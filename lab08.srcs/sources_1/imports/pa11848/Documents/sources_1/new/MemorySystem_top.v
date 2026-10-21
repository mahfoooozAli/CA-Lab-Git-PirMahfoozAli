`timescale 1ns / 1ps

// FPGA top: switches -> data memory -> leds, all through the address decoder
module MemorySystem_top #(
    parameter DEBOUNCE_MAX = 1_000_000
)(
    input         clk,
    input         pbin,           // reset button (center)
    input         pbnext,         // save button (up), stores switches into memory
    input  [15:0] physical_sw,
    output [15:0] physical_leds
);

    wire        rst, save_db;
    wire [31:0] address, writeData, readData;
    wire        readEnable, writeEnable;
    wire [2:0]  state;

    // clean up both buttons
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_rst  (.clk(clk), .pbin(pbin), .pbout(rst));
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_save (.clk(clk), .pbin(pbnext), .pbout(save_db));

    // turn a held button into a single one-clock pulse
    reg save_q;
    always @(posedge clk) save_q <= save_db;
    wire save_pulse = save_db & ~save_q;

    // fsm plays the part of the processor
    mem_fsm fsm (
        .clk(clk), .rst(rst), .save(save_pulse), .readData(readData),
        .address(address), .readEnable(readEnable), .writeEnable(writeEnable),
        .writeData(writeData), .state(state)
    );

    addressDecoderTop mem_sys (
        .clk(clk), .rst(rst), .address(address),
        .readEnable(readEnable), .writeEnable(writeEnable),
        .writeData(writeData), .switches(physical_sw),
        .readData(readData), .leds(physical_leds)
    );

endmodule
