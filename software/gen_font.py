import pygame
import sys
import os

# Setup
OUTPUT_FILE = "font_rom.v"
FONT_FILE = "Bm437_Portfolio_6x8.otb"
FONT_SIZE = 8
CHAR_WIDTH = 6
CHAR_HEIGHT = 8

def generate_verilog():
    pygame.font.init()                                  # Initialize Pygame font module

    # Path handling to find the font file in the script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    font_path = os.path.join(script_dir, FONT_FILE)

    print(f"Loading font...")
    font = pygame.font.Font(font_path, FONT_SIZE)       # Load font (Size 8 matches OTB height)

    with open(OUTPUT_FILE, "w") as f:
        # Module Header
        f.write(f"module font_rom (\n")
        f.write(f"    input [6:0] char_code,\n")
        f.write(f"    input [2:0] row,\n")
        f.write(f"    output reg [{CHAR_WIDTH-1}:0] row_bits\n")
        f.write(f");\n\n")
        f.write(f"    always @(*) begin\n")
        f.write(f"        case (char_code)\n")

        for ascii_val in range(32, 127):
            char = chr(ascii_val)
            
            # Render character (Anti-aliasing disabled, white text)
            surface = font.render(char, False, (255, 255, 255))
            
            glyph_w = surface.get_width()               # Get rendered width
            glyph_h = surface.get_height()              # Get rendered height
            
            # Auto-centering logic
            x_offset = (CHAR_WIDTH - glyph_w) // 2      # Center horizontally
            y_offset = 1                                # Shift down 1px (Row 0 blank for spacing)

            f.write(f"            7'd{ascii_val}: begin // '{char}'\n")
            f.write(f"                case (row)\n")
            
            for y in range(CHAR_HEIGHT):
                bits = ""
                for x in range(CHAR_WIDTH):
                    # Convert box coordinates to glyph coordinates
                    sample_x = x - x_offset
                    sample_y = y - y_offset
                    
                    pixel_on = False
                    
                    # Bounds check to prevent reading outside surface
                    if (0 <= sample_x < glyph_w) and (0 <= sample_y < glyph_h):
                        # Check red channel (index 0) > 128 for white pixel
                        if surface.get_at((sample_x, sample_y))[0] > 128:
                            pixel_on = True
                    
                    bits += "1" if pixel_on else "0"
                
                f.write(f"                    3'd{y}: row_bits = {CHAR_WIDTH}'b{bits};\n")
            
            f.write(f"                    default: row_bits = {CHAR_WIDTH}'b000000;\n")
            f.write(f"                endcase\n")
            f.write(f"            end\n")

        f.write(f"            default: row_bits = {CHAR_WIDTH}'b000000;\n")
        f.write(f"        endcase\n")
        f.write(f"    end\n")
        f.write(f"endmodule\n")

    print(f"Generated {OUTPUT_FILE}.")

if __name__ == "__main__":
    generate_verilog()