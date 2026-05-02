library ieee;
use ieee.std_logic_1164.all;
 
entity gray_sync is
    generic (
        WIDTH : positive := 12
    );
    port (
        clk_b    : in  std_logic;           
        reset_b  : in  std_logic;            
        gray_in  : in  std_logic_vector(WIDTH-1 downto 0);   
        gray_out : out std_logic_vector(WIDTH-1 downto 0)    
    );
end entity gray_sync;


architecture rtl of gray_sync is
 
    signal ff1, ff2 : std_logic_vector(WIDTH-1 downto 0);
 
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of ff1 : signal is "TRUE";
    attribute ASYNC_REG of ff2 : signal is "TRUE";
 
begin
 
    sync_proc : process(clk_b, reset_b)
    begin
        if reset_b = '0' then
            ff1 <= (others => '0');
            ff2 <= (others => '0');
        elsif rising_edge(clk_b) then
            ff1 <= gray_in;   
            ff2 <= ff1;       
        end if;
    end process;
 
    gray_out <= ff2;
 
end architecture rtl;