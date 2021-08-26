//------------------------------------------------------------------------
// test_model_adc_ddr_two_lane_LTC2387.v
//   test model for LTC2387-18 ADC DDR 2-wire output
//   	http://www.analog.com/media/en/technical-documentation/data-sheets/238718fa.pdf
//
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module test_model_adc_ddr_two_lane_LTC2387 (  
	input wire clk_logic, // 125MHz
	input wire reset_n,
	input wire en,
	//
	input wire test, // generate test pattern on dco_adc / dat1_adc / dat2_adc.
	output wire test_cnv_adc, // test generation of cnv_adc for test 
	output wire test_clk_adc, // test generation of clk_adc for test 
	output wire test_clk_reset_serdes, // test generation of clk_reset for serdes 
	output wire test_io_reset_serdes, // test generation of io_reset for serdes 
	output wire test_valid_fifo, // test generation of valid for fifo 
	//
	input wire i_cnv_adc, // trigger input for conversion 
	input wire i_clk_adc, // clock input for adc data ... connected to dco_adc
	//
	input wire test_mode_inc_data, // increasing data or fixed data
	//
	output wire dco_adc,
	output wire dat1_adc,
	output wire dat2_adc,
	// 
	output wire [7:0] debug_out
);

//
parameter DAT1_OUTPUT_POLARITY = 1'b1; // 1 for inversion
parameter DAT2_OUTPUT_POLARITY = 1'b0; // 1 for inversion
parameter DCLK_OUTPUT_POLARITY = 1'b1; // 1 for inversion
// 
parameter PERIOD_CLK_LOGIC_NS = 8; // ns
parameter PERIOD_CLK_CNV_NS = 96; // ns
//
// parameters for non-synthesizable // proper data delay included
//parameter DELAY_dco_adc = 2.5; // ns
//parameter DELAY_dat_adc = 6.5; // ns //$$ 2.5+4=6.5 vs 2.5
// parameters for non-synthesizable // no data delay included // external idelay required
parameter DELAY_dco_adc = 2.5; // ns
parameter DELAY_dat_adc = 2.5; // ns //$$ 2.5+4=6.5 vs 2.5
// for synthesizable code
//parameter DELAY_dco_adc = 0; // ns
//parameter DELAY_dat_adc = 0; // ns 

// test_cnv_adc
reg cnv_adc; // 
reg [31:0] sub_cnt_cnv;
//parameter PERIOD_CNV = 32'd12; // 10MHz ~ 100ns > 96ns = 8ns*12 @125MHz
parameter PERIOD_CNV = PERIOD_CLK_CNV_NS/PERIOD_CLK_LOGIC_NS; // period count of cnv
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		sub_cnt_cnv <= 32'd0;
		cnv_adc <= 1'b0;
		end 
	else if (en && test) begin
		if (sub_cnt_cnv == 0) begin // start of cnv
			sub_cnt_cnv <= PERIOD_CNV - 1;
			cnv_adc <= 1'b1;
			end
		else begin
			sub_cnt_cnv <= sub_cnt_cnv - 1;
			cnv_adc <= 1'b0;
			end
		end
	else begin 
		sub_cnt_cnv <= 32'd0;
		cnv_adc <= 1'b0;
		end
//
assign test_cnv_adc = cnv_adc; // test output 
////

//wire w_cnv_adc = (test)? cnv_adc  : i_cnv_adc;
wire w_cnv_adc = i_cnv_adc;
//

// test_clk_reset_serdes
reg r_clk_reset; // 
reg [31:0] r_sub_clk_reset;
parameter WIDTH_CLK_RESET_NS = 32'd50; // ns
parameter WIDTH_CLK_RESET = WIDTH_CLK_RESET_NS/PERIOD_CLK_LOGIC_NS; // period count of cnv
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_sub_clk_reset <= 32'd0;
		r_clk_reset <= 1'b0;
		end 
	else if (en && test) begin
		if (r_sub_clk_reset == 0) begin // start of r_clk_reset
			r_sub_clk_reset <= WIDTH_CLK_RESET;
			r_clk_reset <= 1'b1;
			end
		else if (r_sub_clk_reset == 1) begin // end of r_clk_reset
			r_sub_clk_reset <= r_sub_clk_reset;
			r_clk_reset <= 1'b0;
			end
		else begin // count down
			r_sub_clk_reset <= r_sub_clk_reset - 1;
			r_clk_reset <= 1'b1;
			end
		end
	else begin 
		r_sub_clk_reset <= 32'd0;
		r_clk_reset <= 1'b0;
		end
//
assign test_clk_reset_serdes = r_clk_reset; // test output 
////

// test_io_reset_serdes
reg r_io_reset; // 
reg [31:0] r_sub_io_reset;
parameter WIDTH_IO_RESET_NS = 32'd150; // ns
parameter WIDTH_IO_RESET = WIDTH_IO_RESET_NS/PERIOD_CLK_LOGIC_NS; // period count of cnv
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_sub_io_reset <= 32'd0;
		r_io_reset <= 1'b0;
		end 
	else if (en && test) begin
		if (r_sub_io_reset == 0) begin // start of r_io_reset
			r_sub_io_reset <= WIDTH_IO_RESET;
			r_io_reset <= 1'b1;
			end
		else if (r_sub_io_reset == 1) begin // end of r_io_reset
			r_sub_io_reset <= r_sub_io_reset;
			r_io_reset <= 1'b0;
			end
		else begin // count down
			r_sub_io_reset <= r_sub_io_reset - 1;
			r_io_reset <= 1'b1;
			end
		end
	else begin 
		r_sub_io_reset <= 32'd0;
		r_io_reset <= 1'b0;
		end
//
assign test_io_reset_serdes = r_io_reset; // test output 
////



// test_clk_adc
reg trig_clk_adc;
reg trig_dat_adc;
reg [31:0] sub_cnt_clk;
parameter DELAY_CLK = 32'd9; // 65ns min < 8ns*9=72ns @125MHz
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		sub_cnt_clk <= 32'd0;
		trig_clk_adc <= 1'b0;
		trig_dat_adc <= 1'b0;
		end 
	else begin
		if (sub_cnt_clk == 0) begin
			if (w_cnv_adc == 1) begin
				sub_cnt_clk <= DELAY_CLK - 2;
				trig_clk_adc <= 1'b0;
				trig_dat_adc <= 1'b0;
				end
			else begin
				sub_cnt_clk <= 0;
				trig_clk_adc <= 1'b0;
				trig_dat_adc <= 1'b0;
				end
			end
		else if (sub_cnt_clk == 2) begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b0;
			trig_dat_adc <= 1'b1;
			end
		else if (sub_cnt_clk == 1) begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b1;
			trig_dat_adc <= 1'b0;
			end
		else begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b0;
			trig_dat_adc <= 1'b0;
			end
		end
//
reg clk_adc;
reg [4:0] cnt_clk;
parameter LEN_CLK = 5'd9; // 9 slots, 5 pulses
//parameter LEN_CLK = 5'd7; // 7 slots, 4 pulses
//parameter LEN_CLK = 5'd13; // 13 slots, 7 pulses
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		cnt_clk <= 5'd0;
		clk_adc <= 1'b0;
		end 
	else begin
		if (cnt_clk == 0) begin
			if (trig_clk_adc) begin 
				cnt_clk <= LEN_CLK - 1;
				clk_adc <= 1'b1;
				end
			else begin
				cnt_clk <= 5'd0;
				clk_adc <= 1'b0;
				end
			end
		else begin
			cnt_clk <= cnt_clk - 1;
			clk_adc <= ~clk_adc; // generate clk_adc for test 
			end
		end
//
assign test_clk_adc = clk_adc;
////

//assign #(DELAY_dco_adc) dco_adc = clk_adc;
wire w_clk_adc = (en)? i_clk_adc : 1'b0;
assign #(DELAY_dco_adc) dco_adc = (DCLK_OUTPUT_POLARITY)? ~w_clk_adc : w_clk_adc;
//

// test_valid_fifo
//   use: trig_clk_adc, r_io_reset
reg r_valid_serdes;
reg [7:0] r_cnt_trig_clk_adc;
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_valid_serdes <= 1'b0;
		r_cnt_trig_clk_adc <= 8'b0;
		end 
	else begin
		if (r_io_reset == 0) begin
			if (trig_clk_adc) begin 
				if (r_cnt_trig_clk_adc < 2) 
					r_cnt_trig_clk_adc <= r_cnt_trig_clk_adc + 1;
				else if (r_cnt_trig_clk_adc >= 2) 
					r_valid_serdes <= 1'b1;
				end
			end
		else begin
			r_valid_serdes <= 1'b0;
			r_cnt_trig_clk_adc <= 8'b0;
			end
		end
//
assign test_valid_fifo = r_valid_serdes;
////


//wire [17:0] POLO = 18'b_10_1000_0001_1111_1100; // pattern_one_lane_output
wire [17:0] PTLO = 18'b_1100_1100_0011_1111_00; // pattern_two_lane_output: CC3F0 ~ 330FC
//wire [17:0] PTLO = 18'b_0110_0101_1000_1011_01; // 6A8B7
//wire [17:0] PTLO = 18'b_1010_1100_0001_1000_01; // AC187 ~ 2B061
// data comes in        0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ...
// the output will be   3210,       98,   7654, ...
//
reg [9:0] r_dat1_adc; // DB 16 ... 2, 0, 0
reg [9:0] r_dat2_adc; // DA 17 ... 3, 1, 0
//
wire [17:0] w_data_adc; // test adc data for increasing pattern 
//
wire [9:0] w_dat1_adc; // DB 16 ... 2, 0, 0
	assign w_dat1_adc[0] = (test_mode_inc_data)? w_data_adc[0]  : 1'b0     ; // 0 for 10-bit length
	assign w_dat1_adc[1] = (test_mode_inc_data)? w_data_adc[0]  : PTLO[0]  ;
	assign w_dat1_adc[2] = (test_mode_inc_data)? w_data_adc[2]  : PTLO[2]  ;
	assign w_dat1_adc[3] = (test_mode_inc_data)? w_data_adc[4]  : PTLO[4]  ;
	assign w_dat1_adc[4] = (test_mode_inc_data)? w_data_adc[6]  : PTLO[6]  ;
	assign w_dat1_adc[5] = (test_mode_inc_data)? w_data_adc[8]  : PTLO[8]  ;
	assign w_dat1_adc[6] = (test_mode_inc_data)? w_data_adc[10] : PTLO[10] ;
	assign w_dat1_adc[7] = (test_mode_inc_data)? w_data_adc[12] : PTLO[12] ;
	assign w_dat1_adc[8] = (test_mode_inc_data)? w_data_adc[14] : PTLO[14] ;
	assign w_dat1_adc[9] = (test_mode_inc_data)? w_data_adc[16] : PTLO[16] ;
wire [9:0] w_dat2_adc; // DA 17 ... 3, 1, 0                     
	assign w_dat2_adc[0] = (test_mode_inc_data)? w_data_adc[0]  : 1'b0     ; // 0 for 10-bit length
	assign w_dat2_adc[1] = (test_mode_inc_data)? w_data_adc[1]  : PTLO[1]  ;
	assign w_dat2_adc[2] = (test_mode_inc_data)? w_data_adc[3]  : PTLO[3]  ;
	assign w_dat2_adc[3] = (test_mode_inc_data)? w_data_adc[5]  : PTLO[5]  ;
	assign w_dat2_adc[4] = (test_mode_inc_data)? w_data_adc[7]  : PTLO[7]  ;
	assign w_dat2_adc[5] = (test_mode_inc_data)? w_data_adc[9]  : PTLO[9]  ;
	assign w_dat2_adc[6] = (test_mode_inc_data)? w_data_adc[11] : PTLO[11] ;
	assign w_dat2_adc[7] = (test_mode_inc_data)? w_data_adc[13] : PTLO[13] ;
	assign w_dat2_adc[8] = (test_mode_inc_data)? w_data_adc[15] : PTLO[15] ;
	assign w_dat2_adc[9] = (test_mode_inc_data)? w_data_adc[17] : PTLO[17] ;
//
reg [4:0] cnt_dat;
parameter LEN_DAT = 5'd10; // 10 slots
//
//always @(posedge clk_logic, negedge reset_n)
always @(posedge w_clk_adc, negedge w_clk_adc, posedge trig_dat_adc, negedge reset_n) // DDR
	if (!reset_n) begin
		cnt_dat <= 5'd0;
		r_dat1_adc <= 10'b0;
		r_dat2_adc <= 10'b0;
		end 
	else if (!en) begin
		cnt_dat <= 5'd0;
		r_dat1_adc <= 10'b0;
		r_dat2_adc <= 10'b0;
		end 
	else begin
		if (cnt_dat == 0) begin
			if (trig_dat_adc) begin // async set 
				cnt_dat <= LEN_DAT - 1;
				r_dat1_adc <= w_dat1_adc;
				r_dat2_adc <= w_dat2_adc; 
				end
			else begin
				cnt_dat <= 5'd0;
				r_dat1_adc <= r_dat1_adc;
				r_dat2_adc <= r_dat2_adc;
				end
			end
		else begin
			cnt_dat <= cnt_dat - 1;
			r_dat1_adc <= {r_dat1_adc[8:0], 1'b0};
			r_dat2_adc <= {r_dat2_adc[8:0], 1'b0};
			end
		end
//
assign #(DELAY_dat_adc) dat1_adc = (DAT1_OUTPUT_POLARITY)? ~r_dat1_adc[9] : r_dat1_adc[9];
assign #(DELAY_dat_adc) dat2_adc = (DAT2_OUTPUT_POLARITY)? ~r_dat2_adc[9] : r_dat2_adc[9];	

// 
reg [17:0] r_data_adc;
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		//r_data_adc <= 18'd0; //
		r_data_adc <= 18'h2_AC18; // any pattern to start
	end 
	else if (en) begin
		if (trig_dat_adc && test_mode_inc_data) begin 
			r_data_adc <= r_data_adc + 1;
			end
		else begin
			r_data_adc <= r_data_adc;
			end
		end
	else begin
		r_data_adc <= 18'd0;
		end
//
assign w_data_adc = r_data_adc;
//
assign debug_out = r_data_adc[7:0];
//
endmodule
