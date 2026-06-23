`timescale 1ns/1ps

`include "alu32_defines.vh"

module or_combine_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] orc_result
);

    integer i;

    always @(*) begin
        orc_result = 32'h0000_0000;

        case (opcode)
            `OP_ORC1: begin
                orc_result = A;
            end

            `OP_ORC2: begin
                for (i = 0; i < 16; i = i + 1) begin
                    orc_result[i] = |A[(2*i) +: 2];
                end
            end

            `OP_ORC4: begin
                for (i = 0; i < 8; i = i + 1) begin
                    orc_result[i] = |A[(4*i) +: 4];
                end
            end

            `OP_ORC8: begin
                for (i = 0; i < 4; i = i + 1) begin
                    orc_result[i] = |A[(8*i) +: 8];
                end
            end

            `OP_ORC16: begin
                for (i = 0; i < 2; i = i + 1) begin
                    orc_result[i] = |A[(16*i) +: 16];
                end
            end

            default: orc_result = 32'h0000_0000;
        endcase
    end

endmodule