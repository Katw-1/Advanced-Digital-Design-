# main 50 MHz clock
create_clock -period 20.000 -name main_clock [ get_ports {clk_50} ]
create_clock -period 20.000 -name main_clock_virt

# ADC 10 MHz clock
create_clock -period 100.000 -name adc_clock [ get_ports {adc_clk_in} ]
create_clock -period 100.000 -name adc_clock_virt

# ADC derived clock
create_generated_clock -name clk_div -source [ get_pins u_divider/clk_in ] \
-divide_by 5 -multiply_by 1 [ get_pins u_divider/clk_out ] 