import os
import logging
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.utils import get_sim_time
from cocotb.types import LogicArray
from cocotb.handle import Force
from cocotb.handle import Release

# source /afs/ece.cmu.edu/class/ece224/setup224
# make -Bf vga_tb.mk
async def repeat_clock(dut, num):
    for _ in range(num):
        await FallingEdge(dut.i_clock)

async def reset_dut(dut):
    dut.i_reset.value = 1
    await repeat_clock(dut, 2)
    dut.i_reset.value = 0
    await repeat_clock(dut, 1)

    assert (dut.i_reset.value == 0), "Reset signal should be deasserted (0) after reset sequence"

async def wait_until(dut, signal, condition, timeout_cycles=1000):
    for cycle in range(timeout_cycles):
        if signal.value == condition:
            print(f"Condition met after {cycle} cycles.")
            return
        await FallingEdge(dut.i_clock)

    assert False, f"Timeout waiting for condition on signal '{signal._name}' after {timeout_cycles} cycles."

async def test_entity_colors(dut):
    await reset_dut(dut)

    # Helper to test a single entity value and expected RGB output
    async def check_entity_color(entity_type, expected_r, expected_g, expected_b):
        dut.i_entity.value = LogicArray(entity_type)
        await FallingEdge(dut.i_clock)
        await FallingEdge(dut.i_clock)
        assert LogicArray(dut.o_vga_r.value) == LogicArray(expected_r), f"Entity {entity_type}: expected red {expected_r}, got {dut.o_vga_r.value}"
        assert LogicArray(dut.o_vga_g.value) == LogicArray(expected_g), f"Entity {entity_type}: expected green {expected_g}, got {dut.o_vga_g.value}"
        assert LogicArray(dut.o_vga_b.value) == LogicArray(expected_b), f"Entity {entity_type}: expected blue {expected_b}, got {dut.o_vga_b.value}"

    # Test entities
    await check_entity_color("00", "1111", "1111", "1111") # ENTITY_NOTHING: Red = 11, Green = 11, Blue = 11
    await check_entity_color("01", "0000", "1111", "0000") # ENTITY_SNAKE: Red = 00, Green = 11, Blue = 00
    await check_entity_color("10", "0000", "0000", "1111") # ENTITY_WALL: Red = 00, Green = 00, Blue = 11
    await check_entity_color("11", "1111", "0000", "0000") # ENTITY_APPLE 11: Red = 11, Green = 00, Blue = 00

@cocotb.test()
async def vga_tests(dut):
    print("============== STARTING VGA TESTS ==============")

    # Run the clock
    # 40ns is the period of a 25MHz clock
    cocotb.start_soon(Clock(dut.i_clock, 40, units="ns").start())

    await FallingEdge(dut.i_clock)

    # Reset the DUT
    await reset_dut(dut)

    await test_entity_colors(dut)