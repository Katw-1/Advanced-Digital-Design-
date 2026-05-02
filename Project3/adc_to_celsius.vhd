library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
-- Converts MAX10 internal temperature sensor ADC output to Celsius
-- Uses manufacturer lookup table (Table 4) for 0 to 40 degrees C
-- ADC codes: 3727 (0C) down to 3643 (40C)
-- Out of range values display as 0
-- Output is 8-bit unsigned (0 to 40)
 
entity adc_to_celsius is
    port (
        adc_in   : in  std_logic_vector(11 downto 0);  -- 12-bit ADC code
        temp_out : out std_logic_vector(15 downto 0)   -- celsius for seven_seg_driver
    );
end entity adc_to_celsius;
 
architecture rtl of adc_to_celsius is
    signal temp_int : unsigned(7 downto 0);
begin
 
    process(adc_in)
    begin
        case to_integer(unsigned(adc_in)) is
            -- From Table 4: Temp(C) -> ADC Code
            when 3727           => temp_int <= to_unsigned(0,  8);
            when 3725           => temp_int <= to_unsigned(1,  8);
            when 3721           => temp_int <= to_unsigned(2,  8);
            when 3720           => temp_int <= to_unsigned(3,  8);
            when 3719           => temp_int <= to_unsigned(4,  8);
            when 3717           => temp_int <= to_unsigned(5,  8);
            when 3715           => temp_int <= to_unsigned(6,  8);
            when 3713           => temp_int <= to_unsigned(7,  8);
            when 3711           => temp_int <= to_unsigned(8,  8);
            when 3709           => temp_int <= to_unsigned(9,  8);
            when 3707           => temp_int <= to_unsigned(10, 8);
            when 3704           => temp_int <= to_unsigned(11, 8);
            when 3703           => temp_int <= to_unsigned(12, 8);
            when 3702           => temp_int <= to_unsigned(13, 8);
            when 3700           => temp_int <= to_unsigned(14, 8);
            when 3699           => temp_int <= to_unsigned(15, 8);
            when 3698           => temp_int <= to_unsigned(16, 8);
            when 3697           => temp_int <= to_unsigned(17, 8);
            when 3696           => temp_int <= to_unsigned(18, 8);
            when 3695           => temp_int <= to_unsigned(19, 8);
            when 3688           => temp_int <= to_unsigned(20, 8);
            when 3684           => temp_int <= to_unsigned(21, 8);
            when 3682           => temp_int <= to_unsigned(22, 8);
            when 3680           => temp_int <= to_unsigned(23, 8);
            when 3678           => temp_int <= to_unsigned(24, 8);
            when 3667           => temp_int <= to_unsigned(29, 8);
            when 3666           => temp_int <= to_unsigned(30, 8);
            when 3664           => temp_int <= to_unsigned(31, 8);
            when 3662           => temp_int <= to_unsigned(32, 8);
            when 3660           => temp_int <= to_unsigned(33, 8);
            when 3658           => temp_int <= to_unsigned(34, 8);
            when 3656           => temp_int <= to_unsigned(35, 8);
            when 3654           => temp_int <= to_unsigned(36, 8);
            when 3651           => temp_int <= to_unsigned(37, 8);
            when 3648           => temp_int <= to_unsigned(38, 8);
            when 3645           => temp_int <= to_unsigned(39, 8);
            when 3643           => temp_int <= to_unsigned(40, 8);
            when others         => temp_int <= to_unsigned(0,  8);  -- out of range
        end case;
    end process;
 
    -- zero pad to 16-bit for seven_seg_driver
    temp_out <= "00000000" & std_logic_vector(temp_int);
 
end architecture rtl;