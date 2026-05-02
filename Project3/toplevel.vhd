library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;

entity toplevel is
    port (
        board_clk : in  std_logic;                      -- 50MHz board oscillator
		  small_clk : in	std_logic;							  -- 10MHz clock
		  reset     : in  std_logic;
        HEX0      : out std_logic_vector(6 downto 0);   -- lamps(6 downto 0)
        HEX1      : out std_logic_vector(6 downto 0);   -- lamps(13 downto 7)
        HEX2      : out std_logic_vector(6 downto 0);   -- lamps(20 downto 14)
        HEX3      : out std_logic_vector(6 downto 0)    -- lamps(27 downto 21)
    );
end entity toplevel;
 
architecture rtl of toplevel is

	 signal reset_n : std_logic;
 
    -- PLL signals
    signal analog_in : std_logic;                       -- 10MHz to ADC
 
    -- ADC signals
    signal soc          : std_logic;
    signal eoc          : std_logic;
    signal dout_natural : natural range 0 to 2**12 - 1;
    signal dout         : std_logic_vector(11 downto 0);
    signal clk_dft      : std_logic;
 
    -- Write FSM signals
    signal head_ptr_raw : std_logic_vector(3 downto 0); -- raw head ptr from adc_fsm
    signal we_a         : std_logic;
 
    -- Gray sync signals (head_ptr crosses write -> read domain)
    signal gray_code    : std_logic_vector(3 downto 0); -- gray encoded head_ptr
    signal post_sync    : std_logic_vector(3 downto 0); -- synced gray code
    signal head_ptr_syn : std_logic_vector(3 downto 0); -- decoded head_ptr in read domain
 
    -- FIFO_SYNC signals (tail_ptr crosses read -> write domain)
    signal tail_ptr         : std_logic_vector(3 downto 0);
    signal synced_tail_ptr  : std_logic_vector(3 downto 0);
 
    -- RAM signals
    signal q_b : std_logic_vector(11 downto 0);         -- RAM port B output
 
    -- 7-seg driver signals
    signal lamps : std_logic_vector(27 downto 0);
	 
	 -- Celsius Conversion Signals
	 signal temp_celsius : std_logic_vector(15 downto 0);


 
begin
 
    -- convert ADC natural output to std_logic_vector
    dout <= std_logic_vector(to_unsigned(dout_natural, 12));
	 
	 
	 reset_n <= not reset;
 

    -- PLL (generates 10MHz for ADC)
    pll_inst : entity work.seven_segment_display_pll
        port map(
            inclk0 => small_clk,
            c0     => analog_in,
            locked => open
        );
 
    -- MAX10 ADC
    adc_inst : entity work.max10_adc
        port map(
            pll_clk  => analog_in,
            chsel    => 0,
            soc      => '1', --soc,
            tsen     => '1',
            dout     => dout_natural,
            eoc      => eoc,
            clk_dft  => clk_dft
        );
 

    -- Write FSM (1MHz domain via clk_dft)
      write_fsm : entity work.adc_fsm
          port map(
              clk             => small_clk,
              reset           => reset_n,
              eoc             => '1',  --eoc,
              dout            => dout,
              synced_tail_ptr => synced_tail_ptr,
              soc             => soc,
              ram_we          => we_a,
              ram_addr        => head_ptr_raw,
              ram_din         => dout
     );
	  
 
    -- Bin to Gray (head_ptr crosses write -> read domain)
   bin_to_gray_inst : entity work.bin_to_gray
    generic map(
        input_width => 4        
    )
    port map(
        bin_in   => head_ptr_raw,
        gray_out => gray_code
    );

    -- Gray Sync (captures gray head_ptr into 50MHz domain)
    gray_sync_inst : entity work.gray_sync
    generic map(
        WIDTH => 4              -- match pointer width
    )
    port map(
        clk_b    => board_clk,
        reset_b  => reset_n,
        gray_in  => gray_code,
        gray_out => post_sync
    );

    -- Gray to Bin (recover head_ptr in read domain)
    gray_to_bin_inst : entity work.gray_to_bin
    generic map(
        input_width => 4        
    )
    port map(
        gray_in => post_sync,
        bin_out => head_ptr_syn
    );

    -- Read FSM (50MHz domain)
    read_fsm : entity work.consumer_fsm
        port map(
            clk      => board_clk,
            reset    => reset_n,
            head_ptr => head_ptr_syn,
            tail_ptr => tail_ptr
        );
 

    -- FIFO_SYNC (tail_ptr crosses read -> write domain)
    fifo_sync_inst : entity work.FIFO_SYNC
        generic map(
            DATA_WIDTH => 4,
            ADDRSIZE => 2
        )
        port map(
            wclk   => board_clk,
            wrst_n => '1',
            wput   => '1',
            wdata  => tail_ptr,
            wrdy   => open,
            rclk   => clk_dft,
            rrst_n => '1',
            rget   => '1',
            rdata  => synced_tail_ptr,
            rrdy   => open
        );
 

    -- Dual Port RAM
    ram_inst : entity work.true_dual_port_ram_dual_clock
		 generic map(
			  DATA_WIDTH => 12,
			  ADDR_WIDTH => 4
		 )
		 port map(
			  clk_a  => small_clk,
			  clk_b  => board_clk,
			  addr_a => to_integer(unsigned(head_ptr_raw)),  -- convert slv to natural
			  addr_b => to_integer(unsigned(tail_ptr)),       -- convert slv to natural
			  data_a => dout,
			  data_b => (others => '0'),
			  we_a   => we_a,
			  we_b   => '0',
			  q_a    => open,
			  q_b    => q_b
		 );
	 
	 --Celsius Converter
	 celsius_conv : entity work.adc_to_celsius
		  port map(
				adc_in => q_b,
				temp_out => temp_celsius
		  );

    -- 7-Segment Driver
    decoder_inst : entity work.seven_seg_driver
        port map(
            data_in    => temp_celsius, --"0000" & q_b,
            decimal_en => '1',
            lamps      => lamps
        );
 
    -- map lamps to HEX outputs
    HEX0 <= lamps(6 downto 0);
    HEX1 <= lamps(13 downto 7);
    HEX2 <= lamps(20 downto 14);
    HEX3 <= lamps(27 downto 21);
 
end architecture rtl;
		