class slv_sequencer extends uvm_sequencer #(axi_xtn);
	`uvm_component_utils(slv_sequencer)
	
	function new(string name = "slv_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
endclass