`timescale 1ns/1ps

`include "alu32_defines.vh"

module shuffle_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] shuffle_result
);

    integer i;

    always @(*) begin
        shuffle_result = 32'h0000_0000;

        case (opcode)
            `OP_SHFL1: begin
                for (i = 0; i < 16; i = i + 1) begin
                    shuffle_result[2*i]     = A[i];
                    shuffle_result[2*i + 1] = A[i + 16];
                end
            end

            `OP_UNSHFL1: begin
                for (i = 0; i < 16; i = i + 1) begin
                    shuffle_result[i]      = A[2*i];
                    shuffle_result[i + 16] = A[2*i + 1];
                end
            end

            `OP_SHFL2: begin
                for (i = 0; i < 8; i = i + 1) begin
                    shuffle_result[(4*i) +: 2]     = A[(2*i) +: 2];
                    shuffle_result[(4*i + 2) +: 2] = A[(2*(i + 8)) +: 2];
                end
            end

            `OP_UNSHFL2: begin
                for (i = 0; i < 8; i = i + 1) begin
                    shuffle_result[(2*i) +: 2]       = A[(4*i) +: 2];
                    shuffle_result[(2*(i + 8)) +: 2] = A[(4*i + 2) +: 2];
                end
            end

            `OP_SHFL4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    shuffle_result[(8*i) +: 4]     = A[(4*i) +: 4];
                    shuffle_result[(8*i + 4) +: 4] = A[(4*(i + 4)) +: 4];
                end
            end

            `OP_UNSHFL4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    shuffle_result[(4*i) +: 4]       = A[(8*i) +: 4];
                    shuffle_result[(4*(i + 4)) +: 4] = A[(8*i + 4) +: 4];
                end
            end

            `OP_SHFL8: begin
                for (i = 0; i < 2; i = i + 1) begin
                    shuffle_result[(16*i) +: 8]     = A[(8*i) +: 8];
                    shuffle_result[(16*i + 8) +: 8] = A[(8*(i + 2)) +: 8];
                end
            end

            `OP_UNSHFL8: begin
                for (i = 0; i < 2; i = i + 1) begin
                    shuffle_result[(8*i) +: 8]       = A[(16*i) +: 8];
                    shuffle_result[(8*(i + 2)) +: 8] = A[(16*i + 8) +: 8];
                end
            end

            `OP_SHFL16: begin
                shuffle_result = A;
            end

            `OP_UNSHFL16: begin
                shuffle_result = A;
            end

            default: shuffle_result = 32'h0000_0000;
        endcase
    end

endmodule