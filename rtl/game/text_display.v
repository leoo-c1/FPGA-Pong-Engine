module text_display #(
    parameter SCALE = 4 // 8*4 = 32 pixels wide per char, modifiable
) (
    input clk_0,
    input rst,
    input [9:0] pixel_x, pixel_y,
    input [9:0] x_pos, y_pos,
    input [6:0] char_code, // ASCII input
    
    output reg pixel_on
);

    // Relative calculation
    wire [9:0] rel_x = pixel_x - x_pos;
    wire [9:0] rel_y = pixel_y - y_pos;
    
    // Scale down
    wire [2:0] rom_row = rel_y / SCALE;
    wire [2:0] rom_col = rel_x / SCALE;

    // Bounds Check
    wire in_box = (pixel_x >= x_pos) && (pixel_x < x_pos + 6*SCALE) &&
                  (pixel_y >= y_pos) && (pixel_y < y_pos + 8*SCALE);

    // ROM lookup
    wire [7:0] row_bits;
    
    font_rom font_library (
        .char_code(char_code),
        .row(rom_row),
        .row_bits(row_bits)
    );

    // Pixel output
    always @(posedge clk_0) begin
        if (!rst) pixel_on <= 0;
        else begin
            if (in_box && row_bits[7 - rom_col]) // 7-col to fix mirroring
                pixel_on <= 1'b1;
            else
                pixel_on <= 1'b0;
        end
    end

endmodule