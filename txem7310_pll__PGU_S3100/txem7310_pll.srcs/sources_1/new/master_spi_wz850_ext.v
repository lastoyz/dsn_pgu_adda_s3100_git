//------------------------------------------------------------------------
// master_spi_wz850_ext.v
//  for wiznet850io (W5500) lan module spi control 
//
//  - doc
//		wiz850io info 
//  		http://wizwiki.net/wiki/doku.php?id=products:wiz850io:start
//  			>>>https://cdn.sos.sk/productdata/43/24/8adad58a/wiz850io.pdf
//  		http://wizwiki.net/wiki/doku.php?id=products:w5500:start
//  	W5500 data sheet 
//  		>>>http://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5500:w5500_ds_v108k.pdf
//  			Mode 0 : SCLK idle level low
//  			2.1 SPI Operation Mode
//  			MR (Mode Register) [R/W] [0x0000] [0x00]
//  			VERSIONR (W5500 Chip Version Register) [R] [0x0039] [0x04]
//  	driver info
//  		http://wizwiki.net/wiki/doku.php?id=products:w5500:driver
//  			http://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5500:iolibrary_bsd_ethernet_v103.zip
//  			http://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5500:iolibrary_bsd_internet_v111.zip
//  			http://wizwiki.net/wiki/lib/exe/fetch.php?media=products:w5500:w5500_socket_apis_v103.zip
//
//  - IO
//
//  - reg 
//
//  - reset timing 
//  	reset active time min       500us --> 500 us * (144 MHz) = 72000    < 2^17
//  	reset active time min       500us --> 500 us * (12 MHz)  = 6000     < 2^13
//  	plock time max after reset  50ms  --> 50  ms * (144 MHz) = 7200000  < 2^23
//  	plock time max after reset  50ms  --> 50  ms * (12 MHz)  = 600000   < 2^20
//
//  i_trig_LAN_reset   __---__________________________________________________
//  o_LAN_RSTn         -----___________---------------------------------------
//  o_done_LAN_reset   --____________________________________________---------
//                          <--500us--><-----------50ms------------->
//
//  - serial packet format from SPI timing diagram
//
//  	base freq 144MHz ~ 6.944ns
//
//   sclk : rise sampling / fall toggling
//   scsn : scsn high time  30ns min  ... 5 / (144 megahertz) = 34.7222222 nanoseconds
//   scsn : scsn hold time  5ns min   
//
//              8-states!!
//                 state 1 2 ... SPI frame 
//
//  state_sig         00000121212121212121212121212121212123456700001212121212121212
//  i_trig_SPI_frame  ____--_______________________________________--_______________
//  o_done_SPI_frame  -----_____________________________________----________________
//  o_LAN_SCSn        -----_________________________________--------________________
//  o_LAN_SCLK        ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__________-_-_-_-_-_-_-_- 
//  o_LAN_MOSI        XXXXXDDddDDddDDddDDddDDddDDddDDddDDddXXXXXXXXXDDddDDddDDddDDdd
//  i_LAN_MISO        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXDDddXXXXXXXXXXXXXXXXXXXXXXXXX
//                                                              
//
//
//
//  - SPI frame // state_frame
//      address phase / control phase / data phase 
//      
//      AAAAAAAAAAAAAAAACCCCCCCCDDDDDDDD...DDDDDDDD
//      11111100000000000000000000000000...00000000
//      54321098765432107654321076543210...76543210
//
//      A[15:0]  address  16-bit
//      C[7:0]   control  8-bit = {BSB[4:0], RWB, OMB[1:0]}
//             BSB[4:0]  block select bits 
//                       BSB[4:0]=5'b00000  Common Register
//                       BSB[4:0]=5'b00001  Socket 0 Register
//                       BSB[4:0]=5'b00010  Socket 0 TX Buffer
//                       BSB[4:0]=5'b00011  Socket 0 RX Buffer
//                       BSB[4:0]=5'b00100  NA
//                       BSB[4:0]=5'b00101  Socket 1 Register
//                       BSB[4:0]=5'b00110  Socket 1 TX Buffer
//                       BSB[4:0]=5'b00111  Socket 1 RX Buffer
//                       BSB[4:0]=5'b01000  NA
//                       BSB[4:0]=5'b01001  Socket 2 Register
//                       BSB[4:0]=5'b01010  Socket 2 TX Buffer
//                       BSB[4:0]=5'b01011  Socket 2 RX Buffer
//                       BSB[4:0]=5'b01100  NA
//                       BSB[4:0]=5'b01101  Socket 3 Register
//                       BSB[4:0]=5'b01110  Socket 3 TX Buffer
//                       BSB[4:0]=5'b01111  Socket 3 RX Buffer
//                       BSB[4:0]=5'b10000  NA
//                       BSB[4:0]=5'b10001  Socket 4 Register
//                       BSB[4:0]=5'b10010  Socket 4 TX Buffer
//                       BSB[4:0]=5'b10011  Socket 4 RX Buffer
//                       BSB[4:0]=5'b10100  NA
//                       BSB[4:0]=5'b10101  Socket 5 Register
//                       BSB[4:0]=5'b10110  Socket 5 TX Buffer
//                       BSB[4:0]=5'b10111  Socket 5 RX Buffer
//                       BSB[4:0]=5'b11000  NA
//                       BSB[4:0]=5'b11001  Socket 6 Register
//                       BSB[4:0]=5'b11010  Socket 6 TX Buffer
//                       BSB[4:0]=5'b11011  Socket 6 RX Buffer
//                       BSB[4:0]=5'b11100  NA
//                       BSB[4:0]=5'b11101  Socket 7 Register
//                       BSB[4:0]=5'b11110  Socket 7 TX Buffer
//                       BSB[4:0]=5'b11111  Socket 7 RX Buffer
//             RWB       Read/Write Access Mode Bit ... 0 for read, 1 for write.
//             OMB[1:0]  Operation Mode Bits
//                       OMB[1:0]=2'00  Variable Data Length Mode
//                       OMB[1:0]=2'01  1 Byte Data
//                       OMB[1:0]=2'10  2 Byte Data
//                       OMB[1:0]=2'11  4 Byte Data
//      D[31:0] data 32-bit  = {D3[7:0], D2[7:0], D1[7:0], D0[7:0]}
//      frame format 
//        OMB[1:0]=2'01  1 Byte Data :  {A[15:0], C[7:0], D0[7:0]}
//        OMB[1:0]=2'10  2 Byte Data :  {A[15:0], C[7:0], D0[7:0], D1[7:0]}
//        OMB[1:0]=2'11  4 Byte Data :  {A[15:0], C[7:0], D0[7:0], D1[7:0], D2[7:0], D3[7:0]}
//        OMB[1:0]=2'00  ~ Byte Data :  {A[15:0], C[7:0], D0[7:0], D1[7:0], D2[7:0], D3[7:0], ...}
//
//      D[ 7:0] data  8-bit 
//      frame format 
//        OMB[1:0]=2'01  1 Byte Data :  {A[15:0], C[7:0], D[7:0]}
//        OMB[1:0]=2'10  2 Byte Data :  {A[15:0], C[7:0], D[7:0], D[7:0]}
//        OMB[1:0]=2'11  4 Byte Data :  {A[15:0], C[7:0], D[7:0], D[7:0], D[7:0], D[7:0]}
//        OMB[1:0]=2'00  ~ Byte Data :  {A[15:0], C[7:0], D[7:0], D[7:0], D[7:0], D[7:0], ...}
//
//      <timing - write>
//  state_sig         00000121212121212121212121212121212121212121212121212121212121212121212121212121212123456700001212121212121212
//  i_trig_SPI_frame  ____--_______________________________________________________________________________________--_______________
//  o_done_SPI_frame  -----_____________________________________________________________________________________----________________
//  o_LAN_SCSn        -----_________________________________________________________________________________--------________________
//  o_LAN_SCLK        ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__________-_-_-_-_-_-_-_- 
//  o_LAN_MOSI        XXXXXDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddXXXXXXXXXDDddDDddDDddDDdd
//                         A A A A A A A A A A A A A A A A C C C C C C C C D D D D D D D D D D D D D D D D          A A A A A A A A 
//                         1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0          1 1 1 1 1 1 0 0 
//                         5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0          5 4 3 2 1 0 9 8 
//  i_LAN_MISO        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//  r_load_para       ____-________________________________________________________________________________________-________________
//  r_frame_adct      _____------------------------------------------------_________________________________________----------------
//  r_frame_data      _____________________________________________________--------------------------------_________________________
//  i_frame_data_wr   XXXXDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDddddddddddddddddXXXXXXXXXXXXXXXXXXXXXXXXX
//  o_frame_done_wr   ___________________________________________________________________--______________--_________________________
//                                                              
//
//
//      <timing - read>
//  state_sig         00000121212121212121212121212121212121212121212121212121212121212121212121212121212123456700001212121212121212
//  i_trig_SPI_frame  ____--_______________________________________________________________________________________--_______________
//  o_done_SPI_frame  -----_____________________________________________________________________________________----________________
//  o_LAN_SCSn        -----_________________________________________________________________________________--------________________
//  o_LAN_SCLK        ______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__________-_-_-_-_-_-_-_- 
//  o_LAN_MOSI        XXXXXDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXDDddDDddDDddDDdd
//                         A A A A A A A A A A A A A A A A C C C C C C C C D D D D D D D D D D D D D D D D          A A A A A A A A 
//                         1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0          1 1 1 1 1 1 0 0 
//                         5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0 7 6 5 4 3 2 1 0          5 4 3 2 1 0 9 8 
//  i_LAN_MISO        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXDDddDDddDDddDDddDDddDDddDDddDDddXXXXXXXXXXXXXXXXXXXXXXXX
//  r_load_para       ____-________________________________________________________________________________________-________________
//  r_frame_adct      _____------------------------------------------------_________________________________________----------------
//  r_frame_data      _____________________________________________________--------------------------------_________________________
//  o_frame_data_rd   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXDDDDDDDDDDDDDDDDdddddddddXXXXXXXXXXXXXXXX
//  o_frame_done_rd   _____________________________________________________________________--______________--_______________________
//
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module master_spi_wz850_ext (  
	// 
	input wire clk, // assume 144MHz
	input wire reset_n,
	input wire clk_reset, // assume 10MHz or 12MHz
	//
	// control 
	input  wire i_trig_LAN_reset   , // LAN reset trigger @ clk_reset
	output wire o_done_LAN_reset   , // LAN reset done 
	input  wire i_trig_SPI_frame   , // SPI frame trigger @ clk
	output wire o_done_SPI_frame   , // SPI frame done 
	output wire o_done_SPI_frame_TO, // SPI frame done trig out @ clk
	//
	// IO
	output wire o_LAN_RSTn ,
	input  wire i_LAN_INTn , // reserved
	output wire o_LAN_SCSn ,
	output wire o_LAN_SCLK ,
	output wire o_LAN_MOSI ,
	input  wire i_LAN_MISO ,
	//
	// frame contents: address / control / data 
	input  wire [15:0] i_frame_adrs          ,
	input  wire [ 4:0] i_frame_ctrl_blck_sel ,
	input  wire        i_frame_ctrl_rdwr_sel ,
	input  wire [ 1:0] i_frame_ctrl_opmd_sel ,
	input  wire [15:0] i_frame_num_byte_data , //
	//input  wire [31:0] i_frame_data_wr       ,
	input  wire [ 7:0] i_frame_data_wr       ,
	output wire        o_frame_done_wr       , //
	//output wire [31:0] o_frame_data_rd       ,
	output wire [ 7:0] o_frame_data_rd       ,
	output wire        o_frame_done_rd       , //
	//
	// flag
	output wire valid
);

// valid 
(* keep = "true" *) reg r_valid;
assign valid = r_valid;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_valid <= 1'b0;
	end
	else begin
		r_valid <= 1'b1;
	end

// reset  
reg r_LAN_RSTn;
reg r_done_LAN_reset;
//
//  	reset active time min       500us --> 500 us * (144 MHz) = 72000    < 2^17
//  	reset active time min       500us --> 500 us * (12 MHz)  = 6000     < 2^13
//  	reset active time min       500us --> 1000 us * (12 MHz)  = 12000     < 2^14
//  	plock time max after reset  50ms  --> 50  ms * (144 MHz) = 7200000  < 2^23
//  	plock time max after reset  50ms  --> 50  ms * (12 MHz)  = 600000   < 2^20
parameter BT_WDTH_RH = 15;
parameter BT_WDTH_RW = 22;
(* keep = "true" *) reg [(BT_WDTH_RH-1):0] r_cnt_reset_hold;
reg [(BT_WDTH_RW-1):0] r_cnt_reset_wait; // wait after reset hold done
//
//parameter PERIOD_CLK_PS = 6944.44444; // 144MHz
parameter PERIOD_CLK_RESET_PS = 83333.3333; // 12MHz
//parameter TIME_RESET_HOLD_US = 500;
parameter TIME_RESET_HOLD_US = 1000;
parameter TIME_RESET_WAIT_MS = 50;
//
parameter INIT_CNT_RESET_HOLD = TIME_RESET_HOLD_US*1e6/PERIOD_CLK_RESET_PS;
parameter INIT_CNT_RESET_WAIT = TIME_RESET_WAIT_MS*1e9/PERIOD_CLK_RESET_PS;
//
assign o_LAN_RSTn = r_LAN_RSTn;
assign o_done_LAN_reset = r_done_LAN_reset;
//
always @(posedge clk_reset, negedge reset_n)
	if (!reset_n) begin
		r_LAN_RSTn       <= 1'b1;
		r_done_LAN_reset <= 1'b1;
		r_cnt_reset_hold <= {(BT_WDTH_RH){1'b0}};
		r_cnt_reset_wait <= {(BT_WDTH_RW){1'b0}};
	end
	else begin 
		//
		if (i_trig_LAN_reset) begin
			r_LAN_RSTn       <= 1'b0; // need to stay more.
			end
		else if (r_cnt_reset_hold == 1) begin 
			r_LAN_RSTn       <= 1'b1; 
			end
		//
		if (i_trig_LAN_reset) begin
			r_done_LAN_reset <= 1'b0; 
			end
		else if (r_cnt_reset_wait == 1) begin 
			r_done_LAN_reset <= 1'b1; 
			end
		//
		if (i_trig_LAN_reset) begin
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
reg r_done_SPI_frame;
reg r_LAN_SCSn;
reg r_LAN_SCLK;
//
assign o_done_SPI_frame = r_done_SPI_frame;
assign o_LAN_SCSn       = r_LAN_SCSn;
assign o_LAN_SCLK       = r_LAN_SCLK;
//
reg r_frame_adct; // indicator for address and control phases
reg r_frame_data; // indicator for data phase
//
reg [ 7:0] r_cnt_adct; // address and control phase bit count
reg [16:0] r_cnt_data; // data phase bit count // 2^14*8 bit max
//
parameter INIT_cnt_adct =  8'd24;
parameter INIT_cnt_data = 17'd08;
//
reg [23:0] r_sh_buf_adct;
reg [ 7:0] r_sh_buf_data;
reg [ 7:0] r_sh_buf_data_trig;
reg [ 7:0] r_sh_buf_data_read;
//
assign o_LAN_MOSI = (r_frame_adct)? r_sh_buf_adct[23]: 
					(r_frame_data)? r_sh_buf_data[ 7]:
					1'b0;
//
(* keep = "true" *) reg [ 4:0] r_blck_sel;
(* keep = "true" *) reg        r_rdwr_sel;
(* keep = "true" *) reg [ 1:0] r_opmd_sel;
//
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
		else if (r_LAN_SCSn == 1'b0) // detect frame start
			r_trig_SPI_frame   <= 1'b0;
		//
	end

// make w_frame_num_byte_data > 0
wire [15:0] w_frame_num_byte_data = (i_frame_num_byte_data == 16'b0)? 16'd1 : i_frame_num_byte_data;
	

// unused	
//wire w_LAN_INTn = i_LAN_INTn; 
	
// outputs
//wire w_LAN_SCSn = 1'b1; // test
//wire w_LAN_SCLK = 1'b0; // test
//wire w_LAN_MOSI = 1'b0; // test
//
//assign o_LAN_SCSn = w_LAN_SCSn ;
//assign o_LAN_SCLK = w_LAN_SCLK ;
//assign o_LAN_MOSI = w_LAN_MOSI ;
//
//assign o_frame_done_wr = r_sh_buf_data_trig[7]; //$$
reg r_frame_done_wr;
//
assign o_frame_done_wr = r_frame_done_wr;
//
reg [ 7:0] r_frame_data_rd;
//
assign o_frame_data_rd = r_frame_data_rd;
//
reg r_frame_done_rd;
//
assign o_frame_done_rd = r_frame_done_rd;
//

//// o_done_SPI_frame_TO :
//   detect rise edge of r_done_SPI_frame
reg [1:0] r_smp_done_SPI_frame;
assign o_done_SPI_frame_TO = (~r_smp_done_SPI_frame[1]) & (r_smp_done_SPI_frame[0]);
// 
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_done_SPI_frame   <= 2'b11; // consider r_done_SPI_frame is high normally.
	end
	else begin 
		//
		r_smp_done_SPI_frame   <= {r_smp_done_SPI_frame[0], r_done_SPI_frame}; // sampling
		//
	end


// state register
reg [7:0] state; 

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
		r_done_SPI_frame	<= 1'b1;
		r_LAN_SCSn			<= 1'b1;
		r_LAN_SCLK			<= 1'b0;
		r_frame_adct		<= 1'b0;
		r_frame_data		<= 1'b0;
		r_cnt_adct			<= INIT_cnt_adct;
		r_cnt_data			<= INIT_cnt_data;
		r_sh_buf_adct		<= 24'b0;
		r_sh_buf_data		<=  8'b0;
		r_sh_buf_data_trig	<=  8'b0;
		r_sh_buf_data_read	<=  8'b0;
		r_frame_data_rd		<=  8'b0;
		r_frame_done_rd		<=  1'b0;
		r_frame_done_wr		<=  1'b0;
		r_blck_sel			<=  5'b0;
		r_rdwr_sel			<=  1'b0;
		r_opmd_sel			<=  2'b0;
		end 
	else if (i_trig_LAN_reset) begin 
		state				<= STATE_SIG_0;
		r_done_SPI_frame	<= 1'b1;
		r_LAN_SCSn			<= 1'b1;
		r_LAN_SCLK			<= 1'b0;
		r_frame_adct		<= 1'b0;
		r_frame_data		<= 1'b0;
		r_cnt_adct			<= INIT_cnt_adct;
		r_cnt_data			<= INIT_cnt_data;
		r_sh_buf_adct		<= 24'b0;
		r_sh_buf_data		<=  8'b0;
		r_sh_buf_data_trig	<=  8'b0;
		r_sh_buf_data_read	<=  8'b0;
		r_frame_data_rd		<=  8'b0;
		r_frame_done_rd		<=  1'b0;
		r_frame_done_wr		<=  1'b0;
		r_blck_sel			<=  5'b0;
		r_rdwr_sel			<=  1'b0;
		r_opmd_sel			<=  2'b0;
		end 
	else case (state)
		// 
		STATE_SIG_0 : begin
			if (r_trig_SPI_frame) begin
				state				<= STATE_SIG_1;
				r_done_SPI_frame	<= 1'b0;
				r_LAN_SCSn			<= 1'b0;
				r_LAN_SCLK			<= 1'b0;
				r_frame_adct		<= 1'b1; //
				r_frame_data		<= 1'b0;
				r_cnt_adct			<= INIT_cnt_adct;
				r_cnt_data			<= INIT_cnt_data;
				// load frame address and control
				r_sh_buf_adct		<= {
									i_frame_adrs, 
									i_frame_ctrl_blck_sel, 
									i_frame_ctrl_rdwr_sel,
									i_frame_ctrl_opmd_sel};
				//
				r_sh_buf_data		<=  8'b0;
				r_sh_buf_data_trig	<=  8'b0;
				r_sh_buf_data_read	<=  8'b0;
				r_frame_data_rd		<=  8'b0;
				r_frame_done_rd		<=  1'b0;
				//
				r_blck_sel			<=  i_frame_ctrl_blck_sel;
				r_rdwr_sel			<=  i_frame_ctrl_rdwr_sel;
				r_opmd_sel			<=  i_frame_ctrl_opmd_sel;
				//
				end
			end
		// 
		STATE_SIG_1 : begin
			state				<= STATE_SIG_2;
			r_LAN_SCLK			<= 1'b1;
			// data phase for read // skip the first eventually
			if (r_frame_data) begin
				// shift buffer for read
				r_sh_buf_data_read			<= {r_sh_buf_data_read[6:0], i_LAN_MISO};
				end
			end
		// 
		STATE_SIG_2 : begin
			// common
			r_LAN_SCLK			<= 1'b0;
			// address and control phases 
			if (r_frame_adct) begin
				// count down 
				r_cnt_adct			<= r_cnt_adct - 1;
				// shift buffer
				r_sh_buf_adct		<= {r_sh_buf_adct[22:0], 1'b0};
				//
				state				<= STATE_SIG_1;
				//
				if (r_cnt_adct == 3) begin //
					r_frame_done_wr		<=  1'b1; // set
					end
				else if (r_cnt_adct == 2) begin //
					r_frame_done_wr		<=  1'b0; // clear 
					end
				else if (r_cnt_adct == 1) begin // last control bit sent 
					r_frame_adct		<= 1'b0;
					r_frame_data		<= 1'b1;
					r_cnt_adct			<= INIT_cnt_adct; // reset
					r_cnt_data			<= w_frame_num_byte_data * 8; // data bit count
					//
					// load frame data 
					r_sh_buf_data		<= i_frame_data_wr; //$$
					r_sh_buf_data_trig	<=  8'b0000_0001;
					end
				end
			// data phase 
			else if (r_frame_data) begin
				// count down 
				r_cnt_data			<= r_cnt_data - 1;
				// shift buffer for write
				r_sh_buf_data_trig	<= {r_sh_buf_data_trig[ 6:0], r_sh_buf_data_trig[7]};
				r_sh_buf_data		<= (r_sh_buf_data_trig[7]==0)? 
										{r_sh_buf_data[ 6:0], 1'b0}:
										i_frame_data_wr; // load frame data every 8 bits...
				// done for write
				if (r_sh_buf_data_trig[5]&&(r_cnt_data>8)) begin 
					r_frame_done_wr		<= 1'b1; // set
					end 
				else begin 
					r_frame_done_wr		<= 1'b0;
					end 
				// load data for read // skip the fist slot
				if (r_sh_buf_data_trig[0]&&(r_cnt_data<w_frame_num_byte_data * 8 - 7)) begin 
					r_frame_data_rd		<= r_sh_buf_data_read;
					end
				//
				if (r_sh_buf_data_trig[0]&&(r_cnt_data<w_frame_num_byte_data * 8 - 7)) begin 
					//r_frame_data_rd		<= r_sh_buf_data_read;
					r_frame_done_rd		<= 1'b1; //$$
					end 
				else begin 
					r_frame_done_rd		<= 1'b0;
					end 
				//
				if (r_cnt_data == 1) begin // last data bit sent
					state				<= STATE_SIG_3;
					r_frame_adct		<= 1'b0;
					r_frame_data		<= 1'b0;
					r_cnt_adct			<= INIT_cnt_adct; // reset
					r_cnt_data			<= INIT_cnt_data; // reset
					end
				else begin
					state				<= STATE_SIG_1;
					end
				end
			//
			end
		// 
		STATE_SIG_3 : begin
			state				<= STATE_SIG_4;
			r_LAN_SCSn			<= 1'b1;
			// data phase for read // read the last bit 
			r_sh_buf_data_read			<= {r_sh_buf_data_read[6:0], i_LAN_MISO};
			//
			end
		// 
		STATE_SIG_4 : begin
			state				<= STATE_SIG_5;
			r_frame_done_rd		<= 1'b1; // turn on the last done bit.
			// load last readback
			r_frame_data_rd		<= r_sh_buf_data_read;
			end
		// 
		STATE_SIG_5 : begin
			state				<= STATE_SIG_6;
			end
		// 
		STATE_SIG_6 : begin
			state		<= STATE_SIG_7;
			r_frame_done_rd		<= 1'b0; // turn off the last done bit.
			end
		//
		STATE_SIG_7 : begin
			state				<= STATE_SIG_0;
			r_done_SPI_frame	<= 1'b1;
			end
		// 
	endcase
	
endmodule
