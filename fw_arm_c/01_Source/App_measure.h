#ifndef _APP_MEASURE_H
#define _APP_MEASURE_H

//#include "STA4_VSVM.h"
#include    "top_core_info.h"
#include 	"UserDefine.h"


#define MAX_ADC_BUFF   6400   //64 x 100 plc까지 가능 



//extern INT32  smu_vadc_values[NO_OF_SMU]; 
//extern INT32  smu_iadc_values[NO_OF_SMU];
//extern INT32  gndu_adc_value;



//extern TDacValues dac_val_reg; // 전역변수로 선언
//extern TSmuCtrlReg smu_ctrl_reg[NO_OF_SMU];

extern float flash_cal_buf[5000];


#ifdef __cplusplus
    extern "C" {
#endif

void smu_force_voltage_multi(int selectCnt, int *smu_ch, float *v_source, int *v_source_range, float *i_limit, int *i_limit_range);
void smu_force_voltage(int smu_ch, float v_source, int v_source_range, float i_limit, int i_measure_range);
void smu_force_current_multi(int selectCnt, int *smu_ch, float *i_source, int *i_source_range, float *v_limit, int *v_measure_range);
void smu_force_current(int smu_ch, float i_source, int i_source_range, float v_limit, int v_measure_range);
void smu_measure_voltage_multi(char *msr_val, int selectCnt, int *p_ch, int average_cnt, char rng_ctrl, int msr_rng);
void smu_measure_voltage_multi2(char *msr_val, int selectCnt, int *p_ch, int *average_cnt, char *rng_ctrl, int *msr_rng);
void smu_measure_voltage(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng);
void smu_measure_current_multi(char *msr_val, int selectCnt, int *p_ch, int average_cnt, char rng_ctrl, int msr_rng);
void smu_measure_current_multi2(char *msr_val, int selectCnt, int *p_ch, int *average_cnt, char *rng_ctrl, int *msr_rng);
void smu_measure_current(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng);
void smu_measure_current_DI(float *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng);

void smu_measure_current_ex2(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng);
void smu_measure_current_ex(char *msr_val, int ch, int average_cnt, char rng_ctrl, int msr_rng);	// 2012.02.15 ydh
void get_smu_measure_current_rawdata(char *msr_val, int ch, int start_idx, int num);	// 2012.02.28 ydh

void smu_source_start(int smu_ch);
void smu_source_voltage_start_multi(int selectCnt, int *p_ch);
void smu_source_voltage_start(int ch);
void smu_source_voltage_start_all(void);
void smu_source_current_start_multi(int selectCnt, int *p_ch);
void smu_source_current_start(int ch);


void meas_measure(int smu_ch, int average_cnt);
void meas_measure_all(int average_cnt);
void meas_measure_voltage_multi(int selectCnt, int *p_ch, int average_cnt);
void meas_measure_voltage(int ch, int average_cnt);
void meas_measure_voltage_all(int average_cnt);
void meas_measure_current_multi(int selectCnt, int *p_ch, int average_cnt);
void meas_measure_current(int ch, int average_cnt);
void meas_measure_current_all(int average_cnt);
UINT32 get_average_count(int count);

void meas_acquire(int ch, int average_cnt);
void meas_acquire_all(int average_cnt);
void meas_acquire_voltage_multi(int selectCnt, int *p_ch, int average_cnt);
void meas_acquire_voltage(int ch, int average_cnt);
void meas_acquire_voltage_all(int average_cnt);
void meas_acquire_current_multi(int selectCnt, int *p_ch, int average_cnt);
void meas_acquire_current(int ch, int average_cnt);
void meas_acquire_current_all(int average_cnt);

BOOL meas_remove_limit(int ch);
BOOL meas_remove_limit_all(void);
BOOL meas_remove_limit_voltage_multi(int selectCnt, int *p_ch);
BOOL meas_remove_limit_voltage(int ch);
BOOL meas_remove_limit_voltage_all(void); 
BOOL meas_remove_limit_current(int ch);
BOOL meas_remove_limit_current_all(void);

void smu_adc_acquire(int ch, unsigned int meas_cnt);
void gndu_adc_acquire(int mux_ch, unsigned int meas_cnt);
void smu_adc_acquire_all(unsigned int meas_cnt);
void smu_adc_acquire_voltage_multi(int selectCnt, int *p_ch, unsigned int meas_cnt);
void smu_adc_acquire_voltage(int ch, unsigned int meas_cnt);
void smu_adc_acquire_voltage_all(unsigned int meas_cnt);
void smu_adc_acquire_current_multi(int selectCnt, int *p_ch, unsigned int meas_cnt);
void smu_adc_acquire_current_multi_check(int selectCnt, int *p_ch, unsigned int meas_cnt);
void smu_adc_acquire_current(int ch, unsigned int meas_cnt);
void smu_adc_acquire_current_check(int ch, unsigned int meas_cnt);
void smu_adc_acquire_current_all(unsigned int meas_cnt);

void gndu_source_start(void);
float gndu_measure(int mux_ch, int avg_cnt);

//void start_calib(char* msr_val);
void start_calib(void);
void start_calib_leak(void);
void start_calib_leak_one(int ch);
void end_calib_leak(void);
void end_calib_leak_one(int ch);

void smu_dac_offset_adjust(void);
void smu_dac_gain_adjust(void);
void gndu_dac_offset_adjust(void);
void gndu_dac_gain_adjust(void);

void Delay_ms(UINT32 milisecond);
void Delay_us(vu32 microsecond);


//2015.12.22
int Delay_ms_poll(UINT32 milisecond);
int Sweep_VSVM(int vsChannel, int vmChannel, double startV, double endV, double stepV, double stepTime);


#ifdef __cplusplus
    }
#endif

#endif

