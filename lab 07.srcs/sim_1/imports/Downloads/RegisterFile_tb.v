`timescale 1ns / 1ps

module RegisterFile_tb;

    reg clk = 0;
    reg rst, WriteEnable;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    RegisterFile uut(
        .clk(clk), .rst(rst), .WriteEnable(WriteEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    always #5 clk = ~clk;

    initial begin
        // reset first
        rst = 1; WriteEnable = 0; rs1 = 0; rs2 = 0; rd = 0; WriteData = 0;
        #10 rst = 0;

        // test 1: write DEADBEEF to x5, read it on both ports
        WriteEnable = 1; rd = 5; WriteData = 32'hDEADBEEF; rs1 = 5; rs2 = 5;
        #10;
        if (ReadData1 == 32'hDEADBEEF && ReadData2 == 32'hDEADBEEF) $display("test 1 passed: x5 = %h", ReadData1);
        else $display("test 1 failed: x5 = %h", ReadData1);

        // test 2: write to x0, should still be 0
        rd = 0; WriteData = 32'h12345678; rs1 = 0;
        #10;
        if (ReadData1 == 0) $display("test 2 passed: x0 = %h", ReadData1);
        else $display("test 2 failed: x0 = %h", ReadData1);

        // test 3: write x6, then read x5 and x6 at the same time
        rd = 6; WriteData = 32'hA5A5A5A5; rs1 = 5; rs2 = 6;
        #10;
        if (ReadData1 == 32'hDEADBEEF && ReadData2 == 32'hA5A5A5A5) $display("test 3 passed: x5 = %h, x6 = %h", ReadData1, ReadData2);
        else $display("test 3 failed: x5 = %h, x6 = %h", ReadData1, ReadData2);

        // test 4: overwrite x5 with a new value
        rd = 5; WriteData = 32'h0BADF00D; rs1 = 5;
        #10;
        if (ReadData1 == 32'h0BADF00D) $display("test 4 passed: x5 = %h", ReadData1);
        else $display("test 4 failed: x5 = %h", ReadData1);

        // test 5: reset should clear x5 and x6
        WriteEnable = 0; rst = 1; rs1 = 5; rs2 = 6;
        #10 rst = 0;
        if (ReadData1 == 0 && ReadData2 == 0) $display("test 5 passed: x5 = %h, x6 = %h", ReadData1, ReadData2);
        else $display("test 5 failed: x5 = %h, x6 = %h", ReadData1, ReadData2);

        $finish;
    end

endmodule
