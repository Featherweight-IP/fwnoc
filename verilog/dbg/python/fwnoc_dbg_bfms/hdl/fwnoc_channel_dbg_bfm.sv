
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
	

    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
