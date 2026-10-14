`timescale 1ns / 1ps

// Decides which part of the ALU result the LEDs show
module alu_fsm(
    input clk,
    input rst,
    input next,            // one-clock pulse per button press
    output reg [1:0] state
);

    parameter LOW  = 2'b00;   // show result[15:0]
    parameter HIGH = 2'b01;   // show result[31:16]
    parameter ZERO = 2'b10;   // show the Zero flag

    reg [1:0] next_state;

    // state register: reset goes back to LOW
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= LOW;
        else
            state <= next_state;
    end

    // each button press moves to the next view, then wraps around
    always @(*) begin
        case (state)
            LOW:     next_state = next ? HIGH : LOW;
            HIGH:    next_state = next ? ZERO : HIGH;
            ZERO:    next_state = next ? LOW  : ZERO;
            default: next_state = LOW;
        endcase
    end

endmodule