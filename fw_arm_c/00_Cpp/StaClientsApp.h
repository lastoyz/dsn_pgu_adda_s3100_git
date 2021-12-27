
#ifndef STACLIENTSAPP_H
#define STACLIENTSAPP_H

#define ABS(x)          ((x) < 0 ? -1*(x) : (x))
#define MAX(x, y)       ((x) > (y) ? (x) : (y))
#define MAX_ABS(x, y)   MAX(ABS(x), ABS(y))

// STA System Setup
/* ID code */
#define MODEL_EL420     420
#define MODEL_EL421     421
#define MODEL_F4500     421
#define MODEL_EL423     423

#define MAX_MODEL_NAME      11
#define MODEL_NAME_EL420    "EL420"        
#define MODEL_NAME_EL421    "EL421/EL422B"
#define MODEL_NAME_EL423    "EL424"

#define SMUID_EL423     1000  // 1fA(1nA,1pA) SMU 보드 
#define SMUID_EL425     2000  // 1A SMU 보드

/* FLASH READ/WRITE */
#define FLASH_BLANK_CHAR        0xFF

#define FLASH_BUFFER_BASE       0x10000
#define FLASH_BUFFER_SIZE       0x8000    // 32KB
#define FLASH_CPU_OFFSET        0x0000    // 1KB
#define FLASH_STA_OFFSET        0x0400   
#define FLASH_HPU_OFFSET        0x1000
#define FLASH_HPU_CALIB_OFFSET  0x0400
#define FLASH_HPU_SIZE          0x1000    // 4KB
   
#define FLASH_BASE_ADDR         0x08000000
#define FLASH_SECTOR_BASE       0x08020000

// 아래 VMU, VSU 채널의 수에 따른 구현은 아직 안됨... 
#define MAX_SMU_COUNT   4     // 최대로 장착 될 수 있는 SMU 보드 갯수.
#define MAX_VSU_COUNT   2
#define MAX_VMU_COUNT   2

/******* Range of Module(SMU, VM) *********/
#define SMU_200mV     0     // 현재까지(EL423) 사용 되지 않는 레인지
#define SMU_2V	      1
#define SMU_20V  	    2
#define SMU_100V	    3

// [100G]
#define SMU_10pA	    0      // EL423 version 은 100pA ~ 100mA 레인지 사용
#define SMU_100pA	    1      // 100G *1 레인지에서 10ohm *10 레인지 까지 쓴다
#define SMU_1nA	      2
#define SMU_10nA	    3
#define SMU_100nA     4
#define SMU_1uA	      5
#define SMU_10uA	    6
#define SMU_100uA     7
#define SMU_1mA	      8
#define SMU_10mA	    9
#define SMU_100mA     10
#define SMU_1A	      11

#define VMU_2V		    0
#define VMU_20V       1

#define VSU_2V        0
#define VSU_20V       1

#define SMU_CONST_0A_RANGE     SMU_100nA
//smu.h
//#define SMU_UPPER_LEAK_IRANGE  SMU_10nA

/* 프로그램상에서 사용 되는 최대 레인지 갯수*/
#define SMU_VRANGE_COUNT      (SMU_100V+1)
#define SMU_IRANGE_COUNT      (SMU_1A+1)
#define VSU_VRANGE_COUNT      (VSU_20V+1)
#define VMU_VRANGE_COUNT      (VMU_20V+1)

// Serial Cmd
#define CMD_MODE_SHELL      0  
#define CMD_MODE_OLD        1

#define MAX_PKT_LENGTH			4028
#define MAX_ARGS_CNT			500

// proc_ return error
#define SYS_ERR             -1
#define SYS_INVALID_CMD     -2
#define SYS_CMD_ERR         -3 
#define SYS_NO_ARGS         -4
#define SYS_INVALID_ARGS    -5
#define SYS_ARGS_ERR        -6 
#define SYS_BUSY_ERR        -7 
#define SYS_OK               0
#define SYS_NO_CMD           1

// Command Error
#define CMD_EXP_EL425           425

#define OLD_TARG_CNT            62 //57+4+1

#define OLD_SCH_CNT             35 //<sampling mode>
#define OLD_STM_CNT             6

#define OLD_NO_ERR              0
#define OLD_CMD_ERR             1
#define OLD_PARA_ERR            2
#define OLD_PARA_STR_ERR        3
#define OLD_MEAS_ERR            4
#define OLD_CALIB_ERR           5
#define OLD_CPU_ERR             6
#define OLD_ADDA_ERR            7
#define OLD_SMU1_ERR            8
#define OLD_SMU2_ERR            9
#define OLD_SMU3_ERR            10
#define OLD_SMU4_ERR            11
#define OLD_VSVM_ERR            12
#define OLD_SELTTEST_ERR        13

#define OLD_NO_CMD  	        0
#define OLD_IN2_CMD             1	/* load single point program			            */
#define OLD_MST_CMD		        2	/* Start Single mode measure			            */
#define OLD_IN1_CMD 		    3	/* load sweep mode program			                */
#define OLD_MS1_CMD	    	    4	/* Start sweep mode measurement once		        */
#define OLD_MS2_CMD		        5	/* Start sweep mode measurement with 16 average	    */
#define OLD_MS3_CMD		        6	/* Start sweep mode measurement with 256 average    */
#define OLD_MR1_CMD             7	/* Start sweep in repeat mode with 		            */
#define OLD_MR2_CMD             8	/* Start sweep in repeat mode with 16 average	    */
#define OLD_MR3_CMD		        9	/* Start sweep in repeat mode with 256 average	    */
#define OLD_MA1_CMD		        10	/* Start sweep in append mode with 		            */
#define OLD_MA2_CMD		        11	/* Start sweep in append mode with 16 average	    */
#define OLD_MA3_CMD		        12  /* Start sweep in append mode with 256 average	    */                                 
#define OLD_MS_CMD		        13  /* Stop Measurement                                 */
#define OLD_TEST_CMD		    14	/* AD DA loop-back test				                */
#define OLD_O1_CMD		        15	/* Load sweep parameter using parameter #	        */
#define OLD_O2_CMD		        16	/* Load single bias parameter using parameter #	    */
#define OLD_CAL1_CMD		    17	/* Get calibration coefficients			            */
#define OLD_CAL0_CMD		    18	/* Diable auto-calibration			                */
#define OLD_INIT_CMD		    19	/* Initialize STA test subsystem		            */
#define OLD_VCAL_CMD	        20	/* 전압 Initial calibration parameter 측정 명령     */
#define OLD_ICAL_CMD	        21	/* 전압 Initial calibration parameter 측정 명령     */
#define OLD_DGTLIO_CMD          22  /* Digital I/O port control command [DGTLIO]        */
#define OLD_TCAL_CMD            23  /* Write initial parameter to eeprom [FPGA]         */
#define OLD_FLOADA_CMD          24  /* Load station A setting and write fpga register to eeprom [FPGA] */
#define OLD_FLOADB_CMD          25  /* Load station B setting and write fpga register to eeprom [FPGA] */
#define OLD_TEND_CMD            26  /* Output test end signal [FPGA] */
#define OLD_MSN_CMD	    	    27	/* Start sweep mode measurement once		        */
#define OLD_MRN_CMD		        28	/* Start sweep mode measurement with 16 average	    */
#define OLD_MAN_CMD		        29	/* Start sweep mode measurement with 256 average    */
#define OLD_INIT0_CMD		    30	/* Initialize system & upload confiuration          */		            */
#define OLD_MEASVMETER_CMD      31  /* measure test v-meter */
#define OLD_WRSMUTR_CMD         32  /* write SMU test relay control */
#define OLD_WRVSMTR_CMD         33  /* write VSM test relay (VS, VM) control */
#define OLD_WRTESTCTRL_CMD      34  /* write VSM test relay (Resister, V-meter) control */

// Measure Mode Status
#define MEAS_IDLE_MODE      0
#define MEAS_SWEEP_MODE     1
#define MEAS_SINGLE_MODE    2
#define MEAS_CALIB_MODE     3
#define MEAS_SELF_MODE      4
#define MEAS_SAMPLING_MODE  5  //<sampling mode>

#define SM_NONE    -1
#define SM_SMU1I    0
#define SM_SMU1V    1
#define SM_SMU2I    2
#define SM_SMU2V    3
#define SM_SMU3I    4
#define SM_SMU3V    5
#define SM_SMU4I    6
#define SM_SMU4V    7
#define SM_VSU1     8
#define SM_VSU2     9
#define SM_VMU1     10
#define SM_VMU2     11
#define SM_VSVM1    8
#define SM_VSVM2    9

#define CH_NONE    -1
#define CH_SMU1     0
#define CH_SMU2     1
#define CH_SMU3     2
#define CH_SMU4     3
#define CH_SMU5     4
#define CH_SMU6     5
//#define CH_SMU7     6
//#define CH_SMU8     7
#define CH_GNDU		8

#define CH_VSU1     100
#define CH_VSU2     101
#define CH_VMU1     200
#define CH_VMU2     201

#define MODE_V         'V'
#define MODE_I         'I'
#define MODE_COM       'C'

#define FUNC_CONST     'C'
#define FUNC_VARA      'A'
#define FUNC_VARB      'B'
#define FUNC_VARA1     '1'

//<sampling mode>
#define MEASURE_V      'V'
#define MEASURE_I      'I'
#define MEASURE_BOTH   'B'

#define MODE_LINEAR    'L'
#define MODE_LOG10     '1'
#define MODE_LOG25     '2'
#define MODE_LOG50     '3'
#define MODE_RLOG10    '4'
#define MODE_RLOG25    '5'
#define MODE_RLOG50    '6'
#define MODE_DOUBLE    '7'

#define RANGE_AUTO     'A'
#define RANGE_FIXED    'F'
#define RANGE_LIMITED  'L'
#define RANGE_CURRENT  'C'

//smu.h
//#define AVG_SHORT_MODE       0   // byhong 
//#define AVG_MEDIUM_MODE     -1    
//#define AVG_LONG_MODE       -2  

//#define AVG_CNT_SHORT   3//3
//#define AVG_CNT_MEDIUM  32//8
//#define AVG_CNT_LONG    512//128

#define MAX_DATA_COUNT      2048
#define MAX_SAMPLING_TIME   2000000 //단위 50us
#define MAX_SAMPLING_CNT    4096

/**********************************************************************
 MeasState
 D31: MEAS_BUSY_STATE
 D30: MEAS_REPEAT_STATE
 **********************************************************************/
#define MEAS_DEFAULT_STATE  0x0000
#define MEAS_BUSY_STATE     0x8000
#define MEAS_REPEAT_STATE   0x0800

// Measure.h
//*** #define MAX_ADC_BUFF   1024
//#define MAX_SAMPLING_CNT 10000

#define SMU_100K_DELAY 1
#define SMU_10M_DELAY  3

//* #define SMU_MODE_V     'V'
//* #define SMU_MODE_I     'I'
//* #define SMU_MODE_COM   'C'

#define SMU_STATE_V    'V'
#define SMU_STATE_I    'I'

#define SMU_VMAX        100.0
#define SMU_IMAX          0.1

#define RANGE_YET           0
#define RANGE_DISABLE       1
#define RANGE_UP            2
#define RANGE_DOWN          3
#define RANGE_DOWN_2STEP	4

//* #define RANGE_UP_VOLT           9.8
//* #define RANGE_DOWN_VOLT         0.8 
#define RANGE_100G_UP_VOLT      9.8
#define RANGE_100G_DOWN_VOLT    0.8 

#define OSC_DETECT_PTP_VOLT     0.5 
#define OSC_DETECT_MAX_VOLT     0.9 // OSC_DETECT_UNDER_VOLT > RANGE_DOWN_VOLT

// SelfTest
/**********************************************************************
 Self Test Return Code
 
 Board Error
 D31: CPU_ERR
 D27: VSM_ERR
 D23: SMU1_ERR
 D22: SMU2_ERR
 D21: SMU3_ERR
 D20: SMU4_ERR
 **********************************************************************/
#define CPU_ERR     0x80000000
#define VSM_ERR     0x08000000
#define SMU1_ERR    0x00800000
#define SMU2_ERR    0x00400000
#define SMU3_ERR    0x00200000
#define SMU4_ERR    0x00100000
#define SMU5_ERR    0x00080000
#define SMU6_ERR    0x00040000
#define SMU7_ERR    0x00020000
#define SMU8_ERR    0x00010000

// UI Register Structure
typedef struct {
    UINT32 ReadyTime;
	UINT32 StartTime;
	//UINT32 SamplingTime;
    UINT32 InitInterval;
	UINT32 Interval;
	UINT32 MinInterval;
    UINT8  Mode;
	UINT32 NoSamples;
} UISamplingReg;

typedef struct {
    BOOL   Used;
    float  Source;
    float  Limit;
    UINT8  Mode;
    UINT8  Func;
    UINT8  RangeCtrl;
    UINT16 Range;
    BOOL   Measured;

	BOOL PulseMode;

	float Ready; //<sampling mode>
	UINT8 Measure;
} UISmuReg;

typedef struct {
    BOOL   Used;
    float  Source;
    UINT8  Func;

    BOOL PulseMode;

	float Ready; //<sampling mode>
} UIVsuReg;

typedef struct {
    BOOL   Used;
    UINT8  RangeCtrl;
    UINT16 Range;
} UIVmuReg;

typedef struct {
    UINT8  Mode;
    float  Start;
    float  Step;
    UINT32 NoStep;
} UIVarAReg;

typedef struct {
	UINT8 Mode;
    float  Start;
    float  Step;
    UINT32 NoStep;
} UIVarBReg;

typedef struct {
    float  Ratio;
    float  Offset;
} UIVarA1Reg;

typedef struct {
    int PulseCh;
	float Base;
    unsigned long Width;
    unsigned long Period;
} UIPulseReg;

typedef struct {
    UINT32 Hold;
    UINT32 Delay;
    UINT32 RangeDelay[4]; 
} UIMeasTimeReg;

typedef struct {
    float *SmuSrc[MAX_SMU_COUNT];
    float *SmuMsr[MAX_SMU_COUNT];
    UINT8 *SmuState[MAX_SMU_COUNT];
    float *Vsu[MAX_VSU_COUNT];
    float *Vmu[MAX_VMU_COUNT];
    UINT32 Count;
} UIDataReg;

// 
//typedef struct {
//    //-------------------------------------------------------------------
//    // installed이 FALSE이면 셀프테스트, 실행 중 켈리브레이션에서 사용됨 
//    // used: 측정시 사용됨
//    BOOL installed;
//    // 실제 사용되는 최대/최소 레인지.
//    int min_vrange;
//    int max_vrange;
//    int min_isrc_range;
//    int max_isrc_range;
//    int min_imsr_range;
//    int max_imsr_range;
//    //-------------------------------------------------------------------
//
//
//    BOOL used; // 주의! installed=FALSE 라도 uesd=TRUE 이면 측정된다. 
//    char mode;
//    
//    
//	BOOL pulsemode;
//	float base;
//	unsigned long width;
//    unsigned long period;
//    
//   
//    float source;
//	float ready; //<sampling mode>
//    short src_rng;
//    
//    float limit;
//    short msr_rng;
//    short msr_max_rng;
//    short msr_min_rng;
//    
//    char state;
//    float msr_val;
//    float src_val;
//
//	// [ele-v3.7.2]
//    BOOL sweep_measured;
//
//	float imsr_val;
//	float vmsr_val;
//
//	int imsr_rng;
//	int vmsr_rng;
//	short vmsr_max_rng;
//    short vmsr_min_rng;
//	short imsr_max_rng;
//    short imsr_min_rng;
//
//} UISmuCtrlReg;
//
//typedef struct {
//    //-------------------------------------------------------------------
//    // installed이 FALSE이면 셀프테스트, 실행 중 켈리브레이션에서 사용됨 
//    // used: 측정시 사용됨
//    BOOL installed;
//    // 실제 사용되는 최대/최소 레인지.
//    int min_range;
//    int max_range;
//    //-------------------------------------------------------------------
//
//
//    BOOL used; // 주의! installed=FALSE 라도 uesd=TRUE 이면 측정된다. 
//    float source;
//    float ready; //<sampling mode>
//
//	BOOL pulsemode;
//	float base;
//	unsigned long width;
//    unsigned long period;
//  
//} UIVsuCtrlReg;
//
//typedef struct {
//    //-------------------------------------------------------------------
//    // installed이 FALSE이면 셀프테스트, 실행 중 켈리브레이션에서 사용됨 
//    // used: 측정시 사용됨
//    BOOL installed;
//    // 실제 사용되는 최대/최소 레인지.
//    int min_range;
//    int max_range;
//    //-------------------------------------------------------------------
//
//
//    BOOL used; // 주의! installed=FALSE 라도 uesd=TRUE 이면 측정된다.        
//    short msr_rng;
//    short msr_max_rng;
//    short msr_min_rng;
//    float msr_val;
//} UIVmuCtrlReg;

typedef struct {
    UINT32 smu_imsr_change[SMU_IRANGE_COUNT];
    UINT32 smu_isrc_change[SMU_IRANGE_COUNT];

    UINT32 smu_imsr_range[SMU_IRANGE_COUNT];
    UINT32 smu_isrc_range[SMU_IRANGE_COUNT];
} UIDelayCtrlReg;

typedef struct { // byhong
	UINT32 average_short[SMU_IRANGE_COUNT];
    UINT32 average_medium[SMU_IRANGE_COUNT];
    UINT32 average_long[SMU_IRANGE_COUNT];
	
	UINT32 voltage_average_short;
	UINT32 voltage_average_medium;
	UINT32 voltage_average_long;
} UIAverageCountReg;

//typedef struct {
//    int module;
//    char calib_mode;  // 'V'/'I' calibration
//    char smu_mode;
//    int src_rng;
//    int msr_rng;
//    float start;
//    float step;
//    UINT32 no_step;
//    UINT32 count;
//    UINT32 hold;
//    UINT32 delay;
//    BOOL extern_trig;
//    BOOL use_rbox;      // use resistor box
//    BOOL dut_on;        // measure on dut 
//} UICalibMeasReg;
//
//typedef struct {
//    float smu_vdac[MAX_SMU_COUNT];
//    float smu_idac[MAX_SMU_COUNT];
//    float vsu_vdac[MAX_VSU_COUNT];
//} UIDacTableReg;
//
//typedef struct {
//    float smu_vadc[MAX_SMU_COUNT];
//    float smu_iadc[MAX_SMU_COUNT];
//    float vmu_vadc[MAX_VMU_COUNT];
//} UIAdcTableReg;

// Extern

// VSM System Register
typedef struct {
    //-------------------------------------------------------------------
    // installed이 FALSE이면 셀프테스트, 실행 중 켈리브레이션에서 사용됨 
    // used: 측정시 사용됨
    BOOL installed;
    // 실제 사용되는 최대/최소 레인지.
    int min_range;
    int max_range;
    //-------------------------------------------------------------------

    BOOL used; // 주의! installed=FALSE 라도 uesd=TRUE 이면 측정된다. 
    float source;
    float ready; //<sampling mode>

	BOOL pulsemode;
	float base;
	unsigned long width;
    unsigned long period;  
} TVsuCtrlReg;

typedef struct {
    //-------------------------------------------------------------------
    // installed이 FALSE이면 셀프테스트, 실행 중 켈리브레이션에서 사용됨 
    // used: 측정시 사용됨
    BOOL installed;
    // 실제 사용되는 최대/최소 레인지.
    int min_range;
    int max_range;
    //-------------------------------------------------------------------

    BOOL used; // 주의! installed=FALSE 라도 uesd=TRUE 이면 측정된다.        
    short msr_rng;
    short msr_max_rng;
    short msr_min_rng;
    float msr_val;
} TVmuCtrlReg;


typedef struct
{
	long id_code;
	long sta_version;
	long ac_power_freq;
	char model_name[MAX_MODEL_NAME+1];
} SysInfo;

/*************************** User Registers **************************/
extern UISmuReg SmuReg[MAX_SMU_COUNT];
extern UIVsuReg VsuReg[MAX_VSU_COUNT];
extern UIVmuReg VmuReg[MAX_VMU_COUNT];
extern UIVarAReg  VarAReg;
extern UIVarBReg  VarBReg;
extern UIVarA1Reg VarA1Reg;

extern UISamplingReg SamplingReg; // <sampling mode>
// VSM System Register
extern TVsuCtrlReg vsu_reg[MAX_VSU_COUNT];
extern TVmuCtrlReg vmu_reg[MAX_VMU_COUNT];

extern UIDelayCtrlReg delay_set;
extern UIAverageCountReg average_set;

extern UIPulseReg PulseReg; //pulse mode
extern UIDataReg DataReg;
extern UIMeasTimeReg MeasTimeReg;

extern UINT32 interval_reg[MAX_SAMPLING_CNT];

extern int NoConstant;
extern int AverageCount;

extern float SmuSrcDataReg[MAX_SMU_COUNT][MAX_DATA_COUNT];
extern float SmuMsrDataReg[MAX_SMU_COUNT][MAX_DATA_COUNT];
extern UINT8 SmuStateDataReg[MAX_SMU_COUNT][MAX_DATA_COUNT];
extern float VsuDataReg[MAX_VSU_COUNT][MAX_DATA_COUNT];
extern float VmuDataReg[MAX_VMU_COUNT][MAX_DATA_COUNT];
extern int CmdMode;
extern int MeasMode;
extern UINT32 MeasState;
extern BOOL EnableAutoCalib;

// Function 선언

#ifdef __cplusplus
    extern "C" {
#endif

void load_sta_info(long id, long ver, long freq, char *model);
void read_sta_info(void);
void write_sta_info(void);
void print_sta_info(void);
void return_sta_info(void);
void configure_sta_info();

int GetVarACh();
int GetVarBCh();
int GetVarA1Ch();
float GetVarASource(int k);
float GetVarBSource(int k);
float GetVarA1Source(int k);
float GetVarAStop();
float GetVarBStop();
float GetVarA1Start();
float GetVarA1Stop();
void SetMeasState(UINT32 state);
void InitSmuReg(int ch);
void InitVsuReg(int ch);
void InitVmuReg(int ch);
void InitModuleReg();
void InitUserReg();
void init_reg();
int init_hw();
UINT32 SelfTest();
int get_smu_rng(int ch, char mode, float val);
void create_sweep_var();

int start_stress();
void stress_force(int data_cnt, int Ntotal);
void stress_force_const(int ch, int data_cnt, int Ntotal);

int start_sweep();
int start_sweep_repeat();
void sweep_force(int data_cnt, int Ntotal);
void sweep_measure(int data_cnt, int Ntotal);
void force_const(int ch, int data_cnt, int Ntotal);
void force_vara(int ch, int data_cnt, int Ntotal);
void force_varb(int ch, int data_cnt, int Ntotal);
void force_vara1(int ch, int data_cnt, int Ntotal);



#ifdef __cplusplus
    }
#endif

#endif
