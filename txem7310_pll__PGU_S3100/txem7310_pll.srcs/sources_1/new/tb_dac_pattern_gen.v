`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_dac_pattern_gen
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test  dac_pattern_gen.v
//
//////////////////////////////////////////////////////////////////////////////////


module tb_dac_pattern_gen;

//// clock and reset //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_bus = 1'b0; //$$ 9.92ns for USB3.0	
	always
	#4.96 	clk_bus = ~clk_bus; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
//
reg clk_400M = 1'b0; // 400Mz
	always
	#1.25 	clk_400M = ~clk_400M; // toggle every 1.25ns --> clock 2.5ns 
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

reg clk_144M = 1'b0; // 144MHz
//	always
//	#3.47222222 clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns 

reg clk_72M = 1'b0; // 72MHz
//	always
//	#6.94444444 clk_72M = ~clk_72M; // toggle every 6.94444444 ns --> clock 13.8888889 ns 

always begin
    #3.47222222;
    clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
    clk_72M = ~clk_72M;
    #3.47222222 
    clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
    end

reg clk_12M = 1'b0; // 12MHz
	always
	#41.6666667 clk_12M = ~clk_12M;  
//}

//// reg and wire //{
reg test_reset;
//
reg [31:0] r_trig_dacx_ctrl;
reg [31:0] r_wire_dacx_data;
//
reg [31:0] test_fifo_in_data0; //
reg [31:0] test_fifo_in_data1; //
reg        test_fifo_in_wr; //
reg        test_fifo_out_rd; //
//
reg [31:0] test_data_rep0;
reg [31:0] test_data_rep1;

//
wire       w_dac0_active_dco;
wire       w_dac1_active_dco;
wire       w_dac0_active_clk;
wire       w_dac1_active_clk;

//
wire        w_fifo_dac0_rst;
wire [31:0] w_fifo_dac0_dout;
wire        c_fifo_dac0_rd_ck;
wire        w_fifo_dac0_rd_en;
wire        w_fifo_dac0_empty;
wire        w_fifo_dac0_valid;
//
wire        w_fifo_dac1_rst;
wire [31:0] w_fifo_dac1_dout;
wire        c_fifo_dac1_rd_ck;
wire        w_fifo_dac1_rd_en;
wire        w_fifo_dac1_empty;
wire        w_fifo_dac1_valid;


wire        w_dac0_fifo_reload1_rst   ;
wire [31:0] w_dac0_fifo_reload1_dout  ;
wire        c_dac0_fifo_reload1_rd_ck ;
wire        w_dac0_fifo_reload1_rd_en ;
wire        w_dac0_fifo_reload1_empty ;
wire        w_dac0_fifo_reload1_valid ;
wire [31:0] w_dac0_fifo_reload1_din   ;
wire        c_dac0_fifo_reload1_wr_ck ;
wire        w_dac0_fifo_reload1_wr_en ;
wire        w_dac0_fifo_reload1_full  ;
wire        w_dac0_fifo_reload1_wr_ack;

wire        w_dac0_fifo_reload2_rst   ;
wire [31:0] w_dac0_fifo_reload2_dout  ;
wire        c_dac0_fifo_reload2_rd_ck ;
wire        w_dac0_fifo_reload2_rd_en ;
wire        w_dac0_fifo_reload2_empty ;
wire        w_dac0_fifo_reload2_valid ;
wire [31:0] w_dac0_fifo_reload2_din   ;
wire        c_dac0_fifo_reload2_wr_ck ;
wire        w_dac0_fifo_reload2_wr_en ;
wire        w_dac0_fifo_reload2_full  ;
wire        w_dac0_fifo_reload2_wr_ack;


wire        w_dac1_fifo_reload1_rst   ;
wire [31:0] w_dac1_fifo_reload1_dout  ;
wire        c_dac1_fifo_reload1_rd_ck ;
wire        w_dac1_fifo_reload1_rd_en ;
wire        w_dac1_fifo_reload1_empty ;
wire        w_dac1_fifo_reload1_valid ;
wire [31:0] w_dac1_fifo_reload1_din   ;
wire        c_dac1_fifo_reload1_wr_ck ;
wire        w_dac1_fifo_reload1_wr_en ;
wire        w_dac1_fifo_reload1_full  ;
wire        w_dac1_fifo_reload1_wr_ack;

wire        w_dac1_fifo_reload2_rst   ;
wire [31:0] w_dac1_fifo_reload2_dout  ;
wire        c_dac1_fifo_reload2_rd_ck ;
wire        w_dac1_fifo_reload2_rd_en ;
wire        w_dac1_fifo_reload2_empty ;
wire        w_dac1_fifo_reload2_valid ;
wire [31:0] w_dac1_fifo_reload2_din   ;
wire        c_dac1_fifo_reload2_wr_ck ;
wire        w_dac1_fifo_reload2_wr_en ;
wire        w_dac1_fifo_reload2_full  ;
wire        w_dac1_fifo_reload2_wr_ack;


//}


/* DUT */ //{

dac_pattern_gen  dac_pattern_gen_inst (
	.clk				(clk_10M), // 
	.reset_n			(reset_n),
	//
	.i_clk_dacx_ref   (), //
	.i_rstn_dacx_ref  (), //
	.i_clk_dac0_dco   (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac0_dco  (~test_reset), //
	.i_clk_dac1_dco   (clk_200M),    // clk_400M --> clk_200M
	.i_rstn_dac1_dco  (~test_reset), //
	
	.i_trig_dacx_ctrl (r_trig_dacx_ctrl), // [31:0]
	.i_wire_dacx_data (r_wire_dacx_data), // [31:0]
	.o_wire_dacx_data (), // [31:0]
	
	.o_dac0_data_pin  (), // [15:0]
	.o_dac1_data_pin  (), // [15:0]
	
	.o_dac0_active_dco  (w_dac0_active_dco),
	.o_dac1_active_dco  (w_dac1_active_dco),
	.o_dac0_active_clk  (w_dac0_active_clk),
	.o_dac1_active_clk  (w_dac1_active_clk),
	

	.o_dac0_fifo_rst    (w_fifo_dac0_rst  ),
	.i_dac0_fifo_dout   (w_fifo_dac0_dout ), // [31:0]
	.c_dac0_fifo_rd_ck  (c_fifo_dac0_rd_ck),
	.o_dac0_fifo_rd_en  (w_fifo_dac0_rd_en),
	.i_dac0_fifo_empty  (w_fifo_dac0_empty),
	.i_dac0_fifo_valid  (w_fifo_dac0_valid),

	.o_dac1_fifo_rst    (w_fifo_dac1_rst  ),
	.i_dac1_fifo_dout   (w_fifo_dac1_dout ), // [31:0]
	.c_dac1_fifo_rd_ck  (c_fifo_dac1_rd_ck),
	.o_dac1_fifo_rd_en  (w_fifo_dac1_rd_en),
	.i_dac1_fifo_empty  (w_fifo_dac1_empty),
	.i_dac1_fifo_valid  (w_fifo_dac1_valid),
	
	//
	.o_dac0_fifo_reload1_rst    (w_dac0_fifo_reload1_rst   ),
	.i_dac0_fifo_reload1_dout   (w_dac0_fifo_reload1_dout  ),
	.c_dac0_fifo_reload1_rd_ck  (c_dac0_fifo_reload1_rd_ck ),
	.o_dac0_fifo_reload1_rd_en  (w_dac0_fifo_reload1_rd_en ),
	.i_dac0_fifo_reload1_empty  (w_dac0_fifo_reload1_empty ),
	.i_dac0_fifo_reload1_valid  (w_dac0_fifo_reload1_valid ),
	.o_dac0_fifo_reload1_din    (w_dac0_fifo_reload1_din   ),
	.c_dac0_fifo_reload1_wr_ck  (c_dac0_fifo_reload1_wr_ck ),
	.o_dac0_fifo_reload1_wr_en  (w_dac0_fifo_reload1_wr_en ),
	.i_dac0_fifo_reload1_full   (w_dac0_fifo_reload1_full  ),
	.i_dac0_fifo_reload1_wr_ack (w_dac0_fifo_reload1_wr_ack),
	
	//
	.o_dac0_fifo_reload2_rst    (w_dac0_fifo_reload2_rst   ),
	.i_dac0_fifo_reload2_dout   (w_dac0_fifo_reload2_dout  ),
	.c_dac0_fifo_reload2_rd_ck  (c_dac0_fifo_reload2_rd_ck ),
	.o_dac0_fifo_reload2_rd_en  (w_dac0_fifo_reload2_rd_en ),
	.i_dac0_fifo_reload2_empty  (w_dac0_fifo_reload2_empty ),
	.i_dac0_fifo_reload2_valid  (w_dac0_fifo_reload2_valid ),
	.o_dac0_fifo_reload2_din    (w_dac0_fifo_reload2_din   ),
	.c_dac0_fifo_reload2_wr_ck  (c_dac0_fifo_reload2_wr_ck ),
	.o_dac0_fifo_reload2_wr_en  (w_dac0_fifo_reload2_wr_en ),
	.i_dac0_fifo_reload2_full   (w_dac0_fifo_reload2_full  ),
	.i_dac0_fifo_reload2_wr_ack (w_dac0_fifo_reload2_wr_ack),

	//
	.o_dac1_fifo_reload1_rst    (w_dac1_fifo_reload1_rst   ),
	.i_dac1_fifo_reload1_dout   (w_dac1_fifo_reload1_dout  ),
	.c_dac1_fifo_reload1_rd_ck  (c_dac1_fifo_reload1_rd_ck ),
	.o_dac1_fifo_reload1_rd_en  (w_dac1_fifo_reload1_rd_en ),
	.i_dac1_fifo_reload1_empty  (w_dac1_fifo_reload1_empty ),
	.i_dac1_fifo_reload1_valid  (w_dac1_fifo_reload1_valid ),
	.o_dac1_fifo_reload1_din    (w_dac1_fifo_reload1_din   ),
	.c_dac1_fifo_reload1_wr_ck  (c_dac1_fifo_reload1_wr_ck ),
	.o_dac1_fifo_reload1_wr_en  (w_dac1_fifo_reload1_wr_en ),
	.i_dac1_fifo_reload1_full   (w_dac1_fifo_reload1_full  ),
	.i_dac1_fifo_reload1_wr_ack (w_dac1_fifo_reload1_wr_ack),

	//
	.o_dac1_fifo_reload2_rst    (w_dac1_fifo_reload2_rst   ),
	.i_dac1_fifo_reload2_dout   (w_dac1_fifo_reload2_dout  ),
	.c_dac1_fifo_reload2_rd_ck  (c_dac1_fifo_reload2_rd_ck ),
	.o_dac1_fifo_reload2_rd_en  (w_dac1_fifo_reload2_rd_en ),
	.i_dac1_fifo_reload2_empty  (w_dac1_fifo_reload2_empty ),
	.i_dac1_fifo_reload2_valid  (w_dac1_fifo_reload2_valid ),
	.o_dac1_fifo_reload2_din    (w_dac1_fifo_reload2_din   ),
	.c_dac1_fifo_reload2_wr_ck  (c_dac1_fifo_reload2_wr_ck ),
	.o_dac1_fifo_reload2_wr_en  (w_dac1_fifo_reload2_wr_en ),
	.i_dac1_fifo_reload2_full   (w_dac1_fifo_reload2_full  ),
	.i_dac1_fifo_reload2_wr_ack (w_dac1_fifo_reload2_wr_ack),

	//
	.valid()
);


// fifo_generator_4_* : dac pattern ... 16 bit dac code + 16 bit duration count
// 32 bits
// 4096 depth = 2^12    or 2048
// 2^12 * 4 byte = 16KB or 8KB
//
// fifo in  : from USB end-points
// fifo out : to dac_pattern_gen for FDCS test
//
// fifo loopback setup ... considered later
//   clock sharing is must for loopback ... thus, loopback fifo will be considered.

// fifo_generator_4 // DAC fifo 
//   width "32-bit"
//   depth "4096 = 2^12"
//   standard read mode
//   rd 72MHz // used in rd 200MHz
//   wr 72MHz // used in wr 72MHz or okClk 100.806MHz

// fifo_generator_4_1 // DAC fifo 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz

// fifo_generator_4_1_1 // DAC fifo 
//   width "32-bit"
//   depth "512 = 2^9"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz

// fifo_generator_4_1_2 // DAC fifo 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz


// fifo_generator_4_2 // DAC fifo 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz
//   block ram 
//   output pipeline register (embedded and fabric)

// fifo_generator_4_2_1 // DAC fifo 
//   width "32-bit"
//   depth "512 = 2^9"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz
//   block ram 
//   output pipeline register (embedded and fabric)

// fifo_generator_4_2_2 // DAC fifo 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz
//   block ram 
//   output pipeline register (embedded and fabric)


 
//  fifo_generator_4_1_1  fifo_dac0_inst (
//    .rst       (~reset_n | w_fifo_dac0_rst), // input wire rst
//    .wr_clk    (clk_bus),  // input wire wr_clk
//    .wr_en     (test_fifo_in_wr),      // input wire wr_en
//    .din       (test_fifo_in_data0), // input wire [31 : 0] din
//    //
//    .rd_clk    (c_fifo_dac0_rd_ck),  // input wire rd_clk
//    .rd_en     (test_fifo_out_rd | w_fifo_dac0_rd_en),      // input wire rd_en
//    .dout      (w_fifo_dac0_dout), // output wire [31 : 0] dout
//    //
//    .full      (),  // output wire full
//    .wr_ack    (),  // output wire wr_ack
//    .empty     (w_fifo_dac0_empty),  // output wire empty
//    .valid     (w_fifo_dac0_valid)   // output wire valid
//  );
//  
//  fifo_generator_4_1_1  fifo_dac1_inst (
//    .rst       (~reset_n | w_fifo_dac1_rst), // input wire rst
//    .wr_clk    (clk_bus),  // input wire wr_clk
//    .wr_en     (test_fifo_in_wr),      // input wire wr_en
//    .din       (test_fifo_in_data1), // input wire [31 : 0] din
//    //
//    .rd_clk    (c_fifo_dac1_rd_ck),  // input wire rd_clk
//    .rd_en     (test_fifo_out_rd | w_fifo_dac1_rd_en),      // input wire rd_en
//    .dout      (w_fifo_dac1_dout), // output wire [31 : 0] dout
//    //
//    .full      (),  // output wire full
//    .wr_ack    (),  // output wire wr_ack
//    .empty     (w_fifo_dac1_empty),  // output wire empty
//    .valid     (w_fifo_dac1_valid)   // output wire valid
//  );
//  


fifo_generator_4_1_2  fifo_dac0_inst (
  .rst       (~reset_n | w_fifo_dac0_rst), // input wire rst
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (clk_bus),  // input wire wr_clk
  .wr_en     (test_fifo_in_wr),      // input wire wr_en
  .din       (test_fifo_in_data0), // input wire [31 : 0] din
  //
  .rd_clk    (c_fifo_dac0_rd_ck),  // input wire rd_clk
  .rd_en     (test_fifo_out_rd | w_fifo_dac0_rd_en),      // input wire rd_en
  .dout      (w_fifo_dac0_dout), // output wire [31 : 0] dout
  //
  .full      (),  // output wire full
  .wr_ack    (),  // output wire wr_ack
  .empty     (w_fifo_dac0_empty),  // output wire empty
  .valid     (w_fifo_dac0_valid)   // output wire valid
);

fifo_generator_4_1_2  fifo_dac1_inst (
  .rst       (~reset_n | w_fifo_dac1_rst), // input wire rst
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (clk_bus),  // input wire wr_clk
  .wr_en     (test_fifo_in_wr),      // input wire wr_en
  .din       (test_fifo_in_data1), // input wire [31 : 0] din
  //
  .rd_clk    (c_fifo_dac1_rd_ck),  // input wire rd_clk
  .rd_en     (test_fifo_out_rd | w_fifo_dac1_rd_en),      // input wire rd_en
  .dout      (w_fifo_dac1_dout), // output wire [31 : 0] dout
  //
  .full      (),  // output wire full
  .wr_ack    (),  // output wire wr_ack
  .empty     (w_fifo_dac1_empty),  // output wire empty
  .valid     (w_fifo_dac1_valid)   // output wire valid
);



// fifo_generator_5 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "2048 = 2^11"
//   standard read mode
//   rd 200MHz
//   wr 200MHz

// fifo_generator_5_1 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz

// fifo_generator_5_1_1 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "512 = 2^9"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz

// fifo_generator_5_1_2 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz


// fifo_generator_5_2 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   clk 200MHz // common
//   built-in fifo
//   output pipeline register // embed // reload data missing!!

// fifo_generator_5_3 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   clk 200MHz // common
//   block ram  
//   output pipeline register // embed and fabric?

// fifo_generator_5_4 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "2048 = 2^11"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz
//   block ram 
//   output pipeline register (embedded and fabric)

// fifo_generator_5_4_1 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "512 = 2^9"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz
//   block ram 
//   output pipeline register (embedded and fabric)

// fifo_generator_5_4_2 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz
//   block ram 
//   output pipeline register (embedded and fabric)


//  fifo_generator_5_1_1  fifo_reload1_dac0_inst (
//    .rst       (~reset_n | w_dac0_fifo_reload1_rst),  // input wire rst
//    .wr_clk    (c_dac0_fifo_reload1_wr_ck),  // input wire wr_clk
//    .wr_en     (w_dac0_fifo_reload1_wr_en),  // input wire wr_en
//    .din       (w_dac0_fifo_reload1_din),  // input wire [31 : 0] din
//    //
//    .rd_clk    (c_dac0_fifo_reload1_rd_ck),  // input wire rd_clk
//    .rd_en     (w_dac0_fifo_reload1_rd_en),  // input wire rd_en
//    .dout      (w_dac0_fifo_reload1_dout),  // output wire [31 : 0] dout
//    //
//    .full      (w_dac0_fifo_reload1_full),  // output wire full
//    .wr_ack    (w_dac0_fifo_reload1_wr_ack),  // output wire wr_ack
//    .empty     (w_dac0_fifo_reload1_empty),  // output wire empty
//    .valid     (w_dac0_fifo_reload1_valid)   // output wire valid
//  );
//  
//  fifo_generator_5_1_1  fifo_reload2_dac0_inst (
//    .rst       (~reset_n | w_dac0_fifo_reload2_rst),  // input wire rst
//    .wr_clk    (c_dac0_fifo_reload2_wr_ck),  // input wire wr_clk
//    .wr_en     (w_dac0_fifo_reload2_wr_en),  // input wire wr_en
//    .din       (w_dac0_fifo_reload2_din),  // input wire [31 : 0] din
//    //
//    .rd_clk    (c_dac0_fifo_reload2_rd_ck),  // input wire rd_clk
//    .rd_en     (w_dac0_fifo_reload2_rd_en),  // input wire rd_en
//    .dout      (w_dac0_fifo_reload2_dout),  // output wire [31 : 0] dout
//    //
//    .full      (w_dac0_fifo_reload2_full),  // output wire full
//    .wr_ack    (w_dac0_fifo_reload2_wr_ack),  // output wire wr_ack
//    .empty     (w_dac0_fifo_reload2_empty),  // output wire empty
//    .valid     (w_dac0_fifo_reload2_valid)   // output wire valid
//  );
//  
//  
//  fifo_generator_5_1_1  fifo_reload1_dac1_inst (
//    .rst       (~reset_n | w_dac1_fifo_reload1_rst),  // input wire rst
//    .wr_clk    (c_dac1_fifo_reload1_wr_ck),  // input wire wr_clk
//    .wr_en     (w_dac1_fifo_reload1_wr_en),  // input wire wr_en
//    .din       (w_dac1_fifo_reload1_din),  // input wire [31 : 0] din
//    //
//    .rd_clk    (c_dac1_fifo_reload1_rd_ck),  // input wire rd_clk
//    .rd_en     (w_dac1_fifo_reload1_rd_en),  // input wire rd_en
//    .dout      (w_dac1_fifo_reload1_dout),  // output wire [31 : 0] dout
//    //
//    .full      (w_dac1_fifo_reload1_full),  // output wire full
//    .wr_ack    (w_dac1_fifo_reload1_wr_ack),  // output wire wr_ack
//    .empty     (w_dac1_fifo_reload1_empty),  // output wire empty
//    .valid     (w_dac1_fifo_reload1_valid)   // output wire valid
//  );
//  
//  fifo_generator_5_1_1  fifo_reload2_dac1_inst (
//    .rst       (~reset_n | w_dac1_fifo_reload2_rst),  // input wire rst
//    .wr_clk    (c_dac1_fifo_reload2_wr_ck),  // input wire wr_clk
//    .wr_en     (w_dac1_fifo_reload2_wr_en),  // input wire wr_en
//    .din       (w_dac1_fifo_reload2_din),  // input wire [31 : 0] din
//    //
//    .rd_clk    (c_dac1_fifo_reload2_rd_ck),  // input wire rd_clk
//    .rd_en     (w_dac1_fifo_reload2_rd_en),  // input wire rd_en
//    .dout      (w_dac1_fifo_reload2_dout),  // output wire [31 : 0] dout
//    //
//    .full      (w_dac1_fifo_reload2_full),  // output wire full
//    .wr_ack    (w_dac1_fifo_reload2_wr_ack),  // output wire wr_ack
//    .empty     (w_dac1_fifo_reload2_empty),  // output wire empty
//    .valid     (w_dac1_fifo_reload2_valid)   // output wire valid
//  );
//  


fifo_generator_5_1_2  fifo_reload1_dac0_inst (
  .rst       (~reset_n | w_dac0_fifo_reload1_rst),  // input wire rst
  //.clk       (c_dac0_fifo_reload1_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac0_fifo_reload1_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_reload1_wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_reload1_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac0_fifo_reload1_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_reload1_rd_en),  // input wire rd_en
  .dout      (w_dac0_fifo_reload1_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac0_fifo_reload1_full),  // output wire full
  .wr_ack    (w_dac0_fifo_reload1_wr_ack),  // output wire wr_ack
  .empty     (w_dac0_fifo_reload1_empty),  // output wire empty
  .valid     (w_dac0_fifo_reload1_valid)   // output wire valid
);

fifo_generator_5_1_2  fifo_reload2_dac0_inst (
  .rst       (~reset_n | w_dac0_fifo_reload2_rst),  // input wire rst
  //.clk       (c_dac0_fifo_reload2_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac0_fifo_reload2_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_reload2_wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_reload2_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac0_fifo_reload2_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_reload2_rd_en),  // input wire rd_en
  .dout      (w_dac0_fifo_reload2_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac0_fifo_reload2_full),  // output wire full
  .wr_ack    (w_dac0_fifo_reload2_wr_ack),  // output wire wr_ack
  .empty     (w_dac0_fifo_reload2_empty),  // output wire empty
  .valid     (w_dac0_fifo_reload2_valid)   // output wire valid
);


fifo_generator_5_1_2  fifo_reload1_dac1_inst (
  .rst       (~reset_n | w_dac1_fifo_reload1_rst),  // input wire rst
  //.clk       (c_dac1_fifo_reload1_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac1_fifo_reload1_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_reload1_wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_reload1_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac1_fifo_reload1_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_reload1_rd_en),  // input wire rd_en
  .dout      (w_dac1_fifo_reload1_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac1_fifo_reload1_full),  // output wire full
  .wr_ack    (w_dac1_fifo_reload1_wr_ack),  // output wire wr_ack
  .empty     (w_dac1_fifo_reload1_empty),  // output wire empty
  .valid     (w_dac1_fifo_reload1_valid)   // output wire valid
);

fifo_generator_5_1_2  fifo_reload2_dac1_inst (
  .rst       (~reset_n | w_dac1_fifo_reload2_rst),  // input wire rst
  //.clk       (c_dac1_fifo_reload2_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac1_fifo_reload2_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_reload2_wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_reload2_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac1_fifo_reload2_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_reload2_rd_en),  // input wire rd_en
  .dout      (w_dac1_fifo_reload2_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac1_fifo_reload2_full),  // output wire full
  .wr_ack    (w_dac1_fifo_reload2_wr_ack),  // output wire wr_ack
  .empty     (w_dac1_fifo_reload2_empty),  // output wire empty
  .valid     (w_dac1_fifo_reload2_valid)   // output wire valid
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
	test_fifo_in_wr   = 1'b0 ; //	
	test_fifo_out_rd  = 1'b0 ; //	
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


//// MLS test //{
// MLS test address / data setup 
#200;
DACX_MLS_WRITE_ADRS(32'h_0000_0000);
//DACX_MLS_WRITE_DATA(32'h_03FF_03FF);
DACX_MLS_WRITE_DATA(32'h_3FFF_3FFF);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0001);
//DACX_MLS_WRITE_DATA(32'h_07FF_07FF);
DACX_MLS_WRITE_DATA(32'h_7FFF_7FFF);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0002);
//DACX_MLS_WRITE_DATA(32'h_03FF_03FF);
DACX_MLS_WRITE_DATA(32'h_3FFF_3FFF);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0003);
DACX_MLS_WRITE_DATA(32'h_0000_0000);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0004);
//DACX_MLS_WRITE_DATA(32'h_FC00_FC00);
DACX_MLS_WRITE_DATA(32'h_C000_C000);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0005);
//DACX_MLS_WRITE_DATA(32'h_F800_F800);
DACX_MLS_WRITE_DATA(32'h_8000_8000);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0006);
//DACX_MLS_WRITE_DATA(32'h_FC00_FC00);
DACX_MLS_WRITE_DATA(32'h_C000_C000);
//
DACX_MLS_WRITE_ADRS(32'h_0000_0007);
DACX_MLS_WRITE_DATA(32'h_0000_0000);
#0; 
// MLS test run
#200;
DACX_MLS_RUN_TEST();
#1000;
DACX_MLS_STOP_TEST();
#0; 
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


//// FDCS test //{

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
FIFO_IN_DATA(32'h_3FFF_0000, 32'h_3FFF_0002); // (data0, data1)
FIFO_IN_DATA(32'h_7FFF_0000, 32'h_7FFF_0004);
FIFO_IN_DATA(32'h_3FFF_0001, 32'h_3FFF_0002);
FIFO_IN_DATA(32'h_FFFE_0002, 32'h_0000_0001);
FIFO_IN_DATA(32'h_C000_0002, 32'h_C000_0002);
FIFO_IN_DATA(32'h_8000_0001, 32'h_8000_0004);
FIFO_IN_DATA(32'h_C000_0000, 32'h_C000_0002);
FIFO_IN_DATA(32'h_0001_0000, 32'h_0000_0001);
//
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
//}

// FDCS test repeat setup 1 //{
#200;
DACX_FDCS_WRITE_REPEAT(32'h_0000_0000); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0006_0003); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0002_0001); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
//DACX_FDCS_WRITE_REPEAT(32'h_0004_0002); // r_dcs_repeat = {r_dcs_repeat_dac1, r_dcs_repeat_dac0}
#0; 
//}

// FDCS test run 1 //{
#200;
DACX_FDCS_RUN_TEST();
#1000;
//@(posedge (w_fifo_dac0_empty&w_fifo_dac1_empty))
//@(posedge (w_fifo_dac0_empty))
//@(negedge (w_dac0_active_dco | w_dac1_active_dco))
#100
DACX_FDCS_STOP_TEST();
#0; 
//}


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

//// tasks based on clk_10M  

// MLS
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

// DCS
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


// FDCS
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


//// task based on clk_bus

// FIFO IN test 
task FIFO_IN_DATA; // (data0, data1)
	input [31:0] data0;
	input [31:0] data1;
	begin
		@(posedge clk_bus);
		test_fifo_in_data0    = data0;
		test_fifo_in_data1    = data1;
		@(posedge clk_bus);
		test_fifo_in_wr = 1'b1;
		@(posedge clk_bus);
		test_fifo_in_wr = 1'b0;
	end
endtask
//

//// task based on clk_400M

// FIFO OUT test 
task FIFO_OUT_DATA;
	begin
		@(posedge clk_400M);
		test_fifo_out_rd = 1'b1;
		@(posedge clk_400M);
		test_fifo_out_rd = 1'b0;
	end
endtask


	
// task IO bus WRITE 
//task MCS_IO_BUS_WRITE;
//	input  [31:0] adrs;
//	input  [31:0] data;
//	begin 
//		@(posedge clk_72M);
//		test_strb_adrs = 1'b1;
//		test_adrs      = adrs; //
//		test_strb_wr   = 1'b1;
//		test_data      = data; //
//		@(posedge clk_72M);
//		test_strb_adrs = 1'b0;
//		test_adrs      = 32'h0;
//		test_strb_wr   = 1'b0;
//		test_data      = 32'h0; //
//		@(negedge IO_ready); // neg
//	end
//endtask 

// task 
// task wi write 
//task MCS_WI_WRITE;
//	input  [31:0] offset;
//	input  [31:0] data;
//	input  [31:0] mask;
//	begin
//	//parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
//	MCS_IO_BUS_WRITE(32'h_C000_0F10, mask);
//	#14;
//	MCS_IO_BUS_WRITE(32'h_C000_0000+(offset<<4), data); 
//	#14;
//	end
//endtask 

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
