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
	
	// States
	// - Wait for request
	// - Latch parameters (specifically size)
	// - Connect appropriate ingress to egrees
	// - Count down size
	// - Back to first state
	reg[31:0] count;
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			count <= {32{1'b0}};
		end else begin
			count <= count + 1;
		end
	end
	
	assign i0_dat = count;

endmodule


