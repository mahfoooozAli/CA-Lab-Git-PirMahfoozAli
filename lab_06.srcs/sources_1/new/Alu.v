`timescale 1ns / 1ps

// One bit of the ALU: logic ops, a full adder, and a pick-one output
module alu_1bit (
    input        a, b, cin,
    input        binv,        // 1 for SUB: flips b so a + ~b + 1 = a - b
    input  [3:0] op,
    input        shift_bit,   // this bit's value from the shifter
    output reg   result,
    output       cout
);
    wire bx  = b ^ binv;                              // b or inverted b
    wire sum = a ^ bx ^ cin;                          // full adder sum
    assign cout = (a & bx) | (cin & (a ^ bx));        // full adder carry out

    always @(*) begin
        case (op)
            4'b0000: result = a & b;          // AND
            4'b0001: result = a | b;          // OR
            4'b0010,
            4'b0110: result = sum;            // ADD and SUB use the adder
            4'b0011: result = a ^ b;          // XOR
            4'b0100,
            4'b0101: result = shift_bit;      // SLL and SRL come from the shifter
            default: result = 1'b0;           // undefined op gives 0
        endcase
    end
endmodule

// Barrel shifter: 5 stages, stage k shifts by 2^k when shamt[k] is 1
module shifter_32 (
    input  [31:0] in,
    input  [4:0]  shamt,
    input         right,      // 0 = shift left (SLL), 1 = shift right (SRL)
    output [31:0] out
);
    wire [31:0] s0, s1, s2, s3;
    assign s0  = shamt[0] ? (right ? {1'b0,  in[31:1]}  : {in[30:0], 1'b0})  : in;
    assign s1  = shamt[1] ? (right ? {2'b0,  s0[31:2]}  : {s0[29:0], 2'b0})  : s0;
    assign s2  = shamt[2] ? (right ? {4'b0,  s1[31:4]}  : {s1[27:0], 4'b0})  : s1;
    assign s3  = shamt[3] ? (right ? {8'b0,  s2[31:8]}  : {s2[23:0], 8'b0})  : s2;
    assign out = shamt[4] ? (right ? {16'b0, s3[31:16]} : {s3[15:0], 16'b0}) : s3;
endmodule

// 32-bit ALU built from 32 one-bit slices, carry rippling from bit 0 up
module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALUControl,
    output [31:0] ALUResult,
    output        Zero
);
    wire        sub = (ALUControl == 4'b0110);   // SUB (also used for BEQ)
    wire [31:0] shifted;
    wire [32:0] carry;

    assign carry[0] = sub;                       // the +1 for two's complement

    shifter_32 sh (.in(A), .shamt(B[4:0]), .right(ALUControl[0]), .out(shifted));

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

    assign Zero = ~|ALUResult;                   // 1 when every result bit is 0
endmodule