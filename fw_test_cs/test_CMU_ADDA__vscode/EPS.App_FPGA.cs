//// EPS.App_FPGA.cs

//// from App_FPGA.h
//
//v u32  __GetWireOutValue__(u32 adrs, u32 mask);
//v void __SetWireInValue__(u32 adrs, u32 data, u32 mask); 
//v void __ActivateTriggerIn__(u32 adrs, s32 loc_bit);
//v bool __IsTriggered__(u32 adrs, u32 mask);
//
//v u32 _test__reset_spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_reset_trig, u32 mask_MSPI_reset_done);
//v u32 _test__init__spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_init_trig, u32 mask_MSPI_init_done);
//v u32 _test__send_spi_frame(u32 data_C, u32 data_A, u32 data_D, u32 enable_CS_bits_16b , u32 enable_CS_group_16b,
//             u32 adrs_MSPI_CON_WI, u32 adrs_MSPI_FLAG_WO, u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, 
//             u32 adrs_MSPI_EN_CS_WI , s32 loc_bit_MSPI_frame_trig, u32 mask_MSPI_frame_done);
// 
//v u32 _read_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
//v u32 _send_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);
//
//v u32 GetWireOutValue(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
//v void SetWireInValue(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);
//v void ActivateTriggerIn(u32 slot, u32 spi_sel, u32 adrs, s32 loc_bit);
//v bool IsTriggered(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
//v u32 GetTriggerOutVector(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
// 
//x u32 SPI_EMUL__send_frame(u32 dumy_a, u32 dumy_b, u32 dumy_c);		// dumy function // not used
// 
//v u32 WriteToPipeIn(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8* data_bytearray);
//v u32 ReadFromPipeOut(u32 slot, u32 spi_sel, u16 adrs, u16 num_bytes_DAT_b16, u8 *data_bytearray, u8 dummy_leading_read_pulse);

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware

    enum __board_class_id__ 
        {
            // for top_core_info.h
            S3000_PGU        = 0xBD, // reserved
            S3000_CMU        = 0xED, // reserved
            S3100_CPU_BASE   = 0xA0, // reserved
            S3100_GNDU       = 0xA2,
            S3100_PGU_ADDA   = 0xA4,  // alias S3100_PGU_ADDA, S3100_PGU
            S3100_CMU_ADDA   = 0xA6,  // alias S3100_CMU_ADDA, S3100_ADDA
            E8000_HLSMU      = 0xA7, // reserved
            S3100_HVSMU      = 0xA8,
            S3100_CMU_SUB    = 0xAB,
            //S3100_CMU_ANAL = 0xAA,  // removed
            //S3100_CMU_SIG  = 0xAC   // removed
            S3100_PGU_SUB    = 0xAE   // alias S3100_HVPGU
        };

    
    interface I_EPS 
    {
        // for App_FPGA.h

        u32  GetWireOutValue(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF);
        void SetWireInValue(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask = 0xFFFF_FFFF);
        void ActivateTriggerIn(u32 slot, u32 spi_sel, u32 adrs, s32 loc_bit);
        bool IsTriggered(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF);
        u32  GetTriggerOutVector(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF);

        u32  WriteToPipeIn(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8[] data_bytearray); // u8* --> u8[]
        u32  ReadFromPipeOut(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8[] data_bytearray, u8 dummy_leading_read_pulse); // u8* --> u8[]


   }

    interface I_EPS_SPI 
    {
        // for App_FPGA.h

        u32 _read_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
        u32 _send_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);
        u32 _send_spi_frame_32b_mask_check__no_readback_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);

    }

    interface I_SPI_frame_gen 
    {
        // for App_FPGA.h

        u32 _test__reset_spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, s32 loc_bit_MSPI_reset_trig, u32 mask_MSPI_reset_done);
        u32 _test__init__spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, s32 loc_bit_MSPI_init_trig, u32 mask_MSPI_init_done);
        u32 _test__send_spi_frame(u32 data_C, u32 data_A, u32 data_D, u32 enable_CS_bits_16b , u32 enable_CS_group_16b,
                   u32 adrs_MSPI_CON_WI, u32 adrs_MSPI_FLAG_WO, u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, 
                   u32 adrs_MSPI_EN_CS_WI , s32 loc_bit_MSPI_frame_trig, u32 mask_MSPI_frame_done);
    }

    interface I_SPI_frame_gen_EPS 
    {
        // for App_FPGA.h

        // in ARM FW, access FPGA EPS in CPU-BASE via Host 16 bit bus interface 
        // in test LAN, access FPGA EPS in CPU-BASE via LAN SCPI protocol interface

        u32  __GetWireOutValue__(u32 adrs, u32 mask);
        void __SetWireInValue__(u32 adrs, u32 data, u32 mask); 
        void __ActivateTriggerIn__(u32 adrs, s32 loc_bit);
        bool __IsTriggered__(u32 adrs, u32 mask);

    }

    //$$ for S3100-CPU-BASE control from ARM FW
    public partial class __S3100_CPU_BASE
    { 
        public enum __enum_SPI_CADD 
        {
            // S3100 FPGA SPI CONTROL ADDRESS
            FPGA_SPI_CS_ADRS						= 0x00600000,
            FPGA_SPI_SLOT_CS_MASK_ADRS				= 0x00000000,
            FPGA_SPI_CH_SELECT_ADRS					= 0x00000004,

            FPGA_SPI_MOSI_ADRS						= 0x00700000,
            FPGA_SPI_MOSI_L_ADRS					= 0x00000000,
            FPGA_SPI_MOSI_H_ADRS					= 0x00000004,

            FPGA_SPI_MISO_ADRS						= 0x00700008,
            FPGA_SPI_MISO_L_ADRS					= 0x00000008,
            FPGA_SPI_MISO_H_ADRS					= 0x0000000C,

            FPGA_SPI_TRIG_ADRS						= 0x00700010,
            FPGA_SPI_DONE_ADRS						= 0x00700018

        };

        public enum __enum_SPI_CBIT
        {
            // S3100 FPGA SPI CONTROL BIT
            SPI_MODE_WRITE							= 0x00000000,
            SPI_MODE_READ							= 0x00000010,

            SPI_SEL_M0								= 0x00000001,			//GNDU & SMU
            // SPI_SEL_M1								= 0x00000002,		// E8000 not used
            SPI_SEL_M2								= 0x00000004,			//CMU & PGU
            SPI_SEL_EMUL 							= 0x00000000,			//emulation ... self test

            SPI_TRIG_OPT_RESET_LOC					= 0,
            SPI_TRIG_OPT_INIT_LOC					= 1,
            SPI_TRIG_OPT_FRAME_LOC	 			    = 2,

            SPI_TRIG_OPT_RESET_MSK					= 0x1<<SPI_TRIG_OPT_RESET_LOC,
            SPI_TRIG_OPT_INIT_MSK					= 0x1<<SPI_TRIG_OPT_INIT_LOC,
            SPI_TRIG_OPT_FRAME_MSK	 			    = 0x1<<SPI_TRIG_OPT_FRAME_LOC

        };

        public enum __slot_cs_code__ 
        {
            //
            SLOT_CS_EMUL                            = 0x00000000,
            SLOT_CS0								= 0x00000001 << 0,
            SLOT_CS1								= 0x00000001 << 1,
            SLOT_CS2								= 0x00000001 << 2,
            SLOT_CS3								= 0x00000001 << 3,
            SLOT_CS4								= 0x00000001 << 4,
            SLOT_CS5								= 0x00000001 << 5,
            SLOT_CS6								= 0x00000001 << 6,
            SLOT_CS7								= 0x00000001 << 7,
            SLOT_CS8								= 0x00000001 << 8,
            SLOT_CS9								= 0x00000001 << 9,
            SLOT_CS10								= 0x00000001 << 10,
            SLOT_CS11								= 0x00000001 << 11,
            SLOT_CS12								= 0x00000001 << 12
        }

    }
    
    //$$ for S3100-CPU-BASE control from test LAN
    public partial class __S3100_SPI_EMUL
    { 
        public enum __enum_SPI_CADD 
        {
            // S3100 FPGA SPI CONTROL ADDRESS
            FPGA_SPI_CS_ADRS						= 0x16, // adrs_MSPI_EN_CS_WI = 0x16
            FPGA_SPI_MOSI_ADRS						= 0x17, // adrs_MSPI_CON_WI = 0x17
            FPGA_SPI_MISO_ADRS						= 0x24, //adrs_MSPI_FLAG_WO = 0x24
            FPGA_SPI_TRIG_ADRS						= 0x42, // adrs_MSPI_TI = 0x42
            FPGA_SPI_DONE_ADRS						= 0x62 // adrs_MSPI_TO = 0x62
        };

        public enum __enum_SPI_CBIT
        {
            // S3100 FPGA SPI CONTROL BIT
            SPI_MODE_WRITE							= 0x00000000,
            SPI_MODE_READ							= 0x00000010,

            SPI_SEL_M0								= 0x00000001,			//GNDU & SMU
            // SPI_SEL_M1								= 0x00000002,		// E8000 not used
            SPI_SEL_M2								= 0x00000004,			//CMU & PGU
            SPI_SEL_EMUL 							= 0x00000000,			//emulation ... self test

            SPI_TRIG_OPT_RESET_LOC					= 0,
            SPI_TRIG_OPT_INIT_LOC					= 1,
            SPI_TRIG_OPT_FRAME_LOC	 			    = 2,

            SPI_TRIG_OPT_RESET_MSK					= 0x1<<SPI_TRIG_OPT_RESET_LOC,
            SPI_TRIG_OPT_INIT_MSK					= 0x1<<SPI_TRIG_OPT_INIT_LOC,
            SPI_TRIG_OPT_FRAME_MSK	 			    = 0x1<<SPI_TRIG_OPT_FRAME_LOC,

            SPI_TRIG_MAX_CNT                        = 99

        };

        public enum __slot_cs_code__ 
        {
            //
            SLOT_CS_EMUL                            = 0x00000000,
            SLOT_CS0								= 0x00000001 << 0,
            SLOT_CS1								= 0x00000001 << 1,
            SLOT_CS2								= 0x00000001 << 2,
            SLOT_CS3								= 0x00000001 << 3,
            SLOT_CS4								= 0x00000001 << 4,
            SLOT_CS5								= 0x00000001 << 5,
            SLOT_CS6								= 0x00000001 << 6,
            SLOT_CS7								= 0x00000001 << 7,
            SLOT_CS8								= 0x00000001 << 8,
            SLOT_CS9								= 0x00000001 << 9,
            SLOT_CS10								= 0x00000001 << 10,
            SLOT_CS11								= 0x00000001 << 11,
            SLOT_CS12								= 0x00000001 << 12
        }

        // scan slot

        // more for test LAN

    }


    //// implement interface
    public partial class EPS : I_EPS 
    {
        //// for I_EPS
        public u32  GetWireOutValue(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF)
        {
            return _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
        }
        public void SetWireInValue(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask = 0xFFFF_FFFF)
        {
            _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data, mask);
        }
        public void ActivateTriggerIn(u32 slot, u32 spi_sel, u32 adrs, s32 loc_bit)
        {
            u32 mask = (u32)(0x00000001 << loc_bit);
            u32 data = mask;
            //$$ _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data, mask);
            _send_spi_frame_32b_mask_check__no_readback_(slot, spi_sel, adrs, data, mask); //$$ rev 20210826
        }
        public bool IsTriggered(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF)
        {
            bool ret = false;
            u32 data_trig_done = _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
            if (data_trig_done != 0)
                ret = true;
            return ret;
        }
        public u32  GetTriggerOutVector(u32 slot, u32 spi_sel, u32 adrs, u32 mask = 0xFFFF_FFFF)
        {
            return _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
        }
        public u32  WriteToPipeIn(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8[] data_bytearray) // u8* --> u8[]
        {
            // u32 data_B = 0;
            // u16 idx;
            // for (idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
            // {		
            //     data_B = SYS_HexToWord(&data_bytearray[idx]);		// MSB 16bit + LSB 16bit
            //     _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);		// FIFO in
            // }
            // return num_bytes_DAT_b16;

            //$$ C# implement
            u32 data_B = 0;
            var buf_tmp = new u8[4];
            for (u32 idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
            {		
                Array.Copy(data_bytearray, idx, buf_tmp, 0, 4);
                data_B = SYS_HexToWord(buf_tmp);		// MSB 16bit + LSB 16bit
                _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);		// FIFO in
            }
            return num_bytes_DAT_b16;

        }
        public u32  ReadFromPipeOut(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8[] data_bytearray, u8 dummy_leading_read_pulse) // u8* --> u8[]
        {
            // u32 data_B    = 0;
            // if (dummy_leading_read_pulse !=0 )
            // {
            //     _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);
            // }
            // for (s32 idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
            // {		
            //     data_B = _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, 0xFFFFFFFF);
            //     SYS_WordToHex(data_B, &data_bytearray[idx]);
            // }
            // return num_bytes_DAT_b16;

            //$$ C# implement
            u32 data_B    = 0;
            var buf_tmp = new u8[4];
            if (dummy_leading_read_pulse !=0 )
            {
                _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);
            }
            for (s32 idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
            {		
                data_B = _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, 0xFFFFFFFF);
                SYS_WordToHex(data_B, buf_tmp);
                Array.Copy(buf_tmp, 0, data_bytearray, idx, 4);
            }
            return num_bytes_DAT_b16;

        }
    }

    public partial class EPS : I_EPS_SPI
    { 
        //// for I_EPS_SPI
        public u32 _read_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 mask)
        {
            u32 data_C = (u32)__enum_SPI_CBIT.SPI_MODE_READ;		// read
            u32 data_A = (adrs << 2);
            u32 data_D = 0x0000;
            // lo first
            u32 data_B_lo = 0;
            if ((mask & 0x0000FFFF) != 0) {
                data_B_lo = _test__send_spi_frame(data_C, data_A, data_D, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);
            }
            //
            u32 data_B_hi = 0;
            if ((mask & 0xFFFF0000) != 0) {
                data_B_hi = _test__send_spi_frame(data_C, data_A+2, data_D, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS , 
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);
            }
            //
            u32 data_B = ( (data_B_hi << 16) + (data_B_lo & 0x0000FFFF)) & mask; // mask off
            return data_B;
        }
        public u32 _send_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask)
        {
            u32 data_C_rd = (u32)__enum_SPI_CBIT.SPI_MODE_READ;		// read
            u32 data_C_wr = (u32)__enum_SPI_CBIT.SPI_MODE_WRITE;		// write
            u32 data_A_lo = (adrs << 2);
            u32 data_A_hi = (adrs << 2) + 2;
            u32 data_D_lo = 0x0000;
            u32 data_D_hi = 0x0000;
            u32 data_B_lo = 0;
            u32 data_B_hi = 0;
            // addres low side 
            if ((mask & 0x0000FFFF) != 0) {
                if ((mask & 0x0000FFFF) != 0xFFFF) { // need to read data first to mask off
                    data_B_lo = _test__send_spi_frame(data_C_rd, data_A_lo, data_D_lo, slot, spi_sel, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                    (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                    (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);

                    // mask off: 
                    //  data mask  new
                    //  0    0     0
                    //  0    1     0
                    //  1    0     1
                    //  1    1     0
                    data_B_lo = data_B_lo & ~(mask & 0x0000FFFF) ; // previous data with mask off
                }
                data_D_lo = (data & mask) & 0x0000FFFF; // new data with mask off
                data_D_lo = data_D_lo | data_B_lo;      // merge data
                data_B_lo = _test__send_spi_frame(data_C_wr, data_A_lo, data_D_lo, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);
            }
            // addres high side 
            if ((mask & 0xFFFF0000) != 0) {
                if ((mask & 0xFFFF0000) != 0xFFFF0000) { // need to read data first to mask off
                    data_B_hi = _test__send_spi_frame(data_C_rd, data_A_hi, data_D_hi, slot, spi_sel, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                    (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                    (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                    (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);			
                    // mask off: 
                    //  data mask  new
                    //  0    0     0
                    //  0    1     0
                    //  1    0     1
                    //  1    1     0
                    data_B_hi = data_B_hi & ~( (mask>>16) & 0x0000FFFF) ; // previous data with mask off
                }
                data_D_hi = ((data & mask)>>16) & 0x0000FFFF; // new data with mask off
                data_D_hi = data_D_hi | data_B_hi;      // merge data
                data_B_hi = _test__send_spi_frame(data_C_wr, data_A_hi, data_D_hi, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);
            }

            u32 data_B = (data_B_hi << 16) | (data_B_lo & 0x0000FFFF); // merge
            return data_B;
        }
        public u32 _send_spi_frame_32b_mask_check__no_readback_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask)
        {
            //$$ for ActivateTriggerIn()
            u32 data_C_wr = (u32)__enum_SPI_CBIT.SPI_MODE_WRITE;		// write
            u32 data_A_lo = (adrs << 2);
            u32 data_A_hi = (adrs << 2) + 2;
            u32 data_D_lo = 0x0000;
            u32 data_D_hi = 0x0000;
            u32 data_B_lo = 0;
            u32 data_B_hi = 0;
            // addres low side 
            if ((mask & 0x0000FFFF) != 0) {
                data_D_lo = (data & mask) & 0x0000FFFF; // new data with mask off
                data_B_lo = _test__send_spi_frame(data_C_wr, data_A_lo, data_D_lo, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, // adrs_MSPI_CON_WI = 0x17
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, // adrs_MSPI_FLAG_WO = 0x24
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, // adrs_MSPI_TI = 0x42
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, // adrs_MSPI_TO = 0x62
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, // adrs_MSPI_EN_CS_WI = 0x16
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, // loc_bit_MSPI_frame_trig = 2
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK); // mask_MSPI_frame_done = 0x00000004
            }
            // addres high side 
            if ((mask & 0xFFFF0000) != 0) {
                data_D_hi = ((data & mask)>>16) & 0x0000FFFF; // new data with mask off
                data_B_hi = _test__send_spi_frame(data_C_wr, data_A_hi, data_D_hi, slot, spi_sel, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MOSI_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_MISO_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS, 
                                (u32)__enum_SPI_CADD.FPGA_SPI_CS_ADRS, 
                                (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_LOC, 
                                (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_FRAME_MSK);
            }
            //
            u32 data_B = (data_B_hi << 16) | (data_B_lo & 0x0000FFFF); // merge
            return data_B;
        }

    }

    public partial class EPS : I_SPI_frame_gen 
    {
        //// for I_SPI_frame_gen 
        public u32 _test__reset_spi_emul(
            u32 adrs_MSPI_TI            = (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS    , 
            u32 adrs_MSPI_TO            = (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS    , 
            s32 loc_bit_MSPI_reset_trig = (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_RESET_LOC, 
            u32 mask_MSPI_reset_done    = (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_RESET_MSK)
        {
            //## trigger reset 
            //uint adrs_MSPI_TI = 0x42;
            //uint loc_bit_MSPI_reset_trig = 0;
            //uint adrs_MSPI_TO = 0x62;
            //uint mask_MSPI_reset_done = 0x00000001;
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_reset_trig);
            u32 cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_reset_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
                    break;
                }
            }
            return cnt_loop;
        }
        public u32 _test__init__spi_emul(
            u32 adrs_MSPI_TI           = (u32)__enum_SPI_CADD.FPGA_SPI_TRIG_ADRS    , 
            u32 adrs_MSPI_TO           = (u32)__enum_SPI_CADD.FPGA_SPI_DONE_ADRS    , 
            s32 loc_bit_MSPI_init_trig = (s32)__enum_SPI_CBIT.SPI_TRIG_OPT_INIT_LOC, 
            u32 mask_MSPI_init_done    = (u32)__enum_SPI_CBIT.SPI_TRIG_OPT_INIT_MSK)
        {
            //## trigger init 
            //uint adrs_MSPI_TI = 0x42;
            //uint loc_bit_MSPI_init_trig = 1;
            //uint adrs_MSPI_TO = 0x62;
            //uint mask_MSPI_init_done = 0x00000002;
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_init_trig);
            u32 cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_init_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
                    break;
                }
            }
            return cnt_loop;
        }
        public u32 _test__send_spi_frame(u32 data_C, u32 data_A, u32 data_D, u32 enable_CS_bits_16b , u32 enable_CS_group_16b,
                   u32 adrs_MSPI_CON_WI, u32 adrs_MSPI_FLAG_WO, u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, 
                   u32 adrs_MSPI_EN_CS_WI , s32 loc_bit_MSPI_frame_trig, u32 mask_MSPI_frame_done)
        {
            //## set spi frame data (example)
            //#data_C = 0x10   ##// for read 
            //#data_A = 0x380  ##// for address of known pattern  0x_33AA_CC55
            //#data_D = 0x0000 ##// for reading (XXXX)

            u32 data_MSPI_CON_WI = (data_C<<26) + (data_A<<16) + data_D;
            //uint adrs_MSPI_CON_WI = 0x17;
            __SetWireInValue__(adrs_MSPI_CON_WI, data_MSPI_CON_WI, 0xFFFFFFFF);

            //## set spi enable signals : {enable_CS_group_16b, enable_CS_bits_16b}
            u32 data_MSPI_EN_CS_WI = ((enable_CS_group_16b & 0x0007) <<16 ) + (enable_CS_bits_16b & 0x1FFF);
            __SetWireInValue__(adrs_MSPI_EN_CS_WI, data_MSPI_EN_CS_WI, 0xFFFFFFFF);		// SLOT CS MASK 16bit

            //## trigger frame 
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_frame_trig);

            u32 cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_frame_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //$$Console.WriteLine(string.Format("> frame done !! @ cnt_loop={0}", cnt_loop)); // test
                    break;
                }
                if(cnt_loop > (s32)EPS.__enum_SPI_CBIT.SPI_TRIG_MAX_CNT)
                {
                    // TRACE("slot %d, eeprom_send_frame_ep Trigger Time Out\r\n", slot);
                    Console.WriteLine("cnt_loop={0}, _test__send_spi_frame Trigger Time Out", cnt_loop);
                    break;
                }
            }
            
            //## read miso data
            u32 data_B;
            if (done_trig) {
                data_B = __GetWireOutValue__(adrs_MSPI_FLAG_WO, 0xFFFFFFFF);
                data_B = data_B & 0xFFFF; // data mask on low 16 bits
            }
            else {
                data_B = 0x3AC50000 | (cnt_loop & 0xFFFF); // prefix 0x3AC5 for timeout status
            }
            return data_B;
        }

    }

    public partial class __S3100_SPI_EMUL : I_SPI_frame_gen_EPS  // or __S3100_SPI_EMUL vs __S3100_TLAN
    { 
        //// for I_SPI_frame_gen_EPS
        //private u32 address_step_b16 = 4;  // 4 or 2 // for ARM FW
        public u32  __GetWireOutValue__(u32 adrs, u32 mask)
        {
            //$$ C# implement for TLAN
            //# cmd: ":EPS:WMO#Hnn #Hmmmmmmmm\n"
            //# rsp: "#H000O3245\n" 
            //
            string cmd_str = cmd_str__EPS_WMO + string.Format("#H{0,2:X2} #H{1,8:X8}\n", adrs, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
            return (uint)Convert.ToUInt32(rsp_str.Substring(2,8),16); // convert hex into uint32;

            //$$ ARM FW implement
            // CPU BASE Host Interface
            //
            // u32 ret = 0;
            // ret = FPGA_ReadSingle(adrs + address_step_b16);
            // ret = (ret<<16) | FPGA_ReadSingle(adrs) ;
            // ret = ret & mask;
            // //TRACE("GetWireOutValue adrs: 0x%08X, data: 0x%08X\r\n", adrs, ret);
            // return ret;

        }
        public void __SetWireInValue__(u32 adrs, u32 data, u32 mask)
        {
            //$$ C# implement for TLAN
            //# cmd: ":EPS:WMI#Hnn #Hnnnnnnnn #Hmmmmmmmm\n"
            //# rsp: "OK\n" or "NG\n"
            //
            string cmd_str = cmd_str__EPS_WMI + string.Format("#H{0,2:X2} #H{1,8:X8} #H{2,8:X8}\n", adrs, data, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));

            //$$ ARM FW implement
            // CPU BASE Host Interface
            //
            // u32 maskedData = data & mask;
            // FPGA_WriteSingle(adrs + address_step_b16, (maskedData>>16) & 0x0000FFFF); // write hi 16b
            // FPGA_WriteSingle(adrs + 0               , (maskedData>>0 ) & 0x0000FFFF); // write low 16b
            // //TRACE("SetWireInValue adrs: 0x%08X, data: 0x%08X\r\n", adrs, maskedData);
        }
        public void __ActivateTriggerIn__(u32 adrs, s32 loc_bit)
        {
            //$$ C# implement for TLAN
            //# cmd: ":EPS:TAC#Hnn  #Hnn\n"
            //# rsp: "OK\n" or "NG\n"
            //
            string cmd_str = cmd_str__EPS_TAC + string.Format("#H{0,2:X2} #H{1,2:X2}\n",adrs,loc_bit);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));

            //$$ ARM FW implement
            // CPU BASE Host Interface
            //
            // s32 sh_loc_bit = 0x00000001 << loc_bit;
            // FPGA_WriteSingle(adrs, sh_loc_bit);
            // //TRACE("ActivateTriggerIn adrs: 0x%08X, data: 0x%08X\r\n", adrs, loc_bit);
        }
        public bool __IsTriggered__(u32 adrs, u32 mask)
        {
            //$$ C# implement for TLAN
            //# cmd: ":EPS:TMO#H60 #H0000FFFF\n"
            //# rsp: "ON\n" or "OFF\n"
            //
            string cmd_str = cmd_str__EPS_TMO + string.Format("#H{0,2:X2} #H{1,8:X8}\n", adrs, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
            bool ret;
            if (rsp_str.Substring(0,3)=="OFF") {
                ret = false;
            }
            else if (rsp_str.Substring(0,2)=="ON") {
                ret = true;
            } else {
                ret = false; // error in response string
            }
            return ret;

            //$$ ARM FW implement
            // CPU BASE Host Interface
            //
            // u32 ret = FPGA_ReadSingle(adrs);
            // //TRACE("IsTriggered adrs: 0x%08X, data: 0x%08X\r\n", adrs, ret);
            // if(ret & mask) return 1;
            // else return 0;

        }


    }
    




}