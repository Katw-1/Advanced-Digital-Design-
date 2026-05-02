library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_fsm is
    port (
        clk             : in  std_logic;                       -- ADC clock domain (1 MHz)
        reset           : in  std_logic;
        eoc             : in  std_logic;                       -- end of conversion
        dout            : in  std_logic_vector(11 downto 0);   -- 12-bit ADC output -> direct to RAM
        synced_tail_ptr : in  std_logic_vector(3 downto 0);    -- tail_ptr synced from 50MHz domain

        soc      : out std_logic;                              -- start of conversion

        -- RAM Port A signals (direct to dual-port RAM)
        ram_we   : out std_logic;                              -- WREN_A
        ram_addr : out std_logic_vector(3 downto 0);           -- ADDR_A (head pointer)
        ram_din  : out std_logic_vector(11 downto 0)           -- DIN_A
    );
end entity adc_fsm;

architecture rtl of adc_fsm is

    -- FSM states
    type state_type is (START, WAIT_EOC, WRITE_RAM);
    signal state, next_state : state_type;

    -- head pointer (write address)
    signal head_ptr : unsigned(3 downto 0);

begin

    -- dout goes directly to RAM, no latching needed
    ram_din  <= dout;
    ram_addr <= std_logic_vector(head_ptr);

    -- -------------------------
    -- State register
    -- -------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state <= START;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- -------------------------
    -- Next state logic (full check removed for debug)
    -- -------------------------
    process(state, eoc)
    begin
        case state is
            when START =>
                next_state <= WAIT_EOC;

            when WAIT_EOC =>
                if eoc = '1' then
                    next_state <= WRITE_RAM;
                else
                    next_state <= WAIT_EOC;
                end if;

            when WRITE_RAM =>
                next_state <= START;        -- always go back, ignore full

            when others =>
                next_state <= START;
        end case;
    end process;

    -- -------------------------
    -- Output logic (full check removed for debug)
    -- -------------------------
    process(state)
    begin
        soc    <= '0';
        ram_we <= '0';

        case state is
            when START =>
                soc <= '1';                 -- pulse start of conversion

            when WAIT_EOC =>
                null;

            when WRITE_RAM =>
                ram_we <= '1';              -- always write, ignore full

            when others =>
                null;
        end case;
    end process;

    -- -------------------------
    -- Head pointer (always increment, ignore full)
    -- -------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            head_ptr <= (others => '0');
        elsif rising_edge(clk) then
            if state = WRITE_RAM then
                head_ptr <= head_ptr + 1;   -- wraps automatically (4-bit)
            end if;
        end if;
    end process;

end architecture rtl;