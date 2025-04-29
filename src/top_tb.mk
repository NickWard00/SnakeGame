TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/SnakeGame.sv
TOPLEVEL = SnakeGame
MODULE = top_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs -Wno-fatal
include $(shell cocotb-config --makefiles)/Makefile.sim
          