`timescale 1ns / 1ps

//// support dsp macro
module dac_pattern_gen_wrapper__dsp ( //{

	// clock / reset
	input wire clk    , // system 10MHz 
	input wire reset_n,
	
	// DAC clock / reset
	//input wire i_clk_dacx_ref  , // dacx ref clock in      // unused
	//input wire i_rstn_dacx_ref , // dacx ref pll locked in // unused
	input wire i_clk_dac0_dco  , // dac0 / fifo clock in
	input wire i_rstn_dac0_dco , // 
	input wire i_clk_dac1_dco  , // dac1 / fifo clock in
	input wire i_rstn_dac1_dco , // 
	
	// DACZ control port // new control 
	input  wire [31:0] i_trig_dacz_ctrl, // 
	input  wire [31:0] i_wire_dacz_data, // 
	output wire [31:0] o_wire_dacz_data, // 

	// DACZ fifo port // new control // from MCS or USB
	input  wire        i_dac0_fifo_datinc_wr_ck , //
	input  wire        i_dac0_fifo_datinc_wr_en , //
	input  wire [31:0] i_dac0_fifo_datinc_din   , //
	input  wire        i_dac0_fifo_dur____wr_ck , //
	input  wire        i_dac0_fifo_dur____wr_en , //
	input  wire [31:0] i_dac0_fifo_dur____din   , //
	input  wire        i_dac1_fifo_datinc_wr_ck , //
	input  wire        i_dac1_fifo_datinc_wr_en , //
	input  wire [31:0] i_dac1_fifo_datinc_din   , //
	input  wire        i_dac1_fifo_dur____wr_ck , //
	input  wire        i_dac1_fifo_dur____wr_en , //
	input  wire [31:0] i_dac1_fifo_dur____din   , //
	
	input  wire        i_dac0_fifo_dd_rd_en_test, //
	input  wire        i_dac1_fifo_dd_rd_en_test, //
	
	// DAC data output port 
	output wire [15:0] o_dac0_data_pin, // 
	output wire [15:0] o_dac1_data_pin, // 
	
	// DAC activity flag 
	output wire        o_dac0_active_dco,
	output wire        o_dac1_active_dco,
	output wire        o_dac0_active_clk,
	output wire        o_dac1_active_clk,
	
	output wire        o_dac_pttn_trig_out,
	
	
	// flag
	output wire valid

	);


//// valid //{
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
//}


//// wires for cores //{

// DACZ
wire        w_dac0_fifo_datinc_rst  ;
wire [31:0] w_dac0_fifo_datinc_dout ;
wire        w_dac0_fifo_datinc_rd_ck;
wire        w_dac0_fifo_datinc_rd_en;
wire        w_dac0_fifo_datinc_full ;
wire        w_dac0_fifo_datinc_wrack;
wire        w_dac0_fifo_datinc_empty;
wire        w_dac0_fifo_datinc_valid;
//
wire        w_dac0_fifo_dur____rst  ;
wire [31:0] w_dac0_fifo_dur____dout ;
wire        w_dac0_fifo_dur____rd_ck;
wire        w_dac0_fifo_dur____rd_en;
wire        w_dac0_fifo_dur____full ;
wire        w_dac0_fifo_dur____wrack;
wire        w_dac0_fifo_dur____empty;
wire        w_dac0_fifo_dur____valid;
//
wire        w_dac1_fifo_datinc_rst  ;
wire [31:0] w_dac1_fifo_datinc_dout ;
wire        w_dac1_fifo_datinc_rd_ck;
wire        w_dac1_fifo_datinc_rd_en;
wire        w_dac1_fifo_datinc_full ;
wire        w_dac1_fifo_datinc_wrack;
wire        w_dac1_fifo_datinc_empty;
wire        w_dac1_fifo_datinc_valid;
//
wire        w_dac1_fifo_dur____rst  ;
wire [31:0] w_dac1_fifo_dur____dout ;
wire        w_dac1_fifo_dur____rd_ck;
wire        w_dac1_fifo_dur____rd_en;
wire        w_dac1_fifo_dur____full ;
wire        w_dac1_fifo_dur____wrack;
wire        w_dac1_fifo_dur____empty;
wire        w_dac1_fifo_dur____valid;


//}


////
wire w_enable_dac0_fifo_reload;
wire w_enable_dac1_fifo_reload;

//// pattern gen core ... dac_pattern_gen.v --> dac_pattern_gen_ext.v
////                      -->  dac_pattern_gen_ext__dsp.v
dac_pattern_gen_ext__dsp  dac_pattern_gen_inst (
	
	.clk              (clk    ), // 
	.reset_n          (reset_n),
	//
	.i_clk_dacx_ref   (), // unused
	.i_rstn_dacx_ref  (), // unused
	.i_clk_dac0_dco   (i_clk_dac0_dco     ),   
	.i_rstn_dac0_dco  (i_rstn_dac0_dco    ), 
	.i_clk_dac1_dco   (i_clk_dac1_dco     ),   
	.i_rstn_dac1_dco  (i_rstn_dac1_dco    ), 
	
	.i_trig_dacz_ctrl (i_trig_dacz_ctrl   ), // [31:0]
	.i_wire_dacz_data (i_wire_dacz_data   ), // [31:0]
	.o_wire_dacz_data (o_wire_dacz_data   ), // [31:0]
	
	.o_dac0_data_pin  (o_dac0_data_pin    ), // [15:0]
	.o_dac1_data_pin  (o_dac1_data_pin    ), // [15:0]
	
	.o_dac0_active_dco  (o_dac0_active_dco), //$$ CID or FCID active signal for switching fifo reload path
	.o_dac1_active_dco  (o_dac1_active_dco), //$$ CID or FCID active signal for switching fifo reload path
	.o_dac0_active_clk  (o_dac0_active_clk),
	.o_dac1_active_clk  (o_dac1_active_clk),
	.o_enable_dac0_fifo_reload (w_enable_dac0_fifo_reload),
	.o_enable_dac1_fifo_reload (w_enable_dac1_fifo_reload),
	
	//// DACZ fifo interface //{
	.o_dac0_fifo_datinc_rst       (w_dac0_fifo_datinc_rst  ), //       
	.i_dac0_fifo_datinc_dout      (w_dac0_fifo_datinc_dout ), // [31:0]
	.o_dac0_fifo_datinc_rd_ck     (w_dac0_fifo_datinc_rd_ck), //       
	.o_dac0_fifo_datinc_rd_en     (w_dac0_fifo_datinc_rd_en), //       
	.i_dac0_fifo_datinc_empty     (w_dac0_fifo_datinc_empty), //       
	.i_dac0_fifo_datinc_valid     (w_dac0_fifo_datinc_valid), //       
	.o_dac0_fifo_dur____rst       (w_dac0_fifo_dur____rst  ), //       
	.i_dac0_fifo_dur____dout      (w_dac0_fifo_dur____dout ), // [31:0]
	.o_dac0_fifo_dur____rd_ck     (w_dac0_fifo_dur____rd_ck), //       
	.o_dac0_fifo_dur____rd_en     (w_dac0_fifo_dur____rd_en), //       
	.i_dac0_fifo_dur____empty     (w_dac0_fifo_dur____empty), //       
	.i_dac0_fifo_dur____valid     (w_dac0_fifo_dur____valid), //       
	.o_dac1_fifo_datinc_rst       (w_dac1_fifo_datinc_rst  ), //       
	.i_dac1_fifo_datinc_dout      (w_dac1_fifo_datinc_dout ), // [31:0]
	.o_dac1_fifo_datinc_rd_ck     (w_dac1_fifo_datinc_rd_ck), //       
	.o_dac1_fifo_datinc_rd_en     (w_dac1_fifo_datinc_rd_en), //       
	.i_dac1_fifo_datinc_empty     (w_dac1_fifo_datinc_empty), //       
	.i_dac1_fifo_datinc_valid     (w_dac1_fifo_datinc_valid), //       
	.o_dac1_fifo_dur____rst       (w_dac1_fifo_dur____rst  ), //       
	.i_dac1_fifo_dur____dout      (w_dac1_fifo_dur____dout ), // [31:0]
	.o_dac1_fifo_dur____rd_ck     (w_dac1_fifo_dur____rd_ck), //       
	.o_dac1_fifo_dur____rd_en     (w_dac1_fifo_dur____rd_en), //       
	.i_dac1_fifo_dur____empty     (w_dac1_fifo_dur____empty), //       
	.i_dac1_fifo_dur____valid     (w_dac1_fifo_dur____valid), //       
	
	//}
	
	.o_dac_pttn_trig_out (o_dac_pttn_trig_out),	
	
	//
	.valid()
);


//// fifo cores //{


//// try fifo reload reg insertion
reg [31:0] r_dac0_fifo_datinc_dout ; // loopback sample
reg [31:0] r_dac0_fifo_dur____dout ; // loopback sample
reg [31:0] r_dac1_fifo_datinc_dout ; // loopback sample
reg [31:0] r_dac1_fifo_dur____dout ; // loopback sample
reg        r_dac0_fifo_datinc_rd_en; // loopback sample
reg        r_dac0_fifo_dur____rd_en; // loopback sample
reg        r_dac1_fifo_datinc_rd_en; // loopback sample
reg        r_dac1_fifo_dur____rd_en; // loopback sample

always @(posedge i_clk_dac0_dco, negedge i_rstn_dac0_dco)
	if (!i_rstn_dac0_dco) begin
		r_dac0_fifo_datinc_dout  <= 32'b0;
		r_dac0_fifo_dur____dout  <= 32'b0;
		r_dac0_fifo_datinc_rd_en <= 1'b0;
		r_dac0_fifo_dur____rd_en <= 1'b0;
	end
	else begin
		r_dac0_fifo_datinc_dout  <= w_dac0_fifo_datinc_dout;
		r_dac0_fifo_dur____dout  <= w_dac0_fifo_dur____dout;
		r_dac0_fifo_datinc_rd_en <= w_dac0_fifo_datinc_rd_en;
		r_dac0_fifo_dur____rd_en <= w_dac0_fifo_dur____rd_en;
	end

always @(posedge i_clk_dac1_dco, negedge i_rstn_dac1_dco)
	if (!i_rstn_dac1_dco) begin
		r_dac1_fifo_datinc_dout  <= 32'b0;
		r_dac1_fifo_dur____dout  <= 32'b0;
		r_dac1_fifo_datinc_rd_en <= 1'b0;
		r_dac1_fifo_dur____rd_en <= 1'b0;
	end
	else begin
		r_dac1_fifo_datinc_dout  <= w_dac1_fifo_datinc_dout;
		r_dac1_fifo_dur____dout  <= w_dac1_fifo_dur____dout;
		r_dac1_fifo_datinc_rd_en <= w_dac1_fifo_datinc_rd_en;
		r_dac1_fifo_dur____rd_en <= w_dac1_fifo_dur____rd_en;
	end


//// fifo wr path switch for reload

//$$ note: re-define reload signal based on fifo activity
//$$wire w_enable_dac0_fifo_reload = o_dac0_active_dco; //$$ note coupling with non-fifo operation...
//$$wire w_enable_dac1_fifo_reload = o_dac1_active_dco;

wire        w_dac0_fifo_datinc_wr_ck = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_wr_ck : w_dac0_fifo_datinc_rd_ck ;
wire        w_dac0_fifo_datinc_wr_en = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_wr_en : r_dac0_fifo_datinc_rd_en ;
wire [31:0] w_dac0_fifo_datinc_din   = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_din   : r_dac0_fifo_datinc_dout  ;
wire        w_dac0_fifo_dur____wr_ck = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____wr_ck : w_dac0_fifo_dur____rd_ck ;
wire        w_dac0_fifo_dur____wr_en = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____wr_en : r_dac0_fifo_dur____rd_en ;
wire [31:0] w_dac0_fifo_dur____din   = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____din   : r_dac0_fifo_dur____dout  ;

wire        w_dac1_fifo_datinc_wr_ck = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_wr_ck : w_dac1_fifo_datinc_rd_ck ;
wire        w_dac1_fifo_datinc_wr_en = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_wr_en : r_dac1_fifo_datinc_rd_en ;
wire [31:0] w_dac1_fifo_datinc_din   = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_din   : r_dac1_fifo_datinc_dout  ;
wire        w_dac1_fifo_dur____wr_ck = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____wr_ck : w_dac1_fifo_dur____rd_ck ;
wire        w_dac1_fifo_dur____wr_en = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____wr_en : r_dac1_fifo_dur____rd_en ;
wire [31:0] w_dac1_fifo_dur____din   = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____din   : r_dac1_fifo_dur____dout  ;



//// DACZ fifos : fifo_generator_5_1_2 //{

// fifo_generator_5_1_2 : 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz

fifo_generator_5_1_2  dac0_fifo_datinc__inst (
  .rst       (w_dac0_fifo_datinc_rst  ),  // input wire rst
  .wr_clk    (w_dac0_fifo_datinc_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_datinc_wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_datinc_din  ),  // input wire [31 : 0] din
  .rd_clk    (w_dac0_fifo_datinc_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_datinc_rd_en | i_dac0_fifo_dd_rd_en_test),  // input wire rd_en
  .dout      (w_dac0_fifo_datinc_dout ),  // output wire [31 : 0] dout
  .full      (w_dac0_fifo_datinc_full ),  // output wire full
  .wr_ack    (w_dac0_fifo_datinc_wrack),  // output wire wr_ack
  .empty     (w_dac0_fifo_datinc_empty),  // output wire empty
  .valid     (w_dac0_fifo_datinc_valid)   // output wire valid
);

fifo_generator_5_1_2  dac0_fifo_dur_____inst (
  .rst       (w_dac0_fifo_dur____rst  ),  // input wire rst
  .wr_clk    (w_dac0_fifo_dur____wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_dur____wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_dur____din  ),  // input wire [31 : 0] din
  .rd_clk    (w_dac0_fifo_dur____rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_dur____rd_en | i_dac0_fifo_dd_rd_en_test),  // input wire rd_en
  .dout      (w_dac0_fifo_dur____dout ),  // output wire [31 : 0] dout
  .full      (w_dac0_fifo_dur____full ),  // output wire full
  .wr_ack    (w_dac0_fifo_dur____wrack),  // output wire wr_ack
  .empty     (w_dac0_fifo_dur____empty),  // output wire empty
  .valid     (w_dac0_fifo_dur____valid)   // output wire valid
);

fifo_generator_5_1_2  dac1_fifo_datinc__inst (
  .rst       (w_dac1_fifo_datinc_rst  ),  // input wire rst
  .wr_clk    (w_dac1_fifo_datinc_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_datinc_wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_datinc_din  ),  // input wire [31 : 0] din
  .rd_clk    (w_dac1_fifo_datinc_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_datinc_rd_en | i_dac1_fifo_dd_rd_en_test),  // input wire rd_en
  .dout      (w_dac1_fifo_datinc_dout ),  // output wire [31 : 0] dout
  .full      (w_dac1_fifo_datinc_full ),  // output wire full
  .wr_ack    (w_dac1_fifo_datinc_wrack),  // output wire wr_ack
  .empty     (w_dac1_fifo_datinc_empty),  // output wire empty
  .valid     (w_dac1_fifo_datinc_valid)   // output wire valid
);

fifo_generator_5_1_2  dac1_fifo_dur_____inst (
  .rst       (w_dac1_fifo_dur____rst  ),  // input wire rst
  .wr_clk    (w_dac1_fifo_dur____wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_dur____wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_dur____din  ),  // input wire [31 : 0] din
  .rd_clk    (w_dac1_fifo_dur____rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_dur____rd_en | i_dac1_fifo_dd_rd_en_test),  // input wire rd_en
  .dout      (w_dac1_fifo_dur____dout ),  // output wire [31 : 0] dout
  .full      (w_dac1_fifo_dur____full ),  // output wire full
  .wr_ack    (w_dac1_fifo_dur____wrack),  // output wire wr_ack
  .empty     (w_dac1_fifo_dur____empty),  // output wire empty
  .valid     (w_dac1_fifo_dur____valid)   // output wire valid
);

//// note : din to mux with dout

//}


//}


endmodule
//}

