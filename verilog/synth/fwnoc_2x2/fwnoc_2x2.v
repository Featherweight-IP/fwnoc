
`include "rv_macros.svh"

module fwnoc_2x2(
	input		clock,
	input		reset,
	`RV_TARGET_PORT_ARR(i_, 32, 4),
	`RV_INITIATOR_PORT_ARR(e_, 32, 4)
	);
	
	fwnoc #(
		.FIFO_DEPTH  (4 ), 
		.X_SIZE      (2     ), 
		.Y_SIZE      (2     )
		) fwnoc (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT(i_, i_),
		`RV_CONNECT(e_, e_)
		);
	
endmodule
