class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
	`uvm_component_utils(virtual_sequencer)
		mst_sequencer m_seqr[];
		slv_sequencer s_seqr[];
		env_config e_cfg;
		
	function new(string name = "virtual_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(env_config)::get(this, "", "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		
		m_seqr = new[e_cfg.no_of_master];
		s_seqr = new[e_cfg.no_of_slave];
	endfunction
	
endclass
