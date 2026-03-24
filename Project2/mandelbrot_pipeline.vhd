library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.pipeline_pkg.all;

entity mandelbrot_pipeline is
    generic(
        total_stages : natural := 64;
        threshold    : ads_sfixed
    );
    port(
        clock  : in std_logic;
        reset  : in std_logic;

        pipeline_input  : in  complex_pipeline_data;
        pipeline_output : out complex_pipeline_data
    );
end entity mandelbrot_pipeline;


architecture rtl of mandelbrot_pipeline is

-- Pipeline storage between stages

	type pipeline_array is array (natural range <>) of complex_pipeline_data;

	signal stage_data : pipeline_array(0 to total_stages);

begin


-- First stage input

stage_data(0) <= pipeline_input;

-- Generate pipeline

pipeline: for i in 0 to total_stages - 1 generate
begin

    stage: entity work.complex_pipeline
        generic map (
            threshold     => threshold,
            stage_number  => i
        )
        port map (
            clock        => clock,
            reset        => reset,

            stage_input  => stage_data(i),
            stage_output => stage_data(i+1)
        );
		  
end generate pipeline;

-- Final pipeline output

pipeline_output <= stage_data(total_stages);


end architecture rtl;