library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wctl is
    generic (
        ADDRSIZE : integer := 1   -- 1-deep: pointer width = ADDRSIZE+1 bits
    );
    port (
        wclk     : in  std_logic;
        wrst_n   : in  std_logic;
        wput     : in  std_logic;                             
        wq2_rptr : in  std_logic_vector(ADDRSIZE downto 0);  -- sync'd rptr (2-FF sync)

        wptr     : out std_logic_vector(ADDRSIZE downto 0);  -- Gray write pointer → sync2
        we       : out std_logic;                             -- write enable → RAM
        wrdy     : out std_logic                              
    );
end entity wctl;

architecture rtl of wctl is

    -- Internal binary counter and Gray-coded pointer
    signal wbin      : unsigned(ADDRSIZE downto 0) := (others => '0');
    signal wbin_next : unsigned(ADDRSIZE downto 0);
    signal wgray     : std_logic_vector(ADDRSIZE downto 0);

    -- Full flag
    signal wfull     : std_logic;
    signal wfull_val : std_logic;

begin

    -- AND gate: accept write only when not full
    we       <= wput and (not wfull);
    wbin_next <= wbin + 1 when (wput = '1' and wfull = '0') else wbin;

   
    -- wptr register: D flip-flop, clocked on wclk, async reset
   
    process(wclk, wrst_n)
    begin
        if wrst_n = '0' then
            wbin  <= (others => '0');
            wfull <= '0';
        elsif rising_edge(wclk) then
            wbin  <= wbin_next;
            wfull <= wfull_val;
        end if;
    end process;

	 
    -- Binary-to-Gray: combinational
    wgray <= std_logic_vector(wbin_next xor ('0' & wbin_next(ADDRSIZE downto 1)));

 
    -- Full when Gray wptr has lapped Gray rptr:
    --   top 2 bits differ, remaining bits equal
	 
    wfull_val <= '1' when (wgray =
                           (not wq2_rptr(ADDRSIZE) &
                            not wq2_rptr(ADDRSIZE-1) &
                            wq2_rptr(ADDRSIZE-2 downto 0)))
                 else '0';

  
    -- wrdy = NOT full  (the bubble/inverter shown on wrdy line)
    -- wptr = Gray-coded pointer to sync2 synchronizer
   
    wrdy <= not wfull;
    wptr <= wgray;

end architecture rtl;