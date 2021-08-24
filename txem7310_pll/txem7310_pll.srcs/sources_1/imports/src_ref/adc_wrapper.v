//------------------------------------------------------------------------
// adc_wrapper.v
//



`timescale 1ns / 1ps
//$$`default_nettype none



//// TODO: submodule adc_wrapper //{

//  
//  module sub_wire_in ( //{
//  	input  wire          reset_n         ,
//  	input  wire          host_clk        , 
//  	input  wire [31 : 0] i_ADRS_BUS      ,
//  	input  wire          i_rise_WE_BUS   ,
//  	input  wire [31 : 0] i_epXX_hadrs    ,
//  	input  wire [31 : 0] i_ep_offs_hadrs ,
//  	input  wire [15 : 0] i_DATA_WR       ,
//  	output wire [31 : 0] o_epXXwire      
//  ); 
//  reg  [31:0] r_epXXwire; //{
//  
//  assign o_epXXwire = r_epXXwire;
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXwire <= 32'b0;
//  	end
//  	else begin
//  		r_epXXwire[15: 0] <= ( i_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? i_DATA_WR : r_epXXwire[15: 0];
//  		r_epXXwire[31:16] <= ( i_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + i_ep_offs_hadrs) )? i_DATA_WR : r_epXXwire[31:16];
//  		//
//  	end
//  end
//  
//  //}
//  endmodule //}
//  
//  module sub_trig_in ( //{
//  	input  wire          reset_n         ,
//  	input  wire          host_clk        , 
//  	input  wire [31 : 0] i_ADRS_BUS      ,
//  	input  wire          i_rise_WE_BUS   , // for setting trig
//  	input  wire [31 : 0] i_epXX_hadrs    ,
//  	input  wire [31 : 0] i_ep_offs_hadrs ,
//  	input  wire [15 : 0] i_DATA_WR       ,
//  	input  wire          i_epXXck        ,
//  	output wire [31 : 0] o_epXXtrig      
//  );
//  
//  // * timing : host_clk fast case
//  //   host_clk                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   r_epXXtrig    @host_clk  _____------_______________________________
//  //   i_epXXck                 ___---___---___---___---___---___---___---
//  //   r_epXXtrig_ck @i_epXXck  _________------___________________________
//  //   o_epXXtrig               _______________------_____________________
//  //
//  // * timing : host_clk slow case (NG)
//  //   host_clk                 ___---___---___---___---___---___---___---
//  //   r_epXXtrig    @host_clk  _________------___________________________
//  //   i_epXXck                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   r_epXXtrig_ck @i_epXXck  ___________--_____________________________
//  //   o_epXXtrig               _____________--___________________________
//  //
//  // * timing : host_clk slow case with handshake
//  //   host_clk                 ___---___---___---___---___---___---___---
//  //   r_epXXtrig    @host_clk  _________------___________________________
//  //   i_epXXck                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   r_epXXtrig_ck @i_epXXck  ___________------_________________________
//  //   o_epXXtrig               _____________--___________________________
//  //
//  // * transition table
//  //   r_epXXtrig+    = r_epXXtrig,  ext_input,  r_epXXtrig_ck // r_epXXtrig <= (w_ext_input) | (r_epXXtrig & (~w_epXXtrig_ck)); 
//  //   0                0            0           0      
//  //   0                0            0           1      
//  //   1                0            1           0             // set
//  //   1                0            1           1             // set
//  //   1                1            0           0      
//  //   0                1            0           1             // clear
//  //   1                1            1           0             // set
//  //   1                1            1           1             // set
//  //
//  //   r_epXXtrig_ck+ = r_epXXtrig_ck,  r_epXXtrig // r_epXXtrig_ck <= r_epXXtrig; 
//  //   0                0               0          
//  //   1                0               1          // set
//  //   0                1               0          // clear
//  //   1                1               1          // set
//  
//  reg  [31:0] r_epXXtrig; //{
//  
//  wire [31:0] w_ext_input;
//  assign  w_ext_input[15: 0] = ( i_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? i_DATA_WR : 16'b0;
//  assign  w_ext_input[31:16] = ( i_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + i_ep_offs_hadrs) )? i_DATA_WR : 16'b0;
//  
//  wire [31:0] w_epXXtrig_ck;
//  
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXtrig <= 32'b0;
//  	end
//  	else begin
//  		r_epXXtrig <= (w_ext_input) | (r_epXXtrig & (~w_epXXtrig_ck)); 
//  		//
//  	end
//  end
//  
//  //}
//  
//  reg  [31:0] r_epXXtrig_ck; //{
//  
//  assign w_epXXtrig_ck = r_epXXtrig_ck;
//  
//  reg  [31:0] r_epXXtrig_ck_smp;
//  wire [31:0] w_rise_epXXtrig_ck = (~r_epXXtrig_ck_smp) & (r_epXXtrig_ck);
//  assign o_epXXtrig = w_rise_epXXtrig_ck;
//  
//  always @(posedge i_epXXck, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXtrig_ck     <= 32'b0;
//  		r_epXXtrig_ck_smp <= 32'b0;
//  	end
//  	else begin
//  		r_epXXtrig_ck     <= r_epXXtrig   ;
//  		r_epXXtrig_ck_smp <= r_epXXtrig_ck;
//  		//
//  	end
//  end
//  
//  //}
//  
//  endmodule //}
//  
//  module sub_trig_out ( //{
//  	input  wire          reset_n         ,
//  	input  wire          host_clk        , 
//  	input  wire [31 : 0] i_ADRS_BUS      ,
//  	input  wire          i_rise_OE_BUS   , // for clearing trig
//  	input  wire [31 : 0] i_epXX_hadrs    ,
//  	input  wire [31 : 0] i_ep_offs_hadrs ,
//  	input  wire          i_epXXck        ,
//  	input  wire [31 : 0] i_epXXtrig      ,
//  	output wire [31 : 0] o_epXXtrig      
//  );
//  
//  // * timing : host_clk fast case
//  //   host_clk                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   i_rise_OE_BUS            _______________________________--_________
//  //   r_epXXtrig    @host_clk  _______________________----------_________
//  //   i_epXXck                 ___---___---___---___---___---___---___---
//  //   r_epXXtrig_ck @i_epXXck  _____________________------_______________
//  //   i_epXXtrig               _______________------_____________________
//  //   o_epXXtrig               _______________________----------_________
//  //
//  // * timing : host_clk slow case (NG)
//  //   host_clk                 ___---___---___---___---___---___---___---
//  //   i_rise_OE_BUS            ___________________________------_________
//  //   r_epXXtrig    @host_clk  _____________________------------_________
//  //   i_epXXck                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   r_epXXtrig_ck @i_epXXck  _______________--_________________________
//  //   i_epXXtrig               _____________--___________________________
//  //   o_epXXtrig               _____________________------------_________
//  //
//  // * timing : host_clk slow case with handshake
//  //   host_clk                 ___---___---___---___---___---___---___---
//  //   i_rise_OE_BUS            ___________________________------_________
//  //   r_epXXtrig    @host_clk  _____________________------------_________
//  //   i_epXXck                 _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
//  //   r_epXXtrig_ck @i_epXXck  _______________--------___________________
//  //   i_epXXtrig               _____________--___________________________
//  //   o_epXXtrig               _____________________------------_________
//  //
//  // * transition table
//  //   r_epXXtrig+    = r_epXXtrig,  r_epXXtrig_ck , w_ext_input_clear // r_epXXtrig <= (r_epXXtrig_ck) | (r_epXXtrig & (~w_ext_input_clear)); 
//  //   0                0            0               0      
//  //   0                0            0               1      
//  //   1                0            1               0             // set
//  //   1                0            1               1             // set
//  //   1                1            0               0      
//  //   0                1            0               1             // clear
//  //   1                1            1               0             // set
//  //   1                1            1               1             // set
//  //
//  //   r_epXXtrig_ck+ = r_epXXtrig_ck,  i_epXXtrig,  r_epXXtrig    // r_epXXtrig_ck <= (i_epXXtrig) | (r_epXXtrig_ck & (~r_epXXtrig)); 
//  //   0                0               0            0      
//  //   0                0               0            1      
//  //   1                0               1            0             // set
//  //   1                0               1            1             // set
//  //   1                1               0            0      
//  //   0                1               0            1             // clear
//  //   1                1               1            0             // set
//  //   1                1               1            1             // set
//  
//  reg  [31:0] r_epXXtrig; //{
//  
//  assign o_epXXtrig = r_epXXtrig;
//  
//  wire [31:0] w_ext_input_clear;
//  assign  w_ext_input_clear[15: 0] = ( i_rise_OE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? 16'hFFFF : 16'b0;
//  assign  w_ext_input_clear[31:16] = ( i_rise_OE_BUS & (i_ADRS_BUS == i_epXX_hadrs + i_ep_offs_hadrs) )? 16'hFFFF : 16'b0;
//  
//  wire [31:0] w_epXXtrig_ck;
//  
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXtrig <= 32'b0;
//  	end
//  	else begin
//  		r_epXXtrig <= (w_epXXtrig_ck) | (r_epXXtrig & (~w_ext_input_clear)); 
//  		//
//  	end
//  end
//  
//  //}
//  
//  reg  [31:0] r_epXXtrig_ck; //{
//  
//  assign w_epXXtrig_ck = r_epXXtrig_ck;
//  
//  always @(posedge i_epXXck, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXtrig_ck     <= 32'b0;
//  	end
//  	else begin
//  		r_epXXtrig_ck     <= (i_epXXtrig) | (r_epXXtrig_ck & (~r_epXXtrig)); 
//  		//
//  	end
//  end
//  
//  //}
//  
//  endmodule //}
//  
//  module sub_pipe_in ( //{
//  	input  wire          reset_n         ,
//  	input  wire          host_clk        , 
//  	input  wire [31 : 0] i_ADRS_BUS      ,
//  	input  wire          i_rise_WE_BUS   , // for pipe control
//  	input  wire [31 : 0] i_epXX_hadrs    ,
//  	input  wire [31 : 0] i_ep_offs_hadrs ,
//  	input  wire [15 : 0] i_DATA_WR       ,
//  	output wire          o_epXXwr        ,
//  	output wire [31 : 0] o_epXXpipe      
//  );
//  
//  wire w_rise_WE_BUS = i_rise_WE_BUS;
//  
//  reg  [31:0] r_epXXpipe; //{
//  
//  assign o_epXXpipe = r_epXXpipe;
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXpipe <= 32'b0;
//  	end
//  	else begin
//  		r_epXXpipe[15: 0] <= ( w_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? i_DATA_WR : r_epXXpipe[15: 0];
//  		r_epXXpipe[31:16] <= ( w_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + i_ep_offs_hadrs) )? i_DATA_WR : r_epXXpipe[31:16];
//  		//
//  	end
//  end
//  //}
//  
//  reg  r_epXXwr; //{
//  
//  reg  r_epXXwr_smp;
//  assign o_epXXwr = r_epXXwr_smp;
//  
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXwr     <= 1'b0;
//  		r_epXXwr_smp <= 1'b0;
//  	end
//  	else begin
//  		r_epXXwr     <= ( w_rise_WE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? 1'b1 : 1'b0;
//  		r_epXXwr_smp <= r_epXXwr;
//  		//
//  	end
//  end
//  //}
//  
//  endmodule //}
//  
//  module sub_pipe_out ( //{
//  	input  wire          reset_n         ,
//  	input  wire          host_clk        , 
//  	input  wire [31 : 0] i_ADRS_BUS      ,
//  	input  wire          i_rise_OE_BUS   , // for pipe control
//  	input  wire [31 : 0] i_epXX_hadrs    ,
//  	input  wire [31 : 0] i_ep_offs_hadrs ,
//  	output wire          o_epXXrd        
//  );
//  
//  wire w_rise_OE_BUS = i_rise_OE_BUS;
//  
//  reg  r_epXXrd; //{
//  
//  reg  r_epXXrd_smp;
//  assign o_epXXrd = r_epXXrd_smp;
//  
//  always @(posedge host_clk, negedge reset_n) begin
//  	if (!reset_n) begin
//  		r_epXXrd     <= 1'b0;
//  		r_epXXrd_smp <= 1'b0;
//  	end
//  	else begin
//  		r_epXXrd     <= ( w_rise_OE_BUS & (i_ADRS_BUS == i_epXX_hadrs + 0              ) )? 1'b1 : 1'b0;
//  		r_epXXrd_smp <= r_epXXrd;
//  		//
//  	end
//  end
//  //}
//  
//  
//  
//  endmodule //}
//  
//  
//// main module

module adc_wrapper ( //{

	//// controls //{
	
	// for common 
	input  wire        clk     , // 10MHz
	input  wire        reset_n ,	
	
	// host core monitoring clock
	input  wire        host_clk, // 140MHz	(or less ... 104MHz possible)

	//// IO bus interface // async for arm io // STM32F767
	input  wire          i_FMC_NCE ,  // input  wire          // FMC_NCE
	input  wire [31 : 0] i_FMC_ADD ,  // input  wire [31 : 0] // FMC_ADD
	input  wire          i_FMC_NOE ,  // input  wire          // FMC_NOE
	output wire [15 : 0] o_FMC_DRD ,  // output wire [15 : 0] // FMC_DRD
	input  wire          i_FMC_NWE ,  // input  wire          // FMC_NWE
	input  wire [15 : 0] i_FMC_DWR ,  // input  wire [15 : 0] // FMC_DWR
	
	// IO buffer controls ...
	output wire [15 : 0] o_FMC_DRD_TRI ,  // output wire [15 : 0] // 1 for tri, 0 for output.

	//}

	//// end-point address offset between high and low 16 bits //{
	input wire [31:0] ep_offs_hadrs,  // 0x0000_0004 or 0x0000_0002
	//}

	//// wire-in //{
	input wire [31:0] ep00_hadrs, output wire [31:0] ep00wire,
	input wire [31:0] ep01_hadrs, output wire [31:0] ep01wire,
	input wire [31:0] ep02_hadrs, output wire [31:0] ep02wire,
	input wire [31:0] ep03_hadrs, output wire [31:0] ep03wire,
	input wire [31:0] ep04_hadrs, output wire [31:0] ep04wire,
	//
	input wire [31:0] ep12_hadrs, output wire [31:0] ep12wire,
	input wire [31:0] ep13_hadrs, output wire [31:0] ep13wire,
	//
	input wire [31:0] ep16_hadrs, output wire [31:0] ep16wire,
	input wire [31:0] ep17_hadrs, output wire [31:0] ep17wire,
	//
	input wire [31:0] ep1A_hadrs, output wire [31:0] ep1Awire,
	input wire [31:0] ep1B_hadrs, output wire [31:0] ep1Bwire,
	input wire [31:0] ep1C_hadrs, output wire [31:0] ep1Cwire,
	input wire [31:0] ep1D_hadrs, output wire [31:0] ep1Dwire,
	input wire [31:0] ep1E_hadrs, output wire [31:0] ep1Ewire,
	//}
	
	//// wire-out //{
	input wire [31:0] ep20_hadrs, input wire [31:0]  ep20wire,
	input wire [31:0] ep21_hadrs, input wire [31:0]  ep21wire,
	input wire [31:0] ep22_hadrs, input wire [31:0]  ep22wire,
	input wire [31:0] ep23_hadrs, input wire [31:0]  ep23wire,
	input wire [31:0] ep24_hadrs, input wire [31:0]  ep24wire,
	//
	input wire [31:0] ep30_hadrs, input wire [31:0]  ep30wire,
	input wire [31:0] ep31_hadrs, input wire [31:0]  ep31wire,
	input wire [31:0] ep32_hadrs, input wire [31:0]  ep32wire,
	input wire [31:0] ep33_hadrs, input wire [31:0]  ep33wire,
	input wire [31:0] ep34_hadrs, input wire [31:0]  ep34wire,
	input wire [31:0] ep35_hadrs, input wire [31:0]  ep35wire,
	input wire [31:0] ep36_hadrs, input wire [31:0]  ep36wire,
	input wire [31:0] ep37_hadrs, input wire [31:0]  ep37wire,
	input wire [31:0] ep38_hadrs, input wire [31:0]  ep38wire,
	input wire [31:0] ep39_hadrs, input wire [31:0]  ep39wire,
	input wire [31:0] ep3A_hadrs, input wire [31:0]  ep3Awire,
	input wire [31:0] ep3B_hadrs, input wire [31:0]  ep3Bwire,
	//}
	
	//// trig-in //{
	input wire [31:0] ep40_hadrs, input wire ep40ck, output wire [31:0] ep40trig,
	input wire [31:0] ep42_hadrs, input wire ep42ck, output wire [31:0] ep42trig,
	//
	input wire [31:0] ep50_hadrs, input wire ep50ck, output wire [31:0] ep50trig,
	input wire [31:0] ep51_hadrs, input wire ep51ck, output wire [31:0] ep51trig,
	input wire [31:0] ep52_hadrs, input wire ep52ck, output wire [31:0] ep52trig,
	input wire [31:0] ep53_hadrs, input wire ep53ck, output wire [31:0] ep53trig,
	//}
	
	//// trig-out //{
	input wire [31:0] ep60_hadrs, input wire ep60ck, input wire [31:0] ep60trig,
	input wire [31:0] ep62_hadrs, input wire ep62ck, input wire [31:0] ep62trig,
	input wire [31:0] ep73_hadrs, input wire ep73ck, input wire [31:0] ep73trig,
	//}
	
	//// pipe-in //{
	//input wire [31:0] ep80_hadrs, output wire ep80wr, output wire [31:0] ep80pipe,
	input wire [31:0] ep93_hadrs, output wire ep93wr, output wire [31:0] ep93pipe,
	//}
	
	//// pipe-out //{
	//input wire [31:0] epA0_hadrs, output wire epA0rd,  input wire [31:0] epA0pipe,
	input wire [31:0] epB3_hadrs, output wire epB3rd,  input wire [31:0] epB3pipe,
	//}
	
	//// pipe-ck //{
	output wire epPPck, // sync with write/read of pipe // w_ck_core
	//}
	
	// test //{
	output wire valid
	//}
	
	);
	
//// valid //{
(* keep = "true" *) 
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


//// sampling signals //{

(* keep = "true" *) 
reg         r_smp_NCE; //{

always @(posedge host_clk, negedge reset_n) begin
    if (!reset_n) begin
        r_smp_NCE <= 1'b1;
    end
    else begin
        r_smp_NCE <= i_FMC_NCE;
    end
end

//}

(* keep = "true" *) 
reg   [1:0] r_smp_WE_BUS; //{

wire w_WE_BUS = i_FMC_NWE | i_FMC_NCE; //$$ check NCE
wire w_rise_WE_BUS = (~(r_smp_WE_BUS[1])) & ( (r_smp_WE_BUS[0]));
wire w_fall_WE_BUS = ( (r_smp_WE_BUS[1])) & (~(r_smp_WE_BUS[0]));
always @(posedge host_clk, negedge reset_n) begin
    if (!reset_n) begin
        r_smp_WE_BUS <= 2'b11;
    end
    else begin
        r_smp_WE_BUS <= {r_smp_WE_BUS[0], w_WE_BUS};
    end
end

//}

(* keep = "true" *) 
reg   [1:0] r_smp_OE_BUS; //{

wire w_OE_BUS = i_FMC_NOE | i_FMC_NCE; //$$ check NCE
wire w_rise_OE_BUS = (~(r_smp_OE_BUS[1])) & ( (r_smp_OE_BUS[0]));
wire w_fall_OE_BUS = ( (r_smp_OE_BUS[1])) & (~(r_smp_OE_BUS[0]));
always @(posedge host_clk, negedge reset_n) begin
    if (!reset_n) begin
        r_smp_OE_BUS <= 2'b11;
    end
    else begin
        r_smp_OE_BUS <= {r_smp_OE_BUS[0], w_OE_BUS};
    end
end

//}

(* keep = "true" *) 
reg  [31:0] r_ADRS_BUS; //{ 

reg  [31:0] r_ADRS_BUS__smp;

wire [31:0] w_ADRS_BUS = i_FMC_ADD;
always @(posedge host_clk, negedge reset_n) begin
    if (!reset_n) begin
        r_ADRS_BUS      <= 32'b0;
        r_ADRS_BUS__smp <= 32'b0;
    end
    else begin
        //r_ADRS_BUS <= ( w_fall_WE_BUS | w_fall_OE_BUS ) ? w_ADRS_BUS : r_ADRS_BUS; // method 0
		//r_ADRS_BUS <= ( !r_smp_NCE ) ? w_ADRS_BUS : r_ADRS_BUS; // method 1
		// add delay for rise dection 
		r_ADRS_BUS__smp <= ( !r_smp_NCE ) ? w_ADRS_BUS : r_ADRS_BUS; // method 1
		r_ADRS_BUS      <= r_ADRS_BUS__smp;
    end
end

//}

(* keep = "true" *) 
reg  [15:0] r_DATA_WR; //{

reg  [15:0] r_DATA_WR_smp;

wire [15:0] w_DATA_WR = i_FMC_DWR;
always @(posedge host_clk, negedge reset_n) begin
    if (!reset_n) begin
        r_DATA_WR     <= 16'b0;
        r_DATA_WR_smp <= 16'b0;
    end
    else begin
		r_DATA_WR_smp <= ( !r_smp_WE_BUS[0] ) ? w_DATA_WR : r_DATA_WR;
		r_DATA_WR     <= r_DATA_WR_smp;
    end
end

//}

//}

//// wire-in //{
wire [31:0] w_ep00wire; assign ep00wire = w_ep00wire;
wire [31:0] w_ep01wire; assign ep01wire = w_ep01wire;
wire [31:0] w_ep02wire; assign ep02wire = w_ep02wire;
wire [31:0] w_ep03wire; assign ep03wire = w_ep03wire;
wire [31:0] w_ep04wire; assign ep04wire = w_ep04wire;
//
wire [31:0] w_ep12wire; assign ep12wire = w_ep12wire;
wire [31:0] w_ep13wire; assign ep13wire = w_ep13wire;
//
wire [31:0] w_ep16wire; assign ep16wire = w_ep16wire;
wire [31:0] w_ep17wire; assign ep17wire = w_ep17wire;
//
wire [31:0] w_ep1Awire; assign ep1Awire = w_ep1Awire;
wire [31:0] w_ep1Bwire; assign ep1Bwire = w_ep1Bwire;
wire [31:0] w_ep1Cwire; assign ep1Cwire = w_ep1Cwire;
wire [31:0] w_ep1Dwire; assign ep1Dwire = w_ep1Dwire;
wire [31:0] w_ep1Ewire; assign ep1Ewire = w_ep1Ewire;
//
sub_wire_in  sub_wire_in__h00 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep00_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep00wire) );
sub_wire_in  sub_wire_in__h01 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep01_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep01wire) );
sub_wire_in  sub_wire_in__h02 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep02_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep02wire) );
sub_wire_in  sub_wire_in__h03 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep03_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep03wire) );
sub_wire_in  sub_wire_in__h04 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep04_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep04wire) );
//
sub_wire_in  sub_wire_in__h12 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep12_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep12wire) );
sub_wire_in  sub_wire_in__h13 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep13_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep13wire) );
//
sub_wire_in  sub_wire_in__h16 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep16_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep16wire) );
sub_wire_in  sub_wire_in__h17 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep17_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep17wire) );
//
sub_wire_in  sub_wire_in__h1A (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep1A_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep1Awire) );
sub_wire_in  sub_wire_in__h1B (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep1B_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep1Bwire) );
sub_wire_in  sub_wire_in__h1C (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep1C_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep1Cwire) );
sub_wire_in  sub_wire_in__h1D (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep1D_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep1Dwire) );
sub_wire_in  sub_wire_in__h1E (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep1E_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwire (w_ep1Ewire) );
//
//}

//// wire-out // NOP

//// trig-in //{
sub_trig_in  sub_trig_in__h40 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep40_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep40ck), .o_epXXtrig (ep40trig) );
sub_trig_in  sub_trig_in__h42 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep42_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep42ck), .o_epXXtrig (ep42trig) );
sub_trig_in  sub_trig_in__h50 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep50_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep50ck), .o_epXXtrig (ep50trig) );
sub_trig_in  sub_trig_in__h51 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep51_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep51ck), .o_epXXtrig (ep51trig) );
sub_trig_in  sub_trig_in__h52 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep52_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep52ck), .o_epXXtrig (ep52trig) );
sub_trig_in  sub_trig_in__h53 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep53_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .i_epXXck(ep53ck), .o_epXXtrig (ep53trig) );
//}

//// trig-out //{
wire [31:0] w_ep60trig; // to host interface
wire [31:0] w_ep62trig; // to host interface
wire [31:0] w_ep73trig; // to host interface
//
sub_trig_out  sub_trig_out__h60 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_OE_BUS (w_rise_OE_BUS), .i_epXX_hadrs (ep60_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_epXXck(ep60ck), .i_epXXtrig (ep60trig) , .o_epXXtrig (w_ep60trig) );
sub_trig_out  sub_trig_out__h62 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_OE_BUS (w_rise_OE_BUS), .i_epXX_hadrs (ep62_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_epXXck(ep62ck), .i_epXXtrig (ep62trig) , .o_epXXtrig (w_ep62trig) );
sub_trig_out  sub_trig_out__h73 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_OE_BUS (w_rise_OE_BUS), .i_epXX_hadrs (ep73_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_epXXck(ep73ck), .i_epXXtrig (ep73trig) , .o_epXXtrig (w_ep73trig) );
//}

//// pipe-in //{
sub_pipe_in  sub_pipe_in__h93 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_WE_BUS (w_rise_WE_BUS), .i_epXX_hadrs (ep93_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .i_DATA_WR (r_DATA_WR), .o_epXXwr(ep93wr), .o_epXXpipe (ep93pipe) );
//}

//// pipe-out //{
sub_pipe_out  sub_pipe_out__hB3 (.reset_n (reset_n), .host_clk (host_clk), .i_ADRS_BUS (r_ADRS_BUS), .i_rise_OE_BUS (w_rise_OE_BUS), .i_epXX_hadrs (epB3_hadrs), .i_ep_offs_hadrs (ep_offs_hadrs), .o_epXXrd(epB3rd) );
//}

//// pipe-ck //{
assign epPPck = host_clk;
//}

//// bus readback 
reg  [15:0] r_DATA_RD; //{

assign o_FMC_DRD = r_DATA_RD;
always @(posedge host_clk, negedge reset_n) begin
	if (!reset_n) begin
		r_DATA_RD = 16'b0;
	end
	else begin
		r_DATA_RD <= 
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep00_hadrs + 0            ) )? w_ep00wire[15: 0] : // WI
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep00_hadrs + ep_offs_hadrs) )? w_ep00wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep01_hadrs + 0            ) )? w_ep01wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep01_hadrs + ep_offs_hadrs) )? w_ep01wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep02_hadrs + 0            ) )? w_ep02wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep02_hadrs + ep_offs_hadrs) )? w_ep02wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep03_hadrs + 0            ) )? w_ep03wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep03_hadrs + ep_offs_hadrs) )? w_ep03wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep04_hadrs + 0            ) )? w_ep04wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep04_hadrs + ep_offs_hadrs) )? w_ep04wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep12_hadrs + 0            ) )? w_ep12wire[15: 0] : // WI
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep12_hadrs + ep_offs_hadrs) )? w_ep12wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep13_hadrs + 0            ) )? w_ep13wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep13_hadrs + ep_offs_hadrs) )? w_ep13wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep16_hadrs + 0            ) )? w_ep16wire[15: 0] : // WI
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep16_hadrs + ep_offs_hadrs) )? w_ep16wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep17_hadrs + 0            ) )? w_ep17wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep17_hadrs + ep_offs_hadrs) )? w_ep17wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1A_hadrs + 0            ) )? w_ep1Awire[15: 0] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1A_hadrs + ep_offs_hadrs) )? w_ep1Awire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1B_hadrs + 0            ) )? w_ep1Bwire[15: 0] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1B_hadrs + ep_offs_hadrs) )? w_ep1Bwire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1C_hadrs + 0            ) )? w_ep1Cwire[15: 0] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1C_hadrs + ep_offs_hadrs) )? w_ep1Cwire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1D_hadrs + 0            ) )? w_ep1Dwire[15: 0] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1D_hadrs + ep_offs_hadrs) )? w_ep1Dwire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1E_hadrs + 0            ) )? w_ep1Ewire[15: 0] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1E_hadrs + ep_offs_hadrs) )? w_ep1Ewire[31:16] :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep20_hadrs + 0            ) )?   ep20wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep20_hadrs + ep_offs_hadrs) )?   ep20wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep21_hadrs + 0            ) )?   ep21wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep21_hadrs + ep_offs_hadrs) )?   ep21wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep22_hadrs + 0            ) )?   ep22wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep22_hadrs + ep_offs_hadrs) )?   ep22wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep23_hadrs + 0            ) )?   ep23wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep23_hadrs + ep_offs_hadrs) )?   ep23wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep24_hadrs + 0            ) )?   ep24wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep24_hadrs + ep_offs_hadrs) )?   ep24wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep30_hadrs + 0            ) )?   ep30wire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep30_hadrs + ep_offs_hadrs) )?   ep30wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep31_hadrs + 0            ) )?   ep31wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep31_hadrs + ep_offs_hadrs) )?   ep31wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep32_hadrs + 0            ) )?   ep32wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep32_hadrs + ep_offs_hadrs) )?   ep32wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep33_hadrs + 0            ) )?   ep33wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep33_hadrs + ep_offs_hadrs) )?   ep33wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep34_hadrs + 0            ) )?   ep34wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep34_hadrs + ep_offs_hadrs) )?   ep34wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep35_hadrs + 0            ) )?   ep35wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep35_hadrs + ep_offs_hadrs) )?   ep35wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep36_hadrs + 0            ) )?   ep36wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep36_hadrs + ep_offs_hadrs) )?   ep36wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep37_hadrs + 0            ) )?   ep37wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep37_hadrs + ep_offs_hadrs) )?   ep37wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep38_hadrs + 0            ) )?   ep38wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep38_hadrs + ep_offs_hadrs) )?   ep38wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep39_hadrs + 0            ) )?   ep39wire[15: 0] : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep39_hadrs + ep_offs_hadrs) )?   ep39wire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3A_hadrs + 0            ) )?   ep3Awire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3A_hadrs + ep_offs_hadrs) )?   ep3Awire[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3B_hadrs + 0            ) )?   ep3Bwire[15: 0] : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3B_hadrs + ep_offs_hadrs) )?   ep3Bwire[31:16] :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep60_hadrs + 0            ) )? w_ep60trig[15: 0] : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep60_hadrs + ep_offs_hadrs) )? w_ep60trig[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep62_hadrs + 0            ) )? w_ep62trig[15: 0] : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep62_hadrs + ep_offs_hadrs) )? w_ep62trig[31:16] :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep73_hadrs + 0            ) )? w_ep73trig[15: 0] : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep73_hadrs + ep_offs_hadrs) )? w_ep73trig[31:16] :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == epB3_hadrs + 0            ) )?   epB3pipe[15: 0] :// PO // hold value during OE_BUS low ... to check
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == epB3_hadrs + ep_offs_hadrs) )?   epB3pipe[31:16] :
					 //
					 r_DATA_RD;
		//
	end
end


//}


assign o_FMC_DRD_TRI =  //{
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep00_hadrs + 0            ) )? 16'h0000 : // WI
		             ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep00_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep01_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep01_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep02_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep02_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep03_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep03_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep04_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep04_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep12_hadrs + 0            ) )? 16'h0000 : // WI
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep12_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep13_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep13_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep16_hadrs + 0            ) )? 16'h0000 : // WI
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep16_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep17_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep17_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1A_hadrs + 0            ) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1A_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1B_hadrs + 0            ) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1B_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1C_hadrs + 0            ) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1C_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1D_hadrs + 0            ) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1D_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1E_hadrs + 0            ) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep1E_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep20_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep20_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep21_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep21_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep22_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep22_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep23_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep23_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep24_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep24_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep30_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep30_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep31_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep31_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep32_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep32_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep33_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep33_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep34_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep34_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep35_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep35_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep36_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep36_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep37_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep37_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep38_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep38_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep39_hadrs + 0            ) )? 16'h0000 : //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep39_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3A_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3A_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3B_hadrs + 0            ) )? 16'h0000 : // WO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep3B_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep60_hadrs + 0            ) )? 16'h0000 : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep60_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep62_hadrs + 0            ) )? 16'h0000 : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep62_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep73_hadrs + 0            ) )? 16'h0000 : // TO
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == ep73_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 //
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == epB3_hadrs + 0            ) )? 16'h0000 :// PO // hold value during OE_BUS low ... to check
					 ( (!r_smp_OE_BUS[0]) & (r_ADRS_BUS == epB3_hadrs + ep_offs_hadrs) )? 16'h0000 :
					 //
					 16'hFFFF;

//}



endmodule //}


//// testbench
module tb_adc_wrapper (); //{

//// clocks //{
reg clk_10M = 1'b0; // assume 10MHz or 100ns
	always
	#50 	clk_10M = ~clk_10M; // toggle every 50ns --> clock 100ns 
//
reg reset_n = 1'b0;
wire reset = ~reset_n;
//
reg clk_140M = 1'b0; // assume 140MHz or 7.1428571428571ns
	always
	#3.571428571428571 	clk_140M = ~clk_140M; // toggle
//
reg clk_104M = 1'b0; // 104MHz
reg clk_52M  = 1'b0; //  52MHz
reg clk_26M  = 1'b0; //  26MHz
always begin
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	clk_52M  = ~clk_52M ;  // toggle every 1/( 52MHz)/2=9.61538462ns
	clk_26M  = ~clk_26M ;  // toggle every 1/( 26MHz)/2=19.2307692ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	clk_52M  = ~clk_52M ;  // toggle every 1/( 52MHz)/2=9.61538462ns
	#4.80769231;
	clk_104M = ~clk_104M;  // toggle every 1/(104MHz)/2=4.80769231ns
	end
	
wire sys_clk  = clk_10M;
wire host_clk = clk_140M;
wire spi_clk  = clk_104M; 
	
//}


//// DUT //{

reg           r_FMC_NCE ; 
reg  [31 : 0] r_FMC_ADD ; 
reg           r_FMC_NOE ; 
wire [15 : 0] w_FMC_DRD ; 
reg           r_FMC_NWE ; 
reg  [15 : 0] r_FMC_DWR ; 

// wire [31 : 0] w_ep62trig_loopback ;

adc_wrapper  adc_wrapper__inst ();

//  adc_wrapper  adc_wrapper__inst (
//  	
//  	// clock and reset
//  	.clk      (sys_clk  ),
//  	.reset_n  (reset_n  ),
//  	.host_clk (host_clk ), // monitoring async bus signals
//  	
//  	// IO bus interface // async for arm io
//  	.i_FMC_NCE  ( r_FMC_NCE ),  // input  wire          // FMC_NCE
//  	.i_FMC_ADD  ( r_FMC_ADD ),  // input  wire [31 : 0] // FMC_ADD
//  	.i_FMC_NOE  ( r_FMC_NOE ),  // input  wire          // FMC_NOE
//  	.o_FMC_DRD  ( w_FMC_DRD ),  // output wire [31 : 0] // FMC_DRD
//  	.i_FMC_NWE  ( r_FMC_NWE ),  // input  wire          // FMC_NWE
//  	.i_FMC_DWR  ( r_FMC_DWR ),  // input  wire [15 : 0] // FMC_DWR
//  	
//  	// end-points
//  	
//  	//// end-point address offset between high and low 16 bits //{
//  	.ep_offs_hadrs     (32'h0000_0004),  // input wire [31:0]
//  	//}
//  	
//  	//// wire-in //{
//  	.ep00_hadrs(32'h6010_0008),  .ep00wire     (),  // input wire [31:0] // output wire [31:0] // ERR_LED
//  	.ep01_hadrs(32'h6010_0010),  .ep01wire     (),  // input wire [31:0] // output wire [31:0] // FPGA_LED
//  	.ep02_hadrs(32'h6010_0030),  .ep02wire     (),  // input wire [31:0] // output wire [31:0] // H I/F OUT 
//  	.ep03_hadrs(32'h6010_0068),  .ep03wire     (),  // input wire [31:0] // output wire [31:0] // {INTER_LOCK RELAY, INTER_LOCK LED}
//  	.ep04_hadrs(32'h6030_0008),  .ep04wire     (),  // input wire [31:0] // output wire [31:0] // GPIB CONTROL // Control Read & Write     
//  	//
//  	.ep12_hadrs(32'h0000_0000),  .ep12wire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep13_hadrs(32'h0000_0000),  .ep13wire     (),  // input wire [31:0] // output wire [31:0] //
//  	//
//  	.ep16_hadrs(32'h6060_0000),  .ep16wire     (),  // input wire [31:0] // output wire [31:0] // MSPI_EN_CS_WI // {SPI_CH_SELEC, SLOT_CS_MASK}
//  	.ep17_hadrs(32'h6070_0000),  .ep17wire     (),  // input wire [31:0] // output wire [31:0] // MSPI_CON_WI   // {Mx_SPI_MOSI_DATA_H, Mx_SPI_MOSI_DATA_L}
//  	//
//  	.ep1A_hadrs(32'h0000_0000),  .ep1Awire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1B_hadrs(32'h0000_0000),  .ep1Bwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1C_hadrs(32'h0000_0000),  .ep1Cwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1D_hadrs(32'h0000_0000),  .ep1Dwire     (),  // input wire [31:0] // output wire [31:0] //
//  	.ep1E_hadrs(32'h0000_0000),  .ep1Ewire     (),  // input wire [31:0] // output wire [31:0] //	
//  	//}
//  	
//  	//// wire-out //{
//  	.ep20_hadrs(32'h0000_0000),  .ep20wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep21_hadrs(32'h0000_0000),  .ep21wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep22_hadrs(32'h0000_0000),  .ep22wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep23_hadrs(32'h0000_0000),  .ep23wire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep24_hadrs(32'h6070_0008),  .ep24wire     (),  // input wire [31:0] // input wire [31:0] // MSPI_FLAG_WO // {Mx_SPI_MISO_DATA_H, Mx_SPI_MISO_DATA_L}
//  	//
//  	.ep30_hadrs(32'h6010_0000),  .ep30wire     (32'h33AA_CC55),  // input wire [31:0] // input wire [31:0] // {MAGIC CODE_H, MAGIC CODE_L}
//  	.ep31_hadrs(32'h6010_0018),  .ep31wire     (),  // input wire [31:0] // input wire [31:0] // MASTER MODE LAN IP Address 
//  	.ep32_hadrs(32'h6010_0020),  .ep32wire     (32'hA021_0805),  // input wire [31:0] // input wire [31:0] // {FPGA_IMAGE_ID_H, FPGA_IMAGE_ID_L}
//  	.ep33_hadrs(32'h6010_0038),  .ep33wire     (),  // input wire [31:0] // input wire [31:0] // H I/F IN
//  	.ep34_hadrs(32'h6010_0040),  .ep34wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#1 FAN SPEED, FAN#0 FAN SPEED}
//  	.ep35_hadrs(32'h6010_0048),  .ep35wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#3 FAN SPEED, FAN#2 FAN SPEED}
//  	.ep36_hadrs(32'h6010_0050),  .ep36wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#5 FAN SPEED, FAN#4 FAN SPEED}
//  	.ep37_hadrs(32'h6010_0058),  .ep37wire     (),  // input wire [31:0] // input wire [31:0] // {FAN#7 FAN SPEED, FAN#6 FAN SPEED}
//  	.ep38_hadrs(32'h6010_0060),  .ep38wire     (),  // input wire [31:0] // input wire [31:0] // INTER_LOCK
//  	.ep39_hadrs(32'h6030_0000),  .ep39wire     (),  // input wire [31:0] // input wire [31:0] // {GPIB Switch Read, GPIB Status Read}
//  	.ep3A_hadrs(32'h0000_0000),  .ep3Awire     (),  // input wire [31:0] // input wire [31:0] //
//  	.ep3B_hadrs(32'h0000_0000),  .ep3Bwire     (),  // input wire [31:0] // input wire [31:0] //
//  	//}
//  	
//  	//// trig-in //{
//  	.ep42_hadrs(32'h6070_0010),  .ep42ck       (spi_clk),  .ep42trig   (w_ep62trig_loopback),  // input wire [31:0] // input wire  // output wire [31:0] // MSPI_TI // Mx_SPI_Trig
//  	//
//  	.ep50_hadrs(32'h6010_0028),  .ep50ck       (),  .ep50trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // S/W Reset
//  	.ep51_hadrs(32'h60A0_0000),  .ep51ck       (),  .ep51trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // {PRE_Trig, Trig}
//  	.ep52_hadrs(32'h60A0_0008),  .ep52ck       (),  .ep52trig   (),  // input wire [31:0] // input wire  // output wire [31:0] // SOT
//  	//}
//  	
//  	//// trig-out //{
//  	.ep60_hadrs(32'h0000_0000),  .ep60ck       (       ),  .ep60trig   (                   ),  // input wire [31:0] // input wire  // input wire [31:0] //
//  	.ep62_hadrs(32'h6070_0018),  .ep62ck       (spi_clk),  .ep62trig   (w_ep62trig_loopback),  // input wire [31:0] // input wire  // input wire [31:0] // MSPI_TO // Mx_SPI_DONE
//  	.ep73_hadrs(32'h0000_0000),  .ep73ck       (       ),  .ep73trig   (                   ),  // input wire [31:0] // input wire  // input wire [31:0] //
//  	//}
//  	
//  	//// pipe-in //{
//  	//.ep80_hadrs(),  .ep80wr       (),  .ep80pipe   (),  // input wire [31:0] // output wire  // output wire [31:0]
//  	.ep93_hadrs(32'h6070_00A0),  .ep93wr       (),  .ep93pipe   (), // input wire [31:0] // output wire  // output wire [31:0]
//  	//}
//  	
//  	//// pipe-out //{
//  	//.epA0_hadrs(),  .epA0rd       (),  .epA0pipe   (),  // input wire [31:0] // output wire  // input wire [31:0]
//  	.epB3_hadrs(32'h6070_00A8),  .epB3rd       (),  .epB3pipe   (32'hCA53_3AC5),  // input wire [31:0] // output wire  // input wire [31:0]
//  	//}
//  	
//  	//// pipe-ck //{
//  	.epPPck       (),  // output wire  // sync with write/read of pipe
//  	//}
//  	
//  	// test //{
//  	.valid    ()
//  	//}
//  );

//}


//// test sequence //{

initial begin : reset_n__gen
#0	reset_n 	= 1'b0;
#200;
	reset_n 	= 1'b1; 
#200;
end

initial begin 
// init
TASK__FMC__IDLE();
//
$display(" Wait for rise of reset_n"); 
@(posedge reset_n)
#200;

// test
TASK__FMC__IDLE();
#200;
TASK__FMC__READ (32'h6010_0000); // WO
#200;
TASK__FMC__READ (32'h6010_0004);
#200;
TASK__FMC__READ (32'h6010_0020);
#200;
TASK__FMC__READ (32'h6010_0024);
#200;
TASK__FMC__WRITE(32'h6060_0004, 16'h0003); // WI
#200;
TASK__FMC__WRITE(32'h6060_0000, 16'h1FFF);
#200;
TASK__FMC__WRITE(32'h6070_0004, 16'h4380); // WI
#200;
TASK__FMC__WRITE(32'h6070_0000, 16'h0000);
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0001); // TI
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0002); // TI
#200;
TASK__FMC__WRITE(32'h6070_0010, 16'h0004); // TI
#200;
TASK__FMC__READ (32'h6070_0018); // TO
#200;
//
TASK__FMC__WRITE(32'h6060_0000, 16'h1FFF); // WI
#200;
TASK__FMC__WRITE(32'h6060_0004, 16'h0003);
#200;
TASK__FMC__READ (32'h6060_0000);
#200;
TASK__FMC__READ (32'h6060_0004);
#200;
//
TASK__FMC__WRITE(32'h6070_00A0+4, 16'h1234); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+0, 16'hABCD); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+4, 16'h5678); // PI
#200;
TASK__FMC__WRITE(32'h6070_00A0+0, 16'hFEFE); // PI
#200;
// 
TASK__FMC__READ (32'h6070_00A8+4); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+0); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+4); // PO
#200;
TASK__FMC__READ (32'h6070_00A8+0); // PO
#200;
// 

///////////////////////
#200;
$finish;
end 

//}


//// test task //{

// task bus idle
task TASK__FMC__IDLE;
begin
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk);
end 
endtask

// task bus read  (address_32b)
task TASK__FMC__READ;
input [31:0] temp_adrs;
begin
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  --______________---
//    FMC_DRD  xxxDDDDDDDDDDDDDxxx
//    FMC_NWE  -------------------
//    FMC_DWR  -------------------
	@(posedge host_clk); // 0
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b0;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	repeat (13) begin
		@(posedge host_clk); // 1~13
	end
	@(posedge host_clk); // 14
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
end 
endtask

// task bus write (address_32b, data_16b)
task TASK__FMC__WRITE;
input [31:0] temp_adrs;
input [15:0] temp_data;
begin

//// case a // OK
//    idx      --01234567890123---
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  -------------------
//    FMC_DRD  xxxxxxxxxxxxxxxxxxx
//    FMC_NWE  --------_____------
//    FMC_DWR  xxxxxxxxxxxDDDDDxxx

//// case b // rev
//    idx      --01234567890123---
//    FMC_NCE  --______________---
//    FMC_ADD  xxAAAAAAAAAAAAAAxxx
//    FMC_NOE  -------------------
//    FMC_DRD  xxxxxxxxxxxxxxxxxxx
//    FMC_NWE  --------________---
//    FMC_DWR  xxxxxxxxxxxDDDDDxxx


	@(posedge host_clk); // 0
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk); // 0
	@(posedge host_clk); // 1
	@(posedge host_clk); // 2
	@(posedge host_clk); // 3
	@(posedge host_clk); // 4
	@(posedge host_clk); // 5
	@(posedge host_clk); // 6
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b0;
	r_FMC_DWR = 16'b0;
	@(posedge host_clk); // 7
	@(posedge host_clk); // 8
	@(posedge host_clk); // 9
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b0;
	r_FMC_DWR = temp_data; // set data
	@(posedge host_clk); // 10
	@(posedge host_clk); // 11
	r_FMC_NCE =  1'b0;
	r_FMC_ADD = temp_adrs; // set address
	r_FMC_NOE =  1'b1;
	//r_FMC_NWE =  1'b1; // case a
	r_FMC_NWE =  1'b0; // case b
	r_FMC_DWR = temp_data; // set data
	@(posedge host_clk); // 12
	@(posedge host_clk); // 13
	@(posedge host_clk); // 14
	r_FMC_NCE =  1'b1;
	r_FMC_ADD = 32'b0;
	r_FMC_NOE =  1'b1;
	r_FMC_NWE =  1'b1;
	r_FMC_DWR = 16'b0;
end 
endtask


//}

endmodule //}

//}

