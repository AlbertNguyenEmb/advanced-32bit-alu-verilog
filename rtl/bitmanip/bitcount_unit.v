`timescale 1ns/1ps

`include "alu32_defines.vh"

module bitcount_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] bitcount_result
);

    integer i;
    reg [5:0] count;

    always @(*) begin
        bitcount_result = 32'h0000_0000;
        count = 6'd0;

        if (opcode == `OP_BITCOUNT) begin
            for (i = 0; i < 32; i = i + 1) begin
                count = count + A[i];
            end

            bitcount_result = {26'd0, count};
        end
    end

endmodule