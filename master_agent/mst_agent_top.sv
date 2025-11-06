class mst_agent_top extends uvm_env;
	`uvm_component_utils(mst_agent_top)
	
	mst_agent mst_agt[];
	mst_agt_config m_cfg;
	
	function new(string name = "mst_agent_top", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(mst_agt_config)::get(this, "", "mst_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while geting config")
		mst_agt = new[m_cfg.no_of_master];
		foreach(mst_agt[i]) begin
			mst_agt[i] = mst_agent::type_id::create($sformatf("mst_agt[%0d]", i), this);
		end
	endfunction

endclass