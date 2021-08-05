//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/15 10:25:21
// Design Name: 
// Module Name: address_decode
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

module address_decode (
	input wire clk,
	input wire reset_n,
	
	input wire [25:20] BA25_20,
	input wire [19:18] BA19_18,
	input wire [ 7: 2] BA7_2,
	
	input wire nCS1,
	input wire nCS2,
	input wire nCS3,
	input wire nCS4,
	
	input wire nOE,
	input wire nWE,
	
	output wire [13:0] o_nBCS, // 
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

//---------------------------------------------------------------------------------------------//
wire [25:20] w_BA25_20;		// 6 bits
wire [19:18] w_BA19_18;		// 2 bits
wire [ 7: 2] w_BA7_2;		// 6 bits

assign w_BA25_20 = BA25_20;
assign w_BA19_18 = BA19_18;
assign w_BA7_2   = BA7_2;

wire w_nCS1;

assign w_nCS1 = nCS1;

reg [13:0] r_nFCS;			// 14 bits  //{

always@(negedge reset_n)
begin
    if(reset_n == 1'b0) begin
				 //14'b11 1111 1111 1111
		r_nFCS	<= {14{1'b1}};
	end else begin
		if(w_nCS1 == 1'b0) begin
			case (w_BA25_20)
				6'b00_0000 : r_nFCS <= 14'b11_1111_1111_1110;	//(0)  nCS_FPGA_sig         Don't Used	
			//	6'b00_0000 : r_nFCS[0] <= 1'b0;	                //(0)  nCS_FPGA_sig         Don't Used
				
				6'b00_0001 : r_nFCS <= 14'b11_1111_1111_1101;	//(1)  nCS_REG_sig			0x6010 0000 ~ 0x6010 007C
				6'b00_0010 : r_nFCS <= 14'b11_1111_1111_1011;	//(2)  nCS_USB_sig			0x6020 0000 ~ 
				6'b00_0011 : r_nFCS <= 14'b11_1111_1111_0111;	//(3)  nCS_GPIB_sig			0x6030 0000 ~ 0x6030 0008
				6'b00_0100 : r_nFCS <= 14'b11_1111_1110_1111;	//(4)  GPIB_nCS_sig			0x6040 0000 ~
				6'b00_0101 : r_nFCS <= 14'b11_1111_1101_1111;	//(5)  SUB_nCS_sig			0x6050 0000 ~
				6'b00_0110 : r_nFCS <= 14'b11_1111_1011_1111;	//(6)  SPI_CS_CONTROL_CS	0x6060 0000 ~ 0x6060 0014
				6'b00_0111 : r_nFCS <= 14'b11_1111_0111_1111;	//(7)  Mx_SPI_TRX_CONFIG_CS 0x6070 0000 ~ 0x6070 0010 
				6'b00_1000 : r_nFCS <= 14'b11_1110_1111_1111;	//(8)  Reserved				0x6080 0000 ~
				6'b00_1001 : r_nFCS <= 14'b11_1101_1111_1111;	//(9)  Reserved				0x6090 0000 ~
				6'b00_1010 : r_nFCS <= 14'b11_1011_1111_1111;	//(10) Trig_CONFIG_CS 		0x60A0 0000 ~ 0x60A0 0008 
				6'b00_1011 : r_nFCS <= 14'b11_0111_1111_1111;	//(11) Reserved				0x60B0 0000 ~
				6'b00_1100 : r_nFCS <= 14'b10_1111_1111_1111;	//(12) Reserved				0x60C0 0000 ~
				6'b00_1101 : r_nFCS <= 14'b01_1111_1111_1111;	//(13) Reserved				0x60D0 0000 ~
				default : r_nFCS <= {14{1'b1}};
			endcase
		end else begin
			r_nFCS	<= {14{1'b1}};
		end
	end
end

//always@(w_BA25_20)
//        case (w_BA25_20)
//            6'b00_0000 : r_nFCS <= 14'b1_1111_1111_1110;	//(0)  nCS_FPGA_sig	        Don't Used			
//            6'b00_0001 : r_nFCS <= 14'b1_1111_1111_1101;	//(1)  nCS_REG_sig			0x6010 0000 ~ 0x6010 007C
//            6'b00_0010 : r_nFCS <= 14'b1_1111_1111_1011;	//(2)  nCS_USB_sig			0x6020 0000 ~ 
//            6'b00_0011 : r_nFCS <= 14'b1_1111_1111_0111;	//(3)  nCS_GPIB_sig			0x6030 0000 ~ 0x6030 0008
//            // ...							  1110			//(4)  SUB_nCS_sig			0x6040 0000 ~
//            // ...							  1101			//(5)  Reserved				0x6050 0000 ~
//            6'b00_0110 : r_nFCS <= 14'b1_1111_1011_1111;	//(6)  SPI_CS_CONTROL_CS	0x6060 0000 ~ 0x6060 0014
//            6'b00_0111 : r_nFCS <= 14'b1_1111_0111_1111;	//(7)  Mx_SPI_TRX_CONFIG_CS 0x6070 0000 ~ 0x6070 0010 
//            6'b00_1000 : r_nFCS <= 14'b1_1110_1111_1111;	//(8)  Reserved				0x6080 0000 ~
//            6'b00_1001 : r_nFCS <= 14'b1_1101_1111_1111;	//(9)  Reserved				0x6090 0000 ~
//            6'b00_1010 : r_nFCS <= 14'b1_1011_0111_1111;	//(10) Trig_CONFIG_CS 		0x60A0 0000 ~ 0x60A0 0008 
//            // ...											//(11) Reserved				0x60B0 0000 ~
//            // ...											//(12) Reserved				0x60C0 0000 ~
//            // ...											//(13) Reserved				0x60D0 0000 ~
//            default : r_nFCS <= {14{1'b1}};
//        endcase


assign	o_nBCS = r_nFCS;

//}

/*
reg FPGA_LED_RUN_STATUS_F;
reg [23:0] FPGA_LED_RUN_cnt_F;

always @(posedge sys_clk, negedge reset_n)
begin
    if(reset_n == 1'b0) begin
        FPGA_LED_RUN_STATUS_F     <= 1'b0;
        FPGA_LED_RUN_cnt_F        <= {24{1'b0}};
    end else begin
        if(FPGA_LED_RUN_cnt_F < 24'd250000) begin             // DEC 250,000
            FPGA_LED_RUN_STATUS_F     <= 1'b0;
            FPGA_LED_RUN_cnt_F        <= FPGA_LED_RUN_cnt_F + 1;
        end else if(FPGA_LED_RUN_cnt_F < 24'd500000) begin    // DEC 500,000
            FPGA_LED_RUN_STATUS_F     <= 1'b1;
            FPGA_LED_RUN_cnt_F        <= FPGA_LED_RUN_cnt_F + 1;
        end else begin 
            FPGA_LED_RUN_STATUS_F     <= 1'b0;
            FPGA_LED_RUN_cnt_F        <= {24{1'b0}};
        end
    end
end

assign o_run_led_fast = FPGA_LED_RUN_STATUS_F;
*/

endmodule 

////

module tb_address_decode ();

endmodule