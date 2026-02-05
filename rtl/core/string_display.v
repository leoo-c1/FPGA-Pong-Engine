module string_display #(
    parameter SCALE = 4,            // Scaling factor for 6x8 char (e.g. 4 -> 24x32)
    parameter KERNING = 4,          // Pixel gap between characters
    parameter LEN = 4,              // Number of characters in the string
    parameter [LEN*8-1:0] TEXT = "" // The ASCII string (packed MSB first)
)(
    input wire clk_0,               // System clock
    input wire rst,                 // Reset signal
    
    input wire [9:0] pixel_x,       // Current horizontal pixel position
    input wire [9:0] pixel_y,       // Current vertical pixel position
    
    input wire [9:0] x_pos,         // Top-left X coordinate of the string
    input wire [9:0] y_pos,         // Top-left Y coordinate of the string
    
    output wire pixel_on            // High if current pixel is part of the text
    );

    wire [LEN-1:0] char_pixels;     // Aggregates 'pixel_on' signals from all chars

    // Generate loop to instantiate multiple text_display modules
    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1) begin : chars
            
            // Calculate X offset: (Previous Chars Width) + (Total Kerning Gaps)
            localparam X_OFFSET = i * (6 * SCALE + KERNING);
            
            // Extract char code from packed string (MSB is the first char)
            localparam [7:0] CHAR_VAL = TEXT[(LEN - 1 - i) * 8 +: 8];

            text_display #(.SCALE(SCALE)) t (
                .clk_0(clk_0),
                .rst(rst),
                .pixel_x(pixel_x), 
                .pixel_y(pixel_y),
                .x_pos(x_pos + X_OFFSET),  // Apply calculated offset
                .y_pos(y_pos),
                .char_code(CHAR_VAL[6:0]),      // Truncate to 7-bit ASCII
                .pixel_on(char_pixels[i])
            );
        end
    endgenerate

    // Combine all character signals into a single output
    assign pixel_on = |char_pixels;

endmodule