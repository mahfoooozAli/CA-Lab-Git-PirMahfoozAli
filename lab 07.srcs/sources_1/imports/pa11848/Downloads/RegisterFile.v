`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output [31:0] ReadData1,
    output [31:0] ReadData2
);

    reg [31:0] regs [31:0];   // 32 registers of 32 bits
    integer i;

    // reading is not clocked, x0 always gives 0
    assign ReadData1 = (rs1 == 0) ? 0 : regs[rs1];
    assign ReadData2 = (rs2 == 0) ? 0 : regs[rs2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // clear all registers
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 0;
        end
        else if (WriteEnable && rd != 0) begin
            // write on clock edge, writes to x0 are ignored
            regs[rd] <= WriteData;
        end
    end

endmodule
