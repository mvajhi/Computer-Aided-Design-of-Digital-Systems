alias clc ".main clear"

# Clear the simulation environment
clc
exec vlib work
vmap work work

# Set testbench and paths
set TB "testbench2_3"
set hdl_path "../src/hdl"
set inc_path "../src/inc"

# Set the runtime for simulation
set run_time "10 ns"
# Uncomment the line below for an unlimited runtime
# set run_time "-all"

#============================ Add Verilog Files ===============================
# Add your HDL source files here
vlog +acc -incr -source +define+SIM $hdl_path/IF_buf_read.v
vlog +acc -incr -source +define+SIM $hdl_path/buffer.v
vlog +acc -incr -source +define+SIM $hdl_path/datapath.v
vlog +acc -incr -source +define+SIM $hdl_path/filt_buf_read.v
vlog +acc -incr -source +define+SIM $hdl_path/read_addr_gen.v
vlog +acc -incr -source +define+SIM $hdl_path/top.v
vlog +acc -incr -source +define+SIM $hdl_path/aux_mir.v
vlog +acc -incr -source +define+SIM $hdl_path/Mux2to1.v
vlog +acc -incr -source +define+SIM $hdl_path/P_Sum_Scratch.v
vlog +acc -incr -source +define+SIM $hdl_path/controller.v
vlog +acc -incr -source +define+SIM $hdl_path/fifo_buffer.v
vlog +acc -incr -source +define+SIM $hdl_path/out_buf.v
vlog +acc -incr -source +define+SIM $hdl_path/scratches.v

# Add the implementation options file if applicable
# vlog +acc -incr -source +define+SIM $inc_path/implementation_option.vh

# Add the testbench
vlog +acc -incr -source +incdir+$inc_path +define+SIM ./tb/$TB.v
onerror {break}

#================================ Simulation ====================================
vsim -voptargs=+acc -debugDB $TB

#======================= Adding Signals to Wave Window ==========================
add wave -hex -group {TB} sim:/$TB/*
add wave -hex -group {top} sim:/$TB/uut/*
add wave -hex -group -r {all} sim:/$TB/*
add wave -hex -position end  sim:/testbench2/uut/datapath/p_sum_scratch_pad/buffer/memory
add wave -position insertpoint sim:/testbench2_3/uut/datapath/mult_inp
add wave -position insertpoint sim:/testbench2_3/uut/datapath/filt_scratch_out
add wave -position insertpoint sim:/testbench2_3/uut/datapath/IF_scratch_reg_out
add wave -position end  sim:/testbench2_3/uut/out_buffer/buffer/memory

#=========================== Configure Wave Signals =============================
configure wave -signalnamewidth 2

#====================================== Run =====================================
run $run_time
