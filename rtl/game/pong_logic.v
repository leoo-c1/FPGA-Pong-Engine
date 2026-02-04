module pong_logic (
    input clk_0,            // 25MHz clock
    input rst,              // Reset button

    // Coordinates for the top left corner of each sprite
    output reg [9:0] square_xpos = h_video /2,
    output reg [9:0] square_ypos = v_video/2,

    output reg [9:0] paddle1_xpos = 24,
    output reg [9:0] paddle1_ypos = 191,

    output reg [9:0] paddle2_xpos = 603,
    output reg [9:0] paddle2_ypos = 191
    );

    parameter h_video = 640;        // Horizontal active video (in pixels)
    parameter v_video = 480;        // Vertical active video (in lines)

    parameter square_width = 16;    // The side lengths of the square
    parameter paddle_width = 12;    // The thickness of the paddle
    parameter paddle_height = 96;  // The height of the paddle

    // Future reference: Net is alternating black and white squares (size 12)  

    parameter velocity = 200;       // Velocity in pixels/second
    parameter vel_psc = 25_175_000 / velocity;  // Clock prescaler for velocity
    reg [18:0] vel_count = 0;       // Velocity ticker
    reg square_xvel = 1'b0;         // Square's direction of velocity along x, 0 = left, 1 = right
    reg square_yvel = 1'b0;         // Square's direction of velocity along y, 0 = up, 1 = down

    always @ (posedge clk_0) begin
        if (!rst) begin             // If we press the reset button
            // Reset the score and sprites' positions and velocities
            square_xpos <= h_video /2;
            square_ypos <= v_video /2;
            vel_count <= 0;
            square_xvel <= 1'b0;
            square_yvel <= 1'b0;
            paddle1_xpos <= 24;
            paddle1_ypos <= 191;
            paddle2_xpos <= 603;
            paddle2_ypos <= 191;

        // Square collision with right wall
        end else if (square_xpos >= h_video - square_width - 1) begin
            square_xvel <= ~square_xvel;        // Change direction along x-axis
            square_xpos <= square_xpos - 1;     // Move to the left by one pixel

        // Square collision with left wall
        end else if (square_xpos <= 0) begin
            square_xvel <= ~square_xvel;        // Change direction along y-axis
            square_xpos <= square_xpos + 1;     // Move to the right one pixel
        
        // Square collision with left paddle
        end else if (square_xpos <= paddle1_xpos + paddle_width + 1 && 
                    square_xpos + square_width >= paddle1_xpos) begin
            // If top/bottom left corner of the square is hitting the left paddle's right side
            if (square_ypos <= paddle1_ypos + paddle_height && 
                square_ypos + square_width >= paddle1_ypos) begin
                // Check if top of the square is hitting the bottom of the paddle
                if (square_ypos == paddle1_ypos + paddle_height ||
                    square_ypos == paddle1_ypos + paddle_height - 1) begin
                    square_yvel <= ~square_yvel;        // Change direction along y-axis
                    square_ypos <= square_ypos + 1;     // Move down one pixel
                
                // Check if bottom of the square is hitting the top of the paddle
                end else if (square_ypos + square_width == paddle1_ypos || 
                             square_ypos + square_width == paddle1_ypos + 1) begin
                    square_yvel <= ~square_yvel;        // Change direction along y-axis
                    square_ypos <= square_ypos - 1;     // Move up by one pixel

                end else begin
                    square_xvel <= ~square_xvel;        // Change direction along y-axis
                    square_xpos <= square_xpos + 1;     // Move to the right one pixel
                end
            end 

        // Square collision with right paddle
        // Check if the left/right side of the square hits
        end else if (square_xpos + square_width >= paddle2_xpos && 
                    square_xpos <= paddle2_xpos + paddle_width) begin
            // Check if the top/bottom right corner of the square hits the paddle
            if (square_ypos <= paddle2_ypos + paddle_height && 
                square_ypos + square_width >= paddle2_ypos) begin
                // Check if top of the square is hitting the bottom of the paddle
                if (square_ypos == paddle2_ypos + paddle_height ||
                    square_ypos == paddle2_ypos + paddle_height - 1) begin
                    square_yvel <= ~square_yvel;        // Change direction along y-axis
                    square_ypos <= square_ypos + 1;     // Move down one pixel
                
                // Check if bottom of the square is hitting the top of the paddle
                end else if (square_ypos + square_width == paddle2_ypos || 
                             square_ypos + square_width == paddle2_ypos + 1) begin
                    square_yvel <= ~square_yvel;        // Change direction along y-axis
                    square_ypos <= square_ypos - 1;     // Move up by one pixel

                end else begin
                    square_xvel <= ~square_xvel;        // Change direction along x-axis
                    square_xpos <= square_xpos - 1;     // Move to the left by one pixel
                end
            end
        end

        if (square_ypos >= v_video - square_width - 1) begin    // If we hit the bottom wall
            square_yvel <= ~square_yvel;        // Change direction along y-axis
            square_ypos <= square_ypos - 1;     // Move up by one pixel

        end else if (square_ypos <= 0) begin    // If we hit the top wall
            square_yvel <= ~square_yvel;        // Change direction along y-axis
            square_ypos <= square_ypos + 1;     // Move down one pixel
        end

        // Control square's x and y position
        if (vel_count < vel_psc) begin
            vel_count <= vel_count + 1;
        end else begin              // Increment square position every velocity tick
            vel_count <= 0;
            square_xpos <= square_xpos + 2*square_xvel - 1;
            square_ypos <= square_ypos + 2*square_yvel - 1;
        end

    end

endmodule