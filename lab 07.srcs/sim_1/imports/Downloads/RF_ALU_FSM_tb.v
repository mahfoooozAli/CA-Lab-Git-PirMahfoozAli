`timescale 1ns / 1ps

module RF_ALU_FSM_tb;

    reg clk = 0;
    reg rst, start;

    wire WriteEnable, useALU, zero;
    wire [4:0] rs1, rs2, rd;
    wire [3:0] ALUControl, state;
    wire [31:0] constant, ReadData1, ReadData2, ALUResult;

    // write back either the alu result or the constant from the fsm
    wire [31:0] WriteData = useALU ? ALUResult : constant;

    RegisterFile rf(
        .clk(clk), .rst(rst), .WriteEnable(WriteEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    // change port names to match your alu
    ALU alu(
        .A(ReadData1), .B(ReadData2), .ALUControl(ALUControl),
        .ALUResult(ALUResult), .Zero(zero)
    );

    rf_alu_fsm fsm(
        .clk(clk), .rst(rst), .en(1'b1), .start(start), .zero(zero),
        .WriteEnable(WriteEnable), .rs1(rs1), .rs2(rs2), .rd(rd),
        .ALUControl(ALUControl), .useALU(useALU), .constant(constant), .state(state)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1; start = 0;
        #10 rst = 0; start = 1;
        #10 start = 0;

        // read after write: x13 written in RAW_WRITE, should show up in RAW_READ
        wait (state == 8);
        #1;
        if (ReadData1 == 32'hCAFEBABE) $display("read after write passed: x13 = %h", ReadData1);
        else $display("read after write failed: x13 = %h", ReadData1);

        // wait till fsm is done then check everything
        wait (state == 9);
        #1;
        if (rf.regs[4] == 32'h11111111) $display("ADD passed: x4 = %h", rf.regs[4]);
        else $display("ADD failed: x4 = %h", rf.regs[4]);

        if (rf.regs[5] == 32'h0F0F0F0F) $display("SUB passed: x5 = %h", rf.regs[5]);
        else $display("SUB failed: x5 = %h", rf.regs[5]);

        if (rf.regs[6] == 32'h00000000) $display("AND passed: x6 = %h", rf.regs[6]);
        else $display("AND failed: x6 = %h", rf.regs[6]);

        if (rf.regs[7] == 32'h11111111) $display("OR passed: x7 = %h", rf.regs[7]);
        else $display("OR failed: x7 = %h", rf.regs[7]);

        if (rf.regs[8] == 32'h11111111) $display("XOR passed: x8 = %h", rf.regs[8]);
        else $display("XOR failed: x8 = %h", rf.regs[8]);

        // shift amount is x2[4:0] = 1
        if (rf.regs[9] == 32'h20202020) $display("SLL passed: x9 = %h", rf.regs[9]);
        else $display("SLL failed: x9 = %h", rf.regs[9]);

        if (rf.regs[10] == 32'h08080808) $display("SRL passed: x10 = %h", rf.regs[10]);
        else $display("SRL failed: x10 = %h", rf.regs[10]);

        // beq: x11 should be 1 (equal), x12 should be 0 (not equal)
        if (rf.regs[11] == 1 && rf.regs[12] == 0) $display("BEQ passed: x11 = %h, x12 = %h", rf.regs[11], rf.regs[12]);
        else $display("BEQ failed: x11 = %h, x12 = %h", rf.regs[11], rf.regs[12]);

        $finish;
    end

endmodule
