library ieee;
use ieee.std_logic_1164.all;
use work.pipeline_pkg.all;

entity complex_shift_register is
    generic(
        depth : natural := 4
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_in   : in  complex_pipeline_data;
        data_out  : out complex_pipeline_data
    );
end entity complex_shift_register;



architecture rtl of complex_shift_register is

    type shift_array is array (0 to depth-1) of complex_pipeline_data;
    signal reg : shift_array;

begin

process(clock, reset)
begin
    if reset = '0' then
        for i in 0 to depth-1 loop
            reg(i).z.re <= (others => '0');
            reg(i).z.im <= (others => '0');
            reg(i).c.re <= (others => '0');
            reg(i).c.im <= (others => '0');
            reg(i).stage_data <= 0;
            reg(i).stage_overflow <= false;
            reg(i).stage_valid <= false;
        end loop;

    elsif rising_edge(clock) then
        for i in depth-1 downto 1 loop
            reg(i) <= reg(i-1);
        end loop;
        reg(0) <= data_in;
    end if;
end process;

data_out <= reg(depth-1);

end architecture rtl;
