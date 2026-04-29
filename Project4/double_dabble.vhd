library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package double_dabble is

	function to_bcd (
			data_value:	in std_logic_vector(15 downto 0)
		) return std_logic_vector;

end package double_dabble;

package body double_dabble is

	function to_bcd (
			data_value:	in std_logic_vector(15 downto 0)
		) return std_logic_vector
	is
		variable ret: std_logic_vector(19 downto 0);
		variable temp: std_logic_vector(data_value'range);
	begin
		temp := data_value;
		ret := (others => '0');
		for i in data_value'range loop
			for j in 0 to ret'length/4 - 1 loop
				if unsigned(ret(4*j + 3 downto 4*j)) >= 5 then
					ret(4*j + 3 downto 4*j) :=
							std_logic_vector(
								unsigned(ret(4*j + 3 downto 4 * j)) + 3);
				end if;
			end loop;
			ret := ret(ret'high -1 downto 0) & temp(temp'high);
			temp := temp(temp'high - 1 downto 0) & '0';
		end loop;
		return ret;
	end function to_bcd;

end package body double_dabble;