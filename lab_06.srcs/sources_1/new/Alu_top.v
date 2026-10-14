`timescale 1ns / 1ps

module ALU_top #(
    parameter DEBOUNCE_MAX = 1_000_000
)(
    input         clk,
    input         pbin,           // reset button
    input         pbnext,         // step button
    input  [15:0] physical_sw,
    output [15:0] physical_leds
);

    localparam [31:0] A = 32'h10101010;
    localparam [31:0] B = 32'h01010101;

    wire        rst, next_db;
    wire [31:0] sw_read;
    wire [31:0] ALUResult;
    wire        Zero;
    wire [1:0]  state;
    reg  [31:0] led_data;

    // clean up both buttons
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_rst  (.clk(clk), .pbin(pbin),   .pbout(rst));
    debouncer #(.DEBOUNCE_MAX(DEBOUNCE_MAX)) db_next (.clk(clk), .pbin(pbnext), .pbout(next_db));

    // turn a held button into a single one-clock pulse
    reg next_q;
    always @(posedge clk) next_q <= next_db;
    wire next_pulse = next_db & ~next_q;

    // the "leds" module is the switch reader (names are swapped from Lab 5)
    leds sw_if (
        .clk(clk), .rst(rst), .btns(16'd0),
        .writeData(32'd0), .writeEnable(1'b0), .readEnable(1'b1),
        .memAddress(30'd0), .switches(physical_sw), .readData(sw_read)
    );

    // switches[3:0] choose the ALU operation
    ALU alu (.A(A), .B(B), .ALUControl(sw_read[3:0]),
             .ALUResult(ALUResult), .Zero(Zero));

    alu_fsm fsm (.clk(clk), .rst(rst), .next(next_pulse), .state(state));

    // choose what the 16 LEDs show for the current state
    always @(*) begin
        case (state)
            2'b00:   led_data = {16'd0, ALUResult[15:0]};
            2'b01:   led_data = {16'd0, ALUResult[31:16]};
            2'b10:   led_data = {31'd0, Zero};
            default: led_data = 32'd0;
        endcase
    end

    // the "switches" module is the LED writer (names are swapped from Lab 5)
    switches led_if (
        .clk(clk), .rst(rst),
        .writeData(led_data), .writeEnable(1'b1), .readEnable(1'b0),
        .memAddress(30'd0), .readData(), .leds(physical_leds)
    );

endmodule