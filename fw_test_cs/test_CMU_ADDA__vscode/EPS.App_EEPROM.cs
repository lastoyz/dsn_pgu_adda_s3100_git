//// EPS.App_EEPROM.cs

//// from App_EEPROM.h
//v void eeprom_reset_fifo(u32 slot, u32 spi_sel);
//v u16  eeprom_write_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_datain);
//v u16  eeprom_read_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_dataout);
//v void eeprom_write_enable(u32 slot, u32 spi_sel);
//v u16  eeprom_write_data_16B(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16);
//v void eeprom_write_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
//v u16  eeprom_read_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
//v u32  eeprom_read_status(u32 slot, u32 spi_sel);
//v u32  eeprom_send_frame (u32 slot, u32 spi_sel, u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);
//v u32  eeprom_send_frame_ep (u32 slot, u32 spi_sel, u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32);
//
//v void eeprom_write_data_u8(u32 slot, u32 spi_sel, u16 adrs, u8 data);
//v void write_data_1byte(u32 slot, u32 spi_sel, u16 adrs, u8 data);
//v void write_data_4byte(u32 slot, u32 spi_sel, u16 adrs, u32 data);
//v u32 eeprom__read__data_4byte(u32 slot, u32 spi_sel, u16 adrs);
//v void write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data);
//v float read__data_float(u32 slot, u32 spi_sel, u16 adrs);
// 
//v void  eeprom_write_data_u32(u32 slot, u32 spi_sel, u16 adrs, u32 data);     // for App_teginfo.c
//v u32   eeprom__read__data_u32(u32 slot, u32 spi_sel, u16 adrs);              // for App_teginfo.c
//v void  eeprom_write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data); // for App_teginfo.c
//v float eeprom__read__data_float(u32 slot, u32 spi_sel, u16 adrs);            // for App_teginfo.c

using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace TopInstrument{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware

    //// some interface
    interface I_eeprom {
        // for App_EEPROM.h
        u32  eeprom_read_status(u32 slot, u32 spi_sel);
        void  eeprom_write_data_u32(u32 slot, u32 spi_sel, u16 adrs, u32 data);     // for App_teginfo.c
        u32   eeprom__read__data_u32(u32 slot, u32 spi_sel, u16 adrs);              // for App_teginfo.c
        void  eeprom_write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data); // for App_teginfo.c
        float eeprom__read__data_float(u32 slot, u32 spi_sel, u16 adrs);            // for App_teginfo.c

    }

    interface I_eeprom_sub {
        // for App_EEPROM.h
        void eeprom_write_data_u8(u32 slot, u32 spi_sel, u16 adrs, u8 data);
        void write_data_1byte(u32 slot, u32 spi_sel, u16 adrs, u8 data);
        void write_data_4byte(u32 slot, u32 spi_sel, u16 adrs, u32 data);
        u32 read__data_4byte(u32 slot, u32 spi_sel, u16 adrs);
        void write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data);
        float read__data_float(u32 slot, u32 spi_sel, u16 adrs);

    }

    interface I_eeprom_eps {
        // for App_EEPROM.h
        void eeprom_reset_fifo(u32 slot, u32 spi_sel);
        u16  eeprom_write_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8[] buf_datain); // u8* --> u8[]
        u16  eeprom_read_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8[] buf_dataout); // u8* --> u8[]
        void eeprom_write_enable(u32 slot, u32 spi_sel);
        u16  eeprom_write_data_16B(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16);
        void eeprom_write_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_datain); // u8* --> u8[]
        u16  eeprom_read_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_dataout); // u8* --> u8[]
        u32  eeprom_send_frame (u32 slot, u32 spi_sel, u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);
        u32  eeprom_send_frame_ep (u32 slot, u32 spi_sel, u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32);

    }

    //// some class or enum or struct


    public partial class EPS : I_eeprom, I_eeprom_sub, I_eeprom_eps 
    {

        //// for I_eeprom 
        public void  eeprom_write_data_u32(u32 slot, u32 spi_sel, u16 adrs, u32 data)
        {
            write_data_4byte(slot, spi_sel, adrs, data);
        }
        public u32   eeprom__read__data_u32(u32 slot, u32 spi_sel, u16 adrs)
        {
            u32 ret = read__data_4byte(slot, spi_sel, adrs);
            return ret;
        }
        public void  eeprom_write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data)
        {
            write_data_float(slot, spi_sel, adrs, data);
        }
        public float eeprom__read__data_float(u32 slot, u32 spi_sel, u16 adrs)
        {
            float ret = read__data_float(slot, spi_sel, adrs);
            return ret;
        }


        //// for I_eeprom_sub
        public void eeprom_write_data_u8(u32 slot, u32 spi_sel, u16 adrs, u8 data) 
        {
            write_data_1byte(slot, spi_sel, adrs, data);
        }
        public void write_data_1byte(u32 slot, u32 spi_sel, u16 adrs, u8 data) 
        {
            // eeprom_write_data(slot, spi_sel, adrs, 1, &data); //$$ write eeprom 
            // Delay_ms(1);

            //$$ C# implement
            u8[] buf_u8 = new u8[1];
            buf_u8[0] = data;
            eeprom_write_data(slot, spi_sel, adrs, 1, buf_u8); //$$ write eeprom 
            Delay_ms(1);
        }
        public void write_data_4byte(u32 slot, u32 spi_sel, u16 adrs, u32 data) 
        {
            //$$ C# implement
           	u16 num_byte_DAT_b16 = 4;		                                     //$$ u16 num_byte_DAT_b16 = 4;		// byte
            u8[] data_32b = new u8[4];                                           //$$ u8 data_32b[4];
           	SYS_WordToHex(data, data_32b);                                       //$$ SYS_WordToHex(data, &data_32b[0]);
           	eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, data_32b);  //$$ eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, &data_32b[0]); // write eeprom 
        }
        public u32 read__data_4byte(u32 slot, u32 spi_sel, u16 adrs) 
        {

            // u8 buf[50];
            // u32 ret_u32 = 0;
            // u16 idx;
            // eeprom_read_data(slot, spi_sel, adrs, 4, &buf[0]);
            // for(idx = 0; idx < 4; idx++)
            // {
            // 	ret_u32 |= (buf[idx*4] << (idx*8));
            // }
            // return ret_u32;

            //$$ C# implement
            u8[] buf = new u8[16];
            u32 ret_u32 = 0;
            u16 idx;
            eeprom_read_data(slot, spi_sel, adrs, 4, buf);
            for(idx = 0; idx < 4; idx++)
            {
                ret_u32 |= ( (u32)buf[idx*4] << (s32)(idx*8) ); //$$ Little Endian
            }            
            return ret_u32;
        }
        public void write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data) 
        {
            //$$ C# implement
            u16 num_byte_DAT_b16 = 4;                                            //$$ u16 num_byte_DAT_b16 = 4;		// byte
            u8[] data_32b = new u8[4];                                           //$$ u8 data_32b[4];
            SYS_FloatToHex(data, data_32b);                                      //$$ SYS_FloatToHex(data, &data_32b[0]);
            eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, data_32b);  //$$ eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, &data_32b[0]); //$$ write eeprom 

        }
        public float read__data_float(u32 slot, u32 spi_sel, u16 adrs) 
        {

            // u8 buf[50];
            // float ret_u32 = 0;
            // u16 idx;
            // u8 *p;
            // eeprom_read_data(slot, spi_sel, adrs, 4, &buf[0]);
            // p = (u8 *)(&ret_u32);	
            // for(idx = 0; idx < 4; idx++)
            // {
            // 	*(p+idx) = buf[idx*4];
            // }

            //$$ C# implement
            u8[] buf = new u8[16];
            float ret_float = 0;
            eeprom_read_data(slot, spi_sel, adrs, 4, buf);
            //$$ use BitConverter
            u8[] buf_tmp = new u8[4];
            buf_tmp[0] = buf[ 0];
            buf_tmp[1] = buf[ 4];
            buf_tmp[2] = buf[ 8];
            buf_tmp[3] = buf[12];
            ret_float = BitConverter.ToSingle(buf_tmp); //$$ SYS_HexToFloat??
            return ret_float;
        }


        //// for I_eeprom_eps
        public void eeprom_reset_fifo(u32 slot, u32 spi_sel)
        {
            //$$ C# implement
            ActivateTriggerIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TI, 1);
        }
        public u16  eeprom_write_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8[] buf_datain) // u8* --> u8[]
        {
            // u16 num_bytes_DAT_b16_extend = num_bytes_DAT_b16 * 4;
            // u8 *buf_datain_32b = (u8 *)calloc(num_bytes_DAT_b16_extend, sizeof(u8));
            // u16 idx;
            // if(buf_datain_32b == NULL)
            // {
            //     free(buf_datain_32b);
            //     buf_datain_32b = NULL;
            //     return 0xFFFF;
            // }
            // for(idx = 0; idx < num_bytes_DAT_b16; idx++)
            // {
            //     memcpy(&buf_datain_32b[idx * 4], &buf_datain[idx], 1);
            // }
            // WriteToPipeIn(slot, spi_sel, EP_ADRS__MEM_PI, num_bytes_DAT_b16_extend, buf_datain_32b);
            // free(buf_datain_32b);
            // buf_datain_32b = NULL;
            // return 0;

            //$$ C# implement
            u16 num_bytes_DAT_b16_extend = (u16)(num_bytes_DAT_b16 * 4);
            u8[] buf_datain_32b = new u8[num_bytes_DAT_b16_extend]; //$$ calloc style
            u16 idx;
            for(idx = 0; idx < num_bytes_DAT_b16; idx++)
            {
                //$$ memcpy(&buf_datain_32b[idx * 4], &buf_datain[idx], 1);
                buf_datain_32b[idx*4+0] = buf_datain[idx];
                buf_datain_32b[idx*4+1] = 0;
                buf_datain_32b[idx*4+2] = 0;
                buf_datain_32b[idx*4+3] = 0;
            }
            //WriteToPipeIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_PI, num_bytes_DAT_b16_extend, buf_datain_32b); // without fifo
            //WriteToPipeIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_PI, num_bytes_DAT_b16_extend, buf_datain_32b, 1, 256); // with fifo
            WriteToPipeIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_PI, num_bytes_DAT_b16_extend, buf_datain_32b, 0); // without fifo
            buf_datain_32b = null; //$$ free
            return 0;
        }
        public u16  eeprom_read_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8[] buf_dataout) // u8* --> u8[]
        {
            //$$ C# implement : use (u32)__enum_EPA.
            u16 ret;
            u32 adrs = (u32)__enum_EPA.EP_ADRS__MEM_PO;
            u16 num_bytes_DAT_b16_extend = (u16)(num_bytes_DAT_b16 * 4);
            //ret = (u16)ReadFromPipeOut(slot, spi_sel, adrs, num_bytes_DAT_b16_extend, buf_dataout, 0); // without fifo
            //ret = (u16)ReadFromPipeOut(slot, spi_sel, adrs, num_bytes_DAT_b16_extend, buf_dataout, 0, 1, 256); // with fifo
            ret = (u16)ReadFromPipeOut(slot, spi_sel, adrs, num_bytes_DAT_b16_extend, buf_dataout, 0, 0); // without fifo
            return ret;
        }
        public void eeprom_write_enable(u32 slot, u32 spi_sel)
        {
            //  	## // CMD_WREN__96 
            //  	print('\n>>> CMD_WREN__96')
            //  	eeprom_send_frame (CMD=0x96, con_disable_SBP=1)
            eeprom_send_frame (slot, spi_sel, 0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
        }
        public u16  eeprom_write_data_16B(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16)
        {
            eeprom_write_enable(slot, spi_sel);
            u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
            u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);
            //  	## // CMD_WRITE_6C 
            //  	eeprom_send_frame (CMD=0x6C, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT, con_disable_SBP=1)
            eeprom_send_frame (slot, spi_sel, 0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
            return num_bytes_DAT_b16;
        }
        public void eeprom_write_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_datain) // u8* --> u8[]
        {
            u16 ret = num_bytes_DAT_b16;
            eeprom_reset_fifo(slot, spi_sel);
            if (num_bytes_DAT_b16 <= 16)
            {
                eeprom_write_fifo (slot, spi_sel, num_bytes_DAT_b16, buf_datain);
                eeprom_write_data_16B (slot, spi_sel, ADRS_b16, num_bytes_DAT_b16);
                ret = 0; // sent all
            }
            else
            {
                eeprom_write_fifo (slot, spi_sel, num_bytes_DAT_b16, buf_datain);
                while (true)
                {
                    eeprom_write_data_16B (slot, spi_sel, ADRS_b16, 16);
                    //
                    ADRS_b16          += 16;
                    ret               -= 16;
                    //
                    if (ret <= 16)
                    {
                        eeprom_write_data_16B (slot, spi_sel, ADRS_b16, num_bytes_DAT_b16);
                        ret            = 0;
                        break;
                    }
                }

            }
            //
            Delay_ms(5);            
        }
        public u16  eeprom_read_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_dataout) // u8* --> u8[]
        {
            u16 ret;
            eeprom_reset_fifo(slot, spi_sel);
            u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
            u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);
            //  	## // CMD_READ__03 
            //  	eeprom_send_frame (CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT)
            eeprom_send_frame (slot, spi_sel, 0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);
            ret = eeprom_read_fifo(slot, spi_sel, num_bytes_DAT_b16, buf_dataout);
            return ret;
        }
        public u32  eeprom_read_status(u32 slot, u32 spi_sel)
        {
            //$$ C# implement : use (u32)__enum_EPA.
            u32 ret;
            //  	## // CMD_RDSR__05 
            //  	print('\n>>> CMD_RDSR__05')
            //  	eeprom_send_frame (CMD=0x05) 
            eeprom_send_frame (slot, spi_sel, 0x05, 0, 0, 0, 1, 0); //
            //  	# clear TO
            ret = GetTriggerOutVector(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TO, 0xFFFFFFFF);
            //  	# read again TO for reading latched status
            ret = GetTriggerOutVector(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TO, 0xFFFFFFFF);
            //  	MUST_ZEROS = (ret>>12)&0x0F
            //  	BP1 = (ret>>11)&0x01
            //  	BP0 = (ret>>10)&0x01
            //     	WEL = (ret>> 9)&0x01
            //  	WIP = (ret>> 8)&0x01
            ret = (ret>> 8)&0xFF;
            return ret;
        }
        public u32  eeprom_send_frame (u32 slot, u32 spi_sel, u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8)
        {
            u32 ret;
            u32 set_data_WI = ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
            u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
            ret = eeprom_send_frame_ep (slot, spi_sel, set_data_WI, set_data_FDAT_WI);
            return ret;
        }
        public u32  eeprom_send_frame_ep (u32 slot, u32 spi_sel, u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32)
        {
            //$$ C# implement : use (u32)__enum_EPA.
            bool ret_bool;
            s32 cnt_loop;
            SetWireInValue(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_WI, MEM_WI_b32, 0xFFFFFFFF); 
            SetWireInValue(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_FDAT_WI, MEM_FDAT_WI_b32, 0xFFFFFFFF); 
            //  	# clear TO
            GetTriggerOutVector(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TO, 0xFFFFFFFF);
            //  	# act TI
            ActivateTriggerIn(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TI, 2);
            cnt_loop = 0;
            while (true) {
                ret_bool = IsTriggered(slot, spi_sel, (u32)__enum_EPA.EP_ADRS__MEM_TO, 0x04);
                if (ret_bool==true) {
                    break;
                }
                if(cnt_loop > (s32)EPS.__enum_SPI_CBIT.SPI_TRIG_MAX_CNT)
                {
                    // TRACE("slot %d, eeprom_send_frame_ep Trigger Time Out\r\n", slot);
                    Console.WriteLine("slot {0,4:X4}, spi_sel {1,4:X4},eeprom_send_frame_ep Trigger Time Out", slot, spi_sel);
                    break;
                }
                cnt_loop += 1;
                Delay_ms(1);
            }
            return (u32)cnt_loop; //$$ return count loop to check timeout
        }


    }
    

}
