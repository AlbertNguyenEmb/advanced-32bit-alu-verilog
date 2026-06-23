`timescale 1ns/1ps

`include "alu32_defines.vh"

module alu32_core (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [6:0]  opcode,
    input  wire [4:0]  shamt,

    output reg  [31:0] Result,
    output wire        Zero,
    output wire        Negative,
    output wire        Carry,
    output wire        Overflow
);

    wire [31:0] arithmetic_result;
    wire [31:0] logic_result;
    wire [31:0] compare_result;
    wire [31:0] shift_result;
    wire [31:0] funnel_result;
    wire [31:0] extend_result;
    wire [31:0] reverse_result;
    wire [31:0] orc_result;
    wire [31:0] bitcount_result;
    wire [31:0] shuffle_result;
    wire [31:0] crc_result;

    wire [63:0] clmul_product;
    wire [63:0] mul_product;
    wire signed [63:0] booth_mul_product;
    assign booth_mul_product = $signed(A) * $signed(B);
    arithmetic_unit u_arithmetic (
        .A(A),
        .B(B),
        .opcode(opcode),
        .arithmetic_result(arithmetic_result),
        .Carry(Carry),
        .Overflow(Overflow)
    );

    logic_unit u_logic (
        .A(A),
        .B(B),
        .opcode(opcode),
        .logic_result(logic_result)
    );

    comparator32 u_compare (
        .A(A),
        .B(B),
        .opcode(opcode),
        .compare_result(compare_result)
    );

    barrel_shifter32 u_barrel_shift (
        .A(A),
        .shamt(shamt),
        .opcode(opcode),
        .shift_result(shift_result)
    );

    funnel_shifter32 u_funnel_shift (
        .A(A),
        .B(B),
        .shamt(shamt),
        .opcode(opcode),
        .funnel_result(funnel_result)
    );

    extender_unit u_extender (
        .A(A),
        .opcode(opcode),
        .extend_result(extend_result)
    );

    reverse_unit u_reverse (
        .A(A),
        .opcode(opcode),
        .reverse_result(reverse_result)
    );

    or_combine_unit u_or_combine (
        .A(A),
        .opcode(opcode),
        .orc_result(orc_result)
    );

    bitcount_unit u_bitcount (
        .A(A),
        .opcode(opcode),
        .bitcount_result(bitcount_result)
    );

    shuffle_unit u_shuffle (
        .A(A),
        .opcode(opcode),
        .shuffle_result(shuffle_result)
    );

    carryless_multiplier32 u_clmul (
        .A(A),
        .B(B),
        .P(clmul_product)
    );

    crc_unit u_crc (
        .A(A),
        .opcode(opcode),
        .crc_result(crc_result)
    );

    multiplier_comb32 u_mul_comb (
        .A(A),
        .B(B),
        .P(mul_product)
    );

    always @(*) begin
        Result = 32'h0000_0000;

        case (opcode)
            `OP_ADD,
            `OP_SUB:
                Result = arithmetic_result;

            `OP_AND,
            `OP_OR,
            `OP_XOR,
            `OP_NOT:
                Result = logic_result;

            `OP_EQ,
            `OP_LT_UNSIGNED,
            `OP_GT_UNSIGNED,
            `OP_LT_SIGNED,
            `OP_GT_SIGNED:
                Result = compare_result;

            `OP_SLL,
            `OP_SRL,
            `OP_SRA:
                Result = shift_result;

            `OP_FSL,
            `OP_FSR:
                Result = funnel_result;

            `OP_ZEXT16,
            `OP_SEXT16:
                Result = extend_result;

            `OP_REV1,
            `OP_REV2,
            `OP_REV4,
            `OP_REV8,
            `OP_REV16:
                Result = reverse_result;

            `OP_ORC1,
            `OP_ORC2,
            `OP_ORC4,
            `OP_ORC8,
            `OP_ORC16:
                Result = orc_result;

            `OP_BITCOUNT:
                Result = bitcount_result;

            `OP_SHFL1,
            `OP_UNSHFL1,
            `OP_SHFL2,
            `OP_UNSHFL2,
            `OP_SHFL4,
            `OP_UNSHFL4,
            `OP_SHFL8,
            `OP_UNSHFL8,
            `OP_SHFL16,
            `OP_UNSHFL16:
                Result = shuffle_result;

            `OP_CLMUL_LOW:
                Result = clmul_product[31:0];

            `OP_CLMUL_HIGH:
                Result = clmul_product[63:32];
            `OP_BOOTH_MUL_LOW: begin
                Result = booth_mul_product[31:0];
            end

            `OP_BOOTH_MUL_HIGH: begin
                Result = booth_mul_product[63:32];
            end
            `OP_CRC8,
            `OP_CRC16,
            `OP_CRC32:
                Result = crc_result;

            `OP_MUL_LOW:
                Result = mul_product[31:0];

            `OP_MUL_HIGH:
                Result = mul_product[63:32];

            default:
                Result = 32'h0000_0000;
        endcase
    end

    assign Zero     = (Result == 32'h0000_0000);
    assign Negative = Result[31];

endmodule