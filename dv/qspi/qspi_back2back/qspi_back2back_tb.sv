/****************************************************************************
 * qspi_back2back_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns / 1ns
`endif
  
/**
 * Module: qspi_back2back_tb
 * 
 * TODO: Add module documentation
 */
module qspi_back2back_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clk_r = 0;
	initial begin
		forever begin
			#10;
			clk_r <= ~clk_r;
		end
	end
	assign clock = clk_r;
`endif
	
`ifdef IVERILOG
`include "iverilog_control.svh"
`endif
	
	wire sck /*verilator public*/;
	wire[3:0] io;
	wire[3:0] csn;
	wire reset;
	
	resetgen u_reset(
			.clock(clock),
			.reset(reset)
			);

	qspi_initiator_bfm u_init (
			.clk(				clock),
			.resetn(			~reset),
			.sck(				sck),
			.csn(				csn),
			.io(				io)
			);
		
	qspi_target_bfm u_targ (
			.sck(				sck),
			.csn(				csn[0]),
			.io(				io)
			);

endmodule


