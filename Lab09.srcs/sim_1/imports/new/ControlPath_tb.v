`timescale 1ns / 1ps

module ControlPath_tb;
    reg  [6:0] opcode = 0;
    reg  [2:0] funct3 = 0;
    reg  [6:0] funct7 = 0;
    wire       RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;
    integer    errors = 0;

    MainControl main_ctrl(
        .opcode(opcode), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), .ALUOp(ALUOp)
    );

    ALUControl alu_ctrl(
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUCtrl)
    );

    // all outputs in one bus so they can be checked in one line
    // {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp, ALUControl}
    wire [11:0] outs = {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp, ALUCtrl};

    // puts one instruction on the inputs and checks the outputs 10ns later
    task check(input [8*4:1] name, input [6:0] op, input [2:0] f3, input [6:0] f7, input [11:0] expected);
        begin
            opcode = op; funct3 = f3; funct7 = f7;
            #10;
            if (outs === expected) $display("%s passed: outs = %b", name, outs);
            else begin
                $display("%s failed: outs = %b, expected %b", name, outs, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        //            name    opcode       funct3  funct7       RW AS MR MW MtR Br ALUOp ALUControl
        // R-type
        check("ADD",  7'b0110011, 3'b000, 7'b0000000, 12'b1_0_0_0_0_0_10_0010);
        check("SUB",  7'b0110011, 3'b000, 7'b0100000, 12'b1_0_0_0_0_0_10_0110);
        check("SLL",  7'b0110011, 3'b001, 7'b0000000, 12'b1_0_0_0_0_0_10_0100);
        check("SRL",  7'b0110011, 3'b101, 7'b0000000, 12'b1_0_0_0_0_0_10_0101);
        check("AND",  7'b0110011, 3'b111, 7'b0000000, 12'b1_0_0_0_0_0_10_0000);
        check("OR",   7'b0110011, 3'b110, 7'b0000000, 12'b1_0_0_0_0_0_10_0001);
        check("XOR",  7'b0110011, 3'b100, 7'b0000000, 12'b1_0_0_0_0_0_10_0011);

        // addi, funct7 is part of the immediate here so it must not turn it into sub
        check("ADDI", 7'b0010011, 3'b000, 7'b0100000, 12'b1_1_0_0_0_0_00_0010);

        // loads
        check("LW",   7'b0000011, 3'b010, 7'b0000000, 12'b1_1_1_0_1_0_00_0010);
        check("LH",   7'b0000011, 3'b001, 7'b0000000, 12'b1_1_1_0_1_0_00_0010);
        check("LB",   7'b0000011, 3'b000, 7'b0000000, 12'b1_1_1_0_1_0_00_0010);

        // stores
        check("SW",   7'b0100011, 3'b010, 7'b0000000, 12'b0_1_0_1_0_0_00_0010);
        check("SH",   7'b0100011, 3'b001, 7'b0000000, 12'b0_1_0_1_0_0_00_0010);
        check("SB",   7'b0100011, 3'b000, 7'b0000000, 12'b0_1_0_1_0_0_00_0010);

        // branch
        check("BEQ",  7'b1100011, 3'b000, 7'b0000000, 12'b0_0_0_0_0_1_01_0110);

        // unknown opcode, everything should be off
        check("NONE", 7'b1111111, 3'b000, 7'b0000000, 12'b0_0_0_0_0_0_00_0010);

        $display("errors = %0d", errors);
        $finish;
    end
endmodule
