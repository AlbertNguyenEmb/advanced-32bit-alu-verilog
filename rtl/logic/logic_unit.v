`timescale 1ns/1ps

`include "alu32_defines.vh"

module logic_unit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [6:0]  opcode,
    output reg  [31:0] logic_result
);

    always @(*) begin
        logic_result = 32'h0000_0000;

        case (opcode)
            `OP_AND: logic_result = A & B;
            `OP_OR : logic_result = A | B;
            `OP_XOR: logic_result = A ^ B;
            `OP_NOT: logic_result = ~A;
            default: logic_result = 32'h0000_0000;
        endcase
    end

endmodule