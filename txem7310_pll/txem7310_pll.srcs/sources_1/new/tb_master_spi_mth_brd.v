`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_master_spi_mth_brd
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test :  master_spi_mth_brd.v 
// test :  slave_spi_mth_brd.v  test_model__master_spi__from_mth_brd.v
// test :  adc_wrapper.v
//
//////////////////////////////////////////////////////////////////////////////////

module tb_master_spi_mth_brd; //{


//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;

reg clk_144M = 1'b0; // 144MHz
reg clk_72M = 1'b0; // 72MHz
always begin
	#3.47222222;
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	clk_72M = ~clk_72M;
	#3.47222222 
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	end

reg clk_210M = 1'b0; // 210MHz 
	always
	#2.38095238  clk_210M = ~clk_210M; // toggle every 2.38095238 nanoseconds

reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5 ns --> clock 5.0 ns 

reg clk_60M = 1'b0; // 60MHz
	always
	#8.33333333 	clk_60M = ~clk_60M; // toggle every 8ns --> clock 16ns 
	
reg clk_104M = 1'b0; // 104MHz
reg clk_52M  = 1'b0; //  52MHz
reg clk_26M  = 1'b0; //  26MHz
always begin
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	clk_52M  = ~clk_52M ;  // toggle every 1/( 52MHz)/2=9.61538462ns
	clk_26M  = ~clk_26M ;  // toggle every 1/( 26MHz)/2=19.2307692ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	clk_52M  = ~clk_52M ;  // toggle every 1/( 52MHz)/2=9.61538462ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	end
	

reg clk_192M = 1'b0; // 192MHz
reg clk_96M  = 1'b0; //  96MHz
reg clk_48M  = 1'b0; //  48MHz
reg clk_24M  = 1'b0; //  24MHz
reg clk_12M  = 1'b0; //  12MHz
always begin
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	clk_48M  = ~clk_48M ;
	clk_24M  = ~clk_24M ;
	clk_12M  = ~clk_12M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	//
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	clk_48M  = ~clk_48M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	//
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	clk_48M  = ~clk_48M ;
	clk_24M  = ~clk_24M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	//
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	clk_48M  = ~clk_48M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	clk_96M  = ~clk_96M ;
	#2.60416667;
	clk_192M = ~clk_192M;  // toggle every 1/(192MHz)/2=2.60416667ns
	//
	end


//  reg clk_12M = 1'b0; // 12MHz
//  	always
//  	#41.6666667 clk_12M = ~clk_12M;  

wire sys_clk       = clk_10M;
wire base_sspi_clk = clk_104M;
wire mcs_clk       = clk_72M ; // for LAN endpoints   // 72MHz
//
wire base_adc_clk  = clk_210M; // base clock for ADC  // 210MHz
wire adc_fifo_clk  = clk_60M ; // adc fifo clock      // 60MHz
wire ref_200M_clk  = clk_200M;

//wire base_adc_clk = clk_192M; // for MHVSU-BASE
//wire p_adc_clk    = clk_12M;

//}

//// test signals //{
reg test_init;
wire w_done_init;
//
reg test_frame;
reg test_frame_rdwr; // 0 for write, 1 for read
reg [ 9:0] test_adrs;
reg [15:0] test_data;
reg [31:0] test_data_to;
reg [31:0] test_data_to_210M;

//reg [31:0] pattern_MISO;

//}


/* DUT */


//// master_spi_mth_brd //{

//
wire w_SSPI_trig_init  = test_init;
wire w_SSPI_done_init ;
wire w_SSPI_trig_frame = test_frame;
wire w_SSPI_done_frame;
//
wire [ 5:0] w_SSPI_frame_data_C = {1'b0,test_frame_rdwr,4'b0000};
wire [ 9:0] w_SSPI_frame_data_A = test_adrs;
wire [15:0] w_SSPI_frame_data_D = test_data;
wire [15:0] w_SSPI_frame_data_B;
//
wire w_SSPI_SS_B   ;
wire w_SSPI_MCLK   ;
wire w_SSPI_SCLK   ;
wire w_SSPI_MOSI   ;
wire w_SSPI_MISO   ;
wire w_SSPI_MISO_EN;


// master SPI emulation 
master_spi_mth_brd  master_spi_mth_brd__inst (
	.clk     (base_sspi_clk), // 104MHz
	.reset_n (reset_n ),
	
	// control 
	.i_trig_init  (w_SSPI_trig_init ), 
	.o_done_init  (w_SSPI_done_init ), 
	.i_trig_frame (w_SSPI_trig_frame), 
	.o_done_frame (w_SSPI_done_frame), 
	
	// frame data 
	.i_frame_data_C (w_SSPI_frame_data_C), // [ 5:0] // control  data on MOSI
	.i_frame_data_A (w_SSPI_frame_data_A), // [ 9:0] // address  data on MOSI
	.i_frame_data_D (w_SSPI_frame_data_D), // [15:0] // register data on MOSI
	.o_frame_data_B (w_SSPI_frame_data_B), // [15:0] // readback data on MISO

	// IO 
	.o_SS_B       (w_SSPI_SS_B   ),
	.o_MCLK       (w_SSPI_MCLK   ), // sclk master out 
	.i_SCLK       (w_SSPI_SCLK   ), // sclk slave out
	.o_MOSI       (w_SSPI_MOSI   ),
	.i_MISO       (w_SSPI_MISO   ),
	.i_MISO_EN    (w_SSPI_MISO_EN), // not necessary?

	.valid   ()
);

// loopback test 
assign w_SSPI_SCLK = w_SSPI_MCLK;
assign w_SSPI_MISO = w_SSPI_MOSI;
assign w_SSPI_MISO_EN = ~w_SSPI_SS_B;

//}


//// test_model__master_spi__from_mth_brd //{

wire [ 5:0] w_frame_data_C = {1'b0,test_frame_rdwr,4'b0000}; // control  data on MOSI
wire [ 9:0] w_frame_data_A = test_adrs; // address  data on MOSI
wire [15:0] w_frame_data_D = test_data; // register data on MOSI
wire [15:0] w_frame_data_B;             // readback data on MISO
//
wire w_trig_frame = test_frame;
wire w_done_frame;
//
wire w_SS_B;
wire w_SCLK;
wire w_MOSI;
wire w_MISO;
//

// master SPI
test_model__master_spi__from_mth_brd  test_model__master_spi__from_mth_brd__inst (  
	.clk     (clk_26M), // base clock 26MHz
	.reset_n (reset_n),
	.en      (1'b1),
	//
	.i_frame_data_C(w_frame_data_C) , // [ 5:0] // control  data on MOSI
	.i_frame_data_A(w_frame_data_A) , // [ 9:0] // address  data on MOSI
	.i_frame_data_D(w_frame_data_D) , // [15:0] // register data on MOSI
	.o_frame_data_B(w_frame_data_B) , // [15:0] // readback data on MISO
	//
	.i_trig_frame (w_trig_frame), // @ clk
	.o_done_frame (w_done_frame),
	//
	.o_SS_B (w_SS_B),
	.o_SCLK (w_SCLK),
	.o_MOSI (w_MOSI),
	.i_MISO (w_MISO)
);

//}


//// adc test model to come //{

wire w_cnv_adc ; // i
wire w_clk_adc ; // i
wire w_pin_test_adc ; // i
wire w_dco_adc ; // o
wire w_dat1_adc; // o
wire w_dat2_adc; // o

test_model_adc_ddr_two_lane_LTC2387 #(
	.PERIOD_CLK_LOGIC_NS (4.76190476), // ns // for 210MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (8 ), // ns // for 125MHz @ clk_logic
	.PERIOD_CLK_CNV_NS   (57.14285712), // ns // period of test_cnv_adc // 57.14285712=12*4.76190476
	//.PERIOD_CLK_CNV_NS   (96), // ns // period of test_cnv_adc // 96=12*8
	//.PERIOD_CLK_CNV_NS   (88), // ns // period of test_cnv_adc // 88=11*8
	//
	.DELAY_NS_delay_locked(973), // ns // only for simulation // 0 or 973ns
	//
	//parameter DELAY_CLK = 32'd9; // 65ns min < 8ns*9=72ns @125MHz
	//parameter DELAY_CLK = 32'd14; // 65ns min < 1/(210MHz)*14=66.7ns @210MHz
	.DELAY_CLK(14),
	//
	.DAT1_OUTPUT_POLARITY(1'b0),
	.DAT2_OUTPUT_POLARITY(1'b0),
	.DCLK_OUTPUT_POLARITY(1'b0)	
	) test_model_adc_ddr_two_lane_LTC2387_inst (
	.clk_logic	(base_adc_clk), // 210MHz
	.reset_n	(reset_n),
	.en			(1'b1), // test fo connected ADC
	//
	.test					(1'b0), // generate test pattern on dco_adc / dat1_adc / dat2_adc, without external clock.
	.test_cnv_adc			(    ), // o // auto conversion output signal for test 
	.test_clk_adc			(    ), // o // auto conversion output signal for test 
	.test_clk_reset_serdes	(    ), // o // auto clk_reset for serdes
	.test_io_reset_serdes	(    ), // o // auto io_reset for serdes
	.test_valid_fifo		(    ), // o // auto valid for fifo
	//
	.i_cnv_adc	(w_cnv_adc), // trigger input for conversion 
	.i_clk_adc	(w_clk_adc), // clock input for adc data ... connected to dco_adc
	//
	.test_mode_inc_data (~w_pin_test_adc), // increasing data or fixed data
	//
	.dco_adc	(w_dco_adc ),  // o
	.dat1_adc	(w_dat1_adc),  // o
	.dat2_adc	(w_dat2_adc),  // o
	//
	.debug_out	() // o
);

//}


//// adc control to come //{

parameter TEST_num_update_samples    = 32'd136;
parameter TEST_sampling_period_count = 32'd14 ; // 210MHz/14 = 15 Msps //
wire [31:0] w_ADCH_UPD_SM_WI_test = TEST_num_update_samples;
wire [31:0] w_ADCH_SMP_PR_WI_test = TEST_sampling_period_count;
// serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
parameter TEST_in_delay_tap    = 5'd15;
wire [31:0] w_ADCH_DLY_TP_WI_test;
assign w_ADCH_DLY_TP_WI_test[0]     = 1'b0; //wire w_hsadc_pin_test_frc_high = w_ADCH_DLY_TP_WI[0];
assign w_ADCH_DLY_TP_WI_test[1]     = 1'b0; //
assign w_ADCH_DLY_TP_WI_test[2]     = 1'b0; //wire w_hsadc_pttn_cnt_up_en    = w_ADCH_DLY_TP_WI[2];
assign w_ADCH_DLY_TP_WI_test[11: 3] = 9'b0; //
assign w_ADCH_DLY_TP_WI_test[21:12] = { TEST_in_delay_tap, TEST_in_delay_tap };
assign w_ADCH_DLY_TP_WI_test[31:22] = { TEST_in_delay_tap, TEST_in_delay_tap };

// endpoint wires : ADC and DFT
wire [31:0] w_ADCH_WI        ;
wire [31:0] w_ADCH_FREQ_WI   ; // not yet
wire [31:0] w_ADCH_UPD_SM_WI ;
wire [31:0] w_ADCH_SMP_PR_WI ;
wire [31:0] w_ADCH_DLY_TP_WI ;
wire [31:0] w_ADCH_WO        ;  assign w_ADCH_WO[31:20] = 12'b0;  assign w_ADCH_WO[7:4] = 4'b0;
wire [31:0] w_ADCH_B_FRQ_WO  ; // not yet
wire [31:0] w_ADCH_DOUT0_WO  ; // not yet
wire [31:0] w_ADCH_DOUT1_WO  ; // not yet
wire [31:0] w_ADCH_DOUT2_WO  ; // not yet
wire [31:0] w_ADCH_DOUT3_WO  ; // not yet
wire [31:0] w_ADCH_TI        ;
wire [31:0] w_ADCH_TO        ;  assign w_ADCH_TO[31:5] = 27'b0;
wire [31:0] w_ADCH_DOUT0_PO  ;  wire w_ADCH_DOUT0_PO_rd;
wire [31:0] w_ADCH_DOUT1_PO  ;  wire w_ADCH_DOUT1_PO_rd;
wire [31:0] w_DFT_TI         ; // not yet
wire [31:0] w_DFT_COEF_RE_PI ;  wire w_DFT_COEF_RE_PI_wr; // not yet
wire [31:0] w_DFT_COEF_IM_PI ;  wire w_DFT_COEF_IM_PI_wr; // not yet

// control wires
wire        w_hsadc_reset             = w_ADCH_TI[0];  assign w_ADCH_TO[0] = w_hsadc_reset;
wire        w_hsadc_en                = w_ADCH_WI[0];  assign w_ADCH_WO[0] = w_hsadc_en;

wire        w_hsadc_init              = w_ADCH_WI[1] | w_ADCH_TI[1];
wire        w_hsadc_update            = w_ADCH_WI[2] | w_ADCH_TI[2];
wire        w_hsadc_test              = w_ADCH_WI[3] | w_ADCH_TI[3];

wire        w_hsadc_fifo_rst          = w_ADCH_TI[4];  assign w_ADCH_TO[4] = w_hsadc_fifo_rst;

wire        w_hsadc_init_done         ;  assign w_ADCH_WO[1] = w_hsadc_init_done  ;
wire        w_hsadc_update_done       ;  assign w_ADCH_WO[2] = w_hsadc_update_done;
wire        w_hsadc_test_done         ;  assign w_ADCH_WO[3] = w_hsadc_test_done  ;

wire        w_hsadc_init_done_to      ;  assign w_ADCH_TO[1] = w_hsadc_init_done_to  ;
wire        w_hsadc_update_done_to    ;  assign w_ADCH_TO[2] = w_hsadc_update_done_to;
wire        w_hsadc_test_done_to      ;  assign w_ADCH_TO[3] = w_hsadc_test_done_to  ;


wire [31:0] w_HSADC_UPD_SMP           = w_ADCH_UPD_SM_WI;
wire [31:0] w_HSADC_SMP_PRD           = w_ADCH_SMP_PR_WI;

wire [ 9:0] w_HSADC_DLY_TAP0          = w_ADCH_DLY_TP_WI[21:12]; // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
wire [ 9:0] w_HSADC_DLY_TAP1          = w_ADCH_DLY_TP_WI[31:22]; // serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
wire        w_hsadc_pin_test_frc_high = w_ADCH_DLY_TP_WI[0];
wire        w_hsadc_pttn_cnt_up_en    = w_ADCH_DLY_TP_WI[2];

wire [17:0] w_hsadc_fifo_adc0_din     ;  assign w_ADCH_DOUT0_WO = {w_hsadc_fifo_adc0_din , 14'b0};
wire [17:0] w_hsadc_fifo_adc0_dout    ;  assign w_ADCH_DOUT0_PO = {w_hsadc_fifo_adc0_dout, 14'b0};
wire        w_hsadc_fifo_adc0_rd_en   = w_ADCH_DOUT0_PO_rd;
wire        w_hsadc_fifo_adc0_pempty  ;  assign w_ADCH_WO[ 8] = w_hsadc_fifo_adc0_pempty;
wire        w_hsadc_fifo_adc0_empty   ;  assign w_ADCH_WO[ 9] = w_hsadc_fifo_adc0_empty ;
wire        w_hsadc_fifo_adc0_wr_ack  ;  assign w_ADCH_WO[10] = w_hsadc_fifo_adc0_wr_ack;
wire        w_hsadc_fifo_adc0_oflow   ;  assign w_ADCH_WO[11] = w_hsadc_fifo_adc0_oflow ;
wire        w_hsadc_fifo_adc0_pfull   ;  assign w_ADCH_WO[12] = w_hsadc_fifo_adc0_pfull ;
wire        w_hsadc_fifo_adc0_full    ;  assign w_ADCH_WO[13] = w_hsadc_fifo_adc0_full  ;

wire [17:0] w_hsadc_fifo_adc1_din     ;  assign w_ADCH_DOUT1_WO = {w_hsadc_fifo_adc1_din , 14'b0};
wire [17:0] w_hsadc_fifo_adc1_dout    ;  assign w_ADCH_DOUT1_PO = {w_hsadc_fifo_adc1_dout, 14'b0};
wire        w_hsadc_fifo_adc1_rd_en   = w_ADCH_DOUT1_PO_rd;
wire        w_hsadc_fifo_adc1_pempty  ;  assign w_ADCH_WO[14] = w_hsadc_fifo_adc1_pempty;
wire        w_hsadc_fifo_adc1_empty   ;  assign w_ADCH_WO[15] = w_hsadc_fifo_adc1_empty ;
wire        w_hsadc_fifo_adc1_wr_ack  ;  assign w_ADCH_WO[16] = w_hsadc_fifo_adc1_wr_ack;
wire        w_hsadc_fifo_adc1_oflow   ;  assign w_ADCH_WO[17] = w_hsadc_fifo_adc1_oflow ;
wire        w_hsadc_fifo_adc1_pfull   ;  assign w_ADCH_WO[18] = w_hsadc_fifo_adc1_pfull ;
wire        w_hsadc_fifo_adc1_full    ;  assign w_ADCH_WO[19] = w_hsadc_fifo_adc1_full  ;

// io wires
wire   w_hsadc_pin_conv  ;  assign w_cnv_adc      = w_hsadc_pin_conv; //$$
wire   w_hsadc_pin_sclk  ;  assign w_clk_adc      = w_hsadc_pin_sclk; //$$
wire   w_hsadc_pin_test  ;  assign w_pin_test_adc = w_hsadc_pin_test;
wire   w_hsadc_dco__adc_0 = w_dco_adc ;
wire   w_hsadc_dat2_adc_0 = w_dat2_adc;
wire   w_hsadc_dat1_adc_0 = w_dat1_adc;
wire   w_hsadc_dco__adc_1 = w_dco_adc ;
wire   w_hsadc_dat2_adc_1 = w_dat2_adc;
wire   w_hsadc_dat1_adc_1 = w_dat1_adc;

adc_wrapper  adc_wrapper__inst (

	//// clocks and reset //{
	
	.reset_n        (reset_n),	
	.sys_clk        (sys_clk), // 10MHz
	
	// adc related clocks
	.base_adc_clk   (base_adc_clk), // 210MHz
	.adc_fifo_clk   (adc_fifo_clk), // 60MHz
	.ref_200M_clk   (ref_200M_clk), // 200MHz
	
	// endpoint related clock
	.base_sspi_clk  (base_sspi_clk), // 104MHz // for sspi endpoints
	.mcs_clk        (mcs_clk      ), // 72MHz  // for lan  endpoints
	
	//}
	
	//// endpoint controls //{
	
	.i_hsadc_reset              (w_hsadc_reset            ), //        // 
	.i_hsadc_en                 (w_hsadc_en               ), //        // 
	.i_hsadc_init               (w_hsadc_init             ), //        // 
	.i_hsadc_update             (w_hsadc_update           ), //        // 
	.i_hsadc_test               (w_hsadc_test             ), //        // 
	.i_hsadc_fifo_rst           (w_hsadc_fifo_rst         ), //        //  
	.o_hsadc_init_done          (w_hsadc_init_done        ), //        // 
	.o_hsadc_update_done        (w_hsadc_update_done      ), //        // 
	.o_hsadc_test_done          (w_hsadc_test_done        ), //        // 
	.o_hsadc_init_done_to       (w_hsadc_init_done_to     ), //        // 
	.o_hsadc_update_done_to     (w_hsadc_update_done_to   ), //        // 
	.o_hsadc_test_done_to       (w_hsadc_test_done_to     ), //        // 
	.i_HSADC_UPD_SMP            (w_HSADC_UPD_SMP          ), // [31:0] // 
	.i_HSADC_SMP_PRD            (w_HSADC_SMP_PRD          ), // [31:0] // 
	.i_HSADC_DLY_TAP0           (w_HSADC_DLY_TAP0         ), // [ 9:0] // 
	.i_HSADC_DLY_TAP1           (w_HSADC_DLY_TAP1         ), // [ 9:0] // 
	.i_hsadc_pin_test_frc_high  (w_hsadc_pin_test_frc_high), //        // 
	.i_hsadc_pttn_cnt_up_en     (w_hsadc_pttn_cnt_up_en   ), //        // 
	.o_hsadc_fifo_adc0_din      (w_hsadc_fifo_adc0_din    ), // [17:0] // 
	.o_hsadc_fifo_adc0_dout     (w_hsadc_fifo_adc0_dout   ), // [17:0] // 
	.i_hsadc_fifo_adc0_rd_en    (w_hsadc_fifo_adc0_rd_en  ), //        // 
	.o_hsadc_fifo_adc0_pempty   (w_hsadc_fifo_adc0_pempty ), //        // 
	.o_hsadc_fifo_adc0_empty    (w_hsadc_fifo_adc0_empty  ), //        // 
	.o_hsadc_fifo_adc0_wr_ack   (w_hsadc_fifo_adc0_wr_ack ), //        // 
	.o_hsadc_fifo_adc0_oflow    (w_hsadc_fifo_adc0_oflow  ), //        // 
	.o_hsadc_fifo_adc0_pfull    (w_hsadc_fifo_adc0_pfull  ), //        // 
	.o_hsadc_fifo_adc0_full     (w_hsadc_fifo_adc0_full   ), //        // 
	.o_hsadc_fifo_adc1_din      (w_hsadc_fifo_adc1_din    ), // [17:0] // 
	.o_hsadc_fifo_adc1_dout     (w_hsadc_fifo_adc1_dout   ), // [17:0] // 
	.i_hsadc_fifo_adc1_rd_en    (w_hsadc_fifo_adc1_rd_en  ), //        // 
	.o_hsadc_fifo_adc1_pempty   (w_hsadc_fifo_adc1_pempty ), //        // 
	.o_hsadc_fifo_adc1_empty    (w_hsadc_fifo_adc1_empty  ), //        // 
	.o_hsadc_fifo_adc1_wr_ack   (w_hsadc_fifo_adc1_wr_ack ), //        // 
	.o_hsadc_fifo_adc1_oflow    (w_hsadc_fifo_adc1_oflow  ), //        // 
	.o_hsadc_fifo_adc1_pfull    (w_hsadc_fifo_adc1_pfull  ), //        // 
	.o_hsadc_fifo_adc1_full     (w_hsadc_fifo_adc1_full   ), //        // 
	
	//}
	
	//// ios //{

	.o_hsadc_pin_conv    (w_hsadc_pin_conv  ),
	.o_hsadc_pin_sclk    (w_hsadc_pin_sclk  ),
	.o_hsadc_pin_test    (w_hsadc_pin_test  ),
	.i_hsadc_dco__adc_0  (w_hsadc_dco__adc_0),
	.i_hsadc_dat2_adc_0  (w_hsadc_dat2_adc_0),
	.i_hsadc_dat1_adc_0  (w_hsadc_dat1_adc_0),
	.i_hsadc_dco__adc_1  (w_hsadc_dco__adc_1),
	.i_hsadc_dat2_adc_1  (w_hsadc_dat2_adc_1),
	.i_hsadc_dat1_adc_1  (w_hsadc_dat1_adc_1),
	
	//}
	
	// test //{
	.valid    ()
	//}
);



//}


//// slave_spi_mth_brd //{

// slave SPI wires
wire w_MISO_S    ;
wire w_MISO_S_EN ;

wire [31:0] w_port_wi_sadrs_h000;
wire [31:0] w_port_wi_sadrs_h008;
wire [31:0] w_port_wi_sadrs_h060;  assign w_ADCH_WI        = w_port_wi_sadrs_h060;// | ADCH  | ADCH_WI       | 0x060      | wire_in_18 |
wire [31:0] w_port_wi_sadrs_h070;  assign w_ADCH_FREQ_WI   = w_port_wi_sadrs_h070;// | ADCH  | ADCH_FREQ_WI  | 0x070      | wire_in_1C |
wire [31:0] w_port_wi_sadrs_h074;  assign w_ADCH_UPD_SM_WI = w_port_wi_sadrs_h074;// | ADCH  | ADCH_UPD_SM_WI| 0x074      | wire_in_1D |
wire [31:0] w_port_wi_sadrs_h078;  assign w_ADCH_SMP_PR_WI = w_port_wi_sadrs_h078;// | ADCH  | ADCH_SMP_PR_WI| 0x078      | wire_in_1E |
wire [31:0] w_port_wi_sadrs_h07C;  assign w_ADCH_DLY_TP_WI = w_port_wi_sadrs_h07C;// | ADCH  | ADCH_DLY_TP_WI| 0x07C      | wire_in_1F |

wire [31:0] w_port_wo_sadrs_h0E0 = w_ADCH_WO      ;// | ADCH  | ADCH_WO       | 0x0E0      | wireout_38 |
wire [31:0] w_port_wo_sadrs_h0E4 = w_ADCH_B_FRQ_WO;// | ADCH  | ADCH_B_FRQ_WO | 0x0E4      | wireout_39 |
wire [31:0] w_port_wo_sadrs_h0F0 = w_ADCH_DOUT0_WO;// | ADCH  | ADCH_DOUT0_WO | 0x0F0      | wireout_3C |
wire [31:0] w_port_wo_sadrs_h0F4 = w_ADCH_DOUT1_WO;// | ADCH  | ADCH_DOUT1_WO | 0x0F4      | wireout_3D |
wire [31:0] w_port_wo_sadrs_h0F8 = w_ADCH_DOUT2_WO;// | ADCH  | ADCH_DOUT2_WO | 0x0F8      | wireout_3E |
wire [31:0] w_port_wo_sadrs_h0FC = w_ADCH_DOUT3_WO;// | ADCH  | ADCH_DOUT3_WO | 0x0FC      | wireout_3F |
wire [31:0] w_port_wo_sadrs_h080 = 32'hD020_0529;
wire [31:0] w_port_wo_sadrs_h088 = 32'h0000_1010; 
wire [31:0] w_port_wo_sadrs_h380 = 32'h33AA_CC55; // 0x33AACC55

wire [31:0] w_port_ti_sadrs_h160;  assign w_ADCH_TI = w_port_ti_sadrs_h160;// | ADCH  | ADCH_TI       | 0x160      | trig_in_58 |
wire [31:0] w_port_ti_sadrs_h104;

wire [31:0] w_port_to_sadrs_h1E0 = w_ADCH_TO; // | ADCH  | ADCH_TO       | 0x1E0      | trigout_78 |
wire [31:0] w_port_to_sadrs_h194 = test_data_to;
wire [31:0] w_port_to_sadrs_h19C = test_data_to_210M;

wire [31:0] w_port_po_sadrs_h2F0 = w_ADCH_DOUT0_PO; wire w_rd__sadrs_h2F0; assign w_ADCH_DOUT0_PO_rd = w_rd__sadrs_h2F0;// | ADCH  | ADCH_DOUT0_PO | 0x2F0      | pipeout_BC |
wire [31:0] w_port_po_sadrs_h2F4 = w_ADCH_DOUT1_PO; wire w_rd__sadrs_h2F4; assign w_ADCH_DOUT1_PO_rd = w_rd__sadrs_h2F4;// | ADCH  | ADCH_DOUT1_PO | 0x2F4      | pipeout_BD |


//wire w_loopback_en = 1'b1; // loopback mode control on
wire w_loopback_en = 1'b0; // loopback mode control off
//wire w_MISO_one_bit_ahead_en = 1'b1; // MISO one bit ahead mode on 
wire w_MISO_one_bit_ahead_en = 1'b0; // MISO one bit ahead mode off 
//
slave_spi_mth_brd  slave_spi_mth_brd__inst (
	.clk     (base_sspi_clk), // base clock clk_104M
	.reset_n (reset_n),

	//// slave SPI pins:
	.i_SPI_CS_B      (w_SS_B),
	.i_SPI_CLK       (w_SCLK),
	.i_SPI_MOSI      (w_MOSI),
	.o_SPI_MISO      (w_MISO_S   ),
	.o_SPI_MISO_EN   (w_MISO_S_EN), // MISO buffer control

	//// test register interface
	.o_port_wi_sadrs_h000    (w_port_wi_sadrs_h000), // [31:0] // adrs h003~h000
	.o_port_wi_sadrs_h008    (w_port_wi_sadrs_h008),
	.o_port_wi_sadrs_h060    (w_port_wi_sadrs_h060), // ADCH
	.o_port_wi_sadrs_h070    (w_port_wi_sadrs_h070), // ADCH
	.o_port_wi_sadrs_h074    (w_port_wi_sadrs_h074), // ADCH
	.o_port_wi_sadrs_h078    (w_port_wi_sadrs_h078), // ADCH
	.o_port_wi_sadrs_h07C    (w_port_wi_sadrs_h07C), // ADCH
	//
	.i_port_wo_sadrs_h380    (w_port_wo_sadrs_h380), // [31:0] // adrs h383~h380
	.i_port_wo_sadrs_h080    (w_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h088    (w_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h0E0    (w_port_wo_sadrs_h0E0), // ADCH
	.i_port_wo_sadrs_h0E4    (w_port_wo_sadrs_h0E4), // ADCH
	.i_port_wo_sadrs_h0F0    (w_port_wo_sadrs_h0F0), // ADCH
	.i_port_wo_sadrs_h0F4    (w_port_wo_sadrs_h0F4), // ADCH
	.i_port_wo_sadrs_h0F8    (w_port_wo_sadrs_h0F8), // ADCH
	.i_port_wo_sadrs_h0FC    (w_port_wo_sadrs_h0FC), // ADCH
	//
	.i_ck__sadrs_h104(clk_10M ),  .o_port_ti_sadrs_h104(w_port_ti_sadrs_h104),
	.i_ck__sadrs_h160(clk_10M ),  .o_port_ti_sadrs_h160(w_port_ti_sadrs_h160), // ADCH
	//
	.i_ck__sadrs_h194(clk_10M ),  .i_port_to_sadrs_h194(w_port_to_sadrs_h194), // [31:0]
	.i_ck__sadrs_h19C(clk_210M),  .i_port_to_sadrs_h19C(w_port_to_sadrs_h19C), // [31:0]
	.i_ck__sadrs_h1E0(clk_10M ),  .i_port_to_sadrs_h1E0(w_port_to_sadrs_h1E0), // [31:0] // ADCH

	//
	.o_wr__sadrs_h24C (),  .o_port_pi_sadrs_h24C (), // [31:0]  // MEM_PI	0x24C	pi93 //$$
	//
	.o_rd__sadrs_h280 (                ),  .i_port_po_sadrs_h280 (32'h32AB_CD54       ), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	.o_rd__sadrs_h2F0 (w_rd__sadrs_h2F0),  .i_port_po_sadrs_h2F0 (w_port_po_sadrs_h2F0), // ADCH
	.o_rd__sadrs_h2F4 (w_rd__sadrs_h2F4),  .i_port_po_sadrs_h2F4 (w_port_po_sadrs_h2F4), // ADCH
	
	//// loopback mode control 
	.i_loopback_en           (w_loopback_en),


	//// MISO timing control // rev
	
	//.i_slack_count_MISO      (5'd0 ), // [4:0] // '0'  for MISO on SCLK rising edge + 1 + 0  clock delay
	//.i_slack_count_MISO      (5'd1 ), // [4:0] // '1'  for MISO on SCLK rising edge + 1 + 1  clock delay
	//.i_slack_count_MISO      (5'd2 ), // [4:0] // '2'  for MISO on SCLK rising edge + 1 + 2  clock delay
	//.i_slack_count_MISO      (5'd3 ), // [4:0] // '3'  for MISO on SCLK rising edge + 1 + 3  clock delay
	//.i_slack_count_MISO      (5'd4 ), // [4:0] // '4'  for MISO on SCLK rising edge + 1 + 4  clock delay
	.i_slack_count_MISO      (5'd5 ), // [4:0] // '5'  for MISO on SCLK rising edge + 1 + 5  clock delay
	//.i_slack_count_MISO      (5'd6 ), // [4:0] // '6'  for MISO on SCLK rising edge + 1 + 6  clock delay
	//.i_slack_count_MISO      (5'd7 ), // [4:0] // '7'  for MISO on SCLK rising edge + 1 + 7  clock delay
	//.i_slack_count_MISO      (5'd8 ), // [4:0] // '8'  for MISO on SCLK rising edge + 1 + 8  clock delay
	//.i_slack_count_MISO      (5'd9 ), // [4:0] // '9'  for MISO on SCLK rising edge + 1 + 9  clock delay
	//.i_slack_count_MISO      (5'd10), // [4:0] // '10' for MISO on SCLK rising edge + 1 + 10 clock delay
	//.i_slack_count_MISO      (5'd11), // [4:0] // '11' for MISO on SCLK rising edge + 1 + 11 clock delay
	//.i_slack_count_MISO      (5'd12), // [4:0] // '12' for MISO on SCLK rising edge + 1 + 12 clock delay
	//.i_slack_count_MISO      (5'd13), // [4:0] // '13' for MISO on SCLK rising edge + 1 + 13 clock delay
	//.i_slack_count_MISO      (5'd14), // [4:0] // '14' for MISO on SCLK rising edge + 1 + 14 clock delay
	//.i_slack_count_MISO      (5'd15), // [4:0] // '15' for MISO on SCLK rising edge + 1 + 15 clock delay
	//.i_slack_count_MISO      (5'd23), // [4:0] // '15' for MISO on SCLK rising edge + 1 + 15 clock delay
	//.i_slack_count_MISO      (5'd28), // [4:0] // '29' for MISO on SCLK rising edge + 1 + 28 clock delay 
	//.i_slack_count_MISO      (5'd29), // [4:0] // '29' for MISO on SCLK rising edge + 1 + 29 clock delay // outbound of CS
	//.i_slack_count_MISO      (5'd30), // [4:0] // '30' for MISO on SCLK rising edge + 1 + 30 clock delay
	//.i_slack_count_MISO      (5'd31), // [4:0] // '31' for MISO on SCLK rising edge + 1 + 31 clock delay // outbound of CS

	//// MISO timing control 
	//.i_slack_count_MISO      (3'd0), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	//.i_slack_count_MISO      (3'd1), // [2:0] // '1' for MISO on SCLK rising edge + 1 + 1/(72MHz) delay
	//.i_slack_count_MISO      (3'd2), // [2:0] // '2' for MISO on SCLK rising edge + 1 + 2/(72MHz) delay
	//.i_slack_count_MISO      (3'd4), // [2:0] // '4' for MISO on SCLK rising edge + 1 + 4/(72MHz) delay
	//.i_slack_count_MISO      (3'd3), // [2:0] // '3' for MISO on SCLK rising edge + 1 + 4/(72MHz) delay
	//
	.i_MISO_one_bit_ahead_en (w_MISO_one_bit_ahead_en),
	
	//// miso return contents
	.i_board_id      (4'b0110), // [3:0] // slot ID
	.i_board_status  (8'hC5  ), // [7:0] // board status
	

	.valid    () 
);

// MISO buf control
assign w_MISO = (w_MISO_S_EN)?  w_MISO_S : 1'b0;

//}


/* test signals */

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
	test_init 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
	test_init 	= 1'b1;
#200;
	test_init 	= 1'b0;
#200;
	reset_n 	= 1'b0; 
#200;
	reset_n 	= 1'b1; 
#200;
	test_init 	= 1'b1;
#200;
	test_init 	= 1'b0;
end

// test sequence 
initial begin
#0	;
/// test init //{
begin : test_sig__init
	test_frame 		  = 1'b0;
	test_frame_rdwr	  = 1'b0;
	test_adrs         = 10'h000;
	test_data         = 16'h0000;
	test_data_to      = 32'h0000_0000;
	test_data_to_210M = 32'h0000_0000;
	//
	end
#1000;
// wait for w_SSPI_done_init
$display(" Wait for w_SSPI_done_init"); 
@(posedge w_SSPI_done_init)
#200;
///}


//// test frames //{

// write frame setup : done by assignment
#0; 
// frame start
begin : frame_wr__trig__h008
	test_frame_rdwr		= 1'b0; // 0 for write
	test_adrs       = 10'h008;
	test_data       = 16'hA35C;
	#200;
	test_frame 		= 1'b1; 
	#200;
	end 
#200
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//
	test_frame 		= 1'b0; // delayed off
#1000; // long delay test for rise detection... if failed, two frames will be shown...
	//
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_wr__trig__h00A
	test_frame_rdwr		= 1'b0; // 0 for write
	test_adrs       = 10'h00A;
	test_data       = 16'h5A3C;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end 
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_rd__trig__h008
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h008;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_rd__trig__h00A
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h00A;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_rd__trig__h380
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h380;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_rd__trig__h382
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h382;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
//	$finish;
	
#0; 
// frame start
begin : frame_wr__trig__h104
	test_frame_rdwr		= 1'b0; // 0 for write
	test_adrs       = 10'h104;
	test_data       = 16'h2DF3;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end 
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
	$finish;
	

#0; 
//// test trig out
@(posedge sys_clk)
test_data_to = 32'h1010_0101;
@(posedge sys_clk)
test_data_to = 32'h0000_0000;
#200;
//// read trig out - low 16 bits
#0; 
// frame start
begin : frame_rd__trig__h194
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h194;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//// read trig out - high 16 bits
#0; 
// frame start
begin : frame_rd__trig__h196
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h196;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;
	
#0; 
//// test trig out : two pulses long case  //{
@(posedge sys_clk)
test_data_to = 32'h1010_0101;
@(posedge sys_clk)
@(posedge sys_clk)
test_data_to = 32'h0000_0000;
#200;
//// read trig out - low 16 bits
#0; 
// frame start
begin 
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h194;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//// read trig out - high 16 bits
#0; 
// frame start
begin 
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h196;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;
	
	
#0; 
//// test trig out : level signal case  //{
@(posedge sys_clk)
test_data_to = 32'h1010_0101;  // pulse on
#200;
//// read trig out - low 16 bits
#0; 
// frame start
begin 
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h194;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//// read trig out - high 16 bits
#0; 
// frame start
begin 
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h196;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
@(posedge sys_clk)
test_data_to = 32'h0000_0000; // pulse off
#200;
//}
///////////////////////
	$finish;

	
#0; 
//// test trig out //{
@(posedge base_adc_clk)
test_data_to_210M = 32'h1100_1001;
@(posedge base_adc_clk)
test_data_to_210M = 32'h0000_0000;
#200;
//// read trig out
#0; 
// frame start
begin : frame_rd__trig__h19C
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h19C;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;

#0; 
//// test trig out : simultaneous trigout-in and readout //{
// frame start
begin : frame_rd__trig__h19C__simult
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h19C;
	#200;
	@(posedge base_sspi_clk)
	test_frame 		= 1'b1; 
	@(posedge base_adc_clk)
	test_data_to_210M = 32'h0011_0101;
	@(posedge base_adc_clk)
	test_data_to_210M = 32'h0000_0000;
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;

#0; 
//// test pipe out //{
// frame start
begin : frame_rd__trig__h280
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h280;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;
	
#0; 
//// test pipe in //{
// frame start
begin : frame_wr__trig__h24C
	test_frame_rdwr	= 1'b0; // 1/0 for read/write
	test_adrs       = 10'h24C;
	test_data       = 16'hD23F;
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
//}
///////////////////////
	$finish;

#0;
//// adc test to come //{

// adc setup 
TASK__SEND_FRAME(1'b0, 10'h074+2, w_ADCH_UPD_SM_WI_test[31:16]); // w_ADCH_UPD_SM_WI high
TASK__SEND_FRAME(1'b0, 10'h074+0, w_ADCH_UPD_SM_WI_test[15: 0]); // w_ADCH_UPD_SM_WI low
TASK__SEND_FRAME(1'b0, 10'h078+2, w_ADCH_SMP_PR_WI_test[31:16]); // w_ADCH_SMP_PR_WI high
TASK__SEND_FRAME(1'b0, 10'h078+0, w_ADCH_SMP_PR_WI_test[15: 0]); // w_ADCH_SMP_PR_WI low
TASK__SEND_FRAME(1'b0, 10'h07C+2, w_ADCH_DLY_TP_WI_test[31:16]); // w_ADCH_DLY_TP_WI high 
TASK__SEND_FRAME(1'b0, 10'h07C+0, w_ADCH_DLY_TP_WI_test[15: 0]); // w_ADCH_DLY_TP_WI low

// adc enable 
TASK__SEND_FRAME(1'b0, 10'h060, 16'h0001); // ADCH_WI

// adc init 
TASK__SEND_FRAME(1'b0, 10'h160, 16'h0002); // ADCH_TI
@(posedge w_hsadc_init_done);
TASK__SEND_FRAME(1'b1, 10'h1E0, 16'h0000); // ADCH_TO
///////////////////////
	$finish;

// adc fifo reset
TASK__SEND_FRAME(1'b0, 10'h160, 16'h0010); // ADCH_TI
TASK__SEND_FRAME(1'b1, 10'h1E0, 16'h0000); // ADCH_TO
///////////////////////
	$finish;

// adc update
TASK__SEND_FRAME(1'b0, 10'h160, 16'h0004); // ADCH_TI
@(posedge w_hsadc_update_done);
TASK__SEND_FRAME(1'b1, 10'h1E0, 16'h0000); // ADCH_TO
///////////////////////
	$finish;

// adc fifo read
repeat (136+2) begin
TASK__SEND_FRAME(1'b1, 10'h2F0, 16'h0000); // ADCH
end


#200;
//}
///////////////////////
	$finish;
end



//// test tasks //{

//$$ wire [31:0] w_port_wi_sadrs_h01C;  assign w_ADC_CON_WI = w_port_wi_sadrs_h01C;
//$$ wire [31:0] w_port_wi_sadrs_h040;  assign w_ADC_PAR_WI= w_port_wi_sadrs_h040;
//$$ wire [31:0] w_port_ti_sadrs_h11C;  assign w_ADC_TRIG_TI = w_port_ti_sadrs_h11C;
//$$ wire [31:0] w_port_to_sadrs_h19C = test_data_to_210M | w_ADC_TRIG_TO;

// TASK__SEND_FRAME(temp_frame_rdwr_1b, temp_adrs_10b, temp_data_16b)
task  TASK__SEND_FRAME;
	input         temp_frame_rdwr; // 1/0 for read/write
	input  [ 9:0] temp_adrs      ;
	input  [15:0] temp_data      ;
	begin 
		@(posedge sys_clk);
		test_frame_rdwr = temp_frame_rdwr ;
		test_adrs       = temp_adrs       ;
		test_data       = temp_data       ;
		//
		@(posedge sys_clk);
		test_frame 		= 1'b1; 
		@(posedge sys_clk);
		test_frame 		= 1'b0; 
		//
		@(posedge w_done_frame); // wait for frame done 
	end
endtask 

//}

//  // test_MISO
//  always @(negedge w_SCLK) begin : pattern_MISO__gen
//  	if (!reset_n) begin
//  		pattern_MISO <= 32'hAA55_CC33;
//  		end 
//  	else begin
//  		pattern_MISO <= {pattern_MISO[30:0],pattern_MISO[31]};
//  	end
//  end
//  //
//  assign w_MISO = pattern_MISO[31];


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

//}
endmodule
