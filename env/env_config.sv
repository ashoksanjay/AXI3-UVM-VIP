class env_config extends uvm_object;
	`uvm_object_utils(env_config)
	
	
	bit has_scoreboard;
	bit has_virtual_seq;
	bit has_master;
	bit has_slave;
	
	mst_agt_config m_cfg;
	slv_agt_config s_cfg;
	
	int no_of_master = 1;
	int no_of_slave = 1;
	
	function new(string name = "env_config");
		super.new(name);
	endfunction
	
endclass