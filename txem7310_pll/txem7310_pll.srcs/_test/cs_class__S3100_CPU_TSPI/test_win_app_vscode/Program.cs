using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;


//$$namespace test_win_app_vscode
namespace __test__
{
    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware

    static class Program
    {

        public static string test_host_ip = "192.168.100.143"; // test dummy ip
        //public static string test_host_ip = "192.168.100.62"; // test adda via test lan

        //// S3100 frame slot selection:
        // loc_slot bit 0  = slot location 0
        // loc_slot bit 1  = slot location 1
        // ...
        // loc_slot bit 12 = slot location 12

        //public static uint test_loc_slot = 0x0004; // slot location 2
        //public static uint test_loc_slot = 0x0008; // slot location 3
        //public static uint test_loc_slot = 0x0010; // slot location 4
        //public static uint test_loc_slot = 0x0040; // slot location 6
        //public static uint test_loc_slot = 0x0100; // slot location 8
        //public static uint test_loc_slot = 0x0200; // slot location 9
        public static uint test_loc_slot = 0x0400; // slot location 10
        //public static uint test_loc_slot = 0x1000; // slot location 12

        //public static uint test_loc_slot__SIG   = (0x1<< 2); // slot location 2
        //public static uint test_loc_slot__ANL   = (0x1<< 6); // slot location 6
        
        //public static uint test_loc_slot__ADDA  = (0x1<< 2); // slot location 2
        public static uint test_loc_slot__ADDA  = (0x1<<10); // slot location 10

        //public static uint test_loc_slot__HVPGU = (0x1<< 4); // slot location 4
        public static uint test_loc_slot__HVPGU = (0x1<< 6); // slot location 6
        
        //// frame spi channel selection:
        // loc_spi_group bit 0 = mother board spi M0
        // loc_spi_group bit 1 = mother board spi M1
        // loc_spi_group bit 2 = mother board spi M2
        //public static uint test_loc_spi_group = 0x0001; // spi M0 // for GNDU
        //public static uint test_loc_spi_group = 0x0002; // spi M1 // for SMU
        public static uint test_loc_spi_group = 0x0004; // spi M2 // for PGU CMU, ADDA        

        ////// test conditions

        //public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 2100   ; // 210MHz/2100   =  100 ksps // 10us
        //public static u32 adc_sampling_period_count = 21000  ; // 210MHz/21000   =   10 ksps // 100us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 1050000   ; // 210MHz/1050000   =  200 sps // 5ms 
        public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        public static s32 len_adc_data        = 6000  ; // adc samples

        public static int num_repeat_pulses = 5;
        public static int    output_range   = 40; // 10 or 40  
            

        //// case 1us : pr 1000ns, tr 100ns, repeat 50, ADC 100ns 600 samples.
        //public static long[]   StepTime_ns  = new long[]   {      0,     50,     150,    450,    550,   1000 }; // ns
        //public static double[] StepLevel_V  = new double[] {  0.000,  0.000,  16.000, 16.000,  0.000,  0.000 }; // V

        //// case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V

        //// case 100us : pr 100000ns, tr 10000ns, repeat 5, ADC 100ns 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 10000, 20000, 30000, 40000, 50000, 70000, 80000, 100000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V

        //// case 100ms : pr 100000000 ns, tr 10000000 ns, repeat 5, ADC 100us 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 10000000, 20000000, 30000000, 40000000, 50000000, 70000000, 80000000, 100000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        // Tdata_usr = [     0, 10000000, 15000000, 60000000, 65000000, 100000000, ]
        // Vdata_usr = [ 0.000,    0.000,   20.000,   20.000,    0.000,     0.000, ] 
        //public static long[]   StepTime_ns = new long[]   {     0, 10000000, 15000000, 60000000, 65000000, 100000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,    0.000,   20.000,   20.000,    0.000,     0.000 }; // V

        //// case 1000ms : 1000ms long pulse, tr 50m, repeat 5, ADC 1ms 6000 samples.
        // Tdata_usr = [     0, 100000000, 150 000 000, 600000000, 650000000, 1000000000, ]
        // Vdata_usr = [ 0.000,     0.000,    20.000,    20.000,     0.000,      0.000, ] 
        //public static long[]   StepTime_ns = new long[]   {     0, 100000000, 150000000, 600000000, 650000000, 1000000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,     0.000,    20.000,    20.000,     0.000,      0.000 }; // V
        
        // case 10s : 10s long pulse, tr 500m, repeat 5, ADC 10ms 6000 samples.
        // Tdata_usr = [     0, 1 000 000 000, 1 500 000 000, 6 000 000 000, 6 500 000 000, 10 000 000 000, ]
        // Vdata_usr = [ 0.000,     0.000,    20.000,    20.000,     0.000,      0.000, ] 
        public static long[]   StepTime_ns = new long[]   {     0, 1000000000, 1500000000,6000000000, 6500000000, 10000000000 }; // ns
        public static double[] StepLevel_V = new double[] { 0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; // V




        //////

        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.SetHighDpiMode(HighDpiMode.SystemAware);
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}
