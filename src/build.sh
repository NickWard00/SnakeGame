#!/bin/sh

set -e

rm -r build || true

mkdir build

yosys -p 'read_verilog -sv define.svh GameStateController.sv LFSR.sv SnakeGame.sv GameClock.sv VGAController.sv KeyToDirection.sv; synth_ecp5 -abc2 -json build/synthesis.json -top SnakeGame'

nextpnr-ecp5 --12k --json build/synthesis.json --lpf constraints.lpf --textcfg build/pnr_out.config --freq 25

ecppack --compress build/pnr_out.config build/bitstream.bit

fujprog build/bitstream.bit
