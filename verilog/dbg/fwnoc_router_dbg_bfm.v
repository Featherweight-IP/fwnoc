/****************************************************************************
 * fwnoc_router_dbg_bfm.v
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: fwnoc_router_dbg_bfm
 * 
 * TODO: Add module documentation
 */
module fwnoc_router_dbg_bfm #(
		parameter X_ID = 0,
		parameter Y_ID = 0
		) (
		input				clock,
		input				reset,
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
		);
	
	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) hi (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , hi_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) he (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , he_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) ni (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , ni_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) ne (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , ne_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) si (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , si_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) se (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , se_)
		);
	
	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) ei (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , ei_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) ee (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , ee_)
		);	
	
	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) wi (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , wi_)
		);

	fwnoc_channel_dbg_bfm #(
			.X_ID(X_ID),
			.Y_ID(Y_ID)
		) we (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT( , we_)
		);	
	
endmodule


