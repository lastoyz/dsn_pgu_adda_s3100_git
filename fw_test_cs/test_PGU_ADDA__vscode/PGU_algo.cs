//// PGU_algo.cs

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


    //// interface
    interface I_PGU_proc {} // interface for GUI SW // to come
    interface I_PGU_algo {} // interface for algorithm // to come


    //// some common class or enum or struct

    public partial class __PGU 
    {
        public enum __enum_TEST {}

        static class __CONST__
        {
            //
            public const int LEN_DAC_DATA_FIFO = 1000;
        }

        //TODO: PGU GUI parameters
        // parameters ... almost fixed, not allowed to change user setup.
        // variables  ... according to user setup
        // flags      ... internal signals

        //// parameters for PGU : from PC, but fixed.
        public float  __gui_time_ns__dac_update             = 10; // 2.5, 5, 10
        public int    __gui_time_ns__code_duration          = 10; // 10 100 
        public float  __gui_scale_voltage_10V_mode          = (float)0.85;
        public float  __gui_gain_voltage_10V_to_40V_mode    = 4;
        public float  __gui_output_impedance_ohm            = 50;
        public int    __gui_output_range_V                  = 10; // 10 or 40
        public float  __gui_dacx_ch1_full_scale_current__mA = (float)25.5; //  8.66~31.66mA
        public float  __gui_dacx_ch2_full_scale_current__mA = (float)25.5; //  8.66~31.66mA
        public float  __gui_dacx_ch1_offset_current__mA     = (float)0.60; // 0~2mA
        public float  __gui_dacx_ch2_offset_current__mA     = (float)0.60; // 0~2mA
        public int   __gui_dacx_ch1_N_pol_sel               = 0          ; // N pol or P pol
        public int   __gui_dacx_ch2_N_pol_sel               = 0          ; // N pol or P pol
        public int   __gui_dacx_ch1_Sink_sel                = 0          ; // sink or source
        public int   __gui_dacx_ch2_Sink_sel                = 0          ; // sink or source


        //// flags for PGU : not set by GUI.
        public bool   __gui_IsInit = false;   // internal flag for PGU initialization 
        public int    __gui_ch_info;          // temp access info
        public int    __gui_aux_io_control;   // temp access info
        public char[] __gui_pgu_idn_txt = new char[60]; //$$ not inside EEPROM // only available from test LAN port
        public byte   __gui_pgu_check_sum_residual;     //$$ not inside EEPROM // calculated from others


        //// variables for PGU : from GUI
        // pulse info
        public float    __gui_cmd_ch1_load_impedance_ohm = (float)1e6; // 1e6, 50 or others
        public float    __gui_cmd_ch2_load_impedance_ohm = (float)1e6; // 1e6, 50 or others
        public int      __gui_cmd_ch1_cycle_count        = 1; // 0 for inf
        public int      __gui_cmd_ch2_cycle_count        = 1; // 0 for inf
        public long[]   __gui_cmd_ch1_StepTime_ns  = new long[__CONST__.LEN_DAC_DATA_FIFO];
        public long[]   __gui_cmd_ch2_StepTime_ns  = new long[__CONST__.LEN_DAC_DATA_FIFO]; 
        public double[] __gui_cmd_ch1_StepLevel_V  = new double[__CONST__.LEN_DAC_DATA_FIFO]; 
        public double[] __gui_cmd_ch2_StepLevel_V  = new double[__CONST__.LEN_DAC_DATA_FIFO]; 

        // cal_data from EEPROM
        public int   __gui_use_caldata    = 1; // 1 to use calibration data.
        public float __gui_out_ch1_offset = 0.0F; //$$ EEPROM float32 location @ 0x040
        public float __gui_out_ch2_offset = 0.0F; //$$ EEPROM float32 location @ 0x044
        public float __gui_out_ch1_gain   = 1.0F; //$$ EEPROM float32 location @ 0x048
        public float __gui_out_ch2_gain   = 1.0F; //$$ EEPROM float32 location @ 0x04C

        // board INFO from EEPROM // including test LAN IP setup
        public char[] __gui_pgu_model_name  = new char[16]; //$$ location @ 0x00-0x0F
        public char[] __gui_pgu_ip_adrs = new char[16]; //$$ location @ 0x10-0x13
        public char[] __gui_pgu_sm_adrs = new char[16]; //$$ location @ 0x14-0x17
        public char[] __gui_pgu_ga_adrs = new char[16]; //$$ location @ 0x18-0x1B
        public char[] __gui_pgu_dns_adrs= new char[16]; //$$ location @ 0x1C-0x1F
        public char[] __gui_pgu_mac_adrs= new char[12]; //$$ location @ 0x20-0x2B
        public char[] __gui_pgu_slot_id = new char[2];  //$$ location @ 0x2C-0x2D
        public byte   __gui_pgu_user_id         ;       //$$ location @ 0x2E
        public byte   __gui_pgu_check_sum       ;       //$$ location @ 0x2F
        public char[] __gui_pgu_user_txt = new char[16];//$$ location @ 0x30-0x3F

    }

    //// implement

    public partial class PGU : I_PGU_proc {}
    public partial class PGU : I_PGU_algo {}

}
