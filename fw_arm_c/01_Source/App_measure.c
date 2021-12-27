#include "App_measure.h"


//#include "stdafx.h"
//
//#include <stdio.h>
//#include <stdlib.h>  
//#include <string.h>
//
//#include "OsTimer.h"
//#include "App_SMU.h"
//#include "App_measure.h"
//#include "InterfaceApp.h"
//#include "shell.h"
//#include "StaClientsApp.h"
//#include "top_core_info.h"

char smu_state[NO_OF_SMU];   
char smu_states[NO_OF_SMU][MAX_ADC_BUFF] @ SDRAM_CODE_SECTION1;

TAdcValuesInt adc_mean @ SDRAM_CODE_SECTION2;                        
TAdcValuesInt adc_max @ SDRAM_CODE_SECTION3;                          
TAdcValuesInt adc_min @ SDRAM_CODE_SECTION4; 
TAdcValuesInt adc_buff[MAX_ADC_BUFF] @ SDRAM_CODE_SECTION5;

// for flash calibration
// float flash_cal_buf[5000] @ SDRAM_CODE_SECTION6; 
float flash_cal_buf[5000] @ SDRAM_CODE_SECTION6; 



//#define TRACE printf

//#define NCS3_BASE_ADDR		0x0C000000		// 0xAB500000	
//#define	VSVM_BASE_ADDR		(NCS3_BASE_ADDR + 0x00C00000) // VSVM

//// 2015.12.10 hong
//CSta4VsVm		m_Sta4VsVm;
//CSta4VsuCal*	m_pSta4VsuCal[2];
//CSta4VmuCal*	m_pSta4VmuCal[2];
//CSta4Vsu		m_Sta4Vsu[2];
//CSta4Vmu		m_Sta4Vmu[2];


int tmp_current_vrange;

static int calib_leak_rng;  // current calibration range
//static int calib_cnt;       // current calibration step

// variable for smu leak calibration 
static float calib_leak_val[NO_OF_SMU][11];
static float calib_leak_start;
static float calib_leak_step;
static int   calib_leak_nostep;

static float calib_leak_gain[NO_OF_SMU][SMU_UPPER_LEAK_IRANGE+1];
static float calib_leak_offset[NO_OF_SMU][SMU_UPPER_LEAK_IRANGE+1];


//2017.08.28
extern SysInfo sta_info;




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void smu_force_voltage_multi(int selectCnt, int *smu_ch, float *v_source, int *v_source_range, float *i_limit, int *i_limit_range)
{
	int cnt;
	int irange[NO_OF_SMU], irange_for_limit[NO_OF_SMU], current_irange[NO_OF_SMU];

    //printf("smu_force_voltage_multi : %d, %d, %f, %d, %f, %d \n", selectCnt, *smu_ch, *v_source, *v_source_range, *i_limit, *i_limit_range);

    for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_ctrl_reg[smu_ch[cnt]].used = TRUE;
		smu_ctrl_reg[smu_ch[cnt]].mode = SMU_MODE_V;
		smu_ctrl_reg[smu_ch[cnt]].src_val = v_source[cnt];  // v_source[smu_ch[cnt]] -> v_source[cnt] 수정
		smu_ctrl_reg[smu_ch[cnt]].limit_val = i_limit[cnt]; // i_limit[smu_ch[cnt]]  -> i_limit[cnt]  수정
	
        // 전압공급레인지 결정 
		if(v_source_range[cnt] == -1) // Auto Range. 전압공급값으로부터 적당한 전압공급레인지를 찾는다
        {
            //printf("smu_force_voltage_multi : %d\n", v_source_range[cnt]);
			smu_ctrl_reg[smu_ch[cnt]].src_rng = get_smu_vrng(smu_ch[cnt], v_source[cnt]);
        }
		else	// 전압공급레인지를 명시적으로 지정해 준 경우  
        {
            //printf("smu_force_voltage_multi : %d\n", v_source_range[cnt]);
			smu_ctrl_reg[smu_ch[cnt]].src_rng = v_source_range[cnt];
        }

        // 전압측정레인지는 전압공급레인지와 같게 한다.
		smu_ctrl_reg[smu_ch[cnt]].vmsr_rng = smu_ctrl_reg[smu_ch[cnt]].src_rng;       //측정, min, max 레인지 모두 인가레인지로
		smu_ctrl_reg[smu_ch[cnt]].vmsr_max_rng = smu_ctrl_reg[smu_ch[cnt]].src_rng;  // 추가 (20070102) // SMU_100V_RANGE;(SMU.cpp)
		smu_ctrl_reg[smu_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[smu_ch[cnt]].src_rng;  // 추가 (20070102) // SMU_2V_RANGE;(SMU.cpp) 

		// 전류레인지 결정
		if(i_limit_range[cnt] == -1) // Auto Range. 전류 limit값으로부터 적당한 전류레인지를 찾는다
		{
			// 현재 설정돼있는 전류레인지가 전류리미트값에 알맞는 전류 레인지 보다 큰 경우 
			// 전류리미트값에 알맞는 레인지로 변경하고 그렇지 않은 경우 현재 전류레인지를 유지한다.
			irange_for_limit[smu_ch[cnt]] = get_smu_imsr_rng(smu_ch[cnt], i_limit[cnt]); // 전류 리미트 값에 적당한 전류 레인지

			current_irange[smu_ch[cnt]] = read_smu_irange(smu_ch[cnt]);
			if (current_irange[smu_ch[cnt]] > irange_for_limit[smu_ch[cnt]]) irange[smu_ch[cnt]] = irange_for_limit[smu_ch[cnt]]; 
			else irange[smu_ch[cnt]] = current_irange[smu_ch[cnt]];
			//else irange[smu_ch[cnt]] = irange_for_limit[smu_ch[cnt]];		// AutoRange의 경우 설정된 범위 이내의 최대전류를 출력하도록 함

			smu_ctrl_reg[smu_ch[cnt]].imsr_rng = irange[smu_ch[cnt]];           //마지막 측정했던 전류 레인지를 기억하고 있다.   
			smu_ctrl_reg[smu_ch[cnt]].limit_i_rng = irange_for_limit[smu_ch[cnt]]; 
			smu_ctrl_reg[smu_ch[cnt]].imsr_max_rng = irange_for_limit[smu_ch[cnt]];  
			smu_ctrl_reg[smu_ch[cnt]].imsr_min_rng = smu_ctrl_reg[smu_ch[cnt]].min_imsr_range;
		}
		else 	// 전류측정 레인지를 명시적으로 지정해 준 경우
		{
			smu_ctrl_reg[smu_ch[cnt]].imsr_rng = i_limit_range[cnt];   //마지막 측정했던 전류 레인지를 기억하고 있다.
			smu_ctrl_reg[smu_ch[cnt]].limit_i_rng = i_limit_range[cnt]; 
			smu_ctrl_reg[smu_ch[cnt]].imsr_max_rng = i_limit_range[cnt]; //일단 측정 min, max 레인지는 같게한다. 측정시 변경한다.
			smu_ctrl_reg[smu_ch[cnt]].imsr_min_rng = i_limit_range[cnt]; 
		}
	}
    
	smu_source_voltage_start_multi(selectCnt, smu_ch);
}

// SMU Voltage Source
void smu_force_voltage(int smu_ch, float v_source, int v_source_range, float i_limit, int i_limit_range)
{
	int irange, irange_for_limit, current_irange;
	//int ch;
	//	printf("Force Voltage\n");

	//TRACE("ch: %d, V: %0.2e, Vrng: %d, Ilimit %0.2e, Irange %d\r\n", smu_ch, v_source, v_source_range, i_limit, i_limit_range);


//	u16 i;
//	u32 mio_addr;
//	u32 test_val;
//	for(i = 0; i < 20; i++)
//	{
//
//		//mio_addr = smu_ctrl_reg[4].base_addr + 0x00008000;
//		mio_addr = 0x00008000;
//		
//		MIO_SMU_WR(4, mio_addr, i);
//		test_val = MIO_SMU_RD(4, mio_addr);
//	}

	smu_ctrl_reg[smu_ch].used = TRUE;
	smu_ctrl_reg[smu_ch].mode = SMU_MODE_V;
	smu_ctrl_reg[smu_ch].src_val = v_source;
	smu_ctrl_reg[smu_ch].limit_val = i_limit;

	// 전압공급레인지 결정 
	if(v_source_range == -1) // Auto Range. 전압공급값으로부터 적당한 전압공급레인지를 찾는다
		smu_ctrl_reg[smu_ch].src_rng = get_smu_vrng(smu_ch, v_source);
	else	// 전압공급레인지를 명시적으로 지정해 준 경우  
		smu_ctrl_reg[smu_ch].src_rng = v_source_range;

	// 전압측정레인지는 전압공급레인지와 같게 한다.
	smu_ctrl_reg[smu_ch].vmsr_rng = smu_ctrl_reg[smu_ch].src_rng;       //측정, min, max 레인지 모두 인가레인지로
	smu_ctrl_reg[smu_ch].vmsr_max_rng = smu_ctrl_reg[smu_ch].src_rng;  // 추가 (20070102) // SMU_100V_RANGE;(SMU.cpp)
	smu_ctrl_reg[smu_ch].vmsr_min_rng = smu_ctrl_reg[smu_ch].src_rng;  // 추가 (20070102) // SMU_2V_RANGE;(SMU.cpp) 

	// 전류레인지 결정
	if(i_limit_range == -1) // Auto Range. 전류 limit값으로부터 적당한 전류레인지를 찾는다
	{
		// 현재 설정돼있는 전류레인지가 전류리미트값에 알맞는 전류 레인지 보다 큰 경우 
		// 전류리미트값에 알맞는 레인지로 변경하고 그렇지 않은 경우 현재 전류레인지를 유지한다.
		irange_for_limit = get_smu_imsr_rng(smu_ch, i_limit); // 전류 리미트 값에 적당한 전류 레인지

		current_irange = read_smu_irange(smu_ch);
		if (current_irange > irange_for_limit) irange = irange_for_limit;
		//else irange = irange_for_limit;		// AutoRange의 경우 설정된 범위 이내의 최대전류를 출력하도록 함
		else irange = current_irange;

		smu_ctrl_reg[smu_ch].imsr_rng = irange;           //마지막 측정했던 전류 레인지를 기억하고 있다.   
		smu_ctrl_reg[smu_ch].limit_i_rng = irange_for_limit; 
		smu_ctrl_reg[smu_ch].imsr_max_rng = irange_for_limit;  
		smu_ctrl_reg[smu_ch].imsr_min_rng = smu_ctrl_reg[smu_ch].min_imsr_range;

	}
	else 	// 전류측정 레인지를 명시적으로 지정해 준 경우
	{
		smu_ctrl_reg[smu_ch].imsr_rng = i_limit_range;   //마지막 측정했던 전류 레인지를 기억하고 있다.
		smu_ctrl_reg[smu_ch].limit_i_rng = i_limit_range; 
		smu_ctrl_reg[smu_ch].imsr_max_rng = i_limit_range; //일단 측정 min, max 레인지는 같게한다. 측정시 변경한다.
		smu_ctrl_reg[smu_ch].imsr_min_rng = i_limit_range; 
	}

	smu_source_voltage_start(smu_ch);
	
	//printf("Force Voltage\n");
	//meas_remove_limit_current_all();
}

void smu_force_current_multi(int selectCnt, int *smu_ch, float *i_source, int *i_source_range, float *v_limit, int *v_measure_range)
{
	int cnt;
	int vrange[NO_OF_SMU], vrange_for_limit[NO_OF_SMU], current_vrange[NO_OF_SMU];

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_ctrl_reg[smu_ch[cnt]].used = TRUE;
		smu_ctrl_reg[smu_ch[cnt]].mode = SMU_MODE_I;
		smu_ctrl_reg[smu_ch[cnt]].src_val = i_source[cnt];
		smu_ctrl_reg[smu_ch[cnt]].limit_val = v_limit[cnt];

		//smu_output_rly_on(smu_ch); //2105.12.22

		// 전류레인지 결정
		if(i_source_range[cnt] == -1) // Auto Range. 전류공급값으로부터 적당한 전류공급레인지를 찾는다 
			smu_ctrl_reg[smu_ch[cnt]].src_rng = get_smu_isrc_rng(smu_ch[cnt], i_source[cnt]);
		else	// 전류공급레인지를 명시적으로 지정해 준 경우  
			smu_ctrl_reg[smu_ch[cnt]].src_rng = i_source_range[cnt];

		// 전류측정레인지는 전류공급레인지와 같다
		smu_ctrl_reg[smu_ch[cnt]].imsr_rng = smu_ctrl_reg[smu_ch[cnt]].src_rng;
		smu_ctrl_reg[smu_ch[cnt]].imsr_max_rng = smu_ctrl_reg[smu_ch[cnt]].max_imsr_range; // 추가 (20070102)
		smu_ctrl_reg[smu_ch[cnt]].imsr_min_rng = smu_ctrl_reg[smu_ch[cnt]].min_imsr_range; // 추가 (20070102)

		// 전압레인지 결정
		if(v_measure_range[cnt] == -1) // Auto Range. 전압 limit값으로부터 적당한 전압레인지를 찾는다
		{
			// 현재 설정돼 있는 전압레인지가 전압리미트값에 알맞는 전압레인지 보다 큰 경우 
			// 전압리미트값에 알맞는 레인지로 변경하고 그렇지 않은 경우 현재 전압레인지를 유지한다.
			vrange_for_limit[smu_ch[cnt]] = get_smu_vrng(smu_ch[cnt], v_limit[cnt]);
			current_vrange[smu_ch[cnt]] = read_smu_vrange(smu_ch[cnt]);
			if (current_vrange[smu_ch[cnt]] > vrange_for_limit[smu_ch[cnt]]) vrange[smu_ch[cnt]] = vrange_for_limit[smu_ch[cnt]];
			else vrange[smu_ch[cnt]] = current_vrange[smu_ch[cnt]];
			smu_ctrl_reg[smu_ch[cnt]].vmsr_rng = vrange[smu_ch[cnt]];
			smu_ctrl_reg[smu_ch[cnt]].vmsr_max_rng = vrange_for_limit[smu_ch[cnt]];
			smu_ctrl_reg[smu_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[smu_ch[cnt]].min_vrange;
		}
		else 	// 전압측정 레인지를 명시적으로 지정해 준 경우
		{
			smu_ctrl_reg[smu_ch[cnt]].vmsr_rng = v_measure_range[cnt];
			smu_ctrl_reg[smu_ch[cnt]].vmsr_max_rng = v_measure_range[cnt]; // 수정 (20071121)
			smu_ctrl_reg[smu_ch[cnt]].vmsr_min_rng = v_measure_range[cnt]; // 수정 (20061121)
		}
	}
	smu_source_current_start_multi(selectCnt, smu_ch);
}

// SMU Current Source
void smu_force_current(int smu_ch, float i_source, int i_source_range, float v_limit, int v_measure_range)
{
	int vrange, vrange_for_limit, current_vrange;

	smu_ctrl_reg[smu_ch].used = TRUE;
	smu_ctrl_reg[smu_ch].mode = SMU_MODE_I;
	smu_ctrl_reg[smu_ch].src_val = i_source;
	smu_ctrl_reg[smu_ch].limit_val = v_limit;

	//smu_output_rly_on(smu_ch); //2105.12.22

	// 전류레인지 결정
	if(i_source_range == -1) // Auto Range. 전류공급값으로부터 적당한 전류공급레인지를 찾는다 
		smu_ctrl_reg[smu_ch].src_rng = get_smu_isrc_rng(smu_ch, i_source);
	else	// 전류공급레인지를 명시적으로 지정해 준 경우  
		smu_ctrl_reg[smu_ch].src_rng = i_source_range;

	// 전류측정레인지는 전류공급레인지와 같다
	smu_ctrl_reg[smu_ch].imsr_rng = smu_ctrl_reg[smu_ch].src_rng;
	smu_ctrl_reg[smu_ch].imsr_max_rng = smu_ctrl_reg[smu_ch].max_imsr_range; // 추가 (20070102)
	smu_ctrl_reg[smu_ch].imsr_min_rng = smu_ctrl_reg[smu_ch].min_imsr_range; // 추가 (20070102)

	// 전압레인지 결정
	if(v_measure_range == -1) // Auto Range. 전압 limit값으로부터 적당한 전압레인지를 찾는다
	{
		// 현재 설정돼 있는 전압레인지가 전압리미트값에 알맞는 전압레인지 보다 큰 경우 
		// 전압리미트값에 알맞는 레인지로 변경하고 그렇지 않은 경우 현재 전압레인지를 유지한다.
		vrange_for_limit = get_smu_vrng(smu_ch, v_limit);
		current_vrange = read_smu_vrange(smu_ch);
		if (current_vrange > vrange_for_limit) vrange = vrange_for_limit;
		else vrange = current_vrange;
		smu_ctrl_reg[smu_ch].vmsr_rng = vrange;
		smu_ctrl_reg[smu_ch].vmsr_max_rng = vrange_for_limit;
		smu_ctrl_reg[smu_ch].vmsr_min_rng = smu_ctrl_reg[smu_ch].min_vrange;
	}
	else 	// 전압측정 레인지를 명시적으로 지정해 준 경우
	{
		smu_ctrl_reg[smu_ch].vmsr_rng = v_measure_range;
		smu_ctrl_reg[smu_ch].vmsr_max_rng = v_measure_range; // 수정 (20071121)
		smu_ctrl_reg[smu_ch].vmsr_min_rng = v_measure_range; // 수정 (20061121)
	}

	smu_source_current_start(smu_ch);
}

void smu_measure_voltage_multi(char *msr_val, int selectCnt, int *p_ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int cnt;
	int current_vrange[NO_OF_SMU];
	float vdac_out_val[NO_OF_SMU];
	char msr_smu[NO_OF_SMU][100];
	int flag[NO_OF_SMU];

    for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		//memset(msr_smu[cnt], NULL, sizeof(msr_smu[cnt]));
		msr_smu[cnt][0] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		current_vrange[p_ch[cnt]] = read_smu_vrange(p_ch[cnt]);

		if (rng_ctrl == RANGE_AUTO) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_vrange;
		}
		else if (rng_ctrl == RANGE_LIMITED_AUTO) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = msr_rng;
		}
		else if (rng_ctrl == RANGE_FIXED)
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = msr_rng;
			smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng = msr_rng;
		}
		else if (rng_ctrl == RANGE_CURRENT) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = current_vrange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng = current_vrange[p_ch[cnt]];
		}
		else //jh default autorange;
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_vrange;
		}
	}

	
    // sbcho@20211108 HLSMU : Range 500mV -> 2V / 100V -> 40V
    if( msr_rng < SMU_2V_RANGE || msr_rng > SMU_40V_RANGE )
    {
        msr_rng = SMU_40V_RANGE;
    }

    // jh default AVG_MEDIUM_MODE;
    //if( average_cnt < AVG_LONG_MODE || average_cnt > 320 )
    //{
    //    average_cnt = AVG_MEDIUM_MODE;
    //}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_ctrl_reg[p_ch[cnt]].vmsr_rng = current_vrange[p_ch[cnt]];

		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng < smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng)
			smu_ctrl_reg[p_ch[cnt]].vmsr_rng = smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng; 
		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng > smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng)
			smu_ctrl_reg[p_ch[cnt]].vmsr_rng = smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng; 

		flag[p_ch[cnt]] = 0;
		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng != current_vrange[p_ch[cnt]])
		{ // 현재 설정돼 있는 전압 레인지에서 설정이 바껴야 하는 경우 (Fixed 로 설정된 경우)
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)   
			{
				vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
				if (vdac_out_val[p_ch[cnt]] > 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
				if (smu_ctrl_reg[p_ch[cnt]].src_val < 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
				
				dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]]; 

				if (current_vrange[p_ch[cnt]] < smu_ctrl_reg[p_ch[cnt]].vmsr_rng)
				{ // 전압 레인지를 올려야 하는 경우 
					flag[p_ch[cnt]] = 1;
					start_smu_dac(p_ch[cnt]);
				}
				else
				{ // 전압 레인지를 내리거나 그대로 유지하는 경우
					flag[p_ch[cnt]] = 2;
					write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
				}
			}
			else
			{
				vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
				dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];

				if (current_vrange[p_ch[cnt]] < smu_ctrl_reg[p_ch[cnt]].src_rng)
				{ // 전압 레인지를 올려야 하는 경우 
					flag[p_ch[cnt]] = 1;
					start_smu_dac(p_ch[cnt]); 
					
				}
				else
				{ // 전압 레인지를 내리거나 그대로 유지하는 경우
					flag[p_ch[cnt]] = 2;
					write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng); //전압 레인지 설정
					
				}

			}
		}
	}

	int flagFinal = 0;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		flagFinal |= flag[p_ch[cnt]];
	}

	if(flagFinal)
		Delay_ms(1);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(flag[p_ch[cnt]] == 1)
		{
			write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
		}
		else if(flag[p_ch[cnt]] == 2)
		{
			start_smu_dac(p_ch[cnt]);
		}
		/*
		else if(flag[p_ch[cnt]] == 3)
		{
			write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng); //전압 레인지 설정
		}
		else if(flag[p_ch[cnt]] == 4)
		{
			start_smu_dac(p_ch[cnt]);
		}
		*/
	}

	meas_measure_voltage_multi(selectCnt, p_ch, average_cnt);

	unsigned long *pTmpVal;
    //float *pTmpVal;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{

		pTmpVal = (unsigned long*) &smu_ctrl_reg[p_ch[cnt]].vmsr_val;
		//pTmpVal = &smu_ctrl_reg[p_ch[cnt]].vmsr_val;

		if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'I')
				sprintf(msr_smu[p_ch[cnt]], "S,%d,V,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,V,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
		}
		else 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'V') 
				sprintf(msr_smu[p_ch[cnt]],"S,%d,V,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]],"S,%d,V,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
		}
	}
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		strcat(msr_val, msr_smu[p_ch[cnt]]);
	}
}

void smu_measure_voltage_multi2(char *msr_val, int selectCnt, int *p_ch, int *average_cnt, char *rng_ctrl, int *msr_rng)
{
	int cnt;
	int current_vrange[NO_OF_SMU];
	float vdac_out_val[NO_OF_SMU];
	char msr_smu[NO_OF_SMU][100];
	int flag[NO_OF_SMU];
	int averageCountFinal;

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		//memset(msr_smu[cnt], NULL, sizeof(msr_smu[cnt]));
		msr_smu[cnt][0] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		current_vrange[p_ch[cnt]] = read_smu_vrange(p_ch[cnt]);

		if (rng_ctrl[p_ch[cnt]] == RANGE_AUTO) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_vrange;
		}
		else if (rng_ctrl[p_ch[cnt]] == RANGE_LIMITED_AUTO) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = msr_rng[p_ch[cnt]];
		}
		else if (rng_ctrl[p_ch[cnt]] == RANGE_FIXED)
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = msr_rng[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng = msr_rng[p_ch[cnt]];
		}
		else if (rng_ctrl[p_ch[cnt]] == RANGE_CURRENT) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = current_vrange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng = current_vrange[p_ch[cnt]];
		}
		else //jh default autorange;
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_vrange;
		}
	}

	
    // sbcho@20211108 HLSMU : Range 500mV -> 2V / 100V -> 40V
    if( msr_rng[p_ch[cnt]] < SMU_2V_RANGE || msr_rng[p_ch[cnt]] > SMU_40V_RANGE )
    {
        msr_rng[p_ch[cnt]] = SMU_40V_RANGE;
    }

	averageCountFinal = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		// jh default AVG_MEDIUM_MODE;
		//if( average_cnt[p_ch[cnt]] < AVG_LONG_MODE || average_cnt[p_ch[cnt]] > 320 )
		//{
		//	average_cnt[p_ch[cnt]] = AVG_MEDIUM_MODE;
		//}

		// SMU 여러개의 AverageCount의 갯수를 확인 후 최대치를 이용한다.

		if(averageCountFinal < get_average_count(average_cnt[p_ch[cnt]]))
		{
			averageCountFinal = get_average_count(average_cnt[p_ch[cnt]]);
		}
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_ctrl_reg[p_ch[cnt]].vmsr_rng = current_vrange[p_ch[cnt]];

		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng < smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng)
			smu_ctrl_reg[p_ch[cnt]].vmsr_rng = smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng; 
		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng > smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng)
			smu_ctrl_reg[p_ch[cnt]].vmsr_rng = smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng; 

		flag[p_ch[cnt]] = 0;
		if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng != current_vrange[p_ch[cnt]])
		{ // 현재 설정돼 있는 전압 레인지에서 설정이 바껴야 하는 경우 (Fixed 로 설정된 경우)
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)   
			{
				vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
				if (vdac_out_val[p_ch[cnt]] > 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
				if (smu_ctrl_reg[p_ch[cnt]].src_val < 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
				
				dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]]; 

				if (current_vrange[p_ch[cnt]] < smu_ctrl_reg[p_ch[cnt]].vmsr_rng)
				{ // 전압 레인지를 올려야 하는 경우 
					flag[p_ch[cnt]] = 1;
					start_smu_dac(p_ch[cnt]);
				}
				else
				{ // 전압 레인지를 내리거나 그대로 유지하는 경우
					flag[p_ch[cnt]] = 2;
					write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
				}
			}
			else
			{
				vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
				dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];

				if (current_vrange[p_ch[cnt]] < smu_ctrl_reg[p_ch[cnt]].src_rng)
				{ // 전압 레인지를 올려야 하는 경우 
					flag[p_ch[cnt]] = 1;
					start_smu_dac(p_ch[cnt]); 
					
				}
				else
				{ // 전압 레인지를 내리거나 그대로 유지하는 경우
					flag[p_ch[cnt]] = 2;
					write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng); //전압 레인지 설정
					
				}

			}
		}
	}

	int flagFinal = 0;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		flagFinal |= flag[p_ch[cnt]];
	}

	if(flagFinal)
		Delay_ms(1);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(flag[p_ch[cnt]] == 1)
		{
			write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
		}
		else if(flag[p_ch[cnt]] == 2)
		{
			start_smu_dac(p_ch[cnt]);
		}
		/*
		else if(flag[p_ch[cnt]] == 3)
		{
			write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng); //전압 레인지 설정
		}
		else if(flag[p_ch[cnt]] == 4)
		{
			start_smu_dac(p_ch[cnt]);
		}
		*/
	}

	meas_measure_voltage_multi(selectCnt, p_ch, averageCountFinal);

	//float *pTmpVal;
	unsigned long *pTmpVal;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		pTmpVal = (unsigned long*) &smu_ctrl_reg[p_ch[cnt]].vmsr_val;

		//pTmpVal = &smu_ctrl_reg[p_ch[cnt]].vmsr_val;

		if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'I')
				sprintf(msr_smu[p_ch[cnt]], "S,%d,V,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,V,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
		}
		else 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'V') 
				sprintf(msr_smu[p_ch[cnt]],"S,%d,V,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]],"S,%d,V,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].vmsr_rng);
		}
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		strcat(msr_val, msr_smu[p_ch[cnt]]);
	}
}

// SMU Voltage Measure
void smu_measure_voltage(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int current_vrange;
	float vdac_out_val;

	// printf("Measure Voltage\n");

	current_vrange = read_smu_vrange(ch);

	if (rng_ctrl == RANGE_AUTO) 
	{
		smu_ctrl_reg[ch].vmsr_min_rng = smu_ctrl_reg[ch].min_vrange;
	}
	else if (rng_ctrl == RANGE_LIMITED_AUTO) 
	{
		smu_ctrl_reg[ch].vmsr_min_rng = msr_rng;
	}
	else if (rng_ctrl == RANGE_FIXED)
	{
		smu_ctrl_reg[ch].vmsr_min_rng = msr_rng;
		smu_ctrl_reg[ch].vmsr_max_rng = msr_rng;
	}
	else if (rng_ctrl == RANGE_CURRENT) 
	{
		smu_ctrl_reg[ch].vmsr_min_rng = current_vrange;
		smu_ctrl_reg[ch].vmsr_max_rng = current_vrange;
	}
	else //jh default autorange;
	{
		smu_ctrl_reg[ch].vmsr_min_rng = smu_ctrl_reg[ch].min_vrange;
	}

    // sbcho@20211108  HLSMU: Range 500mV -> 2V / 100V -> 40V
	if( msr_rng < SMU_2V_RANGE || msr_rng > SMU_40V_RANGE )
	{
		msr_rng = SMU_40V_RANGE;
	}

	// jh default AVG_MEDIUM_MODE;
	//if( average_cnt < AVG_LONG_MODE || average_cnt > 320 )
	//{
	//	average_cnt = AVG_MEDIUM_MODE;
	//}

	if( ch < CH_SMU1 || ch >= NO_OF_SMU)
	{
		ch = NO_OF_SMU - 1;
	}
	/////////////////////////////////////////////////////////////////////////////////////
	// <전압 레인지 변경> 
	/////////////////////////////////////////////////////////////////////////////////////
	// 1) Auto 또는 limited Auto 로 설정된 경우 여기에서 레인지를 바꾸지는 않는다.
	//    측정을 하면서 레인지를 바꾼다.
	// 2) Fixed 로 설정된 경우 사용자가 지정한 레인지가 현재 레인지 설정과 다른 경우
	//    여기에서 설정해 버리고 이후에는 변경하지 않는다.
	// 3) Current 로 설정된 경우 현재 설정돼 있는 레인지 유지. 어디에서도 레인지는 변경되지 않는다.
	////////////////////////////////////////////////////////////////////////////////////////////////////
	smu_ctrl_reg[ch].vmsr_rng = current_vrange;

	if (smu_ctrl_reg[ch].vmsr_rng < smu_ctrl_reg[ch].vmsr_min_rng)
		smu_ctrl_reg[ch].vmsr_rng = smu_ctrl_reg[ch].vmsr_min_rng; 
	if (smu_ctrl_reg[ch].vmsr_rng > smu_ctrl_reg[ch].vmsr_max_rng)
		smu_ctrl_reg[ch].vmsr_rng = smu_ctrl_reg[ch].vmsr_max_rng; 

	if (smu_ctrl_reg[ch].vmsr_rng != current_vrange)
	{ // 현재 설정돼 있는 전압 레인지에서 설정이 바껴야 하는 경우 (Fixed 로 설정된 경우)
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I)   
		{
			vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
			if (vdac_out_val > 0) vdac_out_val = -vdac_out_val;
			if (smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
				dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val; 

			if (current_vrange < smu_ctrl_reg[ch].vmsr_rng)
			{ // 전압 레인지를 올려야 하는 경우 
				start_smu_dac(ch);
				Delay_ms(1);
				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
			}
			else
			{ // 전압 레인지를 내리거나 그대로 유지하는 경우
				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
				Delay_ms(1);
				start_smu_dac(ch);
			}
		}
		else
		{
			vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
			dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;

			if (current_vrange < smu_ctrl_reg[ch].src_rng)
			{ // 전압 레인지를 올려야 하는 경우 
				start_smu_dac(ch); 
				Delay_ms(1);
				write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); //전압 레인지 설정
			}
			else
			{ // 전압 레인지를 내리거나 그대로 유지하는 경우
				write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); //전압 레인지 설정
				Delay_ms(1);
				start_smu_dac(ch);
			}

		}
		
	}


	/*
	if (smu_ctrl_reg[ch].vmsr_rng != current_vrange)
	{ // 현재 설정돼 있는 전압 레인지에서 설정이 바껴야 하는 경우 (Fixed 로 설정된 경우)
	if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
	dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
	else
	dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);

	if (current_vrange < smu_ctrl_reg[ch].vmsr_rng)
	{ // 전압 레인지를 올려야 하는 경우 
	start_smu_dac(ch);
	delay_ms(1);
	write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
	}
	else
	{ // 전압 레인지를 내리거나 그대로 유지하는 경우
	write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
	delay_ms(1);
	start_smu_dac(ch);
	}
	}
	*/    

	meas_measure_voltage(ch, average_cnt);

	//	meas_measure(ch, average_cnt);

	/*
	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
	if (smu_ctrl_reg[ch].state == 'I')
	sprintf(msr_val, "SMU,%d,V,%E,%d,N\r", ch+1, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].vmsr_rng);
	else
	sprintf(msr_val, "SMU,%d,V,%E,%d,C\r", ch+1, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].vmsr_rng);
	}
	else 
	{
	if (smu_ctrl_reg[ch].state == 'V') 
	sprintf(msr_val,"SMU,%d,V,%E,%d,N\r", ch+1, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].vmsr_rng);
	else
	sprintf(msr_val,"SMU,%d,V,%E,%d,C\r", ch+1, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].vmsr_rng);
	}
	*/

	//printf("I: %2.6fV\n",smu_ctrl_reg[ch].vmsr_val);

	unsigned long *pTmpVal;
	pTmpVal = (unsigned long*) &smu_ctrl_reg[ch].vmsr_val;

	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		if (smu_ctrl_reg[ch].state == 'I')
			sprintf(msr_val, "S,%d,V,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].vmsr_rng);
		else
			sprintf(msr_val, "S,%d,V,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].vmsr_rng);
	}
	else 
	{
		if (smu_ctrl_reg[ch].state == 'V') 
			sprintf(msr_val,"S,%d,V,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].vmsr_rng);
		else
			sprintf(msr_val,"S,%d,V,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].vmsr_rng);
	}

	//    return SYS_OK;  
}


// 20200520 range 변경 multi수정
void smu_measure_current_multi(char *msr_val, int selectCnt, int *p_ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int cnt;
	int current_irange[NO_OF_SMU];
	int delay[NO_OF_SMU];
	int delayFinal;
	char msr_smu[NO_OF_SMU][100];

	int change_flag_ch[NO_OF_SMU];
	int change_flag_cnt;

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		//memset(msr_smu[cnt], NULL, sizeof(msr_smu[cnt]));
		msr_smu[cnt][0] = NULL;
		delay[cnt] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		current_irange[p_ch[cnt]] = read_smu_irange(p_ch[cnt]);

		if( smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_V )
		{
			if (rng_ctrl == RANGE_AUTO)
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_imsr_range;
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;
			}
			else if (rng_ctrl == RANGE_LIMITED_AUTO) 
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = msr_rng;
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;		
			}
			else if (rng_ctrl == RANGE_FIXED)
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = msr_rng;
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = msr_rng;
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = msr_rng;
			}
			else if (rng_ctrl == RANGE_CURRENT) 
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = current_irange[p_ch[cnt]];
			}
			else //jh default autorange;
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_imsr_range;
			}
		}
		else //전류모드일때는 모두 무시하고 현재 전류레인지(인가전류 레인지)를 측정 레인지로 한다.
		{
			smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = current_irange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = current_irange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].limit_i_rng = current_irange[p_ch[cnt]]; //force_i 에서 설정하지만 한번더 설정한다...
		}

		//min max range check
		if(smu_ctrl_reg[p_ch[cnt]].imsr_max_rng > smu_ctrl_reg[p_ch[cnt]].limit_i_rng)
			smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;  //max 레인지는 limit 레인지보다 클수 없다.

		if(smu_ctrl_reg[p_ch[cnt]].imsr_min_rng > smu_ctrl_reg[p_ch[cnt]].imsr_max_rng)
			smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].imsr_max_rng;  //min 레인지는 max 레인지보다 클수 없다.

		//측정 레인지 체크, 최소레인지보다 작다면 최소 레인지로, 최대 레인지보다 크다면 최대 레인지로 변경한다.
		if( smu_ctrl_reg[p_ch[cnt]].imsr_rng < smu_ctrl_reg[p_ch[cnt]].imsr_min_rng )
			smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_min_rng;

		if( smu_ctrl_reg[p_ch[cnt]].imsr_rng > smu_ctrl_reg[p_ch[cnt]].imsr_max_rng )
			smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_max_rng;
	}

//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		delay[p_ch[cnt]] = 0;
//		if (smu_ctrl_reg[p_ch[cnt]].imsr_rng != current_irange[p_ch[cnt]])
//		{ 
//			//전류 인가 모드일때 
//			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
//				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
//			else
//				//전압 인가 모드일때 
//				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
//
//			//Delay_ms(10);
//
//			change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//
//			if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng])
//				delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];
//
//			start_smu_dac(p_ch[cnt]);
//		}
//	}

	change_flag_cnt = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		delay[p_ch[cnt]] = 0;
		if (smu_ctrl_reg[p_ch[cnt]].imsr_rng != current_irange[p_ch[cnt]])
		{ 
 			change_flag_ch[change_flag_cnt++] = p_ch[cnt];
		
			//전류 인가 모드일때 
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
			else
				//전압 인가 모드일때 
				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);

			//Delay_ms(10);

			//change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);

//			if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng])
//				delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];

			//start_smu_dac(p_ch[cnt]);
		}
	}

	if(change_flag_cnt > 0)
		change_smu_imsr_range_multi(change_flag_cnt, change_flag_ch, smu_ctrl_reg);

	

	for(cnt = 0; cnt < change_flag_cnt; cnt++)
	{
		if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng])
			delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];
		
		start_smu_dac(change_flag_ch[cnt]);
	}
		
	delayFinal = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(delayFinal < delay[p_ch[cnt]])
			delayFinal = delay[p_ch[cnt]];
	}

	Delay_ms(delayFinal);
	//Delay_ms(20);


	meas_measure_current_multi(selectCnt, p_ch, average_cnt);

	unsigned long *pTmpVal;
	//float *pTmpVal;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		pTmpVal = (unsigned long*) &smu_ctrl_reg[p_ch[cnt]].imsr_val;
		//pTmpVal = &smu_ctrl_reg[p_ch[cnt]].imsr_val;

		//printf("S,%d,I,%2.15Le,%d,N\r\n", p_ch[cnt]+1, (double)smu_ctrl_reg[p_ch[cnt]].imsr_val, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
		
		if (smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'V')
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
		}
		else 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'I') 
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
		}
	}
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		strcat(msr_val, msr_smu[p_ch[cnt]]);
	}
}

void smu_measure_current_multi2(char *msr_val, int selectCnt, int *p_ch, int *average_cnt, char *rng_ctrl, int *msr_rng)
{
	int cnt;
	int current_irange[NO_OF_SMU];
	int delay[NO_OF_SMU];
	int delayFinal;
	char msr_smu[NO_OF_SMU][100];
	int averageCountFinal;

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		//memset(msr_smu[cnt], NULL, sizeof(msr_smu[cnt]));
		msr_smu[cnt][0] = NULL;
		delay[cnt] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		current_irange[p_ch[cnt]] = read_smu_irange(p_ch[cnt]);

		if( smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_V )
		{
			if (rng_ctrl[p_ch[cnt]] == RANGE_AUTO)
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_imsr_range;
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;
			}
			else if (rng_ctrl[p_ch[cnt]] == RANGE_LIMITED_AUTO) 
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = msr_rng[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;		
			}
			else if (rng_ctrl[p_ch[cnt]] == RANGE_FIXED)
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = msr_rng[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = msr_rng[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = msr_rng[p_ch[cnt]];
			}
			else if (rng_ctrl[p_ch[cnt]] == RANGE_CURRENT) 
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = current_irange[p_ch[cnt]];
				smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = current_irange[p_ch[cnt]];
			}
			else //jh default autorange;
			{
				smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].min_imsr_range;
			}
		}
		else //전류모드일때는 모두 무시하고 현재 전류레인지(인가전류 레인지)를 측정 레인지로 한다.
		{
			smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = current_irange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = current_irange[p_ch[cnt]];
			smu_ctrl_reg[p_ch[cnt]].limit_i_rng = current_irange[p_ch[cnt]]; //force_i 에서 설정하지만 한번더 설정한다...
		}

		//min max range check
		if(smu_ctrl_reg[p_ch[cnt]].imsr_max_rng > smu_ctrl_reg[p_ch[cnt]].limit_i_rng)
			smu_ctrl_reg[p_ch[cnt]].imsr_max_rng = smu_ctrl_reg[p_ch[cnt]].limit_i_rng;  //max 레인지는 limit 레인지보다 클수 없다.

		if(smu_ctrl_reg[p_ch[cnt]].imsr_min_rng > smu_ctrl_reg[p_ch[cnt]].imsr_max_rng)
			smu_ctrl_reg[p_ch[cnt]].imsr_min_rng = smu_ctrl_reg[p_ch[cnt]].imsr_max_rng;  //min 레인지는 max 레인지보다 클수 없다.

		//측정 레인지 체크, 최소레인지보다 작다면 최소 레인지로, 최대 레인지보다 크다면 최대 레인지로 변경한다.
		if( smu_ctrl_reg[p_ch[cnt]].imsr_rng < smu_ctrl_reg[p_ch[cnt]].imsr_min_rng )
			smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_min_rng;

		if( smu_ctrl_reg[p_ch[cnt]].imsr_rng > smu_ctrl_reg[p_ch[cnt]].imsr_max_rng )
			smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_max_rng;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		delay[p_ch[cnt]] = 0;
		if (smu_ctrl_reg[p_ch[cnt]].imsr_rng != current_irange[p_ch[cnt]])
		{ 
			//전류 인가 모드일때 
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
			else
				//전압 인가 모드일때 
				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);

			//Delay_ms(10);

			change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);

			if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng])
				delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];

			start_smu_dac(p_ch[cnt]);
		}
	}

	delayFinal = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(delayFinal < delay[p_ch[cnt]])
			delayFinal = delay[p_ch[cnt]];
	}

	Delay_ms(delayFinal);
	//Delay_ms(20);

	// averageCount 정리
	averageCountFinal = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(averageCountFinal < get_average_count(p_ch[cnt]))
		{
			averageCountFinal = get_average_count(p_ch[cnt]);
		}
	}

	meas_measure_current_multi(selectCnt, p_ch, averageCountFinal);

	unsigned long *pTmpVal;
	//float *pTmpVal;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		pTmpVal = (unsigned long*) &smu_ctrl_reg[p_ch[cnt]].imsr_val;
		//pTmpVal = &smu_ctrl_reg[p_ch[cnt]].imsr_val;

		if (smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'V')
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
		}
		else 
		{
			if (smu_ctrl_reg[p_ch[cnt]].state == 'I') 
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,N ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
			else
				sprintf(msr_smu[p_ch[cnt]], "S,%d,I,%x,%d,C ", p_ch[cnt]+1, *pTmpVal, smu_ctrl_reg[p_ch[cnt]].imsr_rng);
		}
	}
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		strcat(msr_val, msr_smu[p_ch[cnt]]);
	}
}

// SMU Current Measure
void smu_measure_current(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int current_irange;

	int delay = 0;

	//printf("ch: %d, avg_cnt %d, rng_ctrl %c, msr_rng %d\r\n", ch, average_cnt, rng_ctrl, msr_rng);

	current_irange = read_smu_irange(ch);

  //------------------------------------------------------------------
	if( smu_ctrl_reg[ch].mode == SMU_MODE_V )
	{
		if (rng_ctrl == RANGE_AUTO)
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
	  else if (rng_ctrl == RANGE_LIMITED_AUTO) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
		else if (rng_ctrl == RANGE_FIXED)
		{
      smu_ctrl_reg[ch].imsr_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = msr_rng;
		}
		else if (rng_ctrl == RANGE_CURRENT) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = current_irange;
			smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		}
		else //jh default autorange;
		{
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
		}
	}
	else //전류모드일때는 모두 무시하고 현재 전류레인지(인가전류 레인지)를 측정 레인지로 한다.
	{
		smu_ctrl_reg[ch].imsr_min_rng = current_irange;
		smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		smu_ctrl_reg[ch].limit_i_rng = current_irange; //force_i 에서 설정하지만 한번더 설정한다...
	}
 //------------------------------------------------------------------

	//min max range check
	if(smu_ctrl_reg[ch].imsr_max_rng > smu_ctrl_reg[ch].limit_i_rng)
		smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;  //max 레인지는 limit 레인지보다 클수 없다.

	if(smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
		smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;  //min 레인지는 max 레인지보다 클수 없다.

    //측정 레인지 체크, 최소레인지보다 작다면 최소 레인지로, 최대 레인지보다 크다면 최대 레인지로 변경한다.
	if( smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_min_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_min_rng;

	if( smu_ctrl_reg[ch].imsr_rng > smu_ctrl_reg[ch].imsr_max_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng;
	   
  /////////////////////////////////////////////////////////////////////////////////////
	// <전류 레인지 변경> 
	/////////////////////////////////////////////////////////////////////////////////////
	// 1) 여기에서 초기 측정레인지로 바꾼다.
	// 2) 마지막 측정레인지 또는 설정한 레인지로 시작해서 측정한후 
	// 3) 측정후 다시 리미트 레인지로 변경한다.
	/////////////////////////////////////////////////////////////////////////////////////
	//------------------------------------------------------------------
	//전류측정레인지가 현재 레인지와 다를경우
  if (smu_ctrl_reg[ch].imsr_rng != current_irange)
	{ 
		//전류 인가 모드일때 
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
    else
    {
		  //전압 인가 모드일때 
      dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
    }

    //2017.07.22
		Delay_ms(10);

		change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

		delay = 0;
		if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];

		start_smu_dac(ch);

		Delay_ms(delay);	
		//Delay_ms(20);
	}  
  //------------------------------------------------------------------    

	//전류 측정
  meas_measure_current(ch, average_cnt);

  //------------------------------------------------------------------   
	unsigned long *pTmpVal;
	pTmpVal = (unsigned long*) &smu_ctrl_reg[ch].imsr_val;
  //float *pTmpVal;
  //pTmpVal = &smu_ctrl_reg[ch].imsr_val;

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
    if (smu_ctrl_reg[ch].state == 'V')
    {
      sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
    }
    else
    {
      sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
    }
  }
  else 
	{
    if (smu_ctrl_reg[ch].state == 'I') 
      sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
    else
      sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
  }
  //------------------------------------------------------------------   
}

// SMU Current Measure
void smu_measure_current_DI(float *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int current_irange;

	int delay = 0;

	//TRACE("ch: %d, avg_cnt %d, rng_ctrl %c, msr_rng %d\r\n", ch, average_cnt, rng_ctrl, msr_rng);


	current_irange = read_smu_irange(ch);

  //------------------------------------------------------------------
	if( smu_ctrl_reg[ch].mode == SMU_MODE_V )
	{
		if (rng_ctrl == RANGE_AUTO)
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
	  else if (rng_ctrl == RANGE_LIMITED_AUTO) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
		else if (rng_ctrl == RANGE_FIXED)
		{
      smu_ctrl_reg[ch].imsr_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = msr_rng;
		}
		else if (rng_ctrl == RANGE_CURRENT) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = current_irange;
			smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		}
		else //jh default autorange;
		{
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
		}
	}
	else //전류모드일때는 모두 무시하고 현재 전류레인지(인가전류 레인지)를 측정 레인지로 한다.
	{
		smu_ctrl_reg[ch].imsr_min_rng = current_irange;
		smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		smu_ctrl_reg[ch].limit_i_rng = current_irange; //force_i 에서 설정하지만 한번더 설정한다...
	}
 //------------------------------------------------------------------

	//min max range check
	if(smu_ctrl_reg[ch].imsr_max_rng > smu_ctrl_reg[ch].limit_i_rng)
		smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;  //max 레인지는 limit 레인지보다 클수 없다.

	if(smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
		smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;  //min 레인지는 max 레인지보다 클수 없다.

    //측정 레인지 체크, 최소레인지보다 작다면 최소 레인지로, 최대 레인지보다 크다면 최대 레인지로 변경한다.
	if( smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_min_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_min_rng;

	if( smu_ctrl_reg[ch].imsr_rng > smu_ctrl_reg[ch].imsr_max_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng;
	   
  /////////////////////////////////////////////////////////////////////////////////////
	// <전류 레인지 변경> 
	/////////////////////////////////////////////////////////////////////////////////////
	// 1) 여기에서 초기 측정레인지로 바꾼다.
	// 2) 마지막 측정레인지 또는 설정한 레인지로 시작해서 측정한후 
	// 3) 측정후 다시 리미트 레인지로 변경한다.
	/////////////////////////////////////////////////////////////////////////////////////
	//------------------------------------------------------------------
	//전류측정레인지가 현재 레인지와 다를경우
  if (smu_ctrl_reg[ch].imsr_rng != current_irange)
	{ 
		//전류 인가 모드일때 
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
    else
    {
		  //전압 인가 모드일때 
      dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
    }

    //2017.07.22
		Delay_ms(10);

		change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

		delay = 0;
		if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];

		start_smu_dac(ch);

		Delay_ms(delay);	
		//Delay_ms(20);
	}  
  //------------------------------------------------------------------    

	//전류 측정
  meas_measure_current(ch, average_cnt);

  //------------------------------------------------------------------   
	//unsigned long *pTmpVal;
	//pTmpVal = (unsigned long*) &smu_ctrl_reg[ch].imsr_val;
 // //float *pTmpVal;
 // //pTmpVal = &smu_ctrl_reg[ch].imsr_val;

	//if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	//{
	//	if (smu_ctrl_reg[ch].state == 'V')
	//	{
	//	  sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
	//	}
	//	else
	//	{
	//	  sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
	//	}
	//}
	//else 
	//{
	//	if (smu_ctrl_reg[ch].state == 'I') 
	//		sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
	//	else
	//		sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
	//}

  	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
		if (smu_ctrl_reg[ch].state == 'V')
		{
		  //sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
			msr_val[0] = 0x53;			//S
			msr_val[1] = ch+1;
			msr_val[2] = 0x49;			//I
			msr_val[3] = smu_ctrl_reg[ch].imsr_val;
			msr_val[4] = smu_ctrl_reg[ch].imsr_rng;
			msr_val[5] = 0x4E;			//N
		}
		else
		{
		  //sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
			msr_val[0] = 0x53;			//S
			msr_val[1] = ch+1;
			msr_val[2] = 0x49;			//I
			msr_val[3] = smu_ctrl_reg[ch].imsr_val;
			msr_val[4] = smu_ctrl_reg[ch].imsr_rng;
			msr_val[5] = 0x43;			//C
		}
	}
	else 
	{
		if (smu_ctrl_reg[ch].state == 'I') 
		{
			//sprintf(msr_val, "S,%d,I,%x,%d,N\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
			msr_val[0] = 0x53;			//S
			msr_val[1] = ch+1;
			msr_val[2] = 0x49;			//I
			msr_val[3] = smu_ctrl_reg[ch].imsr_val;
			msr_val[4] = smu_ctrl_reg[ch].imsr_rng;
			msr_val[5] = 0x4E;			//N
		}
		else
		{
			//sprintf(msr_val, "S,%d,I,%x,%d,C\r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
			msr_val[0] = 0x53;			//S
			msr_val[1] = ch+1;
			msr_val[2] = 0x49;			//I
			msr_val[3] = smu_ctrl_reg[ch].imsr_val;
			msr_val[4] = smu_ctrl_reg[ch].imsr_rng;
			msr_val[5] = 0x43;			//C
		}
			
	}

  //------------------------------------------------------------------   
}


// SMU Current Measure
void smu_measure_current_ex2(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng)
{
	int current_irange;

	int delay = 0;

	current_irange = read_smu_irange(ch);

  //------------------------------------------------------------------
	if( smu_ctrl_reg[ch].mode == SMU_MODE_V )
	{
		if (rng_ctrl == RANGE_AUTO)
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
	  else if (rng_ctrl == RANGE_LIMITED_AUTO) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;
		}
		else if (rng_ctrl == RANGE_FIXED)
		{
      smu_ctrl_reg[ch].imsr_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = msr_rng;
		}
		else if (rng_ctrl == RANGE_CURRENT) 
		{
      smu_ctrl_reg[ch].imsr_rng = current_irange;
			smu_ctrl_reg[ch].imsr_min_rng = current_irange;
			smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		}
		else //jh default autorange;
		{
			smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
		}
	}
	else //전류모드일때는 모두 무시하고 현재 전류레인지(인가전류 레인지)를 측정 레인지로 한다.
	{
		smu_ctrl_reg[ch].imsr_min_rng = current_irange;
		smu_ctrl_reg[ch].imsr_max_rng = current_irange;
		smu_ctrl_reg[ch].limit_i_rng = current_irange; //force_i 에서 설정하지만 한번더 설정한다...
	}
 //------------------------------------------------------------------

	//min max range check
	if(smu_ctrl_reg[ch].imsr_max_rng > smu_ctrl_reg[ch].limit_i_rng)
		smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].limit_i_rng;  //max 레인지는 limit 레인지보다 클수 없다.

	if(smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
		smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;  //min 레인지는 max 레인지보다 클수 없다.

    //측정 레인지 체크, 최소레인지보다 작다면 최소 레인지로, 최대 레인지보다 크다면 최대 레인지로 변경한다.
	if( smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_min_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_min_rng;

	if( smu_ctrl_reg[ch].imsr_rng > smu_ctrl_reg[ch].imsr_max_rng )
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng;
	   
  /////////////////////////////////////////////////////////////////////////////////////
	// <전류 레인지 변경> 
	/////////////////////////////////////////////////////////////////////////////////////
	// 1) 여기에서 초기 측정레인지로 바꾼다.
	// 2) 마지막 측정레인지 또는 설정한 레인지로 시작해서 측정한후 
	// 3) 측정후 다시 리미트 레인지로 변경한다.
	/////////////////////////////////////////////////////////////////////////////////////
	//------------------------------------------------------------------
	//전류측정레인지가 현재 레인지와 다를경우
  if (smu_ctrl_reg[ch].imsr_rng != current_irange)
	{ 
		//전류 인가 모드일때 
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I)  //이경우는 없을 것이다. 하지만 추가한다.
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
    else
    {
		  //전압 인가 모드일때 
      dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
    }

    //2017.07.22
		Delay_ms(10);

		change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

		delay = 0;
		if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];

		start_smu_dac(ch);

		Delay_ms(delay);	
		//Delay_ms(20);
	}  
  //------------------------------------------------------------------    

	//전류 측정
  meas_measure_current(ch, average_cnt);

  //------------------------------------------------------------------   
	unsigned long *pTmpVal;
	pTmpVal = (unsigned long*) &smu_ctrl_reg[ch].imsr_val;
  //float *pTmpVal;
  //pTmpVal = &smu_ctrl_reg[ch].imsr_val;

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
		if (smu_ctrl_reg[ch].state == 'V')
		{
		  sprintf(msr_val, "S,%d,I,%x,%d,N \r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
		}
		else
		{
		  sprintf(msr_val, "S,%d,I,%x,%d,C \r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
		}
	}
	else 
	{
		if (smu_ctrl_reg[ch].state == 'I') 
		  sprintf(msr_val, "S,%d,I,%x,%d,N \r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
		else
		  sprintf(msr_val, "S,%d,I,%x,%d,C \r", ch+1, *pTmpVal, smu_ctrl_reg[ch].imsr_rng);
	}

  //------------------------------------------------------------------   
}

// 2012.02.15 ydh
void smu_measure_current_ex(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng)
{

  int current_irange;
	int delay = 0;	

  /* // jh default 100V range;
  if( msr_rng < SMU_1nA_RANGE || msr_rng > SMU_100mA_RANGE )
  {
      msr_rng = SMU_1mA_RANGE;
  }*/

  // jh default AVG_MEDIUM_MODE;
  if( average_cnt < AVG_LONG_MODE || average_cnt > 4096 )
  {
      average_cnt = AVG_SHORT_MODE;
  }

  if( ch < CH_SMU1 || ch >= NO_OF_SMU )
  {
    ch = NO_OF_SMU - 1;
  }


	//printf("Measure Current begin\n");

  current_irange = read_smu_irange(ch);
     
  if (rng_ctrl == RANGE_AUTO) 
	{
		smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
  }
  else if (rng_ctrl == RANGE_LIMITED_AUTO) 
	{
		smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
		
		// 수정 (20080328) 
		if(smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
			smu_ctrl_reg[ch].imsr_max_rng = smu_ctrl_reg[ch].imsr_min_rng; 
  }
  else if (rng_ctrl == RANGE_FIXED)
	{
		smu_ctrl_reg[ch].imsr_min_rng = msr_rng;
    smu_ctrl_reg[ch].imsr_max_rng = msr_rng;
  }
  else if (rng_ctrl == RANGE_CURRENT) 
	{
		smu_ctrl_reg[ch].imsr_min_rng = current_irange;
		smu_ctrl_reg[ch].imsr_max_rng = current_irange;
  }
  else //jh default autorange;
  {
    smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].min_imsr_range;
  }

  /////////////////////////////////////////////////////////////////////////////////////
	// <전류 레인지 변경> 
	/////////////////////////////////////////////////////////////////////////////////////
	// 1) Auto 또는 limited Auto 로 설정된 경우 여기에서 레인지를 바꾸지는 않는다.
	//    측정을 하면서 레인지를 바꾼다.
	// 2) Fixed 로 설정된 경우 사용자가 지정한 레인지가 현재 레인지 설정과 다른 경우
	//    여기에서 설정해 버리고 이후에는 변경하지 않는다.
	// 3) Current 로 설정된 경우 현재 설정돼 있는 레인지 유지. 어디에서도 레인지는 변경되지 않는다.
	////////////////////////////////////////////////////////////////////////////////////////////////////
  smu_ctrl_reg[ch].imsr_rng = current_irange;

  if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_min_rng)
		smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_min_rng;
  if (smu_ctrl_reg[ch].imsr_rng > smu_ctrl_reg[ch].imsr_max_rng)
    smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng;
       
	if (smu_ctrl_reg[ch].imsr_rng != current_irange)
	{ // 현재 설정돼 있는 전류레인지와 다른 레인지로 Fixed모드로 설정된 경우
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
		else
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
			
		change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

		if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
              
		start_smu_dac(ch);             
		Delay_ms(delay);
	}  
         
	meas_measure_current(ch, average_cnt);

	//float MsrVal[adc_buff_msr_cnt-1];
	char addString[64];
	int loopCount,i;
	float adcfval,idutval;
	unsigned long *pTmpVal;

	loopCount=average_cnt;

	sprintf(msr_val, "SMU,%d,I,", ch+1);

	for (i=0;i<loopCount;i++)
	{	
		adcfval=adcval_to_float(adc_buff[i].smu_iadc[ch]);
		idutval=get_smu_idut(ch,smu_ctrl_reg[ch].imsr_rng,adcfval);
		pTmpVal = (unsigned long*) &idutval;
		sprintf(addString, "%x,", *pTmpVal);		
		strcat(msr_val, addString);
	}

	sprintf(addString, "%d,", smu_ctrl_reg[ch].imsr_rng);
	strcat(msr_val, addString);

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
    if (smu_ctrl_reg[ch].state == 'V')
			strcat(msr_val, "N\r");
    else
			strcat(msr_val, "C\r");
  }
  else 
	{
    if (smu_ctrl_reg[ch].state == 'I') 
      strcat(msr_val, "N\r");
    else
			strcat(msr_val, "C\r");
	}

	//printf(" %s\n",msr_val);
	//printf("Measure Current end\n");
}

// 2012.02.28 ydh
void get_smu_measure_current_rawdata(char *msr_val, int ch, int start_idx, int num)
{

	//float MsrVal[adc_buff_msr_cnt-1];
	char addString[64];
	int loopStart, loopEnd, i;
	float adcfval,idutval;
	unsigned long *pTmpVal;

	loopStart=start_idx;
	loopEnd=start_idx + num;

	sprintf(msr_val, "SMU,%d,I,", ch+1);

	for (i=loopStart; i<loopEnd; i++)
	{	
		adcfval=adcval_to_float(adc_buff[i].smu_iadc[ch]);
		idutval=get_smu_idut(ch,smu_ctrl_reg[ch].imsr_rng,adcfval);
		pTmpVal = (unsigned long*) &idutval;
		sprintf(addString, "%x,", *pTmpVal);		
		strcat(msr_val, addString);
	}

	//sprintf(addString, "%d", smu_ctrl_reg[ch].imsr_rng);
	strcat(msr_val, " (END)");

	/*if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
        if (smu_ctrl_reg[ch].state == 'V')
			strcat(msr_val, "N\r");
        else
			strcat(msr_val, "C\r");
    }
    else 
	{
        if (smu_ctrl_reg[ch].state == 'I') 
    			strcat(msr_val, "N\r");
        else
			strcat(msr_val, "C\r");
	}*/

	//printf(" %s\n",msr_val);
   
	//printf("Measure Current end\n");

}

// not used, 작업중 (20080214)
float gndu_measure(int mux_ch, int avg_cnt)
{
	gndu_adc_acquire(mux_ch, avg_cnt);
	
	adc_val_reg.gndu_adc_out_val = adcval_to_float(adc_mean.gndu_adc);
		  
	if (mux_ch == GNDU_MUX_DIAG_ADCIN)
	{
		gndu_ctrl_reg.vmsr_rng = read_gndu_vrange();
		gndu_ctrl_reg.msr_val = get_gndu_vm(gndu_ctrl_reg.vmsr_rng, adc_val_reg.gndu_adc_out_val);
	}
	else
		gndu_ctrl_reg.msr_val = adc_val_reg.gndu_adc_out_val;
	  			
	return gndu_ctrl_reg.msr_val;
}

// not used, under construction. 수정 필요
void smu_source_start(int ch)
{   
	UINT32 delay = 0;
	float vdac_out_val;
	volatile int i;
	int current_vrange;//, current_irange;

    calculate_dac_out_val(ch);
	
	current_vrange = read_smu_vrange(ch);

    // SMU 전압레인지 설정 
    if (smu_ctrl_reg[ch].mode == SMU_MODE_I)   
	{
		vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
		if (vdac_out_val > 0) vdac_out_val = -vdac_out_val;
		if (smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
        dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val; 
		
		if (current_vrange < smu_ctrl_reg[ch].vmsr_rng)
		{ // 전압 레인지를 올려야 하는 경우 
			start_smu_dac(ch);
			Delay_ms(1);
			write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
		}
		else
		{ // 전압 레인지를 내리거나 그대로 유지하는 경우
			write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
			Delay_ms(1);
			start_smu_dac(ch);
		}
	}
    else
	{
		vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
		dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;

		if (current_vrange < smu_ctrl_reg[ch].src_rng)
		{ // 전압 레인지를 올려야 하는 경우 
			start_smu_dac(ch);
			Delay_ms(1);
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); //전압 레인지 설정
		}
		else
		{ // 전압 레인지를 내리거나 그대로 유지하는 경우
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); //전압 레인지 설정
			Delay_ms(1);
			start_smu_dac(ch);
		}
	}
    
	// 전류 레인지 바꾸는 부분은 추후 수정이 필요
    // 전류레인지 설정
    if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
    {    
    	write_smu_isrc_range(ch, smu_ctrl_reg[ch].src_rng);
        if (delay < delay_reg.smu_isrc_change[smu_ctrl_reg[ch].src_rng])
        	delay = delay_reg.smu_isrc_change[smu_ctrl_reg[ch].src_rng];
    }
    else
    {
    	write_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
        if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
        	delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
    }
   	
	Delay_ms(delay);
}


/*
// 수정 (20070119)
// 전압 출력값을 생성하는 루틴
void smu_source_voltage_start(int ch)
{   
	UINT32 delay = 0;
	float vdac_out_val, idac_out_val;
	volatile int i;
	int current_vrange, current_irange;

	calculate_dac_out_val(ch);

	current_vrange = read_smu_vrange(ch); // 현재 설정돼 있는 전압레인지
	current_irange = read_smu_irange(ch); // 현재 설정돼 있는 전류레인지

    if ( (current_vrange == smu_ctrl_reg[ch].src_rng) && (current_irange == smu_ctrl_reg[ch].imsr_rng) )
	{ // 전압 레인지, 전류 레인지를 바꿀 필요가 없는 경우 (지금 당장 바꿀 필요는 없을 때)
		start_smu_dac(ch);
		
		Delay_ms(2); // Delay 필요 (20061229)

		meas_remove_limit_current_all();
	}
	else
	{	// 전압레인지 또는 전류레인지를 바꿔야 하는 경우
		// 1) 전압DAC는 0V 출력
		// 2) 전압레인지 설정
		// 3) 전류레인지 설정
		// 4) 전압DAC 출력 복원
		
		vdac_out_val = dac_val_reg.smu_vdac_out_val[ch];
		dac_val_reg.smu_vdac_out_val[ch] = 0;
		start_smu_dac(ch);

		//전압레인지 설정
		if (current_vrange != smu_ctrl_reg[ch].src_rng)
		{
			Delay_us(500);
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); 
			Delay_us(100);
		}
		else
		{
//			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng);
		}

		// 전류레인지 설정
		if (current_irange != smu_ctrl_reg[ch].imsr_rng)
		{
		//	write_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
 
			if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
        		delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
		}
		else
		{
//			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
		//	write_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
		}

		dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
		start_smu_dac(ch);
		Delay_ms(delay); // Sleep(delay);

		Delay_ms(2); // Delay 필요 (20061229)
		
		meas_remove_limit_current_all();
	}
}
*/

// not used
void smu_source_voltage_start_1st(int ch)
{   
	UINT32 delay = 0;
	float vdac_out_val, idac_out_val;
	volatile int i;
	int current_vrange, current_irange;

	//calculate_dac_out_val(ch);  //Vdac, Idac 값 모두 구함

	current_vrange = read_smu_vrange(ch); // 현재 설정돼 있는 전압레인지
	current_irange = read_smu_irange(ch); // 현재 설정돼 있는 전류레인지

	//printf("fv : CVrng=%d SVrng%d, CIrng=%d LIrng=%d \n", current_vrange, smu_ctrl_reg[ch].src_rng, current_irange, smu_ctrl_reg[ch].limit_i_rng);

    if ( (current_vrange == smu_ctrl_reg[ch].src_rng) && (current_irange == smu_ctrl_reg[ch].imsr_rng ) )
	{ // 전압 레인지, 전류 레인지를 바꿀 필요가 없는 경우 (지금 당장 바꿀 필요는 없을 때)
		dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
		dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
		start_smu_dac(ch);
		//Delay_us(500);
	}
	else
	{	// 전압레인지 또는 전류레인지를 바꿔야 하는 경우
		// 1) 전압DAC는 0V 출력
		// 2) 전압레인지 설정
		// 3) 전류레인지 설정
		// 4) 전압DAC 출력 복원
		
		dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
		dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, current_irange, smu_ctrl_reg[ch].limit_val);

		delay = 0;

        
		// 2) 전압 레인지 변경
		if(current_vrange != smu_ctrl_reg[ch].src_rng) 
		{
            //if (current_irange != smu_ctrl_reg[ch].imsr_rng) Delay_us(3000);

			vdac_out_val = dac_val_reg.smu_vdac_out_val[ch];
						
			//0V
			dac_val_reg.smu_vdac_out_val[ch] = 0;
			start_smu_dac(ch);
			Delay_us(500); //위의 전압 0V안정화 시간

			//레인지변경
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); 
			Delay_us(500); // Delay_us(500);

           	dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
			start_smu_dac(ch);	
			Delay_us(500);
		}

        // 1) 전류레인지 설정
		else if (current_irange != smu_ctrl_reg[ch].imsr_rng)
		{
            vdac_out_val = dac_val_reg.smu_vdac_out_val[ch];

            dac_val_reg.smu_vdac_out_val[ch] = 0;
			start_smu_dac(ch);
            Delay_us(500); 

            dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
            idac_out_val = dac_val_reg.smu_idac_out_val[ch];

			delay = 0;
			if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
              
           // dac_val_reg.smu_vdac_out_val[ch] = 0;
            dac_val_reg.smu_idac_out_val[ch] = 0;
			start_smu_dac(ch);
            Delay_us(500); 

			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
            Delay_us(500); 

            //dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
            dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
            start_smu_dac(ch);

            Delay_us(500);

            dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
            //dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
            start_smu_dac(ch);

            Delay_us(500);
			//Delay_ms(delay); // 출력 전압에 따른 딜레이 적용 필요??
		}		


        //Delay_ms(100);//
		
		
	}	
}

void smu_source_voltage_start_multi(int selectCnt, int *p_ch)
{
	int cnt;
	//UINT32 delayFinal, delay[NO_OF_SMU];
        UINT32 delay[NO_OF_SMU];
	float vdac_out_val[NO_OF_SMU], idac_out_val[NO_OF_SMU];
	volatile int i;
	int current_vrange[NO_OF_SMU], current_irange[NO_OF_SMU];
	int flagFinal, flag[NO_OF_SMU];
	int vRangeFlagFinal, vRangeFlag[NO_OF_SMU];
	int iRangeFlagFinal, iRangeFlag[NO_OF_SMU];

	// 변수 초기화
	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		delay[cnt] = 0;
		vdac_out_val[cnt] = idac_out_val[cnt] = 0;
		current_vrange[cnt] = current_irange[cnt] = 0;
		flag[cnt] = 0;
		vRangeFlag[cnt] = 0;
		iRangeFlag[cnt] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		current_vrange[p_ch[cnt]] = read_smu_vrange(p_ch[cnt]); // 현재 설정돼 있는 전압레인지
		current_irange[p_ch[cnt]] = read_smu_irange(p_ch[cnt]); // 현재 설정돼 있는 전류레인지

		if ( (current_vrange[p_ch[cnt]] == smu_ctrl_reg[p_ch[cnt]].src_rng) && (current_irange[p_ch[cnt]] == smu_ctrl_reg[p_ch[cnt]].imsr_rng ) )
		{ 
            // 전압 레인지, 전류 레인지를 바꿀 필요가 없는 경우 (지금 당장 바꿀 필요는 없을 때)
			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
			dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
			start_smu_dac(p_ch[cnt]);
			//Delay_us(500);
		}
		else
		{
			flag[p_ch[cnt]] = 1;
			// 전압레인지 또는 전류레인지를 바꿔야 하는 경우
			// 1) 전압DAC는 0V 출력
			// 2) 전압레인지 설정
			// 3) 전류레인지 설정
			// 4) 전압DAC 출력 복원

			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
			dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], current_irange[p_ch[cnt]], smu_ctrl_reg[p_ch[cnt]].limit_val);

			vdac_out_val[p_ch[cnt]] = dac_val_reg.smu_vdac_out_val[p_ch[cnt]];

			//0V
			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], current_vrange[p_ch[cnt]], 0);
			start_smu_dac(p_ch[cnt]);
			//Delay_us(500); //위의 전압 0V안정화 시간
		}
	}

	flagFinal = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		flagFinal |= flag[p_ch[cnt]];
	}

	if(flagFinal)
	{
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if(flag[p_ch[cnt]] == 0) continue;
		}

		vRangeFlagFinal = 0;

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if(current_vrange[p_ch[cnt]] != smu_ctrl_reg[p_ch[cnt]].src_rng)
			{
				vRangeFlag[p_ch[cnt]] = 1;
				vRangeFlagFinal = 1;
			}
		}

		if(vRangeFlagFinal)
		{
			Delay_us(500);

			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				if(vRangeFlag[p_ch[cnt]] == 0)	continue;
				write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng);
			}
		}

		iRangeFlagFinal = 0;

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if (current_irange[p_ch[cnt]] != smu_ctrl_reg[p_ch[cnt]].imsr_rng)
			{
				iRangeFlag[p_ch[cnt]] = 1;
				iRangeFlagFinal = 1;
			}
		}

		if(iRangeFlagFinal)
		{
			Delay_us(500);

            
			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				if(iRangeFlag[p_ch[cnt]] == 0)	continue;

				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
				idac_out_val[p_ch[cnt]] = dac_val_reg.smu_idac_out_val[p_ch[cnt]];

				delay[p_ch[cnt]] = 0;
				if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng])
				delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];

				// dac_val_reg.smu_vdac_out_val[ch] = 0;
				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], current_irange[p_ch[cnt]], 0);
				start_smu_dac(p_ch[cnt]);
			}

			Delay_us(500);

			for(cnt = 0; cnt < selectCnt; cnt++)
			{
 				if(iRangeFlag[p_ch[cnt]] == 0)	continue;

				change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
			}

			Delay_us(500);

			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				if(iRangeFlag[p_ch[cnt]] == 0)	continue;

				dac_val_reg.smu_idac_out_val[p_ch[cnt]] = idac_out_val[p_ch[cnt]];
				start_smu_dac(p_ch[cnt]);
			}

			Delay_us(500);
		}

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
			start_smu_dac(p_ch[cnt]);
		}

		Delay_us(500);
	}
}

void smu_source_voltage_start(int ch)
{   
	UINT32 delay = 0;
	float vdac_out_val, idac_out_val;
	volatile int i;
	int current_vrange, current_irange;

	//calculate_dac_out_val(ch);  //Vdac, Idac 값 모두 구함
	current_vrange = read_smu_vrange(ch); // 현재 설정돼 있는 전압레인지
	current_irange = read_smu_irange(ch); // 현재 설정돼 있는 전류레인지
  //tmp_current_vrange=current_vrange;

	//printf("fv : CVrng=%d SVrng%d, CIrng=%d LIrng=%d \n", current_vrange, smu_ctrl_reg[ch].src_rng, current_irange, smu_ctrl_reg[ch].limit_i_rng);
    
	if ( (current_vrange == smu_ctrl_reg[ch].src_rng) && (current_irange == smu_ctrl_reg[ch].imsr_rng ) )
	{ // 전압 레인지, 전류 레인지를 바꿀 필요가 없는 경우 (지금 당장 바꿀 필요는 없을 때)
		dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
		dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
		start_smu_dac(ch);
        //Delay_us(500);
	}
	else
	{
		// 전압레인지 또는 전류레인지를 바꿔야 하는 경우
		// 1) 전압레인지 설정 -> 전압DAC는 0V 출력 -> 전압레인지 변경
		// 3) 전류레인지 설정
		// 4) 전압DAC 출력 복원
	    dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val); //바꿀전압레인지
		dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, current_irange, smu_ctrl_reg[ch].limit_val); //현재전류레인지
		vdac_out_val = dac_val_reg.smu_vdac_out_val[ch];
   
  //  //2017.01.20
		//dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, current_vrange, 0);
		//start_smu_vdac(ch);
		//Delay_us(1000); //위의 전압 0V안정화 시간

  //   //2) 전압 레인지 변경
		//if(current_vrange != smu_ctrl_reg[ch].src_rng) 
		//{    
		//	write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); 			
  //    Delay_us(500);
		//}

  //   //3) 출력 전압 설정
  //  dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
		//start_smu_vdac(ch);
		//Delay_us(1000);

    // 1) 전류레인지 설정
		if (current_irange != smu_ctrl_reg[ch].imsr_rng)
		{
            dac_val_reg.smu_vdac_out_val[ch] = calculate_smu_vdac_out_val(ch, current_vrange, smu_ctrl_reg[ch].src_val); 
			dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);//바꿀전류레인지
			idac_out_val = dac_val_reg.smu_idac_out_val[ch];

			delay = 0;
			if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];

			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
			Delay_us(500); 

			//dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
			dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
			start_smu_idac(ch);  
			Delay_us(500);  //추가 delay 필요, 없으면 전류 컴플라이언스 셋팅 완료 안된 상태에서 전압 인가하게 됨.. 순간 전압 컴플라이언스 안된
		}

        //2) 전압 레인지 변경
        if(current_vrange != smu_ctrl_reg[ch].src_rng) 
		{    
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); 			
            Delay_us(500);
		}

        //3) 출력 전압 설정
        dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
		start_smu_vdac(ch);
		Delay_us(1000);
		
    ////Delay_ms(delay); // 출력 전압에 따른 딜레이 적용 필요??
	}
}

// 전류 출력값을 생성하는 루틴
void smu_source_current_start_multi(int selectCnt, int *p_ch)
{
	int cnt;
	int irange[NO_OF_SMU];
    BOOL irange_changed[NO_OF_SMU];
	BOOL irange_changed_final;
    float prev_idac_out_val[NO_OF_SMU], vdac_out_val[NO_OF_SMU], idac_out_val[NO_OF_SMU];
    UINT32 dlyFinal, dly[NO_OF_SMU];

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		dly[cnt] = 0;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		prev_idac_out_val[p_ch[cnt]] = dac_val_reg.smu_idac_out_val[p_ch[cnt]]; // 이전 전류DAC값 저장
		calculate_dac_out_val(p_ch[cnt]); // 새로운 DAC값 계산

		write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); // 전압레인지 설정

		irange_changed[p_ch[cnt]] = FALSE;

		// 다음에 출력해야 할  V, I DAC 값 저장 
		idac_out_val[p_ch[cnt]] = dac_val_reg.smu_idac_out_val[p_ch[cnt]];
		vdac_out_val[p_ch[cnt]] = dac_val_reg.smu_vdac_out_val[p_ch[cnt]];

		irange[p_ch[cnt]] = read_smu_irange(p_ch[cnt]);

		if (irange[p_ch[cnt]] != smu_ctrl_reg[p_ch[cnt]].src_rng) 
		{ // 전류모드에서 전류 공급레인지를 바꿔야 하는 경우 
			irange_changed[p_ch[cnt]] = TRUE;                                   
			// 이전 전류값, 측정된 전압값 입력 
			smu_adc_acquire_voltage(p_ch[cnt], 3);
			adc_val_reg.smu_vadc_out_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_vadc[p_ch[cnt]]);
			dac_val_reg.smu_idac_out_val[p_ch[cnt]] = prev_idac_out_val[p_ch[cnt]]; // 이전 전류DAC값
			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = 2 * adc_val_reg.smu_vadc_out_val[p_ch[cnt]]; // 측정된 전압값(현재 DUT의 전압값)

			if (dly[p_ch[cnt]] < delay_reg.smu_isrc_change[smu_ctrl_reg[p_ch[cnt]].src_rng])
				dly[p_ch[cnt]] = delay_reg.smu_isrc_change[smu_ctrl_reg[p_ch[cnt]].src_rng];
		}       

		start_smu_dac(p_ch[cnt]);
	}

	dlyFinal = 0;
	irange_changed_final = 0;
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		irange_changed_final |= irange_changed[p_ch[cnt]];

		if(dlyFinal < dly[p_ch[cnt]])
			dlyFinal = dly[p_ch[cnt]];
	}

	if(irange_changed_final == 0)	return;

	Delay_ms(3);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(irange_changed[p_ch[cnt]])
		{
			dac_val_reg.smu_idac_out_val[p_ch[cnt]] = -3.75; // 변경(-9.1 -> -10.1) (20070124)
			start_smu_dac(p_ch[cnt]);

			change_smu_isrc_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng);
		}
	}

	Delay_ms(5);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(irange_changed[p_ch[cnt]])
		{
			dac_val_reg.smu_idac_out_val[p_ch[cnt]] = idac_out_val[p_ch[cnt]];
			start_smu_dac(p_ch[cnt]);
		}
	}

	Delay_ms(dlyFinal); // 추가 (20070124)

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if(irange_changed[p_ch[cnt]])
		{
			dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
			start_smu_dac(p_ch[cnt]);
		}
	}

	Delay_ms(dlyFinal);
}

void smu_source_current_start(int ch)
{   
	///////////////////////////////////////////////////////////////////////////////////////////
	// (1) 전류레인지를 바꿀 필요가 없는 경우
	//		1) 전압레인지 설정
	//		2) DAC 출력
	// (2) 전류레인지를 바꿔야 하는 경우 
	//		1) 전압레인지 설정
	//		2) 전류DAC는 이전 전류DAC값 출력, 전압DAC는 현재의 전압값이 유지되는 값 출력
	//		3) 전류DAC 최대값, 전압DAC 값 유지
	//		4) 전류레인지 설정
	//		5) 전류DAC값 복원, 전압DAC값 유지
	//		6) 전류DAC값 유지, 전압DAC값 복원
	////////////////////////////////////////////////////////////////////////////////////////////
    int irange;
    BOOL irange_changed;
    float prev_idac_out_val, vdac_out_val, idac_out_val;
    UINT32 dly = 0;

    prev_idac_out_val = dac_val_reg.smu_idac_out_val[ch]; // 이전 전류DAC값 저장
    calculate_dac_out_val(ch); // 새로운 DAC값 계산
       
    write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); // 전압레인지 설정
     
    irange_changed = FALSE;
    
    // 다음에 출력해야 할  V, I DAC 값 저장 
    idac_out_val = dac_val_reg.smu_idac_out_val[ch];
    vdac_out_val = dac_val_reg.smu_vdac_out_val[ch];
       
    irange = read_smu_irange(ch);

    if (irange != smu_ctrl_reg[ch].src_rng) 
	{ 
		// 전류모드에서 전류 공급레인지를 바꿔야 하는 경우 
		irange_changed = TRUE;                                   
		// 이전 전류값, 측정된 전압값 입력 
		smu_adc_acquire_voltage(ch, 3);
		adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);
		dac_val_reg.smu_idac_out_val[ch] = prev_idac_out_val; // 이전 전류DAC값
		dac_val_reg.smu_vdac_out_val[ch] = 2 * adc_val_reg.smu_vadc_out_val[ch]; // 측정된 전압값(현재 DUT의 전압값)

		if (dly < delay_reg.smu_isrc_change[smu_ctrl_reg[ch].src_rng])
				dly = delay_reg.smu_isrc_change[smu_ctrl_reg[ch].src_rng];
	}       
         
    start_smu_dac(ch);

    if (irange_changed) 
  	{
		Delay_ms(3);

		// I DAC 값을 최대로 설정  
		dac_val_reg.smu_idac_out_val[ch] = -3.75; // 변경(-9.1 -> -10.1) (20070124)

		start_smu_dac(ch);

		change_smu_isrc_range(ch, smu_ctrl_reg[ch].src_rng);
		Delay_ms(5);

		dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
	    start_smu_dac(ch);
		Delay_ms(dly); // 추가 (20070124)

		dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
		start_smu_dac(ch);

		Delay_ms(dly);
    }
}

void smu_source_voltage_start_all(void)
{   
	UINT32 delay = 0;
	float vdac_out_val[NO_OF_SMU];
	volatile int i;
	int current_vrange[NO_OF_SMU], current_irange[NO_OF_SMU];
	int ch;
	
	BOOL irange_changed = FALSE;

  calculate_dac_out_val_all();

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		current_vrange[ch] = read_smu_vrange(ch);
		current_irange[ch] = read_smu_irange(ch);
	}

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if ( current_vrange[ch] == smu_ctrl_reg[ch].src_rng )
		{ // 전압 레인지 바꿀 필요가 없는 경우  
			start_smu_dac(ch);
		}
		else
		{ // 
			vdac_out_val[ch] = dac_val_reg.smu_vdac_out_val[ch];
			dac_val_reg.smu_vdac_out_val[ch] = 0;
			start_smu_dac(ch);
		}
	}

	Delay_ms(1);

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if ( current_vrange[ch] != smu_ctrl_reg[ch].src_rng )
			write_smu_vrange(ch, smu_ctrl_reg[ch].src_rng); //전압 레인지 설정
	}

	Delay_ms(1);
	
	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if ( current_irange[ch] != smu_ctrl_reg[ch].imsr_rng )
		{
			irange_changed = TRUE;
			write_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

			if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
        		delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
		}
	}

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if ( current_vrange[ch] != smu_ctrl_reg[ch].src_rng )
		{
			dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val[ch];
			start_smu_dac(ch);
		}
	}
	
	if (irange_changed)
		Delay_ms(delay);
	
}

void gndu_source_start(void)
{
	float dac_out_val;

	dac_out_val = calculate_gndu_dac_out_val();
	dac_val_reg.gndu_dac_out_val = dac_out_val;

	start_gndu_dac();
}

void meas_measure(int ch, int average_cnt)
{
	meas_acquire(ch, average_cnt);
    
	adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);
  adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
   
  if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		smu_ctrl_reg[ch].vmsr_rng = read_smu_vrange(ch);
		smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].vmsr_rng, adc_val_reg.smu_vadc_out_val[ch]);
		smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_iadc_out_val[ch]);
  }
  else 
	{
		smu_ctrl_reg[ch].imsr_rng = read_smu_irange(ch);
		smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_vadc_out_val[ch]);
		smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
  }
    smu_ctrl_reg[ch].state = smu_state[ch];
}

void meas_measure_all(int average_cnt)
{
	int ch;

	meas_acquire_all(average_cnt);
    
	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);
			adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
   
			if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
			{
				smu_ctrl_reg[ch].vmsr_rng = read_smu_vrange(ch);
				smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].vmsr_rng, adc_val_reg.smu_vadc_out_val[ch]);
				smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_iadc_out_val[ch]);
			}
			else 
			{
				smu_ctrl_reg[ch].imsr_rng = read_smu_irange(ch);
				smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_vadc_out_val[ch]);
				smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
			}
			smu_ctrl_reg[ch].state = smu_state[ch];
		}
	}
}


void meas_measure_current_multi(int selectCnt, int *p_ch, int average_cnt)
{
	int cnt;

	meas_acquire_current_multi(selectCnt, p_ch, average_cnt);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		adc_val_reg.smu_iadc_out_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_iadc[p_ch[cnt]]);

		if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
		{
			smu_ctrl_reg[p_ch[cnt]].imsr_val = get_smu_idut(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, adc_val_reg.smu_iadc_out_val[p_ch[cnt]]);
		}
		else 
		{
			smu_ctrl_reg[p_ch[cnt]].imsr_rng = read_smu_irange(p_ch[cnt]);

			/*
			// for debug
			int i;
			for(i=0; i<9; i++){
			get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
			}
			*/

			smu_ctrl_reg[p_ch[cnt]].imsr_val = get_smu_idut(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, adc_val_reg.smu_iadc_out_val[p_ch[cnt]]);
		}
		smu_ctrl_reg[p_ch[cnt]].state = smu_state[p_ch[cnt]];	
	}
}


void meas_measure_current(int ch, int average_cnt)
{	
	meas_acquire_current(ch, average_cnt);

	adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);

	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_iadc_out_val[ch]);
	}
	else 
	{ 
		smu_ctrl_reg[ch].imsr_rng = read_smu_irange(ch);

		/*
		// for debug
		int i;
		for(i=0; i<9; i++){
		get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
		}
		*/
    
		smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);

	}
	smu_ctrl_reg[ch].state = smu_state[ch];	

}

/*
// 0927수정 
void meas_measure_current(int ch, int average_cnt)
{
    if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		meas_acquire_current(ch, average_cnt);
		adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
	
		smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_iadc_out_val[ch]);
    }
    else 
	{
		smu_ctrl_reg[ch].imsr_rng = read_smu_irange(ch);
		
		if (smu_ctrl_reg[ch].imsr_rng <= SMU_UPPER_LEAK_IRANGE)
		{
			meas_acquire(ch, average_cnt);
    
			adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
			adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);

			smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_vadc_out_val[ch]);
			smu_ctrl_reg[ch].imsr_val = get_smu_idut_leak(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch], smu_ctrl_reg[ch].vmsr_val);
		}
		else
		{
			meas_acquire_current(ch, average_cnt);
			adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
	
			smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
		}
    }

    smu_ctrl_reg[ch].state = smu_state[ch];
}
*/



void meas_measure_current_all(int average_cnt)
{
	int ch;

	meas_acquire_current_all(average_cnt);

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			adc_val_reg.smu_iadc_out_val[ch] = adcval_to_float(adc_mean.smu_iadc[ch]);
   
			if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
			{
				smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_iadc_out_val[ch]);
			}
			else 
			{
				smu_ctrl_reg[ch].imsr_rng = read_smu_irange(ch);
				smu_ctrl_reg[ch].imsr_val = get_smu_idut(ch, smu_ctrl_reg[ch].imsr_rng, adc_val_reg.smu_iadc_out_val[ch]);
			}
			smu_ctrl_reg[ch].state = smu_state[ch];
		}
	}
}


void meas_measure_voltage_multi(int selectCnt, int *p_ch, int average_cnt)
{
	int cnt;

    meas_acquire_voltage_multi(selectCnt, p_ch, average_cnt);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		adc_val_reg.smu_vadc_out_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_vadc[p_ch[cnt]]);

		if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_rng = read_smu_vrange(p_ch[cnt]);
			smu_ctrl_reg[p_ch[cnt]].vmsr_val = get_smu_vdut(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, adc_val_reg.smu_vadc_out_val[p_ch[cnt]]);
		}
		else 
		{
			smu_ctrl_reg[p_ch[cnt]].vmsr_val = get_smu_vdut(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, adc_val_reg.smu_vadc_out_val[p_ch[cnt]]);
		}
		smu_ctrl_reg[p_ch[cnt]].state = smu_state[p_ch[cnt]];
	}
}
       
void meas_measure_voltage(int ch, int average_cnt)
{

  meas_acquire_voltage(ch, average_cnt);

  adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);
 

  if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
  {
    smu_ctrl_reg[ch].vmsr_rng = read_smu_vrange(ch);
    smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].vmsr_rng, adc_val_reg.smu_vadc_out_val[ch]);
  }
  else 
  {
    smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_vadc_out_val[ch]);
  }
  smu_ctrl_reg[ch].state = smu_state[ch];  
}


// not used
void meas_measure_voltage_all(int average_cnt)
{
	int ch;

	meas_acquire_voltage_all(average_cnt);
    
	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			adc_val_reg.smu_vadc_out_val[ch] = adcval_to_float(adc_mean.smu_vadc[ch]);

			if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
			{
				smu_ctrl_reg[ch].vmsr_rng = read_smu_vrange(ch);
				smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].vmsr_rng, adc_val_reg.smu_vadc_out_val[ch]);
			}
			else 
			{
				smu_ctrl_reg[ch].vmsr_val = get_smu_vdut(ch, smu_ctrl_reg[ch].src_rng, adc_val_reg.smu_vadc_out_val[ch]);
			}
			smu_ctrl_reg[ch].state = smu_state[ch];
		}
	}
}

// not used, under construction
void meas_acquire(int ch, int average_cnt)
{
    int i;
    float adc_mean_val, ptp, vdac_out_val, idac_out_val;
    BOOL range_changed, is_limit, is_osc;
    int pre_change;
    UINT32 delay = 0;  
	// sbcho@20211130
    // float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

	// sbcho@20211130
    // range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    // range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4 

	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	    meas_remove_limit_voltage(ch);
	else
		meas_remove_limit_current(ch);

	meas_cnt = get_average_count(average_cnt);

    smu_adc_acquire(ch, meas_cnt);
   
	if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
	{
		if (smu_ctrl_reg[ch].vmsr_max_rng == smu_ctrl_reg[ch].vmsr_min_rng) //
			pre_change = RANGE_DISABLE;
		else
			pre_change = RANGE_YET;
	}
	else
	{
		if (smu_ctrl_reg[ch].imsr_max_rng == smu_ctrl_reg[ch].imsr_min_rng) //
			pre_change = RANGE_DISABLE;
		else
			pre_change = RANGE_YET;
	}
       
	range_changed = FALSE;

	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		while (TRUE) 
		{
			if (pre_change == RANGE_DISABLE) break; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_vadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'I') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_vadc[ch] - adc_min.smu_vadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;

			// sbcho@20211130
			if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
			
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed = FALSE;
					pre_change = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed = TRUE;
					pre_change = RANGE_UP;
				}
			}
            
			// sbcho@20211130
			else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN;
				}
			}
            
			else
			{
				range_changed = FALSE;
			}	
        
			if (range_changed == FALSE) break; // 레인지가 안 바뀐 경우 while문 탈출
        
			if (pre_change == RANGE_DOWN) smu_ctrl_reg[ch].vmsr_rng--;
			else smu_ctrl_reg[ch].vmsr_rng++;
				
			if (pre_change == RANGE_UP)
			{ // 전압 레인지를 올려야 하는 경우 
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}
				else
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}

				start_smu_dac(ch);
				Delay_ms(1);
				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
			}
			else
			{ // 전압 레인지를 내려야 하는 경우
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}
				else
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}

				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
				Delay_ms(1);
				start_smu_dac(ch);
			}
	            
			Delay_ms(10);

			smu_adc_acquire(ch, meas_cnt);
		}
	}

	else 
	{
		while (TRUE) 
		{
			if (pre_change == RANGE_DISABLE) break; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'V') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_iadc[ch] - adc_min.smu_iadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
			if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
				if(is_osc) 
				{
					if (smu_ctrl_reg[ch].imsr_rng < SMU_10uA_RANGE)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_rng + 1;
					if (smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;
				}

				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed = FALSE;
					pre_change = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed = TRUE;
					pre_change = RANGE_UP;
				}
			}
            
			else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN;
				}
			}
            
			else
			{
				range_changed = FALSE;
			}
        
			if (range_changed == FALSE) break; // 레인지가 안 바뀐 경우 while문 탈출
        
			if (pre_change == RANGE_DOWN) smu_ctrl_reg[ch].imsr_rng--;
			else smu_ctrl_reg[ch].imsr_rng++;
				
			idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
			dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                 // 전류 DAC가 출력해야 하는 값도 다시 계산
        
			delay = 0;

			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
                   
			if (pre_change == RANGE_UP) 
			{
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
					delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
			}
			else 
			{
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
					delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
			}    
        				
			start_smu_dac(ch); // 수정. 여기에 추가
	            
			Delay_ms(delay);

			smu_adc_acquire(ch, meas_cnt);
		}
	}
	
}

// not used
void meas_acquire_all(int average_cnt)
{
	int ch;
    int i;
    float adc_mean_val, ptp, vdac_out_val, idac_out_val;
    BOOL range_changed[NO_OF_SMU], is_limit, is_osc, flag;
    int pre_change[NO_OF_SMU];
    UINT32 delay = 0;
    // float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

	// sbcho@20211130
    // range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    // range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
	    
	meas_remove_limit_all();

	meas_cnt = get_average_count(average_cnt);

    smu_adc_acquire_all(meas_cnt);
   
	flag = FALSE;

	// 각 채널별로 레인지 변경이 가능한지 조사 
	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
			{
				if (smu_ctrl_reg[ch].vmsr_max_rng == smu_ctrl_reg[ch].vmsr_min_rng) //
					pre_change[ch] = RANGE_DISABLE;
				else
					pre_change[ch] = RANGE_YET;
			}
			else
			{
				if (smu_ctrl_reg[ch].imsr_max_rng == smu_ctrl_reg[ch].imsr_min_rng) //
					pre_change[ch] = RANGE_DISABLE;
				else
					pre_change[ch] = RANGE_YET;
			}
		}
		else
		{
			pre_change[ch] = RANGE_DISABLE;
		}
	}
       	
	while (TRUE) 
	{
		for(ch=0; ch<NO_OF_SMU; ch++)
			range_changed[ch] = FALSE;

		// 각 채널별로 레인지를 바꿔야 하는지 조사 
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if (pre_change[ch] == RANGE_DISABLE) continue; // 레인지 변경이 불가능한 채널은 이후의 for문은 필요없다. 

			if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
			{	// 전류모드. 전압 측정시 
				adc_mean_val = adcval_to_float(adc_mean.smu_vadc[ch]);
		
				if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
				is_limit = FALSE;
				is_osc = FALSE;
            
				for (i=0; i<meas_cnt; i++) 
				{
					if (smu_states[ch][i] != 'I') is_limit = TRUE;  // compliance가 걸린 경우
				}
            
				ptp = adcval_to_float(adc_max.smu_vadc[ch] - adc_min.smu_vadc[ch]); 
				if (ptp < 0) ptp = -ptp;                            
				if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
				if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
				{ // 레인지를 높여야 할 때
				// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
					if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_max_rng) 
					{// 더이상 올릴 수 없을 때
						range_changed[ch] = FALSE;
						pre_change[ch] = RANGE_DISABLE;
					}
					else 
					{ // 레인지 업
						range_changed[ch] = TRUE;
						pre_change[ch] = RANGE_UP;
					}
				}
            	else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change[ch] != RANGE_UP)) 
				{ // 레인지를 낮춰야 할 때
					if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_min_rng) 
					{
						range_changed[ch] = FALSE;
						pre_change[ch] = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
					}
					else 
					{
						range_changed[ch] = TRUE;
						pre_change[ch] = RANGE_DOWN;
					}
				}
            	else
				{
					range_changed[ch] = FALSE;
				}	
			}
			else
			{	// 전압모드. 전류 측정시
				adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		
				if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
				is_limit = FALSE;
				is_osc = FALSE;
            
				for (i=0; i<meas_cnt; i++) 
				{
					if (smu_states[ch][i] != 'V') is_limit = TRUE;  // compliance가 걸린 경우
				}
            
				ptp = adcval_to_float(adc_max.smu_iadc[ch] - adc_min.smu_iadc[ch]); 
				if (ptp < 0) ptp = -ptp;                            
				if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
				if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
				{ // 레인지를 높여야 할 때
				// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
					if(is_osc) 
					{
						if (smu_ctrl_reg[ch].imsr_rng < SMU_10uA_RANGE)
							smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_rng + 1;
						if (smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
							smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;
					}

					if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_max_rng) 
					{// 더이상 올릴 수 없을 때
						range_changed[ch] = FALSE;
						pre_change[ch] = RANGE_DISABLE;
					}
					else 
					{ // 레인지 업
						range_changed[ch] = TRUE;
						pre_change[ch] = RANGE_UP;
					}
				}
            	else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change[ch] != RANGE_UP)) 
				{ // 레인지를 낮춰야 할 때
					if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
					{
						range_changed[ch] = FALSE;
						pre_change[ch] = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
					}
					else 
					{
						range_changed[ch] = TRUE;
						pre_change[ch] = RANGE_DOWN;
					}
				}
            	else
				{
					range_changed[ch] = FALSE;
				}
			}
		}

		flag = FALSE;

		// 각 채널별로 조사된 레인지 변경사항 정보를 가지고 레인지 변경을 위한 
		// 값들을 생성한다.
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch]) // 레인지를 바꿔야하는 채널에 대해서
			{	
				flag = TRUE; // 레인지가 변경돼야하는 채널이 하나라도 있는 경우 flag는 TRUE
				
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
				{
					if (pre_change[ch] == RANGE_DOWN) smu_ctrl_reg[ch].vmsr_rng--;
					else smu_ctrl_reg[ch].vmsr_rng++;
				
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}
				else
				{
					if (pre_change[ch] == RANGE_DOWN) smu_ctrl_reg[ch].imsr_rng--;
					else smu_ctrl_reg[ch].imsr_rng++;
				
					idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
					dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
				}
			}
		}

		if (flag == FALSE) break; // 레인지를 바꿔야 하는 채널이 하나도 없는 경우 while 루프를 빠져나간다 
		
		delay = 0;
		// 레인지 변경이 필요한 채널은 레인지 변경 작업과 새로운 DAC출력 생성 작업을 실행한다.
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch])
			{
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
				{
					if (pre_change[ch] == RANGE_UP)
					{ // 전압 레인지를 올려야 하는 경우 
						start_smu_dac(ch);
						Delay_ms(1);
						write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
					}
					else
					{ // 전압 레인지를 내려야 하는 경우
						write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
						Delay_ms(1);
						start_smu_dac(ch);
					}
				}
				else
				{
					change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
                   
					if (pre_change[ch] == RANGE_UP) 
					{
						if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
							delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
					}
					else 
					{
						if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
							delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
					}    
					start_smu_dac(ch); 
				}
			}
		}
		Delay_ms(10);
		Delay_ms(delay);

		smu_adc_acquire_all(meas_cnt); // 레인지를 변경시킨 후 다시 측정을 실행한다.
	}
}

// 20200520 range 변경 multi수정
void meas_acquire_current_multi(int selectCnt, int *p_ch, int average_cnt)
{
	int i, j, cnt;
	float adc_mean_val[NO_OF_SMU], ptp[NO_OF_SMU], idac_out_val[NO_OF_SMU];
    BOOL range_changed[NO_OF_SMU], is_limit[NO_OF_SMU], is_osc[NO_OF_SMU];
    int pre_change[NO_OF_SMU];
    UINT32 delay[NO_OF_SMU];
	UINT32 delayFinal;
	UINT32 meas_cnt;
	int rng;

	int completeFlag[NO_OF_SMU];
	int completeFlagFinal;

	//int change_flag_selectCnt;
	int change_flag_ch[NO_OF_SMU];
	int change_flag_cnt;

	TSmuCtrlReg imsr_rng_temp[NO_OF_SMU];

	const int MODE_UP				= 1;
	const int MODE_MEAS				= 0;
	const int MODE_DOWN				= -1;

	

	// sbcho@20211130
	// const float range_up_volt		= 4.4; //RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    // const float range_down_volt		= 0.44; //RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
	// const float range_down2_volt	= 0.044;

	int mode[NO_OF_SMU];

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		mode[cnt] = 0;
		completeFlag[cnt] = 1;
		delay[cnt] = 0;
	}

	meas_cnt = 3;

	// 현재 레인지에서 측정
	// smu_adc_acquire_current_multi(selectCnt, p_ch, meas_cnt);
	// sbcho@20211214
	smu_adc_acquire_current_multi_check(selectCnt, p_ch, meas_cnt);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		adc_mean_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_iadc[p_ch[cnt]]);
		if (adc_mean_val[p_ch[cnt]] < 0) adc_mean_val[p_ch[cnt]] = -adc_mean_val[p_ch[cnt]];

		if( adc_mean_val[p_ch[cnt]] > smu_irng_up_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] ) mode[p_ch[cnt]] = MODE_UP;  //저항값 작게 전류 인덱스 크게, 더 큰전류로
		else if( adc_mean_val[p_ch[cnt]] < smu_irng_down_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] ) mode[p_ch[cnt]] = MODE_DOWN; //저항값 크게 전류 인덱스 작게
		else mode[p_ch[cnt]] = MODE_MEAS;
	}

	for(i=0; i<=1; i++)
	{
		meas_cnt = 3;

		while(true)
		{		
			change_flag_cnt = 0;		
			
			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				completeFlag[p_ch[cnt]] = 0;
				delay[p_ch[cnt]] = 0;

				if(mode[p_ch[cnt]] == MODE_UP)
				{
					//최대 측정 레인지이면 종료한다.
					if( smu_ctrl_reg[p_ch[cnt]].imsr_rng >= smu_ctrl_reg[p_ch[cnt]].imsr_max_rng )
					{
						completeFlag[p_ch[cnt]] = 1;
						continue;
					}

					//레인지 풀이면 레인지 한개 업
					if( adc_mean_val[p_ch[cnt]] > smu_irng_up_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] )
					{
						smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng + 1;
						imsr_rng_temp[change_flag_cnt].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng;
						change_flag_ch[change_flag_cnt] = p_ch[cnt];
						change_flag_cnt++;
						// printf("ch: %d range_up, imsr_rng %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
					}
					else 
					{
						completeFlag[p_ch[cnt]] = 1;
						continue;
					}

					//레인지 변경
//					idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val); // 전류 측정레인지가 바꼈으므로 
//					dac_val_reg.smu_idac_out_val[p_ch[cnt]] = idac_out_val[p_ch[cnt]];                                                      // 전류 DAC가 출력해야 하는 값도 다시 계산

//					printf("ch: %d change_imsr_before imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					printf("ch: %d change_imsr_after imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);

//					if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng]) 
//						delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];  
//					printf("ch: %d change_DAC_before imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					start_smu_dac(p_ch[cnt]);
//					printf("ch: %d change_DAC_after imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					printf("ch: %d VDAC_val %X, IDAC_val %X\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vdac_in_val, smu_ctrl_reg[p_ch[cnt]].idac_in_val);

				} // if(mode[p_ch[cnt]] == MODE_UP)
				else if(mode[p_ch[cnt]] == MODE_DOWN)
				{
					if( smu_ctrl_reg[p_ch[cnt]].imsr_rng <= smu_ctrl_reg[p_ch[cnt]].imsr_min_rng )
					{
						completeFlag[p_ch[cnt]] = 1;
						continue;
					}

					if( SMU_100uA_RANGE <= smu_ctrl_reg[p_ch[cnt]].imsr_rng )
					{
						if( adc_mean_val[p_ch[cnt]] < smu_irng_2down_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] )
						{
							smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng - 2; //2단계 다운
							imsr_rng_temp[change_flag_cnt].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng;
							change_flag_ch[change_flag_cnt] = p_ch[cnt];
							change_flag_cnt++;
							//printf("ch: %d range_down<100uA_2, imsr_rng %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
						}
						else if( adc_mean_val[p_ch[cnt]] < smu_irng_down_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] )
						{
							smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng - 1; //1단계 다운
							imsr_rng_temp[change_flag_cnt].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng;
							change_flag_ch[change_flag_cnt] = p_ch[cnt];
							change_flag_cnt++;
							//printf("ch: %d range_down<100uA_1, imsr_rng %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
						}
						else
						{
							completeFlag[p_ch[cnt]] = 1;
							continue;
						}
					}
					else
					{
						if( adc_mean_val[p_ch[cnt]] < smu_irng_down_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng] )
						{
							smu_ctrl_reg[p_ch[cnt]].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng - 1; //1단계 다운
							imsr_rng_temp[change_flag_cnt].imsr_rng = smu_ctrl_reg[p_ch[cnt]].imsr_rng;
							change_flag_ch[change_flag_cnt] = p_ch[cnt];
							change_flag_cnt++;

							//printf("ch: %d range_down1, imsr_rng %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
						}
						else
						{
							completeFlag[p_ch[cnt]] = 1;
							continue;
						}
					}

//					//레인지 변경
//					idac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val); // 전류 측정레인지가 바꼈으므로 
//					dac_val_reg.smu_idac_out_val[p_ch[cnt]] = idac_out_val[p_ch[cnt]];                                                      // 전류 DAC가 출력해야 하는 값도 다시 계산

//					printf("ch: %d change_DAC_before imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					start_smu_dac(p_ch[cnt]);
//					printf("ch: %d change_DAC_after imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					printf("ch: %d VDAC_val %X, IDAC_val %X\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vdac_in_val, smu_ctrl_reg[p_ch[cnt]].idac_in_val);
//
//					printf("ch: %d change_imsr_before imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					change_smu_imsr_range(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);
//					printf("ch: %d change_imsr_after imsr: %d\r\n", p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].imsr_rng);

//					if (delay[p_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng]) 
//						delay[p_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[p_ch[cnt]].imsr_rng];
				} // else if(mode[p_ch[cnt]] == MODE_DOWN)
				else
				{
					completeFlag[p_ch[cnt]] = 1;
					continue;
				}
			} // for(cnt = 0; cnt < selectCnt; cnt++)
			

			//RANGE CHANGE
			if(change_flag_cnt > 0)
				change_smu_imsr_range_multi(change_flag_cnt, change_flag_ch, smu_ctrl_reg);

			
			for(cnt = 0; cnt < change_flag_cnt; cnt++)
			{
				if (delay[change_flag_ch[cnt]] < delay_reg.smu_imsr_change[smu_ctrl_reg[change_flag_ch[cnt]].imsr_rng]) 
					delay[change_flag_ch[cnt]] = delay_reg.smu_imsr_change[smu_ctrl_reg[change_flag_ch[cnt]].imsr_rng]; 
				
				idac_out_val[change_flag_ch[cnt]] = calculate_smu_idac_out_val(change_flag_ch[cnt], smu_ctrl_reg[change_flag_ch[cnt]].imsr_rng, smu_ctrl_reg[change_flag_ch[cnt]].limit_val); // 전류 측정레인지가 바꼈으므로 
				dac_val_reg.smu_idac_out_val[change_flag_ch[cnt]] = idac_out_val[change_flag_ch[cnt]];
				
				//DAC SET
				start_smu_dac(change_flag_ch[cnt]);				
			}

			
			completeFlagFinal = 1;
			delayFinal = 0;
			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				completeFlagFinal &= completeFlag[p_ch[cnt]];
				if(delayFinal < delay[p_ch[cnt]]) delayFinal = delay[p_ch[cnt]];
			} // for(cnt = 0; cnt < selectCnt; cnt++)

			if(completeFlagFinal == 1) break;


			Delay_ms(delayFinal);

			// smu_adc_acquire_current_multi(selectCnt, p_ch, meas_cnt);
			// sbcho@20211214
			smu_adc_acquire_current_multi_check(selectCnt, p_ch, meas_cnt);

			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				adc_mean_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_iadc[p_ch[cnt]]);
				if (adc_mean_val[p_ch[cnt]] < 0) adc_mean_val[p_ch[cnt]] = -adc_mean_val[p_ch[cnt]];
			}

		} // while(true)




		meas_cnt = get_average_count(average_cnt);

		// sbcho@20211214 remove
		//1nA range 이하일때는 더미로 한번더 측정한다.
		// int retryCnt = 0;
		// for(cnt = 0; cnt < selectCnt; cnt++)
		// {
		// 	retryCnt |= smu_ctrl_reg[p_ch[cnt]].imsr_rng <= SMU_1nA_RANGE;
		// }
		// if(retryCnt) smu_adc_acquire_current_multi(selectCnt, p_ch, meas_cnt);	

		smu_adc_acquire_current_multi(selectCnt, p_ch, meas_cnt);
		
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			completeFlag[p_ch[cnt]] = 0;
			//최종 측정 레인지 체크
			adc_mean_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_iadc[p_ch[cnt]]);
			if (adc_mean_val[p_ch[cnt]] < 0) adc_mean_val[p_ch[cnt]] = -adc_mean_val[p_ch[cnt]];

			// TRACE("Measure ADC Voltage(ABS): %f, I range(Index): %d\r\n", adc_mean_val[p_ch[cnt]], smu_ctrl_reg[p_ch[cnt]].imsr_rng);	

			if		(adc_mean_val[p_ch[cnt]] > smu_irng_up_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng])			mode[p_ch[cnt]] = MODE_UP;			//저항값 작게 전류 인덱스 크게, 더 큰전류로
			//else if	(adc_mean_val[p_ch[cnt]] < range_down_volt)			mode[p_ch[cnt]] = MODE_DOWN; //저항값 크게 전류 인덱스 작게
			else
			{
				completeFlag[p_ch[cnt]] = 1;
				continue;													//측정 루프 끝냄		
			}
		}

		completeFlagFinal = 1;
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			completeFlagFinal &= completeFlag[p_ch[cnt]];
		}

		if(completeFlagFinal)	break;

	} // for(i=0; i<=1; i++)	
}

//edit : 2012.09.17 jhcho
void meas_acquire_current(int ch, int average_cnt)
{
	int i;
	float adc_mean_val, ptp, idac_out_val;
	BOOL range_changed, is_limit, is_osc;
	int pre_change;
	UINT32 delay = 0;
	// sbcho@20211130
	// float range_up_volt, range_down_volt, range_down2_volt;
	UINT32 meas_cnt;
	//int rng;

	int MODE_UP = 1;
	int MODE_MEAS = 0;
	int MODE_DOWN = -1;

	int mode = 0;

	// sbcho@20211130
	// range_up_volt = 4.4; //RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
	// range_down_volt = 0.44; //RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
	// range_down2_volt = 0.044;
	
	// 모드 확인
	//if( adc_mean_val < 0.5 ) { //레인지 최소 근접값일경우
	//	Delay_ms(20); //딜레이 적용해서 다시 측정합니다.
	//	//meas_cnt = 64;  //대신 1plc로 측정
	//	smu_adc_acquire_current(ch, meas_cnt);
	//	adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
	//	if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
	//	meas_cnt = 3; //원래데로 변경
	//}

	// SHORT 모드로 측정
	//meas_cnt = get_average_count(AVG_SHORT_MODE);
	meas_cnt = 3;
	//meas_cnt = 50;

	// 현재 레인지에서 측정
  //Test16_4_UP
	//smu_adc_acquire_current(ch, meas_cnt);
	smu_adc_acquire_current_check(ch, meas_cnt);

	adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
	if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

	// TRACE("Check ADC Voltage(ABS): %f, I range(Index): %d\r\n", adc_mean_val, smu_ctrl_reg[ch].imsr_rng);

	if( adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng] ) mode = MODE_UP;  //저항값 작게 전류 인덱스 크게, 더 큰전류로
	else if( adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng] ) mode = MODE_DOWN; //저항값 크게 전류 인덱스 작게
	else mode = MODE_MEAS;

	//전체 시퀀스를 최대 2번만 반복, 무한루프 방지
	for(i=0; i<=1; i++)
	{
		// SHORT 모드로 측정
		meas_cnt = 3;
		//meas_cnt = 50;
		//printf( "init : rng=%d adc_mean_val=%.3f \n", smu_ctrl_reg[ch].imsr_rng, adc_mean_val);
		
		delay = 0;
		if( mode == MODE_UP )  //저항값 작게 전류 인덱스 크게, 더 큰전류로
		{
			while(true)
			{
				//printf( "up : rng=%d adc_mean_val=%.3f \n", smu_ctrl_reg[ch].imsr_rng, adc_mean_val);

				//최대 측정 레인지이면 종료한다.
				if( smu_ctrl_reg[ch].imsr_rng >= smu_ctrl_reg[ch].imsr_max_rng ) break;
			
				//레인지 풀이면 레인지 한개 업
				if( adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng] ) smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_rng + 1;
				else break; //아니면 종료

				//레인지 변경
				idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
				dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                                      // 전류 DAC가 출력해야 하는 값도 다시 계산

				start_smu_dac(ch);
				//Delay_ms(10);

				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng]) 
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];  

				//Delay_ms(10);


				// up 레인지 동작은 1단계씩 동작
				// 100nA -> 10nA변경은 Rr이 500M -> 5M
				if(smu_ctrl_reg[ch].imsr_rng == SMU_100nA_RANGE) Delay_ms(10);
				// 10uA -> 1uA변경은 Rr이 5M -> 50k
				else if(smu_ctrl_reg[ch].imsr_rng == SMU_10uA_RANGE) Delay_ms(7);
				//else if(smu_ctrl_reg[ch].imsr_rng == SMU_10uA_RANGE) Delay_ms(100);
				// 나머지 5, 500, 50k저항변경
				else Delay_ms(2);

				

				// 현재 레인지에서 측정
        // x
				//smu_adc_acquire_current(ch, meas_cnt);
				smu_adc_acquire_current_check(ch, meas_cnt);
				
				adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
				if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

				// TRACE("Up Check ADC Voltage(ABS): %f, I range(Index): %d\r\n", adc_mean_val, smu_ctrl_reg[ch].imsr_rng);
			}
		}

		delay = 0;
		if( mode == MODE_DOWN )
		{
			while(true)
			{
				//printf( "down : rng=%d adc_mean_val=%.3f \n", smu_ctrl_reg[ch].imsr_rng, adc_mean_val);

				//Delay_ms(1000);

				//최소 측정 레인지이면 종료한다.
				if( smu_ctrl_reg[ch].imsr_rng <= smu_ctrl_reg[ch].imsr_min_rng ) break;
									
				//100uA ~ 100mA 레인지에서
				if( SMU_100uA_RANGE <= smu_ctrl_reg[ch].imsr_rng )
				{
					if( adc_mean_val < smu_irng_2down_volt[smu_ctrl_reg[ch].imsr_rng] ) smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_rng - 2; //2단계 다운
					else if( adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng] ) smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_rng - 1; //1단계 다운
					else break; //종료
				}
				//다른 레인지에서
				else
				{
					if( adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng] ) smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_rng - 1; //1단계 다운
					else break; //종료
				}
				

				////10nA보다 작을때는 리미트 레인지로 한번 변경후 다시 내린다
				//if( smu_ctrl_reg[ch].imsr_rng <= SMU_1uA_RANGE )
				//{
				//	printf( "change limit : rng=%d \n", smu_ctrl_reg[ch].limit_i_rng);
				//	dac_val_reg.smu_idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].limit_i_rng, smu_ctrl_reg[ch].limit_val);
				//
				//	change_smu_imsr_range(ch, smu_ctrl_reg[ch].limit_i_rng);

				//	delay = 0;
				//	if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].limit_i_rng])
				//		delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].limit_i_rng];
			 //             
				//	start_smu_dac(ch);
				//	               
				//	Delay_ms(delay); //마지막은 delay 없이 진행
				//}

				//레인지 변경
        // 2017
				idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
				dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                                      // 전류 DAC가 출력해야 하는 값도 다시 계산
		        
				start_smu_dac(ch);
				//Delay_ms(10);

				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
				
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng]) 
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];  
				
				//Delay_ms(10);
				//Delay_ms(8);


				// down레인지 동작에서 10uA레인지 이하일 때는 1단계씩 동작
				// 10uA -> 1uA변경은 Rr이 50k -> 5M
				if(smu_ctrl_reg[ch].imsr_rng == SMU_1uA_RANGE) Delay_ms(7);
				// 100nA -> 10nA변경은 Rr이 5M -> 500M
				else if(smu_ctrl_reg[ch].imsr_rng == SMU_10nA_RANGE) Delay_ms(10);
				// 나머지 5, 500, 50k저항변경
				else Delay_ms(2);

				
				// 현재 레인지에서 측정
        // Test16_4_UP
				//smu_adc_acquire_current(ch, meas_cnt);
				smu_adc_acquire_current_check(ch, meas_cnt);
				
				adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
				if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

				// TRACE("Down Check ADC Voltage(ABS): %f, I range(Index): %d\r\n", adc_mean_val, smu_ctrl_reg[ch].imsr_rng);
			}
		}

        switch(smu_ctrl_reg[ch].imsr_rng)
        {
            case SMU_10uA_RANGE: Delay_us(400);	break;	
            case SMU_1uA_RANGE: Delay_us(2600); break;
            case SMU_100nA_RANGE: Delay_us(1400); break;
            case SMU_10nA_RANGE: Delay_us(3300); break;
            case SMU_1nA_RANGE: Delay_us(3000); break;
            default: Delay_us(400); break;	
        }
        
        
//        Delay_ms(1);
		//Delay_ms(4);

		// 실제 설정된 Average 모드로 측정
		meas_cnt = get_average_count(average_cnt);
 
		//1nA range 이하일때는 더미로 한번더 측정한다.
		//if( smu_ctrl_reg[ch].imsr_rng <= SMU_1nA_RANGE ) smu_adc_acquire_current(ch, meas_cnt);	
		
    // Test16_4_UP
		smu_adc_acquire_current(ch, meas_cnt);	
	

		//최종 측정 레인지 체크
		adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

		// TRACE("Measure ADC Voltage(ABS): %f, I range(Index): %d\r\n", adc_mean_val, smu_ctrl_reg[ch].imsr_rng);

		if( adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng] ) mode = MODE_UP;			//저항값 작게 전류 인덱스 크게, 더 큰전류로
		//else if( adc_mean_val < range_down_volt ) mode = MODE_DOWN; //저항값 크게 전류 인덱스 작게
		else break;													//측정 루프 끝냄		
	}

}   
	
/* 동작 백업
void meas_acquire_current(int ch, int average_cnt)
{
    int i;
    float adc_mean_val, ptp, idac_out_val;
    BOOL range_changed, is_limit, is_osc;
    int pre_change;
    UINT32 delay = 0;
    float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

    range_up_volt = 4.4; //RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    range_down_volt = 0.4;//RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
    
	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	    meas_remove_limit_current(ch);
	   // meas_remove_limit_current_all();

	meas_cnt = get_average_count(average_cnt);

    smu_adc_acquire_current(ch, meas_cnt);
   
    if (smu_ctrl_reg[ch].imsr_max_rng == smu_ctrl_reg[ch].imsr_min_rng) //
		pre_change = RANGE_DISABLE;
    else
		pre_change = RANGE_YET;
       
	range_changed = FALSE;

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
		while (TRUE) 
		{
			if (pre_change == RANGE_DISABLE) break; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'V') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_iadc[ch] - adc_min.smu_iadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
			if((adc_mean_val > range_up_volt) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
				if(is_osc) 
				{
					if (smu_ctrl_reg[ch].imsr_rng < SMU_10uA_RANGE)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_rng + 1;
					if (smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;
				}

				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed = FALSE;
					pre_change = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed = TRUE;
					pre_change = RANGE_UP;
				}
			}
            
			else if ((adc_mean_val < range_down_volt) && (pre_change != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN;
				}
			}
            
			else
			{
				range_changed = FALSE;
			}
        
			if (range_changed == FALSE) break; // 레인지가 안 바뀐 경우 while문 탈출
        
			if (pre_change == RANGE_DOWN) smu_ctrl_reg[ch].imsr_rng--;
			else smu_ctrl_reg[ch].imsr_rng++;
				
			idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
			dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                 // 전류 DAC가 출력해야 하는 값도 다시 계산
        
			delay = 0;

//			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
                   
			if (pre_change == RANGE_UP) 
			{
				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
//				Sleep(2);
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
					delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
				start_smu_dac(ch);
			}
			else 
			{
				start_smu_dac(ch);
//				Sleep(2);
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
					delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
			}    
        
//			start_smu_dac(ch); // 수정. 여기에 추가
	            
//			Sleep(delay*2);
			Delay_ms(delay);

			smu_adc_acquire_current(ch, meas_cnt);
		}
	}
}   
*/

/*
// 측정중 버그 발생 (2011.02.24) jhc
// 수정 작업중 (20071031)
// 레인지 내릴 때 두단계씩 내리는 거 실험
// 레인지 올릴 때 적용 딜레이 시간 변경 (아래레인지 딜레이 -> 위레인지 딜레이)
// 
void meas_acquire_current(int ch, int average_cnt)
{
    int i;  
    float adc_mean_val, ptp, idac_out_val;
    BOOL range_changed, is_limit, is_osc;
    int pre_change;
    UINT32 delay = 0;
    float range_up_volt, range_down_volt, range_down_volt_2step;
	UINT32 meas_cnt;

    range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
 	range_down_volt_2step = 0.04;

	
	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	    meas_remove_limit_current(ch);

    //아래수정 cjh 2010.10.06
	//if(smu_ctrl_reg[ch].imsr_rng <= SMU_100nA_RANGE)
	//	Delay_ms(5);
    if(smu_ctrl_reg[ch].imsr_rng <= SMU_1nA_RANGE)
    {
		//Delay_ms(20);
        meas_cnt = 64;
		smu_adc_acquire_current(ch, meas_cnt);
    }
    else if(smu_ctrl_reg[ch].imsr_rng <= SMU_100nA_RANGE)
		Delay_ms(5);
    //

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I)
	{	
		// SHORT 모드로 측정
		meas_cnt = get_average_count(AVG_SHORT_MODE);
		smu_adc_acquire_current(ch, meas_cnt);
	}
	else
	{
		meas_cnt = get_average_count(average_cnt);
		smu_adc_acquire_current(ch, meas_cnt);
	}

    if (smu_ctrl_reg[ch].imsr_max_rng == smu_ctrl_reg[ch].imsr_min_rng) //
		pre_change = RANGE_DISABLE;
    else
		pre_change = RANGE_YET;
       
	range_changed = FALSE;

	if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
	{
		while (TRUE) 
		{
			if (pre_change == RANGE_DISABLE) break; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'V') is_limit = TRUE;  // compliance가 걸린 경우
			}
			
            
			ptp = adcval_to_float(adc_max.smu_iadc[ch] - adc_min.smu_iadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                     
			if((adc_mean_val > range_up_volt) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
				if(is_osc) 
				{
					if (smu_ctrl_reg[ch].imsr_rng < SMU_10uA_RANGE)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_rng + 1;
					if (smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;
				}

				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed = FALSE;
					pre_change = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed = TRUE;
					pre_change = RANGE_UP;
				}
			}
            
			else if ((adc_mean_val < range_down_volt_2step) && (pre_change != RANGE_UP)) 
			{ // 레인지를 두단계 낮춰야 할 때
				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN_2STEP;
				}
			}

			else if ((adc_mean_val < range_down_volt) && (pre_change != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN;
				}
			}
            
			else
			{
				range_changed = FALSE;
			}
        
			if (range_changed == FALSE) break; // 레인지가 안 바뀐 경우 while문 탈출
        
			if (pre_change == RANGE_DOWN_2STEP)
			{
				smu_ctrl_reg[ch].imsr_rng--;
				if (smu_ctrl_reg[ch].imsr_rng != smu_ctrl_reg[ch].imsr_min_rng)
				{
					smu_ctrl_reg[ch].imsr_rng--;
				}
			}
			else if (pre_change == RANGE_DOWN)
				smu_ctrl_reg[ch].imsr_rng--;
			else smu_ctrl_reg[ch].imsr_rng++;
				
			idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
			dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                 // 전류 DAC가 출력해야 하는 값도 다시 계산
        
			delay = 0;

                   
			if (pre_change == RANGE_UP) 
			{
				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);

				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
				start_smu_dac(ch);
			}
			else 
			{
				start_smu_dac(ch);
			
				if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
					delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
				change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
			}    
    
//			Delay_ms(delay);

			//아래수정 cjh 2010.10.06 , 1nA에서는 최소 20ms 이상 delay가 꼭 필요함, 측정시 초기값이 튀거나, 측정값이 흔들림
	        //if(smu_ctrl_reg[ch].imsr_rng <= SMU_100nA_RANGE)
	        //	Delay_ms(5);
            if(smu_ctrl_reg[ch].imsr_rng <= SMU_1nA_RANGE)
            {
		     //  Delay_ms(20);
                meas_cnt = 64;
		        smu_adc_acquire_current(ch, meas_cnt);
            } 
            else if(smu_ctrl_reg[ch].imsr_rng <= SMU_100nA_RANGE)
		       Delay_ms(5);
            //------------------------------------------------------

            meas_cnt = get_average_count(AVG_SHORT_MODE);
			smu_adc_acquire_current(ch, meas_cnt); // SHORT 모드로 측정
		} // while
		
		if (average_cnt != AVG_SHORT_MODE)
		{
			// 실제 설정된 Average 모드로 측정
			meas_cnt = get_average_count(average_cnt);
			smu_adc_acquire_current(ch, meas_cnt);
		}
		
	}
}
*/

// not used
void meas_acquire_current_all(int average_cnt)
{
	int ch;
    int i;
    float adc_mean_val, ptp, idac_out_val;
    BOOL range_changed[NO_OF_SMU], is_limit, is_osc, flag;
    int pre_change[NO_OF_SMU];
    UINT32 delay = 0;
    // float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

    // range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    // range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
    
	meas_remove_limit_current_all();

	meas_cnt = get_average_count(average_cnt);

    smu_adc_acquire_current_all(meas_cnt);
	            
    for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			if (smu_ctrl_reg[ch].mode != SMU_MODE_I)
			{
				if (smu_ctrl_reg[ch].imsr_max_rng == smu_ctrl_reg[ch].imsr_min_rng) //
					pre_change[ch] = RANGE_DISABLE;
				else
					pre_change[ch] = RANGE_YET;
			}
			else
			{
				pre_change[ch] = RANGE_DISABLE;
			}
		}
		else
		{
			pre_change[ch] = RANGE_DISABLE;
		}
	}

   	while (TRUE) 
	{
		for(ch=0; ch<NO_OF_SMU; ch++)
			range_changed[ch] = FALSE;

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if (pre_change[ch] == RANGE_DISABLE) continue; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'V') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_iadc[ch] - adc_min.smu_iadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
			if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
				if(is_osc) 
				{
					if (smu_ctrl_reg[ch].imsr_rng < SMU_10uA_RANGE)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_rng + 1;
					if (smu_ctrl_reg[ch].imsr_min_rng > smu_ctrl_reg[ch].imsr_max_rng)
						smu_ctrl_reg[ch].imsr_min_rng = smu_ctrl_reg[ch].imsr_max_rng;
				}

				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed[ch] = FALSE;
					pre_change[ch] = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed[ch] = TRUE;
					pre_change[ch] = RANGE_UP;
				}
			}
          	else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change[ch] != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].imsr_rng == smu_ctrl_reg[ch].imsr_min_rng) 
				{
					range_changed[ch] = FALSE;
					pre_change[ch] = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed[ch] = TRUE;
					pre_change[ch] = RANGE_DOWN;
				}
			}
          	else
			{
				range_changed[ch] = FALSE;
			}
		}

		flag = FALSE;
        
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch]) // 레인지를 바꿔야하는 채널에 대해서
			{	
				flag = TRUE; // 
			        
				if (pre_change[ch] == RANGE_DOWN) smu_ctrl_reg[ch].imsr_rng--;
				else smu_ctrl_reg[ch].imsr_rng++;
				
				idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val); // 전류 측정레인지가 바꼈으므로 
				dac_val_reg.smu_idac_out_val[ch] = idac_out_val;                                 // 전류 DAC가 출력해야 하는 값도 다시 계산
			}
		}

		if (flag == FALSE) break; // 레인지를 바꿔야 하는 채널이 하나도 없는 경우 while 루프를 빠져나간다

		delay = 0;
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch])
			{
        		change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng);
                   
				if (pre_change[ch] == RANGE_UP) 
				{
					if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
						delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
				}
				else 
				{
					if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
						delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
				}    
        				
				start_smu_dac(ch);
			}
		}
	    Delay_ms(delay);

		smu_adc_acquire_current_all(meas_cnt);
	}
	
}

void meas_acquire_voltage_multi(int selectCnt, int *p_ch, int average_cnt)
{
	int flag[NO_OF_SMU], flagFinal;
	int i, cnt;
	int pre_change[NO_OF_SMU];
	BOOL range_changed[NO_OF_SMU], is_limit[NO_OF_SMU], is_osc[NO_OF_SMU];
	float adc_mean_val[NO_OF_SMU], ptp[NO_OF_SMU], vdac_out_val[NO_OF_SMU];
	// float range_up_volt, range_down_volt;
	UINT32 meas_cnt;
	int completeFlag[NO_OF_SMU], complete = 0;

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
		completeFlag[cnt] = 1;

	// range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
	// range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  

	/*
	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
		meas_remove_limit_voltage(p_ch[cnt]);
	}
	*/

	// 위의 for문으로 구성된 부분을 일괄처리하기 위하여 아래 함수 사용

	meas_remove_limit_voltage_multi(selectCnt, p_ch);

	meas_cnt = get_average_count(average_cnt);
    
	smu_adc_acquire_voltage_multi(selectCnt, p_ch, meas_cnt);

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		if (smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng == smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng) //
			pre_change[p_ch[cnt]] = RANGE_DISABLE;
		else
			pre_change[p_ch[cnt]] = RANGE_YET;

		range_changed[p_ch[cnt]] = FALSE;
	}

	while(true)
	{
		complete = 1;
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if(pre_change[p_ch[cnt]] == RANGE_DISABLE)
				completeFlag[p_ch[cnt]] = 1;
			else
				completeFlag[p_ch[cnt]] = 0;

			complete &= completeFlag[p_ch[cnt]];
		}

		if(complete)	break;		// 루프 탈출

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if((smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) || (pre_change[p_ch[cnt]] == RANGE_DISABLE))
				continue;

			adc_mean_val[p_ch[cnt]] = adcval_to_float(adc_mean.smu_vadc[p_ch[cnt]]);

			if (adc_mean_val[p_ch[cnt]] < 0) adc_mean_val[p_ch[cnt]] = -adc_mean_val[p_ch[cnt]];

			is_limit[p_ch[cnt]] = FALSE;
			is_osc[p_ch[cnt]] = FALSE;

			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[p_ch[cnt]][i] != 'I') is_limit[p_ch[cnt]] = TRUE;  // compliance가 걸린 경우
			}

			ptp[p_ch[cnt]] = adcval_to_float(adc_max.smu_vadc[p_ch[cnt]] - adc_min.smu_vadc[p_ch[cnt]]);

			if (ptp[p_ch[cnt]] < 0) ptp[p_ch[cnt]] = -ptp[p_ch[cnt]];

			if (ptp[p_ch[cnt]] > OSC_DETECT_PTP_VOLT) is_osc[p_ch[cnt]] = TRUE;

			if((adc_mean_val[p_ch[cnt]] > smu_irng_up_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng]) || is_limit[p_ch[cnt]]) 
			{ // 레인지를 높여야 할 때
				// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.

				if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng == smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed[p_ch[cnt]] = FALSE;
					pre_change[p_ch[cnt]] = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed[p_ch[cnt]] = TRUE;
					pre_change[p_ch[cnt]] = RANGE_UP;
				}
			}
			else if ((adc_mean_val[p_ch[cnt]] < smu_irng_down_volt[smu_ctrl_reg[p_ch[cnt]].imsr_rng]) && (pre_change[p_ch[cnt]] != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng == smu_ctrl_reg[p_ch[cnt]].vmsr_min_rng) 
				{
					range_changed[p_ch[cnt]] = FALSE;
					pre_change[p_ch[cnt]] = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed[p_ch[cnt]] = TRUE;
					pre_change[p_ch[cnt]] = RANGE_DOWN;
				}
			}
			else
			{
				range_changed[p_ch[cnt]] = FALSE;
			}
		}

		complete = 1;

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if(range_changed[p_ch[cnt]] == FALSE)
				completeFlag[p_ch[cnt]] = 1;
			else
				completeFlag[p_ch[cnt]] = 0;

			complete &= completeFlag[p_ch[cnt]];
		}

		if(complete)	break;

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			flag[p_ch[cnt]] = 0;
			if (smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) continue;
			if (range_changed[p_ch[cnt]] == FALSE) continue; // 레인지가 안 바뀐 경우 while문 탈출
			if (pre_change[p_ch[cnt]] == RANGE_DISABLE)	continue;

			if (pre_change[p_ch[cnt]] == RANGE_DOWN) smu_ctrl_reg[p_ch[cnt]].vmsr_rng--;
			else smu_ctrl_reg[p_ch[cnt]].vmsr_rng++;

			if (pre_change[p_ch[cnt]] == RANGE_UP)
			{ // 전압 레인지를 올려야 하는 경우 
				if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
				{
					vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
					if(vdac_out_val > 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
					if(smu_ctrl_reg[p_ch[cnt]].src_val < 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
					dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
				}
				else
				{
					vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
					dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
				}

				start_smu_dac(p_ch[cnt]);
				flag[p_ch[cnt]] = 1;
			}
			else
			{ // 전압 레인지를 내려야 하는 경우
				if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
				{
					vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
					if(vdac_out_val > 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
					if(smu_ctrl_reg[p_ch[cnt]].src_val < 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
					dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
				}
				else
				{
					vdac_out_val[p_ch[cnt]] = calculate_smu_vdac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].src_rng, smu_ctrl_reg[p_ch[cnt]].src_val);
					dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
				}

				write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
				flag[p_ch[cnt]] = 1;
			}
		}

		flagFinal = 0;
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			flagFinal |= flag[p_ch[cnt]];
		}
		if(flagFinal)
			Delay_ms(1);

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if (smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) continue;
			if (range_changed[p_ch[cnt]] == FALSE) continue; // 레인지가 안 바뀐 경우 while문 탈출
			if (pre_change[p_ch[cnt]] == RANGE_DISABLE)	continue;

			if (pre_change[p_ch[cnt]] == RANGE_UP)
			{ // 전압 레인지를 올려야 하는 경우 
				write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
			}
			else
			{ // 전압 레인지를 내려야 하는 경우
				start_smu_dac(p_ch[cnt]);
			}
		}

		smu_adc_acquire_voltage_multi(selectCnt, p_ch, meas_cnt);

		// 반복이 필요한지 검사

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if((smu_ctrl_reg[p_ch[cnt]].mode != SMU_MODE_I) || (range_changed[p_ch[cnt]] == FALSE) || (pre_change[p_ch[cnt]] == RANGE_DISABLE))
			{
				completeFlag[p_ch[cnt]] = 1;
			}
			else
			{
				completeFlag[p_ch[cnt]] = 0;
			}
		}

		complete = 1;

		for(cnt = 0; cnt < NO_OF_SMU; cnt++)
		{
			complete &= completeFlag[cnt];
		}

		if(complete == 1)	break;			// 모든 SMU의 측정이 끝나면 종료한다.
	}
}

// not used, under construction
void meas_acquire_voltage(int ch, int average_cnt)
{
  int i;
  float adc_mean_val, ptp, vdac_out_val;
  BOOL range_changed, is_limit, is_osc;
  int pre_change;
  UINT32 delay = 0;
//   float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

//   range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
//   range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
    
	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
		meas_remove_limit_voltage(ch);

	meas_cnt = get_average_count(average_cnt);

  smu_adc_acquire_voltage(ch, meas_cnt);
	          
  
  if (smu_ctrl_reg[ch].vmsr_max_rng == smu_ctrl_reg[ch].vmsr_min_rng) //
	pre_change = RANGE_DISABLE;
  else
	pre_change = RANGE_YET;
     
	range_changed = FALSE;

	if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
	{
		while (TRUE) 
		{
			if (pre_change == RANGE_DISABLE) break; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_vadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'I') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_vadc[ch] - adc_min.smu_vadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
			if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
			
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed = FALSE;
					pre_change = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed = TRUE;
					pre_change = RANGE_UP;
				}
			}
            
			else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_min_rng) 
				{
					range_changed = FALSE;
					pre_change = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed = TRUE;
					pre_change = RANGE_DOWN;
				}
			}
            
			else
			{
				range_changed = FALSE;
			}	
        
			if (range_changed == FALSE) break; // 레인지가 안 바뀐 경우 while문 탈출
        
			if (pre_change == RANGE_DOWN) smu_ctrl_reg[ch].vmsr_rng--;
			else smu_ctrl_reg[ch].vmsr_rng++;
				
			if (pre_change == RANGE_UP)
			{ // 전압 레인지를 올려야 하는 경우 
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}
				else
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}

				start_smu_dac(ch);
				Delay_ms(1);
				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
			}
			else
			{ // 전압 레인지를 내려야 하는 경우
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}
				else
				{
					vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].src_rng, smu_ctrl_reg[ch].src_val);
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
				}

				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
				Delay_ms(1);
				start_smu_dac(ch);
			}
	            
			Delay_ms(10);

			smu_adc_acquire_voltage(ch, meas_cnt);
		}
	}

}

// not used
void meas_acquire_voltage_all(int average_cnt)
{
	int ch;
    int i;
    float adc_mean_val, ptp, vdac_out_val;
    BOOL range_changed[NO_OF_SMU], is_limit, is_osc, flag;
    int pre_change[NO_OF_SMU];
    UINT32 delay = 0;
    // float range_up_volt, range_down_volt;
	UINT32 meas_cnt;

    // range_up_volt = RANGE_UP_VOLT;     // RANGE_UP_VOLT = 4.4
    // range_down_volt = RANGE_DOWN_VOLT; // RANGE_DOWN_VOLT = 0.4  
    
	meas_remove_limit_voltage_all();

	meas_cnt = get_average_count(average_cnt);

    smu_adc_acquire_voltage_all(meas_cnt);
	            
    for(ch=0; ch<NO_OF_SMU; ch++)
	{
		if(smu_ctrl_reg[ch].used)
		{
			if (smu_ctrl_reg[ch].mode == SMU_MODE_I)
			{
				if (smu_ctrl_reg[ch].vmsr_max_rng == smu_ctrl_reg[ch].vmsr_min_rng) //
					pre_change[ch] = RANGE_DISABLE;
				else
					pre_change[ch] = RANGE_YET;
			}
			else
			{
				pre_change[ch] = RANGE_DISABLE;
			}
		}
		else
		{
			pre_change[ch] = RANGE_DISABLE;
		}
	}
       
	while (TRUE) 
	{
		for(ch=0; ch<NO_OF_SMU; ch++)
			range_changed[ch] = FALSE;

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if (pre_change[ch] == RANGE_DISABLE) continue; 
																
			adc_mean_val = adcval_to_float(adc_mean.smu_vadc[ch]);
		
			if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;
            
			is_limit = FALSE;
			is_osc = FALSE;
            
			for (i=0; i<meas_cnt; i++) 
			{
				if (smu_states[ch][i] != 'I') is_limit = TRUE;  // compliance가 걸린 경우
			}
            
			ptp = adcval_to_float(adc_max.smu_vadc[ch] - adc_min.smu_vadc[ch]); 
			if (ptp < 0) ptp = -ptp;                            
			if (ptp > OSC_DETECT_PTP_VOLT) is_osc = TRUE;
                        
			if((adc_mean_val > smu_irng_up_volt[smu_ctrl_reg[ch].imsr_rng]) || is_limit) 
			{ // 레인지를 높여야 할 때
			// 10uA(100K x10) 이상 레인지는 oscillation detect를 하지 않는다.
			
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_max_rng) 
				{// 더이상 올릴 수 없을 때
					range_changed[ch] = FALSE;
					pre_change[ch] = RANGE_DISABLE;
				}
				else 
				{ // 레인지 업
					range_changed[ch] = TRUE;
					pre_change[ch] = RANGE_UP;
				}
			}
         	else if ((adc_mean_val < smu_irng_down_volt[smu_ctrl_reg[ch].imsr_rng]) && (pre_change[ch] != RANGE_UP)) 
			{ // 레인지를 낮춰야 할 때
				if (smu_ctrl_reg[ch].vmsr_rng == smu_ctrl_reg[ch].vmsr_min_rng) 
				{
					range_changed[ch] = FALSE;
					pre_change[ch] = RANGE_DISABLE; // 수정 (RANGE_DOWN을 RANGE_DISABLE로)
				}
				else 
				{
					range_changed[ch] = TRUE;
					pre_change[ch] = RANGE_DOWN;
				}
			}
            else
			{
				range_changed[ch] = FALSE;
			}
		}

		flag = FALSE;

        for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch]) // 레인지를 바꿔야하는 채널에 대해서
			{	
				flag = TRUE; // 
	
        		if (pre_change[ch] == RANGE_DOWN) smu_ctrl_reg[ch].vmsr_rng--;
				else smu_ctrl_reg[ch].vmsr_rng++;
				
				vdac_out_val = calculate_smu_vdac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
				if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
				if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
				dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
			}
		}

		if (flag == FALSE) break; // 레인지를 바꿔야 하는 채널이 하나도 없는 경우 while 루프를 빠져나간다

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if(range_changed[ch])
			{
				if (pre_change[ch] == RANGE_UP)
				{ // 전압 레인지를 올려야 하는 경우 
					start_smu_dac(ch);
					Delay_ms(1);
					write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
				}
				else
				{ // 전압 레인지를 내려야 하는 경우
					write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
					Delay_ms(1);
					start_smu_dac(ch);
				}
			}
		}
		Delay_ms(10);
		
		smu_adc_acquire_voltage_all(meas_cnt);
	}
}

/*****************************************************************************************
 GUI에서 설정한 average모드(short, medium, long)와 전류 레인지에 따라 Average횟수를 생성
     
	   전류 레인지에 따라 다른 Short(0), Medium(-1), Long(-2) 횟수가 적용된다 
******************************************************************************************/

UINT32 get_average_count(int count)
{
	int ch, i;
	UINT32 measure_count;
    UINT32 average_count[NO_OF_IRANGE]; 

	if(count <= 0)
	{ // SHORT or MEDIUM or LONG

		measure_count = 3;  //cjh

		switch(count)  
		{
		  case AVG_SHORT_MODE:
			  //measure_count = 4;  //cjh
			  for(i=0; i<NO_OF_IRANGE; i++)
				  average_count[i] = average_cnt_reg.average_short[i];
			  break;
		  case AVG_MEDIUM_MODE:
              //measure_count = 64; //cjh
			  for(i=0; i<NO_OF_IRANGE; i++)
				  average_count[i] = average_cnt_reg.average_medium[i];
              break;
		  case AVG_LONG_MODE:
              //measure_count= 64*16; //cjh
			  for(i=0; i<NO_OF_IRANGE; i++)
				  average_count[i]=average_cnt_reg.average_long[i];
			  break;

		    default:
			  for(i=0; i<NO_OF_IRANGE; i++)
				  average_count[i]=average_cnt_reg.average_short[i];
			  break;
      }
	
		for (ch=0; ch<NO_OF_SMU; ch++) 
		{ 
			if (smu_ctrl_reg[ch].used) 
			{
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					if(measure_count<average_count[smu_ctrl_reg[ch].src_rng])
						measure_count=average_count[smu_ctrl_reg[ch].src_rng];
				}
				else 
				{
					if(measure_count<average_count[smu_ctrl_reg[ch].imsr_rng])
						measure_count=average_count[smu_ctrl_reg[ch].imsr_rng];
				}
                //printf("# SMU%d = %d\r\n", ch+1, measure_count);
			}
		}
	}
    else // Average횟수를 직접 입력했을 때
		measure_count = count;

	return measure_count;
	
}

// not used
BOOL meas_remove_limit(int ch)
{
    char smu_state;
    float vdac_out_val, idac_out_val;
    BOOL vrange_changed, irange_changed, is_limit;
    UINT32 delay = 0;
    
    is_limit = FALSE;

    while (TRUE) 
	{
        vrange_changed = FALSE;
		irange_changed = FALSE;
		
		// SMU채널의 현재 상태를 얻는다
        smu_state = read_smu_state(ch);
        
		if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
		{ 
			if (smu_ctrl_reg[ch].vmsr_rng < smu_ctrl_reg[ch].vmsr_max_rng) 
			{ // 현재 전압측정 레인지가 최대 측정레인지가 아닌 경우
				if (smu_state =='V') 
				{    // SMU가 전압 컨트롤 모드로 동작할 때
					smu_ctrl_reg[ch].vmsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
					vdac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
					vrange_changed = TRUE;
				}
			}
		}
        else 
		{ // 전압모드 , COM모드일 때
			if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_max_rng) 
			{ // 현재 전류측정 레인지가 최대 측정레인지가 아닌 경우
				if (smu_state != 'V') 
				{    // SMU가 전압 컨트롤 모드가 아닐때 (전류 컨트롤 모드로 동작할 때)
					smu_ctrl_reg[ch].imsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
					idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
					dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
					irange_changed = TRUE;
				}
			}
		}
                
               
        delay = 0;

		if ( (vrange_changed == TRUE) || (irange_changed == TRUE) )
		{
			if (vrange_changed) 
			{  // 전류 측정 레인지를 높여야 하는 경우
				is_limit = TRUE;
				//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{
					start_smu_dac(ch);
					Delay_ms(1);
					write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
				}
			}	
            if (irange_changed) 
			{  // 전류 측정 레인지를 높여야 하는 경우
				is_limit = TRUE;
				//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            
				if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
				{
					change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng); 
                        
					if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
						delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
				}
				start_smu_dac(ch);
			}
		}
        else 
		{
            return is_limit;
        }

        Delay_ms(delay);
    }
}

// not used
BOOL meas_remove_limit_all(void)
{
	int ch;
    char smu_state[NO_OF_SMU];
    float vdac_out_val, idac_out_val;
    BOOL vrange_changed[NO_OF_SMU], irange_changed[NO_OF_SMU], is_limit, flag;
    UINT32 delay = 0;
	//UINT32 meas_cnt = 0;
	//float adc_mean_val = 0;
    
    is_limit = FALSE;

    while (TRUE) 
	{
		flag = FALSE;
		
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			vrange_changed[ch] = FALSE;
			irange_changed[ch] = FALSE;
		
			// SMU채널의 현재 상태를 얻는다
			smu_state[ch] = read_smu_state(ch);	

		}

        for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if (smu_ctrl_reg[ch].used == TRUE)
			{
				if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
				{ 
					if (smu_ctrl_reg[ch].vmsr_rng < smu_ctrl_reg[ch].vmsr_max_rng) 
					{ // 현재 전압측정 레인지가 최대 측정레인지가 아닌 경우
						if (smu_state[ch] == 'V') 
						{    // SMU가 전압 컨트롤 모드로 동작할 때
							smu_ctrl_reg[ch].vmsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
							vdac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
							if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
							if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
							dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
							vrange_changed[ch] = TRUE;
							flag = TRUE;
						}
					}
				}
				else 
				{ // 전압모드 , COM모드일 때
					if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_max_rng) 
					{ // 현재 전류측정 레인지가 최대 측정레인지가 아닌 경우
						if (smu_state[ch] != 'V') 
						{    // SMU가 전압 컨트롤 모드가 아닐때 (전류 컨트롤 모드로 동작할 때)
							smu_ctrl_reg[ch].imsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
							idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
							dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
							irange_changed[ch] = TRUE;
							flag = TRUE;
						}
					}
				}
			}
		}    
               
        delay = 0;

		if(flag)
		{
			for(ch=0; ch<NO_OF_SMU; ch++)
			{
				if ( (vrange_changed[ch] == TRUE) || (irange_changed[ch] == TRUE) )
				{
					if (vrange_changed[ch]) 
					{  // 전류 측정 레인지를 높여야 하는 경우
						is_limit = TRUE;
						//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            
						if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
						{
							start_smu_dac(ch);
							Delay_ms(1);
							write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
						}
					}	
					if (irange_changed[ch]) 
					{  // 전류 측정 레인지를 높여야 하는 경우
						is_limit = TRUE;
						//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            
						if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
						{
							change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng); 
                        
							if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
								delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
						}
						start_smu_dac(ch);
					}
				}
			}
		}
        else 
		{
            return is_limit;
        }

        Delay_ms(delay);
    }
}




// not used, under construction
BOOL meas_remove_limit_current(int ch)
{
    char smu_state;
    //float vdac_out_val, idac_out_val;
    float idac_out_val;
    BOOL range_changed, is_limit;
    UINT32 delay = 0;
    
    is_limit = FALSE;

    while (TRUE) 
	{
		range_changed = FALSE;
		
		// SMU채널의 현재 상태를 얻는다
        smu_state = read_smu_state(ch);
        
        if (smu_ctrl_reg[ch].mode != SMU_MODE_I) 
		{ // 전압모드 , COM모드일 때
			if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_max_rng) 
			{ // 현재 전류측정 레인지가 최대 측정레인지가 아닌 경우
				if (smu_state != 'V') 
				{    // SMU가 전압 컨트롤 모드가 아닐때 (전류 컨트롤 모드로 동작할 때)
					
                    //------------------- cjh 2010.10.21
                    //smu_ctrl_reg[ch].imsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
                    smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng; //최대레인지로 변경한다.
                    //--------------------
					
                    idac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
					dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
					range_changed = TRUE;
				}
			}
		}
                
               
        delay = 0;

        if (range_changed) 
		{  // 전류 측정 레인지를 높여야 하는 경우
            is_limit = TRUE;
            
			dac_val_reg.smu_idac_out_val[ch] = 0;
            start_smu_dac(ch);

			change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng); 
 
            // 아래수정 cjh 2010.10.06
            if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1])
				delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng-1];
            //if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			//	delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
            //
			                        	
			dac_val_reg.smu_idac_out_val[ch] = idac_out_val;
			start_smu_dac(ch);
		}	
        else 
		{
            return is_limit;
        }

		Delay_ms(delay);
    }
}


// not used
BOOL meas_remove_limit_current_all(void)
{
	int ch;
    char smu_state[NO_OF_SMU];
    float idac_out_val[NO_OF_SMU];
    BOOL range_changed[NO_OF_SMU], is_limit, flag;
    UINT32 delay = 0;
	UINT32 meas_cnt = 0;
	//float adc_mean_val = 0;
    int Imode_count = 0;
    
    is_limit = FALSE;

	
	while (TRUE) 
	{
		flag = FALSE;

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			range_changed[ch] = FALSE;
			// SMU채널의 현재 상태를 얻는다
			//smu_state[ch] = read_smu_state(ch); 
			
			smu_state[ch] = 'V';

			//check
			meas_cnt = 3;
			smu_adc_acquire_current(ch, meas_cnt);

           	//adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
            //if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

			//if (adc_mean_val > 4.9 )
            //{
            //    Imode_count++;
            //    smu_state[ch] = 'I';
            //}

            if( adc_mean.smu_iadc[ch] & 0x3FFFF == 0x3FFFF )
            {
                Imode_count++;
                smu_state[ch] = 'I';
            }
        }

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if ( (smu_ctrl_reg[ch].used == TRUE)&&(smu_ctrl_reg[ch].mode != SMU_MODE_I) ) 
			{ // 전압모드 , COM모드일 때
				if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_max_rng) 
				{ // 현재 전류측정 레인지가 최대 측정레인지가 아닌 경우
					if (smu_state[ch] != 'V') 
					{    // SMU가 전압 컨트롤 모드가 아닐때 (전류 컨트롤 모드로 동작할 때) 즉 compliance 걸린 상태
						//smu_ctrl_reg[ch].imsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
						smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng; //최대레인지로 변경한다.
						
						idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
						dac_val_reg.smu_idac_out_val[ch] = idac_out_val[ch];
						
						range_changed[ch] = TRUE;
						flag = TRUE;
					}
				}
			}
		}
		               
        delay = 0;

		if (flag) // 전류레인지를 변경해야 하는 SMU채널이 하나라도 있는 경우 
		{	// 1) 전류DAC 0V 출력
			// 2) 전류레인지 변경
			// 3) 전류DAC 출력 복원
			is_limit = TRUE;
			for(ch=0; ch<NO_OF_SMU; ch++)
			{
				if (range_changed[ch]) 
				{ 
					//dac_val_reg.smu_idac_out_val[ch] = 0;  // 주석처리 (20070122)
					//start_smu_dac(ch); // 주석처리 (20070122)
					
					change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng); 
				}
			}

//			Delay_ms(50); // for debug
			//Delay_ms(2);
 
			for(ch=0; ch<NO_OF_SMU; ch++)
			{
				if (range_changed[ch]) 
				{ 
					dac_val_reg.smu_idac_out_val[ch] = idac_out_val[ch];
					start_smu_dac(ch);

                    if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			         	delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
                		
					//Delay_ms(delay);
					//Delay_ms(200);
				}
			}
			 
			Delay_ms(delay);			
		}
			
        else 
		{
            return is_limit;
        }
    }
}

// not used
BOOL meas_remove_limit_current_all_orig(void)
{
	int ch;
    char smu_state[NO_OF_SMU];
    float idac_out_val[NO_OF_SMU];
    BOOL range_changed[NO_OF_SMU], is_limit, flag;
    UINT32 delay = 0;
	//UINT32 meas_cnt = 0;
	//float adc_mean_val = 0;
    
    is_limit = FALSE;

	
	while (TRUE) 
	{
		flag = FALSE;

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			range_changed[ch] = FALSE;
			// SMU채널의 현재 상태를 얻는다
			smu_state[ch] = read_smu_state(ch); 
			
			//smu_state[ch] = 'V';

			////test
			//meas_cnt = get_average_count(AVG_SHORT_MODE);
			//smu_adc_acquire_current(ch, meas_cnt);

			//adc_mean_val = adcval_to_float(adc_mean.smu_iadc[ch]);
			//if (adc_mean_val < 0) adc_mean_val = -adc_mean_val;

			//if (adc_mean_val > 4.4 ) smu_state[ch] = 'I';
			////test end

        }

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if ( (smu_ctrl_reg[ch].used == TRUE)&&(smu_ctrl_reg[ch].mode != SMU_MODE_I) ) 
			{ // 전압모드 , COM모드일 때
				if (smu_ctrl_reg[ch].imsr_rng < smu_ctrl_reg[ch].imsr_max_rng) 
				{ // 현재 전류측정 레인지가 최대 측정레인지가 아닌 경우
					if (smu_state[ch] != 'V') 
					{    // SMU가 전압 컨트롤 모드가 아닐때 (전류 컨트롤 모드로 동작할 때) 즉 compliance 걸린 상태
						//smu_ctrl_reg[ch].imsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
						smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].imsr_max_rng; //최대레인지로 변경한다.
						
						idac_out_val[ch] = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].imsr_rng, smu_ctrl_reg[ch].limit_val);
						dac_val_reg.smu_idac_out_val[ch] = idac_out_val[ch];
						
						range_changed[ch] = TRUE;
						flag = TRUE;
					}
				}
			}
		}
		               
        delay = 0;

		if (flag) // 전류레인지를 변경해야 하는 SMU채널이 하나라도 있는 경우 
		{	// 1) 전류DAC 0V 출력
			// 2) 전류레인지 변경
			// 3) 전류DAC 출력 복원
			is_limit = TRUE;
			for(ch=0; ch<NO_OF_SMU; ch++)
			{
				if (range_changed[ch]) 
				{ 
					//dac_val_reg.smu_idac_out_val[ch] = 0;  // 주석처리 (20070122)
					//start_smu_dac(ch); // 주석처리 (20070122)
					
					change_smu_imsr_range(ch, smu_ctrl_reg[ch].imsr_rng); 
				}
			}

//			Delay_ms(50); // for debug
			//Delay_ms(2);
 
			for(ch=0; ch<NO_OF_SMU; ch++)
			{
				if (range_changed[ch]) 
				{ 
					dac_val_reg.smu_idac_out_val[ch] = idac_out_val[ch];
					start_smu_dac(ch);

                    if (delay < delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng])
			         	delay = delay_reg.smu_imsr_change[smu_ctrl_reg[ch].imsr_rng];
                		
					//Delay_ms(delay);
					//Delay_ms(200);
				}
			}
			 
			Delay_ms(delay);			
		}
			
        else 
		{
            return is_limit;
        }
    }
}

BOOL meas_remove_limit_voltage_multi(int selectCnt, int *p_ch)
{
	int cnt;
	char smu_state[NO_OF_SMU];
    float vdac_out_val[NO_OF_SMU];
    BOOL range_changed[NO_OF_SMU], is_limit[NO_OF_SMU];
	BOOL range_changed_final;
	int flag[NO_OF_SMU], flagFinal;

	for(cnt = 0; cnt < NO_OF_SMU; cnt++)
	{
		is_limit[cnt] = FALSE;
		flag[cnt] = 0;
		range_changed[cnt] = FALSE;
	}

	while(true)
	{
 		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)
			{
				range_changed[p_ch[cnt]] = FALSE;

				// SMU채널의 현재 상태를 얻는다
				smu_state[p_ch[cnt]] = read_smu_state(p_ch[cnt]);

				if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
				{ 
					if (smu_ctrl_reg[p_ch[cnt]].vmsr_rng < smu_ctrl_reg[p_ch[cnt]].vmsr_max_rng) 
					{ // 현재 전압측정 레인지가 최대 측정레인지가 아닌 경우
						if (smu_state[p_ch[cnt]] == 'V') 
						{    // SMU가 전압 컨트롤 모드로 동작할 때
							smu_ctrl_reg[p_ch[cnt]].vmsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
							vdac_out_val[p_ch[cnt]] = calculate_smu_idac_out_val(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng, smu_ctrl_reg[p_ch[cnt]].limit_val);
							if(vdac_out_val[p_ch[cnt]] > 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
							if(smu_ctrl_reg[p_ch[cnt]].src_val < 0) vdac_out_val[p_ch[cnt]] = -vdac_out_val[p_ch[cnt]];
							dac_val_reg.smu_vdac_out_val[p_ch[cnt]] = vdac_out_val[p_ch[cnt]];
							range_changed[p_ch[cnt]] = TRUE;
						}
					}
				}
			}
		} //for(cnt = 0; cnt < selectCnt; cnt++)

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)
			{
				flag[p_ch[cnt]] = 0;
				if (range_changed[p_ch[cnt]]) 
				{  // 전류 측정 레인지를 높여야 하는 경우
					is_limit[p_ch[cnt]] = TRUE;
					//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
		            
					if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I) 
					{
						flag[p_ch[cnt]] = 1;
						start_smu_dac(p_ch[cnt]);
					}
				}
			}
		}

		range_changed_final = 0;
		flagFinal = 0;

		for(cnt = 0; cnt < selectCnt; cnt ++)
		{
			if (smu_ctrl_reg[p_ch[cnt]].mode == SMU_MODE_I)
			{
				range_changed_final |= range_changed[p_ch[cnt]];
			}
			flagFinal |= flag[p_ch[cnt]];
		}

		if(range_changed_final == 0)	break;

		if(flagFinal)
		{
			Delay_ms(1);

			for(cnt = 0; cnt < selectCnt; cnt++)
			{
				if(flag[p_ch[cnt]])
				{
					write_smu_vrange(p_ch[cnt], smu_ctrl_reg[p_ch[cnt]].vmsr_rng); //전압 레인지 설정
				}
			}
		}

		Delay_ms(10);
	}
}


// not used, under construction
BOOL meas_remove_limit_voltage(int ch)
{
    char smu_state;
    float vdac_out_val;
    BOOL range_changed, is_limit;
    
    is_limit = FALSE;

    while (TRUE) 
	{
        range_changed = FALSE;
		
		// SMU채널의 현재 상태를 얻는다
        smu_state = read_smu_state(ch);
        
        if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
		{ 
			if (smu_ctrl_reg[ch].vmsr_rng < smu_ctrl_reg[ch].vmsr_max_rng) 
			{ // 현재 전압측정 레인지가 최대 측정레인지가 아닌 경우
				if (smu_state == 'V') 
				{    // SMU가 전압 컨트롤 모드로 동작할 때
					smu_ctrl_reg[ch].vmsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
					vdac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
					if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
					if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
					dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
					range_changed = TRUE;
				}
			}
		}
                
        if (range_changed) 
		{  // 전류 측정 레인지를 높여야 하는 경우
            is_limit = TRUE;
            //meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            
			if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
			{
				start_smu_dac(ch);
				Delay_ms(1);
				write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
			}
		}	
        else 
		{
            return is_limit;
        }

        Delay_ms(10);
    }
}

// not used
BOOL meas_remove_limit_voltage_all(void)
{
	int ch;
    char smu_state[NO_OF_SMU];
    float vdac_out_val;
    BOOL range_changed[NO_OF_SMU], is_limit, flag;
    
    is_limit = FALSE;

    while (TRUE) 
	{
		flag = FALSE;

		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			range_changed[ch] = FALSE;
			// SMU채널의 현재 상태를 얻는다
			smu_state[ch] = read_smu_state(ch);
        }
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			if ( (smu_ctrl_reg[ch].used == TRUE) && (smu_ctrl_reg[ch].mode == SMU_MODE_I) )
			{ 
				if (smu_ctrl_reg[ch].vmsr_rng < smu_ctrl_reg[ch].vmsr_max_rng) 
				{ // 현재 전압측정 레인지가 최대 측정레인지가 아닌 경우
					if (smu_state[ch] == 'V') 
					{    // SMU가 전압 컨트롤 모드로 동작할 때
						smu_ctrl_reg[ch].vmsr_rng++; // 전류 측정 레인지를 한단계 증가시켜야 한다
						vdac_out_val = calculate_smu_idac_out_val(ch, smu_ctrl_reg[ch].vmsr_rng, smu_ctrl_reg[ch].limit_val);
						if(vdac_out_val > 0) vdac_out_val = -vdac_out_val;
						if(smu_ctrl_reg[ch].src_val < 0) vdac_out_val = -vdac_out_val;
						dac_val_reg.smu_vdac_out_val[ch] = vdac_out_val;
						range_changed[ch] = TRUE;
						flag = TRUE;
					}
				}
			}
		}

		if(flag)
		{
			is_limit = TRUE;
			for(ch=0; ch<NO_OF_SMU; ch++)           
			{
				if (range_changed[ch]) 
				{  // 전류 측정 레인지를 높여야 하는 경우
					is_limit = TRUE;
					//meas_start_dac(); // DA변환을 다시 한다. 수정(주석 처리)
            		if (smu_ctrl_reg[ch].mode == SMU_MODE_I) 
					{
						start_smu_dac(ch);
						Delay_ms(1);
						write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng); //전압 레인지 설정
					}
				}
			}
		}
        else 
		{
            return is_limit;
        }

        Delay_ms(10);
    }
}


#if 0
// not used,  under construction
void smu_adc_acquire(int ch, unsigned int meas_cnt)
{
  int i, j;
  INT32 vmax, vmin, imax, imin;
	int max_meas_cnt;

	OstInitTimer();

  max_meas_cnt = meas_cnt;
    
  // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
  for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();

		smu_adc_mux_v_sel(ch);
		Delay_us(100);
    smu_adc_voltage(ch);

		smu_adc_mux_i_sel(ch);
		Delay_us(100);
		smu_adc_current(ch);
		
		// SMU의 상태를 읽는다.
    smu_states[ch][i] = read_smu_state(ch);
    adc_buff[i].smu_vadc[ch] = smu_vadc_values[ch];
		adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];

		while(1041 > OstGet_TimerA());		// wait for 1041 us.
  }  	

  OstStop_TimerA();

	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
	adc_mean.smu_vadc[ch] = 0;
	adc_mean.smu_iadc[ch] = 0;
  smu_state[ch] = smu_states[ch][0];
    
	for (i=0; i<max_meas_cnt; i++) 
	{
		adc_mean.smu_vadc[ch] += adc_buff[i].smu_vadc[ch];
		adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
  }

  if (max_meas_cnt >= 3) 
	{
		vmax = adc_buff[0].smu_vadc[ch];
    vmin = adc_buff[0].smu_vadc[ch];
		imax = adc_buff[0].smu_iadc[ch];
    imin = adc_buff[0].smu_iadc[ch];
    for (i=1; i<max_meas_cnt; i++) 
		{
			if (adc_buff[i].smu_vadc[ch] > vmax) vmax = adc_buff[i].smu_vadc[ch];
        else if (adc_buff[i].smu_vadc[ch] < vmin) vmin = adc_buff[i].smu_vadc[ch];
			if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
        else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];
    }
		adc_mean.smu_vadc[ch] = ((double)(adc_mean.smu_vadc[ch] - vmax - vmin) / (double)(max_meas_cnt - 2)) + 0.55;
    adc_max.smu_vadc[ch] = vmax;
    adc_min.smu_vadc[ch] = vmin;
    adc_mean.smu_iadc[ch] = ((double)(adc_mean.smu_iadc[ch] - imax - imin) / (double)(max_meas_cnt - 2)) + 0.55;
    adc_max.smu_iadc[ch] = imax;
    adc_min.smu_iadc[ch] = imin;
  }
  else 
	{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
		adc_mean.smu_vadc[ch] = ((double)adc_mean.smu_vadc[ch] / (double)max_meas_cnt) + 0.55;
    adc_max.smu_vadc[ch] = adc_mean.smu_vadc[ch];
    adc_min.smu_vadc[ch] = adc_mean.smu_vadc[ch];
		adc_mean.smu_iadc[ch] = ((double)adc_mean.smu_iadc[ch] / (double)max_meas_cnt) + 0.55;
    adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
    adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
  }
}

// not used
void smu_adc_acquire_all(unsigned int meas_cnt)
{
	int ch;
    int i;
    INT32 vmax, vmin, imax, imin;
	int max_meas_cnt;

	OstInitTimer();

    max_meas_cnt = meas_cnt;
    
    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();

		smu_adc_mux_v_sel_all();
		Delay_us(100);
        smu_adc_voltage_all();

		smu_adc_mux_i_sel_all();
		Delay_us(100);
		smu_adc_current_all();
		
		// SMU의 상태를 읽는다.
		for (ch=0; ch<NO_OF_SMU; ch++)
		{
			smu_states[ch][i] = read_smu_state(ch);
			adc_buff[i].smu_vadc[ch] = smu_vadc_values[ch];
			adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];
		}

		while(1041 > OstGet_TimerA());		// wait for 1041 us.
    }  	

    OstStop_TimerA();

	for (ch=0; ch<NO_OF_SMU; ch++)
	{
	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
		adc_mean.smu_vadc[ch] = 0;
		adc_mean.smu_iadc[ch] = 0;
		smu_state[ch] = smu_states[ch][0];
    
		for (i=0; i<max_meas_cnt; i++) 
		{
			adc_mean.smu_vadc[ch] += adc_buff[i].smu_vadc[ch];
			adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
		}

		if (max_meas_cnt >= 3) 
		{
			vmax = adc_buff[0].smu_vadc[ch];
			vmin = adc_buff[0].smu_vadc[ch];
			imax = adc_buff[0].smu_iadc[ch];
			imin = adc_buff[0].smu_iadc[ch];
			for (i=1; i<max_meas_cnt; i++) 
			{
				if (adc_buff[i].smu_vadc[ch] > vmax) vmax = adc_buff[i].smu_vadc[ch];
				else if (adc_buff[i].smu_vadc[ch] < vmin) vmin = adc_buff[i].smu_vadc[ch];
				if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
				else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];
			}
			adc_mean.smu_vadc[ch] = (adc_mean.smu_vadc[ch] - vmax - vmin) / (max_meas_cnt - 2);
			adc_max.smu_vadc[ch] = vmax;
			adc_min.smu_vadc[ch] = vmin;
			adc_mean.smu_iadc[ch] = (adc_mean.smu_iadc[ch] - imax - imin) / (max_meas_cnt - 2);
			adc_max.smu_iadc[ch] = imax;
			adc_min.smu_iadc[ch] = imin;
		}
		else 
		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
			adc_mean.smu_vadc[ch] = adc_mean.smu_vadc[ch] / max_meas_cnt;
			adc_max.smu_vadc[ch] = adc_mean.smu_vadc[ch];
			adc_min.smu_vadc[ch] = adc_mean.smu_vadc[ch];
			adc_mean.smu_iadc[ch] = adc_mean.smu_iadc[ch] / max_meas_cnt;
			adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
			adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
		}
	}
}  

// not used
void smu_adc_acquire_current_jhcho_test(int ch, unsigned int meas_cnt)
{ 
    int i;
    INT32 imax, imin;
	int max_meas_cnt;
	UINT32 sampling_time = 16666 / (SAMPLES_PER_1PLC);
    UINT32 plc_time = 16666; 

	OstInitTimer();

	max_meas_cnt = meas_cnt;

    smu_adc_mux_i_sel(ch);
	Delay_us(100); //delay_us(100);
		

    //for test
    //sampling_time = 240;
    //max_meas_cnt = 69;
    //
    smu_adc_current(ch);
    smu_adc_current(ch);
    adc_mean.smu_iadc[ch] = 0;
    imax = smu_iadc_values[ch];
    imin = smu_iadc_values[ch];

    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
        OstStart_TimerA();
		smu_adc_current(ch);

		//Delay_us(200);
               
        // SMU의 상태를 읽는다.
        smu_states[ch][i] = read_smu_state(ch);
        adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];

     
		while((sampling_time) > OstGet_TimerA());		// wait for 260us -> 64-sampling/1PLC           
    }  	
    
    OstStop_TimerA();

	  adc_mean.smu_iadc[ch] = adc_mean.smu_iadc[ch];
    adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
    adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];	
}


#endif


// SMU SYNC. measure function
void smu_adc_acquire_current_multi(int selectCnt, int *p_ch, unsigned int meas_cnt)
{
	// 측정카운트는 최대값을 이용한다.
	int i, cnt;
	INT32 imax[NO_OF_SMU], imin[NO_OF_SMU];
	int max_meas_cnt;
	int sampling;
	int frequency;
	UINT32 sampling_time;
	UINT32 startCycTime;
	UINT32 delayCycle;
	s64 smu_iadc_mean_temp;

	if (frequency == 50 ) sampling = 20000;
    else sampling = 16666;						// frequency 60 and others
        
	sampling_time = sampling / SAMPLES_PER_1PLC;

	max_meas_cnt = meas_cnt;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_adc_mux_i_sel(p_ch[cnt]);
	}

	Delay_us(100);

	delayCycle = sampling_time * SYS_HCLK_FREQ;
	for(i = 0; i < max_meas_cnt; i++)
	{
		startCycTime = DWT_GetCyccnt();

		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			smu_adc_conv_start(p_ch[cnt]);
			smu_adc_current(p_ch[cnt]);

			smu_states[p_ch[cnt]][i] = read_smu_state(p_ch[cnt]);
			adc_buff[i].smu_iadc[p_ch[cnt]] = smu_iadc_values[p_ch[cnt]];
		}

		while((DWT_GetCyccnt() - startCycTime) < delayCycle);
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_state[p_ch[cnt]] = smu_states[p_ch[cnt]][0];
		smu_iadc_mean_temp = 0;

		for (i=0; i<max_meas_cnt; i++) 
		{
			// adc_mean.smu_iadc[p_ch[cnt]] += adc_buff[i].smu_iadc[p_ch[cnt]];
			smu_iadc_mean_temp += adc_buff[i].smu_iadc[p_ch[cnt]];
		}

		if (max_meas_cnt >= 3) 
		{
			imax[p_ch[cnt]] = adc_buff[0].smu_iadc[p_ch[cnt]];
			imin[p_ch[cnt]] = adc_buff[0].smu_iadc[p_ch[cnt]];
			for (i=1; i<max_meas_cnt; i++) 
			{
				if (adc_buff[i].smu_iadc[p_ch[cnt]] > imax[p_ch[cnt]])
					imax[p_ch[cnt]] = adc_buff[i].smu_iadc[p_ch[cnt]];
				else if (adc_buff[i].smu_iadc[p_ch[cnt]] < imin[p_ch[cnt]])
					imin[p_ch[cnt]] = adc_buff[i].smu_iadc[p_ch[cnt]];
			}
			// adc_mean.smu_iadc[p_ch[cnt]]	= (adc_mean.smu_iadc[p_ch[cnt]] - imax[p_ch[cnt]] - imin[p_ch[cnt]]) / (max_meas_cnt - 2);
			smu_iadc_mean_temp	= ((double)smu_iadc_mean_temp - imax[p_ch[cnt]] - imin[p_ch[cnt]]) / (double)(max_meas_cnt - 2);
			adc_mean.smu_iadc[p_ch[cnt]] = (INT32)smu_iadc_mean_temp;
			adc_max.smu_iadc[p_ch[cnt]]		= imax[p_ch[cnt]];
			adc_min.smu_iadc[p_ch[cnt]]		= imin[p_ch[cnt]];
		}
		else
		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
			// adc_mean.smu_iadc[p_ch[cnt]]	= adc_mean.smu_iadc[p_ch[cnt]] / max_meas_cnt;
			smu_iadc_mean_temp	= (double)smu_iadc_mean_temp / (double)max_meas_cnt;
			adc_mean.smu_iadc[p_ch[cnt]]	= (INT32)smu_iadc_mean_temp;
			adc_max.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
			adc_min.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
		}
	}
}


// SMU SYNC. measure function
void smu_adc_acquire_current_multi_check(int selectCnt, int *p_ch, unsigned int meas_cnt)
{
	// 측정카운트는 최대값을 이용한다.
	int i, cnt;
	INT32 imax[NO_OF_SMU], imin[NO_OF_SMU];
	int max_meas_cnt;
	s64 smu_iadc_mean_temp;

	max_meas_cnt = meas_cnt;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_adc_mux_i_sel(p_ch[cnt]);
	}

	Delay_us(100);

	for(i = 0; i < max_meas_cnt; i++)
	{
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			smu_adc_conv_start(p_ch[cnt]);
			smu_adc_current(p_ch[cnt]);

			smu_states[p_ch[cnt]][i] = read_smu_state(p_ch[cnt]);
			adc_buff[i].smu_iadc[p_ch[cnt]] = smu_iadc_values[p_ch[cnt]];
		}
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_state[p_ch[cnt]] = smu_states[p_ch[cnt]][0];
		smu_iadc_mean_temp = 0;

		for (i=0; i<max_meas_cnt; i++) 
		{
			// adc_mean.smu_iadc[p_ch[cnt]] += adc_buff[i].smu_iadc[p_ch[cnt]];
			smu_iadc_mean_temp += adc_buff[i].smu_iadc[p_ch[cnt]];
		}

		// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
		// adc_mean.smu_iadc[p_ch[cnt]]	= adc_mean.smu_iadc[p_ch[cnt]] / max_meas_cnt;
		smu_iadc_mean_temp	= (double)smu_iadc_mean_temp / (double)max_meas_cnt;
		adc_mean.smu_iadc[p_ch[cnt]]	= (INT32)smu_iadc_mean_temp;
		adc_max.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
		adc_min.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
	}
}


//// not used E5000 backup
//void smu_adc_acquire_current_multi(int selectCnt, int *p_ch, unsigned int meas_cnt)
//{
//	// 측정카운트는 최대값을 이용한다.
//	int i, cnt;
//	INT32 imax[NO_OF_SMU], imin[NO_OF_SMU];
//	int max_meas_cnt;
//	UINT32 sampling_time = 16666 / (SAMPLES_PER_1PLC) - 5; //sampling_time = 255.40625    16666/64 = 260.40625us
//    UINT32 plc_time = 16666;
//
//	OstInitTimer();
//
//	max_meas_cnt = meas_cnt;
//
//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		smu_adc_mux_i_sel(p_ch[cnt]);
//	}
//
//	Delay_us(100);
//
//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		smu_adc_current(p_ch[cnt]);
//		smu_adc_current(p_ch[cnt]);
//		adc_mean.smu_iadc[p_ch[cnt]] = 0;
//		imax[p_ch[cnt]] = smu_iadc_values[p_ch[cnt]];
//		imin[p_ch[cnt]] = smu_iadc_values[p_ch[cnt]];
//	}
//
//	for(i = 0; i < max_meas_cnt; i++)
//	{
//		OstStart_TimerA();
//
//		for(cnt = 0; cnt < selectCnt; cnt++)
//		{
//			smu_adc_conv_start(p_ch[cnt]);
//		}
//
//		while((sampling_time) > OstGet_TimerA());
//
//		for(cnt = 0; cnt < selectCnt; cnt++)
//		{
//			smu_iadc_values[p_ch[cnt]] = *(volatile int *)(smu_ctrl_reg[p_ch[cnt]].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
//			adc_buff[i].smu_iadc[p_ch[cnt]] = smu_iadc_values[p_ch[cnt]];
//		}
//	}
//
//	OstStop_TimerA();
//
//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		smu_state[p_ch[cnt]] = smu_states[p_ch[cnt]][0];
//
//		for (i=0; i<max_meas_cnt; i++) 
//		{
//			adc_mean.smu_iadc[p_ch[cnt]] += adc_buff[i].smu_iadc[p_ch[cnt]];
//		}
//
//		if (max_meas_cnt >= 3) 
//		{
//			imax[p_ch[cnt]] = adc_buff[0].smu_iadc[p_ch[cnt]];
//			imin[p_ch[cnt]] = adc_buff[0].smu_iadc[p_ch[cnt]];
//			for (i=1; i<max_meas_cnt; i++) 
//			{
//				if (adc_buff[i].smu_iadc[p_ch[cnt]] > imax[p_ch[cnt]])
//					imax[p_ch[cnt]] = adc_buff[i].smu_iadc[p_ch[cnt]];
//				else if (adc_buff[i].smu_iadc[p_ch[cnt]] < imin[p_ch[cnt]])
//					imin[p_ch[cnt]] = adc_buff[i].smu_iadc[p_ch[cnt]];
//			}
//			adc_mean.smu_iadc[p_ch[cnt]]	= (adc_mean.smu_iadc[p_ch[cnt]] - imax[p_ch[cnt]] - imin[p_ch[cnt]]) / (max_meas_cnt - 2);
//			adc_max.smu_iadc[p_ch[cnt]]		= imax[p_ch[cnt]];
//			adc_min.smu_iadc[p_ch[cnt]]		= imin[p_ch[cnt]];
//		}
//		else
//		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
//			adc_mean.smu_iadc[p_ch[cnt]]	= adc_mean.smu_iadc[p_ch[cnt]] / max_meas_cnt;
//			adc_max.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
//			adc_min.smu_iadc[p_ch[cnt]]		= adc_mean.smu_iadc[p_ch[cnt]];
//		}
//	}
//}

// SMU SYNC. measure function
void smu_adc_acquire_current(int ch, unsigned int meas_cnt)
{ 
	int i;
    INT32 imax, imin;
	int max_meas_cnt;
	int sampling;
	int frequency;
    UINT32 sampling_time;
	UINT32 startCycTime;
	UINT32 delayCycle;
	s64 smu_iadc_mean_temp = 0;

	frequency = smu_pwr_line_freq;

    if (frequency == 50 ) sampling = 20000;
    else sampling = 16666;						// frequency 60 and others
        
	sampling_time = sampling / SAMPLES_PER_1PLC;

	max_meas_cnt = meas_cnt;

    smu_adc_mux_i_sel(ch);
	Delay_us(100);

	delayCycle = sampling_time * SYS_HCLK_FREQ;
	for (i=0; i<max_meas_cnt; i++) 
	{ 
		startCycTime = DWT_GetCyccnt();

		smu_adc_conv_start(ch);
    	smu_adc_current(ch);

		adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];

		while((DWT_GetCyccnt() - startCycTime) < delayCycle);
	}

	// SMU의 상태를 읽는다.
    smu_states[ch][0] = read_smu_state(ch);
	smu_state[ch] = smu_states[ch][0];
	
	for (i=0; i<max_meas_cnt; i++) 
	{
		// adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
		smu_iadc_mean_temp += adc_buff[i].smu_iadc[ch];
	}

	if (max_meas_cnt >= 3) 
	{
		imax = adc_buff[0].smu_iadc[ch];
		imin = adc_buff[0].smu_iadc[ch];
		for (i=1; i<max_meas_cnt; i++) 
		{
			if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
			else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];
		}

		// adc_mean.smu_iadc[ch] = ((double)(adc_mean.smu_iadc[ch] - imax - imin) / (double)(max_meas_cnt - 2)) + 0.5555;
		smu_iadc_mean_temp = ((double)(smu_iadc_mean_temp - imax - imin) / (double)(max_meas_cnt - 2)) + 0.5555;
		adc_mean.smu_iadc[ch] = (INT32)smu_iadc_mean_temp;

		adc_max.smu_iadc[ch] = imax;
		adc_min.smu_iadc[ch] = imin;
	}
	else
	{	
		// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
		// adc_mean.smu_iadc[ch] = ((double)adc_mean.smu_iadc[ch] / (double)max_meas_cnt) + 0.5555;
		smu_iadc_mean_temp = ((double)smu_iadc_mean_temp / (double)max_meas_cnt) + 0.5555;
		adc_mean.smu_iadc[ch] = (INT32)smu_iadc_mean_temp;

		adc_max.smu_iadc[ch]  = adc_mean.smu_iadc[ch];
		adc_min.smu_iadc[ch]  = adc_mean.smu_iadc[ch];
	}
}

// SMU SYNC. measure function
// void smu_adc_acquire_current_check(int ch, unsigned int meas_cnt)
// { 
//     int i;
// 	int max_meas_cnt;
// 	float cnvs_time;
// 	INT32 smu_iadc_values_temp;

//     // UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;

// 	// max_meas_cnt = meas_cnt;
// 	// cnvs_time = meas_cnt * sampling_time;

//     smu_adc_mux_i_sel(ch);
// 	Delay_us(100);

// 	smu_iadc_values_temp = 0;

// 	for(i = 0; i< max_meas_cnt; i++)
// 	{
// 		smu_adc_conv_start(ch);
// 		smu_adc_current(ch);

// 		smu_iadc_values_temp += smu_iadc_values[ch];	
// 	}

// 	smu_iadc_values[ch] = smu_iadc_values_temp;


// 	// SMU의 상태를 읽는다.
//     smu_states[ch][0] = read_smu_state(ch);
// 	smu_state[ch] = smu_states[ch][0];

// 	// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
// 	adc_mean.smu_iadc[ch] = ((double)smu_iadc_values[ch] / (double)max_meas_cnt) + 0.5555;
// 	adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
// 	adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
	
// }

void smu_adc_acquire_current_check(int ch, unsigned int meas_cnt)
{ 
    int i;
	int max_meas_cnt;
	s64 smu_iadc_mean_temp = 0;

	max_meas_cnt = meas_cnt;

    smu_adc_mux_i_sel(ch);
	Delay_us(100);

	for(i = 0; i< max_meas_cnt; i++)
	{
		smu_adc_conv_start(ch);
		smu_adc_current(ch);

		smu_iadc_mean_temp += smu_iadc_values[ch];	
	}

	// SMU의 상태를 읽는다.
    smu_states[ch][0] = read_smu_state(ch);
	smu_state[ch] = smu_states[ch][0];

	// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
	// adc_mean.smu_iadc[ch] = ((double)smu_iadc_values[ch] / (double)max_meas_cnt) + 0.5555;
	smu_iadc_mean_temp = ((double)smu_iadc_mean_temp / (double)max_meas_cnt) + 0.5555;
	adc_mean.smu_iadc[ch] = (INT32)smu_iadc_mean_temp;
	
	adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
	adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
}





//E5000 backup
//void smu_adc_acquire_current(int ch, unsigned int meas_cnt)
//{ 
//    int i;
//    INT32 imax, imin;
//	int max_meas_cnt;
//    int frequency = 60;
//    int sampling = 16666;
//
//    //F5500
//    //if ((sta_info.ac_power_freq == 60) || (sta_info.ac_power_freq == 50))
//    if ((smu_pwr_line_freq == 60) || (smu_pwr_line_freq == 50))
//    {
//        //frequency = sta_info.ac_power_freq; 
//        frequency = smu_pwr_line_freq;
//    }
//    else
//    {
//        frequency = 60;
//    }
//
//    if (frequency == 50 )
//    {
//        sampling = 20000;
//    }
//    else if (frequency == 60 )
//    {
//        sampling = 16666;
//    }
//    else
//    {
//        return;
//    }
//
//	//dprint("#2016 adc_acquire_current1 : frequency=%d, sampling=%d\n", frequency, sampling);
//
//	//UINT32 sampling_time = 16666 / (SAMPLES_PER_1PLC) - 10;
//    UINT32 sampling_time = sampling / (SAMPLES_PER_1PLC) - 5; // sampling_time = 계산 : 260.40625 / 측정 : 257.738  16666/64 = 260.40625us
//
//    //UINT32 plc_time = 16666; 
//	OstInitTimer();
//
//	max_meas_cnt = meas_cnt;
//
//    smu_adc_mux_i_sel(ch);
//	Delay_us(100); //delay_us(100);
//
//    //for test
//    //sampling_time = 240;
//    //max_meas_cnt = 69;
//    //
//    smu_adc_current(ch);
//    //smu_adc_current(ch);
//    adc_mean.smu_iadc[ch] = 0;
//    imax = smu_iadc_values[ch];
//    imin = smu_iadc_values[ch];
//
//	//dprint("#2016 adc_acquire_current2 : imax=%d, imin=%d\n", imax, imin);
//
//    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
//    for (i=0; i<max_meas_cnt; i++) 
//	{ 
//        OstStart_TimerA();
//
//		//smu_adc_current(ch);
//
//		smu_adc_conv_start(ch);
//               
//		// SMU의 상태를 읽는다.
//
//		//sum
//		/* adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
//		 if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
//		 else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];*/
//		
//		//		while(1041 > OstGet_TimerA());		// wait for 1041us -> 16-sampling/1PLC
//		while((sampling_time) > OstGet_TimerA());		// wait for 260us -> 64-sampling/1PLC
//        //smu_states[ch][i] = read_smu_state(ch);      
//		smu_iadc_values[ch] = *(volatile int *)(smu_ctrl_reg[ch].base_addr + SMU_ADC_READ_ADDR) & 0x3FFFF;
//
//		//dprint("#2016 adc_acquire_current3 : smu_iadc_values=%d\n", smu_iadc_values[ch]);
//
//		adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];
//
//		//if( plc_time <= OstGet_TimerA() ) break;
//		//printf(">>>> OstGet_TimerA() : %d\n",OstGet_TimerA());
//	}  	
//    
//    OstStop_TimerA();
//
//	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
//	smu_state[ch] = smu_states[ch][0];
//
//	for (i=0; i<max_meas_cnt; i++) 
//	{
//		adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
//	}
//
//	if (max_meas_cnt >= 3) 
//	{
//		imax = adc_buff[0].smu_iadc[ch];
//		imin = adc_buff[0].smu_iadc[ch];
//		for (i=1; i<max_meas_cnt; i++) 
//		{
//			if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
//			else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];
//		}
//
//		adc_mean.smu_iadc[ch] = ((double)(adc_mean.smu_iadc[ch] - imax - imin) / (double)(max_meas_cnt - 2)) + 0.5555;
//		adc_max.smu_iadc[ch] = imax;
//		adc_min.smu_iadc[ch] = imin;
//	}
//	else
//	{	
//		// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
//		adc_mean.smu_iadc[ch] = ((double)adc_mean.smu_iadc[ch] / (double)max_meas_cnt) + 0.5555;
//		adc_max.smu_iadc[ch]  = adc_mean.smu_iadc[ch];
//		adc_min.smu_iadc[ch]  = adc_mean.smu_iadc[ch];
//	}
//
//	//dprint("#2016 adc_acquire_current6 : adc_mean.smu_iadc=%d, adc_max.smu_iadc=%d, adc_min.smu_iadc=%d\n", adc_mean.smu_iadc[ch], adc_max.smu_iadc[ch], adc_min.smu_iadc[ch]);
//    //dprint("#2016 adc_acquire_current << end \n");
//}


/*
// QSort 이용

int Test_Data_Sort( const void *a, const void *b)
{
  INT32 a1, b1;

  a1 =  *(INT32 *)a ;
  b1 =  *(INT32 *)b ;

  if(a1>b1) return 1;
  else if( a1<b1) return -1;
  else            return 0;
}


void smu_adc_acquire_current(int ch, unsigned int meas_cnt)
{
    int i;
    INT32 imax, imin, iavg;
	int max_meas_cnt, count;
	UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;
    
    INT32 tmp_buff[MAX_ADC_BUFF]; 


	OstInitTimer();

	max_meas_cnt = meas_cnt;
//	max_meas_cnt = 64;
    
	smu_adc_mux_i_sel(ch);
	Delay_us(100); //delay_us(100);

    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();

        smu_adc_current(ch);
		
		// SMU의 상태를 읽는다.
        smu_states[ch][i] = read_smu_state(ch);
        tmp_buff[i] = smu_iadc_values[ch];

//		while(1041 > OstGet_TimerA());		// wait for 1041us -> 16-sampling/1PLC
		while((sampling_time) > OstGet_TimerA());		// wait for 260us -> 64-sampling/1PLC
//		printf(">>>> OstGet_TimerA() : %d\n",OstGet_TimerA());

    }  	

    OstStop_TimerA();

	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
	adc_mean.smu_iadc[ch] = 0;
	smu_state[ch] = smu_states[ch][0];

    qsort( tmp_buff, max_meas_cnt, sizeof(INT32), Test_Data_Sort );  

    if( max_meas_cnt >= 16 )
    {
         adc_mean.smu_iadc[ch] = (tmp_buff[max_meas_cnt/3]+tmp_buff[max_meas_cnt*2/3])/2;
    }
    else
        adc_mean.smu_iadc[ch] = tmp_buff[max_meas_cnt/2];
    
    adc_max.smu_iadc[ch] = tmp_buff[max_meas_cnt];
    adc_min.smu_iadc[ch] = tmp_buff[1];
}
*/


/*

// Sort 이용
void smu_adc_acquire_current(int ch, unsigned int meas_cnt)
{
    int i, j;
    INT32 imax, imin, temp;
	int max_meas_cnt;
	UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;

	OstInitTimer();

    max_meas_cnt = meas_cnt;
//	max_meas_cnt = 3;
    
	smu_adc_mux_i_sel(ch);
	Delay_us(100); //delay_us(100);

    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();

        smu_adc_current(ch);
		
		// SMU의 상태를 읽는다.
        smu_states[ch][i] = read_smu_state(ch);
        adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];

//		while(1041 > OstGet_TimerA());		// wait for 1041us -> 16-sampling/1PLC
		while(sampling_time > OstGet_TimerA());		// wait for 260us -> 64-sampling/1PLC
//		printf(">>>> OstGet_TimerA() : %d\n",OstGet_TimerA());

    }  	

    OstStop_TimerA();

	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
	adc_mean.smu_iadc[ch] = 0;
    smu_state[ch] = smu_states[ch][0];
 
	
//	for (i=0; i<max_meas_cnt; i++) 
//	{
//		adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
 / /  }


//    if (max_meas_cnt >= 3) 
//	{
		for(i=1; i<max_meas_cnt; i++) 
		{
			for(j=i-1, temp=adc_buff[i].smu_iadc[ch]; j>=0 && adc_buff[j].smu_iadc[ch]>temp; j--)
      			adc_buff[j+1].smu_iadc[ch] = adc_buff[j].smu_iadc[ch];

			adc_buff[j+1].smu_iadc[ch] = temp;
		}
	
        adc_mean.smu_iadc[ch] = adc_buff[max_meas_cnt/2].smu_iadc[ch];
        adc_max.smu_iadc[ch] = adc_buff[max_meas_cnt].smu_iadc[ch];
        adc_min.smu_iadc[ch] = adc_buff[1].smu_iadc[ch];;
//    }
 //   else 
//	{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
//		adc_mean.smu_iadc[ch] = adc_mean.smu_iadc[ch] / max_meas_cnt;
  //      adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
  //      adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
  //  }
}
*/

// SMU SYNC. measure function
void smu_adc_acquire_voltage_multi(int selectCnt, int *p_ch, unsigned int meas_cnt)
{
	int i, cnt;
	INT32 vmax[NO_OF_SMU], vmin[NO_OF_SMU];
	int max_meas_cnt;
	int sampling;
	int frequency;
	UINT32 sampling_time;
	UINT32 startCycTime;
	UINT32 delayCycle;

	frequency = smu_pwr_line_freq;

    if (frequency == 50 ) sampling = 20000;
    else sampling = 16666;						// frequency 60 and others
        
	sampling_time = sampling / SAMPLES_PER_1PLC;

	max_meas_cnt = meas_cnt;

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		smu_adc_mux_v_sel(p_ch[cnt]);
	}

	Delay_us(100);

	delayCycle = sampling_time * SYS_HCLK_FREQ;
	for(i = 0; i < max_meas_cnt; i++)
	{
		startCycTime = DWT_GetCyccnt();
		for(cnt = 0; cnt < selectCnt; cnt++)
		{
			smu_adc_conv_start(p_ch[cnt]);
			smu_adc_voltage(p_ch[cnt]);

			smu_states[p_ch[cnt]][i] = read_smu_state(p_ch[cnt]);
			adc_buff[i].smu_vadc[p_ch[cnt]] = smu_vadc_values[p_ch[cnt]];
		}
		while((DWT_GetCyccnt() - startCycTime) < delayCycle);
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		adc_mean.smu_vadc[p_ch[cnt]] = 0;
		smu_state[p_ch[cnt]] = smu_states[p_ch[cnt]][0];

		for (i=0; i<max_meas_cnt; i++) 
		{
			adc_mean.smu_vadc[p_ch[cnt]] += adc_buff[i].smu_vadc[p_ch[cnt]];
		}

		if (max_meas_cnt >= 3) 
		{
			vmax[p_ch[cnt]] = adc_buff[0].smu_vadc[p_ch[cnt]];
			vmin[p_ch[cnt]] = adc_buff[0].smu_vadc[p_ch[cnt]];
			for (i=1; i<max_meas_cnt; i++) 
			{
				if (adc_buff[i].smu_vadc[p_ch[cnt]] > vmax[p_ch[cnt]])
					vmax[p_ch[cnt]] = adc_buff[i].smu_vadc[p_ch[cnt]];
				else if (adc_buff[i].smu_vadc[p_ch[cnt]] < vmin[p_ch[cnt]])
					vmin[p_ch[cnt]] = adc_buff[i].smu_vadc[p_ch[cnt]];
			}
			adc_mean.smu_vadc[p_ch[cnt]] = (adc_mean.smu_vadc[p_ch[cnt]] - vmax[p_ch[cnt]] - vmin[p_ch[cnt]]) / (max_meas_cnt - 2);
			adc_max.smu_vadc[p_ch[cnt]] = vmax[p_ch[cnt]];
			adc_min.smu_vadc[p_ch[cnt]] = vmin[p_ch[cnt]];
		}
		else 
		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
			adc_mean.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]] / max_meas_cnt;
			adc_max.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]];
			adc_min.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]];
		}
	}
}


//E5000 backup
//void smu_adc_acquire_voltage_multi(int selectCnt, int *p_ch, unsigned int meas_cnt)
//{
//	int i, cnt;
//	INT32 vmax[NO_OF_SMU], vmin[NO_OF_SMU];
//	int max_meas_cnt;
//	UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;
//
//	OstInitTimer();
//
//	max_meas_cnt = meas_cnt;
//
//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		smu_adc_mux_v_sel(p_ch[cnt]);
//	}
//
//	Delay_us(100);
//
//	for(i = 0; i < max_meas_cnt; i++)
//	{
//		OstStart_TimerA();
//
//		for(cnt = 0; cnt < selectCnt; cnt++)
//		{
//			smu_adc_voltage(p_ch[cnt]);
//
//			smu_states[p_ch[cnt]][i] = read_smu_state(p_ch[cnt]);
//			adc_buff[i].smu_vadc[p_ch[cnt]] = smu_vadc_values[p_ch[cnt]];
//		}
//
//		while(sampling_time > OstGet_TimerA());
//	}
//
//	OstStop_TimerA();
//
//	for(cnt = 0; cnt < selectCnt; cnt++)
//	{
//		adc_mean.smu_vadc[p_ch[cnt]] = 0;
//		smu_state[p_ch[cnt]] = smu_states[p_ch[cnt]][0];
//
//		for (i=0; i<max_meas_cnt; i++) 
//		{
//			adc_mean.smu_vadc[p_ch[cnt]] += adc_buff[i].smu_vadc[p_ch[cnt]];
//		}
//
//		if (max_meas_cnt >= 3) 
//		{
//			vmax[p_ch[cnt]] = adc_buff[0].smu_vadc[p_ch[cnt]];
//			vmin[p_ch[cnt]] = adc_buff[0].smu_vadc[p_ch[cnt]];
//			for (i=1; i<max_meas_cnt; i++) 
//			{
//				if (adc_buff[i].smu_vadc[p_ch[cnt]] > vmax[p_ch[cnt]])
//					vmax[p_ch[cnt]] = adc_buff[i].smu_vadc[p_ch[cnt]];
//				else if (adc_buff[i].smu_vadc[p_ch[cnt]] < vmin[p_ch[cnt]])
//					vmin[p_ch[cnt]] = adc_buff[i].smu_vadc[p_ch[cnt]];
//			}
//			adc_mean.smu_vadc[p_ch[cnt]] = (adc_mean.smu_vadc[p_ch[cnt]] - vmax[p_ch[cnt]] - vmin[p_ch[cnt]]) / (max_meas_cnt - 2);
//			adc_max.smu_vadc[p_ch[cnt]] = vmax[p_ch[cnt]];
//			adc_min.smu_vadc[p_ch[cnt]] = vmin[p_ch[cnt]];
//		}
//		else 
//		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
//			adc_mean.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]] / max_meas_cnt;
//			adc_max.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]];
//			adc_min.smu_vadc[p_ch[cnt]] = adc_mean.smu_vadc[p_ch[cnt]];
//		}
//	}
//}

// SMU SYNC. measure function
void smu_adc_acquire_voltage(int ch, unsigned int meas_cnt)
{
	int i;
	INT32 vmax, vmin;
	int max_meas_cnt;
	int sampling;
	int frequency;
	UINT32 sampling_time;
	UINT32 startCycTime;
	UINT32 delayCycle;
	s64 smu_vadc_mean_temp = 0;

	frequency = smu_pwr_line_freq;

    if (frequency == 50 ) sampling = 20000;
    else sampling = 16666;

	sampling_time = sampling / SAMPLES_PER_1PLC;

	max_meas_cnt = meas_cnt;
    
	smu_adc_mux_v_sel(ch);
	Delay_us(100);

	delayCycle = sampling_time * SYS_HCLK_FREQ;

	for (i=0; i<max_meas_cnt; i++) 
	{
		startCycTime = DWT_GetCyccnt();

		smu_adc_conv_start(ch);
    	smu_adc_voltage(ch);

		adc_buff[i].smu_vadc[ch] = smu_vadc_values[ch];

		while((DWT_GetCyccnt() - startCycTime) < delayCycle);
	}

	// SMU의 상태를 읽는다.
	smu_states[ch][0] = read_smu_state(ch);
	smu_state[ch] = smu_states[ch][0];

	for (i=0; i<max_meas_cnt; i++) 
	{
		// adc_mean.smu_vadc[ch] += adc_buff[i].smu_vadc[ch];
		smu_vadc_mean_temp += adc_buff[i].smu_vadc[ch];
	}

	if (max_meas_cnt >= 3) 
	{
		vmax = adc_buff[0].smu_vadc[ch];
		vmin = adc_buff[0].smu_vadc[ch];
		for (i=1; i<max_meas_cnt; i++) 
		{
			if (adc_buff[i].smu_vadc[ch] > vmax) vmax = adc_buff[i].smu_vadc[ch];
			else if (adc_buff[i].smu_vadc[ch] < vmin) vmin = adc_buff[i].smu_vadc[ch];
		}

		// adc_mean.smu_vadc[ch] = ((double)(adc_mean.smu_vadc[ch] - vmax - vmin) / (double)(max_meas_cnt - 2)) + 0.5555;
		smu_vadc_mean_temp = ((double)(smu_vadc_mean_temp - vmax - vmin) / (double)(max_meas_cnt - 2)) + 0.5555;
		adc_mean.smu_vadc[ch] = (INT32)smu_vadc_mean_temp;
		
		adc_max.smu_vadc[ch] = vmax;
		adc_min.smu_vadc[ch] = vmin;
	}
	else
	{	
		// max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
		adc_mean.smu_vadc[ch] = ((double)adc_mean.smu_vadc[ch] / (double)max_meas_cnt) + 0.5555;
		adc_max.smu_vadc[ch]  = adc_mean.smu_vadc[ch];
		adc_min.smu_vadc[ch]  = adc_mean.smu_vadc[ch];
	}
}

//E5000 back up
//void smu_adc_acquire_voltage(int ch, unsigned int meas_cnt)
//{
//  int i;
//  INT32 vmax, vmin;
//	int max_meas_cnt;
//	UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;
//
//
//	OstInitTimer();
//
//  max_meas_cnt = meas_cnt;
//    
//	smu_adc_mux_v_sel(ch);
//	Delay_us(100);
//	
//  // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
//  for (i=0; i<max_meas_cnt; i++) 
//	{ 
//		OstStart_TimerA();
//       
//    smu_adc_voltage(ch);
//		
//		// SMU의 상태를 읽는다.
//    smu_states[ch][i] = read_smu_state(ch);
//		adc_buff[i].smu_vadc[ch] = smu_vadc_values[ch];
//	
////    while(1041 > OstGet_TimerA());	// wait for 1041us -> 16-sampling/1PLC.   
////		while(260 > OstGet_TimerA());		// wait for 260us -> 64-sampling/1PLC
//		while(sampling_time > OstGet_TimerA());	
//  }  	
//
//
//  OstStop_TimerA();
//
//	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
//	adc_mean.smu_vadc[ch] = 0;
//    smu_state[ch] = smu_states[ch][0];
//    
//	for (i=0; i<max_meas_cnt; i++) 
//	{
//		adc_mean.smu_vadc[ch] += adc_buff[i].smu_vadc[ch];
//	}
//
//  if (max_meas_cnt >= 3) 
//  {
//		vmax = adc_buff[0].smu_vadc[ch];
//		vmin = adc_buff[0].smu_vadc[ch];
//		 for (i=1; i<max_meas_cnt; i++) 
//		 {
//			if (adc_buff[i].smu_vadc[ch] > vmax) vmax = adc_buff[i].smu_vadc[ch];
//			else if (adc_buff[i].smu_vadc[ch] < vmin) vmin = adc_buff[i].smu_vadc[ch];
//		 }
//			 adc_mean.smu_vadc[ch] = ((double)(adc_mean.smu_vadc[ch] - vmax - vmin) / (double)(max_meas_cnt - 2)) + 0.55;
//			 adc_max.smu_vadc[ch] = vmax;
//			 adc_min.smu_vadc[ch] = vmin;
//  }
//  else 
//  { // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
//	adc_mean.smu_vadc[ch] = ((double)adc_mean.smu_vadc[ch] / (double)max_meas_cnt) + 0.55;
//    adc_max.smu_vadc[ch] = adc_mean.smu_vadc[ch];
//    adc_min.smu_vadc[ch] = adc_mean.smu_vadc[ch];
//  }
// 
//}

#if 0
// not used
void gndu_adc_acquire(int mux_ch, unsigned int meas_cnt)
{
    int i;
    INT32 max, min;
	int max_meas_cnt;
	UINT32 sampling_time = 16666 / SAMPLES_PER_1PLC;

	OstInitTimer();

    max_meas_cnt = meas_cnt;
    
    if (mux_ch == GNDU_MUX_DIAG_ADCIN)
    	gndu_adc_mux_diag_sel();
    else if (mux_ch == GNDU_MUX_AGND)
    	gndu_adc_mux_agnd_sel();
    else if (mux_ch == GNDU_MUX_5V_REF)
    	gndu_adc_mux_5VREF_sel();
    else if (mux_ch == GNDU_MUX_GND_ADCIN)
    	gndu_adc_mux_gnd_adcin_sel();
    else 
    	gndu_adc_mux_gnd_adcin_sel();
    	
	Delay_us(100);
	
    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();
       
        get_gndu_adc_value();
		
		adc_buff[i].gndu_adc = gndu_adc_value;
	
		while(sampling_time > OstGet_TimerA());	
    }  	

    OstStop_TimerA();

	// 측정한 값의 평균값, 최대값, 최소값을 계산한다
	adc_mean.gndu_adc = 0;
       
	for (i=0; i<max_meas_cnt; i++) 
	{
		adc_mean.gndu_adc += adc_buff[i].gndu_adc;
    }

    if (max_meas_cnt >= 3) 
	{
		max = adc_buff[0].gndu_adc;
        min = adc_buff[0].gndu_adc;
        for (i=1; i<max_meas_cnt; i++) 
		{
			if (adc_buff[i].gndu_adc > max) max = adc_buff[i].gndu_adc;
            else if (adc_buff[i].gndu_adc < min) min = adc_buff[i].gndu_adc;
        }
        adc_mean.gndu_adc = (adc_mean.gndu_adc - max - min) / (max_meas_cnt - 2);
        adc_max.gndu_adc = max;
        adc_min.gndu_adc = min;
    }
    else 
	{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
		adc_mean.gndu_adc = adc_mean.gndu_adc / max_meas_cnt;
        adc_max.gndu_adc = adc_mean.gndu_adc;
        adc_min.gndu_adc = adc_mean.gndu_adc;
    }
}

// not used
void smu_adc_acquire_current_all(unsigned int meas_cnt)
{
	int ch;
    int i;
    INT32 imax, imin;
	int max_meas_cnt;

	OstInitTimer();

    max_meas_cnt = meas_cnt;
    
	smu_adc_mux_i_sel_all();
	Delay_us(100);

    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
//		printf("count : %d \n", i);

		OstStart_TimerA();

        smu_adc_current_all();
		
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			// SMU의 상태를 읽는다.
			smu_states[ch][i] = read_smu_state(ch);
			adc_buff[i].smu_iadc[ch] = smu_iadc_values[ch];
		}

		while(1041 > OstGet_TimerA());		// wait for 100 us.
//		printf(">>>> OstGet_TimerA() : %d\n",OstGet_TimerA());

    }  	

    OstStop_TimerA();

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		// 측정한 값의 평균값, 최대값, 최소값을 계산한다
		adc_mean.smu_iadc[ch] = 0;
		smu_state[ch] = smu_states[ch][0];
    
		for (i=0; i<max_meas_cnt; i++) 
		{
			adc_mean.smu_iadc[ch] += adc_buff[i].smu_iadc[ch];
		}

		if (max_meas_cnt >= 3) 
		{
			imax = adc_buff[0].smu_iadc[ch];
			imin = adc_buff[0].smu_iadc[ch];
			for (i=1; i<max_meas_cnt; i++) 
			{
				if (adc_buff[i].smu_iadc[ch] > imax) imax = adc_buff[i].smu_iadc[ch];
				else if (adc_buff[i].smu_iadc[ch] < imin) imin = adc_buff[i].smu_iadc[ch];
			}
			adc_mean.smu_iadc[ch] = (adc_mean.smu_iadc[ch] - imax - imin) / (max_meas_cnt - 2);
			adc_max.smu_iadc[ch] = imax;
			adc_min.smu_iadc[ch] = imin;
		}
		else 
		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
			adc_mean.smu_iadc[ch] = adc_mean.smu_iadc[ch] / max_meas_cnt;
			adc_max.smu_iadc[ch] = adc_mean.smu_iadc[ch];
			adc_min.smu_iadc[ch] = adc_mean.smu_iadc[ch];
		}
	}
}

// not used
void smu_adc_acquire_voltage_all(unsigned int meas_cnt)
{
	int ch;
    int i, j;
    INT32 vmax, vmin;
	int max_meas_cnt;

	OstInitTimer();

    max_meas_cnt = meas_cnt;
    
	smu_adc_mux_v_sel_all();
	Delay_us(100);
	
    // 설정해준 average횟수 만큼 AD변환을 해서 adc_buff[]에 저장
    for (i=0; i<max_meas_cnt; i++) 
	{ 
		OstStart_TimerA();
       
        smu_adc_voltage_all();
		
		for(ch=0; ch<NO_OF_SMU; ch++)
		{
			// SMU의 상태를 읽는다.
			smu_states[ch][i] = read_smu_state(ch);
			adc_buff[i].smu_vadc[ch] = smu_vadc_values[ch];
		}
	
        while(1041 > OstGet_TimerA());		// wait for 100 us.   
    }  	

    OstStop_TimerA();

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		// 측정한 값의 평균값, 최대값, 최소값을 계산한다
		adc_mean.smu_vadc[ch] = 0;
		smu_state[ch] = smu_states[ch][0];
    
		for (i=0; i<max_meas_cnt; i++) 
		{
			adc_mean.smu_vadc[ch] += adc_buff[i].smu_vadc[ch];
		}

		if (max_meas_cnt >= 3) 
		{
			vmax = adc_buff[0].smu_vadc[ch];
			vmin = adc_buff[0].smu_vadc[ch];
			for (i=1; i<max_meas_cnt; i++) 
			{
				if (adc_buff[i].smu_vadc[ch] > vmax) vmax = adc_buff[i].smu_vadc[ch];
				else if (adc_buff[i].smu_vadc[ch] < vmin) vmin = adc_buff[i].smu_vadc[ch];
			}
			adc_mean.smu_vadc[ch] = (adc_mean.smu_vadc[ch] - vmax - vmin) / (max_meas_cnt - 2);
			adc_max.smu_vadc[ch] = vmax;
			adc_min.smu_vadc[ch] = vmin;
		}
		else 
		{ // max_meas_cnt < 3 이면 max, min 값은 평균 값이 저장 된다.
			adc_mean.smu_vadc[ch] = adc_mean.smu_vadc[ch] / max_meas_cnt;
			adc_max.smu_vadc[ch] = adc_mean.smu_vadc[ch];
			adc_min.smu_vadc[ch] = adc_mean.smu_vadc[ch];
		}
	}
}

#endif

//not used, void start_calib(char* msr_val)
void start_calib(void)
{      
  int ch, i;
	int calib_cnt;
	float vm;
    
    
 //   MeasMode = MEAS_CALIB_MODE;
//    SetMeasState(MEAS_BUSY_STATE);
//    calib_state = CALIB_STATE_MEAS;
    
//    meas_init();
//    create_calib_var();
//    DispCalib();
	
  calib_cnt = 0;

	if (calib_meas_reg.ch < NO_OF_SMU) 
	{
        ch = calib_meas_reg.ch;
        
        smu_ctrl_reg[ch].used = TRUE;            
//		smu_ctrl_reg[ch].src_val = calib_meas_reg.start;
        smu_ctrl_reg[ch].src_rng = calib_meas_reg.src_rng;
                
    if (calib_meas_reg.smu_mode == SMU_MODE_I) 
		{
      smu_ctrl_reg[ch].mode = SMU_MODE_I;
      smu_ctrl_reg[ch].limit_val = 100;
			smu_ctrl_reg[ch].vmsr_rng = calib_meas_reg.msr_rng;
			smu_ctrl_reg[ch].vmsr_max_rng = calib_meas_reg.msr_rng;
			smu_ctrl_reg[ch].vmsr_min_rng = calib_meas_reg.msr_rng;
    }
    else 
		{
      smu_ctrl_reg[ch].mode = SMU_MODE_V;
      smu_ctrl_reg[ch].limit_val = 0.1;
			smu_ctrl_reg[ch].imsr_rng = calib_meas_reg.msr_rng;
			smu_ctrl_reg[ch].imsr_max_rng = calib_meas_reg.msr_rng;
			smu_ctrl_reg[ch].imsr_min_rng = calib_meas_reg.msr_rng;
    }     
  }
  else 
	{
       
  }


  if (calib_meas_reg.use_gndu) 
	{  // calibration을 위해 GNDU보드에 있는 저항사용시.
       
  }

  else 
	{ 
		
  }
	
	for (i=0; i<calib_meas_reg.no_step; i++)
	{
		smu_ctrl_reg[ch].src_val = calib_meas_reg.start + calib_meas_reg.step * i;
		
		if (calib_meas_reg.calib_mode == CALIB_MODE_I)
		{
			if (calib_meas_reg.smu_mode == SMU_MODE_V)
			{
				smu_source_voltage_start(ch);
				
				if (smu_ctrl_reg[ch].imsr_rng == SMU_1nA_RANGE)
				{
					if (i == 0)
						Delay_ms(5000);
					else
						Delay_ms(2000);
				}
				else if (smu_ctrl_reg[ch].imsr_rng == SMU_10nA_RANGE)
				{
					if (i == 0)
						Delay_ms(2000);
					else
						Delay_ms(1000);
				}
				else
				{
					if (i == 0)
						Delay_ms(500);
					else
						Delay_ms(200);
				}


			//	meas_measure_current(ch, AVG_LONG_MODE);
			//	meas_measure_voltage(ch, AVG_LONG_MODE);
				meas_measure(ch, AVG_LONG_MODE);
				
			//	sprintf(msr_val, "M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].imsr_val);
				TRACE("M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].vmsr_val, smu_ctrl_reg[ch].imsr_val);
				
				calib_cnt++;
			}

			else
			{
			//	smu_ctrl_reg[ch].imsr_rng = smu_ctrl_reg[ch].src_rng;
				smu_source_current_start(ch);
				
				if (smu_ctrl_reg[ch].src_rng == SMU_1nA_RANGE)
				{
					if (i == 0)
						Delay_ms(10000);
					else
						Delay_ms(5000);
				}
				else if (smu_ctrl_reg[ch].src_rng == SMU_10nA_RANGE)
				{
					if (i == 0)
						Delay_ms(5000);
					else
						Delay_ms(2000);
				}
				else
				{
					if (i == 0)
						Delay_ms(500);
					else
						Delay_ms(200);
				}

			//	meas_measure_current(ch, AVG_LONG_MODE);
			//	meas_measure_voltage(ch, AVG_LONG_MODE);
			
				meas_measure(ch, AVG_LONG_MODE);
				
			//	printf(msr_val, "M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].imsr_val, smu_ctrl_reg[ch].vmsr_val);
				TRACE("M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].imsr_val, smu_ctrl_reg[ch].vmsr_val);
				
			//	Sleep(100);
				calib_cnt++;
			}
		}

		if (calib_meas_reg.calib_mode == CALIB_MODE_V)
		{
			if (calib_meas_reg.smu_mode == SMU_MODE_V)
			{
				smu_source_voltage_start(ch);
				Delay_ms(1000);

			//	meas_measure_current(ch, AVG_LONG_MODE);
				meas_measure_voltage(ch, AVG_LONG_MODE);
				
				vm = 0;
			//	sprintf(msr_val, "M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].vmsr_val, vm);
				TRACE("M %d %E %E\r", calib_cnt, smu_ctrl_reg[ch].vmsr_val, vm);
			//	Sleep(500); // 키슬리 멀티미터가 값 올리는 시간 delay

				calib_cnt++;
			}
		}
	}
    //sbcho@20211108 HLSMU : Range 100V -> 40V
	smu_force_voltage(ch, 0, SMU_40V_RANGE, 0.1, SMU_100mA_RANGE);
}

void start_calib_leak(void)
{
  int i, ch;
  

  calib_leak_start  = 0.0;
  calib_leak_step   = 0.0;
  calib_leak_nostep = 2;
  //calib_cnt = 0;

  for (i=0; i<NO_OF_SMU; i++) 
	{
        smu_ctrl_reg[i].used = TRUE;
        smu_ctrl_reg[i].src_val = calib_leak_start;
        smu_ctrl_reg[i].src_rng = SMU_40V_RANGE; //s bcho@20211108 HLSMU : Range 100V -> 40V
        smu_ctrl_reg[i].mode = SMU_MODE_V;
        smu_ctrl_reg[i].limit_val = 0.1;
        
        smu_ctrl_reg[i].imsr_rng = SMU_10nA_RANGE; 
        smu_ctrl_reg[i].imsr_min_rng = SMU_10nA_RANGE;
        smu_ctrl_reg[i].imsr_max_rng = SMU_10nA_RANGE;
    }

	calib_leak_rng = SMU_10nA_RANGE;

	for (i=0; i<calib_leak_nostep; i++)
	{
		smu_source_voltage_start_all();

		Delay_ms(500);

		meas_measure_current_all(AVG_CNT_LONG);

		for (ch=0; ch<NO_OF_SMU; ch++) 
			calib_leak_val[ch][i] = adc_val_reg.smu_iadc_out_val[ch];
	}

	end_calib_leak();

  ///
	calib_leak_rng = SMU_1nA_RANGE;

	for (i=0; i<NO_OF_SMU; i++) 
	{
        smu_ctrl_reg[i].used = TRUE;
        smu_ctrl_reg[i].src_val = calib_leak_start;
        smu_ctrl_reg[i].src_rng = SMU_40V_RANGE; // sbcho@20211108 HLSMU : Range 100V -> 40V
        smu_ctrl_reg[i].mode = SMU_MODE_V;
        smu_ctrl_reg[i].limit_val = 0.1;
        
        smu_ctrl_reg[i].imsr_rng = SMU_1nA_RANGE; 
        smu_ctrl_reg[i].imsr_min_rng = SMU_1nA_RANGE;
        smu_ctrl_reg[i].imsr_max_rng = SMU_1nA_RANGE;
    }

	for (i=0; i<calib_leak_nostep; i++)
	{
		smu_source_voltage_start_all();

		Delay_ms(1000);

		meas_measure_current_all(AVG_CNT_LONG);

		for (ch=0; ch<NO_OF_SMU; ch++) 
			calib_leak_val[ch][i] = adc_val_reg.smu_iadc_out_val[ch];
	}

	end_calib_leak();
    
}

void start_calib_leak_one(int ch)
{
	int i;

    calib_leak_start  = 0.0;
    calib_leak_step   = 0.0;
    calib_leak_nostep = 2;
    //calib_cnt = 0;
    
    smu_ctrl_reg[ch].used = TRUE;
    smu_ctrl_reg[ch].src_val = calib_leak_start;
    smu_ctrl_reg[ch].src_rng = SMU_20V_RANGE;
    smu_ctrl_reg[ch].mode = SMU_MODE_V;
    smu_ctrl_reg[ch].limit_val = 0.1;
        
    smu_ctrl_reg[ch].imsr_rng = SMU_10nA_RANGE; 
    smu_ctrl_reg[ch].imsr_min_rng = SMU_10nA_RANGE;
    smu_ctrl_reg[ch].imsr_max_rng = SMU_10nA_RANGE;
    
	calib_leak_rng = SMU_10nA_RANGE;

	for (i=0; i<calib_leak_nostep; i++)
	{
		smu_source_voltage_start(ch);

		Delay_ms(1000);

		meas_measure_current(ch, AVG_CNT_LONG);

	 	calib_leak_val[ch][i] = adc_val_reg.smu_iadc_out_val[ch];
	}

	end_calib_leak_one(ch);

	calib_leak_rng = SMU_1nA_RANGE;

    smu_ctrl_reg[ch].used = TRUE;
    smu_ctrl_reg[ch].src_val = calib_leak_start;
    smu_ctrl_reg[ch].src_rng = SMU_20V_RANGE;
    smu_ctrl_reg[ch].mode = SMU_MODE_V;
    smu_ctrl_reg[ch].limit_val = 0.1;
        
    smu_ctrl_reg[ch].imsr_rng = SMU_1nA_RANGE; 
    smu_ctrl_reg[ch].imsr_min_rng = SMU_1nA_RANGE;
    smu_ctrl_reg[ch].imsr_max_rng = SMU_1nA_RANGE;
   
	for (i=0; i<calib_leak_nostep; i++)
	{
		smu_source_voltage_start(ch);

		Delay_ms(1000);

		meas_measure_current(ch, AVG_CNT_LONG);
		
		calib_leak_val[ch][i] = adc_val_reg.smu_iadc_out_val[ch];
	}

	end_calib_leak_one(ch);
    
}

void end_calib_leak(void)
{
  int i, k;
    
  if (calib_leak_rng == SMU_10nA_RANGE) 
	{
    for (i=0; i<NO_OF_SMU; i++) 
	  {
      calib_leak_offset[i][SMU_10nA_RANGE] = 0.0;
      for (k=0; k<calib_leak_nostep; k++) calib_leak_offset[i][SMU_10nA_RANGE] += calib_leak_val[i][k];
      calib_leak_offset[i][SMU_10nA_RANGE] = calib_leak_offset[i][SMU_10nA_RANGE]/calib_leak_nostep;
      if (calib_leak_step == 0) 
          calib_leak_gain[i][SMU_10nA_RANGE] = 0;
      else 
          calib_leak_gain[i][SMU_10nA_RANGE] = (calib_leak_val[i][calib_leak_nostep-1] - calib_leak_val[i][0])
                                             / (calib_leak_step*(calib_leak_nostep-1));
    }
    for (i=0; i<NO_OF_SMU; i++) 
		{
      // max leak gain :  20pA/10V 
      if (calib_leak_gain[i][SMU_10nA_RANGE] > 2.0E-3) calib_leak_gain[i][SMU_10nA_RANGE] = 2.0E-3;
      else if (calib_leak_gain[i][SMU_10nA_RANGE] < -2.0E-3) calib_leak_gain[i][SMU_10nA_RANGE] = -2.0E-3; 
    
      // max leak offset : <200pA 
      if (calib_leak_offset[i][SMU_10nA_RANGE] > 2.0E-1) calib_leak_offset[i][SMU_10nA_RANGE] = 2.0E-1;
      else if (calib_leak_offset[i][SMU_10nA_RANGE] < -2.0E-1) calib_leak_offset[i][SMU_10nA_RANGE] = -2.0E-1; 
    }
		TRACE("#   1G Auto Calibration......\r\n");
    
    for (i=0; i<NO_OF_SMU; i++) 
	  {
		  TRACE("# SMU%d: G[%E], O[%E]\r\n", i+1, calib_leak_gain[i][SMU_10nA_RANGE], calib_leak_offset[i][SMU_10nA_RANGE]);
      smu_imsr_leak_gain[i][SMU_10nA_RANGE] = calib_leak_gain[i][SMU_10nA_RANGE];
      smu_ipmsr_offset[i][SMU_10nA_RANGE] = calib_leak_offset[i][SMU_10nA_RANGE];
      smu_inmsr_offset[i][SMU_10nA_RANGE] = calib_leak_offset[i][SMU_10nA_RANGE];
    }        
  }

  else if (calib_leak_rng == SMU_1nA_RANGE) 
	{
    for (i=0; i<NO_OF_SMU; i++) 
	  {
      calib_leak_offset[i][SMU_1nA_RANGE] = 0.0;
      for (k=0; k<calib_leak_nostep; k++) calib_leak_offset[i][SMU_1nA_RANGE] += calib_leak_val[i][k];
      calib_leak_offset[i][SMU_1nA_RANGE] = calib_leak_offset[i][SMU_1nA_RANGE]/calib_leak_nostep;
      if (calib_leak_step == 0) 
          calib_leak_gain[i][SMU_1nA_RANGE] = 0;
      else
          calib_leak_gain[i][SMU_1nA_RANGE] = (calib_leak_val[i][calib_leak_nostep-1] - calib_leak_val[i][0]) 
                                            / (calib_leak_step*(calib_leak_nostep-1));
    }
    for (i=0; i<NO_OF_SMU; i++) 
	  {
      /* max leak gain :  20pA/10V */
      if (calib_leak_gain[i][SMU_1nA_RANGE] > 2.0E-2) calib_leak_gain[i][SMU_1nA_RANGE] = 2.0E-2;
      else if (calib_leak_gain[i][SMU_1nA_RANGE] < -2.0E-2) calib_leak_gain[i][SMU_1nA_RANGE] = -2.0E-2; 
    
      /* max leak offset : <200pA */
      if (calib_leak_offset[i][SMU_1nA_RANGE] > 2.0E0) calib_leak_offset[i][SMU_1nA_RANGE] = 2.0E0;
      else if (calib_leak_offset[i][SMU_1nA_RANGE] < -2.0E0) calib_leak_offset[i][SMU_1nA_RANGE] = -2.0E0;
    }
	  TRACE("#  10G Auto Calibration......\r\n");
    for (i=0; i<NO_OF_SMU; i++) 
		{
      TRACE("# SMU%d: G[%E], O[%E]\r\n", i+1, calib_leak_gain[i][SMU_1nA_RANGE], calib_leak_offset[i][SMU_1nA_RANGE]);
      smu_imsr_leak_gain[i][SMU_1nA_RANGE] = calib_leak_gain[i][SMU_1nA_RANGE];
      smu_ipmsr_offset[i][SMU_1nA_RANGE] = calib_leak_offset[i][SMU_1nA_RANGE];
      smu_inmsr_offset[i][SMU_1nA_RANGE] = calib_leak_offset[i][SMU_1nA_RANGE];
    }           
  }
}

// not used
void end_calib_leak_one(int ch)
{
  int k;
    
  if (calib_leak_rng == SMU_10nA_RANGE) 
	{
    calib_leak_offset[ch][SMU_10nA_RANGE] = 0.0;
    for (k=0; k<calib_leak_nostep; k++) calib_leak_offset[ch][SMU_10nA_RANGE] += calib_leak_val[ch][k];
    calib_leak_offset[ch][SMU_10nA_RANGE] = calib_leak_offset[ch][SMU_10nA_RANGE]/calib_leak_nostep;
    if (calib_leak_step == 0) 
	    calib_leak_gain[ch][SMU_10nA_RANGE] = 0;
    else 
			calib_leak_gain[ch][SMU_10nA_RANGE] = (calib_leak_val[ch][calib_leak_nostep-1] - calib_leak_val[ch][0])
                                             / (calib_leak_step*(calib_leak_nostep-1));

    // max leak gain :  20pA/10V 
    if (calib_leak_gain[ch][SMU_10nA_RANGE] > 2.0E-3) calib_leak_gain[ch][SMU_10nA_RANGE] = 2.0E-3;
    else if (calib_leak_gain[ch][SMU_10nA_RANGE] < -2.0E-3) calib_leak_gain[ch][SMU_10nA_RANGE] = -2.0E-3; 
    
    // max leak offset : <200pA 
    if (calib_leak_offset[ch][SMU_10nA_RANGE] > 2.0E-1) calib_leak_offset[ch][SMU_10nA_RANGE] = 2.0E-1;
    else if (calib_leak_offset[ch][SMU_10nA_RANGE] < -2.0E-1) calib_leak_offset[ch][SMU_10nA_RANGE] = -2.0E-1; 
    
//			PrintLine("#   1G Auto Calibration......\r\n");
       
//			PrintF("# SMU%d: G[%E], O[%E]\r\n", i+1, calib_leak_gain[i][SMU_10nA], calib_leak_offset[i][SMU_10nA]);
    smu_imsr_leak_gain[ch][SMU_10nA_RANGE] = calib_leak_gain[ch][SMU_10nA_RANGE];
    smu_ipmsr_offset[ch][SMU_10nA_RANGE] = calib_leak_offset[ch][SMU_10nA_RANGE];
    smu_inmsr_offset[ch][SMU_10nA_RANGE] = calib_leak_offset[ch][SMU_10nA_RANGE];  
	}
  else if (calib_leak_rng == SMU_1nA_RANGE) 
  {
       
    calib_leak_offset[ch][SMU_1nA_RANGE] = 0.0;
    for (k=0; k<calib_leak_nostep; k++) calib_leak_offset[ch][SMU_1nA_RANGE] += calib_leak_val[ch][k];
    calib_leak_offset[ch][SMU_1nA_RANGE] = calib_leak_offset[ch][SMU_1nA_RANGE]/calib_leak_nostep;
    if (calib_leak_step == 0) 
        calib_leak_gain[ch][SMU_1nA_RANGE] = 0;
    else
        calib_leak_gain[ch][SMU_1nA_RANGE] = (calib_leak_val[ch][calib_leak_nostep-1] - calib_leak_val[ch][0]) 
                                    / (calib_leak_step*(calib_leak_nostep-1));

    /* max leak gain :  20pA/10V */
    if (calib_leak_gain[ch][SMU_1nA_RANGE] > 2.0E-2) calib_leak_gain[ch][SMU_1nA_RANGE] = 2.0E-2;
    else if (calib_leak_gain[ch][SMU_1nA_RANGE] < -2.0E-2) calib_leak_gain[ch][SMU_1nA_RANGE] = -2.0E-2; 
    
    /* max leak offset : <200pA */
    if (calib_leak_offset[ch][SMU_1nA_RANGE] > 2.0E0) calib_leak_offset[ch][SMU_1nA_RANGE] = 2.0E0;
    else if (calib_leak_offset[ch][SMU_1nA_RANGE] < -2.0E0) calib_leak_offset[ch][SMU_1nA_RANGE] = -2.0E0;
    
		//PrintLine("#  10G Auto Calibration......\r\n");
        
    //PrintF("# SMU%d: G[%E], O[%E]\r\n", i+1, calib_leak_gain[i][SMU_1nA], calib_leak_offset[i][SMU_1nA]);
    smu_imsr_leak_gain[ch][SMU_1nA_RANGE] = calib_leak_gain[ch][SMU_1nA_RANGE];
    smu_ipmsr_offset[ch][SMU_1nA_RANGE] = calib_leak_offset[ch][SMU_1nA_RANGE];
//	smu_ipmsr_offset[i][SMU_1nA_RANGE] = 1;
    smu_inmsr_offset[ch][SMU_1nA_RANGE] = calib_leak_offset[ch][SMU_1nA_RANGE];
//	smu_inmsr_offset[i][SMU_1nA_RANGE] = 1;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// DAC 출력
//////////////////////////////////////////////////////////////////////////////////////////////////
// -10V 출력
// TP3(VDAC): adjust VR3
// TP4(IDAC): adjust VR5 
void smu_dac_offset_adjust(void)
{
	int ch;

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		write_smu_vdac(ch, MIN_DAC_IN_VALUE);
		write_smu_idac(ch, MIN_DAC_IN_VALUE);
	}
}

// +9.999695 출력
// TP3(VDAC): adjust VR2
// TP4(IDAC): adjust VR4 
void smu_dac_gain_adjust(void)
{
	int ch;

	for(ch=0; ch<NO_OF_SMU; ch++)
	{
		write_smu_vdac(ch, MAX_DAC_IN_VALUE);
		write_smu_idac(ch, MAX_DAC_IN_VALUE);
	}
}

// -10V 출력
// TP3(GND_DAC): adjust VR3
void gndu_dac_offset_adjust(void)
{
	write_gndu_dac(MIN_DAC_IN_VALUE);
}

// +9.999695 출력
// TP3(GND_DAC): adjust VR2
void gndu_dac_gain_adjust(void)
{
	write_gndu_dac(MAX_DAC_IN_VALUE);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Delay
//////////////////////////////////////////////////////////////////////////////////////////////////
void Delay_ms(UINT32 milisecond)
{
	//OstDelay_us(milisecond * 1000);
	HAL_Delay(milisecond);
}

void Delay_us(vu32 microsecond)
{
	DWT_Delay_us(microsecond);
}


//2015.12.22
int Delay_ms_poll(UINT32 milisecond)
{
	UINT32 k;
	UINT32 a = milisecond / 100;
	UINT32 b = milisecond % 100;

	//OstDelay_us(b * 1000);
	Delay_us(b * 1000);
	if (ReadSerial_stop() == -1) return -1;

	for (k=0; k<a; k++)
	{
		//OstDelay_us(100 * 1000);
		Delay_us(100 * 1000);
		if (ReadSerial_stop() == -1) return -1;
	}

	return 0;
}

#if 0
//////////////////////////////////////////////////////////////////////////////////////////////////
// VSVM TEST용
//////////////////////////////////////////////////////////////////////////////////////////////////
int Sweep_VSVM(int vsChannel, int vmChannel, double startV, double endV, double stepV, double stepTime)
{
	double currentV;
	int delayTime;
	double readVoltage;

	delayTime = (int)(stepTime * 1000);	// 초 단위로 받은거 ms로 변환

	delayTime -= 50;					// 출력 후 측정 딜레이 설정
	/*
	Sweep 순서도
	1. VSU의 출력전압을 0으로 만든다.
	2. VSU의 Output Relay를 동작시킨다.
	3. VMU를 활성화 시킨다.
	4. VSU에서 전압을 출력한다.
	5. VMU에서 전압을 읽어온다.
	6. 4번과 5번을 반복한다.
	*/
	m_Sta4Vsu[vsChannel].RelayControl(STA4VSVM_OUTPUT, OFF);		// VSU OUTPUT Relay 제거

	Delay_ms(10);

	m_Sta4Vsu[vsChannel].ForceVoltage_R20V(0);						// VSU 전압 0V

	Delay_ms(10);

	m_Sta4Vsu[vsChannel].RelayControl(STA4VSVM_OUTPUT, ON);			// VSU Output Relay  ON

	m_Sta4Vmu[vmChannel].RelayControl(STA4VSVM_VMU, ON);			//  VMU ON

	m_Sta4Vmu[vmChannel].RelayControl(STA4VSVM_INPUT, ON);			// VMU INPUT Relay ON

	Delay_ms(10);

	currentV = startV;												// 현재 값을 복사

	m_Sta4Vsu[vsChannel].ForceVoltage_R20V(currentV);				// 전압 출력

	Delay_ms(45);

	readVoltage = m_Sta4Vmu[vmChannel].MeasureVoltage_R20V();		// 전압 읽기

	printf("Vsu Output : %fV, Vmu Measure : %fV\r\n", currentV, readVoltage);

	if(startV < endV)			// 시작 전압이 끝 전압보다 작을 때, Step Up
	{
		do{
			Delay_ms(delayTime);

			currentV += stepV;

			m_Sta4Vsu[vsChannel].VoltageChange(currentV);
			
			Delay_ms(45);

			readVoltage = m_Sta4Vmu[vmChannel].MeasureVoltage_R20V();

			printf("Vsu Output : %fV, Vmu Measure : %fV\r\n", currentV, readVoltage);

		}while(currentV < endV);
	}
	else if(startV > endV)		// 시작 전압이 끝 전압보다 클 때, Step Down
	{
		do{
			Delay_ms(delayTime);

			currentV -= stepV;

			m_Sta4Vsu[vsChannel].VoltageChange(currentV);
			
			Delay_ms(45);

			readVoltage = m_Sta4Vmu[vmChannel].MeasureVoltage_R20V();

			printf("Vsu Output : %fV, Vmu Measure : %fV\r\n", currentV, readVoltage);

		}while(currentV > endV);
	}
	else						// 시작 전압과 끝 전압이 같을 때, 그 전압 그냥 출력시킴
	{
	}

	return 0;
}


#endif

