`default_nettype none

module LFSR (
  input logic i_clock, i_reset,
  input logic [5:0] i_seed,
  output logic [5:0] o_random
);
  // Note: Don't use a seed of 0, as this will get it into an infinite loop
  logic random_bit;
  logic [5:0] random_seq;
  logic [2:0] current_bit;

  // This constantly is making new pseudo random numbers, but in GameStateController,
  // this number is only taken when a fruit is eaten.
  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      random_seq <= i_seed;
    end
    else begin
      // Bits get shifted up, and then 2 most MSB get XORed
      // random_seq[5:1] <-- random_seq[4:0]
      // random_seq[0] <-- random_seq[5] ^ random_seq[4]
      random_seq <= (random_seq == 6'b0) ? i_seed : {random_seq[4:0], random_seq[5] ^ random_seq[4]};
    end
  end

  assign random_bit = random_seq[0];

  always_ff @(posedge i_clock or posedge i_reset) begin
    if (i_reset) begin
      o_random <= 6'd40;
      current_bit <= 3'b0;
    end
    else begin
      o_random[current_bit] <= random_bit;
      current_bit <= (current_bit == 3'd5) ? 3'b0 : current_bit + 3'b1;
    end
  end

endmodule
