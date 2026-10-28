`timescale 1ns / 1ps

// main control unit, looks only at the opcode
//   R-type (add, sub, sll, srl, and, or, xor) : 0110011
//   I-type (addi)                             : 0010011
//   load   (lw, lh, lb)                       : 0000011
//   store  (sw, sh, sb)                       : 0100011
//   branch (beq)                              : 1100011
module MainControl(
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg   ALUSrc,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemtoReg,
    output reg   Branch,
    output reg [1:0] ALUOp
);

    always @(*) begin
        // default for unknown opcodes, nothing gets written
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            7'b0110011: begin           // R-type
                RegWrite = 1'b1;
                ALUOp    = 2'b10;       // alu control uses funct3 and funct7
            end
            7'b0010011: begin           // addi
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;        // second operand is the immediate
                ALUOp    = 2'b00;       // add
            end
            7'b0000011: begin           // lw, lh, lb
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;        // write back memory data
                ALUOp    = 2'b00;       // add for the address
            end
            7'b0100011: begin           // sw, sh, sb
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;       // add for the address
            end                         // MemtoReg is x, left at 0
            7'b1100011: begin           // beq
                Branch   = 1'b1;
                ALUOp    = 2'b01;       // sub, zero flag says if equal
            end                         // MemtoReg is x, left at 0
        endcase
    end

endmodule
