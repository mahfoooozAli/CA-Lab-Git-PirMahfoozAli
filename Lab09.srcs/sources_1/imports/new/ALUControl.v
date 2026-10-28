`timescale 1ns / 1ps

// alu control unit, codes are the same ones our lab 7 alu uses
//   0000 and, 0001 or, 0010 add, 0011 xor, 0100 sll, 0101 srl, 0110 sub
module ALUControl(
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;            // loads, stores, addi -> add
            2'b01: ALUControl = 4'b0110;            // beq -> sub
            2'b10: begin                            // R-type, look at funct3
                case (funct3)
                    3'b000: if (funct7[5])
                                ALUControl = 4'b0110;   // sub
                            else
                                ALUControl = 4'b0010;   // add
                    3'b001: ALUControl = 4'b0100;       // sll
                    3'b101: ALUControl = 4'b0101;       // srl
                    3'b100: ALUControl = 4'b0011;       // xor
                    3'b110: ALUControl = 4'b0001;       // or
                    3'b111: ALUControl = 4'b0000;       // and
                    default: ALUControl = 4'b0010;      // not supported, add
                endcase
            end
            default: ALUControl = 4'b0010;          // 11 is not used, add
        endcase
    end

endmodule
