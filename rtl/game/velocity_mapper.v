module velocity_mapper #(
    parameter INIT_XVEL = 300,  // Used on reset, startup or game over
    parameter MIN_XVEL = 500,   // Used for horizontal velocity on centre hit
    parameter MAX_XVEL = 600,   // Maximum horizontal velocity in pixels/second for edge hits
    parameter VEL_WIDTH = $clog2(MAX_VEL + 1)   // Width of velocity register
    ) (
    input clk_0,                // 25.175MHz clock
    input rst,                  // Reset key

    input wire paddle_hit,      // Whether or not we just hit a paddle
    input wire [6:0] hit_y,     // The distance from paddle centre to the square during a hit

    input sq_missed,            // Whether or not the square went out of bounds
    input game_over,            // Whether or not the game is over
    input game_startup,         // Whether or not the game is on the startup menu

    output reg [VEL_WIDTH-1:0] sq_xvel,     // Squares's horizontal velocity in pixels/second
    output reg [VEL_WIDTH-1:0] sq_yvel      // Squares's vertical velocity in pixels/second
    );

    parameter pdl_height = 96;

    parameter SCALE_VELX = 2 * (MAX_XVEL - MIN_XVEL) / pdl_height;
    parameter SCALE_VELY = 2 * MAX_XVEL / pdl_height;

    always @ (posedge clk_0) begin
        if (!rst) begin         // If we reset, set velocities to default velocity
            sq_xvel <= INIT_XVEL;
            sq_yvel <= INIT_XVEL * 5 / 6;   // Decrease slope
        end else if (sq_missed | game_over | game_startup) begin
            sq_xvel <= INIT_XVEL;
            sq_yvel <= INIT_XVEL * 5 / 6;   // Decrease slope
        end else if (paddle_hit) begin
            sq_xvel <= SCALE_VELX * hit_y + MIN_XVEL;
            sq_yvel <= SCALE_VELY * hit_y;
        end
    end
    
endmodule