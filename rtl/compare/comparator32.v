`timescale 1ns/1ps

`include "alu32_defines.vh"

module comparator32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [6:0]  opcode,
    output reg  [31:0] compare_result
);

    always @(*) begin
        compare_result = 32'h0000_0000;

        case (opcode)
            `OP_EQ:
                compare_result = (A == B) ? 32'd1 : 32'd0;

            `OP_LT_UNSIGNED:
                compare_result = (A < B) ? 32'd1 : 32'd0;

            `OP_GT_UNSIGNED:
                compare_result = (A > B) ? 32'd1 : 32'd0;

            `OP_LT_SIGNED:
                compare_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            `OP_GT_SIGNED:
                compare_result = ($signed(A) > $signed(B)) ? 32'd1 : 32'd0;

            default:
                compare_result = 32'h0000_0000;
        endcase
    end

endmodule