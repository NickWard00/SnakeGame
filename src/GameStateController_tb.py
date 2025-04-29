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
# make -Bf GameStateController_tb.mk
async def repeat_clock(dut, num):
    for _ in range(num):
        await FallingEdge(dut.i_vga_clock)

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
        await FallingEdge(dut.i_vga_clock)

    assert False, f"Timeout waiting for condition on signal '{signal._name}' after {timeout_cycles} cycles."

@cocotb.test()
async def entity_location_tests(dut):
    print("============== STARTING ENTITY TESTS ==============")

    # Run the clock
    # 40ns is the period of a 25MHz clock
    cocotb.start_soon(Clock(dut.i_vga_clock, 40, units="ns").start())

    await FallingEdge(dut.i_vga_clock)

    # Reset the DUT
    await reset_dut(dut)

    dut.i_curr_x.value = 10 * 16
    dut.i_curr_y.value = 11 * 16
    await repeat_clock(dut, 5)
    assert (LogicArray(dut.o_entity.value) == LogicArray("11")), "Entity should be an apple!"

    await repeat_clock(dut, 5)
    dut.i_curr_x.value = int((((640 / 16) / 2) - 1 ) * 16)
    dut.i_curr_y.value = int((((480 / 16) / 2) - 1 ) * 16)
    await repeat_clock(dut, 5)
    assert (LogicArray(dut.o_entity.value) == LogicArray("01")), "Entity should be a snake!"

    await repeat_clock(dut, 5)
    dut.i_curr_x.value = 0
    dut.i_curr_y.value = 0
    await repeat_clock(dut, 5)
    assert (LogicArray(dut.o_entity.value) == LogicArray("10")), "Entity should be a wall!"

