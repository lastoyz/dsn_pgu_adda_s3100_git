//// test_model__eeprom__11AA160T.v
//   test model for eeprom controller
//   test timing only for status register
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

//// TODO: test model ////
module test_model__eeprom__11AA160T (
	//
	input  wire clk    , // 10MHz
	input  wire reset_n, 
	
	// io to test
	output wire o_model_SCIO_DI,
	input  wire i_model_SCIO_DO,
	input  wire i_model_SCIO_OE,
	
	// status output
	output wire o_SBP_ack,
	output wire o_SHD_ack,
	output wire o_DVA_ack,
	output wire o_CMD_ack,
	output wire o_ADH_ack,
	output wire o_ADL_ack,
	output wire o_DAT_ack,
	output wire o_DAT_rdy,
	output wire o_STA_ack,
	output wire o_STA_rdy,
	
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

//// slow clock 200kHz from 10MHz //{
// 10MHz/200kHz = 50
reg r_clk_en_200K;
reg [6:0] r_cnt_clk;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_clk_en_200K <= 1'b0;
		r_cnt_clk     <= 7'b0;
	end
	else begin
		if (r_cnt_clk == 7'd01)
			r_clk_en_200K <= 1'b1;
		else 
			r_clk_en_200K <= 1'b0;
		//
		if (r_cnt_clk >= 7'd49)
			r_cnt_clk     <= 7'b0;
		else
			r_cnt_clk     <= r_cnt_clk + 1;
	end
//}

////  monitoring i_model_SCIO_DO base on 200kHz //{
reg [127:0] r_smp_SCIO_DO;
//
wire w_model_SCIO_DO = (i_model_SCIO_OE)? i_model_SCIO_DO : 1'b1; // assume data high during no-drive
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_SCIO_DO <= {128{1'b1}};
	end
	else begin
		if (r_clk_en_200K)
			r_smp_SCIO_DO <= {r_smp_SCIO_DO[126:0], w_model_SCIO_DO};
	end
//}

//// o_SBP_ack //{
reg r_SBP_ack;
reg r_SBP_low_chk; //  low check ...  2 clk @ 100kHz
reg r_SBP_hgh_chk; // high check ... 61 clk @ 100kHz
//
assign o_SBP_ack = r_SBP_ack;
//
wire w_clear_SBP_ack = 1'b0; // will be clear by data frame NG ...
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_SBP_ack     <= 1'b0;
		r_SBP_low_chk <= 1'b0;
		r_SBP_hgh_chk <= 1'b0;
	end
	else begin
		if (r_SBP_ack==1'b0 && r_smp_SCIO_DO[3:0]==4'b0) begin
			r_SBP_low_chk <= 1'b1;
			r_SBP_hgh_chk <= 1'b0;
			end
		else if (r_SBP_hgh_chk==1'b0 && r_SBP_low_chk==1'b1 && r_smp_SCIO_DO[121:0]=={122{1'b1}}) begin
			r_SBP_hgh_chk <= 1'b1;
			r_SBP_ack     <= 1'b1;
			end
		else if (w_clear_SBP_ack) begin 
			r_SBP_ack     <= 1'b0;
			r_SBP_low_chk <= 1'b0;
			r_SBP_hgh_chk <= 1'b0;
			end
	end

//}


//// o_SHD_ack //{

reg r_SHD_ack;
reg r_SHD_setup_chk; // setup check high 2 clk + low 1 clk @ 100kHz 
//
assign o_SHD_ack = r_SHD_ack;
//
wire [ 5:0] w_pattern_SHD_setup_6 =  6'b1111_00; // @ 200kHz
wire [35:0] w_pattern_SHD_data_36 = 36'b1100001111000011_1100001111000011; // @ 200kHz // 18'b10011001_10011001; // @ 100kHz
//
wire w_clear_SHD_ack; // = 1'b0; // will be clear by NoMAK ...

//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_SHD_ack       <= 1'b0;
		r_SHD_setup_chk <= 1'b0;
	end
	else begin
		if (r_SBP_ack==1'b1 && r_SHD_ack==1'b0 && r_smp_SCIO_DO[5:0]==w_pattern_SHD_setup_6) begin
			r_SHD_setup_chk <= 1'b1;
			end
		else if (r_SHD_ack==1'b0 && r_SHD_setup_chk==1'b1 && r_smp_SCIO_DO[35:0]==w_pattern_SHD_data_36) begin
			r_SHD_ack       <= 1'b1;
			end
		else if (w_clear_SHD_ack) begin 
			r_SHD_setup_chk <= 1'b0;
			r_SHD_ack       <= 1'b0;
			end
	end

//}


//// setup syn //{

reg [5:0] r_idx_frame;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_idx_frame     <= 6'h0;
	end
	else if (r_clk_en_200K) begin 
		if (r_SHD_ack)
			r_idx_frame <= (r_idx_frame<6'd39)? r_idx_frame + 1 : 6'h0;
	end
	else if (w_clear_SHD_ack) begin
		r_idx_frame     <= 6'h0;
	end

//
wire w_syn_DAT = (r_idx_frame==6'd1)? 1'b1 : 1'b0;
wire w_syn_MAK = (r_idx_frame==6'd5)? 1'b1 : 1'b0; 
wire w_syn_SAK = (r_idx_frame==6'd7)? 1'b1 : 1'b0; 
//}


//// monitor data frame //{
reg [7:0] r_frame_data__SCIO_DO; // convert from r_smp_SCIO_DO ... 0 for HL; 1 for LH.
reg [7:0] r_frame_data__NG;      // check edge ... 0 for edge detect; 1 for no-edge.
//
wire w_con_even = 1'b1;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_data__SCIO_DO <= 8'b0;
		r_frame_data__NG      <= 8'b0;
	end
	else begin
		if (r_clk_en_200K) begin 
			//
			r_frame_data__SCIO_DO[0] <= (w_con_even)? ( ~r_smp_SCIO_DO[ 0+2] & r_smp_SCIO_DO[ 0] ) : ( ~r_smp_SCIO_DO[ 0+3] & r_smp_SCIO_DO[ 0+1] ) ;
			r_frame_data__SCIO_DO[1] <= (w_con_even)? ( ~r_smp_SCIO_DO[ 4+2] & r_smp_SCIO_DO[ 4] ) : ( ~r_smp_SCIO_DO[ 4+3] & r_smp_SCIO_DO[ 4+1] ) ;
			r_frame_data__SCIO_DO[2] <= (w_con_even)? ( ~r_smp_SCIO_DO[ 8+2] & r_smp_SCIO_DO[ 8] ) : ( ~r_smp_SCIO_DO[ 8+3] & r_smp_SCIO_DO[ 8+1] ) ;
			r_frame_data__SCIO_DO[3] <= (w_con_even)? ( ~r_smp_SCIO_DO[12+2] & r_smp_SCIO_DO[12] ) : ( ~r_smp_SCIO_DO[12+3] & r_smp_SCIO_DO[12+1] ) ;
			r_frame_data__SCIO_DO[4] <= (w_con_even)? ( ~r_smp_SCIO_DO[16+2] & r_smp_SCIO_DO[16] ) : ( ~r_smp_SCIO_DO[16+3] & r_smp_SCIO_DO[16+1] ) ;
			r_frame_data__SCIO_DO[5] <= (w_con_even)? ( ~r_smp_SCIO_DO[20+2] & r_smp_SCIO_DO[20] ) : ( ~r_smp_SCIO_DO[20+3] & r_smp_SCIO_DO[20+1] ) ;
			r_frame_data__SCIO_DO[6] <= (w_con_even)? ( ~r_smp_SCIO_DO[24+2] & r_smp_SCIO_DO[24] ) : ( ~r_smp_SCIO_DO[24+3] & r_smp_SCIO_DO[24+1] ) ;
			r_frame_data__SCIO_DO[7] <= (w_con_even)? ( ~r_smp_SCIO_DO[28+2] & r_smp_SCIO_DO[28] ) : ( ~r_smp_SCIO_DO[28+3] & r_smp_SCIO_DO[28+1] ) ;
			// note verilog xor ^
			r_frame_data__NG[0]      <= (w_con_even)? ~( r_smp_SCIO_DO[ 0+2] ^ r_smp_SCIO_DO[ 0] ) : ~( r_smp_SCIO_DO[ 0+3] ^ r_smp_SCIO_DO[ 0+1] ) ;
			r_frame_data__NG[1]      <= (w_con_even)? ~( r_smp_SCIO_DO[ 4+2] ^ r_smp_SCIO_DO[ 4] ) : ~( r_smp_SCIO_DO[ 4+3] ^ r_smp_SCIO_DO[ 4+1] ) ;
			r_frame_data__NG[2]      <= (w_con_even)? ~( r_smp_SCIO_DO[ 8+2] ^ r_smp_SCIO_DO[ 8] ) : ~( r_smp_SCIO_DO[ 8+3] ^ r_smp_SCIO_DO[ 8+1] ) ;
			r_frame_data__NG[3]      <= (w_con_even)? ~( r_smp_SCIO_DO[12+2] ^ r_smp_SCIO_DO[12] ) : ~( r_smp_SCIO_DO[12+3] ^ r_smp_SCIO_DO[12+1] ) ;
			r_frame_data__NG[4]      <= (w_con_even)? ~( r_smp_SCIO_DO[16+2] ^ r_smp_SCIO_DO[16] ) : ~( r_smp_SCIO_DO[16+3] ^ r_smp_SCIO_DO[16+1] ) ;
			r_frame_data__NG[5]      <= (w_con_even)? ~( r_smp_SCIO_DO[20+2] ^ r_smp_SCIO_DO[20] ) : ~( r_smp_SCIO_DO[20+3] ^ r_smp_SCIO_DO[20+1] ) ;
			r_frame_data__NG[6]      <= (w_con_even)? ~( r_smp_SCIO_DO[24+2] ^ r_smp_SCIO_DO[24] ) : ~( r_smp_SCIO_DO[24+3] ^ r_smp_SCIO_DO[24+1] ) ;
			r_frame_data__NG[7]      <= (w_con_even)? ~( r_smp_SCIO_DO[28+2] ^ r_smp_SCIO_DO[28] ) : ~( r_smp_SCIO_DO[28+3] ^ r_smp_SCIO_DO[28+1] ) ;
			//
		end
	end


//
parameter MODEL_CMD_READ__03 = 8'h03; // SEQ1
parameter MODEL_CMD_CRRD__06 = 8'h06; // SEQ2
parameter MODEL_CMD_WRITE_6C = 8'h6C; // SEQ3
parameter MODEL_CMD_WREN__96 = 8'h96; // SEQ4
parameter MODEL_CMD_WRDI__91 = 8'h91; // SEQ4
parameter MODEL_CMD_RDSR__05 = 8'h05; // SEQ5
parameter MODEL_CMD_WRSR__6E = 8'h6E; // SEQ6
parameter MODEL_CMD_ERAL__6D = 8'h6D; // SEQ4
parameter MODEL_CMD_SETAL_67 = 8'h67; // SEQ4

//
reg [7:0] r_frame_data; // load data with sync
//
reg       r_frame_mack; // load master ack  with sync
//
reg       r_load_SHD; // 
reg       r_load_DVA; // 
reg       r_load_CMD; // 
reg       r_load_ADH; // 
reg       r_load_ADL; // 
reg       r_load_DAT; // 
reg       r_load_STA; // 
//
reg [7:0] r_frame_data_SHD;
reg [7:0] r_frame_data_DVA;
reg [7:0] r_frame_data_CMD;
reg [7:0] r_frame_data_ADH;
reg [7:0] r_frame_data_ADL;
reg [7:0] r_frame_data_DAT;
reg [7:0] r_frame_data_STA;

reg [11:0] r_cnt_wr_data_DAT;

//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_data       <= 8'b0;
		r_frame_data_SHD   <= 8'b0;
		r_frame_data_DVA   <= 8'b0;
		r_frame_data_CMD   <= 8'b0;
		r_frame_data_ADH   <= 8'b0;
		r_frame_data_ADL   <= 8'b0;
		r_frame_data_DAT   <= 8'b0;
		r_frame_data_STA   <= 8'b0;
		//
		r_cnt_wr_data_DAT  <= 12'd0;
		//
		r_frame_mack   <= 1'b0;
		//
		r_load_SHD     <= 1'b0;
		r_load_DVA     <= 1'b0;
		r_load_CMD     <= 1'b0;
		r_load_ADH     <= 1'b0;
		r_load_ADL     <= 1'b0;
		r_load_DAT     <= 1'b0;
		r_load_STA     <= 1'b0;
	end
	else begin
		if (r_clk_en_200K & r_SBP_ack) begin 
			//
			//if (r_frame_data__NG == 8'b0)
			//	r_frame_data <= r_frame_data__SCIO_DO;
			//
			// note ... r_frame_data__NG occurs ... reset r_SBP_ack ...
			// note ... NoMAK occurs ... reset r_SHD_ack ...
			//
			if (r_frame_data__NG == 8'b0 && w_syn_DAT) begin
				r_frame_data <= r_frame_data__SCIO_DO;
				//
				if (r_load_SHD==0) begin 
					r_load_SHD       <= 1'b1;
					r_frame_data_SHD <= r_frame_data__SCIO_DO;
					end
				//
				if (r_load_SHD && r_load_DVA==0) begin 
					r_load_DVA <= 1'b1;
					r_frame_data_DVA <= r_frame_data__SCIO_DO;
					end
				//
				if (r_load_DVA && r_load_CMD==0) begin 
					r_load_CMD <= 1'b1;
					r_frame_data_CMD <= r_frame_data__SCIO_DO;
					end
				//
				if (r_load_CMD && (r_frame_data_CMD==MODEL_CMD_READ__03||r_frame_data_CMD==MODEL_CMD_WRITE_6C) && r_load_ADH==0) begin 
					r_load_ADH <= 1'b1;
					r_frame_data_ADH <= r_frame_data__SCIO_DO;
					end
				//
				if (r_load_ADH && r_load_ADL==0) begin 
					r_load_ADL <= 1'b1;
					r_frame_data_ADL <= r_frame_data__SCIO_DO;
					end
				// MODEL_CMD_WRITE_6C // contiguous writing
				if (r_load_ADL && (r_frame_data_CMD==MODEL_CMD_WRITE_6C) ) begin 
					r_load_DAT <= 1'b1;
					r_frame_data_DAT <= r_frame_data__SCIO_DO;
					r_cnt_wr_data_DAT   <= r_cnt_wr_data_DAT + 1;
					end
				//
				if (r_load_CMD && (r_frame_data_CMD==MODEL_CMD_WRSR__6E) && r_load_STA==0) begin 
					r_load_STA <= 1'b1;
					r_frame_data_STA <= r_frame_data__SCIO_DO;
					end
				//
				end
			else if (r_frame_data__NG > 8'b0 && w_syn_DAT) begin
				r_frame_data <= 8'b0;
				end
			//
			if (r_frame_data__NG[0] == 1'b0 && w_syn_MAK) 
				r_frame_mack <= r_frame_data__SCIO_DO[0];
			else if (r_frame_data__NG[0] == 1'b1 && w_syn_MAK) 
				r_frame_mack <= 1'b0;
			//
		end
		else if (w_clear_SHD_ack) begin
			r_frame_data   <= 8'b0;
			r_frame_data_SHD   <= 8'b0;
			r_frame_data_DVA   <= 8'b0;
			r_frame_data_CMD   <= 8'b0;
			r_frame_data_ADH   <= 8'b0;
			r_frame_data_ADL   <= 8'b0;
			r_frame_data_DAT   <= 8'b0;
			r_frame_data_STA   <= 8'b0;
			//
			r_cnt_wr_data_DAT     <= 12'd0;
			//
			r_frame_mack   <= 1'b0;
			//
			r_load_SHD     <= 1'b0;
			r_load_DVA     <= 1'b0;
			r_load_CMD     <= 1'b0;
			r_load_ADH     <= 1'b0;
			r_load_ADL     <= 1'b0;
			r_load_DAT     <= 1'b0;
			r_load_STA     <= 1'b0;
		end
	end

// sample r_frame_mack
reg [1:0] r_smp_frame_mack;
reg r_fall_lat_frame_mack; // fall latch
reg r_clear_SHD_ack;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_frame_mack         <= 2'b0;
		r_fall_lat_frame_mack    <= 1'b0;
	end
	else begin
		r_smp_frame_mack   <= {r_smp_frame_mack[0], r_frame_mack};
		//
		// set by falling
		if ( (r_smp_frame_mack[1])&(~r_smp_frame_mack[0]) ) // falling
			r_fall_lat_frame_mack <= 1'b1;
		else if (w_syn_SAK)// clear by w_syn_SAK
			r_fall_lat_frame_mack <= 1'b0;		
	end
//
assign w_clear_SHD_ack = r_fall_lat_frame_mack & w_syn_SAK; 

// check DVA 
parameter OK__DVA__A0 = 8'hA0; 
wire w_NG_DVA = (r_load_DVA && r_frame_data_DVA!=OK__DVA__A0); // use it later...


//}


//// control output : o_model_SCIO_DI //{
wire w_model_SCIO_DI;
assign o_model_SCIO_DI = (i_model_SCIO_OE)? 1'b0: w_model_SCIO_DI;

// test patterns
parameter MODEL_PTTN_8B_DAT__C5 = 8'hC5;
parameter MODEL_PTTN_8B_STA__3A = 8'h3A;
//
wire [7:0] w_MODEL_PTTN_8B_DAT_ADD;
wire [7:0] w_MODEL_PTTN_8B_DAT = MODEL_PTTN_8B_DAT__C5 + w_MODEL_PTTN_8B_DAT_ADD;
//
wire [31:0] w_MODEL_PTTN_DAT;
assign w_MODEL_PTTN_DAT[31:28] = { ~w_MODEL_PTTN_8B_DAT[7], ~w_MODEL_PTTN_8B_DAT[7], w_MODEL_PTTN_8B_DAT[7], w_MODEL_PTTN_8B_DAT[7] };
assign w_MODEL_PTTN_DAT[27:24] = { ~w_MODEL_PTTN_8B_DAT[6], ~w_MODEL_PTTN_8B_DAT[6], w_MODEL_PTTN_8B_DAT[6], w_MODEL_PTTN_8B_DAT[6] };
assign w_MODEL_PTTN_DAT[23:20] = { ~w_MODEL_PTTN_8B_DAT[5], ~w_MODEL_PTTN_8B_DAT[5], w_MODEL_PTTN_8B_DAT[5], w_MODEL_PTTN_8B_DAT[5] };
assign w_MODEL_PTTN_DAT[19:16] = { ~w_MODEL_PTTN_8B_DAT[4], ~w_MODEL_PTTN_8B_DAT[4], w_MODEL_PTTN_8B_DAT[4], w_MODEL_PTTN_8B_DAT[4] };
assign w_MODEL_PTTN_DAT[15:12] = { ~w_MODEL_PTTN_8B_DAT[3], ~w_MODEL_PTTN_8B_DAT[3], w_MODEL_PTTN_8B_DAT[3], w_MODEL_PTTN_8B_DAT[3] };
assign w_MODEL_PTTN_DAT[11: 8] = { ~w_MODEL_PTTN_8B_DAT[2], ~w_MODEL_PTTN_8B_DAT[2], w_MODEL_PTTN_8B_DAT[2], w_MODEL_PTTN_8B_DAT[2] };
assign w_MODEL_PTTN_DAT[ 7: 4] = { ~w_MODEL_PTTN_8B_DAT[1], ~w_MODEL_PTTN_8B_DAT[1], w_MODEL_PTTN_8B_DAT[1], w_MODEL_PTTN_8B_DAT[1] };
assign w_MODEL_PTTN_DAT[ 3: 0] = { ~w_MODEL_PTTN_8B_DAT[0], ~w_MODEL_PTTN_8B_DAT[0], w_MODEL_PTTN_8B_DAT[0], w_MODEL_PTTN_8B_DAT[0] };
//
wire [31:0] w_MODEL_PTTN_STA;
assign w_MODEL_PTTN_STA[31:28] = { ~MODEL_PTTN_8B_STA__3A[7], ~MODEL_PTTN_8B_STA__3A[7], MODEL_PTTN_8B_STA__3A[7], MODEL_PTTN_8B_STA__3A[7] };
assign w_MODEL_PTTN_STA[27:24] = { ~MODEL_PTTN_8B_STA__3A[6], ~MODEL_PTTN_8B_STA__3A[6], MODEL_PTTN_8B_STA__3A[6], MODEL_PTTN_8B_STA__3A[6] };
assign w_MODEL_PTTN_STA[23:20] = { ~MODEL_PTTN_8B_STA__3A[5], ~MODEL_PTTN_8B_STA__3A[5], MODEL_PTTN_8B_STA__3A[5], MODEL_PTTN_8B_STA__3A[5] };
assign w_MODEL_PTTN_STA[19:16] = { ~MODEL_PTTN_8B_STA__3A[4], ~MODEL_PTTN_8B_STA__3A[4], MODEL_PTTN_8B_STA__3A[4], MODEL_PTTN_8B_STA__3A[4] };
assign w_MODEL_PTTN_STA[15:12] = { ~MODEL_PTTN_8B_STA__3A[3], ~MODEL_PTTN_8B_STA__3A[3], MODEL_PTTN_8B_STA__3A[3], MODEL_PTTN_8B_STA__3A[3] };
assign w_MODEL_PTTN_STA[11: 8] = { ~MODEL_PTTN_8B_STA__3A[2], ~MODEL_PTTN_8B_STA__3A[2], MODEL_PTTN_8B_STA__3A[2], MODEL_PTTN_8B_STA__3A[2] };
assign w_MODEL_PTTN_STA[ 7: 4] = { ~MODEL_PTTN_8B_STA__3A[1], ~MODEL_PTTN_8B_STA__3A[1], MODEL_PTTN_8B_STA__3A[1], MODEL_PTTN_8B_STA__3A[1] };
assign w_MODEL_PTTN_STA[ 3: 0] = { ~MODEL_PTTN_8B_STA__3A[0], ~MODEL_PTTN_8B_STA__3A[0], MODEL_PTTN_8B_STA__3A[0], MODEL_PTTN_8B_STA__3A[0] };


reg [39:0] r_smp_SCIO_DI; // sample @ 200kHz
reg [11:0] r_cnt_rd_data_DAT;
//
assign w_MODEL_PTTN_8B_DAT_ADD = r_cnt_rd_data_DAT[7:0];
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_SCIO_DI     <= {40{1'b1}};
		r_cnt_rd_data_DAT <= 12'd0;
	end
	else if (r_clk_en_200K) begin
		// MODEL_CMD_READ__03  r_load_ADL
		if      (r_load_ADL && (r_frame_data_CMD==MODEL_CMD_READ__03) && (r_idx_frame==6'd3)) begin // some command
			r_smp_SCIO_DI   <= { 4'b0011, w_MODEL_PTTN_DAT, {4{w_MODEL_PTTN_DAT[0]}} }; // SAK 0011 + DAT + (MAK)
			r_cnt_rd_data_DAT <= r_cnt_rd_data_DAT + 1;
			end
		// MODEL_CMD_CRRD__06
		else if ((r_frame_data_CMD==MODEL_CMD_CRRD__06) && (r_idx_frame==6'd3)) begin // some command
			r_smp_SCIO_DI   <= { 4'b0011, w_MODEL_PTTN_DAT, {4{w_MODEL_PTTN_DAT[0]}} }; // SAK 0011 + DAT + (MAK)
			r_cnt_rd_data_DAT <= r_cnt_rd_data_DAT + 1;
			end
		// MODEL_CMD_RDSR__05
		else if ((r_frame_data_CMD==MODEL_CMD_RDSR__05) && (r_idx_frame==6'd3)) // some command
			r_smp_SCIO_DI   <= { 4'b0011, w_MODEL_PTTN_STA, {4{w_MODEL_PTTN_STA[0]}} }; // SAK 0011 + DAT + (MAK)
		else if (r_frame_mack && (r_idx_frame==6'd3)) // SAK only
			r_smp_SCIO_DI   <= { 4'b0011, {32{1'b1}}, 4'b1111 }; // SAK 0011 + DAT + MAK
		//else if (r_frame_mack)
		else if (r_idx_frame > 0)
			r_smp_SCIO_DI   <= {r_smp_SCIO_DI[38:0], 1'b1};
	end
	else if (w_clear_SHD_ack) begin
		r_smp_SCIO_DI     <= {40{1'b1}};
		r_cnt_rd_data_DAT <= 12'd0;
	end

assign w_model_SCIO_DI = r_smp_SCIO_DI[39];


//}



endmodule





