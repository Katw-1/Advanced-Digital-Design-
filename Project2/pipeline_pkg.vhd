library ieee;
use ieee.std_logic_1164.all;

package pipeline_pkg is

type complex_pipeline_data is record
    z : ads_complex;
    c : ads_complex;
	 stage_data: natural;
    stage_overflow: boolean;
	 stage_valid : boolean;
end record complex_pipeline_data;

end package pipeline_pkg;

package body pipeline_pkg is
end package body pipeline_pkg;