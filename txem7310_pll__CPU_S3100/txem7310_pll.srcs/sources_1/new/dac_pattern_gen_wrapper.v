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


////---- ================================================================ ----////

//// ref
module dac_pattern_gen_wrapper ( //{

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

	// DACX control port
	//input  wire [31:0] i_trig_dacx_ctrl, // 
	//input  wire [31:0] i_wire_dacx_data, // 
	//output wire [31:0] o_wire_dacx_data, // 
	
	//// fifo data and control //{
	input  wire        i_dac0_fifo_wr_clk, //
	input  wire        i_dac0_fifo_wr_en , //
	input  wire [31:0] i_dac0_fifo_din   , //
	input  wire        i_dac1_fifo_wr_clk, //
	input  wire        i_dac1_fifo_wr_en , //
	input  wire [31:0] i_dac1_fifo_din   , //
	//
	input  wire        i_dac0_fifo_rd_en_test , // test read out
	input  wire        i_dac1_fifo_rd_en_test , // test read out
	// FIFO flag 
	output wire        o_fifo_dac0_full ,
	output wire        o_fifo_dac0_wrack,
	output wire        o_fifo_dac0_empty,
	output wire        o_fifo_dac0_valid,
	//
	output wire        o_fifo_dac1_full ,
	output wire        o_fifo_dac1_wrack,
	output wire        o_fifo_dac1_empty,
	output wire        o_fifo_dac1_valid,
	//}
	
	// DAC data output port 
	output wire [15:0] o_dac0_data_pin, // 
	output wire [15:0] o_dac1_data_pin, // 
	
	// DAC activity flag 
	output wire        o_dac0_active_dco,
	output wire        o_dac1_active_dco,
	output wire        o_dac0_active_clk,
	output wire        o_dac1_active_clk,
	
	
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

////{
wire        w_fifo_dac0_rst;
wire [31:0] w_fifo_dac0_dout;
wire        c_fifo_dac0_rd_ck;
wire        w_fifo_dac0_rd_en;
wire        w_fifo_dac0_full ;
wire        w_fifo_dac0_wrack;
wire        w_fifo_dac0_empty;
wire        w_fifo_dac0_valid;
//
wire        w_fifo_dac1_rst;
wire [31:0] w_fifo_dac1_dout;
wire        c_fifo_dac1_rd_ck;
wire        w_fifo_dac1_rd_en;
wire        w_fifo_dac1_full ;
wire        w_fifo_dac1_wrack;
wire        w_fifo_dac1_empty;
wire        w_fifo_dac1_valid;


wire        w_dac0_fifo_reload1_rst   ;
wire [31:0] w_dac0_fifo_reload1_dout  ;
wire        c_dac0_fifo_reload1_rd_ck ;
wire        w_dac0_fifo_reload1_rd_en ;
wire        w_dac0_fifo_reload1_empty ;
wire        w_dac0_fifo_reload1_valid ;
wire [31:0] w_dac0_fifo_reload1_din   ;
wire        c_dac0_fifo_reload1_wr_ck ;
wire        w_dac0_fifo_reload1_wr_en ;
wire        w_dac0_fifo_reload1_full  ;
wire        w_dac0_fifo_reload1_wr_ack;

wire        w_dac0_fifo_reload2_rst   ;
wire [31:0] w_dac0_fifo_reload2_dout  ;
wire        c_dac0_fifo_reload2_rd_ck ;
wire        w_dac0_fifo_reload2_rd_en ;
wire        w_dac0_fifo_reload2_empty ;
wire        w_dac0_fifo_reload2_valid ;
wire [31:0] w_dac0_fifo_reload2_din   ;
wire        c_dac0_fifo_reload2_wr_ck ;
wire        w_dac0_fifo_reload2_wr_en ;
wire        w_dac0_fifo_reload2_full  ;
wire        w_dac0_fifo_reload2_wr_ack;


wire        w_dac1_fifo_reload1_rst   ;
wire [31:0] w_dac1_fifo_reload1_dout  ;
wire        c_dac1_fifo_reload1_rd_ck ;
wire        w_dac1_fifo_reload1_rd_en ;
wire        w_dac1_fifo_reload1_empty ;
wire        w_dac1_fifo_reload1_valid ;
wire [31:0] w_dac1_fifo_reload1_din   ;
wire        c_dac1_fifo_reload1_wr_ck ;
wire        w_dac1_fifo_reload1_wr_en ;
wire        w_dac1_fifo_reload1_full  ;
wire        w_dac1_fifo_reload1_wr_ack;

wire        w_dac1_fifo_reload2_rst   ;
wire [31:0] w_dac1_fifo_reload2_dout  ;
wire        c_dac1_fifo_reload2_rd_ck ;
wire        w_dac1_fifo_reload2_rd_en ;
wire        w_dac1_fifo_reload2_empty ;
wire        w_dac1_fifo_reload2_valid ;
wire [31:0] w_dac1_fifo_reload2_din   ;
wire        c_dac1_fifo_reload2_wr_ck ;
wire        w_dac1_fifo_reload2_wr_en ;
wire        w_dac1_fifo_reload2_full  ;
wire        w_dac1_fifo_reload2_wr_ack;
//}


//}


//// fifo flag //{

assign o_fifo_dac0_full  = w_fifo_dac0_full ;
assign o_fifo_dac0_wrack = w_fifo_dac0_wrack;
assign o_fifo_dac0_empty = w_fifo_dac0_empty;
assign o_fifo_dac0_valid = w_fifo_dac0_valid;

assign o_fifo_dac1_full  = w_fifo_dac1_full ;
assign o_fifo_dac1_wrack = w_fifo_dac1_wrack;
assign o_fifo_dac1_empty = w_fifo_dac1_empty;
assign o_fifo_dac1_valid = w_fifo_dac1_valid;

//}


//// pattern gen core ... dac_pattern_gen.v --> dac_pattern_gen_ext.v
dac_pattern_gen_ext  dac_pattern_gen_inst (
	
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
	
	//// fifo interface //{
	
	.o_dac0_fifo_rst    (w_fifo_dac0_rst  ),
	.i_dac0_fifo_dout   (w_fifo_dac0_dout ), // [31:0]
	.c_dac0_fifo_rd_ck  (c_fifo_dac0_rd_ck), // output
	.o_dac0_fifo_rd_en  (w_fifo_dac0_rd_en),
	.i_dac0_fifo_empty  (w_fifo_dac0_empty),
	.i_dac0_fifo_valid  (w_fifo_dac0_valid),

	.o_dac1_fifo_rst    (w_fifo_dac1_rst  ),
	.i_dac1_fifo_dout   (w_fifo_dac1_dout ), // [31:0]
	.c_dac1_fifo_rd_ck  (c_fifo_dac1_rd_ck),
	.o_dac1_fifo_rd_en  (w_fifo_dac1_rd_en),
	.i_dac1_fifo_empty  (w_fifo_dac1_empty),
	.i_dac1_fifo_valid  (w_fifo_dac1_valid),
	
	//
	.o_dac0_fifo_reload1_rst    (w_dac0_fifo_reload1_rst   ),
	.i_dac0_fifo_reload1_dout   (w_dac0_fifo_reload1_dout  ),
	.c_dac0_fifo_reload1_rd_ck  (c_dac0_fifo_reload1_rd_ck ),
	.o_dac0_fifo_reload1_rd_en  (w_dac0_fifo_reload1_rd_en ),
	.i_dac0_fifo_reload1_empty  (w_dac0_fifo_reload1_empty ),
	.i_dac0_fifo_reload1_valid  (w_dac0_fifo_reload1_valid ),
	.o_dac0_fifo_reload1_din    (w_dac0_fifo_reload1_din   ),
	.c_dac0_fifo_reload1_wr_ck  (c_dac0_fifo_reload1_wr_ck ),
	.o_dac0_fifo_reload1_wr_en  (w_dac0_fifo_reload1_wr_en ),
	.i_dac0_fifo_reload1_full   (w_dac0_fifo_reload1_full  ),
	.i_dac0_fifo_reload1_wr_ack (w_dac0_fifo_reload1_wr_ack),
	
	//
	.o_dac0_fifo_reload2_rst    (w_dac0_fifo_reload2_rst   ),
	.i_dac0_fifo_reload2_dout   (w_dac0_fifo_reload2_dout  ),
	.c_dac0_fifo_reload2_rd_ck  (c_dac0_fifo_reload2_rd_ck ),
	.o_dac0_fifo_reload2_rd_en  (w_dac0_fifo_reload2_rd_en ),
	.i_dac0_fifo_reload2_empty  (w_dac0_fifo_reload2_empty ),
	.i_dac0_fifo_reload2_valid  (w_dac0_fifo_reload2_valid ),
	.o_dac0_fifo_reload2_din    (w_dac0_fifo_reload2_din   ),
	.c_dac0_fifo_reload2_wr_ck  (c_dac0_fifo_reload2_wr_ck ),
	.o_dac0_fifo_reload2_wr_en  (w_dac0_fifo_reload2_wr_en ),
	.i_dac0_fifo_reload2_full   (w_dac0_fifo_reload2_full  ),
	.i_dac0_fifo_reload2_wr_ack (w_dac0_fifo_reload2_wr_ack),

	//
	.o_dac1_fifo_reload1_rst    (w_dac1_fifo_reload1_rst   ),
	.i_dac1_fifo_reload1_dout   (w_dac1_fifo_reload1_dout  ),
	.c_dac1_fifo_reload1_rd_ck  (c_dac1_fifo_reload1_rd_ck ),
	.o_dac1_fifo_reload1_rd_en  (w_dac1_fifo_reload1_rd_en ),
	.i_dac1_fifo_reload1_empty  (w_dac1_fifo_reload1_empty ),
	.i_dac1_fifo_reload1_valid  (w_dac1_fifo_reload1_valid ),
	.o_dac1_fifo_reload1_din    (w_dac1_fifo_reload1_din   ),
	.c_dac1_fifo_reload1_wr_ck  (c_dac1_fifo_reload1_wr_ck ),
	.o_dac1_fifo_reload1_wr_en  (w_dac1_fifo_reload1_wr_en ),
	.i_dac1_fifo_reload1_full   (w_dac1_fifo_reload1_full  ),
	.i_dac1_fifo_reload1_wr_ack (w_dac1_fifo_reload1_wr_ack),

	//
	.o_dac1_fifo_reload2_rst    (w_dac1_fifo_reload2_rst   ),
	.i_dac1_fifo_reload2_dout   (w_dac1_fifo_reload2_dout  ),
	.c_dac1_fifo_reload2_rd_ck  (c_dac1_fifo_reload2_rd_ck ),
	.o_dac1_fifo_reload2_rd_en  (w_dac1_fifo_reload2_rd_en ),
	.i_dac1_fifo_reload2_empty  (w_dac1_fifo_reload2_empty ),
	.i_dac1_fifo_reload2_valid  (w_dac1_fifo_reload2_valid ),
	.o_dac1_fifo_reload2_din    (w_dac1_fifo_reload2_din   ),
	.c_dac1_fifo_reload2_wr_ck  (c_dac1_fifo_reload2_wr_ck ),
	.o_dac1_fifo_reload2_wr_en  (w_dac1_fifo_reload2_wr_en ),
	.i_dac1_fifo_reload2_full   (w_dac1_fifo_reload2_full  ),
	.i_dac1_fifo_reload2_wr_ack (w_dac1_fifo_reload2_wr_ack),

	//}

	//
	.valid()
);


//// fifo cores //{

//// fifo wr path switch for reload

wire w_enable_dac0_fifo_reload = o_dac0_active_dco;
wire w_enable_dac1_fifo_reload = o_dac1_active_dco;

wire        w_dac0_fifo_datinc_wr_ck = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_wr_ck : w_dac0_fifo_datinc_rd_ck ;
wire        w_dac0_fifo_datinc_wr_en = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_wr_en : w_dac0_fifo_datinc_rd_en ;
wire [31:0] w_dac0_fifo_datinc_din   = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_datinc_din   : w_dac0_fifo_datinc_dout  ;
wire        w_dac0_fifo_dur____wr_ck = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____wr_ck : w_dac0_fifo_dur____rd_ck ;
wire        w_dac0_fifo_dur____wr_en = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____wr_en : w_dac0_fifo_dur____rd_en ;
wire [31:0] w_dac0_fifo_dur____din   = (~w_enable_dac0_fifo_reload)? i_dac0_fifo_dur____din   : w_dac0_fifo_dur____dout  ;

wire        w_dac1_fifo_datinc_wr_ck = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_wr_ck : w_dac1_fifo_datinc_rd_ck ;
wire        w_dac1_fifo_datinc_wr_en = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_wr_en : w_dac1_fifo_datinc_rd_en ;
wire [31:0] w_dac1_fifo_datinc_din   = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_datinc_din   : w_dac1_fifo_datinc_dout  ;
wire        w_dac1_fifo_dur____wr_ck = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____wr_ck : w_dac1_fifo_dur____rd_ck ;
wire        w_dac1_fifo_dur____wr_en = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____wr_en : w_dac1_fifo_dur____rd_en ;
wire [31:0] w_dac1_fifo_dur____din   = (~w_enable_dac1_fifo_reload)? i_dac1_fifo_dur____din   : w_dac1_fifo_dur____dout  ;


//// DACZ fifos : fifo_generator_5_1_2 //{

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


////{

// fifo_generator_4_* : dac pattern ... 16 bit dac code + 16 bit duration count
// 32 bits
// 4096 depth = 2^12    or 2048
// 2^12 * 4 byte = 16KB or 8KB
//
// fifo in  : from USB end-points
// fifo out : to dac_pattern_gen for FDCS test
//
// fifo loopback setup ... considered later
//   clock sharing is must for loopback ... thus, loopback fifo will be considered.


// fifo_generator_4_1_2 // DAC fifo 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz // used in rd 200MHz
//   wr 101MHz // used in wr 72MHz or okClk 100.806MHz

fifo_generator_4_1_2  fifo_dac0_inst (
  .rst       (~i_rstn_dac0_dco | w_fifo_dac0_rst), // input wire rst
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (i_dac0_fifo_wr_clk), // input wire wr_clk
  .wr_en     (i_dac0_fifo_wr_en ), // input wire wr_en
  .din       (i_dac0_fifo_din   ), // input wire [31 : 0] din
  //
  .rd_clk    (c_fifo_dac0_rd_ck ),  // input wire rd_clk
  .rd_en     (i_dac0_fifo_rd_en_test  | w_fifo_dac0_rd_en),      // input wire rd_en
  .dout      (w_fifo_dac0_dout), // output wire [31 : 0] dout
  //
  .full      (w_fifo_dac0_full ),  // output wire full
  .wr_ack    (w_fifo_dac0_wrack),  // output wire wr_ack
  .empty     (w_fifo_dac0_empty),  // output wire empty
  .valid     (w_fifo_dac0_valid)   // output wire valid
);

fifo_generator_4_1_2  fifo_dac1_inst (
  .rst       (~i_rstn_dac1_dco | w_fifo_dac1_rst), // input wire rst
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (i_dac1_fifo_wr_clk),  // input wire wr_clk
  .wr_en     (i_dac1_fifo_wr_en ), // input wire wr_en
  .din       (i_dac1_fifo_din   ), // input wire [31 : 0] din
  //
  .rd_clk    (c_fifo_dac1_rd_ck),  // input wire rd_clk
  .rd_en     (i_dac1_fifo_rd_en_test | w_fifo_dac1_rd_en),      // input wire rd_en
  .dout      (w_fifo_dac1_dout), // output wire [31 : 0] dout
  //
  .full      (w_fifo_dac1_full ),  // output wire full
  .wr_ack    (w_fifo_dac1_wrack),  // output wire wr_ack
  .empty     (w_fifo_dac1_empty),  // output wire empty
  .valid     (w_fifo_dac1_valid)   // output wire valid
);


// fifo_generator_5_1_2 : from dac to dac // fifo reload 
//   width "32-bit"
//   depth "1024 = 2^10"
//   read mode: first word fall through (FWFT)
//   rd 200MHz
//   wr 200MHz

fifo_generator_5_1_2  fifo_reload1_dac0_inst (
  .rst       (~reset_n | w_dac0_fifo_reload1_rst),  // input wire rst
  //.clk       (c_dac0_fifo_reload1_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac0_fifo_reload1_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_reload1_wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_reload1_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac0_fifo_reload1_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_reload1_rd_en),  // input wire rd_en
  .dout      (w_dac0_fifo_reload1_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac0_fifo_reload1_full),  // output wire full
  .wr_ack    (w_dac0_fifo_reload1_wr_ack),  // output wire wr_ack
  .empty     (w_dac0_fifo_reload1_empty),  // output wire empty
  .valid     (w_dac0_fifo_reload1_valid)   // output wire valid
);

fifo_generator_5_1_2  fifo_reload2_dac0_inst (
  .rst       (~reset_n | w_dac0_fifo_reload2_rst),  // input wire rst
  //.clk       (c_dac0_fifo_reload2_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac0_fifo_reload2_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac0_fifo_reload2_wr_en),  // input wire wr_en
  .din       (w_dac0_fifo_reload2_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac0_fifo_reload2_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac0_fifo_reload2_rd_en),  // input wire rd_en
  .dout      (w_dac0_fifo_reload2_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac0_fifo_reload2_full),  // output wire full
  .wr_ack    (w_dac0_fifo_reload2_wr_ack),  // output wire wr_ack
  .empty     (w_dac0_fifo_reload2_empty),  // output wire empty
  .valid     (w_dac0_fifo_reload2_valid)   // output wire valid
);


fifo_generator_5_1_2  fifo_reload1_dac1_inst (
  .rst       (~reset_n | w_dac1_fifo_reload1_rst),  // input wire rst
  //.clk       (c_dac1_fifo_reload1_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac1_fifo_reload1_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_reload1_wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_reload1_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac1_fifo_reload1_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_reload1_rd_en),  // input wire rd_en
  .dout      (w_dac1_fifo_reload1_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac1_fifo_reload1_full),  // output wire full
  .wr_ack    (w_dac1_fifo_reload1_wr_ack),  // output wire wr_ack
  .empty     (w_dac1_fifo_reload1_empty),  // output wire empty
  .valid     (w_dac1_fifo_reload1_valid)   // output wire valid
);

fifo_generator_5_1_2  fifo_reload2_dac1_inst (
  .rst       (~reset_n | w_dac1_fifo_reload2_rst),  // input wire rst
  //.clk       (c_dac1_fifo_reload2_wr_ck),  // input wire clk
  //
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy(),  // output wire rd_rst_busy
  //
  .wr_clk    (c_dac1_fifo_reload2_wr_ck),  // input wire wr_clk
  .wr_en     (w_dac1_fifo_reload2_wr_en),  // input wire wr_en
  .din       (w_dac1_fifo_reload2_din),  // input wire [31 : 0] din
  //
  .rd_clk    (c_dac1_fifo_reload2_rd_ck),  // input wire rd_clk
  .rd_en     (w_dac1_fifo_reload2_rd_en),  // input wire rd_en
  .dout      (w_dac1_fifo_reload2_dout),  // output wire [31 : 0] dout
  //
  .full      (w_dac1_fifo_reload2_full),  // output wire full
  .wr_ack    (w_dac1_fifo_reload2_wr_ack),  // output wire wr_ack
  .empty     (w_dac1_fifo_reload2_empty),  // output wire empty
  .valid     (w_dac1_fifo_reload2_valid)   // output wire valid
);

//}

//}


endmodule
//}
