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
		parameter FIFO_DEPTH=4,
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
	
	wire[1:0] x_id = X_ID;
	wire[1:0] y_id = Y_ID;

	`RV_WIRES(if_, 32);
	generate
		if (FIFO_DEPTH > 0) begin
			fwnoc_fifo #(
				.DEPTH(FIFO_DEPTH)
				) u_ififo (
					.clock(clock),
					.reset(reset),
					`RV_CONNECT(i_, i_),
					`RV_CONNECT(e_, if_)
				);
		end else begin
			assign if_valid = i_valid;
			assign i_ready = if_ready;
			assign if_dat = i_dat;
		end
	endgenerate
	
	assign he_dat = if_dat;
	assign ne_dat = if_dat;
	assign se_dat = if_dat;
	assign ee_dat = if_dat;
	assign we_dat = if_dat;

	/**
	 * State 0: Wait for request
	 * State 1: Decode routing
	 * State 2: Forward packet
	 */
	reg[1:0]		state;

	// ready from the selected egress port
	reg ready;
	assign if_ready = (state == 2 && ready);
	
	reg[7:0]		payload_sz;
	
	reg[1:0]		dst_x;
	reg[1:0]		dst_y;

	/**
	 * 0 -- here
	 * 1 -- N
	 * 2 -- S
	 * 3 -- E
	 * 4 -- W
	 */
	reg[2:0]		dst;
	
	assign he_valid = ((dst == 3'd0) & if_valid && state == 2);
	assign ne_valid = ((dst == 3'd1) & if_valid && state == 2);
	assign se_valid = ((dst == 3'd2) & if_valid && state == 2);
	assign ee_valid = ((dst == 3'd3) & if_valid && state == 2);
	assign we_valid = ((dst == 3'd4) & if_valid && state == 2);
	
	always @* begin 
		case (dst) // synopsys parallel_case full_case
			3'd0: ready = he_ready;
			3'd1: ready = ne_ready;
			3'd2: ready = se_ready;
			3'd3: ready = ee_ready;
			3'd4: ready = we_ready;
		endcase
	end

	// payload_sz is power-2 encoded. We also
	// must account for the header word in determining
	// how much data to transfer
	reg[4:0] payload_sz_d;
	always @* begin
		case (if_dat[3:0]) // synopsys parallel_case full_case
			0: payload_sz_d = 5'd0;
			1: payload_sz_d = 5'd1;
			2: payload_sz_d = 5'd2;
			3: payload_sz_d = 5'd4;
			4: payload_sz_d = 5'd8;
			5: payload_sz_d = 5'd16;
		endcase
	end
	
	wire x_dst_gt = (dst_x > x_id);
	wire x_dst_lt = (dst_x < x_id);
	wire y_dst_gt = (dst_y > y_id);
	wire y_dst_lt = (dst_y < y_id);
	
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= 0;
			dst_x <= {2{1'b0}};
			dst_y <= {2{1'b0}};
			dst <= 3'd0;
		end else begin
			case (state)
				0: begin
					if (if_valid) begin
						dst_x <= if_dat[31:30];
						dst_y <= if_dat[29:28];
						payload_sz <= payload_sz_d;
						state <= 1;
					end
				end
				1: begin
					if (x_dst_gt) begin // dst_x > x_id: send East
						dst <= 3'd3;
					end else if (x_dst_lt) begin // dst_x < x_id: send West
						dst <= 3'd4;
					end else if (y_dst_gt) begin // dst_y > y_id: send South
						dst <= 3'd2;
					end else if (y_dst_lt) begin // dst_y < y_id: send North
						dst <= 3'd1;
					end else begin // Send here
						dst <= 3'd0;
					end
					state <= 2;
				end
				2: begin
					// Send the remainder of the message 
					if (ready && if_valid) begin
						if (payload_sz == 0) begin
							// All done
							state <= 0;
						end else begin
							payload_sz <= payload_sz - 1;
						end
					end
				end
				3: begin
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


