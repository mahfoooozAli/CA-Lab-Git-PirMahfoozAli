`timescale 1ns / 1ps

// Acts like the processor: reads switches, writes memory, reads memory, writes leds
module mem_fsm(
    input             clk,
    input             rst,
    input             save,          // one-clock pulse when the save button is pressed
    input      [31:0] readData,
    output reg [31:0] address,
    output reg        readEnable,
    output reg        writeEnable,
    output reg [31:0] writeData,
    output reg [2:0]  state
);

    // reads take 2 clocks because memory and switches give data one clock late
    parameter READ_SW   = 3'b000;   // put the switch address on the bus
    parameter GET_SW    = 3'b001;   // switch data is ready, save it
    parameter WRITE_MEM = 3'b010;   // store switch value in data memory
    parameter READ_MEM  = 3'b011;   // put the memory address on the bus
    parameter GET_MEM   = 3'b100;   // memory data is ready, save it
    parameter WRITE_LED = 3'b101;   // show the stored value on the leds

    parameter SW_ADDR  = 32'd768;   // switches
    parameter MEM_ADDR = 32'd10;    // any location from 0 to 511
    parameter LED_ADDR = 32'd512;   // leds

    reg [2:0]  next_state;
    reg [31:0] sw_value;    // last value read from the switches
    reg [31:0] mem_value;   // last value read from data memory
    reg        save_req;    // remembers a button press until it is used

    // state register: reset goes back to READ_SW
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= READ_SW;
        else
            state <= next_state;
    end

    // memory is only written when save was pressed, otherwise just keep showing it
    always @(*) begin
        case (state)
            READ_SW:   next_state = GET_SW;
            GET_SW:    next_state = save_req ? WRITE_MEM : READ_MEM;
            WRITE_MEM: next_state = READ_MEM;
            READ_MEM:  next_state = GET_MEM;
            GET_MEM:   next_state = WRITE_LED;
            WRITE_LED: next_state = READ_SW;
            default:   next_state = READ_SW;
        endcase
    end

    // save the data that comes back from a read
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_value  <= 32'd0;
            mem_value <= 32'd0;
            save_req  <= 1'b0;
        end
        else begin
            if (state == GET_SW)
                sw_value <= readData;
            if (state == GET_MEM)
                mem_value <= readData;

            if (save)
                save_req <= 1'b1;
            else if (state == WRITE_MEM)
                save_req <= 1'b0;
        end
    end

    // bus signals for each state
    always @(*) begin
        address     = 32'd0;
        readEnable  = 1'b0;
        writeEnable = 1'b0;
        writeData   = 32'd0;

        case (state)
            READ_SW, GET_SW: begin
                address    = SW_ADDR;
                readEnable = 1'b1;
            end

            WRITE_MEM: begin
                address     = MEM_ADDR;
                writeEnable = 1'b1;
                writeData   = sw_value;
            end

            READ_MEM, GET_MEM: begin
                address    = MEM_ADDR;
                readEnable = 1'b1;
            end

            WRITE_LED: begin
                address     = LED_ADDR;
                writeEnable = 1'b1;
                writeData   = mem_value;
            end

            default: begin
                address     = 32'd0;
                readEnable  = 1'b0;
                writeEnable = 1'b0;
            end
        endcase
    end

endmodule
