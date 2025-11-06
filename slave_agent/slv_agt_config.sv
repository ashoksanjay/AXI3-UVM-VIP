class slv_agt_config extends uvm_object;
	`uvm_object_utils(slv_agt_config)
	
	virtual axi_if sif;
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	int no_of_slaves;
	
	function new(string name = "slv_agt_config");
		super.new(name);
	endfunction
endclass