// # this           : xem7310__mhvsu_base__top.v
// # xdc related    : xem7310__mhvsu_base__top.xdc
//
// # FPGA board     : TXEM7310-FPGA-CORE
// # FPGA board sch : FPGA_MODULE_V11_20200812-4M.pdf
//
// # base on socket : MHVSU-BASE-REV2 (BN: MHVSU BASE BOARD, PN: 1B003-B0301, RN: 0.2)
// # base sch       : MHVSU_BASE_BRD_REV02__R0807.pdf
// 

/* note on submodule files */ //{

//}

/* note on clock domains */ //{

//}


// unused
//`default_nettype none

/* top module integration */
module xem7310__mhvsu_base__top ( 

	
	// external clock ports //{
	input  wire         sys_clkp, 
	input  wire         sys_clkn,
	//}
	
	// TXEM7310 interface //{
	
	// ## LAN for END-POINTS 
	output wire  o_B15_L6P , // # H17    EP_LAN_PWDN 
	output wire  o_B15_L7P , // # J22    EP_LAN_MOSI
	output wire  o_B15_L7N , // # H22    EP_LAN_SCLK
	output wire  o_B15_L8P , // # H20    EP_LAN_CS_B
	input  wire  i_B15_L8N , // # G20    EP_LAN_INT_B
	output wire  o_B15_L9P , // # K21    EP_LAN_RST_B
	input  wire  i_B15_L9N , // # K22    EP_LAN_MISO
	
	// ## TP
	inout  wire  io_B15_L1P , // # H13    TP0 // test for eeprom : VCC_3.3V
	inout  wire  io_B15_L1N , // # G13    TP1 // test for eeprom : VSS_GND
	inout  wire  io_B15_L2P , // # G15    TP2 // test for eeprom : SCIO
	inout  wire  io_B15_L2N , // # G16    TP3 // test for        : NA
	inout  wire  io_B15_L3P , // # J14    TP4 // test for        : NA
	inout  wire  io_B15_L3N , // # H14    TP5 // test for        : NA
	inout  wire  io_B15_L5P , // # J15    TP6 // test for        : NA
	inout  wire  io_B15_L5N , // # H15    TP7 // test for        : NA
	
	// ## ADC
	input  wire  i_B15_L10P, // # H20    AUX_AD11P
	input  wire  i_B15_L10N, // # G20    AUX_AD11N

	//}
	
	//// BANK 13 34 35 signals in connectors
	
	// MC1 - odd //{
	output wire 	o_B34_L24P      , // # MC1-15  # RES_NET_2 || M0_SPI_MISO_EN  //$$ MHVSU-BASE-REV1 || REV2
	output wire 	o_B34_L24N      , // # MC1-17  # RES_NET_3 || M1_SPI_MISO_EN  //$$ MHVSU-BASE-REV1 || REV2
	output wire 	o_B34D_L17P     , // # MC1-19  # ADCx_CNV_P        
	output wire 	o_B34D_L17N     , // # MC1-21  # ADCx_CNV_N        
	output wire 	o_B34D_L16P     , // # MC1-23  # ADCx_SCK_P        
	output wire 	o_B34D_L16N     , // # MC1-25  # ADCx_SCK_N        
	input  wire 	c_B34D_L14P_SRCC, // # MC1-27  # ADC1_DCO_P        
	input  wire 	c_B34D_L14N_SRCC, // # MC1-29  # ADC1_DCO_N        
	input  wire 	i_B34D_L10P     , // # MC1-31  # ADC1_SDOA_P       
	input  wire 	i_B34D_L10N     , // # MC1-33  # ADC1_SDOA_N       
	//                              , // # MC1-35  # DGND               
	input  wire 	i_B34D_L20P     , // # MC1-37  # ADC1_SDOB_P       
	input  wire 	i_B34D_L20N     , // # MC1-39  # ADC1_SDOB_N       
	input  wire 	i_B34D_L3P      , // # MC1-41  # ADC1_SDOC_P       
	input  wire 	i_B34D_L3N      , // # MC1-43  # ADC1_SDOC_N       
	input  wire 	i_B34D_L9P      , // # MC1-45  # ADC1_SDOD_P       
	input  wire 	i_B34D_L9N      , // # MC1-47  # ADC1_SDOD_N       
	input  wire 	i_B34_L2P       , // # MC1-49  # M0_SPI_CS_B_BUF   
	input  wire 	i_B34_L2N       , // # MC1-51  # M0_SPI_CLK        
	input  wire 	i_B34_L4P       , // # MC1-53  # M0_SPI_MOSI       
	//                              , // # MC1-55  # DGND               
	output wire 	o_B34_L4N       , // # MC1-57  # M0_SPI_MISO       
	output wire 	o_B34_L1P       , // # MC1-59  # M0_SPI_MISO_EN || M0_SPI_SCLK //$$ MHVSU-BASE-REV1 || REV2
	input  wire 	i_B34_L1N       , // # MC1-61  # M1_SPI_CS_B_BUF   
	input  wire 	i_B34_L7P       , // # MC1-63  # M1_SPI_CLK        
	input  wire 	i_B34_L7N       , // # MC1-65  # M1_SPI_MOSI       
	output wire 	o_B13_L2P       , // # MC1-67  # EXT_SPx_MOSI      
	output wire 	o_B13_L2N       , // # MC1-69  # EXT_SPx_SCLK      
	input  wire 	i_B13_L4P       , // # MC1-71  # EXT_SPx_MISO      
	output wire 	o_B13_L4N       , // # MC1-73  # EXT_SP0_CS_B      
	output wire 	o_B13_L1P       , // # MC1-75  # EXT_SP1_CS_B      
	output wire 	o_B34_L12P_MRCC , // # MC1-77  # M1_SPI_MISO       
	output wire 	o_B34_L12N_MRCC , // # MC1-79  # M1_SPI_MISO_EN || M1_SPI_SCLK //$$ MHVSU-BASE-REV1 || REV2
	//}
	
	// MC1 - even //{
	output wire 	o_B13_SYS_CLK_MC1 , // # MC1-8   # RES_NET_0     
	input  wire 	i_XADC_VN         , // # MC1-10  # XADC_VN              
	input  wire 	i_XADC_VP         , // # MC1-12  # XADC_VP              
	//                                , // # MC1-14  # GND             
	input  wire 	i_B34D_L21P       , // # MC1-16  # ADC0_SDOD_N   
	input  wire 	i_B34D_L21N       , // # MC1-18  # ADC0_SDOD_P   
	input  wire 	i_B34D_L19P       , // # MC1-20  # ADC0_SDOC_N   
	input  wire 	i_B34D_L19N       , // # MC1-22  # ADC0_SDOC_P   
	input  wire 	i_B34D_L23P       , // # MC1-24  # ADC0_SDOB_N   
	input  wire 	i_B34D_L23N       , // # MC1-26  # ADC0_SDOB_P   
	input  wire 	i_B34D_L15P       , // # MC1-28  # ADC0_SDOA_N   
	input  wire 	i_B34D_L15N       , // # MC1-30  # ADC0_SDOA_P   
	input  wire 	c_B34D_L13P_MRCC  , // # MC1-32  # ADC0_DCO_N    
	input  wire 	c_B34D_L13N_MRCC  , // # MC1-34  # ADC0_DCO_P    
	//                                , // # MC1-36  # MC1_VCCO      
	output wire 	o_B34_L11P_SRCC   , // # MC1-38  # DAC1_SCK      
	output wire 	o_B34_L11N_SRCC   , // # MC1-40  # DAC1_MOSI     
	input  wire 	i_B34_L18P        , // # MC1-42  # DAC1_MISO     
	output wire 	o_B34_L18N        , // # MC1-44  # DAC1_SYNC_B   
	output wire 	o_B34_L22P        , // # MC1-46  # DAC0_SCK      
	output wire 	o_B34_L22N        , // # MC1-48  # DAC0_MOSI     
	input  wire 	i_B34_L6P         , // # MC1-50  # DAC0_MISO     
	output wire 	o_B34_L6N         , // # MC1-52  # DAC0_SYNC_B   
	output wire 	o_B34_L5P         , // # MC1-54  # RES_NET_1     
	//                                , // # MC1-56  # MC1_VCCO      
	inout  wire 	io_B34_L5N        , // # MC1-58  # INT_SP_MOSI   
	inout  wire 	io_B34_L8P        , // # MC1-60  # INT_SP_SCLK   
	inout  wire 	io_B34_L8N        , // # MC1-62  # INT_SP_MISO   
	inout  wire 	io_B13_L5P        , // # MC1-64  # INT_SP_CS_B   
	output wire 	o_B13_L5N         , // # MC1-66  # EXT_SP2_CS_B  
	output wire 	o_B13_L3P         , // # MC1-68  # EXT_SP3_CS_B  
	output wire 	o_B13_L3N         , // # MC1-70  # EXT_SP4_CS_B  
	output wire 	o_B13_L16P        , // # MC1-72  # EXT_SP5_CS_B  
	output wire 	o_B13_L16N        , // # MC1-74  # EXT_SP6_CS_B  
	output wire 	o_B13_L1N         , // # MC1-76  # EXT_SP7_CS_B  
	//}
	
	// MC2 - odd //{
	output wire 	o_B13_SYS_CLK_MC2 , // # MC2-11  # DACx_LOAC_B     
	//                                , // # MC2-13  # DGND            
	output wire 	o_B35_L21P        , // # MC2-15  # DAC2_SCK        
	output wire 	o_B35_L21N        , // # MC2-17  # DAC2_MOSI       
	input  wire 	i_B35_L19P        , // # MC2-19  # DAC2_MISO       
	output wire 	o_B35_L19N        , // # MC2-21  # DAC2_SYNC_B     
	input  wire 	i_B35_L18P        , // # MC2-23  # M_TRIG          
	input  wire 	i_B35_L18N        , // # MC2-25  # M_PRE_TRIG      
	input  wire 	i_B35D_L23P       , // # MC2-27  # ADC3_SDOA_P     
	input  wire 	i_B35D_L23N       , // # MC2-29  # ADC3_SDOA_N     
	input  wire 	i_B35D_L15P       , // # MC2-31  # ADC3_SDOB_P     
	input  wire 	i_B35D_L15N       , // # MC2-33  # ADC3_SDOB_N     
	//                                , // # MC2-35  # MC2_VCCO        
	input  wire 	i_B35D_L9P        , // # MC2-37  # ADC3_SDOC_P     
	input  wire 	i_B35D_L9N        , // # MC2-39  # ADC3_SDOC_N     
	input  wire 	i_B35D_L7P        , // # MC2-41  # ADC3_SDOD_P     
	input  wire 	i_B35D_L7N        , // # MC2-43  # ADC3_SDOD_N     
	input  wire 	c_B35D_L11P_SRCC  , // # MC2-45  # ADC3_DCO_P      
	input  wire 	c_B35D_L11N_SRCC  , // # MC2-47  # ADC3_DCO_N      
	output wire 	o_B35_L4P         , // # MC2-49  # EXT_SP16_CS_B   
	output wire 	o_B35_L4N         , // # MC2-51  # EXT_SP17_CS_B   
	output wire 	o_B35_L6P         , // # MC2-53  # EXT_SP18_CS_B   
	//                                , // # MC2-55  # MC2_VCCO        
	output wire 	o_B35_L6N         , // # MC2-57  # EXT_SP19_CS_B   
	output wire 	o_B35_L1P         , // # MC2-59  # EXT_SP20_CS_B   
	output wire 	o_B35_L1N         , // # MC2-61  # EXT_SP21_CS_B   
	output wire 	o_B35_L13P_MRCC   , // # MC2-63  # EXT_SP22_CS_B   
	output wire 	o_B35_L13N_MRCC   , // # MC2-65  # EXT_SP23_CS_B   
	output wire 	o_B13_L17P        , // # MC2-67  # EXT_BUSY_B_OUT  
	inout  wire 	io_B13_L17N       , // # MC2-69  # MEM_SIO         
	input  wire 	i_B13_L13P_MRCC   , // # MC2-71  # LAN_INT_B       
	input  wire 	i_B13_L13N_MRCC   , // # MC2-73  # TMP_SDO         
	output wire 	o_B13_L11P_SRCC   , // # MC2-75  # M_BUSY_B_OUT    
	output wire 	o_B35_L12P_MRCC   , // # MC2-77  # EXT_SP14_CS_B   
	output wire 	o_B35_L12N_MRCC   , // # MC2-79  # EXT_SP15_CS_B   
	//}
	
	// MC2 - even //{
	output wire 	o_B35_IO0        , // # MC2-10  # DAC3_SYNC_B     
	output wire 	o_B35_IO25       , // # MC2-12  # DAC3_SCK        
	//                               , // # MC2-14  # DGND             
	output wire 	o_B35_L24P       , // # MC2-16  # DAC3_MOSI       
	input  wire 	i_B35_L24N       , // # MC2-18  # DAC3_MISO       
	input  wire 	i_B35D_L22P      , // # MC2-20  # ADC2_SDOD_N     
	input  wire 	i_B35D_L22N      , // # MC2-22  # ADC2_SDOD_P     
	input  wire 	i_B35D_L20P      , // # MC2-24  # ADC2_SDOC_N     
	input  wire 	i_B35D_L20N      , // # MC2-26  # ADC2_SDOC_P     
	input  wire 	i_B35D_L16P      , // # MC2-28  # ADC2_SDOB_N     
	input  wire 	i_B35D_L16N      , // # MC2-30  # ADC2_SDOB_P     
	input  wire 	i_B35D_L17P      , // # MC2-32  # ADC2_SDOA_N     
	input  wire 	i_B35D_L17N      , // # MC2-34  # ADC2_SDOA_P     
	//                               , // # MC2-36  # DGND            
	input  wire 	c_B35D_L14P_SRCC , // # MC2-38  # ADC2_DCO_N      
	input  wire 	c_B35D_L14N_SRCC , // # MC2-40  # ADC2_DCO_P      
	output wire 	o_B35_L10P       , // # MC2-42  # EXT_SP8_CS_B    
	output wire 	o_B35_L10N       , // # MC2-44  # EXT_SP9_CS_B    
	output wire 	o_B35_L8P        , // # MC2-46  # EXT_SP10_CS_B   
	output wire 	o_B35_L8N        , // # MC2-48  # EXT_SP11_CS_B   
	output wire 	o_B35_L5P        , // # MC2-50  # EXT_SP12_CS_B   
	output wire 	o_B35_L5N        , // # MC2-52  # EXT_SP13_CS_B   
	input  wire 	i_B35_L3P        , // # MC2-54  # S_ID3_BUF       
	//                                 // # MC2-56  # DGND             
	input  wire 	i_B35_L3N        , // # MC2-58  # S_ID2_BUF       
	input  wire 	i_B35_L2P        , // # MC2-60  # S_ID1_BUF       
	input  wire 	i_B35_L2N        , // # MC2-62  # S_ID0_BUF       
	input  wire 	i_B13D_L14P_SRCC , // # MC2-64  # EXT_TRIG_P      
	input  wire 	i_B13D_L14N_SRCC , // # MC2-66  # EXT_TRIG_N      
	output wire 	o_B13_L15P       , // # MC2-68  # LAN_RST_B       
	input  wire 	i_B13_L15N       , // # MC2-70  # LAN_MISO        
	output wire 	o_B13_L6P        , // # MC2-72  # LAN_CS_B        
	output wire 	o_B13_L6N        , // # MC2-74  # LAN_SCLK        
	output wire 	o_B13_L11N_SRCC  , // # MC2-76  # LAN_MOSI        
	//}


	// LED on XEM7310 //{
	output wire [7:0]   led
	//}
	
	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID: h_DA_20_1113 //{
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0421; // MHVSU-BASE-REV1 (B0191) // pinmap setup
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0522; // MHVSU-BASE // TEST port setup
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0524; // MHVSU-BASE // SPIO test
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0525; // MHVSU-BASE // DAC test
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0527; // MHVSU-BASE // Slave SPI test // loopback
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0529; // MHVSU-BASE // Slave SPI test // register access 
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0530; // MHVSU-BASE // Slave SPI test // MISO timing
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0601; // MHVSU-BASE // Slave SPI test // end-point access
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0602; // MHVSU-BASE // Slave SPI test // base clock 104MHz
//parameter FPGA_IMAGE_ID = 32'h_D0_20_0603; // MHVSU-BASE // Slave SPI test // DAC wire-in bugfix
//parameter FPGA_IMAGE_ID = 32'h_D1_20_0603; // MHVSU-BASE // Slave SPI test // miso timing a bit ahead option
//parameter FPGA_IMAGE_ID = 32'h_D1_20_0604; // MHVSU-BASE // Slave SPI test // miso timing addressing bugfix
//parameter FPGA_IMAGE_ID = 32'h_D2_20_0604; // MHVSU-BASE // ADC test // forced mode
//parameter FPGA_IMAGE_ID = 32'h_D2_20_0610; // MHVSU-BASE // ADC test // single /run trigger  
//parameter FPGA_IMAGE_ID = 32'h_D2_20_0615; // MHVSU-BASE // ADC test // ACC 24-bit width 
//parameter FPGA_IMAGE_ID = 32'h_D2_20_0618; // MHVSU-BASE // ADC test // ACC 24-bit width, ACC high 16-bit monitoring  // ADC busy out retiming // FIFO 16-bit depth to come
//parameter FPGA_IMAGE_ID = 32'h_D2_20_0619; // MHVSU-BASE // ADC+ACC test  // adc base 192MHz // ACC works under b_clk 192MHz
//parameter FPGA_IMAGE_ID = 32'h_D3_20_0622; // MHVSU-BASE // rev sspi trigout // p_clk 12MHz for ADC/ACC
//parameter FPGA_IMAGE_ID = 32'h_D3_20_0623; // MHVSU-BASE // p_clk 12MHz for ADC/ACC/MIN/MAX 
//parameter FPGA_IMAGE_ID = 32'h_D3_20_0629; // MHVSU-BASE // ADC-FIFO test (15-bit depth)
//parameter FPGA_IMAGE_ID = 32'h_D3_20_0709; // MHVSU-BASE // External trigger for ADC-DAC co-work // ADC infinite run test to come
//parameter FPGA_IMAGE_ID = 32'h_D4_20_0703; // MHVSU-BASE // Slave SPI M1 setup for monitoring wireout
//parameter FPGA_IMAGE_ID = 32'h_D4_20_0706; // MHVSU-BASE // Slave SPI M1 setup for monitoring wireout // hotfix for 1ksps max ADC sampling
//parameter FPGA_IMAGE_ID = 32'h_D4_20_0708; // MHVSU-BASE // ADC test data increasing pattern control option
//parameter FPGA_IMAGE_ID = 32'h_D5_20_0710; // MHVSU-BASE // EXT-TRIG test // release draft
//parameter FPGA_IMAGE_ID = 32'h_D6_20_0712; // MHVSU-BASE // slave SPI miso format update // ADC-ACC 32 bit support 
//parameter FPGA_IMAGE_ID = 32'h_D6_20_0714; // MHVSU-BASE // SPIO forced mode added
//parameter FPGA_IMAGE_ID = 32'h_D7_20_0728; // MHVSU-BASE // vivado 2017.3 --> 2017.4
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0731; // MHVSU-BASE // support FPGA_Module_3254
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0812; // MHVSU-BASE // LAN END-POINTS and LED test
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0821; // MHVSU-BASE // LAN END-POINTS and LAN test // address bit fixed 
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0824; // MHVSU-BASE // LAN END-POINTS and LAN test // MAC/IP address assign logic
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0825; // MHVSU-BASE // LAN END-POINTS // python test over LAN // test counter only
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0827; // MHVSU-BASE // LAN END-POINTS // python test over LAN // MHVSU base  device logics
//parameter FPGA_IMAGE_ID = 32'h_D8_20_0828; // MHVSU-BASE // LAN END-POINTS // python test over LAN // MHVSU base  device logics // trigout debug
//parameter FPGA_IMAGE_ID = 32'h_D9_20_0902; // MHVSU-BASE // LAN END-POINTS // dedicated LAN enhanced
//parameter FPGA_IMAGE_ID = 32'h_D9_20_0922; // MHVSU-BASE // LAN END-POINTS // EEPROM test
//parameter FPGA_IMAGE_ID = 32'h_D9_20_0923; // MHVSU-BASE // LAN END-POINTS // EEPROM test // PIPE out one-clk delay
////parameter FPGA_IMAGE_ID = 32'h_D9_20_1013; // MHVSU-BASE-REV1 (B0191) // LAN END-POINTS // EEPROM via SSPI //// pending
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1016; // MHVSU-BASE-REV2 (B0301) // new pinmap setup // LAN END-POINTS enhanced // EEPROM via MCS 
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1019; // MHVSU-BASE-REV2 (B0301) // LAN-on-base-board support 
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1020; // MHVSU-BASE-REV2 (B0301) // update slot ID update from EEPROM ... MCS_SETUP_WI
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1021; // MHVSU-BASE-REV2 (B0301) // update slot ID update from EEPROM ... MCS_SETUP_WI // LAN-SPI BASE MISO timing rev
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1024; // MHVSU-BASE-REV2 (B0301) // support EEPROM via SSPI // eeprom path control rev
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1026; // MHVSU-BASE-REV2 (B0301) // support EEPROM via SSPI // SSPI test
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1028; // MHVSU-BASE-REV2 (B0301) // support counters via SSPI
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1101; // MHVSU-BASE-REV2 (B0301) // support Master SPI emulation for SSPI
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1103; // MHVSU-BASE-REV2 (B0301) // DAC status register revision // DAC trig counter revision
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1110; // MHVSU-BASE-REV2 (B0301) // debug EEPROM via SSPI
//parameter FPGA_IMAGE_ID = 32'h_DA_20_1111; // MHVSU-BASE-REV2 (B0301) // debug EEPROM via SSPI // pipe fifo check // HW reset
parameter FPGA_IMAGE_ID = 32'h_DA_20_1113; // MHVSU-BASE-REV2 (B0301) // revise TP : external EEPROM and BUSY monitor
//}


//// board IO location info:
// BL:S2143_TC21,S7856_BC12
// AD:   01_ABCD,   32_DCBA
// DA:   01_DCAB,   32_BACD
// PL:S4185_TC12,S3276_BC21


// check SW_BUILD_ID //{
//parameter REQ_SW_BUILD_ID = 32'h_ACAC_3535; // 0 for bypass 
//}

// ADC_BASE_FREQ
//parameter ADC_BASE_FREQ = 32'd192_000_000; // 192MHz information only

//}


//-------------------------------------------------------//

/* TODO: clock/pll and reset */ //{

// system clock
wire sys_clk; // 10MHz for slow IO

// clock pll
wire clk_out1_200M ; // for sub pll ... 200MHz // REFCLK 200MHz for IDELAYCTRL 
wire clk_out2_140M ; // for sub pll ... 140MHz
//
wire mcs_clk;       // base clock for MCS block // 72MHz
wire lan_clk;       // base clock for LAN block // 144MHz
//
wire base_sspi_clk; // base clock for slave SPI // 104MHz
wire base_adc_clk;  // base clock for ADC       // 192MHz
//
wire p_sspi_clk; // p_clk for sspio // 13MHz = base / 8
wire p_adc_clk ; // p_clk for adc   // 12MHz = base / 16


// clk_wiz_2
wire clk_2_locked;
clk_wiz_2  clk_wiz_2_inst (
	// Clock out ports  
	.clk_out1_200M (clk_out1_200M ), 
	.clk_out2_140M (clk_out2_140M ),
	// Status and control signals               
	.locked(clk_2_locked),
	// Clock in ports
	.clk_in1_p(sys_clkp),
	.clk_in1_n(sys_clkn)
);

// clk_wiz_2_0
wire clk_2_0_locked;
clk_wiz_2_0  clk_wiz_2_0_inst (
	// Clock out ports  
	//.clk_out1_10M(clk_out3_10M),  
	.clk_out1_10M(sys_clk),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_0_locked),
	// Clock in ports
	.clk_in1(clk_out1_200M)
);

// clk_wiz_2_1
wire clk_2_1_locked;
clk_wiz_2_1  clk_wiz_2_1_inst (
	// Clock out ports  
	.clk_out1_72M (mcs_clk),  
	.clk_out2_144M(lan_clk),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_1_locked),
	// Clock in ports
	.clk_in1(clk_out1_200M)
);

// clk_wiz_2_2
wire clk_2_2_locked;
clk_wiz_2_2  clk_wiz_2_2_inst (
	// Clock out ports  
	.clk_out1_104M(base_sspi_clk),  
	.clk_out2_13M (p_sspi_clk   ),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_2_locked),
	// Clock in ports
	.clk_in1(clk_out1_200M)
);

// clk_wiz_2_3
wire clk_2_3_locked;
clk_wiz_2_3  clk_wiz_2_3_inst (
	// Clock out ports  
	.clk_out1_192M(base_adc_clk),  
	.clk_out2_12M (p_adc_clk   ),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_3_locked),
	// Clock in ports
	.clk_in1(clk_out2_140M)
);


// clock locked 
//$$wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked
//$$                  & clk_dac_locked & dac0_dco_clk_locked & dac1_dco_clk_locked;
//wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked;
wire clk_locked = clk_2_locked   & 
				  clk_2_0_locked & 
				  clk_2_1_locked & 
				  clk_2_2_locked & 
				  clk_2_3_locked ;

// system reset 
(* keep = "true" *) wire reset_n	= clk_locked;
(* keep = "true" *) wire reset		= ~reset_n;
////

  
//}

//-------------------------------------------------------//

/* TODO: end-point wires */ //{

// end-points : USB vs LAN 

// wrapper modules : ok_endpoint_wrapper for USB  vs  lan_endpoint_wrapper for LAN
// ok_endpoint_wrapper  : usb host interface <--> end-points
//    removed
// lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1
//    master_spi_wz850
//    mcs_io_bridge

//// end-point wires: //{

// Wire In 		0x00 - 0x1F //{
wire [31:0] ep00wire; // [TEST]	SW_BUILD_ID_WI
wire [31:0] ep01wire; // [TEST]	TEST_CON_WI
wire [31:0] ep02wire; // [SSPI]	SSPI_CON_WI
wire [31:0] ep03wire; // [TEST] RNET_CON_WI
wire [31:0] ep04wire; // [MHVSU_SPIO]	SPIO_FDAT_WI
wire [31:0] ep05wire; // [MHVSU_SPIO]	SPIO_CON_WI
wire [31:0] ep06wire; // [MHVSU_DAC]	DAC_CON_WI
wire [31:0] ep07wire; // [MHVSU_ADC]	ADC_CON_WI
wire [31:0] ep08wire; // [MHVSU_SPIO]	SPIO_S1_WI
wire [31:0] ep09wire; // [MHVSU_SPIO]	SPIO_S2_WI
wire [31:0] ep0Awire; // [MHVSU_SPIO]	SPIO_S3_WI
wire [31:0] ep0Bwire; // [MHVSU_SPIO]	SPIO_S4_WI
wire [31:0] ep0Cwire; // [MHVSU_SPIO]	SPIO_S5_WI
wire [31:0] ep0Dwire; // [MHVSU_SPIO]	SPIO_S6_WI
wire [31:0] ep0Ewire; // [MHVSU_SPIO]	SPIO_S7_WI
wire [31:0] ep0Fwire; // [MHVSU_SPIO]	SPIO_S8_WI
wire [31:0] ep10wire; // [MHVSU_ADC]	ADC_PAR_WI        
wire [31:0] ep11wire; // [MCS]	MCS_SETUP_WI // dedicated to MCS // updated by MCS boot-up
wire [31:0] ep12wire; // [MEM]	MEM_FDAT_WI 
wire [31:0] ep13wire; // [MEM]	MEM_WI
wire [31:0] ep14wire; // [EXT_TRIG]		EXT_TRIG_CON_WI
wire [31:0] ep15wire; // [EXT_TRIG]		EXT_TRIG_PARA_WI
wire [31:0] ep16wire; // [EXT_TRIG]		EXT_TRIG_AUX_WI
wire [31:0] ep17wire; // [SSPI]	SSPI_TEST_WI // for master emulation test
wire [31:0] ep18wire; // [MHVSU_DAC]	DAC_S1_WI
wire [31:0] ep19wire; // [MHVSU_DAC]	DAC_S2_WI
wire [31:0] ep1Awire; // [MHVSU_DAC]	DAC_S3_WI
wire [31:0] ep1Bwire; // [MHVSU_DAC]	DAC_S4_WI
wire [31:0] ep1Cwire; // [MHVSU_DAC]	DAC_S5_WI
wire [31:0] ep1Dwire; // [MHVSU_DAC]	DAC_S6_WI
wire [31:0] ep1Ewire; // [MHVSU_DAC]	DAC_S7_WI
wire [31:0] ep1Fwire; // [MHVSU_DAC]	DAC_S8_WI
//}

// Wire Out 	0x20 - 0x3F //{
wire [31:0] ep20wire; // [TEST]	FPGA_IMAGE_ID_WO
wire [31:0] ep21wire; // [TEST] TEST_FLAG_WO  // [SSPI] SSPI_TEST_WO //$$
wire [31:0] ep22wire; // [SSPI]	SSPI_FLAG_WO
wire [31:0] ep23wire; // [TEST]	MON_XADC_WO
wire [31:0] ep24wire; // [TEST]	MON_GP_WO
wire [31:0] ep25wire; // [MHVSU_SPIO]	SPIO_FLAG_WO
wire [31:0] ep26wire; // [MHVSU_DAC]	DAC_FLAG_WO 
wire [31:0] ep27wire; // [MHVSU_ADC]	ADC_FLAG_WO 
wire [31:0] ep28wire; // [MHVSU_ADC]	ADC_S1_ACC_MAX_WO
wire [31:0] ep29wire; // [MHVSU_ADC]	ADC_S2_ACC_MAX_WO
wire [31:0] ep2Awire; // [MHVSU_ADC]	ADC_S3_ACC_MAX_WO
wire [31:0] ep2Bwire; // [MHVSU_ADC]	ADC_S4_ACC_MAX_WO
wire [31:0] ep2Cwire; // [MHVSU_ADC]	ADC_S5_ACC_MAX_WO
wire [31:0] ep2Dwire; // [MHVSU_ADC]	ADC_S6_ACC_MAX_WO
wire [31:0] ep2Ewire; // [MHVSU_ADC]	ADC_S7_ACC_MAX_WO
wire [31:0] ep2Fwire; // [MHVSU_ADC]	ADC_S8_ACC_MAX_WO
wire [31:0] ep30wire; // [MHVSU_ADC]	ADC_S1_VAL_MIN_WO
wire [31:0] ep31wire; // [MHVSU_ADC]	ADC_S2_VAL_MIN_WO
wire [31:0] ep32wire; // [MHVSU_ADC]	ADC_S3_VAL_MIN_WO
wire [31:0] ep33wire; // [MHVSU_ADC]	ADC_S4_VAL_MIN_WO
wire [31:0] ep34wire; // [MHVSU_ADC]	ADC_S5_VAL_MIN_WO
wire [31:0] ep35wire; // [MHVSU_ADC]	ADC_S6_VAL_MIN_WO
wire [31:0] ep36wire; // [MHVSU_ADC]	ADC_S7_VAL_MIN_WO
wire [31:0] ep37wire; // [MHVSU_ADC]	ADC_S8_VAL_MIN_WO
wire [31:0] ep38wire; // [MHVSU_DAC]	DAC_S1_WO
wire [31:0] ep39wire; // [MHVSU_DAC]	DAC_S2_WO
wire [31:0] ep3Awire; // [MHVSU_DAC]	DAC_S3_WO
wire [31:0] ep3Bwire; // [MHVSU_DAC]	DAC_S4_WO
wire [31:0] ep3Cwire; // [MHVSU_DAC]	DAC_S5_WO
wire [31:0] ep3Dwire; // [MHVSU_DAC]	DAC_S6_WO
wire [31:0] ep3Ewire; // [MHVSU_DAC]	DAC_S7_WO
wire [31:0] ep3Fwire; // [MHVSU_DAC]	DAC_S8_WO
//}

// Trigger In 	0x40 - 0x5F //{
wire ep40ck = 1'b0;    wire [31:0] ep40trig; // 	
wire ep41ck       ;    wire [31:0] ep41trig; // [TEST]	TEST_TI
wire ep42ck       ;    wire [31:0] ep42trig; // [SSPI]	SSPI_TI --> SSPI_TEST_TI
wire ep43ck = 1'b0;    wire [31:0] ep43trig; // 	
wire ep44ck       ;    wire [31:0] ep44trig; // [EXT_TRIG]		EXT_TRIG_TI	
wire ep45ck       ;    wire [31:0] ep45trig; // [MHVSU_SPIO]	SPIO_TRIG_TI
wire ep46ck       ;    wire [31:0] ep46trig; // [MHVSU_DAC]		DAC_TRIG_TI
wire ep47ck       ;    wire [31:0] ep47trig; // [MHVSU_ADC]		ADC_TRIG_TI
wire ep48ck = 1'b0;    wire [31:0] ep48trig; // 	
wire ep49ck = 1'b0;    wire [31:0] ep49trig; // 	
wire ep4Ack = 1'b0;    wire [31:0] ep4Atrig; // 	
wire ep4Bck = 1'b0;    wire [31:0] ep4Btrig; // 	
wire ep4Cck = 1'b0;    wire [31:0] ep4Ctrig; // 	
wire ep4Dck = 1'b0;    wire [31:0] ep4Dtrig; // 	
wire ep4Eck = 1'b0;    wire [31:0] ep4Etrig; // 	
wire ep4Fck = 1'b0;    wire [31:0] ep4Ftrig; // 	
wire ep50ck = 1'b0;    wire [31:0] ep50trig; // 	
wire ep51ck = 1'b0;    wire [31:0] ep51trig; // 	
wire ep52ck = 1'b0;    wire [31:0] ep52trig; // 	
wire ep53ck       ;    wire [31:0] ep53trig; // [MEM]	MEM_TI
wire ep54ck = 1'b0;    wire [31:0] ep54trig; // 	
wire ep55ck = 1'b0;    wire [31:0] ep55trig; // 	
wire ep56ck = 1'b0;    wire [31:0] ep56trig; // 	
wire ep57ck = 1'b0;    wire [31:0] ep57trig; // 	
wire ep58ck = 1'b0;    wire [31:0] ep58trig; // 	
wire ep59ck = 1'b0;    wire [31:0] ep59trig; // 	
wire ep5Ack = 1'b0;    wire [31:0] ep5Atrig; // 	
wire ep5Bck = 1'b0;    wire [31:0] ep5Btrig; // 	
wire ep5Cck = 1'b0;    wire [31:0] ep5Ctrig; // 	
wire ep5Dck = 1'b0;    wire [31:0] ep5Dtrig; // 	
wire ep5Eck = 1'b0;    wire [31:0] ep5Etrig; // 	
wire ep5Fck = 1'b0;    wire [31:0] ep5Ftrig; // 	
//}

// Trigger Out 	0x60 - 0x7F //{
wire ep60ck = 1'b0;    wire [31:0] ep60trig = 32'b0; // 	
wire ep61ck       ;    wire [31:0] ep61trig; // [TEST]	TEST_TO
wire ep62ck       ;    wire [31:0] ep62trig; // [SSPI]	SSPI_TO --> SSPI_TEST_TO
wire ep63ck = 1'b0;    wire [31:0] ep63trig = 32'b0; // 	
wire ep64ck       ;    wire [31:0] ep64trig; // [EXT_TRIG]		EXT_TRIG_TO	
wire ep65ck       ;    wire [31:0] ep65trig; // [MHVSU_SPIO]	SPIO_TRIG_TO
wire ep66ck       ;    wire [31:0] ep66trig; // [MHVSU_DAC]		DAC_TRIG_TO
wire ep67ck       ;    wire [31:0] ep67trig; // [MHVSU_ADC]		ADC_TRIG_TO
wire ep68ck = 1'b0;    wire [31:0] ep68trig = 32'b0; // 	
wire ep69ck = 1'b0;    wire [31:0] ep69trig = 32'b0; // 	
wire ep6Ack = 1'b0;    wire [31:0] ep6Atrig = 32'b0; // 	
wire ep6Bck = 1'b0;    wire [31:0] ep6Btrig = 32'b0; // 	
wire ep6Cck = 1'b0;    wire [31:0] ep6Ctrig = 32'b0; // 	
wire ep6Dck = 1'b0;    wire [31:0] ep6Dtrig = 32'b0; // 	
wire ep6Eck = 1'b0;    wire [31:0] ep6Etrig = 32'b0; // 	
wire ep6Fck = 1'b0;    wire [31:0] ep6Ftrig = 32'b0; // 	
wire ep70ck = 1'b0;    wire [31:0] ep70trig = 32'b0; // 	
wire ep71ck = 1'b0;    wire [31:0] ep71trig = 32'b0; // 	
wire ep72ck = 1'b0;    wire [31:0] ep72trig = 32'b0; // 	
wire ep73ck       ;    wire [31:0] ep73trig; // [MEM]	MEM_TO
wire ep74ck = 1'b0;    wire [31:0] ep74trig = 32'b0; // 	
wire ep75ck = 1'b0;    wire [31:0] ep75trig = 32'b0; // 	
wire ep76ck = 1'b0;    wire [31:0] ep76trig = 32'b0; // 	
wire ep77ck = 1'b0;    wire [31:0] ep77trig = 32'b0; // 	
wire ep78ck = 1'b0;    wire [31:0] ep78trig = 32'b0; // 	
wire ep79ck = 1'b0;    wire [31:0] ep79trig = 32'b0; // 	
wire ep7Ack = 1'b0;    wire [31:0] ep7Atrig = 32'b0; // 	
wire ep7Bck = 1'b0;    wire [31:0] ep7Btrig = 32'b0; // 	
wire ep7Cck = 1'b0;    wire [31:0] ep7Ctrig = 32'b0; // 	
wire ep7Dck = 1'b0;    wire [31:0] ep7Dtrig = 32'b0; // 	
wire ep7Eck = 1'b0;    wire [31:0] ep7Etrig = 32'b0; // 	
wire ep7Fck = 1'b0;    wire [31:0] ep7Ftrig = 32'b0; // 	
//}

// Pipe In 		0x80 - 0x9F // clock is assumed to use pipeClk //{
wire ep80wr; wire [31:0] ep80pipe;
wire ep81wr; wire [31:0] ep81pipe;
wire ep82wr; wire [31:0] ep82pipe;
wire ep83wr; wire [31:0] ep83pipe;
wire ep84wr; wire [31:0] ep84pipe;
wire ep85wr; wire [31:0] ep85pipe;
wire ep86wr; wire [31:0] ep86pipe;
wire ep87wr; wire [31:0] ep87pipe;
wire ep88wr; wire [31:0] ep88pipe;
wire ep89wr; wire [31:0] ep89pipe;
wire ep8Awr; wire [31:0] ep8Apipe;
wire ep8Bwr; wire [31:0] ep8Bpipe;
wire ep8Cwr; wire [31:0] ep8Cpipe;
wire ep8Dwr; wire [31:0] ep8Dpipe;
wire ep8Ewr; wire [31:0] ep8Epipe;
wire ep8Fwr; wire [31:0] ep8Fpipe;
wire ep90wr; wire [31:0] ep90pipe;
wire ep91wr; wire [31:0] ep91pipe;
wire ep92wr; wire [31:0] ep92pipe;
wire ep93wr; wire [31:0] ep93pipe; // [MEM]	MEM_PI
wire ep94wr; wire [31:0] ep94pipe;
wire ep95wr; wire [31:0] ep95pipe;
wire ep96wr; wire [31:0] ep96pipe;
wire ep97wr; wire [31:0] ep97pipe;
wire ep98wr; wire [31:0] ep98pipe;
wire ep99wr; wire [31:0] ep99pipe;
wire ep9Awr; wire [31:0] ep9Apipe;
wire ep9Bwr; wire [31:0] ep9Bpipe;
wire ep9Cwr; wire [31:0] ep9Cpipe;
wire ep9Dwr; wire [31:0] ep9Dpipe;
wire ep9Ewr; wire [31:0] ep9Epipe;
wire ep9Fwr; wire [31:0] ep9Fpipe;
//}

// Pipe Out 	0xA0 - 0xBF //{
wire epA0rd; wire [31:0] epA0pipe; // [MHVSU_ADC]	ADC_S1_CH1_PO
wire epA1rd; wire [31:0] epA1pipe; // [MHVSU_ADC]	ADC_S2_CH1_PO
wire epA2rd; wire [31:0] epA2pipe; // [MHVSU_ADC]	ADC_S3_CH1_PO
wire epA3rd; wire [31:0] epA3pipe; // [MHVSU_ADC]	ADC_S4_CH1_PO
wire epA4rd; wire [31:0] epA4pipe; // [MHVSU_ADC]	ADC_S5_CH1_PO
wire epA5rd; wire [31:0] epA5pipe; // [MHVSU_ADC]	ADC_S6_CH1_PO
wire epA6rd; wire [31:0] epA6pipe; // [MHVSU_ADC]	ADC_S7_CH1_PO
wire epA7rd; wire [31:0] epA7pipe; // [MHVSU_ADC]	ADC_S8_CH1_PO
wire epA8rd; wire [31:0] epA8pipe; // [MHVSU_ADC]	ADC_S1_CH2_PO
wire epA9rd; wire [31:0] epA9pipe; // [MHVSU_ADC]	ADC_S2_CH2_PO
wire epAArd; wire [31:0] epAApipe; // [MHVSU_ADC]	ADC_S3_CH2_PO
wire epABrd; wire [31:0] epABpipe; // [MHVSU_ADC]	ADC_S4_CH2_PO
wire epACrd; wire [31:0] epACpipe; // [MHVSU_ADC]	ADC_S5_CH2_PO
wire epADrd; wire [31:0] epADpipe; // [MHVSU_ADC]	ADC_S6_CH2_PO
wire epAErd; wire [31:0] epAEpipe; // [MHVSU_ADC]	ADC_S7_CH2_PO
wire epAFrd; wire [31:0] epAFpipe; // [MHVSU_ADC]	ADC_S8_CH2_PO
wire epB0rd; wire [31:0] epB0pipe = 32'b0; // 	
wire epB1rd; wire [31:0] epB1pipe = 32'b0; // 	
wire epB2rd; wire [31:0] epB2pipe = 32'b0; // 	
wire epB3rd; wire [31:0] epB3pipe; // [MEM]	MEM_PO
wire epB4rd; wire [31:0] epB4pipe = 32'b0; // 	
wire epB5rd; wire [31:0] epB5pipe = 32'b0; // 	
wire epB6rd; wire [31:0] epB6pipe = 32'b0; // 	
wire epB7rd; wire [31:0] epB7pipe = 32'b0; // 	
wire epB8rd; wire [31:0] epB8pipe = 32'b0; // 	
wire epB9rd; wire [31:0] epB9pipe = 32'b0; // 	
wire epBArd; wire [31:0] epBApipe = 32'b0; // 	
wire epBBrd; wire [31:0] epBBpipe = 32'b0; // 	
wire epBCrd; wire [31:0] epBCpipe = 32'b0; // 	
wire epBDrd; wire [31:0] epBDpipe = 32'b0; // 	
wire epBErd; wire [31:0] epBEpipe = 32'b0; // 	
wire epBFrd; wire [31:0] epBFpipe = 32'b0; // 	
//}

// pipe interface clk: //{
wire pipeClk; // rename: okClk --> pipeClk
//}

//}

//}

//-------------------------------------------------------//


/* TODO: EP_LAN */ //{  // LAN on FPGA module

// ports for EP_LAN //{

// wire from lan_endpoint_wrapper
wire  EP_LAN_PWDN  = 1'b0; // test // unused // fixed
wire  EP_LAN_MOSI ; // = 1'b0; // test 
wire  EP_LAN_SCLK ; // = 1'b0; // test 
wire  EP_LAN_CS_B ; // = 1'b1; // test 
wire  EP_LAN_INT_B;
wire  EP_LAN_RST_B; // = 1'b1; // test 
wire  EP_LAN_MISO ;

OBUF obuf__EP_LAN_PWDN__inst (.O( o_B15_L6P ), .I( EP_LAN_PWDN   ) ); // 

// lan port on FPGA module
wire  PT_FMOD_EP_LAN_MOSI ; 
wire  PT_FMOD_EP_LAN_SCLK ; 
wire  PT_FMOD_EP_LAN_CS_B ; 
wire  PT_FMOD_EP_LAN_INT_B;
wire  PT_FMOD_EP_LAN_RST_B; 
wire  PT_FMOD_EP_LAN_MISO ;

OBUF obuf__EP_LAN_MOSI__inst (.O( o_B15_L7P ), .I( PT_FMOD_EP_LAN_MOSI  ) ); // 
OBUF obuf__EP_LAN_SCLK__inst (.O( o_B15_L7N ), .I( PT_FMOD_EP_LAN_SCLK  ) ); // 
OBUF obuf__EP_LAN_CS_B__inst (.O( o_B15_L8P ), .I( PT_FMOD_EP_LAN_CS_B  ) ); // 
IBUF ibuf__EP_LAN_INT_B_inst (.I( i_B15_L8N ), .O( PT_FMOD_EP_LAN_INT_B ) ); //
OBUF obuf__EP_LAN_RST_B_inst (.O( o_B15_L9P ), .I( PT_FMOD_EP_LAN_RST_B ) ); // 
IBUF ibuf__EP_LAN_MISO__inst (.I( i_B15_L9N ), .O( PT_FMOD_EP_LAN_MISO  ) ); //

//  wire  LAN_MOSI  = 1'b0; // test 
//  wire  LAN_SCLK  = 1'b0; // test 
//  wire  LAN_CS_B  = 1'b1; // test 
//  wire  LAN_INT_B;
//  wire  LAN_RST_B = 1'b1; // test 
//  wire  LAN_MISO ;

// lan port on BASE board
wire  PT_BASE_EP_LAN_MOSI ; 
wire  PT_BASE_EP_LAN_SCLK ; 
wire  PT_BASE_EP_LAN_CS_B ; 
wire  PT_BASE_EP_LAN_INT_B;
wire  PT_BASE_EP_LAN_RST_B; 
wire  PT_BASE_EP_LAN_MISO ;

OBUF obuf__LAN_MOSI__inst (.O(o_B13_L11N_SRCC ), .I(PT_BASE_EP_LAN_MOSI ) ); // 
OBUF obuf__LAN_SCLK__inst (.O(o_B13_L6N       ), .I(PT_BASE_EP_LAN_SCLK ) ); // 
OBUF obuf__LAN_CS_B__inst (.O(o_B13_L6P       ), .I(PT_BASE_EP_LAN_CS_B ) ); // 
IBUF ibuf__LAN_INT_B_inst (.I(i_B13_L13P_MRCC ), .O(PT_BASE_EP_LAN_INT_B) ); //
OBUF obuf__LAN_RST_B_inst (.O(o_B13_L15P      ), .I(PT_BASE_EP_LAN_RST_B) ); // 
IBUF ibuf__LAN_MISO__inst (.I(i_B13_L15N      ), .O(PT_BASE_EP_LAN_MISO ) ); //

wire select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD; //$$ assign later

// output mux
assign PT_FMOD_EP_LAN_MOSI  = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
assign PT_FMOD_EP_LAN_SCLK  = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
assign PT_FMOD_EP_LAN_CS_B  = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
assign PT_FMOD_EP_LAN_RST_B = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

assign PT_BASE_EP_LAN_MOSI  = ( select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
assign PT_BASE_EP_LAN_SCLK  = ( select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
assign PT_BASE_EP_LAN_CS_B  = ( select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
assign PT_BASE_EP_LAN_RST_B = ( select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

// input mux
assign EP_LAN_INT_B = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_INT_B  : PT_BASE_EP_LAN_INT_B;
assign EP_LAN_MISO  = (~select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_MISO   : PT_BASE_EP_LAN_MISO;


//}

//}


//-------------------------------------------------------//


/* TODO: END-POINTS wrapper for EP_LAN */ //{

// lan_endpoint_wrapper   //{

wire [47:0] w_adrs_offset_mac_48b; // BASE = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ??48 bits
wire [31:0] w_adrs_offset_ip_32b ; // BASE = {8'd192,8'd168,8'd168,8'd112}; // 192.168.168.112 or C0:A8:A8:70 ??32 bits
wire [15:0] w_offset_lan_timeout_rtr_16b = ep00wire[31:16]; // assign later 
wire [15:0] w_offset_lan_timeout_rcr_16b = ep00wire[15: 0]; // assign later 

lan_endpoint_wrapper #(
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID)  
) lan_endpoint_wrapper_inst (

	// `EP_LAN pins 
	.EP_LAN_MOSI   (EP_LAN_MOSI ), // output wire     EP_LAN_MOSI  ,
	.EP_LAN_SCLK   (EP_LAN_SCLK ), // output wire     EP_LAN_SCLK  ,
	.EP_LAN_CS_B   (EP_LAN_CS_B ), // output wire     EP_LAN_CS_B  ,
	.EP_LAN_INT_B  (EP_LAN_INT_B), // input  wire     EP_LAN_INT_B ,
	.EP_LAN_RST_B  (EP_LAN_RST_B), // output wire     EP_LAN_RST_B ,
	.EP_LAN_MISO   (EP_LAN_MISO ), // input  wire     EP_LAN_MISO  ,
	
	// for common 
	.clk           (sys_clk), // 10MHz
	.reset_n       (reset_n),
	
	// soft CPU clock
	.mcs_clk       (mcs_clk), // 72MHz
	
	// dedicated LAN clock 
	.lan_clk       (lan_clk), // 144MHz
	
	// MAC/IP address offsets
	.i_adrs_offset_mac_48b  (w_adrs_offset_mac_48b), // input  wire [47:0]  
	.i_adrs_offset_ip_32b   (w_adrs_offset_ip_32b ), // input  wire [31:0]  
	// LAN timeout setup
	.i_offset_lan_timeout_rtr_16b  (w_offset_lan_timeout_rtr_16b), // input  wire [15:0]
	.i_offset_lan_timeout_rcr_16b  (w_offset_lan_timeout_rcr_16b), // input  wire [15:0]

	
	// Wire In 		0x00 - 0x1F  //{
	.ep00wire(ep00wire), // output wire [31:0]
	.ep01wire(ep01wire), // output wire [31:0]
	.ep02wire(ep02wire), // output wire [31:0]
	.ep03wire(ep03wire), // output wire [31:0]
	.ep04wire(ep04wire), // output wire [31:0]
	.ep05wire(ep05wire), // output wire [31:0]
	.ep06wire(ep06wire), // output wire [31:0]
	.ep07wire(ep07wire), // output wire [31:0]
	.ep08wire(ep08wire), // output wire [31:0]
	.ep09wire(ep09wire), // output wire [31:0]
	.ep0Awire(ep0Awire), // output wire [31:0]
	.ep0Bwire(ep0Bwire), // output wire [31:0]
	.ep0Cwire(ep0Cwire), // output wire [31:0]
	.ep0Dwire(ep0Dwire), // output wire [31:0]
	.ep0Ewire(ep0Ewire), // output wire [31:0]
	.ep0Fwire(ep0Fwire), // output wire [31:0]
	.ep10wire(ep10wire), // output wire [31:0]
	.ep11wire(ep11wire), // output wire [31:0]
	.ep12wire(ep12wire), // output wire [31:0]
	.ep13wire(ep13wire), // output wire [31:0]
	.ep14wire(ep14wire), // output wire [31:0]
	.ep15wire(ep15wire), // output wire [31:0]
	.ep16wire(ep16wire), // output wire [31:0]
	.ep17wire(ep17wire), // output wire [31:0]
	.ep18wire(ep18wire), // output wire [31:0]
	.ep19wire(ep19wire), // output wire [31:0]
	.ep1Awire(ep1Awire), // output wire [31:0]
	.ep1Bwire(ep1Bwire), // output wire [31:0]
	.ep1Cwire(ep1Cwire), // output wire [31:0]
	.ep1Dwire(ep1Dwire), // output wire [31:0]
	.ep1Ewire(ep1Ewire), // output wire [31:0]
	.ep1Fwire(ep1Fwire), // output wire [31:0]
	//}
	
	// Wire Out 	0x20 - 0x3F //{
	.ep20wire(ep20wire), // input wire [31:0]
	.ep21wire(ep21wire), // input wire [31:0]
	.ep22wire(ep22wire), // input wire [31:0]
	.ep23wire(ep23wire), // input wire [31:0]
	.ep24wire(ep24wire), // input wire [31:0]
	.ep25wire(ep25wire), // input wire [31:0]
	.ep26wire(ep26wire), // input wire [31:0]
	.ep27wire(ep27wire), // input wire [31:0]
	.ep28wire(ep28wire), // input wire [31:0]
	.ep29wire(ep29wire), // input wire [31:0]
	.ep2Awire(ep2Awire), // input wire [31:0]
	.ep2Bwire(ep2Bwire), // input wire [31:0]
	.ep2Cwire(ep2Cwire), // input wire [31:0]
	.ep2Dwire(ep2Dwire), // input wire [31:0]
	.ep2Ewire(ep2Ewire), // input wire [31:0]
	.ep2Fwire(ep2Fwire), // input wire [31:0]
	.ep30wire(ep30wire), // input wire [31:0]
	.ep31wire(ep31wire), // input wire [31:0]
	.ep32wire(ep32wire), // input wire [31:0]
	.ep33wire(ep33wire), // input wire [31:0]
	.ep34wire(ep34wire), // input wire [31:0]
	.ep35wire(ep35wire), // input wire [31:0]
	.ep36wire(ep36wire), // input wire [31:0]
	.ep37wire(ep37wire), // input wire [31:0]
	.ep38wire(ep38wire), // input wire [31:0]
	.ep39wire(ep39wire), // input wire [31:0]
	.ep3Awire(ep3Awire), // input wire [31:0]
	.ep3Bwire(ep3Bwire), // input wire [31:0]
	.ep3Cwire(ep3Cwire), // input wire [31:0]
	.ep3Dwire(ep3Dwire), // input wire [31:0]
	.ep3Ewire(ep3Ewire), // input wire [31:0]
	.ep3Fwire(ep3Fwire), // input wire [31:0]
	//}
	
	// Trigger In 	0x40 - 0x5F //{
	.ep40ck(ep40ck), .ep40trig(ep40trig), // input wire, output wire [31:0],
	.ep41ck(ep41ck), .ep41trig(ep41trig), // input wire, output wire [31:0],
	.ep42ck(ep42ck), .ep42trig(ep42trig), // input wire, output wire [31:0],
	.ep43ck(ep43ck), .ep43trig(ep43trig), // input wire, output wire [31:0],
	.ep44ck(ep44ck), .ep44trig(ep44trig), // input wire, output wire [31:0],
	.ep45ck(ep45ck), .ep45trig(ep45trig), // input wire, output wire [31:0],
	.ep46ck(ep46ck), .ep46trig(ep46trig), // input wire, output wire [31:0],
	.ep47ck(ep47ck), .ep47trig(ep47trig), // input wire, output wire [31:0],
	.ep48ck(ep48ck), .ep48trig(ep48trig), // input wire, output wire [31:0],
	.ep49ck(ep49ck), .ep49trig(ep49trig), // input wire, output wire [31:0],
	.ep4Ack(ep4Ack), .ep4Atrig(ep4Atrig), // input wire, output wire [31:0],
	.ep4Bck(ep4Bck), .ep4Btrig(ep4Btrig), // input wire, output wire [31:0],
	.ep4Cck(ep4Cck), .ep4Ctrig(ep4Ctrig), // input wire, output wire [31:0],
	.ep4Dck(ep4Dck), .ep4Dtrig(ep4Dtrig), // input wire, output wire [31:0],
	.ep4Eck(ep4Eck), .ep4Etrig(ep4Etrig), // input wire, output wire [31:0],
	.ep4Fck(ep4Fck), .ep4Ftrig(ep4Ftrig), // input wire, output wire [31:0],
	.ep50ck(ep50ck), .ep50trig(ep50trig), // input wire, output wire [31:0],
	.ep51ck(ep51ck), .ep51trig(ep51trig), // input wire, output wire [31:0],
	.ep52ck(ep52ck), .ep52trig(ep52trig), // input wire, output wire [31:0],
	.ep53ck(ep53ck), .ep53trig(ep53trig), // input wire, output wire [31:0],
	.ep54ck(ep54ck), .ep54trig(ep54trig), // input wire, output wire [31:0],
	.ep55ck(ep55ck), .ep55trig(ep55trig), // input wire, output wire [31:0],
	.ep56ck(ep56ck), .ep56trig(ep56trig), // input wire, output wire [31:0],
	.ep57ck(ep57ck), .ep57trig(ep57trig), // input wire, output wire [31:0],
	.ep58ck(ep58ck), .ep58trig(ep58trig), // input wire, output wire [31:0],
	.ep59ck(ep59ck), .ep59trig(ep59trig), // input wire, output wire [31:0],
	.ep5Ack(ep5Ack), .ep5Atrig(ep5Atrig), // input wire, output wire [31:0],
	.ep5Bck(ep5Bck), .ep5Btrig(ep5Btrig), // input wire, output wire [31:0],
	.ep5Cck(ep5Cck), .ep5Ctrig(ep5Ctrig), // input wire, output wire [31:0],
	.ep5Dck(ep5Dck), .ep5Dtrig(ep5Dtrig), // input wire, output wire [31:0],
	.ep5Eck(ep5Eck), .ep5Etrig(ep5Etrig), // input wire, output wire [31:0],
	.ep5Fck(ep5Fck), .ep5Ftrig(ep5Ftrig), // input wire, output wire [31:0],
	//}
	
	// Trigger Out 	0x60 - 0x7F //{
	.ep60ck(ep60ck), .ep60trig(ep60trig), // input wire, input wire [31:0],
	.ep61ck(ep61ck), .ep61trig(ep61trig), // input wire, input wire [31:0],
	.ep62ck(ep62ck), .ep62trig(ep62trig), // input wire, input wire [31:0],
	.ep63ck(ep63ck), .ep63trig(ep63trig), // input wire, input wire [31:0],
	.ep64ck(ep64ck), .ep64trig(ep64trig), // input wire, input wire [31:0],
	.ep65ck(ep65ck), .ep65trig(ep65trig), // input wire, input wire [31:0],
	.ep66ck(ep66ck), .ep66trig(ep66trig), // input wire, input wire [31:0],
	.ep67ck(ep67ck), .ep67trig(ep67trig), // input wire, input wire [31:0],
	.ep68ck(ep68ck), .ep68trig(ep68trig), // input wire, input wire [31:0],
	.ep69ck(ep69ck), .ep69trig(ep69trig), // input wire, input wire [31:0],
	.ep6Ack(ep6Ack), .ep6Atrig(ep6Atrig), // input wire, input wire [31:0],
	.ep6Bck(ep6Bck), .ep6Btrig(ep6Btrig), // input wire, input wire [31:0],
	.ep6Cck(ep6Cck), .ep6Ctrig(ep6Ctrig), // input wire, input wire [31:0],
	.ep6Dck(ep6Dck), .ep6Dtrig(ep6Dtrig), // input wire, input wire [31:0],
	.ep6Eck(ep6Eck), .ep6Etrig(ep6Etrig), // input wire, input wire [31:0],
	.ep6Fck(ep6Fck), .ep6Ftrig(ep6Ftrig), // input wire, input wire [31:0],
	.ep70ck(ep70ck), .ep70trig(ep70trig), // input wire, input wire [31:0],
	.ep71ck(ep71ck), .ep71trig(ep71trig), // input wire, input wire [31:0],
	.ep72ck(ep72ck), .ep72trig(ep72trig), // input wire, input wire [31:0],
	.ep73ck(ep73ck), .ep73trig(ep73trig), // input wire, input wire [31:0],
	.ep74ck(ep74ck), .ep74trig(ep74trig), // input wire, input wire [31:0],
	.ep75ck(ep75ck), .ep75trig(ep75trig), // input wire, input wire [31:0],
	.ep76ck(ep76ck), .ep76trig(ep76trig), // input wire, input wire [31:0],
	.ep77ck(ep77ck), .ep77trig(ep77trig), // input wire, input wire [31:0],
	.ep78ck(ep78ck), .ep78trig(ep78trig), // input wire, input wire [31:0],
	.ep79ck(ep79ck), .ep79trig(ep79trig), // input wire, input wire [31:0],
	.ep7Ack(ep7Ack), .ep7Atrig(ep7Atrig), // input wire, input wire [31:0],
	.ep7Bck(ep7Bck), .ep7Btrig(ep7Btrig), // input wire, input wire [31:0],
	.ep7Cck(ep7Cck), .ep7Ctrig(ep7Ctrig), // input wire, input wire [31:0],
	.ep7Dck(ep7Dck), .ep7Dtrig(ep7Dtrig), // input wire, input wire [31:0],
	.ep7Eck(ep7Eck), .ep7Etrig(ep7Etrig), // input wire, input wire [31:0],
	.ep7Fck(ep7Fck), .ep7Ftrig(ep7Ftrig), // input wire, input wire [31:0],
	//}
	
	// Pipe In 		0x80 - 0x9F //{
	.ep80wr(ep80wr), .ep80pipe(ep80pipe), // output wire, output wire [31:0],
	.ep81wr(ep81wr), .ep81pipe(ep81pipe), // output wire, output wire [31:0],
	.ep82wr(ep82wr), .ep82pipe(ep82pipe), // output wire, output wire [31:0],
	.ep83wr(ep83wr), .ep83pipe(ep83pipe), // output wire, output wire [31:0],
	.ep84wr(ep84wr), .ep84pipe(ep84pipe), // output wire, output wire [31:0],
	.ep85wr(ep85wr), .ep85pipe(ep85pipe), // output wire, output wire [31:0],
	.ep86wr(ep86wr), .ep86pipe(ep86pipe), // output wire, output wire [31:0],
	.ep87wr(ep87wr), .ep87pipe(ep87pipe), // output wire, output wire [31:0],
	.ep88wr(ep88wr), .ep88pipe(ep88pipe), // output wire, output wire [31:0],
	.ep89wr(ep89wr), .ep89pipe(ep89pipe), // output wire, output wire [31:0],
	.ep8Awr(ep8Awr), .ep8Apipe(ep8Apipe), // output wire, output wire [31:0],
	.ep8Bwr(ep8Bwr), .ep8Bpipe(ep8Bpipe), // output wire, output wire [31:0],
	.ep8Cwr(ep8Cwr), .ep8Cpipe(ep8Cpipe), // output wire, output wire [31:0],
	.ep8Dwr(ep8Dwr), .ep8Dpipe(ep8Dpipe), // output wire, output wire [31:0],
	.ep8Ewr(ep8Ewr), .ep8Epipe(ep8Epipe), // output wire, output wire [31:0],
	.ep8Fwr(ep8Fwr), .ep8Fpipe(ep8Fpipe), // output wire, output wire [31:0],
	.ep90wr(ep90wr), .ep90pipe(ep90pipe), // output wire, output wire [31:0],
	.ep91wr(ep91wr), .ep91pipe(ep91pipe), // output wire, output wire [31:0],
	.ep92wr(ep92wr), .ep92pipe(ep92pipe), // output wire, output wire [31:0],
	.ep93wr(ep93wr), .ep93pipe(ep93pipe), // output wire, output wire [31:0],
	.ep94wr(ep94wr), .ep94pipe(ep94pipe), // output wire, output wire [31:0],
	.ep95wr(ep95wr), .ep95pipe(ep95pipe), // output wire, output wire [31:0],
	.ep96wr(ep96wr), .ep96pipe(ep96pipe), // output wire, output wire [31:0],
	.ep97wr(ep97wr), .ep97pipe(ep97pipe), // output wire, output wire [31:0],
	.ep98wr(ep98wr), .ep98pipe(ep98pipe), // output wire, output wire [31:0],
	.ep99wr(ep99wr), .ep99pipe(ep99pipe), // output wire, output wire [31:0],
	.ep9Awr(ep9Awr), .ep9Apipe(ep9Apipe), // output wire, output wire [31:0],
	.ep9Bwr(ep9Bwr), .ep9Bpipe(ep9Bpipe), // output wire, output wire [31:0],
	.ep9Cwr(ep9Cwr), .ep9Cpipe(ep9Cpipe), // output wire, output wire [31:0],
	.ep9Dwr(ep9Dwr), .ep9Dpipe(ep9Dpipe), // output wire, output wire [31:0],
	.ep9Ewr(ep9Ewr), .ep9Epipe(ep9Epipe), // output wire, output wire [31:0],
	.ep9Fwr(ep9Fwr), .ep9Fpipe(ep9Fpipe), // output wire, output wire [31:0],
	//}
	
	// Pipe Out 	0xA0 - 0xBF //{
	.epA0rd(epA0rd), .epA0pipe(epA0pipe), // output wire, input wire [31:0],
	.epA1rd(epA1rd), .epA1pipe(epA1pipe), // output wire, input wire [31:0],
	.epA2rd(epA2rd), .epA2pipe(epA2pipe), // output wire, input wire [31:0],
	.epA3rd(epA3rd), .epA3pipe(epA3pipe), // output wire, input wire [31:0],
	.epA4rd(epA4rd), .epA4pipe(epA4pipe), // output wire, input wire [31:0],
	.epA5rd(epA5rd), .epA5pipe(epA5pipe), // output wire, input wire [31:0],
	.epA6rd(epA6rd), .epA6pipe(epA6pipe), // output wire, input wire [31:0],
	.epA7rd(epA7rd), .epA7pipe(epA7pipe), // output wire, input wire [31:0],
	.epA8rd(epA8rd), .epA8pipe(epA8pipe), // output wire, input wire [31:0],
	.epA9rd(epA9rd), .epA9pipe(epA9pipe), // output wire, input wire [31:0],
	.epAArd(epAArd), .epAApipe(epAApipe), // output wire, input wire [31:0],
	.epABrd(epABrd), .epABpipe(epABpipe), // output wire, input wire [31:0],
	.epACrd(epACrd), .epACpipe(epACpipe), // output wire, input wire [31:0],
	.epADrd(epADrd), .epADpipe(epADpipe), // output wire, input wire [31:0],
	.epAErd(epAErd), .epAEpipe(epAEpipe), // output wire, input wire [31:0],
	.epAFrd(epAFrd), .epAFpipe(epAFpipe), // output wire, input wire [31:0],
	.epB0rd(epB0rd), .epB0pipe(epB0pipe), // output wire, input wire [31:0],
	.epB1rd(epB1rd), .epB1pipe(epB1pipe), // output wire, input wire [31:0],
	.epB2rd(epB2rd), .epB2pipe(epB2pipe), // output wire, input wire [31:0],
	.epB3rd(epB3rd), .epB3pipe(epB3pipe), // output wire, input wire [31:0],
	.epB4rd(epB4rd), .epB4pipe(epB4pipe), // output wire, input wire [31:0],
	.epB5rd(epB5rd), .epB5pipe(epB5pipe), // output wire, input wire [31:0],
	.epB6rd(epB6rd), .epB6pipe(epB6pipe), // output wire, input wire [31:0],
	.epB7rd(epB7rd), .epB7pipe(epB7pipe), // output wire, input wire [31:0],
	.epB8rd(epB8rd), .epB8pipe(epB8pipe), // output wire, input wire [31:0],
	.epB9rd(epB9rd), .epB9pipe(epB9pipe), // output wire, input wire [31:0],
	.epBArd(epBArd), .epBApipe(epBApipe), // output wire, input wire [31:0],
	.epBBrd(epBBrd), .epBBpipe(epBBpipe), // output wire, input wire [31:0],
	.epBCrd(epBCrd), .epBCpipe(epBCpipe), // output wire, input wire [31:0],
	.epBDrd(epBDrd), .epBDpipe(epBDpipe), // output wire, input wire [31:0],
	.epBErd(epBErd), .epBEpipe(epBEpipe), // output wire, input wire [31:0],
	.epBFrd(epBFrd), .epBFpipe(epBFpipe), // output wire, input wire [31:0],
	//}
	
	// Pipe clock output
	.epPPck(pipeClk)//output wire // sync with write/read of pipe // 72MHz
	);

//}

// assign //{

assign w_adrs_offset_mac_48b[47:16] = {8'h00,8'h00,8'h00,8'h00}; // assign high 32b
assign w_adrs_offset_ip_32b [31:16] = {8'h00,8'h00}            ; // assign high 16b

//}

//}


/* TODO: TP */ //{  // TP on FPGA module

// ports for TP //{

// # H13  o_B15_L1P  TP0
// # G13  o_B15_L1N  TP1
// # G15  o_B15_L2P  TP2
// # G16  o_B15_L2N  TP3
// # J14  o_B15_L3P  TP4
// # H14  o_B15_L3N  TP5
// # J15  o_B15_L5P  TP6
// # H15  o_B15_L5N  TP7

//(* keep = "true" *) wire [7:0] TP;

// wire  TP0  = 1'b1; // test TP0 // test for eeprom : VCC_3.3V
// wire  TP1  = 1'b0; // test TP1 // test for eeprom : VSS_GND
// wire  TP2  = 1'b0; // test TP2 // test for eeprom : SCIO
// wire  TP3  = 1'b0; // test TP3 // test for eeprom : NA 
// wire  TP4  = 1'b1; // test TP4 // test for eeprom : GND
// wire  TP5  = 1'b0; // test TP5 // test for eeprom : DAC_BUSY
// wire  TP6  = 1'b0; // test TP6 // test for eeprom : ADC_BUSY
// wire  TP7  = 1'b0; // test TP7 // test for eeprom : SPIO_BUSY

// assign TP4 = 1'b0;
// assign TP5 = w_busy_DAC_update; 2016
// assign TP6 = w_ADC_busy_pclk  ; 2481
// assign TP7 = w_busy_SPI_frame ; 1790

// OBUF obuf__TP0__inst (.O( o_B15_L1P  ), .I( TP[0] ) ); // TP0
// OBUF obuf__TP1__inst (.O( o_B15_L1N  ), .I( TP[1] ) ); // TP1
// OBUF obuf__TP2__inst (.O( o_B15_L2P  ), .I( TP[2] ) ); // TP2
// OBUF obuf__TP3__inst (.O( o_B15_L2N  ), .I( TP[3] ) ); // TP3
// OBUF obuf__TP4__inst (.O( o_B15_L3P  ), .I( TP[4] ) ); // TP4
// OBUF obuf__TP5__inst (.O( o_B15_L3N  ), .I( TP[5] ) ); // TP5
// OBUF obuf__TP6__inst (.O( o_B15_L5P  ), .I( TP[6] ) ); // TP6
// OBUF obuf__TP7__inst (.O( o_B15_L5N  ), .I( TP[7] ) ); // TP7

(* keep = "true" *) wire [7:0] TP_out;
(* keep = "true" *) wire [7:0] TP_tri; // enable high-Z
(* keep = "true" *) wire [7:0] TP_in;

IOBUF iobuf__TP0__inst(.IO(io_B15_L1P  ), .T(TP_tri[0]), .I(TP_out[0] ), .O(TP_in[0] ) ); //
IOBUF iobuf__TP1__inst(.IO(io_B15_L1N  ), .T(TP_tri[1]), .I(TP_out[1] ), .O(TP_in[1] ) ); //
IOBUF iobuf__TP2__inst(.IO(io_B15_L2P  ), .T(TP_tri[2]), .I(TP_out[2] ), .O(TP_in[2] ) ); //
IOBUF iobuf__TP3__inst(.IO(io_B15_L2N  ), .T(TP_tri[3]), .I(TP_out[3] ), .O(TP_in[3] ) ); //
IOBUF iobuf__TP4__inst(.IO(io_B15_L3P  ), .T(TP_tri[4]), .I(TP_out[4] ), .O(TP_in[4] ) ); //
IOBUF iobuf__TP5__inst(.IO(io_B15_L3N  ), .T(TP_tri[5]), .I(TP_out[5] ), .O(TP_in[5] ) ); //
IOBUF iobuf__TP6__inst(.IO(io_B15_L5P  ), .T(TP_tri[6]), .I(TP_out[6] ), .O(TP_in[6] ) ); //
IOBUF iobuf__TP7__inst(.IO(io_B15_L5N  ), .T(TP_tri[7]), .I(TP_out[7] ), .O(TP_in[7] ) ); //

//assign TP_out[0] = 1'b1;     // for EEPROM test 
//assign TP_out[1] = 1'b0;     // for EEPROM test 
//assign TP_out[2] = 1'b0;    // for EEPROM test
assign TP_out[3] = 1'b0; 
//assign TP_out[4] = 1'b0; // for busy monitor
//assign TP_out[5] = 1'b0; // for busy monitor
//assign TP_out[6] = 1'b0; // for busy monitor
//assign TP_out[7] = 1'b0; // for busy monitor

//assign TP_tri[0] = 1'b0; // '0' enable output // for EEPROM test
//assign TP_tri[1] = 1'b0; // '0' enable output // for EEPROM test
//assign TP_tri[2] = 1'b1;                      // for EEPROM test
assign TP_tri[3] = 1'b1; 
//assign TP_tri[4] = 1'b1; // for busy monitor
//assign TP_tri[5] = 1'b1; // for busy monitor
//assign TP_tri[6] = 1'b1; // for busy monitor
//assign TP_tri[7] = 1'b1; // for busy monitor


//}

//}

//-------------------------------------------------------//






//-------------------------------------------------------//

/* TODO: mapping endpoints to signals for MHVSU BASE board */ //{

//// TEST wires //{
wire [31:0] w_SW_BUILD_ID_WI = ep00wire; // alternatively, w_GP_WI
wire [31:0] w_TEST_CON_WI    = ep01wire;
wire [31:0] w_RNET_CON_WI    = ep03wire;
//
wire [31:0] w_FPGA_IMAGE_ID_WO ; assign ep20wire = w_FPGA_IMAGE_ID_WO; // alternatively, w_GP_WO
wire [31:0] w_TEST_FLAG_WO     ; assign ep21wire = w_TEST_FLAG_WO;
wire [31:0] w_MON_XADC_WO      ; assign ep23wire = w_MON_XADC_WO;
wire [31:0] w_MON_GP_WO        ; assign ep24wire = w_MON_GP_WO;
//
wire [31:0] w_TEST_TI        = ep41trig; assign ep41ck = sys_clk;
//
wire [31:0] w_TEST_TO          ; assign ep61trig = w_TEST_TO     ; assign ep61ck = sys_clk; 
//}

//// MCS setup wire //{

//MCS_SETUP_WI // dedicated to MCS // updated by MCS boot-up
wire [31:0] w_MCS_SETUP_WI = ep11wire;
	// bit [31:16] = board ID // 0000~9999, set from EEPROM via MCS
	// bit [10]    = select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD // set from MCS
	// bit [9]     = w_con_port__L_MEM_SIO__H_TP                // set from MCS
	// bit [8]     = w_con_fifo_path__L_sspi_H_lan              // set from MCS
	// bit [3:0]   = slot ID  // 00~99, set from EEPROM via MCS
//
wire [ 3:0]  w_slot_id;
wire [15:0] w_board_id = w_MCS_SETUP_WI[31:16];

//}

//// SSPI wires //{
wire [31:0] w_SSPI_CON_WI  = ep02wire; // controls ... 
			// w_SSPI_CON_WI[0] enables SSPI control from USB 
			// w_SSPI_CON_WI[1] ...
wire [31:0] w_SSPI_FLAG_WO; assign ep22wire = w_SSPI_FLAG_WO;
//

// HW reset signal : SPIO, DAC, ADC, TRIG_IO, MEM, TEST_COUNTER, XADC, TIMESTAMP
wire w_HW_reset__ext;
wire w_HW_reset = w_SSPI_CON_WI[3] | w_HW_reset__ext;

wire w_SSPI_TEST_mode_en; //$$ hw emulation for mother board master spi
wire [31:0] w_SSPI_TEST_WI   = ep17wire; // test data for SSPI
wire [31:0] w_SSPI_TEST_WO; //$$ assign ep21wire = w_SSPI_TEST_WO; //$$ share with ep21wire or w_TEST_FLAG_WO
//wire [31:0] w_SSPI_TI   = ep42trig; assign ep42ck = sys_clk;
wire [31:0] w_SSPI_TEST_TI   = ep42trig; assign ep42ck = base_sspi_clk;
//wire [31:0] w_SSPI_TO      = 32'b0; assign ep62trig = w_SSPI_TO; assign ep62ck = sys_clk;
wire [31:0] w_SSPI_TEST_TO; assign ep62trig = w_SSPI_TEST_TO; assign ep62ck = base_sspi_clk; // vs sys_clk

//
wire [31:0] w_SSPI_BD_STAT_WO           ;
wire [31:0] w_SSPI_CNT_CS_M0_WO         ;
wire [31:0] w_SSPI_CNT_CS_M1_WO         ;
wire [31:0] w_SSPI_CNT_ADC_FIFO_IN_WO   ;
wire [31:0] w_SSPI_CNT_ADC_TRIG_WO  ;
wire [31:0] w_SSPI_CNT_SPIO_FRM_TRIG_WO ;
wire [31:0] w_SSPI_CNT_DAC_TRIG_WO  ;
//}

//// MHVSU_SPIO wires //{
wire [31:0] w_SPIO_FDAT_WI   = ep04wire; // frame data : ={4'b0, pin_adrs[2:0], R_W_bar, reg_adrs[7:0], DA[7:0], DB[7:0]}
wire [31:0] w_SPIO_CON_WI    = ep05wire; // control    : ={socket_enable[7:0],5'b0, frame_cs_enable[2:0],15'b0, enable}
wire [31:0] w_SPIO_S1_WI     = ep08wire;
wire [31:0] w_SPIO_S2_WI     = ep09wire;
wire [31:0] w_SPIO_S3_WI     = ep0Awire;
wire [31:0] w_SPIO_S4_WI     = ep0Bwire;
wire [31:0] w_SPIO_S5_WI     = ep0Cwire;
wire [31:0] w_SPIO_S6_WI     = ep0Dwire;
wire [31:0] w_SPIO_S7_WI     = ep0Ewire;
wire [31:0] w_SPIO_S8_WI     = ep0Fwire;
//  wire [31:0] w_SPIO_AUX_S1_WI = ep10wire;
//  wire [31:0] w_SPIO_AUX_S2_WI = ep11wire;
//  wire [31:0] w_SPIO_AUX_S3_WI = ep12wire;
//  wire [31:0] w_SPIO_AUX_S4_WI = ep13wire;
//  wire [31:0] w_SPIO_AUX_S5_WI = ep14wire;
//  wire [31:0] w_SPIO_AUX_S6_WI = ep15wire;
//  wire [31:0] w_SPIO_AUX_S7_WI = ep16wire;
//  wire [31:0] w_SPIO_AUX_S8_WI = ep17wire;
//
wire [31:0] w_SPIO_FLAG_WO          ; assign ep25wire = w_SPIO_FLAG_WO  ;
wire [31:0] w_SPIO_TRIG_TI = ep45trig; assign ep45ck = sys_clk; // trig control : ={..., frame_trig, reset_trig}
//
wire [31:0] w_SPIO_TRIG_TO          ; assign ep65trig = w_SPIO_TRIG_TO; assign ep65ck = sys_clk;
//}

//// MHVSU_DAC wires //{
wire [31:0] w_DAC_CON_WI = ep06wire;
wire [31:0] w_DAC_S1_WI  = ep18wire;
wire [31:0] w_DAC_S2_WI  = ep19wire;
wire [31:0] w_DAC_S3_WI  = ep1Awire;
wire [31:0] w_DAC_S4_WI  = ep1Bwire;
wire [31:0] w_DAC_S5_WI  = ep1Cwire;
wire [31:0] w_DAC_S6_WI  = ep1Dwire;
wire [31:0] w_DAC_S7_WI  = ep1Ewire;
wire [31:0] w_DAC_S8_WI  = ep1Fwire;
//
wire [31:0] w_DAC_FLAG_WO; assign ep26wire = w_DAC_FLAG_WO;
wire [31:0] w_DAC_S1_WO  ; assign ep38wire = w_DAC_S1_WO  ;
wire [31:0] w_DAC_S2_WO  ; assign ep39wire = w_DAC_S2_WO  ;
wire [31:0] w_DAC_S3_WO  ; assign ep3Awire = w_DAC_S3_WO  ;
wire [31:0] w_DAC_S4_WO  ; assign ep3Bwire = w_DAC_S4_WO  ;
wire [31:0] w_DAC_S5_WO  ; assign ep3Cwire = w_DAC_S5_WO  ;
wire [31:0] w_DAC_S6_WO  ; assign ep3Dwire = w_DAC_S6_WO  ;
wire [31:0] w_DAC_S7_WO  ; assign ep3Ewire = w_DAC_S7_WO  ;
wire [31:0] w_DAC_S8_WO  ; assign ep3Fwire = w_DAC_S8_WO  ;
//
wire [31:0] w_DAC_TRIG_TI = ep46trig; assign ep46ck = sys_clk; // {..., aux_trig, update_trig, init_trig, frame_trig, reset_trig}
//
wire [31:0] w_DAC_TRIG_TO ; assign ep66trig = w_DAC_TRIG_TO; assign ep66ck = sys_clk;

//}

//// MHVSU_ADC wires //{
wire [31:0] w_ADC_CON_WI = ep07wire; // ADC control
wire [31:0] w_ADC_PAR_WI = ep10wire; // ADC parameters
//
wire [31:0] w_ADC_FLAG_WO ; assign ep27wire = w_ADC_FLAG_WO;
//
wire [31:0] w_ADC_S1_ACC_WO    ;    wire [31:0] w_ADC_S1_MAX_WO    ; 
wire [31:0] w_ADC_S2_ACC_WO    ;    wire [31:0] w_ADC_S2_MAX_WO    ; 
wire [31:0] w_ADC_S3_ACC_WO    ;    wire [31:0] w_ADC_S3_MAX_WO    ; 
wire [31:0] w_ADC_S4_ACC_WO    ;    wire [31:0] w_ADC_S4_MAX_WO    ; 
wire [31:0] w_ADC_S5_ACC_WO    ;    wire [31:0] w_ADC_S5_MAX_WO    ; 
wire [31:0] w_ADC_S6_ACC_WO    ;    wire [31:0] w_ADC_S6_MAX_WO    ; 
wire [31:0] w_ADC_S7_ACC_WO    ;    wire [31:0] w_ADC_S7_MAX_WO    ; 
wire [31:0] w_ADC_S8_ACC_WO    ;    wire [31:0] w_ADC_S8_MAX_WO    ; 
//
wire [31:0] w_ADC_S1_ACC_MAX_WO; 
wire [31:0] w_ADC_S2_ACC_MAX_WO;
wire [31:0] w_ADC_S3_ACC_MAX_WO;
wire [31:0] w_ADC_S4_ACC_MAX_WO;
wire [31:0] w_ADC_S5_ACC_MAX_WO;
wire [31:0] w_ADC_S6_ACC_MAX_WO;
wire [31:0] w_ADC_S7_ACC_MAX_WO;
wire [31:0] w_ADC_S8_ACC_MAX_WO;
//
assign ep28wire = w_ADC_S1_ACC_MAX_WO;
assign ep29wire = w_ADC_S2_ACC_MAX_WO;
assign ep2Awire = w_ADC_S3_ACC_MAX_WO;
assign ep2Bwire = w_ADC_S4_ACC_MAX_WO;
assign ep2Cwire = w_ADC_S5_ACC_MAX_WO;
assign ep2Dwire = w_ADC_S6_ACC_MAX_WO;
assign ep2Ewire = w_ADC_S7_ACC_MAX_WO;
assign ep2Fwire = w_ADC_S8_ACC_MAX_WO;
//
wire [31:0] w_ADC_S1_WO        ;   wire [31:0] w_ADC_S1_MIN_WO    ; 
wire [31:0] w_ADC_S2_WO        ;   wire [31:0] w_ADC_S2_MIN_WO    ; 
wire [31:0] w_ADC_S3_WO        ;   wire [31:0] w_ADC_S3_MIN_WO    ; 
wire [31:0] w_ADC_S4_WO        ;   wire [31:0] w_ADC_S4_MIN_WO    ; 
wire [31:0] w_ADC_S5_WO        ;   wire [31:0] w_ADC_S5_MIN_WO    ; 
wire [31:0] w_ADC_S6_WO        ;   wire [31:0] w_ADC_S6_MIN_WO    ; 
wire [31:0] w_ADC_S7_WO        ;   wire [31:0] w_ADC_S7_MIN_WO    ; 
wire [31:0] w_ADC_S8_WO        ;   wire [31:0] w_ADC_S8_MIN_WO    ; 
//
wire [31:0] w_ADC_S1_VAL_MIN_WO; 
wire [31:0] w_ADC_S2_VAL_MIN_WO; 
wire [31:0] w_ADC_S3_VAL_MIN_WO; 
wire [31:0] w_ADC_S4_VAL_MIN_WO; 
wire [31:0] w_ADC_S5_VAL_MIN_WO; 
wire [31:0] w_ADC_S6_VAL_MIN_WO; 
wire [31:0] w_ADC_S7_VAL_MIN_WO; 
wire [31:0] w_ADC_S8_VAL_MIN_WO; 
//
assign ep30wire = w_ADC_S1_VAL_MIN_WO;
assign ep31wire = w_ADC_S2_VAL_MIN_WO;
assign ep32wire = w_ADC_S3_VAL_MIN_WO;
assign ep33wire = w_ADC_S4_VAL_MIN_WO;
assign ep34wire = w_ADC_S5_VAL_MIN_WO;
assign ep35wire = w_ADC_S6_VAL_MIN_WO;
assign ep36wire = w_ADC_S7_VAL_MIN_WO;
assign ep37wire = w_ADC_S8_VAL_MIN_WO;
//
wire [31:0] w_ADC_TRIG_TI = ep47trig; assign ep47ck = p_adc_clk; // p_clk
//
wire [31:0] w_ADC_TRIG_TO ; assign ep67trig = w_ADC_TRIG_TO; assign ep67ck = p_adc_clk; // p_clk
//
wire [31:0] w_ADC_S1_CH1_PO ; assign epA0pipe = w_ADC_S1_CH1_PO; wire w_ADC_S1_CH1_PO_rd = epA0rd;  // ADC0_D  S1_CH1 
wire [31:0] w_ADC_S2_CH1_PO ; assign epA1pipe = w_ADC_S2_CH1_PO; wire w_ADC_S2_CH1_PO_rd = epA1rd;  // ADC0_B  S2_CH1
wire [31:0] w_ADC_S3_CH1_PO ; assign epA2pipe = w_ADC_S3_CH1_PO; wire w_ADC_S3_CH1_PO_rd = epA2rd;  // ADC1_D  S3_CH1
wire [31:0] w_ADC_S4_CH1_PO ; assign epA3pipe = w_ADC_S4_CH1_PO; wire w_ADC_S4_CH1_PO_rd = epA3rd;  // ADC1_B  S4_CH1
wire [31:0] w_ADC_S5_CH1_PO ; assign epA4pipe = w_ADC_S5_CH1_PO; wire w_ADC_S5_CH1_PO_rd = epA4rd;  // ADC2_D  S5_CH1
wire [31:0] w_ADC_S6_CH1_PO ; assign epA5pipe = w_ADC_S6_CH1_PO; wire w_ADC_S6_CH1_PO_rd = epA5rd;  // ADC2_B  S6_CH1
wire [31:0] w_ADC_S7_CH1_PO ; assign epA6pipe = w_ADC_S7_CH1_PO; wire w_ADC_S7_CH1_PO_rd = epA6rd;  // ADC3_D  S7_CH1
wire [31:0] w_ADC_S8_CH1_PO ; assign epA7pipe = w_ADC_S8_CH1_PO; wire w_ADC_S8_CH1_PO_rd = epA7rd;  // ADC3_B  S8_CH1
wire [31:0] w_ADC_S1_CH2_PO ; assign epA8pipe = w_ADC_S1_CH2_PO; wire w_ADC_S1_CH2_PO_rd = epA8rd;  // ADC0_C  S1_CH2
wire [31:0] w_ADC_S2_CH2_PO ; assign epA9pipe = w_ADC_S2_CH2_PO; wire w_ADC_S2_CH2_PO_rd = epA9rd;  // ADC0_A  S2_CH2
wire [31:0] w_ADC_S3_CH2_PO ; assign epAApipe = w_ADC_S3_CH2_PO; wire w_ADC_S3_CH2_PO_rd = epAArd;  // ADC1_C  S3_CH2
wire [31:0] w_ADC_S4_CH2_PO ; assign epABpipe = w_ADC_S4_CH2_PO; wire w_ADC_S4_CH2_PO_rd = epABrd;  // ADC1_A  S4_CH2
wire [31:0] w_ADC_S5_CH2_PO ; assign epACpipe = w_ADC_S5_CH2_PO; wire w_ADC_S5_CH2_PO_rd = epACrd;  // ADC2_C  S5_CH2
wire [31:0] w_ADC_S6_CH2_PO ; assign epADpipe = w_ADC_S6_CH2_PO; wire w_ADC_S6_CH2_PO_rd = epADrd;  // ADC2_A  S6_CH2
wire [31:0] w_ADC_S7_CH2_PO ; assign epAEpipe = w_ADC_S7_CH2_PO; wire w_ADC_S7_CH2_PO_rd = epAErd;  // ADC3_C  S7_CH2
wire [31:0] w_ADC_S8_CH2_PO ; assign epAFpipe = w_ADC_S8_CH2_PO; wire w_ADC_S8_CH2_PO_rd = epAFrd;  // ADC3_A  S8_CH2

//}

//// EXT_TRIG wires //{
wire [31:0] w_EXT_TRIG_CON_WI  = ep14wire; // sspi adrs 0x050
wire [31:0] w_EXT_TRIG_PARA_WI = ep15wire; // sspi adrs 0x054
wire [31:0] w_EXT_TRIG_AUX_WI  = ep16wire; // sspi adrs 0x058
//
wire [31:0] w_EXT_TRIG_TI = ep44trig; assign ep44ck = sys_clk; // {..., sw_aux_trig, sw_m_pre_trig, sw_m_trig, reset_trig}
//
wire [31:0] w_EXT_TRIG_TO ; assign ep64trig = w_EXT_TRIG_TO; assign ep64ck = sys_clk;
//

//}

//// MEM wires //{
wire [31:0] w_MEM_WI      = ep13wire;                                        //$$ MEM_WI		0x04C	wi13
wire [31:0] w_MEM_FDAT_WI = ep12wire;                                        //$$ MEM_FDAT_WI	0x048	wi12
wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;                    //$$ MEM_TI		0x14C	ti53
wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;   //$$ MEM_TO		0x1CC	to73
wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr;                  //$$ MEM_PI		0x24C	pi93
wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; //$$ MEM_PO		0x2CC	poB3
//}

//}

//-------------------------------------------------------//



//-------------------------------------------------------//

/* TODO: FPGA_IMAGE_ID */ //{

// assignment //{
assign w_FPGA_IMAGE_ID_WO = FPGA_IMAGE_ID;
//}

//}


/* TODO: TIMESTAMP */ //{
// global time index in debugger based on 10MHz 

// module //{
(* keep = "true" *) wire [31:0] w_timestamp;
//
sub_timestamp sub_timestamp_inst(
	.clk         (sys_clk),
	.reset_n     (reset_n & (~w_HW_reset)),
	.o_timestamp (w_timestamp),
	.valid       ()
);
//}

// assignment //{
wire [3:0] w_mon_gp_con = w_TEST_CON_WI[15:12];
assign w_MON_GP_WO = (w_mon_gp_con==4'h0)? w_timestamp: 32'b0;
//}

//}


/* TODO: XADC */ //{

// ports for XADC //{
wire  XADC_VP;
wire  XADC_VN;
IBUF ibuf__XADC_VP_inst  (.I(i_XADC_VP), .O(XADC_VP) ); // must be connected to XADC port
IBUF ibuf__XADC_VN_inst  (.I(i_XADC_VN), .O(XADC_VN) ); // must be connected to XADC port
//}
 
// module //{
wire [31:0] MEASURED_TEMP_MC;
wire [31:0] MEASURED_VCCINT_MV;
wire [31:0] MEASURED_VCCAUX_MV;
wire [31:0] MEASURED_VCCBRAM_MV;
wire [7:0] dbg_drp;
//
master_drp_ug480 master_drp_ug480_inst(
	.DCLK				(sys_clk), // input DCLK, // Clock input for DRP
	.RESET				(~reset_n | w_HW_reset), // input RESET,
	.VP					(XADC_VP), // input VP, VN,// Dedicated and Hardwired Analog Input Pair
	.VN					(XADC_VN),
	.MEASURED_TEMP		(), // output reg [15:0] MEASURED_TEMP, MEASURED_VCCINT,
	.MEASURED_VCCINT	(),
	.MEASURED_VCCAUX	(), // output reg [15:0] MEASURED_VCCAUX, MEASURED_VCCBRAM,
	.MEASURED_VCCBRAM	(),
	// converted to decimal
	.MEASURED_TEMP_MC		(MEASURED_TEMP_MC), 
	.MEASURED_VCCINT_MV		(MEASURED_VCCINT_MV),
	.MEASURED_VCCAUX_MV		(MEASURED_VCCAUX_MV), 
	.MEASURED_VCCBRAM_MV	(MEASURED_VCCBRAM_MV),
	//
	.ALM_OUT	(), // output wire ALM_OUT,
	.CHANNEL	(), // output wire [4:0] CHANNEL,
	.OT			(), // output wire OT,
	.XADC_EOC	(), // output wire XADC_EOC,
	.XADC_EOS	(), // output wire XADC_EOS
	.debug_out	(dbg_drp)
);
//}

// assignment //{
wire [3:0] w_mon_xadc_con = w_TEST_CON_WI[11:8];
assign w_MON_XADC_WO =  (w_mon_xadc_con==4'h0)? MEASURED_TEMP_MC  :
						(w_mon_xadc_con==4'h1)? MEASURED_VCCINT_MV  :
						(w_mon_xadc_con==4'h2)? MEASURED_VCCAUX_MV  :
						(w_mon_xadc_con==4'h3)? MEASURED_VCCBRAM_MV :
						32'b0;
//}
 
//}


/* TODO: Slot_ID (off module) */ //{

// ports for Slot_ID //{
wire  S_ID3_BUF;
wire  S_ID2_BUF;
wire  S_ID1_BUF;
wire  S_ID0_BUF;
IBUF ibuf__S_ID3_inst  (.I(i_B35_L3P), .O(S_ID3_BUF) );
IBUF ibuf__S_ID2_inst  (.I(i_B35_L3N), .O(S_ID2_BUF) );
IBUF ibuf__S_ID1_inst  (.I(i_B35_L2P), .O(S_ID1_BUF) );
IBUF ibuf__S_ID0_inst  (.I(i_B35_L2N), .O(S_ID0_BUF) );
//}

// assignment //{
//$$wire [3:0] w_slot_id; 
//
assign w_slot_id = (w_MCS_SETUP_WI[3:0]==0)? 
	{S_ID3_BUF,S_ID2_BUF,S_ID1_BUF,S_ID0_BUF}:
	w_MCS_SETUP_WI[3:0];
//
//assign w_TEST_FLAG_WO[23:16] = {4'b0, w_slot_id}; 
assign w_TEST_FLAG_WO[19:16] = w_slot_id[3:0]; 

// for dedicated LAN setup from MCS
assign w_adrs_offset_mac_48b[15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
assign w_adrs_offset_ip_32b [15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b

//}

//}


/* TODO: RES_NET (off module) */ //{

// ports for RES_NET //{
wire  RES_NET_0; // non-inverting open-drain buffer // '0' for led R on // '1' for ADC power on
wire  RES_NET_1; // non-inverting open-drain buffer // '0' for led Y on
//$$wire  RES_NET_2; // non-inverting open-drain buffer // '0' for led G on //$$ removed in REV2
//$$wire  RES_NET_3; // non-inverting open-drain buffer // '0' for led B on //$$ removed in REV2
OBUF obuf__RES_NET_0_OUT_inst (.O(o_B13_SYS_CLK_MC1  ), .I(RES_NET_0 & (~w_HW_reset)) ); //## hw reset added
OBUF obuf__RES_NET_1_OUT_inst (.O(o_B34_L5P          ), .I(RES_NET_1  ) ); // 
//$$OBUF obuf__RES_NET_2_OUT_inst (.O(o_B34_L24P         ), .I(RES_NET_2  ) ); // 
//$$OBUF obuf__RES_NET_3_OUT_inst (.O(o_B34_L24N         ), .I(RES_NET_3  ) ); // 
//}

// assignment //{
wire res_net_ctrl_ext_en;
//wire res_net_ctrl_ext_en = 1'b0; // test // to remove
wire [3:0] res_net_ctrl_ext_data;
//
assign RES_NET_0 = (res_net_ctrl_ext_en)? res_net_ctrl_ext_data[0] : w_RNET_CON_WI[0] ;
assign RES_NET_1 = (res_net_ctrl_ext_en)? res_net_ctrl_ext_data[1] : w_RNET_CON_WI[1] ;
//$$assign RES_NET_2 = (res_net_ctrl_ext_en)? res_net_ctrl_ext_data[2] : w_RNET_CON_WI[2] ;
//$$assign RES_NET_3 = (res_net_ctrl_ext_en)? res_net_ctrl_ext_data[3] : w_RNET_CON_WI[3] ;
//}

//}


/* TODO: TEST COUNTER */ //{

// module //{
wire [7:0]  test_shift_pattern;
wire [7:0]  count1;
wire        count1eq00;
wire        count1eq80;
wire        reset1;
wire        disable1;
wire [7:0]  count2;
wire        count2eqFF;
wire        reset2;
wire        up2;
wire        down2;
wire        autocount2;
//
test_counter_wrapper  test_counter_wrapper_inst (
	.sys_clk       (sys_clk),
	.reset_n       (reset_n & (~w_HW_reset)),
	//
	.o_count1      (count1),
	.reset1        (reset1),
	.disable1      (disable1),
	.o_count1eq00  (count1eq00),
	.o_count1eq80  (count1eq80),
	//
	.o_count2      (count2),
	.reset2        (reset2    ),
	.up2           (up2       ),
	.down2         (down2     ),
	.autocount2    (autocount2),
	.o_count2eqFF  (count2eqFF),
	//             
	.o_test        (test_shift_pattern) // circular right shift pattern
);
//}

// assignment //{
// Counter 1:
assign reset1     = w_TEST_CON_WI[0]; 
assign disable1   = w_TEST_CON_WI[1]; 
assign autocount2 = w_TEST_CON_WI[2]; 
//
//assign w_TEST_FLAG_WO[15:0] = {count2[7:0], count1[7:0]}; 
assign w_TEST_FLAG_WO[15:0] = 
	(w_SSPI_TEST_mode_en)? 
	w_SSPI_TEST_WO[15:0]       :
	{count2[7:0], count1[7:0]} ; //$$ share with SSPI_TEST
assign w_TEST_FLAG_WO[23]    = w_SSPI_TEST_mode_en; //$$
//
assign w_TEST_FLAG_WO[22:20] = 3'b0; //$$ not yet used
//
assign w_SSPI_TEST_WO[31:16] = 16'b0; //$$ not used

// Counter 2:
wire [2:0] count2_trig_ext_data;
assign reset2     = w_TEST_TI[0] | count2_trig_ext_data[0];
assign up2        = w_TEST_TI[1] | count2_trig_ext_data[1];
assign down2      = w_TEST_TI[2] | count2_trig_ext_data[2];
//
assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
//}

//}


/* TODO: LED */ //{

// function for LED //{
function [7:0] xem7310_led;
input [7:0] a;
integer i;
begin
	for(i=0; i<8; i=i+1) begin: for_xem7310_led
		// inverted and high-Z
		// to turn on LED ... logic '0' 
		xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
	end
end
endfunction
//}

// assignment for LED //{
wire [7:0] w_test_led = count1 ^ test_shift_pattern; // from test counter
assign led = xem7310_led(w_test_led);
//}

//}


/* TODO: MEM SIO (off module) */ //{  

// ports for MEM SIO //{

//# MC2-69  # MEM_SIO          set_property PACKAGE_PIN U16  [get_ports io_B13_L17N      ]

//// open-drain output style
// wire  MEM_SIO   = 1'b1; // test 
// wire  MEM_SIO_rd;
// IOBUF iobuf__MEM_SIO_inst(.IO(io_B13_L17N  ), .T(MEM_SIO), .I(MEM_SIO ), .O(MEM_SIO_rd ) ); //

// note that 10K ohm pull up is located on board.

//// high-Z control style 
wire  MEM_SIO_out; //  = 1'b1;
wire  MEM_SIO_tri; //  = 1'b1; // enable high-Z
(* keep = "true" *) wire  MEM_SIO_in;
IOBUF iobuf__MEM_SIO_inst(.IO(io_B13_L17N  ), .T(MEM_SIO_tri), .I(MEM_SIO_out ), .O(MEM_SIO_in ) ); //



//}

// modules //{

// path control 
wire w_con_fifo_path__L_sspi_H_lan;
wire w_con_port__L_MEM_SIO__H_TP;

// fifo read clock
wire c_eeprom_fifo_clk; // clock mux between lan and slave-spi end-points
//
BUFGMUX bufgmux_c_eeprom_fifo_clk_inst (
	.O(c_eeprom_fifo_clk), 
	.I0(base_sspi_clk), // base_sspi_clk for slave_spi_mth_brd // 104MHz
	.I1(pipeClk      ), // from lan_endpoint_wrapper_inst      // 72MHz
	.S(w_con_fifo_path__L_sspi_H_lan) 
);


// wires for module
wire w_MEM_rst;
wire w_MEM_fifo_rst;
wire w_MEM_valid;
//
wire w_trig_frame   ;
wire w_done_frame   ;
wire w_done_frame_TO;
//
wire [7:0] w_frame_data_CMD    ;
wire [7:0] w_frame_data_ADH    ;
wire [7:0] w_frame_data_ADL    ;
wire [7:0] w_frame_data_STA_in ;
wire [7:0] w_frame_data_STA_out;
//
wire [11:0] w_num_bytes_DAT    ;
wire        w_con_disable_SBP;
//
wire [7:0] w_frame_data_DAT_wr   ;
wire [7:0] w_frame_data_DAT_rd   ;
wire       w_frame_data_DAT_wr_en;
wire       w_frame_data_DAT_rd_en;

//
wire w_SCIO_DI;
wire w_SCIO_DO;
wire w_SCIO_OE;
//
control_eeprom__11AA160T  control_eeprom__11AA160T_inst (
	//
	.clk     (sys_clk                ), //	input  wire // 10MHz
	.reset_n (reset_n & (~w_MEM_rst) & (~w_HW_reset)), //	input  wire // TI
	
	// controls //{
	.i_trig_frame     (w_trig_frame   ), //	input  wire                    // TI
	.o_done_frame     (w_done_frame   ), //	output wire                    // TO
	.o_done_frame_TO  (w_done_frame_TO), //	output wire  // trig out @ clk // TO
	//	
	.i_en_SBP         (~w_con_disable_SBP  ), //	input  wire  // enable SBP (stand-by pulse) // WI
	//
	.i_frame_data_SHD (8'h55           ), //	input  wire [7:0]  // fixed
	.i_frame_data_DVA (8'hA0           ), //	input  wire [7:0]  // fixed
	.i_frame_data_CMD (w_frame_data_CMD    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADH (w_frame_data_ADH    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADL (w_frame_data_ADL    ), //	input  wire [7:0]  // WI
	.i_frame_data_STA (w_frame_data_STA_in ), //	input  wire [7:0]  // WI
	.o_frame_data_STA (w_frame_data_STA_out), //	output wire [7:0]  // TO
	//	
	.i_num_bytes_DAT  (w_num_bytes_DAT     ), //	input  wire [11:0] // WI
	//}
	
	// FIFO/PIPE interface //{
	.i_reset_fifo             (w_MEM_fifo_rst), //	input  wire    // TI
	//
	.i_frame_data_DAT         (w_frame_data_DAT_wr   ), //	input  wire [7:0] // PI
	.o_frame_data_DAT         (w_frame_data_DAT_rd   ), //	output wire [7:0] // PO
	//
	.i_frame_data_DAT_wr_en   (w_frame_data_DAT_wr_en), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_wr_clk  (c_eeprom_fifo_clk     ), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_rd_en   (w_frame_data_DAT_rd_en), // input wire // control for o_frame_data_DAT	
	.i_frame_data_DAT_rd_clk  (c_eeprom_fifo_clk     ), // input wire // control for o_frame_data_DAT	
	//}
	
	// IO ports //{
	.i_SCIO_DI        (w_SCIO_DI), // input  wire 
	.o_SCIO_DO        (w_SCIO_DO), // output wire 
	.o_SCIO_OE        (w_SCIO_OE), // output wire 
	//}

	.valid            (w_MEM_valid)//	output wire 
);

//}

// assignments //{


// wires for SSPI //$$
wire [31:0] mem_wi_______sspi;
wire [31:0] mem_fdat_wi__sspi;
wire [2:0]  mem_ti_______sspi;
//
wire        w_MEM_PI_wr_sspi_M0;
wire [31:0] w_MEM_PI_sspi_M0   ;
wire        w_MEM_PO_rd_sspi_M0;  wire w_MEM_PO_rd_sspi_M1;

// path control from w_MCS_SETUP_WI
assign w_con_fifo_path__L_sspi_H_lan = w_MCS_SETUP_WI[8]; // SSPI vs LAN
assign w_con_port__L_MEM_SIO__H_TP   = w_MCS_SETUP_WI[9]; // MEM_SIO vs TP


// w_MEM_WI //$$  
assign w_num_bytes_DAT               = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_WI[11:0] : mem_wi_______sspi[11:0] ; // 12-bit // 12:0 --> 11:0
assign w_con_disable_SBP             = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_WI[15]   : mem_wi_______sspi[15]   ; // 1-bit

// w_MEM_FDAT_WI //$$
assign w_frame_data_CMD              = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_FDAT_WI[ 7: 0] : mem_fdat_wi__sspi[ 7: 0] ; // 8-bit
assign w_frame_data_STA_in           = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_FDAT_WI[15: 8] : mem_fdat_wi__sspi[15: 8] ; // 8-bit
assign w_frame_data_ADL              = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_FDAT_WI[23:16] : mem_fdat_wi__sspi[23:16] ; // 8-bit
assign w_frame_data_ADH              = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_FDAT_WI[31:24] : mem_fdat_wi__sspi[31:24] ; // 8-bit

// w_MEM_TI
assign w_MEM_rst      = w_MEM_TI[0] | mem_ti_______sspi[0] ;
assign w_MEM_fifo_rst = w_MEM_TI[1] | mem_ti_______sspi[1] ;
assign w_trig_frame   = w_MEM_TI[2] | mem_ti_______sspi[2] ;

// w_MEM_TO
assign w_MEM_TO[0]     = w_MEM_valid    ;
assign w_MEM_TO[1]     = w_done_frame   ;
assign w_MEM_TO[2]     = w_done_frame_TO;
assign w_MEM_TO[ 7: 3] =  5'b0;
assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
assign w_MEM_TO[31:16] = 16'b0;

// w_MEM_PI
assign w_frame_data_DAT_wr    = (w_con_fifo_path__L_sspi_H_lan)? w_MEM_PI[7:0] : w_MEM_PI_sspi_M0[7:0]; // 8-bit
assign w_frame_data_DAT_wr_en = w_MEM_PI_wr | w_MEM_PI_wr_sspi_M0;

// w_MEM_PO
assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
assign w_MEM_PO[31:8]         = {24{w_frame_data_DAT_rd[7]}}; // rev signed expansion for compatibility
assign w_frame_data_DAT_rd_en = w_MEM_PO_rd | w_MEM_PO_rd_sspi_M0 | w_MEM_PO_rd_sspi_M1;

// port test
// 
assign w_SCIO_DI   = ( w_con_port__L_MEM_SIO__H_TP)?   TP_in[2] : MEM_SIO_in ; // switching
//                     
assign TP_out[2]   = ( w_con_port__L_MEM_SIO__H_TP)?  w_SCIO_DO : 1'b0 ; // test TP 
assign TP_tri[2]   = ( w_con_port__L_MEM_SIO__H_TP)? ~w_SCIO_OE : 1'b1 ; // test TP 
//
assign TP_out[0]   = ( w_con_port__L_MEM_SIO__H_TP)? 1'b1 : 1'b0 ; // for test power (3.3V) on signal line
assign TP_out[1]   = ( w_con_port__L_MEM_SIO__H_TP)? 1'b0 : 1'b0 ; // for test power (GND)  on signal line
assign TP_tri[0]   = ( w_con_port__L_MEM_SIO__H_TP)? 1'b0 : 1'b1 ; // for test power on signal line
assign TP_tri[1]   = ( w_con_port__L_MEM_SIO__H_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//
assign MEM_SIO_out = (~w_con_port__L_MEM_SIO__H_TP)?  w_SCIO_DO : 1'b0 ; // dedicated port
assign MEM_SIO_tri = (~w_con_port__L_MEM_SIO__H_TP)? ~w_SCIO_OE : 1'b1 ; // dedicated port


//}


//}

//-------------------------------------------------------//

/* TODO: SPIO : MCP23S17 */ //{

// ports for SPIO //{

wire  EXT_SPx_MOSI;
wire  EXT_SPx_SCLK;
wire  EXT_SPx_MISO;
OBUF obuf__EXT_SPx_MOSI_inst (.O(o_B13_L2P         ), .I(EXT_SPx_MOSI ) ); // 
OBUF obuf__EXT_SPx_SCLK_inst (.O(o_B13_L2N         ), .I(EXT_SPx_SCLK ) ); // 
IBUF ibuf__EXT_SPx_MISO_inst (.I(i_B13_L4P         ), .O(EXT_SPx_MISO ) ); //
//
wire  EXT_SP0__CS_B; // map: S1_SPI_CSB0
wire  EXT_SP1__CS_B; // map: S1_SPI_CSB1
wire  EXT_SP2__CS_B; // map: S1_SPI_CSB2
wire  EXT_SP3__CS_B; // map: S2_SPI_CSB0
wire  EXT_SP4__CS_B; // map: S2_SPI_CSB1
wire  EXT_SP5__CS_B; // map: S2_SPI_CSB2
wire  EXT_SP6__CS_B; // map: S3_SPI_CSB0
wire  EXT_SP7__CS_B; // map: S3_SPI_CSB1
wire  EXT_SP8__CS_B; // map: S3_SPI_CSB2
wire  EXT_SP9__CS_B; // map: S4_SPI_CSB0
wire  EXT_SP10_CS_B; // map: S4_SPI_CSB1
wire  EXT_SP11_CS_B; // map: S4_SPI_CSB2
wire  EXT_SP12_CS_B; // map: S5_SPI_CSB0
wire  EXT_SP13_CS_B; // map: S5_SPI_CSB1
wire  EXT_SP14_CS_B; // map: S5_SPI_CSB2
wire  EXT_SP15_CS_B; // map: S6_SPI_CSB0
wire  EXT_SP16_CS_B; // map: S6_SPI_CSB1
wire  EXT_SP17_CS_B; // map: S6_SPI_CSB2
wire  EXT_SP18_CS_B; // map: S7_SPI_CSB0
wire  EXT_SP19_CS_B; // map: S7_SPI_CSB1
wire  EXT_SP20_CS_B; // map: S7_SPI_CSB2
wire  EXT_SP21_CS_B; // map: S8_SPI_CSB0
wire  EXT_SP22_CS_B; // map: S8_SPI_CSB1
wire  EXT_SP23_CS_B; // map: S8_SPI_CSB2
//
OBUF obuf__EXT_SP0__CS_B_inst   (.O(o_B13_L4N         ), .I(EXT_SP0__CS_B   ) ); // 
OBUF obuf__EXT_SP1__CS_B_inst   (.O(o_B13_L1P         ), .I(EXT_SP1__CS_B   ) ); // 
OBUF obuf__EXT_SP2__CS_B_inst   (.O(o_B13_L5N         ), .I(EXT_SP2__CS_B   ) ); // 
OBUF obuf__EXT_SP3__CS_B_inst   (.O(o_B13_L3P         ), .I(EXT_SP3__CS_B   ) ); // 
OBUF obuf__EXT_SP4__CS_B_inst   (.O(o_B13_L3N         ), .I(EXT_SP4__CS_B   ) ); // 
OBUF obuf__EXT_SP5__CS_B_inst   (.O(o_B13_L16P        ), .I(EXT_SP5__CS_B   ) ); // 
OBUF obuf__EXT_SP6__CS_B_inst   (.O(o_B13_L16N        ), .I(EXT_SP6__CS_B   ) ); // 
OBUF obuf__EXT_SP7__CS_B_inst   (.O(o_B13_L1N         ), .I(EXT_SP7__CS_B   ) ); // 
OBUF obuf__EXT_SP8__CS_B_inst   (.O(o_B35_L10P        ), .I(EXT_SP8__CS_B   ) ); // 
OBUF obuf__EXT_SP9__CS_B_inst   (.O(o_B35_L10N        ), .I(EXT_SP9__CS_B   ) ); // 
OBUF obuf__EXT_SP10_CS_B_inst   (.O(o_B35_L8P         ), .I(EXT_SP10_CS_B   ) ); // 
OBUF obuf__EXT_SP11_CS_B_inst   (.O(o_B35_L8N         ), .I(EXT_SP11_CS_B   ) ); // 
OBUF obuf__EXT_SP12_CS_B_inst   (.O(o_B35_L5P         ), .I(EXT_SP12_CS_B   ) ); // 
OBUF obuf__EXT_SP13_CS_B_inst   (.O(o_B35_L5N         ), .I(EXT_SP13_CS_B   ) ); // 
OBUF obuf__EXT_SP14_CS_B_inst   (.O(o_B35_L12P_MRCC   ), .I(EXT_SP14_CS_B   ) ); // 
OBUF obuf__EXT_SP15_CS_B_inst   (.O(o_B35_L12N_MRCC   ), .I(EXT_SP15_CS_B   ) ); // 
OBUF obuf__EXT_SP16_CS_B_inst   (.O(o_B35_L4P         ), .I(EXT_SP16_CS_B   ) ); // 
OBUF obuf__EXT_SP17_CS_B_inst   (.O(o_B35_L4N         ), .I(EXT_SP17_CS_B   ) ); // 
OBUF obuf__EXT_SP18_CS_B_inst   (.O(o_B35_L6P         ), .I(EXT_SP18_CS_B   ) ); // 
OBUF obuf__EXT_SP19_CS_B_inst   (.O(o_B35_L6N         ), .I(EXT_SP19_CS_B   ) ); // 
OBUF obuf__EXT_SP20_CS_B_inst   (.O(o_B35_L1P         ), .I(EXT_SP20_CS_B   ) ); // 
OBUF obuf__EXT_SP21_CS_B_inst   (.O(o_B35_L1N         ), .I(EXT_SP21_CS_B   ) ); // 
OBUF obuf__EXT_SP22_CS_B_inst   (.O(o_B35_L13P_MRCC   ), .I(EXT_SP22_CS_B   ) ); // 
OBUF obuf__EXT_SP23_CS_B_inst   (.O(o_B35_L13N_MRCC   ), .I(EXT_SP23_CS_B   ) ); // 

//}
  
// module //{
wire [ 1:0] spio_trig_ti_ext;
wire [31:0] spio_con_wi_ext;
wire [31:0] spio_fdat_wi_ext;

wire w_spio_trig_cowork__ext; // cowork trig from EXT_TRIG

// enable logic table:
//  w_SPIO_en, w_SPIO_CON_WI[0], w_SPIO_TRIG_TI[0], spio_con_wi_ext[0],  spio_trig_ti_ext[0]
//          0,                0,                 0,                  X,                    X // disable
//          1,                1,                 0,                  X,                    X // enable
//          1,                0,                 1,                  X,                    X // enable
//          1,                1,                 1,                  X,                    X // enable
//          0,                1,                 X,                  1,                    X // reset trig
//          0,                X,                 1,                  X,                    1 // reset trig
wire w_SPIO_en  = 
	(  w_SPIO_CON_WI[0]   | spio_con_wi_ext[0]  ) & 
	(~(w_SPIO_CON_WI[0]   & w_SPIO_TRIG_TI[0]  )) & 
	(~(spio_con_wi_ext[0] & spio_trig_ti_ext[0])) ; //

//
wire w_trig_SPIO_SPI_frame   = w_SPIO_TRIG_TI[1] | spio_trig_ti_ext[1] | w_spio_trig_cowork__ext; 
wire w_done_SPIO_SPI_frame;
wire w_done_SPIO_SPI_frame_TO;
wire w_busy_SPI_frame;
//
wire [7:0] w_SPIO_socket_en  = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[31:24]  : spio_con_wi_ext[31:24]  ;
wire [2:0] w_SPIO_CS_en      = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[18:16]  : spio_con_wi_ext[18:16]  ;
//
wire [2:0] w_SPIO_pin_adrs_A = (w_SPIO_CON_WI[0])? w_SPIO_FDAT_WI[27:25] : spio_fdat_wi_ext[27:25] ;
wire       w_SPIO_R_W_bar    = (w_SPIO_CON_WI[0])? w_SPIO_FDAT_WI[24]    : spio_fdat_wi_ext[24]    ;
wire [7:0] w_SPIO_reg_adrs_A = (w_SPIO_CON_WI[0])? w_SPIO_FDAT_WI[23:16] : spio_fdat_wi_ext[23:16] ;
wire [7:0] w_SPIO_wr_DA      = (w_SPIO_CON_WI[0])? w_SPIO_FDAT_WI[15: 8] : spio_fdat_wi_ext[15: 8] ;
wire [7:0] w_SPIO_wr_DB      = (w_SPIO_CON_WI[0])? w_SPIO_FDAT_WI[ 7: 0] : spio_fdat_wi_ext[ 7: 0] ;
//
wire [7:0] w_SPIO_rd_DA;
wire [7:0] w_SPIO_rd_DB;
//
wire       w_forced_pin_mode_en = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[ 8]  : spio_con_wi_ext[ 8] ;
wire       w_forced_sig_mosi    = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[ 9]  : spio_con_wi_ext[ 9] ;
wire       w_forced_sig_sclk    = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[10]  : spio_con_wi_ext[10] ;
wire       w_forced_sig_csel    = (w_SPIO_CON_WI[0])? w_SPIO_CON_WI[11]  : spio_con_wi_ext[11] ;

//
(* keep = "true" *) wire [2:0] w_S1_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S2_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S3_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S4_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S5_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S6_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S7_SPI_CSB;
(* keep = "true" *) wire [2:0] w_S8_SPI_CSB;
//
(* keep = "true" *) wire w_SPIOx_SCLK;
(* keep = "true" *) wire w_SPIOx_MOSI;
(* keep = "true" *) wire w_SPIOx_MISO = EXT_SPx_MISO;

wire [15:0] w_cnt_spio_trig_frame;

//
master_spi_mcp23s17__s8_cs3  master_spi_mcp23s17_inst (
	.clk				(sys_clk), // 10MHz (or 1MHz if failed...)
	.reset_n			(reset_n & w_SPIO_en & (~w_HW_reset)),
	//
	// trig control
	.i_trig_SPI_frame	    (w_trig_SPIO_SPI_frame), 
	.o_done_SPI_frame	    (w_done_SPIO_SPI_frame), 
	.o_done_SPI_frame_TO    (w_done_SPIO_SPI_frame_TO), 
	.o_busy_SPI_frame       (w_busy_SPI_frame     ),
	.o_cnt_spio_trig_frame  (w_cnt_spio_trig_frame), // [15:0] // $$
	
	// IO ports
	.o_S1_SPI_CSB   	(w_S1_SPI_CSB), // [2:0]
	.o_S2_SPI_CSB   	(w_S2_SPI_CSB), // [2:0]
	.o_S3_SPI_CSB   	(w_S3_SPI_CSB), // [2:0]
	.o_S4_SPI_CSB   	(w_S4_SPI_CSB), // [2:0]
	.o_S5_SPI_CSB   	(w_S5_SPI_CSB), // [2:0]
	.o_S6_SPI_CSB   	(w_S6_SPI_CSB), // [2:0]
	.o_S7_SPI_CSB   	(w_S7_SPI_CSB), // [2:0]
	.o_S8_SPI_CSB   	(w_S8_SPI_CSB), // [2:0]
	//
	.o_SPIOx_SCLK 		(w_SPIOx_SCLK), // EXT_SPx_SCLK
	.o_SPIOx_MOSI 		(w_SPIOx_MOSI), // EXT_SPx_MOSI 
	.i_SPIOx_MISO 		(w_SPIOx_MISO), // EXT_SPx_MISO
	
	// CS selection
	.i_socket_en        (w_SPIO_socket_en ), // socket_enable [7:0]
	.i_CS_en            (w_SPIO_CS_en     ), // frame_cs_enable [2:0]
	
	// forced pin mode :
	//   forced pin mode en
	//   EXT_SPx_MOSI_forced_sig
	//   EXT_SPx_SCLK_forced_sig
	.i_forced_pin_mode_en  (w_forced_pin_mode_en), //
	.i_forced_sig_mosi     (w_forced_sig_mosi   ), //
	.i_forced_sig_sclk     (w_forced_sig_sclk   ), //
	.i_forced_sig_csel     (w_forced_sig_csel   ), //
	
	// frame data
	.i_pin_adrs_A       (w_SPIO_pin_adrs_A), // [2:0] 
	.i_R_W_bar          (w_SPIO_R_W_bar   ), //       
	.i_reg_adrs_A       (w_SPIO_reg_adrs_A), // [7:0] 
	.i_wr_DA            (w_SPIO_wr_DA     ), // [7:0] 
	.i_wr_DB            (w_SPIO_wr_DB     ), // [7:0] 
	.o_rd_DA            (w_SPIO_rd_DA     ), // [7:0] 
	.o_rd_DB            (w_SPIO_rd_DB     ), // [7:0] 
	//
	.valid				()
);
//// note on test
// LED test with CHECK_LED0 net (CS0_GPB7)
//   socket/ch enable          : w_SPIO_CON_WI  = 32'h01_01_00_01
//   IODIR frame 0x40_00_FF_7F : w_SPIO_FDAT_WI = 32'h00_00_FF_7F
//   GPIO  frame 0x40_12_00_80 : w_SPIO_FDAT_WI = 32'h00_12_00_80
//   GPIO  frame 0x40_12_00_00 : w_SPIO_FDAT_WI = 32'h00_12_00_00
// LED test with CHECK_LED1 net (CS1_GPB7)
//   socket/ch enable          : w_SPIO_CON_WI  = 32'h01_02_00_01
//   IODIR frame 0x40_00_FF_7F : w_SPIO_FDAT_WI = 32'h00_00_FF_7F
//   IODIR frame 0x41_00_XX_XX : w_SPIO_FDAT_WI = 32'h01_00_XX_XX // read NG // suspect no pullup on board circuit.
//   GPIO  frame 0x40_12_00_80 : w_SPIO_FDAT_WI = 32'h00_12_00_80
//   GPIO  frame 0x40_12_00_00 : w_SPIO_FDAT_WI = 32'h00_12_00_00

//}

// assignments //{
// chip/slave selection
assign EXT_SP0__CS_B = w_S1_SPI_CSB[0]; // map: S1_SPI_CSB0
assign EXT_SP1__CS_B = w_S1_SPI_CSB[1]; // map: S1_SPI_CSB1
assign EXT_SP2__CS_B = w_S1_SPI_CSB[2]; // map: S1_SPI_CSB2
assign EXT_SP3__CS_B = w_S2_SPI_CSB[0]; // map: S2_SPI_CSB0
assign EXT_SP4__CS_B = w_S2_SPI_CSB[1]; // map: S2_SPI_CSB1
assign EXT_SP5__CS_B = w_S2_SPI_CSB[2]; // map: S2_SPI_CSB2
assign EXT_SP6__CS_B = w_S3_SPI_CSB[0]; // map: S3_SPI_CSB0
assign EXT_SP7__CS_B = w_S3_SPI_CSB[1]; // map: S3_SPI_CSB1
assign EXT_SP8__CS_B = w_S3_SPI_CSB[2]; // map: S3_SPI_CSB2
assign EXT_SP9__CS_B = w_S4_SPI_CSB[0]; // map: S4_SPI_CSB0
assign EXT_SP10_CS_B = w_S4_SPI_CSB[1]; // map: S4_SPI_CSB1
assign EXT_SP11_CS_B = w_S4_SPI_CSB[2]; // map: S4_SPI_CSB2
assign EXT_SP12_CS_B = w_S5_SPI_CSB[0]; // map: S5_SPI_CSB0
assign EXT_SP13_CS_B = w_S5_SPI_CSB[1]; // map: S5_SPI_CSB1
assign EXT_SP14_CS_B = w_S5_SPI_CSB[2]; // map: S5_SPI_CSB2
assign EXT_SP15_CS_B = w_S6_SPI_CSB[0]; // map: S6_SPI_CSB0
assign EXT_SP16_CS_B = w_S6_SPI_CSB[1]; // map: S6_SPI_CSB1
assign EXT_SP17_CS_B = w_S6_SPI_CSB[2]; // map: S6_SPI_CSB2
assign EXT_SP18_CS_B = w_S7_SPI_CSB[0]; // map: S7_SPI_CSB0
assign EXT_SP19_CS_B = w_S7_SPI_CSB[1]; // map: S7_SPI_CSB1
assign EXT_SP20_CS_B = w_S7_SPI_CSB[2]; // map: S7_SPI_CSB2
assign EXT_SP21_CS_B = w_S8_SPI_CSB[0]; // map: S8_SPI_CSB0
assign EXT_SP22_CS_B = w_S8_SPI_CSB[1]; // map: S8_SPI_CSB1
assign EXT_SP23_CS_B = w_S8_SPI_CSB[2]; // map: S8_SPI_CSB2
// spi pin output
assign EXT_SPx_SCLK = w_SPIOx_SCLK;
assign EXT_SPx_MOSI = w_SPIOx_MOSI;
// frame data output
assign w_SPIO_FLAG_WO[31:27] = 5'b0;
assign w_SPIO_FLAG_WO[26:25]    = {w_busy_SPI_frame,w_done_SPIO_SPI_frame};
assign w_SPIO_FLAG_WO[24:16] = 9'b0;
assign w_SPIO_FLAG_WO[15:8]  = w_SPIO_rd_DA;
assign w_SPIO_FLAG_WO[ 7:0]  = w_SPIO_rd_DB;
// trig done output
assign w_SPIO_TRIG_TO[31:2]  = 30'b0;
assign w_SPIO_TRIG_TO[1]     = w_done_SPIO_SPI_frame_TO;
assign w_SPIO_TRIG_TO[0]     = 1'b0;
//}

//}


/* TODO: DAC : AD5754BREZ */ //{
// generate 24-bit frame data for AD5754 SPI bus
// support quad AD5754
// support common control with DACx_LOAC_B

// ports for DAC //{
wire  DACx_LOAC_B; 
OBUF obuf__DACx_LOAC_B_inst (.O(o_B13_SYS_CLK_MC2  ), .I(DACx_LOAC_B ) ); // 
//
wire  DAC0_SYNC_B;
wire  DAC0_MOSI  ;
wire  DAC0_SCK   ;
wire  DAC0_MISO  ;
OBUF obuf__DAC0_SYN_inst (.O(o_B34_L6N         ), .I(DAC0_SYNC_B ) ); // 
OBUF obuf__DAC0_MOS_inst (.O(o_B34_L22N        ), .I(DAC0_MOSI   ) ); // 
OBUF obuf__DAC0_SCK_inst (.O(o_B34_L22P        ), .I(DAC0_SCK    ) ); // 
IBUF ibuf__DAC0_MIS_inst (.I(i_B34_L6P         ), .O(DAC0_MISO   ) ); //
//
wire  DAC1_SYNC_B;
wire  DAC1_MOSI  ;
wire  DAC1_SCK   ;
wire  DAC1_MISO  ;
OBUF obuf__DAC1_SYN_inst (.O(o_B34_L18N        ), .I(DAC1_SYNC_B ) ); // 
OBUF obuf__DAC1_MOS_inst (.O(o_B34_L11N_SRCC   ), .I(DAC1_MOSI   ) ); // 
OBUF obuf__DAC1_SCK_inst (.O(o_B34_L11P_SRCC   ), .I(DAC1_SCK    ) ); // 
IBUF ibuf__DAC1_MIS_inst (.I(i_B34_L18P        ), .O(DAC1_MISO   ) ); //
//
wire  DAC2_SYNC_B;
wire  DAC2_MOSI  ;
wire  DAC2_SCK   ;
wire  DAC2_MISO  ;
OBUF obuf__DAC2_SYN_inst (.O(o_B35_L19N         ), .I(DAC2_SYNC_B ) ); // 
OBUF obuf__DAC2_MOS_inst (.O(o_B35_L21N         ), .I(DAC2_MOSI   ) ); // 
OBUF obuf__DAC2_SCK_inst (.O(o_B35_L21P         ), .I(DAC2_SCK    ) ); // 
IBUF ibuf__DAC2_MIS_inst (.I(i_B35_L19P         ), .O(DAC2_MISO   ) ); //
//
wire  DAC3_SYNC_B; 
wire  DAC3_MOSI  ; 
wire  DAC3_SCK   ; 
wire  DAC3_MISO  ;
OBUF obuf__DAC3_SYN_inst (.O(o_B35_IO0          ), .I(DAC3_SYNC_B ) ); // 
OBUF obuf__DAC3_MOS_inst (.O(o_B35_L24P         ), .I(DAC3_MOSI   ) ); // 
OBUF obuf__DAC3_SCK_inst (.O(o_B35_IO25         ), .I(DAC3_SCK    ) ); // 
IBUF ibuf__DAC3_MIS_inst (.I(i_B35_L24N         ), .O(DAC3_MISO   ) ); //
//}

// module for DAC //{
wire [4:0] dac_trig_ti_ext;
wire [31:0] dac_con_wi_ext;
wire [31:0] dac_s1_wi_ext;
wire [31:0] dac_s2_wi_ext;
wire [31:0] dac_s3_wi_ext;
wire [31:0] dac_s4_wi_ext;
wire [31:0] dac_s5_wi_ext;
wire [31:0] dac_s6_wi_ext;
wire [31:0] dac_s7_wi_ext;
wire [31:0] dac_s8_wi_ext;
//
wire w_dac_trig_cowork__ext; // from EXT_TRIG

// enable logic table:
//   w_DAC_en,  w_DAC_CON_WI[0], w_DAC_TRIG_TI[0], dac_con_wi_ext[0],  dac_trig_ti_ext[0]
//          0,                0,                0,                 X,                   X // disable
//          1,                1,                0,                 X,                   X // enable
//          1,                0,                1,                 X,                   X // enable
//          1,                1,                1,                 X,                   X // enable
//          0,                1,                X,                 1,                   X // reset trig
//          0,                X,                1,                 X,                   1 // reset trig
wire w_DAC_en  = 
	(  w_DAC_CON_WI[0]   | dac_con_wi_ext[0]  ) & 
	(~(w_DAC_CON_WI[0]   & w_DAC_TRIG_TI[0]  )) & 
	(~(dac_con_wi_ext[0] & dac_trig_ti_ext[0])) ; //

(* keep = "true" *) wire w_trig_DAC_SPI_frame     = w_DAC_TRIG_TI[1] | dac_trig_ti_ext[1];
(* keep = "true" *) wire w_done_DAC_SPI_frame   ; 
(* keep = "true" *) wire w_done_DAC_SPI_frame_TO; 
(* keep = "true" *) wire w_trig_DAC_init          = w_DAC_TRIG_TI[2] | dac_trig_ti_ext[2];
(* keep = "true" *) wire w_done_DAC_init        ;
(* keep = "true" *) wire w_done_DAC_init_TO     ;
(* keep = "true" *) wire w_trig_DAC_update        = w_DAC_TRIG_TI[3] | dac_trig_ti_ext[3] | w_dac_trig_cowork__ext;
(* keep = "true" *) wire w_done_DAC_update      ;
(* keep = "true" *) wire w_done_DAC_update_TO   ;
(* keep = "true" *) wire w_busy_DAC_update      ;
//
(* keep = "true" *) wire [3:0] w_DAC_SCLK ;
(* keep = "true" *) wire [3:0] w_DAC_SYNB ;
(* keep = "true" *) wire [3:0] w_DAC_MOSI ;
(* keep = "true" *) wire [3:0] w_DAC_MISO = {DAC3_MISO, DAC2_MISO, DAC1_MISO, DAC0_MISO};
//
wire w_load_packet_en       = (w_DAC_CON_WI[0])? w_DAC_CON_WI[1] : dac_con_wi_ext[1] ; // reserved
wire w_load_pin_ext_sig_en  = (w_DAC_CON_WI[0])? w_DAC_CON_WI[2] : dac_con_wi_ext[2] ;
//
wire w_load_pin_ext_sig       = w_DAC_TRIG_TI[4] | dac_trig_ti_ext[4]; // must be min 20ns // 10MHz ... 100ns 
//
wire w_power_up_delay_disable = (w_DAC_CON_WI[0])? w_DAC_CON_WI[1]    : dac_con_wi_ext[1]  ;
wire [3:0] w_DAC_sel          = (w_DAC_CON_WI[0])? w_DAC_CON_WI[7:4]  : dac_con_wi_ext[7:4]  ;
//
wire [23:0] w_test_sdi_pdata = (w_DAC_CON_WI[0])? w_DAC_CON_WI[31:8] : dac_con_wi_ext[31:8] ;
wire [23:0] w_test_sdo_pdata ;

// DAC output mapping //{
//   * order
//	 DAC0
//   S1_CH2 = VOUTA
//   S1_CH1 = VOUTB
//   S2_CH1 = VOUTC
//   S2_CH2 = VOUTD
//	 DAC1
//   S3_CH2 = VOUTA
//   S3_CH1 = VOUTB
//   S4_CH1 = VOUTC
//   S4_CH2 = VOUTD
//	 DAC2
//   S5_CH2 = VOUTA
//   S5_CH1 = VOUTB
//   S6_CH1 = VOUTC
//   S6_CH2 = VOUTD
//	 DAC3
//   S7_CH2 = VOUTA
//   S7_CH1 = VOUTB
//   S8_CH1 = VOUTC
//   S8_CH2 = VOUTD
//
//                                                                            //	 DAC0
wire [15:0] w_DAC0_A_val = (w_DAC_CON_WI[0])? w_DAC_S1_WI[31:16] : dac_s1_wi_ext[31:16] ; //   S1_CH2 = VOUTA
wire [15:0] w_DAC0_B_val = (w_DAC_CON_WI[0])? w_DAC_S1_WI[15:0 ] : dac_s1_wi_ext[15:0 ] ; //   S1_CH1 = VOUTB
wire [15:0] w_DAC0_C_val = (w_DAC_CON_WI[0])? w_DAC_S2_WI[15:0 ] : dac_s2_wi_ext[15:0 ] ; //   S2_CH1 = VOUTC
wire [15:0] w_DAC0_D_val = (w_DAC_CON_WI[0])? w_DAC_S2_WI[31:16] : dac_s2_wi_ext[31:16] ; //   S2_CH2 = VOUTD
//                                                                            //	 DAC1
wire [15:0] w_DAC1_A_val = (w_DAC_CON_WI[0])? w_DAC_S3_WI[31:16] : dac_s3_wi_ext[31:16] ; //   S3_CH2 = VOUTA
wire [15:0] w_DAC1_B_val = (w_DAC_CON_WI[0])? w_DAC_S3_WI[15:0 ] : dac_s3_wi_ext[15:0 ] ; //   S3_CH1 = VOUTB
wire [15:0] w_DAC1_C_val = (w_DAC_CON_WI[0])? w_DAC_S4_WI[15:0 ] : dac_s4_wi_ext[15:0 ] ; //   S4_CH1 = VOUTC
wire [15:0] w_DAC1_D_val = (w_DAC_CON_WI[0])? w_DAC_S4_WI[31:16] : dac_s4_wi_ext[31:16] ; //   S4_CH2 = VOUTD
//                                                                            //	 DAC2
wire [15:0] w_DAC2_A_val = (w_DAC_CON_WI[0])? w_DAC_S5_WI[31:16] : dac_s5_wi_ext[31:16] ; //   S5_CH2 = VOUTA
wire [15:0] w_DAC2_B_val = (w_DAC_CON_WI[0])? w_DAC_S5_WI[15:0 ] : dac_s5_wi_ext[15:0 ] ; //   S5_CH1 = VOUTB
wire [15:0] w_DAC2_C_val = (w_DAC_CON_WI[0])? w_DAC_S6_WI[15:0 ] : dac_s6_wi_ext[15:0 ] ; //   S6_CH1 = VOUTC
wire [15:0] w_DAC2_D_val = (w_DAC_CON_WI[0])? w_DAC_S6_WI[31:16] : dac_s6_wi_ext[31:16] ; //   S6_CH2 = VOUTD
//                                                                            //	 DAC3
wire [15:0] w_DAC3_A_val = (w_DAC_CON_WI[0])? w_DAC_S7_WI[31:16] : dac_s7_wi_ext[31:16] ; //   S7_CH2 = VOUTA
wire [15:0] w_DAC3_B_val = (w_DAC_CON_WI[0])? w_DAC_S7_WI[15:0 ] : dac_s7_wi_ext[15:0 ] ; //   S7_CH1 = VOUTB
wire [15:0] w_DAC3_C_val = (w_DAC_CON_WI[0])? w_DAC_S8_WI[15:0 ] : dac_s8_wi_ext[15:0 ] ; //   S8_CH1 = VOUTC
wire [15:0] w_DAC3_D_val = (w_DAC_CON_WI[0])? w_DAC_S8_WI[31:16] : dac_s8_wi_ext[31:16] ; //   S8_CH2 = VOUTD
//
wire [15:0] w_DAC0_A_rbk ; 
wire [15:0] w_DAC0_B_rbk ; 
wire [15:0] w_DAC0_C_rbk ; 
wire [15:0] w_DAC0_D_rbk ; 
wire [15:0] w_DAC1_A_rbk ; 
wire [15:0] w_DAC1_B_rbk ; 
wire [15:0] w_DAC1_C_rbk ; 
wire [15:0] w_DAC1_D_rbk ; 
wire [15:0] w_DAC2_A_rbk ; 
wire [15:0] w_DAC2_B_rbk ; 
wire [15:0] w_DAC2_C_rbk ; 
wire [15:0] w_DAC2_D_rbk ; 
wire [15:0] w_DAC3_A_rbk ; 
wire [15:0] w_DAC3_B_rbk ; 
wire [15:0] w_DAC3_C_rbk ; 
wire [15:0] w_DAC3_D_rbk ; 

//}

wire [15:0] w_cnt_dac_trig;

//
master_spi_dac_AD5754__quad_d10v  master_spi_dac_AD5754_inst ( 
	.clk		(sys_clk), // assume 10MHz or 100ns
	.reset_n	(reset_n & w_DAC_en & (~w_HW_reset)), 
	
	// trig control
	.i_trig_SPI_frame		(w_trig_DAC_SPI_frame   ), 
	.o_done_SPI_frame		(w_done_DAC_SPI_frame   ), 
	.o_done_SPI_frame_TO	(w_done_DAC_SPI_frame_TO),
	
	.i_trig_DAC_init    	(w_trig_DAC_init        ), 
	.o_done_DAC_init    	(w_done_DAC_init        ), 
	.o_done_DAC_init_TO  	(w_done_DAC_init_TO     ), 
	
	.i_trig_DAC_update  	(w_trig_DAC_update      ), 
	.o_done_DAC_update  	(w_done_DAC_update      ), 
	.o_done_DAC_update_TO	(w_done_DAC_update_TO   ), 

	.o_busy_DAC_update      (w_busy_DAC_update      ), 
	
	.i_power_up_delay_disable (w_power_up_delay_disable),
	
	.o_cnt_dac_trig      	(w_cnt_dac_trig	), // [15:0] //$$ w_cnt_dac_trig

	// DAC load control
	.i_load_packet_en         	(w_load_packet_en        ), // load packet enable
	.i_load_pin_ext_sig_en    	(w_load_pin_ext_sig_en   ), // load pin control by external signal 
	.i_load_pin_ext_sig    	  	(w_load_pin_ext_sig      ), // external signal for load pin
	
	// DAC selection
	.i_DAC_sel   			 	(w_DAC_sel               ), // [3:0] // i_DAC_sel[3:0] for DAC3,DAC2,DAC1,DAC0
	
	// test frame 24-bit
	.i_test_sdi_pdata	(w_test_sdi_pdata), // input // [23:0]
	.o_test_sdo_pdata	(w_test_sdo_pdata), // out   // [23:0]

	// DAC data in/out //{
	.i_DAC0_A_val	(w_DAC0_A_val  ), // [15:0] // DAC value in
	.i_DAC0_B_val	(w_DAC0_B_val  ), // [15:0] // DAC value in
	.i_DAC0_C_val	(w_DAC0_C_val  ), // [15:0] // DAC value in
	.i_DAC0_D_val	(w_DAC0_D_val  ), // [15:0] // DAC value in
	//                    
	.i_DAC1_A_val	(w_DAC1_A_val  ), // [15:0] // DAC value in
	.i_DAC1_B_val	(w_DAC1_B_val  ), // [15:0] // DAC value in
	.i_DAC1_C_val	(w_DAC1_C_val  ), // [15:0] // DAC value in
	.i_DAC1_D_val	(w_DAC1_D_val  ), // [15:0] // DAC value in
	//                    
	.i_DAC2_A_val	(w_DAC2_A_val  ), // [15:0] // DAC value in
	.i_DAC2_B_val	(w_DAC2_B_val  ), // [15:0] // DAC value in
	.i_DAC2_C_val	(w_DAC2_C_val  ), // [15:0] // DAC value in
	.i_DAC2_D_val	(w_DAC2_D_val  ), // [15:0] // DAC value in
	//                    
	.i_DAC3_A_val	(w_DAC3_A_val  ), // [15:0] // DAC value in
	.i_DAC3_B_val	(w_DAC3_B_val  ), // [15:0] // DAC value in
	.i_DAC3_C_val	(w_DAC3_C_val  ), // [15:0] // DAC value in
	.i_DAC3_D_val	(w_DAC3_D_val  ), // [15:0] // DAC value in
	//
	.o_DAC0_A_rbk	(w_DAC0_A_rbk  ), // [15:0]  // DAC readback out
	.o_DAC0_B_rbk	(w_DAC0_B_rbk  ), // [15:0]  // DAC readback out
	.o_DAC0_C_rbk	(w_DAC0_C_rbk  ), // [15:0]  // DAC readback out
	.o_DAC0_D_rbk	(w_DAC0_D_rbk  ), // [15:0]  // DAC readback out
	//                    
	.o_DAC1_A_rbk	(w_DAC1_A_rbk  ), // [15:0]  // DAC readback out
	.o_DAC1_B_rbk	(w_DAC1_B_rbk  ), // [15:0]  // DAC readback out
	.o_DAC1_C_rbk	(w_DAC1_C_rbk  ), // [15:0]  // DAC readback out
	.o_DAC1_D_rbk	(w_DAC1_D_rbk  ), // [15:0]  // DAC readback out
	//                    
	.o_DAC2_A_rbk	(w_DAC2_A_rbk  ), // [15:0]  // DAC readback out
	.o_DAC2_B_rbk	(w_DAC2_B_rbk  ), // [15:0]  // DAC readback out
	.o_DAC2_C_rbk	(w_DAC2_C_rbk  ), // [15:0]  // DAC readback out
	.o_DAC2_D_rbk	(w_DAC2_D_rbk  ), // [15:0]  // DAC readback out
	//                    
	.o_DAC3_A_rbk	(w_DAC3_A_rbk  ), // [15:0]  // DAC readback out
	.o_DAC3_B_rbk	(w_DAC3_B_rbk  ), // [15:0]  // DAC readback out
	.o_DAC3_C_rbk	(w_DAC3_C_rbk  ), // [15:0]  // DAC readback out
	.o_DAC3_D_rbk	(w_DAC3_D_rbk  ), // [15:0]  // DAC readback out
	//}
	
	// DAC control pins // quad
	.o_SCLK			(w_DAC_SCLK	), // [3:0]
	.o_SYNC_N		(w_DAC_SYNB	), // [3:0]
	.o_DIN			(w_DAC_MOSI	), // [3:0]
	.i_SDO			(w_DAC_MISO	), // [3:0]
	
	// IO
	.o_LOAD_DAC_N	(DACx_LOAC_B	), // ext pin

	//
	.valid				()
);

//}

// assignments //{
assign DAC0_SYNC_B = w_DAC_SYNB[0];
assign DAC0_MOSI   = w_DAC_MOSI[0];
assign DAC0_SCK    = w_DAC_SCLK[0];
//
assign DAC1_SYNC_B = w_DAC_SYNB[1];
assign DAC1_MOSI   = w_DAC_MOSI[1];
assign DAC1_SCK    = w_DAC_SCLK[1];
//
assign DAC2_SYNC_B = w_DAC_SYNB[2];
assign DAC2_MOSI   = w_DAC_MOSI[2];
assign DAC2_SCK    = w_DAC_SCLK[2];
//
assign DAC3_SYNC_B = w_DAC_SYNB[3];
assign DAC3_MOSI   = w_DAC_MOSI[3];
assign DAC3_SCK    = w_DAC_SCLK[3];
//
assign w_DAC_FLAG_WO[31:8] = w_test_sdo_pdata; // 24 bits
assign w_DAC_FLAG_WO[7]    = w_busy_DAC_update;
assign w_DAC_FLAG_WO[6:4]  = 3'b0;
assign w_DAC_FLAG_WO[3]    = w_done_DAC_update;
assign w_DAC_FLAG_WO[2]    = w_done_DAC_init;
assign w_DAC_FLAG_WO[1]    = w_done_DAC_SPI_frame;
assign w_DAC_FLAG_WO[0]    = w_DAC_en; //$$ w_DAC_en 
//
assign w_DAC_TRIG_TO[31:4] = 28'b0;
assign w_DAC_TRIG_TO[3]    = w_done_DAC_update_TO;
assign w_DAC_TRIG_TO[2]    = w_done_DAC_init_TO;
assign w_DAC_TRIG_TO[1]    = w_done_DAC_SPI_frame_TO;
assign w_DAC_TRIG_TO[0]    = w_DAC_en; //$$ w_DAC_en 

//             
assign w_DAC_S1_WO[31:16]  =  w_DAC0_A_rbk ; 
assign w_DAC_S1_WO[15:0 ]  =  w_DAC0_B_rbk ; 
assign w_DAC_S2_WO[15:0 ]  =  w_DAC0_C_rbk ; 
assign w_DAC_S2_WO[31:16]  =  w_DAC0_D_rbk ; 
                        
assign w_DAC_S3_WO[31:16]  =  w_DAC1_A_rbk ; 
assign w_DAC_S3_WO[15:0 ]  =  w_DAC1_B_rbk ; 
assign w_DAC_S4_WO[15:0 ]  =  w_DAC1_C_rbk ; 
assign w_DAC_S4_WO[31:16]  =  w_DAC1_D_rbk ; 
                        
assign w_DAC_S5_WO[31:16]  =  w_DAC2_A_rbk ; 
assign w_DAC_S5_WO[15:0 ]  =  w_DAC2_B_rbk ; 
assign w_DAC_S6_WO[15:0 ]  =  w_DAC2_C_rbk ; 
assign w_DAC_S6_WO[31:16]  =  w_DAC2_D_rbk ; 
                        
assign w_DAC_S7_WO[31:16]  =  w_DAC3_A_rbk ; 
assign w_DAC_S7_WO[15:0 ]  =  w_DAC3_B_rbk ; 
assign w_DAC_S8_WO[15:0 ]  =  w_DAC3_C_rbk ; 
assign w_DAC_S8_WO[31:16]  =  w_DAC3_D_rbk ; 

//}

//}


/* TODO: ADC : LTC2325IUKG-16 */ //{

// ports for ADC //{

//# MC1-19  # ADCx_CNV_P       set_property PACKAGE_PIN R6   [get_ports o_B34D_L17P      ]  
//# MC1-21  # ADCx_CNV_N       set_property PACKAGE_PIN T6   [get_ports o_B34D_L17N      ]  
wire  ADCx_CNV ;
OBUFDS obufds__ADCx_CNV_inst (.O(o_B34D_L17P), .OB(o_B34D_L17N), .I(ADCx_CNV)	);
//# MC1-23  # ADCx_SCK_P       set_property PACKAGE_PIN U6   [get_ports o_B34D_L16P      ]  
//# MC1-25  # ADCx_SCK_N       set_property PACKAGE_PIN V5   [get_ports o_B34D_L16N      ]  
wire  ADCx_SCK ;
OBUFDS obufds__ADCx_SCK_inst (.O(o_B34D_L16P), .OB(o_B34D_L16N), .I(ADCx_SCK)	);

//# MC1-16  # ADC0_SDOD_N   set_property PACKAGE_PIN V9   [get_ports i_B34D_L21P         ]  
//# MC1-18  # ADC0_SDOD_P   set_property PACKAGE_PIN V8   [get_ports i_B34D_L21N         ]  
//# MC1-20  # ADC0_SDOC_N   set_property PACKAGE_PIN V7   [get_ports i_B34D_L19P         ]  
//# MC1-22  # ADC0_SDOC_P   set_property PACKAGE_PIN W7   [get_ports i_B34D_L19N         ]  
//# MC1-24  # ADC0_SDOB_N   set_property PACKAGE_PIN Y8   [get_ports i_B34D_L23P         ]  
//# MC1-26  # ADC0_SDOB_P   set_property PACKAGE_PIN Y7   [get_ports i_B34D_L23N         ]  
//# MC1-28  # ADC0_SDOA_N   set_property PACKAGE_PIN W6   [get_ports i_B34D_L15P         ]  
//# MC1-30  # ADC0_SDOA_P   set_property PACKAGE_PIN W5   [get_ports i_B34D_L15N         ]  
//# MC1-32  # ADC0_DCO_N    set_property PACKAGE_PIN R4   [get_ports c_B34D_L13P_MRCC    ]  
//# MC1-34  # ADC0_DCO_P    set_property PACKAGE_PIN T4   [get_ports c_B34D_L13N_MRCC    ]  
wire  ADC0_SDOD_B;  wire  ADC0_SDOD = ~ADC0_SDOD_B;
wire  ADC0_SDOC_B;  wire  ADC0_SDOC = ~ADC0_SDOC_B;
wire  ADC0_SDOB_B;  wire  ADC0_SDOB = ~ADC0_SDOB_B;
wire  ADC0_SDOA_B;  wire  ADC0_SDOA = ~ADC0_SDOA_B;
wire  ADC0_DCO__B;  wire  ADC0_DCO_ = ~ADC0_DCO__B;
IBUFDS ibufds__ADC0_SDOD_inst (.I(i_B34D_L21P     ), .IB(i_B34D_L21N     ), .O(ADC0_SDOD_B) );
IBUFDS ibufds__ADC0_SDOC_inst (.I(i_B34D_L19P     ), .IB(i_B34D_L19N     ), .O(ADC0_SDOC_B) );
IBUFDS ibufds__ADC0_SDOB_inst (.I(i_B34D_L23P     ), .IB(i_B34D_L23N     ), .O(ADC0_SDOB_B) );
IBUFDS ibufds__ADC0_SDOA_inst (.I(i_B34D_L15P     ), .IB(i_B34D_L15N     ), .O(ADC0_SDOA_B) );
IBUFDS ibufds__ADC0_DCO__inst (.I(c_B34D_L13P_MRCC), .IB(c_B34D_L13N_MRCC), .O(ADC0_DCO__B) );

//# MC1-27  # ADC1_DCO_P       set_property PACKAGE_PIN T5   [get_ports c_B34D_L14P_SRCC ]  
//# MC1-29  # ADC1_DCO_N       set_property PACKAGE_PIN U5   [get_ports c_B34D_L14N_SRCC ]  
//# MC1-31  # ADC1_SDOA_P      set_property PACKAGE_PIN AA5  [get_ports i_B34D_L10P      ]  
//# MC1-33  # ADC1_SDOA_N      set_property PACKAGE_PIN AB5  [get_ports i_B34D_L10N      ]  
//# MC1-37  # ADC1_SDOB_P      set_property PACKAGE_PIN AB7  [get_ports i_B34D_L20P      ]  
//# MC1-39  # ADC1_SDOB_N      set_property PACKAGE_PIN AB6  [get_ports i_B34D_L20N      ]  
//# MC1-41  # ADC1_SDOC_P      set_property PACKAGE_PIN R3   [get_ports i_B34D_L3P       ]  
//# MC1-43  # ADC1_SDOC_N      set_property PACKAGE_PIN R2   [get_ports i_B34D_L3N       ]  
//# MC1-45  # ADC1_SDOD_P      set_property PACKAGE_PIN Y3   [get_ports i_B34D_L9P       ]  
//# MC1-47  # ADC1_SDOD_N      set_property PACKAGE_PIN AA3  [get_ports i_B34D_L9N       ]  
wire  ADC1_DCO_;
wire  ADC1_SDOA;
wire  ADC1_SDOB;
wire  ADC1_SDOC;
wire  ADC1_SDOD;
IBUFDS ibufds__ADC1_DCO__inst (.I(c_B34D_L14P_SRCC), .IB(c_B34D_L14N_SRCC), .O(ADC1_DCO_) );
IBUFDS ibufds__ADC1_SDOA_inst (.I(i_B34D_L10P     ), .IB(i_B34D_L10N     ), .O(ADC1_SDOA) );
IBUFDS ibufds__ADC1_SDOB_inst (.I(i_B34D_L20P     ), .IB(i_B34D_L20N     ), .O(ADC1_SDOB) );
IBUFDS ibufds__ADC1_SDOC_inst (.I(i_B34D_L3P      ), .IB(i_B34D_L3N      ), .O(ADC1_SDOC) );
IBUFDS ibufds__ADC1_SDOD_inst (.I(i_B34D_L9P      ), .IB(i_B34D_L9N      ), .O(ADC1_SDOD) );

//# MC2-20  # ADC2_SDOD_N      set_property PACKAGE_PIN P2   [get_ports i_B35D_L22P      ]
//# MC2-22  # ADC2_SDOD_P      set_property PACKAGE_PIN N2   [get_ports i_B35D_L22N      ]
//# MC2-24  # ADC2_SDOC_N      set_property PACKAGE_PIN R1   [get_ports i_B35D_L20P      ]
//# MC2-26  # ADC2_SDOC_P      set_property PACKAGE_PIN P1   [get_ports i_B35D_L20N      ]
//# MC2-28  # ADC2_SDOB_N      set_property PACKAGE_PIN M3   [get_ports i_B35D_L16P      ]
//# MC2-30  # ADC2_SDOB_P      set_property PACKAGE_PIN M2   [get_ports i_B35D_L16N      ]
//# MC2-32  # ADC2_SDOA_N      set_property PACKAGE_PIN K6   [get_ports i_B35D_L17P      ]
//# MC2-34  # ADC2_SDOA_P      set_property PACKAGE_PIN J6   [get_ports i_B35D_L17N      ]
//# MC2-38  # ADC2_DCO_N       set_property PACKAGE_PIN L3   [get_ports c_B35D_L14P_SRCC ]
//# MC2-40  # ADC2_DCO_P       set_property PACKAGE_PIN K3   [get_ports c_B35D_L14N_SRCC ]
wire  ADC2_SDOD_B;  wire  ADC2_SDOD = ~ADC2_SDOD_B;
wire  ADC2_SDOC_B;  wire  ADC2_SDOC = ~ADC2_SDOC_B;
wire  ADC2_SDOB_B;  wire  ADC2_SDOB = ~ADC2_SDOB_B;
wire  ADC2_SDOA_B;  wire  ADC2_SDOA = ~ADC2_SDOA_B;
wire  ADC2_DCO__B;  wire  ADC2_DCO_ = ~ADC2_DCO__B;
IBUFDS ibufds__ADC2_SDOD_inst (.I(i_B35D_L22P     ), .IB(i_B35D_L22N     ), .O(ADC2_SDOD_B) );
IBUFDS ibufds__ADC2_SDOC_inst (.I(i_B35D_L20P     ), .IB(i_B35D_L20N     ), .O(ADC2_SDOC_B) );
IBUFDS ibufds__ADC2_SDOB_inst (.I(i_B35D_L16P     ), .IB(i_B35D_L16N     ), .O(ADC2_SDOB_B) );
IBUFDS ibufds__ADC2_SDOA_inst (.I(i_B35D_L17P     ), .IB(i_B35D_L17N     ), .O(ADC2_SDOA_B) );
IBUFDS ibufds__ADC2_DCO__inst (.I(c_B35D_L14P_SRCC), .IB(c_B35D_L14N_SRCC), .O(ADC2_DCO__B) );

//# MC2-27  # ADC3_SDOA_P      set_property PACKAGE_PIN M6   [get_ports i_B35D_L23P      ]
//# MC2-29  # ADC3_SDOA_N      set_property PACKAGE_PIN M5   [get_ports i_B35D_L23N      ]
//# MC2-31  # ADC3_SDOB_P      set_property PACKAGE_PIN M1   [get_ports i_B35D_L15P      ]
//# MC2-33  # ADC3_SDOB_N      set_property PACKAGE_PIN L1   [get_ports i_B35D_L15N      ]
//# MC2-37  # ADC3_SDOC_P      set_property PACKAGE_PIN K2   [get_ports i_B35D_L9P       ]
//# MC2-39  # ADC3_SDOC_N      set_property PACKAGE_PIN J2   [get_ports i_B35D_L9N       ]
//# MC2-41  # ADC3_SDOD_P      set_property PACKAGE_PIN K1   [get_ports i_B35D_L7P       ]
//# MC2-43  # ADC3_SDOD_N      set_property PACKAGE_PIN J1   [get_ports i_B35D_L7N       ]
//# MC2-45  # ADC3_DCO_P       set_property PACKAGE_PIN H3   [get_ports c_B35D_L11P_SRCC ]
//# MC2-47  # ADC3_DCO_N       set_property PACKAGE_PIN G3   [get_ports c_B35D_L11N_SRCC ]
wire  ADC3_SDOA;
wire  ADC3_SDOB;
wire  ADC3_SDOC;
wire  ADC3_SDOD;
wire  ADC3_DCO_;
IBUFDS ibufds__ADC3_SDOA_inst (.I(i_B35D_L23P     ), .IB(i_B35D_L23N     ), .O(ADC3_SDOA) );
IBUFDS ibufds__ADC3_SDOB_inst (.I(i_B35D_L15P     ), .IB(i_B35D_L15N     ), .O(ADC3_SDOB) );
IBUFDS ibufds__ADC3_SDOC_inst (.I(i_B35D_L9P      ), .IB(i_B35D_L9N      ), .O(ADC3_SDOC) );
IBUFDS ibufds__ADC3_SDOD_inst (.I(i_B35D_L7P      ), .IB(i_B35D_L7N      ), .O(ADC3_SDOD) );
IBUFDS ibufds__ADC3_DCO__inst (.I(c_B35D_L11P_SRCC), .IB(c_B35D_L11N_SRCC), .O(ADC3_DCO_) );

//}


// monitoring //{

// signal monitoring reg
(* keep = "true" *) reg r_ADCx_CNV  ; // 
(* keep = "true" *) reg r_ADCx_SCK  ; // 
//
(* keep = "true" *) reg r_ADC0_DCO_ ; // 
(* keep = "true" *) reg r_ADC0_SDOA ; // 
(* keep = "true" *) reg r_ADC0_SDOB ; // 
(* keep = "true" *) reg r_ADC0_SDOC ; // 
(* keep = "true" *) reg r_ADC0_SDOD ; // 
(* keep = "true" *) reg r_ADC1_DCO_ ; // 
(* keep = "true" *) reg r_ADC1_SDOA ; // 
(* keep = "true" *) reg r_ADC1_SDOB ; // 
(* keep = "true" *) reg r_ADC1_SDOC ; // 
(* keep = "true" *) reg r_ADC1_SDOD ; // 
(* keep = "true" *) reg r_ADC2_DCO_ ; // 
(* keep = "true" *) reg r_ADC2_SDOA ; // 
(* keep = "true" *) reg r_ADC2_SDOB ; // 
(* keep = "true" *) reg r_ADC2_SDOC ; // 
(* keep = "true" *) reg r_ADC2_SDOD ; // 
(* keep = "true" *) reg r_ADC3_DCO_ ; // 
(* keep = "true" *) reg r_ADC3_SDOA ; // 
(* keep = "true" *) reg r_ADC3_SDOB ; // 
(* keep = "true" *) reg r_ADC3_SDOC ; // 
(* keep = "true" *) reg r_ADC3_SDOD ; // 

// input pin sampling
always @(posedge base_adc_clk, negedge reset_n)
	if (!reset_n) begin
		r_ADC0_DCO_   <= 1'b0; // 
		r_ADC0_SDOA   <= 1'b0; // 
		r_ADC0_SDOB   <= 1'b0; // 
		r_ADC0_SDOC   <= 1'b0; // 
		r_ADC0_SDOD   <= 1'b0; // 
		r_ADC1_DCO_   <= 1'b0; // 
		r_ADC1_SDOA   <= 1'b0; // 
		r_ADC1_SDOB   <= 1'b0; // 
		r_ADC1_SDOC   <= 1'b0; // 
		r_ADC1_SDOD   <= 1'b0; // 
		r_ADC2_DCO_   <= 1'b0; // 
		r_ADC2_SDOA   <= 1'b0; // 
		r_ADC2_SDOB   <= 1'b0; // 
		r_ADC2_SDOC   <= 1'b0; // 
		r_ADC2_SDOD   <= 1'b0; // 
		r_ADC3_DCO_   <= 1'b0; // 
		r_ADC3_SDOA   <= 1'b0; // 
		r_ADC3_SDOB   <= 1'b0; // 
		r_ADC3_SDOC   <= 1'b0; // 
		r_ADC3_SDOD   <= 1'b0; // 
	end
	else begin
		r_ADC0_DCO_  <=  ADC0_DCO_ ; // 
		r_ADC0_SDOA  <=  ADC0_SDOA ; // 
		r_ADC0_SDOB  <=  ADC0_SDOB ; // 
		r_ADC0_SDOC  <=  ADC0_SDOC ; // 
		r_ADC0_SDOD  <=  ADC0_SDOD ; // 
		r_ADC1_DCO_  <=  ADC1_DCO_ ; // 
		r_ADC1_SDOA  <=  ADC1_SDOA ; // 
		r_ADC1_SDOB  <=  ADC1_SDOB ; // 
		r_ADC1_SDOC  <=  ADC1_SDOC ; // 
		r_ADC1_SDOD  <=  ADC1_SDOD ; // 
		r_ADC2_DCO_  <=  ADC2_DCO_ ; // 
		r_ADC2_SDOA  <=  ADC2_SDOA ; // 
		r_ADC2_SDOB  <=  ADC2_SDOB ; // 
		r_ADC2_SDOC  <=  ADC2_SDOC ; // 
		r_ADC2_SDOD  <=  ADC2_SDOD ; // 
		r_ADC3_DCO_  <=  ADC3_DCO_ ; // 
		r_ADC3_SDOA  <=  ADC3_SDOA ; // 
		r_ADC3_SDOB  <=  ADC3_SDOB ; // 
		r_ADC3_SDOC  <=  ADC3_SDOC ; // 
		r_ADC3_SDOD  <=  ADC3_SDOD ; // 
	end	

// output pin driving 
wire w_ADCx_CNV ;
wire w_ADCx_SCK ;
//
always @(posedge base_adc_clk, negedge reset_n)
	if (!reset_n) begin
		r_ADCx_CNV   <= 1'b0; // 
		r_ADCx_SCK   <= 1'b0; // 
	end
	else begin
		r_ADCx_CNV  <=  w_ADCx_CNV ; // 
		r_ADCx_SCK  <=  w_ADCx_SCK ; // 
	end	


// external signal from slave SPI
wire [31:0] adc_con_wi_ext  ;
wire [31:0] adc_par_wi_ext  ;
wire [ 3:0] adc_trig_ti_ext ;


// output test pattern 
wire mode__adc_forced_drive__en = (w_ADC_CON_WI[0])? w_ADC_CON_WI[16] : adc_con_wi_ext[16];
wire sig__adc_cnv = (w_ADC_CON_WI[0])? w_ADC_CON_WI[17] : adc_con_wi_ext[17];
wire sig__adc_sck = (w_ADC_CON_WI[0])? w_ADC_CON_WI[18] : adc_con_wi_ext[18];
//
wire w_adc_cnv;
wire w_adc_sck;
//
assign w_ADCx_CNV  =  (mode__adc_forced_drive__en)? sig__adc_cnv : w_adc_cnv ;
assign w_ADCx_SCK  =  (mode__adc_forced_drive__en)? sig__adc_sck : w_adc_sck ;

// min max port switching 
wire port_en__adc_min = (w_ADC_CON_WI[0])? w_ADC_CON_WI[8] : adc_con_wi_ext[8];
wire port_en__adc_max = (w_ADC_CON_WI[0])? w_ADC_CON_WI[9] : adc_con_wi_ext[9];

//}


// module for ADC //{

wire         w_ADC_en            = (~w_ADC_TRIG_TI[0]) & (~adc_trig_ti_ext[0]);
//
wire         w_test_mode_en      = (w_ADC_CON_WI[0])? w_ADC_CON_WI [1] : adc_con_wi_ext [1] ;
wire         w_test_mode_hs      = (w_ADC_CON_WI[0])? w_ADC_CON_WI [2] : adc_con_wi_ext [2] ;

wire         w_acc_bit_shift_disable = (w_ADC_CON_WI[0])? w_ADC_CON_WI [4] : adc_con_wi_ext [4] ; // 0 for disable
wire         w_acc_bit_shift_08_16__ = (w_ADC_CON_WI[0])? w_ADC_CON_WI [5] : adc_con_wi_ext [5] ; // 0/1 for 8/16bit-shift

wire w_adc_trig_cowork__ext; // from EXT_TRIG
//
(* keep = "true" *) wire w_trig_conv_single  = w_ADC_TRIG_TI[1] | adc_trig_ti_ext[1] ;
(* keep = "true" *) wire w_trig_conv_run     = w_ADC_TRIG_TI[2] | adc_trig_ti_ext[2] | w_adc_trig_cowork__ext;
(* keep = "true" *) wire w_trig_conv_stop    = w_ADC_TRIG_TI[3] | adc_trig_ti_ext[3] ; // reserved

wire  [15:0] w_count_period_div4 = (w_ADC_CON_WI[0])? w_ADC_PAR_WI [15:0 ] : adc_par_wi_ext [15:0 ] ;
wire  [15:0] w_count_conv_div4   = (w_ADC_CON_WI[0])? w_ADC_PAR_WI [31:16] : adc_par_wi_ext [31:16] ;
wire         w_ADC_busy          ;
wire         w_ADC_busy_pclk     ;
wire         w_ADC_done_to       ;
wire         w_ADC_done_to_pclk  ;

//// ADC IO //{
wire         w_CNV_B             ;
wire         w_SCK               ;
//
wire         w_ADC0_DCO               =  r_ADC0_DCO_;
wire  [3:0]  w_ADC0_SDO               = {r_ADC0_SDOD,r_ADC0_SDOC,r_ADC0_SDOB,r_ADC0_SDOA};
wire         w_ADC1_DCO               =  r_ADC1_DCO_;
wire  [3:0]  w_ADC1_SDO               = {r_ADC1_SDOD,r_ADC1_SDOC,r_ADC1_SDOB,r_ADC1_SDOA};
wire         w_ADC2_DCO               =  r_ADC2_DCO_;
wire  [3:0]  w_ADC2_SDO               = {r_ADC2_SDOD,r_ADC2_SDOC,r_ADC2_SDOB,r_ADC2_SDOA};
wire         w_ADC3_DCO               =  r_ADC3_DCO_;
wire  [3:0]  w_ADC3_SDO               = {r_ADC3_SDOD,r_ADC3_SDOC,r_ADC3_SDOB,r_ADC3_SDOA};
//}

//// ADC interface //{
wire  [15:0] w_p_data_ADC0_A          ; // ADC0_A S2_CH2
wire  [15:0] w_p_data_ADC0_B          ; // ADC0_B S2_CH1
wire  [15:0] w_p_data_ADC0_C          ; // ADC0_C S1_CH2
wire  [15:0] w_p_data_ADC0_D          ; // ADC0_D S1_CH1
wire  [15:0] w_p_data_ADC1_A          ; // ADC1_A S4_CH2
wire  [15:0] w_p_data_ADC1_B          ; // ADC1_B S4_CH1
wire  [15:0] w_p_data_ADC1_C          ; // ADC1_C S3_CH2
wire  [15:0] w_p_data_ADC1_D          ; // ADC1_D S3_CH1
wire  [15:0] w_p_data_ADC2_A          ; // ADC2_A S6_CH2
wire  [15:0] w_p_data_ADC2_B          ; // ADC2_B S6_CH1
wire  [15:0] w_p_data_ADC2_C          ; // ADC2_C S5_CH2
wire  [15:0] w_p_data_ADC2_D          ; // ADC2_D S5_CH1
wire  [15:0] w_p_data_ADC3_A          ; // ADC3_A S8_CH2
wire  [15:0] w_p_data_ADC3_B          ; // ADC3_B S8_CH1
wire  [15:0] w_p_data_ADC3_C          ; // ADC3_C S7_CH2
wire  [15:0] w_p_data_ADC3_D          ; // ADC3_D S7_CH1
//
wire         w_p_data_ADC0_rd ;
wire         w_p_data_ADC1_rd ;
wire         w_p_data_ADC2_rd ;
wire         w_p_data_ADC3_rd ;
//
wire  [15:0] w_p_data_ADC0_A_pclk          ; // ADC0_A S2_CH2
wire  [15:0] w_p_data_ADC0_B_pclk          ; // ADC0_B S2_CH1
wire  [15:0] w_p_data_ADC0_C_pclk          ; // ADC0_C S1_CH2
wire  [15:0] w_p_data_ADC0_D_pclk          ; // ADC0_D S1_CH1
wire  [15:0] w_p_data_ADC1_A_pclk          ; // ADC1_A S4_CH2
wire  [15:0] w_p_data_ADC1_B_pclk          ; // ADC1_B S4_CH1
wire  [15:0] w_p_data_ADC1_C_pclk          ; // ADC1_C S3_CH2
wire  [15:0] w_p_data_ADC1_D_pclk          ; // ADC1_D S3_CH1
wire  [15:0] w_p_data_ADC2_A_pclk          ; // ADC2_A S6_CH2
wire  [15:0] w_p_data_ADC2_B_pclk          ; // ADC2_B S6_CH1
wire  [15:0] w_p_data_ADC2_C_pclk          ; // ADC2_C S5_CH2
wire  [15:0] w_p_data_ADC2_D_pclk          ; // ADC2_D S5_CH1
wire  [15:0] w_p_data_ADC3_A_pclk          ; // ADC3_A S8_CH2
wire  [15:0] w_p_data_ADC3_B_pclk          ; // ADC3_B S8_CH1
wire  [15:0] w_p_data_ADC3_C_pclk          ; // ADC3_C S7_CH2
wire  [15:0] w_p_data_ADC3_D_pclk          ; // ADC3_D S7_CH1
//
wire         w_p_data_ADC0_rd_pclk ;
wire         w_p_data_ADC1_rd_pclk ;
wire         w_p_data_ADC2_rd_pclk ;
wire         w_p_data_ADC3_rd_pclk ;

wire  [15:0] w_cnt_adc_fifo_in_pclk;
wire  [15:0] w_cnt_adc_trig_conv_pclk;

//}

//// ADC ACC/MIN/MAX interface //{
wire  [31:0]  w_p_data_ADC0_A_ACC  ;  wire  [15:0]  w_p_data_ADC0_A_MIN  ;  wire  [15:0]  w_p_data_ADC0_A_MAX  ;
wire  [31:0]  w_p_data_ADC0_B_ACC  ;  wire  [15:0]  w_p_data_ADC0_B_MIN  ;  wire  [15:0]  w_p_data_ADC0_B_MAX  ;
wire  [31:0]  w_p_data_ADC0_C_ACC  ;  wire  [15:0]  w_p_data_ADC0_C_MIN  ;  wire  [15:0]  w_p_data_ADC0_C_MAX  ;
wire  [31:0]  w_p_data_ADC0_D_ACC  ;  wire  [15:0]  w_p_data_ADC0_D_MIN  ;  wire  [15:0]  w_p_data_ADC0_D_MAX  ;
wire  [31:0]  w_p_data_ADC1_A_ACC  ;  wire  [15:0]  w_p_data_ADC1_A_MIN  ;  wire  [15:0]  w_p_data_ADC1_A_MAX  ;
wire  [31:0]  w_p_data_ADC1_B_ACC  ;  wire  [15:0]  w_p_data_ADC1_B_MIN  ;  wire  [15:0]  w_p_data_ADC1_B_MAX  ;
wire  [31:0]  w_p_data_ADC1_C_ACC  ;  wire  [15:0]  w_p_data_ADC1_C_MIN  ;  wire  [15:0]  w_p_data_ADC1_C_MAX  ;
wire  [31:0]  w_p_data_ADC1_D_ACC  ;  wire  [15:0]  w_p_data_ADC1_D_MIN  ;  wire  [15:0]  w_p_data_ADC1_D_MAX  ;
wire  [31:0]  w_p_data_ADC2_A_ACC  ;  wire  [15:0]  w_p_data_ADC2_A_MIN  ;  wire  [15:0]  w_p_data_ADC2_A_MAX  ;
wire  [31:0]  w_p_data_ADC2_B_ACC  ;  wire  [15:0]  w_p_data_ADC2_B_MIN  ;  wire  [15:0]  w_p_data_ADC2_B_MAX  ;
wire  [31:0]  w_p_data_ADC2_C_ACC  ;  wire  [15:0]  w_p_data_ADC2_C_MIN  ;  wire  [15:0]  w_p_data_ADC2_C_MAX  ;
wire  [31:0]  w_p_data_ADC2_D_ACC  ;  wire  [15:0]  w_p_data_ADC2_D_MIN  ;  wire  [15:0]  w_p_data_ADC2_D_MAX  ;
wire  [31:0]  w_p_data_ADC3_A_ACC  ;  wire  [15:0]  w_p_data_ADC3_A_MIN  ;  wire  [15:0]  w_p_data_ADC3_A_MAX  ;
wire  [31:0]  w_p_data_ADC3_B_ACC  ;  wire  [15:0]  w_p_data_ADC3_B_MIN  ;  wire  [15:0]  w_p_data_ADC3_B_MAX  ;
wire  [31:0]  w_p_data_ADC3_C_ACC  ;  wire  [15:0]  w_p_data_ADC3_C_MIN  ;  wire  [15:0]  w_p_data_ADC3_C_MAX  ;
wire  [31:0]  w_p_data_ADC3_D_ACC  ;  wire  [15:0]  w_p_data_ADC3_D_MIN  ;  wire  [15:0]  w_p_data_ADC3_D_MAX  ;
//}

//// fifo interface //{
// fifo read clock
wire c_f_clk; // = okClk; // mux between usb and slave spi (to come)
BUFGMUX bufgmux_c_f_clk_inst (
	.O(c_f_clk), 
	.I0(base_sspi_clk), // base_sspi_clk vs p_adc_clk 
	.I1(pipeClk), 
	.S(w_ADC_CON_WI[0]) 
);
//
wire w_ADC_S1_CH1_PO_rd_sspi_M0;  wire w_ADC_S1_CH1_PO_rd_sspi_M1;  // ADC0_D  S1_CH1  0x280	poA0
wire w_ADC_S2_CH1_PO_rd_sspi_M0;  wire w_ADC_S2_CH1_PO_rd_sspi_M1;  // ADC0_B  S2_CH1  0x284	poA1
wire w_ADC_S3_CH1_PO_rd_sspi_M0;  wire w_ADC_S3_CH1_PO_rd_sspi_M1;  // ADC1_D  S3_CH1  0x288	poA2
wire w_ADC_S4_CH1_PO_rd_sspi_M0;  wire w_ADC_S4_CH1_PO_rd_sspi_M1;  // ADC1_B  S4_CH1  0x28C	poA3
wire w_ADC_S5_CH1_PO_rd_sspi_M0;  wire w_ADC_S5_CH1_PO_rd_sspi_M1;  // ADC2_D  S5_CH1  0x290	poA4
wire w_ADC_S6_CH1_PO_rd_sspi_M0;  wire w_ADC_S6_CH1_PO_rd_sspi_M1;  // ADC2_B  S6_CH1  0x294	poA5
wire w_ADC_S7_CH1_PO_rd_sspi_M0;  wire w_ADC_S7_CH1_PO_rd_sspi_M1;  // ADC3_D  S7_CH1  0x298	poA6
wire w_ADC_S8_CH1_PO_rd_sspi_M0;  wire w_ADC_S8_CH1_PO_rd_sspi_M1;  // ADC3_B  S8_CH1  0x29C	poA7
wire w_ADC_S1_CH2_PO_rd_sspi_M0;  wire w_ADC_S1_CH2_PO_rd_sspi_M1;  // ADC0_C  S1_CH2  0x2A0	poA8
wire w_ADC_S2_CH2_PO_rd_sspi_M0;  wire w_ADC_S2_CH2_PO_rd_sspi_M1;  // ADC0_A  S2_CH2  0x2A4	poA9
wire w_ADC_S3_CH2_PO_rd_sspi_M0;  wire w_ADC_S3_CH2_PO_rd_sspi_M1;  // ADC1_C  S3_CH2  0x2A8	poAA
wire w_ADC_S4_CH2_PO_rd_sspi_M0;  wire w_ADC_S4_CH2_PO_rd_sspi_M1;  // ADC1_A  S4_CH2  0x2AC	poAB
wire w_ADC_S5_CH2_PO_rd_sspi_M0;  wire w_ADC_S5_CH2_PO_rd_sspi_M1;  // ADC2_C  S5_CH2  0x2B0	poAC
wire w_ADC_S6_CH2_PO_rd_sspi_M0;  wire w_ADC_S6_CH2_PO_rd_sspi_M1;  // ADC2_A  S6_CH2  0x2B4	poAD
wire w_ADC_S7_CH2_PO_rd_sspi_M0;  wire w_ADC_S7_CH2_PO_rd_sspi_M1;  // ADC3_C  S7_CH2  0x2B8	poAE
wire w_ADC_S8_CH2_PO_rd_sspi_M0;  wire w_ADC_S8_CH2_PO_rd_sspi_M1;  // ADC3_A  S8_CH2  0x2BC	poAF
//
wire w_ADC_S1_CH1_PO_rd_sspi = w_ADC_S1_CH1_PO_rd_sspi_M0 | w_ADC_S1_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S2_CH1_PO_rd_sspi = w_ADC_S2_CH1_PO_rd_sspi_M0 | w_ADC_S2_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S3_CH1_PO_rd_sspi = w_ADC_S3_CH1_PO_rd_sspi_M0 | w_ADC_S3_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S4_CH1_PO_rd_sspi = w_ADC_S4_CH1_PO_rd_sspi_M0 | w_ADC_S4_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S5_CH1_PO_rd_sspi = w_ADC_S5_CH1_PO_rd_sspi_M0 | w_ADC_S5_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S6_CH1_PO_rd_sspi = w_ADC_S6_CH1_PO_rd_sspi_M0 | w_ADC_S6_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S7_CH1_PO_rd_sspi = w_ADC_S7_CH1_PO_rd_sspi_M0 | w_ADC_S7_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S8_CH1_PO_rd_sspi = w_ADC_S8_CH1_PO_rd_sspi_M0 | w_ADC_S8_CH1_PO_rd_sspi_M1 ;
wire w_ADC_S1_CH2_PO_rd_sspi = w_ADC_S1_CH2_PO_rd_sspi_M0 | w_ADC_S1_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S2_CH2_PO_rd_sspi = w_ADC_S2_CH2_PO_rd_sspi_M0 | w_ADC_S2_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S3_CH2_PO_rd_sspi = w_ADC_S3_CH2_PO_rd_sspi_M0 | w_ADC_S3_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S4_CH2_PO_rd_sspi = w_ADC_S4_CH2_PO_rd_sspi_M0 | w_ADC_S4_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S5_CH2_PO_rd_sspi = w_ADC_S5_CH2_PO_rd_sspi_M0 | w_ADC_S5_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S6_CH2_PO_rd_sspi = w_ADC_S6_CH2_PO_rd_sspi_M0 | w_ADC_S6_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S7_CH2_PO_rd_sspi = w_ADC_S7_CH2_PO_rd_sspi_M0 | w_ADC_S7_CH2_PO_rd_sspi_M1 ;
wire w_ADC_S8_CH2_PO_rd_sspi = w_ADC_S8_CH2_PO_rd_sspi_M0 | w_ADC_S8_CH2_PO_rd_sspi_M1 ;
// ADC0_A  S2_CH2
wire                          w_fifo_adc0_a_rd_en = (w_ADC_CON_WI[0])? w_ADC_S2_CH2_PO_rd : w_ADC_S2_CH2_PO_rd_sspi; // to mux
wire [15:0]                   w_fifo_adc0_a_dout  ;
wire                          w_fifo_adc0_a_full  ;
wire                          w_fifo_adc0_a_empty ;
assign w_ADC_S2_CH2_PO = {{16{w_fifo_adc0_a_dout[15]}},
                              w_fifo_adc0_a_dout}; // sign bit ext
// ADC0_B  S2_CH1
wire                          w_fifo_adc0_b_rd_en = (w_ADC_CON_WI[0])? w_ADC_S2_CH1_PO_rd : w_ADC_S2_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc0_b_dout  ;
wire                          w_fifo_adc0_b_full  ;
wire                          w_fifo_adc0_b_empty ;
assign w_ADC_S2_CH1_PO = {{16{w_fifo_adc0_b_dout[15]}},
                              w_fifo_adc0_b_dout}; // sign bit ext
// ADC0_C  S1_CH2
wire                          w_fifo_adc0_c_rd_en = (w_ADC_CON_WI[0])? w_ADC_S1_CH2_PO_rd : w_ADC_S1_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc0_c_dout  ;
wire                          w_fifo_adc0_c_full  ;
wire                          w_fifo_adc0_c_empty ;
assign w_ADC_S1_CH2_PO = {{16{w_fifo_adc0_c_dout[15]}},
                              w_fifo_adc0_c_dout}; // sign bit ext
// ADC0_D  S1_CH1
wire                          w_fifo_adc0_d_rd_en = (w_ADC_CON_WI[0])? w_ADC_S1_CH1_PO_rd : w_ADC_S1_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc0_d_dout  ;
wire                          w_fifo_adc0_d_full  ;
wire                          w_fifo_adc0_d_empty ;
assign w_ADC_S1_CH1_PO = {{16{w_fifo_adc0_d_dout[15]}},
                              w_fifo_adc0_d_dout}; // sign bit ext
// ADC1_A  S4_CH2
wire                          w_fifo_adc1_a_rd_en = (w_ADC_CON_WI[0])? w_ADC_S4_CH2_PO_rd : w_ADC_S4_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc1_a_dout  ;
wire                          w_fifo_adc1_a_full  ;
wire                          w_fifo_adc1_a_empty ;
assign w_ADC_S4_CH2_PO = {{16{w_fifo_adc1_a_dout[15]}},
                              w_fifo_adc1_a_dout}; // sign bit ext
// ADC1_B  S4_CH1                        
wire                          w_fifo_adc1_b_rd_en = (w_ADC_CON_WI[0])? w_ADC_S4_CH1_PO_rd : w_ADC_S4_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc1_b_dout  ;
wire                          w_fifo_adc1_b_full  ;
wire                          w_fifo_adc1_b_empty ;
assign w_ADC_S4_CH1_PO = {{16{w_fifo_adc1_b_dout[15]}},
                              w_fifo_adc1_b_dout}; // sign bit ext
// ADC1_C  S3_CH2                        
wire                          w_fifo_adc1_c_rd_en = (w_ADC_CON_WI[0])? w_ADC_S3_CH2_PO_rd : w_ADC_S3_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc1_c_dout  ;
wire                          w_fifo_adc1_c_full  ;
wire                          w_fifo_adc1_c_empty ;
assign w_ADC_S3_CH2_PO = {{16{w_fifo_adc1_c_dout[15]}},
                              w_fifo_adc1_c_dout}; // sign bit ext
// ADC1_D  S3_CH1                         
wire                          w_fifo_adc1_d_rd_en = (w_ADC_CON_WI[0])? w_ADC_S3_CH1_PO_rd : w_ADC_S3_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc1_d_dout  ;
wire                          w_fifo_adc1_d_full  ;
wire                          w_fifo_adc1_d_empty ;
assign w_ADC_S3_CH1_PO = {{16{w_fifo_adc1_d_dout[15]}},
                              w_fifo_adc1_d_dout}; // sign bit ext
// ADC2_A  S6_CH2
wire                          w_fifo_adc2_a_rd_en = (w_ADC_CON_WI[0])? w_ADC_S6_CH2_PO_rd : w_ADC_S6_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc2_a_dout  ;
wire                          w_fifo_adc2_a_full  ;
wire                          w_fifo_adc2_a_empty ;
assign w_ADC_S6_CH2_PO = {{16{w_fifo_adc2_a_dout[15]}},
                              w_fifo_adc2_a_dout}; // sign bit ext
// ADC2_B  S6_CH1                        
wire                          w_fifo_adc2_b_rd_en = (w_ADC_CON_WI[0])? w_ADC_S6_CH1_PO_rd : w_ADC_S6_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc2_b_dout  ;
wire                          w_fifo_adc2_b_full  ;
wire                          w_fifo_adc2_b_empty ;
assign w_ADC_S6_CH1_PO = {{16{w_fifo_adc2_b_dout[15]}},
                              w_fifo_adc2_b_dout}; // sign bit ext
// ADC2_C  S5_CH2                        
wire                          w_fifo_adc2_c_rd_en = (w_ADC_CON_WI[0])? w_ADC_S5_CH2_PO_rd : w_ADC_S5_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc2_c_dout  ;
wire                          w_fifo_adc2_c_full  ;
wire                          w_fifo_adc2_c_empty ;
assign w_ADC_S5_CH2_PO = {{16{w_fifo_adc2_c_dout[15]}},
                              w_fifo_adc2_c_dout}; // sign bit ext
// ADC2_D  S5_CH1                        
wire                          w_fifo_adc2_d_rd_en = (w_ADC_CON_WI[0])? w_ADC_S5_CH1_PO_rd : w_ADC_S5_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc2_d_dout  ;
wire                          w_fifo_adc2_d_full  ;
wire                          w_fifo_adc2_d_empty ;
assign w_ADC_S5_CH1_PO = {{16{w_fifo_adc2_d_dout[15]}},
                              w_fifo_adc2_d_dout}; // sign bit ext
// ADC3_A  S8_CH2
wire                          w_fifo_adc3_a_rd_en = (w_ADC_CON_WI[0])? w_ADC_S8_CH2_PO_rd : w_ADC_S8_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc3_a_dout  ;
wire                          w_fifo_adc3_a_full  ;
wire                          w_fifo_adc3_a_empty ;
assign w_ADC_S8_CH2_PO = {{16{w_fifo_adc3_a_dout[15]}},
                              w_fifo_adc3_a_dout}; // sign bit ext
// ADC3_B  S8_CH1                        
wire                          w_fifo_adc3_b_rd_en = (w_ADC_CON_WI[0])? w_ADC_S8_CH1_PO_rd : w_ADC_S8_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc3_b_dout  ;
wire                          w_fifo_adc3_b_full  ;
wire                          w_fifo_adc3_b_empty ;
assign w_ADC_S8_CH1_PO = {{16{w_fifo_adc3_b_dout[15]}},
                              w_fifo_adc3_b_dout}; // sign bit ext
// ADC3_C  S7_CH2                       
wire                          w_fifo_adc3_c_rd_en = (w_ADC_CON_WI[0])? w_ADC_S7_CH2_PO_rd : w_ADC_S7_CH2_PO_rd_sspi;
wire [15:0]                   w_fifo_adc3_c_dout  ;
wire                          w_fifo_adc3_c_full  ;
wire                          w_fifo_adc3_c_empty ;
assign w_ADC_S7_CH2_PO = {{16{w_fifo_adc3_c_dout[15]}},
                              w_fifo_adc3_c_dout}; // sign bit ext
// ADC3_D  S7_CH1                        
wire                          w_fifo_adc3_d_rd_en = (w_ADC_CON_WI[0])? w_ADC_S7_CH1_PO_rd : w_ADC_S7_CH1_PO_rd_sspi;
wire [15:0]                   w_fifo_adc3_d_dout  ;
wire                          w_fifo_adc3_d_full  ;
wire                          w_fifo_adc3_d_empty ;
assign w_ADC_S7_CH1_PO = {{16{w_fifo_adc3_d_dout[15]}},
                              w_fifo_adc3_d_dout}; // sign bit ext
//}
							  
//
control_adc_ddr_LTC2325  control_adc_ddr_LTC2325_inst( 
	.b_clk 			(base_adc_clk), // 192MHz
	.reset_n 		(reset_n & w_ADC_en & (~w_HW_reset)),
	.p_clk 			(p_adc_clk   ), // 12MHz for parallel data out
	
	//// ADC control //{
	.i_test_mode_en        (w_test_mode_en     ), // enable test pattern mode
	.i_test_mode_hs        (w_test_mode_hs),
	.i_trig_conv_single    (w_trig_conv_single ), // trigger for one ADC sample
	.i_trig_conv_run       (w_trig_conv_run    ), // trigger for ADC samples // trig for fifo reset
	.i_count_period_div4   (w_count_period_div4), // [15:0] // sample period = i_count_period_div4*4  // based on b_clk // ex: 15'd105
	.i_count_conv_div4     (w_count_conv_div4  ), // [15:0] // adc samples   = i_count_conv_div4*4    // < 2^17          // ex: 15'd2  
	
	.o_busy           (w_ADC_busy        ), // busy 
	.o_busy_pclk      (w_ADC_busy_pclk   ), // busy 
	.o_done_to        (w_ADC_done_to     ), // done trig out
	.o_done_to_pclk   (w_ADC_done_to_pclk), // done trig out
	
	//}
	
	//// ADC IO port //{
	.o_CNV_B        (w_CNV_B ), 
	.o_SCK          (w_SCK   ), 

	.i_ADC0_DCO            (w_ADC0_DCO     ), 
	.i_ADC0_SDO            (w_ADC0_SDO     ), // [3:0] 
	.i_ADC1_DCO            (w_ADC1_DCO     ), 
	.i_ADC1_SDO            (w_ADC1_SDO     ), // [3:0] 
	.i_ADC2_DCO            (w_ADC2_DCO     ), 
	.i_ADC2_SDO            (w_ADC2_SDO     ), // [3:0] 
	.i_ADC3_DCO            (w_ADC3_DCO     ), 
	.i_ADC3_SDO            (w_ADC3_SDO     ), // [3:0] 
	//}
	
	//// ADC output interface //{
	.o_p_data_ADC0_A       (w_p_data_ADC0_A), // [15:0] // from i_ADC0_SDO[0]
	.o_p_data_ADC0_B       (w_p_data_ADC0_B), // [15:0] // from i_ADC0_SDO[1]
	.o_p_data_ADC0_C       (w_p_data_ADC0_C), // [15:0] // from i_ADC0_SDO[2]
	.o_p_data_ADC0_D       (w_p_data_ADC0_D), // [15:0] // from i_ADC0_SDO[3]
	.o_p_data_ADC1_A       (w_p_data_ADC1_A), // [15:0] // from i_ADC1_SDO[0]
	.o_p_data_ADC1_B       (w_p_data_ADC1_B), // [15:0] // from i_ADC1_SDO[1]
	.o_p_data_ADC1_C       (w_p_data_ADC1_C), // [15:0] // from i_ADC1_SDO[2]
	.o_p_data_ADC1_D       (w_p_data_ADC1_D), // [15:0] // from i_ADC1_SDO[3]
	.o_p_data_ADC2_A       (w_p_data_ADC2_A), // [15:0] // from i_ADC2_SDO[0]
	.o_p_data_ADC2_B       (w_p_data_ADC2_B), // [15:0] // from i_ADC2_SDO[1]
	.o_p_data_ADC2_C       (w_p_data_ADC2_C), // [15:0] // from i_ADC2_SDO[2]
	.o_p_data_ADC2_D       (w_p_data_ADC2_D), // [15:0] // from i_ADC2_SDO[3]
	.o_p_data_ADC3_A       (w_p_data_ADC3_A), // [15:0] // from i_ADC3_SDO[0]
	.o_p_data_ADC3_B       (w_p_data_ADC3_B), // [15:0] // from i_ADC3_SDO[1]
	.o_p_data_ADC3_C       (w_p_data_ADC3_C), // [15:0] // from i_ADC3_SDO[2]
	.o_p_data_ADC3_D       (w_p_data_ADC3_D), // [15:0] // from i_ADC3_SDO[3]
	
	.o_p_data_ADC0_rd      (w_p_data_ADC0_rd), //
	.o_p_data_ADC1_rd      (w_p_data_ADC1_rd), //
	.o_p_data_ADC2_rd      (w_p_data_ADC2_rd), //
	.o_p_data_ADC3_rd      (w_p_data_ADC3_rd), //

	.o_p_data_ADC0_A_pclk       (w_p_data_ADC0_A_pclk), // [15:0] // from i_ADC0_SDO[0]
	.o_p_data_ADC0_B_pclk       (w_p_data_ADC0_B_pclk), // [15:0] // from i_ADC0_SDO[1]
	.o_p_data_ADC0_C_pclk       (w_p_data_ADC0_C_pclk), // [15:0] // from i_ADC0_SDO[2]
	.o_p_data_ADC0_D_pclk       (w_p_data_ADC0_D_pclk), // [15:0] // from i_ADC0_SDO[3]
	.o_p_data_ADC1_A_pclk       (w_p_data_ADC1_A_pclk), // [15:0] // from i_ADC1_SDO[0]
	.o_p_data_ADC1_B_pclk       (w_p_data_ADC1_B_pclk), // [15:0] // from i_ADC1_SDO[1]
	.o_p_data_ADC1_C_pclk       (w_p_data_ADC1_C_pclk), // [15:0] // from i_ADC1_SDO[2]
	.o_p_data_ADC1_D_pclk       (w_p_data_ADC1_D_pclk), // [15:0] // from i_ADC1_SDO[3]
	.o_p_data_ADC2_A_pclk       (w_p_data_ADC2_A_pclk), // [15:0] // from i_ADC2_SDO[0]
	.o_p_data_ADC2_B_pclk       (w_p_data_ADC2_B_pclk), // [15:0] // from i_ADC2_SDO[1]
	.o_p_data_ADC2_C_pclk       (w_p_data_ADC2_C_pclk), // [15:0] // from i_ADC2_SDO[2]
	.o_p_data_ADC2_D_pclk       (w_p_data_ADC2_D_pclk), // [15:0] // from i_ADC2_SDO[3]
	.o_p_data_ADC3_A_pclk       (w_p_data_ADC3_A_pclk), // [15:0] // from i_ADC3_SDO[0]
	.o_p_data_ADC3_B_pclk       (w_p_data_ADC3_B_pclk), // [15:0] // from i_ADC3_SDO[1]
	.o_p_data_ADC3_C_pclk       (w_p_data_ADC3_C_pclk), // [15:0] // from i_ADC3_SDO[2]
	.o_p_data_ADC3_D_pclk       (w_p_data_ADC3_D_pclk), // [15:0] // from i_ADC3_SDO[3]
	
	.o_p_data_ADC0_rd_pclk      (w_p_data_ADC0_rd_pclk), //
	.o_p_data_ADC1_rd_pclk      (w_p_data_ADC1_rd_pclk), //
	.o_p_data_ADC2_rd_pclk      (w_p_data_ADC2_rd_pclk), //
	.o_p_data_ADC3_rd_pclk      (w_p_data_ADC3_rd_pclk), //
	
	.o_cnt_adc_fifo_in_pclk     (w_cnt_adc_fifo_in_pclk), // [15:0] //$$ w_SSPI_CNT_ADC_FIFO_IN_WO
	.o_cnt_trig_conv_pclk       (w_cnt_adc_trig_conv_pclk  ), // [15:0] //$$ w_SSPI_CNT_ADC_TRIG_WO
	
	//}
	
	//// ACC interface //{
	.o_p_data_ADC0_A_ACC   (w_p_data_ADC0_A_ACC), // [31:0] 
	.o_p_data_ADC0_B_ACC   (w_p_data_ADC0_B_ACC), // [31:0] 
	.o_p_data_ADC0_C_ACC   (w_p_data_ADC0_C_ACC), // [31:0] 
	.o_p_data_ADC0_D_ACC   (w_p_data_ADC0_D_ACC), // [31:0] 
	.o_p_data_ADC1_A_ACC   (w_p_data_ADC1_A_ACC), // [31:0] 
	.o_p_data_ADC1_B_ACC   (w_p_data_ADC1_B_ACC), // [31:0] 
	.o_p_data_ADC1_C_ACC   (w_p_data_ADC1_C_ACC), // [31:0] 
	.o_p_data_ADC1_D_ACC   (w_p_data_ADC1_D_ACC), // [31:0] 
	.o_p_data_ADC2_A_ACC   (w_p_data_ADC2_A_ACC), // [31:0] 
	.o_p_data_ADC2_B_ACC   (w_p_data_ADC2_B_ACC), // [31:0] 
	.o_p_data_ADC2_C_ACC   (w_p_data_ADC2_C_ACC), // [31:0] 
	.o_p_data_ADC2_D_ACC   (w_p_data_ADC2_D_ACC), // [31:0] 
	.o_p_data_ADC3_A_ACC   (w_p_data_ADC3_A_ACC), // [31:0] 
	.o_p_data_ADC3_B_ACC   (w_p_data_ADC3_B_ACC), // [31:0] 
	.o_p_data_ADC3_C_ACC   (w_p_data_ADC3_C_ACC), // [31:0] 
	.o_p_data_ADC3_D_ACC   (w_p_data_ADC3_D_ACC), // [31:0] 
	//}
	
	//// MIN MAX interface //{
	.o_p_data_ADC0_A_MIN   (w_p_data_ADC0_A_MIN),    .o_p_data_ADC0_A_MAX   (w_p_data_ADC0_A_MAX), // [15:0]
	.o_p_data_ADC0_B_MIN   (w_p_data_ADC0_B_MIN),    .o_p_data_ADC0_B_MAX   (w_p_data_ADC0_B_MAX), // [15:0]
	.o_p_data_ADC0_C_MIN   (w_p_data_ADC0_C_MIN),    .o_p_data_ADC0_C_MAX   (w_p_data_ADC0_C_MAX), // [15:0]
	.o_p_data_ADC0_D_MIN   (w_p_data_ADC0_D_MIN),    .o_p_data_ADC0_D_MAX   (w_p_data_ADC0_D_MAX), // [15:0]
	.o_p_data_ADC1_A_MIN   (w_p_data_ADC1_A_MIN),    .o_p_data_ADC1_A_MAX   (w_p_data_ADC1_A_MAX), // [15:0]
	.o_p_data_ADC1_B_MIN   (w_p_data_ADC1_B_MIN),    .o_p_data_ADC1_B_MAX   (w_p_data_ADC1_B_MAX), // [15:0]
	.o_p_data_ADC1_C_MIN   (w_p_data_ADC1_C_MIN),    .o_p_data_ADC1_C_MAX   (w_p_data_ADC1_C_MAX), // [15:0]
	.o_p_data_ADC1_D_MIN   (w_p_data_ADC1_D_MIN),    .o_p_data_ADC1_D_MAX   (w_p_data_ADC1_D_MAX), // [15:0]
	.o_p_data_ADC2_A_MIN   (w_p_data_ADC2_A_MIN),    .o_p_data_ADC2_A_MAX   (w_p_data_ADC2_A_MAX), // [15:0]
	.o_p_data_ADC2_B_MIN   (w_p_data_ADC2_B_MIN),    .o_p_data_ADC2_B_MAX   (w_p_data_ADC2_B_MAX), // [15:0]
	.o_p_data_ADC2_C_MIN   (w_p_data_ADC2_C_MIN),    .o_p_data_ADC2_C_MAX   (w_p_data_ADC2_C_MAX), // [15:0]
	.o_p_data_ADC2_D_MIN   (w_p_data_ADC2_D_MIN),    .o_p_data_ADC2_D_MAX   (w_p_data_ADC2_D_MAX), // [15:0]
	.o_p_data_ADC3_A_MIN   (w_p_data_ADC3_A_MIN),    .o_p_data_ADC3_A_MAX   (w_p_data_ADC3_A_MAX), // [15:0]
	.o_p_data_ADC3_B_MIN   (w_p_data_ADC3_B_MIN),    .o_p_data_ADC3_B_MAX   (w_p_data_ADC3_B_MAX), // [15:0]
	.o_p_data_ADC3_C_MIN   (w_p_data_ADC3_C_MIN),    .o_p_data_ADC3_C_MAX   (w_p_data_ADC3_C_MAX), // [15:0]
	.o_p_data_ADC3_D_MIN   (w_p_data_ADC3_D_MIN),    .o_p_data_ADC3_D_MAX   (w_p_data_ADC3_D_MAX), // [15:0]
	//}
	
	//// FIFO interface //{
	.f_clk   (c_f_clk), // assume 104MHz or 108MHz // fifo reading clock 
	
	// adc0
	.i_fifo_adc0_a_rd_en  (w_fifo_adc0_a_rd_en ), //       
	.o_fifo_adc0_a_dout   (w_fifo_adc0_a_dout  ), // [15:0]
	.o_fifo_adc0_a_full   (w_fifo_adc0_a_full  ), //       
	.o_fifo_adc0_a_empty  (w_fifo_adc0_a_empty ), //       
	.i_fifo_adc0_b_rd_en  (w_fifo_adc0_b_rd_en ), //       
	.o_fifo_adc0_b_dout   (w_fifo_adc0_b_dout  ), // [15:0]
	.o_fifo_adc0_b_full   (w_fifo_adc0_b_full  ), //       
	.o_fifo_adc0_b_empty  (w_fifo_adc0_b_empty ), //       
	.i_fifo_adc0_c_rd_en  (w_fifo_adc0_c_rd_en ), //       
	.o_fifo_adc0_c_dout   (w_fifo_adc0_c_dout  ), // [15:0]
	.o_fifo_adc0_c_full   (w_fifo_adc0_c_full  ), //       
	.o_fifo_adc0_c_empty  (w_fifo_adc0_c_empty ), //       
	.i_fifo_adc0_d_rd_en  (w_fifo_adc0_d_rd_en ), //       
	.o_fifo_adc0_d_dout   (w_fifo_adc0_d_dout  ), // [15:0]
	.o_fifo_adc0_d_full   (w_fifo_adc0_d_full  ), //       
	.o_fifo_adc0_d_empty  (w_fifo_adc0_d_empty ), //       
	// adc1
	.i_fifo_adc1_a_rd_en  (w_fifo_adc1_a_rd_en ), //       
	.o_fifo_adc1_a_dout   (w_fifo_adc1_a_dout  ), // [15:0]
	.o_fifo_adc1_a_full   (w_fifo_adc1_a_full  ), //       
	.o_fifo_adc1_a_empty  (w_fifo_adc1_a_empty ), //       
	.i_fifo_adc1_b_rd_en  (w_fifo_adc1_b_rd_en ), //       
	.o_fifo_adc1_b_dout   (w_fifo_adc1_b_dout  ), // [15:0]
	.o_fifo_adc1_b_full   (w_fifo_adc1_b_full  ), //       
	.o_fifo_adc1_b_empty  (w_fifo_adc1_b_empty ), //       
	.i_fifo_adc1_c_rd_en  (w_fifo_adc1_c_rd_en ), //       
	.o_fifo_adc1_c_dout   (w_fifo_adc1_c_dout  ), // [15:0]
	.o_fifo_adc1_c_full   (w_fifo_adc1_c_full  ), //       
	.o_fifo_adc1_c_empty  (w_fifo_adc1_c_empty ), //       
	.i_fifo_adc1_d_rd_en  (w_fifo_adc1_d_rd_en ), //       
	.o_fifo_adc1_d_dout   (w_fifo_adc1_d_dout  ), // [15:0]
	.o_fifo_adc1_d_full   (w_fifo_adc1_d_full  ), //       
	.o_fifo_adc1_d_empty  (w_fifo_adc1_d_empty ), //       
	// adc2
	.i_fifo_adc2_a_rd_en  (w_fifo_adc2_a_rd_en ), //       
	.o_fifo_adc2_a_dout   (w_fifo_adc2_a_dout  ), // [15:0]
	.o_fifo_adc2_a_full   (w_fifo_adc2_a_full  ), //       
	.o_fifo_adc2_a_empty  (w_fifo_adc2_a_empty ), //       
	.i_fifo_adc2_b_rd_en  (w_fifo_adc2_b_rd_en ), //       
	.o_fifo_adc2_b_dout   (w_fifo_adc2_b_dout  ), // [15:0]
	.o_fifo_adc2_b_full   (w_fifo_adc2_b_full  ), //       
	.o_fifo_adc2_b_empty  (w_fifo_adc2_b_empty ), //       
	.i_fifo_adc2_c_rd_en  (w_fifo_adc2_c_rd_en ), //       
	.o_fifo_adc2_c_dout   (w_fifo_adc2_c_dout  ), // [15:0]
	.o_fifo_adc2_c_full   (w_fifo_adc2_c_full  ), //       
	.o_fifo_adc2_c_empty  (w_fifo_adc2_c_empty ), //       
	.i_fifo_adc2_d_rd_en  (w_fifo_adc2_d_rd_en ), //       
	.o_fifo_adc2_d_dout   (w_fifo_adc2_d_dout  ), // [15:0]
	.o_fifo_adc2_d_full   (w_fifo_adc2_d_full  ), //       
	.o_fifo_adc2_d_empty  (w_fifo_adc2_d_empty ), //       
	// adc3
	.i_fifo_adc3_a_rd_en  (w_fifo_adc3_a_rd_en ), //       
	.o_fifo_adc3_a_dout   (w_fifo_adc3_a_dout  ), // [15:0]
	.o_fifo_adc3_a_full   (w_fifo_adc3_a_full  ), //       
	.o_fifo_adc3_a_empty  (w_fifo_adc3_a_empty ), //       
	.i_fifo_adc3_b_rd_en  (w_fifo_adc3_b_rd_en ), //       
	.o_fifo_adc3_b_dout   (w_fifo_adc3_b_dout  ), // [15:0]
	.o_fifo_adc3_b_full   (w_fifo_adc3_b_full  ), //       
	.o_fifo_adc3_b_empty  (w_fifo_adc3_b_empty ), //       
	.i_fifo_adc3_c_rd_en  (w_fifo_adc3_c_rd_en ), //       
	.o_fifo_adc3_c_dout   (w_fifo_adc3_c_dout  ), // [15:0]
	.o_fifo_adc3_c_full   (w_fifo_adc3_c_full  ), //       
	.o_fifo_adc3_c_empty  (w_fifo_adc3_c_empty ), //       
	.i_fifo_adc3_d_rd_en  (w_fifo_adc3_d_rd_en ), //       
	.o_fifo_adc3_d_dout   (w_fifo_adc3_d_dout  ), // [15:0]
	.o_fifo_adc3_d_full   (w_fifo_adc3_d_full  ), //       
	.o_fifo_adc3_d_empty  (w_fifo_adc3_d_empty ), //       
	

	//}
	
	.valid			()
	///////////////////////////
);

//}


// assignments //{

// output pin assignment
assign ADCx_CNV  =  r_ADCx_CNV ;
assign ADCx_SCK  =  r_ADCx_SCK ;
assign w_adc_cnv = ~w_CNV_B ;
assign w_adc_sck =  w_SCK   ;

// last data 
assign w_ADC_S1_WO = {w_p_data_ADC0_C_pclk, w_p_data_ADC0_D_pclk}; // ADC0 // p_clk
assign w_ADC_S2_WO = {w_p_data_ADC0_A_pclk, w_p_data_ADC0_B_pclk}; // ADC0 // p_clk
assign w_ADC_S3_WO = {w_p_data_ADC1_C_pclk, w_p_data_ADC1_D_pclk}; // ADC1 // p_clk
assign w_ADC_S4_WO = {w_p_data_ADC1_A_pclk, w_p_data_ADC1_B_pclk}; // ADC1 // p_clk
assign w_ADC_S5_WO = {w_p_data_ADC2_C_pclk, w_p_data_ADC2_D_pclk}; // ADC2 // p_clk
assign w_ADC_S6_WO = {w_p_data_ADC2_A_pclk, w_p_data_ADC2_B_pclk}; // ADC2 // p_clk
assign w_ADC_S7_WO = {w_p_data_ADC3_C_pclk, w_p_data_ADC3_D_pclk}; // ADC3 // p_clk
assign w_ADC_S8_WO = {w_p_data_ADC3_A_pclk, w_p_data_ADC3_B_pclk}; // ADC3 // p_clk

// ACC data 
// w_acc_bit_shift_disable : 1 for disable
// w_acc_bit_shift_08_16__ : 0 for 8 bit shift
wire  [15:0]  w_p_data_ADC0_A_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC0_A_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC0_A_ACC[31:16] : w_p_data_ADC0_A_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC0_B_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC0_B_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC0_B_ACC[31:16] : w_p_data_ADC0_B_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC0_C_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC0_C_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC0_C_ACC[31:16] : w_p_data_ADC0_C_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC0_D_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC0_D_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC0_D_ACC[31:16] : w_p_data_ADC0_D_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC1_A_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC1_A_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC1_A_ACC[31:16] : w_p_data_ADC1_A_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC1_B_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC1_B_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC1_B_ACC[31:16] : w_p_data_ADC1_B_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC1_C_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC1_C_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC1_C_ACC[31:16] : w_p_data_ADC1_C_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC1_D_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC1_D_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC1_D_ACC[31:16] : w_p_data_ADC1_D_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC2_A_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC2_A_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC2_A_ACC[31:16] : w_p_data_ADC2_A_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC2_B_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC2_B_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC2_B_ACC[31:16] : w_p_data_ADC2_B_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC2_C_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC2_C_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC2_C_ACC[31:16] : w_p_data_ADC2_C_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC2_D_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC2_D_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC2_D_ACC[31:16] : w_p_data_ADC2_D_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC3_A_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC3_A_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC3_A_ACC[31:16] : w_p_data_ADC3_A_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC3_B_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC3_B_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC3_B_ACC[31:16] : w_p_data_ADC3_B_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC3_C_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC3_C_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC3_C_ACC[31:16] : w_p_data_ADC3_C_ACC[23:8] ;
wire  [15:0]  w_p_data_ADC3_D_ACC_shift = (w_acc_bit_shift_disable)? w_p_data_ADC3_D_ACC[15:0] : (w_acc_bit_shift_08_16__)? w_p_data_ADC3_D_ACC[31:16] : w_p_data_ADC3_D_ACC[23:8] ;
//
assign w_ADC_S1_ACC_WO = {w_p_data_ADC0_C_ACC_shift, w_p_data_ADC0_D_ACC_shift}; // ADC0
assign w_ADC_S2_ACC_WO = {w_p_data_ADC0_A_ACC_shift, w_p_data_ADC0_B_ACC_shift}; // ADC0
assign w_ADC_S3_ACC_WO = {w_p_data_ADC1_C_ACC_shift, w_p_data_ADC1_D_ACC_shift}; // ADC1
assign w_ADC_S4_ACC_WO = {w_p_data_ADC1_A_ACC_shift, w_p_data_ADC1_B_ACC_shift}; // ADC1
assign w_ADC_S5_ACC_WO = {w_p_data_ADC2_C_ACC_shift, w_p_data_ADC2_D_ACC_shift}; // ADC2
assign w_ADC_S6_ACC_WO = {w_p_data_ADC2_A_ACC_shift, w_p_data_ADC2_B_ACC_shift}; // ADC2
assign w_ADC_S7_ACC_WO = {w_p_data_ADC3_C_ACC_shift, w_p_data_ADC3_D_ACC_shift}; // ADC3
assign w_ADC_S8_ACC_WO = {w_p_data_ADC3_A_ACC_shift, w_p_data_ADC3_B_ACC_shift}; // ADC3

// min max data 
assign w_ADC_S1_MIN_WO = {w_p_data_ADC0_C_MIN, w_p_data_ADC0_D_MIN}; // ADC0
assign w_ADC_S2_MIN_WO = {w_p_data_ADC0_A_MIN, w_p_data_ADC0_B_MIN}; // ADC0
assign w_ADC_S3_MIN_WO = {w_p_data_ADC1_C_MIN, w_p_data_ADC1_D_MIN}; // ADC1
assign w_ADC_S4_MIN_WO = {w_p_data_ADC1_A_MIN, w_p_data_ADC1_B_MIN}; // ADC1
assign w_ADC_S5_MIN_WO = {w_p_data_ADC2_C_MIN, w_p_data_ADC2_D_MIN}; // ADC2
assign w_ADC_S6_MIN_WO = {w_p_data_ADC2_A_MIN, w_p_data_ADC2_B_MIN}; // ADC2
assign w_ADC_S7_MIN_WO = {w_p_data_ADC3_C_MIN, w_p_data_ADC3_D_MIN}; // ADC3
assign w_ADC_S8_MIN_WO = {w_p_data_ADC3_A_MIN, w_p_data_ADC3_B_MIN}; // ADC3
// 
assign w_ADC_S1_MAX_WO = {w_p_data_ADC0_C_MAX, w_p_data_ADC0_D_MAX}; // ADC0
assign w_ADC_S2_MAX_WO = {w_p_data_ADC0_A_MAX, w_p_data_ADC0_B_MAX}; // ADC0
assign w_ADC_S3_MAX_WO = {w_p_data_ADC1_C_MAX, w_p_data_ADC1_D_MAX}; // ADC1
assign w_ADC_S4_MAX_WO = {w_p_data_ADC1_A_MAX, w_p_data_ADC1_B_MAX}; // ADC1
assign w_ADC_S5_MAX_WO = {w_p_data_ADC2_C_MAX, w_p_data_ADC2_D_MAX}; // ADC2
assign w_ADC_S6_MAX_WO = {w_p_data_ADC2_A_MAX, w_p_data_ADC2_B_MAX}; // ADC2
assign w_ADC_S7_MAX_WO = {w_p_data_ADC3_C_MAX, w_p_data_ADC3_D_MAX}; // ADC3
assign w_ADC_S8_MAX_WO = {w_p_data_ADC3_A_MAX, w_p_data_ADC3_B_MAX}; // ADC3

// merge 
assign w_ADC_S1_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S1_MIN_WO : w_ADC_S1_WO ;
assign w_ADC_S2_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S2_MIN_WO : w_ADC_S2_WO ;
assign w_ADC_S3_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S3_MIN_WO : w_ADC_S3_WO ;
assign w_ADC_S4_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S4_MIN_WO : w_ADC_S4_WO ;
assign w_ADC_S5_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S5_MIN_WO : w_ADC_S5_WO ;
assign w_ADC_S6_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S6_MIN_WO : w_ADC_S6_WO ;
assign w_ADC_S7_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S7_MIN_WO : w_ADC_S7_WO ;
assign w_ADC_S8_VAL_MIN_WO = (port_en__adc_min)? w_ADC_S8_MIN_WO : w_ADC_S8_WO ;
//
assign w_ADC_S1_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S1_MAX_WO : w_ADC_S1_ACC_WO ;
assign w_ADC_S2_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S2_MAX_WO : w_ADC_S2_ACC_WO ;
assign w_ADC_S3_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S3_MAX_WO : w_ADC_S3_ACC_WO ;
assign w_ADC_S4_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S4_MAX_WO : w_ADC_S4_ACC_WO ;
assign w_ADC_S5_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S5_MAX_WO : w_ADC_S5_ACC_WO ;
assign w_ADC_S6_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S6_MAX_WO : w_ADC_S6_ACC_WO ;
assign w_ADC_S7_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S7_MAX_WO : w_ADC_S7_ACC_WO ;
assign w_ADC_S8_ACC_MAX_WO = (port_en__adc_max)? w_ADC_S8_MAX_WO : w_ADC_S8_ACC_WO ;


// input pin assignment 
assign w_ADC_FLAG_WO[0]   = w_ADC_busy; // not p_clk
assign w_ADC_FLAG_WO[7:1] = 7'b0;
// fifo status
wire w_fifo_adc_full__and_all = w_ADC_FLAG_WO[ 8];
wire w_fifo_adc_full__or__all = w_ADC_FLAG_WO[ 9];
wire w_fifo_adc_empty_and_all = w_ADC_FLAG_WO[10];
wire w_fifo_adc_empty_or__all = w_ADC_FLAG_WO[11];
//
assign w_ADC_FLAG_WO[ 8]  = w_fifo_adc0_a_full &
							w_fifo_adc0_b_full &
							w_fifo_adc0_c_full &
							w_fifo_adc0_d_full &
							w_fifo_adc1_a_full &
							w_fifo_adc1_b_full &
							w_fifo_adc1_c_full &
							w_fifo_adc1_d_full &
							w_fifo_adc2_a_full &
							w_fifo_adc2_b_full &
							w_fifo_adc2_c_full &
							w_fifo_adc2_d_full &
							w_fifo_adc3_a_full &
							w_fifo_adc3_b_full &
							w_fifo_adc3_c_full &
							w_fifo_adc3_d_full ; // fifo full and_all
assign w_ADC_FLAG_WO[ 9]  = w_fifo_adc0_a_full |
							w_fifo_adc0_b_full |
							w_fifo_adc0_c_full |
							w_fifo_adc0_d_full |
							w_fifo_adc1_a_full |
							w_fifo_adc1_b_full |
							w_fifo_adc1_c_full |
							w_fifo_adc1_d_full |
							w_fifo_adc2_a_full |
							w_fifo_adc2_b_full |
							w_fifo_adc2_c_full |
							w_fifo_adc2_d_full |
							w_fifo_adc3_a_full |
							w_fifo_adc3_b_full |
							w_fifo_adc3_c_full |
							w_fifo_adc3_d_full ; // fifo full or_all
assign w_ADC_FLAG_WO[10]  = w_fifo_adc0_a_empty &
							w_fifo_adc0_b_empty &
							w_fifo_adc0_c_empty &
							w_fifo_adc0_d_empty &
							w_fifo_adc1_a_empty &
							w_fifo_adc1_b_empty &
							w_fifo_adc1_c_empty &
							w_fifo_adc1_d_empty &
							w_fifo_adc2_a_empty &
							w_fifo_adc2_b_empty &
							w_fifo_adc2_c_empty &
							w_fifo_adc2_d_empty &
							w_fifo_adc3_a_empty &
							w_fifo_adc3_b_empty &
							w_fifo_adc3_c_empty &
							w_fifo_adc3_d_empty ; // fifo empty and_all
assign w_ADC_FLAG_WO[11]  = w_fifo_adc0_a_empty |
							w_fifo_adc0_b_empty |
							w_fifo_adc0_c_empty |
							w_fifo_adc0_d_empty |
							w_fifo_adc1_a_empty |
							w_fifo_adc1_b_empty |
							w_fifo_adc1_c_empty |
							w_fifo_adc1_d_empty |
							w_fifo_adc2_a_empty |
							w_fifo_adc2_b_empty |
							w_fifo_adc2_c_empty |
							w_fifo_adc2_d_empty |
							w_fifo_adc3_a_empty |
							w_fifo_adc3_b_empty |
							w_fifo_adc3_c_empty |
							w_fifo_adc3_d_empty ; // fifo empty or_all
//
assign w_ADC_FLAG_WO[12]  =  r_ADC0_DCO_ ;
assign w_ADC_FLAG_WO[13]  =  r_ADC1_DCO_ ;
assign w_ADC_FLAG_WO[14]  =  r_ADC2_DCO_ ;
assign w_ADC_FLAG_WO[15]  =  r_ADC3_DCO_ ;
//
assign w_ADC_FLAG_WO[16+ 0]  =  r_ADC0_SDOA ;
assign w_ADC_FLAG_WO[16+ 1]  =  r_ADC0_SDOB ;
assign w_ADC_FLAG_WO[16+ 2]  =  r_ADC0_SDOC ;
assign w_ADC_FLAG_WO[16+ 3]  =  r_ADC0_SDOD ;
assign w_ADC_FLAG_WO[16+ 4]  =  r_ADC1_SDOA ;
assign w_ADC_FLAG_WO[16+ 5]  =  r_ADC1_SDOB ;
assign w_ADC_FLAG_WO[16+ 6]  =  r_ADC1_SDOC ;
assign w_ADC_FLAG_WO[16+ 7]  =  r_ADC1_SDOD ;
assign w_ADC_FLAG_WO[16+ 8]  =  r_ADC2_SDOA ;
assign w_ADC_FLAG_WO[16+ 9]  =  r_ADC2_SDOB ;
assign w_ADC_FLAG_WO[16+10]  =  r_ADC2_SDOC ;
assign w_ADC_FLAG_WO[16+11]  =  r_ADC2_SDOD ;
assign w_ADC_FLAG_WO[16+12]  =  r_ADC3_SDOA ;
assign w_ADC_FLAG_WO[16+13]  =  r_ADC3_SDOB ;
assign w_ADC_FLAG_WO[16+14]  =  r_ADC3_SDOC ;
assign w_ADC_FLAG_WO[16+15]  =  r_ADC3_SDOD ;

//
assign w_ADC_TRIG_TO[0]    = w_ADC_done_to_pclk; // p_clk
assign w_ADC_TRIG_TO[31:1] = 31'b0;

//}

//}


/* TODO: TP assignment  */ //{
// assign TP4 = 1'b0;
assign TP_out[4]   = 1'b0 ; 
assign TP_tri[4]   = 1'b1 ; 
// assign TP5 = w_busy_DAC_update; 
assign TP_out[5]   = w_busy_DAC_update ; 
assign TP_tri[5]   = 1'b1 ; 
// assign TP6 = w_ADC_busy_pclk  ; 
assign TP_out[6]   = w_ADC_busy_pclk ; 
assign TP_tri[6]   = 1'b1 ; 
// assign TP7 = w_busy_SPI_frame ; 
assign TP_out[7]   = w_busy_SPI_frame ; 
assign TP_tri[7]   = 1'b1 ; 

//}


/* TODO: TRIG_IO from MTH and EXT_TRIG IO from SMB port */ //{  

// ports for TRIG_IO //{
wire  M_TRIG      ;
wire  M_PRE_TRIG  ;
wire  M_BUSY_B_OUT;
IBUF ibuf__M_TRIG_______inst (.I(i_B35_L18P      ), .O(M_TRIG        ) );
IBUF ibuf__M_PRE_TRIG___inst (.I(i_B35_L18N      ), .O(M_PRE_TRIG    ) );
OBUF obuf__M_BUSY_B_OUT_inst (.O(o_B13_L11P_SRCC ), .I(M_BUSY_B_OUT  ) );
//}

// ports for EXT_TRIG //{
wire  EXT_TRIG       ;
wire  EXT_BUSY_B_OUT ;
IBUFDS   ibufds__EXT_TRIG_inst (.I(i_B13D_L14P_SRCC), .IB(i_B13D_L14N_SRCC), .O(EXT_TRIG) );
OBUF obuf__EXT_BUSY_B_OUT_inst (.O(o_B13_L17P      ), .I(EXT_BUSY_B_OUT  ) ); // 
//}


// module for EXT_TRIG //{
wire [31:0] ext_trig_con_wi___sspi; // control from sspi adrs 0x050
wire [31:0] ext_trig_para_wi__sspi; // control from sspi adrs 0x054
wire [31:0] ext_trig_aux_wi___sspi; // control from sspi adrs 0x058
wire [31:0] ext_trig_ti_______sspi; // control from sspi adrs 0x110

wire w_EXT_TRIG_en      = (~w_EXT_TRIG_TI[0]) & (~ext_trig_ti_______sspi[0]) ; 

wire w_PIN_trig_disable = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_CON_WI[8] : ext_trig_con_wi___sspi[8] ;

wire w_M_TRIG_PIN       ; // sampled input 
wire w_M_PRE_TRIG_PIN   ; // sampled input 
wire w_AUX_TRIG_PIN     ; // sampled input 

wire w_M_TRIG_SW        = (w_EXT_TRIG_TI[1]) | (ext_trig_ti_______sspi[1]) ;
wire w_M_PRE_TRIG_SW    = (w_EXT_TRIG_TI[2]) | (ext_trig_ti_______sspi[2]) ;
wire w_AUX_TRIG_SW      = (w_EXT_TRIG_TI[3]) | (ext_trig_ti_______sspi[3]) ;

wire [2:0]  w_conf_M_TRIG      = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_CON_WI[18:16] : ext_trig_con_wi___sspi[18:16] ; // [2:0]
wire [2:0]  w_conf_M_PRE_TRIG  = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_CON_WI[22:20] : ext_trig_con_wi___sspi[22:20] ; // [2:0]
wire [2:0]  w_conf_AUX         = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_CON_WI[26:24] : ext_trig_con_wi___sspi[26:24] ; // [2:0]

wire [15:0] w_count_delay_trig_spio = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_AUX_WI[15:0]   : ext_trig_aux_wi___sspi[15:0]  ; // [15:0]
wire [15:0] w_count_delay_trig_dac  = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_PARA_WI[31:16] : ext_trig_para_wi__sspi[31:16] ; // [15:0]
wire [15:0] w_count_delay_trig_adc  = (w_EXT_TRIG_CON_WI[0])? w_EXT_TRIG_PARA_WI[15: 0] : ext_trig_para_wi__sspi[15: 0] ; // [15:0]

wire w_spio_busy_cowork;
wire w_dac_busy_cowork ;
wire w_adc_busy_cowork ;

wire w_spio_trig_cowork; // to trig-in for spio
wire w_dac_trig_cowork ; // to trig-in for dac
wire w_adc_trig_cowork ; // to trig-in for adc

//
control_ext_trig  control_ext_trig_inst (
	.clk                    (sys_clk), // 10MHz
	.reset_n                (reset_n & w_EXT_TRIG_en & (~w_HW_reset)),
	//
	.i_PIN_trig_disable     (w_PIN_trig_disable), // pin disable
	//
	.i_M_TRIG_PIN           (w_M_TRIG_PIN      ), //
	.i_M_PRE_TRIG_PIN       (w_M_PRE_TRIG_PIN  ), //
	.i_AUX_TRIG_PIN         (w_AUX_TRIG_PIN    ), //
	//
	.i_M_TRIG_SW            (w_M_TRIG_SW       ), //
	.i_M_PRE_TRIG_SW        (w_M_PRE_TRIG_SW   ), //
	.i_AUX_TRIG_SW          (w_AUX_TRIG_SW     ), //
	//
	.i_conf_M_TRIG          (w_conf_M_TRIG     ), // [2:0] // M_TRIG     connectivity to {SPIO,DAC,ADC}
	.i_conf_M_PRE_TRIG      (w_conf_M_PRE_TRIG ), // [2:0] // M_PRE_TRIG connectivity to {SPIO,DAC,ADC}
	.i_conf_AUX             (w_conf_AUX        ), // [2:0] // AUX        connectivity to {SPIO,DAC,ADC}
	//
	.i_count_delay_trig_spio   (w_count_delay_trig_spio), // [15:0] // based on 100kHz or 10us
	.i_count_delay_trig_dac    (w_count_delay_trig_dac ), // [15:0] // based on 100kHz or 10us
	.i_count_delay_trig_adc    (w_count_delay_trig_adc ), // [15:0] // based on 100kHz or 10us
	//                         
	.o_spio_busy_cowork        (w_spio_busy_cowork), // 
	.o_dac_busy_cowork         (w_dac_busy_cowork ), // 
	.o_adc_busy_cowork         (w_adc_busy_cowork ), // 
	//                         
	.o_spio_trig_cowork        (w_spio_trig_cowork), // delayed trigger // also done
	.o_dac_trig_cowork         (w_dac_trig_cowork ), // delayed trigger // also done
	.o_adc_trig_cowork         (w_adc_trig_cowork ), // delayed trigger // also done
	//
	.valid                  ()
);

//}


// assignments //{

//// sample TRIG_IO //{
(* keep = "true" *) reg [1:0] r_M_TRIG      ; // test sampling
(* keep = "true" *) reg [1:0] r_M_PRE_TRIG  ; // test sampling
(* keep = "true" *) reg       r_M_BUSY_B_OUT; // test output 
//
wire w_M_BUSY_B_OUT; //
//
assign M_BUSY_B_OUT = r_M_BUSY_B_OUT;
//
always @(posedge sys_clk, negedge reset_n)
	if (!reset_n) begin
		r_M_TRIG        <= 2'b0;
		r_M_PRE_TRIG    <= 2'b0;
		r_M_BUSY_B_OUT  <= 1'b1;
	end
	else begin
		r_M_TRIG        <=  {r_M_TRIG[0]     , M_TRIG     };
		r_M_PRE_TRIG    <=  {r_M_PRE_TRIG[0] , M_PRE_TRIG };
		//r_M_BUSY_B_OUT  <= ~( (r_M_TRIG[0]) | (r_M_PRE_TRIG[0]) );
		r_M_BUSY_B_OUT  <= w_M_BUSY_B_OUT;
	end	
//}

//// sample EXT_TRIG //{
(* keep = "true" *) reg [1:0] r_EXT_TRIG      ; // test sampling
(* keep = "true" *) reg       r_EXT_BUSY_B_OUT; // test output 
//
wire w_EXT_BUSY_B_OUT; //
//
assign EXT_BUSY_B_OUT = r_EXT_BUSY_B_OUT;
//
always @(posedge sys_clk, negedge reset_n)
	if (!reset_n) begin
		r_EXT_TRIG        <= 2'b0;
		r_EXT_BUSY_B_OUT  <= 1'b1;
	end
	else begin
		r_EXT_TRIG        <=  {r_EXT_TRIG[0], EXT_TRIG};
		//r_EXT_BUSY_B_OUT  <= ~(r_EXT_TRIG[0]);
		r_EXT_BUSY_B_OUT  <= w_EXT_BUSY_B_OUT;
	end	
//}


// sampled input 
assign w_M_TRIG_PIN      = r_M_TRIG[0]     & w_EXT_TRIG_CON_WI[1];
assign w_M_PRE_TRIG_PIN  = r_M_PRE_TRIG[0] & w_EXT_TRIG_CON_WI[2];
assign w_AUX_TRIG_PIN    = r_EXT_TRIG[0]   & w_EXT_TRIG_CON_WI[3];

// busy pin out 
assign w_M_BUSY_B_OUT   = ~(w_adc_busy_cowork | w_dac_busy_cowork | w_spio_busy_cowork);
assign w_EXT_BUSY_B_OUT = ~(w_adc_busy_cowork | w_dac_busy_cowork | w_spio_busy_cowork);

// wire out : share with w_TEST_FLAG_WO
assign w_TEST_FLAG_WO[31:24] = {r_EXT_TRIG[0], r_EXT_BUSY_B_OUT, w_spio_busy_cowork, w_dac_busy_cowork, 
							    w_adc_busy_cowork, r_M_TRIG[0], r_M_PRE_TRIG[0], r_M_BUSY_B_OUT}; 

// trig out 
assign w_EXT_TRIG_TO[0] = w_spio_trig_cowork;
assign w_EXT_TRIG_TO[1] = w_dac_trig_cowork ;
assign w_EXT_TRIG_TO[2] = w_adc_trig_cowork ;
assign w_EXT_TRIG_TO[31:3] = 29'b0;

// trig cowork 
assign w_spio_trig_cowork__ext = w_spio_trig_cowork;
assign w_dac_trig_cowork__ext  = w_dac_trig_cowork ;
assign w_adc_trig_cowork__ext  = w_adc_trig_cowork ;


//}

//}


/* TODO: LAN port selection */ //{  

// ports for LAN //{

//  wire  LAN_INT_B;
//  wire  LAN_RST_B = 1'b1; // test 
//  wire  LAN_MISO ;
//  wire  LAN_CS_B  = 1'b1; // test 
//  wire  LAN_SCLK  = 1'b0; // test 
//  wire  LAN_MOSI  = 1'b0; // test 
//  IBUF ibuf__LAN_INT_B_inst (.I(i_B13_L13P_MRCC ), .O(LAN_INT_B  ) ); //
//  OBUF obuf__LAN_RST_B_inst (.O(o_B13_L15P      ), .I(LAN_RST_B  ) ); // 
//  IBUF ibuf__LAN_MISO__inst (.I(i_B13_L15N      ), .O(LAN_MISO   ) ); //
//  OBUF obuf__LAN_CS_B__inst (.O(o_B13_L6P       ), .I(LAN_CS_B   ) ); // 
//  OBUF obuf__LAN_SCLK__inst (.O(o_B13_L6N       ), .I(LAN_SCLK   ) ); // 
//  OBUF obuf__LAN_MOSI__inst (.O(o_B13_L11N_SRCC ), .I(LAN_MOSI   ) ); // 

//}

// LAN port selection for EP :
//  0 for LAN-on-FPGA-module; 1 for LAN-on-BASE-board
//assign select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD = w_TEST_CON_WI[16];
assign select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD = w_MCS_SETUP_WI[10];


//}


//-------------------------------------------------------//

/* TODO: Master_SPI emulation for Slave_SPI */ //{



// module //{

wire w_SSPI_TEST_trig_reset = w_SSPI_TEST_TI[0];
assign w_SSPI_TEST_TO[0]    = w_SSPI_TEST_trig_reset;
//
wire  w_SSPI_TEST_trig_init = w_SSPI_TEST_TI[1];
wire  w_SSPI_TEST_done_init ;
assign w_SSPI_TEST_mode_en = w_SSPI_TEST_done_init;
assign w_SSPI_TEST_TO[1]   = w_SSPI_TEST_done_init;
//
wire  w_SSPI_TEST_trig_frame = w_SSPI_TEST_TI[2];
wire  w_SSPI_TEST_done_frame;
assign w_SSPI_TEST_TO[2]   = w_SSPI_TEST_done_frame;
//
assign w_SSPI_TEST_TO[31:3] = 29'b0;

//
wire  [ 5:0] w_SSPI_frame_data_C = w_SSPI_TEST_WI[31:26];
wire  [ 9:0] w_SSPI_frame_data_A = w_SSPI_TEST_WI[25:16];
wire  [15:0] w_SSPI_frame_data_D = w_SSPI_TEST_WI[15: 0];
//
wire  [15:0] w_SSPI_frame_data_B;
wire  [15:0] w_SSPI_frame_data_E;
assign w_SSPI_TEST_WO[15:0] = w_SSPI_frame_data_B[15:0];

wire  w_SSPI_TEST_SS_B   ;
wire  w_SSPI_TEST_MCLK   ;
wire  w_SSPI_TEST_SCLK   ;
wire  w_SSPI_TEST_MOSI   ;
wire  w_SSPI_TEST_MISO   ;
wire  w_SSPI_TEST_MISO_EN;

//
master_spi_mth_brd  master_spi_mth_brd__inst (
	.clk     (base_sspi_clk), // 104MHz
	.reset_n (reset_n & (~w_SSPI_TEST_trig_reset)),
	
	// control 
	.i_trig_init    (w_SSPI_TEST_trig_init ), // 
	.o_done_init    (w_SSPI_TEST_done_init ), // to be used for monitoring test mode 
	.i_trig_frame   (w_SSPI_TEST_trig_frame), // 
	.o_done_frame   (w_SSPI_TEST_done_frame), // 

	// frame data 
	.i_frame_data_C (w_SSPI_frame_data_C), // [ 5:0] // control  data on MOSI
	.i_frame_data_A (w_SSPI_frame_data_A), // [ 9:0] // address  data on MOSI
	.i_frame_data_D (w_SSPI_frame_data_D), // [15:0] // register data on MOSI
	//
	.o_frame_data_B (w_SSPI_frame_data_B), // [15:0] // readback data on MISO, low  16 bits
	.o_frame_data_E (w_SSPI_frame_data_E), // [15:0] // readback data on MISO, high 16 bits
	
	// IO 
	.o_SS_B    (w_SSPI_TEST_SS_B   ),
	.o_MCLK    (w_SSPI_TEST_MCLK   ), // sclk master out 
	.i_SCLK    (w_SSPI_TEST_SCLK   ), // sclk slave out
	.o_MOSI    (w_SSPI_TEST_MOSI   ),
	.i_MISO    (w_SSPI_TEST_MISO   ),
	.i_MISO_EN (w_SSPI_TEST_MISO_EN),
	
	.valid  ()
); 
//}

//}

//-------------------------------------------------------//

/* TODO: Slave_SPI : from Mother board */ //{

// ports for Slave SPI //{

//// mux M0 with test module : w_SSPI_TEST_mode_en //$$ //{
wire  M0_SPI_CS_B_BUF;
wire  M0_SPI_CLK     ;
wire  M0_SPI_SCLK    ; //$$ REV2
wire  M0_SPI_MOSI    ;
wire  M0_SPI_MISO    ;
wire  M0_SPI_MISO_EN ;

//
//IBUF ibuf__M0_SPI_CS_B_BUF_inst (.I(i_B34_L2P       ), .O(M0_SPI_CS_B_BUF  ) ); //
//IBUF ibuf__M0_SPI_CLK______inst (.I(i_B34_L2N       ), .O(M0_SPI_CLK       ) ); //
//OBUF obuf__M0_SPI_SCLK_____inst (.O(o_B34_L1P       ), .I(M0_SPI_SCLK      ) ); //$$ REV2
//IBUF ibuf__M0_SPI_MOSI_____inst (.I(i_B34_L4P       ), .O(M0_SPI_MOSI      ) ); //
//OBUF obuf__M0_SPI_MISO_____inst (.O(o_B34_L4N       ), .I(M0_SPI_MISO      ) ); // 
//OBUF obuf__M0_SPI_MISO_EN__inst (.O(o_B34_L24P      ), .I(M0_SPI_MISO_EN   ) ); //$$ o_B34_L1P --> o_B34_L24P //$$ REV2

wire  w_B34_L2P  ;
wire  w_B34_L2N  ;
wire  w_B34_L1P  ;
wire  w_B34_L4P  ;
wire  w_B34_L4N  ;
wire  w_B34_L24P ;

IBUF ibuf__M0_SPI_CS_B_BUF_inst (.I(i_B34_L2P       ), .O(w_B34_L2P  ) ); //
IBUF ibuf__M0_SPI_CLK______inst (.I(i_B34_L2N       ), .O(w_B34_L2N  ) ); //
OBUF obuf__M0_SPI_SCLK_____inst (.O(o_B34_L1P       ), .I(w_B34_L1P  ) ); //$$ REV2
IBUF ibuf__M0_SPI_MOSI_____inst (.I(i_B34_L4P       ), .O(w_B34_L4P  ) ); //
OBUF obuf__M0_SPI_MISO_____inst (.O(o_B34_L4N       ), .I(w_B34_L4N  ) ); // 
OBUF obuf__M0_SPI_MISO_EN__inst (.O(o_B34_L24P      ), .I(w_B34_L24P ) ); //$$ o_B34_L1P --> o_B34_L24P //$$ REV2

assign M0_SPI_CS_B_BUF = (~w_SSPI_TEST_mode_en)? w_B34_L2P      : w_SSPI_TEST_SS_B ; // w_SSPI_TEST_SS_B   
assign M0_SPI_CLK      = (~w_SSPI_TEST_mode_en)? w_B34_L2N      : w_SSPI_TEST_MCLK ; // w_SSPI_TEST_MCLK   
assign w_B34_L1P       = (~w_SSPI_TEST_mode_en)? M0_SPI_SCLK    : 1'b1             ; // w_SSPI_TEST_SCLK   
assign M0_SPI_MOSI     = (~w_SSPI_TEST_mode_en)? w_B34_L4P      : w_SSPI_TEST_MOSI ; // w_SSPI_TEST_MOSI   
assign w_B34_L4N       = (~w_SSPI_TEST_mode_en)? M0_SPI_MISO    : 1'b1             ; // w_SSPI_TEST_MISO   
assign w_B34_L24P      = (~w_SSPI_TEST_mode_en)? M0_SPI_MISO_EN : 1'b1             ; // w_SSPI_TEST_MISO_EN

//w_SSPI_TEST_SS_B   
//w_SSPI_TEST_MCLK   
assign w_SSPI_TEST_SCLK    = (w_SSPI_TEST_mode_en)? M0_SPI_SCLK    : 1'b1 ;
//w_SSPI_TEST_MOSI   
assign w_SSPI_TEST_MISO    = (w_SSPI_TEST_mode_en)? M0_SPI_MISO    : 1'b1 ;
assign w_SSPI_TEST_MISO_EN = (w_SSPI_TEST_mode_en)? M0_SPI_MISO_EN : 1'b0 ;

//}

//// M1 //{
wire  M1_SPI_CS_B_BUF;
wire  M1_SPI_CLK     ;
wire  M1_SPI_SCLK    ; //$$ REV2
wire  M1_SPI_MOSI    ;
wire  M1_SPI_MISO    ;
wire  M1_SPI_MISO_EN ;
IBUF ibuf__M1_SPI_CS_B_BUF_inst (.I(i_B34_L1N       ), .O(M1_SPI_CS_B_BUF  ) ); //
IBUF ibuf__M1_SPI_CLK______inst (.I(i_B34_L7P       ), .O(M1_SPI_CLK       ) ); //
OBUF obuf__M1_SPI_SCLK_____inst (.O(o_B34_L12N_MRCC ), .I(M1_SPI_SCLK      ) ); //$$ REV2
IBUF ibuf__M1_SPI_MOSI_____inst (.I(i_B34_L7N       ), .O(M1_SPI_MOSI      ) ); //
OBUF obuf__M1_SPI_MISO_____inst (.O(o_B34_L12P_MRCC ), .I(M1_SPI_MISO      ) ); // 
OBUF obuf__M1_SPI_MISO_EN__inst (.O(o_B34_L24N      ), .I(M1_SPI_MISO_EN   ) ); //$$ o_B34_L12N_MRCC --> o_B34_L24N //$$ REV2

//}

//}

// modules //{
(* keep = "true" *) wire w_M0_SPI_CS_B_BUF;
(* keep = "true" *) wire w_M0_SPI_CLK     ;
(* keep = "true" *) wire w_M0_SPI_MOSI    ;
(* keep = "true" *) wire w_M0_SPI_MISO    ;
(* keep = "true" *) wire w_M0_SPI_MISO_EN ;
//
(* keep = "true" *) wire w_M1_SPI_CS_B_BUF;
(* keep = "true" *) wire w_M1_SPI_CLK     ;
(* keep = "true" *) wire w_M1_SPI_MOSI    ;
(* keep = "true" *) wire w_M1_SPI_MISO    ;
(* keep = "true" *) wire w_M1_SPI_MISO_EN ;
//
wire [15:0] w_M0_cnt_sspi_cs;
wire [15:0] w_M1_cnt_sspi_cs;

//// serial address:
wire [31:0] w_M0_port_wi_sadrs_h000; // SW_BUILD_ID_WI		0x000	wi00
wire [31:0] w_M0_port_wi_sadrs_h004; // TEST_CON_WI			0x004	wi01 //$$ not used in SSPI
wire [31:0] w_M0_port_wi_sadrs_h008; // SSPI_CON_WI			0x008	wi02
wire [31:0] w_M0_port_wi_sadrs_h00C; // RNET_CON_WI			0x00C	wi03
wire [31:0] w_M0_port_wi_sadrs_h010; // SPIO_FDAT_WI		0x010	wi04
wire [31:0] w_M0_port_wi_sadrs_h014; // SPIO_CON_WI			0x014	wi05
wire [31:0] w_M0_port_wi_sadrs_h018; // DAC_CON_WI			0x018	wi06
//
wire [31:0] w_M0_port_wi_sadrs_h060; // MHVSU_DAC	DAC_S1_WI	0x060	wi18	write DAC buffer data.	={S1_DAC_CH2[15:0], S1_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h064; // MHVSU_DAC	DAC_S2_WI	0x064	wi19	write DAC buffer data.	={S2_DAC_CH2[15:0], S2_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h068; // MHVSU_DAC	DAC_S3_WI	0x068	wi1A	write DAC buffer data.	={S3_DAC_CH2[15:0], S3_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h06C; // MHVSU_DAC	DAC_S4_WI	0x06C	wi1B	write DAC buffer data.	={S4_DAC_CH2[15:0], S4_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h070; // MHVSU_DAC	DAC_S5_WI	0x070	wi1C	write DAC buffer data.	={S5_DAC_CH2[15:0], S5_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h074; // MHVSU_DAC	DAC_S6_WI	0x074	wi1D	write DAC buffer data.	={S6_DAC_CH2[15:0], S6_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h078; // MHVSU_DAC	DAC_S7_WI	0x078	wi1E	write DAC buffer data.	={S7_DAC_CH2[15:0], S7_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wi_sadrs_h07C; // MHVSU_DAC	DAC_S8_WI	0x07C	wi1F	write DAC buffer data.	={S8_DAC_CH2[15:0], S8_DAC_CH1[15:0]}	
//
wire [31:0] w_M0_port_wi_sadrs_h01C; // ADC_CON_WI		0x01C			wi07
wire [31:0] w_M0_port_wi_sadrs_h040; // ADC_PAR_WI		0x040 			wi10
//
wire [31:0] w_M0_port_wi_sadrs_h048; // MEM_FDAT_WI		0x048	wi12 //$$
wire [31:0] w_M0_port_wi_sadrs_h04C; // MEM_WI			0x04C	wi13 //$$
wire [31:0] w_M0_port_wi_sadrs_h050; // wire [31:0] ext_trig_con_wi___sspi; // control from sspi adrs 0x050
wire [31:0] w_M0_port_wi_sadrs_h054; // wire [31:0] ext_trig_para_wi__sspi; // control from sspi adrs 0x054
wire [31:0] w_M0_port_wi_sadrs_h058; // wire [31:0] ext_trig_aux_wi___sspi; // control from sspi adrs 0x058
//
wire [31:0] w_M0_port_wo_sadrs_h080 = w_FPGA_IMAGE_ID_WO; // FPGA_IMAGE_ID_WO	0x080	wo20
wire [31:0] w_M0_port_wo_sadrs_h084 = w_TEST_FLAG_WO    ; // TEST_FLAG_WO		0x084	wo21
wire [31:0] w_M0_port_wo_sadrs_h088 = w_SSPI_FLAG_WO    ; // SSPI_FLAG_WO		0x088	wo22
wire [31:0] w_M0_port_wo_sadrs_h08C = w_MON_XADC_WO     ; // MON_XADC_WO		0x08C	wo23
wire [31:0] w_M0_port_wo_sadrs_h090 = w_MON_GP_WO       ; // MON_GP_WO			0x090	wo24
wire [31:0] w_M0_port_wo_sadrs_h094 = w_SPIO_FLAG_WO    ; // SPIO_FLAG_WO		0x094	wo25
wire [31:0] w_M0_port_wo_sadrs_h098 = w_DAC_FLAG_WO     ; // DAC_FLAG_WO		0x098	wo26
//
wire [31:0] w_M0_port_wo_sadrs_h380 = 32'h33AA_CC55     ; // SSPI_TEST_OUT		0x380	NA  // known pattern
wire [31:0] w_M0_port_wo_sadrs_h384 = w_SSPI_BD_STAT_WO           ;
wire [31:0] w_M0_port_wo_sadrs_h388 = w_SSPI_CNT_CS_M0_WO         ;
wire [31:0] w_M0_port_wo_sadrs_h38C = w_SSPI_CNT_CS_M1_WO         ;
wire [31:0] w_M0_port_wo_sadrs_h390 = w_SSPI_CNT_ADC_FIFO_IN_WO   ;
wire [31:0] w_M0_port_wo_sadrs_h394 = w_SSPI_CNT_ADC_TRIG_WO  ;
wire [31:0] w_M0_port_wo_sadrs_h398 = w_SSPI_CNT_SPIO_FRM_TRIG_WO ;
wire [31:0] w_M0_port_wo_sadrs_h39C = w_SSPI_CNT_DAC_TRIG_WO  ;
//
wire [31:0] w_M0_port_wo_sadrs_h0E0 = w_DAC_S1_WO ; // MHVSU_DAC	DAC_S1_WO	0x0E0	wo38	read DAC buffer data.	={S1_DAC_CH2[15:0], S1_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0E4 = w_DAC_S2_WO ; // MHVSU_DAC	DAC_S2_WO	0x0E4	wo39	read DAC buffer data.	={S2_DAC_CH2[15:0], S2_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0E8 = w_DAC_S3_WO ; // MHVSU_DAC	DAC_S3_WO	0x0E8	wo3A	read DAC buffer data.	={S3_DAC_CH2[15:0], S3_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0EC = w_DAC_S4_WO ; // MHVSU_DAC	DAC_S4_WO	0x0EC	wo3B	read DAC buffer data.	={S4_DAC_CH2[15:0], S4_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0F0 = w_DAC_S5_WO ; // MHVSU_DAC	DAC_S5_WO	0x0F0	wo3C	read DAC buffer data.	={S5_DAC_CH2[15:0], S5_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0F4 = w_DAC_S6_WO ; // MHVSU_DAC	DAC_S6_WO	0x0F4	wo3D	read DAC buffer data.	={S6_DAC_CH2[15:0], S6_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0F8 = w_DAC_S7_WO ; // MHVSU_DAC	DAC_S7_WO	0x0F8	wo3E	read DAC buffer data.	={S7_DAC_CH2[15:0], S7_DAC_CH1[15:0]}	
wire [31:0] w_M0_port_wo_sadrs_h0FC = w_DAC_S8_WO ; // MHVSU_DAC	DAC_S8_WO	0x0FC	wo3F	read DAC buffer data.	={S8_DAC_CH2[15:0], S8_DAC_CH1[15:0]}
//
wire [31:0] w_M0_port_wo_sadrs_h09C = w_ADC_FLAG_WO ; // ADC_FLAG_WO		0x09C			wo27
//
wire [31:0] w_M0_port_wo_sadrs_h0A0 = w_ADC_S1_ACC_MAX_WO ; // ADC_Sn_WO		0x0A0~0x0BC		wo28~wo2F
wire [31:0] w_M0_port_wo_sadrs_h0A4 = w_ADC_S2_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0A8 = w_ADC_S3_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0AC = w_ADC_S4_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0B0 = w_ADC_S5_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0B4 = w_ADC_S6_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0B8 = w_ADC_S7_ACC_MAX_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0BC = w_ADC_S8_ACC_MAX_WO ;
//
wire [31:0] w_M0_port_wo_sadrs_h0C0 = w_ADC_S1_VAL_MIN_WO ; // ADC_Sn_WO		0x0C0~0x0DC		wo30~wo37
wire [31:0] w_M0_port_wo_sadrs_h0C4 = w_ADC_S2_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0C8 = w_ADC_S3_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0CC = w_ADC_S4_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0D0 = w_ADC_S5_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0D4 = w_ADC_S6_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0D8 = w_ADC_S7_VAL_MIN_WO ;
wire [31:0] w_M0_port_wo_sadrs_h0DC = w_ADC_S8_VAL_MIN_WO ;
//
wire [31:0] w_M0_port_ti_sadrs_h104; // TEST_TI				0x104	ti41
wire [31:0] w_M0_port_ti_sadrs_h114; // SPIO_TRIG_TI		0x114	ti45
wire [31:0] w_M0_port_ti_sadrs_h118; // DAC_TRIG_TI			0x118	ti46
wire [31:0] w_M0_port_ti_sadrs_h11C; // ADC_TRIG_TI		0x11C			ti47 // base_adc_clk --> p_adc_clk
wire [31:0] w_M0_port_ti_sadrs_h110; // wire [31:0] ext_trig_ti_______sspi; // control from sspi adrs 0x110
wire [31:0] w_M0_port_ti_sadrs_h14C; // MEM_TI	0x14C	ti53 // sys_clk //$$
//
wire [31:0] w_M0_port_to_sadrs_h190 = w_EXT_TRIG_TO     ; // EXT_TRIG_TO	0x190	to64 // sys_clk //$$
wire [31:0] w_M0_port_to_sadrs_h194 = w_SPIO_TRIG_TO    ; // SPIO_TRIG_TO	0x194	to65
wire [31:0] w_M0_port_to_sadrs_h198 = w_DAC_TRIG_TO     ; // DAC_TRIG_TO	0x198	to66
wire [31:0] w_M0_port_to_sadrs_h19C = w_ADC_TRIG_TO     ; // ADC_TRIG_TO	0x19C	to67 // base_adc_clk --> p_adc_clk
wire [31:0] w_M0_port_to_sadrs_h1CC = w_MEM_TO          ; // MEM_TO			0x1CC	to73 // sys_clk //$$
//
wire        w_M0_loopback_en           = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
														   w_SSPI_CON_WI[24]              ;
wire        w_M0_MISO_one_bit_ahead_en = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[25]    : 
														   w_SSPI_CON_WI[25]              ;
wire [2:0]  w_M0_slack_count_MISO      = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
														   w_SSPI_CON_WI[30:28]           ;
//
//wire [3:0] w_board_id = {S_ID3_BUF,S_ID2_BUF,S_ID1_BUF,S_ID0_BUF};
//$$wire [3:0] w_board_id = w_slot_id; //$$ rev miso info
wire [7:0] w_board_status;
assign w_board_status[7] = 1'b0                    ; // NA // Board Error Status                
assign w_board_status[6] = r_M_TRIG[0]             ; // M_TRIG             
assign w_board_status[5] = r_M_PRE_TRIG[0]         ; // M_PRE_TRIG         
assign w_board_status[4] = r_M_BUSY_B_OUT          ; // M_BUSY_B_OUT or M_READY_OUT      
assign w_board_status[3] = w_busy_SPI_frame        ; // SPIO busy          
assign w_board_status[2] = w_busy_DAC_update       ; // DAC  busy          
assign w_board_status[1] = w_fifo_adc_empty_and_all; // ADC FIFO all empty 
assign w_board_status[0] = w_ADC_busy_pclk         ; // ADC_busy           

//
slave_spi_mth_brd  slave_spi_mth_brd__M0_inst (
	.clk     (base_sspi_clk), // base clock 72MHz or 104MHz
	.reset_n (reset_n),
	
	//// slave SPI pins:
	.i_SPI_CS_B      (w_M0_SPI_CS_B_BUF),
	.i_SPI_CLK       (w_M0_SPI_CLK     ),
	.i_SPI_MOSI      (w_M0_SPI_MOSI    ),
	.o_SPI_MISO      (w_M0_SPI_MISO    ),
	.o_SPI_MISO_EN   (w_M0_SPI_MISO_EN ), // MISO buffer control
	
	.o_cnt_sspi_cs   (w_M0_cnt_sspi_cs ), // [15:0] //$$
	
	//// test register interface
	
	// wi
	.o_port_wi_sadrs_h000    (w_M0_port_wi_sadrs_h000), // [31:0] // SW_BUILD_ID_WI		0x000	wi00
	.o_port_wi_sadrs_h004    (w_M0_port_wi_sadrs_h004), // [31:0] // TEST_CON_WI		0x004	wi01
	.o_port_wi_sadrs_h008    (w_M0_port_wi_sadrs_h008), // [31:0] // SSPI_CON_WI		0x008	wi02
	.o_port_wi_sadrs_h00C    (w_M0_port_wi_sadrs_h00C), // [31:0] // RNET_CON_WI		0x00C	wi03
	.o_port_wi_sadrs_h010    (w_M0_port_wi_sadrs_h010), // [31:0] // SPIO_FDAT_WI		0x010	wi04
	.o_port_wi_sadrs_h014    (w_M0_port_wi_sadrs_h014), // [31:0] // SPIO_CON_WI		0x014	wi05
	.o_port_wi_sadrs_h018    (w_M0_port_wi_sadrs_h018), // [31:0] // DAC_CON_WI			0x018	wi06
	.o_port_wi_sadrs_h048    (w_M0_port_wi_sadrs_h048), // [31:0] // MEM_FDAT_WI		0x048	wi12 //$$
	.o_port_wi_sadrs_h04C    (w_M0_port_wi_sadrs_h04C), // [31:0] // MEM_WI				0x04C	wi13 //$$
	.o_port_wi_sadrs_h050    (w_M0_port_wi_sadrs_h050), // [31:0] // EXT_TRIG_CON_WI	0x050	wi14
	.o_port_wi_sadrs_h054    (w_M0_port_wi_sadrs_h054), // [31:0] // EXT_TRIG_PARA_WI	0x054	wi15
	.o_port_wi_sadrs_h058    (w_M0_port_wi_sadrs_h058), // [31:0] // EXT_TRIG_AUX_WI	0x058	wi16
	.o_port_wi_sadrs_h060    (w_M0_port_wi_sadrs_h060), // [31:0] // DAC_S1_WI	0x060	wi18
	.o_port_wi_sadrs_h064    (w_M0_port_wi_sadrs_h064), // [31:0] // DAC_S2_WI	0x064	wi19
	.o_port_wi_sadrs_h068    (w_M0_port_wi_sadrs_h068), // [31:0] // DAC_S3_WI	0x068	wi1A
	.o_port_wi_sadrs_h06C    (w_M0_port_wi_sadrs_h06C), // [31:0] // DAC_S4_WI	0x06C	wi1B
	.o_port_wi_sadrs_h070    (w_M0_port_wi_sadrs_h070), // [31:0] // DAC_S5_WI	0x070	wi1C
	.o_port_wi_sadrs_h074    (w_M0_port_wi_sadrs_h074), // [31:0] // DAC_S6_WI	0x074	wi1D
	.o_port_wi_sadrs_h078    (w_M0_port_wi_sadrs_h078), // [31:0] // DAC_S7_WI	0x078	wi1E
	.o_port_wi_sadrs_h07C    (w_M0_port_wi_sadrs_h07C), // [31:0] // DAC_S8_WI	0x07C	wi1F
	.o_port_wi_sadrs_h01C    (w_M0_port_wi_sadrs_h01C), // ADC_CON_WI		0x01C			wi07
	.o_port_wi_sadrs_h040    (w_M0_port_wi_sadrs_h040), // ADC_PAR_WI		0x040 			wi10
	
	// wo
	.i_port_wo_sadrs_h080    (w_M0_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h084    (w_M0_port_wo_sadrs_h084),
	.i_port_wo_sadrs_h088    (w_M0_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h08C    (w_M0_port_wo_sadrs_h08C),
	.i_port_wo_sadrs_h090    (w_M0_port_wo_sadrs_h090),
	.i_port_wo_sadrs_h094    (w_M0_port_wo_sadrs_h094),
	.i_port_wo_sadrs_h098    (w_M0_port_wo_sadrs_h098),
	.i_port_wo_sadrs_h09C    (w_M0_port_wo_sadrs_h09C), // ADC_FLAG_WO		0x09C			wo27
	.i_port_wo_sadrs_h0E0    (w_M0_port_wo_sadrs_h0E0), // [31:0] // DAC_S1_WO	0x0E0	wo38
	.i_port_wo_sadrs_h0E4    (w_M0_port_wo_sadrs_h0E4), // [31:0] // DAC_S2_WO	0x0E4	wo39
	.i_port_wo_sadrs_h0E8    (w_M0_port_wo_sadrs_h0E8), // [31:0] // DAC_S3_WO	0x0E8	wo3A
	.i_port_wo_sadrs_h0EC    (w_M0_port_wo_sadrs_h0EC), // [31:0] // DAC_S4_WO	0x0EC	wo3B
	.i_port_wo_sadrs_h0F0    (w_M0_port_wo_sadrs_h0F0), // [31:0] // DAC_S5_WO	0x0F0	wo3C
	.i_port_wo_sadrs_h0F4    (w_M0_port_wo_sadrs_h0F4), // [31:0] // DAC_S6_WO	0x0F4	wo3D
	.i_port_wo_sadrs_h0F8    (w_M0_port_wo_sadrs_h0F8), // [31:0] // DAC_S7_WO	0x0F8	wo3E
	.i_port_wo_sadrs_h0FC    (w_M0_port_wo_sadrs_h0FC), // [31:0] // DAC_S8_WO	0x0FC	wo3F
	//
	.i_port_wo_sadrs_h0A0    (w_M0_port_wo_sadrs_h0A0), // ADC_Sn_ACC_WO		0x0A0~0x0BC		wo28~wo2F
	.i_port_wo_sadrs_h0A4    (w_M0_port_wo_sadrs_h0A4),
	.i_port_wo_sadrs_h0A8    (w_M0_port_wo_sadrs_h0A8),
	.i_port_wo_sadrs_h0AC    (w_M0_port_wo_sadrs_h0AC),
	.i_port_wo_sadrs_h0B0    (w_M0_port_wo_sadrs_h0B0),
	.i_port_wo_sadrs_h0B4    (w_M0_port_wo_sadrs_h0B4),
	.i_port_wo_sadrs_h0B8    (w_M0_port_wo_sadrs_h0B8),
	.i_port_wo_sadrs_h0BC    (w_M0_port_wo_sadrs_h0BC),
	//
	.i_port_wo_sadrs_h0C0    (w_M0_port_wo_sadrs_h0C0), // ADC_Sn_WO		0x0C0~0x0DC		wo30~wo37
	.i_port_wo_sadrs_h0C4    (w_M0_port_wo_sadrs_h0C4),
	.i_port_wo_sadrs_h0C8    (w_M0_port_wo_sadrs_h0C8),
	.i_port_wo_sadrs_h0CC    (w_M0_port_wo_sadrs_h0CC),
	.i_port_wo_sadrs_h0D0    (w_M0_port_wo_sadrs_h0D0),
	.i_port_wo_sadrs_h0D4    (w_M0_port_wo_sadrs_h0D4),
	.i_port_wo_sadrs_h0D8    (w_M0_port_wo_sadrs_h0D8),
	.i_port_wo_sadrs_h0DC    (w_M0_port_wo_sadrs_h0DC),
	//
	.i_port_wo_sadrs_h380    (w_M0_port_wo_sadrs_h380), // [31:0] // adrs h383~h380	
	.i_port_wo_sadrs_h384    (w_M0_port_wo_sadrs_h384), // [31:0] // SSPI_BD_STAT_WO           
	.i_port_wo_sadrs_h388    (w_M0_port_wo_sadrs_h388), // [31:0] // SSPI_CNT_CS_M0_WO         
	.i_port_wo_sadrs_h38C    (w_M0_port_wo_sadrs_h38C), // [31:0] // SSPI_CNT_CS_M1_WO         
	.i_port_wo_sadrs_h390    (w_M0_port_wo_sadrs_h390), // [31:0] // SSPI_CNT_ADC_FIFO_IN_WO   
	.i_port_wo_sadrs_h394    (w_M0_port_wo_sadrs_h394), // [31:0] // SSPI_CNT_ADC_RUN_TRIG_WO  
	.i_port_wo_sadrs_h398    (w_M0_port_wo_sadrs_h398), // [31:0] // SSPI_CNT_SPIO_FRM_TRIG_WO 
	.i_port_wo_sadrs_h39C    (w_M0_port_wo_sadrs_h39C), // [31:0] // SSPI_CNT_DAC_FRM_TRIG_WO  
	
	// ti
	.i_ck__sadrs_h104  (sys_clk),      .o_port_ti_sadrs_h104  (w_M0_port_ti_sadrs_h104), // [31:0]
	.i_ck__sadrs_h110  (sys_clk),      .o_port_ti_sadrs_h110  (w_M0_port_ti_sadrs_h110), // [31:0]
	.i_ck__sadrs_h114  (sys_clk),      .o_port_ti_sadrs_h114  (w_M0_port_ti_sadrs_h114), // [31:0]
	.i_ck__sadrs_h118  (sys_clk),      .o_port_ti_sadrs_h118  (w_M0_port_ti_sadrs_h118), // [31:0]
	.i_ck__sadrs_h11C  (p_adc_clk),    .o_port_ti_sadrs_h11C  (w_M0_port_ti_sadrs_h11C), // [31:0] // ADC_TRIG_TI		0x11C			ti47 // p_adc_clk
	.i_ck__sadrs_h14C  (sys_clk),      .o_port_ti_sadrs_h14C  (w_M0_port_ti_sadrs_h14C), // [31:0] // MEM_TI	0x14C	ti53 // sys_clk //$$

	// to
	.i_ck__sadrs_h190  (sys_clk  ),    .i_port_to_sadrs_h190  (w_M0_port_to_sadrs_h190), // [31:0] // EXT_TRIG_TO	0x190	to64 // sys_clk //$$
	.i_ck__sadrs_h194  (sys_clk  ),    .i_port_to_sadrs_h194  (w_M0_port_to_sadrs_h194), // [31:0]
	.i_ck__sadrs_h198  (sys_clk  ),    .i_port_to_sadrs_h198  (w_M0_port_to_sadrs_h198), // [31:0]
	.i_ck__sadrs_h19C  (p_adc_clk),    .i_port_to_sadrs_h19C  (w_M0_port_to_sadrs_h19C), // [31:0] // ADC_TRIG_TO		0x19C			to67 // p_adc_clk
	.i_ck__sadrs_h1CC  (sys_clk  ),    .i_port_to_sadrs_h1CC  (w_M0_port_to_sadrs_h1CC), // [31:0] // MEM_TO	0x1CC	to73 // sys_clk //$$

	// pi
	.o_wr__sadrs_h24C (w_MEM_PI_wr_sspi_M0),   .o_port_po_sadrs_h24C (w_MEM_PI_sspi_M0), // [31:0]  // MEM_PI	0x24C	pi93 //$$
	
	// po
	// ADC_Sn_CH1_PO	0x280~0x29C		poA0~poA7
	// ADC_Sn_CH2_PO	0x2A0~0x2BC		poA8~poAF
	.o_rd__sadrs_h280 (w_ADC_S1_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h280 (w_ADC_S1_CH1_PO), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	.o_rd__sadrs_h284 (w_ADC_S2_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h284 (w_ADC_S2_CH1_PO), // [31:0]  // ADC_S2_CH1_PO	0x284	poA1
	.o_rd__sadrs_h288 (w_ADC_S3_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h288 (w_ADC_S3_CH1_PO), // [31:0]  // ADC_S3_CH1_PO	0x288	poA2
	.o_rd__sadrs_h28C (w_ADC_S4_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h28C (w_ADC_S4_CH1_PO), // [31:0]  // ADC_S4_CH1_PO	0x28C	poA3
	.o_rd__sadrs_h290 (w_ADC_S5_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h290 (w_ADC_S5_CH1_PO), // [31:0]  // ADC_S5_CH1_PO	0x290	poA4
	.o_rd__sadrs_h294 (w_ADC_S6_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h294 (w_ADC_S6_CH1_PO), // [31:0]  // ADC_S6_CH1_PO	0x294	poA5
	.o_rd__sadrs_h298 (w_ADC_S7_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h298 (w_ADC_S7_CH1_PO), // [31:0]  // ADC_S7_CH1_PO	0x298	poA6
	.o_rd__sadrs_h29C (w_ADC_S8_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h29C (w_ADC_S8_CH1_PO), // [31:0]  // ADC_S8_CH1_PO	0x29C	poA7
	.o_rd__sadrs_h2A0 (w_ADC_S1_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A0 (w_ADC_S1_CH2_PO), // [31:0]  // ADC_S1_CH2_PO	0x2A0	poA8
	.o_rd__sadrs_h2A4 (w_ADC_S2_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A4 (w_ADC_S2_CH2_PO), // [31:0]  // ADC_S2_CH2_PO	0x2A4	poA9
	.o_rd__sadrs_h2A8 (w_ADC_S3_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A8 (w_ADC_S3_CH2_PO), // [31:0]  // ADC_S3_CH2_PO	0x2A8	poAA
	.o_rd__sadrs_h2AC (w_ADC_S4_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2AC (w_ADC_S4_CH2_PO), // [31:0]  // ADC_S4_CH2_PO	0x2AC	poAB
	.o_rd__sadrs_h2B0 (w_ADC_S5_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B0 (w_ADC_S5_CH2_PO), // [31:0]  // ADC_S5_CH2_PO	0x2B0	poAC
	.o_rd__sadrs_h2B4 (w_ADC_S6_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B4 (w_ADC_S6_CH2_PO), // [31:0]  // ADC_S6_CH2_PO	0x2B4	poAD
	.o_rd__sadrs_h2B8 (w_ADC_S7_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B8 (w_ADC_S7_CH2_PO), // [31:0]  // ADC_S7_CH2_PO	0x2B8	poAE
	.o_rd__sadrs_h2BC (w_ADC_S8_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2BC (w_ADC_S8_CH2_PO), // [31:0]  // ADC_S8_CH2_PO	0x2BC	poAF
	.o_rd__sadrs_h2CC (       w_MEM_PO_rd_sspi_M0),   .i_port_po_sadrs_h2CC (       w_MEM_PO), // [31:0]  // MEM_PO	0x2CC	poB3 //$$
	
	//// loopback mode control 
	.i_loopback_en           (w_M0_loopback_en),

	//// timing control 
	.i_slack_count_MISO      (w_M0_slack_count_MISO), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	.i_MISO_one_bit_ahead_en (w_M0_MISO_one_bit_ahead_en), // '1' for MISO one bit ahead mode.  

	.i_board_id      (w_slot_id    ), // [3:0] // slot ID
	.i_board_status  (w_board_status), // [7:0] // board status

	.valid    () 
);
//
wire [31:0] w_M1_port_wi_sadrs_h000; // to mux ... // not used
wire [31:0] w_M1_port_wi_sadrs_h008; // to mux ... // not used
//
//wire [31:0] w_M1_port_wo_sadrs_h080 = w_FPGA_IMAGE_ID_WO;
//wire [31:0] w_M1_port_wo_sadrs_h088 = w_SSPI_FLAG_WO    ;
//wire [31:0] w_M1_port_wo_sadrs_h380 = 32'h33AA_CC55     ; // known pattern
//
wire        w_M1_loopback_en           = w_M1_port_wi_sadrs_h008[24];
wire        w_M1_MISO_one_bit_ahead_en = w_M1_port_wi_sadrs_h008[25];
wire [2:0]  w_M1_slack_count_MISO      = w_M1_port_wi_sadrs_h008[30:28];
//
slave_spi_mth_brd  slave_spi_mth_brd__M1_inst (
	.clk     (base_sspi_clk), // base clock 72MHz
	.reset_n (reset_n),
	//// slave SPI pins:
	.i_SPI_CS_B      (w_M1_SPI_CS_B_BUF),
	.i_SPI_CLK       (w_M1_SPI_CLK     ),
	.i_SPI_MOSI      (w_M1_SPI_MOSI    ),
	.o_SPI_MISO      (w_M1_SPI_MISO    ),
	.o_SPI_MISO_EN   (w_M1_SPI_MISO_EN), // MISO buffer control
	
	.o_cnt_sspi_cs   (w_M1_cnt_sspi_cs ), // [15:0] //$$

	//// test register interface
	
	.o_port_wi_sadrs_h000    (w_M1_port_wi_sadrs_h000), // [31:0] // adrs h003~h000
	.o_port_wi_sadrs_h004    (),
	.o_port_wi_sadrs_h008    (w_M1_port_wi_sadrs_h008),
	.o_port_wi_sadrs_h00C    (),
	.o_port_wi_sadrs_h010    (),
	.o_port_wi_sadrs_h014    (),
	.o_port_wi_sadrs_h018    (),
	.o_port_wi_sadrs_h048    (), 
	.o_port_wi_sadrs_h04C    (), 
	.o_port_wi_sadrs_h050    (),
	.o_port_wi_sadrs_h054    (),
	.o_port_wi_sadrs_h058    (),
	.o_port_wi_sadrs_h060    (),
	.o_port_wi_sadrs_h064    (),
	.o_port_wi_sadrs_h068    (),
	.o_port_wi_sadrs_h06C    (),
	.o_port_wi_sadrs_h070    (),
	.o_port_wi_sadrs_h074    (),
	.o_port_wi_sadrs_h078    (),
	.o_port_wi_sadrs_h07C    (),
	.o_port_wi_sadrs_h01C    (),
	.o_port_wi_sadrs_h040    (),
	
	// WO monitor // duplicate
	.i_port_wo_sadrs_h080    (w_M0_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h084    (w_M0_port_wo_sadrs_h084),
	.i_port_wo_sadrs_h088    (w_M0_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h08C    (w_M0_port_wo_sadrs_h08C),
	.i_port_wo_sadrs_h090    (w_M0_port_wo_sadrs_h090),
	.i_port_wo_sadrs_h094    (w_M0_port_wo_sadrs_h094),
	.i_port_wo_sadrs_h098    (w_M0_port_wo_sadrs_h098),
	.i_port_wo_sadrs_h09C    (w_M0_port_wo_sadrs_h09C), 
	.i_port_wo_sadrs_h0E0    (w_M0_port_wo_sadrs_h0E0),
	.i_port_wo_sadrs_h0E4    (w_M0_port_wo_sadrs_h0E4),
	.i_port_wo_sadrs_h0E8    (w_M0_port_wo_sadrs_h0E8),
	.i_port_wo_sadrs_h0EC    (w_M0_port_wo_sadrs_h0EC),
	.i_port_wo_sadrs_h0F0    (w_M0_port_wo_sadrs_h0F0),
	.i_port_wo_sadrs_h0F4    (w_M0_port_wo_sadrs_h0F4),
	.i_port_wo_sadrs_h0F8    (w_M0_port_wo_sadrs_h0F8),
	.i_port_wo_sadrs_h0FC    (w_M0_port_wo_sadrs_h0FC),
	//
	.i_port_wo_sadrs_h0A0    (w_M0_port_wo_sadrs_h0A0),
	.i_port_wo_sadrs_h0A4    (w_M0_port_wo_sadrs_h0A4),
	.i_port_wo_sadrs_h0A8    (w_M0_port_wo_sadrs_h0A8),
	.i_port_wo_sadrs_h0AC    (w_M0_port_wo_sadrs_h0AC),
	.i_port_wo_sadrs_h0B0    (w_M0_port_wo_sadrs_h0B0),
	.i_port_wo_sadrs_h0B4    (w_M0_port_wo_sadrs_h0B4),
	.i_port_wo_sadrs_h0B8    (w_M0_port_wo_sadrs_h0B8),
	.i_port_wo_sadrs_h0BC    (w_M0_port_wo_sadrs_h0BC),
	//
	.i_port_wo_sadrs_h0C0    (w_M0_port_wo_sadrs_h0C0), 
	.i_port_wo_sadrs_h0C4    (w_M0_port_wo_sadrs_h0C4),
	.i_port_wo_sadrs_h0C8    (w_M0_port_wo_sadrs_h0C8),
	.i_port_wo_sadrs_h0CC    (w_M0_port_wo_sadrs_h0CC),
	.i_port_wo_sadrs_h0D0    (w_M0_port_wo_sadrs_h0D0),
	.i_port_wo_sadrs_h0D4    (w_M0_port_wo_sadrs_h0D4),
	.i_port_wo_sadrs_h0D8    (w_M0_port_wo_sadrs_h0D8),
	.i_port_wo_sadrs_h0DC    (w_M0_port_wo_sadrs_h0DC),
	//
	.i_port_wo_sadrs_h380    (w_M0_port_wo_sadrs_h380),
	.i_port_wo_sadrs_h384    (w_M0_port_wo_sadrs_h384),
	.i_port_wo_sadrs_h388    (w_M0_port_wo_sadrs_h388),
	.i_port_wo_sadrs_h38C    (w_M0_port_wo_sadrs_h38C),
	.i_port_wo_sadrs_h390    (w_M0_port_wo_sadrs_h390),
	.i_port_wo_sadrs_h394    (w_M0_port_wo_sadrs_h394),
	.i_port_wo_sadrs_h398    (w_M0_port_wo_sadrs_h398),
	.i_port_wo_sadrs_h39C    (w_M0_port_wo_sadrs_h39C),
	
	// ti
	.i_ck__sadrs_h104  (1'b0),   .o_port_ti_sadrs_h104  (), // [31:0]
	.i_ck__sadrs_h110  (1'b0),   .o_port_ti_sadrs_h110  (), // [31:0]
	.i_ck__sadrs_h114  (1'b0),   .o_port_ti_sadrs_h114  (), // [31:0]
	.i_ck__sadrs_h118  (1'b0),   .o_port_ti_sadrs_h118  (), // [31:0]
	.i_ck__sadrs_h11C  (1'b0),   .o_port_ti_sadrs_h11C  (), 
	.i_ck__sadrs_h14C  (1'b0),   .o_port_ti_sadrs_h14C  (), 
	
	// TO monitor
	.i_ck__sadrs_h190  (sys_clk  ),   .i_port_to_sadrs_h190  (w_M0_port_to_sadrs_h190), // [31:0]
	.i_ck__sadrs_h194  (sys_clk  ),   .i_port_to_sadrs_h194  (w_M0_port_to_sadrs_h194), // [31:0]
	.i_ck__sadrs_h198  (sys_clk  ),   .i_port_to_sadrs_h198  (w_M0_port_to_sadrs_h198), // [31:0]
	.i_ck__sadrs_h19C  (p_adc_clk),   .i_port_to_sadrs_h19C  (w_M0_port_to_sadrs_h19C), 
	.i_ck__sadrs_h1CC  (sys_clk  ),   .i_port_to_sadrs_h1CC  (w_M0_port_to_sadrs_h1CC), // [31:0]
	
	// pi
	.o_wr__sadrs_h24C (),   .o_port_po_sadrs_h24C (),
	
	// PO monitor
	.o_rd__sadrs_h280 (w_ADC_S1_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h280 (w_ADC_S1_CH1_PO), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	.o_rd__sadrs_h284 (w_ADC_S2_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h284 (w_ADC_S2_CH1_PO), // [31:0]  // ADC_S2_CH1_PO	0x284	poA1
	.o_rd__sadrs_h288 (w_ADC_S3_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h288 (w_ADC_S3_CH1_PO), // [31:0]  // ADC_S3_CH1_PO	0x288	poA2
	.o_rd__sadrs_h28C (w_ADC_S4_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h28C (w_ADC_S4_CH1_PO), // [31:0]  // ADC_S4_CH1_PO	0x28C	poA3
	.o_rd__sadrs_h290 (w_ADC_S5_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h290 (w_ADC_S5_CH1_PO), // [31:0]  // ADC_S5_CH1_PO	0x290	poA4
	.o_rd__sadrs_h294 (w_ADC_S6_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h294 (w_ADC_S6_CH1_PO), // [31:0]  // ADC_S6_CH1_PO	0x294	poA5
	.o_rd__sadrs_h298 (w_ADC_S7_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h298 (w_ADC_S7_CH1_PO), // [31:0]  // ADC_S7_CH1_PO	0x298	poA6
	.o_rd__sadrs_h29C (w_ADC_S8_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h29C (w_ADC_S8_CH1_PO), // [31:0]  // ADC_S8_CH1_PO	0x29C	poA7
	.o_rd__sadrs_h2A0 (w_ADC_S1_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A0 (w_ADC_S1_CH2_PO), // [31:0]  // ADC_S1_CH2_PO	0x2A0	poA8
	.o_rd__sadrs_h2A4 (w_ADC_S2_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A4 (w_ADC_S2_CH2_PO), // [31:0]  // ADC_S2_CH2_PO	0x2A4	poA9
	.o_rd__sadrs_h2A8 (w_ADC_S3_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A8 (w_ADC_S3_CH2_PO), // [31:0]  // ADC_S3_CH2_PO	0x2A8	poAA
	.o_rd__sadrs_h2AC (w_ADC_S4_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2AC (w_ADC_S4_CH2_PO), // [31:0]  // ADC_S4_CH2_PO	0x2AC	poAB
	.o_rd__sadrs_h2B0 (w_ADC_S5_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B0 (w_ADC_S5_CH2_PO), // [31:0]  // ADC_S5_CH2_PO	0x2B0	poAC
	.o_rd__sadrs_h2B4 (w_ADC_S6_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B4 (w_ADC_S6_CH2_PO), // [31:0]  // ADC_S6_CH2_PO	0x2B4	poAD
	.o_rd__sadrs_h2B8 (w_ADC_S7_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B8 (w_ADC_S7_CH2_PO), // [31:0]  // ADC_S7_CH2_PO	0x2B8	poAE
	.o_rd__sadrs_h2BC (w_ADC_S8_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2BC (w_ADC_S8_CH2_PO), // [31:0]  // ADC_S8_CH2_PO	0x2BC	poAF
	.o_rd__sadrs_h2CC (       w_MEM_PO_rd_sspi_M1),   .i_port_po_sadrs_h2CC (       w_MEM_PO), // [31:0]  // MEM_PO	0x2CC	poB3 //$$

	
	//// loopback mode control 
	.i_loopback_en           (w_M1_loopback_en),

	//// timing control 
	.i_slack_count_MISO      (w_M1_slack_count_MISO), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	.i_MISO_one_bit_ahead_en (w_M1_MISO_one_bit_ahead_en), // '1' for MISO one bit ahead mode.  

	.i_board_id      (w_slot_id    ), // [3:0] // slot ID
	.i_board_status  (w_board_status), // [7:0] // board status

	.valid    () 
);


//}

// assignments //{

// signal monitoring reg
(* keep = "true" *) reg r_M0_SPI_CS_B_BUF; // test sampling
(* keep = "true" *) reg r_M0_SPI_CLK     ; // test sampling
(* keep = "true" *) reg r_M0_SPI_MOSI    ; // test sampling
(* keep = "true" *) reg r_M0_SPI_MISO    ; // test output
(* keep = "true" *) reg r_M0_SPI_MISO_EN ; // test output
//
(* keep = "true" *) reg r_M1_SPI_CS_B_BUF; // test sampling
(* keep = "true" *) reg r_M1_SPI_CLK     ; // test sampling
(* keep = "true" *) reg r_M1_SPI_MOSI    ; // test sampling
(* keep = "true" *) reg r_M1_SPI_MISO    ; // test output
(* keep = "true" *) reg r_M1_SPI_MISO_EN ; // test output


//// output pin assignment
assign M0_SPI_MISO_EN = r_M0_SPI_MISO_EN;
assign M0_SPI_MISO    = r_M0_SPI_MISO   ;
assign M1_SPI_MISO_EN = r_M1_SPI_MISO_EN;
assign M1_SPI_MISO    = r_M1_SPI_MISO   ;

//// input pin sampling
always @(posedge base_sspi_clk, negedge reset_n)
	if (!reset_n) begin
		r_M0_SPI_CS_B_BUF  <= 1'b0;
		r_M0_SPI_CLK       <= 1'b0;
		r_M0_SPI_MOSI      <= 1'b0;
		r_M1_SPI_CS_B_BUF  <= 1'b0;
		r_M1_SPI_CLK       <= 1'b0;
		r_M1_SPI_MOSI      <= 1'b0;
	end
	else begin
		r_M0_SPI_CS_B_BUF  <= M0_SPI_CS_B_BUF;
		r_M0_SPI_CLK       <= M0_SPI_CLK     ;
		r_M0_SPI_MOSI      <= M0_SPI_MOSI    ;
		r_M1_SPI_CS_B_BUF  <= M1_SPI_CS_B_BUF;
		r_M1_SPI_CLK       <= M1_SPI_CLK     ;
		r_M1_SPI_MOSI      <= M1_SPI_MOSI    ;
	end	


// output sampling
always @(posedge base_sspi_clk, negedge reset_n)
	if (!reset_n) begin
		r_M0_SPI_MISO     <= 1'b0;
		r_M0_SPI_MISO_EN  <= 1'b0;
		r_M1_SPI_MISO     <= 1'b0;
		r_M1_SPI_MISO_EN  <= 1'b0;
	end
	else begin
		r_M0_SPI_MISO      <= w_M0_SPI_MISO    ;
		r_M0_SPI_MISO_EN   <= w_M0_SPI_MISO_EN ;
		r_M1_SPI_MISO      <= w_M1_SPI_MISO    ;
		r_M1_SPI_MISO_EN   <= w_M1_SPI_MISO_EN ;
	end	

// input wire assignment
assign w_M0_SPI_CS_B_BUF = r_M0_SPI_CS_B_BUF;
assign w_M0_SPI_CLK      = r_M0_SPI_CLK     ;
assign w_M0_SPI_MOSI     = r_M0_SPI_MOSI    ;
assign w_M1_SPI_CS_B_BUF = r_M1_SPI_CS_B_BUF;
assign w_M1_SPI_CLK      = r_M1_SPI_CLK     ;
assign w_M1_SPI_MOSI     = r_M1_SPI_MOSI    ;


// output wire loopback //{
// loopback MISO <-- MOSI 
// loobback conditions
//   assign w_M0_SPI_MISO    =  w_M0_SPI_MOSI;
//   assign w_M0_SPI_MISO_EN = (w_M0_SPI_CS_B_BUF == 1'b0)? 1'b1 : 1'b0 ;
//   assign w_M1_SPI_MISO    =  w_M1_SPI_MOSI;
//   assign w_M1_SPI_MISO_EN = (w_M1_SPI_CS_B_BUF == 1'b0)? 1'b1 : 1'b0 ;
//}


// slave clock duplication //$$ REV2 //{
assign M0_SPI_SCLK = r_M0_SPI_CLK;
assign M1_SPI_SCLK = r_M1_SPI_CLK;
//}


// miso control M0
assign w_M0_loopback_en        = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
												   w_SSPI_CON_WI[24]              ;
assign w_M0_slack_count_MISO   = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
												   w_SSPI_CON_WI[30:28]           ;

// HW reset control 
assign w_HW_reset__ext        = w_M0_port_wi_sadrs_h008[3]; //$$

// res net assignment 
assign res_net_ctrl_ext_en    = w_M0_port_wi_sadrs_h008[1];   //$$ enable LED control on Base board
assign res_net_ctrl_ext_data  = w_M0_port_wi_sadrs_h00C[3:0];

// count2 control 
assign count2_trig_ext_data  = w_M0_port_ti_sadrs_h104[2:0];

// SPIO control 
assign spio_trig_ti_ext      = w_M0_port_ti_sadrs_h114[1:0];
assign spio_con_wi_ext       = w_M0_port_wi_sadrs_h014     ; // SPIO_CON_WI			0x014	wi05
assign spio_fdat_wi_ext      = w_M0_port_wi_sadrs_h010     ; // SPIO_FDAT_WI		0x010	wi04

// DAC control 
assign dac_trig_ti_ext       = w_M0_port_ti_sadrs_h118[4:0];
assign dac_con_wi_ext        = w_M0_port_wi_sadrs_h018[31:0];

// DAC wire in 
assign dac_s1_wi_ext = w_M0_port_wi_sadrs_h060 ; // [31:0] // DAC_S1_WI	0x060	wi18;
assign dac_s2_wi_ext = w_M0_port_wi_sadrs_h064 ; // [31:0] // DAC_S2_WI	0x064	wi19;
assign dac_s3_wi_ext = w_M0_port_wi_sadrs_h068 ; // [31:0] // DAC_S3_WI	0x068	wi1A;
assign dac_s4_wi_ext = w_M0_port_wi_sadrs_h06C ; // [31:0] // DAC_S4_WI	0x06C	wi1B;
assign dac_s5_wi_ext = w_M0_port_wi_sadrs_h070 ; // [31:0] // DAC_S5_WI	0x070	wi1C;
assign dac_s6_wi_ext = w_M0_port_wi_sadrs_h074 ; // [31:0] // DAC_S6_WI	0x074	wi1D;
assign dac_s7_wi_ext = w_M0_port_wi_sadrs_h078 ; // [31:0] // DAC_S7_WI	0x078	wi1E;
assign dac_s8_wi_ext = w_M0_port_wi_sadrs_h07C ; // [31:0] // DAC_S8_WI	0x07C	wi1F;

// ADC control 
assign adc_con_wi_ext  = w_M0_port_wi_sadrs_h01C ;
assign adc_par_wi_ext  = w_M0_port_wi_sadrs_h040 ;
assign adc_trig_ti_ext = w_M0_port_ti_sadrs_h11C[3:0];

// MEM control  //$$
//$$ MEM_FDAT_WI	0x048	wi12
//$$ MEM_WI			0x04C	wi13
//$$ MEM_TI			0x14C	ti53
//$$ MEM_TO		0x1CC	to73
//$$ MEM_PI		0x24C	pi93
//$$ MEM_PO		0x2CC	poB3
assign mem_fdat_wi__sspi = w_M0_port_wi_sadrs_h048; //$$ rev
assign mem_wi_______sspi = w_M0_port_wi_sadrs_h04C; //$$ rev
assign mem_ti_______sspi = w_M0_port_ti_sadrs_h14C; //$$

// EXT_TRIG control 
assign ext_trig_con_wi___sspi = w_M0_port_wi_sadrs_h050 ;
assign ext_trig_para_wi__sspi = w_M0_port_wi_sadrs_h054 ;
assign ext_trig_aux_wi___sspi = w_M0_port_wi_sadrs_h058 ;
assign ext_trig_ti_______sspi = w_M0_port_ti_sadrs_h110 ;

// flag assignment 
assign w_SSPI_FLAG_WO[0]     = w_SSPI_CON_WI[0]; // enables SSPI control from MCS or USB 
assign w_SSPI_FLAG_WO[1]     = res_net_ctrl_ext_en; // enables res net control from SSPI
assign w_SSPI_FLAG_WO[2]   = 1'b0; 
assign w_SSPI_FLAG_WO[3]   = w_HW_reset; //$$ HW reset status
assign w_SSPI_FLAG_WO[7:4]   = w_slot_id[3:0]     ; // show board slot id 
assign w_SSPI_FLAG_WO[15:8]  = w_board_status[7:0]; // show board status
assign w_SSPI_FLAG_WO[23:16] = 8'b0;
assign w_SSPI_FLAG_WO[27:24] = {w_M0_slack_count_MISO[2:0], w_M0_loopback_en}; // miso control
assign w_SSPI_FLAG_WO[31:28] = {w_M1_slack_count_MISO[2:0], w_M1_loopback_en}; // miso control

//w_SSPI_BD_STAT_WO           
assign w_SSPI_BD_STAT_WO[7:0]  = w_board_status[7:0];
assign w_SSPI_BD_STAT_WO[11:8] = w_slot_id;
assign w_SSPI_BD_STAT_WO[15:12] = 4'b0;
assign w_SSPI_BD_STAT_WO[31:16] = w_board_id;

//w_SSPI_CNT_CS_M0_WO         
assign w_SSPI_CNT_CS_M0_WO[15:0]  = w_M0_cnt_sspi_cs; //$$ count the falling edge of i_SPI_CS_B
assign w_SSPI_CNT_CS_M0_WO[31:16] = 16'b0;

//w_SSPI_CNT_CS_M1_WO         
assign w_SSPI_CNT_CS_M1_WO[15:0]  = w_M1_cnt_sspi_cs;
assign w_SSPI_CNT_CS_M1_WO[31:16] = 16'b0;

//w_SSPI_CNT_ADC_FIFO_IN_WO   
assign w_SSPI_CNT_ADC_FIFO_IN_WO[15:0]  = w_cnt_adc_fifo_in_pclk;
assign w_SSPI_CNT_ADC_FIFO_IN_WO[31:16] = 16'b0;

//w_SSPI_CNT_ADC_TRIG_WO  
assign w_SSPI_CNT_ADC_TRIG_WO[15:0]  = w_cnt_adc_trig_conv_pclk;
assign w_SSPI_CNT_ADC_TRIG_WO[31:16] = 16'b0;

//w_SSPI_CNT_SPIO_FRM_TRIG_WO 
assign w_SSPI_CNT_SPIO_FRM_TRIG_WO[15:0]  = w_cnt_spio_trig_frame; //$$ count w_trig_SPIO_SPI_frame
assign w_SSPI_CNT_SPIO_FRM_TRIG_WO[31:16] = 16'b0;

//w_SSPI_CNT_DAC_TRIG_WO  
assign w_SSPI_CNT_DAC_TRIG_WO[15:0]  = w_cnt_dac_trig; //$$ count DAC trig
assign w_SSPI_CNT_DAC_TRIG_WO[31:16] = 16'b0;


//}


//}


////----////



/* TODO: TEMP SDO */ //{  // to come

// ports for TEMP SDO //{

//# MC2-73  # TMP_SDO          set_property PACKAGE_PIN V14  [get_ports i_B13_L13N_MRCC  ]
wire  TMP_SDO;
IBUF ibuf__TMP_SDO_inst (.I(i_B13_L13N_MRCC      ), .O(TMP_SDO  ) ); // 

//}

//}




/* TODO: INT SPIO */ //{  // to come

// ports for INT SPIO //{

//# MC1-58  # INT_SP_MOSI   set_property PACKAGE_PIN Y1   [get_ports io_B34_L5N          ]  
//# MC1-60  # INT_SP_SCLK   set_property PACKAGE_PIN AB3  [get_ports io_B34_L8P          ]  
//# MC1-62  # INT_SP_MISO   set_property PACKAGE_PIN AB2  [get_ports io_B34_L8N          ]  
//# MC1-64  # INT_SP_CS_B   set_property PACKAGE_PIN Y13  [get_ports io_B13_L5P          ]  
wire  INT_SP_MOSI    = 1'b1; // test 
wire  INT_SP_SCLK    = 1'b1; // test 
wire  INT_SP_MISO    = 1'b1; // test 
wire  INT_SP_CS_B    = 1'b1; // test 
wire  INT_SP_MOSI_rd;
wire  INT_SP_SCLK_rd;
wire  INT_SP_MISO_rd;
wire  INT_SP_CS_B_rd;
// open-drain output style
IOBUF iobuf__INT_SP_MOSI_inst(.IO(io_B34_L5N  ), .T(INT_SP_MOSI), .I(INT_SP_MOSI ), .O(INT_SP_MOSI_rd ) ); //
IOBUF iobuf__INT_SP_SCLK_inst(.IO(io_B34_L8P  ), .T(INT_SP_SCLK), .I(INT_SP_SCLK ), .O(INT_SP_SCLK_rd ) ); //
IOBUF iobuf__INT_SP_MISO_inst(.IO(io_B34_L8N  ), .T(INT_SP_MISO), .I(INT_SP_MISO ), .O(INT_SP_MISO_rd ) ); //
IOBUF iobuf__INT_SP_CS_B_inst(.IO(io_B13_L5P  ), .T(INT_SP_CS_B), .I(INT_SP_CS_B ), .O(INT_SP_CS_B_rd ) ); //

//}

//}


////----////


endmodule

