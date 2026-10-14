`timescale 1ns / 1ps

module ALU_top_tb;
    reg         clk = 0;
    reg         pbin = 0;
    reg         pbnext = 0;
    reg  [15:0] physical_sw = 16'd0;
    wire [15:0] physical_leds;
    integer     errors = 0;

    ALU_top #(.DEBOUNCE_MAX(4)) dut (
        .clk(clk), .pbin(pbin), .pbnext(pbnext),
        .physical_sw(physical_sw), .physical_leds(physical_leds)
    );

    always #5 clk = ~clk;

    initial begin
        #100;

        // low half of the result for each op
        physical_sw = 16'd0; #100; if (physical_leds !== 16'h0000) errors = errors + 1; // and
        physical_sw = 16'd1; #100; if (physical_leds !== 16'h1111) errors = errors + 1; // or
        physical_sw = 16'd2; #100; if (physical_leds !== 16'h1111) errors = errors + 1; // add
        physical_sw = 16'd3; #100; if (physical_leds !== 16'h1111) errors = errors + 1; // xor
        physical_sw = 16'd4; #100; if (physical_leds !== 16'h2020) errors = errors + 1; // sll
        physical_sw = 16'd5; #100; if (physical_leds !== 16'h0808) errors = errors + 1; // srl
        physical_sw = 16'd6; #100; if (physical_leds !== 16'h0F0F) errors = errors + 1; // sub
        physical_sw = 16'd7; #100; if (physical_leds !== 16'h0000) errors = errors + 1; // undefined

        // step through low -> high -> zero -> low on sll (result is not 0)
        physical_sw = 16'd4; #100;
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h2020) errors = errors + 1;   // high half
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;   // zero flag = 0
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h2020) errors = errors + 1;   // back to low

        // same on and (result is 0, so the zero flag lights LED 0)
        physical_sw = 16'd0; #100;
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;   // high half
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h0001) errors = errors + 1;   // zero flag = 1
        pbnext = 1; #200; pbnext = 0; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;   // back to low

        // reset while LEDs are lit
        physical_sw = 16'd2; #100;
        pbnext = 1; #200; pbnext = 0; #200;                    // high half, 1111
        pbin = 1; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;   // blanked while held
        pbin = 0; #200;
        if (physical_leds !== 16'h1111) errors = errors + 1;   // back to low

        // reset from the zero state, should come back to low and not stay on zero
        pbnext = 1; #200; pbnext = 0; #200;
        pbnext = 1; #200; pbnext = 0; #200;                    // zero view, LEDs 0
        pbin = 1; #200; pbin = 0; #200;
        if (physical_leds !== 16'h1111) errors = errors + 1;

        #100;
        $finish;
    end
endmodule