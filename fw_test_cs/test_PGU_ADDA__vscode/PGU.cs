//// CMU.cs

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
//using System.Text.RegularExpressions;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware
    using s8  = System.SByte;  // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL   = System.Boolean; // for converting firmware

    // for SMU compatible
    using TSmuCtrlReg = __struct_TSmuCtrlReg;
    using TSmuCtrl    = __struct_TSmuCtrl;


    //// interface
    interface I_PGU_proc {} // interface for GUI SW // to come
    interface I_PGU_algo {} // interface for algorithm // to come
    interface I_PGU {} // device low-level functions 


    //// some common class or enum or struct

    public partial class __PGU 
    {

        public string EP_ADRS__GROUP_STR         = "_S3100_PGU_"; // reserved

        public string LOG_DIR_NAME               =  "test_PGU_ADDA__vscode";

        public enum __enum_EPA 
        {
            //// common
            EP_ADRS__SSPI_TEST_WO     = 0xE0, // 0x380
            EP_ADRS__SSPI_CON_WI      = 0x02, // 0x008
            EP_ADRS__FPGA_IMAGE_ID_WO = 0x20, // common
            EP_ADRS__XADC_TEMP_WO     = 0x3A, // common

            // MEM
            EP_ADRS__MEM_FDAT_WI        = 0x12,
            EP_ADRS__MEM_WI             = 0x13,
            EP_ADRS__MEM_TI             = 0x53,
            EP_ADRS__MEM_TO             = 0x73,
            EP_ADRS__MEM_PI             = 0x93,
            EP_ADRS__MEM_PO             = 0xB3,


            //// S3100-CMU

            EP_ADRS__CMU_WI         = 0x14,
            EP_ADRS__CMU_WO         = 0x34,

            // S3100-CMU-ANL
            EP_ADRS__RRIV_WI        = 0x15,
            EP_ADRS__DET_WI         = 0x16,
            EP_ADRS__AMP_WI         = 0x17,
            EP_ADRS__STAT_WO        = 0x37,
            EP_ADRS__DACQ_WI        = 0x0A,
            EP_ADRS__DACQ_WO        = 0x2A,
            EP_ADRS__DACQ_TI        = 0x4A,
            EP_ADRS__DACQ_TO        = 0x6A,
            EP_ADRS__DACQ_DIN21_WI  = 0x0B,
            EP_ADRS__DACQ_DIN43_WI  = 0x0C,
            EP_ADRS__DACQ_RDB21_WO  = 0x2B,
            EP_ADRS__DACQ_RDB43_WO  = 0x2C,


            // S3100-CMU-SIG
            EP_ADRS__DACP_WI        = 0x19,
            EP_ADRS__EXT_WI         = 0x1A,
            EP_ADRS__FILT_WI        = 0x1B,


            // S3100-CMU-ADDA
            EP_ADRS__TEST_MON_WO      = 0x23, // status of FPGA pll for DAC

            EP_ADRS__DACX_WI            = 0x05,
            EP_ADRS__DACX_WO            = 0x25,
            EP_ADRS__DACX_TI            = 0x45,
            EP_ADRS__DACZ_DAT_WI        = 0x08,
            EP_ADRS__DACZ_DAT_WO        = 0x28,
            EP_ADRS__DACZ_DAT_TI        = 0x48,
            EP_ADRS__DAC0_DAT_INC_PI    = 0x86,
            EP_ADRS__DAC0_DUR_PI        = 0x87,
            EP_ADRS__DAC1_DAT_INC_PI    = 0x88,
            EP_ADRS__DAC1_DUR_PI        = 0x89,
            EP_ADRS__CLKD_WI            = 0x06,
            EP_ADRS__CLKD_WO            = 0x26,
            EP_ADRS__CLKD_TI            = 0x46,
            EP_ADRS__SPIO_WI            = 0x07,
            EP_ADRS__SPIO_WO            = 0x27,
            EP_ADRS__SPIO_TI            = 0x47,
            EP_ADRS__ADCH_WI            = 0x18,
            EP_ADRS__ADCH_UPD_SM_WI     = 0x1D,
            EP_ADRS__ADCH_SMP_PR_WI     = 0x1E,
            EP_ADRS__ADCH_DLY_TP_WI     = 0x1F,
            EP_ADRS__ADCH_WO            = 0x38,
            EP_ADRS__ADCH_B_FRQ_WO      = 0x39,
            EP_ADRS__ADCH_TI            = 0x58,
            EP_ADRS__ADCH_TO            = 0x78,
            EP_ADRS__ADCH_DOUT0_PO      = 0xBC,
            EP_ADRS__ADCH_DOUT1_PO      = 0xBD,


            //// S3100-PGU

            // S3100-HVPGU
            // EP_ADRS__HVPGU_WI       = 0x11,
            // EP_ADRS__HVPGU_WO       = 0x31,


            //// S3100-GNDU

            // S3100-GNDU // shared with others // note spi channels may be different.
            // EP_ADRS__HRADC_CON_WI       = 0x08, // 0x020
            // EP_ADRS__HRADC_FLAG_WO      = 0x28, // 0x0A0
            // EP_ADRS__HRADC_TRIG_TI      = 0x48, // 0x120
            // EP_ADRS__HRADC_TRIG_TO      = 0x68, // 0x1A0
            // EP_ADRS__HRADC_DAT_WO       = 0x29, // 0x0A4

            // S3100-GNDU
            //private u32   EP_ADRS__DIAG_RELAY_WI      = 0x04; // 0x010
            //private u32   EP_ADRS__DIAG_RELAY_TI      = 0x44; // 0x110

            // S3100-GNDU
            // EP_ADRS__OUTP_RELAY_WI      = 0x05, // 0x014
            // EP_ADRS__OUTP_RELAY_TI      = 0x45, // 0x114

            // S3100-GNDU
            // EP_ADRS__VM_RANGE_WI        = 0x06, // 0x018
            // EP_ADRS__VM_RANGE_TI        = 0x46, // 0x118

            // S3100-GNDU
            //private u32   EP_ADRS__VDAC_VAL_WI        = 0x09; // 0x024
            //private u32   EP_ADRS__VDAC_CON_TI        = 0x49; // 0x124


            //// S3100-HVSMU

            // S3100-SMU : board control, read ID // shared with CMU
            // EP_ADRS__SMU_WI         = 0x14,
            // EP_ADRS__SMU_WO         = 0x34,

            //LED
            EP_ADRS__HVSMU_TEST_LED_WI            = 0x10, //$$ HVSMU // 0x040
            EP_ADRS__HVSMU_TEST_LED_TI            = 0x50, //$$ HVSMU // 0x140

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
            EP_ADRS__HVSMU_IMODE_WO               = 0x25              // 0x094


        }

        public enum __enum_PGU
        {
            // for CMU
            CMU_brd_cls_id__SIG = 0x8,
            CMU_brd_cls_id__ANL = 0x9,
            
            //
            MAX_CNT = 200 // 2000000 // max counter when checking done trig_out.
                // LAN trans time 1ms ... 200  ... 200ms
                // SPI frame time 7us ... 2000 ... 14ms
                // Soft CPU time 14ns ... 2000000 ... 28ms
            //
        }


        

    }

    public partial class PGU : I_PGU {}
    

}
