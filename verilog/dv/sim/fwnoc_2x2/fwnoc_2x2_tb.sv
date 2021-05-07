
/****************************************************************************
 * fwnoc_2x2_tb.sv
 ****************************************************************************/
`include "rv_macros.svh"
 
`ifdef NEED_TIMESCALE
	`timescale 1ns/1ns
`endif
  
/**
 * Module: fwnoc_2x2_tb
 * 
 * TODO: Add module documentation
 */
module fwnoc_2x2_tb(input clock);
	
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
	
	reg reset /* verilator public */= 0;
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
	
	localparam SIZE_X = 2;
	localparam SIZE_Y = 2;

	wire[31:0]		gpio_in;
	assign gpio_in[7:0]  = SIZE_X;
	assign gpio_in[15:8] = SIZE_Y;
	gpio_bfm #(
		.N_PINS    (32   ), 
		.N_BANKS   (1    )
		) u_gpio_params (
		.clock     (clock    ), 
		.reset     (reset    ), 
		.pin_i     (gpio_in  )
		);
	
	`RV_WIRES_ARR(bfm2noc_i_, 32, 4);
	`RV_WIRES_ARR(bfm2noc_e_, 32, 4);

	generate
		genvar yi, xi;
		for (yi=0; yi<SIZE_Y; yi=yi+1) begin
			for (xi=0; xi<SIZE_X; xi=xi+1) begin
				rv_data_in_bfm #(
					.DATA_WIDTH  (32)
				) u_he_bfm (
					.clock       (clock      ), 
					.reset       (reset      ), 
					`RV_CONNECT_ARR( , bfm2noc_e_, (xi*SIZE_Y+yi), 32)
				);
	
				rv_data_out_bfm #(
					.DATA_WIDTH  (32)
				) u_hi_bfm (
					.clock       (clock      ), 
					.reset       (reset      ), 
					`RV_CONNECT_ARR( , bfm2noc_i_, (xi*SIZE_Y+yi), 32)
				);
			end
		end
	endgenerate

	
	fwnoc #(
		.FIFO_DEPTH  (4 ), 
		.X_SIZE      (2     ), 
		.Y_SIZE      (2     )
		) u_dut (
		.clock       (clock      ), 
		.reset       (reset      ), 
		`RV_CONNECT(i_, bfm2noc_i_),
		`RV_CONNECT(e_, bfm2noc_e_)
		);


endmodule


