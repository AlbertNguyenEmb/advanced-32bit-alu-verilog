transcript on

if {[file exists work]} {
    vdel -lib work -all
}

vlib work

# Compile unit modules
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
vlog +incdir+../../rtl ../../rtl/arithmetic/multiplier_comb32.v

# Compile top ALU core and testbench
vlog +incdir+../../rtl ../../rtl/alu32_core.v
vlog +incdir+../../rtl ../../tb/alu32_core_tb.v

vsim work.alu32_core_tb

add wave -r sim:/alu32_core_tb/*
add wave -r sim:/alu32_core_tb/dut/*

run -all