TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/VGAController.sv
TOPLEVEL = VGAController
MODULE = vga_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim
          