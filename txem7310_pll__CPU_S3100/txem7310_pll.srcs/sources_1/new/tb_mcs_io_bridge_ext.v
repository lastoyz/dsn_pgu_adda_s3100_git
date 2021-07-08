`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_mcs_io_bridge_ext
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test  mcs_io_bridge_ext.v
//
//////////////////////////////////////////////////////////////////////////////////


module tb_mcs_io_bridge_ext;


//// clock and reset
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 

reg reset_n = 1'b0;
wire reset = ~reset_n;
//
/* 
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
*/

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

//// test signals 
/* 
reg test_reset;
reg test_manual; // manual control for frame
reg test_frame;
reg [15:0] test_frame_adrs;
reg [ 5:0] test_frame_blck;
reg        test_frame_rdwr;
reg [ 2:0] test_frame_opmd;
reg [15:0] test_frame_numb;
//
reg [31:0] pattern_MISO;
//
reg [7:0] test_fifo_in_data; //
reg test_fifo_in_wr; //
reg test_fifo_out_rd; //
 */
//
reg test_strb_adrs;
reg test_strb_rd;
reg test_strb_wr;
reg [31:0] test_adrs;
reg [31:0] test_data;
reg [31:0] test_trig;
//

/* DUT */

// test io bus 
wire IO_addr_strobe      = test_strb_adrs;
wire [31:0] IO_address   = test_adrs;
wire [3:0] IO_byte_enable= 4'b0;
wire [31:0] IO_read_data ; //
wire IO_read_strobe      = test_strb_rd;
wire IO_ready            ;
wire IO_ready_ref        ;
wire [31:0] IO_write_data= test_data; 
wire IO_write_strobe     = test_strb_wr;
//
wire [31:0] w_port_wi_00_0; // control for master_spi_wz850_inst
wire [31:0] w_port_wi_01_0; // frame setup for master_spi_wz850_inst
wire [31:0] w_port_wo_20_0; // status for master_spi_wz850_inst
wire [31:0] w_port_wo_21_0; // not yet
//
wire w_ck_40; wire [31:0] w_port_ti_40; // 
wire w_ck_60; wire [31:0] w_port_to_60; // 
//
wire w_wr_80; wire [31:0] w_port_pi_80; // LAN fifo wr
wire w_wr_81; wire [31:0] w_port_pi_81; // not yet
wire w_rd_A0; wire [31:0] w_port_po_A0; // LAN fifo rd
wire w_rd_A1; wire [31:0] w_port_po_A1; // not yet
//
mcs_io_bridge_ext #(
	.XPAR_IOMODULE_IO_BASEADDR  (32'h_C000_0000),
	.MCS_IO_INST_OFFSET         (32'h_0000_0000),// instance offset
	.FPGA_IMAGE_ID              (32'h_ACAC_1414)  
) mcs_io_bridge_ext_inst0 (
	.clk(clk_72M), // assume clk3_out1_72M
	.reset_n(reset_n),
	// IO bus
	.i_IO_addr_strobe(IO_addr_strobe),    // input  wire IO_addr_strobe
	.i_IO_address(IO_address),            // input  wire [31 : 0] IO_address
	.i_IO_byte_enable(IO_byte_enable),    // input  wire [3 : 0] IO_byte_enable
	.o_IO_read_data(IO_read_data),        // output wire [31 : 0] IO_read_data
	.i_IO_read_strobe(IO_read_strobe),    // input  wire IO_read_strobe
	.o_IO_ready(IO_ready),                // output wire IO_ready
	.o_IO_ready_ref(IO_ready_ref),      // output wire IO_ready_ref
	.i_IO_write_data(IO_write_data),      // input  wire [31 : 0] IO_write_data
	.i_IO_write_strobe(IO_write_strobe),  // input  wire IO_write_strobe
	// IO port
	.o_port_wi_00(w_port_wi_00_0),          // output wire [31:0]
	.o_port_wi_01(w_port_wi_01_0),          // output wire [31:0]
	.i_port_wo_20(w_port_wo_20_0),          // input  wire [31:0]
	.i_port_wo_21(w_port_wo_21_0),          // input  wire [31:0]
	//
	.i_port_ck_40(w_ck_40),  .o_port_ti_40(w_port_ti_40), // input  wire i_ck_40, output wire [31:0]   o_port_ti_40 ,
	.i_port_ck_60(w_ck_60),  .i_port_to_60(w_port_to_60), // input  wire i_ck_60, input  wire [31:0]   i_port_to_60 ,
	//
	.o_port_wr_80(w_wr_80),  .o_port_pi_80(w_port_pi_80), // output wire o_wr_80, output wire [31:0]   o_port_pi_80 ,
	.o_port_wr_81(w_wr_81),  .o_port_pi_81(w_port_pi_81), // output wire o_wr_81, output wire [31:0]   o_port_pi_81 ,
	.o_port_rd_A0(w_rd_A0),  .i_port_po_A0(w_port_po_A0), // output wire o_rd_A0, input  wire [31:0]   i_port_po_A0 ,
	.o_port_rd_A1(w_rd_A1),  .i_port_po_A1(w_port_po_A1), // output wire o_rd_A1, input  wire [31:0]   i_port_po_A1 ,
	//
	.valid()
);
//

// test input 
assign  w_port_wo_20_0 = 32'h2020_2020;
assign  w_port_wo_21_0 = 32'h2121_2121;
assign  w_port_to_60   = test_trig; //
assign  w_port_po_A0   = 32'hA0A0_A0A0;
assign  w_port_po_A1   = 32'hA1A1_A1A1;
assign  w_ck_40        = clk_12M;
assign  w_ck_60        = clk_12M;

/*
//
wire w_trig_LAN_reset = test_reset | w_port_wi_00_0[0];
wire w_done_LAN_reset;
wire w_trig_SPI_frame = test_frame | w_port_wi_00_0[1];
wire w_done_SPI_frame;
wire w_FIFO_reset     = w_port_wi_00_0[2];
//
wire w_LAN_RSTn;
wire w_LAN_INTn;
wire w_LAN_SCSn;
wire w_LAN_SCLK;
wire w_LAN_MOSI;
wire w_LAN_MISO;
//
wire [15:0] w_frame_num_byte_data = (test_manual)? test_frame_numb : w_port_wi_00_0[31:16]; 
wire [15:0] w_frame_adrs          = (test_manual)? test_frame_adrs : w_port_wi_01_0[31:16];
wire [ 4:0] w_frame_ctrl_blck_sel = (test_manual)? test_frame_blck : w_port_wi_01_0[15:11]; // for Socket 1 TX Buffer
wire        w_frame_ctrl_rdwr_sel = (test_manual)? test_frame_rdwr : w_port_wi_01_0[10]   ; // 1 for write
wire [ 1:0] w_frame_ctrl_opmd_sel = (test_manual)? test_frame_opmd : w_port_wi_01_0[9:8]  ; // 00 for variable length
wire [ 7:0] w_frame_data_wr      ;
wire        w_frame_done_wr      ;
wire [ 7:0] w_frame_data_rd      ;
wire        w_frame_done_rd      ;
//
wire w_LAN_valid;
//
wire       w_test_fifo_in_wr      = (test_manual)? test_fifo_in_wr  : w_wr_80          ; //
wire [7:0] w_test_fifo_in_data    = (test_manual)? test_fifo_in_data: w_port_pi_80[7:0]; //
wire       w_test_fifo_out_rd     = (test_manual)? test_fifo_out_rd : w_rd_A0          ; //
wire [7:0] w_test_fifo_out_data;
//
assign w_port_po_A0 = w_test_fifo_out_data;
*/
/* 
// LAN control
master_spi_wz850 #(
	.TIME_RESET_WAIT_MS (1) // for fast sim
) master_spi_wz850_inst (
	.clk				(clk_144M), // assume clk3_out2_144M
	.reset_n			(reset_n),
	.clk_reset          (clk_12M), //12MHz
	//
	.i_trig_LAN_reset	(w_trig_LAN_reset),
	.o_done_LAN_reset	(w_done_LAN_reset), 
	.i_trig_SPI_frame	(w_trig_SPI_frame), 
	.o_done_SPI_frame	(w_done_SPI_frame), 
	//
	.o_LAN_RSTn			(w_LAN_RSTn),
	.o_LAN_INTn			(w_LAN_INTn),
	.o_LAN_SCSn			(w_LAN_SCSn),
	.o_LAN_SCLK			(w_LAN_SCLK),
	.o_LAN_MOSI			(w_LAN_MOSI),
	.i_LAN_MISO			(w_LAN_MISO),
	//
	.i_frame_adrs         	(w_frame_adrs         ),
	.i_frame_ctrl_blck_sel	(w_frame_ctrl_blck_sel),
	.i_frame_ctrl_rdwr_sel	(w_frame_ctrl_rdwr_sel),
	.i_frame_ctrl_opmd_sel	(w_frame_ctrl_opmd_sel),
	.i_frame_num_byte_data	(w_frame_num_byte_data),
	.i_frame_data_wr      	(w_frame_data_wr      ),
	.o_frame_done_wr		(w_frame_done_wr      ),
	.o_frame_data_rd      	(w_frame_data_rd      ),
	.o_frame_done_rd		(w_frame_done_rd      ),
	//
	.valid				(w_LAN_valid)		
);
//
assign w_port_wo_20_0 = {27'b0, 
	w_done_SPI_frame ,
	w_LAN_INTn ,
	w_LAN_SCSn ,
	w_LAN_RSTn ,
	w_done_LAN_reset};
// 
*/
/* 
// fifo test wr
// fifo_generator_3 
//   width "8-bit"
//   depth "16378 = 2^14"
//   standard read mode
// 
fifo_generator_3  LAN_fifo_wr_inst (
	.rst		(~reset_n | ~w_LAN_RSTn | w_FIFO_reset),  // input wire rst 
	.wr_clk		(clk_72M			),  // input wire wr_clk
	.wr_en		(w_test_fifo_in_wr	),  // input wire wr_en
	.din		(w_test_fifo_in_data),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(   	),  // output wire full
//	//	
	.rd_clk		(clk_72M			),  // input wire rd_clk
	.rd_en		(w_frame_done_wr&(w_frame_ctrl_rdwr_sel)	),  // input wire rd_en
	.dout		(w_frame_data_wr	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(   	)   // output wire empty
);
// 

// fifo test rd
fifo_generator_3  LAN_fifo_rd_inst (
	.rst		(~reset_n | ~w_LAN_RSTn | w_FIFO_reset),  // input wire rst 
	.wr_clk		(clk_72M			),  // input wire wr_clk
	.wr_en		(w_frame_done_rd&(~w_frame_ctrl_rdwr_sel)	),  // input wire wr_en
	.din		(w_frame_data_rd	),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(   	),  // output wire full
//	//	
	.rd_clk		(clk_72M				),  // input wire rd_clk
	.rd_en		(w_test_fifo_out_rd		),  // input wire rd_en
	.dout		(w_test_fifo_out_data	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(   	)   // output wire empty
);
//
 */

/* test signals */

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
// init 
	test_strb_adrs	= 1'b0;
	test_strb_rd	= 1'b0;
	test_strb_wr	= 1'b0;
	test_adrs		= 32'b0;
	test_data		= 32'b0;
	test_trig		= 32'b0;
#0	;
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;
//

// test IO bus 
#0;
$display(">> TEST IO BUS:"); 
// read FPGA_IMAGE_ID
#0;
MCS_IO_BUS_READ (32'h_C000_0F00);
#200;
// test reg 
MCS_IO_BUS_WRITE(32'h_C000_0F04,32'h_4321_ABCD);
#14
MCS_IO_BUS_READ (32'h_C000_0F04);
#200;
// setup masks 
//parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
MCS_IO_BUS_WRITE(32'h_C000_0F10,32'h_FFFF_0000);
#14
MCS_IO_BUS_READ (32'h_C000_0F10);
#14
//parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14;
MCS_IO_BUS_WRITE(32'h_C000_0F14,32'h_FF00_00FF);
#14
MCS_IO_BUS_READ (32'h_C000_0F14);
#14
//parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18;
MCS_IO_BUS_WRITE(32'h_C000_0F18,32'h_F0F0_0F0F);
#14
MCS_IO_BUS_READ (32'h_C000_0F18);
#14
//parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C;
MCS_IO_BUS_WRITE(32'h_C000_0F1C,32'h_A5A5_5A5A);
#14
MCS_IO_BUS_READ (32'h_C000_0F1C);
#14
#200;
// test wi
MCS_WI_WRITE(32'h00, 32'h_AAAA_5555, 32'h_FFFF_0000); // offset, data, mask
MCS_WI_READ (32'h00); // OK if 32'h_AAAA_0000 on test_data
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FF00_0000); // offset, data, mask
MCS_WI_READ (32'h00); // OK if 32'h_00AA_0000 on test_data
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
#200;
// test wo
MCS_WO_READ(32'h20, 32'h00FF_0F0F);
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
#200;
// test ti
MCS_TI_WRITE(32'h40, 32'h_AAAA_5555, 32'h_FFFF_0000); // offset, data, mask
MCS_TI_READ (32'h40); // 
MCS_TI_WRITE(32'h40, 32'h_0100_0000, 32'h_FF00_0000); // offset, data, mask
MCS_TI_READ (32'h40); // 
MCS_TI_WRITE(32'h40, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
#200;
// trig i_port_to_60
@(posedge w_ck_60)
test_trig = 32'hAA55_CC33;
@(posedge w_ck_60)
test_trig = 32'h0000_0000;
#200;
// test to
MCS_TO_READ(32'h60, 32'h0000_000F);
MCS_TO_READ(32'h60, 32'h0FF0_F000);
MCS_TO_READ(32'h60, 32'h00FF_0F0F);
MCS_TO_READ(32'h60, 32'hFFFF_FFFF);
#200;

///////////////////////
	$finish;

//// test seq 
// write SW_BUILD_ID
MCS_WI_WRITE(32'h00, 32'h_0000_1234, 32'h_FFFF_FFFF); // offset, data, mask
// read FPGA_IMAGE_ID
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
// write SW_BUILD_ID
MCS_WI_WRITE(32'h00, 32'h_0000_0000, 32'h_FFFF_FFFF); // offset, data, mask
// read FPGA_IMAGE_ID
MCS_WO_READ(32'h20, 32'hFFFF_FFFF);
///////////////////////
	$finish;
	
// trig LAN reset over IO bus 
$display(">>> trig LAN reset over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,32'h_0000_0001); // w_port_wi_00_0[0];
#200;
MCS_IO_BUS_WRITE(32'h_C000_0000,32'h_0000_0000); // w_port_wi_00_0[0];
#200;
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#500_000; //500us = 500_000ns
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#1000_000; //1ms = 1000us = 1000_000ns
// read w_done_LAN_reset 
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
///////////////////////
	$finish;
	
// write fifo data 
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_00AB);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_0012);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_00CD);
#14
MCS_IO_BUS_WRITE(32'h_C000_0800,32'h_0000_0089);
#14
// set up write frame 
MCS_IO_BUS_WRITE(32'h_C000_0010,{8'b0, 16'h0040, 5'h06, 1'b1, 2'b0}); // wr frame setup
#14
MCS_IO_BUS_WRITE(32'h_C000_0020,{16'd0, 16'd04}); //
#14
// trig write frame over IO bus 
$display(">>> trig write frame over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b1, 1'b0}); //
#14
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b0, 1'b0}); //
#14
// read w_done_SPI_frame
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#2000; //2us = 2000ns
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
///////////////////////
	$finish;
	
// set up read frame 
MCS_IO_BUS_WRITE(32'h_C000_0010,{8'b0, 16'h0040, 5'h06, 1'b0, 2'b0}); // rd frame setup
#14
MCS_IO_BUS_WRITE(32'h_C000_0020,{16'd0, 16'd04}); //
#14
// trig read frame over IO bus 
$display(">>> trig read frame over IO bus"); 
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b1, 1'b0}); //
#14
MCS_IO_BUS_WRITE(32'h_C000_0000,{16'd0, 14'h0, 1'b0, 1'b0}); //
#14
// read w_done_SPI_frame
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#2000; //2us = 2000ns
MCS_IO_BUS_READ (32'h_C000_0200); // w_port_wo_20_0
#200;
// read fifo data
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
MCS_IO_BUS_READ (32'h_C000_0A00);
#14
//
#200;
///////////////////////
	$finish;
//
end

/* 
// test_MISO
always @(negedge w_LAN_SCLK) begin : pattern_MISO__gen
	if (!reset_n) begin
		pattern_MISO <= 32'hAA55_CC33;
		end 
	else begin
		pattern_MISO <= {pattern_MISO[30:0],pattern_MISO[31]};
	end
end
//
assign w_LAN_MISO = pattern_MISO[31];
 */
 
// task IO bus read 
task MCS_IO_BUS_READ;
	input  [31:0] adrs;
	begin 
		@(posedge clk_72M);
		test_strb_adrs = 1'b1;
		test_adrs      = adrs; //
		test_strb_rd   = 1'b1;
		@(posedge clk_72M);
		test_strb_adrs = 1'b0;
		test_adrs      = 32'h0;
		test_strb_rd   = 1'b0;
		@(negedge clk_72M); // neg
		// read data 
		test_data      = IO_read_data; //
		@(negedge IO_ready); // neg
	end
endtask 

// task IO bus WRITE 
task MCS_IO_BUS_WRITE;
	input  [31:0] adrs;
	input  [31:0] data;
	begin 
		@(posedge clk_72M);
		test_strb_adrs = 1'b1;
		test_adrs      = adrs; //
		test_strb_wr   = 1'b1;
		test_data      = data; //
		@(posedge clk_72M);
		test_strb_adrs = 1'b0;
		test_adrs      = 32'h0;
		test_strb_wr   = 1'b0;
		test_data      = 32'h0; //
		@(negedge IO_ready); // neg
	end
endtask 

// task wi read 
task MCS_WI_READ;
	input  [31:0] offset;
	begin
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task wi write 
task MCS_WI_WRITE;
	input  [31:0] offset;
	input  [31:0] data;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_WI           = ADRS_BASE + 32'h_0000_0F10;
	MCS_IO_BUS_WRITE(32'h_C000_0F10, mask);
	#14;
	MCS_IO_BUS_WRITE(32'h_C000_0000+(offset<<4), data); 
	#14;
	end
endtask 

// task wo20 read 
task MCS_WO_READ;
	input  [31:0] offset;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_WO           = ADRS_BASE + 32'h_0000_0F14;
	MCS_IO_BUS_WRITE(32'h_C000_0F14, mask);
	#14;
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task wo20 write // NA

// task ti40 read 
task MCS_TI_READ;
	input  [31:0] offset;
	begin
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task ti40 write 
task MCS_TI_WRITE;
	input  [31:0] offset;
	input  [31:0] data;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_TI           = ADRS_BASE + 32'h_0000_0F18;
	MCS_IO_BUS_WRITE(32'h_C000_0F18, mask);
	#14;
	MCS_IO_BUS_WRITE(32'h_C000_0000+(offset<<4), data); 
	#14;
	end
endtask 

// task to60 read 
task MCS_TO_READ;
	input  [31:0] offset;
	input  [31:0] mask;
	begin
	//parameter ADRS_MASK_TO           = ADRS_BASE + 32'h_0000_0F1C;
	MCS_IO_BUS_WRITE(32'h_C000_0F1C, mask);
	#14;
	MCS_IO_BUS_READ(32'h_C000_0000+(offset<<4)); 
	#14;
	end
endtask 

// task to60 write // NA


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
