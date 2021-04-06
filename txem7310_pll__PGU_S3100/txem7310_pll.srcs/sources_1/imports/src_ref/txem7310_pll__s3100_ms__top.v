// # this           : txem7310_pll__s3100_ms__top.v
// # top xdc        : txem7310_pll__s3100_ms__top.xdc
//
// # board          : S3100-CPU-BASE
// # board sch      : NA
//
// # note: artix-7 top design for S3100 PGU master side


/* top module integration */
module txem7310_pll__s3100_ms__top ( 


	// external clock ports in B13 //{
	input  wire  sys_clkp,  // # i_B13_L12P_MRCC  # W11 
	input  wire  sys_clkn,  // # i_B13_L12N_MRCC  # W12 
	//}
	
	
	//// BANK B15 //{
	
	// ## TPs and EXT_I2C
	inout  wire  io_B15_L1P_AD0P ,  // # H13   # F_TP0 
	inout  wire  io_B15_L1N_AD0N ,  // # G13   # F_TP1 
	inout  wire  io_B15_L2P_AD8P ,  // # G15   # F_TP2 
	inout  wire  io_B15_L2N_AD8N ,  // # G16   # F_TP3 
	inout  wire  io_B15_L3P_AD1P ,  // # J14   # F_TP4 
	inout  wire  io_B15_L3N_AD1N ,  // # H14   # F_TP5 
	//                                         
	output wire   o_B15_L4P ,       // # G17   # EXT_I2C_4_SCL
	inout  wire  io_B15_L4N ,       // # G18   # EXT_I2C_4_SDA
	//                                         
	inout  wire  io_B15_L5P_AD9P ,  // # J15   # F_TP6 
	inout  wire  io_B15_L5N_AD9N ,  // # H15   # F_TP7 
								   
	// ## LAN for END-POINTS       
	output wire   o_B15_L6P ,       // # H17  # LAN_PWDN 
	//input  wire i_B15_L6N_VREF,   // # H18  # NA
	output wire   o_B15_L7P ,       // # J22  # LAN_MOSI
	output wire   o_B15_L7N ,       // # H22  # LAN_SCLK
	output wire   o_B15_L8P ,       // # H20  # LAN_SSN_B
	input  wire   i_B15_L8N ,       // # G20  # LAN_INT_B
	output wire   o_B15_L9P ,       // # K21  # LAN_RST_B
	input  wire   i_B15_L9N ,       // # K22  # LAN_MISO
	
	// ## ADC
	//input  wire i_B15_L10P_AD11P, // # H20  # AUX_AD11P
	//input  wire i_B15_L10N_AD11N, // # G20  # AUX_AD11N

	//input  wire i_B15_L11P_SRCC,  // # J20  # NA
	//input  wire i_B15_L11N_SRCC,  // # J21  # NA

	input  wire i_B15_L12P_MRCC ,   // # J19  # GPIB_IRQ      
	output wire o_B15_L12N_MRCC ,   // # H19  # GPIB_nCS      
	output wire o_B15_L13P_MRCC ,   // # K18  # GPIB_nRESET   
	output wire o_B15_L13N_MRCC ,   // # K19  # GPIB_SW_nOE   
	input  wire i_B15_L14P_SRCC ,   // # L19  # GPIB_REM      
	input  wire i_B15_L14N_SRCC ,   // # L20  # GPIB_TADCS    
	input  wire i_B15_L15P      ,   // # N22  # GPIB_LADCS    
	input  wire i_B15_L15N      ,   // # M22  # GPIB_DCAS     
	input  wire i_B15_L16P      ,   // # M18  # GPIB_TRIG     
	output wire o_B15_L16N      ,   // # L18  # GPIB_DATA_DIR 
	output wire o_B15_L17P      ,   // # N18  # GPIB_DATA_nOE 

	//input  wire i_B15_L17N,       // # N19  # NA
							        
	input  wire i_B15_L18P ,        // # N20  # BA25
	input  wire i_B15_L18N ,        // # M20  # BA24
	input  wire i_B15_L19P ,        // # K13  # BA23
	input  wire i_B15_L19N ,        // # K14  # BA22
	input  wire i_B15_L20P ,        // # M13  # BA21
	input  wire i_B15_L20N ,        // # L13  # BA20
	input  wire i_B15_L21P ,        // # K17  # BA19
	input  wire i_B15_L21N ,        // # J17  # BA18
	input  wire i_B15_L22P ,        // # L14  # BA7
	input  wire i_B15_L22N ,        // # L15  # BA6
	input  wire i_B15_L23P ,        // # L16  # BA5
	input  wire i_B15_L23N ,        // # K16  # BA4
	input  wire i_B15_L24P ,        // # M15  # BA3
	input  wire i_B15_L24N ,        // # M16  # BA2

	//}


////
////IO_L1P_T0_13
////Y16
////IO_L1N_T0_13
////AA16
////IO_L2P_T0_13
////AB16
////IO_L2N_T0_13
////AB17
////IO_L3P_T0_DQS_13
////AA13
////IO_L3N_T0_DQS_13
////AB13
////IO_L4P_T0_13
////AA15
////IO_L4N_T0_13
////AB15
////IO_L5P_T0_13
////Y13
////IO_L5N_T0_13
////AA14
////IO_L6P_T0_13
////W14
////IO_L6N_T0_VREF_13
////Y14
////IO_L7P_T1_13
////AB11
////IO_L7N_T1_13
////AB12
////IO_L8P_T1_13
////AA9
////IO_L8N_T1_13
////AB10
////IO_L9P_T1_DQS_13
////AA10
////IO_L9N_T1_DQS_13
////AA11
////IO_L10P_T1_13
////V10
////IO_L10N_T1_13
////W10
////IO_L11P_T1_SRCC_13
////Y11
////IO_L11N_T1_SRCC_13
////Y12
////IO_L12P_T1_MRCC_13
////W11
////IO_L12N_T1_MRCC_13
////W12
////IO_L13P_T2_MRCC_13
////V13
////IO_L13N_T2_MRCC_13
////V14
////IO_L14P_T2_SRCC_13
////U15
////IO_L14N_T2_SRCC_13
////V15
////IO_L15P_T2_DQS_13
////T14
////IO_L15N_T2_DQS_13
////T15
////IO_L16P_T2_13
////W15
////IO_L16N_T2_13
////W16
////IO_L17P_T2_13
////T16
////IO_L17N_T2_13
////U16
////
////
////SPI_#1_SCLK [3]
////SPI_#1_MISO [3]
////SPI_#1_nCS [3]
////SPI_#1_MOSI [3]
////GPIO_PB5 [3]
////GPIO_PC4 [3]
////GPIO_PC5 [3]
////GPIO_PH6 [3]
////GPIO_PH4 [3]
////GPIO_PC9 [3]
////GPIO_PC10 [3]
////GPIO_PC11 [3]
////GPIO_PC12 [3]
////GPIO_PI8_RUN_LED [3]
////GPIO_PD2 [3]
////TIM#1_CH1 [3]
////TIM#2_CH4 [3]
////IO_LED[0:5] [15]
////MBD_RS_422_SPI_EN [15]
////MBD_RS_422_TRIG_EN [15]
////M0_SPI_TX_EN [14]
////M1_SPI_TX_EN [14]
////M2_SPI_TX_EN [14]
////TRIG_TX_EN [14]
////SPI_#2_SCLK [3]
////SPI_#2_MISO [3]
////SPI_#2_nCS [3]
////SPI_#2_MOSI [3]
////QSPI_BK1_NCS [3]
////QSPI_CLK [3]
////QSPI_BK1_IO0 [3]
////QSPI_BK1_IO1 [3]
////QSPI_BK1_IO2 [3]
////QSPI_BK1_IO3 [3]
////
////ETH_nIRQ [11]
////ETH_nRESET [11]
////ETH_nCS [11]
////ETH_nTXLED [11]
////ETH_nRXLED [11]
////ETH_nLINKLED [11]
////
////200MHz_LVDS-
////200MHz_LVDS+
////
////SYNC_10MHz [12]
////EXT_TRIG_IN_CW [12]
////
////FPGA_FAN_SENS#0 [13]
////FPGA_FAN_SENS#1 [13]
////FPGA_FAN_SENS#2 [13]
////FPGA_FAN_SENS#3 [13]
////FPGA_FAN_SENS#4 [13]
////FPGA_FAN_SENS#5 [13]
////FPGA_FAN_SENS#6 [13]
////FPGA_FAN_SENS#7 [13]




	//// BANK 14 16 signals // NOT compatible with TXEM7310 connectors
	
	
	
	//// BANK 13 34 35 signals // compatible with TXEM7310 connectors
	
	// MC1 - odd //{
										   // # MC1-1   # VDC_IN
										   // # MC1-3   # VDC_IN
										   // # MC1-5   # VDC_IN
										   // # MC1-7   # VDD_1.8V
										   // # MC1-9   # VDD_3.3V
										   // # MC1-11  # VDD_3.3V
										   // # MC1-13  # VDD_3.3V
	output wire			o_B34D_L24P,       // # MC1-15  # DAC0_DAT_P10 //$$ --> DAC0_DAT_N8  // swap
	output wire			o_B34D_L24N,       // # MC1-17  # DAC0_DAT_N10 //$$ --> DAC0_DAT_P8  // swap
	output wire			o_B34D_L17P,       // # MC1-19  # DAC0_DAT_P9  //$$ --> DAC0_DAT_N9  // swap
	output wire			o_B34D_L17N,       // # MC1-21  # DAC0_DAT_N9  //$$ --> DAC0_DAT_P9  // swap
	output wire			o_B34D_L16P,       // # MC1-23  # DAC0_DAT_P8  //$$ --> DAC0_DAT_N10 // swap
	output wire			o_B34D_L16N,       // # MC1-25  # DAC0_DAT_N8  //$$ --> DAC0_DAT_P10 // swap
	input  wire			c_B34D_L14P_SRCC,  // # MC1-27  # DAC0_DCO_P
	input  wire			c_B34D_L14N_SRCC,  // # MC1-29  # DAC0_DCO_N
	output wire			o_B34D_L10P,       // # MC1-31  # DAC0_DCI_P
	output wire			o_B34D_L10N,       // # MC1-33  # DAC0_DCI_N
										   // # MC1-35  # GND
	output wire			o_B34D_L20P,       // # MC1-37  # DAC0_DAT_P7
	output wire			o_B34D_L20N,       // # MC1-39  # DAC0_DAT_N7
	output wire			o_B34D_L3P,        // # MC1-41  # DAC0_DAT_P6
	output wire			o_B34D_L3N,        // # MC1-43  # DAC0_DAT_N6
	output wire			o_B34D_L9P,        // # MC1-45  # DAC0_DAT_P5
	output wire			o_B34D_L9N,        // # MC1-47  # DAC0_DAT_N5
	output wire			o_B34D_L2P,        // # MC1-49  # DAC0_DAT_P4
	output wire			o_B34D_L2N,        // # MC1-51  # DAC0_DAT_N4
	output wire			o_B34D_L4P,        // # MC1-53  # DAC0_DAT_P3
										   // # MC1-55  # GND
	output wire			o_B34D_L4N,        // # MC1-57  # DAC0_DAT_N3
	output wire			o_B34D_L1P,        // # MC1-59  # DAC0_DAT_P2
	output wire			o_B34D_L1N,        // # MC1-61  # DAC0_DAT_N2
	output wire			o_B34D_L7P,        // # MC1-63  # DAC0_DAT_P1
	output wire			o_B34D_L7N,        // # MC1-65  # DAC0_DAT_N1
	output wire			o_B13_L2P,         // # MC1-67  # SPIO0_CS
	output wire			o_B13_L2N,         // # MC1-69  # SPIOx_SCLK
	output wire			o_B13_L4P,         // # MC1-71  # SPIOx_MOSI
	input  wire			i_B13_L4N,         // # MC1-73  # SPIOx_MISO
	output wire			o_B13_L1P,         // # MC1-75  # SPIO1_CS
	output wire			o_B34D_L12P_MRCC,  // # MC1-77  # DAC0_DAT_P0
	output wire			o_B34D_L12N_MRCC,  // # MC1-79  # DAC0_DAT_N0
	
	
	//}
	
	// MC1 - even //{
										   // # MC1-2   # GND
										   // # MC1-4   # VDD_1.0V
										   // # MC1-6   # VDD_1.0V
	output wire			o_B13_SYS_CLK_MC1, // # MC1-8   # DACx_RST_B
	input  wire			i_XADC_VN,         // # MC1-10  # XADC_VN // external ADC ports 
	input  wire			i_XADC_VP,         // # MC1-12  # XADC_VP // external ADC ports 
										   // # MC1-14  # GND
	output wire			o_B34D_L21P,       // # MC1-16  # DAC0_DAT_P15 //$$ --> DAC0_DAT_N12 // swap
	output wire			o_B34D_L21N,       // # MC1-18  # DAC0_DAT_N15 //$$ --> DAC0_DAT_P12 // swap
	output wire			o_B34D_L19P,       // # MC1-20  # DAC0_DAT_P14 //$$ --> DAC0_DAT_N13 // swap
	output wire			o_B34D_L19N,       // # MC1-22  # DAC0_DAT_N14 //$$ --> DAC0_DAT_P13 // swap
	output wire			o_B34D_L23P,       // # MC1-24  # DAC0_DAT_P13 //$$ --> DAC0_DAT_N14 // swap
	output wire			o_B34D_L23N,       // # MC1-26  # DAC0_DAT_N13 //$$ --> DAC0_DAT_P14 // swap
	output wire			o_B34D_L15P,       // # MC1-28  # DAC0_DAT_P12 //$$ --> DAC0_DAT_N15 // swap
	output wire			o_B34D_L15N,       // # MC1-30  # DAC0_DAT_N12 //$$ --> DAC0_DAT_P15 // swap
	output wire			o_B34D_L13P_MRCC,  // # MC1-32  # DAC0_DAT_P11
	output wire			o_B34D_L13N_MRCC,  // # MC1-34  # DAC0_DAT_N11
										   // # MC1-36  # MC1_VCCO
	input  wire			c_B34D_L11P_SRCC,  // # MC1-38  # ADC0_DCO_P
	input  wire			c_B34D_L11N_SRCC,  // # MC1-40  # ADC0_DCO_N
	input  wire			i_B34D_L18P,       // # MC1-42  # ADC0_DA_P
	input  wire			i_B34D_L18N,       // # MC1-44  # ADC0_DA_N
	input  wire			i_B34D_L22P,       // # MC1-46  # ADC0_DB_P
	input  wire			i_B34D_L22N,       // # MC1-48  # ADC0_DB_N
	output wire			o_B34D_L6P,        // # MC1-50  # ADCx_CNV_P
	output wire			o_B34D_L6N,        // # MC1-52  # ADCx_CNV_N
	output wire			o_B34_L5P,         // # MC1-54  # ADCx_TPT_B
										   // # MC1-56  # MC1_VCCO
	inout  wire			io_B34_L5N,        // # MC1-58  # S_IO_0
	output wire			o_B34D_L8P,        // # MC1-60  # ADCx_CLK_P
	output wire			o_B34D_L8N,        // # MC1-62  # ADCx_CLK_N
	output wire			o_B13_L5P,         // # MC1-64  # DAC1_CS
	output wire			o_B13_L5N,         // # MC1-66  # DACx_SCLK
	output wire			o_B13_L3P,         // # MC1-68  # DACx_SDIO
	input  wire			i_B13_L3N,         // # MC1-70  # DACx_SDO
	output wire			o_B13_L16P,        // # MC1-72  # DAC0_CS
	inout  wire			io_B13_L16N,       // # MC1-74  # S_IO_1
	inout  wire			io_B13_L1N,        // # MC1-76  # S_IO_2
										   // # MC1-78  # GND
										   // # MC1-80  # GND
	//}
	
	// MC2 - odd //{
										   // # MC2-1   # GND
										   // # MC2-3   # +VCCBATT
										   // # MC2-5   # FPGA_TCK
										   // # MC2-7   # FPGA_TMS
										   // # MC2-9   # FPGA_TDI
	output wire			o_B13_SYS_CLK_MC2, // # MC2-11  # CLKD_SYNC
										   // # MC2-13  # GND
	output wire			o_B35D_L21P,       // # MC2-15  # DAC1_DAT_N0  //$$ --> DAC1_DAT_P3
	output wire			o_B35D_L21N,       // # MC2-17  # DAC1_DAT_P0  //$$ --> DAC1_DAT_N3
	output wire			o_B35D_L19P,       // # MC2-19  # DAC1_DAT_N1  //$$ --> DAC1_DAT_P2
	output wire			o_B35D_L19N,       // # MC2-21  # DAC1_DAT_P1  //$$ --> DAC1_DAT_N2
	output wire			o_B35D_L18P,       // # MC2-23  # DAC1_DAT_N2  //$$ --> DAC1_DAT_P1
	output wire			o_B35D_L18N,       // # MC2-25  # DAC1_DAT_P2  //$$ --> DAC1_DAT_N1
	output wire			o_B35D_L23P,       // # MC2-27  # DAC1_DAT_N3  //$$ --> DAC1_DAT_P0
	output wire			o_B35D_L23N,       // # MC2-29  # DAC1_DAT_P3  //$$ --> DAC1_DAT_N0
	input  wire			i_B35_L15P,        // # MC2-31  # CLKD_STAT
	input  wire			i_B35_L15N,        // # MC2-33  # CLKD_REFM
										   // # MC2-35  # MC2_VCCO
	input  wire			i_B35D_L9P,        // # MC2-37  # ADC1_DB_P
	input  wire			i_B35D_L9N,        // # MC2-39  # ADC1_DB_N
	input  wire			i_B35D_L7P,        // # MC2-41  # ADC1_DA_P
	input  wire			i_B35D_L7N,        // # MC2-43  # ADC1_DA_N
	input  wire			c_B35D_L11P_SRCC,  // # MC2-45  # ADC1_DCO_P
	input  wire			c_B35D_L11N_SRCC,  // # MC2-47  # ADC1_DCO_N
	output wire			o_B35_L4P,         // # MC2-49  # CLKD_SCLK
	output wire			o_B35_L4N,         // # MC2-51  # CLKD_CS_B
	input  wire			i_B35_L6P,         // # MC2-53  # CLKD_SDO 
										   // # MC2-55  # MC2_VCCO
	inout  wire			io_B35_L6N,        // # MC2-57  # CLKD_SDIO
	output wire			o_B35D_L1P,        // # MC2-59  # DAC1_DAT_N13 // PN swap
	output wire			o_B35D_L1N,        // # MC2-61  # DAC1_DAT_P13 // PN swap
	output wire			o_B35D_L13P_MRCC,  // # MC2-63  # DAC1_DAT_N14 // PN swap
	output wire			o_B35D_L13N_MRCC,  // # MC2-65  # DAC1_DAT_P14 // PN swap
	output wire			o_B35D_L12P_MRCC,  // # MC2-67  # DAC1_DAT_N15 // PN swap
	output wire			o_B35D_L12N_MRCC,  // # MC2-69  # DAC1_DAT_P15 // PN swap
	input  wire			i_B13_L17P,        // # MC2-71  # LAN_MISO     
	output wire			o_B13_L17N,        // # MC2-73  # LAN_RSTn     
	input  wire			c_B13D_L13P_MRCC,  // # MC2-75  # CLKD_COUT_P   
	input  wire			c_B13D_L13N_MRCC,  // # MC2-77  # CLKD_COUT_N   
	input  wire			i_B13_L11P_SRCC,   // # MC2-79  # LAN_INTn     
	//}
	
	// MC2 - even //{
										   // # MC2-2   # VDD_3.3V
										   // # MC2-4   # VDD_3.3V
										   // # MC2-6   # VDD_3.3V
										   // # MC2-8   # FPGA_TDO
	output wire			o_B35_IO0,         // # MC2-10  # CLKD_RST_B
	input  wire			i_B35_IO25,        // # MC2-12  # CLKD_LD
	//                                     // # MC2-14  # GND
	output wire			o_B35D_L24P,       // # MC2-16  # DAC1_DAT_N4 //$$ --> DAC1_DAT_P7
	output wire			o_B35D_L24N,       // # MC2-18  # DAC1_DAT_P4 //$$ --> DAC1_DAT_N7
	output wire			o_B35D_L22P,       // # MC2-20  # DAC1_DAT_N5 //$$ --> DAC1_DAT_P6
	output wire			o_B35D_L22N,       // # MC2-22  # DAC1_DAT_P5 //$$ --> DAC1_DAT_N6
	output wire			o_B35D_L20P,       // # MC2-24  # DAC1_DAT_N6 //$$ --> DAC1_DAT_P5
	output wire			o_B35D_L20N,       // # MC2-26  # DAC1_DAT_P6 //$$ --> DAC1_DAT_N5
	output wire			o_B35D_L16P,       // # MC2-28  # DAC1_DAT_N7 //$$ --> DAC1_DAT_P4
	output wire			o_B35D_L16N,       // # MC2-30  # DAC1_DAT_P7 //$$ --> DAC1_DAT_N4
	output wire			o_B35D_L17P,       // # MC2-32  # DAC1_DCI_N   // PN swap
	output wire			o_B35D_L17N,       // # MC2-34  # DAC1_DCI_P   // PN swap
										   // # MC2-36  # GND
	input  wire			c_B35D_L14P_SRCC,  // # MC2-38  # DAC1_DCO_N   // PN swap
	input  wire			c_B35D_L14N_SRCC,  // # MC2-40  # DAC1_DCO_P   // PN swap
	output wire			o_B35D_L10P,       // # MC2-42  # DAC1_DAT_N8  // PN swap
	output wire			o_B35D_L10N,       // # MC2-44  # DAC1_DAT_P8  // PN swap
	output wire			o_B35D_L8P,        // # MC2-46  # DAC1_DAT_N9  // PN swap
	output wire			o_B35D_L8N,        // # MC2-48  # DAC1_DAT_P9  // PN swap
	output wire			o_B35D_L5P,        // # MC2-50  # DAC1_DAT_N10 // PN swap
	output wire			o_B35D_L5N,        // # MC2-52  # DAC1_DAT_P10 // PN swap
	output wire			o_B35D_L3P,        // # MC2-54  # DAC1_DAT_N11 // PN swap
										   // # MC2-56  # GND				
	output wire			o_B35D_L3N,        // # MC2-58  # DAC1_DAT_P11 // PN swap
	output wire			o_B35D_L2P,        // # MC2-60  # DAC1_DAT_N12 // PN swap
	output wire			o_B35D_L2N,        // # MC2-62  # DAC1_DAT_P12 // PN swap
	input  wire			i_B13D_L14P_SRCC,  // # MC2-64  # TRIG_IN_P    // 
	input  wire			i_B13D_L14N_SRCC,  // # MC2-66  # TRIG_IN_N    // 
	output wire			o_B13_L15P,        // # MC2-68  # TRIG_OUT_P   //$$ B13 LVCMOS25 
	output wire			o_B13_L15N,        // # MC2-70  # TRIG_OUT_N   //$$ B13 LVCMOS25 
	output wire			o_B13_L6P,         // # MC2-72  # LAN_SSNn     // 
	output wire			o_B13_L6N,         // # MC2-74  # LAN_SCLK     // 
	output wire			o_B13_L11N_SRCC,   // # MC2-76  # LAN_MOSI     // 
										   // # MC2-78  # GND
	                                       // # MC2-80  # GND
	//}

	// LED on XEM7310 //{
	output wire [7:0]   led
	//}
	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID = h_BD_21_0310   //{
//parameter FPGA_IMAGE_ID = 32'h_B0_19_10DD; // PGU-CPU-F5500 // pin map setup
//parameter FPGA_IMAGE_ID = 32'h_B0_19_1008; // PGU-CPU-F5500 // pll setup
//parameter FPGA_IMAGE_ID = 32'h_B1_19_1013; // PGU-CPU-F5500 // dac1 pin swap
//parameter FPGA_IMAGE_ID = 32'h_B1_19_1016; // PGU-CPU-F5500 // dac partial pin swap
//parameter FPGA_IMAGE_ID = 32'h_B1_19_1017; // PGU-CPU-F5500 // spio partial pin swap
//parameter FPGA_IMAGE_ID = 32'h_B2_19_1109; // PGU-CPU-F5500 // spio pin test / other outputs zero
//parameter FPGA_IMAGE_ID = 32'h_B2_19_1112; // PGU-CPU-F5500 // spio ext ic (MCP23S17) test / other outputs zero
//parameter FPGA_IMAGE_ID = 32'h_B3_19_1114; // PGU-CPU-F5500 // clock distribution ic (AD9516-1) test / other outputs zero
//parameter FPGA_IMAGE_ID = 32'h_B4_19_1118; // PGU-CPU-F5500 // dac (AD9783) io test / spi check
//parameter FPGA_IMAGE_ID = 32'h_B4_19_1122; // PGU-CPU-F5500 // dac (AD9783) io test / spi check + trig style 
//parameter FPGA_IMAGE_ID = 32'h_B5_19_1125; // PGU-CPU-F5500 // DAC AMP path test + multi-level test of 8 sequence
//parameter FPGA_IMAGE_ID = 32'h_B5_19_1127; // PGU-CPU-F5500 // DAC AMP path test + pll_bw_hi__jt_50ps
//parameter FPGA_IMAGE_ID = 32'h_B7_19_1129; // PGU-CPU-F5500 // DAC-FPGA sync test / duration controlled sequence test
//parameter FPGA_IMAGE_ID = 32'h_B7_19_1206; // PGU-CPU-F5500 // DAC FIFO test / global time index in debugger
//parameter FPGA_IMAGE_ID = 32'h_B8_19_1211; // PGU-CPU-F5500 // soft CPU setup
//parameter FPGA_IMAGE_ID = 32'h_B9_19_1216; // PGU-CPU-F5500 // lan wiz850 setup
//parameter FPGA_IMAGE_ID = 32'h_BA_19_1218; // PGU-CPU-F5500 // mcs end-points, dac control by soft-cpu
//parameter FPGA_IMAGE_ID = 32'h_BA_20_0201; // PGU-CPU-F5500 // mcs end-points, dac control by soft-cpu, FIFO reset revision // FIFO-512
//parameter FPGA_IMAGE_ID = 32'h_BB_20_0206; // PGU-CPU-F5500 // release test // FIFO-1K // pll reset signals and dac freq count to come
//parameter FPGA_IMAGE_ID = 32'h_BB_20_0208; // PGU-CPU-F5500 // release test // FIFO-1K // CLKD serial clock down 100kHz
//parameter FPGA_IMAGE_ID = 32'h_BC_20_0309; // PGU-CPU-F5500 // release test // FIFO-1K // pulse rev: output status, period setting.
//parameter FPGA_IMAGE_ID = 32'h_BD_20_1216; // PGU-CPU-F5500 // EEPROM test // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_20_1230; // PGU-CPU-F5500 // update top-dsn for new LAN test // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0107; // PGU-CPU-F5500 // setup DAC debugger // pll rev for dac clock enable // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0108; // PGU-CPU-F5500 // dac timing test 6ns-->5ns // fifo 400MHz // XC7A200T_FBG484-2 up // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0109; // PGU-CPU-F5500 // dac timing test 6ns back // fifo 400MHz // XC7A200T_FBG484-1 back // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0112; // PGU-CPU-F5500 // dac pattern gen wrapper design // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0119; // PGU-CPU-F5500 // dac pattern gen : Code-Inc-Dur 8-seq test // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0124; // PGU-CPU-F5500 // dac pattern gen : Code-Inc-Dur fifo test // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0205; // PGU-CPU-F5500 // dac pattern gen : FCID fifo reload test // with XEM7310
parameter FPGA_IMAGE_ID = 32'h_BD_21_0310; // PGU-CPU-F5500 // dac pattern gen : dsp maacro test // with XEM7310

// to support dac timing 2.5ns after re-forming FIFO struct
// to support TXEM7310-FPGA-CORE to come

//}

// check SW_BUILD_ID //{
parameter REQ_SW_BUILD_ID = 32'h_A57E_183C; // 0 for bypass 
//}

//}

//-------------------------------------------------------//

/* TODO: clock/pll and reset */ //{

// clock pll0 //{
wire clk_out1_200M ; // REFCLK 200MHz for IDELAYCTRL // for pll1
wire clk_out2_140M ; // for pll2 ... 140M
wire clk_out3_10M  ; // for slow logic / I2C //
wire clk_out4_10M ; // for XADC 
//
wire clk_locked_pre;
clk_wiz_0  clk_wiz_0_inst (
	// Clock out ports  
	.clk_out1_200M (clk_out1_200M ), // BUFG
	.clk_out2_140M (clk_out2_140M ), // BUFG
	// Status and control signals               
	.locked(clk_locked_pre),
	// Clock in ports
	.clk_in1_p(sys_clkp),
	.clk_in1_n(sys_clkn)
);
////
clk_wiz_0_0_1  clk_wiz_0_0_1_inst (
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
//wire clk1_out1_160M; // for DWAVE 
//wire clk1_out2_120M; // unused
//wire clk1_out3_80M ; // unused
//wire clk1_out4_60M ; // unused // 10M exact...

wire clk1_locked = 1'b1; // unused

//  clk_wiz_0_1  clk_wiz_0_1_inst (
//  	// Clock out ports  
//  	.clk_out1_160M(clk1_out1_160M),  
//  	.clk_out2_120M(clk1_out2_120M), 
//  	.clk_out3_80M (clk1_out3_80M ), 
//  	.clk_out4_60M (clk1_out4_60M ), 
//  	// Status and control signals     
//  	.resetn(clk_locked_pre),          
//  	.locked(clk1_locked),
//  	// Clock in ports
//  	.clk_in1(clk_out1_200M)
//  );

//}

// clock pll2 //{
// wire clk2_out1_210M; // for HR-ADC and test_clk
// wire clk2_out2_105M; // unused
// wire clk2_out3_60M ; // for ADC fifo/serdes
// wire clk2_out4_30M ; // unused             

wire clk2_locked = 1'b1; // unused

//  clk_wiz_0_2  clk_wiz_0_2_inst (
//  	// Clock out ports  
//  	.clk_out1_210M(clk2_out1_210M),  
//  	.clk_out2_105M(clk2_out2_105M), 
//  	.clk_out3_60M (clk2_out3_60M ), 
//  	.clk_out4_30M (clk2_out4_30M ), 
//  	// Status and control signals     
//  	.resetn(clk_locked_pre),          
//  	.locked(clk2_locked),
//  	// Clock in ports
//  	.clk_in1(clk_out2_140M) // 200M --> 140M for better jitter.
//  );

//}

// clock pll3 //{
wire clk3_out1_72M ; // MCS core; IO bridge
wire clk3_out2_144M; // LAN-SPI control 144MHz 
wire clk3_out3_12M ; // slow logic // not used yet
wire clk3_out4_72M ; // eeprom fifo
//
wire clk3_locked;
//
clk_wiz_0_3_1  clk_wiz_0_3_1_inst (
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
//wire clk4_out2_10M ; // for DAC clock measure // unused
//
wire clk4_locked = 1'b1;
//  clk_wiz_0_4  clk_wiz_0_4_inst (
//  	// Clock out ports  
//  	.clk_out1_10M (xadc_clk ),  // BUFH --> BUFG
//  	//.clk_out2_10M (clk4_out2_10M ),  // BUFG
//  	// Status and control signals     
//  	.resetn(clk_locked_pre),          
//  	.locked(clk4_locked),
//  	// Clock in ports
//  	.clk_in1(clk_out1_200M)
//  );

//}

// clock pll for DAC 400MHz  //{

// add more clocks for DAC0_DCI DAC1_DCI
//  DCI pin swap info:
//    DAC0_DCI_P/N - pin noraml
//    DAC1_DCI_P/N - pin swap

//$$ note ... 
//    clk_wiz_1 setting : eventually 1:1
//                        output 400MHz --> 200MHz 
//                        input             200MHz
//    input clock from CLKD 400MHz 
//    clk_wiz_1 --> clk_wiz_1_3 removed unused

wire clk_dac_out1_400M; // DAC update rate 
wire clk_dac_out2_400M_0;   // for DAC0_DCI //$$ alternative to DAC0_DCO
wire clk_dac_out3_400M_180; // for DAC1_DCI //$$ alternative to DAC1_DCO
//
wire clk_dac_locked;
wire clk_dac_clk_in; // from  CLKD_COUT or c_B13D_L13P_MRCC // for DAC/CLK 400MHz pll
wire clk_dac_clk_rst;
//

clk_wiz_1_2  clk_wiz_1_2_inst (
	// Clock out ports  
	.clk_out1_200M      (clk_dac_out1_400M     ), // BUFGCE // same buf type for phase align 
	.clk_out2_200M_0    (clk_dac_out2_400M_0   ), // BUFGCE // same buf type for phase align
	.clk_out3_200M_180  (clk_dac_out3_400M_180 ), // BUFGCE // same buf type for phase align
	// clock en ports
	.clk_out1_200M_ce     (1'b1),
	.clk_out2_200M_0_ce   (1'b1),
	.clk_out3_200M_180_ce (1'b1),
	// Status and control signals     
	.resetn(clk_locked_pre & ~clk_dac_clk_rst),          
	.locked(clk_dac_locked),
	// Clock in ports
	.clk_in1_200M       (clk_dac_clk_in) // no buf
);

//clk_wiz_1_3  clk_wiz_1_3_inst (
//	// Clock out ports  
//	.clk_out1_400M      (clk_dac_out1_400M     ), // BUFGCE // same buf type for phase align 
//	.clk_out2_400M_0    (clk_dac_out2_400M_0   ), // BUFGCE // same buf type for phase align
//	.clk_out3_400M_180  (clk_dac_out3_400M_180 ), // BUFGCE // same buf type for phase align
//	// clock en ports
//	.clk_out1_400M_ce     (1'b1),
//	.clk_out2_400M_0_ce   (1'b1),
//	.clk_out3_400M_180_ce (1'b1),
//	// Status and control signals     
//	.resetn(clk_locked_pre & ~clk_dac_clk_rst),          
//	.locked(clk_dac_locked),
//	// Clock in ports
//	.clk_in1_400M       (clk_dac_clk_in) // no buf
//);

//   
wire dac0_dco_clk_out1_400M; // DAC0 update rate 
//wire dac0_dco_clk_out2_200M; // DAC0 DMA rate     //$$ unused
wire dac0_dco_clk_out5_400M; // DAC0 DCI
wire dac1_dco_clk_out1_400M; // DAC1 update rate 
//wire dac1_dco_clk_out2_200M; // DAC1 DMA rate     //$$ unused
wire dac1_dco_clk_out5_400M; // DAC1 DCI
//
wire dac0_dco_clk_locked;
wire dac0_dco_clk_in;
wire dac0_dco_clk_rst; 
wire dac1_dco_clk_locked;
wire dac1_dco_clk_in;
wire dac1_dco_clk_rst; 
//
wire dac0_clk_dis; // clock disable
wire dac1_clk_dis; // clock disable
//
assign dac0_dco_clk_in = clk_dac_out2_400M_0; // for common clock 
// TODO: must see polarity ... --------////
// note DAC1_DCI and DAC1_DCO are both PN swapped in board 
// note in PGU board... DCI and DAC codes are directly generated from FPGA... in this case, DCO is not necessary.
// in case of DCI coming from external pll, DCO must be used.
assign dac1_dco_clk_in = clk_dac_out3_400M_180; // for common clock //$$ emulation for PN swap of DAC1_DCO
//
//

clk_wiz_1_2  clk_wiz_1_2_0_inst ( // VCO 1200MHz
	// Clock out ports  
	.clk_out1_200M     (dac0_dco_clk_out1_400M), // BUFGCE // //$$ for dac0_clk
	.clk_out2_200M_0   (dac0_dco_clk_out5_400M), // BUFGCE // //$$ for DAC0_DCI
	.clk_out3_200M_180 (),
	// clock en ports
	.clk_out1_200M_ce     (1'b1 & (~dac0_clk_dis) ),
	.clk_out2_200M_0_ce   (1'b1 & (~dac0_clk_dis) ),
	.clk_out3_200M_180_ce (1'b0),
	// Status and control signals            
	.resetn(clk_locked_pre & ~dac0_dco_clk_rst),          
	.locked(dac0_dco_clk_locked),
	// Clock in ports
	.clk_in1_200M      (dac0_dco_clk_in) // no buf
);
//
clk_wiz_1_2  clk_wiz_1_2_1_inst (
	// Clock out ports  
	.clk_out1_200M     (dac1_dco_clk_out5_400M), // BUFGCE // 0 deg for dci same phase with clk in //$$ for DAC1_DCI 
	.clk_out2_200M_0   (),
	.clk_out3_200M_180 (dac1_dco_clk_out1_400M), // BUFGCE // 180 deg for clock in PN swap //$$ for dac1_clk
	// clock en ports
	.clk_out1_200M_ce     (1'b1 & (~dac1_clk_dis) ),
	.clk_out2_200M_0_ce   (1'b0),
	.clk_out3_200M_180_ce (1'b1 & (~dac1_clk_dis) ),
	// Status and control signals            
	.resetn(clk_locked_pre & ~dac1_dco_clk_rst),          
	.locked(dac1_dco_clk_locked),
	// Clock in ports
	.clk_in1_200M      (dac1_dco_clk_in) // no buf // 0 deg
);

//  clk_wiz_1_3  clk_wiz_1_3_0_inst ( // VCO 1400MHz
//  	// Clock out ports  
//  	.clk_out1_400M     (dac0_dco_clk_out1_400M), // BUFGCE // //$$ for dac0_clk
//  	.clk_out2_400M_0   (dac0_dco_clk_out5_400M), // BUFGCE // //$$ for DAC0_DCI
//  	.clk_out3_400M_180 (),
//  	// clock en ports
//  	.clk_out1_400M_ce     (1'b1 & (~dac0_clk_dis) ),
//  	.clk_out2_400M_0_ce   (1'b1 & (~dac0_clk_dis) ),
//  	.clk_out3_400M_180_ce (1'b0),
//  	// Status and control signals            
//  	.resetn(clk_locked_pre & ~dac0_dco_clk_rst),          
//  	.locked(dac0_dco_clk_locked),
//  	// Clock in ports
//  	.clk_in1_400M      (dac0_dco_clk_in) // no buf
//  );
//  //
//  clk_wiz_1_3  clk_wiz_1_3_1_inst (
//  	// Clock out ports  
//  	.clk_out1_400M     (dac1_dco_clk_out5_400M), // BUFGCE // 0 deg for dci same phase with clk in //$$ for DAC1_DCI 
//  	.clk_out2_400M_0   (),
//  	.clk_out3_400M_180 (dac1_dco_clk_out1_400M), // BUFGCE // 180 deg for clock in PN swap //$$ for dac1_clk
//  	// clock en ports
//  	.clk_out1_400M_ce     (1'b1 & (~dac1_clk_dis) ),
//  	.clk_out2_400M_0_ce   (1'b0),
//  	.clk_out3_400M_180_ce (1'b1 & (~dac1_clk_dis) ),
//  	// Status and control signals            
//  	.resetn(clk_locked_pre & ~dac1_dco_clk_rst),          
//  	.locked(dac1_dco_clk_locked),
//  	// Clock in ports
//  	.clk_in1_400M      (dac1_dco_clk_in) // no buf // 0 deg
//  );

//}

// test clock out //{
wire w_trig_p_oddr_out; // to TRIG_OUT_P
wire w_trig_n_oddr_out; // to TRIG_OUT_N
wire w_oddr_in = clk_dac_out1_400M; // OK ... xdc set_output_delay
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TRIG_P_inst (
	.Q(w_trig_p_oddr_out),   // 1-bit DDR output
	.C(w_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge) // normal
	.D2(1'b0), // 1-bit data input (negative edge) // normal
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TRIG_N_inst (
	.Q(w_trig_n_oddr_out),   // 1-bit DDR output
	.C(w_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b0), // 1-bit data input (positive edge) // inverted
	.D2(1'b1), // 1-bit data input (negative edge) // inverted
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);

//}

// clock locked 
//$$wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked
//$$                  & clk_dac_locked & dac0_dco_clk_locked & dac1_dco_clk_locked;
wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked;

// system clock
wire sys_clk	= clk_out3_10M;

// system reset 
wire reset_n	= clk_locked;
wire reset		= ~reset_n;

// clocks 
wire mcs_clk    = clk3_out1_72M;
wire lan_clk      = clk3_out2_144M;
wire lan_io_clk  = clk3_out3_12M; // not used yet
wire  mcs_eeprom_fifo_clk = clk3_out4_72M;
//
wire xadc_clk =  clk_out4_10M;



//// DAC clocks
	
wire dac0_clk   = dac0_dco_clk_out1_400M; 
wire dac1_clk   = dac1_dco_clk_out1_400M; 

// dac dci oddr output //{
wire w_dac0_dci_oddr_out; // to DAC0_DCI
wire w_dac1_dci_oddr_out; // to DAC1_DCI
wire w_dac0_dci_oddr_in = dac0_dco_clk_out5_400M; 
wire w_dac1_dci_oddr_in = dac1_dco_clk_out5_400M; // PN swap in pll 180 degree
// use common clock 
//wire w_dac0_dci_oddr_in = clk_dac_out2_400M_0  ; 
//wire w_dac1_dci_oddr_in = clk_dac_out3_400M_180; // PN swap in pll 180 degree
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
)   ODDR_dac0_dci_inst (
	.Q(w_dac0_dci_oddr_out),   // 1-bit DDR output
	.C(w_dac0_dci_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge)
	.D2(1'b0), // 1-bit data input (negative edge)
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
)   ODDR_dac1_dci_inst (
	.Q(w_dac1_dci_oddr_out),   // 1-bit DDR output
	.C(w_dac1_dci_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge)
	.D2(1'b0), // 1-bit data input (negative edge)
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
	
//}	
	
//}


///TODO: //-------------------------------------------------------//


/* TODO: end-point wires */ //{

// end-points : USB vs LAN 

// wrapper modules : ok_endpoint_wrapper for USB  vs  lan_endpoint_wrapper for LAN
// ok_endpoint_wrapper  : usb host interface <--> end-points
//    okHost okHI
//    ok...
// lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1  soft_cpu_mcs_inst
//    mcs_io_bridge_ext  mcs_io_bridge_inst2
//    master_spi_wz850_ext  master_spi_wz850_inst
//    fifo_generator_3  LAN_fifo_wr_inst
//    fifo_generator_3  LAN_fifo_rd_inst


//// TODO: USB end-point wires: //{

// Wire In 		0x00 - 0x1F //{
wire [31:0] ep00wire; //$$ [TEST] SW_BUILD_ID 
wire [31:0] ep01wire; //$$ [TEST] TEST_CON 
wire [31:0] ep02wire; //
wire [31:0] ep03wire; //$$ [TEST] BRD_CON
wire [31:0] ep04wire; //$$ [DACX] DACX_DAT_WI         // PGU
wire [31:0] ep05wire; //$$ [DACX] DACX_WI             // PGU
wire [31:0] ep06wire; //$$ [CLKD] CLKD_WI             // PGU
wire [31:0] ep07wire; //$$ [SPIO] SPIO_WI             // PGU
wire [31:0] ep08wire; //$$ [DACZ] DACZ_DAT_WI         // PGU
wire [31:0] ep09wire; //
wire [31:0] ep0Awire; //
wire [31:0] ep0Bwire; //
wire [31:0] ep0Cwire; //
wire [31:0] ep0Dwire; //
wire [31:0] ep0Ewire; //
wire [31:0] ep0Fwire; //
wire [31:0] ep10wire; //
wire [31:0] ep11wire; //
wire [31:0] ep12wire; //$$ [MEM] MEM_FDAT_WI
wire [31:0] ep13wire; //$$ [MEM] MEM_WI
wire [31:0] ep14wire; //
wire [31:0] ep15wire; //
wire [31:0] ep16wire; //
wire [31:0] ep17wire; //
wire [31:0] ep18wire; //
wire [31:0] ep19wire; //$$ [MCS] MCS_SETUP_WI  
wire [31:0] ep1Awire; //
wire [31:0] ep1Bwire; //
wire [31:0] ep1Cwire; //
wire [31:0] ep1Dwire; //
wire [31:0] ep1Ewire; //
wire [31:0] ep1Fwire; //
//}

// Wire Out 	0x20 - 0x3F //{
wire [31:0] ep20wire;         //$$ [TEST] FPGA_IMAGE_ID       // PGU
wire [31:0] ep21wire;         //$$ [TEST] TEST_OUT            // PGU
wire [31:0] ep22wire;         //$$ [TEST] TIMESTAMP_WO        // PGU
wire [31:0] ep23wire;         //$$ [TEST] TEST_IO_MON         // PGU
wire [31:0] ep24wire;         //$$ [DACX] DACX_DAT_WO         // PGU
wire [31:0] ep25wire;         //$$ [DACX] DACX_WO             // PGU
wire [31:0] ep26wire;         //$$ [CLKD] CLKD_WO             // PGU
wire [31:0] ep27wire;         //$$ [SPIO] SPIO_WO             // PGU
wire [31:0] ep28wire;         //$$ [DACZ] DACZ_DAT_WO         // PGU
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
wire [31:0] ep3Awire;         //$$ [XADC] XADC_TEMP       // PGU
wire [31:0] ep3Bwire;         //$$ [XADC] XADC_VOLT       // PGU
wire [31:0] ep3Cwire = 32'b0; //
wire [31:0] ep3Dwire = 32'b0; //
wire [31:0] ep3Ewire = 32'b0; //
wire [31:0] ep3Fwire = 32'b0; //
//}

// Trigger In 	0x40 - 0x5F //{
wire ep40ck = sys_clk; wire [31:0] ep40trig; //$$ [TEST] TEST_TI             // PGU
wire ep41ck = 1'b0;    wire [31:0] ep41trig;
wire ep42ck = 1'b0;    wire [31:0] ep42trig;
wire ep43ck = sys_clk; wire [31:0] ep43trig; //$$ [TEST] TEST_IO_TI          // PGU
wire ep44ck = sys_clk; wire [31:0] ep44trig; //$$ [DACX] DACX_DAT_TI         // PGU // to remove
wire ep45ck = sys_clk; wire [31:0] ep45trig; //$$ [DACX] DACX_TI             // PGU
wire ep46ck = sys_clk; wire [31:0] ep46trig; //$$ [CLKD] CLKD_TI             // PGU
wire ep47ck = sys_clk; wire [31:0] ep47trig; //$$ [SPIO] SPIO_TI             // PGU
wire ep48ck = sys_clk; wire [31:0] ep48trig; //$$ [DACZ] DACZ_DAT_TI         // PGU
wire ep49ck = 1'b0;    wire [31:0] ep49trig;
wire ep4Ack = 1'b0;    wire [31:0] ep4Atrig;
wire ep4Bck = 1'b0;    wire [31:0] ep4Btrig;
wire ep4Cck = 1'b0;    wire [31:0] ep4Ctrig;
wire ep4Dck = 1'b0;    wire [31:0] ep4Dtrig;
wire ep4Eck = 1'b0;    wire [31:0] ep4Etrig;
wire ep4Fck = 1'b0;    wire [31:0] ep4Ftrig;
wire ep50ck = 1'b0;    wire [31:0] ep50trig;
wire ep51ck = 1'b0;    wire [31:0] ep51trig;
wire ep52ck = 1'b0;    wire [31:0] ep52trig;
wire ep53ck = sys_clk; wire [31:0] ep53trig; //$$ [MEM] MEM_TI
wire ep54ck = 1'b0;    wire [31:0] ep54trig;
wire ep55ck = 1'b0;    wire [31:0] ep55trig;
wire ep56ck = 1'b0;    wire [31:0] ep56trig;
wire ep57ck = 1'b0;    wire [31:0] ep57trig;
wire ep58ck = 1'b0;    wire [31:0] ep58trig;
wire ep59ck = 1'b0;    wire [31:0] ep59trig;
wire ep5Ack = 1'b0;    wire [31:0] ep5Atrig;
wire ep5Bck = 1'b0;    wire [31:0] ep5Btrig;
wire ep5Cck = 1'b0;    wire [31:0] ep5Ctrig;
wire ep5Dck = 1'b0;    wire [31:0] ep5Dtrig;
wire ep5Eck = 1'b0;    wire [31:0] ep5Etrig;
wire ep5Fck = 1'b0;    wire [31:0] ep5Ftrig;
//}

// Trigger Out 	0x60 - 0x7F //{
wire ep60ck = sys_clk; wire [31:0] ep60trig; //$$ [TEST] TEST_TO
wire ep61ck = 1'b0;    wire [31:0] ep61trig = 32'b0;
wire ep62ck = 1'b0;    wire [31:0] ep62trig = 32'b0;
wire ep63ck = 1'b0;    wire [31:0] ep63trig = 32'b0;
wire ep64ck = 1'b0;    wire [31:0] ep64trig = 32'b0;
wire ep65ck = 1'b0;    wire [31:0] ep65trig = 32'b0;
wire ep66ck = 1'b0;    wire [31:0] ep66trig = 32'b0;
wire ep67ck = 1'b0;    wire [31:0] ep67trig = 32'b0;
wire ep68ck = 1'b0;    wire [31:0] ep68trig = 32'b0;
wire ep69ck = 1'b0;    wire [31:0] ep69trig = 32'b0;
wire ep6Ack = 1'b0;    wire [31:0] ep6Atrig = 32'b0;
wire ep6Bck = 1'b0;    wire [31:0] ep6Btrig = 32'b0;
wire ep6Cck = 1'b0;    wire [31:0] ep6Ctrig = 32'b0;
wire ep6Dck = 1'b0;    wire [31:0] ep6Dtrig = 32'b0;
wire ep6Eck = 1'b0;    wire [31:0] ep6Etrig = 32'b0;
wire ep6Fck = 1'b0;    wire [31:0] ep6Ftrig = 32'b0;
wire ep70ck = 1'b0;    wire [31:0] ep70trig = 32'b0;
wire ep71ck = 1'b0;    wire [31:0] ep71trig = 32'b0;
wire ep72ck = 1'b0;    wire [31:0] ep72trig = 32'b0;
wire ep73ck = sys_clk; wire [31:0] ep73trig; //$$ [MEM] MEM_TO
wire ep74ck = 1'b0;    wire [31:0] ep74trig = 32'b0;
wire ep75ck = 1'b0;    wire [31:0] ep75trig = 32'b0;
wire ep76ck = 1'b0;    wire [31:0] ep76trig = 32'b0;
wire ep77ck = 1'b0;    wire [31:0] ep77trig = 32'b0;
wire ep78ck = 1'b0;    wire [31:0] ep78trig = 32'b0;
wire ep79ck = 1'b0;    wire [31:0] ep79trig = 32'b0;
wire ep7Ack = 1'b0;    wire [31:0] ep7Atrig = 32'b0;
wire ep7Bck = 1'b0;    wire [31:0] ep7Btrig = 32'b0;
wire ep7Cck = 1'b0;    wire [31:0] ep7Ctrig = 32'b0;
wire ep7Dck = 1'b0;    wire [31:0] ep7Dtrig = 32'b0;
wire ep7Eck = 1'b0;    wire [31:0] ep7Etrig = 32'b0;
wire ep7Fck = 1'b0;    wire [31:0] ep7Ftrig = 32'b0; 
//}

// Pipe In 		0x80 - 0x9F // clock is assumed to use okClk //{
wire ep80wr; wire [31:0] ep80pipe;
wire ep81wr; wire [31:0] ep81pipe;
wire ep82wr; wire [31:0] ep82pipe;
wire ep83wr; wire [31:0] ep83pipe;
wire ep84wr; wire [31:0] ep84pipe; //$$ [DACX] DAC0_DAT_PI
wire ep85wr; wire [31:0] ep85pipe; //$$ [DACX] DAC1_DAT_PI
wire ep86wr; wire [31:0] ep86pipe; //$$ [DACZ] DAC0_DAT_INC_PI
wire ep87wr; wire [31:0] ep87pipe; //$$ [DACZ] DAC0_DUR_PI 
wire ep88wr; wire [31:0] ep88pipe; //$$ [DACZ] DAC1_DAT_INC_PI
wire ep89wr; wire [31:0] ep89pipe; //$$ [DACZ] DAC1_DUR_PI 
wire ep8Awr; wire [31:0] ep8Apipe;
wire ep8Bwr; wire [31:0] ep8Bpipe;
wire ep8Cwr; wire [31:0] ep8Cpipe;
wire ep8Dwr; wire [31:0] ep8Dpipe;
wire ep8Ewr; wire [31:0] ep8Epipe;
wire ep8Fwr; wire [31:0] ep8Fpipe;
wire ep90wr; wire [31:0] ep90pipe;
wire ep91wr; wire [31:0] ep91pipe;
wire ep92wr; wire [31:0] ep92pipe;
wire ep93wr; wire [31:0] ep93pipe; //$$ [MEM] MEM_PI
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
wire epB3rd; wire [31:0] epB3pipe; //$$ [MEM] MEM_PO
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
wire w_ck_40_1 = sys_clk       ; wire [31:0] w_port_ti_40_1; // PGU
wire w_ck_43_1 = sys_clk       ; wire [31:0] w_port_ti_43_1; // PGU
wire w_ck_44_1 = sys_clk       ; wire [31:0] w_port_ti_44_1; // PGU
wire w_ck_45_1 = sys_clk       ; wire [31:0] w_port_ti_45_1; // PGU
wire w_ck_46_1 = sys_clk       ; wire [31:0] w_port_ti_46_1; // PGU
wire w_ck_47_1 = sys_clk       ; wire [31:0] w_port_ti_47_1; // PGU 
wire w_ck_48_1 = sys_clk       ; wire [31:0] w_port_ti_48_1; // PGU
wire w_ck_53_1 = sys_clk       ; wire [31:0] w_port_ti_53_1; // MEM
//}

// trig out //{
wire w_ck_60_1 = sys_clk       ; wire [31:0] w_port_to_60_1; // PGU
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

wire [47:0] w_adrs_offset_mac_48b; // BASE = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ??48 bits
wire [31:0] w_adrs_offset_ip_32b ; // BASE = {8'd192,8'd168,8'd168,8'd112}; // 192.168.168.112 or C0:A8:A8:70 ??32 bits
wire [15:0] w_offset_lan_timeout_rtr_16b; //$$ = ep00wire[31:16]; // assign later 
wire [15:0] w_offset_lan_timeout_rcr_16b; //$$ = ep00wire[15: 0]; // assign later 

wire  EP_LAN_MOSI ; // rev 20210105
wire  EP_LAN_SCLK ; // rev 20210105
wire  EP_LAN_CS_B ; // rev 20210105
wire  EP_LAN_INT_B; // rev 20210105
wire  EP_LAN_RST_B; // rev 20210105
wire  EP_LAN_MISO ; // rev 20210105

lan_endpoint_wrapper #(
	//.MCS_IO_INST_OFFSET			(32'h_0004_0000), //$$ for CMU2020
	.MCS_IO_INST_OFFSET			(32'h_0005_0000), //$$ for PGU2020
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID)  
) lan_endpoint_wrapper_inst (
	
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
	.ep42ck (1'b0),      .ep42trig (), // input wire, output wire [31:0],
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
	.ep62ck (1'b0),      .ep62trig (32'b0), // input wire, input wire [31:0],
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
		
fifo_generator_4 TEST_fifo_inst (
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



/* TODO: mapping endpoints to signals for PGU-CPU board */ //{

// most control in signals

//// BRD_CON //{
wire [31:0] w_BRD_CON = w_port_wi_03_1 | ep03wire; // board control // logic or
// reset wires 
// endpoint mux enable : LAN(MCS) vs USB

// sub wires 
wire w_HW_reset              = w_BRD_CON[0];
////  wire w_time_stamp_disp_en    = w_BRD_CON[16];

// reset wires 
//wire w_rst_adc      = w_BRD_CON[1]; 
//wire w_rst_dwave    = w_BRD_CON[2]; 
//wire w_rst_bias     = w_BRD_CON[3]; 
//wire w_rst_spo      = w_BRD_CON[4]; 
////  wire w_rst_mcs_ep   = w_BRD_CON[]; 
//// wire reset_sw_mcs1_n; // see ~w_rst_mcs_ep // not used

// endpoint mux enable : LAN(MCS) vs USB
wire w_mcs_ep_po_en = w_BRD_CON[ 8]; 
wire w_mcs_ep_pi_en = w_BRD_CON[ 9]; 
wire w_mcs_ep_to_en = w_BRD_CON[10]; 
wire w_mcs_ep_ti_en = w_BRD_CON[11];  
wire w_mcs_ep_wo_en = w_BRD_CON[12]; 
wire w_mcs_ep_wi_en = w_BRD_CON[13]; 
// mcs endpoint enables
////wire w_mcs_ep_po_en = w_port_wi_10_0[5];
////wire w_mcs_ep_pi_en = w_port_wi_10_0[4];
////wire w_mcs_ep_to_en = w_port_wi_10_0[3];
////wire w_mcs_ep_ti_en = w_port_wi_10_0[2]; 
////wire w_mcs_ep_wo_en = w_port_wi_10_0[1];
////wire w_mcs_ep_wi_en = w_port_wi_10_0[0];

//}

//// MCS_SETUP_WI //{

// MCS control 
wire [31:0] w_MCS_SETUP_WI = w_port_wi_19_1; //$$ dedicated to MCS. updated by MCS boot-up.
// bit[3:0]=slot_id, range of 00~99, set from EEPROM via MCS
// ...
// bit[8]=sel__H_LAN_for_EEPROM_fifo (or USB)
// bit[9]=sel__H_EEPROM_on_TP (or on Base)
// bit[10]=sel__H_LAN_on_BASE_BD (or on module)
// ...
// bit[31:16]=board_id, range of 0000~9999, set from EEPROM via MCS

wire [3:0]  w_slot_id             = w_MCS_SETUP_WI[3:0];   // not yet
wire w_sel__H_LAN_for_EEPROM_fifo = w_MCS_SETUP_WI[8];
wire w_sel__H_EEPROM_on_TP        = w_MCS_SETUP_WI[9];     // not yet
wire w_sel__H_LAN_on_BASE_BD      = w_MCS_SETUP_WI[10];    // not yet
wire [15:0] w_board_id            = w_MCS_SETUP_WI[31:16]; // not yet

// for dedicated LAN setup from MCS
assign w_adrs_offset_mac_48b[15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
assign w_adrs_offset_ip_32b [15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b

//}

//// TEST wires //{


// check IDs end-point //{
wire [31:0] w_SW_BUILD_ID = (w_mcs_ep_wi_en)? w_port_wi_00_1 : ep00wire;
//
wire [31:0] w_FPGA_IMAGE_ID = 
				(w_SW_BUILD_ID==REQ_SW_BUILD_ID)? FPGA_IMAGE_ID : 
				(w_SW_BUILD_ID==32'b0          )? FPGA_IMAGE_ID : 
				32'b0 ;
//
assign ep20wire = (!w_mcs_ep_wo_en)? w_FPGA_IMAGE_ID : 32'hACAC_ACAC;
assign w_port_wo_20_1 = (w_mcs_ep_wo_en)? w_FPGA_IMAGE_ID : 32'hACAC_ACAC;
//}

// timestamp //{
(* keep = "true" *) wire [31:0] w_TIMESTAMP_WO;
assign ep22wire = w_TIMESTAMP_WO;
assign w_port_wo_22_1 = (w_mcs_ep_wo_en)? w_TIMESTAMP_WO : 32'hACAC_ACAC;
//}

// TEST counter end-point //{
wire [31:0] w_TEST_CON = (w_mcs_ep_wi_en)? w_port_wi_01_1 : ep01wire;
//
wire [31:0] w_TEST_OUT;
assign ep21wire = (!w_mcs_ep_wo_en)? w_TEST_OUT : 32'hACAC_ACAC; // TEST_OUT
assign w_port_wo_21_1 = (w_mcs_ep_wo_en)? w_TEST_OUT : 32'hACAC_ACAC;
//
wire [31:0] w_TEST_TI = (w_mcs_ep_ti_en)? w_port_ti_40_1 : ep40trig;
//
wire [31:0] w_TEST_TO;
assign ep60trig = w_TEST_TO; //$$
assign w_port_to_60_1 = (w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000; //$$
//}

// TEST_IO end-point //{
//
//$$wire [31:0] w_TEST_IO_CON = (w_mcs_ep_wi_en)? w_port_wi_03_1 : ep03wire; //$$ not used in PGU // removed
wire [31:0] w_TEST_IO_MON;
assign ep23wire = (!w_mcs_ep_wo_en)? w_TEST_IO_MON : 32'hACAC_ACAC;
assign w_port_wo_23_1 = (w_mcs_ep_wo_en)? w_TEST_IO_MON : 32'hACAC_ACAC;
//
wire [31:0] w_TEST_IO_TI = (w_mcs_ep_ti_en)? w_port_ti_43_1 : ep43trig;
//
assign w_TEST_IO_MON[28:27] =  2'b0;
assign w_TEST_IO_MON[26] = dac1_dco_clk_locked;
assign w_TEST_IO_MON[25] = dac0_dco_clk_locked;
assign w_TEST_IO_MON[24] = clk_dac_locked;
assign w_TEST_IO_MON[23:20] =  4'b0;
assign w_TEST_IO_MON[19] = clk4_locked;
assign w_TEST_IO_MON[18] = clk3_locked;
assign w_TEST_IO_MON[17] = clk2_locked;
assign w_TEST_IO_MON[16] = clk1_locked;
assign w_TEST_IO_MON[15: 0] = 16'b0;
//}


//}

//// SPIO wires //{

// SPIO_WI @ ep07wire = {3'b0,i_CS_id,i_pin_adrs_A[2:0],i_R_W_bar,i_reg_adrs_A,i_wr_DA[7:0],i_wr_DB[7:0]}
// SPIO_WO @ ep27wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset,8'b0,o_rd_DA[7:0],o_rd_DB[7:0]}
// SPIO_TI @ ep47trig

wire [31:0] w_SPIO_WI = (w_mcs_ep_wi_en)? w_port_wi_07_1 : ep07wire; 
//
wire [31:0] w_SPIO_WO; 
assign ep27wire = (!w_mcs_ep_wo_en)? w_SPIO_WO : 32'hACAC_ACAC; 
assign w_port_wo_27_1 = (w_mcs_ep_wo_en)? w_SPIO_WO : 32'hACAC_ACAC;
//
wire [31:0] w_SPIO_TI = (w_mcs_ep_ti_en)? w_port_ti_47_1 : ep47trig;

//}

//// CLKD wires //{

// CLKD_WI @ ep06wire = {i_R_W_bar,2'b0,3'b0,i_reg_adrs_A[9:0],8'b0,i_wr_D[7:0]}
// CLKD_WO @ ep26wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset,8'b0,8'b0,o_rd_D[7:0]}
// CLKD_TI @ ep46trig

(* keep = "true" *) wire [31:0] w_CLKD_WI = (w_mcs_ep_wi_en)? w_port_wi_06_1 : ep06wire;

(* keep = "true" *) wire [31:0] w_CLKD_WO;
assign ep26wire = (!w_mcs_ep_wo_en)? w_CLKD_WO : 32'hACAC_ACAC; 
assign w_port_wo_26_1 = (w_mcs_ep_wo_en)? w_CLKD_WO : 32'hACAC_ACAC;

(* keep = "true" *) wire [31:0] w_CLKD_TI = (w_mcs_ep_ti_en)? w_port_ti_46_1 : ep46trig;

//}

//// DACX wires //{

// control for AD9783

// DACX_WI @ ep05wire = {1'b0,clk_rst[2:0], 3'b0,i_CS_id, i_R_W_bar, i_byte_mode_N, i_reg_adrs_A, 8'b0, i_wr_D}
// DACX_WO @ ep25wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset, 16'b0 , o_rd_D}
// DACX_TI @ ep45trig

wire [31:0] w_DACX_WI = (w_mcs_ep_wi_en)? w_port_wi_05_1 : ep05wire; 
//  bit[30]    = dac1_dco_clk_rst      
//  bit[29]    = dac0_dco_clk_rst      
//  bit[28]    = clk_dac_clk_rst       
//  bit[27]    = dac1_clk_dis          
//  bit[26]    = dac0_clk_dis          
//  bit[24]    = DACx_CS_id            
//  bit[23]    = DACx_R_W_bar          
//  bit[22:21] = DACx_byte_mode_N[1:0] 
//  bit[20:16] = DACx_reg_adrs_A [4:0] 
//  bit[7:0]   = DACx_wr_D[7:0]        

wire [31:0] w_DACX_WO; 
assign ep25wire       = (!w_mcs_ep_wo_en)? w_DACX_WO : 32'hACAC_ACAC; 
assign w_port_wo_25_1 = ( w_mcs_ep_wo_en)? w_DACX_WO : 32'hACAC_ACAC;
//  bit[25]  = done_DACx_SPI_frame
//  bit[24]  = done_DACx_LNG_reset
//  bit[7:0] = DACx_rd_D[7:0]     

wire [31:0] w_DACX_TI = (w_mcs_ep_ti_en)? w_port_ti_45_1 : ep45trig;
//  bit[0] = trig_DACx_LNG_reset 
//  bit[1] = trig_DACx_SPI_frame 


// DACZ_DAT_WI @ ep08wire   //$$ rev .... = {DAC1_DAT[15:0], DAC0_DAT[15:0]}
// DACZ_DAT_WO @ ep28wire
// DACZ_DAT_TI @ ep48trig

wire [31:0] w_DACZ_DAT_WI = (w_mcs_ep_wi_en)? w_port_wi_08_1 : ep08wire; 
//
wire [31:0] w_DACZ_DAT_WO;
assign ep28wire = (!w_mcs_ep_wo_en)? w_DACZ_DAT_WO : 32'hACAC_ACAC; 
assign w_port_wo_28_1 = (w_mcs_ep_wo_en)? w_DACZ_DAT_WO : 32'hACAC_ACAC;
//
wire [31:0] w_DACZ_DAT_TI = (w_mcs_ep_ti_en)? w_port_ti_48_1 : ep48trig;


// DACX_DAT_WI @ ep04wire   //$$ rev .... = {DAC1_DAT[15:0], DAC0_DAT[15:0]}
// DACX_DAT_WO @ ep24wire
// DACX_DAT_TI @ ep44trig

wire [31:0] w_DACX_DAT_WI = (w_mcs_ep_wi_en)? w_port_wi_04_1 : ep04wire; 
//
wire [31:0] w_DACX_DAT_WO;
assign ep24wire = (!w_mcs_ep_wo_en)? w_DACX_DAT_WO : 32'hACAC_ACAC; 
assign w_port_wo_24_1 = (w_mcs_ep_wo_en)? w_DACX_DAT_WO : 32'hACAC_ACAC;
//
wire [31:0] w_DACX_DAT_TI = (w_mcs_ep_ti_en)? w_port_ti_44_1 : ep44trig; // remove


// DAC0_DAT_PI @ ep84pipe // pipe in for DAC0 FIFO 
// DAC1_DAT_PI @ ep85pipe // pipe in for DAC1 FIFO 

wire [31:0] w_DAC0_DAT_PI    = (w_mcs_ep_pi_en)? w_port_pi_84_1 : ep84pipe;
wire        w_DAC0_DAT_PI_WR = (w_mcs_ep_pi_en)? w_wr_84_1 : ep84wr  ;
wire [31:0] w_DAC1_DAT_PI    = (w_mcs_ep_pi_en)? w_port_pi_85_1 : ep85pipe;
wire        w_DAC1_DAT_PI_WR = (w_mcs_ep_pi_en)? w_wr_85_1 : ep85wr  ;


// 'DAC0_DAT_INC_PI'    : 0x86, ##$$ new for DACZ CID style // data b16 + inc b16
// 'DAC0_DUR_PI    '    : 0x87, ##$$ new for DACZ CID style // duration b32
// 'DAC1_DAT_INC_PI'    : 0x88, ##$$ new for DACZ CID style // data b16 + inc b16
// 'DAC1_DUR_PI    '    : 0x89, ##$$ new for DACZ CID style // duration b32

wire [31:0] w_DAC0_DAT_INC_PI    = (w_mcs_ep_pi_en)? w_port_pi_86_1 : ep86pipe;
wire        w_DAC0_DAT_INC_PI_WR = (w_mcs_ep_pi_en)?      w_wr_86_1 : ep86wr  ;
wire [31:0] w_DAC0_DUR_PI        = (w_mcs_ep_pi_en)? w_port_pi_87_1 : ep87pipe;
wire        w_DAC0_DUR_PI_WR     = (w_mcs_ep_pi_en)?      w_wr_87_1 : ep87wr  ;
wire [31:0] w_DAC1_DAT_INC_PI    = (w_mcs_ep_pi_en)? w_port_pi_88_1 : ep88pipe;
wire        w_DAC1_DAT_INC_PI_WR = (w_mcs_ep_pi_en)?      w_wr_88_1 : ep88wr  ;
wire [31:0] w_DAC1_DUR_PI        = (w_mcs_ep_pi_en)? w_port_pi_89_1 : ep89pipe;
wire        w_DAC1_DUR_PI_WR     = (w_mcs_ep_pi_en)?      w_wr_89_1 : ep89wr  ;


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



//-------------------------------------------------------//


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
wire [7:0] w_test;
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
assign reset1     = w_TEST_CON[0]; 
assign disable1   = w_TEST_CON[1]; 
assign autocount2 = w_TEST_CON[2]; 
//
assign w_TEST_OUT[15:0] = {count2[7:0], count1[7:0]}; 
assign w_TEST_OUT[31:16] = 16'b0; 
// Counter 2:
assign reset2     = w_TEST_TI[0];
assign up2        = w_TEST_TI[1];
assign down2      = w_TEST_TI[2];
//
assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};

// LED drive //{
function [7:0] xem7310_led;
input [7:0] a;
integer i;
begin
	for(i=0; i<8; i=i+1) begin: u
		xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
	end
end
endfunction
// 
assign led = xem7310_led(w_test ^ count1);
//}

//}

// test_counter_wrapper //{
test_counter_wrapper  test_counter_wrapper_inst (
	.sys_clk (sys_clk),
	.reset_n (reset_n),
	//
	.o_test    (w_test),
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

wire [31:0] w_XADC_TEMP; 
assign ep3Awire = w_XADC_TEMP; //$$
assign w_port_wo_3A_1 = (w_mcs_ep_wo_en)? w_XADC_TEMP : 32'hACAC_ACAC;
//
wire [31:0] w_XADC_VOLT; 
assign ep3Bwire = w_XADC_VOLT; //$$
assign w_port_wo_3B_1 = (w_mcs_ep_wo_en)? w_XADC_VOLT : 32'hACAC_ACAC;

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
assign w_XADC_TEMP	= MEASURED_TEMP_MC;
//
assign w_XADC_VOLT = 
	(count2[7:6]==2'b00)? MEASURED_VCCINT_MV :
	(count2[7:6]==2'b01)? MEASURED_VCCAUX_MV :
	(count2[7:6]==2'b10)? MEASURED_VCCBRAM_MV :
		32'b0;
//}

//}


/* SPIO : MCP23S17 */ //{

// SPIO ports //{
wire SPIO0_CS   ;
wire SPIO1_CS   ;
wire SPIOx_SCLK ;
wire SPIOx_MOSI ;
wire SPIOx_MISO ;
//
OBUF obuf_SPIO0_CS_inst   (.O(o_B13_L2P         ), .I(SPIO0_CS   ) ); // 
OBUF obuf_SPIOx_SCLK_inst (.O(o_B13_L2N         ), .I(SPIOx_SCLK ) ); // 
OBUF obuf_SPIOx_MOSI_inst (.O(o_B13_L4P         ), .I(SPIOx_MOSI ) ); // 
IBUF ibuf_SPIOx_MISO_inst (.I(i_B13_L4N         ), .O(SPIOx_MISO ) ); //
OBUF obuf_SPIO1_CS_inst   (.O(o_B13_L1P         ), .I(SPIO1_CS   ) ); // 
//}

//end-points for SPIO //{
//
wire w_trig_SPIO_LNG_reset = w_SPIO_TI[0] | w_TEST_IO_TI[0]; // test 
wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1] | w_TEST_IO_TI[1]; // test 
wire w_done_SPIO_LNG_reset ;
wire w_done_SPIO_SPI_frame ;
//
wire       w_SPIO_CS_id      = w_SPIO_WI[28]   ;
wire [2:0] w_SPIO_pin_adrs_A = w_SPIO_WI[27:25];
wire       w_SPIO_R_W_bar    = w_SPIO_WI[24]   ;
wire [7:0] w_SPIO_reg_adrs_A = w_SPIO_WI[23:16];
wire [7:0] w_SPIO_wr_DA      = w_SPIO_WI[15: 8];
wire [7:0] w_SPIO_wr_DB      = w_SPIO_WI[ 7: 0];
//
wire [7:0] w_SPIO_rd_DA      ;
wire [7:0] w_SPIO_rd_DB      ;
//
assign w_SPIO_WO[31:26] = 6'b0;
assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
assign w_SPIO_WO[24] = w_done_SPIO_LNG_reset;
assign w_SPIO_WO[23:16] = 8'b0;
assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
//}

// master_spi_mcp23s17 //{
master_spi_mcp23s17  master_spi_mcp23s17_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_SPIO_LNG_reset),
	.o_done_LNG_reset	(w_done_SPIO_LNG_reset), 
	.o_LNG_RSTn			(),
	.i_trig_SPI_frame	(w_trig_SPIO_SPI_frame), 
	.o_done_SPI_frame	(w_done_SPIO_SPI_frame), 
	//
	.o_SPIO0_CS   		(SPIO0_CS  ),
	.o_SPIO1_CS   		(SPIO1_CS  ),
	.o_SPIOx_SCLK 		(SPIOx_SCLK),
	.o_SPIOx_MOSI 		(SPIOx_MOSI),
	.i_SPIOx_MISO 		(SPIOx_MISO),
	//
	.i_CS_id            (w_SPIO_CS_id     ), //       
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

// LED test with USER_LED_ST0 net (SP1_GPB3)
//   IODIR frame 0x40_00_FF_F7 : w_SPIO_WI = 32'h10_00_FF_F7
//   GPIO  frame 0x40_12_00_08 : w_SPIO_WI = 32'h10_12_00_08
//   GPIO  frame 0x40_12_00_00 : w_SPIO_WI = 32'h10_12_00_00

//}

//}


/* CLKD : AD9516-1 */ //{

// CLKD ports //{
wire CLKD_REFM;
IBUF ibuf_CLKD_REFM_inst (.I(i_B35_L15N         ), .O(CLKD_REFM ) ); //
//
wire   CLKD_COUT;
wire c_CLKD_COUT;
IBUFDS ibufds_CLKD_COUT_inst (.I(c_B13D_L13P_MRCC), .IB(c_B13D_L13N_MRCC), .O(c_CLKD_COUT) );
BUFG     bufg_CLKD_COUT_inst (.I(c_CLKD_COUT), .O(CLKD_COUT) ); //$$ use BUFG
//$$assign CLKD_COUT = c_CLKD_COUT; //$$ remove BUFG 
//
assign clk_dac_clk_in = CLKD_COUT; // for DAC/CLK 400MHz pll
//
wire CLKD_RST_B;
wire CLKD_LD;
wire CLKD_STAT ;
wire CLKD_SYNC = 1'b0; // reserved
OBUF obuf_CLKD_RST_B_inst (.O(o_B35_IO0         ), .I(CLKD_RST_B  ) ); // 
IBUF ibuf_CLKD_LD_inst    (.I(i_B35_IO25        ), .O(CLKD_LD     ) ); //
IBUF ibuf_CLKD_STAT_inst  (.I(i_B35_L15P        ), .O(CLKD_STAT   ) ); //
OBUF obuf_CLKD_SYNC_inst  (.O(o_B13_SYS_CLK_MC2 ), .I(CLKD_SYNC   ) ); // 
//
wire CLKD_SCLK    ;
wire CLKD_CS_B    ;
wire CLKD_SDO     ; // reserved for 4-wire SPI
wire CLKD_SDIO    ; // open-drain for AD9516-1
wire CLKD_SDIO_rd ;
//
OBUF  obuf_CLKD_SCLK_inst (.O(o_B35_L4P ), .I(CLKD_SCLK ) ); // 
OBUF  obuf_CLKD_CS_B_inst (.O(o_B35_L4N ), .I(CLKD_CS_B ) ); // 
IBUF  ibuf_CLKD_SDO__inst (.I(i_B35_L6P ), .O(CLKD_SDO  ) ); //
//OBUF  obuf_CLKD_SDIO_inst (.O(o_B35_L6N ), .I(CLKD_SDIO ) ); // 
IOBUF iobuf_CLKD_SDIO_inst(.IO(io_B35_L6N  ), .T(CLKD_SDIO), .I(CLKD_SDIO ), .O(CLKD_SDIO_rd ) ); //
//}

//end-points for CLKD //{
//
wire w_trig_CLKD_LNG_reset = w_CLKD_TI[0] | w_TEST_IO_TI[2]; // test 
wire w_trig_CLKD_SPI_frame = w_CLKD_TI[1] | w_TEST_IO_TI[3]; // test 
wire w_done_CLKD_LNG_reset ;
wire w_done_CLKD_SPI_frame ;
//
wire        w_CLKD_R_W_bar     = w_CLKD_WI[31];
wire  [1:0] w_CLKD_byte_mode_W = w_CLKD_WI[30:29];
wire  [9:0] w_CLKD_reg_adrs_A  = w_CLKD_WI[25:16];
wire  [7:0] w_CLKD_wr_D        = w_CLKD_WI[7:0];
//
wire  [7:0] w_CLKD_rd_D       ;
//
assign w_CLKD_WO[31]    = CLKD_LD   ;
assign w_CLKD_WO[30]    = CLKD_STAT ;
assign w_CLKD_WO[29]    = CLKD_REFM ;
//assign w_CLKD_WO[28]    = CLKD_SDO  ;
assign w_CLKD_WO[28]    = CLKD_SDIO_rd  ;
assign w_CLKD_WO[27:26] = 2'b0;
assign w_CLKD_WO[25]    = w_done_CLKD_SPI_frame;
assign w_CLKD_WO[24]    = w_done_CLKD_LNG_reset;
assign w_CLKD_WO[23:8]  = 16'b0;
assign w_CLKD_WO[7:0]   = w_CLKD_rd_D;
//}

// master_spi_ad9516 //{
master_spi_ad9516#(
	.TIME_RESET_WAIT_MS (5) // for 5ms reset 
)   master_spi_ad9516_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_CLKD_LNG_reset),
	.o_done_LNG_reset	(w_done_CLKD_LNG_reset), 
	.o_LNG_RSTn			(CLKD_RST_B),
	.i_trig_SPI_frame	(w_trig_CLKD_SPI_frame), 
	.o_done_SPI_frame	(w_done_CLKD_SPI_frame), 
	//
	.o_CLK_CS_B   		(CLKD_CS_B),
	.o_CLK_SCLK 		(CLKD_SCLK),
	.o_CLK_SDIO 		(CLKD_SDIO),
	//.i_CLK_SDO 			(CLKD_SDIO_rd),
	.i_CLK_SDO 			(CLKD_SDO),
	//
	.i_R_W_bar          (w_CLKD_R_W_bar    ), //     
	.i_byte_mode_W      (w_CLKD_byte_mode_W), // [1:0]
	.i_reg_adrs_A       (w_CLKD_reg_adrs_A ), // [9:0] 
	.i_wr_D             (w_CLKD_wr_D       ), // [7:0] 
	.o_rd_D             (w_CLKD_rd_D       ), // [7:0] 
	//
	.valid				()		
);
//}

//}


/* TRIG */ //{

// TRIG IN port //{
wire   TRIG_IN;
IBUFDS ibufds_TRIG_IN_inst  (.I(i_B13D_L14P_SRCC), .IB(i_B13D_L14N_SRCC), .O(TRIG_IN) );
//}

// TRIG OUT port //{
//wire   TRIG_OUT = w_oddr_out; // test assignment
//wire   TRIG_OUT = 1'b0;
//OBUFDS obufds_TRIG_OUT_inst (.O(o_B13D_L15P), .OB(o_B13D_L15N), .I(TRIG_OUT)	); // LVDS_25
wire TRIG_OUT_P = w_trig_p_oddr_out;
wire TRIG_OUT_N = w_trig_n_oddr_out;
OBUF obuf_TRIG_OUT_P_inst (.O(o_B13_L15P       ), .I( TRIG_OUT_P ) );  // LVCMOS25
OBUF obuf_TRIG_OUT_N_inst (.O(o_B13_L15N       ), .I( TRIG_OUT_N ) );  // LVCMOS25
//}

//}


/* DAC : AD9783 */ //{

// ports //{
(* keep = "true" *) wire [15:0] DAC0_DAT;// = 16'b0; // test
wire        DAC0_DCI = w_dac0_dci_oddr_out; // dac0_dco_clk_out1_400M; // 1'b0;
//
OBUFDS obufds_DAC0_DAT15_inst 	(.O(o_B34D_L15P     ), .OB(o_B34D_L15N     ), .I(~DAC0_DAT[15])	); // PN swap
OBUFDS obufds_DAC0_DAT14_inst 	(.O(o_B34D_L23P     ), .OB(o_B34D_L23N     ), .I(~DAC0_DAT[14])	); // PN swap
OBUFDS obufds_DAC0_DAT13_inst 	(.O(o_B34D_L19P     ), .OB(o_B34D_L19N     ), .I(~DAC0_DAT[13])	); // PN swap
OBUFDS obufds_DAC0_DAT12_inst 	(.O(o_B34D_L21P     ), .OB(o_B34D_L21N     ), .I(~DAC0_DAT[12])	); // PN swap
OBUFDS obufds_DAC0_DAT11_inst 	(.O(o_B34D_L13P_MRCC), .OB(o_B34D_L13N_MRCC), .I( DAC0_DAT[11])	);
OBUFDS obufds_DAC0_DAT10_inst 	(.O(o_B34D_L16P     ), .OB(o_B34D_L16N     ), .I(~DAC0_DAT[10])	); // PN swap
OBUFDS obufds_DAC0_DAT9__inst 	(.O(o_B34D_L17P     ), .OB(o_B34D_L17N     ), .I(~DAC0_DAT[9 ])	); // PN swap //$$
OBUFDS obufds_DAC0_DAT8__inst 	(.O(o_B34D_L24P     ), .OB(o_B34D_L24N     ), .I(~DAC0_DAT[8 ])	); // PN swap //$$
OBUFDS obufds_DAC0_DAT7__inst 	(.O(o_B34D_L20P     ), .OB(o_B34D_L20N     ), .I( DAC0_DAT[7 ])	);
OBUFDS obufds_DAC0_DAT6__inst 	(.O(o_B34D_L3P      ), .OB(o_B34D_L3N      ), .I( DAC0_DAT[6 ])	);
OBUFDS obufds_DAC0_DAT5__inst 	(.O(o_B34D_L9P      ), .OB(o_B34D_L9N      ), .I( DAC0_DAT[5 ])	);
OBUFDS obufds_DAC0_DAT4__inst 	(.O(o_B34D_L2P      ), .OB(o_B34D_L2N      ), .I( DAC0_DAT[4 ])	);
OBUFDS obufds_DAC0_DAT3__inst 	(.O(o_B34D_L4P      ), .OB(o_B34D_L4N      ), .I( DAC0_DAT[3 ])	);
OBUFDS obufds_DAC0_DAT2__inst 	(.O(o_B34D_L1P      ), .OB(o_B34D_L1N      ), .I( DAC0_DAT[2 ])	);
OBUFDS obufds_DAC0_DAT1__inst 	(.O(o_B34D_L7P      ), .OB(o_B34D_L7N      ), .I( DAC0_DAT[1 ])	);
OBUFDS obufds_DAC0_DAT0__inst 	(.O(o_B34D_L12P_MRCC), .OB(o_B34D_L12N_MRCC), .I( DAC0_DAT[0 ])	);
//
OBUFDS obufds_DAC0_DCI_inst 	(.O(o_B34D_L10P),      .OB(o_B34D_L10N),      .I(DAC0_DCI)	); //
//
wire DAC0_DCO;
wire c_DAC0_DCO;
IBUFDS ibufds_DAC0_DCO_inst (.I(c_B34D_L14P_SRCC), .IB(c_B34D_L14N_SRCC), .O(c_DAC0_DCO) );
BUFG     bufg_DAC0_DCO_inst (.I(c_DAC0_DCO), .O(DAC0_DCO) ); 
//
//assign dac0_dco_clk_in = DAC0_DCO; // for DAC1 400MHz pll
//

(* keep = "true" *) wire [15:0] DAC1_DAT;// = 16'b0;
wire        DAC1_DCI = w_dac1_dci_oddr_out; // dac1_dco_clk_out1_400M; // 1'b0;
//
OBUFDS obufds_DAC1_DAT15_inst 	(.O(o_B35D_L12P_MRCC), .OB(o_B35D_L12N_MRCC), .I(~DAC1_DAT[15])	); // PN swap
OBUFDS obufds_DAC1_DAT14_inst 	(.O(o_B35D_L13P_MRCC), .OB(o_B35D_L13N_MRCC), .I(~DAC1_DAT[14])	); // PN swap
OBUFDS obufds_DAC1_DAT13_inst 	(.O(o_B35D_L1P      ), .OB(o_B35D_L1N      ), .I(~DAC1_DAT[13])	); // PN swap
OBUFDS obufds_DAC1_DAT12_inst 	(.O(o_B35D_L2P      ), .OB(o_B35D_L2N      ), .I(~DAC1_DAT[12])	); // PN swap
OBUFDS obufds_DAC1_DAT11_inst 	(.O(o_B35D_L3P      ), .OB(o_B35D_L3N      ), .I(~DAC1_DAT[11])	); // PN swap
OBUFDS obufds_DAC1_DAT10_inst 	(.O(o_B35D_L5P      ), .OB(o_B35D_L5N      ), .I(~DAC1_DAT[10])	); // PN swap
OBUFDS obufds_DAC1_DAT9__inst 	(.O(o_B35D_L8P      ), .OB(o_B35D_L8N      ), .I(~DAC1_DAT[9 ])	); // PN swap
OBUFDS obufds_DAC1_DAT8__inst 	(.O(o_B35D_L10P     ), .OB(o_B35D_L10N     ), .I(~DAC1_DAT[8 ])	); // PN swap
OBUFDS obufds_DAC1_DAT7__inst 	(.O(o_B35D_L24P     ), .OB(o_B35D_L24N     ), .I( DAC1_DAT[7 ])	); 
OBUFDS obufds_DAC1_DAT6__inst 	(.O(o_B35D_L22P     ), .OB(o_B35D_L22N     ), .I( DAC1_DAT[6 ])	); 
OBUFDS obufds_DAC1_DAT5__inst 	(.O(o_B35D_L20P     ), .OB(o_B35D_L20N     ), .I( DAC1_DAT[5 ])	); 
OBUFDS obufds_DAC1_DAT4__inst 	(.O(o_B35D_L16P     ), .OB(o_B35D_L16N     ), .I( DAC1_DAT[4 ])	); 
OBUFDS obufds_DAC1_DAT3__inst 	(.O(o_B35D_L21P     ), .OB(o_B35D_L21N     ), .I( DAC1_DAT[3 ])	); 
OBUFDS obufds_DAC1_DAT2__inst 	(.O(o_B35D_L19P     ), .OB(o_B35D_L19N     ), .I( DAC1_DAT[2 ])	); 
OBUFDS obufds_DAC1_DAT1__inst 	(.O(o_B35D_L18P     ), .OB(o_B35D_L18N     ), .I( DAC1_DAT[1 ])	); 
OBUFDS obufds_DAC1_DAT0__inst 	(.O(o_B35D_L23P     ), .OB(o_B35D_L23N     ), .I( DAC1_DAT[0 ])	); 
//
OBUFDS obufds_DAC1_DCI_inst 	(.O(o_B35D_L17P     ), .OB(o_B35D_L17N     ), .I(DAC1_DCI  )	); // PN swap in PLL
//
wire DAC1_DCO;
wire c_DAC1_DCO;
IBUFDS ibufds_DAC1_DCO_inst (.I(c_B35D_L14P_SRCC), .IB(c_B35D_L14N_SRCC), .O(c_DAC1_DCO) );
//BUFG     bufg_DAC1_DCO_inst (.I(~c_DAC1_DCO), .O(DAC1_DCO) ); // PN swap
BUFG     bufg_DAC1_DCO_inst (.I(c_DAC1_DCO), .O(DAC1_DCO) ); // PN swap in PLL 180 degree
//
//assign dac1_dco_clk_in = DAC1_DCO; // for DAC1 400MHz pll

wire DACx_RST_B; // = 1'b0;
OBUF obuf_DACx_RST_B_inst (.O(o_B13_SYS_CLK_MC1 ), .I(DACx_RST_B ) ); // 
//
wire DAC0_CS    ;//= 1'b0;
wire DAC1_CS    ;//= 1'b0;
wire DACx_SCLK  ;//= 1'b0;
wire DACx_SDIO  ;//= 1'b0;
wire DACx_SDO   ;
//
OBUF obuf_DAC0_CS_inst   (.O(o_B13_L16P        ), .I(DAC0_CS    ) ); // 
OBUF obuf_DAC1_CS_inst   (.O(o_B13_L5P         ), .I(DAC1_CS    ) ); // 
OBUF obuf_DACx_SCLK_inst (.O(o_B13_L5N         ), .I(DACx_SCLK  ) ); // 
OBUF obuf_DACx_SDIO_inst (.O(o_B13_L3P         ), .I(DACx_SDIO  ) ); // 
IBUF ibuf_DACx_SDO_inst  (.I(i_B13_L3N         ), .O(DACx_SDO   ) ); //
//}

// end-points for DACX //{
//
wire w_trig_DACx_LNG_reset = w_DACX_TI[0];
wire w_trig_DACx_SPI_frame = w_DACX_TI[1];
wire w_done_DACx_LNG_reset;
wire w_done_DACx_SPI_frame;
//
assign dac1_dco_clk_rst = w_DACX_WI[30];
assign dac0_dco_clk_rst = w_DACX_WI[29];
assign  clk_dac_clk_rst = w_DACX_WI[28];
//
assign dac1_clk_dis     = w_DACX_WI[27];
assign dac0_clk_dis     = w_DACX_WI[26];
//
wire       w_DACx_CS_id       = w_DACX_WI[24];
wire       w_DACx_R_W_bar     = w_DACX_WI[23];
wire [1:0] w_DACx_byte_mode_N = w_DACX_WI[22:21];
wire [4:0] w_DACx_reg_adrs_A  = w_DACX_WI[20:16];
wire [7:0] w_DACx_wr_D        = w_DACX_WI[7:0];
wire [7:0] w_DACx_rd_D      ;
//
//$$assign w_DACX_WO[31:26] = 6'b0; // assigned from pattern gen
assign w_DACX_WO[25]    = w_done_DACx_SPI_frame;
assign w_DACX_WO[24]    = w_done_DACx_LNG_reset;
assign w_DACX_WO[23:16] = 8'b0;
assign w_DACX_WO[15:8]  = 8'b0;
assign w_DACX_WO[ 7:0]  = w_DACx_rd_D;
//}

// master_spi_ad9783 //{
master_spi_ad9783  master_spi_ad9783_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_DACx_LNG_reset),
	.o_done_LNG_reset	(w_done_DACx_LNG_reset), 
	.o_LNG_RSTn			(DACx_RST_B),
	.i_trig_SPI_frame	(w_trig_DACx_SPI_frame), 
	.o_done_SPI_frame	(w_done_DACx_SPI_frame), 
	//
	.o_DAC0_CS   		(DAC0_CS  ),
	.o_DAC1_CS   		(DAC1_CS  ),
	.o_DACx_SCLK 		(DACx_SCLK),
	.o_DACx_SDIO 		(DACx_SDIO),
	.i_DACx_SDO  		(DACx_SDO),
	//
	.i_CS_id            (w_DACx_CS_id      ), //       
	.i_R_W_bar          (w_DACx_R_W_bar    ), //       
	.i_byte_mode_N      (w_DACx_byte_mode_N), // [1:0] 
	.i_reg_adrs_A       (w_DACx_reg_adrs_A ), // [4:0] 
	.i_wr_D             (w_DACx_wr_D       ), // [7:0] 
	.o_rd_D             (w_DACx_rd_D       ), // [7:0] 
	//
	.valid				()		
);
//}

//}


/* TODO: DAC pattern generator */ //{

// end-points for DACx_DAT_xx and DACX_WO //{

// end-points for FIFO control

// for DACZ
wire [31:0] w_trig_dacz_ctrl     = w_DACZ_DAT_TI;
wire [31:0] w_wire_in__dacz_data = w_DACZ_DAT_WI;
wire [31:0] w_wire_out_dacz_data;
assign w_DACZ_DAT_WO = w_wire_out_dacz_data;

wire [31:0] w_trig_dacx_ctrl     = w_DACX_DAT_TI; // to remove
wire [31:0] w_wire_in__dacx_data = w_DACX_DAT_WI; // to remove
wire [31:0] w_wire_out_dacx_data = 32'b0;         // to remove
assign w_DACX_DAT_WO = w_wire_out_dacx_data;      // to remove

// note clock mux
// BUFGMUX in https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf

wire c_fifo_wr;

// wire w_DAC0_DAT_PI_CK = c_fifo_wr; // remove
// wire w_DAC1_DAT_PI_CK = c_fifo_wr; // remove

wire w_DAC0_DAT_INC_PI_CK = c_fifo_wr;
wire w_DAC0_DUR_PI_CK = c_fifo_wr;
wire w_DAC1_DAT_INC_PI_CK = c_fifo_wr;
wire w_DAC1_DUR_PI_CK = c_fifo_wr;

BUFGMUX bufgmux_c_fifo_read_inst (
	.O(c_fifo_wr), 
	.I0(okClk), 
	.I1(mcs_clk), //$$ mcs_clk vs clk3_out1_72M
	.S(w_mcs_ep_pi_en) 
); 
//


// for DACZ
wire         w_dac0_fifo_datinc_wr_ck  = w_DAC0_DAT_INC_PI_CK; //    
wire         w_dac0_fifo_datinc_wr_en  = w_DAC0_DAT_INC_PI_WR; // 
wire [31:0]  w_dac0_fifo_datinc_din    = w_DAC0_DAT_INC_PI; // 
wire         w_dac0_fifo_dur____wr_ck  = w_DAC0_DUR_PI_CK    ; //    
wire         w_dac0_fifo_dur____wr_en  = w_DAC0_DUR_PI_WR    ; // 
wire [31:0]  w_dac0_fifo_dur____din    = w_DAC0_DUR_PI; // 
wire         w_dac1_fifo_datinc_wr_ck  = w_DAC1_DAT_INC_PI_CK; //    
wire         w_dac1_fifo_datinc_wr_en  = w_DAC1_DAT_INC_PI_WR; // 
wire [31:0]  w_dac1_fifo_datinc_din    = w_DAC1_DAT_INC_PI; // 
wire         w_dac1_fifo_dur____wr_ck  = w_DAC1_DUR_PI_CK    ; //    
wire         w_dac1_fifo_dur____wr_en  = w_DAC1_DUR_PI_WR    ; // 
wire [31:0]  w_dac1_fifo_dur____din    = w_DAC1_DUR_PI       ; // 


//  // DAT_PI // remove
//  wire [31:0] w_dac0_fifo_din        = w_DAC0_DAT_PI   ;
//  wire        w_dac0_fifo_wr_en      = w_DAC0_DAT_PI_WR;
//  wire        w_dac0_fifo_wr_clk     = w_DAC0_DAT_PI_CK;
//  wire [31:0] w_dac1_fifo_din        = w_DAC1_DAT_PI   ;
//  wire        w_dac1_fifo_wr_en      = w_DAC1_DAT_PI_WR;
//  wire        w_dac1_fifo_wr_clk     = w_DAC1_DAT_PI_CK;

//  // DACX_WO //$$ new assign  // remove
//  wire        w_fifo_dac0_full ;
//  wire        w_fifo_dac0_wrack;
//  wire        w_fifo_dac0_empty;
//  wire        w_fifo_dac0_valid; // not used
//  wire        w_fifo_dac1_full ;
//  wire        w_fifo_dac1_wrack;
//  wire        w_fifo_dac1_empty;
//  wire        w_fifo_dac1_valid; // not used

// not used
assign w_DACX_WO[31] = 1'b0; // w_fifo_dac1_empty; 
assign w_DACX_WO[30] = 1'b0; // w_fifo_dac0_empty; 
assign w_DACX_WO[29] = 1'b0; // w_fifo_dac1_full ;
assign w_DACX_WO[28] = 1'b0; // w_fifo_dac0_full ; 
assign w_DACX_WO[27] = 1'b0; // w_fifo_dac1_wrack; 
assign w_DACX_WO[26] = 1'b0; // w_fifo_dac0_wrack;

//}

// wires //{

//wire dacx_ref_clk     = clk_dac_out1_400M;
//wire dacx_ref_reset_n = clk_dac_locked;

wire dac0_reset_n = dac0_dco_clk_locked;
wire dac1_reset_n = dac1_dco_clk_locked;
//
wire [15:0] w_dac0_data_pin;
wire [15:0] w_dac1_data_pin;
assign DAC0_DAT = w_dac0_data_pin;
assign DAC1_DAT = w_dac1_data_pin;

//wire       w_dac0_active_dco;
//wire       w_dac1_active_dco;
//wire       w_dac0_active_clk;
//wire       w_dac1_active_clk;

//}

// dac_pattern_gen_wrapper --> dac_pattern_gen_wrapper__dsp //{

dac_pattern_gen_wrapper__dsp  dac_pattern_gen_wrapper__inst (

	// clock / reset
	.clk                (sys_clk), // 
	.reset_n            (reset_n),
	
	// DAC clock / reset
	.i_clk_dac0_dco     (dac0_clk    ), // clk_400M vs clk_200M
	.i_rstn_dac0_dco    (dac0_reset_n), //
	.i_clk_dac1_dco     (dac1_clk    ), // clk_400M vs clk_200M
	.i_rstn_dac1_dco    (dac1_reset_n), //
	
	// DACZ control port // new control 
	.i_trig_dacz_ctrl   (w_trig_dacz_ctrl    ), // [31:0]
	.i_wire_dacz_data   (w_wire_in__dacz_data), // [31:0]
	.o_wire_dacz_data   (w_wire_out_dacz_data), // [31:0]
	
	// DACZ fifo port // new control // from MCS or USB
	.i_dac0_fifo_datinc_wr_ck    (w_dac0_fifo_datinc_wr_ck ), //       
	.i_dac0_fifo_datinc_wr_en    (w_dac0_fifo_datinc_wr_en ), //       
	.i_dac0_fifo_datinc_din      (w_dac0_fifo_datinc_din   ), // [31:0]
	.i_dac0_fifo_dur____wr_ck    (w_dac0_fifo_dur____wr_ck ), //       
	.i_dac0_fifo_dur____wr_en    (w_dac0_fifo_dur____wr_en ), //       
	.i_dac0_fifo_dur____din      (w_dac0_fifo_dur____din   ), // [31:0]
	.i_dac1_fifo_datinc_wr_ck    (w_dac1_fifo_datinc_wr_ck ), //       
	.i_dac1_fifo_datinc_wr_en    (w_dac1_fifo_datinc_wr_en ), //       
	.i_dac1_fifo_datinc_din      (w_dac1_fifo_datinc_din   ), // [31:0]
	.i_dac1_fifo_dur____wr_ck    (w_dac1_fifo_dur____wr_ck ), //       
	.i_dac1_fifo_dur____wr_en    (w_dac1_fifo_dur____wr_en ), //       
	.i_dac1_fifo_dur____din      (w_dac1_fifo_dur____din   ), // [31:0]
	//
	.i_dac0_fifo_dd_rd_en_test   (1'b0), //
	.i_dac1_fifo_dd_rd_en_test   (1'b0), //
	
	// DAC data output port 
	.o_dac0_data_pin    (w_dac0_data_pin), // [15:0]
	.o_dac1_data_pin    (w_dac1_data_pin), // [15:0]

	// DAC activity flag
	.o_dac0_active_dco  (), // unused
	.o_dac1_active_dco  (), // unused
	.o_dac0_active_clk  (), // alternatively read from o_wire_dacx_data
	.o_dac1_active_clk  (), // alternatively read from o_wire_dacx_data
	
	//  // fifo data and control   // remove
	//  .i_dac0_fifo_wr_clk     (w_dac0_fifo_wr_clk), //
	//  .i_dac0_fifo_wr_en      (w_dac0_fifo_wr_en ), //
	//  .i_dac0_fifo_din        (w_dac0_fifo_din   ), // [31:0]
	//  .i_dac1_fifo_wr_clk     (w_dac1_fifo_wr_clk), //
	//  .i_dac1_fifo_wr_en      (w_dac1_fifo_wr_en ), //
	//  .i_dac1_fifo_din        (w_dac1_fifo_din   ), // [31:0]
	//  //
	//  .i_dac0_fifo_rd_en_test (1'b0), // test read out
	//  .i_dac1_fifo_rd_en_test (1'b0), // test read out
	//  
	//  // FIFO flag 
	//  .o_fifo_dac0_full   (w_fifo_dac0_full ),
	//  .o_fifo_dac0_wrack  (w_fifo_dac0_wrack),
	//  .o_fifo_dac0_empty  (w_fifo_dac0_empty),
	//  .o_fifo_dac0_valid  (w_fifo_dac0_valid),
	//  .o_fifo_dac1_full   (w_fifo_dac1_full ),
	//  .o_fifo_dac1_wrack  (w_fifo_dac1_wrack),
	//  .o_fifo_dac1_empty  (w_fifo_dac1_empty),
	//  .o_fifo_dac1_valid  (w_fifo_dac1_valid),
	
	// flag
	.valid              ()

);

//}


//}


/* S_IO */ //{

// S_IO port //{
//wire   S_IO_0;
//wire w_S_IO_0_wr = 1'b1;
wire   S_IO_1;
wire w_S_IO_1_wr = 1'b1; //$$ not activated
wire   S_IO_2;
wire w_S_IO_2_wr = 1'b1; //$$ not activated

// previous port 
//IBUF ibuf_S_IO_0_inst  (.I(io_B34_L5N  ), .O(S_IO_0 ) ); //
//IBUF ibuf_S_IO_1_inst  (.I(io_B13_L16N ), .O(S_IO_1 ) ); //
//IBUF ibuf_S_IO_2_inst  (.I(io_B13_L1N  ), .O(S_IO_2 ) ); //

//IOBUF iobuf_S_IO_0_inst  (.IO(io_B34_L5N  ), .T(w_S_IO_0_wr), .I(w_S_IO_0_wr ), .O(S_IO_0 ) ); //
IOBUF iobuf_S_IO_1_inst  (.IO(io_B13_L16N ), .T(w_S_IO_1_wr), .I(w_S_IO_1_wr ), .O(S_IO_1 ) ); //
IOBUF iobuf_S_IO_2_inst  (.IO(io_B13_L1N  ), .T(w_S_IO_2_wr), .I(w_S_IO_2_wr ), .O(S_IO_2 ) ); //
//}

// assign //{
assign w_TEST_IO_MON[31] = S_IO_2; //
assign w_TEST_IO_MON[30] = S_IO_1; //
//assign w_TEST_IO_MON[29] = S_IO_0; //
//}

//}


/* ADC */ //{

//$$ not activated

// ADC ports //{
wire   ADC0_DCO;
wire c_ADC0_DCO;
IBUFDS ibufds_ADC0_DCO_inst (.I(c_B34D_L11P_SRCC), .IB(c_B34D_L11N_SRCC), .O(c_ADC0_DCO) );
BUFG     bufg_ADC0_DCO_inst (.I(c_ADC0_DCO), .O(ADC0_DCO) ); 
//
wire ADC0_DA;
wire ADC0_DB;
IBUFDS ibufds_ADC0_DA_inst (.I(i_B34D_L18P), .IB(i_B34D_L18N), .O(ADC0_DA) );
IBUFDS ibufds_ADC0_DB_inst (.I(i_B34D_L22P), .IB(i_B34D_L22N), .O(ADC0_DB) );
//
wire ADCx_CNV   = 1'b0;
wire ADCx_CLK   = 1'b0;
OBUFDS obufds_ADCx_CNV_inst 	(.O(o_B34D_L6P), .OB(o_B34D_L6N), .I(ADCx_CNV)	); //
OBUFDS obufds_ADCx_CLK_inst 	(.O(o_B34D_L8P), .OB(o_B34D_L8N), .I(ADCx_CLK)	); //
wire ADCx_TPT_B = 1'b0;
OBUF obuf_ADCx_TPT_B_inst   (.O(o_B34_L5P         ), .I(ADCx_TPT_B   ) ); // 
//
wire   ADC1_DCO;
wire c_ADC1_DCO;
IBUFDS ibufds_ADC1_DCO_inst (.I(c_B35D_L11P_SRCC), .IB(c_B35D_L11N_SRCC), .O(c_ADC1_DCO) );
BUFG     bufg_ADC1_DCO_inst (.I(c_ADC1_DCO), .O(ADC1_DCO) ); 
//
wire ADC1_DA;
wire ADC1_DB;
IBUFDS ibufds_ADC1_DA_inst (.I(i_B35D_L7P ), .IB(i_B35D_L7N ), .O(ADC1_DA) );
IBUFDS ibufds_ADC1_DB_inst (.I(i_B35D_L9P ), .IB(i_B35D_L9N ), .O(ADC1_DB) );
//}

//}


/* TODO: EEPROM */ //{
// support 11AA160T-I/TT U59 // same in CMU
// io signal, open-drain
// note that 10K ohm pull up is located on board.
// net in sch: S_IO_0
// pin: io_B34_L5N


// ports //{
// share with S_IO 
// high-Z control style ports 
wire  MEM_SIO_out; //  = 1'b1;
wire  MEM_SIO_tri; //  = 1'b1; // enable high-Z
wire  MEM_SIO_in;

IOBUF iobuf_MEM_SIO_inst  (.IO(io_B34_L5N  ), .T(MEM_SIO_tri), .I(MEM_SIO_out ), .O(MEM_SIO_in ) ); //



//}

// fifo read clock //{
wire c_eeprom_fifo_clk; // clock mux between lan and usb/slave-spi end-points
//
BUFGMUX bufgmux_c_eeprom_fifo_clk_inst (
	.O(c_eeprom_fifo_clk), 
	//.I0(base_sspi_clk), // base_sspi_clk for slave_spi_mth_brd // 104MHz
	.I0(okClk        ), // USB  // 100.8MHz
	//.I1(w_ck_pipe    ), // LAN from lan_endpoint_wrapper_inst      // 72MHz
	.I1(mcs_eeprom_fifo_clk), 
	.S(w_sel__H_LAN_for_EEPROM_fifo) 
);

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

// assignment //{

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


//// port mux
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


// no TP yet
assign w_SCIO_DI   = MEM_SIO_in ; 
assign MEM_SIO_out =  w_SCIO_DO ; // dedicated port
assign MEM_SIO_tri = ~w_SCIO_OE ; // dedicated port

//}


//}


/* TODO: TEMP SENSOR */
// to come

/* TODO: TP for TXEM7310 */
// to come


///TODO: //-------------------------------------------------------//

/* TODO: okHost : ok_endpoint_wrapper */ //{
//$$ Endpoints
// Wire In 		0x00 - 0x1F
// Wire Out 	0x20 - 0x3F
// Trigger In 	0x40 - 0x5F
// Trigger Out 	0x60 - 0x7F
// Pipe In 		0x80 - 0x9F
// Pipe Out 	0xA0 - 0xBF
//
ok_endpoint_wrapper  ok_endpoint_wrapper_inst (
	.okUH (okUH ), //input  wire [4:0]   okUH, // external pins
	.okHU (okHU ), //output wire [2:0]   okHU, // external pins
	.okUHU(okUHU), //inout  wire [31:0]  okUHU, // external pins
	.okAA (okAA ), //inout  wire         okAA, // external pin
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


/* TODO: BANK signals */

// LAN signals to mux //{

wire  PT_BASE_EP_LAN_MOSI ; 
wire  PT_BASE_EP_LAN_SCLK ; 
wire  PT_BASE_EP_LAN_CS_B ; 
wire  PT_BASE_EP_LAN_INT_B;
wire  PT_BASE_EP_LAN_RST_B; 
wire  PT_BASE_EP_LAN_MISO ;

wire  PT_FMOD_EP_LAN_MOSI ; 
wire  PT_FMOD_EP_LAN_SCLK ; 
wire  PT_FMOD_EP_LAN_CS_B ; 
wire  PT_FMOD_EP_LAN_INT_B;
wire  PT_FMOD_EP_LAN_RST_B; 
wire  PT_FMOD_EP_LAN_MISO ;

// output mux
assign PT_BASE_EP_LAN_MOSI  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
assign PT_BASE_EP_LAN_SCLK  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
assign PT_BASE_EP_LAN_CS_B  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
assign PT_BASE_EP_LAN_RST_B = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

assign PT_FMOD_EP_LAN_MOSI  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
assign PT_FMOD_EP_LAN_SCLK  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
assign PT_FMOD_EP_LAN_CS_B  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
assign PT_FMOD_EP_LAN_RST_B = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

// input mux
assign EP_LAN_INT_B = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_INT_B  : PT_BASE_EP_LAN_INT_B;
assign EP_LAN_MISO  = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_MISO   : PT_BASE_EP_LAN_MISO;


//}

// LAN pin on BASE board (PGU) //{

// OBUF obuf_LAN_MOSI_inst (.O(o_B13_L11N_SRCC ), .I(LAN_MOSI ) ); // 
// OBUF obuf_LAN_SCLK_inst (.O(o_B13_L6N       ), .I(LAN_SCLK ) ); // 
// OBUF obuf_LAN_SSNn_inst (.O(o_B13_L6P       ), .I(LAN_SSNn ) ); // 
// IBUF ibuf_LAN_INTn_inst (.I(i_B13_L11P_SRCC ), .O(LAN_INTn ) ); //
// OBUF obuf_LAN_RSTn_inst (.O(o_B13_L17N      ), .I(LAN_RSTn ) ); // 
// IBUF ibuf_LAN_MISO_inst (.I(i_B13_L17P      ), .O(LAN_MISO ) ); //

OBUF obuf__LAN_MOSI__inst (.O( o_B13_L11N_SRCC  ), .I(PT_BASE_EP_LAN_MOSI ) ); // 
OBUF obuf__LAN_SCLK__inst (.O( o_B13_L6N        ), .I(PT_BASE_EP_LAN_SCLK ) ); // 
OBUF obuf__LAN_CS_B__inst (.O( o_B13_L6P        ), .I(PT_BASE_EP_LAN_CS_B ) ); // 
IBUF ibuf__LAN_INT_B_inst (.I( i_B13_L11P_SRCC  ), .O(PT_BASE_EP_LAN_INT_B) ); //
OBUF obuf__LAN_RST_B_inst (.O( o_B13_L17N       ), .I(PT_BASE_EP_LAN_RST_B) ); // 
IBUF ibuf__LAN_MISO__inst (.I( i_B13_L17P       ), .O(PT_BASE_EP_LAN_MISO ) ); //


//}


/* TODO: reserved signals : compatible with TXEM7310 */

//// LAN pin on FPGA module //{
//	output wire  o_B15_L6P , // # H17    EP_LAN_PWDN 
//	output wire  o_B15_L7P , // # J22    EP_LAN_MOSI
//	output wire  o_B15_L7N , // # H22    EP_LAN_SCLK
//	output wire  o_B15_L8P , // # H20    EP_LAN_CS_B
//	input  wire  i_B15_L8N , // # G20    EP_LAN_INT_B
//	output wire  o_B15_L9P , // # K21    EP_LAN_RST_B
//	input  wire  i_B15_L9N , // # K22    EP_LAN_MISO

wire  EP_LAN_PWDN  = 1'b0; // test // unused // fixed
OBUF obuf__EP_LAN_PWDN__inst (.O( o_B15_L6P ), .I( EP_LAN_PWDN   ) ); // 

OBUF obuf__EP_LAN_MOSI__inst (.O( o_B15_L7P ), .I( PT_FMOD_EP_LAN_MOSI  ) ); // 
OBUF obuf__EP_LAN_SCLK__inst (.O( o_B15_L7N ), .I( PT_FMOD_EP_LAN_SCLK  ) ); // 
OBUF obuf__EP_LAN_CS_B__inst (.O( o_B15_L8P ), .I( PT_FMOD_EP_LAN_CS_B  ) ); // 
IBUF ibuf__EP_LAN_INT_B_inst (.I( i_B15_L8N ), .O( PT_FMOD_EP_LAN_INT_B ) ); //
OBUF obuf__EP_LAN_RST_B_inst (.O( o_B15_L9P ), .I( PT_FMOD_EP_LAN_RST_B ) ); // 
IBUF ibuf__EP_LAN_MISO__inst (.I( i_B15_L9N ), .O( PT_FMOD_EP_LAN_MISO  ) ); //

//}

//// TP on FPGA module //{

//	inout  wire  io_B15_L1P , // # H13    TP0 // test for eeprom : VCC_3.3V
//	inout  wire  io_B15_L1N , // # G13    TP1 // test for eeprom : VSS_GND
//	inout  wire  io_B15_L2P , // # G15    TP2 // test for eeprom : SCIO
//	inout  wire  io_B15_L2N , // # G16    TP3 // test for eeprom : NA
//	inout  wire  io_B15_L3P , // # J14    TP4 // test for eeprom : VCC_3.3V
//	inout  wire  io_B15_L3N , // # H14    TP5 // test for eeprom : VSS_GND
//	inout  wire  io_B15_L5P , // # J15    TP6 // test for eeprom : NA
//	inout  wire  io_B15_L5N , // # H15    TP7 // test for eeprom : NA

//IOBUF iobuf__TP0__inst(.IO(io_B15_L1P  ), .T(TP_tri[0]), .I(TP_out[0] ), .O(TP_in[0] ) ); //
//IOBUF iobuf__TP1__inst(.IO(io_B15_L1N  ), .T(TP_tri[1]), .I(TP_out[1] ), .O(TP_in[1] ) ); //
//IOBUF iobuf__TP2__inst(.IO(io_B15_L2P  ), .T(TP_tri[2]), .I(TP_out[2] ), .O(TP_in[2] ) ); //
//IOBUF iobuf__TP3__inst(.IO(io_B15_L2N  ), .T(TP_tri[3]), .I(TP_out[3] ), .O(TP_in[3] ) ); //
//IOBUF iobuf__TP4__inst(.IO(io_B15_L3P  ), .T(TP_tri[4]), .I(TP_out[4] ), .O(TP_in[4] ) ); //
//IOBUF iobuf__TP5__inst(.IO(io_B15_L3N  ), .T(TP_tri[5]), .I(TP_out[5] ), .O(TP_in[5] ) ); //
//IOBUF iobuf__TP6__inst(.IO(io_B15_L5P  ), .T(TP_tri[6]), .I(TP_out[6] ), .O(TP_in[6] ) ); //
//IOBUF iobuf__TP7__inst(.IO(io_B15_L5N  ), .T(TP_tri[7]), .I(TP_out[7] ), .O(TP_in[7] ) ); //

//}

//// ADC on module //{

//	input  wire  i_B15_L10P, // # H20    AUX_AD11P
//	input  wire  i_B15_L10N, // # G20    AUX_AD11N

//}

// reserved //{

/* TEMP SENSOR */
//// support MAX6576ZUT+T
//// temp signal count by 12MHz
//// net in sch: FPGA_IO_B
//// pin: i_B35_L6P
//// check signal on debugger 
//// test
//wire w_temp_sig;
//reg r_temp_sig;
//reg r_toggle_temp_sig;
//wire w_rise_temp_sig = ~r_temp_sig & w_temp_sig;
////reg [15:0] r_subcnt_temp_sig_period;
////reg [15:0] r_period_temp_sig_period;
////
//IBUF ibuf_i_B35_L6P_inst  (.I(i_B35_L6P ), .O(w_temp_sig) ); // w_temp_sig
////
//wire tmps_clk = clk3_out3_12M;
//// 
////
//always @(posedge tmps_clk, negedge reset_n) begin
//	if (!reset_n) begin
//		r_temp_sig     <= 1'b0;
//		r_toggle_temp_sig  <= 1'b0;
//		end
//	else begin
//		//
//		r_temp_sig     <= w_temp_sig;
//		//
//		if (w_rise_temp_sig) begin 
//			r_toggle_temp_sig <= ~r_toggle_temp_sig;
//			end
//		end
//end

////

//}

endmodule
