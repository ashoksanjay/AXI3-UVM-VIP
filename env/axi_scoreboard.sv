class axi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(axi_scoreboard)
	
	uvm_tlm_analysis_fifo #(axi_xtn) fifo_mst[];
	uvm_tlm_analysis_fifo #(axi_xtn) fifo_slv[];
	
	axi_xtn mst_data, slv_data;
	axi_xtn wr_xtn, rd_xtn;
	env_config e_cfg;
	
	static int pkt_rcvd, pkt_compared;
	
	covergroup write_cg;
		option.per_instance = 1;
		AWADDR_CP: coverpoint wr_xtn.awaddr{
						bins awaddr_bin = {[0:'hffff_ffff]};}
		AWBURST_CP: coverpoint wr_xtn.awburst{
						bins awburst_bin[] = {[0:2]};}
		AWSIZE_CP: coverpoint wr_xtn.awsize{
						bins awsize_bin[] = {[0:2]};}
		AWLEN_CP: coverpoint wr_xtn.awlen{
						bins awlen = {[0:11]};}
		BRESP_CP: coverpoint wr_xtn.bresp{bins bresp_bin = {0};}
		
		WRITE_ADDR_CROSS: cross AWBURST_CP, AWSIZE_CP, AWLEN_CP;
	endgroup
	
	covergroup write_cg1 with function sample(int i);
		option.per_instance = 1;
		WSTRB_CP: coverpoint wr_xtn.wstrb[i]{
			bins wstrb0 = {4'b1111};
			bins wstrb1 = {4'b1100};
			bins wstrb2 = {4'b0011};
			bins wstrb3 = {4'b1000};
			bins wstrb4 = {4'b0100};
			bins wstrb5 = {4'b0010};
			bins wstrb6 = {4'b0001};
			bins wstrb7 = {4'b1110};
		}
	endgroup
	
	covergroup read_cg;
		option.per_instance = 1;
		ARADDR_CP: coverpoint rd_xtn.araddr{
						bins araddr_bin = {[0:'hffff_ffff]};}
		ARBURST_CP: coverpoint rd_xtn.arburst{
						bins arburst_bin[] = {[0:2]};}
		ARSIZE_CP: coverpoint rd_xtn.arsize{
						bins arsize_bin[] = {[0:2]};}
		ARLEN_CP: coverpoint rd_xtn.arlen{bins arlen_bin = {[0:11]};}
	
		READ_ADDR_CROSS: cross ARBURST_CP, ARSIZE_CP, ARLEN_CP;
	endgroup
	
	covergroup read_cg1 with function sample(int i);
		option.per_instance = 1;
		RRESP_CP: coverpoint rd_xtn.rresp[i]{bins rresp_bin = {0};}
	endgroup
	
	function new(string name = "axi_scoreboard", uvm_component parent);
		super.new(name, parent);
		write_cg = new();
		write_cg1 = new();
		read_cg = new();
		read_cg1 = new();
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(env_config)::get(this, "", "env_config", e_cfg))
			`uvm_fatal(get_type_name(), "error while getting config")
		super.build_phase(phase);
		fifo_mst = new[e_cfg.no_of_master];
		fifo_slv = new[e_cfg.no_of_slave];
		
		foreach(fifo_mst[i]) begin
			fifo_mst[i] = new($sformatf("fifo_mst[%0d]", i), this);
		end
		foreach(fifo_slv[i]) begin
			fifo_slv[i] = new($sformatf("fifo_slv[%0d]", i), this);
		end
	endfunction
	
	task run_phase(uvm_phase phase);
		forever
			begin
				fifo_mst[0].get(mst_data);
				fifo_slv[0].get(slv_data);
				pkt_rcvd++;
				
				if(mst_data.compare(slv_data)) begin
					`uvm_info("SCOREBOARD", $sformatf("Master packet \n %s", mst_data.sprint()), UVM_LOW);
					`uvm_info("SCOREBOARD", $sformatf("Slave packet \n %s", slv_data.sprint()), UVM_LOW);
					`uvm_error("scoreboard", "Packet matched");
					wr_xtn = mst_data;
					write_cg.sample();
					rd_xtn = slv_data;
					read_cg.sample();
					pkt_compared++;
					if(mst_data.wvalid)
					begin
						foreach(mst_data.wdata[i]) begin
							write_cg1.sample(i);
						end
					end
					if(mst_data.rvalid)
					begin
						foreach(mst_data.rdata[i]) begin
							read_cg1.sample(i);
						end
					end
				end
				else begin
					
					`uvm_info("SCOREBOARD", $sformatf("Master packet \n %s", mst_data.sprint()), UVM_LOW);
					`uvm_info("SCOREBOARD", $sformatf("Slave packet \n %s", slv_data.sprint()), UVM_LOW);
					`uvm_error("scoreboard", "Packet mismatched");
				end
			end
	endtask
	
	function void report_phase(uvm_phase phase);
		`uvm_info("Scoreboard", $sformatf("No of packet received: %0d", pkt_rcvd), UVM_LOW);
		`uvm_info("Scoreboard", $sformatf("No of packet Compared: %0d", pkt_compared), UVM_LOW);
	endfunction
	
endclass