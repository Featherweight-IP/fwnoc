/****************************************************************************
 * fwnoc_fifo.v
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: fwnoc_fifo
 * 
 * TODO: Add module documentation
 */
module fwnoc_fifo #(
		parameter DEPTH=2,
		parameter PTR_WIDTH=$clog2(DEPTH)
		) (
		input					clock,
		input					reset,
		`RV_TARGET_PORT(i_, 32),
		`RV_INITIATOR_PORT(e_, 32)
		);

	reg[31:0]					fifo[DEPTH-1:0];
	reg[PTR_WIDTH-1:0]			rptr;
	reg[PTR_WIDTH-1:0]			wptr;
	reg[PTR_WIDTH:0]			count;
	wire[PTR_WIDTH-1:0]			wptr_plus_1 = wptr + 1;

	assign e_valid = |count;
	assign i_ready = (count < DEPTH);
	wire e_pop = (e_ready && e_valid);
	wire i_push = (i_ready && i_valid);

	assign e_dat = fifo[rptr];
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			rptr  <= {PTR_WIDTH{1'b0}};
			wptr  <= {PTR_WIDTH{1'b0}};
			count <= {PTR_WIDTH{1'b0}};
		end else begin
			case ({i_push, e_pop})
				2'b10: begin // push with no pop
					wptr  <= wptr + 1;
					count <= count + 1;
					fifo[wptr] <= i_dat;
				end
				2'b01: begin // pop with no push
					rptr <= rptr + 1;
					count <= count - 1;
				end
				2'b11: begin // push and pop
					fifo[wptr] <= i_dat;
					wptr <= wptr + 1;
					rptr <= rptr + 1;
				end
			endcase
		end
	end

endmodule


