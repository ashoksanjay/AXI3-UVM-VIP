class axi_seq_base extends uvm_sequence #(axi_xtn);
	`uvm_object_utils(axi_seq_base)
	
	int no_of_trans = 50;
	int delay = no_of_trans * 500;
	env_config e_cfg;
	
	function new(string name = "axi_seq_base");
		super.new(name);
	endfunction
	
	
endclass

class master_seq_fixed extends axi_seq_base;
	`uvm_object_utils(master_seq_fixed)
	
	function new(string name = "master_seq_fixed");
		super.new(name);
	endfunction
	
	task body();
		
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 0; arburst == 0;});
			finish_item(req);
		end
		#delay;
	endtask
endclass

class master_seq_incr extends axi_seq_base;
	`uvm_object_utils(master_seq_incr)
	
	function new(string name = "master_seq_incr");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 1; arburst == 1;});
			finish_item(req);
		end
		#delay;
	endtask
endclass

class master_seq_wrap extends axi_seq_base;
	`uvm_object_utils(master_seq_wrap);
	
	function new(string name = "master_seq_wrap");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 2; arburst == 2;});
			finish_item(req);
		end
		#delay;
	endtask
endclass

class master_seq_random extends axi_seq_base;
	`uvm_object_utils(master_seq_random)
	
	function new(string name = "master_seq_random");
		super.new(name);
	endfunction
	
	task body();
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			finish_item(req);
		end
		
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 0; arburst == 0;});
			finish_item(req);
		end
		
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 1; arburst == 1;});
			finish_item(req);
		end
		
		repeat(no_of_trans)
		begin
			req = axi_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {awburst == 2; arburst == 2;});
			finish_item(req);
		end
		#delay;
	endtask
endclass