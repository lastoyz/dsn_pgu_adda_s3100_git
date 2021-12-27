#ifndef	_APP_SMUTEST_H
#define	_APP_SMUTEST_H

#include "top_core_info.h"

#ifdef __cplusplus
extern "C" {
#endif 


// HVSMU Define
enum{

    // SSPI
    //EP_ADRS__HVSMU_SSPI_TEST_WO           = 0xE0,             // 0x380
    //EP_ADRS__HVSMU_SSPI_CON_WI            = 0x02,             // 0x008
    // TEST
    //EP_ADRS__HVSMU_FPGA_IMAGE_ID_WO       = 0x20,             // 0x080
    //EP_ADRS__HVSMU_XADC_TEMP_WO           = 0x3A,             // 0x0E8

    // HRADC
    EP_ADRS__HVSMU_HRADC_CON_WI           = 0x08,             // 0x020
    EP_ADRS__HVSMU_HRADC_FLAG_WO          = 0x28,             // 0x0A0
    EP_ADRS__HVSMU_HRADC_TRIG_TI          = 0x48,             // 0x120
    EP_ADRS__HVSMU_HRADC_TRIG_TO          = 0x68,             // 0x1A0
    EP_ADRS__HVSMU_HRADC_DAT_WO           = 0x29,             // 0x0A4

    // LED
    EP_ADRS__HVSMU_LED_CON_WI             = 0x10,             // 0x040
    EP_ADRS__HVSMU_LED_CON_TI             = 0x50,             // 0x140

    // I_RANGE_CON
    EP_ADRS__HVSMU_IRANGE_CON_WI          = 0x04,             // 0x010
    EP_ADRS__HVSMU_IRANGE_CON_TI          = 0x44,             // 0x110


    // O_RLY
    EP_ADRS__HVSMU_OUTP_RELAY_WI          = 0x05,             // 0x014
    EP_ADRS__HVSMU_OUTP_RELAY_TI          = 0x45,             // 0x114

    // VM_RNG
    EP_ADRS__HVSMU_VMRANGE_WI             = 0x06,             // 0x018
    EP_ADRS__HVSMU_VMRANGE_TI             = 0x46,             // 0x118

    // VS_RNG
    EP_ADRS__HVSMU_VSRANGE_WI             = 0x01,             // 0x004
    EP_ADRS__HVSMU_VSRANGE_TI             = 0x41,             // 0x104

    // ADC_SEL
    EP_ADRS__HVSMU_ADCIN_SEL_WI           = 0x07,             // 0x01C
    EP_ADRS__HVSMU_ADCIN_SEL_TI           = 0x47,             // 0x11C

    // ERR_AMP_TR
    EP_ADRS__HVSMU_ERRAMP_TR_WI           = 0x09,             // 0x024
    EP_ADRS__HVSMU_ERRAMP_TR_TI           = 0x49,             // 0x124

    // V_DAC
    EP_ADRS__HVSMU_VDAC_WI                = 0x0C,             // 0x030
    EP_ADRS__HVSMU_VDAC_WO                = 0x26,             // 0x098
    EP_ADRS__HVSMU_VDAC_TI                = 0x4B,             // 0x12C
    EP_ADRS__HVSMU_VDAC_TO                = 0x69,             // 0x1A4
        
    // I_DAC              
    EP_ADRS__HVSMU_IDAC_WI                = 0x0F,             // 0x03C
    EP_ADRS__HVSMU_IDAC_WO                = 0x27,             // 0x09C
    EP_ADRS__HVSMU_IDAC_TI                = 0x4C,             // 0x130
    EP_ADRS__HVSMU_IDAC_TO                = 0x6A,             // 0x1A8

    // I_MODE
    EP_ADRS__HVSMU_IMODE_WO               = 0x25,             // 0x094

};

enum
{
    HVSMU_OPCODE_DAC_INIT = 0x00004002,
    HVSMU_OPCODE_DAC_READ = 0x00002002,
    HVSMU_OPCODE_DAC_SET = 0x00004402,
    HVSMU_OPCODE_DAC_SET_READ = 0x00002402
};


// GNDU Define
enum{
                                    //  = A << 2
    EP_ADRS__SSPI_TEST_WO               = 0xE0,             // 0x380
    EP_ADRS__FPGA_IMAGE_ID_WO           = 0x20,             // 0x080
    EP_ADRS__XADC_TEMP_WO               = 0x3A,             // 0x0E8
    // EP_ADRS__XADC_VOLT                  = 0x3B,             
    // EP_ADRS__TIMESTAMP_WO               = 0x22,             
    EP_ADRS__TEST_LED_WI                = 0x01,             // 0x004
    EP_ADRS__TEST_LED_TI                = 0x41,             // 0x104
    EP_ADRS__MEM_WI                     = 0x13,             // 0x04C  
    EP_ADRS__MEM_FDAT_WI                = 0x12,             // 0x048  
    EP_ADRS__MEM_TI                     = 0x53,             // 0x14C  
    EP_ADRS__MEM_TO                     = 0x73,             // 0x1CC  
    EP_ADRS__MEM_PI                     = 0x93,             // 0x24C
    EP_ADRS__MEM_PO                     = 0xB3,             // 0x2CC  
    EP_ADRS__HRADC_CON_WI               = 0x08,             // 0x020
    EP_ADRS__HRADC_FLAG_WO              = 0x28,             // 0x0A0
    EP_ADRS__HRADC_TRIG_TI              = 0x48,             // 0x120
    EP_ADRS__HRADC_TRIG_TO              = 0x68,             // 0x1A0
    EP_ADRS__HRADC_DAT_WO               = 0x29,             // 0x0A4
    EP_ADRS__DIAG_RELAY_WI              = 0x04,             // 0x010
    EP_ADRS__DIAG_RELAY_TI              = 0x44,             // 0x110
    EP_ADRS__OUTP_RELAY_WI              = 0x05,             // 0x014
    EP_ADRS__OUTP_RELAY_TI              = 0x45,             // 0x114
    EP_ADRS__VM_RANGE_WI                = 0x06,             // 0x018
    EP_ADRS__VM_RANGE_TI                = 0x46,             // 0x118
    EP_ADRS__ADC_IN_SEL_WI              = 0x07,             // 0x01C
    EP_ADRS__ADC_IN_SEL_TI              = 0x47,             // 0x11C
    EP_ADRS__VDAC_VAL_WI                = 0x09,             // 0x024
    EP_ADRS__VDAC_CON_TI                = 0x49              // 0x124
};

BOOL tst_MsgOut(const char *format, ...);
BOOL MsgOut_DI(char *data, uint32 length);

BOOL SetADCI(int type, int mode, float value, int autozero, float b_range, int mode_h, float value_h);
BOOL CalSmuOffset_channel(int ch);
BOOL ZeroCalSetOffset(int ch, int rng, float val);
BOOL ZeroCalGetOffset( int ch, int rng, float *offset, float *_offset);

BOOL ZeroCalLoadSmu(int ch, long *magic);
BOOL ZeroCalSaveSmu(int ch);

BOOL CalSetSmuFV(int ch, int vrange, float gain, float offset);
BOOL CalGetSmuFV(int ch, int vrange, float *gain, float *offset);
BOOL CalSetSmuMV(int ch, int vrange, float gain, float offset);
BOOL CalGetSmuMV(int ch, int vrange, float *gain, float *offset);

BOOL CalSetSmuFI(int ch, int irange, float gain, float offset, float _gain, float _offset);
BOOL CalGetSmuFI(int ch, int irange, float *gain, float *offset, float *_gain, float *_offset);
BOOL CalSetSmuMI(int ch, int irange, float gain, float offset, float _gain, float _offset);
BOOL CalGetSmuMI(int ch, int irange, float *gain, float *offset, float *_gain, float *_offset);

BOOL CalSetGnduFV(float gain, float offset);
BOOL CalGetGnduFV(float *gain, float *offset);
BOOL CalSmuFVEN(BOOL en);
BOOL CalSmuMVEN(BOOL en);
BOOL CalSmuFIEN(BOOL en);
BOOL CalSmuMIEN(BOOL en);
BOOL CalGnduFVEN(BOOL en);
BOOL CalLoadSmu(int ch);
BOOL CalSaveSmu(int ch);
BOOL ZeroCalLoadSmu(int ch, long *magic);
BOOL ZeroCalSaveSmu(int ch);
BOOL CalLoadGndu(void);
BOOL CalSaveGndu(void);


u8 ProcessTest(void* pCmd, int argc, void* pData);

u8 ProcessSys(void* pCmd, int argc, void* pData);
u8 ProcessSet(void* pCmd, int argc, void* pData);
u8 ProcessCal(void* pCmd, int argc, void* pData);

u8 ProcessRDPLF(void* pCmd, int argc, void* pData);
u8 ProcessWRPLF(void* pCmd, int argc, void* pData);
u8 ProcessLDPLF(void* pCmd, int argc, void* pData);
u8 ProcessDBG(void* pCmd, int argc, void* pData);
u8 ProcessSMUTEST(void* pCmd, int argc, void* pData);

void ProcessQMFV(char *recvMsg);
void ProcessQMMI(char *recvMsg);

u8 ProcessSMFV(void* pCmd, int argc, void* pData);
u8 ProcessSMFI(void* pCmd, int argc, void* pData);
u8 ProcessSMMV(void* pCmd, int argc, void* pData);
u8 ProcessSMMI(void* pCmd, int argc, void* pData);

u8 ProcessSMFVM(void* pCmd, int argc, void* pData);
u8 ProcessSMFIM(void* pCmd, int argc, void* pData);
u8 ProcessSMMVM(void* pCmd, int argc, void* pData);
u8 ProcessSMMIM(void* pCmd, int argc, void* pData);

u8 ProcessSMU_FORCE_RLY(void* pCmd, int argc, void* pData);
// u8 ProcessSMU_OUT_SENSE_RLY(void* pCmd, int argc, void* pData);

u8 ProcessGNDU_FORCE_RLY(void* pCmd, int argc, void* pData);

u8 ProcessGNDU_FORCE_V_TEST(void* pCmd, int argc, void* pData);
u8 ProcessGNDU_MEAS_I_TEST(void* pCmd, int argc, void* pData);

u8 ProcessRETURN_OK(void* pCmd, int argc, void* pData);


float gndu_temp_read();
u32 gndu_D_RLY_reset();
u32 gndu_D_RLY_send(u32 dat);
u32 gndu_VDAC_reset();
u32 gndu_VDAC_send(float dat_float);
u32 gndu_O_RLY_reset();
u32 gndu_O_RLY_send(u32 dat);
u32 gndu_V_RNG_reset();
u32 gndu_V_RNG_send_act_high(u32 dat);
u32 gndu_A_SEL_reset();
u32 gndu_A_SEL_send_act_high(u32 dat);
u32 gndu_A_SEL__diag();
u32 gndu_A_SEL__gnd();
u32 gndu_A_SEL__5V_gref();
u32 gndu_A_SEL__0V_gref();
u32 gndu_LED_reset();
u32 gndu_LED_load_test_data(u32 dat_b4);
u32 gndu_LED_inc_test_data();
u32 gndu_HRADC_enable();
u32 gndu_HRADC_disable();
float gndu_HRADC_measure();
u32 gndu_HRADC_read_status();




#ifdef __cplusplus
}
#endif 

#endif


