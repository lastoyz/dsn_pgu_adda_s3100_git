using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

//$$namespace test_win_app_vscode
namespace __test__
{
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
