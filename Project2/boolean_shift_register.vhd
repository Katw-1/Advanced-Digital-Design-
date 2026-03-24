library ieee;
use ieee.std_logic_1164.all;
use work.pipeline_pkg.all;

entity boolean_shift_register is
    generic(
        depth : natural := 16
    );
    port(
        clock : in std_logic;
        reset : in std_logic;
        data_in   : in  boolean;
        data_out  : out boolean
    );
end entity boolean_shift_register;



architecture rtl of boolean_shift_register is
    type bool_array is array (0 to depth-1) of boolean;
    signal reg : bool_array;
begin
    process(clock, reset)
    begin
        if reset = '0' then
            for i in 0 to depth-1 loop
                reg(i) <= false;
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