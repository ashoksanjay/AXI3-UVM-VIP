class slv_monitor extends uvm_monitor;
	`uvm_component_utils(slv_monitor)
	
	uvm_analysis_port #(axi_xtn) monitor_port;
	virtual axi_if.SLV_MON_MP sif;
	slv_agt_config s_cfg;
	
	axi_xtn xtn, xtn1, xtn2, xtn3, xtn4;
	axi_xtn q1[$], q2[$];
	static int pkt_sent, wdata_pkt, raddr_pkt, rdata_pkt, waddr_pkt, wresp_pkt;
	
	semaphore sem_awc = new(1);
	semaphore sem_awdc = new();
	
	semaphore sem_wrc = new(1);
	semaphore sem_wrdc = new();
	
	semaphore sem_wres = new(1);
	
	semaphore sem_arc = new(1);
	semaphore sem_ardc = new();
	semaphore sem_rdc = new(1);
	
	function new(string name = "slv_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(slv_agt_config)::get(this, "", "slv_agt_config", s_cfg))
			`uvm_fatal(get_type_name(), "error while getting config")
		super.build_phase(phase);
		monitor_port = new("monitor_port", this);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		sif = s_cfg.sif;
	endfunction
	
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	extern task collect_waddr();
	extern task collect_wdata(axi_xtn xtn);
	extern task collect_resp();
	extern task collect_raddr();
	extern task collect_rdata(axi_xtn xtn);
	
	function void report_phase(uvm_phase phase);
		`uvm_info("SLV_MONITOR", $sformatf("total Packet sent : %0d", pkt_sent), UVM_LOW);
		`uvm_info("SLV_MONITOR", $sformatf("awaddr Packet sent : %0d", waddr_pkt), UVM_LOW);
		`uvm_info("SLV_MONITOR", $sformatf("wdata Packet sent : %0d", wdata_pkt), UVM_LOW);
		`uvm_info("SLV_MONITOR", $sformatf("bresp Packet sent : %0d", wresp_pkt), UVM_LOW);
		`uvm_info("SLV_MONITOR", $sformatf("araddr Packet sent : %0d", raddr_pkt), UVM_LOW);
		`uvm_info("SLV_MONITOR", $sformatf("rdata Packet sent : %0d", rdata_pkt), UVM_LOW);
	endfunction
	
endclass

task slv_monitor::run_phase(uvm_phase phase);
	forever
		collect_data();
endtask: run_phase

task slv_monitor::collect_data();
	fork
	
		begin
			sem_awc.get(1);
			collect_waddr();
			sem_awc.put(1);
			sem_awdc.put(1);
		end
		
		begin
			sem_awdc.get(1);
			sem_wrc.get(1);
			collect_wdata(q1.pop_front());
			sem_wrc.put(1);
			sem_wrdc.put(1);
		end
		
		begin
			sem_wrdc.get(1);
			sem_wres.get(1);
			collect_resp();
			sem_wres.put(1);
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

task slv_monitor::collect_waddr();
	xtn = axi_xtn::type_id::create("xtn");
	wait(sif.slv_mon_cb.awvalid && sif.slv_mon_cb.awready)
	
	xtn.awid = sif.slv_mon_cb.awid;
	xtn.awsize = sif.slv_mon_cb.awsize;
	xtn.awlen = sif.slv_mon_cb.awlen;
	xtn.awburst = sif.slv_mon_cb.awburst;
	xtn.awaddr = sif.slv_mon_cb.awaddr;
	
	q1.push_back(xtn);
	monitor_port.write(xtn);
	pkt_sent++;
	waddr_pkt++;
	//`uvm_info(get_type_name(), $sformatf("printing from slave monitor awaddr /n %s", xtn.sprint()), UVM_LOW);

	@(sif.slv_mon_cb);
endtask: collect_waddr

task slv_monitor::collect_wdata(axi_xtn xtn);
	xtn1 = axi_xtn::type_id::create("xtn1");
	xtn1 = xtn;
	xtn.cal_addr();
	xtn1.wdata = new[xtn.awlen+1];
	xtn1.wstrb = new[xtn.wdata.size()];
	foreach(xtn1.wdata[i]) begin
		wait(sif.slv_mon_cb.wvalid && sif.slv_mon_cb.wready)
		xtn1.wstrb[i] = sif.slv_mon_cb.wstrb;
		
		if(sif.slv_mon_cb.wstrb == 15)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata;
			
		if(sif.slv_mon_cb.wstrb == 8)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[31:24];
			
		if(sif.slv_mon_cb.wstrb == 4)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[23:16];
			
		if(sif.slv_mon_cb.wstrb == 2)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[15:8];
			
		if(sif.slv_mon_cb.wstrb == 1)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[7:0];
		
		if(sif.slv_mon_cb.wstrb == 7)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[23:0];
		
		if(sif.slv_mon_cb.wstrb == 14)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[31:8];
			
		if(sif.slv_mon_cb.wstrb == 12)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[31:16];
			
		if(sif.slv_mon_cb.wstrb == 3)
			xtn1.wdata[i] = sif.slv_mon_cb.wdata[15:0];
		
		xtn1.wid = sif.slv_mon_cb.wid;
		xtn1.wlast = sif.slv_mon_cb.wlast;
		xtn1.wvalid = sif.slv_mon_cb.wvalid;
		@(sif.slv_mon_cb);
	end
	monitor_port.write(xtn1);
	wdata_pkt++;
	pkt_sent++;
	//`uvm_info(get_type_name(), $sformatf("printing from master collect_wdata \n %s", xtn1.sprint()), UVM_LOW);
	
endtask

task slv_monitor::collect_resp();
	xtn2 = axi_xtn::type_id::create("xtn2");
	wait(sif.slv_mon_cb.bready && sif.slv_mon_cb.bvalid)
	xtn2.bid = sif.slv_mon_cb.bid;
	xtn2.bresp = sif.slv_mon_cb.bresp;
	monitor_port.write(xtn2);
	`uvm_info(get_type_name(), $sformatf("printing from master collect_resp \n %s", xtn2.sprint()), UVM_LOW);
	pkt_sent++;
	wresp_pkt++;
	@(sif.slv_mon_cb);
	
endtask: collect_resp

task slv_monitor::collect_raddr();
	xtn3 = axi_xtn::type_id::create("xtn3");
	wait(sif.slv_mon_cb.arvalid && sif.slv_mon_cb.arready)
	
	xtn3.arid = sif.slv_mon_cb.arid;
	xtn3.arsize = sif.slv_mon_cb.arsize;
	xtn3.arlen = sif.slv_mon_cb.arlen;
	xtn3.arburst = sif.slv_mon_cb.arburst;
	xtn3.araddr = sif.slv_mon_cb.araddr;
	
	q2.push_back(xtn3);
	monitor_port.write(xtn3);
	pkt_sent++;
	raddr_pkt++;
	//`uvm_info(get_type_name(), $sformatf("printing from master monitor araddr /n %s", xtn3.sprint()), UVM_LOW);
	@(sif.slv_mon_cb);
	
endtask: collect_raddr

task slv_monitor::collect_rdata(axi_xtn xtn);
	xtn4 = axi_xtn::type_id::create("xtn4");
	xtn4 = xtn;
	xtn4.rdata = new[xtn4.arlen+1];
	foreach(xtn4.rdata[i]) begin
		wait(sif.slv_mon_cb.rvalid && sif.slv_mon_cb.rready)
		xtn4.rid = sif.slv_mon_cb.rid;
		xtn4.rvalid = sif.slv_mon_cb.rvalid;
		xtn4.rready = sif.slv_mon_cb.rready;
		xtn4.rdata[i] = sif.slv_mon_cb.rdata;
		xtn4.rresp[i] = sif.slv_mon_cb.rresp;
		
		if(i == (xtn4.rdata.size()-1))
		begin
			xtn4.rlast = sif.slv_mon_cb.rlast;
		end
		@(sif.slv_mon_cb);
		
	end
	monitor_port.write(xtn4);
	pkt_sent++;
	//`uvm_info(get_type_name(), $sformatf("printing from master monitor rdata /n %s", xtn4.sprint()), UVM_LOW);
	rdata_pkt++;
endtask: collect_rdata

