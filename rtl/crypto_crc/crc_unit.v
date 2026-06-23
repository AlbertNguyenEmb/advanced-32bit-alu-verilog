`timescale 1ns/1ps

`include "alu32_defines.vh"

module crc_unit (
    input  wire [31:0] A,
    input  wire [6:0]  opcode,
    output reg  [31:0] crc_result
);

    integer i;
    reg [7:0]  crc8_value;
    reg [15:0] crc16_value;
    reg [31:0] crc32_value;

    always @(*) begin
        crc_result   = 32'h0000_0000;
        crc8_value   = 8'h00;
        crc16_value  = 16'h0000;
        crc32_value  = 32'h0000_0000;

        case (opcode)
            `OP_CRC8: begin
                crc8_value = A[7:0];

                for (i = 0; i < 8; i = i + 1) begin
                    if (crc8_value[7]) begin
                        crc8_value = (crc8_value << 1) ^ 8'h07;
                    end else begin
                        crc8_value = crc8_value << 1;
                    end
                end

                crc_result = {24'd0, crc8_value};
            end

            `OP_CRC16: begin
                crc16_value = A[15:0];

                for (i = 0; i < 16; i = i + 1) begin
                    if (crc16_value[15]) begin
                        crc16_value = (crc16_value << 1) ^ 16'h1021;
                    end else begin
                        crc16_value = crc16_value << 1;
                    end
                end

                crc_result = {16'd0, crc16_value};
            end

            `OP_CRC32: begin
                crc32_value = A;

                for (i = 0; i < 32; i = i + 1) begin
                    if (crc32_value[31]) begin
                        crc32_value = (crc32_value << 1) ^ 32'h04C11DB7;
                    end else begin
                        crc32_value = crc32_value << 1;
                    end
                end

                crc_result = crc32_value;
            end

            default: begin
                crc_result = 32'h0000_0000;
            end
        endcase
    end

endmodule