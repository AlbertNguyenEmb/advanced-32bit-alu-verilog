`timescale 1ns/1ps

module carryless_multiplier32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [63:0] P
);

    integer i;

    always @(*) begin
        P = 64'h0000_0000_0000_0000;

        for (i = 0; i < 32; i = i + 1) begin
            if (B[i]) begin
                P = P ^ ({32'b0, A} << i);
            end
        end
    end

endmodule