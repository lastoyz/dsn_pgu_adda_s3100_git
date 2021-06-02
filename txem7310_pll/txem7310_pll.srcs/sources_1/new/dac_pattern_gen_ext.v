// dac_pattern_gen_ext.v
// - objective 
// 		generate test data pattern for DAC AD9783 data ports 
//  	support more functions:
//  		PGU-DUR32 : use duration 32 bits
//  		PGU-BIAS  : set DAC base code for DC bias
//  		PGU-INC   : usd DAC incremental code
//  		~
//  		PGU-MPRD  : minimum period
//  		PGU-FFRL  : FIFO reload all the time
//  		PGU-INF   : infinite repitition pulse
//  		~
//  		PGU-TRIG  : trig in and out
//
// -doc 
//		ad9783
//			https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
//
// - clock/reset port 
// 		clk			
// 		reset_n		
// 		i_clk_dacx_ref  // unused
// 		i_rstn_dacx_ref // unused
// 		i_clk_dac0_dco 
// 		i_rstn_dac0_dco
// 		i_clk_dac1_dco 
// 		i_rstn_dac1_dco
//
// - IO port
//		i_trig_dacx_ctrl
//		i_wire_dacx_data
//		o_wire_dacx_data
//
// - IO pin 
//		o_dac0_data_pin
//		o_dac1_data_pin

//// note
// - pattern generation modes 
//    CID, FCID
//    consider BIAS ( set base code at idle)
//

//		code-incremental-duration controlled test (CID test) //$$ new format 20210115
//			fixed sequence length of 8
//			data format 64b : (DAC code 16b + INC code 16b + duration count 32b)

//		FIFO-based CID test (FCID test) //$$ new format 20210115


`timescale 1ns / 1ps


// module ref
module dac_pattern_gen_ext (  //{
	// clock / reset
	input wire clk    , // system 10MHz 
	input wire reset_n,
	
	// DAC clock / reset
	input wire i_clk_dacx_ref  , // dacx ref clock in
	input wire i_rstn_dacx_ref , // dacx ref pll locked in 
	input wire i_clk_dac0_dco  , // dac0 / fifo clock in
	input wire i_rstn_dac0_dco , // 
	input wire i_clk_dac1_dco  , // dac1 / fifo clock in
	input wire i_rstn_dac1_dco , // 
	
	// DACZ control port 
	input  wire [31:0] i_trig_dacz_ctrl, // 
	input  wire [31:0] i_wire_dacz_data, // 
	output wire [31:0] o_wire_dacz_data, // 

	// DACX control port 
	//input  wire [31:0] i_trig_dacx_ctrl, // 
	//input  wire [31:0] i_wire_dacx_data, // 
	//output wire [31:0] o_wire_dacx_data, // 
	
	// DAC data port 
	output wire [15:0] o_dac0_data_pin, // 
	output wire [15:0] o_dac1_data_pin, // 
	
	// DAC activity flag 
	output wire        o_dac0_active_dco,
	output wire        o_dac1_active_dco,
	output wire        o_dac0_active_clk,
	output wire        o_dac1_active_clk,
	
	//// DACZ fifo interface //{
	
	// dac0_fifo_datinc
	output wire        o_dac0_fifo_datinc_rst  ,
	input  wire [31:0] i_dac0_fifo_datinc_dout ,
	output wire        o_dac0_fifo_datinc_rd_ck,
	output wire        o_dac0_fifo_datinc_rd_en,
	input  wire        i_dac0_fifo_datinc_empty,
	input  wire        i_dac0_fifo_datinc_valid,
	
	// dac0_fifo_dur____
	output wire        o_dac0_fifo_dur____rst  ,
	input  wire [31:0] i_dac0_fifo_dur____dout ,
	output wire        o_dac0_fifo_dur____rd_ck,
	output wire        o_dac0_fifo_dur____rd_en,
	input  wire        i_dac0_fifo_dur____empty,
	input  wire        i_dac0_fifo_dur____valid,
	
	// dac1_fifo_datinc
	output wire        o_dac1_fifo_datinc_rst  ,
	input  wire [31:0] i_dac1_fifo_datinc_dout ,
	output wire        o_dac1_fifo_datinc_rd_ck,
	output wire        o_dac1_fifo_datinc_rd_en,
	input  wire        i_dac1_fifo_datinc_empty,
	input  wire        i_dac1_fifo_datinc_valid,
	
	// dac1_fifo_dur____
	output wire        o_dac1_fifo_dur____rst  ,
	input  wire [31:0] i_dac1_fifo_dur____dout ,
	output wire        o_dac1_fifo_dur____rd_ck,
	output wire        o_dac1_fifo_dur____rd_en,
	input  wire        i_dac1_fifo_dur____empty,
	input  wire        i_dac1_fifo_dur____valid,
	
	//}
	
	//// fifo interface //{
	
	// fifo port
	output wire        o_dac0_fifo_rst  ,
	input  wire [31:0] i_dac0_fifo_dout ,
	output wire        c_dac0_fifo_rd_ck,
	output wire        o_dac0_fifo_rd_en,
	input  wire        i_dac0_fifo_empty,
	input  wire        i_dac0_fifo_valid,
	//
	output wire        o_dac1_fifo_rst  ,
	input  wire [31:0] i_dac1_fifo_dout ,
	output wire        c_dac1_fifo_rd_ck,
	output wire        o_dac1_fifo_rd_en,
	input  wire        i_dac1_fifo_empty,
	input  wire        i_dac1_fifo_valid,
	
	// fifo reload port
	output wire        o_dac0_fifo_reload1_rst  ,
	input  wire [31:0] i_dac0_fifo_reload1_dout ,
	output wire        c_dac0_fifo_reload1_rd_ck,
	output wire        o_dac0_fifo_reload1_rd_en,
	input  wire        i_dac0_fifo_reload1_empty,
	input  wire        i_dac0_fifo_reload1_valid,
	output wire [31:0] o_dac0_fifo_reload1_din   ,
	output wire        c_dac0_fifo_reload1_wr_ck ,
	output wire        o_dac0_fifo_reload1_wr_en ,
	input  wire        i_dac0_fifo_reload1_full  ,
	input  wire        i_dac0_fifo_reload1_wr_ack,
	//
	output wire        o_dac0_fifo_reload2_rst  ,
	input  wire [31:0] i_dac0_fifo_reload2_dout ,
	output wire        c_dac0_fifo_reload2_rd_ck,
	output wire        o_dac0_fifo_reload2_rd_en,
	input  wire        i_dac0_fifo_reload2_empty,
	input  wire        i_dac0_fifo_reload2_valid,
	output wire [31:0] o_dac0_fifo_reload2_din   ,
	output wire        c_dac0_fifo_reload2_wr_ck ,
	output wire        o_dac0_fifo_reload2_wr_en ,
	input  wire        i_dac0_fifo_reload2_full  ,
	input  wire        i_dac0_fifo_reload2_wr_ack,
	
	//
	output wire        o_dac1_fifo_reload1_rst  ,
	input  wire [31:0] i_dac1_fifo_reload1_dout ,
	output wire        c_dac1_fifo_reload1_rd_ck,
	output wire        o_dac1_fifo_reload1_rd_en,
	input  wire        i_dac1_fifo_reload1_empty,
	input  wire        i_dac1_fifo_reload1_valid,
	output wire [31:0] o_dac1_fifo_reload1_din   ,
	output wire        c_dac1_fifo_reload1_wr_ck ,
	output wire        o_dac1_fifo_reload1_wr_en ,
	input  wire        i_dac1_fifo_reload1_full  ,
	input  wire        i_dac1_fifo_reload1_wr_ack,
	//
	output wire        o_dac1_fifo_reload2_rst  ,
	input  wire [31:0] i_dac1_fifo_reload2_dout ,
	output wire        c_dac1_fifo_reload2_rd_ck,
	output wire        o_dac1_fifo_reload2_rd_en,
	input  wire        i_dac1_fifo_reload2_empty,
	input  wire        i_dac1_fifo_reload2_valid,
	output wire [31:0] o_dac1_fifo_reload2_din   ,
	output wire        c_dac1_fifo_reload2_wr_ck ,
	output wire        o_dac1_fifo_reload2_wr_en ,
	input  wire        i_dac1_fifo_reload2_full  ,
	input  wire        i_dac1_fifo_reload2_wr_ack,
	
	//}
	
	
	// flag
	output wire valid
);

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

//---------------------------------------------------------------//

//// trig-in : i_trig_dacx_ctrl // previously
//   bit[ 4] = write_control        
//   bit[ 5] = read_status          
//   bit[ 6] = write_repeat_period  
//   bit[ 7] = read_repeat_period   
//   bit[16] = dcs_write_adrs        // DCS
//   bit[17] = dcs_read_adrs         // DCS
//   bit[18] = dcs_write_data_dac0   // DCS
//   bit[19] = dcs_read_data_dac0    // DCS
//   bit[20] = dcs_write_data_dac1   // DCS
//   bit[21] = dcs_read_data_dac1    // DCS
//   bit[22] = dcs_run_test          // DCS
//   bit[23] = dcs_stop_test         // DCS
//   bit[24] = dcs_write_repeat      // DCS
//   bit[25] = dcs_read_repeat       // DCS
//   bit[28] = fdcs_run_test         // FDCS
//   bit[29] = fdcs_stop_test        // FDCS
//   bit[30] = fdcs_write_repeat     // FDCS
//   bit[31] = fdcs_read_repeat      // FDCS


//// trig-in : i_trig_dacz_ctrl // new control for CID and FCID
//   ...
//   bit[ 4] = write_control        
//   bit[ 5] = read_status          
//   bit[ 6] = write_repeat_period  
//   bit[ 7] = read_repeat_period   
//   ...
//   bit[ 8] = cid_adrs_wr    // CID or FCID
//   bit[ 9] = cid_adrs_rd    // CID or FCID
//   bit[10] = cid_data_wr    // CID or FCID
//   bit[11] = cid_data_rd    // CID or FCID
//   bit[12] = cid_ctrl_wr    // CID or FCID
//   bit[13] = cid_ctrl_rd    // CID or FCID
//   bit[14] = cid_stat_wr    // CID or FCID // not used 
//   bit[15] = cid_stat_rd    // CID or FCID

//   cid adrs map :  @adrs 32b = data 32b
//     @0x00000000 = bias code 16b data (16'b0 + INC code 16b) of DAC0 
//     @0x00000010 = bias code 16b data (16'b0 + INC code 16b) of DAC1 
//     @0x00000020 = repeat num 16b data (16'b0 + repeat num 16b) of DAC0 
//     @0x00000030 = repeat num 16b data (16'b0 + repeat num 16b) of DAC1 
//     @0x0000004n = code_inc 32b data (DAC code 16b + INC code 16b) of DAC0 seq 'n', where n = 0~7
//     @0x0000005n = code_inc 32b data (DAC code 16b + INC code 16b) of DAC1 seq 'n', where n = 0~7
//     @0x0000006n = duration 32b data of DAC0 seq 'n', where n = 0~7
//     @0x0000007n = duration 32b data of DAC1 seq 'n', where n = 0~7
//
//     @0x00001000 = num_fifo_data 16b of DAC0 FIFO
//     @0x00001010 = num_fifo_data 16b of DAC1 FIFO

//   cid ctrl bits : bit[] = ...
//     bit[0] = enable bias      at DAC0
//     bit[1] = enable bias      at DAC1
//     bit[2] = enable pulse-out at DAC0 from seq 'n'
//     bit[3] = enable pulse-out at DAC1 from seq 'n'
//     bit[4] = enable pulse-out at DAC0 from fifo data // not yet
//     bit[5] = enable pulse-out at DAC1 from fifo data // not yet
//     bit[6] = w_rst_dac0_fifo
//     bit[7] = w_rst_dac1_fifo

//   cid stat bits : bit[] = ...
//     bit[0] = flag_pulse_active_dac0 
//     bit[1] = flag_pulse_active_dac1 



//---------------------------------------------------------------//

//// TODO: CID (code-incremental-duration test) //{
//
//    data format 64b : (DAC code 16b + INC code 16b + duration count 32b)
//    fixed sequence length of 8
//    alternatively, FIFO data can be used.

////// reg and wire //{

//// trig //{
wire w_trig_cid_adrs_wr       = i_trig_dacz_ctrl[ 8];
wire w_trig_cid_adrs_rd       = i_trig_dacz_ctrl[ 9];
wire w_trig_cid_data_wr       = i_trig_dacz_ctrl[10];
wire w_trig_cid_data_rd       = i_trig_dacz_ctrl[11];
wire w_trig_cid_ctrl_wr       = i_trig_dacz_ctrl[12];
wire w_trig_cid_ctrl_rd       = i_trig_dacz_ctrl[13];
//wire w_trig_cid_stat_wr       = i_trig_dacz_ctrl[14]; // unused
wire w_trig_cid_stat_rd       = i_trig_dacz_ctrl[15];
//}

//// reg data //{
reg [31:0] r_cid_reg_adrs;
//reg [31:0] r_cid_reg_data; // not must

reg [15:0] r_cid_reg_dac0_bias_code; // @0x00000000
reg [15:0] r_cid_reg_dac1_bias_code; // @0x00000010

reg [15:0] r_cid_reg_dac0_num_repeat; // @0x00000020
reg [15:0] r_cid_reg_dac1_num_repeat; // @0x00000030
				
reg [15:0] r_cid_reg_dac0_dat_seq_0; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_1; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_2; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_3; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_4; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_5; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_6; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_dat_seq_7; // hi@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_0; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_1; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_2; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_3; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_4; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_5; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_6; // lo@0x0000004n
reg [15:0] r_cid_reg_dac0_inc_seq_7; // lo@0x0000004n
reg [31:0] r_cid_reg_dac0_dur_seq_0; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_1; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_2; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_3; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_4; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_5; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_6; //   @0x0000006n
reg [31:0] r_cid_reg_dac0_dur_seq_7; //   @0x0000006n
				
reg [15:0] r_cid_reg_dac1_dat_seq_0; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_1; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_2; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_3; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_4; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_5; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_6; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_dat_seq_7; // hi@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_0; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_1; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_2; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_3; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_4; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_5; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_6; // lo@0x0000005n
reg [15:0] r_cid_reg_dac1_inc_seq_7; // lo@0x0000005n
reg [31:0] r_cid_reg_dac1_dur_seq_0; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_1; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_2; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_3; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_4; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_5; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_6; //   @0x0000007n
reg [31:0] r_cid_reg_dac1_dur_seq_7; //   @0x0000007n

reg [15:0] r_cid_reg_dac0_num_ffdat; //  @0x00001000 = num_fifo_data 16b of DAC0 FIFO
reg [15:0] r_cid_reg_dac1_num_ffdat; //  @0x00001010 = num_fifo_data 16b of DAC1 FIFO

//}

//// reg control //{
reg [31:0] r_cid_reg_ctrl;
// 
wire w_enable_dac0_bias           = r_cid_reg_ctrl[0];
wire w_enable_dac1_bias           = r_cid_reg_ctrl[1];
wire w_enable_dac0_pulse_out_seq  = r_cid_reg_ctrl[2];
wire w_enable_dac1_pulse_out_seq  = r_cid_reg_ctrl[3];
//
wire w_enable_dac0_pulse_out_fifo = r_cid_reg_ctrl[4];
wire w_enable_dac1_pulse_out_fifo = r_cid_reg_ctrl[5];
wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6];
wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7];

//}

//// status //{
(* keep = "true" *) reg flag_cid_pulse_active_dac0;
(* keep = "true" *) reg flag_cid_pulse_active_dac1;
(* keep = "true" *) reg flag_fcid_pulse_active_dac0;
(* keep = "true" *) reg flag_fcid_pulse_active_dac1;
//
(* keep = "true" *) reg [1:0] flag_cid_sq_pulse_run_dac0; // seq test
(* keep = "true" *) reg [1:0] flag_cid_sq_pulse_run_dac1; // seq test
(* keep = "true" *) reg [1:0] flag_cid_ff_pulse_run_dac0; // fifo test
(* keep = "true" *) reg [1:0] flag_cid_ff_pulse_run_dac1; // fifo test
//
wire      w_rise_cid_sq_pulse_run_dac0 = (~flag_cid_sq_pulse_run_dac0[1]) & (flag_cid_sq_pulse_run_dac0[0]);
wire      w_rise_cid_sq_pulse_run_dac1 = (~flag_cid_sq_pulse_run_dac1[1]) & (flag_cid_sq_pulse_run_dac1[0]);
wire      w_rise_cid_ff_pulse_run_dac0 = (~flag_cid_ff_pulse_run_dac0[1]) & (flag_cid_ff_pulse_run_dac0[0]);
wire      w_rise_cid_ff_pulse_run_dac1 = (~flag_cid_ff_pulse_run_dac1[1]) & (flag_cid_ff_pulse_run_dac1[0]);

//
wire [31:0] w_cid_reg_stat;
//
assign w_cid_reg_stat[0]    = flag_cid_pulse_active_dac0;
assign w_cid_reg_stat[1]    = flag_cid_pulse_active_dac1;
assign w_cid_reg_stat[2]    = flag_cid_sq_pulse_run_dac0[0];
assign w_cid_reg_stat[3]    = flag_cid_sq_pulse_run_dac1[0];
assign w_cid_reg_stat[4]    = flag_cid_ff_pulse_run_dac0[0];
assign w_cid_reg_stat[5]    = flag_cid_ff_pulse_run_dac1[0];
assign w_cid_reg_stat[31:6] = 26'b0;
//}

//// reg output and sub-pulse-info //{
reg [15:0] r_cid_dat_out_dac0;
reg [15:0] r_cid_dat_out_dac1;
reg [15:0] r_fcid_dat_out_dac0;
reg [15:0] r_fcid_dat_out_dac1;

reg [15:0] r_cid_dat_inc_dac0; // inc info
reg [15:0] r_cid_dat_inc_dac1; // inc info
reg [15:0] r_fcid_dat_inc_dac0; // inc info
reg [15:0] r_fcid_dat_inc_dac1; // inc info

reg [ 2:0] r_cid_cnt_idx_dac0; // only for 8-seq
reg [31:0] r_cid_cnt_dur_dac0;
reg [15:0] r_cid_cnt_rpt_dac0;
reg [15:0] r_fcid_cnt_idx_dac0; // for fifo
reg [31:0] r_fcid_cnt_dur_dac0;
reg [15:0] r_fcid_cnt_rpt_dac0;

reg [ 2:0] r_cid_cnt_idx_dac1; // only for 8-seq
reg [31:0] r_cid_cnt_dur_dac1;
reg [15:0] r_cid_cnt_rpt_dac1;
reg [15:0] r_fcid_cnt_idx_dac1; // for fifo
reg [31:0] r_fcid_cnt_dur_dac1;
reg [15:0] r_fcid_cnt_rpt_dac1;


//}


//}

////// always and assign //{

//// r_cid_reg_adrs // [31:0] //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_adrs   <= 32'b0;  
	end
	else begin 
		if (w_trig_cid_adrs_wr) 
			r_cid_reg_adrs   <= i_wire_dacz_data[31:0];  
	end
//}


//// r_cid_reg_dac0_bias_code  // [15:0] // @0x00000000 //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac0_bias_code   <= 16'b0;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0000) ) 
			r_cid_reg_dac0_bias_code   <= i_wire_dacz_data[15:0];  
	end
//}

//// r_cid_reg_dac1_bias_code  // [15:0] // @0x00000010 //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac1_bias_code   <= 16'b0;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0010) ) 
			r_cid_reg_dac1_bias_code   <= i_wire_dacz_data[15:0];  
	end
//}

//// r_cid_reg_dac0_num_repeat // [15:0] // @0x00000020 //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac0_num_repeat   <= 16'd1;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0020) ) 
			r_cid_reg_dac0_num_repeat   <= i_wire_dacz_data[15:0];  
	end
//}

//// r_cid_reg_dac1_num_repeat // [15:0] // @0x00000030 //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac1_num_repeat   <= 16'd1;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0030) ) 
			r_cid_reg_dac1_num_repeat   <= i_wire_dacz_data[15:0];  
	end
//}

//// r_cid_reg_dac0_dat_seq_n // [15:0] // hi@0x0000004n 
//// r_cid_reg_dac0_inc_seq_n // [15:0] // lo@0x0000004n
//// r_cid_reg_dac0_dur_seq_n // [31:0] //   @0x0000006n 
//{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac0_dat_seq_0   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_1   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_2   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_3   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_4   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_5   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_6   <= 16'b0;  
		r_cid_reg_dac0_dat_seq_7   <= 16'b0;  
		//
		r_cid_reg_dac0_inc_seq_0   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_1   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_2   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_3   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_4   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_5   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_6   <= 16'b0;  
		r_cid_reg_dac0_inc_seq_7   <= 16'b0;  
		//
		r_cid_reg_dac0_dur_seq_0   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_1   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_2   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_3   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_4   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_5   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_6   <= 32'b0;  
		r_cid_reg_dac0_dur_seq_7   <= 32'b0;  
	end
	else begin 
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0040))  r_cid_reg_dac0_dat_seq_0   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0041))  r_cid_reg_dac0_dat_seq_1   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0042))  r_cid_reg_dac0_dat_seq_2   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0043))  r_cid_reg_dac0_dat_seq_3   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0044))  r_cid_reg_dac0_dat_seq_4   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0045))  r_cid_reg_dac0_dat_seq_5   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0046))  r_cid_reg_dac0_dat_seq_6   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0047))  r_cid_reg_dac0_dat_seq_7   <= i_wire_dacz_data[31:16];
		//
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0040))  r_cid_reg_dac0_inc_seq_0   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0041))  r_cid_reg_dac0_inc_seq_1   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0042))  r_cid_reg_dac0_inc_seq_2   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0043))  r_cid_reg_dac0_inc_seq_3   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0044))  r_cid_reg_dac0_inc_seq_4   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0045))  r_cid_reg_dac0_inc_seq_5   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0046))  r_cid_reg_dac0_inc_seq_6   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0047))  r_cid_reg_dac0_inc_seq_7   <= i_wire_dacz_data[15:0];
		//
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0060))  r_cid_reg_dac0_dur_seq_0   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0061))  r_cid_reg_dac0_dur_seq_1   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0062))  r_cid_reg_dac0_dur_seq_2   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0063))  r_cid_reg_dac0_dur_seq_3   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0064))  r_cid_reg_dac0_dur_seq_4   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0065))  r_cid_reg_dac0_dur_seq_5   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0066))  r_cid_reg_dac0_dur_seq_6   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0067))  r_cid_reg_dac0_dur_seq_7   <= i_wire_dacz_data[31:0];
	end
//}

//// r_cid_reg_dac1_dat_seq_n // [15:0] // hi@0x0000005n
//// r_cid_reg_dac1_inc_seq_n // [15:0] // lo@0x0000005n
//// r_cid_reg_dac1_dur_seq_n // [31:0] //   @0x0000007n
//{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac1_dat_seq_0   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_1   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_2   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_3   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_4   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_5   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_6   <= 16'b0;  
		r_cid_reg_dac1_dat_seq_7   <= 16'b0;  
		//
		r_cid_reg_dac1_inc_seq_0   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_1   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_2   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_3   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_4   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_5   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_6   <= 16'b0;  
		r_cid_reg_dac1_inc_seq_7   <= 16'b0;  
		//
		r_cid_reg_dac1_dur_seq_0   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_1   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_2   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_3   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_4   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_5   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_6   <= 32'b0;  
		r_cid_reg_dac1_dur_seq_7   <= 32'b0;  
	end
	else begin 
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0050))  r_cid_reg_dac1_dat_seq_0   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0051))  r_cid_reg_dac1_dat_seq_1   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0052))  r_cid_reg_dac1_dat_seq_2   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0053))  r_cid_reg_dac1_dat_seq_3   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0054))  r_cid_reg_dac1_dat_seq_4   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0055))  r_cid_reg_dac1_dat_seq_5   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0056))  r_cid_reg_dac1_dat_seq_6   <= i_wire_dacz_data[31:16];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0057))  r_cid_reg_dac1_dat_seq_7   <= i_wire_dacz_data[31:16];
		//
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0050))  r_cid_reg_dac1_inc_seq_0   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0051))  r_cid_reg_dac1_inc_seq_1   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0052))  r_cid_reg_dac1_inc_seq_2   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0053))  r_cid_reg_dac1_inc_seq_3   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0054))  r_cid_reg_dac1_inc_seq_4   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0055))  r_cid_reg_dac1_inc_seq_5   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0056))  r_cid_reg_dac1_inc_seq_6   <= i_wire_dacz_data[15:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0057))  r_cid_reg_dac1_inc_seq_7   <= i_wire_dacz_data[15:0];
		//
		if      (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0070))  r_cid_reg_dac1_dur_seq_0   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0071))  r_cid_reg_dac1_dur_seq_1   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0072))  r_cid_reg_dac1_dur_seq_2   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0073))  r_cid_reg_dac1_dur_seq_3   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0074))  r_cid_reg_dac1_dur_seq_4   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0075))  r_cid_reg_dac1_dur_seq_5   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0076))  r_cid_reg_dac1_dur_seq_6   <= i_wire_dacz_data[31:0];
		else if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_0077))  r_cid_reg_dac1_dur_seq_7   <= i_wire_dacz_data[31:0];
	end
//}

//// r_cid_reg_dac0_num_ffdat; // [15:0] // @0x00001000 = num_fifo_data 16b of DAC0 FIFO //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac0_num_ffdat   <= 16'd1;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_1000) ) 
			r_cid_reg_dac0_num_ffdat   <= i_wire_dacz_data[15:0];  
	end
//}

//// r_cid_reg_dac1_num_ffdat; // [15:0] // @0x00001010 = num_fifo_data 16b of DAC1 FIFO //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_dac1_num_ffdat   <= 16'd1;  
	end
	else begin 
		if (w_trig_cid_data_wr & (r_cid_reg_adrs==32'h_0000_1010) ) 
			r_cid_reg_dac1_num_ffdat   <= i_wire_dacz_data[15:0];  
	end
//}


//// r_cid_reg_ctrl // [31:0] //{
always @(posedge clk, negedge reset_n) 
	if (!reset_n) begin
		r_cid_reg_ctrl   <= 32'b0;  
	end
	else begin 
		if (w_trig_cid_ctrl_wr) 
			r_cid_reg_ctrl   <= i_wire_dacz_data[31:0];  
	end
//}


//// flag_cid_pulse_active_dac0 // @i_clk_dac0_dco vs @clk
//// flag_cid_pulse_active_dac1 // @i_clk_dac1_dco vs @clk
//// flag_cid_sq_pulse_run_dac0 // @i_clk_dac0_dco
//// flag_cid_sq_pulse_run_dac1 // @i_clk_dac1_dco


//// r_cid_dat_out_dac0 // [15:0] //{
//// r_cid_dat_inc_dac0 // [15:0]
//// r_cid_cnt_idx_dac0 // [ 2:0]
//// r_cid_cnt_dur_dac0 // [31:0]
//// r_cid_cnt_rpt_dac0 // [15:0] 
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		flag_cid_pulse_active_dac0   <=  1'b0;
		flag_cid_sq_pulse_run_dac0   <=  2'b0;
		//
		r_cid_dat_out_dac0           <=  16'b0;
		r_cid_dat_inc_dac0           <=  16'b0;
		//
		r_cid_cnt_idx_dac0           <=  3'b0;
		r_cid_cnt_dur_dac0           <=  32'b0;
		r_cid_cnt_rpt_dac0           <=  16'b0;
	end
	else begin
		// sampling 
		flag_cid_sq_pulse_run_dac0   <=  {flag_cid_sq_pulse_run_dac0[0], w_enable_dac0_pulse_out_seq };
		// detect rise
		if (w_rise_cid_sq_pulse_run_dac0) begin
			flag_cid_pulse_active_dac0   <=  1'b1; // set active 
			r_cid_dat_out_dac0           <=  16'b0; // to be BIAS
			r_cid_cnt_idx_dac0           <=  3'b0;  // clear count
			r_cid_cnt_dur_dac0           <=  32'b0; // clear count
			r_cid_cnt_rpt_dac0           <=  16'b0; // clear count
		end
		else if (flag_cid_pulse_active_dac0) begin
			//
			if (!flag_cid_sq_pulse_run_dac0[0]) begin
				flag_cid_pulse_active_dac0   <=  1'b0; // reset active
			end
			else if (r_cid_cnt_dur_dac0 == 0) begin // count down completed
				// idx
				r_cid_cnt_idx_dac0   <=  r_cid_cnt_idx_dac0 + 1; // count up
				// load duration
				r_cid_cnt_dur_dac0   <= (r_cid_cnt_idx_dac0==3'h0)? r_cid_reg_dac0_dur_seq_0 :
									    (r_cid_cnt_idx_dac0==3'h1)? r_cid_reg_dac0_dur_seq_1 :
									    (r_cid_cnt_idx_dac0==3'h2)? r_cid_reg_dac0_dur_seq_2 :
									    (r_cid_cnt_idx_dac0==3'h3)? r_cid_reg_dac0_dur_seq_3 :
									    (r_cid_cnt_idx_dac0==3'h4)? r_cid_reg_dac0_dur_seq_4 :
									    (r_cid_cnt_idx_dac0==3'h5)? r_cid_reg_dac0_dur_seq_5 :
									    (r_cid_cnt_idx_dac0==3'h6)? r_cid_reg_dac0_dur_seq_6 :
																    r_cid_reg_dac0_dur_seq_7 ;
				// load inc 
				r_cid_dat_inc_dac0   <= (r_cid_cnt_idx_dac0==3'h0)? r_cid_reg_dac0_inc_seq_0 :
				                        (r_cid_cnt_idx_dac0==3'h1)? r_cid_reg_dac0_inc_seq_1 :
				                        (r_cid_cnt_idx_dac0==3'h2)? r_cid_reg_dac0_inc_seq_2 :
				                        (r_cid_cnt_idx_dac0==3'h3)? r_cid_reg_dac0_inc_seq_3 :
				                        (r_cid_cnt_idx_dac0==3'h4)? r_cid_reg_dac0_inc_seq_4 :
				                        (r_cid_cnt_idx_dac0==3'h5)? r_cid_reg_dac0_inc_seq_5 :
				                        (r_cid_cnt_idx_dac0==3'h6)? r_cid_reg_dac0_inc_seq_6 :
				                     							    r_cid_reg_dac0_inc_seq_7 ;
				// output
				if ((r_cid_reg_dac0_num_repeat==0) ||
					(r_cid_cnt_rpt_dac0 <  r_cid_reg_dac0_num_repeat) ||
					(r_cid_cnt_rpt_dac0 == r_cid_reg_dac0_num_repeat && r_cid_cnt_idx_dac0!=3'h0) ) begin
					// normal output
					r_cid_dat_out_dac0           <= (r_cid_cnt_idx_dac0==3'h0)? r_cid_reg_dac0_dat_seq_0 :
					                                (r_cid_cnt_idx_dac0==3'h1)? r_cid_reg_dac0_dat_seq_1 :
					                                (r_cid_cnt_idx_dac0==3'h2)? r_cid_reg_dac0_dat_seq_2 :
					                                (r_cid_cnt_idx_dac0==3'h3)? r_cid_reg_dac0_dat_seq_3 :
					                                (r_cid_cnt_idx_dac0==3'h4)? r_cid_reg_dac0_dat_seq_4 :
					                                (r_cid_cnt_idx_dac0==3'h5)? r_cid_reg_dac0_dat_seq_5 :
					                                (r_cid_cnt_idx_dac0==3'h6)? r_cid_reg_dac0_dat_seq_6 :
					                                						    r_cid_reg_dac0_dat_seq_7 ;
				end
				else begin
					// finished output
					flag_cid_pulse_active_dac0   <=  1'b0; // reset active
					r_cid_dat_out_dac0           <=  16'b0; // to be BIAS
				end
				// repeat
				if (r_cid_cnt_idx_dac0==3'h0) begin // every pulse
					if ((r_cid_reg_dac0_num_repeat==0) || (r_cid_cnt_rpt_dac0 <  r_cid_reg_dac0_num_repeat))
						r_cid_cnt_rpt_dac0  <= r_cid_cnt_rpt_dac0 + 1; // count up
				end
				
			end
			else begin
				// duration
				r_cid_cnt_dur_dac0  <=  r_cid_cnt_dur_dac0 - 1; // count down
				// output 
				//$$ must come with incremental code
				r_cid_dat_out_dac0  <=  r_cid_dat_out_dac0 + r_cid_dat_inc_dac0; 
			end
			
		end 
		else begin
			r_cid_dat_out_dac0           <=  16'b0; // to be BIAS
		end
	end 
end
//}

//// r_cid_dat_out_dac1 // [15:0] //{
//// r_cid_dat_inc_dac1 // [15:0]
//// r_cid_cnt_idx_dac1 // [ 2:0]
//// r_cid_cnt_dur_dac1 // [31:0]
//// r_cid_cnt_rpt_dac1 // [15:0]
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		flag_cid_pulse_active_dac1   <=  1'b0;
		flag_cid_sq_pulse_run_dac1   <=  2'b0;
		//
		r_cid_dat_out_dac1           <=  16'b0;
		r_cid_dat_inc_dac1           <=  16'b0;
		//
		r_cid_cnt_idx_dac1           <=  3'b0;
		r_cid_cnt_dur_dac1           <=  32'b0;
		r_cid_cnt_rpt_dac1           <=  16'b0;
	end
	else begin
		// sampling 
		flag_cid_sq_pulse_run_dac1   <=  {flag_cid_sq_pulse_run_dac1[0], w_enable_dac1_pulse_out_seq };
		// detect rise
		if (w_rise_cid_sq_pulse_run_dac1) begin
			flag_cid_pulse_active_dac1   <=  1'b1; // set active 
			r_cid_dat_out_dac1           <=  16'b0; // to be BIAS
			r_cid_cnt_idx_dac1           <=  3'b0;  // clear count
			r_cid_cnt_dur_dac1           <=  32'b0; // clear count
			r_cid_cnt_rpt_dac1           <=  16'b0; // clear count
		end
		else if (flag_cid_pulse_active_dac1) begin
			//
			if (!flag_cid_sq_pulse_run_dac1[0]) begin
				flag_cid_pulse_active_dac1   <=  1'b0; // reset active
			end
			else if (r_cid_cnt_dur_dac1 == 0) begin // count down completed
				// idx
				r_cid_cnt_idx_dac1   <=  r_cid_cnt_idx_dac1 + 1; // count up
				// load duration
				r_cid_cnt_dur_dac1   <= (r_cid_cnt_idx_dac1==3'h0)? r_cid_reg_dac1_dur_seq_0 :
									    (r_cid_cnt_idx_dac1==3'h1)? r_cid_reg_dac1_dur_seq_1 :
									    (r_cid_cnt_idx_dac1==3'h2)? r_cid_reg_dac1_dur_seq_2 :
									    (r_cid_cnt_idx_dac1==3'h3)? r_cid_reg_dac1_dur_seq_3 :
									    (r_cid_cnt_idx_dac1==3'h4)? r_cid_reg_dac1_dur_seq_4 :
									    (r_cid_cnt_idx_dac1==3'h5)? r_cid_reg_dac1_dur_seq_5 :
									    (r_cid_cnt_idx_dac1==3'h6)? r_cid_reg_dac1_dur_seq_6 :
																    r_cid_reg_dac1_dur_seq_7 ;
				// load inc 
				r_cid_dat_inc_dac1   <= (r_cid_cnt_idx_dac1==3'h0)? r_cid_reg_dac1_inc_seq_0 :
				                        (r_cid_cnt_idx_dac1==3'h1)? r_cid_reg_dac1_inc_seq_1 :
				                        (r_cid_cnt_idx_dac1==3'h2)? r_cid_reg_dac1_inc_seq_2 :
				                        (r_cid_cnt_idx_dac1==3'h3)? r_cid_reg_dac1_inc_seq_3 :
				                        (r_cid_cnt_idx_dac1==3'h4)? r_cid_reg_dac1_inc_seq_4 :
				                        (r_cid_cnt_idx_dac1==3'h5)? r_cid_reg_dac1_inc_seq_5 :
				                        (r_cid_cnt_idx_dac1==3'h6)? r_cid_reg_dac1_inc_seq_6 :
				                     							    r_cid_reg_dac1_inc_seq_7 ;
				// output
				if ((r_cid_reg_dac1_num_repeat==0) ||
					(r_cid_cnt_rpt_dac1 <  r_cid_reg_dac1_num_repeat) ||
					(r_cid_cnt_rpt_dac1 == r_cid_reg_dac1_num_repeat && r_cid_cnt_idx_dac1!=3'h0) ) begin
					// normal output
					r_cid_dat_out_dac1           <= (r_cid_cnt_idx_dac1==3'h0)? r_cid_reg_dac1_dat_seq_0 :
					                                (r_cid_cnt_idx_dac1==3'h1)? r_cid_reg_dac1_dat_seq_1 :
					                                (r_cid_cnt_idx_dac1==3'h2)? r_cid_reg_dac1_dat_seq_2 :
					                                (r_cid_cnt_idx_dac1==3'h3)? r_cid_reg_dac1_dat_seq_3 :
					                                (r_cid_cnt_idx_dac1==3'h4)? r_cid_reg_dac1_dat_seq_4 :
					                                (r_cid_cnt_idx_dac1==3'h5)? r_cid_reg_dac1_dat_seq_5 :
					                                (r_cid_cnt_idx_dac1==3'h6)? r_cid_reg_dac1_dat_seq_6 :
					                                						    r_cid_reg_dac1_dat_seq_7 ;
				end
				else begin
					// finished output
					flag_cid_pulse_active_dac1   <=  1'b0; // reset active
					r_cid_dat_out_dac1           <=  16'b0; // to be BIAS
				end
				// repeat
				if (r_cid_cnt_idx_dac1==3'h0) begin // every pulse
					if ((r_cid_reg_dac1_num_repeat==0) || (r_cid_cnt_rpt_dac1 <  r_cid_reg_dac1_num_repeat))
						r_cid_cnt_rpt_dac1  <= r_cid_cnt_rpt_dac1 + 1; // count up
				end
				
			end
			else begin
				// duration
				r_cid_cnt_dur_dac1  <=  r_cid_cnt_dur_dac1 - 1; // count down
				// output 
				//$$ must come with incremental code
				r_cid_dat_out_dac1  <=  r_cid_dat_out_dac1 + r_cid_dat_inc_dac1; 
			end
			
		end 
		else begin
			r_cid_dat_out_dac1           <=  16'b0; // to be BIAS
		end
	end 
end
//}


////---- fifo-based cid ----////

wire [31:0] w_fcid_cnt_dur_dac0; // = from fifo
wire [15:0] w_fcid_dat_inc_dac0; // = from fifo
wire [15:0] w_fcid_dat_out_dac0; // = from fifo
wire [31:0] w_fcid_cnt_dur_dac1; // = from fifo
wire [15:0] w_fcid_dat_inc_dac1; // = from fifo
wire [15:0] w_fcid_dat_out_dac1; // = from fifo

wire        w_fcid_data_load_dac0 = (r_fcid_cnt_dur_dac0==0)? flag_fcid_pulse_active_dac0 : 1'b0;
wire        w_fcid_data_load_dac1 = (r_fcid_cnt_dur_dac1==0)? flag_fcid_pulse_active_dac1 : 1'b0;

//// flag_fcid_pulse_active_dac0
//// flag_fcid_pulse_active_dac1
//// flag_cid_ff_pulse_run_dac0 // @i_clk_dac0_dco
//// flag_cid_ff_pulse_run_dac1 // @i_clk_dac1_dco

//// r_cid_reg_dac0_num_repeat // used in cid and fcid
//// r_cid_reg_dac1_num_repeat // used in cid and fcid
//// r_cid_reg_dac0_num_ffdat  // used in fcid
//// r_cid_reg_dac1_num_ffdat  // used in fcid


//// r_fcid_dat_out_dac0 // [15:0] //{
//// r_fcid_dat_inc_dac0 // [15:0]
//// r_fcid_cnt_idx_dac0 // [15:0] // up to max num of fifo data
//// r_fcid_cnt_dur_dac0 // [31:0]
//// r_fcid_cnt_rpt_dac0 // [15:0]

always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		flag_fcid_pulse_active_dac0   <=   1'b0;
		//
		flag_cid_ff_pulse_run_dac0    <=   2'b0;
		//
		r_fcid_dat_out_dac0           <=  16'b0;
		r_fcid_dat_inc_dac0           <=  16'b0;
		//
		r_fcid_cnt_idx_dac0           <=  16'b0;
		r_fcid_cnt_dur_dac0           <=  32'b0;
		r_fcid_cnt_rpt_dac0           <=  16'b0;
	end
	else begin
		// sampling 
		flag_cid_ff_pulse_run_dac0   <=  {flag_cid_ff_pulse_run_dac0[0], w_enable_dac0_pulse_out_fifo};
		
		// detect rise
		if (w_rise_cid_ff_pulse_run_dac0) begin
			flag_fcid_pulse_active_dac0   <=   1'b1; // set active 
			r_fcid_dat_out_dac0           <=  16'b0; // to be BIAS
			r_fcid_cnt_idx_dac0           <=  16'b0;  // clear count
			r_fcid_cnt_dur_dac0           <=  32'b0; // clear count
			r_fcid_cnt_rpt_dac0           <=  16'b0; // clear count
		end
		else if (flag_fcid_pulse_active_dac0) begin
			//
			if (!flag_cid_ff_pulse_run_dac0[0]) begin // pulse off
				flag_fcid_pulse_active_dac0   <=   1'b0; // reset active
			end
			else if (r_fcid_cnt_dur_dac0 == 0) begin // duration count down completed
				// idx count up and ... zero when finish
				r_fcid_cnt_idx_dac0   <=  (r_fcid_cnt_idx_dac0 + 1 >= r_cid_reg_dac0_num_ffdat)? 
											16'b0                  :
											r_fcid_cnt_idx_dac0 + 1; // count up
				// load duration
				r_fcid_cnt_dur_dac0   <= w_fcid_cnt_dur_dac0; // test only
				// load inc 
				r_fcid_dat_inc_dac0   <= w_fcid_dat_inc_dac0; // test only
				// output
				if ((r_cid_reg_dac0_num_repeat==0) ||
					(r_fcid_cnt_rpt_dac0 <  r_cid_reg_dac0_num_repeat) ||
					(r_fcid_cnt_rpt_dac0 == r_cid_reg_dac0_num_repeat && r_fcid_cnt_idx_dac0!=16'h0) ) begin
					// load normal output
					r_fcid_dat_out_dac0   <= w_fcid_dat_out_dac0; // test only
				end
				else begin
					// finished output
					flag_fcid_pulse_active_dac0   <=  1'b0; // reset active
					r_fcid_dat_out_dac0           <=  16'b0; // to be BIAS
				end
				// repeat
				if (r_fcid_cnt_idx_dac0==16'h0) begin // every pulse
					if ((r_cid_reg_dac0_num_repeat==0) || (r_fcid_cnt_rpt_dac0 <  r_cid_reg_dac0_num_repeat))
						r_fcid_cnt_rpt_dac0  <= r_fcid_cnt_rpt_dac0 + 1; // count up
				end
				
			end
			else begin
				// duration
				r_fcid_cnt_dur_dac0  <=  r_fcid_cnt_dur_dac0 - 1; // count down
				// output 
				//$$ must come with incremental code
				r_fcid_dat_out_dac0  <=  r_fcid_dat_out_dac0 + r_fcid_dat_inc_dac0; 
			end
			
		end 
		else begin
			r_fcid_dat_out_dac0           <=  16'b0; // to be BIAS
		end
	end 
end
//}

//// r_fcid_dat_out_dac1 // [15:0] //{
//// r_fcid_dat_inc_dac1 // [15:0]
//// r_fcid_cnt_idx_dac1 // [15:0] // up to max num of fifo data
//// r_fcid_cnt_dur_dac1 // [31:0]
//// r_fcid_cnt_rpt_dac1 // [15:0]
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		flag_fcid_pulse_active_dac1   <=   1'b0;
		//
		flag_cid_ff_pulse_run_dac1    <=   2'b0;
		//
		r_fcid_dat_out_dac1           <=  16'b0;
		r_fcid_dat_inc_dac1           <=  16'b0;
		//
		r_fcid_cnt_idx_dac1           <=  16'b0;
		r_fcid_cnt_dur_dac1           <=  32'b0;
		r_fcid_cnt_rpt_dac1           <=  16'b0;
	end
	else begin
		// sampling 
		flag_cid_ff_pulse_run_dac1   <=  {flag_cid_ff_pulse_run_dac1[0], w_enable_dac1_pulse_out_fifo};
		
		// detect rise
		if (w_rise_cid_ff_pulse_run_dac1) begin
			flag_fcid_pulse_active_dac1   <=   1'b1; // set active 
			r_fcid_dat_out_dac1           <=  16'b0; // to be BIAS
			r_fcid_cnt_idx_dac1           <=  16'b0;  // clear count
			r_fcid_cnt_dur_dac1           <=  32'b0; // clear count
			r_fcid_cnt_rpt_dac1           <=  16'b0; // clear count
		end
		else if (flag_fcid_pulse_active_dac1) begin
			//
			if (!flag_cid_ff_pulse_run_dac1[0]) begin // pulse off
				flag_fcid_pulse_active_dac1   <=   1'b0; // reset active
			end
			else if (r_fcid_cnt_dur_dac1 == 0) begin // duration count down completed
				// idx count up and ... zero when finish
				r_fcid_cnt_idx_dac1   <=  (r_fcid_cnt_idx_dac1 + 1 >= r_cid_reg_dac1_num_ffdat)? 
											16'b0                  :
											r_fcid_cnt_idx_dac1 + 1; // count up
				// load duration
				r_fcid_cnt_dur_dac1   <= w_fcid_cnt_dur_dac1; // test only
				// load inc 
				r_fcid_dat_inc_dac1   <= w_fcid_dat_inc_dac1; // test only
				// output
				if ((r_cid_reg_dac1_num_repeat==0) ||
					(r_fcid_cnt_rpt_dac1 <  r_cid_reg_dac1_num_repeat) ||
					(r_fcid_cnt_rpt_dac1 == r_cid_reg_dac1_num_repeat && r_fcid_cnt_idx_dac1!=16'h0) ) begin
					// load normal output
					r_fcid_dat_out_dac1   <= w_fcid_dat_out_dac1; // test only
				end
				else begin
					// finished output
					flag_fcid_pulse_active_dac1   <=  1'b0; // reset active
					r_fcid_dat_out_dac1           <=  16'b0; // to be BIAS
				end
				// repeat
				if (r_fcid_cnt_idx_dac1==16'h0) begin // every pulse
					if ((r_cid_reg_dac1_num_repeat==0) || (r_fcid_cnt_rpt_dac1 <  r_cid_reg_dac1_num_repeat))
						r_fcid_cnt_rpt_dac1  <= r_fcid_cnt_rpt_dac1 + 1; // count up
				end
				
			end
			else begin
				// duration
				r_fcid_cnt_dur_dac1  <=  r_fcid_cnt_dur_dac1 - 1; // count down
				// output 
				//$$ must come with incremental code
				r_fcid_dat_out_dac1  <=  r_fcid_dat_out_dac1 + r_fcid_dat_inc_dac1; 
			end
			
		end 
		else begin
			r_fcid_dat_out_dac1           <=  16'b0; // to be BIAS
		end
	end 
end
//}


//// DACZ fifo control //{

// fifo reset
assign o_dac0_fifo_datinc_rst = ~reset_n | w_rst_dac0_fifo ;
assign o_dac0_fifo_dur____rst = ~reset_n | w_rst_dac0_fifo ;
assign o_dac1_fifo_datinc_rst = ~reset_n | w_rst_dac1_fifo ;
assign o_dac1_fifo_dur____rst = ~reset_n | w_rst_dac1_fifo ;

// fifo read clock 
assign o_dac0_fifo_datinc_rd_ck = i_clk_dac0_dco;
assign o_dac0_fifo_dur____rd_ck = i_clk_dac0_dco;
assign o_dac1_fifo_datinc_rd_ck = i_clk_dac1_dco;
assign o_dac1_fifo_dur____rd_ck = i_clk_dac1_dco;

// fifo rd_en
assign o_dac0_fifo_datinc_rd_en = w_fcid_data_load_dac0; // to fifo
assign o_dac0_fifo_dur____rd_en = w_fcid_data_load_dac0; // to fifo
assign o_dac1_fifo_datinc_rd_en = w_fcid_data_load_dac1; // to fifo
assign o_dac1_fifo_dur____rd_en = w_fcid_data_load_dac1; // to fifo

// fifo dout
assign w_fcid_cnt_dur_dac0 = i_dac0_fifo_dur____dout       ; // [31:0] // = from fifo
assign w_fcid_dat_inc_dac0 = i_dac0_fifo_datinc_dout[15: 0]; // [15:0] // = from fifo
assign w_fcid_dat_out_dac0 = i_dac0_fifo_datinc_dout[31:16]; // [15:0] // = from fifo
assign w_fcid_cnt_dur_dac1 = i_dac1_fifo_dur____dout       ; // [31:0] // = from fifo
assign w_fcid_dat_inc_dac1 = i_dac1_fifo_datinc_dout[15: 0]; // [15:0] // = from fifo
assign w_fcid_dat_out_dac1 = i_dac1_fifo_datinc_dout[31:16]; // [15:0] // = from fifo


//}


//}

//}


//---------------------------------------------------------------//

//// DCS (duration controlled sequence)  //{
// fixed length of 8; (DAC code 16b + duration count 16b)
// setting: number of sequence repeat

//// reg and wire //{
reg r_dcs_run; // @clk
//
reg  [2:0] r_dcs_dacx_adrs;  
//
reg [31:0] r_dcs_dac0_data_seq_0;
reg [31:0] r_dcs_dac0_data_seq_1;
reg [31:0] r_dcs_dac0_data_seq_2;
reg [31:0] r_dcs_dac0_data_seq_3;
reg [31:0] r_dcs_dac0_data_seq_4;
reg [31:0] r_dcs_dac0_data_seq_5;
reg [31:0] r_dcs_dac0_data_seq_6;
reg [31:0] r_dcs_dac0_data_seq_7;
//
reg [31:0] r_dcs_dac1_data_seq_0;
reg [31:0] r_dcs_dac1_data_seq_1;
reg [31:0] r_dcs_dac1_data_seq_2;
reg [31:0] r_dcs_dac1_data_seq_3;
reg [31:0] r_dcs_dac1_data_seq_4;
reg [31:0] r_dcs_dac1_data_seq_5;
reg [31:0] r_dcs_dac1_data_seq_6;
reg [31:0] r_dcs_dac1_data_seq_7;
//
wire w_dcs_write_adrs       = i_trig_dacz_ctrl[16];
wire w_dcs_read_adrs        = i_trig_dacz_ctrl[17];
wire w_dcs_write_data_dac0  = i_trig_dacz_ctrl[18];
wire w_dcs_read_data_dac0   = i_trig_dacz_ctrl[19];
wire w_dcs_write_data_dac1  = i_trig_dacz_ctrl[20];
wire w_dcs_read_data_dac1   = i_trig_dacz_ctrl[21];
wire w_dcs_run_test         = i_trig_dacz_ctrl[22]; //$$
wire w_dcs_stop_test        = i_trig_dacz_ctrl[23];
wire w_dcs_write_repeat     = i_trig_dacz_ctrl[24]; // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
wire w_dcs_read_repeat      = i_trig_dacz_ctrl[25]; // 
//
(* keep = "true" *) reg flag_dcs_rdy_dac0;
(* keep = "true" *) reg flag_dcs_rdy_dac1;
reg flag_dcs_run_dac0; // @i_clk_dac0_dco
reg flag_dcs_run_dac1; // @i_clk_dac1_dco
reg flag_dcs_active_dac0; // @i_clk_dac0_dco
reg flag_dcs_active_dac1; // @i_clk_dac1_dco
//
reg [15:0] r_dcs_data_dac0;
reg [15:0] r_dcs_data_dac1;
//
reg [15:0] r_dcs_repeat_dac0;
reg [15:0] r_dcs_repeat_dac1;
//

localparam  BW_DURATION = 16;  
//
reg [(BW_DURATION-1):0] r_dcs_cnt_duration_dac0; // dount down
reg [(BW_DURATION-1):0] r_dcs_cnt_duration_dac1; 
//
reg [2:0] r_dcs_cnt_adrs_dac0; // count up
reg [2:0] r_dcs_cnt_adrs_dac1; 
//

(* keep = "true" *) reg [15:0] r_dcs_cnt_repeat_dac0; // count up
(* keep = "true" *) reg [15:0] r_dcs_cnt_repeat_dac1; 
//}

//// always and assign //{
always @(posedge clk, negedge reset_n) //{ r_dcs_dacx_adrs
	if (!reset_n) begin
		r_dcs_dacx_adrs   <= 3'b0;  
	end
	else begin 
		if (w_dcs_write_adrs) 
			r_dcs_dacx_adrs   <= i_wire_dacz_data[2:0];  
	end
//}
always @(posedge clk, negedge reset_n) //{ r_dcs_dac*_data_seq_*
	if (!reset_n) begin
		r_dcs_dac0_data_seq_0   <= 32'b0;
		r_dcs_dac0_data_seq_1   <= 32'b0;
		r_dcs_dac0_data_seq_2   <= 32'b0;
		r_dcs_dac0_data_seq_3   <= 32'b0;
		r_dcs_dac0_data_seq_4   <= 32'b0;
		r_dcs_dac0_data_seq_5   <= 32'b0;
		r_dcs_dac0_data_seq_6   <= 32'b0;
		r_dcs_dac0_data_seq_7   <= 32'b0;
		//
		r_dcs_dac1_data_seq_0   <= 32'b0;
		r_dcs_dac1_data_seq_1   <= 32'b0;
		r_dcs_dac1_data_seq_2   <= 32'b0;
		r_dcs_dac1_data_seq_3   <= 32'b0;
		r_dcs_dac1_data_seq_4   <= 32'b0;
		r_dcs_dac1_data_seq_5   <= 32'b0;
		r_dcs_dac1_data_seq_6   <= 32'b0;
		r_dcs_dac1_data_seq_7   <= 32'b0;
	end
	else begin 
		if (w_dcs_write_data_dac0) begin
			r_dcs_dac0_data_seq_0   <= (r_dcs_dacx_adrs==3'b000)? i_wire_dacz_data : r_dcs_dac0_data_seq_0;
			r_dcs_dac0_data_seq_1   <= (r_dcs_dacx_adrs==3'b001)? i_wire_dacz_data : r_dcs_dac0_data_seq_1;
			r_dcs_dac0_data_seq_2   <= (r_dcs_dacx_adrs==3'b010)? i_wire_dacz_data : r_dcs_dac0_data_seq_2;
			r_dcs_dac0_data_seq_3   <= (r_dcs_dacx_adrs==3'b011)? i_wire_dacz_data : r_dcs_dac0_data_seq_3;
			r_dcs_dac0_data_seq_4   <= (r_dcs_dacx_adrs==3'b100)? i_wire_dacz_data : r_dcs_dac0_data_seq_4;
			r_dcs_dac0_data_seq_5   <= (r_dcs_dacx_adrs==3'b101)? i_wire_dacz_data : r_dcs_dac0_data_seq_5;
			r_dcs_dac0_data_seq_6   <= (r_dcs_dacx_adrs==3'b110)? i_wire_dacz_data : r_dcs_dac0_data_seq_6;
			r_dcs_dac0_data_seq_7   <= (r_dcs_dacx_adrs==3'b111)? i_wire_dacz_data : r_dcs_dac0_data_seq_7;
		end
		else if (w_dcs_write_data_dac1) begin
			r_dcs_dac1_data_seq_0   <= (r_dcs_dacx_adrs==3'b000)? i_wire_dacz_data : r_dcs_dac1_data_seq_0;
			r_dcs_dac1_data_seq_1   <= (r_dcs_dacx_adrs==3'b001)? i_wire_dacz_data : r_dcs_dac1_data_seq_1;
			r_dcs_dac1_data_seq_2   <= (r_dcs_dacx_adrs==3'b010)? i_wire_dacz_data : r_dcs_dac1_data_seq_2;
			r_dcs_dac1_data_seq_3   <= (r_dcs_dacx_adrs==3'b011)? i_wire_dacz_data : r_dcs_dac1_data_seq_3;
			r_dcs_dac1_data_seq_4   <= (r_dcs_dacx_adrs==3'b100)? i_wire_dacz_data : r_dcs_dac1_data_seq_4;
			r_dcs_dac1_data_seq_5   <= (r_dcs_dacx_adrs==3'b101)? i_wire_dacz_data : r_dcs_dac1_data_seq_5;
			r_dcs_dac1_data_seq_6   <= (r_dcs_dacx_adrs==3'b110)? i_wire_dacz_data : r_dcs_dac1_data_seq_6;
			r_dcs_dac1_data_seq_7   <= (r_dcs_dacx_adrs==3'b111)? i_wire_dacz_data : r_dcs_dac1_data_seq_7;
		end
	end
//}
//
always @(posedge clk, negedge reset_n) //{ r_dcs_run
	if (!reset_n) begin
		r_dcs_run         <= 1'b0;
	end
	else begin 
		// set flag
		if (w_dcs_run_test) 
			r_dcs_run   <= 1'b1;
		else if (w_dcs_stop_test)
			r_dcs_run   <= 1'b0;
	end
//}
//
always @(posedge clk, negedge reset_n) //{ r_dcs_repeat_dac*
	if (!reset_n) begin
		r_dcs_repeat_dac0   <= 16'b0;
		r_dcs_repeat_dac1   <= 16'b0;
	end
	else begin 
		if (w_dcs_write_repeat) begin
			r_dcs_repeat_dac0   <= i_wire_dacz_data[15: 0];
			r_dcs_repeat_dac1   <= i_wire_dacz_data[31:16];
		end
	end
//}

always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin // r_dcs_data_dac0
	if (!i_rstn_dac0_dco) begin 
		flag_dcs_rdy_dac0       <=  1'b0;
		flag_dcs_run_dac0       <=  1'b0;
		flag_dcs_active_dac0    <=  1'b0;
		r_dcs_data_dac0         <= 16'b0;
		r_dcs_cnt_adrs_dac0     <=  3'b0;  
		r_dcs_cnt_duration_dac0 <= {(BW_DURATION){1'b0}};  
		r_dcs_cnt_repeat_dac0   <= 16'b0;
	end 
	else begin 
		flag_dcs_rdy_dac0   <=  1'b1;
		flag_dcs_run_dac0   <=  r_dcs_run;
		//
		if (flag_dcs_run_dac0) begin  
			if (r_dcs_cnt_duration_dac0 == 0) begin // count down completed
				r_dcs_cnt_adrs_dac0 <= r_dcs_cnt_adrs_dac0 + 1; // count up
				//
				r_dcs_cnt_duration_dac0 <=  (r_dcs_cnt_adrs_dac0==3'b000)? r_dcs_dac0_data_seq_0[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b001)? r_dcs_dac0_data_seq_1[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b010)? r_dcs_dac0_data_seq_2[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b011)? r_dcs_dac0_data_seq_3[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b100)? r_dcs_dac0_data_seq_4[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b101)? r_dcs_dac0_data_seq_5[15:0] :
											(r_dcs_cnt_adrs_dac0==3'b110)? r_dcs_dac0_data_seq_6[15:0] :
																		   r_dcs_dac0_data_seq_7[15:0] ;
				//
				if (r_dcs_repeat_dac0==0 
				|| (r_dcs_cnt_repeat_dac0 < r_dcs_repeat_dac0) 
				|| (r_dcs_cnt_repeat_dac0 == r_dcs_repeat_dac0 && r_dcs_cnt_adrs_dac0!=3'b000) )  begin 
					// normal output
					r_dcs_data_dac0 <=  (r_dcs_cnt_adrs_dac0==3'b000)? r_dcs_dac0_data_seq_0[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b001)? r_dcs_dac0_data_seq_1[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b010)? r_dcs_dac0_data_seq_2[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b011)? r_dcs_dac0_data_seq_3[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b100)? r_dcs_dac0_data_seq_4[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b101)? r_dcs_dac0_data_seq_5[31:16] :
										(r_dcs_cnt_adrs_dac0==3'b110)? r_dcs_dac0_data_seq_6[31:16] :
																	   r_dcs_dac0_data_seq_7[31:16] ;
					flag_dcs_active_dac0    <=  1'b1;
				end 
				else begin
					// output disabled
					r_dcs_data_dac0         <= 16'b0;
					flag_dcs_active_dac0    <=  1'b0;
				end
				//
				if (r_dcs_cnt_adrs_dac0 == 0) begin // every pulse 
					if (r_dcs_cnt_repeat_dac0 < 16'hFFFF)
						r_dcs_cnt_repeat_dac0   <= r_dcs_cnt_repeat_dac0  + 1; // count up
				end
			end
			else begin
				r_dcs_cnt_duration_dac0 <= r_dcs_cnt_duration_dac0 - 1; // count down
			end
		end
		else begin
			flag_dcs_active_dac0    <=  1'b0;
			r_dcs_data_dac0         <= 16'b0;
			r_dcs_cnt_adrs_dac0     <=  3'b0;  
			r_dcs_cnt_duration_dac0 <= {(BW_DURATION){1'b0}};  
			r_dcs_cnt_repeat_dac0   <= 16'b0;
		end 
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin // r_dcs_data_dac1
	if (!i_rstn_dac1_dco) begin 
		flag_dcs_rdy_dac1       <=  1'b0;
		flag_dcs_run_dac1       <=  1'b0;
		flag_dcs_active_dac1    <=  1'b0;
		r_dcs_data_dac1         <= 16'b0;
		r_dcs_cnt_adrs_dac1     <=  3'b0;  
		r_dcs_cnt_duration_dac1 <= {(BW_DURATION){1'b0}};  
		r_dcs_cnt_repeat_dac1   <= 16'b0;
	end 
	else begin 
		flag_dcs_rdy_dac1   <=  1'b1;
		flag_dcs_run_dac1   <=  r_dcs_run;
		//
		if (flag_dcs_run_dac1) begin  
			if (r_dcs_cnt_duration_dac1 == 0) begin
				r_dcs_cnt_adrs_dac1 <= r_dcs_cnt_adrs_dac1 + 1;
				//
				r_dcs_cnt_duration_dac1 <=  (r_dcs_cnt_adrs_dac1==3'b000)? r_dcs_dac1_data_seq_0[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b001)? r_dcs_dac1_data_seq_1[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b010)? r_dcs_dac1_data_seq_2[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b011)? r_dcs_dac1_data_seq_3[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b100)? r_dcs_dac1_data_seq_4[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b101)? r_dcs_dac1_data_seq_5[15:0] :
											(r_dcs_cnt_adrs_dac1==3'b110)? r_dcs_dac1_data_seq_6[15:0] :
																		   r_dcs_dac1_data_seq_7[15:0] ;
				//
				if (r_dcs_repeat_dac1==0 
				|| (r_dcs_cnt_repeat_dac1 < r_dcs_repeat_dac1) 
				|| (r_dcs_cnt_repeat_dac1 == r_dcs_repeat_dac1 && r_dcs_cnt_adrs_dac1!=3'b000) )  begin 
					// output normal
					r_dcs_data_dac1 <=  (r_dcs_cnt_adrs_dac1==3'b000)? r_dcs_dac1_data_seq_0[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b001)? r_dcs_dac1_data_seq_1[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b010)? r_dcs_dac1_data_seq_2[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b011)? r_dcs_dac1_data_seq_3[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b100)? r_dcs_dac1_data_seq_4[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b101)? r_dcs_dac1_data_seq_5[31:16] :
										(r_dcs_cnt_adrs_dac1==3'b110)? r_dcs_dac1_data_seq_6[31:16] :
																	   r_dcs_dac1_data_seq_7[31:16] ;
					flag_dcs_active_dac1    <=  1'b1;
				end 
				else begin
					// output disabled
					r_dcs_data_dac1         <= 16'b0;
					flag_dcs_active_dac1    <=  1'b0;
				end
				//
				if (r_dcs_cnt_adrs_dac1 == 0) begin // every pulse 
					if (r_dcs_cnt_repeat_dac1 < 16'hFFFF)
						r_dcs_cnt_repeat_dac1   <= r_dcs_cnt_repeat_dac1  + 1; // count up
				end
			end
			else begin
				r_dcs_cnt_duration_dac1 <= r_dcs_cnt_duration_dac1 - 1;
			end
		end
		else begin 
			flag_dcs_active_dac1    <=  1'b0;
			r_dcs_data_dac1         <= 16'b0;
			r_dcs_cnt_adrs_dac1     <=  3'b0;  
			r_dcs_cnt_duration_dac1 <= {(BW_DURATION){1'b0}};  
			r_dcs_cnt_repeat_dac1   <= 16'b0;
		end 
	end
end
//}

//}

//---------------------------------------------------------------//

//// FDCS (fifo-based duration controlled sequence)  //{
// fixed fifo depth of 2^12
// each data has (DAC code 16b + duration count 16b)
// setting: number of sequence repeat
//
// note:
// - Must bypass the previous value of fifo at fifo start point. 
//   ... check the first valid after shooting fifo_rd_en

//// reg and wire: //{
//
reg r_fdcs_run;
//
wire w_fdcs_run_test         = i_trig_dacz_ctrl[28]; //$$
wire w_fdcs_stop_test        = i_trig_dacz_ctrl[29];
wire w_fdcs_write_repeat     = i_trig_dacz_ctrl[30];
wire w_fdcs_read_repeat      = i_trig_dacz_ctrl[31];
//
reg flag_fdcs_rdy_dac0;
reg flag_fdcs_rdy_dac1;
reg flag_fdcs_run_dac0;
reg flag_fdcs_run_dac1;
reg flag_fdcs_active_dac0; // @i_clk_dac0_dco
reg flag_fdcs_active_dac1; // @i_clk_dac1_dco
//
reg [15:0] r_fdcs_data_dac0;
reg [15:0] r_fdcs_data_dac1;
//
reg [15:0] r_fdcs_repeat_dac0;
reg [15:0] r_fdcs_repeat_dac1;
//
reg [(BW_DURATION-1):0] r_fdcs_cnt_duration_dac0; 
reg [(BW_DURATION-1):0] r_fdcs_cnt_duration_dac1; 
//
reg [15:0] r_fdcs_cnt_repeat_dac0; // count up
reg [15:0] r_fdcs_cnt_repeat_dac1; 
//
(* keep = "true" *) reg r_dac0_fifo_rd_en;
(* keep = "true" *) reg r_dac1_fifo_rd_en;
//
(* keep = "true" *) reg r_dac0_fifo_empty;
(* keep = "true" *) reg r_dac0_fifo_reload1_empty;
(* keep = "true" *) reg r_dac0_fifo_reload2_empty;
//
(* keep = "true" *) reg r_dac1_fifo_empty;
(* keep = "true" *) reg r_dac1_fifo_reload1_empty;
(* keep = "true" *) reg r_dac1_fifo_reload2_empty;
//
wire w_fdcs_dac0_stop_cond;
wire w_fdcs_dac1_stop_cond;
//

wire [31:0] w_dac0_fifo_dout;
wire        w_dac0_fifo_rd_en;
wire        w_dac0_fifo_valid;
wire [15:0] w_fdcs_data_dac0         =  w_dac0_fifo_dout[31:16];
wire [15:0] w_fdcs_cnt_duration_dac0 =  w_dac0_fifo_dout[15:0] ;
wire        w_flag_trans_st_dac0_fifo_sel; // fifo change moment

wire [31:0] w_dac1_fifo_dout;
wire        w_dac1_fifo_rd_en;
wire        w_dac1_fifo_valid;
wire [15:0] w_fdcs_data_dac1         =  w_dac1_fifo_dout[31:16];
wire [15:0] w_fdcs_cnt_duration_dac1 =  w_dac1_fifo_dout[15:0] ;
wire        w_flag_trans_st_dac1_fifo_sel; // fifo change moment 


//
//}

//// always and assign: //{
//
always @(posedge clk, negedge reset_n) //{ r_fdcs_run
	if (!reset_n) begin
		r_fdcs_run   <= 1'b0;
	end
	else begin 
		// set flag
		if (w_fdcs_run_test) 
			r_fdcs_run   <= 1'b1;
		else if (w_fdcs_stop_test)
			r_fdcs_run   <= 1'b0;
	end
//}

always @(posedge clk, negedge reset_n) //{ r_fdcs_repeat_dac*
	if (!reset_n) begin
		r_fdcs_repeat_dac0   <= 16'b0;
		r_fdcs_repeat_dac1   <= 16'b0;
	end
	else begin 
		if (w_fdcs_write_repeat) begin
			r_fdcs_repeat_dac0   <= i_wire_dacz_data[15: 0];
			r_fdcs_repeat_dac1   <= i_wire_dacz_data[31:16];
		end
	end
//}

//
assign w_fdcs_dac0_stop_cond = (r_fdcs_repeat_dac0 == 0                    )? ~w_dac0_fifo_valid :
							   (r_fdcs_cnt_repeat_dac0 > r_fdcs_repeat_dac0)? 1'b1               :
							   (w_flag_trans_st_dac0_fifo_sel && (r_fdcs_cnt_repeat_dac0+1 > r_fdcs_repeat_dac0))? 
							                                                  1'b1               :
							                                                  1'b0               ;
assign w_fdcs_dac1_stop_cond = (r_fdcs_repeat_dac1 == 0                    )? ~w_dac1_fifo_valid :
							   (r_fdcs_cnt_repeat_dac1 > r_fdcs_repeat_dac1)? 1'b1               :
							   (w_flag_trans_st_dac1_fifo_sel && (r_fdcs_cnt_repeat_dac1+1 > r_fdcs_repeat_dac1))? 
							                                                  1'b1               :
							                                                  1'b0               ; 

// pulse hold signals
wire w_hold_pulse_dac0;
wire w_hold_pulse_dac1;

// retiming for o_dac0_active_dco with fdcs
//   use    flag_fdcs_active_dac0
//   define r_fdcs_active_dac0
(* keep = "true" *) reg  r_fdcs_active_dac0;
(* keep = "true" *) reg [31:0] r_fdcs_subpulse_idx_dac0;
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin // r_fdcs_active_dac0, r_fdcs_data_dac0
	if (!i_rstn_dac0_dco) begin 
		r_fdcs_active_dac0       <=  1'b0; 
		r_fdcs_data_dac0         <= 16'b0;
	end
	else begin
		//
		if (w_hold_pulse_dac0) begin
			// stay
			r_fdcs_active_dac0       <=  r_fdcs_active_dac0;
			r_fdcs_data_dac0         <=  r_fdcs_data_dac0  ;
		end
		else if (!r_fdcs_active_dac0 && (flag_fdcs_run_dac0 && !w_fdcs_dac0_stop_cond) ) begin 
			// start of pulse
			r_fdcs_active_dac0       <=  1'b1;
			r_fdcs_data_dac0         <=  w_fdcs_data_dac0;
		end
		else if ( r_fdcs_active_dac0                             && 
		         (r_fdcs_repeat_dac0 > 0)                        && 
				  w_flag_trans_st_dac0_fifo_sel                  && 
				 (r_fdcs_cnt_repeat_dac0+1 > r_fdcs_repeat_dac0) )  begin
			// end of pulse
			r_fdcs_active_dac0  <=  1'b0;
			r_fdcs_data_dac0    <= 16'b0;
		end
		else if (r_fdcs_active_dac0 && flag_fdcs_active_dac0) begin 
			// during pulse
			r_fdcs_active_dac0  <=  r_fdcs_active_dac0;
			r_fdcs_data_dac0    <=  w_fdcs_data_dac0;
		end
		else if (!flag_fdcs_active_dac0) begin
			// no activity
			r_fdcs_active_dac0  <=  1'b0;
			r_fdcs_data_dac0    <= 16'b0;
		end
		//
	end
end
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin // r_fdcs_subpulse_idx_dac0
	if (!i_rstn_dac0_dco) begin 
		r_fdcs_subpulse_idx_dac0 <= 32'd0;
	end
	else begin
		if (flag_fdcs_run_dac0) begin 
			if (r_fdcs_active_dac0 & ~w_hold_pulse_dac0) 
				r_fdcs_subpulse_idx_dac0 <= r_fdcs_subpulse_idx_dac0 + 32'd1;
			else 
				r_fdcs_subpulse_idx_dac0 <= r_fdcs_subpulse_idx_dac0; // stay
		end 
		else begin 
			r_fdcs_subpulse_idx_dac0 <= 32'd0;
		end
	end
end

	

(* keep = "true" *) reg  r_fdcs_active_dac1;
(* keep = "true" *) reg [31:0] r_fdcs_subpulse_idx_dac1;
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin // r_fdcs_active_dac1, r_fdcs_data_dac1
	if (!i_rstn_dac1_dco) begin 
		r_fdcs_active_dac1      <=  1'b0; 
		r_fdcs_data_dac1        <= 16'b0;
	end
	else begin
		//
		if (w_hold_pulse_dac1) begin
			// stay
			r_fdcs_active_dac1       <=  r_fdcs_active_dac1;
			r_fdcs_data_dac1         <=  r_fdcs_data_dac1  ;
		end
		else if (!r_fdcs_active_dac1 && (flag_fdcs_run_dac1 && !w_fdcs_dac1_stop_cond) ) begin 
			// start of pulse
			r_fdcs_active_dac1  <=  1'b1;
			r_fdcs_data_dac1    <=  w_fdcs_data_dac1;
		end
		else if ( r_fdcs_active_dac1                             && 
		         (r_fdcs_repeat_dac1 > 0)                        && 
				  w_flag_trans_st_dac1_fifo_sel                  && 
				 (r_fdcs_cnt_repeat_dac1+1 > r_fdcs_repeat_dac1) )  begin
			// end of pulse
			r_fdcs_active_dac1  <=  1'b0;
			r_fdcs_data_dac1    <= 16'b0;
		end
		else if (r_fdcs_active_dac1 && flag_fdcs_active_dac1) begin 
			// during pulse
			r_fdcs_active_dac1  <=  r_fdcs_active_dac1;
			r_fdcs_data_dac1    <=  w_fdcs_data_dac1;
		end
		else if (!flag_fdcs_active_dac1) begin
			// no activity
			r_fdcs_active_dac1  <=  1'b0;
			r_fdcs_data_dac1    <= 16'b0;
		end
		//
	end
end 
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin // r_fdcs_subpulse_idx_dac1
	if (!i_rstn_dac1_dco) begin 
		r_fdcs_subpulse_idx_dac1 <= 32'd0;
	end
	else begin
		if (flag_fdcs_run_dac1) begin 
			if (r_fdcs_active_dac1 & ~w_hold_pulse_dac1)
				r_fdcs_subpulse_idx_dac1 <= r_fdcs_subpulse_idx_dac1 + 32'd1;
			else
				r_fdcs_subpulse_idx_dac1 <= r_fdcs_subpulse_idx_dac1; // stay
		end 
		else begin 
			r_fdcs_subpulse_idx_dac1 <= 32'd0;
		end
	end
end


//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin // r_dac0_fifo_rd_en
	if (!i_rstn_dac0_dco) begin 
		flag_fdcs_rdy_dac0               <=  1'b0;
		flag_fdcs_run_dac0               <=  1'b0;
		flag_fdcs_active_dac0            <=  1'b0;
		//                               
		r_fdcs_cnt_duration_dac0         <= {(BW_DURATION){1'b0}};  
		//                               
		r_dac0_fifo_rd_en                <=  1'b0;
		r_dac0_fifo_empty                <=  1'b0;
		r_dac0_fifo_reload1_empty        <=  1'b0;
		r_dac0_fifo_reload2_empty        <=  1'b0;
	end 
	else begin 
		flag_fdcs_rdy_dac0               <=  1'b1;
		flag_fdcs_run_dac0               <=  r_fdcs_run;
		r_dac0_fifo_empty                <=  i_dac0_fifo_empty;
		r_dac0_fifo_reload1_empty        <=  i_dac0_fifo_reload1_empty;
		r_dac0_fifo_reload2_empty        <=  i_dac0_fifo_reload2_empty;
		//
		if (flag_fdcs_run_dac0 && !w_fdcs_dac0_stop_cond) begin  
			// fdcs run condition
			flag_fdcs_active_dac0        <=  1'b1;
		end
		else begin
			flag_fdcs_active_dac0        <=  1'b0;
		end
		
		//
		if (w_hold_pulse_dac0) begin
			// stay
			r_fdcs_cnt_duration_dac0     <=  r_fdcs_cnt_duration_dac0;
		end 
		else if (r_fdcs_run && (w_fdcs_cnt_duration_dac0==0)) begin
			r_fdcs_cnt_duration_dac0     <=  16'hFFFF;
		end
		else if (r_fdcs_run && (w_fdcs_cnt_duration_dac0>0) && (r_fdcs_cnt_duration_dac0==16'hFFFF)) begin
			// load fifo data
			r_fdcs_cnt_duration_dac0     <=  w_fdcs_cnt_duration_dac0 - 1;
		end
		else if (r_fdcs_run)
			r_fdcs_cnt_duration_dac0     <=  r_fdcs_cnt_duration_dac0 - 1;
		else begin
			r_fdcs_cnt_duration_dac0     <=  16'b0;
		end
		
	end
end

//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin // r_dac1_fifo_rd_en
	if (!i_rstn_dac1_dco) begin 
		flag_fdcs_rdy_dac1               <=  1'b0;
		flag_fdcs_run_dac1               <=  1'b0;
		flag_fdcs_active_dac1            <=  1'b0;
		//
		r_fdcs_cnt_duration_dac1         <= {(BW_DURATION){1'b0}};  
		//
		r_dac1_fifo_rd_en                <=  1'b0;
		r_dac1_fifo_empty                <=  1'b0;
		r_dac1_fifo_reload1_empty        <=  1'b0;
		r_dac1_fifo_reload2_empty        <=  1'b0;
	end 
	else begin 
		flag_fdcs_rdy_dac1               <=  1'b1;
		flag_fdcs_run_dac1               <=  r_fdcs_run;
		r_dac1_fifo_empty                <=  i_dac1_fifo_empty;
		r_dac1_fifo_reload1_empty        <=  i_dac1_fifo_reload1_empty;
		r_dac1_fifo_reload2_empty        <=  i_dac1_fifo_reload2_empty;
		
		if (flag_fdcs_run_dac1 && !w_fdcs_dac1_stop_cond) begin  
			// fdcs run condition
			flag_fdcs_active_dac1        <=  1'b1;
		end
		else begin
			flag_fdcs_active_dac1        <=  1'b0;
		end
		
		if (w_hold_pulse_dac1) begin
			// stay
			r_fdcs_cnt_duration_dac1     <=  r_fdcs_cnt_duration_dac1;
		end 
		else if (r_fdcs_run && (w_fdcs_cnt_duration_dac1==0)) begin
			r_fdcs_cnt_duration_dac1     <=  16'hFFFF;
		end
		else if (r_fdcs_run && (w_fdcs_cnt_duration_dac1>0) && (r_fdcs_cnt_duration_dac1==16'hFFFF)) begin
			// load fifo data
			r_fdcs_cnt_duration_dac1     <=  w_fdcs_cnt_duration_dac1 - 1;
		end
		else if (r_fdcs_run)
			r_fdcs_cnt_duration_dac1     <=  r_fdcs_cnt_duration_dac1 - 1;
		else begin
			r_fdcs_cnt_duration_dac1     <=  16'b0;
		end
	
	end
end
//

//}


//}

//---------------------------------------------------------------//

//// fifo assign and control for FDCS //{

// fifo resets //{

// note: add reg signal for fifo reset ... easy to apply false path constraint.

wire last_pulse_run_dac0;
wire last_pulse_run_dac1;
//
wire w_dac0_fifo_rst        ;
wire w_dac0_fifo_reload1_rst;
wire w_dac0_fifo_reload2_rst;
wire w_dac1_fifo_rst        ;
wire w_dac1_fifo_reload1_rst;
wire w_dac1_fifo_reload2_rst;
//
(* keep = "true" *) reg  r_dac0_fifo_rst        ;
(* keep = "true" *) reg  r_dac0_fifo_reload1_rst;
(* keep = "true" *) reg  r_dac0_fifo_reload2_rst;
(* keep = "true" *) reg  r_dac1_fifo_rst        ;
(* keep = "true" *) reg  r_dac1_fifo_reload1_rst;
(* keep = "true" *) reg  r_dac1_fifo_reload2_rst;

//
assign w_dac0_fifo_rst         = ~flag_fdcs_rdy_dac0;
assign w_dac0_fifo_reload1_rst = ~flag_fdcs_rdy_dac0 | last_pulse_run_dac0; // need last pulse for clearing reloading fifo.
assign w_dac0_fifo_reload2_rst = ~flag_fdcs_rdy_dac0 | last_pulse_run_dac0; // 
assign w_dac1_fifo_rst         = ~flag_fdcs_rdy_dac1;
assign w_dac1_fifo_reload1_rst = ~flag_fdcs_rdy_dac1 | last_pulse_run_dac1; // 
assign w_dac1_fifo_reload2_rst = ~flag_fdcs_rdy_dac1 | last_pulse_run_dac1; // 

//
assign o_dac0_fifo_rst         = w_dac0_fifo_rst        ;
assign o_dac0_fifo_reload1_rst = w_dac0_fifo_reload1_rst;
assign o_dac0_fifo_reload2_rst = w_dac0_fifo_reload2_rst;
assign o_dac1_fifo_rst         = w_dac1_fifo_rst        ;
assign o_dac1_fifo_reload1_rst = w_dac1_fifo_reload1_rst;
assign o_dac1_fifo_reload2_rst = w_dac1_fifo_reload2_rst;

//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_dac0_fifo_rst          <=  1'b1;
		r_dac0_fifo_reload1_rst  <=  1'b1;
		r_dac0_fifo_reload2_rst  <=  1'b1;
	end
	else begin
		r_dac0_fifo_rst          <=  w_dac0_fifo_rst        ;
		r_dac0_fifo_reload1_rst  <=  w_dac0_fifo_reload1_rst;
		r_dac0_fifo_reload2_rst  <=  w_dac0_fifo_reload2_rst;
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_dac1_fifo_rst          <=  1'b1;
		r_dac1_fifo_reload1_rst  <=  1'b1;
		r_dac1_fifo_reload2_rst  <=  1'b1;
	end
	else begin
		r_dac1_fifo_rst          <=  w_dac1_fifo_rst        ;
		r_dac1_fifo_reload1_rst  <=  w_dac1_fifo_reload1_rst;
		r_dac1_fifo_reload2_rst  <=  w_dac1_fifo_reload2_rst;
	end
end


//}

// dac0 fifo control //{

// internal signals //{

reg  [1:0] r_st_dac0_fifo_sel;  
//
//   i_dac0_fifo_empty
//   i_dac0_fifo_reload1_empty
//   i_dac0_fifo_reload2_empty
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_st_dac0_fifo_sel      <=  2'b00;
	end
	else if (flag_fdcs_run_dac0) begin
		//
		if (w_hold_pulse_dac0) begin
			// stay
			r_st_dac0_fifo_sel      <= r_st_dac0_fifo_sel;
		end
		else if      (i_dac0_fifo_empty == 0) begin
			r_st_dac0_fifo_sel      <=  2'b00;
		end
		else if (r_st_dac0_fifo_sel == 2'b00 && i_dac0_fifo_empty == 1) begin
			r_st_dac0_fifo_sel      <=  2'b01;
		end 
		else if (r_st_dac0_fifo_sel == 2'b01 && i_dac0_fifo_reload1_empty == 1) begin
			r_st_dac0_fifo_sel      <=  2'b10;
		end
		else if (r_st_dac0_fifo_sel == 2'b10 && i_dac0_fifo_reload2_empty == 1) begin
			r_st_dac0_fifo_sel      <=  2'b01;
		end
	end
	else begin
		r_st_dac0_fifo_sel  <=  2'b00;
	end
end
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_fdcs_cnt_repeat_dac0  <= 16'd0 ;
	end
	else if (flag_fdcs_run_dac0) begin
		//
		if      (i_dac0_fifo_empty == 0) begin //$$
			r_fdcs_cnt_repeat_dac0  <= 16'd1 ;
		end
		else if (r_st_dac0_fifo_sel == 2'b00 && i_dac0_fifo_empty == 1) begin //$$
			r_fdcs_cnt_repeat_dac0  <= r_fdcs_cnt_repeat_dac0 + 1;
		end 
		else if (r_st_dac0_fifo_sel == 2'b01 && i_dac0_fifo_reload1_empty == 1) begin //$$
			r_fdcs_cnt_repeat_dac0  <= r_fdcs_cnt_repeat_dac0 + 1;
		end
		else if (r_st_dac0_fifo_sel == 2'b10 && i_dac0_fifo_reload2_empty == 1) begin //$$
			r_fdcs_cnt_repeat_dac0  <= r_fdcs_cnt_repeat_dac0 + 1;
		end
	end
	else begin
		r_fdcs_cnt_repeat_dac0  <= 16'd0 ;
	end
end
//
assign  w_flag_trans_st_dac0_fifo_sel = 
		(r_st_dac0_fifo_sel == 2'b00 && i_dac0_fifo_empty == 1)         |
		(r_st_dac0_fifo_sel == 2'b01 && i_dac0_fifo_reload1_empty == 1) |
		(r_st_dac0_fifo_sel == 2'b10 && i_dac0_fifo_reload2_empty == 1) ;

reg  r_smp_flag_fdcs_run_dac0;
wire w_fall_flag_fdcs_run_dac0;
reg  r_smp_fall_flag_fdcs_run_dac0;
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_smp_flag_fdcs_run_dac0      <=  1'b0;
		r_smp_fall_flag_fdcs_run_dac0 <=  1'b0;
	end
	else begin
		r_smp_flag_fdcs_run_dac0      <=  flag_fdcs_run_dac0      ;
		r_smp_fall_flag_fdcs_run_dac0 <=  w_fall_flag_fdcs_run_dac0;
	end
end
//
assign w_fall_flag_fdcs_run_dac0 = ~flag_fdcs_run_dac0 & r_smp_flag_fdcs_run_dac0; // falling
assign last_pulse_run_dac0 = w_fall_flag_fdcs_run_dac0 | r_smp_fall_flag_fdcs_run_dac0; // falling + one delay

//} 

// one step earlier before r_st_dac0_fifo_sel //{
wire [1:0] w_st_dac0_fifo_sel; 
//   ...
//   2'b00 :  dac0_fifo_sel
//   2'b01 :  dac0_fifo_reload1_sel
//   2'b10 :  dac0_fifo_reload2_sel
//   2'b11 :  NA
//
//   i_dac0_fifo_empty
//   i_dac0_fifo_reload1_empty
//   i_dac0_fifo_reload2_empty
//
assign w_st_dac0_fifo_sel = (r_st_dac0_fifo_sel == 2'b00)? (i_dac0_fifo_empty         == 1)? 2'b01 : 2'b00 : 
							(r_st_dac0_fifo_sel == 2'b01)? (i_dac0_fifo_reload1_empty == 1)? 2'b10 : 2'b01 : 
							(r_st_dac0_fifo_sel == 2'b10)? (i_dac0_fifo_reload2_empty == 1)? 2'b01 : 2'b10 : 
							                               2'b00 ;

//}

// dac0 data selection : //{
assign w_dac0_fifo_dout = (w_st_dac0_fifo_sel == 2'b00)? i_dac0_fifo_dout         : 
						  (w_st_dac0_fifo_sel == 2'b01)? i_dac0_fifo_reload1_dout :
						  (w_st_dac0_fifo_sel == 2'b10)? i_dac0_fifo_reload2_dout :
						                                 32'b0                    ;
//}

// dac0 fifo rd_en master : //{
assign w_dac0_fifo_rd_en = (w_fdcs_cnt_duration_dac0==0)? 1'b1 :
						   (r_fdcs_cnt_duration_dac0==0)? 1'b1 : 1'b0 ;
//}

// dac0 fifo valid master : //{
assign w_dac0_fifo_valid = i_dac0_fifo_valid | i_dac0_fifo_reload1_valid | i_dac0_fifo_reload2_valid;
//}


// dac0 fifo from user interface //{
assign c_dac0_fifo_rd_ck          =  i_clk_dac0_dco;
assign o_dac0_fifo_rd_en          =  flag_fdcs_active_dac0      & 
									 i_dac0_fifo_valid          & 
									 w_dac0_fifo_rd_en          & 
									 (w_st_dac0_fifo_sel == 2'b00);
//}

// dac0 fifo reload1 interface //{
wire w_dac0_fifo_reload1_wr_en;
reg  r_dac0_fifo_reload1_wr_en;
//
wire [31:0] w_dac0_fifo_reload1_din;
reg  [31:0] r_dac0_fifo_reload1_din;
//
assign c_dac0_fifo_reload1_wr_ck  =  i_clk_dac0_dco   ;
//
assign w_dac0_fifo_reload1_wr_en  =  (w_st_dac0_fifo_sel == 2'b00)? o_dac0_fifo_rd_en :
																	o_dac0_fifo_reload2_rd_en;
assign w_dac0_fifo_reload1_din    =  (w_st_dac0_fifo_sel == 2'b00)? i_dac0_fifo_dout : 
																	i_dac0_fifo_reload2_dout;
//
assign o_dac0_fifo_reload1_wr_en  = r_dac0_fifo_reload1_wr_en;
assign o_dac0_fifo_reload1_din    = r_dac0_fifo_reload1_din  ;
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_dac0_fifo_reload1_wr_en  <=  1'b0;
		r_dac0_fifo_reload1_din    <= 32'h0;
	end
	else begin
		r_dac0_fifo_reload1_wr_en  <= w_dac0_fifo_reload1_wr_en;
		r_dac0_fifo_reload1_din    <= w_dac0_fifo_reload1_din  ;
	end
end
//
assign c_dac0_fifo_reload1_rd_ck  =  i_clk_dac0_dco   ;
assign o_dac0_fifo_reload1_rd_en  =  flag_fdcs_active_dac0      & 
									 i_dac0_fifo_reload1_valid  & 
									 w_dac0_fifo_rd_en          & 
									 (w_st_dac0_fifo_sel == 2'b01);
//}

// dac0 fifo reload2 interface //{
wire w_dac0_fifo_reload2_wr_en;
reg  r_dac0_fifo_reload2_wr_en;
//
wire [31:0] w_dac0_fifo_reload2_din;
reg  [31:0] r_dac0_fifo_reload2_din;
//
assign c_dac0_fifo_reload2_wr_ck  =  i_clk_dac0_dco   ;
//
assign w_dac0_fifo_reload2_wr_en  =  o_dac0_fifo_reload1_rd_en;
assign w_dac0_fifo_reload2_din    =  i_dac0_fifo_reload1_dout ;
//
assign o_dac0_fifo_reload2_wr_en  = (last_pulse_run_dac0)? 1'b0 : r_dac0_fifo_reload2_wr_en;
assign o_dac0_fifo_reload2_din    = r_dac0_fifo_reload2_din  ;
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_dac0_fifo_reload2_wr_en  <=  1'b0;
		r_dac0_fifo_reload2_din    <= 32'h0;
	end
	else begin
		r_dac0_fifo_reload2_wr_en  <= w_dac0_fifo_reload2_wr_en;
		r_dac0_fifo_reload2_din    <= w_dac0_fifo_reload2_din  ;
	end
end
//
assign c_dac0_fifo_reload2_rd_ck  =  i_clk_dac0_dco   ;
assign o_dac0_fifo_reload2_rd_en  =  flag_fdcs_active_dac0      & 
									 i_dac0_fifo_reload2_valid  & 
									 w_dac0_fifo_rd_en          & 
									 (w_st_dac0_fifo_sel == 2'b10);
//}

//}

// dac1 fifo control //{

// internal signals //{

reg  [1:0] r_st_dac1_fifo_sel;  
//
//   i_dac1_fifo_empty
//   i_dac1_fifo_reload1_empty
//   i_dac1_fifo_reload2_empty
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_st_dac1_fifo_sel      <=  2'b00;
	end
	else if (flag_fdcs_run_dac1) begin
		//
		if (w_hold_pulse_dac1) begin
			// stay
			r_st_dac1_fifo_sel      <= r_st_dac1_fifo_sel;
		end
		else if      (i_dac1_fifo_empty == 0) begin
			r_st_dac1_fifo_sel      <=  2'b00;
		end
		else if (r_st_dac1_fifo_sel == 2'b00 && i_dac1_fifo_empty == 1) begin
			r_st_dac1_fifo_sel      <=  2'b01;
		end 
		else if (r_st_dac1_fifo_sel == 2'b01 && i_dac1_fifo_reload1_empty == 1) begin
			r_st_dac1_fifo_sel      <=  2'b10;
		end
		else if (r_st_dac1_fifo_sel == 2'b10 && i_dac1_fifo_reload2_empty == 1) begin
			r_st_dac1_fifo_sel      <=  2'b01;
		end
	end
	else begin
		r_st_dac1_fifo_sel  <=  2'b00;
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_fdcs_cnt_repeat_dac1  <= 16'd0 ;
	end
	else if (flag_fdcs_run_dac1) begin
		//
		if      (i_dac1_fifo_empty == 0) begin
			r_fdcs_cnt_repeat_dac1  <= 16'd1 ;
		end
		else if (r_st_dac1_fifo_sel == 2'b00 && i_dac1_fifo_empty == 1) begin
			r_fdcs_cnt_repeat_dac1  <= r_fdcs_cnt_repeat_dac1 + 1;
		end 
		else if (r_st_dac1_fifo_sel == 2'b01 && i_dac1_fifo_reload1_empty == 1) begin
			r_fdcs_cnt_repeat_dac1  <= r_fdcs_cnt_repeat_dac1 + 1;
		end
		else if (r_st_dac1_fifo_sel == 2'b10 && i_dac1_fifo_reload2_empty == 1) begin
			r_fdcs_cnt_repeat_dac1  <= r_fdcs_cnt_repeat_dac1 + 1;
		end
	end
	else begin
		r_fdcs_cnt_repeat_dac1  <= 16'd0 ;
	end
end
//
assign  w_flag_trans_st_dac1_fifo_sel = 
		(r_st_dac1_fifo_sel == 2'b00 && i_dac1_fifo_empty == 1)         |
		(r_st_dac1_fifo_sel == 2'b01 && i_dac1_fifo_reload1_empty == 1) |
		(r_st_dac1_fifo_sel == 2'b10 && i_dac1_fifo_reload2_empty == 1) ;

reg  r_smp_flag_fdcs_run_dac1;
wire w_fall_flag_fdcs_run_dac1;
reg  r_smp_fall_flag_fdcs_run_dac1;
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_smp_flag_fdcs_run_dac1      <=  1'b0;
		r_smp_fall_flag_fdcs_run_dac1 <=  1'b0;		
	end
	else begin
		r_smp_flag_fdcs_run_dac1      <=  flag_fdcs_run_dac1      ;
		r_smp_fall_flag_fdcs_run_dac1 <=  w_fall_flag_fdcs_run_dac1;
	end
end
//
assign w_fall_flag_fdcs_run_dac1 = ~flag_fdcs_run_dac1 & r_smp_flag_fdcs_run_dac1; // falling
assign last_pulse_run_dac1 = w_fall_flag_fdcs_run_dac1 | r_smp_fall_flag_fdcs_run_dac1; // falling + one delay

//} 

// one step earlier before r_st_dac1_fifo_sel //{
wire [1:0] w_st_dac1_fifo_sel; 
//   ...
//   2'b00 :  dac1_fifo_sel
//   2'b01 :  dac1_fifo_reload1_sel
//   2'b10 :  dac1_fifo_reload2_sel
//   2'b11 :  NA
//
//   i_dac1_fifo_empty
//   i_dac1_fifo_reload1_empty
//   i_dac1_fifo_reload2_empty
//
assign w_st_dac1_fifo_sel = (r_st_dac1_fifo_sel == 2'b00)? (i_dac1_fifo_empty         == 1)? 2'b01 : 2'b00 : 
							(r_st_dac1_fifo_sel == 2'b01)? (i_dac1_fifo_reload1_empty == 1)? 2'b10 : 2'b01 : 
							(r_st_dac1_fifo_sel == 2'b10)? (i_dac1_fifo_reload2_empty == 1)? 2'b01 : 2'b10 : 
							                               2'b00 ;

//}

// dac1 data selection : //{
assign w_dac1_fifo_dout = (w_st_dac1_fifo_sel == 2'b00)? i_dac1_fifo_dout         : 
						  (w_st_dac1_fifo_sel == 2'b01)? i_dac1_fifo_reload1_dout :
						  (w_st_dac1_fifo_sel == 2'b10)? i_dac1_fifo_reload2_dout :
						                                 32'b0                    ;
//}

// dac1 fifo rd_en master : //{
assign w_dac1_fifo_rd_en = (w_fdcs_cnt_duration_dac1==0)? 1'b1 :
						   (r_fdcs_cnt_duration_dac1==0)? 1'b1 : 1'b0 ;
//}

// dac1 fifo valid master : //{
assign w_dac1_fifo_valid = i_dac1_fifo_valid | i_dac1_fifo_reload1_valid | i_dac1_fifo_reload2_valid;
//}


// dac1 fifo from user interface //{
assign c_dac1_fifo_rd_ck          =  i_clk_dac1_dco;
assign o_dac1_fifo_rd_en          =  flag_fdcs_active_dac1      & 
									 i_dac1_fifo_valid          & 
									 w_dac1_fifo_rd_en          & 
									 (w_st_dac1_fifo_sel == 2'b00);
//}

// dac1 fifo reload1 interface //{
wire w_dac1_fifo_reload1_wr_en;
reg  r_dac1_fifo_reload1_wr_en;
//
wire [31:0] w_dac1_fifo_reload1_din;
reg  [31:0] r_dac1_fifo_reload1_din;
//
assign c_dac1_fifo_reload1_wr_ck  =  i_clk_dac1_dco   ;
//
assign w_dac1_fifo_reload1_wr_en  =  (w_st_dac1_fifo_sel == 2'b00)? o_dac1_fifo_rd_en :
																	o_dac1_fifo_reload2_rd_en;
assign w_dac1_fifo_reload1_din    =  (w_st_dac1_fifo_sel == 2'b00)? i_dac1_fifo_dout : 
																	i_dac1_fifo_reload2_dout;
//
assign o_dac1_fifo_reload1_wr_en  = r_dac1_fifo_reload1_wr_en;
assign o_dac1_fifo_reload1_din    = r_dac1_fifo_reload1_din  ;
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_dac1_fifo_reload1_wr_en  <=  1'b0;
		r_dac1_fifo_reload1_din    <= 32'h0;
	end
	else begin
		r_dac1_fifo_reload1_wr_en  <= w_dac1_fifo_reload1_wr_en;
		r_dac1_fifo_reload1_din    <= w_dac1_fifo_reload1_din  ;
	end
end
//
assign c_dac1_fifo_reload1_rd_ck  =  i_clk_dac1_dco   ;
assign o_dac1_fifo_reload1_rd_en  =  flag_fdcs_active_dac1      & 
									 i_dac1_fifo_reload1_valid  & 
									 w_dac1_fifo_rd_en          & 
									 (w_st_dac1_fifo_sel == 2'b01);
//}

// dac1 fifo reload2 interface //{
wire w_dac1_fifo_reload2_wr_en;
reg  r_dac1_fifo_reload2_wr_en;
//
wire [31:0] w_dac1_fifo_reload2_din;
reg  [31:0] r_dac1_fifo_reload2_din;
//
assign c_dac1_fifo_reload2_wr_ck  =  i_clk_dac1_dco   ;
//
assign w_dac1_fifo_reload2_wr_en  =  o_dac1_fifo_reload1_rd_en;
assign w_dac1_fifo_reload2_din    =  i_dac1_fifo_reload1_dout ;
//
assign o_dac1_fifo_reload2_wr_en  = (last_pulse_run_dac1)? 1'b0 : r_dac1_fifo_reload2_wr_en;
assign o_dac1_fifo_reload2_din    = r_dac1_fifo_reload2_din  ;
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_dac1_fifo_reload2_wr_en  <=  1'b0;
		r_dac1_fifo_reload2_din    <= 32'h0;
	end
	else begin
		r_dac1_fifo_reload2_wr_en  <= w_dac1_fifo_reload2_wr_en;
		r_dac1_fifo_reload2_din    <= w_dac1_fifo_reload2_din  ;
	end
end
//
assign c_dac1_fifo_reload2_rd_ck  =  i_clk_dac1_dco   ;
assign o_dac1_fifo_reload2_rd_en  =  flag_fdcs_active_dac1      & 
									 i_dac1_fifo_reload2_valid  & 
									 w_dac1_fifo_rd_en          & 
									 (w_st_dac1_fifo_sel == 2'b10);
//}

//}

//}

//// TODO: dac pin out selection  //{
assign o_dac0_data_pin = (flag_cid_ff_pulse_run_dac0[0])? r_fcid_dat_out_dac0
						:(flag_cid_sq_pulse_run_dac0[0])? r_cid_dat_out_dac0
						:(r_dcs_run )? r_dcs_data_dac0
						:(r_fdcs_run)? r_fdcs_data_dac0
						: 16'b0;
assign o_dac1_data_pin = (flag_cid_ff_pulse_run_dac1[0])? r_fcid_dat_out_dac1
						:(flag_cid_sq_pulse_run_dac1[0])? r_cid_dat_out_dac1
						:(r_dcs_run )? r_dcs_data_dac1 
						:(r_fdcs_run)? r_fdcs_data_dac1
						: 16'b0;
//}

//// DAC activity flag output  //{
//	output wire        o_dac0_active_dco,
//	output wire        o_dac1_active_dco,
//	output wire        o_dac0_active_clk,
//	output wire        o_dac1_active_clk,
reg r_dac0_active_clk; // @clk
reg r_dac1_active_clk; // @clk

//
assign o_dac0_active_clk = r_dac0_active_clk;
assign o_dac1_active_clk = r_dac1_active_clk;
//
always @(posedge clk, negedge reset_n) // r_dac0_active_clk, r_dac1_active_clk
	if (!reset_n) begin
		r_dac0_active_clk <= 1'b0;
		r_dac1_active_clk <= 1'b0;
	end
	else begin 
		// sample flags
		r_dac0_active_clk <= flag_fcid_pulse_active_dac0 | flag_cid_pulse_active_dac0 | flag_dcs_active_dac0 | flag_fdcs_active_dac0;
		r_dac1_active_clk <= flag_fcid_pulse_active_dac1 | flag_cid_pulse_active_dac1 | flag_dcs_active_dac1 | flag_fdcs_active_dac1;
		//
	end

//
//assign o_dac0_active_dco = flag_dcs_active_dac0 | flag_fdcs_active_dac0;
assign o_dac0_active_dco = flag_fcid_pulse_active_dac0 | flag_cid_pulse_active_dac0 | flag_dcs_active_dac0 | r_fdcs_active_dac0;
//assign o_dac1_active_dco = flag_dcs_active_dac1 | flag_fdcs_active_dac1;
assign o_dac1_active_dco = flag_fcid_pulse_active_dac1 | flag_cid_pulse_active_dac1 | flag_dcs_active_dac1 | r_fdcs_active_dac1; 

//}


//// Status flag and controls //{

wire w_write_control = i_trig_dacz_ctrl[4]; //$$
wire w_read_status   = i_trig_dacz_ctrl[5]; //$$

// update control reg based on clk
reg [31:0] r_control_pulse;
//
always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_control_pulse   <= 32'b0;
	end
	else begin 
		if (w_write_control) begin
			r_control_pulse   <= i_wire_dacz_data;
		end
	end
end


// return status or control reg
//wire [31:0] w_status_data = {30'b0, r_dac1_active_clk, r_dac0_active_clk};
wire [31:0] w_status_data = {r_control_pulse[31:2], r_dac1_active_clk, r_dac0_active_clk};

// hold pulse signal 
(* keep = "true" *) reg r_dac0_hold_pulse; // from r_control_pulse[2]
(* keep = "true" *) reg r_dac1_hold_pulse; // from r_control_pulse[3]
// re-sampling
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_dac0_hold_pulse  <=  1'b0;
	end
	else begin
		r_dac0_hold_pulse  <=  r_control_pulse[2];
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_dac1_hold_pulse  <=  1'b0;
	end
	else begin
		r_dac1_hold_pulse  <=  r_control_pulse[3];
	end
end
//
assign w_hold_pulse_dac0 = r_dac0_hold_pulse;
assign w_hold_pulse_dac1 = r_dac1_hold_pulse;


//}


//// repeat pattern period //{

wire w_write_repeat_period = i_trig_dacz_ctrl[6]; //$$
wire w_read_repeat_period  = i_trig_dacz_ctrl[7]; //$$

(* keep = "true" *) reg [31:0] r_repeat_period;
//
always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_repeat_period   <= 32'b0;
	end
	else begin 
		if (w_write_repeat_period) begin
			r_repeat_period   <= i_wire_dacz_data;
		end
	end
end
	
//}

//---------------------------------------------------------------//

//// TODO: o_wire_dacz_data  //{

reg [31:0]  r_wire_dacx_data;
assign o_wire_dacz_data = r_wire_dacx_data;

// read r_wire_dacx_data
always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_wire_dacx_data   <= 32'b0;
	end
	else begin 
		//
		if (w_trig_cid_stat_rd)
			r_wire_dacx_data   <= w_cid_reg_stat;  
		//
		else if (w_trig_cid_adrs_rd)
			r_wire_dacx_data   <= r_cid_reg_adrs;  
		//
		else if (w_trig_cid_ctrl_rd)
			r_wire_dacx_data   <= r_cid_reg_ctrl;  
		////
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0000) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac0_bias_code};  
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0010) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac1_bias_code};  
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0020) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac0_num_repeat};  
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0030) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac1_num_repeat};
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0040))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_0, r_cid_reg_dac0_inc_seq_0};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0041))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_1, r_cid_reg_dac0_inc_seq_1};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0042))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_2, r_cid_reg_dac0_inc_seq_2};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0043))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_3, r_cid_reg_dac0_inc_seq_3};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0044))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_4, r_cid_reg_dac0_inc_seq_4};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0045))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_5, r_cid_reg_dac0_inc_seq_5};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0046))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_6, r_cid_reg_dac0_inc_seq_6};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0047))  r_wire_dacx_data   <= {r_cid_reg_dac0_dat_seq_7, r_cid_reg_dac0_inc_seq_7};
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0050))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_0, r_cid_reg_dac1_inc_seq_0};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0051))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_1, r_cid_reg_dac1_inc_seq_1};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0052))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_2, r_cid_reg_dac1_inc_seq_2};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0053))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_3, r_cid_reg_dac1_inc_seq_3};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0054))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_4, r_cid_reg_dac1_inc_seq_4};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0055))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_5, r_cid_reg_dac1_inc_seq_5};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0056))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_6, r_cid_reg_dac1_inc_seq_6};
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0057))  r_wire_dacx_data   <= {r_cid_reg_dac1_dat_seq_7, r_cid_reg_dac1_inc_seq_7};
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0060))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_0;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0061))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_1;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0062))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_2;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0063))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_3;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0064))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_4;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0065))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_5;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0066))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_6;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0067))  r_wire_dacx_data   <=  r_cid_reg_dac0_dur_seq_7;
		//                                                                                      
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0070))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_0;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0071))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_1;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0072))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_2;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0073))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_3;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0074))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_4;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0075))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_5;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0076))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_6;
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_0077))  r_wire_dacx_data   <=  r_cid_reg_dac1_dur_seq_7;
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_1000) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac0_num_ffdat};
		//
		else if (w_trig_cid_data_rd & (r_cid_reg_adrs==32'h_0000_1010) )
			r_wire_dacx_data   <= {16'b0, r_cid_reg_dac1_num_ffdat};
		
		////
		else if (w_dcs_read_adrs)
			r_wire_dacx_data   <= {29'b0, r_dcs_dacx_adrs};  
		//  
		else if (w_dcs_read_data_dac0)
			r_wire_dacx_data   <= (r_dcs_dacx_adrs==3'b000)? r_dcs_dac0_data_seq_0 : 
								  (r_dcs_dacx_adrs==3'b001)? r_dcs_dac0_data_seq_1 :
								  (r_dcs_dacx_adrs==3'b010)? r_dcs_dac0_data_seq_2 :
								  (r_dcs_dacx_adrs==3'b011)? r_dcs_dac0_data_seq_3 : 
								  (r_dcs_dacx_adrs==3'b100)? r_dcs_dac0_data_seq_4 : 
								  (r_dcs_dacx_adrs==3'b101)? r_dcs_dac0_data_seq_5 :
								  (r_dcs_dacx_adrs==3'b110)? r_dcs_dac0_data_seq_6 :
								                             r_dcs_dac0_data_seq_7 ; 
		//
		else if (w_dcs_read_data_dac1)
			r_wire_dacx_data   <= (r_dcs_dacx_adrs==3'b000)? r_dcs_dac1_data_seq_0 : 
								  (r_dcs_dacx_adrs==3'b001)? r_dcs_dac1_data_seq_1 :
								  (r_dcs_dacx_adrs==3'b010)? r_dcs_dac1_data_seq_2 :
								  (r_dcs_dacx_adrs==3'b011)? r_dcs_dac1_data_seq_3 : 
								  (r_dcs_dacx_adrs==3'b100)? r_dcs_dac1_data_seq_4 : 
								  (r_dcs_dacx_adrs==3'b101)? r_dcs_dac1_data_seq_5 :
								  (r_dcs_dacx_adrs==3'b110)? r_dcs_dac1_data_seq_6 :
								                             r_dcs_dac1_data_seq_7 ; 
		//
		else if (w_dcs_read_repeat)
			r_wire_dacx_data   <= {r_dcs_repeat_dac1, r_dcs_repeat_dac0};  
		else if (w_fdcs_read_repeat)
			r_wire_dacx_data   <= {r_fdcs_repeat_dac1, r_fdcs_repeat_dac0};  
		//
		else if (w_read_status) 
			r_wire_dacx_data   <= w_status_data;
		//
		else if (w_read_repeat_period) 
			r_wire_dacx_data   <= r_repeat_period;
		//
		else
			r_wire_dacx_data   <= r_wire_dacx_data;
		//
	end
end
//}

//---------------------------------------------------------------//


endmodule
//}

