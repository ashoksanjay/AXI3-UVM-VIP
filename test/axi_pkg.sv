package axi_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	`include "axi_xtn.sv"
	
	
	`include "mst_agt_config.sv"
	`include "slv_agt_config.sv"
	`include "env_config.sv"
	
	`include "axi_seq.sv"
	
	`include "mst_driver.sv"
	`include "mst_sequencer.sv"
	`include "mst_monitor.sv"
	`include "mst_agent.sv"
	`include "mst_agent_top.sv"
	
	`include "slv_driver.sv"
	`include "slv_sequencer.sv"
	`include "slv_monitor.sv"
	`include "slv_agent.sv"
	`include "slv_agent_top.sv"
	
	`include "virtual_sequencer.sv"
	`include "virtual_seq.sv"
	
	`include "axi_scoreboard.sv"
	`include "axi_env.sv"
	`include "axi_test.sv"
	
endpackage