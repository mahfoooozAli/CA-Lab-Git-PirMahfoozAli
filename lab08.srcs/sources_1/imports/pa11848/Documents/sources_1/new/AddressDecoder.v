`timescale 1ns / 1ps

// Looks at address[9:8] and enables only one device
//   0   - 511  : data memory  (selector = 00 or 01)
//   512 - 767  : leds         (selector = 10)
//   768 - 1023 : switches     (selector = 11)
module AddressDecoder(
    input  [9:0] address,
    input        readEnable,
    input        writeEnable,
    output reg   DataMemWrite,
    output reg   DataMemRead,
    output reg   LEDWrite,
    output reg   SwitchReadEnable
);

    wire [1:0] selector;
    assign selector = address[9:8];

    always @(*) begin
        DataMemWrite     = 1'b0;
        DataMemRead      = 1'b0;
        LEDWrite         = 1'b0;
        SwitchReadEnable = 1'b0;

        case (selector)
            2'b00,
            2'b01: begin                            // data memory
                DataMemWrite = writeEnable;
                DataMemRead  = readEnable;
            end
            2'b10: LEDWrite         = writeEnable;  // leds are write only
            2'b11: SwitchReadEnable = readEnable;   // switches are read only
        endcase
    end

endmodule
