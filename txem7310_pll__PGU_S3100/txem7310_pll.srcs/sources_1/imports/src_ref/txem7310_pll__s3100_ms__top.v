// # this           : txem7310_pll__s3100_ms__top.v
// # top xdc        : txem7310_pll__s3100_ms__top.xdc
//
// # board          : S3100-CPU-BASE
// # board sch      : NA
//
// # note: artix-7 top design for S3100 PGU master side


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
								 		 
	output wire  o_B14_L11P_SRCC  , // # U20  # FPGA_LED0  //$$ led                
	output wire  o_B14_L11N_SRCC  , // # V20  # FPGA_LED1  //$$ led                
	output wire  o_B14_L12P_MRCC  , // # W19  # FPGA_LED2  //$$ led                
	output wire  o_B14_L12N_MRCC  , // # W20  # FPGA_LED3  //$$ led                
	output wire  o_B14_L13P_MRCC  , // # Y18  # FPGA_LED4  //$$ led                
	output wire  o_B14_L13N_MRCC  , // # Y19  # FPGA_LED5  //$$ led                
	output wire  o_B14_L14P_SRCC  , // # V18  # FPGA_LED6  //$$ led                
	output wire  o_B14_L14N_SRCC  , // # V19  # FPGA_LED7  //$$ led                
								 		 
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
	output wire  o_B15_L4P        , // # G17  # EXT_I2C_4_SCL
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
	//input  wire i_B15_L10P_AD11P, // # H20  # AUX_AD11P
	//input  wire i_B15_L10N_AD11N, // # G20  # AUX_AD11N

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
	
	input  wire io_B16_L1P        , // # F13  # BD0
	input  wire io_B16_L1N        , // # F14  # BD1
	input  wire io_B16_L2P        , // # F16  # BD2
	input  wire io_B16_L2N        , // # E17  # BD3
	input  wire io_B16_L3P        , // # C14  # BD4
	input  wire io_B16_L3N        , // # C15  # BD5
	input  wire io_B16_L4P        , // # E13  # BD6
	input  wire io_B16_L4N        , // # E14  # BD7
	input  wire io_B16_L5P        , // # E16  # BD8
	input  wire io_B16_L5N        , // # D16  # BD9
	input  wire io_B16_L6P        , // # D14  # BD10
	input  wire io_B16_L6N        , // # D15  # BD11
	input  wire io_B16_L7P        , // # B15  # BD12
	input  wire io_B16_L7N        , // # B16  # BD13
	input  wire io_B16_L8P        , // # C13  # BD14
	input  wire io_B16_L8N        , // # B13  # BD15
	input  wire io_B16_L9P        , // # A15  # BD16
	input  wire io_B16_L9N        , // # A16  # BD17
	input  wire io_B16_L10P       , // # A13  # BD18
	input  wire io_B16_L10N       , // # A14  # BD19
	input  wire io_B16_L11P       , // # B17  # BD20
	input  wire io_B16_L11N       , // # B18  # BD21
	input  wire io_B16_L12P       , // # D17  # BD22
	input  wire io_B16_L12N       , // # C17  # BD23
	input  wire io_B16_L13P       , // # C18  # BD24
	input  wire io_B16_L13N       , // # C19  # BD25
	input  wire io_B16_L14P       , // # E19  # BD26
	input  wire io_B16_L14N       , // # D19  # BD27
	input  wire io_B16_L15P       , // # F18  # BD28
	input  wire io_B16_L15N       , // # E18  # BD29
	input  wire io_B16_L16P       , // # B20  # BD30
	input  wire io_B16_L16N       , // # A20  # BD31
	
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
	


	//// note: BANK 13 34 35 signal lists // compatible with TXEM7310 connectors in PGU //{
	
	// MC1 - odd //{
	
	// # MC1-15  # o_B34D_L24P,       # DAC0_DAT_N8 
	// # MC1-19  # o_B34D_L24N,       # DAC0_DAT_N9 
	// # MC1-17  # o_B34D_L17P,       # DAC0_DAT_P8 
	// # MC1-21  # o_B34D_L17N,       # DAC0_DAT_P9 
	// # MC1-23  # o_B34D_L16P,       # DAC0_DAT_N10
	// # MC1-25  # o_B34D_L16N,       # DAC0_DAT_P10
	// # MC1-27  # c_B34D_L14P_SRCC,  # DAC0_DCO_P
	// # MC1-29  # c_B34D_L14N_SRCC,  # DAC0_DCO_N
	// # MC1-31  # o_B34D_L10P,       # DAC0_DCI_P
	// # MC1-33  # o_B34D_L10N,       # DAC0_DCI_N
	// # MC1-37  # o_B34D_L20P,       # DAC0_DAT_P7
	// # MC1-39  # o_B34D_L20N,       # DAC0_DAT_N7
	// # MC1-41  # o_B34D_L3P,        # DAC0_DAT_P6
	// # MC1-43  # o_B34D_L3N,        # DAC0_DAT_N6
	// # MC1-45  # o_B34D_L9P,        # DAC0_DAT_P5
	// # MC1-47  # o_B34D_L9N,        # DAC0_DAT_N5
	// # MC1-49  # o_B34D_L2P,        # DAC0_DAT_P4
	// # MC1-51  # o_B34D_L2N,        # DAC0_DAT_N4
	// # MC1-53  # o_B34D_L4P,        # DAC0_DAT_P3
	// # MC1-57  # o_B34D_L4N,        # DAC0_DAT_N3
	// # MC1-59  # o_B34D_L1P,        # DAC0_DAT_P2
	// # MC1-61  # o_B34D_L1N,        # DAC0_DAT_N2
	// # MC1-63  # o_B34D_L7P,        # DAC0_DAT_P1
	// # MC1-65  # o_B34D_L7N,        # DAC0_DAT_N1
	// # MC1-67  # o_B13_L2P,         # SPIO0_CS
	// # MC1-69  # o_B13_L2N,         # SPIOx_SCLK
	// # MC1-71  # o_B13_L4P,         # SPIOx_MOSI
	// # MC1-73  # i_B13_L4N,         # SPIOx_MISO
	// # MC1-75  # o_B13_L1P,         # SPIO1_CS
	// # MC1-77  # o_B34D_L12P_MRCC,  # DAC0_DAT_P0
	// # MC1-79  # o_B34D_L12N_MRCC,  # DAC0_DAT_N0
	
	//}
	
	// MC1 - even //{

	// # MC1-8   # o_B13_SYS_CLK_MC1, # DACx_RST_B
	// # MC1-10  # i_XADC_VN,         # XADC_VN  # M9
	// # MC1-12  # i_XADC_VP,         # XADC_VP  # L10
	// # MC1-16  # o_B34D_L21P,       # DAC0_DAT_N12
	// # MC1-18  # o_B34D_L21N,       # DAC0_DAT_P12
	// # MC1-20  # o_B34D_L19P,       # DAC0_DAT_N13
	// # MC1-22  # o_B34D_L19N,       # DAC0_DAT_P13
	// # MC1-24  # o_B34D_L23P,       # DAC0_DAT_N14
	// # MC1-26  # o_B34D_L23N,       # DAC0_DAT_P14
	// # MC1-28  # o_B34D_L15P,       # DAC0_DAT_N15
	// # MC1-30  # o_B34D_L15N,       # DAC0_DAT_P15
	// # MC1-32  # o_B34D_L13P_MRCC,  # DAC0_DAT_P11
	// # MC1-34  # o_B34D_L13N_MRCC,  # DAC0_DAT_N11
	// # MC1-38  # c_B34D_L11P_SRCC,  # ADC0_DCO_P
	// # MC1-40  # c_B34D_L11N_SRCC,  # ADC0_DCO_N
	// # MC1-42  # i_B34D_L18P,       # ADC0_DA_P
	// # MC1-44  # i_B34D_L18N,       # ADC0_DA_N
	// # MC1-46  # i_B34D_L22P,       # ADC0_DB_P
	// # MC1-48  # i_B34D_L22N,       # ADC0_DB_N
	// # MC1-50  # o_B34D_L6P,        # ADCx_CNV_P
	// # MC1-52  # o_B34D_L6N,        # ADCx_CNV_N
	// # MC1-54  # o_B34_L5P,         # ADCx_TPT_B
	// # MC1-58  # io_B34_L5N,        # S_IO_0
	// # MC1-60  # o_B34D_L8P,        # ADCx_CLK_P
	// # MC1-62  # o_B34D_L8N,        # ADCx_CLK_N
	// # MC1-64  # o_B13_L5P,         # DAC1_CS
	// # MC1-66  # o_B13_L5N,         # DACx_SCLK
	// # MC1-68  # o_B13_L3P,         # DACx_SDIO
	// # MC1-70  # i_B13_L3N,         # DACx_SDO
	// # MC1-72  # o_B13_L16P,        # DAC0_CS
	// # MC1-74  # io_B13_L16N,       # S_IO_1
	// # MC1-76  # io_B13_L1N,        # S_IO_2

	//}
	
	// MC2 - odd //{

	// # MC2-11  # o_B13_SYS_CLK_MC2, # CLKD_SYNC
	// # MC2-15  # o_B35D_L21P,       # DAC1_DAT_N0  //$$ --> DAC1_DAT_P3
	// # MC2-17  # o_B35D_L21N,       # DAC1_DAT_P0  //$$ --> DAC1_DAT_N3
	// # MC2-19  # o_B35D_L19P,       # DAC1_DAT_N1  //$$ --> DAC1_DAT_P2
	// # MC2-21  # o_B35D_L19N,       # DAC1_DAT_P1  //$$ --> DAC1_DAT_N2
	// # MC2-23  # o_B35D_L18P,       # DAC1_DAT_N2  //$$ --> DAC1_DAT_P1
	// # MC2-25  # o_B35D_L18N,       # DAC1_DAT_P2  //$$ --> DAC1_DAT_N1
	// # MC2-27  # o_B35D_L23P,       # DAC1_DAT_N3  //$$ --> DAC1_DAT_P0
	// # MC2-29  # o_B35D_L23N,       # DAC1_DAT_P3  //$$ --> DAC1_DAT_N0
	// # MC2-31  # i_B35_L15P,        # CLKD_STAT
	// # MC2-33  # i_B35_L15N,        # CLKD_REFM
	// # MC2-37  # i_B35D_L9P,        # ADC1_DB_P
	// # MC2-39  # i_B35D_L9N,        # ADC1_DB_N
	// # MC2-41  # i_B35D_L7P,        # ADC1_DA_P
	// # MC2-43  # i_B35D_L7N,        # ADC1_DA_N
	// # MC2-45  # c_B35D_L11P_SRCC,  # ADC1_DCO_P
	// # MC2-47  # c_B35D_L11N_SRCC,  # ADC1_DCO_N
	// # MC2-49  # o_B35_L4P,         # CLKD_SCLK
	// # MC2-51  # o_B35_L4N,         # CLKD_CS_B
	// # MC2-53  # i_B35_L6P,         # CLKD_SDO 
	// # MC2-57  # io_B35_L6N,        # CLKD_SDIO
	// # MC2-59  # o_B35D_L1P,        # DAC1_DAT_N13 // PN swap
	// # MC2-61  # o_B35D_L1N,        # DAC1_DAT_P13 // PN swap
	// # MC2-63  # o_B35D_L13P_MRCC,  # DAC1_DAT_N14 // PN swap
	// # MC2-65  # o_B35D_L13N_MRCC,  # DAC1_DAT_P14 // PN swap
	// # MC2-67  # o_B35D_L12P_MRCC,  # DAC1_DAT_N15 // PN swap
	// # MC2-69  # o_B35D_L12N_MRCC,  # DAC1_DAT_P15 // PN swap
	// # MC2-71  # i_B13_L17P,        # LAN_MISO     
	// # MC2-73  # o_B13_L17N,        # LAN_RSTn     
	// # MC2-75  # c_B13D_L13P_MRCC,  # CLKD_COUT_P   
	// # MC2-77  # c_B13D_L13N_MRCC,  # CLKD_COUT_N   
	// # MC2-79  # i_B13_L11P_SRCC,   # LAN_INTn     

	//}
	
	// MC2 - even //{
	// # MC2-10  # o_B35_IO0,         # CLKD_RST_B
	// # MC2-12  # i_B35_IO25,        # CLKD_LD
	// # MC2-16  # o_B35D_L24P,       # DAC1_DAT_P7
	// # MC2-18  # o_B35D_L24N,       # DAC1_DAT_N7
	// # MC2-20  # o_B35D_L22P,       # DAC1_DAT_P6
	// # MC2-22  # o_B35D_L22N,       # DAC1_DAT_N6
	// # MC2-24  # o_B35D_L20P,       # DAC1_DAT_P5
	// # MC2-26  # o_B35D_L20N,       # DAC1_DAT_N5
	// # MC2-28  # o_B35D_L16P,       # DAC1_DAT_P4
	// # MC2-30  # o_B35D_L16N,       # DAC1_DAT_N4
	// # MC2-32  # o_B35D_L17P,       # DAC1_DCI_N  
	// # MC2-34  # o_B35D_L17N,       # DAC1_DCI_P  
	// # MC2-38  # c_B35D_L14P_SRCC,  # DAC1_DCO_N  
	// # MC2-40  # c_B35D_L14N_SRCC,  # DAC1_DCO_P  
	// # MC2-42  # o_B35D_L10P,       # DAC1_DAT_N8 
	// # MC2-44  # o_B35D_L10N,       # DAC1_DAT_P8 
	// # MC2-46  # o_B35D_L8P,        # DAC1_DAT_N9 
	// # MC2-48  # o_B35D_L8N,        # DAC1_DAT_P9 
	// # MC2-50  # o_B35D_L5P,        # DAC1_DAT_N10
	// # MC2-52  # o_B35D_L5N,        # DAC1_DAT_P10
	// # MC2-54  # o_B35D_L3P,        # DAC1_DAT_N11
	// # MC2-58  # o_B35D_L3N,        # DAC1_DAT_P11
	// # MC2-60  # o_B35D_L2P,        # DAC1_DAT_N12
	// # MC2-62  # o_B35D_L2N,        # DAC1_DAT_P12
	// # MC2-64  # i_B13D_L14P_SRCC,  # TRIG_IN_P  
	// # MC2-66  # i_B13D_L14N_SRCC,  # TRIG_IN_N  
	// # MC2-68  # o_B13_L15P,        # TRIG_OUT_P 
	// # MC2-70  # o_B13_L15N,        # TRIG_OUT_N 
	// # MC2-72  # o_B13_L6P,         # LAN_SSNn   
	// # MC2-74  # o_B13_L6N,         # LAN_SCLK   
	// # MC2-76  # o_B13_L11N_SRCC,   # LAN_MOSI   

	//}

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
	input  wire  i_B13_L6P        , // # W14    # QSPI_BK1_IO0
	input  wire  i_B13_L6N        , // # Y14    # QSPI_BK1_IO1
	input  wire  i_B13_L7P        , // # AB11   # QSPI_BK1_IO2
	input  wire  i_B13_L7N        , // # AB12   # QSPI_BK1_IO3

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
	input  wire  sys_clkn   // # i_B13_L12N_MRCC  # W12 
	//}

	//// LED on XEM7310 on B16 // compatible with TXEM7310 //{
	//$$ output wire [7:0]   led // moved in S3100-CPU-BASE
	//}
	
	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID = h_BD_21_0310   //{
parameter FPGA_IMAGE_ID = 32'h_A0_21_0407;   // S3100-CPU-BASE // pin map setup
//parameter FPGA_IMAGE_ID = 32'h_B0_XX_1008; // S3100-CPU-BASE // pll setup


//}

// check SW_BUILD_ID //{
parameter REQ_SW_BUILD_ID = 32'h_A57E_183C; // 0 for bypass 
//}

//}


///TODO: //-------------------------------------------------------//

/* TODO: IO BUF assignment */ //{

//OBUF obuf__EP_LAN_CS_B__inst (.O( o_B15_L8P ), .I( PT_FMOD_EP_LAN_CS_B  ) ); // 
//IBUF ibuf__EP_LAN_INT_B_inst (.I( i_B15_L8N ), .O( PT_FMOD_EP_LAN_INT_B ) ); //
//IOBUF iobuf__TP0__inst(.IO(io_B15_L1P  ), .T(TP_tri[0]), .I(TP_out[0] ), .O(TP_in[0] ) ); //

//// BANK B14 IOBUF //{

wire FPGA_IO0;
wire FPGA_IO1;
wire FPGA_IO2;
wire FPGA_IO3;
wire FPGA_IO4;
wire FPGA_IO5;
OBUF obuf__FPGA_IO0__inst (.O( o_B14_L4P ), .I( FPGA_IO0 ) ); 
OBUF obuf__FPGA_IO1__inst (.O( o_B14_L4N ), .I( FPGA_IO1 ) ); 
OBUF obuf__FPGA_IO2__inst (.O( o_B14_L5P ), .I( FPGA_IO2 ) ); 
OBUF obuf__FPGA_IO3__inst (.O( o_B14_L5N ), .I( FPGA_IO3 ) ); 
OBUF obuf__FPGA_IO4__inst (.O( o_B14_L6N ), .I( FPGA_IO4 ) );
OBUF obuf__FPGA_IO5__inst (.O( o_B14_L7P ), .I( FPGA_IO5 ) );

wire FPGA_MBD_RS_422_SPI_EN  ;
wire FPGA_MBD_RS_422_TRIG_EN ;
wire FPGA_M0_SPI_TX_EN       ;
wire FPGA_M1_SPI_TX_EN       ;
wire FPGA_M2_SPI_TX_EN       ;
wire FPGA_TRIG_TX_EN         ;
OBUF obuf__FPGA_MBD_RS_422_SPI_EN___inst (.O( o_B14_L7N  ), .I( FPGA_MBD_RS_422_SPI_EN  ) );
OBUF obuf__FPGA_MBD_RS_422_TRIG_EN__inst (.O( o_B14_L8P  ), .I( FPGA_MBD_RS_422_TRIG_EN ) );
OBUF obuf__FPGA_M0_SPI_TX_EN________inst (.O( o_B14_L8N  ), .I( FPGA_M0_SPI_TX_EN       ) );
OBUF obuf__FPGA_M1_SPI_TX_EN________inst (.O( o_B14_L9P  ), .I( FPGA_M1_SPI_TX_EN       ) );
OBUF obuf__FPGA_M2_SPI_TX_EN________inst (.O( o_B14_L9N  ), .I( FPGA_M2_SPI_TX_EN       ) );
OBUF obuf__FPGA_TRIG_TX_EN__________inst (.O( o_B14_L10P ), .I( FPGA_TRIG_TX_EN         ) );

wire [7:0] led; //$$
wire FPGA_LED0 = led[0];  //$$ led                
wire FPGA_LED1 = led[1];  //$$ led                
wire FPGA_LED2 = led[2];  //$$ led                
wire FPGA_LED3 = led[3];  //$$ led                
wire FPGA_LED4 = led[4];  //$$ led                
wire FPGA_LED5 = led[5];  //$$ led                
wire FPGA_LED6 = led[6];  //$$ led                
wire FPGA_LED7 = led[7];  //$$ led                
OBUF obuf__FPGA_LED0__inst (.O( o_B14_L11P_SRCC  ), .I( FPGA_LED0 ) );
OBUF obuf__FPGA_LED1__inst (.O( o_B14_L11N_SRCC  ), .I( FPGA_LED1 ) );
OBUF obuf__FPGA_LED2__inst (.O( o_B14_L12P_MRCC  ), .I( FPGA_LED2 ) );
OBUF obuf__FPGA_LED3__inst (.O( o_B14_L12N_MRCC  ), .I( FPGA_LED3 ) );
OBUF obuf__FPGA_LED4__inst (.O( o_B14_L13P_MRCC  ), .I( FPGA_LED4 ) );
OBUF obuf__FPGA_LED5__inst (.O( o_B14_L13N_MRCC  ), .I( FPGA_LED5 ) );
OBUF obuf__FPGA_LED6__inst (.O( o_B14_L14P_SRCC  ), .I( FPGA_LED6 ) );
OBUF obuf__FPGA_LED7__inst (.O( o_B14_L14N_SRCC  ), .I( FPGA_LED7 ) );
								 		 
wire FPGA_GPIO_PB5 ;
wire FPGA_GPIO_PC4 ;
wire FPGA_GPIO_PC5 ;
wire FPGA_GPIO_PH4 ;
wire FPGA_GPIO_PH6 ;
wire FPGA_GPIO_PH7 ;
OBUF obuf__FPGA_GPIO_PB5__inst (.O( o_B14_L16N  ), .I( FPGA_GPIO_PB5 ) );
OBUF obuf__FPGA_GPIO_PC4__inst (.O( o_B14_L17P  ), .I( FPGA_GPIO_PC4 ) );
OBUF obuf__FPGA_GPIO_PC5__inst (.O( o_B14_L17N  ), .I( FPGA_GPIO_PC5 ) );
OBUF obuf__FPGA_GPIO_PH4__inst (.O( o_B14_L18P  ), .I( FPGA_GPIO_PH4 ) );
OBUF obuf__FPGA_GPIO_PH6__inst (.O( o_B14_L18N  ), .I( FPGA_GPIO_PH6 ) );
OBUF obuf__FPGA_GPIO_PH7__inst (.O( o_B14_L19P  ), .I( FPGA_GPIO_PH7 ) );
				 				 		 
wire FPGA_GPIO_PC9  ;
wire FPGA_GPIO_PC10 ;
wire FPGA_GPIO_PC11 ;
wire FPGA_GPIO_PC12 ;
wire FPGA_GPIO_PC13 ;
wire FPGA_GPIO_PC14 ;
wire FPGA_GPIO_PC15 ;
OBUF obuf__FPGA_GPIO_PC9___inst (.O( o_B14_L19N  ), .I( FPGA_GPIO_PC9  ) );
OBUF obuf__FPGA_GPIO_PC10__inst (.O( o_B14_L20P  ), .I( FPGA_GPIO_PC10 ) );
OBUF obuf__FPGA_GPIO_PC11__inst (.O( o_B14_L20N  ), .I( FPGA_GPIO_PC11 ) );
OBUF obuf__FPGA_GPIO_PC12__inst (.O( o_B14_L21P  ), .I( FPGA_GPIO_PC12 ) );
OBUF obuf__FPGA_GPIO_PC13__inst (.O( o_B14_L21N  ), .I( FPGA_GPIO_PC13 ) );
OBUF obuf__FPGA_GPIO_PC14__inst (.O( o_B14_L22P  ), .I( FPGA_GPIO_PC14 ) );
OBUF obuf__FPGA_GPIO_PC15__inst (.O( o_B14_L22N  ), .I( FPGA_GPIO_PC15 ) );

wire FPGA_GPIO_PD2  ;
wire FPGA_GPIO_PI8  ;
wire FPGA_GPIO_PA8  ;
wire FPGA_GPIO_PB11 ;
IBUF ibuf__FPGA_GPIO_PD2__inst (.I( i_B14_L23P ), .O( FPGA_GPIO_PD2  ) ); //
IBUF ibuf__FPGA_GPIO_PI8__inst (.I( i_B14_L23N ), .O( FPGA_GPIO_PI8  ) ); //
IBUF ibuf__FPGA_GPIO_PA8__inst (.I( i_B14_L24P ), .O( FPGA_GPIO_PA8  ) ); //
IBUF ibuf__FPGA_GPIO_PB11_inst (.I( i_B14_L24N ), .O( FPGA_GPIO_PB11 ) ); //

	
//}

//// BANK B15 IOBUF

//// BANK B16 IOBUF

//// BANK B13 IOBUF

//// BANK B34 IOBUF

//// BANK B35 IOBUF


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
wire mcs_clk              = clk3_out1_72M;
wire lan_clk              = clk3_out2_144M;
wire lan_io_clk           = clk3_out3_12M; // not used yet
wire  mcs_eeprom_fifo_clk = clk3_out4_72M;
//
wire xadc_clk             =  clk_out4_10M;



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
//wire [31:0] w_TEST_TI = (w_mcs_ep_ti_en)? w_port_ti_40_1 : ep40trig;
//
//wire [31:0] w_TEST_TO;
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


//// SSPI wires //{
wire [31:0] w_SSPI_CON_WI  = ep02wire; // controls ... 
			// w_SSPI_CON_WI[0] enables SSPI control from USB 
			// w_SSPI_CON_WI[1] ...
wire [31:0] w_SSPI_FLAG_WO; assign ep22wire = w_SSPI_FLAG_WO;
//

// HW reset signal : SPIO, DAC, ADC, TRIG_IO, MEM, TEST_COUNTER, XADC, TIMESTAMP
wire w_HW_reset__ext;
wire w_HW_reset = w_SSPI_CON_WI[3] | w_HW_reset__ext | w_BRD_CON[0] ; //$$

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


///TODO: //-------------------------------------------------------//





///TODO: //-------------------------------------------------------//

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


///TODO: //-------------------------------------------------------//

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


///TODO: //-------------------------------------------------------//

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
//wire [31:0] w_M0_port_wo_sadrs_h094 = w_SPIO_FLAG_WO    ; // SPIO_FLAG_WO		0x094	wo25
//wire [31:0] w_M0_port_wo_sadrs_h098 = w_DAC_FLAG_WO     ; // DAC_FLAG_WO		0x098	wo26
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
//
//wire [3:0] w_board_id = {S_ID3_BUF,S_ID2_BUF,S_ID1_BUF,S_ID0_BUF};
//$$wire [3:0] w_board_id = w_slot_id; //$$ rev miso info
wire [7:0] w_board_status;
assign w_board_status[7] = 1'b0                    ; // NA // Board Error Status                
//assign w_board_status[6] = r_M_TRIG[0]             ; // M_TRIG             
//assign w_board_status[5] = r_M_PRE_TRIG[0]         ; // M_PRE_TRIG         
//assign w_board_status[4] = r_M_BUSY_B_OUT          ; // M_BUSY_B_OUT or M_READY_OUT      
//assign w_board_status[3] = w_busy_SPI_frame        ; // SPIO busy          
//assign w_board_status[2] = w_busy_DAC_update       ; // DAC  busy          
//assign w_board_status[1] = w_fifo_adc_empty_and_all; // ADC FIFO all empty 
//assign w_board_status[0] = w_ADC_busy_pclk         ; // ADC_busy           

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


endmodule
