/****************************************************************************
 * spi_target_smoke_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns / 1ns
`endif
  
/**
 * Module: spi_target_smoke_tb
 * 
 * TODO: Add module documentation
 */
module spi_target_smoke_tb(input clock);
	
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
	
	wire sck;
	wire sdo;
	wire sdi;
	wire[3:0] csn;

	spi_initiator_bfm u_init(
			.clk(clock),
			.sck(				sck),
			.sdo(				sdo),
			.sdi(				sdi),
			.csn(				csn)
			);

	spi_target_bfm u_targ(
			.resetn(1'b1),
			.sck(				sck),
			.sdo(				sdi),
			.sdi(				sdo),
			.csn(				csn[0])
			);

endmodule


