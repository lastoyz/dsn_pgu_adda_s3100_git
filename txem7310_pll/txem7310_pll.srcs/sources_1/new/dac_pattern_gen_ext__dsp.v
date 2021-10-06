// dac_pattern_gen_ext__dsp.v
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

// counter ip 
// //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
// c_counter_binary_down_b32_dsp_0 your_instance_name (
//   .CLK(CLK),    // input wire CLK
//   .CE(CE),      // input wire CE
//   .SCLR(SCLR),  // input wire SCLR
//   .LOAD(LOAD),  // input wire LOAD
//   .L(L),        // input wire [31 : 0] L
//   .Q(Q)        // output wire [31 : 0] Q
// );
// // INST_TAG_END ------ End INSTANTIATION Template ---------

// module dsp replica for c_counter_binary_down_b32_dsp_0
module reg_rep__c_counter_binary_down_b32_dsp_0  ( //{
	input  wire          CLK  ,
	input  wire          CE   ,
	input  wire          SCLR ,
	input  wire          LOAD ,
	input  wire [31 : 0] L    ,
	output wire [31 : 0] Q
);

reg [31 : 0] r_Q;

assign Q = r_Q;

always @(posedge CLK   ) begin 
	if (SCLR  ) begin 
		r_Q  <=  48'b0;
	end
	else if (CE) begin
		if (LOAD == 0) begin
			r_Q  <=  r_Q - 1;
		end
		else begin
			r_Q  <=  L;
		end
	end 
end


endmodule
//}


// module dsp replica for dsp48_macro_APC_b32_0
//(* use_dsp48 = "yes" *)
module reg_rep__dsp48_macro_APC_b32_0  ( //{
	input  wire CLK   , 
	input  wire CE    , // active HIGH
	input  wire SCLR  , // active high
	input  wire SEL   ,
	input  wire [15 : 0] A,
	input  wire [31 : 0] C,
	output wire [47 : 0] P
);

reg [47 : 0] r_P;

assign P = r_P;

always @(posedge CLK   ) begin 
	if (SCLR  ) begin 
		r_P  <=  48'b0;
	end
	else if (CE) begin
		if (SEL == 0) begin
			r_P  <=  r_P + {{32{A[15]}}, {A}};
		end
		else begin
			r_P  <=  { {16{C[31]}}, {C}};
		end
	end 
end

endmodule
//}


// buffered acc ip
// //----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
// xbip_dsp48_macro_APC_b32_ce_ctl_0 your_instance_name (
//   .CLK(CLK),    // input wire CLK
//   .SCLR(SCLR),  // input wire SCLR
//   .SEL(SEL),    // input wire [0 : 0] SEL
//   .A(A),        // input wire [15 : 0] A
//   .C(C),        // input wire [31 : 0] C
//   .P(P),        // output wire [47 : 0] P
//   .CEM(CEM),    // input wire CEM vs .CEA3(CEA3),  // input wire CEA3
//   .CEP(CEP)    // input wire CEP
// );
// // INST_TAG_END ------ End INSTANTIATION Template ---------

// module dsp replica for dsp48_macro_APC_b32_ce_ctl_0
//(* use_dsp48 = "yes" *)
module reg_rep__dsp48_macro_APC_b32_ce_ctl_0  ( //{
	input  wire CLK   , 
	input  wire CEP   , // active HIGH for P
	//input  wire CEM   , // active HIGH for A
	input  wire CEA3  , // active HIGH for A
	input  wire SCLR  , // active high
	input  wire SEL   ,
	input  wire [15 : 0] A, 
	input  wire [31 : 0] C,
	output wire [47 : 0] P
);

reg [47 : 0] r_P;
reg [15 : 0] r_A;

assign P = r_P;

wire CEM = CEA3; // rename port

always @(posedge CLK   ) begin 
	if (SCLR  ) begin 
		r_P  <=  48'b0;
		r_A  <=  16'b0;
	end
	else begin
		if (CEP) begin
			if (SEL == 0) begin
				r_P  <=  r_P + {{32{r_A[15]}}, {r_A}};
			end
			else begin
				r_P  <=  { {16{C[31]}}, {C}};
			end
		end 
		//
		if (CEM) begin
			r_A  <=  A;
		end 
	end
end

endmodule
//}


// module using dsp macro
module dac_pattern_gen_ext__dsp ( //{
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

	// DAC data port 
	output wire [15:0] o_dac0_data_pin, // 
	output wire [15:0] o_dac1_data_pin, // 
	
	// DAC activity flag 
	output wire        o_dac0_active_dco,
	output wire        o_dac1_active_dco,
	output wire        o_dac0_active_clk,
	output wire        o_dac1_active_clk,
	output wire        o_enable_dac0_fifo_reload,
	output wire        o_enable_dac1_fifo_reload,
	
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
	
	output wire        o_dac_pttn_trig_out, 
	
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
//   bit[ 6] = write_repeat_period   //$$ maybe for minimum period
//   bit[ 7] = read_repeat_period    //$$ maybe for minimum period
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

//// TODO: CID (code-incremental-duration test) and FCID //{
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
wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6]; //$$ false path try
wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7]; //$$ false path try

wire w_force_trig_out             = r_cid_reg_ctrl[8];// new control for trig out     
assign o_dac_pttn_trig_out        = w_force_trig_out;

//}

//// status //{
(* keep = "true" *) reg flag_cid_pulse_active_dac0;
(* keep = "true" *) reg flag_cid_pulse_active_dac1;
(* keep = "true" *) reg flag_fcid_pulse_active_dac0;
(* keep = "true" *) reg flag_fcid_pulse_active_dac1;
//
(* keep = "true" *) reg [1:0] flag_cid_sq_pulse_run_dac0; // seq test
(* keep = "true" *) reg [1:0] flag_cid_sq_pulse_run_dac1; // seq test
//(* keep = "true" *) reg [3:0] flag_cid_ff_pulse_run_dac0; // fifo test //$$ add latency
//(* keep = "true" *) reg [3:0] flag_cid_ff_pulse_run_dac1; // fifo test //$$ add latency
(* keep = "true" *) reg [1:0] flag_cid_ff_pulse_run_dac0; // fifo test 
(* keep = "true" *) reg [1:0] flag_cid_ff_pulse_run_dac1; // fifo test 
//
wire      w_rise_cid_sq_pulse_run_dac0 = (~flag_cid_sq_pulse_run_dac0[1]) & (flag_cid_sq_pulse_run_dac0[0]);
wire      w_rise_cid_sq_pulse_run_dac1 = (~flag_cid_sq_pulse_run_dac1[1]) & (flag_cid_sq_pulse_run_dac1[0]);
//wire      w_rise_cid_ff_pulse_run_dac0 = (~flag_cid_ff_pulse_run_dac0[3]) & (flag_cid_ff_pulse_run_dac0[2]);
//wire      w_rise_cid_ff_pulse_run_dac1 = (~flag_cid_ff_pulse_run_dac1[3]) & (flag_cid_ff_pulse_run_dac1[2]);
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

reg [15:0] r_cid_dat_inc_dac0; // inc info
reg [15:0] r_cid_dat_inc_dac1; // inc info

reg [ 2:0] r_cid_cnt_idx_dac0; // only for 8-seq
reg [31:0] r_cid_cnt_dur_dac0;
reg [15:0] r_cid_cnt_rpt_dac0;

reg [ 2:0] r_cid_cnt_idx_dac1; // only for 8-seq
reg [31:0] r_cid_cnt_dur_dac1;
reg [15:0] r_cid_cnt_rpt_dac1;

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


////---- TODO: fifo-based cid ----////

// pulse hold signals
wire        w_hold_pulse_dac0;
wire        w_hold_pulse_dac1;


wire [31:0] w_fcid_cnt_dur_dac0; // = from fifo // to dsp
wire [15:0] w_fcid_dat_inc_dac0; // = from fifo // to dsp
wire [15:0] w_fcid_dat_out_dac0; // = from fifo // to dsp
wire [31:0] w_fcid_cnt_dur_dac1; // = from fifo // to dsp
wire [15:0] w_fcid_dat_inc_dac1; // = from fifo // to dsp
wire [15:0] w_fcid_dat_out_dac1; // = from fifo // to dsp

wire        w_fcid_data_load_dac0; // dsp
wire        w_fcid_data_load_dac1; // dsp

//// flag_fcid_pulse_active_dac0
//// flag_fcid_pulse_active_dac1
//// flag_cid_ff_pulse_run_dac0 // @i_clk_dac0_dco
//// flag_cid_ff_pulse_run_dac1 // @i_clk_dac1_dco

//// r_cid_reg_dac0_num_repeat // used in cid and fcid
//// r_cid_reg_dac1_num_repeat // used in cid and fcid
//// r_cid_reg_dac0_num_ffdat  // used in fcid
//// r_cid_reg_dac1_num_ffdat  // used in fcid


//// TODO: dsp macro 
//  // note: [P=A+P, P=C]
//
//  xbip_dsp48_macro_APC_b32_0 : dsp macro
//  reg_rep__dsp48_macro_APC_b32_0 : reg replica
//
//  xbip_dsp48_macro_APC_b32_0  dsp48__AP_C__inst (
//  	.CLK   (clk_400M  ),  // input wire CLK   //
//  	.CE    (test_CE   ),  // input wire CE    // active HIGH
//  	.SCLR  (reset     ),  // input wire SCLR  // active high
//  	.SEL   (test_SEL  ),  // input wire [0 : 0] SEL
//  	.A     (test_A    ),  // input wire [15 : 0] A
//  	.C     (test_C    ),  // input wire [31 : 0] C
//  	.P     (w_P       )   // output wire [47 : 0] P
//  );

// TODO: state para for dsp 
//parameter STATE_SIG_0 = 4'h1; // initial and idle state
	// clear cnt_idx_dac0
//parameter STATE_SIG_1 = 4'h2; // pulse start; data from fifo 
	// count up cnt_idx_dac0 // until reach to r_cid_reg_dac0_num_ffdat
//parameter STATE_SIG_2 = 4'h4; // pulse repeat
	// count up cnt_rpt_dac0
//parameter STATE_SIG_3 = 4'h8;  // sequence finish state

//$$ new states and flag
parameter STATE_IDLE     = 4'h1; // idle or initial
parameter STATE_EVEN_SEQ = 4'h2; // even order sequence gen
parameter STATE_ODD__SEQ = 4'h4; // odd  order sequence gen
parameter STATE_FIN__SEQ = 4'h8; // finish seq.

reg flag_repeat_pattern__dac0; // signal for repeat pattern 
reg flag_repeat_pattern__dac1; // signal for repeat pattern 


////// TODO: dsp for dac0  //{

// dsp macro wires //{
wire          w_CE___dsp48_cnt_idx_dac0 ;
wire          w_SCLR_dsp48_cnt_idx_dac0 ;
wire          w_SEL__dsp48_cnt_idx_dac0 ;
wire [15 : 0] w_A____dsp48_cnt_idx_dac0 ;
wire [31 : 0] w_C____dsp48_cnt_idx_dac0 ;
wire [47 : 0] w_P____dsp48_cnt_idx_dac0 ;
wire [15 : 0]            w_cnt_idx_dac0 = w_P____dsp48_cnt_idx_dac0[15:0];
//
wire          w_CE___dsp48_cnt_dur_dac0 ;
wire          w_SCLR_dsp48_cnt_dur_dac0 ;
wire          w_SEL__dsp48_cnt_dur_dac0 ;
wire [15 : 0] w_A____dsp48_cnt_dur_dac0 ;
wire [31 : 0] w_C____dsp48_cnt_dur_dac0 ;
wire [47 : 0] w_P____dsp48_cnt_dur_dac0 ;
//$$wire [31 : 0]        w_cnt_dur_dac0 = w_P____dsp48_cnt_dur_dac0[31:0]; // 32b
//$$wire [23 : 0]        w_cnt_dur_dac0 = w_P____dsp48_cnt_dur_dac0[23:0]; // 24b
//
wire          w_CE___cnt32b_cnt_dur_dac0 ;
wire          w_SCLR_cnt32b_cnt_dur_dac0 ;
wire          w_LOAD_cnt32b_cnt_dur_dac0 ;
wire [31 : 0] w_L____cnt32b_cnt_dur_dac0 ;
wire [31 : 0] w_Q____cnt32b_cnt_dur_dac0 ;
wire [31 : 0]             w_cnt_dur_dac0 = w_Q____cnt32b_cnt_dur_dac0[31:0]; // 32b
//
wire          w_CE___dsp48_cnt_rpt_dac0 ;
wire          w_SCLR_dsp48_cnt_rpt_dac0 ;
wire          w_SEL__dsp48_cnt_rpt_dac0 ;
wire [15 : 0] w_A____dsp48_cnt_rpt_dac0 ;
wire [31 : 0] w_C____dsp48_cnt_rpt_dac0 ;
wire [47 : 0] w_P____dsp48_cnt_rpt_dac0 ;
wire [15 : 0]            w_cnt_rpt_dac0 = w_P____dsp48_cnt_rpt_dac0[15:0];
//
//wire          w_CE___dsp48_dat_out_dac0 ;
wire          w_CEP___dsp48_dat_out_dac0 ;
wire          w_CEM___dsp48_dat_out_dac0 ;
wire          w_SCLR_dsp48_dat_out_dac0 ;
wire          w_SEL__dsp48_dat_out_dac0 ;
wire [15 : 0] w_A____dsp48_dat_out_dac0 ;
wire [31 : 0] w_C____dsp48_dat_out_dac0 ;
wire [47 : 0] w_P____dsp48_dat_out_dac0 ;
wire [15 : 0]            w_dat_out_dac0 = w_P____dsp48_dat_out_dac0[15:0]; //$$ to come with sign correction or overflow
		   // w_P____dsp48_dat_out_dac0[47:0] > 0x_0000_0000_7FFF
		   // w_P____dsp48_dat_out_dac0[47:0] < 0x_FFFF_FFFF_8000

//}


// control state for dsp48
reg  [3:0] r_state_dsp48__dac0;
reg  [3:0] r_state_dsp48__dac0__smp;

// related var:
//  w_rise_cid_ff_pulse_run_dac0
//  r_cid_reg_dac0_num_ffdat
//  r_cid_reg_dac0_num_repeat
//  w_fcid_cnt_dur_dac0
//  w_fcid_dat_out_dac0
//  w_fcid_dat_inc_dac0

// fifo data load //{
assign w_fcid_data_load_dac0     = ((r_state_dsp48__dac0 == STATE_EVEN_SEQ || r_state_dsp48__dac0 == STATE_ODD__SEQ) && (w_cnt_dur_dac0 == 0))? 1'b1 : 
                                   (w_rise_cid_ff_pulse_run_dac0                                 )? 1'b1 : 
                                                                                                    1'b0 ;
//}

// dac output latency //{
reg [15:0] r_dat_out_dac0;
reg [15:0] r_dat_out_dac0__smp;
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_dat_out_dac0            <=  16'b0;
		r_dat_out_dac0__smp       <=  16'b0;
		r_state_dsp48__dac0__smp  <=   4'b0;
	end
	else begin
		// sampling 
		r_dat_out_dac0__smp       <=  w_dat_out_dac0;
		r_state_dsp48__dac0__smp  <=  r_state_dsp48__dac0;
		
		// detect proper output 
		//$$ if (r_state_dsp48__dac0__smp == STATE_SIG_2) begin
		//$$ 	r_dat_out_dac0   <=   16'b0;
		//$$ 	end
		//$$ else if (r_state_dsp48__dac0 == STATE_SIG_1) begin
		//$$ 	r_dat_out_dac0   <=   r_dat_out_dac0__smp;
		//$$ 	end
		//$$ else if (r_state_dsp48__dac0 == STATE_SIG_2) begin
		//$$ 	r_dat_out_dac0   <=   r_dat_out_dac0__smp; 
		//$$ 	end
		if      (r_state_dsp48__dac0      == STATE_FIN__SEQ) begin
			r_dat_out_dac0   <=   16'b0; // pulse out finished
			end
		else if (r_state_dsp48__dac0__smp == STATE_EVEN_SEQ) begin
			r_dat_out_dac0   <=   r_dat_out_dac0__smp;
			end
		else if (r_state_dsp48__dac0__smp == STATE_ODD__SEQ) begin
			r_dat_out_dac0   <=   r_dat_out_dac0__smp; 
			end
		else begin
			r_dat_out_dac0   <=   16'b0;
		end 
	end 
end
//}


// for w_cnt_idx_dac0 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_idx_dac0__inst (
reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_idx_dac0__inst (
	.CLK   (i_clk_dac0_dco            ),  // input wire CLK   //
	.CE    (w_CE___dsp48_cnt_idx_dac0 ),  // input wire CE    // active HIGH
	.SCLR  (w_SCLR_dsp48_cnt_idx_dac0 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_cnt_idx_dac0 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_cnt_idx_dac0 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_cnt_idx_dac0 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_cnt_idx_dac0 )   // output wire [47 : 0] P
);

assign w_CE___dsp48_cnt_idx_dac0 = ((r_state_dsp48__dac0 == STATE_EVEN_SEQ || r_state_dsp48__dac0 == STATE_ODD__SEQ) && (w_cnt_dur_dac0 == 0))? 1'b1 : 1'b0;
assign w_SCLR_dsp48_cnt_idx_dac0 =  (r_state_dsp48__dac0 == STATE_IDLE)? 1'b1 : 
								     ((w_cnt_idx_dac0 == r_cid_reg_dac0_num_ffdat - 1) && (w_cnt_dur_dac0 == 0))? 1'b1 : 
								     //$$ (flag_repeat_pattern__dac0)? 1'b1 : // 1 clock delay NG //$$ (r_state_dsp48__dac0 == STATE_SIG_2)? 1'b1 : 
								     1'b0;
assign w_SEL__dsp48_cnt_idx_dac0 = 1'b0;
assign w_A____dsp48_cnt_idx_dac0 = 16'd1; // inc by 1
assign w_C____dsp48_cnt_idx_dac0 = 32'b0; // NA

//}

// for w_cnt_dur_dac0 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_dur_dac0__inst (  // use dsp
//  reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_dur_dac0__inst (
//  	.CLK   (i_clk_dac0_dco            ),  // input wire CLK   //
//  	.CE    (w_CE___dsp48_cnt_dur_dac0 ),  // input wire CE    // active HIGH
//  	.SCLR  (w_SCLR_dsp48_cnt_dur_dac0 ),  // input wire SCLR  // active high
//  	.SEL   (w_SEL__dsp48_cnt_dur_dac0 ),  // input wire [0 : 0] SEL
//  	.A     (w_A____dsp48_cnt_dur_dac0 ),  // input wire  [15 : 0] A
//  	.C     (w_C____dsp48_cnt_dur_dac0 ),  // input wire  [31 : 0] C
//  	.P     (w_P____dsp48_cnt_dur_dac0 )   // output wire [47 : 0] P
//  );
//  
//  assign w_CE___dsp48_cnt_dur_dac0 = (r_state_dsp48__dac0 == STATE_SIG_1)? 1'b1 : 
//  								   (r_state_dsp48__dac0 == STATE_SIG_2)? 1'b1 : 
//  								   (w_rise_cid_ff_pulse_run_dac0      )? 1'b1 : 
//  								    1'b0;
//  assign w_SCLR_dsp48_cnt_dur_dac0 = 1'b0; // (r_state_dsp48__dac0 == STATE_SIG_0)? 1'b1 : 1'b0;
//  assign w_SEL__dsp48_cnt_dur_dac0 = (w_cnt_dur_dac0 == 0)? 1'b1 : 1'b0; // load control // w_cnt_dur_dac0 == 0
//  assign w_A____dsp48_cnt_dur_dac0 = -16'd1; // inc by -1
//  assign w_C____dsp48_cnt_dur_dac0 = w_fcid_cnt_dur_dac0; // load from fifos

//c_counter_binary_down_b32_dsp_0            dsp48__AP_C__r_fcid_cnt_dur_dac0__inst (
reg_rep__c_counter_binary_down_b32_dsp_0 dsp48__AP_C__r_fcid_cnt_dur_dac0__inst (
	.CLK       (i_clk_dac0_dco),    // input wire CLK
	.CE        (w_CE___cnt32b_cnt_dur_dac0 ),  // input wire CE
	.SCLR      (w_SCLR_cnt32b_cnt_dur_dac0 ),  // input wire SCLR
	.LOAD      (w_LOAD_cnt32b_cnt_dur_dac0 ),  // input wire LOAD
	.L         (w_L____cnt32b_cnt_dur_dac0 ),  // input wire [31 : 0] L
	.Q         (w_Q____cnt32b_cnt_dur_dac0 )   // output wire [31 : 0] Q
);

assign w_CE___cnt32b_cnt_dur_dac0 = (r_state_dsp48__dac0 == STATE_EVEN_SEQ)? 1'b1 ://$$ (r_state_dsp48__dac0 == STATE_SIG_1)? 1'b1 : 
                                    (r_state_dsp48__dac0 == STATE_ODD__SEQ)? 1'b1 ://$$ (r_state_dsp48__dac0 == STATE_SIG_2)? 1'b1 : 
                                    (w_rise_cid_ff_pulse_run_dac0      )? 1'b1 : 
                                                                          1'b0 ;
assign w_SCLR_cnt32b_cnt_dur_dac0 =  1'b0;
assign w_LOAD_cnt32b_cnt_dur_dac0 = (r_state_dsp48__dac0 == STATE_IDLE)? 1'b1 : 
                                    (     w_cnt_dur_dac0 == 0          )? 1'b1 : 
                                                                          1'b0 ; 
assign w_L____cnt32b_cnt_dur_dac0 = w_fcid_cnt_dur_dac0;

//}

// for w_cnt_rpt_dac0 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_rpt_dac0__inst (
reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_rpt_dac0__inst (
	.CLK   (i_clk_dac0_dco            ),  // input wire CLK   //
	.CE    (w_CE___dsp48_cnt_rpt_dac0 ),  // input wire CE    // active HIGH
	.SCLR  (w_SCLR_dsp48_cnt_rpt_dac0 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_cnt_rpt_dac0 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_cnt_rpt_dac0 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_cnt_rpt_dac0 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_cnt_rpt_dac0 )   // output wire [47 : 0] P
);

assign      w_CE___dsp48_cnt_rpt_dac0 = (flag_repeat_pattern__dac0)? 1'b1 : 1'b0; //$$ (r_state_dsp48__dac0 == STATE_SIG_2)? 1'b1 : 1'b0;
assign      w_SCLR_dsp48_cnt_rpt_dac0 = (r_state_dsp48__dac0 == STATE_IDLE)? 1'b1 : 1'b0;
assign      w_SEL__dsp48_cnt_rpt_dac0 = 1'b0;
assign      w_A____dsp48_cnt_rpt_dac0 = 16'd1; // inc by 1
assign      w_C____dsp48_cnt_rpt_dac0 = 32'b0; // NA
//}

// for w_dat_out_dac0 //{

// note: [P=A+P, P=C]
//  reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_dat_out_dac0__inst (
//  	.CLK   (i_clk_dac0_dco            ),  // input wire CLK   //
//  	.CE    (w_CE___dsp48_dat_out_dac0 ),  // input wire CE    // active HIGH
//  	.SCLR  (w_SCLR_dsp48_dat_out_dac0 ),  // input wire SCLR  // active high
//  	.SEL   (w_SEL__dsp48_dat_out_dac0 ),  // input wire [0 : 0] SEL
//  	.A     (w_A____dsp48_dat_out_dac0 ),  // input wire  [15 : 0] A
//  	.C     (w_C____dsp48_dat_out_dac0 ),  // input wire  [31 : 0] C
//  	.P     (w_P____dsp48_dat_out_dac0 )   // output wire [47 : 0] P
//  );

//xbip_dsp48_macro_APC_b32_ce_ctl_0        dsp48__AP_C__r_fcid_dat_out_dac0__inst (
reg_rep__dsp48_macro_APC_b32_ce_ctl_0  dsp48__AP_C__r_fcid_dat_out_dac0__inst (
	.CLK   (i_clk_dac0_dco            ),  // input wire CLK   
	.CEP   (w_CEP__dsp48_dat_out_dac0 ),  // input wire CEP   // active HIGH
	//.CEM   (w_CEM__dsp48_dat_out_dac0 ),  // input wire CEM   // active HIGH
	.CEA3   (w_CEM__dsp48_dat_out_dac0 ),  // input wire CEM   // active HIGH // for dsp
	.SCLR  (w_SCLR_dsp48_dat_out_dac0 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_dat_out_dac0 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_dat_out_dac0 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_dat_out_dac0 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_dat_out_dac0 )   // output wire [47 : 0] P
);

//assign      w_CE___dsp48_dat_out_dac0 = (r_state_dsp48__dac0 == STATE_SIG_1)? 1'b1 : 1'b0;
//assign      w_SCLR_dsp48_dat_out_dac0 = (r_state_dsp48__dac0 == STATE_SIG_0)? 1'b1 : 1'b0;
//assign      w_SEL__dsp48_dat_out_dac0 = (w_cnt_dur_dac0 == 0)? 1'b1 : 1'b0; // load control 
//assign      w_A____dsp48_dat_out_dac0 = w_fcid_dat_inc_dac0; // inc by A
//assign      w_C____dsp48_dat_out_dac0 = {{16{w_fcid_dat_out_dac0[15]}},{w_fcid_dat_out_dac0}}; // load by C // sign ext

assign      w_CEP__dsp48_dat_out_dac0 = (r_state_dsp48__dac0 == STATE_EVEN_SEQ)? 1'b1 ://$$ (r_state_dsp48__dac0 == STATE_SIG_1)? 1'b1 :
                                        (r_state_dsp48__dac0 == STATE_ODD__SEQ)? 1'b1 ://$$ (r_state_dsp48__dac0 == STATE_SIG_2)? 1'b1 :
                                        (w_rise_cid_ff_pulse_run_dac0      )? 1'b1 :
                                                                              1'b0 ;
assign      w_CEM__dsp48_dat_out_dac0 = ((r_state_dsp48__dac0 == STATE_EVEN_SEQ || r_state_dsp48__dac0 == STATE_ODD__SEQ) && (w_cnt_dur_dac0 == 0) )? 1'b1 :
                                         (w_rise_cid_ff_pulse_run_dac0                                 )? 1'b1 :
                                                                                                          1'b0 ;
assign      w_SCLR_dsp48_dat_out_dac0 = ((r_state_dsp48__dac0 == STATE_IDLE) && (!w_rise_cid_ff_pulse_run_dac0))? 1'b1 : 1'b0;
assign      w_SEL__dsp48_dat_out_dac0 = ((r_state_dsp48__dac0 == STATE_EVEN_SEQ || r_state_dsp48__dac0 == STATE_ODD__SEQ) && (w_cnt_dur_dac0 == 0) )? 1'b1 :
                                         (w_rise_cid_ff_pulse_run_dac0                                 )? 1'b1 :
                                                                                                          1'b0 ;
assign      w_A____dsp48_dat_out_dac0 = w_fcid_dat_inc_dac0; // inc by A
assign      w_C____dsp48_dat_out_dac0 = {{16{w_fcid_dat_out_dac0[15]}},{w_fcid_dat_out_dac0}}; // load by C // sign ext


//}

// TODO: update state for dac0 
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		r_state_dsp48__dac0 <= STATE_IDLE;
		flag_repeat_pattern__dac0 <= 1'b0; //$$ repeat condition flag
	end
	else case (r_state_dsp48__dac0)
	
	STATE_IDLE : begin //$$ idle state
		flag_repeat_pattern__dac0 <= 1'b0;
		if (w_rise_cid_ff_pulse_run_dac0) begin 
			r_state_dsp48__dac0 <= STATE_EVEN_SEQ; //$$ STATE_SIG_1;
			end
		end
		
	STATE_EVEN_SEQ : begin //$$ even sequence  //$$ STATE_SIG_1 : begin //$$ pulse out state
		if ((w_cnt_idx_dac0 == r_cid_reg_dac0_num_ffdat - 1) && (w_cnt_dur_dac0 == 0)) begin
			flag_repeat_pattern__dac0 <= 1'b1; //$$ r_state_dsp48__dac0 <= STATE_SIG_2;
			if (w_cnt_rpt_dac0 >= r_cid_reg_dac0_num_repeat - 1) begin
				r_state_dsp48__dac0 <= STATE_FIN__SEQ;
				end 
			else begin 
				r_state_dsp48__dac0 <= STATE_ODD__SEQ;
				end
			end
		else if (w_hold_pulse_dac0|(~flag_cid_ff_pulse_run_dac0[1])) begin // pulse stop by user command
			flag_repeat_pattern__dac0 <= 1'b0;
			r_state_dsp48__dac0 <= STATE_IDLE;
			end
		else begin
			flag_repeat_pattern__dac0 <= 1'b0;
			end
		end
		
	STATE_ODD__SEQ : begin //$$ even sequence  //$$ STATE_SIG_1 : begin //$$ pulse out state
		if ((w_cnt_idx_dac0 == r_cid_reg_dac0_num_ffdat - 1) && (w_cnt_dur_dac0 == 0)) begin
			flag_repeat_pattern__dac0 <= 1'b1; //$$ r_state_dsp48__dac0 <= STATE_SIG_2;
			if (w_cnt_rpt_dac0 >= r_cid_reg_dac0_num_repeat - 1) begin
				r_state_dsp48__dac0 <= STATE_FIN__SEQ;
				end 
			else begin 
				r_state_dsp48__dac0 <= STATE_EVEN_SEQ;
				end
			end
		else if (w_hold_pulse_dac0|(~flag_cid_ff_pulse_run_dac0[1])) begin // pulse stop by user command
			flag_repeat_pattern__dac0 <= 1'b0;
			r_state_dsp48__dac0 <= STATE_IDLE;
			end
		else begin
			flag_repeat_pattern__dac0 <= 1'b0;
			end
		end

	//$$STATE_SIG_2 : begin //$$ repeat start state //$$ removed
	//$$	if (w_cnt_rpt_dac0 >= r_cid_reg_dac0_num_repeat - 1) begin
	//$$		r_state_dsp48__dac0 <= STATE_SIG_3;
	//$$		end
	//$$	else begin
	//$$		r_state_dsp48__dac0 <= STATE_SIG_1;
	//$$		end
	//$$	end
		
	STATE_FIN__SEQ : begin //$$ finish state
		flag_repeat_pattern__dac0 <= 1'b0;
		r_state_dsp48__dac0 <= STATE_IDLE;
		end
				
	default: begin 
		r_state_dsp48__dac0 <= STATE_IDLE;
		end
	
	endcase
end

// update  other reg for dac0: 
//   flag_fcid_pulse_active_dac0
//   flag_cid_ff_pulse_run_dac0
//   w_rise_cid_ff_pulse_run_dac0
//   w_enable_dac0_pulse_out_fifo
// 
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
	if (!i_rstn_dac0_dco) begin 
		flag_fcid_pulse_active_dac0   <=   1'b0;
		//flag_cid_ff_pulse_run_dac0    <=   4'b0;
		flag_cid_ff_pulse_run_dac0    <=   2'b0;
	end
	else begin
		// sampling 
		//flag_cid_ff_pulse_run_dac0   <=  {flag_cid_ff_pulse_run_dac0[2:0], w_enable_dac0_pulse_out_fifo};
		flag_cid_ff_pulse_run_dac0   <=  {flag_cid_ff_pulse_run_dac0[0], w_enable_dac0_pulse_out_fifo};
		
		// detect rise
		if (w_rise_cid_ff_pulse_run_dac0) begin
			flag_fcid_pulse_active_dac0   <=   1'b1; // set active 
		end
		else if (flag_fcid_pulse_active_dac0) begin
			//
			if (!flag_cid_ff_pulse_run_dac0[0]) begin // pulse off
				flag_fcid_pulse_active_dac0   <=   1'b0; // reset active
			end
		end 
	end 
end

//}


////// TODO: dsp for dac1  //{

// dsp macro wires //{
wire          w_CE___dsp48_cnt_idx_dac1 ;
wire          w_SCLR_dsp48_cnt_idx_dac1 ;
wire          w_SEL__dsp48_cnt_idx_dac1 ;
wire [15 : 0] w_A____dsp48_cnt_idx_dac1 ;
wire [31 : 0] w_C____dsp48_cnt_idx_dac1 ;
wire [47 : 0] w_P____dsp48_cnt_idx_dac1 ;
wire [15 : 0]            w_cnt_idx_dac1 = w_P____dsp48_cnt_idx_dac1[15:0];
//
wire          w_CE___dsp48_cnt_dur_dac1 ;
wire          w_SCLR_dsp48_cnt_dur_dac1 ;
wire          w_SEL__dsp48_cnt_dur_dac1 ;
wire [15 : 0] w_A____dsp48_cnt_dur_dac1 ;
wire [31 : 0] w_C____dsp48_cnt_dur_dac1 ;
wire [47 : 0] w_P____dsp48_cnt_dur_dac1 ;
//$$wire [31 : 0]        w_cnt_dur_dac1 = w_P____dsp48_cnt_dur_dac1[31:0]; // 32b
//$$wire [23 : 0]        w_cnt_dur_dac1 = w_P____dsp48_cnt_dur_dac1[23:0]; // 24b
//
wire          w_CE___cnt32b_cnt_dur_dac1 ;
wire          w_SCLR_cnt32b_cnt_dur_dac1 ;
wire          w_LOAD_cnt32b_cnt_dur_dac1 ;
wire [31 : 0] w_L____cnt32b_cnt_dur_dac1 ;
wire [31 : 0] w_Q____cnt32b_cnt_dur_dac1 ;
wire [31 : 0]             w_cnt_dur_dac1 = w_Q____cnt32b_cnt_dur_dac1[31:0]; // 32b
//
wire          w_CE___dsp48_cnt_rpt_dac1 ;
wire          w_SCLR_dsp48_cnt_rpt_dac1 ;
wire          w_SEL__dsp48_cnt_rpt_dac1 ;
wire [15 : 0] w_A____dsp48_cnt_rpt_dac1 ;
wire [31 : 0] w_C____dsp48_cnt_rpt_dac1 ;
wire [47 : 0] w_P____dsp48_cnt_rpt_dac1 ;
wire [15 : 0]            w_cnt_rpt_dac1 = w_P____dsp48_cnt_rpt_dac1[15:0];
//
//wire          w_CE___dsp48_dat_out_dac1 ;
wire          w_CEP___dsp48_dat_out_dac1 ;
wire          w_CEM___dsp48_dat_out_dac1 ;
wire          w_SCLR_dsp48_dat_out_dac1 ;
wire          w_SEL__dsp48_dat_out_dac1 ;
wire [15 : 0] w_A____dsp48_dat_out_dac1 ;
wire [31 : 0] w_C____dsp48_dat_out_dac1 ;
wire [47 : 0] w_P____dsp48_dat_out_dac1 ;
wire [15 : 0]            w_dat_out_dac1 = w_P____dsp48_dat_out_dac1[15:0]; //$$ to come with sign correction or overflow
		   // w_P____dsp48_dat_out_dac1[47:0] > 0x_0000_0000_7FFF
		   // w_P____dsp48_dat_out_dac1[47:0] < 0x_FFFF_FFFF_8000

//}


// control state for dsp48
reg  [3:0] r_state_dsp48__dac1;
reg  [3:0] r_state_dsp48__dac1__smp;

// related var:
//  w_rise_cid_ff_pulse_run_dac1
//  r_cid_reg_dac1_num_ffdat
//  r_cid_reg_dac1_num_repeat
//  w_fcid_cnt_dur_dac1
//  w_fcid_dat_out_dac1
//  w_fcid_dat_inc_dac1

// fifo data load //{
assign w_fcid_data_load_dac1     = ((r_state_dsp48__dac1 == STATE_EVEN_SEQ || r_state_dsp48__dac1 == STATE_ODD__SEQ) && (w_cnt_dur_dac1 == 0))? 1'b1 : 
                                   (w_rise_cid_ff_pulse_run_dac1                                 )? 1'b1 : 
                                                                                                    1'b0 ;
//}

// dac output latency //{
reg [15:0] r_dat_out_dac1;
reg [15:0] r_dat_out_dac1__smp;
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_dat_out_dac1            <=  16'b0;
		r_dat_out_dac1__smp       <=  16'b0;
		r_state_dsp48__dac1__smp  <=   4'b0;
	end
	else begin
		// sampling 
		r_dat_out_dac1__smp       <=  w_dat_out_dac1;
		r_state_dsp48__dac1__smp  <=  r_state_dsp48__dac1;
		
		// detect proper output 
		//$$ if (r_state_dsp48__dac1__smp == STATE_SIG_2) begin
		//$$ 	r_dat_out_dac1   <=   16'b0;
		//$$ 	end
		//$$ else if (r_state_dsp48__dac1 == STATE_SIG_1) begin
		//$$ 	r_dat_out_dac1   <=   r_dat_out_dac1__smp;
		//$$ 	end
		//$$ else if (r_state_dsp48__dac1 == STATE_SIG_2) begin
		//$$ 	r_dat_out_dac1   <=   r_dat_out_dac1__smp; 
		//$$ 	end
		if      (r_state_dsp48__dac1      == STATE_FIN__SEQ) begin
			r_dat_out_dac1   <=   16'b0; // pulse out finished
			end
		else if (r_state_dsp48__dac1__smp == STATE_EVEN_SEQ) begin
			r_dat_out_dac1   <=   r_dat_out_dac1__smp;
			end
		else if (r_state_dsp48__dac1__smp == STATE_ODD__SEQ) begin
			r_dat_out_dac1   <=   r_dat_out_dac1__smp; 
			end
		else begin
			r_dat_out_dac1   <=   16'b0;
		end 
	end 
end
//}


// for w_cnt_idx_dac1 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_idx_dac1__inst (
reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_idx_dac1__inst (
	.CLK   (i_clk_dac1_dco            ),  // input wire CLK   //
	.CE    (w_CE___dsp48_cnt_idx_dac1 ),  // input wire CE    // active HIGH
	.SCLR  (w_SCLR_dsp48_cnt_idx_dac1 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_cnt_idx_dac1 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_cnt_idx_dac1 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_cnt_idx_dac1 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_cnt_idx_dac1 )   // output wire [47 : 0] P
);

assign w_CE___dsp48_cnt_idx_dac1 = ((r_state_dsp48__dac1 == STATE_EVEN_SEQ || r_state_dsp48__dac1 == STATE_ODD__SEQ) && (w_cnt_dur_dac1 == 0))? 1'b1 : 1'b0;
assign w_SCLR_dsp48_cnt_idx_dac1 =  (r_state_dsp48__dac1 == STATE_IDLE)? 1'b1 : 
								     ((w_cnt_idx_dac1 == r_cid_reg_dac1_num_ffdat - 1) && (w_cnt_dur_dac1 == 0))? 1'b1 : 
								     //$$ (flag_repeat_pattern__dac1)? 1'b1 : // 1 clock delay NG //$$ (r_state_dsp48__dac1 == STATE_SIG_2)? 1'b1 : 
								     1'b0;
assign w_SEL__dsp48_cnt_idx_dac1 = 1'b0;
assign w_A____dsp48_cnt_idx_dac1 = 16'd1; // inc by 1
assign w_C____dsp48_cnt_idx_dac1 = 32'b0; // NA

//}

// for w_cnt_dur_dac1 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_dur_dac1__inst (  // use dsp
//  reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_dur_dac1__inst (
//  	.CLK   (i_clk_dac1_dco            ),  // input wire CLK   //
//  	.CE    (w_CE___dsp48_cnt_dur_dac1 ),  // input wire CE    // active HIGH
//  	.SCLR  (w_SCLR_dsp48_cnt_dur_dac1 ),  // input wire SCLR  // active high
//  	.SEL   (w_SEL__dsp48_cnt_dur_dac1 ),  // input wire [0 : 0] SEL
//  	.A     (w_A____dsp48_cnt_dur_dac1 ),  // input wire  [15 : 0] A
//  	.C     (w_C____dsp48_cnt_dur_dac1 ),  // input wire  [31 : 0] C
//  	.P     (w_P____dsp48_cnt_dur_dac1 )   // output wire [47 : 0] P
//  );
//  
//  assign w_CE___dsp48_cnt_dur_dac1 = (r_state_dsp48__dac1 == STATE_SIG_1)? 1'b1 : 
//  								   (r_state_dsp48__dac1 == STATE_SIG_2)? 1'b1 : 
//  								   (w_rise_cid_ff_pulse_run_dac1      )? 1'b1 : 
//  								    1'b0;
//  assign w_SCLR_dsp48_cnt_dur_dac1 = 1'b0; // (r_state_dsp48__dac1 == STATE_SIG_0)? 1'b1 : 1'b0;
//  assign w_SEL__dsp48_cnt_dur_dac1 = (w_cnt_dur_dac1 == 0)? 1'b1 : 1'b0; // load control // w_cnt_dur_dac1 == 0
//  assign w_A____dsp48_cnt_dur_dac1 = -16'd1; // inc by -1
//  assign w_C____dsp48_cnt_dur_dac1 = w_fcid_cnt_dur_dac1; // load from fifos

//c_counter_binary_down_b32_dsp_0            dsp48__AP_C__r_fcid_cnt_dur_dac1__inst (
reg_rep__c_counter_binary_down_b32_dsp_0 dsp48__AP_C__r_fcid_cnt_dur_dac1__inst (
	.CLK       (i_clk_dac1_dco),    // input wire CLK
	.CE        (w_CE___cnt32b_cnt_dur_dac1 ),  // input wire CE
	.SCLR      (w_SCLR_cnt32b_cnt_dur_dac1 ),  // input wire SCLR
	.LOAD      (w_LOAD_cnt32b_cnt_dur_dac1 ),  // input wire LOAD
	.L         (w_L____cnt32b_cnt_dur_dac1 ),  // input wire [31 : 0] L
	.Q         (w_Q____cnt32b_cnt_dur_dac1 )   // output wire [31 : 0] Q
);

assign w_CE___cnt32b_cnt_dur_dac1 = (r_state_dsp48__dac1 == STATE_EVEN_SEQ)? 1'b1 ://$$ (r_state_dsp48__dac1 == STATE_SIG_1)? 1'b1 : 
                                    (r_state_dsp48__dac1 == STATE_ODD__SEQ)? 1'b1 ://$$ (r_state_dsp48__dac1 == STATE_SIG_2)? 1'b1 : 
                                    (w_rise_cid_ff_pulse_run_dac1      )? 1'b1 : 
                                                                          1'b0 ;
assign w_SCLR_cnt32b_cnt_dur_dac1 =  1'b0;
assign w_LOAD_cnt32b_cnt_dur_dac1 = (r_state_dsp48__dac1 == STATE_IDLE)? 1'b1 : 
                                    (     w_cnt_dur_dac1 == 0          )? 1'b1 : 
                                                                          1'b0 ; 
assign w_L____cnt32b_cnt_dur_dac1 = w_fcid_cnt_dur_dac1;

//}

// for w_cnt_rpt_dac1 //{

// note: [P=A+P, P=C]
//xbip_dsp48_macro_APC_b32_0        dsp48__AP_C__r_fcid_cnt_rpt_dac1__inst (
reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_cnt_rpt_dac1__inst (
	.CLK   (i_clk_dac1_dco            ),  // input wire CLK   //
	.CE    (w_CE___dsp48_cnt_rpt_dac1 ),  // input wire CE    // active HIGH
	.SCLR  (w_SCLR_dsp48_cnt_rpt_dac1 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_cnt_rpt_dac1 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_cnt_rpt_dac1 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_cnt_rpt_dac1 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_cnt_rpt_dac1 )   // output wire [47 : 0] P
);

assign      w_CE___dsp48_cnt_rpt_dac1 = (flag_repeat_pattern__dac1)? 1'b1 : 1'b0; //$$ (r_state_dsp48__dac1 == STATE_SIG_2)? 1'b1 : 1'b0;
assign      w_SCLR_dsp48_cnt_rpt_dac1 = (r_state_dsp48__dac1 == STATE_IDLE)? 1'b1 : 1'b0;
assign      w_SEL__dsp48_cnt_rpt_dac1 = 1'b0;
assign      w_A____dsp48_cnt_rpt_dac1 = 16'd1; // inc by 1
assign      w_C____dsp48_cnt_rpt_dac1 = 32'b0; // NA
//}

// for w_dat_out_dac1 //{

// note: [P=A+P, P=C]
//  reg_rep__dsp48_macro_APC_b32_0  dsp48__AP_C__r_fcid_dat_out_dac1__inst (
//  	.CLK   (i_clk_dac1_dco            ),  // input wire CLK   //
//  	.CE    (w_CE___dsp48_dat_out_dac1 ),  // input wire CE    // active HIGH
//  	.SCLR  (w_SCLR_dsp48_dat_out_dac1 ),  // input wire SCLR  // active high
//  	.SEL   (w_SEL__dsp48_dat_out_dac1 ),  // input wire [0 : 0] SEL
//  	.A     (w_A____dsp48_dat_out_dac1 ),  // input wire  [15 : 0] A
//  	.C     (w_C____dsp48_dat_out_dac1 ),  // input wire  [31 : 0] C
//  	.P     (w_P____dsp48_dat_out_dac1 )   // output wire [47 : 0] P
//  );

//xbip_dsp48_macro_APC_b32_ce_ctl_0        dsp48__AP_C__r_fcid_dat_out_dac1__inst (
reg_rep__dsp48_macro_APC_b32_ce_ctl_0  dsp48__AP_C__r_fcid_dat_out_dac1__inst (
	.CLK   (i_clk_dac1_dco            ),  // input wire CLK   
	.CEP   (w_CEP__dsp48_dat_out_dac1 ),  // input wire CEP   // active HIGH
	//.CEM   (w_CEM__dsp48_dat_out_dac1 ),  // input wire CEM   // active HIGH
	.CEA3   (w_CEM__dsp48_dat_out_dac1 ),  // input wire CEM   // active HIGH // for dsp
	.SCLR  (w_SCLR_dsp48_dat_out_dac1 ),  // input wire SCLR  // active high
	.SEL   (w_SEL__dsp48_dat_out_dac1 ),  // input wire [0 : 0] SEL
	.A     (w_A____dsp48_dat_out_dac1 ),  // input wire  [15 : 0] A
	.C     (w_C____dsp48_dat_out_dac1 ),  // input wire  [31 : 0] C
	.P     (w_P____dsp48_dat_out_dac1 )   // output wire [47 : 0] P
);

//assign      w_CE___dsp48_dat_out_dac1 = (r_state_dsp48__dac1 == STATE_SIG_1)? 1'b1 : 1'b0;
//assign      w_SCLR_dsp48_dat_out_dac1 = (r_state_dsp48__dac1 == STATE_SIG_0)? 1'b1 : 1'b0;
//assign      w_SEL__dsp48_dat_out_dac1 = (w_cnt_dur_dac1 == 0)? 1'b1 : 1'b0; // load control 
//assign      w_A____dsp48_dat_out_dac1 = w_fcid_dat_inc_dac1; // inc by A
//assign      w_C____dsp48_dat_out_dac1 = {{16{w_fcid_dat_out_dac1[15]}},{w_fcid_dat_out_dac1}}; // load by C // sign ext

assign      w_CEP__dsp48_dat_out_dac1 = (r_state_dsp48__dac1 == STATE_EVEN_SEQ)? 1'b1 ://$$ (r_state_dsp48__dac1 == STATE_SIG_1)? 1'b1 :
                                        (r_state_dsp48__dac1 == STATE_ODD__SEQ)? 1'b1 ://$$ (r_state_dsp48__dac1 == STATE_SIG_2)? 1'b1 :
                                        (w_rise_cid_ff_pulse_run_dac1      )? 1'b1 :
                                                                              1'b0 ;
assign      w_CEM__dsp48_dat_out_dac1 = ((r_state_dsp48__dac1 == STATE_EVEN_SEQ || r_state_dsp48__dac1 == STATE_ODD__SEQ) && (w_cnt_dur_dac1 == 0) )? 1'b1 :
                                         (w_rise_cid_ff_pulse_run_dac1                                 )? 1'b1 :
                                                                                                          1'b0 ;
assign      w_SCLR_dsp48_dat_out_dac1 = ((r_state_dsp48__dac1 == STATE_IDLE) && (!w_rise_cid_ff_pulse_run_dac1))? 1'b1 : 1'b0;
assign      w_SEL__dsp48_dat_out_dac1 = ((r_state_dsp48__dac1 == STATE_EVEN_SEQ || r_state_dsp48__dac1 == STATE_ODD__SEQ) && (w_cnt_dur_dac1 == 0) )? 1'b1 :
                                         (w_rise_cid_ff_pulse_run_dac1                                 )? 1'b1 :
                                                                                                          1'b0 ;
assign      w_A____dsp48_dat_out_dac1 = w_fcid_dat_inc_dac1; // inc by A
assign      w_C____dsp48_dat_out_dac1 = {{16{w_fcid_dat_out_dac1[15]}},{w_fcid_dat_out_dac1}}; // load by C // sign ext


//}

// TODO: update state for dac1 
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		r_state_dsp48__dac1 <= STATE_IDLE;
		flag_repeat_pattern__dac1 <= 1'b0; //$$ repeat condition flag
	end
	else case (r_state_dsp48__dac1)
	
	STATE_IDLE : begin //$$ idle state
		flag_repeat_pattern__dac1 <= 1'b0;
		if (w_rise_cid_ff_pulse_run_dac1) begin 
			r_state_dsp48__dac1 <= STATE_EVEN_SEQ; //$$ STATE_SIG_1;
			end
		end
		
	STATE_EVEN_SEQ : begin //$$ even sequence  //$$ STATE_SIG_1 : begin //$$ pulse out state
		if ((w_cnt_idx_dac1 == r_cid_reg_dac1_num_ffdat - 1) && (w_cnt_dur_dac1 == 0)) begin
			flag_repeat_pattern__dac1 <= 1'b1; //$$ r_state_dsp48__dac1 <= STATE_SIG_2;
			if (w_cnt_rpt_dac1 >= r_cid_reg_dac1_num_repeat - 1) begin
				r_state_dsp48__dac1 <= STATE_FIN__SEQ;
				end 
			else begin 
				r_state_dsp48__dac1 <= STATE_ODD__SEQ;
				end
			end
		else if (w_hold_pulse_dac1|(~flag_cid_ff_pulse_run_dac1[1])) begin // pulse stop by user command
			flag_repeat_pattern__dac1 <= 1'b0;
			r_state_dsp48__dac1 <= STATE_IDLE;
			end
		else begin
			flag_repeat_pattern__dac1 <= 1'b0;
			end
		end
		
	STATE_ODD__SEQ : begin //$$ even sequence  //$$ STATE_SIG_1 : begin //$$ pulse out state
		if ((w_cnt_idx_dac1 == r_cid_reg_dac1_num_ffdat - 1) && (w_cnt_dur_dac1 == 0)) begin
			flag_repeat_pattern__dac1 <= 1'b1; //$$ r_state_dsp48__dac1 <= STATE_SIG_2;
			if (w_cnt_rpt_dac1 >= r_cid_reg_dac1_num_repeat - 1) begin
				r_state_dsp48__dac1 <= STATE_FIN__SEQ;
				end 
			else begin 
				r_state_dsp48__dac1 <= STATE_EVEN_SEQ;
				end
			end
		else if (w_hold_pulse_dac1|(~flag_cid_ff_pulse_run_dac1[1])) begin // pulse stop by user command
			flag_repeat_pattern__dac1 <= 1'b0;
			r_state_dsp48__dac1 <= STATE_IDLE;
			end
		else begin
			flag_repeat_pattern__dac1 <= 1'b0;
			end
		end

	//$$STATE_SIG_2 : begin //$$ repeat start state //$$ removed
	//$$	if (w_cnt_rpt_dac1 >= r_cid_reg_dac1_num_repeat - 1) begin
	//$$		r_state_dsp48__dac1 <= STATE_SIG_3;
	//$$		end
	//$$	else begin
	//$$		r_state_dsp48__dac1 <= STATE_SIG_1;
	//$$		end
	//$$	end
		
	STATE_FIN__SEQ : begin //$$ finish state
		flag_repeat_pattern__dac1 <= 1'b0;
		r_state_dsp48__dac1 <= STATE_IDLE;
		end
				
	default: begin 
		r_state_dsp48__dac1 <= STATE_IDLE;
		end
	
	endcase
end

// update  other reg for dac1: 
//   flag_fcid_pulse_active_dac1
//   flag_cid_ff_pulse_run_dac1
//   w_rise_cid_ff_pulse_run_dac1
//   w_enable_dac1_pulse_out_fifo
// 
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
	if (!i_rstn_dac1_dco) begin 
		flag_fcid_pulse_active_dac1   <=   1'b0;
		//flag_cid_ff_pulse_run_dac1    <=   4'b0;
		flag_cid_ff_pulse_run_dac1    <=   2'b0;
	end
	else begin
		// sampling 
		//flag_cid_ff_pulse_run_dac1   <=  {flag_cid_ff_pulse_run_dac1[2:0], w_enable_dac1_pulse_out_fifo};
		flag_cid_ff_pulse_run_dac1   <=  {flag_cid_ff_pulse_run_dac1[0], w_enable_dac1_pulse_out_fifo};
		
		// detect rise
		if (w_rise_cid_ff_pulse_run_dac1) begin
			flag_fcid_pulse_active_dac1   <=   1'b1; // set active 
		end
		else if (flag_fcid_pulse_active_dac1) begin
			//
			if (!flag_cid_ff_pulse_run_dac1[0]) begin // pulse off
				flag_fcid_pulse_active_dac1   <=   1'b0; // reset active
			end
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

//// TODO: dac pin out selection  //{

// r_fcid_dat_out_dac0 --> w_dat_out_dac0 --> r_dat_out_dac1// for dsp
// r_fcid_dat_out_dac1 --> w_dat_out_dac1 --> r_dat_out_dac1// for dsp
wire [15:0] w_dac0_data_pin = (flag_cid_ff_pulse_run_dac0[0])? r_dat_out_dac0
						     :(flag_cid_sq_pulse_run_dac0[0])? r_cid_dat_out_dac0
						     : 16'b0;
						
wire [15:0] w_dac1_data_pin = (flag_cid_ff_pulse_run_dac1[0])? r_dat_out_dac1
						     :(flag_cid_sq_pulse_run_dac1[0])? r_cid_dat_out_dac1
						     : 16'b0;


//$$  // buffer for IOB out reg
//$$  reg [15:0] r_dac0_data_pin;
//$$  reg [15:0] r_dac1_data_pin;
//$$  
//$$  always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin 
//$$  	if (!i_rstn_dac0_dco) begin 
//$$  		r_dac0_data_pin   <=  16'b0;
//$$  	end
//$$  	else begin
//$$  		r_dac0_data_pin   <= w_dac0_data_pin;
//$$  	end
//$$  end
//$$  
//$$  always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin 
//$$  	if (!i_rstn_dac1_dco) begin 
//$$  		r_dac1_data_pin   <=  16'b0;
//$$  	end
//$$  	else begin
//$$  		r_dac1_data_pin   <= w_dac1_data_pin;
//$$  	end
//$$  end

// output
assign o_dac0_data_pin = w_dac0_data_pin;
assign o_dac1_data_pin = w_dac1_data_pin;
//$$  assign o_dac0_data_pin = r_dac0_data_pin;
//$$  assign o_dac1_data_pin = r_dac1_data_pin;

//}


//// TODO: fifo reloading switch //{
assign o_enable_dac0_fifo_reload = flag_fcid_pulse_active_dac0;
assign o_enable_dac1_fifo_reload = flag_fcid_pulse_active_dac1;

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
		r_dac0_active_clk <= flag_fcid_pulse_active_dac0 | flag_cid_pulse_active_dac0 ;
		r_dac1_active_clk <= flag_fcid_pulse_active_dac1 | flag_cid_pulse_active_dac1 ;
		//
	end

//
assign o_dac0_active_dco = flag_fcid_pulse_active_dac0 | flag_cid_pulse_active_dac0 ;
assign o_dac1_active_dco = flag_fcid_pulse_active_dac1 | flag_cid_pulse_active_dac1 ; 

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


//// repeat pattern (minimum?) period //{
// reserved?

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

