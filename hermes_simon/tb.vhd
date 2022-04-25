------------------------------------------------------------------------------ 
-- FERNANDO9 MORAES -  31/maio/2021
------------------------------------------------------------------------------ 
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use work.HermesPackage.all;
use work.standards.all;
use STD.TEXTIO.all;

entity tb is
    generic(X_ROUTERS: integer := 3;
            Y_ROUTERS: integer := 3 );
end;

architecture a1 of tb is

    constant NUM_ROUTERS : integer :=  X_ROUTERS * Y_ROUTERS;

    ------------------------------------------------------------------------------ can stay here
    function RouterAddress(router: integer) return std_logic_vector is
        variable pos_x, pos_y : regquartoflit; 
        variable addr : regmetadeflit; 
        variable aux  : integer;
    begin 
        aux := (router/X_ROUTERS);
        pos_x := conv_std_logic_vector((router mod X_ROUTERS),QUARTOFLIT);
        pos_y := conv_std_logic_vector(aux,QUARTOFLIT); 
        addr := pos_x & pos_y;
        return addr;
    end RouterAddress;


    signal reset : std_logic;
    signal clock_rx : std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
    signal rx, credit_o: std_logic_vector((NUM_ROUTERS-1) downto 0) := (others=>'0');
    signal clock_tx, tx, credit_i: std_logic_vector((NUM_ROUTERS-1) downto 0);
    signal data_in, data_out : arrayNrot_regflit((NUM_ROUTERS-1) downto 0);

    -- delta cycles
    signal cycles : integer := 0;

         
    --
    -- DEFINITION OF THE PACKETS TO INJECT INTO THE NOC
    --   
    type packet is record
         start, size, src, tgt :  integer;
         encrypt : std_logic;
    end record;
    type tpacket is array(natural range <>) of packet;

    -- each block has 128 bits - the size of the block to cypher
    constant FB : integer := 128/TAM_FLIT;   --  FB: flits_per_block:  8 flits per block for TAM_FLIT=16; and 4 flits per block for TAM_FLIT=32

    constant tp : tpacket := (--start size    src tgt  encrypt     --------- size is a function of FB
                              ( 10,     2*FB,    0,  8, '1'), 
                              ( 10,       FB,    2,  6, '1'),  
                              ( 310,    4*FB,    0,  7, '1'),  
                              ( 12,    5*FB,    8,  0, '1'),  
                              ----- ( 40,    3*FB,    2,  3, '1),   -- BUG - ESTE PACOTE NÃO PASSA DEVIDO A FORMA COMO FOI FEITA A GERAÇÃO DOS PACOTES
                              ( 400,   20*FB,    2,  3, '1')
                             );  

    -- packet transmission - one FSM per packet
    type pckstate_t is (WAITING, HEADER, SIZE, PAYLOAD, DONE);
    type pckstate is array(0 to tp'high) of pckstate_t;
    signal pkt_state : pckstate;

    -- vector of integers (one entry per packet)
    type ivector is array(0 to tp'high) of INTEGER range 0 to 255;
    signal pkt_used, pkt_cont: ivector;

    -- for debug purposes - output file ------------------------------------------
    file rcp_file : TEXT open WRITE_MODE is "rcp_packet.txt";
    type lines is array(0 to NUM_ROUTERS-1) of line;

    type flags is array(0 to NUM_ROUTERS-1) of integer;
    signal flag, cs, csize, t0: flags := (others=>0);

begin
    reset <= '1', '0' after 5 ns;

    -- clock signal that goes to each router
    clocks_router: for i in 0 to NUM_ROUTERS-1 generate
          clock_rx(i) <=  not clock_rx(i) after 500 ps;   
    end generate clocks_router;

    credit_i <= (others => '1');   -- *********   local ports that you can consume data (Moraes)

    noc1: Entity work.NOC
    generic map(  X_ROUTERS => X_ROUTERS,
                  Y_ROUTERS => Y_ROUTERS)
    port map(
              clock=>clock_rx, reset=>reset,
      
              -- data that goes to the NoC, controlled by credit_o
              clock_rxLocal=>clock_rx,    rxLocal=>rx,  data_inLocal=>data_in,   credit_oLocal=>credit_o,
      
              -- data reception from NoC
              clock_txLocal => clock_tx,  txLocal=>tx,  data_outLocal=>data_out, credit_iLocal => credit_i
            );

    -- cycle counter process
    cycle_counter : process (clock_rx(0), reset) begin
        if rising_edge(clock_rx(0)) then
            if reset = '0' then 
                cycles <= cycles + 1;
            else 
                cycles <= 0;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    --  one FSM per packet!, according to the timestamps to start the transmission
    --  this process is reponsible to generate the traffic specified in tpacket
    ----------------------------------------------------------------------------
    process(clock_rx(0), reset)
      begin
          for i in 0 to tp'high loop

            if reset = '1' then 
                 pkt_state(i) <= WAITING;
                 rx(tp(i).src) <= '0';
                 data_in(tp(i).src) <= (others => '0');
                 pkt_used <= (others => 0);
            elsif rising_edge(clock_rx(0)) then
              if pkt_used(i) = 0 then    -- AVOID EFFECT OF PAST PACKET IN CURRENT PACKETS WITH THE SAME SOURCE ADDRESS
                 case pkt_state(i) is
                    when WAITING =>  -- must verify rx, to avoid superposed packets --
                                     if cycles >= tp(i).start and rx(tp(i).src)='0' and credit_o(tp(i).src)='1' then  
                                        pkt_state(i) <= HEADER; 
                                        data_in(tp(i).src) <=  RouterAddress(tp(i).src) & RouterAddress(tp(i).tgt);    --- **** ADDED SOURCE IN THE MSB
                                        data_in(tp(i).src)(TAM_FLIT-1) <= tp(i).encrypt;   -- diz se precisa ou não criptografar
                                        rx(tp(i).src) <= '1';
                                     end if;

                    when HEADER =>  if credit_o(tp(i).src)='1' then    
                                         pkt_state(i) <= SIZE; 
                                         pkt_cont(i) <= tp(i).size;  -- store the packet size
                                         data_in(tp(i).src) <=  conv_std_logic_vector( tp(i).size, TAM_FLIT);
                                    end if;

                    when SIZE =>  if credit_o(tp(i).src)='1' then   
                                         pkt_state(i) <= PAYLOAD;
                                         pkt_cont(i) <= pkt_cont(i)-1;
                                         data_in(tp(i).src) <= conv_std_logic_vector(cycles, TAM_FLIT);   -- first flit is the injection moment
                                  end if;   

                     when PAYLOAD =>  if pkt_cont(i)>0 and credit_o(tp(i).src)='1'  then   
                                         pkt_cont(i) <= pkt_cont(i)-1;
                                         data_in(tp(i).src)(TAM_FLIT-1 downto METADEFLIT) <= tp(i).size+1-conv_std_logic_vector(pkt_cont(i), TAM_FLIT/2); 
                                         data_in(tp(i).src)(METADEFLIT-1 downto 0) <= tp(i).size+1-conv_std_logic_vector(pkt_cont(i), TAM_FLIT/2); 
                                      elsif pkt_cont(i)=0 and credit_o(tp(i).src)='1' then
                                         pkt_state(i) <= DONE;
                                         rx(tp(i).src) <= '0';
                                         pkt_used(i) <= 1;  -- THIS PACKET IS NOW USED AND WILL NOT BE USED AGAIN
                                      end if;

                    when DONE  =>   rx(tp(i).src) <= '0';
                                    data_in(tp(i).src) <= (others => '0');
                 end case; 
              end if;
            end if;
          end loop;

    end process;

    ----------------------------------------------------------------------------
    -- log file
    ----------------------------------------------------------------------------
    process(clock_rx(0), reset)
        variable my_line: lines;
        variable spc: string(1 to 2) := "..";
      begin
             for r in 0 to NUM_ROUTERS-1 loop

                 if rising_edge(clock_rx(0)) then
                     if tx(r)='1' and credit_i(r)='1' then

                           if flag(r)=0 then
                              write(my_line(r), "From: " & integer'image( CONV_INTEGER(data_out(r)(TAM_FLIT-2 downto TAM_FLIT-QUARTOFLIT)) +
                                                                          X_ROUTERS*CONV_INTEGER(data_out(r)(TAM_FLIT-QUARTOFLIT-1 downto METADEFLIT)))  & 
                                                " To: "  & integer'image(r) & " P: ");
                           end if;

                           for f in TAM_FLIT/4 downto 1 loop
                                write(my_line(r), CONV_HEX(CONV_INTEGER(data_out(r)( f*4-1 downto f*4-4))));
                           end loop;

                           write(my_line(r), spc );

                           flag(r) <= 1;

                           cs(r) <= cs(r) + 1;

                           if cs(r)=2 then   -- first data flit
                                 t0(r) <= CONV_INTEGER(data_out(r));
                           end if;
                           if cs(r)=1 then  
                                csize(r) <= CONV_INTEGER(data_out(r)); 
                           elsif csize(r) > 0 then
                                 csize(r) <=  csize(r) - 1;
                           end if;
                     end if;
                 end if;

                 if tx(r)='0' and flag(r)=1 and csize(r)=0 then    -- packeted ended and I can write it to the outoup file
                           write(my_line(r), " [Latency: " & integer'image(cycles-t0(r)) & "]");
                           writeline(rcp_file, my_line(r));
                           flag(r) <= 0;
                           cs(r) <= 0;
                 end if;

             end loop;
    end process;

end a1;
