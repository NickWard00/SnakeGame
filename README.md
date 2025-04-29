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

# Final Project Example Template

This is an example outline you can modify and use in your final project submission. You are not required to use this exact template

## Project Name

A short description of what your project does and how it works. Feel free to include images

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

A short description of how to test the design post-tapeout
