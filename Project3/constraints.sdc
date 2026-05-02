# main 50 MHz clock
create_clock -period 20.000 [get_ports {board_clk}]
create_clock -period 20.000 -name main_clock_virt

# ADC 10 MHz clock
create_clock -period 100.000 [get_ports {small_clk}]
create_clock -period 100.000 -name adc_clock_virt

# ADC derived clock
create_generated_clock -name clk_div \
    -source [get_pins {pll_inst|seven_segment_display_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
    -divide_by 5 -multiply_by 1 \
    [get_pins {pll_inst|seven_segment_display_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]

# async clock groups
set_clock_groups -asynchronous \
    -group [get_clocks {board_clk}] \
    -group [get_clocks {small_clk}] \
    -group [get_clocks {clk_div}]