/*
Plan:
When the ball hits a paddle, we need to know where this hit happened on the paddle.
We will label this hit_y. We don't necessarily care about hit_x,
as shots on the bottom/top of the paddle will just act shots high up on the paddle
(larger velocity)

So velocity mapper needs to take in hit_y as an input.
This hit_y is relative to the center of the paddle.
We will also pass in two booleans: above_centre and below_centre.

This means we don't need to worry about storing hit_y as negative as well as positive.
We just consider whether it was above or below centre when hit_y was returned.

Good horizontal baseline at hit_y = 0: 200 pixels/sec

*/

module velocity_mapper (
    input clk_0,            // 25.175MHz clock
    input rst,

    input wire [6:0] hit_y, // The distance from the centre of the paddle to the ball during a hit
    input above_centre,     // Whether or not the ball hit above the paddle's centre
    input below_centre,     // Whether or not the ball hit below the paddle's centre

    output reg [8:0] sq_xvel,   // Squares's horizontal velocity in pixels/second
    output reg [8:0] sq_yvel    // Squares's vertical velocity in pixels/second
    );

    
    
endmodule