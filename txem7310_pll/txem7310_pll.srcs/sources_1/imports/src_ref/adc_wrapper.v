//------------------------------------------------------------------------
// adc_wrapper.v
//



`timescale 1ns / 1ps
//$$`default_nettype none



//// TODO: submodule adc_wrapper //{

module adc_wrapper ( //{

	//// controls //{
	
	// for common 
	input  wire        sys_clk , // 10MHz
	input  wire        reset_n ,	
	
	// host core monitoring clock
	input  wire        host_clk, // 140MHz	(or less ... 104MHz possible)

	////// IO bus interface // async for arm io // STM32F767
	//input  wire          i_FMC_NCE ,  // input  wire          // FMC_NCE
	//input  wire [31 : 0] i_FMC_ADD ,  // input  wire [31 : 0] // FMC_ADD
	//input  wire          i_FMC_NOE ,  // input  wire          // FMC_NOE
	//output wire [15 : 0] o_FMC_DRD ,  // output wire [15 : 0] // FMC_DRD
	//input  wire          i_FMC_NWE ,  // input  wire          // FMC_NWE
	//input  wire [15 : 0] i_FMC_DWR ,  // input  wire [15 : 0] // FMC_DWR
	//
	//// IO buffer controls ...
	//output wire [15 : 0] o_FMC_DRD_TRI ,  // output wire [15 : 0] // 1 for tri, 0 for output.

	//}
    
	//// IOs //{
	
	//}

	// test //{
	output wire valid
	//}
	
	);
	
//// valid //{
(* keep = "true" *) 
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


//// call module 
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
	.DAT1_OUTPUT_POLARITY(4'b0000), // set 1 for inversion
	.DAT2_OUTPUT_POLARITY(4'b0000), // set 1 for inversion
	.DCLK_OUTPUT_POLARITY(4'b0000), // set 1 for inversion
	.MODE_ADC_CONTROL    (4'b0011) // enable adc1 adc0
	
	)  control_hsadc_dual__inst(
	
	.clk			(sys_clk), // assume 10MHz or 100ns
	.reset_n		(reset_n & ~w_hsadc_reset & ~w_rst_adc),
	.en				(w_hsadc_en), //
	//
	//.clk_logic		(clk_out4_125M), 
	.clk_logic		(base_adc_clk), 
	//
	.clk_fifo		(adc_fifo_clk), // for fifo write
	//$$.clk_bus		(okClk),         // for fifo read //$$ should be shared with MCS1
	.clk_bus		(c_adc_fifo_read ), // for fifo read //$$ should be shared with MCS1 
	.clk_ref_200M	(ref_200M_clk), // for serdes reference
	//
	//
	.init			(w_hsadc_init	), //
	.update			(w_hsadc_update	), //
	.test			(w_hsadc_test	), //
	//
	.i_fifo_rst		(w_hsadc_fifo_rst), //$$
	//
	.i_num_update_samples		(w_ADC_HS_UPD_SMP), 
	.i_sampling_period_count	(w_ADC_HS_SMP_PRD), 
	//
	//
	.i_in_delay_tap_serdes0		(w_in_delay_tap_serdes0), // ({5'd15,5'd15}),
	.i_in_delay_tap_serdes1		(w_in_delay_tap_serdes1), // ({5'd15,5'd15}),
	//
	.i_pin_test_frc_high		(w_pin_test_frc_high ),
	.i_pin_dlln_frc_low 		(w_pin_dlln_frc_low  ),
	.i_pttn_cnt_up_en   		(w_pttn_cnt_up_en    ),
	//
	.o_cnv_adc				(     w_cnv_adc), //
	.o_clk_adc				(     w_clk_adc), //
	.o_pin_test_adc			(w_pin_test_adc), //
	.o_pin_duallane_adc		( w_pin_dln_adc), //
	//
	//
	 .i_clk_in_adc0		(  w_dco_adc_0),
	.i_data_in_adc0		({w_dat2_adc_0,w_dat1_adc_0}),
	 .i_clk_in_adc1		(  w_dco_adc_1),
	.i_data_in_adc1		({w_dat2_adc_1,w_dat1_adc_1}),	
	//
	//
	 .o_data_in_fifo_0	(fifo_adc0_din		), // monitor //$$ for DFT calc
	 .o_data_in_fifo_1	(fifo_adc1_din		), // monitor //$$ for DFT calc
	 //
	      .o_wr_fifo_0	(fifo_adc0_wr		), // monitor //$$ for DFT calc
	      .o_wr_fifo_1	(fifo_adc1_wr		), // monitor //$$ for DFT calc
	 //
	.o_data_out_fifo_0	(fifo_adc0_dout		), // to endpoint
	      .i_rd_fifo_0	(fifo_adc0_rd_en	), // to endpoint
	   .o_valid_fifo_0	(fifo_adc0_valid	),
	   .o_uflow_fifo_0	(fifo_adc0_uflow	),
	  .o_pempty_fifo_0	(fifo_adc0_pempty	),
	   .o_empty_fifo_0	(fifo_adc0_empty	),
	  .o_wr_ack_fifo_0	(fifo_adc0_wr_ack	),
	   .o_oflow_fifo_0	(fifo_adc0_oflow	),
	   .o_pfull_fifo_0	(fifo_adc0_pfull	),
	    .o_full_fifo_0	(fifo_adc0_full		),
	//
	.o_data_out_fifo_1	(fifo_adc1_dout		), // to endpoint
	      .i_rd_fifo_1	(fifo_adc1_rd_en	), // to endpoint
	   .o_valid_fifo_1	(fifo_adc1_valid	),
	   .o_uflow_fifo_1	(fifo_adc1_uflow	),
	  .o_pempty_fifo_1	(fifo_adc1_pempty	),
	   .o_empty_fifo_1	(fifo_adc1_empty	),
	  .o_wr_ack_fifo_1	(fifo_adc1_wr_ack	),
	   .o_oflow_fifo_1	(fifo_adc1_oflow	),
	   .o_pfull_fifo_1	(fifo_adc1_pfull	),
	    .o_full_fifo_1	(fifo_adc1_full		),
	//
	//
	.init_done		(w_hsadc_init_done	),  //
	.update_done	(w_hsadc_update_done),  //
	.test_done		(w_hsadc_test_done	),  //
	.error			(w_hsadc_error),        //
	.debug_out		()
);


endmodule //}


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
	
wire sys_clk  = clk_10M;
wire host_clk = clk_140M;
wire spi_clk  = clk_104M; 
	
//}


//// DUT //{

reg           r_FMC_NCE ; 
reg  [31 : 0] r_FMC_ADD ; 
reg           r_FMC_NOE ; 
wire [15 : 0] w_FMC_DRD ; 
reg           r_FMC_NWE ; 
reg  [15 : 0] r_FMC_DWR ; 

// wire [31 : 0] w_ep62trig_loopback ;

adc_wrapper  adc_wrapper__inst ();

//  adc_wrapper  adc_wrapper__inst (
//  	
//  	// clock and reset
//  	.clk      (sys_clk  ),
//  	.reset_n  (reset_n  ),
//  	.host_clk (host_clk ), // monitoring async bus signals
//  	
//  	// IO bus interface // async for arm io
//  	.i_FMC_NCE  ( r_FMC_NCE ),  // input  wire          // FMC_NCE
//  	.i_FMC_ADD  ( r_FMC_ADD ),  // input  wire [31 : 0] // FMC_ADD
//  	.i_FMC_NOE  ( r_FMC_NOE ),  // input  wire          // FMC_NOE
//  	.o_FMC_DRD  ( w_FMC_DRD ),  // output wire [31 : 0] // FMC_DRD
//  	.i_FMC_NWE  ( r_FMC_NWE ),  // input  wire          // FMC_NWE
//  	.i_FMC_DWR  ( r_FMC_DWR ),  // input  wire [15 : 0] // FMC_DWR
//  	
//  	// end-points
//  	
//  	//// end-point address offset between high and low 16 bits //{
//  	.ep_offs_hadrs     (32'h0000_0004),  // input wire [31:0]
//  	//}
//  	
//  	//// wire-in //{
//  	.ep00_hadrs(32'h6010_0008),  .ep00wire     (),  // input wire [31:0] // output wire [31:0] // ERR_LED
//  	.ep01_hadrs(32'h6010_0010),  .ep01wire     (),  // input wire [31:0] // output wire [31:0] // FPGA_LED
//  	.ep02_hadrs(32'h6010_0030),  .ep02wire     (),  // input wire [31:0] // output wire [31:0] // H I/F OUT 
//  	.ep03_hadrs(32'h6010_0068),  .ep03wire     (),  // input wire [31:0] // output wire [31:0] // {INTER_LOCK RELAY, INTER_LOCK LED}
//  	.ep04_hadrs(32'h6030_0008),  .ep04wire     (),  // input wire [31:0] // output wire [31:0] // GPIB CONTROL // Control Read & Write     
//  	//
//  	.ep12_hadrs(32'h0000_0000),  .ep12wire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep13_hadrs(32'h0000_0000),  .ep13wire     (),  // input wire [31:0] // output wire [31:0] //
//  	//
//  	.ep16_hadrs(32'h6060_0000),  .ep16wire     (),  // input wire [31:0] // output wire [31:0] // MSPI_EN_CS_WI // {SPI_CH_SELEC, SLOT_CS_MASK}
//  	.ep17_hadrs(32'h6070_0000),  .ep17wire     (),  // input wire [31:0] // output wire [31:0] // MSPI_CON_WI   // {Mx_SPI_MOSI_DATA_H, Mx_SPI_MOSI_DATA_L}
//  	//
//  	.ep1A_hadrs(32'h0000_0000),  .ep1Awire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1B_hadrs(32'h0000_0000),  .ep1Bwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1C_hadrs(32'h0000_0000),  .ep1Cwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1D_hadrs(32'h0000_0000),  .ep1Dwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1E_hadrs(32'h0000_0000),  .ep1Ewire     (),  // input wire [31:0] // output wire [31:0] //	
//  	//}
//  	
//  	//// wire-out //{
//  	.ep20_hadrs(32'h0000_0000),  .ep20wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep21_hadrs(32'h0000_0000),  .ep21wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep22_hadrs(32'h0000_0000),  .ep22wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep23_hadrs(32'h0000_0000),  .ep23wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep24_hadrs(32'h6070_0008),  .ep24wire     (),  // input wire [31:0] // input wire [31:0] // MSPI_FLAG_WO // {Mx_SPI_MISO_DATA_H, Mx_SPI_MISO_DATA_L}
//  	//
//  	.ep30_hadrs(32'h6010_0000),  .ep30wire     (32'h33AA_CC55),  // input wire [31:0] // input wire [31:0] // {MAGIC CODE_H, MAGIC CODE_L}
//  	.ep31_hadrs(32'h6010_0018),  .ep31wire     (),  // input wire [31:0] // input wire [31:0] // MASTER MODE LAN IP Address 
//  	.ep32_hadrs(32'h6010_0020),  .ep32wire     (32'hA021_0805),  // input wire [31:0] // input wire [31:0] // {FPGA_IMAGE_ID_H, FPGA_IMAGE_ID_L}
//  	.ep33_hadrs(32'h6010_0038),  .ep33wire     (),  // input wire [31:0] // input wire [31:0] // H I/F IN
//  	.ep34_hadrs(32'h6010_0040),  .ep34wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#1 FAN SPEED, FAN#0 FAN SPEED}
//  	.ep35_hadrs(32'h6010_0048),  .ep35wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#3 FAN SPEED, FAN#2 FAN SPEED}
//  	.ep36_hadrs(32'h6010_0050),  .ep36wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#5 FAN SPEED, FAN#4 FAN SPEED}
//  	.ep37_hadrs(32'h6010_0058),  .ep37wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#7 FAN SPEED, FAN#6 FAN SPEED}
//  	.ep38_hadrs(32'h6010_0060),  .ep38wire     (),  // input wire [31:0] // input wire [31:0] // INTER_LOCK
//  	.ep39_hadrs(32'h6030_0000),  .ep39wire     (),  // input wire [31:0] // input wire [31:0] // {GPIB Switch Read, GPIB Status Read}
//  	.ep3A_hadrs(32'h0000_0000),  .ep3Awire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep3B_hadrs(32'h0000_0000),  .ep3Bwire     (),  // input wire [31:0] // input wire [31:0] //
//  	//}
//  	
//  	//// trig-in //{
//  	.ep42_hadrs(32'h6070_0010),  .ep42ck       (spi_clk),  .ep42trig   (w_ep62trig_loopback),  // input wire [31:0] // input wire  // output wire [31:0] // MSPI_TI // Mx_SPI_Trig
//  	//
//  	.ep50_hadrs(32'h6010_0028),  .ep50ck       (),  .ep50trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // S/W Reset
//  	.ep51_hadrs(32'h60A0_0000),  .ep51ck       (),  .ep51trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // {PRE_Trig, Trig}
//  	.ep52_hadrs(32'h60A0_0008),  .ep52ck       (),  .ep52trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // SOT
//  	//}
//  	
//  	//// trig-out //{
//  	.ep60_hadrs(32'h0000_0000),  .ep60ck       (       ),  .ep60trig   (                   ),  // input wire [31:0] // input wire  // input wire [31:0] //
//  	.ep62_hadrs(32'h6070_0018),  .ep62ck       (spi_clk),  .ep62trig   (w_ep62trig_loopback),  // input wire [31:0] // input wire  // input wire [31:0] // MSPI_TO // Mx_SPI_DONE
//  	.ep73_hadrs(32'h0000_0000),  .ep73ck       (       ),  .ep73trig   (                   ),  // input wire [31:0] // input wire  // input wire [31:0] //
//  	//}
//  	
//  	//// pipe-in //{
//  	//.ep80_hadrs(),  .ep80wr       (),  .ep80pipe   (),  // input wire [31:0] // output wire  // output wire [31:0]
//  	.ep93_hadrs(32'h6070_00A0),  .ep93wr       (),  .ep93pipe   (), // input wire [31:0] // output wire  // output wire [31:0]
//  	//}
//  	
//  	//// pipe-out //{
//  	//.epA0_hadrs(),  .epA0rd       (),  .epA0pipe   (),  // input wire [31:0] // output wire  // input wire [31:0]
//  	.epB3_hadrs(32'h6070_00A8),  .epB3rd       (),  .epB3pipe   (32'hCA53_3AC5),  // input wire [31:0] // output wire  // input wire [31:0]
//  	//}
//  	
//  	//// pipe-ck //{
//  	.epPPck       (),  // output wire  // sync with write/read of pipe
//  	//}
//  	
//  	// test //{
//  	.valid    ()
//  	//}
//  );

//}


//// test sequence //{

initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

initial begin 
// init
TASK__FMC__IDLE();
//
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;

// test
TASK__FMC__IDLE();
#200;
TASK__FMC__READ (32'h6010_0000); // WO
#200;
TASK__FMC__READ (32'h6010_0004);
#200;
TASK__FMC__READ (32'h6010_0020);
#200;
TASK__FMC__READ (32'h6010_0024);
#200;
TASK__FMC__WRITE(32'h6060_0004, 16'h0003); // WI
#200;
TASK__FMC__WRITE(32'h6060_0000, 16'h1FFF);
#200;
TASK__FMC__WRITE(32'h6070_0004, 16'h4380); // WI
#200;
TASK__FMC__WRITE(32'h6070_0000, 16'h0000);
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0001); // TI
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0002); // TI
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0004); // TI
#200;
TASK__FMC__READ (32'h6070_0018); // TO
#200;
//
TASK__FMC__WRITE(32'h6060_0000, 16'h1FFF); // WI
#200;
TASK__FMC__WRITE(32'h6060_0004, 16'h0003);
#200;
TASK__FMC__READ (32'h6060_0000);
#200;
TASK__FMC__READ (32'h6060_0004);
#200;
//
TASK__FMC__WRITE(32'h6070_00A0+4, 16'h1234); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+0, 16'hABCD); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+4, 16'h5678); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+0, 16'hFEFE); // PI
#200;
// 
TASK__FMC__READ (32'h6070_00A8+4); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+0); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+4); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+0); // PO
#200;
// 

///////////////////////
#200;
$finish;
end 

//}


//// test task //{

// task bus idle
task TASK__FMC__IDLE;
begin
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk);
end 
endtask

// task bus read  (address_32b)
task TASK__FMC__READ;
input [31:0] temp_adrs;
begin
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  --______________---
//    FMC_DRD  xxxDDDDDDDDDDDDDxxx
//    FMC_NWE  -------------------
//    FMC_DWR  -------------------
	@(posedge host_clk); // 0
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b0;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	repeat (13) begin
		@(posedge host_clk); // 1~13
	end
	@(posedge host_clk); // 14
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
end 
endtask

// task bus write (address_32b, data_16b)
task TASK__FMC__WRITE;
input [31:0] temp_adrs;
input [15:0] temp_data;
begin

//// case a // OK
//    idx      --01234567890123---
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  -------------------
//    FMC_DRD  xxxxxxxxxxxxxxxxxxx
//    FMC_NWE  --------_____------
//    FMC_DWR  xxxxxxxxxxxDDDDDxxx

//// case b // rev
//    idx      --01234567890123---
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  -------------------
//    FMC_DRD  xxxxxxxxxxxxxxxxxxx
//    FMC_NWE  --------________---
//    FMC_DWR  xxxxxxxxxxxDDDDDxxx


	@(posedge host_clk); // 0
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk); // 0
	@(posedge host_clk); // 1
	@(posedge host_clk); // 2
	@(posedge host_clk); // 3
	@(posedge host_clk); // 4
	@(posedge host_clk); // 5
	@(posedge host_clk); // 6
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b0;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk); // 7
	@(posedge host_clk); // 8
	@(posedge host_clk); // 9
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b0;
	r_FMC_DWR = temp_data; // set data
	@(posedge host_clk); // 10
	@(posedge host_clk); // 11
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	//r_FMC_NWE =  1'b1; // case a
	r_FMC_NWE =  1'b0; // case b
	r_FMC_DWR = temp_data; // set data
	@(posedge host_clk); // 12
	@(posedge host_clk); // 13
	@(posedge host_clk); // 14
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
end 
endtask


//}

endmodule //}

//}

