`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_control_eeprom__11AA160T
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test :  control_eeprom__11AA160T.v  test_model__eeprom__11AA160T.v
//
//////////////////////////////////////////////////////////////////////////////////


module tb_control_eeprom__11AA160T;


//// clock and reset

reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg clk_100K = 1'b0; // assume 100kHz or 10us
	always
	#5000 	clk_100K = ~clk_100K; // toggle every 5000ns --> clock 10000ns 


reg reset_n = 1'b0;
wire reset = ~reset_n;

//  //
//  reg clk_144M = 1'b0; // 144MHz
//  reg clk_72M = 1'b0; // 72MHz
//  always begin
//  	#3.47222222;
//  	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
//  	clk_72M = ~clk_72M;
//  	#3.47222222 
//  	clk_144M = ~clk_144M; // toggle every 3.47222222 ns --> clock 6.94444444 ns
//  	end
//  
//  reg clk_210M = 1'b0; // 210MHz 
//  	always
//  	#2.38095238  clk_210M = ~clk_210M; // toggle every 2.38095238 nanoseconds
//  

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



//// test signals 
reg test_reset;
reg test_frame;
reg [7:0] test_cmd;
reg [11:0] test_num_bytes; 
reg [7:0] test_dat;
reg test_dat_wr;
reg test_dat_rd;


//reg test_frame_rdwr; // 0 for write, 1 for read
//reg [ 9:0] test_adrs;
//reg [15:0] test_data;
//reg [31:0] test_data_to;
//reg [31:0] test_data_to_210M;

reg [127:0] test_pattern;


/* DUT */

wire w_en_SBP     = 1'b1;
wire w_trig_frame = test_frame;
wire w_done_frame   ;
wire w_done_frame_TO;

wire w_SCIO_DI;
wire w_SCIO_DO;
wire w_SCIO_OE;

// test paramters
parameter CMD_READ__03 = 8'h03; // SEQ1
parameter CMD_CRRD__06 = 8'h06; // SEQ2
parameter CMD_WRITE_6C = 8'h6C; // SEQ3
parameter CMD_WREN__96 = 8'h96; // SEQ4
parameter CMD_WRDI__91 = 8'h91; // SEQ4
parameter CMD_RDSR__05 = 8'h05; // SEQ5
parameter CMD_WRSR__6E = 8'h6E; // SEQ6
parameter CMD_ERAL__6D = 8'h6D; // SEQ4
parameter CMD_SETAL_67 = 8'h67; // SEQ4
//
wire [7:0] w_frame_data_CMD = test_cmd;

wire [11:0] w_num_bytes_DAT = test_num_bytes; // 12'd03

wire [7:0] w_frame_data_DAT = test_dat; // 8'hC3;
wire w_frame_data_DAT_wr_en = test_dat_wr;
//
wire w_frame_data_DAT_rd_en = test_dat_rd;

control_eeprom__11AA160T  control_eeprom__11AA160T_inst (
	//
	.clk     (clk_10M), //	input  wire // 10MHz
	.reset_n (reset_n&(~test_reset)), //	input  wire
	
	// controls //{
	.i_trig_frame     (w_trig_frame   ), //	input  wire  
	.o_done_frame     (w_done_frame   ), //	output wire  
	.o_done_frame_TO  (w_done_frame_TO), //	output wire  // trig out @ clk
	//	
	.i_en_SBP         (w_en_SBP), //	input  wire  // enable SBP (stand-by pulse)
	//
	.i_frame_data_SHD (8'h55), //	input  wire [7:0] // 8-bit followed by MAK and NoSAK
	.i_frame_data_DVA (8'hA0), //	input  wire [7:0] // 8-bit followed by MAK and SAK
	.i_frame_data_CMD (w_frame_data_CMD), //	input  wire [7:0] // 8-bit followed by MAK/NoMAK and NoSAK
	.i_frame_data_ADH (8'h35), //	input  wire [7:0] // 8-bit followed by MAK and SAK
	.i_frame_data_ADL (8'hAC), //	input  wire [7:0] // 8-bit followed by MAK and SAK
	.i_frame_data_STA (8'hA5), //	input  wire [7:0] // 8-bit followed by MAK/NoMAK and SAK
	.o_frame_data_STA (), //	output wire [7:0] // 8-bit followed by MAK/NoMAK and SAK
	//	
	.i_num_bytes_DAT  (w_num_bytes_DAT), //	input  wire [11:0] // 2048=2^11 ... 12-bit assigned
	//}
	
	// FIFO/PIPE interface //{
	.i_reset_fifo             (1'b0), //
	//
	.i_frame_data_DAT         (w_frame_data_DAT), //	input  wire [7:0] // 8-bit followed by MAK/NoMAK and SAK
	.o_frame_data_DAT         (), //	output wire [7:0] // 8-bit followed by MAK/NoMAK and SAK
	//
	.i_frame_data_DAT_wr_en   (w_frame_data_DAT_wr_en), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_wr_clk  (clk_104M), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_rd_en   (w_frame_data_DAT_rd_en), // input wire // control for o_frame_data_DAT	
	.i_frame_data_DAT_rd_clk  (clk_104M), // input wire // control for o_frame_data_DAT	
	//}
	
	// IO ports //{
	.i_SCIO_DI        (w_SCIO_DI), // input  wire 
	.o_SCIO_DO        (w_SCIO_DO), // output wire 
	.o_SCIO_OE        (w_SCIO_OE), // output wire 
	//}

	.valid            ()//	output wire 
);

wire w_model_SCIO_DI;
wire w_model_SCIO_DO = w_SCIO_DO; // test_pattern[127];
wire w_model_SCIO_OE = w_SCIO_OE; // 1'b1;
//
assign w_SCIO_DI = w_model_SCIO_DI;

test_model__eeprom__11AA160T  test_model__eeprom__11AA160T__inst (
	//
	.clk     (clk_10M), // 10MHz
	.reset_n (reset_n), 
	
	// io to test
	.o_model_SCIO_DI (w_model_SCIO_DI),
	.i_model_SCIO_DO (w_model_SCIO_DO),
	.i_model_SCIO_OE (w_model_SCIO_OE),
	
	// status output
	.o_SBP_ack (),
	.o_SHD_ack (),
	.o_DVA_ack (),
	.o_CMD_ack (),
	.o_ADH_ack (),
	.o_ADL_ack (),
	.o_DAT_ack (),
	.o_DAT_rdy (),
	.o_STA_ack (),
	.o_STA_rdy (),
	
	.valid ()
);




//  //
//  wire [ 5:0] w_frame_data_C = {1'b0,test_frame_rdwr,4'b0000}; // control  data on MOSI
//  //wire [ 9:0] w_frame_data_A = 10'h380;  // address  data on MOSI
//  wire [ 9:0] w_frame_data_A = test_adrs;  // address  data on MOSI
//  //wire [15:0] w_frame_data_D = 16'hA35C; // register data on MOSI
//  wire [15:0] w_frame_data_D = test_data; // register data on MOSI
//  wire [15:0] w_frame_data_B;            // readback data on MISO
//  wire w_trig_frame = test_frame;
//  wire w_done_frame;
//  wire w_SS_B;
//  wire w_SCLK;
//  wire w_MOSI;
//  wire w_MISO;
//  //

//  // master SPI
//  test_model__master_spi__from_mth_brd  test_model__master_spi__from_mth_brd__inst (  
//  	.clk     (clk_26M), // base clock 26MHz
//  	.reset_n (reset_n),
//  	.en      (1'b1),
//  	//
//  	.i_frame_data_C(w_frame_data_C) , // [ 5:0] // control  data on MOSI
//  	.i_frame_data_A(w_frame_data_A) , // [ 9:0] // address  data on MOSI
//  	.i_frame_data_D(w_frame_data_D) , // [15:0] // register data on MOSI
//  	.o_frame_data_B(w_frame_data_B) , // [15:0] // readback data on MISO
//  	//
//  	.i_trig_frame (w_trig_frame),
//  	.o_done_frame (w_done_frame),
//  	//
//  	.o_SS_B (w_SS_B),
//  	.o_SCLK (w_SCLK),
//  	.o_MOSI (w_MOSI),
//  	.i_MISO (w_MISO)
//  );

//  // slave SPI
//  wire w_MISO_S    ;
//  wire w_MISO_S_EN ;
//  //
//  wire [31:0] w_port_wo_sadrs_h080 = 32'hD020_0529;
//  wire [31:0] w_port_wo_sadrs_h088 = 32'h0000_1010; 
//  wire [31:0] w_port_wo_sadrs_h380 = 32'h33AA_CC55; // 0x33AACC55
//  //
//  wire [31:0] w_port_ti_sadrs_h104;
//  wire [31:0] w_port_to_sadrs_h194 = test_data_to;
//  wire [31:0] w_port_to_sadrs_h19C = test_data_to_210M;
//  
//  //wire w_loopback_en = 1'b1; // loopback mode control on
//  wire w_loopback_en = 1'b0; // loopback mode control off
//  //wire w_MISO_one_bit_ahead_en = 1'b1; // MISO one bit ahead mode on 
//  wire w_MISO_one_bit_ahead_en = 1'b0; // MISO one bit ahead mode off 
//  //
//  slave_spi_mth_brd  slave_spi_mth_brd__inst (
//  	.clk     (clk_104M), // base clock clk_104M
//  	.reset_n (reset_n),
//  
//  	//// slave SPI pins:
//  	.i_SPI_CS_B      (w_SS_B),
//  	.i_SPI_CLK       (w_SCLK),
//  	.i_SPI_MOSI      (w_MOSI),
//  	.o_SPI_MISO      (w_MISO_S   ),
//  	.o_SPI_MISO_EN   (w_MISO_S_EN), // MISO buffer control
//  
//  	//// test register interface
//  	.o_port_wi_sadrs_h000    (), // [31:0] // adrs h003~h000
//  	.o_port_wi_sadrs_h008    (),
//  	//
//  	.i_port_wo_sadrs_h080    (w_port_wo_sadrs_h080),
//  	.i_port_wo_sadrs_h088    (w_port_wo_sadrs_h088),
//  	.i_port_wo_sadrs_h380    (w_port_wo_sadrs_h380), // [31:0] // adrs h383~h380
//  	//
//  	.i_ck__sadrs_h104(clk_10M),  .o_port_ti_sadrs_h104(w_port_ti_sadrs_h104),
//  	//
//  	.i_ck__sadrs_h194(clk_10M ),  .i_port_to_sadrs_h194(w_port_to_sadrs_h194), // [31:0]
//  	.i_ck__sadrs_h19C(clk_210M),  .i_port_to_sadrs_h19C(w_port_to_sadrs_h19C), // [31:0]
//  
//  	.o_rd__sadrs_h280(),  .i_port_po_sadrs_h280(32'h32AB_CD54), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
//  	
//  	//// loopback mode control 
//  	.i_loopback_en           (w_loopback_en),
//  
//  
//  	//// MISO timing control 
//  	//.i_slack_count_MISO      (3'd0), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
//  	.i_slack_count_MISO      (3'd1), // [2:0] // '1' for MISO on SCLK rising edge + 1 + 1/(72MHz) delay
//  	//.i_slack_count_MISO      (3'd2), // [2:0] // '2' for MISO on SCLK rising edge + 1 + 2/(72MHz) delay
//  	//.i_slack_count_MISO      (3'd4), // [2:0] // '4' for MISO on SCLK rising edge + 1 + 4/(72MHz) delay
//  	//.i_slack_count_MISO      (3'd3), // [2:0] // '3' for MISO on SCLK rising edge + 1 + 4/(72MHz) delay
//  	//
//  	.i_MISO_one_bit_ahead_en (w_MISO_one_bit_ahead_en),
//  	
//  	//// miso return contents
//  	.i_board_id      (4'b0110), // [3:0] // slot ID
//  	.i_board_status  (8'hC5  ), // [7:0] // board status
//  	
//  
//  	.valid    () 
//  );

//  // MISO buf control
//  assign w_MISO = (w_MISO_S_EN)?  w_MISO_S : 1'b0;


/* test signals */

// CMD_READ__03
// CMD_CRRD__06
// CMD_WRITE_6C
// CMD_WREN__96
// CMD_WRDI__91
// CMD_RDSR__05
// CMD_WRSR__6E
// CMD_ERAL__6D
// CMD_SETAL_67

//// system reset ////
initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

//// test sequence ////
initial begin
#0	;
//// test init
begin : test_sig__init
	test_reset        = 1'b0;
	test_frame        = 1'b0;
	//
	test_num_bytes    = 13'b0;
	test_dat          =  8'b0;
	test_dat_wr       =  1'b0;
	test_dat_rd       =  1'b0;	
	
//	test_frame_rdwr	  = 1'b0;
//	test_adrs         = 10'h000;
//	test_data         = 16'h0000;
//	test_data_to      = 32'h0000_0000;
//	test_data_to_210M = 32'h0000_0000;
	//
	end
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;

//// test reset
begin : test_reset__gen
	test_reset 		= 1'b1; 
	#200;
	test_reset 		= 1'b0; 
	#200;
	end


// fifo setup
test_num_bytes = 12'd03;

//// frame start
TASK_TEST_FRAME(CMD_READ__03);

//// fifo out
TASK_TEST_FIFO_OUT();
TASK_TEST_FIFO_OUT();
TASK_TEST_FIFO_OUT();
//
test_num_bytes = 12'd0;

////////
$finish;
#0; 


// fifo setup
test_num_bytes = 12'd03;

//// frame start
TASK_TEST_FRAME(CMD_CRRD__06);

//// fifo out
TASK_TEST_FIFO_OUT();
TASK_TEST_FIFO_OUT();
TASK_TEST_FIFO_OUT();
//
test_num_bytes = 12'd0;

////////
$finish;
#0; 


// fifo setup
//test_num_bytes = 12'd03;
test_num_bytes = 12'd32;

//// setup fifo in 
TASK_TEST_FIFO_IN(8'hC8);
TASK_TEST_FIFO_IN(8'hC9);
TASK_TEST_FIFO_IN(8'hCA);
TASK_TEST_FIFO_IN(8'hCB);
TASK_TEST_FIFO_IN(8'hCC);
TASK_TEST_FIFO_IN(8'hCD);
TASK_TEST_FIFO_IN(8'hCE);
TASK_TEST_FIFO_IN(8'hCF);
//
TASK_TEST_FIFO_IN(8'hE8);
TASK_TEST_FIFO_IN(8'hE9);
TASK_TEST_FIFO_IN(8'hEA);
TASK_TEST_FIFO_IN(8'hEB);
TASK_TEST_FIFO_IN(8'hEC);
TASK_TEST_FIFO_IN(8'hED);
TASK_TEST_FIFO_IN(8'hEE);
TASK_TEST_FIFO_IN(8'hEF);
//
TASK_TEST_FIFO_IN(8'hE8);
TASK_TEST_FIFO_IN(8'hE9);
TASK_TEST_FIFO_IN(8'hEA);
TASK_TEST_FIFO_IN(8'hEB);
TASK_TEST_FIFO_IN(8'hEC);
TASK_TEST_FIFO_IN(8'hED);
TASK_TEST_FIFO_IN(8'hEE);
TASK_TEST_FIFO_IN(8'hEF);
//
TASK_TEST_FIFO_IN(8'hF8);
TASK_TEST_FIFO_IN(8'hF9);
TASK_TEST_FIFO_IN(8'hFA);
TASK_TEST_FIFO_IN(8'hFB);
TASK_TEST_FIFO_IN(8'hFC);
TASK_TEST_FIFO_IN(8'hFD);
TASK_TEST_FIFO_IN(8'hFE);
TASK_TEST_FIFO_IN(8'hFF);
//

//// frame start
TASK_TEST_FRAME(CMD_WRITE_6C);
//
test_num_bytes = 12'd0;

////////
$finish;
#0; 


//// frame start
TASK_TEST_FRAME(CMD_WREN__96);

////////
$finish;
#0; 

//// frame start
TASK_TEST_FRAME(CMD_WRDI__91);

////////
$finish;
#0; 

//// frame start
TASK_TEST_FRAME(CMD_RDSR__05);

////////
$finish;
#0; 

//// frame start
TASK_TEST_FRAME(CMD_WRSR__6E);

////////
$finish;
#0; 

//// frame start
TASK_TEST_FRAME(CMD_ERAL__6D);

////////
$finish;
#0; 

//// frame start
TASK_TEST_FRAME(CMD_SETAL_67);

////////
$finish;
#0; 

//////////////////////////////////////
end // initial



// test_pattern
always @(negedge clk_100K) begin : test_pattern__gen
	if (!reset_n) begin
		//test_pattern <= 32'hAA55_CC33;
		test_pattern <= 128'h0FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF; // test for SBP_ack
		end 
	else begin
		test_pattern <= {test_pattern[126:0],test_pattern[127]};
	end
end
//
assign w_MISO = test_pattern[31];


//// TASK def //{

// task test frame 
task TASK_TEST_FRAME;
	input  [7:0] i_cmd;
	//
	begin 
		test_cmd   = i_cmd;
		#200;
		test_frame = 1'b1; 
		#200;
		test_frame = 1'b0; 
		#200;
		//
		$display(" Wait for rise of w_done_frame"); 
		@(posedge w_done_frame)
		#200;
	end
endtask 

// task test fifo in 
task TASK_TEST_FIFO_IN;
	input  [7:0] i_dat;
	//
	begin 
		@(posedge clk_104M);
		test_dat    = i_dat;
		test_dat_wr = 1'b1; 
		//
		@(posedge clk_104M);
		test_dat_wr = 1'b0; 
		//
		@(posedge clk_104M);
		test_dat    = 8'b0;
		#200;
	end
endtask 

// task test fifo out
task TASK_TEST_FIFO_OUT;
	//input  [7:0] i_dat;
	//
	begin 
		@(posedge clk_104M);
		//test_dat    = i_dat;
		test_dat_rd = 1'b1; 
		//
		@(posedge clk_104M);
		test_dat_rd = 1'b0; 
		//
		@(posedge clk_104M);
		//test_dat    = 8'b0;
		#200;
	end
endtask 


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

