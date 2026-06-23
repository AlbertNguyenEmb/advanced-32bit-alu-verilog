# Verification Plan

## 1. Project Overview

This document describes the verification strategy for the **Advanced 32-bit ALU Verilog Project**.

The ALU is designed to support basic arithmetic, logic, comparison, shift, funnel shift, bit manipulation, multiplication, carry-less multiplication, CRC, and extension operations.

The verification goal is to ensure that each functional unit works correctly in isolation and that the top-level ALU correctly selects the expected result based on the opcode.

---

## 2. DUT Information

### 2.1 Design Under Test

| Item             | Description                          |
| ---------------- | ------------------------------------ |
| Project          | Advanced 32-bit ALU                  |
| Data width       | 32 bits                              |
| Opcode width     | 7 bits                               |
| HDL              | Verilog                              |
| Simulator        | ModelSim - Intel FPGA Edition 2020.1 |
| Main opcode file | `rtl/alu32_defines.vh`               |
| Opcode table     | `docs/opcode_table.md`               |

---

## 3. Verification Scope

The verification scope includes both **unit-level verification** and **top-level ALU verification**.

### 3.1 Unit-Level Verification

Each submodule is verified independently before integration.

| Unit                  | File                       | Verification Goal                              |
| --------------------- | -------------------------- | ---------------------------------------------- |
| Arithmetic Unit       | `arithmetic_unit.v`        | Verify ADD and SUB operations, carry, overflow |
| Logic Unit            | `logic_unit.v`             | Verify AND, OR, XOR, NOT                       |
| Comparator Unit       | `comparator32.v`           | Verify signed and unsigned comparison          |
| Barrel Shifter        | `barrel_shifter32.v`       | Verify SLL, SRL, SRA                           |
| Funnel Shifter        | `funnel_shifter32.v`       | Verify FSL and FSR                             |
| Extender Unit         | `extender_unit.v`          | Verify zero-extension and sign-extension       |
| Reverse Unit          | `reverse_unit.v`           | Verify REV1, REV2, REV4, REV8, REV16           |
| OR-Combine Unit       | `or_combine_unit.v`        | Verify ORC1, ORC2, ORC4, ORC8, ORC16           |
| Bitcount Unit         | `bitcount_unit.v`          | Verify population count                        |
| Shuffle Unit          | `shuffle_unit.v`           | Verify shuffle and unshuffle operations        |
| Carry-less Multiplier | `carryless_multiplier32.v` | Verify CLMUL low and high results              |
| Multiplier Unit       | `multiplier32.v`           | Verify low and high multiplication results     |
| Booth Multiplier      | `booth_multiplier32.v`     | Verify signed multiplication                   |
| CRC Unit              | `crc_unit.v`               | Verify CRC8, CRC16, CRC32                      |

### 3.2 Top-Level Verification

The top-level ALU verification checks whether:

1. The correct unit is selected based on `op[6:0]`.
2. The output result matches the expected result.
3. Status flags are generated correctly.
4. Invalid opcodes produce safe default outputs.
5. Sequential units correctly assert `busy` and `done`.

---

## 4. Verification Methodology

The project uses a simple but structured Verilog testbench methodology.

The verification flow is:

```text
Apply input stimulus
        |
        v
Drive opcode and operands
        |
        v
Wait for combinational or sequential result
        |
        v
Compare DUT output with expected value
        |
        v
Print PASS or FAIL message
```

For combinational modules, the output is checked after a small delay.

For sequential modules such as multi-cycle multiplier or Booth multiplier, the testbench waits for `done` before checking the result.

---

## 5. Testbench Structure

Each testbench should contain:

| Section            | Purpose                           |
| ------------------ | --------------------------------- |
| Signal declaration | Declare input and output signals  |
| DUT instantiation  | Connect testbench signals to DUT  |
| Clock generation   | Required for sequential modules   |
| Reset sequence     | Initialize DUT state              |
| Test tasks         | Reusable check functions          |
| Directed tests     | Manually selected important cases |
| Random tests       | Additional randomized validation  |
| PASS/FAIL counter  | Track total test result           |
| Final summary      | Print verification result         |

Example summary format:

```text
====================================
Verification Summary
Total tests : 120
Passed      : 120
Failed      : 0
Result      : PASS
====================================
```

---

## 6. Test Categories

## 6.1 Directed Tests

Directed tests are manually selected test cases used to check important corner cases.

### Arithmetic Unit

| Test ID   | Operation |        Input A | Input B | Expected Result | Purpose                             |
| --------- | --------- | -------------: | ------: | --------------: | ----------------------------------- |
| ARITH_001 | ADD       |            `0` |     `0` |             `0` | Basic zero addition                 |
| ARITH_002 | ADD       |            `1` |     `1` |             `2` | Basic addition                      |
| ARITH_003 | ADD       | `32'hFFFFFFFF` |     `1` |             `0` | Carry-out case                      |
| ARITH_004 | ADD       | `32'h7FFFFFFF` |     `1` |  `32'h80000000` | Signed overflow                     |
| ARITH_005 | SUB       |            `5` |     `3` |             `2` | Basic subtraction                   |
| ARITH_006 | SUB       |            `3` |     `5` |  `32'hFFFFFFFE` | Negative result in two's complement |
| ARITH_007 | SUB       | `32'h80000000` |     `1` |  `32'h7FFFFFFF` | Signed overflow                     |

---

### Logic Unit

| Test ID   | Operation |        Input A |        Input B | Expected Result |
| --------- | --------- | -------------: | -------------: | --------------: |
| LOGIC_001 | AND       | `32'hFFFF0000` | `32'h00FFFF00` |  `32'h00FF0000` |
| LOGIC_002 | OR        | `32'hFFFF0000` | `32'h00FFFF00` |  `32'hFFFFFF00` |
| LOGIC_003 | XOR       | `32'hAAAAAAAA` | `32'h55555555` |  `32'hFFFFFFFF` |
| LOGIC_004 | NOT       | `32'h00000000` |     Don't care |  `32'hFFFFFFFF` |
| LOGIC_005 | NOT       | `32'hFFFFFFFF` |     Don't care |  `32'h00000000` |

---

### Comparator Unit

| Test ID | Operation   |        Input A |        Input B | Expected Result | Purpose               |
| ------- | ----------- | -------------: | -------------: | --------------: | --------------------- |
| CMP_001 | EQ          |           `10` |           `10` |             `1` | Equal comparison      |
| CMP_002 | LT_UNSIGNED |            `5` |           `10` |             `1` | Unsigned less-than    |
| CMP_003 | GT_UNSIGNED |           `10` |            `5` |             `1` | Unsigned greater-than |
| CMP_004 | LT_SIGNED   | `32'hFFFFFFFF` |            `1` |             `1` | `-1 < 1` signed       |
| CMP_005 | GT_SIGNED   |            `1` | `32'hFFFFFFFF` |             `1` | `1 > -1` signed       |

---

### Shift Unit

| Test ID   | Operation |        Input A | Shift Amount | Expected Result |
| --------- | --------- | -------------: | -----------: | --------------: |
| SHIFT_001 | SLL       | `32'h00000001` |          `1` |  `32'h00000002` |
| SHIFT_002 | SLL       | `32'h00000001` |         `31` |  `32'h80000000` |
| SHIFT_003 | SRL       | `32'h80000000` |         `31` |  `32'h00000001` |
| SHIFT_004 | SRA       | `32'h80000000` |         `31` |  `32'hFFFFFFFF` |
| SHIFT_005 | SRA       | `32'h7FFFFFFF` |         `31` |  `32'h00000000` |

---

### Funnel Shifter Unit

| Test ID | Operation |        Input A |        Input B | Shift Amount | Purpose                  |
| ------- | --------- | -------------: | -------------: | -----------: | ------------------------ |
| FSL_001 | FSL       | `32'h12345678` | `32'hABCDEF00` |          `4` | Funnel shift left by 4   |
| FSL_002 | FSL       | `32'h12345678` | `32'hABCDEF00` |         `16` | Funnel shift left by 16  |
| FSR_001 | FSR       | `32'h12345678` | `32'hABCDEF00` |          `4` | Funnel shift right by 4  |
| FSR_002 | FSR       | `32'h12345678` | `32'hABCDEF00` |         `16` | Funnel shift right by 16 |

Expected results should be calculated using a reference expression inside the testbench.

---

### Extension Unit

| Test ID | Operation |        Input A | Expected Result |
| ------- | --------- | -------------: | --------------: |
| EXT_001 | ZEXT16    | `32'hFFFF8001` |  `32'h00008001` |
| EXT_002 | ZEXT16    | `32'h12345678` |  `32'h00005678` |
| EXT_003 | SEXT16    | `32'h00008001` |  `32'hFFFF8001` |
| EXT_004 | SEXT16    | `32'h00007FFF` |  `32'h00007FFF` |

---

### Bitcount Unit

| Test ID      |        Input A | Expected Result |
| ------------ | -------------: | --------------: |
| BITCOUNT_001 | `32'h00000000` |             `0` |
| BITCOUNT_002 | `32'hFFFFFFFF` |            `32` |
| BITCOUNT_003 | `32'h00000001` |             `1` |
| BITCOUNT_004 | `32'hAAAAAAAA` |            `16` |
| BITCOUNT_005 | `32'h55555555` |            `16` |

---

### Multiplication Unit

| Test ID   | Operation      |        Input A |        Input B |       Expected Result |
| --------- | -------------- | -------------: | -------------: | --------------------: |
| MUL_001   | MUL_LOW        |            `2` |            `3` |                   `6` |
| MUL_002   | MUL_LOW        | `32'hFFFFFFFF` |            `2` |         Lower 32 bits |
| MUL_003   | MUL_HIGH       | `32'hFFFFFFFF` | `32'hFFFFFFFF` |         Upper 32 bits |
| BOOTH_001 | BOOTH_MUL_LOW  |           `-2` |            `3` | Lower 32 bits of `-6` |
| BOOTH_002 | BOOTH_MUL_HIGH |           `-2` |            `3` | Upper 32 bits of `-6` |

---

### CRC Unit

| Test ID | Operation |              Input A | Expected Result |
| ------- | --------- | -------------------: | --------------: |
| CRC_001 | CRC8      | Selected test vector |     CRC8 result |
| CRC_002 | CRC16     | Selected test vector |    CRC16 result |
| CRC_003 | CRC32     | Selected test vector |    CRC32 result |

The CRC testbench should compare DUT output against known reference vectors or a behavioral reference model.

---

## 6.2 Random Tests

Random tests are used to increase input coverage.

Recommended random test count:

| Unit             | Random Tests |
| ---------------- | -----------: |
| Arithmetic Unit  |         1000 |
| Logic Unit       |          500 |
| Comparator Unit  |          500 |
| Shift Unit       |          500 |
| Funnel Shifter   |          500 |
| Bitcount Unit    |          500 |
| Multiplier Unit  |          200 |
| Booth Multiplier |          200 |
| CRC Unit         |          100 |

For each random test:

1. Generate random `a`.
2. Generate random `b`.
3. Generate random `shamt` if needed.
4. Compute expected result in testbench.
5. Compare DUT result with expected result.
6. Print error message if mismatch occurs.

---

## 7. Corner Cases

The following corner cases must be covered:

| Case                   | Value          |
| ---------------------- | -------------- |
| Zero                   | `32'h00000000` |
| All ones               | `32'hFFFFFFFF` |
| Minimum signed integer | `32'h80000000` |
| Maximum signed integer | `32'h7FFFFFFF` |
| Alternating pattern 1  | `32'hAAAAAAAA` |
| Alternating pattern 2  | `32'h55555555` |
| Lower 16-bit boundary  | `32'h0000FFFF` |
| Upper 16-bit boundary  | `32'hFFFF0000` |
| Shift amount 0         | `5'd0`         |
| Shift amount 1         | `5'd1`         |
| Shift amount 16        | `5'd16`        |
| Shift amount 31        | `5'd31`        |

---

## 8. Flag Verification

The following flags should be verified if they are implemented in the top-level ALU:

| Flag     | Meaning                                | Verification Method                       |
| -------- | -------------------------------------- | ----------------------------------------- |
| Zero     | Result is zero                         | Check `result == 32'b0`                   |
| Negative | Result MSB is 1                        | Check `result[31] == 1'b1`                |
| Carry    | Carry-out from addition or subtraction | Compare with 33-bit reference calculation |
| Overflow | Signed arithmetic overflow             | Check signed overflow condition           |

### Overflow Rules

For addition:

```verilog
overflow = (~a[31] & ~b[31] & result[31]) |
           ( a[31] &  b[31] & ~result[31]);
```

For subtraction:

```verilog
overflow = (~a[31] & b[31] & result[31]) |
           ( a[31] & ~b[31] & ~result[31]);
```

---

## 9. Sequential Unit Verification

Some modules may require multiple clock cycles, such as:

1. Shift-and-add multiplier
2. Booth multiplier
3. Multi-cycle shifter
4. CRC unit if implemented sequentially

For these modules, the testbench should verify:

| Signal   | Expected Behavior                    |
| -------- | ------------------------------------ |
| `start`  | Starts the operation                 |
| `busy`   | Goes high while operation is running |
| `done`   | Pulses high when operation completes |
| `result` | Valid when `done == 1`               |
| `rst`    | Returns DUT to idle state            |

Basic sequence:

```text
Reset DUT
Drive input operands
Assert start for 1 clock cycle
Wait while busy is high
Wait until done is high
Check result
Start next transaction
```

---

## 10. Pass/Fail Criteria

A test is considered passed if:

1. The DUT output exactly matches the expected result.
2. The DUT flags match the expected flags.
3. The DUT does not produce unknown values such as `x` or `z`.
4. Sequential modules assert `done` correctly.
5. The simulation completes without fatal errors.

The full verification is considered passed if:

```text
Total failed tests = 0
```

---

## 11. Regression Flow

The regression should compile all RTL files, compile testbenches, run simulations, and print a final PASS/FAIL summary.

Recommended ModelSim flow:

```tcl
vlib work

vlog +incdir+../../rtl ../../rtl/arithmetic/arithmetic_unit.v
vlog +incdir+../../rtl ../../rtl/logic/logic_unit.v
vlog +incdir+../../rtl ../../rtl/compare/comparator32.v
vlog +incdir+../../rtl ../../rtl/shift/barrel_shifter32.v
vlog +incdir+../../rtl ../../rtl/shift/funnel_shifter32.v
vlog +incdir+../../rtl ../../rtl/bitmanip/extender_unit.v
vlog +incdir+../../rtl ../../rtl/bitmanip/reverse_unit.v
vlog +incdir+../../rtl ../../rtl/bitmanip/or_combine_unit.v
vlog +incdir+../../rtl ../../rtl/bitmanip/bitcount_unit.v
vlog +incdir+../../rtl ../../rtl/bitmanip/shuffle_unit.v
vlog +incdir+../../rtl ../../rtl/arithmetic/carryless_multiplier32.v
vlog +incdir+../../rtl ../../rtl/crypto_crc/crc_unit.v

vlog +incdir+../../rtl ../../tb/tb_alu32_top.v

vsim work.tb_alu32_top
run -all
```

---

## 12. Recommended Testbench Files

Recommended testbench structure:

```text
tb/
├── unit/
│   ├── tb_arithmetic_unit.v
│   ├── tb_logic_unit.v
│   ├── tb_comparator32.v
│   ├── tb_barrel_shifter32.v
│   ├── tb_funnel_shifter32.v
│   ├── tb_extender_unit.v
│   ├── tb_reverse_unit.v
│   ├── tb_or_combine_unit.v
│   ├── tb_bitcount_unit.v
│   ├── tb_shuffle_unit.v
│   ├── tb_carryless_multiplier32.v
│   └── tb_crc_unit.v
│
└── integration/
    └── tb_alu32_top.v
```

---

## 13. Verification Progress Checklist

| Item                            | Status      |
| ------------------------------- | ----------- |
| Opcode table completed          | Done        |
| Arithmetic unit testbench       | To do       |
| Logic unit testbench            | To do       |
| Comparator unit testbench       | To do       |
| Shift unit testbench            | To do       |
| Funnel shifter testbench        | To do       |
| Extension unit testbench        | To do       |
| Reverse unit testbench          | To do       |
| OR-combine unit testbench       | To do       |
| Bitcount unit testbench         | To do       |
| Shuffle unit testbench          | To do       |
| Carry-less multiplier testbench | To do       |
| CRC unit testbench              | To do       |
| Top-level ALU testbench         | To do       |
| Regression script               | In progress |
| Waveform review                 | To do       |
| Final verification report       | To do       |

---

## 14. Final Verification Report Format

After running all tests, the final report should contain:

```text
====================================
Advanced 32-bit ALU Verification
====================================
Arithmetic Unit      : PASS
Logic Unit           : PASS
Comparator Unit      : PASS
Barrel Shifter       : PASS
Funnel Shifter       : PASS
Extender Unit        : PASS
Reverse Unit         : PASS
OR-Combine Unit      : PASS
Bitcount Unit        : PASS
Shuffle Unit         : PASS
Carryless Multiplier : PASS
CRC Unit             : PASS
Top-Level ALU        : PASS
------------------------------------
Total Tests          : XXXX
Passed               : XXXX
Failed               : 0
Final Result          : PASS
====================================
```

---

## 15. Future Improvements

Future verification improvements may include:

1. SystemVerilog self-checking testbench.
2. Functional coverage.
3. Constrained-random testing.
4. Python golden model.
5. Continuous integration using GitHub Actions.
6. Automated regression log generation.
7. Assertion-based verification.
8. UVM-based verification environment.
