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
# make -Bf top_tb.mk
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

async def test_press_and_check_direction(dut, button_direction, expected_direction):
    # Press the button
    button_direction.value = 1

    # Wait 3 clock cycles due to making sure that the button is stabilized after synchronization
    await repeat_clock(dut, 3)
    
    # Check direction
    assert (LogicArray(dut.direction.value) == LogicArray(expected_direction)), f"exp: {expected_direction}, got: {dut.direction.value}"

    # Release the button
    button_direction.value = 0
    await repeat_clock(dut, 3)

async def test_two_input_direction(dut):
    await reset_dut(dut)

    # Press i_up and wait
    dut.i_up.value = 1
    await repeat_clock(dut, 3)
    
    # Verify initial direction is set
    assert LogicArray(dut.direction.value) == LogicArray("10"), f"exp: '10' (up), got: {dut.direction.value}"

    # While i_up is still held, press i_left
    dut.i_left.value = 1
    await repeat_clock(dut, 3)

    # Ensure direction has not changed
    assert LogicArray(dut.direction.value) == LogicArray("10"), f"Direction changed unexpectedly to {dut.direction.value} while first input was still active"

    # Release both inputs
    dut.i_up.value = 0
    dut.i_left.value = 0
    await repeat_clock(dut, 3)

async def test_opposite_direction(dut):
    await reset_dut(dut)

    # Step 1: Press i_up and verify direction
    dut.i_up.value = 1
    await repeat_clock(dut, 3)
    
    assert LogicArray(dut.direction.value) == LogicArray("10"), f"exp: '10' (up), got: {dut.direction.value}"

    # Step 2: While i_up is held, press i_down (opposite)
    dut.i_down.value = 1
    await repeat_clock(dut, 3)

    # Direction should remain as '10' (up)
    assert LogicArray(dut.direction.value) == LogicArray("10"), f"Direction changed to {dut.direction.value} when opposite direction was pressed"

    # Step 3: Release both
    dut.i_up.value = 0
    dut.i_down.value = 0
    await repeat_clock(dut, 3)

@cocotb.test()
async def direction_tests(dut):
    print("============== STARTING DIRECTION TESTS ==============")

    # Run the clock
    # 40ns is the period of a 25MHz clock
    cocotb.start_soon(Clock(dut.i_clock, 40, units="ns").start())

    await FallingEdge(dut.i_clock)

    # Reset the DUT
    await reset_dut(dut)

    await test_press_and_check_direction(dut, dut.i_up, "10")
    await test_press_and_check_direction(dut, dut.i_left, "00")
    await test_press_and_check_direction(dut, dut.i_down, "11")
    await test_press_and_check_direction(dut, dut.i_right, "01")

    await test_two_input_direction(dut)

    await test_opposite_direction(dut)

@cocotb.test()
async def game_over_test(dut):
    print("============== STARTING DIRECTION TESTS ==============")

    # Run the clock
    # 40ns is the period of a 25MHz clock
    cocotb.start_soon(Clock(dut.i_clock, 40, units="ns").start())

    await FallingEdge(dut.i_clock)

    # Reset the DUT
    await reset_dut(dut)

    await test_press_and_check_direction(dut, dut.i_left, "10")

    await wait_until(dut, dut.game_over, 1, timeout_cycles=1000000)