`timescale 1ns / 1ps
//----------------------------------------------------------------------------
// Modulus.v - module
//----------------------------------------------------------------------------
  // ------------------------------------------------------
  // 
  //    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  //                     "1000"   C_BASEADDR + 0x0
  //                     "0100"   C_BASEADDR + 0x4
  //                     "0010"   C_BASEADDR + 0x8
  //                     "0001"   C_BASEADDR + 0xC
  // 
  // ------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:          Modulus.v
// Version:           1.00.a
// Description:       Modulus module.
// Date:              Mon Nov 09 22:28:10 2015
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
module Modulus
(
input                                     Bus2IP_Clk,
input                                     Bus2IP_Resetn,
input      [31 : 0]           				Bus2IP_Data,
input      [2 : 0]         					Bus2IP_BE,
input      [2 : 0]              			   Bus2IP_RdCE,
input      [2 : 0]              				Bus2IP_WrCE,
output     [31 : 0] 					         IP2Bus_Data,
output                                    IP2Bus_RdAck,
output                                    IP2Bus_WrAck,
output                                    IP2Bus_Error
); 

parameter C_NUM_REG                      = 3;
parameter C_SLV_DWIDTH                   = 32;
reg        [C_SLV_DWIDTH-1 : 0]           slv_reg0;
reg        [C_SLV_DWIDTH-1 : 0]           slv_reg1;
reg        [C_SLV_DWIDTH-1 : 0]           slv_reg2;
wire       [2 : 0]                        slv_reg_write_sel;
wire       [2 : 0]                        slv_reg_read_sel;
reg        [C_SLV_DWIDTH-1 : 0]           slv_ip2bus_data;
wire                                      slv_read_ack;
wire                                      slv_write_ack;
integer                                   byte_index, bit_index;
	assign
    slv_reg_write_sel = Bus2IP_WrCE[2:0],
    slv_reg_read_sel  = Bus2IP_RdCE[2:0],
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2];

  // implement slave model register(s)
  always @( posedge Bus2IP_Clk )
    begin
        case ( slv_reg_write_sel )
          3'b100 :
                slv_reg0 <= Bus2IP_Data;
          3'b010 :
                slv_reg1 <= Bus2IP_Data;
          default : begin
            slv_reg0 <= slv_reg0;
            slv_reg1 <= slv_reg1;
            slv_reg2 <= slv_reg2;
                    end
        endcase

    end // SLAVE_REG_WRITE_PROC
	
	always @(posedge Bus2IP_Clk)
begin
	  /* Lower thresholding */
		if ((slv_reg0 - slv_reg1) >> 31 == 1)
		begin
			 slv_reg2 <= 0;
		end
	  /* Upper thresholding */
		else if ((slv_reg0[31:18] - slv_reg1[31:18]) > 63)
		begin
			slv_reg2 <= 63;
		end
		else
		begin
			slv_reg2 <= (slv_reg0[31:18] -slv_reg1[31:18]);
		end
end
  // Implement slave model register read mux
  always @( slv_reg_read_sel or slv_reg2 )
    begin 

      case ( slv_reg_read_sel )
        3'b001 : slv_ip2bus_data <= slv_reg2;
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC

  assign IP2Bus_Data = (slv_read_ack == 1'b1) ? slv_ip2bus_data :  0 ;
  assign IP2Bus_WrAck = slv_write_ack;
  assign IP2Bus_RdAck = slv_read_ack;
  assign IP2Bus_Error = 0;

endmodule