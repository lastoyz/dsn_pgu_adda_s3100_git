//------------------------------------------------------------------------
// master_drp_ug480.v
//
//   https://www.xilinx.com/support/documentation/user_guides/ug480_7Series_XADC.pdf
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module master_drp_ug480 (  //module ug480 (
	input DCLK, // Clock input for DRP
	input RESET,
	//input [3:0] VAUXP, VAUXN, // Auxiliary analog channel inputs
	input VP, VN,// Dedicated and Hardwired Analog Input Pair
	output wire [15:0] MEASURED_TEMP,
	output wire [15:0] MEASURED_VCCINT,
    output wire [15:0] MEASURED_VCCAUX,
	output wire [15:0] MEASURED_VCCBRAM,
	//
	output wire [31:0] MEASURED_TEMP_MC,	// converted value mC
	output wire [31:0] MEASURED_VCCINT_MV,	// converted value mV
    output wire [31:0] MEASURED_VCCAUX_MV,	// converted value mV
	output wire [31:0] MEASURED_VCCBRAM_MV,	// converted value mV
	//
	//output wire [15:0] MEASURED_AUX0,
	//output wire [15:0] MEASURED_AUX1,
    //output wire [15:0] MEASURED_AUX2,
	//output wire [15:0] MEASURED_AUX3,
	//output wire [7:0] ALM,
	output wire ALM_OUT,
	output wire [4:0] CHANNEL,
	output wire OT,
	output wire XADC_EOC,
	output wire XADC_EOS,
	//
	
	//
	output wire [7:0] debug_out
);

reg [15:0] r_MEASURED_TEMP;
reg [15:0] r_MEASURED_VCCINT;
reg [15:0] r_MEASURED_VCCAUX;
reg [15:0] r_MEASURED_VCCBRAM;
//
reg [31:0] r_MEASURED_TEMP_MC;
reg [31:0] r_MEASURED_VCCINT_MV;
reg [31:0] r_MEASURED_VCCAUX_MV;
reg [31:0] r_MEASURED_VCCBRAM_MV;
//
reg [31:0] r_MEASURED_TEMP_MC_smp;
reg [31:0] r_MEASURED_VCCINT_MV_smp;
reg [31:0] r_MEASURED_VCCAUX_MV_smp;
reg [31:0] r_MEASURED_VCCBRAM_MV_smp;
//
// reg [15:0] r_MEASURED_AUX0;
// reg [15:0] r_MEASURED_AUX1;
// reg [15:0] r_MEASURED_AUX2;
// reg [15:0] r_MEASURED_AUX3;

reg [15:0] r_REG40;
 
wire busy;
//$$wire [5:0] channel;
wire drdy;
reg [6:0] daddr;
reg [15:0] di_drp;
wire [15:0] do_drp;
//wire [15:0] vauxp_active;
//wire [15:0] vauxn_active;
reg [1:0] den_reg;
reg [1:0] dwe_reg;

reg [7:0] r_cnt_drdy;
parameter 	MAX_CNT_DRDY	= 8'd100; // wait count for drdy

//
parameter 	INIT_READ 		= 8'h00;
parameter 	READ_WAITDRDY 	= 8'h01;
parameter 	INIT_WRITE		= 8'h02;
parameter	WRITE_WAITDRDY 	= 8'h03;
parameter	READ_REG00 		= 8'h04; // Temperature
parameter	REG00_WAITDRDY 	= 8'h05;
parameter	READ_REG01 		= 8'h06; // VCCINT
parameter	REG01_WAITDRDY 	= 8'h07;
parameter	READ_REG02	 	= 8'h08; // VCCAUX
parameter	REG02_WAITDRDY 	= 8'h09;
parameter	READ_REG06 		= 8'h0a; // VCCBRAM
parameter	REG06_WAITDRDY 	= 8'h0b;
// parameter	READ_REG10 		= 8'h0c; // VAUXP[0]/VAUXN[0] 
// parameter	REG10_WAITDRDY 	= 8'h0d;
// parameter	READ_REG11 		= 8'h0e; // VAUXP[1]/VAUXN[1] 
// parameter	REG11_WAITDRDY 	= 8'h0f;
// parameter	READ_REG12 		= 8'h10; // VAUXP[2]/VAUXN[2] 
// parameter	REG12_WAITDRDY 	= 8'h11;
// parameter	READ_REG13 		= 8'h12; // VAUXP[3]/VAUXN[3] 
// parameter	REG13_WAITDRDY 	= 8'h13;
parameter 	SEQ_START 		= 8'hfd; // start of seq
parameter 	SEQ_END 		= 8'hfe; // end of seq
parameter 	INIT_STATE 		= 8'hff; // reset state

reg [7:0] state; //  = INIT_READ;
wire eos, eoc;

//
assign debug_out = state;


			
always @(posedge DCLK, posedge RESET)
	if (RESET) begin
		state <= INIT_STATE;
		daddr <= 7'h00; 
		den_reg <= 2'h0;
		dwe_reg <= 2'h0;
		di_drp <= 16'h0000;
		r_REG40 <= 16'h0000;
		r_MEASURED_TEMP <= 16'h0000;
        r_MEASURED_VCCINT <= 16'h0000;
        r_MEASURED_VCCAUX <= 16'h0000;
        r_MEASURED_VCCBRAM <= 16'h0000;
        r_cnt_drdy <= 8'd0;
        end 
	else case (state)
		// wait for stable state ... may need more times.
		INIT_STATE : begin
			daddr <= 7'h00; 
			if (busy == 0 ) state <= INIT_READ; // wait for ADC not busy
			end
		// configurate ADC
		INIT_READ : begin
			daddr <= 7'h40; // 0x40
			den_reg <= 2'h2; // performing read
			r_cnt_drdy <= MAX_CNT_DRDY;
			if (busy == 0 ) state <= READ_WAITDRDY; // wait for ADC not busy
			end
		READ_WAITDRDY : if (drdy ==1) begin // wait for read data...
			r_REG40 <= do_drp; // read  Configreg0
			state <= INIT_WRITE;
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			//
			r_cnt_drdy <= r_cnt_drdy - 1;
			if (r_cnt_drdy == 0) state <= INIT_STATE; // drdy missing
			end 
		INIT_WRITE : begin
			daddr <= 7'h40; // 0x40
			di_drp <= r_REG40 & 16'h03_FF; //Clearing AVG bits for Configreg0 read
			dwe_reg <= 2'h2; // performing write
			den_reg <= 2'h2; // fake read trigger for next drdy
			r_cnt_drdy <= MAX_CNT_DRDY;			
			if (busy == 0 ) state <= WRITE_WAITDRDY; // wait for ADC not busy
			end
		WRITE_WAITDRDY : if (drdy ==1) begin
			state <= READ_REG00;
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			//
			r_cnt_drdy <= r_cnt_drdy - 1;
			if (r_cnt_drdy == 0) state <= INIT_STATE; // drdy missing 
			end
		// start seq
		SEQ_START : begin
			daddr <= 7'h00;
			if (eos == 1) state <= READ_REG00; // wait for start of seq
			end
		READ_REG00 : begin
			daddr <= 7'h00;
			den_reg <= 2'h2; // performing read
			state <= REG00_WAITDRDY;
			end
		REG00_WAITDRDY : if (drdy ==1) begin
			r_MEASURED_TEMP <= do_drp;
			state <= READ_REG01;
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			state <= state;
			end
		READ_REG01 : begin
			daddr <= 7'h01;
			den_reg <= 2'h2; // performing read
			state <= REG01_WAITDRDY;
			end
		REG01_WAITDRDY : if (drdy ==1) begin
			r_MEASURED_VCCINT <= do_drp;
			state <= READ_REG02;
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			state <= state;
			end
		READ_REG02 : begin
			daddr <= 7'h02;
			den_reg <= 2'h2; // performing read
			state <= REG02_WAITDRDY;
			end
		REG02_WAITDRDY : if (drdy ==1) begin
			r_MEASURED_VCCAUX <= do_drp;
			state <= READ_REG06;
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			state <= state;
			end
		READ_REG06 : begin
			daddr <= 7'h06;
			den_reg <= 2'h2; // performing read
			state <= REG06_WAITDRDY;
			end
		REG06_WAITDRDY : if (drdy ==1) begin
			r_MEASURED_VCCBRAM <= do_drp;
			//state <= READ_REG10;
			state <= SEQ_END; // go to end of seq 
			end else begin
			den_reg <= { 1'b0, den_reg[1] } ;
			dwe_reg <= { 1'b0, dwe_reg[1] } ;
			state <= state;
			end
		// READ_REG10 : begin
			// daddr <= 7'h10;
			// den_reg <= 2'h2; // performing read
			// state <= REG10_WAITDRDY;
			// end
		// REG10_WAITDRDY :
			// if (drdy ==1) begin
			// r_MEASURED_AUX0 <= do_drp;
			// state <= READ_REG11;
			// end else begin
			// den_reg <= { 1'b0, den_reg[1] } ;
			// dwe_reg <= { 1'b0, dwe_reg[1] } ;
			// state <= state;
			// end
		// READ_REG11 : begin
			// daddr <= 7'h11;
			// den_reg <= 2'h2; // performing read
			// state <= REG11_WAITDRDY;
			// end
		// REG11_WAITDRDY :
			// if (drdy ==1) begin
			// r_MEASURED_AUX1 <= do_drp;
			// state <= READ_REG12;
			// end else begin
			// den_reg <= { 1'b0, den_reg[1] } ;
			// dwe_reg <= { 1'b0, dwe_reg[1] } ;
			// state <= state;
			// end
		// READ_REG12 : begin
			// daddr <= 7'h12;
			// den_reg <= 2'h2; // performing read
			// state <= REG12_WAITDRDY;
			// end
		// REG12_WAITDRDY :
			// if (drdy ==1) begin
			// r_MEASURED_AUX2 <= do_drp;
			// state <= READ_REG13;
			// end else begin
			// den_reg <= { 1'b0, den_reg[1] } ;
			// dwe_reg <= { 1'b0, dwe_reg[1] } ;
			// state <= state;
			// end
		// READ_REG13 : begin
			// daddr <= 7'h13;
			// den_reg <= 2'h2; // performing read
			// state <= REG13_WAITDRDY;
			// end
		// REG13_WAITDRDY :
			// if (drdy ==1) begin
			// r_MEASURED_AUX3 <= do_drp;
			// state <= SEQ_END;
			// end else begin
			// den_reg <= { 1'b0, den_reg[1] } ;
			// dwe_reg <= { 1'b0, dwe_reg[1] } ;
			// state <= state;
			// end
		SEQ_END : begin
			daddr <= 7'h00; 	// just seq done notice
			state <= SEQ_START; // return to start of seq
			end
		default  : 
			state <= INIT_STATE;
	endcase
 
// xadc_wiz_0
xadc_wiz_0 xadc_wiz_0_inst (
	.daddr_in		(daddr),		// Address bus for the dynamic reconfiguration port
	.dclk_in		(DCLK),     	// Clock input for the dynamic reconfiguration port
	.den_in			(den_reg[0]),   // Enable Signal for the dynamic reconfiguration port
	.di_in			(di_drp),     	// Input data bus for the dynamic reconfiguration port
	.dwe_in			(dwe_reg[0]),   // Write Enable for the dynamic reconfiguration port
	.reset_in		(RESET),     // Reset signal for the System Monitor control logic
	//
	.busy_out		(busy),     // ADC Busy signal
	.channel_out	(CHANNEL),  // Channel Selection Outputs
	.do_out			(do_drp),   // Output data bus for dynamic reconfiguration port
	.drdy_out		(drdy),     // Data ready signal for the dynamic reconfiguration port
	.eoc_out		(eoc),     	// End of Conversion Signal
	.eos_out		(eos),     	// End of Sequence Signal
	.ot_out			(OT),         // Over-Temperature alarm output
	.alarm_out		(ALM_OUT),  // OR'ed output of all the Alarms    
	.vp_in			(VP),     	// Dedicated Analog Input Pair
	.vn_in			(VN)
);
 

//assign vauxp_active = {12'h000, VAUXP[3:0]};
//assign vauxn_active = {12'h000, VAUXN[3:0]};
assign XADC_EOC = eoc;
assign XADC_EOS = eos;

assign MEASURED_TEMP = r_MEASURED_TEMP;
assign MEASURED_VCCINT = r_MEASURED_VCCINT;
assign MEASURED_VCCAUX = r_MEASURED_VCCAUX;
assign MEASURED_VCCBRAM = r_MEASURED_VCCBRAM;
//
assign MEASURED_TEMP_MC = r_MEASURED_TEMP_MC;
assign MEASURED_VCCINT_MV = r_MEASURED_VCCINT_MV;
assign MEASURED_VCCAUX_MV = r_MEASURED_VCCAUX_MV;
assign MEASURED_VCCBRAM_MV = r_MEASURED_VCCBRAM_MV;
//
// assign MEASURED_AUX0 = r_MEASURED_AUX0;
// assign MEASURED_AUX1 = r_MEASURED_AUX1;
// assign MEASURED_AUX2 = r_MEASURED_AUX2;
// assign MEASURED_AUX3 = r_MEASURED_AUX3;


//$$ converted to decimal * 10^3
// transform
// (ADC_TEMP * 15749 - 559411200 ) /2^11 = temp C /1000
// (ADC_PWR * 3001) / 2^16 = mV
/* 	- temp conversion
		(ADC Code * 503.975) / 4096 - 273.15
		(0xA340/16 * 503.975) / 4096 - 273.15 = 48.232
		*10^-3_C ... (ADC/16 * 503975) / 4096 - 273150
					  (ADC * 503975 * 2^11 /16 / 4096 - 273150*2^11 ) /2^11
					  = (ADC * 15749.21875 - 559411200 ) /2^11
					  ~ (ADC_TEMP * 15749 - 559411200 ) /2^11
					  ...
					  (0xA340 * 15749 - 559411200 ) /2^11 = 48228.03125
	- ADC conversion 
		((0.2V?„ 1.0V) Ã— FFFh) = 819 or 333h
	- Power Supply Sensors conversion
		1V / 3V x 4096 = 1365 = 555h
		0x561D/16 / 0xFFF * 3 = 1.009
		mV ... ADC /16 /0xFFF * 3 * 1000 
			   3000/16/0xfff * 2^16 = 3000.73260073
			   (ADC * 3000.73260073) / 2^16
			   ~ (ADC_PWR * 3001) / 2^16
			   ...
			   ( 0x561D * 3001 ) / 2^16 = 1009.47639465 
*/
			   
always @(posedge DCLK, posedge RESET)
	if (RESET) begin
		r_MEASURED_TEMP_MC		<= 32'b0;
		r_MEASURED_VCCINT_MV	<= 32'b0;
		r_MEASURED_VCCAUX_MV	<= 32'b0;
		r_MEASURED_VCCBRAM_MV	<= 32'b0;
		r_MEASURED_TEMP_MC_smp		<= 32'b0;
		r_MEASURED_VCCINT_MV_smp	<= 32'b0;
		r_MEASURED_VCCAUX_MV_smp	<= 32'b0;
		r_MEASURED_VCCBRAM_MV_smp	<= 32'b0;
		end 
	else begin
		r_MEASURED_TEMP_MC_smp 		<= (32'd015749 * r_MEASURED_TEMP - 32'd0559411200 );
		r_MEASURED_VCCINT_MV_smp 	<= (32'd003001 * r_MEASURED_VCCINT);
		r_MEASURED_VCCAUX_MV_smp 	<= (32'd003001 * r_MEASURED_VCCAUX);
		r_MEASURED_VCCBRAM_MV_smp 	<= (32'd003001 * r_MEASURED_VCCBRAM);
		r_MEASURED_TEMP_MC 		<= (r_MEASURED_TEMP_MC_smp   )>>11;
		r_MEASURED_VCCINT_MV 	<= (r_MEASURED_VCCINT_MV_smp )>>16;
		r_MEASURED_VCCAUX_MV 	<= (r_MEASURED_VCCAUX_MV_smp )>>16;
		r_MEASURED_VCCBRAM_MV 	<= (r_MEASURED_VCCBRAM_MV_smp)>>16;
		end

//$$mult_gen_A_mul_B_0 your_instance_name (
//$$  .CLK(CLK),  // input wire CLK
//$$  .A(A),      // input wire [15 : 0] A
//$$  .B(B),      // input wire [15 : 0] B
//$$  .P(P)      // output wire [31 : 0] P
//$$);
	
endmodule