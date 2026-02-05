module text_display #(
    parameter SCALE = 4             // Font scaling factor
) (
    input wire clk_0,               // Pixel clock
    input wire rst,                 // Reset signal
    
    input wire [9:0] pixel_x,       // Current horizontal pixel position
    input wire [9:0] pixel_y,       // Current vertical pixel position
    
    input wire [9:0] x_pos,         // Top-left x coordinate of the char
    input wire [9:0] y_pos,         // Top-left y coordinate of the char
    
    input wire [6:0] char_code,     // ASCII code to display
    
    output reg pixel_on             // Output pixel signal
);

    // Calculate position relative to the character's top-left corner
    wire [9:0] rel_x = pixel_x - x_pos;
    wire [9:0] rel_y = pixel_y - y_pos;
    
    // Calculate which ROM row/col we are drawing (scaling down)
    wire [2:0] rom_row = rel_y / SCALE;
    wire [2:0] rom_col = rel_x / SCALE;

    // Check if the current pixel is within the character's bounding box
    wire in_box = (pixel_x >= x_pos) && (pixel_x < x_pos + 6*SCALE) &&
                  (pixel_y >= y_pos) && (pixel_y < y_pos + 8*SCALE);

    // Get the 6-bit row data from the font ROM
    wire [5:0] row_bits;
    
    font_rom font_library (
        .char_code(char_code),
        .row(rom_row),
        .row_bits(row_bits)
    );

    always @(posedge clk_0) begin
        if (!rst) pixel_on <= 0;
        else begin
            // Check if we are inside the box and the specific bit is '1'
            if (in_box && row_bits[5 - rom_col]) 
                pixel_on <= 1'b1;
            else
                pixel_on <= 1'b0;
        end
    end

endmodule