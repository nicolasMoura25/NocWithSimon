--
-- REVISADO POR MORAES EM 22/DEZ/2020
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity key_scheduler is
    port
    (
        clock        : in  std_logic;
        reset        : in  std_logic;

        enable       : in  std_logic;

        decrypt      : in  std_logic;

        shared_key_0 : in  std_logic_vector(63 downto 0);
        shared_key_1 : in  std_logic_vector(63 downto 0);

        last_round   : in  std_logic;

        round_key    : out std_logic_vector(63 downto 0);
        ks_ready     : out std_logic
    );
end key_scheduler;

architecture behavorial of key_scheduler is
    -- DEFINES
        constant MOD_62     : std_logic_vector(6 downto 0)  := "0111101";
        constant R68        : std_logic_vector(6 downto 0)  := "1000100";
        constant C_CONSTANT : std_logic_vector(63 downto 0) := x"FFFFFFFFFFFFFFFC";
        constant Z_SEQUENCE : std_logic_vector(63 downto 0) := "00" & "11001101101001111110001000010100011001001011000000111011110101";

        type STATE is (S_INIT, S_INIT_D, S_KEY_GEN, S_ROUND_KEY);
        type KEY_SCHEDULER_REGS is array (0 to 1)  of std_logic_vector(63 downto 0);
        signal CURRENT_STATE, NEXT_STATE: STATE;

        -- ENCRYPTION KEY REGISTERS     
        signal ks_encrypt   : KEY_SCHEDULER_REGS := (others => (others => '0'));
        alias  key_right    : std_logic_vector(63 downto 0) is ks_encrypt(0);
        alias  key_left     : std_logic_vector(63 downto 0) is ks_encrypt(1);

        -- DECRYPTION KEY REGISTERS
        signal ks_decrypt   : KEY_SCHEDULER_REGS := (others => (others => '0'));

        -- MEMORIZE TO AVOID RECOMPUTATION OF DECRYPTION KEYS
        signal ks_last_key  : KEY_SCHEDULER_REGS := (others => (others => '0'));

        signal d_key_ready  : std_logic := '0';

        -- DECRYPTION CONTROL
        signal decrypt_int      : std_logic := '0'; 
        signal first_decryption : std_logic := '0';

        -- SCHEDULER LOGIC
        signal reg_1, reg_2, reg_3, reg_11, reg_22 : std_logic_vector(63 downto 0) := (others => '0');
        signal mod_counter      : integer range 0 to 61 := 0;
        signal mod_counter_std  : integer range 0 to 61 := 0;
        signal mod_counter_inv  : integer range 0 to 61 := 0;
        signal gen_counter      : integer range 0 to 72 := 0;
    
begin

    --------------------------------------------------------------------------------
    -- define como varre a Z_SEQUENCE
    --------------------------------------------------------------------------------
    mod_counter      <= mod_counter_inv when (decrypt_int = '1' and d_key_ready = '1') else mod_counter_std;

    --------------------------------------------------------------------------------
    -- este sinal é fundamental - serve para gerar as chaves iniciais da decriptação
    --------------------------------------------------------------------------------
    first_decryption <= decrypt_int and (not d_key_ready);

    -- combinational part
    --
    reg_3     <= key_left(2 downto 0) & key_left(63 downto 3);
    reg_11    <= reg_3 xor key_right;
    reg_22    <= reg_3(0) & reg_3(63 downto 1);
    reg_2     <= C_CONSTANT (63 downto 1) & Z_SEQUENCE(mod_counter);
    reg_1     <= reg_11 xor reg_22;
  --  round_key <= key_right;
    --
    -- end combinational part

    process(clock, reset)   -- precisa atrasar um ciclo de clock para sincronizar com o 'core'
    begin
        if reset = '1' then
           round_key <= (others=>'0');
        elsif rising_edge(clock) then
           round_key <= key_right;
        end if;
    end process;

    inst_seq:
    process(clock, reset)
    begin
        if reset = '1' then
            ks_encrypt          <= (others => (others => '0'));

            decrypt_int         <= '0';

            mod_counter_std     <= 0;
            mod_counter_inv     <= 0;
            gen_counter         <= 0;

            ks_ready            <= '0';
            d_key_ready         <= '0';

            ks_decrypt          <= (others => (others => '0'));
            ks_last_key         <= (others => (others => '0'));

        elsif rising_edge(clock) then

            case CURRENT_STATE is
                when S_INIT      => ks_ready        <= '0';

                                    decrypt_int     <= decrypt;

                                    if d_key_ready = '0' then        -- por default usa chaves
                                        key_left  <= shared_key_1;
                                        key_right <= shared_key_0;
                                        mod_counter_std <= 0;
                                    else                            -- para decriptar usa a útima chave
                                        key_right   <= ks_decrypt(0);
                                        key_left    <= ks_decrypt(1);
                                        mod_counter_inv <= 3; 
                                    end if;

                                    gen_counter <= 2;


                when S_INIT_D    => d_key_ready     <= '1';
                                    mod_counter_inv <= mod_counter_std - 1;

                                    key_right       <= key_left;
                                    key_left        <= key_right;

                                    ks_decrypt(1)   <= key_right;
                                    ks_decrypt(0)   <= key_left;

                                    ks_last_key(0)  <= shared_key_0;
                                    ks_last_key(1)  <= shared_key_1;                                    

                when S_KEY_GEN   => key_right <= key_left;
                                    key_left  <= reg_2 xor reg_1;

                                    if mod_counter_std = MOD_62 then
                                        mod_counter_std <= 0;
                                    else
                                        mod_counter_std <= mod_counter_std + 1;
                                    end if;

                                    if first_decryption = '0' then
                                        if mod_counter_inv = 0 then
                                            mod_counter_inv <= CONV_INTEGER(MOD_62);
                                        else
                                            mod_counter_inv <= mod_counter_inv - 1;
                                        end if;                                     
                                    else
                                        gen_counter <= gen_counter + 1;
                                    end if;

                when S_ROUND_KEY => ks_ready <= '1';
                                    
                when others =>

            end case;
        end if;
    end process;

    inst_comb:
    process(CURRENT_STATE, enable, decrypt, d_key_ready, gen_counter, last_round)
    begin
        
        case CURRENT_STATE is

            when S_INIT      =>
                if enable = '0' then
                    NEXT_STATE <= S_INIT;
                elsif decrypt = '1' and d_key_ready = '0' then
                    NEXT_STATE <= S_KEY_GEN;
                else
                    NEXT_STATE <= S_ROUND_KEY;
                end if;

            when S_KEY_GEN   =>

                if last_round = '1' then
                    NEXT_STATE <= S_INIT;
                elsif gen_counter = R68 - 1 then
                    NEXT_STATE <= S_INIT_D;
                else
                    NEXT_STATE <= S_KEY_GEN;
                end if;

            when S_INIT_D    => NEXT_STATE <= S_ROUND_KEY;

            when S_ROUND_KEY => NEXT_STATE <= S_KEY_GEN;

            when others      => NEXT_STATE <= S_INIT;
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
