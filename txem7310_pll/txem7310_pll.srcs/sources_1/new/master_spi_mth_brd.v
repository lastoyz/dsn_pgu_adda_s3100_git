// master_spi_mth_brd.v
//   some master SPI controller 
//
//   === parameter ===
//   logic base freq                          : 72MHz (b_clk)
//   spi sclk freq                            : ~6.5MHz or "11" b_clk
//   frame bit count                          : 32 bits
//   slave selection length                   : "365" b_clk
//   first sclk rise after slave selection    : "12" b_clk
//   slave selection end after last sclk fall : "4" b_clk
//
//   === timing (rough) ===
//   slave selection (inverted) : SS_B 
//   spi clock                  : SCLK 
//   spi master output          : MOSI 
//   spi master input           : MISO 
//   ----
//   index_H      0000000000111111111122222222223333333333444444444455555555556666
//   index_L      0123456789012345678901234567890123456789012345678901234567890123
//   SS_B   -----__________________________________________________________________-----
//   SCLK   _______-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-______
//   MOSI   ______CCccCCccCCccAAaaAAaaAAaaAAaaAAaaDDddDDddDDddDDddDDddDDddDDddDDdd______
//   MISO1  ______________________________________BBbbBBbbBBbbBBbbBBbbBBbbBBbbBBbb______
//   MISO2  _____________________________________BBbbBBbbBBbbBBbbBBbbBBbbBBbbBBbb_______
//
//   MISO1 ... normal reponse
//   MISO2 ... half-clock-earlier reponse // reserved 
//
//   === frame contents ===
//   write frame for sw info data : write any data   @ address 0x000  
//   read  frame for known data   : read  0x33AACC55 @ address 0x380
//   ----
//   frame data : {C[5:0], A[9:0], D[15:0]}
//               control C5  : '0' for short packet
//               control C4  : '0' for write; '1' for read
//               control C3  : reserved
//               control C2  : reserved
//               control C1  : reserved
//               control C0  : reserved
//               adress  A9   
//               adress  A8   
//               adress  A7   
//               adress  A6   
//               adress  A5   
//               adress  A4   
//               adress  A3   
//               adress  A2   
//               adress  A1   
//               adress  A0   
//               data    D15 
//               data    D14 
//               data    D13 
//               data    D12 
//               data    D11 
//               data    D10 
//               data    D9  
//               data    D8  
//               data    D7  
//               data    D6  
//               data    D5  
//               data    D4  
//               data    D3  
//               data    D2  
//               data    D1  
//               data    D0  
//
//   === re-parameterize ===
//   use 26MHz or 38.461ns
//   ----
//   logic base freq                          : 72MHz (b_clk) --> 26MHz (c_clk)
//   spi sclk freq                            : ~6.5MHz or  "11" b_clk -->   "4" c_clk
//   frame bit count                          : 32 bits
//   slave selection length                   : ~5.07us or "365" b_clk --> "132" c_clk = 31*4 + 2 + 6
//   first sclk rise after slave selection    : "12" b_clk             -->   "5" c_clk
//   slave selection end after last sclk fall :  "4" b_clk             -->   "1" c_clk
//
//   === timing based on control index ===
//   ctl_idx_H  0000000000111111111122222222223333333333444444444455555555556666666666777777777788888888889999999999AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDD    
//   ctl_idx_L  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012    
//   index_H        0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 6 6 6 6
//   index_L        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
//   SS_B   -----____________________________________________________________________________________________________________________________________----
//                           
//   SCLK   __________--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--__--_____
//   MOSI   ________CCCCccccCCCCccccCCCCccccAAAAaaaaAAAAaaaaAAAAaaaaAAAAaaaaAAAAaaaaDDDDddddDDDDddddDDDDddddDDDDddddDDDDddddDDDDddddDDDDddddDDDDdddd_____
//   MISO1  ________________________________________________________________________BBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbb_____
//   MISO2  _______________________________________________________________________BBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbbBBBBbbbb______
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module master_spi_mth_brd (
	input  wire clk, // 104MHz
	input  wire reset_n,
	
	// control 
	input  wire i_trig_init , // 
	output wire o_done_init , // to be used for monitoring test mode 
	input  wire i_trig_frame, // 
	output wire o_done_frame, // 

	// frame data 
	input  wire [ 5:0] i_frame_data_C, // control  data on MOSI
	input  wire [ 9:0] i_frame_data_A, // address  data on MOSI
	input  wire [15:0] i_frame_data_D, // register data on MOSI
	//
	output wire [15:0] o_frame_data_B, // readback data on MISO, low  16 bits
	output wire [15:0] o_frame_data_E, // readback data on MISO, high 16 bits
	
	// IO 
	output wire o_SS_B   ,
	output wire o_MCLK   ,
	input  wire i_SCLK   ,
	output wire o_MOSI   ,
	input  wire i_MISO   ,
	input  wire i_MISO_EN,
	
	output wire valid
); 
//{

//// valid //{
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
//}

//// o_done_init //{
reg r_done_init;
assign o_done_init = r_done_init;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_done_init <= 1'b0;
	end
	else begin
		if (i_trig_init)
			r_done_init <= 1'b1;
	end
//}

//// trig and control index //{
reg [1:0] r_trig_frame;
wire w_rise__trig_frame = (~r_trig_frame[1]) & (r_trig_frame[0]);
reg r_done_frame;
reg [9:0] r_ctl_idx; //based on 104MHz

// sampling i_trig_frame //{
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_trig_frame <= 2'b0;
	end 
else begin
	r_trig_frame <= {r_trig_frame[0], i_trig_frame};
	end
//}

// count up r_ctl_idx //{
//parameter STOP__ctl_idx = 10'd132*4; // based on 26*4MHz=104MHz 
parameter STOP__ctl_idx = 10'd134*4; // based on 26*4MHz=104MHz // add half cycle of 26MHz ... 132+2 = 134 // 5.15384615 us
//parameter STOP__ctl_idx = 10'd143*4; // based on 26*4MHz=104MHz //132+11 = 143 // 5.5 us
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_ctl_idx <= 10'b0;
	end 
else begin
	if (r_ctl_idx == 0)
		if (w_rise__trig_frame)
			r_ctl_idx <= 1;	
		else
			r_ctl_idx <= r_ctl_idx;	// stay
	else 
		if (r_ctl_idx == STOP__ctl_idx)
			r_ctl_idx <= 0;	
		else
			r_ctl_idx <= r_ctl_idx + 1; // count up
	end
//}

// r_done_frame //{
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_done_frame <= 1'b0;
	end 
else begin
	if (w_rise__trig_frame)
		r_done_frame <= 1'b0;
	else if (r_ctl_idx == 0)
		r_done_frame <= 1'b1;
	else 
		r_done_frame <= r_done_frame; // stay
	end
//
assign o_done_frame = r_done_frame;
//}

//}

//// r_SS_B //{
reg r_SS_B;
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_SS_B <= 1'b1;
	end 
else begin
	if (w_rise__trig_frame)
		r_SS_B <= 1'b0;
	else if (r_ctl_idx == STOP__ctl_idx)
		r_SS_B <= 1'b1;
	else 
		r_SS_B <= r_SS_B; // stay
	end
//
assign o_SS_B = r_SS_B;
//}

//// r_pttn__MCLK //{
reg [15:0] r_pttn__MCLK; // pattern of "--------__________"
parameter PTTN__MCLK = 16'b11111111_00000000;
parameter GOGO_MCLK__ctl_idx = 10'd21;   // based on 26*4MHz
//parameter STOP_MCLK__ctl_idx = 10'd524;  // based on 26*4MHz // 131*4
parameter STOP_MCLK__ctl_idx = 10'd528;  // based on 26*4MHz // 132*4
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_pttn__MCLK <= 16'b0;
	end 
else begin
	if      (r_ctl_idx > STOP_MCLK__ctl_idx-1)
		r_pttn__MCLK <= r_pttn__MCLK; // stay
	else if (r_ctl_idx >  GOGO_MCLK__ctl_idx-1)
		r_pttn__MCLK <= {r_pttn__MCLK[14:0], r_pttn__MCLK[15]}; // shift left
	else if (r_ctl_idx == GOGO_MCLK__ctl_idx-1)
		r_pttn__MCLK <= PTTN__MCLK;
	end
//
assign o_MCLK = r_pttn__MCLK[15];
//}

//// r_pttn__MOSI //{
reg [31:0] r_pttn__MOSI;
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_pttn__MOSI <= 32'b0;
	end 
else begin
	if      (w_rise__trig_frame)
		r_pttn__MOSI <= {i_frame_data_C, i_frame_data_A, i_frame_data_D};
	else if (r_pttn__MCLK == 16'b1_0000_0000_1111_111) // falling edge pattern
		r_pttn__MOSI <= {r_pttn__MOSI[30:0], r_pttn__MOSI[31]}; // shift left
	else if (r_done_frame)
		r_pttn__MOSI <= 32'b0;
	else 
		r_pttn__MOSI <= r_pttn__MOSI; // stay
	end
//
assign o_MOSI = r_pttn__MOSI[31];
//}

//// o_frame_data_B // readback data //{
reg [31:0] r_pttn__MISO  ; // all pattern from MISO 
reg [15:0] r_frame_data_B; // data pattern only
reg [15:0] r_frame_data_E;
reg [15:0] r_pttn__SCLK; // slave clock pattern // based on 26*4MHz
wire [3:0] w_pttn__sclk_detect = 4'b0011; // 8'b0000_0001 --> 4'b0011 ... for balanced duty response

//
wire w_MISO = (i_MISO_EN)? i_MISO : 1'b1;
wire w_SCLK = i_SCLK;
//
always @(posedge clk, negedge reset_n) 
if (!reset_n) begin
	r_pttn__MISO     <= 32'b0;
	r_frame_data_B   <= 16'b0;
	r_frame_data_E   <= 16'b0;
	r_pttn__SCLK     <= 16'b0;
	end 
else begin
	//
	if      (w_rise__trig_frame) begin
		r_pttn__MISO     <= 32'b0;
		r_frame_data_B   <= 16'b0;
		r_frame_data_E   <= 16'b0;
		end
	else if (r_done_frame) begin
		r_frame_data_B   <= r_pttn__MISO[15:0 ]; // load data 
		r_frame_data_E   <= r_pttn__MISO[31:16]; // load data 
		end
	else if (r_pttn__SCLK[3:0] == w_pttn__sclk_detect) // rising edge pattern + 2 delays // relax
		r_pttn__MISO <= {r_pttn__MISO[30:0], w_MISO}; // shift left in
	else begin
		r_pttn__MISO     <= r_pttn__MISO;   // stay
		r_frame_data_B   <= r_frame_data_B; // stay
		r_frame_data_E   <= r_frame_data_E; // stay
		end
	//
	r_pttn__SCLK <= {r_pttn__SCLK[14:0], w_SCLK}; // shift left
	//
	end
//
assign o_frame_data_B = r_frame_data_B;
assign o_frame_data_E = r_frame_data_E;
//}

//}
endmodule

