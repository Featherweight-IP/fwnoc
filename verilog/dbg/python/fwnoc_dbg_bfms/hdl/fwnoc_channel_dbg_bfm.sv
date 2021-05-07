
/****************************************************************************
 * fwnoc_channel_dbg_bfm.sv
 ****************************************************************************/

  
/**
 * Module: fwnoc_channel_dbg_bfm
 * 
 * TODO: Add module documentation
 */
module fwnoc_channel_dbg_bfm #(
		parameter X_ID = 0,
		parameter Y_ID = 0
		) (
		input				clock,
		input				reset,
		input[31:0]			dat,
		input				ready,
		input				valid
		);

	parameter MSG_SZ = 32;
	reg[8*MSG_SZ-1:0]		pkt_header = {8*MSG_SZ{1'b0}};
	reg[1:0]                delta_req = 0;
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			pkt_header = {8*MSG_SZ{1'b0}};
			delta_req = 0;
		end else begin
			if (delta_req > 0) begin
				delta_req = delta_req-1;
				_delta_ack;
			end
			if (ready && valid) begin
				_recv(dat);
			end
		end
	end
	
	task _clr_pkt_hdr;
		pkt_header = {8*MSG_SZ{1'b0}};
	endtask
	
	task _set_pkt_hdr_c(input reg[7:0] idx, input reg[7:0] ch);
	begin
		idx = MSG_SZ-idx-1;
		
		pkt_header = ((pkt_header & ~('hFF << 8*idx)) | (ch << 8*idx));
	end
	endtask
	
	task _delta_req;
		delta_req = delta_req + 1;
	endtask
	
	task init;
		_set_parameters(X_ID, Y_ID);
	endtask
	

    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
