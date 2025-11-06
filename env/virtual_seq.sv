class virtual_seq_base extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(virtual_seq_base)
	
	mst_sequencer m_seqr[];
	slv_sequencer s_seqr[];
	
	master_seq_fixed fixed;
	master_seq_incr incr;
	master_seq_wrap wrap;
	master_seq_random random;
	
	virtual_sequencer v_seqrh;
	env_config e_cfg;
	
	function new(string name= "virtual_seq_base");
		super.new(name);
	endfunction		
		
		task body();
			//super.body();
			if(!uvm_config_db #(env_config)::get(null, get_full_name(), "env_config", e_cfg))
				`uvm_fatal("VIRTUAL SEQUENCE", "Error while getting config")
			
			m_seqr = new[e_cfg.no_of_master];
			s_seqr = new[e_cfg.no_of_slave];
			
			assert($cast(v_seqrh, m_sequencer)) else begin
				`uvm_fatal("VIRTUAL_SEQUENCE", "Error while casting in vseq");
			end
			
			if(e_cfg.has_master) begin
				foreach(m_seqr[i]) begin
					m_seqr[i] = v_seqrh.m_seqr[i];
				end	
			end
			
		endtask

	
endclass

class fixed_vseq extends virtual_seq_base;
	`uvm_object_utils(fixed_vseq)
	
	function new(string name = "fixed_vseq");
		super.new(name);
	endfunction
	
	task body();
		super.body();
		fixed = master_seq_fixed::type_id::create("fixed");
		foreach(m_seqr[i])
			fixed.start(m_seqr[i]);
	endtask
endclass

class incr_vseq extends virtual_seq_base;
	`uvm_object_utils(incr_vseq)
	
	function new(string name = "incr_vseq");
		super.new(name);
	endfunction
	
	task body();
		super.body();
		incr = master_seq_incr::type_id::create("incr");
		foreach(m_seqr[i])
			incr.start(m_seqr[i]);
	endtask
endclass

class wrap_vseq extends virtual_seq_base;
	`uvm_object_utils(wrap_vseq)
	
	function new(string name = "wrap_vseq");
		super.new(name);
	endfunction
	
	task body();
		super.body();
		wrap = master_seq_wrap::type_id::create("wrap");
		foreach(m_seqr[i])
			wrap.start(m_seqr[i]);
	endtask
endclass

class random_vseq extends virtual_seq_base;
	`uvm_object_utils(random_vseq)
	
	function new(string name = "random_vseq");
		super.new(name);
	endfunction
	
	task body();
		super.body();
		random = master_seq_random::type_id::create("random");
		foreach(m_seqr[i])
			random.start(m_seqr[i]);
	endtask
endclass