library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity consumer_fsm is
port (
    clk : in std_logic; --50 MHz clock
    reset : in std_logic;

    fifo_empty : in std_logic;
    fifo_dout : in std_logic_vector(11 downto 0);

    fifo_rd_en : out std_logic;

    seg_out : out std_logic_vector(6 downto 0) -- single 7-seg
);
end entity;

architecture rtl of consumer_fsm is 

    type state_type is (IDLE, READ_FIFO, LATCH, DECODE, DISPLAY);
    signal state, next_state : state_type;

    signal data_reg : std_logic_vector(11 downto 0);
    signal digit : std_logic_vector(3 downto 0);

begin

    --State register
    process(clk, reset)
    begin
        if reset = '1' then 
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    --Next State Logic
    process(state, fifo_empty)
    begin
        case state is

            when IDLE =>
                if fifo_empty = '0' then
                    next_state <= READ_FIFO;
                else
                    next_state <= IDLE;
                end if;
            
            when READ_FIFO =>
                next_state <= LATCH;

            when LATCH =>
                next_state <= DECODE;

            when DECODE =>
                next_state <= DISPLAY;

            when DISPLAY =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;

        end case;
    end process;

    --output logic
    process(state)
    begin
        fifo_rd_en <= '0';

        case state is

            when READ_FIFO =>
                fifo_rd_en <= '1'; --one-cycle pulse

            when others =>
                null;

        end case;
    end process;

    --data latch
    process(clk)
    begin
        if rising_edge(clk) then
            if state = READ_FIFO then
                data_reg <= fifo_dout;
            end if;
        end if;
    end process;

    --simple decode
    process(data_reg)
    begin
        digit <= data_reg(3 downto 0); --lowest nibble

        case digit is
            when "0000" => seg_out <= "1111110"; --0
            when "0001" => seg_out <= "0110000"; --1
            when "0010" => seg_out <= "1101101"; -- 2
            when "0011" => seg_out <= "1111001"; -- 3
            when "0100" => seg_out <= "0110011"; --4
            when "0101" => seg_out <= "1011011"; -- 5
            when "0110" => seg_out <= "1011111"; -- 6
            when "0111" => seg_out <= "1110000"; -- 7
            when "1000" => seg_out <= "1111111"; -- 8
            when "1001" => seg_out <= "1111011"; -- 9
            when others => seg_out <= "0000000";
        end case;
    end process;

end architecture;