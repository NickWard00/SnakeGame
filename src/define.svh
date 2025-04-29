`ifndef define_svh
`define define_svh

// User Configurables
// Comment/delete this to change the design to output 4 bit color
`define TWO_BIT_COLOR

// Uncomment the following to have walls not appear in the game. The snake will just loop across the screen.
//`define NO_WALLS

// Game Speed
// Change to 3'd1 for fast, 3'd6 for slow, 3'd3 for normal
`define DRAW_WAIT_CYCLES 3'd3

// Game Direction
`define LEFT_DIR 2'b00
`define RIGHT_DIR 2'b01
`define UP_DIR 2'b10
`define DOWN_DIR 2'b11

// Entities
`define ENTITY_NOTHING 2'b00
`define ENTITY_SNAKE 2'b01
`define ENTITY_WALL 2'b10
`define ENTITY_APPLE 2'b11

// VGA Signals
`define VGA_WIDTH 640
`define VGA_HEIGHT 480

`define H_SQUARE 16
`define V_SQUARE 16

`define H_FRONT 16
`define H_SYNC 96
`define H_BACK 48
`define H_BLANK (`H_FRONT + `H_SYNC + `H_BACK)
`define H_TOTAL (`H_FRONT + `H_SYNC + `H_BACK + `VGA_WIDTH)
`define GRID_WIDTH (`VGA_WIDTH / `H_SQUARE)
`define GRID_MID_WIDTH (`GRID_WIDTH / 2)
`define MAX_H_ADDR (`GRID_WIDTH - 1)

`define V_FRONT 10
`define V_SYNC 2
`define V_BACK 33
`define V_BLANK (`V_FRONT + `V_SYNC + `V_BACK)
`define V_TOTAL (`V_FRONT + `V_SYNC + `V_BACK + `VGA_HEIGHT)
`define GRID_HEIGHT (`VGA_HEIGHT / `V_SQUARE)
`define GRID_MID_HEIGHT (`GRID_HEIGHT / 2)
`define MAX_V_ADDR (`GRID_HEIGHT - 1)

// Grid/Game Parameters
`define X_SIZE [$clog2(`GRID_WIDTH):0]
`define Y_SIZE [$clog2(`GRID_HEIGHT):0]
`define COORD_SIZE [$clog2(`GRID_WIDTH) + $clog2(`GRID_HEIGHT):0]

`define MAX_TAILS 32
`define MAX_TAIL_ADDR (`MAX_TAILS - 1)
`define TAIL_COUNT_MSB $clog2(`MAX_TAILS)
`define TAIL_SIZE [`TAIL_COUNT_MSB:0]

`endif // define_svh
