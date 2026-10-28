`timescale 1ns / 1ps

// fsm that tests the control path on the board
// waits for the load button, reads the instruction fields from the switches,
// lets the control units decode them, then writes the control signals to the leds
module control_fsm(
    input             clk,
    input             rst,
    input             load,          // one-clock pulse when the load button is pressed
    input      [15:0] sw_value,      // switch data from the lab 5 switch module
    input      [11:0] control_bits,  // outputs of the main control and alu control
    output reg [6:0]  opcode,
    output reg [2:0]  funct3,
    output reg [6:0]  funct7,
    output reg [11:0] led_bits,
    output reg        led_write,
    output reg [1:0]  state
);

    parameter WAIT    = 2'b00;   // wait for the load button
    parameter READ_SW = 2'b01;   // save opcode, funct3 and funct7 from the switches
    parameter DECODE  = 2'b10;   // control units decode, save their outputs
    parameter SHOW    = 2'b11;   // write the saved control signals to the leds

    reg [1:0] next_state;
    reg       load_req;          // remembers a button press until it is used

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= WAIT;
        else
            state <= next_state;
    end

    // next state
    always @(*) begin
        case (state)
            WAIT:    next_state = load_req ? READ_SW : WAIT;
            READ_SW: next_state = DECODE;
            DECODE:  next_state = SHOW;
            SHOW:    next_state = WAIT;
            default: next_state = WAIT;
        endcase
    end

    // registers that the fsm fills in
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            opcode   <= 7'd0;
            funct3   <= 3'd0;
            funct7   <= 7'd0;
            led_bits <= 12'd0;
            load_req <= 1'b0;
        end
        else begin
            // sw[6:0] = opcode, sw[9:7] = funct3, sw[10] = funct7 bit 5 (the only bit we need)
            if (state == READ_SW) begin
                opcode <= sw_value[6:0];
                funct3 <= sw_value[9:7];
                funct7 <= {1'b0, sw_value[10], 5'b00000};
            end
            if (state == DECODE)
                led_bits <= control_bits;

            if (load)
                load_req <= 1'b1;
            else if (state == READ_SW)
                load_req <= 1'b0;
        end
    end

    // leds are only written in SHOW
    always @(*) begin
        led_write = (state == SHOW);
    end

endmodule
