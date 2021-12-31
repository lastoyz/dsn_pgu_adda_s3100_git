`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_master_spi_mth_brd__wrapper
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test :  master_spi_mth_brd__wrapper.v 
// test :  slave_spi_mth_brd.v  test_model__master_spi__from_mth_brd.v
//
//////////////////////////////////////////////////////////////////////////////////

module tb_master_spi_mth_brd__wrapper; //{


/* TODO: clock and reset */ //{
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

wire spi_base_clk = clk_104M;
wire mcs_clk      = clk_72M;

//}


/* TODO: DUT */ //{

//// master SPI emulation with FIFO interface //{

wire w_trig_init ;
wire w_done_init ;
wire w_trig_frame;
wire w_done_frame;

wire w_trig_reset_fifo ;
wire w_trig_frame_fifo ;
wire w_done_reset_fifo ;
wire w_done_frame_fifo ;

wire [ 5:0] w_frame_data_C ;
wire [ 9:0] w_frame_data_A ;
wire [15:0] w_frame_data_D ;
wire [15:0] w_frame_data_B ;
wire [15:0] w_frame_data_E ;

wire        w_mosi__wr_en;
wire [31:0] w_mosi__din  ;
wire        w_miso__rd_en;
wire [31:0] w_miso__dout ;

wire w_SS_B   ; // o
wire w_MCLK   ; // o
wire w_SCLK   ; // i // from w_MCLK
wire w_MOSI   ; // o
wire w_MISO   ; // i // from w_SPI_MISO
wire w_MISO_EN; // i // from w_SPI_MISO_EN

master_spi_mth_brd__wrapper  master_spi_mth_brd__wrapper__inst(
	.clk                (spi_base_clk), // 104MHz
	.reset_n            (reset_n     ),
	
	// control 
	.i_trig_init        (w_trig_init ), // 
	.o_done_init        (w_done_init ), // to be used for monitoring test mode 
	.i_trig_frame       (w_trig_frame), // edge-detection inside
	//.o_done_frame       (), // level output inside
	.o_done_frame_pulse (w_done_frame), // one-pulse output inside
	.i_trig_reset_fifo  (w_trig_reset_fifo), // reset fifo // 3 clock long
	.i_trig_frame_fifo  (w_trig_frame_fifo), // trigger spi frame with fifo data
	.o_done_reset_fifo  (w_done_reset_fifo), // one pulse
	.o_done_frame_fifo  (w_done_frame_fifo), // one pulse

	// frame data 
	.i_frame_data_C     (w_frame_data_C), // [ 5:0] // control  data on MOSI
	.i_frame_data_A     (w_frame_data_A), // [ 9:0] // address  data on MOSI
	.i_frame_data_D     (w_frame_data_D), // [15:0] // register data on MOSI
	.o_frame_data_B     (w_frame_data_B), // [15:0] // readback data on MISO, low  16 bits
	.o_frame_data_E     (w_frame_data_E), // [15:0] // readback data on MISO, high 16 bits
	
	// fifo interface
	.i_mosi__wr_clk     (mcs_clk       ), //       
	.i_mosi__wr_en      (w_mosi__wr_en ), //       
	.i_mosi__din        (w_mosi__din   ), // [31:0]
	.i_miso__rd_clk     (mcs_clk       ), //       
	.i_miso__rd_en      (w_miso__rd_en ), //       
	.o_miso__dout       (w_miso__dout  ), // [31:0]
	
	// IO 
	.o_SS_B             (w_SS_B   ),
	.o_MCLK             (w_MCLK   ),
	.i_SCLK             (w_SCLK   ),
	.o_MOSI             (w_MOSI   ),
	.i_MISO             (w_MISO   ),
	.i_MISO_EN          (w_MISO_EN) 
);

//}

//// slave SPI //{

wire w_SPI_CS_B   ; // i  // from w_SS_B
wire w_SPI_CLK    ; // i  // from w_MCLK
wire w_SPI_MOSI   ; // i  // from w_MOSI
wire w_SPI_MISO   ; // o
wire w_SPI_MISO_EN; // o

//
wire [31:0] w_port_wo_sadrs_h080 = 32'hD020_0529;
wire [31:0] w_port_wo_sadrs_h088 = 32'h0000_1010; 
wire [31:0] w_port_wo_sadrs_h380 = 32'h33AA_CC55; // 0x33AACC55
//
wire [31:0] w_port_ti_sadrs_h104;
wire [31:0] w_port_to_sadrs_h194; // = test_data_to;
wire [31:0] w_port_to_sadrs_h19C; // = test_data_to_210M;

//wire w_loopback_en = 1'b1; // loopback mode control on
wire w_loopback_en = 1'b0; // loopback mode control off
//wire w_MISO_one_bit_ahead_en = 1'b1; // MISO one bit ahead mode on 
wire w_MISO_one_bit_ahead_en = 1'b0; // MISO one bit ahead mode off 
//
slave_spi_mth_brd  slave_spi_mth_brd__inst (
	.clk     (spi_base_clk), // base clock clk_104M
	.reset_n (reset_n     ),

	//// slave SPI pins:
	.i_SPI_CS_B      (w_SPI_CS_B   ),
	.i_SPI_CLK       (w_SPI_CLK    ),
	.i_SPI_MOSI      (w_SPI_MOSI   ),
	.o_SPI_MISO      (w_SPI_MISO   ),
	.o_SPI_MISO_EN   (w_SPI_MISO_EN), // MISO buffer control

	//// test register interface
	.o_port_wi_sadrs_h000    (), // [31:0] // adrs h003~h000
	.o_port_wi_sadrs_h008    (),
	//
	.i_port_wo_sadrs_h080    (w_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h088    (w_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h380    (w_port_wo_sadrs_h380), // [31:0] // adrs h383~h380
	//
	.i_ck__sadrs_h104(clk_10M ),  .o_port_ti_sadrs_h104(w_port_ti_sadrs_h104),
	//
	.i_ck__sadrs_h194(clk_10M ),  .i_port_to_sadrs_h194(w_port_to_sadrs_h194), // [31:0]
	.i_ck__sadrs_h19C(clk_210M),  .i_port_to_sadrs_h19C(w_port_to_sadrs_h19C), // [31:0]

	//
	.o_wr__sadrs_h24C (),  .o_port_pi_sadrs_h24C (), // [31:0]  // MEM_PI	0x24C	pi93 //$$
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

//}

//}


/* TODO: test sequence */ //{

//// test signals //{
reg test_init;
//
reg test_frame;
reg test_frame_rdwr; // 0 for write, 1 for read
reg [ 9:0] test_adrs_10b;
reg [15:0] test_data_16b;
//
reg test_reset_fifo;
reg test_frame_fifo;

reg        test_fifo_mosi_wr      ;
reg [31:0] test_fifo_mosi_data_32b;
reg        test_fifo_miso_rd      ;


//
//reg [31:0] test_data_to;
//reg [31:0] test_data_to_210M;

//}

//// port assignment //{
assign w_frame_data_C = {1'b0,test_frame_rdwr,4'b0000}; // control  data on MOSI
assign w_frame_data_A = test_adrs_10b; // address  data on MOSI
assign w_frame_data_D = test_data_16b; // register data on MOSI
//
assign w_trig_init  = test_init;
assign w_trig_frame = test_frame;

assign w_trig_reset_fifo = test_reset_fifo;
assign w_trig_frame_fifo = test_frame_fifo;

assign w_mosi__wr_en = test_fifo_mosi_wr      ;
assign w_mosi__din   = test_fifo_mosi_data_32b;
assign w_miso__rd_en = test_fifo_miso_rd      ;
//w_miso__dout 


assign w_SCLK    = w_MCLK        ; 
assign w_MISO    = w_SPI_MISO    ; 
assign w_MISO_EN = w_SPI_MISO_EN ; 

assign w_SPI_CS_B = w_SS_B ;
assign w_SPI_CLK  = w_MCLK ;
assign w_SPI_MOSI = w_MOSI ;

//}

//// system reset 
initial begin : reset_n__gen
#0	reset_n 	    = 1'b0;
	test_init 	    = 1'b0;
	test_frame 	    = 1'b0;
	test_frame_rdwr	= 1'b0;
	test_adrs_10b   = 10'h000;
	test_data_16b   = 16'h0000;
	test_reset_fifo = 1'b0;
	test_frame_fifo = 1'b0;
	test_fifo_mosi_wr       = 1'b0;
	test_fifo_mosi_data_32b = 32'h0000_0000;
	test_fifo_miso_rd       = 1'b0;
#200;
	reset_n 	    = 1'b1; 
end


//// test sequence 
// 0. trigger init 
// 1. trigger a frame // test
//
// 2. trigger reset fifo
// 3. trigger frame fifo // test
//
// 4. trigger reset fifo
// 5. send MOSI data into fifo 
// 6. trigger frame fifo
// 7. check frame fifo done
// 8. read MISO data from fifo
// 9. repeat from 4 ~ 8

initial begin

$display(" Wait for reset_n"); 
@(posedge reset_n)
#200;

// 0. trigger init //{
MSPI_TRIG_INIT();
// wait for w_done_init
//$display(" Wait for w_done_init"); 
//@(posedge w_done_init)
#200;
//}
	
// 1. trigger a frame // test //{
MSPI_TRIG_FRAME(1'b1, 10'h382, 16'h0000); // (rdwr_bar, adrs_10b, data_16b) // 0x33AA
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
	$finish;
//}

// 1'. trigger a frame // test //{
MSPI_TRIG_FRAME(1'b1, 10'h380, 16'h0000); // (rdwr_bar, adrs_10b, data_16b) // 0xCC55
//
$display(" Wait for rise of w_done_frame"); 
@(posedge w_done_frame)
#200;
///////////////////////
	$finish;
//}

// 2. trigger reset fifo //{
MSPI_TRIG_RESET_FIFO();
#200;
///////////////////////
	$finish;
//}

// 3. trigger frame fifo // test //{
// trig frame fifo // with no fifo data
MSPI_TRIG_FRAME_FIFO();
//
$display(" Wait for rise of w_done_frame_fifo"); 
@(posedge w_done_frame_fifo)
#200;
///////////////////////
	$finish;
//}

// 4. trigger reset fifo //{
MSPI_TRIG_RESET_FIFO();
#200;
///////////////////////
	$finish;
//}

// 5. send MOSI data into fifo //{
MSPI_SEND_MOSI_INTO_FIFO( {6'h10, 10'h382, 16'h0000} ); // {C_6b, A_10b, D_16b}
MSPI_SEND_MOSI_INTO_FIFO( {6'h10, 10'h380, 16'h0000} ); // {C_6b, A_10b, D_16b}
MSPI_SEND_MOSI_INTO_FIFO( {6'h10, 10'h382, 16'h0000} ); // {C_6b, A_10b, D_16b}
MSPI_SEND_MOSI_INTO_FIFO( {6'h10, 10'h380, 16'h0000} ); // {C_6b, A_10b, D_16b}
#200;
///////////////////////
	$finish;

//}

// 6. trigger frame fifo //{
// trig frame fifo 
MSPI_TRIG_FRAME_FIFO();
#200;
///////////////////////
	$finish;

//}

// 7. check frame fifo done //{
$display(" Wait for rise of w_done_frame_fifo"); 
@(posedge w_done_frame_fifo)
#200;
///////////////////////
	$finish;

//}

// 8. read MISO data from fifo //{
MSPI_READ_MISO_FROM_FIFO();
MSPI_READ_MISO_FROM_FIFO();
MSPI_READ_MISO_FROM_FIFO();
MSPI_READ_MISO_FROM_FIFO();
#200;
///////////////////////
	$finish;

//}

// 9. repeat from 4 ~ 8 //{

//}


end



//// task //{

// task -- trigger init
task MSPI_TRIG_INIT;
	begin 
		@(posedge spi_base_clk);
		test_init = 1'b1;
		@(posedge spi_base_clk);
		test_init = 1'b0;
		@(posedge spi_base_clk);
	end 
endtask

// task -- trigger frame
task MSPI_TRIG_FRAME; // (rdwr_bar, adrs_10b, data_16b)
	input         rdwr_bar; // 0 for write
	input  [ 9:0] adrs_10b;
	input  [15:0] data_16b;
	begin
		@(posedge spi_base_clk);
		test_frame = 1'b0;
		test_frame_rdwr	= rdwr_bar;
		test_adrs_10b   = adrs_10b;
		test_data_16b   = data_16b;
		@(posedge spi_base_clk);
		test_frame = 1'b1;
		@(posedge spi_base_clk);
		test_frame = 1'b0;
		@(posedge spi_base_clk);
	end
endtask

// task -- trigger reset fifo
task MSPI_TRIG_RESET_FIFO;
	begin
		@(posedge spi_base_clk);
		test_reset_fifo = 1'b1;
		@(posedge spi_base_clk);
		test_reset_fifo = 1'b0;
		@(posedge spi_base_clk);
	end
endtask

// task -- send mosi data into fifo  
task MSPI_SEND_MOSI_INTO_FIFO; // (data_32b)
	input  [31:0] data_32b;
	begin
		@(posedge mcs_clk);
		test_fifo_mosi_wr       = 1'b0;
		test_fifo_mosi_data_32b = data_32b;
		@(posedge mcs_clk);
		test_fifo_mosi_wr       = 1'b1;
		@(posedge mcs_clk);
		test_fifo_mosi_wr       = 1'b0;
		@(posedge mcs_clk);
	end
endtask

// task -- read miso data from fifo 
task MSPI_READ_MISO_FROM_FIFO; // 
	begin
		@(posedge mcs_clk);
		test_fifo_miso_rd       = 1'b0;
		@(posedge mcs_clk);
		test_fifo_miso_rd       = 1'b1;
		@(posedge mcs_clk);
		test_fifo_miso_rd       = 1'b0;
		@(posedge mcs_clk);
	end
endtask

// task -- trigger frame fifo
task MSPI_TRIG_FRAME_FIFO;
	begin
		@(posedge spi_base_clk);
		test_frame_fifo = 1'b1;
		@(posedge spi_base_clk);
		test_frame_fifo = 1'b0;
		@(posedge spi_base_clk);
	end
endtask


//}

//}


//}
endmodule
