`timescale 1ns / 1ps

module ControlPath_top_tb;
    reg         clk = 0;
    reg         pbin = 0;
    reg         pbnext = 0;
    reg  [15:0] physical_sw = 16'd0;
    wire [15:0] physical_leds;
    integer     errors = 0;

    ControlPath_top #(.DEBOUNCE_MAX(4)) dut (
        .clk(clk), .pbin(pbin), .pbnext(pbnext),
        .physical_sw(physical_sw), .physical_leds(physical_leds)
    );

    always #5 clk = ~clk;

    // sets the switches, presses load and checks the leds
    // switches: {5'b0, funct7[5], funct3, opcode}
    // leds: {4'b0, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp, ALUControl}
    task load(input [8*4:1] name, input [15:0] sw, input [15:0] expected);
        begin
            physical_sw = sw; #100;
            pbnext = 1; #200; pbnext = 0; #200;
            if (physical_leds === expected) $display("%s passed: leds = %b", name, physical_leds);
            else begin
                $display("%s failed: leds = %b, expected %b", name, physical_leds, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        pbin = 1; #200; pbin = 0; #200;

        // switches change but load is not pressed, leds stay 0
        physical_sw = {5'b0, 1'b0, 3'b000, 7'b0110011}; #300;
        if (physical_leds !== 16'h0000) errors = errors + 1;

        load("ADD",  {5'b0, 1'b0, 3'b000, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0010);
        load("SUB",  {5'b0, 1'b1, 3'b000, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0110);
        load("SLL",  {5'b0, 1'b0, 3'b001, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0100);
        load("SRL",  {5'b0, 1'b0, 3'b101, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0101);
        load("AND",  {5'b0, 1'b0, 3'b111, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0000);
        load("OR",   {5'b0, 1'b0, 3'b110, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0001);
        load("XOR",  {5'b0, 1'b0, 3'b100, 7'b0110011}, 16'b0000_1_0_0_0_0_0_10_0011);
        load("ADDI", {5'b0, 1'b1, 3'b000, 7'b0010011}, 16'b0000_1_1_0_0_0_0_00_0010);
        load("LW",   {5'b0, 1'b0, 3'b010, 7'b0000011}, 16'b0000_1_1_1_0_1_0_00_0010);
        load("LH",   {5'b0, 1'b0, 3'b001, 7'b0000011}, 16'b0000_1_1_1_0_1_0_00_0010);
        load("LB",   {5'b0, 1'b0, 3'b000, 7'b0000011}, 16'b0000_1_1_1_0_1_0_00_0010);
        load("SW",   {5'b0, 1'b0, 3'b010, 7'b0100011}, 16'b0000_0_1_0_1_0_0_00_0010);
        load("SH",   {5'b0, 1'b0, 3'b001, 7'b0100011}, 16'b0000_0_1_0_1_0_0_00_0010);
        load("SB",   {5'b0, 1'b0, 3'b000, 7'b0100011}, 16'b0000_0_1_0_1_0_0_00_0010);
        load("BEQ",  {5'b0, 1'b0, 3'b000, 7'b1100011}, 16'b0000_0_0_0_0_0_1_01_0110);

        // change switches without load, leds keep showing beq
        physical_sw = {5'b0, 1'b0, 3'b000, 7'b0110011}; #300;
        if (physical_leds !== 16'b0000_0_0_0_0_0_1_01_0110) errors = errors + 1;

        // reset clears the leds
        pbin = 1; #200; pbin = 0; #200;
        if (physical_leds !== 16'h0000) errors = errors + 1;

        $display("errors = %0d", errors);
        $finish;
    end
endmodule
