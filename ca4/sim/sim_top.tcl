	alias clc ".main clear"
	
	clc
	exec vlib work
	vmap work work
	
	set TB					"TB"
	set hdl_path			"../src/hdl"
	set inc_path			"../src/inc"

	set run_time			"-all"

#============================ Add verilog files  ===============================
# Pleas add other module here	
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ALUMinus.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/ALUMinus2.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Decrementer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/FIFOBUF2.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Incrementer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/MinThreshold.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/MUX2to1.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Register.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/SimpleBuf.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Threshold_unit.v


	vlog 	+acc -incr -source  +incdir+$inc_path +define+SIM 	./tb/$TB.sv
	onerror {break}

#================================ simulation ====================================

	vsim	-voptargs=+acc -debugDB $TB


#======================= adding signals to wave window ==========================


	add wave -hex -group 	 	{TB}				sim:/$TB/*
	add wave -hex -group 	 	{top}				sim:/$TB/UUT/*	
	add wave -hex -group -r		{all}				sim:/$TB/*

#=========================== Configure wave signals =============================
	
	configure wave -signalnamewidth 2
    

#====================================== run =====================================

	run $run_time 
	