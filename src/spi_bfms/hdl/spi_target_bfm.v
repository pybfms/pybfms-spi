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
	reg						dat_out_valid_v = 0;
	reg[DAT_WIDTH-1:0]		dat_out_r = {DAT_WIDTH{1'b0}};
	
	// Transmit state machine
	always @(negedge sck or posedge reset) begin
		if (reset || csn) begin
			dat_out_r <= {DAT_WIDTH{1'b0}};
		end else begin
			if (dat_out_valid_v) begin
				sdo_r <= dat_out_v[DAT_WIDTH-1];
				dat_out_r <= {dat_out_v[DAT_WIDTH-2:0], 1'b0};
				dat_out_v = 0;
				dat_out_valid_v = 0;
			end else begin
				sdo_r <= dat_out_r[DAT_WIDTH-1];
				dat_out_r <= {dat_out_r[DAT_WIDTH-2:0], 1'b0};
			end
		end
	end
	
	// Receive state machine
	reg      recv_state = 0;
	reg[7:0] recv_count = 0;
	always @(posedge sck or posedge reset or posedge csn) begin
		if (reset) begin
			recv_state <= 0;
			recv_count <= {8{1'b0}};
		end else if (csn) begin
			_clocked_csn_high();
			recv_state <= 0;
		end else begin
			dat_in_r <= {dat_in_r[DAT_WIDTH-2:0], sdi};
			case (recv_state)
				0: begin
					recv_count <= 1;
					recv_state <= 1;
					// Notify the Python side so it can
					// specify the data to send
					_recv_start();
				end
				1: begin
					if (recv_count == DAT_WIDTH-1) begin
						recv_state <= 0;
						// Send the resulting data back. Note that
						// The final bit hasn't been shifted in, so we
						// handle that here
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
		dat_out_valid_v = 1;
	end
	endtask
    
    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
