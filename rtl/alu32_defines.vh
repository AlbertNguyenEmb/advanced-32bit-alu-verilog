`ifndef ALU32_DEFINES_VH
`define ALU32_DEFINES_VH

// =====================================================
// ALU32 Opcode Definitions
// Width: 7 bits
// =====================================================

// Basic arithmetic and logic opcodes
`define OP_ADD  7'b0000000
`define OP_SUB  7'b0000001
`define OP_AND  7'b0000010
`define OP_OR   7'b0000011
`define OP_XOR  7'b0000100
`define OP_NOT  7'b0000101

// Comparison opcodes
`define OP_EQ           7'b0000110
`define OP_LT_UNSIGNED  7'b0000111
`define OP_GT_UNSIGNED  7'b0001000
`define OP_LT_SIGNED    7'b0001001
`define OP_GT_SIGNED    7'b0001010

// Shift opcodes
`define OP_SLL  7'b0001011
`define OP_SRL  7'b0001100
`define OP_SRA  7'b0001101
`define OP_FSL  7'b0001110
`define OP_FSR  7'b0001111

// Extension opcodes
`define OP_ZEXT16  7'b0010000
`define OP_SEXT16  7'b0010001

// Reverse opcodes
`define OP_REV1   7'b0010010
`define OP_REV2   7'b0010011
`define OP_REV4   7'b0010100
`define OP_REV8   7'b0010101
`define OP_REV16  7'b0010110

// OR-Combine opcodes
`define OP_ORC1   7'b0101111
`define OP_ORC2   7'b0110000
`define OP_ORC4   7'b0110001
`define OP_ORC8   7'b0110010
`define OP_ORC16  7'b0110011

// Bitcount opcode
`define OP_BITCOUNT  7'b0110100

// Shuffle / Unshuffle opcodes
`define OP_SHFL1     7'b0110101
`define OP_UNSHFL1   7'b0110110
`define OP_SHFL2     7'b0110111
`define OP_UNSHFL2   7'b0111000
`define OP_SHFL4     7'b0111001
`define OP_UNSHFL4   7'b0111010
`define OP_SHFL8     7'b0111011
`define OP_UNSHFL8   7'b0111100
`define OP_SHFL16    7'b0111101
`define OP_UNSHFL16  7'b0111110

// Carry-less Multiplication - CLMUL
`define OP_CLMUL_LOW   7'b0111111
`define OP_CLMUL_HIGH  7'b1000000

// Shift-and-Add Multiplier
`define OP_MUL_LOW   7'b1000001
`define OP_MUL_HIGH  7'b1000010

// Booth Multiplier32
`define OP_BOOTH_MUL_LOW   7'b1000011
`define OP_BOOTH_MUL_HIGH  7'b1000100

// CRC opcodes
`define OP_CRC8   7'b1000101
`define OP_CRC16  7'b1000110
`define OP_CRC32  7'b1000111
`endif