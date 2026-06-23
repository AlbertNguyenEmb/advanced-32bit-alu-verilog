# Advanced 32-bit ALU in Verilog HDL

## Overview

This project implements a modular 32-bit Arithmetic Logic Unit (ALU) using Verilog HDL. The ALU supports arithmetic, logic, comparison, shifting, bit manipulation, carry-less multiplication, CRC error detection, and multiplier-related operations.

The project is designed for FPGA and RTL design practice. It uses a clean modular architecture, separate functional units, self-checking testbenches, and ModelSim/Questa simulation scripts.

The main purpose of this project is not only to build a working ALU, but also to practice professional RTL project organization, verification methodology, waveform debugging, and GitHub documentation.

---

## Key Features

### Basic Arithmetic and Logic

* 32-bit addition
* 32-bit subtraction
* Bitwise AND
* Bitwise OR
* Bitwise XOR
* Bitwise NOT

### Comparison Operations

* Equality comparison
* Unsigned less-than comparison
* Unsigned greater-than comparison
* Signed less-than comparison
* Signed greater-than comparison

### Status Flags

* Zero flag
* Negative flag
* Carry flag
* Overflow flag

### Shift Operations

* Logical shift left
* Logical shift right
* Arithmetic shift right
* Funnel shift left
* Funnel shift right

### Extension Operations

* Zero extension from 16-bit to 32-bit
* Sign extension from 16-bit to 32-bit

### Bit Manipulation Operations

* Reverse by 1-bit group
* Reverse by 2-bit group
* Reverse by 4-bit group
* Reverse by 8-bit group
* Reverse by 16-bit group
* OR-combine by 1-bit group
* OR-combine by 2-bit group
* OR-combine by 4-bit group
* OR-combine by 8-bit group
* OR-combine by 16-bit group
* Population count / bitcount
* Shuffle by 1-bit group
* Unshuffle by 1-bit group
* Shuffle by 2-bit group
* Unshuffle by 2-bit group
* Shuffle by 4-bit group
* Unshuffle by 4-bit group
* Shuffle by 8-bit group
* Unshuffle by 8-bit group
* Shuffle by 16-bit group
* Unshuffle by 16-bit group

### Advanced Arithmetic and Error Detection

* Carry-less multiplication low result
* Carry-less multiplication high result
* Unsigned shift-and-add multiplication low result
* Unsigned shift-and-add multiplication high result
* Signed multiplication low result
* Signed multiplication high result
* CRC-8
* CRC-16
* CRC-32 educational implementation

### Standalone Sequential Units

The project also includes standalone sequential modules for advanced RTL practice:

* Multicycle shifter
* Sequential shift-and-add multiplier
* Sequential Booth multiplier

These modules use:

* `clk`
* `rst`
* `start`
* `busy`
* `done`

---

## Project Structure

```text
advanced-32bit-alu-verilog/
│
├── rtl/
│   ├── alu32_core.v
│   ├── alu32_defines.vh
│   │
│   ├── arithmetic/
│   │   ├── arithmetic_unit.v
│   │   ├── carryless_multiplier32.v
│   │   ├── multiplier_comb32.v
│   │   ├── shift_add_multiplier32.v
│   │   └── booth_multiplier32.v
│   │
│   ├── logic/
│   │   └── logic_unit.v
│   │
│   ├── compare/
│   │   └── comparator32.v
│   │
│   ├── shift/
│   │   ├── barrel_shifter32.v
│   │   ├── funnel_shifter32.v
│   │   └── multicycle_shifter32.v
│   │
│   ├── bitmanip/
│   │   ├── extender_unit.v
│   │   ├── reverse_unit.v
│   │   ├── or_combine_unit.v
│   │   ├── bitcount_unit.v
│   │   └── shuffle_unit.v
│   │
│   └── crypto_crc/
│       └── crc_unit.v
│
├── tb/
│   ├── alu32_core_tb.v
│   ├── multicycle_shifter32_tb.v
│   ├── shift_add_multiplier32_tb.v
│   └── booth_multiplier32_tb.v
│
├── sim/
│   └── modelsim/
│       ├── run_refactor_core.do
│       ├── run_alu32_core_full.do
│       ├── run_multicycle_shifter.do
│       ├── run_shift_add_multiplier.do
│       └── run_booth_multiplier.do
│
├── docs/
│   ├── architecture.md
│   ├── opcode_table.md
│   ├── verification_plan.md
│   └── images/
│
├── constraints/
├── reports/
├── README.md
└── .gitignore
```

---

## ALU Core Interface

```verilog
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
```

### Signal Description

| Signal     | Direction |  Width | Description                      |
| ---------- | --------: | -----: | -------------------------------- |
| `A`        |     Input | 32-bit | First operand                    |
| `B`        |     Input | 32-bit | Second operand                   |
| `opcode`   |     Input |  7-bit | Operation selector               |
| `shamt`    |     Input |  5-bit | Shift amount                     |
| `Result`   |    Output | 32-bit | ALU result                       |
| `Zero`     |    Output |  1-bit | Set when `Result == 0`           |
| `Negative` |    Output |  1-bit | Set when `Result[31] == 1`       |
| `Carry`    |    Output |  1-bit | Carry flag for ADD/SUB           |
| `Overflow` |    Output |  1-bit | Signed overflow flag for ADD/SUB |

---

## Opcode Table

| Opcode    | Operation                      |
| --------- | ------------------------------ |
| `0000000` | ADD                            |
| `0000001` | SUB                            |
| `0000010` | AND                            |
| `0000011` | OR                             |
| `0000100` | XOR                            |
| `0000101` | NOT A                          |
| `0000110` | Equal                          |
| `0000111` | Less than unsigned             |
| `0001000` | Greater than unsigned          |
| `0001001` | Less than signed               |
| `0001010` | Greater than signed            |
| `0001011` | Shift left logical             |
| `0001100` | Shift right logical            |
| `0001101` | Shift right arithmetic         |
| `0001110` | Funnel shift left              |
| `0001111` | Funnel shift right             |
| `0010000` | Zero extension 16-bit          |
| `0010001` | Sign extension 16-bit          |
| `0010010` | Reverse by 1-bit group         |
| `0010011` | Reverse by 2-bit group         |
| `0010100` | Reverse by 4-bit group         |
| `0010101` | Reverse by 8-bit group         |
| `0010110` | Reverse by 16-bit group        |
| `0101111` | OR-combine by 1-bit group      |
| `0110000` | OR-combine by 2-bit group      |
| `0110001` | OR-combine by 4-bit group      |
| `0110010` | OR-combine by 8-bit group      |
| `0110011` | OR-combine by 16-bit group     |
| `0110100` | Bitcount / population count    |
| `0110101` | Shuffle by 1-bit group         |
| `0110110` | Unshuffle by 1-bit group       |
| `0110111` | Shuffle by 2-bit group         |
| `0111000` | Unshuffle by 2-bit group       |
| `0111001` | Shuffle by 4-bit group         |
| `0111010` | Unshuffle by 4-bit group       |
| `0111011` | Shuffle by 8-bit group         |
| `0111100` | Unshuffle by 8-bit group       |
| `0111101` | Shuffle by 16-bit group        |
| `0111110` | Unshuffle by 16-bit group      |
| `0111111` | Carry-less multiplication low  |
| `1000000` | Carry-less multiplication high |
| `1000001` | Unsigned multiplication low    |
| `1000010` | Unsigned multiplication high   |
| `1000011` | Signed multiplication low      |
| `1000100` | Signed multiplication high     |
| `1000101` | CRC-8                          |
| `1000110` | CRC-16                         |
| `1000111` | CRC-32                         |

---

## RTL Architecture

The ALU uses a modular RTL architecture. The top-level `alu32_core` module instantiates multiple functional units and selects the final output using an opcode-based result multiplexer.

```text
A, B, opcode, shamt
        |
        v
+-------------------+
|    alu32_core     |
+-------------------+
        |
        +--> arithmetic_unit
        +--> logic_unit
        +--> comparator32
        +--> barrel_shifter32
        +--> funnel_shifter32
        +--> extender_unit
        +--> reverse_unit
        +--> or_combine_unit
        +--> bitcount_unit
        +--> shuffle_unit
        +--> carryless_multiplier32
        +--> multiplier_comb32
        +--> crc_unit
        |
        v
   Result, Flags
```

The main ALU core is combinational. Sequential units such as the multicycle shifter, shift-and-add multiplier, and Booth multiplier are implemented as standalone modules and verified separately.

---

## Functional Unit Description

### `arithmetic_unit`

Handles:

* ADD
* SUB
* Carry flag
* Overflow flag

### `logic_unit`

Handles:

* AND
* OR
* XOR
* NOT

### `comparator32`

Handles:

* Equal comparison
* Unsigned less-than / greater-than
* Signed less-than / greater-than

### `barrel_shifter32`

Handles:

* SLL
* SRL
* SRA

### `funnel_shifter32`

Handles:

* Funnel shift left
* Funnel shift right

### `extender_unit`

Handles:

* Zero extension
* Sign extension

### `reverse_unit`

Handles:

* Reverse by 1-bit, 2-bit, 4-bit, 8-bit, and 16-bit groups

### `or_combine_unit`

Handles:

* OR-combine by 1-bit, 2-bit, 4-bit, 8-bit, and 16-bit groups

### `bitcount_unit`

Handles:

* Population count of 32-bit input

### `shuffle_unit`

Handles:

* Shuffle and unshuffle by 1-bit, 2-bit, 4-bit, 8-bit, and 16-bit groups

### `carryless_multiplier32`

Implements carry-less multiplication using shift and XOR operations.

### `multiplier_comb32`

Implements unsigned shift-and-add multiplication using a combinational reference structure.

### `crc_unit`

Implements educational CRC operations:

* CRC-8 with polynomial `0x07`
* CRC-16 with polynomial `0x1021`
* CRC-32 with polynomial `0x04C11DB7`

---

## Verification Strategy

The project uses self-checking Verilog testbenches.

The main testbench is:

```text
tb/alu32_core_tb.v
```

It verifies:

* All major ALU opcodes
* Expected result values
* Zero flag
* Negative flag
* Carry flag
* Overflow flag
* Corner cases
* Signed and unsigned behavior
* Shift edge cases
* CRC outputs
* Multiplier low/high results

The testbench includes a golden reference model and automatically prints:

```text
[PASS]
[FAIL]
```

At the end of simulation, it prints a summary:

```text
ALU32 CORE TEST SUMMARY
PASS = ...
FAIL = ...
```

---

## Example Test Cases

### Arithmetic

```text
ADD: FFFFFFFF + 00000001 = 00000000, Carry = 1
ADD: 7FFFFFFF + 00000001 = 80000000, Overflow = 1
SUB: 00000003 - 0000000A = FFFFFFF9
```

### Shift

```text
SLL: 00000001 << 3 = 00000008
SRL: 80000000 >> 1 = 40000000
SRA: 80000000 >>> 1 = C0000000
```

### Reverse

```text
REV4: 12345678 -> 87654321
REV8: 12345678 -> 78563412
REV16: 12345678 -> 56781234
```

### Shuffle / Unshuffle

```text
SHFL4:   12345678 -> 15263748
UNSHFL4: 15263748 -> 12345678

SHFL8:   12345678 -> 12563478
UNSHFL8: 12563478 -> 12345678
```

### Carry-less Multiplication

```text
CLMUL: 0000000B carry-less multiply 00000005 = 00000027
```

### Unsigned Multiplication

```text
MUL: 0000000B * 00000005 = 00000037
```

### Signed Multiplication

```text
-5 * 3 = -15
LOW  = FFFFFFF1
HIGH = FFFFFFFF
```

### CRC

```text
CRC8(00) = 00
CRC8(01) = 07
CRC8(AB) = 58
CRC8(FF) = F3
```

---

## Running Simulation in ModelSim / Questa

Go to the simulation directory:

```tcl
cd sim/modelsim
```

Run the full ALU core simulation:

```tcl
do run_refactor_core.do
```

or:

```tcl
do run_alu32_core_full.do
```

The script will:

1. Delete the old `work` library
2. Create a new `work` library
3. Compile all RTL unit modules
4. Compile `alu32_core.v`
5. Compile `alu32_core_tb.v`
6. Load the simulation
7. Add waveform signals
8. Run all tests

---

## Example ModelSim Script

```tcl
transcript on

if {[file exists work]} {
    vdel -lib work -all
}

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
vlog +incdir+../../rtl ../../rtl/arithmetic/multiplier_comb32.v
vlog +incdir+../../rtl ../../rtl/crypto_crc/crc_unit.v

vlog +incdir+../../rtl ../../rtl/alu32_core.v
vlog +incdir+../../rtl ../../tb/alu32_core_tb.v

vsim work.alu32_core_tb

add wave -r sim:/alu32_core_tb/*
add wave -r sim:/alu32_core_tb/dut/*

run -all
```

---

## Notes on ModelSim Intel FPGA Edition

If the following message appears:

```text
ERROR: No extended dataflow license exists
```

it can usually be ignored for this project as long as Verilog compilation and simulation still run successfully.

The important lines to check are:

```text
Errors: 0, Warnings: 0
```

and the final test summary:

```text
FAIL = 0
```

---

## Development Milestones

* [x] Project structure
* [x] Basic arithmetic and logic ALU
* [x] Comparator and flags
* [x] Shift operations
* [x] Extension unit
* [x] Reverse unit
* [x] OR-combine unit
* [x] Bitcounting unit
* [x] Shuffle and unshuffle unit
* [x] Funnel shifter
* [x] Carry-less multiplier
* [x] CRC unit
* [x] Unsigned shift-and-add multiplier
* [x] Signed multiply result operations
* [x] Sequential multicycle shifter
* [x] Sequential shift-and-add multiplier
* [x] Sequential Booth multiplier
* [x] Modular RTL refactor
* [x] Self-checking ALU core testbench
* [ ] FPGA top module for Arty Z7
* [ ] FPGA constraints
* [ ] Synthesis report
* [ ] Timing report
* [ ] Final waveform screenshots

---

## Tools

* Verilog HDL
* ModelSim Intel FPGA Edition
* Questa Intel FPGA Edition
* Git / GitHub
* Optional FPGA toolchain:

  * Vivado
  * Quartus Prime

---

## Design Notes

### Combinational Core

The main `alu32_core` is designed as a combinational ALU. It receives operands and an opcode, then produces a result and flags without requiring a clock.

### Sequential Units

Sequential modules such as the multicycle shifter and Booth multiplier are implemented separately. These modules are designed with FSMs and handshake-style control signals.

Typical control signals:

```text
start
busy
done
```

This separation makes the design easier to verify and keeps the ALU core clean.

### CRC Implementation

The CRC units are educational MSB-first implementations:

```text
CRC-8  polynomial:  0x07
CRC-16 polynomial:  0x1021
CRC-32 polynomial:  0x04C11DB7
```

They are intended for RTL learning and demonstration purposes, not as fully parameterized industrial CRC engines.

---

## Future Improvements

Possible next steps:

* Add random testing to the ALU core testbench
* Add functional coverage-style reporting
* Add FPGA top module for Arty Z7
* Add switch/button-controlled opcode selection
* Add seven-segment or LED output display
* Add Vivado synthesis project
* Add timing and resource utilization reports
* Add waveform screenshots to documentation
* Add Wallace tree multiplier
* Add pipelined ALU version
* Add SystemVerilog testbench version
* Add UVM-lite verification environment

---

## Author

Albert Nguyen

---

## License

This project is intended for educational and portfolio purposes.
