# ALU32 Opcode Table

This document defines the opcode map used by the Advanced 32-bit ALU project.

* Opcode width: **7 bits**
* Control signal: `op[6:0]`
* Definition file: `rtl/alu32_defines.vh`
* Usage style:

```verilog
case (op)
    `OP_ADD: begin
        // ADD operation
    end
endcase
```

---

## 1. Basic Arithmetic and Logic Opcodes

| Macro    | Binary Opcode |    Hex | Category   | Description                       |
| -------- | ------------: | -----: | ---------- | --------------------------------- |
| `OP_ADD` |  `7'b0000000` | `0x00` | Arithmetic | Add two 32-bit operands           |
| `OP_SUB` |  `7'b0000001` | `0x01` | Arithmetic | Subtract operand B from operand A |
| `OP_AND` |  `7'b0000010` | `0x02` | Logic      | Bitwise AND                       |
| `OP_OR`  |  `7'b0000011` | `0x03` | Logic      | Bitwise OR                        |
| `OP_XOR` |  `7'b0000100` | `0x04` | Logic      | Bitwise XOR                       |
| `OP_NOT` |  `7'b0000101` | `0x05` | Logic      | Bitwise NOT of operand A          |

---

## 2. Comparison Opcodes

| Macro            | Binary Opcode |    Hex | Category | Description                      |
| ---------------- | ------------: | -----: | -------- | -------------------------------- |
| `OP_EQ`          |  `7'b0000110` | `0x06` | Compare  | Check if A is equal to B         |
| `OP_LT_UNSIGNED` |  `7'b0000111` | `0x07` | Compare  | Unsigned less-than comparison    |
| `OP_GT_UNSIGNED` |  `7'b0001000` | `0x08` | Compare  | Unsigned greater-than comparison |
| `OP_LT_SIGNED`   |  `7'b0001001` | `0x09` | Compare  | Signed less-than comparison      |
| `OP_GT_SIGNED`   |  `7'b0001010` | `0x0A` | Compare  | Signed greater-than comparison   |

---

## 3. Shift and Funnel Shift Opcodes

| Macro    | Binary Opcode |    Hex | Category     | Description            |
| -------- | ------------: | -----: | ------------ | ---------------------- |
| `OP_SLL` |  `7'b0001011` | `0x0B` | Shift        | Logical shift left     |
| `OP_SRL` |  `7'b0001100` | `0x0C` | Shift        | Logical shift right    |
| `OP_SRA` |  `7'b0001101` | `0x0D` | Shift        | Arithmetic shift right |
| `OP_FSL` |  `7'b0001110` | `0x0E` | Funnel Shift | Funnel shift left      |
| `OP_FSR` |  `7'b0001111` | `0x0F` | Funnel Shift | Funnel shift right     |

---

## 4. Extension Opcodes

| Macro       | Binary Opcode |    Hex | Category  | Description                          |
| ----------- | ------------: | -----: | --------- | ------------------------------------ |
| `OP_ZEXT16` |  `7'b0010000` | `0x10` | Extension | Zero-extend lower 16 bits to 32 bits |
| `OP_SEXT16` |  `7'b0010001` | `0x11` | Extension | Sign-extend lower 16 bits to 32 bits |

---

## 5. Reverse Opcodes

| Macro      | Binary Opcode |    Hex | Category         | Description                |
| ---------- | ------------: | -----: | ---------------- | -------------------------- |
| `OP_REV1`  |  `7'b0010010` | `0x12` | Bit Manipulation | Reverse every 1-bit group  |
| `OP_REV2`  |  `7'b0010011` | `0x13` | Bit Manipulation | Reverse every 2-bit group  |
| `OP_REV4`  |  `7'b0010100` | `0x14` | Bit Manipulation | Reverse every 4-bit group  |
| `OP_REV8`  |  `7'b0010101` | `0x15` | Bit Manipulation | Reverse every 8-bit group  |
| `OP_REV16` |  `7'b0010110` | `0x16` | Bit Manipulation | Reverse every 16-bit group |

---

## 6. OR-Combine Opcodes

| Macro      | Binary Opcode |    Hex | Category         | Description                   |
| ---------- | ------------: | -----: | ---------------- | ----------------------------- |
| `OP_ORC1`  |  `7'b0101111` | `0x2F` | Bit Manipulation | OR-combine every 1-bit group  |
| `OP_ORC2`  |  `7'b0110000` | `0x30` | Bit Manipulation | OR-combine every 2-bit group  |
| `OP_ORC4`  |  `7'b0110001` | `0x31` | Bit Manipulation | OR-combine every 4-bit group  |
| `OP_ORC8`  |  `7'b0110010` | `0x32` | Bit Manipulation | OR-combine every 8-bit group  |
| `OP_ORC16` |  `7'b0110011` | `0x33` | Bit Manipulation | OR-combine every 16-bit group |

---

## 7. Bit Count Opcode

| Macro         | Binary Opcode |    Hex | Category         | Description                             |
| ------------- | ------------: | -----: | ---------------- | --------------------------------------- |
| `OP_BITCOUNT` |  `7'b0110100` | `0x34` | Bit Manipulation | Count the number of 1 bits in operand A |

---

## 8. Shuffle and Unshuffle Opcodes

| Macro         | Binary Opcode |    Hex | Category         | Description                  |
| ------------- | ------------: | -----: | ---------------- | ---------------------------- |
| `OP_SHFL1`    |  `7'b0110101` | `0x35` | Bit Manipulation | Shuffle every 1-bit group    |
| `OP_UNSHFL1`  |  `7'b0110110` | `0x36` | Bit Manipulation | Unshuffle every 1-bit group  |
| `OP_SHFL2`    |  `7'b0110111` | `0x37` | Bit Manipulation | Shuffle every 2-bit group    |
| `OP_UNSHFL2`  |  `7'b0111000` | `0x38` | Bit Manipulation | Unshuffle every 2-bit group  |
| `OP_SHFL4`    |  `7'b0111001` | `0x39` | Bit Manipulation | Shuffle every 4-bit group    |
| `OP_UNSHFL4`  |  `7'b0111010` | `0x3A` | Bit Manipulation | Unshuffle every 4-bit group  |
| `OP_SHFL8`    |  `7'b0111011` | `0x3B` | Bit Manipulation | Shuffle every 8-bit group    |
| `OP_UNSHFL8`  |  `7'b0111100` | `0x3C` | Bit Manipulation | Unshuffle every 8-bit group  |
| `OP_SHFL16`   |  `7'b0111101` | `0x3D` | Bit Manipulation | Shuffle every 16-bit group   |
| `OP_UNSHFL16` |  `7'b0111110` | `0x3E` | Bit Manipulation | Unshuffle every 16-bit group |

---

## 9. Carry-less Multiplication Opcodes

| Macro           | Binary Opcode |    Hex | Category                  | Description                                       |
| --------------- | ------------: | -----: | ------------------------- | ------------------------------------------------- |
| `OP_CLMUL_LOW`  |  `7'b0111111` | `0x3F` | Carry-less Multiplication | Lower 32 bits of carry-less multiplication result |
| `OP_CLMUL_HIGH` |  `7'b1000000` | `0x40` | Carry-less Multiplication | Upper 32 bits of carry-less multiplication result |

---

## 10. Shift-and-Add Multiplier Opcodes

| Macro         | Binary Opcode |    Hex | Category       | Description                                     |
| ------------- | ------------: | -----: | -------------- | ----------------------------------------------- |
| `OP_MUL_LOW`  |  `7'b1000001` | `0x41` | Multiplication | Lower 32 bits of unsigned multiplication result |
| `OP_MUL_HIGH` |  `7'b1000010` | `0x42` | Multiplication | Upper 32 bits of unsigned multiplication result |

---

## 11. Booth Multiplier Opcodes

| Macro               | Binary Opcode |    Hex | Category              | Description                                  |
| ------------------- | ------------: | -----: | --------------------- | -------------------------------------------- |
| `OP_BOOTH_MUL_LOW`  |  `7'b1000011` | `0x43` | Signed Multiplication | Lower 32 bits of Booth multiplication result |
| `OP_BOOTH_MUL_HIGH` |  `7'b1000100` | `0x44` | Signed Multiplication | Upper 32 bits of Booth multiplication result |

---

## 12. CRC Opcodes

| Macro      | Binary Opcode |    Hex | Category | Description    |
| ---------- | ------------: | -----: | -------- | -------------- |
| `OP_CRC8`  |  `7'b1000101` | `0x45` | CRC      | Compute CRC-8  |
| `OP_CRC16` |  `7'b1000110` | `0x46` | CRC      | Compute CRC-16 |
| `OP_CRC32` |  `7'b1000111` | `0x47` | CRC      | Compute CRC-32 |

---

## 13. Opcode Allocation Summary

| Range                       |       Hex Range | Usage                        |
| --------------------------- | --------------: | ---------------------------- |
| `7'b0000000` - `7'b0000101` | `0x00` - `0x05` | Basic arithmetic and logic   |
| `7'b0000110` - `7'b0001010` | `0x06` - `0x0A` | Comparison                   |
| `7'b0001011` - `7'b0001111` | `0x0B` - `0x0F` | Shift and funnel shift       |
| `7'b0010000` - `7'b0010001` | `0x10` - `0x11` | Extension                    |
| `7'b0010010` - `7'b0010110` | `0x12` - `0x16` | Reverse                      |
| `7'b0101111` - `7'b0110011` | `0x2F` - `0x33` | OR-combine                   |
| `7'b0110100`                |          `0x34` | Bit count                    |
| `7'b0110101` - `7'b0111110` | `0x35` - `0x3E` | Shuffle / Unshuffle          |
| `7'b0111111` - `7'b1000000` | `0x3F` - `0x40` | Carry-less multiplication    |
| `7'b1000001` - `7'b1000010` | `0x41` - `0x42` | Shift-and-add multiplication |
| `7'b1000011` - `7'b1000100` | `0x43` - `0x44` | Booth multiplication         |
| `7'b1000101` - `7'b1000111` | `0x45` - `0x47` | CRC                          |

---

## 14. Notes

1. All opcodes must be kept consistent with `rtl/alu32_defines.vh`.
2. Every module that uses opcode macros should include:

```verilog
`include "alu32_defines.vh"
```

3. The ALU control input should be declared as:

```verilog
input wire [6:0] op
```

4. Avoid using plain names such as `EQ`, `LT_UNSIGNED`, or `GT_UNSIGNED`. Use the consistent macro naming style:

```verilog
`OP_EQ
`OP_LT_UNSIGNED
`OP_GT_UNSIGNED
```

5. When adding a new operation, update both:

   * `rtl/alu32_defines.vh`
   * `docs/opcode_table.md`
