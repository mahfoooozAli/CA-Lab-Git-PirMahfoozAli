`timescale 1ns / 1ps

module MemorySystem_top_tb;
    reg         clk = 0;
    reg         pbin = 0;
    reg         pbnext = 0;
    reg  [15:0] physical_sw = 16'd0;
    wire [15:0] physical_leds;
    integer     errors = 0;

    MemorySystem_top #(.DEBOUNCE_MAX(4)) dut (
        .clk(clk), .pbin(pbin), .pbnext(pbnext),
        .physical_sw(physical_sw), .physical_leds(physical_leds)
    );

    always #5 clk = ~clk;

    initial begin
        pbin = 1; #200; pbin = 0; #200;

        // switches change but nothing is saved yet, leds stay 0
        physical_sw = 16'h1234; #300;
        if (physical_leds !== 16'h0000) errors = errors + 1;

        // press save, leds show the switch value
        pbnext = 1; #200; pbnext = 0; #300;
        if (physical_leds !== 16'h1234) errors = errors + 1;

        // change switches without saving, leds keep the old value from memory
        physical_sw = 16'h00FF; #300;
        if (physical_leds !== 16'h1234) errors = errors + 1;

        // save again
        pbnext = 1; #200; pbnext = 0; #300;
        if (physical_leds !== 16'h00FF) errors = errors + 1;

        // reset, memory keeps its data so leds come back to the saved value
        pbin = 1; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;  // blank while held
        pbin = 0; #300;
        if (physical_leds !== 16'h00FF) errors = errors + 1;

        $display("errors = %0d", errors);
        #100;
        $finish;
    end
endmodule
