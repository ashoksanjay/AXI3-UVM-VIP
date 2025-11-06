module top;
	import uvm_pkg::*;
	import axi_pkg::*;
	
	`include "uvm_macros.svh"
	
	bit clock;
	always #5 clock = ~clock;
	axi_if axi_if0(clock);
	
	axi_xtn xtn;
	initial begin
		uvm_config_db #(virtual axi_if)::set(null, "*", "axi_if", axi_if0);
		run_test();
	end
endmodule