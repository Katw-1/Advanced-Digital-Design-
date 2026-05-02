library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_complex_pkg.all;

package pipeline_pkg is

type complex_pipeline_data is record
    z : ads_complex;
    c : ads_complex;
	 stage_data: natural;
    stage_overflow: boolean;
	 stage_valid : boolean;
end record complex_pipeline_data;


component complex_shift_register is
    generic(
        depth : natural := 16
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_in   : in  complex_pipeline_data;
        data_out  : out complex_pipeline_data
    );
end component complex_shift_register;


component natural_shift_register is
    generic(
        depth : natural := 16
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_in   : in  natural;
        data_out  : out natural
    );
end component natural_shift_register;


component boolean_shift_register is
    generic(
        depth : natural := 16
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_in   : in  boolean;
        data_out  : out boolean
    );
end component boolean_shift_register;


end package pipeline_pkg;

package body pipeline_pkg is
end package body pipeline_pkg;