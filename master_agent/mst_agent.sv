class mst_agent extends uvm_agent;
	`uvm_component_utils(mst_agent)
	
	mst_driver drvh;
	mst_sequencer seqrh;
	mst_monitor monh;
	
	mst_agt_config m_cfg;
	
	function new(string name = "mst_agent", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(mst_agt_config)::get(this, "", "mst_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		monh = mst_monitor::type_id::create("monh", this);
		if(m_cfg.is_active == UVM_ACTIVE) begin
			drvh = mst_driver::type_id::create("drvh", this);
			seqrh = mst_sequencer::type_id::create("seqrh", this);
		end
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(m_cfg.is_active == UVM_ACTIVE)begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
	endfunction
endclass