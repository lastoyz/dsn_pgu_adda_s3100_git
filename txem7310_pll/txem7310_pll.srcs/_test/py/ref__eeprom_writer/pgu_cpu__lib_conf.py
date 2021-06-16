## pgu_cpu__lib_conf.py : library configuration ... end-point addresses  for PGU-CPU


## TODO: end-point addresses for PGU

### previous endpoint without EEPROM 
##  TEST		SW_BUILD_ID		wi00	0x00
##  TEST		TEST_CON		wi01	0x01
##  TEST		TEST_IO_CON		wi03	0x03 // unused??
##  DACX		DACX_DAT_WI		wi04	0x04
##  DACX		DACX_WI			wi05	0x05
##  CLKD		CLKD_WI			wi06	0x06
##  SPIO		SPIO_WI			wi07	0x07
##  TEST		FPGA_IMAGE_ID	wo20	0x20
##  TEST		TEST_OUT		wo21	0x21
##  TEST		TIMESTAMP_WO	wo22	0x22
##  TEST		TEST_IO_MON		wo23	0x23
##  DACX		DACX_DAT_WO		wo24	0x24
##  DACX		DACX_WO			wo25	0x25
##  CLKD		CLKD_WO			wo26	0x26
##  SPIO		SPIO_WO			wo27	0x27
##  XADC/TEST	MON_TEMP		wo3A	0x3A
##  XADC		XADC_VOLT		wo3B	0x3B
##  TEST		TEST_TI			ti40	0x40
##  TEST		TEST_IO_TI		ti43	0x43
##  DACX		DACX_DAT_TI		ti44	0x44
##  DACX		DACX_TI			ti45	0x45
##  CLKD		CLKD_TI			ti46	0x46
##  SPIO		SPIO_TI			ti47	0x47
##  TEST		TEST_TO			to60	0x60
##  DACX		DAC0_DAT_PI		pi84	0x84
##  DACX		DAC1_DAT_PI		pi85	0x85

### ref CMU  
##  TEST	SW_BUILD_ID	wi00	0x00
##  TEST	TEST_CON	wi01	0x01
##  TEST	TEST_CC_DIN	wi02	0x02
##  TEST	BRD_CON	wi03	0x03
##  DAC	DAC_TEST_IN	wi04	0x04
##  DWAVE	DWAVE_DIN_BY_TRIG	wi05	0x05
##  DWAVE	DWAVE_CON	wi06	0x06
##  SPO	SPO_CON	wi07	0x07
##  SPO	SPO_DIN_B0_L	wi08	0x08
##  SPO	SPO_DIN_B0_H	wi09	0x09
##  SPO	SPO_DIN_B1_L	wi0A	0x0A
##  SPO	SPO_DIN_B1_H	wi0B	0x0B
##  SPO	SPO_DIN_B2_L	wi0C	0x0C
##  SPO	SPO_DIN_B2_H	wi0D	0x0D
##  SPO	SPO_DIN_B3_L	wi0E	0x0E
##  SPO	SPO_DIN_B3_H	wi0F	0x0F
##  DAC_A2A3	DAC_A2A3_CON	wi10	0x10
##  DAC_BIAS	DAC_BIAS_CON	wi11	0x11
##  MEM	MEM_FDAT_WI	wi12	0x12
##  MEM	MEM_WI	wi13	0x13
##  DAC_A2A3	DAC_A2A3_DIN21	wi14	0x14
##  DAC_A2A3	DAC_A2A3_DIN43	wi15	0x15
##  DAC_BIAS	DAC_BIAS_DIN21	wi16	0x16
##  DAC_BIAS	DAC_BIAS_DIN43	wi17	0x17
##  ADC_HS	ADC_HS_WI	wi18	0x18
##  MCS	MCS_SETUP_WI	wi19	0x19
##  SPIO	SPIO_FDAT_WI	wi1A	0x1A
##  SPIO	SPIO_WI	wi1B	0x1B
##  ADC_HS	ADC_HS_UPD_SMP	wi1D	0x1D
##  ADC_HS	ADC_HS_SMP_PRD	wi1E	0x1E
##  ADC_HS	ADC_HS_DLY_TAP_OPT	wi1F	0x1F
##  TEST	FPGA_IMAGE_ID	wo20	0x20
##  TEST	TEST_OUT	wo21	0x21
##  TEST	TEST_CC_MON	wo22	0x22
##  DWAVE	DWAVE_BASE_FREQ	wo23	0x23
##  DAC	DAC_TEST_OUT	wo24	0x24
##  DWAVE	DWAVE_DOUT_BY_TRIG	wo25	0x25
##  DWAVE	DWAVE_FLAG	wo26	0x26
##  SPO	SPO_FLAG	wo27	0x27
##  SPO	SPO_MON_B0_L	wo28	0x28
##  SPO	SPO_MON_B0_H	wo29	0x29
##  SPO	SPO_MON_B1_L	wo2A	0x2A
##  SPO	SPO_MON_B1_H	wo2B	0x2B
##  SPO	SPO_MON_B2_L	wo2C	0x2C
##  SPO	SPO_MON_B2_H	wo2D	0x2D
##  SPO	SPO_MON_B3_L	wo2E	0x2E
##  SPO	SPO_MON_B3_H	wo2F	0x2F
##  DAC_A2A3	DAC_A2A3_FLAG	wo30	0x30
##  DAC_BIAS	DAC_BIAS_FLAG	wo31	0x31
##  DAC	DAC_TEST_RB1	wo32	0x32
##  DAC	DAC_TEST_RB2	wo33	0x33
##  DAC_A2A3	DAC_A2A3_RB21	wo34	0x34
##  DAC_A2A3	DAC_A2A3_RB43	wo35	0x35
##  DAC_BIAS	DAC_BIAS_RB21	wo36	0x36
##  DAC_BIAS	DAC_BIAS_RB43	wo37	0x37
##  ADC_HS	ADC_HS_WO	wo38	0x38
##  ADC	ADC_BASE_FREQ	wo39	0x39
##  XADC/TEST	XADC_TEMP or TIME_STAMP	wo3A	0x3A
##  XADC/SPIO	XADC_VOLT or SPIO_WO	wo3B	0x3B
##  ADC_HS	ADC_HS_DOUT0	wo3C	0x3C
##  ADC_HS	ADC_HS_DOUT1	wo3D	0x3D
##  ADC_HS	ADC_HS_DOUT2	wo3E	0x3E
##  ADC_HS	ADC_HS_DOUT3	wo3F	0x3F
##  TEST	TEST_TI	ti40	0x40
##  TEST	TEST_TI_HS	ti41	0x41
##  DWAVE	DWAVE_TI	ti46	0x46
##  TEST_MCS		ti4A	0x4A
##  DAC_BIAS	DAC_BIAS_TI	ti50	0x50
##  DAC_A2A3	DAC_A2A3_TI	ti51	0x51
##  MEM	MEM_TI	ti53	0x53
##  ADC_HS	ADC_HS_TI	ti58	0x58
##  SPIO	SPIO_TI	ti5B	0x5B
##  TEST	TEST_TO	to60	0x60
##  TEST_MCS		to6A	0x6A
##  DAC_BIAS	DAC_BIAS_TO	to70	0x70
##  DAC_A2A3	DAC_A2A3_TO	to71	0x71
##  MEM	MEM_TO	to73	0x73
##  ADC_HS	ADC_HS_TO	to78	0x78
##  SPIO	SPIO_TO	to7B	0x7B
##  TEST_MCS		pi8A	0x8A
##  MEM	MEM_PI	pi93	0x93
##  TEST_MCS		poAA	0xAA
##  MEM	MEM_PO	poB3	0xB3
##  ADC_HS	ADC_HS_DOUT0_PO	poBC	0xBC
##  ADC_HS	ADC_HS_DOUT1_PO	poBD	0xBD
##  ADC_HS	ADC_HS_DOUT2_PO	poBE	0xBE
##  ADC_HS	ADC_HS_DOUT3_PO	poBF	0xBF


### ref MHVSU  
##  TEST	SW_INFO_WI	0x000	wi00
##  TEST	TEST_CON_WI	0x004	wi01
##  SSPI	SSPI_CON_WI	0x008	wi02
##  TEST	RNET_CON_WI	0x00C	wi03
##  MHVSU_SPIO	SPIO_FDAT_WI	0x010	wi04
##  MHVSU_SPIO	SPIO_CON_WI	0x014	wi05
##  MHVSU_DAC	DAC_CON_WI	0x018	wi06
##  MHVSU_ADC	ADC_CON_WI	0x01C	wi07
##  MHVSU_SPIO	SPIO_S1_WI	0x020	wi08
##  MHVSU_SPIO	SPIO_S2_WI	0x024	wi09
##  MHVSU_SPIO	SPIO_S3_WI	0x028	wi0A
##  MHVSU_SPIO	SPIO_S4_WI	0x02C	wi0B
##  MHVSU_SPIO	SPIO_S5_WI	0x030	wi0C
##  MHVSU_SPIO	SPIO_S6_WI	0x034	wi0D
##  MHVSU_SPIO	SPIO_S7_WI	0x038	wi0E
##  MHVSU_SPIO	SPIO_S8_WI	0x03C	wi0F
##  MHVSU_ADC	ADC_PAR_WI        	0x040	wi10
##  MCS	MCS_SETUP_WI	0x044	wi11
##  MEM	MEM_FDAT_WI	0x048	wi12
##  MEM	MEM_WI	0x04C	wi13
##  EXT_TRIG	EXT_TRIG_CON_WI	0x050	wi14
##  EXT_TRIG	EXT_TRIG_PARA_WI	0x054	wi15
##  EXT_TRIG	EXT_TRIG_AUX_WI	0x058	wi16
##  SSPI	SSPI_TEST_WI	0x05C	wi17
##  MHVSU_DAC	DAC_S1_WI	0x060	wi18
##  MHVSU_DAC	DAC_S2_WI	0x064	wi19
##  MHVSU_DAC	DAC_S3_WI	0x068	wi1A
##  MHVSU_DAC	DAC_S4_WI	0x06C	wi1B
##  MHVSU_DAC	DAC_S5_WI	0x070	wi1C
##  MHVSU_DAC	DAC_S6_WI	0x074	wi1D
##  MHVSU_DAC	DAC_S7_WI	0x078	wi1E
##  MHVSU_DAC	DAC_S8_WI	0x07C	wi1F
##  TEST	FPGA_IMAGE_ID_WO	0x080	wo20
##  "TEST
##  SSPI"	"TEST_FLAG_WO
##  SSPI_TEST_WO"	0x084	wo21
##  SSPI	SSPI_FLAG_WO	0x088	wo22
##  TEST	MON_XADC_WO	0x08C	wo23
##  TEST	MON_GP_WO	0x090	wo24
##  MHVSU_SPIO	SPIO_FLAG_WO	0x094	wo25
##  MHVSU_DAC	DAC_FLAG_WO	0x098	wo26
##  MHVSU_ADC	ADC_FLAG_WO	0x09C	wo27
##  MHVSU_ADC	ADC_S1_ACC_WO	0x0A0	wo28
##  MHVSU_ADC	ADC_S2_ACC_WO	0x0A4	wo29
##  MHVSU_ADC	ADC_S3_ACC_WO	0x0A8	wo2A
##  MHVSU_ADC	ADC_S4_ACC_WO	0x0AC	wo2B
##  MHVSU_ADC	ADC_S5_ACC_WO	0x0B0	wo2C
##  MHVSU_ADC	ADC_S6_ACC_WO	0x0B4	wo2D
##  MHVSU_ADC	ADC_S7_ACC_WO	0x0B8	wo2E
##  MHVSU_ADC	ADC_S8_ACC_WO	0x0BC	wo2F
##  MHVSU_ADC	ADC_S1_WO	0x0C0	wo30
##  MHVSU_ADC	ADC_S2_WO	0x0C4	wo31
##  MHVSU_ADC	ADC_S3_WO	0x0C8	wo32
##  MHVSU_ADC	ADC_S4_WO	0x0CC	wo33
##  MHVSU_ADC	ADC_S5_WO	0x0D0	wo34
##  MHVSU_ADC	ADC_S6_WO	0x0D4	wo35
##  MHVSU_ADC	ADC_S7_WO	0x0D8	wo36
##  MHVSU_ADC	ADC_S8_WO	0x0DC	wo37
##  MHVSU_DAC	DAC_S1_WO	0x0E0	wo38
##  MHVSU_DAC	DAC_S2_WO	0x0E4	wo39
##  MHVSU_DAC	DAC_S3_WO	0x0E8	wo3A
##  MHVSU_DAC	DAC_S4_WO	0x0EC	wo3B
##  MHVSU_DAC	DAC_S5_WO	0x0F0	wo3C
##  MHVSU_DAC	DAC_S6_WO	0x0F4	wo3D
##  MHVSU_DAC	DAC_S7_WO	0x0F8	wo3E
##  MHVSU_DAC	DAC_S8_WO	0x0FC	wo3F
##  TEST	TEST_TI	0x104	ti41
##  SSPI	SSPI_TEST_TI	0x108	ti42
##  EXT_TRIG	EXT_TRIG_TI	0x110	ti44
##  MHVSU_SPIO	SPIO_TRIG_TI	0x114	ti45
##  MHVSU_DAC	DAC_TRIG_TI	0x118	ti46
##  MHVSU_ADC	ADC_TRIG_TI	0x11C	ti47
##  MEM	MEM_TI	0x14C	ti53
##  TEST	TEST_TO	0x184	to61
##  SSPI	SSPI_TEST_TO	0x188	to62
##  EXT_TRIG	EXT_TRIG_TO	0x190	to64
##  MHVSU_SPIO	SPIO_TRIG_TO	0x194	to65
##  MHVSU_DAC	DAC_TRIG_TO	0x198	to66
##  MHVSU_ADC	ADC_TRIG_TO	0x19C	to67
##  MEM	MEM_TO	0x1CC	to73
##  MEM	MEM_PI	0x24C	pi93
##  MHVSU_ADC	ADC_S1_CH1_PO	0x280	poA0
##  MHVSU_ADC	ADC_S2_CH1_PO	0x284	poA1
##  MHVSU_ADC	ADC_S3_CH1_PO	0x288	poA2
##  MHVSU_ADC	ADC_S4_CH1_PO	0x28C	poA3
##  MHVSU_ADC	ADC_S5_CH1_PO	0x290	poA4
##  MHVSU_ADC	ADC_S6_CH1_PO	0x294	poA5
##  MHVSU_ADC	ADC_S7_CH1_PO	0x298	poA6
##  MHVSU_ADC	ADC_S8_CH1_PO	0x29C	poA7
##  MHVSU_ADC	ADC_S1_CH2_PO	0x2A0	poA8
##  MHVSU_ADC	ADC_S2_CH2_PO	0x2A4	poA9
##  MHVSU_ADC	ADC_S3_CH2_PO	0x2A8	poAA
##  MHVSU_ADC	ADC_S4_CH2_PO	0x2AC	poAB
##  MHVSU_ADC	ADC_S5_CH2_PO	0x2B0	poAC
##  MHVSU_ADC	ADC_S6_CH2_PO	0x2B4	poAD
##  MHVSU_ADC	ADC_S7_CH2_PO	0x2B8	poAE
##  MHVSU_ADC	ADC_S8_CH2_PO	0x2BC	poAF
##  MEM	MEM_PO	0x2CC	poB3
##  SSPI	SSPI_TEST_OUT	0x380	NA
##  SSPI	SSPI_BD_STAT_WO	0x384	NA
##  SSPI	SSPI_CNT_CS_M0_WO	0x388	NA
##  SSPI	SSPI_CNT_CS_M1_WO	0x38C	NA
##  SSPI	SSPI_CNT_ADC_FIFO_IN_WO	0x390	NA
##  SSPI	SSPI_CNT_ADC_TRIG_WO	0x394	NA
##  SSPI	SSPI_CNT_SPIO_FRM_TRIG_WO	0x398	NA
##  SSPI	SSPI_CNT_DAC_TRIG_WO	0x39C	NA



EP_ADRS_CONFIG = {
	'board_name'         : 'PGU-CPU-F5500-REVA', # PGU-CPU-F5500-REVA 19-10-24
	#
	'ver'                : '0xBD201216', # // EEPROM and LAN test // over PGEP with XEM7310
	#                                    # // support TXEM7310-FPGA-CORE to come
	#
	'bit_filename'        : 'download.bit',
	#
	# wire-in
	'SW_BUILD_ID'        : 0x00,
	'TEST_CON'           : 0x01,
	'wi02'               : 0x02,
	'BRD_CON'            : 0x03, # BRD_CON ##$$ compatible with CMU ## TEST_IO_CON unused??
	'DACX_DAT_WI'        : 0x04,
	'DACX_WI'            : 0x05,
	'CLKD_WI'            : 0x06,
	'SPIO_WI'            : 0x07,
	'DACZ_DAT_WI'        : 0x08, ##$$ new pattern gen
	'wi09'               : 0x09,
	'wi0A'               : 0x0A,
	'wi0B'               : 0x0B,
	'wi0C'               : 0x0C,
	'wi0D'               : 0x0D,
	'wi0E'               : 0x0E,
	'wi0F'               : 0x0F,
	'wi10'               : 0x10,
	'wi11'               : 0x11, # MCS_SETUP_WI ##$$ compatible with MHVSU
	'MEM_FDAT_WI'        : 0x12, ##$$ compatible with CMU
	'MEM_WI'             : 0x13, ##$$ compatible with CMU
	'wi14'               : 0x14, 
	'wi15'               : 0x15, 
	'wi16'               : 0x16, 
	'wi17'               : 0x17,
	'wi18'               : 0x18,
	'MCS_SETUP_WI'       : 0x19, # MCS_SETUP_WI ##$$ compatible with CMU
	'wi1A'               : 0x1A, 
	'wi1B'               : 0x1B, 
	'wi1C'               : 0x1C, 
	'wi1D'               : 0x1D,
	'wi1E'               : 0x1E,
	'wi1F'               : 0x1F,
	# wire-out
	'FPGA_IMAGE_ID'      : 0x20,
	'TEST_OUT'           : 0x21,
	'TIMESTAMP_WO'       : 0x22,
	'TEST_IO_MON'        : 0x23, 
	'DACX_DAT_WO'        : 0x24, 
	'DACX_WO'            : 0x25, 
	'CLKD_WO'            : 0x26, 
	'SPIO_WO'            : 0x27, 
	'DACZ_DAT_WO'        : 0x28, ##$$ new pattern gen
	'wo29'               : 0x29,
	'wo2A'               : 0x2A,
	'wo2B'               : 0x2B,
	'wo2C'               : 0x2C,
	'wo2D'               : 0x2D,
	'wo2E'               : 0x2E,
	'wo2F'               : 0x2F,
	'wo30'               : 0x30, 
	'wo31'               : 0x31,
	'wo32'               : 0x32,
	'wo33'               : 0x33,
	'wo34'               : 0x34, 
	'wo35'               : 0x35, 
	'wo36'               : 0x36,
	'wo37'               : 0x37,
	'wo38'               : 0x38,
	'wo39'	             : 0x39,
	'MON_TEMP'           : 0x3A,
	'XADC_TEMP'          : 0x3A, 	# alias
	'XADC_VOLT'          : 0x3B,
	'wo3B'               : 0x3B, 
	'wo3C'               : 0x3C,
	'wo3D'               : 0x3D,
	'wo3E'               : 0x3E,
	'wo3F'               : 0x3F,
	#
	# trig-in
	'TEST_TI'            : 0x40,
	'TEST_IO_TI'         : 0x43, 
	'DACX_DAT_TI'        : 0x44,
	'DACX_TI'            : 0x45,
	'CLKD_TI'            : 0x46,
	'SPIO_TI'            : 0x47,
	'DACZ_DAT_TI'        : 0x48, ##$$ new pattern gen
	'MEM_TI'             : 0x53, ##$$ compatible with CMU
	#
	# trig-out
	'TEST_TO'            : 0x60,
	'MEM_TO'             : 0x73, ##$$ compatible with CMU
	#
	# pipe-in
	'DAC0_DAT_PI'        : 0x84, ##$$ 
	'DAC1_DAT_PI'        : 0x85, ##$$ 
	'DAC0_DAT_INC_PI'    : 0x86, ##$$ new // data b16 + inc b16
	'DAC0_DUR_PI'        : 0x87, ##$$ new // duration b32
	'DAC1_DAT_INC_PI'    : 0x88, ##$$ new // data b16 + inc b16
	'DAC1_DUR_PI'        : 0x89, ##$$ new // duration b32
	'TEST_PI'            : 0x8A, ##$$ test fifo from MCS only
	'MEM_PI'             : 0x93, ##$$ compatible with CMU
	#
	# pipe-out
	'TEST_PO'            : 0xAA, ##$$ test fifo from MCS only
	'MEM_PO'             : 0xB3, ##$$ compatible with CMU
	#
	'end' : 'end'
}


## TODO: SPIO configuration 
# for MCP23S17
# IODIR output(0) or input(1)
# OLAT  initial output value 
SPIO_CONFIG_ref = {
	'BITNAME_A' : [ ['HA0_B0_A', 'HA0_B1_A', 'HA0_B2_A', 'HA0_B3_A', 'HA0_B4_A', 'HA0_B5_A', 'HA0_B6_A', 'HA0_B7_A'], 
					['HA1_B0_A', 'HA1_B1_A', 'HA1_B2_A', 'HA1_B3_A', 'HA1_B4_A', 'HA1_B5_A', 'HA1_B6_A', 'HA1_B7_A'], 
					['HA2_B0_A', 'HA2_B1_A', 'HA2_B2_A', 'HA2_B3_A', 'HA2_B4_A', 'HA2_B5_A', 'HA2_B6_A', 'HA2_B7_A'], 
					['HA3_B0_A', 'HA3_B1_A', 'HA3_B2_A', 'HA3_B3_A', 'HA3_B4_A', 'HA3_B5_A', 'HA3_B6_A', 'HA3_B7_A'],  
					['HA4_B0_A', 'HA4_B1_A', 'HA4_B2_A', 'HA4_B3_A', 'HA4_B4_A', 'HA4_B5_A', 'HA4_B6_A', 'HA4_B7_A'], 
					['HA5_B0_A', 'HA5_B1_A', 'HA5_B2_A', 'HA5_B3_A', 'HA5_B4_A', 'HA5_B5_A', 'HA5_B6_A', 'HA5_B7_A'], 
					['HA6_B0_A', 'HA6_B1_A', 'HA6_B2_A', 'HA6_B3_A', 'HA6_B4_A', 'HA6_B5_A', 'HA6_B6_A', 'HA6_B7_A'], 
					['HA7_B0_A', 'HA7_B1_A', 'HA7_B2_A', 'HA7_B3_A', 'HA7_B4_A', 'HA7_B5_A', 'HA7_B6_A', 'HA7_B7_A']],
	'BITNAME_B' : [ ['HA0_B0_B', 'HA0_B1_B', 'HA0_B2_B', 'HA0_B3_B', 'HA0_B4_B', 'HA0_B5_B', 'HA0_B6_B', 'HA0_B7_B'], 
					['HA1_B0_B', 'HA1_B1_B', 'HA1_B2_B', 'HA1_B3_B', 'HA1_B4_B', 'HA1_B5_B', 'HA1_B6_B', 'HA1_B7_B'], 
					['HA2_B0_B', 'HA2_B1_B', 'HA2_B2_B', 'HA2_B3_B', 'HA2_B4_B', 'HA2_B5_B', 'HA2_B6_B', 'HA2_B7_B'], 
					['HA3_B0_B', 'HA3_B1_B', 'HA3_B2_B', 'HA3_B3_B', 'HA3_B4_B', 'HA3_B5_B', 'HA3_B6_B', 'HA3_B7_B'],  
					['HA4_B0_B', 'HA4_B1_B', 'HA4_B2_B', 'HA4_B3_B', 'HA4_B4_B', 'HA4_B5_B', 'HA4_B6_B', 'HA4_B7_B'], 
					['HA5_B0_B', 'HA5_B1_B', 'HA5_B2_B', 'HA5_B3_B', 'HA5_B4_B', 'HA5_B5_B', 'HA5_B6_B', 'HA5_B7_B'], 
					['HA6_B0_B', 'HA6_B1_B', 'HA6_B2_B', 'HA6_B3_B', 'HA6_B4_B', 'HA6_B5_B', 'HA6_B6_B', 'HA6_B7_B'], 
					['HA7_B0_B', 'HA7_B1_B', 'HA7_B2_B', 'HA7_B3_B', 'HA7_B4_B', 'HA7_B5_B', 'HA7_B6_B', 'HA7_B7_B']],
	#
	#             hw0   hw1   hw2   hw3    hw4   hw5   hw6   hw7 
	'IODIR_A' : [0xFF, 0xFF, 0xFF, 0xFF,  0xFF, 0xFF, 0xFF, 0xFF],
	'IODIR_B' : [0xFF, 0xFF, 0xFF, 0xFF,  0xFF, 0xFF, 0xFF, 0xFF],
	'OLAT_A'  : [0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00],
	'OLAT_B'  : [0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00]
	
}

# nets from hvpgu-201125a-top_ver1_1.pdf
#   new spio pin map U6 
#
#   GPA7 : [10v_cls2 | O | 0] 10v_output_close2
#   GPA6 : [10v_cls1 | O | 0] 10v_output_close1
#   GPA5 : [40v_cls2 | O | 0] 40v_output_close2
#   GPA4 : [40v_cls1 | O | 0] 40v_output_close1
#   GPA3 : [ch2_40v  | O | 0] ch2_40v
#   GPA2 : [ch1_40v  | O | 0] ch1_40v
#   GPA1 : [sleep2   | O | 0] sleep2
#   GPA0 : [sleep1   | O | 0] sleep1
#
#   GPB7 : [CHK_LED  | O | 0] check_LED
#   GPB6 : [NA       | O | 0] NA
#   GPB5 : [lat_rst2 | O | 0] latch_reset2
#   GPB4 : [lat_rst1 | O | 0] latch_reset1
#   GPB3 : [OH_det2  | I | 0] OH_deteced2 
#   GPB2 : [OH_det1  | I | 0] OH_deteced1 
#   GPB1 : [OC_det2  | I | 0] OC_deteced2 
#   GPB0 : [OC_det1  | I | 0] OC_deteced1 


SPIO_CONFIG = {
	'BITNAME_A' : [ ['HA0_B0_A sleep1_n', 'HA0_B1_A sleep2_n', 'HA0_B2_A ch1_40v ', 'HA0_B3_A ch2_40v ', 'HA0_B4_A 40v_cls1', 'HA0_B5_A 40v_cls2', 'HA0_B6_A 10v_cls1', 'HA0_B7_A 10v_cls2'], 
					['HA1_B0_A         ', 'HA1_B1_A         ', 'HA1_B2_A         ', 'HA1_B3_A         ', 'HA1_B4_A         ', 'HA1_B5_A         ', 'HA1_B6_A         ', 'HA1_B7_A         '], 
					['HA2_B0_A         ', 'HA2_B1_A         ', 'HA2_B2_A         ', 'HA2_B3_A         ', 'HA2_B4_A         ', 'HA2_B5_A         ', 'HA2_B6_A         ', 'HA2_B7_A         '], 
					['HA3_B0_A         ', 'HA3_B1_A         ', 'HA3_B2_A         ', 'HA3_B3_A         ', 'HA3_B4_A         ', 'HA3_B5_A         ', 'HA3_B6_A         ', 'HA3_B7_A         '],  
					['HA4_B0_A         ', 'HA4_B1_A         ', 'HA4_B2_A         ', 'HA4_B3_A         ', 'HA4_B4_A         ', 'HA4_B5_A         ', 'HA4_B6_A         ', 'HA4_B7_A         '], 
					['HA5_B0_A         ', 'HA5_B1_A         ', 'HA5_B2_A         ', 'HA5_B3_A         ', 'HA5_B4_A         ', 'HA5_B5_A         ', 'HA5_B6_A         ', 'HA5_B7_A         '], 
					['HA6_B0_A         ', 'HA6_B1_A         ', 'HA6_B2_A         ', 'HA6_B3_A         ', 'HA6_B4_A         ', 'HA6_B5_A         ', 'HA6_B6_A         ', 'HA6_B7_A         '], 
					['HA7_B0_A         ', 'HA7_B1_A         ', 'HA7_B2_A         ', 'HA7_B3_A         ', 'HA7_B4_A         ', 'HA7_B5_A         ', 'HA7_B6_A         ', 'HA7_B7_A         ']],
	'BITNAME_B' : [ ['HA0_B0_B OC_det1 ', 'HA0_B1_B OC_det2 ', 'HA0_B2_B OH_det1 ', 'HA0_B3_B OH_det2 ', 'HA0_B4_B lat_rst1', 'HA0_B5_B lat_rst2', 'HA0_B6_B NA      ', 'HA0_B7_B CHK_LED '], 
					['HA1_B0_B         ', 'HA1_B1_B         ', 'HA1_B2_B         ', 'HA1_B3_B         ', 'HA1_B4_B         ', 'HA1_B5_B         ', 'HA1_B6_B         ', 'HA1_B7_B         '], 
					['HA2_B0_B         ', 'HA2_B1_B         ', 'HA2_B2_B         ', 'HA2_B3_B         ', 'HA2_B4_B         ', 'HA2_B5_B         ', 'HA2_B6_B         ', 'HA2_B7_B         '], 
					['HA3_B0_B         ', 'HA3_B1_B         ', 'HA3_B2_B         ', 'HA3_B3_B         ', 'HA3_B4_B         ', 'HA3_B5_B         ', 'HA3_B6_B         ', 'HA3_B7_B         '],  
					['HA4_B0_B         ', 'HA4_B1_B         ', 'HA4_B2_B         ', 'HA4_B3_B         ', 'HA4_B4_B         ', 'HA4_B5_B         ', 'HA4_B6_B         ', 'HA4_B7_B         '], 
					['HA5_B0_B         ', 'HA5_B1_B         ', 'HA5_B2_B         ', 'HA5_B3_B         ', 'HA5_B4_B         ', 'HA5_B5_B         ', 'HA5_B6_B         ', 'HA5_B7_B         '], 
					['HA6_B0_B         ', 'HA6_B1_B         ', 'HA6_B2_B         ', 'HA6_B3_B         ', 'HA6_B4_B         ', 'HA6_B5_B         ', 'HA6_B6_B         ', 'HA6_B7_B         '], 
					['HA7_B0_B         ', 'HA7_B1_B         ', 'HA7_B2_B         ', 'HA7_B3_B         ', 'HA7_B4_B         ', 'HA7_B5_B         ', 'HA7_B6_B         ', 'HA7_B7_B         ']],
	#
	#             hw0   hw1   hw2   hw3    hw4   hw5   hw6   hw7 
	'IODIR_A' : [0x00, 0xFF, 0xFF, 0xFF,  0xFF, 0xFF, 0xFF, 0xFF],
	'IODIR_B' : [0x0F, 0xFF, 0xFF, 0xFF,  0xFF, 0xFF, 0xFF, 0xFF],
	'OLAT_A'  : [0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00],
	'OLAT_B'  : [0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00]
}


###########################################################################
# test lib

def _test():
	
	##  
	print(EP_ADRS_CONFIG)
	
	##
	print(SPIO_CONFIG)
	#
	print(SPIO_CONFIG['BITNAME_A'])
	print(SPIO_CONFIG['BITNAME_B'])
	#
	print(SPIO_CONFIG['IODIR_A'])
	print(SPIO_CONFIG['IODIR_A'][0x0]) # hardware adrs 0x0
	print(SPIO_CONFIG['IODIR_A'][0x1]) # hardware adrs 0x1
	print(SPIO_CONFIG['IODIR_A'][0x2]) # hardware adrs 0x2
	print(SPIO_CONFIG['IODIR_A'][0x3]) # hardware adrs 0x3
	print(SPIO_CONFIG['IODIR_A'][0x4]) # hardware adrs 0x4
	print(SPIO_CONFIG['IODIR_A'][0x5]) # hardware adrs 0x5
	print(SPIO_CONFIG['IODIR_A'][0x6]) # hardware adrs 0x6
	print(SPIO_CONFIG['IODIR_A'][0x7]) # hardware adrs 0x7
	#
	#print('NAME {} : IO {} : LAT {}'.format(
	#	SPIO_CONFIG['BITNAME_A'][0x0][0],
	#	(SPIO_CONFIG['IODIR_A'][0x0]>>0)&0x01,
	#	(SPIO_CONFIG['OLAT_A' ][0x0]>>0)&0x01)
	#	)
	#
	for aa in range(0,8): # hardware address
		for bb in range(0,8): # bit location
			#print('{} {}'.format(aa,bb))
			print('NAME {} : IOD {} : LAT {}, NAME {} : IOD {} : LAT {}'.format(
				SPIO_CONFIG['BITNAME_A'][aa] [bb],
				(SPIO_CONFIG[ 'IODIR_A'][aa]>>bb)&0x01,
				(SPIO_CONFIG[  'OLAT_A'][aa]>>bb)&0x01,
				SPIO_CONFIG['BITNAME_B'][aa] [bb],
				(SPIO_CONFIG[ 'IODIR_B'][aa]>>bb)&0x01,
				(SPIO_CONFIG[  'OLAT_B'][aa]>>bb)&0x01)
				)
	#
	return

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	_test()
	
