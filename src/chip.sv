`default_nettype none

module my_chip (
  input logic [11:0] io_in, // Inputs to your chip
  output logic [11:0] io_out, // Outputs from your chip
  input logic clock,
  input logic reset // Important: Reset is ACTIVE-HIGH
);

  SnakeGame SnakeGame_inst (
    .i_clock(clock),
    .i_reset(reset),
    .i_up(io_in[3]),
    .i_down(io_in[2]),
    .i_left(io_in[1]),
    .i_right(io_in[0]),
    .o_vga_r(io_out[7:6]),
    .o_vga_g(io_out[5:4]),
    .o_vga_b(io_out[3:2]),
    .o_vga_hs(io_out[1]),
    .o_vga_vs(io_out[0])
  );

endmodule
