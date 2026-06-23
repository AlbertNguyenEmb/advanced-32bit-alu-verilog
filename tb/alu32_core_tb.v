`timescale 1ns/1ps

`include "alu32_defines.vh"

module alu32_core_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [6:0]  opcode;
    reg  [4:0]  shamt;

    wire [31:0] Result;
    wire        Zero;
    wire        Negative;
    wire        Carry;
    wire        Overflow;

    integer pass_count;
    integer fail_count;

    reg [31:0] expected_result;
    reg        expected_zero;
    reg        expected_negative;
    reg        expected_carry;
    reg        expected_overflow;

    // =====================================================
    // DUT
    // =====================================================
    alu32_core dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .shamt(shamt),
        .Result(Result),
        .Zero(Zero),
        .Negative(Negative),
        .Carry(Carry),
        .Overflow(Overflow)
    );

    // =====================================================
    // Golden helper functions
    // =====================================================

    function [31:0] reverse_by_1;
        input [31:0] x;
        integer i;
        begin
            reverse_by_1 = 32'd0;
            for (i = 0; i < 32; i = i + 1) begin
                reverse_by_1[i] = x[31 - i];
            end
        end
    endfunction

    function [31:0] reverse_by_2;
        input [31:0] x;
        integer i;
        begin
            reverse_by_2 = 32'd0;
            for (i = 0; i < 16; i = i + 1) begin
                reverse_by_2[(2*i) +: 2] = x[(2*(15-i)) +: 2];
            end
        end
    endfunction

    function [31:0] reverse_by_4;
        input [31:0] x;
        begin
            reverse_by_4[3:0]    = x[31:28];
            reverse_by_4[7:4]    = x[27:24];
            reverse_by_4[11:8]   = x[23:20];
            reverse_by_4[15:12]  = x[19:16];
            reverse_by_4[19:16]  = x[15:12];
            reverse_by_4[23:20]  = x[11:8];
            reverse_by_4[27:24]  = x[7:4];
            reverse_by_4[31:28]  = x[3:0];
        end
    endfunction

    function [31:0] or_combine_2;
        input [31:0] x;
        integer i;
        begin
            or_combine_2 = 32'd0;
            for (i = 0; i < 16; i = i + 1) begin
                or_combine_2[i] = |x[(2*i) +: 2];
            end
        end
    endfunction

    function [31:0] or_combine_4;
        input [31:0] x;
        integer i;
        begin
            or_combine_4 = 32'd0;
            for (i = 0; i < 8; i = i + 1) begin
                or_combine_4[i] = |x[(4*i) +: 4];
            end
        end
    endfunction

    function [31:0] or_combine_8;
        input [31:0] x;
        integer i;
        begin
            or_combine_8 = 32'd0;
            for (i = 0; i < 4; i = i + 1) begin
                or_combine_8[i] = |x[(8*i) +: 8];
            end
        end
    endfunction

    function [31:0] or_combine_16;
        input [31:0] x;
        integer i;
        begin
            or_combine_16 = 32'd0;
            for (i = 0; i < 2; i = i + 1) begin
                or_combine_16[i] = |x[(16*i) +: 16];
            end
        end
    endfunction

    function [31:0] bitcount32;
        input [31:0] x;
        integer i;
        reg [5:0] count;
        begin
            count = 6'd0;
            for (i = 0; i < 32; i = i + 1) begin
                count = count + x[i];
            end
            bitcount32 = {26'd0, count};
        end
    endfunction

    function [31:0] shfl1;
        input [31:0] x;
        integer i;
        begin
            shfl1 = 32'd0;
            for (i = 0; i < 16; i = i + 1) begin
                shfl1[2*i]     = x[i];
                shfl1[2*i + 1] = x[i + 16];
            end
        end
    endfunction

    function [31:0] unshfl1;
        input [31:0] x;
        integer i;
        begin
            unshfl1 = 32'd0;
            for (i = 0; i < 16; i = i + 1) begin
                unshfl1[i]      = x[2*i];
                unshfl1[i + 16] = x[2*i + 1];
            end
        end
    endfunction

    function [31:0] shfl2;
        input [31:0] x;
        integer i;
        begin
            shfl2 = 32'd0;
            for (i = 0; i < 8; i = i + 1) begin
                shfl2[(4*i) +: 2]     = x[(2*i) +: 2];
                shfl2[(4*i + 2) +: 2] = x[(2*(i + 8)) +: 2];
            end
        end
    endfunction

    function [31:0] unshfl2;
        input [31:0] x;
        integer i;
        begin
            unshfl2 = 32'd0;
            for (i = 0; i < 8; i = i + 1) begin
                unshfl2[(2*i) +: 2]       = x[(4*i) +: 2];
                unshfl2[(2*(i + 8)) +: 2] = x[(4*i + 2) +: 2];
            end
        end
    endfunction

    function [31:0] shfl4;
        input [31:0] x;
        integer i;
        begin
            shfl4 = 32'd0;
            for (i = 0; i < 4; i = i + 1) begin
                shfl4[(8*i) +: 4]     = x[(4*i) +: 4];
                shfl4[(8*i + 4) +: 4] = x[(4*(i + 4)) +: 4];
            end
        end
    endfunction

    function [31:0] unshfl4;
        input [31:0] x;
        integer i;
        begin
            unshfl4 = 32'd0;
            for (i = 0; i < 4; i = i + 1) begin
                unshfl4[(4*i) +: 4]       = x[(8*i) +: 4];
                unshfl4[(4*(i + 4)) +: 4] = x[(8*i + 4) +: 4];
            end
        end
    endfunction

    function [31:0] shfl8;
        input [31:0] x;
        integer i;
        begin
            shfl8 = 32'd0;
            for (i = 0; i < 2; i = i + 1) begin
                shfl8[(16*i) +: 8]     = x[(8*i) +: 8];
                shfl8[(16*i + 8) +: 8] = x[(8*(i + 2)) +: 8];
            end
        end
    endfunction

    function [31:0] unshfl8;
        input [31:0] x;
        integer i;
        begin
            unshfl8 = 32'd0;
            for (i = 0; i < 2; i = i + 1) begin
                unshfl8[(8*i) +: 8]       = x[(16*i) +: 8];
                unshfl8[(8*(i + 2)) +: 8] = x[(16*i + 8) +: 8];
            end
        end
    endfunction

    function [63:0] clmul32;
        input [31:0] x;
        input [31:0] y;
        integer i;
        begin
            clmul32 = 64'd0;
            for (i = 0; i < 32; i = i + 1) begin
                if (y[i]) begin
                    clmul32 = clmul32 ^ ({32'd0, x} << i);
                end
            end
        end
    endfunction

    function [63:0] mul32_unsigned;
        input [31:0] x;
        input [31:0] y;
        integer i;
        begin
            mul32_unsigned = 64'd0;
            for (i = 0; i < 32; i = i + 1) begin
                if (y[i]) begin
                    mul32_unsigned = mul32_unsigned + ({32'd0, x} << i);
                end
            end
        end
    endfunction

    function signed [63:0] mul32_signed;
        input signed [31:0] x;
        input signed [31:0] y;
        begin
            mul32_signed = x * y;
        end
    endfunction

    function [31:0] crc8_ref;
        input [31:0] x;
        integer i;
        reg [7:0] crc;
        begin
            crc = x[7:0];

            for (i = 0; i < 8; i = i + 1) begin
                if (crc[7]) begin
                    crc = (crc << 1) ^ 8'h07;
                end else begin
                    crc = crc << 1;
                end
            end

            crc8_ref = {24'd0, crc};
        end
    endfunction

    function [31:0] crc16_ref;
        input [31:0] x;
        integer i;
        reg [15:0] crc;
        begin
            crc = x[15:0];

            for (i = 0; i < 16; i = i + 1) begin
                if (crc[15]) begin
                    crc = (crc << 1) ^ 16'h1021;
                end else begin
                    crc = crc << 1;
                end
            end

            crc16_ref = {16'd0, crc};
        end
    endfunction

    function [31:0] crc32_ref;
        input [31:0] x;
        integer i;
        reg [31:0] crc;
        begin
            crc = x;

            for (i = 0; i < 32; i = i + 1) begin
                if (crc[31]) begin
                    crc = (crc << 1) ^ 32'h04C11DB7;
                end else begin
                    crc = crc << 1;
                end
            end

            crc32_ref = crc;
        end
    endfunction

    function [31:0] expected_model;
        input [31:0] x;
        input [31:0] y;
        input [6:0]  op;
        input [4:0]  s;
        reg [63:0] temp64;
        reg signed [63:0] stemp64;
        reg [63:0] funnel_temp;
        begin
            expected_model = 32'h0000_0000;
            temp64 = 64'd0;
            stemp64 = 64'sd0;
            funnel_temp = 64'd0;

            case (op)
                `OP_ADD: expected_model = x + y;
                `OP_SUB: expected_model = x - y;
                `OP_AND: expected_model = x & y;
                `OP_OR : expected_model = x | y;
                `OP_XOR: expected_model = x ^ y;
                `OP_NOT: expected_model = ~x;

                `OP_EQ:          expected_model = (x == y) ? 32'd1 : 32'd0;
                `OP_LT_UNSIGNED: expected_model = (x < y) ? 32'd1 : 32'd0;
                `OP_GT_UNSIGNED: expected_model = (x > y) ? 32'd1 : 32'd0;
                `OP_LT_SIGNED:   expected_model = ($signed(x) < $signed(y)) ? 32'd1 : 32'd0;
                `OP_GT_SIGNED:   expected_model = ($signed(x) > $signed(y)) ? 32'd1 : 32'd0;

                `OP_SLL: expected_model = x << s;
                `OP_SRL: expected_model = x >> s;
                `OP_SRA: expected_model = $signed(x) >>> s;

                `OP_FSL: begin
                    funnel_temp = {x, y} << s;
                    expected_model = funnel_temp[63:32];
                end

                `OP_FSR: begin
                    funnel_temp = {x, y} >> s;
                    expected_model = funnel_temp[31:0];
                end

                `OP_ZEXT16: expected_model = {16'b0, x[15:0]};
                `OP_SEXT16: expected_model = {{16{x[15]}}, x[15:0]};

                `OP_REV1:  expected_model = reverse_by_1(x);
                `OP_REV2:  expected_model = reverse_by_2(x);
                `OP_REV4:  expected_model = reverse_by_4(x);
                `OP_REV8:  expected_model = {x[7:0], x[15:8], x[23:16], x[31:24]};
                `OP_REV16: expected_model = {x[15:0], x[31:16]};

                `OP_ORC1:  expected_model = x;
                `OP_ORC2:  expected_model = or_combine_2(x);
                `OP_ORC4:  expected_model = or_combine_4(x);
                `OP_ORC8:  expected_model = or_combine_8(x);
                `OP_ORC16: expected_model = or_combine_16(x);

                `OP_BITCOUNT: expected_model = bitcount32(x);

                `OP_SHFL1:    expected_model = shfl1(x);
                `OP_UNSHFL1:  expected_model = unshfl1(x);
                `OP_SHFL2:    expected_model = shfl2(x);
                `OP_UNSHFL2:  expected_model = unshfl2(x);
                `OP_SHFL4:    expected_model = shfl4(x);
                `OP_UNSHFL4:  expected_model = unshfl4(x);
                `OP_SHFL8:    expected_model = shfl8(x);
                `OP_UNSHFL8:  expected_model = unshfl8(x);
                `OP_SHFL16:   expected_model = x;
                `OP_UNSHFL16: expected_model = x;

                `OP_CLMUL_LOW: begin
                    temp64 = clmul32(x, y);
                    expected_model = temp64[31:0];
                end

                `OP_CLMUL_HIGH: begin
                    temp64 = clmul32(x, y);
                    expected_model = temp64[63:32];
                end

                `OP_MUL_LOW: begin
                    temp64 = mul32_unsigned(x, y);
                    expected_model = temp64[31:0];
                end

                `OP_MUL_HIGH: begin
                    temp64 = mul32_unsigned(x, y);
                    expected_model = temp64[63:32];
                end

                `OP_BOOTH_MUL_LOW: begin
                    stemp64 = mul32_signed($signed(x), $signed(y));
                    expected_model = stemp64[31:0];
                end

                `OP_BOOTH_MUL_HIGH: begin
                    stemp64 = mul32_signed($signed(x), $signed(y));
                    expected_model = stemp64[63:32];
                end

                `OP_CRC8:  expected_model = crc8_ref(x);
                `OP_CRC16: expected_model = crc16_ref(x);
                `OP_CRC32: expected_model = crc32_ref(x);

                default: expected_model = 32'h0000_0000;
            endcase
        end
    endfunction

    function expected_carry_model;
        input [31:0] x;
        input [31:0] y;
        input [6:0]  op;
        reg [32:0] add_ext;
        reg [32:0] sub_ext;
        begin
            add_ext = {1'b0, x} + {1'b0, y};
            sub_ext = {1'b0, x} - {1'b0, y};

            case (op)
                `OP_ADD: expected_carry_model = add_ext[32];
                `OP_SUB: expected_carry_model = sub_ext[32];
                default: expected_carry_model = 1'b0;
            endcase
        end
    endfunction

    function expected_overflow_model;
        input [31:0] x;
        input [31:0] y;
        input [31:0] r;
        input [6:0]  op;
        begin
            case (op)
                `OP_ADD:
                    expected_overflow_model =
                        ((~x[31] & ~y[31] & r[31]) |
                         ( x[31] &  y[31] & ~r[31]));

                `OP_SUB:
                    expected_overflow_model =
                        ((~x[31] &  y[31] & r[31]) |
                         ( x[31] & ~y[31] & ~r[31]));

                default:
                    expected_overflow_model = 1'b0;
            endcase
        end
    endfunction

    // =====================================================
    // Main check task
    // =====================================================
    task check_op;
        input [8*32-1:0] test_name;
        input [31:0]     test_A;
        input [31:0]     test_B;
        input [6:0]      test_opcode;
        input [4:0]      test_shamt;
        begin
            A      = test_A;
            B      = test_B;
            opcode = test_opcode;
            shamt  = test_shamt;

            #10;

            expected_result   = expected_model(test_A, test_B, test_opcode, test_shamt);
            expected_zero     = (expected_result == 32'h0000_0000);
            expected_negative = expected_result[31];
            expected_carry    = expected_carry_model(test_A, test_B, test_opcode);
            expected_overflow = expected_overflow_model(test_A, test_B, expected_result, test_opcode);

            if ((Result   === expected_result)   &&
                (Zero     === expected_zero)     &&
                (Negative === expected_negative) &&
                (Carry    === expected_carry)    &&
                (Overflow === expected_overflow)) begin

                pass_count = pass_count + 1;
                $display("[PASS] %-32s | A=%h B=%h shamt=%0d opcode=%b Result=%h",
                         test_name, A, B, shamt, opcode, Result);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %-32s | A=%h B=%h shamt=%0d opcode=%b",
                         test_name, A, B, shamt, opcode);

                $display("       Result   expected=%h got=%h", expected_result, Result);
                $display("       Zero     expected=%b got=%b", expected_zero, Zero);
                $display("       Negative expected=%b got=%b", expected_negative, Negative);
                $display("       Carry    expected=%b got=%b", expected_carry, Carry);
                $display("       Overflow expected=%b got=%b", expected_overflow, Overflow);
            end
        end
    endtask

    // =====================================================
    // Test sequence
    // =====================================================
    initial begin
        pass_count = 0;
        fail_count = 0;

        A = 32'd0;
        B = 32'd0;
        opcode = `OP_ADD;
        shamt = 5'd0;

        $display("====================================================");
        $display(" ALU32 CORE FULL TESTBENCH");
        $display("====================================================");

        // =================================================
        // Arithmetic
        // =================================================
        check_op("ADD basic",              32'd10,        32'd3,         `OP_ADD, 5'd0);
        check_op("ADD carry",              32'hFFFF_FFFF, 32'h0000_0001, `OP_ADD, 5'd0);
        check_op("ADD overflow positive",  32'h7FFF_FFFF, 32'h0000_0001, `OP_ADD, 5'd0);
        check_op("ADD overflow negative",  32'h8000_0000, 32'hFFFF_FFFF, `OP_ADD, 5'd0);

        check_op("SUB basic",              32'd10,        32'd3,         `OP_SUB, 5'd0);
        check_op("SUB zero",               32'd5,         32'd5,         `OP_SUB, 5'd0);
        check_op("SUB negative",           32'd3,         32'd10,        `OP_SUB, 5'd0);
        check_op("SUB overflow",           32'h8000_0000, 32'h0000_0001, `OP_SUB, 5'd0);

        // =================================================
        // Logic
        // =================================================
        check_op("AND",                    32'h0000_00F0, 32'h0000_000F, `OP_AND, 5'd0);
        check_op("OR",                     32'h0000_00F0, 32'h0000_000F, `OP_OR,  5'd0);
        check_op("XOR",                    32'h0000_00F0, 32'h0000_000F, `OP_XOR, 5'd0);
        check_op("NOT",                    32'hFFFF_0000, 32'h0000_0000, `OP_NOT, 5'd0);

        // =================================================
        // Compare
        // =================================================
        check_op("EQ true",                32'd10,        32'd10,        `OP_EQ, 5'd0);
        check_op("EQ false",               32'd10,        32'd3,         `OP_EQ, 5'd0);
        check_op("LT unsigned true",       32'd5,         32'd10,        `OP_LT_UNSIGNED, 5'd0);
        check_op("GT unsigned true",       32'd10,        32'd5,         `OP_GT_UNSIGNED, 5'd0);
        check_op("LT signed true",         -32'sd5,       32'sd10,       `OP_LT_SIGNED, 5'd0);
        check_op("GT signed true",         32'sd10,       -32'sd5,       `OP_GT_SIGNED, 5'd0);
        check_op("Signed vs unsigned diff",32'hFFFF_FFFF, 32'h0000_0001, `OP_LT_SIGNED, 5'd0);

        // =================================================
        // Shift
        // =================================================
        check_op("SLL 1 by 3",             32'h0000_0001, 32'd0,         `OP_SLL, 5'd3);
        check_op("SLL by 31",              32'h0000_0001, 32'd0,         `OP_SLL, 5'd31);
        check_op("SRL high bit",           32'h8000_0000, 32'd0,         `OP_SRL, 5'd1);
        check_op("SRA high bit",           32'h8000_0000, 32'd0,         `OP_SRA, 5'd1);
        check_op("SRA negative -8",        32'hFFFF_FFF8, 32'd0,         `OP_SRA, 5'd1);

        check_op("FSL",                    32'h1234_5678, 32'hABCD_EF00, `OP_FSL, 5'd8);
        check_op("FSR",                    32'h1234_5678, 32'hABCD_EF00, `OP_FSR, 5'd8);

        // =================================================
        // Extension
        // =================================================
        check_op("ZEXT16",                 32'hFFFF_8123, 32'd0,         `OP_ZEXT16, 5'd0);
        check_op("SEXT16 negative",        32'h0000_8123, 32'd0,         `OP_SEXT16, 5'd0);
        check_op("SEXT16 positive",        32'h0000_7123, 32'd0,         `OP_SEXT16, 5'd0);

        // =================================================
        // Reverse
        // =================================================
        check_op("REV1",                   32'h0000_000F, 32'd0,         `OP_REV1, 5'd0);
        check_op("REV2",                   32'h0000_0003, 32'd0,         `OP_REV2, 5'd0);
        check_op("REV4",                   32'h1234_5678, 32'd0,         `OP_REV4, 5'd0);
        check_op("REV8",                   32'h1234_5678, 32'd0,         `OP_REV8, 5'd0);
        check_op("REV16",                  32'h1234_5678, 32'd0,         `OP_REV16, 5'd0);

        // =================================================
        // OR-combine
        // =================================================
        check_op("ORC1",                   32'h1234_5678, 32'd0,         `OP_ORC1, 5'd0);
        check_op("ORC2",                   32'h0000_0003, 32'd0,         `OP_ORC2, 5'd0);
        check_op("ORC4",                   32'h1000_0001, 32'd0,         `OP_ORC4, 5'd0);
        check_op("ORC8",                   32'h1200_00F0, 32'd0,         `OP_ORC8, 5'd0);
        check_op("ORC16 low",              32'h0000_1234, 32'd0,         `OP_ORC16, 5'd0);
        check_op("ORC16 high",             32'h1234_0000, 32'd0,         `OP_ORC16, 5'd0);
        check_op("ORC16 both",             32'h1234_5678, 32'd0,         `OP_ORC16, 5'd0);

        // =================================================
        // Bitcount
        // =================================================
        check_op("BITCOUNT zero",           32'h0000_0000, 32'd0,         `OP_BITCOUNT, 5'd0);
        check_op("BITCOUNT four",           32'h0000_000F, 32'd0,         `OP_BITCOUNT, 5'd0);
        check_op("BITCOUNT sixteen",        32'hFFFF_0000, 32'd0,         `OP_BITCOUNT, 5'd0);
        check_op("BITCOUNT thirty two",     32'hFFFF_FFFF, 32'd0,         `OP_BITCOUNT, 5'd0);
        check_op("BITCOUNT two",            32'h8000_0001, 32'd0,         `OP_BITCOUNT, 5'd0);

        // =================================================
        // Shuffle / Unshuffle
        // =================================================
        check_op("SHFL1",                   32'hA5C3_3C5A, 32'd0,         `OP_SHFL1, 5'd0);
        check_op("UNSHFL1",                 shfl1(32'hA5C3_3C5A), 32'd0,  `OP_UNSHFL1, 5'd0);

        check_op("SHFL2",                   32'h1234_5678, 32'd0,         `OP_SHFL2, 5'd0);
        check_op("UNSHFL2",                 shfl2(32'h1234_5678), 32'd0,  `OP_UNSHFL2, 5'd0);

        check_op("SHFL4",                   32'h1234_5678, 32'd0,         `OP_SHFL4, 5'd0);
        check_op("UNSHFL4",                 32'h1526_3748, 32'd0,         `OP_UNSHFL4, 5'd0);

        check_op("SHFL8",                   32'h1234_5678, 32'd0,         `OP_SHFL8, 5'd0);
        check_op("UNSHFL8",                 32'h1256_3478, 32'd0,         `OP_UNSHFL8, 5'd0);

        check_op("SHFL16",                  32'h1234_5678, 32'd0,         `OP_SHFL16, 5'd0);
        check_op("UNSHFL16",                32'h1234_5678, 32'd0,         `OP_UNSHFL16, 5'd0);

        // =================================================
        // Carry-less multiplication
        // =================================================
        check_op("CLMUL low small",          32'h0000_000B, 32'h0000_0005, `OP_CLMUL_LOW, 5'd0);
        check_op("CLMUL low by one",        32'h1234_5678, 32'h0000_0001, `OP_CLMUL_LOW, 5'd0);
        check_op("CLMUL low by zero",       32'hFFFF_FFFF, 32'h0000_0000, `OP_CLMUL_LOW, 5'd0);
        check_op("CLMUL high",              32'h8000_0000, 32'h0000_0002, `OP_CLMUL_HIGH, 5'd0);
        check_op("CLMUL low high-case",     32'h8000_0000, 32'h0000_0002, `OP_CLMUL_LOW, 5'd0);

        // =================================================
        // Unsigned multiplier
        // =================================================
        check_op("MUL low small",            32'h0000_000B, 32'h0000_0005, `OP_MUL_LOW, 5'd0);
        check_op("MUL low by one",          32'h1234_5678, 32'h0000_0001, `OP_MUL_LOW, 5'd0);
        check_op("MUL low by zero",         32'hFFFF_FFFF, 32'h0000_0000, `OP_MUL_LOW, 5'd0);
        check_op("MUL high",                32'h8000_0000, 32'h0000_0002, `OP_MUL_HIGH, 5'd0);
        check_op("MUL low high-case",       32'h8000_0000, 32'h0000_0002, `OP_MUL_LOW, 5'd0);

        // =================================================
        // Signed multiplication / Booth opcode in ALU core
        // =================================================
        check_op("BOOTH low -5*3",           -32'sd5,       32'sd3,        `OP_BOOTH_MUL_LOW, 5'd0);
        check_op("BOOTH high -5*3",          -32'sd5,       32'sd3,        `OP_BOOTH_MUL_HIGH, 5'd0);
        check_op("BOOTH low 5*-3",           32'sd5,        -32'sd3,       `OP_BOOTH_MUL_LOW, 5'd0);
        check_op("BOOTH low -5*-3",          -32'sd5,       -32'sd3,       `OP_BOOTH_MUL_LOW, 5'd0);

        // =================================================
        // CRC
        // =================================================
        check_op("CRC8 zero",                32'h0000_0000, 32'd0,         `OP_CRC8, 5'd0);
        check_op("CRC8 one",                 32'h0000_0001, 32'd0,         `OP_CRC8, 5'd0);
        check_op("CRC8 AB",                  32'h0000_00AB, 32'd0,         `OP_CRC8, 5'd0);
        check_op("CRC8 FF",                  32'h0000_00FF, 32'd0,         `OP_CRC8, 5'd0);

        check_op("CRC16 1234",               32'h0000_1234, 32'd0,         `OP_CRC16, 5'd0);
        check_op("CRC32 12345678",           32'h1234_5678, 32'd0,         `OP_CRC32, 5'd0);

        // =================================================
        // Summary
        // =================================================
        $display("====================================================");
        $display(" ALU32 CORE TEST SUMMARY");
        $display(" PASS = %0d", pass_count);
        $display(" FAIL = %0d", fail_count);
        $display("====================================================");

        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED. CHECK WAVEFORM AND LOG.");
        end

        #20;
        $finish;
    end

endmodule