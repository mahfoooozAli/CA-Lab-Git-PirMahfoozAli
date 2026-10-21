`timescale 1ns / 1ps

// 512 x 32 data memory
module DataMemory(
    input         clk, rst,
    input  [31:0] address,
    input  [31:0] writedata,
    input         memwrite,       // 1 = write, 0 = read
    output reg [31:0] readdata
);

    // register declaration
    reg [31:0] mem [0:511];
    integer i;

    // start with every location at 0 (vivado uses this as the memory's initial value)
    initial begin
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 32'd0;
    end

    // read and write both happen on the clock edge
    // only address[8:0] is used since there are 512 locations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            readdata <= 32'b0;
        end
        else if (memwrite == 1'b1) begin
            mem[address[8:0]] <= writedata;     // write
        end
        else begin
            readdata <= mem[address[8:0]];      // read
        end
    end

endmodule
