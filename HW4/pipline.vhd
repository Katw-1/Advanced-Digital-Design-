library ieee;
use ieee.std_logic_1164.all;
use work.complex_pkg.all;

type pipeline_data is record
    z : ads_complex; 
    c : ads_complex; 
    stage_data : natural; 
    stage_overflow : boolean; 
    stage_valid : boolean; 
end record; 

entity pipline_stage is 
    generic (
         threshold : ads_sfixed;
         stage_num : natural
    );
    port(
        clock        : in std_logic;
        reset        : in std_logic;
        stage_input  : in pipeline_data;
        stage_output : out pipeline_data;
    );
end entity pipline_stage; 

architecture rtl of pipeline_stage is
-- add any signals you may need
signal x2, y2, xy, : ads_sfixed;
signal magnitude : ads_sfixed
signal newReal, new_imag : ads_sfixed;

begin
-- perform computations and complete assignments
    x2 <= stage_input.z.real * stage_input.z.real;
    y2 <= stage_input.z.imag * stage_input.z.imag; 
    xy <= stage_input.z.real * stage_input.z.imag; 
    newReal <= x2 - y2 + stage_input.c.real;
    new_imag <= (xy + xy) + stage_input.c.imag;
    magnitude <= x2 + y2;
-- ...
    stage: process(clock, reset) is
    begin
        if reset = '0' then
         -- reset pipeline stage
            stage_output.stage_data <= 0;
            stage_output.stage_overflow <= false; 
            stage_output.stage_valid <= false;

        elsif rising_edge(clock) then
            stage_output.stage_valid <= stage_input.stage_valid; 
            if stage_input.stage_overflow = true then
                stage_output.stage_data <= stage_input.stage_data;
            else
                stage_output.stage_data <= stage_num; 
            end if;
            stage_output.c <= stage_input.c 
            stage_output.z <= stage_input.z
            if stage_output.stage_overflow = true then
                stage_output.stage_overflow <= true;
            else
                stage_output.stage_overflow <= (magnitude > threshold);
            end if;
        end if;
    end process stage;
end architecture rtl;