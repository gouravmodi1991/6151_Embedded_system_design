`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: NTU
// Engineer: Gourav and Mahesh
//
// Create Date:   23:50:50 10/09/2015
// Design Name:   fftip
// Module Name:   D:/hardware_part/fft/fft_test_bench.v
// Project Name:  FFT
// Target Device: Zedboard
// Description: FFT simulation
//
// Verilog Test Fixture created by ISE for module: fftip
// 
////////////////////////////////////////////////////////////////////////////////

module fft_test_bench;

	// Inputs
	reg clk;
	reg start;
	reg unload;
	reg fwd_inv;
	reg fwd_inv_we;
	reg [15:0] xn_re;
	reg [15:0] xn_im;

	// Outputs
	wire rfd;
	wire busy;
	wire edone;
	wire done;
	wire dv;
	wire [6:0] xn_index;
	wire [6:0] xk_index;
	wire [23:0] xk_re;
	wire [23:0] xk_im;

	// Instantiate the Unit Under Test (UUT)
	fftip uut (
		.clk(clk), 
		.start(start), 
		.unload(unload), 
		.fwd_inv(fwd_inv), 
		.fwd_inv_we(fwd_inv_we), 
		.rfd(rfd), 
		.busy(busy), 
		.edone(edone), 
		.done(done), 
		.dv(dv), 
		.xn_re(xn_re), 
		.xn_im(xn_im), 
		.xn_index(xn_index), 
		.xk_index(xk_index), 
		.xk_re(xk_re), 
		.xk_im(xk_im)
	);

/* Clock defination */
always 
#5 clk = ~ clk;


	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		unload = 0;
		fwd_inv = 0;
		fwd_inv_we = 0;
		xn_re = 0;
		xn_im = 0;

		/* Wait 100 ns for global reset to finish */
		#100;
		unload = 1;
		start = 1;
		fwd_inv = 1;
		fwd_inv_we = 1;
		/* Give 128 values to FFT */
		repeat(128) begin                          
		@(posedge(clk));
			xn_re = 1;  
		end
		unload = 0;
		#1000;
		wait(dv);
		start = 0;
		fwd_inv = 0;
		fwd_inv_we = 0;
	end
endmodule

