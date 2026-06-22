`timescale 1ns/1ps
module alu32_core(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [6:0] opcode,
    input wire [4:0] shamt,
    output reg [31:0] Result,
    output wire Zero,
    output wire Negative,
    output wire Carry,
    output wire Overflow
);  
    reg [5:0] bit_count;
    reg [7:0] crc8_value;
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
    //Create funnel shift result
    wire [63:0] funnel_concat;
    wire [63:0] fsl_temp;
    wire [63:0] fsr_temp;
    wire [31:0] fsl_result;
    wire [31:0] fsr_result;
    reg [63:0] clmul_product;
    assign funnel_concat = {A, B};
    
    assign fsl_temp = funnel_concat << shamt;
    assign fsr_temp = funnel_concat >> shamt;

    assign fsl_result = fsl_temp[63:32];
    assign fsr_result = fsr_temp[31:0];
    //Create bit carry
    wire [32:0] add_result;
    wire [32:0] sub_result;
    assign add_result = {1'b0, A} + {1'b0, B};
    assign sub_result = {1'b0, A} - {1'b0, B};
    assign Carry = (opcode == OP_ADD) ? add_result[32] : 1'b0;
    //Create bit overflow
    assign Overflow = ((opcode == OP_ADD)
                        && ((~A[31] && ~B[31] && Result[31]) ||
                            (A[31] && B[31] && ~Result[31])));
    integer i;
    always @(*) begin
        Result = 32'h0000_0000;
        bit_count = 6'd0;
        clmul_product = 64'h0000_0000_0000_0000;
        crc8_value = 8'h00;
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
            OP_FSL: Result = fsl_result;
            OP_FSR: Result = fsr_result;
            //Extension
            OP_ZEXT16: Result = {16'b0, A[15:0]};
            OP_SEXT16: Result = {{16{A[15]}}, A[15:0]};
            //Reverse
            OP_REV1: begin
                for (i = 0; i < 32; i = i + 1) begin
                    Result[i] = A[31-i];
                end
            end
            OP_REV2: begin
                for (i = 0; i < 32; i = i + 1) begin
                    Result[(2*i) +: 2] = A[(2*(15 - i)) +: 2];
                end
            end
            OP_REV4: begin
                Result[3:0]    = A[31:28];
                Result[7:4]    = A[27:24];
                Result[11:8]   = A[23:20];
                Result[15:12]  = A[19:16];
                Result[19:16]  = A[15:12];
                Result[23:20]  = A[11:8];
                Result[27:24]  = A[7:4];
                Result[31:28]  = A[3:0];
            end

            OP_REV8: begin
                Result = {A[7:0], A[15:8], A[23:16], A[31:24]};
            end

            OP_REV16: begin
                Result = {A[15:0], A[31:16]};
            end
            OP_ORC1: begin
                Result = A;
            end
            OP_ORC2: begin
                for (i = 0; i < 16; i = i + 1) begin
                    Result[i] = |A[(2*i) +: 2];
                end
            end
            OP_ORC8: begin
                for (i = 0; i < 4; i = i + 1) begin
                    Result[i] = |A[(8*i) +: 8];
                end
            end
            OP_ORC16: begin
                for (i = 0; i < 2; i = i + 1) begin
                    Result[i] = |A[(16*i) +: 16];
                end
            end
            OP_BITCOUNT: begin
                bit_count = 6'd0;

                for (i = 0; i < 32; i = i + 1) begin
                    bit_count = bit_count + A[i];
                end
                Result = {26'd0, bit_count};
            end
            OP_SHFL1: begin
                for (i = 0; i < 16; i = i + 1) begin
                    Result[2*i]     = A[i];
                    Result[2*i + 1] = A[i + 16];
                end
            end

            OP_UNSHFL1: begin
                for (i = 0; i < 16; i = i + 1) begin
                    Result[i]      = A[2*i];
                    Result[i + 16] = A[2*i + 1];
                end
            end

            OP_SHFL2: begin
                for (i = 0; i < 8; i = i + 1) begin
                    Result[(4*i) +: 2]     = A[(2*i) +: 2];
                    Result[(4*i + 2) +: 2] = A[(2*(i + 8)) +: 2];
                end
            end

            OP_UNSHFL2: begin
                for (i = 0; i < 8; i = i + 1) begin
                    Result[(2*i) +: 2]       = A[(4*i) +: 2];
                    Result[(2*(i + 8)) +: 2] = A[(4*i + 2) +: 2];
                end
            end

            OP_SHFL4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    Result[(8*i) +: 4]     = A[(4*i) +: 4];
                    Result[(8*i + 4) +: 4] = A[(4*(i + 4)) +: 4];
                end
            end

            OP_UNSHFL4: begin
                for (i = 0; i < 4; i = i + 1) begin
                    Result[(4*i) +: 4]       = A[(8*i) +: 4];
                    Result[(4*(i + 4)) +: 4] = A[(8*i + 4) +: 4];
                end
            end

            OP_SHFL8: begin
                for (i = 0; i < 2; i = i + 1) begin
                    Result[(16*i) +: 8]     = A[(8*i) +: 8];
                    Result[(16*i + 8) +: 8] = A[(8*(i + 2)) +: 8];
                end
            end

            OP_UNSHFL8: begin
                for (i = 0; i < 2; i = i + 1) begin
                    Result[(8*i) +: 8]       = A[(16*i) +: 8];
                    Result[(8*(i + 2)) +: 8] = A[(16*i + 8) +: 8];
                end
            end

            OP_SHFL16: begin
                Result = A;
            end

            OP_UNSHFL16: begin
                Result = A;
            end
            OP_CLMUL_LOW: begin
                clmul_product = 64'h0000_0000_0000_0000;

                for (i = 0; i < 32; i = i + 1) begin
                    if (B[i]) begin
                        clmul_product = clmul_product ^ ({32'b0, A} << i);
                    end
                end

                Result = clmul_product[31:0];
            end
            OP_CLMUL_HIGH: begin
                clmul_product = 64'h0000_0000_0000_0000;

                for (i = 0; i < 32; i = i + 1) begin
                    if (B[i]) begin
                        clmul_product = clmul_product ^ ({32'b0, A} << i);
                    end
                end

                Result = clmul_product[63:32];
            end
            default: Result = 32'h0000_0000;
            endcase
        end

    assign Zero = (Result == 32'h0000_0000);
    assign Negative = (Result[31]);
endmodule