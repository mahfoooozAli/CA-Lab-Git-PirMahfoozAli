`timescale 1ns / 1ps

// Memory system that the processor talks to
module addressDecoderTop(
    input         clk, rst,
    input  [31:0] address,
    input         readEnable, writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,

    output [31:0] readData,
    output [15:0] leds
);

    wire        DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable;
    wire [31:0] memReadData;
    wire [31:0] switchReadData;

    // only the lower 10 bits of the address are used
    AddressDecoder decoder (
        .address(address[9:0]), .readEnable(readEnable), .writeEnable(writeEnable),
        .DataMemWrite(DataMemWrite), .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite), .SwitchReadEnable(SwitchReadEnable)
    );

    DataMemory dmem (
        .clk(clk), .rst(rst), .address(address),
        .writedata(writeData), .memwrite(DataMemWrite), .readdata(memReadData)
    );

    // the "switches" module is the LED writer (names are swapped from Lab 5)
    switches led_if (
        .clk(clk), .rst(rst),
        .writeData(writeData), .writeEnable(LEDWrite), .readEnable(1'b0),
        .memAddress(address[31:2]), .readData(), .leds(leds)
    );

    // the "leds" module is the switch reader (names are swapped from Lab 5)
    leds sw_if (
        .clk(clk), .rst(rst), .btns(16'd0),
        .writeData(32'd0), .writeEnable(1'b0), .readEnable(SwitchReadEnable),
        .memAddress(address[31:2]), .switches(switches), .readData(switchReadData)
    );

    // send back data from whichever device was read, 0 otherwise
    // memory and switch reads are clocked, so the data shows up one clock after the address
    assign readData = DataMemRead      ? memReadData    :
                      SwitchReadEnable ? switchReadData :
                      32'd0;

endmodule
