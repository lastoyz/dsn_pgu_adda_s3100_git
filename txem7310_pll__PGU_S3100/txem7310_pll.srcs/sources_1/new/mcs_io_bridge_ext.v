// mcs_io_bridge_ext.v
//  for mb MCS IO bus slave 
//  support MCS port end-point
//  support LAN dedicated end-point
//

// - IO timing -- write 
//  clk               :  _-_-_-_-_-_-_-_-_-_
//  i_IO_addr_strobe  : __--________________
//  i_IO_address      : __AA________________
//  i_IO_byte_enable  : __BB________________
//  o_IO_read_data    : ____________________
//  i_IO_read_strobe  : ____________________
//  o_IO_ready        : ____--______________
//  i_IO_write_data   : __DD________________
//  i_IO_write_strobe : __--________________

// - IO timing -- read
//  clk               :  _-_-_-_-_-_-_-_-_-_
//  i_IO_addr_strobe  : __--________________
//  i_IO_address      : __AA________________
//  i_IO_byte_enable  : ____________________
//  o_IO_read_data    : ____DD______________
//  i_IO_read_strobe  : __--________________
//  o_IO_ready        : ____--______________
//  i_IO_write_data   : ____________________
//  i_IO_write_strobe : ____________________

// - IO BUS map 
//  base    : XPAR_IOMODULE_IO_BASEADDR = 32'h_C000_0000
//  offsets : 30 bits 
//    ADRS_FPGA_IMAGE_ID = XPAR_IOMODULE_IO_BASEADDR + 32'h_0000_0000
//    ADRS_TEST_REG      = XPAR_IOMODULE_IO_BASEADDR + 32'h_0000_0004
//    ...
//    ADRS_END           = XPAR_IOMODULE_IO_BASEADDR + 32'h_3FFF_FFFF

`timescale 1ns / 1ps

//// submodules

// module for o_port_wi_X //{
module o_wi_core (
	input wire clk, // assume 72MHz
	input wire reset_n,
	//
	input  wire        i_IO_addr_strobe ,
	input  wire        i_IO_write_strobe,
	input  wire [31:0] i_IO_address     ,
	input  wire [31:0] i_IO_write_data  ,
	input  wire [31:0] i_mask_wi        , //
	//
	output wire [31:0] o_wi  //
);
//{
parameter ADRS_PORT_WI           = 32'h_CDCD_CDCD; //
parameter ADRS_PORT_WI_00        = ADRS_PORT_WI;   // temporal name
//
reg  [31:0] r_port_wi_00;
//
wire [31:0] r_mask_wi = i_mask_wi; // temporal name
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_wi_00 <= 32'b0;
	end
	// note  r_port_wi_00 <= (r_port_wi_00, i_IO_write_data, r_mask_wi)
	//       0                0             0                0
	//       0                0             0                1
	//       0                0             1                0
	//       1                0             1                1
	//       1                1             0                0
	//       0                1             0                1
	//       1                1             1                0
	//       1                1             1                1
	//      r_port_wi_00 <= (r_port_wi_00&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi)
	//
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_00)) begin 
		r_port_wi_00 <= (r_port_wi_00&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); 
		end
//
assign o_wi = r_port_wi_00;
//}
endmodule
//}


// TODO: module for o_port_ti_X //{
module o_ti_core (
	input wire clk, // assume 72MHz
	input wire reset_n,
	//
	input  wire        i_IO_addr_strobe ,
	input  wire        i_IO_write_strobe,
	input  wire [31:0] i_IO_address     ,
	input  wire [31:0] i_IO_write_data  ,
	//
	input  wire [31:0] i_mask_ti        , // r_mask_ti
	//
	input  wire        i_port_ck        , // i_port_ck_40
	output wire [31:0] o_ti_clk         , // o_port_ti_40 // sampled
	output wire [31:0] o_ti_reg           // r_port_ti_40
);
//{
parameter ADRS_PORT_TI           = 32'h_CDCD_CDCD; //
parameter ADRS_PORT_TI_40        = ADRS_PORT_TI;   // temporal name
//

// input  wire i_port_ck_40, output wire [31:0]   o_port_ti_40 ,
reg [31:0] r_port_ti_40; reg [31:0] r_port_ti_40_smp; reg [31:0] r_port_ti_40_smpp;
//
wire        i_port_ck_40 = i_port_ck; // temporal name
wire [31:0] r_mask_ti    = i_mask_ti; // temporal name


// always r_port_ti_X 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_40 <= 32'b0;
	end
	else begin
		// trig on
		//else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_40)) begin r_port_ti_40 <= (r_port_ti_40&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end
		// note r_port_ti_40 <= (r_port_ti_40, i_IO_write_data, r_mask_ti)
		//      0                0             0                0
		//      0                0             0                1
		//      0                0             1                0
		//      1                0             1                1
		//      1                1             0                0
		//      0                1             0                1
		//      1                1             1                0
		//      1                1             1                1
		//
		// trig off
		//else begin r_port_ti_40 <= r_port_ti_40 & (~r_port_ti_40_smp); end
		// note r_port_ti_40 <= (r_port_ti_40, r_port_ti_40_smp)
		//      0                0             0
		//      0                0             1
		//      1                1             0
		//      0                1             1
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_40)) begin 
			r_port_ti_40 <= (r_port_ti_40&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); 
			end  
		else begin 
			r_port_ti_40 <= r_port_ti_40 & (~r_port_ti_40_smp); 
			end
	end
		
// always r_port_ti_X_smp
always @(posedge i_port_ck_40, negedge reset_n)	
	if (!reset_n) begin 
		r_port_ti_40_smp  <= 32'b0; 
		r_port_ti_40_smpp <= 32'b0; 
		end  
	else begin 
		r_port_ti_40_smp  <= r_port_ti_40; 
		r_port_ti_40_smpp <= r_port_ti_40_smp; 
		end

// assign o_port_ti_X 
wire [31:0] o_port_ti_40 = (~r_port_ti_40_smp) & r_port_ti_40_smpp;
assign o_ti_clk = o_port_ti_40;
assign o_ti_reg = r_port_ti_40;


//}
endmodule
//}


// TODO: module for r_port_to_X //{ // to revise more
module i_to_core (
	input wire clk, // assume 72MHz
	input wire reset_n,
	//
	input  wire        i_IO_addr_strobe ,
	//input  wire        i_IO_write_strobe,
	input  wire        i_IO_read_strobe,
	input  wire [31:0] i_IO_address     ,
	//input  wire [31:0] i_IO_write_data  ,
	//
	input  wire [31:0] i_mask_to        , // r_mask_to
	//
	input  wire        i_port_ck        , // i_port_ck_60
	input  wire [31:0] i_to_clk         , // i_port_to_60 // sampled
	output wire [31:0] o_to_reg           // r_port_to_60
);
//{
parameter ADRS_PORT_TO           = 32'h_CDCD_CDCD; //
parameter ADRS_PORT_TO_60        = ADRS_PORT_TO;   // temporal name
//

wire         i_port_ck_60 = i_port_ck;
wire [31:0]  i_port_to_60 = i_to_clk; 
wire [31:0]  r_mask_to    = i_mask_to; // temporal

// input  wire i_port_ck_60, input  wire [31:0]   i_port_to_60 ,
reg [31:0] r_port_to_60; reg [31:0] r_port_to_60_smp;
//
always @(posedge i_port_ck_60, negedge reset_n)	
	if (!reset_n) begin	
		r_port_to_60  <= 32'b0; 
		end  
	else begin 
		r_port_to_60  <= ( (~r_port_to_60)&i_port_to_60 ) | ( r_port_to_60&(~r_port_to_60_smp) ) ; 
		end
	// trig on / off 
	// note  r_port_to_60  <= (r_port_to_60, i_port_to_60, r_port_to_60_smp)
	//       0                 0             0             0
	//       0                 0             0             1
	//       1                 0             1             0
	//       1                 0             1             1 <<<
	//       1                 1             0             0
	//       0                 1             0             1
	//       1                 1             1             0
	//       0                 1             1             1
	//       r_port_to_60  <= ( (~r_port_to_60)&i_port_to_60 ) | ( r_port_to_60&(~r_port_to_60_smp) ) ;

//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_to_60_smp  <= 32'b0;
	end
	else begin 
		// trig off 
		// note  r_port_to_60_smp  <= (r_port_to_60_smp, r_mask_to)
		//       0                     0                 0
		//       0                     0                 1
		//       1                     1                 0
		//       0                     1                 1
		//       r_port_to_60_smp  <= r_port_to_60_smp & (~r_mask_to) ;
		// trig on
		//   r_port_to_60_smp  <= r_port_to_60_smp | r_port_to_60;
		//
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_60)) begin 
			r_port_to_60_smp  <= r_port_to_60_smp & (~r_mask_to) ; 
			end  
		else begin 
			r_port_to_60_smp  <= r_port_to_60_smp | r_port_to_60; 
			end
	end

// o_to_reg
assign o_to_reg = r_port_to_60_smp & r_mask_to;

//}
endmodule
//}


//// main module
module mcs_io_bridge_ext (  
	// 
	input wire clk, // assume 72MHz
	input wire reset_n,
	
	//// IO bus control from master //{
	input  wire          i_IO_addr_strobe  ,
	input  wire [31 : 0] i_IO_address      ,
	input  wire [3 : 0]  i_IO_byte_enable  ,
	output wire [31 : 0] o_IO_read_data    ,
	input  wire          i_IO_read_strobe  ,
	output wire          o_IO_ready        , // IO ready with    address check
	output wire          o_IO_ready_ref    , // IO ready without address check
	input  wire [31 : 0] i_IO_write_data   ,
	input  wire          i_IO_write_strobe ,
	//}
	
	//// IO port
	
	// wire in //{
	output wire [31:0]   o_port_wi_00 ,
	output wire [31:0]   o_port_wi_01 ,
	output wire [31:0]   o_port_wi_02 ,
	output wire [31:0]   o_port_wi_03 ,
	output wire [31:0]   o_port_wi_04 ,
	output wire [31:0]   o_port_wi_05 ,
	output wire [31:0]   o_port_wi_06 ,
	output wire [31:0]   o_port_wi_07 ,
	output wire [31:0]   o_port_wi_08 ,
	output wire [31:0]   o_port_wi_09 ,
	output wire [31:0]   o_port_wi_0A ,
	output wire [31:0]   o_port_wi_0B ,
	output wire [31:0]   o_port_wi_0C ,
	output wire [31:0]   o_port_wi_0D ,
	output wire [31:0]   o_port_wi_0E ,
	output wire [31:0]   o_port_wi_0F ,
	//
	output wire [31:0]   o_port_wi_10 ,
	output wire [31:0]   o_port_wi_11 ,
	output wire [31:0]   o_port_wi_12 ,
	output wire [31:0]   o_port_wi_13 ,
	output wire [31:0]   o_port_wi_14 ,
	output wire [31:0]   o_port_wi_15 ,
	output wire [31:0]   o_port_wi_16 ,
	output wire [31:0]   o_port_wi_17 ,
	output wire [31:0]   o_port_wi_18 ,
	output wire [31:0]   o_port_wi_19 ,
	output wire [31:0]   o_port_wi_1A ,
	output wire [31:0]   o_port_wi_1B ,
	output wire [31:0]   o_port_wi_1C ,
	output wire [31:0]   o_port_wi_1D ,
	output wire [31:0]   o_port_wi_1E ,
	output wire [31:0]   o_port_wi_1F ,
	//}
	
	// wire out //{
	input  wire [31:0]   i_port_wo_20 ,
	input  wire [31:0]   i_port_wo_21 ,
	input  wire [31:0]   i_port_wo_22 ,
	input  wire [31:0]   i_port_wo_23 ,
	input  wire [31:0]   i_port_wo_24 ,
	input  wire [31:0]   i_port_wo_25 ,
	input  wire [31:0]   i_port_wo_26 ,
	input  wire [31:0]   i_port_wo_27 ,
	input  wire [31:0]   i_port_wo_28 ,
	input  wire [31:0]   i_port_wo_29 ,
	input  wire [31:0]   i_port_wo_2A ,
	input  wire [31:0]   i_port_wo_2B ,
	input  wire [31:0]   i_port_wo_2C ,
	input  wire [31:0]   i_port_wo_2D ,
	input  wire [31:0]   i_port_wo_2E ,
	input  wire [31:0]   i_port_wo_2F ,
	//
	input  wire [31:0]   i_port_wo_30 ,
	input  wire [31:0]   i_port_wo_31 ,
	input  wire [31:0]   i_port_wo_32 ,
	input  wire [31:0]   i_port_wo_33 ,
	input  wire [31:0]   i_port_wo_34 ,
	input  wire [31:0]   i_port_wo_35 ,
	input  wire [31:0]   i_port_wo_36 ,
	input  wire [31:0]   i_port_wo_37 ,
	input  wire [31:0]   i_port_wo_38 ,
	input  wire [31:0]   i_port_wo_39 ,
	input  wire [31:0]   i_port_wo_3A ,
	input  wire [31:0]   i_port_wo_3B ,
	input  wire [31:0]   i_port_wo_3C ,
	input  wire [31:0]   i_port_wo_3D ,
	input  wire [31:0]   i_port_wo_3E ,
	input  wire [31:0]   i_port_wo_3F ,
	//}
	
	// trig in //{
	input  wire i_port_ck_40, output wire [31:0]   o_port_ti_40 ,
	input  wire i_port_ck_41, output wire [31:0]   o_port_ti_41 ,
	input  wire i_port_ck_42, output wire [31:0]   o_port_ti_42 ,
	input  wire i_port_ck_43, output wire [31:0]   o_port_ti_43 ,
	input  wire i_port_ck_44, output wire [31:0]   o_port_ti_44 ,
	input  wire i_port_ck_45, output wire [31:0]   o_port_ti_45 ,
	input  wire i_port_ck_46, output wire [31:0]   o_port_ti_46 ,
	input  wire i_port_ck_47, output wire [31:0]   o_port_ti_47 ,
	input  wire i_port_ck_48, output wire [31:0]   o_port_ti_48 ,
	input  wire i_port_ck_49, output wire [31:0]   o_port_ti_49 ,
	input  wire i_port_ck_4A, output wire [31:0]   o_port_ti_4A ,
	input  wire i_port_ck_4B, output wire [31:0]   o_port_ti_4B ,
	input  wire i_port_ck_4C, output wire [31:0]   o_port_ti_4C ,
	input  wire i_port_ck_4D, output wire [31:0]   o_port_ti_4D ,
	input  wire i_port_ck_4E, output wire [31:0]   o_port_ti_4E ,
	input  wire i_port_ck_4F, output wire [31:0]   o_port_ti_4F ,
	//
	input  wire i_port_ck_50, output wire [31:0]   o_port_ti_50 ,
	input  wire i_port_ck_51, output wire [31:0]   o_port_ti_51 ,
	input  wire i_port_ck_52, output wire [31:0]   o_port_ti_52 ,
	input  wire i_port_ck_53, output wire [31:0]   o_port_ti_53 ,
	input  wire i_port_ck_54, output wire [31:0]   o_port_ti_54 ,
	input  wire i_port_ck_55, output wire [31:0]   o_port_ti_55 ,
	input  wire i_port_ck_56, output wire [31:0]   o_port_ti_56 ,
	input  wire i_port_ck_57, output wire [31:0]   o_port_ti_57 ,
	input  wire i_port_ck_58, output wire [31:0]   o_port_ti_58 ,
	input  wire i_port_ck_59, output wire [31:0]   o_port_ti_59 ,
	input  wire i_port_ck_5A, output wire [31:0]   o_port_ti_5A ,
	input  wire i_port_ck_5B, output wire [31:0]   o_port_ti_5B ,
	input  wire i_port_ck_5C, output wire [31:0]   o_port_ti_5C ,
	input  wire i_port_ck_5D, output wire [31:0]   o_port_ti_5D ,
	input  wire i_port_ck_5E, output wire [31:0]   o_port_ti_5E ,
	input  wire i_port_ck_5F, output wire [31:0]   o_port_ti_5F ,
	//}
	
	// trig out //{
	input  wire i_port_ck_60, input  wire [31:0]   i_port_to_60 ,
	input  wire i_port_ck_61, input  wire [31:0]   i_port_to_61 ,
	input  wire i_port_ck_62, input  wire [31:0]   i_port_to_62 ,
	input  wire i_port_ck_63, input  wire [31:0]   i_port_to_63 ,
	input  wire i_port_ck_64, input  wire [31:0]   i_port_to_64 ,
	input  wire i_port_ck_65, input  wire [31:0]   i_port_to_65 ,
	input  wire i_port_ck_66, input  wire [31:0]   i_port_to_66 ,
	input  wire i_port_ck_67, input  wire [31:0]   i_port_to_67 ,
	input  wire i_port_ck_68, input  wire [31:0]   i_port_to_68 ,
	input  wire i_port_ck_69, input  wire [31:0]   i_port_to_69 ,
	input  wire i_port_ck_6A, input  wire [31:0]   i_port_to_6A ,
	input  wire i_port_ck_6B, input  wire [31:0]   i_port_to_6B ,
	input  wire i_port_ck_6C, input  wire [31:0]   i_port_to_6C ,
	input  wire i_port_ck_6D, input  wire [31:0]   i_port_to_6D ,
	input  wire i_port_ck_6E, input  wire [31:0]   i_port_to_6E ,
	input  wire i_port_ck_6F, input  wire [31:0]   i_port_to_6F ,
	//
	input  wire i_port_ck_70, input  wire [31:0]   i_port_to_70 ,
	input  wire i_port_ck_71, input  wire [31:0]   i_port_to_71 ,
	input  wire i_port_ck_72, input  wire [31:0]   i_port_to_72 ,
	input  wire i_port_ck_73, input  wire [31:0]   i_port_to_73 ,
	input  wire i_port_ck_74, input  wire [31:0]   i_port_to_74 ,
	input  wire i_port_ck_75, input  wire [31:0]   i_port_to_75 ,
	input  wire i_port_ck_76, input  wire [31:0]   i_port_to_76 ,
	input  wire i_port_ck_77, input  wire [31:0]   i_port_to_77 ,
	input  wire i_port_ck_78, input  wire [31:0]   i_port_to_78 ,
	input  wire i_port_ck_79, input  wire [31:0]   i_port_to_79 ,
	input  wire i_port_ck_7A, input  wire [31:0]   i_port_to_7A ,
	input  wire i_port_ck_7B, input  wire [31:0]   i_port_to_7B ,
	input  wire i_port_ck_7C, input  wire [31:0]   i_port_to_7C ,
	input  wire i_port_ck_7D, input  wire [31:0]   i_port_to_7D ,
	input  wire i_port_ck_7E, input  wire [31:0]   i_port_to_7E ,
	input  wire i_port_ck_7F, input  wire [31:0]   i_port_to_7F ,
	//}
	
	// pipe in //{
	output wire o_port_wr_80, output wire [31:0]   o_port_pi_80 ,
	output wire o_port_wr_81, output wire [31:0]   o_port_pi_81 ,
	output wire o_port_wr_82, output wire [31:0]   o_port_pi_82 ,
	output wire o_port_wr_83, output wire [31:0]   o_port_pi_83 ,
	output wire o_port_wr_84, output wire [31:0]   o_port_pi_84 ,
	output wire o_port_wr_85, output wire [31:0]   o_port_pi_85 ,
	output wire o_port_wr_86, output wire [31:0]   o_port_pi_86 ,
	output wire o_port_wr_87, output wire [31:0]   o_port_pi_87 ,
	output wire o_port_wr_88, output wire [31:0]   o_port_pi_88 ,
	output wire o_port_wr_89, output wire [31:0]   o_port_pi_89 ,
	output wire o_port_wr_8A, output wire [31:0]   o_port_pi_8A ,
	output wire o_port_wr_8B, output wire [31:0]   o_port_pi_8B ,
	output wire o_port_wr_8C, output wire [31:0]   o_port_pi_8C ,
	output wire o_port_wr_8D, output wire [31:0]   o_port_pi_8D ,
	output wire o_port_wr_8E, output wire [31:0]   o_port_pi_8E ,
	output wire o_port_wr_8F, output wire [31:0]   o_port_pi_8F ,
	//
	output wire o_port_wr_90, output wire [31:0]   o_port_pi_90 ,
	output wire o_port_wr_91, output wire [31:0]   o_port_pi_91 ,
	output wire o_port_wr_92, output wire [31:0]   o_port_pi_92 ,
	output wire o_port_wr_93, output wire [31:0]   o_port_pi_93 ,
	output wire o_port_wr_94, output wire [31:0]   o_port_pi_94 ,
	output wire o_port_wr_95, output wire [31:0]   o_port_pi_95 ,
	output wire o_port_wr_96, output wire [31:0]   o_port_pi_96 ,
	output wire o_port_wr_97, output wire [31:0]   o_port_pi_97 ,
	output wire o_port_wr_98, output wire [31:0]   o_port_pi_98 ,
	output wire o_port_wr_99, output wire [31:0]   o_port_pi_99 ,
	output wire o_port_wr_9A, output wire [31:0]   o_port_pi_9A ,
	output wire o_port_wr_9B, output wire [31:0]   o_port_pi_9B ,
	output wire o_port_wr_9C, output wire [31:0]   o_port_pi_9C ,
	output wire o_port_wr_9D, output wire [31:0]   o_port_pi_9D ,
	output wire o_port_wr_9E, output wire [31:0]   o_port_pi_9E ,
	output wire o_port_wr_9F, output wire [31:0]   o_port_pi_9F ,
	//}
	
	// pipe out //{
	output wire o_port_rd_A0, input  wire [31:0]   i_port_po_A0 ,
	output wire o_port_rd_A1, input  wire [31:0]   i_port_po_A1 ,
	output wire o_port_rd_A2, input  wire [31:0]   i_port_po_A2 ,
	output wire o_port_rd_A3, input  wire [31:0]   i_port_po_A3 ,
	output wire o_port_rd_A4, input  wire [31:0]   i_port_po_A4 ,
	output wire o_port_rd_A5, input  wire [31:0]   i_port_po_A5 ,
	output wire o_port_rd_A6, input  wire [31:0]   i_port_po_A6 ,
	output wire o_port_rd_A7, input  wire [31:0]   i_port_po_A7 ,
	output wire o_port_rd_A8, input  wire [31:0]   i_port_po_A8 ,
	output wire o_port_rd_A9, input  wire [31:0]   i_port_po_A9 ,
	output wire o_port_rd_AA, input  wire [31:0]   i_port_po_AA ,
	output wire o_port_rd_AB, input  wire [31:0]   i_port_po_AB ,
	output wire o_port_rd_AC, input  wire [31:0]   i_port_po_AC ,
	output wire o_port_rd_AD, input  wire [31:0]   i_port_po_AD ,
	output wire o_port_rd_AE, input  wire [31:0]   i_port_po_AE ,
	output wire o_port_rd_AF, input  wire [31:0]   i_port_po_AF ,
	//
	output wire o_port_rd_B0, input  wire [31:0]   i_port_po_B0 ,
	output wire o_port_rd_B1, input  wire [31:0]   i_port_po_B1 ,
	output wire o_port_rd_B2, input  wire [31:0]   i_port_po_B2 ,
	output wire o_port_rd_B3, input  wire [31:0]   i_port_po_B3 ,
	output wire o_port_rd_B4, input  wire [31:0]   i_port_po_B4 ,
	output wire o_port_rd_B5, input  wire [31:0]   i_port_po_B5 ,
	output wire o_port_rd_B6, input  wire [31:0]   i_port_po_B6 ,
	output wire o_port_rd_B7, input  wire [31:0]   i_port_po_B7 ,
	output wire o_port_rd_B8, input  wire [31:0]   i_port_po_B8 ,
	output wire o_port_rd_B9, input  wire [31:0]   i_port_po_B9 ,
	output wire o_port_rd_BA, input  wire [31:0]   i_port_po_BA ,
	output wire o_port_rd_BB, input  wire [31:0]   i_port_po_BB ,
	output wire o_port_rd_BC, input  wire [31:0]   i_port_po_BC ,
	output wire o_port_rd_BD, input  wire [31:0]   i_port_po_BD ,
	output wire o_port_rd_BE, input  wire [31:0]   i_port_po_BE ,
	output wire o_port_rd_BF, input  wire [31:0]   i_port_po_BF ,
	//}
	
	//// LAN dedicated port //{
	input  wire [31:0]   i_lan_conf_00 , // (BASE_ADRS_IP_32B  + i_adrs_offset_ip_32b ),   // input  wire [31:0]  
	input  wire [31:0]   i_lan_conf_01 , // (BASE_ADRS_MAC_48B[31: 0] + i_adrs_offset_mac_48b[31: 0] ),   // input  wire [31:0]  
	input  wire [31:0]   i_lan_conf_02 , // ( {16b0,BASE_ADRS_MAC_48B[47:32]} + {16b0,i_adrs_offset_mac_48b[47:32]} ),   // input  wire [31:0]  
	input  wire [31:0]   i_lan_conf_03 , // ( i_lan_timeout_rtr_16b , i_lan_timeout_rcr_16b ),   // input  wire [31:0]  
	//
	output wire [31:0]   o_lan_wi_00 ,
	output wire [31:0]   o_lan_wi_01 ,
	input  wire [31:0]   i_lan_wo_20 ,
	input  wire [31:0]   i_lan_wo_21 ,
	input  wire i_lan_ck_40, output wire [31:0]   o_lan_ti_40 ,
	input  wire i_lan_ck_41, output wire [31:0]   o_lan_ti_41 ,
	input  wire i_lan_ck_60, input  wire [31:0]   i_lan_to_60 ,
	input  wire i_lan_ck_61, input  wire [31:0]   i_lan_to_61 ,
	output wire o_lan_wr_80, output wire [31:0]   o_lan_pi_80 ,
	output wire o_lan_wr_81, output wire [31:0]   o_lan_pi_81 ,
	output wire o_lan_rd_A0, input  wire [31:0]   i_lan_po_A0 ,
	output wire o_lan_rd_A1, input  wire [31:0]   i_lan_po_A1 ,
	//}
	
	//// flag
	output wire valid
);

//// parameters //{

// parameters from outside
parameter XPAR_IOMODULE_IO_BASEADDR   = 32'h_C000_0000; 
parameter MCS_IO_INST_OFFSET          = 32'h_0003_0000; // 32'h_0001_0000
parameter FPGA_IMAGE_ID               = 32'h_BABA_B0B0;  

// inner parameters
parameter INIT_IO_data = 32'h_ACAC_CDCD;

//// parameters for register offsets
parameter ADRS_BASE              = XPAR_IOMODULE_IO_BASEADDR + MCS_IO_INST_OFFSET; 
//parameter ADRS_END               = XPAR_IOMODULE_IO_BASEADDR + 32'h_3FFF_FFFF; 

//$$ MCS PORT Endpoints
// Wire In      0x0000 - 0x01F0  // output wire [31:0]
// Wire Out     0x0200 - 0x03F0  // input wire [31:0]
// Trigger In   0x0400 - 0x05F0  // input wire, output wire [31:0],
// Trigger Out  0x0600 - 0x07F0  // input wire, input wire [31:0],
// Pipe In      0x0800 - 0x09F0  // output wire, output wire [31:0],
// Pipe Out     0x0A00 - 0x0BF0  // output wire, input wire [31:0],


// PORT wire in //{
parameter ADRS_PORT_WI_00        = ADRS_BASE + 32'h_0000_0000; // output wire [31:0]
parameter ADRS_PORT_WI_01        = ADRS_BASE + 32'h_0000_0010; // output wire [31:0]
parameter ADRS_PORT_WI_02        = ADRS_BASE + 32'h_0000_0020; // output wire [31:0]
parameter ADRS_PORT_WI_03        = ADRS_BASE + 32'h_0000_0030; // output wire [31:0]
parameter ADRS_PORT_WI_04        = ADRS_BASE + 32'h_0000_0040; // output wire [31:0]
parameter ADRS_PORT_WI_05        = ADRS_BASE + 32'h_0000_0050; // output wire [31:0]
parameter ADRS_PORT_WI_06        = ADRS_BASE + 32'h_0000_0060; // output wire [31:0]
parameter ADRS_PORT_WI_07        = ADRS_BASE + 32'h_0000_0070; // output wire [31:0]
parameter ADRS_PORT_WI_08        = ADRS_BASE + 32'h_0000_0080; // output wire [31:0]
parameter ADRS_PORT_WI_09        = ADRS_BASE + 32'h_0000_0090; // output wire [31:0]
parameter ADRS_PORT_WI_0A        = ADRS_BASE + 32'h_0000_00A0; // output wire [31:0]
parameter ADRS_PORT_WI_0B        = ADRS_BASE + 32'h_0000_00B0; // output wire [31:0]
parameter ADRS_PORT_WI_0C        = ADRS_BASE + 32'h_0000_00C0; // output wire [31:0]
parameter ADRS_PORT_WI_0D        = ADRS_BASE + 32'h_0000_00D0; // output wire [31:0]
parameter ADRS_PORT_WI_0E        = ADRS_BASE + 32'h_0000_00E0; // output wire [31:0]
parameter ADRS_PORT_WI_0F        = ADRS_BASE + 32'h_0000_00F0; // output wire [31:0]
//
parameter ADRS_PORT_WI_10        = ADRS_BASE + 32'h_0000_0100; // output wire [31:0]
parameter ADRS_PORT_WI_11        = ADRS_BASE + 32'h_0000_0110; // output wire [31:0]
parameter ADRS_PORT_WI_12        = ADRS_BASE + 32'h_0000_0120; // output wire [31:0]
parameter ADRS_PORT_WI_13        = ADRS_BASE + 32'h_0000_0130; // output wire [31:0]
parameter ADRS_PORT_WI_14        = ADRS_BASE + 32'h_0000_0140; // output wire [31:0]
parameter ADRS_PORT_WI_15        = ADRS_BASE + 32'h_0000_0150; // output wire [31:0]
parameter ADRS_PORT_WI_16        = ADRS_BASE + 32'h_0000_0160; // output wire [31:0]
parameter ADRS_PORT_WI_17        = ADRS_BASE + 32'h_0000_0170; // output wire [31:0]
parameter ADRS_PORT_WI_18        = ADRS_BASE + 32'h_0000_0180; // output wire [31:0]
parameter ADRS_PORT_WI_19        = ADRS_BASE + 32'h_0000_0190; // output wire [31:0]
parameter ADRS_PORT_WI_1A        = ADRS_BASE + 32'h_0000_01A0; // output wire [31:0]
parameter ADRS_PORT_WI_1B        = ADRS_BASE + 32'h_0000_01B0; // output wire [31:0]
parameter ADRS_PORT_WI_1C        = ADRS_BASE + 32'h_0000_01C0; // output wire [31:0]
parameter ADRS_PORT_WI_1D        = ADRS_BASE + 32'h_0000_01D0; // output wire [31:0]
parameter ADRS_PORT_WI_1E        = ADRS_BASE + 32'h_0000_01E0; // output wire [31:0]
parameter ADRS_PORT_WI_1F        = ADRS_BASE + 32'h_0000_01F0; // output wire [31:0]
//}

// PORT wire out //{
parameter ADRS_PORT_WO_20        = ADRS_BASE + 32'h_0000_0200; // input wire [31:0]
parameter ADRS_PORT_WO_21        = ADRS_BASE + 32'h_0000_0210; // input wire [31:0]
parameter ADRS_PORT_WO_22        = ADRS_BASE + 32'h_0000_0220; // input wire [31:0]
parameter ADRS_PORT_WO_23        = ADRS_BASE + 32'h_0000_0230; // input wire [31:0]
parameter ADRS_PORT_WO_24        = ADRS_BASE + 32'h_0000_0240; // input wire [31:0]
parameter ADRS_PORT_WO_25        = ADRS_BASE + 32'h_0000_0250; // input wire [31:0]
parameter ADRS_PORT_WO_26        = ADRS_BASE + 32'h_0000_0260; // input wire [31:0]
parameter ADRS_PORT_WO_27        = ADRS_BASE + 32'h_0000_0270; // input wire [31:0]
parameter ADRS_PORT_WO_28        = ADRS_BASE + 32'h_0000_0280; // input wire [31:0]
parameter ADRS_PORT_WO_29        = ADRS_BASE + 32'h_0000_0290; // input wire [31:0]
parameter ADRS_PORT_WO_2A        = ADRS_BASE + 32'h_0000_02A0; // input wire [31:0]
parameter ADRS_PORT_WO_2B        = ADRS_BASE + 32'h_0000_02B0; // input wire [31:0]
parameter ADRS_PORT_WO_2C        = ADRS_BASE + 32'h_0000_02C0; // input wire [31:0]
parameter ADRS_PORT_WO_2D        = ADRS_BASE + 32'h_0000_02D0; // input wire [31:0]
parameter ADRS_PORT_WO_2E        = ADRS_BASE + 32'h_0000_02E0; // input wire [31:0]
parameter ADRS_PORT_WO_2F        = ADRS_BASE + 32'h_0000_02F0; // input wire [31:0]
//
parameter ADRS_PORT_WO_30        = ADRS_BASE + 32'h_0000_0300; // input wire [31:0]
parameter ADRS_PORT_WO_31        = ADRS_BASE + 32'h_0000_0310; // input wire [31:0]
parameter ADRS_PORT_WO_32        = ADRS_BASE + 32'h_0000_0320; // input wire [31:0]
parameter ADRS_PORT_WO_33        = ADRS_BASE + 32'h_0000_0330; // input wire [31:0]
parameter ADRS_PORT_WO_34        = ADRS_BASE + 32'h_0000_0340; // input wire [31:0]
parameter ADRS_PORT_WO_35        = ADRS_BASE + 32'h_0000_0350; // input wire [31:0]
parameter ADRS_PORT_WO_36        = ADRS_BASE + 32'h_0000_0360; // input wire [31:0]
parameter ADRS_PORT_WO_37        = ADRS_BASE + 32'h_0000_0370; // input wire [31:0]
parameter ADRS_PORT_WO_38        = ADRS_BASE + 32'h_0000_0380; // input wire [31:0]
parameter ADRS_PORT_WO_39        = ADRS_BASE + 32'h_0000_0390; // input wire [31:0]
parameter ADRS_PORT_WO_3A        = ADRS_BASE + 32'h_0000_03A0; // input wire [31:0]
parameter ADRS_PORT_WO_3B        = ADRS_BASE + 32'h_0000_03B0; // input wire [31:0]
parameter ADRS_PORT_WO_3C        = ADRS_BASE + 32'h_0000_03C0; // input wire [31:0]
parameter ADRS_PORT_WO_3D        = ADRS_BASE + 32'h_0000_03D0; // input wire [31:0]
parameter ADRS_PORT_WO_3E        = ADRS_BASE + 32'h_0000_03E0; // input wire [31:0]
parameter ADRS_PORT_WO_3F        = ADRS_BASE + 32'h_0000_03F0; // input wire [31:0]
//}

// PORT trig in //{
parameter ADRS_PORT_TI_40        = ADRS_BASE + 32'h_0000_0400; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_41        = ADRS_BASE + 32'h_0000_0410; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_42        = ADRS_BASE + 32'h_0000_0420; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_43        = ADRS_BASE + 32'h_0000_0430; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_44        = ADRS_BASE + 32'h_0000_0440; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_45        = ADRS_BASE + 32'h_0000_0450; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_46        = ADRS_BASE + 32'h_0000_0460; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_47        = ADRS_BASE + 32'h_0000_0470; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_48        = ADRS_BASE + 32'h_0000_0480; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_49        = ADRS_BASE + 32'h_0000_0490; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4A        = ADRS_BASE + 32'h_0000_04A0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4B        = ADRS_BASE + 32'h_0000_04B0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4C        = ADRS_BASE + 32'h_0000_04C0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4D        = ADRS_BASE + 32'h_0000_04D0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4E        = ADRS_BASE + 32'h_0000_04E0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_4F        = ADRS_BASE + 32'h_0000_04F0; // input wire, output wire [31:0],
//
parameter ADRS_PORT_TI_50        = ADRS_BASE + 32'h_0000_0500; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_51        = ADRS_BASE + 32'h_0000_0510; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_52        = ADRS_BASE + 32'h_0000_0520; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_53        = ADRS_BASE + 32'h_0000_0530; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_54        = ADRS_BASE + 32'h_0000_0540; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_55        = ADRS_BASE + 32'h_0000_0550; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_56        = ADRS_BASE + 32'h_0000_0560; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_57        = ADRS_BASE + 32'h_0000_0570; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_58        = ADRS_BASE + 32'h_0000_0580; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_59        = ADRS_BASE + 32'h_0000_0590; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5A        = ADRS_BASE + 32'h_0000_05A0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5B        = ADRS_BASE + 32'h_0000_05B0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5C        = ADRS_BASE + 32'h_0000_05C0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5D        = ADRS_BASE + 32'h_0000_05D0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5E        = ADRS_BASE + 32'h_0000_05E0; // input wire, output wire [31:0],
parameter ADRS_PORT_TI_5F        = ADRS_BASE + 32'h_0000_05F0; // input wire, output wire [31:0],
//}

// PORT trig out //{
parameter ADRS_PORT_TO_60        = ADRS_BASE + 32'h_0000_0600; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_61        = ADRS_BASE + 32'h_0000_0610; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_62        = ADRS_BASE + 32'h_0000_0620; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_63        = ADRS_BASE + 32'h_0000_0630; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_64        = ADRS_BASE + 32'h_0000_0640; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_65        = ADRS_BASE + 32'h_0000_0650; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_66        = ADRS_BASE + 32'h_0000_0660; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_67        = ADRS_BASE + 32'h_0000_0670; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_68        = ADRS_BASE + 32'h_0000_0680; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_69        = ADRS_BASE + 32'h_0000_0690; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6A        = ADRS_BASE + 32'h_0000_06A0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6B        = ADRS_BASE + 32'h_0000_06B0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6C        = ADRS_BASE + 32'h_0000_06C0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6D        = ADRS_BASE + 32'h_0000_06D0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6E        = ADRS_BASE + 32'h_0000_06E0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_6F        = ADRS_BASE + 32'h_0000_06F0; // input wire, input wire [31:0],
//
parameter ADRS_PORT_TO_70        = ADRS_BASE + 32'h_0000_0700; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_71        = ADRS_BASE + 32'h_0000_0710; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_72        = ADRS_BASE + 32'h_0000_0720; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_73        = ADRS_BASE + 32'h_0000_0730; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_74        = ADRS_BASE + 32'h_0000_0740; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_75        = ADRS_BASE + 32'h_0000_0750; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_76        = ADRS_BASE + 32'h_0000_0760; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_77        = ADRS_BASE + 32'h_0000_0770; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_78        = ADRS_BASE + 32'h_0000_0780; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_79        = ADRS_BASE + 32'h_0000_0790; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7A        = ADRS_BASE + 32'h_0000_07A0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7B        = ADRS_BASE + 32'h_0000_07B0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7C        = ADRS_BASE + 32'h_0000_07C0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7D        = ADRS_BASE + 32'h_0000_07D0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7E        = ADRS_BASE + 32'h_0000_07E0; // input wire, input wire [31:0],
parameter ADRS_PORT_TO_7F        = ADRS_BASE + 32'h_0000_07F0; // input wire, input wire [31:0],
//}

// PORT pipe in //{
parameter ADRS_PORT_PI_80        = ADRS_BASE + 32'h_0000_0800; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_81        = ADRS_BASE + 32'h_0000_0810; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_82        = ADRS_BASE + 32'h_0000_0820; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_83        = ADRS_BASE + 32'h_0000_0830; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_84        = ADRS_BASE + 32'h_0000_0840; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_85        = ADRS_BASE + 32'h_0000_0850; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_86        = ADRS_BASE + 32'h_0000_0860; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_87        = ADRS_BASE + 32'h_0000_0870; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_88        = ADRS_BASE + 32'h_0000_0880; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_89        = ADRS_BASE + 32'h_0000_0890; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8A        = ADRS_BASE + 32'h_0000_08A0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8B        = ADRS_BASE + 32'h_0000_08B0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8C        = ADRS_BASE + 32'h_0000_08C0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8D        = ADRS_BASE + 32'h_0000_08D0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8E        = ADRS_BASE + 32'h_0000_08E0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_8F        = ADRS_BASE + 32'h_0000_08F0; // output wire, output wire [31:0],
//
parameter ADRS_PORT_PI_90        = ADRS_BASE + 32'h_0000_0900; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_91        = ADRS_BASE + 32'h_0000_0910; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_92        = ADRS_BASE + 32'h_0000_0920; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_93        = ADRS_BASE + 32'h_0000_0930; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_94        = ADRS_BASE + 32'h_0000_0940; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_95        = ADRS_BASE + 32'h_0000_0950; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_96        = ADRS_BASE + 32'h_0000_0960; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_97        = ADRS_BASE + 32'h_0000_0970; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_98        = ADRS_BASE + 32'h_0000_0980; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_99        = ADRS_BASE + 32'h_0000_0990; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9A        = ADRS_BASE + 32'h_0000_09A0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9B        = ADRS_BASE + 32'h_0000_09B0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9C        = ADRS_BASE + 32'h_0000_09C0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9D        = ADRS_BASE + 32'h_0000_09D0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9E        = ADRS_BASE + 32'h_0000_09E0; // output wire, output wire [31:0],
parameter ADRS_PORT_PI_9F        = ADRS_BASE + 32'h_0000_09F0; // output wire, output wire [31:0],
//}

// PORT pipe out //{
parameter ADRS_PORT_PO_A0        = ADRS_BASE + 32'h_0000_0A00; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A1        = ADRS_BASE + 32'h_0000_0A10; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A2        = ADRS_BASE + 32'h_0000_0A20; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A3        = ADRS_BASE + 32'h_0000_0A30; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A4        = ADRS_BASE + 32'h_0000_0A40; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A5        = ADRS_BASE + 32'h_0000_0A50; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A6        = ADRS_BASE + 32'h_0000_0A60; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A7        = ADRS_BASE + 32'h_0000_0A70; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A8        = ADRS_BASE + 32'h_0000_0A80; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_A9        = ADRS_BASE + 32'h_0000_0A90; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AA        = ADRS_BASE + 32'h_0000_0AA0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AB        = ADRS_BASE + 32'h_0000_0AB0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AC        = ADRS_BASE + 32'h_0000_0AC0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AD        = ADRS_BASE + 32'h_0000_0AD0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AE        = ADRS_BASE + 32'h_0000_0AE0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_AF        = ADRS_BASE + 32'h_0000_0AF0; // output wire, input wire [31:0],
//
parameter ADRS_PORT_PO_B0        = ADRS_BASE + 32'h_0000_0B00; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B1        = ADRS_BASE + 32'h_0000_0B10; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B2        = ADRS_BASE + 32'h_0000_0B20; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B3        = ADRS_BASE + 32'h_0000_0B30; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B4        = ADRS_BASE + 32'h_0000_0B40; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B5        = ADRS_BASE + 32'h_0000_0B50; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B6        = ADRS_BASE + 32'h_0000_0B60; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B7        = ADRS_BASE + 32'h_0000_0B70; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B8        = ADRS_BASE + 32'h_0000_0B80; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_B9        = ADRS_BASE + 32'h_0000_0B90; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BA        = ADRS_BASE + 32'h_0000_0BA0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BB        = ADRS_BASE + 32'h_0000_0BB0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BC        = ADRS_BASE + 32'h_0000_0BC0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BD        = ADRS_BASE + 32'h_0000_0BD0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BE        = ADRS_BASE + 32'h_0000_0BE0; // output wire, input wire [31:0],
parameter ADRS_PORT_PO_BF        = ADRS_BASE + 32'h_0000_0BF0; // output wire, input wire [31:0],
//}

// Dedicated LAN control //{
// 'b_0000_XXHH_hhxx_xx00
//
//         1100 (C)
//         1101 (D)
//         1110 (E)
//         
// 'b_0000_1100_00xx_xx00 -- LAN_WI_00
// 'b_0000_1100_01xx_xx00 -- LAN_WI_10
// 'b_0000_1100_10xx_xx00 -- LAN_WO_20
// 'b_0000_1100_11xx_xx00 -- LAN_WO_30
// 'b_0000_1101_00xx_xx00 -- LAN_TI_40
// 'b_0000_1101_01xx_xx00 -- LAN_TI_50
// 'b_0000_1101_10xx_xx00 -- LAN_TO_60
// 'b_0000_1101_11xx_xx00 -- LAN_TO_70
// 'b_0000_1110_00xx_xx00 -- LAN_PI_80
// 'b_0000_1110_01xx_xx00 -- LAN_PI_90
// 'b_0000_1110_10xx_xx00 -- LAN_PO_A0
// 'b_0000_1110_11xx_xx00 -- LAN_PO_B0
//
parameter ADRS_LAN_WI_00         = ADRS_BASE + 32'h_0000_0C00; // output wire [31:0]
parameter ADRS_LAN_WI_01         = ADRS_BASE + 32'h_0000_0C04; // output wire [31:0]
parameter ADRS_LAN_WO_20         = ADRS_BASE + 32'h_0000_0C80; // input wire [31:0]
parameter ADRS_LAN_WO_21         = ADRS_BASE + 32'h_0000_0C84; // input wire [31:0]
parameter ADRS_LAN_TI_40         = ADRS_BASE + 32'h_0000_0D00; // input wire, output wire [31:0],
parameter ADRS_LAN_TI_41         = ADRS_BASE + 32'h_0000_0D04; // input wire, output wire [31:0],
parameter ADRS_LAN_TO_60         = ADRS_BASE + 32'h_0000_0D80; // input wire, input wire [31:0],
parameter ADRS_LAN_TO_61         = ADRS_BASE + 32'h_0000_0D84; // input wire, input wire [31:0],
parameter ADRS_LAN_PI_80         = ADRS_BASE + 32'h_0000_0E00; // output wire, output wire [31:0],
parameter ADRS_LAN_PI_81         = ADRS_BASE + 32'h_0000_0E04; // output wire, output wire [31:0],
parameter ADRS_LAN_PO_A0         = ADRS_BASE + 32'h_0000_0E80; // output wire, input wire [31:0],
parameter ADRS_LAN_PO_A1         = ADRS_BASE + 32'h_0000_0E84; // output wire, input wire [31:0],
//
parameter ADRS_LAN_CONF_00       = ADRS_BASE + 32'h_0000_0FC0; //input  wire [31:0]   i_lan_conf_00
parameter ADRS_LAN_CONF_01       = ADRS_BASE + 32'h_0000_0FC4; //input  wire [31:0]   i_lan_conf_01
parameter ADRS_LAN_CONF_02       = ADRS_BASE + 32'h_0000_0FC8; //input  wire [31:0]   i_lan_conf_02
parameter ADRS_LAN_CONF_03       = ADRS_BASE + 32'h_0000_0FCC; //input  wire [31:0]   i_lan_conf_03

//}

// end-point control //{
parameter ADRS_FPGA_IMAGE_ID     = ADRS_BASE + 32'h_0000_0F00;
parameter ADRS_TEST_REG          = ADRS_BASE + 32'h_0000_0F04;
//
parameter ADRS_MASK_ALL          = ADRS_BASE + 32'h_0000_0F08; // mask all 
parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10; // mask for port IO
parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14; // mask for port IO
parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18; // mask for port IO
parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C; // mask for port IO
//}

//}

// valid //{
reg r_valid;
assign valid = r_valid;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_valid <= 1'b0;
	end
	else begin
		r_valid <= 1'b1;
	end
//}

// r_test //{
reg [31:0] r_test;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_test <= INIT_IO_data;
	end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_TEST_REG)) begin
		r_test <= i_IO_write_data;
	end
	else begin 
		r_test <= r_test;
	end
//}

// r_mask_X //{
reg [31:0] r_mask_wi;
reg [31:0] r_mask_wo;
reg [31:0] r_mask_ti;
reg [31:0] r_mask_to;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_mask_wi <= 32'hFFFF_FFFF;
		r_mask_wo <= 32'hFFFF_FFFF;
		r_mask_ti <= 32'hFFFF_FFFF;
		r_mask_to <= 32'hFFFF_FFFF;
	end
	else begin 
		if ( i_IO_addr_strobe & i_IO_write_strobe & ( (i_IO_address == ADRS_MASK_WI)|(i_IO_address == ADRS_MASK_ALL)) ) begin r_mask_wi <= i_IO_write_data; end
		if ( i_IO_addr_strobe & i_IO_write_strobe & ( (i_IO_address == ADRS_MASK_WO)|(i_IO_address == ADRS_MASK_ALL)) ) begin r_mask_wo <= i_IO_write_data; end
		if ( i_IO_addr_strobe & i_IO_write_strobe & ( (i_IO_address == ADRS_MASK_TI)|(i_IO_address == ADRS_MASK_ALL)) ) begin r_mask_ti <= i_IO_write_data; end
		if ( i_IO_addr_strobe & i_IO_write_strobe & ( (i_IO_address == ADRS_MASK_TO)|(i_IO_address == ADRS_MASK_ALL)) ) begin r_mask_to <= i_IO_write_data; end	
	end
//}

//// dedicated LAN port masks fixed to full mask.
wire [31:0] w_mask_wi_lan = 32'hFFFF_FFFF;
wire [31:0] w_mask_wo_lan = 32'hFFFF_FFFF;
wire [31:0] w_mask_ti_lan = 32'hFFFF_FFFF;
wire [31:0] w_mask_to_lan = 32'hFFFF_FFFF;

	
//// o_port_wi_X and o_lan_wi_X //{

o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_00))  o_wi_core__inst__port_wi_00 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_00), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_01))  o_wi_core__inst__port_wi_01 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_01), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_02))  o_wi_core__inst__port_wi_02 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_02), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_03))  o_wi_core__inst__port_wi_03 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_03), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_04))  o_wi_core__inst__port_wi_04 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_04), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_05))  o_wi_core__inst__port_wi_05 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_05), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_06))  o_wi_core__inst__port_wi_06 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_06), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_07))  o_wi_core__inst__port_wi_07 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_07), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_08))  o_wi_core__inst__port_wi_08 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_08), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_09))  o_wi_core__inst__port_wi_09 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_09), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0A))  o_wi_core__inst__port_wi_0A (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0B))  o_wi_core__inst__port_wi_0B (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0C))  o_wi_core__inst__port_wi_0C (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0D))  o_wi_core__inst__port_wi_0D (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0E))  o_wi_core__inst__port_wi_0E (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_0F))  o_wi_core__inst__port_wi_0F (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_0F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_10))  o_wi_core__inst__port_wi_10 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_10), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_11))  o_wi_core__inst__port_wi_11 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_11), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_12))  o_wi_core__inst__port_wi_12 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_12), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_13))  o_wi_core__inst__port_wi_13 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_13), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_14))  o_wi_core__inst__port_wi_14 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_14), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_15))  o_wi_core__inst__port_wi_15 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_15), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_16))  o_wi_core__inst__port_wi_16 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_16), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_17))  o_wi_core__inst__port_wi_17 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_17), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_18))  o_wi_core__inst__port_wi_18 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_18), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_19))  o_wi_core__inst__port_wi_19 (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_19), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1A))  o_wi_core__inst__port_wi_1A (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1B))  o_wi_core__inst__port_wi_1B (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1C))  o_wi_core__inst__port_wi_1C (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1D))  o_wi_core__inst__port_wi_1D (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1E))  o_wi_core__inst__port_wi_1E (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_PORT_WI_1F))  o_wi_core__inst__port_wi_1F (.clk (clk), .reset_n (reset_n), .o_wi (o_port_wi_1F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (r_mask_wi) ); //

//----//

o_wi_core #(.ADRS_PORT_WI(ADRS_LAN_WI_00))  o_wi_core__inst__lan_wi_00 (.clk (clk), .reset_n (reset_n), .o_wi (o_lan_wi_00), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (w_mask_wi_lan) ); //
o_wi_core #(.ADRS_PORT_WI(ADRS_LAN_WI_01))  o_wi_core__inst__lan_wi_01 (.clk (clk), .reset_n (reset_n), .o_wi (o_lan_wi_01), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_wi (w_mask_wi_lan) ); //

//}

//// o_port_ti_X and o_lan_ti_X //{ 

wire [31:0] w_port_ti_40; // replace r_port_ti_40
wire [31:0] w_port_ti_41; // replace r_port_ti_41
wire [31:0] w_port_ti_42; // replace r_port_ti_42
wire [31:0] w_port_ti_43; // replace r_port_ti_43
wire [31:0] w_port_ti_44; // replace r_port_ti_44
wire [31:0] w_port_ti_45; // replace r_port_ti_45
wire [31:0] w_port_ti_46; // replace r_port_ti_46
wire [31:0] w_port_ti_47; // replace r_port_ti_47
wire [31:0] w_port_ti_48; // replace r_port_ti_48
wire [31:0] w_port_ti_49; // replace r_port_ti_49
wire [31:0] w_port_ti_4A; // replace r_port_ti_4A
wire [31:0] w_port_ti_4B; // replace r_port_ti_4B
wire [31:0] w_port_ti_4C; // replace r_port_ti_4C
wire [31:0] w_port_ti_4D; // replace r_port_ti_4D
wire [31:0] w_port_ti_4E; // replace r_port_ti_4E
wire [31:0] w_port_ti_4F; // replace r_port_ti_4F
wire [31:0] w_port_ti_50; // replace r_port_ti_50
wire [31:0] w_port_ti_51; // replace r_port_ti_51
wire [31:0] w_port_ti_52; // replace r_port_ti_52
wire [31:0] w_port_ti_53; // replace r_port_ti_53
wire [31:0] w_port_ti_54; // replace r_port_ti_54
wire [31:0] w_port_ti_55; // replace r_port_ti_55
wire [31:0] w_port_ti_56; // replace r_port_ti_56
wire [31:0] w_port_ti_57; // replace r_port_ti_57
wire [31:0] w_port_ti_58; // replace r_port_ti_58
wire [31:0] w_port_ti_59; // replace r_port_ti_59
wire [31:0] w_port_ti_5A; // replace r_port_ti_5A
wire [31:0] w_port_ti_5B; // replace r_port_ti_5B
wire [31:0] w_port_ti_5C; // replace r_port_ti_5C
wire [31:0] w_port_ti_5D; // replace r_port_ti_5D
wire [31:0] w_port_ti_5E; // replace r_port_ti_5E
wire [31:0] w_port_ti_5F; // replace r_port_ti_5F


o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_40))  o_ti_core__inst__port_ti_40 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_40), .o_ti_clk (o_port_ti_40), .o_ti_reg (w_port_ti_40), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_41))  o_ti_core__inst__port_ti_41 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_41), .o_ti_clk (o_port_ti_41), .o_ti_reg (w_port_ti_41), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_42))  o_ti_core__inst__port_ti_42 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_42), .o_ti_clk (o_port_ti_42), .o_ti_reg (w_port_ti_42), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_43))  o_ti_core__inst__port_ti_43 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_43), .o_ti_clk (o_port_ti_43), .o_ti_reg (w_port_ti_43), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_44))  o_ti_core__inst__port_ti_44 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_44), .o_ti_clk (o_port_ti_44), .o_ti_reg (w_port_ti_44), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_45))  o_ti_core__inst__port_ti_45 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_45), .o_ti_clk (o_port_ti_45), .o_ti_reg (w_port_ti_45), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_46))  o_ti_core__inst__port_ti_46 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_46), .o_ti_clk (o_port_ti_46), .o_ti_reg (w_port_ti_46), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_47))  o_ti_core__inst__port_ti_47 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_47), .o_ti_clk (o_port_ti_47), .o_ti_reg (w_port_ti_47), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_48))  o_ti_core__inst__port_ti_48 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_48), .o_ti_clk (o_port_ti_48), .o_ti_reg (w_port_ti_48), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_49))  o_ti_core__inst__port_ti_49 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_49), .o_ti_clk (o_port_ti_49), .o_ti_reg (w_port_ti_49), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4A))  o_ti_core__inst__port_ti_4A (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4A), .o_ti_clk (o_port_ti_4A), .o_ti_reg (w_port_ti_4A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4B))  o_ti_core__inst__port_ti_4B (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4B), .o_ti_clk (o_port_ti_4B), .o_ti_reg (w_port_ti_4B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4C))  o_ti_core__inst__port_ti_4C (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4C), .o_ti_clk (o_port_ti_4C), .o_ti_reg (w_port_ti_4C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4D))  o_ti_core__inst__port_ti_4D (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4D), .o_ti_clk (o_port_ti_4D), .o_ti_reg (w_port_ti_4D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4E))  o_ti_core__inst__port_ti_4E (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4E), .o_ti_clk (o_port_ti_4E), .o_ti_reg (w_port_ti_4E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_4F))  o_ti_core__inst__port_ti_4F (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_4F), .o_ti_clk (o_port_ti_4F), .o_ti_reg (w_port_ti_4F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_50))  o_ti_core__inst__port_ti_50 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_50), .o_ti_clk (o_port_ti_50), .o_ti_reg (w_port_ti_50), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_51))  o_ti_core__inst__port_ti_51 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_51), .o_ti_clk (o_port_ti_51), .o_ti_reg (w_port_ti_51), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_52))  o_ti_core__inst__port_ti_52 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_52), .o_ti_clk (o_port_ti_52), .o_ti_reg (w_port_ti_52), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_53))  o_ti_core__inst__port_ti_53 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_53), .o_ti_clk (o_port_ti_53), .o_ti_reg (w_port_ti_53), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_54))  o_ti_core__inst__port_ti_54 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_54), .o_ti_clk (o_port_ti_54), .o_ti_reg (w_port_ti_54), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_55))  o_ti_core__inst__port_ti_55 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_55), .o_ti_clk (o_port_ti_55), .o_ti_reg (w_port_ti_55), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_56))  o_ti_core__inst__port_ti_56 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_56), .o_ti_clk (o_port_ti_56), .o_ti_reg (w_port_ti_56), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_57))  o_ti_core__inst__port_ti_57 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_57), .o_ti_clk (o_port_ti_57), .o_ti_reg (w_port_ti_57), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_58))  o_ti_core__inst__port_ti_58 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_58), .o_ti_clk (o_port_ti_58), .o_ti_reg (w_port_ti_58), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_59))  o_ti_core__inst__port_ti_59 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_59), .o_ti_clk (o_port_ti_59), .o_ti_reg (w_port_ti_59), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5A))  o_ti_core__inst__port_ti_5A (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5A), .o_ti_clk (o_port_ti_5A), .o_ti_reg (w_port_ti_5A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5B))  o_ti_core__inst__port_ti_5B (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5B), .o_ti_clk (o_port_ti_5B), .o_ti_reg (w_port_ti_5B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5C))  o_ti_core__inst__port_ti_5C (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5C), .o_ti_clk (o_port_ti_5C), .o_ti_reg (w_port_ti_5C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5D))  o_ti_core__inst__port_ti_5D (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5D), .o_ti_clk (o_port_ti_5D), .o_ti_reg (w_port_ti_5D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5E))  o_ti_core__inst__port_ti_5E (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5E), .o_ti_clk (o_port_ti_5E), .o_ti_reg (w_port_ti_5E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_PORT_TI_5F))  o_ti_core__inst__port_ti_5F (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_5F), .o_ti_clk (o_port_ti_5F), .o_ti_reg (w_port_ti_5F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (r_mask_ti) ); //

//----//

wire [31:0] w_lan_ti_40; //
wire [31:0] w_lan_ti_41; //

o_ti_core #(.ADRS_PORT_TI(ADRS_LAN_TI_40))  o_ti_core__inst__lan_ti_40 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_lan_ck_40), .o_ti_clk (o_lan_ti_40), .o_ti_reg (w_lan_ti_40), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (w_mask_ti_lan) ); //
o_ti_core #(.ADRS_PORT_TI(ADRS_LAN_TI_41))  o_ti_core__inst__lan_ti_41 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_lan_ck_41), .o_ti_clk (o_lan_ti_41), .o_ti_reg (w_lan_ti_41), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_write_strobe (i_IO_write_strobe ), .i_IO_address  (i_IO_address), .i_IO_write_data(i_IO_write_data), .i_mask_ti (w_mask_ti_lan) ); //

//}


//// w_port_to_X and w_lan_to_X //{

wire [31:0] w_port_to_60; // replace  r_port_to_60_smp&r_mask_to
wire [31:0] w_port_to_61;
wire [31:0] w_port_to_62;
wire [31:0] w_port_to_63;
wire [31:0] w_port_to_64;
wire [31:0] w_port_to_65;
wire [31:0] w_port_to_66;
wire [31:0] w_port_to_67;
wire [31:0] w_port_to_68;
wire [31:0] w_port_to_69;
wire [31:0] w_port_to_6A;
wire [31:0] w_port_to_6B;
wire [31:0] w_port_to_6C;
wire [31:0] w_port_to_6D;
wire [31:0] w_port_to_6E;
wire [31:0] w_port_to_6F;
wire [31:0] w_port_to_70;
wire [31:0] w_port_to_71;
wire [31:0] w_port_to_72;
wire [31:0] w_port_to_73;
wire [31:0] w_port_to_74;
wire [31:0] w_port_to_75;
wire [31:0] w_port_to_76;
wire [31:0] w_port_to_77;
wire [31:0] w_port_to_78;
wire [31:0] w_port_to_79;
wire [31:0] w_port_to_7A;
wire [31:0] w_port_to_7B;
wire [31:0] w_port_to_7C;
wire [31:0] w_port_to_7D;
wire [31:0] w_port_to_7E;
wire [31:0] w_port_to_7F;

i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_60))  i_to_core__inst__port_to_60 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_60), .i_to_clk (i_port_to_60), .o_to_reg (w_port_to_60), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_61))  i_to_core__inst__port_to_61 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_61), .i_to_clk (i_port_to_61), .o_to_reg (w_port_to_61), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_62))  i_to_core__inst__port_to_62 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_62), .i_to_clk (i_port_to_62), .o_to_reg (w_port_to_62), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_63))  i_to_core__inst__port_to_63 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_63), .i_to_clk (i_port_to_63), .o_to_reg (w_port_to_63), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_64))  i_to_core__inst__port_to_64 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_64), .i_to_clk (i_port_to_64), .o_to_reg (w_port_to_64), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_65))  i_to_core__inst__port_to_65 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_65), .i_to_clk (i_port_to_65), .o_to_reg (w_port_to_65), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_66))  i_to_core__inst__port_to_66 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_66), .i_to_clk (i_port_to_66), .o_to_reg (w_port_to_66), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_67))  i_to_core__inst__port_to_67 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_67), .i_to_clk (i_port_to_67), .o_to_reg (w_port_to_67), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_68))  i_to_core__inst__port_to_68 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_68), .i_to_clk (i_port_to_68), .o_to_reg (w_port_to_68), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_69))  i_to_core__inst__port_to_69 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_69), .i_to_clk (i_port_to_69), .o_to_reg (w_port_to_69), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6A))  i_to_core__inst__port_to_6A (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6A), .i_to_clk (i_port_to_6A), .o_to_reg (w_port_to_6A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6B))  i_to_core__inst__port_to_6B (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6B), .i_to_clk (i_port_to_6B), .o_to_reg (w_port_to_6B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6C))  i_to_core__inst__port_to_6C (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6C), .i_to_clk (i_port_to_6C), .o_to_reg (w_port_to_6C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6D))  i_to_core__inst__port_to_6D (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6D), .i_to_clk (i_port_to_6D), .o_to_reg (w_port_to_6D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6E))  i_to_core__inst__port_to_6E (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6E), .i_to_clk (i_port_to_6E), .o_to_reg (w_port_to_6E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_6F))  i_to_core__inst__port_to_6F (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_6F), .i_to_clk (i_port_to_6F), .o_to_reg (w_port_to_6F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_70))  i_to_core__inst__port_to_70 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_70), .i_to_clk (i_port_to_70), .o_to_reg (w_port_to_70), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_71))  i_to_core__inst__port_to_71 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_71), .i_to_clk (i_port_to_71), .o_to_reg (w_port_to_71), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_72))  i_to_core__inst__port_to_72 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_72), .i_to_clk (i_port_to_72), .o_to_reg (w_port_to_72), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_73))  i_to_core__inst__port_to_73 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_73), .i_to_clk (i_port_to_73), .o_to_reg (w_port_to_73), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_74))  i_to_core__inst__port_to_74 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_74), .i_to_clk (i_port_to_74), .o_to_reg (w_port_to_74), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_75))  i_to_core__inst__port_to_75 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_75), .i_to_clk (i_port_to_75), .o_to_reg (w_port_to_75), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_76))  i_to_core__inst__port_to_76 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_76), .i_to_clk (i_port_to_76), .o_to_reg (w_port_to_76), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_77))  i_to_core__inst__port_to_77 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_77), .i_to_clk (i_port_to_77), .o_to_reg (w_port_to_77), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_78))  i_to_core__inst__port_to_78 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_78), .i_to_clk (i_port_to_78), .o_to_reg (w_port_to_78), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_79))  i_to_core__inst__port_to_79 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_79), .i_to_clk (i_port_to_79), .o_to_reg (w_port_to_79), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7A))  i_to_core__inst__port_to_7A (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7A), .i_to_clk (i_port_to_7A), .o_to_reg (w_port_to_7A), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7B))  i_to_core__inst__port_to_7B (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7B), .i_to_clk (i_port_to_7B), .o_to_reg (w_port_to_7B), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7C))  i_to_core__inst__port_to_7C (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7C), .i_to_clk (i_port_to_7C), .o_to_reg (w_port_to_7C), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7D))  i_to_core__inst__port_to_7D (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7D), .i_to_clk (i_port_to_7D), .o_to_reg (w_port_to_7D), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7E))  i_to_core__inst__port_to_7E (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7E), .i_to_clk (i_port_to_7E), .o_to_reg (w_port_to_7E), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_PORT_TO_7F))  i_to_core__inst__port_to_7F (.clk (clk), .reset_n (reset_n), .i_port_ck (i_port_ck_7F), .i_to_clk (i_port_to_7F), .o_to_reg (w_port_to_7F), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (r_mask_to) ); //


//----//

wire [31:0] w_lan_to_60; //
wire [31:0] w_lan_to_61; //

i_to_core #(.ADRS_PORT_TO(ADRS_LAN_TO_60))  i_to_core__inst__lan_to_60 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_lan_ck_60), .i_to_clk (i_lan_to_60), .o_to_reg (w_lan_to_60), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (w_mask_to_lan) ); //
i_to_core #(.ADRS_PORT_TO(ADRS_LAN_TO_61))  i_to_core__inst__lan_to_61 (.clk (clk), .reset_n (reset_n), .i_port_ck (i_lan_ck_61), .i_to_clk (i_lan_to_61), .o_to_reg (w_lan_to_61), .i_IO_addr_strobe  (i_IO_addr_strobe), .i_IO_read_strobe (i_IO_read_strobe ), .i_IO_address  (i_IO_address), .i_mask_to (w_mask_to_lan) ); //

	
//}
	
	
//// r_IO_address //{
(* keep = "true" *) reg [31:0] r_IO_address;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_address <= 32'b0;
	end
	else if (i_IO_addr_strobe & i_IO_read_strobe) begin
		r_IO_address <= i_IO_address;
	end
	else begin
		r_IO_address <= 32'b0;
	end
//}

//// r_IO_read_data //{
(* keep = "true" *) reg [31:0] r_IO_read_data;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_read_data <= INIT_IO_data;
	end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_FPGA_IMAGE_ID)) begin r_IO_read_data <= FPGA_IMAGE_ID; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_TEST_REG)) begin r_IO_read_data <= r_test; end

	// MASK //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_ALL)) begin r_IO_read_data <= r_mask_wi&r_mask_wo&r_mask_ti&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_WI )) begin r_IO_read_data <= r_mask_wi; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_WO )) begin r_IO_read_data <= r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_TI )) begin r_IO_read_data <= r_mask_ti; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_TO )) begin r_IO_read_data <= r_mask_to; end
	//}
	
	// LAN control //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_LAN_CONF_00)) begin r_IO_read_data <= i_lan_conf_00; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_LAN_CONF_01)) begin r_IO_read_data <= i_lan_conf_01; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_LAN_CONF_02)) begin r_IO_read_data <= i_lan_conf_02; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_LAN_CONF_03)) begin r_IO_read_data <= i_lan_conf_03; end
	//}
	
	// WI //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_00)) begin r_IO_read_data <= o_port_wi_00; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_01)) begin r_IO_read_data <= o_port_wi_01; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_02)) begin r_IO_read_data <= o_port_wi_02; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_03)) begin r_IO_read_data <= o_port_wi_03; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_04)) begin r_IO_read_data <= o_port_wi_04; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_05)) begin r_IO_read_data <= o_port_wi_05; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_06)) begin r_IO_read_data <= o_port_wi_06; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_07)) begin r_IO_read_data <= o_port_wi_07; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_08)) begin r_IO_read_data <= o_port_wi_08; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_09)) begin r_IO_read_data <= o_port_wi_09; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0A)) begin r_IO_read_data <= o_port_wi_0A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0B)) begin r_IO_read_data <= o_port_wi_0B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0C)) begin r_IO_read_data <= o_port_wi_0C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0D)) begin r_IO_read_data <= o_port_wi_0D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0E)) begin r_IO_read_data <= o_port_wi_0E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0F)) begin r_IO_read_data <= o_port_wi_0F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_10)) begin r_IO_read_data <= o_port_wi_10; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_11)) begin r_IO_read_data <= o_port_wi_11; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_12)) begin r_IO_read_data <= o_port_wi_12; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_13)) begin r_IO_read_data <= o_port_wi_13; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_14)) begin r_IO_read_data <= o_port_wi_14; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_15)) begin r_IO_read_data <= o_port_wi_15; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_16)) begin r_IO_read_data <= o_port_wi_16; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_17)) begin r_IO_read_data <= o_port_wi_17; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_18)) begin r_IO_read_data <= o_port_wi_18; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_19)) begin r_IO_read_data <= o_port_wi_19; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1A)) begin r_IO_read_data <= o_port_wi_1A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1B)) begin r_IO_read_data <= o_port_wi_1B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1C)) begin r_IO_read_data <= o_port_wi_1C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1D)) begin r_IO_read_data <= o_port_wi_1D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1E)) begin r_IO_read_data <= o_port_wi_1E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1F)) begin r_IO_read_data <= o_port_wi_1F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_WI_00)) begin r_IO_read_data <=  o_lan_wi_00; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_WI_01)) begin r_IO_read_data <=  o_lan_wi_01; end
	//}
	
	// WO //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_20)) begin r_IO_read_data <= i_port_wo_20&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_21)) begin r_IO_read_data <= i_port_wo_21&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_22)) begin r_IO_read_data <= i_port_wo_22&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_23)) begin r_IO_read_data <= i_port_wo_23&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_24)) begin r_IO_read_data <= i_port_wo_24&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_25)) begin r_IO_read_data <= i_port_wo_25&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_26)) begin r_IO_read_data <= i_port_wo_26&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_27)) begin r_IO_read_data <= i_port_wo_27&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_28)) begin r_IO_read_data <= i_port_wo_28&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_29)) begin r_IO_read_data <= i_port_wo_29&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2A)) begin r_IO_read_data <= i_port_wo_2A&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2B)) begin r_IO_read_data <= i_port_wo_2B&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2C)) begin r_IO_read_data <= i_port_wo_2C&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2D)) begin r_IO_read_data <= i_port_wo_2D&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2E)) begin r_IO_read_data <= i_port_wo_2E&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_2F)) begin r_IO_read_data <= i_port_wo_2F&r_mask_wo; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_30)) begin r_IO_read_data <= i_port_wo_30&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_31)) begin r_IO_read_data <= i_port_wo_31&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_32)) begin r_IO_read_data <= i_port_wo_32&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_33)) begin r_IO_read_data <= i_port_wo_33&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_34)) begin r_IO_read_data <= i_port_wo_34&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_35)) begin r_IO_read_data <= i_port_wo_35&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_36)) begin r_IO_read_data <= i_port_wo_36&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_37)) begin r_IO_read_data <= i_port_wo_37&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_38)) begin r_IO_read_data <= i_port_wo_38&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_39)) begin r_IO_read_data <= i_port_wo_39&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3A)) begin r_IO_read_data <= i_port_wo_3A&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3B)) begin r_IO_read_data <= i_port_wo_3B&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3C)) begin r_IO_read_data <= i_port_wo_3C&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3D)) begin r_IO_read_data <= i_port_wo_3D&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3E)) begin r_IO_read_data <= i_port_wo_3E&r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WO_3F)) begin r_IO_read_data <= i_port_wo_3F&r_mask_wo; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_WO_20)) begin r_IO_read_data <=  i_lan_wo_20&w_mask_wo_lan; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_WO_21)) begin r_IO_read_data <=  i_lan_wo_21&w_mask_wo_lan; end
	//}
	
	// TI //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_40)) begin r_IO_read_data <= w_port_ti_40; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_41)) begin r_IO_read_data <= w_port_ti_41; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_42)) begin r_IO_read_data <= w_port_ti_42; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_43)) begin r_IO_read_data <= w_port_ti_43; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_44)) begin r_IO_read_data <= w_port_ti_44; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_45)) begin r_IO_read_data <= w_port_ti_45; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_46)) begin r_IO_read_data <= w_port_ti_46; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_47)) begin r_IO_read_data <= w_port_ti_47; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_48)) begin r_IO_read_data <= w_port_ti_48; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_49)) begin r_IO_read_data <= w_port_ti_49; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4A)) begin r_IO_read_data <= w_port_ti_4A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4B)) begin r_IO_read_data <= w_port_ti_4B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4C)) begin r_IO_read_data <= w_port_ti_4C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4D)) begin r_IO_read_data <= w_port_ti_4D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4E)) begin r_IO_read_data <= w_port_ti_4E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4F)) begin r_IO_read_data <= w_port_ti_4F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_50)) begin r_IO_read_data <= w_port_ti_50; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_51)) begin r_IO_read_data <= w_port_ti_51; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_52)) begin r_IO_read_data <= w_port_ti_52; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_53)) begin r_IO_read_data <= w_port_ti_53; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_54)) begin r_IO_read_data <= w_port_ti_54; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_55)) begin r_IO_read_data <= w_port_ti_55; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_56)) begin r_IO_read_data <= w_port_ti_56; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_57)) begin r_IO_read_data <= w_port_ti_57; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_58)) begin r_IO_read_data <= w_port_ti_58; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_59)) begin r_IO_read_data <= w_port_ti_59; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5A)) begin r_IO_read_data <= w_port_ti_5A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5B)) begin r_IO_read_data <= w_port_ti_5B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5C)) begin r_IO_read_data <= w_port_ti_5C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5D)) begin r_IO_read_data <= w_port_ti_5D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5E)) begin r_IO_read_data <= w_port_ti_5E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5F)) begin r_IO_read_data <= w_port_ti_5F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_TI_40)) begin r_IO_read_data <=  w_lan_ti_40; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_TI_41)) begin r_IO_read_data <=  w_lan_ti_41; end
	//}
	
	// TO //{
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_60)) begin r_IO_read_data <= w_port_to_60; end // r_port_to_60_smp&r_mask_to
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_61)) begin r_IO_read_data <= w_port_to_61; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_62)) begin r_IO_read_data <= w_port_to_62; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_63)) begin r_IO_read_data <= w_port_to_63; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_64)) begin r_IO_read_data <= w_port_to_64; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_65)) begin r_IO_read_data <= w_port_to_65; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_66)) begin r_IO_read_data <= w_port_to_66; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_67)) begin r_IO_read_data <= w_port_to_67; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_68)) begin r_IO_read_data <= w_port_to_68; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_69)) begin r_IO_read_data <= w_port_to_69; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6A)) begin r_IO_read_data <= w_port_to_6A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6B)) begin r_IO_read_data <= w_port_to_6B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6C)) begin r_IO_read_data <= w_port_to_6C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6D)) begin r_IO_read_data <= w_port_to_6D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6E)) begin r_IO_read_data <= w_port_to_6E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6F)) begin r_IO_read_data <= w_port_to_6F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_70)) begin r_IO_read_data <= w_port_to_70; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_71)) begin r_IO_read_data <= w_port_to_71; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_72)) begin r_IO_read_data <= w_port_to_72; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_73)) begin r_IO_read_data <= w_port_to_73; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_74)) begin r_IO_read_data <= w_port_to_74; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_75)) begin r_IO_read_data <= w_port_to_75; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_76)) begin r_IO_read_data <= w_port_to_76; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_77)) begin r_IO_read_data <= w_port_to_77; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_78)) begin r_IO_read_data <= w_port_to_78; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_79)) begin r_IO_read_data <= w_port_to_79; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7A)) begin r_IO_read_data <= w_port_to_7A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7B)) begin r_IO_read_data <= w_port_to_7B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7C)) begin r_IO_read_data <= w_port_to_7C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7D)) begin r_IO_read_data <= w_port_to_7D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7E)) begin r_IO_read_data <= w_port_to_7E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7F)) begin r_IO_read_data <= w_port_to_7F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_TO_60)) begin r_IO_read_data <=  w_lan_to_60; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address ==  ADRS_LAN_TO_61)) begin r_IO_read_data <=  w_lan_to_61; end
	//}
	
	else begin 
		r_IO_read_data <= INIT_IO_data;
	end
//}

// o_port_wr_X //{
assign o_port_wr_80 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_80))? 1'b1 : 1'b0;
assign o_port_wr_81 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_81))? 1'b1 : 1'b0;
assign o_port_wr_82 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_82))? 1'b1 : 1'b0;
assign o_port_wr_83 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_83))? 1'b1 : 1'b0;
assign o_port_wr_84 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_84))? 1'b1 : 1'b0;
assign o_port_wr_85 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_85))? 1'b1 : 1'b0;
assign o_port_wr_86 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_86))? 1'b1 : 1'b0;
assign o_port_wr_87 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_87))? 1'b1 : 1'b0;
assign o_port_wr_88 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_88))? 1'b1 : 1'b0;
assign o_port_wr_89 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_89))? 1'b1 : 1'b0;
assign o_port_wr_8A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8A))? 1'b1 : 1'b0;
assign o_port_wr_8B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8B))? 1'b1 : 1'b0;
assign o_port_wr_8C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8C))? 1'b1 : 1'b0;
assign o_port_wr_8D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8D))? 1'b1 : 1'b0;
assign o_port_wr_8E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8E))? 1'b1 : 1'b0;
assign o_port_wr_8F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8F))? 1'b1 : 1'b0;
//
assign o_port_wr_90 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_90))? 1'b1 : 1'b0;
assign o_port_wr_91 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_91))? 1'b1 : 1'b0;
assign o_port_wr_92 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_92))? 1'b1 : 1'b0;
assign o_port_wr_93 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_93))? 1'b1 : 1'b0;
assign o_port_wr_94 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_94))? 1'b1 : 1'b0;
assign o_port_wr_95 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_95))? 1'b1 : 1'b0;
assign o_port_wr_96 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_96))? 1'b1 : 1'b0;
assign o_port_wr_97 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_97))? 1'b1 : 1'b0;
assign o_port_wr_98 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_98))? 1'b1 : 1'b0;
assign o_port_wr_99 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_99))? 1'b1 : 1'b0;
assign o_port_wr_9A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9A))? 1'b1 : 1'b0;
assign o_port_wr_9B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9B))? 1'b1 : 1'b0;
assign o_port_wr_9C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9C))? 1'b1 : 1'b0;
assign o_port_wr_9D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9D))? 1'b1 : 1'b0;
assign o_port_wr_9E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9E))? 1'b1 : 1'b0;
assign o_port_wr_9F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9F))? 1'b1 : 1'b0;
//
assign  o_lan_wr_80 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address ==  ADRS_LAN_PI_80))? 1'b1 : 1'b0;
assign  o_lan_wr_81 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address ==  ADRS_LAN_PI_81))? 1'b1 : 1'b0;
//}

// o_port_pi_X //{
assign o_port_pi_80 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_80))? i_IO_write_data : 32'b0;
assign o_port_pi_81 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_81))? i_IO_write_data : 32'b0;
assign o_port_pi_82 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_82))? i_IO_write_data : 32'b0;
assign o_port_pi_83 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_83))? i_IO_write_data : 32'b0;
assign o_port_pi_84 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_84))? i_IO_write_data : 32'b0;
assign o_port_pi_85 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_85))? i_IO_write_data : 32'b0;
assign o_port_pi_86 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_86))? i_IO_write_data : 32'b0;
assign o_port_pi_87 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_87))? i_IO_write_data : 32'b0;
assign o_port_pi_88 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_88))? i_IO_write_data : 32'b0;
assign o_port_pi_89 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_89))? i_IO_write_data : 32'b0;
assign o_port_pi_8A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8A))? i_IO_write_data : 32'b0;
assign o_port_pi_8B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8B))? i_IO_write_data : 32'b0;
assign o_port_pi_8C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8C))? i_IO_write_data : 32'b0;
assign o_port_pi_8D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8D))? i_IO_write_data : 32'b0;
assign o_port_pi_8E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8E))? i_IO_write_data : 32'b0;
assign o_port_pi_8F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8F))? i_IO_write_data : 32'b0;
//
assign o_port_pi_90 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_90))? i_IO_write_data : 32'b0;
assign o_port_pi_91 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_91))? i_IO_write_data : 32'b0;
assign o_port_pi_92 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_92))? i_IO_write_data : 32'b0;
assign o_port_pi_93 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_93))? i_IO_write_data : 32'b0;
assign o_port_pi_94 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_94))? i_IO_write_data : 32'b0;
assign o_port_pi_95 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_95))? i_IO_write_data : 32'b0;
assign o_port_pi_96 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_96))? i_IO_write_data : 32'b0;
assign o_port_pi_97 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_97))? i_IO_write_data : 32'b0;
assign o_port_pi_98 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_98))? i_IO_write_data : 32'b0;
assign o_port_pi_99 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_99))? i_IO_write_data : 32'b0;
assign o_port_pi_9A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9A))? i_IO_write_data : 32'b0;
assign o_port_pi_9B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9B))? i_IO_write_data : 32'b0;
assign o_port_pi_9C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9C))? i_IO_write_data : 32'b0;
assign o_port_pi_9D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9D))? i_IO_write_data : 32'b0;
assign o_port_pi_9E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9E))? i_IO_write_data : 32'b0;
assign o_port_pi_9F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9F))? i_IO_write_data : 32'b0;
//
assign  o_lan_pi_80 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address ==  ADRS_LAN_PI_80))? i_IO_write_data : 32'b0;
assign  o_lan_pi_81 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address ==  ADRS_LAN_PI_81))? i_IO_write_data : 32'b0;
//}

// o_port_rd_X //{
assign o_port_rd_A0 = (i_IO_address == ADRS_PORT_PO_A0)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A1 = (i_IO_address == ADRS_PORT_PO_A1)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A2 = (i_IO_address == ADRS_PORT_PO_A2)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A3 = (i_IO_address == ADRS_PORT_PO_A3)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A4 = (i_IO_address == ADRS_PORT_PO_A4)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A5 = (i_IO_address == ADRS_PORT_PO_A5)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A6 = (i_IO_address == ADRS_PORT_PO_A6)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A7 = (i_IO_address == ADRS_PORT_PO_A7)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A8 = (i_IO_address == ADRS_PORT_PO_A8)? i_IO_read_strobe : 1'b0;
assign o_port_rd_A9 = (i_IO_address == ADRS_PORT_PO_A9)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AA = (i_IO_address == ADRS_PORT_PO_AA)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AB = (i_IO_address == ADRS_PORT_PO_AB)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AC = (i_IO_address == ADRS_PORT_PO_AC)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AD = (i_IO_address == ADRS_PORT_PO_AD)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AE = (i_IO_address == ADRS_PORT_PO_AE)? i_IO_read_strobe : 1'b0;
assign o_port_rd_AF = (i_IO_address == ADRS_PORT_PO_AF)? i_IO_read_strobe : 1'b0;
//
assign o_port_rd_B0 = (i_IO_address == ADRS_PORT_PO_B0)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B1 = (i_IO_address == ADRS_PORT_PO_B1)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B2 = (i_IO_address == ADRS_PORT_PO_B2)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B3 = (i_IO_address == ADRS_PORT_PO_B3)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B4 = (i_IO_address == ADRS_PORT_PO_B4)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B5 = (i_IO_address == ADRS_PORT_PO_B5)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B6 = (i_IO_address == ADRS_PORT_PO_B6)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B7 = (i_IO_address == ADRS_PORT_PO_B7)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B8 = (i_IO_address == ADRS_PORT_PO_B8)? i_IO_read_strobe : 1'b0;
assign o_port_rd_B9 = (i_IO_address == ADRS_PORT_PO_B9)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BA = (i_IO_address == ADRS_PORT_PO_BA)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BB = (i_IO_address == ADRS_PORT_PO_BB)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BC = (i_IO_address == ADRS_PORT_PO_BC)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BD = (i_IO_address == ADRS_PORT_PO_BD)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BE = (i_IO_address == ADRS_PORT_PO_BE)? i_IO_read_strobe : 1'b0;
assign o_port_rd_BF = (i_IO_address == ADRS_PORT_PO_BF)? i_IO_read_strobe : 1'b0;
//
assign  o_lan_rd_A0 = (i_IO_address ==  ADRS_LAN_PO_A0)? i_IO_read_strobe : 1'b0;
assign  o_lan_rd_A1 = (i_IO_address ==  ADRS_LAN_PO_A1)? i_IO_read_strobe : 1'b0;
//}

// w_match_IO_adrs //{
wire w_match_IO_adrs;
assign w_match_IO_adrs =
	(i_IO_address == ADRS_PORT_WI_00)    |
	(i_IO_address == ADRS_PORT_WI_01)    |
	(i_IO_address == ADRS_PORT_WI_02)    |
	(i_IO_address == ADRS_PORT_WI_03)    |
	(i_IO_address == ADRS_PORT_WI_04)    |
	(i_IO_address == ADRS_PORT_WI_05)    |
	(i_IO_address == ADRS_PORT_WI_06)    |
	(i_IO_address == ADRS_PORT_WI_07)    |
	(i_IO_address == ADRS_PORT_WI_08)    |
	(i_IO_address == ADRS_PORT_WI_09)    |
	(i_IO_address == ADRS_PORT_WI_0A)    |
	(i_IO_address == ADRS_PORT_WI_0B)    |
	(i_IO_address == ADRS_PORT_WI_0C)    |
	(i_IO_address == ADRS_PORT_WI_0D)    |
	(i_IO_address == ADRS_PORT_WI_0E)    |
	(i_IO_address == ADRS_PORT_WI_0F)    |
	//
	(i_IO_address == ADRS_PORT_WI_10)    |
	(i_IO_address == ADRS_PORT_WI_11)    |
	(i_IO_address == ADRS_PORT_WI_12)    |
	(i_IO_address == ADRS_PORT_WI_13)    |
	(i_IO_address == ADRS_PORT_WI_14)    |
	(i_IO_address == ADRS_PORT_WI_15)    |
	(i_IO_address == ADRS_PORT_WI_16)    |
	(i_IO_address == ADRS_PORT_WI_17)    |
	(i_IO_address == ADRS_PORT_WI_18)    |
	(i_IO_address == ADRS_PORT_WI_19)    |
	(i_IO_address == ADRS_PORT_WI_1A)    |
	(i_IO_address == ADRS_PORT_WI_1B)    |
	(i_IO_address == ADRS_PORT_WI_1C)    |
	(i_IO_address == ADRS_PORT_WI_1D)    |
	(i_IO_address == ADRS_PORT_WI_1E)    |
	(i_IO_address == ADRS_PORT_WI_1F)    |
	//
	(i_IO_address == ADRS_PORT_WO_20)    |
	(i_IO_address == ADRS_PORT_WO_21)    |
	(i_IO_address == ADRS_PORT_WO_22)    |
	(i_IO_address == ADRS_PORT_WO_23)    |
	(i_IO_address == ADRS_PORT_WO_24)    |
	(i_IO_address == ADRS_PORT_WO_25)    |
	(i_IO_address == ADRS_PORT_WO_26)    |
	(i_IO_address == ADRS_PORT_WO_27)    |
	(i_IO_address == ADRS_PORT_WO_28)    |
	(i_IO_address == ADRS_PORT_WO_29)    |
	(i_IO_address == ADRS_PORT_WO_2A)    |
	(i_IO_address == ADRS_PORT_WO_2B)    |
	(i_IO_address == ADRS_PORT_WO_2C)    |
	(i_IO_address == ADRS_PORT_WO_2D)    |
	(i_IO_address == ADRS_PORT_WO_2E)    |
	(i_IO_address == ADRS_PORT_WO_2F)    |
	//
	(i_IO_address == ADRS_PORT_WO_30)    |
	(i_IO_address == ADRS_PORT_WO_31)    |
	(i_IO_address == ADRS_PORT_WO_32)    |
	(i_IO_address == ADRS_PORT_WO_33)    |
	(i_IO_address == ADRS_PORT_WO_34)    |
	(i_IO_address == ADRS_PORT_WO_35)    |
	(i_IO_address == ADRS_PORT_WO_36)    |
	(i_IO_address == ADRS_PORT_WO_37)    |
	(i_IO_address == ADRS_PORT_WO_38)    |
	(i_IO_address == ADRS_PORT_WO_39)    |
	(i_IO_address == ADRS_PORT_WO_3A)    |
	(i_IO_address == ADRS_PORT_WO_3B)    |
	(i_IO_address == ADRS_PORT_WO_3C)    |
	(i_IO_address == ADRS_PORT_WO_3D)    |
	(i_IO_address == ADRS_PORT_WO_3E)    |
	(i_IO_address == ADRS_PORT_WO_3F)    |
	//
	(i_IO_address == ADRS_PORT_TI_40)    |
	(i_IO_address == ADRS_PORT_TI_41)    |
	(i_IO_address == ADRS_PORT_TI_42)    |
	(i_IO_address == ADRS_PORT_TI_43)    |
	(i_IO_address == ADRS_PORT_TI_44)    |
	(i_IO_address == ADRS_PORT_TI_45)    |
	(i_IO_address == ADRS_PORT_TI_46)    |
	(i_IO_address == ADRS_PORT_TI_47)    |
	(i_IO_address == ADRS_PORT_TI_48)    |
	(i_IO_address == ADRS_PORT_TI_49)    |
	(i_IO_address == ADRS_PORT_TI_4A)    |
	(i_IO_address == ADRS_PORT_TI_4B)    |
	(i_IO_address == ADRS_PORT_TI_4C)    |
	(i_IO_address == ADRS_PORT_TI_4D)    |
	(i_IO_address == ADRS_PORT_TI_4E)    |
	(i_IO_address == ADRS_PORT_TI_4F)    |
	//
	(i_IO_address == ADRS_PORT_TI_50)    |
	(i_IO_address == ADRS_PORT_TI_51)    |
	(i_IO_address == ADRS_PORT_TI_52)    |
	(i_IO_address == ADRS_PORT_TI_53)    |
	(i_IO_address == ADRS_PORT_TI_54)    |
	(i_IO_address == ADRS_PORT_TI_55)    |
	(i_IO_address == ADRS_PORT_TI_56)    |
	(i_IO_address == ADRS_PORT_TI_57)    |
	(i_IO_address == ADRS_PORT_TI_58)    |
	(i_IO_address == ADRS_PORT_TI_59)    |
	(i_IO_address == ADRS_PORT_TI_5A)    |
	(i_IO_address == ADRS_PORT_TI_5B)    |
	(i_IO_address == ADRS_PORT_TI_5C)    |
	(i_IO_address == ADRS_PORT_TI_5D)    |
	(i_IO_address == ADRS_PORT_TI_5E)    |
	(i_IO_address == ADRS_PORT_TI_5F)    |
	//
	(i_IO_address == ADRS_PORT_TO_60)    |
	(i_IO_address == ADRS_PORT_TO_61)    |
	(i_IO_address == ADRS_PORT_TO_62)    |
	(i_IO_address == ADRS_PORT_TO_63)    |
	(i_IO_address == ADRS_PORT_TO_64)    |
	(i_IO_address == ADRS_PORT_TO_65)    |
	(i_IO_address == ADRS_PORT_TO_66)    |
	(i_IO_address == ADRS_PORT_TO_67)    |
	(i_IO_address == ADRS_PORT_TO_68)    |
	(i_IO_address == ADRS_PORT_TO_69)    |
	(i_IO_address == ADRS_PORT_TO_6A)    |
	(i_IO_address == ADRS_PORT_TO_6B)    |
	(i_IO_address == ADRS_PORT_TO_6C)    |
	(i_IO_address == ADRS_PORT_TO_6D)    |
	(i_IO_address == ADRS_PORT_TO_6E)    |
	(i_IO_address == ADRS_PORT_TO_6F)    |
	//
	(i_IO_address == ADRS_PORT_TO_70)    |
	(i_IO_address == ADRS_PORT_TO_71)    |
	(i_IO_address == ADRS_PORT_TO_72)    |
	(i_IO_address == ADRS_PORT_TO_73)    |
	(i_IO_address == ADRS_PORT_TO_74)    |
	(i_IO_address == ADRS_PORT_TO_75)    |
	(i_IO_address == ADRS_PORT_TO_76)    |
	(i_IO_address == ADRS_PORT_TO_77)    |
	(i_IO_address == ADRS_PORT_TO_78)    |
	(i_IO_address == ADRS_PORT_TO_79)    |
	(i_IO_address == ADRS_PORT_TO_7A)    |
	(i_IO_address == ADRS_PORT_TO_7B)    |
	(i_IO_address == ADRS_PORT_TO_7C)    |
	(i_IO_address == ADRS_PORT_TO_7D)    |
	(i_IO_address == ADRS_PORT_TO_7E)    |
	(i_IO_address == ADRS_PORT_TO_7F)    |
	//
	(i_IO_address == ADRS_PORT_PI_80)    |
	(i_IO_address == ADRS_PORT_PI_81)    |
	(i_IO_address == ADRS_PORT_PI_82)    |
	(i_IO_address == ADRS_PORT_PI_83)    |
	(i_IO_address == ADRS_PORT_PI_84)    |
	(i_IO_address == ADRS_PORT_PI_85)    |
	(i_IO_address == ADRS_PORT_PI_86)    |
	(i_IO_address == ADRS_PORT_PI_87)    |
	(i_IO_address == ADRS_PORT_PI_88)    |
	(i_IO_address == ADRS_PORT_PI_89)    |
	(i_IO_address == ADRS_PORT_PI_8A)    |
	(i_IO_address == ADRS_PORT_PI_8B)    |
	(i_IO_address == ADRS_PORT_PI_8C)    |
	(i_IO_address == ADRS_PORT_PI_8D)    |
	(i_IO_address == ADRS_PORT_PI_8E)    |
	(i_IO_address == ADRS_PORT_PI_8F)    |
	//
	(i_IO_address == ADRS_PORT_PI_90)    |
	(i_IO_address == ADRS_PORT_PI_91)    |
	(i_IO_address == ADRS_PORT_PI_92)    |
	(i_IO_address == ADRS_PORT_PI_93)    |
	(i_IO_address == ADRS_PORT_PI_94)    |
	(i_IO_address == ADRS_PORT_PI_95)    |
	(i_IO_address == ADRS_PORT_PI_96)    |
	(i_IO_address == ADRS_PORT_PI_97)    |
	(i_IO_address == ADRS_PORT_PI_98)    |
	(i_IO_address == ADRS_PORT_PI_99)    |
	(i_IO_address == ADRS_PORT_PI_9A)    |
	(i_IO_address == ADRS_PORT_PI_9B)    |
	(i_IO_address == ADRS_PORT_PI_9C)    |
	(i_IO_address == ADRS_PORT_PI_9D)    |
	(i_IO_address == ADRS_PORT_PI_9E)    |
	(i_IO_address == ADRS_PORT_PI_9F)    |
	//
	(i_IO_address == ADRS_PORT_PO_A0)    |
	(i_IO_address == ADRS_PORT_PO_A1)    |
	(i_IO_address == ADRS_PORT_PO_A2)    |
	(i_IO_address == ADRS_PORT_PO_A3)    |
	(i_IO_address == ADRS_PORT_PO_A4)    |
	(i_IO_address == ADRS_PORT_PO_A5)    |
	(i_IO_address == ADRS_PORT_PO_A6)    |
	(i_IO_address == ADRS_PORT_PO_A7)    |
	(i_IO_address == ADRS_PORT_PO_A8)    |
	(i_IO_address == ADRS_PORT_PO_A9)    |
	(i_IO_address == ADRS_PORT_PO_AA)    |
	(i_IO_address == ADRS_PORT_PO_AB)    |
	(i_IO_address == ADRS_PORT_PO_AC)    |
	(i_IO_address == ADRS_PORT_PO_AD)    |
	(i_IO_address == ADRS_PORT_PO_AE)    |
	(i_IO_address == ADRS_PORT_PO_AF)    |
	//
	(i_IO_address == ADRS_PORT_PO_B0)    |
	(i_IO_address == ADRS_PORT_PO_B1)    |
	(i_IO_address == ADRS_PORT_PO_B2)    |
	(i_IO_address == ADRS_PORT_PO_B3)    |
	(i_IO_address == ADRS_PORT_PO_B4)    |
	(i_IO_address == ADRS_PORT_PO_B5)    |
	(i_IO_address == ADRS_PORT_PO_B6)    |
	(i_IO_address == ADRS_PORT_PO_B7)    |
	(i_IO_address == ADRS_PORT_PO_B8)    |
	(i_IO_address == ADRS_PORT_PO_B9)    |
	(i_IO_address == ADRS_PORT_PO_BA)    |
	(i_IO_address == ADRS_PORT_PO_BB)    |
	(i_IO_address == ADRS_PORT_PO_BC)    |
	(i_IO_address == ADRS_PORT_PO_BD)    |
	(i_IO_address == ADRS_PORT_PO_BE)    |
	(i_IO_address == ADRS_PORT_PO_BF)    |
	//
	(i_IO_address ==  ADRS_LAN_WI_00)    |
	(i_IO_address ==  ADRS_LAN_WI_01)    |
	(i_IO_address ==  ADRS_LAN_WO_20)    |
	(i_IO_address ==  ADRS_LAN_WO_21)    |
	(i_IO_address ==  ADRS_LAN_TI_40)    |
	(i_IO_address ==  ADRS_LAN_TI_41)    |
	(i_IO_address ==  ADRS_LAN_TO_60)    |
	(i_IO_address ==  ADRS_LAN_TO_61)    |
	(i_IO_address ==  ADRS_LAN_PI_80)    |
	(i_IO_address ==  ADRS_LAN_PI_81)    |
	(i_IO_address ==  ADRS_LAN_PO_A0)    |
	(i_IO_address ==  ADRS_LAN_PO_A1)    |
	//
	(i_IO_address ==  ADRS_LAN_CONF_00)  |
	(i_IO_address ==  ADRS_LAN_CONF_01)  |
	(i_IO_address ==  ADRS_LAN_CONF_02)  |
	(i_IO_address ==  ADRS_LAN_CONF_03)  |
	//
	(i_IO_address == ADRS_FPGA_IMAGE_ID) |
	(i_IO_address == ADRS_TEST_REG     ) |
	(i_IO_address == ADRS_MASK_ALL     ) |
	(i_IO_address == ADRS_MASK_WI      ) |
	(i_IO_address == ADRS_MASK_WO      ) |
	(i_IO_address == ADRS_MASK_TI      ) |
	(i_IO_address == ADRS_MASK_TO      ) ;
//}

// r_IO_ready_rd //{
reg r_IO_ready_rd;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_ready_rd  <= 1'b0;
	end
	else if (i_IO_addr_strobe & i_IO_read_strobe & w_match_IO_adrs) begin
		r_IO_ready_rd  <= 1'b1;
	end
	else begin 
		r_IO_ready_rd  <= 1'b0;
	end
//}
	
//// o_IO_read_data including PO //{
assign o_IO_read_data = 
	// check pipe out first //{
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A0))? i_port_po_A0 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A1))? i_port_po_A1 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A2))? i_port_po_A2 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A3))? i_port_po_A3 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A4))? i_port_po_A4 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A5))? i_port_po_A5 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A6))? i_port_po_A6 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A7))? i_port_po_A7 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A8))? i_port_po_A8 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_A9))? i_port_po_A9 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AA))? i_port_po_AA :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AB))? i_port_po_AB :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AC))? i_port_po_AC :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AD))? i_port_po_AD :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AE))? i_port_po_AE :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_AF))? i_port_po_AF :
	//
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B0))? i_port_po_B0 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B1))? i_port_po_B1 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B2))? i_port_po_B2 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B3))? i_port_po_B3 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B4))? i_port_po_B4 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B5))? i_port_po_B5 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B6))? i_port_po_B6 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B7))? i_port_po_B7 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B8))? i_port_po_B8 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_B9))? i_port_po_B9 :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BA))? i_port_po_BA :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BB))? i_port_po_BB :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BC))? i_port_po_BC :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BD))? i_port_po_BD :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BE))? i_port_po_BE :
	(r_IO_ready_rd & (r_IO_address == ADRS_PORT_PO_BF))? i_port_po_BF :
	//
	(r_IO_ready_rd & (r_IO_address ==  ADRS_LAN_PO_A0))?  i_lan_po_A0 :
	(r_IO_ready_rd & (r_IO_address ==  ADRS_LAN_PO_A1))?  i_lan_po_A1 :
	//}
	
	// otherwise, connect wi, wo, ti, to. //{
	r_IO_read_data;
	//}

//}
	
	
// r_IO_ready_wr //{
reg r_IO_ready_wr;
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_ready_wr  <= 1'b0;
	end
	else if (i_IO_addr_strobe & i_IO_write_strobe & w_match_IO_adrs) begin
		r_IO_ready_wr  <= 1'b1;
	end
	else begin 
		r_IO_ready_wr  <= 1'b0;
	end
//}
	
//// o_IO_ready
assign o_IO_ready = r_IO_ready_rd | r_IO_ready_wr;

// r_IO_ready_rd_ref //{
reg r_IO_ready_rd_ref;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_ready_rd_ref  <= 1'b0;
	end
	else if (i_IO_addr_strobe & i_IO_read_strobe) begin
		r_IO_ready_rd_ref  <= 1'b1;
	end
	else begin 
		r_IO_ready_rd_ref  <= 1'b0;
	end
//}

// r_IO_ready_wr_ref //{
reg r_IO_ready_wr_ref;
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_ready_wr_ref  <= 1'b0;
	end
	else if (i_IO_addr_strobe & i_IO_write_strobe) begin
		r_IO_ready_wr_ref  <= 1'b1;
	end
	else begin 
		r_IO_ready_wr_ref  <= 1'b0;
	end
//}

//// o_IO_ready_ref // without check address
assign o_IO_ready_ref = r_IO_ready_rd_ref | r_IO_ready_wr_ref;
	
endmodule
