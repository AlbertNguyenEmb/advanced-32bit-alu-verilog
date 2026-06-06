`timescale 1ns/1ps
module alu32_core(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [5:0] opcode,
    output reg [31:0] Result,
    output wire Zero,
    output wire Negative
);
    //Opcode definitions
    localparam OP_ADD = 6'b000000;
    localparam OP_SUB = 6'b000001;
    localparam OP_AND = 6'b000010;
    localparam OP_OR = 6'b000011;
    localparam OP_XOR = 6'b000100;
    localparam OP_NOT = 6'b000101;

    always @(*) begin
        case (opcode)
            OP_ADD: Result = A + B;
            OP_SUB: Result = A - B;
            OP_AND: Result = A & B;
            OP_OR: Result = A | B;
            OP_XOR: Result = A ^ B;
            OP_NOT: Result = ~A;
            default: Result = 32'h0000_0000;
        endcase
    end

    assign Zero = (Result == 32'h0000_0000);
    assign Negative = (Result[31]);
endmodule