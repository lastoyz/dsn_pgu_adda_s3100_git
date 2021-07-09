#ifndef __MCS_IO_BRIDGE_H_
#define __MCS_IO_BRIDGE_H_

#include "xil_types.h"

//$$#include "mhvsu_base_config.h" //$$ board dependent
//$$#include "cmu_cpu_config.h" //$$ board dependent
#include "pgu_cpu_config.h" //$$ board dependent

// note : __MCS_IO_BRIDGE_H_ replaces __PGU_CPU_H_

// macro for FPGA LAN end point access in  w5500.c
// _PGU_CPU_ --> _MCS_IO_BRDG_
#define _MCS_IO_BRDG_

// MCS_EP_BASE control from pgu_cpu_config.h

#define _MCS_DEBUG_


//// common //{
u32 hexchr2data_u32(u8 hexchr);
u32 hexstr2data_u32(u8* hexstr, u32 len);
u32 decchr2data_u32(u8 chr);
u32 decstr2data_u32(u8* str, u32 len);
u32 is_dec_char(u8 chr); // 0 for dec; -1 for not
void mcopy(void *dest, const void *src, size_t n); //$$ rename memcpy --> mcopy
//}


//// TODO: MCS io access functions ========  //{
u32 _test_read_mcs (char* txt, u32 adrs);
u32 _test_write_mcs(char* txt, u32 adrs, u32 value);
//
u32 read_mcs_io (u32 adrs);
u32 write_mcs_io(u32 adrs, u32 value);
//
u32   read_mcs_fpga_img_id(u32 adrs_base);
u32   read_mcs_test_reg(u32 adrs_base);
void write_mcs_test_reg(u32 adrs_base, u32 data);
//}


//// TODO: wiznet 850io functions ======== //{
u8     hw_reset__wz850();
u8    read_data__wz850 (u32 AddrSel);
void write_data__wz850 (u32 AddrSel, u8 value);
void  read_data_buf__wz850 (u32 AddrSel, u8* p_val, u16 len);
void write_data_buf__wz850 (u32 AddrSel, u8* p_val, u16 len);
//
//void  read_data_pipe__wz850 (u32 AddrSel, u32 ep_offset, u32 len_u32); // not used yet
void  read_data_pipe__wz850 (u32 AddrSel, u32 dst_adrs_p32, u32 len_u32); // not used yet
void write_data_pipe__wz850 (u32 AddrSel, u32 src_adrs_p32, u32 len);
//}


//// TODO: MCS-EP access subfunctions ======== //{
void  enable_mcs_ep(); // enable MCS end-point control over CMU-CPU
void disable_mcs_ep(); // disable MCS end-point control over CMU-CPU
void reset_mcs_ep(); // reset MCS end-point control

//$$ TODO: check to use  reset_io_dev()
void reset_io_dev(); // reset ...  adc / dwave / bias / spo //$$ to see for PGU 

u32 is_enabled_mcs_ep(); 
//
u32  read_mcs_ep_wi_mask(u32 adrs_base);
u32 write_mcs_ep_wi_mask(u32 adrs_base, u32 mask);
u32  read_mcs_ep_wo_mask(u32 adrs_base);
u32 write_mcs_ep_wo_mask(u32 adrs_base, u32 mask);
u32  read_mcs_ep_ti_mask(u32 adrs_base);
u32 write_mcs_ep_ti_mask(u32 adrs_base, u32 mask);
u32  read_mcs_ep_to_mask(u32 adrs_base);
u32 write_mcs_ep_to_mask(u32 adrs_base, u32 mask);
u32  read_mcs_ep_wi_data(u32 adrs_base, u32 offset);
u32 write_mcs_ep_wi_data(u32 adrs_base, u32 offset, u32 data);
u32  read_mcs_ep_wo_data(u32 adrs_base, u32 offset);
u32  read_mcs_ep_ti_data(u32 adrs_base, u32 offset);
u32 write_mcs_ep_ti_data(u32 adrs_base, u32 offset, u32 data);
u32  read_mcs_ep_to_data(u32 adrs_base, u32 offset);
u32 write_mcs_ep_pi_data(u32 adrs_base, u32 offset, u32 data); // write data from a 32b-value to pipe-in(32b)
u32  read_mcs_ep_po_data(u32 adrs_base, u32 offset);           // read data from pipe-out(32b) to a 32b-value
//
u32   read_mcs_ep_wi(u32 adrs_base, u32 offset);
void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask);
u32   read_mcs_ep_wo(u32 adrs_base, u32 offset, u32 mask);
u32   read_mcs_ep_ti(u32 adrs_base, u32 offset);
void write_mcs_ep_ti(u32 adrs_base, u32 offset, u32 data, u32 mask); //$$
void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
u32   read_mcs_ep_to(u32 adrs_base, u32 offset, u32 mask); //$$
u32 is_triggered_mcs_ep_to(u32 adrs_base, u32 offset, u32 mask);
//
u32 write_mcs_ep_pi_buf (u32 adrs_base, u32 offset, u32 len_byte, u8 *p_data); // write data from buffer(32b) to pipe-in(8b) // not used
u32  read_mcs_ep_po_buf (u32 adrs_base, u32 offset, u32 len_byte, u8 *p_data); // read data from pipe-out(8b) to buffer(32b) // not used
//u32 write_mcs_ep_pi_fifo(u32 offset, u32 len_byte, u8 *p_data); // write data from fifo(32b) to pipe-in(8b) 
//u32  read_mcs_ep_po_fifo(u32 offset, u32 len_byte, u8 *p_data); // read data from pipe-out(8b) to fifo(32b) 

//}


//// TODO: subfunctions for pipe ======== //{

// note pipe end-points in CMU or PGU 
// pipe-in  address: 
//    ADRS_PORT_PI_80 ... LAN  fifo  8-bit in MCS0
//    pi8A            ... TEST fifo 32-bit in MCS1
// pipe-out address: 
//    ADRS_PORT_PO_A0 ... LAN  fifo  8-bit in MCS0
//    poAA            ... TEST fifo 32-bit in MCS1
//    poBC            ... ADC  fifo 32-bit in MCS1
//    poBD            ... ADC  fifo 32-bit in MCS1


// PIPE-DATA in buffer (pointer)
//     buffer ... u32 buf[], u8 buf[]
//     pipe  ... 32-bit pipe, 8-bit pipe
//        32-bit pipe --> 32-bit buf
//        32-bit buf  --> 32-bit pipe
//         8-bit pipe -->  8-bit buf
//         8-bit buf  -->  8-bit pipe
//         8-bit pipe --> 32-bit buf
//        32-bit buf  -->  8-bit pipe
void dcopy_pipe8_to_buf8  (u32 adrs_p8, u8 *p_buf_u8, u32 len); // (src,dst,len)
void dcopy_buf8_to_pipe8  (u8 *p_buf_u8, u32 adrs_p8, u32 len); // (src,dst,len)
void dcopy_pipe32_to_buf32(u32 adrs_p32, u32 *p_buf_u32, u32 len_byte); // (src,dst,len_byte) 
void dcopy_buf32_to_pipe32(u32 *p_buf_u32, u32 adrs_p32, u32 len_byte); // (src,dst,len_byte)
void dcopy_buf8_to_pipe32(u8 *p_buf_u8, u32 adrs_p32, u32 len_byte); // (src,dst,len_byte) //$$ used in // # cmd: ":EPS:PI#H8A #4_001024_rrrr...rrrrrrrrrr\n"

// PIPE-DATA in fifo/pipe (IO address)
//     pipe  ... 32-bit pipe, 8-bit pipe
//        32-bit pipe --> 32-bit pipe
//        32-bit pipe -->  8-bit pipe
//         8-bit pipe --> 32-bit pipe
void dcopy_pipe32_to_pipe32(u32 src_adrs_p32, u32 dst_adrs_p32, u32 len_byte);
void dcopy_pipe8_to_pipe32 (u32 src_adrs_p8,  u32 dst_adrs_p32, u32 len_byte);
void dcopy_pipe32_to_pipe8 (u32 src_adrs_p32, u32 dst_adrs_p8,  u32 len_byte);


//}


//// TODO: eeprom access over MCS-EP (WTP) ======== //{

//  #  // w_MEM_WI   
//  #  assign w_num_bytes_DAT               = w_MEM_WI[12:0]; // 12-bit 
//  #  assign w_con_disable_SBP             = w_MEM_WI[15]; // 1-bit
//  #  assign w_con_fifo_path__L_sspi_H_lan = w_MEM_WI[16]; // 1-bit
//  #  assign w_con_port__L_MEM_SIO__H_TP   = w_MEM_WI[17]; // 1-bit
//  #  
//  #  // w_MEM_FDAT_WI
//  #  assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
//  #  assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
//  #  assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
//  #  assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit
//  #  
//  #  // w_MEM_TI
//  #  assign w_MEM_rst      = w_MEM_TI[0];
//  #  assign w_MEM_fifo_rst = w_MEM_TI[1];
//  #  assign w_trig_frame   = w_MEM_TI[2];
//  #  
//  #  // w_MEM_TO
//  #  assign w_MEM_TO[0]     = w_MEM_valid    ;
//  #  assign w_MEM_TO[1]     = w_done_frame   ;
//  #  assign w_MEM_TO[2]     = w_done_frame_TO; //$$ rev
//  #  assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
//  #  
//  #  // w_MEM_PI
//  #  assign w_frame_data_DAT_wr    = w_MEM_PI[7:0]; // 8-bit
//  #  assign w_frame_data_DAT_wr_en = w_MEM_PI_wr;
//  #  
//  #  // w_MEM_PO
//  #  assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
//  #  assign w_MEM_PO[31:8]         = 24'b0; // unused
//  #  assign w_frame_data_DAT_rd_en = w_MEM_PO_rd;
//  

u32  eeprom_send_frame_ep (u32 MEM_WI, u32 MEM_FDAT_WI);
u32  eeprom_set_g_var (u8 EEPROM__LAN_access, u8 EEPROM__on_TP);
u32  eeprom_send_frame (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);
void eeprom_write_enable();
void eeprom_write_disable();
u32 eeprom_read_status();
void eeprom_write_status (u8 BP1_b8, u8 BP0_b8);
u32 is_eeprom_available();
void eeprom_erase_all();
void eeprom_set_all();
void eeprom_reset_fifo();

u16 eeprom_read_fifo (u16 num_bytes_DAT_b16, u8 *buf_dataout);
u16 eeprom_write_fifo (u16 num_bytes_DAT_b16, u8 *buf_datain);
u16 eeprom_read_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
u16 eeprom_read_data_current (u16 num_bytes_DAT_b16, u8 *buf_dataout);
u16 eeprom_write_data_16B (u16 ADRS_b16, u16 num_bytes_DAT_b16);
u16 eeprom_write_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
u8* get_adrs__g_EEPROM__buf_2KB();
u16 eeprom_read_all();
u16 eeprom_write_all();

void hex_txt_display (s16 len_b16, u8 *p_mem_data, u32 adrs_offset);
u8 cal_checksum (u16 len_b16, u8 *p_data_b8);
u8 gen_checksum (u16 len_b16, u8 *p_data_b8);
u8 chk_all_zeros (u16 len_b16, u8 *p_data_b8);

//}


//// TODO: PGU-CPU functions ======== //{
	
// TODO: common
//$$ new command for board GUI
//$$ FPGA_IMAGE_ID `':FPGA:FID?'`
//$$ FPGA_TEMP     `':FPGA:TMP?'`
u32  pgu_read_fpga_image_id();
u32  pgu_read_fpga_temperature();
	
// TODO: SPIO + AUX
void pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp);
u32  pgu_spio_ext_pwr_led_readback();
//
u32  pgu_spio_ext__aux_init(); // set iodir and init out for aux spio //$$ called by ':PGU:AUX:INIT'
void pgu_spio_ext__aux_idle(); //$$ idle state after spio frame done
void pgu_spio_ext__aux_out (u32 val_b4);
u32  pgu_spio_ext__aux_in ();
u32  pgu_spio_ext__aux_send_spi_frame (u32 R_W_bar, u32 reg_adrs_b8, u32 val_b16);
void pgu_spio_ext__aux_reg_write_b16(u32 reg_adrs_b8, u32 val_b16);
u32  pgu_spio_ext__aux_reg_read_b16(u32 reg_adrs_b8);
//
//void pgu_spio_ext__aux_IO_init();
u32  pgu_spio_ext__aux_IO_init(u32 conf_iodir_AB, u32 conf_out_init_AB); //$$ to revise
void pgu_spio_ext__aux_IO_write_b16 (u32 val_b16); //$$ to OLAT  
u32  pgu_spio_ext__aux_IO_read_b16(); //$$ from GPIO
//
//$$ new command for subboard v2
//$$ IOCON (@reg 0x0A)   `':PGU:AUX:CON?'`     `':PGU:AUX:CON #H0000'`
//$$ OLAT  (@reg 0x14)   `':PGU:AUX:OLAT?'`    `':PGU:AUX:OLAT #H0000'`
//$$ IODIR (@reg 0x00)   `':PGU:AUX:DIR?'`     `':PGU:AUX:DIR #H0000'`
//$$ GPIO  (@reg 0x12)   `':PGU:AUX:GPIO?'`    `':PGU:AUX:GPIO #H0000'`
u32  pgu_spio_ext__read_aux_IO_CON  ();
u32  pgu_spio_ext__read_aux_IO_OLAT ();
u32  pgu_spio_ext__read_aux_IO_DIR  ();
u32  pgu_spio_ext__read_aux_IO_GPIO ();
//
void pgu_spio_ext__send_aux_IO_CON  (u32 val_b16);
void pgu_spio_ext__send_aux_IO_OLAT (u32 val_b16);
void pgu_spio_ext__send_aux_IO_DIR  (u32 val_b16);
void pgu_spio_ext__send_aux_IO_GPIO (u32 val_b16);


// TODO: CLKD
u32   pgu_clkd_init();
u32   pgu_clkd_setup(u32 freq_preset);
//
u32  pgu_clkd_reg_write_b8(u32 reg_adrs_b10, u32 val_b8);
u32  pgu_clkd_reg_read_b8(u32 reg_adrs_b10);

// TODO: DACX
u32   pgu_dacx_init();
u32   pgu_dacx_fpga_pll_rst(u32 clkd_out_rst, u32 dac0_dco_rst, u32 dac1_dco_rst);
u32   pgu_dacx_fpga_clk_dis(u32 dac0_clk_dis, u32 dac1_clk_dis);
u32   pgu_dacx_cal_input_dtap();
u32   pgu_dacx_setup();
//
u32  pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8);
u32  pgu_dac0_reg_read_b8(u32 reg_adrs_b5);
u32  pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8);
u32  pgu_dac1_reg_read_b8(u32 reg_adrs_b5);

// TODO: DACX_PG
u32  pgu_dacx_pg_setup();
//
void pgu_dacx_dcs_write_adrs(u32 adrs);
u32  pgu_dacx_dcs_read_adrs();
void pgu_dacx_dcs_write_data_dac0(u32 val_b32);
u32  pgu_dacx_dcs_read_data_dac0();
void pgu_dacx_dcs_write_data_dac1(u32 val_b32);
u32  pgu_dacx_dcs_read_data_dac1();
void pgu_dacx_dcs_run_test();
void pgu_dacx_dcs_stop_test();
void pgu_dacx_dcs_write_repeat(u32 val_b32);
u32  pgu_dacx_dcs_read_repeat();
//
void pgu_dac0_fifo_write_data(u32 val_b32);
void pgu_dac1_fifo_write_data(u32 val_b32);
void pgu_dacx_fdcs_run_test();
void pgu_dacx_fdcs_stop_test();
void pgu_dacx_fdcs_write_repeat(u32 val_b32);
u32  pgu_dacx_fdcs_read_repeat();
//
u32  pgu_dacx__read_status();
void pgu_dacx__write_rep_period(u32 val_b32);
u32  pgu_dacx__read_rep_period();

//}


#endif
