TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/GameStateController.sv
TOPLEVEL = GameStateController
MODULE = GameStateController_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim
          