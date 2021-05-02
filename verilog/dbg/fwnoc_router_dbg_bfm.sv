/****************************************************************************
 * fwnoc_router_dbg_bfm.sv
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

endmodule


