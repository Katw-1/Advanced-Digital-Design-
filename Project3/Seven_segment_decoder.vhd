library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
    port (
        data_in     : in  std_logic_vector(15 downto 0); -- input number
        decimal_en  : in  std_logic;                    -- 1 = decimal, 0 = hex
        lamps       : out std_logic_vector(27 downto 0) -- 4 digits × 7 segments
    );
end entity;

architecture rtl of seven_seg_driver is

    -- BCD output
    signal bcd_data : std_logic_vector(19 downto 0);

    -- individual digits
    signal digit0, digit1, digit2, digit3 : std_logic_vector(3 downto 0);

    -- BCD conversion (Double Dabble)
    function to_bcd (
        data_value : in std_logic_vector(15 downto 0)
    ) return std_logic_vector is
        variable ret  : std_logic_vector(19 downto 0);
        variable temp : std_logic_vector(15 downto 0);
    begin
        temp := data_value;
        ret  := (others => '0');

        for i in 0 to 15 loop
            -- add 3 if >=5
            for j in 0 to 4 loop
                if unsigned(ret(4*j+3 downto 4*j)) >= 5 then
                    ret(4*j+3 downto 4*j) :=
                        std_logic_vector(unsigned(ret(4*j+3 downto 4*j)) + 3);
                end if;
            end loop;

            -- shift left
            ret  := ret(18 downto 0) & temp(15);
            temp := temp(14 downto 0) & '0';
        end loop;

        return ret;
    end function;
	 
    -- 7-segment decoder (common anode)
    function seven_seg_decode(
        digit : std_logic_vector(3 downto 0)
    ) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case digit is
            when "0000" => seg := "1000000"; -- 0
            when "0001" => seg := "1111001"; -- 1
            when "0010" => seg := "0100100"; -- 2
            when "0011" => seg := "0110000"; -- 3
            when "0100" => seg := "0011001"; -- 4
            when "0101" => seg := "0010010"; -- 5
            when "0110" => seg := "0000010"; -- 6
            when "0111" => seg := "1111000"; -- 7
            when "1000" => seg := "0000000"; -- 8
            when "1001" => seg := "0010000"; -- 9
            when "1010" => seg := "0001000"; -- A
            when "1011" => seg := "0000011"; -- b
            when "1100" => seg := "1000110"; -- C
            when "1101" => seg := "0100001"; -- d
            when "1110" => seg := "0000110"; -- E
            when "1111" => seg := "0001110"; -- F
            when others => seg := "1111111"; -- OFF
        end case;
        return seg;
    end function;

begin

    -- Mode selection (Decimal vs Hex)
    process(data_in, decimal_en)
    begin
        if decimal_en = '1' then
            -- Decimal mode
            bcd_data <= to_bcd(data_in);

            digit0 <= bcd_data(3 downto 0);
            digit1 <= bcd_data(7 downto 4);
            digit2 <= bcd_data(11 downto 8);
            digit3 <= bcd_data(15 downto 12);

        else
            -- Hex mode
            digit0 <= data_in(3 downto 0);
            digit1 <= data_in(7 downto 4);
            digit2 <= data_in(11 downto 8);
            digit3 <= data_in(15 downto 12);
        end if;
    end process;
	 
    -- Output mapping
    lamps(6 downto 0)     <= seven_seg_decode(digit0);
    lamps(13 downto 7)    <= seven_seg_decode(digit1);
    lamps(20 downto 14)   <= seven_seg_decode(digit2);
    lamps(27 downto 21)   <= seven_seg_decode(digit3);

end architecture;