// master_spi_mth_brd.v
//   some master SPI controller 
//
//   master_spi_mth_brd__wrapper : fifo interface added
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

//// TODO: master_spi_mth_brd //{
module master_spi_mth_brd (
	input  wire clk, // 104MHz
	input  wire reset_n,
	
	// control 
	input  wire i_trig_init , // 
	output wire o_done_init , // to be used for monitoring test mode 
	input  wire i_trig_frame, // edge-detection inside
	output wire o_done_frame, // level output inside
	output wire o_done_frame_pulse, // one-pulse output inside

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
reg r_done_frame_pulse;
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

//// input buffer //{
reg  [ 5:0] r_frame_data_C;
reg  [ 9:0] r_frame_data_A;
reg  [15:0] r_frame_data_D;

wire [ 5:0] w_frame_data_C = r_frame_data_C;
wire [ 9:0] w_frame_data_A = r_frame_data_A;
wire [15:0] w_frame_data_D = r_frame_data_D;

always @(posedge clk, negedge reset_n)
if (!reset_n) begin
	r_frame_data_C <=  6'b0;
	r_frame_data_A <= 10'b0;
	r_frame_data_D <= 16'b0;
	end 
else if (i_trig_frame) begin
	r_frame_data_C <= i_frame_data_C;
	r_frame_data_A <= i_frame_data_A;
	r_frame_data_D <= i_frame_data_D;
	end

//}


// count up r_ctl_idx //{
//parameter STOP__ctl_idx = 10'd132*4; // based on 26*4MHz=104MHz 
//parameter STOP__ctl_idx = 10'd134*4; // based on 26*4MHz=104MHz // add half cycle of 26MHz ... 132+2 = 134 // 5.15384615 us
//parameter STOP__ctl_idx = 10'd143*4; // based on 26*4MHz=104MHz //132+11 = 143 // 5.5 us
parameter STOP__ctl_idx = 10'd546; // based on 26*4MHz=104MHz // add half cycle of 26MHz ... 132+4.5 = 136.5 // 5.25 us
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
	r_done_frame_pulse <= 1'b0;
	end 
else begin
	if (w_rise__trig_frame)
		r_done_frame <= 1'b0;
	//else if (r_ctl_idx == 0) //$$ to revise // not to response with reset
	else if (r_ctl_idx == STOP__ctl_idx)
		r_done_frame <= 1'b1;
	else 
		r_done_frame <= r_done_frame; // stay
	//
	if (r_ctl_idx == STOP__ctl_idx)
		r_done_frame_pulse <= 1'b1;
	else 
		r_done_frame_pulse <= 1'b0;
	//
	end
//
assign o_done_frame       = r_done_frame      ;
assign o_done_frame_pulse = r_done_frame_pulse;
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
		r_pttn__MOSI <= {w_frame_data_C, w_frame_data_A, w_frame_data_D};
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

endmodule
//}


//// TODO: master_spi_mth_brd__wrapper //{
module master_spi_mth_brd__wrapper (
	input  wire clk, // 104MHz
	input  wire reset_n,
	
	// control 
	input  wire i_trig_init       , // 
	output wire o_done_init       , // to be used for monitoring test mode 
	input  wire i_trig_frame      , // edge-detection inside
	output wire o_done_frame      , // level output inside
	output wire o_done_frame_pulse, // one-pulse output inside
	input  wire i_trig_reset_fifo , // reset fifo // 3 clock long
	input  wire i_trig_frame_fifo , // trigger spi frame with fifo data
	output wire o_done_reset_fifo , // one pulse
	output wire o_done_frame_fifo , // one pulse

	// frame data 
	input  wire [ 5:0] i_frame_data_C, // control  data on MOSI
	input  wire [ 9:0] i_frame_data_A, // address  data on MOSI
	input  wire [15:0] i_frame_data_D, // register data on MOSI
	//
	output wire [15:0] o_frame_data_B, // readback data on MISO, low  16 bits
	output wire [15:0] o_frame_data_E, // readback data on MISO, high 16 bits
	
	// fifo interface
	input  wire        i_mosi__wr_clk, //
	input  wire        i_mosi__wr_en , //
	input  wire [31:0] i_mosi__din   , //
	input  wire        i_miso__rd_clk, //
	input  wire        i_miso__rd_en , //
	output wire [31:0] o_miso__dout  , //
	
	// IO 
	output wire o_SS_B   ,
	output wire o_MCLK   ,
	input  wire i_SCLK   ,
	output wire o_MOSI   ,
	input  wire i_MISO   ,
	input  wire i_MISO_EN,
	
	output wire valid
);

//// master_spi_mth_brd //{
wire  [ 5:0] w_frame_data_C ;
wire  [ 9:0] w_frame_data_A ;
wire  [15:0] w_frame_data_D ;
wire  [15:0] w_frame_data_B ; assign o_frame_data_B = w_frame_data_B ;
wire  [15:0] w_frame_data_E ; assign o_frame_data_E = w_frame_data_E ;
wire         w_trig_frame       ;
wire         w_done_frame_pulse ;

master_spi_mth_brd  master_spi__inst(
	.clk                (clk               ), // 104MHz
	.reset_n            (reset_n           ),
	
	// control 
	.i_trig_init        (i_trig_init       ), // level sampling inside based on clk
	.o_done_init        (o_done_init       ), // to be used for monitoring test mode 
	.i_trig_frame       (w_trig_frame      ), // rise-edge detection inside based on clk
	.o_done_frame       (o_done_frame      ), // level output
	.o_done_frame_pulse (w_done_frame_pulse), // pulse output

	// frame data 
	.i_frame_data_C     (w_frame_data_C     ), // [ 5:0] // control  data on MOSI
	.i_frame_data_A     (w_frame_data_A     ), // [ 9:0] // address  data on MOSI
	.i_frame_data_D     (w_frame_data_D     ), // [15:0] // register data on MOSI
	.o_frame_data_B     (w_frame_data_B     ), // [15:0] // readback data on MISO, low  16 bits
	.o_frame_data_E     (w_frame_data_E     ), // [15:0] // readback data on MISO, high 16 bits
	
	// IO 
	.o_SS_B             (o_SS_B             ),
	.o_MCLK             (o_MCLK             ), // sclk master out 
	.i_SCLK             (i_SCLK             ), // sclk slave in
	.o_MOSI             (o_MOSI             ),
	.i_MISO             (i_MISO             ),
	.i_MISO_EN          (i_MISO_EN          ),
	
	.valid              (valid              )
);

//}

//// FIFO interface //{
//  mspi mosi FIFO side : lan(72MHz)or host(140MHz) --> spi(104MHz)
//    depth 512, bit width 32 bit, first word first through
//  mspi miso FIFO side : lan(72MHz)or host(140MHz) <-- spi(104MHz)
//    depth 512, bit width 32 bit, first word first through
//  note ... lan case  .. lan(72MHz)   <--> spi(104MHz)
//           host case .. host(140MHz) <--> spi(104MHz)
//  try first lan case 
//  note ... fifo_generator_4_3_1 .. lan(72MHz) wr  --> spi(104MHz) rd
//           fifo_generator_4_3_2 .. lan(72MHz) rd <--  spi(104MHz) wr

// fifo_generator_4_3_* fifo_inst(
//   .rst       (), // input wire rst
//
//   .wr_clk    (), // input wire wr_clk
//   .wr_en     (), // input wire wr_en
//   .din       (), // input wire [31 : 0] din
//   .full      (), // output wire full
//   .wr_ack    (), // output wire wr_ack
//
//   .rd_clk    (), // input wire rd_clk
//   .rd_en     (), // input wire rd_en
//   .dout      (), // output wire [31 : 0] dout
//   .empty     (), // output wire empty
//   .valid     ()  // output wire valid
// );

wire  w_reset_fifo  ;

wire         w_mosi__rd_en ;
wire  [31:0] w_mosi__dout  ;
wire         w_mosi__empty ;

wire         w_miso__wr_en ;
wire  [31:0] w_miso__din   ;

// lan(72MHz) wr  --> spi(104MHz) rd
fifo_generator_4_3_1  mspi_mosi_fifo__inst(
   .rst       (w_reset_fifo       ), // input wire rst

   .wr_clk    (i_mosi__wr_clk), // input wire wr_clk
   .wr_en     (i_mosi__wr_en ), // input wire wr_en
   .din       (i_mosi__din   ), // input wire [31 : 0] din
   .full      (), // output wire full
   .wr_ack    (), // output wire wr_ack

   .rd_clk    (clk                ), // input wire rd_clk
   .rd_en     (w_mosi__rd_en      ), // input wire rd_en
   .dout      (w_mosi__dout       ), // output wire [31 : 0] dout
   .empty     (w_mosi__empty      ), // output wire empty
   .valid     ()  // output wire valid
); 

// lan(72MHz) rd <--  spi(104MHz) wr
fifo_generator_4_3_2  mspi_miso_fifo__inst(
   .rst       (w_reset_fifo       ), // input wire rst

   .wr_clk    (clk                ), // input wire wr_clk
   .wr_en     (w_miso__wr_en      ), // input wire wr_en
   .din       (w_miso__din        ), // input wire [31 : 0] din
   .full      (), // output wire full
   .wr_ack    (), // output wire wr_ack

   .rd_clk    (i_miso__rd_clk     ), // input wire rd_clk
   .rd_en     (i_miso__rd_en      ), // input wire rd_en
   .dout      (o_miso__dout       ), // output wire [31 : 0] dout
   .empty     (), // output wire empty
   .valid     ()  // output wire valid
); 


//// fifo controller with trigger frame fifo
wire w_trig_frame_int  ;
wire w_done_frame_int  ;
wire w_empty__mosi_fifo;
wire w_busy_reset_fifo;
wire w_busy_frame_fifo;
wire w_wr_en_miso_fifo;

control_mspi_fifo  control_mspi_fifo__inst(
	.clk                (clk               ) , // 104MHz
	.reset_n            (reset_n           ) ,

	.i_trig_reset_fifo  (i_trig_reset_fifo ) , // reset fifo // trigger 3 clock long
	.i_trig_frame_fifo  (i_trig_frame_fifo ) , // trigger spi frame with fifo data
	.o_done_reset_fifo  (o_done_reset_fifo ) , // one pulse
	.o_done_frame_fifo  (o_done_frame_fifo ) , // one pulse
	
	.o_trig_frame_int   (w_trig_frame_int  ) , // internal frame trigger
	.i_done_frame_int   (w_done_frame_int  ) , // internal frame done
	.i_empty__mosi_fifo (w_empty__mosi_fifo) , // empty mosi fifo

	.o_busy_reset_fifo  (w_busy_reset_fifo ) , // 
	.o_busy_frame_fifo  (w_busy_frame_fifo ) , // busy for sending frame fifo data
	
	.o_wr_en_miso_fifo  (w_wr_en_miso_fifo )   //

);

//}

//// port mux //{
assign w_reset_fifo = (~reset_n) | w_busy_reset_fifo;

assign w_frame_data_C = (w_busy_frame_fifo)? w_mosi__dout[31:26] : i_frame_data_C ;
assign w_frame_data_A = (w_busy_frame_fifo)? w_mosi__dout[25:16] : i_frame_data_A ;
assign w_frame_data_D = (w_busy_frame_fifo)? w_mosi__dout[15: 0] : i_frame_data_D ;

assign w_trig_frame       = (w_busy_frame_fifo)?   w_trig_frame_int : i_trig_frame ;
assign o_done_frame_pulse = (w_busy_frame_fifo)?               1'b0 : w_done_frame_pulse ;
assign w_done_frame_int   = (w_busy_frame_fifo)? w_done_frame_pulse : 1'b0 ;
assign w_empty__mosi_fifo = (w_busy_frame_fifo)?      w_mosi__empty : 1'b0 ;

assign w_mosi__rd_en  =  w_trig_frame_int;

assign w_miso__din    = {w_frame_data_E, w_frame_data_B};
assign w_miso__wr_en  =  w_wr_en_miso_fifo ;

//}

endmodule
//}


//// TODO: control_mspi_fifo //{
module  control_mspi_fifo (
	input  wire clk    , // 104MHz
	input  wire reset_n,
	
	// control 
	input  wire i_trig_reset_fifo , // reset fifo // 3 clock long
	input  wire i_trig_frame_fifo , // trigger spi frame with fifo data
	output wire o_done_reset_fifo , // one pulse
	output wire o_done_frame_fifo , // one pulse

	output wire o_trig_frame_int   , // internal frame trigger
	input  wire i_done_frame_int   , // internal frame done
	input  wire i_empty__mosi_fifo , // empty mosi fifo
	                                 
	output wire o_busy_reset_fifo  , // 
	output wire o_busy_frame_fifo  , // busy for sending frame fifo data
	
	output wire o_wr_en_miso_fifo
);

//// reset fifo control //{
//               clk : _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
// i_trig_reset_fifo : _____--_______________________
// o_busy_reset_fifo : _______------_________________
// o_done_reset_fifo : ___________--_________________

reg [2:0] r_sh_busy_reset_fifo;
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_sh_busy_reset_fifo <= 3'b0;
	end
	else begin
		if (i_trig_reset_fifo)
			r_sh_busy_reset_fifo <= 3'b111;
		else
			r_sh_busy_reset_fifo <= {1'b0, r_sh_busy_reset_fifo[2:1]}; // shift right
	end

assign o_busy_reset_fifo = r_sh_busy_reset_fifo[0];
assign o_done_reset_fifo = (~r_sh_busy_reset_fifo[1]) & (r_sh_busy_reset_fifo[0]); // falling

//}

//// internal trigger control //{

// * normal timing
//               clk : _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
// i_trig_frame_fifo : _____--________________________________________________
// o_busy_frame_fifo : _______--------------------------------------__________
// o_done_frame_fifo : _____________________________________________--________
// o_trig_frame_int  : _________--__________--__________--____________________
// r_busy_frame_int  : _________----------__----------__----------____________
// i_done_frame_int  : _________________--__________--__________--____________
// i_empty__mosi_fifo: ___________________________________--------------------

// * timing - no fifo data
//               clk : _-_-_-_-_-_-_-_-_-_
// i_trig_frame_fifo : _____--____________
// o_busy_frame_fifo : _______--__________
// o_done_frame_fifo : _________--________
// o_trig_frame_int  : ___________________
// r_busy_frame_int  : ___________________
// i_done_frame_int  : ___________________
// i_empty__mosi_fifo: -------------------

// * normal timing -- rev frame interval control
//               clk : _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
// i_trig_frame_fifo : _____--________________________________________________
// o_busy_frame_fifo : _______--------------------------------------__________
// o_done_frame_fifo : _____________________________________________--________
// o_trig_frame_int  : _________--__________--__________--____________________
// r_busy_frame_int  : _________----------__----------__----------____________
// i_done_frame_int  : _______________--__________--__________--______________
// i_empty__mosi_fifo: ___________________________________--------------------


reg r_busy_frame_fifo;
reg r_busy_frame_int;
reg r_done_frame_fifo;
reg r_trig_frame_int;

reg [4:0] r_cnt_clear_busy_frame_int;
parameter CNT_CLEAR__BUSY_FRAME_INT = 5'd22;

always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_busy_frame_fifo          <= 1'b0;
		r_busy_frame_int           <= 1'b0;
		r_done_frame_fifo          <= 1'b0;
		r_trig_frame_int           <= 1'b0;
		r_cnt_clear_busy_frame_int <= 5'd0;
	end
	else begin
		if      (i_trig_frame_fifo) // trig frame fifo
			begin
			r_busy_frame_fifo <= 1'b1;
			end
		else if ( (~r_busy_frame_int)&(i_empty__mosi_fifo) ) // done frame fifo
			begin 
			r_busy_frame_fifo <= 1'b0;
			r_done_frame_fifo <= 1'b1;
			end
		else 
			begin
			r_busy_frame_fifo <= r_busy_frame_fifo ; 
			r_done_frame_fifo <= 1'b0 ; // one pulse
			end
		//
		if      ( r_busy_frame_fifo&(~r_busy_frame_int)&(~i_empty__mosi_fifo) )
			begin
			r_trig_frame_int           <= 1'b1;
			r_busy_frame_int           <= 1'b1;
			r_cnt_clear_busy_frame_int <= 5'd0;
			end
		else if ( r_busy_frame_fifo&(i_done_frame_int) ) // clear r_busy_frame_int
			begin
			//r_busy_frame_int  <= 1'b0;
			r_cnt_clear_busy_frame_int <= r_cnt_clear_busy_frame_int + 1;
			end
		else if (r_cnt_clear_busy_frame_int == CNT_CLEAR__BUSY_FRAME_INT)
			begin
				r_busy_frame_int  <= 1'b0;
				r_cnt_clear_busy_frame_int <= 5'd0;
			end
		else if (r_cnt_clear_busy_frame_int > 0)
			begin
				r_cnt_clear_busy_frame_int <= r_cnt_clear_busy_frame_int + 1;
			end
		else 
			begin
			r_trig_frame_int  <= 1'b0;
			end
		//
	end

assign o_busy_frame_fifo = r_busy_frame_fifo;
assign o_done_frame_fifo = r_done_frame_fifo;
assign o_trig_frame_int  = r_trig_frame_int;

//o_wr_en_miso_fifo : one clock delay from i_done_frame_int
reg r_wr_en_miso_fifo;
assign o_wr_en_miso_fifo = r_wr_en_miso_fifo;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_wr_en_miso_fifo  <= 1'b0;
	end
	else begin
		r_wr_en_miso_fifo  <= i_done_frame_int; // one clock delay
	end

//} 

endmodule
//}