`timescale 1ns / 1ps

module Fsm(
    input clk,             // clock signal
    input rst,             // reset signal
    input switch,          // 1 when switch != 0
    input count_zero,      // 1 when counter == 0
    output reg load,       // tells counter to load the switches value
    output reg count_dec,  // tells counter to decrement
    output reg [1:0] state
);

    parameter Idle  = 2'b00;
    parameter Count = 2'b01;

    reg [1:0] next_state;

    // State register: updates on every clock edge
   always @(posedge clk or posedge rst) begin
    if (rst)
        state <= Idle;
    else
        state <= next_state;
end

    // Next-state logic
    always @(*) begin
        case (state)
            Idle: begin
                if (switch)
                    next_state = Count;
                else
                    next_state = Idle;
            end

            Count: begin
                if (count_zero)
                    next_state = Idle;
                else
                    next_state = Count;
            end

            default: begin
                next_state = Idle;
            end
        endcase
    end

    // Output logic
    always @(*) begin
        load      = 1'b0;
        count_dec = 1'b0;

        case (state)
            Idle: begin
                if (switch)
                    load = 1'b1;
                else
                    load = 1'b0;
            end

            Count: begin
                count_dec = 1'b1;
            end

            default: begin
                load      = 1'b0;
                count_dec = 1'b0;
            end
        endcase
    end

endmodule
