`timescale 1ns / 1ps

module MemorySystem_tb;
    reg         clk = 0;
    reg         rst = 0;
    reg  [31:0] address = 0;
    reg         readEnable = 0;
    reg         writeEnable = 0;
    reg  [31:0] writeData = 0;
    reg  [15:0] switches = 16'd0;
    wire [31:0] readData;
    wire [15:0] leds;
    integer     errors = 0;

    addressDecoderTop dut (
        .clk(clk), .rst(rst), .address(address),
        .readEnable(readEnable), .writeEnable(writeEnable),
        .writeData(writeData), .switches(switches),
        .readData(readData), .leds(leds)
    );

    always #5 clk = ~clk;

    // inputs change every 10ns and the clock edge is in the middle,
    // so a read is checked 10ns later once the clocked data has come out
    initial begin
        rst = 1; #20; rst = 0; #10;

        // write 2 values into data memory, leds should not change
        address = 32'd0; writeData = 32'hAAAA5555; writeEnable = 1; #1;
        if (dut.DataMemWrite !== 1 || dut.LEDWrite !== 0) errors = errors + 1;
        #9;
        address = 32'd511; writeData = 32'h12345678; #10;
        writeEnable = 0;
        if (leds !== 16'h0000) errors = errors + 1;

        // read them back
        address = 32'd0; readEnable = 1; #1;
        if (dut.DataMemRead !== 1 || dut.SwitchReadEnable !== 0) errors = errors + 1;
        #9;  if (readData !== 32'hAAAA5555) errors = errors + 1;
        address = 32'd511; #10; if (readData !== 32'h12345678) errors = errors + 1;

        // 0x106 = 262 is still data memory (0 to 511)
        readEnable = 0;
        address = 32'h106; writeData = 32'd206; writeEnable = 1; #10;
        writeEnable = 0; readEnable = 1; #10;
        if (readData !== 32'd206) errors = errors + 1;
        readEnable = 0;

        // write to leds (0x210 = 528), memory write should stay off
        address = 32'h210; writeData = 32'h0000BEEF; writeEnable = 1; #1;
        if (dut.LEDWrite !== 1 || dut.DataMemWrite !== 0) errors = errors + 1;
        #9;
        writeEnable = 0; #10;
        if (leds !== 16'hBEEF) errors = errors + 1;
        address = 32'd0; readEnable = 1; #10;
        if (readData !== 32'hAAAA5555) errors = errors + 1;   // memory not touched
        readEnable = 0;

        // read the switches (0x350 = 848)
        switches = 16'hA5C3;
        address = 32'h350; readEnable = 1; #1;
        if (dut.SwitchReadEnable !== 1 || dut.DataMemRead !== 0) errors = errors + 1;
        #9;  if (readData !== 32'h0000A5C3) errors = errors + 1;
        readEnable = 0; #1;
        if (readData !== 32'd0) errors = errors + 1;          // nothing selected gives 0
        #9;

        // writing to the switch address should do nothing
        address = 32'd800; writeData = 32'h00001111; writeEnable = 1; #1;
        if (dut.DataMemWrite !== 0 || dut.LEDWrite !== 0) errors = errors + 1;
        #9; writeEnable = 0; #10;
        if (leds !== 16'hBEEF) errors = errors + 1;

        // upper address bits are ignored (1024 + 0 is the same as 0)
        address = 32'd1024; readEnable = 1; #10;
        if (readData !== 32'hAAAA5555) errors = errors + 1;
        readEnable = 0;

        // reset clears the leds and the memory output, data stays in memory
        rst = 1; #10;
        if (leds !== 16'h0000 || dut.memReadData !== 32'd0) errors = errors + 1;
        rst = 0; #10;
        address = 32'd511; readEnable = 1; #10;
        if (readData !== 32'h12345678) errors = errors + 1;
        readEnable = 0;

        $display("errors = %0d", errors);
        #10;
        $finish;
    end
endmodule
