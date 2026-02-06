module scoreboard_renderer #(
    // Layout Configuration
    parameter X_START = 220,        // x coordinate of the leftmost digit (P1 tens)
    parameter Y_START = 28,         // y coordinate of the top of the scores
    parameter SCALE = 8,            // Pixel scaling
    parameter KERNING = 10,         // Space between tens and ones of the same player
    parameter PLAYER_SPACING = 52   // Space between player 1 and player 2 scores
)(
    input clk,
    input rst,
    input [9:0] pixel_x,
    input [9:0] pixel_y,
    input [3:0] score_p1,
    input [3:0] score_p2,
    
    output pixel_on                 // Whether or not we are in the score text
);

    reg [3:0] p1_tens;
    reg [3:0] p1_ones;
    reg [3:0] p2_tens;
    reg [3:0] p2_ones;

    always @(*) begin
        // Player 1 Logic
        if (score_p1 <= 9) begin
            p1_ones = score_p1;
            p1_tens = 0;
        end else if (score_p1 == 10) begin
            p1_ones = 0;
            p1_tens = 1;
        end else if (score_p1 == 11) begin
            p1_ones = 1;
            p1_tens = 1;
        end else begin
            p1_ones = 0;
            p1_tens = 0;
        end

        // Player 2 Logic
        if (score_p2 <= 9) begin
            p2_ones = score_p2;
            p2_tens = 0;
        end else if (score_p2 == 10) begin
            p2_ones = 0;
            p2_tens = 1;
        end else if (score_p2 == 11) begin
            p2_ones = 1;
            p2_tens = 1;
        end else begin
            p2_ones = 0;
            p2_tens = 0;
        end
    end

    // The width of a single digit in pixels
    localparam DIGIT_W = 4 * SCALE; 

    // Calculate x coordinates for all 4 digits
    localparam P1_TENS_X = X_START;
    localparam P1_ONES_X = X_START + DIGIT_W + KERNING;
    localparam P2_TENS_X = P1_ONES_X + DIGIT_W + PLAYER_SPACING;
    localparam P2_ONES_X = P2_TENS_X + DIGIT_W + KERNING;

    // Rendering booleans
    wire on_p1_tens;
    wire on_p1_ones;
    wire on_p2_tens;
    wire on_p2_ones;

    // Player 1 digits
    score_display #(.SCALE(SCALE)) disp_p1_tens (
        .clk_0(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(P1_TENS_X[9:0]), .y_pos(Y_START[9:0]),
        .number(p1_tens), .pixel_on(on_p1_tens)
    );

    score_display #(.SCALE(SCALE)) disp_p1_ones (
        .clk_0(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(P1_ONES_X[9:0]), .y_pos(Y_START[9:0]),
        .number(p1_ones), .pixel_on(on_p1_ones)
    );

    // Player 2 digits
    score_display #(.SCALE(SCALE)) disp_p2_tens (
        .clk_0(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(P2_TENS_X[9:0]), .y_pos(Y_START[9:0]),
        .number(p2_tens), .pixel_on(on_p2_tens)
    );

    score_display #(.SCALE(SCALE)) disp_p2_ones (
        .clk_0(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(P2_ONES_X[9:0]), .y_pos(Y_START[9:0]),
        .number(p2_ones), .pixel_on(on_p2_ones)
    );

    // Combine all outputs
    assign pixel_on = on_p1_tens | on_p1_ones | on_p2_tens | on_p2_ones;

endmodule