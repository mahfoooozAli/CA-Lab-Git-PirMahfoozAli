`timescale 1ns / 1ps

// top module for basys3, port names match the master xdc they gave
//
// center button = reset, up button = start fsm
// sw15 off: fsm mode, after it finishes sw[4:0] picks which register shows on the leds
// sw15 on:  manual mode, alu does x1 op x2
//           sw[8:5] = alu control code, sw[13:9] = rd, sw14 = WriteEnable
// leds[15:12] = fsm state, leds[11:0] = lower 12 bits of the value
module top_rf_alu(
    input clk,
    input pbin,                  // center button
    input pbnext,                // up button
    input [15:0] physical_sw,
    output [15:0] physical_leds
);

    wire rst = pbin;

    // lab 5 switch module
    wire [31:0] sw_data;
    leds switch_in(
        .clk(clk), .rst(rst), .btns(16'd0), .writeData(32'd0), .writeEnable(1'b0),
        .readEnable(1'b1), .memAddress(30'd0), .switches(physical_sw), .readData(sw_data)
    );
    wire [15:0] sw = sw_data[15:0];

    // lab 5 debouncer for the start button
    wire start_btn;
    debouncer db(.clk(clk), .pbin(pbnext), .pbout(start_btn));

    // slow tick so we can see the fsm states on the leds (4 per second)
    reg [24:0] counter = 0;
    wire tick = (counter == 25_000_000 - 1);
    always @(posedge clk) begin
        if (tick) counter <= 0;
        else counter <= counter + 1;
    end

    // remember the button press till the fsm sees it on a tick
    wire [3:0] state;
    reg go = 0;
    always @(posedge clk) begin
        if (rst) go <= 0;
        else if (start_btn) go <= 1;
        else if (state != 0) go <= 0;
    end

    wire manual = sw[15];
    wire running = (state != 0);

    // fsm
    wire f_we, useALU, zero;
    wire [4:0] f_rs1, f_rs2, f_rd;
    wire [3:0] f_alu;
    wire [31:0] constant;

    rf_alu_fsm fsm(
        .clk(clk), .rst(rst), .en(tick & ~manual), .start(go), .zero(zero),
        .WriteEnable(f_we), .rs1(f_rs1), .rs2(f_rs2), .rd(f_rd),
        .ALUControl(f_alu), .useALU(useALU), .constant(constant), .state(state)
    );

    // manual mode uses switches, otherwise the fsm drives everything
    // when the fsm is idle, read port 1 shows the register picked on sw[4:0]
    wire [4:0] rs1 = manual ? 5'd1 : (running ? f_rs1 : sw[4:0]);
    wire [4:0] rs2 = manual ? 5'd2 : f_rs2;
    wire [4:0] rd = manual ? sw[13:9] : f_rd;
    wire WriteEnable = manual ? sw[14] : f_we;
    wire [3:0] ALUControl = manual ? sw[8:5] : f_alu;

    wire [31:0] ReadData1, ReadData2, ALUResult;
    wire [31:0] WriteData = (manual || useALU) ? ALUResult : constant;

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

    // manual shows alu result, otherwise shows read port 1
    wire [31:0] value = manual ? ALUResult : ReadData1;

    // lab 5 led module 
    switches led_out(
        .clk(clk), .rst(rst), .writeData({16'd0, state, value[11:0]}), .writeEnable(1'b1),
        .readEnable(1'b0), .memAddress(30'd0), .readData(), .leds(physical_leds)
    );

endmodule
