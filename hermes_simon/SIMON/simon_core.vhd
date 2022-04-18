--
-- REVISADO POR MORAES EM 22/DEZ/2020
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity simon is
    port
    (
        clock        : in  std_logic;                        
        reset        : in  std_logic;

        enable       : in  std_logic;
        decrypt      : in  std_logic;

        shared_key_0 : in  std_logic_vector(63 downto 0);
        shared_key_1 : in  std_logic_vector(63 downto 0);

        plain_left   : in  std_logic_vector(63 downto 0);   
        plain_right  : in  std_logic_vector(63 downto 0);

        cipher_left  : out std_logic_vector(63 downto 0);   
        cipher_right : out std_logic_vector(63 downto 0);
        cipher_ready : out std_logic
    );
end simon;

architecture behavorial of simon is
    -- DEFINES
        constant R68        : std_logic_vector(6 downto 0) := "1000100";
        type STATE is (S_INIT, S_ENCRYPT_NEXT, S_LAST_ROUND);
        signal CURRENT_STATE, NEXT_STATE: STATE;

        -- key scheduler
        signal key_schedule_0 : std_logic_vector(63 downto 0) := (others=> '0');
        signal key_schedule_1 : std_logic_vector(63 downto 0) := (others=> '0');

        signal ks_ready     : std_logic := '0';

        -- control
        signal last_round   : std_logic := '0';
        signal enable_int   : std_logic := '0';

        -- encryption
        signal t_counter    : std_logic_vector(6 downto 0)  := (others=> '0');

        signal right_block  : std_logic_vector(63 downto 0) := (others=> '0');
        signal left_block   : std_logic_vector(63 downto 0) := (others=> '0');
        signal round_key    : std_logic_vector(63 downto 0) := (others=> '0');

        signal temp_block   : std_logic_vector(63 downto 0) := (others=> '0');
        signal shift_1      : std_logic_vector(63 downto 0) := (others=> '0');
        signal shift_2      : std_logic_vector(63 downto 0) := (others=> '0');
        signal shift_8      : std_logic_vector(63 downto 0) := (others=> '0');

begin
    inst_ks : entity work.key_scheduler
    port map (
                    clock        => clock,
                    reset        => reset,

                    enable       => enable,
                    decrypt      => decrypt,

                    shared_key_0 => key_schedule_0,
                    shared_key_1 => key_schedule_1,

                    last_round   => last_round,

                    round_key    => round_key,
                    ks_ready     => ks_ready
    );

    -- combinational part  (FEISTEL)
    --
    shift_1     <= left_block(63-1 downto 0) & left_block(63);
    shift_2     <= left_block(63-2 downto 0) & left_block(63 downto 63-1);
    shift_8     <= left_block(63-8 downto 0) & left_block(63 downto 63-7);
    temp_block  <= round_key xor (shift_2 xor (right_block xor (shift_1 and shift_8)));

    cipher_ready <= not enable_int;   -- avisa que o cipher esta trabalhandov(saída)
    --
    -- end combinational part

    inst_seq:
    process(clock, reset)
    begin
        if reset = '1' then
            key_schedule_0  <= (others=> '0');
            key_schedule_1  <= (others=> '0');

            last_round  <= '0';
            enable_int  <= '0';         

            right_block <= (others=> '0');
            left_block  <= (others=> '0');

            t_counter   <= (others=> '0');

            cipher_left  <= (others=> '0');
            cipher_right <= (others=> '0');

        elsif rising_edge(clock) then
            case CURRENT_STATE is

                when S_INIT          => if enable = '1' then
                                            enable_int   <= '1';
                                        end if;
                                        
                                        last_round      <= '0';

                                        t_counter       <= (others => '0');

                                        right_block <= plain_right;
                                        left_block  <= plain_left;

                                        key_schedule_0  <= shared_key_0;
                                        key_schedule_1  <= shared_key_1;
                                                                        
                when S_ENCRYPT_NEXT  => right_block <= left_block;
                                        left_block  <= temp_block;
                                        t_counter   <= t_counter + 1;

                when S_LAST_ROUND    => cipher_right <= left_block;
                                        cipher_left  <= right_block; 

                                        last_round   <= '1';
                                        enable_int   <= '0';
            end case;
        end if;
    end process;

    inst_comb:
    process(CURRENT_STATE, enable, enable_int, ks_ready, t_counter)
    begin
        
        case CURRENT_STATE is
            when S_INIT =>
                if enable_int = '1' and ks_ready = '1' then
                    NEXT_STATE <= S_ENCRYPT_NEXT; 
                else
                    NEXT_STATE <= S_INIT;
                end if;

            when S_ENCRYPT_NEXT =>
                if t_counter >= R68-1
                  then
                    NEXT_STATE <= S_LAST_ROUND;
                else
                    NEXT_STATE <= S_ENCRYPT_NEXT;  
                end if;

            when S_LAST_ROUND =>
                    NEXT_STATE <= S_INIT;

            when others =>
                NEXT_STATE <= S_INIT;
        end case;
    end process;

    inst_state_ctrl:
    process(clock, reset)
    begin
        if reset = '1' then
            CURRENT_STATE <= S_INIT;
        elsif rising_edge(clock) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;

end behavorial;
