interface axi_if(input bit clock);
	//totally 5 channels

	//write address signals
	bit aresetn;
	bit [3:0] awid;
	bit [31:0] awaddr;
	bit [7:0] awlen;
	bit [2:0] awsize;
	bit [1:0] awburst;
	bit awvalid;
	bit awready;
	
	//write data signals
	bit [3:0] wid;
	bit [31:0] wdata;
	bit [3:0] wstrb;
	bit wlast;
	bit wvalid;
	bit wready;
	
	//write response signals
	bit [3:0] bid;
	bit [1:0] bresp;
	bit bready;
	bit bvalid;
	
	//read address signals
	bit [3:0] arid;
	bit [31:0] araddr;
	bit [7:0] arlen;
	bit [2:0] arsize;
	bit [1:0] arburst;
	bit arvalid;
	bit arready;
	
	//read data signals
	bit [3:0] rid;
	bit [31:0] rdata;
	bit [1:0] rresp;
	bit rlast;
	bit rvalid;
	bit rready;
	
	clocking mst_drv_cb @(posedge clock);
		default input #1 output #1;
		output aresetn, awid, awaddr, awsize, awburst, awvalid, awlen;
		input awready;
		
		output wid, wdata, wstrb, wlast, wvalid;
		input wready;
		
		output bready;
		input bid, bresp, bvalid;
		
		output arid, araddr, arlen, arsize, arburst, arvalid;
		input arready;
		
		output rready;
		input rid, rdata, rresp, rlast, rvalid;
	endclocking
	
	clocking mst_mon_cb @(posedge clock);
		default input #1 output #1;
		input aresetn, awid, awaddr, awsize, awburst, awvalid, awready, awlen;
		
		input wid, wdata, wstrb, wlast, wvalid, wready;
		
		input bready, bid, bresp, bvalid;
		
		input arid, araddr, arlen, arsize, arburst, arvalid, arready;
		
		input rready, rid, rdata, rresp, rlast, rvalid;
	endclocking
	
	clocking slv_drv_cb @(posedge clock);
		default input #1 output #1;
		input aresetn, awid, awaddr, awsize, awburst, awvalid, awlen;
		output awready;
		
		input wid, wdata, wstrb, wlast, wvalid;
		output wready;
		
		input bready;
		output bid, bresp, bvalid;
		
		input arid, araddr, arlen, arsize, arburst, arvalid;
		output arready;
		
		input rready;
		output rid, rdata, rresp, rlast, rvalid;
	endclocking
	
	clocking slv_mon_cb @(posedge clock);
		default input #1 output #1;
		input aresetn, awid, awaddr, awsize, awburst, awvalid, awready, awlen;
		
		input wid, wdata, wstrb, wlast, wvalid, wready;
		
		input bready, bid, bresp, bvalid;
		
		input arid, araddr, arlen, arsize, arburst, arvalid, arready;
		
		input rready, rid, rdata, rresp, rlast, rvalid;
	endclocking
	
	modport MST_DRV_MP(clocking mst_drv_cb);
	modport MST_MON_MP(clocking mst_mon_cb);
	modport SLV_DRV_MP(clocking slv_drv_cb);
	modport SLV_MON_MP(clocking slv_mon_cb);
	
endinterface