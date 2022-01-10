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
    
    using DUT = TopInstrument.CMU;
    using I_DUT = TopInstrument.I_CMU;
    
    //using DUT = TopInstrument.PGU;
    //using I_DUT = TopInstrument.I_PGU;

    //using c_test_condition = c_test_case__pgu; // case 1. pgu pulse 
    using c_test_condition = c_test_case__cmu_normal_sample; // case 2. cmu 500kHz normal sampling
    //using c_test_condition = c_test_case__cmu_under_sample; // case 3. cmu 500kHz undersampling


    //// test condition

    public enum __enum_TEST_CASE {
        __PGU = 1000,
        __CMU_NORMAL_SAMPLE = 2000,
        __CMU_UNDER_SAMPLE  = 3000,
        TEST_CASE__Unknown = -1
    }


    public class c_test_case__pgu {
        // test control parameters
        public static int _test_case__ID  = (int)__enum_TEST_CASE.__PGU;
        //
        // DAC setup
        public static double time_ns__dac_update            = 10; // 5ns, 200MHz dac update // or 10ns
        public static int    time_ns__code_duration         = 10; // 5 or 10
        public static double load_impedance_ohm             = 1e6;
        public static double output_impedance_ohm           = 50;
        public static double scale_voltage_10V_mode         = 0.85; // 0.765
        public static double gain_voltage_10V_to_40V_mode   = 4;
        public static double out_scale                      = 1.0;
        public static double out_offset_V                   = 0.0;
        public static int    output_range_V                 = 10; // 10 or 40  
        // DAC ic setup
        public static double DAC_full_scale_current__mA_1   = 25.50;       // 
        public static double DAC_full_scale_current__mA_2   = 25.50;       // 
        public static float DAC_offset_current__mA_1        = (float)0.00; // 0~2mA
        public static float DAC_offset_current__mA_2        = (float)0.00; // 0~2mA
        public static s32   N_pol_sel_1                     = 0;           // 
        public static s32   N_pol_sel_2                     = 0;           // 
        public static s32   Sink_sel_1                      = 0;           // 
        public static s32   Sink_sel_2                      = 0;           // 
        // repeat pattern
        public static int num_repeat_pulses = 1500; // for undersampling


        //// for pgu wave info

        // case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 8.0, 8.0, 16.0, 16.0, -16.0, -16.0,   0.0 }; // V
        public static double[] StepLevel_V = new double[] { 0.0,  0.0, 1.7, 1.7, 3.4, 3.4, -3.4, -3.4,   0.0 }; // V


        //// for cmu wave info
        public static double test_freq_kHz           = 500;
        public static int    len_dac_command_points  = 200;
        public static double amplitude               = 1.0;
        //public static double phase_diff = Math.PI/2;  //$$ emulate inductor load in IV balanced circuit (adc0 = voltage, adc1 = -currrent)
        //public static double phase_diff = Math.PI;    //$$ emulate resistor load in IV balanced circuit
        public static double phase_diff = -Math.PI/2;   //$$ emulate capacitor   load in IV balanced circuit
        //public static double phase_diff = 0;          //$$ emulate neg resistor  load in IV balanced circuit

        // ADC setup
        public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 210   ; // 210MHz/210   =  1000 ksps // 1us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        //public static u32 adc_sampling_period_count = 421   ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        
        public static s32 len_adc_data        = 1800  ; // adc samples
        
        public static u32    adc_base_freq_MHz         = 210      ; // MHz // 210MHz vs 189MHz
        //public static u32    adc_base_freq_MHz         = 189      ; // MHz // 210MHz vs 189MHz
        
        //// for DFT computation

        //public static int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
        public static int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling

        //public static int    len_dft_coef              = 420    ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        public static int    len_dft_coef              = 20    ; // (1 / (500 kHz)) * (10 MHz) = 20 // for normal sampling

        public static int    num_repeat_block_coef     =   3    ;

        //public static int    idx_offset_adc_data       = 100;
        public static int    idx_offset_adc_data       = 5;
    }
    public class c_test_case__cmu_normal_sample {
        // test control parameters
        public static int _test_case__ID  = (int)__enum_TEST_CASE.__CMU_NORMAL_SAMPLE;
        //
        // DAC setup
        public static double time_ns__dac_update            = 10; // 5ns, 200MHz dac update // or 10ns
        public static int    time_ns__code_duration         = 10; // 5 or 10
        public static double load_impedance_ohm             = 1e6;
        public static double output_impedance_ohm           = 50;
        public static double scale_voltage_10V_mode         = 0.85; // 0.765
        public static double gain_voltage_10V_to_40V_mode   = 4;
        public static double out_scale                      = 1.0;
        public static double out_offset_V                   = 0.0;
        public static int    output_range_V                 = 10; // 10 or 40  
        // DAC ic setup
        public static double DAC_full_scale_current__mA_1   = 25.50;       // 
        public static double DAC_full_scale_current__mA_2   = 25.50;       // 
        public static float DAC_offset_current__mA_1        = (float)0.00; // 0~2mA
        public static float DAC_offset_current__mA_2        = (float)0.00; // 0~2mA
        public static s32   N_pol_sel_1                     = 0;           // 
        public static s32   N_pol_sel_2                     = 0;           // 
        public static s32   Sink_sel_1                      = 0;           // 
        public static s32   Sink_sel_2                      = 0;           // 
        // repeat pattern
        public static int num_repeat_pulses = 1500; // for undersampling


        //// for pgu wave info

        // case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 8.0, 8.0, 16.0, 16.0, -16.0, -16.0,   0.0 }; // V
        public static double[] StepLevel_V = new double[] { 0.0,  0.0, 1.7, 1.7, 3.4, 3.4, -3.4, -3.4,   0.0 }; // V


        //// for cmu wave info
        public static double test_freq_kHz           = 500;
        public static int    len_dac_command_points  = 200;
        public static double amplitude               = 1.0;
        //public static double phase_diff = Math.PI/2;  //$$ emulate inductor load in IV balanced circuit (adc0 = voltage, adc1 = -currrent)
        //public static double phase_diff = Math.PI;    //$$ emulate resistor load in IV balanced circuit
        public static double phase_diff = -Math.PI/2;   //$$ emulate capacitor   load in IV balanced circuit
        //public static double phase_diff = 0;          //$$ emulate neg resistor  load in IV balanced circuit

        // ADC setup
        public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 210   ; // 210MHz/210   =  1000 ksps // 1us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        //public static u32 adc_sampling_period_count = 421   ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        
        public static s32 len_adc_data        = 1800  ; // adc samples
        
        public static u32    adc_base_freq_MHz         = 210      ; // MHz // 210MHz vs 189MHz
        //public static u32    adc_base_freq_MHz         = 189      ; // MHz // 210MHz vs 189MHz
        
        //// for DFT computation

        //public static int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
        public static int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling

        //public static int    len_dft_coef              = 420    ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        public static int    len_dft_coef              = 20    ; // (1 / (500 kHz)) * (10 MHz) = 20 // for normal sampling

        public static int    num_repeat_block_coef     =   3    ;

        //public static int    idx_offset_adc_data       = 100;
        public static int    idx_offset_adc_data       = 5;
    }
    public class c_test_case__cmu_under_sample {
        // test control parameters
        public static int _test_case__ID  = (int)__enum_TEST_CASE.__CMU_UNDER_SAMPLE;

        ////// test conditions for adda

        // DAC setup
        public static double time_ns__dac_update            = 10; // 5ns, 200MHz dac update // or 10ns
        public static int    time_ns__code_duration         = 10; // 5 or 10
        public static double load_impedance_ohm             = 1e6;
        public static double output_impedance_ohm           = 50;
        public static double scale_voltage_10V_mode         = 0.85; // 0.765
        public static double gain_voltage_10V_to_40V_mode   = 4;
        public static double out_scale                      = 1.0;
        public static double out_offset_V                   = 0.0;
        public static int    output_range_V                 = 10; // 10 or 40  
        // DAC ic setup
        public static double DAC_full_scale_current__mA_1   = 25.50;       // 
        public static double DAC_full_scale_current__mA_2   = 25.50;       // 
        public static float DAC_offset_current__mA_1        = (float)0.00; // 0~2mA
        public static float DAC_offset_current__mA_2        = (float)0.00; // 0~2mA
        public static s32   N_pol_sel_1                     = 0;           // 
        public static s32   N_pol_sel_2                     = 0;           // 
        public static s32   Sink_sel_1                      = 0;           // 
        public static s32   Sink_sel_2                      = 0;           // 
        // repeat pattern
        public static int num_repeat_pulses = 1500; // for undersampling


        //// for pgu wave info

        // case 10us : pr 10000ns, tr 1000ns, repeat 5, ADC 100ns 600 samples.
        public static long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 16.0, 16.0, 32.0, 32.0, -32.0, -32.0,   0.0 }; // V
        //public static double[] StepLevel_V = new double[] { 0.0,  0.0, 8.0, 8.0, 16.0, 16.0, -16.0, -16.0,   0.0 }; // V
        public static double[] StepLevel_V = new double[] { 0.0,  0.0, 1.7, 1.7, 3.4, 3.4, -3.4, -3.4,   0.0 }; // V


        //// for cmu wave info
        public static double test_freq_kHz           = 500;
        public static int    len_dac_command_points  = 200;
        public static double amplitude               = 1.0;
        //public static double phase_diff = Math.PI/2;  //$$ emulate inductor load in IV balanced circuit (adc0 = voltage, adc1 = -currrent)
        //public static double phase_diff = Math.PI;    //$$ emulate resistor load in IV balanced circuit
        public static double phase_diff = -Math.PI/2;   //$$ emulate capacitor   load in IV balanced circuit
        //public static double phase_diff = 0;          //$$ emulate neg resistor  load in IV balanced circuit

        // ADC setup
        //public static u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps // 100ns
        //public static u32 adc_sampling_period_count = 210   ; // 210MHz/210   =  1000 ksps // 1us
        //public static u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps // 1ms
        //public static u32 adc_sampling_period_count = 2100000   ; // 210MHz/2100000   =  100 sps // 10ms
        public static u32 adc_sampling_period_count = 421   ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        
        public static s32 len_adc_data        = 1800  ; // adc samples
        
        public static u32    adc_base_freq_MHz         = 210      ; // MHz // 210MHz vs 189MHz
        //public static u32    adc_base_freq_MHz         = 189      ; // MHz // 210MHz vs 189MHz
        
        //// for DFT computation

        public static int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
        //public static int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling

        public static int    len_dft_coef              = 420    ; // (210MHz/421)/(500kHz-210MHz/421) = 420 // for undersampling 
        //public static int    len_dft_coef              = 20    ; // (1 / (500 kHz)) * (10 MHz) = 20 // for normal sampling

        public static int    num_repeat_block_coef     =   3    ;

        //public static int    idx_offset_adc_data       = 100;
        public static int    idx_offset_adc_data       = 5;
    }

    public class Program : c_test_condition
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
            /*
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

            // dac setup
            dev_itfc_dut.adda_init(slot_sel_code__adda, spi_chnl_code__adda, 
                len_adc_data                , 
                adc_sampling_period_count   ,
                adc_base_freq_MHz           ,
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

            // wave data
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1

            if (_test_case__ID  == (int)__enum_TEST_CASE.__PGU) 
            {
                // adda_setup_pgu_waveform()
                time_volt_dual_list = dev_itfc_dut.adda_setup_pgu_waveform(
                    slot_sel_code__adda, spi_chnl_code__adda, 
                    // PGU wave info
                    StepTime_ns, StepLevel_V,
                    // setup dac output
                    output_range_V                ,
                    time_ns__code_duration      ,
                    load_impedance_ohm          ,
                    output_impedance_ohm        ,
                    scale_voltage_10V_mode      ,
                    gain_voltage_10V_to_40V_mode,
                    out_scale                   ,
                    out_offset_V                  ,
                    // setup repeat
                    num_repeat_pulses
                );
            }
            else if (_test_case__ID  == (int)__enum_TEST_CASE.__CMU_NORMAL_SAMPLE || 
                     _test_case__ID  == (int)__enum_TEST_CASE.__CMU_UNDER_SAMPLE ) 
            {
                // adda_setup_cmu_waveform()
                time_volt_dual_list = dev_itfc_dut.adda_setup_cmu_waveform(
                    slot_sel_code__adda, spi_chnl_code__adda, 
                    // CMU wave info
                    test_freq_kHz           ,
                    len_dac_command_points  ,
                    amplitude               ,
                    phase_diff              ,
                    // setup dac output
                    output_range_V                ,
                    time_ns__code_duration      ,
                    load_impedance_ohm          ,
                    output_impedance_ohm        ,
                    scale_voltage_10V_mode      ,
                    gain_voltage_10V_to_40V_mode,
                    out_scale                   ,
                    out_offset_V                  ,
                    // setup repeat
                    num_repeat_pulses
                );
            }
            else {
                return;// unknown case
            }

            // adda_trigger_pgu_output()
            dev_itfc_dut.adda_trigger_pgu_output(slot_sel_code__adda, spi_chnl_code__adda);


            //// adc buffer read and write log file

            // adda_wait_for_adc_done()
            dev_itfc_dut.adda_wait_for_adc_done(slot_sel_code__adda, spi_chnl_code__adda);

            // adda_trigger_pgu_off()
            dev_itfc_dut.adda_trigger_pgu_off(slot_sel_code__adda, spi_chnl_code__adda);

            // adda_read_adc_buf()
            s32[] adc0_s32_buf = new s32[len_adc_data];
            s32[] adc1_s32_buf = new s32[len_adc_data];
            string buf_time_str = String.Join(", ", time_volt_dual_list.Item1);
            string buf_dac0_str = String.Join(", ", time_volt_dual_list.Item2);
            string buf_dac1_str = String.Join(", ", time_volt_dual_list.Item3);
            //Console.WriteLine("> buf_time_str =" + buf_time_str);
            //Console.WriteLine("> buf_dac0_str =" + buf_dac0_str);
            //Console.WriteLine("> buf_dac1_str =" + buf_dac1_str);
            //
            dev_itfc_dut.adda_read_adc_buf(slot_sel_code__adda, spi_chnl_code__adda, 
                len_adc_data,
                adc0_s32_buf,
                adc1_s32_buf,
                buf_time_str,
                buf_dac0_str,
                buf_dac1_str);
            
            //// calculate dft and write log file
            if (_test_case__ID  == (int)__enum_TEST_CASE.__CMU_UNDER_SAMPLE ||
                _test_case__ID  == (int)__enum_TEST_CASE.__CMU_NORMAL_SAMPLE
                ) 
            {
                // adda_compute_dft()
                var ret__dft_compute = dev_itfc_dut.adda_compute_dft(
                    test_freq_kHz            , // dft parameters
                    adc_base_freq_MHz        , //
                    adc_sampling_period_count, //
                    mode_undersampling       , //
                    len_dft_coef             , //
                    num_repeat_block_coef    , // adc data inputs
                    idx_offset_adc_data      , //
                    len_adc_data             , //
                    adc0_s32_buf             , //
                    adc1_s32_buf               //
                );
            }


            //// finish test 
            dev_itfc_dut.adda_pwr_off(slot_sel_code__adda, spi_chnl_code__adda);
            */


            // test finish
            dev._test__reset_spi_emul();
            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

        }
    }
}
