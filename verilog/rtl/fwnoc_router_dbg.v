
/****************************************************************************
 * fwnoc_router_dbg.v
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: fwnoc_rouer_dbg
 * 
 * TODO: Add module documentation
 */
module fwnoc_router_dbg #(
		parameter X_ID = 0,
		parameter Y_ID = 0
		) (
		input			clock,
		input			reset,
		`RV_MONITOR_PORT(he_, 32),
		`RV_MONITOR_PORT(hi_, 32),
	
		// North port
		`RV_MONITOR_PORT(ne_, 32),
		`RV_MONITOR_PORT(ni_, 32),
		
		// South port
		`RV_MONITOR_PORT(se_, 32),
		`RV_MONITOR_PORT(si_, 32),
		
		// East port
		`RV_MONITOR_PORT(ee_, 32),
		`RV_MONITOR_PORT(ei_, 32),
		
		// West port
		`RV_MONITOR_PORT(we_, 32),
		`RV_MONITOR_PORT(wi_, 32)
		) ;
`ifdef FWNOC_ROUTER_DBG_MODULE
	`FWNOC_ROUTER_DBG_MODULE #(
		) u_dbg (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT(he_, he_),
			`RV_CONNECT(hi_, hi_),
			`RV_CONNECT(ne_, ne_),
			`RV_CONNECT(ni_, ni_),
			`RV_CONNECT(se_, se_),
			`RV_CONNECT(si_, si_),
			`RV_CONNECT(ee_, ee_),
			`RV_CONNECT(ei_, ei_),
			`RV_CONNECT(we_, we_),
			`RV_CONNECT(wi_, wi_)
		);
`endif


endmodule


