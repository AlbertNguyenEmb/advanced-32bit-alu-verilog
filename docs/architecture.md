# ALU RTL Architecture

The ALU is organized as a modular datapath. Each functional group is implemented as a separate RTL unit. The top-level `alu32_core` module instantiates all units and selects the final output using an opcode-based result multiplexer.

## Architecture Diagram

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
        +--> crc_unit
        +--> multiplier_comb32
        |
        v
   Result, Flags