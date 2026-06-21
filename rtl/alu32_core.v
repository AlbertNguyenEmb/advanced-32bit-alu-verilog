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
    reg [5:0] bit_count;
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
    localparam OP_FSL = 6'b001110;
    localparam OP_FSR = 6'b001111;
    //Extension opcodes
    localparam OP_ZEXT16 = 6'b010000;
    localparam OP_SEXT16 = 6'b010001;
    // Reverse opcodes
    localparam OP_REV1 = 6'b010010;
    localparam OP_REV2 = 6'b010011;
    localparam OP_REV4 = 6'b010100;
    localparam OP_REV8 = 6'b010101;
    localparam OP_REV16 = 6'b010110;
    // OR-Combine opcode
    localparam OP_ORC1 = 6'b0101111;
    localparam OP_ORC2 = 6'b110000;
    localparam OP_ORC4 = 6'b110001;
    localparam OP_ORC8 = 6'b110010;
    localparam OP_ORC16 = 6'b110011;
    // Bitcount opcode
    localparam OP_BITCOUNT = 6'b110100;
    // Shuffle / Unshuffle opcodes tiếp nối
    localparam OP_SHFL1    = 6'b110101; 
    localparam OP_UNSHFL1  = 6'b110110; 
    localparam OP_SHFL2    = 6'b110111;
    localparam OP_UNSHFL2  = 6'b111000; 
    localparam OP_SHFL4    = 6'b111001; 
    localparam OP_UNSHFL4  = 6'b111010; 
    localparam OP_SHFL8    = 6'b111011; 
    localparam OP_UNSHFL8  = 6'b111100; 
    localparam OP_SHFL16   = 6'b111101; 
    localparam OP_UNSHFL16 = 6'b111110;
    //Create funnel shift result
    wire [63:0] funnel_concat;
    wire [63:0] fsl_temp;
    wire [63:0] fsr_temp;
    wire [31:0] fsl_result;
    wire [31:0] fsr_result;
    
    assign funnel_concat = {A, B};
    
    assign fsl_temp = funnel_concat << shamt;
    assign fsr_result = funnel_concat >> shamt;

    assign fsl_result = fsl_temp[63:32];
    assign fsr_result = fsr_temp[31:0];
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
    integer i;
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
            ORC1: begin
                Result = A;
            end
            ORC2: begin
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
            default: Result = 32'h0000_0000;
            endcase
        end

    assign Zero = (Result == 32'h0000_0000);
    assign Negative = (Result[31]);
endmodule