
using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace __test__
{
    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware

    public class Program
    {
        //$$ note: IP ... setup for own LAN port test //{
        
        //public static string test_host_ip = "192.168.168.143"; // test dummy ip 
        public static uint test_loc_slot = 0x0000; // slot dummy // for self LAN port test
        public static uint test_loc_spi_group = 0x0000; // spi dummy outside  // for self LAN port test

        //}

        //public static string test_host_ip = "192.168.100.77"; // S3100-CPU_BD1
        //public static string test_host_ip = "192.168.100.78"; // S3100-CPU_BD2
        //public static string test_host_ip = "192.168.100.79"; // S3100-CPU_BD3

        //public static string test_host_ip = "192.168.100.61"; // S3100-PGU_BD1
        //public static string test_host_ip = "192.168.100.62"; // S3100-PGU_BD2
        //public static string test_host_ip = "192.168.100.63"; // S3100-PGU_BD3

        //public static string test_host_ip = "192.168.100.51"; // S3100-CMU-ADDA_BD1
        //public static string test_host_ip = "192.168.100.52"; // S3100-CMU-ADDA_BD2
        public static string test_host_ip = "192.168.100.53"; // S3100-CMU-ADDA_BD3

        //public static string test_host_ip = "192.168.168.143"; // test dummy ip
        //public static string test_host_ip = "192.168.100.143"; // test dummy ip for S3100-CPU-BASE

        //// S3100 frame slot selection:
        // loc_slot bit 0  = slot location 0`
        // loc_slot bit 1  = slot location 1
        // ...
        // loc_slot bit 12 = slot location 12

        //public static uint test_loc_slot = 0x0004; // slot location 2
        //public static uint test_loc_slot = 0x0010; // slot location 4
        //public static uint test_loc_slot = 0x0040; // slot location 6
        //public static uint test_loc_slot = 0x0100; // slot location 8
        //public static uint test_loc_slot = 0x0200; // slot location 9
        //public static uint test_loc_slot = 0x0400; // slot location 10
        //public static uint test_loc_slot = 0x1000; // slot location 12
        
        //// frame spi channel selection:
        // loc_spi_group bit 0 = mother board spi M0
        // loc_spi_group bit 1 = mother board spi M1
        // loc_spi_group bit 2 = mother board spi M2
        //public static uint test_loc_spi_group = 0x0001; // spi M0 // for GNDU
        //public static uint test_loc_spi_group = 0x0002; // spi M1 // for SMU
        //public static uint test_loc_spi_group = 0x0004; // spi M2 // for PGU CMU


        ////// test conditions:

        // adc
        //public static u32    adc_base_freq_MHz         = 189      ; // MHz // 210MHz vs 189MHz
        //public static u32    adc_base_freq_MHz         = 210      ; // MHz // 210MHz vs 189MHz

        //public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 210   ; // 210MHz/210   =  1000 ksps // 1us
        //public static u32 adc_sampling_period_count = 2100   ; // 210MHz/2100   =  100 ksps // 10us
        //public static u32 adc_sampling_period_count = 21000  ; // 210MHz/21000   =   10 ksps // 100us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 1050000   ; // 210MHz/1050000   =  200 sps // 5ms 
        //public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        //adc_sampling_period_count = 14   ; // 210MHz/14   =  15 Msps
        //adc_sampling_period_count = 15   ; // 210MHz/15   =  14 Msps
        //adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
        //adc_sampling_period_count = 43   ; // 210MHz/43   =  4.883721 Msps //$$ 116.27907kHz image with 5MHz wave
        //adc_sampling_period_count = 106  ; // 210MHz/106  =  1.98113208 Msps //$$ 18.8679245kHz image with 2MHz wave
        //adc_sampling_period_count = 210  ; // 210MHz/210  =  1 Msps
        //adc_sampling_period_count = 211  ; // 210MHz/211  =  0.995261 Msps //$$ 4.739336kHz image with 1MHz wave
        //adc_sampling_period_count = 2100 ; // 210MHz/2100 =  0.1 Msps
        //
        //adc_sampling_period_count =  15  ; // 189MHz/14   =  13.5 Msps
        //adc_sampling_period_count =  18  ; // 189MHz/18   =  10.5 Msps
        //public static u32 adc_sampling_period_count = 1890 ; // 189MHz/1890  =  0.1 Msps
        //public static u32 adc_sampling_period_count =  38  ; // 189MHz/38   =  4.973684 Msps //$$ 26.315789kHz image with 5MHz wave
        //adc_sampling_period_count =  95  ; // 189MHz/95  =  1.98947368 Msps //$$  10.5263158kHz image with 2MHz wave
        //adc_sampling_period_count = 190  ; // 189MHz/190  =  0.994737 Msps //$$  5.263158kHz image with 1MHz wave
        //public static u32 adc_sampling_period_count = 379  ; // 189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave

        //public static s32 len_adc_data         = 1200;
        //public static s32 len_adc_data        = 6000  ; // adc samples
        

        // dac pattern gen
        
        //public static double time_ns__dac_update    = 5; // 200MHz dac update
        //public static s32    time_ns__code_duration = 5; // 5ns = 200MHz
   
        //public static double time_ns__dac_update    = 10; // 200MHz dac update
        //public static s32    time_ns__code_duration = 10; // 5ns = 200MHz

        //public static s32    output_range      = 40; // 10 or 40  
        //public static s32    output_range      = 10; // 10 or 40  

        //public static double load_impedance_ohm              = 1e6; // 1e6 vs 50
        //public static double load_impedance_ohm              = 50; // 1e6 vs 50
        
        public static double output_impedance_ohm            = 50; // on board

        //// amp gain 1
        // note 40V mode gain = scale_voltage_10V_mode * gain_voltage_10V_to_40V_mode = 8.5/10 * 3.64 = 3.094
        // note 10V mode gain = scale_voltage_10V_mode = 8.5/10 = 0.85
        // note ... ideally scale_voltage_10V_mode = (40V mode gain) / 4 = 3.094 / 4 = 0.7735
        //
        //public static double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
        //public static double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64

        //// amp gain 2
        // note 10V mode gain = scale_voltage_10V_mode =  0.7735
        // ideally, gain_voltage_10V_to_40V_mode = 4
        // note 40V mode gain = scale_voltage_10V_mode * gain_voltage_10V_to_40V_mode = 0.7735 * 4 = 3.094
        //
        //public static double scale_voltage_10V_mode          = 0.7735;
        //public static double gain_voltage_10V_to_40V_mode    = 4;

        //// amp gain 3
        // note 0x7791 / 0x6303 = 1.20759853237 
        // note 10V mode gain = scale_voltage_10V_mode =  0.7735 * 1.20759853237  = 0.9341
        // note 40V mode gain = scale_voltage_10V_mode * gain_voltage_10V_to_40V_mode = 0.9341 * 3.64 = 3.400124
        // ideally, gain_voltage_10V_to_40V_mode = 4

        //// amp gain 4 - used in T-SPACE for 0.4mV resoltuion with 10V range
        //public static double scale_voltage_10V_mode          = 0.695;
        //public static double gain_voltage_10V_to_40V_mode    = 4;        

        //// amp gain 5 - cs code for 0.4mV resoltuion with 10V range
        // 0x61ED in T-SPACE
        // 0x58F7 in cs code
        // 0x61ED/0x58F7*0.695 = 0.76500351262
        public static double scale_voltage_10V_mode          = 0.765;
        public static double gain_voltage_10V_to_40V_mode    = 4;



        // cal factor
        public static double out_scale                       = 1.0;
        public static double out_offset                      = 0.0;


        //public static s32    num_repeat_pulses = 5;
        //public static s32    num_repeat_pulses = 10;
        //public static s32    num_repeat_pulses = 1000;
        //public static s32    num_repeat_pulses = 10000;


        // dac ic
        public static double DAC_full_scale_current__mA_1 = 25.50;       // 
        public static double DAC_full_scale_current__mA_2 = 25.45;       // 
        public static float DAC_offset_current__mA_1      = (float)0.44; // 
        public static float DAC_offset_current__mA_2      = (float)0.79; // 
        public static s32   N_pol_sel_1                     = 0;           // 
        public static s32   N_pol_sel_2                     = 0;           // 
        public static s32   Sink_sel_1                      = 0;           // 
        public static s32   Sink_sel_2                      = 0;           // 


        // test pattern selection <<<<<<<
        public static int test_case__wave = 1; // 0 for pulse, 1 for sine
        //public static int test_case__wave = 0; // 0 for pulse, 1 for sine

        // test pattern sine <<<<<<

        //// case 1kHz normal sampling : 5ns dac update, 5ns code duration, range 10V, repeat 10, adc 189MHz/1890 1200 samples(=12ms).
        // 189MHz/1890  =  0.1 Msps
        // double test_freq_kHz       =  1; 
        // int len_dac_command_points = 500; //80;
        // double amplitude  = 8.0; // no distortion
        //
        //public static double test_freq_kHz       = 1; 
        //public static int len_dac_command_points = 500; 
        //public static double amplitude  = 1.0; // test 1V amp


        //// case 500kHz undersampling : 5ns dac update, 5ns code duration, range 10V, repeat 1000, adc 189MHz/379 1200 samples.
        // 189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave
        public static double test_freq_kHz       = 500; 
        public static int len_dac_command_points = 200; //40;
        //public static double amplitude  = 8.0; // no distortion in diract sample // little distortion in undersample
        //public static double amplitude  = 4.0; // no distortion
        public static double amplitude  = 1.0; // test 1V amp
        //
        public static u32    adc_base_freq_MHz         = 189      ; // MHz // 210MHz vs 189MHz
        public static u32 adc_sampling_period_count = 379  ; // 189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave
        public static s32 len_adc_data         = 1200;
        public static double time_ns__dac_update    = 5; // 200MHz dac update
        public static s32    time_ns__code_duration = 5; // 5ns = 200MHz
        public static double load_impedance_ohm              = 1e6; // 1e6 vs 50
        public static s32    output_range      = 10; // 10 or 40  
        public static s32    num_repeat_pulses = 1000;

        //// case 5MHz undersampling : 5ns dac update, 5ns code duration, range 10V, repeat 1000, adc 189MHz/38 1200 samples.
        // 189MHz/38   =  4.973684 Msps //$$ 26.315789kHz image with 5MHz wave
        // double test_freq_kHz       = 5000; 
        // int len_dac_command_points = 20; // 4
        // //double amplitude  = 8.0; // waveform distortion
        // //double amplitude  = 3.0;
        // double amplitude  = 2.0; // best waveform
        // //double amplitude  = 1.0; 
        //
        //public static double test_freq_kHz       = 5000; 
        //public static int len_dac_command_points = 20; 
        //public static double amplitude  = 1.0; // test 1V amp
        //public static double amplitude  = 2.0; // test 1V amp
        


        // test pattern pulse <<<<<<

        //// case 1us : pr 1000ns, tr 100ns, repeat 50, ADC 100ns 600 samples.
        //public static long[]   StepTime_ns  = new long[]   {      0,     50,     150,    450,    550,   1000 }; // ns
        //public static double[] StepLevel_V  = new double[] {  0.000,  0.000,  16.000, 16.000,  0.000,  0.000 }; // V

        //// case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V

        //// case 100us : pr 100000ns, tr 10000ns, repeat 5, ADC 100ns 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 10000, 20000, 30000, 40000, 50000, 70000, 80000, 100000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V

        //// case 1000us : pr 1000000 ns, tr 100000ns, repeat 5, ADC 1us 6000 samples.
        public static long[]   StepTime_ns = new long[]   {   0, 100000, 200000, 300000, 400000, 500000, 700000, 800000, 1000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        public static double[] StepLevel_V = new double[] { 0.0,  0.0, 2.0, 2.0, 4.0, 4.0, -4.0, -4.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 3.0, 3.0, 6.0, 6.0, -6.0, -6.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 5.0, 5.0, 10.0, 10.0, -10.0, -10.0,   0.0 }; // V
        //
        // public static u32    adc_base_freq_MHz         = 210  ; // MHz // 210MHz vs 189MHz
        // public static u32    adc_sampling_period_count = 210 ; // 210MHz/210  =  1 Msps 
        // //public static s32    len_adc_data              = 6000;
        // public static s32    len_adc_data              = 1200;
        // public static double time_ns__dac_update       = 10;
        // public static s32    time_ns__code_duration    = 10;
        // public static double load_impedance_ohm        = 1e6; // 1e6 vs 50
        // public static s32    output_range              = 10; // 10 or 40  
        // //public static s32    num_repeat_pulses         = 5;
        // public static s32    num_repeat_pulses         = 1;


        //// case 10000us : pr 10000000 ns, tr 1000000ns, repeat 5, ADC 10us 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 1000000, 2000000, 3000000, 4000000, 5000000, 7000000, 8000000, 10000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  20.0,  20.0,  40.0,  40.0,  -40.0,  -40.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  10.0,  10.0,  20.0,  20.0,  -20.0,  -20.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  5.0,  5.0,  10.0,  10.0,  -10.0,  -10.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  2.5,  2.5,   5.0,   5.0,   -5.0,   -5.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  4.0,  4.0,  8.0,  8.0,  -8.0,  -8.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0,  2.0,  2.0,  4.0,  4.0,  -4.0,  -4.0,   0.0 }; // V
        //
        //public static u32    adc_base_freq_MHz         = 210  ; // MHz // 210MHz vs 189MHz
        //public static u32    adc_sampling_period_count = 2100 ; // 210MHz/2100  =  0.1 Msps 
        //public static s32    len_adc_data              = 6000;
        //public static double time_ns__dac_update       = 10;
        //public static s32    time_ns__code_duration    = 10;
        //public static double load_impedance_ohm        = 1e6; // 1e6 vs 50
        //public static s32    output_range              = 10; // 10 or 40  
        //public static s32    num_repeat_pulses         = 5;


        //// case 100ms : pr 100000000 ns, tr 10000000 ns, repeat 5, ADC 100us 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 10000000, 20000000, 30000000, 40000000, 50000000, 70000000, 80000000, 100000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 2.0, 2.0, 4.0, 4.0, -4.0, -4.0,   0.0 }; // V
        // Tdata_usr = [     0, 10000000, 15000000, 60000000, 65000000, 100000000, ]
        // Vdata_usr = [ 0.000,    0.000,   20.000,   20.000,    0.000,     0.000, ] 
        //public static long[]   StepTime_ns = new long[]   {     0, 10000000, 15000000, 60000000, 65000000, 100000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,    0.000,   20.000,   20.000,    0.000,     0.000 }; // V
        //public static double[] StepLevel_V = new double[] { 0.000,    0.000,   4.000,   4.000,    0.000,     0.000 }; // V

        //// case 1000ms : 1000ms long pulse, tr 50m, repeat 5, ADC 1ms 6000 samples.
        // Tdata_usr = [     0, 100000000, 150 000 000, 600000000, 650000000, 1000000000, ]
        // Vdata_usr = [ 0.000,     0.000,    20.000,    20.000,     0.000,      0.000, ] 
        //public static long[]   StepTime_ns = new long[]   {     0, 100000000, 150000000, 600000000, 650000000, 1000000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,     0.000,    20.000,    20.000,     0.000,      0.000 }; // V
        
        // case 10s : 10s long pulse, tr 500m, repeat 5, ADC 10ms 6000 samples.
        // Tdata_usr = [     0, 1 000 000 000, 1 500 000 000, 6 000 000 000, 6 500 000 000, 10 000 000 000, ]
        // Vdata_usr = [ 0.000,     0.000,    20.000,    20.000,     0.000,      0.000, ] 
        //public static long[]   StepTime_ns = new long[]   {     0, 1000000000, 1500000000,6000000000, 6500000000, 10000000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; // V
        //public static double[] StepLevel_V = new double[] { 0.000,    0.000,   4.000,   4.000,    0.000,     0.000 }; // V


        //// dft calculation setup <<<<<<
        public static int  test_dft_enable = 1;
        //public static int  test_dft_enable = 0;

        // DFT compute
        //double test_freq_kHz             = 500      ; // kHz
        //int    adc_base_freq_MHz         = 189      ; // MHz
        //int    adc_sampling_period_count = 379      ;
        //int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
        ////int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling
        //int    len_dft_coef              = 378    ; // 378*3    ; //$$ must check integer // if failed to try multiple cycle // samples_per_cycle ratio
        //int    num_repeat_block_coef     =   2    ;
        //int    idx_offset_adc_data       = 100;

        public static int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
        //public statuc int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling
        public static int    len_dft_coef              = 378    ; // 378*3    ; //$$ must check integer // if failed to try multiple cycle // samples_per_cycle ratio
        public static int    num_repeat_block_coef     =   2    ;
        public static int    idx_offset_adc_data       = 100;



        public static void Main(string[] args)
        {
            //Your code goes hereafter
            Console.WriteLine("Hello, world!");

            //call something in TopInstrument
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SCPI_base          ", TopInstrument.SCPI_base._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "EPS_Dev            ", TopInstrument.EPS_Dev._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SPI_EMUL           ", TopInstrument.SPI_EMUL._test()));
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "PGU_control_by_lan ", TopInstrument.PGU_control_by_lan._test()));
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "PGU_control_by_eps ", TopInstrument.PGU_control_by_eps._test()));
            //
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "TOP_PGU (alias)    ", TOP_PGU._test())); // using alias
            //
            Console.WriteLine(string.Format(">>> {0} - {1} ", "ADDA_control_by_eps", TopInstrument.ADDA_control_by_eps._test()));

            int ret = 0;
            ret = TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards
            ret = TopInstrument.SPI_EMUL.__test_spi_emul(); // test SPI EMUL // test fifo on spi emulation
            
            // new adc test : adc power on // adc enable // adc init // adc fifo reset // adc update // fifo data read 
            ret = TopInstrument.ADDA_control_by_eps.__test_ADDA_control_by_eps(); 

            //ret = TOP_PGU.__test_top_pgu(); // test PGU control // must locate PGU board on slot // sel_loc_groups=0x0004, sel_loc_slots=0x0400  

            Console.WriteLine(string.Format(">>> ret = 0x{0,8:X8}",ret));

        }
    }
}
