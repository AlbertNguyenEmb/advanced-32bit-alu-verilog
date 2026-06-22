`timescale 1ns/1ps
module alu32_core_tb();

reg [31:0] A;
reg [31:0] B;
reg [6:0] opcode;
reg [4:0] shamt;
wire [31:0] Result;
wire Zero;
wire Negative;
wire carry_out;
wire overflow_out;
alu32_core dut(
    .A(A),
    .B(B),
    .opcode(opcode),
    .Result(Result),
    .Zero(Zero),
    .shamt(shamt),
    .Negative(Negative),
    .Carry(carry_out),
    .Overflow(overflow_out)
);

task run_test;
    input [6:0] op;
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

task run_test_shift;
    input [6:0] op;
    input [31:0] a;
    input [31:0] b;
    input [4:0] shift_amt;
begin
    opcode = op;
    A = a;
    B = b;
    shamt = shift_amt;
    #10;
    $display("Time = %0t, Opcode = %0b, A = %0h, shamt = %d, Result = %0d", 
            $time, op, a, shamt, Result);
end
endtask
    //Opcode definitions
    // Basic arithmetic and logic opcodes
    localparam OP_ADD = 7'b0000000;
    localparam OP_SUB = 7'b0000001;
    localparam OP_AND = 7'b0000010;
    localparam OP_OR  = 7'b0000011;
    localparam OP_XOR = 7'b0000100;
    localparam OP_NOT = 7'b0000101;
    
    // Comparision opcodes
    localparam EQ          = 7'b0000110;
    localparam LT_UNSIGNED = 7'b0000111;
    localparam GT_UNSIGNED = 7'b0001000;
    localparam LT_SIGNED   = 7'b0001001;
    localparam GT_SIGNED   = 7'b0001010;
    
    // Shift opcodes
    localparam OP_SLL = 7'b0001011;
    localparam OP_SRL = 7'b0001100;
    localparam OP_SRA = 7'b0001101;
    localparam OP_FSL = 7'b0001110;
    localparam OP_FSR = 7'b0001111;
    
    // Extension opcodes
    localparam OP_ZEXT16 = 7'b0010000;
    localparam OP_SEXT16 = 7'b0010001;
    
    // Reverse opcodes
    localparam OP_REV1  = 7'b0010010;
    localparam OP_REV2  = 7'b0010011;
    localparam OP_REV4  = 7'b0010100;
    localparam OP_REV8  = 7'b0010101;
    localparam OP_REV16 = 7'b0010110;
    
    // OR-Combine opcode
    localparam OP_ORC1  = 7'b0101111; 
    localparam OP_ORC2  = 7'b0110000;
    localparam OP_ORC4  = 7'b0110001;
    localparam OP_ORC8  = 7'b0110010;
    localparam OP_ORC16 = 7'b0110011;
    
    // Bitcount opcode
    localparam OP_BITCOUNT = 7'b0110100;
    
    // Shuffle / Unshuffle opcodes
    localparam OP_SHFL1    = 7'b0110101; 
    localparam OP_UNSHFL1  = 7'b0110110; 
    localparam OP_SHFL2    = 7'b0110111;
    localparam OP_UNSHFL2  = 7'b0111000; 
    localparam OP_SHFL4    = 7'b0111001; 
    localparam OP_UNSHFL4  = 7'b0111010; 
    localparam OP_SHFL8    = 7'b0111011; 
    localparam OP_UNSHFL8  = 7'b0111100; 
    localparam OP_SHFL16   = 7'b0111101; 
    localparam OP_UNSHFL16 = 7'b0111110;
    //Carry-less Multiplication — CLMUL
    localparam OP_CLMUL_LOW = 7'b0111111;
    localparam OP_CLMUL_HIGH = 7'b1000000;
    initial begin
        /*
        //Test Arithmetic and logic
        run_test(6'b000000, 10, 20); // ADD
        run_test(6'b000001, 50, 15); // SUB
        run_test(6'b000010, 32'h0000_0000,  32'h0000_0001);  // AND
        run_test(6'b000011, 32'h1111_1111,  32'h0000_0000);  // OR
        run_test(6'b000100, 32'h1100_1100,  32'h0011_0011);  // XOR
        run_test(6'b000101, 32'h1100_1100, 32'h0000_0000);  // NOT
        //Test comparision
        run_test(6'b000110, 32'h1111_1111, 32'h1111_1111); // 1
        run_test(6'b000111, 32'h1111_1111, 32'h1111_1110); //0
        run_test(6'b001000, 32'h1111_1111, 32'h1111_1110); // 1
        run_test(6'b001001, 32'hFFFF_FFFF, 32'h1111_1111); //1
        run_test(6'b001010, 32'hFFFF_FFFF, 32'h1111_1111); //0 
        //Test shift
        run_test_shift(6'b001011, 32'h1111_1111, 32'h1111_1111, 5'b01000); //SLL 2bit -> 1111_1100
        run_test_shift(6'b001100, 32'h1111_1111, 32'h1111_1111, 5'b01000); //SRL 2bit -> 0011_1111
        run_test_shift(6'b001101, 32'h1100_0000, 32'h1111_1111, 5'b01000); //SRA 2bit -> 1110_0000
        run_test_shift(6'b001110, 32'h1234_5678, 32'hABCD_EF00, 5'b01000); //FSL Result = 345678AB
        run_test_shift(6'b001111, 32'h1234_5678, 32'hABCD_EF00, 5'b01000); //FSR Result = 78ABCDEF
        //ZEXT16 test
        A = 32'hFFFF_8103;
        B = 32'h0000_1111;
        shamt = 5'd0;
        opcode = OP_ZEXT16;
        #10;
        $display("ZEXT16: A = %h, Result = %h", A , Result);
        // SEXT16 test - negative 16-bit value
        A = 32'h0000_8123;
        B = 32'h0;
        shamt = 5'd0;
        opcode = OP_SEXT16;
        #10;
        $display("SEXT16: A=%h, Result=%h, expected=FFFF8123", A, Result);

        // SEXT16 test - positive 16-bit value
        A = 32'h0000_7123;
        opcode = OP_SEXT16;
        #10;
        $display("SEXT16: A=%h, Result=%h, expected=00007123", A, Result);
        // REV4 test
        A = 32'h1234_5678;
        opcode = OP_REV4;
        #10;
        $display("REV4: A=%h, Result=%h, expected=87654321", A, Result);

        // REV8 test
        A = 32'h1234_5678;
        opcode = OP_REV8;
        #10;
        $display("REV8: A=%h, Result=%h, expected=78563412", A, Result);

        // REV16 test
        A = 32'h1234_5678;
        opcode = OP_REV16;
        #10;
        $display("REV16: A=%h, Result=%h, expected=56781234", A, Result);
        
        // ORC8 test
        A = 32'h1200_00F0;
        B = 32'd0;
        shamt = 5'd0;
        opcode = OP_ORC8;
        #10;
        $display("ORC8: A=%h, Result=%h, expected=00000009", A, Result);
        // ORC16 test
        A = 32'h0000_1234;
        opcode = OP_ORC16;
        #10;
        $display("ORC16: A=%h, Result=%h, expected=00000001", A, Result);

        A = 32'h1234_0000;
        opcode = OP_ORC16;
        #10;
        $display("ORC16: A=%h, Result=%h, expected=00000002", A, Result);

        A = 32'h1234_5678;
        opcode = OP_ORC16;
        #10;
        $display("ORC16: A=%h, Result=%h, expected=00000003", A, Result);
        // BITCOUNT tests
        A = 32'h0000_0000;
        opcode = OP_BITCOUNT;
        #10;
        $display("BITCOUNT: A=%h, Result=%0d, expected=0", A, Result);

        A = 32'h0000_000F;
        opcode = OP_BITCOUNT;
        #10;
        $display("BITCOUNT: A=%h, Result=%0d, expected=4", A, Result);

        A = 32'hFFFF_0000;
        opcode = OP_BITCOUNT;
        #10;
        $display("BITCOUNT: A=%h, Result=%0d, expected=16", A, Result);

        A = 32'hFFFF_FFFF;
        opcode = OP_BITCOUNT;
        #10;
        $display("BITCOUNT: A=%h, Result=%0d, expected=32", A, Result);

        A = 32'h8000_0001;
        opcode = OP_BITCOUNT;
        #10;
        $display("BITCOUNT: A=%h, Result=%0d, expected=2", A, Result);

        // SHFL4 test
        A = 32'h1234_5678;
        B = 32'd0;
        shamt = 5'd0;
        opcode = OP_SHFL4;
        #10;
        $display("SHFL4: A=%h, Result=%h, expected=15263748", A, Result);

        // UNSHFL4 test
        A = Result;
        opcode = OP_UNSHFL4;
        #10;
        $display("UNSHFL4: A=%h, Result=%h, expected=12345678", A, Result); */
        // CLMUL test 1: 4-bit example
        A = 32'h0000_000B; // 1011
        B = 32'h0000_0005; // 0101
        opcode = OP_CLMUL_LOW;
        #10;
        $display("CLMUL_LOW: A=%h, B=%h, Result=%h, expected=00000027", A, B, Result);
        // CLMUL test 2: A * 1 = A
        A = 32'h1234_5678;
        B = 32'h0000_0001;
        opcode = OP_CLMUL_LOW;
        #10;
        $display("CLMUL_LOW: A=%h, B=%h, Result=%h, expected=12345678", A, B, Result);
        // CLMUL high test
        A = 32'h8000_0000;
        B = 32'h0000_0002;
        opcode = OP_CLMUL_HIGH;
        #10;
        $display("CLMUL_HIGH: A=%h, B=%h, Result=%h, expected=00000001", A, B, Result);
        // CLMUL low test
        A = 32'h8000_0000;
        B = 32'h0000_0002;
        opcode = OP_CLMUL_LOW;
        #10;
        $display("CLMUL_LOW: A=%h, B=%h, Result=%h, expected=00000000", A, B, Result);
    end
    
endmodule