
/****************************************************************************
 * spi_target_bfm.v
 * 
 ****************************************************************************/

module spi_target_bfm #(
        ) (
        input						reset,
        input						sclk,
        input						copi,
        output						cipo,
        input						cs_n
        );
	
	reg[7:0]			wordsize = 8;
	reg[63:0]			data = 0;
	reg[7:0]			bitcount = 0;
        
    task init;
    begin
        $display("spi_target_bfm: %m");
        // TODO: pass parameter values
        _set_parameters();
    end
    endtask
    
    always @(posedge sclk or posedge reset) begin
    	if (reset) begin
    		data <= {64{1'b0}};
    	end else begin
    		data <= {data[62:0], copi};
    	end
    end
	
    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
