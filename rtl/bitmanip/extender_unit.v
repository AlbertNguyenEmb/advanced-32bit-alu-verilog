`timescale 1ns/1ps

`include "alu32_defines.vh"

module extender_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] extend_result
);

    always @(*) begin
        extend_result = 32'h0000_0000;

        case (opcode)
            `OP_ZEXT16: extend_result = {16'b0, A[15:0]};
            `OP_SEXT16: extend_result = {{16{A[15]}}, A[15:0]};
            default:    extend_result = 32'h0000_0000;
        endcase
    end

endmodule