class slv_driver extends uvm_driver #(axi_xtn);
	`uvm_component_utils(slv_driver)
	
	slv_agt_config s_cfg;
	virtual axi_if.SLV_DRV_MP sif;
	
	axi_xtn xtn, xtn1;
	axi_xtn q1[$], q2[$], q3[$];
	
	//int count, ending;
	
	semaphore sem_awad = new(); //
	semaphore sem_awaddr = new(1); //
	
	semaphore sem_wdrp = new();
	semaphore sem_awdata = new(1); //
	
	semaphore sem_wrp = new(1);
	
	semaphore sem_radc = new();
	semaphore sem_rac = new(1);
	semaphore sem_rdc = new(1);
	
	function new(string name = "slv_driver", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(slv_agt_config)::get(this, "", "slv_agt_config", s_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		super.build_phase(phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		sif = s_cfg.sif;
	endfunction
	
	extern task run_phase(uvm_phase phase);
	extern task drive();
	extern task read_awaddr(axi_xtn xtn);
	extern task read_data(axi_xtn xtn);
	extern task drive_wresp(axi_xtn xtn);
	extern task slave_raddr();
	extern task slave_rdata(axi_xtn xtn1);
	
	
endclass

task slv_driver::run_phase(uvm_phase phase);
	forever
		drive();
endtask: run_phase

task slv_driver::drive();

	xtn = axi_xtn::type_id::create("xtn");
	//xtn1 = axi_xtn::type_id::create("xtn1");
	fork
	
		begin
			sem_awaddr.get(1);
			read_awaddr(xtn);
			sem_awaddr.put(1);
			sem_awad.put(1);
		end
		
		begin
			sem_awad.get(1);
			sem_awdata.get(1);
			read_data(q1.pop_front());
			sem_awdata.put(1);
			sem_wdrp.put(1);
		end
		
		begin
			sem_wdrp.get(1);
			sem_wrp.get(1);
			drive_wresp(q2.pop_front());
			sem_wrp.put(1);
		end
		
		begin
			sem_rac.get(1);
			slave_raddr();
			sem_radc.put(1);
			sem_rac.put(1);
		end
		begin
			sem_radc.get(1);
			sem_rdc.get(1);
			slave_rdata(q3.pop_front());
			sem_rdc.put(1);
		end
		
	join_any
	
endtask: drive

task slv_driver::read_awaddr(axi_xtn xtn);
	//$display("start of slave_awaddr");
	

	//repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	sif.slv_drv_cb.awready <= 1;
	@(sif.slv_drv_cb);
	
	wait(sif.slv_drv_cb.awvalid)
	//xtn.aresetn = sif.slv_drv_cb.aresetn;
	xtn.awid = sif.slv_drv_cb.awid;
	xtn.awlen = sif.slv_drv_cb.awlen;
	xtn.awsize = sif.slv_drv_cb.awsize;
	xtn.awaddr = sif.slv_drv_cb.awaddr;
	xtn.awburst = sif.slv_drv_cb.awburst;
	q1.push_back(xtn);  //write_channel
	xtn.bid = xtn.awid;
	q2.push_back(xtn);  //write resp channel
	
	sif.slv_drv_cb.awready <= 0;
	
	repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	//$display("end of slave_awaddr");
	
endtask: read_awaddr

task slv_driver::read_data(axi_xtn xtn);
	
	int mem[int];
	xtn.cal_addr();
	$display("start of slave_wdata"); 
	$displayh("aligned: %h", xtn.aligned_addr);
	$displayh("addresses calculated in slave side are %p", xtn.addr);
	for(int i = 0; i<(xtn.awlen+1); i++) begin
		//$display("slave_iteration: %0d", i);
		sif.slv_drv_cb.wready <= 1;
		@(sif.slv_drv_cb);
		wait(sif.slv_drv_cb.wvalid)
		
		$display("slave drive start of wvalid");
		$display("WSTRB in slave driver is: %p", sif.slv_drv_cb.wstrb);
		
		if(sif.slv_drv_cb.wstrb == 15)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata;
		
		if(sif.slv_drv_cb.wstrb == 8)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[31:24];
			
		if(sif.slv_drv_cb.wstrb == 4)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[23:16];
			
		if(sif.slv_drv_cb.wstrb == 2)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[15:8];
			
		if(sif.slv_drv_cb.wstrb == 1)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[7:0];
			
		if(sif.slv_drv_cb.wstrb == 7)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[23:0];
		
		if(sif.slv_drv_cb.wstrb == 14)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[31:8];
		
		if(sif.slv_drv_cb.wstrb == 12)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[31:16];
			
		if(sif.slv_drv_cb.wstrb == 3)
			mem[xtn.addr[i]] = sif.slv_drv_cb.wdata[15:0];
		$displayh("Value inside mem is %p", mem[xtn.addr[i]]);
		sif.slv_drv_cb.wready <= 0;
		
		repeat($urandom_range(1, 5))
			@(sif.slv_drv_cb);
		//count = 1;
	end
	$displayh("mem is %p", mem);
	$display("end of read_data");
endtask: read_data

task slv_driver::drive_wresp(axi_xtn xtn);
	//$display("start of drive wresp");
	sif.slv_drv_cb.bvalid <= 1;
	sif.slv_drv_cb.bresp <= 0;
	sif.slv_drv_cb.bid <= xtn.bid;
	
	//$display("BID send is %d", xtn.awid);
	
	@(sif.slv_drv_cb);
	wait(sif.slv_drv_cb.bready)
	sif.slv_drv_cb.bvalid <= 0;
	sif.slv_drv_cb.bresp <= 'hx;
	
	repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	//$display("end of drive resp");
endtask

task slv_driver::slave_raddr();
	xtn1 = axi_xtn::type_id::create("xtn1");
	//repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	//$display("start of raddr");
	sif.slv_drv_cb.arready <= 1;
	//@(sif.slv_drv_cb);
	//$display("waiting for arvalid signal");
	wait(sif.slv_drv_cb.arvalid)
	//$display("done for arvalid signal");
	xtn1.arid = sif.slv_drv_cb.arid;
	xtn1.arlen = sif.slv_drv_cb.arlen;
	xtn1.arsize = sif.slv_drv_cb.arsize;
	xtn1.araddr = sif.slv_drv_cb.araddr;
	xtn1.arburst = sif.slv_drv_cb.arburst;
	
	q3.push_back(xtn1);  //write_channel
	
	
	
	repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	sif.slv_drv_cb.arready <= 0;
	//$display("end of raddr");
endtask: slave_raddr

task slv_driver::slave_rdata(axi_xtn xtn1);
	int len = xtn1.arlen;
	//$display("start of slave_rdata");
	for(int i = 0; i<len+1; i++) begin
		sif.slv_drv_cb.rdata <= $urandom;
		sif.slv_drv_cb.rvalid <= 1;
		sif.slv_drv_cb.rid <= xtn1.arid;
		sif.slv_drv_cb.rresp <= 0;
		if(i == (len))
			sif.slv_drv_cb.rlast <= 1;
		else
			sif.slv_drv_cb.rlast <= 0;
		
		@(sif.slv_drv_cb);
		wait(sif.slv_drv_cb.rready)
		sif.slv_drv_cb.rvalid <= 0;
		sif.slv_drv_cb.rlast <= 0;
		sif.slv_drv_cb.rresp <= 'hx;		
		repeat($urandom_range(1, 5))
		@(sif.slv_drv_cb);
	end
	//$display("end of slave_rdata");
endtask: slave_rdata	
