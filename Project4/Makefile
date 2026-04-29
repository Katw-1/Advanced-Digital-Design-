TOPLEVEL_LANG=vhdl
VHDL_SOURCES = \
		$(PWD)/../vhdl/seven_segment_pkg.vhd \
		$(PWD)/../vhdl/config_ctl.vhd \
		$(PWD)/../vhdl/register_config.vhd \
		$(PWD)/../vhdl/seven_segment_driver.vhd \
		$(PWD)/../vhdl/toplevel.vhd \
		$(PWD)/../vhdl/toplevel_wrapper.vhd \
		$(PWD)/toplevel_seven_segment_pkg.vhd \
		$(PWD)/toplevel_seven_segment_driver.vhd
TOPLEVEL ?= toplevel_wrapper
SIM=ghdl
COCOTB_TEST_MODULES ?= tb_toplevel_wrapper
# SIM_ARGS=--wave=$(TOPLEVEL).ghw

export COCOTB_REDUCED_LOG_FMT=1

include $(shell cocotb-config --makefiles)/Makefile.sim
