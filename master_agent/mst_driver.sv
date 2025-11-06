class mst_driver extends uvm_driver #(axi_xtn);
	`uvm_component_utils(mst_driver)
	
	virtual axi_if.MST_DRV_MP mif;
	mst_agt_config m_cfg;
	
	axi_xtn xtn;
	axi_xtn q1[$], q2[$], q3[$], q4[$], q5[$];
	
	semaphore sem_awdc = new();
	semaphore sem_wdrc = new();
	semaphore sem_wdc = new(1);
	semaphore sem_awc = new(1);
	semaphore sem_wrc = new(1);
	
	semaphore sem_ardc = new();
	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
	
	function new(string name = "mst_driver", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(mst_agt_config)::get(this, "", "mst_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config");
		super.build_phase(phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mif = m_cfg.mif;
	endfunction
	
	extern task run_phase(uvm_phase phase);
	extern task drive(axi_xtn xtn);
	extern task drive_awaddr(axi_xtn xtn);
	extern task drive_wdata(axi_xtn xtn);
	extern task drive_bresp(axi_xtn xtn);
	
	extern task drive_raddr(axi_xtn xtn);
	extern task drive_rdata(axi_xtn xtn);
		
endclass

task mst_driver::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		drive(req);
		seq_item_port.item_done();
		//#1000;
	end
endtask: run_phase

task mst_driver::drive(axi_xtn xtn);
	`uvm_info(get_type_name(), $sformatf("packet: %s", xtn.sprint()), UVM_LOW);
	q1.push_back(xtn);
	
	q2.push_back(xtn);
	q3.push_back(xtn);
	q4.push_back(xtn);
	//q5.push_back(xtn);
	
	fork
	
		begin
			sem_awc.get(1);
			drive_awaddr(q1.pop_front());
			sem_awc.put(1);
			sem_awdc.put(1);
		end
		
		begin
			sem_awdc.get(1);
			sem_wdc.get(1);
			drive_wdata(q2.pop_front());
			sem_wdc.put(1);
			sem_wdrc.put(1);
		end
		
		begin
			sem_wdrc.get(1);
			sem_wrc.get(1);
			drive_bresp(q3.pop_front());
			sem_wrc.put(1);
		end
		
		begin
			sem_arc.get(1);
			drive_raddr(q4.pop_front());
			sem_arc.put(1);
			sem_ardc.put(1);
		end
		begin
			sem_ardc.get(1);
			sem_rdc.get(1);
			drive_rdata(q5.pop_front());
			sem_rdc.put(1);
		end

	join_any
endtask: drive

task mst_driver::drive_awaddr(axi_xtn xtn);
	//$display("start of drive_awaddr");
	@(mif.mst_drv_cb);
	begin
	mif.mst_drv_cb.awvalid <= 1;
	mif.mst_drv_cb.awaddr <= xtn.awaddr;
	mif.mst_drv_cb.awsize <= xtn.awsize;
	mif.mst_drv_cb.awid <= xtn.awid;
	mif.mst_drv_cb.awlen <= xtn.awlen;
	mif.mst_drv_cb.awburst <= xtn.awburst;
	
	@(mif.mst_drv_cb);
	wait(mif.mst_drv_cb.awready)
	mif.mst_drv_cb.awvalid <= 0;
	 
	repeat($urandom_range(1, 5))
		@(mif.mst_drv_cb);
	end
	//$display("end of drive_awaddr");
	
endtask: drive_awaddr

task mst_driver::drive_wdata(axi_xtn xtn);
	$display("start of drive_wdata");
	foreach(xtn.wdata[i])
	begin
		//$display("%iteration: %0d", i);
		mif.mst_drv_cb.wvalid <= 1;
		mif.mst_drv_cb.wdata <= xtn.wdata[i];
		mif.mst_drv_cb.wstrb <= xtn.wstrb[i];
		mif.mst_drv_cb.wid <= xtn.wid;
		if(i == (xtn.awlen))
			mif.mst_drv_cb.wlast <= 1;
		else
			mif.mst_drv_cb.wlast <= 0;
		
		@(mif.mst_drv_cb);
		wait(mif.mst_drv_cb.wready)
		
		mif.mst_drv_cb.wvalid <= 0;
		mif.mst_drv_cb.wlast <= 0;
		//@(mif.mst_drv_cb);
		repeat($urandom_range(1, 5))
			@(mif.mst_drv_cb);
		//count++;
	end
	/*
	$display("xtn.wdata.size(): %0d, count : %0d", xtn.wdata.size(), count);
	if(count == xtn.wdata.size()) begin
		ending = 1;
	end
	*/
	$display("end of drive_wdata");
endtask: drive_wdata

task mst_driver::drive_bresp(axi_xtn xtn);
	//$display("start of drive_bresp");
	//mif.mst_drv_cb.bid <= xtn.bid;
	mif.mst_drv_cb.bready <= 1;
	@(mif.mst_drv_cb);
	wait(mif.mst_drv_cb.bvalid)
	
	mif.mst_drv_cb.bready <= 0;
	repeat($urandom_range(1, 5))
		@(mif.mst_drv_cb);
	//$display("end of drive_bresp");
		
endtask: drive_bresp

task mst_driver::drive_raddr(axi_xtn xtn);
	//$display("start of drive_raddr");
	repeat($urandom_range(1, 5))
		@(mif.mst_drv_cb);
	mif.mst_drv_cb.arid <= xtn.arid;
	mif.mst_drv_cb.arlen <= xtn.arlen;
	mif.mst_drv_cb.arsize <= xtn.arsize;
	mif.mst_drv_cb.arburst <= xtn.arburst;
	mif.mst_drv_cb.araddr <= xtn.araddr;
	mif.mst_drv_cb.arvalid <= 1;
	q5.push_back(xtn);
	@(mif.mst_drv_cb);
	//$display("waiting for master arready signal");
	wait(mif.mst_drv_cb.arready)
	//$display("done for master arready signal");
	mif.mst_drv_cb.arvalid <= 0;
	
	repeat($urandom_range(1, 5))
		@(mif.mst_drv_cb);
	//$display("end of drive_raddr");
		
endtask: drive_raddr

task mst_driver::drive_rdata(axi_xtn xtn);
	//$display("start of drive_rdata");
	repeat(xtn.arlen+1)
	begin
		@(mif.mst_drv_cb);
		mif.mst_drv_cb.rready <= 1;
		wait(mif.mst_drv_cb.rvalid)
		@(mif.mst_drv_cb);
		mif.mst_drv_cb.rready <= 0;
		
		repeat($urandom_range(1, 5))
		@(mif.mst_drv_cb);
		
	end
	//$display("end of drive_rdata");
endtask: drive_rdata


