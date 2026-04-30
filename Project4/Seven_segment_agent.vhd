library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.seven_segment_pkg.all; 

entity seven_segment_agent is
    generic (
        lamp_mode_common_anode : boolean := true;
        decimal_support        : boolean := true;
        signed_support         : boolean := false;
        blank_zeros_support    : boolean := false;
        implementer            : natural range 1 to 255 := 77;
        revision               : natural range 0 to 255 := 1;
        num_digits             : positive := 6
    );
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;

        address   : in  std_logic_vector(1 downto 0);
        read      : in  std_logic;
        write     : in  std_logic;
        writedata : in  std_logic_vector(31 downto 0);
        readdata  : out std_logic_vector(31 downto 0);

        lamps     : out std_logic_vector(7 * num_digits - 1 downto 0)
    );
end entity;

architecture rtl of seven_segment_agent is
	function lamp_mode
		return lamp_configuration
	is
	begin
		if lamp_mode_common_anode then
			return common_anode;
		end if;
		return common_cathode;
	end function lamp_mode;

    signal data    : std_logic_vector(31 downto 0);
    signal control : std_logic_vector(31 downto 0);
    signal features_reg : std_logic_vector(31 downto 0);

    -- digits
    type digit_array is array (0 to 5) of std_logic_vector(3 downto 0);
    signal digits : digit_array;

    signal lamps_internal : std_logic_vector(41 downto 0);

    -- BCD conversion
    
    function to_bcd(data_value : std_logic_vector(15 downto 0))
    return std_logic_vector is
        variable ret  : std_logic_vector(19 downto 0) := (others => '0');
        variable temp : std_logic_vector(15 downto 0) := data_value;
    begin
        for i in 0 to 15 loop
            for j in 0 to 4 loop
                if unsigned(ret(4*j+3 downto 4*j)) >= 5 then
                    ret(4*j+3 downto 4*j) :=
                        std_logic_vector(unsigned(ret(4*j+3 downto 4*j)) + 3);
                end if;
            end loop;
            ret  := ret(18 downto 0) & temp(15);
            temp := temp(14 downto 0) & '0';
        end loop;
        return ret;
    end function;

begin

    -- FEATURES REGISTER
    
    features_reg(31 downto 24) <= std_logic_vector(to_unsigned(implementer, 8));
    features_reg(23 downto 16) <= std_logic_vector(to_unsigned(revision, 8));
    features_reg(15 downto 8)  <= std_logic_vector(to_unsigned(num_digits, 8));

    features_reg(7 downto 4) <= (others => '0');

    features_reg(3) <= '1' when lamp_mode_common_anode else '0';
    features_reg(2) <= '1' when blank_zeros_support else '0';
    features_reg(1) <= '1' when signed_support else '0';
    features_reg(0) <= '1' when decimal_support else '0';

    -- BUS LOGIC
    
    process(clk)
    begin
        if rising_edge(clk) then

            if reset_n = '0' then
                data      <= (others => '0');
                control   <= (others => '0');
                readdata  <= (others => '0');

            else

                -- WRITE
                if write = '1' then
                    case address is
                        when "00" => data <= writedata;

                        when "01" =>
                            control(0) <= writedata(0);

                            if decimal_support then
                                control(1) <= writedata(1);
                            end if;

                            if blank_zeros_support then
                                control(2) <= writedata(2);
                            end if;

                            if signed_support then
                                control(3) <= writedata(3);
                            end if;

                        when others => null;
                    end case;
                end if;

                -- READ
                if read = '1' then
                    case address is
                        when "00" => readdata <= data;
                        when "01" => readdata <= control;
                        when "10" => readdata <= features_reg;
                        when "11" => readdata <= x"F6A5A5AC";
                        when others => readdata <= (others => '0');
                    end case;
                end if;

            end if;
        end if;
    end process;

    --- DATA PROCESSING
    process(data, control)
		function flatten (
				d: in seven_segment_config
			) return std_logic_vector
		is
		begin
			return d.g & d.f & d.e & d.d & d.c & d.b & d.a;
		end function flatten;
        variable temp_signed : signed(15 downto 0);
        variable temp_abs    : unsigned(15 downto 0);
        variable bcd         : std_logic_vector(19 downto 0);
        variable blank       : boolean := false;
    begin

        -- signed handling
        if (control(1) = '1' and control(3) = '1' and signed_support) then
            temp_signed := signed(data(15 downto 0));

            if temp_signed < 0 then
                temp_abs := unsigned(-temp_signed);
            else
                temp_abs := unsigned(temp_signed);
            end if;
        else
            temp_abs := unsigned(data(15 downto 0));
        end if;

        -- decimal vs hex
        if (control(1) = '1') then
            bcd := to_bcd(std_logic_vector(temp_abs));

            digits(0) <= bcd(3 downto 0);
            digits(1) <= bcd(7 downto 4);
            digits(2) <= bcd(11 downto 8);
            digits(3) <= bcd(15 downto 12);
            digits(4) <= bcd(19 downto 16);
            digits(5) <= "0000";

        else
            digits(0) <= data(3 downto 0);
            digits(1) <= data(7 downto 4);
            digits(2) <= data(11 downto 8);
            digits(3) <= data(15 downto 12);
            digits(4) <= "0000";
            digits(5) <= "0000";
        end if;

        -- leading zero blanking
        blank := true;
        for i in 5 downto 0 loop
            if digits(i) /= "0000" then
                blank := false;
            end if;

			if control(0) = '0' then
				lamps_internal(7*i + 6 downto 7*i) <= flatten(lamps_off(lamp_mode));
            elsif blank and blank_zeros_support and control(2) = '1' then
                lamps_internal(7*i+6 downto 7*i) <= flatten(lamps_off(lamp_mode));
            else
                lamps_internal(7*i+6 downto 7*i) <= flatten(get_hex_digit(to_integer(unsigned(digits(i))), lamp_mode));
            end if;
        end loop;

    end process;

    -- OUTPUT
    lamps <= lamps_internal(7 * num_digits - 1 downto 0);

end architecture;
