class axi_xtn extends uvm_sequence_item;
	`uvm_object_utils(axi_xtn)
	
	rand bit [3:0] awid;
	rand bit [31:0] awaddr;
	rand bit [7:0] awlen;
	rand bit [2:0] awsize;
	rand bit [1:0] awburst;
	bit awready;
	bit awvalid;
	
	rand bit [3:0] wid;
	rand bit [31:0] wdata[];
    bit [3:0] wstrb[];
	bit wlast;
	bit wvalid;
	bit wready;
	
	rand bit [3:0] bid;
	bit [1:0] bresp;
	bit bvalid;
	bit bready;
	
	rand bit [3:0] arid;
	rand bit [31:0] araddr;
	rand bit [7:0] arlen;
	rand bit [2:0] arsize;
	rand bit [1:0] arburst;
	bit arready;
	bit arvalid;
	
	rand bit [3:0] rid;
	rand bit [31:0] rdata[];
	bit [1:0] rresp;
	bit rlast;
	bit rvalid;
	bit rready;
	
	//Local variables
	bit [31:0] addr[];
	int no_of_bytes;
	int aligned_addr;
	int start_addr;
	
	bit [31:0] raddr[];
	int no_of_rdbytes;
	int aligned_raddr;
	int start_raddr;
	bit [3:0] rstrb[];
	
	constraint wdac {wdata.size() == (awlen+1);}
	constraint ardac {rdata.size() == (arlen+1);}
	
	constraint awb {awburst dist {0:=10, 1:=10, 2:=10};}
	constraint arb {arburst dist {0:=10, 1:=10, 2:=10};}
	
	constraint write_id_c {awid == wid; bid == wid;}
	constraint read_id_c {rid == arid;}
	
	constraint aws {awsize dist {0:=10, 1:=10, 2:=10};}
	constraint ar {arsize dist {0:=10, 1:=10, 2:=10};}
	
	constraint c1 {((awburst == 2'b10) && awsize == 1) -> awaddr%2 == 0;}
	constraint c2 {((awburst == 2'b10) && awsize == 2) -> awaddr%4 == 0;}
	constraint c3 {(arburst == 2'b10 && arsize == 1) -> araddr%2 == 0;}
	constraint c4 {(arburst == 2'b10 && arsize == 2) -> araddr%4 == 0;}
	
	constraint c5 {awaddr < 4096;}
	constraint c6 {araddr < 4096;}
	
	constraint c7 {awlen inside {[0:15]};}
	constraint c8 {arlen inside {[0:15]};}
	
	
	function new(string name = "axi_xtn");
		super.new(name);
	endfunction
	
	function void post_randomize();
		wstrb = new[awlen+1];
		//rstrb = new[arlen+1];
		cal_addr();
		strb_cal();
		cal_raddr();
		//strb_rcal();
	endfunction
	
	extern function void cal_addr();
	extern function void strb_cal();
	extern function void cal_raddr();
	//extern function void strb_rcal();
	extern function void do_print(uvm_printer printer);
	extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);	
endclass

function void axi_xtn::cal_addr();
	
	bit wb;
	int burst_length = awlen+1;
	int addr_n;
	int wrap_boundary;
	//$display("cal_addr is working");
	no_of_bytes = 2**awsize;
	aligned_addr = (int'(awaddr/no_of_bytes))*no_of_bytes;
	start_addr = awaddr;
	
	wrap_boundary = (int'(awaddr/(no_of_bytes*burst_length)))*(no_of_bytes*burst_length);
	addr_n = wrap_boundary+(no_of_bytes*burst_length);
	
	addr = new[awlen+1];
	addr[0] = awaddr;
	
	for(int i = 1; i < (burst_length); i++) begin
		if(awburst == 0) begin
			addr[i] = awaddr;
		end
		if(awburst == 1) begin
			addr[i] = aligned_addr+(i)*no_of_bytes;
		end
		if(awburst == 2) begin
			if(wb == 0) begin
				addr[i] = aligned_addr+(i)*no_of_bytes;
				if(addr[i] == (wrap_boundary+(no_of_bytes*burst_length)))
				begin
					addr[i] = wrap_boundary;
					wb++;
				end
			end
			else 
				addr[i] = start_addr+((i)*no_of_bytes)-(no_of_bytes*burst_length);
		end
			
	end
	
endfunction

function void axi_xtn::strb_cal();
	int data_bus_bytes = 4;
	int lower_byte_lane, upper_byte_lane;
	
	int lower_byte_lane_0 = start_addr-((int'(start_addr/data_bus_bytes))*data_bus_bytes);
	int upper_byte_lane_0 = (aligned_addr+(no_of_bytes-1))-((int'(start_addr/data_bus_bytes))*data_bus_bytes);
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	begin
		wstrb[0][j] = 1;
	end
	
	for(int i=1; i<(awlen+1);i++)
	begin
		lower_byte_lane = addr[i]-(int'(addr[i]/data_bus_bytes))*data_bus_bytes;
		upper_byte_lane = lower_byte_lane+no_of_bytes-1;
		for(int j = lower_byte_lane; j<=upper_byte_lane;j++)
			wstrb[i][j]=1;
	end	
endfunction

function void axi_xtn::cal_raddr();
	bit wb;
	int burst_length = arlen+1;
	int N = burst_length;
	int raddr_n;
	int wrap_boundary;
	no_of_rdbytes = 2**arsize;
	aligned_raddr = (int'(araddr/no_of_rdbytes))*no_of_rdbytes;
	start_raddr = araddr;
	
	wrap_boundary = (int'(araddr/(no_of_rdbytes*burst_length)))*(no_of_rdbytes*burst_length);
	raddr_n = wrap_boundary+(no_of_rdbytes*burst_length);
	
	raddr = new[arlen+1];
	raddr[0] = araddr;
	
	for(int i = 1; i < (burst_length); i++) begin
		if(arburst == 0) begin
			raddr[i] = araddr;
		end
		if(arburst == 1) begin
			raddr[i] = aligned_raddr+(i)*no_of_rdbytes;
		end
		if(arburst == 2) begin
			if(wb == 0) begin
				raddr[i] = aligned_raddr+(i)*no_of_rdbytes;
				if(raddr[i] == (wrap_boundary+(no_of_rdbytes*burst_length)))
				begin
					raddr[i] = wrap_boundary;
					wb++;
				end
			end
			else 
				raddr[i] = start_raddr+((i)*no_of_rdbytes)-(no_of_rdbytes*burst_length);
		end
			
	end
	
endfunction
/*
function void axi_xtn::strb_rcal();
	int data_bus_bytes = 4;
	int lower_byte_lane, upper_byte_lane;
	
	int lower_byte_lane_0 = start_raddr-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
	int upper_byte_lane_0 = (aligned_raddr+(no_of_rdbytes-1))-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	begin
		rstrb[0][j] = 1;
	end
	
	for(int i=1; i<(arlen+1);i++)
	begin
		lower_byte_lane = raddr[i]-(int'(raddr[i]/data_bus_bytes))*data_bus_bytes;
		upper_byte_lane = lower_byte_lane+no_of_rdytes-1;
		for(int j = lower_byte_lane; j<=upper_byte_lane;j++)
			rstrb[i][j]=1;
	end	
endfunction
*/

function void axi_xtn::do_print(uvm_printer printer);
	super.do_print(printer);
	printer.print_field("awid", this.awid, 4, UVM_DEC);
	printer.print_field("awaddr", this.awaddr, 32, UVM_HEX);
	printer.print_field("awlen", this.awlen, 4, UVM_DEC);
	printer.print_field("awsize", this.awsize, 3, UVM_DEC);
	printer.print_field("awburst", this.awburst, 2, UVM_DEC);
	printer.print_field("wid", this.wid, 4, UVM_DEC);
	foreach(this.wdata[i]) begin
		printer.print_field("wdata", this.wdata[i], 32, UVM_HEX);
		printer.print_field("wstrb", this.wstrb[i], 4, UVM_BIN);
		printer.print_field("wlast", this.wlast, 1, UVM_BIN);
	end
	printer.print_field("bid", this.bid, 04, UVM_DEC);
	printer.print_field("bresp", this.bresp, 02, UVM_DEC);
	printer.print_field("arid", this.arid, 04, UVM_DEC);
	printer.print_field("araddr", this.araddr, 32, UVM_HEX);
	printer.print_field("arlen", this.arlen, 08, UVM_DEC);
	printer.print_field("arsize", this.arsize, 03, UVM_DEC);
	printer.print_field("arburst", this.arburst, 02, UVM_DEC);
	printer.print_field("rid", this.rid, 04, UVM_DEC);
	foreach(this.rdata[i])
	begin
		printer.print_field("rdata", this.rdata[i], 32, UVM_HEX);
		printer.print_field("rresp", this.rresp[i], 02, UVM_DEC);
	end
endfunction

function bit axi_xtn::do_compare(uvm_object rhs, uvm_comparer comparer);
	axi_xtn rhs_;
	if(!$cast(rhs_, rhs))
	begin
		`uvm_fatal("do_compare", "failed");
		return 0;
	end
	return super.do_compare(rhs, comparer) &&
	awid == rhs_.awid &&
	awaddr == rhs_.awaddr &&
	awsize == rhs_.awsize &&
	awburst == rhs_.awburst &&
	wid == rhs_.wid &&
	wdata == rhs_.wdata &&
	bid == rhs_.bid &&
	bresp == rhs_.bresp &&
	arid == rhs_.arid &&
	araddr == rhs_.araddr &&
	arlen == rhs_.arlen &&
	arsize == rhs_.arsize &&
	arburst == rhs_.arburst &&
	rid == rhs_.rid &&
	rdata == rhs_.rdata &&
	rresp == rhs_.rresp;
endfunction	
