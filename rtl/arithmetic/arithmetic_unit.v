`timescale 1ns/1ps

`include "alu32_defines.vh"

module arithmetic_unit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [6:0]  opcode,

    output reg  [31:0] arithmetic_result,
    output wire        Carry,
    output wire        Overflow
);

    wire [32:0] add_ext;
    wire [32:0] sub_ext;

    assign add_ext = {1'b0, A} + {1'b0, B};
    assign sub_ext = {1'b0, A} - {1'b0, B};

    always @(*) begin
        arithmetic_result = 32'h0000_0000;

        case (opcode)
            `OP_ADD: arithmetic_result = A + B;
            `OP_SUB: arithmetic_result = A - B;
            default: arithmetic_result = 32'h0000_0000;
        endcase
    end

    assign Carry =
        (opcode == `OP_ADD) ? add_ext[32] :
        (opcode == `OP_SUB) ? sub_ext[32] :
        1'b0;

    assign Overflow =
        (opcode == `OP_ADD) ?
            ((~A[31] & ~B[31] & arithmetic_result[31]) |
             ( A[31] &  B[31] & ~arithmetic_result[31])) :
        (opcode == `OP_SUB) ?
            ((~A[31] &  B[31] & arithmetic_result[31]) |
             ( A[31] & ~B[31] & ~arithmetic_result[31])) :
        1'b0;

endmodule