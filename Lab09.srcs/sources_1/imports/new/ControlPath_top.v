`timescale 1ns / 1ps

// FPGA top: switches -> main control + alu control -> leds, run by the fsm
//
// center button = reset, up button = load the instruction on the switches
// sw[6:0] = opcode, sw[9:7] = funct3, sw[10] = funct7 bit 5
// leds[3:0] = ALUControl, leds[5:4] = ALUOp, leds[6] = Branch, leds[7] = MemtoReg,
// leds[8] = MemWrite, leds[9] = MemRead, leds[10] = ALUSrc, leds[11] = RegWrite
module ControlPath_top #(
    parameter DEBOUNCE_MAX = 1_000_000
)(
    input         clk,
    input         pbin,           // reset button (center)
    input         pbnext,         // load button (up)
    input  [15:0] physical_sw,
    output [15:0] physical_leds
);

    wire rst, load_db;

    // lab 5 debouncer for both buttons
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_rst  (.clk(clk), .pbin(pbin), .pbout(rst));
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_load (.clk(clk), .pbin(pbnext), .pbout(load_db));

    // turn a held button into a single one-clock pulse
    reg load_q;
    always @(posedge clk) load_q <= load_db;
    wire load_pulse = load_db & ~load_q;

    // lab 5 switch module
    wire [31:0] sw_data;
    leds switch_in(
        .clk(clk), .rst(rst), .btns(16'd0), .writeData(32'd0), .writeEnable(1'b0),
        .readEnable(1'b1), .memAddress(30'd0), .switches(physical_sw), .readData(sw_data)
    );

    // instruction fields saved by the fsm
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;

    // control path
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;

    MainControl main_ctrl(
        .opcode(opcode), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemRead(MemRead),
        .MemWrite(MemWrite), .MemtoReg(MemtoReg), .Branch(Branch), .ALUOp(ALUOp)
    );

    ALUControl alu_ctrl(
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUCtrl)
    );

    wire [11:0] control_bits = {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp, ALUCtrl};

    // fsm
    wire [11:0] led_bits;
    wire        led_write;
    wire [1:0]  state;

    control_fsm fsm(
        .clk(clk), .rst(rst), .load(load_pulse), .sw_value(sw_data[15:0]),
        .control_bits(control_bits), .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .led_bits(led_bits), .led_write(led_write), .state(state)
    );

    // lab 5 led module
    switches led_out(
        .clk(clk), .rst(rst), .writeData({20'd0, led_bits}), .writeEnable(led_write),
        .readEnable(1'b0), .memAddress(30'd0), .readData(), .leds(physical_leds)
    );

endmodule
