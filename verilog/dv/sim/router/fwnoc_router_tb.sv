/****************************************************************************
 * fwnoc_router_tb.sv
 ****************************************************************************/
`include "rv_macros.svh"
 
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif
  
/**
 * Module: fwnoc_router_tb
 * 
 * TODO: Add module documentation
 */
module fwnoc_router_tb(input clock);
	
`ifdef IVERILOG
`include "iverilog_control.svh"
`endif
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#10;
`else
			#10ns;
`endif
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
	reg reset = 0;
	reg[7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		case (reset_cnt)
			1: begin
				reset_cnt <= reset_cnt + 1;
				reset <= 1;
			end
			20: reset <= 0;
			default: reset_cnt <= reset_cnt + 1;
		endcase
	end
	
	// Five channels
	// h
	// n
	// s
	// e
	// w
	
	localparam DATA_WIDTH = 32;

	`RV_WIRES(he2bfm_, 32);
	`RV_WIRES(bfm2hi_, 32);
	`RV_WIRES(ne2bfm_, 32);
	`RV_WIRES(bfm2ni_, 32);
	`RV_WIRES(se2bfm_, 32);
	`RV_WIRES(bfm2si_, 32);
	`RV_WIRES(ee2bfm_, 32);
	`RV_WIRES(bfm2ei_, 32);
	`RV_WIRES(we2bfm_, 32);
	`RV_WIRES(bfm2wi_, 32);
	
	rv_data_in_bfm #(
		.DATA_WIDTH  (DATA_WIDTH )
		) u_he_bfm (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT( , he2bfm_   ));
	
	rv_data_out_bfm #(
		.DATA_WIDTH  (DATA_WIDTH )
		) u_hi_bfm (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT( , bfm2hi_   ));
	
	rv_data_in_bfm #(
		.DATA_WIDTH  (32 )
		) u_ne_bfm (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT( , ne2bfm_   ));
	
	rv_data_out_bfm #(
		.DATA_WIDTH  (DATA_WIDTH )
		) u_ni_bfm (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT( , bfm2ni_   ));

	rv_data_in_bfm #(
			.DATA_WIDTH  (32 )
		) u_se_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , se2bfm_   ));
	
	rv_data_out_bfm #(
			.DATA_WIDTH  (DATA_WIDTH )
		) u_si_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , bfm2si_   ));

	rv_data_in_bfm #(
			.DATA_WIDTH  (32 )
		) u_ee_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , ee2bfm_   ));
	
	rv_data_out_bfm #(
			.DATA_WIDTH  (DATA_WIDTH )
		) u_ei_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , bfm2ei_   ));

	rv_data_in_bfm #(
			.DATA_WIDTH  (32 )
		) u_we_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , we2bfm_   ));
	
	rv_data_out_bfm #(
			.DATA_WIDTH  (DATA_WIDTH )
		) u_wi_bfm (
			.clock       (clock      ), 
			.reset       (reset      ), 
			`RV_CONNECT( , bfm2wi_   ));
	
	fwnoc_router #(
		.X_ID      (7     ), 
		.Y_ID      (5     )
		) u_dut (
		.clock     (clock    ), 
		.reset     (reset    ),
		`RV_CONNECT(hi_, bfm2hi_),
		`RV_CONNECT(he_, he2bfm_),
		`RV_CONNECT(ni_, bfm2ni_),
		`RV_CONNECT(ne_, ne2bfm_),
		`RV_CONNECT(si_, bfm2si_),
		`RV_CONNECT(se_, se2bfm_),
		`RV_CONNECT(ei_, bfm2ei_),
		`RV_CONNECT(ee_, ee2bfm_),
		`RV_CONNECT(wi_, bfm2wi_),
		`RV_CONNECT(we_, we2bfm_)
		);


endmodule


