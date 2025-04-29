`default_nettype none
`include "define.vh"

module VGAController (
  input logic i_clock, i_reset,
  input logic [1:0] i_entity,

  output logic [9:0] o_curr_x,
  output logic [9:0] o_curr_y,
  output logic [3:0] o_vga_r, o_vga_g, o_vga_b,
  output logic o_vga_hs, o_vga_vs
);
  logic [9:0] h_count;
  logic [9:0] v_count;
  logic [3:0] red, green, blue;

  assign o_curr_x = (h_count >= `H_BLANK) ? h_count - `H_BLANK : 10'b0;
  assign o_curr_y = (v_count >= `V_BLANK) ? v_count - `V_BLANK : 10'b0;

  assign o_vga_r = (o_curr_x > 0) ? red : 4'b0;
  assign o_vga_g = (o_curr_x > 0) ? green : 4'b0;
  assign o_vga_b = (o_curr_x > 0) ? blue : 4'b0;

  // Horizontal Signals
  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      h_count <= 10'b0;
      o_vga_hs <= 1'b1;
    end
    else begin
      if (h_count < `H_TOTAL - 1) begin
        h_count <= h_count + 1'b1;
      end
      else begin
        h_count <= 10'b0;
      end
      // Horizontal Sync
      if (h_count == `H_FRONT - 1) begin // Front porch end
        o_vga_hs <= 1'b0;
      end
      if (h_count == `H_FRONT + `H_SYNC - 1) begin // Sync pulse end
        o_vga_hs <= 1'b1;
      end
    end
  end

  // Vertical Signals
  always_ff @(posedge o_vga_hs or posedge i_reset) begin
    if (i_reset) begin
      v_count <= 10'b0;
      o_vga_vs <= 1'b1;
    end
    else begin
      if (v_count < `V_TOTAL - 1) begin
        v_count <= v_count + 1'b1;
      end
      else begin
        v_count <= 10'b0;
      end
      // Vertical Sync
      if (v_count == `V_FRONT - 1) begin // Front porch end
        o_vga_vs <= 1'b0;
      end
      if (v_count == `V_FRONT + `V_SYNC - 1) begin // Sync pulse end
        o_vga_vs <= 1'b1;
      end
    end
  end

  always_comb begin
    red = 4'b0;
    green = 4'b0;
    blue = 4'b0;
    case (i_entity)
      `ENTITY_NOTHING: begin
        red = 4'b1111;
        green = 4'b1111;
        blue = 4'b1111;
      end
      `ENTITY_SNAKE: begin
        red = 4'b0;
        green = 4'b1111;
        blue = 4'b0;
      end
      `ENTITY_WALL: begin
        red = 4'b0;
        green = 4'b0;
        blue = 4'b1111;
      end
      `ENTITY_APPLE: begin
        red = 4'b1111;
        green = 4'b0;
        blue = 4'b0;
      end
    endcase
  end
endmodule