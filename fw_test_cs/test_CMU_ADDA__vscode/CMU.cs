//// CMU.cs

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


    //// some common interface
    interface I_CMU
    {
        // for slot functions
        void scan_frame_slot(); // scan slot
        bool search_board_init(s8 slot, u32 fid); //(s8 slot, u32 slot_cs_code, u32 slot_ch_code, u32 fid);
        u32 _SPI_SEL_SLOT(s32 ch); // in S3100 slot 1~12 // ch = 0  => slot = 1
        u32 _SPI_SEL_SLOT_GNDU(); // in S3100-GNDU slot 0 fixed
        u32 _SPI_SEL_CH_SMU();
        u32 _SPI_SEL_CH_GNDU();
        u32 _SPI_SEL_CH_PGU();
        u32 _SPI_SEL_CH_CMU();

        // adda sub-devices
        //...

        // cmu sub-devices
        //...

    }


    //// some common class or enum or struct

    public partial class __CMU_ADDA {}
    public partial class __CMU_SUB {}
    public partial class __CMU 
    {

        public string EP_ADRS__GROUP_STR         = "_S3100_CMU_"; // reserved

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

        //// for SMU compatible
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

    public partial class CMU : I_CMU
    {
        // slot functions
        /*
        public new void scan_frame_slot() // scan slot
        {
            TRACE("----------------------------------------------------------\r\n");            

            // scan slot 0 for GNDU
            if (search_board_init(-1, GetWireOutValue(_SPI_SEL_SLOT_GNDU(), _SPI_SEL_CH_GNDU(), 
                (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF)) == FALSE)
                // nop or more init
                //Console.WriteLine("# <Slot {0,2:d}: Not Detected: GNDU expected>", 0);
                TRACE("# <Not Detect Board on Slot 0>\r\n");

            // scan slot 1 ~ 12
            for(int i = 0; i < 12; i++)
            {
                // search spi ch M0
                if(search_board_init((s8)i, GetWireOutValue(_SPI_SEL_SLOT(i), (u32)__enum_SPI_CBIT.SPI_SEL_M0, 
                    (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;
                // search spi ch M2
                if(search_board_init((s8)i, GetWireOutValue(_SPI_SEL_SLOT(i), (u32)__enum_SPI_CBIT.SPI_SEL_M2, 
                    (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;
                // no board found in this slot
                //Console.WriteLine("# <Slot {0,2:d}: Not Detected: no FID>", i + 1);
                TRACE("# <Not Detect Board on Slot %d>\r\n", i + 1);
            }
        }
        public new bool search_board_init(s8 slot, u32 fid) // (s8 slot, u32 slot_cs_code, u32 slot_ch_code, u32 fid)
        {
            bool rtn = true;
            u8 boardID = (u8)(fid >> 24);

            switch(boardID)
            {
                case (u8)__board_class_id__.S3100_GNDU      :
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100_GNDU, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); // slot 0 fixed
                    //
                    TRACE("# <Detect Board on Slot %d: S3100-GNDU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3000_PGU:			// S3000 PGU
                    TRACE("# <Detect Board on Slot %d: S3000-PGU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3000_CMU:			// S3000 CMU
                    TRACE("# <Detect Board on Slot %d: S3000-CMU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3100_PGU_ADDA  :  // alias S3100_PGU_ADDA, S3100_PGU
                    TRACE("# <Detect Board on Slot %d: S3100-PGU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-PGU-ADDA, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_CMU_ADDA  :  // alias S3100_CMU_ADDA, S3100_ADDA
                    TRACE("# <Detect Board on Slot %d: S3100-CMU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100_CMU_ADDA, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_HVSMU     :	// S3100 HVSMU
                    TRACE("# <Detect Board on Slot %d: S3100-HVSMU, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-HVSMU, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    hvsmu_V_DAC_init((u8)slot);
                    hvsmu_I_DAC_init((u8)slot);
                    //
                    hvsmu_HRADC_enable((u8)slot);
                    break;
                case (u8)__board_class_id__.S3100_PGU_SUB   :  // alias S3100_HVPGU
                    TRACE("# <Detect Board on Slot %d: S3100-PGU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-PGU-SUB, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_CMU_SUB   :	// S3100-CMU-SUB
                    TRACE("# <Detect Board on Slot %d: S3100-CMU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-CMU-SUB, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.E8000_HLSMU   :   // E8000-HVSMU
                    TRACE("# <Detect Board on Slot %d: E8000-HLSMU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                default:
                    rtn = false;
                    //TRACE("# <Not Detect Board on Slot %d>\r\n", slot + 1);
                    //
                    //if ( (fid != 0xFFFFFFFF) && (fid != 0x00000000))
                    //    Console.WriteLine("# <Slot {0,2:d}: Detected: Unknown, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //        slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
            }

            return rtn;
        } 
        public new u32 _SPI_SEL_SLOT(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public new u32 _SPI_SEL_SLOT_GNDU() // in S3100-GNDU slot 0
        {
            //
            return (u32)__slot_cs_code__.SLOT_CS0;
        }
        public new u32 _SPI_SEL_SLOT_SMU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public new u32 _SPI_SEL_SLOT_CMU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public new u32 _SPI_SEL_SLOT_PGU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public new u32 _SPI_SEL_CH_SMU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M0;
        }
        public new u32 _SPI_SEL_CH_GNDU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M0;
        }
        public new u32 _SPI_SEL_CH_PGU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M2;
        }
        public new u32 _SPI_SEL_CH_CMU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M2;
        }
        */

    }

    
}
