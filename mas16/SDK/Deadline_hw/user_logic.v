//----------------------------------------------------------------------------
// AUDIO PROCESSING MODULE 
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Author:			  Mahesh and Gourav
// Filename:          user_logic.v
// Version:           1.00.a
// Description:       User logic module.
// Date:              Fri Oct 09 12:19:21 2015 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here 
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Resetn,                  // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_CS,                      // Bus to IP chip select for user logic memory selection
  Bus2IP_RNW,                     // Bus to IP read/not write
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  Bus2IP_Burst,                   // Bus to IP burst-mode qualifier
  Bus2IP_BurstLength,             // Bus to IP burst length
  Bus2IP_RdReq,                   // Bus to IP read request
  Bus2IP_WrReq,                   // Bus to IP write request
  IP2Bus_AddrAck,                 // IP to Bus address acknowledgement
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error,                   // IP to Bus error response
  Type_of_xfer                    // Transfer Type
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_AWIDTH                   = 32;
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_MEM                      = 1;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 

  reg start;
  reg [15 : 0] xn_re;
  reg fwd_inv;
  reg fwd_inv_we;
  wire rfd;
  wire [6 : 0] xn_index;
  wire busy;
  wire edone;
  wire done;
  wire dv;
  wire [6 : 0] xk_index;
  wire [23 : 0] xk_re;
  wire [23 : 0] xk_im;
  reg [6:0] index_re = 0;  
  reg [6:0] index_im = 0; 
  integer ram_in [0:128];
  reg [31:0] ram_re [0:127]; 
  reg [31:0] ram_im [0:127]; 
  reg [31:0] ram_mod [0:7][0:63]; 
  reg [31:0] ram_avg [0:63]; 
  reg [31:0] ram_noise [0:63]; 
  reg [31:0] ram_avg_out [0:128];
  reg [5:0] cnt = 0;
  reg [5:0] cnt_1 = 0; 
  reg [5:0] cnt_2 = 0 ;
  reg [5:0] cnt_3 = 0;
  reg [1:0] flag = 0;
  reg flag_1 = 0;
  reg flag_2 = 0;
  reg state = 0;
  reg [5:0]index_mul = 0;
  reg [2:0] id = 0 ;
  reg [7:0] noise_flag = 0;
  
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Resetn;
input      [C_SLV_AWIDTH-1 : 0]           Bus2IP_Addr;
input      [C_NUM_MEM-1 : 0]              Bus2IP_CS;
input                                     Bus2IP_RNW;
input      [C_SLV_DWIDTH-1 : 0]           Bus2IP_Data;
input      [C_SLV_DWIDTH/8-1 : 0]         Bus2IP_BE;
input      [C_NUM_MEM-1 : 0]              Bus2IP_RdCE;
input      [C_NUM_MEM-1 : 0]              Bus2IP_WrCE;
input                                     Bus2IP_Burst;
input      [7 : 0]                        Bus2IP_BurstLength;
input                                     Bus2IP_RdReq;
input                                     Bus2IP_WrReq;
output                                    IP2Bus_AddrAck;
output     [C_SLV_DWIDTH-1 : 0]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
output                                    Type_of_xfer;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic

parameter NUM_BYTE_LANES = (C_SLV_DWIDTH+7)/8;
reg [C_SLV_DWIDTH-1 : 0] mem_data_out [0 : C_NUM_MEM-1];
wire [7:0] mem_address;
wire mem_select;
wire mem_read_enable;
reg  [C_SLV_DWIDTH-1 : 0] mem_ip2bus_data;
reg mem_read_ack_dly1;
reg mem_read_ack_dly2; 
wire mem_read_ack; 
wire mem_write_ack; 
//reg [7 : 0] ram [C_NUM_MEM-1 : 0][NUM_BYTE_LANES-1 : 0][0 :255];
reg [NUM_BYTE_LANES-1 : 0] write_enable [C_NUM_MEM-1 : 0];
reg [7 : 0] data_in [C_NUM_MEM-1 : 0][NUM_BYTE_LANES-1 : 0];
reg [7 : 0] data_out [C_NUM_MEM-1 : 0][NUM_BYTE_LANES-1 : 0];
reg [7 : 0] read_address;

integer i;
integer byte_index;
  // --USER logic implementation added here

// ------------------------------------------------------
// Example code to read/write user memory space
assign mem_select = Bus2IP_CS;
assign mem_read_enable = Bus2IP_RdCE[0];

/* Generation of pulse */
assign mem_read_ack = (mem_read_ack_dly1 && (!mem_read_ack_dly2));
assign mem_write_ack = Bus2IP_WrCE[0];
/* For addressing, just like index */
assign mem_address = Bus2IP_Addr[9:2];
assign mem_write_enable = Bus2IP_WrCE[0];

/* 2 Flip Flop synchronization between different clock domain */
always @( posedge Bus2IP_Clk)
begin
    if(Bus2IP_Resetn == 0) 
    begin
      mem_read_ack_dly1 <= 0;
      mem_read_ack_dly2 <= 0;
    end
    else
    begin
      mem_read_ack_dly1 <= mem_read_enable;
      mem_read_ack_dly2 <= mem_read_ack_dly1;
    end
end
 
/* Fetch inputs from the SDK */ 
always @(posedge Bus2IP_Clk)
begin
	if (mem_write_enable)
		ram_in[mem_address] <= Bus2IP_Data;
	if (start == 1)
		ram_in[128] <= 0;
end

/* Loading Data into FFT */
/* For synchronization, write 128th bit as '1' before moving to FFT */
always @(posedge Bus2IP_Clk)
begin
if(!Bus2IP_Resetn)
begin
	start <= 0;
	fwd_inv <= 0;
	fwd_inv_we <= 0;	
	state <= 0;
end
else
begin
case(state)
0: begin
	/* FFT start */
		if ((ram_in[128] == 1) && (!busy))
		begin
			start <= 1;
			fwd_inv <= 1;
			fwd_inv_we <= 1;	
			state <= 1;
			xn_re <= ram_in[xn_index];
		end
	end
1: begin	
	/* Check for read for data high */
		if (rfd)
		begin
			xn_re <= ram_in[xn_index+1];
		end
	/* If all the data is transferred to FFT engine */
		if(xn_index == 127)
		begin
			start <= 0;
			fwd_inv <= 0;
			fwd_inv_we <= 0;
			state <= 0;
		end
	end
default: state<= state;
endcase	
end
end


/* Store the real value from FFT into ram */
/* Check for 23rd bit for 1 */
/* Extending the 24 bit value to 32 bits and converting the 2's complement into -ve number */
always @(posedge Bus2IP_Clk)
begin
/* Start reading the value, if data valid is high */
if (dv == 1)
begin
	index_re <= index_re + 1;
	if ((xk_re >> 23) == 1)
		ram_re[index_re] <= (-{{8{xk_re[23]}},xk_re});
	else
		ram_re[index_re] <= xk_re;
end
end

/* Store the imag value from FFT into ram */
/* Check for 23rd bit for 1 */
/* Extending the 24 bit value to 32 bits and converting the 2's complement into -ve number */
always @(posedge Bus2IP_Clk)
begin
/* Start reading the value, if data valid is high */
if (dv == 1)
begin
	index_im <= index_im + 1;
	if ((xk_im >> 23) == 1)
		ram_im[index_im] <= (-{{8{xk_im[23]}},xk_im});
	else
		ram_im[index_im] <= xk_im;
end
/* Floping the mem_address to read_address, as mem_address is directly connected to bus, which can change */
read_address <= mem_address;
end


/* Using state machine, doing modulus and sliding window averaging */
/* For optimization, we have used just 64 samples and have done mirroring for resource optimization */
/* For synchronization, we monitor 128 bit in SDK before displaying on the OLED */
always @(posedge Bus2IP_Clk)
begin
case(flag)
2'd0 : begin
		if (xk_index == 7'd127)
		begin
			flag <= 2'd1;
			ram_avg_out[128] <= 0;
		end
		if(start)
		begin
			flag_1 <= 0;
			flag_2 <= 0;
			ram_avg_out[128] <= 0;
		end		
	end
2'd1:  begin
		/* Modulus functionality */
			ram_mod[id][index_mul] <= (ram_re[cnt]*ram_re[cnt])+ (ram_im[cnt]*ram_im[cnt]);
			index_mul <= index_mul + 1;
			cnt <= cnt + 1;
			if(cnt == 6'd63)
			begin
				id <= id + 1;
				flag <= 2'd2;
				flag_1 <= 1;
				cnt <= 0;
			end	
		end
2'd2: begin
		if (flag_1)
		begin
		/* Sliding window averaging */
			ram_avg[cnt_1] <= ((ram_mod[0][cnt_1]+ ram_mod[1][cnt_1]+ ram_mod[2][cnt_1] + ram_mod[3][cnt_1] + ram_mod[4][cnt_1]+ ram_mod[5][cnt_1]+ ram_mod[6][cnt_1] + ram_mod[7][cnt_1]) >> 3 );
			cnt_1 <= cnt_1 + 1 ;
			if(cnt_1 == 6'd63)
			begin
				flag <= 2'd3;
				flag_2 <= 1;
				cnt_1 <= 0;			
			end
		end
	end
2'd3: begin
	  /* Calculating noise for 128 windows */
	  if((flag_2 == 1) && (noise_flag < 128))
	  begin
			ram_noise[cnt_2] <= ram_noise[cnt_2] + ((ram_avg[cnt_2])>>7);
			cnt_2 <= cnt_2 + 1;
			if(cnt_2 == 6'd63)
			begin
				flag <= 2'd0;
				cnt_2 <= 0;	
				noise_flag <= noise_flag + 1;
			end
		end
	  else if((flag_2 == 1) && (noise_flag >= 128))
	  begin
	  /* Lower thresholding */
	  /* Mirroring */
		if ((ram_avg[cnt_3] - ram_noise[cnt_3]) >> 31 == 1)
		begin
			ram_avg_out[cnt_3] <= 0;
			ram_avg_out[127-cnt_3] <= 0;
		end
	  /* Upper thresholding */
	  /* Mirroring */
		else if ((ram_avg[cnt_3][31:18] - ram_noise[cnt_3][31:18]) > 63)
		begin
			ram_avg_out[cnt_3] <= 63;
			ram_avg_out[127-cnt_3] <= 63;
		end
		else
		begin
			ram_avg_out[cnt_3] <= (ram_avg[cnt_3][31:18] - ram_noise[cnt_3][31:18]);
			ram_avg_out[127-cnt_3] <= (ram_avg[cnt_3][31:18] - ram_noise[cnt_3][31:18]);
		end
		cnt_3 <= cnt_3 + 1;
		if(cnt_3 == 6'd63)
		begin
			flag <= 2'd0;
			cnt_3 <= 0;
			ram_avg_out[128] <= 1;
		end
	end
end	
default: flag<= flag;
endcase
end

/* Pass the values into bus, once read_address has been sent through the SDK */
always @(*)
begin
  case (mem_select) 
    1 : mem_ip2bus_data <= ram_avg_out[read_address];
  default : mem_ip2bus_data <= 0;
  endcase
end

/* Only, when acknowledgement goes high, pass the data into the bus */
  assign IP2Bus_Data  = (mem_read_ack == 1'b1) ? mem_ip2bus_data : 0;
  assign IP2Bus_AddrAck = (mem_write_ack || (mem_read_enable && mem_read_ack));
  assign IP2Bus_WrAck = mem_write_ack;
  assign IP2Bus_RdAck = mem_read_ack;
  assign IP2Bus_Error = 0;
  

  //FFT Instantiation
  /* Make unload signal 'high' and imaginary data 'zero' */
  fftip your_instance_name (
  .clk(Bus2IP_Clk), // input clk
  .start(start), // input start
  .unload(1), // input unload
  .xn_re(xn_re), // input [15 : 0] xn_re
  .xn_im(0), // input [15 : 0] xn_im          
  .fwd_inv(fwd_inv), // input fwd_inv
  .fwd_inv_we(fwd_inv_we), // input fwd_inv_we
  .rfd(rfd), // output rfd
  .xn_index(xn_index), // output [6 : 0] xn_index
  .busy(busy), // output busy
  .edone(edone), // output edone
  .done(done), // output done
  .dv(dv), // output dv
  .xk_index(xk_index), // output [6 : 0] xk_index
  .xk_re(xk_re), // output [23 : 0] xk_re
  .xk_im(xk_im) // output [23 : 0] xk_im
);

endmodule
