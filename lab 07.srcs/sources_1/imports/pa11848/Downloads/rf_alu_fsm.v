`timescale 1ns / 1ps

// fsm that runs the whole test on the register file and alu
// writes x1, x2, x3 -> does 7 alu ops on x1 and x2 and puts results in x4 to x10
// -> beq check (x11 gets 1, x12 stays 0) -> read after write on x13
module rf_alu_fsm(
    input clk,
    input rst,
    input en,                 // fsm only moves when en is 1
    input start,
    input zero,               // zero flag from alu
    output reg WriteEnable,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [3:0] ALUControl,
    output reg useALU,        // 1 = write alu result, 0 = write constant
    output reg [31:0] constant,
    output reg [3:0] state
);

    localparam IDLE = 0, WRITE_REGS = 1, READ_REGISTERS = 2, ALU_OPERATION = 3,
               WRITE_REGISTERS = 4, BEQ_EQUAL = 5, BEQ_NOT_EQUAL = 6,
               RAW_WRITE = 7, RAW_READ = 8, DONE = 9;

    // alu codes, change these to match your alu
    localparam ALU_AND = 4'b0000, ALU_OR = 4'b0001, ALU_ADD = 4'b0010, ALU_XOR = 4'b0011,
               ALU_SLL = 4'b0100, ALU_SRL = 4'b0101, ALU_SUB = 4'b0110;

    reg [2:0] count;   // which constant / which alu op we are on

    // state changes
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            count <= 0;
        end
        else if (en) begin
            case (state)
                IDLE: if (start) begin state <= WRITE_REGS; count <= 0; end

                // write 3 constants then go to the alu loop
                WRITE_REGS: if (count == 2) begin state <= READ_REGISTERS; count <= 0; end
                            else count <= count + 1;

                READ_REGISTERS: state <= ALU_OPERATION;
                ALU_OPERATION:  state <= WRITE_REGISTERS;

                // after 7 ops go to beq, else do next op
                WRITE_REGISTERS: if (count == 6) state <= BEQ_EQUAL;
                                 else begin count <= count + 1; state <= READ_REGISTERS; end

                BEQ_EQUAL:     state <= BEQ_NOT_EQUAL;
                BEQ_NOT_EQUAL: state <= RAW_WRITE;
                RAW_WRITE:     state <= RAW_READ;
                RAW_READ:      state <= DONE;
                DONE:          state <= IDLE;
                default:       state <= IDLE;
            endcase
        end
    end

    // outputs for each state
    always @(*) begin
        WriteEnable = 0; rs1 = 0; rs2 = 0; rd = 0;
        ALUControl = ALU_ADD; useALU = 0; constant = 0;

        case (state)
            WRITE_REGS: begin
                // count 0,1,2 -> x1,x2,x3
                WriteEnable = 1;
                rd = count + 1;
                if (count == 0)      constant = 32'h10101010;
                else if (count == 1) constant = 32'h01010101;
                else                 constant = 32'h00000005;
            end

            READ_REGISTERS, ALU_OPERATION, WRITE_REGISTERS: begin
                rs1 = 1; rs2 = 2;
                case (count)
                    0: ALUControl = ALU_ADD;
                    1: ALUControl = ALU_SUB;
                    2: ALUControl = ALU_AND;
                    3: ALUControl = ALU_OR;
                    4: ALUControl = ALU_XOR;
                    5: ALUControl = ALU_SLL;
                    6: ALUControl = ALU_SRL;
                endcase
                // result goes to x4 to x10
                if (state == WRITE_REGISTERS) begin
                    WriteEnable = 1; useALU = 1; rd = count + 4;
                end
            end

            BEQ_EQUAL: begin
                // x1 - x1 = 0 so zero = 1, write 1 to x11
                rs1 = 1; rs2 = 1; ALUControl = ALU_SUB;
                rd = 11; constant = 1; WriteEnable = zero;
            end

            BEQ_NOT_EQUAL: begin
                // x1 - x2 is not 0 so zero = 0, x12 does not get written
                rs1 = 1; rs2 = 2; ALUControl = ALU_SUB;
                rd = 12; constant = 1; WriteEnable = zero;
            end

            RAW_WRITE: begin
                // write x13 here, read it next state
                WriteEnable = 1; rd = 13; constant = 32'hCAFEBABE; rs1 = 13;
            end

            RAW_READ: rs1 = 13;
        endcase
    end

endmodule
