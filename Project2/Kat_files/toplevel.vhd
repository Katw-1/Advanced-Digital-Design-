library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity toplevel is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock: in std_logic;
		reset: in std_logic; 
		
		h_sync: out std_logic;
		v_sync: out std_logic; 
		
		color: out rbg_color
	);
	
end entity toplevel;

architecture rtl of toplevel is

signal point:  coordinate;
signal point_valid:  boolean;
signal pixel_clock:  std_logic;
signal pll_locked:  std_logic;

begin
	color <= color_blue when point_valid else color_black;
	vga: vga_fsm
		generic map(
			vga_res => vga_res
		)
		port map(
			vga_clock => pixel_clock,
			reset => reset,
			h_sync => h_sync,
			v_sync => v_sync,
			
			point => point ,
			point_valid => point_valid
		);
		
	
	pll: entity work.vga_pll
		port map(
			inclk0 => vga_clock,
			c0	=> pixel_clock,
			locked => pll_locked
		);

 	
end architecture rtl;