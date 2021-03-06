library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.log2;
use ieee.math_real.ceil;
use work.HermesPackage.all;

-- interface da Hermes_buffer
entity simon_wrapper is
port(
	clock:			in  std_logic;
	reset:			in  std_logic;

	IN_data_in:		in  regflit;
	IN_rx:			in  std_logic;
	IN_credit_o:	out std_logic;

	OUT_data_in:	out regflit;
	OUT_rx:			out std_logic;
	OUT_credit_o:	in  std_logic;

	decrypt:		in  std_logic
   );
end simon_wrapper;

architecture a1 of simon_wrapper is

     --
     -- internal buffers:  buf is the input buffer and buf_out the output buffer
     --
	constant BUF_SIZE: integer := 128/TAM_FLIT;     -- 128 bits / 16 bit-flit = 8 posições
    constant BUF_BITS: integer := INTEGER(CEIL(LOG2(REAL(BUF_SIZE))));

    type bf is array(0 to BUF_SIZE-1) of regflit;   
    signal cont: std_logic_vector(BUF_BITS downto 0);

    type st is (S_iddle, S0, S1, S2, S3, Initializer, by_pass);
    signal EA: st;

    type st_out is (S_iddle, S0, S1, S_H, S_S);
    signal O_EA : st_out;
     
    signal contO: integer ;

    signal size, h_target, h_size, cont_flit_out, out_buff, by_pass_buff: regflit ;
	signal go, output_buffer_in_use: std_logic;
	signal must_by_pass_simon, encrypt, cipher_ready, OUT_rx_crypted, OUT_rx_by_passed : std_logic;   

	constant key: std_logic_vector(127 downto 0) := x"BDCBCFEDACCACCABEAEDFFCDCECDBEFD";

	signal key_cont: integer range 0 to 128/TAM_FLIT;
	signal data_word_in, data_word_out, key_word_in	:	std_logic_vector(31 downto 0):=(others=>'0');
	signal key_valid, key_sent, data_valid, reset_to_key, buff_populated : std_logic;
	signal key_length    : std_logic_vector(1 downto 0);
	
	type st_key is (reset_key, send_lenth, send_key, key_ok );
    signal key_state : st_key;
	signal cypher_Buff : bf := (others=>(others=>'0'));
	signal cypher_position: integer range 0 to 4;
	

begin

	-- há crédito se o buffer de entrada não encheu (most significat bit)   ** IMPORTANT **
	IN_credit_o <= '1' when cont(BUF_BITS)='0' else '0';
	
	OUT_data_in <= by_pass_buff when EA=by_pass else out_buff;
	
	OUT_rx <= '1' when EA=by_pass else OUT_rx_crypted;
	
	

    ----------------------------------------------------------------------------
    -- FSM and input registers
    ----------------------------------------------------------------------------
	process(reset, clock)
	begin
		if reset='1' then
			EA			<= Initializer;
			cont		<= (others=>'0') ;
			size		<= (others=>'0') ;
			encrypt		<= '0';
			go			<= '0';
			data_valid	<= '0';
			OUT_rx_by_passed <= '0';

		elsif rising_edge(clock) then
			case EA is
				when Initializer =>	if	key_sent = '1' then
										EA <= S_iddle;
									end if;								

				when S_iddle =>	if IN_rx='1' then 
									EA <= S0;
									h_target <= IN_data_in;
									must_by_pass_simon <= not(IN_data_in(TAM_FLIT-1));   -- bit mais significativo indica se encripta ou não
								end if;
									go <= '0';

				when S0 =>		if IN_rx='1' then   -- payload size
									EA <= S1;
								end if;

								size   <= IN_data_in;
								h_size <= IN_data_in;
								cont <= (others=>'0');

				when S1 =>	if must_by_pass_simon='0'then
									if (cont < 4) then 
										if IN_rx='1' then
											data_valid <= '1';
											data_word_in <= IN_data_in;                            
											cont <= cont + 1;
											go <= '0';
											size <= size - 1;
										end if;
									else
										encrypt <= not decrypt;   -- enable Encrypt
										EA <= S2;
										data_valid <= '0';
									end if;
								else
									EA <= by_pass;
								end if; 

				when S2 =>		if buff_populated = '1' then 
									go <= '1';         -- can transfer to the other buffer
									EA <= S3;
								end if;
								
				when by_pass =>	if IN_rx='1' then 
									by_pass_buff <= IN_data_in;
									size <= size - 1;
								end if;
								
								if size=0 then     -- terminou o pacote ou continua a receber
									EA <= S_iddle;
								else
								end if;
								
				when S3 =>
					go <= '0';
					if IN_rx='1' or size=0 then
						cont <= (others=>'0');
						if size=0 then     -- terminou o pacote ou continua a receber
							EA <= S_iddle;
						else
							EA <= S1;
						end if;
					end if;
				end case;
		end if;
	end process;
    

	----------------------------------------------------------------------------
	-- modulo  SIMON
	----------------------------------------------------------------------------
			
	encription : entity work.noekeon_top
	port map (
				clk           => clock,
				reset_n       => reset_to_key,
				encryption    => encrypt,
				key_length    => key_length,
				key_valid     => key_valid,
				key_word_in   => key_word_in,
				data_valid    => data_valid,
				data_word_in  => data_word_in,
				data_word_out => data_word_out,
				data_ready    => cipher_ready
            );

	-- Buffer to Store the Crypted data
	process(reset, clock)
	begin
	if reset='1' then
		cypher_Buff <= (others=>(others=>'0'));  
		cypher_position <= 0;
		buff_populated <= '0';
		elsif rising_edge(clock) then
			if cipher_ready='1' and output_buffer_in_use = '0'  then
				if must_by_pass_simon ='1' then
					cypher_Buff(cypher_position) <= IN_data_in;
				else
					cypher_Buff(cypher_position) <= data_word_out;	
				end if;
				
				if cypher_position < 3 then 
					cypher_position <= cypher_position +1;
				else
					cypher_position <= 0;
					buff_populated <= '1';
				end if;
			else 
				buff_populated <= '0';
			end if;			
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- FSM to send Key
	----------------------------------------------------------------------------
	process(reset, clock)
	begin
		if reset='1' then
			key_state <= send_lenth;
			key_sent <= '0';
			key_word_in <= (others=>'0');
			reset_to_key <= '0';
		elsif rising_edge(clock) then
			case key_state is
				when reset_key =>	reset_to_key <= '0';	
				
				when send_lenth =>	reset_to_key <= '1';
									key_length   <= "00"; -- Set "00" to 128 bit
									key_state <= send_key;
									
				when send_key =>	key_word_in  <= key((key_cont+1)*TAM_FLIT-1 downto key_cont*TAM_FLIT);
									key_cont <= key_cont +1;
									if key_cont = 0  then
										key_valid    <= '1';								
									elsif key_cont = 3 and key_cont /= 0 then 										
										key_cont <= 0;
										key_state <= key_ok;
									end if;
				when key_ok =>
					key_valid	<= '0';
					key_sent	<= '1';
					key_word_in	<= x"00000000";
			end case;	
		end if;
	end process;

	----------------------------------------------------------------------------
	-- FSM e registradores de entrada
	----------------------------------------------------------------------------
	process(reset, clock)
	begin
	if reset='1' then
		O_EA <= S_iddle;
		contO <= 0;
		OUT_rx_crypted <= '0';                    -- signalize output data
		out_buff <= (others=>'0');     -- output data
		output_buffer_in_use <= '0';
		elsif rising_edge(clock) then
			case O_EA is
				when S_iddle =>	OUT_rx_crypted	<= '0';
								contO	<= 0;
								if go='1' then 
									O_EA <= S_H;
									output_buffer_in_use <= '1';
								else
									output_buffer_in_use <= '0';
								end if;

				when S_H	=>	if OUT_credit_o='1' then    -- send address
									out_buff <= h_target;
									OUT_rx_crypted <= '1' ;
									O_EA <= S_S;
								else
									OUT_rx_crypted <= '0' ;  
								end if;

				when S_S 	=>  if OUT_credit_o='1' then -- send size
									out_buff <= h_size;
									cont_flit_out <= h_size;
									OUT_rx_crypted <= '1' ;
									O_EA <= S0;
								else
									OUT_rx_crypted <= '0' ;  
								end if;
							
				when S0 	=>	if OUT_credit_o='1' then       -------------------- a dada iteração em S0 envia 128
									out_buff <= cypher_Buff(contO);
									OUT_rx_crypted <= '1' ;
									cont_flit_out <= cont_flit_out - 1;
									if contO=BUF_SIZE-1 then   
										contO<=0;  
										O_EA <= S1;
										output_buffer_in_use <= '0';
									else  
										contO <= contO + 1;   
									end if;
								else
									OUT_rx_crypted <= '1' ;  
								end if;

				when S1		=>	OUT_rx_crypted <= '0';
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
