`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_xem7310_top
//  simulation testbench to call top file
//  just to see code correctness...
//
// http://www.asic-world.com/verilog/art_testbench_writing1.html
// http://www.asic-world.com/verilog/art_testbench_writing2.html
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2016_1/ug937-vivado-design-suite-simulation-tutorial.pdf
//
//////////////////////////////////////////////////////////////////////////////////


module tb_xem7310_top;
reg clk; // assume 10MHz or 100ns
reg reset_n;
reg en;
//
reg clk_osc; //$$ 5ns for external osc 200MHz
//
reg clk_bus; //$$ 9.92ns for USB3.0	
//
reg init;
reg update;
reg test;
reg [31:0] test_sdi_pdata;
wire [31:0] test_sdo_pdata;
//
reg [31:0] r_sdo;
wire sdo = r_sdo[31];
wire sclk;

// test loopback
wire w_loopback_p;
wire w_loopback_n;

// DUT
xem7310__cmu_cpu__top  xem7310_inst ( // test for CMU-CPU-TEST-F5500
//xem7310__serdes_reg_quad_test__top xem7310_inst ( // test for CMU-1MHZ-SUB
//xem7310__cmu_1MHz_sub__top xem7310_inst ( // test for CMU-1MHZ-SUB
	//
	.sys_clkp         (clk_osc),
	.sys_clkn         (~clk_osc),
	//
	//
	.o_B34D_L21P      (w_loopback_p),       //$$ ADC_XX_CNV_P
	.o_B34D_L21N      (w_loopback_n),       //$$ ADC_XX_CNV_N
	//
	.i_B35D_L12P_MRCC (w_loopback_p),   //$$ OSC_IN_P // DAC_DCO_P
	.i_B35D_L12N_MRCC (w_loopback_n),   //$$ OSC_IN_N // DAC_DCO_N
	//
	.led()
);

// force signals
initial begin
#0_000 	force tb_xem7310_top.xem7310_inst.sys_clkp = 1'b0;	
#1_000 	release tb_xem7310_top.xem7310_inst.sys_clkp; // 1us
end

// test for loopback
initial begin
//
@(posedge tb_xem7310_top.xem7310_inst.clk_locked); // test_clk
#100;
	// enable and set parameters
	force tb_xem7310_top.xem7310_inst.w_enable__pulse_loopback = 1'b1;
	force tb_xem7310_top.xem7310_inst.w_set__pulse_period = 8'd10;
	force tb_xem7310_top.xem7310_inst.w_set__pulse_width  = 8'd5;
	force tb_xem7310_top.xem7310_inst.w_set__pulse_num    = 8'd23;
#100;
	// trig pulse on
@(posedge tb_xem7310_top.xem7310_inst.test_clk); 
	force tb_xem7310_top.xem7310_inst.w_trig__pulse_shot = 1'b1;
@(posedge tb_xem7310_top.xem7310_inst.test_clk); 
	force tb_xem7310_top.xem7310_inst.w_trig__pulse_shot = 1'b0;
#100
	// wait for pulse done 
@(posedge tb_xem7310_top.xem7310_inst.r_cnt__pulse_num == 8'b0)
#100
	// reset counter  
@(posedge tb_xem7310_top.xem7310_inst.test_clk); 
	force tb_xem7310_top.xem7310_inst.w_reset__pulse_loopback_cnt = 1'b1;
@(posedge tb_xem7310_top.xem7310_inst.test_clk); 
	force tb_xem7310_top.xem7310_inst.w_reset__pulse_loopback_cnt = 1'b0;
#100
	// release
#1_000;
	release tb_xem7310_top.xem7310_inst.w_enable__pulse_loopback;
	release tb_xem7310_top.xem7310_inst.w_set__pulse_period;
	release tb_xem7310_top.xem7310_inst.w_set__pulse_width;
	release tb_xem7310_top.xem7310_inst.w_set__pulse_num;
	release tb_xem7310_top.xem7310_inst.w_trig__pulse_shot;
	release tb_xem7310_top.xem7310_inst.w_reset__pulse_loopback_cnt;
//
$finish; 
//
end


// test signals
initial begin
#0		clk = 1'b0;
		reset_n = 1'b0;
		en = 1'b0;
		clk_bus = 1'b0;
		clk_osc = 1'b0;
		init = 1'b0;
		update = 1'b0;
		test = 1'b0;
		test_sdi_pdata = 32'b1010_0101_1001_0110_1100_1010_0011_0101;
#200	reset_n = 1'b1;
#200	en = 1'b1;
#200	test = 1'b1;
#15_000	init = 1'b1;
		test = 1'b0;
#30_000	update = 1'b1;
		test = 1'b1;
end

// clocks
always
#50 	clk = ~clk; // toggle every 50ns --> clock 100ns 
always
#4.96 	clk_bus = ~clk_bus; // toggle every 4.96ns --> clock 9.92ns for USB3.0	 
always
#2.5 	clk_osc = ~clk_osc; // toggle every 2.5ns --> clock 5ns for osc

// SPI bus
always @(posedge sclk, negedge reset_n)
    if (!reset_n) begin
        r_sdo <= 32'b1010_0101_1001_0110_1100_1010_0011_0101;
        end 
    else begin
        r_sdo <= {r_sdo[30:0], r_sdo[31]}; 
        end

//initial begin
	//$dumpfile ("waveform.vcd"); 
	//$dumpvars; 
//end 
  
//initial  begin
	//$display("\t\t time,\t clk,\t reset_n,\t en"); 
	//$monitor("%d,\t%b,\t%b,\t%b,\t%d",$time,clk,reset_n,en); 
//end 
  
//initial 
//#200_000 $finish; // 200us = 200_000 ns
//#1000 $finish; // 1us = 1000 ns
//#1000_000 $finish; // 1ms = 1000_000 ns

endmodule
