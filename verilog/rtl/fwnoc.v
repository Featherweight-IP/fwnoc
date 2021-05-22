
/****************************************************************************
 * fwnoc.v
 ****************************************************************************/
`include "rv_macros.svh"

//`define wire_idx(x,y) (((y)*X_SIZE)+(x))
`define wire_idx(x,y) (((x)*Y_SIZE)+(y))
  
/**
 * Module: fwnoc
 * 
 * TODO: Add module documentation
 */
module fwnoc #(
		parameter FIFO_DEPTH=4,
		parameter X_SIZE=2,
		parameter Y_SIZE=1
		) (
		input		clock,
		input		reset,
		`RV_TARGET_PORT_ARR(i_, 32, X_SIZE*Y_SIZE),
		`RV_INITIATOR_PORT_ARR(e_, 32, X_SIZE*Y_SIZE)
		);
	
	// Wires are arranged as follows (assume 2x2)
	// [0] - [x=0,y=0]
	// [1] - [x=0,y=1]
	// [2] - [x=1,y=0]
	// [3] - [x=1,y=1]
	
	`RV_WIRES_ARR(router_ne_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_ni_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_se_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_si_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_ee_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_ei_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_we_, 32, (X_SIZE*Y_SIZE));
	`RV_WIRES_ARR(router_wi_, 32, (X_SIZE*Y_SIZE));

	// Instance routers and connect to the grid
	generate
		genvar xi, yi;
		// Iterate over Y inside to ensure y dimension is second
		for (xi=0; xi<X_SIZE; xi=xi+1) begin : router_xi
			for (yi=0; yi<Y_SIZE; yi=yi+1) begin : router_yi
				fwnoc_router #(
					.FIFO_DEPTH  (FIFO_DEPTH ), 
					.X_ID        (xi         ), 
					.Y_ID        (yi         )
					) u_router (
					.clock       (clock      ), 
					.reset       (reset      ), 
					`RV_CONNECT_ARR(he_, e_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(hi_, i_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(ne_, router_ne_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(ni_, router_ni_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(se_, router_se_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(si_, router_si_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(ee_, router_ee_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(ei_, router_ei_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(we_, router_we_, `wire_idx(xi,yi), 32),
					`RV_CONNECT_ARR(wi_, router_wi_, `wire_idx(xi,yi), 32)
					);
			end
		end
	endgenerate

	// Connect between-router nets
	generate
		// Complete East/West connections
		genvar ew_xi, ew_yi;
		for (ew_xi=0; ew_xi<X_SIZE-1; ew_xi=ew_xi+1) begin : ew_connections_xi
			for (ew_yi=0; ew_yi<Y_SIZE; ew_yi=ew_yi+1) begin : ew_connections_yi
				// East egress port
				//
				// The east-bound egress port on this router connects 
				// to the west ingress port on the router to the west
				assign router_wi_valid[`wire_idx(ew_xi+1,ew_yi)] = router_ee_valid[`wire_idx(ew_xi,ew_yi)];
				assign router_ee_ready[`wire_idx(ew_xi,ew_yi)] = router_wi_ready[`wire_idx(ew_xi+1,ew_yi)];
				assign router_wi_dat[(`wire_idx(ew_xi+1,ew_yi))*32+:32] = router_ee_dat[(`wire_idx(ew_xi,ew_yi))*32+:32];
				
				// The east-bound ingress port of this router connects
				// to the west egress port on the router to the west
				assign router_ei_valid[`wire_idx(ew_xi,ew_yi)] = router_we_valid[`wire_idx(ew_xi+1,ew_yi)];
				assign router_we_ready[`wire_idx(ew_xi+1,ew_yi)] = router_ei_ready[`wire_idx(ew_xi,ew_yi)];
				assign router_ei_dat[(`wire_idx(ew_xi,ew_yi))*32+:32] = router_we_dat[(`wire_idx(ew_xi+1,ew_yi))*32+:32];
			end
		end
		
		genvar ns_xi, ns_yi;
		for (ns_xi=0; ns_xi<X_SIZE; ns_xi=ns_xi+1) begin : ns_connections_xi
			for (ns_yi=0; ns_yi<Y_SIZE-1; ns_yi=ns_yi+1) begin : ns_connections_yi
				// The south-bound egress port on this router connects
				// to the north-bound ingress port on the router to the south
				assign router_ni_valid[`wire_idx(ns_xi,ns_yi+1)] = router_se_valid[`wire_idx(ns_xi,ns_yi)];
				assign router_se_ready[`wire_idx(ns_xi,ns_yi)] = router_ni_ready[`wire_idx(ns_xi,ns_yi+1)];
				assign router_ni_dat[(`wire_idx(ns_xi,ns_yi+1))*32+:32] = router_se_dat[(`wire_idx(ns_xi,ns_yi))*32+:32];
				
				// The south-bound ingress port on this router connects
				// to the north-bound egress port on the router to the south
				assign router_si_valid[`wire_idx(ns_xi,ns_yi)] = router_ne_valid[`wire_idx(ns_xi,ns_yi+1)];
				assign router_ne_ready[`wire_idx(ns_xi,ns_yi+1)] = router_si_ready[`wire_idx(ns_xi,ns_yi)];
				assign router_si_dat[(`wire_idx(ns_xi,ns_yi))*32+:32] = router_ne_dat[(`wire_idx(ns_xi,ns_yi+1))*32+:32];
			end
		end
	endgenerate

	// Tie off edge ports
	generate
		// North ports go across the top. Y_IDX=0
		genvar n_tieoff_i;
		for (n_tieoff_i=0; n_tieoff_i<X_SIZE; n_tieoff_i=n_tieoff_i+1) begin : n_tieoff
			assign router_ne_ready[`wire_idx(n_tieoff_i,0)] = 1;
			assign router_ni_valid[`wire_idx(n_tieoff_i,0)] = 0;
			// Avoid propagating X in
			assign router_ni_dat[(`wire_idx(n_tieoff_i,0))*32+:32] = {32{1'b0}};
		end
			
		// South ports go across the bottom. Y_IDX=(Y_SIZE-1)
		genvar s_tieoff_i;
		for (s_tieoff_i=0; s_tieoff_i<X_SIZE; s_tieoff_i=s_tieoff_i+1) begin : s_tieoff
			assign router_se_ready[`wire_idx(s_tieoff_i,Y_SIZE-1)] = 1;
			assign router_si_valid[`wire_idx(s_tieoff_i,Y_SIZE-1)] = 0;
			// Avoid propagating X in
			assign router_si_dat[(`wire_idx(s_tieoff_i,Y_SIZE-1))*32+:32] = {32{1'b0}};
		end
		// East ports go down the right side. X_IDX=(X_SIZE-1)
		genvar e_tieoff_i;
		for (e_tieoff_i=0; e_tieoff_i<Y_SIZE; e_tieoff_i=e_tieoff_i+1) begin : e_tieoff
			assign router_ee_ready[`wire_idx(X_SIZE-1,e_tieoff_i)] = 1;
			assign router_ei_valid[`wire_idx(X_SIZE-1,e_tieoff_i)] = 0;
			// Avoid propagating X in
			assign router_ei_dat[(`wire_idx(X_SIZE-1,e_tieoff_i))*32+:32] = {32{1'b0}};
		end
			
		// West ports go down the left side. X_IDX=0
		genvar w_tieoff_i;
		for (w_tieoff_i=0; w_tieoff_i<Y_SIZE; w_tieoff_i=w_tieoff_i+1) begin : w_tieoff
			assign router_we_ready[`wire_idx(0,w_tieoff_i)] = 1;
			assign router_wi_valid[`wire_idx(0,w_tieoff_i)] = 0;
			// Avoid propagating X in
			assign router_wi_dat[(`wire_idx(0,w_tieoff_i))*32+:32] = {32{1'b0}};
		end
	endgenerate


endmodule

`undef wire_idx
