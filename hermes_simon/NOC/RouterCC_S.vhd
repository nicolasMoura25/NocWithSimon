------------------------------------------------------------------------------ 
-- FERNANDO9 MORAES -  31/maio/2021
------------------------------------------------------------------------------ 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HermesPackage.all;

entity RouterCC_S is
generic( address: regmetadeflit);
port(
	clock:     in  std_logic;
	reset:     in  std_logic;
	clock_rx:  in  regNport;
	rx:        in  regNport;
	data_in:   in  arrayNport_regflit;
	credit_o:  out regNport;    
	clock_tx:  out regNport;
	tx:        out regNport;
	data_out:  out arrayNport_regflit;
	credit_i:  in  regNport);
end RouterCC_S;

architecture RouterCC_S of RouterCC_S is

	signal w_tx, w_rx, w_credit_i, w_credit_o : regNport;
	signal w_data_in, w_data_out : arrayNport_regflit;

begin

    -- connect N / S / W / E - connect all ports, except the local one
	nswe_ports : for i in 0 to(NPORT-2) generate
           w_rx(i)       <= rx(i); 
           w_data_in(i)  <= data_in(i);
           credit_o(i)   <= w_credit_o(i);

           data_out(i)   <= w_data_out(i);
           tx(i)         <= w_tx(i);
           w_credit_i(i) <= credit_i(i);
	end generate nswe_ports;  


    router: entity work.RouterCC
	  generic map( address => address )
	  port map(
		clock    => clock,
		reset    => reset,
		clock_rx => clock_rx,
		rx       => w_rx,
		data_in  => w_data_in,
		credit_o => w_credit_o,
		clock_tx => clock_tx,
		tx       => w_tx,
		data_out => w_data_out,
		credit_i => w_credit_i);                          
   

    -- data from the PE in the local port
    wrapper_in : entity work.simon_wrapper
         port map(
                   clock => clock,
                   reset => reset,
    
                   IN_data_in  =>   data_in(LOCAL),
                   IN_rx       =>   rx(LOCAL),
                   IN_credit_o =>   credit_o(LOCAL),
                 
                   OUT_data_in  =>    w_data_in(LOCAL),
                   OUT_rx       =>    w_rx(LOCAL),
                   OUT_credit_o =>    w_credit_o(LOCAL),

                   decrypt     => '0'     ------------------------------- encripta o pacote
                 );


    wrapper_out : entity work.simon_wrapper
    port map(
              clock => clock,
              reset => reset,
    
              IN_data_in  =>   w_data_out(LOCAL),
              IN_rx       =>   w_tx(LOCAL),
              IN_credit_o =>   w_credit_i(LOCAL),
            
              OUT_data_in  =>   data_out(LOCAL) ,
              OUT_rx       =>   tx(LOCAL),
              OUT_credit_o =>   credit_i(LOCAL),

              decrypt     => '1'    ------------------------------- decripta o pacote
            );
                   
end RouterCC_S;
