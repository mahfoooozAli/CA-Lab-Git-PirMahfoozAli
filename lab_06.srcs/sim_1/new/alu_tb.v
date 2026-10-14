`timescale 1ns / 1ps

module ALU_tb;
    reg  [31:0] A, B;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;
    integer     errors = 0;

    ALU dut (.A(A), .B(B), .ALUControl(ALUControl),
             .ALUResult(ALUResult), .Zero(Zero));

    initial begin
        // lab operands
        A = 32'h10101010; B = 32'h01010101;
        ALUControl = 4'b0000; #10; if (ALUResult !== 32'h00000000) errors = errors + 1; // and
        ALUControl = 4'b0001; #10; if (ALUResult !== 32'h11111111) errors = errors + 1; // or
        ALUControl = 4'b0010; #10; if (ALUResult !== 32'h11111111) errors = errors + 1; // add
        ALUControl = 4'b0011; #10; if (ALUResult !== 32'h11111111) errors = errors + 1; // xor
        ALUControl = 4'b0110; #10; if (ALUResult !== 32'h0F0F0F0F) errors = errors + 1; // sub

        // shifts
        B = 32'h00000004;
        ALUControl = 4'b0100; #10; if (ALUResult !== 32'h01010100) errors = errors + 1; // sll
        ALUControl = 4'b0101; #10; if (ALUResult !== 32'h01010101) errors = errors + 1; // srl

        // A == B, Zero should go high (beq)
        A = 32'h0000000F; B = 32'h0000000F;
        ALUControl = 4'b0110; #10; if (ALUResult !== 0 || Zero !== 1) errors = errors + 1;

        // add wraps to 0
        A = 32'hFFFFFFFF; B = 32'h00000001;
        ALUControl = 4'b0010; #10; if (ALUResult !== 0 || Zero !== 1) errors = errors + 1;

        // add overflow
        A = 32'h7FFFFFFF; B = 32'h00000001;
        ALUControl = 4'b0010; #10; if (ALUResult !== 32'h80000000) errors = errors + 1;

        // shift by 31
        A = 32'h00000001; B = 32'h0000001F;
        ALUControl = 4'b0100; #10; if (ALUResult !== 32'h80000000) errors = errors + 1;
        A = 32'h80000000;
        ALUControl = 4'b0101; #10; if (ALUResult !== 32'h00000001) errors = errors + 1;

        // upper bits of B ignored for shifts (B[4:0] = 4)
        A = 32'h00000001; B = 32'hFFFFFFE4;
        ALUControl = 4'b0100; #10; if (ALUResult !== 32'h00000010) errors = errors + 1;

        // undefined op
        ALUControl = 4'b1111; #10; if (ALUResult !== 0) errors = errors + 1;

        #10;
        $finish;
    end
endmodule