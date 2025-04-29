TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/LFSR.sv
TOPLEVEL = LFSR
MODULE = LFSR_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim
