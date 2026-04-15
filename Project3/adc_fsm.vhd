library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_fsm is
port (
    clk : in std_logic; --ADC clock domain (1 MHz)
    reset : in std_logic;

    eoc : in std_logic; --end of conversion
    dout : in std_logic_vector(11 downto 0); -- 12-bit ADC output

    soc : out std_logic; -- start of conversion
    fifo_we : out std_logic; --write enable to FIFO
    fifo_din : out std_logic_vector(11 downto 0) --data to FIFO

);
end entity;

architecture rtl of adc_fsm is

    --FSM states
    type state_type is (IDLE, START, WAIT_EOC, READ, WRITE_FIFO);
    signal state, next_state : state_type;

    --internal registers
    signal data_reg : std_logic_vector(11 downto 0);

begin
    --state register
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    --next state logic
    process(state, eoc)
    begin
        case state is
            when IDLE =>
            next_state <= START;

            when START =>
                next_state <= WAIT_EOC;
            
            when WAIT_EOC =>
                if eoc = '1' then
                    next_state <= READ;
                else
                    next_state <= WAIT_EOC;
                end if;

            when READ =>
                next_state <= WRITE_FIFO;

            when WRITE_FIFO =>
                next_state <= START;

            when others =>
                next_state <= IDLE;

        end case;
    end process;

    --output logic
    process(state)
    begin
        --default values
        soc <= '0';
        fifo_we <= '0';
        fifo_din <= (others => '0');

        case state is

            when IDLE =>
                null;
            
            when START =>
                soc <= '1'; --pulse start of conversion
            
            when WAIT_EOC =>
                null;

            when READ =>
                null; --latch ADC output

            when WRITE_FIFO =>
                fifo_we <= '1';
                fifo_din <= data_reg;

        end case;
    end process;

    -- data register
    process(clk)
    begin
        if rising_edge(clk) then
            if state = READ then
                data_reg <= dout;
            end if;
        end if;
    end process;
end architecture;
