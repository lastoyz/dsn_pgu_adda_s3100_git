//// SMU.cs

//// from App_SmuTest.h
// //HLSMU Define
// enum{
//
//     // SSPI
//     EP_ADRS__HLSMU_SSPI_TEST_WO               = 0xE0,             // 0x380
//     EP_ADRS__HLSMU_SSPI_CON_WI                = 0x02,             // 0x008
//     // TEST
//     EP_ADRS__HLSMU_FPGA_IMAGE_ID_WO           = 0x20,             // 0x080
//     EP_ADRS__HLSMU_XADC_TEMP_WO               = 0x3A,             // 0x0E8
// 
//     // HRADC CH1/CH2
//     EP_ADRS__HLSMU_HRADC_CH1_CON_WI           = 0x08,             // 0x020
//     EP_ADRS__HLSMU_HRADC_CH1_FLAG_WO          = 0x28,             // 0x0A0
//     EP_ADRS__HLSMU_HRADC_CH1_TRIG_TI          = 0x48,             // 0x120
//     EP_ADRS__HLSMU_HRADC_CH1_TRIG_TO          = 0x68,             // 0x1A0
//     EP_ADRS__HLSMU_HRADC_CH1_DAT_WO           = 0x29,             // 0x0A4
//     EP_ADRS__HLSMU_HRADC_CH2_CON_WI           = 0x18,             // 0x060
//     EP_ADRS__HLSMU_HRADC_CH2_FLAG_WO          = 0x38,             // 0x0E0
//     EP_ADRS__HLSMU_HRADC_CH2_TRIG_TI          = 0x58,             // 0x160
//     EP_ADRS__HLSMU_HRADC_CH2_TRIG_TO          = 0x68,             // 0x1E0
//     EP_ADRS__HLSMU_HRADC_CH2_DAT_WO           = 0x39,             // 0x0E4
// 
//     // LED
//     EP_ADRS__HLSMU_LED_CON_WI                 = 0x10,             // 0x040
//     EP_ADRS__HLSMU_LED_CON_TI                 = 0x50,             // 0x140
// 
//     // I_RANGE_CON_CH1/CH2
//     EP_ADRS__HLSMU_IRANGE_CON_CH1_WI         = 0x04,             // 0x010
//     EP_ADRS__HLSMU_IRANGE_CON_CH1_TI         = 0x44,             // 0x110
//     EP_ADRS__HLSMU_IRANGE_CON_CH2_WI         = 0x14,             // 0x050
//     EP_ADRS__HLSMU_IRANGE_CON_CH2_TI         = 0x54,             // 0x150
// 
//     // O_RLY_CH1/CH2
//     EP_ADRS__HLSMU_OUTP_RELAY_CH1_WI          = 0x05,             // 0x014
//     EP_ADRS__HLSMU_OUTP_RELAY_CH1_TI          = 0x45,             // 0x114
//     EP_ADRS__HLSMU_OUTP_RELAY_CH2_WI          = 0x15,             // 0x054
//     EP_ADRS__HLSMU_OUTP_RELAY_CH2_TI          = 0x55,             // 0x154
// 
//     // VM_RNG_CH1/CH2
//     EP_ADRS__HLSMU_VMRANGE_CH1_WI            = 0x06,             // 0x018
//     EP_ADRS__HLSMU_VMRANGE_CH1_TI            = 0x46,             // 0x118
//     EP_ADRS__HLSMU_VMRANGE_CH2_WI            = 0x16,             // 0x058
//     EP_ADRS__HLSMU_VMRANGE_CH2_TI            = 0x56,             // 0x158
// 
//     // VS_RNG_CH1/CH2
//     EP_ADRS__HLSMU_VSRANGE_CH1_WI            = 0x01,             // 0x004
//     EP_ADRS__HLSMU_VSRANGE_CH1_TI            = 0x41,             // 0x104
//     EP_ADRS__HLSMU_VSRANGE_CH2_WI            = 0x11,             // 0x044
//     EP_ADRS__HLSMU_VSRANGE_CH2_TI            = 0x51,             // 0x144
// 
//     // ADC_SEL_CH1/CH2
//     EP_ADRS__HLSMU_ADCIN_SEL_CH1_WI          = 0x07,             // 0x01C
//     EP_ADRS__HLSMU_ADCIN_SEL_CH1_TI          = 0x47,             // 0x11C
//     EP_ADRS__HLSMU_ADCIN_SEL_CH2_WI          = 0x17,             // 0x05C
//     EP_ADRS__HLSMU_ADCIN_SEL_CH2_TI          = 0x57,             // 0x15C
// 
//     // ERR_AMP_TR_CH1/CH2
//     EP_ADRS__HLSMU_ERRAMP_TR_CH1_WI         = 0x09,             // 0x024
//     EP_ADRS__HLSMU_ERRAMP_TR_CH1_TI         = 0x49,             // 0x124
//     EP_ADRS__HLSMU_ERRAMP_TR_CH2_WI         = 0x19,             // 0x064
//     EP_ADRS__HLSMU_ERRAMP_TR_CH2_TI         = 0x59,             // 0x164
// 
//     // V_DAC_CH1/CH2
//     EP_ADRS__HLSMU_V_DAC_VAL_CH1_WI         = 0x0A,             // 0x028
//     EP_ADRS__HLSMU_V_DAC_OPCODE_CH1_WI      = 0x0B,             // 0x02C    
//     EP_ADRS__HLSMU_V_DAC_CON_CH1_WI         = 0x0C,             // 0x030
//     EP_ADRS__HLSMU_V_DAC_VAL_CH1_WO         = 0x26,             // 0x098
//     EP_ADRS__HLSMU_V_DAC_CON_CH1_TI         = 0x4B,             // 0x12C
//     EP_ADRS__HLSMU_V_DAC_CON_CH1_TO         = 0x69,             // 0x1A4
// 
//     EP_ADRS__HLSMU_V_DAC_VAL_CH2_WI         = 0x1A,             // 0x068
//     EP_ADRS__HLSMU_V_DAC_OPCODE_CH2_WI      = 0x1B,             // 0x06C
//     EP_ADRS__HLSMU_V_DAC_CON_CH2_WI         = 0x1C,             // 0x070
//     EP_ADRS__HLSMU_V_DAC_VAL_CH2_WO         = 0x36,             // 0x0D8
//     EP_ADRS__HLSMU_V_DAC_CON_CH2_TI         = 0x5B,             // 0x16C
//     EP_ADRS__HLSMU_V_DAC_CON_CH2_TO         = 0x79,             // 0x1E4
// 
//     // I_DAC_CH1/CH2
//     EP_ADRS__HLSMU_I_DAC_VAL_CH1_WI         = 0x0D,             // 0x034
//     EP_ADRS__HLSMU_I_DAC_OPCODE_CH1_WI      = 0x0E,             // 0x038
//     EP_ADRS__HLSMU_I_DAC_CON_CH1_WI         = 0x0F,             // 0x03C
//     EP_ADRS__HLSMU_I_DAC_VAL_CH1_WO         = 0x27,             // 0x09C
//     EP_ADRS__HLSMU_I_DAC_CON_CH1_TI         = 0x4C,             // 0x130
//     EP_ADRS__HLSMU_I_DAC_CON_CH1_TO         = 0x6A,             // 0x1A8
// 
//     EP_ADRS__HLSMU_I_DAC_VAL_CH2_WI         = 0x1D,             // 0x074
//     EP_ADRS__HLSMU_I_DAC_OPCODE_CH2_WI      = 0x1E,             // 0x078
//     EP_ADRS__HLSMU_I_DAC_CON_CH2_WI         = 0x1F,             // 0x07C
//     EP_ADRS__HLSMU_I_DAC_VAL_CH2_WO         = 0x37,             // 0x0DC
//     EP_ADRS__HLSMU_I_DAC_CON_CH2_TI         = 0x5C,             // 0x170
//     EP_ADRS__HLSMU_I_DAC_CON_CH2_TO         = 0x7A,             // 0x1E8
// 
//     // I_MODE_CH1/CH2
//     EP_ADRS__HLSMU_IMODE_CH1_WO             = 0x25,             // 0x094
//     EP_ADRS__HLSMU_IMODE_CH2_WO             = 0x26              // 0x098
// 
// };
// 
// enum
// {
//     HLSMU_OPCODE_DAC_INIT     = 0x00004002,
//     HLSMU_OPCODE_DAC_READ     = 0x00002002,
//     HLSMU_OPCODE_DAC_SET      = 0x00004402,
//     HLSMU_OPCODE_DAC_SET_READ = 0x00002402
// };


using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL   = System.Boolean; // for converting firmware

    //// some common interface


    //// some common class or enum or struct
    using TSmuCtrlReg = __struct_TSmuCtrlReg;
    using TSmuCtrl    = __struct_TSmuCtrl;

    public struct __struct_TSmuCtrlReg
    {
        public bool used;
        public bool is_measure;
        public int mode;
        public int base_addr;
        public char state;

        public float src_val;
        public float limit_val;
        public int   limit_i_rng;
        public int   limit_v_rng;
        
        public float imsr_val;
        public float vmsr_val;

        public int src_rng;
        public int msr_rng; //2015.12.22
        public short msr_max_rng;
        public short msr_min_rng;
    
        public int min_vrange;
        public int max_vrange;

        public int min_imsr_range;
        public int max_imsr_range;
        public int min_isrc_range;
        public int max_isrc_range;

        public int ictrl;
        public int vctrl; // s32 vs u16
        public int comp_ctrl;

        public int idac_in_val;
        public int vdac_in_val;

        public int imsr_rng;
        public int vmsr_rng;
        public short imsr_max_rng;
        public short imsr_min_rng;
        public short vmsr_max_rng;
        public short vmsr_min_rng;

        // StaClients 용 추가
        // 2015.12.22
        public float _base_; //$$ base --> _base_
        public UINT32 width;
        public UINT32 period;
        public BOOL sweep_measured;

        // sbcho@20211108 HLSMU
        public UINT16 diag_relay_ctrl;
        public UINT16 force_relay_ctrl;

        public UINT16 iv_dac_filter_ctrl;
        public UINT16 adc_plc_info;

    }

    public struct __struct_TSmuCtrl
    {
        public int vctrl;
        public int ictrl;
        public int comp_ctrl;
    }

    public partial class __HLSMU {
        
        // for App_SmuTest.h
        //HLSMU Define
        public enum __enum_EPA 
        {
            // SSPI
            EP_ADRS__HLSMU_SSPI_TEST_WO               = 0xE0,             // 0x380
            EP_ADRS__HLSMU_SSPI_CON_WI                = 0x02,             // 0x008
            // TEST
            EP_ADRS__HLSMU_FPGA_IMAGE_ID_WO           = 0x20,             // 0x080
            EP_ADRS__HLSMU_XADC_TEMP_WO               = 0x3A,             // 0x0E8

            // HRADC CH1/CH2
            EP_ADRS__HLSMU_HRADC_CH1_CON_WI           = 0x08,             // 0x020
            EP_ADRS__HLSMU_HRADC_CH1_FLAG_WO          = 0x28,             // 0x0A0
            EP_ADRS__HLSMU_HRADC_CH1_TRIG_TI          = 0x48,             // 0x120
            EP_ADRS__HLSMU_HRADC_CH1_TRIG_TO          = 0x68,             // 0x1A0
            EP_ADRS__HLSMU_HRADC_CH1_DAT_WO           = 0x29,             // 0x0A4
            EP_ADRS__HLSMU_HRADC_CH2_CON_WI           = 0x18,             // 0x060
            EP_ADRS__HLSMU_HRADC_CH2_FLAG_WO          = 0x38,             // 0x0E0
            EP_ADRS__HLSMU_HRADC_CH2_TRIG_TI          = 0x58,             // 0x160
            EP_ADRS__HLSMU_HRADC_CH2_TRIG_TO          = 0x68,             // 0x1E0
            EP_ADRS__HLSMU_HRADC_CH2_DAT_WO           = 0x39,             // 0x0E4

            // LED
            EP_ADRS__HLSMU_LED_CON_WI                 = 0x10,             // 0x040
            EP_ADRS__HLSMU_LED_CON_TI                 = 0x50,             // 0x140

            // I_RANGE_CON_CH1/CH2
            EP_ADRS__HLSMU_IRANGE_CON_CH1_WI         = 0x04,             // 0x010
            EP_ADRS__HLSMU_IRANGE_CON_CH1_TI         = 0x44,             // 0x110
            EP_ADRS__HLSMU_IRANGE_CON_CH2_WI         = 0x14,             // 0x050
            EP_ADRS__HLSMU_IRANGE_CON_CH2_TI         = 0x54,             // 0x150

            // O_RLY_CH1/CH2
            EP_ADRS__HLSMU_OUTP_RELAY_CH1_WI          = 0x05,             // 0x014
            EP_ADRS__HLSMU_OUTP_RELAY_CH1_TI          = 0x45,             // 0x114
            EP_ADRS__HLSMU_OUTP_RELAY_CH2_WI          = 0x15,             // 0x054
            EP_ADRS__HLSMU_OUTP_RELAY_CH2_TI          = 0x55,             // 0x154

            // VM_RNG_CH1/CH2
            EP_ADRS__HLSMU_VMRANGE_CH1_WI            = 0x06,             // 0x018
            EP_ADRS__HLSMU_VMRANGE_CH1_TI            = 0x46,             // 0x118
            EP_ADRS__HLSMU_VMRANGE_CH2_WI            = 0x16,             // 0x058
            EP_ADRS__HLSMU_VMRANGE_CH2_TI            = 0x56,             // 0x158

            // VS_RNG_CH1/CH2
            EP_ADRS__HLSMU_VSRANGE_CH1_WI            = 0x01,             // 0x004
            EP_ADRS__HLSMU_VSRANGE_CH1_TI            = 0x41,             // 0x104
            EP_ADRS__HLSMU_VSRANGE_CH2_WI            = 0x11,             // 0x044
            EP_ADRS__HLSMU_VSRANGE_CH2_TI            = 0x51,             // 0x144

            // ADC_SEL_CH1/CH2
            EP_ADRS__HLSMU_ADCIN_SEL_CH1_WI          = 0x07,             // 0x01C
            EP_ADRS__HLSMU_ADCIN_SEL_CH1_TI          = 0x47,             // 0x11C
            EP_ADRS__HLSMU_ADCIN_SEL_CH2_WI          = 0x17,             // 0x05C
            EP_ADRS__HLSMU_ADCIN_SEL_CH2_TI          = 0x57,             // 0x15C

            // ERR_AMP_TR_CH1/CH2
            EP_ADRS__HLSMU_ERRAMP_TR_CH1_WI         = 0x09,             // 0x024
            EP_ADRS__HLSMU_ERRAMP_TR_CH1_TI         = 0x49,             // 0x124
            EP_ADRS__HLSMU_ERRAMP_TR_CH2_WI         = 0x19,             // 0x064
            EP_ADRS__HLSMU_ERRAMP_TR_CH2_TI         = 0x59,             // 0x164

            // V_DAC_CH1/CH2
            EP_ADRS__HLSMU_V_DAC_VAL_CH1_WI         = 0x0A,             // 0x028
            EP_ADRS__HLSMU_V_DAC_OPCODE_CH1_WI      = 0x0B,             // 0x02C    
            EP_ADRS__HLSMU_V_DAC_CON_CH1_WI         = 0x0C,             // 0x030
            EP_ADRS__HLSMU_V_DAC_VAL_CH1_WO         = 0x26,             // 0x098
            EP_ADRS__HLSMU_V_DAC_CON_CH1_TI         = 0x4B,             // 0x12C
            EP_ADRS__HLSMU_V_DAC_CON_CH1_TO         = 0x69,             // 0x1A4

            EP_ADRS__HLSMU_V_DAC_VAL_CH2_WI         = 0x1A,             // 0x068
            EP_ADRS__HLSMU_V_DAC_OPCODE_CH2_WI      = 0x1B,             // 0x06C
            EP_ADRS__HLSMU_V_DAC_CON_CH2_WI         = 0x1C,             // 0x070
            EP_ADRS__HLSMU_V_DAC_VAL_CH2_WO         = 0x36,             // 0x0D8
            EP_ADRS__HLSMU_V_DAC_CON_CH2_TI         = 0x5B,             // 0x16C
            EP_ADRS__HLSMU_V_DAC_CON_CH2_TO         = 0x79,             // 0x1E4

            // I_DAC_CH1/CH2
            EP_ADRS__HLSMU_I_DAC_VAL_CH1_WI         = 0x0D,             // 0x034
            EP_ADRS__HLSMU_I_DAC_OPCODE_CH1_WI      = 0x0E,             // 0x038
            EP_ADRS__HLSMU_I_DAC_CON_CH1_WI         = 0x0F,             // 0x03C
            EP_ADRS__HLSMU_I_DAC_VAL_CH1_WO         = 0x27,             // 0x09C
            EP_ADRS__HLSMU_I_DAC_CON_CH1_TI         = 0x4C,             // 0x130
            EP_ADRS__HLSMU_I_DAC_CON_CH1_TO         = 0x6A,             // 0x1A8

            EP_ADRS__HLSMU_I_DAC_VAL_CH2_WI         = 0x1D,             // 0x074
            EP_ADRS__HLSMU_I_DAC_OPCODE_CH2_WI      = 0x1E,             // 0x078
            EP_ADRS__HLSMU_I_DAC_CON_CH2_WI         = 0x1F,             // 0x07C
            EP_ADRS__HLSMU_I_DAC_VAL_CH2_WO         = 0x37,             // 0x0DC
            EP_ADRS__HLSMU_I_DAC_CON_CH2_TI         = 0x5C,             // 0x170
            EP_ADRS__HLSMU_I_DAC_CON_CH2_TO         = 0x7A,             // 0x1E8

            // I_MODE_CH1/CH2
            EP_ADRS__HLSMU_IMODE_CH1_WO             = 0x25,             // 0x094
            EP_ADRS__HLSMU_IMODE_CH2_WO             = 0x26              // 0x098

        };

        public enum __enum_OPC
        {
            HLSMU_OPCODE_DAC_INIT     = 0x00004002,
            HLSMU_OPCODE_DAC_READ     = 0x00002002,
            HLSMU_OPCODE_DAC_SET      = 0x00004402,
            HLSMU_OPCODE_DAC_SET_READ = 0x00002402
        };

    }


    public partial class __HVSMU {
        // for App_SmuTest.h
        
        //// EPS address map info ......
        
        // for S3100 common       : TEST, MEM
        // for S3100-ADDA only    : DACX, DACZ, DACn, CLKD, SPIO, ADCH.
        // for S3100-CMU-ANL only : RRIV, DET, AMP, STAT, DACQ(AD5754).
        // for S3100-CMU-SIG only : DACP, EXT, FILT.
		// for S3100-HVPGU only   : HVPGU.
		// for S3100-HVSMU only   : HRADC(LTC2380), HRDAC(AD5791), I_RNG, O_RLY, V_RNG, E_AMP, A_SEL, I_MODE.

        public string EP_ADRS__GROUP_STR         = "_S3100_HVSMU_"; // reserved

        public enum __enum_EPA 
        {
            EP_ADRS__SSPI_TEST_WO     = 0xE0, // 0x380
            EP_ADRS__SSPI_CON_WI      = 0x02, // 0x008
            EP_ADRS__FPGA_IMAGE_ID_WO = 0x20, // common
            EP_ADRS__XADC_TEMP_WO     = 0x3A, // common

            //LED
            EP_ADRS__TEST_LED_WI      = 0x10, //$$ HVSMU // 0x040
            EP_ADRS__TEST_LED_TI      = 0x50, //$$ HVSMU // 0x140

            // MEM
            EP_ADRS__MEM_FDAT_WI        = 0x12,
            EP_ADRS__MEM_WI             = 0x13,
            EP_ADRS__MEM_TI             = 0x53,
            EP_ADRS__MEM_TO             = 0x73,
            EP_ADRS__MEM_PI             = 0x93,
            EP_ADRS__MEM_PO             = 0xB3,

            // S3100-GNDU // shared with others // note spi channels may be different.
            // S3100-ADDA
            // S3100-HVSMU
            // EP_ADRS__HRADC_CON_WI       = 0x08, // 0x020
            // EP_ADRS__HRADC_FLAG_WO      = 0x28, // 0x0A0
            // EP_ADRS__HRADC_TRIG_TI      = 0x48, // 0x120
            // EP_ADRS__HRADC_TRIG_TO      = 0x68, // 0x1A0
            // EP_ADRS__HRADC_DAT_WO       = 0x29, // 0x0A4

            // S3100-GNDU
            //private u32   EP_ADRS__DIAG_RELAY_WI      = 0x04; // 0x010
            //private u32   EP_ADRS__DIAG_RELAY_TI      = 0x44; // 0x110

            // S3100-HVSMU
            // EP_ADRS__I_RANGE_CON_WI      = 0x04, // 0x010
            // EP_ADRS__I_RANGE_CON_TI      = 0x44, // 0x110

            // S3100-GNDU
            // S3100-HVSMU
            // EP_ADRS__OUTP_RELAY_WI      = 0x05, // 0x014
            // EP_ADRS__OUTP_RELAY_TI      = 0x45, // 0x114

            // S3100-GNDU
            // S3100-HVSMU
            // EP_ADRS__VM_RANGE_WI        = 0x06, // 0x018
            // EP_ADRS__VM_RANGE_TI        = 0x46, // 0x118

            // S3100-HVSMU
            // EP_ADRS__VS_RANGE_WI        = 0x01, // 0x004
            // EP_ADRS__VS_RANGE_TI        = 0x41, // 0x104
            // EP_ADRS__ERR_AMP_TR_WI      = 0x09, // 0x024
            // EP_ADRS__ERR_AMP_TR_TI      = 0x49, // 0x124
            // EP_ADRS__ADC_IN_SEL_WI      = 0x07, // 0x01C
            // EP_ADRS__ADC_IN_SEL_TI      = 0x47, // 0x11C

            //// S3100-HVSMU
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
            //EP_ADRS__HVSMU_LED_CON_WI             = 0x10,             // 0x040
            //EP_ADRS__HVSMU_LED_CON_TI             = 0x50,             // 0x140

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
            EP_ADRS__HVSMU_IMODE_WO               = 0x25              // 0x094

            // S3100-GNDU
            //private u32   EP_ADRS__VDAC_VAL_WI        = 0x09; // 0x024
            //private u32   EP_ADRS__VDAC_CON_TI        = 0x49; // 0x124

            // S3100-HVSMU
            // EP_ADRS__HRDAC_VDAC_WI     = 0x0C, // 0x030
            // EP_ADRS__HRDAC_VDAC_WO     = 0x26, // 0x098
            // EP_ADRS__HRDAC_VDAC_TI     = 0x4B, // 0x12C
            // EP_ADRS__HRDAC_VDAC_TO     = 0x69, // 0x1A4
            // EP_ADRS__HRDAC_IDAC_WI     = 0x0F, // 0x03C
            // EP_ADRS__HRDAC_IDAC_WO     = 0x27, // 0x09C
            // EP_ADRS__HRDAC_IDAC_TI     = 0x4C, // 0x130
            // EP_ADRS__HRDAC_IDAC_TO     = 0x6A, // 0x1A8

            // S3100-CMU-SIG
            // EP_ADRS__DACP_WI        = 0x19,
            // EP_ADRS__EXT_WI         = 0x1A,
            // EP_ADRS__FILT_WI        = 0x1B,

            // S3100-HVPGU
            // EP_ADRS__HVPGU_WI       = 0x11,
            // EP_ADRS__HVPGU_WO       = 0x31,

            // S3100-SMU : board control, read ID // shared with CMU
            // EP_ADRS__SMU_WI         = 0x14,
            // EP_ADRS__SMU_WO         = 0x34,
        
        }

        public enum __enum_SMU
        {
            //
            NO_OF_SMU               = 12,
            //
            NO_OF_AUX_INPUTBD       = 1,
            NO_OF_IO_INPUT	        = 1,
            //
            SMU_MODE_COM            = 0,
            SMU_MODE_V              = 1,
            SMU_MODE_I              = 2,
            CALIB_MODE_I	        = 1,
            CALIB_MODE_V	        = 2,
            SMU_ICTRL_XORMASK	    = 0x0000003D,
            SMU_VCTRL_XORMASK	    = 0xFFFF,
            SMU_COMP_CTRL_XORMASK	= 0x01, // 5M_COMP is Active High!
            //
            NO_OF_VRANGE            = 5,
            // sbcho@20211217 HVSMU
            SMU_2V_RANGE            = 0,
            SMU_5V_RANGE            = 1,
            SMU_20V_RANGE           = 2,
            SMU_40V_RANGE           = 3,
            SMU_200V_RANGE          = 4,
            //
            SMU_VCTRL_SRC_MASK      = 0x00FF,
            SMU_VCTRL_MSR_MASK      = 0xFF00,
            //
            // sbcho@20211108 HVSMU
            SMU_2V_CTRL	            = 0x0000,              // Close loop
            SMU_5V_CTRL	            = 0x0101,
            SMU_20V_CTRL            = 0x0202,
            SMU_40V_CTRL            = 0x0404,
            SMU_200V_CTRL           = 0x0808,
            //
            SMU_IX10_COMP           = 0x01,
            SMU_5M_COMP             = 0x02,
            //
            NO_OF_IRANGE            = 12,
            SMU_10pA_RANGE	        = 0, 	// HVSMU used
            SMU_100pA_RANGE	        = 1,   // HVSMU used
            SMU_1nA_RANGE	        = 2,   // 0.000000001  1E-9   10G 
            SMU_10nA_RANGE	        = 3,   // 0.00000001   1E-8   1G  
            SMU_100nA_RANGE         = 4,   // 0.0000001    1E-7   100M
            SMU_1uA_RANGE	        = 5,   // 0.000001     1E-6   10M 
            SMU_10uA_RANGE	        = 6,   // 0.00001      1E-5   1M  
            SMU_100uA_RANGE         = 7,   // 0.0001       1E-4   100K
            SMU_1mA_RANGE	        = 8,   // 0.001        1E-3   10K
            SMU_10mA_RANGE	        = 9,   // 0.01         1E-2   1K
            SMU_100mA_RANGE         = 10,  // 0.1          1E-1   100
            SMU_1A_RANGE	        = 11,  // not used
            //
            SMU_UPPER_LEAK_IRANGE   = SMU_10nA_RANGE,

            // sbcho@20211217 HVSMU
            SMU_ICTRL_MASK          = 0x00F7FF,
            SMU_ICTRL_IX10_MASK     = 0x000003,
            SMU_ICTRL_RAMP_MASK     = 0x0000FC,

            // sbcho@20211217 HVSMU
            SMU_ICTRL_RELAY_MASK    = 0x00F000,
            SMU_ICTRL_MJFET_MASK    = 0x000700,
            //
            SMU_ICTRL_IX10	        = 0x000002,
            SMU_ICTRL_IX10_BAR      = 0x000002,
            //
            SMU_ICTRL_INIT          = 0x000000,

            //sbcho@20211217 HVSMU
            SMU_100mA_CTRL          = 0x00F1FF,
            SMU_10mA_CTRL           = 0x00F2F8,
            SMU_1mA_CTRL            = 0x00F2FA,
            SMU_100uA_CTRL          = 0x00F4F1,
            SMU_10uA_CTRL           = 0x00F4F2,
            SMU_1uA_CTRL            = 0x00E4E0,
            SMU_100nA_CTRL          = 0x00E4E3,
            SMU_10nA_CTRL           = 0x00C4C0,
            SMU_1nA_CTRL            = 0x00C4C3,
            SMU_100pA_CTRL          = 0x008483,
            SMU_10pA_CTRL           = 0x000403,
            //
            SMU_ICTRL_5G_RAMP       = 0x000080,
            SMU_ICTRL_500M_RAMP     = 0x000040,
            SMU_ICTRL_5M_RAMP       = 0x000020,
            SMU_ICTRL_50K_RAMP      = 0x000010,
            SMU_ICTRL_500_RAMP      = 0x000008,
            SMU_ICTRL_5_RAMP        = 0x000004,

            // relay
            SMU_GUARD_REL	        = 0x0001,
            SMU_FOCE_REL	        = 0x0002,
            SMU_DIAG_REL		    = 0x0004,
            SMU_GRD_RLY	        = 0x0001, // alt name
            SMU_FRC_RLY	        = 0x0002, // alt name
            SMU_DIG_RLY		    = 0x0004, // alt name

            //
            SMU_STATE_VMODE	       = 0x03,
            SMU_STATE_MASK	       = 0x03
        }

        public INT32[]  smu_vadc_values    = new INT32[(int)__enum_SMU.NO_OF_SMU];  
        public INT32[]  smu_iadc_values    = new INT32[(int)__enum_SMU.NO_OF_SMU];

        public TSmuCtrlReg[]  smu_ctrl_reg = new TSmuCtrlReg[(int)__enum_SMU.NO_OF_SMU]; // TSmuCtrlReg smu_ctrl_reg[NO_OF_SMU];


    }


    //// inheritance control
    public partial class __S3100_CPU_BASE : __HVSMU {} // note: __HVSMU has END-POINT ADDRESS for HVSMU // __enum_EPA
    public partial class __S3100_SPI_EMUL : __HVSMU {} // note: __HVSMU has END-POINT ADDRESS for HVSMU // __enum_EPA
    public partial class EPS : __S3100_SPI_EMUL {} // __S3100_SPI_EMUL vs __S3100_CPU_BASE
    public partial class SMU : EPS {}


    
}
