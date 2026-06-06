transcript on

# Clean old work library
if {[file exists work]} {
    vdel -lib work -all
}

# Create work library
vlib work

# Compile RTL and testbench
vlog ../../rtl/alu32_core.v
vlog ../../tb/alu32_core_tb.v

# Start simulation
vsim work.alu32_core_tb

# Add waves
add wave -r sim:/alu32_core_tb/*

# Run all simulation
run -all