// # this           : txem7310_pll__s3100_ms__top.v
// # top xdc        : txem7310_pll__s3100_ms__top.xdc
//
// # board          : S3100-CPU-BASE
// # board sch      : s3100_cpu_base_v100_20210413.pdf

// # note: artix-7 top design for S3100 CPU-BASE  master spi side
//
// ############################################################################
// ## TODO: bank usage in xc7a200
// ############################################################################
// # B13 : CPU_SPI, CPU_QSPI, CPU_ETH, FAN_SENS // (prev. in MC1/MC2) // 3.3V
// # B14 : CONF, LED, MTH_SPI control, CPU_GPIO                       // 1.8V
// # B15 : TP, LAN_SPI, SCIO, GPIB, BUS_BA                            // 3.3V
// # B16 : BUS_BD, BUS control, INTER_LOCK                            // 3.3V
// # B34 : MTH M0_SPI, MTH M1_SPI, HDR control         (prev. in MC1) // 3.3V
// # B35 : MTH M2_SPI, CAL_SPI, EXT_TRIG               (prev. in MC2) // 3.3V
// # B216: not used


// ## TODO: EP locations : LAN-MCS interface, MTH slave interface
//
// * LAN-MCS interface : MTH spi master emulation for debugging without connecting mother board
//                       - MSPI
//                       - TEST
//                       - MEM 
//                       - MCS
//
// * MTH slave SPI interface : END-POINT for test or known pattern


// ## S3100 MTH SPI frame format : 32 bits 
//
// * MOSI : 
//   FRAME MODE       // [1:0]
//   FRAME CONTROL    // [3:0]
//   FRAME ADDRESS    // [9:0]
//   FRAME WRITE DATA // [15:0]
//
// * MISO : 
//   zeros            // [1:0]
//   FRAME STATUS     // [3:0]
//   BOARD STATUS     // [7:0]
//   zeros            // [1:0]
//   FRAME READ DATA  // [15:0]


//// TODO: MTH slave SPI frame address map
// ## S3100-CPU-BASE  // GNDU --> PGU --> CPU-BASE(test only)
//                           
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | frame adrs | type/index | Description                | contents (32-bit)              |
// |       |               | (10-bit)   |            |                            |                                |
// +=======+===============+============+============+============================+================================+
// | SSPI  | SSPI_TEST_WO  | 0x380      | wireout_E0 | Return known frame data.   | bit[31:16]=0x33AA              | 
// |       |               |            |            |                            | bit[15: 0]=0xCC55              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


//// TODO: LAN-MCS endpoint address map
// ## S3100-CPU-BASE  // GNDU --> PGU --> CPU-BASE
//
// note: LAN access must have TEST, MCS, MEM and MSPI.
// note: MEM device is connected via pin B34_L5N, net S_IO_0 in case of S3100-PGU and S3000-PGU.
// note: MEM device is connected via pin IO_L11P_T1_SRCC_15, net SCIO_0 in case of S3100-CPU-BASE.
//
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | MCS adrs   | type/index | Description                | contents (32-bit)              |
// |       |               | (32-bit)   |            |                            |                                |
// +=======+===============+============+=========================================+================================+
// | TEST  | F_IMAGE_ID_WO | TBD        | wireout_20 | Return FPGA image ID.      | Image_ID[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_TEMP_WO  | TBD        | wireout_3A | Return XADC values.[mC]    | MON_TEMP[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_VOLT_WO  | TBD        | wireout_3B | Return XADC values.[mV]    | MON_VOLT[31:0] normial 1.1V    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TIMESTAMP_WO  | TBD        | wireout_22 | Return time stamp. (10MHz) | TIME_STAMP[31:0]               | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_MON_WO   | TBD        | wireout_23 | Return PLL status.         | bit[18]=MCS pll locked         | 
// |       |               |            |            |                            | bit[24]=DAC common pll locked  |
// |       |               |            |            |                            | bit[25]=DAC0 pll locked        |
// |       |               |            |            |                            | bit[26]=DAC1 pll locked        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_CON_WI   | TBD        | wireout_01 | Control test logics.       | bit[0]=count1_reset            | 
// |       |               |            |            |                            | bit[1]=count1_disable          |
// |       |               |            |            |                            | bit[2]=count2_auto_increase    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_OUT_WO   | TBD        | wireout_21 | Return test values.        | bit[15:8]=count2[7:0]          |
// |       |               |            |            |                            | bit[ 7:0]=count1[7:0]          |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TI       | TBD        | wireout_40 | Trigger test functions.    | bit[0]=trigger_count2_reset    |
// |       |               |            |            |                            | bit[1]=trigger_count2_up       |
// |       |               |            |            |                            | bit[2]=trigger_count2_down     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TO       | TBD        | wireout_60 | Check if trigger is done.  | bit[ 0]=done_count1eq00        |
// |       |               |            |            |                            | bit[ 1]=done_count1eq80        |
// |       |               |            |            |                            | bit[16]=done_count2eqFF        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PI       | TBD__      | pipe_in_8A | Write data into test FIFO. | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PO       | TBD__      | pipeout_AA | Read data from test FIFO.  | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | BRD_CON_WI    | TBD        | wire_in_03 | Control board from LAN.    | bit[ 0]=HW_reset               | 
// |       |               |            |            |                            | bit[ 8]=mcs_ep_po_enable       |
// |       |               |            |            |                            | bit[ 9]=mcs_ep_pi_enable       |
// |       |               |            |            |                            | bit[10]=mcs_ep_to_enable       |
// |       |               |            |            |                            | bit[11]=mcs_ep_ti_enable       |
// |       |               |            |            |                            | bit[12]=mcs_ep_wo_enable       |
// |       |               |            |            |                            | bit[13]=mcs_ep_wi_enable       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MCS   | MCS_SETUP_WI  | TBD        | wire_in_19 | Control board for MCS.     | bit[31:16]=board_id[15:0]      | 
// |       |               |            |            |                            | bit[10]=lan_on_base_enable(NA) |
// |       |               |            |            |                            | bit[ 9]=eeprom_on_tp_enable(NA)|
// |       |               |            |            |                            | bit[ 8]=eeprom_lan_enable(NA)  |
// |       |               |            |            |                            | bit[ 7: 0]=slot_id             |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_EN_CS_WI | TBD        | wire_in_16 | Control MSPI CS enable.    | bit[12: 0]=MSPI_EN_CS[12: 0]   |
// |       |               |            |            |                            | bit[16]   =M0 group enable     |
// |       |               |            |            |                            | bit[17]   =M1 group enable     |
// |       |               |            |            |                            | bit[18]   =M2 group enable     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_CON_WI   | TBD        | wire_in_17 | Control MSPI MOSI frame.   | bit[31:26]=frame_data_C[ 5:0]  |
// |       |               |            |            |                            | bit[25:16]=frame_data_A[ 9:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_D[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_FLAG_WO  | TBD        | wireout_24 | Return MSPI MISO frame.    | bit[31:16]=frame_data_E[15:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_B[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TI       | TBD        | trig_in_42 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_init            |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TO       | TBD        | trigout_62 | Check if trigger is done.  | bit[0]=done_reset              |
// |       |               |            |            |                            | bit[1]=done_init               |
// |       |               |            |            |                            | bit[2]=done_frame              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_WI        | TBD__      | wire_in_13 | Control EEPROM interface.  | bit[  15]=disable_SBP_packet   | 
// |       |               |            |            |                            | bit[11:0]=num_bytes_DAT[11:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_FDAT_WI   | TBD__      | wire_in_12 | Control EEPROM frame data. | bit[31:24]=frame_data_ADH[7:0] |
// |       |               |            |            |                            | bit[23:16]=frame_data_ADL[7:0] |
// |       |               |            |            |                            | bit[15: 8]=frame_data_STA[7:0] |
// |       |               |            |            |                            | bit[ 7: 0]=frame_data_CMD[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TI        | TBD__      | trig_in_53 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_fifo_reset      |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TO        | TBD__      | trigout_73 | Check status.              | bit[0]=MEM_valid_latch         |
// |       |               |            |            |                            | bit[1]=done_frame_latch        |
// |       |               |            |            |                            | bit[2]=done_frame (one pulse)  |
// |       |               |            |            |                            | bit[15:8]=frame_data_STA[7:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PI        | TBD__      | pipe_in_93 | Write data into pipe.      | bit[7:0]=frame_data_DAT_w[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PO        | TBD__      | pipeout_B3 | Read data from pipe.       | bit[7:0]=frame_data_DAT_r[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


/* top module integration */
module txem7310_pll__s3100_ms__top ( 
	
	//// note: BANK 14 15 16  signals // NOT compatible with TXEM7310 connectors
	

	//// BANK B14 //{
	
	// # IO_0_14                       # P20  # NA                        
	// # IO_B14_L1P_D00_MOSI           # P22  # FPGA_CFG_D0     (*)       
	// # IO_B14_L1N_D01_DIN            # R22  # FPGA_CFG_D1     (*)       
	// # IO_B14_L2P_D02                # P21  # FPGA_CFG_D2     (*)       
	// # IO_B14_L2N_D03                # R21  # FPGA_CFG_D3     (*)       
	// # IO_B14_L3P_PUDC_B             # U22  # FPGA_CFG_PUDC_B (*)       
	// # IO_B14_L3N                    # V22  # NA                        
	                                                             
	output wire  o_B14_L4P        , // # T21  # FPGA_IO0                  
	output wire  o_B14_L4N        , // # U21  # FPGA_IO1                  
	output wire  o_B14_L5P        , // # P19  # FPGA_IO2                  
	output wire  o_B14_L5N        , // # R19  # FPGA_IO3                  
	                                                            
	// # IO_B14_L6P_FCS_B              # T19  # FPGA_CFG_FCS_B  (*)       
	                                                            
	output wire  o_B14_L6N        , // # T20  # FPGA_IO4                  
	output wire  o_B14_L7P        , // # W21  # FPGA_IO5                  
	output wire  o_B14_L7N        , // # W22  # FPGA_MBD_RS_422_SPI_EN    
	output wire  o_B14_L8P        , // # AA20 # FPGA_MBD_RS_422_TRIG_EN   
	                                                       
	output wire  o_B14_L8N        , // # AA21 # FPGA_M0_SPI_TX_EN         
	output wire  o_B14_L9P        , // # Y21  # FPGA_M1_SPI_TX_EN         
	output wire  o_B14_L9N        , // # Y22  # FPGA_M2_SPI_TX_EN         
	output wire  o_B14_L10P       , // # AB21 # FPGA_TRIG_TX_EN           
								 		 
	// # IO_B14_L10N_                  # AB22 # NA                        
								 		 
	inout  wire  io_B14_L11P_SRCC , // # U20  # FPGA_LED0  //$$ led                
	inout  wire  io_B14_L11N_SRCC , // # V20  # FPGA_LED1  //$$ led                
	inout  wire  io_B14_L12P_MRCC , // # W19  # FPGA_LED2  //$$ led                
	inout  wire  io_B14_L12N_MRCC , // # W20  # FPGA_LED3  //$$ led                
	inout  wire  io_B14_L13P_MRCC , // # Y18  # FPGA_LED4  //$$ led                
	inout  wire  io_B14_L13N_MRCC , // # Y19  # FPGA_LED5  //$$ led                
	inout  wire  io_B14_L14P_SRCC , // # V18  # FPGA_LED6  //$$ led                
	inout  wire  io_B14_L14N_SRCC , // # V19  # FPGA_LED7  //$$ led                
								 		 
	// # IO_B14_L15P                   # AA19 # NA                        
	// # IO_B14_L15N                   # AB20 # NA                        
	// # IO_B14_L16P                   # V17  # NA                        
								 		 
	output wire  o_B14_L16N       , // # W17  # FPGA_GPIO_PB5             
	output wire  o_B14_L17P       , // # AA18 # FPGA_GPIO_PC4             
	output wire  o_B14_L17N       , // # AB18 # FPGA_GPIO_PC5             
	output wire  o_B14_L18P       , // # U17  # FPGA_GPIO_PH4             
	output wire  o_B14_L18N       , // # U18  # FPGA_GPIO_PH6             
	output wire  o_B14_L19P       , // # P14  # FPGA_GPIO_PH7             
				 				 		 
	output wire  o_B14_L19N       , // # R14  # FPGA_GPIO_PC9             
	output wire  o_B14_L20P       , // # R18  # FPGA_GPIO_PC10            
	output wire  o_B14_L20N       , // # T18  # FPGA_GPIO_PC11            
	output wire  o_B14_L21P       , // # N17  # FPGA_GPIO_PC12            
	output wire  o_B14_L21N       , // # P17  # FPGA_GPIO_PC13            
	output wire  o_B14_L22P       , // # P15  # FPGA_GPIO_PC14            
	output wire  o_B14_L22N       , // # R16  # FPGA_GPIO_PC15            
				 				 		 
	input  wire  i_B14_L23P       , // # N13  # FPGA_GPIO_PD2             
	input  wire  i_B14_L23N       , // # N14  # FPGA_GPIO_PI8             
	input  wire  i_B14_L24P       , // # P16  # FPGA_GPIO_PA8             
	input  wire  i_B14_L24N       , // # R17  # FPGA_GPIO_PB11            
								  		 
	// # IO_B14_25                     # N15  # NA                        
	
	//}

	
	//// BANK B15 //{
	
	output wire   o_B15_0_        , // # J16  # F_RDY

	// ## TPs and EXT_I2C
	output wire  o_B15_L1P_AD0P   , // # H13  # F_TP0 
	output wire  o_B15_L1N_AD0N   , // # G13  # F_TP1 
	output wire  o_B15_L2P_AD8P   , // # G15  # F_TP2 
	output wire  o_B15_L2N_AD8N   , // # G16  # F_TP3 
	output wire  o_B15_L3P_AD1P   , // # J14  # F_TP4 
	output wire  o_B15_L3N_AD1N   , // # H14  # F_TP5 
	//                                        
	input  wire  i_B15_L4P        , // # G17  # EXT_I2C_4_SCL
	inout  wire io_B15_L4N        , // # G18  # EXT_I2C_4_SDA
	//                                        
	output wire  o_B15_L5P_AD9P   , // # J15  # F_TP6 
	output wire  o_B15_L5N_AD9N   , // # H15  # F_TP7 
								   
	// ## LAN for END-POINTS       
	output wire  o_B15_L6P        , // # H17  # LAN_PWDN 
	output wire  o_B15_L6N        , // # H18  # LAN_SSAUX_B //$$ ssn aux
	output wire  o_B15_L7P        , // # J22  # LAN_MOSI
	output wire  o_B15_L7N        , // # H22  # LAN_SCLK
	output wire  o_B15_L8P        , // # H20  # LAN_SSN_B
	input  wire  i_B15_L8N        , // # G20  # LAN_INT_B
	output wire  o_B15_L9P        , // # K21  # LAN_RST_B
	input  wire  i_B15_L9N        , // # K22  # LAN_MISO
	
	// ## ADC
	//input  wire i_B15_L10P_AD11P, // # M21  # AUX_AD11P
	//input  wire i_B15_L10N_AD11N, // # L21  # AUX_AD11N

	inout  wire io_B15_L11P_SRCC  , // # J20  # SCIO_0 //$$ 11AA160T
	inout  wire io_B15_L11N_SRCC  , // # J21  # SCIO_1 //$$ 11AA160T

	input  wire  i_B15_L12P_MRCC  , // # J19  # GPIB_IRQ      
	output wire  o_B15_L12N_MRCC  , // # H19  # GPIB_nCS      
	output wire  o_B15_L13P_MRCC  , // # K18  # GPIB_nRESET   
	output wire  o_B15_L13N_MRCC  , // # K19  # GPIB_SW_nOE   
	input  wire  i_B15_L14P_SRCC  , // # L19  # GPIB_REM      
	input  wire  i_B15_L14N_SRCC  , // # L20  # GPIB_TADCS    
	input  wire  i_B15_L15P       , // # N22  # GPIB_LADCS    
	input  wire  i_B15_L15N       , // # M22  # GPIB_DCAS     
	input  wire  i_B15_L16P       , // # M18  # GPIB_TRIG     
	output wire  o_B15_L16N       , // # L18  # GPIB_DATA_DIR 
	output wire  o_B15_L17P       , // # N18  # GPIB_DATA_nOE 

	//input  wire i_B15_L17N,       // # N19  # NA
							        
	input  wire  i_B15_L18P       , // # N20  # BA25
	input  wire  i_B15_L18N       , // # M20  # BA24
	input  wire  i_B15_L19P       , // # K13  # BA23
	input  wire  i_B15_L19N       , // # K14  # BA22
	input  wire  i_B15_L20P       , // # M13  # BA21
	input  wire  i_B15_L20N       , // # L13  # BA20
	input  wire  i_B15_L21P       , // # K17  # BA19
	input  wire  i_B15_L21N       , // # J17  # BA18
	input  wire  i_B15_L22P       , // # L14  # BA7
	input  wire  i_B15_L22N       , // # L15  # BA6
	input  wire  i_B15_L23P       , // # L16  # BA5
	input  wire  i_B15_L23N       , // # K16  # BA4
	input  wire  i_B15_L24P       , // # M15  # BA3
	input  wire  i_B15_L24N       , // # M16  # BA2

	input  wire  i_B15_25         , // # M17  # BUF_FMC_CLK

	//}


	//// BANK B16 //{
	
	output wire  o_B16_0_         , // # F15  # BASE_F_LED_ERR 
	
	inout  wire io_B16_L1P        , // # F13  # BD0
	inout  wire io_B16_L1N        , // # F14  # BD1
	inout  wire io_B16_L2P        , // # F16  # BD2
	inout  wire io_B16_L2N        , // # E17  # BD3
	inout  wire io_B16_L3P        , // # C14  # BD4
	inout  wire io_B16_L3N        , // # C15  # BD5
	inout  wire io_B16_L4P        , // # E13  # BD6
	inout  wire io_B16_L4N        , // # E14  # BD7
	inout  wire io_B16_L5P        , // # E16  # BD8
	inout  wire io_B16_L5N        , // # D16  # BD9
	inout  wire io_B16_L6P        , // # D14  # BD10
	inout  wire io_B16_L6N        , // # D15  # BD11
	inout  wire io_B16_L7P        , // # B15  # BD12
	inout  wire io_B16_L7N        , // # B16  # BD13
	inout  wire io_B16_L8P        , // # C13  # BD14
	inout  wire io_B16_L8N        , // # B13  # BD15
	inout  wire io_B16_L9P        , // # A15  # BD16
	inout  wire io_B16_L9N        , // # A16  # BD17
	inout  wire io_B16_L10P       , // # A13  # BD18
	inout  wire io_B16_L10N       , // # A14  # BD19
	inout  wire io_B16_L11P       , // # B17  # BD20
	inout  wire io_B16_L11N       , // # B18  # BD21
	inout  wire io_B16_L12P       , // # D17  # BD22
	inout  wire io_B16_L12N       , // # C17  # BD23
	inout  wire io_B16_L13P       , // # C18  # BD24
	inout  wire io_B16_L13N       , // # C19  # BD25
	inout  wire io_B16_L14P       , // # E19  # BD26
	inout  wire io_B16_L14N       , // # D19  # BD27
	inout  wire io_B16_L15P       , // # F18  # BD28
	inout  wire io_B16_L15N       , // # E18  # BD29
	inout  wire io_B16_L16P       , // # B20  # BD30
	inout  wire io_B16_L16N       , // # A20  # BD31
	
	//  # IO_B16_L17P_T2_16         // # A18  # NA

	output wire  o_B16_L17N       , // # A19  # BUF_DATA_DIR
	output wire  o_B16_L18P       , // # F19  # nBUF_DATA_OE

	//  # IO_B16_L18N_T2_16         // # F20  # NA

	output wire  o_B16_L19P       , // # D20  # INTER_RELAY_O
	output wire  o_B16_L19N       , // # C20  # INTER_LED_O
	input  wire  i_B16_L20P       , // # C22  # INTER_LOCK_ON

	//  # IO_B16_L20N_T3_16         // # B22  # NA

	input  wire  i_B16_L21P       , // # B21  # nBNE1
	input  wire  i_B16_L21N       , // # A21  # nBNE2
	input  wire  i_B16_L22P       , // # E22  # nBNE3
	input  wire  i_B16_L22N       , // # D22  # nBNE4
	input  wire  i_B16_L23P       , // # E21  # nBOE
	input  wire  i_B16_L23N       , // # D21  # nBWE
	
	//  # IO_B16_L24P_T3_16         // # G21  # NA
	
	input  wire  i_B16_L24N       , // # G22  # BUF_nRESET											
	output wire  o_B16_25         , // # F21  # RUN_FPGA_LED
	
	//}
	


	//// BANK B13 //{
	
	// # IO_B13_0_                , // # Y17  # NA
											  
	input  wire  i_B13_L1P        , // # Y16  # SPI__1_SCLK
	input  wire  i_B13_L1N        , // # AA16 # SPI__1_nCS
	input  wire  i_B13_L2P        , // # AB16 # SPI__1_MOSI
	output wire  o_B13_L2N        , // # AB17 # SPI__1_MISO

	input  wire  i_B13_L3P        , // # AA13   # SPI__2_SCLK
	input  wire  i_B13_L3N        , // # AB13   # SPI__2_nCS
	input  wire  i_B13_L4P        , // # AA15   # SPI__2_MOSI
	output wire  o_B13_L4N        , // # AB15   # SPI__2_MISO

	input  wire  i_B13_L5P        , // # Y13    # QSPI_BK1_NCS
	input  wire  i_B13_L5N        , // # AA14   # QSPI_CLK
	inout  wire io_B13_L6P        , // # W14    # QSPI_BK1_IO0
	inout  wire io_B13_L6N        , // # Y14    # QSPI_BK1_IO1
	inout  wire io_B13_L7P        , // # AB11   # QSPI_BK1_IO2
	inout  wire io_B13_L7N        , // # AB12   # QSPI_BK1_IO3

	// # IO_B13_L8P               , // # AA9    # NA

	input  wire  i_B13_L8N        , // # AB10   # ETH_nIRQ
	output wire  o_B13_L9P        , // # AA10   # ETH_nRESET
	output wire  o_B13_L9N        , // # AA11   # ETH_nCS
	input  wire  i_B13_L10P       , // # V10    # ETH_nLINKLED
	input  wire  i_B13_L10N       , // # W10    # ETH_nTXLED
	input  wire  i_B13_L11P_SRCC  , // # Y11    # ETH_nRXLED

	// # IO_B13_L11N_SRCC         , // # Y12    # NA

	// # IO_B13_L12P_MRCC         , // # W11    # clocks sys_clkp (*)
	// # IO_B13_L12N_MRCC         , // # W12    # clocks sys_clkn (*)

	input  wire  i_B13_L13P_MRCC  , // # V13    # SYNC_10MHz
	input  wire  i_B13_L13N_MRCC  , // # V14    # EXT_TRIG_IN_CW

	input  wire  i_B13_L14P_SRCC  , // # U15    # FPGA_FAN_SENS_0
	input  wire  i_B13_L14N_SRCC  , // # V15    # FPGA_FAN_SENS_1
	input  wire  i_B13_L15P       , // # T14    # FPGA_FAN_SENS_2
	input  wire  i_B13_L15N       , // # T15    # FPGA_FAN_SENS_3
	input  wire  i_B13_L16P       , // # W15    # FPGA_FAN_SENS_4
	input  wire  i_B13_L16N       , // # W16    # FPGA_FAN_SENS_5
	input  wire  i_B13_L17P       , // # T16    # FPGA_FAN_SENS_6
	input  wire  i_B13_L17N       , // # U16    # FPGA_FAN_SENS_7

	//}
	
	
	//// BANK B34 //{
	
	input  wire  i_B34_0_         , // # T3     # FPGA_EXT_TRIG_IN_D
											    
	output wire  o_B34_L1P        , // # T1     # FPGA_M0_SPI_nCS0
	output wire  o_B34_L1N        , // # U1     # FPGA_M0_SPI_nCS1
	output wire  o_B34_L2P        , // # U2     # FPGA_M0_SPI_nCS2
	output wire  o_B34_L2N        , // # V2     # FPGA_M0_SPI_nCS3
	output wire  o_B34_L3P        , // # R3     # FPGA_M0_SPI_nCS4
	output wire  o_B34_L3N        , // # R2     # FPGA_M0_SPI_nCS5
	output wire  o_B34_L4P        , // # W2     # FPGA_M0_SPI_nCS6
	output wire  o_B34_L4N        , // # Y2     # FPGA_M0_SPI_nCS7
	output wire  o_B34_L5P        , // # W1     # FPGA_M0_SPI_nCS8
	output wire  o_B34_L5N        , // # Y1     # FPGA_M0_SPI_nCS9
	output wire  o_B34_L6P        , // # U3     # FPGA_M0_SPI_nCS10
	output wire  o_B34_L6N        , // # V3     # FPGA_M0_SPI_nCS11
	output wire  o_B34_L7P        , // # AA1    # FPGA_M0_SPI_nCS12
											    
	output wire  o_B34_L7N        , // # AB1    # M0_SPI_TX_CLK
	output wire  o_B34_L8P        , // # AB3    # M0_SPI_MOSI
	input  wire  i_B34_L8N        , // # AB2    # M0_SPI_RX_CLK
	input  wire  i_B34_L9P        , // # Y3     # M0_SPI_MISO
	
	//  # IO_B34_L9N              , // # AA3    # NA
	
	output wire  o_B34_L10P       , // # AA5    # FPGA_M1_SPI_nCS0
	output wire  o_B34_L10N       , // # AB5    # FPGA_M1_SPI_nCS1
	output wire  o_B34_L11P_SRCC  , // # Y4     # FPGA_M1_SPI_nCS2
	output wire  o_B34_L11N_SRCC  , // # AA4    # FPGA_M1_SPI_nCS3
	output wire  o_B34_L12P_MRCC  , // # V4     # FPGA_M1_SPI_nCS4
	output wire  o_B34_L12N_MRCC  , // # W4     # FPGA_M1_SPI_nCS5
	output wire  o_B34_L13P_MRCC  , // # R4     # FPGA_M1_SPI_nCS6
	output wire  o_B34_L13N_MRCC  , // # T4     # FPGA_M1_SPI_nCS7
	output wire  o_B34_L14P_SRCC  , // # T5     # FPGA_M1_SPI_nCS8
	output wire  o_B34_L14N_SRCC  , // # U5     # FPGA_M1_SPI_nCS9
	output wire  o_B34_L15P       , // # W6     # FPGA_M1_SPI_nCS10
	output wire  o_B34_L15N       , // # W5     # FPGA_M1_SPI_nCS11
	output wire  o_B34_L16P       , // # U6     # FPGA_M1_SPI_nCS12
											    
	output wire  o_B34_L16N       , // # V5     # M1_SPI_TX_CLK
	output wire  o_B34_L17P       , // # R6     # M1_SPI_MOSI
	input  wire  i_B34_L17N       , // # T6     # M1_SPI_RX_CLK
	input  wire  i_B34_L18P       , // # Y6     # M1_SPI_MISO
	
	//  # IO_B34_L18N             , // # AA6    # NA
											   
	output wire  o_B34_L19P       , // # V7     # TRIG
	output wire  o_B34_L19N       , // # W7     # SOT
	output wire  o_B34_L20P       , // # AB7    # PRE_TRIG
	
	//  # IO_B34_L20N             , // # AB6    # NA
	
	input  wire  i_B34_L21P       , // # V9     # FPGA_H_IN1
	input  wire  i_B34_L21N       , // # V8     # FPGA_H_IN2
	input  wire  i_B34_L22P       , // # AA8    # FPGA_H_IN3
	input  wire  i_B34_L22N       , // # AB8    # FPGA_H_IN4
											   
	output wire  o_B34_L23P       , // # Y8     # FPGA_H_OUT1
	output wire  o_B34_L23N       , // # Y7     # FPGA_H_OUT2
	output wire  o_B34_L24P       , // # W9     # FPGA_H_OUT3
	output wire  o_B34_L24N       , // # Y9     # FPGA_H_OUT4
											   
	output wire  o_B34_25         , // # U7     # FPGA_EXT_TRIG_OUT_D
	
	//}


	//// BANK B35 //{
	
	input  wire  i_B35_0_         , // # F4     # BUF_MASTER0
											   
	output wire  o_B35_L1P        , // # B1     # FPGA_M2_SPI_nCS0
	output wire  o_B35_L1N        , // # A1     # FPGA_M2_SPI_nCS1
	output wire  o_B35_L2P        , // # C2     # FPGA_M2_SPI_nCS2
	output wire  o_B35_L2N        , // # B2     # FPGA_M2_SPI_nCS3
	output wire  o_B35_L3P        , // # E1     # FPGA_M2_SPI_nCS4
	output wire  o_B35_L3N        , // # D1     # FPGA_M2_SPI_nCS5
	output wire  o_B35_L4P        , // # E2     # FPGA_M2_SPI_nCS6
	output wire  o_B35_L4N        , // # D2     # FPGA_M2_SPI_nCS7
	output wire  o_B35_L5P        , // # G1     # FPGA_M2_SPI_nCS8
	output wire  o_B35_L5N        , // # F1     # FPGA_M2_SPI_nCS9
	output wire  o_B35_L6P        , // # F3     # FPGA_M2_SPI_nCS10
	output wire  o_B35_L6N        , // # E3     # FPGA_M2_SPI_nCS11
	output wire  o_B35_L7P        , // # K1     # FPGA_M2_SPI_nCS12
											   
	output wire  o_B35_L7N        , // # J1     # M2_SPI_TX_CLK
	output wire  o_B35_L8P        , // # H2     # M2_SPI_MOSI
	input  wire  i_B35_L8N        , // # G2     # M2_SPI_RX_CLK
	input  wire  i_B35_L9P        , // # K2     # M2_SPI_MISO
											   
	// IO_B35_L9N        , // # J2    # NA     
											   
	output wire  o_B35_L10P       , // # J5     # FPGA_CAL_SPI_nCS0
	output wire  o_B35_L10N       , // # H5     # FPGA_CAL_SPI_nCS1
	output wire  o_B35_L11P_SRCC  , // # H3     # FPGA_CAL_SPI_nCS2
	output wire  o_B35_L11N_SRCC  , // # G3     # FPGA_CAL_SPI_nCS3
	output wire  o_B35_L12P_MRCC  , // # H4     # FPGA_CAL_SPI_nCS4
	output wire  o_B35_L12N_MRCC  , // # G4     # FPGA_CAL_SPI_nCS5
	output wire  o_B35_L13P_MRCC  , // # K4     # FPGA_CAL_SPI_nCS6
	output wire  o_B35_L13N_MRCC  , // # J4     # FPGA_CAL_SPI_nCS7
	output wire  o_B35_L14P_SRCC  , // # L3     # FPGA_CAL_SPI_nCS8
	output wire  o_B35_L14N_SRCC  , // # K3     # FPGA_CAL_SPI_nCS9
	output wire  o_B35_L15P       , // # M1     # FPGA_CAL_SPI_nCS10
	output wire  o_B35_L15N       , // # L1     # FPGA_CAL_SPI_nCS11
	output wire  o_B35_L16P       , // # M3     # FPGA_CAL_SPI_nCS12
											   
	output wire  o_B35_L16N       , // # M2     # FPGA_CAL_SPI_TX_CLK
	output wire  o_B35_L17P       , // # K6     # FPGA_CAL_SPI_MOSI
	input  wire  i_B35_L17N       , // # J6     # FPGA_CAL_SPI_MISO
	output wire  o_B35_L18P       , // # L5     # FPGA_nRESET_OUT
											   
	// IO_B35_L18N       , // # L4    # NA     
											   
	input  wire  i_B35_L19P       , // # N4     # BUF_LAN_IP0
	input  wire  i_B35_L19N       , // # N3     # BUF_LAN_IP1
	input  wire  i_B35_L20P       , // # R1     # BUF_LAN_IP2
	input  wire  i_B35_L20N       , // # P1     # BUF_LAN_IP3
											   
	output wire  o_B35_L21P       , // # P5     # FPGA_RESERVED0
	output wire  o_B35_L21N       , // # P4     # FPGA_RESERVED1
	output wire  o_B35_L22P       , // # P2     # FPGA_RESERVED2
											   
	output wire  o_B35_L22N       , // # N2     # EXT_TRIG_CW_IN
	output wire  o_B35_L23P       , // # M6     # EXT_TRIG_DIGITAL_IN
	output wire  o_B35_L23N       , // # M5     # EXT_TRIG_CW_OUT
	output wire  o_B35_L24P       , // # P6     # EXT_TRIG_DIGITAL_OUT
	output wire  o_B35_L24N       , // # N5     # EXT_TRIG_BYPASS
											   
	input  wire  i_B35_25         , // # L6     # BUF_MASTER1
	
	//}
	
	

	//// external clock ports on B13 //{
	input  wire  sys_clkp,  // # i_B13_L12P_MRCC  # W11 
	input  wire  sys_clkn,  // # i_B13_L12N_MRCC  # W12 
	//}

	//// XADC input on B0 //{
	input  wire  i_XADC_VP, // # L10   VP_0      CONFIG    
	input  wire  i_XADC_VN  // # M9    VN_0      CONFIG    
	//}
	
	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID = h_BD_21_0310   //{
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0407;   // S3100-CPU-BASE // pin map setup
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0416; // S3100-CPU-BASE // pll, endpoints setup
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0702; // S3100-CPU-BASE // MSPI-M0 - SSPI-M2 test
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0706; // S3100-CPU-BASE // update M0 M1 M2 CS pin control
//parameter FPGA_IMAGE_ID = 32'h_A0_21_07A6; // S3100-CPU-BASE // update spi miso pin control
//parameter FPGA_IMAGE_ID = 32'h_A0_21_0707; // S3100-CPU-BASE // revise master spi timing
parameter FPGA_IMAGE_ID = 32'h_A0_21_0708; // S3100-CPU-BASE // merge git


//}

//}


///TODO: //-------------------------------------------------------//


/* TODO: IO BUF assignment */ //{


//// BANK B14 IOBUF //{

wire FPGA_IO0;
wire FPGA_IO1;
wire FPGA_IO2;
wire FPGA_IO3;
wire FPGA_IO4;
wire FPGA_IO5;
OBUF obuf__FPGA_IO0__inst(.O( o_B14_L4P ), .I( FPGA_IO0 ) ); 
OBUF obuf__FPGA_IO1__inst(.O( o_B14_L4N ), .I( FPGA_IO1 ) ); 
OBUF obuf__FPGA_IO2__inst(.O( o_B14_L5P ), .I( FPGA_IO2 ) ); 
OBUF obuf__FPGA_IO3__inst(.O( o_B14_L5N ), .I( FPGA_IO3 ) ); 
OBUF obuf__FPGA_IO4__inst(.O( o_B14_L6N ), .I( FPGA_IO4 ) );
OBUF obuf__FPGA_IO5__inst(.O( o_B14_L7P ), .I( FPGA_IO5 ) );

wire FPGA_MBD_RS_422_SPI_EN  ;
wire FPGA_MBD_RS_422_TRIG_EN ;
wire FPGA_M0_SPI_TX_EN       ;
wire FPGA_M1_SPI_TX_EN       ;
wire FPGA_M2_SPI_TX_EN       ;
wire FPGA_TRIG_TX_EN         ;
OBUF obuf__FPGA_MBD_RS_422_SPI_EN___inst(.O( o_B14_L7N  ), .I( FPGA_MBD_RS_422_SPI_EN  ) );
OBUF obuf__FPGA_MBD_RS_422_TRIG_EN__inst(.O( o_B14_L8P  ), .I( FPGA_MBD_RS_422_TRIG_EN ) );
OBUF obuf__FPGA_M0_SPI_TX_EN________inst(.O( o_B14_L8N  ), .I( FPGA_M0_SPI_TX_EN       ) );
OBUF obuf__FPGA_M1_SPI_TX_EN________inst(.O( o_B14_L9P  ), .I( FPGA_M1_SPI_TX_EN       ) );
OBUF obuf__FPGA_M2_SPI_TX_EN________inst(.O( o_B14_L9N  ), .I( FPGA_M2_SPI_TX_EN       ) );
OBUF obuf__FPGA_TRIG_TX_EN__________inst(.O( o_B14_L10P ), .I( FPGA_TRIG_TX_EN         ) );

// ## LED
//$$ S3100 vs TXEM7310
//// note: fpga module    in B16 uses high-Z output // 7..0 ... B17,B16,A16,B15,A15,A14,B13,A13
//// note: S3100-CPU-BASE in B14 uses high-Z output // 7..0 ... V19,V18,Y19,Y18,W20,W19,V20,U20
(* keep = "true" *) wire [7:0] led; //$$
wire FPGA_LED0_tri = led[0];  wire FPGA_LED0_out = 1'b0;  wire FPGA_LED0_in; // *_in unused
wire FPGA_LED1_tri = led[1];  wire FPGA_LED1_out = 1'b0;  wire FPGA_LED1_in; // *_in unused
wire FPGA_LED2_tri = led[2];  wire FPGA_LED2_out = 1'b0;  wire FPGA_LED2_in; // *_in unused
wire FPGA_LED3_tri = led[3];  wire FPGA_LED3_out = 1'b0;  wire FPGA_LED3_in; // *_in unused
wire FPGA_LED4_tri = led[4];  wire FPGA_LED4_out = 1'b0;  wire FPGA_LED4_in; // *_in unused
wire FPGA_LED5_tri = led[5];  wire FPGA_LED5_out = 1'b0;  wire FPGA_LED5_in; // *_in unused
wire FPGA_LED6_tri = led[6];  wire FPGA_LED6_out = 1'b0;  wire FPGA_LED6_in; // *_in unused
wire FPGA_LED7_tri = led[7];  wire FPGA_LED7_out = 1'b0;  wire FPGA_LED7_in; // *_in unused
//
IOBUF iobuf__FPGA_LED0__inst(.IO(io_B14_L11P_SRCC ), .T( FPGA_LED0_tri ) , .I( FPGA_LED0_out ), .O( FPGA_LED0_in  ) ); 
IOBUF iobuf__FPGA_LED1__inst(.IO(io_B14_L11N_SRCC ), .T( FPGA_LED1_tri ) , .I( FPGA_LED1_out ), .O( FPGA_LED1_in  ) ); 
IOBUF iobuf__FPGA_LED2__inst(.IO(io_B14_L12P_MRCC ), .T( FPGA_LED2_tri ) , .I( FPGA_LED2_out ), .O( FPGA_LED2_in  ) ); 
IOBUF iobuf__FPGA_LED3__inst(.IO(io_B14_L12N_MRCC ), .T( FPGA_LED3_tri ) , .I( FPGA_LED3_out ), .O( FPGA_LED3_in  ) ); 
IOBUF iobuf__FPGA_LED4__inst(.IO(io_B14_L13P_MRCC ), .T( FPGA_LED4_tri ) , .I( FPGA_LED4_out ), .O( FPGA_LED4_in  ) ); 
IOBUF iobuf__FPGA_LED5__inst(.IO(io_B14_L13N_MRCC ), .T( FPGA_LED5_tri ) , .I( FPGA_LED5_out ), .O( FPGA_LED5_in  ) ); 
IOBUF iobuf__FPGA_LED6__inst(.IO(io_B14_L14P_SRCC ), .T( FPGA_LED6_tri ) , .I( FPGA_LED6_out ), .O( FPGA_LED6_in  ) ); 
IOBUF iobuf__FPGA_LED7__inst(.IO(io_B14_L14N_SRCC ), .T( FPGA_LED7_tri ) , .I( FPGA_LED7_out ), .O( FPGA_LED7_in  ) ); 


wire FPGA_GPIO_PB5 ;
wire FPGA_GPIO_PC4 ;
wire FPGA_GPIO_PC5 ;
wire FPGA_GPIO_PH4 ;
wire FPGA_GPIO_PH6 ;
wire FPGA_GPIO_PH7 ;
OBUF obuf__FPGA_GPIO_PB5__inst(.O( o_B14_L16N  ), .I( FPGA_GPIO_PB5 ) );
OBUF obuf__FPGA_GPIO_PC4__inst(.O( o_B14_L17P  ), .I( FPGA_GPIO_PC4 ) );
OBUF obuf__FPGA_GPIO_PC5__inst(.O( o_B14_L17N  ), .I( FPGA_GPIO_PC5 ) );
OBUF obuf__FPGA_GPIO_PH4__inst(.O( o_B14_L18P  ), .I( FPGA_GPIO_PH4 ) );
OBUF obuf__FPGA_GPIO_PH6__inst(.O( o_B14_L18N  ), .I( FPGA_GPIO_PH6 ) );
OBUF obuf__FPGA_GPIO_PH7__inst(.O( o_B14_L19P  ), .I( FPGA_GPIO_PH7 ) );
				 				 		 
wire FPGA_GPIO_PC9  ;
wire FPGA_GPIO_PC10 ;
wire FPGA_GPIO_PC11 ;
wire FPGA_GPIO_PC12 ;
wire FPGA_GPIO_PC13 ;
wire FPGA_GPIO_PC14 ;
wire FPGA_GPIO_PC15 ;
OBUF obuf__FPGA_GPIO_PC9___inst(.O( o_B14_L19N  ), .I( FPGA_GPIO_PC9  ) );
OBUF obuf__FPGA_GPIO_PC10__inst(.O( o_B14_L20P  ), .I( FPGA_GPIO_PC10 ) );
OBUF obuf__FPGA_GPIO_PC11__inst(.O( o_B14_L20N  ), .I( FPGA_GPIO_PC11 ) );
OBUF obuf__FPGA_GPIO_PC12__inst(.O( o_B14_L21P  ), .I( FPGA_GPIO_PC12 ) );
OBUF obuf__FPGA_GPIO_PC13__inst(.O( o_B14_L21N  ), .I( FPGA_GPIO_PC13 ) );
OBUF obuf__FPGA_GPIO_PC14__inst(.O( o_B14_L22P  ), .I( FPGA_GPIO_PC14 ) );
OBUF obuf__FPGA_GPIO_PC15__inst(.O( o_B14_L22N  ), .I( FPGA_GPIO_PC15 ) );

wire FPGA_GPIO_PD2  ;
wire FPGA_GPIO_PI8  ;
wire FPGA_GPIO_PA8  ;
wire FPGA_GPIO_PB11 ;
IBUF ibuf__FPGA_GPIO_PD2__inst(.I( i_B14_L23P ), .O( FPGA_GPIO_PD2  ) ); //
IBUF ibuf__FPGA_GPIO_PI8__inst(.I( i_B14_L23N ), .O( FPGA_GPIO_PI8  ) ); //
IBUF ibuf__FPGA_GPIO_PA8__inst(.I( i_B14_L24P ), .O( FPGA_GPIO_PA8  ) ); //
IBUF ibuf__FPGA_GPIO_PB11_inst(.I( i_B14_L24N ), .O( FPGA_GPIO_PB11 ) ); //

	
//}

//// BANK B15 IOBUF //{

wire F_RDY ;
wire BUF_FMC_CLK ;
OBUF obuf__F_RDY__inst      ( .O( o_B15_0_ ), .I( F_RDY        ) );
IBUF ibuf__BUF_FMC_CLK__inst( .I( i_B15_25 ), .O( BUF_FMC_CLK  ) );

(* keep = "true" *) wire [7:0] test_point;               //$$
wire  F_TP0 = test_point[0] ;
wire  F_TP1 = test_point[1] ;
wire  F_TP2 = test_point[2] ;
wire  F_TP3 = test_point[3] ;
wire  F_TP4 = test_point[4] ;
wire  F_TP5 = test_point[5] ;
wire  F_TP6 = test_point[6] ;
wire  F_TP7 = test_point[7] ;

OBUF obuf__F_TP0__inst(.O( o_B15_L2N_AD8N ), .I( F_TP0 ) );
OBUF obuf__F_TP1__inst(.O( o_B15_L5P_AD9P ), .I( F_TP1 ) );
OBUF obuf__F_TP2__inst(.O( o_B15_L5N_AD9N ), .I( F_TP2 ) );
OBUF obuf__F_TP3__inst(.O( o_B15_L2P_AD8P ), .I( F_TP3 ) );

OBUF obuf__F_TP4__inst(.O( o_B15_L3P_AD1P ), .I( F_TP4 ) );
OBUF obuf__F_TP5__inst(.O( o_B15_L3N_AD1N ), .I( F_TP5 ) );
OBUF obuf__F_TP6__inst(.O( o_B15_L1P_AD0P ), .I( F_TP6 ) );
OBUF obuf__F_TP7__inst(.O( o_B15_L1N_AD0N ), .I( F_TP7 ) );

wire EXT_I2C_4_SCL_in  ;
wire EXT_I2C_4_SDA_tri ; wire EXT_I2C_4_SDA_out ; wire EXT_I2C_4_SDA_in  ;
IBUF   ibuf__EXT_I2C_4_SCL__inst( .I( i_B15_L4P ), .O( EXT_I2C_4_SCL_in  ) );
IOBUF iobuf__EXT_I2C_4_SDA__inst(.IO(io_B15_L4N ), 
								                   .T( EXT_I2C_4_SDA_tri ) , 
								                   .I( EXT_I2C_4_SDA_out ) , 
								                   .O( EXT_I2C_4_SDA_in  ) ); 
								   
// ## LAN 
wire  LAN_PWDN    = 1'b0; // unused 
wire  LAN_RST_B   ;
wire  LAN_SSAUX_B = 1'b1; // unused 
wire  LAN_SSN_B   ;
wire  LAN_MOSI    ;
wire  LAN_SCLK    ;
wire  LAN_INT_B   ;
wire  LAN_MISO    ;
OBUF obuf__LAN_PWDN_____inst(.O( o_B15_L6P ), .I( LAN_PWDN    ) );
OBUF obuf__LAN_RST_B____inst(.O( o_B15_L9P ), .I( LAN_RST_B   ) );
OBUF obuf__LAN_SSAUX_B__inst(.O( o_B15_L6N ), .I( LAN_SSAUX_B ) );
OBUF obuf__LAN_SSN_B____inst(.O( o_B15_L8P ), .I( LAN_SSN_B   ) );
OBUF obuf__LAN_MOSI_____inst(.O( o_B15_L7P ), .I( LAN_MOSI    ) );
OBUF obuf__LAN_SCLK_____inst(.O( o_B15_L7N ), .I( LAN_SCLK    ) );
IBUF ibuf__LAN_INT_B____inst( .I( i_B15_L8N ), .O( LAN_INT_B   ) );
IBUF ibuf__LAN_MISO_____inst( .I( i_B15_L9N ), .O( LAN_MISO    ) );
	
// # H20  # AUX_AD11P ## unused
// # G20  # AUX_AD11N ## unused

// ## EEPROM 
//$$ S3100 vs TXEM7310
//// note: fpga module in PGU    uses io_B34_L5N       // Y1
//// note: S3100-CPU-BASE SCIO_0 uses io_B15_L11P_SRCC // J20
wire SCIO_0_tri ; wire SCIO_0_out ; wire SCIO_0_in  ;
wire SCIO_1_tri ; wire SCIO_1_out ; wire SCIO_1_in  ;
IOBUF iobuf__SCIO_0__inst(.IO(io_B15_L11P_SRCC ), 
			                   .T( SCIO_0_tri ) , 
			                   .I( SCIO_0_out ) , 
			                   .O( SCIO_0_in  ) ); 
IOBUF iobuf__SCIO_1__inst(.IO(io_B15_L11N_SRCC ), 
			                   .T( SCIO_1_tri ) , 
			                   .I( SCIO_1_out ) , 
			                   .O( SCIO_1_in  ) ); 

wire  GPIB_nCS      ;
wire  GPIB_nRESET   ;
wire  GPIB_SW_nOE   ;
wire  GPIB_DATA_DIR ;
wire  GPIB_DATA_nOE ;
wire  GPIB_IRQ      ;
wire  GPIB_REM      ;
wire  GPIB_TADCS    ;
wire  GPIB_LADCS    ;
wire  GPIB_DCAS     ;
wire  GPIB_TRIG     ;
OBUF obuf__GPIB_nCS_______inst(.O( o_B15_L12N_MRCC ), .I( GPIB_nCS      ) );
OBUF obuf__GPIB_nRESET____inst(.O( o_B15_L13P_MRCC ), .I( GPIB_nRESET   ) );
OBUF obuf__GPIB_SW_nOE____inst(.O( o_B15_L13N_MRCC ), .I( GPIB_SW_nOE   ) );
OBUF obuf__GPIB_DATA_DIR__inst(.O( o_B15_L16N      ), .I( GPIB_DATA_DIR ) );
OBUF obuf__GPIB_DATA_nOE__inst(.O( o_B15_L17P      ), .I( GPIB_DATA_nOE ) );
IBUF ibuf__GPIB_IRQ_______inst( .I( i_B15_L12P_MRCC ), .O( GPIB_IRQ      ) );
IBUF ibuf__GPIB_REM_______inst( .I( i_B15_L14P_SRCC ), .O( GPIB_REM      ) );
IBUF ibuf__GPIB_TADCS_____inst( .I( i_B15_L14N_SRCC ), .O( GPIB_TADCS    ) );
IBUF ibuf__GPIB_LADCS_____inst( .I( i_B15_L15P      ), .O( GPIB_LADCS    ) );
IBUF ibuf__GPIB_DCAS______inst( .I( i_B15_L15N      ), .O( GPIB_DCAS     ) );
IBUF ibuf__GPIB_TRIG______inst( .I( i_B15_L16P      ), .O( GPIB_TRIG     ) );

// # N19  # NA
							        
wire  BA25 ;
wire  BA24 ;
wire  BA23 ;
wire  BA22 ;
wire  BA21 ;
wire  BA20 ;
wire  BA19 ;
wire  BA18 ;
wire  BA7  ;
wire  BA6  ;
wire  BA5  ;
wire  BA4  ;
wire  BA3  ;
wire  BA2  ;
IBUF ibuf__BA25__inst( .I( i_B15_L18P ), .O( BA25 ) );
IBUF ibuf__BA24__inst( .I( i_B15_L18N ), .O( BA24 ) );
IBUF ibuf__BA23__inst( .I( i_B15_L19P ), .O( BA23 ) );
IBUF ibuf__BA22__inst( .I( i_B15_L19N ), .O( BA22 ) );
IBUF ibuf__BA21__inst( .I( i_B15_L20P ), .O( BA21 ) );
IBUF ibuf__BA20__inst( .I( i_B15_L20N ), .O( BA20 ) );
IBUF ibuf__BA19__inst( .I( i_B15_L21P ), .O( BA19 ) );
IBUF ibuf__BA18__inst( .I( i_B15_L21N ), .O( BA18 ) );
IBUF ibuf__BA7___inst( .I( i_B15_L22P ), .O( BA7  ) );
IBUF ibuf__BA6___inst( .I( i_B15_L22N ), .O( BA6  ) );
IBUF ibuf__BA5___inst( .I( i_B15_L23P ), .O( BA5  ) );
IBUF ibuf__BA4___inst( .I( i_B15_L23N ), .O( BA4  ) );
IBUF ibuf__BA3___inst( .I( i_B15_L24P ), .O( BA3  ) );
IBUF ibuf__BA2___inst( .I( i_B15_L24N ), .O( BA2  ) );


//}

//// BANK B16 IOBUF //{

wire  BASE_F_LED_ERR ;
wire  RUN_FPGA_LED   ;
wire  BUF_nRESET     ;
OBUF obuf__BASE_F_LED_ERR__inst(.O( o_B16_0_   ), .I( BASE_F_LED_ERR ) );
OBUF obuf__RUN_FPGA_LED____inst(.O( o_B16_25   ), .I( RUN_FPGA_LED   ) );
IBUF ibuf__BUF_nRESET______inst( .I( i_B16_L24N ), .O( BUF_nRESET     ) );
	
wire BD0__tri ;  wire BD0__out ;  wire BD0__in ;
wire BD1__tri ;  wire BD1__out ;  wire BD1__in ;
wire BD2__tri ;  wire BD2__out ;  wire BD2__in ;
wire BD3__tri ;  wire BD3__out ;  wire BD3__in ;
wire BD4__tri ;  wire BD4__out ;  wire BD4__in ;
wire BD5__tri ;  wire BD5__out ;  wire BD5__in ;
wire BD6__tri ;  wire BD6__out ;  wire BD6__in ;
wire BD7__tri ;  wire BD7__out ;  wire BD7__in ;
wire BD8__tri ;  wire BD8__out ;  wire BD8__in ;
wire BD9__tri ;  wire BD9__out ;  wire BD9__in ;
wire BD10_tri ;  wire BD10_out ;  wire BD10_in ;
wire BD11_tri ;  wire BD11_out ;  wire BD11_in ;
wire BD12_tri ;  wire BD12_out ;  wire BD12_in ;
wire BD13_tri ;  wire BD13_out ;  wire BD13_in ;
wire BD14_tri ;  wire BD14_out ;  wire BD14_in ;
wire BD15_tri ;  wire BD15_out ;  wire BD15_in ;
wire BD16_tri ;  wire BD16_out ;  wire BD16_in ;
wire BD17_tri ;  wire BD17_out ;  wire BD17_in ;
wire BD18_tri ;  wire BD18_out ;  wire BD18_in ;
wire BD19_tri ;  wire BD19_out ;  wire BD19_in ;
wire BD20_tri ;  wire BD20_out ;  wire BD20_in ;
wire BD21_tri ;  wire BD21_out ;  wire BD21_in ;
wire BD22_tri ;  wire BD22_out ;  wire BD22_in ;
wire BD23_tri ;  wire BD23_out ;  wire BD23_in ;
wire BD24_tri ;  wire BD24_out ;  wire BD24_in ;
wire BD25_tri ;  wire BD25_out ;  wire BD25_in ;
wire BD26_tri ;  wire BD26_out ;  wire BD26_in ;
wire BD27_tri ;  wire BD27_out ;  wire BD27_in ;
wire BD28_tri ;  wire BD28_out ;  wire BD28_in ;
wire BD29_tri ;  wire BD29_out ;  wire BD29_in ;
wire BD30_tri ;  wire BD30_out ;  wire BD30_in ;
wire BD31_tri ;  wire BD31_out ;  wire BD31_in ;
IOBUF iobuf__BD0___inst(.IO( io_B16_L1P  ), .T( BD0__tri ), .I( BD0__out ), .O( BD0__in  ) ); 
IOBUF iobuf__BD1___inst(.IO( io_B16_L1N  ), .T( BD1__tri ), .I( BD1__out ), .O( BD1__in  ) ); 
IOBUF iobuf__BD2___inst(.IO( io_B16_L2P  ), .T( BD2__tri ), .I( BD2__out ), .O( BD2__in  ) ); 
IOBUF iobuf__BD3___inst(.IO( io_B16_L2N  ), .T( BD3__tri ), .I( BD3__out ), .O( BD3__in  ) ); 
IOBUF iobuf__BD4___inst(.IO( io_B16_L3P  ), .T( BD4__tri ), .I( BD4__out ), .O( BD4__in  ) ); 
IOBUF iobuf__BD5___inst(.IO( io_B16_L3N  ), .T( BD5__tri ), .I( BD5__out ), .O( BD5__in  ) ); 
IOBUF iobuf__BD6___inst(.IO( io_B16_L4P  ), .T( BD6__tri ), .I( BD6__out ), .O( BD6__in  ) ); 
IOBUF iobuf__BD7___inst(.IO( io_B16_L4N  ), .T( BD7__tri ), .I( BD7__out ), .O( BD7__in  ) ); 
IOBUF iobuf__BD8___inst(.IO( io_B16_L5P  ), .T( BD8__tri ), .I( BD8__out ), .O( BD8__in  ) ); 
IOBUF iobuf__BD9___inst(.IO( io_B16_L5N  ), .T( BD9__tri ), .I( BD9__out ), .O( BD9__in  ) ); 
IOBUF iobuf__BD10__inst(.IO( io_B16_L6P  ), .T( BD10_tri ), .I( BD10_out ), .O( BD10_in  ) ); 
IOBUF iobuf__BD11__inst(.IO( io_B16_L6N  ), .T( BD11_tri ), .I( BD11_out ), .O( BD11_in  ) ); 
IOBUF iobuf__BD12__inst(.IO( io_B16_L7P  ), .T( BD12_tri ), .I( BD12_out ), .O( BD12_in  ) ); 
IOBUF iobuf__BD13__inst(.IO( io_B16_L7N  ), .T( BD13_tri ), .I( BD13_out ), .O( BD13_in  ) ); 
IOBUF iobuf__BD14__inst(.IO( io_B16_L8P  ), .T( BD14_tri ), .I( BD14_out ), .O( BD14_in  ) ); 
IOBUF iobuf__BD15__inst(.IO( io_B16_L8N  ), .T( BD15_tri ), .I( BD15_out ), .O( BD15_in  ) ); 
IOBUF iobuf__BD16__inst(.IO( io_B16_L9P  ), .T( BD16_tri ), .I( BD16_out ), .O( BD16_in  ) ); 
IOBUF iobuf__BD17__inst(.IO( io_B16_L9N  ), .T( BD17_tri ), .I( BD17_out ), .O( BD17_in  ) ); 
IOBUF iobuf__BD18__inst(.IO( io_B16_L10P ), .T( BD18_tri ), .I( BD18_out ), .O( BD18_in  ) ); 
IOBUF iobuf__BD19__inst(.IO( io_B16_L10N ), .T( BD19_tri ), .I( BD19_out ), .O( BD19_in  ) ); 
IOBUF iobuf__BD20__inst(.IO( io_B16_L11P ), .T( BD20_tri ), .I( BD20_out ), .O( BD20_in  ) ); 
IOBUF iobuf__BD21__inst(.IO( io_B16_L11N ), .T( BD21_tri ), .I( BD21_out ), .O( BD21_in  ) ); 
IOBUF iobuf__BD22__inst(.IO( io_B16_L12P ), .T( BD22_tri ), .I( BD22_out ), .O( BD22_in  ) ); 
IOBUF iobuf__BD23__inst(.IO( io_B16_L12N ), .T( BD23_tri ), .I( BD23_out ), .O( BD23_in  ) ); 
IOBUF iobuf__BD24__inst(.IO( io_B16_L13P ), .T( BD24_tri ), .I( BD24_out ), .O( BD24_in  ) ); 
IOBUF iobuf__BD25__inst(.IO( io_B16_L13N ), .T( BD25_tri ), .I( BD25_out ), .O( BD25_in  ) ); 
IOBUF iobuf__BD26__inst(.IO( io_B16_L14P ), .T( BD26_tri ), .I( BD26_out ), .O( BD26_in  ) ); 
IOBUF iobuf__BD27__inst(.IO( io_B16_L14N ), .T( BD27_tri ), .I( BD27_out ), .O( BD27_in  ) ); 
IOBUF iobuf__BD28__inst(.IO( io_B16_L15P ), .T( BD28_tri ), .I( BD28_out ), .O( BD28_in  ) ); 
IOBUF iobuf__BD29__inst(.IO( io_B16_L15N ), .T( BD29_tri ), .I( BD29_out ), .O( BD29_in  ) ); 
IOBUF iobuf__BD30__inst(.IO( io_B16_L16P ), .T( BD30_tri ), .I( BD30_out ), .O( BD30_in  ) ); 
IOBUF iobuf__BD31__inst(.IO( io_B16_L16N ), .T( BD31_tri ), .I( BD31_out ), .O( BD31_in  ) ); 

// # A18  # NA

wire  BUF_DATA_DIR ;
wire  nBUF_DATA_OE ;
OBUF obuf__BUF_DATA_DIR__inst(.O( o_B16_L17N ), .I( BUF_DATA_DIR ) );
OBUF obuf__nBUF_DATA_OE__inst(.O( o_B16_L18P ), .I( nBUF_DATA_OE ) );

// # F20  # NA

wire  INTER_RELAY_O ;
wire  INTER_LED_O   ;
wire  INTER_LOCK_ON ;
OBUF obuf__INTER_RELAY_O__inst(.O( o_B16_L19P ), .I( INTER_RELAY_O ) );
OBUF obuf__INTER_LED_O____inst(.O( o_B16_L19N ), .I( INTER_LED_O   ) );
IBUF ibuf__INTER_LOCK_ON__inst( .I( i_B16_L20P ), .O( INTER_LOCK_ON ) );

// # B22  # NA

wire  nBNE1 ;
wire  nBNE2 ;
wire  nBNE3 ;
wire  nBNE4 ;
wire  nBOE  ;
wire  nBWE  ;
IBUF ibuf__nBNE1__inst( .I( i_B16_L21P ), .O( nBNE1 ) );
IBUF ibuf__nBNE2__inst( .I( i_B16_L21N ), .O( nBNE2 ) );
IBUF ibuf__nBNE3__inst( .I( i_B16_L22P ), .O( nBNE3 ) );
IBUF ibuf__nBNE4__inst( .I( i_B16_L22N ), .O( nBNE4 ) );
IBUF ibuf__nBOE___inst( .I( i_B16_L23P ), .O( nBOE  ) );
IBUF ibuf__nBWE___inst( .I( i_B16_L23N ), .O( nBWE  ) );
	
// # G21  # NA
	

//}

//// BANK B13 IOBUF //{

// # Y17  # NA
											  
wire  SPI__1_SCLK ;
wire  SPI__1_nCS  ;
wire  SPI__1_MOSI ;
wire  SPI__1_MISO ;
IBUF ibuf__SPI__1_SCLK__inst( .I( i_B13_L1P ), .O( SPI__1_SCLK ) );
IBUF ibuf__SPI__1_nCS___inst( .I( i_B13_L1N ), .O( SPI__1_nCS  ) );
IBUF ibuf__SPI__1_MOSI__inst( .I( i_B13_L2P ), .O( SPI__1_MOSI ) );
OBUF obuf__SPI__1_MISO__inst(.O( o_B13_L2N ), .I( SPI__1_MISO ) );

wire  SPI__2_SCLK ;
wire  SPI__2_nCS  ;
wire  SPI__2_MOSI ;
wire  SPI__2_MISO ;
IBUF ibuf__SPI__2_SCLK__inst( .I( i_B13_L3P ), .O( SPI__2_SCLK ) );
IBUF ibuf__SPI__2_nCS___inst( .I( i_B13_L3N ), .O( SPI__2_nCS  ) );
IBUF ibuf__SPI__2_MOSI__inst( .I( i_B13_L4P ), .O( SPI__2_MOSI ) );
OBUF obuf__SPI__2_MISO__inst(.O( o_B13_L4N ), .I( SPI__2_MISO ) );

wire  QSPI_BK1_NCS ;
wire  QSPI_CLK     ;
wire  QSPI_BK1_IO0_tri ; wire  QSPI_BK1_IO0_out ; wire  QSPI_BK1_IO0_in ;
wire  QSPI_BK1_IO1_tri ; wire  QSPI_BK1_IO1_out ; wire  QSPI_BK1_IO1_in ;
wire  QSPI_BK1_IO2_tri ; wire  QSPI_BK1_IO2_out ; wire  QSPI_BK1_IO2_in ;
wire  QSPI_BK1_IO3_tri ; wire  QSPI_BK1_IO3_out ; wire  QSPI_BK1_IO3_in ;
IBUF ibuf__QSPI_BK1_NCS__inst( .I( i_B13_L5P ), .O( QSPI_BK1_NCS ) );
IBUF ibuf__QSPI_CLK______inst( .I( i_B13_L5N ), .O( QSPI_CLK     ) );
IOBUF iobuf__QSPI_BK1_IO0__inst(.IO( io_B13_L6P  ), .T( QSPI_BK1_IO0_tri ), .I( QSPI_BK1_IO0_out ), .O( QSPI_BK1_IO0_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO1__inst(.IO( io_B13_L6N  ), .T( QSPI_BK1_IO1_tri ), .I( QSPI_BK1_IO1_out ), .O( QSPI_BK1_IO1_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO2__inst(.IO( io_B13_L7P  ), .T( QSPI_BK1_IO2_tri ), .I( QSPI_BK1_IO2_out ), .O( QSPI_BK1_IO2_in  ) ); 
IOBUF iobuf__QSPI_BK1_IO3__inst(.IO( io_B13_L7N  ), .T( QSPI_BK1_IO3_tri ), .I( QSPI_BK1_IO3_out ), .O( QSPI_BK1_IO3_in  ) ); 

// # AA9    # NA

wire  ETH_nRESET   ;
wire  ETH_nCS      ;
wire  ETH_nIRQ     ;
wire  ETH_nLINKLED ;
wire  ETH_nTXLED   ;
wire  ETH_nRXLED   ;
OBUF obuf__ETH_nRESET____inst( .O( o_B13_L9P       ), .I( ETH_nRESET   ) );
OBUF obuf__ETH_nCS_______inst( .O( o_B13_L9N       ), .I( ETH_nCS      ) );
IBUF ibuf__ETH_nIRQ______inst( .I( i_B13_L8N       ), .O( ETH_nIRQ     ) );
IBUF ibuf__ETH_nLINKLED__inst( .I( i_B13_L10P      ), .O( ETH_nLINKLED ) );
IBUF ibuf__ETH_nTXLED____inst( .I( i_B13_L10N      ), .O( ETH_nTXLED   ) );
IBUF ibuf__ETH_nRXLED____inst( .I( i_B13_L11P_SRCC ), .O( ETH_nRXLED   ) );

// # Y12    # NA

// # W11    # clocks sys_clkp (*)
// # W12    # clocks sys_clkn (*)

wire  SYNC_10MHz     ;
wire  EXT_TRIG_IN_CW ;
IBUF ibuf__SYNC_10MHz______inst( .I( i_B13_L13P_MRCC ), .O( SYNC_10MHz ) );
IBUF ibuf__EXT_TRIG_IN_CW__inst( .I( i_B13_L13N_MRCC ), .O( EXT_TRIG_IN_CW ) );

wire  FPGA_FAN_SENS_0 ;
wire  FPGA_FAN_SENS_1 ;
wire  FPGA_FAN_SENS_2 ;
wire  FPGA_FAN_SENS_3 ;
wire  FPGA_FAN_SENS_4 ;
wire  FPGA_FAN_SENS_5 ;
wire  FPGA_FAN_SENS_6 ;
wire  FPGA_FAN_SENS_7 ;
IBUF ibuf__FPGA_FAN_SENS_0__inst( .I( i_B13_L14P_SRCC ), .O( FPGA_FAN_SENS_0 ) );
IBUF ibuf__FPGA_FAN_SENS_1__inst( .I( i_B13_L14N_SRCC ), .O( FPGA_FAN_SENS_1 ) );
IBUF ibuf__FPGA_FAN_SENS_2__inst( .I( i_B13_L15P      ), .O( FPGA_FAN_SENS_2 ) );
IBUF ibuf__FPGA_FAN_SENS_3__inst( .I( i_B13_L15N      ), .O( FPGA_FAN_SENS_3 ) );
IBUF ibuf__FPGA_FAN_SENS_4__inst( .I( i_B13_L16P      ), .O( FPGA_FAN_SENS_4 ) );
IBUF ibuf__FPGA_FAN_SENS_5__inst( .I( i_B13_L16N      ), .O( FPGA_FAN_SENS_5 ) );
IBUF ibuf__FPGA_FAN_SENS_6__inst( .I( i_B13_L17P      ), .O( FPGA_FAN_SENS_6 ) );
IBUF ibuf__FPGA_FAN_SENS_7__inst( .I( i_B13_L17N      ), .O( FPGA_FAN_SENS_7 ) );

//}

//// BANK B34 IOBUF //{

wire  FPGA_EXT_TRIG_IN_D  ;
wire  FPGA_EXT_TRIG_OUT_D ;
IBUF ibuf__FPGA_EXT_TRIG_IN_D___inst(.I( i_B34_0_ ), .O( FPGA_EXT_TRIG_IN_D  ) );
OBUF obuf__FPGA_EXT_TRIG_OUT_D__inst(.O( o_B34_25 ), .I( FPGA_EXT_TRIG_OUT_D ) );
											    
wire  FPGA_M0_SPI_nCS0_;
wire  FPGA_M0_SPI_nCS1_;
wire  FPGA_M0_SPI_nCS2_;
wire  FPGA_M0_SPI_nCS3_;
wire  FPGA_M0_SPI_nCS4_;
wire  FPGA_M0_SPI_nCS5_;
wire  FPGA_M0_SPI_nCS6_;
wire  FPGA_M0_SPI_nCS7_;
wire  FPGA_M0_SPI_nCS8_;
wire  FPGA_M0_SPI_nCS9_;
wire  FPGA_M0_SPI_nCS10;
wire  FPGA_M0_SPI_nCS11;
wire  FPGA_M0_SPI_nCS12;
OBUF obuf__FPGA_M0_SPI_nCS0___inst(.O( o_B34_L1P ), .I( FPGA_M0_SPI_nCS0_ ) );
OBUF obuf__FPGA_M0_SPI_nCS1___inst(.O( o_B34_L1N ), .I( FPGA_M0_SPI_nCS1_ ) );
OBUF obuf__FPGA_M0_SPI_nCS2___inst(.O( o_B34_L2P ), .I( FPGA_M0_SPI_nCS2_ ) );
OBUF obuf__FPGA_M0_SPI_nCS3___inst(.O( o_B34_L2N ), .I( FPGA_M0_SPI_nCS3_ ) );
OBUF obuf__FPGA_M0_SPI_nCS4___inst(.O( o_B34_L3P ), .I( FPGA_M0_SPI_nCS4_ ) );
OBUF obuf__FPGA_M0_SPI_nCS5___inst(.O( o_B34_L3N ), .I( FPGA_M0_SPI_nCS5_ ) );
OBUF obuf__FPGA_M0_SPI_nCS6___inst(.O( o_B34_L4P ), .I( FPGA_M0_SPI_nCS6_ ) );
OBUF obuf__FPGA_M0_SPI_nCS7___inst(.O( o_B34_L4N ), .I( FPGA_M0_SPI_nCS7_ ) );
OBUF obuf__FPGA_M0_SPI_nCS8___inst(.O( o_B34_L5P ), .I( FPGA_M0_SPI_nCS8_ ) );
OBUF obuf__FPGA_M0_SPI_nCS9___inst(.O( o_B34_L5N ), .I( FPGA_M0_SPI_nCS9_ ) );
OBUF obuf__FPGA_M0_SPI_nCS10__inst(.O( o_B34_L6P ), .I( FPGA_M0_SPI_nCS10 ) );
OBUF obuf__FPGA_M0_SPI_nCS11__inst(.O( o_B34_L6N ), .I( FPGA_M0_SPI_nCS11 ) );
OBUF obuf__FPGA_M0_SPI_nCS12__inst(.O( o_B34_L7P ), .I( FPGA_M0_SPI_nCS12 ) );
											    
wire  M0_SPI_TX_CLK ;
wire  M0_SPI_MOSI   ;
wire  M0_SPI_RX_CLK ;
wire  M0_SPI_MISO   ;
OBUF obuf__M0_SPI_TX_CLK__inst(.O( o_B34_L7N ), .I( M0_SPI_TX_CLK ) );
OBUF obuf__M0_SPI_MOSI____inst(.O( o_B34_L8P ), .I( M0_SPI_MOSI   ) );
IBUF ibuf__M0_SPI_RX_CLK__inst(.I( i_B34_L8N ), .O( M0_SPI_RX_CLK ) );
IBUF ibuf__M0_SPI_MISO____inst(.I( i_B34_L9P ), .O( M0_SPI_MISO   ) );
	
// # AA3    # NA
	
wire  FPGA_M1_SPI_nCS0_ ;
wire  FPGA_M1_SPI_nCS1_ ;
wire  FPGA_M1_SPI_nCS2_ ;
wire  FPGA_M1_SPI_nCS3_ ;
wire  FPGA_M1_SPI_nCS4_ ;
wire  FPGA_M1_SPI_nCS5_ ;
wire  FPGA_M1_SPI_nCS6_ ;
wire  FPGA_M1_SPI_nCS7_ ;
wire  FPGA_M1_SPI_nCS8_ ;
wire  FPGA_M1_SPI_nCS9_ ;
wire  FPGA_M1_SPI_nCS10 ;
wire  FPGA_M1_SPI_nCS11 ;
wire  FPGA_M1_SPI_nCS12 ;
OBUF obuf__FPGA_M1_SPI_nCS0___inst(.O( o_B34_L10P      ), .I( FPGA_M1_SPI_nCS0_ ) );
OBUF obuf__FPGA_M1_SPI_nCS1___inst(.O( o_B34_L10N      ), .I( FPGA_M1_SPI_nCS1_ ) );
OBUF obuf__FPGA_M1_SPI_nCS2___inst(.O( o_B34_L11P_SRCC ), .I( FPGA_M1_SPI_nCS2_ ) );
OBUF obuf__FPGA_M1_SPI_nCS3___inst(.O( o_B34_L11N_SRCC ), .I( FPGA_M1_SPI_nCS3_ ) );
OBUF obuf__FPGA_M1_SPI_nCS4___inst(.O( o_B34_L12P_MRCC ), .I( FPGA_M1_SPI_nCS4_ ) );
OBUF obuf__FPGA_M1_SPI_nCS5___inst(.O( o_B34_L12N_MRCC ), .I( FPGA_M1_SPI_nCS5_ ) );
OBUF obuf__FPGA_M1_SPI_nCS6___inst(.O( o_B34_L13P_MRCC ), .I( FPGA_M1_SPI_nCS6_ ) );
OBUF obuf__FPGA_M1_SPI_nCS7___inst(.O( o_B34_L13N_MRCC ), .I( FPGA_M1_SPI_nCS7_ ) );
OBUF obuf__FPGA_M1_SPI_nCS8___inst(.O( o_B34_L14P_SRCC ), .I( FPGA_M1_SPI_nCS8_ ) );
OBUF obuf__FPGA_M1_SPI_nCS9___inst(.O( o_B34_L14N_SRCC ), .I( FPGA_M1_SPI_nCS9_ ) );
OBUF obuf__FPGA_M1_SPI_nCS10__inst(.O( o_B34_L15P      ), .I( FPGA_M1_SPI_nCS10 ) );
OBUF obuf__FPGA_M1_SPI_nCS11__inst(.O( o_B34_L15N      ), .I( FPGA_M1_SPI_nCS11 ) );
OBUF obuf__FPGA_M1_SPI_nCS12__inst(.O( o_B34_L16P      ), .I( FPGA_M1_SPI_nCS12 ) );
									     		    
wire  M1_SPI_TX_CLK ;
wire  M1_SPI_MOSI   ;
wire  M1_SPI_RX_CLK ;
wire  M1_SPI_MISO   ;
OBUF obuf__M1_SPI_TX_CLK__inst(.O( o_B34_L16N ), .I( M1_SPI_TX_CLK ) );
OBUF obuf__M1_SPI_MOSI____inst(.O( o_B34_L17P ), .I( M1_SPI_MOSI   ) );
IBUF ibuf__M1_SPI_RX_CLK__inst(.I( i_B34_L17N ), .O( M1_SPI_RX_CLK ) );
IBUF ibuf__M1_SPI_MISO____inst(.I( i_B34_L18P ), .O( M1_SPI_MISO   ) );
	
// # AA6    # NA
											   
wire  TRIG     ;
wire  SOT      ;
wire  PRE_TRIG ;
OBUF obuf__TRIG______inst(.O( o_B34_L19P ), .I( TRIG     ) );
OBUF obuf__SOT_______inst(.O( o_B34_L19N ), .I( SOT      ) );
OBUF obuf__PRE_TRIG__inst(.O( o_B34_L20P ), .I( PRE_TRIG ) );
	
// # AB6    # NA
	
wire  FPGA_H_IN1 ;
wire  FPGA_H_IN2 ;
wire  FPGA_H_IN3 ;
wire  FPGA_H_IN4 ;
IBUF ibuf__FPGA_H_IN1__inst( .I( i_B34_L21P ), .O( FPGA_H_IN1 ) );
IBUF ibuf__FPGA_H_IN2__inst( .I( i_B34_L21N ), .O( FPGA_H_IN2 ) );
IBUF ibuf__FPGA_H_IN3__inst( .I( i_B34_L22P ), .O( FPGA_H_IN3 ) );
IBUF ibuf__FPGA_H_IN4__inst( .I( i_B34_L22N ), .O( FPGA_H_IN4 ) );
											   
wire  FPGA_H_OUT1 ;
wire  FPGA_H_OUT2 ;
wire  FPGA_H_OUT3 ;
wire  FPGA_H_OUT4 ;
OBUF obuf__FPGA_H_OUT1__inst(.O( o_B34_L23P ), .I( FPGA_H_OUT1 ) );
OBUF obuf__FPGA_H_OUT2__inst(.O( o_B34_L23N ), .I( FPGA_H_OUT2 ) );
OBUF obuf__FPGA_H_OUT3__inst(.O( o_B34_L24P ), .I( FPGA_H_OUT3 ) );
OBUF obuf__FPGA_H_OUT4__inst(.O( o_B34_L24N ), .I( FPGA_H_OUT4 ) );
											   


//}

//// BANK B35 IOBUF //{

wire  BUF_MASTER0 ;
wire  BUF_MASTER1 ;
IBUF ibuf__BUF_MASTER0__inst(.I( i_B35_0_ ), .O( BUF_MASTER0 ) );
IBUF ibuf__BUF_MASTER1__inst(.I( i_B35_25 ), .O( BUF_MASTER1 ) );
											   
wire  FPGA_M2_SPI_nCS0_ ;
wire  FPGA_M2_SPI_nCS1_ ;
wire  FPGA_M2_SPI_nCS2_ ;
wire  FPGA_M2_SPI_nCS3_ ;
wire  FPGA_M2_SPI_nCS4_ ;
wire  FPGA_M2_SPI_nCS5_ ;
wire  FPGA_M2_SPI_nCS6_ ;
wire  FPGA_M2_SPI_nCS7_ ;
wire  FPGA_M2_SPI_nCS8_ ;
wire  FPGA_M2_SPI_nCS9_ ;
wire  FPGA_M2_SPI_nCS10 ;
wire  FPGA_M2_SPI_nCS11 ;
wire  FPGA_M2_SPI_nCS12 ;
OBUF obuf__FPGA_M2_SPI_nCS0___inst(.O( o_B35_L1P ), .I( FPGA_M2_SPI_nCS0_ ) );
OBUF obuf__FPGA_M2_SPI_nCS1___inst(.O( o_B35_L1N ), .I( FPGA_M2_SPI_nCS1_ ) );
OBUF obuf__FPGA_M2_SPI_nCS2___inst(.O( o_B35_L2P ), .I( FPGA_M2_SPI_nCS2_ ) );
OBUF obuf__FPGA_M2_SPI_nCS3___inst(.O( o_B35_L2N ), .I( FPGA_M2_SPI_nCS3_ ) );
OBUF obuf__FPGA_M2_SPI_nCS4___inst(.O( o_B35_L3P ), .I( FPGA_M2_SPI_nCS4_ ) );
OBUF obuf__FPGA_M2_SPI_nCS5___inst(.O( o_B35_L3N ), .I( FPGA_M2_SPI_nCS5_ ) );
OBUF obuf__FPGA_M2_SPI_nCS6___inst(.O( o_B35_L4P ), .I( FPGA_M2_SPI_nCS6_ ) );
OBUF obuf__FPGA_M2_SPI_nCS7___inst(.O( o_B35_L4N ), .I( FPGA_M2_SPI_nCS7_ ) );
OBUF obuf__FPGA_M2_SPI_nCS8___inst(.O( o_B35_L5P ), .I( FPGA_M2_SPI_nCS8_ ) );
OBUF obuf__FPGA_M2_SPI_nCS9___inst(.O( o_B35_L5N ), .I( FPGA_M2_SPI_nCS9_ ) );
OBUF obuf__FPGA_M2_SPI_nCS10__inst(.O( o_B35_L6P ), .I( FPGA_M2_SPI_nCS10 ) );
OBUF obuf__FPGA_M2_SPI_nCS11__inst(.O( o_B35_L6N ), .I( FPGA_M2_SPI_nCS11 ) );
OBUF obuf__FPGA_M2_SPI_nCS12__inst(.O( o_B35_L7P ), .I( FPGA_M2_SPI_nCS12 ) );
											   
wire  M2_SPI_TX_CLK ;
wire  M2_SPI_MOSI   ;
wire  M2_SPI_RX_CLK ;
wire  M2_SPI_MISO   ;
OBUF obuf__M2_SPI_TX_CLK__inst(.O( o_B35_L7N ), .I( M2_SPI_TX_CLK ) );
OBUF obuf__M2_SPI_MOSI____inst(.O( o_B35_L8P ), .I( M2_SPI_MOSI   ) );
IBUF ibuf__M2_SPI_RX_CLK__inst(.I( i_B35_L8N ), .O( M2_SPI_RX_CLK ) );
IBUF ibuf__M2_SPI_MISO____inst(.I( i_B35_L9P ), .O( M2_SPI_MISO   ) );
											   
// # J2    # NA     
											   
wire  FPGA_CAL_SPI_nCS0_ ;
wire  FPGA_CAL_SPI_nCS1_ ;
wire  FPGA_CAL_SPI_nCS2_ ;
wire  FPGA_CAL_SPI_nCS3_ ;
wire  FPGA_CAL_SPI_nCS4_ ;
wire  FPGA_CAL_SPI_nCS5_ ;
wire  FPGA_CAL_SPI_nCS6_ ;
wire  FPGA_CAL_SPI_nCS7_ ;
wire  FPGA_CAL_SPI_nCS8_ ;
wire  FPGA_CAL_SPI_nCS9_ ;
wire  FPGA_CAL_SPI_nCS10 ;
wire  FPGA_CAL_SPI_nCS11 ;
wire  FPGA_CAL_SPI_nCS12 ;
OBUF obuf__FPGA_CAL_SPI_nCS0___inst(.O( o_B35_L10P      ), .I( FPGA_CAL_SPI_nCS0_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS1___inst(.O( o_B35_L10N      ), .I( FPGA_CAL_SPI_nCS1_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS2___inst(.O( o_B35_L11P_SRCC ), .I( FPGA_CAL_SPI_nCS2_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS3___inst(.O( o_B35_L11N_SRCC ), .I( FPGA_CAL_SPI_nCS3_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS4___inst(.O( o_B35_L12P_MRCC ), .I( FPGA_CAL_SPI_nCS4_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS5___inst(.O( o_B35_L12N_MRCC ), .I( FPGA_CAL_SPI_nCS5_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS6___inst(.O( o_B35_L13P_MRCC ), .I( FPGA_CAL_SPI_nCS6_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS7___inst(.O( o_B35_L13N_MRCC ), .I( FPGA_CAL_SPI_nCS7_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS8___inst(.O( o_B35_L14P_SRCC ), .I( FPGA_CAL_SPI_nCS8_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS9___inst(.O( o_B35_L14N_SRCC ), .I( FPGA_CAL_SPI_nCS9_ ) );
OBUF obuf__FPGA_CAL_SPI_nCS10__inst(.O( o_B35_L15P      ), .I( FPGA_CAL_SPI_nCS10 ) );
OBUF obuf__FPGA_CAL_SPI_nCS11__inst(.O( o_B35_L15N      ), .I( FPGA_CAL_SPI_nCS11 ) );
OBUF obuf__FPGA_CAL_SPI_nCS12__inst(.O( o_B35_L16P      ), .I( FPGA_CAL_SPI_nCS12 ) );
											   
wire  FPGA_CAL_SPI_TX_CLK ;
wire  FPGA_CAL_SPI_MOSI   ;
wire  FPGA_CAL_SPI_MISO   ;
OBUF obuf__FPGA_CAL_SPI_TX_CLK__inst(.O( o_B35_L16N ), .I( FPGA_CAL_SPI_TX_CLK ) );
OBUF obuf__FPGA_CAL_SPI_MOSI____inst(.O( o_B35_L17P ), .I( FPGA_CAL_SPI_MOSI   ) );
IBUF ibuf__FPGA_CAL_SPI_MISO____inst(.I( i_B35_L17N ), .O( FPGA_CAL_SPI_MISO   ) );

wire FPGA_nRESET_OUT ;
OBUF obuf__FPGA_nRESET_OUT__inst(.O( o_B35_L18P ), .I( FPGA_nRESET_OUT ) );
											   
// # L4    # NA     
											   
wire  BUF_LAN_IP0 ;
wire  BUF_LAN_IP1 ;
wire  BUF_LAN_IP2 ;
wire  BUF_LAN_IP3 ;
IBUF ibuf__BUF_LAN_IP0__inst(.I( i_B35_L19P ), .O( BUF_LAN_IP0  ) );
IBUF ibuf__BUF_LAN_IP1__inst(.I( i_B35_L19N ), .O( BUF_LAN_IP1  ) );
IBUF ibuf__BUF_LAN_IP2__inst(.I( i_B35_L20P ), .O( BUF_LAN_IP2  ) );
IBUF ibuf__BUF_LAN_IP3__inst(.I( i_B35_L20N ), .O( BUF_LAN_IP3  ) );
											   
wire  FPGA_RESERVED0 ;
wire  FPGA_RESERVED1 ;
wire  FPGA_RESERVED2 ;
OBUF obuf__FPGA_RESERVED0__inst(.O( o_B35_L21P ), .I( FPGA_RESERVED0 ) );
OBUF obuf__FPGA_RESERVED1__inst(.O( o_B35_L21N ), .I( FPGA_RESERVED1 ) );
OBUF obuf__FPGA_RESERVED2__inst(.O( o_B35_L22P ), .I( FPGA_RESERVED2 ) );
											   
wire  EXT_TRIG_CW_IN       ;
wire  EXT_TRIG_DIGITAL_IN  ;
wire  EXT_TRIG_CW_OUT      ;
wire  EXT_TRIG_DIGITAL_OUT ;
wire  EXT_TRIG_BYPASS      ;
OBUF obuf__EXT_TRIG_CW_IN________inst(.O( o_B35_L22N ), .I( EXT_TRIG_CW_IN       ) );
OBUF obuf__EXT_TRIG_DIGITAL_IN___inst(.O( o_B35_L23P ), .I( EXT_TRIG_DIGITAL_IN  ) );
OBUF obuf__EXT_TRIG_CW_OUT_______inst(.O( o_B35_L23N ), .I( EXT_TRIG_CW_OUT      ) );
OBUF obuf__EXT_TRIG_DIGITAL_OUT__inst(.O( o_B35_L24P ), .I( EXT_TRIG_DIGITAL_OUT ) );
OBUF obuf__EXT_TRIG_BYPASS_______inst(.O( o_B35_L24N ), .I( EXT_TRIG_BYPASS      ) );
											   

//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: clock/pll and reset */ //{

// clock pll0 //{
wire clk_out1_200M ; // REFCLK 200MHz for IDELAYCTRL // for pll1
wire clk_out2_140M ; // for pll2 ... 140M
wire clk_out3_10M  ; // for slow logic / I2C //
wire clk_out4_10M ; // for XADC 
//
wire clk_locked_pre;
clk_wiz_0  clk_wiz_0_inst(
	// MMCM
	// VCO 700MHz
	// Clock out ports  
	.clk_out1_200M (clk_out1_200M ), // BUFG
	.clk_out2_140M (clk_out2_140M ), // BUFG
	// Status and control signals               
	.locked(clk_locked_pre),
	// Clock in ports
	.clk_in1_p(sys_clkp), // diff clock pin
	.clk_in1_n(sys_clkn)
);
////
clk_wiz_0_0_1  clk_wiz_0_0_1_inst(
	// Clock out ports  
	.clk_out1_10M (clk_out3_10M), // BUFGCE // due to soft-startup
	.clk_out2_10M (clk_out4_10M), // BUFGCE // due to soft-startup
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(), // not used
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll1 //{

wire clk1_locked = 1'b1; // unused // to remove

//}

// clock pll2 //{


wire clk2_locked = 1'b1; // unused // to remove



//}

// clock pll3 //{
wire clk3_out1_72M ; // MCS core; IO bridge
wire clk3_out2_144M; // LAN-SPI control 144MHz 
wire clk3_out3_12M ; // slow logic // not used yet
wire clk3_out4_72M ; // eeprom fifo
//
wire clk3_locked;
//
clk_wiz_0_3_1  clk_wiz_0_3_1_inst(
	// Clock out ports  
	.clk_out1_72M (clk3_out1_72M ), // BUFGCE // due to soft-startup 
	.clk_out2_144M(clk3_out2_144M), // BUFGCE // due to soft-startup
	.clk_out3_12M (clk3_out3_12M ), // BUFGCE // due to soft-startup
	.clk_out4_72M (clk3_out4_72M ), // BUFGCE // due to soft-startup 
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(clk3_locked),
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll4 //{

wire clk4_locked = 1'b1; // to remove


//}



// clock locked //{
wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked;
//}

// system clock //{
wire sys_clk	= clk_out3_10M;
//}

// system reset //{
wire reset_n	= clk_locked;
wire reset		= ~reset_n;
//}

// other alias clocks //{
wire mcs_clk             = clk3_out1_72M;
wire lan_clk             = clk3_out2_144M;
wire mcs_eeprom_fifo_clk = clk3_out4_72M;
wire xadc_clk            = clk_out4_10M;
//}





// clock for MTH SPI //{

wire base_sspi_clk; // base clock for slave SPI // 104MHz
wire p_sspi_clk;    // p_clk for SSPI // 13MHz = base / 8

wire clk_2_locked = 1'b1;

// clk_wiz_2_2
wire clk_2_2_locked; //$$ unused
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

//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: end-point wires */ //{

// end-points : SSPI vs LAN 
//
// endpoint modules :
//
// (USB) ok_endpoint_wrapper : usb host interface <--> end-points //$$ removed
//    okHost okHI
//    ok...
//
// (LAN) lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1  soft_cpu_mcs_inst
//    mcs_io_bridge_ext  mcs_io_bridge_inst2
//    master_spi_wz850_ext  master_spi_wz850_inst
//    fifo_generator_3  LAN_fifo_wr_inst
//    fifo_generator_3  LAN_fifo_rd_inst
//
// (SSPI) slave_spi_mth_brd : MTH slave SPI <--> end-points
//   


//// TODO: USB --> SSPI end-point wires: //{

// Wire In 		0x00 - 0x1F //{
wire [31:0] ep00wire; //
wire [31:0] ep01wire; //$$ [TEST] TEST_CON     //$$ S3100
wire [31:0] ep02wire; //$$ [SSPI] SSPI_CON_WI  //$$ S3100
wire [31:0] ep03wire; //$$ [TEST] BRD_CON      //$$ S3100
wire [31:0] ep04wire; //
wire [31:0] ep05wire; //
wire [31:0] ep06wire; //
wire [31:0] ep07wire; //
wire [31:0] ep08wire; //
wire [31:0] ep09wire; //
wire [31:0] ep0Awire; //
wire [31:0] ep0Bwire; //
wire [31:0] ep0Cwire; //
wire [31:0] ep0Dwire; //
wire [31:0] ep0Ewire; //
wire [31:0] ep0Fwire; //
wire [31:0] ep10wire; //
wire [31:0] ep11wire; //
wire [31:0] ep12wire; //$$ [MEM] MEM_FDAT_WI    //$$ S3100
wire [31:0] ep13wire; //$$ [MEM] MEM_WI         //$$ S3100
wire [31:0] ep14wire; //
wire [31:0] ep15wire; //
wire [31:0] ep16wire; //$$ [MSPI] MSPI_EN_CS_WI //$$ S3100 
wire [31:0] ep17wire; //$$ [MSPI] MSPI_CON_WI   //$$ S3100  // SSPI_TEST_WI // for MTH spi master test 
wire [31:0] ep18wire; //
wire [31:0] ep19wire; //$$ [MCS] MCS_SETUP_WI   //$$ S3100
wire [31:0] ep1Awire; //
wire [31:0] ep1Bwire; //
wire [31:0] ep1Cwire; //
wire [31:0] ep1Dwire; //
wire [31:0] ep1Ewire; //
wire [31:0] ep1Fwire; //
//}

// Wire Out 	0x20 - 0x3F //{
wire [31:0] ep20wire;         //$$ [TEST] FPGA_IMAGE_ID  //$$ S3100
wire [31:0] ep21wire;         //$$ [TEST] TEST_OUT       //$$ S3100
wire [31:0] ep22wire;         //$$ [TEST] TIMESTAMP_WO   //$$ S3100
wire [31:0] ep23wire;         //$$ [SSPI] SSPI_FLAG_WO   //$$ S3100
wire [31:0] ep24wire;         //$$ [MSPI] MSPI_FLAG_WO   //$$ S3100 // SSPI_TEST_WO //$$
wire [31:0] ep25wire = 32'b0; //
wire [31:0] ep26wire = 32'b0; //
wire [31:0] ep27wire = 32'b0; //
wire [31:0] ep28wire = 32'b0; //
wire [31:0] ep29wire = 32'b0; //
wire [31:0] ep2Awire = 32'b0; //
wire [31:0] ep2Bwire = 32'b0; //
wire [31:0] ep2Cwire = 32'b0; //
wire [31:0] ep2Dwire = 32'b0; //
wire [31:0] ep2Ewire = 32'b0; //
wire [31:0] ep2Fwire = 32'b0; //
wire [31:0] ep30wire = 32'b0; //
wire [31:0] ep31wire = 32'b0; //
wire [31:0] ep32wire = 32'b0; //
wire [31:0] ep33wire = 32'b0; //
wire [31:0] ep34wire = 32'b0; //
wire [31:0] ep35wire = 32'b0; //
wire [31:0] ep36wire = 32'b0; //
wire [31:0] ep37wire = 32'b0; //
wire [31:0] ep38wire = 32'b0; //
wire [31:0] ep39wire = 32'b0; //
wire [31:0] ep3Awire;         //$$ [XADC] XADC_TEMP       //$$ S3100
wire [31:0] ep3Bwire;         //$$ [XADC] XADC_VOLT       //$$ S3100
wire [31:0] ep3Cwire = 32'b0; //
wire [31:0] ep3Dwire = 32'b0; //
wire [31:0] ep3Ewire = 32'b0; //
wire [31:0] ep3Fwire = 32'b0; //
//}

// Trigger In 	0x40 - 0x5F //{
wire ep40ck = sys_clk;          wire [31:0] ep40trig; //$$ [TEST] TEST_TI  //$$ S3100
wire ep41ck = 1'b0;             wire [31:0] ep41trig;
wire ep42ck = base_sspi_clk;    wire [31:0] ep42trig; //$$ [MSPI] MSPI_TI  //$$ S3100
wire ep43ck = 1'b0;             wire [31:0] ep43trig; 
wire ep44ck = 1'b0;             wire [31:0] ep44trig; 
wire ep45ck = 1'b0;             wire [31:0] ep45trig; 
wire ep46ck = 1'b0;             wire [31:0] ep46trig; 
wire ep47ck = 1'b0;             wire [31:0] ep47trig; 
wire ep48ck = 1'b0;             wire [31:0] ep48trig; 
wire ep49ck = 1'b0;             wire [31:0] ep49trig;
wire ep4Ack = 1'b0;             wire [31:0] ep4Atrig;
wire ep4Bck = 1'b0;             wire [31:0] ep4Btrig;
wire ep4Cck = 1'b0;             wire [31:0] ep4Ctrig;
wire ep4Dck = 1'b0;             wire [31:0] ep4Dtrig;
wire ep4Eck = 1'b0;             wire [31:0] ep4Etrig;
wire ep4Fck = 1'b0;             wire [31:0] ep4Ftrig;
wire ep50ck = 1'b0;             wire [31:0] ep50trig;
wire ep51ck = 1'b0;             wire [31:0] ep51trig;
wire ep52ck = 1'b0;             wire [31:0] ep52trig;
wire ep53ck = sys_clk;          wire [31:0] ep53trig; //$$ [MEM] MEM_TI  //$$ S3100
wire ep54ck = 1'b0;             wire [31:0] ep54trig;
wire ep55ck = 1'b0;             wire [31:0] ep55trig;
wire ep56ck = 1'b0;             wire [31:0] ep56trig;
wire ep57ck = 1'b0;             wire [31:0] ep57trig;
wire ep58ck = 1'b0;             wire [31:0] ep58trig;
wire ep59ck = 1'b0;             wire [31:0] ep59trig;
wire ep5Ack = 1'b0;             wire [31:0] ep5Atrig;
wire ep5Bck = 1'b0;             wire [31:0] ep5Btrig;
wire ep5Cck = 1'b0;             wire [31:0] ep5Ctrig;
wire ep5Dck = 1'b0;             wire [31:0] ep5Dtrig;
wire ep5Eck = 1'b0;             wire [31:0] ep5Etrig;
wire ep5Fck = 1'b0;             wire [31:0] ep5Ftrig;
//}

// Trigger Out 	0x60 - 0x7F //{
wire ep60ck = sys_clk;          wire [31:0] ep60trig; //$$ [TEST] TEST_TO  //$$ S3100
wire ep61ck = 1'b0;             wire [31:0] ep61trig = 32'b0;
wire ep62ck = base_sspi_clk;    wire [31:0] ep62trig; //$$ [MSPI] MSPI_TO  //$$ S3100
wire ep63ck = 1'b0;             wire [31:0] ep63trig = 32'b0;
wire ep64ck = 1'b0;             wire [31:0] ep64trig = 32'b0;
wire ep65ck = 1'b0;             wire [31:0] ep65trig = 32'b0;
wire ep66ck = 1'b0;             wire [31:0] ep66trig = 32'b0;
wire ep67ck = 1'b0;             wire [31:0] ep67trig = 32'b0;
wire ep68ck = 1'b0;             wire [31:0] ep68trig = 32'b0;
wire ep69ck = 1'b0;             wire [31:0] ep69trig = 32'b0;
wire ep6Ack = 1'b0;             wire [31:0] ep6Atrig = 32'b0;
wire ep6Bck = 1'b0;             wire [31:0] ep6Btrig = 32'b0;
wire ep6Cck = 1'b0;             wire [31:0] ep6Ctrig = 32'b0;
wire ep6Dck = 1'b0;             wire [31:0] ep6Dtrig = 32'b0;
wire ep6Eck = 1'b0;             wire [31:0] ep6Etrig = 32'b0;
wire ep6Fck = 1'b0;             wire [31:0] ep6Ftrig = 32'b0;
wire ep70ck = 1'b0;             wire [31:0] ep70trig = 32'b0;
wire ep71ck = 1'b0;             wire [31:0] ep71trig = 32'b0;
wire ep72ck = 1'b0;             wire [31:0] ep72trig = 32'b0;
wire ep73ck = sys_clk;          wire [31:0] ep73trig; //$$ [MEM] MEM_TO  //$$ S3100
wire ep74ck = 1'b0;             wire [31:0] ep74trig = 32'b0;
wire ep75ck = 1'b0;             wire [31:0] ep75trig = 32'b0;
wire ep76ck = 1'b0;             wire [31:0] ep76trig = 32'b0;
wire ep77ck = 1'b0;             wire [31:0] ep77trig = 32'b0;
wire ep78ck = 1'b0;             wire [31:0] ep78trig = 32'b0;
wire ep79ck = 1'b0;             wire [31:0] ep79trig = 32'b0;
wire ep7Ack = 1'b0;             wire [31:0] ep7Atrig = 32'b0;
wire ep7Bck = 1'b0;             wire [31:0] ep7Btrig = 32'b0;
wire ep7Cck = 1'b0;             wire [31:0] ep7Ctrig = 32'b0;
wire ep7Dck = 1'b0;             wire [31:0] ep7Dtrig = 32'b0;
wire ep7Eck = 1'b0;             wire [31:0] ep7Etrig = 32'b0;
wire ep7Fck = 1'b0;             wire [31:0] ep7Ftrig = 32'b0; 
//}

// Pipe In 		0x80 - 0x9F // clock is assumed to use okClk //{
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
wire ep93wr; wire [31:0] ep93pipe; //$$ [MEM] MEM_PI  //$$ S3100
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
wire epA0rd; wire [31:0] epA0pipe = 32'b0;
wire epA1rd; wire [31:0] epA1pipe = 32'b0;
wire epA2rd; wire [31:0] epA2pipe = 32'b0;
wire epA3rd; wire [31:0] epA3pipe = 32'b0;
wire epA4rd; wire [31:0] epA4pipe = 32'b0;
wire epA5rd; wire [31:0] epA5pipe = 32'b0;
wire epA6rd; wire [31:0] epA6pipe = 32'b0;
wire epA7rd; wire [31:0] epA7pipe = 32'b0;
wire epA8rd; wire [31:0] epA8pipe = 32'b0;
wire epA9rd; wire [31:0] epA9pipe = 32'b0;
wire epAArd; wire [31:0] epAApipe = 32'b0;
wire epABrd; wire [31:0] epABpipe = 32'b0;
wire epACrd; wire [31:0] epACpipe = 32'b0;
wire epADrd; wire [31:0] epADpipe = 32'b0;
wire epAErd; wire [31:0] epAEpipe = 32'b0;
wire epAFrd; wire [31:0] epAFpipe = 32'b0;
wire epB0rd; wire [31:0] epB0pipe = 32'b0;
wire epB1rd; wire [31:0] epB1pipe = 32'b0;
wire epB2rd; wire [31:0] epB2pipe = 32'b0;
wire epB3rd; wire [31:0] epB3pipe; //$$ [MEM] MEM_PO  //$$ S3100
wire epB4rd; wire [31:0] epB4pipe = 32'b0;
wire epB5rd; wire [31:0] epB5pipe = 32'b0;
wire epB6rd; wire [31:0] epB6pipe = 32'b0;
wire epB7rd; wire [31:0] epB7pipe = 32'b0;
wire epB8rd; wire [31:0] epB8pipe = 32'b0;
wire epB9rd; wire [31:0] epB9pipe = 32'b0;
wire epBArd; wire [31:0] epBApipe = 32'b0;
wire epBBrd; wire [31:0] epBBpipe = 32'b0;
wire epBCrd; wire [31:0] epBCpipe = 32'b0;
wire epBDrd; wire [31:0] epBDpipe = 32'b0;
wire epBErd; wire [31:0] epBEpipe = 32'b0;
wire epBFrd; wire [31:0] epBFpipe = 32'b0;
//}

// OK Target interface clk: //{
//
wire okClk;
//}

//}

//// TODO: LAN end-point wires: //{

// wire in //{
wire [31:0] w_port_wi_00_1; // PGU
wire [31:0] w_port_wi_01_1; // PGU
wire [31:0] w_port_wi_02_1;
wire [31:0] w_port_wi_03_1; // PGU
wire [31:0] w_port_wi_04_1; // PGU
wire [31:0] w_port_wi_05_1; // PGU
wire [31:0] w_port_wi_06_1; // PGU
wire [31:0] w_port_wi_07_1; // PGU
wire [31:0] w_port_wi_08_1; // PGU
wire [31:0] w_port_wi_09_1;
wire [31:0] w_port_wi_0A_1;
wire [31:0] w_port_wi_0B_1;
wire [31:0] w_port_wi_0C_1;
wire [31:0] w_port_wi_0D_1;
wire [31:0] w_port_wi_0E_1;
wire [31:0] w_port_wi_0F_1;
wire [31:0] w_port_wi_10_1;
wire [31:0] w_port_wi_11_1;
wire [31:0] w_port_wi_12_1;
wire [31:0] w_port_wi_13_1;
wire [31:0] w_port_wi_14_1;
wire [31:0] w_port_wi_15_1;
wire [31:0] w_port_wi_16_1;
wire [31:0] w_port_wi_17_1;
wire [31:0] w_port_wi_18_1;
wire [31:0] w_port_wi_19_1;
wire [31:0] w_port_wi_1A_1;
wire [31:0] w_port_wi_1B_1;
wire [31:0] w_port_wi_1C_1;
wire [31:0] w_port_wi_1D_1;
wire [31:0] w_port_wi_1E_1;
wire [31:0] w_port_wi_1F_1;
//}

// wire out //{
wire [31:0] w_port_wo_20_1; // PGU
wire [31:0] w_port_wo_21_1; // PGU
wire [31:0] w_port_wo_22_1; // PGU
wire [31:0] w_port_wo_23_1; // PGU
wire [31:0] w_port_wo_24_1; // PGU
wire [31:0] w_port_wo_25_1; // PGU
wire [31:0] w_port_wo_26_1; // PGU
wire [31:0] w_port_wo_27_1; // PGU
wire [31:0] w_port_wo_28_1; // PGU
wire [31:0] w_port_wo_29_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2A_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2B_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2C_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2D_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2E_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_2F_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_30_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_31_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_32_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_33_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_34_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_35_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_36_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_37_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_38_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_39_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3A_1; // PGU
wire [31:0] w_port_wo_3B_1; // PGU
wire [31:0] w_port_wo_3C_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3D_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3E_1 = 32'b0; // not yet used
wire [31:0] w_port_wo_3F_1 = 32'b0; // not yet used
//}

// trig in //{
wire w_ck_40_1 = sys_clk       ; wire [31:0] w_port_ti_40_1; // 
wire w_ck_42_1 = base_sspi_clk ; wire [31:0] w_port_ti_42_1; // S3100
wire w_ck_43_1 = sys_clk       ; wire [31:0] w_port_ti_43_1; // 
wire w_ck_44_1 = sys_clk       ; wire [31:0] w_port_ti_44_1; // 
wire w_ck_45_1 = sys_clk       ; wire [31:0] w_port_ti_45_1; // 
wire w_ck_46_1 = sys_clk       ; wire [31:0] w_port_ti_46_1; // 
wire w_ck_47_1 = sys_clk       ; wire [31:0] w_port_ti_47_1; // 
wire w_ck_48_1 = sys_clk       ; wire [31:0] w_port_ti_48_1; // 
wire w_ck_53_1 = sys_clk       ; wire [31:0] w_port_ti_53_1; // MEM
//}

// trig out //{
wire w_ck_60_1 = sys_clk       ; wire [31:0] w_port_to_60_1; // 
wire w_ck_62_1 = base_sspi_clk ; wire [31:0] w_port_to_62_1; // S3100
wire w_ck_73_1 = sys_clk       ; wire [31:0] w_port_to_73_1; 
//}

// pipe in //{
wire w_wr_84_1; wire [31:0] w_port_pi_84_1; // PGU
wire w_wr_85_1; wire [31:0] w_port_pi_85_1; // PGU
wire w_wr_86_1; wire [31:0] w_port_pi_86_1; // PGU
wire w_wr_87_1; wire [31:0] w_port_pi_87_1; // PGU
wire w_wr_88_1; wire [31:0] w_port_pi_88_1; // PGU
wire w_wr_89_1; wire [31:0] w_port_pi_89_1; // PGU
wire w_wr_8A_1; wire [31:0] w_port_pi_8A_1; // test fifo // MCS only
wire w_wr_93_1; wire [31:0] w_port_pi_93_1; // [MEM] MEM_PI
//}

// pipe out //{
wire w_rd_AA_1; wire [31:0] w_port_po_AA_1; // test fifo // MCS only
wire w_rd_B3_1; wire [31:0] w_port_po_B3_1; // [MEM] MEM_PO
//}

//$$ TODO: pipe clock //{
wire w_ck_pipe; // not used // mcs_eeprom_fifo_clk vs epPPck from lan_endpoint_wrapper
//wire w_ck_pipe = clk3_out1_72M;
//}

//}

//}


///TODO: //-------------------------------------------------------//


/* TODO: END-POINTS wrapper for EP_LAN */ //{

// offset definition for mcs_io_bridge.v //{

//#define MCS_IO_INST_OFFSET              0x00000000 // for LAN
//#define MCS_IO_INST_OFFSET_CMU          0x00010000 // for CMU
//#define MCS_IO_INST_OFFSET_PGU          0x00020000 // for PGU
//#define MCS_IO_INST_OFFSET_EXT          0x00030000 // for MHVSU_BASE (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_CMU      0x00040000 // for NEW CMU (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_PGU      0x00050000 // for NEW PGU (port end-points + lan end-points) //$$ to come

//}

// lan_endpoint_wrapper   //{

wire [47:0] w_adrs_offset_mac_48b       ; // BASE = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ??48 bits
wire [31:0] w_adrs_offset_ip_32b        ; // BASE = {8'd192,8'd168,8'd168,8'd112};         // 192.168.168.112 or C0:A8:A8:70 ??32 bits
wire [15:0] w_offset_lan_timeout_rtr_16b; //
wire [15:0] w_offset_lan_timeout_rcr_16b; //

wire  EP_LAN_MOSI ; 
wire  EP_LAN_SCLK ; 
wire  EP_LAN_CS_B ; 
wire  EP_LAN_INT_B; 
wire  EP_LAN_RST_B; 
wire  EP_LAN_MISO ; 

// asign for pin map 
assign  LAN_RST_B   = EP_LAN_RST_B  ;
assign  LAN_SSN_B   = EP_LAN_CS_B   ;
assign  LAN_MOSI    = EP_LAN_MOSI   ;
assign  LAN_SCLK    = EP_LAN_SCLK   ;
//
assign  EP_LAN_INT_B  = LAN_INT_B   ;
assign  EP_LAN_MISO   = LAN_MISO    ;

lan_endpoint_wrapper #(
	//.MCS_IO_INST_OFFSET			(32'h_0004_0000), //$$ for CMU2020
	//.MCS_IO_INST_OFFSET			(32'h_0005_0000), //$$ for PGU2020 or S3000-PGU
	.MCS_IO_INST_OFFSET			(32'h_0006_0000), //$$ for S3100-CPU-BASE
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID)  
) lan_endpoint_wrapper_inst(
	
	//// pins and config //{
	
	// EP_LAN pins 
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
	
	//}

	// Wire In 		0x00 - 0x1F  //{
	.ep00wire (w_port_wi_00_1), // output wire [31:0]
	.ep01wire (w_port_wi_01_1), // output wire [31:0]
	.ep02wire (w_port_wi_02_1), // output wire [31:0]
	.ep03wire (w_port_wi_03_1), // output wire [31:0]
	.ep04wire (w_port_wi_04_1), // output wire [31:0]
	.ep05wire (w_port_wi_05_1), // output wire [31:0]
	.ep06wire (w_port_wi_06_1), // output wire [31:0]
	.ep07wire (w_port_wi_07_1), // output wire [31:0]
	.ep08wire (w_port_wi_08_1), // output wire [31:0]
	.ep09wire (w_port_wi_09_1), // output wire [31:0]
	.ep0Awire (w_port_wi_0A_1), // output wire [31:0]
	.ep0Bwire (w_port_wi_0B_1), // output wire [31:0]
	.ep0Cwire (w_port_wi_0C_1), // output wire [31:0]
	.ep0Dwire (w_port_wi_0D_1), // output wire [31:0]
	.ep0Ewire (w_port_wi_0E_1), // output wire [31:0]
	.ep0Fwire (w_port_wi_0F_1), // output wire [31:0]
	.ep10wire (w_port_wi_10_1), // output wire [31:0]
	.ep11wire (w_port_wi_11_1), // output wire [31:0]
	.ep12wire (w_port_wi_12_1), // output wire [31:0]
	.ep13wire (w_port_wi_13_1), // output wire [31:0]
	.ep14wire (w_port_wi_14_1), // output wire [31:0]
	.ep15wire (w_port_wi_15_1), // output wire [31:0]
	.ep16wire (w_port_wi_16_1), // output wire [31:0]
	.ep17wire (w_port_wi_17_1), // output wire [31:0]
	.ep18wire (w_port_wi_18_1), // output wire [31:0]
	.ep19wire (w_port_wi_19_1), // output wire [31:0]
	.ep1Awire (w_port_wi_1A_1), // output wire [31:0]
	.ep1Bwire (w_port_wi_1B_1), // output wire [31:0]
	.ep1Cwire (w_port_wi_1C_1), // output wire [31:0]
	.ep1Dwire (w_port_wi_1D_1), // output wire [31:0]
	.ep1Ewire (w_port_wi_1E_1), // output wire [31:0]
	.ep1Fwire (w_port_wi_1F_1), // output wire [31:0]
	//}
	
	// Wire Out 	0x20 - 0x3F //{
	.ep20wire (w_port_wo_20_1), // input wire [31:0]
	.ep21wire (w_port_wo_21_1), // input wire [31:0]
	.ep22wire (w_port_wo_22_1), // input wire [31:0]
	.ep23wire (w_port_wo_23_1), // input wire [31:0]
	.ep24wire (w_port_wo_24_1), // input wire [31:0]
	.ep25wire (w_port_wo_25_1), // input wire [31:0]
	.ep26wire (w_port_wo_26_1), // input wire [31:0]
	.ep27wire (w_port_wo_27_1), // input wire [31:0]
	.ep28wire (w_port_wo_28_1), // input wire [31:0]
	.ep29wire (w_port_wo_29_1), // input wire [31:0]
	.ep2Awire (w_port_wo_2A_1), // input wire [31:0]
	.ep2Bwire (w_port_wo_2B_1), // input wire [31:0]
	.ep2Cwire (w_port_wo_2C_1), // input wire [31:0]
	.ep2Dwire (w_port_wo_2D_1), // input wire [31:0]
	.ep2Ewire (w_port_wo_2E_1), // input wire [31:0]
	.ep2Fwire (w_port_wo_2F_1), // input wire [31:0]
	.ep30wire (w_port_wo_30_1), // input wire [31:0]
	.ep31wire (w_port_wo_31_1), // input wire [31:0]
	.ep32wire (w_port_wo_32_1), // input wire [31:0]
	.ep33wire (w_port_wo_33_1), // input wire [31:0]
	.ep34wire (w_port_wo_34_1), // input wire [31:0]
	.ep35wire (w_port_wo_35_1), // input wire [31:0]
	.ep36wire (w_port_wo_36_1), // input wire [31:0]
	.ep37wire (w_port_wo_37_1), // input wire [31:0]
	.ep38wire (w_port_wo_38_1), // input wire [31:0]
	.ep39wire (w_port_wo_39_1), // input wire [31:0]
	.ep3Awire (w_port_wo_3A_1), // input wire [31:0]
	.ep3Bwire (w_port_wo_3B_1), // input wire [31:0]
	.ep3Cwire (w_port_wo_3C_1), // input wire [31:0]
	.ep3Dwire (w_port_wo_3D_1), // input wire [31:0]
	.ep3Ewire (w_port_wo_3E_1), // input wire [31:0]
	.ep3Fwire (w_port_wo_3F_1), // input wire [31:0]
	//}
	
	// Trigger In 	0x40 - 0x5F //{
	.ep40ck (w_ck_40_1), .ep40trig (w_port_ti_40_1), // input wire, output wire [31:0],
	.ep41ck (1'b0),      .ep41trig (), // input wire, output wire [31:0],
	.ep42ck (w_ck_42_1), .ep42trig (w_port_ti_42_1), // input wire, output wire [31:0],
	.ep43ck (w_ck_43_1), .ep43trig (w_port_ti_43_1), // input wire, output wire [31:0],
	.ep44ck (w_ck_44_1), .ep44trig (w_port_ti_44_1), // input wire, output wire [31:0],
	.ep45ck (w_ck_45_1), .ep45trig (w_port_ti_45_1), // input wire, output wire [31:0],
	.ep46ck (w_ck_46_1), .ep46trig (w_port_ti_46_1), // input wire, output wire [31:0],
	.ep47ck (w_ck_47_1), .ep47trig (w_port_ti_47_1), // input wire, output wire [31:0],
	.ep48ck (w_ck_48_1), .ep48trig (w_port_ti_48_1), // input wire, output wire [31:0],
	.ep49ck (1'b0),      .ep49trig (), // input wire, output wire [31:0],
	.ep4Ack (1'b0),      .ep4Atrig (), // input wire, output wire [31:0],
	.ep4Bck (1'b0),      .ep4Btrig (), // input wire, output wire [31:0],
	.ep4Cck (1'b0),      .ep4Ctrig (), // input wire, output wire [31:0],
	.ep4Dck (1'b0),      .ep4Dtrig (), // input wire, output wire [31:0],
	.ep4Eck (1'b0),      .ep4Etrig (), // input wire, output wire [31:0],
	.ep4Fck (1'b0),      .ep4Ftrig (), // input wire, output wire [31:0],
	.ep50ck (1'b0),      .ep50trig (), // input wire, output wire [31:0],
	.ep51ck (1'b0),      .ep51trig (), // input wire, output wire [31:0],
	.ep52ck (1'b0),      .ep52trig (), // input wire, output wire [31:0],
	.ep53ck (w_ck_53_1), .ep53trig (w_port_ti_53_1), // input wire, output wire [31:0],
	.ep54ck (1'b0),      .ep54trig (), // input wire, output wire [31:0],
	.ep55ck (1'b0),      .ep55trig (), // input wire, output wire [31:0],
	.ep56ck (1'b0),      .ep56trig (), // input wire, output wire [31:0],
	.ep57ck (1'b0),      .ep57trig (), // input wire, output wire [31:0],
	.ep58ck (1'b0),      .ep58trig (), // input wire, output wire [31:0],
	.ep59ck (1'b0),      .ep59trig (), // input wire, output wire [31:0],
	.ep5Ack (1'b0),      .ep5Atrig (), // input wire, output wire [31:0],
	.ep5Bck (1'b0),      .ep5Btrig (), // input wire, output wire [31:0],
	.ep5Cck (1'b0),      .ep5Ctrig (), // input wire, output wire [31:0],
	.ep5Dck (1'b0),      .ep5Dtrig (), // input wire, output wire [31:0],
	.ep5Eck (1'b0),      .ep5Etrig (), // input wire, output wire [31:0],
	.ep5Fck (1'b0),      .ep5Ftrig (), // input wire, output wire [31:0],
	//}
	
	// Trigger Out 	0x60 - 0x7F //{
	.ep60ck (w_ck_60_1), .ep60trig (w_port_to_60_1), // input wire, input wire [31:0],
	.ep61ck (1'b0),      .ep61trig (32'b0), // input wire, input wire [31:0],
	.ep62ck (w_ck_62_1), .ep62trig (w_port_to_62_1), // input wire, input wire [31:0],
	.ep63ck (1'b0),      .ep63trig (32'b0), // input wire, input wire [31:0],
	.ep64ck (1'b0),      .ep64trig (32'b0), // input wire, input wire [31:0],
	.ep65ck (1'b0),      .ep65trig (32'b0), // input wire, input wire [31:0],
	.ep66ck (1'b0),      .ep66trig (32'b0), // input wire, input wire [31:0],
	.ep67ck (1'b0),      .ep67trig (32'b0), // input wire, input wire [31:0],
	.ep68ck (1'b0),      .ep68trig (32'b0), // input wire, input wire [31:0],
	.ep69ck (1'b0),      .ep69trig (32'b0), // input wire, input wire [31:0],
	.ep6Ack (1'b0),      .ep6Atrig (32'b0), // input wire, input wire [31:0],
	.ep6Bck (1'b0),      .ep6Btrig (32'b0), // input wire, input wire [31:0],
	.ep6Cck (1'b0),      .ep6Ctrig (32'b0), // input wire, input wire [31:0],
	.ep6Dck (1'b0),      .ep6Dtrig (32'b0), // input wire, input wire [31:0],
	.ep6Eck (1'b0),      .ep6Etrig (32'b0), // input wire, input wire [31:0],
	.ep6Fck (1'b0),      .ep6Ftrig (32'b0), // input wire, input wire [31:0],
	.ep70ck (1'b0),      .ep70trig (32'b0), // input wire, input wire [31:0],
	.ep71ck (1'b0),      .ep71trig (32'b0), // input wire, input wire [31:0],
	.ep72ck (1'b0),      .ep72trig (32'b0), // input wire, input wire [31:0],
	.ep73ck (w_ck_73_1), .ep73trig (w_port_to_73_1), // input wire, input wire [31:0],
	.ep74ck (1'b0),      .ep74trig (32'b0), // input wire, input wire [31:0],
	.ep75ck (1'b0),      .ep75trig (32'b0), // input wire, input wire [31:0],
	.ep76ck (1'b0),      .ep76trig (32'b0), // input wire, input wire [31:0],
	.ep77ck (1'b0),      .ep77trig (32'b0), // input wire, input wire [31:0],
	.ep78ck (1'b0),      .ep78trig (32'b0), // input wire, input wire [31:0],
	.ep79ck (1'b0),      .ep79trig (32'b0), // input wire, input wire [31:0],
	.ep7Ack (1'b0),      .ep7Atrig (32'b0), // input wire, input wire [31:0],
	.ep7Bck (1'b0),      .ep7Btrig (32'b0), // input wire, input wire [31:0],
	.ep7Cck (1'b0),      .ep7Ctrig (32'b0), // input wire, input wire [31:0],
	.ep7Dck (1'b0),      .ep7Dtrig (32'b0), // input wire, input wire [31:0],
	.ep7Eck (1'b0),      .ep7Etrig (32'b0), // input wire, input wire [31:0],
	.ep7Fck (1'b0),      .ep7Ftrig (32'b0), // input wire, input wire [31:0],
	//}
	
	// Pipe In 		0x80 - 0x9F //{
	.ep80wr (),          .ep80pipe (), // output wire, output wire [31:0],
	.ep81wr (),          .ep81pipe (), // output wire, output wire [31:0],
	.ep82wr (),          .ep82pipe (), // output wire, output wire [31:0],
	.ep83wr (),          .ep83pipe (), // output wire, output wire [31:0],
	.ep84wr (w_wr_84_1), .ep84pipe (w_port_pi_84_1), // output wire, output wire [31:0],
	.ep85wr (w_wr_85_1), .ep85pipe (w_port_pi_85_1), // output wire, output wire [31:0],
	.ep86wr (w_wr_86_1), .ep86pipe (w_port_pi_86_1), // output wire, output wire [31:0],
	.ep87wr (w_wr_87_1), .ep87pipe (w_port_pi_87_1), // output wire, output wire [31:0],
	.ep88wr (w_wr_88_1), .ep88pipe (w_port_pi_88_1), // output wire, output wire [31:0],
	.ep89wr (w_wr_89_1), .ep89pipe (w_port_pi_89_1), // output wire, output wire [31:0],
	.ep8Awr (w_wr_8A_1), .ep8Apipe (w_port_pi_8A_1), // output wire, output wire [31:0],
	.ep8Bwr (),          .ep8Bpipe (), // output wire, output wire [31:0],
	.ep8Cwr (),          .ep8Cpipe (), // output wire, output wire [31:0],
	.ep8Dwr (),          .ep8Dpipe (), // output wire, output wire [31:0],
	.ep8Ewr (),          .ep8Epipe (), // output wire, output wire [31:0],
	.ep8Fwr (),          .ep8Fpipe (), // output wire, output wire [31:0],
	.ep90wr (),          .ep90pipe (), // output wire, output wire [31:0],
	.ep91wr (),          .ep91pipe (), // output wire, output wire [31:0],
	.ep92wr (),          .ep92pipe (), // output wire, output wire [31:0],
	.ep93wr (w_wr_93_1), .ep93pipe (w_port_pi_93_1), // output wire, output wire [31:0],
	.ep94wr (),          .ep94pipe (), // output wire, output wire [31:0],
	.ep95wr (),          .ep95pipe (), // output wire, output wire [31:0],
	.ep96wr (),          .ep96pipe (), // output wire, output wire [31:0],
	.ep97wr (),          .ep97pipe (), // output wire, output wire [31:0],
	.ep98wr (),          .ep98pipe (), // output wire, output wire [31:0],
	.ep99wr (),          .ep99pipe (), // output wire, output wire [31:0],
	.ep9Awr (),          .ep9Apipe (), // output wire, output wire [31:0],
	.ep9Bwr (),          .ep9Bpipe (), // output wire, output wire [31:0],
	.ep9Cwr (),          .ep9Cpipe (), // output wire, output wire [31:0],
	.ep9Dwr (),          .ep9Dpipe (), // output wire, output wire [31:0],
	.ep9Ewr (),          .ep9Epipe (), // output wire, output wire [31:0],
	.ep9Fwr (),          .ep9Fpipe (), // output wire, output wire [31:0],
	//}
	
	// Pipe Out 	0xA0 - 0xBF //{
	.epA0rd (),          .epA0pipe (32'b0), // output wire, input wire [31:0],
	.epA1rd (),          .epA1pipe (32'b0), // output wire, input wire [31:0],
	.epA2rd (),          .epA2pipe (32'b0), // output wire, input wire [31:0],
	.epA3rd (),          .epA3pipe (32'b0), // output wire, input wire [31:0],
	.epA4rd (),          .epA4pipe (32'b0), // output wire, input wire [31:0],
	.epA5rd (),          .epA5pipe (32'b0), // output wire, input wire [31:0],
	.epA6rd (),          .epA6pipe (32'b0), // output wire, input wire [31:0],
	.epA7rd (),          .epA7pipe (32'b0), // output wire, input wire [31:0],
	.epA8rd (),          .epA8pipe (32'b0), // output wire, input wire [31:0],
	.epA9rd (),          .epA9pipe (32'b0), // output wire, input wire [31:0],
	.epAArd (w_rd_AA_1), .epAApipe (w_port_po_AA_1), // output wire, input wire [31:0],
	.epABrd (),          .epABpipe (32'b0), // output wire, input wire [31:0],
	.epACrd (),          .epACpipe (32'b0), // output wire, input wire [31:0],
	.epADrd (),          .epADpipe (32'b0), // output wire, input wire [31:0],
	.epAErd (),          .epAEpipe (32'b0), // output wire, input wire [31:0],
	.epAFrd (),          .epAFpipe (32'b0), // output wire, input wire [31:0],
	.epB0rd (),          .epB0pipe (32'b0), // output wire, input wire [31:0],
	.epB1rd (),          .epB1pipe (32'b0), // output wire, input wire [31:0],
	.epB2rd (),          .epB2pipe (32'b0), // output wire, input wire [31:0],
	.epB3rd (w_rd_B3_1), .epB3pipe (w_port_po_B3_1), // output wire, input wire [31:0],
	.epB4rd (),          .epB4pipe (32'b0), // output wire, input wire [31:0],
	.epB5rd (),          .epB5pipe (32'b0), // output wire, input wire [31:0],
	.epB6rd (),          .epB6pipe (32'b0), // output wire, input wire [31:0],
	.epB7rd (),          .epB7pipe (32'b0), // output wire, input wire [31:0],
	.epB8rd (),          .epB8pipe (32'b0), // output wire, input wire [31:0],
	.epB9rd (),          .epB9pipe (32'b0), // output wire, input wire [31:0],
	.epBArd (),          .epBApipe (32'b0), // output wire, input wire [31:0],
	.epBBrd (),          .epBBpipe (32'b0), // output wire, input wire [31:0],
	.epBCrd (),          .epBCpipe (32'b0), // output wire, input wire [31:0],
	.epBDrd (),          .epBDpipe (32'b0), // output wire, input wire [31:0],
	.epBErd (),          .epBEpipe (32'b0), // output wire, input wire [31:0],
	.epBFrd (),          .epBFpipe (32'b0), // output wire, input wire [31:0],
	//}
	
	// Pipe clock output //{
	.epPPck (w_ck_pipe) //output wire // sync with write/read of pipe // 72MHz
	//}
	);

//}

// assign //{

assign w_adrs_offset_mac_48b[47:16] = {8'h00,8'h00,8'h00,8'h00}; // assign high 32b
assign w_adrs_offset_ip_32b [31:16] = {8'h00,8'h00}            ; // assign high 16b
assign w_offset_lan_timeout_rtr_16b = 16'd0;
assign w_offset_lan_timeout_rcr_16b = 16'd0;

//}

////

//}


/* TODO: TEST FIFO */ //{

// emulate LAN-fifo from/to ADC-fifo
// test-place ADC-fifo with TEST-fifo, which can be read and written.
//
// fifo_generator_4 : test
// 32 bits
// 4096 depth = 2^12
// 2^12 * 4 byte = 16KB
		
fifo_generator_4 TEST_fifo_inst(
  //.rst       (~reset_n | ~w_LAN_RSTn | w_FIFO_reset), // input wire rst
  .rst       (~reset_n), // input wire rst
  .wr_clk    (mcs_clk),  // input wire wr_clk
  .wr_en     (w_wr_8A_1),      // input wire wr_en
  .din       (w_port_pi_8A_1), // input wire [31 : 0] din
  .rd_clk    (mcs_clk),  // input wire rd_clk
  .rd_en     (w_rd_AA_1),      // input wire rd_en
  .dout      (w_port_po_AA_1), // output wire [31 : 0] dout
  .full      (),  // output wire full
  .wr_ack    (),  // output wire wr_ack
  .empty     (),  // output wire empty
  .valid     ()   // output wire valid
);

//}


///TODO: //-------------------------------------------------------//


/* TODO: mapping endpoints to signals for S3100-CPU-BASE board */ //{

// most control in signals

//// BRD_CON //{
wire [31:0] w_BRD_CON = w_port_wi_03_1 | ep03wire; // board control // logic or
// reset wires 
// endpoint mux enable : LAN(MCS) vs USB

// sub wires 
//wire w_HW_reset              = w_BRD_CON[0];
////  wire w_time_stamp_disp_en    = w_BRD_CON[16];

// reset wires 
//wire w_rst_adc      = w_BRD_CON[1]; 
//wire w_rst_dwave    = w_BRD_CON[2]; 
//wire w_rst_bias     = w_BRD_CON[3]; 
//wire w_rst_spo      = w_BRD_CON[4]; 
////  wire w_rst_mcs_ep   = w_BRD_CON[]; 

// endpoint mux enable : LAN(MCS) vs USB
wire w_mcs_ep_po_en = w_BRD_CON[ 8]; 
wire w_mcs_ep_pi_en = w_BRD_CON[ 9]; 
wire w_mcs_ep_to_en = w_BRD_CON[10]; 
wire w_mcs_ep_ti_en = w_BRD_CON[11];  
wire w_mcs_ep_wo_en = w_BRD_CON[12]; 
wire w_mcs_ep_wi_en = w_BRD_CON[13]; 

//}

//// MCS_SETUP_WI //{

// MCS control 
wire [31:0] w_MCS_SETUP_WI = w_port_wi_19_1; //$$ dedicated to MCS. updated by MCS boot-up.
// bit[3:0]= slot_id, range of 00~99, set from EEPROM via MCS
// ...
// bit[8]  = sel__H_LAN_for_EEPROM_fifo (or USB)  //$$ no USB in S3100
// bit[9]  = sel__H_EEPROM_on_TP (or on Base)
// bit[10] = sel__H_LAN_on_BASE_BD (or on module) //$$ always LAN_on_BASE in S3100
// ...
// bit[31:16]=board_id, range of 0000~9999, set from EEPROM via MCS

wire [3:0]  w_slot_id             = w_MCS_SETUP_WI[3:0];   // not yet
wire w_sel__H_LAN_for_EEPROM_fifo = w_MCS_SETUP_WI[8];
wire w_sel__H_EEPROM_on_TP        = w_MCS_SETUP_WI[9];     // not yet
wire w_sel__H_LAN_on_BASE_BD      = w_MCS_SETUP_WI[10];    // not yet // ignored in S3100
wire [15:0] w_board_id            = w_MCS_SETUP_WI[31:16]; // not yet

// for dedicated LAN setup from MCS
assign w_adrs_offset_mac_48b[15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
assign w_adrs_offset_ip_32b [15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b

//}

//// TEST wires //{

// check IDs end-point //{
wire [31:0] w_F_IMAGE_ID_WO = FPGA_IMAGE_ID ;
//
assign         ep20wire = w_F_IMAGE_ID_WO; //$$ SSPI (test)
assign w_port_wo_20_1   = w_F_IMAGE_ID_WO; //$$ LAN
//}

// timestamp //{
(* keep = "true" *) wire [31:0] w_TIMESTAMP_WO;
assign ep22wire       = w_TIMESTAMP_WO ;
assign w_port_wo_22_1 = w_TIMESTAMP_WO ;
//}

// TEST counter end-point //{
wire [31:0] w_TEST_CON_WI = (w_mcs_ep_wi_en)? w_port_wi_01_1 : ep01wire;
//
wire [31:0] w_TEST_OUT_WO;
assign ep21wire       =                    w_TEST_OUT_WO ; 
assign w_port_wo_21_1 = ( w_mcs_ep_wo_en)? w_TEST_OUT_WO : 32'hACAC_ACAC;

wire [31:0] w_TEST_TI = ( w_mcs_ep_ti_en)? w_port_ti_40_1 : ep40trig;

wire [31:0] w_TEST_TO;
assign ep60trig      =  (!w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000;
assign w_port_to_60_1 = ( w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000; 

//}


//}


//// SSPI and MSPI wires //{

wire [31:0] w_SSPI_CON_WI  = ep02wire; // controls ... 
			// w_SSPI_CON_WI[0] enables SSPI control against USB 
			// w_SSPI_CON_WI[1] ...
wire [31:0] w_SSPI_FLAG_WO; 
	assign ep23wire = w_SSPI_FLAG_WO; //$$ ep22wire --> ep23wire
//

// HW reset signal : MEM, TEST_COUNTER, XADC, TIMESTAMP // SPIO, DAC, ADC, TRIG_IO,
wire w_HW_reset__ext;
wire w_HW_reset = w_SSPI_CON_WI[3] | w_HW_reset__ext | w_BRD_CON[0] ; //$$

wire w_SSPI_TEST_mode_en; //$$ hw emulation for mother board master spi //$$ w_MTH_SPI_emulation__en ??

//$wire [31:0] w_SSPI_TEST_WI   = ep17wire; // test data for SSPI
//$wire [31:0] w_SSPI_TEST_WO; //$$ assign ep21wire = w_SSPI_TEST_WO; //$$ share with ep21wire or w_TEST_FLAG_WO
//wire [31:0] w_MSPI_CON_WI   = ep17wire; // w_SSPI_TEST_WI --> w_MSPI_CON_WI// test data for SSPI

wire [31:0] w_MSPI_CON_WI   = (w_mcs_ep_wi_en)? w_port_wi_17_1 : ep17wire; //$$ MSPI frame data
wire [31:0] w_MSPI_EN_CS_WI = (w_mcs_ep_wi_en)? w_port_wi_16_1 : ep16wire; //$$ MSPI nCSX enable
//$$ alias SPI group selection
wire w_M0_SPI_CS_enable = w_MSPI_EN_CS_WI[16] | ((~w_MSPI_EN_CS_WI[17])&(~w_MSPI_EN_CS_WI[18]));
wire w_M1_SPI_CS_enable = w_MSPI_EN_CS_WI[17];
wire w_M2_SPI_CS_enable = w_MSPI_EN_CS_WI[18];

wire [31:0] w_MSPI_FLAG_WO; // w_TEST_FLAG_WO --> SSPI_TEST_WO --> MSPI_FLAG_WO
	assign ep24wire         =                   w_MSPI_FLAG_WO                ;
	assign w_port_wo_24_1   = (w_mcs_ep_wo_en)? w_MSPI_FLAG_WO : 32'hACAC_ACAC;


//wire [31:0] w_SSPI_TI   = ep42trig; assign ep42ck = sys_clk;
//wire [31:0] w_SSPI_TEST_TI   = ep42trig; assign ep42ck = base_sspi_clk;
//$$ w_SSPI_TEST_TI --> w_MSPI_TI 
wire [31:0] w_MSPI_TI   = ( w_mcs_ep_ti_en)? w_port_ti_42_1 : ep42trig;

//wire [31:0] w_SSPI_TO      = 32'b0; assign ep62trig = w_SSPI_TO; assign ep62ck = sys_clk;
//wire [31:0] w_SSPI_TEST_TO; assign ep62trig = w_SSPI_TEST_TO; assign ep62ck = base_sspi_clk; // vs sys_clk
//$$ w_SSPI_TEST_TO --> w_MSPI_TO 
wire [31:0] w_MSPI_TO;
	assign ep62trig      =  (!w_mcs_ep_to_en)? w_MSPI_TO : 32'h0000_0000;
	assign w_port_to_62_1 = ( w_mcs_ep_to_en)? w_MSPI_TO : 32'h0000_0000; 


//
wire [31:0] w_SSPI_BD_STAT_WO           ;  // rev...
wire [31:0] w_SSPI_CNT_CS_M0_WO         ;  // rev...
wire [31:0] w_SSPI_CNT_CS_M1_WO         ;  // rev...
//wire [31:0] w_SSPI_CNT_ADC_FIFO_IN_WO   ;  // rev...
//wire [31:0] w_SSPI_CNT_ADC_TRIG_WO      ;  // rev...
//wire [31:0] w_SSPI_CNT_SPIO_FRM_TRIG_WO ;  // rev...
//wire [31:0] w_SSPI_CNT_DAC_TRIG_WO      ;  // rev...

// for w_MSPI_FLAG_WO or w_TEST_FLAG_WO
//assign w_TEST_FLAG_WO[23]    = w_SSPI_TEST_mode_en; //$$
//assign w_TEST_FLAG_WO[22:20] = 3'b0; //$$ not yet used
//assign w_TEST_FLAG_WO[31:24] = {r_EXT_TRIG[0], r_EXT_BUSY_B_OUT, w_spio_busy_cowork, w_dac_busy_cowork, 
//							    w_adc_busy_cowork, r_M_TRIG[0], r_M_PRE_TRIG[0], r_M_BUSY_B_OUT}; 
//assign w_SSPI_TEST_WO[15:0] = w_SSPI_frame_data_B[15:0];
//
assign w_MSPI_FLAG_WO[31:24] = 8'b0; //$$ not yet used
assign w_MSPI_FLAG_WO[23]    = w_SSPI_TEST_mode_en;
assign w_MSPI_FLAG_WO[22:20] = 3'b0; //$$ not yet used
//assign w_MSPI_FLAG_WO[15:0 ] = w_SSPI_frame_data_B[15:0]; // to come

//}


//// EEPROM wires //{
wire [31:0] w_MEM_WI      = (w_sel__H_LAN_for_EEPROM_fifo)? w_port_wi_13_1 : ep13wire;                                        
wire [31:0] w_MEM_FDAT_WI = (w_sel__H_LAN_for_EEPROM_fifo)? w_port_wi_12_1 : ep12wire;                                        
wire [31:0] w_MEM_TI      = w_port_ti_53_1 | ep53trig; 
wire [31:0] w_MEM_TO; 
	assign ep73trig       = w_MEM_TO; 
	assign w_port_to_73_1 = w_MEM_TO; 
wire [31:0] w_MEM_PI = (w_sel__H_LAN_for_EEPROM_fifo)? w_port_pi_93_1 : ep93pipe;
wire w_MEM_PI_wr = w_wr_93_1 | ep93wr;                  
wire [31:0] w_MEM_PO; 
	assign epB3pipe       = w_MEM_PO; 
	assign w_port_po_B3_1 = w_MEM_PO; 
wire w_MEM_PO_rd = w_rd_B3_1 | epB3rd; 

//}


//}



///TODO: //-------------------------------------------------------//

/* timestamp */ //{
// global time index in debugger based on 10MHz 

//sub_timestamp //{
sub_timestamp sub_timestamp_inst(
	.clk         (sys_clk),
	.reset_n     (reset_n),
	.o_timestamp (w_TIMESTAMP_WO),
	.valid       ()
);
//}

//}


/* TEST COUNTER */ //{

// wires //{
wire [7:0]  w_test; // moving pattern
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
//}

// assign //{

// Counter 1:
assign reset1     = w_TEST_CON_WI[0]; 
assign disable1   = w_TEST_CON_WI[1]; 
assign autocount2 = w_TEST_CON_WI[2]; 
//
assign w_TEST_OUT_WO[15:0]  = {count2[7:0], count1[7:0]}; 
assign w_TEST_OUT_WO[31:16] = 16'b0; 
// Counter 2:
assign reset2     = w_TEST_TI[0];
assign up2        = w_TEST_TI[1];
assign down2      = w_TEST_TI[2];
//
assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};

// LED drive //{

//// note: fpga module    uses high-Z output // 7..0 ... B17,B16,A16,B15,A15,A14,B13,A13
//// note: S3100-CPU-BASE uses high-Z output // 7..0 ... V19,V18,Y19,Y18,W20,W19,V20,U20

// xem7310_led:
//   1 in --> 0 out // tri_0, out_0
//   0 in --> Z out // tri_1, out_X
function [7:0] xem7310_led;
input [7:0] a;
integer i;
begin
	for(i=0; i<8; i=i+1) begin: u
		//xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
		xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'b1); // inverter
	end
end
endfunction
// 
//assign led = xem7310_led(w_test ^ count1);
//}

//}

// test_counter_wrapper //{
test_counter_wrapper  test_counter_wrapper_inst(
	.sys_clk (sys_clk),
	.reset_n (reset_n),
	//
	.o_test        (w_test),
	//
	.o_count1      (count1),
	//
	.o_count1eq00  (count1eq00),
	.o_count1eq80  (count1eq80),
	//
	.reset1        (reset1),
	.disable1      (disable1),
	//
	.o_count2      (count2),
	//
	.o_count2eqFF  (count2eqFF),
	//
	.reset2        (reset2    ),
	.up2           (up2       ),
	.down2         (down2     ),
	.autocount2    (autocount2)
	//             
);
//}

//}


/* XADC */ //{

// wires and end-points //{

wire [31:0] w_XADC_TEMP_WO; 
assign ep3Awire       =                   w_XADC_TEMP_WO ;
assign w_port_wo_3A_1 = (w_mcs_ep_wo_en)? w_XADC_TEMP_WO : 32'hACAC_ACAC;
//
wire [31:0] w_XADC_VOLT_WO; 
assign ep3Bwire       =                   w_XADC_VOLT_WO ;
assign w_port_wo_3B_1 = (w_mcs_ep_wo_en)? w_XADC_VOLT_WO : 32'hACAC_ACAC;

// XADC_DRP
wire [31:0] MEASURED_TEMP_MC;
wire [31:0] MEASURED_VCCINT_MV;
wire [31:0] MEASURED_VCCAUX_MV;
wire [31:0] MEASURED_VCCBRAM_MV;
//
wire [7:0] dbg_drp;
//}

// master_drp_ug480 //{
master_drp_ug480 master_drp_ug480_inst(
	.DCLK				(xadc_clk), // input DCLK, // Clock input for DRP
	.RESET				(~reset_n), // input RESET,
	.VP					(i_XADC_VP), // input VP, VN,// Dedicated and Hardwired Analog Input Pair
	.VN					(i_XADC_VN),
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

// assign //{
assign w_XADC_TEMP_WO	= MEASURED_TEMP_MC;
//
assign w_XADC_VOLT_WO = 
	(count2[7:6]==2'b00)? MEASURED_VCCINT_MV  :
	(count2[7:6]==2'b01)? MEASURED_VCCAUX_MV  :
	(count2[7:6]==2'b10)? MEASURED_VCCBRAM_MV :
		32'b0;
//}

//}


///TODO: //-------------------------------------------------------//





///TODO: //-------------------------------------------------------//


/* TODO: EEPROM */ //{
// support 11AA160T-I/TT 
// io signal, open-drain
// note that 10K ohm pull up is located on board.
// net in sch : SCIO_0              in S3100-CPU-BASE
// pin in fpga: io_B15_L11P_SRCC    in S3100-CPU-BASE

//$$ S3100 vs TXEM7310
//// note: fpga module in PGU    uses io_B34_L5N       // Y1
//// note: S3100-CPU-BASE SCIO_0 uses io_B15_L11P_SRCC // J20


// fifo read clock //{
wire c_eeprom_fifo_clk; // clock mux between lan and usb/slave-spi end-points

//$$  BUFGMUX bufgmux_c_eeprom_fifo_clk_inst(
//$$  	.O(c_eeprom_fifo_clk), 
//$$  	//.I0(base_sspi_clk), // base_sspi_clk for slave_spi_mth_brd // 104MHz
//$$  	.I0(okClk        ), // USB  // 100.8MHz
//$$  	//.I1(w_ck_pipe    ), // LAN from lan_endpoint_wrapper_inst      // 72MHz
//$$  	.I1(mcs_eeprom_fifo_clk), 
//$$  	.S(w_sel__H_LAN_for_EEPROM_fifo) 
//$$  );

assign c_eeprom_fifo_clk = (w_sel__H_LAN_for_EEPROM_fifo == 0)? okClk : mcs_eeprom_fifo_clk ; //$$ remove BUFGMUX

// note BUFG issue : solved with duplicated clock  mcs_eeprom_fifo_clk
//   without BUFGMUX : pre BUFG 35, post BUGF 26
//   with    BUFGMUX : pre BUFG 37, post BUGF 28 // duplicate clock

// try remove bufg at pll out
//assign c_eeprom_fifo_clk = w_ck_pipe; // LAN test 

//}


// module //{

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
wire w_SCIO_DI; // io port from module
wire w_SCIO_DO; // io port from module
wire w_SCIO_OE; // io port from module

//
control_eeprom__11AA160T  control_eeprom__11AA160T_inst(
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

// assignment //{

//// MEM endpoints //{
assign w_num_bytes_DAT               = w_MEM_WI[11:0]; // 12-bit 
assign w_con_disable_SBP             = w_MEM_WI[15]  ; // 1-bit

assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit

assign w_MEM_rst      = w_MEM_TI[0];
assign w_MEM_fifo_rst = w_MEM_TI[1];
assign w_trig_frame   = w_MEM_TI[2];

assign w_MEM_TO[0]     = w_MEM_valid    ;
assign w_MEM_TO[1]     = w_done_frame   ;
assign w_MEM_TO[2]     = w_done_frame_TO;
assign w_MEM_TO[ 7: 3] =  5'b0;
assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
assign w_MEM_TO[31:16] = 16'b0;

assign w_frame_data_DAT_wr    = w_MEM_PI[7:0]; // 8-bit
assign w_frame_data_DAT_wr_en = w_MEM_PI_wr;

assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
assign w_MEM_PO[31:8]         = {24{w_frame_data_DAT_rd[7]}}; // rev signed expansion for compatibility
assign w_frame_data_DAT_rd_en = w_MEM_PO_rd;
//}

//// port mux with TP // removed
//  assign w_SCIO_DI   = ( w_sel__H_EEPROM_on_TP)?   TP_in[2] : MEM_SIO_in ; // switching
//  //                     
//  assign TP_out[2]   = ( w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // test TP 
//  assign TP_tri[2]   = ( w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // test TP 
//  //
//  assign TP_out[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b1 : 1'b0 ; // for test power (3.3V) on signal line
//  assign TP_out[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b0 ; // for test power (GND)  on signal line
//  assign TP_tri[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  assign TP_tri[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  //                     
//  assign MEM_SIO_out = (~w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // dedicated port
//  assign MEM_SIO_tri = (~w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // dedicated port


//// mapping io via module

//// SCIO_0
assign                SCIO_0_tri  = ~w_SCIO_OE ;
assign                SCIO_0_out  =  w_SCIO_DO ;
assign w_SCIO_DI   =  SCIO_0_in ; 

//// SCIO_1 // reserved
assign  SCIO_1_tri = 1'b1; // high-Z
assign  SCIO_1_out = 1'b0; 



//}


//}


///TODO: //-------------------------------------------------------//

/* TODO: Master_SPI emulation for Slave_SPI  or  MSPI */ //{


// module //{

//// Master SPI endpoints
//
// MSPI_TI : ep42trig
//   bit[0] = reset_trig 
//   bit[1] = init_trig
//   bit[2] = frame_trig
//
// MSPI_TO : ep62trig
//   bit[0] = reset_done
//   bit[1] = init_done
//   bit[2] = frame_done
//
// MSPI_CON_WI : ep17wire
//  bit[31:26] = data_C // control[5:0]
//  bit[25:16] = data_A // address[9:0]
//  bit[15: 0] = data_D // MOSI data[15:0]
//
// MSPI_EN_CS_WI : ep16wire
//  bit[0 ] = enable SPI_nCS0  
//  bit[1 ] = enable SPI_nCS1  
//  bit[2 ] = enable SPI_nCS2  
//  bit[3 ] = enable SPI_nCS3  
//  bit[4 ] = enable SPI_nCS4  
//  bit[5 ] = enable SPI_nCS5  
//  bit[6 ] = enable SPI_nCS6  
//  bit[7 ] = enable SPI_nCS7  
//  bit[8 ] = enable SPI_nCS8  
//  bit[9 ] = enable SPI_nCS9  
//  bit[10] = enable SPI_nCS10 
//  bit[11] = enable SPI_nCS11 
//  bit[12] = enable SPI_nCS12 
//
// MSPI_FLAG_WO : ep24wire
//  bit[23]   = TEST_mode_en
//  bit[15:0] = data_B // MISO data[15:0]

wire w_SSPI_TEST_trig_reset = w_MSPI_TI[0];
assign w_MSPI_TO[0]    = w_SSPI_TEST_trig_reset;
//
wire  w_SSPI_TEST_trig_init = w_MSPI_TI[1];
wire  w_SSPI_TEST_done_init ;
assign w_SSPI_TEST_mode_en = w_SSPI_TEST_done_init;
assign w_MSPI_TO[1]   = w_SSPI_TEST_done_init;
//
wire  w_SSPI_TEST_trig_frame = w_MSPI_TI[2];
wire  w_SSPI_TEST_done_frame;
assign w_MSPI_TO[2]   = w_SSPI_TEST_done_frame;
//
assign w_MSPI_TO[31:3] = 29'b0;

//
wire  [ 5:0] w_SSPI_frame_data_C = w_MSPI_CON_WI[31:26]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [ 9:0] w_SSPI_frame_data_A = w_MSPI_CON_WI[25:16]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [15:0] w_SSPI_frame_data_D = w_MSPI_CON_WI[15: 0]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
//
wire  [15:0] w_SSPI_frame_data_B;
wire  [15:0] w_SSPI_frame_data_E;
assign w_MSPI_FLAG_WO[15:0] = w_SSPI_frame_data_B[15:0]; //$$ w_SSPI_TEST_WO --> w_MSPI_FLAG_WO

(* keep = "true" *) wire  w_SSPI_TEST_SS_B   ;
(* keep = "true" *) wire  w_SSPI_TEST_MCLK   ;
(* keep = "true" *) wire  w_SSPI_TEST_SCLK   ;
(* keep = "true" *) wire  w_SSPI_TEST_MOSI   ;
(* keep = "true" *) wire  w_SSPI_TEST_MISO   ;
(* keep = "true" *) wire  w_SSPI_TEST_MISO_EN;

//$$ S3100: mapping SSPI_TEST to M0_SPI
//assign  FPGA_M0_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
//
//assign  FPGA_M0_SPI_nCS0_   = (w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS1_   = (w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS2_   = (w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS3_   = (w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS4_   = (w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS5_   = (w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS6_   = (w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS7_   = (w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS8_   = (w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS9_   = (w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS10   = (w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS11   = (w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
//assign  FPGA_M0_SPI_nCS12   = (w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

//
//assign  M0_SPI_TX_CLK       = w_SSPI_TEST_MCLK    ;
//assign  M0_SPI_MOSI         = w_SSPI_TEST_MOSI    ;
//
assign  w_SSPI_TEST_MISO_EN = w_SSPI_TEST_mode_en ; 
//$$assign  w_SSPI_TEST_SCLK    = M0_SPI_RX_CLK       ; //$$ must come from SSPI in test.
//$$assign  w_SSPI_TEST_MISO    = M0_SPI_MISO         ; //$$ must come from SSPI in test.



//
master_spi_mth_brd  master_spi_mth_brd__inst(
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
	.i_SCLK    (w_SSPI_TEST_SCLK   ), // sclk slave in
	.o_MOSI    (w_SSPI_TEST_MOSI   ),
	.i_MISO    (w_SSPI_TEST_MISO   ),
	.i_MISO_EN (w_SSPI_TEST_MISO_EN),
	
	.valid  ()
); 
//}

//}


///TODO: //-------------------------------------------------------//

/* TODO: Slave_SPI from Mother board  or  SSPI */ //{

// ports for Slave SPI //{

//// mux M0 with test module : w_SSPI_TEST_mode_en //$$ //{

//$$ wire  M0_SPI_CS_B_BUF;
//$$ wire  M0_SPI_CLK     ;
//$$ wire  M0_SPI_SCLK    ; //$$ REV2
//$$ wire  M0_SPI_MOSI    ;
//$$ wire  M0_SPI_MISO    ;
//$$ wire  M0_SPI_MISO_EN ;

//
//IBUF ibuf__M0_SPI_CS_B_BUF_inst(.I(i_B34_L2P       ), .O(M0_SPI_CS_B_BUF  ) ); //
//IBUF ibuf__M0_SPI_CLK______inst(.I(i_B34_L2N       ), .O(M0_SPI_CLK       ) ); //
//OBUF obuf__M0_SPI_SCLK_____inst(.O(o_B34_L1P       ), .I(M0_SPI_SCLK      ) ); //$$ REV2
//IBUF ibuf__M0_SPI_MOSI_____inst(.I(i_B34_L4P       ), .O(M0_SPI_MOSI      ) ); //
//OBUF obuf__M0_SPI_MISO_____inst(.O(o_B34_L4N       ), .I(M0_SPI_MISO      ) ); // 
//OBUF obuf__M0_SPI_MISO_EN__inst(.O(o_B34_L24P      ), .I(M0_SPI_MISO_EN   ) ); //$$ o_B34_L1P --> o_B34_L24P //$$ REV2


//$$ wire  w_B34_L2P  ;
//$$ wire  w_B34_L2N  ;
//$$ wire  w_B34_L1P  ;
//$$ wire  w_B34_L4P  ;
//$$ wire  w_B34_L4N  ;
//$$ wire  w_B34_L24P ;
//$$ 
//$$ //$$IBUF ibuf__M0_SPI_CS_B_BUF_inst(.I(i_B34_L2P       ), .O(w_B34_L2P  ) ); //
//$$ //$$IBUF ibuf__M0_SPI_CLK______inst(.I(i_B34_L2N       ), .O(w_B34_L2N  ) ); //
//$$ //$$OBUF obuf__M0_SPI_SCLK_____inst(.O(o_B34_L1P       ), .I(w_B34_L1P  ) ); //$$ REV2
//$$ //$$IBUF ibuf__M0_SPI_MOSI_____inst(.I(i_B34_L4P       ), .O(w_B34_L4P  ) ); //
//$$ //$$OBUF obuf__M0_SPI_MISO_____inst(.O(o_B34_L4N       ), .I(w_B34_L4N  ) ); // 
//$$ //$$OBUF obuf__M0_SPI_MISO_EN__inst(.O(o_B34_L24P      ), .I(w_B34_L24P ) ); //$$ o_B34_L1P --> o_B34_L24P //$$ REV2
//$$ 
//$$ assign M0_SPI_CS_B_BUF = (~w_SSPI_TEST_mode_en)? w_B34_L2P      : w_SSPI_TEST_SS_B ; // w_SSPI_TEST_SS_B   
//$$ assign M0_SPI_CLK      = (~w_SSPI_TEST_mode_en)? w_B34_L2N      : w_SSPI_TEST_MCLK ; // w_SSPI_TEST_MCLK   
//$$ assign w_B34_L1P       = (~w_SSPI_TEST_mode_en)? M0_SPI_SCLK    : 1'b1             ; // w_SSPI_TEST_SCLK   
//$$ assign M0_SPI_MOSI     = (~w_SSPI_TEST_mode_en)? w_B34_L4P      : w_SSPI_TEST_MOSI ; // w_SSPI_TEST_MOSI   
//$$ assign w_B34_L4N       = (~w_SSPI_TEST_mode_en)? M0_SPI_MISO    : 1'b1             ; // w_SSPI_TEST_MISO   
//$$ assign w_B34_L24P      = (~w_SSPI_TEST_mode_en)? M0_SPI_MISO_EN : 1'b1             ; // w_SSPI_TEST_MISO_EN
//$$ 
//$$ //w_SSPI_TEST_SS_B   
//$$ //w_SSPI_TEST_MCLK   
//$$ assign w_SSPI_TEST_SCLK    = (w_SSPI_TEST_mode_en)? M0_SPI_SCLK    : 1'b1 ;
//$$ //w_SSPI_TEST_MOSI   
//$$ assign w_SSPI_TEST_MISO    = (w_SSPI_TEST_mode_en)? M0_SPI_MISO    : 1'b1 ;
//$$ assign w_SSPI_TEST_MISO_EN = (w_SSPI_TEST_mode_en)? M0_SPI_MISO_EN : 1'b0 ;


//}

//// M1 //{
	
//$$ wire  M1_SPI_CS_B_BUF;
//$$ wire  M1_SPI_CLK     ;
//$$ wire  M1_SPI_SCLK    ; //$$ REV2
//$$ wire  M1_SPI_MOSI    ;
//$$ wire  M1_SPI_MISO    ;
//$$ wire  M1_SPI_MISO_EN ;
//$$ IBUF ibuf__M1_SPI_CS_B_BUF_inst(.I(i_B34_L1N       ), .O(M1_SPI_CS_B_BUF  ) ); //
//$$ IBUF ibuf__M1_SPI_CLK______inst(.I(i_B34_L7P       ), .O(M1_SPI_CLK       ) ); //
//$$ OBUF obuf__M1_SPI_SCLK_____inst(.O(o_B34_L12N_MRCC ), .I(M1_SPI_SCLK      ) ); //$$ REV2
//$$ IBUF ibuf__M1_SPI_MOSI_____inst(.I(i_B34_L7N       ), .O(M1_SPI_MOSI      ) ); //
//$$ OBUF obuf__M1_SPI_MISO_____inst(.O(o_B34_L12P_MRCC ), .I(M1_SPI_MISO      ) ); // 
//$$ OBUF obuf__M1_SPI_MISO_EN__inst(.O(o_B34_L24N      ), .I(M1_SPI_MISO_EN   ) ); //$$ o_B34_L12N_MRCC --> o_B34_L24N //$$ REV2

//}

//}

// modules //{
(* keep = "true" *) wire w_M0_SPI_CS_B_BUF;
(* keep = "true" *) wire w_M0_SPI_CLK     ;
(* keep = "true" *) wire w_M0_SPI_MOSI    ;
(* keep = "true" *) wire w_M0_SPI_MISO    ;
(* keep = "true" *) wire w_M0_SPI_MISO_EN ;

//$$ for S3100 test
assign w_M0_SPI_CS_B_BUF = w_SSPI_TEST_SS_B;
assign w_M0_SPI_CLK      = w_SSPI_TEST_MCLK;
assign w_M0_SPI_MOSI     = w_SSPI_TEST_MOSI;

//$$assign  w_SSPI_TEST_SCLK    = w_M0_SPI_CLK       ; //$$ must come from SSPI in test.
//$$assign  w_SSPI_TEST_MISO    = w_M0_SPI_MISO      ; //$$ must come from SSPI in test.


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
wire [31:0] w_M0_port_wo_sadrs_h080 = w_F_IMAGE_ID_WO; //  FPGA_IMAGE_ID_WO  0x080	wo20
wire [31:0] w_M0_port_wo_sadrs_h084 = w_TEST_OUT_WO     ; //  TEST_OUT_WO       0x084	wo21
wire [31:0] w_M0_port_wo_sadrs_h088 = w_TIMESTAMP_WO    ; //  TIMESTAMP_WO      0x088	wo22
wire [31:0] w_M0_port_wo_sadrs_h08C = w_SSPI_FLAG_WO    ; //  SSPI_FLAG_WO      0x08C	wo23
wire [31:0] w_M0_port_wo_sadrs_h090 = w_MSPI_FLAG_WO    ; //  MSPI_FLAG_WO      0x090	wo24
//wire [31:0] w_M0_port_wo_sadrs_h084 = w_TEST_FLAG_WO    ; // TEST_FLAG_WO		0x084	wo21
//wire [31:0] w_M0_port_wo_sadrs_h088 = w_SSPI_FLAG_WO    ; // SSPI_FLAG_WO		0x088	wo22
//wire [31:0] w_M0_port_wo_sadrs_h08C = w_XADC_TEMP_WO    ; // w_MON_XADC_WO     ; // MON_XADC_WO		0x08C	wo23
//wire [31:0] w_M0_port_wo_sadrs_h090 = w_XADC_VOLT_WO    ; // w_MON_GP_WO       ; // MON_GP_WO			0x090	wo24
//wire [31:0] w_M0_port_wo_sadrs_h094 = w_SPIO_FLAG_WO    ; // SPIO_FLAG_WO		0x094	wo25
//wire [31:0] w_M0_port_wo_sadrs_h098 = w_DAC_FLAG_WO     ; // DAC_FLAG_WO		0x098	wo26
//
wire [31:0] w_M0_port_wo_sadrs_h380 = 32'h33AA_CC55     ; // SSPI_TEST_OUT		0x380	NA  // known pattern
wire [31:0] w_M0_port_wo_sadrs_h384 = w_SSPI_BD_STAT_WO           ;
wire [31:0] w_M0_port_wo_sadrs_h388 = w_SSPI_CNT_CS_M0_WO         ;
wire [31:0] w_M0_port_wo_sadrs_h38C = w_SSPI_CNT_CS_M1_WO         ;
wire [31:0] w_M0_port_wo_sadrs_h390 = 32'b0; //$$ w_SSPI_CNT_ADC_FIFO_IN_WO   ;
wire [31:0] w_M0_port_wo_sadrs_h394 = 32'b0; //$$ w_SSPI_CNT_ADC_TRIG_WO  ;
wire [31:0] w_M0_port_wo_sadrs_h398 = 32'b0; //$$ w_SSPI_CNT_SPIO_FRM_TRIG_WO ;
wire [31:0] w_M0_port_wo_sadrs_h39C = 32'b0; //$$ w_SSPI_CNT_DAC_TRIG_WO  ;
//
//wire [31:0] w_M0_port_wo_sadrs_h0E0 = w_DAC_S1_WO ; // MHVSU_DAC	DAC_S1_WO	0x0E0	wo38	read DAC buffer data.	={S1_DAC_CH2[15:0], S1_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0E4 = w_DAC_S2_WO ; // MHVSU_DAC	DAC_S2_WO	0x0E4	wo39	read DAC buffer data.	={S2_DAC_CH2[15:0], S2_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0E8 = w_DAC_S3_WO ; // MHVSU_DAC	DAC_S3_WO	0x0E8	wo3A	read DAC buffer data.	={S3_DAC_CH2[15:0], S3_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0EC = w_DAC_S4_WO ; // MHVSU_DAC	DAC_S4_WO	0x0EC	wo3B	read DAC buffer data.	={S4_DAC_CH2[15:0], S4_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0F0 = w_DAC_S5_WO ; // MHVSU_DAC	DAC_S5_WO	0x0F0	wo3C	read DAC buffer data.	={S5_DAC_CH2[15:0], S5_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0F4 = w_DAC_S6_WO ; // MHVSU_DAC	DAC_S6_WO	0x0F4	wo3D	read DAC buffer data.	={S6_DAC_CH2[15:0], S6_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0F8 = w_DAC_S7_WO ; // MHVSU_DAC	DAC_S7_WO	0x0F8	wo3E	read DAC buffer data.	={S7_DAC_CH2[15:0], S7_DAC_CH1[15:0]}	
//wire [31:0] w_M0_port_wo_sadrs_h0FC = w_DAC_S8_WO ; // MHVSU_DAC	DAC_S8_WO	0x0FC	wo3F	read DAC buffer data.	={S8_DAC_CH2[15:0], S8_DAC_CH1[15:0]}
////
//wire [31:0] w_M0_port_wo_sadrs_h09C = w_ADC_FLAG_WO ; // ADC_FLAG_WO		0x09C			wo27
////
//wire [31:0] w_M0_port_wo_sadrs_h0A0 = w_ADC_S1_ACC_MAX_WO ; // ADC_Sn_WO		0x0A0~0x0BC		wo28~wo2F
//wire [31:0] w_M0_port_wo_sadrs_h0A4 = w_ADC_S2_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0A8 = w_ADC_S3_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0AC = w_ADC_S4_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0B0 = w_ADC_S5_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0B4 = w_ADC_S6_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0B8 = w_ADC_S7_ACC_MAX_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0BC = w_ADC_S8_ACC_MAX_WO ;
////
//wire [31:0] w_M0_port_wo_sadrs_h0C0 = w_ADC_S1_VAL_MIN_WO ; // ADC_Sn_WO		0x0C0~0x0DC		wo30~wo37
//wire [31:0] w_M0_port_wo_sadrs_h0C4 = w_ADC_S2_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0C8 = w_ADC_S3_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0CC = w_ADC_S4_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0D0 = w_ADC_S5_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0D4 = w_ADC_S6_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0D8 = w_ADC_S7_VAL_MIN_WO ;
//wire [31:0] w_M0_port_wo_sadrs_h0DC = w_ADC_S8_VAL_MIN_WO ;
//
wire [31:0] w_M0_port_ti_sadrs_h104; // TEST_TI				0x104	ti41
wire [31:0] w_M0_port_ti_sadrs_h114; // SPIO_TRIG_TI		0x114	ti45
wire [31:0] w_M0_port_ti_sadrs_h118; // DAC_TRIG_TI			0x118	ti46
wire [31:0] w_M0_port_ti_sadrs_h11C; // ADC_TRIG_TI		0x11C			ti47 // base_adc_clk --> p_adc_clk
wire [31:0] w_M0_port_ti_sadrs_h110; // wire [31:0] ext_trig_ti_______sspi; // control from sspi adrs 0x110
wire [31:0] w_M0_port_ti_sadrs_h14C; // MEM_TI	0x14C	ti53 // sys_clk //$$
//
//wire [31:0] w_M0_port_to_sadrs_h190 = w_EXT_TRIG_TO     ; // EXT_TRIG_TO	0x190	to64 // sys_clk //$$
//wire [31:0] w_M0_port_to_sadrs_h194 = w_SPIO_TRIG_TO    ; // SPIO_TRIG_TO	0x194	to65
//wire [31:0] w_M0_port_to_sadrs_h198 = w_DAC_TRIG_TO     ; // DAC_TRIG_TO	0x198	to66
//wire [31:0] w_M0_port_to_sadrs_h19C = w_ADC_TRIG_TO     ; // ADC_TRIG_TO	0x19C	to67 // base_adc_clk --> p_adc_clk
wire [31:0] w_M0_port_to_sadrs_h1CC = w_MEM_TO          ; // MEM_TO			0x1CC	to73 // sys_clk //$$
//
wire        w_M0_loopback_en           = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
														   w_SSPI_CON_WI[24]              ;
wire        w_M0_MISO_one_bit_ahead_en = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[25]    : 
														   w_SSPI_CON_WI[25]              ;
wire [2:0]  w_M0_slack_count_MISO      = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
														   w_SSPI_CON_WI[30:28]           ;

//wire [3:0] w_board_id = {S_ID3_BUF,S_ID2_BUF,S_ID1_BUF,S_ID0_BUF};
//$$wire [3:0] w_board_id = w_slot_id; //$$ rev miso info

wire [7:0] w_board_status = 8'b0; // test
//assign w_board_status[7] = 1'b0                    ; // NA // Board Error Status                
//assign w_board_status[6] = r_M_TRIG[0]             ; // M_TRIG             
//assign w_board_status[5] = r_M_PRE_TRIG[0]         ; // M_PRE_TRIG         
//assign w_board_status[4] = r_M_BUSY_B_OUT          ; // M_BUSY_B_OUT or M_READY_OUT      
//assign w_board_status[3] = w_busy_SPI_frame        ; // SPIO busy          
//assign w_board_status[2] = w_busy_DAC_update       ; // DAC  busy          
//assign w_board_status[1] = w_fifo_adc_empty_and_all; // ADC FIFO all empty 
//assign w_board_status[0] = w_ADC_busy_pclk         ; // ADC_busy           


//
slave_spi_mth_brd  slave_spi_mth_brd__M0_inst(
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
	//.i_port_wo_sadrs_h094    (w_M0_port_wo_sadrs_h094),
	//.i_port_wo_sadrs_h098    (w_M0_port_wo_sadrs_h098),
	//.i_port_wo_sadrs_h09C    (w_M0_port_wo_sadrs_h09C), // ADC_FLAG_WO		0x09C			wo27
	//.i_port_wo_sadrs_h0E0    (w_M0_port_wo_sadrs_h0E0), // [31:0] // DAC_S1_WO	0x0E0	wo38
	//.i_port_wo_sadrs_h0E4    (w_M0_port_wo_sadrs_h0E4), // [31:0] // DAC_S2_WO	0x0E4	wo39
	//.i_port_wo_sadrs_h0E8    (w_M0_port_wo_sadrs_h0E8), // [31:0] // DAC_S3_WO	0x0E8	wo3A
	//.i_port_wo_sadrs_h0EC    (w_M0_port_wo_sadrs_h0EC), // [31:0] // DAC_S4_WO	0x0EC	wo3B
	//.i_port_wo_sadrs_h0F0    (w_M0_port_wo_sadrs_h0F0), // [31:0] // DAC_S5_WO	0x0F0	wo3C
	//.i_port_wo_sadrs_h0F4    (w_M0_port_wo_sadrs_h0F4), // [31:0] // DAC_S6_WO	0x0F4	wo3D
	//.i_port_wo_sadrs_h0F8    (w_M0_port_wo_sadrs_h0F8), // [31:0] // DAC_S7_WO	0x0F8	wo3E
	//.i_port_wo_sadrs_h0FC    (w_M0_port_wo_sadrs_h0FC), // [31:0] // DAC_S8_WO	0x0FC	wo3F
	//
	//.i_port_wo_sadrs_h0A0    (w_M0_port_wo_sadrs_h0A0), // ADC_Sn_ACC_WO		0x0A0~0x0BC		wo28~wo2F
	//.i_port_wo_sadrs_h0A4    (w_M0_port_wo_sadrs_h0A4),
	//.i_port_wo_sadrs_h0A8    (w_M0_port_wo_sadrs_h0A8),
	//.i_port_wo_sadrs_h0AC    (w_M0_port_wo_sadrs_h0AC),
	//.i_port_wo_sadrs_h0B0    (w_M0_port_wo_sadrs_h0B0),
	//.i_port_wo_sadrs_h0B4    (w_M0_port_wo_sadrs_h0B4),
	//.i_port_wo_sadrs_h0B8    (w_M0_port_wo_sadrs_h0B8),
	//.i_port_wo_sadrs_h0BC    (w_M0_port_wo_sadrs_h0BC),
	//
	//.i_port_wo_sadrs_h0C0    (w_M0_port_wo_sadrs_h0C0), // ADC_Sn_WO		0x0C0~0x0DC		wo30~wo37
	//.i_port_wo_sadrs_h0C4    (w_M0_port_wo_sadrs_h0C4),
	//.i_port_wo_sadrs_h0C8    (w_M0_port_wo_sadrs_h0C8),
	//.i_port_wo_sadrs_h0CC    (w_M0_port_wo_sadrs_h0CC),
	//.i_port_wo_sadrs_h0D0    (w_M0_port_wo_sadrs_h0D0),
	//.i_port_wo_sadrs_h0D4    (w_M0_port_wo_sadrs_h0D4),
	//.i_port_wo_sadrs_h0D8    (w_M0_port_wo_sadrs_h0D8),
	//.i_port_wo_sadrs_h0DC    (w_M0_port_wo_sadrs_h0DC),
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
	//.i_ck__sadrs_h11C  (p_adc_clk),    .o_port_ti_sadrs_h11C  (w_M0_port_ti_sadrs_h11C), // [31:0] // ADC_TRIG_TI		0x11C			ti47 // p_adc_clk
	.i_ck__sadrs_h14C  (sys_clk),      .o_port_ti_sadrs_h14C  (w_M0_port_ti_sadrs_h14C), // [31:0] // MEM_TI	0x14C	ti53 // sys_clk //$$

	// to
	//.i_ck__sadrs_h190  (sys_clk  ),    .i_port_to_sadrs_h190  (w_M0_port_to_sadrs_h190), // [31:0] // EXT_TRIG_TO	0x190	to64 // sys_clk //$$
	//.i_ck__sadrs_h194  (sys_clk  ),    .i_port_to_sadrs_h194  (w_M0_port_to_sadrs_h194), // [31:0]
	//.i_ck__sadrs_h198  (sys_clk  ),    .i_port_to_sadrs_h198  (w_M0_port_to_sadrs_h198), // [31:0]
	//.i_ck__sadrs_h19C  (p_adc_clk),    .i_port_to_sadrs_h19C  (w_M0_port_to_sadrs_h19C), // [31:0] // ADC_TRIG_TO		0x19C			to67 // p_adc_clk
	.i_ck__sadrs_h1CC  (sys_clk  ),    .i_port_to_sadrs_h1CC  (w_M0_port_to_sadrs_h1CC), // [31:0] // MEM_TO	0x1CC	to73 // sys_clk //$$

	// pi
	//.o_wr__sadrs_h24C (w_MEM_PI_wr_sspi_M0),   .o_port_po_sadrs_h24C (w_MEM_PI_sspi_M0), // [31:0]  // MEM_PI	0x24C	pi93 //$$
	
	// po
	// ADC_Sn_CH1_PO	0x280~0x29C		poA0~poA7
	// ADC_Sn_CH2_PO	0x2A0~0x2BC		poA8~poAF
	//.o_rd__sadrs_h280 (w_ADC_S1_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h280 (w_ADC_S1_CH1_PO), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	//.o_rd__sadrs_h284 (w_ADC_S2_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h284 (w_ADC_S2_CH1_PO), // [31:0]  // ADC_S2_CH1_PO	0x284	poA1
	//.o_rd__sadrs_h288 (w_ADC_S3_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h288 (w_ADC_S3_CH1_PO), // [31:0]  // ADC_S3_CH1_PO	0x288	poA2
	//.o_rd__sadrs_h28C (w_ADC_S4_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h28C (w_ADC_S4_CH1_PO), // [31:0]  // ADC_S4_CH1_PO	0x28C	poA3
	//.o_rd__sadrs_h290 (w_ADC_S5_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h290 (w_ADC_S5_CH1_PO), // [31:0]  // ADC_S5_CH1_PO	0x290	poA4
	//.o_rd__sadrs_h294 (w_ADC_S6_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h294 (w_ADC_S6_CH1_PO), // [31:0]  // ADC_S6_CH1_PO	0x294	poA5
	//.o_rd__sadrs_h298 (w_ADC_S7_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h298 (w_ADC_S7_CH1_PO), // [31:0]  // ADC_S7_CH1_PO	0x298	poA6
	//.o_rd__sadrs_h29C (w_ADC_S8_CH1_PO_rd_sspi_M0),   .i_port_po_sadrs_h29C (w_ADC_S8_CH1_PO), // [31:0]  // ADC_S8_CH1_PO	0x29C	poA7
	//.o_rd__sadrs_h2A0 (w_ADC_S1_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A0 (w_ADC_S1_CH2_PO), // [31:0]  // ADC_S1_CH2_PO	0x2A0	poA8
	//.o_rd__sadrs_h2A4 (w_ADC_S2_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A4 (w_ADC_S2_CH2_PO), // [31:0]  // ADC_S2_CH2_PO	0x2A4	poA9
	//.o_rd__sadrs_h2A8 (w_ADC_S3_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2A8 (w_ADC_S3_CH2_PO), // [31:0]  // ADC_S3_CH2_PO	0x2A8	poAA
	//.o_rd__sadrs_h2AC (w_ADC_S4_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2AC (w_ADC_S4_CH2_PO), // [31:0]  // ADC_S4_CH2_PO	0x2AC	poAB
	//.o_rd__sadrs_h2B0 (w_ADC_S5_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B0 (w_ADC_S5_CH2_PO), // [31:0]  // ADC_S5_CH2_PO	0x2B0	poAC
	//.o_rd__sadrs_h2B4 (w_ADC_S6_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B4 (w_ADC_S6_CH2_PO), // [31:0]  // ADC_S6_CH2_PO	0x2B4	poAD
	//.o_rd__sadrs_h2B8 (w_ADC_S7_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2B8 (w_ADC_S7_CH2_PO), // [31:0]  // ADC_S7_CH2_PO	0x2B8	poAE
	//.o_rd__sadrs_h2BC (w_ADC_S8_CH2_PO_rd_sspi_M0),   .i_port_po_sadrs_h2BC (w_ADC_S8_CH2_PO), // [31:0]  // ADC_S8_CH2_PO	0x2BC	poAF
	//.o_rd__sadrs_h2CC (       w_MEM_PO_rd_sspi_M0),   .i_port_po_sadrs_h2CC (       w_MEM_PO), // [31:0]  // MEM_PO	0x2CC	poB3 //$$
	
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
//wire [31:0] w_M1_port_wo_sadrs_h080 = w_F_IMAGE_ID_WO;
//wire [31:0] w_M1_port_wo_sadrs_h088 = w_SSPI_FLAG_WO    ;
//wire [31:0] w_M1_port_wo_sadrs_h380 = 32'h33AA_CC55     ; // known pattern
//
wire        w_M1_loopback_en           = w_M1_port_wi_sadrs_h008[24];
wire        w_M1_MISO_one_bit_ahead_en = w_M1_port_wi_sadrs_h008[25];
wire [2:0]  w_M1_slack_count_MISO      = w_M1_port_wi_sadrs_h008[30:28];
//
slave_spi_mth_brd  slave_spi_mth_brd__M1_inst(
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
	//.i_port_wo_sadrs_h094    (w_M0_port_wo_sadrs_h094),
	//.i_port_wo_sadrs_h098    (w_M0_port_wo_sadrs_h098),
	//.i_port_wo_sadrs_h09C    (w_M0_port_wo_sadrs_h09C), 
	//.i_port_wo_sadrs_h0E0    (w_M0_port_wo_sadrs_h0E0),
	//.i_port_wo_sadrs_h0E4    (w_M0_port_wo_sadrs_h0E4),
	//.i_port_wo_sadrs_h0E8    (w_M0_port_wo_sadrs_h0E8),
	//.i_port_wo_sadrs_h0EC    (w_M0_port_wo_sadrs_h0EC),
	//.i_port_wo_sadrs_h0F0    (w_M0_port_wo_sadrs_h0F0),
	//.i_port_wo_sadrs_h0F4    (w_M0_port_wo_sadrs_h0F4),
	//.i_port_wo_sadrs_h0F8    (w_M0_port_wo_sadrs_h0F8),
	//.i_port_wo_sadrs_h0FC    (w_M0_port_wo_sadrs_h0FC),
	//
	//.i_port_wo_sadrs_h0A0    (w_M0_port_wo_sadrs_h0A0),
	//.i_port_wo_sadrs_h0A4    (w_M0_port_wo_sadrs_h0A4),
	//.i_port_wo_sadrs_h0A8    (w_M0_port_wo_sadrs_h0A8),
	//.i_port_wo_sadrs_h0AC    (w_M0_port_wo_sadrs_h0AC),
	//.i_port_wo_sadrs_h0B0    (w_M0_port_wo_sadrs_h0B0),
	//.i_port_wo_sadrs_h0B4    (w_M0_port_wo_sadrs_h0B4),
	//.i_port_wo_sadrs_h0B8    (w_M0_port_wo_sadrs_h0B8),
	//.i_port_wo_sadrs_h0BC    (w_M0_port_wo_sadrs_h0BC),
	//
	//.i_port_wo_sadrs_h0C0    (w_M0_port_wo_sadrs_h0C0), 
	//.i_port_wo_sadrs_h0C4    (w_M0_port_wo_sadrs_h0C4),
	//.i_port_wo_sadrs_h0C8    (w_M0_port_wo_sadrs_h0C8),
	//.i_port_wo_sadrs_h0CC    (w_M0_port_wo_sadrs_h0CC),
	//.i_port_wo_sadrs_h0D0    (w_M0_port_wo_sadrs_h0D0),
	//.i_port_wo_sadrs_h0D4    (w_M0_port_wo_sadrs_h0D4),
	//.i_port_wo_sadrs_h0D8    (w_M0_port_wo_sadrs_h0D8),
	//.i_port_wo_sadrs_h0DC    (w_M0_port_wo_sadrs_h0DC),
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
	//.i_ck__sadrs_h190  (sys_clk  ),   .i_port_to_sadrs_h190  (w_M0_port_to_sadrs_h190), // [31:0]
	//.i_ck__sadrs_h194  (sys_clk  ),   .i_port_to_sadrs_h194  (w_M0_port_to_sadrs_h194), // [31:0]
	//.i_ck__sadrs_h198  (sys_clk  ),   .i_port_to_sadrs_h198  (w_M0_port_to_sadrs_h198), // [31:0]
	//.i_ck__sadrs_h19C  (p_adc_clk),   .i_port_to_sadrs_h19C  (w_M0_port_to_sadrs_h19C), 
	.i_ck__sadrs_h1CC  (sys_clk  ),   .i_port_to_sadrs_h1CC  (w_M0_port_to_sadrs_h1CC), // [31:0]
	
	// pi
	.o_wr__sadrs_h24C (),   .o_port_po_sadrs_h24C (),
	
	// PO monitor
	//.o_rd__sadrs_h280 (w_ADC_S1_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h280 (w_ADC_S1_CH1_PO), // [31:0]  // ADC_S1_CH1_PO	0x280	poA0
	//.o_rd__sadrs_h284 (w_ADC_S2_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h284 (w_ADC_S2_CH1_PO), // [31:0]  // ADC_S2_CH1_PO	0x284	poA1
	//.o_rd__sadrs_h288 (w_ADC_S3_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h288 (w_ADC_S3_CH1_PO), // [31:0]  // ADC_S3_CH1_PO	0x288	poA2
	//.o_rd__sadrs_h28C (w_ADC_S4_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h28C (w_ADC_S4_CH1_PO), // [31:0]  // ADC_S4_CH1_PO	0x28C	poA3
	//.o_rd__sadrs_h290 (w_ADC_S5_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h290 (w_ADC_S5_CH1_PO), // [31:0]  // ADC_S5_CH1_PO	0x290	poA4
	//.o_rd__sadrs_h294 (w_ADC_S6_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h294 (w_ADC_S6_CH1_PO), // [31:0]  // ADC_S6_CH1_PO	0x294	poA5
	//.o_rd__sadrs_h298 (w_ADC_S7_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h298 (w_ADC_S7_CH1_PO), // [31:0]  // ADC_S7_CH1_PO	0x298	poA6
	//.o_rd__sadrs_h29C (w_ADC_S8_CH1_PO_rd_sspi_M1),   .i_port_po_sadrs_h29C (w_ADC_S8_CH1_PO), // [31:0]  // ADC_S8_CH1_PO	0x29C	poA7
	//.o_rd__sadrs_h2A0 (w_ADC_S1_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A0 (w_ADC_S1_CH2_PO), // [31:0]  // ADC_S1_CH2_PO	0x2A0	poA8
	//.o_rd__sadrs_h2A4 (w_ADC_S2_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A4 (w_ADC_S2_CH2_PO), // [31:0]  // ADC_S2_CH2_PO	0x2A4	poA9
	//.o_rd__sadrs_h2A8 (w_ADC_S3_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2A8 (w_ADC_S3_CH2_PO), // [31:0]  // ADC_S3_CH2_PO	0x2A8	poAA
	//.o_rd__sadrs_h2AC (w_ADC_S4_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2AC (w_ADC_S4_CH2_PO), // [31:0]  // ADC_S4_CH2_PO	0x2AC	poAB
	//.o_rd__sadrs_h2B0 (w_ADC_S5_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B0 (w_ADC_S5_CH2_PO), // [31:0]  // ADC_S5_CH2_PO	0x2B0	poAC
	//.o_rd__sadrs_h2B4 (w_ADC_S6_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B4 (w_ADC_S6_CH2_PO), // [31:0]  // ADC_S6_CH2_PO	0x2B4	poAD
	//.o_rd__sadrs_h2B8 (w_ADC_S7_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2B8 (w_ADC_S7_CH2_PO), // [31:0]  // ADC_S7_CH2_PO	0x2B8	poAE
	//.o_rd__sadrs_h2BC (w_ADC_S8_CH2_PO_rd_sspi_M1),   .i_port_po_sadrs_h2BC (w_ADC_S8_CH2_PO), // [31:0]  // ADC_S8_CH2_PO	0x2BC	poAF
	//.o_rd__sadrs_h2CC (       w_MEM_PO_rd_sspi_M1),   .i_port_po_sadrs_h2CC (       w_MEM_PO), // [31:0]  // MEM_PO	0x2CC	poB3 //$$

	
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



//$$  // signal monitoring reg
//$$  (* keep = "true" *) reg r_M0_SPI_CS_B_BUF; // test sampling
//$$  (* keep = "true" *) reg r_M0_SPI_CLK     ; // test sampling
//$$  (* keep = "true" *) reg r_M0_SPI_MOSI    ; // test sampling
//$$  (* keep = "true" *) reg r_M0_SPI_MISO    ; // test output
//$$  (* keep = "true" *) reg r_M0_SPI_MISO_EN ; // test output
//$$  //
//$$  (* keep = "true" *) reg r_M1_SPI_CS_B_BUF; // test sampling
//$$  (* keep = "true" *) reg r_M1_SPI_CLK     ; // test sampling
//$$  (* keep = "true" *) reg r_M1_SPI_MOSI    ; // test sampling
//$$  (* keep = "true" *) reg r_M1_SPI_MISO    ; // test output
//$$  (* keep = "true" *) reg r_M1_SPI_MISO_EN ; // test output
//$$  
//$$  
//$$  //// output pin assignment
//$$  assign M0_SPI_MISO_EN = r_M0_SPI_MISO_EN;
//$$  assign M0_SPI_MISO    = r_M0_SPI_MISO   ;
//$$  assign M1_SPI_MISO_EN = r_M1_SPI_MISO_EN;
//$$  assign M1_SPI_MISO    = r_M1_SPI_MISO   ;
//$$  
//$$  // output sampling
//$$  always @(posedge base_sspi_clk, negedge reset_n)
//$$  	if (!reset_n) begin
//$$  		r_M0_SPI_MISO     <= 1'b0;
//$$  		r_M0_SPI_MISO_EN  <= 1'b0;
//$$  		r_M1_SPI_MISO     <= 1'b0;
//$$  		r_M1_SPI_MISO_EN  <= 1'b0;
//$$  	end
//$$  	else begin
//$$  		r_M0_SPI_MISO      <= w_M0_SPI_MISO    ;
//$$  		r_M0_SPI_MISO_EN   <= w_M0_SPI_MISO_EN ;
//$$  		r_M1_SPI_MISO      <= w_M1_SPI_MISO    ;
//$$  		r_M1_SPI_MISO_EN   <= w_M1_SPI_MISO_EN ;
//$$  	end	
//$$  
//$$  // input wire assignment
//$$  assign w_M0_SPI_CS_B_BUF = r_M0_SPI_CS_B_BUF;
//$$  assign w_M0_SPI_CLK      = r_M0_SPI_CLK     ;
//$$  assign w_M0_SPI_MOSI     = r_M0_SPI_MOSI    ;
//$$  assign w_M1_SPI_CS_B_BUF = r_M1_SPI_CS_B_BUF;
//$$  assign w_M1_SPI_CLK      = r_M1_SPI_CLK     ;
//$$  assign w_M1_SPI_MOSI     = r_M1_SPI_MOSI    ;


// output wire loopback //{
// loopback MISO <-- MOSI 
// loobback conditions
//   assign w_M0_SPI_MISO    =  w_M0_SPI_MOSI;
//   assign w_M0_SPI_MISO_EN = (w_M0_SPI_CS_B_BUF == 1'b0)? 1'b1 : 1'b0 ;
//   assign w_M1_SPI_MISO    =  w_M1_SPI_MOSI;
//   assign w_M1_SPI_MISO_EN = (w_M1_SPI_CS_B_BUF == 1'b0)? 1'b1 : 1'b0 ;
//}


// slave clock duplication //$$ REV2 //{
//$$ assign M0_SPI_SCLK = r_M0_SPI_CLK;
//$$ assign M1_SPI_SCLK = r_M1_SPI_CLK;

//}


// miso control M0
assign w_M0_loopback_en        = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[24]    : 
												   w_SSPI_CON_WI[24]              ;
assign w_M0_slack_count_MISO   = (~w_SSPI_CON_WI[0])? w_M0_port_wi_sadrs_h008[30:28] :
												   w_SSPI_CON_WI[30:28]           ;

// HW reset control 
assign w_HW_reset__ext        = w_M0_port_wi_sadrs_h008[3]; //$$

// res net assignment 
//$$assign res_net_ctrl_ext_en    = w_M0_port_wi_sadrs_h008[1];   //$$ enable LED control on Base board
//assign res_net_ctrl_ext_data  = w_M0_port_wi_sadrs_h00C[3:0];

// count2 control 
//assign count2_trig_ext_data  = w_M0_port_ti_sadrs_h104[2:0];

// SPIO control 
//assign spio_trig_ti_ext      = w_M0_port_ti_sadrs_h114[1:0];
//assign spio_con_wi_ext       = w_M0_port_wi_sadrs_h014     ; // SPIO_CON_WI			0x014	wi05
//assign spio_fdat_wi_ext      = w_M0_port_wi_sadrs_h010     ; // SPIO_FDAT_WI		0x010	wi04

// DAC control 
//assign dac_trig_ti_ext       = w_M0_port_ti_sadrs_h118[4:0];
//assign dac_con_wi_ext        = w_M0_port_wi_sadrs_h018[31:0];

// DAC wire in 
//assign dac_s1_wi_ext = w_M0_port_wi_sadrs_h060 ; // [31:0] // DAC_S1_WI	0x060	wi18;
//assign dac_s2_wi_ext = w_M0_port_wi_sadrs_h064 ; // [31:0] // DAC_S2_WI	0x064	wi19;
//assign dac_s3_wi_ext = w_M0_port_wi_sadrs_h068 ; // [31:0] // DAC_S3_WI	0x068	wi1A;
//assign dac_s4_wi_ext = w_M0_port_wi_sadrs_h06C ; // [31:0] // DAC_S4_WI	0x06C	wi1B;
//assign dac_s5_wi_ext = w_M0_port_wi_sadrs_h070 ; // [31:0] // DAC_S5_WI	0x070	wi1C;
//assign dac_s6_wi_ext = w_M0_port_wi_sadrs_h074 ; // [31:0] // DAC_S6_WI	0x074	wi1D;
//assign dac_s7_wi_ext = w_M0_port_wi_sadrs_h078 ; // [31:0] // DAC_S7_WI	0x078	wi1E;
//assign dac_s8_wi_ext = w_M0_port_wi_sadrs_h07C ; // [31:0] // DAC_S8_WI	0x07C	wi1F;

// ADC control 
//assign adc_con_wi_ext  = w_M0_port_wi_sadrs_h01C ;
//assign adc_par_wi_ext  = w_M0_port_wi_sadrs_h040 ;
//assign adc_trig_ti_ext = w_M0_port_ti_sadrs_h11C[3:0];

// MEM control  //$$
//$$ MEM_FDAT_WI	0x048	wi12
//$$ MEM_WI			0x04C	wi13
//$$ MEM_TI			0x14C	ti53
//$$ MEM_TO		0x1CC	to73
//$$ MEM_PI		0x24C	pi93
//$$ MEM_PO		0x2CC	poB3
//assign mem_fdat_wi__sspi = w_M0_port_wi_sadrs_h048; //$$ rev
//assign mem_wi_______sspi = w_M0_port_wi_sadrs_h04C; //$$ rev
//assign mem_ti_______sspi = w_M0_port_ti_sadrs_h14C; //$$

// EXT_TRIG control 
//assign ext_trig_con_wi___sspi = w_M0_port_wi_sadrs_h050 ;
//assign ext_trig_para_wi__sspi = w_M0_port_wi_sadrs_h054 ;
//assign ext_trig_aux_wi___sspi = w_M0_port_wi_sadrs_h058 ;
//assign ext_trig_ti_______sspi = w_M0_port_ti_sadrs_h110 ;

// flag assignment 
assign w_SSPI_FLAG_WO[0]     = w_SSPI_CON_WI[0]; // enables SSPI control from MCS or USB 
//$$assign w_SSPI_FLAG_WO[1]     = res_net_ctrl_ext_en; // enables res net control from SSPI
assign w_SSPI_FLAG_WO[2]     = 1'b0; 
assign w_SSPI_FLAG_WO[3]     = w_HW_reset; //$$ HW reset status
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

////w_SSPI_CNT_ADC_FIFO_IN_WO   
//assign w_SSPI_CNT_ADC_FIFO_IN_WO[15:0]  = w_cnt_adc_fifo_in_pclk;
//assign w_SSPI_CNT_ADC_FIFO_IN_WO[31:16] = 16'b0;
//
////w_SSPI_CNT_ADC_TRIG_WO  
//assign w_SSPI_CNT_ADC_TRIG_WO[15:0]  = w_cnt_adc_trig_conv_pclk;
//assign w_SSPI_CNT_ADC_TRIG_WO[31:16] = 16'b0;
//
////w_SSPI_CNT_SPIO_FRM_TRIG_WO 
//assign w_SSPI_CNT_SPIO_FRM_TRIG_WO[15:0]  = w_cnt_spio_trig_frame; //$$ count w_trig_SPIO_SPI_frame
//assign w_SSPI_CNT_SPIO_FRM_TRIG_WO[31:16] = 16'b0;
//
////w_SSPI_CNT_DAC_TRIG_WO  
//assign w_SSPI_CNT_DAC_TRIG_WO[15:0]  = w_cnt_dac_trig; //$$ count DAC trig
//assign w_SSPI_CNT_DAC_TRIG_WO[31:16] = 16'b0;


//}


//}


/* TODO: Mux MTH ... MISO and SCLK  */ //{

//$$ note ... mux signals according to w_MSPI_EN_CS_WI[*]
//$$ slave SPI emulation is activated when w_MSPI_EN_CS_WI == 0.
//$$ S3100-PGU is on M2

assign  FPGA_M0_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M0_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M0_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M0_SPI_nCS0_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS1_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS2_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS3_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS4_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS5_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS6_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS7_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS8_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS9_   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS10   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS11   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M0_SPI_nCS12   = (w_M0_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

assign  FPGA_M1_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M1_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M1_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M1_SPI_nCS0_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS1_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS2_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS3_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS4_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS5_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS6_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS7_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS8_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS9_   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS10   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS11   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M1_SPI_nCS12   = (w_M1_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

assign  FPGA_M2_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
assign       M2_SPI_TX_CLK  = w_SSPI_TEST_MCLK    ;
assign       M2_SPI_MOSI    = w_SSPI_TEST_MOSI    ;
assign  FPGA_M2_SPI_nCS0_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS1_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS2_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS3_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS4_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS5_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS6_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS7_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS8_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS9_   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS10   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS11   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
assign  FPGA_M2_SPI_nCS12   = (w_M2_SPI_CS_enable & w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;

//assign  w_SSPI_TEST_SCLK    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_CLK  :  M0_SPI_RX_CLK ; 
//assign  w_SSPI_TEST_MISO    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_MISO :  M0_SPI_MISO   ; 
//
//assign  w_SSPI_TEST_SCLK    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_CLK  :  M1_SPI_RX_CLK ; 
//assign  w_SSPI_TEST_MISO    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_MISO :  M1_SPI_MISO   ; 
//
//assign  w_SSPI_TEST_SCLK    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_CLK  :  M2_SPI_RX_CLK ; 
//assign  w_SSPI_TEST_MISO    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_MISO :  M2_SPI_MISO   ; 

assign  w_SSPI_TEST_SCLK    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_CLK  :
							  (w_M0_SPI_CS_enable)? M0_SPI_RX_CLK :
							  (w_M1_SPI_CS_enable)? M1_SPI_RX_CLK : 
							  (w_M2_SPI_CS_enable)? M2_SPI_RX_CLK :
													          1'b0; 
assign  w_SSPI_TEST_MISO    = (w_MSPI_EN_CS_WI==0)? w_M0_SPI_MISO :
							  (w_M0_SPI_CS_enable)? M0_SPI_MISO   : 
							  (w_M1_SPI_CS_enable)? M1_SPI_MISO   : 
							  (w_M2_SPI_CS_enable)? M2_SPI_MISO   :
													          1'b0; 


//}


///TODO: //-------------------------------------------------------//


/* TODO: okHost : ok_endpoint_wrapper */ //{
//$$ Endpoints
// Wire In 		0x00 - 0x1F
// Wire Out 	0x20 - 0x3F
// Trigger In 	0x40 - 0x5F
// Trigger Out 	0x60 - 0x7F
// Pipe In 		0x80 - 0x9F
// Pipe Out 	0xA0 - 0xBF

ok_endpoint_wrapper__dummy  ok_endpoint_wrapper_inst (
//ok_endpoint_wrapper  ok_endpoint_wrapper_inst (
	//$$  .okUH (okUH ), //input  wire [4:0]   okUH, // external pins
	//$$  .okHU (okHU ), //output wire [2:0]   okHU, // external pins
	//$$  .okUHU(okUHU), //inout  wire [31:0]  okUHU, // external pins
	//$$  .okAA (okAA ), //inout  wire         okAA, // external pin
	
	//$$ for dummy
	.clk    (sys_clk),
	.reset_n(reset_n),
	
	// Wire In 		0x00 - 0x1F
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
	// Wire Out 	0x20 - 0x3F
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
	// Trigger In 	0x40 - 0x5F
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
	// Trigger Out 	0x60 - 0x7F
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
	// Pipe In 		0x80 - 0x9F
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
	// Pipe Out 	0xA0 - 0xBF
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
	// 
	.okClk(okClk)//output wire okClk // sync with write/read of pipe
	);
//}


///TODO: //-------------------------------------------------------//

/* TODO: FPGA_RUN_LED assign */ //{

wire FPGA_LED_RUN_STATUS;

led_test  led_test__inst (
	.clk       (sys_clk            ), // system 10MHz 
	.reset_n   (reset_n            ),
	.o_run_led (FPGA_LED_RUN_STATUS), // 
	.valid     (                   )
	);	

assign RUN_FPGA_LED = FPGA_LED_RUN_STATUS;

//}


/* TODO: LED assign */ //{

assign led[0] = FPGA_LED_RUN_STATUS;
assign led[1] = ~FPGA_LED_RUN_STATUS; 
assign led[2] = 1'b0;
assign led[3] = 1'b1;

assign led[4] = FPGA_LED_RUN_STATUS; 
assign led[5] = ~FPGA_LED_RUN_STATUS;
assign led[6] = 1'b0;
assign led[7] = 1'b1;

//}


/* TODO: TP assign */ //{

assign test_point[0] = w_SSPI_TEST_MCLK;
assign test_point[1] = w_SSPI_TEST_MOSI; 
assign test_point[2] = w_SSPI_TEST_SS_B;
assign test_point[3] = 1'b0; 

assign test_point[4] = 1'b1; 
assign test_point[5] = 1'b0; 
assign test_point[6] = FPGA_LED_RUN_STATUS;  
assign test_point[7] = ~FPGA_LED_RUN_STATUS; 

//}


endmodule
