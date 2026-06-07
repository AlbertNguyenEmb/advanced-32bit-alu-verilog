`timescale 1ns/1ps
module alu32_core_tb();

reg [31:0] A;
reg [31:0] B;
reg [5:0] opcode;
wire [31:0] Result;
wire Zero;
wire Negative;

alu32_core dut(
    .A(A),
    .B(B),
    .opcode(opcode),
    .Result(Result),
    .Zero(Zero),
    .Negative(Negative)
);

task run_test;
    input [5:0] op;
    input [31:0] a, b;
begin
    opcode = op;
    A = a;
    B = b;
    #10;
    $display("Time = %0t, Opcode = %0b, A = %0d, B = %0d, Result = %0d", 
            $time, op, a, b, Result);
end
endtask

    //Opcode definitions
    localparam OP_ADD = 6'b000000;
    localparam OP_SUB = 6'b000001;
    localparam OP_AND = 6'b000010;
    localparam OP_OR = 6'b000011;
    localparam OP_XOR = 6'b000100;
    localparam OP_NOT = 6'b000101;

    localparam EQ = 6'b000110;
    localparam LT_UNSIGNED = 6'b000111;
    localparam GT_UNSIGNED = 6'b001000;
    localparam LT_SIGNED = 6'b001001;
    localparam GT_SIGNED = 6'b001010;

    initial begin
        run_test(6'b000000, 10, 20); // ADD
        run_test(6'b000001, 50, 15); // SUB
        run_test(6'b000010, 32'h0000_0000,  32'h0000_0001);  // AND
        run_test(6'b000011, 32'h1111_1111,  32'h0000_0000);  // OR
        run_test(6'b000100, 32'h1100_1100,  32'h0011_0011);  // XOR
        run_test(6'b000101, 32'h1100_1100, 32'h0000_0000);  // NOT 
        /*run_test(6'b000110, 32'h1111_1111, 32'h1111_1111); // 1
        run_test(6'b000111, 32'h1111_1111, 32'h1111_1110); //0
        run_test(6'b001000, 32'h1111_1111, 32'h1111_1110); // 1
        run_test(6'b001001, 32'hFFFF_FFFF, 32'h1111_1111); //1
        run_test(6'b001010, 32'hFFFF_FFFF, 32'h1111_1111); //0 */
    end
    
endmodule