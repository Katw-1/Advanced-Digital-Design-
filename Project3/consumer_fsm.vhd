 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity consumer_fsm is
    port (
        clk      : in  std_logic;                      -- 50MHz read domain
        reset    : in  std_logic;
 
        -- synced head_ptr (from gray_sync -> gray_to_bin)
        head_ptr : in  std_logic_vector(3 downto 0);
 
        -- tail_ptr -> RAM ADDR_B and FIFO_SYNC wdata (same signal)
        tail_ptr : out std_logic_vector(3 downto 0)
    );
end entity consumer_fsm;
 
architecture rtl of consumer_fsm is
 
    -- FSM states
    type state_type is (IDLE, READ_RAM, INCREMENT);
    signal state, next_state : state_type;
 
    -- internal tail pointer
    signal tail_ptr_reg : unsigned(3 downto 0);
 
begin
 
    -- tail_ptr drives both RAM ADDR_B and FIFO_SYNC wdata in top level
    tail_ptr <= std_logic_vector(tail_ptr_reg);
 
    -- -------------------------
    -- State register
    -- -------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
 
    -- -------------------------
    -- Next state logic (empty check removed for debug)
    -- -------------------------
    process(state)
    begin
        case state is
            when IDLE =>
                next_state <= READ_RAM;     -- always read, ignore empty
 
            when READ_RAM =>
                next_state <= INCREMENT;
 
            when INCREMENT =>
                next_state <= IDLE;
 
            when others =>
                next_state <= IDLE;
        end case;
    end process;
 
    -- -------------------------
    -- Tail pointer increment
    -- -------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            tail_ptr_reg <= (others => '0');
        elsif rising_edge(clk) then
            if state = INCREMENT then
                tail_ptr_reg <= tail_ptr_reg + 1;  -- wraps automatically (4-bit)
            end if;
        end if;
    end process;
 
end architecture rtl;

 