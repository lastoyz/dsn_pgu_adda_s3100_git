//------------------------------------------------------------------------
// master_spi_mcp23s17.v
// - objective 
//		send and recv SPI frame of 16 bit data
//		write and read 16 bit PORT // researved
//
// - doc 
//		mcp23s17
//			http://ww1.microchip.com/downloads/en/DeviceDoc/20001952C.pdf
//
// - IO pin 
//		o_SPIO0_CS
//		o_SPIO1_CS
//		o_SPIOx_SCLK
//		o_SPIOx_MOSI
//		i_SPIOx_MISO
//
// - IO port
//		i_trig_LNG_reset  // generate long reset signal
//		o_done_LNG_reset  // return done with long reset 
//		i_trig_SPI_frame  // generate SPI frame with 16 bit data.
//		o_done_SPI_frame  // sending SPI frame is done and data read is available.
//
//		i_CS_id           // 0 for SPIO0; 1 for SPIO1
//		i_pin_adrs_A[2:0] // hardware pin address or
//		i_R_W_bar         // 0 for write; 1 for read
//		i_reg_adrs_A[7:0] // register address
//		i_wr_DA[7:0]
//		i_wr_DB[7:0]
//		o_rd_DA[7:0]
//		o_rd_DB[7:0]
//
//
//		i_trig_PORT_write
//		o_done_PORT_write
//		i_trig_PORT_read
//		o_done_PORT_read
//
//		i_dr_CS0_GPA[7:0]  // 1 for input; 0 for output.
//		i_dr_CS0_GPB[7:0]  // 1 for input; 0 for output.
//		i_wr_CS0_GPA[7:0]
//		i_wr_CS0_GPB[7:0]
//		o_rd_CS0_GPA[7:0]
//		o_rd_CS0_GPB[7:0]
//		i_dr_CS1_GPA[7:0]  // 1 for input; 0 for output.
//		i_dr_CS1_GPB[7:0]  // 1 for input; 0 for output.
//		i_wr_CS1_GPA[7:0]
//		i_wr_CS1_GPB[7:0]
//		o_rd_CS1_GPA[7:0]
//		o_rd_CS1_GPB[7:0]
//
// 
// - SPI timing 
//		parameters
//			base SPI logic clock : 10MHz ~ 100ns 
//			base SPI clock       :  5MHz ~ 200ns ... _-
//			clock rate                   : 10MHz max ... (100ns)*2EA
//			cs setup time to clk rise    : 50ns min  ... (100ns)*1EA
//			data setup time to clk rise  : 20ns min  ... (100ns)*1EA
//			data hold time from clk rise : 20ns min  ... (100ns)*1EA
//			cs disable time              : 100ns min ... (100ns)*3EA
//			output valid from clk fall   : 90ns max  ... (100ns)*1EA
//			output disable time          : 100ns max ... (100ns)*1EA
//
//		<write> 
//		  o_SPIOx_CS_B -________________________________________________________________---________________________________________________________________---
//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
//		  o_SPIOx_MOSI _CCccCCccCCccCCccAAaaAAaaAAaaAAaaDDddDDddDDddDDddDDddDDddDDddDDdd___CCccCCccCCccCCccAAaaAAaaAAaaAAaaDDddDDddDDddDDddDDddDDddDDddDDdd___
//
//		<read> 
//		  o_SPIOx_CS_B -________________________________________________________________---________________________________________________________________---
//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-____-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-___
//		  o_SPIOx_MOSI _CCccCCccCCccCCccAAaaAAaaAAaaAAaa___________________________________CCccCCccCCccCCccAAaaAAaaAAaaAAaa___________________________________
//		  o_SPIOx_MISO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DDddDDddDDddDDddDDddDDddDDddDDdd~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DDddDDddDDddDDddDDddDDddDDddDDdd~~
//
//
// - SPI frame format: 16 bit long data
//		<write> 
//		  o_SPIOx_CS_B -________________________________________________________________---
//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0___
//                     
//		<read>           
//		  o_SPIOx_CS_B -________________________________________________________________---
//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-___
//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0___________________________________
//		  o_SPIOx_MISO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0~~
//
//		control bits      : C[7:0]
//			C7 0
//			C6 1
//			C5 0
//			C4 0
//			C3 HW_A2
//			C2 HW_A1
//			C1 HW_A0
//			C0 R_W_bar
//		address bits      : A[7:0]
//		data bits for GPA : D[7:0]
//		data bits for GPB : E[7:0]
//
//
// - state assignment on SPI frame
//		<write>
//        state_frame  0000012121212121212121212121212121212121212121212121212121212121212123470000012121212
//   i_trig_SPI_frame  ____--______________________________________________________________________--_______
//   o_done_SPI_frame  -----___________________________________________________________________-----________
//		  o_SPIOx_CS_B -----________________________________________________________________--------________
//		  o_SPIOx_SCLK ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_______-_-_-_-
//		  o_SPIOx_MOSI _____C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0________C7C6C5C4
//		  r_CS_id      ~~~~~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX~~~~~~~~~~~~~
//		  r_R_W_bar    ~~~~~0000000000000000000000000000000000000000000000000000000000000000000~~~~~~~~~~~~~
//	 r_fbit_index_H    0000000000000011111111112222222222333333333344444444445555555555666666660000000000000
//	 r_fbit_index_L    0000012345678901234567890123456789012345678901234567890123456789012345670000012345678
//
//		<read>           
//        state_frame  0000012121212121212121212121212121212121212121212121212121212121212125670000012121212
//   i_trig_SPI_frame  ____--______________________________________________________________________--_______
//   o_done_SPI_frame  -----___________________________________________________________________-----________
//		  o_SPIOx_CS_B -----________________________________________________________________--------________
//		  o_SPIOx_SCLK ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_________-_-_-_-
//		  o_SPIOx_MOSI _____C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0________________________________________C7C6C5C4
//		  o_SPIOx_MISO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0~~~~~~~~~~~~~~~
//		  r_CS_id      ~~~~~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX~~~~~~~~~~~~~
//		  r_R_W_bar    ~~~~~1111111111111111111111111111111111111111111111111111111111111111111~~~~~~~~~~~~~
//	 r_fbit_index_H    0000000000000011111111112222222222333333333344444444445555555555666666660000000000000
//	 r_fbit_index_L    0000012345678901234567890123456789012345678901234567890123456789012345670000012345678
//
// - state transitions and job
//		* s0 --> s1, if i_trig_SPI_frame == 1
//		* s1 --> s2, always
//		* s2 --> s1, if r_fbit_index < 64 
//		* s2 --> s3, if r_fbit_index >== 64 and r_R_W_bar == 0  
//		* s2 --> s5, if r_fbit_index >== 64 and r_R_W_bar == 1  
//		* s3 --> s4 --> s7, always
//		* s5 --> s6 --> s7, always
//		* s7 --> s0, always
//
// - state and job 
//		* s0 : done high, sclk low , cs_b high // job: ready to trig frame
//		* s1 : done low , sclk low , cs_b low
//		* s2 : done low , sclk high, cs_b low  // job: shift r_shift_send and r_shift_recv
//		* s3 : done low , sclk low , cs_b high 
//		* s4 : done low , sclk high, cs_b high
//		* s5 : done low , sclk low , cs_b high // job: load data from r_shift_recv
//		* s6 : done low , sclk low , cs_b high
//		* s7 : done low , sclk low , cs_b high // job: last state, go to s0.
//
//  - long reset timing : aux reset signal 
//  	reset active time min       500us --> 500 us * (144 MHz) = 72000    < 2^17
//  	reset active time min       500us --> 500 us * (12 MHz)  = 6000     < 2^13
//  	reset active time min       500us --> 500 us * (10 MHz)  = 5000     < 2^13  ... log(5000)/log(2)= 12.3
//  	plock time max after reset  50ms  --> 50  ms * (144 MHz) = 7200000  < 2^23
//  	plock time max after reset  50ms  --> 50  ms * (12 MHz)  = 600000   < 2^20
//  	plock time max after reset  50ms  --> 50  ms * (10 MHz)  = 500000   < 2^19  ... log(500000)/log(2)= 18.9
//
//  i_trig_LNG_reset   __---__________________________________________________
//  o_LNG_RSTn         -----___________---------------------------------------
//  o_done_LNG_reset   --____________________________________________---------
//                          <--500us--><-----------50ms------------->
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module master_spi_mcp23s17 (  
	// 
	input wire clk, // assume clk3_out2_144M //$$ 10MHz 
	input wire reset_n,
	//
	// control 
	input  wire i_trig_LNG_reset , // Long reset trigger 
	output wire o_done_LNG_reset , // Long reset done 
	output wire o_LNG_RSTn       , // long reset signal out
	input  wire i_trig_SPI_frame , // SPI frame trigger 
	output wire o_done_SPI_frame , // SPI frame done 
	//
	// IO
	output wire o_SPIO0_CS   ,
	output wire o_SPIO1_CS   ,
	output wire o_SPIOx_SCLK ,
	output wire o_SPIOx_MOSI ,
	input  wire i_SPIOx_MISO ,
	//
	// SPI frame contents
	input  wire       i_CS_id      , // 0 for SPIO0; 1 for SPIO1
	input  wire [2:0] i_pin_adrs_A , // hardware pin address or
	input  wire       i_R_W_bar    , // 0 for write; 1 for read
	input  wire [7:0] i_reg_adrs_A , // register address
	input  wire [7:0] i_wr_DA      ,
	input  wire [7:0] i_wr_DB      ,
	output wire [7:0] o_rd_DA      ,
	output wire [7:0] o_rd_DB      ,
	//
	// multi-frame controls and contents
	//input  wire i_trig_PORT_write ,
	//output wire o_done_PORT_write ,
	//input  wire i_trig_PORT_read  ,
	//output wire o_done_PORT_read  ,
	////
	//input  wire [7:0] i_dr_CS0_GPA, 
	//input  wire [7:0] i_dr_CS0_GPB, 
	//input  wire [7:0] i_wr_CS0_GPA,
	//input  wire [7:0] i_wr_CS0_GPB,
	//output wire [7:0] o_rd_CS0_GPA,
	//output wire [7:0] o_rd_CS0_GPB,
	////
	//input  wire [7:0] i_dr_CS1_GPA, 
	//input  wire [7:0] i_dr_CS1_GPB, 
	//input  wire [7:0] i_wr_CS1_GPA,
	//input  wire [7:0] i_wr_CS1_GPB,
	//output wire [7:0] o_rd_CS1_GPA,
	//output wire [7:0] o_rd_CS1_GPB,
	//
	// flag
	output wire valid
);

// valid 
reg r_valid;
assign valid = r_valid;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_valid <= 1'b0;
	end
	else begin
		r_valid <= 1'b1;
	end


// long reset control 
reg r_LNG_RSTn;
reg r_done_LNG_reset;
//
parameter BT_WDTH_RH = 13;
parameter BT_WDTH_RW = 19;
(* keep = "true" *) reg [(BT_WDTH_RH-1):0] r_cnt_reset_hold;
(* keep = "true" *) reg [(BT_WDTH_RW-1):0] r_cnt_reset_wait; // wait after reset hold done
//
//parameter PERIOD_CLK_RESET_PS = 83333.3333; // 12MHz
parameter PERIOD_CLK_RESET_PS = 100000; // 10MHz
parameter TIME_RESET_HOLD_US = 500;
parameter TIME_RESET_WAIT_MS = 50;
//
parameter INIT_CNT_RESET_HOLD = TIME_RESET_HOLD_US*1e6/PERIOD_CLK_RESET_PS; // 500*1e6/100000 = 5000 ... log(5000)/log(2) = 12.3
parameter INIT_CNT_RESET_WAIT = TIME_RESET_WAIT_MS*1e9/PERIOD_CLK_RESET_PS; // 50*1e9/100000 = 500000   ... log(500000)/log(2) = 18.9315685693
//
assign o_LNG_RSTn = r_LNG_RSTn;
assign o_done_LNG_reset = r_done_LNG_reset;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_LNG_RSTn       <= 1'b1;
		r_done_LNG_reset <= 1'b1;
		r_cnt_reset_hold <= {(BT_WDTH_RH){1'b0}};
		r_cnt_reset_wait <= {(BT_WDTH_RW){1'b0}};
	end
	else begin 
		//
		if (i_trig_LNG_reset) begin
			r_LNG_RSTn       <= 1'b0; // need to stay more.
			end
		else if (r_cnt_reset_hold == 1) begin 
			r_LNG_RSTn       <= 1'b1; 
			end
		//
		if (i_trig_LNG_reset) begin
			r_done_LNG_reset <= 1'b0; 
			end
		else if (r_cnt_reset_wait == 1) begin 
			r_done_LNG_reset <= 1'b1; 
			end
		//
		if (i_trig_LNG_reset) begin
			r_cnt_reset_hold <= INIT_CNT_RESET_HOLD;
			end
		else if (r_cnt_reset_hold>0) begin
			r_cnt_reset_hold <= r_cnt_reset_hold - 1;
			end
		//
		if (r_cnt_reset_hold == 1) begin
			r_cnt_reset_wait <= INIT_CNT_RESET_WAIT;
			end
		else if (r_cnt_reset_wait>0) begin
			r_cnt_reset_wait <= r_cnt_reset_wait - 1;
			end
		//
	end
//
	
	


// frame control
(* keep = "true" *) reg r_done_SPI_frame;
assign o_done_SPI_frame = r_done_SPI_frame;
//
reg r_SPIOx_SCLK;
assign o_SPIOx_SCLK   = r_SPIOx_SCLK;
//
reg r_SPIOx_CS  ;
reg r_CS_id     ;
assign o_SPIO0_CS     = (r_CS_id == 1'b0) ? r_SPIOx_CS : 1'b0;
assign o_SPIO1_CS     = (r_CS_id == 1'b1) ? r_SPIOx_CS : 1'b0;
//
reg [7:0] r_rd_DA;
reg [7:0] r_rd_DB;
//
assign o_rd_DA              = r_rd_DA;
assign o_rd_DB              = r_rd_DB;
//
reg [31:0] r_shift_send_w32; 
reg [15:0] r_shift_recv_w16; 
reg  [7:0] r_fbit_index    ; // check around 64 bit count
reg        r_R_W_bar       ;
//
assign o_SPIOx_MOSI   = r_shift_send_w32[31];


// trig SPI frame  
reg r_smp_trig_SPI_frame;
reg r_trig_SPI_frame;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_trig_SPI_frame   <= 1'b0;
		r_trig_SPI_frame       <= 1'b0;
	end
	else begin 
		//
		r_smp_trig_SPI_frame   <= i_trig_SPI_frame; // sampling
		//
		if ((~r_smp_trig_SPI_frame)&i_trig_SPI_frame) // detect rise
			r_trig_SPI_frame   <= 1'b1;
		else if (r_done_SPI_frame == 1'b0) // detect frame start
			r_trig_SPI_frame   <= 1'b0;
		//
	end


// state register
(* keep = "true" *) reg [7:0] state; 

// state def 
parameter STATE_SIG_0 = 8'h00; 
parameter STATE_SIG_1 = 8'h01; 
parameter STATE_SIG_2 = 8'h02; 
parameter STATE_SIG_3 = 8'h03; 
parameter STATE_SIG_4 = 8'h04; 
parameter STATE_SIG_5 = 8'h05; 
parameter STATE_SIG_6 = 8'h06; 
parameter STATE_SIG_7 = 8'h07; 
//


// process state 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		state				<= STATE_SIG_0;
		r_done_SPI_frame	<=  1'b1;
		r_CS_id             <=  1'b0;
		r_SPIOx_CS          <=  1'b0;
		r_SPIOx_SCLK        <=  1'b0;
		r_rd_DA             <=  8'b0; // [7:0] 
		r_rd_DB             <=  8'b0; // [7:0] 
		r_fbit_index        <=  8'b0; // [7:0]
		r_shift_recv_w16    <= 16'b0; // [15:0]
		r_shift_send_w32    <= 32'b0; // [31:0]
		r_R_W_bar           <=  1'b0;
		end 
	else if (i_trig_LNG_reset) begin 
		state				<= STATE_SIG_0;
		r_done_SPI_frame	<= 1'b1;
		r_CS_id             <=  1'b0;
		r_SPIOx_CS          <=  1'b0;
		r_SPIOx_SCLK        <=  1'b0;
		r_rd_DA             <=  8'b0; // [7:0] 
		r_rd_DB             <=  8'b0; // [7:0] 
		r_fbit_index        <=  8'b0; // [7:0]
		r_shift_recv_w16    <= 16'b0; // [15:0]
		r_shift_send_w32    <= 32'b0; // [31:0]
		r_R_W_bar           <=  1'b0;
		end 
	else case (state)
		// 
		STATE_SIG_0 : begin
			if (r_trig_SPI_frame) begin
				state				<= STATE_SIG_1;
				r_done_SPI_frame	<= 1'b0;
				//
				r_CS_id             <=  i_CS_id;
				r_SPIOx_CS          <=  1'b1;
				//
				r_SPIOx_SCLK        <=  1'b0;
				r_rd_DA             <=  8'b0; // [7:0] 
				r_rd_DB             <=  8'b0; // [7:0] 
				r_fbit_index        <=  8'b1; // [7:0]
				r_shift_recv_w16    <= 16'b0; // [15:0]
				//
				// load frame control 
				r_shift_send_w32    <= {
									{4'b0100, i_pin_adrs_A, i_R_W_bar},
									i_reg_adrs_A,
									i_wr_DA,
									i_wr_DB};
				r_R_W_bar           <=  i_R_W_bar;
				//
				end
			end
		// 
		STATE_SIG_1 : begin
			state				<= STATE_SIG_2;
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b1;
			//
			end
		// 
		STATE_SIG_2 : begin
			// common
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b0;
			// shift data 
			r_shift_send_w32 <= {r_shift_send_w32[30:0], 1'b0};
			r_shift_recv_w16 <= {r_shift_recv_w16[14:0], i_SPIOx_MISO};
			// still in frame 
			if (r_fbit_index < 8'd64) begin 
				state				<= STATE_SIG_1;
				end 
			// end of write frame 
			else if (r_R_W_bar == 0) begin 
				state				<= STATE_SIG_3;
				r_SPIOx_CS          <=  1'b0;
				//
				end
			// end of read frame 
			else begin 
				state				<= STATE_SIG_5;
				r_SPIOx_CS          <=  1'b0;
				//
				end
			end
		// 
		STATE_SIG_3 : begin
			state				<= STATE_SIG_4;
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b1;
			//
			end
		// 
		STATE_SIG_4 : begin
			state				<= STATE_SIG_7;
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b0;
			//
			end
		// 
		STATE_SIG_5 : begin
			state				<= STATE_SIG_6;
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b0;
			//
			r_rd_DA             <= r_shift_recv_w16[15:8];
			r_rd_DB             <= r_shift_recv_w16[ 7:0];
			//
			end
		// 
		STATE_SIG_6 : begin
			state		        <= STATE_SIG_7;
			r_fbit_index        <= r_fbit_index + 1;
			r_SPIOx_SCLK        <=  1'b0;
			end
		//
		STATE_SIG_7 : begin
			state				<= STATE_SIG_0;
			r_fbit_index        <= 8'b0;
			//
			r_done_SPI_frame	<= 1'b1;
			end
		default:
			state				<= STATE_SIG_0;
		// 
	endcase
	
endmodule
