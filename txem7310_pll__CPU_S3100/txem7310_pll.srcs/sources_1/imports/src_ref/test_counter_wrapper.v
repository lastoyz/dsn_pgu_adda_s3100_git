//------------------------------------------------------------------------
// test_counter_wrapper.v
//
//------------------------------------------------------------------------

//$$`default_nettype none

module test_counter_wrapper (
	input  wire sys_clk,
	input  wire reset_n,
	//
	output wire [7:0] o_test  ,
	output wire [7:0] o_count1,
	//
	input  wire reset1,
	input  wire disable1,
	//
	output wire o_count1eq00,
	output wire o_count1eq80,
	//
	output wire [7:0] o_count2,
	//
	output wire o_count2eqFF,
	//
	input  wire reset2    ,
	input  wire up2       ,
	input  wire down2     ,
	input  wire autocount2
);

// reg and wire //{
reg  [7:0] r_test;
reg  [31:0] div1;
reg         clk1div;
(* keep = "true" *)
reg  [7:0]  count1;
reg         count1eq00;
reg         count1eq80;

reg  [23:0] div2;
reg         clk2div;
(* keep = "true" *)
reg  [7:0]  count2;
reg         count2eqFF;

//}


// assign //{
assign o_test       = r_test;
assign o_count1     = count1;
assign o_count1eq00 = count1eq00;
assign o_count1eq80 = count1eq80;

assign o_count2     = count2;
assign o_count2eqFF = count2eqFF;

//}


// Counter #1 //{
// + Counting using a divided sysclk.
// + Reset sets the counter to 0.
// + Disable turns off the counter.
always @(posedge sys_clk, negedge reset_n) begin
	if (!reset_n) begin
		div1 <= 32'd0; 
		clk1div <= 1'b0;
		count1 <= 8'h00;
		count1eq00 <= 1'b0;
		count1eq80 <= 1'b0;
	end
	else begin
		//
		if (div1 == 32'h000000) begin
			// div1 <= 24'h400000;
			//div1 <= 32'h0BEBC200-1; // 0x0BEBC200 for 1sec @ 200MHz
			div1 <= 32'd010_000_000-1; // 1sec @ 10MHz
			clk1div <= 1'b1;
		end else begin
			div1 <= div1 - 1;
			clk1div <= 1'b0;
		end
		//
		if (clk1div == 1'b1) begin
			if (reset1 == 1'b1) begin
				count1 <= 8'h00;
			end else if (disable1 == 1'b0) begin
				count1 <= count1 + 8'd1;
			end
		end
		//
		if (count1 == 8'h00)
			count1eq00 <= 1'b1;
		else
			count1eq00 <= 1'b0;
		//
		if (count1 == 8'h80)
			count1eq80 <= 1'b1;
		else
			count1eq80 <= 1'b0;
		//
		end
end
//}


// Counter #2 //{
// + Reset, up, and down control counter.
// + If autocount is enabled, a divided sys_clk can also
//   upcount.
always @(posedge sys_clk, negedge reset_n) begin
	if (!reset_n) begin
		div2 <= 24'd0; 
		clk2div <= 1'b0;
		count2 <= 8'h00;
		r_test <= 8'h80;
		count2eqFF <= 1'b0;
		end
	else begin
		//
		if (div2 == 24'h000000) begin
			div2 <= 24'h100000;
			clk2div <= 1'b1;
		end else begin
			div2 <= div2 - 1;
			clk2div <= 1'b0;
		end
		//
		if (reset2 == 1'b1) begin
			count2 <= 8'h00;
			r_test <= 8'h80;
			end
		else if (up2 == 1'b1)
			count2 <= count2 + 8'd1;
		else if (down2 == 1'b1)
			count2 <= count2 - 1;
		else if ((autocount2 == 1'b1) && (clk2div == 1'b1)) begin 
			count2 <= count2 + 8'd1;
			//r_test <= {r_test[6:0], r_test[7]}; // circular left
			r_test <= {r_test[0], r_test[7:1]}; // circular right
			end
		//
		if (count2 == 8'hff)
			count2eqFF <= 1'b1;
		else
			count2eqFF <= 1'b0;
		//
		end
end
//}

endmodule