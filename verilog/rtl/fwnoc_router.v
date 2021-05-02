/****************************************************************************
 * fwnoc_router.v
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: fwnoc_router
 * 
 * TODO: Add module documentation
 */
module fwnoc_router #(
		parameter FIFO_DEPTH=4,
		parameter X_ID = 0,
		parameter Y_ID = 0
		) (
		input clock,
		input reset,
		// Host port
		`RV_INITIATOR_PORT(he_, 32),
		`RV_TARGET_PORT(hi_, 32),
	
		// North port
		`RV_INITIATOR_PORT(ne_, 32),
		`RV_TARGET_PORT(ni_, 32),
		
		// South port
		`RV_INITIATOR_PORT(se_, 32),
		`RV_TARGET_PORT(si_, 32),
		
		// East port
		`RV_INITIATOR_PORT(ee_, 32),
		`RV_TARGET_PORT(ei_, 32),
		
		// West port
		`RV_INITIATOR_PORT(we_, 32),
		`RV_TARGET_PORT(wi_, 32)
		);
	wire [1:0]		x_id = X_ID;
	wire [1:0]		y_id = Y_ID;

	// Host ingress cannot route to host
	`RV_WIRES(hi2ne_, 32);
	`RV_WIRES(hi2se_, 32);
	`RV_WIRES(hi2ee_, 32);
	`RV_WIRES(hi2we_, 32);

	`RV_WIRES(he_stub_, 32);
	assign he_stub_ready = 1;
	fwnoc_router_ingress_mgr #(
			.FIFO_DEPTH(FIFO_DEPTH),
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) u_ingress_h (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_CONNECT(i_, hi_),
		`RV_CONNECT(he_, he_stub_),
		`RV_CONNECT(ne_, hi2ne_),
		`RV_CONNECT(se_, hi2se_),
		`RV_CONNECT(ee_, hi2ee_),
		`RV_CONNECT(we_, hi2we_)
		);
	
	`RV_WIRES(ni2he_, 32);
	`RV_WIRES(ni2se_, 32);
	`RV_WIRES(ni2ee_, 32);
	`RV_WIRES(ni2we_, 32);
	`RV_WIRES(ne_stub_, 32);
	assign ne_stub_ready = 1;
	fwnoc_router_ingress_mgr #(
			.FIFO_DEPTH(FIFO_DEPTH),
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) u_ingress_n (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_CONNECT(i_, ni_),
		`RV_CONNECT(he_, ni2he_),
		`RV_CONNECT(ne_, ne_stub_),
		`RV_CONNECT(se_, ni2se_),
		`RV_CONNECT(ee_, ni2ee_),
		`RV_CONNECT(we_, ni2we_)
		);
	
	`RV_WIRES(si2he_, 32);
	`RV_WIRES(si2ne_, 32);
	`RV_WIRES(si2ee_, 32);
	`RV_WIRES(si2we_, 32);
	`RV_WIRES(se_stub_, 32);
	assign se_stub_ready = 1;
	fwnoc_router_ingress_mgr #(
			.FIFO_DEPTH(FIFO_DEPTH),
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) u_ingress_s (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_CONNECT(i_, si_),
		`RV_CONNECT(he_, si2he_),
		`RV_CONNECT(ne_, si2ne_),
		`RV_CONNECT(se_, se_stub_),
		`RV_CONNECT(ee_, si2ee_),
		`RV_CONNECT(we_, si2we_)
		);
	
	`RV_WIRES(ei2he_, 32);
	`RV_WIRES(ei2ne_, 32);
	`RV_WIRES(ei2se_, 32);
	`RV_WIRES(ei2we_, 32);
	`RV_WIRES(ee_stub_, 32);
	assign ee_stub_ready = 1;
	fwnoc_router_ingress_mgr #(
			.FIFO_DEPTH(FIFO_DEPTH),
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) u_ingress_e (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_CONNECT(i_, ei_),
		`RV_CONNECT(he_, ei2he_),
		`RV_CONNECT(ne_, ei2ne_),
		`RV_CONNECT(se_, ei2se_),
		`RV_CONNECT(ee_, ee_stub_),
		`RV_CONNECT(we_, ei2we_)
		);
	
	`RV_WIRES(wi2he_, 32);
	`RV_WIRES(wi2ne_, 32);
	`RV_WIRES(wi2se_, 32);
	`RV_WIRES(wi2ee_, 32);
	`RV_WIRES(we_stub_, 32);
	assign we_stub_ready = 1;
	fwnoc_router_ingress_mgr #(
			.FIFO_DEPTH(FIFO_DEPTH),
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) u_ingress_w (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_CONNECT(i_, wi_),
		`RV_CONNECT(he_, wi2he_),
		`RV_CONNECT(ne_, wi2ne_),
		`RV_CONNECT(se_, wi2se_),
		`RV_CONNECT(ee_, wi2ee_),
		`RV_CONNECT(we_, we_stub_)
		);
	
	// Ingress:
	// - Accept header
	// - Determine what action to take
	//   - If dst is <this>, then forward to host port
	//   - If dst.x > <this.x>, then send east
	//   - If dst.x < <this.x>, then send west
	//   - If dst.y > <this.y>, then send north
	//   - If dst.y < <this.y>, then send south
	
	// Each egress (initiator) port has:
	// - multiplexer for 
	
	// Need arbiters for each of the xt -> yi
	// (nt,et,wt) -> si
	// (et,wt,st) -> ni
	// (nt,wt,st) -> ei
	// (nt,et,st) -> wi
	// 
	// combinations
	
	// Operation:
	//
	// - One target interface receives a header
	// - Determines appropriate initiator port and requests

	// The egress for the host must consider
	// everything except the host ingress
	
	fwnoc_router_egress_mgr u_egress_h(
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(i0_, ni2he_),
		`RV_CONNECT(i1_, si2he_),
		`RV_CONNECT(i2_, ei2he_),
		`RV_CONNECT(i3_, wi2he_),
		`RV_CONNECT(e_, he_)
		);
	
	fwnoc_router_egress_mgr u_egress_n(
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(i0_, hi2ne_),
		`RV_CONNECT(i1_, si2ne_),
		`RV_CONNECT(i2_, ei2ne_),
		`RV_CONNECT(i3_, wi2ne_),
		`RV_CONNECT(e_, ne_)
		);
	
	fwnoc_router_egress_mgr u_egress_s(
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(i0_, hi2se_),
		`RV_CONNECT(i1_, ni2se_),
		`RV_CONNECT(i2_, ei2se_),
		`RV_CONNECT(i3_, wi2se_),
		`RV_CONNECT(e_, se_)
		);
	
	fwnoc_router_egress_mgr u_egress_e(
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(i0_, hi2ee_),
		`RV_CONNECT(i1_, ni2ee_),
		`RV_CONNECT(i2_, si2ee_),
		`RV_CONNECT(i3_, wi2ee_),
		`RV_CONNECT(e_, ee_)
		);
	
	fwnoc_router_egress_mgr u_egress_w(
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(i0_, hi2we_),
		`RV_CONNECT(i1_, ni2we_),
		`RV_CONNECT(i2_, si2we_),
		`RV_CONNECT(i3_, ei2we_),
		`RV_CONNECT(e_, we_)
		);

endmodule


