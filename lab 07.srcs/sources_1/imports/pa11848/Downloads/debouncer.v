`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Muddassir Ali

// Module Name: debouncer
// Project Name: Counter
// Target Devices: Baasys 3
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

// Cleans up a button: output only changes after the input has stayed
// different from it for DEBOUNCE_MAX clock cycles
module debouncer #(
    parameter DEBOUNCE_MAX = 1_000_000   // about 10 ms at 100 MHz
)(
    input      clk,
    input      pbin,
    output reg pbout = 1'b0
);

    reg [1:0]  sync  = 2'b00;    // lines the button up with the clock
    reg [31:0] count = 32'd0;

    always @(posedge clk) begin
        sync <= {sync[0], pbin};

        if (sync[1] == pbout)
            count <= 32'd0;                      // input agrees with output, restart count
        else if (count >= DEBOUNCE_MAX - 1) begin
            pbout <= sync[1];                    // input held long enough, accept it
            count <= 32'd0;
        end else
            count <= count + 1;
    end

endmodule