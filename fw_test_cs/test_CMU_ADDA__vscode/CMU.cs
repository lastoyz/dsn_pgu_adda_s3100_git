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
    interface I_CMU_proc {} // interface for GUI SW // to come
    interface I_CMU_algo {} // interface for GMU algorithm // to come
    interface I_CMU // CMU low-level functions // CMU-ADDA, CMU-SUB
    {
        //// for slot functions
        void scan_frame_slot(); // scan slot
        bool search_board_init(s8 slot, u32 fid); //(s8 slot, u32 slot_cs_code, u32 slot_ch_code, u32 fid);
        u32 _SPI_SEL_SLOT(s32 ch); // in S3100 slot 1~12 // ch = 0  => slot = 1
        u32 _SPI_SEL_SLOT_GNDU(); // in S3100-GNDU slot 0 fixed
        u32 _SPI_SEL_CH_SMU();
        u32 _SPI_SEL_CH_GNDU();
        u32 _SPI_SEL_CH_PGU();
        u32 _SPI_SEL_CH_CMU();

        //// adda functions:
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

        //// cmu sub device functions:
        u32 cmu__dev_get_stat(u32 slot, u32 spi_sel);
        u32 cmu__dev_get_fid(u32 slot, u32 spi_sel);
        float cmu__dev_get_temp_C(u32 slot, u32 spi_sel);
        u32 cmu__dev_is_SIG_board(u32 slot, u32 spi_sel);
        public u32 cmu__dev_is_ANL_board(u32 slot, u32 spi_sel);
        //
        u32 cmu_init_sig(u32 slot, u32 spi_sel);
        void cmu_set_sig_dacp(u32 slot, u32 spi_sel, 
            u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0);
        void cmu_set_sig_extc(u32 slot, u32 spi_sel,  u32 val = 0);
        void cmu_set_sig_filt(u32 slot, u32 spi_sel, 
            u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF);
        //
        u32 cmu_init_anl(u32 slot, u32 spi_sel);
        void cmu_set_anl_rr_iv(u32 slot, u32 spi_sel, 
            u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0);
        void cmu_set_anl_det_mod(u32 slot, u32 spi_sel, 
            u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0);
        void cmu_set_anl_amp_gain(u32 slot, u32 spi_sel,
            u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0);
        u32 cmu_get_anl_stat__unbal(u32 slot, u32 spi_sel);
        u32 cmu_get_anl_stat__dcba_d(u32 slot, u32 spi_sel);
        u32 cmu_get_anl_stat__dcba_r(u32 slot, u32 spi_sel);
        void cmu_set_anl_dacq(u32 slot, u32 spi_sel, 
            float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0);
        float cmu_get_anl_dacq(u32 slot, u32 spi_sel,
            u32 ch_sel = 1);
        //
    }
    interface I_spio {} // SPIO IC control
    interface I_clkd {} // clock IC control
    interface I_dac {} // DAC IC control
    interface I_adc {} // ADC IC control
    interface I_dft {} // DFT calculation
    interface I_dacz {} // DAC pattern generation
    interface I_printf {} // for FW style printf

    interface I_CMU_SIG {} // CMU-SIG board control
    interface I_CMU_ANL {} // CMU-ANL board control

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
            CMU_brd_cls_id__SIG = 0x8,
            CMU_brd_cls_id__ANL = 0x9,
            //
            MAX_CNT = 200 // 2000000 // max counter when checking done trig_out.
                // LAN trans time 1ms ... 200  ... 200ms
                // SPI frame time 7us ... 2000 ... 14ms
                // Soft CPU time 14ns ... 2000000 ... 28ms
            //
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
            //
            s32[] dac0_code_inc_value__s32_buf = ret__dac0_fifo_dat.Item1;
            u32[] dac0_code_duration__u32_buf  = ret__dac0_fifo_dat.Item2;
            s32[] dac1_code_inc_value__s32_buf = ret__dac1_fifo_dat.Item1;
            u32[] dac1_code_duration__u32_buf  = ret__dac1_fifo_dat.Item2;
            ////
            // DAC pulse download
            Console.WriteLine(">>>>>> DAC0 download");
            dac_set_fifo_dat(slot, spi_sel, 
                1, num_repeat_pulses,
                dac0_code_inc_value__s32_buf, dac0_code_duration__u32_buf);
            Console.WriteLine(">>>>>> DAC1 download");
            dac_set_fifo_dat(slot, spi_sel, 
                2, num_repeat_pulses,
                dac1_code_inc_value__s32_buf, dac1_code_duration__u32_buf);
            Console.WriteLine(">>>>>> download done!");
            //
            return time_volt_dual_list; // for log data
        }

        // adda_trigger_pgu_output()
        public void adda_trigger_pgu_output(u32 slot, u32 spi_sel) {
            //// trigger linked DAC wave and adc update 
            dac_set_trig(slot, spi_sel,  true, true, true); // (bool Ch1, bool Ch2, bool force_adc_trig = false) 
        }

        // adda_wait_for_adc_done()
        public void adda_wait_for_adc_done(u32 slot, u32 spi_sel) {
            adc_update_check(slot, spi_sel); // check done without triggering // vs. adc_update() with triggering
            Console.WriteLine(">>>>>> ADC update done");

        }

        // adda_trigger_pgu_off()
        public void adda_trigger_pgu_off(u32 slot, u32 spi_sel) {
            //// clear DAC wave
            dac_reset_trig(slot, spi_sel);
            Console.WriteLine(">>>>>> PGU trigger off");
        }

        // adda_read_adc_buf()
        public void adda_read_adc_buf(u32 slot, u32 spi_sel, 
            s32 len_adc_data = 600, string buf_time_str = "", string buf_dac0_str = "", string buf_dac1_str ="") {            
            //// fifo data read 
            s32[] adc0_s32_buf = new s32[len_adc_data];
            s32[] adc1_s32_buf = new s32[len_adc_data];
            Console.WriteLine(">>>>>> ADC0 FIFO read");
            adc_get_fifo(slot, spi_sel, 
                0, len_adc_data, adc0_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            Console.WriteLine(">>>>>> ADC1 FIFO read");
            adc_get_fifo(slot, spi_sel ,
                1, len_adc_data, adc1_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            // log fifo data into a file
            Console.WriteLine(">>>>>> write ADC log file");
            adc_log("log__adc_buf__dac.py".ToCharArray(), 
                len_adc_data, adc0_s32_buf, adc1_s32_buf,
                buf_time_str, buf_dac0_str, buf_dac1_str); 
        }

        // adda_compute_dft() //$$ new
        public void adda_compute_dft() {}


        //// cmu sub boards:
        public u32 cmu__dev_get_stat(u32 slot, u32 spi_sel) 
        {
            // | CMU   | CMU_WO        | 0x0D0      | wireout_34 | Return CMU-SUB status.     | bit[0]=selection_io_path_ANL   |
            // |       |               |            |            |                            | bit[1]=selection_io_path_SIG   |
            // |       |               |            |            |                            | bit[7:2]=NA                    |
            // |       |               |            |            |                            | bit[11:8]=board class ID[3:0]  |
            // |       |               |            |            |                            | bit[19:16]=MTH SLOT ID[3:0]    |
            //
            // note : board class ID[3:0]
            //  [S3100-CMU-ANL] = 0x9
            //  [S3100-CMU-SIG] = 0x8
            return GetWireOutValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__CMU_WO);
        }

        public u32 cmu__dev_get_fid(u32 slot, u32 spi_sel) {
            return GetWireOutValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO);
        }

        public float cmu__dev_get_temp_C(u32 slot, u32 spi_sel) {
            return (float)GetWireOutValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__XADC_TEMP_WO)/1000;
        }

        public u32 cmu__dev_is_SIG_board(u32 slot, u32 spi_sel) 
        {
            //
            u32 ret = 0;
            u32 val = cmu__dev_get_stat(slot, spi_sel);
            val = (val>>8)&0xF;
            if (val==(u32)__enum_CMU.CMU_brd_cls_id__SIG) {
                ret = 1;
            }
            return ret;
        }

        public u32 cmu__dev_is_ANL_board(u32 slot, u32 spi_sel) 
        {
            //
            u32 ret = 0;
            u32 val = cmu__dev_get_stat(slot, spi_sel);
            val = (val>>8)&0xF;
            if (val==(u32)__enum_CMU.CMU_brd_cls_id__ANL) {
                ret = 1;
            }
            return ret;
        }
        //
        private void cmu__dev_set_cntl(u32 slot, u32 spi_sel,  u32 val) {
            // | CMU   | CMU_WI        | 0x050      | wire_in_14 | Control for CMU-SUB.       | bit[0]=force_io_path_ANL       |
            // |       |               |            |            |                            | bit[1]=force_io_path_SIG       |
            // |       |               |            |            |                            | bit[2]=auto_sel_io_path        |
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__CMU_WI, val);
        }
        //
        public u32 cmu_init_sig(u32 slot, u32 spi_sel)
        {
            u32 ret;
            // set IO path 
            cmu__dev_set_cntl(slot, spi_sel,  0x4); // for auto selection
            // get status
            ret = cmu__dev_get_stat(slot, spi_sel);
            return ret;
        }
        public void cmu_set_sig_dacp(u32 slot, u32 spi_sel, 
            u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0) 
        {
            // | DACP  | DACP_WI       | 0x064      | wire_in_19 | Control parallel DACP.     | bit[ 0]=o_DAC_D0               |
            // |       |               |            |            |                            | bit[ 1]=o_DAC_D1               |
            // |       |               |            |            |                            | bit[ 2]=o_DAC_D2               |
            // |       |               |            |            |                            | bit[ 3]=o_DAC_D3               |
            // |       |               |            |            |                            | bit[ 4]=o_DAC_D4               |
            // |       |               |            |            |                            | bit[ 5]=o_DAC_D5               |
            // |       |               |            |            |                            | bit[ 6]=o_DAC_D6               |
            // |       |               |            |            |                            | bit[ 7]=o_DAC_D7               |
            // |       |               |            |            |                            | bit[ 8]=o_DAC_D8               |
            // |       |               |            |            |                            | bit[ 9]=o_DAC_D9               |
            // |       |               |            |            |                            | bit[10]=o_DAC_D10              |
            // |       |               |            |            |                            | bit[11]=o_DAC_D11              |
            // |       |               |            |            |                            | bit[12]=o_DAC_MODE1            |
            // |       |               |            |            |                            | bit[13]=o_DAC_MODE2            |
            // |       |               |            |            |                            | bit[14]=o_DAC_POL              |
            // |       |               |            |            |                            | bit[15]=o_DAC_SPDUP            |

            u32 val = (spdup<<15) | (pol<<14) | (mode2<<13) | (mode1<<12) | (val_DACP_b12);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DACP_WI, val);
        }
        public void cmu_set_sig_extc(u32 slot, u32 spi_sel,  u32 val = 0) {
            // | EXT   | EXT_WI        | 0x068      | wire_in_1A | Control external IO.       | bit[ 0]=o_EXT_BIAS_ON          |
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__EXT_WI, val);
        }
        public void cmu_set_sig_filt(u32 slot, u32 spi_sel, 
            u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF) 
        {
            // | FILT  | FILT_WI       | 0x06C      | wire_in_1B | Control Filter.            | bit[ 0]=o_T_0_1                |
            // |       |               |            |            |                            | bit[ 1]=o_T_0_2                |
            // |       |               |            |            |                            | bit[ 2]=o_T_0_4                |
            // |       |               |            |            |                            | bit[ 3]=o_T_0_8                |
            // |       |               |            |            |                            | bit[ 4]=o_T_0_16               |
            // |       |               |            |            |                            | bit[ 5]=o_T_0_32               |
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_T_90_1               |
            // |       |               |            |            |                            | bit[ 9]=o_T_90_2               |
            // |       |               |            |            |                            | bit[10]=o_T_90_4               |
            // |       |               |            |            |                            | bit[11]=o_T_90_8               |
            // |       |               |            |            |                            | bit[12]=o_T_90_16              |
            // |       |               |            |            |                            | bit[13]=o_T_90_32              |
            // |       |               |            |            |                            | bit[14]=NA                     |
            // |       |               |            |            |                            | bit[15]=NA                     |
            // |       |               |            |            |                            | bit[16]=o_6K_B                 |
            // |       |               |            |            |                            | bit[17]=o_60K_B                |
            // |       |               |            |            |                            | bit[18]=o_600K_B               |
            // |       |               |            |            |                            | bit[19]=o_LPF_B                |
            // |       |               |            |            |                            | bit[31:20]=NA                  |
            u32 val = (val_FILT_b4<<16) | (val_T_90_b6<<8) | (val_T_0_b6);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__FILT_WI, val);
        }
        //
        public u32 cmu_init_anl(u32 slot, u32 spi_sel) {
            u32 ret;
            //// set IO path 
            cmu__dev_set_cntl(slot, spi_sel,  0x4); // for auto selection
            // get status
            ret = cmu__dev_get_stat(slot, spi_sel);
            //// initialize DACQ
            cmu__dacq_init(slot, spi_sel);
            return ret;
        }
        public void cmu_set_anl_rr_iv(u32 slot, u32 spi_sel, 
            u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) {
            // | RRIV  | RRIV_WI       | 0x054      | wire_in_15 | Control RR and IV.         | bit[ 0]=o_F_R_1                |
            // |       |               |            |            |                            | bit[ 1]=o_F_R_2                |
            // |       |               |            |            |                            | bit[ 2]=o_A1_R_1               |          
            // |       |               |            |            |                            | bit[ 3]=o_A1_R_2               |
            // |       |               |            |            |                            | bit[ 4]=o_F_D_1                |
            // |       |               |            |            |                            | bit[ 5]=o_F_D_2                | 
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_R100                 |
            // |       |               |            |            |                            | bit[ 9]=o_R1K                  |
            // |       |               |            |            |                            | bit[10]=o_R10K                 |
            // |       |               |            |            |                            | bit[11]=o_R100K                |
            // |       |               |            |            |                            | bit[12]=o_R_0                  |
            // |       |               |            |            |                            | bit[13]=o_R_1                  |
            // |       |               |            |            |                            | bit[14]=o_R_2                  |
            // |       |               |            |            |                            | bit[15]=o_R_3                  |
            u32 val = (val_R_N_b4<<12) | (val_R_M_b4<<8) | (val_F_D_b2<<4) | (val_A1_R_b2<<2) | (val_F_R_b2);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__RRIV_WI, val);
        }
        public void cmu_set_anl_det_mod(u32 slot, u32 spi_sel, 
            u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0) {
            // | DET   | DET_WI        | 0x058      | wire_in_16 | Control PH det and MOD.    | bit[ 0]=o_A3_D1                |
            // |       |               |            |            |                            | bit[ 1]=o_A3_D2                |
            // |       |               |            |            |                            | bit[ 2]=o_A3_R1                |
            // |       |               |            |            |                            | bit[ 3]=o_A3_R2                |
            // |       |               |            |            |                            | bit[ 4]=o_PS_0_0_RLY           |
            // |       |               |            |            |                            | bit[ 5]=o_PS90_0_RLY           |
            u32 val = (val_PS_RLY_b2<<4) | (val_A3_R_b2<<2) | (val_A3_D_b2);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DET_WI, val);
        }
        public void cmu_set_anl_amp_gain(u32 slot, u32 spi_sel,
            u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0) {
            // | AMP   | AMP_WI        | 0x05C      | wire_in_17 | Control AMP gain.          | bit[ 0]=o_AF1_D                |
            // |       |               |            |            |                            | bit[ 1]=o_AF2_D                |  
            // |       |               |            |            |                            | bit[ 2]=o_AF4_D                |
            // |       |               |            |            |                            | bit[ 3]=o_AM__1_D              |
            // |       |               |            |            |                            | bit[ 4]=o_AM100_D              |
            // |       |               |            |            |                            | bit[ 5]=NA                     |
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_AF1_R                |
            // |       |               |            |            |                            | bit[ 9]=o_AF2_R                |
            // |       |               |            |            |                            | bit[10]=o_AF4_R                |
            // |       |               |            |            |                            | bit[11]=o_AM__1_R              |
            // |       |               |            |            |                            | bit[12]=o_AM100_R              |

            u32 val = (val_AM_R_b2<<11) | (val_AF_R_b3<<8) | (val_AM_D_b2<<3) | (val_AF_D_b3);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__AMP_WI, val);
        }
        public u32 cmu_get_anl_stat__unbal(u32 slot, u32 spi_sel) {
            return (cmu_get_anl_stat(slot, spi_sel) & 0x0001);
        }
        public u32 cmu_get_anl_stat__dcba_d(u32 slot, u32 spi_sel) {
            return (cmu_get_anl_stat(slot, spi_sel)>>8) & 0x000F;
        }
        public u32 cmu_get_anl_stat__dcba_r(u32 slot, u32 spi_sel) {
            return (cmu_get_anl_stat(slot, spi_sel)>>12) & 0x000F;
        }
        private s32 cmu__daq_conv_flt_s32(float val_flt) {
            //// convert float to int (16-bits)
            // note: range -10V ~ +10V in float 
            s32 val_s32;
            float val_flt_MAX = 10;
            float val_flt_MIN = -10;

            // limit
            if (val_flt > val_flt_MAX) val_flt = val_flt_MAX;
            if (val_flt < val_flt_MIN) val_flt = val_flt_MIN;

            // pos scale = 10V / (2^15-1)
            // neg scale = -10V / 2^15
            float scale;
            if (val_flt > 0) scale = (float)( (Math.Pow(2,15)-1)/10.0 );
            else             scale = (float)(  Math.Pow(2,15)   /10.0 );

            val_s32 = (s32)(val_flt * scale);
            return val_s32;
        }
        private float cmu__daq_conv_s32_flt(s32 val_s32) {
            //// convert int (16-bits) to float
            // note: range -10V ~ +10V in float 
            float val_flt;

            // limit
            s32 val_s32_MAX = (s32)(Math.Pow(2,15)-1);
            s32 val_s32_MIN = (s32)(-Math.Pow(2,15));
            if (val_s32 > val_s32_MAX) val_flt = val_s32_MAX;
            if (val_s32 < val_s32_MIN) val_flt = val_s32_MIN;

            // pos scale = 10V / (2^15-1)
            // neg scale = -10V / 2^15
            float scale;
            if (val_s32 > 0) scale = (float)(10.0 / (Math.Pow(2,15)-1) );
            else             scale = (float)(10.0 /  Math.Pow(2,15)    );

            val_flt = (float)(val_s32 * scale);
            return val_flt;
        }
        public void cmu_set_anl_dacq(u32 slot, u32 spi_sel, 
            float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0) {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_DIN21_WI | 0x02C      | wire_in_0B | Set DACQ_21 data.          | bit[31:16]=DAC2[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC1[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_DIN43_WI | 0x030      | wire_in_0C | Set DACQ_43 data.          | bit[31:16]=DAC4[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC3[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            
            //// convert float to int (16-bits)
            // note: range -10V ~ +10V in float // scale = 10V / (2^15-1)
            s32 val_dac1_s32 = cmu__daq_conv_flt_s32(val_dac1_flt);
            s32 val_dac2_s32 = cmu__daq_conv_flt_s32(val_dac2_flt);
            s32 val_dac3_s32 = cmu__daq_conv_flt_s32(val_dac3_flt);
            s32 val_dac4_s32 = cmu__daq_conv_flt_s32(val_dac4_flt);
            // set dac integer values
            u32 val_dac21 =  (u32)( ((val_dac2_s32&0xFFFF)<<16) | (val_dac1_s32&0xFFFF) );
            u32 val_dac43 =  (u32)( ((val_dac4_s32&0xFFFF)<<16) | (val_dac3_s32&0xFFFF) );
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DACQ_DIN21_WI, val_dac21);
            SetWireInValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DACQ_DIN43_WI, val_dac43);

            // trigger dac update
            cmu__dacq_update(slot, spi_sel);
        }
        public float cmu_get_anl_dacq(u32 slot, u32 spi_sel,
            u32 ch_sel = 1) {
            // ch_sel : 1, 2, 3, 4

            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_RDB21_WO | 0x0AC      | wireout_2B | Get DACQ_21 readback.      | bit[31:16]=DAC2[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC1[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_RDB43_WO | 0x0B0      | wireout_2C | Get DACQ_43 readback.      | bit[31:16]=DAC4[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC3[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+

            float val_flt;
            u32 ret_val_21 = GetWireOutValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DACQ_RDB21_WO);
            u32 ret_val_43 = GetWireOutValue(slot, spi_sel,
                (u32)__enum_EPA.EP_ADRS__DACQ_RDB43_WO);
            s16 ret_val_s16;
            s32 ret_val_s32;
            if      (ch_sel == 1) ret_val_s16 = (s16)((ret_val_21>> 0)&0xFFFF);
            else if (ch_sel == 2) ret_val_s16 = (s16)((ret_val_21>>16)&0xFFFF);
            else if (ch_sel == 3) ret_val_s16 = (s16)((ret_val_43>> 0)&0xFFFF);
            else if (ch_sel == 4) ret_val_s16 = (s16)((ret_val_43>>16)&0xFFFF);
            else                  ret_val_s16 = 0;
            //
            ret_val_s32 = (s32)ret_val_s16;
            val_flt = cmu__daq_conv_s32_flt(ret_val_s32);
            return val_flt;
        }
        //
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
            if (DAC_gain > 0x3FF) {
                DAC_gain = 0x3FF; // max
            }
            //// for firmware
            u32 val       = (u32)((DAC_gain<<16) + DAC_gain);
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
            u32 val       = (u32)((DAC_offset<<16) + DAC_offset);
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
        private u32 adc_update_check(u32 slot, u32 spi_sel) {
            return adc_trig_check__wo_trig(slot, spi_sel,  2);
        }
        //
        private u32 adc_trig_check__wo_trig(u32 slot, u32 spi_sel, 
            s32 bit_loc) 
        {
            //# check done
            u32 cnt_done = 0    ;
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
            //
            u32 ret = GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__ADCH_WO);
            return ret;
        }        
        //
        private u32 adc_get_fifo(u32 slot, u32 spi_sel, 
            u32 ch, s32 num_data, s32[] buf_s32) 
        {
            u32 ret;
            u32 adrs;
            u8[] buf_pipe = new u8[num_data*4]; // *4 for 32-bit pipe 
            if (ch==0) {
                adrs = (u32)__enum_EPA.EP_ADRS__ADCH_DOUT0_PO;
            } else if (ch==1) {
                adrs = (u32)__enum_EPA.EP_ADRS__ADCH_DOUT1_PO;
            } else {
                return 0;
            }
            // buf_pipe ... u8 buffer
            ret = (u32)ReadFromPipeOut(slot, spi_sel, 
                adrs, (u16)(buf_pipe.Length), buf_pipe); 
            // collect and copy data : buf => buf_dataout
            s32 ii;
            s32 tmp;
            for (ii=0;ii<num_data;ii++) {
                tmp = BitConverter.ToInt32(buf_pipe, ii*4); // read one pipe data every 4 bytes
                buf_s32[ii] = tmp; // adc uses 32 bits ... msb side 18 bits are valid.
            }
            //
            return ret/4; // number of bytes --> number of int
        }        
        //
        //
        private void adc_log(char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32, 
                                string buf_time_str="", string buf_dac0_str="", string buf_dac1_str="") {
            // open or create a file
            string LOG_DIR_NAME  =  "test_CMU_ADDA__vscode"; //$$ test_HVPGU__vscode --> test_win_app_vscode
            string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), LOG_DIR_NAME, "log"); //$$ TODO: logfile location in vs code
            string LogFileName = Path.Combine(LogFilePath, new string(log_filename));
            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }
            // write header
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) {
                ws.WriteLine("\"\"\" data log file : import data as CONSTANT \"\"\"");
                ws.WriteLine("# pylint: disable=C0301");
                ws.WriteLine("# pylint: disable=line-too-long");
                ws.WriteLine("# pylint: disable=C0326 ## disable-exactly-one-space");
                ws.WriteLine("## log start"); //$$ add python comment header
            }
            // note adc full scale : +/-4.096V with 2^31-1 ~ -2^31
            float adc_scale = (float)4.096 / ((float)Math.Pow(2,31)-(float)1.0);
            //
            string buf0_s32_str = "";
            string buf1_s32_str = "";
            string buf0_s32_hex_str = "";
            string buf1_s32_hex_str = "";
            string buf0_flt_str = "";
            string buf1_flt_str = "";
            //
            for (s32 i = 0; i < len_data; i++) {
                //
                buf0_s32_str     = buf0_s32_str + string.Format("{0,11:D}, ",buf0_s32[i]);
                buf1_s32_str     = buf1_s32_str + string.Format("{0,11:D}, ",buf1_s32[i]);
                buf0_s32_hex_str = buf0_s32_hex_str + string.Format(" '{0,8:X8}', ",buf0_s32[i]);
                buf1_s32_hex_str = buf1_s32_hex_str + string.Format(" '{0,8:X8}', ",buf1_s32[i]);
                buf0_flt_str     = buf0_flt_str + string.Format("{0,11:F8}, ",(float)buf0_s32[i]*adc_scale);
                buf1_flt_str     = buf1_flt_str + string.Format("{0,11:F8}, ",(float)buf1_s32[i]*adc_scale);
            }
            // write data string on the file
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                ws.WriteLine("TEST_DATA = [0, 1, 2, 3]"); // test
                // command info
                ws.WriteLine("BUF_TIME     = [" + buf_time_str + "]"); // command info
                ws.WriteLine("BUF_DAC0     = [" + buf_dac0_str + "]"); // command info
                ws.WriteLine("BUF_DAC1     = [" + buf_dac1_str + "]"); // command info
                ws.WriteLine(""); // newline
                ws.WriteLine("ADC_BUF0     = [" + buf0_s32_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1     = [" + buf1_s32_str + "]"); // from buf1_s32
                ws.WriteLine("ADC_BUF0_HEX = [" + buf0_s32_hex_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1_HEX = [" + buf1_s32_hex_str + "]"); // from buf1_s32
                ws.WriteLine("ADC_BUF0_FLT = [" + buf0_flt_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1_FLT = [" + buf1_flt_str + "]"); // from buf1_s32
            }
        }
        //
    }
    
    public partial class CMU : I_dacz 
    {
        public Tuple<long[], double[], double[]> dac_gen_pulse_cmd(long[] StepTime, double[] StepLevel) 
        {
            // generate dac command dual list from single time-voltage list
            int len_dac_command_points = StepTime.Length;
            long[]   buf_time = new long  [len_dac_command_points];
            double[] buf_dac0 = new double[len_dac_command_points];
            double[] buf_dac1 = new double[len_dac_command_points];

            Array.Copy(StepTime,  buf_time, len_dac_command_points);

            // same data on dac0 and dac1
            Array.Copy(StepLevel, buf_dac0, len_dac_command_points);
            Array.Copy(StepLevel, buf_dac1, len_dac_command_points);

            return Tuple.Create(buf_time, buf_dac0, buf_dac1);
        }
        //
        public Tuple<s32[], u32[]> dac_gen_fifo_dat(long[] time_ns_list, double[] level_volt_list, 
            int    time_ns__code_duration, 
            double load_impedance_ohm, double output_impedance_ohm,
            double scale_voltage_10V_mode, int output_range, double gain_voltage_10V_to_40V_mode, 
            double out_scale, double out_offset)
        {
            // copy to new lists
            int len_data = time_ns_list.Length;
            long[]   time_ns_list__ref    = new long  [len_data];
            double[] level_volt_list__ref = new double[len_data];

            Array.Copy(time_ns_list,    time_ns_list__ref,    len_data);
            Array.Copy(level_volt_list, level_volt_list__ref, len_data);

            // generate pulse waveform
            var pulse_info = pgu__gen_pulse_info(
                output_range, 
                time_ns_list__ref, level_volt_list__ref, 
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm, 
                scale_voltage_10V_mode, gain_voltage_10V_to_40V_mode,
                out_scale, out_offset);

            // download waveform into FPGA
            List<s32>[]  code_value__list    = pulse_info.Item1;
            List<long>[] code_duration__list = pulse_info.Item2;            
            // set the number of fifo data length
            u32 len_fifo_data = 0;
            for (int i = 0; i < code_value__list.Length; i++)
            {
                len_fifo_data = len_fifo_data + (u32)code_value__list[i].Count;
            }
            s32[]  code_value__s32_buf    ;
            s32[]  code_inc_value__s32_buf;
            long[] code_duration__long_buf; 
            u32[]  code_duration__u32_buf ; 
            s32[]  merge_code_inc_value__s32_buf = new s32[len_fifo_data];
            u32[]  merge_code_duration__u32_buf  = new u32[len_fifo_data]; 
            // send DAC data into FPGA FIFO
            //for (int i = 0; i < pulse_info_num_block_str.Length; i++)
            int idx_merge = 0;
            for (int i = 0; i < code_value__list.Length; i++)
            {
                //// collect DAC data into arrays
                //code_value__list[i]   
                code_value__s32_buf = code_value__list[i].ToArray();
                // shift 16 bits due to 0 incremental code
                code_inc_value__s32_buf = code_value__s32_buf.Select(x => (x<<16)).ToArray();
                //code_duration__list[i]
                code_duration__long_buf = code_duration__list[i].ToArray();
                code_duration__u32_buf  = Array.ConvertAll(code_duration__long_buf, x => (u32)x);
                //// accumulate arrays 
                int len_code_buf = code_inc_value__s32_buf.Length;
                Array.Copy(code_inc_value__s32_buf, 0, merge_code_inc_value__s32_buf, idx_merge, len_code_buf);
                Array.Copy(code_duration__u32_buf,  0, merge_code_duration__u32_buf,  idx_merge, len_code_buf);
                idx_merge += len_code_buf;
            }
            //
            return Tuple.Create(merge_code_inc_value__s32_buf, merge_code_duration__u32_buf);
        }
        //
        private Tuple<List<s32>[], List<long>[]> pgu__gen_pulse_info(int output_range, long[] time_ns_list, double[] level_volt_list,
            int    time_ns__code_duration, 
            double load_impedance_ohm, double output_impedance_ohm,
            double scale_voltage_10V_mode, double gain_voltage_10V_to_40V_mode, 
            double out_scale, double out_offset) 
        {
            double Devide_V = 1;
            if (output_range == 40)
            {
                Devide_V = gain_voltage_10V_to_40V_mode; //$$ must be 4
            }

            // apply load_impedance_ohm
            //$$scale_voltage_10V_mode = scale_voltage_10V_mode * ((output_impedance_ohm + load_impedance_ohm) / load_impedance_ohm);
            double scale_voltage_10V = scale_voltage_10V_mode * ((output_impedance_ohm + load_impedance_ohm) / load_impedance_ohm);

            // apply calibration to voltages
            for (int i = 0; i < level_volt_list.Length; i++) 
            {
                //$$level_volt_list[i]     = (level_volt_list[i]* out_scale + out_offset) * scale_voltage_10V_mode / Devide_V; 
                level_volt_list[i]     = (level_volt_list[i]* out_scale + out_offset) * scale_voltage_10V / Devide_V;
            }

            long[] num_steps_list = new long[time_ns_list.Length - 1]; //$$ <<<
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				num_steps_list[i - 1] = Convert.ToInt64(((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__code_duration));  //$$ number of DAC points in eash segment
            }

            double[] level_diff_volt_list = new double[level_volt_list.Length - 1]; //$$ <<<
            for (int i = 1; i < level_volt_list.Length; i++)
            {
                level_diff_volt_list[i - 1] = level_volt_list[i] - level_volt_list[i - 1]; //$$ dac incremental value in each segment
            }

            int[] level_code_list = new int[level_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_volt_list.Length; i++)
            {
                level_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(level_volt_list[i]); //$$ dac starting code in ease segment
            }

            int[] level_step_code_list = new int[level_diff_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                //$$ num_steps_list[i] == 0 means data duplicate.
                if (num_steps_list[i] > 0) {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) / num_steps_list[i]); //$$ dac incremental code in each segment
                }
                else {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(0); //$$ 
                }
            }
			
			int[] level_diff_code_list = new int[level_diff_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                level_diff_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) ); //$$ dac full difference in each segment
            }

            int[]    time_step_code_list        = new int   [time_ns_list.Length - 1]; //$$ <<<
			double[] time_step_code_double_list = new double[time_ns_list.Length - 1];
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				time_step_code_list[i - 1] = 0; //$$ basic step 1
            }

            string[] num_block_str__sample_code__list = new string[level_step_code_list.Length]; //$$ <<<

            List<s32>[]  code_value__list    = new List<s32> [level_step_code_list.Length];
            List<long>[] code_duration__list = new List<long>[level_step_code_list.Length];

            int code_start;
			double volt_diff;
			int code_diff;
            int code_step;
            long num_steps;
			long time_step_code; //$$
			long time_start_ns; //$$
			
            long max_duration_a_code__in_flat_segment = Convert.ToInt64(Math.Pow(2, 31)-1); // 2^32-1

            int Point_NUM = Convert.ToInt32(1000 / (num_steps_list.Length));    //$$ FIFO Count limit 
            long max_num_codes__in_slope_segment = Point_NUM;
                //
            for (int i = 0; i < level_step_code_list.Length; i++)
            {
                code_start     = level_code_list[i];      //$$ dac starting code in each segment
                volt_diff      = level_diff_volt_list[i]; //$$ dac voltage difference in in each segment for max step +/- 20V or more.
                code_diff      = level_diff_code_list[i]; //$$ dac code diff in each segment for better slope shape //$$ NG  with large slope step more than +/-10V
                code_step      = level_step_code_list[i]; //$$ dac incremental code in each segment 
                num_steps      = num_steps_list[i];       //$$ number of DAC points in eash segment
                time_step_code = time_step_code_list[i];  //$$ duration count 32 bit in each segment // share it with all points
                time_start_ns  = time_ns_list[i];         //$$ start time each segment in ns
                //
                var ret = gen_pulse_info_segment__inc_step(code_start, volt_diff, code_diff, code_step, num_steps, time_step_code, 
                            time_start_ns, max_duration_a_code__in_flat_segment, max_num_codes__in_slope_segment, time_ns__code_duration); //$$ (pulse_info_num_block_str, code_value_float_str, time_ns_str) 
                //$$ segment info by list not string
                code_value__list[i]    = ret.Item1;
                code_duration__list[i] = ret.Item2;
            }
            return Tuple.Create(code_value__list, code_duration__list);
        }
        //
        private long conv_dec_to_bit_2s_comp_16bit(double dec, double full_scale = 20) //$$ int to double
        {
            if (dec > (full_scale / 2.0 - full_scale / Math.Pow(2, 16)))
            {
                dec = full_scale / 2.0 - full_scale / Math.Pow(2, 16);
            }
            if (dec < (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)))
            {
                dec = -full_scale / 2.0;
            }
            // bit_2s_comp = int( 0x10000 * ( dec + full_scale/2)    / full_scale ) + 0x8000
            long bit_2s_comp = Convert.ToInt64(0x10000 * (dec + full_scale / 2.0) / full_scale) + 0x8000;
            //
            if (bit_2s_comp > (0xFFFF))
            {
                bit_2s_comp -= 0x10000;
            }
            //
            return bit_2s_comp;
        }
        //
        public double conv_bit_2s_comp_16bit_to_dec(int bit_2s_comp, double full_scale = 20) //$$ int to double
        {
            if (bit_2s_comp >= 0x8000) //$$ negative
            {
                double dec = full_scale * (bit_2s_comp) / (double)0x10000 - full_scale; //$$ rev
                // 20 * 0x8000 / 0x10000 - 20 = -10
                return dec;
            }
            else
            {
                //$$double dec = Convert.ToInt32(full_scale * (bit_2s_comp) / 0x10000); //$$ NG
                double dec = full_scale * (bit_2s_comp) / 0x10000;
                //$$if (dec == full_scale / 2.0 - full_scale / Convert.ToInt32(Math.Pow(2, 16)))
                if (dec == full_scale / 2.0 - full_scale / Math.Pow(2, 16))
                    dec = full_scale / 2.0;
                return dec;
            }
        }
        //
        private Tuple<List<s32>, List<long>> gen_pulse_info_segment__inc_step(int code_start, double volt_diff, int code_diff, int code_step, long num_steps, long code_duration, 
                long time_start_ns = 0, long max_duration_a_code__in_flat_segment = 16, long max_num_codes__in_slope_segment = 16,
                int time_ns__code_duration = 10)
        {
            long num_codes = num_steps;
            long time_ns = (long)time_start_ns;
            long duration_ns = 0; //$$
            int code_value = code_start;
            
            long total_duration_segment = num_steps*(code_duration + 1); //$$
            int    num_merge_steps = 1;
            double code_start_float = conv_bit_2s_comp_16bit_to_dec(code_start);
            
            //$$ note if code_step == 0, flat segment
            //   re-calculate code_duration
            if ((volt_diff == 0) && (total_duration_segment > max_duration_a_code__in_flat_segment )) 
            {
                // use max_duration_a_code__in_flat_segment
                code_duration = (int)max_duration_a_code__in_flat_segment - 1;
            }
            else if ((volt_diff == 0) && (total_duration_segment <= max_duration_a_code__in_flat_segment )) 
            {
                // use one step for total_duration_segment 
                //num_codes     = 1; // not used
                code_duration = (int)total_duration_segment - 1; //$$ 
            }
            else if (num_steps > max_num_codes__in_slope_segment)
            {
                //$$ slope segment ...
                // use max_num_codes__in_slope_segment
                double ratio_num_steps_max_num_codes__in_slope_segment = (double)num_steps/max_num_codes__in_slope_segment;
                // Console.WriteLine("ratio_num_steps_max_num_codes__in_slope_segment = " + Convert.ToString(ratio_num_steps_max_num_codes__in_slope_segment) );
                num_merge_steps = (int)Math.Ceiling(ratio_num_steps_max_num_codes__in_slope_segment);
                // Console.WriteLine("num_merge_steps                                 = " + Convert.ToString(num_merge_steps) );
                code_duration = (int)((code_duration+1)*num_merge_steps - 1); //$$ 
            }
            else 
            {
                // as it is ...
            }
            //$$ code list and duration list
            List<s32>  code_value_list    = new List<s32>();
            List<long> code_duration_list = new List<long>();
            //
            long duration_send = total_duration_segment;
            double code_value_float = code_start_float;
            long count_codes = 0; // count number of codes in a segment
            while (true)
            {
                //$$ calculate dac code 
                code_value = (int)conv_dec_to_bit_2s_comp_16bit(code_value_float);
                ////test_value = (code_value << 16) + code_duration;
                count_codes++; //$$ increase count
                duration_ns = (code_duration + 1) * (long)time_ns__code_duration;
                //$$ report as string
                //code_value_str       += string.Format("{0,6:X4}, ", code_value  ); //$$ must convert to s32 array or list
                //code_value_float_str += string.Format("{0,6:f3}, ", conv_bit_2s_comp_16bit_to_dec(code_value)  );
                //code_duration_str    += string.Format("{0,6:d}, ", code_duration); //$$ must convert to long array or list
                //time_ns_str          += string.Format("{0,6:d}, ", time_ns      );
                //duration_ns_str      += string.Format("{0,6:d}, ", duration_ns);
                //
                // report data as list
                code_value_list   .Add(code_value);
                code_duration_list.Add(code_duration);
                // update code in float 
                code_value_float += (volt_diff * (code_duration+1) / total_duration_segment); //$$ get more accuracy
                // update time_ns 
                time_ns += duration_ns;
                //$$ update loop 
                duration_send -= (code_duration+1);
                if (duration_send < (code_duration+1) ) 
                {
                    code_duration = (int)duration_send-1;
                }
                if (duration_send == 0) break;
            }
            return Tuple.Create(code_value_list, code_duration_list);
        }
        //
        //
        public void dac_set_fifo_dat(u32 slot, u32 spi_sel, 
            int ch, int num_repeat_pulses,
            s32[] code_inc_value__s32_buf,
            u32[] code_duration__u32_buf) 
        {
            u32 val;
            //$$ note pgu_dacz_dat_write --> dac__pat*...
            // set pulse repeat number
            val = (u32)num_repeat_pulses;
            if (ch == 1) { // Ch == 1 or DAC0
                pgu_dacz_dat_write(slot, spi_sel,  0x00000020,  8); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  val, 10); // trig control
            } else { // Ch == 2 or DAC1
                pgu_dacz_dat_write(slot, spi_sel,  0x00000030,  8); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  val, 10); // trig control
            }
            //// download waveform into FPGA
            // set the number of fifo data length
            u32 len_fifo_data = (u32)code_inc_value__s32_buf.Length;
            val = (u32)len_fifo_data;
            if (ch == 1) { // Ch == 1 or DAC0
                //// dac0 fifo reset 
                pgu_dacz_dat_write(slot, spi_sel,  0x00000040, 12); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  0x00000000, 12); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  0x00000000, 12); // trig control
                // on dac0 fifo length set
                pgu_dacz_dat_write(slot, spi_sel,  0x00001000,  8); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  val, 10); // trig control
            }
            else { // Ch == 2 or DAC1
                //// dac1 fifo reset 
                pgu_dacz_dat_write(slot, spi_sel,  0x00000080, 12); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  0x00000000, 12); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  0x00000000, 12); // trig control
                // on dac1 fifo length set
                pgu_dacz_dat_write(slot, spi_sel,  0x00001010,  8); // trig control
                pgu_dacz_dat_write(slot, spi_sel,  val, 10); // trig control
            }            
            //// send merged DAC data into FPGA FIFO
            byte[] dat_bytearray = code_inc_value__s32_buf.SelectMany(BitConverter.GetBytes).ToArray();
            byte[] dur_bytearray = code_duration__u32_buf.SelectMany(BitConverter.GetBytes).ToArray();
            //
            if (ch == 1) { // Ch == 1 or DAC0
                WriteToPipeIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DAC0_DAT_INC_PI, (u16)(dat_bytearray.Length), dat_bytearray);
                WriteToPipeIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DAC0_DUR_PI    , (u16)(dur_bytearray.Length), dur_bytearray);
            }
            else { // Ch == 2 or DAC1
                WriteToPipeIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DAC1_DAT_INC_PI, (u16)(dat_bytearray.Length), dat_bytearray);
                WriteToPipeIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DAC1_DUR_PI    , (u16)(dur_bytearray.Length), dur_bytearray);
            }
        }
        //
        private void pgu_dacz_dat_write(u32 slot, u32 spi_sel, 
            u32 dacx_dat, s32 bit_loc_trig) 
        {
            SetWireInValue   (slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACZ_DAT_WI, dacx_dat    );
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACZ_DAT_TI, bit_loc_trig); // trig location
        }
        //
        private u32  pgu_dacz_dat_read(u32 slot, u32 spi_sel,
            s32 bit_loc_trig) 
        {
            ActivateTriggerIn(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACZ_DAT_TI, bit_loc_trig); // trig location
            return (u32)GetWireOutValue(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACZ_DAT_WO);
        }
        //
        private u32  pgu_dacz__read_status(u32 slot, u32 spi_sel) {
            // return status : 
            // wire w_read_status   = i_trig_dacz_ctrl[5]; //$$
            // wire [31:0] w_status_data = {r_control_pulse[31:2], r_dac1_active_clk, r_dac0_active_clk};
            return pgu_dacz_dat_read(slot, spi_sel,  5); 
        }
        //
        private void dac_set_trig(u32 slot, u32 spi_sel, 
            bool trig_ch1 =false, bool trig_ch2 = false, bool trig_adc_linked = false) 
        {
            u32 val;
            if (trig_ch1 && trig_ch2)
                val = 0x00000030;
            else if ( (trig_ch1 == true) && (trig_ch2 == false) )
                val = 0x00000010;
            else if ( (trig_ch1 == false) && (trig_ch2 == true) )
                val = 0x00000020;
            else
                val = 0x00000000;
            //
            if (trig_adc_linked)
                val = val + 0x100;
            //
            //wire w_enable_dac0_bias           = r_cid_reg_ctrl[0];
            //wire w_enable_dac1_bias           = r_cid_reg_ctrl[1];
            //wire w_enable_dac0_pulse_out_seq  = r_cid_reg_ctrl[2]; 
            //wire w_enable_dac1_pulse_out_seq  = r_cid_reg_ctrl[3]; 
            //wire w_enable_dac0_pulse_out_fifo = r_cid_reg_ctrl[4];
            //wire w_enable_dac1_pulse_out_fifo = r_cid_reg_ctrl[5];
            //wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6]; //$$ false path try
            //wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7]; //$$ false path try
            //wire w_force_trig_out             = r_cid_reg_ctrl[8];// new control for trig out  
            pgu_dacz_dat_write(slot, spi_sel,  val, 12); // trig control
        }
        //
        private void dac_reset_trig(u32 slot, u32 spi_sel) {
            dac_set_trig(slot, spi_sel,  false, false, false);
        }
        //
        //
    }

    public partial class CMU : I_dft {}

    public partial class CMU : I_printf 
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

    public partial class CMU : I_CMU_SIG {}

    public partial class CMU : I_CMU_ANL 
    {
        private u32 cmu__dacq_init(u32 slot, u32 spi_sel) {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WI       | 0x028      | wire_in_0A | Control DACQ.              | bit[ 0]=enable                 | 
            // |       |               |            |            |                            | bit[31:16]=confuration         |
            // |       |               |            |            |                            | conf=0xFF0B for +/-10V scale   |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WO       | 0x0A8      | wireout_2A | Return DACQ status.        | bit[ 0]=ready                  | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TI       | 0x128      | trig_in_4A | Trigger DACQ.              | bit[ 0]=trig_reset             | 
            // |       |               |            |            |                            | bit[ 1]=trig_init              |  
            // |       |               |            |            |                            | bit[ 2]=trig_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TO       | 0x1A8      | trigout_6A | Check DACQ done.           | bit[ 0]=done_reset             | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            SetWireInValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__DACQ_WI,0xFF0B0001);
            return cmu__dacq_trig_check(slot, spi_sel,  1);
        }
        private u32 cmu__dacq_trig_check(u32 slot, u32 spi_sel, 
            s32 bit_loc) 
        {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TI       | 0x128      | trig_in_4A | Trigger DACQ.              | bit[ 0]=trig_reset             | 
            // |       |               |            |            |                            | bit[ 1]=trig_init              |  
            // |       |               |            |            |                            | bit[ 2]=trig_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TO       | 0x1A8      | trigout_6A | Check DACQ done.           | bit[ 0]=done_reset             | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WO       | 0x0A8      | wireout_2A | Return DACQ status.        | bit[ 0]=ready                  | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            ActivateTriggerIn(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__DACQ_TI, bit_loc); // (u32 adrs, s32 loc_bit)
            //# check done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000; 
            bool flag_done;
            while (true) {
                flag_done = IsTriggered(slot, spi_sel, 
                    (u32)__enum_EPA.EP_ADRS__DACQ_TO, (u32)(0x1<<bit_loc));
                if (flag_done==true)
                    break;
                cnt_done += 1;
                if (cnt_done>=(u32)__enum_CMU.MAX_CNT)
                    break;
            }
            u32 ret = GetWireOutValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__DACQ_WO);
            return ret;
        }        
        private u32 cmu_get_anl_stat(u32 slot, u32 spi_sel) {
            // | STAT  | STAT_WO       | 0x0DC      | wireout_37 | Return status.             | bit[ 0]=i_UNBAL                |
            // |       |               |            |            |                            | bit[7:2]=NA                    |
            // |       |               |            |            |                            | bit[ 8]=i_A_D                  |
            // |       |               |            |            |                            | bit[ 9]=i_B_D                  |
            // |       |               |            |            |                            | bit[10]=i_C_D                  |
            // |       |               |            |            |                            | bit[11]=i_D_D                  |
            // |       |               |            |            |                            | bit[12]=i_A_R                  |
            // |       |               |            |            |                            | bit[13]=i_B_R                  |
            // |       |               |            |            |                            | bit[14]=i_C_R                  |
            // |       |               |            |            |                            | bit[15]=i_D_R                  |
            return GetWireOutValue(slot, spi_sel, 
                (u32)__enum_EPA.EP_ADRS__STAT_WO);
        }
        private u32 cmu__dacq_update(u32 slot, u32 spi_sel) {
            return cmu__dacq_trig_check(slot, spi_sel,  2);
        }
        //
    }


}
