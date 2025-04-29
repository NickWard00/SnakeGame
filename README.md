# 18-224/624 S25 Tapeout Template


1. Add your verilog source files to `source_files` in `info.yaml`. The top level of your chip should remain in `chip.sv` and be named `my_chip`

  
  

2. Optionally add other details about your project to `info.yaml` as well (this is only for GitHub - your final project submission will involve submitting these in a different format)

3. Do NOT edit `toplevel_chip.v`  `config.tcl` or `pin_order.cfg`

 # Final Project Submission Details 
  
1. Your design must synthesize at 30MHz but you can run it at any arbitrarily-slow frequency (including single-stepping the clock) on the manufactured chip. If your design must run at an exact frequency, it is safest to choose a lower frequency (i.e. 5MHz)

  

2. For your final project, we will ask you to submit some sort of testbench to verify your design. Include all relevant testing files inside the `testbench` repository



3. For your final project, we will ask you to submit documentation on how to run/test your design, as well as include your project proposal and progress reports. Include all these files inside the `docs` repository



4. Optionally, if you use any images in your documentation (diagrams, waveforms, etc) please include them in a separate `img` repository


5. Feel free to edit this file and include some basic information about your project (short description, inputs and outputs, diagrams, how to run, etc). An outline is provided below

# Final Project

## Snake Game

This is a simple game of Snake that outputs to a display using the VGA interface. The game uses 5 buttons to control the game: left, right, up, down, and reset. The user must control the snake to reach an apple that appears randomly on the screen. Each time the snake eats an apple, it grows a longer tail. The snake moves continuously in one direction, and you can only change its direction (up, down, left, or right). The game ends when the snake collides with a wall or itself. To start the game, hit a direction button. To restart the game, hit the reset button.

The development of the chip was completed using a fully open-source toolchain provided by the OSS CAD Suite. This included key tools such as Yosys for RTL synthesis, NextPNR for placement and routing, and OpenSTA for static timing analysis. Verilator was used for high-performance Verilog simulation, and the design was verified using cocotb to create SystemVerilog testbenches in Python.

## User Configurables

In the `define.vh` file, the user can change a few parameters to change game functionality.
1. `TWO_BIT_COLOR`: Comment/delete this to change the design to output 4 bit color
2. `NO_WALLS`: Uncomment the following to have walls not appear in the game. The snake will just loop across the screen.
2. `DRAW_WAIT_CYCLES`: Change this value to `3'd3` for normal speed, `3'd1` for fast speed, `3'd6` for slow speed. If the game is too challenging or too easy, feel free to change this option.

## IO

Here is an IO table listing all of the inputs and outputs and their functions.

| Input/Output | Description|																
|--------------|--------------------------------------------------|
| io_in[0]     | right button signal                              |
| io_in[1]     | left button signal                               |
| io_in[2]     | down button signal                               |
| io_in[3]     | up button signal                                 |
| io_in[11:4]  | Unused                                           |
| io_out[0]    | VS, vertical sync                                |
| io_out[1]    | HS, horizontal sync                              |
| io_out[3:2]  | Blue Channel                                     |
| io_out[5:4]  | Green Channel                                    |
| io_out[7:6]  | Red Channel                                      |
| io_out[11:8] | Unused                                           |

## How to Test

To test the game, use the `top_tb`, `vga_tb`, `LFSR_tb`, and `GameStateController_tb` tests to test the functionality. 

In order to run, source into the `OSS_CAD_SUITE` and do: `make -Bf top_tb.mk` for the top_tb tests. Change `top_tb` to any of the other tests to test functionality.

## FPGA and Hardware Setup
The following photo shows the CS-ULX3S-01 with the TinyVGA Pmod VGA adaptor.
![BoardSetup](https://github.com/user-attachments/assets/7b50bd35-f102-4d88-b0d4-99c07c31cf5a)

## Demo
Here is a video of the game working as intended on the ULX3S.
https://github.com/NickWard00/SnakeGame/blob/0369b70b15940c62f082c47a60f1a965d06c6b3c/docs/GameDemoVideo.mp4
