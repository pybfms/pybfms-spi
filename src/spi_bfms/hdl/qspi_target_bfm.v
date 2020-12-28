
/****************************************************************************
 * qspi_target_bfm.v
 * 
 * Implements the BFM for a QSPI memory model. Python implements the 
 * back-end logic of the actual memory model
 ****************************************************************************/

module qspi_target_bfm #(
		parameter DAT_WIDTH = 8
        ) (
        input				resetn,
        input				sck,
        input				csn,
        inout[3:0]			io
        );
        
	// Active-high output enable
	reg xmit_en = 0;
	reg[3:0] oe_r = {4{1'b0}};
	reg[3:0] do_r = {4{1'b0}};
	wire[3:0] di = io;
	
	assign io[0] = (oe_r[0])?do_r[0]:1'bz;
	assign io[1] = (oe_r[1])?do_r[1]:1'bz;
	assign io[2] = (oe_r[2])?do_r[2]:1'bz;
	assign io[3] = (oe_r[3])?do_r[3]:1'bz;
	
	reg[DAT_WIDTH-1:0]		dat_in_r = {DAT_WIDTH{1'b0}};
	reg[DAT_WIDTH-1:0]		dat_out_v = {DAT_WIDTH{1'b0}};
	reg[DAT_WIDTH-1:0]		dat_out_r = {DAT_WIDTH{1'b0}};
	
	localparam XFER_MODE_SPI      = 0;
	localparam XFER_MODE_DSPI     = (XFER_MODE_SPI+1);
	localparam XFER_MODE_QSPI     = (XFER_MODE_DSPI+1);
	localparam XFER_MODE_QSPI_DDR = (XFER_MODE_QSPI+1);
	reg[2:0]  xfer_mode = XFER_MODE_SPI;
	
	localparam CMD_REMS = 'h90; // Read manufacturer signature
	localparam CMD_RDID = 'h9F; // Read manufacturer signature
	localparam CMD_RES  = 'hAB; // Read electronic signature
	localparam CMD_READ        = 'h03; // Read, with a 3- or 4-byte address
	localparam CMD_4READ       = 'h13; // Read, with a 4-byte address
	localparam CMD_FAST_READ   = 'h0B; // Fast read with a 3- or 4-byte address
	localparam CMD_4FAST_READ  = 'h0C; // Fast read with a 4-byte address
	
	// Transmit state machine
	reg      xmit_state = 0;
	reg[7:0] xmit_count = 0;
	always @(negedge sck or negedge resetn) begin
		if (~resetn) begin
			xmit_state <= 0;
			xmit_count <= {8{1'b0}};
			xfer_mode = XFER_MODE_SPI;
		end else if (~csn) begin
			// Send the next bits
			case (xfer_mode)
				XFER_MODE_SPI: begin
					oe_r <= (xmit_en)?4'b0010:{4{1'b0}};
					do_r[1] <= (xmit_state)?dat_out_r[DAT_WIDTH-1]:dat_out_v[DAT_WIDTH-1];
				end
				XFER_MODE_DSPI: begin
					oe_r <= (xmit_en)?4'b0011:{4{1'b0}};
					do_r[1:0] <= (xmit_state)?dat_out_r[DAT_WIDTH-1:DAT_WIDTH-2]:dat_out_v[DAT_WIDTH-1:DAT_WIDTH-2];
				end
				XFER_MODE_QSPI: begin
					oe_r <= (xmit_en)?4'b1111:{4{1'b0}};
					do_r <= (xmit_state)?dat_out_r[DAT_WIDTH-1:DAT_WIDTH-4]:dat_out_v[DAT_WIDTH-1:DAT_WIDTH-4];
				end
			endcase
			
			case (xmit_state) 
				0: begin
					case (xfer_mode)
						XFER_MODE_SPI: begin
							dat_out_r <= {dat_out_v[DAT_WIDTH-2:0], 1'b0};
							xmit_count <= 1;
						end
						XFER_MODE_DSPI: begin
							dat_out_r <= {dat_out_v[DAT_WIDTH-3:0], 2'b0};
							xmit_count <= 2;
						end
						XFER_MODE_QSPI: begin
							dat_out_r <= {dat_out_v[DAT_WIDTH-5:0], 4'b0};
							xmit_count <= 4;
						end
					endcase
					xmit_state <= 1'b1;
				end
				1: begin
					case (xfer_mode)
						XFER_MODE_SPI: begin
							dat_out_r <= {dat_out_r[DAT_WIDTH-2:0], 1'b0};
							if (xmit_count == DAT_WIDTH-1) begin
								xmit_state <= 0;
							end else begin
								xmit_count <= xmit_count + 1;
							end
						end
						
						XFER_MODE_DSPI: begin
							dat_out_r <= {dat_out_r[DAT_WIDTH-3:0], 2'b0};
							if (xmit_count == DAT_WIDTH-2) begin
								xmit_state <= 0;
							end else begin
								xmit_count <= xmit_count + 2;
							end
						end
						
						XFER_MODE_QSPI: begin
							dat_out_r <= {dat_out_r[DAT_WIDTH-5:0], 4'b0};
							if (xmit_count == DAT_WIDTH-4) begin
								xmit_state <= 0;
							end else begin
								xmit_count <= xmit_count + 4;
							end
						end
					endcase
				end
			endcase
		end else begin
			// Float the io signals when idle
			do_r <= {4{1'b0}};
		end
	end
	
	// Receive state machine
	reg      recv_state = 0;
	reg[7:0] recv_count = 0;
	always @(posedge sck or negedge resetn) begin
		if (~resetn) begin
			recv_state <= 0;
			recv_count <= {8{1'b0}};
		end else if (~csn) begin
			do_r <= {4{1'b0}};
			case (xfer_mode)
				XFER_MODE_SPI: dat_in_r <= {dat_in_r[DAT_WIDTH-2:0], di[1]};
				XFER_MODE_DSPI: dat_in_r <= {dat_in_r[DAT_WIDTH-3:0], di[1:0]};
				XFER_MODE_QSPI: dat_in_r <= {dat_in_r[DAT_WIDTH-5:0], di[3:0]};
			endcase
			
			case (recv_state)
				0: begin
					case (xfer_mode)
						XFER_MODE_SPI: recv_count <= 1;
						XFER_MODE_DSPI: recv_count <= 2;
						XFER_MODE_QSPI: recv_count <= 4;
					endcase
					recv_state <= 1;
				end
				1: begin
					case (xfer_mode)
						XFER_MODE_SPI: begin
							if (recv_count == DAT_WIDTH-1) begin
								recv_state <= 0;
								// Send the resulting data back. Note that
								// The final bit hasn't been shifted in, so we
								// handle that here
								_recv({dat_in_r[DAT_WIDTH-2:0], di[1]});
							end else begin
								recv_count <= recv_count + 1;
							end
						end
						XFER_MODE_DSPI: begin
							if (recv_count == DAT_WIDTH-2) begin
								recv_state <= 0;
								// Send the resulting data back. Note that
								// The final bit hasn't been shifted in, so we
								// handle that here
								_recv({dat_in_r[DAT_WIDTH-3:0], di[1:0]});
							end else begin
								recv_count <= recv_count + 2;
							end
						end
						XFER_MODE_QSPI: begin
							if (recv_count == DAT_WIDTH-4) begin
								recv_state <= 0;
								// Send the resulting data back. Note that
								// The final bit hasn't been shifted in, so we
								// handle that here
								_recv({dat_in_r[DAT_WIDTH-5:0], di[3:0]});
							end else begin
								recv_count <= recv_count + 4;
							end
						end
					endcase
				end
			endcase
		end else begin
			// Float the io signals when idle
			do_r <= {4{1'b0}};
		end
	end
	
	task _send(input reg[63:0] data, input reg[2:0] mode);
	begin
		dat_out_v = data;
		xfer_mode = mode;
	end
	endtask
	
	task set_xfer_mode(input reg[31:0] mode);
	begin
		xfer_mode = mode;
	end
	endtask
        
    task init;
    begin
        $display("qspi_target_bfm: %m");
        // TODO: pass parameter values
        _set_parameters(DAT_WIDTH);
    end
    endtask
	
    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
