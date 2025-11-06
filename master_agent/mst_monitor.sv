class mst_monitor extends uvm_monitor;
	`uvm_component_utils(mst_monitor)
	
	uvm_analysis_port #(axi_xtn) monitor_port;
	
	virtual axi_if.MST_MON_MP mif;
	mst_agt_config m_cfg;
	
	axi_xtn xtn, xtn1, xtn2, xtn3, xtn4;
	axi_xtn q1[$], q2[$];
	
	semaphore sem_awdc = new();
	semaphore sem_wdrc = new();
	semaphore sem_wdc = new(1);
	semaphore sem_awc = new(1);
	semaphore sem_wrc = new(1);
	
	semaphore sem_ardc = new();
	semaphore sem_arc = new(1);
	semaphore sem_rdc = new(1);
	static int pkt_sent, wdata_pkt, raddr_pkt, rdata_pkt, waddr_pkt, wresp_pkt;
	
	function new(string name = "mst_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(mst_agt_config)::get(this, "", "mst_agt_config", m_cfg))
			`uvm_fatal(get_type_name(), "Error while getting config")
		super.build_phase(phase);
		monitor_port = new("monitor_port", this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		mif = m_cfg.mif;
	endfunction
	
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern task collect_awaddr();
	extern task collect_wdata(axi_xtn xtn);
	extern task collect_bresp();
	extern task collect_raddr();
	extern task collect_rdata(axi_xtn xtn);
	
	function void report_phase(uvm_phase phase);
		`uvm_info("MST_MONITOR", $sformatf("Total Packet: %0d", pkt_sent), UVM_LOW);
		`uvm_info("MST_MONITOR", $sformatf("awaddr Packet: %0d", waddr_pkt), UVM_LOW);
		`uvm_info("MST_MONITOR", $sformatf("wdata Packet: %0d", wdata_pkt), UVM_LOW);
		`uvm_info("MST_MONITOR", $sformatf("brep Packet: %0d", wresp_pkt), UVM_LOW);
		`uvm_info("MST_MONITOR", $sformatf("araddr Packet: %0d", raddr_pkt), UVM_LOW);
		`uvm_info("MST_MONITOR", $sformatf("rdata Packet: %0d", rdata_pkt), UVM_LOW);
	endfunction
	
endclass

task mst_monitor::run_phase(uvm_phase phase);
	forever
		collect_data();
endtask: run_phase

task mst_monitor::collect_data();
	fork
	
		begin
			sem_awc.get(1);
			collect_awaddr();
			sem_awc.put(1);
			sem_awdc.put(1);
		end
		
		begin
			sem_awdc.get(1);
			sem_wdc.get(1);
			collect_wdata(q1.pop_front());
			sem_wdc.put(1);
			sem_wdrc.put(1);
		end
		
		begin
			sem_wdrc.get(1);
			sem_wrc.get(1);
			collect_bresp();
			sem_wrc.put(1);
		end
		
		begin
			sem_arc.get(1);
			collect_raddr();
			sem_arc.put(1);
			sem_ardc.put(1);
		end
		begin
			sem_ardc.get(1);
			sem_rdc.get(1);
			collect_rdata(q2.pop_front());
			sem_rdc.put(1);
		end
		
	join_any
endtask: collect_data
	
task mst_monitor::collect_awaddr();
	xtn = axi_xtn::type_id::create("xtn");
	wait(mif.mst_mon_cb.awvalid && mif.mst_mon_cb.awready)
	
	xtn.awvalid = mif.mst_mon_cb.awvalid;
	xtn.awaddr = mif.mst_mon_cb.awaddr;
	xtn.awsize = mif.mst_mon_cb.awsize;
	xtn.awid = mif.mst_mon_cb.awid;
	xtn.awlen = mif.mst_mon_cb.awlen;
	xtn.awburst = mif.mst_mon_cb.awburst;
	
	q1.push_back(xtn);
	monitor_port.write(xtn);
	pkt_sent++;
	waddr_pkt++;
	//`uvm_info(get_type_name(), $sformatf("printing from master monitor awaddr /n %s", xtn.sprint()), UVM_LOW);
	@(mif.mst_mon_cb);
	
endtask: collect_awaddr

task mst_monitor::collect_wdata(axi_xtn xtn);
	xtn1 = axi_xtn::type_id::create("xtn1");
	xtn1 = xtn;
	xtn1.cal_addr();
	xtn1.wdata = new[xtn1.awlen+1];
	xtn1.wstrb = new[xtn1.wdata.size()];
	foreach(xtn1.wdata[i]) begin
		wait(mif.mst_mon_cb.wvalid && mif.mst_mon_cb.wready)
		xtn1.wstrb[i] = mif.mst_mon_cb.wstrb;
		
		if(mif.mst_mon_cb.wstrb == 15)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata;
			
		if(mif.mst_mon_cb.wstrb == 8)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[31:24];
			
		if(mif.mst_mon_cb.wstrb == 4)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[23:16];
			
		if(mif.mst_mon_cb.wstrb == 2)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[15:8];
			
		if(mif.mst_mon_cb.wstrb == 1)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[7:0];
		
		if(mif.mst_mon_cb.wstrb == 7)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[23:0];
		
		if(mif.mst_mon_cb.wstrb == 14)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[31:8];
			
		if(mif.mst_mon_cb.wstrb == 12)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[31:16];
			
		if(mif.mst_mon_cb.wstrb == 3)
			xtn1.wdata[i] = mif.mst_mon_cb.wdata[15:0];
			
		xtn1.wid = mif.mst_mon_cb.wid;
		xtn1.wlast = mif.mst_mon_cb.wlast;
		xtn1.wvalid = mif.mst_mon_cb.wvalid;
		@(mif.mst_mon_cb);
	end
	monitor_port.write(xtn1);
	pkt_sent++;
	wdata_pkt++;
	//`uvm_info(get_type_name(), $sformatf("printing from master collect_wdata \n %s", xtn1.sprint()), UVM_LOW);
endtask: collect_wdata

task mst_monitor::collect_bresp();
	xtn2 = axi_xtn::type_id::create("xtn2");
	wait(mif.mst_mon_cb.bready && mif.mst_mon_cb.bvalid)
	xtn2.bid = mif.mst_mon_cb.bid;
	
	xtn2.bresp = mif.mst_mon_cb.bresp;
	monitor_port.write(xtn2);
	`uvm_info(get_type_name(), $sformatf("printing from master collect_resp \n %s", xtn2.sprint()), UVM_LOW);
	pkt_sent++;
	wresp_pkt++;
	@(mif.mst_mon_cb);
endtask: collect_bresp

task mst_monitor::collect_raddr();
	xtn3 = axi_xtn::type_id::create("xtn3");
	wait(mif.mst_mon_cb.arvalid && mif.mst_mon_cb.arready)
	
	xtn3.arid = mif.mst_mon_cb.arid;
	xtn3.arsize = mif.mst_mon_cb.arsize;
	xtn3.arlen = mif.mst_mon_cb.arlen;
	xtn3.arburst = mif.mst_mon_cb.arburst;
	xtn3.araddr = mif.mst_mon_cb.araddr;
	
	q2.push_back(xtn3);
	monitor_port.write(xtn3);
	pkt_sent++;
	raddr_pkt++;
	
	//`uvm_info(get_type_name(), $sformatf("printing from master monitor araddr /n %s", xtn3.sprint()), UVM_LOW);
	@(mif.mst_mon_cb);
	
endtask: collect_raddr

task mst_monitor::collect_rdata(axi_xtn xtn);
	xtn4 = axi_xtn::type_id::create("xtn4");
	xtn4 = xtn;
	xtn4.rdata = new[xtn4.arlen+1];
	foreach(xtn4.rdata[i]) begin
		wait(mif.mst_mon_cb.rvalid && mif.mst_mon_cb.rready)
		xtn4.rid = mif.mst_mon_cb.rid;
		xtn4.rvalid = mif.mst_mon_cb.rvalid;
		xtn4.rready = mif.mst_mon_cb.rready;
		xtn4.rdata[i] = mif.mst_mon_cb.rdata;
		xtn4.rresp[i] = mif.mst_mon_cb.rresp;
		
		if(i == (xtn4.rdata.size()-1))
		begin
			xtn4.rlast = mif.mst_mon_cb.rlast;
		end
		@(mif.mst_mon_cb);
		
	end
	monitor_port.write(xtn4);
	pkt_sent++;
	rdata_pkt++;
	//`uvm_info(get_type_name(), $sformatf("printing from master monitor rdata /n %s", xtn4.sprint()), UVM_LOW);

endtask: collect_rdata