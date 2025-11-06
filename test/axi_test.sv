class axi_test_base extends uvm_test;
	`uvm_component_utils(axi_test_base)
	
	bit has_scoreboard = 1;
	bit has_virtual_seq = 1;
	bit has_master = 1;
	bit has_slave = 1;
	
	int no_of_master = 1;
	int no_of_slaves = 1;
	
	env_config e_cfg;
	mst_agt_config m_cfg;
	slv_agt_config s_cfg;
	
	axi_env envh;
	
	function new(string name = "axi_test_base", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		e_cfg = env_config::type_id::create("e_cfg");
		config_axi();
		uvm_config_db #(env_config)::set(this, "*", "env_config", e_cfg);
		
		super.build_phase(phase);
		envh = axi_env::type_id::create("envh", this);
		
	endfunction
	
	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction
	
	function void config_axi();
		if(has_master) begin
			m_cfg = mst_agt_config::type_id::create("m_cfg");
			if(!uvm_config_db #(virtual axi_if)::get(this, "", "axi_if", m_cfg.mif))
				`uvm_fatal(get_type_name(), "Error while getting interface");
			m_cfg.no_of_master = no_of_master;
			e_cfg.m_cfg = m_cfg;
		end
		
		if(has_slave) begin
			s_cfg = slv_agt_config::type_id::create("s_cfg");
			if(!uvm_config_db #(virtual axi_if)::get(this, "", "axi_if", s_cfg.sif))
				`uvm_fatal(get_type_name(), "Error while getting interface");
			s_cfg.no_of_slaves = no_of_slaves;
			e_cfg.s_cfg = s_cfg;
		end
		
		
		
		e_cfg.has_scoreboard = has_scoreboard;
		e_cfg.has_virtual_seq = has_virtual_seq;
		e_cfg.has_master = has_master;
		e_cfg.has_slave = has_slave;
	endfunction
endclass

class fixed_seq_test extends axi_test_base;
	`uvm_component_utils(fixed_seq_test)
	fixed_vseq fixed_seq;
	
	function new(string name = "fixed_seq_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		fixed_seq = fixed_vseq::type_id::create("fixed_seq");
		phase.raise_objection(this);
			fixed_seq.start(envh.v_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass 

class incr_seq_test extends axi_test_base;
	`uvm_component_utils(incr_seq_test)
	incr_vseq incr_seq;
	
	function new(string name = "incr_seq_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		incr_seq = incr_vseq::type_id::create("incr_seq");
		phase.raise_objection(this);
			incr_seq.start(envh.v_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass 

class wrap_seq_test extends axi_test_base;
	`uvm_component_utils(wrap_seq_test)
	wrap_vseq wrap_seq;
	
	function new(string name = "wrap_seq_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		wrap_seq = wrap_vseq::type_id::create("wrap_seq");
		phase.raise_objection(this);
			wrap_seq.start(envh.v_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass 

// random...

class random_seq_test extends axi_test_base;
	`uvm_component_utils(random_seq_test)
	random_vseq random_seq;
	
	function new(string name = "random_seq_test", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	
	task run_phase(uvm_phase phase);
		random_seq = random_vseq::type_id::create("random_seq");
		phase.raise_objection(this);
			random_seq.start(envh.v_seqrh);
		phase.drop_objection(this);
	endtask
	
endclass 