`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:12:57 10/06/2015
// Design Name:   moduluscalc
// Module Name:   D:/NTU/1_Embedded_sys_design/Xilinx_PL/modulus funtion/modulus/moduluscalc_test.v
// Project Name:  modulus
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: moduluscalc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module moduluscalc_test;

	// Inputs
	reg ce;
	;
	reg reset;
	reg clk;
	reg [30:0] realpart;
	reg [30:0] imagpart;

	// Outputs
	wire [30:0] sample1;

	// Instantiate the Unit Under Test (UUT)
	moduluscalc uut (
		.ce(ce), 
		.reset(reset), 
		.clk(clk), 
		.realpart(realpart), 
		.imagpart(imagpart), 
		.sample1(sample1)
	);
always
#10 clk = ~clk;

	initial begin
		// Initialize Inputs
		ce = 0;
		reset = 1;
		clk = 0;
		realpart = 0;
		imagpart = 0;

		// Wait 100 ns for global reset to finish
		#100;
		@(posedge clk)
		begin
		ce = 1;
		reset = 0;
		realpart = 5;
		imagpart = 10;
		end
		
		#20;
		//end
		//@(posedge clk)
		//begin
		realpart = 10;
		imagpart = 20;
		
			#20;
		//end
		//@(posedge clk)
		//begin
		realpart = 20;
		imagpart = 10;
			#20;
		//end
		//@(posedge clk)
		//begin
		realpart = 30;
		imagpart = 40;
		//end
		
        
		// Add stimulus here

	end
      
endmodule

