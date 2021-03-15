//// control_eeprom__11AA160T.v
//   eeprom controller
//
// EEPROM part name : 11AA160T-I/TT
// EEPROM memory configuration : 2k*8bit
// 
// === parameters ===
// logic base clock freq : 100kHz or 10us (b_clk)
// BIT_period            : 20us or "2" b_clk
// standby pulse width   : 610us or "61" b_clk
// start header high setup : 30us or "3" b_clk 
// start header low pulse  : 20us or "2" b_clk 
//
// === constant codes ===
// device address byte allication : 1010 0000 (MAK)(SAK)
// data 0 : HL
// data 1 : LH
// MAK    : LH
// SAK    : LH
// NoMAK  : HL 
// NoSAK  : HH or LL
//
// === timing (rough) ===
// * standby pulse  : L  H
//             SCIO : ___--------------------
//                     3 <-------61--------->
//
// * starter header : H  L 0 1 0 1 0 1 0 1 1 X
//             SCIO : ---__-__--__--__--__-_-xx
//                                         | |
//                                         | +-- NoSAK
//                                         +---- MAK
// * data example   : 0 1 1 0 ...
//             SCIO : -__-_--_...
//
// === command byte list ===
// READ : 0x03 // read data beginning from the address 
// CRRD : 0x06 // read data at the current address
// WRITE: 0x6C // write data beginning from the address
// WREN : 0x96 // enable write operations
// WRDI : 0x91 // disable write operations
// RDSR : 0x05 // read  status
// WRSR : 0x6E // write status
// ERAL : 0x6D // write 0x00 to entire array
// SETAL: 0x67 // write 0xFF to entire array
//
// === sequence tyes === //{
// 0. common sequence
// [standby pulse (SBP)] -- [start header(SHD)] -- [dev adrs(DVA)] -- [command(CMD)] 
//                      -- [word adrs high(ADH)] -- [word adrs low(ADL)] -- [data 1 (DA1)] -- ... -- [data n (DAn)]
//       or [SBP]--[SHD(0x55)]--[DVA(0xA0)]--[CMD]--[ADH]--[ADL]--[DA1]--...--[DAn]
//       Note SP is option.
// 
// 1.READ : 0x03 // read data beginning from the address 
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x03)]-(MAK)-(SAK)--
//          [ADH]-(MAK)-(SAK)  --[ADL]-(MAK)-(SAK)--[DA1]-(MAK)-(SAK)--...
//          [DAn]-(NoMAK)-(SAK)
//
// 2.CRRD : 0x06 // read data at the current address
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x06)]-(MAK)-(SAK)--
//          [DA1]-(MAK)-(SAK)--...
//          [DAn]-(NoMAK)-(SAK)
//
// 3.WRITE: 0x6C // write data beginning from the address
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x6C)]-(MAK)-(SAK)--
//          [ADH]-(MAK)-(SAK)  --[ADL]-(MAK)-(SAK)--[DA1]-(MAK)-(SAK)--...
//          [DAn]-(NoMAK)-(SAK)
//
// 4.WREN : 0x96 // enable write operations
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x96)]-(NoMAK)-(SAK)
//
// 5.WRDI : 0x91 // disable write operations
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x91)]-(NoMAK)-(SAK)
//
// 6.RDSR : 0x05 // read  status
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x05)]-(MAK)-(SAK)
//          [STA]-(NoMAK)-(SAK)
//
// 7.WRSR : 0x6E // write status
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x6E)]-(MAK)-(SAK)
//          [STA]-(NoMAK)-(SAK)
//
// 8.ERAL : 0x6D // write 0x00 to entire array
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x6D)]-(NoMAK)-(SAK)
//
// 9.SETAL: 0x67 // write 0xFF to entire array
//          [SBP]--
//          [SHD]-(MAK)-(NoSAK)--[DVA(0xA0)]-(MAK)-(SAK)--[CMD(0x67)]-(NoMAK)-(SAK)
//
// //}
//
// === internal signals and frames === //{
// SCIO_DI
// SCIO_DO
// SCIO_OE
//
// * [SBP]--
// SCIO_DI : xxxxxxxxxxxxxxxxxxxxxx
// SCIO_DO : ___-------------------
// SCIO_OE : ----------------------
// idx_L   : 012345678901...7890123
// idx_H   : 000000000011...5555666
//
// * [SHD]-(MAK)-(NoSAK)--
// SCIO_DI : xxxxxxxxxxxxxxxxxxxxxxx~~
// SCIO_DO : ---__-__--__--__--__-_-xx
// SCIO_OE : -----------------------__
// idx_L   : 0123456789012345678901234
// idx_H   : 0000000000111111111122222
// odata   :      0_1_0_1_0_1_0_1_LH
//
//
// * [DVA(0xA0)]-(MAK)-(SAK)--
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : _--__--_-_-_-_-__-xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : 1_0_1_0_0_0_0_0_LH
//
// * [CMD(CC)]-(MAK)-(SAK)--
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : CcCcCcCcCcCcCcCc_-xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : CcCcCcCcCcCcCcCcLH
//
// * [CMD(CC)]-(NoMAK)-(SAK)
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : CcCcCcCcCcCcCcCc-_xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : CcCcCcCcCcCcCcCcHL
//
// * [ADH(AA)]-(MAK)-(SAK)--
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : AfAeAdAcAbAaA9A8_-xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : AfAeAdAcAbAaA9A8LH
//
// * [ADL(AA)]-(MAK)-(SAK)--
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : A7A6A5A4A3A2A1A0_-xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : A7A6A5A4A3A2A1A0LH
//
//
// * read  [DA1]-(MAK)-(SAK)
// SCIO_DI : D7D6D5D4D3D2D1D0xx_-
// SCIO_DO : xxxxxxxxxxxxxxxx_-xx
// SCIO_OE : ________________--__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : ________________LH
//
// * read  [DAn]-(NoMAK)-(SAK)
// SCIO_DI : D7D6D5D4D3D2D1D0xx_-
// SCIO_DO : xxxxxxxxxxxxxxxx-_xx
// SCIO_OE : ________________--__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : ________________HL
//
// * write [DA1]-(MAK)-(SAK)
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : D7D6D5D4D3D2D1D0_-xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : D7D6D5D4D3D2D1D0LH
//
// * write [DAn]-(NoMAK)-(SAK)
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : D7D6D5D4D3D2D1D0-_xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : D7D6D5D4D3D2D1D0HL
//
//
// * read  [STA]-(NoMAK)-(SAK)
// SCIO_DI : ________D3D2D1D0xx_-
// SCIO_DO : xxxxxxxxxxxxxxxx-_xx
// SCIO_OE : ________________--__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : ________________HL
//
// * write [STA]-(NoMAK)-(SAK)
// SCIO_DI : xxxxxxxxxxxxxxxxxx_-
// SCIO_DO : ________D3D2____-_xx
// SCIO_OE : ------------------__
// idx_L   : 01234567890123456789
// idx_H   : 00000000001111111111
// odata   : ________D3D2____HL
//
// //}
//
// === internal ports (for test model) ===
// clk // 10MHz
// reset_n
//
// o_model_SCIO_DI
// i_model_SCIO_DO
// i_model_SCIO_OE
//
// o_SBP_ack
// o_SHD_ack
// o_DVA_ack
// o_CMD_ack
// o_ADH_ack
// o_ADL_ack
// o_DAT_ack
// o_DAT_rdy
// o_STA_ack
// o_STA_rdy
// 
//
//
// === internal ports (for controller) ===
// clk // 10MHz
// reset_n
//
// [7:0] i_frame_data_SHD // 8-bit followed by MAK and NoSAK
// [7:0] i_frame_data_DVA // 8-bit followed by MAK and SAK
// [7:0] i_frame_data_CMD // 8-bit followed by MAK/NoMAK and NoSAK
// [7:0] i_frame_data_STA // 8-bit followed by MAK/NoMAK and SAK
// [7:0] o_frame_data_STA // 8-bit followed by MAK/NoMAK and SAK
// [7:0] i_frame_data_DAT // 8-bit followed by MAK/NoMAK and SAK
// [7:0] o_frame_data_DAT // 8-bit followed by MAK/NoMAK and SAK
// 
// [11:0] i_num_bytes_DAT // 2048=2^11 ... 12-bit assigned
//
// i_trig_frame
// o_done_frame
// o_done_frame_TO // trig out @ clk
//
//

`timescale 1ns / 1ps

//// TODO: module ////
module control_eeprom__11AA160T (
	//
	input  wire clk    , // 10MHz
	input  wire reset_n,
	
	// controls
	input  wire i_trig_frame   ,                                                 // TI
	output wire o_done_frame   ,                                                 // TO
	output wire o_done_frame_TO, // trig out @ clk                               // TO
	//
	input  wire i_en_SBP, // enable SBP (stand-by pulse)                         // fixed
	//
	input  wire [7:0] i_frame_data_SHD, // 8-bit followed by MAK and NoSAK       // fixed
	input  wire [7:0] i_frame_data_DVA, // 8-bit followed by MAK and SAK         // fixed
	input  wire [7:0] i_frame_data_CMD, // 8-bit followed by MAK/NoMAK and NoSAK // WI
	input  wire [7:0] i_frame_data_ADH, // 8-bit followed by MAK and SAK         // WI
	input  wire [7:0] i_frame_data_ADL, // 8-bit followed by MAK and SAK         // WI
	input  wire [7:0] i_frame_data_STA, // 8-bit followed by MAK/NoMAK and SAK   // WI
	output wire [7:0] o_frame_data_STA, // 8-bit followed by MAK/NoMAK and SAK   // TO
	//
	input  wire [11:0] i_num_bytes_DAT, // 2048=2^11 ... 12-bit assigned         // WI

	// FIFO/PIPE interfaces
	input wire i_reset_fifo, // force reset fifo                                 // TI
	//
	input  wire [7:0] i_frame_data_DAT, // 8-bit followed by MAK/NoMAK and SAK   // PI
	output wire [7:0] o_frame_data_DAT, // 8-bit followed by MAK/NoMAK and SAK   // PO
	//
	input wire i_frame_data_DAT_wr_en , //  // control for i_frame_data_DAT
	input wire i_frame_data_DAT_wr_clk, //  // control for i_frame_data_DAT
	input wire i_frame_data_DAT_rd_en , //  // control for o_frame_data_DAT
	input wire i_frame_data_DAT_rd_clk, //  // control for o_frame_data_DAT
	
	// IO ports
	input  wire i_SCIO_DI,
	output wire o_SCIO_DO,
	output wire o_SCIO_OE,
	
	output wire valid
);

//// valid //{
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

//// slow clocks from 10MHz : r_clk_en_100K and r_clk_en_200K //{
// 10MHz/100kHz = 100
reg r_clk_en_100K;
reg r_clk_en_200K;
(* keep = "true" *) reg [6:0] r_cnt_clk;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_clk_en_100K <= 1'b0;
		r_clk_en_200K <= 1'b0;
		r_cnt_clk     <= 7'b0;
	end
	else begin
		//
		if (r_cnt_clk == 7'd01)
			r_clk_en_100K <= 1'b1;
		else 
			r_clk_en_100K <= 1'b0;
		//
		if (r_cnt_clk == 7'd01 || r_cnt_clk == 7'd51)
			r_clk_en_200K <= 1'b1;
		else 
			r_clk_en_200K <= 1'b0;
		//
		if (r_cnt_clk >= 7'd99)
			r_cnt_clk     <= 7'b0;
		else
			r_cnt_clk     <= r_cnt_clk + 1;
		//
	end
//}


//// monitor trig : r_trig_frame //{

reg r_trig_frame;
reg [1:0] r_smp_trig_frame; // i_trig_frame
wire w_clear_trig_frame; // assign later
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_trig_frame     <= 1'b0;
		r_smp_trig_frame <= 2'b0;
	end
	else begin
		if (r_smp_trig_frame==2'b01)
			r_trig_frame     <= 1'b1;
		else if (r_trig_frame==1'b1 && w_clear_trig_frame)
			r_trig_frame     <= 1'b0;
		//
		r_smp_trig_frame <= {r_smp_trig_frame[0], i_trig_frame};
	end


//
wire w_frame_done;
reg [1:0] r_smp_frame_done; // w_frame_done
//
wire w_frame_done_rise = (~r_smp_frame_done[1])&(r_smp_frame_done[0]); // rise edge
//
assign w_clear_trig_frame = w_frame_done_rise;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_frame_done <= 2'b0;
	end
	else begin
		r_smp_frame_done <= {r_smp_frame_done[0], w_frame_done};
	end

//}


//// o_done_frame  o_done_frame_TO //{
assign o_done_frame    = ~r_trig_frame;
assign o_done_frame_TO = w_frame_done_rise;
//}




//// o_SCIO_OE //{
wire w_SCIO_OE;
assign o_SCIO_OE = w_SCIO_OE;
//}

//// o_SCIO_DO //{
wire w_SCIO_DO;
assign o_SCIO_DO = w_SCIO_DO;
//}




//// state register //{
(* keep = "true" *) reg [7:0] r_state; 
// state def  STATE_ 
parameter STATE_RDY_00 = 8'h00; // ready to get trig
parameter STATE_SBP_01 = 8'h01; // generate stand-by pulse frame
parameter STATE_SHD_02 = 8'h02; // generate start header frame
parameter STATE_DVA_03 = 8'h03; // generate device address frame
parameter STATE_CMD_04 = 8'h04; // generate command frame
//
parameter STATE_ADH_10 = 8'h10; // generate data address high frame
parameter STATE_ADL_11 = 8'h11; // generate data address low  frame
//
parameter STATE_DAW_20 = 8'h20; // generate data write frame
parameter STATE_DAR_21 = 8'h21; // generate data read  frame
parameter STATE_STW_22 = 8'h22; // generate status write frame
parameter STATE_STR_23 = 8'h23; // generate status read  frame
//
parameter STATE_FIN_99 = 8'h99; // finish the frame

// * review ... sequence S1 ~ S6 
// === command byte list ===
// 1.READ[S1] : 0x03 // read data beginning from the address 
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](MAK/SAK)-->
//          [STATE_ADH_10](MAK/SAK)  -->[STATE_ADL_11](MAK/SAK)-->
//          [STATE_DAR_21](MAK/SAK)-->...-->[STATE_DAR_21](NoMAK/SAK)
// 2.CRRD[S2] : 0x06 // read data at the current address
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](MAK/SAK)-->
//          [STATE_DAR_21](MAK/SAK)-->...-->[STATE_DAR_21](NoMAK/SAK)
// 3.WRITE[S3]: 0x6C // write data beginning from the address
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](MAK/SAK)-->
//          [STATE_ADH_10](MAK/SAK)  -->[STATE_ADL_11](MAK/SAK)-->
//          [STATE_DAW_20](MAK/SAK)-->...-->[STATE_DAW_20](NoMAK/SAK)
// 4.WREN[S4] : 0x96 // enable write operations
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](NoMAK/SAK)
// 5.WRDI[S4] : 0x91 // disable write operations
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](NoMAK/SAK)
// 6.RDSR[S5] : 0x05 // read  status
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](MAK/SAK)-->
//          [STATE_STR_23](NoMAK/SAK)
// 7.WRSR[S6] : 0x6E // write status
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](MAK/SAK)-->
//          [STATE_STW_22](NoMAK/SAK)
// 8.ERAL[S4] : 0x6D // write 0x00 to entire array
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](NoMAK/SAK)
// 9.SETAL[S4]: 0x67 // write 0xFF to entire array
//          [STATE_SBP_01]-->
//          [STATE_SHD_02](MAK/NoSAK)-->[STATE_DVA_03](MAK/SAK)-->[STATE_CMD_04](NoMAK/SAK)

// * sequence related to commands
// - SEQ1 : 0x03
// - SEQ2 : 0x06
// - SEQ3 : 0x6C
// - SEQ4 : 0x96, 0x91, 0x6D, 0x67, unknowns.
// - SEQ5 : 0x05
// - SEQ6 : 0x6E
parameter CMD_READ__03 = 8'h03; // SEQ1
parameter CMD_CRRD__06 = 8'h06; // SEQ2
parameter CMD_WRITE_6C = 8'h6C; // SEQ3
parameter CMD_WREN__96 = 8'h96; // SEQ4
parameter CMD_WRDI__91 = 8'h91; // SEQ4
parameter CMD_RDSR__05 = 8'h05; // SEQ5
parameter CMD_WRSR__6E = 8'h6E; // SEQ6
parameter CMD_ERAL__6D = 8'h6D; // SEQ4
parameter CMD_SETAL_67 = 8'h67; // SEQ4
// 
wire w_flag_SEQ1 = (i_frame_data_CMD==CMD_READ__03)? 1'b1 : 1'b0;
wire w_flag_SEQ2 = (i_frame_data_CMD==CMD_CRRD__06)? 1'b1 : 1'b0;
wire w_flag_SEQ3 = (i_frame_data_CMD==CMD_WRITE_6C)? 1'b1 : 1'b0;
wire w_flag_SEQ4; // NoMAK // no more frame after this.
wire w_flag_SEQ5 = (i_frame_data_CMD==CMD_RDSR__05)? 1'b1 : 1'b0;
wire w_flag_SEQ6 = (i_frame_data_CMD==CMD_WRSR__6E)? 1'b1 : 1'b0;
//
assign w_flag_SEQ4 = ~(w_flag_SEQ1 | w_flag_SEQ2 | w_flag_SEQ3 | w_flag_SEQ5 | w_flag_SEQ6); // otherwise

//}


//// monitoring i_SCIO_DI  base on 200kHz //{
reg [19:0] r_smp_SCIO_DI  ;
reg [9:0]  r_frame_data_DI;
reg [9:0]  r_frame_data_NG;
//
reg [7:0]  r_frame_data_DAT;
reg [7:0]  r_frame_data_STA;
//
reg r_flag_load__frame_data_DAT;
reg r_flag_load__frame_data_STA;


//
wire [19:0] w_next_smp_SCIO_DI = {r_smp_SCIO_DI[18:0], i_SCIO_DI};
wire [6:0]  w_idx_subframe;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_SCIO_DI   <=  {20{1'b1}};
		r_frame_data_DI <=  10'b0;
		r_frame_data_NG <=  10'b0;
		//
		r_frame_data_DAT <=  8'b0;
		r_frame_data_STA <=  8'b0;
		//
		r_flag_load__frame_data_DAT <= 1'b0;
		r_flag_load__frame_data_STA <= 1'b0;
	end
	else begin
		//if (r_clk_en_200K &  r_clk_en_100K) // in-phase
		if (r_clk_en_200K & ~r_clk_en_100K) begin // 180-phase
			r_smp_SCIO_DI   <= w_next_smp_SCIO_DI;
			//
			r_frame_data_DI[0] <= (~w_next_smp_SCIO_DI[2*0+1])&(w_next_smp_SCIO_DI[2*0+0]);
			r_frame_data_DI[1] <= (~w_next_smp_SCIO_DI[2*1+1])&(w_next_smp_SCIO_DI[2*1+0]);
			r_frame_data_DI[2] <= (~w_next_smp_SCIO_DI[2*2+1])&(w_next_smp_SCIO_DI[2*2+0]);
			r_frame_data_DI[3] <= (~w_next_smp_SCIO_DI[2*3+1])&(w_next_smp_SCIO_DI[2*3+0]);
			r_frame_data_DI[4] <= (~w_next_smp_SCIO_DI[2*4+1])&(w_next_smp_SCIO_DI[2*4+0]);
			r_frame_data_DI[5] <= (~w_next_smp_SCIO_DI[2*5+1])&(w_next_smp_SCIO_DI[2*5+0]);
			r_frame_data_DI[6] <= (~w_next_smp_SCIO_DI[2*6+1])&(w_next_smp_SCIO_DI[2*6+0]);
			r_frame_data_DI[7] <= (~w_next_smp_SCIO_DI[2*7+1])&(w_next_smp_SCIO_DI[2*7+0]);
			r_frame_data_DI[8] <= (~w_next_smp_SCIO_DI[2*8+1])&(w_next_smp_SCIO_DI[2*8+0]);
			r_frame_data_DI[9] <= (~w_next_smp_SCIO_DI[2*9+1])&(w_next_smp_SCIO_DI[2*9+0]);
			//
			r_frame_data_NG[0] <= ~(w_next_smp_SCIO_DI[2*0+1]^w_next_smp_SCIO_DI[2*0+0]);
			r_frame_data_NG[1] <= ~(w_next_smp_SCIO_DI[2*1+1]^w_next_smp_SCIO_DI[2*1+0]);
			r_frame_data_NG[2] <= ~(w_next_smp_SCIO_DI[2*2+1]^w_next_smp_SCIO_DI[2*2+0]);
			r_frame_data_NG[3] <= ~(w_next_smp_SCIO_DI[2*3+1]^w_next_smp_SCIO_DI[2*3+0]);
			r_frame_data_NG[4] <= ~(w_next_smp_SCIO_DI[2*4+1]^w_next_smp_SCIO_DI[2*4+0]);
			r_frame_data_NG[5] <= ~(w_next_smp_SCIO_DI[2*5+1]^w_next_smp_SCIO_DI[2*5+0]);
			r_frame_data_NG[6] <= ~(w_next_smp_SCIO_DI[2*6+1]^w_next_smp_SCIO_DI[2*6+0]);
			r_frame_data_NG[7] <= ~(w_next_smp_SCIO_DI[2*7+1]^w_next_smp_SCIO_DI[2*7+0]);
			r_frame_data_NG[8] <= ~(w_next_smp_SCIO_DI[2*8+1]^w_next_smp_SCIO_DI[2*8+0]);
			r_frame_data_NG[9] <= ~(w_next_smp_SCIO_DI[2*9+1]^w_next_smp_SCIO_DI[2*9+0]);
			//
			if (r_state==STATE_DAR_21 && w_idx_subframe==16) begin
				r_frame_data_DAT <= (r_frame_data_NG[7:0]==0)? r_frame_data_DI[7:0] : 8'b0;
				r_flag_load__frame_data_DAT <= 1'b1;
				end
			//
			if (r_state==STATE_STR_23 && w_idx_subframe==16) begin
				r_frame_data_STA <= (r_frame_data_NG[7:0]==0)? r_frame_data_DI[7:0] : 8'b0;
				r_flag_load__frame_data_STA <= 1'b1;
				end
			//
			end
		//
		else if (r_state==STATE_FIN_99) begin // clear condition
			r_smp_SCIO_DI   <=  {20{1'b1}};
			r_frame_data_DI <=  10'b0;
			r_frame_data_NG <=  10'b0;
			//
			r_frame_data_DAT <=  8'b0;
			r_frame_data_STA <=  8'b0;
			//
			r_flag_load__frame_data_DAT <= 1'b0;
			r_flag_load__frame_data_STA <= 1'b0;
		end
		//
		else begin // clear flag for one-pulse
			r_flag_load__frame_data_DAT <= 1'b0;
			r_flag_load__frame_data_STA <= 1'b0;
			end
		//
	end

//}



//// TODO: process state //{

//
reg r_frame_done;
assign w_frame_done = r_frame_done;

(* keep = "true" *) reg [6:0] r_idx_subframe;
assign w_idx_subframe = r_idx_subframe;

(* keep = "true" *) reg r_SCIO_OE;
assign w_SCIO_OE = r_SCIO_OE;
(* keep = "true" *) reg r_SCIO_DO;
assign w_SCIO_DO = r_SCIO_DO;

(* keep = "true" *) reg [17:0] r_buf_SCIO_DO;


// pattern for r_buf_SCIO_DO
//parameter PTTN_SHD__55R = 18'b10011001_10011001_01; // 0_1_0_1_0_1_0_1_LH
//parameter PTTN_DVA__A0R = 18'b01100110_10101010_01; // 1_0_1_0_0_0_0_0_LH
//parameter PTTN_DVA__A1R = 18'b01100110_10101001_01; // 1_0_1_0_0_0_0_0_LH // test A1R
//
wire [17:0] w_PTTN_SHD;
assign w_PTTN_SHD[17:16] = { ~i_frame_data_SHD[7], i_frame_data_SHD[7] };
assign w_PTTN_SHD[15:14] = { ~i_frame_data_SHD[6], i_frame_data_SHD[6] };
assign w_PTTN_SHD[13:12] = { ~i_frame_data_SHD[5], i_frame_data_SHD[5] };
assign w_PTTN_SHD[11:10] = { ~i_frame_data_SHD[4], i_frame_data_SHD[4] };
assign w_PTTN_SHD[ 9: 8] = { ~i_frame_data_SHD[3], i_frame_data_SHD[3] };
assign w_PTTN_SHD[ 7: 6] = { ~i_frame_data_SHD[2], i_frame_data_SHD[2] };
assign w_PTTN_SHD[ 5: 4] = { ~i_frame_data_SHD[1], i_frame_data_SHD[1] };
assign w_PTTN_SHD[ 3: 2] = { ~i_frame_data_SHD[0], i_frame_data_SHD[0] };
assign w_PTTN_SHD[ 1: 0] = 2'b01 ; // MAK
//
wire [17:0] w_PTTN_DVA;
assign w_PTTN_DVA[17:16] = { ~i_frame_data_DVA[7], i_frame_data_DVA[7] };
assign w_PTTN_DVA[15:14] = { ~i_frame_data_DVA[6], i_frame_data_DVA[6] };
assign w_PTTN_DVA[13:12] = { ~i_frame_data_DVA[5], i_frame_data_DVA[5] };
assign w_PTTN_DVA[11:10] = { ~i_frame_data_DVA[4], i_frame_data_DVA[4] };
assign w_PTTN_DVA[ 9: 8] = { ~i_frame_data_DVA[3], i_frame_data_DVA[3] };
assign w_PTTN_DVA[ 7: 6] = { ~i_frame_data_DVA[2], i_frame_data_DVA[2] };
assign w_PTTN_DVA[ 5: 4] = { ~i_frame_data_DVA[1], i_frame_data_DVA[1] };
assign w_PTTN_DVA[ 3: 2] = { ~i_frame_data_DVA[0], i_frame_data_DVA[0] };
assign w_PTTN_DVA[ 1: 0] = 2'b01 ; // MAK
//
wire [17:0] w_PTTN_CMD; // from i_frame_data_CMD + MAK/NoMAK ... 0-->HL, 1-->LH //{
assign w_PTTN_CMD[17:16] = { ~i_frame_data_CMD[7], i_frame_data_CMD[7] };
assign w_PTTN_CMD[15:14] = { ~i_frame_data_CMD[6], i_frame_data_CMD[6] };
assign w_PTTN_CMD[13:12] = { ~i_frame_data_CMD[5], i_frame_data_CMD[5] };
assign w_PTTN_CMD[11:10] = { ~i_frame_data_CMD[4], i_frame_data_CMD[4] };
assign w_PTTN_CMD[ 9: 8] = { ~i_frame_data_CMD[3], i_frame_data_CMD[3] };
assign w_PTTN_CMD[ 7: 6] = { ~i_frame_data_CMD[2], i_frame_data_CMD[2] };
assign w_PTTN_CMD[ 5: 4] = { ~i_frame_data_CMD[1], i_frame_data_CMD[1] };
assign w_PTTN_CMD[ 3: 2] = { ~i_frame_data_CMD[0], i_frame_data_CMD[0] };
assign w_PTTN_CMD[ 1: 0] = (w_flag_SEQ4)? 2'b10 : 2'b01 ; // NoMAK : MAK
//}
parameter PTTN_MAK___ONLY__XXR = 18'b00000000_00000000_01; // X_X_X_X_X_X_X_X_LH
parameter PTTN_NoMAK_ONLY__XXF = 18'b00000000_00000000_10; // X_X_X_X_X_X_X_X_HL
//
wire [17:0] w_PTTN_ADH; // from i_frame_data_ADH + MAK ... 0-->HL, 1-->LH //{
assign w_PTTN_ADH[17:16] = { ~i_frame_data_ADH[7], i_frame_data_ADH[7] };
assign w_PTTN_ADH[15:14] = { ~i_frame_data_ADH[6], i_frame_data_ADH[6] };
assign w_PTTN_ADH[13:12] = { ~i_frame_data_ADH[5], i_frame_data_ADH[5] };
assign w_PTTN_ADH[11:10] = { ~i_frame_data_ADH[4], i_frame_data_ADH[4] };
assign w_PTTN_ADH[ 9: 8] = { ~i_frame_data_ADH[3], i_frame_data_ADH[3] };
assign w_PTTN_ADH[ 7: 6] = { ~i_frame_data_ADH[2], i_frame_data_ADH[2] };
assign w_PTTN_ADH[ 5: 4] = { ~i_frame_data_ADH[1], i_frame_data_ADH[1] };
assign w_PTTN_ADH[ 3: 2] = { ~i_frame_data_ADH[0], i_frame_data_ADH[0] };
assign w_PTTN_ADH[ 1: 0] = 2'b01 ; // MAK
//}
wire [17:0] w_PTTN_ADL; // from i_frame_data_ADL + MAK ... 0-->HL, 1-->LH //{
assign w_PTTN_ADL[17:16] = { ~i_frame_data_ADL[7], i_frame_data_ADL[7] };
assign w_PTTN_ADL[15:14] = { ~i_frame_data_ADL[6], i_frame_data_ADL[6] };
assign w_PTTN_ADL[13:12] = { ~i_frame_data_ADL[5], i_frame_data_ADL[5] };
assign w_PTTN_ADL[11:10] = { ~i_frame_data_ADL[4], i_frame_data_ADL[4] };
assign w_PTTN_ADL[ 9: 8] = { ~i_frame_data_ADL[3], i_frame_data_ADL[3] };
assign w_PTTN_ADL[ 7: 6] = { ~i_frame_data_ADL[2], i_frame_data_ADL[2] };
assign w_PTTN_ADL[ 5: 4] = { ~i_frame_data_ADL[1], i_frame_data_ADL[1] };
assign w_PTTN_ADL[ 3: 2] = { ~i_frame_data_ADL[0], i_frame_data_ADL[0] };
assign w_PTTN_ADL[ 1: 0] = 2'b01 ; // MAK
//}

//
wire [11:0] w_num_bytes_DAT;
//
assign w_num_bytes_DAT = (i_num_bytes_DAT == 0)? 12'd1 : i_num_bytes_DAT;
//
reg [11:0] r_cnt_bytes_DAT; // count down for DAT frame

//
wire [7:0] w_frame_data_DAT;
//
wire [17:0] w_PTTN_DAT; // from i_frame_data_DAT + MAK/NoMAK ... 0-->HL, 1-->LH //{
assign w_PTTN_DAT[17:16] = (w_flag_SEQ3)? { ~w_frame_data_DAT[7], w_frame_data_DAT[7] } : 2'b00 ;
assign w_PTTN_DAT[15:14] = (w_flag_SEQ3)? { ~w_frame_data_DAT[6], w_frame_data_DAT[6] } : 2'b00 ;
assign w_PTTN_DAT[13:12] = (w_flag_SEQ3)? { ~w_frame_data_DAT[5], w_frame_data_DAT[5] } : 2'b00 ;
assign w_PTTN_DAT[11:10] = (w_flag_SEQ3)? { ~w_frame_data_DAT[4], w_frame_data_DAT[4] } : 2'b00 ;
assign w_PTTN_DAT[ 9: 8] = (w_flag_SEQ3)? { ~w_frame_data_DAT[3], w_frame_data_DAT[3] } : 2'b00 ;
assign w_PTTN_DAT[ 7: 6] = (w_flag_SEQ3)? { ~w_frame_data_DAT[2], w_frame_data_DAT[2] } : 2'b00 ;
assign w_PTTN_DAT[ 5: 4] = (w_flag_SEQ3)? { ~w_frame_data_DAT[1], w_frame_data_DAT[1] } : 2'b00 ;
assign w_PTTN_DAT[ 3: 2] = (w_flag_SEQ3)? { ~w_frame_data_DAT[0], w_frame_data_DAT[0] } : 2'b00 ;
// note NoMAK cases : 
//   w_num_bytes_DAT == 1
//   r_cnt_bytes_DAT == 2
wire  w_flag_DAT_NoMAK = ((w_num_bytes_DAT == 1)||(r_cnt_bytes_DAT == 2))? 1'b1 : 1'b0;
wire  w_flag_DAT_MAK   = ~w_flag_DAT_NoMAK;
assign w_PTTN_DAT[ 1: 0] = (w_flag_DAT_MAK)? 2'b01 : 2'b10 ; // MAK/NoMAK

//}

wire [17:0] w_PTTN_STA; // from i_frame_data_STA + NoMAK ... 0-->HL, 1-->LH //{
assign w_PTTN_STA[17:16] = { ~i_frame_data_STA[7], i_frame_data_STA[7] };
assign w_PTTN_STA[15:14] = { ~i_frame_data_STA[6], i_frame_data_STA[6] };
assign w_PTTN_STA[13:12] = { ~i_frame_data_STA[5], i_frame_data_STA[5] };
assign w_PTTN_STA[11:10] = { ~i_frame_data_STA[4], i_frame_data_STA[4] };
assign w_PTTN_STA[ 9: 8] = { ~i_frame_data_STA[3], i_frame_data_STA[3] };
assign w_PTTN_STA[ 7: 6] = { ~i_frame_data_STA[2], i_frame_data_STA[2] };
assign w_PTTN_STA[ 5: 4] = { ~i_frame_data_STA[1], i_frame_data_STA[1] };
assign w_PTTN_STA[ 3: 2] = { ~i_frame_data_STA[0], i_frame_data_STA[0] };
assign w_PTTN_STA[ 1: 0] = 2'b10 ; // NoMAK
//}

reg r_flag_send__frame_data_DAT;
(* keep = "true" *) reg r_flag_send__frame_data_STA;


// process r_state
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_state				<= STATE_RDY_00;
		r_frame_done        <=  1'b0;
		r_idx_subframe      <=  7'b0;
		r_SCIO_OE           <=  1'b0;
		r_SCIO_DO           <=  1'b1;
		r_buf_SCIO_DO       <= 18'b0;
		r_cnt_bytes_DAT     <= 12'b0;
		//
		r_flag_send__frame_data_DAT <=  1'b0;
		r_flag_send__frame_data_STA <=  1'b0;
		end 
	else case (r_state)
		STATE_RDY_00 : if (r_clk_en_100K) begin
			//
			r_frame_done    <= 1'b0;
			r_idx_subframe  <= 7'b0;
			r_buf_SCIO_DO   <= 18'b0;
			r_cnt_bytes_DAT <= 12'b0;
			//
			//$$ if (r_trig_frame) begin
			if (~i_reset_fifo & r_trig_frame) begin //$$ wait until reset_fifo is done.
			
				// start frame 
				r_state         <= (i_en_SBP)? STATE_SBP_01 : STATE_SHD_02;
				r_SCIO_OE       <= 1'b1;
				r_SCIO_DO       <= (i_en_SBP)? 1'b0         : 1'b1        ;
				end
			else begin 
				r_SCIO_OE       <= 1'b0;
				r_SCIO_DO       <= 1'b1;
				end
			//
			end
		STATE_SBP_01 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd63) begin
				r_state			<= STATE_SHD_02;
				r_idx_subframe  <= 7'b0;
				end
			else begin
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				end
			//
			r_SCIO_OE           <= 1'b1;
			//
			if (r_idx_subframe >= 7'd03)
				r_SCIO_DO       <= 1'b1;
			else 
				r_SCIO_DO       <= 1'b0;
			//
			end
		STATE_SHD_02 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd24) begin
				//// next r_state
				r_state         <= STATE_DVA_03;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE       <= 1'b1;                     // init r_SCIO_OE
				r_buf_SCIO_DO   <= {w_PTTN_DVA[16:0], 1'b0}; // set DO pattern
				r_SCIO_DO       <=  w_PTTN_DVA[17];          // init r_SCIO_DO
				//
				end
			else begin 
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				if (r_idx_subframe == 7'd0) 
					r_buf_SCIO_DO       <= w_PTTN_SHD;
				else if (r_idx_subframe >= 7'd04) 
					r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd22) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				if (r_idx_subframe < 7'd02)
					r_SCIO_DO       <= 1'b1;
				else if (r_idx_subframe < 7'd04)
					r_SCIO_DO       <= 1'b0;
				else
					r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//
				end
			//
			end
		STATE_DVA_03 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state
				r_state			<= STATE_CMD_04;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE       <= 1'b1;                     // init r_SCIO_OE
				r_buf_SCIO_DO   <= {w_PTTN_CMD[16:0], 1'b0}; // set DO pattern
				r_SCIO_DO       <=  w_PTTN_CMD[17];          // init r_SCIO_DO
				//
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end
		STATE_CMD_04 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				r_state			<= (w_flag_SEQ1)? STATE_ADH_10 : 
								   (w_flag_SEQ2)? STATE_DAR_21 : // read type frame
								   (w_flag_SEQ3)? STATE_ADH_10 : 
								   (w_flag_SEQ4)? STATE_FIN_99 : // finish
								   (w_flag_SEQ5)? STATE_STR_23 : // read type frame
								   (w_flag_SEQ6)? STATE_STW_22 : 
								                  STATE_FIN_99 ; // finish
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE		<= (w_flag_SEQ1)? 1'b1 : 
								   (w_flag_SEQ2)? 1'b0 : // read type frame
								   (w_flag_SEQ3)? 1'b1 : 
								   (w_flag_SEQ4)? 1'b0 : // finish
								   (w_flag_SEQ5)? 1'b0 : // read type frame
								   (w_flag_SEQ6)? 1'b1 : 
								                  1'b0 ; // finish
				//r_buf_SCIO_DO   <= {w_PTTN_CMD[16:0], 1'b0}; // set DO pattern
				r_buf_SCIO_DO	<= (w_flag_SEQ1)? {w_PTTN_ADH[16:0], 1'b0} : 
								   (w_flag_SEQ2)? {w_PTTN_DAT[16:0], 1'b0} : // read type frame
								   (w_flag_SEQ3)? {w_PTTN_ADH[16:0], 1'b0} : 
								   (w_flag_SEQ4)? {PTTN_NoMAK_ONLY__XXF[16:0], 1'b0} : // finish
								   (w_flag_SEQ5)? {PTTN_NoMAK_ONLY__XXF[16:0], 1'b0} : // read type frame
								   (w_flag_SEQ6)? {w_PTTN_STA[16:0], 1'b0} : 
								                  {PTTN_NoMAK_ONLY__XXF[16:0], 1'b0} ; // finish
				//r_SCIO_DO       <=  w_PTTN_CMD[17];          // init r_SCIO_DO
				r_SCIO_DO		<= (w_flag_SEQ1)?  w_PTTN_ADH[17] : 
								   (w_flag_SEQ2)?  w_PTTN_DAT[17] : // read type frame
								   (w_flag_SEQ3)?  w_PTTN_ADH[17] : 
								   (w_flag_SEQ4)?  PTTN_NoMAK_ONLY__XXF[17] : // finish
								   (w_flag_SEQ5)?  PTTN_NoMAK_ONLY__XXF[17] : // read type frame
								   (w_flag_SEQ6)?  w_PTTN_STA[17] : 
								                   PTTN_NoMAK_ONLY__XXF[17] ; // finish
				//
				r_cnt_bytes_DAT <= (w_flag_SEQ1)? 12'd0           : 
								   (w_flag_SEQ2)? w_num_bytes_DAT : // read type frame
								   (w_flag_SEQ3)? 12'd0           : 
								   (w_flag_SEQ4)? 12'd0           : // finish
								   (w_flag_SEQ5)? 12'd0           : // read type frame
								   (w_flag_SEQ6)? 12'd0           : 
								                  12'd0           ; // finish
				//
				r_flag_send__frame_data_STA <= (w_flag_SEQ6)? 1'b1 : 1'b0;         // update wr flag
				//}
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end
		STATE_ADH_10 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				r_state			<= STATE_ADL_11;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE		<= 1'b1; 
				r_buf_SCIO_DO   <= {w_PTTN_ADL[16:0], 1'b0}; // set DO pattern
				r_SCIO_DO       <=  w_PTTN_ADL[17];          // init r_SCIO_DO
				//}
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end
		STATE_ADL_11 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				r_state			<= (w_flag_SEQ1)? STATE_DAR_21 : // need to check data count
								   (w_flag_SEQ3)? STATE_DAW_20 : // need to check data count
								                  STATE_FIN_99 ;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE		<= (w_flag_SEQ1)? 1'b0 :
								   (w_flag_SEQ3)? 1'b1 :
								                  1'b0 ;
				r_buf_SCIO_DO	<= (w_flag_SEQ1)? {w_PTTN_DAT[16:0], 1'b0} :
								   (w_flag_SEQ3)? {w_PTTN_DAT[16:0], 1'b0}           :
								                  {PTTN_NoMAK_ONLY__XXF[16:0], 1'b0} ;
				r_SCIO_DO		<= (w_flag_SEQ1)? w_PTTN_DAT[17] : //$$ to revise
								   (w_flag_SEQ3)? w_PTTN_DAT[17]           :
								                  PTTN_NoMAK_ONLY__XXF[17] ;
				r_cnt_bytes_DAT <= (w_flag_SEQ1)? w_num_bytes_DAT : // need to check data count
								   (w_flag_SEQ3)? w_num_bytes_DAT : // need to check data count
								                  12'd0           ;
				r_flag_send__frame_data_DAT <= (w_flag_SEQ3)? 1'b1 : 1'b0; // update DAT wr flag
				//}
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end
		STATE_DAW_20 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				// count down data frame
				r_cnt_bytes_DAT <= r_cnt_bytes_DAT -1;
				//
				if (r_cnt_bytes_DAT == 1) begin
					//
					r_state			<= STATE_FIN_99;
					r_idx_subframe  <= 7'b0;
					r_SCIO_OE		<= 1'b0;
					//
					end
				else begin
					//
					r_state			<= STATE_DAW_20;
					r_idx_subframe  <= 7'b0;
					r_SCIO_OE		<= 1'b1;
					//
					r_buf_SCIO_DO   <= {w_PTTN_DAT[16:0], 1'b0}; // set DO pattern
					r_SCIO_DO       <=  w_PTTN_DAT[17];          // init r_SCIO_DO
					r_flag_send__frame_data_DAT <= 1'b1;         // update DAT wr flag
					//
					end
				//}
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end else begin // clear flag for one pulse
				r_flag_send__frame_data_DAT <= 1'b0;
			end
		STATE_DAR_21 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				// count down data frame
				r_cnt_bytes_DAT <= r_cnt_bytes_DAT -1;
				//
				if (r_cnt_bytes_DAT == 1) begin
					//
					r_state			<= STATE_FIN_99;
					r_idx_subframe  <= 7'b0;
					r_SCIO_OE		<= 1'b0; 
					//
					end
				else begin
					//
					r_state			<= STATE_DAR_21;
					r_idx_subframe  <= 7'b0;
					r_SCIO_OE		<= 1'b0; //read
					r_buf_SCIO_DO   <= {w_PTTN_DAT[16:0], 1'b0}; // set DO pattern
					r_SCIO_DO       <=  w_PTTN_DAT[17];          // init r_SCIO_DO
					//
					end
				//}
				end
			else begin
				//// common update //read //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE //read
				// r_SCIO_DO //read
				if (r_idx_subframe >= 7'd15 && r_idx_subframe < 7'd17) begin
					r_SCIO_OE       <= 1'b1;
					r_SCIO_DO       <= r_buf_SCIO_DO[17];
					end
				else begin
					r_SCIO_OE       <= 1'b0;
					r_SCIO_DO       <= 1'b0;
					end
				//}
				end
			//
			end
		STATE_STW_22 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				r_state			<= STATE_FIN_99;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE		<= 1'b0; 
				//}
				end
			else begin
				//// common update //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE
				if (r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end else begin // clear flag for one pulse
				r_flag_send__frame_data_STA <= 1'b0;
			end
		STATE_STR_23 : if (r_clk_en_100K) begin
			//
			if (r_idx_subframe >= 7'd19) begin
				//// next r_state //{
				r_state			<= STATE_FIN_99;
				r_idx_subframe  <= 7'b0;
				r_SCIO_OE		<= 1'b0; 
				//}
				end
			else begin
				//// common update //read //{
				// increase r_idx_subframe
				r_idx_subframe  <= r_idx_subframe + 1; // count up
				// set DO pattern
				r_buf_SCIO_DO       <= {r_buf_SCIO_DO[16:0], 1'b0};
				// r_SCIO_OE //read
				if (r_idx_subframe >= 7'd15 && r_idx_subframe < 7'd17) 
					r_SCIO_OE           <= 1'b1;
				else 
					r_SCIO_OE           <= 1'b0;
				// r_SCIO_DO
				r_SCIO_DO       <= r_buf_SCIO_DO[17];
				//}
				end
			//
			end
		STATE_FIN_99 : if (r_clk_en_100K) begin
			r_state				<= STATE_RDY_00;
			r_frame_done        <= 1'b1; // one pulse 100kHz
			end
		default:
			r_state				<= STATE_RDY_00;
		// 
	endcase
//}


//// o_frame_data_STA //{

// assign o_frame_data_STA = r_frame_data_STA; // test only

// load by r_flag_load__frame_data_STA
reg [7:0]  r_smp_frame_data_STA;
//
assign o_frame_data_STA = r_smp_frame_data_STA; 
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_frame_data_STA <=  8'b0;
	end
	else begin
		if (r_flag_load__frame_data_STA)
			r_smp_frame_data_STA <= r_frame_data_STA;
	end


//}


//// TODO: fifo interface //{

// ex: fifo_generator_3 
//   width "8-bit"
//   depth "16378 = 2^14"
//   standard read mode
//   rd 72MHz
//   wr 72MHz

// try: fifo_generator_3_1 // for i_frame_data_DAT // framer <-- pipe-in
//   width "8-bit"
//   depth "2048 = 2^11"
//   memory type : built-in FIFO
//   read mode: First Word Fall Through
//   rd 10MHz @ logic
//   wr 72MHz or 104MHz @ bus 

// try: fifo_generator_3_2 // for o_frame_data_DAT // framer --> pipe-out
//   width "8-bit"
//   depth "2048 = 2^11"
//   memory type : built-in FIFO
//   read mode: First Word Fall Through
//   rd 72MHz or 104MHz @ bus 
//   wr 10MHz @ logic

//$$ r_SCIO_DO update hold window added 
reg r_smp_flag_send__frame_data_DAT;
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_flag_send__frame_data_DAT <= 1'b0;
	end
	else begin
		//
		r_smp_flag_send__frame_data_DAT     <= r_flag_send__frame_data_DAT;
		//
	end

//wire       w_EEPROM_fifo_wr__rd_en = r_flag_send__frame_data_DAT;
wire       w_EEPROM_fifo_wr__rd_en = r_smp_flag_send__frame_data_DAT;
wire [7:0] w_EEPROM_fifo_wr__dout;
//
fifo_generator_3_1  EEPROM_fifo_wr_inst (
	.rst		(~reset_n | i_reset_fifo),  // input wire rst 
	//
	.wr_clk		(i_frame_data_DAT_wr_clk  ),  // input wire wr_clk
	.wr_en		(i_frame_data_DAT_wr_en   ),  // input wire wr_en
	.din		(i_frame_data_DAT         ),  // input wire [7 : 0] din
	.wr_ack		(   ),  // output wire wr_ack
	.overflow	(   ),  // output wire overflow
	.prog_full	(   ),  // set at 16378
	.full		(   ),  // output wire full
	//	
	.rd_clk		(clk                      ),  // input wire rd_clk
	.rd_en		(w_EEPROM_fifo_wr__rd_en  ),  // input wire rd_en
	.dout		(w_EEPROM_fifo_wr__dout   ),  // output wire [7 : 0] dout
	.valid		(   ),  // output wire valid
	.underflow	(   ),  // output wire underflow
	.prog_empty	(   ),  // set at 5
	.empty		(   )   // output wire empty
);


wire       w_EEPROM_fifo_rd__wr_en = r_flag_load__frame_data_DAT; 
wire [7:0] w_EEPROM_fifo_rd__din;
wire [7:0] w_EEPROM_fifo_rd__dout;
//
fifo_generator_3_2  EEPROM_fifo_rd_inst (
	.rst		(~reset_n | i_reset_fifo),  // input wire rst 
	//
	.wr_clk		(clk                      ),  // input wire wr_clk
	.wr_en		(w_EEPROM_fifo_rd__wr_en  ),  // input wire wr_en
	.din		(w_EEPROM_fifo_rd__din    ),  // input wire [7 : 0] din
	.wr_ack		(   ),  // output wire wr_ack
	.overflow	(   ),  // output wire overflow
	.prog_full	(   ),  // set at 16378
	.full		(   ),  // output wire full
	//	
	.rd_clk		(i_frame_data_DAT_rd_clk  ),  // input wire rd_clk
	.rd_en		(i_frame_data_DAT_rd_en   ),  // input wire rd_en
	.dout		(w_EEPROM_fifo_rd__dout   ),  // output wire [7 : 0] dout
	.valid		(   ),  // output wire valid
	.underflow	(   ),  // output wire underflow
	.prog_empty	(   ),  // set at 5
	.empty		(   )   // output wire empty
);

//// to bypass without FIFO
//assign w_frame_data_DAT = i_frame_data_DAT; // test only

//// to connect FIFO 
assign w_frame_data_DAT     = w_EEPROM_fifo_wr__dout; 
assign w_EEPROM_fifo_rd__din = r_frame_data_DAT     ;

//// PIPE out timing control : add one clock data delay
reg [7:0] r_EEPROM_fifo_rd__dout;
assign o_frame_data_DAT = r_EEPROM_fifo_rd__dout;
//
always @(posedge i_frame_data_DAT_rd_clk, negedge reset_n)
	if (!reset_n) begin
		r_EEPROM_fifo_rd__dout <=  8'b0;
	end
	else begin
		r_EEPROM_fifo_rd__dout <= w_EEPROM_fifo_rd__dout;
	end

//}


////
endmodule





