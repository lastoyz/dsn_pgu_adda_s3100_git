//------------------------------------------------------------------------
// lan_endpoint_wrapper.v
//

// lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1
//    master_spi_wz850
//    mcs_io_bridge
//   
//  conf 1) initial setup
//    [master_spi_wz850]    <--> lan spi  interface 
//    [mcs_io_bridge_inst0] 
//    [microblaze_mcs_1]    // main controller with dual bus
//    [mcs_io_bridge_inst1] <--> end-points
//
//  conf 2) minimal footprint // try this
//    [microblaze_mcs_1]    // controller with single bus
//    [mcs_io_bridge_inst2] <--> end-points
//                          <--> LAN dedicated end-points (2WI, 2WO, 2TI, 2TO, 2PI, 2PO)
//                               [master_spi_wz850]    <--> lan spi  interface 
//
//  conf 3) independent control, fast response
//    [master_spi_wz850]    <--> lan spi  interface 
//    [mcs_io_bridge_inst0] 
//    [microblaze_mcs_0] 
//    [blk_mem_gen_0]       // dual port memory
//    [microblaze_mcs_1] 
//    [mcs_io_bridge_inst1] <--> end-points
//    

// check microblaze_mcs_   in PGU 
//microblaze_mcs_1  soft_cpu_mcs_inst (
//	.Clk(clk3_out1_72M),                  // input wire Clk
//	.Reset(reset),                     // input wire Reset
//	//
//	.IO_addr_strobe(IO_addr_strobe),    // output wire IO_addr_strobe
//	.IO_address(IO_address),            // output wire [31 : 0] IO_address
//	.IO_byte_enable(IO_byte_enable),    // output wire [3 : 0] IO_byte_enable
//	.IO_read_data(IO_read_data),        // input  wire [31 : 0] IO_read_data
//	.IO_read_strobe(IO_read_strobe),    // output wire IO_read_strobe
//	.IO_ready(IO_ready),                // input  wire IO_ready
//	.IO_write_data(IO_write_data),      // output wire [31 : 0] IO_write_data
//	.IO_write_strobe(IO_write_strobe)   // output wire IO_write_strobe
//);

// check microblaze_mcs_   in CMU 
//microblaze_mcs_0 mcs_inst (
//	.Clk(clk3_out1_72M),                // input wire Clk
//	.Reset(reset),                      // input wire Reset
//	//
//	.FIT1_Toggle(FIT1_Toggle),          // output wire FIT1_Toggle
//	.PIT1_Toggle(PIT1_Toggle),          // output wire PIT1_Toggle	
//	//.PIT1_Interrupt(PIT1_Interrupt),    // output wire PIT1_Interrupt
//	//
//	.IO_addr_strobe(IO_addr_strobe),    // output wire IO_addr_strobe
//	.IO_address(IO_address),            // output wire [31 : 0] IO_address
//	.IO_byte_enable(IO_byte_enable),    // output wire [3 : 0] IO_byte_enable
//	.IO_read_data(IO_read_data),        // input  wire [31 : 0] IO_read_data
//	.IO_read_strobe(IO_read_strobe),    // output wire IO_read_strobe
//	.IO_ready(IO_ready),                // input  wire IO_ready
//	.IO_write_data(IO_write_data),      // output wire [31 : 0] IO_write_data
//	.IO_write_strobe(IO_write_strobe),  // output wire IO_write_strobe
//	//
//	//.UART_rxd(UART_rxd),                // input wire UART_rxd
//	//.UART_txd(UART_txd),                // output wire UART_txd
//	//
//	.INTC_IRQ(INTC_IRQ),                // output wire INTC_IRQ
//	//.UART_Interrupt(UART_Interrupt),    // output wire UART_Interrupt
//	.INTC_Interrupt(INTC_Interrupt),    // input wire [0 : 0] INTC_Interrupt
//	//
//	.GPIO1_tri_i(GPIO1_tri_i),          // input  wire [31 : 0] GPIO1_tri_i
//	.GPIO1_tri_o(GPIO1_tri_o)           // output wire [31 : 0] GPIO1_tri_o
//);

// 
//------------------------------------------------------------------------

//$$`default_nettype none

module lan_endpoint_wrapper (

	// EP_LAN pins 
	output wire     EP_LAN_MOSI  ,
	output wire     EP_LAN_SCLK  ,
	output wire     EP_LAN_CS_B  ,
	input  wire     EP_LAN_INT_B ,
	output wire     EP_LAN_RST_B , 
	input  wire     EP_LAN_MISO  ,
	
	// for common 
	input  wire        clk     , // 10MHz
	input  wire        reset_n ,	
	
	// soft CPU clock
	input  wire        mcs_clk , // 72MHz
	
	// dedicated LAN clock 
	input  wire        lan_clk , // 144MHz
	
	// configuration bits //{
	// MAC/IP address offsets
	input  wire [47:0] i_adrs_offset_mac_48b ,
	input  wire [31:0] i_adrs_offset_ip_32b  ,
	// LAN timeout setup
	input  wire [15:0] i_offset_lan_timeout_rtr_16b ,
	input  wire [15:0] i_offset_lan_timeout_rcr_16b ,
	//}
	
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
	output wire ep80wr, output wire [31:0] ep80pipe,
	output wire ep81wr, output wire [31:0] ep81pipe, 
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
	output wire epPPck // sync with write/read of pipe // from mcs_clk
	);


// parameters from outside
parameter XPAR_IOMODULE_IO_BASEADDR   = 32'h_C000_0000; 
parameter MCS_IO_INST_OFFSET          = 32'h_0003_0000; // 32'h_0001_0000
parameter FPGA_IMAGE_ID               = 32'h_CDCD_CDCD;  
parameter BASE_ADRS_MAC_48B           = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ← 48 bits
parameter BASE_ADRS_IP_32B            = {8'd192,8'd168,8'd168,8'd128}; // 192.168.168.112 or C0:A8:A8:80 ← 32 bits
parameter BASE_LAN_TIMEOUT_RTR_16B    = 16'd2048; // 
parameter BASE_LAN_TIMEOUT_RCR_16B    = 16'd24;   // 

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


// assign epPPck
assign epPPck = (r_valid)? mcs_clk : 1'b0;


//// test output for EP_LAN //{
// assign  EP_LAN_MOSI  = 1'b0; // test 
// assign  EP_LAN_SCLK  = 1'b0; // test 
// assign  EP_LAN_CS_B  = 1'b1; // test 
// assign  EP_LAN_RST_B = 1'b1; // test 
//}


/* soft CPU */ //{ 

// try a single bus

// wires //{
wire          IO_addr_strobe ;
wire [31 : 0] IO_address     ; // 
wire [3 : 0]  IO_byte_enable ; // 
wire [31 : 0] IO_read_data   ; //
wire          IO_read_strobe ;
wire          IO_ready       ;
wire [31 : 0] IO_write_data  ; //
wire          IO_write_strobe;

// for dual bus option
//(* keep = "true" *) wire IO_ready_0           ;
//(* keep = "true" *) wire IO_ready_1           ;
//(* keep = "true" *) wire IO_ready_ref_0       ;
//(* keep = "true" *) wire IO_ready_ref_1       ;
//(* keep = "true" *) wire [31:0] IO_read_data_0;
//(* keep = "true" *) wire [31:0] IO_read_data_1;
//
// assign IO_ready = IO_ready_ref_0 | IO_ready_ref_1;
// assign IO_read_data = 	(IO_ready_0)? IO_read_data_0: 
// 						(IO_ready_1)? IO_read_data_1: 
// 									  32'hC3C3_C3C3;

//}


// TODO: microblaze_mcs_1 //{
microblaze_mcs_1  soft_cpu_mcs_inst (
	.Clk   (mcs_clk),                   // input wire Clk
	.Reset (~reset_n),                  // input wire Reset
	//
	.IO_addr_strobe(IO_addr_strobe),    // output wire IO_addr_strobe
	.IO_address(IO_address),            // output wire [31 : 0] IO_address
	.IO_byte_enable(IO_byte_enable),    // output wire [3 : 0] IO_byte_enable
	.IO_read_data(IO_read_data),        // input  wire [31 : 0] IO_read_data
	.IO_read_strobe(IO_read_strobe),    // output wire IO_read_strobe
	.IO_ready(IO_ready),                // input  wire IO_ready
	.IO_write_data(IO_write_data),      // output wire [31 : 0] IO_write_data
	.IO_write_strobe(IO_write_strobe)   // output wire IO_write_strobe
);
//}

//}


/* MCS to IO bridge for END-POINTS */ //{ 
  
// wires //{

//// dedicated LAN interface 
wire [31:0] w_lan_wi_00;
wire [31:0] w_lan_wi_01;
wire [31:0] w_lan_wo_20;
//
wire w_lan_ck_40 = lan_clk; wire [31:0] w_lan_ti_40;
wire w_lan_ck_60 = lan_clk; wire [31:0] w_lan_to_60;
//
wire        w_lan_wr_80; wire [31:0] w_lan_pi_80;
wire        w_lan_rd_A0; wire [31:0] w_lan_po_A0;

//}

// TODO: mcs_io_bridge_inst2 //{
mcs_io_bridge_ext #(
	.XPAR_IOMODULE_IO_BASEADDR  (XPAR_IOMODULE_IO_BASEADDR),
	.MCS_IO_INST_OFFSET         (MCS_IO_INST_OFFSET       ),// instance offset
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID            )  
) mcs_io_bridge_inst2 (
	.clk                    (mcs_clk), // assume clk3_out1_72M
	.reset_n                (reset_n),
	
	//// IO bus //{
	.i_IO_addr_strobe(IO_addr_strobe),    // input  wire IO_addr_strobe
	.i_IO_address(IO_address),            // input  wire [31 : 0] IO_address
	.i_IO_byte_enable(IO_byte_enable),    // input  wire [3 : 0] IO_byte_enable
	.o_IO_read_data(IO_read_data),        // output wire [31 : 0] IO_read_data
	.i_IO_read_strobe(IO_read_strobe),    // input  wire IO_read_strobe
	.o_IO_ready(IO_ready),                // output wire IO_ready
	.o_IO_ready_ref(),                    // output wire IO_ready_ref IO ready without address check
	.i_IO_write_data(IO_write_data),      // input  wire [31 : 0] IO_write_data
	.i_IO_write_strobe(IO_write_strobe),  // input  wire IO_write_strobe
	//}
	
	//// IO port
	
	// WI //{
	
	.o_port_wi_00        (ep00wire),          // output wire [31:0]
	.o_port_wi_01        (ep01wire),          // output wire [31:0]
	.o_port_wi_02        (ep02wire),          // output wire [31:0]
	.o_port_wi_03        (ep03wire),          // output wire [31:0]
	.o_port_wi_04        (ep04wire),          // output wire [31:0]
	.o_port_wi_05        (ep05wire),          // output wire [31:0]
	.o_port_wi_06        (ep06wire),          // output wire [31:0]
	.o_port_wi_07        (ep07wire),          // output wire [31:0]
	.o_port_wi_08        (ep08wire),          // output wire [31:0]
	.o_port_wi_09        (ep09wire),          // output wire [31:0]
	.o_port_wi_0A        (ep0Awire),          // output wire [31:0]
	.o_port_wi_0B        (ep0Bwire),          // output wire [31:0]
	.o_port_wi_0C        (ep0Cwire),          // output wire [31:0]
	.o_port_wi_0D        (ep0Dwire),          // output wire [31:0]
	.o_port_wi_0E        (ep0Ewire),          // output wire [31:0]
	.o_port_wi_0F        (ep0Fwire),          // output wire [31:0]
	.o_port_wi_10        (ep10wire),          // output wire [31:0]
	.o_port_wi_11        (ep11wire),          // output wire [31:0]
	.o_port_wi_12        (ep12wire),          // output wire [31:0]
	.o_port_wi_13        (ep13wire),          // output wire [31:0]
	.o_port_wi_14        (ep14wire),          // output wire [31:0]
	.o_port_wi_15        (ep15wire),          // output wire [31:0]
	.o_port_wi_16        (ep16wire),          // output wire [31:0]
	.o_port_wi_17        (ep17wire),          // output wire [31:0]
	.o_port_wi_18        (ep18wire),          // output wire [31:0]
	.o_port_wi_19        (ep19wire),          // output wire [31:0]
	.o_port_wi_1A        (ep1Awire),          // output wire [31:0]
	.o_port_wi_1B        (ep1Bwire),          // output wire [31:0]
	.o_port_wi_1C        (ep1Cwire),          // output wire [31:0]
	.o_port_wi_1D        (ep1Dwire),          // output wire [31:0]
	.o_port_wi_1E        (ep1Ewire),          // output wire [31:0]
	.o_port_wi_1F        (ep1Fwire),          // output wire [31:0]
	
	//}
	
	// WO //{
	
	.i_port_wo_20        (ep20wire),          // input  wire [31:0]
	.i_port_wo_21        (ep21wire),          // input  wire [31:0]
	.i_port_wo_22        (ep22wire),          // input  wire [31:0]
	.i_port_wo_23        (ep23wire),          // input  wire [31:0]
	.i_port_wo_24        (ep24wire),          // input  wire [31:0]
	.i_port_wo_25        (ep25wire),          // input  wire [31:0]
	.i_port_wo_26        (ep26wire),          // input  wire [31:0]
	.i_port_wo_27        (ep27wire),          // input  wire [31:0]
	.i_port_wo_28        (ep28wire),          // input  wire [31:0]
	.i_port_wo_29        (ep29wire),          // input  wire [31:0]
	.i_port_wo_2A        (ep2Awire),          // input  wire [31:0]
	.i_port_wo_2B        (ep2Bwire),          // input  wire [31:0]
	.i_port_wo_2C        (ep2Cwire),          // input  wire [31:0]
	.i_port_wo_2D        (ep2Dwire),          // input  wire [31:0]
	.i_port_wo_2E        (ep2Ewire),          // input  wire [31:0]
	.i_port_wo_2F        (ep2Fwire),          // input  wire [31:0]
	.i_port_wo_30        (ep30wire),          // input  wire [31:0]
	.i_port_wo_31        (ep31wire),          // input  wire [31:0]
	.i_port_wo_32        (ep32wire),          // input  wire [31:0]
	.i_port_wo_33        (ep33wire),          // input  wire [31:0]
	.i_port_wo_34        (ep34wire),          // input  wire [31:0]
	.i_port_wo_35        (ep35wire),          // input  wire [31:0]
	.i_port_wo_36        (ep36wire),          // input  wire [31:0]
	.i_port_wo_37        (ep37wire),          // input  wire [31:0]
	.i_port_wo_38        (ep38wire),          // input  wire [31:0]
	.i_port_wo_39        (ep39wire),          // input  wire [31:0]
	.i_port_wo_3A        (ep3Awire),          // input  wire [31:0]
	.i_port_wo_3B        (ep3Bwire),          // input  wire [31:0]
	.i_port_wo_3C        (ep3Cwire),          // input  wire [31:0]
	.i_port_wo_3D        (ep3Dwire),          // input  wire [31:0]
	.i_port_wo_3E        (ep3Ewire),          // input  wire [31:0]
	.i_port_wo_3F        (ep3Fwire),          // input  wire [31:0]
	
	//}
	
	// TI TO //{
	
	.i_port_ck_40 (ep40ck),   .o_port_ti_40 (ep40trig),
	.i_port_ck_41 (ep41ck),   .o_port_ti_41 (ep41trig),
	.i_port_ck_42 (ep42ck),   .o_port_ti_42 (ep42trig),
	.i_port_ck_43 (ep43ck),   .o_port_ti_43 (ep43trig),
	.i_port_ck_44 (ep44ck),   .o_port_ti_44 (ep44trig),
	.i_port_ck_45 (ep45ck),   .o_port_ti_45 (ep45trig),
	.i_port_ck_46 (ep46ck),   .o_port_ti_46 (ep46trig),
	.i_port_ck_47 (ep47ck),   .o_port_ti_47 (ep47trig),
	.i_port_ck_48 (ep48ck),   .o_port_ti_48 (ep48trig),
	.i_port_ck_49 (ep49ck),   .o_port_ti_49 (ep49trig),
	.i_port_ck_4A (ep4Ack),   .o_port_ti_4A (ep4Atrig),
	.i_port_ck_4B (ep4Bck),   .o_port_ti_4B (ep4Btrig),
	.i_port_ck_4C (ep4Cck),   .o_port_ti_4C (ep4Ctrig),
	.i_port_ck_4D (ep4Dck),   .o_port_ti_4D (ep4Dtrig),
	.i_port_ck_4E (ep4Eck),   .o_port_ti_4E (ep4Etrig),
	.i_port_ck_4F (ep4Fck),   .o_port_ti_4F (ep4Ftrig),
	.i_port_ck_50 (ep50ck),   .o_port_ti_50 (ep50trig),
	.i_port_ck_51 (ep51ck),   .o_port_ti_51 (ep51trig),
	.i_port_ck_52 (ep52ck),   .o_port_ti_52 (ep52trig),
	.i_port_ck_53 (ep53ck),   .o_port_ti_53 (ep53trig),
	.i_port_ck_54 (ep54ck),   .o_port_ti_54 (ep54trig),
	.i_port_ck_55 (ep55ck),   .o_port_ti_55 (ep55trig),
	.i_port_ck_56 (ep56ck),   .o_port_ti_56 (ep56trig),
	.i_port_ck_57 (ep57ck),   .o_port_ti_57 (ep57trig),
	.i_port_ck_58 (ep58ck),   .o_port_ti_58 (ep58trig),
	.i_port_ck_59 (ep59ck),   .o_port_ti_59 (ep59trig),
	.i_port_ck_5A (ep5Ack),   .o_port_ti_5A (ep5Atrig),
	.i_port_ck_5B (ep5Bck),   .o_port_ti_5B (ep5Btrig),
	.i_port_ck_5C (ep5Cck),   .o_port_ti_5C (ep5Ctrig),
	.i_port_ck_5D (ep5Dck),   .o_port_ti_5D (ep5Dtrig),
	.i_port_ck_5E (ep5Eck),   .o_port_ti_5E (ep5Etrig),
	.i_port_ck_5F (ep5Fck),   .o_port_ti_5F (ep5Ftrig),

	.i_port_ck_60 (ep60ck),   .i_port_to_60 (ep60trig),
	.i_port_ck_61 (ep61ck),   .i_port_to_61 (ep61trig),
	.i_port_ck_62 (ep62ck),   .i_port_to_62 (ep62trig),
	.i_port_ck_63 (ep63ck),   .i_port_to_63 (ep63trig),
	.i_port_ck_64 (ep64ck),   .i_port_to_64 (ep64trig),
	.i_port_ck_65 (ep65ck),   .i_port_to_65 (ep65trig),
	.i_port_ck_66 (ep66ck),   .i_port_to_66 (ep66trig),
	.i_port_ck_67 (ep67ck),   .i_port_to_67 (ep67trig),
	.i_port_ck_68 (ep68ck),   .i_port_to_68 (ep68trig),
	.i_port_ck_69 (ep69ck),   .i_port_to_69 (ep69trig),
	.i_port_ck_6A (ep6Ack),   .i_port_to_6A (ep6Atrig),
	.i_port_ck_6B (ep6Bck),   .i_port_to_6B (ep6Btrig),
	.i_port_ck_6C (ep6Cck),   .i_port_to_6C (ep6Ctrig),
	.i_port_ck_6D (ep6Dck),   .i_port_to_6D (ep6Dtrig),
	.i_port_ck_6E (ep6Eck),   .i_port_to_6E (ep6Etrig),
	.i_port_ck_6F (ep6Fck),   .i_port_to_6F (ep6Ftrig),
	.i_port_ck_70 (ep70ck),   .i_port_to_70 (ep70trig),
	.i_port_ck_71 (ep71ck),   .i_port_to_71 (ep71trig),
	.i_port_ck_72 (ep72ck),   .i_port_to_72 (ep72trig),
	.i_port_ck_73 (ep73ck),   .i_port_to_73 (ep73trig),
	.i_port_ck_74 (ep74ck),   .i_port_to_74 (ep74trig),
	.i_port_ck_75 (ep75ck),   .i_port_to_75 (ep75trig),
	.i_port_ck_76 (ep76ck),   .i_port_to_76 (ep76trig),
	.i_port_ck_77 (ep77ck),   .i_port_to_77 (ep77trig),
	.i_port_ck_78 (ep78ck),   .i_port_to_78 (ep78trig),
	.i_port_ck_79 (ep79ck),   .i_port_to_79 (ep79trig),
	.i_port_ck_7A (ep7Ack),   .i_port_to_7A (ep7Atrig),
	.i_port_ck_7B (ep7Bck),   .i_port_to_7B (ep7Btrig),
	.i_port_ck_7C (ep7Cck),   .i_port_to_7C (ep7Ctrig),
	.i_port_ck_7D (ep7Dck),   .i_port_to_7D (ep7Dtrig),
	.i_port_ck_7E (ep7Eck),   .i_port_to_7E (ep7Etrig),
	.i_port_ck_7F (ep7Fck),   .i_port_to_7F (ep7Ftrig),

	//}

	// PI PO //{
	
	.o_port_wr_80 (ep80wr),   .o_port_pi_80 (ep80pipe),
	.o_port_wr_81 (ep81wr),   .o_port_pi_81 (ep81pipe),
	.o_port_wr_82 (ep82wr),   .o_port_pi_82 (ep82pipe),
	.o_port_wr_83 (ep83wr),   .o_port_pi_83 (ep83pipe),
	.o_port_wr_84 (ep84wr),   .o_port_pi_84 (ep84pipe),
	.o_port_wr_85 (ep85wr),   .o_port_pi_85 (ep85pipe),
	.o_port_wr_86 (ep86wr),   .o_port_pi_86 (ep86pipe),
	.o_port_wr_87 (ep87wr),   .o_port_pi_87 (ep87pipe),
	.o_port_wr_88 (ep88wr),   .o_port_pi_88 (ep88pipe),
	.o_port_wr_89 (ep89wr),   .o_port_pi_89 (ep89pipe),
	.o_port_wr_8A (ep8Awr),   .o_port_pi_8A (ep8Apipe),
	.o_port_wr_8B (ep8Bwr),   .o_port_pi_8B (ep8Bpipe),
	.o_port_wr_8C (ep8Cwr),   .o_port_pi_8C (ep8Cpipe),
	.o_port_wr_8D (ep8Dwr),   .o_port_pi_8D (ep8Dpipe),
	.o_port_wr_8E (ep8Ewr),   .o_port_pi_8E (ep8Epipe),
	.o_port_wr_8F (ep8Fwr),   .o_port_pi_8F (ep8Fpipe),
	.o_port_wr_90 (ep90wr),   .o_port_pi_90 (ep90pipe),
	.o_port_wr_91 (ep91wr),   .o_port_pi_91 (ep91pipe),
	.o_port_wr_92 (ep92wr),   .o_port_pi_92 (ep92pipe),
	.o_port_wr_93 (ep93wr),   .o_port_pi_93 (ep93pipe),
	.o_port_wr_94 (ep94wr),   .o_port_pi_94 (ep94pipe),
	.o_port_wr_95 (ep95wr),   .o_port_pi_95 (ep95pipe),
	.o_port_wr_96 (ep96wr),   .o_port_pi_96 (ep96pipe),
	.o_port_wr_97 (ep97wr),   .o_port_pi_97 (ep97pipe),
	.o_port_wr_98 (ep98wr),   .o_port_pi_98 (ep98pipe),
	.o_port_wr_99 (ep99wr),   .o_port_pi_99 (ep99pipe),
	.o_port_wr_9A (ep9Awr),   .o_port_pi_9A (ep9Apipe),
	.o_port_wr_9B (ep9Bwr),   .o_port_pi_9B (ep9Bpipe),
	.o_port_wr_9C (ep9Cwr),   .o_port_pi_9C (ep9Cpipe),
	.o_port_wr_9D (ep9Dwr),   .o_port_pi_9D (ep9Dpipe),
	.o_port_wr_9E (ep9Ewr),   .o_port_pi_9E (ep9Epipe),
	.o_port_wr_9F (ep9Fwr),   .o_port_pi_9F (ep9Fpipe),
	
	.o_port_rd_A0 (epA0rd),   .i_port_po_A0 (epA0pipe),
	.o_port_rd_A1 (epA1rd),   .i_port_po_A1 (epA1pipe),
	.o_port_rd_A2 (epA2rd),   .i_port_po_A2 (epA2pipe),
	.o_port_rd_A3 (epA3rd),   .i_port_po_A3 (epA3pipe),
	.o_port_rd_A4 (epA4rd),   .i_port_po_A4 (epA4pipe),
	.o_port_rd_A5 (epA5rd),   .i_port_po_A5 (epA5pipe),
	.o_port_rd_A6 (epA6rd),   .i_port_po_A6 (epA6pipe),
	.o_port_rd_A7 (epA7rd),   .i_port_po_A7 (epA7pipe),
	.o_port_rd_A8 (epA8rd),   .i_port_po_A8 (epA8pipe),
	.o_port_rd_A9 (epA9rd),   .i_port_po_A9 (epA9pipe),
	.o_port_rd_AA (epAArd),   .i_port_po_AA (epAApipe),
	.o_port_rd_AB (epABrd),   .i_port_po_AB (epABpipe),
	.o_port_rd_AC (epACrd),   .i_port_po_AC (epACpipe),
	.o_port_rd_AD (epADrd),   .i_port_po_AD (epADpipe),
	.o_port_rd_AE (epAErd),   .i_port_po_AE (epAEpipe),
	.o_port_rd_AF (epAFrd),   .i_port_po_AF (epAFpipe),
	.o_port_rd_B0 (epB0rd),   .i_port_po_B0 (epB0pipe),
	.o_port_rd_B1 (epB1rd),   .i_port_po_B1 (epB1pipe),
	.o_port_rd_B2 (epB2rd),   .i_port_po_B2 (epB2pipe),
	.o_port_rd_B3 (epB3rd),   .i_port_po_B3 (epB3pipe),
	.o_port_rd_B4 (epB4rd),   .i_port_po_B4 (epB4pipe),
	.o_port_rd_B5 (epB5rd),   .i_port_po_B5 (epB5pipe),
	.o_port_rd_B6 (epB6rd),   .i_port_po_B6 (epB6pipe),
	.o_port_rd_B7 (epB7rd),   .i_port_po_B7 (epB7pipe),
	.o_port_rd_B8 (epB8rd),   .i_port_po_B8 (epB8pipe),
	.o_port_rd_B9 (epB9rd),   .i_port_po_B9 (epB9pipe),
	.o_port_rd_BA (epBArd),   .i_port_po_BA (epBApipe),
	.o_port_rd_BB (epBBrd),   .i_port_po_BB (epBBpipe),
	.o_port_rd_BC (epBCrd),   .i_port_po_BC (epBCpipe),
	.o_port_rd_BD (epBDrd),   .i_port_po_BD (epBDpipe),
	.o_port_rd_BE (epBErd),   .i_port_po_BE (epBEpipe),
	.o_port_rd_BF (epBFrd),   .i_port_po_BF (epBFpipe),

	//}
	
	//// dedicated LAN endpoints //{
	// conf
	.i_lan_conf_00      (BASE_ADRS_IP_32B  + i_adrs_offset_ip_32b ),   // input  wire [31:0]  
	.i_lan_conf_01      (BASE_ADRS_MAC_48B[31: 0] + i_adrs_offset_mac_48b[31: 0] ),   // input  wire [31:0]  
	.i_lan_conf_02      ( {16'b0,BASE_ADRS_MAC_48B[47:32]} + {16'b0,i_adrs_offset_mac_48b[47:32]} ),   // input  wire [31:0]  
	.i_lan_conf_03      ( {BASE_LAN_TIMEOUT_RTR_16B+i_offset_lan_timeout_rtr_16b , BASE_LAN_TIMEOUT_RCR_16B+i_offset_lan_timeout_rcr_16b} ),   // input  wire [31:0]  
	//
	.o_lan_wi_00        (w_lan_wi_00),   // output wire [31:0]  
	.o_lan_wi_01        (w_lan_wi_01),   // output wire [31:0]  
	.i_lan_wo_20        (w_lan_wo_20),   // input  wire [31:0]  
	.i_lan_wo_21        (32'b0),   // input  wire [31:0]  
	.i_lan_ck_40        (w_lan_ck_40),   .o_lan_ti_40 (w_lan_ti_40),  // input  wire , output wire [31:0]  
	.i_lan_ck_41        (1'b0),   .o_lan_ti_41 (),  // input  wire , output wire [31:0]  
	.i_lan_ck_60        (w_lan_ck_60),   .i_lan_to_60 (w_lan_to_60),  // input  wire , input  wire [31:0]  
	.i_lan_ck_61        (1'b0),   .i_lan_to_61 (32'b0),  // input  wire , input  wire [31:0]  
	.o_lan_wr_80        (w_lan_wr_80),   .o_lan_pi_80 (w_lan_pi_80),  // output wire , output wire [31:0]  
	.o_lan_wr_81        (),   .o_lan_pi_81 (),  // output wire , output wire [31:0]  
	.o_lan_rd_A0        (w_lan_rd_A0),   .i_lan_po_A0 (w_lan_po_A0),  // output wire , input  wire [31:0]  
	.o_lan_rd_A1        (),   .i_lan_po_A1 (32'b0),  // output wire , input  wire [31:0]  
	//}
	
	// test flag
	.valid()
);

//}

//}


//// zero outputs test //{

// wire in //{
//assign  ep00wire  =  32'h0;
//assign  ep01wire  =  32'h0;
//assign  ep02wire  =  32'h0;
//assign  ep03wire  =  32'h0;
//assign  ep04wire  =  32'h0;
//assign  ep05wire  =  32'h0;
//assign  ep06wire  =  32'h0;
//assign  ep07wire  =  32'h0;
//assign  ep08wire  =  32'h0;
//assign  ep09wire  =  32'h0;
//assign  ep0Awire  =  32'h0;
//assign  ep0Bwire  =  32'h0;
//assign  ep0Cwire  =  32'h0;
//assign  ep0Dwire  =  32'h0;
//assign  ep0Ewire  =  32'h0;
//assign  ep0Fwire  =  32'h0;
//assign  ep10wire  =  32'h0;
//assign  ep11wire  =  32'h0;
//assign  ep12wire  =  32'h0;
//assign  ep13wire  =  32'h0;
//assign  ep14wire  =  32'h0;
//assign  ep15wire  =  32'h0;
//assign  ep16wire  =  32'h0;
//assign  ep17wire  =  32'h0;
//assign  ep18wire  =  32'h0;
//assign  ep19wire  =  32'h0;
//assign  ep1Awire  =  32'h0;
//assign  ep1Bwire  =  32'h0;
//assign  ep1Cwire  =  32'h0;
//assign  ep1Dwire  =  32'h0;
//assign  ep1Ewire  =  32'h0;
//assign  ep1Fwire  =  32'h0;
//}

// trig in //{
//assign  ep40trig  =  32'h0;
//assign  ep41trig  =  32'h0;
//assign  ep42trig  =  32'h0;
//assign  ep43trig  =  32'h0;
//assign  ep44trig  =  32'h0;
//assign  ep45trig  =  32'h0;
//assign  ep46trig  =  32'h0;
//assign  ep47trig  =  32'h0;
//assign  ep48trig  =  32'h0;
//assign  ep49trig  =  32'h0;
//assign  ep4Atrig  =  32'h0;
//assign  ep4Btrig  =  32'h0;
//assign  ep4Ctrig  =  32'h0;
//assign  ep4Dtrig  =  32'h0;
//assign  ep4Etrig  =  32'h0;
//assign  ep4Ftrig  =  32'h0;
//assign  ep50trig  =  32'h0;
//assign  ep51trig  =  32'h0;
//assign  ep52trig  =  32'h0;
//assign  ep53trig  =  32'h0;
//assign  ep54trig  =  32'h0;
//assign  ep55trig  =  32'h0;
//assign  ep56trig  =  32'h0;
//assign  ep57trig  =  32'h0;
//assign  ep58trig  =  32'h0;
//assign  ep59trig  =  32'h0;
//assign  ep5Atrig  =  32'h0;
//assign  ep5Btrig  =  32'h0;
//assign  ep5Ctrig  =  32'h0;
//assign  ep5Dtrig  =  32'h0;
//assign  ep5Etrig  =  32'h0;
//assign  ep5Ftrig  =  32'h0;
//}

// pipe in //{
//assign  ep80wr  = 1'b0;  assign  ep81pipe  = 32'b0;
//assign  ep81wr  = 1'b0;  assign  ep80pipe  = 32'b0; 
//assign  ep82wr  = 1'b0;  assign  ep82pipe  = 32'b0;
//assign  ep83wr  = 1'b0;  assign  ep83pipe  = 32'b0;
//assign  ep84wr  = 1'b0;  assign  ep84pipe  = 32'b0;
//assign  ep85wr  = 1'b0;  assign  ep85pipe  = 32'b0;
//assign  ep86wr  = 1'b0;  assign  ep86pipe  = 32'b0;
//assign  ep87wr  = 1'b0;  assign  ep87pipe  = 32'b0;
//assign  ep88wr  = 1'b0;  assign  ep88pipe  = 32'b0;
//assign  ep89wr  = 1'b0;  assign  ep89pipe  = 32'b0;
//assign  ep8Awr  = 1'b0;  assign  ep8Apipe  = 32'b0;
//assign  ep8Bwr  = 1'b0;  assign  ep8Bpipe  = 32'b0;
//assign  ep8Cwr  = 1'b0;  assign  ep8Cpipe  = 32'b0;
//assign  ep8Dwr  = 1'b0;  assign  ep8Dpipe  = 32'b0;
//assign  ep8Ewr  = 1'b0;  assign  ep8Epipe  = 32'b0;
//assign  ep8Fwr  = 1'b0;  assign  ep8Fpipe  = 32'b0;
//assign  ep90wr  = 1'b0;  assign  ep90pipe  = 32'b0;
//assign  ep91wr  = 1'b0;  assign  ep91pipe  = 32'b0;
//assign  ep92wr  = 1'b0;  assign  ep92pipe  = 32'b0;
//assign  ep93wr  = 1'b0;  assign  ep93pipe  = 32'b0;
//assign  ep94wr  = 1'b0;  assign  ep94pipe  = 32'b0;
//assign  ep95wr  = 1'b0;  assign  ep95pipe  = 32'b0;
//assign  ep96wr  = 1'b0;  assign  ep96pipe  = 32'b0;
//assign  ep97wr  = 1'b0;  assign  ep97pipe  = 32'b0;
//assign  ep98wr  = 1'b0;  assign  ep98pipe  = 32'b0;
//assign  ep99wr  = 1'b0;  assign  ep99pipe  = 32'b0;
//assign  ep9Awr  = 1'b0;  assign  ep9Apipe  = 32'b0;
//assign  ep9Bwr  = 1'b0;  assign  ep9Bpipe  = 32'b0;
//assign  ep9Cwr  = 1'b0;  assign  ep9Cpipe  = 32'b0;
//assign  ep9Dwr  = 1'b0;  assign  ep9Dpipe  = 32'b0;
//assign  ep9Ewr  = 1'b0;  assign  ep9Epipe  = 32'b0;
//assign  ep9Fwr  = 1'b0;  assign  ep9Fpipe  = 32'b0;
//}

// pipe out //{
//assign  epA0rd  = 1'b0;
//assign  epA1rd  = 1'b0;
//assign  epA2rd  = 1'b0;
//assign  epA3rd  = 1'b0;
//assign  epA4rd  = 1'b0;
//assign  epA5rd  = 1'b0;
//assign  epA6rd  = 1'b0;
//assign  epA7rd  = 1'b0;
//assign  epA8rd  = 1'b0;
//assign  epA9rd  = 1'b0;
//assign  epAArd  = 1'b0;
//assign  epABrd  = 1'b0;
//assign  epACrd  = 1'b0;
//assign  epADrd  = 1'b0;
//assign  epAErd  = 1'b0;
//assign  epAFrd  = 1'b0;
//assign  epB0rd  = 1'b0;
//assign  epB1rd  = 1'b0;
//assign  epB2rd  = 1'b0;
//assign  epB3rd  = 1'b0;
//assign  epB4rd  = 1'b0;
//assign  epB5rd  = 1'b0;
//assign  epB6rd  = 1'b0;
//assign  epB7rd  = 1'b0;
//assign  epB8rd  = 1'b0;
//assign  epB9rd  = 1'b0;
//assign  epBArd  = 1'b0;
//assign  epBBrd  = 1'b0;
//assign  epBCrd  = 1'b0;
//assign  epBDrd  = 1'b0;
//assign  epBErd  = 1'b0;
//assign  epBFrd  = 1'b0;
//}

//}


//// Dedicated LAN interface  //{

// LAN control 
wire w_trig_LAN_reset = w_lan_wi_00[0];
wire w_done_LAN_reset;
wire w_trig_SPI_frame = w_lan_wi_00[1] | w_lan_ti_40[1]; // support wire and trig both.
wire w_done_SPI_frame;
wire w_done_SPI_frame_TO; // trig out
wire w_FIFO_reset     = w_lan_wi_00[2];

assign w_lan_to_60[31:2] = 30'b0;
assign w_lan_to_60[1]    = w_done_SPI_frame_TO;
assign w_lan_to_60[0]    = 1'b0;

// frame control 
wire [15:0] w_frame_adrs          = w_lan_wi_01[23: 8];
wire [ 4:0] w_frame_ctrl_blck_sel = w_lan_wi_01[ 7: 3];
wire        w_frame_ctrl_rdwr_sel = w_lan_wi_01[ 2: 2]; // RWB       Read/Write Access Mode Bit ... 0 for read, 1 for write.
wire [ 1:0] w_frame_ctrl_opmd_sel = w_lan_wi_01[ 1: 0];
wire [15:0] w_frame_num_byte_data = w_lan_wi_00[31: 16]; // reallocated

// fifo and lan module status
wire w_full_fifo_in  ;
wire w_empty_fifo_in ;
wire w_full_fifo_out ;
wire w_empty_fifo_out;
//
wire [31:0] w_LAN_status = {16'b0, 
							4'b0, 
							w_full_fifo_in   ,
							w_empty_fifo_in  ,
							w_full_fifo_out  ,
							w_empty_fifo_out ,
							3'b0, 
							w_done_SPI_frame ,
							EP_LAN_INT_B     ,
							EP_LAN_CS_B      ,
							EP_LAN_RST_B     ,
							w_done_LAN_reset };
assign w_lan_wo_20 = w_LAN_status;

// frame fifo data / control
wire [7:0] w_frame_fifo_in     = w_lan_pi_80[7:0];
wire       w_frame_fifo_in_wr  = w_lan_wr_80;
wire [7:0] w_frame_fifo_out;
wire       w_frame_fifo_out_rd = w_lan_rd_A0;
assign w_lan_po_A0[7:0]  = w_frame_fifo_out;
assign w_lan_po_A0[31:8] = 24'b0;
//
wire [7:0] w_frame_data_wr;
wire       w_frame_done_wr;
wire [7:0] w_frame_data_rd;
wire       w_frame_done_rd;


// TODO: master_spi_wz850_ext
//
//parameter PERIOD_CLK_RESET_PS =  83333.3333; // 12MHz
//parameter PERIOD_CLK_RESET_PS = 100000.0   ; // 10MHz
//
// master_spi_wz850_ext : full trig based operation 
//   i_trig_SPI_frame     trig-in  based on lan_clk 144MHz 
//   o_done_SPI_frame_TO  trig-out based on lan_clk 144MHz 
//
master_spi_wz850_ext #(
	.PERIOD_CLK_RESET_PS   (100000.0)
) master_spi_wz850_inst (
	.clk				(lan_clk), // assume 144MHz
	.reset_n			(reset_n),
	.clk_reset			(clk    ), // 12MHz --> 10MHz
	//
	.i_trig_LAN_reset	(w_trig_LAN_reset   ), // input  wire i_trig_LAN_reset , // LAN reset trigger
	.o_done_LAN_reset	(w_done_LAN_reset   ), // output wire o_done_LAN_reset , // LAN reset done 
	.i_trig_SPI_frame	(w_trig_SPI_frame   ), // input  wire i_trig_SPI_frame , // SPI frame trigger
	.o_done_SPI_frame	(w_done_SPI_frame   ), // output wire o_done_SPI_frame , // SPI frame done 
	.o_done_SPI_frame_TO(w_done_SPI_frame_TO), // output wire o_done_SPI_frame_TO , // SPI frame done trig out @ clk
	//
	.o_LAN_RSTn			(EP_LAN_RST_B),
	.i_LAN_INTn			(EP_LAN_INT_B), // reserved
	.o_LAN_SCSn			(EP_LAN_CS_B),
	.o_LAN_SCLK			(EP_LAN_SCLK),
	.o_LAN_MOSI			(EP_LAN_MOSI),
	.i_LAN_MISO			(EP_LAN_MISO),
	//
	.i_frame_adrs         	(w_frame_adrs         ),
	.i_frame_ctrl_blck_sel	(w_frame_ctrl_blck_sel),
	.i_frame_ctrl_rdwr_sel	(w_frame_ctrl_rdwr_sel), // RWB       Read/Write Access Mode Bit ... 0 for read, 1 for write.
	.i_frame_ctrl_opmd_sel	(w_frame_ctrl_opmd_sel),
	.i_frame_num_byte_data	(w_frame_num_byte_data), // 0 input --> 1 converted by inner logic.
	//
	.i_frame_data_wr      	(w_frame_data_wr      ),
	.o_frame_done_wr		(w_frame_done_wr      ),
	.o_frame_data_rd      	(w_frame_data_rd      ),
	.o_frame_done_rd		(w_frame_done_rd      ),
	//
	.valid				()		
);

// TODO: fifo_generator_3 
//   width "8-bit"
//   depth "16378 = 2^14"
//   standard read mode
//   rd 72MHz
//   wr 72MHz
//  
fifo_generator_3  LAN_fifo_wr_inst (
	.rst		(~reset_n | ~EP_LAN_RST_B | w_FIFO_reset),  // input wire rst 
	.wr_clk		(mcs_clk		),  // input wire wr_clk
	.wr_en		(w_frame_fifo_in_wr	),  // input wire wr_en
	.din		(w_frame_fifo_in	),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(w_full_fifo_in     ),  // output wire full
//	//	
	.rd_clk		(mcs_clk			),  // input wire rd_clk
	.rd_en		(w_frame_done_wr&(w_frame_ctrl_rdwr_sel)	),  // input wire rd_en
	.dout		(w_frame_data_wr	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(w_empty_fifo_in   	)   // output wire empty
);
//  
fifo_generator_3  LAN_fifo_rd_inst (
	.rst		(~reset_n | ~EP_LAN_RST_B | w_FIFO_reset),  // input wire rst 
	.wr_clk		(mcs_clk			),  // input wire wr_clk
	.wr_en		(w_frame_done_rd&(~w_frame_ctrl_rdwr_sel)	),  // input wire wr_en
	.din		(w_frame_data_rd	),  // input wire [7 : 0] din
	.wr_ack		(   	),  // output wire wr_ack
	.overflow	(   	),  // output wire overflow
	.prog_full	(   	),  // set at 16378
	.full		(w_full_fifo_out    ),  // output wire full
//	//	
	.rd_clk		(mcs_clk		),  // input wire rd_clk
	.rd_en		(w_frame_fifo_out_rd),  // input wire rd_en
	.dout		(w_frame_fifo_out	),  // output wire [7 : 0] dout
	.valid		(   	),  // output wire valid
	.underflow	(   	),  // output wire underflow
	.prog_empty	(   	),  // set at 5
	.empty		(w_empty_fifo_out   )   // output wire empty
);

//}

endmodule