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

    //// assign DUT
    //using DUT = TopInstrument.SMU;
    //using I_DUT = TopInstrument.I_SMU;
    using DUT = TopInstrument.CMU;
    using I_DUT = TopInstrument.I_CMU;
    //using DUT = TopInstrument.PGU;
    //using I_DUT = TopInstrument.I_PGU;

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

        //public static string test_host_ip = "192.168.100.51"; // S3100-CMU_BD1
        //public static string test_host_ip = "192.168.100.52"; // S3100-CMU_BD2
        //public static string test_host_ip = "192.168.100.53"; // S3100-CMU_BD3

        //public static string test_host_ip = "192.168.168.143"; // test dummy ip
        public static string test_host_ip = "192.168.100.143"; // S3100-CPU-BASE test port

        //// S3100 frame test slot selection:
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
        //public static uint test_loc_slot = 0x0400; // slot location 10
        //public static uint test_loc_slot = 0x1000; // slot location 12
       
        //// frame spi channel selection:
        // loc_spi_group bit 0 = mother board spi M0
        // loc_spi_group bit 1 = mother board spi M1
        // loc_spi_group bit 2 = mother board spi M2
        //public static uint test_loc_spi_group = 0x0001; // spi M0 // for GNDU, SMU
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
        //public static uint test_loc_slot__HVSMU = (0x1<< 3); // slot location 3
        //public static uint test_loc_slot__HVSMU = (0x1<< 4); // slot location 4
        //public static uint test_loc_slot__HVSMU = (0x1<< 6); // slot location 6
        //public static uint test_loc_slot__HVSMU = (0x1<< 9); // slot location 9
        //public static uint test_loc_spi_group__HVSMU = 0x0001; // spi M0 // for GNDU, SMU

        //// GNDU
        //public static uint test_loc_slot__GNDU = (0x1<< 12); // slot location 12
        //public static uint test_loc_spi_group__GNDU = 0x0001; // spi M0 // for GNDU, SMU
        

        ////// test conditions for adda

        public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 210   ; // 210MHz/210   =  1000 ksps // 1us
        //public static u32 adc_sampling_period_count = 2100   ; // 210MHz/2100   =  100 ksps // 10us
        //public static u32 adc_sampling_period_count = 21000  ; // 210MHz/21000   =   10 ksps // 100us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 1050000   ; // 210MHz/1050000   =  200 sps // 5ms 
        //public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        //public static s32 len_adc_data        = 6000  ; // adc samples
        public static s32 len_adc_data        = 600  ; // adc samples

        public static int num_repeat_pulses = 5;
        public static int    output_range   = 10; // 10 or 40  
            

        //// case 1us : pr 1000ns, tr 100ns, repeat 50, ADC 100ns 600 samples.
        //public static long[]   StepTime_ns  = new long[]   {      0,     50,     150,    450,    550,   1000 }; // ns
        //public static double[] StepLevel_V  = new double[] {  0.000,  0.000,  16.000, 16.000,  0.000,  0.000 }; // V

        //// case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 8.0, 8.0, 16.0, 16.0, -16.0, -16.0,   0.0 }; // V
        public static double[] StepLevel_V = new double[] { 0.0,  0.0, 1.7, 1.7, 3.4, 3.4, -3.4, -3.4,   0.0 }; // V

        //// case 100us : pr 100000ns, tr 10000ns, repeat 5, ADC 100ns 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 10000, 20000, 30000, 40000, 50000, 70000, 80000, 100000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V

        //// case 1000us : pr 1000000 ns, tr 100000ns, repeat 5, ADC 1us 6000 samples.
        //public static long[]   StepTime_ns = new long[]   {   0, 100000, 200000, 300000, 400000, 500000, 700000, 800000, 1000000 }; // ns
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
        //public static long[]   StepTime_ns = new long[]   {     0, 1000000000, 1500000000,6000000000, 6500000000, 10000000000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; // V




        public static void Main(string[] args)
        {
            //Your code goes hereafter
            Console.WriteLine("Hello, world!");


            //// hvsmu fw style test 

            // call test function via class
            Console.WriteLine(">>>>>> test: DUT class");
            var dev = new DUT();

            // call test function via interface
            Console.WriteLine(">>>>>> test: DUT interface ");
            TopInstrument.I_EPS    dev_itfc_eps    = dev; // basic endpoint functions
            I_DUT                  dev_itfc_dut    = dev; // slot management and dut functions
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
                (u32)DUT.__slot_cs_code__.SLOT_CS_EMUL,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_EMUL,
                0xE0).ToString("X8")); // known pattern from 0xE0 or 0x380 : 0x33AA_CC55

            // test slot
            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)DUT. __slot_cs_code__.SLOT_CS2,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_M0,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)DUT.__slot_cs_code__.SLOT_CS4,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_M0,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)DUT.__slot_cs_code__.SLOT_CS8,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)DUT.__slot_cs_code__.SLOT_CS10,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            Console.WriteLine(dev_itfc_eps.GetWireOutValue(
                (u32)DUT.__slot_cs_code__.SLOT_CS12,
                (u32)DUT.__enum_SPI_CBIT.SPI_SEL_M2,
                0x20).ToString("X8")); // FID

            // test scan slot
            Console.WriteLine(">>>>>> test: scan slot ");
            dev_itfc_dut.scan_frame_slot();
            //$$ example display on console:
            //$$ ----------------------------------------------------------
            //$$ # <Not Detect Board on Slot 0>
            //$$ # <Not Detect Board on Slot 1>
            //$$ # <Detect Board on Slot 2: S3100-HVSMU, Ver 0xA8211123>
            //$$ # <Not Detect Board on Slot 3>
            //$$ # <Detect Board on Slot 4: S3100-PGU-ADDA, Ver 0xA4211207>
            //$$ # <Not Detect Board on Slot 5>
            //$$ # <Detect Board on Slot 6: S3100-PGU-SUB, Ver 0xAE2110A8>
            //$$ # <Not Detect Board on Slot 7>
            //$$ # <Detect Board on Slot 8: S3100-GNDU, Ver 0xA2210728>
            //$$ # <Detect Board on Slot 9: S3100-CMU-ADDA, Ver 0xA6211231>
            //$$ # <Not Detect Board on Slot 10>
            //$$ # <Detect Board on Slot 11: S3100-CMU-SUB, Ver 0xAB211102>
            //$$ # <Detect Board on Slot 12: S3100-CMU-SUB, Ver 0xAB211102>
            
            
            Console.WriteLine(">>>>>> test: eeprom ");

            // eeprom test on slot 11 = _SPI_SEL_SLOT(10), S3100-CMU-SUB
            u32 slot_code__dut_eeprom   = dev._SPI_SEL_SLOT(10);
            //u32 slot_code__dut_eeprom   = dev._SPI_SEL_SLOT_EMUL();

            //u32 spi_ch_code__dut_eeprom = dev._SPI_SEL_CH_SMU(); // M0
            u32 spi_ch_code__dut_eeprom = dev._SPI_SEL_CH_CMU(); // M2
            //u32 spi_ch_code__dut_eeprom = dev._SPI_SEL_CH_EMUL();

            // init eeprom
            Console.WriteLine("> Read Status : 0x{0,8:X8}", 
                dev_itfc_eeprom.eeprom_read_status(slot_code__dut_eeprom, spi_ch_code__dut_eeprom)
            );
            // read eeprom
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x00), 
                0x00
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x10), 
                0x10
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x20), 
                0x20
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x30), 
                0x30
            );
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x40), 
                0x40
            );
            // test write on 0x40
            u32 test_dat_u32 = 0x1234ABCD; // 0x56784321; // 
            Console.WriteLine("> Send 0x{0,8:X8} at 0x{1,2:X2} ", test_dat_u32, 0x40);
            dev_itfc_eeprom.eeprom_write_data_u32 (slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x40, test_dat_u32);
            Console.WriteLine("> Read 0x{0,8:X8} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_u32(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x40), 
                0x40
            );
            // test write on 0x44
            float val;
            Console.WriteLine("> Read {0} at 0x{1,2:X2} ", 
                val=dev_itfc_eeprom.eeprom__read__data_float(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x44), 
                0x44
            );
            if (float.IsNaN(val))
                val = 1; 
            else 
                val = (float)((val+1)*0.9);
            Console.WriteLine("> Send {0} at 0x{1,2:X2} ", val, 0x44);
            dev_itfc_eeprom.eeprom_write_data_float (slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x44, val);
            Console.WriteLine("> Read {0} at 0x{1,2:X2} ", 
                dev_itfc_eeprom.eeprom__read__data_float(slot_code__dut_eeprom, spi_ch_code__dut_eeprom, 0x44), 
                0x44
            );

            // test cmu functions :
            //   test spio, clkd, dac, adc, dft
            u32 slot_sel_code__adda    = dev._SPI_SEL_SLOT(8); // slot 9
            u32 spi_chnl_code__adda    = dev._SPI_SEL_CH_CMU();
            u32 slot_sel_code__cmu_sig = dev._SPI_SEL_SLOT(10); // slot 11
            u32 spi_chnl_code__cmu_sig = dev._SPI_SEL_CH_CMU();
            u32 slot_sel_code__cmu_anl = dev._SPI_SEL_SLOT(11); // slot 12
            u32 spi_chnl_code__cmu_anl = dev._SPI_SEL_CH_CMU();

            //// cmu sub board ID check
            // note : board class ID[3:0]
            //  [S3100-CMU-SIG] = 0x8
            //  [S3100-CMU-ANL] = 0x9
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_fid   (slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig) ));
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",
                dev_itfc_dut.cmu__dev_get_temp_C(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig) ));
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_stat  (slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig) ));
            if (dev_itfc_dut.cmu__dev_is_SIG_board(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig)==1)
                Console.WriteLine("S3100-CMU-SIG is found.");
            else 
                Console.WriteLine("S3100-CMU-SIG is missing.");
            //
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_fid   (slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl) ));
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",
                dev_itfc_dut.cmu__dev_get_temp_C(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl) ));
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_stat  (slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl) ));
            if (dev_itfc_dut.cmu__dev_is_ANL_board(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl)==1)
                Console.WriteLine("S3100-CMU-ANL is found.");
            else 
                Console.WriteLine("S3100-CMU-ANL is missing.");
            
            //// cmu sub board control for [S3100-CMU-SIG]
            // to come
            // CMU-SIG init
            dev_itfc_dut.cmu_init_sig(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig); 
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_stat  (slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig) ));

            // test DACP_WI
            dev_itfc_dut.cmu_set_sig_dacp(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0xF35,1,1,1,1); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_itfc_dut.cmu_set_sig_dacp(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x3CA,1,0,1,0); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_itfc_dut.cmu_set_sig_dacp(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0xC35,0,1,0,1); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_itfc_dut.cmu_set_sig_dacp(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)

            // test EXT_WI
            dev_itfc_dut.cmu_set_sig_extc(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  1); //(u32 val = 0)
            dev_itfc_dut.cmu_set_sig_extc(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0); //(u32 val = 0)

            // test FILT_WI
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x00,0x00,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x01,0x01,0xE); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x02,0x02,0xD); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x04,0x04,0xB); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x08,0x08,0x7); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x10,0x10,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig,  0x20,0x20,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_itfc_dut.cmu_set_sig_filt(slot_sel_code__cmu_sig, spi_chnl_code__cmu_sig); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)

            //// cmu sub board control for [S3100-CMU-ANL]
            // CMU-ANL init
            dev_itfc_dut.cmu_init_anl(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl); 
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu__dev_get_stat  (slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl) ));

            // test RRIV_WI
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x0,0x0,0x0,0x0) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x1,0x0,0x0,0x1,0x8) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x2,0x0,0x1,0x2,0x4) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x1,0x2,0x4,0x2) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x2,0x0,0x8,0x1) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_itfc_dut.cmu_set_anl_rr_iv(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl); //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 

            // test DET_WI
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x0,0x0); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x1,0x0,0x1); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x1,0x1,0x2); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x2,0x2,0x1); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x2,0x0,0x2); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_itfc_dut.cmu_set_anl_det_mod(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)

            // test AMP_WI
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x0,0x0,0x0); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x1,0x1,0x1); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x1,0x1,0x1,0x2); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x1,0x2,0x0,0x4); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x2,0x2,0x0,0x1); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x2,0x4,0x2,0x2); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0x0,0x4,0x2,0x4); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_itfc_dut.cmu_set_anl_amp_gain(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl) ; //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)

            // test STAT_WO
            Console.WriteLine(string.Format("CMU_ANL UNBAL   = 0x{0,8:X8} ",
                dev_itfc_dut.cmu_get_anl_stat__unbal(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl)   ));
            Console.WriteLine(string.Format("CMU_ANL DCBA_D  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu_get_anl_stat__dcba_d(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl)  ));
            Console.WriteLine(string.Format("CMU_ANL DCBA_R  = 0x{0,8:X8} ",
                dev_itfc_dut.cmu_get_anl_stat__dcba_r(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl)  ));

            // test DACQ
            dev_itfc_dut.cmu_set_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl); //(float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0)

            dev_itfc_dut.cmu_set_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  0,1,-1,0);
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  4) ));

            dev_itfc_dut.cmu_set_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  5,10,-10,-5);
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  4) ));

            dev_itfc_dut.cmu_set_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl); //(float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0)
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_itfc_dut.cmu_get_anl_dacq(slot_sel_code__cmu_anl, spi_chnl_code__cmu_anl,  4) ));

            
            //// adc-dac ready

            // adc-dac power on
            dev_itfc_dut.adda_pwr_on(slot_sel_code__adda, spi_chnl_code__adda);

            // adc setup
            s32 len_adc_data              = __test__.Program.len_adc_data;
            u32 adc_sampling_period_count = __test__.Program.adc_sampling_period_count;
            // dac setup
            //double time_ns__dac_update         = 5; // 200MHz dac update
            double time_ns__dac_update           = 10; // 100MHz dac update
            double DAC_full_scale_current__mA_1  = 25.5; //25.5; // 25.50;       // for BD2
            double DAC_full_scale_current__mA_2  = 25.5; //25.3; // 25.45;       // for BD2
            float  DAC_offset_current__mA_2      = (float)0.00; // (float)0.79; // for BD2 // 0~2mA
            float  DAC_offset_current__mA_1      = (float)0.00; // (float)0.44; // for BD2 // 0~2mA
            int    N_pol_sel_1                   = 0;           // 0;           // for BD2
            int    N_pol_sel_2                   = 0;           // 0;           // for BD2
            int    Sink_sel_1                    = 0;           // 0;           // for BD2
            int    Sink_sel_2                    = 0;           // 0;           // for BD2
            //
            dev_itfc_dut.adda_init(slot_sel_code__adda, spi_chnl_code__adda, 
                len_adc_data, adc_sampling_period_count,
                time_ns__dac_update         ,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2                  
                );

            // cmu io control may come

            
            //// adc-dac trigger

            // pgu waveform style vs cmu waveform style

            // wave setup
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1

            // DAC setup
            int    time_ns__code_duration          = 10; // 5 or 10
            double load_impedance_ohm              = 1e6;
            double output_impedance_ohm            = 50;
            double scale_voltage_10V_mode          = 0.85; // 0.765
            double gain_voltage_10V_to_40V_mode    = 4;
            double out_scale                       = 1.0;
            double out_offset                      = 0.0;

            // for CMU wave info
            double test_freq_kHz           = 500;
            int    len_dac_command_points  = 200;
            double amplitude               = 1.0;
            double phase_diff              = Math.PI/2;
            //double phase_diff = Math.PI/2;  //$$ inductor load in IV balanced circuit (adc0 = voltage, adc1 = -currrent)
            //double phase_diff = Math.PI;    //$$ resistor load in IV balanced circuit
            //double phase_diff = -Math.PI/2;   //$$ capacitor   load in IV balanced circuit
            //double phase_diff = 0;          //$$ neg resistor  load in IV balanced circuit

            // adda_setup_pgu_waveform()
            time_volt_dual_list = dev_itfc_dut.adda_setup_pgu_waveform(
                slot_sel_code__adda, spi_chnl_code__adda, 
                // PGU wave info
                StepTime_ns, StepLevel_V,
                // setup dac output
                output_range                ,
                time_ns__code_duration      ,
                load_impedance_ohm          ,
                output_impedance_ohm        ,
                scale_voltage_10V_mode      ,
                gain_voltage_10V_to_40V_mode,
                out_scale                   ,
                out_offset                  ,
                // setup repeat
                num_repeat_pulses
            );

            time_volt_dual_list = dev_itfc_dut.adda_setup_cmu_waveform(
                slot_sel_code__adda, spi_chnl_code__adda, 
                // CMU wave info
                test_freq_kHz           ,
                len_dac_command_points  ,
                amplitude               ,
                phase_diff              ,
                // setup dac output
                output_range                ,
                time_ns__code_duration      ,
                load_impedance_ohm          ,
                output_impedance_ohm        ,
                scale_voltage_10V_mode      ,
                gain_voltage_10V_to_40V_mode,
                out_scale                   ,
                out_offset                  ,
                // setup repeat
                num_repeat_pulses
            );

            //string buf_dac_time_str = String.Join(", ", time_volt_dual_list.Item1);
            //string buf_dac0_str     = String.Join(", ", time_volt_dual_list.Item2);
            //string buf_dac1_str     = String.Join(", ", time_volt_dual_list.Item3);



            // adda_trigger_pgu_output()
            dev_itfc_dut.adda_trigger_pgu_output(slot_sel_code__adda, spi_chnl_code__adda);


            //// adc buffer read

            // adda_wait_for_adc_done()
            dev_itfc_dut.adda_wait_for_adc_done(slot_sel_code__adda, spi_chnl_code__adda);

            // adda_trigger_pgu_off()
            dev_itfc_dut.adda_trigger_pgu_off(slot_sel_code__adda, spi_chnl_code__adda);

            // adda_read_adc_buf()
            dev_itfc_dut.adda_read_adc_buf(slot_sel_code__adda, spi_chnl_code__adda, 
                len_adc_data); //(len_adc_data, buf_dac_time_str, buf_dac0_str, buf_dac1_str);
            

            //// calculate dft

            // adda_compute_dft() //$$ new
            dev_itfc_dut.adda_compute_dft();


            //// finish test 
            dev_itfc_dut.adda_pwr_off(slot_sel_code__adda, spi_chnl_code__adda);


            // test smu functions :
            /*
            Console.WriteLine(">>>>>> test: more from interface I_SMU");
            //s32 smu_ch = 2; // ch = 2, slot = 3
            //s32 smu_ch = 2; // ch = -1, slot = 0 // NG
            s32 smu_ch = 0; // ch = 0, slot = 1

            char smu_state = dev_itfc_dut.read_smu_state(smu_ch);
            Console.WriteLine("> {0} : {1} = {2} ", "read_smu_state()", "smu_state", smu_state);

            dev_itfc_dut.smu_adc_mux_v_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_v_sel()", "done");

            dev_itfc_dut.smu_adc_mux_no_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_no_sel()", "done");

            dev_itfc_dut.smu_adc_mux_v_sel_all();
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_v_sel_all()", "done");

            dev_itfc_dut.smu_adc_mux_i_sel(smu_ch);
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_i_sel()", "done");

            dev_itfc_dut.smu_adc_mux_i_sel_all();
            Console.WriteLine("> {0} : {1} ", "smu_adc_mux_i_sel_all()", "done");

            dev_itfc_dut.write_smu_vctrl(smu_ch, 0x0001);
            UINT16 val_uint16 = (UINT16)dev.smu_ctrl_reg[smu_ch].vctrl;
            Console.WriteLine("> {0} : {1} = {2} ", "write_smu_vctrl()", "vctrl", val_uint16);
            */

            // test finish
            dev._test__reset_spi_emul();
            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

        }
    }
}
