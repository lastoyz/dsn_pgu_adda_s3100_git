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

        // adda functions:
        void adda_pwr_on(u32 slot, u32 spi_sel);
        void adda_pwr_off(u32 slot, u32 spi_sel);
        void adda_init(
            u32 slot, u32 spi_sel,
            s32 len_adc_data = 600, u32 adc_sampling_period_count = 21,
            double time_ns__dac_update = 5,
            double DAC_full_scale_current__mA_1 = 25.47      , 
            double DAC_full_scale_current__mA_2 = 25.47      , 
            float DAC_offset_current__mA_1      = (float)0.61, 
            float DAC_offset_current__mA_2      = (float)0.61, 
            int N_pol_sel_1                     = 0          , 
            int N_pol_sel_2                     = 0          , 
            int Sink_sel_1                      = 0          , 
            int Sink_sel_2                      = 0          
        );
        // adda_setup_pgu_waveform()
        // adda_trigger_pgu_output()
        // adda_wait_for_adc_done()
        // adda_trigger_pgu_off()
        // adda_read_adc_buf()

        // cmu functions:
        //... io control

    }
    interface I_spio {}
    interface I_clkd {}
    interface I_dac {}
    interface I_adc {}
    interface I_dft {}
    interface I_dacz {} //?



    //// some common class or enum or struct

    //public partial class __CMU_ADDA {}
    //public partial class __CMU_SUB {}
    public partial class __CMU 
    {

        public string EP_ADRS__GROUP_STR         = "_S3100_CMU_"; // reserved

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

        public enum __enum_CMU
        {
            //
            MAX_CNT = 200 // 2000000 // max counter when checking done trig_out.
                // LAN trans time 1ms ... 200  ... 200ms
                // SPI frame time 7us ... 2000 ... 14ms
                // Soft CPU time 14ns ... 2000000 ... 28ms
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
        // slot functions :
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

        //// adda functions :
        public void adda_pwr_on(u32 slot, u32 spi_sel) {
            
            // spio init for power control : adc power on, dac power on, output relay on

            u32 val;

            // powers on
            val = sp1_ext_init(slot, spi_sel, 1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay_ms(1); // 1ms

            // output relay on
            val = sp1_ext_init(slot, spi_sel, 1,1,1,1,1,1); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay_ms(5); // 5ms

        }

        public void adda_pwr_off(u32 slot, u32 spi_sel) {

            // relay off
            sp1_ext_init(slot, spi_sel, 1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

            // delay 
            Delay_ms(5); // 5ms

            // powers off
            sp1_ext_init(slot, spi_sel, 0,0,0,0,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

        }


        public void adda_init(
            u32 slot, u32 spi_sel,
            s32 len_adc_data = 600, u32 adc_sampling_period_count = 21,
            double time_ns__dac_update = 5,
            double DAC_full_scale_current__mA_1 = 25.47      , 
            double DAC_full_scale_current__mA_2 = 25.47      , 
            float DAC_offset_current__mA_1      = (float)0.61, 
            float DAC_offset_current__mA_2      = (float)0.61, 
            int N_pol_sel_1                     = 0          , 
            int N_pol_sel_2                     = 0          , 
            int Sink_sel_1                      = 0          , 
            int Sink_sel_2                      = 0          
        ) {
            /* to come ...
            // adc setup
            //s32 len_adc_data = 600; // adc samples
            //u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
            adc_enable(); // 210MHz base freq
            adc_init(len_adc_data, adc_sampling_period_count); // init with setup parameters
            adc_reset_fifo(); // clear fifo for new data

            // dac setup
            //double time_ns__dac_update = 5; // 200MHz dac update
            ////double time_ns__dac_update = 10; // 100MHz dac update
            //double DAC_full_scale_current__mA_1 = 25.50;       // for BD2
            //double DAC_full_scale_current__mA_2 = 25.45;       // for BD2
            //float DAC_offset_current__mA_1      = (float)0.44; // for BD2
            //float DAC_offset_current__mA_2      = (float)0.79; // for BD2
            //int N_pol_sel_1                     = 0;           // for BD2
            //int N_pol_sel_2                     = 0;           // for BD2
            //int Sink_sel_1                      = 0;           // for BD2
            //int Sink_sel_2                      = 0;           // for BD2
            //
            dac_init(time_ns__dac_update,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2
            ); 
            */
        }


    }


    public partial class CMU : I_spio
    {
        //
        public u32 sp1_ext_init(u32 slot, u32  spi_sel, u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0) {
            //...
            u32 dir_read;
            u32 lat_read;
            u32 inp_read;

            // SP1 pin map:
            //  SP1_GPB7 = AUX_CS_B           // o
            //  SP1_GPB6 = AUX_SCLK           // o    
            //  SP1_GPB5 = AUX_MOSI           // o    
            //  SP1_GPB4 = AUX_MISO           // i    
            //  SP1_GPB3 = USER_LED           // o    
            //  SP1_GPB2 = PWR_ANAL_DAC_ON    // o           
            //  SP1_GPB1 = PWR_ANAL_ON (ADC)  // o             
            //  SP1_GPB0 = PWR_AMP_ON         // o  // reserved // with pwr_amp
            //
            //  SP1_GPA7 = SLOT_ID3_BUF       // i        
            //  SP1_GPA6 = SLOT_ID2_BUF       // i        
            //  SP1_GPA5 = SLOT_ID1_BUF       // i        
            //  SP1_GPA4 = SLOT_ID0_BUF       // i        
            //  SP1_GPA3 = NA                 // i
            //  SP1_GPA2 = PWR_AMP_DAC_ON     // i  // 5/-5V dac amp power enable // shared with pwr_amp
            //  SP1_GPA1 = SW_RL_K2           // o    
            //  SP1_GPA0 = SW_RL_K1           // o    

            //
            //# read IO direction 
            //# check IO direction : (SPA,SPB)
            dir_read = sp1_reg_read_b16(slot, spi_sel, 0x00); // 0 for out, 1 for in.

            //# read output Latch
            lat_read = sp1_reg_read_b16(slot, spi_sel, 0x14);
            
            //# set IO direction for SP1 PA[2:0] - output // PA[1:0] --> PA[2:0]
            //# set IO direction for SP1 PB[7:5] - output
            //# set IO direction for SP1 PB[3:0] - output
            //sp1_reg_write_b16(0x00, dir_read & 0xFC10);
            sp1_reg_write_b16(slot, spi_sel, 0x00, dir_read & 0xF810);
            
            //# set IO for SP1 PB[3:0]
            //u32 val = (lat_read & 0xFFF0) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));
            //u32 val = (lat_read & 0xFCF0) | ( (sw_relay_k2<<9) + (sw_relay_k1<<8) ) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));
            u32 val = (lat_read & 0xFCF0) | ( (pwr_amp<<10) + (sw_relay_k2<<9) + (sw_relay_k1<<8) ) | 
                                            ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));

            sp1_reg_write_b16(slot, spi_sel, 0x12,val);

            // power stability delay 
            Delay_ms(10); // 10ms

            // read IO 
            inp_read = sp1_reg_read_b16(slot, spi_sel, 0x12);
            return inp_read & 0xFFFF;
        }
    
        private u32 sp1_reg_read_b16(u32 slot, u32  spi_sel, u32 reg_adrs_b8) {
            u32 val_b16    = 0;
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 1; // read
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return spio_send_spi_frame(slot, spi_sel, framedata);
        }
        private u32 sp1_reg_write_b16(u32 slot, u32  spi_sel, u32 reg_adrs_b8, u32 val_b16) {
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 0; // write
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return spio_send_spi_frame(slot, spi_sel, framedata);
        }

        private u32 spio_send_spi_frame(u32 slot, u32  spi_sel, u32 frame_data) {
            //# write control 
            SetWireInValue(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__SPIO_WI, frame_data);  //# (ep,val,mask)

            //# trig spi frame
            //#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
            ActivateTriggerIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__SPIO_TI, 1); //# (ep,bit) 
            
            //# check spi frame done
            //#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            while (true) {
            	flag = GetWireOutValue(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__SPIO_WO);
            	flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
            		break;
            }

            //# read received data 
            //#   assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
            //#   assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
            u32 val_recv = flag & 0x0000FFFF;
            return val_recv;
        }        

    }
    public partial class CMU : I_clkd {}
    public partial class CMU : I_dac {}
    public partial class CMU : I_adc {}
    public partial class CMU : I_dft {}


}
