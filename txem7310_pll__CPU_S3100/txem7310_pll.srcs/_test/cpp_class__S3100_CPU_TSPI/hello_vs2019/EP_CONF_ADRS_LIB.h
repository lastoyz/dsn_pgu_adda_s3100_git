
#define __MAX_CNT			400000

#define SW_BUILD_ID         0x00
#define	TEST_CON            0x01
#define	TEST_CC_DIN         0x02
#define	wi03                0x03
#define	DAC_TEST_IN         0x04
#define	DWAVE_DIN_BY_TRIG   0x05
#define	DWAVE_CON           0x06
#define	SPO_CON             0x07
#define	SPO_DIN_B0_L        0x08
#define	SPO_DIN_B0_H        0x09
#define	SPO_DIN_B1_L        0x0A
#define	SPO_DIN_B1_H        0x0B
#define	SPO_DIN_B2_L        0x0C
#define	SPO_DIN_B2_H        0x0D
#define	SPO_DIN_B3_L        0x0E
#define	SPO_DIN_B3_H        0x0F
#define	DAC_A2A3_CON        0x10
#define	DAC_BIAS_CON        0x11
#define	wi12                0x12
#define	wi13                0x13
#define	DAC_A2A3_DIN21      0x14
#define	DAC_A2A3_DIN43      0x15
#define	DAC_BIAS_DIN21      0x16
#define	DAC_BIAS_DIN43      0x17
#define	ADC_HS_WI           0x18
#define	wi19                0x19
//#define	wi1A                0x1A
#define SPIO_FDAT_WI		0x1A		//SPIO FDAT WI
//#define	wi1B                0x1B
#define SPIO_WI				0x1B		//SPIO WI
#define	wi1C                0x1C
#define	ADC_HS_UPD_SMP      0x1D
#define	ADC_HS_SMP_PRD      0x1E
#define	ADC_HS_DLY_TAP_OPT  0x1F

// wire-out

#define	FPGA_IMAGE_ID       0x20
#define	TEST_OUT            0x21
#define	TEST_CC_MON         0x22
#define	DWAVE_BASE_FREQ     0x23
#define	DAC_TEST_OUT        0x24
#define	DWAVE_DOUT_BY_TRIG  0x25
#define	DWAVE_FLAG          0x26
#define	SPO_FLAG            0x27
#define	SPO_MON_B0_L        0x28
#define	SPO_MON_B0_H        0x29
#define	SPO_MON_B1_L        0x2A
#define	SPO_MON_B1_H        0x2B
#define	SPO_MON_B2_L        0x2C
#define	SPO_MON_B2_H        0x2D
#define	SPO_MON_B3_L        0x2E
#define	SPO_MON_B3_H        0x2F
#define	DAC_A2A3_FLAG       0x30
#define	DAC_BIAS_FLAG       0x31
#define	DAC_TEST_RB1        0x32
#define	DAC_TEST_RB2        0x33
#define	DAC_A2A3_RB21       0x34
#define	DAC_A2A3_RB43       0x35
#define	DAC_BIAS_RB21       0x36
#define	DAC_BIAS_RB43       0x37
#define	ADC_HS_WO           0x38
#define	ADC_BASE_FREQ	      0x39
#define	XADC_TEMP           0x3A
#define	XADC_VOLT           0x3B
#define SPIO_WO				0x3B		//SPIO WO (shared with XADC_VOLT)
#define	ADC_HS_DOUT0        0x3C
#define	ADC_HS_DOUT1        0x3D
#define	ADC_HS_DOUT2        0x3E
#define	ADC_HS_DOUT3        0x3F

#define ADC_FIFO_DIN0		0x3C//, ##$$ assign w_ADC_HS_DOUT0 = (w_ADC_HS_WI[8])? {fifo_adc0_din,14'b0}    : w_acc_flt32_re_dout0;
#define ADC_FIFO_DIN1		0x3D//, ##$$ assign w_ADC_HS_DOUT1 = (w_ADC_HS_WI[8])? {fifo_adc1_din,14'b0}    : w_acc_flt32_im_dout0;
#define DFT_COEF_FLT32_RE	0x3E//, ##$$ assign w_ADC_HS_DOUT2 = (w_ADC_HS_WI[8])? w_dft_coef_flt32_re_dout : w_acc_flt32_re_dout1;
#define DFT_COEF_FLT32_IM	0x3F//, ##$$ assign w_ADC_HS_DOUT3 = (w_ADC_HS_WI[8])? w_dft_coef_flt32_im_dout : w_acc_flt32_im_dout1;
#define ACC_FLT32_VX_RE		0x3C//, ##$$ DFT
#define ACC_FLT32_VX_IM		0x3D//, ##$$ DFT
#define ACC_FLT32_VR_RE		0x3E//, ##$$ DFT
#define ACC_FLT32_VR_IM		0x3F//, ##$$ DFT


// trig-in

#define	TEST_TI             0x40
#define	DWAVE_TI            0x46
#define	DAC_BIAS_TI         0x50
#define	DAC_A2A3_TI         0x51
#define	ADC_HS_TI           0x58
#define SPIO_TI				0x5B	//SPIO TI
#define DFT_TI				0x5C

// trig-out

#define	TEST_TO             0x60
#define	DAC_BIAS_TO         0x70
#define	DAC_A2A3_TO         0x71
#define	ADC_HS_TO           0x78
#define SPIO_TO				0x7B	//SPIO TO

// pipe-out

#define	ADC_HS_DOUT0_PO     0xBC
#define	ADC_HS_DOUT1_PO     0xBD
#define	ADC_HS_DOUT2_PO     0xBE
#define	ADC_HS_DOUT3_PO     0xBF
#define	TEST_CON            0x01
#define	TEST_CC_DIN         0x02
#define	wi03                0x03
#define	DAC_TEST_IN         0x04
#define	DWAVE_DIN_BY_TRIG   0x05
#define	DWAVE_CON           0x06
#define	SPO_CON             0x07
#define	SPO_DIN_B0_L        0x08
#define	SPO_DIN_B0_H        0x09
#define	SPO_DIN_B1_L        0x0A
#define	SPO_DIN_B1_H        0x0B
#define	SPO_DIN_B2_L        0x0C
#define	SPO_DIN_B2_H        0x0D
#define	SPO_DIN_B3_L        0x0E
#define	SPO_DIN_B3_H        0x0F
#define	DAC_A2A3_CON        0x10
#define	DAC_BIAS_CON        0x11
#define	wi12                0x12
#define	wi13                0x13
#define	DAC_A2A3_DIN21      0x14
#define	DAC_A2A3_DIN43      0x15
#define	DAC_BIAS_DIN21      0x16
#define	DAC_BIAS_DIN43      0x17
#define	ADC_HS_WI           0x18
#define	wi19                0x19
#define	wi1A                0x1A
#define	wi1B                0x1B
#define	wi1C                0x1C
#define	ADC_HS_UPD_SMP      0x1D
#define	ADC_HS_SMP_PRD      0x1E
#define	ADC_HS_DLY_TAP_OPT  0x1F

// wire-out

#define	FPGA_IMAGE_ID       0x20
#define	TEST_OUT            0x21
#define	TEST_CC_MON         0x22
#define	DWAVE_BASE_FREQ     0x23
#define	DAC_TEST_OUT        0x24
#define	DWAVE_DOUT_BY_TRIG  0x25
#define	DWAVE_FLAG          0x26
#define	SPO_FLAG            0x27
#define	SPO_MON_B0_L        0x28
#define	SPO_MON_B0_H        0x29
#define	SPO_MON_B1_L        0x2A
#define	SPO_MON_B1_H        0x2B
#define	SPO_MON_B2_L        0x2C
#define	SPO_MON_B2_H        0x2D
#define	SPO_MON_B3_L        0x2E
#define	SPO_MON_B3_H        0x2F
#define	DAC_A2A3_FLAG       0x30
#define	DAC_BIAS_FLAG       0x31
#define	DAC_TEST_RB1        0x32
#define	DAC_TEST_RB2        0x33
#define	DAC_A2A3_RB21       0x34
#define	DAC_A2A3_RB43       0x35
#define	DAC_BIAS_RB21       0x36
#define	DAC_BIAS_RB43       0x37
#define	ADC_HS_WO           0x38
#define	ADC_BASE_FREQ	      0x39
#define	XADC_TEMP           0x3A
#define	XADC_VOLT           0x3B
#define	ADC_HS_DOUT0        0x3C
#define	ADC_HS_DOUT1        0x3D
#define	ADC_HS_DOUT2        0x3E
#define	ADC_HS_DOUT3        0x3F

// trig-in

#define	TEST_TI             0x40
#define	DWAVE_TI            0x46
#define	DAC_BIAS_TI         0x50
#define	DAC_A2A3_TI         0x51
#define	ADC_HS_TI           0x58

// trig-out

#define	TEST_TO             0x60
#define	DAC_BIAS_TO         0x70
#define	DAC_A2A3_TO         0x71
#define	ADC_HS_TO           0x78

// pipe-in
#define MEM_PI				0x93
#define COEF_FLT32_RE_PI	0x9C
#define COEF_FLT32_IM_PI	0x9D

// pipe-out

#define MEM_PO				0xB3
#define	ADC_HS_DOUT0_PO     0xBC
#define	ADC_HS_DOUT1_PO     0xBD
#define	ADC_HS_DOUT2_PO     0xBE
#define	ADC_HS_DOUT3_PO     0xBF


#define spio_reg_adrs_iocon	0x0A
#define spio_reg_adrs_olat	0x14
#define spio_reg_adrs_iodir	0x00
#define spio_reg_adrs_gpio	0x12


