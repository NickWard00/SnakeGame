`default_nettype none
`include "define.svh"
// yosys -p 'read_verilog -sv define.vh GameStateController.sv LFSR.sv pll.sv SnakeGame.sv updateGameClock.sv VGA_Controller.sv; synth_ecp5 -json build/synthesis.json -top SnakeGame'
// nextpnr-ecp5 --log build/nextpnr.log --json build/synthesis.json --write build/placed.json --freq 25 --sdf build/back_annotation.sdf --placed-svg build/place_render.svg --routed-svg build/routed_render.svg --12k --package CABGA381 --speed 6 --lpf constraints.lpf --textcfg build/pnr_out.config
// ecppack --compress build/pnr_out.config build/bitstream.bit
// fujprog build/bitstream.bit
// Assumes i_clock assumes a 25MHz clock, please use a PLL if incoming clock is different

module SnakeGame (
  input logic i_clock, i_reset,

  // Button Inputs
  input logic i_up, i_down, i_left, i_right,

  // VGA Output
`ifdef TWO_BIT_COLOR
  output logic [1:0] o_vga_r,
  output logic [1:0] o_vga_g,
  output logic [1:0] o_vga_b,
`else
  output logic [3:0] o_vga_r,
  output logic [3:0] o_vga_g,
  output logic [3:0] o_vga_b,
`endif
  output logic o_vga_hs, o_vga_vs
);
  // Clocking
  logic game_clock;
  
  // Direction
  logic [1:0] direction;
  
  // VGA
  logic [3:0] vga_r, vga_g, vga_b;
  logic [9:0] vga_x, vga_y;

  // Game logic
  logic [1:0] current_entity;
  logic `TAIL_SIZE game_score;
  logic start_game, game_over, game_won;

  always_comb begin
  `ifdef TWO_BIT_COLOR
    o_vga_r = {vga_r[1], vga_r[0]};
    o_vga_g = {vga_g[1], vga_g[0]};
    o_vga_b = {vga_b[1], vga_b[0]};
  `else
    o_vga_r = vga_r;
    o_vga_g = vga_g;
    o_vga_b = vga_b;
  `endif
  end

  GameStateController GameStateController_inst (
    .i_vga_clock(i_clock),
    .i_game_clock(game_clock),
    .i_reset(i_reset),
    .i_game_start(start_game),
    .i_direction(direction),
    .i_curr_x(vga_x),
    .i_curr_y(vga_y),
    .o_entity(current_entity),
    .o_game_over(game_over),
    .o_game_won(game_won),
    .o_tail_count(game_score)
  );

  GameClock GameClock_inst (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_x(vga_x),
    .i_y(vga_y),
    .o_game_clock(game_clock)
  );

  VGAController VGAController_inst (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_entity(current_entity),
    .o_curr_x(vga_x),
    .o_curr_y(vga_y),
    .o_vga_r(vga_r),
    .o_vga_g(vga_g),
    .o_vga_b(vga_b),
    .o_vga_hs(o_vga_hs),
    .o_vga_vs(o_vga_vs)
  );

  KeyToDirection KeyToDirection_inst (
    .i_clock(i_clock), 
    .i_reset(i_reset),
    .i_key({i_up, i_down, i_left, i_right}),
    .o_direction(direction),
    .o_game_start(start_game)
  );

endmodule: SnakeGame