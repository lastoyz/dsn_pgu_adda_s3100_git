//------------------------------------------------------------------------
// dac_pattern_gen.v
// - objective 
// 		generate test data pattern for DAC AD9783 data ports 
//
// -doc 
//		ad9783
//			https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
//
// - clock/reset port 
// 		clk			
// 		reset_n		
// 		i_clk_dacx_ref 
// 		i_rstn_dacx_ref
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
//
// - pattern generation modes
//		single level toggle test (SLT test)
//			...
//		multi-level sequence test (MLS test)
//			...
//		duration controlled sequence test (DCS test)
//			fixed sequence length of 8
//			data format: (DAC code 16b + duration count 16b)
// 			each tick has max 2^16/(400MHz)=163.84 us duration @ 400MHz 
//				max period = 2^16/(400MHz)*8 = 1.31072 milliseconds
// 			each tick has max 2^16/(200MHz)=327.68 us duration @ 200MHz 
//				max period = 2^16/(200MHz)*8 = 2.62144 milliseconds
// 			each tick has max 2^16/(133.3MHz)=491.642911 us duration @ 133.3MHz 
//				max period = 2^16/(133.3MHz)*8 = 3.93314329 milliseconds
// 			each tick has max 2^16/(100MHz)=655.36 us duration @ 100MHz 
//				max period = 2^16/(100MHz)*8 = 5.24288 milliseconds
// 			each tick has max 2^16/(80MHz)=819.2 us duration @ 80MHz 
//				max period = 2^16/(80MHz)*8 = 6.5536 milliseconds
// 			each tick has max 2^16/(66.6MHz)=984.024024 us duration @ 66.6MHz 
//				max period = 2^16/(66.6MHz)*8 = 7.87219219 milliseconds
// 			each tick has max 2^16/(20MHz)=3.2768 milliseconds duration @ 20MHz 
//				max period = 2^16/(20MHz)*8 = 26.2144 milliseconds
//			...
//			slowest clock 400MHz/6/32= 2.08333333 MHz
// 			each tick has max 2^16/(400MHz/6/32)=31.45728 ms duration @ 2.08333333 MHz 
//				max period = 2^16/(400MHz/6/32)*8 = 0.25165824 seconds
//			...
//		fifo-based duration controlled test sequence (FDCS test) : use DCS format
//			fixed fifo depth of 2^16 vs 2^12
//			data format: (DAC code 16b + duration count 16b)
//			...
// 			each tick has max 2^16/(400MHz)=163.84 us duration @ 400MHz 
//				max period = 2^16/(400MHz)*2^16 = 10.7374182 seconds
//				max period = 2^16/(400MHz)*2^12 = 0.67108864 seconds
//			200MHz = 400MHz/(2+0)
// 			each tick has max 2^16/(200MHz)=327.68 us duration @ 200MHz 
//				max period = 2^16/(200MHz)*2^16 = 21.4748365 seconds
//				max period = 2^16/(200MHz)*2^12 = 1.34217728 seconds <<<
//			100MHz = 400MHz/(2+2)
// 			each tick has max 2^16/(100MHz)=655.36 us duration @ 100MHz 
//				max period = 2^16/(100MHz)*2^16 = 42.949673 seconds
//				max period = 2^16/(100MHz)*2^12 = 2.68435456 seconds <<<
//			66.6MHz = 400MHz/(2+4)
// 			each tick has max 2^16/(66.6MHz)=984.024024 us duration @ 66.6MHz 
//				max period = 2^16/(66.6MHz)*2^16 = 64.4889984 seconds
//				max period = 2^16/(66.6MHz)*2^12 = 4.0305624 seconds
//			20MHz = 400MHz/(2+3)/(2+1+1)
// 			each tick has max 2^16/(20MHz)=3.2768 milliseconds duration @ 20MHz 
//				max period = 2^16/(20MHz)*2^16 = 3.57913941 minutes
//				max period = 2^16/(20MHz)*2^12 = 13.4217728 seconds <<<<<<
//			5MHz = 400MHz/(2+3)/(2+7+7)
// 			each tick has max 2^16/(5MHz)=13.1072 milliseconds duration @ 5MHz 
//				max period = 2^16/(5MHz)*2^16 = 14.3165577 minutes
//				max period = 2^16/(5MHz)*2^12 = 53.6870912 seconds <<<<<<
//
//
// - SLT test timing 
//		... toggle style _----____----____
//
// - MLS test timing 
//		... sequence  
//		              __--  --__
//		                  --
//
// - DCS test timing 
//		... sequence  
//		              __--------    -----___________
//		                        ----
//
// - FDCS test timing 
//		...
//
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module dac_pattern_gen (  
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
	
	// DACX control port 
	input  wire [31:0] i_trig_dacx_ctrl, // 
	input  wire [31:0] i_wire_dacx_data, // 
	output wire [31:0] o_wire_dacx_data, // 
	
	// DAC data port 
	output wire [15:0] o_dac0_data_pin, // 
	output wire [15:0] o_dac1_data_pin, // 
	
	// DAC activity flag 
	output wire        o_dac0_active_dco,
	output wire        o_dac1_active_dco,
	output wire        o_dac0_active_clk,
	output wire        o_dac1_active_clk,
	
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
	
	//
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

//// incremental pattern 16 bit
// (* keep = "true" *)
// reg  [15:0] r_test_count0;
// //
// always @(posedge dac0_clk, negedge reset_n) begin
// 	if (!reset_n) begin 
// 		r_test_count0 <= 16'b0;
// 	end 
// 	else begin 
// 		r_test_count0 <= r_test_count0 + 16'd1;
// 	end
// end
// //
// //
// (* keep = "true" *)
// reg  [15:0] r_test_count1;
// //
// always @(posedge dac1_clk, negedge reset_n) begin
// 	if (!reset_n) begin 
// 		r_test_count1 <= 16'b0;
// 	end 
// 	else begin 
// 		r_test_count1 <= r_test_count1 + 16'd1;
// 	end
// end


//// SLT (single level test) //{
//
reg [31:0] r_slt_dacx;
//
wire w_slt_write_data  = i_trig_dacx_ctrl[0];
wire w_slt_read_data   = i_trig_dacx_ctrl[1];
wire w_slt_run_test    = 0; //test//i_trig_dacx_ctrl[2]; //$$
wire w_slt_stop_test   = i_trig_dacx_ctrl[3];
//
reg flag_slt_run;
//
reg [15:0] r_slt_dac0;
reg [15:0] r_slt_dac1;
//
reg flag_run_dac0;
reg flag_run_dac1;
reg flag_toggle_dac0;
reg flag_toggle_dac1;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_slt_dacx   <= 32'b0;
	end
	else begin 
		// write data 
		if (w_slt_write_data) 
			r_slt_dacx   <= i_wire_dacx_data; 
	end
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		flag_slt_run   <= 1'b0;
	end
	else begin 
		// set flag
		if (w_slt_run_test) 
			flag_slt_run   <= 1'b1;
		else if (w_slt_stop_test)
			flag_slt_run   <= 1'b0;
	end
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin
	if (!i_rstn_dac0_dco) begin 
		r_slt_dac0      <= 16'b0;
		flag_run_dac0    <= 1'b0;
		flag_toggle_dac0 <= 1'b0;
	end 
	else begin 
		flag_run_dac0 <= 1'b1;
		if (flag_slt_run & flag_run_dac0 & flag_run_dac1) begin
			flag_toggle_dac0 <= ~flag_toggle_dac0;
			r_slt_dac0      <= (flag_toggle_dac0)? r_slt_dacx[15: 0] : 16'b0;
		end
		else begin 
			flag_toggle_dac0 <= 1'b0;
			r_slt_dac0      <= 16'b0;
		end 
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin
	if (!i_rstn_dac1_dco) begin 
		r_slt_dac1 <= 16'b0;
		flag_run_dac1 <= 1'b0;
		flag_toggle_dac1 <= 1'b0;
	end 
	else begin 
		flag_run_dac1 <= 1'b1;
		if (flag_slt_run & flag_run_dac1 & flag_run_dac0) begin
			flag_toggle_dac1 <= ~flag_toggle_dac1;
			r_slt_dac1      <= (flag_toggle_dac1)? r_slt_dacx[31:16] : 16'b0;
		end
		else begin 
			flag_toggle_dac1 <= 1'b0;
			r_slt_dac1      <= 16'b0;
		end 
	end
end
//
//}

//---------------------------------------------------------------//

//// MLS (Multi-level sequence) //{
// fixed length of 4 // rev with 8
reg [31:0] r_mls_dacx_data_seq_0;
reg [31:0] r_mls_dacx_data_seq_1;
reg [31:0] r_mls_dacx_data_seq_2;
reg [31:0] r_mls_dacx_data_seq_3;
reg [31:0] r_mls_dacx_data_seq_4;
reg [31:0] r_mls_dacx_data_seq_5;
reg [31:0] r_mls_dacx_data_seq_6;
reg [31:0] r_mls_dacx_data_seq_7;
reg  [2:0] r_mls_dacx_adrs;  
//
wire w_mls_write_adrs  = i_trig_dacx_ctrl[8];
wire w_mls_read_adrs   = i_trig_dacx_ctrl[9];
wire w_mls_write_data  = i_trig_dacx_ctrl[10];
wire w_mls_read_data   = i_trig_dacx_ctrl[11];
wire w_mls_run_test    = 0; //test//i_trig_dacx_ctrl[12]; //$$
wire w_mls_stop_test   = i_trig_dacx_ctrl[13];
//
reg flag_mls_run;
//
reg [15:0] r_mls_dac0;
reg [15:0] r_mls_dac1;
//
reg [2:0] r_cnt_adrs_dac0;  
reg [2:0] r_cnt_adrs_dac1;  
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_mls_dacx_adrs   <= 3'b0;  
	end
	else begin 
		if (w_mls_write_adrs) 
			r_mls_dacx_adrs   <= i_wire_dacx_data[2:0];  
	end
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_mls_dacx_data_seq_0   <= 32'b0;
		r_mls_dacx_data_seq_1   <= 32'b0;
		r_mls_dacx_data_seq_2   <= 32'b0;
		r_mls_dacx_data_seq_3   <= 32'b0;
		r_mls_dacx_data_seq_4   <= 32'b0;
		r_mls_dacx_data_seq_5   <= 32'b0;
		r_mls_dacx_data_seq_6   <= 32'b0;
		r_mls_dacx_data_seq_7   <= 32'b0;
	end
	else begin 
		if (w_mls_write_data) begin
			r_mls_dacx_data_seq_0   <= (r_mls_dacx_adrs==3'b000)? i_wire_dacx_data : r_mls_dacx_data_seq_0;
			r_mls_dacx_data_seq_1   <= (r_mls_dacx_adrs==3'b001)? i_wire_dacx_data : r_mls_dacx_data_seq_1;
			r_mls_dacx_data_seq_2   <= (r_mls_dacx_adrs==3'b010)? i_wire_dacx_data : r_mls_dacx_data_seq_2;
			r_mls_dacx_data_seq_3   <= (r_mls_dacx_adrs==3'b011)? i_wire_dacx_data : r_mls_dacx_data_seq_3;
			r_mls_dacx_data_seq_4   <= (r_mls_dacx_adrs==3'b100)? i_wire_dacx_data : r_mls_dacx_data_seq_4;
			r_mls_dacx_data_seq_5   <= (r_mls_dacx_adrs==3'b101)? i_wire_dacx_data : r_mls_dacx_data_seq_5;
			r_mls_dacx_data_seq_6   <= (r_mls_dacx_adrs==3'b110)? i_wire_dacx_data : r_mls_dacx_data_seq_6;
			r_mls_dacx_data_seq_7   <= (r_mls_dacx_adrs==3'b111)? i_wire_dacx_data : r_mls_dacx_data_seq_7;
		end
	end
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		flag_mls_run   <= 1'b0;
	end
	else begin 
		// set flag
		if (w_mls_run_test) 
			flag_mls_run   <= 1'b1;
		else if (w_mls_stop_test)
			flag_mls_run   <= 1'b0;
	end
//
always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco) begin
	if (!i_rstn_dac0_dco) begin 
		r_mls_dac0      <= 16'b0;
		r_cnt_adrs_dac0 <=  3'b0;  
	end 
	else begin 
		if (flag_mls_run) begin
			r_mls_dac0      <= (r_cnt_adrs_dac0==3'b000)? r_mls_dacx_data_seq_0[15: 0] :
			                   (r_cnt_adrs_dac0==3'b001)? r_mls_dacx_data_seq_1[15: 0] :
			                   (r_cnt_adrs_dac0==3'b010)? r_mls_dacx_data_seq_2[15: 0] :
			                   (r_cnt_adrs_dac0==3'b011)? r_mls_dacx_data_seq_3[15: 0] :
			                   (r_cnt_adrs_dac0==3'b100)? r_mls_dacx_data_seq_4[15: 0] :
			                   (r_cnt_adrs_dac0==3'b101)? r_mls_dacx_data_seq_5[15: 0] :
			                   (r_cnt_adrs_dac0==3'b110)? r_mls_dacx_data_seq_6[15: 0] :
			                                              r_mls_dacx_data_seq_7[15: 0] ;
			r_cnt_adrs_dac0 <= r_cnt_adrs_dac0 + 1;
		end
		else begin 
			r_mls_dac0      <= 16'b0;
			r_cnt_adrs_dac0 <=  3'b0;  
		end 
	end
end
//
always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco) begin
	if (!i_rstn_dac1_dco) begin 
		r_mls_dac1      <= 16'b0;
		r_cnt_adrs_dac1 <=  3'b0;  
	end 
	else begin 
		if (flag_mls_run) begin
			r_mls_dac1      <= (r_cnt_adrs_dac1==3'b000)? r_mls_dacx_data_seq_0[31:16] :
			                   (r_cnt_adrs_dac1==3'b001)? r_mls_dacx_data_seq_1[31:16] :
			                   (r_cnt_adrs_dac1==3'b010)? r_mls_dacx_data_seq_2[31:16] :
			                   (r_cnt_adrs_dac1==3'b011)? r_mls_dacx_data_seq_3[31:16] :
			                   (r_cnt_adrs_dac1==3'b100)? r_mls_dacx_data_seq_4[31:16] :
			                   (r_cnt_adrs_dac1==3'b101)? r_mls_dacx_data_seq_5[31:16] :
			                   (r_cnt_adrs_dac1==3'b110)? r_mls_dacx_data_seq_6[31:16] :
			                                              r_mls_dacx_data_seq_7[31:16] ;
			r_cnt_adrs_dac1 <= r_cnt_adrs_dac1 + 1;
		end
		else begin 
			r_mls_dac1      <= 16'b0;
			r_cnt_adrs_dac1 <=  3'b0;  
		end 
	end
end
//
//}

//---------------------------------------------------------------//

//// DCS (duration controlled sequence)  //{
// fixed length of 8; (DAC code 16b + duration count 16b)
// setting: number of sequence repeat

//{ reg and wire
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
wire w_dcs_write_adrs       = i_trig_dacx_ctrl[16];
wire w_dcs_read_adrs        = i_trig_dacx_ctrl[17];
wire w_dcs_write_data_dac0  = i_trig_dacx_ctrl[18];
wire w_dcs_read_data_dac0   = i_trig_dacx_ctrl[19];
wire w_dcs_write_data_dac1  = i_trig_dacx_ctrl[20];
wire w_dcs_read_data_dac1   = i_trig_dacx_ctrl[21];
wire w_dcs_run_test         = i_trig_dacx_ctrl[22]; //$$
wire w_dcs_stop_test        = i_trig_dacx_ctrl[23];
wire w_dcs_write_repeat     = i_trig_dacx_ctrl[24]; // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
wire w_dcs_read_repeat      = i_trig_dacx_ctrl[25]; // 
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

//{ always and assign
always @(posedge clk, negedge reset_n) //{ r_dcs_dacx_adrs
	if (!reset_n) begin
		r_dcs_dacx_adrs   <= 3'b0;  
	end
	else begin 
		if (w_dcs_write_adrs) 
			r_dcs_dacx_adrs   <= i_wire_dacx_data[2:0];  
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
			r_dcs_dac0_data_seq_0   <= (r_dcs_dacx_adrs==3'b000)? i_wire_dacx_data : r_dcs_dac0_data_seq_0;
			r_dcs_dac0_data_seq_1   <= (r_dcs_dacx_adrs==3'b001)? i_wire_dacx_data : r_dcs_dac0_data_seq_1;
			r_dcs_dac0_data_seq_2   <= (r_dcs_dacx_adrs==3'b010)? i_wire_dacx_data : r_dcs_dac0_data_seq_2;
			r_dcs_dac0_data_seq_3   <= (r_dcs_dacx_adrs==3'b011)? i_wire_dacx_data : r_dcs_dac0_data_seq_3;
			r_dcs_dac0_data_seq_4   <= (r_dcs_dacx_adrs==3'b100)? i_wire_dacx_data : r_dcs_dac0_data_seq_4;
			r_dcs_dac0_data_seq_5   <= (r_dcs_dacx_adrs==3'b101)? i_wire_dacx_data : r_dcs_dac0_data_seq_5;
			r_dcs_dac0_data_seq_6   <= (r_dcs_dacx_adrs==3'b110)? i_wire_dacx_data : r_dcs_dac0_data_seq_6;
			r_dcs_dac0_data_seq_7   <= (r_dcs_dacx_adrs==3'b111)? i_wire_dacx_data : r_dcs_dac0_data_seq_7;
		end
		else if (w_dcs_write_data_dac1) begin
			r_dcs_dac1_data_seq_0   <= (r_dcs_dacx_adrs==3'b000)? i_wire_dacx_data : r_dcs_dac1_data_seq_0;
			r_dcs_dac1_data_seq_1   <= (r_dcs_dacx_adrs==3'b001)? i_wire_dacx_data : r_dcs_dac1_data_seq_1;
			r_dcs_dac1_data_seq_2   <= (r_dcs_dacx_adrs==3'b010)? i_wire_dacx_data : r_dcs_dac1_data_seq_2;
			r_dcs_dac1_data_seq_3   <= (r_dcs_dacx_adrs==3'b011)? i_wire_dacx_data : r_dcs_dac1_data_seq_3;
			r_dcs_dac1_data_seq_4   <= (r_dcs_dacx_adrs==3'b100)? i_wire_dacx_data : r_dcs_dac1_data_seq_4;
			r_dcs_dac1_data_seq_5   <= (r_dcs_dacx_adrs==3'b101)? i_wire_dacx_data : r_dcs_dac1_data_seq_5;
			r_dcs_dac1_data_seq_6   <= (r_dcs_dacx_adrs==3'b110)? i_wire_dacx_data : r_dcs_dac1_data_seq_6;
			r_dcs_dac1_data_seq_7   <= (r_dcs_dacx_adrs==3'b111)? i_wire_dacx_data : r_dcs_dac1_data_seq_7;
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
			r_dcs_repeat_dac0   <= i_wire_dacx_data[15: 0];
			r_dcs_repeat_dac1   <= i_wire_dacx_data[31:16];
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

//{ reg and wire:
//
reg r_fdcs_run;
//
wire w_fdcs_run_test         = i_trig_dacx_ctrl[28]; //$$
wire w_fdcs_stop_test        = i_trig_dacx_ctrl[29];
wire w_fdcs_write_repeat     = i_trig_dacx_ctrl[30];
wire w_fdcs_read_repeat      = i_trig_dacx_ctrl[31];
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

//{ always and assign:
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
			r_fdcs_repeat_dac0   <= i_wire_dacx_data[15: 0];
			r_fdcs_repeat_dac1   <= i_wire_dacx_data[31:16];
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

//// fifo assign and control //{

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

//// dac pin out selection  //{
assign o_dac0_data_pin = (flag_slt_run )? r_slt_dac0 
						:(flag_mls_run )? r_mls_dac0 
						:(r_dcs_run )? r_dcs_data_dac0
						:(r_fdcs_run)? r_fdcs_data_dac0
						: 16'b0;
assign o_dac1_data_pin = (flag_slt_run )? r_slt_dac1 
						:(flag_mls_run )? r_mls_dac1 
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
		r_dac0_active_clk <= flag_dcs_active_dac0 | flag_fdcs_active_dac0;
		r_dac1_active_clk <= flag_dcs_active_dac1 | flag_fdcs_active_dac1;
		//
	end

//
//assign o_dac0_active_dco = flag_dcs_active_dac0 | flag_fdcs_active_dac0;
assign o_dac0_active_dco = flag_dcs_active_dac0 | r_fdcs_active_dac0;
//assign o_dac1_active_dco = flag_dcs_active_dac1 | flag_fdcs_active_dac1;
assign o_dac1_active_dco = flag_dcs_active_dac1 | r_fdcs_active_dac1; 

//}


//// Status flag and controls //{

wire w_write_control = i_trig_dacx_ctrl[4]; //$$
wire w_read_status   = i_trig_dacx_ctrl[5]; //$$

// update control reg based on clk
reg [31:0] r_control_pulse;
//
always @(posedge clk, negedge reset_n) //{ r_repeat_period
	if (!reset_n) begin
		r_control_pulse   <= 32'b0;
	end
	else begin 
		if (w_write_control) begin
			r_control_pulse   <= i_wire_dacx_data;
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

wire w_write_repeat_period = i_trig_dacx_ctrl[6]; //$$
wire w_read_repeat_period  = i_trig_dacx_ctrl[7]; //$$

(* keep = "true" *) reg [31:0] r_repeat_period;
//
always @(posedge clk, negedge reset_n) //{ r_repeat_period
	if (!reset_n) begin
		r_repeat_period   <= 32'b0;
	end
	else begin 
		if (w_write_repeat_period) begin
			r_repeat_period   <= i_wire_dacx_data;
		end
	end
	
//}


//// o_wire_dacx_data  //{
reg [31:0]  r_wire_dacx_data;
assign o_wire_dacx_data = r_wire_dacx_data;
// read r_wire_dacx_data
always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_wire_dacx_data   <= 32'b0;
	end
	else begin 
		// 
		if      (w_slt_read_data) 
			r_wire_dacx_data   <= r_slt_dacx; 
		else if (w_mls_read_adrs)
			r_wire_dacx_data   <= {29'b0, r_mls_dacx_adrs};  
		else if (w_mls_read_data)
			r_wire_dacx_data   <= (r_mls_dacx_adrs==3'b000)? r_mls_dacx_data_seq_0 : 
								  (r_mls_dacx_adrs==3'b001)? r_mls_dacx_data_seq_1 :
								  (r_mls_dacx_adrs==3'b010)? r_mls_dacx_data_seq_2 :
								  (r_mls_dacx_adrs==3'b011)? r_mls_dacx_data_seq_3 : 
								  (r_mls_dacx_adrs==3'b100)? r_mls_dacx_data_seq_4 : 
								  (r_mls_dacx_adrs==3'b101)? r_mls_dacx_data_seq_5 :
								  (r_mls_dacx_adrs==3'b110)? r_mls_dacx_data_seq_6 :
								                             r_mls_dacx_data_seq_7 ; 
		//
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


