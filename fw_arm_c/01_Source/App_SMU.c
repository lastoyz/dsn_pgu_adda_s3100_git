//******************************************************************************
// File Name: App_SMU.c
// Description: 명령어 처리 스레드
//******************************************************************************

#include "App_SMU.h"

#include "App_teginfo.h"


/////////////////////////////////////////////////////////////////////////////////////////////////////
// Ideal Gains
/////////////////////////////////////////////////////////////////////////////////////////////////////
float smu_vsrc_ideal_gain[NO_OF_SMU][NO_OF_VRANGE];  
float smu_vmsr_ideal_gain[NO_OF_SMU][NO_OF_VRANGE];

float smu_isrc_ideal_gain[NO_OF_SMU][NO_OF_IRANGE];  
float smu_imsr_ideal_gain[NO_OF_SMU][NO_OF_IRANGE];

float smu_irng_up_volt[NO_OF_IRANGE];
float smu_irng_down_volt[NO_OF_IRANGE];
float smu_irng_2down_volt[NO_OF_IRANGE];

float gndu_vsrc_ideal_gain; 
float gndu_vmsr_ideal_gain[NO_OF_VRANGE];

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Calibration Parameter 
/////////////////////////////////////////////////////////////////////////////////////////////////////
float adc_gain;
float adc_offset;

float smu_vsrc_gain_calib[NO_OF_SMU][NO_OF_VRANGE], smu_vsrc_offset_calib[NO_OF_SMU][NO_OF_VRANGE];
float smu_vmsr_gain_calib[NO_OF_SMU][NO_OF_VRANGE], smu_vmsr_offset_calib[NO_OF_SMU][NO_OF_VRANGE];

float smu_ipsrc_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_ipsrc_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
float smu_insrc_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_insrc_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
float smu_ipmsr_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_ipmsr_offset_calib[NO_OF_SMU][NO_OF_IRANGE];
float smu_inmsr_gain_calib[NO_OF_SMU][NO_OF_IRANGE], smu_inmsr_offset_calib[NO_OF_SMU][NO_OF_IRANGE];

float gndu_vsrc_gain_calib, gndu_vsrc_offset_calib;
float gndu_vmsr_gain_calib[NO_OF_VRANGE], gndu_vmsr_offset_calib[NO_OF_VRANGE];

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Calibration Factor
/////////////////////////////////////////////////////////////////////////////////////////////////////
float smu_vsrc_real_gain[NO_OF_SMU][NO_OF_VRANGE], smu_vsrc_offset[NO_OF_SMU][NO_OF_VRANGE];
float smu_vmsr_real_gain[NO_OF_SMU][NO_OF_VRANGE], smu_vmsr_offset[NO_OF_SMU][NO_OF_VRANGE];

float smu_ipsrc_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_ipsrc_offset[NO_OF_SMU][NO_OF_IRANGE];
float smu_insrc_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_insrc_offset[NO_OF_SMU][NO_OF_IRANGE];
float smu_ipmsr_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_ipmsr_offset[NO_OF_SMU][NO_OF_IRANGE];
float smu_inmsr_real_gain[NO_OF_SMU][NO_OF_IRANGE], smu_inmsr_offset[NO_OF_SMU][NO_OF_IRANGE];

float smu_imsr_leak_gain[NO_OF_SMU][SMU_UPPER_LEAK_IRANGE+1];

float gndu_vsrc_real_gain, gndu_vsrc_offset;
float gndu_vmsr_real_gain[NO_OF_VRANGE], gndu_vmsr_offset[NO_OF_VRANGE];

BOOL without_smu_vsrc;
BOOL without_smu_vmsr; 
BOOL without_smu_isrc;
BOOL without_smu_imsr;
BOOL without_vsu_vsrc;
BOOL without_vmu_vmsr;
BOOL without_gndu_vsrc;
BOOL without_gndu_vmsr;





TGnduCtrlReg gndu_ctrl_reg;
TInputBdCtrlReg AUX_inputbd_ctrl_reg[NO_OF_AUX_INPUTBD];
TAdcValues adc_val_reg;
TDelayCtrlReg delay_reg;
TAverageCountReg average_cnt_reg; TAuxoutputCtrlReg aux_output_ctrl_reg; //(2020.03.18_윤상훈) TSmucmuinputCtrlReg smu_cmu_input_ctrl_reg; //(2020.03.18_윤상훈)
TDvmpguinputCtrlReg dvm_pgu_input_ctrl_reg; //(2020.03.18_윤상훈)

TCalibMeasReg calib_meas_reg;

INT32  smu_vadc_values[NO_OF_SMU];  INT32  smu_iadc_values[NO_OF_SMU];
INT32  gndu_adc_value;
TDacValues dac_val_reg; // 전역변수로 선언
TSmuCtrlReg smu_ctrl_reg[NO_OF_SMU];

meas_send msr_val_union;



/////////////////////////////////////////////////////////////////////////////////////////////////////
// PLC & Calibration Data Flash Section(External Flash Memory)
/////////////////////////////////////////////////////////////////////////////////////////////////////

// /* nand_addr_t = {Lun, Block, Page, Column} */

nand_addr_t nand_plc_addr = { 0, 1, 0, 0 };
nand_addr_t nand_gnduCal_addr = { 0, 2, 0, 0 };
nand_addr_t nand_gnduZeroCal_addr = { 0, 2, 0, 0 };
nand_addr_t nand_smuCal_addr = { 0, 4, 0, 0 };
nand_addr_t nand_smuZeroCal_addr = { 0, 5, 0, 0 };




/////////////////////////////////////////////////////////////////////////////////////////////////////
// Power Line Frequency
/////////////////////////////////////////////////////////////////////////////////////////////////////


UINT8 smu_pwr_line_freq;

extern SysInfo sta_info;
extern INT32 tmp_current_vrange;

extern TDelayCtrlReg delay_reg;


/////////////////////////////////////////////////////////////////////////////////////////////////////
// Calibration 관련 루틴
/////////////////////////////////////////////////////////////////////////////////////////////////////




// ideal gain 값을 설정하고
// calibration parameter를 default 값으로 설정한다
void init_calib(void)
{
	init_ideal_gain();
    smu_clear_calib_para_all();
	gndu_clear_calib_para();
}



// ideal gain 값을 설정한다
// 각 레인지별로 하드웨어적으로 결정되는 이상적인 값을 입력한다
void init_ideal_gain(void)
{
	int ch, i;
	
	for (ch=0; ch<NO_OF_SMU; ch++)
	{
        //2018.12.18 F5500 회로
        // smu_vsrc_ideal_gain[ch][0] = -0.060000000;  // Close Loop.	-6K/100K	
        // smu_vsrc_ideal_gain[ch][1] = -0.241818182;  // 2V range.	100K,33K -> -6K/24.81203007K               (GUI Vrange 2, Index 1)
	    // smu_vsrc_ideal_gain[ch][2] = -0.605454545;  // 5V range.	100K,22K -> -6K/9.90990991K                (GUI Vrange 5, Index 2)
	    // smu_vsrc_ideal_gain[ch][3] = -2.412941176;  // 20V range.	(병렬)100K,5.1K,5.1K -> -6k/2.486591906K   (GUI Vrange 20, Index 3)
	    // smu_vsrc_ideal_gain[ch][4] = -4.879277108;  // 40V range.   (병렬)100K,2.49K,2.49K -> -6k/1.229690355K (GUI Vrange 40, Index 4)
        // smu_vsrc_ideal_gain[ch][5] = -12.06000000;  // 100V range.  200K,0.5K -> -6K/0.497512438K              (GUI Vrange 100, Index 5)

	    // smu_vmsr_ideal_gain[ch][0] = -8.250000001;  // Close Loop.	-12.12121212K/100K	
	    // smu_vmsr_ideal_gain[ch][1] = -2.046992481;  // 2V range. 	100K,33K -> -12.12121212K/24.81203007K                  (GUI Mrange 2, Index 1)
	    // smu_vmsr_ideal_gain[ch][2] = -0.817567568;  // 5V range.	100K,11K  -> -12.12121212K/9.90990991K	                (GUI Mrange 5, Index 2)
	    // smu_vmsr_ideal_gain[ch][3] = -0.205143832;  // 20V range.	(병렬)100K,5.1K,5.1K -> -12.12121212K/2.486591906K      (GUI Mrange 20, Index 3)
	    // smu_vmsr_ideal_gain[ch][4] = -0.101449454;  // 40V range.	(병렬)100K,2.49K,2.49K -> -12.12121212K/1.229690355K    (GUI Mrange 40, Index 4)
        // smu_vmsr_ideal_gain[ch][5] = -0.041044776;  // 100V range.  100K,0.5K, -> -12.12121212K/0.497512438K                (GUI Mrange 100, Index 5)


		smu_vsrc_ideal_gain[ch][0] = -0.588235294;  // Close Loop(2V range).	-30K/51K
        smu_vsrc_ideal_gain[ch][1] = -3.007590133;  // 10V range.				-30K/9.97476340694K               (GUI Vrange 10, Index 1)
	    smu_vsrc_ideal_gain[ch][2] = -12.17124688;  // 40V range.				-30K/2.46482552715K               (GUI Vrange 40, Index 2)
		smu_vsrc_ideal_gain[ch][3] = -1.000000000;  // Not used
		smu_vsrc_ideal_gain[ch][4] = -1.000000000;  // Not used
		smu_vsrc_ideal_gain[ch][5] = -1.000000000;  // Not used

		smu_vmsr_ideal_gain[ch][0] = -2.000000000;  // Close Loop(2V range).	1/(-50K/100K)
	    smu_vmsr_ideal_gain[ch][1] = -0.400000000;  // 10V range. 				1/(-50K/20K)                   (GUI Mrange 10, Index 1)
	    smu_vmsr_ideal_gain[ch][2] = -0.097050428;  // 40V range.				1/(-50K/4.8525214081K)	       (GUI Mrange 40, Index 2)
		smu_vmsr_ideal_gain[ch][3] = -1.000000000;			// Not used
		smu_vmsr_ideal_gain[ch][4] = -1.000000000;			// Not used
		smu_vmsr_ideal_gain[ch][5] = -1.000000000;			// Not used
		
        // F5500 회로
	    // smu_isrc_ideal_gain[ch][0]  = -1.098e-12;	// 10pA range.  not used
	    // smu_isrc_ideal_gain[ch][1]  = -1.098e-11;	// 100pA range. not used
	    // smu_isrc_ideal_gain[ch][2]  = -1.098e-10;	// 1nA range.
	    // smu_isrc_ideal_gain[ch][3]  = -1.098e-9;	// 10nA range. 
	    // smu_isrc_ideal_gain[ch][4]  = -1.098e-8;	// 100nA range. 
	    // smu_isrc_ideal_gain[ch][5]  = -1.098e-7;	// 1uA range. 
	    // smu_isrc_ideal_gain[ch][6]  = -1.098e-6;	// 10uA range. 
	    // smu_isrc_ideal_gain[ch][7]  = -1.098e-5;	// 100uA range. 
	    // smu_isrc_ideal_gain[ch][8]  = -1.098e-4;	// 1mA range. 
	    // smu_isrc_ideal_gain[ch][9]  = -1.098e-3;	// 10mA range. 
	    // smu_isrc_ideal_gain[ch][10] = -1.098e-2;	// 100mA range.

	    // smu_imsr_ideal_gain[ch][0]  = -0.45537e+12;	        // 10pA range.  not used
	    // smu_imsr_ideal_gain[ch][1]  = -0.45537e+11;	        // 100pA range. not used
	    // smu_imsr_ideal_gain[ch][2]  = -0.4553734061930e+10;	// 1nA range.
	    // smu_imsr_ideal_gain[ch][3]  = -0.4553734061930e+9;	// 10nA range.
	    // smu_imsr_ideal_gain[ch][4]  = -0.4553734061930e+8;	// 100nA range.
	    // smu_imsr_ideal_gain[ch][5]  = -0.4553734061930e+7;	// 1uA range.
	    // smu_imsr_ideal_gain[ch][6]  = -0.4553734061930e+6;	// 10uA range.
	    // smu_imsr_ideal_gain[ch][7]  = -0.4553734061930e+5;	// 100uA range.
	    // smu_imsr_ideal_gain[ch][8]  = -0.4553734061930e+4;	// 1mA range.
	    // smu_imsr_ideal_gain[ch][9]  = -0.4553734061930e+3;	// 10mA range.
	    // smu_imsr_ideal_gain[ch][10] = -0.4553734061930e+2;	// 100mA range.

		smu_isrc_ideal_gain[ch][0]  = -3.09800E-12;	// 10pA range.  not used
	    smu_isrc_ideal_gain[ch][1]  = -3.09800E-11;	// 100pA range. not used
	    smu_isrc_ideal_gain[ch][2]  = -3.09800E-10;	// 1nA range.
	    smu_isrc_ideal_gain[ch][3]  = -3.09800E-09;	// 10nA range. 
	    smu_isrc_ideal_gain[ch][4]  = -3.12898E-08;	// 100nA range. 
	    smu_isrc_ideal_gain[ch][5]  = -3.12898E-07;	// 1uA range. 
	    smu_isrc_ideal_gain[ch][6]  = -3.12929E-06;	// 10uA range. 
	    smu_isrc_ideal_gain[ch][7]  = -3.12929E-05;	// 100uA range. 
	    smu_isrc_ideal_gain[ch][8]  = -3.12929E-04;	// 1mA range. 
	    smu_isrc_ideal_gain[ch][9]  = -3.12929E-03;	// 10mA range. 
	    smu_isrc_ideal_gain[ch][10] = -3.12929E-02;	// 100mA range.

	    smu_imsr_ideal_gain[ch][0]  = -4.09836E+11; // 10pA range.  not used
	    smu_imsr_ideal_gain[ch][1]  = -4.09836E+10; // 100pA range. not used
	    smu_imsr_ideal_gain[ch][2]  = -4.09836E+09;	// 1nA range.
	    smu_imsr_ideal_gain[ch][3]  = -4.09836E+08;	// 10nA range.
	    smu_imsr_ideal_gain[ch][4]  = -4.05778E+07;	// 100nA range.
	    smu_imsr_ideal_gain[ch][5]  = -4.05778E+06;	// 1uA range.
	    smu_imsr_ideal_gain[ch][6]  = -4.05738E+05;	// 10uA range.
	    smu_imsr_ideal_gain[ch][7]  = -4.05738E+04;	// 100uA range.
	    smu_imsr_ideal_gain[ch][8]  = -4.05738E+03;	// 1mA range.
	    smu_imsr_ideal_gain[ch][9]  = -4.05738E+02;	// 10mA range.
	    smu_imsr_ideal_gain[ch][10] = -4.05738E+01;	// 100mA range.	

		// smu_imsr_ideal_gain[ch][10] = -1.449062E+03;
		

// 		float smu_irng_up_volt[NO_OF_IRANGE];
// float smu_irng_down_volt[NO_OF_IRANGE];
// float smu_irng_2down_volt[NO_OF_IRANGE];

		smu_irng_up_volt[0] = 4.3033;	// 10pA range.  not used
		smu_irng_up_volt[1] = 4.3033;	// 100pA range. not used
		smu_irng_up_volt[2] = 4.3033;	// 1nA range.
		smu_irng_up_volt[3] = 4.3033;	// 10nA range. 
		smu_irng_up_volt[4] = 4.057377;	// 100nA range. 
		smu_irng_up_volt[5] = 4.057377;	// 1uA range. 
		smu_irng_up_volt[6] = 4.057377;	// 10uA range. 
		smu_irng_up_volt[7] = 4.057377;	// 100uA range. 
		smu_irng_up_volt[8] = 4.057377;	// 1mA range. 
		smu_irng_up_volt[9] = 4.057377;	// 10mA range. 
		smu_irng_up_volt[10] = 4.057377;// 100mA range.


		smu_irng_down_volt[0] = 0.38934; // 10pA range.  not used
		smu_irng_down_volt[1] = 0.38934; // 100pA range. not used
		smu_irng_down_volt[2] = 0.38934; // 1nA range.
		smu_irng_down_volt[3] = 0.38934; // 10nA range. 
		smu_irng_down_volt[4] = 0.38545; // 100nA range. 
		smu_irng_down_volt[5] = 0.38545; // 1uA range. 
		smu_irng_down_volt[6] = 0.38545; // 10uA range. 
		smu_irng_down_volt[7] = 0.38545; // 100uA range. 
		smu_irng_down_volt[8] = 0.38545; // 1mA range. 
		smu_irng_down_volt[9] = 0.38545; // 10mA range. 
		smu_irng_down_volt[10] = 0.38545;// 100mA range.

		smu_irng_2down_volt[0] = 0.038934; // 10pA range.  not used
		smu_irng_2down_volt[1] = 0.038934; // 100pA range. not used
		smu_irng_2down_volt[2] = 0.038934; // 1nA range.
		smu_irng_2down_volt[3] = 0.038934; // 10nA range. 
		smu_irng_2down_volt[4] = 0.038545; // 100nA range. 
		smu_irng_2down_volt[5] = 0.038545; // 1uA range. 
		smu_irng_2down_volt[6] = 0.038545; // 10uA range. 
		smu_irng_2down_volt[7] = 0.038545; // 100uA range. 
		smu_irng_2down_volt[8] = 0.038545; // 1mA range. 
		smu_irng_2down_volt[9] = 0.038545; // 10mA range. 
		smu_irng_2down_volt[10] = 0.038545; // 100mA range.


    }
	
	for (ch=0; ch<NO_OF_SMU; ch++) 
	{
        for (i=0; i<=SMU_UPPER_LEAK_IRANGE; i++) 
		{ // SMU_UPPER_LEAK_IRANGE = SMU_10nA = 3
            smu_imsr_leak_gain[ch][i] = 0.0;
        }
    }

	gndu_vsrc_ideal_gain = -0.01;

    //2017.09.26 Per_Pin 회로
 //   gndu_vmsr_ideal_gain[0] = -9.090909091;   // Close Loop.	200k/22k
	//gndu_vmsr_ideal_gain[1] = -2.272727273;   // 2V range.	50k/22k
	//gndu_vmsr_ideal_gain[2] = -0.900900901;   // 5V range.	19.819819k/22k
	//gndu_vmsr_ideal_gain[3] = -0.226053810;   // 20V range.	4.97318k/22k
	//gndu_vmsr_ideal_gain[4] = -0.114449855;   // 40V range.	2.51789k/22k

    //2018.12.18 F5500 회로
    gndu_vmsr_ideal_gain[0] = -8.250000001;   // Close Loop.	200k/22k
	gndu_vmsr_ideal_gain[1] = -2.046992481;   // 2V range.	50k/22k
	gndu_vmsr_ideal_gain[2] = -0.817567568;   // 5V range.	19.819819k/22k
	gndu_vmsr_ideal_gain[3] = -0.205143832;   // 20V range.	4.97318k/22k
	gndu_vmsr_ideal_gain[4] = -0.101449454;   // 40V range.	2.51789k/22k
    gndu_vmsr_ideal_gain[5] = -0.041044776;   // 100V range.	2.51789k/22k

    without_smu_vsrc = FALSE;
    without_smu_vmsr = FALSE;
    without_smu_isrc = FALSE;
    without_smu_imsr = FALSE;
    without_vsu_vsrc = FALSE;
    without_vmu_vmsr = FALSE;
    without_gndu_vsrc = FALSE;
    without_gndu_vmsr = FALSE;
}    

// calibration parameter를 default 값으로 설정한다
// 여기서 입력한 parameter를 가지고 calculate_calib()를 실행하면
// real gain 은 ideal gain과 같게되고 offset은 0이된다
// 즉 calibration parameter를 적용시키지 않는 것이 된다  
void smu_clear_calib_para_all(void)
{
	int ch;
	int vrange, irange;

	for (ch=0; ch<NO_OF_SMU; ch++)
	{
		for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
		{
			smu_vsrc_gain_calib[ch][vrange] = 1.0;
			smu_vmsr_gain_calib[ch][vrange] = 1.0;
			smu_vsrc_offset_calib[ch][vrange] = 0.0;
			smu_vmsr_offset_calib[ch][vrange] = 0.0;
		}
        
        for (irange=0; irange<NO_OF_IRANGE; irange++)
		{
            smu_ipsrc_gain_calib[ch][irange] = 1.0;
            smu_insrc_gain_calib[ch][irange] = 1.0;
            smu_ipmsr_gain_calib[ch][irange] = 1.0;
            smu_inmsr_gain_calib[ch][irange] = 1.0;
            smu_ipsrc_offset_calib[ch][irange] = 0.0;
            smu_insrc_offset_calib[ch][irange] = 0.0;
            smu_ipmsr_offset_calib[ch][irange] = 0.0;
            smu_inmsr_offset_calib[ch][irange] = 0.0;
        }
    }
    
	// 현재 아래 값들은 실제로 사용되지는 않는다.
	adc_gain   = 1.0; // Not Used
	adc_offset = 0.0; // Not Used
}


void smu_clear_calib_para(int ch)
{
	int vrange, irange;

	for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
	{
		smu_vsrc_gain_calib[ch][vrange] = 1.0;
		smu_vmsr_gain_calib[ch][vrange] = 1.0;
		smu_vsrc_offset_calib[ch][vrange] = 0.0;
		smu_vmsr_offset_calib[ch][vrange] = 0.0;
	}
        
    for (irange=0; irange<NO_OF_IRANGE; irange++)
	{
		smu_ipsrc_gain_calib[ch][irange] = 1.0;
        smu_insrc_gain_calib[ch][irange] = 1.0;
        smu_ipmsr_gain_calib[ch][irange] = 1.0;
        smu_inmsr_gain_calib[ch][irange] = 1.0;
        smu_ipsrc_offset_calib[ch][irange] = 0.0;
        smu_insrc_offset_calib[ch][irange] = 0.0;
        smu_ipmsr_offset_calib[ch][irange] = 0.0;
        smu_inmsr_offset_calib[ch][irange] = 0.0;
    }
}

void scan_frame_slot(void)
{
	int i;
	
	TRACE("----------------------------------------------------------\r\n");

	// GNDU
	if(search_board_init(-1, GetWireOutValue(SLOT_CS0, SPI_SEL_M0, EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF)) == FALSE) //$$ 0 --> -1
	{
		TRACE("# <Not Detect Board on Slot 0>\r\n");
	}
	
	// Slot 1 ~ 12 Search
	for(i = 0; i < 12; i++)
	{
		if(search_board_init(i, GetWireOutValue(_SPI_SEL_SLOT_SMU(i), SPI_SEL_M0, EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;
		if(search_board_init(i, GetWireOutValue(_SPI_SEL_SLOT_SMU(i), SPI_SEL_M2, EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;

		TRACE("# <Not Detect Board on Slot %d>\r\n", i + 1); //$$ i --> i + 1
	}
}

BOOL search_board_init(u8 slot, u32 fid)
{
	BOOL rtn = TRUE;
	u8 boardID = (u8)(fid >> 24);

	switch(boardID)
	{
		case S3100_GNDU:		// S3100 GNDU
			TRACE("# <Detect Board on Slot %d: S3100-GNDU, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		case S3000_PGU:			// S3000 PGU
			TRACE("# <Detect Board on Slot %d: S3000-PGU, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		case S3000_CMU:			// S3000 CMU
			TRACE("# <Detect Board on Slot %d: S3000-CMU, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		case S3100_PGU_ADDA:			// S3100 PGU ADDA
			TRACE("# <Detect Board on Slot %d: S3100-PGU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		case S3100_CMU_ADDA:			// S3100 CMU ADDA
			TRACE("# <Detect Board on Slot %d: S3100-CMU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		// case E8000_HVSMU:		// S3100 HVSMU

		// 	if(slot < 1)
		// 	{
		// 		rtn = FALSE;
		// 		TRACE("# <Check the Board on Slot>\r\n");
		// 		break;
		// 	}

		// 	TRACE("# <Detect Board on Slot %d: E8000 HVSMU, Ver 0x%X>\r\n", slot, bdid);

		// 	for(ch = 0; ch < 2; ch++)
		// 	{
		// 		hvsmu_V_DAC_reset((slot - 1) * 2 + ch);
		// 		hvsmu_V_DAC_init((slot - 1) * 2 + ch);		

		// 		hvsmu_I_DAC_reset((slot - 1) * 2 + ch);
		// 		hvsmu_I_DAC_init((slot - 1) * 2 + ch);

		// 		hvsmu_HRADC_enable((slot - 1) * 2 + ch);

		// 		smu_adc_mux_no_sel((slot - 1) * 2 + ch);
		// 	}
			
		// 	break;
		case S3100_HVSMU:			// S3100 HVSMU
			TRACE("# <Detect Board on Slot %d: S3100-HVSMU, Ver 0x%X>\r\n", slot + 1, fid);
				hvsmu_V_DAC_init(slot);
				hvsmu_I_DAC_init(slot);
				//
				hvsmu_HRADC_enable(slot);
			break;
		case S3100_PGU_SUB:			// S3100-PGU-SUB, S3100-HVPGU
			TRACE("# <Detect Board on Slot %d: S3100-PGU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		case S3100_CMU_SUB:			// S3100-CMU-SUB
			TRACE("# <Detect Board on Slot %d: S3100-CMU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
			break;
		default:
			rtn = FALSE;
			// TRACE("# <Not Detect Board on Slot %d>\r\n", slot);
			break;
	}

	return rtn;
}

void load_calib_para_flash(void)
{
	int ch;
	u32* pAdrs;
	u32 loopCnt;
	u32 flash_adrs_offset;
	
	// GNDU Calibration factor count
	// magic code + vsrc gain + vsrc offset + NO_OF_VRANGE * (vmsr gain + vmsr offset)
	loopCnt = 1 + 2 + NO_OF_VRANGE * 2;

	pAdrs = (u32*)SDRAM_GNDU_CAL_SECTION;

	// Load GNDU Calibration factor from Flash to SDRAM
	NAND_Page_Read(nand_gnduCal_addr, (u8*)pAdrs, loopCnt * 4);		// flash 8bit storage


	// SMU Calibration factor count
	// magic code + NO_OF_VRANGE * (vsrc gain + vsrc offset) + NO_OF_VRANGE * (vmsr gain + vmsr offset)
	// + NO_OF_IRANGE * (vsrc gain + vsrc offset) + NO_OF_IRANGE * (vmsr gain + vmsr offset)

	loopCnt = 1 + NO_OF_VRANGE * 4 + NO_OF_IRANGE * 8;

	// pAdrs = (u32*)SDRAM_SMU_CAL_SECTION;

	for(ch = 0; ch < NO_OF_SMU; ch++)
	{
		nand_smuCal_addr.page = ch;
		flash_adrs_offset= ch * loopCnt;
		// Load GNDU Calibration factor from Flash to SDRAM
		// NAND_Page_Read(nand_smuCal_addr, (u8*)pAdrs + ch * SDRAM_SMU_CAL_SECTION_OFFSET, loopCnt * 4);		// flash 8bit storage
		NAND_Page_Read(nand_smuCal_addr, (u8*)&flash_cal_buf[flash_adrs_offset], loopCnt * 4);		// flash 8bit storage
	}
}

// 20070912 수정
void load_calib_para(void)
{
    int ch;
    
	TRACE("---------------------------------------------------------------\r\n");
	// read_gndu_calib_para();
    for (ch=0; ch<NO_OF_SMU; ch++) 
	{
		read_smu_calib_para(ch);
	}
}


// 공급값, 측정값 계산에 사용되는 calibration factor 계산
void calculate_calib(void)
{
    int ch, vrange, irange;

    for (ch=0; ch<NO_OF_SMU; ch++) 
	{
		for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
		{
			smu_vsrc_real_gain[ch][vrange] = smu_vsrc_ideal_gain[ch][vrange] * smu_vsrc_gain_calib[ch][vrange]; // 실제gain = 이상적gain * gain parameter 
			smu_vsrc_offset[ch][vrange]    = smu_vsrc_offset_calib[ch][vrange];
			smu_vmsr_real_gain[ch][vrange] = smu_vmsr_ideal_gain[ch][vrange] * smu_vmsr_gain_calib[ch][vrange];
			smu_vmsr_offset[ch] [vrange]   = smu_vmsr_ideal_gain[ch][vrange] * smu_vmsr_offset_calib[ch][vrange];
        }

        for (irange=0; irange<NO_OF_IRANGE; irange++)
		{
            smu_ipsrc_real_gain[ch][irange] = smu_isrc_ideal_gain[ch][irange] * smu_ipsrc_gain_calib[ch][irange];
            smu_ipsrc_offset[ch][irange]    = smu_ipsrc_offset_calib[ch][irange];
            smu_ipmsr_real_gain[ch][irange] = smu_imsr_ideal_gain[ch][irange] * smu_ipmsr_gain_calib[ch][irange];
            smu_ipmsr_offset[ch][irange]    = smu_imsr_ideal_gain[ch][irange] * smu_ipmsr_offset_calib[ch][irange];;

            smu_insrc_real_gain[ch][irange] = smu_isrc_ideal_gain[ch][irange] * smu_insrc_gain_calib[ch][irange];
            smu_insrc_offset[ch][irange]    = smu_insrc_offset_calib[ch][irange];
            smu_inmsr_real_gain[ch][irange] = smu_imsr_ideal_gain[ch][irange] * smu_inmsr_gain_calib[ch][irange];
            smu_inmsr_offset[ch][irange]    = smu_imsr_ideal_gain[ch][irange] * smu_inmsr_offset_calib[ch][irange];
        }
    }

    gndu_vsrc_real_gain = gndu_vsrc_ideal_gain * gndu_vsrc_gain_calib;
	gndu_vsrc_offset = gndu_vsrc_offset_calib;

	/*
	for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
	{
		gndu_vmsr_real_gain[vrange] = gndu_vmsr_ideal_gain[vrange] * gndu_vmsr_gain_calib[vrange];
		gndu_vmsr_offset[vrange] = gndu_vmsr_offset_calib[vrange];
	}
	*/
	// 현재 GNDU의 측정값 얻을 때 calibration을 적용하지 않는다.
	for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
	{
		gndu_vmsr_real_gain[vrange] = gndu_vmsr_ideal_gain[vrange];
		gndu_vmsr_offset[vrange] = 0.0;
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
// 보드 초기화 및 레지스터 초기화 루틴
/////////////////////////////////////////////////////////////////////////////////////////////////////

void init_module(void)
{
	io_output_eeprom_cs_init();
    init_smu_ctrl_reg();
	init_smu_ctrl();
	init_gndu_ctrl_reg();
	init_delay_ctrl_reg();
    init_average_count_reg();

	init_calib();
	scan_frame_slot();
	//load_calib_para_flash();
	load_calib_para();  // 저장되어 있는 calibration parameter를 불러온다.
	calculate_calib();//
	
	// init_smu_adc_mux();		// move in scan_frame_slot()
	init_gndu_adc_mux();
}

void init_smu_ctrl_reg(void)
{
	int smu_ch;	

	// smu_ctrl_reg[CH_SMU1].base_addr = SMU1_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU2].base_addr = SMU2_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU3].base_addr = SMU3_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU4].base_addr = SMU4_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU5].base_addr = SMU5_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU6].base_addr = SMU6_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU7].base_addr = SMU7_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU8].base_addr = SMU8_BASE_ADDR;
    // smu_ctrl_reg[CH_SMU9].base_addr = SMU9_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU10].base_addr = SMU10_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU11].base_addr = SMU11_BASE_ADDR;
	// smu_ctrl_reg[CH_SMU12].base_addr = SMU12_BASE_ADDR;
//	
    
	for(smu_ch = 0; smu_ch<NO_OF_SMU; smu_ch++)
	{
		smu_ctrl_reg[smu_ch].used = FALSE;
		smu_ctrl_reg[smu_ch].mode = SMU_MODE_V;
		smu_ctrl_reg[smu_ch].src_val = 0;
		smu_ctrl_reg[smu_ch].limit_val = 0.0001;         // 수정 20080214 ??
		smu_ctrl_reg[smu_ch].imsr_rng = SMU_100uA_RANGE; // 추가 마지막 측정레인지를 항상 기억한다. 초기에는 100uA 레인지
   
		smu_ctrl_reg[smu_ch].min_vrange = SMU_2V_RANGE; // sbcho@20211108 HVSMU : Range 500mV -> 2V
		smu_ctrl_reg[smu_ch].max_vrange = SMU_40V_RANGE; // sbcho@20211108 HVSMU : Range 100V -> 40V

		smu_ctrl_reg[smu_ch].min_imsr_range = SMU_1nA_RANGE;
		smu_ctrl_reg[smu_ch].max_imsr_range = SMU_100mA_RANGE;
		smu_ctrl_reg[smu_ch].min_isrc_range = SMU_1nA_RANGE;
		smu_ctrl_reg[smu_ch].max_isrc_range = SMU_100mA_RANGE;

		io_eeprom_sequence(smu_ch);

//		smu_ctrl_reg[smu_ch].ictrl = SMU_ICTRL_INIT; // 추가 20070806

        // 2018.12.18 F5500(input output relay off)
        smu_rly_all_off(smu_ch); //20190411 modify
        
		// // SMU DAC FILTER Initialization
        // smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl | (SMU_VDAC_FIL_1NF | SMU_VDAC_FIL_10NF | SMU_IDAC_FIL_1NF | SMU_IDAC_FIL_10NF));

        // //I, V DAC Filter 10NF ON
        // smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl & ~SMU_VDAC_FIL_10NF);
        // smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl & ~SMU_VDAC_FIL_10NF);

    }

	io_output_eeprom_cs_init();
    //configure_sta_info();

	


}

void init_smu_ctrl(void)
{
	int smu_ch;

	for(smu_ch = 0; smu_ch < NO_OF_SMU; smu_ch++)
	{
		// 2018.12.18 F5500(input output relay off)
        smu_rly_all_off(smu_ch); //20190411 modify
        
		// SMU DAC FILTER Initialization

        // smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl | (SMU_VDAC_FIL_1NF | SMU_VDAC_FIL_10NF | SMU_IDAC_FIL_1NF | SMU_IDAC_FIL_10NF));

        // //I, V DAC Filter 1NF ON
        // smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl & ~SMU_IDAC_FIL_1NF);
		// smu_iv_dac_filter_ctrl(smu_ch, smu_ctrl_reg[smu_ch].iv_dac_filter_ctrl & ~SMU_VDAC_FIL_1NF);
	}
	 
}
          
          
void init_delay_ctrl_reg()  
{ 
    int i;   
       
   // delay_reg.smu_imsr_range[SMU_10pA_RANGE] = 400; // 10pA(100G x10) 200
   // delay_reg.smu_imsr_range[SMU_100pA_RANGE] = 300; // 100pA(100G x1) 150
   // delay_reg.smu_imsr_range[SMU_1nA_RANGE] = 50;  // 1nA(1G x10)    100
   // delay_reg.smu_imsr_range[SMU_10nA_RANGE] = 50;  // 10nA(1G x1)    50
   // for (i=4; i<NO_OF_IRANGE; i++) delay_reg.smu_imsr_range[i] = 0;
   // 	 
	  //delay_reg.smu_imsr_change[SMU_10pA_RANGE] = 500; // 10pA(100G x10) 200
   // delay_reg.smu_imsr_change[SMU_100pA_RANGE] = 500; // 100pA(100G x1) 150
   // delay_reg.smu_imsr_change[SMU_1nA_RANGE] = 100;  // 1nA(1G x10)    100
   // delay_reg.smu_imsr_change[SMU_10nA_RANGE] = 50;  // 10nA(1G x1)    50
   // delay_reg.smu_imsr_change[SMU_100nA_RANGE] = 20;  // 10>20 cjh, 100nA(10M x10) 20  
   // delay_reg.smu_imsr_change[SMU_1uA_RANGE] = 10;  //0>50 cjh, 1uA(10M x1)    20
   // delay_reg.smu_imsr_change[SMU_10uA_RANGE] = 5;  //0>10 cjh, 10uA(10M x1)    20
   // delay_reg.smu_imsr_change[SMU_100uA_RANGE] = 5;  //0>10 cjh, 100uA(10M x1)    20
   // for (i=8; i<NO_OF_IRANGE; i++) delay_reg.smu_imsr_change[i] = 0; 
  
    delay_reg.smu_imsr_range[SMU_10pA_RANGE]  = 20; // 10pA(100G x10) 20
    delay_reg.smu_imsr_range[SMU_100pA_RANGE] = 20; // 100pA(100G x1) 20
    delay_reg.smu_imsr_range[SMU_1nA_RANGE]   = 20; // 1nA(1G x10)    20 
    delay_reg.smu_imsr_range[SMU_10nA_RANGE]  = 10; // 10nA(1G x1)    10
    delay_reg.smu_imsr_range[SMU_100nA_RANGE] = 5;  // 10>20 cjh, 100nA(10M x10) 10  
    delay_reg.smu_imsr_range[SMU_1uA_RANGE]   = 5;  // 0>50 cjh, 1uA(10M x1)    5
    delay_reg.smu_imsr_range[SMU_10uA_RANGE]  = 5;  // 0>10 cjh, 10uA(10M x1)    5
    delay_reg.smu_imsr_range[SMU_100uA_RANGE] = 3;  // 0>10 cjh, 100uA(10M x1)    3
    delay_reg.smu_imsr_range[SMU_1mA_RANGE]   = 0;  // 0>10 cjh, 100uA(10M x1)    0
    for (i=9; i<NO_OF_IRANGE; i++) delay_reg.smu_imsr_range[i] = 0; 
   	 
 //   delay_reg.smu_imsr_change[SMU_10pA_RANGE] = 20; // 10pA(100G x10) 20
 //   delay_reg.smu_imsr_change[SMU_100pA_RANGE] = 20; // 100pA(100G x1) 20
 //   delay_reg.smu_imsr_change[SMU_1nA_RANGE] = 20;  // 1nA(1G x10)    20
 //   delay_reg.smu_imsr_change[SMU_10nA_RANGE] = 20;  // 10nA(1G x1)    20
 //   delay_reg.smu_imsr_change[SMU_100nA_RANGE] = 20;  // 10>20 cjh, 100nA(10M x10) 10  
 //   delay_reg.smu_imsr_change[SMU_1uA_RANGE] = 20;  //0>50 cjh, 1uA(10M x1)    10
 //   delay_reg.smu_imsr_change[SMU_10uA_RANGE] = 20;  //0>10 cjh, 10uA(10M x1)    10
 //   delay_reg.smu_imsr_change[SMU_100uA_RANGE] = 20;  //0>10 cjh, 100uA(10M x1)   10
	//delay_reg.smu_imsr_change[SMU_1mA_RANGE] = 20;                                //  5
 //   for (i=9; i<NO_OF_IRANGE; i++) delay_reg.smu_imsr_change[i] = 5;            //1

    //2016.01.25
    delay_reg.smu_imsr_change[SMU_10pA_RANGE]  = 200; // 10pA(100G x10) 20 
    delay_reg.smu_imsr_change[SMU_100pA_RANGE] = 200; // 100pA(100G x1) 20
    delay_reg.smu_imsr_change[SMU_1nA_RANGE]   = 100; // 1nA(1G x10)    20
    delay_reg.smu_imsr_change[SMU_10nA_RANGE]  = 50;  // 10nA(1G x1)    20
    delay_reg.smu_imsr_change[SMU_100nA_RANGE] = 50;  // 10>20 cjh, 100nA(10M x10) 10  
    delay_reg.smu_imsr_change[SMU_1uA_RANGE]   = 20;  // 0>50 cjh, 1uA(10M x1)    10
    delay_reg.smu_imsr_change[SMU_10uA_RANGE]  = 20;  // 0>10 cjh, 10uA(10M x1)    10
    delay_reg.smu_imsr_change[SMU_100uA_RANGE] = 20;  // 0>10 cjh, 100uA(10M x1)   10
    delay_reg.smu_imsr_change[SMU_1mA_RANGE]   = 10;  // 5
    for (i=9; i<NO_OF_IRANGE; i++) delay_reg.smu_imsr_change[i] = 5; //1
  
    // i source range delay 
    delay_reg.smu_isrc_range[SMU_10pA_RANGE]  = 500;  // 10pA(100G x10) 500
    delay_reg.smu_isrc_range[SMU_100pA_RANGE] = 400;  // 100pA(100G x1) 400
    delay_reg.smu_isrc_range[SMU_1nA_RANGE]   = 300;  // 1nA(1G x10)    300
    delay_reg.smu_isrc_range[SMU_10nA_RANGE]  = 200;  // 10nA(1G x1)    200
    delay_reg.smu_isrc_range[SMU_100nA_RANGE] = 100;  // 100nA(10M x10) 100
    delay_reg.smu_isrc_range[SMU_1uA_RANGE]   = 100;  // 1uA(10M x1)    100
    delay_reg.smu_isrc_range[SMU_10uA_RANGE]  = 100;  // 10uA(100K x10) 100 
    for (i=7; i<NO_OF_IRANGE; i++) delay_reg.smu_isrc_range[i] = 5;
    	
    delay_reg.smu_isrc_change[SMU_10pA_RANGE]  = 400; // 10pA(100G x10) 400
    delay_reg.smu_isrc_change[SMU_100pA_RANGE] = 350; // 100pA(100G x1) 350
    delay_reg.smu_isrc_change[SMU_1nA_RANGE]   = 100; // 1nA(1G x10)    300
    delay_reg.smu_isrc_change[SMU_10nA_RANGE]  = 100; // 10nA(1G x1)    250
    delay_reg.smu_isrc_change[SMU_100nA_RANGE] = 100; // 100nA(10M x10) 200
    delay_reg.smu_isrc_change[SMU_1uA_RANGE]   = 20;  // 1uA(10M x1)    150
    delay_reg.smu_isrc_change[SMU_10uA_RANGE]  = 5;   // 10uA(100K x10) 100
    for (i=7; i<NO_OF_IRANGE; i++) delay_reg.smu_isrc_change[i] = 5;
}


void init_average_count_reg()
{
    average_cnt_reg.average_short[SMU_10pA_RANGE] = 4;
    average_cnt_reg.average_short[SMU_100pA_RANGE]= 4;
    average_cnt_reg.average_short[SMU_1nA_RANGE]  =	32; //4
    average_cnt_reg.average_short[SMU_10nA_RANGE] = 32; //4
    average_cnt_reg.average_short[SMU_100nA_RANGE]= 16; //4
    average_cnt_reg.average_short[SMU_1uA_RANGE]  = 4;  //8
    average_cnt_reg.average_short[SMU_10uA_RANGE] = 4;  //8
    average_cnt_reg.average_short[SMU_100uA_RANGE]= 4;
    average_cnt_reg.average_short[SMU_1mA_RANGE]  = 4;
    average_cnt_reg.average_short[SMU_10mA_RANGE] = 4;
    average_cnt_reg.average_short[SMU_100mA_RANGE]= 4;
    average_cnt_reg.average_short[SMU_1A_RANGE]   = 4;

    average_cnt_reg.average_medium[SMU_10pA_RANGE] = SAMPLES_PER_1PLC * 3;
    average_cnt_reg.average_medium[SMU_100pA_RANGE]= SAMPLES_PER_1PLC * 3;
    //average_cnt_reg.average_medium[SMU_1nA_RANGE]  = SAMPLES_PER_1PLC * 2;
    average_cnt_reg.average_medium[SMU_1nA_RANGE]  = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_10nA_RANGE] = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_100nA_RANGE]= SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_1uA_RANGE]  = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_10uA_RANGE] = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_100uA_RANGE]= SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_1mA_RANGE]  = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_10mA_RANGE] = SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_100mA_RANGE]= SAMPLES_PER_1PLC;
    average_cnt_reg.average_medium[SMU_1A_RANGE]   = SAMPLES_PER_1PLC;
		
    average_cnt_reg.average_long[SMU_10pA_RANGE] = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_100pA_RANGE]= SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_1nA_RANGE]  = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_10nA_RANGE] = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_100nA_RANGE]= SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_1uA_RANGE]  = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_10uA_RANGE] = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_100uA_RANGE]= SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_1mA_RANGE]  = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_10mA_RANGE] = SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_100mA_RANGE]= SAMPLES_PER_1PLC * 16;
    average_cnt_reg.average_long[SMU_1A_RANGE]   = SAMPLES_PER_1PLC * 16;
}

//////////////////////////////////////////////////////////////////////////////////////
// SMU ADC_MUX 설정 관련 루틴
//////////////////////////////////////////////////////////////////////////////////////
void init_smu_adc_mux(void)
{
	int smu_ch;

	for(smu_ch = CH_SMU1; smu_ch<NO_OF_SMU; smu_ch++)
		smu_adc_mux_no_sel(smu_ch);
}

void smu_adc_mux_v_sel(int smu_ch)
{
  //기존 회로
	//*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS5_ADDR) = 0x01;

  //2017.09.26 Per_pin 회로
  //*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_ADC_SEL_SW_CS) = 0xFE;

//   MIO_SMU_WR(smu_ch, SMU_ADC_SEL_SW_CS, 0x000000FE);


	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
	
	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FE, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
}


void smu_adc_mux_no_sel(int smu_ch)
{
  //기존 회로
	//*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS5_ADDR) = 0x00;
  
  //2017.09.26 Per_pin 회로
  //*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_ADC_SEL_SW_CS) = 0xFF;

  //   MIO_SMU_WR(smu_ch, SMU_ADC_SEL_SW_CS, 0x000000FF);

	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FF, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
}


void smu_adc_mux_v_sel_all(void)
{
	int ch;
	u32 slotCS;

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		slotCS = _SPI_SEL_SLOT_SMU(ch);
    //기존 회로
		//*(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_CS5_ADDR) = 0x01;

    //2017.09.26 Per_pin 회로
//	    *(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_SEL_SW_CS) = 0xFE;

		// MIO_SMU_WR(ch, SMU_ADC_SEL_SW_CS, 0x000000FE);

		SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FE, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
		ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
	}
}


void smu_adc_mux_i_sel(int smu_ch)
{
  //기존 회로
	//*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS5_ADDR) = 0x02;

  //2017.09.26 Per_pin 회로
//	  *(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_ADC_SEL_SW_CS) = 0xFD;
	// MIO_SMU_WR(smu_ch, SMU_ADC_SEL_SW_CS, 0x000000FD);

	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FD, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
}


void smu_adc_mux_i_sel_all(void)
{
	int ch;
	u32 slotCS;

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
    //기존 회로
//			*(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_SEL_SW_CS) = 0x02;
    
    //2017.09.26 Per_pin 회로
//	    *(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_SEL_SW_CS) = 0xFD;
		// MIO_SMU_WR(ch, SMU_ADC_SEL_SW_CS, 0x000000FD);

		slotCS = _SPI_SEL_SLOT_SMU(ch + 1);

		SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FD, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
		ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
	}
}

//////////////////////////////////////////////////////////////////////////////////////
// DAC 출력값 계산 루틴 
//////////////////////////////////////////////////////////////////////////////////////

void calculate_dac_out_val_all(void)
{
    int smu_ch;
    float idac_out_val, vdac_out_val;
 
    for (smu_ch=0; smu_ch<NO_OF_SMU; smu_ch++) 
    {
        if (smu_ctrl_reg[smu_ch].used) 
        {
            if (smu_ctrl_reg[smu_ch].mode == SMU_MODE_I)	// 전류모드
            { 
                idac_out_val = calculate_smu_idac_out_val(smu_ch, smu_ctrl_reg[smu_ch].src_rng, smu_ctrl_reg[smu_ch].src_val);
                dac_val_reg.smu_idac_out_val[smu_ch] = idac_out_val;
                
                if( get_smu_vrng(smu_ch, smu_ctrl_reg[smu_ch].limit_val) > smu_ctrl_reg[smu_ch].vmsr_rng ) 
					vdac_out_val = -3.75;

                else
                    vdac_out_val = calculate_smu_vdac_out_val(smu_ch, smu_ctrl_reg[smu_ch].vmsr_rng, smu_ctrl_reg[smu_ch].limit_val);
                
//                vdac_out_val = -ABS(vdac_out_val);	// 항상 음인 값으로 만든다. 
                if (vdac_out_val > 0) vdac_out_val = -1 * vdac_out_val;

                if (smu_ctrl_reg[smu_ch].src_val < 0)	// '-' 전류모드인 경우 전압DAC출력값은 양의 값이다.
                	vdac_out_val = -vdac_out_val;
                                
                dac_val_reg.smu_vdac_out_val[smu_ch] = vdac_out_val;                
            }

            else 
            { // 전압모드, COM모드
                vdac_out_val = calculate_smu_vdac_out_val(smu_ch, smu_ctrl_reg[smu_ch].src_rng, smu_ctrl_reg[smu_ch].src_val);
                dac_val_reg.smu_vdac_out_val[smu_ch] = vdac_out_val;
                                
                if(smu_ctrl_reg[smu_ch].mode == SMU_MODE_COM) // COM모드에서 전류 compliance값은 100mA로 최대이므로 
                    idac_out_val = -3.75;                     // 전류 DAC는 항상 최대값을 출력해야한다
                else if( get_smu_imsr_rng(smu_ch, smu_ctrl_reg[smu_ch].limit_val) > smu_ctrl_reg[smu_ch].imsr_rng )
                    idac_out_val = -3.75;
                else
                    idac_out_val = calculate_smu_idac_out_val(smu_ch, smu_ctrl_reg[smu_ch].imsr_rng, smu_ctrl_reg[smu_ch].limit_val);
                    
                dac_val_reg.smu_idac_out_val[smu_ch] = idac_out_val;    
            } 
        }

        else 
        {	//사용되지 않는 SMU
                dac_val_reg.smu_vdac_out_val[smu_ch] = 0;
                dac_val_reg.smu_idac_out_val[smu_ch] = -3.75;      
        }
    }
}


void calculate_dac_out_val(int smu_ch)
{
	float idac_out_val, vdac_out_val;
 
    if (smu_ctrl_reg[smu_ch].mode == SMU_MODE_I)	// 전류모드
    { 
    	idac_out_val = calculate_smu_idac_out_val(smu_ch, smu_ctrl_reg[smu_ch].src_rng, smu_ctrl_reg[smu_ch].src_val);
      dac_val_reg.smu_idac_out_val[smu_ch] = idac_out_val;
              
      if( get_smu_vrng(smu_ch, smu_ctrl_reg[smu_ch].limit_val) > smu_ctrl_reg[smu_ch].vmsr_rng ) 
      	vdac_out_val = -3.75;
      else
        vdac_out_val = calculate_smu_vdac_out_val(smu_ch, smu_ctrl_reg[smu_ch].vmsr_rng, smu_ctrl_reg[smu_ch].limit_val);
              
//      vdac_out_val = -ABS(vdac_out_val);	// 항상 음인 값으로 만든다. 
      if (vdac_out_val > 0) vdac_out_val = -1 * vdac_out_val;

      if (smu_ctrl_reg[smu_ch].src_val < 0)	// '-' 전류모드인 경우 전압DAC출력값은 양의 값이다.
      	vdac_out_val = -vdac_out_val;
                              
      dac_val_reg.smu_vdac_out_val[smu_ch] = vdac_out_val;    

	}

    else 
    { // 전압모드, COM모드
    	vdac_out_val = calculate_smu_vdac_out_val(smu_ch, smu_ctrl_reg[smu_ch].src_rng, smu_ctrl_reg[smu_ch].src_val);
      dac_val_reg.smu_vdac_out_val[smu_ch] = vdac_out_val;
                              
      if(smu_ctrl_reg[smu_ch].mode == SMU_MODE_COM) // COM모드에서 전류 compliance값은 100mA로 최대이므로 
      	idac_out_val = -3.75;                       // 전류 DAC는 항상 최대값을 출력해야한다
      else
        idac_out_val = calculate_smu_idac_out_val(smu_ch, smu_ctrl_reg[smu_ch].imsr_rng, smu_ctrl_reg[smu_ch].limit_val);
    	
      dac_val_reg.smu_idac_out_val[smu_ch] = idac_out_val;    
    }
	  	
      
}


// DUT에 출력해야 하는 전류값을 가지고 전류DAC가 출력해야 하는 값 계산
// 전류 공급 gain이 음의 값이기 때문에 항상 음의 값을 리턴한다. 
float calculate_smu_idac_out_val(int smu_ch, int i_range, float dut_out_val)
{
	float idac_out_val;
	if (without_smu_isrc) 
	{
		if (dut_out_val < 0)  
			idac_out_val = -dut_out_val/smu_isrc_ideal_gain[smu_ch][i_range];
		else 
			idac_out_val = dut_out_val/smu_isrc_ideal_gain[smu_ch][i_range];

		return idac_out_val;
	}

	if (dut_out_val < 0) 
		idac_out_val = -(dut_out_val - smu_insrc_offset[smu_ch][i_range])/smu_insrc_real_gain[smu_ch][i_range];
	else 
		idac_out_val = (dut_out_val - smu_ipsrc_offset[smu_ch][i_range])/smu_ipsrc_real_gain[smu_ch][i_range];

	return idac_out_val;
}


// DUT에 출력해야 하는 전압값을 가지고 전압DAC가 출력해야 하는 값 계산
float calculate_smu_vdac_out_val(int smu_ch, int v_range, float dut_out_val)
{
    volatile float vdac_out_val;
    
	if (without_smu_vsrc)
	{
		vdac_out_val = dut_out_val/smu_vsrc_ideal_gain[smu_ch][v_range];
		return vdac_out_val;
	}

	vdac_out_val = (dut_out_val - smu_vsrc_offset[smu_ch][v_range])/smu_vsrc_real_gain[smu_ch][v_range];

	
	return vdac_out_val;
}

//////////////////////////////////////////////////////////////////////////////////////
// DAC 동작 관련  루틴 
//////////////////////////////////////////////////////////////////////////////////////

// DAC가 출력해야 하는 값 (float) 으로부터 DAC에 입력돼야 하는 값 (integer) 계산
// INT32 calculate_dac_in_val(float dac_out_val)
// {
//   INT32 dac_in_val;

//   if(dac_out_val < -10) 
//   dac_out_val = -10;
  	
//   else if(dac_out_val > 10)
//     dac_out_val = 10;
  	
//   if(dac_out_val < 0)
//   {
//     dac_in_val = (INT32)((dac_out_val * 0x8000 / 10) - 0.55); //0x8000 : Analog Output(v) -> -10V [Negative Full-Scale]
//   }
//   else
//   {
//     dac_in_val= (INT32)((dac_out_val * 0x8000 / 10) + 0.55);
//   }

//   if (dac_in_val > MAX_DAC_IN_VALUE) dac_in_val = MAX_DAC_IN_VALUE;
//   else if (dac_in_val < MIN_DAC_IN_VALUE) dac_in_val = MIN_DAC_IN_VALUE;

//   return dac_in_val; 
// }

// sbcho@20211124 HVSMU
INT32 calculate_dac_in_val(float dac_out_val)
{
	INT32 dac_in_val;

	if(dac_out_val < -3.75) dac_out_val = -3.75;
	if(dac_out_val > 3.75) dac_out_val = 3.75;
  	
	if(dac_out_val < 0)
	{
		// dac_in_val = (INT32)((dac_out_val * 0x00800001 / 3.75)); //0x00800000 : Analog Output(v) -> -3.75V [Negative Full-Scale]
		dac_in_val= (INT32)((dac_out_val * 0x00800000 / 3.75)) + 1;
	}
	else
	{
		// dac_in_val= (INT32)((dac_out_val * 0x007FFFFF / 3.75));
		dac_in_val = (INT32)((dac_out_val * 0x00800000 / 3.75) - 1); //0x00800000 : Analog Output(v) -> -3.75V [Negative Full-Scale]
	}

//   if (dac_in_val > MAX_DAC_IN_VALUE) dac_in_val = MAX_DAC_IN_VALUE;
//   else if (dac_in_val < MIN_DAC_IN_VALUE) dac_in_val = MIN_DAC_IN_VALUE;

  return dac_in_val; 
}


// 전 SMU 보드의 DAC 값을 출력시키는 루틴
void start_smu_dac_all(void)
{
    int smu_ch;
            
    // DAC가 출력해야 하는 값으로부터 DAC에 입력돼야하는 값 계산        
    for (smu_ch=0; smu_ch<NO_OF_SMU; smu_ch++) 
    {
        dac_val_reg.smu_vdac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_vdac_out_val[smu_ch]);
        dac_val_reg.smu_idac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_idac_out_val[smu_ch]);
    }
        
    for(smu_ch=0; smu_ch<NO_OF_SMU; smu_ch++)
	{
		write_smu_vdac(smu_ch, dac_val_reg.smu_vdac_in_val[smu_ch]);
		write_smu_idac(smu_ch, dac_val_reg.smu_idac_in_val[smu_ch]);
	}
}


void start_smu_dac(int smu_ch)
{
	// DAC가 출력해야 하는 값으로부터 DAC에 입력돼야하는 값 계산      
	dac_val_reg.smu_vdac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_vdac_out_val[smu_ch]);
	dac_val_reg.smu_idac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_idac_out_val[smu_ch]);

	write_smu_vdac(smu_ch, dac_val_reg.smu_vdac_in_val[smu_ch]);
	write_smu_idac(smu_ch, dac_val_reg.smu_idac_in_val[smu_ch]);
}

void start_smu_vdac(int smu_ch)
{
  // DAC가 출력해야 하는 값으로부터 DAC에 입력돼야하는 값 계산  
	
	dac_val_reg.smu_vdac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_vdac_out_val[smu_ch]);
         
	write_smu_vdac(smu_ch, dac_val_reg.smu_vdac_in_val[smu_ch]); 


}

void start_smu_idac(int smu_ch)
{
  // DAC가 출력해야 하는 값으로부터 DAC에 입력돼야하는 값 계산  

	dac_val_reg.smu_idac_in_val[smu_ch] = calculate_dac_in_val(dac_val_reg.smu_idac_out_val[smu_ch]);
  
	write_smu_idac(smu_ch, dac_val_reg.smu_idac_in_val[smu_ch]);
		
}

// 지정한 SMU 보드의 전압 DAC 에 값을 쓰는 루틴
void write_smu_vdac(int smu_ch, INT32 vdac_in_val)
{
    smu_ctrl_reg[smu_ch].vdac_in_val = vdac_in_val;

    //*(INT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_VDAC_WRITE_ADDR) = (INT16)vdac_in_val;  
    //MIO_SMU_WR(smu_ch, SMU_VDAC_WRITE_ADDR, (u32)vdac_in_val);

	hvsmu_V_DAC_reg_set(smu_ch, 0x1, (u32)vdac_in_val);
	hvsmu_V_DAC__trig_ldac(smu_ch); // trigger ldac


}


// 지정한 SMU 보드의 전류 DAC 에 값을 쓰는 루틴
void write_smu_idac(int smu_ch, INT32 idac_in_val)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);

    smu_ctrl_reg[smu_ch].idac_in_val = idac_in_val;

    //*(INT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_IDAC_WRITE_ADDR) = (INT16)idac_in_val;
    // MIO_SMU_WR(smu_ch, SMU_IDAC_WRITE_ADDR, (u32)idac_in_val);

	hvsmu_I_DAC_reg_set(smu_ch, 0x1, (u32)idac_in_val);
	hvsmu_I_DAC__trig_ldac(smu_ch); // trigger ldac
}


//////////////////////////////////////////////////////////////////////////////////////
// 전압레인지, 전류레인지 설정 관련 루틴 
//////////////////////////////////////////////////////////////////////////////////////

// 주어진 전압레인지에서 공급,측정 할 수 있는 최대 전압값 계산
float get_smu_vmax(int smu_ch, int rng)
{
    if (without_smu_vsrc) return -3.75 * smu_vsrc_ideal_gain[smu_ch][rng];
    return -3.75 * smu_vsrc_real_gain[smu_ch][rng] + smu_vsrc_offset[smu_ch][rng];
}


// 주어진 전압레인지에서 공급,측정 할 수 있는 최소 전압값 계산
float get_smu_vmin(int smu_ch, int rng)
{
    if (without_smu_vsrc) return 10 * smu_vsrc_ideal_gain[smu_ch][rng];
    return 10 * smu_vsrc_real_gain[smu_ch][rng] + smu_vsrc_offset[smu_ch][rng];
}


// 주어진 전류레인지에서 공급,측정 할 수 있는 최대 전류값 계산
float get_smu_imax(int ch, int rng)
{
    if (without_smu_isrc) return -3.75 * smu_isrc_ideal_gain[ch][rng];
    return -3.75 * smu_ipsrc_real_gain[ch][rng] + smu_ipsrc_offset[ch][rng];
}


// 주어진 전류레인지에서 공급,측정 할 수 있는 최소 전류값 계산
float get_smu_imin(int ch, int rng)
{
    if (without_smu_isrc) return 3.75 * smu_isrc_ideal_gain[ch][rng];
    return 3.75 * smu_insrc_real_gain[ch][rng] + smu_insrc_offset[ch][rng];
}


// Update : 2004.08.26. 조재한 
// 전압값(val)을 이 레인지(rng)에서 공급 또는 측정할 수 있는가?
BOOL is_smu_vrng(int smu_ch, int rng, float val)
{
    if ((val >= get_smu_vmin(smu_ch, rng)) && (val <= get_smu_vmax(smu_ch, rng)))
        return TRUE;
    else
        return FALSE;
}


// Update : 2004.08.26. 조재한 
// 전류값(val)을 이 레인지(rng)에서 공급 또는 측정할 수 있는가?
BOOL is_smu_irng(int smu_ch, int rng, float val)
{
    if ((val >= get_smu_imin(smu_ch, rng)) && (val <= get_smu_imax(smu_ch, rng)))
        return TRUE;
    else
        return FALSE;
}


// SMU가 공급하거나 측정해야 하는 전압값을 가지고 그 전압값을 공급 혹은 측정할 수 있는
// 레인지를  아랫 레인지에서 부터 찾아서 리턴한다 
int get_smu_vrng(int smu_ch, float val)
{
    int range;

    for (range = smu_ctrl_reg[smu_ch].min_vrange; range <= smu_ctrl_reg[smu_ch].max_vrange; range++) 
    {       
        if(is_smu_vrng(smu_ch, range, val)) 
        	return range;
    }
    
    return smu_ctrl_reg[smu_ch].max_vrange;
}


// 채널이 측정해야 하는 전류값을 가지고 그 전류값을 측정할 수 있는 레인지를
// 아랫 레인지에서 부터 찾는다 
int get_smu_imsr_rng(int smu_ch, float val)
{
    int range;

    for (range = smu_ctrl_reg[smu_ch].min_imsr_range; range <= smu_ctrl_reg[smu_ch].max_imsr_range; range++) 
    {       
        if (is_smu_irng(smu_ch, range, val)) return range;
    }
    
    return smu_ctrl_reg[smu_ch].max_imsr_range;
}


// 채널이 공급해야 하는 전류값을 가지고 그 전류값을 공급할 수 있는 레인지를
// 아랫 레인지에서 부터 찾는다 
int get_smu_isrc_rng(int smu_ch, float val)
{
    int range;

    for (range = smu_ctrl_reg[smu_ch].min_isrc_range; range <= smu_ctrl_reg[smu_ch].max_isrc_range; range++) 
    {       
        if (is_smu_irng(smu_ch, range, val)) return range;
    }
    
    return smu_ctrl_reg[smu_ch].max_isrc_range;
}


// SMU의 현재 전압 레인지 설정 상태를 읽는다
int read_smu_vrange(int smu_ch)
{
    return to_smu_vrange(smu_ch, smu_ctrl_reg[smu_ch].vctrl);
}


// SMU의 현재 전류 레인지 설정 상태를 읽는다
int read_smu_irange(int smu_ch)
{
    return to_smu_irange(smu_ch, smu_ctrl_reg[smu_ch].ictrl);
}

// sbcho@20211217 HVSMU
// 현재 설정된 레지스터 값으로부터 전압레인지를 알아낸다
int to_smu_vrange(int smu_ch, UINT16 vctrl)
{
    int range;
    
    if(vctrl & SMU_200V_CTRL) range = SMU_200V_RANGE;
	else if(vctrl & SMU_40V_CTRL) range = SMU_40V_RANGE;
    else if(vctrl & SMU_20V_CTRL) range = SMU_20V_RANGE;
    else if(vctrl & SMU_5V_CTRL) range = SMU_5V_RANGE;
	else if(vctrl & SMU_2V_CTRL) range = SMU_2V_RANGE;
	else range = SMU_2V_RANGE;
    //dprint("#range = %d\n", range);
    return range;
}


// 현재 설정된 레지스터 값으로부터 전류레인지를 알아낸다
// sbcho@20211217 HVSMU
int to_smu_irange(int ch, UINT32 ictrl)
{
    int range;
      
    if (ictrl & SMU_ICTRL_IX10_MASK) 
    {
	    if(ictrl & SMU_ICTRL_5_RAMP) range = SMU_100mA_RANGE;
        else if(ictrl & SMU_ICTRL_500_RAMP) range = SMU_1mA_RANGE;
        else if (ictrl & SMU_ICTRL_50K_RAMP) range = SMU_10uA_RANGE;
		else if (ictrl & SMU_ICTRL_5M_RAMP) range = SMU_100nA_RANGE;
		else if (ictrl & SMU_ICTRL_500M_RAMP) range = SMU_1nA_RANGE;
        else range = SMU_10pA_RANGE;
	}
    else 
	{
        if (ictrl & SMU_ICTRL_500_RAMP) range = SMU_10mA_RANGE;
        else if (ictrl & SMU_ICTRL_50K_RAMP) range = SMU_100uA_RANGE;
		else if (ictrl & SMU_ICTRL_5M_RAMP) range = SMU_1uA_RANGE;
		else if (ictrl & SMU_ICTRL_500M_RAMP) range = SMU_10nA_RANGE;
		else range = SMU_100pA_RANGE;
    }
    return range;
}


// 전압 레인지 컨트롤 신호를 쓰는 루틴
void write_smu_vctrl(int smu_ch, UINT16 vctrl)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
    //기존회로
    //UINT8 *addr;
    //smu_ctrl_reg[smu_ch].vctrl = vctrl;
    //
    //addr = (UINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS0_ADDR);
    //*addr = (UINT8)((((tmp_current_vrange)|vctrl) ^ SMU_VCTRL_XORMASK) & 0xFF); 
    ////*addr = (UINT8)((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF);    

    //2018.12.18 F5500 회로
	//UINT16 *sRangeAddr, *mRangeAddr;
      
    smu_ctrl_reg[smu_ch].vctrl = vctrl;
        
//    sRangeAddr = (UINT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_SRANGE_CS);
//    mRangeAddr = (UINT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_MRANGE_CS);
//
//
//    *sRangeAddr = (UINT16)((vctrl ^ SMU_VCTRL_XORMASK) & 0x00FF);
//    *mRangeAddr = (UINT16)(((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF00) >> 8);


	// MIO_SMU_WR(smu_ch, SMU_SRANGE_CS, (u32)((vctrl ^ SMU_VCTRL_XORMASK) & 0x00FF));
	// MIO_SMU_WR(smu_ch, SMU_MRANGE_CS, (u32)(((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF00) >> 8));

	// ADG451 Low Active(0 == ON)
	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VSRANGE_WI, (u32)((vctrl ^ SMU_VCTRL_XORMASK) & 0x00FF), 0xFFFFFFFF); // EP for VDAC_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VSRANGE_TI, 1); // EP for VDAC_TI // write pulse

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VMRANGE_WI, (u32)(((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF00) >> 8), 0xFFFFFFFF); // EP for VDAC_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VMRANGE_TI, 1); // EP for VDAC_TI // write pulse
	
    //printf("sRangeAddr = %04X mRangeAddr = %04X, vctrl =%04X\n", *sRangeAddr, *mRangeAddr, vctrl);

}

//============
// not used
// void write_smu_vsrc_ctrl(int smu_ch, UINT8 vsrc_ctrl)
// {
// 	//UINT8 *addr;
// 	UINT8 vctrl;
//   	vctrl = (smu_ctrl_reg[smu_ch].vctrl & ~SMU_VCTRL_SRC_MASK) | vsrc_ctrl;
//   	smu_ctrl_reg[smu_ch].vctrl = vctrl;
    
//   	//addr = (UINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_SRANGE_CS);
    
//   	//*addr = (UINT8)((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF);

// 	MIO_SMU_WR(smu_ch, SMU_SRANGE_CS, (u32)((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF));
// }

// not used
// void write_smu_vmsr_ctrl(int smu_ch, UINT8 vmsr_ctrl)
// {
//   	//UINT8 *addr;
// 	UINT8 vctrl;
  
// 	vctrl = (smu_ctrl_reg[smu_ch].vctrl & ~SMU_VCTRL_MSR_MASK) | vmsr_ctrl;
//   	smu_ctrl_reg[smu_ch].vctrl = vctrl;
    
//   	//addr = (UINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_SRANGE_CS);
    
//   	//*addr = (UINT8)((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF);    

// 	MIO_SMU_WR(smu_ch, SMU_SRANGE_CS, (u32)((vctrl ^ SMU_VCTRL_XORMASK) & 0xFF));
// }
//=============

// Compensation 컨트롤 신호를 쓰는 루틴
void write_smu_comp_ctrl(int smu_ch, UINT8 comp_ctrl)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);	

//    UINT8 *addr;
  
	comp_ctrl = (comp_ctrl ^ SMU_COMP_CTRL_XORMASK) & 0xFF;
    smu_ctrl_reg[smu_ch].comp_ctrl = comp_ctrl;
    
//    addr = (UINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_COMP_SW_CS);
//    
//   	*addr = (UINT8)((comp_ctrl ^ SMU_COMP_CTRL_XORMASK) & 0xFF);


	// MIO_SMU_WR(smu_ch, SMU_COMP_SW_CS, (u32)((comp_ctrl ^ SMU_COMP_CTRL_XORMASK) & 0xFF));

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ERRAMP_TR_WI, (u32)comp_ctrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ERRAMP_TR_TI, 1); // EP for IRANGE_CON_TI // write pulse


}

////////////////////////////////////////////////////////////////////////////////////////////////////////
// 기존 회로
// 전류 레인지 컨트롤 신호를 쓰는 루틴
//void write_smu_ictrl(int smu_ch, UINT32 ictrl)
//{
//    VUINT8* pdata;
//    VUINT8* pctrl;
//    UINT32 prev_ictrl, masked_ictrl;
//    UINT8 prev_ictrl_porta, prev_ictrl_portb, prev_ictrl_portc,
//    ictrl_porta, ictrl_portb, ictrl_portc,
//    masked_ictrl_porta, masked_ictrl_portb, masked_ictrl_portc;
//    
//    pdata = (VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS3_ADDR); //U32 -> U30,U34(Data)
//    pctrl = (VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS4_ADDR); //U35 -> U37(CLK)
//    
//    prev_ictrl = smu_ctrl_reg[smu_ch].ictrl;
//    smu_ctrl_reg[smu_ch].ictrl = ictrl;
//    
//    prev_ictrl_porta = (UINT8)prev_ictrl;
//    prev_ictrl_portb = (UINT8)(prev_ictrl>>8);
//    prev_ictrl_portc = (UINT8)(prev_ictrl>>16);
//    ictrl_porta = (UINT8)ictrl;
//    ictrl_portb = (UINT8)(ictrl>>8);
//    ictrl_portc = (UINT8)(ictrl>>16);
//    
//    masked_ictrl  = ictrl ^ SMU_ICTRL_XORMASK;
//    masked_ictrl_porta = (UINT8)masked_ictrl;
//    masked_ictrl_portb = (UINT8)(masked_ictrl>>8);
//    masked_ictrl_portc = (UINT8)(masked_ictrl>>16);
//    
//    if (prev_ictrl_portc != ictrl_portc)
//    {
//    	*pdata = masked_ictrl_portc;
//    	*pctrl = 0x0B;
//    	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    	*pctrl = 0x0F;
//    	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    }
//    
//    if (prev_ictrl_porta != ictrl_porta)
//    {
//    	*pdata = masked_ictrl_porta;
//    	*pctrl = 0x0E;
//    	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    	*pctrl = 0x0F;
//    	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    }
//    
//    if (prev_ictrl_portb != ictrl_portb)
//    {
//    	*pdata = masked_ictrl_portb;
//    	*pctrl = 0x0D;
//	   	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    	*pctrl = 0x0F;
//    	Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    }
//}

//void write_smu_ictrl_init(int smu_ch, UINT32 ictrl)
//{
//    VUINT8* pdata;
//    VUINT8* pctrl;
//    UINT32 masked_ictrl;
//    UINT8 ictrl_porta, ictrl_portb, ictrl_portc,
//    	  masked_ictrl_porta, masked_ictrl_portb, masked_ictrl_portc;
//    
//    pdata = (VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS3_ADDR);
//    pctrl = (VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS4_ADDR);
//        
//    smu_ctrl_reg[smu_ch].ictrl = ictrl;
//       
//    ictrl_porta = (UINT8)ictrl;
//    ictrl_portb = (UINT8)(ictrl>>8);
//    ictrl_portc = (UINT8)(ictrl>>16);
//    
//    masked_ictrl  = ictrl ^ SMU_ICTRL_XORMASK;
//    masked_ictrl_porta = (UINT8)masked_ictrl;
//    masked_ictrl_portb = (UINT8)(masked_ictrl>>8);
//    masked_ictrl_portc = (UINT8)(masked_ictrl>>16);
//    
//   	*pdata = masked_ictrl_portc;
//    *pctrl = 0x0B;
//    Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    *pctrl = 0x0F;
//    Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    
//    *pdata = masked_ictrl_porta;
//    *pctrl = 0x0E;
//    Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    *pctrl = 0x0F;
//    Delay_us(1500); // for (delay=0; delay<5000; delay++);
//       
//    *pdata = masked_ictrl_portb;
//    *pctrl = 0x0D;
//	  Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    *pctrl = 0x0F;
//    Delay_us(1500); // for (delay=0; delay<5000; delay++);
//    
//}


////2017.09.26T Per_pin 회로
//// 전류 레인지 컨트롤 신호를 쓰는 루틴
//void write_smu_ictrl(int smu_ch, UINT32 ictrl)
//{
//    VUINT16* pictrlData;
//	VUINT8* poutRlyData;
//
//	UINT32 prev_ictrl, masked_ictrl;
//	UINT16 prev_loc_ictrl, current_ictrl;
//	UINT8 prev_loc_outRly, current_outRly;
//
//	// Ix10/, Ix10, 5_RAMP/, 500_RAMP/, 50k_RAMP/, 5M_RAMP/, 5<M>, 500<M>, >500<M>
//	pictrlData = (VUINT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_IRANGE_CS);
//
//	// 50k_RELAY, 5M_RELAY, GRD_GND_RELAY, OUPUT1_RELAY, OUTPUT2_RELAY
//	poutRlyData = (VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_CS3_ADDR);
//
//
//	prev_ictrl = smu_ctrl_reg[smu_ch].ictrl;
//    smu_ctrl_reg[smu_ch].ictrl = ictrl;
//
//
//	prev_loc_ictrl = (UINT16)prev_ictrl;
//	prev_loc_outRly = (UINT8)(prev_ictrl>>16);
//
//
//	current_ictrl = (UINT16)ictrl;
//	current_outRly = (UINT8)(ictrl>>16);
//
//	masked_ictrl = ictrl ^ SMU_ICTRL_XORMASK;
//
//
//	if (prev_loc_ictrl != current_ictrl)
//	{
//		*pictrlData = (UINT16)masked_ictrl;
//		Delay_us(1500);
//	}
//
//	if(prev_loc_outRly != current_outRly)
//	{
//		*poutRlyData = (UINT8)(masked_ictrl>>16);
//		Delay_us(1500);
//	}
//}


//2018.12.18 F5500 회로
// 전류 레인지 컨트롤 신호를 쓰는 루틴
void write_smu_ictrl(int smu_ch, UINT32 ictrl)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
    //VUINT16* pictrlData;

	UINT32 prev_ictrl, masked_ictrl;
    UINT32 prev_loc_ictrl, current_ictrl;

	// 5M_RELAY, 50k_RELAY, '0', >500<M>, 500<M>, 5<M>, 5M_RAMP/, 50k_RAMP/, 500_RAMP/, 5_RAMP/, '0', '0', Ix10, Ix10/(LSB)
	//pictrlData = (VUINT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_IRANGE_CS);

	prev_ictrl = smu_ctrl_reg[smu_ch].ictrl;
    smu_ctrl_reg[smu_ch].ictrl = ictrl;

	prev_loc_ictrl = prev_ictrl;                
	current_ictrl = ictrl;	

	masked_ictrl = ictrl ^ SMU_ICTRL_XORMASK;

	if (prev_loc_ictrl != current_ictrl)
	{
		//*pictrlData = (UINT16)masked_ictrl;
		//MIO_SMU_WR(smu_ch, SMU_IRANGE_CS, (u32)masked_ictrl);

		SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IRANGE_CON_WI, (u32)masked_ictrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
		ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IRANGE_CON_TI, 1); // EP for IRANGE_CON_TI // write pulse
		
		//Delay_us(500);
		//Delay_us(1000);
		Delay_us(200);		
	}
}

//2018.12.18 F5500 회로
void write_smu_ictrl_init(int smu_ch, UINT32 ictrl)
{
    //VUINT16* pictrlData;

	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
	UINT32 masked_ictrl;
	//UINT32 current_ictrl;

	//pictrlData = (VUINT16 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_IRANGE_CS);

    smu_ctrl_reg[smu_ch].ictrl = ictrl;

	masked_ictrl = ictrl ^ SMU_ICTRL_XORMASK;
	
	//*pictrlData = (UINT16)masked_ictrl;

	// MIO_SMU_WR(smu_ch, SMU_IRANGE_CS, (u32)masked_ictrl);

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IRANGE_CON_WI, (u32)masked_ictrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IRANGE_CON_TI, 1); // EP for IRANGE_CON_TI // write pulse
	
	Delay_us(1500);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////

// sbcho@20211217 HVSMU
//설정하고자 하는 전압레인지를 위한 컨트롤 신호를 생성하는 루틴
UINT16 to_smu_vctrl(int vrange)
{
    UINT16 vctrl;

    switch (vrange) 
    {
        case SMU_2V_RANGE    : vctrl = SMU_2V_CTRL;    break;
		case SMU_5V_RANGE    : vctrl = SMU_5V_CTRL;    break;
        case SMU_20V_RANGE   : vctrl = SMU_20V_CTRL;   break;
        case SMU_40V_RANGE   : vctrl = SMU_40V_CTRL;   break;
		case SMU_200V_RANGE   : vctrl = SMU_200V_CTRL;   break;
        default: vctrl = SMU_2V_CTRL;
    }
    //printf("vrange = %d\n", vrange);
    return vctrl;
}

// 전류 공급시 설정하고자 하는 전류레인지를 위한 컨트롤 신호를 생성하는 루틴
TSmuCtrl to_smu_isrc_ctrl(int smu_ch, int irange)
{
    TSmuCtrl ctrl;
    
    ctrl.comp_ctrl = 0x00;

    switch (irange) 
    {
		  case SMU_100mA_RANGE: 
			  ctrl.ictrl = SMU_100mA_CTRL; 
			  ctrl.comp_ctrl = SMU_IX10_COMP;
			  break;
		  case SMU_10mA_RANGE: 
			  ctrl.ictrl = SMU_10mA_CTRL;
			  break;
		  case SMU_1mA_RANGE: 
			  ctrl.ictrl = SMU_1mA_CTRL;
			  ctrl.comp_ctrl = SMU_IX10_COMP;
			  break;
		  case SMU_100uA_RANGE: 
			  ctrl.ictrl = SMU_100uA_CTRL; 
			  break;
		  case SMU_10uA_RANGE: 
			  ctrl.ictrl = SMU_10uA_CTRL;
			  ctrl.comp_ctrl = SMU_IX10_COMP;
			  break;
		  case SMU_1uA_RANGE: 
			  ctrl.ictrl = SMU_1uA_CTRL;
			  ctrl.comp_ctrl = SMU_5M_COMP;
			  break;
		  case SMU_100nA_RANGE: 
			  ctrl.ictrl = SMU_100nA_CTRL;
			  ctrl.comp_ctrl = SMU_IX10_COMP | SMU_5M_COMP;
			  break;
		  case SMU_10nA_RANGE: 
			  ctrl.ictrl = SMU_10nA_CTRL; 
			  ctrl.comp_ctrl = SMU_5M_COMP;
			  break;
		  case SMU_1nA_RANGE: 
			  ctrl.ictrl = SMU_1nA_CTRL;
			  ctrl.comp_ctrl = SMU_IX10_COMP | SMU_5M_COMP;
			  break;
		  default: 
			  ctrl.ictrl =  SMU_100mA_CTRL; 
			  ctrl.comp_ctrl = SMU_IX10_COMP;
    }
    
    ctrl.ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MASK) | ctrl.ictrl;  // SMU_ICTRL_MASK = 0x03073F

    return ctrl;
}


// 전류 측정시 설정하고자 하는 전류레인지를 위한 컨트롤 신호를 생성하는 루틴
TSmuCtrl to_smu_imsr_ctrl(int smu_ch, int irange)
{
    TSmuCtrl ctrl;
	
	ctrl.comp_ctrl = 0x00;
    
   	switch (irange) 
    {
      case SMU_100mA_RANGE: 
          ctrl.ictrl = SMU_100mA_CTRL; 
          ctrl.comp_ctrl = SMU_IX10_COMP;
          break;
      case SMU_10mA_RANGE: 
          ctrl.ictrl = SMU_10mA_CTRL;
          break;
      case SMU_1mA_RANGE: 
          ctrl.ictrl = SMU_1mA_CTRL;
          ctrl.comp_ctrl = SMU_IX10_COMP;
          break;
      case SMU_100uA_RANGE: 
          ctrl.ictrl = SMU_100uA_CTRL; 
          break;
      case SMU_10uA_RANGE: 
          ctrl.ictrl = SMU_10uA_CTRL;
          ctrl.comp_ctrl = SMU_IX10_COMP;
          break;
      case SMU_1uA_RANGE: 
          ctrl.ictrl = SMU_1uA_CTRL;
          break;
      case SMU_100nA_RANGE: 
          ctrl.ictrl = SMU_100nA_CTRL;
          ctrl.comp_ctrl = SMU_IX10_COMP;
          break;
      case SMU_10nA_RANGE: 
          ctrl.ictrl = SMU_10nA_CTRL; 
          break;
      case SMU_1nA_RANGE: 
          ctrl.ictrl = SMU_1nA_CTRL;
          ctrl.comp_ctrl = SMU_IX10_COMP;
          break;
      default: 
          ctrl.ictrl =  SMU_100mA_CTRL; 
          ctrl.comp_ctrl = SMU_IX10_COMP;
    }
    
    ctrl.ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MASK) | ctrl.ictrl;  // SMU_ICTRL_MASK = 0x03073F

    return ctrl;
}

// not used
void change_smu_ictrl_debug(int smu_ch, UINT32 ictrl)
{
    UINT32 temp_ictrl;
        
    // Gain Adjust JFET (Ix10/, Ix10) All ON
    temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_IX10_MASK) | SMU_ICTRL_IX10;
    write_smu_ictrl(smu_ch, temp_ictrl);
   
	
	//Delay_us(2000); ??
    //Delay_us(1000); //jhcho (2013.02.13)
    Delay_us(3000);
        
    ////////////////////////////////////////////////////////////////////////////////////////////   
    // <Range 저항을 작은 값으로 바꿔야하는 경우 (range up)> //Relay on, RAMP on
    //  설정 변경 순서는 아래와 같다.
    //		1)Range Relay 설정 변경 
    //		2)RAMP 설정 변경  
    //		3)Current Measure JFET 설정 변경 
    ////////////////////////////////////////////////////////////////////////////////////////////
    if ((ictrl & SMU_ICTRL_RAMP_MASK) > (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RAMP_MASK)) 
    {
        // Range Relay 설정 변경
		if ((ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RELAY_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl & SMU_ICTRL_RELAY_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			Delay_us(3000); // Sleep(1);
		}

        // Current Measure JFET 설정 변경 
		if ((ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_MJFET_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl & SMU_ICTRL_MJFET_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			Delay_us(3000); // Sleep(1);            
		}

        // RAMP 설정 변경 
        temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl & SMU_ICTRL_RAMP_MASK);
	    write_smu_ictrl(smu_ch, temp_ictrl);
	    //Delay_us(1500); // Sleep(1);
		Delay_ms(10); // 추가 (20070124)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////   
    // <Range 저항을 큰 값으로 바꿔야하는 경우 (range down)> //RAMP off, RLY off
    //  설정 변경 순서는 아래와 같다.
    //		1)RAMP 설정 변경
    //		2)Range Relay 설정 변경  
    //		3)Current Measure JFET 설정 변경 
    ////////////////////////////////////////////////////////////////////////////////////////////
    else if ((ictrl & SMU_ICTRL_RAMP_MASK) < (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RAMP_MASK)) 
    {
        // RAMP 설정 변경 
        temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl & SMU_ICTRL_RAMP_MASK);
	    write_smu_ictrl(smu_ch, temp_ictrl);
	    //Delay_us(1500); // Sleep(1);
        Delay_ms(20); //
        
        // Current Measure JFET 설정 변경 
		if ((ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_MJFET_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl & SMU_ICTRL_MJFET_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			Delay_us(3000); // Sleep(1);
		}
         
        // Range Relay 설정 변경
		if ((ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RELAY_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl & SMU_ICTRL_RELAY_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			Delay_us(3000); // Sleep(1);
		}
    }
    
    // GAIN 조절 JFET 설정 변경
    temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_IX10_MASK) | (ictrl & SMU_ICTRL_IX10_MASK);
    write_smu_ictrl(smu_ch, temp_ictrl);
    
	Delay_us(3000); // Delay_us(2000); //jhcho (2013.02.13)
//	Delay_ms(10); // for debug
}

void change_smu_ictrl(int smu_ch, UINT32 ictrl)
{
    UINT32 temp_ictrl;
        
    // Gain Adjust JFET (Ix10/, Ix10) All ON --> 빨리 하지 않으면 전압이 크게튄다
    temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_IX10_MASK) | SMU_ICTRL_IX10;
	
    write_smu_ictrl(smu_ch, temp_ictrl);
	  //Delay_us(2000); 
	//Delay_us(200); 

    ////////////////////////////////////////////////////////////////////////////////////////////   
    // <Range 저항을 작은 값으로 바꿔야하는 경우 (range up)>
    //  설정 변경 순서는 아래와 같다.
    //		1)Range Relay 설정 변경 
    //		2)RAMP 설정 변경  
    //		3)Current Measure JFET 설정 변경 
    ////////////////////////////////////////////////////////////////////////////////////////////
    if ((ictrl & SMU_ICTRL_RAMP_MASK) > (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RAMP_MASK)) 
    {
		// Range Relay 설정 변경
		if ((ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RELAY_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl & SMU_ICTRL_RELAY_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			//Delay_us(2000); // Sleep(1);
		}

		// RAMP 설정 변경 
		temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl & SMU_ICTRL_RAMP_MASK);
		write_smu_ictrl(smu_ch, temp_ictrl);
		//Delay_us(15000); // 추가 (20070124) // 10ms 이상이 아니면 파형이 튄다.
		Delay_us(800);

		// Current Measure JFET 설정 변경 
		if ((ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_MJFET_MASK))
		{
			temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl & SMU_ICTRL_MJFET_MASK);
			write_smu_ictrl(smu_ch, temp_ictrl);
			//Delay_us(2000); // Sleep(1);            
		}
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////   
    // <Range 저항을 큰 값으로 바꿔야하는 경우 (range down)>
    //  설정 변경 순서는 아래와 같다.
    //		1)RAMP 설정 변경
    //		2)Range Relay 설정 변경  
    //		3)Current Measure JFET 설정 변경 
    ////////////////////////////////////////////////////////////////////////////////////////////
    else if ((ictrl & SMU_ICTRL_RAMP_MASK) < (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RAMP_MASK)) 
    {
      // Range Relay 설정 변경
		  if ((ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_RELAY_MASK))
		  {
			  temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl & SMU_ICTRL_RELAY_MASK);
			  write_smu_ictrl(smu_ch, temp_ictrl);
			  //Delay_us(2000); // Sleep(1);
			  //Delay_us(200); // Sleep(1);
		  }

      // RAMP 설정 변경 
      temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl & SMU_ICTRL_RAMP_MASK);
	    write_smu_ictrl(smu_ch, temp_ictrl);
      // 2017
	    //Delay_us(20000); // 10ms 이상이 아니면 파형이 튄다.
		//Delay_us(200); // 
		Delay_us(800); // 
		//Delay_us(19000); // 


      // Current Measure JFET 설정 변경 
		  if ((ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[smu_ch].ictrl & SMU_ICTRL_MJFET_MASK))
		  {
			  temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl & SMU_ICTRL_MJFET_MASK);
			  write_smu_ictrl(smu_ch, temp_ictrl);
        // 2017
			  //Delay_us(2000);
			  //Delay_us(200);
		  }
    }
    
    // GAIN 조절 JFET 설정 변경
    temp_ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~SMU_ICTRL_IX10_MASK) | (ictrl & SMU_ICTRL_IX10_MASK);
    write_smu_ictrl(smu_ch, temp_ictrl);
	  //Delay_us(2000); // Sleep(1);
	//Delay_us(200);
}

void change_smu_ictrl_multi(int selectCnt, int *p_ch, TSmuCtrl *ictrl)
{
	UINT32 temp_ictrl[NO_OF_SMU];
	int cnt = 0;
	int mode_range_up[NO_OF_SMU];
	int mode_range_down[NO_OF_SMU];

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		// Gain Adjust JFET (Ix10/, Ix10) All ON --> 빨리 하지 않으면 전압이 크게튄다
	    temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_IX10_MASK) | SMU_ICTRL_IX10;
    	write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
	}


 	Delay_us(2000); 

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK) > (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK)) 
		{
			mode_range_up[p_ch[cnt]] = 1;
			mode_range_down[p_ch[cnt]] = 0;
		}
		else if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK) < (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK)) 
		{
			mode_range_up[p_ch[cnt]] = 0;
			mode_range_down[p_ch[cnt]] = 1;
		}
		else
		{
			mode_range_up[p_ch[cnt]] = 0;
			mode_range_down[p_ch[cnt]] = 0;	
		}
	}
	


	// Range Relay 설정 변경
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		////////////////////////////////////////////////////////////////////////////////////////////   
		// <Range 저항을 작은 값으로 바꿔야하는 경우 (range up)>
		//	설정 변경 순서는 아래와 같다.
		//		1)Range Relay 설정 변경 
		//		2)RAMP 설정 변경  
		//		3)Current Measure JFET 설정 변경 
		////////////////////////////////////////////////////////////////////////////////////////////
		if(mode_range_up[p_ch[cnt]] == 1)
		{
		  	// Range Relay 설정 변경
			if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK))
			{
				temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK);
				write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
				//Delay_us(2000); // Sleep(1);
			}
		}
		    ////////////////////////////////////////////////////////////////////////////////////////////   
	    // <Range 저항을 큰 값으로 바꿔야하는 경우 (range down)>
	    //  설정 변경 순서는 아래와 같다.
	    //		1)RAMP 설정 변경
	    //		2)Range Relay 설정 변경  
	    //		3)Current Measure JFET 설정 변경 
	    ////////////////////////////////////////////////////////////////////////////////////////////
	    else if(mode_range_down[p_ch[cnt]] == 1)
	    {
      		// Range Relay 설정 변경
		  	if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK) != (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK))
		  	{
				temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_RELAY_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RELAY_MASK);
			  	write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
			 	 //Delay_us(2000); // Sleep(1);
		  	}
		}
	}



	Delay_us(2000); // Sleep(1);


	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(mode_range_up[p_ch[cnt]] == 1)
    	{
			// RAMP 설정 변경 
			temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK);
			write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
			//Delay_us(15000); // 추가 (20070124) // 10ms 이상이 아니면 파형이 튄다.
		}
		else if(mode_range_down[p_ch[cnt]] == 1)
    	{
			// RAMP 설정 변경 
			temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_RAMP_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_RAMP_MASK);
			write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
			// 2017
			//Delay_us(20000); // 10ms 이상이 아니면 파형이 튄다.
		}
	}


	Delay_us(20000); // 10ms 이상이 아니면 파형이 튄다.
	
	
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(mode_range_up[p_ch[cnt]] == 1)
		{
			// Current Measure JFET 설정 변경 
		  	if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK))
		  	{
			  	temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK);
			  	write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
			  	//Delay_us(2000); // Sleep(1);            
		  	}
		}

		else if(mode_range_down[p_ch[cnt]] == 1)
		{
			
			// Current Measure JFET 설정 변경 
		  	if ((ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK) != (smu_ctrl_reg[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK))
		  	{
				temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_MJFET_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_MJFET_MASK);
			  	write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
	    		// 2017
			  	//Delay_us(2000);
		  	}
		}
	}


	Delay_us(2000);
	
	
	// GAIN 조절 JFET 설정 변경
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		temp_ictrl[p_ch[cnt]] = (smu_ctrl_reg[p_ch[cnt]].ictrl & ~SMU_ICTRL_IX10_MASK) | (ictrl[p_ch[cnt]].ictrl & SMU_ICTRL_IX10_MASK);
		write_smu_ictrl(p_ch[cnt], temp_ictrl[p_ch[cnt]]);
	}
	

	Delay_us(2000); // Sleep(1);	
	
}

void change_smu_isrc_range(int smu_ch, int irange)
{
    TSmuCtrl ctrl;

    ctrl = to_smu_isrc_ctrl(smu_ch, irange);
    
    change_smu_ictrl(smu_ch, ctrl.ictrl); 

    write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl);//뒤에해야 튀는게 없어진다.
}


void change_smu_imsr_range(int smu_ch, int irange)
{
	TSmuCtrl ctrl;

	//기존 회로
	if(  smu_ctrl_reg[smu_ch].src_val == 0.0 ) //출력전압이 0일때
	{
		ctrl = to_smu_imsr_ctrl(smu_ch, irange);
		change_smu_ictrl(smu_ch, ctrl.ictrl);
		write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl); //뒤에해야 튀는게 없어진다. 
	}
	else
	{
		ctrl = to_smu_imsr_ctrl(smu_ch, irange);
		change_smu_ictrl(smu_ch, ctrl.ictrl);  
		write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl);
	}

	/* ctrl = to_smu_imsr_ctrl(smu_ch, irange);
	write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl);

	change_smu_ictrl(smu_ch, ctrl.ictrl);*/
}

void change_smu_imsr_range_multi(int selectCnt, int *p_ch, TSmuCtrlReg *irange)
{
	TSmuCtrl ctrl[NO_OF_SMU];
  	int cnt;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		//기존 회로
		if(  smu_ctrl_reg[p_ch[cnt]].src_val == 0.0 ) //출력전압이 0일때
		{
			ctrl[p_ch[cnt]]	= to_smu_imsr_ctrl(p_ch[cnt], irange[p_ch[cnt]].imsr_rng);
		}
		else
		{
			ctrl[p_ch[cnt]]	= to_smu_imsr_ctrl(p_ch[cnt], irange[p_ch[cnt]].imsr_rng);
		}
				
	}

	change_smu_ictrl_multi(selectCnt, p_ch, ctrl);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		//기존 회로
  		if(  smu_ctrl_reg[p_ch[cnt]].src_val == 0.0 ) //출력전압이 0일때
  		{
			write_smu_comp_ctrl(p_ch[cnt], ctrl[p_ch[cnt]].comp_ctrl); //뒤에해야 튀는게 없어진다. 
		}
		else
		{
			write_smu_comp_ctrl(p_ch[cnt], ctrl[p_ch[cnt]].comp_ctrl); //뒤에해야 튀는게 없어진다. 
		}
	}
}

// not used
void write_smu_isrc_range(int smu_ch, int irange)
{
    TSmuCtrl ctrl;

    ctrl = to_smu_isrc_ctrl(smu_ch, irange);
    
    write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl);
    
    write_smu_ictrl(smu_ch, ctrl.ictrl);
}


void write_smu_imsr_range(int smu_ch, int irange)
{
    TSmuCtrl ctrl;

    ctrl = to_smu_imsr_ctrl(smu_ch, irange);
    
    write_smu_comp_ctrl(smu_ch, ctrl.comp_ctrl);
    
    write_smu_ictrl(smu_ch, ctrl.ictrl);
}


void write_smu_vrange(int smu_ch, int range)
{
	UINT16 vctrl;
	
	vctrl = to_smu_vctrl(range);
    write_smu_vctrl(smu_ch, vctrl);
}


//////////////////////////////////////////////////////////////////////////////////////
// ADC 동작 관련  루틴 
//////////////////////////////////////////////////////////////////////////////////////

void smu_adc_all()
{

}

void smu_adc_current(int ch)
{
	// single trigger

	// assumed: gndu_HRADC_enable()
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
	u32 cnt_loop = 0;
	bool ret_bool;

	// check trigger done
	while (true) {
		if(cnt_loop > 99)
		{
			smu_iadc_values[ch] = 0xFFFFFFFF;
			return;
		}

		ret_bool = IsTriggered(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_TRIG_TO, 0x01); // adc conversion done 
		if (ret_bool==true) {
			break;
		}
		cnt_loop += 1;
		Delay_us(10);
	}

	// read adc value
	// 24bit ADC
	smu_iadc_values[ch] = (INT32)GetWireOutValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_DAT_WO, 0xFFFFFFFF);
}



// // SMU SYNC. measure function
// void smu_adc_current(int ch)
// {
// 	int i;
// 	int adc_complete = 1;
	
// 	//smu_adc_conv_start(ch);

// 	for (i=0; i<10000; i++)
// 	{
//         //adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
//         adc_complete = (MIO_SMU_RD(ch,SMU_FPGA_STATE) >> 4) & 0x1;
// 		if(adc_complete == 0) break;
// 	}
	
// 	if(i == 10000)
// 		TRACE("SMU%d ADC Error.\n",ch + 1);

// 	//smu_iadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
// //	smu_iadc_values[ch] = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_H_ADDR) & 0xFFFF) << 16;
// //	smu_iadc_values[ch] += *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_L_ADDR) & 0xFFFF;

// 	smu_iadc_values[ch] = (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_H_ADDR) & 0xFFFF) << 16;
// 	smu_iadc_values[ch] += (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_L_ADDR) & 0xFFFF);
// }

//E5000 backup
//void smu_adc_current(int ch)
//{
//	int i;
//	int adc_complete = 1;
//
//	smu_adc_conv_start(ch);
//
//	for (i=0; i<10; i++)
//	{
//		//adc_complete = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_CS7_ADDR + SMU_ADC_BUSY_ADDR) & 0x1;
//        
//        adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
//		if(adc_complete == 0) break;
//	}
//	
//	//if(i == 9)
//	//	printf("ADC Error.\n");
//
//	smu_iadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
//
//}


void smu_adc_current_all(void)
{
	// To do
}

// void smu_adc_current_all(void)
// {
// 	int ch;
// 	int adc_complete = 1;

// 	smu_adc_conv_start_all();

	
// 	for(ch=0; ch<NO_OF_SMU; ch++)
// 	{
// 		if(smu_ctrl_reg[ch].used)
// 		{
//             //adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
//             adc_complete = (MIO_SMU_RD(ch, SMU_FPGA_STATE) >> 4) & 0x1;
// 			if(adc_complete == 0) break;
// 		}
// 	}

// 	for(ch=0; ch<NO_OF_SMU; ch++)
// 	{
// 		//smu_iadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
// 		smu_iadc_values[ch] = (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR) & 0x3FFFF);
// 	}
// }

void smu_adc_voltage(int ch)
{
	// single trigger
	// assumed: gndu_HRADC_enable()

	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
	u32 cnt_loop = 0;
	bool ret_bool;

	// check trigger done
	while (true) {
		if(cnt_loop > 99)
		{
			smu_vadc_values[ch] = 0xFFFFFFFF;
			return;
		}

		ret_bool = IsTriggered(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_TRIG_TO, 0x01); // adc conversion done 
		if (ret_bool==true) {
			break;
		}
		cnt_loop += 1;
		Delay_us(10);
	}

	// read adc value
	// 24bit ADC
	smu_vadc_values[ch] = (INT32)GetWireOutValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_DAT_WO, 0xFFFFFFFF);

}

// // SMU SYNC. measure function
// void smu_adc_voltage(int ch)
// {
// 	int i;
// 	int adc_complete = 1;

// 	//smu_adc_conv_start(ch);

// 	for (i=0; i<10000; i++)
// 	{
// 		//adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
// 		adc_complete = (MIO_SMU_RD(ch, SMU_FPGA_STATE) >> 4) & 0x1;
// 		if(adc_complete == 0) break;
// 	}
	
// 	if(i == 10000)
// 		TRACE("SMU%d ADC Error.\n",ch + 1);

// 	//smu_vadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
// //	smu_vadc_values[ch] = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_H_ADDR) & 0xFFFF) << 16;
// //	smu_vadc_values[ch] += *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_L_ADDR) & 0xFFFF;

// 	smu_iadc_values[ch] = (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_H_ADDR) & 0xFFFF) << 16;
// 	smu_iadc_values[ch] += (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR + SMU_ADC_D_SUM_L_ADDR) & 0xFFFF);

	
// }

//E5000 backup
//void smu_adc_voltage(int ch)
//{
//	int i;
//	int adc_complete = 1;
//
//	smu_adc_conv_start(ch);
//	
//	for (i=0; i<10; i++)
//	{
//		adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
//		if(adc_complete == 0) break;
//	}
//	
//	if(i == 9)
//		printf("ADC Error.\n");
//
//	smu_vadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
//}

void smu_adc_voltage_all(void)
{
	// To do
}
// void smu_adc_voltage_all(void)
// {
// 	int ch;
// 	int adc_complete = 1;
	
// 	smu_adc_conv_start_all();


// 	for(ch=0; ch<NO_OF_SMU; ch++)
// 	{
// 		if(smu_ctrl_reg[ch].used)
// 		{
// 			//adc_complete = (*(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE) >> 4) & 0x1;
// 			adc_complete = (MIO_SMU_RD(ch, SMU_FPGA_STATE) >> 4) & 0x1;
// 			if(adc_complete == 0) break;
// 		}
// 	}
	
// 	for(ch=0; ch<NO_OF_SMU; ch++)
// 	{
// 		//smu_vadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
// 		smu_iadc_values[ch] = (MIO_SMU_RD(ch, SMU_ADC_READ_ADDR) & 0x3FFFF);
// 	}
// }


void smu_adc_conv_start(int smu_ch)
{
	//*(VUINT8 *)(smu_ctrl_reg[smu_ch].base_addr + SMU_ADC_CNVST_ADDR) = 0x00; // dummy write for ADC Conversion Start
	// MIO_SMU_WR(smu_ch, SMU_ADC_CNVST_ADDR, 0x00000000);
	u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);

	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_TRIG_TI, 0); // trigger conversion
}

// void smu_adc_conv_start_all(void)
// {
// 	int ch;

// 	for(ch=0; ch<NO_OF_SMU; ch++)
// 	{
// 		//*(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_CNVST_ADDR) = 0x00; // dummy write for ADC Conversion Start
// 		MIO_SMU_WR(ch, SMU_ADC_CNVST_ADDR, 0x00000000);
// 	}

// }

//////////////////////////////////////////////////////////////////////////////////////
// 측정값 계산 관련  루틴 
//////////////////////////////////////////////////////////////////////////////////////

// AD변환된 값 레인지를 가지고 실제로 dut에 걸리는 전압 계산
float get_smu_vdut(int ch, int rng, float adc)
{
    if (without_smu_vmsr) 
		return (adc - adc_offset)/(smu_vmsr_ideal_gain[ch][rng] * adc_gain);

    return (adc - smu_vmsr_offset[ch][rng])/smu_vmsr_real_gain[ch][rng];
}


// 20070712 수정
// AD변환된 값과 레인지를 가지고 실제로 dut에 흐르는 전류 계산
float get_smu_idut(int ch, int rng, float adc)
{
  float dut;

	if (without_smu_imsr) 
	{
		dut = adc / smu_imsr_ideal_gain[ch][rng];
		return dut;
	}

  if (adc < 0) //부호 반대
	{	
		dut = (adc - smu_ipmsr_offset[ch][rng])/smu_ipmsr_real_gain[ch][rng];
	}
  else
	{
		dut = (adc - smu_inmsr_offset[ch][rng])/smu_inmsr_real_gain[ch][rng];
	}

	return dut; 
}

// not used
float get_smu_idut_leak(int ch, int rng, float adc, float vdut)
{
    float dut;

	if (without_smu_imsr)
	{
		dut = (adc - adc_offset)/(smu_imsr_ideal_gain[ch][rng]*adc_gain);
		return dut;
	}

	if (rng <= SMU_UPPER_LEAK_IRANGE)
	{ // 10nA이하의 레인지에서는 leakage측정으로 구한 offset을 이용한다
        if (adc < 0) //부호 반대
            dut = (adc - smu_ipmsr_offset[ch][rng] - smu_imsr_leak_gain[ch][rng]*vdut)/smu_ipmsr_real_gain[ch][rng];
        else
            dut = (adc - smu_inmsr_offset[ch][rng] - smu_imsr_leak_gain[ch][rng]*vdut)/smu_inmsr_real_gain[ch][rng];
    }
    else 
	{
        if (adc < 0) //부호 반대
            dut = (adc - smu_ipmsr_offset[ch][rng])/smu_ipmsr_real_gain[ch][rng];
        else
            dut = (adc - smu_inmsr_offset[ch][rng])/smu_inmsr_real_gain[ch][rng];
    }

	return dut;
}


// float adcval_to_float(INT32 adc_val)
// {
// 	//INT32 adc_val_int;
// 	float adc_val_float;
// 	//adc_val_int = 0x3FFFF & adc_val;
	
// 	adc_val_float = (float)( (adc_val * 10.0) / 262143.0 - 5.0);
// 	return adc_val_float;
// //	return 0;
// }

// 24bit HRADC
float adcval_to_float(INT32 adc_val)
{
	float adc_val_float;
	float LSB = (float)10.0 / (float)4294967040;		//4294967296 - 256(ADC Value 0xFFFF_FF00)
	adc_val_float = LSB*(float)adc_val;
	
	// // LTC2380 24bit, ref 5V ... -5V ~ +5V ... extented 32bit -2^31(-2147483648) ~ 2^31-1(2147483647)
	// // adc_val_float = (float)((adc_val * 10.0) / (float)4294967296);		// 10V/2^32
	// adc_val_float = (float)((adc_val * 10.0) / (float)16777215);		// 10V/2^24

	 return adc_val_float;
}




// // SMU SYNC. measure function
// void smu_adc_meas_cnt_send(int ch, int meas_cnt)
// {
// //	volatile unsigned int *addr;
// 	int plc_info;
	
// 	if(smu_pwr_line_freq == 60){plc_info = 0;}
// 	else if(smu_pwr_line_freq == 50){ plc_info = 1;}
// 	else{plc_info = 0; TRACE("plc value: %d\r\n", smu_pwr_line_freq);} 
	
// 	smu_ctrl_reg[ch].adc_plc_info = ((meas_cnt << 2) | (plc_info & 0x0003));

// //	addr = (volatile unsigned int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_WRITE_ADDR + SMU_ADC_PLC_INFO);
// //	*addr = smu_ctrl_reg[ch].adc_plc_info;

// 	MIO_SMU_WR(ch, SMU_ADC_WRITE_ADDR + SMU_ADC_PLC_INFO, smu_ctrl_reg[ch].adc_plc_info);
// }


//////////////////////////////////////////////////////////////////////////////////////
// Serial EEPROM 동작 관련 루틴 
//////////////////////////////////////////////////////////////////////////////////////

void smu_seeprom_cs_on(int ch)
{

//	VUINT8 *addr;

	//seeprom_cs_off();

	//io_eeprom_sequence(ch);
		
//	addr = (VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_SEEPROM_CS_ADDR);
//	*addr = 0x00;

	MIO_SMU_WR(ch, SMU_SEEPROM_CS_ADDR, 0x00000000);
}

//E5000 추가(2020.03.20_조성범)
//2020.03.20 I/O OUTPUT 보드 버퍼 Output Enable 신호('H'일 때 isolation, 'L'일 때 Enable)
//SMU CS에 Output Enable신호가 로직에서 제어되지면 eeprom은 신호타이밍이 달라 제어가 별도로 필요
void io_output1_eeprom_cs_on()
{
#if 0

    VUINT8 *addr;

    addr = (VUINT8 *)(IO_OUTPUT1_EEPROM_CS);
    *addr = 0x01;

#endif

}

void io_output2_eeprom_cs_on()
{
#if 0

    VUINT8 *addr;

    addr = (VUINT8 *)(IO_OUTPUT2_EEPROM_CS);
    *addr = 0x01;

#endif
}

void io_output3_eeprom_cs_on()
{
#if 0

    VUINT8 *addr;

    addr = (VUINT8 *)(IO_OUTPUT3_EEPROM_CS);
    *addr = 0x01;

#endif
}

void io_output_eeprom_cs_init()
{
#if SMU_DBG_POINT

    VUINT8 *addr;

    addr = (VUINT8 *)(IO_OUTPUT_EEPROMCS_INIT);
    *addr = 0x00;

#endif
}

void io_eeprom_sequence(int ch)
{
	io_output_eeprom_cs_init();
	if((0 <= ch) && (16 >= ch))
	{
		io_output1_eeprom_cs_on();
	}

	else if((17 <= ch) && (33 >= ch))
	{
		io_output2_eeprom_cs_on();
	}

	else if((34 <= ch) && (50 >= ch))
	{	
		io_output3_eeprom_cs_on();
	}
	else
	{
		return;
	}
}

void smu_seeprom_cs_off(void)
{
    int ch;
//    VUINT8 *addr;    

	for (ch=0; ch<NO_OF_SMU; ch++) 
	{
       // addr = (VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_CS7_ADDR + SMU_SEEPROM_CS_ADDR);
		//2018.12.18 F5500

		//io_eeprom_sequence(ch);

//		addr = (VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_SEEPROM_CS_ADDR);
//		 *addr = 0xFF;

		MIO_SMU_WR(ch, SMU_SEEPROM_CS_ADDR, 0x000000FF);
	}

	io_output_eeprom_cs_init();
}

// I+, I- read
// 현재 SMU가 전압 컨트롤 모드 인지 전류 컨트롤 모드 인지 판단
char read_smu_state(int ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
	char state;
	u32 val;

	val = GetWireOutValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IMODE_WO, 0xFFFFFFFF); 
	state = (char)(val & 0x000000FF);

	if ((state & SMU_STATE_MASK) == SMU_STATE_VMODE) state = 'V';  		
	else state = 'I';

	return state;
}



// char read_smu_state(int ch)
// {
//     //char state;
// 	char state2;
// //    char *addr;
    
// //    addr = (char *)(smu_ctrl_reg[ch].base_addr + SMU_FPGA_STATE);
//     //state = *addr;

// 	//printf("[SMU %d] s = %08X \n", ch, state);

// 	Delay_us(1);
// 	//state2 = *addr;
// 	state2 = MIO_SMU_RD(ch, SMU_FPGA_STATE);
	
// 	//printf("[SMU %d] 2nd = %08X \n", ch, state2);
		
// 	//if ((state & SMU_STATE_MASK) == SMU_STATE_VMODE) state = 'V';  		
// 	//else state = 'I'; < Original >

// 	/*if ((state & SMU_STATE_MASK) == SMU_STATE_VMODE) state2 = 'V';  		
// 	else state2 = 'I'; < SUCCESS > 
// 	return state;*/
	

// 	if ((state2 & SMU_STATE_MASK) == SMU_STATE_VMODE) state2 = 'V';  		
// 	else state2 = 'I';

// 	/*if ((state & SMU_STATE_MASK) == SMU_STATE_VMODE) state = 'V';  		
// 	else 
// 	{
// 		state2 = *addr;
// 		printf("[SMU %d] 2nd = %08X \n", ch, state2);
// 		if ((state & SMU_STATE_MASK) == SMU_STATE_VMODE) state = 'V';
// 		else state = 'I';
// 	}*/

// 	return state2;
// }

// not used
void smu_diag_on(int ch)
{
    write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl | SMU_ICTRL_DIAG);
}

// not used
void smu_diag_off(int ch)
{
    write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl & ~SMU_ICTRL_DIAG);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//기존 회로
//2015.12.22
//void smu_output_rly_on(int ch)
//{
//  write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl | SMU_OUTPUT1_REL); //sense
//	write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl | SMU_OUTPUT2_REL); //force
//}
//
//void smu_output_rly_off(int ch)
//{
//  write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl & ~SMU_OUTPUT1_REL); //sense
//	write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl & ~SMU_OUTPUT2_REL); //force
//}

////2017.09.26 Per_pin 회로
//void smu_output_rly_on(int ch)
//{
//	UINT32 ictrl;
//
//  // Only Test : I, V Filter Capacitor(0x05 : 10nF, 0x0A : 1nF)
//	*(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_IVDAC_Filter_CS) = 0x0A;
//
//	ictrl = (smu_ctrl_reg[ch].ictrl & ~(SMU_OUTPUT1_REL | SMU_OUTPUT2_REL)) | SMU_GRD_GND_REL;
//	write_smu_ictrl(ch, ictrl);
//}
//
//void smu_output_rly_off(int ch)
//{
//	UINT32 ictrl;
//
//	*(VUINT8 *)(smu_ctrl_reg[ch].base_addr + SMU_IVDAC_Filter_CS) = 0xFF;
//
//	ictrl = (smu_ctrl_reg[ch].ictrl | (SMU_OUTPUT1_REL | SMU_OUTPUT2_REL)) & ~SMU_GRD_GND_REL;
//	write_smu_ictrl(ch, ictrl);
//}

//2018.12.18 F5500 회로
//OUTPUT_RELAY_DATA
//OUTPUT_SENSE | OUTPUT_FORCE | 0 | 0 | FORCE_R | GRD_GND_R(LSB)
void smu_force_rly_on(int ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);


//    VUINT16 *out_rly_addr;
//
//    out_rly_addr = (VUINT16 *)(smu_ctrl_reg[ch].base_addr + SMU_OUTPUT_RLY);
//    *out_rly_addr = (UINT16) (SMU_FOCE_REL | SMU_OUT_FOCE_REL | SMU_OUT_SENS_REL);

	// MIO_SMU_WR(ch, SMU_OUTPUT_RLY, SMU_FOCE_REL | SMU_OUT_FOCE_REL | SMU_OUT_SENS_REL);

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_WI, (u32)SMU_FOCE_REL, 0xFFFFFFFF); // EP for DIAG_RELAY_WI // set ...
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_TI, 1);           // EP for DIAG_RELAY_TI // latch pulse
}

void smu_force_rly_off(int ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
//	VUINT16* out_rly_addr;
//
//    out_rly_addr = (VUINT16 *)(smu_ctrl_reg[ch].base_addr + SMU_OUTPUT_RLY);	
//    *out_rly_addr = (UINT16) (~(SMU_FOCE_REL | SMU_OUT_FOCE_REL | SMU_OUT_SENS_REL));

	// MIO_SMU_WR(ch, SMU_OUTPUT_RLY, ~(SMU_FOCE_REL | SMU_OUT_FOCE_REL | SMU_OUT_SENS_REL));

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_WI, (u32)(~(SMU_FOCE_REL)), 0xFFFFFFFF); // EP for DIAG_RELAY_WI // set ...
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_TI, 1) ;           // EP for DIAG_RELAY_TI // latch pulse

}

// void smu_input_rly_ctrl(int ch, int rly_ctrl)
// {
// //    VUINT16* in_rly_addr;

//     smu_ctrl_reg[ch].input_relay_ctrl = rly_ctrl;

// //    in_rly_addr = (VUINT16 *)(smu_ctrl_reg[ch].base_addr + SMU_INPUT_RLY);	
// //    *in_rly_addr = (UINT16) rly_ctrl;

// 	MIO_SMU_WR(ch, SMU_INPUT_RLY, (u32)rly_ctrl);
// }

// bit: [5]output_sense, [4]output, [1]force_r, [0]grd_gnd_r
void smu_force_rly_ctrl(int ch, int rly_ctrl)
{
//    VUINT16* in_rly_addr;
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);

    smu_ctrl_reg[ch].force_relay_ctrl = rly_ctrl;

//    in_rly_addr = (VUINT16 *)(smu_ctrl_reg[ch].base_addr + SMU_OUTPUT_RLY);	
//    *in_rly_addr = (UINT16) rly_ctrl;

	// MIO_SMU_WR(ch, SMU_OUTPUT_RLY, (u32)rly_ctrl);

	SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_WI, (u32)rly_ctrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_OUTP_RELAY_TI, 1); // EP for IRANGE_CON_TI // write pulse
}

// void smu_iv_dac_filter_ctrl(int ch, int filter_ctrl)
// {
// //	VUINT16* iv_dac_fil_addr;

// 	smu_ctrl_reg[ch].iv_dac_filter_ctrl = filter_ctrl;

// //    iv_dac_fil_addr = (VUINT16 *)(smu_ctrl_reg[ch].base_addr + SMU_IVDAC_Filter_CS);	
// //    *iv_dac_fil_addr = (UINT16) filter_ctrl;

// 	MIO_SMU_WR(ch, SMU_IVDAC_Filter_CS, (u32)filter_ctrl);
// }

void smu_rly_all_off(int ch)
{
//   smu_input_rly_ctrl(ch, 0x0000);
  smu_force_rly_ctrl(ch, 0x0000);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// GNDU
//////////////////////////////////////////////////////////////////////////////////////////////////////////

void init_gndu_ctrl_reg(void)
{
	gndu_ctrl_reg.min_vrange = GNDU_500mV_RANGE;
	gndu_ctrl_reg.max_vrange = GNDU_100V_RANGE;
			
	gndu_ctrl_reg.base_addr   = GNDU_ADDR;

    // 2018.12.18 F5500(input output relay off)
  	gndu_rly_all_off();//20190405 modify

}

void gndu_clear_calib_para(void)
{
	int vrange;
	
	gndu_vsrc_gain_calib = 1.0;
	gndu_vsrc_offset_calib = 0.0;
	
	for (vrange=0; vrange<NO_OF_VRANGE; vrange++)
	{
		gndu_vmsr_gain_calib[vrange] = 1.0;
		gndu_vmsr_offset_calib[vrange] = 0.0;
	}
}

// not used
void write_gndu_vmsr_range(int range)
{
	UINT8 vmsr_ctrl;
	
	vmsr_ctrl = to_gndu_vmsr_ctrl(range);
    write_gndu_vmsr_ctrl(vmsr_ctrl);
}


// not used
// 전압레인지에 따른 전압레인지 컨트롤값 계산
UINT8 to_gndu_vmsr_ctrl(int vrange)
{
    UINT8 vmsr_ctrl;

    switch (vrange) 
    {
        case GNDU_500mV_RANGE 	: vmsr_ctrl = GNDU_500mV_MSR_CTRL;   break;
    	case GNDU_2V_RANGE 	    : vmsr_ctrl = GNDU_2V_MSR_CTRL;   break;
        case GNDU_20V_RANGE     : vmsr_ctrl = GNDU_20V_MSR_CTRL;  break;
        case GNDU_40V_RANGE     : vmsr_ctrl = GNDU_40V_MSR_CTRL;  break;
        case GNDU_100V_RANGE    : vmsr_ctrl = GNDU_100V_MSR_CTRL; break;
        default: vmsr_ctrl = GNDU_100V_MSR_CTRL;
    }
    
    return vmsr_ctrl;
}

// not used
// 전압 레인지 설정값을 출력하는 루틴
void write_gndu_vmsr_ctrl(UINT8 vmsr_ctrl)
{
//    VUINT8 *addr;
	UINT8 vmsr_mux_ctrl;
  
	vmsr_mux_ctrl = (gndu_ctrl_reg.vmsr_mux_ctrl & ~GNDU_VMSR_CTRL_MASK) | vmsr_ctrl;
    gndu_ctrl_reg.vmsr_mux_ctrl = vmsr_mux_ctrl;
    
    //2018.12.18 F5500 회로
    //addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK2_ADDR);
    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_MRANGE_CS);
//   	*addr = (VUINT8)((vmsr_mux_ctrl ^ GNDU_VMSR_MUX_CTRL_XORMASK) & 0xFF);

	// MIO_GNDU_WR(GNDU_MRANGE_CS, (u32)((vmsr_mux_ctrl ^ GNDU_VMSR_MUX_CTRL_XORMASK) & 0xFF));

	SetWireInValue   (SLOT_CS0, SPI_SEL_M0, EP_ADRS__VM_RANGE_WI, (u32)vmsr_mux_ctrl, 0xFFFFFFFF); // EP for VM_RANGE_WI 
	ActivateTriggerIn(SLOT_CS0, SPI_SEL_M0, EP_ADRS__VM_RANGE_TI, 1); // EP for IRANGE_CON_TI // write pulse
}


// ADC MUX 설정값을 출력하는 루틴
void write_gndu_mux_ctrl(UINT8 mux_ctrl)
{
//    VUINT8 *addr;
	// UINT8 vmsr_mux_ctrl;
    
    
	//vmsr_mux_ctrl = (gndu_ctrl_reg.vmsr_mux_ctrl & ~GNDU_MUX_CTRL_MASK) | mux_ctrl;
    //gndu_ctrl_reg.vmsr_mux_ctrl = vmsr_mux_ctrl;

    //addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK2_ADDR);

//    //2018.12.18 F5500 회로
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_ADC_SEL_SW_CS);
//   	*addr = (VUINT8)((mux_ctrl ^ GNDU_VMSR_MUX_CTRL_XORMASK) & 0xFF);    


	// MIO_GNDU_WR(GNDU_ADC_SEL_SW_CS, (u32)((mux_ctrl ^ GNDU_VMSR_MUX_CTRL_XORMASK) & 0xFF));

	SetWireInValue   (SLOT_CS0, SPI_SEL_M0, EP_ADRS__ADC_IN_SEL_WI, (u32)((mux_ctrl ^ GNDU_VMSR_MUX_CTRL_XORMASK) & 0xFF), 0xFFFFFFFF); // EP for ADC_IN_SEL_WI 
	ActivateTriggerIn(SLOT_CS0, SPI_SEL_M0, EP_ADRS__ADC_IN_SEL_TI, 1); // EP for IRANGE_CON_TI // write pulse	
}




//// 1K, 100K, 10M, VM Relay 설정값을 출력하는 루틴
//void write_gndu_relay_ctrl1(UINT8 relay_ctrl1)
//{
//    VUINT8 *addr;
//  
//    gndu_ctrl_reg.relay_ctrl1 = relay_ctrl1;
//    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK1_ADDR);
//   	*addr = (VUINT8)((relay_ctrl1 ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF);    
//}
//
//
//// EXT, DIAG, 1GU, 1G Realy 설정값을 출력하는 루틴
//void write_gndu_relay_ctrl2(UINT8 relay_ctrl2)
//{
//    VUINT8 *addr;
//  
//    gndu_ctrl_reg.relay_ctrl2 = relay_ctrl2;
//    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK3_ADDR);
//   	*addr = (VUINT8)((relay_ctrl2 ^ GNDU_RELAY_CTRL2_XORMASK) & 0xFF);    
//}
//
//
//// 100, 10K, 1M, 100M Relay 설정값을 출력하는 루틴
//void write_gndu_relay_ctrl3(UINT8 relay_ctrl3)
//{
//    VUINT8 *addr;
//  
//    gndu_ctrl_reg.relay_ctrl3 = relay_ctrl3;
//    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK4_ADDR);
//   	*addr = (VUINT8)((relay_ctrl3 ^ GNDU_RELAY_CTRL3_XORMASK) & 0xFF);    
//}


//2018.12.18 F5500 회로
//100, 10K, 1M, 100M, 1K, 100K, 10M, VM Relay 설정값을 출력하는 루틴
void write_gndu_diag_relay_ctrl(UINT8 relay_ctrl)
{
//    VUINT8 *addr;
  
    gndu_ctrl_reg.diag_Rrange_relay_ctrl = relay_ctrl;
    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_DIAG_RLY_CS);
//   	*addr = (VUINT8)((relay_ctrl ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF);


	// MIO_GNDU_WR(GNDU_DIAG_RLY_CS, (u32)((relay_ctrl ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF));

	SetWireInValue   (SLOT_CS0, SPI_SEL_M0, EP_ADRS__DIAG_RELAY_WI, (u32)((relay_ctrl ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF), 0xFFFFFFFF); // EP for DIAG_RELAY_WI 
	ActivateTriggerIn(SLOT_CS0, SPI_SEL_M0, EP_ADRS__DIAG_RELAY_TI, 1); // EP for IRANGE_CON_TI // write pulse	
}

//EXT, DIAG, 1GU, 1G Realy 설정값을 출력하는 루틴
void write_gndu_diag_mod_relay_ctrl(UINT8 diag_relay_ctrl)
{
//    VUINT8 *addr;
  
    gndu_ctrl_reg.diag_mod_relay_ctrl = diag_relay_ctrl;
    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_DIAG_MOD_CON_CS);
//   	*addr = (VUINT8)((diag_relay_ctrl ^ GNDU_RELAY_CTRL2_XORMASK) & 0xFF);


	MIO_GNDU_WR(GNDU_DIAG_MOD_CON_CS, (u32)((diag_relay_ctrl ^ GNDU_RELAY_CTRL2_XORMASK) & 0xFF));
	
}

void write_gndu_out_relay_ctrl(UINT8 out_relay_ctrl)
{
//    VUINT8 *addr;
  
    gndu_ctrl_reg.output_relay_ctrl = out_relay_ctrl;
    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_OUTPUT_RLY);
//   	*addr = (VUINT8)((out_relay_ctrl ^ GNDU_RELAY_CTRL3_XORMASK) & 0xFF);

	//MIO_GNDU_WR(GNDU_OUTPUT_RLY, (u32)((out_relay_ctrl ^ GNDU_RELAY_CTRL3_XORMASK) & 0xFF));
	// MIO_GNDU_WR(GNDU_OUTPUT_RLY_TST, 0x1234);

	SetWireInValue   (SLOT_CS0, SPI_SEL_M0, EP_ADRS__OUTP_RELAY_WI, (u32)((out_relay_ctrl ^ GNDU_RELAY_CTRL3_XORMASK) & 0xFF), 0xFFFFFFFF); // EP for OUTP_RELAY_WI 
	ActivateTriggerIn(SLOT_CS0, SPI_SEL_M0, EP_ADRS__OUTP_RELAY_TI, 1); // EP for OUTP_RELAY_TI // write pulse	
}

//2018.12.18 F5500 회로
void write_gndu_in_relay_ctrl(UINT8 in_relay_ctrl)
{
//    VUINT16* in_rly_addr;

    gndu_ctrl_reg.input_relay_ctrl = in_relay_ctrl;

//    in_rly_addr = (VUINT16 *)(gndu_ctrl_reg.base_addr + GNDU_INPUT_RLY);	
//    *in_rly_addr = (UINT16) ((in_relay_ctrl ^ GNDU_RELAY_CTRL4_XORMASK) & 0xFF);

	MIO_GNDU_WR(GNDU_INPUT_RLY, (u32)((in_relay_ctrl ^ GNDU_RELAY_CTRL4_XORMASK) & 0xFF));
}

void gndu_100_relay_on(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 | GNDU_100_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_100_RELAY);
}

void gndu_1K_relay_on(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 | GNDU_1K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_1K_RELAY);
}

void gndu_10K_relay_on(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 | GNDU_10K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_10K_RELAY);
}

void gndu_100K_relay_on(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 | GNDU_100K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_100K_RELAY);
}

void gndu_1M_relay_on(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 | GNDU_1M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_1M_RELAY);
}

void gndu_10M_relay_on(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 | GNDU_10M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_10M_RELAY);
}

void gndu_100M_relay_on(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 | GNDU_100M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_100M_RELAY);
}

void gndu_1G_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_1G_RELAY);
    
    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl | GNDU_1G_RELAY);
}

void gndu_1GU_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_1GU_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl | GNDU_1GU_RELAY);
}

void gndu_ext_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_EXT_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl | GNDU_EXT_RELAY);
}

void gndu_diag_pogo_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_DIAG_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_in_relay_ctrl(gndu_ctrl_reg.input_relay_ctrl | GNDU_L_C_RELAY);
}
void gndu_diag_conn_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_DIAG_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_in_relay_ctrl(gndu_ctrl_reg.input_relay_ctrl | GNDU_SMU_IN_RELAY);
}


void gndu_vm_relay_on(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 | GNDU_VM_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl | GNDU_VM_RELAY);
}

//2017.12.19 추가
void gndu_s_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_S_RELAY);
    
    //2018.12.18 F5500 회로
    write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl | GNDU_S_RELAY);
}
void gndu_s_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_S_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl & ~GNDU_S_RELAY);
}
void gndu_f_relay_on(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_F_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl | GNDU_F_RELAY);
}
void gndu_f_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_F_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl & ~GNDU_S_RELAY);
}
//

void gndu_100_relay_off(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 & ~GNDU_100_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_100_RELAY);
}

void gndu_1K_relay_off(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 & ~GNDU_1K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_1K_RELAY);
}

void gndu_10K_relay_off(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 & ~GNDU_10K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_10K_RELAY);
}

void gndu_100K_relay_off(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 & ~GNDU_100K_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_100K_RELAY);
}

void gndu_1M_relay_off(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 & ~GNDU_1M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_1M_RELAY);
}

void gndu_10M_relay_off(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 & ~GNDU_10M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_10M_RELAY);
}

void gndu_100M_relay_off(void)
{
	//write_gndu_relay_ctrl3(gndu_ctrl_reg.relay_ctrl3 & ~GNDU_100M_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_100M_RELAY);
}

void gndu_1G_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_1G_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl & ~GNDU_1G_RELAY);
}

void gndu_1GU_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_1GU_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl & ~GNDU_1GU_RELAY);
}

void gndu_vm_relay_off(void)
{
	//write_gndu_relay_ctrl1(gndu_ctrl_reg.relay_ctrl1 & ~GNDU_VM_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_relay_ctrl(gndu_ctrl_reg.diag_Rrange_relay_ctrl & ~GNDU_VM_RELAY);
}

void gndu_ext_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_EXT_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_diag_mod_relay_ctrl(gndu_ctrl_reg.diag_mod_relay_ctrl & ~GNDU_EXT_RELAY);
}

void gndu_diag_pogo_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 & ~GNDU_DIAG_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_in_relay_ctrl(gndu_ctrl_reg.input_relay_ctrl & ~GNDU_L_C_RELAY);
}

void gndu_diag_conn_relay_off(void)
{
	//write_gndu_relay_ctrl2(gndu_ctrl_reg.relay_ctrl2 | GNDU_DIAG_RELAY);

    //2018.12.18 F5500 회로
    write_gndu_in_relay_ctrl(gndu_ctrl_reg.input_relay_ctrl & ~GNDU_SMU_IN_RELAY);
}


//2018.12.18 F5500 회로
void gndu_vm_500mV_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_500mV_MSR_CTRL);
}
void gndu_vm_2V_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_2V_MSR_CTRL);
}

//2018.12.18 F5500 회로
void gndu_vm_5V_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_5V_MSR_CTRL);
}
void gndu_vm_20V_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_20V_MSR_CTRL);
}

void gndu_vm_40V_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_40V_MSR_CTRL);
}

void gndu_vm_100V_range(void)
{
	write_gndu_vmsr_ctrl(GNDU_100V_MSR_CTRL);
}

void gndu_adc_mux_diag_sel(void)
{
	write_gndu_mux_ctrl(0x01);
}

void gndu_adc_mux_agnd_sel(void)
{
	write_gndu_mux_ctrl(0x08);
}

void gndu_adc_mux_5VREF_sel(void)
{
	write_gndu_mux_ctrl(0x04);
}

void gndu_adc_mux_gnd_adcin_sel(void)
{
	write_gndu_mux_ctrl(0x02);
}

void get_gndu_adc_value(void)
{
	gndu_adc_conv_start();
	
	Delay_us(200);
		
//	gndu_adc_value = *(volatile int *)(gndu_ctrl_reg.base_addr + GNDU_ADC_CS_ADDR) & 0x3FFFF;

	gndu_adc_value = (MIO_GNDU_RD(GNDU_ADC_CS_ADDR) & 0x3FFFF);
}


// AD변환된 값 레인지를 가지고 실제 측정값 계산
float get_gndu_vm(int rng, float adc)
{
    if (without_gndu_vmsr) 
		return (adc - adc_offset)/(gndu_vmsr_ideal_gain[rng] * adc_gain);

    return (adc - gndu_vmsr_offset[rng])/gndu_vmsr_real_gain[rng];
}

void init_gndu_adc_mux(void)
{
	gndu_adc_mux_agnd_sel();
}

void gndu_adc_conv_start(void)
{
//	*(VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_ADC_CNVST_ADDR) = 0x00; // dummy write for ADC Conversion Start

	MIO_GNDU_WR(GNDU_ADC_CNVST_ADDR, 0x00000000);	// dummy write for ADC Conversion Start
}

float get_gndu_vmax(int rng)
{
    if (without_gndu_vmsr) return -3.75 * gndu_vmsr_ideal_gain[rng];
    return -3.75 * gndu_vmsr_real_gain[rng] + gndu_vmsr_offset[rng];
}

float get_gndu_vmin(int rng)
{
    if (without_gndu_vmsr) return 3.75 * gndu_vmsr_ideal_gain[rng];
    return 3.75 * gndu_vmsr_real_gain[rng] + gndu_vmsr_offset[rng];
}

BOOL is_gndu_vrng(int rng, float val)
{
    if ((val > get_gndu_vmin(rng)) && (val <= get_gndu_vmax(rng)))
        return TRUE;
    else
        return FALSE;
}

int get_gndu_vrng(float val)
{
    int range;

    for (range = gndu_ctrl_reg.min_vrange; range <= gndu_ctrl_reg.max_vrange; range++) 
    {       
        if(is_gndu_vrng(range, val)) 
        	return range;
    }
    
    return gndu_ctrl_reg.max_vrange;
}

int read_gndu_vrange(void)
{
    return to_gndu_vrange(gndu_ctrl_reg.vmsr_mux_ctrl);
}

int to_gndu_vrange(UINT8 vctrl)
{
	int range;
	
   	if(vctrl & GNDU_100V_MSR_CTRL) range = GNDU_100V_RANGE;
    else if(vctrl & GNDU_40V_MSR_CTRL) range = GNDU_40V_RANGE;
	else if(vctrl & GNDU_20V_MSR_CTRL) range = GNDU_20V_RANGE;
    else if(vctrl & GNDU_5V_MSR_CTRL) range = GNDU_5V_RANGE;
	else if(vctrl & GNDU_2V_MSR_CTRL) range = GNDU_2V_RANGE;
    else if(vctrl & GNDU_500mV_MSR_CTRL) range = GNDU_500mV_RANGE;
        
    return range;
}

void start_gndu_dac(void)
{
    // DAC가 출력해야 하는 값으로부터 DAC에 입력돼야하는 값 계산        
    dac_val_reg.gndu_dac_in_val = calculate_dac_in_val(dac_val_reg.gndu_dac_out_val);
         
	write_gndu_dac(dac_val_reg.gndu_dac_in_val);
}

void write_gndu_dac(INT32 dac_in_val)
{
	gndu_ctrl_reg.dac_in_val = dac_in_val;

//    *(INT16 *)(gndu_ctrl_reg.base_addr + GNDU_DAC_WRITE_ADDR) = (INT16)dac_in_val;    

	MIO_GNDU_WR(GNDU_DAC_WRITE_ADDR, (u32)dac_in_val);
	
}

float calculate_gndu_dac_out_val(void)
{
	float dac_out_val;
    
	if (without_gndu_vsrc)
	{
        dac_out_val = 0;
        return dac_out_val;
    }
    
    dac_out_val = (0 - gndu_vsrc_offset)/gndu_vsrc_real_gain;

	return dac_out_val;
}


//20150728 GNDU V1.4 Edit
void gndu_seeprom_cs_on()
{
#if SMU_DBG_POINT

//  VUINT8 *addr;
	seeprom_cs_off();

    /* (for GNDU TEST)
    gndu_ctrl_reg.relay_ctrl1 = gndu_ctrl_reg.relay_ctrl1 | 0x80 ;
    
    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK1_ADDR);
   	*addr = (VUINT8)((gndu_ctrl_reg.relay_ctrl1 ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF);  

    */

//  *(INT16 *)(gndu_ctrl_reg.base_addr + GNDU_SPROM_CS_ADDR) = 0x0000;// CS Low active

  MIO_GNDU_WR(GNDU_SPROM_CS_ADDR, 0x00000000);		// CS Low active

#endif

}

//20150728 GNDU V1.4 Edit
void gndu_seeprom_cs_off()
{
    //VUINT8 *addr;

    /* (for GNDU TEST)
    gndu_ctrl_reg.relay_ctrl1 = gndu_ctrl_reg.relay_ctrl1 & ~0x80 ;
    
    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK1_ADDR);
   	*addr = (VUINT8)((gndu_ctrl_reg.relay_ctrl1 ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF);

    */

//    *(INT16 *)(gndu_ctrl_reg.base_addr + GNDU_SPROM_CS_ADDR) = 0x0001;// CS Low active

	 MIO_GNDU_WR(GNDU_SPROM_CS_ADDR, 0x00000001);		// CS Low active

}

// 20070713 => 20150728 GNDU V1.4 Edit
void gndu_rst(UINT8 val)
{
    //2018.12.18 F5500 회로
//    *(VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_FPGA_RESET) = val; // RST Low active

	MIO_GNDU_WR(GNDU_FPGA_RESET, (u32)val);		// CS Low active
}


//// 20070713
//void gndu_seeprom_cs_on()
//{
//    VUINT8 *addr;
//	  
//	seeprom_cs_off();
//
//    gndu_ctrl_reg.relay_ctrl1 = gndu_ctrl_reg.relay_ctrl1 | 0x80 ;
//    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK1_ADDR);
//   	*addr = (VUINT8)((gndu_ctrl_reg.relay_ctrl1 ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF);  
//}
//
//
//// 20070713
//void gndu_seeprom_cs_off()
//{
//    VUINT8 *addr;
//
//    gndu_ctrl_reg.relay_ctrl1 = gndu_ctrl_reg.relay_ctrl1 & ~0x80 ;
//    
//    addr = (VUINT8 *)(gndu_ctrl_reg.base_addr + GNDU_CLK1_ADDR);
//   	*addr = (VUINT8)((gndu_ctrl_reg.relay_ctrl1 ^ GNDU_RELAY_CTRL1_XORMASK) & 0xFF); 
//}

//


void gndu_rly_all_off(void)
{
   	write_gndu_out_relay_ctrl(0x00);
	write_gndu_in_relay_ctrl(0x00);
	write_gndu_diag_relay_ctrl(0x00);
    write_gndu_diag_mod_relay_ctrl(0x00);
}

void read_plf_info(void)
{

	// memcpy(&smu_pwr_line_freq, (char *)STRATA_STA_ADDRESS, sizeof(smu_pwr_line_freq));
    // TRACE("# <Read Power Line Frequency>:%dHz", smu_pwr_line_freq);

	NAND_Page_Read(nand_plc_addr, &smu_pwr_line_freq, 1);
	TRACE("# <Read Power Line Frequency>:%dHz\r\n", smu_pwr_line_freq);
    
}

BOOL write_plf_info(void)
{

    // long read_plf;
    
	// if (Flash_Write(STRATA_STA_ADDRESS, (unsigned long)&smu_pwr_line_freq, sizeof(smu_pwr_line_freq))) return TRUE;
	// else return FALSE;

	UINT8 ret;

	GPIO_NandWpCtrl(NAND_WP_HIGH);

	ret = NAND_Block_Erase(nand_plc_addr);

    if(NAND_SUCCESS != ret) {
        TRACE("NAND_Block_Erase FAIL! (exit code=%x)\n", ret);
		GPIO_NandWpCtrl(NAND_WP_LOW);
		return FALSE;
    }

    /* program */
    ret = NAND_Page_Program(nand_plc_addr, &smu_pwr_line_freq, 1);

	if(NAND_SUCCESS != ret) {
		TRACE("NAND_Page_Program FAIL! (exit code=%x)\n", ret);
		GPIO_NandWpCtrl(NAND_WP_LOW);
		return FALSE;
    }

	GPIO_NandWpCtrl(NAND_WP_LOW);
	return TRUE;
}

void load_plf_info(UINT8 freq)
{
    if (freq == 50)
    {
        smu_pwr_line_freq = 50;
        
    } 
	else if (freq == 60) 
    {
        smu_pwr_line_freq = 60;
    }
}

void SmuInit(void)
{
	init_module();

	write_smu_ictrl_init(CH_SMU1, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU2, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU3, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU4, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU5, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU6, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU7, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU8, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU9, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU10, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU11, SMU_100mA_CTRL);
	write_smu_ictrl_init(CH_SMU12, SMU_100mA_CTRL);
	

  //Delay_ms(1000);
  //printf("init_modlue() done.\n");

	smu_force_voltage(CH_SMU1, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU2, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU3, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU4, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU5, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU6, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU7, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU8, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU9, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU10, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU11, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	smu_force_voltage(CH_SMU12, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
	
	gndu_source_start();

	smu_adc_mux_v_sel_all();

    // init_module();
    Delay_ms(100);

    smu_force_voltage(CH_SMU1, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU2, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU3, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU4, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU5, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU6, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU7, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU8, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
    smu_force_voltage(CH_SMU9, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU10, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU11, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	smu_force_voltage(CH_SMU12, 0, SMU_20V_RANGE, 100e-6, SMU_100uA_RANGE);
	
	
}


//
//void Unit_FPGA_Read(u32 ch, u32 addr, u32 *pData, u32 length)
//{
//	u32 cnt;
//	// buswidth : 16bit 
//	//vu16 *paddr = (vu16*)(NCS3_BASE_ADDR +  _SHIFT_ADDR(addr));
//	//vu16 *paddr = (vu16*)(smu_ctrl_reg[ch].base_addr + _SHIFT_ADDR(addr));
//
//	for(cnt = 0; cnt < length; cnt++)
//	{
//		pData[cnt] = 0x0000FFFF & *paddr;
//	}
//}


void Unit_FPGA_Read(vu16 *addr, u32 *pData, u32 length)
{
	u32 cnt;
	// buswidth : 16bit 
	//vu16 *paddr = (vu16*)(NCS3_BASE_ADDR +  _SHIFT_ADDR(addr));
	//vu16 *paddr = (vu16*)(smu_ctrl_reg[ch].base_addr + _SHIFT_ADDR(addr));

	for(cnt = 0; cnt < length; cnt++)
	{
		pData[cnt] = 0x0000FFFF & *(addr);
	}
}

void Unit_FPGA_Write(vu16 *addr, u32 *pData, u32 length)
{
	u32 cnt;
	// buswidth : 16bit 
	//vu16 *paddr = (vu16*)(NCS3_BASE_ADDR +  _SHIFT_ADDR(addr));
	//vu16 *paddr = (vu16*)(smu_ctrl_reg[ch].base_addr + _SHIFT_ADDR(addr));

	for(cnt = 0; cnt < length; cnt++)
	{
		*(addr + 2*cnt) = 0x0000FFFF & pData[cnt] ;
	}
}

// SMU Read & Write
u32 SMU_FPGA_ReadSingle(u32 ch, u32 addr)
{
	u32 data;

	vu16 *paddr = (vu16*)(smu_ctrl_reg[ch].base_addr + _SHIFT_ADDR(addr));
	Unit_FPGA_Read(paddr, &data, 1);

	return data;
}

void SMU_FPGA_WriteSingle(u32 ch, u32 addr, u32 data)
{
	vu16 *paddr = (vu16*)(smu_ctrl_reg[ch].base_addr + _SHIFT_ADDR(addr));
	Unit_FPGA_Write(paddr, &data, 1);
}


// GNDU Read & Write
u32 GNDU_FPGA_ReadSingle(u32 addr)
{
	u32 data;

	vu16 *paddr = (vu16*)(gndu_ctrl_reg.base_addr + _SHIFT_ADDR(addr));
	Unit_FPGA_Read(paddr, &data, 1);

	return data;
}

void GNDU_FPGA_WriteSingle(u32 addr, u32 data)
{
	vu16 *paddr = (vu16*)(gndu_ctrl_reg.base_addr + _SHIFT_ADDR(addr));
	Unit_FPGA_Write(paddr, &data, 1);
}

u32 GNDU_FPGA_SPI_RD(u32 addr)
{
	u32 ret;
	ret = _test__send_spi_frame(SPI_MODE_READ, addr, 0, 0, SPI_SEL_M0, 
					FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS, FPGA_SPI_TRIG_ADRS, FPGA_SPI_TRIG_ADRS, 
					FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_INIT_LOC, SPI_TRIG_OPT_FRAME_LOC);
	return ret;
}

void GNDU_FPGA_SPI_WR(u32 addr, u32 data)
{
	_test__send_spi_frame(SPI_MODE_WRITE, addr, data, 0, SPI_SEL_M0, 
					FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS, FPGA_SPI_TRIG_ADRS, FPGA_SPI_TRIG_ADRS, 
					FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_LOC);
}

void TestFunction1(float dat_float)
{
	
	
    
    gndu_VDAC_send(dat_float);                                          // DAC SEND
    //meas_val = gndu_HRADC_measure();                                  //ADC Measure
    //TRACE("meas val %f\r\n", meas_val);
    
    //meas_val = gndu_HRADC_measure();                                  //ADC Measure
    //TRACE("meas val %f\r\n", meas_val);

}

float TestFunction2()
{
	return gndu_HRADC_measure();                                        //ADC Measure
}

float TestFunction3(float dat_float)
{
	gndu_VDAC_send(dat_float);                                          // DAC SEND
	return gndu_HRADC_measure();                                        //ADC Measure
}
















// //S3100 code ///////////////////////////////////////////////// 





u32 hvsmu_HRADC_enable(u32 ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);

	SetWireInValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_HRADC_CON_WI, 0x00000001, 0xFFFFFFFF);
	
	// send dummy converion and sck signals.
	smu_adc_conv_start(ch);
    smu_adc_voltage(ch);

	return true;
}













u32 hvsmu_V_DAC_reset(u32 ch)
{
	hvsmu_V_DAC__trig_clr(ch);
	return true;
}

u32 hvsmu_I_DAC_reset(u32 ch)
{
	hvsmu_I_DAC__trig_clr(ch);
	return true;
}


u32 hvsmu_V_DAC_init(u32 ch)
{
	//          DAC_code = 0xFFFFF ... Vout = +10V
	//          DAC_code = 0xE0000 ... Vout = +7.5V
	//          DAC_code = 0xC0000 ... Vout = +5V
	//          DAC_code = 0xA0000 ... Vout = +2.5V
	//          DAC_code = 0x80000 ... Vout = +0V
	//          DAC_code = 0x7FFFF ... Vout = -0V
	//          DAC_code = 0x5FFFF ... Vout = -2.5V
	//          DAC_code = 0x3FFFF ... Vout = -5V
	//          DAC_code = 0x1FFFF ... Vout = -7.5V
	//          DAC_code = 0x00000 ... Vout = -10V
	hvsmu_V_DAC__trig_rst(ch); // trigger reset

	hvsmu_V_DAC_reg_set(ch, 0x3, 0x00000); // set clear code 0V // 20-bit data
	hvsmu_V_DAC__trig_clr(ch); // trigger clear 

	// DAC output enable
	hvsmu_V_DAC_reg_set(ch, 0x2, 0x00002); // control reg // 0x00002 --> DAC normal out | RBUF power down
	u32 val_readback = hvsmu_V_DAC_reg_get(ch, 0x2); // control readback
	if (val_readback != 0x00002)
		return 0xFFFFFFFF;

	return true;
}

u32 hvsmu_I_DAC_init(u32 ch)
{
	hvsmu_I_DAC__trig_rst(ch); // trigger reset

	hvsmu_I_DAC_reg_set(ch, 0x3, 0x00000); // set clear code 0V // 20-bit data
	hvsmu_I_DAC__trig_clr(ch); // trigger clear 

	// DAC output enable
	hvsmu_I_DAC_reg_set(ch, 0x2, 0x00002); // control reg // 0x00002 --> DAC normal out | RBUF power down
	u32 val_readback = hvsmu_I_DAC_reg_get(ch, 0x2); // control readback
	if (val_readback != 0x00002)
		return 0xFFFFFFFF;

	return true;
}

void hvsmu_V_DAC__trig_rst(u32 ch)
{
	// trigger reset
	hvsmu_V_DAC__sub_trig_check(ch, 0);
}

void hvsmu_I_DAC__trig_rst(u32 ch)
{
	// trigger reset
	hvsmu_I_DAC__sub_trig_check(ch, 0);
}

void hvsmu_V_DAC__trig_clr(u32 ch)
{
	// trigger clear
	hvsmu_V_DAC__sub_trig_check(ch, 1);
}

void hvsmu_I_DAC__trig_clr(u32 ch)
{
	// trigger clear
	hvsmu_I_DAC__sub_trig_check(ch, 1);
}

void hvsmu_V_DAC__trig_frame(u32 ch) 
{
	// trigger ldac
	hvsmu_V_DAC__sub_trig_check(ch, 3);
}

void hvsmu_I_DAC__trig_frame(u32 ch) 
{
	// trigger ldac
	hvsmu_I_DAC__sub_trig_check(ch, 3);
}

void hvsmu_V_DAC__trig_nop(u32 ch)
{
	// trigger ldac
	hvsmu_V_DAC__sub_trig_check(ch, 4);
}

void hvsmu_I_DAC__trig_nop(u32 ch)
{
	// trigger ldac
	hvsmu_I_DAC__sub_trig_check(ch, 4);
}

u32 hvsmu_V_DAC__sub_trig_check(u32 ch, u32 bit_loc)
{
	// +-------+---------------+------------+------------+----------------------------+--------------------------------+
	// | HRDAC | HRDAC_VDAC_WI | 0x030      | wire_in_0C | Control HRDAC VDAC.        | bit[23:0]=mosi_data[23:0]      | 
	// +-------+---------------+------------+------------+----------------------------+--------------------------------+
	// | HRDAC | HRDAC_VDAC_WO | 0x098      | wireout_26 | Return HRDAC VDAC status.  | bit[23:0]=miso_data[23:0]      | 
	// +-------+---------------+------------+------------+----------------------------+--------------------------------+
	// | HRDAC | HRDAC_VDAC_TI | 0x12C      | trig_in_4B | Trigger HRDAC VDAC.        | bit[0]=trig_reset              | 
	// |       |               |            |            |                            | bit[1]=trig_clr                | 
	// |       |               |            |            |                            | bit[2]=trig_ldac               | 
	// |       |               |            |            |                            | bit[3]=trig_frame              | 
	// |       |               |            |            |                            | bit[4]=trig_nop                | 
	// +-------+---------------+------------+------------+----------------------------+--------------------------------+
	// | HRDAC | HRDAC_VDAC_TO | 0x1A4      | trigout_69 | Check HRDAC VDAC done.     | bit[0]=trig_reset              | 
	// |       |               |            |            |                            | bit[1]=trig_clr                | 
	// |       |               |            |            |                            | bit[2]=trig_ldac               | 
	// |       |               |            |            |                            | bit[3]=trig_frame              | 
	// |       |               |            |            |                            | bit[4]=trig_nop                | 
	// +-------+---------------+------------+------------+----------------------------+--------------------------------+

	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);

	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VDAC_TI, bit_loc); // (u32 adrs, s32 loc_bit)

	//# check done
	u32 cnt_done = 0;
	bool flag_done;
	while (true) {
		flag_done = IsTriggered(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VDAC_TO, (u32)(0x1<<bit_loc));
		if (flag_done==true)
			break;
		cnt_done += 1;
		if (cnt_done>=SPI_TRIG_MAX_CNT)
			break;
	}

	return cnt_done;
}

u32 hvsmu_I_DAC__sub_trig_check(u32 ch, u32 bit_loc)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);

	ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IDAC_TI, bit_loc); // (u32 adrs, s32 loc_bit)

	//# check done
	u32 cnt_done = 0;
	bool flag_done;
	while (true) {
		flag_done = IsTriggered(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IDAC_TO, (u32)(0x1<<bit_loc));
		if (flag_done==true)
			break;
		cnt_done += 1;
		if (cnt_done>=SPI_TRIG_MAX_CNT)
			break;
	}

	return cnt_done;
}


u32 hvsmu_V_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20)
{
	// reg adrs AD5791 // https://www.analog.com/media/en/technical-documentation/data-sheets/ad5791.pdf
	// 000 (0x0) : NOP
	// 001 (0x1) : DAC reg
	// 010 (0x2) : control reg
	// 011 (0x3) : clear code reg
	// 100 (0x4) : SW control reg
	u32 val_mosi;
	val_mosi = (adrs_b3<<20) | (val_b20); 
	hvsmu_V_DAC__set_mosi(ch, val_mosi); 
	hvsmu_V_DAC__trig_frame(ch);
	return val_mosi;
}

u32 hvsmu_I_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20)
{
	// reg adrs AD5791 // https://www.analog.com/media/en/technical-documentation/data-sheets/ad5791.pdf
	// 000 (0x0) : NOP
	// 001 (0x1) : DAC reg
	// 010 (0x2) : control reg
	// 011 (0x3) : clear code reg
	// 100 (0x4) : SW control reg
	u32 val_mosi;
	val_mosi = (adrs_b3<<20) | (val_b20); 
	hvsmu_I_DAC__set_mosi(ch, val_mosi); 
	hvsmu_I_DAC__trig_frame(ch);
	return val_mosi;
}

u32 hvsmu_V_DAC_reg_get(u32 ch, u32 adrs_b3)
{
	// adrs
	// 000  : NOP
	// 001  : DAC reg
	// 010  : control reg
	// 011  : clear code reg
	// 100  : SW control reg
	u32 val_mosi;
	val_mosi = (0x1<<23) | (adrs_b3<<20) | 0; // read flag
	hvsmu_V_DAC__set_mosi(ch, val_mosi); 
	hvsmu_V_DAC__trig_frame(ch);
	hvsmu_V_DAC__trig_nop(ch);
	u32 val_miso = hvsmu_V_DAC__get_miso(ch); // collect miso data
	return val_miso & 0xFFFFF;
}

u32 hvsmu_I_DAC_reg_get(u32 ch, u32 adrs_b3)
{
	// adrs
	// 000  : NOP
	// 001  : DAC reg
	// 010  : control reg
	// 011  : clear code reg
	// 100  : SW control reg
	u32 val_mosi;
	val_mosi = (0x1<<23) | (adrs_b3<<20) | 0; // read flag
	hvsmu_V_DAC__set_mosi(ch, val_mosi); 
	hvsmu_V_DAC__trig_frame(ch);
	hvsmu_V_DAC__trig_nop(ch);
	u32 val_miso = hvsmu_V_DAC__get_miso(ch); // collect miso data
	return val_miso & 0xFFFFF;
}

void hvsmu_V_DAC__set_mosi(u32 ch, u32 val_u32)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);

	// set mosi data
	SetWireInValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VDAC_WI, val_u32, 0xFFFFFFFF);
}

void hvsmu_I_DAC__set_mosi(u32 ch, u32 val_u32)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);

	// set mosi data
	SetWireInValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IDAC_WI, val_u32, 0xFFFFFFFF);
}

u32 hvsmu_V_DAC__get_miso(u32 ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);

	// get miso data
	return GetWireOutValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_VDAC_WO, 0xFFFFFFFF);
}
u32 hvsmu_I_DAC__get_miso(u32 ch)
{
	u32 slotCS = _SPI_SEL_SLOT_SMU(ch);
	
	// get miso data
	return GetWireOutValue(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_IDAC_WO, 0xFFFFFFFF);
}

void hvsmu_I_DAC__trig_ldac(u32 ch)
{
	hvsmu_I_DAC__sub_trig_check(ch, 2);
}

void hvsmu_V_DAC__trig_ldac(u32 ch)
{
	hvsmu_V_DAC__sub_trig_check(ch, 2);
}


























// u32 gndu_D_RLY_reset() {
// 	ActivateTriggerIn(EP_ADRS__DIAG_RELAY_TI, 0);           // EP for DIAG_RELAY_TI // clear pulse
// 	return 0;
// }



// u32 gndu_D_RLY_send(u32 dat) {
// 	SetWireInValue   (EP_ADRS__DIAG_RELAY_WI, dat); // EP for DIAG_RELAY_WI // set ...
// 	ActivateTriggerIn(EP_ADRS__DIAG_RELAY_TI, 1);           // EP for DIAG_RELAY_TI // latch pulse
// 	return 0;
// }

// u32 gndu_VDAC_reset() {
// 	ActivateTriggerIn(EP_ADRS__VDAC_CON_TI, 0); // EP for VDAC_CON_TI // reset pulse
// 	return 0;
// }

// u32 gndu_VDAC_send(float dat_float) {
// 	s32 dat;
// 	if (dat_float>0) {
// 		dat = (s32)(16384*((dat_float)/5.0)); // 0x0000_4000 = 16384
// 		if (dat>32767) // 0x0000_7FFF = 32767
// 			dat = 32767;
// 	}
// 	else {
// 		dat = (s32)(-16384*((dat_float)/-5.0)); // 0xFFFF_C000 = -0x4000 = -16384
// 		if (dat<-32768) // 0xFFFF_8000 = -32768
// 			dat = -32768;
// 	}
// 	//Console.WriteLine(">>> DAC test : " + string.Format(" {0} ... 0x{1,8:X8}", dat_float, (u32)dat));
// 	SetWireInValue   (EP_ADRS__VDAC_VAL_WI, (u32)dat); // EP for VDAC_VAL_WI 
// 	ActivateTriggerIn(EP_ADRS__VDAC_CON_TI, 1); // EP for VDAC_CON_TI // write pulse
// 	return 0;
// }


// u32 gndu_O_RLY_reset() {
// 	ActivateTriggerIn(EP_ADRS__OUTP_RELAY_TI, 0); // clear pulse
// 	return 0;
// }

// u32 gndu_O_RLY_send(u32 dat) {
// 	SetWireInValue   (EP_ADRS__OUTP_RELAY_WI, dat); // set ...
// 	ActivateTriggerIn(EP_ADRS__OUTP_RELAY_TI, 1); // latch pulse
// 	return 0;
// }












