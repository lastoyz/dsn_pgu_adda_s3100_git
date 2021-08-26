`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: calculate_dft_wrapper
// 
//////////////////////////////////////////////////////////////////////////////////


//// TODO: control_dft_calc
module control_dft_calc (
	input  wire clk    , // assume 10MHz or 100ns // io control
	input  wire reset_n,
		   
	input  wire clk_fifo, // assume 60MHz fifo clock // data from adc to dft buffer
	input  wire clk_mcs ,  // assume 72MHz mcs clock // data from mcs to fifo dft coef // or muxed with usb clock

	// control from adc logic // @ clk_fifo
	input  wire        i_adc_data_en       , // adc data enable // assume apulse
	//
	input  wire        i_rst__coef_rd_adrs , // reset dft coef read address 
	input  wire        i_inc__coef_rd_adrs , // increase dft coef read address
	output wire [16:0] o_adrs_rd_dft_coef  , // dft coef read address 
	output wire        o_rd_en__dft_coef   , // dft coef read enable
	
	// command from mcs or usb // @ clk_mcs
	input  wire        i_rst__coef_wr_adrs , // reset dft coef write address 
	//input  wire        i_inc__coef_wr_adrs , // increase dft coef write address // pipe-in access
	//output wire [16:0] o_adrs_wr_dft_coef  , // dft coef write address
	input  wire        i_mcs_dft_coef_re_wren      , //
	input  wire        i_mcs_dft_coef_im_wren      , //
	input  wire [31:0] i_mcs_dft_coef_flt32_re_din , // 
	input  wire [31:0] i_mcs_dft_coef_flt32_im_din , // 

	output wire        o_dft_coef_re_wren          , //
	output wire        o_dft_coef_im_wren          , //
	output wire [16:0] o_dft_coef_re_adrs_wr       , // 
	output wire [16:0] o_dft_coef_im_adrs_wr       , // 
	output wire [23:0] o_dft_coef_flt24_re_din     , //
	output wire [23:0] o_dft_coef_flt24_im_din     , //
	
	// controls for other components // @ clk_fifo
	output wire        o_pulse_seq1        ,// seq 1
	output wire        o_pulse_seq2        ,// seq 2
	output wire        o_pulse_seq3        ,// seq 3
	output wire        o_pulse_seq4        ,// seq 4
				       
	output wire        valid
); //{

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


//// o_adrs_rd_dft_coef  o_rd_en__dft_coef //{
reg [16:0] r_adrs_rd_dft_coef;
reg        r_rd_en__dft_coef;

always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_adrs_rd_dft_coef <= 17'b0;
		r_rd_en__dft_coef  <= 1'b0;
	end
	else begin
		if (i_rst__coef_rd_adrs) begin 
			r_adrs_rd_dft_coef <= 17'b0;
			r_rd_en__dft_coef  <= 1'b1;
		end
		else if (i_inc__coef_rd_adrs) begin 
			r_adrs_rd_dft_coef <= r_adrs_rd_dft_coef + 1;
			r_rd_en__dft_coef  <= 1'b1;
		end
		else begin 
			r_adrs_rd_dft_coef <= r_adrs_rd_dft_coef;
			r_rd_en__dft_coef  <= 1'b0;
		end
		
	end

assign o_adrs_rd_dft_coef = r_adrs_rd_dft_coef;
assign o_rd_en__dft_coef  = r_rd_en__dft_coef;

//}

//// seq controls //{
reg r_pulse_seq1;
reg r_pulse_seq2;
reg r_pulse_seq3;
reg r_pulse_seq4;

always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_pulse_seq1 <= 1'b0;
		r_pulse_seq2 <= 1'b0;
		r_pulse_seq3 <= 1'b0;
		r_pulse_seq4 <= 1'b0;
	end
	else begin
		r_pulse_seq1 <= i_adc_data_en;
		r_pulse_seq2 <= r_pulse_seq1 ;
		r_pulse_seq3 <= r_pulse_seq2 ;
		r_pulse_seq4 <= r_pulse_seq3 ;
	end
		

assign o_pulse_seq1 = r_pulse_seq1 ;
assign o_pulse_seq2 = r_pulse_seq2 ;
assign o_pulse_seq3 = r_pulse_seq3 ;
assign o_pulse_seq4 = r_pulse_seq4 ;
//}


//// write dft coef //{

reg        r_dft_coef_re_wren   ;
reg        r_dft_coef_im_wren   ;
reg [16:0] r_dft_coef_re_adrs_wr;
reg [16:0] r_dft_coef_im_adrs_wr;
reg [23:0] r_dft_coef_flt24_re_din;
reg [23:0] r_dft_coef_flt24_im_din;

// clk_mcs
// i_rst__coef_wr_adrs
always @(posedge clk_mcs, negedge reset_n)
	if (!reset_n) begin
		r_dft_coef_re_wren      <=  1'b0;
		r_dft_coef_im_wren      <=  1'b0;
		r_dft_coef_re_adrs_wr   <= 17'b0;
		r_dft_coef_im_adrs_wr   <= 17'b0;
		r_dft_coef_flt24_re_din <= 24'b0;
		r_dft_coef_flt24_im_din <= 24'b0;
	end
	else begin
		//// re side
		if (i_rst__coef_wr_adrs) begin 
			r_dft_coef_re_wren    <=  1'b0;
		end
		else if (i_mcs_dft_coef_re_wren) begin 
			r_dft_coef_re_wren      <= 1'b1;
			r_dft_coef_flt24_re_din <= i_mcs_dft_coef_flt32_re_din[31:8]; // flt32-->flt24 by def of flt24
		end
		else begin 
			r_dft_coef_re_wren    <= 1'b0;
		end
		//
		if (i_rst__coef_wr_adrs) begin 
			r_dft_coef_re_adrs_wr <= 17'b0;
		end
		else if (r_dft_coef_re_wren) begin 
			r_dft_coef_re_adrs_wr <= r_dft_coef_re_adrs_wr + 1; // delayed increase
		end
		else begin 
			r_dft_coef_re_adrs_wr <= r_dft_coef_re_adrs_wr;
		end
		
		//// im side
		if (i_rst__coef_wr_adrs) begin 
			r_dft_coef_im_wren    <=  1'b0;
		end
		else if (i_mcs_dft_coef_im_wren) begin 
			r_dft_coef_im_wren      <= 1'b1;
			r_dft_coef_flt24_im_din <= i_mcs_dft_coef_flt32_im_din[31:8]; // flt32-->flt24 by def of flt24
		end
		else begin 
			r_dft_coef_im_wren    <= 1'b0;
		end
		//
		if (i_rst__coef_wr_adrs) begin 
			r_dft_coef_im_adrs_wr <= 17'b0;
		end
		else if (r_dft_coef_im_wren) begin 
			r_dft_coef_im_adrs_wr <= r_dft_coef_im_adrs_wr + 1; // delayed increase
		end
		else begin 
			r_dft_coef_im_adrs_wr <= r_dft_coef_im_adrs_wr;
		end
	end



//// assign outputs 
assign o_dft_coef_re_wren      = r_dft_coef_re_wren   ;
assign o_dft_coef_im_wren      = r_dft_coef_im_wren   ;
assign o_dft_coef_re_adrs_wr   = r_dft_coef_re_adrs_wr;
assign o_dft_coef_im_adrs_wr   = r_dft_coef_im_adrs_wr;
//
//assign o_dft_coef_flt24_re_din = i_mcs_dft_coef_flt32_re_din[31:8]; // flt32-->flt24 by def of flt24
//assign o_dft_coef_flt24_im_din = i_mcs_dft_coef_flt32_im_din[31:8]; // flt32-->flt24 by def of flt24
assign o_dft_coef_flt24_re_din = r_dft_coef_flt24_re_din;
assign o_dft_coef_flt24_im_din = r_dft_coef_flt24_im_din;

//}


endmodule
//}


//// TODO: calculate_dft_wrapper
// new try ... prod_reg (r_prd_flt32_*) and acc_reg (r_acc_flt32_*)

module calculate_dft_wrapper (
	input  wire clk    , // assume 10MHz or 100ns // io control
	input  wire reset_n,
		   
	input  wire clk_fifo, // assume 60MHz fifo clock // data from adc to dft buffer
	input  wire clk_mcs ,  // assume 72MHz mcs clock // data from mcs to fifo dft coef // or muxed with usb clock

	// controls
	input  wire i_dft_coef_adrs_clear,
	input  wire i_acc_clear          ,
	input  wire i_trig_fifo_wr_en    ,

	// ports - data in and acc out
	input  wire [17:0] i_adc_data_int18_dout0,
	input  wire [17:0] i_adc_data_int18_dout1,
	//
	output wire [31:0] o_acc_flt32_re_dout0,
	output wire [31:0] o_acc_flt32_im_dout0,
	output wire [31:0] o_acc_flt32_re_dout1,
	output wire [31:0] o_acc_flt32_im_dout1,

	// ports - coef write
	input  wire        i_dft_coef_wr_adrs_clear     ,
	//input  wire i_dft_coef_wr_en        , // based on clk_mcs
	input  wire        i_mcs_dft_coef_re_wren       ,
	input  wire        i_mcs_dft_coef_im_wren       ,
	input  wire [31:0] i_mcs_dft_coef_flt32_re_din  ,
	input  wire [31:0] i_mcs_dft_coef_flt32_im_din  ,

	// port - monitor
	output wire o_pulse_monitor, // every acc load
	
	output wire [31:0] o_dft_coef_flt32_re_dout, // from mem
	output wire [31:0] o_dft_coef_flt32_im_dout, // from mem

	output wire valid
); //{

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


////---- controller ----////

////  control_dft_calc  //{

//reg         r_dft_coef_adrs_clear = 1'b0; // from adc fifo logic
//reg         r_acc_clear           = 1'b0; // from adc fifo logic
//reg         r_trig_fifo_wr_en     = 1'b0; // from adc fifo logic

wire        w_adc_data_en       = i_trig_fifo_wr_en;

// read dft coef
wire        w_rst__coef_rd_adrs = i_dft_coef_adrs_clear;
wire        w_inc__coef_rd_adrs ; // assign later
wire [16:0] w_adrs_rd_dft_coef  ;
wire        w_rd_en__dft_coef   ;

// write dft coef
wire        w_rst__coef_wr_adrs = i_dft_coef_wr_adrs_clear;
//wire        w_inc__coef_wr_adrs = 1'b0;
//wire [16:0] w_adrs_wr_dft_coef  ;

//
wire        w_dft_coef_re_wren       ;
wire        w_dft_coef_im_wren       ;
wire [16:0] w_dft_coef_re_adrs_wr    ;
wire [16:0] w_dft_coef_im_adrs_wr    ;
wire [23:0] w_dft_coef_flt24_re_din  ;
wire [23:0] w_dft_coef_flt24_im_din  ;


wire        w_pulse_seq1 ;
wire        w_pulse_seq2 ;
wire        w_pulse_seq3 ;
wire        w_pulse_seq4 ;

//
control_dft_calc  control_dft_calc__inst (
	.clk                 (clk      ), // assume 10MHz or 100ns // io control
	.reset_n             (reset_n  ),
		   
	.clk_fifo            (clk_fifo ), // 60MHz
	.clk_mcs             (clk_mcs  ), // 72MHz or 100.8MHz

	// control from adc logic // @ clk_fifo
	.i_adc_data_en       (w_adc_data_en      ), // 
	.i_rst__coef_rd_adrs (w_rst__coef_rd_adrs), // 
	.i_inc__coef_rd_adrs (w_inc__coef_rd_adrs), // 
	.o_adrs_rd_dft_coef  (w_adrs_rd_dft_coef ), // [16:0]
	.o_rd_en__dft_coef   (w_rd_en__dft_coef  ), //
	
	// command from mcs or usb // @ clk_mcs
	.i_rst__coef_wr_adrs (w_rst__coef_wr_adrs), // 
	
	.i_mcs_dft_coef_re_wren      (i_mcs_dft_coef_re_wren      ), //
	.i_mcs_dft_coef_im_wren      (i_mcs_dft_coef_im_wren      ), //
	.i_mcs_dft_coef_flt32_re_din (i_mcs_dft_coef_flt32_re_din ), // [31:0]
	.i_mcs_dft_coef_flt32_im_din (i_mcs_dft_coef_flt32_im_din ), // [31:0]
	
	//.i_inc__coef_wr_adrs (w_inc__coef_wr_adrs), // 
	
	// to dft mem wr side
	.o_dft_coef_re_wren       (w_dft_coef_re_wren     ), // 
	.o_dft_coef_im_wren       (w_dft_coef_im_wren     ), // 
	.o_dft_coef_re_adrs_wr    (w_dft_coef_re_adrs_wr  ), // [16:0] 
	.o_dft_coef_im_adrs_wr    (w_dft_coef_im_adrs_wr  ), // [16:0] 
	.o_dft_coef_flt24_re_din  (w_dft_coef_flt24_re_din), // [23:0]
	.o_dft_coef_flt24_im_din  (w_dft_coef_flt24_im_din), // [23:0]
	
	//.o_adrs_wr_dft_coef  (w_adrs_wr_dft_coef ), // [16:0]
	
	// controls for other components // @ clk_fifo
	.o_pulse_seq1        (w_pulse_seq1), // r_adc_data_rden
	.o_pulse_seq2        (w_pulse_seq2), // r_adc_int_flt_conv // r_dft_coef_adrs = r_dft_coef_adrs + 1
	.o_pulse_seq3        (w_pulse_seq3), // r_acc_conv // r_dft_coef_rden (--> w_rd_en__dft_coef)
	.o_pulse_seq4        (w_pulse_seq4), // r_acc_load // r_verify_data_rden
				       
	.valid               ()
);

//
assign w_inc__coef_rd_adrs = w_pulse_seq2;
//assign w_inc__coef_rd_adrs = w_pulse_seq3;

//}

//// call block mem : dft coef data loaded //{
//reg         r_dft_coef_rden = 1'b0;
wire [16:0] w_dft_coef_adrs         = w_adrs_rd_dft_coef;
//
wire        w_dft_coef_rden         = w_rd_en__dft_coef; //w_pulse_seq3;
wire        w_dft_coef_regceb       = reset_n;
wire [31:0] w_dft_coef_flt32_re_dout;
wire [31:0] w_dft_coef_flt32_im_dout;


//  //
//  blk_mem_gen_dft_re_0  blk_mem_gen_dft_re__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (32'b0                   ),  // input wire [31 : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt32_re_dout)   // output wire [31 : 0] doutb
//  );
//  
//  blk_mem_gen_dft_im_0  blk_mem_gen_dft_im__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (32'b0                   ),  // input wire [31 : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt32_im_dout)   // output wire [31 : 0] doutb
//  );


////
//  blk_mem_gen_dft_im_flt24_0 your_instance_name (
//    .clka(clka),      // input wire clka
//    .wea(wea),        // input wire [0 : 0] wea
//    .addra(addra),    // input wire [16 : 0] addra
//    .dina(dina),      // input wire [23 : 0] dina
//    .clkb(clkb),      // input wire clkb
//    .enb(enb),        // input wire enb
//    .regceb(regceb),  // input wire regceb
//    .addrb(addrb),    // input wire [16 : 0] addrb
//    .doutb(doutb)    // output wire [23 : 0] doutb
//  );

//// flt32 S E8 F24 <--  flt24 S E8 F16 //{
wire [23:0] w_dft_coef_flt24_re_dout;
wire [23:0] w_dft_coef_flt24_im_dout;


blk_mem_gen_dft_re_flt24_0  blk_mem_gen_dft_re__inst0 (
	.clka  (clk_mcs                 ),  // input wire clka
	.wea   (w_dft_coef_re_wren      ),  // input wire [0 : 0] wea
	.addra (w_dft_coef_re_adrs_wr   ),  // input wire [16 : 0] addra
	.dina  (w_dft_coef_flt24_re_din ),  // input wire [* : 0] dina
	.clkb  (clk_fifo                ),  // input wire clkb
	.enb   (w_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt24_re_dout)   // output wire [* : 0] doutb
);

blk_mem_gen_dft_im_flt24_0  blk_mem_gen_dft_im__inst0 (
	.clka  (clk_mcs                 ),  // input wire clka
	.wea   (w_dft_coef_im_wren      ),  // input wire [0 : 0] wea
	.addra (w_dft_coef_im_adrs_wr   ),  // input wire [16 : 0] addra
	.dina  (w_dft_coef_flt24_im_din ),  // input wire [* : 0] dina
	.clkb  (clk_fifo                ),  // input wire clkb
	.enb   (w_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt24_im_dout)   // output wire [* : 0] doutb
);

//
assign  w_dft_coef_flt32_re_dout =  {w_dft_coef_flt24_re_dout,8'b0};
assign  w_dft_coef_flt32_im_dout =  {w_dft_coef_flt24_im_dout,8'b0};

//}

//// flt32 S E8 F24 <--  flt26 S E8 F18 //{
//  wire [25:0] w_dft_coef_flt26_re_dout;
//  wire [25:0] w_dft_coef_flt26_im_dout;
//  
//  blk_mem_gen_dft_re_flt26_0  blk_mem_gen_dft_re__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (26'b0                   ),  // input wire [* : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt26_re_dout)   // output wire [* : 0] doutb
//  );
//  
//  blk_mem_gen_dft_im_flt26_0  blk_mem_gen_dft_im__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (26'b0                   ),  // input wire [* : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt26_im_dout)   // output wire [* : 0] doutb
//  );
//  
//  //
//  assign  w_dft_coef_flt32_re_dout =  {w_dft_coef_flt26_re_dout,6'b0};
//  assign  w_dft_coef_flt32_im_dout =  {w_dft_coef_flt26_im_dout,6'b0};

//}

assign o_dft_coef_flt32_re_dout = w_dft_coef_flt32_re_dout;
assign o_dft_coef_flt32_im_dout = w_dft_coef_flt32_im_dout;



//}


////---- calculate ----////

//// convert adc data int18 into single prcs flt32 : call floating_point_int32_sgflt_0 //{
//   note ... floating_point_int18_flt32_0 ip is also possible!!
//reg         r_adc_int_flt_conv = 1'b0;
//

wire [17:0] w_adc_data_int18_dout0 = i_adc_data_int18_dout0;
wire [17:0] w_adc_data_int18_dout1 = i_adc_data_int18_dout1;

wire [31:0] w_adc_data_int32_dout0     = { {14{w_adc_data_int18_dout0[17]}}, w_adc_data_int18_dout0[17:0]};
wire [31:0] w_adc_data_int32_dout1     = { {14{w_adc_data_int18_dout1[17]}}, w_adc_data_int18_dout1[17:0]};
wire        w_adc_data_int32_dout0_vld = w_pulse_seq2; // r_adc_int_flt_conv; // input
wire        w_adc_data_int32_dout1_vld = w_pulse_seq2; // r_adc_int_flt_conv; // input
wire [31:0] w_adc_data_flt32_dout0     ;
wire [31:0] w_adc_data_flt32_dout1     ;
wire        w_adc_data_flt32_dout0_vld ; // output
wire        w_adc_data_flt32_dout1_vld ; // output
//
wire        w_adc_int_flt_conv         = w_pulse_seq2; // r_adc_int_flt_conv; //$$ not for latency 0
// ...

//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout0_inst (
	//.aclk                   (clk_fifo                   ),  // input wire aclk
	//.aclken                 (w_adc_int_flt_conv         ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout0_vld ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout0     ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout0_vld ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout0     )   // output wire [31 : 0] m_axis_result_tdata
);
//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout1_inst (
	//.aclk                   (clk_fifo                    ),  // input wire aclk
	//.aclken                 (w_adc_int_flt_conv          ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout1_vld  ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout1      ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout1_vld  ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout1      )   // output wire [31 : 0] m_axis_result_tdata
);


// multiply adc and coef  // we can skip...
//wire [31:0] w_prd_calc_flt32_re_dout0;
//wire [31:0] w_prd_calc_flt32_im_dout0;
//wire [31:0] w_prd_calc_flt32_re_dout1;
//wire [31:0] w_prd_calc_flt32_im_dout1;
// ...

//}


//// accumulate the products for dft calcation //{


//// call floating_point_mult_flt32_0 // new try 
//   C = A*B
//   A : adc data 
//   B : dft coef 
//  floating_point_mult_flt32_0 floating_point_mult_flt32__re_dout0_inst (
//  	.s_axis_a_tvalid        (s_axis_a_tvalid        ), // input wire s_axis_a_tvalid
//  	.s_axis_a_tdata         (s_axis_a_tdata         ), // input wire [31 : 0] s_axis_a_tdata
//  	.s_axis_b_tvalid        (s_axis_b_tvalid        ), // input wire s_axis_b_tvalid
//  	.s_axis_b_tdata         (s_axis_b_tdata         ), // input wire [31 : 0] s_axis_b_tdata
//  	.m_axis_result_tvalid   (m_axis_result_tvalid   ), // output wire m_axis_result_tvalid
//  	.m_axis_result_tdata    (m_axis_result_tdata    )  // output wire [31 : 0] m_axis_result_tdata
//  );

//// call floating_point_add_flt32_0 // new try 
//   C = A+B
//   A : accumulator
//   B : product
//  floating_point_add_flt32_0 floating_point_add_flt32__re_dout0_inst (
//  	.s_axis_a_tvalid        (s_axis_a_tvalid        ), // input wire s_axis_a_tvalid
//  	.s_axis_a_tdata         (s_axis_a_tdata         ), // input wire [31 : 0] s_axis_a_tdata
//  	.s_axis_b_tvalid        (s_axis_b_tvalid        ), // input wire s_axis_b_tvalid
//  	.s_axis_b_tdata         (s_axis_b_tdata         ), // input wire [31 : 0] s_axis_b_tdata
//  	.m_axis_result_tvalid   (m_axis_result_tvalid   ), // output wire m_axis_result_tvalid
//  	.m_axis_result_tdata    (m_axis_result_tdata    )  // output wire [31 : 0] m_axis_result_tdata
//  );

//// note that ... consider buffer reg for adc data and coef data... due to two fanouts


//// sample acc clear //{
reg       r_acc_clear;
reg [1:0] r_smp_acc_clear;

always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_smp_acc_clear <= 2'b0;
		r_acc_clear     <= 1'b0;
		end 
	else begin
		r_smp_acc_clear <= {r_smp_acc_clear[0], i_acc_clear};
		r_acc_clear     <= (r_smp_acc_clear==2'b01)? 1'b1 : 1'b0;
		end

//}


//// controls
wire w_buf_clear = r_acc_clear ;
wire w_buf_load  = w_pulse_seq1;

wire w_prd_clear = r_acc_clear ;
wire w_prd_load  = w_pulse_seq2;

wire w_acc_clear = r_acc_clear ; // r_acc_clear; // input //$$ may be time-relaxed
wire w_acc_load  = w_pulse_seq4; // r_acc_load ; // input

//// regs for pipe //{

reg [31:0] r_adc_data_flt32_re_dout0; // repeater of w_adc_data_flt32_dout0
reg [31:0] r_adc_data_flt32_im_dout0; // repeater of w_adc_data_flt32_dout0
reg [31:0] r_adc_data_flt32_re_dout1; // repeater of w_adc_data_flt32_dout1
reg [31:0] r_adc_data_flt32_im_dout1; // repeater of w_adc_data_flt32_dout1

reg [31:0] r_dft_coef_flt32_re_dout0; // repeater of w_dft_coef_flt32_re_dout
reg [31:0] r_dft_coef_flt32_im_dout0; // repeater of w_dft_coef_flt32_im_dout
reg [31:0] r_dft_coef_flt32_re_dout1; // repeater of w_dft_coef_flt32_re_dout
reg [31:0] r_dft_coef_flt32_im_dout1; // repeater of w_dft_coef_flt32_im_dout

reg  [31:0] r_prd_flt32_re_dout0;
reg  [31:0] r_prd_flt32_im_dout0;
reg  [31:0] r_prd_flt32_re_dout1;
reg  [31:0] r_prd_flt32_im_dout1;

reg  [31:0] r_acc_flt32_re_dout0;
reg  [31:0] r_acc_flt32_im_dout0;
reg  [31:0] r_acc_flt32_re_dout1;
reg  [31:0] r_acc_flt32_im_dout1;

wire [31:0] w_prd_flt32_re_dout0; // assign
wire [31:0] w_prd_flt32_im_dout0; // assign
wire [31:0] w_prd_flt32_re_dout1; // assign
wire [31:0] w_prd_flt32_im_dout1; // assign

wire [31:0] w_acc_flt32_re_dout0; // assign
wire [31:0] w_acc_flt32_im_dout0; // assign
wire [31:0] w_acc_flt32_re_dout1; // assign
wire [31:0] w_acc_flt32_im_dout1; // assign

//// input buffer update
always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_adc_data_flt32_re_dout0 <= 32'b0;
		r_adc_data_flt32_im_dout0 <= 32'b0;
		r_adc_data_flt32_re_dout1 <= 32'b0;
		r_adc_data_flt32_im_dout1 <= 32'b0;
        
		r_dft_coef_flt32_re_dout0 <= 32'b0;
		r_dft_coef_flt32_im_dout0 <= 32'b0;
		r_dft_coef_flt32_re_dout1 <= 32'b0;
		r_dft_coef_flt32_im_dout1 <= 32'b0;
		end 
	else begin
		if (w_buf_clear) begin
			r_adc_data_flt32_re_dout0 <= 32'b0;
			r_adc_data_flt32_im_dout0 <= 32'b0;
			r_adc_data_flt32_re_dout1 <= 32'b0;
			r_adc_data_flt32_im_dout1 <= 32'b0;
			
			r_dft_coef_flt32_re_dout0 <= 32'b0;
			r_dft_coef_flt32_im_dout0 <= 32'b0;
			r_dft_coef_flt32_re_dout1 <= 32'b0;
			r_dft_coef_flt32_im_dout1 <= 32'b0;
			end
		else if (w_buf_load) begin 
			r_adc_data_flt32_re_dout0 <= w_adc_data_flt32_dout0;
			r_adc_data_flt32_im_dout0 <= w_adc_data_flt32_dout0;
			r_adc_data_flt32_re_dout1 <= w_adc_data_flt32_dout1;
			r_adc_data_flt32_im_dout1 <= w_adc_data_flt32_dout1;
			                             
			r_dft_coef_flt32_re_dout0 <= w_dft_coef_flt32_re_dout;
			r_dft_coef_flt32_im_dout0 <= w_dft_coef_flt32_im_dout;
			r_dft_coef_flt32_re_dout1 <= w_dft_coef_flt32_re_dout;
			r_dft_coef_flt32_im_dout1 <= w_dft_coef_flt32_im_dout;
			end
		end



//// prod reg update
always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_prd_flt32_re_dout0 <= 32'b0;
		r_prd_flt32_im_dout0 <= 32'b0;
		r_prd_flt32_re_dout1 <= 32'b0;
		r_prd_flt32_im_dout1 <= 32'b0;
		end 
	else begin
		if (w_prd_clear) begin
			r_prd_flt32_re_dout0 <= 32'b0;
			r_prd_flt32_im_dout0 <= 32'b0;
			r_prd_flt32_re_dout1 <= 32'b0;
			r_prd_flt32_im_dout1 <= 32'b0;
			end
		else if (w_prd_load) begin 
			r_prd_flt32_re_dout0 <= w_prd_flt32_re_dout0;
			r_prd_flt32_im_dout0 <= w_prd_flt32_im_dout0;
			r_prd_flt32_re_dout1 <= w_prd_flt32_re_dout1;
			r_prd_flt32_im_dout1 <= w_prd_flt32_im_dout1;
			end
		end


//// final acc reg update
always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_acc_flt32_re_dout0 <= 32'b0;
		r_acc_flt32_im_dout0 <= 32'b0;
		r_acc_flt32_re_dout1 <= 32'b0;
		r_acc_flt32_im_dout1 <= 32'b0;
		end 
	else begin
		if (w_acc_clear) begin
			r_acc_flt32_re_dout0 <= 32'b0;
			r_acc_flt32_im_dout0 <= 32'b0;
			r_acc_flt32_re_dout1 <= 32'b0;
			r_acc_flt32_im_dout1 <= 32'b0;
			end
		else if (w_acc_load) begin 
			r_acc_flt32_re_dout0 <= w_acc_flt32_re_dout0;
			r_acc_flt32_im_dout0 <= w_acc_flt32_im_dout0;
			r_acc_flt32_re_dout1 <= w_acc_flt32_re_dout1;
			r_acc_flt32_im_dout1 <= w_acc_flt32_im_dout1;
			end
		end

//}


//// TODO: math operation //{

//// data wires 

// adc : w_adc_data_flt32_dout0
// adc : w_adc_data_flt32_dout1

// coef: w_dft_coef_flt32_re_dout
// coef: w_dft_coef_flt32_im_dout

// prod: r_prd_flt32_re_dout0
// prod: r_prd_flt32_im_dout0
// prod: r_prd_flt32_re_dout1
// prod: r_prd_flt32_im_dout1

// acc : r_acc_flt32_re_dout0
// acc : r_acc_flt32_im_dout0
// acc : r_acc_flt32_re_dout1
// acc : r_acc_flt32_im_dout1

// valid 
wire mult_vld_in = w_pulse_seq2;
wire mult_vld_re_dout0;
wire mult_vld_im_dout0;
wire mult_vld_re_dout1;
wire mult_vld_im_dout1;

wire add_vld_in  = w_pulse_seq3 | w_pulse_seq4; //$$ note multicycle
wire add_vld_re_dout0;
wire add_vld_im_dout0;
wire add_vld_re_dout1;
wire add_vld_im_dout1;


//// mult : adc * coef
floating_point_mult_flt32_0 floating_point_mult_flt32__re_dout0_inst (
	.s_axis_a_tvalid        (mult_vld_in              ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_adc_data_flt32_re_dout0), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (mult_vld_in              ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_dft_coef_flt32_re_dout0), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (mult_vld_re_dout0        ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_prd_flt32_re_dout0     )  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_flt32_0 floating_point_mult_flt32__im_dout0_inst (
	.s_axis_a_tvalid        (mult_vld_in              ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_adc_data_flt32_im_dout0), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (mult_vld_in              ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_dft_coef_flt32_im_dout0), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (mult_vld_im_dout0        ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_prd_flt32_im_dout0     )  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_flt32_0 floating_point_mult_flt32__re_dout1_inst (
	.s_axis_a_tvalid        (mult_vld_in              ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_adc_data_flt32_re_dout1), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (mult_vld_in              ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_dft_coef_flt32_re_dout1), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (mult_vld_re_dout1        ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_prd_flt32_re_dout1     )  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_flt32_0 floating_point_mult_flt32__im_dout1_inst (
	.s_axis_a_tvalid        (mult_vld_in              ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_adc_data_flt32_im_dout1), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (mult_vld_in              ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_dft_coef_flt32_im_dout1), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (mult_vld_im_dout1        ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_prd_flt32_im_dout1     )  // output wire [31 : 0] m_axis_result_tdata
);


//// add : acc + prod
floating_point_add_flt32_0 floating_point_add_flt32__re_dout0_inst (
	.s_axis_a_tvalid        (add_vld_in          ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_acc_flt32_re_dout0), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (add_vld_in          ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_prd_flt32_re_dout0), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (add_vld_re_dout0    ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_acc_flt32_re_dout0)  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_add_flt32_0 floating_point_add_flt32__im_dout0_inst (
	.s_axis_a_tvalid        (add_vld_in          ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_acc_flt32_im_dout0), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (add_vld_in          ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_prd_flt32_im_dout0), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (add_vld_im_dout0    ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_acc_flt32_im_dout0)  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_add_flt32_0 floating_point_add_flt32__re_dout1_inst (
	.s_axis_a_tvalid        (add_vld_in          ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_acc_flt32_re_dout1), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (add_vld_in          ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_prd_flt32_re_dout1), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (add_vld_re_dout1    ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_acc_flt32_re_dout1)  // output wire [31 : 0] m_axis_result_tdata
);

floating_point_add_flt32_0 floating_point_add_flt32__im_dout1_inst (
	.s_axis_a_tvalid        (add_vld_in          ), // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (r_acc_flt32_im_dout1), // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid        (add_vld_in          ), // input wire s_axis_b_tvalid
	.s_axis_b_tdata         (r_prd_flt32_im_dout1), // input wire [31 : 0] s_axis_b_tdata
	.m_axis_result_tvalid   (add_vld_im_dout1    ), // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_acc_flt32_im_dout1)  // output wire [31 : 0] m_axis_result_tdata
);


//}


//}


//// acc output //{
assign o_acc_flt32_re_dout0 = r_acc_flt32_re_dout0; //
assign o_acc_flt32_im_dout0 = r_acc_flt32_im_dout0; //
assign o_acc_flt32_re_dout1 = r_acc_flt32_re_dout1; //
assign o_acc_flt32_im_dout1 = r_acc_flt32_im_dout1; //
//}

//// o_pulse_monitor //{
//assign o_pulse_monitor = w_pulse_seq4 & w_acc_flt32_im_dout1_o_vld; 
assign o_pulse_monitor = w_pulse_seq4; 

//}

//
endmodule

//}


//// TODO: calculate_dft_wrapper ref mult-add
module calculate_dft_wrapper__ref_mult_add (
	input  wire clk    , // assume 10MHz or 100ns // io control
	input  wire reset_n,
		   
	input  wire clk_fifo, // assume 60MHz fifo clock // data from adc to dft buffer
	input  wire clk_mcs ,  // assume 72MHz mcs clock // data from mcs to fifo dft coef // or muxed with usb clock

	// controls
	input  wire i_dft_coef_adrs_clear,
	input  wire i_acc_clear          ,
	input  wire i_trig_fifo_wr_en    ,

	// ports - data in and acc out
	input  wire [17:0] i_adc_data_int18_dout0,
	input  wire [17:0] i_adc_data_int18_dout1,
	//
	output wire [31:0] o_acc_flt32_re_dout0,
	output wire [31:0] o_acc_flt32_im_dout0,
	output wire [31:0] o_acc_flt32_re_dout1,
	output wire [31:0] o_acc_flt32_im_dout1,
	

	// ports - coef write
	//...

	// port - monitor
	output wire o_pulse_monitor, // every acc load

	output wire valid
); //{

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


////---- controller ----////

////  control_dft_calc  //{

//reg         r_dft_coef_adrs_clear = 1'b0; // from adc fifo logic
//reg         r_acc_clear           = 1'b0; // from adc fifo logic
//reg         r_trig_fifo_wr_en     = 1'b0; // from adc fifo logic

wire        w_adc_data_en       = i_trig_fifo_wr_en;
//
wire        w_rst__coef_rd_adrs = i_dft_coef_adrs_clear;
wire        w_inc__coef_rd_adrs ; // assign later
wire [16:0] w_adrs_rd_dft_coef  ;
wire        w_rd_en__dft_coef   ;

wire        w_rst__coef_wr_adrs = ~reset_n;
wire        w_inc__coef_wr_adrs = 1'b0;
wire [16:0] w_adrs_wr_dft_coef  ;

wire        w_pulse_seq1 ;
wire        w_pulse_seq2 ;
wire        w_pulse_seq3 ;
wire        w_pulse_seq4 ;

//
control_dft_calc  control_dft_calc__inst (
	.clk                 (clk      ), // assume 10MHz or 100ns // io control
	.reset_n             (reset_n  ),
		   
	.clk_fifo            (clk_fifo ), // 60MHz
	.clk_mcs             (clk_mcs  ), // 72MHz or 100.8MHz

	// control from adc logic // @ clk_fifo
	.i_adc_data_en       (w_adc_data_en      ), // 
	.i_rst__coef_rd_adrs (w_rst__coef_rd_adrs), // 
	.i_inc__coef_rd_adrs (w_inc__coef_rd_adrs), // 
	.o_adrs_rd_dft_coef  (w_adrs_rd_dft_coef ), // [16:0]
	.o_rd_en__dft_coef   (w_rd_en__dft_coef  ), //
	
	// command from mcs or usb // @ clk_mcs
	.i_rst__coef_wr_adrs (w_rst__coef_wr_adrs), // 
	.i_inc__coef_wr_adrs (w_inc__coef_wr_adrs), // 
	.o_adrs_wr_dft_coef  (w_adrs_wr_dft_coef ), // [16:0]
	
	// controls for other components // @ clk_fifo
	.o_pulse_seq1        (w_pulse_seq1), // r_adc_data_rden
	.o_pulse_seq2        (w_pulse_seq2), // r_adc_int_flt_conv // r_dft_coef_adrs = r_dft_coef_adrs + 1
	.o_pulse_seq3        (w_pulse_seq3), // r_acc_conv // r_dft_coef_rden (--> w_rd_en__dft_coef)
	.o_pulse_seq4        (w_pulse_seq4), // r_acc_load // r_verify_data_rden
				       
	.valid               ()
);

//
assign w_inc__coef_rd_adrs = w_pulse_seq2;
//assign w_inc__coef_rd_adrs = w_pulse_seq3;

//}

//// call block mem : dft coef data loaded //{
//reg         r_dft_coef_rden = 1'b0;
wire [16:0] w_dft_coef_adrs         = w_adrs_rd_dft_coef;
//
wire        w_dft_coef_rden         = w_rd_en__dft_coef; //w_pulse_seq3;
wire        w_dft_coef_regceb       = reset_n;
wire [31:0] w_dft_coef_flt32_re_dout;
wire [31:0] w_dft_coef_flt32_im_dout;

//  //
//  blk_mem_gen_dft_re_0  blk_mem_gen_dft_re__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (32'b0                   ),  // input wire [31 : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt32_re_dout)   // output wire [31 : 0] doutb
//  );
//  
//  blk_mem_gen_dft_im_0  blk_mem_gen_dft_im__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (32'b0                   ),  // input wire [31 : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt32_im_dout)   // output wire [31 : 0] doutb
//  );


////
//  blk_mem_gen_dft_im_flt24_0 your_instance_name (
//    .clka(clka),      // input wire clka
//    .wea(wea),        // input wire [0 : 0] wea
//    .addra(addra),    // input wire [16 : 0] addra
//    .dina(dina),      // input wire [23 : 0] dina
//    .clkb(clkb),      // input wire clkb
//    .enb(enb),        // input wire enb
//    .regceb(regceb),  // input wire regceb
//    .addrb(addrb),    // input wire [16 : 0] addrb
//    .doutb(doutb)    // output wire [23 : 0] doutb
//  );

//// flt32 S E8 F24 <--  flt24 S E8 F16 //{
wire [23:0] w_dft_coef_flt24_re_dout;
wire [23:0] w_dft_coef_flt24_im_dout;

blk_mem_gen_dft_re_flt24_0  blk_mem_gen_dft_re__inst0 (
	.clka  (clk_fifo                ),  // input wire clka
	.wea   (1'b0                    ),  // input wire [0 : 0] wea
	.addra (17'b0                   ),  // input wire [16 : 0] addra
	.dina  (24'b0                   ),  // input wire [* : 0] dina
	.clkb  (clk_fifo                ),  // input wire clkb
	.enb   (w_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt24_re_dout)   // output wire [* : 0] doutb
);

blk_mem_gen_dft_im_flt24_0  blk_mem_gen_dft_im__inst0 (
	.clka  (clk_fifo                ),  // input wire clka
	.wea   (1'b0                    ),  // input wire [0 : 0] wea
	.addra (17'b0                   ),  // input wire [16 : 0] addra
	.dina  (24'b0                   ),  // input wire [* : 0] dina
	.clkb  (clk_fifo                ),  // input wire clkb
	.enb   (w_dft_coef_rden         ),  // input wire enb
	.regceb(w_dft_coef_regceb       ),  // input wire regceb
	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
	.doutb (w_dft_coef_flt24_im_dout)   // output wire [* : 0] doutb
);

//
assign  w_dft_coef_flt32_re_dout =  {w_dft_coef_flt24_re_dout,8'b0};
assign  w_dft_coef_flt32_im_dout =  {w_dft_coef_flt24_im_dout,8'b0};

//}

//// flt32 S E8 F24 <--  flt26 S E8 F18 //{
//  wire [25:0] w_dft_coef_flt26_re_dout;
//  wire [25:0] w_dft_coef_flt26_im_dout;
//  
//  blk_mem_gen_dft_re_flt26_0  blk_mem_gen_dft_re__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (26'b0                   ),  // input wire [* : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt26_re_dout)   // output wire [* : 0] doutb
//  );
//  
//  blk_mem_gen_dft_im_flt26_0  blk_mem_gen_dft_im__inst0 (
//  	.clka  (clk_fifo                ),  // input wire clka
//  	.wea   (1'b0                    ),  // input wire [0 : 0] wea
//  	.addra (17'b0                   ),  // input wire [16 : 0] addra
//  	.dina  (26'b0                   ),  // input wire [* : 0] dina
//  	.clkb  (clk_fifo                ),  // input wire clkb
//  	.enb   (w_dft_coef_rden         ),  // input wire enb
//  	.regceb(w_dft_coef_regceb       ),  // input wire regceb
//  	.addrb (w_dft_coef_adrs         ),  // input wire [16 : 0] addrb
//  	.doutb (w_dft_coef_flt26_im_dout)   // output wire [* : 0] doutb
//  );
//  
//  //
//  assign  w_dft_coef_flt32_re_dout =  {w_dft_coef_flt26_re_dout,6'b0};
//  assign  w_dft_coef_flt32_im_dout =  {w_dft_coef_flt26_im_dout,6'b0};

//}






//}


////---- calculate ----////

//// convert adc data int18 into single prcs flt32 : call floating_point_int32_sgflt_0 //{
//   note ... floating_point_int18_flt32_0 ip is also possible!!
//reg         r_adc_int_flt_conv = 1'b0;
//

wire [17:0] w_adc_data_int18_dout0 = i_adc_data_int18_dout0;
wire [17:0] w_adc_data_int18_dout1 = i_adc_data_int18_dout1;

wire [31:0] w_adc_data_int32_dout0     = { {14{w_adc_data_int18_dout0[17]}}, w_adc_data_int18_dout0[17:0]};
wire [31:0] w_adc_data_int32_dout1     = { {14{w_adc_data_int18_dout1[17]}}, w_adc_data_int18_dout1[17:0]};
wire        w_adc_data_int32_dout0_vld = w_pulse_seq2; // r_adc_int_flt_conv; // input
wire        w_adc_data_int32_dout1_vld = w_pulse_seq2; // r_adc_int_flt_conv; // input
wire [31:0] w_adc_data_flt32_dout0     ;
wire [31:0] w_adc_data_flt32_dout1     ;
wire        w_adc_data_flt32_dout0_vld ; // output
wire        w_adc_data_flt32_dout1_vld ; // output
//
wire        w_adc_int_flt_conv         = w_pulse_seq2; // r_adc_int_flt_conv; //$$ not for latency 0
// ...

//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout0_inst (
	//.aclk                   (clk_fifo                   ),  // input wire aclk
	//.aclken                 (w_adc_int_flt_conv         ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout0_vld ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout0     ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout0_vld ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout0     )   // output wire [31 : 0] m_axis_result_tdata
);
//
floating_point_int32_sgflt_0  floating_point_int32_sgflt__dout1_inst (
	//.aclk                   (clk_fifo                    ),  // input wire aclk
	//.aclken                 (w_adc_int_flt_conv          ),  // input wire aclken
	.s_axis_a_tvalid        (w_adc_data_int32_dout1_vld  ),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata         (w_adc_data_int32_dout1      ),  // input wire [31 : 0] s_axis_a_tdata
	.m_axis_result_tvalid   (w_adc_data_flt32_dout1_vld  ),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata    (w_adc_data_flt32_dout1      )   // output wire [31 : 0] m_axis_result_tdata
);


// multiply adc and coef  // we can skip...
//wire [31:0] w_prd_calc_flt32_re_dout0;
//wire [31:0] w_prd_calc_flt32_im_dout0;
//wire [31:0] w_prd_calc_flt32_re_dout1;
//wire [31:0] w_prd_calc_flt32_im_dout1;
// ...

//}

//// accumulate the products for dft calcation : call floating_point_mult_add_0 //{
//   C = A*B+C
//   C : accumulator
//   A : adc data 
//   B : dft coef 

//reg         r_acc_clear = 1'b0;
//reg         r_acc_conv  = 1'b0;
//reg         r_acc_load  = 1'b0;


//// sample acc clear 
reg       r_acc_clear;
reg [1:0] r_smp_acc_clear;

always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_smp_acc_clear <= 2'b0;
		r_acc_clear     <= 1'b0;
		end 
	else begin
		r_smp_acc_clear <= {r_smp_acc_clear[0], i_acc_clear};
		r_acc_clear     <= (r_smp_acc_clear==2'b01)? 1'b1 : 1'b0;
		end

//// controls
wire w_acc_clear = r_acc_clear; // r_acc_clear; // input //$$ may be time-relaxed
wire w_acc_load  = w_pulse_seq4; // r_acc_load ; // input


//// math operation

reg  [31:0] r_acc_flt32_re_dout0;
reg  [31:0] r_acc_flt32_im_dout0;
reg  [31:0] r_acc_flt32_re_dout1;
reg  [31:0] r_acc_flt32_im_dout1;
//
wire [31:0] w_acc_flt32_re_dout0 = r_acc_flt32_re_dout0;
wire [31:0] w_acc_flt32_im_dout0 = r_acc_flt32_im_dout0;
wire [31:0] w_acc_flt32_re_dout1 = r_acc_flt32_re_dout1;
wire [31:0] w_acc_flt32_im_dout1 = r_acc_flt32_im_dout1;
//
wire        w_acc_data_en              = w_pulse_seq3; // r_acc_conv; // input //$$ not for laterncy 0 case

wire        w_acc_flt32_re_dout0_a_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_a     = w_adc_data_flt32_dout0  ; // input
wire        w_acc_flt32_re_dout0_b_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_b     = w_dft_coef_flt32_re_dout; // input
wire        w_acc_flt32_re_dout0_c_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout0_c     = w_acc_flt32_re_dout0    ; // input
wire        w_acc_flt32_re_dout0_o_vld ; // output
wire [31:0] w_acc_flt32_re_dout0_o     ; // output

wire        w_acc_flt32_im_dout0_a_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_a     = w_adc_data_flt32_dout0  ; // input
wire        w_acc_flt32_im_dout0_b_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_b     = w_dft_coef_flt32_im_dout; // input
wire        w_acc_flt32_im_dout0_c_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout0_c     = w_acc_flt32_im_dout0    ; // input
wire        w_acc_flt32_im_dout0_o_vld ; // output
wire [31:0] w_acc_flt32_im_dout0_o     ; // output

wire        w_acc_flt32_re_dout1_a_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_a     = w_adc_data_flt32_dout1  ; // input
wire        w_acc_flt32_re_dout1_b_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_b     = w_dft_coef_flt32_re_dout; // input
wire        w_acc_flt32_re_dout1_c_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_re_dout1_c     = w_acc_flt32_re_dout1    ; // input
wire        w_acc_flt32_re_dout1_o_vld ; // output
wire [31:0] w_acc_flt32_re_dout1_o     ; // output

wire        w_acc_flt32_im_dout1_a_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_a     = w_adc_data_flt32_dout1  ; // input
wire        w_acc_flt32_im_dout1_b_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_b     = w_dft_coef_flt32_im_dout; // input
wire        w_acc_flt32_im_dout1_c_vld = w_pulse_seq3; // r_acc_conv              ; // input
wire [31:0] w_acc_flt32_im_dout1_c     = w_acc_flt32_im_dout1    ; // input
wire        w_acc_flt32_im_dout1_o_vld ; // output
wire [31:0] w_acc_flt32_im_dout1_o     ; // output


floating_point_mult_add_0  acc_flt32_re_dout0__inst (
	//.aclk                  (clk_fifo                  ),  // input wire aclk
	//.aclken                (w_acc_data_en             ),  // input wire aclken
	//.aresetn               (~w_acc_clear              ),  // input wire aresetn
	.s_axis_a_tvalid       (w_acc_flt32_re_dout0_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_re_dout0_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_re_dout0_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_re_dout0_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_re_dout0_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_re_dout0_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_re_dout0_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_re_dout0_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_im_dout0__inst (
	//.aclk                  (clk_fifo                  ),  // input wire aclk
	//.aclken                (w_acc_data_en             ),  // input wire aclken
	//.aresetn               (~w_acc_clear              ),  // input wire aresetn
	.s_axis_a_tvalid       (w_acc_flt32_im_dout0_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_im_dout0_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_im_dout0_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_im_dout0_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_im_dout0_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_im_dout0_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_im_dout0_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_im_dout0_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_re_dout1__inst (
	//.aclk                  (clk_fifo                  ),  // input wire aclk
	//.aclken                (w_acc_data_en             ),  // input wire aclken
	//.aresetn               (~w_acc_clear              ),  // input wire aresetn
	.s_axis_a_tvalid       (w_acc_flt32_re_dout1_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_re_dout1_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_re_dout1_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_re_dout1_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_re_dout1_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_re_dout1_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_re_dout1_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_re_dout1_o    )   // output wire [31 : 0] m_axis_result_tdata
);

floating_point_mult_add_0  acc_flt32_im_dout1__inst (
	//.aclk                  (clk_fifo                  ),  // input wire aclk
	//.aclken                (w_acc_data_en             ),  // input wire aclken
	//.aresetn               (~w_acc_clear              ),  // input wire aresetn
	.s_axis_a_tvalid       (w_acc_flt32_im_dout1_a_vld),  // input wire s_axis_a_tvalid
	.s_axis_a_tdata        (w_acc_flt32_im_dout1_a    ),  // input wire [31 : 0] s_axis_a_tdata
	.s_axis_b_tvalid       (w_acc_flt32_im_dout1_b_vld),  // input wire s_axis_b_tvalid
	.s_axis_b_tdata        (w_acc_flt32_im_dout1_b    ),  // input wire [31 : 0] s_axis_b_tdata
	.s_axis_c_tvalid       (w_acc_flt32_im_dout1_c_vld),  // input wire s_axis_c_tvalid
	.s_axis_c_tdata        (w_acc_flt32_im_dout1_c    ),  // input wire [31 : 0] s_axis_c_tdata
	.m_axis_result_tvalid  (w_acc_flt32_im_dout1_o_vld),  // output wire m_axis_result_tvalid
	.m_axis_result_tdata   (w_acc_flt32_im_dout1_o    )   // output wire [31 : 0] m_axis_result_tdata
);



//// final acc reg update
always @(posedge clk_fifo, negedge reset_n)
	if (!reset_n) begin
		r_acc_flt32_re_dout0 <= 32'b0;
		r_acc_flt32_im_dout0 <= 32'b0;
		r_acc_flt32_re_dout1 <= 32'b0;
		r_acc_flt32_im_dout1 <= 32'b0;
		end 
	else begin
		if (w_acc_clear) begin
			r_acc_flt32_re_dout0 <= 32'b0;
			r_acc_flt32_im_dout0 <= 32'b0;
			r_acc_flt32_re_dout1 <= 32'b0;
			r_acc_flt32_im_dout1 <= 32'b0;
			end
		else if (w_acc_load) begin //$$  & w_acc_flt32_im_dout1_o_vld
			r_acc_flt32_re_dout0 <= w_acc_flt32_re_dout0_o;
			r_acc_flt32_im_dout0 <= w_acc_flt32_im_dout0_o;
			r_acc_flt32_re_dout1 <= w_acc_flt32_re_dout1_o;
			r_acc_flt32_im_dout1 <= w_acc_flt32_im_dout1_o;
			end
		end


//}

//// acc output //{
assign o_acc_flt32_re_dout0 = r_acc_flt32_re_dout0; //
assign o_acc_flt32_im_dout0 = r_acc_flt32_im_dout0; //
assign o_acc_flt32_re_dout1 = r_acc_flt32_re_dout1; //
assign o_acc_flt32_im_dout1 = r_acc_flt32_im_dout1; //
//}

//// o_pulse_monitor //{
//assign o_pulse_monitor = w_pulse_seq4 & w_acc_flt32_im_dout1_o_vld; 
assign o_pulse_monitor = w_pulse_seq4; 

//}

//
endmodule

//}

