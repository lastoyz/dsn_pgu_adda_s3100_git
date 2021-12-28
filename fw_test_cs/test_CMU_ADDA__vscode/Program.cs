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
    using s8  = System.SByte;  // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL = System.Boolean;  

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

        //// S3100 frame test slot selection:
        // loc_slot bit 0  = slot location 0
        // loc_slot bit 1  = slot location 1
        // ...
        // loc_slot bit 12 = slot location 12

        //public static uint test_loc_slot = 0x0004; // slot location 2
        //public static uint test_loc_slot = 0x0008; // slot location 3
        public static uint test_loc_slot = 0x0010; // slot location 4
        //public static uint test_loc_slot = 0x0040; // slot location 6
        //public static uint test_loc_slot = 0x0100; // slot location 8
        //public static uint test_loc_slot = 0x0200; // slot location 9
        //public static uint test_loc_slot = 0x0400; // slot location 10
        //public static uint test_loc_slot = 0x1000; // slot location 12
       
        //// frame spi channel selection:
        // loc_spi_group bit 0 = mother board spi M0
        // loc_spi_group bit 1 = mother board spi M1
        // loc_spi_group bit 2 = mother board spi M2
        public static uint test_loc_spi_group = 0x0001; // spi M0 // for GNDU, SMU
        //public static uint test_loc_spi_group = 0x0002; // spi M1 // reserved or test
        //public static uint test_loc_spi_group = 0x0004; // spi M2 // for PGU CMU, ADDA
        
        //// CMU and PGU
        //public static uint test_loc_slot__SIG   = (0x1<< 2); // slot location 2
        //public static uint test_loc_spi_group__SIG = 0x0004; // spi M2 // for PGU CMU, ADDA
        //public static uint test_loc_slot__ANL   = (0x1<< 6); // slot location 6
        //public static uint test_loc_spi_group__ANL = 0x0004; // spi M2 // for PGU CMU, ADDA
        //public static uint test_loc_slot__ADDA  = (0x1<<10); // slot location 10
        //public static uint test_loc_spi_group__ADDA = 0x0004; // spi M2 // for PGU CMU, ADDA
        //public static uint test_loc_slot__HVPGU = (0x1<< 6); // slot location 6
        //public static uint test_loc_spi_group__HVPGU = 0x0004; // spi M2 // for PGU CMU, ADDA
        
        //// HVSMU
        //public static uint test_loc_slot__HVSMU = (0x1<< 2); // slot location 2
        public static uint test_loc_slot__HVSMU = (0x1<< 3); // slot location 3
        //public static uint test_loc_slot__HVSMU = (0x1<< 4); // slot location 4
        //public static uint test_loc_slot__HVSMU = (0x1<< 6); // slot location 6
        //public static uint test_loc_slot__HVSMU = (0x1<< 9); // slot location 9
        public static uint test_loc_spi_group__HVSMU = 0x0001; // spi M0 // for GNDU, SMU

        //// GNDU
        //public static uint test_loc_slot__GNDU = (0x1<< 12); // slot location 12
        //public static uint test_loc_spi_group__GNDU = 0x0001; // spi M0 // for GNDU, SMU
        

        public static void Main(string[] args)
        {
            //Your code goes hereafter
            Console.WriteLine("Hello, world!");


            //// hvsmu fw style test 

            // call test function via class
            Console.WriteLine(">>>>>> test: SMU class");
            var dev = new TopInstrument.SMU();

            // call test function via interface
            Console.WriteLine(">>>>>> test: SMU interface ");
            TopInstrument.I_EPS    dev_itfc_eps    = dev; // basic endpoint functions
            TopInstrument.I_SMU    dev_itfc_smu    = dev; // slot management and smu functions
            TopInstrument.I_eeprom dev_itfc_eeprom = dev; // eeprom access


            // open scpi port on S3100-CPU-BASE 
            dev.my_open(test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable());
            Console.WriteLine((float)dev.get_FPGA_TMP_mC()/1000);


            // must enable spi
            dev._test__reset_spi_emul();
            dev.Delay_ms(1);
            dev._test__init__spi_emul();
            dev.Delay_ms(1);


            Console.WriteLine(">>>>>> test: slots selected ");

            // emulation slot : slot = 0, spi_ch = 0
            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS2,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M0,
                0xE0).ToString("X8")); // known pattern from 0xE0 or 0x380 : 0x33AA_CC55

            // test slot
            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS2,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M0,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS4,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M0,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS8,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS10,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)TopInstrument.SMU.__slot_cs_code__.SLOT_CS12,
                (u32)TopInstrument.SMU.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            // test scan slot
            Console.WriteLine(">>>>>> test: scan slot ");
            dev_itfc_smu.scan_frame_slot();

            
            // eeprom test on slot 3 = _SPI_SEL_SLOT(2), HVSMU
            // eeprom test on slot 0 = _SPI_SEL_SLOT(-1), HVSMU
            u32 slot_code__SMU   = dev._SPI_SEL_SLOT(2);
            u32 spi_ch_code__SMU = dev._SPI_SEL_CH_SMU();
            Console.WriteLine(">>>>>> test: eeprom ");
            // init eeprom
            Console.WriteLine("> Read Status : 0x{0,8:X8}", 
                dev_itfc_eeprom.eeprom_read_status(slot_code__SMU, spi_ch_code__SMU)
            );
            // read eeprom
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x00), 
                0x00
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x10), 
                0x10
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x20), 
                0x20
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x30), 
                0x30
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x40), 
                0x40
            );
            // test write on 0x40
            Console.WriteLine("> Send 0x{0,8:X8} at 0x{1,2:X2} ", 0x1234ABCD, 0x40);
            dev_itfc_eeprom.eeprom_write_data_u32 (slot_code__SMU, spi_ch_code__SMU, 0x40, 0x1234ABCD);
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__SMU, spi_ch_code__SMU, 0x40), 
                0x40
            );
            // test write on 0x44
            float val;
            Console.WriteLine("> Read {0} at 0x{1,2:X2} ", 
                val=dev_itfc_eeprom.eeprom__read__data_float(slot_code__SMU, spi_ch_code__SMU, 0x44), 
                0x44
            );
            if (float.IsNaN(val))
                val = 1; 
            else 
                val = (float)((val+1)*0.9);
            Console.WriteLine("> Send {0} at 0x{1,2:X2} ", val, 0x44);
            dev_itfc_eeprom.eeprom_write_data_float (slot_code__SMU, spi_ch_code__SMU, 0x44, val);
            Console.WriteLine("> Read {0} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_float(slot_code__SMU, spi_ch_code__SMU, 0x44), 
                0x44
            );
           
           // test smu functions
            Console.WriteLine(">>>>>> test: more from interface I_SMU");
            //s32 smu_ch = 2; // ch = 2, slot = 3
            //s32 smu_ch = 2; // ch = -1, slot = 0 // NG
            s32 smu_ch = 0; // ch = 0, slot = 1

            char smu_state = dev_itfc_smu.read_smu_state(smu_ch);
            Console.WriteLine("> {0} : {1} = {2} ", "read_smu_state()", "smu_state", smu_state);

            dev_itfc_smu.smu_adc_mux_v_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_v_sel()", "done");

            dev_itfc_smu.smu_adc_mux_no_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_no_sel()", "done");

            dev_itfc_smu.smu_adc_mux_v_sel_all();
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_v_sel_all()", "done");

            dev_itfc_smu.smu_adc_mux_i_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_i_sel()", "done");

            dev_itfc_smu.smu_adc_mux_i_sel_all();
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_i_sel_all()", "done");

            dev_itfc_smu.write_smu_vctrl(smu_ch, 0x0001);
            UINT16 val_uint16 = (UINT16)dev.smu_ctrl_reg[smu_ch].vctrl;
            Console.WriteLine("> {0} : {1} = {2} ", "write_smu_vctrl()", "vctrl", val_uint16);

            // test finish
            dev._test__reset_spi_emul();
            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

        }
    }
}
