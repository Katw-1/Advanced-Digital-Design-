library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.color_data.all;
use work.pipeline_pkg.all;
use work.pointconversion.all;

entity toplevel is
	generic (
		vga_res:	vga_timing := vga_res_default;
		total_stages:	positive := 4;
		threshold:		ads_sfixed := to_ads_sfixed(4)
	);
	port (
		vga_clock: in std_logic;
		reset: in std_logic;
		mode:	 in std_logic;
		
		h_sync: out std_logic;
		v_sync: out std_logic; 
		
		color: out rgb_color
	);
	
end entity toplevel;

architecture rtl of toplevel is

signal point:  coordinate;

signal point_valid:  boolean;
signal pixel_clock:  std_logic;

signal pipeline_input, pipeline_output: complex_pipeline_data;

signal h_sync_sreg, v_sync_sreg: std_logic_vector(0 to total_stages);
signal vga_h_sync, vga_v_sync: std_logic;

signal seed_value: ads_complex;

begin

	color <= color_compromise when pipeline_output.stage_valid 
		and point_valid 
		and not pipeline_output.stage_overflow
	else color_black;
	
	
	sync_sregs: process(pixel_clock) is
	begin
		if rising_edge(pixel_clock) then
			h_sync_sreg <= vga_h_sync & h_sync_sreg(0 to h_sync_sreg'high - 1);
			v_sync_sreg <= vga_v_sync & v_sync_sreg(0 to v_sync_sreg'high - 1);
		end if;
	end process sync_sregs;
	
	h_sync <= h_sync_sreg(h_sync_sreg'high);
	v_sync <= v_sync_sreg(v_sync_sreg'high);
	
	video_gen: entity vga.vga_fsm
		generic map(
			vga_res => vga_res
		)
		port map(
			vga_clock => pixel_clock,
			reset => reset,
			h_sync => vga_h_sync,
			v_sync => vga_v_sync,
			
			point => point ,
			point_valid => point_valid
		);
	
	pll: entity work.vga_pll
		port map(
			inclk0 => vga_clock,
			c0	=> pixel_clock,
			locked => open
		);

	pipeline: entity work.mandelbrot_pipeline
		generic map (
			total_stages =>	total_stages,
			threshold =>		threshold
		)
		port map (
			clock => pixel_clock,
			reset =>	reset,
			pipeline_input =>	pipeline_input,
			pipeline_output =>	pipeline_output
		);
		
	
		
	seed_value <= map_coordinate_to_complex(point, vga_res, mode);
	
	feed_the_pipeline: process(pixel_clock) is
	begin
		if rising_edge(pixel_clock) then
			if mode = '1' then
				pipeline_input.z <= complex_zero;
				pipeline_input.c <= seed_value;
			else
				pipeline_input.z <= seed_value;
				pipeline_input.c <= ads_cmplx(to_ads_sfixed(-1.0), to_ads_sfixed(0.25));
			end if;
			pipeline_input.stage_data <= 0;
			pipeline_input.stage_overflow <= false;
			pipeline_input.stage_valid <= point_valid;
		end if;
	end process feed_the_pipeline;
 	
end architecture rtl;