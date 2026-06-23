`timescale 1ns/1ps

`include "alu32_defines.vh"

module reverse_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] reverse_result
);

    integer i;

    always @(*) begin
        reverse_result = 32'h0000_0000;

        case (opcode)
            `OP_REV1: begin
                for (i = 0; i < 32; i = i + 1) begin
                    reverse_result[i] = A[31 - i];
                end
            end

            `OP_REV2: begin
                for (i = 0; i < 16; i = i + 1) begin
                    reverse_result[(2*i) +: 2] = A[(2*(15-i)) +: 2];
                end
            end

            `OP_REV4: begin
                reverse_result[3:0]    = A[31:28];
                reverse_result[7:4]    = A[27:24];
                reverse_result[11:8]   = A[23:20];
                reverse_result[15:12]  = A[19:16];
                reverse_result[19:16]  = A[15:12];
                reverse_result[23:20]  = A[11:8];
                reverse_result[27:24]  = A[7:4];
                reverse_result[31:28]  = A[3:0];
            end

            `OP_REV8: begin
                reverse_result = {A[7:0], A[15:8], A[23:16], A[31:24]};
            end

            `OP_REV16: begin
                reverse_result = {A[15:0], A[31:16]};
            end

            default: reverse_result = 32'h0000_0000;
        endcase
    end

endmodule