`default_nettype none
`include "define.svh"

module GameStateController (
  input i_vga_clock, i_game_clock, i_reset,
  input i_game_start,
  input [1:0] i_direction,
  input logic [9:0] i_curr_x, i_curr_y,
  output logic [1:0] o_entity,
  output logic o_game_over, o_game_won,
  output logic `TAIL_SIZE o_tail_count
);

  logic `X_SIZE tile_x, snake_head_x, apple_x;
  logic `Y_SIZE tile_y, snake_head_y, apple_y;
  logic `COORD_SIZE tails [`MAX_TAIL_ADDR:0];
  logic [5:0] rand_x, rand_y, rand_apple_x, rand_apple_y;
  logic `TAIL_SIZE next_tail_count;
  logic tail_coord, ate_apple, tail_touch, wall_touch;

  LFSR LFSR_X_inst (
    .i_clock(i_game_clock),
    .i_reset(i_reset),
    .i_seed(6'b100110),
    .o_random(rand_x)
  );

  LFSR LFSR_Y_inst (
    .i_clock(i_game_clock),
    .i_reset(i_reset),
    .i_seed(6'b101001),
    .o_random(rand_y)
  );

  // Modulo to make sure that apple appears on the screen
  assign rand_apple_x = (rand_x % (`MAX_H_ADDR - 1)) + 1;
  assign rand_apple_y = (rand_y % (`MAX_V_ADDR - 1)) + 1;

  assign tile_x = (i_curr_x / `H_SQUARE);
  assign tile_y = (i_curr_y / `V_SQUARE);

  assign o_game_over = tail_touch || wall_touch;

  // Entity from current x,y
  always_comb begin
    o_entity = `ENTITY_NOTHING;
    if ({tile_x, tile_y} == {snake_head_x, snake_head_y} || tail_coord) begin
      o_entity = `ENTITY_SNAKE;
    end
    else if ({tile_x, tile_y} == {apple_x, apple_y}) begin
      o_entity = `ENTITY_APPLE;
    end
    `ifndef NO_WALLS
    else if (tile_x == 0 || tile_x == `MAX_H_ADDR || tile_y == 0 || tile_y == `MAX_V_ADDR) begin
      o_entity = `ENTITY_WALL;
    end
    `endif
  end

  // Go over all tails and check if the current x,y is a tail
  always_ff @(posedge i_vga_clock or posedge i_reset) begin
    if (i_reset) begin
      tail_touch <= 1'b0;
      tail_coord <= 1'b0;
    end
    else begin
      tail_coord <= 1'b0;

      for (int i = 0; i < `MAX_TAILS; i++) begin
        if (i < o_tail_count) begin
          if (tails[i] == {tile_x, tile_y}) begin
            tail_coord <= 1'b1;
          end
          if (tails[i] == {snake_head_x, snake_head_y}) begin
            tail_touch <= 1'b1;
          end
        end
      end
    end
  end

  // Advance snake head and restart to other side of screen if hits the end
  always_ff @(posedge i_game_clock or posedge i_reset) begin
    if (i_reset) begin
      snake_head_x <= `GRID_MID_WIDTH - 1;
      snake_head_y <= `GRID_MID_HEIGHT - 1;
      wall_touch <= 1'b0;
    end
    else begin
      if ((!o_game_over) && (i_game_start)) begin
        case (i_direction)
        `ifdef NO_WALLS
          `LEFT_DIR: begin
            snake_head_x <= (snake_head_x == 0) ? `MAX_H_ADDR : (snake_head_x - 1);
          end
          `UP_DIR: begin
            snake_head_y <= (snake_head_y == 0) ? `MAX_V_ADDR : (snake_head_y - 1);
          end
          `RIGHT_DIR: begin
            snake_head_x <= (snake_head_x == `MAX_H_ADDR) ? 0 : (snake_head_x + 1);
          end
          `DOWN_DIR: begin
            snake_head_y <= (snake_head_y == `MAX_V_ADDR) ? 0 : (snake_head_y + 1);
          end
          `else
          `LEFT_DIR: begin
            if (snake_head_x == 1) begin
              wall_touch <= 1'b1;
            end
            else begin
              snake_head_x <= snake_head_x - 1;
            end
          end
          `UP_DIR: begin
            if (snake_head_y == 1) begin
              wall_touch <= 1'b1;
            end
            else begin
              snake_head_y <= snake_head_y - 1;
            end
          end
          `RIGHT_DIR: begin
            if (snake_head_x == `MAX_H_ADDR - 1) begin
              wall_touch <= 1'b1;
            end
            else begin
              snake_head_x <= snake_head_x + 1;
            end
          end
          `DOWN_DIR: begin
            if (snake_head_y == `MAX_V_ADDR - 1) begin
             wall_touch <= 1'b1;
            end
            else begin
              snake_head_y <= snake_head_y + 1;
            end
          end
          `endif
        endcase
      end
    end
  end

  // Update tails
  always_ff @(posedge i_game_clock or posedge i_reset) begin
    if (i_reset) begin
      apple_x <= 10;
      apple_y <= 11;
      o_tail_count <= 0;
    end
    else begin
      // Check if apple is eaten
      ate_apple = (snake_head_x == apple_x && snake_head_y == apple_y);

      // Calculate next tail count in advance
      next_tail_count = (ate_apple && (o_tail_count < `MAX_TAILS)) ? o_tail_count + 1'b1 : o_tail_count;

      // Update apple position if eaten
      if (ate_apple) begin
        apple_x <= rand_apple_x;
        apple_y <= rand_apple_y;
      end

      // Shift tails
      for (int i = `MAX_TAILS-1; i > 0; i--) begin
        if (i < next_tail_count) begin
          tails[i] <= tails[i-1];
        end
      end

      // Add current head position as new tail
      if (next_tail_count > 0) begin
        tails[0] <= {snake_head_x, snake_head_y};
      end

      // Update tail count
      o_tail_count <= next_tail_count;
    end
  end

  always_ff @(posedge i_game_clock or posedge i_reset) begin
    if (i_reset) begin
      o_game_won <= 1'b0;
    end
    else begin
      if (o_tail_count == `MAX_TAILS) begin
        o_game_won <= 1'b1;
      end
    end
  end

endmodule
