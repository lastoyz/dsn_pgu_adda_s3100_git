//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 17:25:21
// Design Name: 
// Module Name: led_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module led_test (
	input wire clk    , // system 10MHz 
	input wire reset_n,
	//
	output wire o_run_led, // 
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
	
//// global time index in debugger based on 10MHz
//(* keep = "true" *) 
//reg [31:0] r_global_time_idx; //{
////
//always @(posedge clk, negedge reset_n) begin
//	if (!reset_n) begin
//		r_global_time_idx <= 32'd0; 
//	end
//	else begin
//		//
//		r_global_time_idx <= r_global_time_idx + 1;
//		//
//		end
//end
////
//assign o_timestamp = r_global_time_idx;
////}

reg FPGA_LED_RUN_STATUS;
reg [23:0] FPGA_LED_RUN_cnt;

wire sys_clk = clk;

always @(posedge sys_clk, negedge reset_n)
begin
    if(reset_n == 1'b0) begin
        FPGA_LED_RUN_STATUS     <= 1'b0;
        FPGA_LED_RUN_cnt        <= {24{1'b0}};
    end else begin
        if(FPGA_LED_RUN_cnt < 24'd2500000) begin             // DEC 2,500,000
            FPGA_LED_RUN_STATUS     <= 1'b0;
            FPGA_LED_RUN_cnt        <= FPGA_LED_RUN_cnt + 1;
        end else if(FPGA_LED_RUN_cnt < 24'd5000000) begin    // DEC 5,000,000
            FPGA_LED_RUN_STATUS     <= 1'b1;
            FPGA_LED_RUN_cnt        <= FPGA_LED_RUN_cnt + 1;
        end else begin 
            FPGA_LED_RUN_STATUS     <= 1'b0;
            FPGA_LED_RUN_cnt        <= {24{1'b0}};
        end
    end
end

assign o_run_led = FPGA_LED_RUN_STATUS;

endmodule 
