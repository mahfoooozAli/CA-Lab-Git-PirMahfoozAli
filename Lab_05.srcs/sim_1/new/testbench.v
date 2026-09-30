`timescale 1ns/1ps

module top_tb;

    reg clk;
    reg pbin;
    reg [15:0] physical_sw;

    wire [15:0] physical_leds;

    // Instantiate the top module
    top_fsm_system top0 (
        .clk          (clk),
        .pbin         (pbin),
        .physical_sw  (physical_sw),
        .physical_leds(physical_leds)
    );

    // Clock: toggles every 5ns
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        clk = 0;
        pbin = 0;
        physical_sw = 16'd0;

        #2  pbin = 1;              // press reset (2ns so the reset edge is seen)
        #48 pbin = 0;              // release reset at 50ns

        // Test 1: nonzero switch -> load, count down to 0, back to Idle
        #100 physical_sw = 16'd5;  // at 150ns
        #150 physical_sw = 16'd0;  // at 300ns, switch is ignored during countdown anyway
        #300;                      // at 600ns, countdown finished, back in Idle

        // Test 2: switch stays 0 -> should stay in Idle
        #100;                      // at 700ns

        // Test 3: load 8, then press reset mid-countdown
        physical_sw = 16'd8;       // at 700ns
        #150 physical_sw = 16'd0;  // at 850ns
        #80  pbin = 1;             // at 930ns, reset mid-count, leds should go to 0
        #20  pbin = 0;             // at 950ns

        #200 $finish;
    end

endmodule