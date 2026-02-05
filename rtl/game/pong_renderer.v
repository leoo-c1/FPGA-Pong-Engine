module pong_renderer (
    input clk_0,            // 25.175MHz clock
    input rst,              // Reset button

    input [9:0] pixel_x,    // Horizontal position of pixel
    input [9:0] pixel_y,    // Vertical position of pixel
    input video_on,         // Whether or not we are in the active video region

    // Coordinates for the top left corner of each sprite
    input wire [9:0] square_xpos,
    input wire [9:0] square_ypos,

    input wire [9:0] paddle1_xpos,
    input wire [9:0] paddle1_ypos,

    input wire [9:0] paddle2_xpos,
    input wire [9:0] paddle2_ypos,

    // Game states
    input wire sq_shown,    // Whether the square should be shown or not

    input wire [3:0] score_p1,  // Player 1's score
    input wire [3:0] score_p2,  // Player 2's score
    input wire game_over,   // Whether or not the game is over

    output reg red,         // Red colour (either 0v or 0.7v)
    output reg green,       // Green colour (either 0v or 0.7v)
    output reg blue         // Blue colour (either 0v or 0.7v)
    );

    parameter h_video = 640;        // Horizontal active video (in pixels)
    parameter v_video = 480;        // Vertical active video (in lines)

    parameter square_width = 16;    // The side lengths of the square
    parameter paddle_width = 12;    // The thickness of the paddle
    parameter paddle_height = 96;   // The height of the paddle
    parameter net_width = 12;       // The side lengths of the net squares

    parameter score_p1_d1x = 262;   // x-coordinate for top left of digit 1 of player 1's score
    parameter score_p1_d2x = 220;   // x-coordinate for top left of digit 2 of player 1's score

    parameter score_p2_d1x = 388;   // x-coordinate for top left of digit 1 of player 2's score
    parameter score_p2_d2x = 346;   // x-coordinate for top left of digit 2 of player 2's score

    parameter score_ypos = 28;      // y-coordinate for top left both scores' digits

    reg [3:0] score_p1_d1 = 0;      // Digit 1 of player 1's score
    reg [3:0] score_p1_d2 = 0;      // Digit 2 of player 1's score

    reg [3:0] score_p2_d1 = 0;      // Digit 1 of player 2's score
    reg [3:0] score_p2_d2 = 0;      // Digit 2 of player 2's score

    reg [4:0] net_counter = 0; 

    reg in_square = 1'b0;           // If current pixel is inside the square
    reg in_paddle1 = 1'b0;          // If current pixel is inside paddle1
    reg in_paddle2 = 1'b0;          // If current pixel is inside paddle2
    reg in_net = 1'b0;              // If current pixel is inside the net
    wire in_score_p1_d1;            // If the current pixel is digit 1 of player 1's score
    wire in_score_p1_d2;            // If the current pixel is digit 2 of player 1's score
    wire in_score_p2_d1;            // If the current pixel is digit 1 of player 2's score
    wire in_score_p2_d2;            // If the current pixel is digit 2 of player 2's score
    wire in_startup_text;           // If the current pixel is in the startup text ('PONG...')

    // Digit 1 of player 1's score
    score_display score_p1_dig1 (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .x_pos(score_p1_d1x),
        .y_pos(score_ypos),
        .number(score_p1_d1),
        .pixel_on(in_score_p1_d1)
    );

    // Digit 2 of player 1's score
    score_display score_p1_dig2 (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .x_pos(score_p1_d2x),
        .y_pos(score_ypos),
        .number(score_p1_d2),
        .pixel_on(in_score_p1_d2)
    );

    // Digit 1 of player 2's score
    score_display score_p2_dig1 (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .x_pos(score_p2_d1x),
        .y_pos(score_ypos),
        .number(score_p2_d1),
        .pixel_on(in_score_p2_d1)
    );

    // Digit 2 of player 2's score
    score_display score_p2_dig2 (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .x_pos(score_p2_d2x),
        .y_pos(score_ypos),
        .number(score_p2_d2),
        .pixel_on(in_score_p2_d2)
    );

    /* Startup text:
            PONG
    Press any key to start
    */
    startup_text startup_menu (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .in_text(in_startup_text)
    );

    always @ (posedge clk_0) begin
        if (!rst) begin             // If we press the reset button, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
            in_square <= 1'b0;
            in_paddle1 <= 1'b0;
            in_paddle2 <= 1'b0;
            in_net <= 1'b0;
            net_counter <= 0;

        end else if (video_on) begin    // If we are in the active video region
            // If the pixel is within the horizontal limits of the square
            if (pixel_x >= square_xpos && pixel_x <= square_xpos + square_width) begin
                // If the pixel is within the vertical limits of the square
                if (pixel_y >= square_ypos && pixel_y <= square_ypos + square_width) begin
                    // Indicate we are inside the square
                    in_square <= 1'b1;
                end else begin
                    // Indicate we are outside the square
                    in_square <= 1'b0;
                end
            end else begin
                // Indicate we are outside the square
                in_square <= 1'b0;
            end

            // If the pixel is within the horizontal limits of paddle1
            if (pixel_x >= paddle1_xpos && pixel_x <= paddle1_xpos + paddle_width) begin
                // If the pixel is within the vertical limits of paddle1
                if (pixel_y >= paddle1_ypos && pixel_y <= paddle1_ypos + paddle_height) begin
                    // Indicate we are inside paddle1
                    in_paddle1 <= 1'b1;
                end else begin
                    // Indicate we are outside paddle1
                    in_paddle1 <= 1'b0;
                end
            end else begin
                // Indicate we are outside paddle1
                in_paddle1 <= 1'b0;
            end

            // If the pixel is within the horizontal limits of paddle2
            if (pixel_x >= paddle2_xpos && pixel_x <= paddle2_xpos + paddle_width) begin
                // If the pixel is within the vertical limits of paddle2
                if (pixel_y >= paddle2_ypos && pixel_y <= paddle2_ypos + paddle_height) begin
                    // Indicate we are inside paddle2
                    in_paddle2 <= 1'b1;
                end else begin
                    // Indicate we are outside paddle2
                    in_paddle2 <= 1'b0;
                end
            end else begin
                // Indicate we are outside paddle2
                in_paddle2 <= 1'b0;
            end

            if (pixel_y == 0 && pixel_x == 0) begin
                net_counter <= 18; 
            end 
            // Check for Start of New Line
            else if (pixel_x == 0) begin
                if (net_counter == 23) begin
                    net_counter <= 0;
                end else begin
                    net_counter <= net_counter + 1;
                end
            end

            if (pixel_x >= h_video/2 - net_width/2 && pixel_x <= h_video/2 + net_width/2 - 1) begin
                if (net_counter < 12) begin
                    in_net <= 1'b1;
                end
            end else begin
                in_net <= 1'b0;
            end

            // Handle assigning digits of player 1's score
            if (score_p1 <= 9) begin
                score_p1_d1 <= score_p1;
                score_p1_d2 <= 0;
            end else if (score_p1 == 10) begin
                score_p1_d1 <= 0;
                score_p1_d2 <= 1;
            end else if (score_p1 == 11) begin
                score_p1_d1 <= 1;
                score_p1_d2 <= 1;
            end else begin
                score_p1_d1 <= 0;
                score_p1_d2 <= 0;
            end

            // Handle assigning digits of player 2's score
            if (score_p2 <= 9) begin
                score_p2_d1 <= score_p2;
                score_p2_d2 <= 0;
            end else if (score_p2 == 10) begin
                score_p2_d1 <= 0;
                score_p2_d2 <= 1;
            end else if (score_p2 == 11) begin
                score_p2_d1 <= 1;
                score_p2_d2 <= 1;
            end else begin
                score_p2_d1 <= 0;
                score_p2_d2 <= 0;
            end

        end else begin          // If we are outside the active video region, show black
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end

        // If we are inside a sprite, make the pixel white
        if (in_paddle1 || in_paddle2 || (in_square && sq_shown) || in_net
            || in_score_p1_d1 || in_score_p1_d2 || in_score_p2_d1 || in_score_p2_d2) begin
            red <= 1'b1;
            green <= 1'b1;
            blue <= 1'b1;
        // If we are outside of a sprite, make the pixel black
        end else begin
            red <= 1'b0;
            green <= 1'b0;
            blue <= 1'b0;
        end

    end

endmodule