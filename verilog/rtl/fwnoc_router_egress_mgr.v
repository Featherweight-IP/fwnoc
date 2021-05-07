/****************************************************************************
 * fwnoc_router_egress_mgr.v
 ****************************************************************************/
`include "rv_macros.svh"

  
/**
 * Module: fwnoc_router_egress_mgr
 * 
 * TODO: Add module documentation
 */
module fwnoc_router_egress_mgr(
		input		clock,
		input		reset,
		`RV_TARGET_PORT(i0_, 32),
		`RV_TARGET_PORT(i1_, 32),
		`RV_TARGET_PORT(i2_, 32),
		`RV_TARGET_PORT(i3_, 32),

		`RV_INITIATOR_PORT(e_, 32)
		);
	
	wire[3:0]		req = {i0_valid, i1_valid, i2_valid, i3_valid};
	wire[3:0]		gnt;
	
	// Perform round-robin arbitration between ingress ports
	reg[3:0]		last_gnt;
	wire[3:0]		gnt_ppc;
	wire[3:0]		gnt_ppc_next = {gnt_ppc[2:0], 1'b0};

	generate
		genvar gnt_ppc_i;
	
		// The gnt_ppc vector has 0 bits leading up to the fireset request
		for (gnt_ppc_i=3; gnt_ppc_i>=0; gnt_ppc_i=gnt_ppc_i-1) begin : block_gnt_ppc_i
			if (|gnt_ppc_i) begin
				assign gnt_ppc[gnt_ppc_i] = |last_gnt[gnt_ppc_i-1:0];
			end else begin
				assign gnt_ppc[gnt_ppc_i] = last_gnt[0];
			end
		end
	endgenerate
	
	wire[3:0]		unmasked_gnt;
	generate
		genvar unmasked_gnt_i;
	
		// The unmasked_gnt vector grants to the lowest active request
		for (unmasked_gnt_i=0; unmasked_gnt_i<4; unmasked_gnt_i=unmasked_gnt_i+1) begin : block_unmasked_gnt_i
			if (|unmasked_gnt_i) begin
				assign unmasked_gnt[unmasked_gnt_i] = (req[unmasked_gnt_i] & ~(|req[unmasked_gnt_i-1:0]));
			end else begin
				assign unmasked_gnt[unmasked_gnt_i] = req[0];
			end
		end
	endgenerate	
	
	wire[3:0]		masked_gnt;
	generate
		genvar masked_gnt_i;
	
		// The masked_gnt vector selects the fireset active request
		// above the last grant
		for (masked_gnt_i=0; masked_gnt_i<4; masked_gnt_i=masked_gnt_i+1) begin : block_masked_gnt_i
			if (|masked_gnt_i) begin
				assign masked_gnt[masked_gnt_i] = 
					(gnt_ppc_next[masked_gnt_i] 
						& req[masked_gnt_i] 
						& ~(|(gnt_ppc_next[masked_gnt_i-1:0] & req[masked_gnt_i-1:0])));
			end else begin
				assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[0] & req[0]);
			end
		end
	endgenerate	
	
	wire[3:0] prioritized_gnt;
	
	// Give priority to the 'next' request
	assign prioritized_gnt = (|masked_gnt)?masked_gnt:unmasked_gnt;
	assign gnt = prioritized_gnt;
	
	
	// Datapath mux
	reg[31:0]		e_dat_r;
	assign e_dat = e_dat_r;
	always @* begin
		case (req & gnt) // synopsys parallel_case full_case
			4'b0000: e_dat_r = {32{1'b0}};
			4'b1000: e_dat_r = i0_dat;
			4'b0100: e_dat_r = i1_dat;
			4'b0010: e_dat_r = i2_dat;
			4'b0001: e_dat_r = i3_dat;
		endcase
	end

	reg				i_valid;
	reg				i_ready;
	// Actually begin transferring data in state1
	assign e_valid = (state == 1 && i_valid);

	
	assign i0_ready = (gnt == 4'b1000 && (e_ready && e_valid));
	assign i1_ready = (gnt == 4'b0100 && (e_ready && e_valid));
	assign i2_ready = (gnt == 4'b0010 && (e_ready && e_valid));
	assign i3_ready = (gnt == 4'b0001 && (e_ready && e_valid));
	
	always @* begin
		case (req & gnt) // synopsys parallel_case full_case
			4'b0000: begin
				i_valid = 1'b0;
				i_ready = 1'b0;
			end
			4'b1000: begin
				i_valid = i0_valid;
				i_ready = i0_ready;
			end
			4'b0100: begin
				i_valid = i1_valid;
				i_ready = i1_ready;
			end
			4'b0010: begin
				i_valid = i2_valid;
				i_ready = i2_ready;
			end
			4'b0001: begin
				i_valid = i3_valid;
				i_ready = i3_ready;
			end
		endcase
	end

	// Latch size from winner's header
	// Transfer full packet, then repeat
	reg[1:0]		state;
	reg[4:0]		payload_sz;
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= 0;
			payload_sz <= {5{1'b0}};
			last_gnt <= 0;
		end else begin
			case (state)
				0: begin
					// Wait for the selected ingress to
					// have valid data
					if (i_valid) begin
						case (e_dat[3:0]) // synopsys parallel_case full_case
							0: payload_sz <= 5'd0;
							1: payload_sz <= 5'd1;
							2: payload_sz <= 5'd2;
							3: payload_sz <= 5'd4;
							4: payload_sz <= 5'd8;
							5: payload_sz <= 5'd16;
						endcase
						state <= 1;
						last_gnt <= prioritized_gnt;
					end
				end
				1: begin
					if (i_valid && e_ready) begin
						if (payload_sz == 0) begin
							state <= 0;
						end else begin
							payload_sz <= payload_sz - 1;
						end
					end
				end
			endcase
		end
	end
	
	
	// States
	// - Wait for request
	// - Latch parameters (specifically size)
	// - Connect appropriate ingress to egrees
	// - Count down size
	// - Back to first state

endmodule


