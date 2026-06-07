`timescale 1ns/1ps
module alu32_core(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [5:0] opcode,
    input wire [4:0] shamt,
    output reg [31:0] Result,
    output wire Zero,
    output wire Negative,
    output wire Carry,
    output wire Overflow
    
);
    //Opcode definitions
    //Basic arithmetic and logic opcodes
    localparam OP_ADD = 6'b000000;
    localparam OP_SUB = 6'b000001;
    localparam OP_AND = 6'b000010;
    localparam OP_OR = 6'b000011;
    localparam OP_XOR = 6'b000100;
    localparam OP_NOT = 6'b000101;
    //Comaparision opcodes
    localparam EQ = 6'b000110;
    localparam LT_UNSIGNED = 6'b000111;
    localparam GT_UNSIGNED = 6'b001000;
    localparam LT_SIGNED = 6'b001001;
    localparam GT_SIGNED = 6'b001010;
    //Shift opcodes
    localparam OP_SLL = 6'b001011;
    localparam OP_SRL = 6'b001100;
    localparam OP_SRA = 6'b001101;
    //Create bit carry
    wire [32:0] add_result;
    wire [32:0] sub_result;

    assign add_result = {1'b0, A} + {1'b0, B};
    assign sub_ext = {1'b0, A} - {1'b0, B};
    assign Carry = (opcode == OP_ADD) ? add_result[32] : 1'b0;
    //Create bit overflow
    assign Overflow = ((opcode == OP_ADD)
                        && ((~A[31] && ~B[31] && Result[31]) ||
                            (A[31] && B[31] && ~Result[31])));
    always @(*) begin
        case (opcode)
            //Arithmetic and logic
            OP_ADD: Result = A + B;
            OP_SUB: Result = A - B;
            OP_AND: Result = A & B;
            OP_OR: Result = A | B;
            OP_XOR: Result = A ^ B;
            OP_NOT: Result = ~A;
            //Comparision
            EQ: Result = (A == B) ? 32'b1 : 32'b0;
            LT_UNSIGNED: Result = (A < B) ? 32'b1 : 32'b0;
            GT_UNSIGNED: Result = (A > B) ? 32'b1 : 32'b0;
            LT_SIGNED: Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            GT_SIGNED: Result = ($signed(A) > $signed(B)) ? 32'b1 : 32'b0;
            //Shift
            OP_SLL: Result = A << shamt;
            OP_SRL: Result = A >> shamt;
            OP_SRA: Result = $signed(A) >>> shamt;
            default: Result = 32'h0000_0000;
        endcase
    end

    assign Zero = (Result == 32'h0000_0000);
    assign Negative = (Result[31]);
endmodule