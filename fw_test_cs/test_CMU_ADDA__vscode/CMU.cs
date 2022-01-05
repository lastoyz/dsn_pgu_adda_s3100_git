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
        // adda_init()
        void adda_init(
            u32 slot, u32 spi_sel, //$$ for FW
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
        Tuple<long[], double[], double[]>  adda_setup_pgu_waveform(
            u32 slot, u32 spi_sel, //$$ for FW
            long[] StepTime_ns, double[] StepLevel_V, 
            int    output_range                    = 10,
            int    time_ns__code_duration          = 5,
            double load_impedance_ohm              = 1e6,                       
            double output_impedance_ohm            = 50,                        
            double scale_voltage_10V_mode          = 0.765, //8.5/10, // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 4, //3.64, // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0,
            double out_offset                      = 0.0,
            int num_repeat_pulses                  = 4   // repeat pulse
        );

        // adda_trigger_pgu_output()
        void adda_trigger_pgu_output(u32 slot, u32 spi_sel);

        // adda_wait_for_adc_done()
        void adda_wait_for_adc_done(u32 slot, u32 spi_sel);

        // adda_trigger_pgu_off()
        void adda_trigger_pgu_off(u32 slot, u32 spi_sel);

        // adda_read_adc_buf()
        void adda_read_adc_buf(u32 slot, u32 spi_sel,
            s32 len_adc_data = 600, string buf_time_str = "", string buf_dac0_str = "", string buf_dac1_str ="");

        // adda_compute_dft() //$$ new
        void adda_compute_dft();

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
            val = sp1_ext_init(slot, spi_sel, 
                1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay_ms(1); // 1ms

            // output relay on
            val = sp1_ext_init(slot, spi_sel, 
                1,1,1,1,1,1); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay_ms(5); // 5ms

        }

        public void adda_pwr_off(u32 slot, u32 spi_sel) {

            // relay off
            sp1_ext_init(slot, spi_sel, 
                1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

            // delay 
            Delay_ms(5); // 5ms

            // powers off
            sp1_ext_init(slot, spi_sel, 
                0,0,0,0,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

        }

        // adda_init()
        public void adda_init(u32 slot, u32 spi_sel, 
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
            // adc setup
            adc_enable(slot, spi_sel,  210); // 210MHz base freq
            adc_init(slot, spi_sel,  len_adc_data, adc_sampling_period_count); // init with setup parameters
            adc_reset_fifo(slot, spi_sel); // clear fifo for new data

            // dac setup
            dac_init(slot, spi_sel,  
                time_ns__dac_update,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2
            ); 
            
        }

        // adda_setup_pgu_waveform()
        public Tuple<long[], double[], double[]>  adda_setup_pgu_waveform(
            u32 slot, u32 spi_sel, //$$ for FW
            long[] StepTime_ns, double[] StepLevel_V, 
            int    output_range                    = 10,
            int    time_ns__code_duration          = 5,
            double load_impedance_ohm              = 1e6,                       
            double output_impedance_ohm            = 50,                        
            double scale_voltage_10V_mode          = 0.765, //8.5/10, // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 4, //3.64, // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0,
            double out_offset                      = 0.0,
            int num_repeat_pulses                  = 4   // repeat pulse
        ) {
            //
            return Tuple.Create(StepTime_ns, StepLevel_V, StepLevel_V); // for test

            /*
            // DAC waveform command generation : time, dac0, dac1
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1
            time_volt_dual_list = dac_gen_pulse_cmd(StepTime_ns, StepLevel_V);

            // DAC0 FIFO data generation
            var ret__dac0_fifo_dat = dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item2,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            );  

            // DAC1 FIFO data generation
            var ret__dac1_fifo_dat = dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item3,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            ); 

            s32[] dac0_code_inc_value__s32_buf = ret__dac0_fifo_dat.Item1;
            u32[] dac0_code_duration__u32_buf  = ret__dac0_fifo_dat.Item2;
            s32[] dac1_code_inc_value__s32_buf = ret__dac1_fifo_dat.Item1;
            u32[] dac1_code_duration__u32_buf  = ret__dac1_fifo_dat.Item2;

            ////
            // DAC pulse download
            Console.WriteLine(">>>>>> DAC0 download");
            dac_set_fifo_dat(
                1, num_repeat_pulses,
                dac0_code_inc_value__s32_buf, dac0_code_duration__u32_buf);
            Console.WriteLine(">>>>>> DAC1 download");
            dac_set_fifo_dat(
                2, num_repeat_pulses,
                dac1_code_inc_value__s32_buf, dac1_code_duration__u32_buf);
            Console.WriteLine(">>>>>> download done!");

            return time_volt_dual_list; // for log data
            */
        }

        // adda_trigger_pgu_output()
        public void adda_trigger_pgu_output(u32 slot, u32 spi_sel) {
            //// trigger linked DAC wave and adc update 
            //dac_set_trig(true, true, true); // (bool Ch1, bool Ch2, bool force_adc_trig = false) 
        }

        // adda_wait_for_adc_done()
        public void adda_wait_for_adc_done(u32 slot, u32 spi_sel) {
            //adc_update_check(); // check done without triggering // vs. adc_update() with triggering
            //Console.WriteLine(">>>>>> ADC update done");

        }

        // adda_trigger_pgu_off()
        public void adda_trigger_pgu_off(u32 slot, u32 spi_sel) {
            //// clear DAC wave
            //dac_reset_trig();
            //Console.WriteLine(">>>>>> PGU trigger off");
        }

        // adda_read_adc_buf()
        public void adda_read_adc_buf(u32 slot, u32 spi_sel, 
            s32 len_adc_data = 600, string buf_time_str = "", string buf_dac0_str = "", string buf_dac1_str ="") {            
            //// fifo data read 
            //s32[] adc0_s32_buf = new s32[len_adc_data];
            //s32[] adc1_s32_buf = new s32[len_adc_data];
            //Console.WriteLine(">>>>>> ADC0 FIFO read");
            //adc_get_fifo(0, len_adc_data, adc0_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            //Console.WriteLine(">>>>>> ADC1 FIFO read");
            //adc_get_fifo(1, len_adc_data, adc1_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            //// log fifo data into a file
            //Console.WriteLine(">>>>>> write ADC log file");
            //adc_log("log__adc_buf__dac.py".ToCharArray(), 
            //    len_adc_data, adc0_s32_buf, adc1_s32_buf,
            //    buf_time_str, buf_dac0_str, buf_dac1_str); 
        }

        // adda_compute_dft() //$$ new
        public void adda_compute_dft() {}

    }


    public partial class CMU : I_spio
    {
        //
        public u32 sp1_ext_init(u32 slot, u32  spi_sel, 
            u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0) {
            //
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
    
        private u32 sp1_reg_read_b16(u32 slot, u32  spi_sel, 
            u32 reg_adrs_b8) {
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
        private u32 sp1_reg_write_b16(u32 slot, u32  spi_sel, 
            u32 reg_adrs_b8, u32 val_b16) {
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

        private u32 spio_send_spi_frame(u32 slot, u32  spi_sel, 
            u32 frame_data) {
            //# write control 
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__SPIO_WI, frame_data);  //# (ep,val,mask)

            //# trig spi frame
            //#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
            ActivateTriggerIn(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__SPIO_TI, 1); //# (ep,bit) 
            
            //# check spi frame done
            //#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            while (true) {
            	flag = GetWireOutValue(slot, spi_sel, 
                        (u32)__enum_EPA.EP_ADRS__SPIO_WO);
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
    public partial class CMU : I_dac 
    {
        //
        private void dac_init(u32 slot, u32 spi_sel, 
            double time_ns__dac_update = 5,
            double DAC_full_scale_current__mA_1 = 25.5,
            double DAC_full_scale_current__mA_2 = 25.5,
            float  DAC_offset_current__mA_1     = (float)0.0,
            float  DAC_offset_current__mA_2     = (float)0.0,
            int    N_pol_sel_1                  = 0,
            int    N_pol_sel_2                  = 0,
            int    Sink_sel_1                   = 0,
            int    Sink_sel_2                   = 0
        ) {
            //// calculate parameters
            int pgu_freq_in_100kHz = Convert.ToInt32(1 / (time_ns__dac_update * 1e-9) / 100000);
            u32 val = (u32)pgu_freq_in_100kHz;
            // DACX fpga pll reset
            pgu_dacx_fpga_pll_rst(slot, spi_sel,  1, 1, 1);
            // CLKD init
            pgu_clkd_init(slot, spi_sel);
            // CLKD freq setup 
            pgu_clkd_setup(slot, spi_sel,  val);
            // DACX init 
            pgu_dacx_init(slot, spi_sel);
            // DACX fpga pll run
            pgu_dacx_fpga_pll_rst(slot, spi_sel,  0, 0, 0);
            pgu_dacx_fpga_clk_dis(slot, spi_sel,  0, 0);
            // wait for pll stable
            Delay_ms(1); // 1ms
            //$$ DAC device input delay tap calibration 
            if (time_ns__dac_update <= 5) // conduct dac input delay tap check only when update rate >= 200MHz.
                dac__dev_cal_dtap(slot, spi_sel);
            else
                dac__dev_set_dtap(slot, spi_sel,  (u32)0, (u32)0); // set 0 taps
            //$$ DAC device full-scale current, offset setup
            pgu__setup_gain_offset(slot, spi_sel,  
                1, 
                DAC_full_scale_current__mA_1, DAC_offset_current__mA_1, 
                N_pol_sel_1, Sink_sel_1);
            pgu__setup_gain_offset(slot, spi_sel,  
                2, 
                DAC_full_scale_current__mA_2, DAC_offset_current__mA_2, 
                N_pol_sel_2, Sink_sel_2);
        }
        //
        private u32  pgu_dacx_fpga_pll_rst(u32 slot, u32 spi_sel, 
            u32 clkd_out_rst, u32 dac0_dco_rst, u32 dac1_dco_rst) 
        {
            u32 control_data;
            u32 status_pll;
            // control data
            control_data = (dac1_dco_rst<<30) + (dac0_dco_rst<<29) + (clkd_out_rst<<28);
            // write control 
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, control_data, 0x70000000);
            SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_WI, control_data, 0x70000000);
            // read status
            //   assign w_TEST_IO_MON[31] = S_IO_2; //
            //   assign w_TEST_IO_MON[30] = S_IO_1; //
            //   assign w_TEST_IO_MON[29] = S_IO_0; //
            //   assign w_TEST_IO_MON[28:27] =  2'b0;
            //   assign w_TEST_IO_MON[26] = dac1_dco_clk_locked;
            //   assign w_TEST_IO_MON[25] = dac0_dco_clk_locked;
            //   assign w_TEST_IO_MON[24] = clk_dac_locked;
            //
            //   assign w_TEST_IO_MON[23:20] =  4'b0;
            //   assign w_TEST_IO_MON[19] = clk4_locked;
            //   assign w_TEST_IO_MON[18] = clk3_locked;
            //   assign w_TEST_IO_MON[17] = clk2_locked;
            //   assign w_TEST_IO_MON[16] = clk1_locked;
            //
            //   assign w_TEST_IO_MON[15: 0] = 16'b0;	
            //
            //status_pll = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__TEST_IO_MON, 0x07000000);
            status_pll = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__TEST_MON_WO, 0x07000000);
            //
            return status_pll;
        }        //
        //
        private u32  pgu_dacx_fpga_clk_dis(u32 slot, u32 spi_sel, 
            u32 dac0_clk_dis, u32 dac1_clk_dis) 
        {
            u32 ret = 0;
            u32 control_data;
            // control data
            control_data = (dac1_clk_dis<<27) + (dac0_clk_dis<<26);
            // write control 
            SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_WI, control_data, (0x03 << 26));
            return ret;
        }
        //
        private u32  pgu_dacx_init(u32 slot, u32 spi_sel) 
        {
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_TI, 0);
            //
            u32 cnt_done = 0    ;
            s32 bit_loc  = 24   ;
            u32 flag            ;
            u32 flag_done       ;
            //
            while (true) {
                flag = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_WO);
                flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
            		break;
            }
            //
            return flag_done;
        }
        //
        private void dac__dev_set_dtap(u32 slot, u32 spi_sel, 
            u32 val_dac0_dtap, u32 val_dac1_dtap) 
        {
            // input delay tap 0 ~ 31
            pgu_dac0_reg_write_b8(slot, spi_sel,  0x05, (u32)val_dac0_dtap);
            pgu_dac1_reg_write_b8(slot, spi_sel,  0x05, (u32)val_dac1_dtap);
        }
        //
        private u32  dac__dev_cal_dtap(u32 slot, u32 spi_sel) { 
            //$$ dac input delay tap calibration
            //$$   set initial smp value for input delay tap : try 8
            //     https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
            //           
            //     The nominal step size for SET and HLD is 80 ps. 
            //     The nominal step size for SMP is 160 ps.
            //
            //     400MHz 2.5ns 2500ps  ... 1/3 position ... SMP 2500/160/3 ~ 7.8
            //     400MHz 2.5ns 2500ps  ... 1/2 position ... SMP 2500/160/3 ~ 5
            //     200MHz 5ns   5000ps  ... 1/3 position ... SMP 5000/160/3 ~ 10
            //     200MHz 5ns   5000ps  ... 1/4 position ... SMP 5000/160/4 ~ 7.8
            //
            //     build timing data array
            //       SMP n, SET 0, HLD 0, ... record SEEK
            //       SMP n, SET 0, HLD increasing until SEEK toggle ... to find the hold time 
            //       SMP n, HLD 0, SET increasing until SEEK toggle ... to find the setup time 
            //
            //    simple method 
            //       SET 0, HLD 0, SMP increasing ... record SEEK bit
            //       find the center of SMP of the first SEEK high range.
            //
            // SET  = BIT[7:4] @ 0x04
            // HLD  = BIT[3:0] @ 0x04
            // SMP  = BIT[4:0] @ 0x05
            // SEEK = BIT[0]   @ 0x06
            s32 val;
            s32 val_0_pre = 0;
            s32 val_1_pre = 0;
            s32 val_0 = 0;
            s32 val_1 = 0;
            s32 ii;
            s32 val_0_seek_low = -1; // loc of rise
            s32 val_0_seek_hi  = -1; // loc of fall
            s32 val_1_seek_low = -1; // loc of rise
            s32 val_1_seek_hi  = -1; // loc of fall
            s32 val_0_center   = 0; 
            s32 val_1_center   = 0; 
            //// new try: weighted sum approach
            u32 val_0_seek_low_found = 0;
            u32 val_0_seek_hi__found = 0;
            s32 val_0_seek_w_sum     = 0;
            s32 val_0_seek_w_sum_fin = 0;
            s32 val_0_cnt_seek_hi    = 0;
            s32 val_0_center_new     = 0;
            u32 val_1_seek_low_found = 0;
            u32 val_1_seek_hi__found = 0;
            s32 val_1_seek_w_sum     = 0;
            s32 val_1_seek_w_sum_fin = 0;
            s32 val_1_cnt_seek_hi    = 0;
            s32 val_1_center_new     = 0;
            xil_printf(">>>>>> pgu_dacx_cal_input_dtap: \r\n");
            ii=0;
            // make timing table:
            //  SMP  DAC0_SEEK  DAC1_SEEK 
            xil_printf("+-----++-----------+-----------+\r\n");
            xil_printf("| SMP || DAC0_SEEK | DAC1_SEEK |\r\n");
            xil_printf("+-----++-----------+-----------+\r\n");
            //
            while (true) {
                //
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x05, (u32)ii); // test SMP
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x05, (u32)ii); // test SMP
                //
                val       = (s32)pgu_dac0_reg_read_b8(slot, spi_sel,  0x06);
                val_0_pre = val_0;
                val_0     = val & 0x01;
                //xil_printf("read dac0 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
                val       = (s32)pgu_dac1_reg_read_b8(slot, spi_sel,  0x06);
                val_1_pre = val_1;
                val_1     = val & 0x01;
                //xil_printf("read dac1 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);

                // report
                xil_printf("| %3d || %9d | %9d |\r\n", ii, val_0, val_1);

                // detection rise and fall
                if (val_0_seek_low == -1 && val_0_pre==0 && val_0==1)
                    val_0_seek_low = ii;
                if (val_0_seek_hi  == -1 && val_0_pre==1 && val_0==0)
                    val_0_seek_hi  = ii-1;
                if (val_1_seek_low == -1 && val_1_pre==0 && val_1==1)
                    val_1_seek_low = ii;
                if (val_1_seek_hi  == -1 && val_1_pre==1 && val_1==0)
                    val_1_seek_hi  = ii-1;

                //// new try 
                if (val_0_seek_low_found == 0 && val_0==0)
                    val_0_seek_low_found = 1;
                if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 0 && val_0==1)
                    val_0_seek_hi__found = 1;
                if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 1 && val_0==0)
                    val_0_seek_w_sum_fin = 1;
                if (val_0_seek_hi__found == 1 && val_0_seek_w_sum_fin == 0) {
                    val_0_seek_w_sum    += ii;
                    val_0_cnt_seek_hi   += 1;
                }
                if (val_1_seek_low_found == 0 && val_1==0)
                    val_1_seek_low_found = 1;
                if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 0 && val_1==1)
                    val_1_seek_hi__found = 1;
                if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 1 && val_1==0)
                    val_1_seek_w_sum_fin = 1;
                if (val_1_seek_hi__found == 1 && val_1_seek_w_sum_fin == 0) {
                    val_1_seek_w_sum    += ii;
                    val_1_cnt_seek_hi   += 1;
                }

                if (ii==31) 
                    break;
                else 
                    ii=ii+1;
            }
            xil_printf("+-----++-----------+-----------+\r\n");
            // check windows 
            if (val_0_seek_low == -1) val_0_seek_low = 31;
            if (val_0_seek_hi  == -1) val_0_seek_hi  = 31;
            if (val_1_seek_low == -1) val_1_seek_low = 31;
            if (val_1_seek_hi  == -1) val_1_seek_hi  = 31;
            //
            val_0_center = (val_0_seek_low + val_0_seek_hi)/2;
            val_1_center = (val_1_seek_low + val_1_seek_hi)/2;
            //
            xil_printf(" > val_0_seek_low : %02d \r\n", val_0_seek_low);
            xil_printf(" > val_0_seek_hi  : %02d \r\n", val_0_seek_hi );
            xil_printf(" > val_0_center   : %02d \r\n", val_0_center  );
            xil_printf(" > val_1_seek_low : %02d \r\n", val_1_seek_low);
            xil_printf(" > val_1_seek_hi  : %02d \r\n", val_1_seek_hi );
            xil_printf(" > val_1_center   : %02d \r\n", val_1_center  );
            //// new try 
            if (val_0_cnt_seek_hi>0) val_0_center_new = val_0_seek_w_sum / val_0_cnt_seek_hi;
            else                     val_0_center_new = 0; //15; // no seek_hi
            if (val_1_cnt_seek_hi>0) val_1_center_new = val_1_seek_w_sum / val_1_cnt_seek_hi;
            else                     val_1_center_new = 0; //15; // no seek_hi
            //// add more for too few seek_hi
            if (val_0_cnt_seek_hi>0 && val_0_cnt_seek_hi<8) val_0_center_new = 0; // few seek_hi
            if (val_1_cnt_seek_hi>0 && val_1_cnt_seek_hi<8) val_1_center_new = 0; // few seek_hi
            //
            xil_printf(" >>>> weighted sum \r\n");
            xil_printf(" > val_0_seek_w_sum  : %02d \r\n", val_0_seek_w_sum  );
            xil_printf(" > val_0_cnt_seek_hi : %02d \r\n", val_0_cnt_seek_hi );
            xil_printf(" > val_0_center_new  : %02d \r\n", val_0_center_new  );
            xil_printf(" > val_1_seek_w_sum  : %02d \r\n", val_1_seek_w_sum  );
            xil_printf(" > val_1_cnt_seek_hi : %02d \r\n", val_1_cnt_seek_hi );
            xil_printf(" > val_1_center_new  : %02d \r\n", val_1_center_new  );
            //
            dac__dev_set_dtap(slot, spi_sel,  (u32)val_0_center_new, (u32)val_1_center_new);
            //
            xil_printf(">>> DAC input delay taps are chosen at each center\r\n");
            return 0;
        }
        //
        private u32  pgu_dac0_reg_write_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b5, u32 val_b8) 
        {
            //
            u32 CS_id       = 0          ;
            u32 R_W_bar     = 0          ;
            u32 byte_mode_N = 0x0        ;
            u32 reg_adrs    = reg_adrs_b5;
            u32 val         = val_b8     ;
            //
            u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
            //
            return pgu_dacx_send_spi_frame(slot, spi_sel,  framedata);
        }
        //
        private u32  pgu_dac0_reg_read_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b5) 
        {
            //
            u32 CS_id       = 0          ;
            u32 R_W_bar     = 1          ;
            u32 byte_mode_N = 0x0        ;
            u32 reg_adrs    = reg_adrs_b5;
            u32 val         = 0xFF       ;
            //
            u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
            //
            return pgu_dacx_send_spi_frame(slot, spi_sel,  framedata);
        }        //
        //
        private u32  pgu_dac1_reg_write_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b5, u32 val_b8) 
        {
            //
            u32 CS_id       = 1          ;
            u32 R_W_bar     = 0          ;
            u32 byte_mode_N = 0x0        ;
            u32 reg_adrs    = reg_adrs_b5;
            u32 val         = val_b8     ;
            //
            u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
            //
            return pgu_dacx_send_spi_frame(slot, spi_sel,  framedata);
        }
        //
        private u32  pgu_dac1_reg_read_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b5) 
        {
            //
            u32 CS_id       = 1          ;
            u32 R_W_bar     = 1          ;
            u32 byte_mode_N = 0x0        ;
            u32 reg_adrs    = reg_adrs_b5;
            u32 val         = 0xFF       ;
            //
            u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
            //
            return pgu_dacx_send_spi_frame(slot, spi_sel,  framedata);
        }        
        //
        private u32  pgu_dacx_send_spi_frame(u32 slot, u32 spi_sel, 
            u32 frame_data) 
        {
            // write control 
            SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_WI, frame_data);
            // trig spi frame
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_TI, 1);
            // check spi frame done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            //while True:
            while (true) {
                flag = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACX_WO);
                flag_done = (flag>>bit_loc) & 0x00000001;
                if (flag_done==1)
                    break;
                cnt_done += 1;
                if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
                    break;
            }
            u32 val_recv = flag & 0x000000FF;
            return val_recv;
        }
        //
        private void pgu__setup_gain_offset(u32 slot, u32 spi_sel, 
            int Ch, 
            double DAC_full_scale_current__mA = 25.5, float DAC_offset_current__mA = 0, 
            int N_pol_sel = 1, int Sink_sel = 1) {
            //$$ double DAC_full_scale_current__mA = 25.5; // 20.1Vpp
            pgu_gain__send(slot, spi_sel, 
                Ch, DAC_full_scale_current__mA);
            //$$ float DAC_offset_current__mA = 0; // 0 min // # 0.625 mA
            //float DAC_offset_current__mA = 1; // 
            //float DAC_offset_current__mA = 2; // 2 max
            //$$ int N_pol_sel = 1; // 1
            //$$ int Sink_sel = 1; // 1
            pgu_ofst__send(slot, spi_sel, 
                Ch, DAC_offset_current__mA, N_pol_sel, Sink_sel);
        }
        //
        public void pgu_gain__send(u32 slot, u32 spi_sel, 
            int Ch, double DAC_full_scale_current__mA = 25.5) 
        {
            //// calculate parameters // from https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
            double I_FS__mA = DAC_full_scale_current__mA; //$$ 8.66 ~ 31.66mA
            double R_FS__ohm = 10e3; // from schematic
            int DAC_gain = Convert.ToInt32((I_FS__mA / 1000 * R_FS__ohm - 86.6) / 0.220 + 0.5);
            // ((25.5 / 1000 * 10e3 - 86.6) / 0.220 + 0.5) = 765.954545455 ~ 0x2FD
            //// for firmware
            u32 val       = (u32)DAC_gain;
            u32 val1_high;
            u32 val1_low;
            u32 val0_high;
            u32 val0_low;
            // resolve data
            val1_high = (val>>24) & 0x000000FF;
            val1_low  = (val>>16) & 0x000000FF;
            val0_high = (val>> 8) & 0x000000FF;
            val0_low  = (val>> 0) & 0x000000FF;
            // set data
            if (Ch == 1) { // Ch == 1 or DAC0
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x0C, val1_high);
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x0B, val1_low );
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x10, val0_high);
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x0F, val0_low );
            } else {
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x0C, val1_high);
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x0B, val1_low );
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x10, val0_high);
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x0F, val0_low );
            }
        }
        //
        public void pgu_ofst__send(u32 slot, u32 spi_sel, 
            int Ch, float DAC_offset_current__mA = 0, int N_pol_sel = 1, int Sink_sel = 1) 
        {
            //// calculate parameters
            //int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200 + 0.5);
            int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200);
            // 0x3FF, sets output current to 2.0 mA.
            // 0x200, sets output current to 1.0 mA.
            // 0x000, sets output current to 0.0 mA.
            //
            //if DAC_offset_current__code > 0x3FF :
            //print('>>> please check the offset current: {}'.format(DAC_offset_current__mA))
            //raise
            if (DAC_offset_current__code > 0x3FF) {
                DAC_offset_current__code = 0x3FF; // max
            }
            // compose
            int DAC_offset = (N_pol_sel << 15) + (Sink_sel << 14) + DAC_offset_current__code;
            //// for firmware
            u32 val       = (u32)DAC_offset;
            u32 val1_high;
            u32 val1_low;
            u32 val0_high;
            u32 val0_low;
            // resolve data
            val1_high = (val>>24) & 0x000000FF;
            val1_low  = (val>>16) & 0x000000FF;
            val0_high = (val>> 8) & 0x000000FF;
            val0_low  = (val>> 0) & 0x000000FF;
            // set data
            if (Ch == 1) { // Ch == 1 or DAC0
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x0E, val1_high); // AUXDAC1 MSB
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x0D, val1_low ); // AUXDAC1
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x12, val0_high); // AUXDAC2 MSB
                pgu_dac0_reg_write_b8(slot, spi_sel,  0x11, val0_low ); // AUXDAC2
            } else {
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x0E, val1_high);
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x0D, val1_low );
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x12, val0_high);
                pgu_dac1_reg_write_b8(slot, spi_sel,  0x11, val0_low );
            }

        }
        //
    }
    public partial class CMU : I_clkd 
    {
        //
        private u32  pgu_clkd_init(u32 slot, u32 spi_sel) 
        {
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__CLKD_TI, 0);
            //
            u32 cnt_done = 0    ;
            s32 bit_loc  = 24   ;
            u32 flag            ;
            u32 flag_done       ;
            //
            while (true) {
            	flag = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__CLKD_WO);
                flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
            		break;
            }
            //
            return flag_done;
        }
        //
        private u32  pgu_clkd_setup(u32 slot, u32 spi_sel, 
            u32 freq_preset) 
        {
            u32 ret = freq_preset;
            u32 tmp = 0;
            // write conf : SDO active 0x99
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x000,0x99);
            // read conf 
            tmp += pgu_clkd_reg_read_b8_check(slot, spi_sel,  0x000, 0x99); // readback 0x99
            // read ID
            tmp += pgu_clkd_reg_read_b8_check(slot, spi_sel,  0x003, 0x41); // read ID 0x41 
            // power down for output ports
            // ## LVPECL outputs:
            // ##   0x0F0 OUT0 ... 0x0A for power down; 0x08 for power up.
            // ##   0x0F1 OUT1 ... 0x0A for power down; 0x08 for power up.
            // ##   0x0F2 OUT2 ... 0x0A for power down; 0x08 for power up. // TO DAC 
            // ##   0x0F3 OUT3 ... 0x0A for power down; 0x08 for power up. // TO DAC 
            // ##   0x0F4 OUT4 ... 0x0A for power down; 0x08 for power up.
            // ##   0x0F5 OUT5 ... 0x0A for power down; 0x08 for power up.
            // ## LVDS outputs:
            // ##   0x140 OUT6 ... 0x43 for power down; 0x42 for power up. // TO REF OUT
            // ##   0x141 OUT7 ... 0x43 for power down; 0x42 for power up.
            // ##   0x142 OUT8 ... 0x43 for power down; 0x42 for power up. // TO FPGA
            // ##   0x143 OUT9 ... 0x43 for power down; 0x42 for power up.
            // ##
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F0,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F1,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F2,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F3,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F4,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F5,0x0A);
            // ##
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x140,0x43);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x141,0x43);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x142,0x43);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x143,0x43);
            // update registers // no readback
            pgu_clkd_reg_write_b8(slot, spi_sel,  0x232,0x01); 
            //// clock distribution setting
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x010,0x7D); //# PLL power-down

            if (freq_preset == 4000) { // 400MHz // OK
            	//# 400MHz common = 400MHz/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x01); //# Bypass VCO divider # for 400MHz common clock 
            	//
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
            }
            else if (freq_preset == 2000) { // 200MHz // OK
            	//# 200MHz common = 400MHz/(2+0)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
            }
            else if (freq_preset == 1000) { // 100MHz // OK
            	//# 100MHz common = 400MHz/(2+2)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x02); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
            }
            else if (freq_preset == 800) { // 80MHz //OK
            	//# 80MHz common = 400MHz/(2+3)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
            }
            else if (freq_preset == 500) { // 50MHz //OK
            	//# 200MHz common = 400MHz/(2+0)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/4
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x00); //# DVD1 bypass off 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x199,0x00); //# DVD3.1 div 2+0+0=2 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19E,0x00); //# DVD4.1 div 2+0+0=2 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
            }
            else if (freq_preset == 200) { // 20MHz //OK
            	//# 80MHz common = 400MHz/(2+3)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/4  
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x00); //# DVD1 bypass off 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x199,0x00); //# DVD3.1 div 2+0+0=2 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19E,0x00); //# DVD4.1 div 2+0+0=2 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
            }
            else {
            	// return 0
            	ret = 0;
            	//# 200MHz common = 400MHz/(2+0)
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
            	// ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
            	tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
            }
            // power up for clock outs
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F0,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F1,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F2,0x08); //$$ power up
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F3,0x08); //$$ power up
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F4,0x0A);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x0F5,0x0A);
            // ##
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x140,0x42); //$$ power up
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x141,0x43);
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x142,0x42); //$$ power up
            tmp += pgu_clkd_reg_write_b8_check(slot, spi_sel,  0x143,0x43);
            //
            // update registers // no readback
            pgu_clkd_reg_write_b8(slot, spi_sel,  0x232,0x01); 
            // check if retry count > 0
            if (tmp>0) {
            	ret = 0;
            }
            return ret;
        }
        //
        private u32  pgu_clkd_reg_write_b8_check (u32 slot, u32 spi_sel, 
            u32 reg_adrs_b10, u32 val_b8) 
        {
            u32 tmp;
            u32 retry_count = 0;
            while(true) {
            	// write 
            	pgu_clkd_reg_write_b8(slot, spi_sel,  reg_adrs_b10, val_b8);
            	// readback
            	tmp = pgu_clkd_reg_read_b8(slot, spi_sel,  reg_adrs_b10); // readback 0x18
            	if (tmp == val_b8) 
            		break;
            	retry_count++;
            }
            return retry_count;
        }
        //
        private u32  pgu_clkd_reg_read_b8_check (u32 slot, u32 spi_sel, 
            u32 reg_adrs_b10, u32 val_b8) 
        {
            u32 tmp;
            u32 retry_count = 0;
            while(true) {
            	// read
            	tmp = pgu_clkd_reg_read_b8(slot, spi_sel,  reg_adrs_b10); // readback 0x18
            	if (tmp == val_b8) 
            		break;
            	retry_count++;
            }
            return retry_count;
        }
        //
        private u32  pgu_clkd_reg_write_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b10, u32 val_b8) 
        {
            //
            u32 R_W_bar     = 0           ;
            u32 byte_mode_W = 0x0         ;
            u32 reg_adrs    = reg_adrs_b10;
            u32 val         = val_b8      ;
            //
            u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
            //
            return pgu_clkd_send_spi_frame(slot, spi_sel,  framedata);        
        }
        //
        private u32  pgu_clkd_reg_read_b8(u32 slot, u32 spi_sel, 
            u32 reg_adrs_b10) 
        {
            //
            u32 R_W_bar     = 1           ;
            u32 byte_mode_W = 0x0         ;
            u32 reg_adrs    = reg_adrs_b10;
            u32 val         = 0xFF        ;
            //
            u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
            //
            return pgu_clkd_send_spi_frame(slot, spi_sel,  framedata);
        }        //
        //
        private u32  pgu_clkd_send_spi_frame(u32 slot, u32 spi_sel, 
            u32 frame_data) 
        {
            // write control 
            SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__CLKD_WI, frame_data);
            // trig spi frame
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__CLKD_TI, 1);
            // check spi frame done
            u32 cnt_done = 0    ;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            //$$ note clkd frame done is poorly implemented by checking two levels.
            //$$ must revise this ... to check triggered output...
            // check if done is high
            while (true) {
            	//
            	flag = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__CLKD_WO);
            	flag_done = (flag>>bit_loc) & 0x00000001;
            	//
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
            		break;
            }
            // copy received data
            u32 val_recv = flag & 0x000000FF;
            //
            return val_recv;
        }
        //
        //
        //
    }

    public partial class CMU : I_adc 
    {
        //
        private u32 adc_enable(u32 slot, u32 spi_sel, 
            u32 sel_freq_mode_MHz = 210) 
        {
            //
            if (sel_freq_mode_MHz == 210) 
                SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_WI, 0x0000_0001); // enable with 210MHz base freq
            else if (sel_freq_mode_MHz == 189) 
                SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_WI, 0x0000_0101); // enable with 189MHz base freq
            else // default 210MHz
                SetWireInValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_WI, 0x0000_0001); // enable with 210MHz base freq
            //
            u32 ret = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_WO);
            return ret;
        }
        //
        private u32 adc_disable(u32 slot, u32 spi_sel) {
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_WI, 0x0000_0000);
            u32 ret = GetWireOutValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_WO);
            return ret;
        }
        //
        private u32 adc_init(u32 slot, u32 spi_sel, 
            s32 len_adc_data = 4, u32 cnt_sampling_period = 21,
            u32 val_tst_fix_pat_en_b1 = 0, u32 val_tst_inc_pat_en_b1 = 0,
            u32 val_tap0a_b5 = 0x0, u32 val_tap0b_b5 = 0x0, u32 val_tap1a_b5 = 0x0, u32 val_tap1b_b5 = 0x0) 
        {
            // ADC parameter setup
            adc_set_update_sample_num(slot, spi_sel,  len_adc_data); // set the number of ADC samples
            adc_set_sampling_period(slot, spi_sel,  cnt_sampling_period); // 210MHz/21   =  10 Msps
            adc_set_tap_control(slot, spi_sel,  val_tap0a_b5,val_tap0b_b5,val_tap1a_b5,val_tap1b_b5,val_tst_fix_pat_en_b1,val_tst_inc_pat_en_b1); // (u32 val_tap0a_b5, u32 val_tap0b_b5, u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 

            // print out base freq and sampling rate
            u32 val = adc_get_base_freq(slot, spi_sel); // adc base freq check 
            Console.WriteLine(string.Format("{0} = {1} [MHz]", "adc_base_freq    ", (float)val/1000000.0));
            Console.WriteLine(string.Format("{0} = {1,0:0.####} [MHz]", "adc_sampling_freq", (float)val/1000000.0/cnt_sampling_period));

            // trigger init
            return adc_trig_check(slot, spi_sel,  1);
        }
        //
        private s32 adc_set_update_sample_num(u32 slot, u32 spi_sel, 
            s32 val) 
        {
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_UPD_SM_WI, (u32)val);
            return val;
        }
        //
        private u32 adc_set_sampling_period(u32 slot, u32 spi_sel, 
            u32 val) 
        {
            // 210MHz/val = x  Msps
            // 210MHz/14  = 15 Msps
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_SMP_PR_WI, val);
            return val;
        }
        //
        private u32 adc_set_tap_control(u32 slot, u32 spi_sel, 
            u32 val_tap0a_b5, u32 val_tap0b_b5, u32 val_tap1a_b5, u32 val_tap1b_b5,
            u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
        {
            // note: val_tst_fix_pat_en_b1 for adc fixed test pattern 18-bit 0x330FC
            u32 val = 
                (val_tap1b_b5<<27) | (val_tap1a_b5<<22) | 
                (val_tap0b_b5<<17) | (val_tap0a_b5<<12) | 
                (val_tst_inc_pat_en_b1<<2) | (val_tst_fix_pat_en_b1);
            
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_DLY_TP_WI, val);
            return val;
        }
        //
        private u32 adc_get_base_freq(u32 slot, u32 spi_sel) {
            return GetWireOutValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_B_FRQ_WO);
        }
        //
        private u32 adc_trig_check(u32 slot, u32 spi_sel,
            s32 bit_loc) 
        {
            ActivateTriggerIn(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_TI, bit_loc); // (u32 adrs, s32 loc_bit)
            //# check done
            u32 cnt_done = 0;
            bool flag_done;
            while (true) {
                flag_done = IsTriggered(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_TO, (u32)(0x1<<bit_loc));
                if (flag_done==true)
                    break;
                cnt_done += 1;
                if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
                    break;
            }
            u32 ret = GetWireOutValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_WO);
            return ret;
        }        //
        //
        private u32 adc_reset_fifo(u32 slot, u32 spi_sel) {
            //return adc_trig_check(4);
            return adc_trig__wo_check(slot, spi_sel, 4);
        }
        //
        private u32 adc_trig__wo_check(u32 slot, u32 spi_sel, 
            s32 bit_loc) 
        {
            ActivateTriggerIn(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__ADCH_TI, bit_loc); // (u32 adrs, s32 loc_bit)
            return 1;
        }
        //
        //
        //
        //
    }
    public partial class CMU : I_dft {}

    public partial class CMU //: I_printf 
    {
        // test printf emulation
        private void xil_printf(string fmt) { // for test print
            // remove "\r\n" 
            if (fmt.Substring(fmt.Length-2)=="\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-2);
                fmt = tmp; //
            }
            Console.WriteLine(fmt);
        }
        //
        private void xil_printf(string fmt, s32 val) { // for test print
            // check "%02d \r\n"
            if (fmt.Substring(fmt.Length-7)=="%02d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-7);
                fmt = tmp + string.Format("{0,2:d2} ", val); //
            }
            // check "%d \r\n"
            else if (fmt.Substring(fmt.Length-5)=="%d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-5);
                fmt = tmp + string.Format("{0} ", val); //
            }
            Console.WriteLine(fmt);
        }
        //
        private void xil_printf(string fmt, s32 val1 , s32 val2 , s32 val3) { // for test print
            // remove "| %3d || %9d | %9d |\r\n" 
            if (fmt.Substring(fmt.Length-22)=="| %3d || %9d | %9d |\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-22);
                fmt = tmp + string.Format("| {0,3:d} || {1,9:d} | {2,9:d} |", val1, val2, val3); //
            }
            Console.WriteLine(fmt);
        }
        //
    }

}
