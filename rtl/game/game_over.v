module game_over #(
    parameter KERNING = 0,
    parameter OVER_SCALE = 8,
    parameter START_SCALE = 3,
    // Coordinates for top left of the 'G' in 'Game over!' so the word is centered
    parameter OVER_X = 320 - 3*KERNING/2 - 30*OVER_SCALE,
    parameter OVER_Y = 99,
    // Coordinates for top left of the 'P' in 'Press any key to start'
    parameter START_X = 320 - 66*START_SCALE - 10*KERNING,
    parameter START_Y = OVER_Y + 8*OVER_SCALE + 20 - 1

) (
    input clk_0,
    input rst,
    input [9:0] pixel_x, pixel_y,
    
    output reg in_text
    );

    wire in_over;
    wire in_start;

    // Generate string 'Game over!'
    string_display #(
        .SCALE(OVER_SCALE),
        .KERNING(KERNING),
        .LEN(10),
        .TEXT("Game over!")
    ) game_over (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(OVER_X), .y_pos(OVER_Y),
        .pixel_on(in_over)
    );

    // Generate string 'Press any key to start'
    string_display #(
        .SCALE(START_SCALE),
        .KERNING(KERNING),
        .LEN(22),
        .TEXT("Press any key to start")
    ) start2 (
        .clk_0(clk_0),
        .rst(rst),
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .x_pos(START_X), .y_pos(START_Y),
        .pixel_on(in_start)
    );

    always @ (posedge clk_0) begin
        in_text <= (in_over | in_start);
    end

endmodule