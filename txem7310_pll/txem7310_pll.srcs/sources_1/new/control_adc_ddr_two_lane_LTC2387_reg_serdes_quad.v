//------------------------------------------------------------------------
// control_adc_ddr_two_lane_LTC2387_reg_serdes_quad.v
//   for LTC2387-18 ADC DDR 2-wire output
//   	http://www.analog.com/media/en/technical-documentation/data-sheets/238718fa.pdf
//   support serdes reg logic
//   support fifo IP
//   support quad ADC control 
//   add dual control mode
//   test pattern : 0x330FC
//
//------------------------------------------------------------------------
// IO for quad ADC 
//		o_cnv_adc 		// ADC_XX_CNV_TRIG
//		o_clk_adc 		// ADC_XX_CLK_P
//		o_test_adc 		// ADC_XX_TEST_N
//		o_duallane_adc 	// ADC_XX_DUAL_LANE_N
// IO for serdes IP
//		i_clk_in_serdes	
//		i_data_in_serdes		
// IO for fifo IP
//		o_data_out_fifo
//		i_rd_fifo
//
//------------------------------------------------------------------------
// init mode   : initialize serdes, (set registers,) and generate 5 test patterns. 
//               check if prog_empty flag is set.
// update mode : initialize serdes, read adc data with a given length of data.
// test mode   : initialize serdes, read a single adc data. (4 conversion pulses)
//------------------------------------------------------------------------
//
//
// adc timing 
//   cnv high time    5ns min ~ 200MHz max
//   clk high time 1.25ns min ~ 800MHz max
//
//   10Msps ... with 125MHz control ...
//   to support 15Msps ...
//     250MHz control vs 200MHz 



`timescale 1ns / 1ps
module control_adc_ddr_two_lane_LTC2387_reg_serdes_quad (  
	// 
	input wire clk, // assume 10MHz or 100ns
	input wire reset_n,
	input wire en,
	//
	input wire clk_logic, // assume 125MHz or 8ns // try 250MHz or 4ns
	input wire clk_fifo, // assume 62.5MHz or 16ns
	input wire clk_bus, // bus or fifo read
	input wire clk_ref_200M, // serdes ref clock 200MHz // to remove
	//
	// end-point control
	input wire init, // rising
	input wire update, // rising
	input wire test, // rising
	//
	input wire i_fifo_rst,
	//
	// register setting values // consider pipe-in end-point outside
	input wire [31:0] i_num_update_samples		, // number of update samples 
	input wire [31:0] i_sampling_period_count	, // period count based on 125MHz clock
	input wire [9:0]  i_in_delay_tap_serdes0		, // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
	input wire [9:0]  i_in_delay_tap_serdes1		, // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
	input wire [9:0]  i_in_delay_tap_serdes2		, // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
	input wire [9:0]  i_in_delay_tap_serdes3		, // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
	input wire i_pin_test_frc_high, //	pin_test forced high      pin_test_frc_high
	input wire i_pin_dlln_frc_low , //	pin_duallane forced low   pin_dlln_frc_low
	input wire i_pttn_cnt_up_en   , //	count up pattern enable   pttn_cnt_up_en
	//	
	// common control for ADC 
	output wire o_cnv_adc,
	output wire o_clk_adc,
	output wire o_pin_test_adc,
	output wire o_pin_duallane_adc,
	//
	// ADC clock and data in 
	input wire        i_clk_in_adc0,
	input wire [1:0] i_data_in_adc0,
	//
	input wire        i_clk_in_adc1,
	input wire [1:0] i_data_in_adc1,
	//
	input wire        i_clk_in_adc2,
	input wire [1:0] i_data_in_adc2,
	//
	input wire        i_clk_in_adc3,
	input wire [1:0] i_data_in_adc3,
	//
	// monitoring path for adc ddr after serdes
	output wire [17:0] o_data_in_fifo_0,
	output wire [17:0] o_data_in_fifo_1,
	output wire [17:0] o_data_in_fifo_2,
	output wire [17:0] o_data_in_fifo_3,
	//
	output wire             o_wr_fifo_0,
	output wire             o_wr_fifo_1,
	output wire             o_wr_fifo_2,
	output wire             o_wr_fifo_3,
	//
	// data out path for fifo 
	output wire [17:0] o_data_out_fifo_0,
	input  wire              i_rd_fifo_0,
	output wire           o_valid_fifo_0,
	output wire           o_uflow_fifo_0,
	output wire          o_pempty_fifo_0,
	output wire           o_empty_fifo_0,
	output wire          o_wr_ack_fifo_0,
	output wire           o_oflow_fifo_0,
	output wire           o_pfull_fifo_0,
	output wire            o_full_fifo_0,
	//
	output wire [17:0] o_data_out_fifo_1,
	input  wire              i_rd_fifo_1,
	output wire           o_valid_fifo_1,
	output wire           o_uflow_fifo_1,
	output wire          o_pempty_fifo_1,
	output wire           o_empty_fifo_1,
	output wire          o_wr_ack_fifo_1,
	output wire           o_oflow_fifo_1,
	output wire           o_pfull_fifo_1,
	output wire            o_full_fifo_1,
	//
	output wire [17:0] o_data_out_fifo_2,
	input  wire              i_rd_fifo_2,
	output wire           o_valid_fifo_2,
	output wire           o_uflow_fifo_2,
	output wire          o_pempty_fifo_2,
	output wire           o_empty_fifo_2,
	output wire          o_wr_ack_fifo_2,
	output wire           o_oflow_fifo_2,
	output wire           o_pfull_fifo_2,
	output wire            o_full_fifo_2,
	//
	output wire [17:0] o_data_out_fifo_3,
	input  wire              i_rd_fifo_3,
	output wire           o_valid_fifo_3,
	output wire           o_uflow_fifo_3,
	output wire          o_pempty_fifo_3,
	output wire           o_empty_fifo_3,
	output wire          o_wr_ack_fifo_3,
	output wire           o_oflow_fifo_3,
	output wire           o_pfull_fifo_3,
	output wire            o_full_fifo_3,
	//
	//
	// flag
	output wire init_done,
	output wire update_done,
	output wire test_done,
	output wire error,
	output wire [7:0] debug_out
);


// parameters
parameter PERIOD_CLK_LOGIC_NS = 8; // ns // for 125MHz @ clk_logic
//parameter PERIOD_CLK_CNV_NS = 96; // ns --> INIT_r_sampling_period_count
//
parameter MODE_ADC_CONTROL = 4'b1111; //$$ 4'b1111 for quad adc, 4'b0011 for dual, 4'b0001 for single.



// state register
(* keep = "true" *) reg [7:0] state; 
//
parameter 	ST_INIT			= 8'hCA; // state init
parameter 	ST_UPDATE		= 8'hDA; // state update
parameter 	ST_UPDATE_WAIT	= 8'hDB; // state update_wait for reliable
parameter 	ST_TEST			= 8'hEA; // state test
//
parameter 	SEQ_READY 		= 8'hFC; // ready srate
parameter 	SEQ_START 		= 8'hFD; // start of seq
parameter 	SEQ_END 		= 8'hFE; // end of seq
parameter 	SEQ_END_WAIT	= 8'hFF; // end of seq
//
////
// SEQ_READY -> SEQ_START (wait for triggers) -> (options) -> SEQ_END -> SEQ_START ...
//
// initial seq: ST_INIT triggered by r_init_trig
// update  seq: ST_UPDATE triggered by r_update_trig
// test    seq: ST_TEST triggered by r_test_trig 
//
assign debug_out = state;

////
// update wait // independent with fifo 
//
reg [9:0] r_cnt_update_wait;
//
parameter UPDATE_WAIT_CNT = 10'd200; // based on clk_fifo
//
always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_cnt_update_wait	<= 10'd0;
		end 
	else if (!en) begin
		r_cnt_update_wait	<= 10'd0;
		end 
	else if (state == ST_UPDATE) begin
		r_cnt_update_wait <= UPDATE_WAIT_CNT;
		end	
	else if (r_cnt_update_wait>0) begin
		r_cnt_update_wait <= r_cnt_update_wait - 1;
		end
	else begin 
		r_cnt_update_wait	<= 10'd0;
		end
//
////


// init trig
reg r_init_trig;
reg r_init_done;
reg [1:0] r_init;
reg r_init_done_smp;

// update trig
reg r_update_trig;
reg r_update_done;
reg [1:0] r_update;
reg r_update_done_smp;
	
// test trigverilog bitwidth variable
reg r_test_trig;
reg r_test_done;
reg [1:0] r_test;
reg r_test_done_smp;

// busy
reg r_init_busy;		
reg r_update_busy;		
reg r_test_busy;		

// done
assign init_done = r_init_done;
assign update_done = r_update_done;
assign test_done = r_test_done;

parameter BW__NUM_UPD_SAMP = 18; // 32-->18
// note ... assume min 10ksps with 250MHz ... 250MHz/10kHz = 25000 ~ 2^15
parameter BW__ADC_SAMP_PERIOD = 22; // 32-->16 // 16--> 22 for slow undersampling
// ... r_sampling_period_count
// INIT_r_sampling_period_count
// w_period_cnv
// sub_cnt_cnv

// initialize parameters from outside 
//$$reg [31:0] r_num_update_samples		; // number of update samples 
reg [(BW__NUM_UPD_SAMP-1):0] r_num_update_samples		; // number of update samples 
wire [31:0] w_num_update_samples = {{(32-BW__NUM_UPD_SAMP){1'b0}}, r_num_update_samples};
//
//$$reg [31:0] r_sampling_period_count	; // period count based on 125MHz clock
reg [BW__ADC_SAMP_PERIOD-1:0] r_sampling_period_count	; // period count based on 125MHz clock
reg [9:0]  r_in_delay_tap_serdes0	; // serdes input delay // 5 bits/lane, 2 lanes/ADC
reg [9:0]  r_in_delay_tap_serdes1	; // serdes input delay // 5 bits/lane, 2 lanes/ADC
reg [9:0]  r_in_delay_tap_serdes2	; // serdes input delay // 5 bits/lane, 2 lanes/ADC
reg [9:0]  r_in_delay_tap_serdes3	; // serdes input delay // 5 bits/lane, 2 lanes/ADC
//
//parameter INIT_r_num_update_samples    = 32'd100; // 
parameter INIT_r_num_update_samples    = {{(BW__NUM_UPD_SAMP-8){1'b0}}, 8'd100}; // 
//parameter INIT_r_sampling_period_count = 32'd12; // for 125MHz
//parameter INIT_r_sampling_period_count = 32'd14; // for 210MHz
//parameter INIT_r_sampling_period_count = 32'd24; // for 250MHz
//parameter INIT_r_sampling_period_count = {{(BW__ADC_SAMP_PERIOD-8){1'b0}}, 8'd24}; // for 250MHz
parameter INIT_r_sampling_period_count = {{(BW__ADC_SAMP_PERIOD-8){1'b0}}, 8'd14}; // for 210MHz
parameter INIT_r_in_delay_tap_serdes   = {5'd10,5'd10}; // 
	
reg r_pin_test_frc_high;
reg r_pin_dlln_frc_low ;
reg r_pttn_cnt_up_en   ;

////
// o_pin_duallane_adc: dual lane control output 
//assign o_pin_duallane_adc	= 1'b1;
assign o_pin_duallane_adc = (r_pin_dlln_frc_low)? 1'b0 : 1'b1;
//
////


////
// o_pin_test_adc:  test_pin high for init.
assign o_pin_test_adc = 
	(r_pin_test_frc_high)? 1'b1 :
	(r_init_busy        )? 1'b1 : 1'b0;
//
////


////
// process sampling
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
        r_init <= 2'b0;
		r_init_done_smp <= 1'b0;
		//
        r_update <= 2'b0;
		r_update_done_smp <= 1'b0;
		//
        r_test <= 2'b0;
		r_test_done_smp <= 1'b0;
        end
    else if (en) begin
        r_init <= {r_init[0], init};
        r_init_done_smp <= r_init_done;
		//
        r_update <= {r_update[0], update};
        r_update_done_smp <= r_update_done;
		//
        r_test <= {r_test[0], test};
        r_test_done_smp <= r_test_done;
        end 
    else begin
        r_init <= 2'b0;
		r_init_done_smp <= 1'b0;
		//
        r_update <= 2'b0;
		r_update_done_smp <= 1'b0;
		//
        r_test <= 2'b0;
		r_test_done_smp <= 1'b0;
        end
//
// process trig 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
        r_init_trig <= 1'b0;
        r_update_trig <= 1'b0;
        r_test_trig <= 1'b0;
        end
    else if (en) begin
		if (!r_init_trig)
			r_init_trig <= ~r_init[1]&r_init[0];
		else if (~r_init_done_smp&r_init_done)
			r_init_trig <= 1'b0;
		//
		if (!r_update_trig)
			r_update_trig <= ~r_update[1]&r_update[0];
		else if (~r_update_done_smp&r_update_done)
			r_update_trig <= 1'b0;
		//
		if (!r_test_trig)
			r_test_trig <= ~r_test[1]&r_test[0];
		else if (~r_test_done_smp&r_test_done)
			r_test_trig <= 1'b0;
        end 
    else begin
        r_init_trig <= 1'b0;
        r_update_trig <= 1'b0;
        r_test_trig <= 1'b0;
        end
		
reg r_error; // update error
assign error = r_error;
//
////


////
// clk_reset // independent with fifo 
//
reg r_clk_reset; // 
wire w_clk_reset;
//
parameter BW__SUB_CLK_RESET = 8; // 32-->8
//reg [31:0] r_sub_clk_reset;
reg [(BW__SUB_CLK_RESET-1):0] r_sub_clk_reset;
parameter WIDTH_CLK_RESET_NS = 32'd50; // ns
parameter WIDTH_CLK_RESET = WIDTH_CLK_RESET_NS/PERIOD_CLK_LOGIC_NS; // period count of r_clk_reset
//
wire w_clk_reset_en = r_test_busy | r_init_busy | r_update_busy;
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_sub_clk_reset <= {(BW__SUB_CLK_RESET){1'b0}};
		r_clk_reset <= 1'b0;
		end 
	else if (!en) begin
		r_sub_clk_reset <= {(BW__SUB_CLK_RESET){1'b0}};
		r_clk_reset <= 1'b0;
		end 
	else if (w_clk_reset_en) begin
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
		r_sub_clk_reset <= {(BW__SUB_CLK_RESET){1'b0}};
		r_clk_reset <= 1'b0;
		end
//
assign w_clk_reset = r_clk_reset;
//
////

////
// io_reset // independent with fifo 
//
reg r_io_reset; // 
wire w_io_reset; 
//
// note 150ns * 210MHz = 31.5 
parameter BW__SUB_IO_RESET = 8; // 32-->8
//reg [31:0] r_sub_io_reset;
reg [(BW__SUB_IO_RESET-1):0] r_sub_io_reset;
parameter WIDTH_IO_RESET_NS = 32'd150; // ns
parameter WIDTH_IO_RESET = WIDTH_IO_RESET_NS/PERIOD_CLK_LOGIC_NS; // period count of r_io_reset
//
wire w_io_reset_en = r_test_busy | r_init_busy;
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_sub_io_reset <= {(BW__SUB_IO_RESET){1'b0}};
		r_io_reset <= 1'b0;
		end 
	else if (!en) begin
		r_sub_io_reset <= {(BW__SUB_IO_RESET){1'b0}};
		r_io_reset <= 1'b0;
		end 
	else if (w_io_reset_en) begin
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
		r_sub_io_reset <= {(BW__SUB_IO_RESET){1'b0}};
		r_io_reset <= 1'b0;
		end
//
assign w_io_reset = r_io_reset;
//
////


////
// w_delay_locked
// delay control : IDELAYCTRL
//   IDELAYCTRL is needed for calibration
//
wire w_delay_locked;
wire delay_locked_pre;
//
(* IODELAY_GROUP = "control_adc_subtop__group" *)
IDELAYCTRL  delayctrl_inst (
	.RDY    (delay_locked_pre),
	.REFCLK (clk_ref_200M),
	.RST    (w_io_reset)
);
//
parameter DELAY_NS_delay_locked = 0; // ns // only for simulation // 0 or 973ns
assign #(DELAY_NS_delay_locked,0) w_delay_locked = delay_locked_pre; 
//
//assign w_delay_locked = delay_locked_pre; // for implementation
//
////


////
// data input delay : IDELAYE2
//
localparam NUM_IN_DELAY = 8;
genvar in_delay_idx;
//
wire [NUM_IN_DELAY-1:0] w_in_delay_data_in; // adc in 
	assign w_in_delay_data_in[0] = i_data_in_adc0[0];
	assign w_in_delay_data_in[1] = i_data_in_adc0[1];
	assign w_in_delay_data_in[2] = i_data_in_adc1[0];
	assign w_in_delay_data_in[3] = i_data_in_adc1[1];
	assign w_in_delay_data_in[4] = i_data_in_adc2[0];
	assign w_in_delay_data_in[5] = i_data_in_adc2[1];
	assign w_in_delay_data_in[6] = i_data_in_adc3[0];
	assign w_in_delay_data_in[7] = i_data_in_adc3[1];
//
wire [4:0]  w_in_delay_tap_in[0:NUM_IN_DELAY-1];
	assign w_in_delay_tap_in[0] = r_in_delay_tap_serdes0[4:0];
	assign w_in_delay_tap_in[1] = r_in_delay_tap_serdes0[9:5];
	assign w_in_delay_tap_in[2] = r_in_delay_tap_serdes1[4:0];
	assign w_in_delay_tap_in[3] = r_in_delay_tap_serdes1[9:5];
	assign w_in_delay_tap_in[4] = r_in_delay_tap_serdes2[4:0];
	assign w_in_delay_tap_in[5] = r_in_delay_tap_serdes2[9:5];
	assign w_in_delay_tap_in[6] = r_in_delay_tap_serdes3[4:0];
	assign w_in_delay_tap_in[7] = r_in_delay_tap_serdes3[9:5];
//
wire [0:NUM_IN_DELAY-1] w_in_delay_data_out; // delayed out
wire [4:0]  w_in_delay_tap_out[0:NUM_IN_DELAY-1];
//
wire [(5*NUM_IN_DELAY-1):0] w_in_delay_tap_out_aug; // to be connected
	assign w_in_delay_tap_out_aug = {
		w_in_delay_tap_out[7], 
		w_in_delay_tap_out[6], 
		w_in_delay_tap_out[5], 
		w_in_delay_tap_out[4], 
		w_in_delay_tap_out[3], 
		w_in_delay_tap_out[2], 
		w_in_delay_tap_out[1], 
		w_in_delay_tap_out[0]};
//
generate for (in_delay_idx=0; in_delay_idx<NUM_IN_DELAY; in_delay_idx=in_delay_idx+1) begin: in_delays
	//
	(* IODELAY_GROUP = "control_adc_subtop__group" *)
	IDELAYE2 # (
		.CINVCTRL_SEL           ("FALSE"),     // TRUE, FALSE
		.DELAY_SRC              ("IDATAIN"),   // IDATAIN, DATAIN
		.HIGH_PERFORMANCE_MODE  ("FALSE"),     // TRUE, FALSE
		.IDELAY_TYPE            ("VAR_LOAD"),  // FIXED, VARIABLE, or VAR_LOADABLE
		.IDELAY_VALUE           (0),           // 0 to 31
		.REFCLK_FREQUENCY       (200.0),       
		.PIPE_SEL               ("FALSE"),     
		.SIGNAL_PATTERN         ("DATA"))      // CLOCK, DATA
	idelaye2_inst_0 (
		.DATAOUT                (w_in_delay_data_out[in_delay_idx]), // delayed data out
		.DATAIN                 (1'b0),    // Data from FPGA logic // not used
		.C                      (clk_ref_200M), //(clk_div), // loading clock for delay tap (slow clock)
		.CE                     (1'b0), // in_delay_data_ce for inc // not used 
		.INC                    (1'b0), // in_delay_data_inc        // not used 
		.IDATAIN                (w_in_delay_data_in[in_delay_idx]), // Driven by IOB // data in 
		.LD                     (1'b1), // load the tap_in // 1 for using in_delay_tap_in 
		.REGRST                 (w_io_reset),
		.LDPIPEEN               (1'b0),
		.CNTVALUEIN             ( w_in_delay_tap_in[in_delay_idx]),  // in_delay_tap_in
		.CNTVALUEOUT            (w_in_delay_tap_out[in_delay_idx]), // in_delay_tap_out 
		.CINVCTRL               (1'b0) // invert clock pol // not used 
	);
	//
	end
endgenerate
//
////


////
// adc data/clock polarity
//  CMU-CPU-TEST-F5500
//   adc0 adc1 
//   polarity of adc0 : direct
//   polarity of adc1 : inversion
//
//	input wire [1:0]  i_data_in_serdes, // from adc
//	output wire [1:0] o_data_adc_out_pol, // go to serdes 
//   DA D17 ... D03 D01 0 // odd
//   DB D16 ... D02 D00 0 // even
//
//parameter DAT1_OUTPUT_POLARITY = 1'b1; // 1 for inversion
//parameter DAT2_OUTPUT_POLARITY = 1'b0; // 1 for inversion
//parameter DCLK_OUTPUT_POLARITY = 1'b1; // 1 for inversion
parameter DAT1_OUTPUT_POLARITY = 4'b0000; // 1 for inversion
parameter DAT2_OUTPUT_POLARITY = 4'b0000; // 1 for inversion
parameter DCLK_OUTPUT_POLARITY = 4'b0000; // 1 for inversion
//
localparam NUM_ADC = 4; //$$ check for mode
genvar adc_idx;
//
//wire [1:0] w_data_adc_out_pol[0:NUM_ADC-1];
wire [1:0] w_data_adc_out[0:NUM_ADC-1]; //$$
//
generate for (adc_idx=0;adc_idx<NUM_ADC;adc_idx=adc_idx+1) begin: adc
	//
	//$$assign w_data_adc_out_pol[adc_idx][0] = (DAT1_OUTPUT_POLARITY[adc_idx])? 
	//$$		~w_in_delay_data_out[adc_idx*2+0] : 
	//$$		 w_in_delay_data_out[adc_idx*2+0]; // even - DB
	//$$assign w_data_adc_out_pol[adc_idx][1] = (DAT2_OUTPUT_POLARITY[adc_idx])? 
	//$$		~w_in_delay_data_out[adc_idx*2+1] : 
	//$$		 w_in_delay_data_out[adc_idx*2+1]; // odd - DA
	//
	assign w_data_adc_out[adc_idx][0] = 
			 w_in_delay_data_out[adc_idx*2+0]; // even - DB
	assign w_data_adc_out[adc_idx][1] = 
			 w_in_delay_data_out[adc_idx*2+1]; // odd - DA
	//
	end
endgenerate
//
// DCLK_OUTPUT_POLARITY[*]
wire w_clk_in_adc0 = (DCLK_OUTPUT_POLARITY[0])? ~i_clk_in_adc0 : i_clk_in_adc0;
wire w_clk_in_adc1 = (DCLK_OUTPUT_POLARITY[1])? ~i_clk_in_adc1 : i_clk_in_adc1;
wire w_clk_in_adc2 = (DCLK_OUTPUT_POLARITY[2])? ~i_clk_in_adc2 : i_clk_in_adc2;
wire w_clk_in_adc3 = (DCLK_OUTPUT_POLARITY[3])? ~i_clk_in_adc3 : i_clk_in_adc3;
//wire w_clk_in_adc0 = i_clk_in_adc0;
//wire w_clk_in_adc1 = i_clk_in_adc1;
//wire w_clk_in_adc2 = i_clk_in_adc2;
//wire w_clk_in_adc3 = i_clk_in_adc3;
//
////


////
// serdes reg 
//
//  serdes_ddr_2lane_in_20bit_out_nodly.v -- no delay control 
//
//
localparam NUM_SERDES = 4; //$$ mode will touch
genvar serdes_idx;
//
wire [NUM_SERDES-1:0] w_serdes_clk_in;
	assign w_serdes_clk_in[0] = (MODE_ADC_CONTROL[0])? w_clk_in_adc0 : 1'b0;
	assign w_serdes_clk_in[1] = (MODE_ADC_CONTROL[1])? w_clk_in_adc1 : 1'b0;
	assign w_serdes_clk_in[2] = (MODE_ADC_CONTROL[2])? w_clk_in_adc2 : 1'b0;
	assign w_serdes_clk_in[3] = (MODE_ADC_CONTROL[3])? w_clk_in_adc3 : 1'b0;
	//
wire [1:0]   w_serdes_data_in[0:NUM_SERDES-1];
	//$$assign w_serdes_data_in[0] = (MODE_ADC_CONTROL[0])? w_data_adc_out_pol[0] : 2'b0;
	//$$assign w_serdes_data_in[1] = (MODE_ADC_CONTROL[1])? w_data_adc_out_pol[1] : 2'b0;
	//$$assign w_serdes_data_in[2] = (MODE_ADC_CONTROL[2])? w_data_adc_out_pol[2] : 2'b0;
	//$$assign w_serdes_data_in[3] = (MODE_ADC_CONTROL[3])? w_data_adc_out_pol[3] : 2'b0;
	assign w_serdes_data_in[0] = (MODE_ADC_CONTROL[0])? w_data_adc_out[0] : 2'b0;
	assign w_serdes_data_in[1] = (MODE_ADC_CONTROL[1])? w_data_adc_out[1] : 2'b0;
	assign w_serdes_data_in[2] = (MODE_ADC_CONTROL[2])? w_data_adc_out[2] : 2'b0;
	assign w_serdes_data_in[3] = (MODE_ADC_CONTROL[3])? w_data_adc_out[3] : 2'b0;
	//
wire [19:0] w_serdes_data_out[0:NUM_SERDES-1];
wire [19:0] w_serdes_data_out_pre[0:NUM_SERDES-1];
//wire [19:0] w_serdes_data_out_pre_dco[0:NUM_SERDES-1];
//
wire [NUM_SERDES-1:0] w_serdes_en_wr_fifo; // replace en_wr_fifo
//
wire [31:0] w_serdes_cnt_fall_clk_div[0:NUM_SERDES-1]; // replace w_cnt_fall_clk_div
//
//
generate for (serdes_idx=0;serdes_idx<NUM_SERDES;serdes_idx=serdes_idx+1) begin: serdes
	//
	// DDR serdes reg implementation
	serdes_ddr_2lane_in_20bit_out_nodly  serdes_ddr_2lane_in_20bit_out_inst(
		.rst        (w_clk_reset | (~reset_n) | (~MODE_ADC_CONTROL[serdes_idx])),
		.i_data_s   ( w_serdes_data_in[serdes_idx]), // [1:0] 
		.i_dclk     (  w_serdes_clk_in[serdes_idx]), // from adc 
		//$$.o_data_p   (w_serdes_data_out[serdes_idx]), // [19:0] 
		.o_data_p   (w_serdes_data_out_pre[serdes_idx]), // [19:0] 
		.o_dclk_div (),// w_clk_div_serdes), // not used ... use o_en_wr_fifo
		.i_clk_wr_fifo      (clk_fifo), // 62.5MHz external
		.o_en_wr_fifo	    (      w_serdes_en_wr_fifo[serdes_idx]), // fifo wr enable
		.o_cnt_fall_clk_div (w_serdes_cnt_fall_clk_div[serdes_idx]) // [31:0]
	);
	//
	//$$assign w_serdes_data_out[serdes_idx] = w_serdes_data_out_pre[serdes_idx];
	//
	//
	//$$ case of DCLK_OUTPUT_POLARITY[serdes_idx] == 0
	assign w_serdes_data_out[serdes_idx][ 0] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 0] : w_serdes_data_out_pre[serdes_idx][ 0]; // even - DB
	assign w_serdes_data_out[serdes_idx][ 2] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 2] : w_serdes_data_out_pre[serdes_idx][ 2]; // even - DB
	assign w_serdes_data_out[serdes_idx][ 4] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 4] : w_serdes_data_out_pre[serdes_idx][ 4]; // even - DB
	assign w_serdes_data_out[serdes_idx][ 6] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 6] : w_serdes_data_out_pre[serdes_idx][ 6]; // even - DB
	assign w_serdes_data_out[serdes_idx][ 8] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 8] : w_serdes_data_out_pre[serdes_idx][ 8]; // even - DB
	assign w_serdes_data_out[serdes_idx][10] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][10] : w_serdes_data_out_pre[serdes_idx][10]; // even - DB
	assign w_serdes_data_out[serdes_idx][12] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][12] : w_serdes_data_out_pre[serdes_idx][12]; // even - DB
	assign w_serdes_data_out[serdes_idx][14] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][14] : w_serdes_data_out_pre[serdes_idx][14]; // even - DB
	assign w_serdes_data_out[serdes_idx][16] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][16] : w_serdes_data_out_pre[serdes_idx][16]; // even - DB
	assign w_serdes_data_out[serdes_idx][18] = (DAT1_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][18] : w_serdes_data_out_pre[serdes_idx][18]; // even - DB
	//
	assign w_serdes_data_out[serdes_idx][ 1] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 1] : w_serdes_data_out_pre[serdes_idx][ 1]; // odd - DA
	assign w_serdes_data_out[serdes_idx][ 3] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 3] : w_serdes_data_out_pre[serdes_idx][ 3]; // odd - DA
	assign w_serdes_data_out[serdes_idx][ 5] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 5] : w_serdes_data_out_pre[serdes_idx][ 5]; // odd - DA
	assign w_serdes_data_out[serdes_idx][ 7] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 7] : w_serdes_data_out_pre[serdes_idx][ 7]; // odd - DA
	assign w_serdes_data_out[serdes_idx][ 9] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][ 9] : w_serdes_data_out_pre[serdes_idx][ 9]; // odd - DA
	assign w_serdes_data_out[serdes_idx][11] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][11] : w_serdes_data_out_pre[serdes_idx][11]; // odd - DA
	assign w_serdes_data_out[serdes_idx][13] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][13] : w_serdes_data_out_pre[serdes_idx][13]; // odd - DA
	assign w_serdes_data_out[serdes_idx][15] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][15] : w_serdes_data_out_pre[serdes_idx][15]; // odd - DA
	assign w_serdes_data_out[serdes_idx][17] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][17] : w_serdes_data_out_pre[serdes_idx][17]; // odd - DA
	assign w_serdes_data_out[serdes_idx][19] = (DAT2_OUTPUT_POLARITY[serdes_idx])? ~w_serdes_data_out_pre[serdes_idx][19] : w_serdes_data_out_pre[serdes_idx][19]; // odd - DA
	//
	//$$ case of DCLK_OUTPUT_POLARITY[serdes_idx] == 1
	// swap odd even with some delay or not...
	//
	//assign w_serdes_data_out[serdes_idx][ 0] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][ 2] : w_serdes_data_out_pre_dco[serdes_idx][ 0]; 
	//assign w_serdes_data_out[serdes_idx][ 2] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][ 4] : w_serdes_data_out_pre_dco[serdes_idx][ 2]; 
	//assign w_serdes_data_out[serdes_idx][ 4] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][ 6] : w_serdes_data_out_pre_dco[serdes_idx][ 4]; 
	//assign w_serdes_data_out[serdes_idx][ 6] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][ 8] : w_serdes_data_out_pre_dco[serdes_idx][ 6]; 
	//assign w_serdes_data_out[serdes_idx][ 8] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][10] : w_serdes_data_out_pre_dco[serdes_idx][ 8]; 
	//assign w_serdes_data_out[serdes_idx][10] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][12] : w_serdes_data_out_pre_dco[serdes_idx][10]; 
	//assign w_serdes_data_out[serdes_idx][12] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][14] : w_serdes_data_out_pre_dco[serdes_idx][12]; 
	//assign w_serdes_data_out[serdes_idx][14] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][16] : w_serdes_data_out_pre_dco[serdes_idx][14]; 
	//assign w_serdes_data_out[serdes_idx][16] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][18] : w_serdes_data_out_pre_dco[serdes_idx][16]; 
	//assign w_serdes_data_out[serdes_idx][18] = (DCLK_OUTPUT_POLARITY[serdes_idx])? w_serdes_data_out_pre_dco[serdes_idx][18] : w_serdes_data_out_pre_dco[serdes_idx][18]; 
	////
	//assign w_serdes_data_out[serdes_idx][ 1] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][ 3] : w_serdes_data_out_pre_dco[serdes_idx][ 1];
	//assign w_serdes_data_out[serdes_idx][ 3] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][ 5] : w_serdes_data_out_pre_dco[serdes_idx][ 3];
	//assign w_serdes_data_out[serdes_idx][ 5] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][ 7] : w_serdes_data_out_pre_dco[serdes_idx][ 5];
	//assign w_serdes_data_out[serdes_idx][ 7] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][ 9] : w_serdes_data_out_pre_dco[serdes_idx][ 7];
	//assign w_serdes_data_out[serdes_idx][ 9] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][11] : w_serdes_data_out_pre_dco[serdes_idx][ 9];
	//assign w_serdes_data_out[serdes_idx][11] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][13] : w_serdes_data_out_pre_dco[serdes_idx][11];
	//assign w_serdes_data_out[serdes_idx][13] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][15] : w_serdes_data_out_pre_dco[serdes_idx][13];
	//assign w_serdes_data_out[serdes_idx][15] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][17] : w_serdes_data_out_pre_dco[serdes_idx][15];
	//assign w_serdes_data_out[serdes_idx][17] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][19] : w_serdes_data_out_pre_dco[serdes_idx][17];
	//assign w_serdes_data_out[serdes_idx][19] = (DCLK_OUTPUT_POLARITY[serdes_idx])?  w_serdes_data_out_pre_dco[serdes_idx][19] : w_serdes_data_out_pre_dco[serdes_idx][19];
	//
	end
endgenerate
//
//
////


////
// TODO: fifo-hsadc // fifo_generator_2
//   width "18-bit"
//   depth "131072 = 2^17"
//   standard read mode
//
//
wire fifo_adc0_wr_en; // from fifo control
wire fifo_adc1_wr_en; // from fifo control
wire fifo_adc2_wr_en; // from fifo control
wire fifo_adc3_wr_en; // from fifo control
//
wire [17:0] fifo_adc0_din;
wire [17:0] fifo_adc1_din;
wire [17:0] fifo_adc2_din;
wire [17:0] fifo_adc3_din;
//
wire [17:0] w_data_out_fifo_0;
wire [17:0] w_data_out_fifo_1;
wire [17:0] w_data_out_fifo_2;
wire [17:0] w_data_out_fifo_3;
//
assign o_data_out_fifo_0 = (MODE_ADC_CONTROL[0])? w_data_out_fifo_0 : 18'b0;
assign o_data_out_fifo_1 = (MODE_ADC_CONTROL[1])? w_data_out_fifo_1 : 18'b0;
assign o_data_out_fifo_2 = (MODE_ADC_CONTROL[2])? w_data_out_fifo_2 : 18'b0;
assign o_data_out_fifo_3 = (MODE_ADC_CONTROL[3])? w_data_out_fifo_3 : 18'b0;
//
wire w_rd_fifo_0 = (MODE_ADC_CONTROL[0])? i_rd_fifo_0 : 1'b0;
wire w_rd_fifo_1 = (MODE_ADC_CONTROL[1])? i_rd_fifo_1 : 1'b0;
wire w_rd_fifo_2 = (MODE_ADC_CONTROL[2])? i_rd_fifo_2 : 1'b0;
wire w_rd_fifo_3 = (MODE_ADC_CONTROL[3])? i_rd_fifo_3 : 1'b0;
//
//
fifo_generator_2  fifo_generator_2_inst_0 (
	.rst		(~reset_n | ~en | ~MODE_ADC_CONTROL[0] | i_fifo_rst),  // input wire rst 
	.wr_clk		(clk_fifo			),  // input wire wr_clk
	.wr_en		(fifo_adc0_wr_en	),  // input wire wr_en
	.din		(fifo_adc0_din		),  // input wire [17 : 0] din
	.wr_ack		(o_wr_ack_fifo_0	),  // output wire wr_ack
	.overflow	( o_oflow_fifo_0	),  // output wire overflow
	.prog_full	( o_pfull_fifo_0	),  // set at 131072
	.full		(  o_full_fifo_0	),  // output wire full
	//	
	.rd_clk		(clk_bus			),  // input wire rd_clk
	.rd_en		(      w_rd_fifo_0	),  // input wire rd_en
	.dout		(w_data_out_fifo_0	),  // output wire [17 : 0] dout
	.valid		(   o_valid_fifo_0	),  // output wire valid
	.underflow	(   o_uflow_fifo_0	),  // output wire underflow
	.prog_empty	(  o_pempty_fifo_0	),  // set at 8
	.empty		(   o_empty_fifo_0	)   // output wire empty
);
//
fifo_generator_2  fifo_generator_2_inst_1 (
	.rst		(~reset_n | ~en | ~MODE_ADC_CONTROL[1]  | i_fifo_rst),
	.wr_clk		(clk_fifo			),
	.wr_en		(fifo_adc1_wr_en	),
	.din		(fifo_adc1_din		),
	.wr_ack		(o_wr_ack_fifo_1	),
	.overflow	( o_oflow_fifo_1	),
	.prog_full	( o_pfull_fifo_1	),
	.full		(  o_full_fifo_1	),
	//	
	.rd_clk		(clk_bus			),
	.rd_en		(      w_rd_fifo_1	),
	.dout		(w_data_out_fifo_1	),
	.valid		(   o_valid_fifo_1	),
	.underflow	(   o_uflow_fifo_1	),
	.prog_empty	(  o_pempty_fifo_1	),
	.empty		(   o_empty_fifo_1	) 
);

//$$ removed
//$$  fifo_generator_2  fifo_generator_2_inst_2 (
//$$  	.rst		(~reset_n | ~en | ~MODE_ADC_CONTROL[2]),
//$$  	.wr_clk		(clk_fifo			),
//$$  	.wr_en		(fifo_adc2_wr_en	),
//$$  	.din		(fifo_adc2_din		),
//$$  	.wr_ack		(o_wr_ack_fifo_2	),
//$$  	.overflow	( o_oflow_fifo_2	),
//$$  	.prog_full	( o_pfull_fifo_2	),
//$$  	.full		(  o_full_fifo_2	),
//$$  	//	
//$$  	.rd_clk		(clk_bus			),
//$$  	.rd_en		(      w_rd_fifo_2	),
//$$  	.dout		(w_data_out_fifo_2	),
//$$  	.valid		(   o_valid_fifo_2	),
//$$  	.underflow	(   o_uflow_fifo_2	),
//$$  	.prog_empty	(  o_pempty_fifo_2	),
//$$  	.empty		(   o_empty_fifo_2	) 
//$$  );
//$$  //
//$$  fifo_generator_2  fifo_generator_2_inst_3 (
//$$  	.rst		(~reset_n | ~en | ~MODE_ADC_CONTROL[3]),
//$$  	.wr_clk		(clk_fifo			),
//$$  	.wr_en		(fifo_adc3_wr_en	),
//$$  	.din		(fifo_adc3_din		),
//$$  	.wr_ack		(o_wr_ack_fifo_3	),
//$$  	.overflow	( o_oflow_fifo_3	),
//$$  	.prog_full	( o_pfull_fifo_3	),
//$$  	.full		(  o_full_fifo_3	),
//$$  	//	
//$$  	.rd_clk		(clk_bus			),
//$$  	.rd_en		(      w_rd_fifo_3	),
//$$  	.dout		(w_data_out_fifo_3	),
//$$  	.valid		(   o_valid_fifo_3	),
//$$  	.underflow	(   o_uflow_fifo_3	),
//$$  	.prog_empty	(  o_pempty_fifo_3	),
//$$  	.empty		(   o_empty_fifo_3	) 
//$$  );


//
////



////
// variables relating serdes 
// 
//note that 
//   w_serdes_en_wr_fifo[]       replace en_wr_fifo.
//   w_serdes_cnt_fall_clk_div[] replace w_cnt_fall_clk_div.
//
//   new w_serdes_wr_fifo[]     ... replace w_wr_fifo
//   new w_serdes_cnt_wr_fifo[] ... replace w_cnt_wr_fifo 
//
wire                 w_serdes_wr_fifo[0:NUM_SERDES-1];
wire [31:0]      w_serdes_cnt_wr_fifo[0:NUM_SERDES-1];




////
// cnv_adc
//
reg r_cnv_adc; // 
reg r_smp_cnv_adc; // 
reg [BW__ADC_SAMP_PERIOD-1:0] sub_cnt_cnv; //$$
wire [31:0] w_cnt_cnv; //
//
wire w_cnv_adc_en = r_test_busy | r_init_busy | r_update_busy; //
//
wire [BW__ADC_SAMP_PERIOD-1:0] w_period_cnv = r_sampling_period_count; //$$
//
parameter NUM_CNV_INIT = 32'd7; // number of conversion pulses in init mode. 
parameter NUM_FIFO_INIT = 32'd4;
// note (NUM_CNV_INIT-3) fifo data are generated.
parameter NUM_CNV_TEST = 32'd4; // number of conversion pulses in test mode.
parameter NUM_FIFO_TEST = 32'd1;
//
// condition of w_cnt_cnv : activate r_cnv_adc
//
wire check_cnt_cnv__init__adc0 =
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv < NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[0] < NUM_FIFO_INIT ;
wire check_cnt_cnv__init__adc1 = 
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv < NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[1] < NUM_FIFO_INIT ;
wire check_cnt_cnv__init__adc2 = 
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv < NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[2] < NUM_FIFO_INIT ;
wire check_cnt_cnv__init__adc3 = 
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv < NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[3] < NUM_FIFO_INIT ;

wire check_cnt_cnv__init = |{
		check_cnt_cnv__init__adc0 & MODE_ADC_CONTROL[0],
		check_cnt_cnv__init__adc1 & MODE_ADC_CONTROL[1],
		check_cnt_cnv__init__adc2 & MODE_ADC_CONTROL[2],
		check_cnt_cnv__init__adc3 & MODE_ADC_CONTROL[3]};
//
wire check_cnt_cnv__test__adc0 = 
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv < NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[0] < NUM_FIFO_TEST ;
wire check_cnt_cnv__test__adc1 = 
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv < NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[1] < NUM_FIFO_TEST ;
wire check_cnt_cnv__test__adc2 = 
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv < NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[2] < NUM_FIFO_TEST ;
wire check_cnt_cnv__test__adc3 = 
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv < NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[3] < NUM_FIFO_TEST ;

wire check_cnt_cnv__test = |{
		check_cnt_cnv__test__adc0 & MODE_ADC_CONTROL[0],
		check_cnt_cnv__test__adc1 & MODE_ADC_CONTROL[1],
		check_cnt_cnv__test__adc2 & MODE_ADC_CONTROL[2],
		check_cnt_cnv__test__adc3 & MODE_ADC_CONTROL[3]};
//
wire check_cnt_cnv__update__adc0 =
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv < w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[0] < w_num_update_samples ;
wire check_cnt_cnv__update__adc1 =
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv < w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[1] < w_num_update_samples ;
wire check_cnt_cnv__update__adc2 =
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv < w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[2] < w_num_update_samples ;
wire check_cnt_cnv__update__adc3 =
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv < w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[3] < w_num_update_samples ;

wire check_cnt_cnv__update = |{
		check_cnt_cnv__update__adc0 & MODE_ADC_CONTROL[0],
		check_cnt_cnv__update__adc1 & MODE_ADC_CONTROL[1],
		check_cnt_cnv__update__adc2 & MODE_ADC_CONTROL[2],
		check_cnt_cnv__update__adc3 & MODE_ADC_CONTROL[3]};
//
wire check_cnt_cnv = 
	(r_init_busy)? check_cnt_cnv__init :
	(r_test_busy)? check_cnt_cnv__test :
	(r_update_busy)? check_cnt_cnv__update :
	1'b0;
//
// r_cnv_adc was one pulse 8ns @ 125MHz > 5ns 
// r_cnv_adc is two pulses 8ns @ 250MHz > 5ns 
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		sub_cnt_cnv   <= {(BW__ADC_SAMP_PERIOD){1'b0}};
		r_cnv_adc     <= 1'b0;
		r_smp_cnv_adc <= 1'b0;
		end 
	else if (!en) begin
		sub_cnt_cnv   <= {(BW__ADC_SAMP_PERIOD){1'b0}};
		r_cnv_adc     <= 1'b0;
		r_smp_cnv_adc <= 1'b0;
		end 
	else if (w_cnv_adc_en  & check_cnt_cnv) begin
		//
		if (sub_cnt_cnv == 0) begin // start of cnv
			sub_cnt_cnv <= w_period_cnv - 1;
			r_cnv_adc <= 1'b1;
			end
		else begin
			sub_cnt_cnv <= sub_cnt_cnv - 1;
			r_cnv_adc <= 1'b0;
			end
		//
		r_smp_cnv_adc <= r_cnv_adc;
		//
		end
	else begin 
		sub_cnt_cnv   <= {(BW__ADC_SAMP_PERIOD){1'b0}};
		r_cnv_adc     <= 1'b0;
		r_smp_cnv_adc <= 1'b0;
		end
//
//assign o_cnv_adc = r_cnv_adc;
assign o_cnv_adc = r_cnv_adc | r_smp_cnv_adc; // make two pulses 
// note that o_cnv_adc is high 5ns min, and low 8ns min.
wire w_cnv_adc = r_cnv_adc;
//
////



////
// clk_adc
//
reg trig_clk_adc;
//reg [31:0] sub_cnt_clk;
parameter BW__SUB_CNT_CLK = 8; // 32-->8
reg [(BW__SUB_CNT_CLK-1):0] sub_cnt_clk; // 8 bit
//parameter DELAY_CLK = 32'd9; // 65ns min < 8ns*9=72ns @125MHz
// must use PERIOD_CLK_LOGIC_NS
// 65ns min < 8ns*9=72ns @125MHz
// 65ns min < 1/(210MHz)*14=66.7ns @210MHz
parameter DELAY_CLK_NS = 32'd66;
parameter DELAY_CLK = DELAY_CLK_NS/PERIOD_CLK_LOGIC_NS; // delay count of trig_clk_adc	
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		sub_cnt_clk <= {(BW__SUB_CNT_CLK){1'b0}};
		trig_clk_adc <= 1'b0;
		end 
	else begin
		if (sub_cnt_clk == 0) begin
			if (w_cnv_adc == 1) begin
				sub_cnt_clk <= DELAY_CLK - 2;
				trig_clk_adc <= 1'b0;
				end
			else begin
				sub_cnt_clk <= 0;
				trig_clk_adc <= 1'b0;
				end
			end
		else if (sub_cnt_clk == 2) begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b0;
			end
		else if (sub_cnt_clk == 1) begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b1;
			end
		else begin
			sub_cnt_clk <= sub_cnt_clk - 1;
			trig_clk_adc <= 1'b0;
			end
		end
//
reg r_clk_adc; //
reg [4:0] cnt_clk;
parameter LEN_CLK = 5'd9; // 9 slots, 5 pulses
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		cnt_clk <= 5'd0;
		r_clk_adc <= 1'b0;
		end 
	else begin
		if (cnt_clk == 0) begin
			if (trig_clk_adc) begin 
				cnt_clk <= LEN_CLK - 1;
				r_clk_adc <= 1'b1;
				end
			else begin
				cnt_clk <= 5'd0;
				r_clk_adc <= 1'b0;
				end
			end
		else begin
			cnt_clk <= cnt_clk - 1;
			r_clk_adc <= ~r_clk_adc; // generate clk_adc for test 
			end
		end
//
assign o_clk_adc = r_clk_adc;
//
////


////
// cnt_cnv
// monitoring conversion pulses 
//	use: w_cnv_adc
//
// reduce bitwidth for high speed clock: 32bit --> 18bit, 125MHz --> 200MHz
parameter BW__CNT_CNV = 18; // 32-->18
//$$reg [31:0] cnt_cnv;
reg [(BW__CNT_CNV-1):0] cnt_cnv;

//
wire w_cnt_cnv_en = w_cnv_adc & (~w_clk_reset) & (~w_io_reset) & (w_delay_locked);
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		cnt_cnv			<= {(BW__CNT_CNV){1'b0}};
		end 
	else if (!en) begin
		cnt_cnv			<= {(BW__CNT_CNV){1'b0}};
		end 
	else if (w_cnv_adc_en) begin
		//
		if (w_cnt_cnv_en) begin // count w_cnv_adc
			cnt_cnv <= cnt_cnv + 1;
			end
		else begin
			cnt_cnv <= cnt_cnv; // stay
			end
		//
		end
	else begin 
		cnt_cnv			<= {(BW__CNT_CNV){1'b0}};
		end
//
//assign w_cnt_cnv = cnt_cnv;
assign w_cnt_cnv = {{(32-BW__CNT_CNV){1'b0}}, cnt_cnv};
//
////


////
// valid_serdes  r_cnt_trig_clk_adc
//   use: trig_clk_adc, r_io_reset
//   add more staff for handshake with w_delay_locked
//		may use : r_clk_reset for serdes valid 
//		may use : r_io_reset for delay locked 
//   note that it has better use clk_div_serdes rather than clk_adc
//   
reg r_valid_serdes;
reg [7:0] r_cnt_trig_clk_adc;
//
always @(posedge clk_logic, negedge reset_n)
	if (!reset_n) begin
		r_valid_serdes <= 1'b0;
		r_cnt_trig_clk_adc <= 8'b0;
		end 
	else if (!en) begin
		r_valid_serdes <= 1'b0;
		r_cnt_trig_clk_adc <= 8'b0;
		end 
	else begin
		if ( (~r_clk_reset)&(~r_io_reset)&(w_delay_locked) ) begin
			//
			if (trig_clk_adc) begin 
				if (r_cnt_trig_clk_adc < 2) // wait for serdes reg full-filled
					r_cnt_trig_clk_adc <= r_cnt_trig_clk_adc + 1; // count trig after all reset cleared
				else if (r_cnt_trig_clk_adc >= 2) 
					r_valid_serdes <= 1'b1;
				end
			end
			//
		else begin
			r_valid_serdes <= 1'b0;
			r_cnt_trig_clk_adc <= 8'b0;
			end
		end
//
wire w_valid_serdes;
	assign w_valid_serdes = r_valid_serdes;
//
////



////
//wr_fifo  r_serdes_wr_fifo
//  use: r_valid_serdes 
//
reg r_serdes_wr_fifo[0:NUM_SERDES-1];
//
//
wire [NUM_SERDES-1:0] w_wr_fifo_en;
//
//$$ mode will touch
generate for (serdes_idx=0;serdes_idx<NUM_SERDES;serdes_idx=serdes_idx+1) begin: serdes_wr_fifo
	//
	assign w_wr_fifo_en[serdes_idx] =
		(r_init_busy  )? (w_serdes_cnt_wr_fifo[serdes_idx] < NUM_FIFO_INIT) : 
		(r_test_busy  )? (w_serdes_cnt_wr_fifo[serdes_idx] < NUM_FIFO_TEST) : 
		(r_update_busy)? (w_serdes_cnt_wr_fifo[serdes_idx] < w_num_update_samples) : 
		1'b0;
	//
	always @(posedge clk_fifo, negedge reset_n)
		if (!reset_n) begin
			r_serdes_wr_fifo[serdes_idx] <= 1'b0;
			end 
		else if (!en) begin
			r_serdes_wr_fifo[serdes_idx] <= 1'b0;
			end 
		else begin
			//
			if (w_serdes_en_wr_fifo[serdes_idx] & w_valid_serdes) begin
				r_serdes_wr_fifo[serdes_idx] <= (w_wr_fifo_en[serdes_idx])? 1'b1 : 1'b0;
				end
			else begin
				r_serdes_wr_fifo[serdes_idx] <= 1'b0;
				end
			//
			end
	//
	//assign w_serdes_wr_fifo[serdes_idx] = r_serdes_wr_fifo[serdes_idx];
	assign w_serdes_wr_fifo[serdes_idx] = (MODE_ADC_CONTROL[serdes_idx])? r_serdes_wr_fifo[serdes_idx] : 1'b0;
	//
	end
endgenerate
//
//assign o_wr_fifo_0     = r_serdes_wr_fifo[0];
//assign o_wr_fifo_1     = r_serdes_wr_fifo[1];
//assign o_wr_fifo_2     = r_serdes_wr_fifo[2];
//assign o_wr_fifo_3     = r_serdes_wr_fifo[3];
assign o_wr_fifo_0     = w_serdes_wr_fifo[0];
assign o_wr_fifo_1     = w_serdes_wr_fifo[1];
assign o_wr_fifo_2     = w_serdes_wr_fifo[2];
assign o_wr_fifo_3     = w_serdes_wr_fifo[3];
//
// fifo wr_en 
//$$
//assign fifo_adc0_wr_en = (MODE_ADC_CONTROL[0])? r_serdes_wr_fifo[0] : 1'b0;
//assign fifo_adc1_wr_en = (MODE_ADC_CONTROL[1])? r_serdes_wr_fifo[1] : 1'b0;
//assign fifo_adc2_wr_en = (MODE_ADC_CONTROL[2])? r_serdes_wr_fifo[2] : 1'b0;
//assign fifo_adc3_wr_en = (MODE_ADC_CONTROL[3])? r_serdes_wr_fifo[3] : 1'b0;
assign fifo_adc0_wr_en = w_serdes_wr_fifo[0];
assign fifo_adc1_wr_en = w_serdes_wr_fifo[1];
assign fifo_adc2_wr_en = w_serdes_wr_fifo[2];
assign fifo_adc3_wr_en = w_serdes_wr_fifo[3];
//
////


////
// cnt_wr_fifo //$$ mode will touch
// monitoring conversion pulses 
//	use: w_valid_serdes
//
// note : w_wr_fifo --> w_serdes_wr_fifo[]
//
reg [31:0] cnt_wr_fifo[0:NUM_SERDES-1];
wire [NUM_SERDES-1:0] w_cnt_wr_fifo_en;
//
//
generate for (serdes_idx=0;serdes_idx<NUM_SERDES;serdes_idx=serdes_idx+1) begin: serdes_cnt_wr_fifo
	//
	assign w_cnt_wr_fifo_en[serdes_idx] 
		= w_serdes_wr_fifo[serdes_idx] & (~w_clk_reset) & (~w_io_reset) & (w_delay_locked);
	//
	always @(posedge clk_fifo, negedge reset_n)
		if (!reset_n) begin
			cnt_wr_fifo[serdes_idx]	<= 32'd0;
			end 
		else if (!en) begin
			cnt_wr_fifo[serdes_idx]	<= 32'd0;
			end 
		else if (w_valid_serdes) begin
			//
			if (w_cnt_wr_fifo_en[serdes_idx]) begin // count w_wr_fifo
				cnt_wr_fifo[serdes_idx] <= cnt_wr_fifo[serdes_idx] + 1;
				end
			//
			end
		else begin 
			cnt_wr_fifo[serdes_idx]	<= 32'd0;
			end
	//
	assign w_serdes_cnt_wr_fifo[serdes_idx] = cnt_wr_fifo[serdes_idx];
	//
	end
endgenerate
//
//
////

////
// fifo in
//$$
assign fifo_adc0_din = (MODE_ADC_CONTROL[0])? 
	(r_pttn_cnt_up_en)? w_serdes_cnt_wr_fifo[0][17:0] 
		: w_serdes_data_out[0][19:2] 
	: 18'b0;
assign fifo_adc1_din = (MODE_ADC_CONTROL[1])? 
	(r_pttn_cnt_up_en)? w_serdes_cnt_wr_fifo[1][17:0] 
		: w_serdes_data_out[1][19:2] 
	: 18'b0;
assign fifo_adc2_din = (MODE_ADC_CONTROL[2])? 
	(r_pttn_cnt_up_en)? w_serdes_cnt_wr_fifo[2][17:0] 
		: w_serdes_data_out[2][19:2] 
	: 18'b0;
assign fifo_adc3_din = (MODE_ADC_CONTROL[3])? 
	(r_pttn_cnt_up_en)? w_serdes_cnt_wr_fifo[3][17:0] 
		: w_serdes_data_out[3][19:2] 
	: 18'b0;
//
////


////
// r_data_in_fifo 
//
reg [17:0] r_data_in_fifo[0:NUM_SERDES-1]; 
//
generate for (serdes_idx=0;serdes_idx<NUM_SERDES;serdes_idx=serdes_idx+1) begin: serdes_mon
	//
	// monitoring path for adc ddr after serdes
	always @(posedge clk_fifo, negedge reset_n)
		if (!reset_n) begin
			r_data_in_fifo[serdes_idx] <= 18'b0;
			end
		else if (!en || !MODE_ADC_CONTROL[serdes_idx]) begin 
			r_data_in_fifo[serdes_idx] <= 18'b0;
			end
		else if (w_serdes_wr_fifo[serdes_idx]) begin
			r_data_in_fifo[serdes_idx] <= w_serdes_data_out[serdes_idx][19:2];
			end
	//
	end
endgenerate
//
//$$ monitoring
assign o_data_in_fifo_0 = r_data_in_fifo[0];
assign o_data_in_fifo_1 = r_data_in_fifo[1];
assign o_data_in_fifo_2 = r_data_in_fifo[2];
assign o_data_in_fifo_3 = r_data_in_fifo[3];
//
////



////
// adc done conditions //$$ mode will touch
//
wire w_adc_done_init__adc0 =  
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv >= NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[0] >= NUM_FIFO_INIT ;
wire w_adc_done_init__adc1 =  
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv >= NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[1] >= NUM_FIFO_INIT ;
wire w_adc_done_init__adc2 =  
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv >= NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[2] >= NUM_FIFO_INIT ;
wire w_adc_done_init__adc3 =  
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv >= NUM_CNV_INIT - 1:
		w_serdes_cnt_wr_fifo[3] >= NUM_FIFO_INIT ;

wire w_adc_done_init = &{
	w_adc_done_init__adc0 | ~MODE_ADC_CONTROL[0],
	w_adc_done_init__adc1 | ~MODE_ADC_CONTROL[1],
	w_adc_done_init__adc2 | ~MODE_ADC_CONTROL[2],
	w_adc_done_init__adc3 | ~MODE_ADC_CONTROL[3]};
//
wire w_adc_done_update__adc0 = 
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv >= w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[0] >= w_num_update_samples ;
wire w_adc_done_update__adc1 = 
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv >= w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[1] >= w_num_update_samples ;
wire w_adc_done_update__adc2 = 
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv >= w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[2] >= w_num_update_samples ;
wire w_adc_done_update__adc3 = 
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv >= w_num_update_samples + 3:
		w_serdes_cnt_wr_fifo[3] >= w_num_update_samples ;

wire w_adc_done_update = &{
	w_adc_done_update__adc0 | ~MODE_ADC_CONTROL[0],
	w_adc_done_update__adc1 | ~MODE_ADC_CONTROL[1],
	w_adc_done_update__adc2 | ~MODE_ADC_CONTROL[2],
	w_adc_done_update__adc3 | ~MODE_ADC_CONTROL[3]};
//
wire w_adc_done_test__adc0 =
	(w_serdes_cnt_fall_clk_div[0]==0)? 
		w_cnt_cnv >= NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[0] >= NUM_FIFO_TEST ;
wire w_adc_done_test__adc1 =
	(w_serdes_cnt_fall_clk_div[1]==0)? 
		w_cnt_cnv >= NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[1] >= NUM_FIFO_TEST ;
wire w_adc_done_test__adc2 =
	(w_serdes_cnt_fall_clk_div[2]==0)? 
		w_cnt_cnv >= NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[2] >= NUM_FIFO_TEST ;
wire w_adc_done_test__adc3 =
	(w_serdes_cnt_fall_clk_div[3]==0)? 
		w_cnt_cnv >= NUM_CNV_TEST - 1:
		w_serdes_cnt_wr_fifo[3] >= NUM_FIFO_TEST ;

wire w_adc_done_test = &{
	w_adc_done_test__adc0 | ~MODE_ADC_CONTROL[0],
	w_adc_done_test__adc1 | ~MODE_ADC_CONTROL[1],
	w_adc_done_test__adc2 | ~MODE_ADC_CONTROL[2],
	w_adc_done_test__adc3 | ~MODE_ADC_CONTROL[3]};
//
////


////	
// process state 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		state       		<= SEQ_READY;
		//
		r_init_done     	<= 1'b0;
		r_update_done     	<= 1'b0;
		r_test_done     	<= 1'b0;
		//
		r_init_busy     	<= 1'b0;
		r_update_busy     	<= 1'b0;
		r_test_busy     	<= 1'b0;
		//
		r_error				<=1'b0;
		//
		r_num_update_samples	<= INIT_r_num_update_samples;
		r_sampling_period_count	<= INIT_r_sampling_period_count;
		r_in_delay_tap_serdes0	<= INIT_r_in_delay_tap_serdes;
		r_in_delay_tap_serdes1	<= INIT_r_in_delay_tap_serdes;
		r_in_delay_tap_serdes2	<= INIT_r_in_delay_tap_serdes;
		r_in_delay_tap_serdes3	<= INIT_r_in_delay_tap_serdes;
		r_pin_test_frc_high	<= 1'b0;
		r_pin_dlln_frc_low 	<= 1'b0;
		r_pttn_cnt_up_en   	<= 1'b0;
		//
		end 
	else if (!en) begin 
		state <= SEQ_READY;
		end
	else case (state)
		// wait for stable state ... may need more times.
		SEQ_READY : begin
			r_error			<=1'b0;
			if (en) state <= SEQ_START; // wait for en
			end
		// start seq
		SEQ_START : begin
			//
			if (r_init_trig) begin
				r_init_done	<= 1'b0;
				r_init_busy <= 1'b1;
				//
				// load settings 
				r_num_update_samples	<= (i_num_update_samples==0)? 
					r_num_update_samples :
					i_num_update_samples[(BW__NUM_UPD_SAMP-1):0] ;
				r_sampling_period_count	<= (i_sampling_period_count==0)? 
					r_sampling_period_count	:
					i_sampling_period_count[BW__ADC_SAMP_PERIOD-1:0]	;
				//
				r_in_delay_tap_serdes0	<= i_in_delay_tap_serdes0	;
				r_in_delay_tap_serdes1	<= i_in_delay_tap_serdes1	;
				r_in_delay_tap_serdes2	<= i_in_delay_tap_serdes2	;
				r_in_delay_tap_serdes3	<= i_in_delay_tap_serdes3	;
				r_pin_test_frc_high	<= i_pin_test_frc_high;
				r_pin_dlln_frc_low 	<= i_pin_dlln_frc_low ;
				r_pttn_cnt_up_en   	<= i_pttn_cnt_up_en   ;
				//
				state   	<= ST_INIT; 
				end
			//
			else if (r_update_trig) begin
				r_update_done	<= 1'b0;
				r_update_busy	<= 1'b1;
				state   	<= ST_UPDATE; 
				end
			//
			else if (r_test_trig) begin
				r_test_done	<= 1'b0;
				r_test_busy <= 1'b1;
				state   	<= ST_TEST; 
				end
			end
		//
		// init 
		ST_INIT : begin
			//
			if (w_adc_done_init)
				state	<= SEQ_END;
			else 
				state	<= state; // stay init mode 
			end
		//
		// update 
		ST_UPDATE : begin
			//
			if (w_adc_done_update)
				state	<= ST_UPDATE_WAIT;
			else 
				state	<= state; // stay update mode
			end
		//
		ST_UPDATE_WAIT : begin
			//
			if (r_cnt_update_wait==0) 
				state	<= SEQ_END;
			else 
				state	<= state; // wait done
			end
		//
		// test 
		ST_TEST : begin
			//
			if (w_adc_done_test)
				state	<= SEQ_END;
			else 
				state	<= state; // stay test mode 
			end
		//
		// end of seq
		SEQ_END : begin
			// check done 
			if (r_init_busy) begin // init packet was sent!
				r_init_done		<= 1'b1;
				r_init_busy		<= 1'b0;
				end
			if (r_update_busy) begin // update packet was sent!
				r_update_done	<= 1'b1;
				r_update_busy	<= 1'b0;
				end
			if (r_test_busy) begin // test packet was sent!
				r_test_done		<= 1'b1;
				r_test_busy		<= 1'b0;
				end
			//
			state 				<= SEQ_END_WAIT; // return to start of seq
			end
		SEQ_END_WAIT : begin // wait for clearing the previous trigger.
			state <= SEQ_START; // return to start of seq
			end
		default : begin
			state <= SEQ_READY;
			r_error			<=1'b1;
			end
	endcase
//
////
	
endmodule

