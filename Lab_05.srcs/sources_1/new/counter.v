`timescale 1ns / 1ps

module counter(
    input clk,
    input rst,
    input load,
    input count_dec,
    input [15:0] switches,
    output reg [15:0] count,
    output count_zero
);

   always @(posedge clk or posedge rst) begin
    if (rst)
        count <= 16'b0;
    else if (load)
        count <= switches;
    else if (count_dec && count != 0)
        count <= count - 1'b1;
end
    assign count_zero = (count == 16'b0);

endmodule