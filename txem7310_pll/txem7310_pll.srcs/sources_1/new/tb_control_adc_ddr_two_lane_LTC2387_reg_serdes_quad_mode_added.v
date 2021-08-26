`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_control_adc_ddr_two_lane_LTC2387_reg_serdes_quad_mode_added
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//----------------------------------------------------------------------------
// This demonstration testbench instantiates the example design for the SelectIO wizard. 
//$$    https://www.xilinx.com/support/documentation/ip_documentation/selectio_wiz/v5_1/pg070-selectio-wiz.pdf
//$$    https://www.xilinx.com/support/documentation/user_guides/ug471_7Series_SelectIO.pdf
//----------------------------------------------------------------------------
// simulate LTC2387-18 ADC DDR 2-wire output
//    http://www.analog.com/media/en/technical-documentation/data-sheets/238718fa.pdf
//
//	Output Test Patterns of LTC2387
//		To allow in-circuit testing of the digital interface to the
//		ADC, there is a test mode that forces the ADC data outputs
//		to known values:
//		One-Lane Mode: 10 1000 0001 1111 1100
//		Two-Lane Mode: 11 0011 0000 1111 1100
//					lane0 1 0100 1110
//					lane1 1 0100 1110
//		The test pattern is enabled when the TESTPAT pin is brought high.
//
// test  control_adc_ddr_two_lane_LTC2387_reg_serdes_quad
//
//////////////////////////////////////////////////////////////////////////////////


module tb_control_adc_ddr_two_lane_LTC2387_reg_serdes_quad_mode_added;


//// clock and reset //{
reg clk = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk = ~clk; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_bus = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_bus = ~clk_bus; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	
reg clk_210M = 1'b0; // 210Mz
	always
	#2.38095238 	clk_210M = ~clk_210M; // toggle every 2.38095238 ns --> clock 4.76190476 ns 

reg clk_250M = 1'b0; // 250MHz
	always
	#2 	clk_250M = ~clk_250M; // toggle every 2ns --> clock 4ns 
	
reg clk_183M = 1'b0; // 183.3MHz
	always
	#2.72727273 clk_183M = ~clk_183M; // toggle every 2.72727273 ns --> clock 5.45454546 ns 

reg clk_92M = 1'b0; // 91.67MHz
	always
	#1.36363637 clk_92M = ~clk_92M; // toggle every 1.38888889 ns --> clock 2.72727273 ns 

reg clk_150M = 1'b0; // 150MHz
	always
	#3.33333333 clk_150M = ~clk_150M; // toggle every 3.33333333 ns --> clock 6.66666667 ns 

reg clk_75M = 1'b0; // 75MHz
	always
	#6.66666667 clk_75M = ~clk_75M; // toggle every 6.66666667 ns --> clock 13.3333333 ns 

reg clk_125M = 1'b0; // 125MHz
	always
	#4 	clk_125M = ~clk_125M; // toggle every 4ns --> clock 8ns 

reg clk_62p5M = 1'b0; // 62.5MHz
	always
	#8 	clk_62p5M = ~clk_62p5M; // toggle every 8ns --> clock 16ns 

reg clk_60M = 1'b0; // 60MHz
	always
	#8.33333333 	clk_60M = ~clk_60M; // toggle every 8ns --> clock 16ns 

//}

//// wire and reg //{

//// adc test 
wire w_dco_adc;
wire w_dat1_adc;
wire w_dat2_adc;

//// module test 
reg en;
reg init;
reg update;
reg test;
reg test_model_en;
reg test_model;
reg test_fifo_rd_en;
//

//
wire [9:0] w_in_delay_tap; // from control 
wire w_clk_reset_mdl; // from model
wire w_io_reset_mdl; // from model
wire w_clk_reset_ctl; // from control
wire w_io_reset_ctl; // from control 
wire w_clk_reset; // mux
wire w_io_reset; // mux
	assign w_clk_reset = (test_model_en)? w_clk_reset_mdl : w_clk_reset_ctl;
	assign w_io_reset  = (test_model_en)? w_io_reset_mdl  : w_io_reset_ctl;
//
wire w_clk_div; // to control
wire w_delay_locked; // to control 
//
wire w_valid_fifo_mdl;
wire w_valid_fifo_ctl;
wire w_valid_fifo = (test_model_en)? w_valid_fifo_mdl : w_valid_fifo_ctl; // for fifo
//
wire w_wr_fifo;
//
wire w_cnv_adc_mdl; // from model
wire w_clk_adc_mdl; // from model
wire [7:0] w_debug_out;
//
wire w_cnv_adc_ctl; // from control 
wire w_clk_adc_ctl; // from control 
wire w_cnv_adc; // mux
wire w_clk_adc; // mux
	assign w_cnv_adc = (test_model_en)? w_cnv_adc_mdl : w_cnv_adc_ctl;
	assign w_clk_adc = (test_model_en)? w_clk_adc_mdl : w_clk_adc_ctl;
wire w_pin_test_adc;

//}


//// TODO: DUT: test model //{
//      quad adc channel

//
test_model_adc_ddr_two_lane_LTC2387 #(
	.PERIOD_CLK_LOGIC_NS (8 ), // ns // for 125MHz @ clk_logic
	.PERIOD_CLK_CNV_NS   (96), // ns // period of test_cnv_adc // 96=12*8
	//.PERIOD_CLK_CNV_NS   (88), // ns // period of test_cnv_adc // 88=11*8
	.DAT1_OUTPUT_POLARITY(1'b0),
	.DAT2_OUTPUT_POLARITY(1'b0),
	.DCLK_OUTPUT_POLARITY(1'b0)	
	) test_model_adc_ddr_two_lane_LTC2387_inst (
	.clk_logic	(clk_125M), // 125MHz
	.reset_n	(reset_n),
	.en			(1'b1), // test fo connected ADC
	//.en			(1'b0), // test for unconnected behaviour
	//
	.test					(test_model		), // generate test pattern on dco_adc / dat1_adc / dat2_adc, without external clock.
	.test_cnv_adc			(w_cnv_adc_mdl	), // auto conversion output signal for test 
	.test_clk_adc			(w_clk_adc_mdl	), // auto conversion output signal for test 
	.test_clk_reset_serdes	(w_clk_reset_mdl), // auto clk_reset for serdes
	.test_io_reset_serdes	(w_io_reset_mdl	), // auto io_reset for serdes
	.test_valid_fifo		(w_valid_fifo_mdl), // auto valid for fifo
	//
	.i_cnv_adc	(w_cnv_adc), // trigger input for conversion 
	.i_clk_adc	(w_clk_adc), // clock input for adc data ... connected to dco_adc
	//
	.test_mode_inc_data (~w_pin_test_adc), // increasing data or fixed data
	//
	.dco_adc	(w_dco_adc),
	.dat1_adc	(w_dat1_adc),
	.dat2_adc	(w_dat2_adc),
	//
	.debug_out	(w_debug_out)
);
//

//}


//// TODO: DUT: test control for quad adc //{

// for DFT calc
wire  [17:0] w_data_in_fifo_0;
wire  [17:0] w_data_in_fifo_1;
//
wire         w_wr_fifo_0;
wire         w_wr_fifo_1;


//
//wire [17:0] fifo_adc0_dout; // to be connected
//wire fifo_adc0_rd_en	= test_fifo_rd_en; // test
//wire fifo_adc0_valid	;
//wire fifo_adc0_uflow	;
//wire fifo_adc0_pempty	;
//wire fifo_adc0_empty	;
//wire fifo_adc0_wr_ack	;
//wire fifo_adc0_oflow	;
//wire fifo_adc0_pfull	;
//wire fifo_adc0_full		;
//
wire init_done;
wire update_done;
wire test_done;
//
parameter TEST_num_update_samples = 32'd136;
//
// for 125MHz control
//parameter TEST_sampling_period_count = 32'd12; // 125MHz/12 = 10.4166667 Msps
//parameter TEST_sampling_period_count = 32'd11; // 125MHz/11 = 11.3636364 Msps
//parameter TEST_sampling_period_count = 32'd10; // NG ... init test value is not updated in GUI ... may be related to delay_locked
//parameter TEST_sampling_period_count = 32'd9; // NG clk_adc broken by overlab
//
// for 150MHz control
//parameter TEST_sampling_period_count = 32'd14; // 150MHz/14 = 10.7142857 Msps // OK 66.7ns(>65)  33.3ns(<49)
//parameter TEST_sampling_period_count = 32'd12; // 150MHz/12 = 12.5 Msps // OK
//parameter TEST_sampling_period_count = 32'd11; // 150MHz/11 = 13.6363636 Msps // NG 66.7ns(>65)  53.3ns(<49)
//parameter TEST_sampling_period_count = 32'd10; // 150MHz/10 = 15 Msps // NG 66.7ns(>65)  60.0ns(<49)
//
// 65ns + (1/f)*9 - 1/(15MHz) < 49ns
// (1/f) < (1/(15MHz) + 49ns - 65ns)/9 = 5.62962963 ns
// f > 177.631579 MHz
// try 180MHz or 210MHz
//
// for 183MHz control
//parameter TEST_sampling_period_count = 32'd13; // 183MHz/13 = 14.0769231 Msps // OK 65.5ns(>65)  49.1ns(<49)
//
// for 200MHz control
//parameter TEST_sampling_period_count = 32'd16; // 200MHz/16 = 12.5 Msps // OK 
//parameter TEST_sampling_period_count = 32'd14; // 200MHz/14 = 14.2857143 Msps // OK 
//
// for 210MHz control
parameter TEST_sampling_period_count = 32'd14; // 210MHz/14 = 15 Msps // OK 
//
// for 250MHz control
//parameter TEST_sampling_period_count = 32'd22; // 250MHz/22 = 11.3636364 Msps // OK 68ns(>65)  16ns(<49)
//parameter TEST_sampling_period_count = 32'd17; // 250MHz/17 = 14.7058824 Msps // OK 68ns(>65)  36ns(<49)
//parameter TEST_sampling_period_count = 32'd16; // 250MHz/16 = 15.62500 Msps // OK 68ns(>65)  40ns(<49)
//
//parameter TEST_num_update_samples = 32'd148;
//parameter TEST_sampling_period_count = 32'd24;
//
//parameter TEST_num_update_samples = 32'd156;
//parameter TEST_sampling_period_count = 32'd120;
//
parameter ADC1_EN = 1'b1;
parameter ADC2_EN = 1'b1;
parameter ADC3_EN = 1'b0;
parameter ADC4_EN = 1'b0;
parameter MODE_ADC_CONTROL = {ADC4_EN,ADC3_EN,ADC2_EN,ADC1_EN};
//
control_adc_ddr_two_lane_LTC2387_reg_serdes_quad #(
	//.PERIOD_CLK_LOGIC_NS (8 ), // ns // for 125MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (6.66666667), // ns // for 150MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (5.45454546), // ns // for 183MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (5 ), // ns // for 200MHz @ clk_logic
	.PERIOD_CLK_LOGIC_NS (4.76190476), // ns // for 210MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (4 ), // ns // for 250MHz @ clk_logic
	//
	//.DELAY_CLK (9), // 65ns min < 8ns*9=72ns @125MHz
	//.DELAY_CLK (10), // 65ns min < 6.6ns*10=66ns @150MHz
	//.DELAY_CLK (12), // 65ns min < 5.5ns*12=66ns @183MHz
	//.DELAY_CLK (14), // 65ns min < 5ns*14=70ns @200MHz
	.DELAY_CLK (14), // 65ns min < 4.76ns*14=66.6ns @210MHz
	//.DELAY_CLK (17), // 65ns min < 4ns*17=68ns @250MHz
	//
	.DELAY_NS_delay_locked(973), // ns // only for simulation // 0 or 973ns
	.MODE_ADC_CONTROL(MODE_ADC_CONTROL),
	.DAT1_OUTPUT_POLARITY(4'b0010),
	.DAT2_OUTPUT_POLARITY(4'b0010),
	.DCLK_OUTPUT_POLARITY(4'b0010)
	)  control_adc_ddr_two_lane_LTC2387_inst( 
	.clk		(clk), // assume 10MHz or 100ns
	.reset_n	(reset_n),
	.en			(en),
	//
	//.clk_logic		(clk_125M), // 
	//.clk_logic		(clk_150M), // 
	//.clk_logic		(clk_183M), // 
	//.clk_logic		(clk_200M), // 
	.clk_logic		(clk_210M), // 
	//.clk_logic		(clk_250M), // 
	//
	.clk_fifo		(clk_60M), // for fifo write
	//
	.clk_bus		(clk_bus), // for fifo read
	.clk_ref_200M	(clk_200M), // for serdes reference
	//
	.init		(init),
	.update		(update),
	.test		(test),
	//
	.i_num_update_samples		(TEST_num_update_samples), //  adc samples OK
	.i_sampling_period_count	(TEST_sampling_period_count),
	//
	.i_in_delay_tap_serdes0		({5'd15,5'd15}),
	.i_in_delay_tap_serdes1		({5'd15,5'd15}),
	.i_in_delay_tap_serdes2		({5'd15,5'd15}),
	.i_in_delay_tap_serdes3		({5'd15,5'd15}),
	//
	.i_pin_test_frc_high		(1'b0),
	.i_pin_dlln_frc_low 		(1'b0),
	.i_pttn_cnt_up_en   		(1'b0), //
	//
	.o_cnv_adc				(w_cnv_adc_ctl),
	.o_clk_adc				(w_clk_adc_ctl),
	.o_pin_test_adc			(w_pin_test_adc),
	.o_pin_duallane_adc		(),
	//
	//.i_master_mode_en	(1'b1),
	//.o_io_reset			(w_io_reset_ctl), // remove? 
	//.o_clk_reset		(w_clk_reset_ctl), // remove?
	//.i_io_reset			(),
	//.o_delay_locked			(w_delay_locked),
	//.i_delay_locked	(w_delay_locked), // remove
	//
	//
	. i_clk_in_adc0		((ADC1_EN)? w_dco_adc : 1'b1), // serdes clock in from adc
	.i_data_in_adc0		((ADC1_EN)? {w_dat2_adc,w_dat1_adc} : 2'b11), // from adc
	. i_clk_in_adc1		((ADC2_EN)? ~w_dco_adc : 1'b1), // serdes clock in from adc
	.i_data_in_adc1		((ADC2_EN)? {~w_dat2_adc,~w_dat1_adc} : 2'b11), // from adc
	. i_clk_in_adc2		((ADC3_EN)?  w_dco_adc : 1'b1), // serdes clock in from adc
	.i_data_in_adc2		((ADC3_EN)? {w_dat2_adc,w_dat1_adc} : 2'b11), // from adc
	. i_clk_in_adc3		((ADC4_EN)?  w_dco_adc : 1'b1), // serdes clock in from adc
	.i_data_in_adc3		((ADC4_EN)? {w_dat2_adc,w_dat1_adc} : 2'b11), // from adc
	//
	.o_data_in_fifo_0	(w_data_in_fifo_0), // [17:0]
	.o_data_in_fifo_1	(w_data_in_fifo_1), // [17:0]
	.o_data_in_fifo_2	(),
	.o_data_in_fifo_3	(),
	//
	.     o_wr_fifo_0	(w_wr_fifo_0), //
	.     o_wr_fifo_1	(w_wr_fifo_1), //
	.     o_wr_fifo_2	(),
	.     o_wr_fifo_3	(),
	//
	.o_data_out_fifo_0	(), // to usb endpoint
	.      i_rd_fifo_0	(test_fifo_rd_en	), // to usb endpoint
	.   o_valid_fifo_0	(),
	.   o_uflow_fifo_0	(),
	.  o_pempty_fifo_0	(),
	.   o_empty_fifo_0	(),
	.  o_wr_ack_fifo_0	(),
	.   o_oflow_fifo_0	(),
	.   o_pfull_fifo_0	(),
	.    o_full_fifo_0	(),
	//
	.o_data_out_fifo_1	(), // to usb endpoint
	.      i_rd_fifo_1	(test_fifo_rd_en	), // to usb endpoint
	.   o_valid_fifo_1	(),
	.   o_uflow_fifo_1	(),
	.  o_pempty_fifo_1	(),
	.   o_empty_fifo_1	(),
	.  o_wr_ack_fifo_1	(),
	.   o_oflow_fifo_1	(),
	.   o_pfull_fifo_1	(),
	.    o_full_fifo_1	(),
	//
	.o_data_out_fifo_2	(), // to usb endpoint
	.      i_rd_fifo_2	(test_fifo_rd_en	), // to usb endpoint
	.   o_valid_fifo_2	(),
	.   o_uflow_fifo_2	(),
	.  o_pempty_fifo_2	(),
	.   o_empty_fifo_2	(),
	.  o_wr_ack_fifo_2	(),
	.   o_oflow_fifo_2	(),
	.   o_pfull_fifo_2	(),
	.    o_full_fifo_2	(),
	//
	.o_data_out_fifo_3	(), // to usb endpoint
	.      i_rd_fifo_3	(test_fifo_rd_en	), // to usb endpoint
	.   o_valid_fifo_3	(),
	.   o_uflow_fifo_3	(),
	.  o_pempty_fifo_3	(),
	.   o_empty_fifo_3	(),
	.  o_wr_ack_fifo_3	(),
	.   o_oflow_fifo_3	(),
	.   o_pfull_fifo_3	(),
	.    o_full_fifo_3	(),
	//	
	.init_done				(init_done),
	.update_done			(update_done),
	.test_done				(test_done),
	.error					(),
	.debug_out				()
);
//

//}


//// TODO: DFT calculation //{

wire w_dft_coef_adrs_clear = update    ; //r_dft_coef_adrs_clear; //
wire w_acc_clear           = update    ; //r_acc_clear          ; //
wire w_trig_fifo_wr_en     = w_wr_fifo_0; //r_trig_fifo_wr_en    ; //

wire [17:0] w_adc_data_int18_dout0 = w_data_in_fifo_0; //
wire [17:0] w_adc_data_int18_dout1 = w_data_in_fifo_1; //

wire [31:0] w_acc_flt32_re_dout0;
wire [31:0] w_acc_flt32_im_dout0;
wire [31:0] w_acc_flt32_re_dout1;
wire [31:0] w_acc_flt32_im_dout1;

wire w_pulse_monitor;


calculate_dft_wrapper  calculate_dft_wrapper__inst (
	.clk                 (clk    ), // assume 10MHz or 100ns // io control
	.reset_n             (reset_n),

	.clk_fifo            (clk_60M), // 60MHz
	.clk_mcs             (clk_bus),      // 72MHz or 100.8MHz

	// controls
	.i_dft_coef_adrs_clear  (w_dft_coef_adrs_clear),
	.i_acc_clear            (w_acc_clear          ),
	.i_trig_fifo_wr_en      (w_trig_fifo_wr_en    ),

	// ports - data in and acc out
	.i_adc_data_int18_dout0 (w_adc_data_int18_dout0), // [17:0] 
	.i_adc_data_int18_dout1 (w_adc_data_int18_dout1), // [17:0] 
	
	.o_acc_flt32_re_dout0   (w_acc_flt32_re_dout0), // [31:0] 
	.o_acc_flt32_im_dout0   (w_acc_flt32_im_dout0), // [31:0] 
	.o_acc_flt32_re_dout1   (w_acc_flt32_re_dout1), // [31:0] 
	.o_acc_flt32_im_dout1   (w_acc_flt32_im_dout1), // [31:0] 

	// ports - coef write
	//...

	// port - monitor
	.o_pulse_monitor (w_pulse_monitor), // every acc load

	.valid           ()
);
//}

////
// DUT: io delay / clock in
//
// 
////


////
//// delay control : IDELAYCTRL
////   IDELAYCTRL is needed for calibration
////
//wire delay_locked_pre;
////
//(* IODELAY_GROUP = "top__group" *)
//IDELAYCTRL  delayctrl_inst (
//	.RDY    (delay_locked_pre),
//	.REFCLK (clk_200M),
//	.RST    (w_io_reset)
//);
////
//parameter DELAY_NS_delay_locked = 973; // ns // only for simulation // 0 or 973ns
//assign #(DELAY_NS_delay_locked,0) w_delay_locked = delay_locked_pre; 
////
////assign w_delay_locked = delay_locked_pre; // for implementation
////
//////


//$$ to revise ...
wire trig_test_done = (w_debug_out == 8'h23)? 1'b1 : 1'b0;


//// test signals  //{
time cnt_wait_64bit_unsigned = 64'd0;
//
initial begin
#0	reset_n 		= 1'b0;
	en 				= 1'b0;
	init			= 1'b0;
	update 			= 1'b0;
	test 			= 1'b0;
	test_model_en	= 1'b0;
	test_model		= 1'b0;
	test_fifo_rd_en	= 1'b0;
#200;
	reset_n = 1'b1; 
#200;
//
///////////////////////
	test_model_en	= 1'b1;
#200;
	test_model		= 1'b1;
//#1000;
#100;
//@(posedge tb_control_adc_ddr_two_lane_LTC2387_reg_serdes_quad_mode_added.test_model_adc_ddr_two_lane_LTC2387_inst.trig_dat_adc)
@(posedge trig_test_done)
	test_model		= 1'b0;
//
#200;
	test_model_en	= 1'b0;
#200;
///////////////////////
	en 			= 1'b1;
#200;
//
	init		= 1'b1;
#100;
	init		= 1'b0;
#200;
//
$display(" Wait for rise of init_done"); 
@(posedge init_done)
#200;
//
	//test_fifo_rd_en		= 1'b1;
#200;
	//test_fifo_rd_en		= 1'b0;
#200;
//
	test 		= 1'b1;
#100;
	test 		= 1'b0;
//
$display(" Wait for rise of test_done"); 
@(posedge test_done)
#200;
//
	test 		= 1'b1;
#1000;
	test 		= 1'b0;
#200;
//
$display(" Wait for rise of test_done"); 
@(posedge test_done)
#200;
//
	update 		= 1'b1;
#100;
	update 		= 1'b0;
#200;
//
#200;
////#10_000;
//cnt_wait_64bit_unsigned = 64'd8*TEST_sampling_period_count*TEST_num_update_samples;
//$display(" Wait = ", cnt_wait_64bit_unsigned); 
//#(cnt_wait_64bit_unsigned);
//#200;
//
$display(" Wait for rise of update_done"); 
@(posedge update_done)
#200;
//
	test_fifo_rd_en		= 1'b1;
#200;
//
cnt_wait_64bit_unsigned = 64'd10*TEST_num_update_samples*2;
$display(" Wait = ", cnt_wait_64bit_unsigned); 
#(cnt_wait_64bit_unsigned);
#200;
	test_fifo_rd_en		= 1'b0;
#200;
//
	en 			= 1'b0;
#200;
///////////////////////
	$finish;
end

//}


//initial begin
	//$dumpfile ("waveform.vcd"); 
	//$dumpvars; 
//end 
  
//initial  begin
	//$display("\t\t time,\t clk,\t reset_n,\t en"); 
	//$monitor("%d,\t%b,\t%b,\t%b,\t%d",$time,clk,reset_n,en); 
//end 

//initial begin
//#1000_000; // 1ms = 1000_000ns
//	$finish;
//end

endmodule
