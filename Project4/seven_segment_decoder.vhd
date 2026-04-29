library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_decoder is
    generic (
        lamp_mode_common_anode : boolean := true;
        decimal_support        : boolean := true;
        implementer            : natural range 1 to 255 := 1;
        revision               : natural range 0 to 255 := 1;
        num_digits             : positive := 6
    );
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;

        address   : in  std_logic_vector(1 downto 0);
        read      : in  std_logic;
        readdata  : out std_logic_vector(31 downto 0);

        write     : in  std_logic;
        writedata : in  std_logic_vector(31 downto 0);

        lamps     : out std_logic_vector((num_digits * 7) - 1 downto 0)
    );
end entity;

architecture rtl of seven_segment_decoder is

    signal data_reg     : std_logic_vector(31 downto 0) := (others => '0');
    signal control_reg  : std_logic_vector(31 downto 0) := (others => '0');
    signal features_reg : std_logic_vector(31 downto 0);
    constant magic_reg  : std_logic_vector(31 downto 0) :=
                          std_logic_vector(to_unsigned(4144533516, 32));

    signal display_value : std_logic_vector((num_digits * 4) - 1 downto 0);


    function to_bcd (
        data_value : in std_logic_vector(15 downto 0)
    ) return std_logic_vector is

        variable ret  : std_logic_vector(19 downto 0);
        variable temp : std_logic_vector(data_value'range);

    begin
        temp := data_value;
        ret  := (others => '0');

        for i in data_value'range loop
            for j in 0 to ret'length/4 - 1 loop
                if unsigned(ret(4*j + 3 downto 4*j)) >= 5 then
                    ret(4*j + 3 downto 4*j) :=
                        std_logic_vector(
                            unsigned(ret(4*j + 3 downto 4*j)) + 3
                        );
                end if;
            end loop;

            ret  := ret(ret'high - 1 downto 0) & temp(temp'high);
            temp := temp(temp'high - 1 downto 0) & '0';

        end loop;

        return ret;
    end function;


    function seven_seg (
        hex : std_logic_vector(3 downto 0)
    ) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case hex is
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
            when others => seg := "0001110"; -- F
        end case;

        return seg;
    end function;

begin

    process(all)
    begin
        features_reg <= (others => '0');

        features_reg(31 downto 24) <= std_logic_vector(to_unsigned(implementer, 8));
        features_reg(23 downto 16) <= std_logic_vector(to_unsigned(revision, 8));
        features_reg(15 downto 8)  <= std_logic_vector(to_unsigned(num_digits, 8));

        if lamp_mode_common_anode then
            features_reg(3) <= '1';
        else
            features_reg(3) <= '0';
        end if;

        if decimal_support then
            features_reg(0) <= '1';
        else
            features_reg(0) <= '0';
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then

            if reset_n = '0' then
                data_reg    <= (others => '0');
                control_reg <= (others => '0');

            elsif write = '1' then

                case address is

                    when "00" =>
                        data_reg <= writedata;

                    when "01" =>
                        -- only bit1(decimal) and bit0(enable)
                        control_reg(1 downto 0) <= writedata(1 downto 0);

                    when others =>
                        null;

                end case;
            end if;
        end if;
    end process;

    process(all)
    begin
        readdata <= (others => '0');

        if read = '1' then
            case address is

                when "00" =>
                    readdata <= data_reg;

                when "01" =>
                    readdata <= control_reg;

                when "10" =>
                    readdata <= features_reg;

                when "11" =>
                    readdata <= magic_reg;

                when others =>
                    readdata <= (others => '0');

            end case;
        end if;
    end process;


    process(all)
        variable bcd_value : std_logic_vector(19 downto 0);
    begin

        if decimal_support = true and control_reg(1) = '1' then
            bcd_value := to_bcd(data_reg(15 downto 0));
            display_value <= std_logic_vector(resize(unsigned(bcd_value), num_digits * 4));
        else
            display_value <= data_reg((num_digits * 4) - 1 downto 0);
        end if;

    end process;

    -- Drive lamps

    gen_digits : for i in 0 to num_digits - 1 generate
    begin
        process(all)
            variable seg : std_logic_vector(6 downto 0);
        begin

            if control_reg(0) = '1' then
                seg := seven_seg(display_value((i*4)+3 downto i*4));

                if lamp_mode_common_anode then
                    lamps((i*7)+6 downto i*7) <= seg;
                else
                    lamps((i*7)+6 downto i*7) <= not seg;
                end if;

            else
                if lamp_mode_common_anode then
                    lamps((i*7)+6 downto i*7) <= (others => '1');
                else
                    lamps((i*7)+6 downto i*7) <= (others => '0');
                end if;
            end if;

        end process;
    end generate;

end architecture;