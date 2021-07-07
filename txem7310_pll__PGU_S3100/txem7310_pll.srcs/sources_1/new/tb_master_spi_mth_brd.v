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
	
//  reg clk_12M = 1'b0; // 12MHz
//  	always
//  	#41.6666667 clk_12M = ~clk_12M;  

//}

//// test signals 
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




/* DUT */
//
wire [ 5:0] w_frame_data_C = {1'b0,test_frame_rdwr,4'b0000}; // control  data on MOSI
//wire [ 9:0] w_frame_data_A = 10'h380;  // address  data on MOSI
wire [ 9:0] w_frame_data_A = test_adrs;  // address  data on MOSI
//wire [15:0] w_frame_data_D = 16'hA35C; // register data on MOSI
wire [15:0] w_frame_data_D = test_data; // register data on MOSI
wire [15:0] w_frame_data_B;            // readback data on MISO
//
wire w_trig_frame = test_frame;
wire w_done_frame;
//
wire w_SS_B;
wire w_SCLK;
wire w_MOSI;
wire w_MISO;
//


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
	.clk     (clk_104M), // 104MHz
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
assign w_SSPI_SCLK = w_SSPI_MCLK;  // add delay
assign w_SSPI_MISO = w_SSPI_MOSI; // add delay
assign w_SSPI_MISO_EN = ~w_SSPI_SS_B;


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
	.i_trig_frame (w_trig_frame),
	.o_done_frame (w_done_frame),
	//
	.o_SS_B (w_SS_B),
	.o_SCLK (w_SCLK),
	.o_MOSI (w_MOSI),
	.i_MISO (w_MISO)
);

// slave SPI
wire w_MISO_S    ;
wire w_MISO_S_EN ;
//
wire [31:0] w_port_wo_sadrs_h080 = 32'hD020_0529;
wire [31:0] w_port_wo_sadrs_h088 = 32'h0000_1010; 
wire [31:0] w_port_wo_sadrs_h380 = 32'h33AA_CC55; // 0x33AACC55
//
wire [31:0] w_port_ti_sadrs_h104;
wire [31:0] w_port_to_sadrs_h194 = test_data_to;
wire [31:0] w_port_to_sadrs_h19C = test_data_to_210M;

//wire w_loopback_en = 1'b1; // loopback mode control on
wire w_loopback_en = 1'b0; // loopback mode control off
//wire w_MISO_one_bit_ahead_en = 1'b1; // MISO one bit ahead mode on 
wire w_MISO_one_bit_ahead_en = 1'b0; // MISO one bit ahead mode off 
//
slave_spi_mth_brd  slave_spi_mth_brd__inst (
	.clk     (clk_104M), // base clock clk_104M
	.reset_n (reset_n),

	//// slave SPI pins:
	.i_SPI_CS_B      (w_SS_B),
	.i_SPI_CLK       (w_SCLK),
	.i_SPI_MOSI      (w_MOSI),
	.o_SPI_MISO      (w_MISO_S   ),
	.o_SPI_MISO_EN   (w_MISO_S_EN), // MISO buffer control

	//// test register interface
	.o_port_wi_sadrs_h000    (), // [31:0] // adrs h003~h000
	.o_port_wi_sadrs_h008    (),
	//
	.i_port_wo_sadrs_h080    (w_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h088    (w_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h380    (w_port_wo_sadrs_h380), // [31:0] // adrs h383~h380
	//
	.i_ck__sadrs_h104(clk_10M),  .o_port_ti_sadrs_h104(w_port_ti_sadrs_h104),
	//
	.i_ck__sadrs_h194(clk_10M ),  .i_port_to_sadrs_h194(w_port_to_sadrs_h194), // [31:0]
	.i_ck__sadrs_h19C(clk_210M),  .i_port_to_sadrs_h19C(w_port_to_sadrs_h19C), // [31:0]

	//
	.o_wr__sadrs_h24C (),  .o_port_po_sadrs_h24C (), // [31:0]  // MEM_PI	0x24C	pi93 //$$
	//
	.o_rd__sadrs_h280 (),  .i_port_po_sadrs_h280 (32'h32AB_CD54), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	
	//// loopback mode control 
	.i_loopback_en           (w_loopback_en),


	//// MISO timing control 
	//.i_slack_count_MISO      (3'd0), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	.i_slack_count_MISO      (3'd1), // [2:0] // '1' for MISO on SCLK rising edge + 1 + 1/(72MHz) delay
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
// test init
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
	$finish;
	
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
	$finish;
	
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
	$finish;
	
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
	$finish;
	
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
	$finish;
	
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
	$finish;
	
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
@(posedge clk_10M)
test_data_to = 32'h1010_0101;
@(posedge clk_10M)
test_data_to = 32'h0000_0000;
#200;
//// read trig out
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
///////////////////////
	$finish;
	
#0; 
//// test trig out
@(posedge clk_210M)
test_data_to_210M = 32'h1100_1001;
@(posedge clk_210M)
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
///////////////////////
	$finish;

#0; 
//// test trig out // simultaneous trigout-in and readout
// frame start
begin : frame_rd__trig__h19C__simult
	test_frame_rdwr		= 1'b1; // 1 for read
	test_adrs       = 10'h19C;
	#200;
	@(posedge clk_104M)
	test_frame 		= 1'b1; 
	@(posedge clk_210M)
	test_data_to_210M = 32'h0011_0101;
	@(posedge clk_210M)
	test_data_to_210M = 32'h0000_0000;
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
//// test pipe out
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
///////////////////////
	$finish;
	
#0; 
//// test pipe in 
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
///////////////////////
	$finish;


end



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
