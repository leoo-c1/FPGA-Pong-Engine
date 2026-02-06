module input_bridge #(
    parameter BUTTONS = 4
)(
    input clk,                      // 50MHz clock
    input rst,                      // Reset button
    
    // User's chosen input mode
    input [1:0] input_mode,         // 0 = Buttons, 1 = Keyboard, 2 = PS4 controller
    
    // User inputs
    input [BUTTONS-1:0] btn_raw,    // Physical FPGA pushbuttons
    // input uart_rx,               // Will be added in future

    // Paddle control outputs
    output reg p1_up,
    output reg p1_down,
    output reg p2_up,
    output reg p2_down
);

    // Debounce the buttons
    wire [BUTTONS-1:0] btn_clean;
    
    button_debouncer #(.BUTTONS(BUTTONS)) db (
        .clk(clk),
        .rst(rst),
        .raw_signal(btn_raw),
        .debounced_signal(btn_clean)
    );

    always @(*) begin
        case (input_mode)
            2'b00: begin    // If we choose to use the pushbuttons as input
                // Invert signals because buttons are Active Low (0 = Pressed)
                p1_up   = ~btn_clean[0]; 
                p1_down = ~btn_clean[1];
                p2_up   = ~btn_clean[2];
                p2_down = ~btn_clean[3];
            end
            
            2'b01: begin    // If we choose to use the keyboard as input
                p1_up = 0; p1_down = 0; p2_up = 0; p2_down = 0;
                // Add logic later
            end

            default: begin
                p1_up = 0; p1_down = 0; p2_up = 0; p2_down = 0;
            end
        endcase
    end

endmodule