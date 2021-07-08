//------------------------------------------------------------------------
// master_spi_ad9516.v
// - objective 
//		send and recv SPI frame of 8 bit data
//
// - doc 
//		ad9516-1
//			https://www.analog.com/media/en/technical-documentation/data-sheets/AD9516-1.pdf
//
// - IO pin 
//		o_CLK_CS_B
//		o_CLK_SCLK
//		o_CLK_SDIO
//		i_CLK_SDO 
//
// - IO port
//		i_trig_LNG_reset  // generate long reset signal
//		o_done_LNG_reset  // return done with long reset 
//		i_trig_SPI_frame  // generate SPI frame with 16 bit data.
//		o_done_SPI_frame  // sending SPI frame is done and data read is available.
//
//		i_R_W_bar         // 0 for write; 1 for read
//		i_reg_adrs_A[9:0] // register address
//		i_wr_D[7:0]
//		o_rd_D[7:0]
//
// - reg or wire
//		r_R_W_bar
//		w_byte_mode_W[1:0]  = 2'b00; // 00 for 1 byte transfer
//		w_reg_adrs_A[12:10] = 3'b000; // fixed to 0
//
// - SPI timing 
//		parameters
//			base SPI logic clock : 10MHz ~ 100ns 
//			base SPI clock       :  5MHz ~ 200ns ... _-
//			clock rate                   : 25MHz max ... (100ns)*2EA
//			cs setup time to clk rise    :  2ns min  ... (100ns)*1EA
//			data setup time to clk rise  :  2ns min  ... (100ns)*1EA
//			data hold time from clk rise : 1.1ns min ... (100ns)*1EA
//			cs disable time              : NA        ... (100ns)*1EA
//			output valid from clk fall   :  8ns max  ... (100ns)*1EA 
//			output disable time          : NA        ... (100ns)*1EA 
//
//		<write> 16 bit header + 8 bit data
//		    o_CLK_CS_B -________________________________________________--________________________________________________--
//		    o_CLK_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_
//		    o_CLK_SDIO _HHhhHHhhHHhhHHhhHHhhHHhhHHhhHHhhDDddDDddDDddDDdd__HHhhHHhhHHhhHHhhHHhhHHhhHHhhHHhhDDddDDddDDddDDdd__
//
//		<read> 16 bit header + 8 bit data
//		    o_CLK_CS_B -________________________________________________--________________________________________________--
//		    o_CLK_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--__-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_
//		    o_CLK_SDIO _HHhhHHhhHHhhHHhhHHhhHHhhHHhhHHhh__________________HHhhHHhhHHhhHHhhHHhhHHhhHHhhHHhh__________________
//		     i_CLK_SDO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DDddDDddDDddDDdd~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DDddDDddDDddDDdd~~
//
//
// - SPI frame format: 16 bit header + 8 bit data
//		<write> 
//		    o_CLK_CS_B -________________________________________________--
//		    o_CLK_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_
//		                 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
//		    o_CLK_SDIO _H5H4H3H2H1H0H9H8H7H6H5H4H3H2H1H0D7D6D5D4D3D2D1D0__
//
//		<read>           
//		    o_CLK_CS_B -________________________________________________--
//		    o_CLK_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_
//		                 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
//		    o_CLK_SDIO _H5H4H3H2H1H0H9H8H7H6H5H4H3H2H1H0__________________
//		     i_CLK_SDO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0~~
//
//		header bits      : H[15:0]
//			H15 R_W_bar
//			H14 byte_mode_W1 = 0
//			H13 byte_mode_W0 = 0
//			H12 A12 = 0
//			H11 A11 = 0
//			H00 A10 = 0
//			H09 A9
//			H08 A8
//			H07 A7
//			H06 A6
//			H05 A5
//			H04 A4
//			H03 A3
//			H02 A2
//			H01 A1
//			H00 A0
//		address bits      : A[9:0]
//		data bits         : D[7:0]
//
//
// - state assignment on SPI frame
//		<write>
//        state_frame  00000121212121212121212121212121212121212121212121212350000012121212
//   i_trig_SPI_frame  ____--_____________________________________________________--_______
//   o_done_SPI_frame  -----__________________________________________________-----________
//		    o_CLK_CS_B -----________________________________________________-------________
//		    o_CLK_SCLK ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_______-_-_-_-
//		                     1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0                        1 1 1 1
//		    o_CLK_SDIO _____H5H4H3H2H1H0H9H8H7H6H5H4H3H2H1H0D7D6D5D4D3D2D1D0_______H5H4H3H2
//		  r_R_W_bar    xxxxx________________________________________________xxxxxxxxxxxxxxx
//	 r_fbit_index_H    00000000000000111111111122222222223333333333444444444450000000000000
//	 r_fbit_index_L    00000123456789012345678901234567890123456789012345678900000012345678
//                                                                           
//		<read>                                                               
//        state_frame  00000121212121212121212121212121212121212121212121212450000012121212
//   i_trig_SPI_frame  ____--_____________________________________________________--_______
//   o_done_SPI_frame  -----__________________________________________________-----________
//		    o_CLK_CS_B -----________________________________________________-------________
//		    o_CLK_SCLK ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_--_______-_-_-_-
//		                     1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0                        1 1 1 1
//		    o_CLK_SDIO _____H5H4H3H2H1H0H9H8H7H6H5H4H3H2H1H0_______________________H5H4H3H2
//		     i_CLK_SDO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0~~~~~~~~~~~~~~~
//		  r_R_W_bar    xxxxx------------------------------------------------xxxxxxxxxxxxxxx
//	 r_fbit_index_H    00000000000000111111111122222222223333333333444444444450000000000000
//	 r_fbit_index_L    00000123456789012345678901234567890123456789012345678900000012345678
//
// - state transitions and job
//		* s0 --> s1, if i_trig_SPI_frame == 1
//		* s1 --> s2, always
//		* s2 --> s1, if r_fbit_index < 48 
//		* s2 --> s3, if r_fbit_index >= 48 and r_R_W_bar == 0  
//		* s2 --> s4, if r_fbit_index >= 48 and r_R_W_bar == 1  
//		* s3 --> s5, always
//		* s4 --> s5, always
//		* s5 --> s0, always
//
// - state and job 
//		* s0 : done high, sclk low , cs_b high // job: ready to trig frame
//		* s1 : done low , sclk low , cs_b low  // job: shift r_shift_recv
//		* s2 : done low , sclk high, cs_b low  // job: shift r_shift_send
//		* s3 : done low , sclk high, cs_b high 
//		* s4 : done low , sclk high, cs_b high // job: load data from r_shift_recv
//		* s5 : done low , sclk low , cs_b high // job: last state, go to s0.
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
module master_spi_ad9516 (  
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
	output wire o_CLK_CS_B ,
	output wire o_CLK_SCLK ,
	output wire o_CLK_SDIO ,
	input  wire i_CLK_SDO  ,
	//
	// SPI frame contents
	input  wire       i_R_W_bar    , // 0 for write; 1 for read
	input  wire [9:0] i_reg_adrs_A , // register address
	input  wire [7:0] i_wr_D       , // data to register
	output wire [7:0] o_rd_D       , // data from register
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
(* keep = "true" *) reg r_LNG_RSTn;
(* keep = "true" *) reg r_done_LNG_reset;
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
(* keep = "true" *) reg r_CLK_SCLK;
assign o_CLK_SCLK     = r_CLK_SCLK;
//
(* keep = "true" *) reg r_CLK_CS_B;
assign o_CLK_CS_B     = r_CLK_CS_B;
//
(* keep = "true" *) reg [7:0] r_rd_D;
assign o_rd_D               = r_rd_D;
//
(* keep = "true" *) reg [23:0] r_shift_send_w24; 
(* keep = "true" *) reg  [7:0] r_shift_recv_w8; 
(* keep = "true" *) reg  [7:0] r_fbit_index    ; // check around bit count 48
(* keep = "true" *) reg        r_R_W_bar       ;
//
assign o_CLK_SDIO   = r_shift_send_w24[23];


// trig SPI frame  
reg r_smp_trig_SPI_frame;
(* keep = "true" *) reg r_trig_SPI_frame;
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
//parameter STATE_SIG_6 = 8'h06; 
//parameter STATE_SIG_7 = 8'h07; 
//


// process state 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		state				<= STATE_SIG_0;
		r_done_SPI_frame	<=  1'b1;
		//
		r_CLK_CS_B          <=  1'b1;
		r_CLK_SCLK          <=  1'b0;
		r_rd_D              <=  8'b0; // [7:0] 
		r_fbit_index        <=  8'b0; // [7:0]
		r_shift_recv_w8     <=  8'b0; // [7:0]
		r_shift_send_w24    <= 24'b0; // [23:0]
		r_R_W_bar           <=  1'b0;
		end 
	else if (i_trig_LNG_reset) begin 
		state				<= STATE_SIG_0;
		r_done_SPI_frame	<= 1'b1;
		//
		r_CLK_CS_B          <=  1'b1;
		r_CLK_SCLK          <=  1'b0;
		r_rd_D              <=  8'b0; // [7:0] 
		r_fbit_index        <=  8'b0; // [7:0]
		r_shift_recv_w8     <=  8'b0; // [7:0]
		r_shift_send_w24    <= 24'b0; // [23:0]
		r_R_W_bar           <=  1'b0;
		end 
	else case (state)
		// 
		STATE_SIG_0 : begin
			if (r_trig_SPI_frame) begin
				state				<= STATE_SIG_1;
				r_done_SPI_frame	<= 1'b0;
				//
				r_CLK_CS_B          <=  1'b0;
				r_CLK_SCLK          <=  1'b0;
				r_rd_D              <=  8'b0; // [7:0]
				//
				r_fbit_index        <=  8'b1; // [7:0]
				r_shift_recv_w8     <=  8'b0; // [7:0]
				//
				// load frame control 
				r_shift_send_w24    <= {
									i_R_W_bar, 2'b00, 
									3'b000, 
									i_reg_adrs_A,
									i_wr_D};
				r_R_W_bar           <=  i_R_W_bar;
				//
				end
			end
		// 
		STATE_SIG_1 : begin
			state				<= STATE_SIG_2;
			r_fbit_index        <= r_fbit_index + 1;
			r_CLK_SCLK          <=  1'b1;
			// shift data 
			r_shift_recv_w8     <= {r_shift_recv_w8[6:0], i_CLK_SDO};
			//
			end
		// 
		STATE_SIG_2 : begin
			// common
			r_fbit_index        <= r_fbit_index + 1;
			// shift data 
			r_shift_send_w24 <= {r_shift_send_w24[22:0], 1'b0};
			//
			// still in frame 
			if (r_fbit_index < 8'd48) begin 
				state				<= STATE_SIG_1;
				r_CLK_SCLK          <=  1'b0;
				end 
			// end of write frame 
			else if (r_R_W_bar == 0) begin 
				state				<= STATE_SIG_3;
				r_CLK_CS_B          <=  1'b1;
				//
				end
			// end of read frame 
			else begin 
				state				<= STATE_SIG_4;
				r_CLK_CS_B          <=  1'b1;
				//
				end
			end
		// 
		STATE_SIG_3 : begin
			state				<= STATE_SIG_5;
			r_fbit_index        <= r_fbit_index + 1;
			r_CLK_SCLK          <=  1'b0;
			//
			end
		// 
		STATE_SIG_4 : begin
			state				<= STATE_SIG_5;
			r_fbit_index        <= r_fbit_index + 1;
			r_CLK_SCLK          <=  1'b0;
			//
			r_rd_D              <= r_shift_recv_w8[ 7:0];
			//
			end
		//
		STATE_SIG_5 : begin
			state				<= STATE_SIG_0;
			r_fbit_index        <= 8'b0;
			//
			r_done_SPI_frame	<= 1'b1;
			end
		// 
	endcase
	
endmodule
