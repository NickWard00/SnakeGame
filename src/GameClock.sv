`default_nettype none
`include "define.svh"

module GameClock (
  input logic i_clock, i_reset,
  input [9:0] i_x,
  input [9:0] i_y,
  output logic o_game_clock
);
  logic updated;
  bit [2:0] draw_cycles;

  // calculate whether the screen has been updated
  always_ff @(posedge i_clock) begin
    if (o_game_clock) begin
      updated <= 1'b1;
    end
    else begin
      updated <= (draw_cycles == `DRAW_WAIT_CYCLES) ? 1'b1 : 1'b0;
    end
  end

  // calculate whether game state can be updated at this i_clock cycle
  always_ff @(posedge i_clock) begin
    o_game_clock <= (~updated && (draw_cycles == `DRAW_WAIT_CYCLES));
  end

  // calculate number of times screen was fully drawn
  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      draw_cycles <= 3'b0;
    end
    else begin
      if ((i_x == `MAX_H_ADDR) && (i_y == `MAX_V_ADDR)) begin
        draw_cycles <= (draw_cycles == `DRAW_WAIT_CYCLES) ? 3'b0 : draw_cycles + 1'b1;
      end
    end
  end

endmodule
