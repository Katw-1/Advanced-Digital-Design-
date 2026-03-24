library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

<<<<<<< HEAD
library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.color_data.all;
use work.pipeline_pkg.all;
use work.pointconversion.all;

entity toplevel is
	generic (
		vga_res:	vga_timing := vga_res_default;
		total_stages:	positive := 16;
		threshold:		ads_sfixed := to_ads_sfixed(4)
	);
	port (
		vga_clock: in std_logic;
		reset: in std_logic;
		mode:	 in std_logic;
=======
entity toplevel is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock: in std_logic;
		reset: in std_logic; 
>>>>>>> e8e74ca875c4b64f73c1ea1846a1f726eabdf51a
		
		h_sync: out std_logic;
		v_sync: out std_logic; 
		
<<<<<<< HEAD
		color: out rgb_color
=======
		color: out rbg_color
>>>>>>> e8e74ca875c4b64f73c1ea1846a1f726eabdf51a
	);
	
end entity toplevel;

architecture rtl of toplevel is

signal point:  coordinate;
<<<<<<< HEAD
signal corrected_point : coordinate;

signal point_valid:  boolean;
signal pixel_clock:  std_logic;

signal delayed_point : coordinate;
signal delayed_point_valid : boolean;

signal pipeline_input, pipeline_output: complex_pipeline_data;
signal delayed_pipeline_output: complex_pipeline_data;

begin
	corrected_point.x <= (delayed_point.x - total_stages) when delayed_point.x > total_stages else 0;
	corrected_point.y <= delayed_point.y;

	color <= color_comprimise when delayed_pipeline_output.stage_valid 
		and delayed_point_valid 
		and not delayed_pipeline_output.stage_overflow
	else color_black;
	
	--delayed_pipeline_output.stage_valid 
	-- and delayed_point_valid
	-- --and not delayed_pipeline_output.stage_overflow

	video_gen: entity vga.vga_fsm
=======
signal point_valid:  boolean;
signal pixel_clock:  std_logic;
signal pll_locked:  std_logic;

begin
	color <= color_blue when point_valid else color_black;
	vga: vga_fsm
>>>>>>> e8e74ca875c4b64f73c1ea1846a1f726eabdf51a
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
<<<<<<< HEAD
=======
		
>>>>>>> e8e74ca875c4b64f73c1ea1846a1f726eabdf51a
	
	pll: entity work.vga_pll
		port map(
			inclk0 => vga_clock,
			c0	=> pixel_clock,
<<<<<<< HEAD
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
		
	shift_output: entity work.complex_shift_register
		generic map(
			depth => total_stages	
		)
		port map(
			clock => pixel_clock,
			reset => reset,
			data_in => pipeline_output,
			data_out => delayed_pipeline_output
		);
		
	shift_point_x: entity work.natural_shift_register
		generic map(
			depth => total_stages
		)
		port map(
			clock => pixel_clock, 
			reset => reset,
         data_in => point.x, 
			data_out => delayed_point.x
		);
		
	shift_point_y: entity work.natural_shift_register
		generic map(
			depth => total_stages
		)
		port map(
			clock => pixel_clock, 
			reset => reset,
         data_in => point.y, 
			data_out => delayed_point.y
		);
		
	
	shift_point_valid: entity work.boolean_shift_register
		generic map(
			depth => total_stages
		)
		port map(
			clock => pixel_clock, 
			reset => reset,
         data_in => point_valid, 
			data_out => delayed_point_valid
		);
		
	
	
	feed_the_pipeline: process(pixel_clock) is
	begin
		if rising_edge(pixel_clock) then
			if mode = '1' then
				pipeline_input.z <= complex_zero;
				pipeline_input.c <= map_coordinate_to_complex(corrected_point, vga_res, '1');
			else
				pipeline_input.z <= map_coordinate_to_complex(corrected_point, vga_res, '0');
				pipeline_input.c <= ads_cmplx(to_ads_sfixed(-1.0), to_ads_sfixed(0.25));
			end if;
			pipeline_input.stage_data <= 0;
			pipeline_input.stage_overflow <= false;
			pipeline_input.stage_valid <= delayed_point_valid;
		end if;
	end process feed_the_pipeline;
=======
			locked => pll_locked
		);

>>>>>>> e8e74ca875c4b64f73c1ea1846a1f726eabdf51a
 	
end architecture rtl;