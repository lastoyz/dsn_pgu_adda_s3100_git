//------------------------------------------------------------------------
// adc_wrapper.v
//



`timescale 1ns / 1ps
//$$`default_nettype none



//// TODO: submodule adc_wrapper //{

// detec rise edge //{
module detect_rise_edge (
	input  wire  reset_n,
	input  wire  clk    ,
	input  wire  i_sig  ,
	output wire  o_pulse
); 

reg r_sig;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_sig <= 1'b0;
	end
	else begin
		r_sig <= i_sig;
	end	
//
assign o_pulse = (~r_sig) & (i_sig);

endmodule //}


// note: fifo read clock mux 
//       wire c_adc_fifo_read = (w_mcs_ep_po_en)? w_ck_pipe : okClk;
//       lan endpoint pipe clock  vs  usb or sspi endpoint pipe clock

// note: trigger clock ... based on sys_clk

module adc_wrapper ( //{

	//// clocks and reset //{
	
	// for common 
	input  wire        reset_n ,	
	input  wire        sys_clk , // 10MHz
	
	// adc related clocks
	input  wire        base_adc_clk, // 210MHz
	input  wire        adc_fifo_clk, // 60MHz // writing fifo 
	input  wire        ref_200M_clk, // 200MHz
	input  wire        adc_bus_clk , // reading fifo // 104MHz or 72MHz
	
	// endpoint related clock
	input  wire        base_sspi_clk, // 104MHz // for sspi endpoints
	input  wire        mcs_clk      , // 72MHz  // for lan  endpoints
	
	//}
	
	//// endpoint controls //{
	input  wire  i_hsadc_reset   ,
	input  wire  i_hsadc_en      ,
	input  wire  i_hsadc_init    ,
	input  wire  i_hsadc_update  ,
	input  wire  i_hsadc_test    ,
	input  wire  i_hsadc_fifo_rst, 
	
	output wire  o_hsadc_init_done   ,
	output wire  o_hsadc_update_done ,
	output wire  o_hsadc_test_done   ,
	
	output wire  o_hsadc_init_done_to   ,
	output wire  o_hsadc_update_done_to ,
	output wire  o_hsadc_test_done_to   ,

	input  wire [31:0] i_HSADC_UPD_SMP,
	input  wire [31:0] i_HSADC_SMP_PRD,
	
	
	input  wire [ 9:0] i_HSADC_DLY_TAP0,
	input  wire [ 9:0] i_HSADC_DLY_TAP1,
	
	input  wire  i_hsadc_pin_test_frc_high ,
	input  wire  i_hsadc_pttn_cnt_up_en    ,
	
	output wire [17:0] o_hsadc_fifo_adc0_din    ,
	output wire [17:0] o_hsadc_fifo_adc0_dout   ,
	input  wire        i_hsadc_fifo_adc0_rd_en  ,
	output wire        o_hsadc_fifo_adc0_pempty ,
	output wire        o_hsadc_fifo_adc0_empty  ,
	output wire        o_hsadc_fifo_adc0_wr_ack ,
	output wire        o_hsadc_fifo_adc0_oflow  ,
	output wire        o_hsadc_fifo_adc0_pfull  ,
	output wire        o_hsadc_fifo_adc0_full   ,
	
	output wire [17:0] o_hsadc_fifo_adc1_din    ,
	output wire [17:0] o_hsadc_fifo_adc1_dout   ,
	input  wire        i_hsadc_fifo_adc1_rd_en  ,
	output wire        o_hsadc_fifo_adc1_pempty ,
	output wire        o_hsadc_fifo_adc1_empty  ,
	output wire        o_hsadc_fifo_adc1_wr_ack ,
	output wire        o_hsadc_fifo_adc1_oflow  ,
	output wire        o_hsadc_fifo_adc1_pfull  ,
	output wire        o_hsadc_fifo_adc1_full   ,

	//}
    
	//// ios //{
	
	output wire  o_hsadc_pin_conv ,
	output wire  o_hsadc_pin_sclk ,
	output wire  o_hsadc_pin_test ,
	
	input  wire  i_hsadc_dco__adc_0 ,
	input  wire  i_hsadc_dat2_adc_0 ,
	input  wire  i_hsadc_dat1_adc_0 ,
	input  wire  i_hsadc_dco__adc_1 ,
	input  wire  i_hsadc_dat2_adc_1 ,
	input  wire  i_hsadc_dat1_adc_1 ,
	
	//}

	// test //{
	output wire valid
	//}
	
	);
	
//// valid //{
//(* keep = "true" *) 
reg r_valid;
assign valid = r_valid;
//
always @(posedge sys_clk, negedge reset_n)
	if (!reset_n) begin
		r_valid <= 1'b0;
	end
	else begin
		r_valid <= 1'b1;
	end	
//}


//// sampling signals //{

//  
//  (* keep = "true" *) 
//  reg         r_smp_NCE; //{
//  
//  always @(posedge host_clk, negedge reset_n) begin
//      if (!reset_n) begin
//          r_smp_NCE <= 1'b1;
//      end
//      else begin
//          r_smp_NCE <= i_FMC_NCE;
//      end
//  end
//  
//  //}
//  
//  (* keep = "true" *) 
//  reg   [1:0] r_smp_WE_BUS; //{
//  
//  wire w_WE_BUS = i_FMC_NWE | i_FMC_NCE; //$$ check NCE
//  wire w_rise_WE_BUS = (~(r_smp_WE_BUS[1])) & ( (r_smp_WE_BUS[0]));
//  wire w_fall_WE_BUS = ( (r_smp_WE_BUS[1])) & (~(r_smp_WE_BUS[0]));
//  always @(posedge host_clk, negedge reset_n) begin
//      if (!reset_n) begin
//          r_smp_WE_BUS <= 2'b11;
//      end
//      else begin
//          r_smp_WE_BUS <= {r_smp_WE_BUS[0], w_WE_BUS};
//      end
//  end
//  
//  //}
//  
//  (* keep = "true" *) 
//  reg   [1:0] r_smp_OE_BUS; //{
//  
//  wire w_OE_BUS = i_FMC_NOE | i_FMC_NCE; //$$ check NCE
//  wire w_rise_OE_BUS = (~(r_smp_OE_BUS[1])) & ( (r_smp_OE_BUS[0]));
//  wire w_fall_OE_BUS = ( (r_smp_OE_BUS[1])) & (~(r_smp_OE_BUS[0]));
//  always @(posedge host_clk, negedge reset_n) begin
//      if (!reset_n) begin
//          r_smp_OE_BUS <= 2'b11;
//      end
//      else begin
//          r_smp_OE_BUS <= {r_smp_OE_BUS[0], w_OE_BUS};
//      end
//  end
//  
//  //}
//  
//  (* keep = "true" *) 
//  reg  [31:0] r_ADRS_BUS; //{ 
//  
//  reg  [31:0] r_ADRS_BUS__smp;
//  
//  wire [31:0] w_ADRS_BUS = i_FMC_ADD;
//  always @(posedge host_clk, negedge reset_n) begin
//      if (!reset_n) begin
//          r_ADRS_BUS      <= 32'b0;
//          r_ADRS_BUS__smp <= 32'b0;
//      end
//      else begin
//          //r_ADRS_BUS <= ( w_fall_WE_BUS | w_fall_OE_BUS ) ? w_ADRS_BUS : r_ADRS_BUS; // method 0
//  		//r_ADRS_BUS <= ( !r_smp_NCE ) ? w_ADRS_BUS : r_ADRS_BUS; // method 1
//  		// add delay for rise dection 
//  		r_ADRS_BUS__smp <= ( !r_smp_NCE ) ? w_ADRS_BUS : r_ADRS_BUS; // method 1
//  		r_ADRS_BUS      <= r_ADRS_BUS__smp;
//      end
//  end
//  
//  //}
//  
//  (* keep = "true" *) 
//  reg  [15:0] r_DATA_WR; //{
//  
//  reg  [15:0] r_DATA_WR_smp;
//  
//  wire [15:0] w_DATA_WR = i_FMC_DWR;
//  always @(posedge host_clk, negedge reset_n) begin
//      if (!reset_n) begin
//          r_DATA_WR     <= 16'b0;
//          r_DATA_WR_smp <= 16'b0;
//      end
//      else begin
//  		r_DATA_WR_smp <= ( !r_smp_WE_BUS[0] ) ? w_DATA_WR : r_DATA_WR;
//  		r_DATA_WR     <= r_DATA_WR_smp;
//      end
//  end
//  
//  //}
//
  
//}


// fifo pipe read clock 
//wire c_adc_fifo_read = base_sspi_clk; // only for sspi in sim
wire c_adc_fifo_read = adc_bus_clk; 

// DFT interface signals
wire  w_hsadc_fifo_adc0_wr;
wire  w_hsadc_fifo_adc1_wr;


//// call module adc control
control_adc_ddr_two_lane_LTC2387_reg_serdes_dual #( //$$ TODO: adc rev
	//.PERIOD_CLK_LOGIC_NS (5 ), // ns // for 200MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (4 ), // ns // for 250MHz @ clk_logic
	.PERIOD_CLK_LOGIC_NS (4.76190476), // ns // for 210MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (5.5556 ), // ns // for 180MHz @ clk_logic
	//.PERIOD_CLK_LOGIC_NS (5.12820513 ), // ns // for 195MHz @ clk_logic
	//
	//.DELAY_CLK (14), // 65ns min < 5ns*14=70ns @200MHz
	//.DELAY_CLK (17), // 65ns min < 4ns*17=68ns @250MHz
	.DELAY_CLK (14), // 65ns min < 4.76ns*14=66.7ns @210MHz
	//.DELAY_CLK (12), // 65ns min < 5.56ns*12=66.7ns @180MHz
	//.DELAY_CLK (13), // 65ns min < 5.12820513ns*13=66.7ns @195MHz
	//
	.DAT1_OUTPUT_POLARITY(2'b00), // set 1 for inversion
	.DAT2_OUTPUT_POLARITY(2'b00), // set 1 for inversion
	.DCLK_OUTPUT_POLARITY(2'b00), // set 1 for inversion
	.MODE_ADC_CONTROL    (2'b11)  // enable adc1 adc0
	
	)  control_hsadc_dual__inst(
	
	.clk			(sys_clk), // assume 10MHz or 100ns
	.reset_n		(reset_n & ~i_hsadc_reset),
	.en				(i_hsadc_en), //
	//
	.clk_logic		(base_adc_clk), 
	//
	.clk_fifo		(adc_fifo_clk), // for fifo write
	.clk_bus		(c_adc_fifo_read ), // for fifo read //$$ endpoint pipe clock
	.clk_ref_200M	(ref_200M_clk), // for serdes reference

	//
	.init			(i_hsadc_init	), // based on sys_clk 10MHz
	.update			(i_hsadc_update	), // based on sys_clk 10MHz
	.test			(i_hsadc_test	), // based on sys_clk 10MHz
	//
	.i_fifo_rst		(i_hsadc_fifo_rst), //$$
	//
	.i_num_update_samples		(i_HSADC_UPD_SMP), // [31:0] // number of update samples 
	.i_sampling_period_count	(i_HSADC_SMP_PRD), // [31:0] // period count @ base_adc_clk
	//
	.i_in_delay_tap_serdes0		(i_HSADC_DLY_TAP0), // [9:0] 
	.i_in_delay_tap_serdes1		(i_HSADC_DLY_TAP1), // [9:0] 
	//
	.i_pin_test_frc_high		(i_hsadc_pin_test_frc_high ),
	.i_pin_dlln_frc_low 		(1'b1                ), // unused
	.i_pttn_cnt_up_en   		(i_hsadc_pttn_cnt_up_en    ), 

	//
	.o_cnv_adc				(o_hsadc_pin_conv ), //
	.o_clk_adc				(o_hsadc_pin_sclk ), //
	.o_pin_test_adc			(o_hsadc_pin_test ), //
	.o_pin_duallane_adc		(                 ), // unused
	//
	 .i_clk_in_adc0		( i_hsadc_dco__adc_0),
	.i_data_in_adc0		({i_hsadc_dat2_adc_0,i_hsadc_dat1_adc_0}), // [1:0]
	 .i_clk_in_adc1		( i_hsadc_dco__adc_1),
	.i_data_in_adc1		({i_hsadc_dat2_adc_1,i_hsadc_dat1_adc_1}), // [1:0]

	//
	 .o_data_in_fifo_0	(o_hsadc_fifo_adc0_din		), // [17:0] // monitor //$$ for DFT calc
	 .o_data_in_fifo_1	(o_hsadc_fifo_adc1_din		), // [17:0] // monitor //$$ for DFT calc
	 //
	      .o_wr_fifo_0	(w_hsadc_fifo_adc0_wr		), // monitor //$$ for DFT calc
	      .o_wr_fifo_1	(w_hsadc_fifo_adc1_wr		), // monitor //$$ for DFT calc
	 //
	.o_data_out_fifo_0	(o_hsadc_fifo_adc0_dout		), // [17:0] // to endpoint
	      .i_rd_fifo_0	(i_hsadc_fifo_adc0_rd_en	), // to endpoint
	  .o_pempty_fifo_0	(o_hsadc_fifo_adc0_pempty	), // to endpoint
	   .o_empty_fifo_0	(o_hsadc_fifo_adc0_empty	), // to endpoint
	  .o_wr_ack_fifo_0	(o_hsadc_fifo_adc0_wr_ack	), // to endpoint
	   .o_oflow_fifo_0	(o_hsadc_fifo_adc0_oflow	), // to endpoint
	   .o_pfull_fifo_0	(o_hsadc_fifo_adc0_pfull	), // to endpoint
	    .o_full_fifo_0	(o_hsadc_fifo_adc0_full		), // to endpoint
	   .o_valid_fifo_0	(), // unused // fifo_adc0_valid
	   .o_uflow_fifo_0	(), // unused // fifo_adc0_uflow
	//
	.o_data_out_fifo_1	(o_hsadc_fifo_adc1_dout		), // [17:0] // to endpoint
	      .i_rd_fifo_1	(i_hsadc_fifo_adc1_rd_en	), // to endpoint
	  .o_pempty_fifo_1	(o_hsadc_fifo_adc1_pempty	), // to endpoint
	   .o_empty_fifo_1	(o_hsadc_fifo_adc1_empty	), // to endpoint
	  .o_wr_ack_fifo_1	(o_hsadc_fifo_adc1_wr_ack	), // to endpoint
	   .o_oflow_fifo_1	(o_hsadc_fifo_adc1_oflow	), // to endpoint
	   .o_pfull_fifo_1	(o_hsadc_fifo_adc1_pfull	), // to endpoint
	    .o_full_fifo_1	(o_hsadc_fifo_adc1_full		), // to endpoint
	   .o_valid_fifo_1	(), // unused // fifo_adc1_valid
	   .o_uflow_fifo_1	(), // unused // fifo_adc1_uflow
	//
	//
	.init_done		(o_hsadc_init_done	),  //
	.update_done	(o_hsadc_update_done),  //
	.test_done		(o_hsadc_test_done	),  //
	.error			(),                     // unused
	.debug_out		()
);

// generate pulse from done 
detect_rise_edge  detect_rise_edge__inst__init_done (
	.reset_n (reset_n), 
	.clk     (sys_clk),
	.i_sig   (o_hsadc_init_done),
	.o_pulse (o_hsadc_init_done_to)
); 

detect_rise_edge  detect_rise_edge__inst__update_done (
	.reset_n (reset_n), 
	.clk     (sys_clk),
	.i_sig   (o_hsadc_update_done),
	.o_pulse (o_hsadc_update_done_to)
); 

detect_rise_edge  detect_rise_edge__inst__test_done (
	.reset_n (reset_n), 
	.clk     (sys_clk),
	.i_sig   (o_hsadc_test_done),
	.o_pulse (o_hsadc_test_done_to)
); 


endmodule //}


////------------------------------------------------------------------------------------------////

//// testbench
module tb_adc_wrapper (); //{

//// call previous ref module
tb_control_adc_ddr_two_lane_LTC2387_reg_serdes_quad_mode_added  tb_ref__inst();


//// clocks //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 
//
reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_140M = 1'b0; // assume 140MHz or 7.1428571428571ns
	always
	#3.571428571428571 	clk_140M = ~clk_140M; // toggle
//
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

reg clk_210M = 1'b0; // 210Mz
	always
	#2.38095238 	clk_210M = ~clk_210M; // toggle every 2.38095238 ns --> clock 4.76190476 ns 

reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5 ns --> clock 5.0 ns 

reg clk_60M = 1'b0; // 60MHz
	always
	#8.33333333 	clk_60M = ~clk_60M; // toggle every 8ns --> clock 16ns 

reg clk_144M = 1'b0; // 144MHz
reg clk_72M = 1'b0; // 72MHz
always begin
	#3.47222222;
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	clk_72M = ~clk_72M;
	#3.47222222 
	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
	end

// rename
wire sys_clk       = clk_10M ;
wire host_clk      = clk_140M;
wire base_sspi_clk = clk_104M; // base clock for SSPI // 104MHz
wire mcs_clk       = clk_72M ; // for LAN endpoints   // 72MHz
//
wire base_adc_clk  = clk_210M; // base clock for ADC  // 210MHz
wire adc_fifo_clk  = clk_60M ; // adc fifo clock      // 60MHz
wire ref_200M_clk  = clk_200M;
	
//}


//// DUT //{

//// adc test model //{

wire w_test_model_en; // enable test mode without controller
wire w_test_model_trig;

wire w_cnv_adc_mdl; // from model
wire w_clk_adc_mdl; // from model
//
wire w_cnv_adc_ctl; // from control 
wire w_clk_adc_ctl; // from control 
wire w_cnv_adc; // mux
wire w_clk_adc; // mux
	assign w_cnv_adc = (w_test_model_en)? w_cnv_adc_mdl : w_cnv_adc_ctl;
	assign w_clk_adc = (w_test_model_en)? w_clk_adc_mdl : w_clk_adc_ctl;
wire w_pin_test_adc ; // 0 for fixed pattern disabled

wire w_dco_adc ;
wire w_dat1_adc;
wire w_dat2_adc;


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
	.clk_logic	(base_adc_clk), // 
	.reset_n	(reset_n),
	.en			(1'b1), // test fo connected ADC
	//
	.test					(w_test_model_trig), // generate test pattern on dco_adc / dat1_adc / dat2_adc, without external clock.
	.test_cnv_adc			(w_cnv_adc_mdl	  ), // o // auto conversion output signal for test 
	.test_clk_adc			(w_clk_adc_mdl	  ), // o // auto conversion output signal for test 
	.test_clk_reset_serdes	(w_clk_reset_mdl  ), // o // auto clk_reset for serdes
	.test_io_reset_serdes	(w_io_reset_mdl	  ), // o // auto io_reset for serdes
	.test_valid_fifo		(w_valid_fifo_mdl ), // o // auto valid for fifo
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

//// adc control //{

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
wire   w_hsadc_pin_conv  ;  assign w_cnv_adc_ctl  = w_hsadc_pin_conv;
wire   w_hsadc_pin_sclk  ;  assign w_clk_adc_ctl  = w_hsadc_pin_sclk;
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
	.adc_bus_clk    (base_sspi_clk), // no mux // only for simulation
	
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

//}


//// test signals //{

//// test model setup 
reg test_model_en; // adc test without controller
assign w_test_model_en = test_model_en;
reg test_model_trig; // trigger test model
assign w_test_model_trig = test_model_trig;


//// endpoint setup 

parameter TEST_num_update_samples    = 32'd136;
parameter TEST_sampling_period_count = 32'd14 ; // 210MHz/14 = 15 Msps //
assign w_ADCH_UPD_SM_WI = TEST_num_update_samples;
assign w_ADCH_SMP_PR_WI = TEST_sampling_period_count;

// serdes input delay // 5 bits/lane, 2 lanes/ADC // {[9:5],[4:0]} for i_data_in_adc[1:0]
parameter TEST_in_delay_tap    = 5'd15;
assign w_ADCH_DLY_TP_WI[21:12] = { TEST_in_delay_tap, TEST_in_delay_tap };
assign w_ADCH_DLY_TP_WI[31:22] = { TEST_in_delay_tap, TEST_in_delay_tap };
assign w_ADCH_DLY_TP_WI[0]     = 1'b0; //wire w_hsadc_pin_test_frc_high = w_ADCH_DLY_TP_WI[0];
assign w_ADCH_DLY_TP_WI[2]     = 1'b0; //wire w_hsadc_pttn_cnt_up_en    = w_ADCH_DLY_TP_WI[2];

// wire        w_hsadc_en                = w_ADCH_WI[0];  assign w_ADCH_WO[0] = w_hsadc_en;
reg test_hsadc_en;
assign w_ADCH_WI[0] = test_hsadc_en;

reg test_hsadc_init;
assign w_ADCH_WI[1] = 1'b0;
assign w_ADCH_TI[1] = test_hsadc_init;

reg test_hsadc_update;
assign w_ADCH_WI[2] = 1'b0;
assign w_ADCH_TI[2] = test_hsadc_update;

reg test_hsadc_test;
assign w_ADCH_WI[3] = 1'b0;
assign w_ADCH_TI[3] = test_hsadc_test;

// wire        w_hsadc_fifo_rst          = w_ADCH_TI[4];
reg test_hsadc_fifo_rst;
assign w_ADCH_TI[4] = test_hsadc_fifo_rst;

//
reg test_fifo_rd_en;
assign w_ADCH_DOUT0_PO_rd = test_fifo_rd_en;
assign w_ADCH_DOUT1_PO_rd = test_fifo_rd_en;


//}


//// test sequence //{

// reset seq //{
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end
//}

// test mode seq //{
initial begin 
#0;
	test_model_en   = 1'b1;
	test_model_trig = 1'b0;
@(posedge reset_n)
#200;
@(posedge base_adc_clk)
	test_model_trig = 1'b1; // start adc model output
	//
repeat(55) begin // find 55 dco clocks
@(posedge w_dco_adc);
end
	//
//#200;
@(posedge base_adc_clk)
	test_model_trig = 1'b0; // stop adc model output
#200;
	test_model_en   = 1'b0;
end 
//}

// main test seq
initial begin

// init signals
#0;
test_hsadc_en       = 1'b0;
test_hsadc_init     = 1'b0;
test_hsadc_test     = 1'b0;
test_hsadc_update   = 1'b0;
test_hsadc_fifo_rst = 1'b0;
//
test_fifo_rd_en     = 1'b0;


// find reset done 
@(posedge reset_n)
// find test mode done
@(negedge test_model_en)

///////////////////////
#200;
$finish;

//// adc enable 
test_hsadc_en = 1'b1;


//// adc init 
@(posedge sys_clk)
test_hsadc_init   = 1'b1;
@(posedge sys_clk)
test_hsadc_init   = 1'b0;
// find init done 
@(posedge w_hsadc_init_done_to)

///////////////////////
#200;
//$finish;

//// adc test 
@(posedge sys_clk)
test_hsadc_test   = 1'b1;
@(posedge sys_clk)
test_hsadc_test   = 1'b0;
// find done 
@(posedge w_hsadc_test_done_to)

//// adc test 
@(posedge sys_clk)
test_hsadc_test   = 1'b1;
@(posedge sys_clk)
test_hsadc_test   = 1'b0;
// find done 
@(posedge w_hsadc_test_done_to)

///////////////////////
#200;
$finish;

//  //// adc fifo reset
//  @(posedge sys_clk)
//  test_hsadc_fifo_rst   = 1'b1;
//  @(posedge sys_clk)
//  test_hsadc_fifo_rst   = 1'b0;

//// adc update
@(posedge sys_clk)
test_hsadc_update   = 1'b1;
@(posedge sys_clk)
test_hsadc_update   = 1'b0;
// find done 
@(posedge w_hsadc_update_done_to)


//// adc fifo read : 
// test_fifo_rd_en
// w_hsadc_fifo_adc0_empty
@(posedge base_sspi_clk)
test_fifo_rd_en   = 1'b1;
// find done 
@(posedge w_hsadc_fifo_adc0_empty)
@(posedge base_sspi_clk)
test_fifo_rd_en   = 1'b0;

///////////////////////
#200;
$finish;


//// adc init 
@(posedge sys_clk)
test_hsadc_init   = 1'b1;
@(posedge sys_clk)
test_hsadc_init   = 1'b0;
// find init done 
@(posedge w_hsadc_init_done_to)


//// adc fifo reset
@(posedge sys_clk)
test_hsadc_fifo_rst   = 1'b1;
@(posedge sys_clk)
test_hsadc_fifo_rst   = 1'b0;


//// adc update 
@(posedge sys_clk)
test_hsadc_update   = 1'b1;
@(posedge sys_clk)
test_hsadc_update   = 1'b0;
// find done 
@(posedge w_hsadc_update_done_to)


//// adc fifo read
@(posedge base_sspi_clk)
test_fifo_rd_en   = 1'b1;
// find done 
@(posedge w_hsadc_fifo_adc0_empty)
@(posedge base_sspi_clk)
test_fifo_rd_en   = 1'b0;

///////////////////////
#200;
$finish;

//// slave SPI cowork test ... may come



//// test done
test_hsadc_en = 1'b0;

///////////////////////
#200;
$finish;
end 

//}


//// test task //{

// task bus idle
// task TASK__FMC__IDLE;
// begin
// 	r_FMC_NCE =  1'b1;
// 	r_FMC_ADD = 32'b0;
// 	r_FMC_NOE =  1'b1;
// 	r_FMC_NWE =  1'b1;
// 	r_FMC_DWR = 16'b0;
// 	@(posedge host_clk);
// end 
// endtask

//}

endmodule //}

//}

