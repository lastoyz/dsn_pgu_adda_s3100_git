//------------------------------------------------------------------------
// ok_endpoint_wrapper__dummy.v
//
// test idle state
//------------------------------------------------------------------------

//$$`default_nettype none

module ok_endpoint_wrapper__dummy (
	//input  wire [4:0]   okUH, // external pins
	//output wire [2:0]   okHU, // external pins
	//inout  wire [31:0]  okUHU, // external pins
	//inout  wire         okAA, // external pin
	//
	// for dummy 
	input  wire        clk     ,
	input  wire        reset_n ,	
	
	// wire in //{
	output wire [31:0] ep00wire,
	output wire [31:0] ep01wire,
	output wire [31:0] ep02wire,
	output wire [31:0] ep03wire,
	output wire [31:0] ep04wire,
	output wire [31:0] ep05wire,
	output wire [31:0] ep06wire,
	output wire [31:0] ep07wire,
	output wire [31:0] ep08wire,
	output wire [31:0] ep09wire,
	output wire [31:0] ep0Awire,
	output wire [31:0] ep0Bwire,
	output wire [31:0] ep0Cwire,
	output wire [31:0] ep0Dwire,
	output wire [31:0] ep0Ewire,
	output wire [31:0] ep0Fwire,
	output wire [31:0] ep10wire,
	output wire [31:0] ep11wire,
	output wire [31:0] ep12wire,
	output wire [31:0] ep13wire,
	output wire [31:0] ep14wire,
	output wire [31:0] ep15wire,
	output wire [31:0] ep16wire,
	output wire [31:0] ep17wire,
	output wire [31:0] ep18wire,
	output wire [31:0] ep19wire,
	output wire [31:0] ep1Awire,
	output wire [31:0] ep1Bwire,
	output wire [31:0] ep1Cwire,
	output wire [31:0] ep1Dwire,
	output wire [31:0] ep1Ewire,
	output wire [31:0] ep1Fwire,
	//}
	
	// wire out //{
	input wire [31:0]  ep20wire,
	input wire [31:0]  ep21wire,
	input wire [31:0]  ep22wire,
	input wire [31:0]  ep23wire,
	input wire [31:0]  ep24wire,
	input wire [31:0]  ep25wire,
	input wire [31:0]  ep26wire,
	input wire [31:0]  ep27wire,
	input wire [31:0]  ep28wire,
	input wire [31:0]  ep29wire,
	input wire [31:0]  ep2Awire,
	input wire [31:0]  ep2Bwire,
	input wire [31:0]  ep2Cwire,
	input wire [31:0]  ep2Dwire,
	input wire [31:0]  ep2Ewire,
	input wire [31:0]  ep2Fwire,
	input wire [31:0]  ep30wire,
	input wire [31:0]  ep31wire,
	input wire [31:0]  ep32wire,
	input wire [31:0]  ep33wire,
	input wire [31:0]  ep34wire,
	input wire [31:0]  ep35wire,
	input wire [31:0]  ep36wire,
	input wire [31:0]  ep37wire,
	input wire [31:0]  ep38wire,
	input wire [31:0]  ep39wire,
	input wire [31:0]  ep3Awire,
	input wire [31:0]  ep3Bwire,
	input wire [31:0]  ep3Cwire,
	input wire [31:0]  ep3Dwire,
	input wire [31:0]  ep3Ewire,
	input wire [31:0]  ep3Fwire,
	//}
	
	// trig in //{
	input wire ep40ck, output wire [31:0] ep40trig,
	input wire ep41ck, output wire [31:0] ep41trig,
	input wire ep42ck, output wire [31:0] ep42trig,
	input wire ep43ck, output wire [31:0] ep43trig,
	input wire ep44ck, output wire [31:0] ep44trig,
	input wire ep45ck, output wire [31:0] ep45trig,
	input wire ep46ck, output wire [31:0] ep46trig,
	input wire ep47ck, output wire [31:0] ep47trig,
	input wire ep48ck, output wire [31:0] ep48trig,
	input wire ep49ck, output wire [31:0] ep49trig,
	input wire ep4Ack, output wire [31:0] ep4Atrig,
	input wire ep4Bck, output wire [31:0] ep4Btrig,
	input wire ep4Cck, output wire [31:0] ep4Ctrig,
	input wire ep4Dck, output wire [31:0] ep4Dtrig,
	input wire ep4Eck, output wire [31:0] ep4Etrig,
	input wire ep4Fck, output wire [31:0] ep4Ftrig,
	input wire ep50ck, output wire [31:0] ep50trig,
	input wire ep51ck, output wire [31:0] ep51trig,
	input wire ep52ck, output wire [31:0] ep52trig,
	input wire ep53ck, output wire [31:0] ep53trig,
	input wire ep54ck, output wire [31:0] ep54trig,
	input wire ep55ck, output wire [31:0] ep55trig,
	input wire ep56ck, output wire [31:0] ep56trig,
	input wire ep57ck, output wire [31:0] ep57trig,
	input wire ep58ck, output wire [31:0] ep58trig,
	input wire ep59ck, output wire [31:0] ep59trig,
	input wire ep5Ack, output wire [31:0] ep5Atrig,
	input wire ep5Bck, output wire [31:0] ep5Btrig,
	input wire ep5Cck, output wire [31:0] ep5Ctrig,
	input wire ep5Dck, output wire [31:0] ep5Dtrig,
	input wire ep5Eck, output wire [31:0] ep5Etrig,
	input wire ep5Fck, output wire [31:0] ep5Ftrig,
	//}
	
	// trig out //{
	input wire ep60ck,  input wire [31:0] ep60trig,
	input wire ep61ck,  input wire [31:0] ep61trig,
	input wire ep62ck,  input wire [31:0] ep62trig,
	input wire ep63ck,  input wire [31:0] ep63trig,
	input wire ep64ck,  input wire [31:0] ep64trig,
	input wire ep65ck,  input wire [31:0] ep65trig,
	input wire ep66ck,  input wire [31:0] ep66trig,
	input wire ep67ck,  input wire [31:0] ep67trig,
	input wire ep68ck,  input wire [31:0] ep68trig,
	input wire ep69ck,  input wire [31:0] ep69trig,
	input wire ep6Ack,  input wire [31:0] ep6Atrig,
	input wire ep6Bck,  input wire [31:0] ep6Btrig,
	input wire ep6Cck,  input wire [31:0] ep6Ctrig,
	input wire ep6Dck,  input wire [31:0] ep6Dtrig,
	input wire ep6Eck,  input wire [31:0] ep6Etrig,
	input wire ep6Fck,  input wire [31:0] ep6Ftrig,
	input wire ep70ck,  input wire [31:0] ep70trig,
	input wire ep71ck,  input wire [31:0] ep71trig,
	input wire ep72ck,  input wire [31:0] ep72trig,
	input wire ep73ck,  input wire [31:0] ep73trig,
	input wire ep74ck,  input wire [31:0] ep74trig,
	input wire ep75ck,  input wire [31:0] ep75trig,
	input wire ep76ck,  input wire [31:0] ep76trig,
	input wire ep77ck,  input wire [31:0] ep77trig,
	input wire ep78ck,  input wire [31:0] ep78trig,
	input wire ep79ck,  input wire [31:0] ep79trig,
	input wire ep7Ack,  input wire [31:0] ep7Atrig,
	input wire ep7Bck,  input wire [31:0] ep7Btrig,
	input wire ep7Cck,  input wire [31:0] ep7Ctrig,
	input wire ep7Dck,  input wire [31:0] ep7Dtrig,
	input wire ep7Eck,  input wire [31:0] ep7Etrig,
	input wire ep7Fck,  input wire [31:0] ep7Ftrig,
	//}
	
	// pipe in //{
	output wire ep80wr, output wire [31:0] ep81pipe,
	output wire ep81wr, output wire [31:0] ep80pipe, 
	output wire ep82wr, output wire [31:0] ep82pipe,
	output wire ep83wr, output wire [31:0] ep83pipe,
	output wire ep84wr, output wire [31:0] ep84pipe,
	output wire ep85wr, output wire [31:0] ep85pipe,
	output wire ep86wr, output wire [31:0] ep86pipe,
	output wire ep87wr, output wire [31:0] ep87pipe,
	output wire ep88wr, output wire [31:0] ep88pipe,
	output wire ep89wr, output wire [31:0] ep89pipe,
	output wire ep8Awr, output wire [31:0] ep8Apipe,
	output wire ep8Bwr, output wire [31:0] ep8Bpipe,
	output wire ep8Cwr, output wire [31:0] ep8Cpipe,
	output wire ep8Dwr, output wire [31:0] ep8Dpipe,
	output wire ep8Ewr, output wire [31:0] ep8Epipe,
	output wire ep8Fwr, output wire [31:0] ep8Fpipe,
	output wire ep90wr, output wire [31:0] ep90pipe,
	output wire ep91wr, output wire [31:0] ep91pipe,
	output wire ep92wr, output wire [31:0] ep92pipe,
	output wire ep93wr, output wire [31:0] ep93pipe,
	output wire ep94wr, output wire [31:0] ep94pipe,
	output wire ep95wr, output wire [31:0] ep95pipe,
	output wire ep96wr, output wire [31:0] ep96pipe,
	output wire ep97wr, output wire [31:0] ep97pipe,
	output wire ep98wr, output wire [31:0] ep98pipe,
	output wire ep99wr, output wire [31:0] ep99pipe,
	output wire ep9Awr, output wire [31:0] ep9Apipe,
	output wire ep9Bwr, output wire [31:0] ep9Bpipe,
	output wire ep9Cwr, output wire [31:0] ep9Cpipe,
	output wire ep9Dwr, output wire [31:0] ep9Dpipe,
	output wire ep9Ewr, output wire [31:0] ep9Epipe,
	output wire ep9Fwr, output wire [31:0] ep9Fpipe,
	//}
	
	// pipe out //{
	output wire epA0rd,  input wire [31:0] epA0pipe,
	output wire epA1rd,  input wire [31:0] epA1pipe,
	output wire epA2rd,  input wire [31:0] epA2pipe,
	output wire epA3rd,  input wire [31:0] epA3pipe,
	output wire epA4rd,  input wire [31:0] epA4pipe,
	output wire epA5rd,  input wire [31:0] epA5pipe,
	output wire epA6rd,  input wire [31:0] epA6pipe,
	output wire epA7rd,  input wire [31:0] epA7pipe,
	output wire epA8rd,  input wire [31:0] epA8pipe,
	output wire epA9rd,  input wire [31:0] epA9pipe,
	output wire epAArd,  input wire [31:0] epAApipe,
	output wire epABrd,  input wire [31:0] epABpipe,
	output wire epACrd,  input wire [31:0] epACpipe,
	output wire epADrd,  input wire [31:0] epADpipe,
	output wire epAErd,  input wire [31:0] epAEpipe,
	output wire epAFrd,  input wire [31:0] epAFpipe,
	output wire epB0rd,  input wire [31:0] epB0pipe,
	output wire epB1rd,  input wire [31:0] epB1pipe,
	output wire epB2rd,  input wire [31:0] epB2pipe,
	output wire epB3rd,  input wire [31:0] epB3pipe,
	output wire epB4rd,  input wire [31:0] epB4pipe,
	output wire epB5rd,  input wire [31:0] epB5pipe,
	output wire epB6rd,  input wire [31:0] epB6pipe,
	output wire epB7rd,  input wire [31:0] epB7pipe,
	output wire epB8rd,  input wire [31:0] epB8pipe,
	output wire epB9rd,  input wire [31:0] epB9pipe,
	output wire epBArd,  input wire [31:0] epBApipe,
	output wire epBBrd,  input wire [31:0] epBBpipe,
	output wire epBCrd,  input wire [31:0] epBCpipe,
	output wire epBDrd,  input wire [31:0] epBDpipe,
	output wire epBErd,  input wire [31:0] epBEpipe,
	output wire epBFrd,  input wire [31:0] epBFpipe,
	//}
	
	//
	output wire okClk // sync with write/read of pipe
	);


// valid
(* keep = "true" *) 
reg r_valid; //{
//assign valid = r_valid;
//
always @(posedge clk, negedge reset_n)
	if (!reset_n) begin
		r_valid <= 1'b0;
	end
	else begin
		r_valid <= 1'b1;
	end	
//}


// assign okClk
assign okClk = (r_valid)? clk : 1'b0;


//// zero outputs 

// wire in //{
assign  ep00wire  =  32'h0;
assign  ep01wire  =  32'h0;
assign  ep02wire  =  32'h0;
assign  ep03wire  =  32'h0;
assign  ep04wire  =  32'h0;
assign  ep05wire  =  32'h0;
assign  ep06wire  =  32'h0;
assign  ep07wire  =  32'h0;
assign  ep08wire  =  32'h0;
assign  ep09wire  =  32'h0;
assign  ep0Awire  =  32'h0;
assign  ep0Bwire  =  32'h0;
assign  ep0Cwire  =  32'h0;
assign  ep0Dwire  =  32'h0;
assign  ep0Ewire  =  32'h0;
assign  ep0Fwire  =  32'h0;
assign  ep10wire  =  32'h0;
assign  ep11wire  =  32'h0;
assign  ep12wire  =  32'h0;
assign  ep13wire  =  32'h0;
assign  ep14wire  =  32'h0;
assign  ep15wire  =  32'h0;
assign  ep16wire  =  32'h0;
assign  ep17wire  =  32'h0;
assign  ep18wire  =  32'h0;
assign  ep19wire  =  32'h0;
assign  ep1Awire  =  32'h0;
assign  ep1Bwire  =  32'h0;
assign  ep1Cwire  =  32'h0;
assign  ep1Dwire  =  32'h0;
assign  ep1Ewire  =  32'h0;
assign  ep1Fwire  =  32'h0;
//}

// trig in //{
assign  ep40trig  =  32'h0;
assign  ep41trig  =  32'h0;
assign  ep42trig  =  32'h0;
assign  ep43trig  =  32'h0;
assign  ep44trig  =  32'h0;
assign  ep45trig  =  32'h0;
assign  ep46trig  =  32'h0;
assign  ep47trig  =  32'h0;
assign  ep48trig  =  32'h0;
assign  ep49trig  =  32'h0;
assign  ep4Atrig  =  32'h0;
assign  ep4Btrig  =  32'h0;
assign  ep4Ctrig  =  32'h0;
assign  ep4Dtrig  =  32'h0;
assign  ep4Etrig  =  32'h0;
assign  ep4Ftrig  =  32'h0;
assign  ep50trig  =  32'h0;
assign  ep51trig  =  32'h0;
assign  ep52trig  =  32'h0;
assign  ep53trig  =  32'h0;
assign  ep54trig  =  32'h0;
assign  ep55trig  =  32'h0;
assign  ep56trig  =  32'h0;
assign  ep57trig  =  32'h0;
assign  ep58trig  =  32'h0;
assign  ep59trig  =  32'h0;
assign  ep5Atrig  =  32'h0;
assign  ep5Btrig  =  32'h0;
assign  ep5Ctrig  =  32'h0;
assign  ep5Dtrig  =  32'h0;
assign  ep5Etrig  =  32'h0;
assign  ep5Ftrig  =  32'h0;
//}

// pipe in //{
assign  ep80wr  = 1'b0;  assign  ep81pipe  = 32'b0;
assign  ep81wr  = 1'b0;  assign  ep80pipe  = 32'b0; 
assign  ep82wr  = 1'b0;  assign  ep82pipe  = 32'b0;
assign  ep83wr  = 1'b0;  assign  ep83pipe  = 32'b0;
assign  ep84wr  = 1'b0;  assign  ep84pipe  = 32'b0;
assign  ep85wr  = 1'b0;  assign  ep85pipe  = 32'b0;
assign  ep86wr  = 1'b0;  assign  ep86pipe  = 32'b0;
assign  ep87wr  = 1'b0;  assign  ep87pipe  = 32'b0;
assign  ep88wr  = 1'b0;  assign  ep88pipe  = 32'b0;
assign  ep89wr  = 1'b0;  assign  ep89pipe  = 32'b0;
assign  ep8Awr  = 1'b0;  assign  ep8Apipe  = 32'b0;
assign  ep8Bwr  = 1'b0;  assign  ep8Bpipe  = 32'b0;
assign  ep8Cwr  = 1'b0;  assign  ep8Cpipe  = 32'b0;
assign  ep8Dwr  = 1'b0;  assign  ep8Dpipe  = 32'b0;
assign  ep8Ewr  = 1'b0;  assign  ep8Epipe  = 32'b0;
assign  ep8Fwr  = 1'b0;  assign  ep8Fpipe  = 32'b0;
assign  ep90wr  = 1'b0;  assign  ep90pipe  = 32'b0;
assign  ep91wr  = 1'b0;  assign  ep91pipe  = 32'b0;
assign  ep92wr  = 1'b0;  assign  ep92pipe  = 32'b0;
assign  ep93wr  = 1'b0;  assign  ep93pipe  = 32'b0;
assign  ep94wr  = 1'b0;  assign  ep94pipe  = 32'b0;
assign  ep95wr  = 1'b0;  assign  ep95pipe  = 32'b0;
assign  ep96wr  = 1'b0;  assign  ep96pipe  = 32'b0;
assign  ep97wr  = 1'b0;  assign  ep97pipe  = 32'b0;
assign  ep98wr  = 1'b0;  assign  ep98pipe  = 32'b0;
assign  ep99wr  = 1'b0;  assign  ep99pipe  = 32'b0;
assign  ep9Awr  = 1'b0;  assign  ep9Apipe  = 32'b0;
assign  ep9Bwr  = 1'b0;  assign  ep9Bpipe  = 32'b0;
assign  ep9Cwr  = 1'b0;  assign  ep9Cpipe  = 32'b0;
assign  ep9Dwr  = 1'b0;  assign  ep9Dpipe  = 32'b0;
assign  ep9Ewr  = 1'b0;  assign  ep9Epipe  = 32'b0;
assign  ep9Fwr  = 1'b0;  assign  ep9Fpipe  = 32'b0;
//}

// pipe out //{
assign  epA0rd  = 1'b0;
assign  epA1rd  = 1'b0;
assign  epA2rd  = 1'b0;
assign  epA3rd  = 1'b0;
assign  epA4rd  = 1'b0;
assign  epA5rd  = 1'b0;
assign  epA6rd  = 1'b0;
assign  epA7rd  = 1'b0;
assign  epA8rd  = 1'b0;
assign  epA9rd  = 1'b0;
assign  epAArd  = 1'b0;
assign  epABrd  = 1'b0;
assign  epACrd  = 1'b0;
assign  epADrd  = 1'b0;
assign  epAErd  = 1'b0;
assign  epAFrd  = 1'b0;
assign  epB0rd  = 1'b0;
assign  epB1rd  = 1'b0;
assign  epB2rd  = 1'b0;
assign  epB3rd  = 1'b0;
assign  epB4rd  = 1'b0;
assign  epB5rd  = 1'b0;
assign  epB6rd  = 1'b0;
assign  epB7rd  = 1'b0;
assign  epB8rd  = 1'b0;
assign  epB9rd  = 1'b0;
assign  epBArd  = 1'b0;
assign  epBBrd  = 1'b0;
assign  epBCrd  = 1'b0;
assign  epBDrd  = 1'b0;
assign  epBErd  = 1'b0;
assign  epBFrd  = 1'b0;
//}


//  // Target interface bus:
//  //(* keep = "true" *) 
//  wire [112:0] okHE;
//  //(* keep = "true" *) 
//  wire [64:0]  okEH;
//  
//  //$$ okHost: full connection 
//  // Instantiate the okHost and connect endpoints.
//  parameter NUM_WIREOR	= 128;
//  wire [65*NUM_WIREOR-1:0]  okEHx;
//  //
//  okWireOR # (.N(NUM_WIREOR)) wireOR (okEH, okEHx); // okEHx
//  //
//  okHost okHI(
//  	.okUH(okUH),
//  	.okHU(okHU),
//  	.okUHU(okUHU),
//  	.okAA(okAA),
//  	.okClk(okClk),
//  	.okHE(okHE), 
//  	.okEH(okEH)
//  );

//  $$ Endpoints
//   Wire In 		0x00 - 0x1F
//   Wire Out 	0x20 - 0x3F
//   Trigger In 	0x40 - 0x5F
//   Trigger Out 	0x60 - 0x7F
//   Pipe In 		0x80 - 0x9F
//   Pipe Out 	0xA0 - 0xBF
//
// okRegisterBridge   to come!!
// see https://www.opalkelly.com/examples/setting-and-getting-registers/
// see http://www.opalkelly.com:8090/display/FPSDK/FrontPanel+HDL
// see http://www.opalkelly.com:8090/display/FPSDK/XML+Components  not for registerbridge
//
//  okWireIn     wi00(.okHE(okHE),                              .ep_addr(8'h00),                    .ep_dataout(ep00wire));
//  okWireIn     wi01(.okHE(okHE),                              .ep_addr(8'h01),                    .ep_dataout(ep01wire));
//  okWireIn     wi02(.okHE(okHE),                              .ep_addr(8'h02),                    .ep_dataout(ep02wire));
//  okWireIn     wi03(.okHE(okHE),                              .ep_addr(8'h03),                    .ep_dataout(ep03wire));
//  okWireIn     wi04(.okHE(okHE),                              .ep_addr(8'h04),                    .ep_dataout(ep04wire));
//  okWireIn     wi05(.okHE(okHE),                              .ep_addr(8'h05),                    .ep_dataout(ep05wire));
//  okWireIn     wi06(.okHE(okHE),                              .ep_addr(8'h06),                    .ep_dataout(ep06wire));
//  okWireIn     wi07(.okHE(okHE),                              .ep_addr(8'h07),                    .ep_dataout(ep07wire));
//  okWireIn     wi08(.okHE(okHE),                              .ep_addr(8'h08),                    .ep_dataout(ep08wire));
//  okWireIn     wi09(.okHE(okHE),                              .ep_addr(8'h09),                    .ep_dataout(ep09wire));
//  okWireIn     wi0A(.okHE(okHE),                              .ep_addr(8'h0A),                    .ep_dataout(ep0Awire));
//  okWireIn     wi0B(.okHE(okHE),                              .ep_addr(8'h0B),                    .ep_dataout(ep0Bwire));
//  okWireIn     wi0C(.okHE(okHE),                              .ep_addr(8'h0C),                    .ep_dataout(ep0Cwire));
//  okWireIn     wi0D(.okHE(okHE),                              .ep_addr(8'h0D),                    .ep_dataout(ep0Dwire));
//  okWireIn     wi0E(.okHE(okHE),                              .ep_addr(8'h0E),                    .ep_dataout(ep0Ewire));
//  okWireIn     wi0F(.okHE(okHE),                              .ep_addr(8'h0F),                    .ep_dataout(ep0Fwire));
//  okWireIn     wi10(.okHE(okHE),                              .ep_addr(8'h10),                    .ep_dataout(ep10wire));
//  okWireIn     wi11(.okHE(okHE),                              .ep_addr(8'h11),                    .ep_dataout(ep11wire));
//  okWireIn     wi12(.okHE(okHE),                              .ep_addr(8'h12),                    .ep_dataout(ep12wire));
//  okWireIn     wi13(.okHE(okHE),                              .ep_addr(8'h13),                    .ep_dataout(ep13wire));
//  okWireIn     wi14(.okHE(okHE),                              .ep_addr(8'h14),                    .ep_dataout(ep14wire));
//  okWireIn     wi15(.okHE(okHE),                              .ep_addr(8'h15),                    .ep_dataout(ep15wire));
//  okWireIn     wi16(.okHE(okHE),                              .ep_addr(8'h16),                    .ep_dataout(ep16wire));
//  okWireIn     wi17(.okHE(okHE),                              .ep_addr(8'h17),                    .ep_dataout(ep17wire));
//  okWireIn     wi18(.okHE(okHE),                              .ep_addr(8'h18),                    .ep_dataout(ep18wire));
//  okWireIn     wi19(.okHE(okHE),                              .ep_addr(8'h19),                    .ep_dataout(ep19wire));
//  okWireIn     wi1A(.okHE(okHE),                              .ep_addr(8'h1A),                    .ep_dataout(ep1Awire)); 
//  okWireIn     wi1B(.okHE(okHE),                              .ep_addr(8'h1B),                    .ep_dataout(ep1Bwire)); 
//  okWireIn     wi1C(.okHE(okHE),                              .ep_addr(8'h1C),                    .ep_dataout(ep1Cwire)); 
//  okWireIn     wi1D(.okHE(okHE),                              .ep_addr(8'h1D),                    .ep_dataout(ep1Dwire)); 
//  okWireIn     wi1E(.okHE(okHE),                              .ep_addr(8'h1E),                    .ep_dataout(ep1Ewire));
//  okWireIn     wi1F(.okHE(okHE),                              .ep_addr(8'h1F),                    .ep_dataout(ep1Fwire));
//  //
//  okWireOut    wo20(.okHE(okHE), .okEH(okEHx[ 00*65 +: 65 ]), .ep_addr(8'h20),                     .ep_datain(ep20wire));
//  okWireOut    wo21(.okHE(okHE), .okEH(okEHx[ 01*65 +: 65 ]), .ep_addr(8'h21),                     .ep_datain(ep21wire));
//  okWireOut    wo22(.okHE(okHE), .okEH(okEHx[ 02*65 +: 65 ]), .ep_addr(8'h22),                     .ep_datain(ep22wire));
//  okWireOut    wo23(.okHE(okHE), .okEH(okEHx[ 03*65 +: 65 ]), .ep_addr(8'h23),                     .ep_datain(ep23wire));
//  okWireOut    wo24(.okHE(okHE), .okEH(okEHx[ 04*65 +: 65 ]), .ep_addr(8'h24),                     .ep_datain(ep24wire));
//  okWireOut    wo25(.okHE(okHE), .okEH(okEHx[ 05*65 +: 65 ]), .ep_addr(8'h25),                     .ep_datain(ep25wire));
//  okWireOut    wo26(.okHE(okHE), .okEH(okEHx[ 06*65 +: 65 ]), .ep_addr(8'h26),                     .ep_datain(ep26wire));
//  okWireOut    wo27(.okHE(okHE), .okEH(okEHx[ 07*65 +: 65 ]), .ep_addr(8'h27),                     .ep_datain(ep27wire));
//  okWireOut    wo28(.okHE(okHE), .okEH(okEHx[ 08*65 +: 65 ]), .ep_addr(8'h28),                     .ep_datain(ep28wire));
//  okWireOut    wo29(.okHE(okHE), .okEH(okEHx[ 09*65 +: 65 ]), .ep_addr(8'h29),                     .ep_datain(ep29wire));
//  okWireOut    wo2A(.okHE(okHE), .okEH(okEHx[ 10*65 +: 65 ]), .ep_addr(8'h2A),                     .ep_datain(ep2Awire));
//  okWireOut    wo2B(.okHE(okHE), .okEH(okEHx[ 11*65 +: 65 ]), .ep_addr(8'h2B),                     .ep_datain(ep2Bwire));
//  okWireOut    wo2C(.okHE(okHE), .okEH(okEHx[ 12*65 +: 65 ]), .ep_addr(8'h2C),                     .ep_datain(ep2Cwire));
//  okWireOut    wo2D(.okHE(okHE), .okEH(okEHx[ 13*65 +: 65 ]), .ep_addr(8'h2D),                     .ep_datain(ep2Dwire));
//  okWireOut    wo2E(.okHE(okHE), .okEH(okEHx[ 14*65 +: 65 ]), .ep_addr(8'h2E),                     .ep_datain(ep2Ewire));
//  okWireOut    wo2F(.okHE(okHE), .okEH(okEHx[ 15*65 +: 65 ]), .ep_addr(8'h2F),                     .ep_datain(ep2Fwire));
//  okWireOut    wo30(.okHE(okHE), .okEH(okEHx[ 16*65 +: 65 ]), .ep_addr(8'h30),                     .ep_datain(ep30wire));
//  okWireOut    wo31(.okHE(okHE), .okEH(okEHx[ 17*65 +: 65 ]), .ep_addr(8'h31),                     .ep_datain(ep31wire));
//  okWireOut    wo32(.okHE(okHE), .okEH(okEHx[ 18*65 +: 65 ]), .ep_addr(8'h32),                     .ep_datain(ep32wire));
//  okWireOut    wo33(.okHE(okHE), .okEH(okEHx[ 19*65 +: 65 ]), .ep_addr(8'h33),                     .ep_datain(ep33wire));
//  okWireOut    wo34(.okHE(okHE), .okEH(okEHx[ 20*65 +: 65 ]), .ep_addr(8'h34),                     .ep_datain(ep34wire));
//  okWireOut    wo35(.okHE(okHE), .okEH(okEHx[ 21*65 +: 65 ]), .ep_addr(8'h35),                     .ep_datain(ep35wire));
//  okWireOut    wo36(.okHE(okHE), .okEH(okEHx[ 22*65 +: 65 ]), .ep_addr(8'h36),                     .ep_datain(ep36wire));
//  okWireOut    wo37(.okHE(okHE), .okEH(okEHx[ 23*65 +: 65 ]), .ep_addr(8'h37),                     .ep_datain(ep37wire));
//  okWireOut    wo38(.okHE(okHE), .okEH(okEHx[ 24*65 +: 65 ]), .ep_addr(8'h38),                     .ep_datain(ep38wire));
//  okWireOut    wo39(.okHE(okHE), .okEH(okEHx[ 25*65 +: 65 ]), .ep_addr(8'h39),                     .ep_datain(ep39wire));
//  okWireOut    wo3A(.okHE(okHE), .okEH(okEHx[ 26*65 +: 65 ]), .ep_addr(8'h3A),                     .ep_datain(ep3Awire));
//  okWireOut    wo3B(.okHE(okHE), .okEH(okEHx[ 27*65 +: 65 ]), .ep_addr(8'h3B),                     .ep_datain(ep3Bwire)); 
//  okWireOut    wo3C(.okHE(okHE), .okEH(okEHx[ 28*65 +: 65 ]), .ep_addr(8'h3C),                     .ep_datain(ep3Cwire)); 
//  okWireOut    wo3D(.okHE(okHE), .okEH(okEHx[ 29*65 +: 65 ]), .ep_addr(8'h3D),                     .ep_datain(ep3Dwire)); 
//  okWireOut    wo3E(.okHE(okHE), .okEH(okEHx[ 30*65 +: 65 ]), .ep_addr(8'h3E),                     .ep_datain(ep3Ewire));
//  okWireOut    wo3F(.okHE(okHE), .okEH(okEHx[ 31*65 +: 65 ]), .ep_addr(8'h3F),                     .ep_datain(ep3Fwire));
//  //
//  okTriggerIn  ti40(.okHE(okHE),                              .ep_addr(8'h40),   .ep_clk(ep40ck), .ep_trigger(ep40trig));
//  okTriggerIn  ti41(.okHE(okHE),                              .ep_addr(8'h41),   .ep_clk(ep41ck), .ep_trigger(ep41trig));
//  okTriggerIn  ti42(.okHE(okHE),                              .ep_addr(8'h42),   .ep_clk(ep42ck), .ep_trigger(ep42trig));
//  okTriggerIn  ti43(.okHE(okHE),                              .ep_addr(8'h43),   .ep_clk(ep43ck), .ep_trigger(ep43trig));
//  okTriggerIn  ti44(.okHE(okHE),                              .ep_addr(8'h44),   .ep_clk(ep44ck), .ep_trigger(ep44trig));
//  okTriggerIn  ti45(.okHE(okHE),                              .ep_addr(8'h45),   .ep_clk(ep45ck), .ep_trigger(ep45trig));
//  okTriggerIn  ti46(.okHE(okHE),                              .ep_addr(8'h46),   .ep_clk(ep46ck), .ep_trigger(ep46trig));
//  okTriggerIn  ti47(.okHE(okHE),                              .ep_addr(8'h47),   .ep_clk(ep47ck), .ep_trigger(ep47trig));
//  okTriggerIn  ti48(.okHE(okHE),                              .ep_addr(8'h48),   .ep_clk(ep48ck), .ep_trigger(ep48trig));
//  okTriggerIn  ti49(.okHE(okHE),                              .ep_addr(8'h49),   .ep_clk(ep49ck), .ep_trigger(ep49trig));
//  okTriggerIn  ti4A(.okHE(okHE),                              .ep_addr(8'h4A),   .ep_clk(ep4Ack), .ep_trigger(ep4Atrig));
//  okTriggerIn  ti4B(.okHE(okHE),                              .ep_addr(8'h4B),   .ep_clk(ep4Bck), .ep_trigger(ep4Btrig));
//  okTriggerIn  ti4C(.okHE(okHE),                              .ep_addr(8'h4C),   .ep_clk(ep4Cck), .ep_trigger(ep4Ctrig));
//  okTriggerIn  ti4D(.okHE(okHE),                              .ep_addr(8'h4D),   .ep_clk(ep4Dck), .ep_trigger(ep4Dtrig));
//  okTriggerIn  ti4E(.okHE(okHE),                              .ep_addr(8'h4E),   .ep_clk(ep4Eck), .ep_trigger(ep4Etrig));
//  okTriggerIn  ti4F(.okHE(okHE),                              .ep_addr(8'h4F),   .ep_clk(ep4Fck), .ep_trigger(ep4Ftrig));
//  okTriggerIn  ti50(.okHE(okHE),                              .ep_addr(8'h50),   .ep_clk(ep50ck), .ep_trigger(ep50trig));
//  okTriggerIn  ti51(.okHE(okHE),                              .ep_addr(8'h51),   .ep_clk(ep51ck), .ep_trigger(ep51trig));
//  okTriggerIn  ti52(.okHE(okHE),                              .ep_addr(8'h52),   .ep_clk(ep52ck), .ep_trigger(ep52trig));
//  okTriggerIn  ti53(.okHE(okHE),                              .ep_addr(8'h53),   .ep_clk(ep53ck), .ep_trigger(ep53trig));
//  okTriggerIn  ti54(.okHE(okHE),                              .ep_addr(8'h54),   .ep_clk(ep54ck), .ep_trigger(ep54trig));
//  okTriggerIn  ti55(.okHE(okHE),                              .ep_addr(8'h55),   .ep_clk(ep55ck), .ep_trigger(ep55trig));
//  okTriggerIn  ti56(.okHE(okHE),                              .ep_addr(8'h56),   .ep_clk(ep56ck), .ep_trigger(ep56trig));
//  okTriggerIn  ti57(.okHE(okHE),                              .ep_addr(8'h57),   .ep_clk(ep57ck), .ep_trigger(ep57trig));
//  okTriggerIn  ti58(.okHE(okHE),                              .ep_addr(8'h58),   .ep_clk(ep58ck), .ep_trigger(ep58trig));
//  okTriggerIn  ti59(.okHE(okHE),                              .ep_addr(8'h59),   .ep_clk(ep59ck), .ep_trigger(ep59trig));
//  okTriggerIn  ti5A(.okHE(okHE),                              .ep_addr(8'h5A),   .ep_clk(ep5Ack), .ep_trigger(ep5Atrig));
//  okTriggerIn  ti5B(.okHE(okHE),                              .ep_addr(8'h5B),   .ep_clk(ep5Bck), .ep_trigger(ep5Btrig));
//  okTriggerIn  ti5C(.okHE(okHE),                              .ep_addr(8'h5C),   .ep_clk(ep5Cck), .ep_trigger(ep5Ctrig));
//  okTriggerIn  ti5D(.okHE(okHE),                              .ep_addr(8'h5D),   .ep_clk(ep5Dck), .ep_trigger(ep5Dtrig));
//  okTriggerIn  ti5E(.okHE(okHE),                              .ep_addr(8'h5E),   .ep_clk(ep5Eck), .ep_trigger(ep5Etrig));
//  okTriggerIn  ti5F(.okHE(okHE),                              .ep_addr(8'h5F),   .ep_clk(ep5Fck), .ep_trigger(ep5Ftrig));
//  //
//  okTriggerOut to60(.okHE(okHE), .okEH(okEHx[ 32*65 +: 65 ]), .ep_addr(8'h60),   .ep_clk(ep60ck), .ep_trigger(ep60trig));
//  okTriggerOut to61(.okHE(okHE), .okEH(okEHx[ 33*65 +: 65 ]), .ep_addr(8'h61),   .ep_clk(ep61ck), .ep_trigger(ep61trig));
//  okTriggerOut to62(.okHE(okHE), .okEH(okEHx[ 34*65 +: 65 ]), .ep_addr(8'h62),   .ep_clk(ep62ck), .ep_trigger(ep62trig));
//  okTriggerOut to63(.okHE(okHE), .okEH(okEHx[ 35*65 +: 65 ]), .ep_addr(8'h63),   .ep_clk(ep63ck), .ep_trigger(ep63trig));
//  okTriggerOut to64(.okHE(okHE), .okEH(okEHx[ 36*65 +: 65 ]), .ep_addr(8'h64),   .ep_clk(ep64ck), .ep_trigger(ep64trig));
//  okTriggerOut to65(.okHE(okHE), .okEH(okEHx[ 37*65 +: 65 ]), .ep_addr(8'h65),   .ep_clk(ep65ck), .ep_trigger(ep65trig));
//  okTriggerOut to66(.okHE(okHE), .okEH(okEHx[ 38*65 +: 65 ]), .ep_addr(8'h66),   .ep_clk(ep66ck), .ep_trigger(ep66trig));
//  okTriggerOut to67(.okHE(okHE), .okEH(okEHx[ 39*65 +: 65 ]), .ep_addr(8'h67),   .ep_clk(ep67ck), .ep_trigger(ep67trig));
//  okTriggerOut to68(.okHE(okHE), .okEH(okEHx[ 40*65 +: 65 ]), .ep_addr(8'h68),   .ep_clk(ep68ck), .ep_trigger(ep68trig));
//  okTriggerOut to69(.okHE(okHE), .okEH(okEHx[ 41*65 +: 65 ]), .ep_addr(8'h69),   .ep_clk(ep69ck), .ep_trigger(ep69trig));
//  okTriggerOut to6A(.okHE(okHE), .okEH(okEHx[ 42*65 +: 65 ]), .ep_addr(8'h6A),   .ep_clk(ep6Ack), .ep_trigger(ep6Atrig));
//  okTriggerOut to6B(.okHE(okHE), .okEH(okEHx[ 43*65 +: 65 ]), .ep_addr(8'h6B),   .ep_clk(ep6Bck), .ep_trigger(ep6Btrig));
//  okTriggerOut to6C(.okHE(okHE), .okEH(okEHx[ 44*65 +: 65 ]), .ep_addr(8'h6C),   .ep_clk(ep6Cck), .ep_trigger(ep6Ctrig));
//  okTriggerOut to6D(.okHE(okHE), .okEH(okEHx[ 45*65 +: 65 ]), .ep_addr(8'h6D),   .ep_clk(ep6Dck), .ep_trigger(ep6Dtrig));
//  okTriggerOut to6E(.okHE(okHE), .okEH(okEHx[ 46*65 +: 65 ]), .ep_addr(8'h6E),   .ep_clk(ep6Eck), .ep_trigger(ep6Etrig));
//  okTriggerOut to6F(.okHE(okHE), .okEH(okEHx[ 47*65 +: 65 ]), .ep_addr(8'h6F),   .ep_clk(ep6Fck), .ep_trigger(ep6Ftrig));
//  okTriggerOut to70(.okHE(okHE), .okEH(okEHx[ 48*65 +: 65 ]), .ep_addr(8'h70),   .ep_clk(ep70ck), .ep_trigger(ep70trig));
//  okTriggerOut to71(.okHE(okHE), .okEH(okEHx[ 49*65 +: 65 ]), .ep_addr(8'h71),   .ep_clk(ep71ck), .ep_trigger(ep71trig));
//  okTriggerOut to72(.okHE(okHE), .okEH(okEHx[ 50*65 +: 65 ]), .ep_addr(8'h72),   .ep_clk(ep72ck), .ep_trigger(ep72trig));
//  okTriggerOut to73(.okHE(okHE), .okEH(okEHx[ 51*65 +: 65 ]), .ep_addr(8'h73),   .ep_clk(ep73ck), .ep_trigger(ep73trig));
//  okTriggerOut to74(.okHE(okHE), .okEH(okEHx[ 52*65 +: 65 ]), .ep_addr(8'h74),   .ep_clk(ep74ck), .ep_trigger(ep74trig));
//  okTriggerOut to75(.okHE(okHE), .okEH(okEHx[ 53*65 +: 65 ]), .ep_addr(8'h75),   .ep_clk(ep75ck), .ep_trigger(ep75trig));
//  okTriggerOut to76(.okHE(okHE), .okEH(okEHx[ 54*65 +: 65 ]), .ep_addr(8'h76),   .ep_clk(ep76ck), .ep_trigger(ep76trig));
//  okTriggerOut to77(.okHE(okHE), .okEH(okEHx[ 55*65 +: 65 ]), .ep_addr(8'h77),   .ep_clk(ep77ck), .ep_trigger(ep77trig));
//  okTriggerOut to78(.okHE(okHE), .okEH(okEHx[ 56*65 +: 65 ]), .ep_addr(8'h78),   .ep_clk(ep78ck), .ep_trigger(ep78trig));
//  okTriggerOut to79(.okHE(okHE), .okEH(okEHx[ 57*65 +: 65 ]), .ep_addr(8'h79),   .ep_clk(ep79ck), .ep_trigger(ep79trig));
//  okTriggerOut to7A(.okHE(okHE), .okEH(okEHx[ 58*65 +: 65 ]), .ep_addr(8'h7A),   .ep_clk(ep7Ack), .ep_trigger(ep7Atrig));
//  okTriggerOut to7B(.okHE(okHE), .okEH(okEHx[ 59*65 +: 65 ]), .ep_addr(8'h7B),   .ep_clk(ep7Bck), .ep_trigger(ep7Btrig));
//  okTriggerOut to7C(.okHE(okHE), .okEH(okEHx[ 60*65 +: 65 ]), .ep_addr(8'h7C),   .ep_clk(ep7Cck), .ep_trigger(ep7Ctrig));
//  okTriggerOut to7D(.okHE(okHE), .okEH(okEHx[ 61*65 +: 65 ]), .ep_addr(8'h7D),   .ep_clk(ep7Dck), .ep_trigger(ep7Dtrig));
//  okTriggerOut to7E(.okHE(okHE), .okEH(okEHx[ 62*65 +: 65 ]), .ep_addr(8'h7E),   .ep_clk(ep7Eck), .ep_trigger(ep7Etrig));
//  okTriggerOut to7F(.okHE(okHE), .okEH(okEHx[ 63*65 +: 65 ]), .ep_addr(8'h7F),   .ep_clk(ep7Fck), .ep_trigger(ep7Ftrig));
//  //
//  okPipeIn     pi80(.okHE(okHE), .okEH(okEHx[ 64*65 +: 65 ]), .ep_addr(8'h80), .ep_write(ep80wr), .ep_dataout(ep80pipe));
//  okPipeIn     pi81(.okHE(okHE), .okEH(okEHx[ 65*65 +: 65 ]), .ep_addr(8'h81), .ep_write(ep81wr), .ep_dataout(ep81pipe));
//  okPipeIn     pi82(.okHE(okHE), .okEH(okEHx[ 66*65 +: 65 ]), .ep_addr(8'h82), .ep_write(ep82wr), .ep_dataout(ep82pipe));
//  okPipeIn     pi83(.okHE(okHE), .okEH(okEHx[ 67*65 +: 65 ]), .ep_addr(8'h83), .ep_write(ep83wr), .ep_dataout(ep83pipe));
//  okPipeIn     pi84(.okHE(okHE), .okEH(okEHx[ 68*65 +: 65 ]), .ep_addr(8'h84), .ep_write(ep84wr), .ep_dataout(ep84pipe));
//  okPipeIn     pi85(.okHE(okHE), .okEH(okEHx[ 69*65 +: 65 ]), .ep_addr(8'h85), .ep_write(ep85wr), .ep_dataout(ep85pipe));
//  okPipeIn     pi86(.okHE(okHE), .okEH(okEHx[ 70*65 +: 65 ]), .ep_addr(8'h86), .ep_write(ep86wr), .ep_dataout(ep86pipe));
//  okPipeIn     pi87(.okHE(okHE), .okEH(okEHx[ 71*65 +: 65 ]), .ep_addr(8'h87), .ep_write(ep87wr), .ep_dataout(ep87pipe));
//  okPipeIn     pi88(.okHE(okHE), .okEH(okEHx[ 72*65 +: 65 ]), .ep_addr(8'h88), .ep_write(ep88wr), .ep_dataout(ep88pipe));
//  okPipeIn     pi89(.okHE(okHE), .okEH(okEHx[ 73*65 +: 65 ]), .ep_addr(8'h89), .ep_write(ep89wr), .ep_dataout(ep89pipe));
//  okPipeIn     pi8A(.okHE(okHE), .okEH(okEHx[ 74*65 +: 65 ]), .ep_addr(8'h8A), .ep_write(ep8Awr), .ep_dataout(ep8Apipe));
//  okPipeIn     pi8B(.okHE(okHE), .okEH(okEHx[ 75*65 +: 65 ]), .ep_addr(8'h8B), .ep_write(ep8Bwr), .ep_dataout(ep8Bpipe));
//  okPipeIn     pi8C(.okHE(okHE), .okEH(okEHx[ 76*65 +: 65 ]), .ep_addr(8'h8C), .ep_write(ep8Cwr), .ep_dataout(ep8Cpipe));
//  okPipeIn     pi8D(.okHE(okHE), .okEH(okEHx[ 77*65 +: 65 ]), .ep_addr(8'h8D), .ep_write(ep8Dwr), .ep_dataout(ep8Dpipe));
//  okPipeIn     pi8E(.okHE(okHE), .okEH(okEHx[ 78*65 +: 65 ]), .ep_addr(8'h8E), .ep_write(ep8Ewr), .ep_dataout(ep8Epipe));
//  okPipeIn     pi8F(.okHE(okHE), .okEH(okEHx[ 79*65 +: 65 ]), .ep_addr(8'h8F), .ep_write(ep8Fwr), .ep_dataout(ep8Fpipe));
//  okPipeIn     pi90(.okHE(okHE), .okEH(okEHx[ 80*65 +: 65 ]), .ep_addr(8'h90), .ep_write(ep90wr), .ep_dataout(ep90pipe));
//  okPipeIn     pi91(.okHE(okHE), .okEH(okEHx[ 81*65 +: 65 ]), .ep_addr(8'h91), .ep_write(ep91wr), .ep_dataout(ep91pipe));
//  okPipeIn     pi92(.okHE(okHE), .okEH(okEHx[ 82*65 +: 65 ]), .ep_addr(8'h92), .ep_write(ep92wr), .ep_dataout(ep92pipe));
//  okPipeIn     pi93(.okHE(okHE), .okEH(okEHx[ 83*65 +: 65 ]), .ep_addr(8'h93), .ep_write(ep93wr), .ep_dataout(ep93pipe));
//  okPipeIn     pi94(.okHE(okHE), .okEH(okEHx[ 84*65 +: 65 ]), .ep_addr(8'h94), .ep_write(ep94wr), .ep_dataout(ep94pipe));
//  okPipeIn     pi95(.okHE(okHE), .okEH(okEHx[ 85*65 +: 65 ]), .ep_addr(8'h95), .ep_write(ep95wr), .ep_dataout(ep95pipe));
//  okPipeIn     pi96(.okHE(okHE), .okEH(okEHx[ 86*65 +: 65 ]), .ep_addr(8'h96), .ep_write(ep96wr), .ep_dataout(ep96pipe));
//  okPipeIn     pi97(.okHE(okHE), .okEH(okEHx[ 87*65 +: 65 ]), .ep_addr(8'h97), .ep_write(ep97wr), .ep_dataout(ep97pipe));
//  okPipeIn     pi98(.okHE(okHE), .okEH(okEHx[ 88*65 +: 65 ]), .ep_addr(8'h98), .ep_write(ep98wr), .ep_dataout(ep98pipe));
//  okPipeIn     pi99(.okHE(okHE), .okEH(okEHx[ 89*65 +: 65 ]), .ep_addr(8'h99), .ep_write(ep99wr), .ep_dataout(ep99pipe));
//  okPipeIn     pi9A(.okHE(okHE), .okEH(okEHx[ 90*65 +: 65 ]), .ep_addr(8'h9A), .ep_write(ep9Awr), .ep_dataout(ep9Apipe));
//  okPipeIn     pi9B(.okHE(okHE), .okEH(okEHx[ 91*65 +: 65 ]), .ep_addr(8'h9B), .ep_write(ep9Bwr), .ep_dataout(ep9Bpipe));
//  okPipeIn     pi9C(.okHE(okHE), .okEH(okEHx[ 92*65 +: 65 ]), .ep_addr(8'h9C), .ep_write(ep9Cwr), .ep_dataout(ep9Cpipe));
//  okPipeIn     pi9D(.okHE(okHE), .okEH(okEHx[ 93*65 +: 65 ]), .ep_addr(8'h9D), .ep_write(ep9Dwr), .ep_dataout(ep9Dpipe));
//  okPipeIn     pi9E(.okHE(okHE), .okEH(okEHx[ 94*65 +: 65 ]), .ep_addr(8'h9E), .ep_write(ep9Ewr), .ep_dataout(ep9Epipe));
//  okPipeIn     pi9F(.okHE(okHE), .okEH(okEHx[ 95*65 +: 65 ]), .ep_addr(8'h9F), .ep_write(ep9Fwr), .ep_dataout(ep9Fpipe));
//  //
//  okPipeOut    poA0(.okHE(okHE), .okEH(okEHx[ 96*65 +: 65 ]), .ep_addr(8'hA0),  .ep_read(epA0rd),  .ep_datain(epA0pipe));
//  okPipeOut    poA1(.okHE(okHE), .okEH(okEHx[ 97*65 +: 65 ]), .ep_addr(8'hA1),  .ep_read(epA1rd),  .ep_datain(epA1pipe));
//  okPipeOut    poA2(.okHE(okHE), .okEH(okEHx[ 98*65 +: 65 ]), .ep_addr(8'hA2),  .ep_read(epA2rd),  .ep_datain(epA2pipe));
//  okPipeOut    poA3(.okHE(okHE), .okEH(okEHx[ 99*65 +: 65 ]), .ep_addr(8'hA3),  .ep_read(epA3rd),  .ep_datain(epA3pipe));
//  okPipeOut    poA4(.okHE(okHE), .okEH(okEHx[100*65 +: 65 ]), .ep_addr(8'hA4),  .ep_read(epA4rd),  .ep_datain(epA4pipe));
//  okPipeOut    poA5(.okHE(okHE), .okEH(okEHx[101*65 +: 65 ]), .ep_addr(8'hA5),  .ep_read(epA5rd),  .ep_datain(epA5pipe));
//  okPipeOut    poA6(.okHE(okHE), .okEH(okEHx[102*65 +: 65 ]), .ep_addr(8'hA6),  .ep_read(epA6rd),  .ep_datain(epA6pipe));
//  okPipeOut    poA7(.okHE(okHE), .okEH(okEHx[103*65 +: 65 ]), .ep_addr(8'hA7),  .ep_read(epA7rd),  .ep_datain(epA7pipe));
//  okPipeOut    poA8(.okHE(okHE), .okEH(okEHx[104*65 +: 65 ]), .ep_addr(8'hA8),  .ep_read(epA8rd),  .ep_datain(epA8pipe));
//  okPipeOut    poA9(.okHE(okHE), .okEH(okEHx[105*65 +: 65 ]), .ep_addr(8'hA9),  .ep_read(epA9rd),  .ep_datain(epA9pipe));
//  okPipeOut    poAA(.okHE(okHE), .okEH(okEHx[106*65 +: 65 ]), .ep_addr(8'hAA),  .ep_read(epAArd),  .ep_datain(epAApipe));
//  okPipeOut    poAB(.okHE(okHE), .okEH(okEHx[107*65 +: 65 ]), .ep_addr(8'hAB),  .ep_read(epABrd),  .ep_datain(epABpipe));
//  okPipeOut    poAC(.okHE(okHE), .okEH(okEHx[108*65 +: 65 ]), .ep_addr(8'hAC),  .ep_read(epACrd),  .ep_datain(epACpipe));
//  okPipeOut    poAD(.okHE(okHE), .okEH(okEHx[109*65 +: 65 ]), .ep_addr(8'hAD),  .ep_read(epADrd),  .ep_datain(epADpipe));
//  okPipeOut    poAE(.okHE(okHE), .okEH(okEHx[110*65 +: 65 ]), .ep_addr(8'hAE),  .ep_read(epAErd),  .ep_datain(epAEpipe));
//  okPipeOut    poAF(.okHE(okHE), .okEH(okEHx[111*65 +: 65 ]), .ep_addr(8'hAF),  .ep_read(epAFrd),  .ep_datain(epAFpipe));
//  okPipeOut    poB0(.okHE(okHE), .okEH(okEHx[112*65 +: 65 ]), .ep_addr(8'hB0),  .ep_read(epB0rd),  .ep_datain(epB0pipe));
//  okPipeOut    poB1(.okHE(okHE), .okEH(okEHx[113*65 +: 65 ]), .ep_addr(8'hB1),  .ep_read(epB1rd),  .ep_datain(epB1pipe));
//  okPipeOut    poB2(.okHE(okHE), .okEH(okEHx[114*65 +: 65 ]), .ep_addr(8'hB2),  .ep_read(epB2rd),  .ep_datain(epB2pipe));
//  okPipeOut    poB3(.okHE(okHE), .okEH(okEHx[115*65 +: 65 ]), .ep_addr(8'hB3),  .ep_read(epB3rd),  .ep_datain(epB3pipe));
//  okPipeOut    poB4(.okHE(okHE), .okEH(okEHx[116*65 +: 65 ]), .ep_addr(8'hB4),  .ep_read(epB4rd),  .ep_datain(epB4pipe));
//  okPipeOut    poB5(.okHE(okHE), .okEH(okEHx[117*65 +: 65 ]), .ep_addr(8'hB5),  .ep_read(epB5rd),  .ep_datain(epB5pipe));
//  okPipeOut    poB6(.okHE(okHE), .okEH(okEHx[118*65 +: 65 ]), .ep_addr(8'hB6),  .ep_read(epB6rd),  .ep_datain(epB6pipe));
//  okPipeOut    poB7(.okHE(okHE), .okEH(okEHx[119*65 +: 65 ]), .ep_addr(8'hB7),  .ep_read(epB7rd),  .ep_datain(epB7pipe));
//  okPipeOut    poB8(.okHE(okHE), .okEH(okEHx[120*65 +: 65 ]), .ep_addr(8'hB8),  .ep_read(epB8rd),  .ep_datain(epB8pipe));
//  okPipeOut    poB9(.okHE(okHE), .okEH(okEHx[121*65 +: 65 ]), .ep_addr(8'hB9),  .ep_read(epB9rd),  .ep_datain(epB9pipe));
//  okPipeOut    poBA(.okHE(okHE), .okEH(okEHx[122*65 +: 65 ]), .ep_addr(8'hBA),  .ep_read(epBArd),  .ep_datain(epBApipe));
//  okPipeOut    poBB(.okHE(okHE), .okEH(okEHx[123*65 +: 65 ]), .ep_addr(8'hBB),  .ep_read(epBBrd),  .ep_datain(epBBpipe));
//  okPipeOut    poBC(.okHE(okHE), .okEH(okEHx[124*65 +: 65 ]), .ep_addr(8'hBC),  .ep_read(epBCrd),  .ep_datain(epBCpipe));
//  okPipeOut    poBD(.okHE(okHE), .okEH(okEHx[125*65 +: 65 ]), .ep_addr(8'hBD),  .ep_read(epBDrd),  .ep_datain(epBDpipe));
//  okPipeOut    poBE(.okHE(okHE), .okEH(okEHx[126*65 +: 65 ]), .ep_addr(8'hBE),  .ep_read(epBErd),  .ep_datain(epBEpipe));
//  okPipeOut    poBF(.okHE(okHE), .okEH(okEHx[127*65 +: 65 ]), .ep_addr(8'hBF),  .ep_read(epBFrd),  .ep_datain(epBFpipe));

endmodule