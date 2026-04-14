library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rctl is
    generic (
        ADDRSIZE : integer := 1
    );
    port (
        rclk     : in  std_logic;
        rrst_n   : in  std_logic;
        rget     : in  std_logic;
        rq2_wptr : in  std_logic_vector(ADDRSIZE downto 0);  
        rptr     : out std_logic_vector(ADDRSIZE downto 0);
        re       : out std_logic;                             
        rrdy     : out std_logic
    );
end entity rctl;

architecture rtl of rctl is

    signal rbin      : unsigned(ADDRSIZE downto 0) := (others => '0');
    signal rbin_next : unsigned(ADDRSIZE downto 0);
    signal rgray     : std_logic_vector(ADDRSIZE downto 0);
    signal rempty     : std_logic;
    signal rempty_val : std_logic;

begin

    -- Read enable: only when requested and not empty
    re        <= rget and (not rempty);                       
    rbin_next <= rbin + 1 when (rget = '1' and rempty = '0') else rbin;

    -- rptr register: D flip-flop, clocked on rclk, async reset
    process(rclk, rrst_n)
    begin
        if rrst_n = '0' then
            rbin   <= (others => '0');
            rempty <= '1';                                    
        elsif rising_edge(rclk) then
            rbin   <= rbin_next;
            rempty <= rempty_val;
        end if;
    end process;

    -- Binary-to-Gray: combinational
    rgray <= std_logic_vector(rbin_next xor ('0' & rbin_next(ADDRSIZE downto 1)));

    -- Empty when rgray equals the synced write pointer exactly
    rempty_val <= '1' when (rgray = rq2_wptr) else '0';      

    -- rrdy = NOT empty
    rrdy <= not rempty;
    rptr <= rgray;

end architecture rtl;