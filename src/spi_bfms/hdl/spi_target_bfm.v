
/****************************************************************************
 * spi_target_bfm.v
 * 
 ****************************************************************************/

module spi_target_bfm #(
		parameter DAT_WIDTH = 8
        ) (
        input						reset,
        input						sck,
        input						sdi,
        inout						sdo,
        input						csn
        );

	reg sdo_r = 0;
	assign sdo = (~csn)?sdo_r:1'bz;
	
	reg[7:0]			wordsize = 8;
	reg[63:0]			data = 0;
	reg[7:0]			bitcount = 0;
	
	reg[DAT_WIDTH-1:0]		dat_in_r = {DAT_WIDTH{1'b0}};
	reg[DAT_WIDTH-1:0]		dat_out_v = {DAT_WIDTH{1'b0}};
	reg[DAT_WIDTH-1:0]		dat_out_r = {DAT_WIDTH{1'b0}};
	
	// Transmit state machine
	reg      xmit_state = 0;
	reg[7:0] xmit_count = 0;
	always @(negedge sck or posedge reset) begin
		if (reset) begin
			xmit_state <= 0;
			xmit_count <= {8{1'b0}};
		end else begin
			sdo_r <= (xmit_state)?dat_out_r[DAT_WIDTH-1]:dat_out_v[DAT_WIDTH-1];
			case (xmit_state) 
				0: begin
					dat_out_r <= {dat_out_v[DAT_WIDTH-2:0], 1'b0};
					xmit_state <= 1'b1;
					xmit_count <= 1;
				end
				1: begin
					dat_out_r <= {dat_out_r[DAT_WIDTH-2:0], 1'b0};
					if (xmit_count == DAT_WIDTH-1) begin
						xmit_state <= 0;
					end else begin
						xmit_count <= xmit_count + 1;
					end
				end
			endcase
		end
	end
	
	// Receive state machine
	reg      recv_state = 0;
	reg[7:0] recv_count = 0;
	always @(posedge sck or posedge reset) begin
		if (reset) begin
			recv_state <= 0;
			recv_count <= {8{1'b0}};
		end else begin
			dat_in_r <= {dat_in_r[DAT_WIDTH-2:0], sdi};
			case (recv_state)
				0: begin
					if (~csn) begin
						recv_count <= 1;
						recv_state <= 1;
						// Notify the Python side so it can
						// specify the data to send
						_recv_start();
					end
				end
				1: begin
					if (recv_count == DAT_WIDTH-1) begin
						recv_state <= 0;
						// Send the resulting data back. Note that
						// The final bit hasn't been shifted in, so we
						// handle that here
						$display("Recive byte 'h%02h", {dat_in_r[DAT_WIDTH-2:0], sdi});
						_recv({dat_in_r[DAT_WIDTH-2:0], sdi});
					end else begin
						recv_count <= recv_count + 1;
					end
				end
			endcase
		end
	end	
        
    task init;
    begin
        $display("spi_target_bfm: %m");
        _set_parameters(DAT_WIDTH);
    end
    endtask
    
	task _send(input reg[63:0]	data);
	begin
		dat_out_v = data[DAT_WIDTH-1:0];
	end
	endtask
    
    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
