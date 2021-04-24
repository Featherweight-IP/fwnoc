/****************************************************************************
 * fwnoc_router_ingress_mgr.v
 ****************************************************************************/
`include "rv_macros.svh"

  
/**
 * Module: fwnoc_router_ingress_mgr
 * 
 * TODO: Add module documentation
 */
module fwnoc_router_ingress_mgr #(
		parameter X_ID = 0,
		parameter Y_ID = 0
		) (
		input			clock,
		input			reset,
		`RV_TARGET_PORT(i_, 32),
		
		`RV_INITIATOR_PORT(he_, 32),
		`RV_INITIATOR_PORT(ne_, 32),
		`RV_INITIATOR_PORT(se_, 32),
		`RV_INITIATOR_PORT(ee_, 32),
		`RV_INITIATOR_PORT(we_, 32)
		);
	
	assign he_dat = i_dat;
	assign ne_dat = i_dat;
	assign se_dat = i_dat;
	assign ee_dat = i_dat;
	assign we_dat = i_dat;

	reg[1:0]		state;
	
	assign i_ready = (state == 0 /* || */);
	
	// Need to 
	// TODO: needs to be a FIFO 
	reg[31:0]		fifo;
	reg[3:0]		payload_sz;
	
	reg[1:0]		dst_x = header[31:30];
	reg[1:0]		dst_y = header[29:28];
	reg				valid_h;
	reg				valid_n;
	reg				valid_s;
	reg				valid_e;
	reg				valid_w;
	
	wire[31:0]		fifo_top;
	
	assign he_dat = fifo_top;
	assign ne_dat = fifo_top;
	assign se_dat = fifo_top;
	assign ee_dat = fifo_top;
	assign we_dat = fifo_top;
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= 0;
			dst_x <= {2{1'b0}};
			dst_y <= {2{1'b0}};
			valid_h <= 1'b0;
			valid_n <= 1'b0;
			valid_s <= 1'b0;
			valid_e <= 1'b0;
			valid_w <= 1'b0;
		end else begin
			case (state)
				0: begin
					if (i_valid && i_ready) begin
						dst_x <= i_dat[31:30];
						dst_y <= i_dat[29:28];
						payload_sz <= i_dat[3:0];
						state <= 1;
					end
				end
				1: begin
					if (dst_x == X_ID || dst_y == Y_ID) begin
						// Destination is here
						valid_h <= 1'b1;
					end else if (dst_x > X_ID) begin
						// Send East
						valid_e <= 1'b1;
					end else if (dst_x < X_ID) begin
						// Send West
						valid_w <= 1'b1;
					end else if (dst_y > Y_ID) begin
						// Send North
						valid_n <= 1'b1;
					end else if (dst_y < Y_ID) begin
						// Send South
						valid_s <= 1'b1;
					end
				end
				2: begin
					// Send the header to the destination
				end
				3: begin
					// Send the remainder of the message 
					state <= 0;
				end
			endcase
		end
	end
	// TODO: 
	
	// Ingress:
	// - Accept header
	// - Determine what action to take
	//   - If dst is <this>, then forward to host port
	//   - If dst.x > <this.x>, then send east
	//   - If dst.x < <this.x>, then send west
	//   - If dst.y > <this.y>, then send north
	//   - If dst.y < <this.y>, then send south

endmodule


