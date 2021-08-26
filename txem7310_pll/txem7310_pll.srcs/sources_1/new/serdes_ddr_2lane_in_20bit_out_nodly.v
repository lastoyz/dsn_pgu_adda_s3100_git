//------------------------------------------------------------------------
// serdes_ddr_2lane_in_20bit_out_nodly.v
//   DDR deserializer
//   
//
//------------------------------------------------------------------------
// IO 
//  	rst
//  	[1:0] i_data_s // = {odd, even}
//  	i_dclk
//  	[19:0] o_data_p
//  	o_dclk_div
//
//------------------------------------------------------------------------
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module serdes_ddr_2lane_in_20bit_out_nodly (  
	input wire rst,
	input wire [1:0] i_data_s,
	input wire i_dclk,
	output wire [19:0] o_data_p,
	output wire o_dclk_div, // remove
	input wire i_clk_wr_fifo, // fifo wr clock 
	output wire o_en_wr_fifo, // falling of dclk_div	
	output wire [31:0] o_cnt_fall_clk_div // count of falling of dclk_div
);

reg [4:0] r_shift_pos_0;
reg [4:0] r_shift_pos_1;
reg [4:0] r_shift_neg_0;
reg [4:0] r_shift_neg_1;

wire [1:0] w_data_s = i_data_s; 

always @(posedge i_dclk, posedge rst)
	if (rst) begin
		r_shift_pos_0 <= 5'b0;
		r_shift_pos_1 <= 5'b0;
		end
	else begin
		r_shift_pos_0 <= {r_shift_pos_0[3:0], w_data_s[0]};
		r_shift_pos_1 <= {r_shift_pos_1[3:0], w_data_s[1]};
	end

always @(negedge i_dclk, posedge rst)
	if (rst) begin
		r_shift_neg_0 <= 5'b0;
		r_shift_neg_1 <= 5'b0;
		end
	else begin
		r_shift_neg_0 <= {r_shift_neg_0[3:0], w_data_s[0]};
		r_shift_neg_1 <= {r_shift_neg_1[3:0], w_data_s[1]};
		end

////		
// BUFR generates the slow clock
wire clk_in = i_dclk;
wire clk_reset = rst;
wire clk_div;
BUFR #(
	.SIM_DEVICE("7SERIES"),
	.BUFR_DIVIDE("5"))
clkout_buf_inst(
	.O (clk_div),
	.CE(1'b1),
	.CLR(clk_reset),
	.I (clk_in)
);
//
assign o_dclk_div = clk_div;
//
////


// w_data_p
wire [19:0] w_data_p;
	//
	assign w_data_p[19] = r_shift_pos_1[4];
	assign w_data_p[17] = r_shift_neg_1[4];
	assign w_data_p[15] = r_shift_pos_1[3];
	assign w_data_p[13] = r_shift_neg_1[3];
	assign w_data_p[11] = r_shift_pos_1[2];
	assign w_data_p[ 9] = r_shift_neg_1[2];
	assign w_data_p[ 7] = r_shift_pos_1[1];
	assign w_data_p[ 5] = r_shift_neg_1[1];
	assign w_data_p[ 3] = r_shift_pos_1[0];
	assign w_data_p[ 1] = r_shift_neg_1[0];
	//
	assign w_data_p[18] = r_shift_pos_0[4];
	assign w_data_p[16] = r_shift_neg_0[4];
	assign w_data_p[14] = r_shift_pos_0[3];
	assign w_data_p[12] = r_shift_neg_0[3];
	assign w_data_p[10] = r_shift_pos_0[2];
	assign w_data_p[ 8] = r_shift_neg_0[2];
	assign w_data_p[ 6] = r_shift_pos_0[1];
	assign w_data_p[ 4] = r_shift_neg_0[1];
	assign w_data_p[ 2] = r_shift_pos_0[0];
	assign w_data_p[ 0] = r_shift_neg_0[0];
	//

// r_data_p
reg [19:0] r_data_p;
//reg [19:0] r_data_p_smp; // delay
reg [19:0] r_data_p_dco_p;
//reg [19:0] r_data_p_dco_n;
reg [19:0] r_data_p_dco_p_smp;
reg [19:0] r_data_p_dco_p_smpp;
//
wire w_dclk_div = clk_div; //
//
always @(posedge i_dclk, posedge rst)
	if (rst) begin
		r_data_p_dco_p <= 20'b0;
		r_data_p_dco_p_smp <= 20'b0;
		r_data_p_dco_p_smpp <= 20'b0;
	end
	else begin
		r_data_p_dco_p <= w_data_p;
		if (w_dclk_div) begin
		  r_data_p_dco_p_smp <= r_data_p_dco_p;
		  r_data_p_dco_p_smpp <= r_data_p_dco_p_smp;
		  end 
		end
//
//$$always @(negedge i_dclk, posedge rst)
//$$	if (rst) begin
//$$		r_data_p_dco_n <= 20'b0;
//$$	end
//$$	else begin
//$$		r_data_p_dco_n <= w_data_p;
//$$		end
//
//$$always @(posedge w_dclk_div, posedge rst)
//$$	if (rst) begin
//$$		r_data_p_smp <= 20'b0;
//$$		r_data_p <= 20'b0;
//$$	end
//$$	else begin
//$$		r_data_p_smp <= w_data_p;
//$$		//$$r_data_p <= r_data_p_smp;
//$$		r_data_p <= r_data_p_dco_p_smpp;
//$$		end
//

always @(negedge i_clk_wr_fifo, posedge rst)
	if (rst) begin
		r_data_p <= 20'b0;
	end
	else begin
		r_data_p <= r_data_p_dco_p_smpp;
		end


// o_data_p
assign o_data_p = r_data_p;
//assign o_data_p = r_data_p_dco_p_smpp;


////
// fifo wr enable signal : falling of clk_div
//
wire w_clk_div_serdes = clk_div; 
reg [1:0] smp_clk_div_serdes;
(* keep = "true" *) wire en_wr_fifo;
(* keep = "true" *) reg [31:0] cnt_fall_clk_div;
//
//
always @(posedge i_clk_wr_fifo, posedge rst)
	if (rst) begin
		smp_clk_div_serdes <= 2'b0;
		cnt_fall_clk_div <= 32'b0;
		end 
	else begin
		//
		smp_clk_div_serdes <= {smp_clk_div_serdes[0], w_clk_div_serdes}; // sampling
		//if (w_clk_div_serdes)
		//	smp_clk_div_serdes <= {smp_clk_div_serdes[0], 1'b1}; // sampling
		//else 
		//	smp_clk_div_serdes <= {smp_clk_div_serdes[0], 1'b0}; // sampling
		//
		if (en_wr_fifo)
			cnt_fall_clk_div <= cnt_fall_clk_div + 1;
		//
		end
//
assign en_wr_fifo = smp_clk_div_serdes[1] & ~smp_clk_div_serdes[0];
assign o_en_wr_fifo = en_wr_fifo;
assign o_cnt_fall_clk_div = cnt_fall_clk_div;
//
////


endmodule
