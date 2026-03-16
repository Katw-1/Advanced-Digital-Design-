library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.complex_pkg.all 

type pipeline_data is record
    z                : ads_complex;
    c                : ads_complex;
    stage_data       : natural;    
    stage_overflow   : boolean;
    stage_valid      : boolean;
end record;

entity pipeline_stage is
    generic(
        threshold : ads_complex_mag
    );
    port(
        clock  : in std_logic;
        input  : in pipeline_data;
        output : out pipeline_data;
    );
end pipeline_stage;

architecture rtl of pipeline_stage is
begin
process(clock)
    variable z_next : ads_complex;
    variable mag2   : ads_complex_mag; 
begin
    if rising_edge(clock) then 
        if input.stage_valid then  
            if input.stage_overflow then        
                output <= input; 
            else 
                z_next := complex_add(
                    complex_mult(input.z, input.z),
                    input.c
                    );
                    mag2 := complex_mag2(z_next);
                    output.z <= z_next; 
                    output.c <= input.c;

                    if mag2 > threshold then 
                        output.stage_overflow <= true;
                        output.stage_data <= input.stage_data;
                    else
                        output.stage_overflow <= false; 
                        output.stage_data <= input.stage_data + 1;
                    end if; 
                    output.stage_valid <= true;
                end if; 
            else  
                output.stage_valid <= false; 
        end if; 
    end process; 
end rtl; 

            
