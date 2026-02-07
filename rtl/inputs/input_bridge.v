module input_bridge #(
    parameter BUTTONS = 4
)(
    input clk,                      // 50MHz clock
    input rst,                      // Reset button
    
    // User's chosen input mode
    input [1:0] input_mode,         // 0 = Buttons, 1 = Keyboard, 2 = PS4 controller
    
    // User inputs
    input [BUTTONS-1:0] btn_raw,    // Physical FPGA pushbuttons
    input uart_rx,                  // Receives keyboard or PS4 controller input

    // Paddle control outputs
    output reg p1_up,
    output reg p1_down,
    output reg p2_up,
    output reg p2_down,

    output reg start_trigger
);

    // Debounce the buttons
    wire [BUTTONS-1:0] btn_clean;
    
    button_debouncer #(.BUTTONS(BUTTONS)) db (
        .clk(clk),
        .rst(rst),
        .raw_signal(btn_raw),
        .debounced_signal(btn_clean)
    );

    wire uart_rx_valid;             // Whether we received valid data recieved and it is available
    wire [7:0] uart_rx_data;        // The recieved uart data

    uart_rx #(
        .BIT_RATE(115200)
        ) receive_keyboard (
        .clk(clk),
        .resetn(rst),
        .uart_rxd(uart_rx),
        .uart_rx_en(1'b1),
        .uart_rx_valid(uart_rx_valid),
        .uart_rx_data(uart_rx_data)
    );

    // UART state
    reg uart_p1_up = 0;
    reg uart_p1_down = 0;
    reg uart_p2_up = 0;
    reg uart_p2_down = 0;

    always @(posedge clk) begin
        if (!rst) begin
            uart_p1_up <= 0;
            uart_p1_down <= 0;
            uart_p2_up <= 0;
            uart_p2_down <= 0;
            start_trigger <= 0;
        end else if (uart_rx_valid) begin
            start_trigger <= 0;             // Default to zero

            case (uart_rx_data)
                // Player 1
                8'h57: uart_p1_up   <= 1'b1;    // 'W'
                8'h77: uart_p1_up   <= 1'b0;    // 'w'
                8'h53: uart_p1_down <= 1'b1;    // 'S'
                8'h73: uart_p1_down <= 1'b0;    // 's'
                
                // Player 2
                8'h49: uart_p2_up   <= 1'b1;    // 'I'
                8'h69: uart_p2_up   <= 1'b0;    // 'i'
                8'h4B: uart_p2_down <= 1'b1;    // 'K'
                8'h6B: uart_p2_down <= 1'b0;    // 'k'

                // Start trigger
                8'hAA: start_trigger <= 1'b1;   // Start code
            endcase
        end
    end

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
                p1_up   = uart_p1_up;
                p1_down = uart_p1_down;
                p2_up   = uart_p2_up;
                p2_down = uart_p2_down;
            end

            default: begin
                p1_up = 0; p1_down = 0; p2_up = 0; p2_down = 0;
            end
        endcase
    end

endmodule