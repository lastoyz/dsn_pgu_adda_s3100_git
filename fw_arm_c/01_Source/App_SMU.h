//******************************************************************************
// File Name: shell.c
// Description: 명령어 처리 스레드
//******************************************************************************

#ifndef	_APP_SMU_H
#define	_APP_SMU_H

#include    "top_core_info.h"
#include 	"UserDefine.h"


#define MIO_SMU_WR			SMU_FPGA_WriteSingle
#define MIO_SMU_RD			SMU_FPGA_ReadSingle
// #define MIO_GNDU_WR			GNDU_FPGA_WriteSingle
// #define MIO_GNDU_RD			GNDU_FPGA_ReadSingle
#define MIO_GNDU_WR			GNDU_FPGA_SPI_WR
#define MIO_GNDU_RD			GNDU_FPGA_SPI_RD

#define MIO_IO_IN_WR		AUX_INPUT_FPGA_WriteSingle
#define MIO_IO_IN_RD		AUX_INPUT_FPGA_ReadSingle
#define MIO_IO_OUT_WR		AUX_OUTPUT_FPGA_WriteSingle
#define MIO_IO_OUT_RD		AUX_OUTPUT_FPGA_ReadSingle
#define MIO_SMU_CMU_IN_WR	SMU_CMU_INPUT_FPGA_WriteSingle
#define MIO_SMU_CMU_IN_RD	SMU_CMU_INPUT_FPGA_ReadSingle
#define MIO_DVM_PGU_IN_WR	DVM_PGU_INPUT_FPGA_WriteSingle
#define MIO_DVM_PGU_IN_RD	DVM_PGU_INPUT_FPGA_ReadSingle


#define CH_SMU1		0  //slot2
#define CH_SMU2		1  //slot3
#define CH_SMU3		2  //slot4
#define CH_SMU4		3  //slot5
#define CH_SMU5		4  //slot6
#define CH_SMU6		5  //slot7
#define CH_SMU7		6  //slot8
#define CH_SMU8		7  //slot9
#define CH_SMU9		8  //slot10
#define CH_SMU10	9  //slot11
#define CH_SMU11	10 //slot12
#define CH_SMU12	11 //slot13


#define CH_AUX_INPUTBD1 0  //slot19
#define CH_AUX_INPUTBD2 1  //slot38
#define CH_AUX_INPUTBD3 2  //slot57

#define CH_IO_INPUT1	0
#define CH_IO_INPUT2	1
#define CH_IO_INPUT3	2

#define NO_OF_SMU	12
//#define CH_GNDU		8
//#define NO_OF_AUX_INPUTBD 3
//#define NO_OF_IO_INPUT	3
#define NO_OF_AUX_INPUTBD 1
#define NO_OF_IO_INPUT	1



#define SMU_MODE_COM    0
#define SMU_MODE_V      1
#define SMU_MODE_I      2 

#define CALIB_MODE_I	1
#define CALIB_MODE_V	2



#define FPGA_BASE_ADDR		FPGA_DEVICE_ADDR		// 0x6000_0000

#define NCS3_BASE_ADDR		FPGA_BASE_ADDR + 0x0C000000		// 0xAB500000

#define MM_AUX_INPUT1_ADDR	(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00000000)) // MM_AUX_INPUT1(nBCS18)
#define GNDU_ADDR			(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00200000)) // MM_I/O_INPUT1(nBCS0)

#define SMU1_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00400000)) // SMU1(nBCS1)
#define SMU2_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00600000)) // SMU2(nBCS2)
#define SMU3_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00800000)) // SMU3(nBCS3)
#define SMU4_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00A00000)) // SMU4(nBCS4)
#define SMU5_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00C00000)) // SMU5(nBCS5)

#define	SMU6_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x00E00000)) // SMU6(nBCS6)
#define SMU7_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01000000)) // SMU7(nBCS7)
#define SMU8_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01200000)) // SMU8(nBCS8)
#define SMU9_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01400000)) // SMU9(nBCS9)
#define SMU10_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01600000)) // SMU10(nBCS10)
#define SMU11_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01800000)) // SMU11(nBCS11) 
#define SMU12_BASE_ADDR		(NCS3_BASE_ADDR + _SHIFT_ADDR(0x01A00000)) // SMU12(nBCS12)   


//2018.12.18 F5500 회로
#define SMU_FPGA_CHECK        0x00000000
#define SMU_FPGA_VER          0x00002000
#define SYS_IF_CHECK		  0x00008000

#define SMU_FPGA_ID           0x00012000
#define SMU_FPGA_RESET        0x000C0000

#define SMU_INPUT_RLY         0x000D0000            //Active High
#define SMU_OUTPUT_RLY        0x000E0000            //Active High
#define SMU_GPIO_CS           0x000F0000

#define SMU_SRANGE_CS         0x00070000			// Write_SMU Vctrl, vsrc, vmsrZ
#define SMU_COMP_SW_CS        0x00060000            // SMU compensation
#define SMU_FPGA_STATE        0x00010000            // read_smu_state(현재 SMU가 전압 컨트롤 모드 인지 전류 컨트롤 모드 인지 판단)
#define SMU_ADC_SEL_SW_CS     0x000A0000			// smu_adc_mux_v(or)i_sel ####

#define SMU_ADC_CNVST_ADDR	  0x00050000			// smu_adc_conv ####
#define SMU_ADC_WRITE_ADDR	  0x00050000

#define SMU_ADC_READ_ADDR	  0x00050000			// smu_adc_acquire_current // smu_adc_voltage ####

#define SMU_IDAC_WRITE_ADDR	  0x00030000			// write_smu_idac(지정한 SMU 보드의 전류 DAC 에 값을 쓰는 루틴)
#define SMU_VDAC_WRITE_ADDR	  0x00040000			// write_smu_vdac(지정한 SMU 보드의 전압 DAC 에 값을 쓰는 루틴)
#define SMU_MRANGE_CS		  0x00080000			// Write SMU Irange Control
#define SMU_IVDAC_Filter_CS   0x00090000			// Write SMU I, V DAC Filter Capacitor S/W Control
#define SMU_IRANGE_CS		  0x000B0000			// Write SMU Irange Control
#define SMU_SEEPROM_CS_ADDR	  0x00020000	        // SMUX_BASE_ADDR + SMU_CS7_ADDR + SMU_SEEPROM_CS_ADDR

//2019.09.26 Per_pin 회로
//#define SMU_ADC_BUSY_ADDR	0x00002000	// SMUX_BASE_ADDR + SMU_CS7_ADDR + SMU_ADC_BUSY
#define SMU_ADC_D_MAX_H_ADDR	0x2000
#define SMU_ADC_D_MAX_L_ADDR	0x4000

#define SMU_ADC_D_MIN_H_ADDR	0x6000
#define SMU_ADC_D_MIN_L_ADDR	0x8000

#define SMU_ADC_D_SUM_H_ADDR	0xA000
#define SMU_ADC_D_SUM_L_ADDR	0xC000
#define SMU_ADC_PLC_INFO		0xE000


//2018.12.18 F5500

//2018.12.18 F5500 회로
#define GNDU_FPGA_CHECK         0x00000000
#define GNDU_FPGA_VER           0x00002000
#define GNDU_FPGA_STATE         0x00010000
#define GNDU_FPGA_ID            0x00012000
#define GNDU_SPROM_CS_ADDR      0x00020000
#define GNDU_DAC_WRITE_ADDR     0x00040000
#define GNDU_ADC_CS_ADDR        0x00050000
#define GNDU_ADC_CNVST_ADDR     0x00050000
#define GNDU_MRANGE_CS          0x00080000
#define GNDU_DIAG_MOD_CON_CS    0x00090000      // EXT, DIAG, 1GU, 1G Realy 설정값을 출력하는 루틴
#define GNDU_ADC_SEL_SW_CS      0x000A0000      // ADC MUX 설정값을 출력하는 루틴
#define GNDU_DIAG_RLY_CS        0x000B0000      // 1K, 100K, 10M, VM Relay 설정값을 출력하는 루틴, // 100, 10K, 1M, 100M Relay 설정값을 출력하는 루틴
#define GNDU_FPGA_RESET         0x000C0000
#define GNDU_INPUT_RLY          0x000D0000
#define GNDU_OUTPUT_RLY         0x000E0000
#define GNDU_GPIO_CS            0x000F0000


#define GNDU_OUTPUT_RLY_TST     0x0000000E



//F5500회로
// Input board define
#define INPUTBD_FPGA_CHECK         0x00000000
#define INPUTBD_FPGA_VER           0x00002000
#define INPUTBD_FPGA_STATE         0x00010000
#define INPUTBD_FPGA_ID            0x00012000
#define INPUTBD_VFORCE_RLY         0x000B0000
#define INPUTBD_FPGA_RESET         0x000C0000
#define INPUTBD_INPUT_RLY          0x000D0000            //Active High
#define INPUTBD_CMU_RLY            0x000E0000
#define INPUTBD_GPIO_CS            0x000F0000

#define TEG_SMU_V10	0x10

#define SMU_ICTRL_XORMASK	0x0000003D
#define SMU_VCTRL_XORMASK	0xFFFF
//#define SMU_COMP_CTRL_XORMASK	0x03
#define SMU_COMP_CTRL_XORMASK	0x01 // 5M_COMP 는 Active High이다.

#define NO_OF_VRANGE     5

// sbcho@20211217 HVSMU
#define SMU_2V_RANGE	  0
#define SMU_5V_RANGE	  1
#define SMU_20V_RANGE	  2
#define SMU_40V_RANGE	  3
#define SMU_200V_RANGE	  4

#define SMU_VCTRL_SRC_MASK  0x00FF
#define SMU_VCTRL_MSR_MASK	0xFF00

// sbcho@20211108 HVSMU
#define SMU_2V_CTRL			0x0000              // Close loop
#define SMU_5V_CTRL			0x0101
#define SMU_20V_CTRL		0x0202
#define SMU_40V_CTRL	    0x0404
#define SMU_200V_CTRL	    0x0808

#define SMU_IX10_COMP		0x01
#define SMU_5M_COMP			0x02


#define NO_OF_IRANGE        12
#define SMU_10pA_RANGE	    0 	// HVSMU used
#define SMU_100pA_RANGE	    1   // HVSMU used
#define SMU_1nA_RANGE	    2   // 0.000000001  1E-9   10G 
#define SMU_10nA_RANGE	    3   // 0.00000001   1E-8   1G  
#define SMU_100nA_RANGE     4   // 0.0000001    1E-7   100M
#define SMU_1uA_RANGE	    5   // 0.000001     1E-6   10M 
#define SMU_10uA_RANGE	    6   // 0.00001      1E-5   1M  
#define SMU_100uA_RANGE     7   // 0.0001       1E-4   100K
#define SMU_1mA_RANGE	    8   // 0.001        1E-3   10K
#define SMU_10mA_RANGE	    9   // 0.01         1E-2   1K
#define SMU_100mA_RANGE     10  // 0.1          1E-1   100
#define SMU_1A_RANGE	    11	// not used

#define SMU_UPPER_LEAK_IRANGE	SMU_10nA_RANGE

// sbcho@20211217 HVSMU
#define SMU_ICTRL_MASK  		0x00F7FF
#define SMU_ICTRL_IX10_MASK		0x000003
#define SMU_ICTRL_RAMP_MASK		0x0000FC

// sbcho@20211217 HVSMU
#define SMU_ICTRL_RELAY_MASK	0x00F000
#define SMU_ICTRL_MJFET_MASK	0x000700

#define SMU_ICTRL_IX10		0x000002
#define SMU_ICTRL_IX10_BAR	0x000002

//2018.12.18 F5500 회로
#define SMU_ICTRL_DIAG		0x004000

//2021.10.12 HLSMU 회로
#define SMU_GUARD_REL	    	0x0001
#define SMU_FOCE_REL	    	0x0002
#define SMU_DIAG_REL			0x0004

// reseved for remove
#define SMU_L_C_RELAY           0x0010            // AUX1 input relay POGO pin path
#define SMU_SMU_IN_RELAY        0x0024            // AUX2 input relay CMU SMU path
#define SMU_C_L_RELAY           0x0021            // AUX3 input relay CMU L path
#define SMU_C_H_RELAY           0x0022            // AUX4 input relay CMU H path
#define SMU_SIG_GND_RELAY	    0x00A0            // input relay singal ground relay
#define SMU_GRD_GND_RELAY	    0x0060            // input relay guard ground relay

#define SMU_VDAC_FIL_1NF		0x0001
#define SMU_VDAC_FIL_10NF		0x0002
#define SMU_IDAC_FIL_1NF		0x0004
#define SMU_IDAC_FIL_10NF		0x0008


#define SMU_ICTRL_INIT		0x000000

//#define SMU_100mA_CTRL	0x03013F
//#define SMU_10mA_CTRL	0x030238
//#define SMU_1mA_CTRL	0x03023B
//#define SMU_100uA_CTRL	0x030430
//#define SMU_10uA_CTRL	0x030433
//#define SMU_1uA_CTRL	0x020420
//#define SMU_100nA_CTRL	0x020423
//#define SMU_10nA_CTRL	0x000400
//#define SMU_1nA_CTRL	0x000403

//sbcho@20211217 HVSMU
#define SMU_100mA_CTRL	0x00F1FF
#define SMU_10mA_CTRL	0x00F2F8
#define SMU_1mA_CTRL	0x00F2FA
#define SMU_100uA_CTRL	0x00F4F1
#define SMU_10uA_CTRL	0x00F4F2
#define SMU_1uA_CTRL	0x00E4E0
#define SMU_100nA_CTRL	0x00E4E3
#define SMU_10nA_CTRL	0x00C4C0
#define SMU_1nA_CTRL	0x00C4C3
#define SMU_100pA_CTRL	0x008483
#define SMU_10pA_CTRL	0x000403

#define SMU_ICTRL_5G_RAMP	0x000080
#define SMU_ICTRL_500M_RAMP	0x000040
#define SMU_ICTRL_5M_RAMP	0x000020 
#define SMU_ICTRL_50K_RAMP	0x000010 
#define SMU_ICTRL_500_RAMP	0x000008
#define SMU_ICTRL_5_RAMP	0x000004

#define SMU_STATE_VMODE	 0x03
#define SMU_STATE_MASK	 0x03

// sbcho@20211108 HLSMU
// #define MAX_DAC_IN_VALUE    32767
// #define MIN_DAC_IN_VALUE    -32768

#define MAX_DAC_IN_VALUE    2147483647
#define MIN_DAC_IN_VALUE    -2147483648

#define RANGE_AUTO			    'A'
#define RANGE_FIXED			    'F'
#define RANGE_LIMITED_AUTO  	'L'
#define RANGE_CURRENT		    'C'

#define RANGE_YET           0
#define RANGE_DISABLE       1
#define RANGE_UP            2
#define RANGE_DOWN          3
#define RANGE_DOWN_2STEP	4

// #define RANGE_UP_VOLT       4.4  //4.4>4.6 20110225 cjh 
// #define RANGE_DOWN_VOLT     0.4

#define OSC_DETECT_PTP_VOLT 0.5  

#define AVG_SHORT_MODE       0 
#define AVG_MEDIUM_MODE     -1    
#define AVG_LONG_MODE       -2  

#define AVG_CNT_SHORT   16
#define AVG_CNT_MEDIUM  64
#define AVG_CNT_LONG    128

//#define GNDU_200mV_RANGE	0	// not used
//#define GNDU_2V_RANGE		1
//#define GNDU_20V_RANGE		2
//#define GNDU_40V_RANGE		3
//#define GNDU_100V_RANGE		4

//2018.12.18 F5500 회로
#define GNDU_500mV_RANGE	0	// Close Loop
#define GNDU_2V_RANGE		1
#define GNDU_5V_RANGE		2
#define GNDU_20V_RANGE		3
#define GNDU_40V_RANGE		4
#define GNDU_100V_RANGE		5


#define GNDU_VMSR_CTRL_MASK	0x0F
//2018.12.18 F5500 회로
#define GNDU_MUX_CTRL_MASK	0x0F

#define GNDU_MUX_DIAG_ADCIN	1
#define GNDU_MUX_AGND		2
#define GNDU_MUX_5V_REF		3
#define GNDU_MUX_GND_ADCIN	4

#define GNDU_VMSR_MUX_CTRL_XORMASK	  0xFF
#define GNDU_RELAY_CTRL1_XORMASK	  0x00
#define GNDU_RELAY_CTRL2_XORMASK	  0x00
#define GNDU_RELAY_CTRL3_XORMASK	  0x00
#define GNDU_RELAY_CTRL4_XORMASK	  0x00

//#define GNDU_2V_MSR_CTRL	  0x01
//#define GNDU_20V_MSR_CTRL	  0x02
//#define GNDU_40V_MSR_CTRL	  0x04
//#define GNDU_100V_MSR_CTRL	  0x08

//2018.12.18 F5500 회로
#define GNDU_500mV_MSR_CTRL	  0x00
#define GNDU_2V_MSR_CTRL	  0x01
#define GNDU_5V_MSR_CTRL	  0x02
#define GNDU_20V_MSR_CTRL	  0x04
#define GNDU_40V_MSR_CTRL	  0x08
#define GNDU_100V_MSR_CTRL	  0x10

//#define GNDU_100_RELAY  0x01
//#define GNDU_1K_RELAY   0x01
//#define GNDU_10K_RELAY	0x02
//#define GNDU_100K_RELAY	0x02
//#define GNDU_1M_RELAY	0x04
//#define GNDU_10M_RELAY	0x04
//#define GNDU_100M_RELAY	0x08
//#define GNDU_VM_RELAY	0x08
//#define GNDU_EXT_RELAY	0x01
//#define GNDU_DIAG_RELAY	0x02
//#define GNDU_1GU_RELAY	0x04
//#define GNDU_1G_RELAY	0x08
//
////2017.12.19 추가, GNDU Output Relay
//#define GNDU_S_RELAY	0x10
//#define GNDU_F_RELAY	0x20

//2018.12.18 F5500 회로
#define GNDU_100_RELAY          0x01
#define GNDU_1K_RELAY           0x02
#define GNDU_10K_RELAY	        0x04
#define GNDU_100K_RELAY	        0x08
#define GNDU_1M_RELAY	        0x10
#define GNDU_10M_RELAY	        0x20
#define GNDU_100M_RELAY	        0x40
#define GNDU_VM_RELAY	        0x80
#define GNDU_EXT_RELAY	        0x01

#define GNDU_1GU_RELAY	        0x04
#define GNDU_1G_RELAY	        0x08

#define GNDU_F_RELAY	        0x10
#define GNDU_S_RELAY	        0x20

#define GNDU_L_C_RELAY          0x10            // input relay POGO pin path
#define GNDU_C_H_RELAY          0x22            // input relay CMU H path
#define GNDU_C_L_RELAY          0x21            // input relay CMU L path
#define GNDU_SMU_IN_RELAY       0x24            // input relay SMU mother board path
#define GNDU_SIG_GND_RELAY	    0x80            // input relay singal ground relay
#define GNDU_GRD_GND_RELAY	    0x40            // input relay guard ground relay

#define GNDU_SEEPROM_CS	        0x80


//INPUT BD RELAY 제어
#define INPUTBD_VFORCE_SIG_RELAY 0x0002
#define INPUTBD_VFORCE_GRD_RELAY 0x0001

#define INPUTBD_AUX1_RELAY      0x0010            // AUX1
#define INPUTBD_AUX2_RELAY		0x0020            // AUX2
#define INPUTBD_AUX3_RELAY		0x0004            // AUX3
#define INPUTBD_AUX4_RELAY		0x0002            // AUX4
#define INPUTBD_AUX5_RELAY		0x0001            // AUX5

// SIGNAL GUARD L_H SHORT RELAY
#define INPUTBD_AUX2_3_SIG_SHORT_RELAY	0x0200
#define INPUTBD_AUX2_3_GRD_SHORT_RELAY	0x0100
#define INPUTBD_AUX4_5_SIG_SHORT_RELAY	0x0020
#define INPUTBD_AUX4_5_GRD_SHORT_RELAY	0x0010

// SIGNAL GURAD L_H GROUND RELAY
#define INPUTBD_AUX1_SIG_GND_RELAY	 0x0080
#define INPUTBD_AUX1_GRD_GND_RELAY	 0x0040

#define INPUTBD_AUX2_SIG_GND_RELAY	 0x0080
#define INPUTBD_AUX2_GRD_GND_RELAY	 0x0040
#define INPUTBD_AUX3_SIG_GND_RELAY	 0x0800
#define INPUTBD_AUX3_GRD_GND_RELAY	 0x0400

#define INPUTBD_AUX4_SIG_GND_RELAY	 0x0008		//AUX4와 AJUX5를 변경해야함
#define INPUTBD_AUX4_GRD_GND_RELAY	 0x0004
#define INPUTBD_AUX5_SIG_GND_RELAY	 0x0002
#define INPUTBD_AUX5_GRD_GND_RELAY	 0x0001


//E5000 수정(2020.03.20_조성범)
// 각 보드 RELAY제어관련 bit masking
#define SMU_IN_RLY_MASK					0x00F7
#define SMU_OUT_RLY_MASK				0x0033
#define GNDU_IN_RLY_MASK				0x00F7
#define GNDU_OUT_RLY_MASK				0x0030
#define AUX_OUTPUTBD_OUT_RLY_MASK		0x0FFF
#define AUX_INPUTBD_IN_RLY_MASK			0x03F7
#define AUX_INPUTBD_CMU_RLY_MASK		0x3F3F
#define AUX_INPUTBD_VFORCE_RLY_MASK		0x0003
#define SMU_CMU_INPUTBD_IN_RLY_MASK		0x00FF
#define DVM_PGU_INPUTBD_IN_RLY_MASK		0x03FF


#define SAMPLES_PER_1PLC    64

typedef struct 
{
	bool used;
	bool is_measure;
	int mode;
	int base_addr;
	char state;

	float src_val;
	float limit_val;
    int   limit_i_rng;
	int   limit_v_rng;
	
	float imsr_val;
	float vmsr_val;

	int src_rng;
	int msr_rng; //2015.12.22
	short msr_max_rng;
    short msr_min_rng;
   
	int min_vrange;
	int max_vrange;

	int min_imsr_range;
	int max_imsr_range;
	int min_isrc_range;
	int max_isrc_range;

	int ictrl;
	int vctrl;
	int comp_ctrl;

	int idac_in_val;
	int vdac_in_val;

	int imsr_rng;
	int vmsr_rng;
	short imsr_max_rng;
    short imsr_min_rng;
	short vmsr_max_rng;
    short vmsr_min_rng;

	// StaClients 용 추가
	// 2015.12.22
	float base;
	UINT32 width;
	UINT32 period;
	BOOL sweep_measured;

    // sbcho@20211108 HLSMU
    UINT16 diag_relay_ctrl;
    UINT16 force_relay_ctrl;

	UINT16 iv_dac_filter_ctrl;
	UINT16 adc_plc_info;

}TSmuCtrlReg;


typedef struct 
{
	bool used;
	int base_addr;

	float msr_val;
	
	int min_vrange;
	int max_vrange;
	
    UINT16 diag_Rrange_relay_ctrl;
    UINT16 diag_mod_relay_ctrl;
    UINT16 output_relay_ctrl;
    UINT16 input_relay_ctrl;

	UINT8 vmsr_mux_ctrl;
	
	int vmsr_rng;
		
	int dac_in_val;

	UINT16 SLOT_CS;
	UINT16 CH_OFFSET;

}TGnduCtrlReg;

typedef struct 
{
    int base_addr;

    UINT16 input_relay_ctrl;
    UINT16 cmu_relay_ctrl;
	UINT16 diag_force_ctrl;

}TInputBdCtrlReg;

typedef struct 
{
    int base_addr;

}TIOinputCtrlReg;

typedef struct 
{
    int base_addr;
	UINT16 aux_output_relay_ctrl;

}TAuxoutputCtrlReg;

typedef struct 
{
    int base_addr;
	UINT16 smu_cmu_input_relay_ctrl;

}TSmucmuinputCtrlReg;

typedef struct 
{
    int base_addr;
	UINT16 dvm_pgu_input_relay_ctrl;

}TDvmpguinputCtrlReg;


typedef struct 
{
   int vctrl;
   int ictrl;
   int comp_ctrl;
}TSmuCtrl;


typedef struct 
{
    INT32 smu_vdac_in_val[NO_OF_SMU];
    INT32 smu_idac_in_val[NO_OF_SMU];
    INT32 gndu_dac_in_val;
    
    float smu_vdac_out_val[NO_OF_SMU];
    float smu_idac_out_val[NO_OF_SMU];
    float gndu_dac_out_val;
}TDacValues;


typedef struct {
    INT32 smu_vadc[NO_OF_SMU];
    INT32 smu_iadc[NO_OF_SMU];
    INT32 gndu_adc;
}TAdcValuesInt;

typedef struct {
    float smu_vadc_out_val[NO_OF_SMU];
    float smu_iadc_out_val[NO_OF_SMU];
    float gndu_adc_out_val;
}TAdcValues;


typedef struct {
    UINT32 smu_imsr_change[NO_OF_IRANGE];
    UINT32 smu_isrc_change[NO_OF_IRANGE];

    UINT32 smu_imsr_range[NO_OF_IRANGE];
    UINT32 smu_isrc_range[NO_OF_IRANGE];
} TDelayCtrlReg;


typedef struct { 
	UINT32 average_short[NO_OF_IRANGE];
    UINT32 average_medium[NO_OF_IRANGE];
    UINT32 average_long[NO_OF_IRANGE];
} TAverageCountReg;



typedef struct {
    int ch;
    int calib_mode;  // 'V'/'I' calibration
    int smu_mode;
    int src_rng;
    int msr_rng;
    float start;
    float step;
    UINT32 no_step;
    UINT32 count;
    UINT32 hold;
    UINT32 delay;
    BOOL extern_trig;
    BOOL use_gndu;      // use resistor box
    BOOL dut_on;        // measure on dut 
} TCalibMeasReg;

typedef union meas_send
{
	char cVal[40];
	float fVal[10];
}meas_send;

// typedef struct{

// 	int ch;
// 	int block;
// } TSmuChSel

//////////////// Ideal Gains /////////////////////
extern float smu_vsrc_ideal_gain[NO_OF_SMU][NO_OF_VRANGE];  
extern float smu_vmsr_ideal_gain[NO_OF_SMU][NO_OF_VRANGE];

extern float smu_isrc_ideal_gain[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_imsr_ideal_gain[NO_OF_SMU][NO_OF_IRANGE];

extern float smu_irng_up_volt[NO_OF_IRANGE];
extern float smu_irng_down_volt[NO_OF_IRANGE];
extern float smu_irng_2down_volt[NO_OF_IRANGE];

extern float gndu_vsrc_ideal_gain; 
extern float gndu_vmsr_ideal_gain[NO_OF_VRANGE];

//////////////// Calibration Parameter ///////////////////
extern float adc_gain;
extern float adc_offset;

extern float smu_vsrc_gain_calib[NO_OF_SMU][NO_OF_VRANGE], smu_vsrc_offset_calib[NO_OF_SMU][NO_OF_VRANGE];
extern float smu_vmsr_gain_calib[NO_OF_SMU][NO_OF_VRANGE], smu_vmsr_offset_calib[NO_OF_SMU][NO_OF_VRANGE];

extern float smu_ipsrc_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_ipsrc_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_insrc_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_insrc_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_ipmsr_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_ipmsr_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_inmsr_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_inmsr_offset_calib[NO_OF_SMU][NO_OF_IRANGE];

extern float gndu_vsrc_gain_calib, gndu_vsrc_offset_calib;
extern float gndu_vmsr_gain_calib[NO_OF_VRANGE], gndu_vmsr_offset_calib[NO_OF_VRANGE];

////////////////// Calibration Factor //////////////////////
extern float smu_vsrc_real_gain[NO_OF_SMU][NO_OF_VRANGE], smu_vsrc_offset[NO_OF_SMU][NO_OF_VRANGE];
extern float smu_vmsr_real_gain[NO_OF_SMU][NO_OF_VRANGE], smu_vmsr_offset[NO_OF_SMU][NO_OF_VRANGE];

extern float smu_ipsrc_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_ipsrc_offset[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_insrc_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_insrc_offset[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_ipmsr_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_ipmsr_offset[NO_OF_SMU][NO_OF_IRANGE];
extern float smu_inmsr_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_inmsr_offset[NO_OF_SMU][NO_OF_IRANGE];

extern float smu_imsr_leak_gain[NO_OF_SMU][SMU_UPPER_LEAK_IRANGE+1];

extern float gndu_vsrc_real_gain, gndu_vsrc_offset;
extern float gndu_vmsr_real_gain[NO_OF_VRANGE], gndu_vmsr_offset[NO_OF_VRANGE];

extern BOOL without_smu_vsrc;
extern BOOL without_smu_vmsr;
extern BOOL without_smu_isrc;
extern BOOL without_smu_imsr;
extern BOOL without_vsu_vsrc;
extern BOOL without_vmu_vmsr;
extern BOOL without_gndu_vsrc;    
extern BOOL without_gndu_vmsr;

////////////////// Power Line Frequency //////////////////////
extern UINT8 smu_pwr_line_freq;

extern TGnduCtrlReg gndu_ctrl_reg;
extern TInputBdCtrlReg AUX_inputbd_ctrl_reg[NO_OF_AUX_INPUTBD];
extern TAdcValues adc_val_reg;
extern TDelayCtrlReg delay_reg;
extern TAverageCountReg average_cnt_reg;
extern TAuxoutputCtrlReg aux_output_ctrl_reg; //(2020.03.18_윤상훈)
extern TSmucmuinputCtrlReg smu_cmu_input_ctrl_reg; //(2020.03.18_윤상훈)
extern TDvmpguinputCtrlReg dvm_pgu_input_ctrl_reg; //(2020.03.18_윤상훈)

extern TCalibMeasReg calib_meas_reg;


extern INT32  smu_vadc_values[NO_OF_SMU]; 
extern INT32  smu_iadc_values[NO_OF_SMU];
extern INT32  gndu_adc_value;

extern TDacValues dac_val_reg; // 전역변수로 선언
extern TSmuCtrlReg smu_ctrl_reg[NO_OF_SMU];

extern meas_send msr_val_union;

extern nand_addr_t nand_plc_addr;
extern nand_addr_t nand_gnduCal_addr;
extern nand_addr_t nand_gnduZeroCal_addr;
extern nand_addr_t nand_smuCal_addr;
extern nand_addr_t nand_smuZeroCal_addr;

//TDacValues dac_val_reg; // 전역변수로 선언
//TSmuCtrlReg smu_ctrl_reg[NO_OF_SMU];
//TIOinputCtrlReg io_input_ctrl_reg[NO_OF_IO_INPUT];  //(2020.02.18_윤상훈)
//TGnduCtrlReg gndu_ctrl_reg;
//TInputBdCtrlReg AUX_inputbd_ctrl_reg[NO_OF_AUX_INPUTBD];
//TAdcValues adc_val_reg;
//TAuxoutputCtrlReg aux_output_ctrl_reg; //(2020.03.18_윤상훈)
//TSmucmuinputCtrlReg smu_cmu_input_ctrl_reg; //(2020.03.18_윤상훈)
//TDvmpguinputCtrlReg dvm_pgu_input_ctrl_reg; //(2020.03.18_윤상훈)







#ifdef __cplusplus
extern "C" {
#endif 

	void init_module(void);
	void init_smu_adc_mux(void);
	void smu_adc_mux_v_sel(int smu_ch);
	void smu_adc_mux_no_sel(int smu_ch);
	void smu_adc_mux_v_sel_all(void);
	void smu_adc_mux_i_sel(int smu_ch);
	void smu_adc_mux_i_sel_all(void);
	
	void calculate_dac_out_val_all(void);
	void calculate_dac_out_val(int smu_ch);
	float calculate_smu_idac_out_val(int smu_ch, int i_range, float dut_out_val);
	float calculate_smu_vdac_out_val(int smu_ch, int v_range, float dut_out_val);
	int get_smu_vrng(int smu_ch, float val);
	int get_gndu_vrng(float val);
	void start_smu_dac_all(void);
	void start_smu_dac(int smu_ch);
	void start_smu_vdac(int smu_ch);
	void start_smu_idac(int smu_ch);
	
	//INT16 calculate_dac_in_val(float dac_out_val);
	INT32 calculate_dac_in_val(float dac_out_val);
	void write_smu_vdac(int smu_ch, INT32 vdac_in_val);
	void write_smu_idac(int smu_ch, INT32 idac_in_val);
	void write_smu_vctrl(int smu_ch, UINT16 vctrl);
	void write_smu_comp_ctrl(int smu_ch, UINT8 comp_ctrl);
	void write_smu_ictrl(int smu_ch, UINT32 ictrl);
	void write_smu_ictrl_init(int smu_ch, UINT32 ictrl);
	UINT16 to_smu_vctrl(int vrange);
	TSmuCtrl to_smu_isrc_ctrl(int smu_ch, int irange);
	TSmuCtrl to_smu_imsr_ctrl(int smu_ch, int irange);
	void change_smu_ictrl(int smu_ch, UINT32 ictrl);
	void change_smu_ictrl_multi(int selectCnt, int *p_ch, TSmuCtrl *ictrl);
	void change_smu_isrc_range(int smu_ch, int irange);
	void change_smu_imsr_range(int smu_ch, int irange);
	void change_smu_imsr_range_multi(int selectCnt, int *p_ch, TSmuCtrlReg *irange);
	void write_smu_isrc_range(int smu_ch, int irange);
	void write_smu_imsr_range(int smu_ch, int irange);
	void write_smu_vrange(int smu_ch, int range);
	void smu_adc_conv_start(int smu_ch);
	// void smu_adc_conv_start_all(void);
	
	float get_smu_vmax(int smu_ch, int rng);
	float get_smu_vmin(int smu_ch, int rng);
	float get_smu_imax(int ch, int rng);
	float get_smu_imin(int ch, int rng);
	BOOL is_smu_vrng(int smu_ch, int rng, float val);
	BOOL is_smu_irng(int smu_ch, int rng, float val);
	int get_smu_imsr_rng(int smu_ch, float val);
	int get_smu_isrc_rng(int smu_ch, float val);
	
	void init_smu_ctrl_reg(void); 
	void init_smu_ctrl(void); 
	//void init_calibration_param(void);
	void init_calib(void);
	void init_ideal_gain(void);
	void smu_clear_calib_para_all(void);
	void smu_clear_calib_para(int ch);
	void load_calib_para(void);
	void scan_frame_slot(void);
	BOOL search_board_init(u8 slot, u32 bdid);
	void load_calib_para_flash(void);
	void calculate_calib(void);
	
	float get_smu_vdut(int ch, int rng, float adc);
	float get_smu_idut(int ch, int rng, float adc);
	float get_smu_idut_leak(int ch, int rng, float adc, float vdut);
	
	float adcval_to_float(INT32 adc_val);
	// void smu_adc_meas_cnt_send(int ch, int meas_cnt);
	void init_delay_ctrl_reg();
	void init_average_count_reg();
	char read_smu_state(int ch);
	void smu_adc_all();
	
	int read_smu_vrange(int smu_ch);
	int read_smu_irange(int smu_ch);
	
	int to_smu_vrange(int smu_ch, UINT16 vctrl);
	int to_smu_irange(int smu_ch, UINT32 ictrl);
	
	UINT16 to_smu_vsrc_ctrl(int vrange);
	UINT16 to_smu_vmsr_ctrl(int vrange);
	void smu_adc_current(int ch);
	void smu_adc_current_all(void);
	void smu_adc_voltage(int ch);
	void smu_adc_voltage_all(void);
	void smu_seeprom_cs_on(int ch);
	void smu_seeprom_cs_off(void);
	
	//E5000 추가
	//EEPROM제어용 IO_OUTPUT보드 제어 함수(2020.03.20_조성범)
	void io_eeprom_sequence(int ch);
	void io_output1_eeprom_cs_on();
	void io_output2_eeprom_cs_on();
	void io_output3_eeprom_cs_on();
	void io_output_eeprom_cs_init();
	
	void smu_diag_on(int ch);
	void smu_diag_off(int ch);
	
	//2015.12.22
	void smu_force_rly_on(int ch);
	void smu_force_rly_off(int ch);
	//2018.12.18 F5500
	// void smu_input_rly_ctrl(int ch, int rly_ctrl);
	void smu_force_rly_ctrl(int ch, int rly_ctrl);
	void smu_iv_dac_filter_ctrl(int ch, int filter_ctrl);
	void smu_rly_all_off(int ch);
	
	/////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////
	void init_gndu_ctrl_reg(void);
	void gndu_clear_calib_para(void);
	void write_gndu_vmsr_range(int range);
	UINT8 to_gndu_vmsr_ctrl(int vrange);
	void write_gndu_vmsr_ctrl(UINT8 vmsr_ctrl);
	void write_gndu_mux_ctrl(UINT8 mux_ctrl);
	//void write_gndu_relay_ctrl1(UINT8 relay_ctrl1);
	//void write_gndu_relay_ctrl2(UINT8 relay_ctrl2);
	//void write_gndu_relay_ctrl3(UINT8 relay_ctrl3);
	//2018.12.18 F5500 회로
	void write_gndu_diag_relay_ctrl(UINT8 relay_ctrl);
	void write_gndu_diag_mod_relay_ctrl(UINT8 diag_relay_ctrl);
	void write_gndu_out_relay_ctrl(UINT8 out_relay_ctrl);
	void write_gndu_in_relay_ctrl(UINT8 in_relay_ctrl);
	
	
	void gndu_100_relay_on(void);
	void gndu_1K_relay_on(void);
	void gndu_10K_relay_on(void);
	void gndu_100K_relay_on(void);
	void gndu_1M_relay_on(void);
	void gndu_10M_relay_on(void);
	void gndu_100M_relay_on(void);
	void gndu_1G_relay_on(void);
	void gndu_1GU_relay_on(void);
	void gndu_ext_relay_on(void);
	void gndu_diag_pogo_relay_on(void);
	void gndu_diag_conn_relay_on(void);
	void gndu_vm_relay_on(void);
	void gndu_100_relay_off(void);
	void gndu_1K_relay_off(void);
	void gndu_10K_relay_off(void);
	void gndu_100K_relay_off(void);
	void gndu_1M_relay_off(void);
	void gndu_10M_relay_off(void);
	void gndu_100M_relay_off(void);
	void gndu_1G_relay_off(void);
	void gndu_1GU_relay_off(void);
	void gndu_vm_relay_off(void);
	void gndu_ext_relay_off(void);
	void gndu_diag_pogo_relay_off(void);
	void gndu_diag_conn_relay_off(void);
	
	//2017.12.19 추가
	void gndu_s_relay_on(void);
	void gndu_s_relay_off(void);
	void gndu_f_relay_on(void);
	void gndu_f_relay_off(void);
	
	//2018.12.18 F5500 회로
	void gndu_vm_500mV_range(void);
	void gndu_vm_2V_range(void);
	//2018.12.18 F5500 회로
	void gndu_vm_5V_range(void);
	void gndu_vm_20V_range(void);
	void gndu_vm_40V_range(void);
	void gndu_vm_100V_range(void);
	void gndu_adc_mux_diag_sel(void);
	void gndu_adc_mux_agnd_sel(void);
	void gndu_adc_mux_5VREF_sel(void);
	void gndu_adc_mux_gnd_adcin_sel(void);
	void get_gndu_adc_value(void);
	float get_gndu_vm(int rng, float adc);
	void init_gndu_adc_mux(void);
	void gndu_adc_conv_start(void);
	float get_gndu_vmax(int rng);
	float get_gndu_vmin(int rng);
	BOOL is_gndu_vrng(int rng, float val);
	int get_gndu_vrng(float val);
	int read_gndu_vrange(void);
	int to_gndu_vrange(UINT8 vctrl);
	void start_gndu_dac(void);
	void write_gndu_dac(INT32 dac_in_val);
	float calculate_gndu_dac_out_val(void);
	void gndu_seeprom_cs_on();
	void gndu_seeprom_cs_off();
	void gndu_rly_all_off();
	
	void read_plf_info(void);
	BOOL write_plf_info(void);
	void load_plf_info(UINT8 freq);

	void SmuInit(void);
	
	//float get_smu_idut_debug(int ch, int rng, float adc);
	
	void Unit_FPGA_Read(vu16 *addr, u32 *pData, u32 length);
	void Unit_FPGA_Write(vu16 *addr, u32 *pData, u32 length);
	u32 SMU_FPGA_ReadSingle(u32 ch, u32 addr);
	void SMU_FPGA_WriteSingle(u32 ch, u32 addr, u32 data);
	u32 GNDU_FPGA_ReadSingle(u32 addr);
	void GNDU_FPGA_WriteSingle(u32 addr, u32 data);

	u32 GNDU_FPGA_SPI_RD(u32 addr);
	void GNDU_FPGA_SPI_WR(u32 addr, u32 data);
    
    void TestFunction1(float dat_float);
	float TestFunction2();
	float TestFunction3(float dat_float);

	u32 hvsmu_HRADC_enable(u32 ch);
	u32 hvsmu_V_DAC_reset(u32 ch);
	u32 hvsmu_I_DAC_reset(u32 ch);
	u32 hvsmu_V_DAC_init(u32 ch);
	u32 hvsmu_I_DAC_init(u32 ch);
	void hvsmu_V_DAC__trig_rst(u32 ch);
	void hvsmu_I_DAC__trig_rst(u32 ch);
	void hvsmu_V_DAC__trig_clr(u32 ch);
	void hvsmu_I_DAC__trig_clr(u32 ch);
	void hvsmu_V_DAC__trig_frame(u32 ch);
	void hvsmu_I_DAC__trig_frame(u32 ch);
	void hvsmu_V_DAC__trig_nop(u32 ch);
	void hvsmu_I_DAC__trig_nop(u32 ch);
	u32 hvsmu_V_DAC__sub_trig_check(u32 ch, u32 bit_loc);
	u32 hvsmu_I_DAC__sub_trig_check(u32 ch, u32 bit_loc);
	u32 hvsmu_V_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20);
	u32 hvsmu_I_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20);
	u32 hvsmu_V_DAC_reg_get(u32 ch, u32 adrs_b3);
	u32 hvsmu_I_DAC_reg_get(u32 ch, u32 adrs_b3);
	void hvsmu_V_DAC__set_mosi(u32 ch, u32 val_u32);
	void hvsmu_I_DAC__set_mosi(u32 ch, u32 val_u32);
	u32 hvsmu_V_DAC__get_miso(u32 ch);
	u32 hvsmu_I_DAC__get_miso(u32 ch);
	void hvsmu_I_DAC__trig_ldac(u32 ch);
	void hvsmu_V_DAC__trig_ldac(u32 ch);
	


#ifdef __cplusplus
}
#endif 

#endif /* #ifndef SMU_H */


