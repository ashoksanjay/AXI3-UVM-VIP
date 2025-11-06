class slv_agent extends uvm_agent;
	`uvm_component_utils(slv_agent)
	
	slv_driver drvh;
	slv_sequencer seqrh;
	slv_monitor monh;
	
	slv_agt_config m_cfg;
	
	function new(string name = "slv_agent", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(slv_agt_config)::get(this, "", "slv_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		monh = slv_monitor::type_id::create("monh", this);
		if(m_cfg.is_active == UVM_ACTIVE) begin
			drvh = slv_driver::type_id::create("drvh", this);
			seqrh = slv_sequencer::type_id::create("seqrh", this);
		end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(m_cfg.is_active == UVM_ACTIVE)begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
	endfunction
endclass