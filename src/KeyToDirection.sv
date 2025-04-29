`default_nettype none
`include "define.vh"

module KeyToDirection (
  input logic i_clock, i_reset,
  input logic [3:0] i_key,
  output logic o_game_start,
  output logic [1:0] o_direction
);
  logic left, right, up, down;
  // Game Buttons
  FFSynchronizer syncKEY0 (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_bit(i_key[0]),
    .o_bit(right)
  );
  FFSynchronizer syncKEY1 (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_bit(i_key[1]),
    .o_bit(left)
  );
  FFSynchronizer syncKEY2 (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_bit(i_key[2]),
    .o_bit(down)
  );
  FFSynchronizer syncKEY3 (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_bit(i_key[3]),
    .o_bit(up)
  );

  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      o_game_start <= 1'b0;
    end
    else begin
      if (!o_game_start && (up | down | left | right)) begin
        o_game_start <= 1'b1;
      end
    end
  end
  
  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      o_direction <= `LEFT_DIR;
    end
    else begin
      if (left + right + up + down == 3'b001) begin 
        if (left && (o_direction != `RIGHT_DIR)) begin
          o_direction <= `LEFT_DIR; 
        end
        if (right && (o_direction != `LEFT_DIR)) begin
          o_direction <= `RIGHT_DIR; 
        end
        if (up && (o_direction != `DOWN_DIR)) begin
          o_direction <= `UP_DIR;
        end
        if (down && (o_direction != `UP_DIR)) begin
          o_direction <= `DOWN_DIR; 
        end
      end
    end
  end

endmodule: KeyToDirection

module FFSynchronizer (
  input i_clock,
  input i_reset,
  input logic i_bit,
  output logic o_bit
);
  logic temp;

  // This synchronizer works by double flopping the bit
  // This takes a cycle instead of it being instant,
  // but we guarantee a stable bit 
  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      {o_bit, temp} <= {2'b0};
    end else begin
      {o_bit, temp} <= {temp, i_bit};
    end
  end
endmodule: FFSynchronizer
