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
# make -Bf LFSR_tb.mk
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

async def test_random_numbers(dut):
    await reset_dut(dut)

    last_random_num = 40 # Always starts at 40
    frequency = {}
    random_seed = random.randint(1, 63)
    
    for i in range(1000):
        dut.i_seed.value = random_seed
        # After 1 clock, we should still be on the reset value which is 40 (set in the code) or the last random value
        received_value = dut.o_random.value.integer
        assert received_value == last_random_num, f"exp: {last_random_num}, got {received_value}"
        await repeat_clock(dut, random.randint(1, 63))

        # Check that this number is not the original seed
        received_value = dut.o_random.value.integer

        if received_value in frequency:
            frequency[received_value] += 1
        else:
            frequency[received_value] = 1
        last_random_num = received_value
    
    assert len(frequency) > 25, f"Too few unique values: {len(frequency)}"

@cocotb.test()
async def LFSR_tests(dut):
    print("============== STARTING LFSR TESTS ==============")

    # Run the clock
    # 40ns is the period of a 25MHz clock
    cocotb.start_soon(Clock(dut.i_clock, 40, units="ns").start())

    await FallingEdge(dut.i_clock)

    # Reset the DUT
    await reset_dut(dut)

    await test_random_numbers(dut)