
/****************************************************************************
 * fwnoc_fifo_tb.sv
 ****************************************************************************/
`include "rv_macros.svh"
  
/**
 * Module: fwnoc_fifo_tb
 * 
 * TODO: Add module documentation
 */
module fwnoc_fifo_tb(input clock);
	
	reg[31:0]		in_q[3:0];
	reg[1:0]		in_q_idx = 0;
	reg				reset = 1;
	
	`RV_WIRES(i_, 32);
	`RV_WIRES(e_, 32);
	
	assign i_dat = in_q_idx;
	
	wire push = (i_valid && i_ready);
	wire pop  = (e_valid && e_ready);
	
	always @(posedge clock) begin
		if (reset) begin
			reset <= 0;
		end
	end

	always @(posedge clock or posedge reset) begin
		if (reset) begin
			in_q_idx <= 0;
		end else begin
			case ({push,pop}) 
				2'b10: begin
					// Push and no pop. Save data
					in_q[in_q_idx] <= i_dat;
					in_q_idx <= in_q_idx + 1;
				end
				2'b01: begin
					// Pop and no push. Check data
					assert(in_q_idx > 0);
					in_q_idx <= in_q_idx - 1;
					assert(e_dat == in_q[0]);
					in_q[0] <= in_q[1];
					in_q[1] <= in_q[2];
					in_q[2] <= in_q[3];
				end
				2'b11: begin
					// Pop and push
					assert(in_q_idx > 0);
					assert(e_dat == in_q[0]);
					if (in_q_idx == 1) begin
						in_q[0] <= i_dat;
					end else if (in_q_idx == 2) begin
						in_q[0] <= in_q[1];
						in_q[1] <= i_dat;
					end else if (in_q_idx == 3) begin
						in_q[0] <= in_q[1];
						in_q[1] <= in_q[2];
						in_q[2] <= i_dat;
					end 
				end
			endcase
			
			cover(in_q_idx == 1);
		end
	end
	
	fwnoc_fifo u_dut (
			.clock(clock),
			.reset(reset),
			`RV_CONNECT(i_, i_),
			`RV_CONNECT(e_, e_)
		);
	
endmodule


