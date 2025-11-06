class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)
	
	env_config e_cfg;
	mst_agent_top m_agt_top;
	slv_agent_top s_agt_top;
	
	axi_scoreboard sb_h;
	virtual_sequencer v_seqrh;
	
	function new(string name = "axi_env", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(env_config)::get(this, "", "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		if(e_cfg.has_master) begin
			m_agt_top = mst_agent_top::type_id::create("m_agt_top", this);
			uvm_config_db #(mst_agt_config)::set(this, "m_agt_top*", "mst_agt_config", e_cfg.m_cfg);
		end
		
		if(e_cfg.has_slave) begin
			s_agt_top = slv_agent_top::type_id::create("s_agt_top", this);
			uvm_config_db #(slv_agt_config)::set(this, "s_agt_top*", "slv_agt_config", e_cfg.s_cfg);
		end
		
		if(e_cfg.has_scoreboard) begin
			sb_h = axi_scoreboard::type_id::create("sb_h", this); 
		end
		
		if(e_cfg.has_virtual_seq) begin
			v_seqrh = virtual_sequencer::type_id::create("v_seqrh", this);
		end
		
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(e_cfg.has_scoreboard) begin
			if(e_cfg.has_master) begin
				m_agt_top.mst_agt[0].monh.monitor_port.connect(sb_h.fifo_mst[0].analysis_export);
			end
			if(e_cfg.has_slave) begin
				s_agt_top.slv_agt[0].monh.monitor_port.connect(sb_h.fifo_slv[0].analysis_export);
			end
		end
		if(e_cfg.has_virtual_seq) begin
			if(e_cfg.has_master) begin
				for(int i = 0; i < e_cfg.no_of_master; i++) begin
					v_seqrh.m_seqr[i] = m_agt_top.mst_agt[i].seqrh;
				end
			end
		end
	endfunction
	
endclass