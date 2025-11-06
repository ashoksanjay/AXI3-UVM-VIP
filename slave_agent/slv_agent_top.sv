class slv_agent_top extends uvm_env;
	`uvm_component_utils(slv_agent_top)
	
	slv_agent slv_agt[];
	slv_agt_config m_cfg;
	
	function new(string name = "slv_agent_top", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slv_agt_config)::get(this, "", "slv_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while geting config")
		slv_agt = new[m_cfg.no_of_slaves];
		foreach(slv_agt[i]) begin
			slv_agt[i] = slv_agent::type_id::create($sformatf("slv_agt[%0d]", i), this);
		end
	endfunction

endclass