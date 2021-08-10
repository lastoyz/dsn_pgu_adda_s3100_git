`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module name: 
//    tb_dac_pattern_gen_wrapper
//    tb_dac_pattern_gen_wrapper__dsp
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// DUT name:  
//    dac_pattern_gen_wrapper.v
//
//////////////////////////////////////////////////////////////////////////////////


// testbench for dsp macro only

module tb_dsp48__AP_C ; //{

//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_BUS = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_BUS = ~clk_BUS; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_400M = 1'b0; // 400Mz
	always
	#1.25 	clk_400M = ~clk_400M; // toggle every 1.25ns --> clock 2.5ns 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	

//}

//// reg and wire //{

reg         test_CE ;
reg         test_SEL;
reg  [15:0] test_A  ;
reg  [31:0] test_C  ;
wire [47:0] w_P     ;

//}

/* DUT */ //{

// note: [P=A+P, P=C]

//  xbip_dsp48_macro_APC_b32_0     dsp48__AP_C__inst (
reg_rep__dsp48_macro_APC_b32_0 dsp48__AP_C__inst ( // reg replica
	.CLK   (clk_400M  ),  // input wire CLK   
	.CE    (test_CE   ),  // input wire CE    // active HIGH
	.SCLR  (reset     ),  // input wire SCLR  // active high
	.SEL   (test_SEL  ),  // input wire [0 : 0] SEL
	.A     (test_A    ),  // input wire [15 : 0] A
	.C     (test_C    ),  // input wire [31 : 0] C
	.P     (w_P       )   // output wire [47 : 0] P
);


//}

/* test signaling */ //{

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test sequence 
initial begin
#0	;

// test init
begin : test_sig__init
	//
	test_CE  =  1'b0; //
	test_SEL =  1'b0; //
	test_A   = 16'd00024; //
	test_C   = 32'd00003; //
	//
	end
	
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#20;


//// test 1
@(posedge clk_400M);
	test_A   = 16'd01024; 
	test_C   = 32'd00012;
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = C
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = C


///////////////////////
#20;
$finish;


//// test 2
@(posedge clk_400M);
	test_A   = -16'd01024; // negative 
	test_C   =  32'd00012; 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = C
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = C



///////////////////////
#20;
$finish;


//// test 3
@(posedge clk_400M);
	test_A   = -16'd00001; // negative 
	test_C   =  32'd040_000_000; 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = C
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = C



///////////////////////
#20;
$finish;


//// test 4
@(posedge clk_400M);
	test_A   =  16'd00001; 
	test_C   =  32'd040_000_000; 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = C
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = A+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = C



///////////////////////
#20;
$finish;


//
end

//}

endmodule

//}


module tb_dsp48__CP_A ; //{

//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_BUS = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_BUS = ~clk_BUS; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_400M = 1'b0; // 400Mz
	always
	#1.25 	clk_400M = ~clk_400M; // toggle every 1.25ns --> clock 2.5ns 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	

//}

//// reg and wire //{

reg         test_CE ;
reg         test_SEL;
reg  [15:0] test_A  ;
reg  [15:0] test_C  ;
wire [47:0] w_P     ;

//}

/* DUT */ //{

// note: [P=C+P, P=A]
xbip_dsp48_macro_CPA_b16_0  dsp48__CP_A__inst (
	.CLK   (clk_400M  ),  // input wire CLK   // negative edge
	.CE    (test_CE   ),  // input wire CE    // active HIGH
	.SCLR  (reset     ),  // input wire SCLR  // active high
	.SEL   (test_SEL  ),  // input wire [0 : 0] SEL
	.A     (test_A    ),  // input wire [15 : 0] A
	.C     (test_C    ),  // input wire [15 : 0] C
	.P     (w_P       )   // output wire [47 : 0] P
);

//}

/* test signaling */ //{

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test sequence 
initial begin
#0	;

// test init
begin : test_sig__init
	//
	test_CE  =  1'b0; //
	test_SEL =  1'b0; //
	test_A   = 16'd00024; //
	test_C   = 16'd00003; //
	//
	end
	
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#20;


//// test 1
@(posedge clk_400M);
	test_A   = 16'd01024; 
	test_C   = 16'd00012;
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = A
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = A

//@(posedge clk_400M);
//	test_CE  =  1'b1; //
//	test_SEL =  1'b1; // for P = A

///////////////////////
#20;
$finish;


//// test 2
@(posedge clk_400M);
	test_A   = 16'd01024; 
	test_C   = -16'd00012; // negative 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = A
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = A



///////////////////////
#20;
$finish;


//// test 3
@(posedge clk_400M);
	test_A   = 16'd00024; 
	test_C   = -16'd00012; // negative 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = A
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = A



///////////////////////
#20;
$finish;


//// test 4
@(posedge clk_400M);
	test_A   = 16'd00024; 
	test_C   = -16'd00012; // negative 
	test_CE  =  1'b1; //
	test_SEL =  1'b1; // for P = A
	
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P
		
@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b1; //
	test_SEL =  1'b0; // for P = C+P

@(posedge clk_400M);
	test_CE  =  1'b0; //
	test_SEL =  1'b1; // for P = A



///////////////////////
#20;
$finish;


//
end

//}

endmodule
//}


////---- ================================================================ ----////

// testbench for dac pattern using dsp macro 
module tb_dac_pattern_gen_wrapper__dsp ; //{

//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_BUS = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_BUS = ~clk_BUS; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_400M = 1'b0; // 400Mz
	always
	#1.25 	clk_400M = ~clk_400M; // toggle every 1.25ns --> clock 2.5ns 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	

//}

//// reg and wire //{
reg test_reset;
//
reg [31:0] r_trig_dacz_ctrl;
reg [31:0] r_wire_dacz_data;

//// fifo test 

//
reg [31:0] test_dacz_fifo_in_datinc0; // new control
reg [31:0] test_dacz_fifo_in_dur0   ; // new control
reg [31:0] test_dacz_fifo_in_datinc1; // new control
reg [31:0] test_dacz_fifo_in_dur1   ; // new control
reg        test_dacz_fifo_in_wr     ; // new control
reg        test_dacz_fifo_out_rd    ; // new control

//
wire       w_dac0_active_dco;
wire       w_dac1_active_dco;
wire       w_dac0_active_clk;
wire       w_dac1_active_clk;



//}


/* DUT */ //{

dac_pattern_gen_wrapper__dsp  dac_pattern_gen_wrapper__inst (

	// clock / reset
	.clk                (clk_10M), // 
	.reset_n            (reset_n),
	
	// DAC clock / reset
	.i_clk_dac0_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac0_dco    (reset_n & ~test_reset), //
	.i_clk_dac1_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac1_dco    (reset_n & ~test_reset), //
	
	// DACZ control port
	.i_trig_dacz_ctrl   (r_trig_dacz_ctrl), // [31:0]
	.i_wire_dacz_data   (r_wire_dacz_data), // [31:0]
	.o_wire_dacz_data   (), // [31:0]
	
	// DACZ fifo port // new control // from MCS or USB
	.i_dac0_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_datinc_din      (test_dacz_fifo_in_datinc0), // [31:0]
	.i_dac0_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_dur____din      (test_dacz_fifo_in_dur0   ), // [31:0]
	.i_dac1_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_datinc_din      (test_dacz_fifo_in_datinc1), // [31:0]
	.i_dac1_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_dur____din      (test_dacz_fifo_in_dur1   ), // [31:0]
	//
	.i_dac0_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	.i_dac1_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	
	// DAC data output port 
	.o_dac0_data_pin    (), // [15:0]
	.o_dac1_data_pin    (), // [15:0]

	// DAC activity flag
	.o_dac0_active_dco  (w_dac0_active_dco),
	.o_dac1_active_dco  (w_dac1_active_dco),
	.o_dac0_active_clk  (w_dac0_active_clk),
	.o_dac1_active_clk  (w_dac1_active_clk),
	
	// flag
	.valid              ()

);


// ref
dac_pattern_gen_wrapper  dac_pattern_gen_wrapper__ref__inst (

	// clock / reset
	.clk                (clk_10M), // 
	.reset_n            (reset_n),
	
	// DAC clock / reset
	.i_clk_dac0_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac0_dco    (reset_n & ~test_reset), //
	.i_clk_dac1_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac1_dco    (reset_n & ~test_reset), //
	
	// DACZ control port
	.i_trig_dacz_ctrl   (r_trig_dacz_ctrl), // [31:0]
	.i_wire_dacz_data   (r_wire_dacz_data), // [31:0]
	.o_wire_dacz_data   (), // [31:0]
	
	// DACZ fifo port // new control // from MCS or USB
	.i_dac0_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_datinc_din      (test_dacz_fifo_in_datinc0), // [31:0]
	.i_dac0_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_dur____din      (test_dacz_fifo_in_dur0   ), // [31:0]
	.i_dac1_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_datinc_din      (test_dacz_fifo_in_datinc1), // [31:0]
	.i_dac1_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_dur____din      (test_dacz_fifo_in_dur1   ), // [31:0]
	//
	.i_dac0_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	.i_dac1_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	
	// DAC data output port 
	.o_dac0_data_pin    (), // [15:0]
	.o_dac1_data_pin    (), // [15:0]

	// DAC activity flag
	.o_dac0_active_dco  (),
	.o_dac1_active_dco  (),
	.o_dac0_active_clk  (),
	.o_dac1_active_clk  (),
	
	// flag
	.valid              ()

);

//}


/* test signaling */ //{

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test sequence 
initial begin
#0	;
// test init
begin : test_sig__init
	test_reset 		= 1'b0;
	//
	r_trig_dacz_ctrl = 32'b0;
	r_wire_dacz_data = 32'b0;
	//

	//
	test_dacz_fifo_in_datinc0 = 32'b0; //
	test_dacz_fifo_in_dur0    = 32'b0; //
	test_dacz_fifo_in_datinc1 = 32'b0; //
	test_dacz_fifo_in_dur1    = 32'b0; //
	test_dacz_fifo_in_wr      =  1'b0; //
	test_dacz_fifo_out_rd     =  1'b0; //
	
	//
	end
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;
// test reset //{
begin : test_reset__gen
	test_reset 		= 1'b1; 
	#200;
	test_reset 		= 1'b0; 
	end
//}


///////////////////////
#200;
//$finish;


//// TODO: CID test //{

// test r_cid_reg_adrs
CID_ADRS_WR(32'h_0000_0000);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0010);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0020);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0030);
CID_ADRS_RD();
#200;

// test r_cid_reg_ctrl
CID_CTRL_WR(32'h_0000_0003);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_000C);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_0030);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_0000);
CID_CTRL_RD();
#200;

// test w_cid_reg_stat
CID_STAT_RD();
#200;

// test r_cid_reg_dac*_bias_code
CID_DAC0_BIAS_WR(32'h_0000_0123);
CID_DAC0_BIAS_RD();
#200;
CID_DAC1_BIAS_WR(32'h_0000_01AB);
CID_DAC1_BIAS_RD();
#200;

// test r_cid_reg_dac*_num_repeat
CID_DAC0_REPEAT_WR(32'h_0000_0003);
CID_DAC0_REPEAT_RD();
#200;
CID_DAC1_REPEAT_WR(32'h_0000_0004);
CID_DAC1_REPEAT_RD();
#200;

// test cid regs
//DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_7FFF_0010);
//DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
//DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_8000_0010);
//DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
//
//DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_7FFF_0004);
//DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
//DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_8000_0004);
//DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
//
CID_DAC0_SEQ_WR(0,32'h_3FFF_0080,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(1,32'h_7FFF_FF80,32'h_0000_0010); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(2,32'h_3FFF_FF80,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(3,32'h_0000_FFFF,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(4,32'h_C000_FF80,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(5,32'h_8000_0080,32'h_0000_0010); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(6,32'h_C000_0080,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(7,32'h_0000_0001,32'h_0000_0004); // idx, dat_inc, dur
#200;
//
CID_DAC1_SEQ_WR(0,32'h_3FFF_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(1,32'h_7FFF_0000,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(2,32'h_3FFF_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(3,32'h_0000_0000,32'h_0000_0001); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(4,32'h_C000_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(5,32'h_8000_0000,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(6,32'h_C000_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(7,32'h_0000_0000,32'h_0000_0001); // idx, dat_inc, dur
#200;
//


//// test run 1
CID_DAC0_REPEAT_WR(32'h_0000_0000);
CID_DAC1_REPEAT_WR(32'h_0000_0000);
#200;
CID_SEQ_TEST_RUN();
#1000;
CID_SEQ_TEST_STOP();


//// test run 2
CID_DAC0_REPEAT_WR(32'h_0000_0001);
CID_DAC1_REPEAT_WR(32'h_0000_0004);
#200;
CID_SEQ_TEST_RUN();
#1000;
CID_SEQ_TEST_STOP();


//}

///////////////////////
#200;
//$finish;

//// FCID test //{

// test fifo setup 1 //{

// short interval test

// cnt_duration,    rd_en  ...  expected
//                        
// 3FFF_0000  XXXX  H
// 7FFF_0000  XXXX  H
// 3FFF_0001  XXXX  L
//            0000  H
// FFFE_0002  XXXX  L
//            0001  L
//            0000  H
// C000_0002  XXXX  L
//            0001  L
//            0000  H
// 8000_0001  XXXX  L
//            0000  H
// C000_0000  0000  H
// 0001_0000  XXXX  H
//            XXXX  

////---- CID ---////
CID_FIFO_RESET();
//
FIFO_IN_CID_DATA(32'h_3FFF_0000, 32'h_0000_0000,  32'h_3FFF_0080, 32'h_0000_0008); // (datinc0, dur0,  datinc1, dur1)
FIFO_IN_CID_DATA(32'h_7FFF_0000, 32'h_0000_0000,  32'h_7FFF_FF80, 32'h_0000_0010);
FIFO_IN_CID_DATA(32'h_3FFF_0000, 32'h_0000_0001,  32'h_3FFF_FF80, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_FFFE_0000, 32'h_0000_0002,  32'h_0000_FFFF, 32'h_0000_0004);
FIFO_IN_CID_DATA(32'h_C000_0000, 32'h_0000_0002,  32'h_C000_FF80, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_8000_0000, 32'h_0000_0001,  32'h_8000_0080, 32'h_0000_0010);
FIFO_IN_CID_DATA(32'h_C000_0000, 32'h_0000_0000,  32'h_C000_0080, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_0001_0000, 32'h_0000_0000,  32'h_0000_0001, 32'h_0000_0004);

// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();

CID_DAC0_NUM_FFDAT_WR(32'd0008); // (data)
CID_DAC1_NUM_FFDAT_WR(32'd0008); // (data)

//}

// test repeat setup 1 //{
#200;

//CID_DAC0_REPEAT_WR(32'h_0000_0000);
//CID_DAC1_REPEAT_WR(32'h_0000_0000);
CID_DAC0_REPEAT_WR(32'h_0000_0003);
CID_DAC1_REPEAT_WR(32'h_0000_0005);

//}

// test run 1 //{
#200;

CID_FIFO_TEST_RUN();
#1000;
#1000;
CID_FIFO_TEST_STOP();


//}


//}


///////////////////////
#200;
$finish;

//
end

//}


//// tasks //{

////---- tasks based on clk_10M  or  clk_200M / clk_400M ----////

//TODO: CID task //{


task CID_ADRS_WR;
	input  [31:0] adrs;
	begin
		@(posedge clk_10M);
		r_wire_dacz_data    = adrs;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[8] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[8] = 1'b0;
	end
endtask

task CID_ADRS_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacz_ctrl[9] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[9] = 1'b0;
	end
endtask

////

task CID_DATA_WR;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacz_data    = data;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[10] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[10] = 1'b0;
	end
endtask

task CID_DATA_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacz_ctrl[11] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[11] = 1'b0;
	end
endtask

//

task CID_DAC0_BIAS_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0000);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_BIAS_RD;
	begin
		CID_ADRS_WR(32'h_0000_0000);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_BIAS_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0010);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_BIAS_RD;
	begin
		CID_ADRS_WR(32'h_0000_0010);
		CID_DATA_RD();
	end
endtask

//

task CID_DAC0_REPEAT_WR; // (data)
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0020);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_REPEAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_0020);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_REPEAT_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0030);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_REPEAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_0030);
		CID_DATA_RD();
	end
endtask

//

task CID_DAC0_SEQ_WR; // (idx, dat_inc, dur)
	input  [31:0] idx;
	input  [31:0] dat_inc;
	input  [31:0] dur;
	begin
		// dat inc
		CID_ADRS_WR(32'h_0000_0040+idx);
		CID_DATA_WR(dat_inc);
		// dur
		CID_ADRS_WR(32'h_0000_0060+idx);
		CID_DATA_WR(dur);
	end
endtask

task CID_DAC1_SEQ_WR;
	input  [31:0] idx;
	input  [31:0] dat_inc;
	input  [31:0] dur;
	begin
		// dat inc
		CID_ADRS_WR(32'h_0000_0050+idx);
		CID_DATA_WR(dat_inc);
		// dur
		CID_ADRS_WR(32'h_0000_0070+idx);
		CID_DATA_WR(dur);
	end
endtask

//

task CID_DAC0_NUM_FFDAT_WR; // (data)
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_1000);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_NUM_FFDAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_1000);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_NUM_FFDAT_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_1010);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_NUM_FFDAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_1010);
		CID_DATA_RD();
	end
endtask


////

task CID_CTRL_WR;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacz_data    = data;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[12] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[12] = 1'b0;
	end
endtask

task CID_CTRL_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacz_ctrl[13] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[13] = 1'b0;
	end
endtask

//

task CID_ALL_TEST_OFF;
	begin
		CID_CTRL_WR(32'h0000_0000);
	end
endtask

//

task CID_ALL_TEST_OFF__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_0003);
	end
endtask

//

task CID_FIFO_RESET;
	begin
		CID_CTRL_WR(32'h0000_00C0);
		CID_CTRL_WR(32'h0000_0000); // wair for reset done
		CID_CTRL_WR(32'h0000_0000); // wair for reset done
	end
endtask


//

task CID_SEQ_TEST_RUN;
	begin
		CID_CTRL_WR(32'h0000_000C);
	end
endtask

task CID_SEQ_TEST_RUN__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_000F);
	end
endtask

task CID_SEQ_TEST_STOP;
	begin
		CID_ALL_TEST_OFF();
	end
endtask

//

task CID_FIFO_TEST_RUN;
	begin
		CID_CTRL_WR(32'h0000_0030);
	end
endtask

task CID_FIFO_TEST_RUN__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_0033);
	end
endtask

task CID_FIFO_TEST_STOP;
	begin
		CID_ALL_TEST_OFF();
	end
endtask



////

task CID_STAT_WR; // unused
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacz_data    = data;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[14] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[14] = 1'b0;
	end
endtask

task CID_STAT_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacz_ctrl[15] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacz_ctrl[15] = 1'b0;
	end
endtask


//}

//TODO: FCID task //{

// test_dacz_fifo_in_datinc0
// test_dacz_fifo_in_dur0   
// test_dacz_fifo_in_datinc1
// test_dacz_fifo_in_dur1   
// test_dacz_fifo_in_wr     
// test_dacz_fifo_out_rd    

task FIFO_IN_CID_DATA; // (datinc0, dur0, datinc1, dur1)
	input [31:0] datinc0;
	input [31:0] dur0   ;
	input [31:0] datinc1;
	input [31:0] dur1   ;
	begin
		@(posedge clk_BUS);
		test_dacz_fifo_in_datinc0    = datinc0;
		test_dacz_fifo_in_dur0       = dur0   ;
		test_dacz_fifo_in_datinc1    = datinc1;
		test_dacz_fifo_in_dur1       = dur1   ;
		@(posedge clk_BUS);
		test_dacz_fifo_in_wr = 1'b1;
		@(posedge clk_BUS);
		test_dacz_fifo_in_wr = 1'b0;
	end
endtask

task FIFO_OUT_CID_DATA; // ()
	begin
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_dacz_fifo_out_rd = 1'b1;
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_dacz_fifo_out_rd = 1'b0;
	end
endtask

//}


//}



endmodule
//}


////---- TODO: ================================================================ ----////

//// testbench
module tb_dac_pattern_gen_wrapper; //{

//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_BUS = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_BUS = ~clk_BUS; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_400M = 1'b0; // 400Mz
	always
	#1.25 	clk_400M = ~clk_400M; // toggle every 1.25ns --> clock 2.5ns 
//
reg clk_200M = 1'b0; // 200Mz
	always
	#2.5 	clk_200M = ~clk_200M; // toggle every 2.5ns --> clock 5ns 
	

//}

//// reg and wire //{
reg test_reset;
//
reg [31:0] r_trig_dacx_ctrl;
reg [31:0] r_wire_dacx_data;

//// fifo test 
reg [31:0] test_fifo_in_data0; //
reg [31:0] test_fifo_in_data1; //
//
reg        test_fifo_in_wr; //
reg        test_fifo_out_rd; //
//
reg [31:0] test_dacz_fifo_in_datinc0; // new control
reg [31:0] test_dacz_fifo_in_dur0   ; // new control
reg [31:0] test_dacz_fifo_in_datinc1; // new control
reg [31:0] test_dacz_fifo_in_dur1   ; // new control
reg        test_dacz_fifo_in_wr     ; // new control
reg        test_dacz_fifo_out_rd    ; // new control

//
reg [31:0] test_data_rep0;
reg [31:0] test_data_rep1;

//
wire       w_dac0_active_dco;
wire       w_dac1_active_dco;
wire       w_dac0_active_clk;
wire       w_dac1_active_clk;

//
wire       w_fifo_dac0_empty;
wire       w_fifo_dac1_empty;

////



//}


/* DUT */ //{

dac_pattern_gen_wrapper  dac_pattern_gen_wrapper__inst (

	// clock / reset
	.clk                (clk_10M), // 
	.reset_n            (reset_n),
	
	// DAC clock / reset
	.i_clk_dac0_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac0_dco    (reset_n & ~test_reset), //
	.i_clk_dac1_dco     (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac1_dco    (reset_n & ~test_reset), //
	
	// DACZ control port
	.i_trig_dacz_ctrl   (r_trig_dacx_ctrl), // [31:0]
	.i_wire_dacz_data   (r_wire_dacx_data), // [31:0]
	.o_wire_dacz_data   (), // [31:0]
	
	// DACZ fifo port // new control // from MCS or USB
	.i_dac0_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_datinc_din      (test_dacz_fifo_in_datinc0), // [31:0]
	.i_dac0_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac0_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac0_fifo_dur____din      (test_dacz_fifo_in_dur0   ), // [31:0]
	.i_dac1_fifo_datinc_wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_datinc_wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_datinc_din      (test_dacz_fifo_in_datinc1), // [31:0]
	.i_dac1_fifo_dur____wr_ck    (clk_BUS                  ), //       
	.i_dac1_fifo_dur____wr_en    (test_dacz_fifo_in_wr     ), //       
	.i_dac1_fifo_dur____din      (test_dacz_fifo_in_dur1   ), // [31:0]
	//
	.i_dac0_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	.i_dac1_fifo_dd_rd_en_test   (test_dacz_fifo_out_rd    ), // test read out
	

	// fifo data and control 
	.i_dac0_fifo_wr_clk     (clk_BUS           ), //
	.i_dac0_fifo_wr_en      (test_fifo_in_wr   ), //
	.i_dac0_fifo_din        (test_fifo_in_data0), // [31:0]
	.i_dac1_fifo_wr_clk     (clk_BUS           ), //
	.i_dac1_fifo_wr_en      (test_fifo_in_wr   ), //
	.i_dac1_fifo_din        (test_fifo_in_data1), // [31:0]
	//
	.i_dac0_fifo_rd_en_test (test_fifo_out_rd), // test read out
	.i_dac1_fifo_rd_en_test (test_fifo_out_rd), // test read out
	
	// DAC data output port 
	.o_dac0_data_pin    (), // [15:0]
	.o_dac1_data_pin    (), // [15:0]

	// DAC activity flag
	.o_dac0_active_dco  (w_dac0_active_dco),
	.o_dac1_active_dco  (w_dac1_active_dco),
	.o_dac0_active_clk  (w_dac0_active_clk),
	.o_dac1_active_clk  (w_dac1_active_clk),
	
	// FIFO flag 
	.o_fifo_dac0_empty  (w_fifo_dac0_empty),
	.o_fifo_dac1_empty  (w_fifo_dac1_empty),
	
	// flag
	.valid              ()

);




//}


/* test signaling */ //{

integer num_steps;
integer step_size;
integer code_level   ;
integer code_duration;

// system reset 
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

// test sequence 
initial begin
#0	;
// test init
begin : test_sig__init
	test_reset 		= 1'b0;
	//
	r_trig_dacx_ctrl = 32'b0;
	r_wire_dacx_data = 32'b0;
	//
	test_fifo_in_data0 = 32'b0; //
	test_fifo_in_data1 = 32'b0; //
	test_fifo_in_wr    =  1'b0; //
	test_fifo_out_rd   =  1'b0; //
	//
	test_dacz_fifo_in_datinc0 = 32'b0; //
	test_dacz_fifo_in_dur0    = 32'b0; //
	test_dacz_fifo_in_datinc1 = 32'b0; //
	test_dacz_fifo_in_dur1    = 32'b0; //
	test_dacz_fifo_in_wr      =  1'b0; //
	test_dacz_fifo_out_rd     =  1'b0; //
	
	//
	test_data_rep0     = 32'b0; //
	test_data_rep1     = 32'b0; //
	end
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;
// test reset //{
begin : test_reset__gen
	test_reset 		= 1'b1; 
	#200;
	test_reset 		= 1'b0; 
	end
//}


//// DCS test //{
// DCS test address / data setup
#200;
DACX_DCS_WRITE_ADRS(32'h_0000_0000);
DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0001);
DACX_DCS_WRITE_DATA_DAC0(32'h_7FFF_0010);
DACX_DCS_WRITE_DATA_DAC1(32'h_7FFF_0004);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0002);
DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0003);
DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0004);
DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0005);
DACX_DCS_WRITE_DATA_DAC0(32'h_8000_0010);
DACX_DCS_WRITE_DATA_DAC1(32'h_8000_0004);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0006);
DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//
DACX_DCS_WRITE_ADRS(32'h_0000_0007);
DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
#0; 

// DCS test repeat setup 1
#200;
DACX_DCS_WRITE_REPEAT(32'h_0000_0000); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 
// DCS test run
#200;
DACX_DCS_RUN_TEST();
#1000;
DACX_DCS_STOP_TEST();
#0; 
//

// DCS test repeat setup 2
#200;
DACX_DCS_WRITE_REPEAT(32'h_0004_0001); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 
// DCS test run
#200;
DACX_DCS_RUN_TEST();
#1000;
//
// repeat counter overflow check: 10slack ... 650ns
//   2^16/10*650ns = 4 259 840 nanoseconds
//#4_400_000;
//
DACX_DCS_STOP_TEST();
#0; 
//


//}

///////////////////////
#200;
$finish;


//// TODO: CID test //{

// test r_cid_reg_adrs
CID_ADRS_WR(32'h_0000_0000);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0010);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0020);
CID_ADRS_RD();
#200;
CID_ADRS_WR(32'h_0000_0030);
CID_ADRS_RD();
#200;

// test r_cid_reg_ctrl
CID_CTRL_WR(32'h_0000_0003);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_000C);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_0030);
CID_CTRL_RD();
#200;
CID_CTRL_WR(32'h_0000_0000);
CID_CTRL_RD();
#200;

// test w_cid_reg_stat
CID_STAT_RD();
#200;

// test r_cid_reg_dac*_bias_code
CID_DAC0_BIAS_WR(32'h_0000_0123);
CID_DAC0_BIAS_RD();
#200;
CID_DAC1_BIAS_WR(32'h_0000_01AB);
CID_DAC1_BIAS_RD();
#200;

// test r_cid_reg_dac*_num_repeat
CID_DAC0_REPEAT_WR(32'h_0000_0003);
CID_DAC0_REPEAT_RD();
#200;
CID_DAC1_REPEAT_WR(32'h_0000_0004);
CID_DAC1_REPEAT_RD();
#200;

// test cid regs
//DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_7FFF_0010);
//DACX_DCS_WRITE_DATA_DAC0(32'h_3FFF_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
//DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_8000_0010);
//DACX_DCS_WRITE_DATA_DAC0(32'h_C000_0008);
//DACX_DCS_WRITE_DATA_DAC0(32'h_0000_0004);
//
//DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_7FFF_0004);
//DACX_DCS_WRITE_DATA_DAC1(32'h_3FFF_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
//DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_8000_0004);
//DACX_DCS_WRITE_DATA_DAC1(32'h_C000_0002);
//DACX_DCS_WRITE_DATA_DAC1(32'h_0000_0001);
//
CID_DAC0_SEQ_WR(0,32'h_3FFF_0080,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(1,32'h_7FFF_FF80,32'h_0000_0010); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(2,32'h_3FFF_FF80,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(3,32'h_0000_FFFF,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(4,32'h_C000_FF80,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(5,32'h_8000_0080,32'h_0000_0010); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(6,32'h_C000_0080,32'h_0000_0008); // idx, dat_inc, dur
CID_DAC0_SEQ_WR(7,32'h_0000_0001,32'h_0000_0004); // idx, dat_inc, dur
#200;
//
CID_DAC1_SEQ_WR(0,32'h_3FFF_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(1,32'h_7FFF_0000,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(2,32'h_3FFF_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(3,32'h_0000_0000,32'h_0000_0001); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(4,32'h_C000_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(5,32'h_8000_0000,32'h_0000_0004); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(6,32'h_C000_0000,32'h_0000_0002); // idx, dat_inc, dur
CID_DAC1_SEQ_WR(7,32'h_0000_0000,32'h_0000_0001); // idx, dat_inc, dur
#200;
//


//// test run 1
CID_DAC0_REPEAT_WR(32'h_0000_0000);
CID_DAC1_REPEAT_WR(32'h_0000_0000);
#200;
CID_SEQ_TEST_RUN();
#1000;
CID_SEQ_TEST_STOP();


//// test run 2
CID_DAC0_REPEAT_WR(32'h_0000_0001);
CID_DAC1_REPEAT_WR(32'h_0000_0004);
#200;
CID_SEQ_TEST_RUN();
#1000;
CID_SEQ_TEST_STOP();


//}

///////////////////////
#200;
$finish;

//// FDCS --> FCID test //{


// FDCS test fifo setup 1 //{

// short interval test
//FIFO_IN_DATA(32'h_3FFF_0008, 32'h_3FFF_0002); // (data0, data1)
//FIFO_IN_DATA(32'h_7FFF_0010, 32'h_7FFF_0004);
//FIFO_IN_DATA(32'h_3FFF_0008, 32'h_3FFF_0002);
//FIFO_IN_DATA(32'h_0000_0004, 32'h_0000_0001);
//FIFO_IN_DATA(32'h_C000_0008, 32'h_C000_0002);
//FIFO_IN_DATA(32'h_8000_0010, 32'h_8000_0004);
//FIFO_IN_DATA(32'h_C000_0008, 32'h_C000_0002);
//FIFO_IN_DATA(32'h_0000_0004, 32'h_0000_0001);
//
FIFO_IN_DATA(32'h_3FFF_0000, 32'h_3FFF_0008); // (data0, data1)
FIFO_IN_DATA(32'h_7FFF_0000, 32'h_7FFF_0010);
FIFO_IN_DATA(32'h_3FFF_0001, 32'h_3FFF_0008);
FIFO_IN_DATA(32'h_FFFE_0002, 32'h_0000_0004);
FIFO_IN_DATA(32'h_C000_0002, 32'h_C000_0008);
FIFO_IN_DATA(32'h_8000_0001, 32'h_8000_0010);
FIFO_IN_DATA(32'h_C000_0000, 32'h_C000_0008);
FIFO_IN_DATA(32'h_0001_0000, 32'h_0000_0004);

// cnt_duration, rd_en  ...  expected
// 
//                        
// 3FFF_0000  XXXX  H
// 7FFF_0000  XXXX  H
// 3FFF_0001  XXXX  L
//            0000  H
// FFFE_0002  XXXX  L
//            0001  L
//            0000  H
// C000_0002  XXXX  L
//            0001  L
//            0000  H
// 8000_0001  XXXX  L
//            0000  H
// C000_0000  0000  H
// 0001_0000  XXXX  H
//            XXXX  
//                        
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();
//FIFO_OUT_DATA();

////---- CID ---////
CID_FIFO_RESET();
//
FIFO_IN_CID_DATA(32'h_3FFF_0000, 32'h_0000_0000,  32'h_3FFF_0080, 32'h_0000_0008); // (datinc0, dur0,  datinc1, dur1)
FIFO_IN_CID_DATA(32'h_7FFF_0000, 32'h_0000_0000,  32'h_7FFF_FF80, 32'h_0000_0010);
FIFO_IN_CID_DATA(32'h_3FFF_0000, 32'h_0000_0001,  32'h_3FFF_FF80, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_FFFE_0000, 32'h_0000_0002,  32'h_0000_FFFF, 32'h_0000_0004);
FIFO_IN_CID_DATA(32'h_C000_0000, 32'h_0000_0002,  32'h_C000_FF80, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_8000_0000, 32'h_0000_0001,  32'h_8000_0080, 32'h_0000_0010);
FIFO_IN_CID_DATA(32'h_C000_0000, 32'h_0000_0000,  32'h_C000_0080, 32'h_0000_0008);
FIFO_IN_CID_DATA(32'h_0001_0000, 32'h_0000_0000,  32'h_0000_0001, 32'h_0000_0004);

// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();
// FIFO_OUT_CID_DATA();

CID_DAC0_NUM_FFDAT_WR(32'd0008); // (data)
CID_DAC1_NUM_FFDAT_WR(32'd0008); // (data)

//}

// FDCS test repeat setup 1 //{
#200;
//DACX_FDCS_WRITE_REPEAT(32'h_0000_0000); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
DACX_FDCS_WRITE_REPEAT(32'h_0005_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0006_0003); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0002_0001); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0004_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 

//CID_DAC0_REPEAT_WR(32'h_0000_0000);
//CID_DAC1_REPEAT_WR(32'h_0000_0000);
CID_DAC0_REPEAT_WR(32'h_0000_0002);
CID_DAC1_REPEAT_WR(32'h_0000_0005);

//}

// FDCS test run 1 //{
#200;
DACX_FDCS_RUN_TEST();
#1000;
#1000;
//@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
//@(posedge (w_fifo_dac0_empty))
//@(negedge (w_dac0_active_dco | w_dac1_active_dco))
#100
DACX_FDCS_STOP_TEST();
#0; 

CID_FIFO_TEST_RUN();
#1000;
#1000;
CID_FIFO_TEST_STOP();


//}

///////////////////////
#200;
$finish;


// FDCS setup 2 //{

// test pattern @ 200MHz DAC update or 5ns period
//  slew rates : 10V/15ns, 10V/60ns, 5V/30ns, 5V/50ns 
//
// time, voltage, dac code, (time_diff+1) count @ 5ns
//   0ns,  0V, 0000, 0004
//  25ns,  0V, 0000, 0002 //  10V/15ns 
//  40ns, 10V, 7FFF, 0005
//  70ns, 10V, 7FFF, 000B // -10V/60ns
// 130ns,  0V, 0000, 0009
// 180ns,  0V, 0000, 0005 //   5V/30ns
// 210ns,  5V, 4FFF, 0009
// 260ns,  5V, 4FFF, 000B //  -5V/50ns
// 320ns,  0V, 0000, 000F
// 400ns

//FIFO_IN_DATA(32'h_0000_0004, 32'h_3FFF_0002); // (data0, data1)
//FIFO_IN_DATA(32'h_0000_0002, 32'h_7FFF_0004); 
//FIFO_IN_DATA(32'h_7FFF_0005, 32'h_3FFF_0002); 
//FIFO_IN_DATA(32'h_7FFF_000B, 32'h_0000_0001); 
//FIFO_IN_DATA(32'h_0000_0009, 32'h_C000_0002); 
//FIFO_IN_DATA(32'h_0000_0005, 32'h_8000_0004); 
//FIFO_IN_DATA(32'h_4FFF_0009, 32'h_C000_0002); 
//FIFO_IN_DATA(32'h_4FFF_000B, 32'h_0000_0001); 
//FIFO_IN_DATA(32'h_0000_000F, 32'h_0000_0000); 

FIFO_IN_DATA(32'h_0001_0004, 32'h_3FFF_0002); // (data0, data1) //
FIFO_IN_DATA(32'h_1FFF_0000, 32'h_7FFF_0004); // (data0, data1) //
FIFO_IN_DATA(32'h_3FFF_0000, 32'h_3FFF_0002);
FIFO_IN_DATA(32'h_5FFF_0000, 32'h_0000_0001);
FIFO_IN_DATA(32'h_7FFF_0005, 32'h_C000_0002); // (data0, data1) //
FIFO_IN_DATA(32'h_6FFF_0000, 32'h_8000_0004); // (data0, data1) //
FIFO_IN_DATA(32'h_5FFF_0001, 32'h_C000_0002);
FIFO_IN_DATA(32'h_4FFF_0001, 32'h_0000_0001);
FIFO_IN_DATA(32'h_3FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_2FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_1FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_0FFF_0000, 32'h_0001_0000);
FIFO_IN_DATA(32'h_0000_0009, 32'h_0001_0000); // (data0, data1) //
FIFO_IN_DATA(32'h_0FFF_0001, 32'h_0001_0000); // (data0, data1) //
FIFO_IN_DATA(32'h_1FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_2FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_3FFF_0009, 32'h_0001_0000); // (data0, data1) //
FIFO_IN_DATA(32'h_37FF_0000, 32'h_0001_0000); // (data0, data1) //
FIFO_IN_DATA(32'h_2FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_27FF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_1FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_17FF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_0FFF_0001, 32'h_0001_0000);
FIFO_IN_DATA(32'h_07FF_0000, 32'h_0001_0000);
FIFO_IN_DATA(32'h_FFFF_000F, 32'h_0001_0000); // (data0, data1) //

#200;
DACX_FDCS_WRITE_REPEAT(32'h_0004_0005); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 


//}

// FDCS test run 2 //{
#200;
DACX_FDCS_RUN_TEST();
#1000;
#1000;
//@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
//@(posedge (w_fifo_dac0_empty))
//@(negedge (w_dac0_active_dco | w_dac1_active_dco))
#100
DACX_FDCS_STOP_TEST();
#0; 
//}

///////////////////////
#200;
$finish;


// FDCS setup 3 //{

// 400ms long rise time
//   400ms * 400MHz = 160 000 000
//   log(400ms * 400MHz)/log(2) = 27.2534966642
//   10ns * 400MHz = 4 ... 100MHz 
//   400ms * 100MHz = 40 000 000
//   log(400ms * 100MHz)/log(2) = 25.2534966642
//    ...
//   duration = 40000 ... 0.1MHz
//   duration = 4000  ... 0.01MHz
//   400ms * 0.01MHz = 40000
//   400ms * 0.1MHz  = 4000
//   dac code step 0x7FFF/40000 = 0.819175  ... 0.25 millivolts @ 10V fullscale
//   dac code step 0x7FFF/4000  = 8.19175   ...  2.5 millivolts @ 10V fullscale
//   dac code step 0x7FFF/40000 ~ 1  ... 10V/2^15   = 0.305175781 millivolts @ 10V fullscale
//   dac code step 0x7FFF/4000  ~ 8  ... 10V/2^15*8 = 2.44140625  millivolts @ 10V fullscale
//
// FIFO_IN_DATA(32'h_0000_0FA0, 32'h_0000_0FA0);
// FIFO_IN_DATA(32'h_0008_0FA0, 32'h_0008_0FA0);
// FIFO_IN_DATA(32'h_0010_0FA0, 32'h_0010_0FA0);
// FIFO_IN_DATA(32'h_0018_0FA0, 32'h_0018_0FA0);
//
// FIFO_IN_DATA(32'h_0000_0FA0, 32'h_0000_0FA0);
// FIFO_IN_DATA(32'h_0001_0FA0, 32'h_0001_0FA0);
// FIFO_IN_DATA(32'h_0002_0FA0, 32'h_0002_0FA0);
// FIFO_IN_DATA(32'h_0003_0FA0, 32'h_0003_0FA0);
//
// 0x0FA0 = 4000
// 0x000A = 0010
//

// fifo data in //{

//test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*4000 = 100 us
//test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*4000  = 10 us
//test_data_rep1 = 32'h_7FFF_03E7; // 1000/(400MHz)*4000 = 10 ms
//test_data_rep1 = 32'h_7FFF_9C3F; // 40000/(400MHz)*4000 = 400 ms

// for fifo depth 4k
//test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*4000 = 100 us
//test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*4000  = 10 us
//repeat(4000) begin
//	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
//	test_data_rep0 = test_data_rep0 - 32'h_0008_0000;
//	test_data_rep1 = test_data_rep1 - 32'h_0008_0000;
//end

// for fifo depth 2k
//test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*2000 = 50 us
//test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*2000  = 5 us
//repeat(2000) begin
//	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
//	test_data_rep0 = test_data_rep0 - 32'h_000F_0000;
//	test_data_rep1 = test_data_rep1 - 32'h_000F_0000;
//end

// for fifo depth 1k
//test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*1000 = 25 us
//test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*1000  = 2.5 us
//repeat(1000) begin
//	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
//	test_data_rep0 = test_data_rep0 - 32'h_0020_0000;
//	test_data_rep1 = test_data_rep1 - 32'h_0020_0000;
//end

// for fifo depth 512
test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*500 = 12.5 us
test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*500  = 1.25 us
//test_data_rep1 = 32'h_7FFF_9C3F; // 40000/(400MHz)*500 = 50 ms
//test_data_rep1 = 32'h_7FFF_9C3F; // 40000/( 50MHz)*500 = 400 ms
repeat(500) begin
	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
	test_data_rep0 = test_data_rep0 - 32'h_0040_0000;
	test_data_rep1 = test_data_rep1 - 32'h_0040_0000;
end



//}

// fifo repeat //{

#200;
DACX_FDCS_WRITE_REPEAT(32'h_0000_0000); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0001_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 

//}

//}

// FDCS test run 3 //{
#200;
DACX_FDCS_RUN_TEST();
#1000;
//{ to check fifo read without logic 
//repeat(4000) begin
//	FIFO_OUT_DATA();
//end 
//}
//
#0
@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
#100    // 100ns
#1000   // 1us
#50_000 // 50us
#50_000 // 50us
#20_000 // 20us
//@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
//@(posedge (w_fifo_dac0_empty))
//@(negedge (w_dac0_active_dco | w_dac1_active_dco))
#100
DACX_FDCS_STOP_TEST();
#0; 
//}

///////////////////////
#200;
$finish;


// FDCS setup 4 //{

// new long slope test 
// rise (100ms) - flat (100ms) - fall (100ms) - flat (100ms)


// fifo data in //{

// consider fifo depth 512

// 40000/( 50MHz)*125 =  100 ms // 1 + 0x9C3F = 40000
// 40000/(200MHz)*125 =   25 ms 
//    10/(200MHz)*125 = 6.25 us // 1 + 0x0009 = 10
//     1/(200MHz)*125 =  625 ns // 1

assign code_level    = 16'h_7FFF;
assign code_duration = 16'h_0009;
assign num_steps     =  125;
assign step_size     =  (code_level/num_steps); // 0x7FFF/125=262.136

//test_data_rep0 = 32'h_7FFF_0009; // 10/(400MHz)*500 = 12.5 us
//test_data_rep1 = 32'h_7FFF_0000; // 1/(400MHz)*500  = 1.25 us
//test_data_rep1 = 32'h_7FFF_9C3F; // 40000/(400MHz)*500 = 50 ms
//test_data_rep1 = 32'h_7FFF_9C3F; // 40000/( 50MHz)*500 = 400 ms

// rise 
test_data_rep0 = (0<<16)+code_duration;
test_data_rep1 = (0<<16)+0            ;
//
repeat(num_steps) begin
	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
	test_data_rep0 = test_data_rep0 + (step_size<<16); // skip duration region
	test_data_rep1 = test_data_rep1 + (step_size<<16); // skip duration region
end

// flat
test_data_rep0 = (code_level<<16)+code_duration;
test_data_rep1 = (code_level<<16)+0            ;
//
repeat(num_steps) begin
	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
	test_data_rep0 = test_data_rep0;
	test_data_rep1 = test_data_rep1;
end

// fall 
test_data_rep0 = (code_level<<16)+code_duration;
test_data_rep1 = (code_level<<16)+0            ;
//
repeat(num_steps) begin
	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
	test_data_rep0 = test_data_rep0 - (step_size<<16); // skip duration region
	test_data_rep1 = test_data_rep1 - (step_size<<16); // skip duration region
end

// flat
test_data_rep0 = (0<<16)+code_duration;
test_data_rep1 = (0<<16)+0            ;
//
repeat(num_steps) begin
	FIFO_IN_DATA(test_data_rep0, test_data_rep1);
	test_data_rep0 = test_data_rep0;
	test_data_rep1 = test_data_rep1;
end


//}

// fifo repeat //{

#200;
//DACX_FDCS_WRITE_REPEAT(32'h_0000_0000); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0001_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
DACX_FDCS_WRITE_REPEAT(32'h_0003_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 

#200;
DACX_WRITE_REPEAT_PERIOD(32'd6000); // set repeat period 1/(200MHz)*6000=30us
#0; 

//}


//}

// FDCS test run 4 //{
#200;
DACX_FDCS_RUN_TEST();
#1000;
//{ to check fifo read without logic 
//repeat(4000) begin
//	FIFO_OUT_DATA();
//end 
//}
//
#0;
DACX_READ_STATUS();
#0;
#100
DACX_HOLD_PUSLE();
#1000
DACX_RELEASE_PUSLE();
#0
@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
#100    // 100ns
#1000   // 1us
#20_000 // 20us
//@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
//@(posedge (w_fifo_dac0_empty))
//@(negedge (w_dac0_active_dco | w_dac1_active_dco))
#0
DACX_READ_STATUS();
#5_000
DACX_READ_STATUS();
#100
DACX_FDCS_STOP_TEST();
#0; 
//}


//}


///////////////////////
#200;
$finish;

//
end

//}


//// tasks //{

////---- tasks based on clk_10M  ----////

// MLS task // to remove //{
task DACX_MLS_WRITE_ADRS;
	input  [31:0] adrs;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = adrs;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[8] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[8] = 1'b0;
	end
endtask
//
task DACX_MLS_READ_ADRS;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[9] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[9] = 1'b0;
	end
endtask
//
task DACX_MLS_WRITE_DATA;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[10] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[10] = 1'b0;
	end
endtask
//
task DACX_MLS_READ_DATA;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[11] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[11] = 1'b0;
	end
endtask
//
task DACX_MLS_RUN_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[12] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[12] = 1'b0;
	end
endtask
//
task DACX_MLS_STOP_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[13] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[13] = 1'b0;
	end
endtask
//

//}

// DCS task // to remove //{
task DACX_DCS_WRITE_ADRS;
	input  [31:0] adrs;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = adrs;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[16] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[16] = 1'b0;
	end
endtask
//
task DACX_DCS_READ_ADRS;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[17] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[17] = 1'b0;
	end
endtask
//
task DACX_DCS_WRITE_DATA_DAC0;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[18] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[18] = 1'b0;
	end
endtask
//
task DACX_DCS_READ_DATA_DAC0;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[19] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[19] = 1'b0;
	end
endtask
//
task DACX_DCS_WRITE_DATA_DAC1;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[20] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[20] = 1'b0;
	end
endtask
//
task DACX_DCS_READ_DATA_DAC1;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[21] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[21] = 1'b0;
	end
endtask
//
task DACX_DCS_RUN_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[22] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[22] = 1'b0;
	end
endtask
//
task DACX_DCS_STOP_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[23] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[23] = 1'b0;
	end
endtask
//
task DACX_DCS_WRITE_REPEAT;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[24] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[24] = 1'b0;
	end
endtask
//
task DACX_DCS_READ_REPEAT;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[25] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[25] = 1'b0;
	end
endtask

//}

// FDCS task // to remove //{
task DACX_FDCS_RUN_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[28] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[28] = 1'b0;
	end
endtask
//
task DACX_FDCS_STOP_TEST;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[29] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[29] = 1'b0;
	end
endtask
//
task DACX_FDCS_WRITE_REPEAT;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[30] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[30] = 1'b0;
	end
endtask
//
task DACX_FDCS_READ_REPEAT;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[31] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[31] = 1'b0;
	end
endtask//


// write control for pulse 
task DACX_WRITE_CONTROL;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[4] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[4] = 1'b0;
	end
endtask

// sub control - hold pulse
task DACX_HOLD_PUSLE;
	begin
		DACX_WRITE_CONTROL({28'b0,4'b1100});
	end
endtask//

task DACX_RELEASE_PUSLE;
	begin
		DACX_WRITE_CONTROL({28'b0,4'b0000});
	end
endtask//


// read status for pulse
task DACX_READ_STATUS;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[5] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[5] = 1'b0;
	end
endtask//


// pulse repeat period
//
task DACX_WRITE_REPEAT_PERIOD;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[6] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[6] = 1'b0;
	end
endtask
//
task DACX_READ_REPEAT_PERIOD;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[7] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[7] = 1'b0;
	end
endtask//

//}


//TODO: CID task //{


task CID_ADRS_WR;
	input  [31:0] adrs;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = adrs;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[8] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[8] = 1'b0;
	end
endtask

task CID_ADRS_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[9] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[9] = 1'b0;
	end
endtask

////

task CID_DATA_WR;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[10] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[10] = 1'b0;
	end
endtask

task CID_DATA_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[11] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[11] = 1'b0;
	end
endtask

//

task CID_DAC0_BIAS_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0000);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_BIAS_RD;
	begin
		CID_ADRS_WR(32'h_0000_0000);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_BIAS_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0010);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_BIAS_RD;
	begin
		CID_ADRS_WR(32'h_0000_0010);
		CID_DATA_RD();
	end
endtask

//

task CID_DAC0_REPEAT_WR; // (data)
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0020);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_REPEAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_0020);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_REPEAT_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_0030);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_REPEAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_0030);
		CID_DATA_RD();
	end
endtask

//

task CID_DAC0_SEQ_WR; // (idx, dat_inc, dur)
	input  [31:0] idx;
	input  [31:0] dat_inc;
	input  [31:0] dur;
	begin
		// dat inc
		CID_ADRS_WR(32'h_0000_0040+idx);
		CID_DATA_WR(dat_inc);
		// dur
		CID_ADRS_WR(32'h_0000_0060+idx);
		CID_DATA_WR(dur);
	end
endtask

task CID_DAC1_SEQ_WR;
	input  [31:0] idx;
	input  [31:0] dat_inc;
	input  [31:0] dur;
	begin
		// dat inc
		CID_ADRS_WR(32'h_0000_0050+idx);
		CID_DATA_WR(dat_inc);
		// dur
		CID_ADRS_WR(32'h_0000_0070+idx);
		CID_DATA_WR(dur);
	end
endtask

//

task CID_DAC0_NUM_FFDAT_WR; // (data)
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_1000);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC0_NUM_FFDAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_1000);
		CID_DATA_RD();
	end
endtask

task CID_DAC1_NUM_FFDAT_WR;
	input  [31:0] data;
	begin
		CID_ADRS_WR(32'h_0000_1010);
		CID_DATA_WR(data);
	end
endtask

task CID_DAC1_NUM_FFDAT_RD;
	begin
		CID_ADRS_WR(32'h_0000_1010);
		CID_DATA_RD();
	end
endtask


////

task CID_CTRL_WR;
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[12] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[12] = 1'b0;
	end
endtask

task CID_CTRL_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[13] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[13] = 1'b0;
	end
endtask

//

task CID_ALL_TEST_OFF;
	begin
		CID_CTRL_WR(32'h0000_0000);
	end
endtask

//

task CID_ALL_TEST_OFF__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_0003);
	end
endtask

//

task CID_FIFO_RESET;
	begin
		CID_CTRL_WR(32'h0000_00C0);
		CID_CTRL_WR(32'h0000_0000); // wair for reset done
		CID_CTRL_WR(32'h0000_0000); // wair for reset done
	end
endtask


//

task CID_SEQ_TEST_RUN;
	begin
		CID_CTRL_WR(32'h0000_000C);
	end
endtask

task CID_SEQ_TEST_RUN__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_000F);
	end
endtask

task CID_SEQ_TEST_STOP;
	begin
		CID_ALL_TEST_OFF();
	end
endtask

//

task CID_FIFO_TEST_RUN;
	begin
		CID_CTRL_WR(32'h0000_0030);
	end
endtask

task CID_FIFO_TEST_RUN__BIAS_EN;
	begin
		CID_CTRL_WR(32'h0000_0033);
	end
endtask

task CID_FIFO_TEST_STOP;
	begin
		CID_ALL_TEST_OFF();
	end
endtask



////

task CID_STAT_WR; // unused
	input  [31:0] data;
	begin
		@(posedge clk_10M);
		r_wire_dacx_data    = data;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[14] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[14] = 1'b0;
	end
endtask

task CID_STAT_RD;
	begin
		@(posedge clk_10M);
		r_trig_dacx_ctrl[15] = 1'b1;
		@(posedge clk_10M);
		r_trig_dacx_ctrl[15] = 1'b0;
	end
endtask


//}

//TODO: FCID task //{

// test_dacz_fifo_in_datinc0
// test_dacz_fifo_in_dur0   
// test_dacz_fifo_in_datinc1
// test_dacz_fifo_in_dur1   
// test_dacz_fifo_in_wr     
// test_dacz_fifo_out_rd    

task FIFO_IN_CID_DATA; // (datinc0, dur0, datinc1, dur1)
	input [31:0] datinc0;
	input [31:0] dur0   ;
	input [31:0] datinc1;
	input [31:0] dur1   ;
	begin
		@(posedge clk_BUS);
		test_dacz_fifo_in_datinc0    = datinc0;
		test_dacz_fifo_in_dur0       = dur0   ;
		test_dacz_fifo_in_datinc1    = datinc1;
		test_dacz_fifo_in_dur1       = dur1   ;
		@(posedge clk_BUS);
		test_dacz_fifo_in_wr = 1'b1;
		@(posedge clk_BUS);
		test_dacz_fifo_in_wr = 1'b0;
	end
endtask

task FIFO_OUT_CID_DATA; // ()
	begin
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_dacz_fifo_out_rd = 1'b1;
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_dacz_fifo_out_rd = 1'b0;
	end
endtask

//}



////---- task based on clk_BUS  ----////

// FDCS FIFO IN test 
task FIFO_IN_DATA; // (data0, data1)
	input [31:0] data0;
	input [31:0] data1;
	begin
		@(posedge clk_BUS);
		test_fifo_in_data0    = data0;
		test_fifo_in_data1    = data1;
		@(posedge clk_BUS);
		test_fifo_in_wr = 1'b1;
		@(posedge clk_BUS);
		test_fifo_in_wr = 1'b0;
	end
endtask
//


////---- task based on clk_400M --> clk_200M  ----////

// FDCS FIFO OUT test 
task FIFO_OUT_DATA;
	begin
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_fifo_out_rd = 1'b1;
		@(posedge clk_200M);  // clk_400M --> clk_200M
		test_fifo_out_rd = 1'b0;
	end
endtask


//}


//{ note dumpfile display monitor

//initial begin : waveform
	//$dumpfile ("waveform.vcd"); 
	//$dumpvars; 
//end 
  
//initial  begin : monitor
	//$display("\t\t time,\t clk,\t reset_n,\t en"); 
	//$monitor("%d,\t%b,\t%b,\t%b,\t%d",$time,clk,reset_n,en); 
//end 

//initial begin : finish
//#1000_000; // 1ms = 1000_000ns
//	$finish;
//end

//}


endmodule
//}
