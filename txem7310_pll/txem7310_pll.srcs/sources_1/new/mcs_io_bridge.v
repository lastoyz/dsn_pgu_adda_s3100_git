//------------------------------------------------------------------------
// mcs_io_bridge.v
//  for mb MCS IO bus slave 
//  support MCS end-point
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
module mcs_io_bridge (  
	// 
	input wire clk, // assume clk3_out1_72M
	input wire reset_n,
	//
	// IO bus control from master 
	input  wire          i_IO_addr_strobe  ,
	input  wire [31 : 0] i_IO_address      ,
	input  wire [3 : 0]  i_IO_byte_enable  ,
	output wire [31 : 0] o_IO_read_data    ,
	input  wire          i_IO_read_strobe  ,
	output wire          o_IO_ready        , // IO ready with    address check
	output wire          o_IO_ready_ref    , // IO ready without address check
	input  wire [31 : 0] i_IO_write_data   ,
	input  wire          i_IO_write_strobe ,
	//
	// IO port
	// wire in
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
	// wire out
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
	// trig in
	input  wire i_ck_40, output wire [31:0]   o_port_ti_40 ,
	input  wire i_ck_41, output wire [31:0]   o_port_ti_41 ,
	input  wire i_ck_42, output wire [31:0]   o_port_ti_42 ,
	input  wire i_ck_43, output wire [31:0]   o_port_ti_43 ,
	input  wire i_ck_44, output wire [31:0]   o_port_ti_44 ,
	input  wire i_ck_45, output wire [31:0]   o_port_ti_45 ,
	input  wire i_ck_46, output wire [31:0]   o_port_ti_46 ,
	input  wire i_ck_47, output wire [31:0]   o_port_ti_47 ,
	input  wire i_ck_48, output wire [31:0]   o_port_ti_48 ,
	input  wire i_ck_49, output wire [31:0]   o_port_ti_49 ,
	input  wire i_ck_4A, output wire [31:0]   o_port_ti_4A ,
	input  wire i_ck_4B, output wire [31:0]   o_port_ti_4B ,
	input  wire i_ck_4C, output wire [31:0]   o_port_ti_4C ,
	input  wire i_ck_4D, output wire [31:0]   o_port_ti_4D ,
	input  wire i_ck_4E, output wire [31:0]   o_port_ti_4E ,
	input  wire i_ck_4F, output wire [31:0]   o_port_ti_4F ,
	//
	input  wire i_ck_50, output wire [31:0]   o_port_ti_50 ,
	input  wire i_ck_51, output wire [31:0]   o_port_ti_51 ,
	input  wire i_ck_52, output wire [31:0]   o_port_ti_52 ,
	input  wire i_ck_53, output wire [31:0]   o_port_ti_53 ,
	input  wire i_ck_54, output wire [31:0]   o_port_ti_54 ,
	input  wire i_ck_55, output wire [31:0]   o_port_ti_55 ,
	input  wire i_ck_56, output wire [31:0]   o_port_ti_56 ,
	input  wire i_ck_57, output wire [31:0]   o_port_ti_57 ,
	input  wire i_ck_58, output wire [31:0]   o_port_ti_58 ,
	input  wire i_ck_59, output wire [31:0]   o_port_ti_59 ,
	input  wire i_ck_5A, output wire [31:0]   o_port_ti_5A ,
	input  wire i_ck_5B, output wire [31:0]   o_port_ti_5B ,
	input  wire i_ck_5C, output wire [31:0]   o_port_ti_5C ,
	input  wire i_ck_5D, output wire [31:0]   o_port_ti_5D ,
	input  wire i_ck_5E, output wire [31:0]   o_port_ti_5E ,
	input  wire i_ck_5F, output wire [31:0]   o_port_ti_5F ,
	// trig out
	input  wire i_ck_60, input  wire [31:0]   i_port_to_60 ,
	input  wire i_ck_61, input  wire [31:0]   i_port_to_61 ,
	input  wire i_ck_62, input  wire [31:0]   i_port_to_62 ,
	input  wire i_ck_63, input  wire [31:0]   i_port_to_63 ,
	input  wire i_ck_64, input  wire [31:0]   i_port_to_64 ,
	input  wire i_ck_65, input  wire [31:0]   i_port_to_65 ,
	input  wire i_ck_66, input  wire [31:0]   i_port_to_66 ,
	input  wire i_ck_67, input  wire [31:0]   i_port_to_67 ,
	input  wire i_ck_68, input  wire [31:0]   i_port_to_68 ,
	input  wire i_ck_69, input  wire [31:0]   i_port_to_69 ,
	input  wire i_ck_6A, input  wire [31:0]   i_port_to_6A ,
	input  wire i_ck_6B, input  wire [31:0]   i_port_to_6B ,
	input  wire i_ck_6C, input  wire [31:0]   i_port_to_6C ,
	input  wire i_ck_6D, input  wire [31:0]   i_port_to_6D ,
	input  wire i_ck_6E, input  wire [31:0]   i_port_to_6E ,
	input  wire i_ck_6F, input  wire [31:0]   i_port_to_6F ,
	//
	input  wire i_ck_70, input  wire [31:0]   i_port_to_70 ,
	input  wire i_ck_71, input  wire [31:0]   i_port_to_71 ,
	input  wire i_ck_72, input  wire [31:0]   i_port_to_72 ,
	input  wire i_ck_73, input  wire [31:0]   i_port_to_73 ,
	input  wire i_ck_74, input  wire [31:0]   i_port_to_74 ,
	input  wire i_ck_75, input  wire [31:0]   i_port_to_75 ,
	input  wire i_ck_76, input  wire [31:0]   i_port_to_76 ,
	input  wire i_ck_77, input  wire [31:0]   i_port_to_77 ,
	input  wire i_ck_78, input  wire [31:0]   i_port_to_78 ,
	input  wire i_ck_79, input  wire [31:0]   i_port_to_79 ,
	input  wire i_ck_7A, input  wire [31:0]   i_port_to_7A ,
	input  wire i_ck_7B, input  wire [31:0]   i_port_to_7B ,
	input  wire i_ck_7C, input  wire [31:0]   i_port_to_7C ,
	input  wire i_ck_7D, input  wire [31:0]   i_port_to_7D ,
	input  wire i_ck_7E, input  wire [31:0]   i_port_to_7E ,
	input  wire i_ck_7F, input  wire [31:0]   i_port_to_7F ,
	// pipe in
	output wire o_wr_80, output wire [31:0]   o_port_pi_80 ,
	output wire o_wr_81, output wire [31:0]   o_port_pi_81 ,
	output wire o_wr_82, output wire [31:0]   o_port_pi_82 ,
	output wire o_wr_83, output wire [31:0]   o_port_pi_83 ,
	output wire o_wr_84, output wire [31:0]   o_port_pi_84 ,
	output wire o_wr_85, output wire [31:0]   o_port_pi_85 ,
	output wire o_wr_86, output wire [31:0]   o_port_pi_86 ,
	output wire o_wr_87, output wire [31:0]   o_port_pi_87 ,
	output wire o_wr_88, output wire [31:0]   o_port_pi_88 ,
	output wire o_wr_89, output wire [31:0]   o_port_pi_89 ,
	output wire o_wr_8A, output wire [31:0]   o_port_pi_8A ,
	output wire o_wr_8B, output wire [31:0]   o_port_pi_8B ,
	output wire o_wr_8C, output wire [31:0]   o_port_pi_8C ,
	output wire o_wr_8D, output wire [31:0]   o_port_pi_8D ,
	output wire o_wr_8E, output wire [31:0]   o_port_pi_8E ,
	output wire o_wr_8F, output wire [31:0]   o_port_pi_8F ,
	//
	output wire o_wr_90, output wire [31:0]   o_port_pi_90 ,
	output wire o_wr_91, output wire [31:0]   o_port_pi_91 ,
	output wire o_wr_92, output wire [31:0]   o_port_pi_92 ,
	output wire o_wr_93, output wire [31:0]   o_port_pi_93 ,
	output wire o_wr_94, output wire [31:0]   o_port_pi_94 ,
	output wire o_wr_95, output wire [31:0]   o_port_pi_95 ,
	output wire o_wr_96, output wire [31:0]   o_port_pi_96 ,
	output wire o_wr_97, output wire [31:0]   o_port_pi_97 ,
	output wire o_wr_98, output wire [31:0]   o_port_pi_98 ,
	output wire o_wr_99, output wire [31:0]   o_port_pi_99 ,
	output wire o_wr_9A, output wire [31:0]   o_port_pi_9A ,
	output wire o_wr_9B, output wire [31:0]   o_port_pi_9B ,
	output wire o_wr_9C, output wire [31:0]   o_port_pi_9C ,
	output wire o_wr_9D, output wire [31:0]   o_port_pi_9D ,
	output wire o_wr_9E, output wire [31:0]   o_port_pi_9E ,
	output wire o_wr_9F, output wire [31:0]   o_port_pi_9F ,
	// pipe out
	output wire o_rd_A0, input  wire [31:0]   i_port_po_A0 ,
	output wire o_rd_A1, input  wire [31:0]   i_port_po_A1 ,
	output wire o_rd_A2, input  wire [31:0]   i_port_po_A2 ,
	output wire o_rd_A3, input  wire [31:0]   i_port_po_A3 ,
	output wire o_rd_A4, input  wire [31:0]   i_port_po_A4 ,
	output wire o_rd_A5, input  wire [31:0]   i_port_po_A5 ,
	output wire o_rd_A6, input  wire [31:0]   i_port_po_A6 ,
	output wire o_rd_A7, input  wire [31:0]   i_port_po_A7 ,
	output wire o_rd_A8, input  wire [31:0]   i_port_po_A8 ,
	output wire o_rd_A9, input  wire [31:0]   i_port_po_A9 ,
	output wire o_rd_AA, input  wire [31:0]   i_port_po_AA ,
	output wire o_rd_AB, input  wire [31:0]   i_port_po_AB ,
	output wire o_rd_AC, input  wire [31:0]   i_port_po_AC ,
	output wire o_rd_AD, input  wire [31:0]   i_port_po_AD ,
	output wire o_rd_AE, input  wire [31:0]   i_port_po_AE ,
	output wire o_rd_AF, input  wire [31:0]   i_port_po_AF ,
	//
	output wire o_rd_B0, input  wire [31:0]   i_port_po_B0 ,
	output wire o_rd_B1, input  wire [31:0]   i_port_po_B1 ,
	output wire o_rd_B2, input  wire [31:0]   i_port_po_B2 ,
	output wire o_rd_B3, input  wire [31:0]   i_port_po_B3 ,
	output wire o_rd_B4, input  wire [31:0]   i_port_po_B4 ,
	output wire o_rd_B5, input  wire [31:0]   i_port_po_B5 ,
	output wire o_rd_B6, input  wire [31:0]   i_port_po_B6 ,
	output wire o_rd_B7, input  wire [31:0]   i_port_po_B7 ,
	output wire o_rd_B8, input  wire [31:0]   i_port_po_B8 ,
	output wire o_rd_B9, input  wire [31:0]   i_port_po_B9 ,
	output wire o_rd_BA, input  wire [31:0]   i_port_po_BA ,
	output wire o_rd_BB, input  wire [31:0]   i_port_po_BB ,
	output wire o_rd_BC, input  wire [31:0]   i_port_po_BC ,
	output wire o_rd_BD, input  wire [31:0]   i_port_po_BD ,
	output wire o_rd_BE, input  wire [31:0]   i_port_po_BE ,
	output wire o_rd_BF, input  wire [31:0]   i_port_po_BF ,
	//
	// flag
	output wire valid
);

// parameters from outside
parameter XPAR_IOMODULE_IO_BASEADDR   = 32'h_C000_0000; 
parameter MCS_IO_INST_OFFSET          = 32'h_0000_0000; // 32'h_0001_0000
parameter FPGA_IMAGE_ID               = 32'h_FBFB_FBFB;  

// inner parameters
parameter INIT_IO_data = 32'h_ACAC_C8C8;

//// parameters for register offsets
parameter ADRS_BASE              = XPAR_IOMODULE_IO_BASEADDR + MCS_IO_INST_OFFSET; 
//parameter ADRS_END               = XPAR_IOMODULE_IO_BASEADDR + 32'h_3FFF_FFFF; 
//
//$$ Endpoints
// Wire In 		0x00 - 0x1F  // output wire [31:0]
// Wire Out 	0x20 - 0x3F  // input wire [31:0]
// Trigger In 	0x40 - 0x5F  // input wire, output wire [31:0],
// Trigger Out 	0x60 - 0x7F  // input wire, input wire [31:0],
// Pipe In 		0x80 - 0x9F  // output wire, output wire [31:0],
// Pipe Out 	0xA0 - 0xBF  // output wire, input wire [31:0],
//
// wire in
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
// wire out
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
// trig in 
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
// trig out
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
// pipe in 
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
// pipe out
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
// control 
parameter ADRS_FPGA_IMAGE_ID     = ADRS_BASE + 32'h_0000_0F00;
parameter ADRS_TEST_REG          = ADRS_BASE + 32'h_0000_0F04;
parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14;
parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18;
parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C;


// valid 
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


// r_test 
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
	

// r_mask_X
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
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_MASK_WI)) begin r_mask_wi <= i_IO_write_data; end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_MASK_WO)) begin r_mask_wo <= i_IO_write_data; end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_MASK_TI)) begin r_mask_ti <= i_IO_write_data; end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_MASK_TO)) begin r_mask_to <= i_IO_write_data; end	
	
// o_port_wi_X
reg [31:0] r_port_wi_00;
reg [31:0] r_port_wi_01;
reg [31:0] r_port_wi_02;
reg [31:0] r_port_wi_03;
reg [31:0] r_port_wi_04;
reg [31:0] r_port_wi_05;
reg [31:0] r_port_wi_06;
reg [31:0] r_port_wi_07;
reg [31:0] r_port_wi_08;
reg [31:0] r_port_wi_09;
reg [31:0] r_port_wi_0A;
reg [31:0] r_port_wi_0B;
reg [31:0] r_port_wi_0C;
reg [31:0] r_port_wi_0D;
reg [31:0] r_port_wi_0E;
reg [31:0] r_port_wi_0F;
//
reg [31:0] r_port_wi_10;
reg [31:0] r_port_wi_11;
reg [31:0] r_port_wi_12;
reg [31:0] r_port_wi_13;
reg [31:0] r_port_wi_14;
reg [31:0] r_port_wi_15;
reg [31:0] r_port_wi_16;
reg [31:0] r_port_wi_17;
reg [31:0] r_port_wi_18;
reg [31:0] r_port_wi_19;
reg [31:0] r_port_wi_1A;
reg [31:0] r_port_wi_1B;
reg [31:0] r_port_wi_1C;
reg [31:0] r_port_wi_1D;
reg [31:0] r_port_wi_1E;
reg [31:0] r_port_wi_1F;
//
assign o_port_wi_00 = r_port_wi_00;
assign o_port_wi_01 = r_port_wi_01;
assign o_port_wi_02 = r_port_wi_02;
assign o_port_wi_03 = r_port_wi_03;
assign o_port_wi_04 = r_port_wi_04;
assign o_port_wi_05 = r_port_wi_05;
assign o_port_wi_06 = r_port_wi_06;
assign o_port_wi_07 = r_port_wi_07;
assign o_port_wi_08 = r_port_wi_08;
assign o_port_wi_09 = r_port_wi_09;
assign o_port_wi_0A = r_port_wi_0A;
assign o_port_wi_0B = r_port_wi_0B;
assign o_port_wi_0C = r_port_wi_0C;
assign o_port_wi_0D = r_port_wi_0D;
assign o_port_wi_0E = r_port_wi_0E;
assign o_port_wi_0F = r_port_wi_0F;
//
assign o_port_wi_10 = r_port_wi_10;
assign o_port_wi_11 = r_port_wi_11;
assign o_port_wi_12 = r_port_wi_12;
assign o_port_wi_13 = r_port_wi_13;
assign o_port_wi_14 = r_port_wi_14;
assign o_port_wi_15 = r_port_wi_15;
assign o_port_wi_16 = r_port_wi_16;
assign o_port_wi_17 = r_port_wi_17;
assign o_port_wi_18 = r_port_wi_18;
assign o_port_wi_19 = r_port_wi_19;
assign o_port_wi_1A = r_port_wi_1A;
assign o_port_wi_1B = r_port_wi_1B;
assign o_port_wi_1C = r_port_wi_1C;
assign o_port_wi_1D = r_port_wi_1D;
assign o_port_wi_1E = r_port_wi_1E;
assign o_port_wi_1F = r_port_wi_1F;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_wi_00 <= 32'b0;
		r_port_wi_01 <= 32'b0;
		r_port_wi_02 <= 32'b0;
		r_port_wi_03 <= 32'b0;
		r_port_wi_04 <= 32'b0;
		r_port_wi_05 <= 32'b0;
		r_port_wi_06 <= 32'b0;
		r_port_wi_07 <= 32'b0;
		r_port_wi_08 <= 32'b0;
		r_port_wi_09 <= 32'b0;
		r_port_wi_0A <= 32'b0;
		r_port_wi_0B <= 32'b0;
		r_port_wi_0C <= 32'b0;
		r_port_wi_0D <= 32'b0;
		r_port_wi_0E <= 32'b0;
		r_port_wi_0F <= 32'b0;
		//
		r_port_wi_10 <= 32'b0;
		r_port_wi_11 <= 32'b0;
		r_port_wi_12 <= 32'b0;
		r_port_wi_13 <= 32'b0;
		r_port_wi_14 <= 32'b0;
		r_port_wi_15 <= 32'b0;
		r_port_wi_16 <= 32'b0;
		r_port_wi_17 <= 32'b0;
		r_port_wi_18 <= 32'b0;
		r_port_wi_19 <= 32'b0;
		r_port_wi_1A <= 32'b0;
		r_port_wi_1B <= 32'b0;
		r_port_wi_1C <= 32'b0;
		r_port_wi_1D <= 32'b0;
		r_port_wi_1E <= 32'b0;
		r_port_wi_1F <= 32'b0;
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
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_00)) begin r_port_wi_00 <= (r_port_wi_00&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_01)) begin r_port_wi_01 <= (r_port_wi_01&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_02)) begin r_port_wi_02 <= (r_port_wi_02&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_03)) begin r_port_wi_03 <= (r_port_wi_03&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_04)) begin r_port_wi_04 <= (r_port_wi_04&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_05)) begin r_port_wi_05 <= (r_port_wi_05&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_06)) begin r_port_wi_06 <= (r_port_wi_06&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_07)) begin r_port_wi_07 <= (r_port_wi_07&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_08)) begin r_port_wi_08 <= (r_port_wi_08&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_09)) begin r_port_wi_09 <= (r_port_wi_09&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0A)) begin r_port_wi_0A <= (r_port_wi_0A&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0B)) begin r_port_wi_0B <= (r_port_wi_0B&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0C)) begin r_port_wi_0C <= (r_port_wi_0C&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0D)) begin r_port_wi_0D <= (r_port_wi_0D&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0E)) begin r_port_wi_0E <= (r_port_wi_0E&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_0F)) begin r_port_wi_0F <= (r_port_wi_0F&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	//
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_10)) begin r_port_wi_10 <= (r_port_wi_10&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_11)) begin r_port_wi_11 <= (r_port_wi_11&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_12)) begin r_port_wi_12 <= (r_port_wi_12&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_13)) begin r_port_wi_13 <= (r_port_wi_13&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_14)) begin r_port_wi_14 <= (r_port_wi_14&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_15)) begin r_port_wi_15 <= (r_port_wi_15&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_16)) begin r_port_wi_16 <= (r_port_wi_16&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_17)) begin r_port_wi_17 <= (r_port_wi_17&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_18)) begin r_port_wi_18 <= (r_port_wi_18&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_19)) begin r_port_wi_19 <= (r_port_wi_19&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1A)) begin r_port_wi_1A <= (r_port_wi_1A&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1B)) begin r_port_wi_1B <= (r_port_wi_1B&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1C)) begin r_port_wi_1C <= (r_port_wi_1C&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1D)) begin r_port_wi_1D <= (r_port_wi_1D&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1E)) begin r_port_wi_1E <= (r_port_wi_1E&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end
	else if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_WI_1F)) begin r_port_wi_1F <= (r_port_wi_1F&(~r_mask_wi)) | (i_IO_write_data&r_mask_wi); end

// input  wire i_ck_40, output wire [31:0]   o_port_ti_40 ,
reg [31:0] r_port_ti_40; reg [31:0] r_port_ti_40_smp; reg [31:0] r_port_ti_40_smpp;
reg [31:0] r_port_ti_41; reg [31:0] r_port_ti_41_smp; reg [31:0] r_port_ti_41_smpp;
reg [31:0] r_port_ti_42; reg [31:0] r_port_ti_42_smp; reg [31:0] r_port_ti_42_smpp;
reg [31:0] r_port_ti_43; reg [31:0] r_port_ti_43_smp; reg [31:0] r_port_ti_43_smpp;
reg [31:0] r_port_ti_44; reg [31:0] r_port_ti_44_smp; reg [31:0] r_port_ti_44_smpp;
reg [31:0] r_port_ti_45; reg [31:0] r_port_ti_45_smp; reg [31:0] r_port_ti_45_smpp;
reg [31:0] r_port_ti_46; reg [31:0] r_port_ti_46_smp; reg [31:0] r_port_ti_46_smpp;
reg [31:0] r_port_ti_47; reg [31:0] r_port_ti_47_smp; reg [31:0] r_port_ti_47_smpp;
reg [31:0] r_port_ti_48; reg [31:0] r_port_ti_48_smp; reg [31:0] r_port_ti_48_smpp;
reg [31:0] r_port_ti_49; reg [31:0] r_port_ti_49_smp; reg [31:0] r_port_ti_49_smpp;
reg [31:0] r_port_ti_4A; reg [31:0] r_port_ti_4A_smp; reg [31:0] r_port_ti_4A_smpp;
reg [31:0] r_port_ti_4B; reg [31:0] r_port_ti_4B_smp; reg [31:0] r_port_ti_4B_smpp;
reg [31:0] r_port_ti_4C; reg [31:0] r_port_ti_4C_smp; reg [31:0] r_port_ti_4C_smpp;
reg [31:0] r_port_ti_4D; reg [31:0] r_port_ti_4D_smp; reg [31:0] r_port_ti_4D_smpp;
reg [31:0] r_port_ti_4E; reg [31:0] r_port_ti_4E_smp; reg [31:0] r_port_ti_4E_smpp;
reg [31:0] r_port_ti_4F; reg [31:0] r_port_ti_4F_smp; reg [31:0] r_port_ti_4F_smpp;
//
reg [31:0] r_port_ti_50; reg [31:0] r_port_ti_50_smp; reg [31:0] r_port_ti_50_smpp;
reg [31:0] r_port_ti_51; reg [31:0] r_port_ti_51_smp; reg [31:0] r_port_ti_51_smpp;
reg [31:0] r_port_ti_52; reg [31:0] r_port_ti_52_smp; reg [31:0] r_port_ti_52_smpp;
reg [31:0] r_port_ti_53; reg [31:0] r_port_ti_53_smp; reg [31:0] r_port_ti_53_smpp;
reg [31:0] r_port_ti_54; reg [31:0] r_port_ti_54_smp; reg [31:0] r_port_ti_54_smpp;
reg [31:0] r_port_ti_55; reg [31:0] r_port_ti_55_smp; reg [31:0] r_port_ti_55_smpp;
reg [31:0] r_port_ti_56; reg [31:0] r_port_ti_56_smp; reg [31:0] r_port_ti_56_smpp;
reg [31:0] r_port_ti_57; reg [31:0] r_port_ti_57_smp; reg [31:0] r_port_ti_57_smpp;
reg [31:0] r_port_ti_58; reg [31:0] r_port_ti_58_smp; reg [31:0] r_port_ti_58_smpp;
reg [31:0] r_port_ti_59; reg [31:0] r_port_ti_59_smp; reg [31:0] r_port_ti_59_smpp;
reg [31:0] r_port_ti_5A; reg [31:0] r_port_ti_5A_smp; reg [31:0] r_port_ti_5A_smpp;
reg [31:0] r_port_ti_5B; reg [31:0] r_port_ti_5B_smp; reg [31:0] r_port_ti_5B_smpp;
reg [31:0] r_port_ti_5C; reg [31:0] r_port_ti_5C_smp; reg [31:0] r_port_ti_5C_smpp;
reg [31:0] r_port_ti_5D; reg [31:0] r_port_ti_5D_smp; reg [31:0] r_port_ti_5D_smpp;
reg [31:0] r_port_ti_5E; reg [31:0] r_port_ti_5E_smp; reg [31:0] r_port_ti_5E_smpp;
reg [31:0] r_port_ti_5F; reg [31:0] r_port_ti_5F_smp; reg [31:0] r_port_ti_5F_smpp;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_40 <= 32'b0;
		r_port_ti_41 <= 32'b0;
		r_port_ti_42 <= 32'b0;
		r_port_ti_43 <= 32'b0;
		r_port_ti_44 <= 32'b0;
		r_port_ti_45 <= 32'b0;
		r_port_ti_46 <= 32'b0;
		r_port_ti_47 <= 32'b0;
		r_port_ti_48 <= 32'b0;
		r_port_ti_49 <= 32'b0;
		r_port_ti_4A <= 32'b0;
		r_port_ti_4B <= 32'b0;
		r_port_ti_4C <= 32'b0;
		r_port_ti_4D <= 32'b0;
		r_port_ti_4E <= 32'b0;
		r_port_ti_4F <= 32'b0;
		//
		r_port_ti_50 <= 32'b0;
		r_port_ti_51 <= 32'b0;
		r_port_ti_52 <= 32'b0;
		r_port_ti_53 <= 32'b0;
		r_port_ti_54 <= 32'b0;
		r_port_ti_55 <= 32'b0;
		r_port_ti_56 <= 32'b0;
		r_port_ti_57 <= 32'b0;
		r_port_ti_58 <= 32'b0;
		r_port_ti_59 <= 32'b0;
		r_port_ti_5A <= 32'b0;
		r_port_ti_5B <= 32'b0;
		r_port_ti_5C <= 32'b0;
		r_port_ti_5D <= 32'b0;
		r_port_ti_5E <= 32'b0;
		r_port_ti_5F <= 32'b0;
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
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_40)) begin r_port_ti_40 <= (r_port_ti_40&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_40 <= r_port_ti_40 & (~r_port_ti_40_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_41)) begin r_port_ti_41 <= (r_port_ti_41&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_41 <= r_port_ti_41 & (~r_port_ti_41_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_42)) begin r_port_ti_42 <= (r_port_ti_42&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_42 <= r_port_ti_42 & (~r_port_ti_42_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_43)) begin r_port_ti_43 <= (r_port_ti_43&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_43 <= r_port_ti_43 & (~r_port_ti_43_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_44)) begin r_port_ti_44 <= (r_port_ti_44&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_44 <= r_port_ti_44 & (~r_port_ti_44_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_45)) begin r_port_ti_45 <= (r_port_ti_45&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_45 <= r_port_ti_45 & (~r_port_ti_45_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_46)) begin r_port_ti_46 <= (r_port_ti_46&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_46 <= r_port_ti_46 & (~r_port_ti_46_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_47)) begin r_port_ti_47 <= (r_port_ti_47&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_47 <= r_port_ti_47 & (~r_port_ti_47_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_48)) begin r_port_ti_48 <= (r_port_ti_48&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_48 <= r_port_ti_48 & (~r_port_ti_48_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_49)) begin r_port_ti_49 <= (r_port_ti_49&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_49 <= r_port_ti_49 & (~r_port_ti_49_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4A)) begin r_port_ti_4A <= (r_port_ti_4A&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4A <= r_port_ti_4A & (~r_port_ti_4A_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4B)) begin r_port_ti_4B <= (r_port_ti_4B&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4B <= r_port_ti_4B & (~r_port_ti_4B_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4C)) begin r_port_ti_4C <= (r_port_ti_4C&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4C <= r_port_ti_4C & (~r_port_ti_4C_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4D)) begin r_port_ti_4D <= (r_port_ti_4D&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4D <= r_port_ti_4D & (~r_port_ti_4D_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4E)) begin r_port_ti_4E <= (r_port_ti_4E&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4E <= r_port_ti_4E & (~r_port_ti_4E_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_4F)) begin r_port_ti_4F <= (r_port_ti_4F&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_4F <= r_port_ti_4F & (~r_port_ti_4F_smp); end
		//
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_50)) begin r_port_ti_50 <= (r_port_ti_50&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_50 <= r_port_ti_50 & (~r_port_ti_50_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_51)) begin r_port_ti_51 <= (r_port_ti_51&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_51 <= r_port_ti_51 & (~r_port_ti_51_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_52)) begin r_port_ti_52 <= (r_port_ti_52&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_52 <= r_port_ti_52 & (~r_port_ti_52_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_53)) begin r_port_ti_53 <= (r_port_ti_53&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_53 <= r_port_ti_53 & (~r_port_ti_53_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_54)) begin r_port_ti_54 <= (r_port_ti_54&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_54 <= r_port_ti_54 & (~r_port_ti_54_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_55)) begin r_port_ti_55 <= (r_port_ti_55&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_55 <= r_port_ti_55 & (~r_port_ti_55_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_56)) begin r_port_ti_56 <= (r_port_ti_56&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_56 <= r_port_ti_56 & (~r_port_ti_56_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_57)) begin r_port_ti_57 <= (r_port_ti_57&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_57 <= r_port_ti_57 & (~r_port_ti_57_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_58)) begin r_port_ti_58 <= (r_port_ti_58&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_58 <= r_port_ti_58 & (~r_port_ti_58_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_59)) begin r_port_ti_59 <= (r_port_ti_59&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_59 <= r_port_ti_59 & (~r_port_ti_59_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5A)) begin r_port_ti_5A <= (r_port_ti_5A&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5A <= r_port_ti_5A & (~r_port_ti_5A_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5B)) begin r_port_ti_5B <= (r_port_ti_5B&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5B <= r_port_ti_5B & (~r_port_ti_5B_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5C)) begin r_port_ti_5C <= (r_port_ti_5C&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5C <= r_port_ti_5C & (~r_port_ti_5C_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5D)) begin r_port_ti_5D <= (r_port_ti_5D&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5D <= r_port_ti_5D & (~r_port_ti_5D_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5E)) begin r_port_ti_5E <= (r_port_ti_5E&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5E <= r_port_ti_5E & (~r_port_ti_5E_smp); end
		if (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_TI_5F)) begin r_port_ti_5F <= (r_port_ti_5F&(~r_mask_ti)) | (i_IO_write_data&r_mask_ti); end  else begin r_port_ti_5F <= r_port_ti_5F & (~r_port_ti_5F_smp); end
	end
//
always @(posedge i_ck_40, negedge reset_n)	if (!reset_n) begin r_port_ti_40_smp  <= 32'b0; r_port_ti_40_smpp <= 32'b0; end  else begin r_port_ti_40_smp  <= r_port_ti_40; r_port_ti_40_smpp <= r_port_ti_40_smp; end
always @(posedge i_ck_41, negedge reset_n)	if (!reset_n) begin r_port_ti_41_smp  <= 32'b0; r_port_ti_41_smpp <= 32'b0; end  else begin r_port_ti_41_smp  <= r_port_ti_41; r_port_ti_41_smpp <= r_port_ti_41_smp; end
always @(posedge i_ck_42, negedge reset_n)	if (!reset_n) begin r_port_ti_42_smp  <= 32'b0; r_port_ti_42_smpp <= 32'b0; end  else begin r_port_ti_42_smp  <= r_port_ti_42; r_port_ti_42_smpp <= r_port_ti_42_smp; end
always @(posedge i_ck_43, negedge reset_n)	if (!reset_n) begin r_port_ti_43_smp  <= 32'b0; r_port_ti_43_smpp <= 32'b0; end  else begin r_port_ti_43_smp  <= r_port_ti_43; r_port_ti_43_smpp <= r_port_ti_43_smp; end
always @(posedge i_ck_44, negedge reset_n)	if (!reset_n) begin r_port_ti_44_smp  <= 32'b0; r_port_ti_44_smpp <= 32'b0; end  else begin r_port_ti_44_smp  <= r_port_ti_44; r_port_ti_44_smpp <= r_port_ti_44_smp; end
always @(posedge i_ck_45, negedge reset_n)	if (!reset_n) begin r_port_ti_45_smp  <= 32'b0; r_port_ti_45_smpp <= 32'b0; end  else begin r_port_ti_45_smp  <= r_port_ti_45; r_port_ti_45_smpp <= r_port_ti_45_smp; end
always @(posedge i_ck_46, negedge reset_n)	if (!reset_n) begin r_port_ti_46_smp  <= 32'b0; r_port_ti_46_smpp <= 32'b0; end  else begin r_port_ti_46_smp  <= r_port_ti_46; r_port_ti_46_smpp <= r_port_ti_46_smp; end
always @(posedge i_ck_47, negedge reset_n)	if (!reset_n) begin r_port_ti_47_smp  <= 32'b0; r_port_ti_47_smpp <= 32'b0; end  else begin r_port_ti_47_smp  <= r_port_ti_47; r_port_ti_47_smpp <= r_port_ti_47_smp; end
always @(posedge i_ck_48, negedge reset_n)	if (!reset_n) begin r_port_ti_48_smp  <= 32'b0; r_port_ti_48_smpp <= 32'b0; end  else begin r_port_ti_48_smp  <= r_port_ti_48; r_port_ti_48_smpp <= r_port_ti_48_smp; end
always @(posedge i_ck_49, negedge reset_n)	if (!reset_n) begin r_port_ti_49_smp  <= 32'b0; r_port_ti_49_smpp <= 32'b0; end  else begin r_port_ti_49_smp  <= r_port_ti_49; r_port_ti_49_smpp <= r_port_ti_49_smp; end
always @(posedge i_ck_4A, negedge reset_n)	if (!reset_n) begin r_port_ti_4A_smp  <= 32'b0; r_port_ti_4A_smpp <= 32'b0; end  else begin r_port_ti_4A_smp  <= r_port_ti_4A; r_port_ti_4A_smpp <= r_port_ti_4A_smp; end
always @(posedge i_ck_4B, negedge reset_n)	if (!reset_n) begin r_port_ti_4B_smp  <= 32'b0; r_port_ti_4B_smpp <= 32'b0; end  else begin r_port_ti_4B_smp  <= r_port_ti_4B; r_port_ti_4B_smpp <= r_port_ti_4B_smp; end
always @(posedge i_ck_4C, negedge reset_n)	if (!reset_n) begin r_port_ti_4C_smp  <= 32'b0; r_port_ti_4C_smpp <= 32'b0; end  else begin r_port_ti_4C_smp  <= r_port_ti_4C; r_port_ti_4C_smpp <= r_port_ti_4C_smp; end
always @(posedge i_ck_4D, negedge reset_n)	if (!reset_n) begin r_port_ti_4D_smp  <= 32'b0; r_port_ti_4D_smpp <= 32'b0; end  else begin r_port_ti_4D_smp  <= r_port_ti_4D; r_port_ti_4D_smpp <= r_port_ti_4D_smp; end
always @(posedge i_ck_4E, negedge reset_n)	if (!reset_n) begin r_port_ti_4E_smp  <= 32'b0; r_port_ti_4E_smpp <= 32'b0; end  else begin r_port_ti_4E_smp  <= r_port_ti_4E; r_port_ti_4E_smpp <= r_port_ti_4E_smp; end
always @(posedge i_ck_4F, negedge reset_n)	if (!reset_n) begin r_port_ti_4F_smp  <= 32'b0; r_port_ti_4F_smpp <= 32'b0; end  else begin r_port_ti_4F_smp  <= r_port_ti_4F; r_port_ti_4F_smpp <= r_port_ti_4F_smp; end
//	//                                                                                          //
always @(posedge i_ck_50, negedge reset_n)	if (!reset_n) begin r_port_ti_50_smp  <= 32'b0; r_port_ti_50_smpp <= 32'b0; end  else begin r_port_ti_50_smp  <= r_port_ti_50; r_port_ti_50_smpp <= r_port_ti_50_smp; end
always @(posedge i_ck_51, negedge reset_n)	if (!reset_n) begin r_port_ti_51_smp  <= 32'b0; r_port_ti_51_smpp <= 32'b0; end  else begin r_port_ti_51_smp  <= r_port_ti_51; r_port_ti_51_smpp <= r_port_ti_51_smp; end
always @(posedge i_ck_52, negedge reset_n)	if (!reset_n) begin r_port_ti_52_smp  <= 32'b0; r_port_ti_52_smpp <= 32'b0; end  else begin r_port_ti_52_smp  <= r_port_ti_52; r_port_ti_52_smpp <= r_port_ti_52_smp; end
always @(posedge i_ck_53, negedge reset_n)	if (!reset_n) begin r_port_ti_53_smp  <= 32'b0; r_port_ti_53_smpp <= 32'b0; end  else begin r_port_ti_53_smp  <= r_port_ti_53; r_port_ti_53_smpp <= r_port_ti_53_smp; end
always @(posedge i_ck_54, negedge reset_n)	if (!reset_n) begin r_port_ti_54_smp  <= 32'b0; r_port_ti_54_smpp <= 32'b0; end  else begin r_port_ti_54_smp  <= r_port_ti_54; r_port_ti_54_smpp <= r_port_ti_54_smp; end
always @(posedge i_ck_55, negedge reset_n)	if (!reset_n) begin r_port_ti_55_smp  <= 32'b0; r_port_ti_55_smpp <= 32'b0; end  else begin r_port_ti_55_smp  <= r_port_ti_55; r_port_ti_55_smpp <= r_port_ti_55_smp; end
always @(posedge i_ck_56, negedge reset_n)	if (!reset_n) begin r_port_ti_56_smp  <= 32'b0; r_port_ti_56_smpp <= 32'b0; end  else begin r_port_ti_56_smp  <= r_port_ti_56; r_port_ti_56_smpp <= r_port_ti_56_smp; end
always @(posedge i_ck_57, negedge reset_n)	if (!reset_n) begin r_port_ti_57_smp  <= 32'b0; r_port_ti_57_smpp <= 32'b0; end  else begin r_port_ti_57_smp  <= r_port_ti_57; r_port_ti_57_smpp <= r_port_ti_57_smp; end
always @(posedge i_ck_58, negedge reset_n)	if (!reset_n) begin r_port_ti_58_smp  <= 32'b0; r_port_ti_58_smpp <= 32'b0; end  else begin r_port_ti_58_smp  <= r_port_ti_58; r_port_ti_58_smpp <= r_port_ti_58_smp; end
always @(posedge i_ck_59, negedge reset_n)	if (!reset_n) begin r_port_ti_59_smp  <= 32'b0; r_port_ti_59_smpp <= 32'b0; end  else begin r_port_ti_59_smp  <= r_port_ti_59; r_port_ti_59_smpp <= r_port_ti_59_smp; end
always @(posedge i_ck_5A, negedge reset_n)	if (!reset_n) begin r_port_ti_5A_smp  <= 32'b0; r_port_ti_5A_smpp <= 32'b0; end  else begin r_port_ti_5A_smp  <= r_port_ti_5A; r_port_ti_5A_smpp <= r_port_ti_5A_smp; end
always @(posedge i_ck_5B, negedge reset_n)	if (!reset_n) begin r_port_ti_5B_smp  <= 32'b0; r_port_ti_5B_smpp <= 32'b0; end  else begin r_port_ti_5B_smp  <= r_port_ti_5B; r_port_ti_5B_smpp <= r_port_ti_5B_smp; end
always @(posedge i_ck_5C, negedge reset_n)	if (!reset_n) begin r_port_ti_5C_smp  <= 32'b0; r_port_ti_5C_smpp <= 32'b0; end  else begin r_port_ti_5C_smp  <= r_port_ti_5C; r_port_ti_5C_smpp <= r_port_ti_5C_smp; end
always @(posedge i_ck_5D, negedge reset_n)	if (!reset_n) begin r_port_ti_5D_smp  <= 32'b0; r_port_ti_5D_smpp <= 32'b0; end  else begin r_port_ti_5D_smp  <= r_port_ti_5D; r_port_ti_5D_smpp <= r_port_ti_5D_smp; end
always @(posedge i_ck_5E, negedge reset_n)	if (!reset_n) begin r_port_ti_5E_smp  <= 32'b0; r_port_ti_5E_smpp <= 32'b0; end  else begin r_port_ti_5E_smp  <= r_port_ti_5E; r_port_ti_5E_smpp <= r_port_ti_5E_smp; end
always @(posedge i_ck_5F, negedge reset_n)	if (!reset_n) begin r_port_ti_5F_smp  <= 32'b0; r_port_ti_5F_smpp <= 32'b0; end  else begin r_port_ti_5F_smp  <= r_port_ti_5F; r_port_ti_5F_smpp <= r_port_ti_5F_smp; end
//
assign o_port_ti_40 = (~r_port_ti_40_smp) & r_port_ti_40_smpp;
assign o_port_ti_41 = (~r_port_ti_41_smp) & r_port_ti_41_smpp;
assign o_port_ti_42 = (~r_port_ti_42_smp) & r_port_ti_42_smpp;
assign o_port_ti_43 = (~r_port_ti_43_smp) & r_port_ti_43_smpp;
assign o_port_ti_44 = (~r_port_ti_44_smp) & r_port_ti_44_smpp;
assign o_port_ti_45 = (~r_port_ti_45_smp) & r_port_ti_45_smpp;
assign o_port_ti_46 = (~r_port_ti_46_smp) & r_port_ti_46_smpp;
assign o_port_ti_47 = (~r_port_ti_47_smp) & r_port_ti_47_smpp;
assign o_port_ti_48 = (~r_port_ti_48_smp) & r_port_ti_48_smpp;
assign o_port_ti_49 = (~r_port_ti_49_smp) & r_port_ti_49_smpp;
assign o_port_ti_4A = (~r_port_ti_4A_smp) & r_port_ti_4A_smpp;
assign o_port_ti_4B = (~r_port_ti_4B_smp) & r_port_ti_4B_smpp;
assign o_port_ti_4C = (~r_port_ti_4C_smp) & r_port_ti_4C_smpp;
assign o_port_ti_4D = (~r_port_ti_4D_smp) & r_port_ti_4D_smpp;
assign o_port_ti_4E = (~r_port_ti_4E_smp) & r_port_ti_4E_smpp;
assign o_port_ti_4F = (~r_port_ti_4F_smp) & r_port_ti_4F_smpp;
//
assign o_port_ti_50 = (~r_port_ti_50_smp) & r_port_ti_50_smpp;
assign o_port_ti_51 = (~r_port_ti_51_smp) & r_port_ti_51_smpp;
assign o_port_ti_52 = (~r_port_ti_52_smp) & r_port_ti_52_smpp;
assign o_port_ti_53 = (~r_port_ti_53_smp) & r_port_ti_53_smpp;
assign o_port_ti_54 = (~r_port_ti_54_smp) & r_port_ti_54_smpp;
assign o_port_ti_55 = (~r_port_ti_55_smp) & r_port_ti_55_smpp;
assign o_port_ti_56 = (~r_port_ti_56_smp) & r_port_ti_56_smpp;
assign o_port_ti_57 = (~r_port_ti_57_smp) & r_port_ti_57_smpp;
assign o_port_ti_58 = (~r_port_ti_58_smp) & r_port_ti_58_smpp;
assign o_port_ti_59 = (~r_port_ti_59_smp) & r_port_ti_59_smpp;
assign o_port_ti_5A = (~r_port_ti_5A_smp) & r_port_ti_5A_smpp;
assign o_port_ti_5B = (~r_port_ti_5B_smp) & r_port_ti_5B_smpp;
assign o_port_ti_5C = (~r_port_ti_5C_smp) & r_port_ti_5C_smpp;
assign o_port_ti_5D = (~r_port_ti_5D_smp) & r_port_ti_5D_smpp;
assign o_port_ti_5E = (~r_port_ti_5E_smp) & r_port_ti_5E_smpp;
assign o_port_ti_5F = (~r_port_ti_5F_smp) & r_port_ti_5F_smpp;


// input  wire i_ck_60, input  wire [31:0]   i_port_to_60 ,
reg [31:0] r_port_to_60; reg [31:0] r_port_to_60_smp;
reg [31:0] r_port_to_61; reg [31:0] r_port_to_61_smp;
reg [31:0] r_port_to_62; reg [31:0] r_port_to_62_smp;
reg [31:0] r_port_to_63; reg [31:0] r_port_to_63_smp;
reg [31:0] r_port_to_64; reg [31:0] r_port_to_64_smp;
reg [31:0] r_port_to_65; reg [31:0] r_port_to_65_smp;
reg [31:0] r_port_to_66; reg [31:0] r_port_to_66_smp;
reg [31:0] r_port_to_67; reg [31:0] r_port_to_67_smp;
reg [31:0] r_port_to_68; reg [31:0] r_port_to_68_smp;
reg [31:0] r_port_to_69; reg [31:0] r_port_to_69_smp;
reg [31:0] r_port_to_6A; reg [31:0] r_port_to_6A_smp;
reg [31:0] r_port_to_6B; reg [31:0] r_port_to_6B_smp;
reg [31:0] r_port_to_6C; reg [31:0] r_port_to_6C_smp;
reg [31:0] r_port_to_6D; reg [31:0] r_port_to_6D_smp;
reg [31:0] r_port_to_6E; reg [31:0] r_port_to_6E_smp;
reg [31:0] r_port_to_6F; reg [31:0] r_port_to_6F_smp;
//
reg [31:0] r_port_to_70; reg [31:0] r_port_to_70_smp;
reg [31:0] r_port_to_71; reg [31:0] r_port_to_71_smp;
reg [31:0] r_port_to_72; reg [31:0] r_port_to_72_smp;
reg [31:0] r_port_to_73; reg [31:0] r_port_to_73_smp;
reg [31:0] r_port_to_74; reg [31:0] r_port_to_74_smp;
reg [31:0] r_port_to_75; reg [31:0] r_port_to_75_smp;
reg [31:0] r_port_to_76; reg [31:0] r_port_to_76_smp;
reg [31:0] r_port_to_77; reg [31:0] r_port_to_77_smp;
reg [31:0] r_port_to_78; reg [31:0] r_port_to_78_smp;
reg [31:0] r_port_to_79; reg [31:0] r_port_to_79_smp;
reg [31:0] r_port_to_7A; reg [31:0] r_port_to_7A_smp;
reg [31:0] r_port_to_7B; reg [31:0] r_port_to_7B_smp;
reg [31:0] r_port_to_7C; reg [31:0] r_port_to_7C_smp;
reg [31:0] r_port_to_7D; reg [31:0] r_port_to_7D_smp;
reg [31:0] r_port_to_7E; reg [31:0] r_port_to_7E_smp;
reg [31:0] r_port_to_7F; reg [31:0] r_port_to_7F_smp;
//
always @(posedge i_ck_60, negedge reset_n)	if (!reset_n) begin	r_port_to_60  <= 32'b0; end  else begin r_port_to_60  <= ( (~r_port_to_60)&i_port_to_60 ) | ( r_port_to_60&(~r_port_to_60_smp) ) ; end
always @(posedge i_ck_61, negedge reset_n)	if (!reset_n) begin	r_port_to_61  <= 32'b0; end  else begin r_port_to_61  <= ( (~r_port_to_61)&i_port_to_61 ) | ( r_port_to_61&(~r_port_to_61_smp) ) ; end
always @(posedge i_ck_62, negedge reset_n)	if (!reset_n) begin	r_port_to_62  <= 32'b0; end  else begin r_port_to_62  <= ( (~r_port_to_62)&i_port_to_62 ) | ( r_port_to_62&(~r_port_to_62_smp) ) ; end
always @(posedge i_ck_63, negedge reset_n)	if (!reset_n) begin	r_port_to_63  <= 32'b0; end  else begin r_port_to_63  <= ( (~r_port_to_63)&i_port_to_63 ) | ( r_port_to_63&(~r_port_to_63_smp) ) ; end
always @(posedge i_ck_64, negedge reset_n)	if (!reset_n) begin	r_port_to_64  <= 32'b0; end  else begin r_port_to_64  <= ( (~r_port_to_64)&i_port_to_64 ) | ( r_port_to_64&(~r_port_to_64_smp) ) ; end
always @(posedge i_ck_65, negedge reset_n)	if (!reset_n) begin	r_port_to_65  <= 32'b0; end  else begin r_port_to_65  <= ( (~r_port_to_65)&i_port_to_65 ) | ( r_port_to_65&(~r_port_to_65_smp) ) ; end
always @(posedge i_ck_66, negedge reset_n)	if (!reset_n) begin	r_port_to_66  <= 32'b0; end  else begin r_port_to_66  <= ( (~r_port_to_66)&i_port_to_66 ) | ( r_port_to_66&(~r_port_to_66_smp) ) ; end
always @(posedge i_ck_67, negedge reset_n)	if (!reset_n) begin	r_port_to_67  <= 32'b0; end  else begin r_port_to_67  <= ( (~r_port_to_67)&i_port_to_67 ) | ( r_port_to_67&(~r_port_to_67_smp) ) ; end
always @(posedge i_ck_68, negedge reset_n)	if (!reset_n) begin	r_port_to_68  <= 32'b0; end  else begin r_port_to_68  <= ( (~r_port_to_68)&i_port_to_68 ) | ( r_port_to_68&(~r_port_to_68_smp) ) ; end
always @(posedge i_ck_69, negedge reset_n)	if (!reset_n) begin	r_port_to_69  <= 32'b0; end  else begin r_port_to_69  <= ( (~r_port_to_69)&i_port_to_69 ) | ( r_port_to_69&(~r_port_to_69_smp) ) ; end
always @(posedge i_ck_6A, negedge reset_n)	if (!reset_n) begin	r_port_to_6A  <= 32'b0; end  else begin r_port_to_6A  <= ( (~r_port_to_6A)&i_port_to_6A ) | ( r_port_to_6A&(~r_port_to_6A_smp) ) ; end
always @(posedge i_ck_6B, negedge reset_n)	if (!reset_n) begin	r_port_to_6B  <= 32'b0; end  else begin r_port_to_6B  <= ( (~r_port_to_6B)&i_port_to_6B ) | ( r_port_to_6B&(~r_port_to_6B_smp) ) ; end
always @(posedge i_ck_6C, negedge reset_n)	if (!reset_n) begin	r_port_to_6C  <= 32'b0; end  else begin r_port_to_6C  <= ( (~r_port_to_6C)&i_port_to_6C ) | ( r_port_to_6C&(~r_port_to_6C_smp) ) ; end
always @(posedge i_ck_6D, negedge reset_n)	if (!reset_n) begin	r_port_to_6D  <= 32'b0; end  else begin r_port_to_6D  <= ( (~r_port_to_6D)&i_port_to_6D ) | ( r_port_to_6D&(~r_port_to_6D_smp) ) ; end
always @(posedge i_ck_6E, negedge reset_n)	if (!reset_n) begin	r_port_to_6E  <= 32'b0; end  else begin r_port_to_6E  <= ( (~r_port_to_6E)&i_port_to_6E ) | ( r_port_to_6E&(~r_port_to_6E_smp) ) ; end
always @(posedge i_ck_6F, negedge reset_n)	if (!reset_n) begin	r_port_to_6F  <= 32'b0; end  else begin r_port_to_6F  <= ( (~r_port_to_6F)&i_port_to_6F ) | ( r_port_to_6F&(~r_port_to_6F_smp) ) ; end
//	//
always @(posedge i_ck_70, negedge reset_n)	if (!reset_n) begin	r_port_to_70  <= 32'b0; end  else begin r_port_to_70  <= ( (~r_port_to_70)&i_port_to_70 ) | ( r_port_to_70&(~r_port_to_70_smp) ) ; end
always @(posedge i_ck_71, negedge reset_n)	if (!reset_n) begin	r_port_to_71  <= 32'b0; end  else begin r_port_to_71  <= ( (~r_port_to_71)&i_port_to_71 ) | ( r_port_to_71&(~r_port_to_71_smp) ) ; end
always @(posedge i_ck_72, negedge reset_n)	if (!reset_n) begin	r_port_to_72  <= 32'b0; end  else begin r_port_to_72  <= ( (~r_port_to_72)&i_port_to_72 ) | ( r_port_to_72&(~r_port_to_72_smp) ) ; end
always @(posedge i_ck_73, negedge reset_n)	if (!reset_n) begin	r_port_to_73  <= 32'b0; end  else begin r_port_to_73  <= ( (~r_port_to_73)&i_port_to_73 ) | ( r_port_to_73&(~r_port_to_73_smp) ) ; end
always @(posedge i_ck_74, negedge reset_n)	if (!reset_n) begin	r_port_to_74  <= 32'b0; end  else begin r_port_to_74  <= ( (~r_port_to_74)&i_port_to_74 ) | ( r_port_to_74&(~r_port_to_74_smp) ) ; end
always @(posedge i_ck_75, negedge reset_n)	if (!reset_n) begin	r_port_to_75  <= 32'b0; end  else begin r_port_to_75  <= ( (~r_port_to_75)&i_port_to_75 ) | ( r_port_to_75&(~r_port_to_75_smp) ) ; end
always @(posedge i_ck_76, negedge reset_n)	if (!reset_n) begin	r_port_to_76  <= 32'b0; end  else begin r_port_to_76  <= ( (~r_port_to_76)&i_port_to_76 ) | ( r_port_to_76&(~r_port_to_76_smp) ) ; end
always @(posedge i_ck_77, negedge reset_n)	if (!reset_n) begin	r_port_to_77  <= 32'b0; end  else begin r_port_to_77  <= ( (~r_port_to_77)&i_port_to_77 ) | ( r_port_to_77&(~r_port_to_77_smp) ) ; end
always @(posedge i_ck_78, negedge reset_n)	if (!reset_n) begin	r_port_to_78  <= 32'b0; end  else begin r_port_to_78  <= ( (~r_port_to_78)&i_port_to_78 ) | ( r_port_to_78&(~r_port_to_78_smp) ) ; end
always @(posedge i_ck_79, negedge reset_n)	if (!reset_n) begin	r_port_to_79  <= 32'b0; end  else begin r_port_to_79  <= ( (~r_port_to_79)&i_port_to_79 ) | ( r_port_to_79&(~r_port_to_79_smp) ) ; end
always @(posedge i_ck_7A, negedge reset_n)	if (!reset_n) begin	r_port_to_7A  <= 32'b0; end  else begin r_port_to_7A  <= ( (~r_port_to_7A)&i_port_to_7A ) | ( r_port_to_7A&(~r_port_to_7A_smp) ) ; end
always @(posedge i_ck_7B, negedge reset_n)	if (!reset_n) begin	r_port_to_7B  <= 32'b0; end  else begin r_port_to_7B  <= ( (~r_port_to_7B)&i_port_to_7B ) | ( r_port_to_7B&(~r_port_to_7B_smp) ) ; end
always @(posedge i_ck_7C, negedge reset_n)	if (!reset_n) begin	r_port_to_7C  <= 32'b0; end  else begin r_port_to_7C  <= ( (~r_port_to_7C)&i_port_to_7C ) | ( r_port_to_7C&(~r_port_to_7C_smp) ) ; end
always @(posedge i_ck_7D, negedge reset_n)	if (!reset_n) begin	r_port_to_7D  <= 32'b0; end  else begin r_port_to_7D  <= ( (~r_port_to_7D)&i_port_to_7D ) | ( r_port_to_7D&(~r_port_to_7D_smp) ) ; end
always @(posedge i_ck_7E, negedge reset_n)	if (!reset_n) begin	r_port_to_7E  <= 32'b0; end  else begin r_port_to_7E  <= ( (~r_port_to_7E)&i_port_to_7E ) | ( r_port_to_7E&(~r_port_to_7E_smp) ) ; end
always @(posedge i_ck_7F, negedge reset_n)	if (!reset_n) begin	r_port_to_7F  <= 32'b0; end  else begin r_port_to_7F  <= ( (~r_port_to_7F)&i_port_to_7F ) | ( r_port_to_7F&(~r_port_to_7F_smp) ) ; end
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
		r_port_to_61_smp  <= 32'b0;
		r_port_to_62_smp  <= 32'b0;
		r_port_to_63_smp  <= 32'b0;
		r_port_to_64_smp  <= 32'b0;
		r_port_to_65_smp  <= 32'b0;
		r_port_to_66_smp  <= 32'b0;
		r_port_to_67_smp  <= 32'b0;
		r_port_to_68_smp  <= 32'b0;
		r_port_to_69_smp  <= 32'b0;
		r_port_to_6A_smp  <= 32'b0;
		r_port_to_6B_smp  <= 32'b0;
		r_port_to_6C_smp  <= 32'b0;
		r_port_to_6D_smp  <= 32'b0;
		r_port_to_6E_smp  <= 32'b0;
		r_port_to_6F_smp  <= 32'b0;
		//
		r_port_to_70_smp  <= 32'b0;
		r_port_to_71_smp  <= 32'b0;
		r_port_to_72_smp  <= 32'b0;
		r_port_to_73_smp  <= 32'b0;
		r_port_to_74_smp  <= 32'b0;
		r_port_to_75_smp  <= 32'b0;
		r_port_to_76_smp  <= 32'b0;
		r_port_to_77_smp  <= 32'b0;
		r_port_to_78_smp  <= 32'b0;
		r_port_to_79_smp  <= 32'b0;
		r_port_to_7A_smp  <= 32'b0;
		r_port_to_7B_smp  <= 32'b0;
		r_port_to_7C_smp  <= 32'b0;
		r_port_to_7D_smp  <= 32'b0;
		r_port_to_7E_smp  <= 32'b0;
		r_port_to_7F_smp  <= 32'b0;
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
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_60)) begin r_port_to_60_smp  <= r_port_to_60_smp & (~r_mask_to) ; end  else begin r_port_to_60_smp  <= r_port_to_60_smp | r_port_to_60; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_61)) begin r_port_to_61_smp  <= r_port_to_61_smp & (~r_mask_to) ; end  else begin r_port_to_61_smp  <= r_port_to_61_smp | r_port_to_61; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_62)) begin r_port_to_62_smp  <= r_port_to_62_smp & (~r_mask_to) ; end  else begin r_port_to_62_smp  <= r_port_to_62_smp | r_port_to_62; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_63)) begin r_port_to_63_smp  <= r_port_to_63_smp & (~r_mask_to) ; end  else begin r_port_to_63_smp  <= r_port_to_63_smp | r_port_to_63; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_64)) begin r_port_to_64_smp  <= r_port_to_64_smp & (~r_mask_to) ; end  else begin r_port_to_64_smp  <= r_port_to_64_smp | r_port_to_64; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_65)) begin r_port_to_65_smp  <= r_port_to_65_smp & (~r_mask_to) ; end  else begin r_port_to_65_smp  <= r_port_to_65_smp | r_port_to_65; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_66)) begin r_port_to_66_smp  <= r_port_to_66_smp & (~r_mask_to) ; end  else begin r_port_to_66_smp  <= r_port_to_66_smp | r_port_to_66; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_67)) begin r_port_to_67_smp  <= r_port_to_67_smp & (~r_mask_to) ; end  else begin r_port_to_67_smp  <= r_port_to_67_smp | r_port_to_67; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_68)) begin r_port_to_68_smp  <= r_port_to_68_smp & (~r_mask_to) ; end  else begin r_port_to_68_smp  <= r_port_to_68_smp | r_port_to_68; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_69)) begin r_port_to_69_smp  <= r_port_to_69_smp & (~r_mask_to) ; end  else begin r_port_to_69_smp  <= r_port_to_69_smp | r_port_to_69; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6A)) begin r_port_to_6A_smp  <= r_port_to_6A_smp & (~r_mask_to) ; end  else begin r_port_to_6A_smp  <= r_port_to_6A_smp | r_port_to_6A; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6B)) begin r_port_to_6B_smp  <= r_port_to_6B_smp & (~r_mask_to) ; end  else begin r_port_to_6B_smp  <= r_port_to_6B_smp | r_port_to_6B; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6C)) begin r_port_to_6C_smp  <= r_port_to_6C_smp & (~r_mask_to) ; end  else begin r_port_to_6C_smp  <= r_port_to_6C_smp | r_port_to_6C; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6D)) begin r_port_to_6D_smp  <= r_port_to_6D_smp & (~r_mask_to) ; end  else begin r_port_to_6D_smp  <= r_port_to_6D_smp | r_port_to_6D; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6E)) begin r_port_to_6E_smp  <= r_port_to_6E_smp & (~r_mask_to) ; end  else begin r_port_to_6E_smp  <= r_port_to_6E_smp | r_port_to_6E; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6F)) begin r_port_to_6F_smp  <= r_port_to_6F_smp & (~r_mask_to) ; end  else begin r_port_to_6F_smp  <= r_port_to_6F_smp | r_port_to_6F; end
		//
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_70)) begin r_port_to_70_smp  <= r_port_to_70_smp & (~r_mask_to) ; end  else begin r_port_to_70_smp  <= r_port_to_70_smp | r_port_to_70; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_71)) begin r_port_to_71_smp  <= r_port_to_71_smp & (~r_mask_to) ; end  else begin r_port_to_71_smp  <= r_port_to_71_smp | r_port_to_71; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_72)) begin r_port_to_72_smp  <= r_port_to_72_smp & (~r_mask_to) ; end  else begin r_port_to_72_smp  <= r_port_to_72_smp | r_port_to_72; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_73)) begin r_port_to_73_smp  <= r_port_to_73_smp & (~r_mask_to) ; end  else begin r_port_to_73_smp  <= r_port_to_73_smp | r_port_to_73; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_74)) begin r_port_to_74_smp  <= r_port_to_74_smp & (~r_mask_to) ; end  else begin r_port_to_74_smp  <= r_port_to_74_smp | r_port_to_74; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_75)) begin r_port_to_75_smp  <= r_port_to_75_smp & (~r_mask_to) ; end  else begin r_port_to_75_smp  <= r_port_to_75_smp | r_port_to_75; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_76)) begin r_port_to_76_smp  <= r_port_to_76_smp & (~r_mask_to) ; end  else begin r_port_to_76_smp  <= r_port_to_76_smp | r_port_to_76; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_77)) begin r_port_to_77_smp  <= r_port_to_77_smp & (~r_mask_to) ; end  else begin r_port_to_77_smp  <= r_port_to_77_smp | r_port_to_77; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_78)) begin r_port_to_78_smp  <= r_port_to_78_smp & (~r_mask_to) ; end  else begin r_port_to_78_smp  <= r_port_to_78_smp | r_port_to_78; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_79)) begin r_port_to_79_smp  <= r_port_to_79_smp & (~r_mask_to) ; end  else begin r_port_to_79_smp  <= r_port_to_79_smp | r_port_to_79; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7A)) begin r_port_to_7A_smp  <= r_port_to_7A_smp & (~r_mask_to) ; end  else begin r_port_to_7A_smp  <= r_port_to_7A_smp | r_port_to_7A; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7B)) begin r_port_to_7B_smp  <= r_port_to_7B_smp & (~r_mask_to) ; end  else begin r_port_to_7B_smp  <= r_port_to_7B_smp | r_port_to_7B; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7C)) begin r_port_to_7C_smp  <= r_port_to_7C_smp & (~r_mask_to) ; end  else begin r_port_to_7C_smp  <= r_port_to_7C_smp | r_port_to_7C; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7D)) begin r_port_to_7D_smp  <= r_port_to_7D_smp & (~r_mask_to) ; end  else begin r_port_to_7D_smp  <= r_port_to_7D_smp | r_port_to_7D; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7E)) begin r_port_to_7E_smp  <= r_port_to_7E_smp & (~r_mask_to) ; end  else begin r_port_to_7E_smp  <= r_port_to_7E_smp | r_port_to_7E; end
		if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7F)) begin r_port_to_7F_smp  <= r_port_to_7F_smp & (~r_mask_to) ; end  else begin r_port_to_7F_smp  <= r_port_to_7F_smp | r_port_to_7F; end
	end
	
	
	
// r_IO_address
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
//

// o_IO_read_data
(* keep = "true" *) reg [31:0] r_IO_read_data;
//assign o_IO_read_data = r_IO_read_data;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_IO_read_data <= INIT_IO_data;
	end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_FPGA_IMAGE_ID)) begin r_IO_read_data <= FPGA_IMAGE_ID; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_TEST_REG)) begin r_IO_read_data <= r_test; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_WI)) begin r_IO_read_data <= r_mask_wi; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_WO)) begin r_IO_read_data <= r_mask_wo; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_TI)) begin r_IO_read_data <= r_mask_ti; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_MASK_TO)) begin r_IO_read_data <= r_mask_to; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_00)) begin r_IO_read_data <= r_port_wi_00; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_01)) begin r_IO_read_data <= r_port_wi_01; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_02)) begin r_IO_read_data <= r_port_wi_02; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_03)) begin r_IO_read_data <= r_port_wi_03; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_04)) begin r_IO_read_data <= r_port_wi_04; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_05)) begin r_IO_read_data <= r_port_wi_05; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_06)) begin r_IO_read_data <= r_port_wi_06; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_07)) begin r_IO_read_data <= r_port_wi_07; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_08)) begin r_IO_read_data <= r_port_wi_08; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_09)) begin r_IO_read_data <= r_port_wi_09; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0A)) begin r_IO_read_data <= r_port_wi_0A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0B)) begin r_IO_read_data <= r_port_wi_0B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0C)) begin r_IO_read_data <= r_port_wi_0C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0D)) begin r_IO_read_data <= r_port_wi_0D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0E)) begin r_IO_read_data <= r_port_wi_0E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_0F)) begin r_IO_read_data <= r_port_wi_0F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_10)) begin r_IO_read_data <= r_port_wi_10; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_11)) begin r_IO_read_data <= r_port_wi_11; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_12)) begin r_IO_read_data <= r_port_wi_12; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_13)) begin r_IO_read_data <= r_port_wi_13; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_14)) begin r_IO_read_data <= r_port_wi_14; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_15)) begin r_IO_read_data <= r_port_wi_15; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_16)) begin r_IO_read_data <= r_port_wi_16; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_17)) begin r_IO_read_data <= r_port_wi_17; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_18)) begin r_IO_read_data <= r_port_wi_18; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_19)) begin r_IO_read_data <= r_port_wi_19; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1A)) begin r_IO_read_data <= r_port_wi_1A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1B)) begin r_IO_read_data <= r_port_wi_1B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1C)) begin r_IO_read_data <= r_port_wi_1C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1D)) begin r_IO_read_data <= r_port_wi_1D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1E)) begin r_IO_read_data <= r_port_wi_1E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_WI_1F)) begin r_IO_read_data <= r_port_wi_1F; end
	//
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
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_40)) begin r_IO_read_data <= r_port_ti_40; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_41)) begin r_IO_read_data <= r_port_ti_41; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_42)) begin r_IO_read_data <= r_port_ti_42; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_43)) begin r_IO_read_data <= r_port_ti_43; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_44)) begin r_IO_read_data <= r_port_ti_44; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_45)) begin r_IO_read_data <= r_port_ti_45; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_46)) begin r_IO_read_data <= r_port_ti_46; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_47)) begin r_IO_read_data <= r_port_ti_47; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_48)) begin r_IO_read_data <= r_port_ti_48; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_49)) begin r_IO_read_data <= r_port_ti_49; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4A)) begin r_IO_read_data <= r_port_ti_4A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4B)) begin r_IO_read_data <= r_port_ti_4B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4C)) begin r_IO_read_data <= r_port_ti_4C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4D)) begin r_IO_read_data <= r_port_ti_4D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4E)) begin r_IO_read_data <= r_port_ti_4E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_4F)) begin r_IO_read_data <= r_port_ti_4F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_50)) begin r_IO_read_data <= r_port_ti_50; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_51)) begin r_IO_read_data <= r_port_ti_51; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_52)) begin r_IO_read_data <= r_port_ti_52; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_53)) begin r_IO_read_data <= r_port_ti_53; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_54)) begin r_IO_read_data <= r_port_ti_54; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_55)) begin r_IO_read_data <= r_port_ti_55; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_56)) begin r_IO_read_data <= r_port_ti_56; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_57)) begin r_IO_read_data <= r_port_ti_57; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_58)) begin r_IO_read_data <= r_port_ti_58; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_59)) begin r_IO_read_data <= r_port_ti_59; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5A)) begin r_IO_read_data <= r_port_ti_5A; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5B)) begin r_IO_read_data <= r_port_ti_5B; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5C)) begin r_IO_read_data <= r_port_ti_5C; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5D)) begin r_IO_read_data <= r_port_ti_5D; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5E)) begin r_IO_read_data <= r_port_ti_5E; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TI_5F)) begin r_IO_read_data <= r_port_ti_5F; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_60)) begin r_IO_read_data <= r_port_to_60_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_61)) begin r_IO_read_data <= r_port_to_61_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_62)) begin r_IO_read_data <= r_port_to_62_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_63)) begin r_IO_read_data <= r_port_to_63_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_64)) begin r_IO_read_data <= r_port_to_64_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_65)) begin r_IO_read_data <= r_port_to_65_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_66)) begin r_IO_read_data <= r_port_to_66_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_67)) begin r_IO_read_data <= r_port_to_67_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_68)) begin r_IO_read_data <= r_port_to_68_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_69)) begin r_IO_read_data <= r_port_to_69_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6A)) begin r_IO_read_data <= r_port_to_6A_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6B)) begin r_IO_read_data <= r_port_to_6B_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6C)) begin r_IO_read_data <= r_port_to_6C_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6D)) begin r_IO_read_data <= r_port_to_6D_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6E)) begin r_IO_read_data <= r_port_to_6E_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_6F)) begin r_IO_read_data <= r_port_to_6F_smp&r_mask_to; end
	//
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_70)) begin r_IO_read_data <= r_port_to_70_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_71)) begin r_IO_read_data <= r_port_to_71_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_72)) begin r_IO_read_data <= r_port_to_72_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_73)) begin r_IO_read_data <= r_port_to_73_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_74)) begin r_IO_read_data <= r_port_to_74_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_75)) begin r_IO_read_data <= r_port_to_75_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_76)) begin r_IO_read_data <= r_port_to_76_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_77)) begin r_IO_read_data <= r_port_to_77_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_78)) begin r_IO_read_data <= r_port_to_78_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_79)) begin r_IO_read_data <= r_port_to_79_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7A)) begin r_IO_read_data <= r_port_to_7A_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7B)) begin r_IO_read_data <= r_port_to_7B_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7C)) begin r_IO_read_data <= r_port_to_7C_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7D)) begin r_IO_read_data <= r_port_to_7D_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7E)) begin r_IO_read_data <= r_port_to_7E_smp&r_mask_to; end
	else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_TO_7F)) begin r_IO_read_data <= r_port_to_7F_smp&r_mask_to; end
	//
	//else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_PO_A0)) begin
	//	r_IO_read_data <= i_port_po_A0; //
	//end
	//else if (i_IO_addr_strobe & i_IO_read_strobe & (i_IO_address == ADRS_PORT_PO_A1)) begin
	//	r_IO_read_data <= i_port_po_A1; //
	//end
	else begin 
		r_IO_read_data <= INIT_IO_data;
	end

// o_wr_X
assign o_wr_80 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_80))? 1'b1 : 1'b0;
assign o_wr_81 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_81))? 1'b1 : 1'b0;
assign o_wr_82 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_82))? 1'b1 : 1'b0;
assign o_wr_83 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_83))? 1'b1 : 1'b0;
assign o_wr_84 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_84))? 1'b1 : 1'b0;
assign o_wr_85 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_85))? 1'b1 : 1'b0;
assign o_wr_86 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_86))? 1'b1 : 1'b0;
assign o_wr_87 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_87))? 1'b1 : 1'b0;
assign o_wr_88 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_88))? 1'b1 : 1'b0;
assign o_wr_89 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_89))? 1'b1 : 1'b0;
assign o_wr_8A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8A))? 1'b1 : 1'b0;
assign o_wr_8B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8B))? 1'b1 : 1'b0;
assign o_wr_8C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8C))? 1'b1 : 1'b0;
assign o_wr_8D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8D))? 1'b1 : 1'b0;
assign o_wr_8E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8E))? 1'b1 : 1'b0;
assign o_wr_8F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_8F))? 1'b1 : 1'b0;
//
assign o_wr_90 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_90))? 1'b1 : 1'b0;
assign o_wr_91 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_91))? 1'b1 : 1'b0;
assign o_wr_92 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_92))? 1'b1 : 1'b0;
assign o_wr_93 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_93))? 1'b1 : 1'b0;
assign o_wr_94 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_94))? 1'b1 : 1'b0;
assign o_wr_95 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_95))? 1'b1 : 1'b0;
assign o_wr_96 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_96))? 1'b1 : 1'b0;
assign o_wr_97 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_97))? 1'b1 : 1'b0;
assign o_wr_98 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_98))? 1'b1 : 1'b0;
assign o_wr_99 = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_99))? 1'b1 : 1'b0;
assign o_wr_9A = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9A))? 1'b1 : 1'b0;
assign o_wr_9B = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9B))? 1'b1 : 1'b0;
assign o_wr_9C = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9C))? 1'b1 : 1'b0;
assign o_wr_9D = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9D))? 1'b1 : 1'b0;
assign o_wr_9E = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9E))? 1'b1 : 1'b0;
assign o_wr_9F = (i_IO_addr_strobe & i_IO_write_strobe & (i_IO_address == ADRS_PORT_PI_9F))? 1'b1 : 1'b0;

// o_port_pi_X
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

// o_rd_X
assign o_rd_A0 = (i_IO_address == ADRS_PORT_PO_A0)? i_IO_read_strobe : 1'b0;
assign o_rd_A1 = (i_IO_address == ADRS_PORT_PO_A1)? i_IO_read_strobe : 1'b0;
assign o_rd_A2 = (i_IO_address == ADRS_PORT_PO_A2)? i_IO_read_strobe : 1'b0;
assign o_rd_A3 = (i_IO_address == ADRS_PORT_PO_A3)? i_IO_read_strobe : 1'b0;
assign o_rd_A4 = (i_IO_address == ADRS_PORT_PO_A4)? i_IO_read_strobe : 1'b0;
assign o_rd_A5 = (i_IO_address == ADRS_PORT_PO_A5)? i_IO_read_strobe : 1'b0;
assign o_rd_A6 = (i_IO_address == ADRS_PORT_PO_A6)? i_IO_read_strobe : 1'b0;
assign o_rd_A7 = (i_IO_address == ADRS_PORT_PO_A7)? i_IO_read_strobe : 1'b0;
assign o_rd_A8 = (i_IO_address == ADRS_PORT_PO_A8)? i_IO_read_strobe : 1'b0;
assign o_rd_A9 = (i_IO_address == ADRS_PORT_PO_A9)? i_IO_read_strobe : 1'b0;
assign o_rd_AA = (i_IO_address == ADRS_PORT_PO_AA)? i_IO_read_strobe : 1'b0;
assign o_rd_AB = (i_IO_address == ADRS_PORT_PO_AB)? i_IO_read_strobe : 1'b0;
assign o_rd_AC = (i_IO_address == ADRS_PORT_PO_AC)? i_IO_read_strobe : 1'b0;
assign o_rd_AD = (i_IO_address == ADRS_PORT_PO_AD)? i_IO_read_strobe : 1'b0;
assign o_rd_AE = (i_IO_address == ADRS_PORT_PO_AE)? i_IO_read_strobe : 1'b0;
assign o_rd_AF = (i_IO_address == ADRS_PORT_PO_AF)? i_IO_read_strobe : 1'b0;
//
assign o_rd_B0 = (i_IO_address == ADRS_PORT_PO_B0)? i_IO_read_strobe : 1'b0;
assign o_rd_B1 = (i_IO_address == ADRS_PORT_PO_B1)? i_IO_read_strobe : 1'b0;
assign o_rd_B2 = (i_IO_address == ADRS_PORT_PO_B2)? i_IO_read_strobe : 1'b0;
assign o_rd_B3 = (i_IO_address == ADRS_PORT_PO_B3)? i_IO_read_strobe : 1'b0;
assign o_rd_B4 = (i_IO_address == ADRS_PORT_PO_B4)? i_IO_read_strobe : 1'b0;
assign o_rd_B5 = (i_IO_address == ADRS_PORT_PO_B5)? i_IO_read_strobe : 1'b0;
assign o_rd_B6 = (i_IO_address == ADRS_PORT_PO_B6)? i_IO_read_strobe : 1'b0;
assign o_rd_B7 = (i_IO_address == ADRS_PORT_PO_B7)? i_IO_read_strobe : 1'b0;
assign o_rd_B8 = (i_IO_address == ADRS_PORT_PO_B8)? i_IO_read_strobe : 1'b0;
assign o_rd_B9 = (i_IO_address == ADRS_PORT_PO_B9)? i_IO_read_strobe : 1'b0;
assign o_rd_BA = (i_IO_address == ADRS_PORT_PO_BA)? i_IO_read_strobe : 1'b0;
assign o_rd_BB = (i_IO_address == ADRS_PORT_PO_BB)? i_IO_read_strobe : 1'b0;
assign o_rd_BC = (i_IO_address == ADRS_PORT_PO_BC)? i_IO_read_strobe : 1'b0;
assign o_rd_BD = (i_IO_address == ADRS_PORT_PO_BD)? i_IO_read_strobe : 1'b0;
assign o_rd_BE = (i_IO_address == ADRS_PORT_PO_BE)? i_IO_read_strobe : 1'b0;
assign o_rd_BF = (i_IO_address == ADRS_PORT_PO_BF)? i_IO_read_strobe : 1'b0;

// 
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
	(i_IO_address == ADRS_FPGA_IMAGE_ID) |
	(i_IO_address == ADRS_TEST_REG     ) |
	(i_IO_address == ADRS_MASK_WI      ) |
	(i_IO_address == ADRS_MASK_WO      ) |
	(i_IO_address == ADRS_MASK_TI      ) |
	(i_IO_address == ADRS_MASK_TO      ) ;
	//


// r_IO_ready_rd
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
	
//
assign o_IO_read_data = 
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
	r_IO_read_data;
//
	
	
// r_IO_ready_wr
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

	
// o_IO_ready
assign o_IO_ready = r_IO_ready_rd | r_IO_ready_wr;

// r_IO_ready_rd_ref
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

// r_IO_ready_wr_ref
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

// o_IO_ready_ref
assign o_IO_ready_ref = r_IO_ready_rd_ref | r_IO_ready_wr_ref;
	
endmodule
