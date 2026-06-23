`timescale 1ns/1ps

`include "alu32_defines.vh"

module barrel_shifter32 (
    input  wire [31:0] A,
    input  wire [4:0]  shamt,
    input  wire [6:0]  opcode,
    output reg  [31:0] shift_result
);

    always @(*) begin
        shift_result = 32'h0000_0000;

        case (opcode)
            `OP_SLL: shift_result = A << shamt;
            `OP_SRL: shift_result = A >> shamt;
            `OP_SRA: shift_result = $signed(A) >>> shamt;
            default: shift_result = 32'h0000_0000;
        endcase
    end

endmodule