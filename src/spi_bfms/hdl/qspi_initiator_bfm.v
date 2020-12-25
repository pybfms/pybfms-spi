
/****************************************************************************
 * qspi_initiator_bfm.v
 * 
 ****************************************************************************/

module qspi_initiator_bfm #(
        ) (
        input                            clock,
        input                            reset
        );
        
    reg            in_reset = 0;
    
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            in_reset <= 1;
        end else begin
            if (in_reset) begin
                _reset();
                in_reset <= 1'b0;
            end
        end
    end
        
    task init;
    begin
        $display("qspi_initiator_bfm: %m");
        // TODO: pass parameter values
        _set_parameters();
    end
    endtask
	
    // Auto-generated code to implement the BFM API
`ifdef PYBFMS_GEN
${pybfms_api_impl}
`endif

endmodule
