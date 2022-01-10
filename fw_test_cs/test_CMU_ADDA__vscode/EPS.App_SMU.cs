//// EPS.App_SMU.cs

//// from App_SMU.h
//...
// void scan_frame_slot(void);   // HLSMU
// void smu_adc_current(int ch); // HLSMU
// void smu_adc_voltage(int ch); // HLSMU
// char read_smu_state(int ch);  // HLSMU
//
// void smu_adc_mux_v_sel(int smu_ch);                    // HLSMU
// void smu_adc_mux_no_sel(int smu_ch);                   // HLSMU
// void smu_adc_mux_v_sel_all(void);                      // HLSMU
// void smu_adc_mux_i_sel(int smu_ch);                    // HLSMU
// void smu_adc_mux_i_sel_all(void);                      // HLSMU
// void write_smu_vdac(int smu_ch, INT32 vdac_in_val);    // HLSMU
// void write_smu_idac(int smu_ch, INT32 idac_in_val);    // HLSMU
// void write_smu_vctrl(int smu_ch, UINT16 vctrl);        // HLSMU
// void write_smu_comp_ctrl(int smu_ch, UINT8 comp_ctrl); // HLSMU
// void write_smu_ictrl(int smu_ch, UINT32 ictrl);        // HLSMU
// void write_smu_ictrl_init(int smu_ch, UINT32 ictrl);   // HLSMU
// void smu_force_rly_on(int ch);                         // HLSMU
// void smu_force_rly_off(int ch);                        // HLSMU
// void smu_force_rly_ctrl(int ch, int rly_ctrl);         // HLSMU
//
// u32 hlsmu_V_DAC_reset(u32 ch);   // HLSMU
// u32 hlsmu_V_DAC_init(u32 ch);    // HLSMU
// u32 hlsmu_I_DAC_reset(u32 ch);   // HLSMU
// u32 hlsmu_I_DAC_init(u32 ch);    // HLSMU
// u32 hlsmu_HRADC_enable(u32 ch);  // HLSMU

//// from App_SmuTest.h
//...

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
    using s8  = System.SByte;  // for converting firmware
    //
    using UINT32 = System.UInt32; // for converting firmware
    using INT32  = System.Int32;  // for converting firmware
    using UINT16 = System.UInt16; // for converting firmware
    using INT16  = System.Int16;  // for converting firmware
    using UINT8  = System.Byte;   // for converting firmware
    //
    using BOOL = System.Boolean;  

    using TSmuCtrlReg = __struct_TSmuCtrlReg;
    using TSmuCtrl    = __struct_TSmuCtrl;

    //// some interface
    public interface I_SMU {
        //// for  App_SMU.h
        
        // slot functions
        void scan_frame_slot(); // scan slot
        bool search_board_init(s8 slot, u32 fid); //(s8 slot, u32 slot_cs_code, u32 slot_ch_code, u32 fid);
        u32 _SPI_SEL_SLOT(s32 ch); // in S3100 slot 1~12 // ch = 0  => slot = 1
        u32 _SPI_SEL_SLOT_GNDU(); // in S3100-GNDU slot 0 fixed

        u32 _SPI_SEL_CH_SMU();
        u32 _SPI_SEL_CH_GNDU();
        u32 _SPI_SEL_CH_PGU();
        u32 _SPI_SEL_CH_CMU();
        

        // smu sub-devices
        char read_smu_state(int ch);

        void smu_adc_mux_v_sel(int smu_ch);
        void smu_adc_mux_no_sel(int smu_ch);
        void smu_adc_mux_v_sel_all();
        void smu_adc_mux_i_sel(int smu_ch);
        void smu_adc_mux_i_sel_all();

        void write_smu_vctrl(int smu_ch, UINT16 vctrl);
        void write_smu_comp_ctrl(int smu_ch, UINT8 comp_ctrl);
        void write_smu_ictrl(int smu_ch, UINT32 ictrl);
        void write_smu_ictrl_init(int smu_ch, UINT32 ictrl);
	    
        UINT16 to_smu_vctrl(int vrange);
        TSmuCtrl to_smu_isrc_ctrl(int smu_ch, int irange);
        TSmuCtrl to_smu_imsr_ctrl(int smu_ch, int irange);
        void write_smu_isrc_range(int smu_ch, int irange);
        void write_smu_imsr_range(int smu_ch, int irange);
        void write_smu_vrange(int smu_ch, int range);

        void smu_force_rly_on(int ch);
        void smu_force_rly_off(int ch);
        void smu_force_rly_ctrl(int ch, int rly_ctrl);
        void smu_rly_all_off(int ch);

        u32 hvsmu_HRADC_enable(u32 ch);

        void smu_adc_conv_start(int smu_ch);
        void smu_adc_current(int ch);
        void smu_adc_voltage(int ch);

        u32 hvsmu_V_DAC_reset(u32 ch);
        u32 hvsmu_I_DAC_reset(u32 ch);
        u32 hvsmu_V_DAC_init(u32 ch);
        u32 hvsmu_I_DAC_init(u32 ch);
        void hvsmu_V_DAC__trig_rst(u32 ch);
        void hvsmu_I_DAC__trig_rst(u32 ch);
        void hvsmu_V_DAC__trig_clr(u32 ch);
        void hvsmu_I_DAC__trig_clr(u32 ch);
        void hvsmu_V_DAC__trig_frame(u32 ch);
        void hvsmu_I_DAC__trig_frame(u32 ch);
        void hvsmu_V_DAC__trig_nop(u32 ch);
        void hvsmu_I_DAC__trig_nop(u32 ch);
        u32 hvsmu_V_DAC__sub_trig_check(u32 ch, u32 bit_loc);
        u32 hvsmu_I_DAC__sub_trig_check(u32 ch, u32 bit_loc);
        u32 hvsmu_V_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20);
        u32 hvsmu_I_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20);
        u32 hvsmu_V_DAC_reg_get(u32 ch, u32 adrs_b3);
        u32 hvsmu_I_DAC_reg_get(u32 ch, u32 adrs_b3);
        void hvsmu_V_DAC__set_mosi(u32 ch, u32 val_u32);
        void hvsmu_I_DAC__set_mosi(u32 ch, u32 val_u32);
        u32 hvsmu_V_DAC__get_miso(u32 ch);
        u32 hvsmu_I_DAC__get_miso(u32 ch);
        void hvsmu_V_DAC__trig_ldac(u32 ch);
        void hvsmu_I_DAC__trig_ldac(u32 ch);

    }


    //// some class or enum or struct


    public partial class SMU : I_SMU 
    {
        // slot functions
        public void scan_frame_slot() // scan slot
        {
            TRACE("----------------------------------------------------------\r\n");            

            // scan slot 0 for GNDU
            if (search_board_init(-1, GetWireOutValue(_SPI_SEL_SLOT_GNDU(), _SPI_SEL_CH_GNDU(), 
                (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF)) == FALSE)
                // nop or more init
                //Console.WriteLine("# <Slot {0,2:d}: Not Detected: GNDU expected>", 0);
                TRACE("# <Not Detect Board on Slot 0>\r\n");

            // scan slot 1 ~ 12
            for(int i = 0; i < 12; i++)
            {
                // search spi ch M0
                if(search_board_init((s8)i, GetWireOutValue(_SPI_SEL_SLOT(i), (u32)__enum_SPI_CBIT.SPI_SEL_M0, 
                    (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;
                // search spi ch M2
                if(search_board_init((s8)i, GetWireOutValue(_SPI_SEL_SLOT(i), (u32)__enum_SPI_CBIT.SPI_SEL_M2, 
                    (u32)__enum_EPA.EP_ADRS__FPGA_IMAGE_ID_WO , 0xFFFFFFFF))) continue;
                // no board found in this slot
                //Console.WriteLine("# <Slot {0,2:d}: Not Detected: no FID>", i + 1);
                TRACE("# <Not Detect Board on Slot %d>\r\n", i + 1);
            }
        }
        public bool search_board_init(s8 slot, u32 fid) // (s8 slot, u32 slot_cs_code, u32 slot_ch_code, u32 fid)
        {
            bool rtn = true;
            u8 boardID = (u8)(fid >> 24);

            switch(boardID)
            {
                case (u8)__board_class_id__.S3100_GNDU      :
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100_GNDU, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); // slot 0 fixed
                    //
                    TRACE("# <Detect Board on Slot %d: S3100-GNDU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3000_PGU:			// S3000 PGU
                    TRACE("# <Detect Board on Slot %d: S3000-PGU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3000_CMU:			// S3000 CMU
                    TRACE("# <Detect Board on Slot %d: S3000-CMU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                case (u8)__board_class_id__.S3100_PGU_ADDA  :  // alias S3100_PGU_ADDA, S3100_PGU
                    TRACE("# <Detect Board on Slot %d: S3100-PGU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-PGU-ADDA, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_CMU_ADDA  :  // alias S3100_CMU_ADDA, S3100_ADDA
                    TRACE("# <Detect Board on Slot %d: S3100-CMU-ADDA, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100_CMU_ADDA, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_HVSMU     :	// S3100 HVSMU
                    TRACE("# <Detect Board on Slot %d: S3100-HVSMU, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-HVSMU, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    hvsmu_V_DAC_init((u8)slot);
                    hvsmu_I_DAC_init((u8)slot);
                    //
                    hvsmu_HRADC_enable((u8)slot);
                    break;
                case (u8)__board_class_id__.S3100_PGU_SUB   :  // alias S3100_HVPGU
                    TRACE("# <Detect Board on Slot %d: S3100-PGU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-PGU-SUB, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.S3100_CMU_SUB   :	// S3100-CMU-SUB
                    TRACE("# <Detect Board on Slot %d: S3100-CMU-SUB, Ver 0x%X>\r\n", slot + 1, fid);
                    //Console.WriteLine("# <Slot {0,2:d}: Detected: S3100-CMU-SUB, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //    slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
                case (u8)__board_class_id__.E8000_HLSMU   :   // E8000-HVSMU
                    TRACE("# <Detect Board on Slot %d: E8000-HLSMU, Ver 0x%X>\r\n", slot + 1, fid);
                    break;
                default:
                    rtn = false;
                    //TRACE("# <Not Detect Board on Slot %d>\r\n", slot + 1);
                    //
                    //if ( (fid != 0xFFFFFFFF) && (fid != 0x00000000))
                    //    Console.WriteLine("# <Slot {0,2:d}: Detected: Unknown, Ver 0x{1,8:X8}, SPI_cs_code {2,8:X8}, SPI_ch_code {3,8:X8}>", 
                    //        slot + 1, fid, slot_cs_code, slot_ch_code); 
                    break;
            }

            return rtn;
        } 

        public u32 _SPI_SEL_SLOT(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public u32 _SPI_SEL_SLOT_GNDU() // in S3100-GNDU slot 0
        {
            //
            return (u32)__slot_cs_code__.SLOT_CS0;
        }
        public u32 _SPI_SEL_SLOT_SMU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public u32 _SPI_SEL_SLOT_CMU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public u32 _SPI_SEL_SLOT_PGU(s32 a) // in S3100 slot 1~12
        {
            return (u32)(0x1<<(a+1));
        }
        public u32 _SPI_SEL_SLOT_EMUL() // in S3100 EMUL
        {
            return (u32)__slot_cs_code__.SLOT_CS_EMUL;
        }

        public u32 _SPI_SEL_CH_SMU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M0;
        }
        public u32 _SPI_SEL_CH_GNDU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M0;
        }
        public u32 _SPI_SEL_CH_PGU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M2;
        }
        public u32 _SPI_SEL_CH_CMU() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_M2;
        }
        public u32 _SPI_SEL_CH_EMUL() 
        {
            return (u32)__enum_SPI_CBIT.SPI_SEL_EMUL;
        }

        // smu sub-devices
        public char read_smu_state(int ch) // ch : 0 ~ 12
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            char state;
            u32 val;

            val = GetWireOutValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IMODE_WO, 0xFFFFFFFF); 
            state = (char)(val & 0x000000FF);

            if ((state & (char)__enum_SMU.SMU_STATE_MASK) == (char)__enum_SMU.SMU_STATE_VMODE) state = 'V';  		
            else state = 'I';

            return state;
        }

        public void smu_adc_mux_v_sel(int smu_ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FE, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
        }
        public void smu_adc_mux_no_sel(int smu_ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FF, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse

        }
        public void smu_adc_mux_v_sel_all() 
        {
            int ch;
            //u32 slotCS;
            for(ch=0; ch < (int)__enum_SMU.NO_OF_SMU; ch++)
            {
                //slotCS = _SPI_SEL_SLOT_SMU(ch);
                //SetWireInValue   (slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FE, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
                //ActivateTriggerIn(slotCS, SPI_SEL_M0, EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
                smu_adc_mux_v_sel(ch);
            }
        }
        public void smu_adc_mux_i_sel(int smu_ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_WI, 0x000000FD, 0xFFFFFFFF); // EP for ADCIN_SEL_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ADCIN_SEL_TI, 1); // EP for ADCIN_SEL_TI // write pulse
        }
        public void smu_adc_mux_i_sel_all()
        {
            int ch;
            for(ch=0; ch < (int)__enum_SMU.NO_OF_SMU; ch++)
            {
                smu_adc_mux_i_sel(ch);
            }
        }

        public void write_smu_vctrl(int smu_ch, UINT16 vctrl) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            smu_ctrl_reg[smu_ch].vctrl = vctrl;
            // ADG451 Low Active(0 == ON)
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VSRANGE_WI, (u32)((vctrl ^ (u16)__enum_SMU.SMU_VCTRL_XORMASK) & 0x00FF), 0xFFFFFFFF); // EP for VDAC_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VSRANGE_TI, 1); // EP for VDAC_TI // write pulse
            //
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VMRANGE_WI, (u32)(((vctrl ^ (u16)__enum_SMU.SMU_VCTRL_XORMASK) & 0xFF00) >> 8), 0xFFFFFFFF); // EP for VDAC_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VMRANGE_TI, 1); // EP for VDAC_TI // write pulse
        }
        public void write_smu_comp_ctrl(int smu_ch, UINT8 comp_ctrl) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            //
            comp_ctrl = (u8)((comp_ctrl ^ (u8)__enum_SMU.SMU_COMP_CTRL_XORMASK) & 0xFF);
            smu_ctrl_reg[smu_ch].comp_ctrl = comp_ctrl;
            //
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ERRAMP_TR_WI, (u32)comp_ctrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_ERRAMP_TR_TI, 1); // EP for IRANGE_CON_TI // write pulse
        }
        public void write_smu_ictrl(int smu_ch, UINT32 ictrl) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            //
            UINT32 prev_ictrl, masked_ictrl;
            UINT32 prev_loc_ictrl, current_ictrl;
            prev_ictrl = (UINT32)smu_ctrl_reg[smu_ch].ictrl;
            smu_ctrl_reg[smu_ch].ictrl = (s32)ictrl;
            //
            prev_loc_ictrl = prev_ictrl;                
            current_ictrl = ictrl;	
            //
            masked_ictrl = ictrl ^ (UINT32)__enum_SMU.SMU_ICTRL_XORMASK;
            //
            if (prev_loc_ictrl != current_ictrl)
            {
                SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IRANGE_CON_WI, (u32)masked_ictrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
                ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IRANGE_CON_TI, 1); // EP for IRANGE_CON_TI // write pulse
                Delay_us(200);		
            }
        }
        public void write_smu_ictrl_init(int smu_ch, UINT32 ictrl) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            //
            UINT32 masked_ictrl;
            smu_ctrl_reg[smu_ch].ictrl = (s32)ictrl;
            masked_ictrl = ictrl ^ (UINT32)__enum_SMU.SMU_ICTRL_XORMASK;
            //
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IRANGE_CON_WI, (u32)masked_ictrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IRANGE_CON_TI, 1); // EP for IRANGE_CON_TI // write pulse	
            Delay_us(1500);
        }

        //// range control calcultions

        // sbcho@20211217 HVSMU
        //설정하고자 하는 전압레인지를 위한 컨트롤 신호를 생성하는 루틴
        public UINT16 to_smu_vctrl(int vrange)
        {
            UINT16 vctrl;

            switch (vrange) 
            {
                case (int)__enum_SMU.SMU_2V_RANGE     : vctrl = (UINT16)__enum_SMU.SMU_2V_CTRL;    break;
                case (int)__enum_SMU.SMU_5V_RANGE     : vctrl = (UINT16)__enum_SMU.SMU_5V_CTRL;    break;
                case (int)__enum_SMU.SMU_20V_RANGE    : vctrl = (UINT16)__enum_SMU.SMU_20V_CTRL;   break;
                case (int)__enum_SMU.SMU_40V_RANGE    : vctrl = (UINT16)__enum_SMU.SMU_40V_CTRL;   break;
                case (int)__enum_SMU.SMU_200V_RANGE   : vctrl = (UINT16)__enum_SMU.SMU_200V_CTRL;  break;
                default                               : vctrl = (UINT16)__enum_SMU.SMU_2V_CTRL;    break;
            }
            //printf("vrange = %d\n", vrange);
            return vctrl;
        }

        // 전류 공급시 설정하고자 하는 전류레인지를 위한 컨트롤 신호를 생성하는 루틴
        public TSmuCtrl to_smu_isrc_ctrl(int smu_ch, int irange)
        {
            //TSmuCtrl ctrl;
            TSmuCtrl ctrl = new TSmuCtrl();
            
            ctrl.comp_ctrl = 0x00;

            switch (irange) 
            {
                case (int)__enum_SMU.SMU_100mA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_100mA_CTRL; 
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                    break;
                case (int)__enum_SMU.SMU_10mA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_10mA_CTRL;
                    break;
                case (int)__enum_SMU.SMU_1mA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_1mA_CTRL;
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                    break;
                case (int)__enum_SMU.SMU_100uA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_100uA_CTRL; 
                    break;
                case (int)__enum_SMU.SMU_10uA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_10uA_CTRL;
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                    break;
                case (int)__enum_SMU.SMU_1uA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_1uA_CTRL;
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_5M_COMP;
                    break;
                case (int)__enum_SMU.SMU_100nA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_100nA_CTRL;
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP | (int)__enum_SMU.SMU_5M_COMP;
                    break;
                case (int)__enum_SMU.SMU_10nA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_10nA_CTRL; 
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_5M_COMP;
                    break;
                case (int)__enum_SMU.SMU_1nA_RANGE: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_1nA_CTRL;
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP | (int)__enum_SMU.SMU_5M_COMP;
                    break;
                default: 
                    ctrl.ictrl     = (int)__enum_SMU.SMU_100mA_CTRL; 
                    ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                    break; //$$
            }
            
            ctrl.ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~(int)__enum_SMU.SMU_ICTRL_MASK) | ctrl.ictrl;  // SMU_ICTRL_MASK = 0x03073F

            return ctrl;
        }

        // 전류 측정시 설정하고자 하는 전류레인지를 위한 컨트롤 신호를 생성하는 루틴
        public TSmuCtrl to_smu_imsr_ctrl(int smu_ch, int irange)
        {
            //TSmuCtrl ctrl;
            TSmuCtrl ctrl = new TSmuCtrl();
            
            ctrl.comp_ctrl = 0x00;
            
            switch (irange) 
            {
            case (int)__enum_SMU.SMU_100mA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_100mA_CTRL; 
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            case (int)__enum_SMU.SMU_10mA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_10mA_CTRL;
                break;
            case (int)__enum_SMU.SMU_1mA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_1mA_CTRL;
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            case (int)__enum_SMU.SMU_100uA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_100uA_CTRL; 
                break;
            case (int)__enum_SMU.SMU_10uA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_10uA_CTRL;
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            case (int)__enum_SMU.SMU_1uA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_1uA_CTRL;
                break;
            case (int)__enum_SMU.SMU_100nA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_100nA_CTRL;
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            case (int)__enum_SMU.SMU_10nA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_10nA_CTRL; 
                break;
            case (int)__enum_SMU.SMU_1nA_RANGE: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_1nA_CTRL;
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            default: 
                ctrl.ictrl     = (int)__enum_SMU.SMU_100mA_CTRL; 
                ctrl.comp_ctrl = (int)__enum_SMU.SMU_IX10_COMP;
                break;
            }
            
            ctrl.ictrl = (smu_ctrl_reg[smu_ch].ictrl & ~(int)__enum_SMU.SMU_ICTRL_MASK) | ctrl.ictrl;  // SMU_ICTRL_MASK = 0x03073F

            return ctrl;
        }
        public void write_smu_isrc_range(int smu_ch, int irange)
        {
            //TSmuCtrl ctrl;
            TSmuCtrl ctrl = new TSmuCtrl();
            ctrl = to_smu_isrc_ctrl(smu_ch, irange);
            write_smu_comp_ctrl(smu_ch, (u8)ctrl.comp_ctrl);
            write_smu_ictrl(smu_ch, (u32)ctrl.ictrl);
        }
        public void write_smu_imsr_range(int smu_ch, int irange)
        {
            //TSmuCtrl ctrl;
            TSmuCtrl ctrl = new TSmuCtrl();
            ctrl = to_smu_imsr_ctrl(smu_ch, irange);
            write_smu_comp_ctrl(smu_ch, (u8)ctrl.comp_ctrl);
            write_smu_ictrl(smu_ch, (u32)ctrl.ictrl);
        }
        public void write_smu_vrange(int smu_ch, int range)
        {
            UINT16 vctrl;
            vctrl = to_smu_vctrl(range);
            write_smu_vctrl(smu_ch, vctrl);
        }

        public void smu_adc_current(int ch) 
        {
            // single trigger

            // assumed: gndu_HRADC_enable()
            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            u32 cnt_loop = 0;
            bool ret_bool;

            // check trigger done
            while (true) {
                if(cnt_loop > (u32)__enum_SPI_CBIT.SPI_TRIG_MAX_CNT) //$$ cnt_loop
                {
                    smu_iadc_values[ch] = unchecked((s32)0xFFFFFFFF); //$$
                    return;
                }

                ret_bool = IsTriggered(slotCS, 
                    (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_TRIG_TO, 
                    0x01); // adc conversion done 
                if (ret_bool==true) {
                    break;
                }
                cnt_loop += 1;
                Delay_us(10);
            }

            // read adc value
            // 24bit ADC
            smu_iadc_values[ch] = (INT32)GetWireOutValue(slotCS, 
                (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_DAT_WO, 0xFFFFFFFF);

        }
    	public void smu_adc_voltage(int ch) 
        {
            // single trigger
            // assumed: gndu_HRADC_enable()

            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            u32 cnt_loop = 0;
            bool ret_bool;

            // check trigger done
            while (true) {
                if(cnt_loop > (u32)__enum_SPI_CBIT.SPI_TRIG_MAX_CNT) //$$ SPI_TRIG_MAX_CNT
                {
                    smu_vadc_values[ch] = unchecked((s32)0xFFFFFFFF); //$$
                    return;
                }

                ret_bool = IsTriggered(slotCS, 
                    (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_TRIG_TO, 
                    0x01); // adc conversion done 
                if (ret_bool==true) {
                    break;
                }
                cnt_loop += 1;
                Delay_us(10);
            }

            // read adc value
            // 24bit ADC
            smu_vadc_values[ch] = (INT32)GetWireOutValue(slotCS, 
                (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_DAT_WO, 0xFFFFFFFF);
        }
        public void smu_adc_conv_start(int smu_ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(smu_ch + 1);
            ActivateTriggerIn(slotCS, 
                (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_TRIG_TI, 
                0); // trigger conversion
        }

        public void smu_force_rly_on(int ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_WI, 
                (u32)__enum_SMU.SMU_FOCE_REL, 0xFFFFFFFF); // EP for DIAG_RELAY_WI // set ...
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_TI, 
                1);           // EP for DIAG_RELAY_TI // latch pulse
        }
        public void smu_force_rly_off(int ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            //$$ to revise
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_WI, 
                (u32)(~((u32)__enum_SMU.SMU_FOCE_REL)), 0xFFFFFFFF); // EP for DIAG_RELAY_WI // set ...
            //$$
            //SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_WI, 
            //    0x00000000, (u32)__enum_SMU.SMU_FOCE_REL); // EP for DIAG_RELAY_WI // set ...
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_TI, 1) ;           // EP for DIAG_RELAY_TI // latch pulse
        }
        public void smu_force_rly_ctrl(int ch, int rly_ctrl) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU(ch + 1);
            smu_ctrl_reg[ch].force_relay_ctrl = (u16)rly_ctrl;
            SetWireInValue   (slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_WI, 
                (u32)rly_ctrl, 0xFFFFFFFF); // EP for IRANGE_CON_WI 
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_OUTP_RELAY_TI, 1); // EP for IRANGE_CON_TI // write pulse
        }
        public void smu_rly_all_off(int ch)
        {
            //   smu_input_rly_ctrl(ch, 0x0000);
            smu_force_rly_ctrl(ch, 0x0000);
        }


        public u32 hvsmu_HRADC_enable(u32 ch) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)(ch + 1));
            SetWireInValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_HRADC_CON_WI, 
                0x00000001, 0xFFFFFFFF);
            // send dummy converion and sck signals.
            smu_adc_conv_start((s32)ch);
            smu_adc_voltage((s32)ch);
            return 1;
        }

        public u32 hvsmu_V_DAC_reset(u32 ch) 
        {
            hvsmu_V_DAC__trig_clr(ch);
            return 1;
        }
        public u32 hvsmu_I_DAC_reset(u32 ch)
        {
            hvsmu_I_DAC__trig_clr(ch);
            return 1;
        }
        public u32 hvsmu_V_DAC_init(u32 ch)
        {
            hvsmu_V_DAC__trig_rst(ch); // trigger reset
            hvsmu_V_DAC_reg_set(ch, 0x3, 0x00000); // set clear code 0V // 20-bit data
            hvsmu_V_DAC__trig_clr(ch); // trigger clear 
            // DAC output enable
            hvsmu_V_DAC_reg_set(ch, 0x2, 0x00002); // control reg // 0x00002 --> DAC normal out | RBUF power down
            u32 val_readback = hvsmu_V_DAC_reg_get(ch, 0x2); // control readback
            if (val_readback != 0x00002)
                return 0xFFFFFFFF;
            return 1;
            }
        public u32 hvsmu_I_DAC_init(u32 ch)
        {
            hvsmu_I_DAC__trig_rst(ch); // trigger reset
            hvsmu_I_DAC_reg_set(ch, 0x3, 0x00000); // set clear code 0V // 20-bit data
            hvsmu_I_DAC__trig_clr(ch); // trigger clear 
            // DAC output enable
            hvsmu_I_DAC_reg_set(ch, 0x2, 0x00002); // control reg // 0x00002 --> DAC normal out | RBUF power down
            u32 val_readback = hvsmu_I_DAC_reg_get(ch, 0x2); // control readback
            if (val_readback != 0x00002)
                return 0xFFFFFFFF;
            return 1;            
        }
        public void hvsmu_V_DAC__trig_rst(u32 ch) 
        {
            // trigger reset
            hvsmu_V_DAC__sub_trig_check(ch, 0);
        }
        public void hvsmu_I_DAC__trig_rst(u32 ch)
        {
            // trigger reset
            hvsmu_I_DAC__sub_trig_check(ch, 0);
        }
        public void hvsmu_V_DAC__trig_clr(u32 ch)
        {
            // trigger clear
            hvsmu_V_DAC__sub_trig_check(ch, 1);
        }
        public void hvsmu_I_DAC__trig_clr(u32 ch)
        {
            // trigger clear
            hvsmu_I_DAC__sub_trig_check(ch, 1);
        }
        public void hvsmu_V_DAC__trig_frame(u32 ch)
        {
            // trigger trig_frame
            hvsmu_V_DAC__sub_trig_check(ch, 3);
        }
        public void hvsmu_I_DAC__trig_frame(u32 ch)
        {
            // trigger trig_frame
            hvsmu_I_DAC__sub_trig_check(ch, 3);
        }
        public void hvsmu_V_DAC__trig_nop(u32 ch)
        {
            // trigger trig_nop
            hvsmu_V_DAC__sub_trig_check(ch, 4);
        }
        public void hvsmu_I_DAC__trig_nop(u32 ch)
        {
            // trigger trig_nop
            hvsmu_I_DAC__sub_trig_check(ch, 4);
        }
        public u32 hvsmu_V_DAC__sub_trig_check(u32 ch, u32 bit_loc)
        {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | HRDAC | HRDAC_VDAC_WI | 0x030      | wire_in_0C | Control HRDAC VDAC.        | bit[23:0]=mosi_data[23:0]      | 
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | HRDAC | HRDAC_VDAC_WO | 0x098      | wireout_26 | Return HRDAC VDAC status.  | bit[23:0]=miso_data[23:0]      | 
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | HRDAC | HRDAC_VDAC_TI | 0x12C      | trig_in_4B | Trigger HRDAC VDAC.        | bit[0]=trig_reset              | 
            // |       |               |            |            |                            | bit[1]=trig_clr                | 
            // |       |               |            |            |                            | bit[2]=trig_ldac               | 
            // |       |               |            |            |                            | bit[3]=trig_frame              | 
            // |       |               |            |            |                            | bit[4]=trig_nop                | 
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | HRDAC | HRDAC_VDAC_TO | 0x1A4      | trigout_69 | Check HRDAC VDAC done.     | bit[0]=trig_reset              | 
            // |       |               |            |            |                            | bit[1]=trig_clr                | 
            // |       |               |            |            |                            | bit[2]=trig_ldac               | 
            // |       |               |            |            |                            | bit[3]=trig_frame              | 
            // |       |               |            |            |                            | bit[4]=trig_nop                | 
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VDAC_TI, 
                (s32)bit_loc); // (u32 adrs, s32 loc_bit)
            //# check done
            u32 cnt_done = 0;
            bool flag_done;
            while (true) {
                flag_done = IsTriggered(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VDAC_TO, 
                                (u32)(0x1<<(s32)bit_loc));
                if (flag_done==true)
                    break;
                cnt_done += 1;
                if (cnt_done>=(u32)__enum_SPI_CBIT.SPI_TRIG_MAX_CNT)
                    break;
            }
            return cnt_done;
        }
        public u32 hvsmu_I_DAC__sub_trig_check(u32 ch, u32 bit_loc)
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);
            ActivateTriggerIn(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IDAC_TI, 
                (s32)bit_loc); // (u32 adrs, s32 loc_bit)
            //# check done
            u32 cnt_done = 0;
            bool flag_done;
            while (true) {
                flag_done = IsTriggered(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IDAC_TO, 
                                (u32)(0x1<<(s32)bit_loc));
                if (flag_done==true)
                    break;
                cnt_done += 1;
                if (cnt_done>=(u32)__enum_SPI_CBIT.SPI_TRIG_MAX_CNT)
                    break;
            }
            return cnt_done;
        }
        public u32 hvsmu_V_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20)
        {
            // reg adrs AD5791 // https://www.analog.com/media/en/technical-documentation/data-sheets/ad5791.pdf
            // 000 (0x0) : NOP
            // 001 (0x1) : DAC reg
            // 010 (0x2) : control reg
            // 011 (0x3) : clear code reg
            // 100 (0x4) : SW control reg
            u32 val_mosi;
            val_mosi = (adrs_b3<<20) | (val_b20); 
            hvsmu_V_DAC__set_mosi(ch, val_mosi); 
            hvsmu_V_DAC__trig_frame(ch);
            return val_mosi;
        }
        public u32 hvsmu_I_DAC_reg_set(u32 ch, u32 adrs_b3, u32 val_b20)
        {
            // reg adrs AD5791 // https://www.analog.com/media/en/technical-documentation/data-sheets/ad5791.pdf
            // 000 (0x0) : NOP
            // 001 (0x1) : DAC reg
            // 010 (0x2) : control reg
            // 011 (0x3) : clear code reg
            // 100 (0x4) : SW control reg
            u32 val_mosi;
            val_mosi = (adrs_b3<<20) | (val_b20); 
            hvsmu_I_DAC__set_mosi(ch, val_mosi); 
            hvsmu_I_DAC__trig_frame(ch);
            return val_mosi;
        }
        public u32 hvsmu_V_DAC_reg_get(u32 ch, u32 adrs_b3)
        {
            // adrs
            // 000  : NOP
            // 001  : DAC reg
            // 010  : control reg
            // 011  : clear code reg
            // 100  : SW control reg
            u32 val_mosi;
            val_mosi = (0x1<<23) | (adrs_b3<<20) | 0; // read flag
            hvsmu_V_DAC__set_mosi(ch, val_mosi); 
            hvsmu_V_DAC__trig_frame(ch);
            hvsmu_V_DAC__trig_nop(ch);
            u32 val_miso = hvsmu_V_DAC__get_miso(ch); // collect miso data
            return val_miso & 0xFFFFF;
        }
        public u32 hvsmu_I_DAC_reg_get(u32 ch, u32 adrs_b3)
        {
            // adrs
            // 000  : NOP
            // 001  : DAC reg
            // 010  : control reg
            // 011  : clear code reg
            // 100  : SW control reg
            u32 val_mosi;
            val_mosi = (0x1<<23) | (adrs_b3<<20) | 0; // read flag
            hvsmu_V_DAC__set_mosi(ch, val_mosi); 
            hvsmu_V_DAC__trig_frame(ch);
            hvsmu_V_DAC__trig_nop(ch);
            u32 val_miso = hvsmu_V_DAC__get_miso(ch); // collect miso data
            return val_miso & 0xFFFFF;
        }
        public void hvsmu_V_DAC__set_mosi(u32 ch, u32 val_u32) 
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);
            // set mosi data
            SetWireInValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VDAC_WI, 
                val_u32, 0xFFFFFFFF);
        }
        public void hvsmu_I_DAC__set_mosi(u32 ch, u32 val_u32)
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);
            // set mosi data
            SetWireInValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IDAC_WI, 
                val_u32, 0xFFFFFFFF);
        }
        public u32 hvsmu_V_DAC__get_miso(u32 ch)
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);
            // get miso data
            return GetWireOutValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_VDAC_WO, 0xFFFFFFFF);
        }
        public u32 hvsmu_I_DAC__get_miso(u32 ch)
        {
            u32 slotCS = _SPI_SEL_SLOT_SMU((s32)ch);	
            // get miso data
            return GetWireOutValue(slotCS, (u32)__enum_SPI_CBIT.SPI_SEL_M0, (u32)__enum_EPA.EP_ADRS__HVSMU_IDAC_WO, 0xFFFFFFFF);
        }
        public void hvsmu_V_DAC__trig_ldac(u32 ch)
        {
            hvsmu_V_DAC__sub_trig_check(ch, 2);
        }
        public void hvsmu_I_DAC__trig_ldac(u32 ch)
        {
        	hvsmu_I_DAC__sub_trig_check(ch, 2);
        }


    }


}
