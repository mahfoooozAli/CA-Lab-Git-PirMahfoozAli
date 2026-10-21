`timescale 1ns / 1ps

// 1 bit alu
module alu_1bit (
    input        a, b, cin,
    input        binv,        // 1 for sub, inverts b
    input  [3:0] op,
    input        shift_bit,   // bit coming from the shifter
    output reg   result,
    output       cout
);
    wire bx  = b ^ binv;
    wire sum = a ^ bx ^ cin;
    assign cout = (a & bx) | (cin & (a ^ bx));

    always @(*) begin
        case (op)
            4'b0000: result = a & b;        // and
            4'b0001: result = a | b;        // or
            4'b0010,
            4'b0110: result = sum;          // add and sub
            4'b0011: result = a ^ b;        // xor
            4'b0100,
            4'b0101: result = shift_bit;    // sll and srl
            default: result = 1'b0;
        endcase
    end
endmodule

// shifter for sll and srl
module shifter_32 (
    input  [31:0] in,
    input  [4:0]  shamt,
    input         right,      // 0 = sll, 1 = srl
    output reg [31:0] out
);
    always @(*) begin
        if (right)
            out = in >> shamt;
        else
            out = in << shamt;
    end
endmodule

// 32 bit alu made from 32 one bit alus
module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] ALUResult,
    output        Zero
);
    wire        sub = (ALUControl == 4'b0110);   // sub, also used for beq
    wire [31:0] shifted;
    wire [32:0] carry;

    assign carry[0] = sub;   // +1 for twos complement

    shifter_32 sh (.in(A), .shamt(B[4:0]), .right(ALUControl[0]), .out(shifted));

    // loop that makes 32 copies of alu_1bit and connects the carries
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : slice
            alu_1bit s (
                .a(A[i]), .b(B[i]), .cin(carry[i]), .binv(sub),
                .op(ALUControl), .shift_bit(shifted[i]),
                .result(ALUResult[i]), .cout(carry[i+1])
            );
        end
    endgenerate

    assign Zero = (ALUResult == 32'b0);   // 1 when result is 0
endmodule
