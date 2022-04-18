library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.log2;
use ieee.math_real.ceil;
use work.HermesPackage.all;

-- interface da Hermes_buffer
entity simon_wrapper is
port(
    clock:      in  std_logic;
    reset:      in  std_logic;

    IN_data_in:   in  regflit;
    IN_rx:        in  std_logic;
    IN_credit_o:  out std_logic;

    OUT_data_in:   out regflit;
    OUT_rx:        out std_logic;
    OUT_credit_o:  in  std_logic;

    decrypt:     in  std_logic
   );
end simon_wrapper;

architecture a1 of simon_wrapper is

     --
     -- internal buffers:  buf is the input buffer and buf_out the output buffer
     --
     constant BUF_SIZE: integer := 128/TAM_FLIT;     -- 128 bits / 16 bit-flit = 8 posições
     constant BUF_BITS: integer := INTEGER(CEIL(LOG2(REAL(BUF_SIZE))));

     type bf is array(0 to BUF_SIZE-1) of regflit;   
     signal buf, buf_out, buf_copy, buf_simon: bf := (others=>(others=>'0'));
     signal cont: std_logic_vector(BUF_BITS downto 0);

     type st is (S_iddle, S0, S1, S1b, S2);
     signal EA: st;

     type st_out is (S_iddle, S0, S1, S_H, S_S);
     signal O_EA : st_out;
     
     signal contO: integer ;

     signal size, h_target, h_size, cont_flit_out: regflit ;
     signal go, output_buffer_in_use: std_logic;

     signal must_by_pass_simon, encrypt, cipher_ready: std_logic;
   
     signal cipher_left, cipher_right, plain_left, plain_right : std_logic_vector(63 downto 0);

     constant key: std_logic_vector(127 downto 0) := x"CECDBEFDEAEDFFCDCCACCABBDCBCFEDA";  -- key

begin

    -- há crédito se o buffer de entrada não encheu (most significat bit)   ** IMPORTANT **
    IN_credit_o <= '1' when cont(BUF_BITS)='0' else
                   '0';

    ----------------------------------------------------------------------------
    -- FSM and input registers
    ----------------------------------------------------------------------------
    process(reset, clock)
    begin
        if reset='1' then
            EA      <= S_iddle;
            cont    <= (others=>'0') ;
            size    <= (others=>'0') ;
            encrypt <= '0';
            go      <= '0' ;

        elsif rising_edge(clock) then

         case EA is

          when S_iddle =>  if IN_rx='1' then 
                               EA <= S0;
                               h_target <= IN_data_in;
                               must_by_pass_simon <= not(IN_data_in(TAM_FLIT-1));   -- bit mais significativo indica se encripta ou não
                           end if;
                           go <= '0';

          when S0 =>       if IN_rx='1' then   -- payload size
                                  EA <= S1;
                           end if;

                           size   <= IN_data_in;
                           h_size <= IN_data_in;
                           cont <= (others=>'0');

          when S1 =>       -- fill the input buffer
                           if cont=BUF_SIZE then
                                  if must_by_pass_simon='0'then
                                        encrypt <= '1';   -- habilita a encriptação
                                  end if;
                                  EA <= S1b;
                            else 
                                  cont <= cont + 1;
                                  go <= '0';
                                  buf(CONV_INTEGER(cont)) <= IN_data_in;
                                  size <= size - 1;
                            end if;

          when S1b =>      EA <= S2;   -- it takes one clock cycle to fall cipher_ready

          when S2 =>       encrypt <= '0';
                           if cipher_ready='1' or must_by_pass_simon='1' then   -- assim que sobe o encrypt o cipher_ready desce duranta a encriptação

                               -- verifica se o buffer de saída esta livre
                               if output_buffer_in_use='0' then
                                   cont <= (others=>'0');
                                   go <= '1';         -- can transfer to the other buffer
                                   if size=0 then     -- terminou o pacote ou continua a receber
                                      EA <= S_iddle;
                                   else
                                      EA <= S1;
                                  end if;  
                               end if;

                          end if;

         end case;
       end if;
    end process;
    

    ----------------------------------------------------------------------------
    -- modulo  SIMON
    ----------------------------------------------------------------------------
    encription : entity work.simon
    port map (
                clock        => clock,
                reset        => reset,
                enable       => encrypt,
                decrypt      => decrypt,    -- sinal de entrada que diz o que o core tem que fazer
                shared_key_0 => key(63 downto 0),
                shared_key_1 => key(127 downto 64),
                plain_left   => plain_left,
                plain_right  => plain_right,
                cipher_left  => cipher_left,
                cipher_right => cipher_right,
                cipher_ready => cipher_ready
            );


    -- buffers that communicate with simon
    buf_gen: for i in BUF_SIZE/2-1 downto 0 generate

        plain_left(  (i+1)*TAM_FLIT-1 downto i*TAM_FLIT) <= buf(i);
        plain_right( (i+1)*TAM_FLIT-1 downto i*TAM_FLIT) <= buf(i+BUF_SIZE/2);

        buf_simon(i)            <= cipher_left(  (i+1)*TAM_FLIT-1 downto i*TAM_FLIT);
        buf_simon(i+BUF_SIZE/2) <= cipher_right( (i+1)*TAM_FLIT-1 downto i*TAM_FLIT);

    end generate;

    -- MAKE A COPY OF THE INPUT BUFFER IF IT IS NOT NECESSARY TO ENCRYPT
    process(reset, clock)
    begin
        if reset='1' then
            buf_copy <= (others=>(others=>'0'));  
        elsif rising_edge(clock) then
           if go='1' then
            buf_copy <= buf;
           end if;
        end if;
     end process;

    buf_out <=  buf_copy when must_by_pass_simon='1' else     -- large mux :-(
                buf_simon;


    -- exemplo para 16 bits
    --plain_left <= buf(3) & buf(2) & buf(1) & buf(0);
    --plain_right <= buf(7) & buf(6) & buf(5) & buf(4);
    --buf_out(7) <= cipher_right(63 downto 48);
    --buf_out(6) <= cipher_right(47 downto 32);
    --buf_out(5) <= cipher_right(31 downto 16);
    --buf_out(4) <= cipher_right(15 downto 0);
    --buf_out(3) <= cipher_left(63 downto 48);
    --buf_out(2) <= cipher_left(47 downto 32);
    --buf_out(1) <= cipher_left(31 downto 16);
    --buf_out(0) <= cipher_left(15 downto 0);


    ----------------------------------------------------------------------------
    -- FSM e registradores de entrada
    ----------------------------------------------------------------------------
    process(reset, clock)
    begin
        if reset='1' then
            O_EA <= S_iddle;
            contO <= 0;
            OUT_rx <= '0';                    -- signalize output data
            OUT_data_in <= (others=>'0');     -- output data
            output_buffer_in_use <= '0';
        elsif rising_edge(clock) then
            case O_EA is
                when S_iddle =>  OUT_rx  <= '0' ;
                                 contO <= 0;

                                 if go='1' then 
                                    O_EA <= S_H;
                                    output_buffer_in_use <= '1';
                                 else
                                    output_buffer_in_use <= '0';
                                 end if;

                when S_H =>  if  OUT_credit_o='1' then    -- send address
                                 OUT_data_in <= h_target;
                                 OUT_rx <= '1' ;
                                 O_EA <= S_S;
                              else
                                 OUT_rx <= '0' ;  
                              end if;

                when S_S =>  if  OUT_credit_o='1' then -- send size
                                 OUT_data_in <= h_size;
                                 cont_flit_out <= h_size;
                                 OUT_rx <= '1' ;
                                 O_EA <= S0;
                              else
                                 OUT_rx <= '0' ;  
                              end if;

                when S0 =>    if  OUT_credit_o='1' then       -------------------- a dada iteração em S0 envia 128

                                 OUT_data_in <= buf_out(contO);
                                 OUT_rx <= '1' ;

                                 cont_flit_out <= cont_flit_out - 1;
                              
                                 if contO=BUF_SIZE-1 then   
                                      contO<=0;  
                                      O_EA <= S1;
                                      output_buffer_in_use <= '0';
                                  else  
                                      contO <= contO + 1;   
                                  end if;
                              else
                                 OUT_rx <= '1' ;  
                              end if;

                when S1 =>   OUT_rx <= '0';
                             contO <= 0;

                             if cont_flit_out=0 then   
                                      O_EA <= S_iddle;    -- final de pacote
                              elsif go='1' then 
                                 O_EA <= S0;
                                 output_buffer_in_use <= '1';
                              end if;

            end case;
        end if;
    end process;

     
end a1;
