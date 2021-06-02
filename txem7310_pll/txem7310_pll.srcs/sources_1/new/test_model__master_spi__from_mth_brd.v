// test_model__master_spi__from_mth_brd.v
//   test model for some master SPI controller 
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
//   MISO2 ... half-clock-earlier reponse
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
module test_model__master_spi__from_mth_brd (  
	input  wire clk, // base clock 26MHz
	input  wire reset_n,
	input  wire en,
	//
	input  wire [ 5:0] i_frame_data_C, // control  data on MOSI
	input  wire [ 9:0] i_frame_data_A, // address  data on MOSI
	input  wire [15:0] i_frame_data_D, // register data on MOSI
	output wire [15:0] o_frame_data_B, // readback data on MISO
	//
	input  wire i_trig_frame,
	output wire o_done_frame,
	//
	output wire o_SS_B ,
	output wire o_SCLK ,
	output wire o_MOSI ,
	input  wire i_MISO 
);


//// registers : trig and control index
reg r_trig_frame;
reg r_done_frame;
reg [7:0] r_ctl_idx;

// sampling i_trig_frame
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_trig_frame <= 1'b0;
	end 
else if (en) begin
	r_trig_frame <= i_trig_frame;	
	end
//
wire w_rise__trig_frame = (~r_trig_frame) & (i_trig_frame);

// count up r_ctl_idx
parameter STOP__ctl_idx = 8'd132; // based on 26MHz
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_ctl_idx <= 8'b0;
	end 
else if (en) begin
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

// r_done_frame
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_done_frame <= 1'b0;
	end 
else if (en) begin
	if (w_rise__trig_frame)
		r_done_frame <= 1'b0;
	else if (r_ctl_idx == 0)
		r_done_frame <= 1'b1;
	else 
		r_done_frame <= r_done_frame; // stay
	end


// r_SS_B
reg r_SS_B;
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_SS_B <= 1'b1;
	end 
else if (en) begin
	if (w_rise__trig_frame)
		r_SS_B <= 1'b0;
	else if (r_ctl_idx == STOP__ctl_idx)
		r_SS_B <= 1'b1;
	else 
		r_SS_B <= r_SS_B; // stay
	end

// r_pttn__SCLK
reg [3:0] r_pttn__SCLK; // pattern of "--__"
parameter PTTN__SCLK = 4'b1100;
parameter GOGO_SCLK__ctl_idx = 8'd6;
parameter STOP_SCLK__ctl_idx = 8'd131; //
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_pttn__SCLK <= 4'b0;
	end 
else if (en) begin
	if      (r_ctl_idx == GOGO_SCLK__ctl_idx-1)
		r_pttn__SCLK <= PTTN__SCLK;
	else if (r_ctl_idx >  GOGO_SCLK__ctl_idx-1)
		r_pttn__SCLK <= {r_pttn__SCLK[2:0], r_pttn__SCLK[3]}; // shift left
	else if (r_ctl_idx == STOP_SCLK__ctl_idx-1)
		r_pttn__SCLK <= r_pttn__SCLK; // stay
	else 
		r_pttn__SCLK <= 4'b0;
	end

// r_pttn__MOSI
reg [31:0] r_pttn__MOSI;
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_pttn__MOSI <= 32'b0;
	end 
else if (en) begin
	if      (w_rise__trig_frame)
		r_pttn__MOSI <= {i_frame_data_C, i_frame_data_A, i_frame_data_D};
	else if (r_pttn__SCLK == 4'b1001) // falling edge pattern
		r_pttn__MOSI <= {r_pttn__MOSI[30:0], r_pttn__MOSI[31]}; // shift left
	else if (r_done_frame)
		r_pttn__MOSI <= 32'b0;
	else 
		r_pttn__MOSI <= r_pttn__MOSI; // stay
	end


// r_frame_data_B // readback data
reg [15:0] r_frame_data_B; // data pattern only
reg [31:0] r_pttn__MISO  ; // all pattern from MISO 
wire w_MISO;
//
always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_pttn__MISO     <= 32'b0;
	r_frame_data_B   <= 16'b0;
	end 
else if (en) begin
	if      (w_rise__trig_frame) begin
		r_pttn__MISO     <= 32'b0;
		r_frame_data_B   <= 16'b0;
		end
	else if (r_pttn__SCLK == 4'b1100) // rising edge pattern + one delay
		r_pttn__MISO <= {r_pttn__MISO[30:0], w_MISO}; // shift left in
	else if (r_done_frame)
		r_frame_data_B   <= r_pttn__MISO[15:0]; // load data 
	else begin
		r_pttn__MISO     <= r_pttn__MISO;   // stay
		r_frame_data_B   <= r_frame_data_B; // stay
		end
	end
//


//// outputs
assign o_frame_data_B = r_frame_data_B;
//
assign o_done_frame = r_done_frame;
//
assign o_SS_B = r_SS_B;
assign o_SCLK = r_pttn__SCLK[3];
assign o_MOSI = r_pttn__MOSI[31];


//// input 
//parameter DELAY_NS__MISO = 50; // ns // OK with no timing adjustment
//parameter DELAY_NS__MISO = 60; // ns // OK with no timing adjustment
//parameter DELAY_NS__MISO = 75; // ns // NG with no timing adjustment
parameter DELAY_NS__MISO = 140; // ns // NG with no timing adjustment // OK miso one bit ahead en
//parameter DELAY_NS__MISO = 75; // ns // OK // loopback data on frame_data_B 0xCC33
//parameter DELAY_NS__MISO = 120; // ns // NG // loopback data on frame_data_B 0xe619
//
assign #(DELAY_NS__MISO) w_MISO = i_MISO;


//
endmodule
