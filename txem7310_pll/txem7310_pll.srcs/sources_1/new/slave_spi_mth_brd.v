// slave_spi_mth_brd.v
//   slave SPI controller for MHVSU base board from mother board SPI master
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

//// sub: //{

//}


//// module: slave_spi_mth_brd //{
module slave_spi_mth_brd (  
	input  wire clk, // base clock 72MHz
	input  wire reset_n,
	
	//// slave SPI pins //{
	input  wire i_SPI_CS_B    ,
	input  wire i_SPI_CLK     ,
	input  wire i_SPI_MOSI    ,
	output wire o_SPI_MISO    ,
	output wire o_SPI_MISO_EN , // MISO buffer control
	//}
	
	//// monitor
	output wire [15:0] o_cnt_sspi_cs, // count nega edge of i_SPI_CS_B on clk
	
	//// register/end-point interface //{
	//
	// 16 bit data frame process:
	//   read in condition   ... 4n address reading moment
	//   write out condition ... 4n+2 address writing moment
	//   4n+1, 4n+3 addressing --> ignored.
	//
	output wire [31:0] o_port_wi_sadrs_h000, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h004, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h008, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h00C, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h010, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h014, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h018, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h020, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h024, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h048, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h04C, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h050, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h054, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h058, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h060, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h064, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h068, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h06C, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h070, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h074, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h078, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h07C, // [31:0]
	output wire [31:0] o_port_wi_sadrs_h01C, // [31:0] // ADC
	output wire [31:0] o_port_wi_sadrs_h040, // [31:0] // ADC
	//
	input  wire [31:0] i_port_wo_sadrs_h080, // [31:0] // adrs h083~h080
	input  wire [31:0] i_port_wo_sadrs_h084, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h088, // [31:0] // adrs h08B~h088
	input  wire [31:0] i_port_wo_sadrs_h08C, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h090, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h094, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h098, // [31:0] // 
	
	input  wire [31:0] i_port_wo_sadrs_h380, // [31:0] // adrs h383~h380
	input  wire [31:0] i_port_wo_sadrs_h384, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h388, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h38C, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h390, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h394, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h398, // [31:0] //
	input  wire [31:0] i_port_wo_sadrs_h39C, // [31:0] //
	
	input  wire [31:0] i_port_wo_sadrs_h0E0, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0E4, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0E8, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0EC, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0F0, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0F4, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0F8, // [31:0] // 
	input  wire [31:0] i_port_wo_sadrs_h0FC, // [31:0] // 
	
	input  wire [31:0] i_port_wo_sadrs_h09C, // [31:0] // ADC flag
	
	input  wire [31:0] i_port_wo_sadrs_h0A0, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0A4, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0A8, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0AC, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0B0, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0B4, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0B8, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0BC, // [31:0] // ADC ACC
	input  wire [31:0] i_port_wo_sadrs_h0C0, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0C4, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0C8, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0CC, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0D0, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0D4, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0D8, // [31:0] // ADC
	input  wire [31:0] i_port_wo_sadrs_h0DC, // [31:0] // ADC

	//
	input  wire i_ck__sadrs_h104,  output wire [31:0] o_port_ti_sadrs_h104, // [31:0]
	input  wire i_ck__sadrs_h110,  output wire [31:0] o_port_ti_sadrs_h110, // [31:0]
	input  wire i_ck__sadrs_h114,  output wire [31:0] o_port_ti_sadrs_h114, // [31:0]
	input  wire i_ck__sadrs_h118,  output wire [31:0] o_port_ti_sadrs_h118, // [31:0]
	input  wire i_ck__sadrs_h11C,  output wire [31:0] o_port_ti_sadrs_h11C, // [31:0] // ADC
	input  wire i_ck__sadrs_h120,  output wire [31:0] o_port_ti_sadrs_h120, // [31:0]
	input  wire i_ck__sadrs_h124,  output wire [31:0] o_port_ti_sadrs_h124, // [31:0]
	input  wire i_ck__sadrs_h14C,  output wire [31:0] o_port_ti_sadrs_h14C, // [31:0] // MEM_TI	0x14C	ti53 // sys_clk //$$
	//
	input  wire i_ck__sadrs_h190,  input  wire [31:0] i_port_to_sadrs_h190, // [31:0] // ADC
	input  wire i_ck__sadrs_h194,  input  wire [31:0] i_port_to_sadrs_h194, // [31:0]
	input  wire i_ck__sadrs_h198,  input  wire [31:0] i_port_to_sadrs_h198, // [31:0]
	input  wire i_ck__sadrs_h19C,  input  wire [31:0] i_port_to_sadrs_h19C, // [31:0] // ADC
	input  wire i_ck__sadrs_h1CC,  input  wire [31:0] i_port_to_sadrs_h1CC, // [31:0] // ADC

	//
	output wire o_wr__sadrs_h218,  output wire [31:0] o_port_pi_sadrs_h218, // [31:0]
	output wire o_wr__sadrs_h21C,  output wire [31:0] o_port_pi_sadrs_h21C, // [31:0]
	output wire o_wr__sadrs_h220,  output wire [31:0] o_port_pi_sadrs_h220, // [31:0]
	output wire o_wr__sadrs_h224,  output wire [31:0] o_port_pi_sadrs_h224, // [31:0]
	output wire o_wr__sadrs_h24C,  output wire [31:0] o_port_pi_sadrs_h24C, // [31:0]  // MEM_PI	0x24C	pi93 //$$
	
	//
	output wire o_rd__sadrs_h280,  input  wire [31:0] i_port_po_sadrs_h280, // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	output wire o_rd__sadrs_h284,  input  wire [31:0] i_port_po_sadrs_h284, // [31:0]  // ADC_S2_CH1_PO	0x284	poA1
	output wire o_rd__sadrs_h288,  input  wire [31:0] i_port_po_sadrs_h288, // [31:0]  // ADC_S3_CH1_PO	0x288	poA2
	output wire o_rd__sadrs_h28C,  input  wire [31:0] i_port_po_sadrs_h28C, // [31:0]  // ADC_S4_CH1_PO	0x28C	poA3
	output wire o_rd__sadrs_h290,  input  wire [31:0] i_port_po_sadrs_h290, // [31:0]  // ADC_S5_CH1_PO	0x290	poA4
	output wire o_rd__sadrs_h294,  input  wire [31:0] i_port_po_sadrs_h294, // [31:0]  // ADC_S6_CH1_PO	0x294	poA5
	output wire o_rd__sadrs_h298,  input  wire [31:0] i_port_po_sadrs_h298, // [31:0]  // ADC_S7_CH1_PO	0x298	poA6
	output wire o_rd__sadrs_h29C,  input  wire [31:0] i_port_po_sadrs_h29C, // [31:0]  // ADC_S8_CH1_PO	0x29C	poA7
	output wire o_rd__sadrs_h2A0,  input  wire [31:0] i_port_po_sadrs_h2A0, // [31:0]  // ADC_S1_CH2_PO	0x2A0	poA8
	output wire o_rd__sadrs_h2A4,  input  wire [31:0] i_port_po_sadrs_h2A4, // [31:0]  // ADC_S2_CH2_PO	0x2A4	poA9
	output wire o_rd__sadrs_h2A8,  input  wire [31:0] i_port_po_sadrs_h2A8, // [31:0]  // ADC_S3_CH2_PO	0x2A8	poAA
	output wire o_rd__sadrs_h2AC,  input  wire [31:0] i_port_po_sadrs_h2AC, // [31:0]  // ADC_S4_CH2_PO	0x2AC	poAB
	output wire o_rd__sadrs_h2B0,  input  wire [31:0] i_port_po_sadrs_h2B0, // [31:0]  // ADC_S5_CH2_PO	0x2B0	poAC
	output wire o_rd__sadrs_h2B4,  input  wire [31:0] i_port_po_sadrs_h2B4, // [31:0]  // ADC_S6_CH2_PO	0x2B4	poAD
	output wire o_rd__sadrs_h2B8,  input  wire [31:0] i_port_po_sadrs_h2B8, // [31:0]  // ADC_S7_CH2_PO	0x2B8	poAE
	output wire o_rd__sadrs_h2BC,  input  wire [31:0] i_port_po_sadrs_h2BC, // [31:0]  // ADC_S8_CH2_PO	0x2BC	poAF
	output wire o_rd__sadrs_h2CC,  input  wire [31:0] i_port_po_sadrs_h2CC, // [31:0]  // MEM_PO	0x2CC	poB3 //$$
	
	//}
	
	//// loopback mode control 
	input  wire i_loopback_en  ,
	
	//// timing control 
	input  wire  [2:0] i_slack_count_MISO, // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	input  wire i_MISO_one_bit_ahead_en, // '1' for MISO one bit ahead mode.
	
	//// miso return contents
	input wire [3:0] i_board_id, // slot ID
	input wire [7:0] i_board_status, // board status
	
	output wire valid
);

// valid //{
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

//// monitor counters //{
(* keep = "true" *) reg [15:0] r_cnt_sspi_cs; // count nega edge of i_SPI_CS_B on clk
reg [1:0] r_smp_sspi_cs;
//wire w_rise_sspi_cs = (~r_smp_sspi_cs[1]) & ( r_smp_sspi_cs[0]) ;
wire w_fall_sspi_cs = ( r_smp_sspi_cs[1]) & (~r_smp_sspi_cs[0]) ;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_smp_sspi_cs <=  2'b0;
		r_cnt_sspi_cs <= 16'b0;
	end
	else begin
		r_smp_sspi_cs <=  {r_smp_sspi_cs[0], i_SPI_CS_B};
		//
		if (w_fall_sspi_cs)
			r_cnt_sspi_cs <= r_cnt_sspi_cs + 1;
		else 
			r_cnt_sspi_cs <= r_cnt_sspi_cs;
	end

//
assign o_cnt_sspi_cs = r_cnt_sspi_cs;
//}

//// wires for spi pins //{
wire w_SPI_CS_B    = i_SPI_CS_B ;
wire w_SPI_CLK     = i_SPI_CLK  ;
wire w_SPI_MOSI    = i_SPI_MOSI ;
//
wire w_SPI_MISO    ;
wire w_SPI_MISO_EN ; 
//
wire w_SPI_MISO____loopback ;
wire w_SPI_MISO_EN_loopback ;


// output assignment
assign o_SPI_MISO    = (i_loopback_en)? w_SPI_MISO____loopback : w_SPI_MISO    ;
assign o_SPI_MISO_EN = (i_loopback_en)? w_SPI_MISO_EN_loopback : w_SPI_MISO_EN ;

//}

//// loopback MISO <-- MOSI //{
// loobback conditions
assign w_SPI_MISO____loopback =  w_SPI_MOSI;
assign w_SPI_MISO_EN_loopback = (w_SPI_CS_B == 1'b0)? 1'b1 : 1'b0 ;
//}

//// register address access //{
// SW_BUILD_ID_WI	0x000
// SSPI_CON_WI		0x008
//
// FPGA_IMAGE_ID_WO	0x080
// SSPI_FLAG_WO		0x088
// SSPI_TEST_OUT	0x380

// internal registers 
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h000;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h004;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h008;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h00C;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h010;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h014;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h018;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h020;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h024;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h048;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h04C;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h050;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h054;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h058;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h060;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h064;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h068;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h06C;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h070;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h074;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h078;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h07C;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h01C;
(* keep = "true" *) reg [31:0] r_port_wi_sadrs_h040;
//
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h104; 
reg [31:0] r_port_ti_sadrs_h104_ck; reg [31:0] r_port_ti_sadrs_h104_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h110; 
reg [31:0] r_port_ti_sadrs_h110_ck; reg [31:0] r_port_ti_sadrs_h110_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h114; 
reg [31:0] r_port_ti_sadrs_h114_ck; reg [31:0] r_port_ti_sadrs_h114_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h118; 
reg [31:0] r_port_ti_sadrs_h118_ck; reg [31:0] r_port_ti_sadrs_h118_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h11C; 
reg [31:0] r_port_ti_sadrs_h11C_ck; reg [31:0] r_port_ti_sadrs_h11C_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h120; 
reg [31:0] r_port_ti_sadrs_h120_ck; reg [31:0] r_port_ti_sadrs_h120_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h124; 
reg [31:0] r_port_ti_sadrs_h124_ck; reg [31:0] r_port_ti_sadrs_h124_ck_smp;
(* keep = "true" *) reg [31:0] r_port_ti_sadrs_h14C; 
reg [31:0] r_port_ti_sadrs_h14C_ck; reg [31:0] r_port_ti_sadrs_h14C_ck_smp;
//
(* keep = "true" *) reg [31:0] r_port_to_sadrs_h190;
reg [31:0] r_port_to_sadrs_h190_ck;
reg [31:0] r_port_to_sadrs_h190_mon; reg [31:0] r_port_to_sadrs_h190_mon_smp;
(* keep = "true" *) reg [31:0] r_port_to_sadrs_h194;
reg [31:0] r_port_to_sadrs_h194_ck;
reg [31:0] r_port_to_sadrs_h194_mon; reg [31:0] r_port_to_sadrs_h194_mon_smp;
(* keep = "true" *) reg [31:0] r_port_to_sadrs_h198;
reg [31:0] r_port_to_sadrs_h198_ck;
reg [31:0] r_port_to_sadrs_h198_mon; reg [31:0] r_port_to_sadrs_h198_mon_smp;
(* keep = "true" *) reg [31:0] r_port_to_sadrs_h19C;
reg [31:0] r_port_to_sadrs_h19C_ck;
reg [31:0] r_port_to_sadrs_h19C_mon; reg [31:0] r_port_to_sadrs_h19C_mon_smp;
(* keep = "true" *) reg [31:0] r_port_to_sadrs_h1CC;
reg [31:0] r_port_to_sadrs_h1CC_ck;
reg [31:0] r_port_to_sadrs_h1CC_mon; reg [31:0] r_port_to_sadrs_h1CC_mon_smp;
//
(* keep = "true" *) reg [31:0] r_port_pi_sadrs_h218;
(* keep = "true" *) reg [31:0] r_port_pi_sadrs_h21C;
(* keep = "true" *) reg [31:0] r_port_pi_sadrs_h220;
(* keep = "true" *) reg [31:0] r_port_pi_sadrs_h224;
(* keep = "true" *) reg [31:0] r_port_pi_sadrs_h24C;



//// port output assignment 
// wire
assign o_port_wi_sadrs_h000 = r_port_wi_sadrs_h000;
assign o_port_wi_sadrs_h004 = r_port_wi_sadrs_h004;
assign o_port_wi_sadrs_h008 = r_port_wi_sadrs_h008;
assign o_port_wi_sadrs_h00C = r_port_wi_sadrs_h00C;
assign o_port_wi_sadrs_h010 = r_port_wi_sadrs_h010;
assign o_port_wi_sadrs_h014 = r_port_wi_sadrs_h014;
assign o_port_wi_sadrs_h018 = r_port_wi_sadrs_h018;
assign o_port_wi_sadrs_h020 = r_port_wi_sadrs_h020;
assign o_port_wi_sadrs_h024 = r_port_wi_sadrs_h024;
assign o_port_wi_sadrs_h048 = r_port_wi_sadrs_h048;
assign o_port_wi_sadrs_h04C = r_port_wi_sadrs_h04C;
assign o_port_wi_sadrs_h050 = r_port_wi_sadrs_h050;
assign o_port_wi_sadrs_h054 = r_port_wi_sadrs_h054;
assign o_port_wi_sadrs_h058 = r_port_wi_sadrs_h058;
assign o_port_wi_sadrs_h060 = r_port_wi_sadrs_h060;
assign o_port_wi_sadrs_h064 = r_port_wi_sadrs_h064;
assign o_port_wi_sadrs_h068 = r_port_wi_sadrs_h068;
assign o_port_wi_sadrs_h06C = r_port_wi_sadrs_h06C;
assign o_port_wi_sadrs_h070 = r_port_wi_sadrs_h070;
assign o_port_wi_sadrs_h074 = r_port_wi_sadrs_h074;
assign o_port_wi_sadrs_h078 = r_port_wi_sadrs_h078;
assign o_port_wi_sadrs_h07C = r_port_wi_sadrs_h07C;
assign o_port_wi_sadrs_h01C = r_port_wi_sadrs_h01C;
assign o_port_wi_sadrs_h040 = r_port_wi_sadrs_h040;
// pipe
assign o_port_pi_sadrs_h218 = r_port_pi_sadrs_h218;
assign o_port_pi_sadrs_h21C = r_port_pi_sadrs_h21C;
assign o_port_pi_sadrs_h220 = r_port_pi_sadrs_h220;
assign o_port_pi_sadrs_h224 = r_port_pi_sadrs_h224;
assign o_port_pi_sadrs_h24C = r_port_pi_sadrs_h24C;


// frame detection
reg r_frame_busy;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_busy  <= 1'b0;
	end
	else begin
		r_frame_busy  <= (w_SPI_CS_B == 1'b0)? 1'b1 :  1'b0;
	end	

// sclk edge detection 
reg [9:0] r_SPI_CLK;
wire w_rise__sclk = (~r_SPI_CLK[1]) & ( r_SPI_CLK[0]);
wire w_fall__sclk = ( r_SPI_CLK[1]) & (~r_SPI_CLK[0]);
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_SPI_CLK  <= 10'b0;
	end
	else begin
		r_SPI_CLK  <= (r_frame_busy)? {r_SPI_CLK[8:0], w_SPI_CLK} :  10'b0;
	end	

// frame shift samling // frame index count
reg [31:0] r_frame_MOSI;
(* keep = "true" *) reg [5:0] r_frame_index;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_MOSI  <= 32'b0;
		r_frame_index <=  6'b0;
	end
	else begin
		if (r_frame_busy) begin 
			r_frame_MOSI  <= (w_rise__sclk)? {r_frame_MOSI[30:0], w_SPI_MOSI} :  r_frame_MOSI;
			r_frame_index <= (w_rise__sclk)? r_frame_index + 1 : r_frame_index;
			end
		else begin
			r_frame_MOSI  <= r_frame_MOSI ; // stay
			r_frame_index <= 6'b0;
			end
	end	

// frame control detection // write or read, short or long
(* keep = "true" *) reg [5:0] r_frame_ctrl;
(* keep = "true" *) wire w_frame_ctrl_read = r_frame_ctrl[4];
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_ctrl  <= 6'b0;
	end
	else begin
		if (r_frame_busy) begin 
			r_frame_ctrl  <= (w_fall__sclk & (r_frame_index==6'd6) )? 
			                 r_frame_MOSI[5:0] : r_frame_ctrl;
			end
		else begin
			r_frame_ctrl  <= r_frame_ctrl ; // stay
			end
	end	

// frame address detection 
(* keep = "true" *) reg [9:0] r_frame_adrs;
(* keep = "true" *) reg r_frame_adrs_valid;
wire w_phase__adrs_trig = (r_SPI_CLK[2:0]==3'b011)? 1'b1 : 1'b0; // rise edge + 1  : r_SPI_CLK[2:0]==3'b011
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_adrs       <= 10'b0;
		r_frame_adrs_valid <=  1'b0;
	end
	else begin
		if (r_frame_busy) begin 
			if (~i_MISO_one_bit_ahead_en) begin
				r_frame_adrs        <= (w_phase__adrs_trig & (r_frame_index==6'd16) )? 
										r_frame_MOSI[9:0] : r_frame_adrs;
				r_frame_adrs_valid  <= (w_phase__adrs_trig & (r_frame_index==6'd16) )? 
										1'b1 : r_frame_adrs_valid;
				end
			else begin
				r_frame_adrs        <= (w_phase__adrs_trig & (r_frame_index==6'd15) )? 
										{r_frame_MOSI[8:0], 1'b0}  : r_frame_adrs;
				r_frame_adrs_valid  <= (w_phase__adrs_trig & (r_frame_index==6'd15) )? 
										1'b1 : r_frame_adrs_valid;
				end
			end
		else begin
			r_frame_adrs       <= r_frame_adrs ; // stay
			r_frame_adrs_valid <=  1'b0;
			end
	end	

// frame MOSI data detection 
(* keep = "true" *) reg [15:0] r_frame_mosi;
(* keep = "true" *) reg r_frame_mosi_valid;
(* keep = "true" *) reg r_frame_mosi_trig; // trig @ (~w_frame_ctrl_read & rise of r_frame_mosi_valid)
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_mosi        <= 16'b0;
		r_frame_mosi_valid  <=  1'b0;
		r_frame_mosi_trig   <=  1'b0;
	end
	else begin
		if (r_frame_busy & ~w_frame_ctrl_read) begin 
			r_frame_mosi        <= (w_fall__sclk & (r_frame_index==6'd32) )? 
			                        r_frame_MOSI[15:0] : r_frame_mosi;
			r_frame_mosi_valid  <= (w_fall__sclk & (r_frame_index==6'd32) )? 
			                        1'b1 : r_frame_mosi_valid;
			r_frame_mosi_trig   <= (w_fall__sclk & (r_frame_index==6'd32) )? 
			                        1'b1 : 1'b0;
			end
		else begin
			r_frame_mosi        <= r_frame_mosi ; // stay
			r_frame_mosi_valid  <=  1'b0;
			r_frame_mosi_trig   <=  1'b0;
			end
	end	

// frame MISO data selection
(* keep = "true" *) reg [15:0] r_frame_miso;
(* keep = "true" *) reg r_frame_miso_trig; // trig @ (w_frame_ctrl_read & rise of r_frame_adrs_valid)
(* keep = "true" *) wire w_frame_miso_trig;
(* keep = "true" *) wire w_frame_miso_trig_pre;
//  miso trig phase ... 
wire w_phase__miso_trig =
                           (i_slack_count_MISO == 3'h0)? (r_SPI_CLK[1:0]== 2'b10        ) :  // fall edge     
                           (i_slack_count_MISO == 3'h1)? (r_SPI_CLK[3:0]== 4'b0111      ) :  // rise edge + 2 
                           (i_slack_count_MISO == 3'h2)? (r_SPI_CLK[4:0]== 5'b01111     ) :  // rise edge + 3 
                           (i_slack_count_MISO == 3'h3)? (r_SPI_CLK[5:0]== 6'b011111    ) :  // rise edge + 4 
                           (i_slack_count_MISO == 3'h4)? (r_SPI_CLK[6:0]== 7'b0111111   ) :  // rise edge + 5
                           (i_slack_count_MISO == 3'h5)? (r_SPI_CLK[7:0]== 8'b01111111  ) :  // rise edge + 6
                           (i_slack_count_MISO == 3'h6)? (r_SPI_CLK[8:0]== 9'b011111111 ) :  // rise edge + 7
                           (i_slack_count_MISO == 3'h7)? (r_SPI_CLK[9:0]==10'b0111111111) :  // rise edge + 8
                           1'b0;
//
assign w_frame_miso_trig = (~i_MISO_one_bit_ahead_en)? 
							((w_phase__miso_trig & (r_frame_index==6'd16) )? 1'b1 : 1'b0) :
							((w_phase__miso_trig & (r_frame_index==6'd15) )? 1'b1 : 1'b0) ;
//
assign w_frame_miso_trig_pre = (~i_MISO_one_bit_ahead_en)? 
							((w_phase__miso_trig & (r_frame_index==6'd2) )? 1'b1 : 1'b0) :
							((w_phase__miso_trig & (r_frame_index==6'd1) )? 1'b1 : 1'b0) ;
// r_frame_miso_trig
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_miso_trig <=  1'b0;
	end
	else begin
		if (r_frame_busy & w_frame_ctrl_read) begin 
			r_frame_miso_trig  <=  w_frame_miso_trig; // one shot
			end
		else begin
			r_frame_miso_trig <=  1'b0;
			end
	end	
//

wire [9:0] w_frame_adrs_sel_32b; // ignore bit[1:0]
//
assign w_frame_adrs_sel_32b[9:2] = r_frame_adrs[9:2];
assign w_frame_adrs_sel_32b[1:0] = 2'b0;
//
wire [31:0] w_frame_miso_b32; // from ports 32-bit wide
//
assign w_frame_miso_b32 =  //{
                      (w_frame_adrs_sel_32b == 10'h000)?  r_port_wi_sadrs_h000 : 
                      (w_frame_adrs_sel_32b == 10'h004)?  r_port_wi_sadrs_h004 : 
                      (w_frame_adrs_sel_32b == 10'h008)?  r_port_wi_sadrs_h008 : 
                      (w_frame_adrs_sel_32b == 10'h00C)?  r_port_wi_sadrs_h00C : 
                      (w_frame_adrs_sel_32b == 10'h020)?  r_port_wi_sadrs_h020 : 
                      (w_frame_adrs_sel_32b == 10'h024)?  r_port_wi_sadrs_h024 : 
                      (w_frame_adrs_sel_32b == 10'h010)?  r_port_wi_sadrs_h010 : 
                      (w_frame_adrs_sel_32b == 10'h014)?  r_port_wi_sadrs_h014 : 
                      (w_frame_adrs_sel_32b == 10'h018)?  r_port_wi_sadrs_h018 : 
                      (w_frame_adrs_sel_32b == 10'h048)?  r_port_wi_sadrs_h048 :
                      (w_frame_adrs_sel_32b == 10'h04C)?  r_port_wi_sadrs_h04C :
                      (w_frame_adrs_sel_32b == 10'h050)?  r_port_wi_sadrs_h050 :
                      (w_frame_adrs_sel_32b == 10'h054)?  r_port_wi_sadrs_h054 :
                      (w_frame_adrs_sel_32b == 10'h058)?  r_port_wi_sadrs_h058 :
                      (w_frame_adrs_sel_32b == 10'h060)?  r_port_wi_sadrs_h060 :
                      (w_frame_adrs_sel_32b == 10'h064)?  r_port_wi_sadrs_h064 :
                      (w_frame_adrs_sel_32b == 10'h068)?  r_port_wi_sadrs_h068 :
                      (w_frame_adrs_sel_32b == 10'h06C)?  r_port_wi_sadrs_h06C :
                      (w_frame_adrs_sel_32b == 10'h070)?  r_port_wi_sadrs_h070 :
                      (w_frame_adrs_sel_32b == 10'h074)?  r_port_wi_sadrs_h074 :
                      (w_frame_adrs_sel_32b == 10'h078)?  r_port_wi_sadrs_h078 :
                      (w_frame_adrs_sel_32b == 10'h07C)?  r_port_wi_sadrs_h07C :
                      (w_frame_adrs_sel_32b == 10'h01C)?  r_port_wi_sadrs_h01C :
                      (w_frame_adrs_sel_32b == 10'h040)?  r_port_wi_sadrs_h040 :
                      //
                      (w_frame_adrs_sel_32b == 10'h080)?  i_port_wo_sadrs_h080 :
                      (w_frame_adrs_sel_32b == 10'h084)?  i_port_wo_sadrs_h084 :
                      (w_frame_adrs_sel_32b == 10'h088)?  i_port_wo_sadrs_h088 :
                      (w_frame_adrs_sel_32b == 10'h08C)?  i_port_wo_sadrs_h08C :
                      (w_frame_adrs_sel_32b == 10'h090)?  i_port_wo_sadrs_h090 :
                      (w_frame_adrs_sel_32b == 10'h094)?  i_port_wo_sadrs_h094 :
                      (w_frame_adrs_sel_32b == 10'h098)?  i_port_wo_sadrs_h098 :
                      (w_frame_adrs_sel_32b == 10'h0E0)?  i_port_wo_sadrs_h0E0 :
                      (w_frame_adrs_sel_32b == 10'h0E4)?  i_port_wo_sadrs_h0E4 :
                      (w_frame_adrs_sel_32b == 10'h0E8)?  i_port_wo_sadrs_h0E8 :
                      (w_frame_adrs_sel_32b == 10'h0EC)?  i_port_wo_sadrs_h0EC :
                      (w_frame_adrs_sel_32b == 10'h0F0)?  i_port_wo_sadrs_h0F0 :
                      (w_frame_adrs_sel_32b == 10'h0F4)?  i_port_wo_sadrs_h0F4 :
                      (w_frame_adrs_sel_32b == 10'h0F8)?  i_port_wo_sadrs_h0F8 :
                      (w_frame_adrs_sel_32b == 10'h0FC)?  i_port_wo_sadrs_h0FC :
                      (w_frame_adrs_sel_32b == 10'h09C)?  i_port_wo_sadrs_h09C :
                      (w_frame_adrs_sel_32b == 10'h0A0)?  i_port_wo_sadrs_h0A0 :
                      (w_frame_adrs_sel_32b == 10'h0A4)?  i_port_wo_sadrs_h0A4 :
                      (w_frame_adrs_sel_32b == 10'h0A8)?  i_port_wo_sadrs_h0A8 :
                      (w_frame_adrs_sel_32b == 10'h0AC)?  i_port_wo_sadrs_h0AC :
                      (w_frame_adrs_sel_32b == 10'h0B0)?  i_port_wo_sadrs_h0B0 :
                      (w_frame_adrs_sel_32b == 10'h0B4)?  i_port_wo_sadrs_h0B4 :
                      (w_frame_adrs_sel_32b == 10'h0B8)?  i_port_wo_sadrs_h0B8 :
                      (w_frame_adrs_sel_32b == 10'h0BC)?  i_port_wo_sadrs_h0BC :
                      (w_frame_adrs_sel_32b == 10'h0C0)?  i_port_wo_sadrs_h0C0 :
                      (w_frame_adrs_sel_32b == 10'h0C4)?  i_port_wo_sadrs_h0C4 :
                      (w_frame_adrs_sel_32b == 10'h0C8)?  i_port_wo_sadrs_h0C8 :
                      (w_frame_adrs_sel_32b == 10'h0CC)?  i_port_wo_sadrs_h0CC :
                      (w_frame_adrs_sel_32b == 10'h0D0)?  i_port_wo_sadrs_h0D0 :
                      (w_frame_adrs_sel_32b == 10'h0D4)?  i_port_wo_sadrs_h0D4 :
                      (w_frame_adrs_sel_32b == 10'h0D8)?  i_port_wo_sadrs_h0D8 :
                      (w_frame_adrs_sel_32b == 10'h0DC)?  i_port_wo_sadrs_h0DC :
                      //
                      (w_frame_adrs_sel_32b == 10'h104)?  r_port_ti_sadrs_h104 :
                      (w_frame_adrs_sel_32b == 10'h110)?  r_port_ti_sadrs_h110 :
                      (w_frame_adrs_sel_32b == 10'h114)?  r_port_ti_sadrs_h114 :
                      (w_frame_adrs_sel_32b == 10'h118)?  r_port_ti_sadrs_h118 :
                      (w_frame_adrs_sel_32b == 10'h11C)?  r_port_ti_sadrs_h11C :
                      (w_frame_adrs_sel_32b == 10'h120)?  r_port_ti_sadrs_h120 :
                      (w_frame_adrs_sel_32b == 10'h124)?  r_port_ti_sadrs_h124 :
                      (w_frame_adrs_sel_32b == 10'h14C)?  r_port_ti_sadrs_h14C :
                      //
                      (w_frame_adrs_sel_32b == 10'h190)?  r_port_to_sadrs_h190 :
                      (w_frame_adrs_sel_32b == 10'h194)?  r_port_to_sadrs_h194 :
                      (w_frame_adrs_sel_32b == 10'h198)?  r_port_to_sadrs_h198 :
                      (w_frame_adrs_sel_32b == 10'h19C)?  r_port_to_sadrs_h19C :
                      (w_frame_adrs_sel_32b == 10'h1CC)?  r_port_to_sadrs_h1CC :
                      //
                      (w_frame_adrs_sel_32b == 10'h218)?  r_port_pi_sadrs_h218 :
                      (w_frame_adrs_sel_32b == 10'h21C)?  r_port_pi_sadrs_h21C :
                      (w_frame_adrs_sel_32b == 10'h220)?  r_port_pi_sadrs_h220 :
                      (w_frame_adrs_sel_32b == 10'h224)?  r_port_pi_sadrs_h224 :
                      (w_frame_adrs_sel_32b == 10'h24C)?  r_port_pi_sadrs_h24C :
                      //
                      (w_frame_adrs_sel_32b == 10'h280)?  i_port_po_sadrs_h280 :
                      (w_frame_adrs_sel_32b == 10'h284)?  i_port_po_sadrs_h284 :
                      (w_frame_adrs_sel_32b == 10'h288)?  i_port_po_sadrs_h288 :
                      (w_frame_adrs_sel_32b == 10'h28C)?  i_port_po_sadrs_h28C :
                      (w_frame_adrs_sel_32b == 10'h290)?  i_port_po_sadrs_h290 :
                      (w_frame_adrs_sel_32b == 10'h294)?  i_port_po_sadrs_h294 :
                      (w_frame_adrs_sel_32b == 10'h298)?  i_port_po_sadrs_h298 :
                      (w_frame_adrs_sel_32b == 10'h29C)?  i_port_po_sadrs_h29C :
                      (w_frame_adrs_sel_32b == 10'h2A0)?  i_port_po_sadrs_h2A0 :
                      (w_frame_adrs_sel_32b == 10'h2A4)?  i_port_po_sadrs_h2A4 :
                      (w_frame_adrs_sel_32b == 10'h2A8)?  i_port_po_sadrs_h2A8 :
                      (w_frame_adrs_sel_32b == 10'h2AC)?  i_port_po_sadrs_h2AC :
                      (w_frame_adrs_sel_32b == 10'h2B0)?  i_port_po_sadrs_h2B0 :
                      (w_frame_adrs_sel_32b == 10'h2B4)?  i_port_po_sadrs_h2B4 :
                      (w_frame_adrs_sel_32b == 10'h2B8)?  i_port_po_sadrs_h2B8 :
                      (w_frame_adrs_sel_32b == 10'h2BC)?  i_port_po_sadrs_h2BC :
                      (w_frame_adrs_sel_32b == 10'h2CC)?  i_port_po_sadrs_h2CC :
                      //
                      (w_frame_adrs_sel_32b == 10'h380)?  i_port_wo_sadrs_h380 :
                      (w_frame_adrs_sel_32b == 10'h384)?  i_port_wo_sadrs_h384 :
                      (w_frame_adrs_sel_32b == 10'h388)?  i_port_wo_sadrs_h388 :
                      (w_frame_adrs_sel_32b == 10'h38C)?  i_port_wo_sadrs_h38C :
                      (w_frame_adrs_sel_32b == 10'h390)?  i_port_wo_sadrs_h390 :
                      (w_frame_adrs_sel_32b == 10'h394)?  i_port_wo_sadrs_h394 :
                      (w_frame_adrs_sel_32b == 10'h398)?  i_port_wo_sadrs_h398 :
                      (w_frame_adrs_sel_32b == 10'h39C)?  i_port_wo_sadrs_h39C :
                      32'b0;
//}

wire [15:0] w_frame_miso; // from ports
// 
assign w_frame_miso = (r_frame_adrs[1])? w_frame_miso_b32[31:16] :
                                         w_frame_miso_b32[15: 0] ;
//

// r_frame_miso
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_frame_miso <= 16'b0;
	end
	else begin
		if (w_frame_miso_trig) begin // one clock earlier than r_frame_miso_trig
			r_frame_miso  <= w_frame_miso;
			end
		else if (w_frame_miso_trig_pre) begin // load board id / status
			r_frame_miso  <= {i_board_id,i_board_status, 4'b0};
			end
		else if (w_phase__miso_trig) begin // shift control here...
			r_frame_miso  <= {r_frame_miso[14:0], 1'b0};
			end
		else begin
			r_frame_miso <=  r_frame_miso;
			end
	end	

// MISO output assignment 
assign w_SPI_MISO    = r_frame_miso[15];
assign w_SPI_MISO_EN = (w_SPI_CS_B == 1'b0)? 1'b1 : 1'b0 ;


// load MOSI data on a proper "internal register"
// r_port_wi_sadrs_h000
// r_port_wi_sadrs_h004
// r_port_wi_sadrs_h008
// r_port_wi_sadrs_h00C
// r_port_wi_sadrs_h010
// r_port_wi_sadrs_h014
// r_port_wi_sadrs_h018
// r_port_wi_sadrs_h060
// r_port_wi_sadrs_h064
// r_port_wi_sadrs_h068
// r_port_wi_sadrs_h06C
// r_port_wi_sadrs_h070
// r_port_wi_sadrs_h074
// r_port_wi_sadrs_h078
// r_port_wi_sadrs_h07C
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		// wire in 
		r_port_wi_sadrs_h000 <= 32'b0;
		r_port_wi_sadrs_h004 <= 32'b0;
		r_port_wi_sadrs_h008 <= 32'b0;
		r_port_wi_sadrs_h00C <= 32'b0;
		r_port_wi_sadrs_h020 <= 32'b0;
		r_port_wi_sadrs_h024 <= 32'b0;
		r_port_wi_sadrs_h010 <= 32'b0;
		r_port_wi_sadrs_h014 <= 32'b0;
		r_port_wi_sadrs_h018 <= 32'b0;
		r_port_wi_sadrs_h048 <= 32'b0;
		r_port_wi_sadrs_h04C <= 32'b0;
		r_port_wi_sadrs_h050 <= 32'b0;
		r_port_wi_sadrs_h054 <= 32'b0;
		r_port_wi_sadrs_h058 <= 32'b0;
		r_port_wi_sadrs_h060 <= 32'b0;
		r_port_wi_sadrs_h064 <= 32'b0;
		r_port_wi_sadrs_h068 <= 32'b0;
		r_port_wi_sadrs_h06C <= 32'b0;
		r_port_wi_sadrs_h070 <= 32'b0;
		r_port_wi_sadrs_h074 <= 32'b0;
		r_port_wi_sadrs_h078 <= 32'b0;
		r_port_wi_sadrs_h07C <= 32'b0;
		r_port_wi_sadrs_h01C <= 32'b0;
		r_port_wi_sadrs_h040 <= 32'b0;
		// pipe in 
		r_port_pi_sadrs_h218 <= 32'b0;
		r_port_pi_sadrs_h21C <= 32'b0;
		r_port_pi_sadrs_h220 <= 32'b0;
		r_port_pi_sadrs_h224 <= 32'b0;
		r_port_pi_sadrs_h24C <= 32'b0;
	end
	else begin
		if (r_frame_mosi_trig) begin 
			if      (r_frame_adrs == 10'h000+10'h000)  r_port_wi_sadrs_h000[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h000+10'h002)  r_port_wi_sadrs_h000[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h004+10'h000)  r_port_wi_sadrs_h004[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h004+10'h002)  r_port_wi_sadrs_h004[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h008+10'h000)  r_port_wi_sadrs_h008[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h008+10'h002)  r_port_wi_sadrs_h008[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h00C+10'h000)  r_port_wi_sadrs_h00C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h00C+10'h002)  r_port_wi_sadrs_h00C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h010+10'h000)  r_port_wi_sadrs_h010[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h010+10'h002)  r_port_wi_sadrs_h010[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h014+10'h000)  r_port_wi_sadrs_h014[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h014+10'h002)  r_port_wi_sadrs_h014[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h018+10'h000)  r_port_wi_sadrs_h018[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h018+10'h002)  r_port_wi_sadrs_h018[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h020+10'h000)  r_port_wi_sadrs_h020[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h020+10'h002)  r_port_wi_sadrs_h020[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h024+10'h000)  r_port_wi_sadrs_h024[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h024+10'h002)  r_port_wi_sadrs_h024[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h048+10'h000)  r_port_wi_sadrs_h048[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h048+10'h002)  r_port_wi_sadrs_h048[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h04C+10'h000)  r_port_wi_sadrs_h04C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h04C+10'h002)  r_port_wi_sadrs_h04C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h050+10'h000)  r_port_wi_sadrs_h050[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h050+10'h002)  r_port_wi_sadrs_h050[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h054+10'h000)  r_port_wi_sadrs_h054[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h054+10'h002)  r_port_wi_sadrs_h054[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h058+10'h000)  r_port_wi_sadrs_h058[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h058+10'h002)  r_port_wi_sadrs_h058[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h060+10'h000)  r_port_wi_sadrs_h060[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h060+10'h002)  r_port_wi_sadrs_h060[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h064+10'h000)  r_port_wi_sadrs_h064[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h064+10'h002)  r_port_wi_sadrs_h064[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h068+10'h000)  r_port_wi_sadrs_h068[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h068+10'h002)  r_port_wi_sadrs_h068[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h06C+10'h000)  r_port_wi_sadrs_h06C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h06C+10'h002)  r_port_wi_sadrs_h06C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h070+10'h000)  r_port_wi_sadrs_h070[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h070+10'h002)  r_port_wi_sadrs_h070[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h074+10'h000)  r_port_wi_sadrs_h074[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h074+10'h002)  r_port_wi_sadrs_h074[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h078+10'h000)  r_port_wi_sadrs_h078[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h078+10'h002)  r_port_wi_sadrs_h078[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h07C+10'h000)  r_port_wi_sadrs_h07C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h07C+10'h002)  r_port_wi_sadrs_h07C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h01C+10'h000)  r_port_wi_sadrs_h01C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h01C+10'h002)  r_port_wi_sadrs_h01C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h040+10'h000)  r_port_wi_sadrs_h040[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h040+10'h002)  r_port_wi_sadrs_h040[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h218+10'h000)  r_port_pi_sadrs_h218[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h218+10'h002)  r_port_pi_sadrs_h218[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h21C+10'h000)  r_port_pi_sadrs_h21C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h21C+10'h002)  r_port_pi_sadrs_h21C[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h220+10'h000)  r_port_pi_sadrs_h220[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h220+10'h002)  r_port_pi_sadrs_h220[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h224+10'h000)  r_port_pi_sadrs_h224[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h224+10'h002)  r_port_pi_sadrs_h224[31:16]  <= r_frame_mosi;
			//
			else if (r_frame_adrs == 10'h24C+10'h000)  r_port_pi_sadrs_h24C[15: 0]  <= r_frame_mosi;
			else if (r_frame_adrs == 10'h24C+10'h002)  r_port_pi_sadrs_h24C[31:16]  <= r_frame_mosi;
			//
			end
			
	end	

//// trig in process
// r_port_ti_sadrs_h104
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h104 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h104+10'h000))  r_port_ti_sadrs_h104[15: 0]  <= r_port_ti_sadrs_h104[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h104+10'h002))  r_port_ti_sadrs_h104[31:16]  <= r_port_ti_sadrs_h104[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h104+, r_port_ti_sadrs_h104, r_port_ti_sadrs_h104_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h104 <= (r_port_ti_sadrs_h104) & (~r_port_ti_sadrs_h104_ck);
			end
	end	
// r_port_ti_sadrs_h110
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h110 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h110+10'h000))  r_port_ti_sadrs_h110[15: 0]  <= r_port_ti_sadrs_h110[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h110+10'h002))  r_port_ti_sadrs_h110[31:16]  <= r_port_ti_sadrs_h110[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h110+, r_port_ti_sadrs_h110, r_port_ti_sadrs_h110_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h110 <= (r_port_ti_sadrs_h110) & (~r_port_ti_sadrs_h110_ck);
			end
	end	
// r_port_ti_sadrs_h114
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h114 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h114+10'h000))  r_port_ti_sadrs_h114[15: 0]  <= r_port_ti_sadrs_h114[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h114+10'h002))  r_port_ti_sadrs_h114[31:16]  <= r_port_ti_sadrs_h114[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h114+, r_port_ti_sadrs_h114, r_port_ti_sadrs_h114_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h114 <= (r_port_ti_sadrs_h114) & (~r_port_ti_sadrs_h114_ck);
			end
	end	
// r_port_ti_sadrs_h118
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h118 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h118+10'h000))  r_port_ti_sadrs_h118[15: 0]  <= r_port_ti_sadrs_h118[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h118+10'h002))  r_port_ti_sadrs_h118[31:16]  <= r_port_ti_sadrs_h118[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h118+, r_port_ti_sadrs_h118, r_port_ti_sadrs_h118_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h118 <= (r_port_ti_sadrs_h118) & (~r_port_ti_sadrs_h118_ck);
			end
	end	
// r_port_ti_sadrs_h11C
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h11C <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h11C+10'h000))  r_port_ti_sadrs_h11C[15: 0]  <= r_port_ti_sadrs_h11C[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h11C+10'h002))  r_port_ti_sadrs_h11C[31:16]  <= r_port_ti_sadrs_h11C[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h11C+, r_port_ti_sadrs_h11C, r_port_ti_sadrs_h11C_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h11C <= (r_port_ti_sadrs_h11C) & (~r_port_ti_sadrs_h11C_ck);
			end
	end	
// r_port_ti_sadrs_h120
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h120 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h120+10'h000))  r_port_ti_sadrs_h120[15: 0]  <= r_port_ti_sadrs_h120[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h120+10'h002))  r_port_ti_sadrs_h120[31:16]  <= r_port_ti_sadrs_h120[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h120+, r_port_ti_sadrs_h120, r_port_ti_sadrs_h120_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h120 <= (r_port_ti_sadrs_h120) & (~r_port_ti_sadrs_h120_ck);
			end
	end	
// r_port_ti_sadrs_h124
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h124 <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h124+10'h000))  r_port_ti_sadrs_h124[15: 0]  <= r_port_ti_sadrs_h124[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h124+10'h002))  r_port_ti_sadrs_h124[31:16]  <= r_port_ti_sadrs_h124[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h124+, r_port_ti_sadrs_h124, r_port_ti_sadrs_h124_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h124 <= (r_port_ti_sadrs_h124) & (~r_port_ti_sadrs_h124_ck);
			end
	end	
// r_port_ti_sadrs_h14C
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h14C <= 32'b0;
	end
	else begin
		// set condition 
		if      (r_frame_mosi_trig & (r_frame_adrs == 10'h14C+10'h000))  r_port_ti_sadrs_h14C[15: 0]  <= r_port_ti_sadrs_h14C[15: 0] | r_frame_mosi;
		else if (r_frame_mosi_trig & (r_frame_adrs == 10'h14C+10'h002))  r_port_ti_sadrs_h14C[31:16]  <= r_port_ti_sadrs_h14C[31:16] | r_frame_mosi;
		// clear condition
		//    r_port_ti_sadrs_h14C+, r_port_ti_sadrs_h14C, r_port_ti_sadrs_h14C_ck
		//    0                      0                     0
		//    0                      0                     1
		//    1                      1                     0
		//    0                      1                     1
		else begin
			r_port_ti_sadrs_h14C <= (r_port_ti_sadrs_h14C) & (~r_port_ti_sadrs_h14C_ck);
			end
	end	

//// trig in sample
// r_port_ti_sadrs_h104_ck
always @(posedge i_ck__sadrs_h104, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h104_ck     <= 32'b0;
		r_port_ti_sadrs_h104_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h104_ck     <= r_port_ti_sadrs_h104   ;
		r_port_ti_sadrs_h104_ck_smp <= r_port_ti_sadrs_h104_ck;
		//
	end	
// r_port_ti_sadrs_h110_ck
always @(posedge i_ck__sadrs_h110, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h110_ck     <= 32'b0;
		r_port_ti_sadrs_h110_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h110_ck     <= r_port_ti_sadrs_h110   ;
		r_port_ti_sadrs_h110_ck_smp <= r_port_ti_sadrs_h110_ck;
		//
	end	
// r_port_ti_sadrs_h114_ck
always @(posedge i_ck__sadrs_h114, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h114_ck     <= 32'b0;
		r_port_ti_sadrs_h114_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h114_ck     <= r_port_ti_sadrs_h114   ;
		r_port_ti_sadrs_h114_ck_smp <= r_port_ti_sadrs_h114_ck;
		//
	end	
// r_port_ti_sadrs_h118_ck
always @(posedge i_ck__sadrs_h118, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h118_ck     <= 32'b0;
		r_port_ti_sadrs_h118_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h118_ck     <= r_port_ti_sadrs_h118   ;
		r_port_ti_sadrs_h118_ck_smp <= r_port_ti_sadrs_h118_ck;
		//
	end	
// r_port_ti_sadrs_h11C_ck
always @(posedge i_ck__sadrs_h11C, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h11C_ck     <= 32'b0;
		r_port_ti_sadrs_h11C_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h11C_ck     <= r_port_ti_sadrs_h11C   ;
		r_port_ti_sadrs_h11C_ck_smp <= r_port_ti_sadrs_h11C_ck;
		//
	end	
// r_port_ti_sadrs_h120_ck
always @(posedge i_ck__sadrs_h120, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h120_ck     <= 32'b0;
		r_port_ti_sadrs_h120_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h120_ck     <= r_port_ti_sadrs_h120   ;
		r_port_ti_sadrs_h120_ck_smp <= r_port_ti_sadrs_h120_ck;
		//
	end	
// r_port_ti_sadrs_h124_ck
always @(posedge i_ck__sadrs_h124, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h124_ck     <= 32'b0;
		r_port_ti_sadrs_h124_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h124_ck     <= r_port_ti_sadrs_h124   ;
		r_port_ti_sadrs_h124_ck_smp <= r_port_ti_sadrs_h124_ck;
		//
	end	
// r_port_ti_sadrs_h14C_ck
always @(posedge i_ck__sadrs_h14C, negedge reset_n)
	if (!reset_n) begin
		r_port_ti_sadrs_h14C_ck     <= 32'b0;
		r_port_ti_sadrs_h14C_ck_smp <= 32'b0;
	end
	else begin
		r_port_ti_sadrs_h14C_ck     <= r_port_ti_sadrs_h14C   ;
		r_port_ti_sadrs_h14C_ck_smp <= r_port_ti_sadrs_h14C_ck;
		//
	end	

// one shot output
assign o_port_ti_sadrs_h104 = (~r_port_ti_sadrs_h104_ck_smp) & (r_port_ti_sadrs_h104_ck);
assign o_port_ti_sadrs_h110 = (~r_port_ti_sadrs_h110_ck_smp) & (r_port_ti_sadrs_h110_ck);
assign o_port_ti_sadrs_h114 = (~r_port_ti_sadrs_h114_ck_smp) & (r_port_ti_sadrs_h114_ck);
assign o_port_ti_sadrs_h118 = (~r_port_ti_sadrs_h118_ck_smp) & (r_port_ti_sadrs_h118_ck);
assign o_port_ti_sadrs_h11C = (~r_port_ti_sadrs_h11C_ck_smp) & (r_port_ti_sadrs_h11C_ck);
assign o_port_ti_sadrs_h120 = (~r_port_ti_sadrs_h120_ck_smp) & (r_port_ti_sadrs_h120_ck);
assign o_port_ti_sadrs_h124 = (~r_port_ti_sadrs_h124_ck_smp) & (r_port_ti_sadrs_h124_ck);
assign o_port_ti_sadrs_h14C = (~r_port_ti_sadrs_h14C_ck_smp) & (r_port_ti_sadrs_h14C_ck);
	

// trig out process 
// trig out sample
//
always @(posedge i_ck__sadrs_h190, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h190_ck     <= 32'b0;
	end
	else begin
		// update r_port_to_sadrs_h190_ck
		//    set   by i_port_...
		//    clear by r_port_..._mon
		// r_port_to_sadrs_h190_ck+  r_port_to_sadrs_h190_ck  i_port_to_sadrs_h190  r_port_to_sadrs_h190_mon
		// 0                         0                        0                     0  
		// 0                         0                        0                     1  
		// 1                         0                        1                     0  
		// 1                         0                        1                     1  
		// 1                         1                        0                     0  <<<
		// 0                         1                        0                     1  
		// 1                         1                        1                     0  
		// 1                         1                        1                     1  
		r_port_to_sadrs_h190_ck     <= i_port_to_sadrs_h190                                  | 
									   (r_port_to_sadrs_h190_ck & ~r_port_to_sadrs_h190_mon) ;
	end	
//
always @(posedge i_ck__sadrs_h194, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h194_ck     <= 32'b0;
	end
	else begin
		r_port_to_sadrs_h194_ck     <= i_port_to_sadrs_h194   ;
		// update r_port_to_sadrs_h194_ck
		//    set   by i_port_...
		//    clear by r_port_..._mon
		// r_port_to_sadrs_h194_ck+  r_port_to_sadrs_h194_ck  i_port_to_sadrs_h194  r_port_to_sadrs_h194_mon
		// 0                         0                        0                     0  
		// 0                         0                        0                     1  
		// 1                         0                        1                     0  
		// 1                         0                        1                     1  
		// 1                         1                        0                     0  <<<
		// 0                         1                        0                     1  
		// 1                         1                        1                     0  
		// 1                         1                        1                     1  
		r_port_to_sadrs_h194_ck     <= i_port_to_sadrs_h194                                  | 
									   (r_port_to_sadrs_h194_ck & ~r_port_to_sadrs_h194_mon) ;
	end	
//
always @(posedge i_ck__sadrs_h198, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h198_ck     <= 32'b0;
	end
	else begin
		r_port_to_sadrs_h198_ck     <= i_port_to_sadrs_h198   ;
		// update r_port_to_sadrs_h198_ck
		//    set   by i_port_...
		//    clear by r_port_..._mon
		// r_port_to_sadrs_h198_ck+  r_port_to_sadrs_h198_ck  i_port_to_sadrs_h198  r_port_to_sadrs_h198_mon
		// 0                         0                        0                     0  
		// 0                         0                        0                     1  
		// 1                         0                        1                     0  
		// 1                         0                        1                     1  
		// 1                         1                        0                     0  <<<
		// 0                         1                        0                     1  
		// 1                         1                        1                     0  
		// 1                         1                        1                     1  
		r_port_to_sadrs_h198_ck     <= i_port_to_sadrs_h198                                  | 
									   (r_port_to_sadrs_h198_ck & ~r_port_to_sadrs_h198_mon) ;
	end	
//
always @(posedge i_ck__sadrs_h19C, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h19C_ck     <= 32'b0;
	end
	else begin
		// update r_port_to_sadrs_h19C_ck
		//    set   by i_port_...
		//    clear by r_port_..._mon
		// r_port_to_sadrs_h19C_ck+  r_port_to_sadrs_h19C_ck  i_port_to_sadrs_h19C  r_port_to_sadrs_h19C_mon
		// 0                         0                        0                     0  
		// 0                         0                        0                     1  
		// 1                         0                        1                     0  
		// 1                         0                        1                     1  
		// 1                         1                        0                     0  <<<
		// 0                         1                        0                     1  
		// 1                         1                        1                     0  
		// 1                         1                        1                     1  
		r_port_to_sadrs_h19C_ck     <= i_port_to_sadrs_h19C                                  | 
									   (r_port_to_sadrs_h19C_ck & ~r_port_to_sadrs_h19C_mon) ;
	end	
//
always @(posedge i_ck__sadrs_h1CC, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h1CC_ck     <= 32'b0;
	end
	else begin
		// update r_port_to_sadrs_h1CC_ck
		//    set   by i_port_...
		//    clear by r_port_..._mon
		// r_port_to_sadrs_h1CC_ck+  r_port_to_sadrs_h1CC_ck  i_port_to_sadrs_h1CC  r_port_to_sadrs_h1CC_mon
		// 0                         0                        0                     0  
		// 0                         0                        0                     1  
		// 1                         0                        1                     0  
		// 1                         0                        1                     1  
		// 1                         1                        0                     0  <<<
		// 0                         1                        0                     1  
		// 1                         1                        1                     0  
		// 1                         1                        1                     1  
		r_port_to_sadrs_h1CC_ck     <= i_port_to_sadrs_h1CC                                  | 
									   (r_port_to_sadrs_h1CC_ck & ~r_port_to_sadrs_h1CC_mon) ;
	end	


// detection by rise and clear by read
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz or 104MHz
	if (!reset_n) begin
		r_port_to_sadrs_h190         <= 32'b0;
		r_port_to_sadrs_h190_mon     <= 32'b0;
		r_port_to_sadrs_h190_mon_smp <= 32'b0;
	end
	else begin
		// clear by read 
		if      (r_frame_miso_trig & (r_frame_adrs == 10'h190+10'h000)) begin
			r_port_to_sadrs_h190[15: 0] <= 16'b0;
		end
		else if (r_frame_miso_trig & (r_frame_adrs == 10'h190+10'h002)) begin 
			r_port_to_sadrs_h190[31:16] <= 16'b0;
		end
		// set by rise 
		// r_port_to_sadrs_h190+ , r_port_to_sadrs_h190, r_port_to_sadrs_h190_mon_smp, r_port_to_sadrs_h190_mon
		// 0                       0                     0                             0
		// 1                       0                     0                             1
		// 0                       0                     1                             0
		// 0                       0                     1                             1
		// 1                       1                     0                             0
		// 1                       1                     0                             1
		// 1                       1                     1                             0
		// 1                       1                     1                             1
		else begin
			//
			r_port_to_sadrs_h190 = r_port_to_sadrs_h190 | ( (~r_port_to_sadrs_h190_mon_smp) & (r_port_to_sadrs_h190_mon) );
		end
		//
		r_port_to_sadrs_h190_mon     <= r_port_to_sadrs_h190_ck ; // always
		r_port_to_sadrs_h190_mon_smp <= r_port_to_sadrs_h190_mon; // always
		//
	end
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_port_to_sadrs_h194         <= 32'b0;
		r_port_to_sadrs_h194_mon     <= 32'b0;
		r_port_to_sadrs_h194_mon_smp <= 32'b0;
	end
	else begin
		// clear by read 
		if      (r_frame_miso_trig & (r_frame_adrs == 10'h194+10'h000)) begin
			r_port_to_sadrs_h194[15: 0] <= 16'b0;
		end
		else if (r_frame_miso_trig & (r_frame_adrs == 10'h194+10'h002)) begin 
			r_port_to_sadrs_h194[31:16] <= 16'b0;
		end
		// set by rise 
		// r_port_to_sadrs_h194+ , r_port_to_sadrs_h194, r_port_to_sadrs_h194_mon_smp, r_port_to_sadrs_h194_mon
		// 0                       0                     0                             0
		// 1                       0                     0                             1
		// 0                       0                     1                             0
		// 0                       0                     1                             1
		// 1                       1                     0                             0
		// 1                       1                     0                             1
		// 1                       1                     1                             0
		// 1                       1                     1                             1
		else begin
			//
			r_port_to_sadrs_h194 = r_port_to_sadrs_h194 | ( (~r_port_to_sadrs_h194_mon_smp) & (r_port_to_sadrs_h194_mon) );
		end
		//
		r_port_to_sadrs_h194_mon     <= r_port_to_sadrs_h194_ck ; // always
		r_port_to_sadrs_h194_mon_smp <= r_port_to_sadrs_h194_mon; // always
		//
	end
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz
	if (!reset_n) begin
		r_port_to_sadrs_h198         <= 32'b0;
		r_port_to_sadrs_h198_mon     <= 32'b0;
		r_port_to_sadrs_h198_mon_smp <= 32'b0;
	end
	else begin
		// clear by read 
		if      (r_frame_miso_trig & (r_frame_adrs == 10'h198+10'h000)) begin
			r_port_to_sadrs_h198[15: 0] <= 16'b0;
		end
		else if (r_frame_miso_trig & (r_frame_adrs == 10'h198+10'h002)) begin 
			r_port_to_sadrs_h198[31:16] <= 16'b0;
		end
		// set by rise 
		// r_port_to_sadrs_h198+ , r_port_to_sadrs_h198, r_port_to_sadrs_h198_mon_smp, r_port_to_sadrs_h198_mon
		// 0                       0                     0                             0
		// 1                       0                     0                             1
		// 0                       0                     1                             0
		// 0                       0                     1                             1
		// 1                       1                     0                             0
		// 1                       1                     0                             1
		// 1                       1                     1                             0
		// 1                       1                     1                             1
		else begin
			//
			r_port_to_sadrs_h198 = r_port_to_sadrs_h198 | ( (~r_port_to_sadrs_h198_mon_smp) & (r_port_to_sadrs_h198_mon) );
		end
		//
		r_port_to_sadrs_h198_mon     <= r_port_to_sadrs_h198_ck ; // always
		r_port_to_sadrs_h198_mon_smp <= r_port_to_sadrs_h198_mon; // always
		//
	end
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz or 104MHz
	if (!reset_n) begin
		r_port_to_sadrs_h19C         <= 32'b0;
		r_port_to_sadrs_h19C_mon     <= 32'b0;
		r_port_to_sadrs_h19C_mon_smp <= 32'b0;
	end
	else begin
		// clear by read 
		if      (r_frame_miso_trig & (r_frame_adrs == 10'h19C+10'h000)) begin
			r_port_to_sadrs_h19C[15: 0] <= 16'b0;
		end
		else if (r_frame_miso_trig & (r_frame_adrs == 10'h19C+10'h002)) begin 
			r_port_to_sadrs_h19C[31:16] <= 16'b0;
		end
		// set by rise 
		// r_port_to_sadrs_h19C+ , r_port_to_sadrs_h19C, r_port_to_sadrs_h19C_mon_smp, r_port_to_sadrs_h19C_mon
		// 0                       0                     0                             0
		// 1                       0                     0                             1
		// 0                       0                     1                             0
		// 0                       0                     1                             1
		// 1                       1                     0                             0
		// 1                       1                     0                             1
		// 1                       1                     1                             0
		// 1                       1                     1                             1
		else begin
			//
			r_port_to_sadrs_h19C = r_port_to_sadrs_h19C | ( (~r_port_to_sadrs_h19C_mon_smp) & (r_port_to_sadrs_h19C_mon) );
		end
		//
		r_port_to_sadrs_h19C_mon     <= r_port_to_sadrs_h19C_ck ; // always
		r_port_to_sadrs_h19C_mon_smp <= r_port_to_sadrs_h19C_mon; // always
		//
	end
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz or 104MHz
	if (!reset_n) begin
		r_port_to_sadrs_h1CC         <= 32'b0;
		r_port_to_sadrs_h1CC_mon     <= 32'b0;
		r_port_to_sadrs_h1CC_mon_smp <= 32'b0;
	end
	else begin
		// clear by read 
		if      (r_frame_miso_trig & (r_frame_adrs == 10'h1CC+10'h000)) begin
			r_port_to_sadrs_h1CC[15: 0] <= 16'b0;
		end
		else if (r_frame_miso_trig & (r_frame_adrs == 10'h1CC+10'h002)) begin 
			r_port_to_sadrs_h1CC[31:16] <= 16'b0;
		end
		// set by rise 
		// r_port_to_sadrs_h1CC+ , r_port_to_sadrs_h1CC, r_port_to_sadrs_h1CC_mon_smp, r_port_to_sadrs_h1CC_mon
		// 0                       0                     0                             0
		// 1                       0                     0                             1
		// 0                       0                     1                             0
		// 0                       0                     1                             1
		// 1                       1                     0                             0
		// 1                       1                     0                             1
		// 1                       1                     1                             0
		// 1                       1                     1                             1
		else begin
			//
			r_port_to_sadrs_h1CC = r_port_to_sadrs_h1CC | ( (~r_port_to_sadrs_h1CC_mon_smp) & (r_port_to_sadrs_h1CC_mon) );
		end
		//
		r_port_to_sadrs_h1CC_mon     <= r_port_to_sadrs_h1CC_ck ; // always
		r_port_to_sadrs_h1CC_mon_smp <= r_port_to_sadrs_h1CC_mon; // always
		//
	end

//// pipe in  write //$$
// for o_wr__sadrs_h24C
// sync with r_frame_mosi_trig (not r_frame_miso_trig)

(* keep = "true" *) reg r_wr__sadrs_h218;
(* keep = "true" *) reg r_wr__sadrs_h21C;
(* keep = "true" *) reg r_wr__sadrs_h220;
(* keep = "true" *) reg r_wr__sadrs_h224;
(* keep = "true" *) reg r_wr__sadrs_h24C;
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz or 104MHz
	if (!reset_n) begin
		r_wr__sadrs_h218         <= 1'b0;
		r_wr__sadrs_h21C         <= 1'b0;
		r_wr__sadrs_h220         <= 1'b0;
		r_wr__sadrs_h224         <= 1'b0;
		r_wr__sadrs_h24C         <= 1'b0;
	end
	else begin
		// one pulse out
		if (r_frame_mosi_trig & (r_frame_adrs == 10'h218)) r_wr__sadrs_h218 <= 1'b1;  else r_wr__sadrs_h218 <= 1'b0;
		if (r_frame_mosi_trig & (r_frame_adrs == 10'h21C)) r_wr__sadrs_h21C <= 1'b1;  else r_wr__sadrs_h21C <= 1'b0;
		if (r_frame_mosi_trig & (r_frame_adrs == 10'h220)) r_wr__sadrs_h220 <= 1'b1;  else r_wr__sadrs_h220 <= 1'b0;
		if (r_frame_mosi_trig & (r_frame_adrs == 10'h224)) r_wr__sadrs_h224 <= 1'b1;  else r_wr__sadrs_h224 <= 1'b0;
		if (r_frame_mosi_trig & (r_frame_adrs == 10'h24C)) r_wr__sadrs_h24C <= 1'b1;  else r_wr__sadrs_h24C <= 1'b0;
	end
//
assign o_wr__sadrs_h218 = r_wr__sadrs_h218;
assign o_wr__sadrs_h21C = r_wr__sadrs_h21C;
assign o_wr__sadrs_h220 = r_wr__sadrs_h220;
assign o_wr__sadrs_h224 = r_wr__sadrs_h224;
assign o_wr__sadrs_h24C = r_wr__sadrs_h24C;



//// pipe out  read 
reg r_rd__sadrs_h280;
reg r_rd__sadrs_h284;
reg r_rd__sadrs_h288;
reg r_rd__sadrs_h28C;
reg r_rd__sadrs_h290;
reg r_rd__sadrs_h294;
reg r_rd__sadrs_h298;
reg r_rd__sadrs_h29C;
reg r_rd__sadrs_h2A0;
reg r_rd__sadrs_h2A4;
reg r_rd__sadrs_h2A8;
reg r_rd__sadrs_h2AC;
reg r_rd__sadrs_h2B0;
reg r_rd__sadrs_h2B4;
reg r_rd__sadrs_h2B8;
reg r_rd__sadrs_h2BC;
reg r_rd__sadrs_h2CC;
//
always @(posedge clk, negedge reset_n) // clk // base clock 72MHz or 104MHz
	if (!reset_n) begin
		r_rd__sadrs_h280         <= 1'b0;
		r_rd__sadrs_h284         <= 1'b0;
		r_rd__sadrs_h288         <= 1'b0;
		r_rd__sadrs_h28C         <= 1'b0;
		r_rd__sadrs_h290         <= 1'b0;
		r_rd__sadrs_h294         <= 1'b0;
		r_rd__sadrs_h298         <= 1'b0;
		r_rd__sadrs_h29C         <= 1'b0;
		r_rd__sadrs_h2A0         <= 1'b0;
		r_rd__sadrs_h2A4         <= 1'b0;
		r_rd__sadrs_h2A8         <= 1'b0;
		r_rd__sadrs_h2AC         <= 1'b0;
		r_rd__sadrs_h2B0         <= 1'b0;
		r_rd__sadrs_h2B4         <= 1'b0;
		r_rd__sadrs_h2B8         <= 1'b0;
		r_rd__sadrs_h2BC         <= 1'b0;
		r_rd__sadrs_h2CC         <= 1'b0;
	end
	else begin
		// one pulse out
		if (r_frame_miso_trig & (r_frame_adrs == 10'h280)) r_rd__sadrs_h280 <= 1'b1;  else r_rd__sadrs_h280 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h284)) r_rd__sadrs_h284 <= 1'b1;  else r_rd__sadrs_h284 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h288)) r_rd__sadrs_h288 <= 1'b1;  else r_rd__sadrs_h288 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h28C)) r_rd__sadrs_h28C <= 1'b1;  else r_rd__sadrs_h28C <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h290)) r_rd__sadrs_h290 <= 1'b1;  else r_rd__sadrs_h290 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h294)) r_rd__sadrs_h294 <= 1'b1;  else r_rd__sadrs_h294 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h298)) r_rd__sadrs_h298 <= 1'b1;  else r_rd__sadrs_h298 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h29C)) r_rd__sadrs_h29C <= 1'b1;  else r_rd__sadrs_h29C <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2A0)) r_rd__sadrs_h2A0 <= 1'b1;  else r_rd__sadrs_h2A0 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2A4)) r_rd__sadrs_h2A4 <= 1'b1;  else r_rd__sadrs_h2A4 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2A8)) r_rd__sadrs_h2A8 <= 1'b1;  else r_rd__sadrs_h2A8 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2AC)) r_rd__sadrs_h2AC <= 1'b1;  else r_rd__sadrs_h2AC <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2B0)) r_rd__sadrs_h2B0 <= 1'b1;  else r_rd__sadrs_h2B0 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2B4)) r_rd__sadrs_h2B4 <= 1'b1;  else r_rd__sadrs_h2B4 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2B8)) r_rd__sadrs_h2B8 <= 1'b1;  else r_rd__sadrs_h2B8 <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2BC)) r_rd__sadrs_h2BC <= 1'b1;  else r_rd__sadrs_h2BC <= 1'b0;
		if (r_frame_miso_trig & (r_frame_adrs == 10'h2CC)) r_rd__sadrs_h2CC <= 1'b1;  else r_rd__sadrs_h2CC <= 1'b0;
	end
//
assign o_rd__sadrs_h280 = r_rd__sadrs_h280;
assign o_rd__sadrs_h284 = r_rd__sadrs_h284;
assign o_rd__sadrs_h288 = r_rd__sadrs_h288;
assign o_rd__sadrs_h28C = r_rd__sadrs_h28C;
assign o_rd__sadrs_h290 = r_rd__sadrs_h290;
assign o_rd__sadrs_h294 = r_rd__sadrs_h294;
assign o_rd__sadrs_h298 = r_rd__sadrs_h298;
assign o_rd__sadrs_h29C = r_rd__sadrs_h29C;
assign o_rd__sadrs_h2A0 = r_rd__sadrs_h2A0;
assign o_rd__sadrs_h2A4 = r_rd__sadrs_h2A4;
assign o_rd__sadrs_h2A8 = r_rd__sadrs_h2A8;
assign o_rd__sadrs_h2AC = r_rd__sadrs_h2AC;
assign o_rd__sadrs_h2B0 = r_rd__sadrs_h2B0;
assign o_rd__sadrs_h2B4 = r_rd__sadrs_h2B4;
assign o_rd__sadrs_h2B8 = r_rd__sadrs_h2B8;
assign o_rd__sadrs_h2BC = r_rd__sadrs_h2BC;
assign o_rd__sadrs_h2CC = r_rd__sadrs_h2CC;

	
//}

//
endmodule
//}