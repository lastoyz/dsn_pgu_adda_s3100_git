using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

using TOP_HVPGU = TopInstrument.TOP_HVPGU__EPS_SPI; // EPS emulated on SPI bus

namespace __test__
{
    public class Program
    {
        //$$ note: IP ... setup for own LAN port test //{
        
        //public static string test_host_ip = "192.168.168.143"; // test dummy ip 
        //public static uint test_loc_slot = 0x0000; // slot dummy // for self LAN port test
        //public static uint test_loc_spi_group = 0x0000; // spi dummy outside  // for self LAN port test

        //}

        //public static string test_host_ip = "192.168.100.77"; // S3100-CPU_BD1
        //public static string test_host_ip = "192.168.100.78"; // S3100-CPU_BD2
        //public static string test_host_ip = "192.168.100.79"; // S3100-CPU_BD3

        //public static string test_host_ip = "192.168.100.61"; // S3100-PGU_BD1
        //public static string test_host_ip = "192.168.100.62"; // S3100-PGU_BD2
        //public static string test_host_ip = "192.168.100.63"; // S3100-PGU_BD3

        //public static string test_host_ip = "192.168.168.143"; // test dummy ip
        public static string test_host_ip = "192.168.100.143"; // test dummy ip

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

        public static uint test_loc_slot__SIG   = (0x1<< 2); // slot location 2
        public static uint test_loc_slot__ANL   = (0x1<< 6); // slot location 6
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
        
        public static void Main(string[] args)
        {
            //Your code goes hereafter
            Console.WriteLine("Hello, world!");

            //call something in TopInstrument
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SCPI_base           ", TopInstrument.SCPI_base._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "EPS_Dev             ", TopInstrument.EPS_Dev._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SPI_EMUL            ", TopInstrument.SPI_EMUL._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "HVPGU_control_by_eps", TopInstrument.HVPGU_control_by_eps._test()));
            //
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "TOP_PGU (alias)    ", TOP_PGU._test())); // using alias
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "TOP_GNDU (alias)   ", TOP_GNDU._test())); // using alias
            Console.WriteLine(string.Format(">>> {0} - {1} ", "TOP_HVPGU (alias)   ", TOP_HVPGU._test())); // using alias

            int ret = 0;
            ret = TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards
            ret = TopInstrument.SPI_EMUL.__test_spi_emul(); // test fifo on spi emulation

            // hvpgu IO test 
            //ret = TopInstrument.HVPGU_control_by_eps.__test_HVPGU_control_by_eps(); 
            
            //// dac-adc cowork test for hvpgu IO test
            //ret = TOP_HVPGU.__test_TOP_HVPGU__EPS_SPI(); 

            //// new test seq 
            // seq 0. HVPGU_ADDA__ready() 
            // seq 1. HVPGU_ADDA__trigger() 
            // seq 2. HVPGU_ADDA__read_adc_buf() 
            // seq 3. HVPGU_ADDA__standby() 

            ret = TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            ret = TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            ret = TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            ret = TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

            Console.WriteLine(string.Format(">>> ret = 0x{0,8:X8}",ret));

        }
    }
}
