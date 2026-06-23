`timescale 1ns/1ps

`include "alu32_defines.vh"

module funnel_shifter32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [4:0]  shamt,
    input  wire [6:0]  opcode,
    output reg  [31:0] funnel_result
);

    wire [63:0] concat_ab;
    wire [63:0] fsl_temp;
    wire [63:0] fsr_temp;

    assign concat_ab = {A, B};
    assign fsl_temp  = concat_ab << shamt;
    assign fsr_temp  = concat_ab >> shamt;

    always @(*) begin
        funnel_result = 32'h0000_0000;

        case (opcode)
            `OP_FSL: funnel_result = fsl_temp[63:32];
            `OP_FSR: funnel_result = fsr_temp[31:0];
            default: funnel_result = 32'h0000_0000;
        endcase
    end

endmodule