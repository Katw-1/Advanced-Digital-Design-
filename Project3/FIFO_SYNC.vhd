library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_SYNC is
	generic(
		DATA_WIDTH : natural := 8;
		ADDRSIZE : natural := 6
	);
	
	port(
		-- From Write side
		 wclk     : in  std_logic;
       wrst_n   : in  std_logic;
       wput     : in  std_logic;                             
       wdata    : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
		 wrdy     : out std_logic;
	
	
		-- From Read Side
		 rclk     : in  std_logic;
       rrst_n   : in  std_logic;
       rget     : in  std_logic;                             
       rdata    : out  std_logic_vector(DATA_WIDTH-1 downto 0); 
		 rrdy     : out std_logic
	);
end entity FIFO_SYNC;

architecture rtl of FIFO_SYNC is
	signal wptr  : std_logic_vector(ADDRSIZE downto 0);
	signal rptr	 : std_logic_vector(ADDRSIZE downto 0);
	
	signal wq2_rptr: std_logic_vector(ADDRSIZE downto 0);
	signal rq2_wptr: std_logic_vector(ADDRSIZE downto 0);
	
	signal we	 : std_logic;
	signal re	 : std_logic;
	

begin
	
	wctl_block: entity work.wctl
		generic map(
			ADDRSIZE => ADDRSIZE
		)
		port map(
			wclk 		=> wclk,
			wrst_n 	=> wrst_n,
			wput		=> wput,
			wq2_rptr => wq2_rptr,
			wptr		=> wptr,
			we 		=> we, 
			wrdy 		=> wrdy
		);
		
		
		
		
	  rctl_block : entity work.rctl
        generic map(
			  ADDRSIZE => ADDRSIZE
			)
        port map(
            rclk     => rclk,
            rrst_n   => rrst_n,
            rget     => rget,
            rq2_wptr => rq2_wptr,
            rptr     => rptr,
            re       => re,
            rrdy     => rrdy
        );
		  
		  
		  
		  
		  sync_rptr_block : entity work.gray_sync
        generic map(
			  WIDTH => ADDRSIZE + 1
		  )
        port map(
            clk_b    => wclk,
            reset_b  => wrst_n,
            gray_in  => rptr,
            gray_out => wq2_rptr
        );
		  
		  
		  
		 sync_wptr_block : entity work.gray_sync
        generic map(
			  WIDTH => ADDRSIZE + 1
		  )
        port map(
            clk_b    => rclk,
            reset_b  => rrst_n,
            gray_in  => wptr,
            gray_out => rq2_wptr
        );
		  
		  
		  
		  fifo_ram : entity work.simple_dual_port_ram_dual_clock
        generic map(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDRSIZE
        )
        port map(
            wclk  => wclk,
            rclk  => rclk,
            we    => we,
            waddr => to_integer(unsigned(wptr(ADDRSIZE-1 downto 0))),
            raddr => to_integer(unsigned(rptr(ADDRSIZE-1 downto 0))),
            data  => wdata,
            q     => rdata
        );

end architecture rtl;  
		  
		  