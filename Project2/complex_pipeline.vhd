library ieee;
library ads;

use ieee.std_logic_1164.all;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;
use work.pipeline_pkg.all;

entity complex_pipeline is
	generic(
		 threshold : ads_sfixed;
		 stage_number : natural
	);
	port(
		 clock : in std_logic;
		 reset : in std_logic;
		 stage_input  : in complex_pipeline_data;
		 stage_output : out complex_pipeline_data
	);
end entity complex_pipeline;

architecture rtl of complex_pipeline is

	-- Stage 1 registers
	signal a2_s1, b2_s1, ab_s1 : ads_sfixed;
	signal c_s1 : ads_complex;
	signal data_s1 : natural;
	signal overflow_s1 : boolean;
	signal valid_s1 : boolean;

	-- Stage 2 registers
	signal real_s2, imag_s2 : ads_sfixed;
	signal mag_s2 : ads_sfixed;
	signal c_s2 : ads_complex;
	signal data_s2 : natural;
	signal overflow_s2 : boolean;
	signal valid_s2 : boolean;

begin

	stage : process(clock, reset)
	begin

		if reset = '0' then

			 -- Reset complex value
			 stage_output.z.re <= 0;
			 stage_output.z.im <= 0;
			 
			 -- Reset seed
			 stage_output.c.re <= 0;
			 stage_output.c.im <= 0;
			 
			 -- Reset metadata
			 stage_output.stage_data <= 0;
			 stage_output.stage_overflow <= false;
			 stage_output.stage_valid <= false;
			 

		elsif rising_edge(clock) then


				-- PIPELINE STAGE 1 (Multiplications)

			 a2_s1 <= stage_input.z.re * stage_input.z.re;
			 b2_s1 <= stage_input.z.im * stage_input.z.im;
			 ab_s1 <= stage_input.z.re * stage_input.z.im;

			 c_s1 <= stage_input.c;
			 data_s1 <= stage_input.stage_data;
			 overflow_s1 <= stage_input.stage_overflow;
			 valid_s1 <= stage_input.stage_valid;

				-- PIPELINE STAGE 2 (Additions)

			 real_s2 <= (a2_s1 - b2_s1) + c_s1.re;
			 imag_s2 <= (ab_s1 + ab_s1) + c_s1.im;

			 mag_s2 <= a2_s1 + b2_s1;

			 c_s2 <= c_s1;
			 data_s2 <= data_s1;
			 overflow_s2 <= overflow_s1;
			 valid_s2 <= valid_s1;

				-- PIPELINE STAGE 3 (Comparison)
				
			 stage_output.z.re <= real_s2;
			 stage_output.z.im <= imag_s2;

			 stage_output.c <= c_s2;

			 if overflow_s2 then
				  stage_output.stage_data <= data_s2;
			 else
				  stage_output.stage_data <= stage_number;
			 end if;

			 if overflow_s2 then
				  stage_output.stage_overflow <= overflow_s2;
			 else
				  stage_output.stage_overflow <= (mag_s2 > threshold);
			 end if;

			 stage_output.stage_valid <= valid_s2;

		end if;

	end process stage;

end architecture rtl;