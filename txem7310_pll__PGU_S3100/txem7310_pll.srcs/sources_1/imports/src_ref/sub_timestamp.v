/* submodule: time stamp */ //{
module sub_timestamp (
	input wire clk    , // system 10MHz 
	input wire reset_n,
	//
	output wire [31:0] o_timestamp, // 
	//
	// flag
	output wire valid
	);

// valid
(* keep = "true" *) 
reg r_valid; //{
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
	
// global time index in debugger based on 10MHz
(* keep = "true" *) 
reg [31:0] r_global_time_idx; //{
//
always @(posedge clk, negedge reset_n) begin
	if (!reset_n) begin
		r_global_time_idx <= 32'd0; 
	end
	else begin
		//
		r_global_time_idx <= r_global_time_idx + 1;
		//
		end
end
//
assign o_timestamp = r_global_time_idx;
//}

endmodule 
//}
