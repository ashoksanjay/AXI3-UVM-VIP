class mst_agt_config extends uvm_object;
	`uvm_object_utils(mst_agt_config)
	
	virtual axi_if mif;
	uvm_active_passive_enum is_active = UVM_ACTIVE;
	int no_of_master;
	
	function new(string name = "mst_agt_config");
		super.new(name);
	endfunction
endclass