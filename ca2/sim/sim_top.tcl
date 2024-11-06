	alias clc ".main clear"
	
	clc
	exec vlib work
	vmap work work
	
	set TB					"tb"
	set hdl_path			"../src/hdl"
	set inc_path			"../src/inc"
	
	# set run_time			"1 us"
	set run_time			"-all"

#============================ Add verilog files  ===============================
# Pleas add other module here	
	# vlog 	+acc -incr -source  +define+SIM 	$inc_path/implementation_option.vh
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/counter.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/datapath.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/decoder.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/fifo.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/handshake_controller.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/instant_buffer.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/mux.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/register.sv
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/up_down_counter.sv
		
	vlog 	+acc -incr -source  +incdir+$inc_path +define+SIM 	./tb/$TB.v
	onerror {break}

#================================ simulation ====================================

	vsim	-voptargs=+acc -debugDB $TB


#======================= adding signals to wave window ==========================


	add wave -hex -group 	 	{TB}				sim:/$TB/*
	add wave -hex -group 	 	{top}				sim:/$TB/uut/*	
	add wave -hex -group -r		{all}				sim:/$TB/*

#=========================== Configure wave signals =============================
	
	configure wave -signalnamewidth 2
    

#====================================== run =====================================

	run $run_time 
	