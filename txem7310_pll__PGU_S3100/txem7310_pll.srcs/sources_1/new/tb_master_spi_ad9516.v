`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_master_spi_ad9516
// 
//----------------------------------------------------------------------------
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//
// test  master_spi_ad9516.v
//
//////////////////////////////////////////////////////////////////////////////////


module tb_master_spi_ad9516;


//// clock and reset
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


//// test signals 
reg test_reset;
reg test_frame;
reg test_frame_rdwr; // 0 for write, 1 for read
//
reg [31:0] pattern_MISO;
//



/* DUT */
//
wire w_trig_LNG_reset = test_reset;
wire w_done_LNG_reset;
wire w_LNG_RSTn;
wire w_trig_SPI_frame = test_frame;
wire w_done_SPI_frame;
wire w_SCLK;
wire w_MISO;
//

// master_spi_ad9516
master_spi_ad9516 #(
	.TIME_RESET_WAIT_MS (0.1) // for fast sim
) master_spi_ad9516_inst (
	.clk				(clk_10M), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_LNG_reset),
	.o_done_LNG_reset	(w_done_LNG_reset), 
	.o_LNG_RSTn			(w_LNG_RSTn),
	.i_trig_SPI_frame	(w_trig_SPI_frame), 
	.o_done_SPI_frame	(w_done_SPI_frame), 
	//
	.o_CLK_CS_B   		(),
	.o_CLK_SCLK 		(w_SCLK),
	.o_CLK_SDIO 		(),
	.i_CLK_SDO 			(w_MISO),
	//
	.i_R_W_bar          (test_frame_rdwr), //       
	.i_byte_mode_W      (2'b00), // 1 byte mode 
	.i_reg_adrs_A       (10'h232),          // [9:0] 
	.i_wr_D             (8'hA5),           // [7:0] 
	.o_rd_D             (),                // [7:0] 
	//
	.valid				()		
);
//


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
// test init
begin : test_sig__init
	test_reset 		= 1'b0;
	test_frame 		= 1'b0;
	test_frame_rdwr	= 1'b0;
	//
	end
// wait for system reset
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;
// test reset
begin : test_reset__gen
	test_reset 		= 1'b1; 
	#200;
	test_reset 		= 1'b0; 
	end
//
$display(" Wait for rise of w_LNG_RSTn"); 
@(posedge w_LNG_RSTn)
#200;
//
$display(" Wait for rise of w_done_LNG_reset"); 
@(posedge w_done_LNG_reset)
#200;
// write frame setup : done by assignment
#0; 
// frame start
begin : frame_wr__trig
	test_frame_rdwr		= 1'b0; // 0 for write
	#200;
	test_frame 		= 1'b1; 
	#200;
	end 
#200
//
$display(" Wait for rise of w_done_SPI_frame"); 
@(posedge w_done_SPI_frame)
#200;
//
	test_frame 		= 1'b0; // delayed off
#1000; // long delay test for rise detection... if failed, two frames will be shown...
	//
///////////////////////
//	$finish;
#0; 
// frame start
begin : frame_rd__trig
	test_frame_rdwr		= 1'b1; // 1 for read
	#200;
	test_frame 		= 1'b1; 
	#200;
	test_frame 		= 1'b0; 
	end
#200;
//
$display(" Wait for rise of w_done_SPI_frame"); 
@(posedge w_done_SPI_frame)
#200;
///////////////////////
//	$finish;
#0; 
    // frame start
    begin : frame_rd__trig_2
        test_frame_rdwr        = 1'b1; // 1 for read
        #200;
        test_frame         = 1'b1; 
        #200;
        test_frame         = 1'b0; 
        end
    #200;
    //
    $display(" Wait for rise of w_done_SPI_frame"); 
    @(posedge w_done_SPI_frame)
    #200;
    ///////////////////////
        $finish;
//
end

// test_MISO
always @(negedge w_SCLK, negedge reset_n) begin : pattern_MISO__gen
	if (!reset_n) begin
		pattern_MISO <= 32'hAA55_CC33;
		end 
	else begin
		pattern_MISO <= {pattern_MISO[30:0],pattern_MISO[31]};
	end
end
//
assign w_MISO = pattern_MISO[31];




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
