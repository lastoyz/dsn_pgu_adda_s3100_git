// # this           : txem7310_pll__s3100_sv_adda__top.v
// # top xdc        : txem7310_pll__s3100_sv_adda__top.xdc
//
// # FPGA board     : TXEM7310-FPGA-CORE (XEM7310-A200 compatible) or similar
// # FPGA board_sch : FPGA_MODULE_V11_20200812-4M.pdf
//
// # base board     : S3100-PGU or S3100-ADDA or S3100-CMU-ADDA to come
// # base board sch : S3100_ADDA.pdf // not yet
//
// # note: artix-7 top design for S3100-ADDA slave spi side
//
// ############################################################################
// ## TODO: bank usage in xc7a200
// ############################################################################
// # B13 : CLK, SPIO1, S_IO, DACx_SPI, M2_SPI, CLK_COUT, TRIG  // 3.3V // (in MC1/MC2) 
// # B14 : CONF                                                // 1.8V
// # B15 : TP, LAN_SPI(, SCIO)                                 // 3.3V
// # B16 : LED                                                 // 3.3V
// # B34 : XADC, DAC0, ADC0, ADCx                              // 3.3V // (in MC1)
// # B35 : DAC1, ADC1, CLK_SPI                                 // 3.3V // (in MC2)
// # B216: not used


// ## TODO: EP locations : LAN-MCS interface, MTH slave interface
//
// to revise for S3100-ADDA
// * LAN-MCS interface : MTH spi master emulation for debugging without connecting mother board
//                       - FPGA_LED 
//                       - TEST
//                       - EEPROM from SCIO 
//                       - MEM 
//                       - SSPI
//                       - MSPI
//
// * MTH slave SPI interface : END-POINT for "device IO control"
//                             - SSPI 
//                             - TEST 
//                             - HRADC 
//


// ## S3100 MTH SPI frame format : 32 bits 
//
// * MOSI : 
//   FRAME MODE       // [1:0]
//   FRAME CONTROL    // [3:0]
//   FRAME ADDRESS    // [9:0]
//   FRAME WRITE DATA // [15:0]
//
// * MISO : 
//   zeros            // [1:0]
//   FRAME STATUS     // [3:0]
//   BOARD STATUS     // [7:0]
//   zeros            // [1:0]
//   FRAME READ DATA  // [15:0]


//// TODO: MTH slave SPI frame address map
// ## S3100-ADDA  // GNDU --> PGU --> ADDA
//                           
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | frame adrs | type/index | Description                | contents (32-bit)              |
// |       |               | (10-bit)   |            |                            |                                |
// +=======+===============+============+============+============================+================================+
// | SSPI  | SSPI_TEST_WO  | 0x380      | wireout_E0 | Return known frame data.   | bit[31:16]=0x33AA              | 
// |       |               |            |            |                            | bit[15: 0]=0xCC55              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SSPI  | SSPI_CON_WI   | 0x008      | wire_in_02 | Control slave SPI bus.     | bit[30:28]=miso_timing_control | 
// |       |               |            |            |                            | bit[25]=miso_one_bit_ahead_en  |
// |       |               |            |            |                            | bit[24]=loopback_en            |
// |       |               |            |            |                            | bit[ 3]=HW_reset               |
// |       |               |            |            |                            | bit[ 0]=1'b0                   |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SSPI  | SSPI_FLAG_WO  | 0x0C8      | wire_in_32 | Control slave SPI bus.     | bit[31:24]=board_status[7:0]   | 
// |       |               |            |            |                            | bit[23:16]=slot_id[7:0]        |
// |       |               |            |            |                            | bit[15: 0]=count_cs[15:0]      |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | F_IMAGE_ID_WO | 0x080      | wireout_20 | Return FPGA image ID.      | Image_ID[31:0]                 |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_TEMP_WO  | 0x0E8      | wireout_3A | Return XADC values.[mC]    | MON_TEMP[31:0]                 |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_VOLT_WO  | 0x0EC      | wireout_3B | Return XADC values.[mV]    | MON_VOLT[31:0] normial 1.1V    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TIMESTAMP_WO  | 0x088      | wireout_22 | Return time stamp. (10MHz) | TIME_STAMP[31:0]               | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_MON_WO   | 0x08C      | wireout_23 | Return PLL status.         | bit[18]=MCS pll locked         | 
// |       |               |            |            |                            | bit[24]=DAC common pll locked  |
// |       |               |            |            |                            | bit[25]=DAC0 pll locked        |
// |       |               |            |            |                            | bit[26]=DAC1 pll locked        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PI       | 0x228      | pipe_in_8A | Write data into test FIFO. | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PO       | 0x2A8      | pipeout_AA | Read data from test FIFO.  | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_WI        | 0x04C      | wire_in_13 | Control EEPROM interface.  | bit[  15]=disable_SBP_packet   | 
// |       |               |            |            |                            | bit[11:0]=num_bytes_DAT[11:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_FDAT_WI   | 0x048      | wire_in_12 | Control EEPROM frame data. | bit[31:24]=frame_data_ADH[7:0] |
// |       |               |            |            |                            | bit[23:16]=frame_data_ADL[7:0] |
// |       |               |            |            |                            | bit[15: 8]=frame_data_STA[7:0] |
// |       |               |            |            |                            | bit[ 7: 0]=frame_data_CMD[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TI        | 0x14C      | trig_in_53 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_fifo_reset      |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TO        | 0x1CC      | trigout_73 | Check status.              | bit[0]=MEM_valid_latch         |
// |       |               |            |            |                            | bit[1]=done_frame_latch        |
// |       |               |            |            |                            | bit[2]=done_frame (one pulse)  |
// |       |               |            |            |                            | bit[15:8]=frame_data_STA[7:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PI        | 0x24C      | pipe_in_93 | Write data into pipe.      | bit[7:0]=frame_data_DAT_w[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PO        | 0x2CC      | pipeout_B3 | Read data from pipe.       | bit[7:0]=frame_data_DAT_r[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_WI       | 0x014      | wire_in_05 | Control DAC IC interface.  | bit[30]   = dac1_dco_clk_rst   |
// |       |               |            |            |                            | bit[29]   = dac0_dco_clk_rst   |
// |       |               |            |            |                            | bit[28]   = clk_dac_clk_rst    |
// |       |               |            |            |                            | bit[27]   = dac1_clk_dis       |
// |       |               |            |            |                            | bit[26]   = dac0_clk_dis       |
// |       |               |            |            |                            | bit[24]   = DACx_CS_id         |
// |       |               |            |            |                            | bit[23]   = DACx_R_W_bar       |
// |       |               |            |            |                            | bit[22:21]= DACx_byte_mode[1:0]|
// |       |               |            |            |                            | bit[20:16]= DACx_reg_adrs [4:0]|
// |       |               |            |            |                            | bit[7:0]  = DACx_wr_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_WO       | 0x094      | wireout_25 | Read DAC status.           | bit[25]   = done_DACx_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_DACx_LNG_reset|
// |       |               |            |            |                            | bit[7:0]  = DACx_rd_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_TI       | 0x114      | trig_in_45 | Trigger functions.         | bit[0]    = trig_DACx_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_DACx_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_WI   | 0x020      | wire_in_08 | Control pattern gen.       | wire_in__dacz_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_WO   | 0x0A0      | wireout_28 | Read pattern gen status.   | wire_out_dacz_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_TI   | 0x120      | trig_in_48 | Trigger dacz data func.    | bit[ 4] = write_control        |
// |       |               |            |            |                            | bit[ 5] = read_status          |
// |       |               |            |            |                            | bit[ 6] = write_repeat_period  |
// |       |               |            |            |                            | bit[ 7] = read_repeat_period   |
// |       |               |            |            |                            | bit[ 8] = trig_cid_adrs_wr     |
// |       |               |            |            |                            | bit[ 9] = trig_cid_adrs_rd     |
// |       |               |            |            |                            | bit[10] = trig_cid_data_wr     |
// |       |               |            |            |                            | bit[11] = trig_cid_data_rd     |
// |       |               |            |            |                            | bit[12] = trig_cid_ctrl_wr     |
// |       |               |            |            |                            | bit[13] = trig_cid_ctrl_rd     |
// |       |               |            |            |                            |                                |
// |       |               |            |            |                            | bit[15] = trig_cid_stat_rd     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC0_DAT_PI   | 0x218      | pipe_in_86 | Write pattern data in fifo.| w_DAC0_DAT_INC_PI[31:0]        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC0_DUR_PI   | 0x21C      | pipe_in_87 | Write pattern data in fifo.| w_DAC0_DUR_PI[31:0]            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC1_DAT_PI   | 0x220      | pipe_in_88 | Write pattern data in fifo.| w_DAC1_DAT_INC_PI[31:0]        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC1_DUR_PI   | 0x224      | pipe_in_89 | Write pattern data in fifo.| w_DAC1_DUR_PI[31:0]            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_WI       | 0x018      | wire_in_06 | Control DAC IC interface.  | bit[   31]= CLKD_R_W_bar       |
// |       |               |            |            |                            | bit[30:29]= CLKD_byte_mode[1:0]|
// |       |               |            |            |                            | bit[25:16]= CLKD_reg_adrs[9:0] |
// |       |               |            |            |                            | bit[ 7: 0]= CLKD_wr_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_WO       | 0x098      | wireout_26 | Read DAC status.           | bit[31]   = CLKD_LD            |
// |       |               |            |            |                            | bit[30]   = CLKD_STAT          |
// |       |               |            |            |                            | bit[29]   = CLKD_REFM          |
// |       |               |            |            |                            | bit[28]   = CLKD_SDIO_rd       |
// |       |               |            |            |                            | bit[25]   = done_CLKD_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_CLKD_LNG_reset|
// |       |               |            |            |                            | bit[7:0]  = CLKD_rd_D          |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_TI       | 0x118      | trig_in_46 | Trigger functions.         | bit[0]    = trig_CLKD_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_CLKD_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_WI       | 0x01C      | wire_in_07 | Control SPIO IC interface. | bit[28]   = SPIO_CS_id         |
// |       |               |            |            |                            | bit[27:25]= SPIO_pin_adrs[2:0] |
// |       |               |            |            |                            | bit[24]   = SPIO_R_W_bar       |
// |       |               |            |            |                            | bit[23:16]= SPIO_reg_adrs[7:0] |
// |       |               |            |            |                            | bit[15: 8]= SPIO_wr_DA   [7:0] |
// |       |               |            |            |                            | bit[ 7: 0]= SPIO_wr_DB   [7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_WO       | 0x09C      | wireout_27 | Read SPIO status.          | bit[25]   = done_SPIO_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_SPIO_LNG_reset|
// |       |               |            |            |                            | bit[15:8] = SPIO_rd_DA         |
// |       |               |            |            |                            | bit[ 7:0] = SPIO_rd_DB         |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_TI       | 0x11C      | trig_in_47 | Trigger functions.         | bit[0]    = trig_SPIO_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_SPIO_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_WI   | 0x024      | wire_in_09 | Control TRIG_DAT interface.| wire_in__trig_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_WO   | 0x0A4      | wireout_29 | Read TRIG_DAT status.      | wire_out_trig_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_TI   | 0x124      | trig_in_49 | Trigger TRIG_DAT func.     | bit[0] = trig_data_wr          |
// |       |               |            |            | (reserved)                 | bit[1] = trig_data_rd          |
// |       |               |            |            |                            | TBD (reserved)                 |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+


//// TODO: LAN-MCS endpoint address map
// ## S3100-ADDA  LAN-MCS endpoint address map // GNDU --> PGU --> ADDA
//
// note: LAN access must have TEST, MCS, MEM and MSPI.
// note: MEM device is connected via pin B34_L5N, net S_IO_0 in case of S3100-PGU and S3000-PGU.
// note: MEM device is connected via pin IO_L11P_T1_SRCC_15, net SCIO_0 in case of S3100-CPU-BASE.
//
// +=======+===============+============+=========================================+================================+
// | Group | EP name       | MCS adrs   | type/index | Description                | contents (32-bit)              |
// |       |               | (32-bit)   |            |                            |                                |
// +=======+===============+============+=========================================+================================+
// | TEST  | F_IMAGE_ID_WO | TBD        | wireout_20 | Return FPGA image ID.      | Image_ID[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_TEMP_WO  | TBD        | wireout_3A | Return XADC values.[mC]    | MON_TEMP[31:0]                 | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | XADC_VOLT_WO  | TBD        | wireout_3B | Return XADC values.[mV]    | MON_VOLT[31:0] normial 1.1V    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TIMESTAMP_WO  | TBD        | wireout_22 | Return time stamp. (10MHz) | TIME_STAMP[31:0]               | 
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_MON_WO   | TBD        | wireout_23 | Return PLL status.         | bit[18]=MCS pll locked         | 
// |       |               |            |            |                            | bit[24]=DAC common pll locked  |
// |       |               |            |            |                            | bit[25]=DAC0 pll locked        |
// |       |               |            |            |                            | bit[26]=DAC1 pll locked        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_CON_WI   | TBD        | wireout_01 | Control test logics.       | bit[0]=count1_reset            | 
// |       |               |            |            |                            | bit[1]=count1_disable          |
// |       |               |            |            |                            | bit[2]=count2_auto_increase    |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_OUT_WO   | TBD        | wireout_21 | Return test values.        | bit[15:8]=count2[7:0]          |
// |       |               |            |            |                            | bit[ 7:0]=count1[7:0]          |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TI       | TBD        | wireout_40 | Trigger test functions.    | bit[0]=trigger_count2_reset    |
// |       |               |            |            |                            | bit[1]=trigger_count2_up       |
// |       |               |            |            |                            | bit[2]=trigger_count2_down     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_TO       | TBD        | wireout_60 | Check if trigger is done.  | bit[ 0]=done_count1eq00        |
// |       |               |            |            |                            | bit[ 1]=done_count1eq80        |
// |       |               |            |            |                            | bit[16]=done_count2eqFF        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PI       | TBD__      | pipe_in_8A | Write data into test FIFO. | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | TEST_PO       | TBD__      | pipeout_AA | Read data from test FIFO.  | test_fifo_data[31:0]           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TEST  | BRD_CON_WI    | TBD        | wire_in_03 | Control board from LAN.    | bit[ 0]=HW_reset               | 
// |       |               |            |            |                            | bit[ 8]=mcs_ep_po_enable       |
// |       |               |            |            |                            | bit[ 9]=mcs_ep_pi_enable       |
// |       |               |            |            |                            | bit[10]=mcs_ep_to_enable       |
// |       |               |            |            |                            | bit[11]=mcs_ep_ti_enable       |
// |       |               |            |            |                            | bit[12]=mcs_ep_wo_enable       |
// |       |               |            |            |                            | bit[13]=mcs_ep_wi_enable       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MCS   | MCS_SETUP_WI  | TBD        | wire_in_19 | Control board for MCS.     | bit[31:16]=board_id[15:0]      | 
// |       |               |            |            |                            | bit[10]=lan_on_base_enable(NA) |
// |       |               |            |            |                            | bit[ 9]=eeprom_on_tp_enable(NA)|
// |       |               |            |            |                            | bit[ 8]=eeprom_lan_enable(NA)  |
// |       |               |            |            |                            | bit[ 7: 0]=slot_id             |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_EN_CS_WI | TBD        | wire_in_16 | Control MSPI CS enable.    | bit[12: 0]=MSPI_EN_CS[12: 0]   |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_CON_WI   | TBD        | wire_in_17 | Control MSPI MOSI frame.   | bit[31:26]=frame_data_C[ 5:0]  |
// |       |               |            |            |                            | bit[25:16]=frame_data_A[ 9:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_D[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_FLAG_WO  | TBD        | wireout_24 | Return MSPI MISO frame.    | bit[31:16]=frame_data_E[15:0]  |
// |       |               |            |            |                            | bit[15: 0]=frame_data_B[15:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TI       | TBD        | trig_in_42 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_init            |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MSPI  | MSPI_TO       | TBD        | trigout_62 | Check if trigger is done.  | bit[0]=done_reset              |
// |       |               |            |            |                            | bit[1]=done_init               |
// |       |               |            |            |                            | bit[2]=done_frame              |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_WI        | TBD__      | wire_in_13 | Control EEPROM interface.  | bit[  15]=disable_SBP_packet   | 
// |       |               |            |            |                            | bit[11:0]=num_bytes_DAT[11:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_FDAT_WI   | TBD__      | wire_in_12 | Control EEPROM frame data. | bit[31:24]=frame_data_ADH[7:0] |
// |       |               |            |            |                            | bit[23:16]=frame_data_ADL[7:0] |
// |       |               |            |            |                            | bit[15: 8]=frame_data_STA[7:0] |
// |       |               |            |            |                            | bit[ 7: 0]=frame_data_CMD[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TI        | TBD__      | trig_in_53 | Trigger functions.         | bit[0]=trigger_reset           |
// |       |               |            |            |                            | bit[1]=trigger_fifo_reset      |
// |       |               |            |            |                            | bit[2]=trigger_frame           |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_TO        | TBD__      | trigout_73 | Check status.              | bit[0]=MEM_valid_latch         |
// |       |               |            |            |                            | bit[1]=done_frame_latch        |
// |       |               |            |            |                            | bit[2]=done_frame (one pulse)  |
// |       |               |            |            |                            | bit[15:8]=frame_data_STA[7:0]  |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PI        | TBD__      | pipe_in_93 | Write data into pipe.      | bit[7:0]=frame_data_DAT_w[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | MEM   | MEM_PO        | TBD__      | pipeout_B3 | Read data from pipe.       | bit[7:0]=frame_data_DAT_r[7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_WI       | TBD__      | wire_in_05 | Control DAC IC interface.  | bit[30]   = dac1_dco_clk_rst   |
// |       |               |            |            |                            | bit[29]   = dac0_dco_clk_rst   |
// |       |               |            |            |                            | bit[28]   = clk_dac_clk_rst    |
// |       |               |            |            |                            | bit[27]   = dac1_clk_dis       |
// |       |               |            |            |                            | bit[26]   = dac0_clk_dis       |
// |       |               |            |            |                            | bit[24]   = DACx_CS_id         |
// |       |               |            |            |                            | bit[23]   = DACx_R_W_bar       |
// |       |               |            |            |                            | bit[22:21]= DACx_byte_mode[1:0]|
// |       |               |            |            |                            | bit[20:16]= DACx_reg_adrs [4:0]|
// |       |               |            |            |                            | bit[7:0]  = DACx_wr_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_WO       | TBD__      | wireout_25 | Read DAC status.           | bit[25]   = done_DACx_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_DACx_LNG_reset|
// |       |               |            |            |                            | bit[7:0]  = DACx_rd_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACX  | DACX_TI       | TBD__      | trig_in_45 | Trigger functions.         | bit[0]    = trig_DACx_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_DACx_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_WI   | TBD__      | wire_in_08 | Control pattern gen.       | wire_in__dacz_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_WO   | TBD__      | wireout_28 | Read pattern gen status.   | wire_out_dacz_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DACZ_DAT_TI   | TBD__      | trig_in_48 | Trigger dacz data func.    | bit[ 4] = write_control        |
// |       |               |            |            |                            | bit[ 5] = read_status          |
// |       |               |            |            |                            | bit[ 6] = write_repeat_period  |
// |       |               |            |            |                            | bit[ 7] = read_repeat_period   |
// |       |               |            |            |                            | bit[ 8] = trig_cid_adrs_wr     |
// |       |               |            |            |                            | bit[ 9] = trig_cid_adrs_rd     |
// |       |               |            |            |                            | bit[10] = trig_cid_data_wr     |
// |       |               |            |            |                            | bit[11] = trig_cid_data_rd     |
// |       |               |            |            |                            | bit[12] = trig_cid_ctrl_wr     |
// |       |               |            |            |                            | bit[13] = trig_cid_ctrl_rd     |
// |       |               |            |            |                            |                                |
// |       |               |            |            |                            | bit[15] = trig_cid_stat_rd     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC0_DAT_PI   | TBD__      | pipe_in_86 | Write pattern data in fifo.| w_DAC0_DAT_INC_PI[31:0]        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC0_DUR_PI   | TBD__      | pipe_in_87 | Write pattern data in fifo.| w_DAC0_DUR_PI[31:0]            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC1_DAT_PI   | TBD__      | pipe_in_88 | Write pattern data in fifo.| w_DAC1_DAT_INC_PI[31:0]        |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | DACZ  | DAC1_DUR_PI   | TBD__      | pipe_in_89 | Write pattern data in fifo.| w_DAC1_DUR_PI[31:0]            |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_WI       | TBD__      | wire_in_06 | Control DAC IC interface.  | bit[   31]= CLKD_R_W_bar       |
// |       |               |            |            |                            | bit[30:29]= CLKD_byte_mode[1:0]|
// |       |               |            |            |                            | bit[25:16]= CLKD_reg_adrs[9:0] |
// |       |               |            |            |                            | bit[ 7: 0]= CLKD_wr_D[7:0]     |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_WO       | TBD__      | wireout_26 | Read DAC status.           | bit[31]   = CLKD_LD            |
// |       |               |            |            |                            | bit[30]   = CLKD_STAT          |
// |       |               |            |            |                            | bit[29]   = CLKD_REFM          |
// |       |               |            |            |                            | bit[28]   = CLKD_SDIO_rd       |
// |       |               |            |            |                            | bit[25]   = done_CLKD_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_CLKD_LNG_reset|
// |       |               |            |            |                            | bit[7:0]  = CLKD_rd_D          |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | CLKD  | CLKD_TI       | TBD__      | trig_in_46 | Trigger functions.         | bit[0]    = trig_CLKD_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_CLKD_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_WI       | TBD__      | wire_in_07 | Control SPIO IC interface. | bit[28]   = SPIO_CS_id         |
// |       |               |            |            |                            | bit[27:25]= SPIO_pin_adrs[2:0] |
// |       |               |            |            |                            | bit[24]   = SPIO_R_W_bar       |
// |       |               |            |            |                            | bit[23:16]= SPIO_reg_adrs[7:0] |
// |       |               |            |            |                            | bit[15: 8]= SPIO_wr_DA   [7:0] |
// |       |               |            |            |                            | bit[ 7: 0]= SPIO_wr_DB   [7:0] |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_WO       | TBD__      | wireout_27 | Read SPIO status.          | bit[25]   = done_SPIO_SPI_frame|
// |       |               |            |            |                            | bit[24]   = done_SPIO_LNG_reset|
// |       |               |            |            |                            | bit[15:8] = SPIO_rd_DA         |
// |       |               |            |            |                            | bit[ 7:0] = SPIO_rd_DB         |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | SPIO  | SPIO_TI       | TBD__      | trig_in_47 | Trigger functions.         | bit[0]    = trig_SPIO_LNG_reset|
// |       |               |            |            |                            | bit[1]    = trig_SPIO_SPI_frame|
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_WI   | TBD__      | wire_in_09 | Control TRIG_DAT interface.| wire_in__trig_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_WO   | TBD__      | wireout_29 | Read TRIG_DAT status.      | wire_out_trig_data[31:0]       |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// | TRIG  | TRIG_DAT_TI   | TBD__      | trig_in_49 | Trigger TRIG_DAT func.     | bit[0] = trig_data_wr          |
// |       |               |            |            | (reserved)                 | bit[1] = trig_data_rd          |
// |       |               |            |            |                            | TBD (reserved)                 |
// +-------+---------------+------------+------------+----------------------------+--------------------------------+
// +-------+---------------+------------+------------+----------------------------+--------------------------------+



/* sub modules */

//// TODO:  sub_buf_16b //{
module sub_buf_16b ( //{
	input wire clk    ,
	input wire reset_n,
	//
	input  wire [15:0] i_buf, // 
	output wire [15:0] o_buf  // 
	);

reg  [15:0] r_DAT; // located at IOB //{

reg  [15:0] r_DAT_smp0;
reg  [15:0] r_DAT_smp1;
wire [15:0] w_DAT = i_buf;

always @(posedge clk, negedge reset_n) begin 
	if (!reset_n) begin 
		r_DAT        <=  16'b0;
		r_DAT_smp0   <=  16'b0;
		r_DAT_smp1   <=  16'b0;
	end
	else begin
		r_DAT        <= r_DAT_smp0;
		r_DAT_smp0   <= r_DAT_smp1;
		r_DAT_smp1   <= w_DAT     ;
	end
end

assign o_buf = r_DAT;
//}

endmodule //}

//}


//// TODO:  sub_trig_data //{

// test only

module sub_trig_data ( //{
	input wire clk    ,
	input wire reset_n,
	//
	input  wire [31:0] i_wire_in_trig_data, // 
	input  wire [31:0] i_trig_in_trig_data, // 
	output wire [31:0] o_wireout_trig_data  // 
	);

wire [31:0] w_data_in = i_wire_in_trig_data;
wire [31:0] w_trig    = i_trig_in_trig_data;
// bit[0] = trig_data_wr 
// bit[1] = trig_data_rd 

reg  [31:0] r_data    ;
reg  [31:0] r_port_out; //{

// mapping
assign o_wireout_trig_data = r_port_out;

always @(posedge clk, negedge reset_n) begin 
	if (!reset_n) begin 
		r_data     <=  32'b0;
		r_port_out <=  32'b0;
	end
	else begin
		//
		if (w_trig[0])
			r_data     <= w_data_in;
		//
		if (w_trig[1])
			r_port_out <= r_data   ;
		//
	end
end

//}

endmodule //}

//}


//// TODO:  adc_wrapper

/* top module integration */
module txem7310_pll__s3100_sv_adda__top ( 

	//// note: BANK 14 15 16  signals // NOT compatible with TXEM7310 connectors

	//// BANK B14 //{
	
	// # IO_0_14                         # P20  # NA                        
	// # IO_B14_L1P_D00_MOSI             # P22  # FPGA_CFG_D0     (*)       
	// # IO_B14_L1N_D01_DIN              # R22  # FPGA_CFG_D1     (*)       
	// # IO_B14_L2P_D02                  # P21  # FPGA_CFG_D2     (*)       
	// # IO_B14_L2N_D03                  # R21  # FPGA_CFG_D3     (*)       
	// # IO_B14_L3P_PUDC_B               # U22  # FPGA_CFG_PUDC_B (*)       
	// # IO_B14_L3N                      # V22  # NA                        
	//output wire  o_B14_L4P        , // # T21  # NA
	//output wire  o_B14_L4N        , // # U21  # NA
	//output wire  o_B14_L5P        , // # P19  # NA
	//output wire  o_B14_L5N        , // # R19  # NA
	// # IO_B14_L6P_FCS_B                # T19  # FPGA_CFG_FCS_B  (*)       
	//output wire  o_B14_L6N        , // # T20  # NA
	//output wire  o_B14_L7P        , // # W21  # NA
	//output wire  o_B14_L7N        , // # W22  # NA
	//output wire  o_B14_L8P        , // # AA20 # NA
	//output wire  o_B14_L8N        , // # AA21 # NA
	//output wire  o_B14_L9P        , // # Y21  # NA
	//output wire  o_B14_L9N        , // # Y22  # NA
	//output wire  o_B14_L10P       , // # AB21 # NA
	// # IO_B14_L10N_                    # AB22 # NA                        
	//inout  wire  io_B14_L11P_SRCC , // # U20  # NA
	//inout  wire  io_B14_L11N_SRCC , // # V20  # NA
	//inout  wire  io_B14_L12P_MRCC , // # W19  # NA
	//inout  wire  io_B14_L12N_MRCC , // # W20  # NA
	//inout  wire  io_B14_L13P_MRCC , // # Y18  # NA
	//inout  wire  io_B14_L13N_MRCC , // # Y19  # NA
	//inout  wire  io_B14_L14P_SRCC , // # V18  # NA
	//inout  wire  io_B14_L14N_SRCC , // # V19  # NA
	// # IO_B14_L15P                     # AA19 # NA                        
	// # IO_B14_L15N                     # AB20 # NA                        
	// # IO_B14_L16P                     # V17  # NA                        
	//output wire  o_B14_L16N       , // # W17  # NA
	//output wire  o_B14_L17P       , // # AA18 # NA
	//output wire  o_B14_L17N       , // # AB18 # NA
	//output wire  o_B14_L18P       , // # U17  # NA
	//output wire  o_B14_L18N       , // # U18  # NA
	//output wire  o_B14_L19P       , // # P14  # NA
	//output wire  o_B14_L19N       , // # R14  # NA
	//output wire  o_B14_L20P       , // # R18  # NA
	//output wire  o_B14_L20N       , // # T18  # NA
	//output wire  o_B14_L21P       , // # N17  # NA
	//output wire  o_B14_L21N       , // # P17  # NA
	//output wire  o_B14_L22P       , // # P15  # NA
	//output wire  o_B14_L22N       , // # R16  # NA
	//input  wire  i_B14_L23P       , // # N13  # NA
	//input  wire  i_B14_L23N       , // # N14  # NA
	//input  wire  i_B14_L24P       , // # P16  # NA
	//input  wire  i_B14_L24N       , // # R17  # NA
	// # IO_B14_25                       # N15  # NA                        
	
	//}
	
	//// BANK B15 //{
	
	//output wire   o_B15_0_        , // # J16  # NA

	// ## TPs 
	inout  wire io_B15_L1P_AD0P   , // # H13  # F_TP0       ## TP0 // test for eeprom : VCC_3.3V
	inout  wire io_B15_L1N_AD0N   , // # G13  # F_TP1       ## TP1 // test for eeprom : VSS_GND
	inout  wire io_B15_L2P_AD8P   , // # G15  # F_TP2       ## TP2 // test for eeprom : SCIO
	inout  wire io_B15_L2N_AD8N   , // # G16  # F_TP3       ## TP3 // test for        : NA
	inout  wire io_B15_L3P_AD1P   , // # J14  # F_TP4       ## TP4 // test for        : NA
	inout  wire io_B15_L3N_AD1N   , // # H14  # F_TP5       ## TP5 // test for        : NA
	//input  wire  i_B15_L4P        , // # G17   # NA
	//inout  wire io_B15_L4N        , // # G18   # NA
	inout  wire io_B15_L5P_AD9P   , // # J15  # F_TP6       ## TP6 // test for        : NA
	inout  wire io_B15_L5N_AD9N   , // # H15  # F_TP7       ## TP7 // test for        : NA

	// ## LAN for END-POINTS       
	output wire  o_B15_L6P        , // # H17  # LAN_PWDN    ## EP_LAN_PWDN 
	output wire  o_B15_L6N        , // # H18  # LAN_SSAUX_B //$$ ssn aux # NA
	output wire  o_B15_L7P        , // # J22  # LAN_MOSI    ## EP_LAN_MOSI
	output wire  o_B15_L7N        , // # H22  # LAN_SCLK    ## EP_LAN_SCLK
	output wire  o_B15_L8P        , // # H20  # LAN_SSN_B   ## EP_LAN_CS_B
	input  wire  i_B15_L8N        , // # G20  # LAN_INT_B   ## EP_LAN_INT_B
	output wire  o_B15_L9P        , // # K21  # LAN_RST_B   ## EP_LAN_RST_B
	input  wire  i_B15_L9N        , // # K22  # LAN_MISO    ## EP_LAN_MISO
	
	// ## ADC
	//input  wire i_B15_L10P_AD11P, // # M21  # AUX_AD11P
	//input  wire i_B15_L10N_AD11N, // # L21  # AUX_AD11N

	//inout  wire io_B15_L11P_SRCC  , // # J20  # SCIO_0 //$$ 11AA160T # NA
	//inout  wire io_B15_L11N_SRCC  , // # J21  # SCIO_1 //$$ 11AA160T # NA
	//input  wire  i_B15_L12P_MRCC  , // # J19  # NA
	//output wire  o_B15_L12N_MRCC  , // # H19  # NA
	//output wire  o_B15_L13P_MRCC  , // # K18  # NA
	//output wire  o_B15_L13N_MRCC  , // # K19  # NA
	//input  wire  i_B15_L14P_SRCC  , // # L19  # NA
	//input  wire  i_B15_L14N_SRCC  , // # L20  # NA
	//input  wire  i_B15_L15P       , // # N22  # NA
	//input  wire  i_B15_L15N       , // # M22  # NA
	//input  wire  i_B15_L16P       , // # M18  # NA
	//output wire  o_B15_L16N       , // # L18  # NA
	//output wire  o_B15_L17P       , // # N18  # NA
	//input  wire  i_B15_L17N       , // # N19  # NA
	//input  wire  i_B15_L18P       , // # N20  # NA
	//input  wire  i_B15_L18N       , // # M20  # NA
	//input  wire  i_B15_L19P       , // # K13  # NA
	//input  wire  i_B15_L19N       , // # K14  # NA
	//input  wire  i_B15_L20P       , // # M13  # NA
	//input  wire  i_B15_L20N       , // # L13  # NA
	//input  wire  i_B15_L21P       , // # K17  # NA
	//input  wire  i_B15_L21N       , // # J17  # NA
	//input  wire  i_B15_L22P       , // # L14  # NA
	//input  wire  i_B15_L22N       , // # L15  # NA
	//input  wire  i_B15_L23P       , // # L16  # NA
	//input  wire  i_B15_L23N       , // # K16  # NA
	//input  wire  i_B15_L24P       , // # M15  # NA
	//input  wire  i_B15_L24N       , // # M16  # NA
	//input  wire  i_B15_25         , // # M17  # NA

	//}

	//// BANK B16 //{
	
	//output wire  o_B16_0_         , // # F15  # NA
	//inout  wire io_B16_L1P        , // # F13  # NA
	//inout  wire io_B16_L1N        , // # F14  # NA
	//inout  wire io_B16_L2P        , // # F16  # NA
	//inout  wire io_B16_L2N        , // # E17  # NA
	//inout  wire io_B16_L3P        , // # C14  # NA
	//inout  wire io_B16_L3N        , // # C15  # NA
	//inout  wire io_B16_L4P        , // # E13  # NA
	//inout  wire io_B16_L4N        , // # E14  # NA
	//inout  wire io_B16_L5P        , // # E16  # NA
	//inout  wire io_B16_L5N        , // # D16  # NA
	//inout  wire io_B16_L6P        , // # D14  # NA
	//inout  wire io_B16_L6N        , // # D15  # NA
	inout  wire io_B16_L7P          , // # B15  ## F_LED4
	inout  wire io_B16_L7N          , // # B16  ## F_LED6
	//inout  wire io_B16_L8P        , // # C13  # NA
	inout  wire io_B16_L8N          , // # B13  ## F_LED1
	inout  wire io_B16_L9P          , // # A15  ## F_LED3
	inout  wire io_B16_L9N          , // # A16  ## F_LED5
	inout  wire io_B16_L10P         , // # A13  ## F_LED0
	inout  wire io_B16_L10N         , // # A14  ## F_LED2
	inout  wire io_B16_L11P         , // # B17  ## F_LED7
	//inout  wire io_B16_L11N       , // # B18  # NA
	//inout  wire io_B16_L12P       , // # D17  # NA
	//inout  wire io_B16_L12N       , // # C17  # NA
	//inout  wire io_B16_L13P       , // # C18  # NA
	//inout  wire io_B16_L13N       , // # C19  # NA
	//inout  wire io_B16_L14P       , // # E19  # NA
	//inout  wire io_B16_L14N       , // # D19  # NA
	//inout  wire io_B16_L15P       , // # F18  # NA
	//inout  wire io_B16_L15N       , // # E18  # NA
	//inout  wire io_B16_L16P       , // # B20  # NA
	//inout  wire io_B16_L16N       , // # A20  # NA
	//  # IO_B16_L17P_T2_16           // # A18  # NA
	//output wire  o_B16_L17N       , // # A19  # NA
	//output wire  o_B16_L18P       , // # F19  # NA
	//  # IO_B16_L18N_T2_16           // # F20  # NA
	//output wire  o_B16_L19P       , // # D20  # NA
	//output wire  o_B16_L19N       , // # C20  # NA
	//input  wire  i_B16_L20P       , // # C22  # NA
	//  # IO_B16_L20N_T3_16           // # B22  # NA
	//input  wire  i_B16_L21P       , // # B21  # NA
	//input  wire  i_B16_L21N       , // # A21  # NA
	//input  wire  i_B16_L22P       , // # E22  # NA
	//input  wire  i_B16_L22N       , // # D22  # NA
	//input  wire  i_B16_L23P       , // # E21  # NA
	//input  wire  i_B16_L23N       , // # D21  # NA
	//  # IO_B16_L24P_T3_16           // # G21  # NA
	//input  wire  i_B16_L24N       , // # G22  # NA
	//output wire  o_B16_25         , // # F21  # NA
	
	//}


	//// BANK 13 34 35 signals in connectors
	
	//// BANK B13 //{
	
	// # IO_B13_0_                       , // # Y17            # NA
	output wire			 o_B13_L1P       , // # Y16  # MC1-75  ## SPIO1_CS    
	inout  wire			io_B13_L1N       , // # AA16 # MC1-76  ## S_IO_2    
	output wire			 o_B13_L2P       , // # AB16 # MC1-67  ## M2_SPI_RX_EN_SLAVE
	output wire			 o_B13_L2N       , // # AB17 # MC1-69  ## SPIOx_SCLK  
	output wire			 o_B13_L3P       , // # AA13 # MC1-68  ## DACx_SDIO   
	input  wire			 i_B13_L3N       , // # AB13 # MC1-70  ## DACx_SDO    
	output wire			 o_B13_L4P       , // # AA15 # MC1-71  ## SPIOx_MOSI  
	input  wire			 i_B13_L4N       , // # AB15 # MC1-73  ## SPIOx_MISO  
	output wire			 o_B13_L5P       , // # Y13  # MC1-64  ## DAC1_CS     
	output wire			 o_B13_L5N       , // # AA14 # MC1-66  ## DACx_SCLK   
	input  wire			 i_B13_L6P       , // # W14  # MC2-72  ## M2_SPI_CS_BUF
	input  wire			 i_B13_L6N       , // # Y14  # MC2-74  ## M2_SPI_TX_CLK
	output wire			 o_B13_L7P       , // # AB11 # MC1-8   ## DACx_RST_B  
	output wire			 o_B13_L7N       , // # AB12 # MC2-11  ## CLKD_SYNC   
	// # IO_B13_L8P                      , // # AA9            # NA
	//input  wire  i_B13_L8N             , // # AB10           # NA
	//output wire  o_B13_L9P             , // # AA10           # NA
	//output wire  o_B13_L9N             , // # AA11           # NA
	//input  wire  i_B13_L10P            , // # V10            # NA
	//input  wire  i_B13_L10N            , // # W10            # NA
	output wire			o_B13_L11P_SRCC  , // # Y11  # MC2-75  ## M2_SPI_TX_EN_SLAVE
	input  wire			i_B13_L11N_SRCC  , // # Y12  # MC2-76  ## M2_SPI_MOSI     
	// # IO_B13_L12P_MRCC                , // # W11            ## clocks sys_clkp (*)
	// # IO_B13_L12N_MRCC                , // # W12            ## clocks sys_clkn (*)
	input  wire			 c_B13D_L13P_MRCC, // # V13  # MC2-71  ## CLKD_COUT_P                     
	input  wire			 c_B13D_L13N_MRCC, // # V14  # MC2-73  ## CLKD_COUT_N                     
	input  wire			 i_B13D_L14P_SRCC, // # U15  # MC2-64  ## TRIG_IN_P    //                 
	input  wire			 i_B13D_L14N_SRCC, // # V15  # MC2-66  ## TRIG_IN_N    //                 
	output wire			 o_B13_L15P      , // # T14  # MC2-68  ## TRIG_OUT_P   //$$ B13 LVCMOS25  
	output wire			 o_B13_L15N      , // # T15  # MC2-70  ## TRIG_OUT_N   //$$ B13 LVCMOS25  
	output wire			 o_B13_L16P      , // # W15  # MC1-72  ## DAC0_CS                         
	inout  wire			io_B13_L16N      , // # W16  # MC1-74  ## S_IO_1                          
	output wire			 o_B13_L17P      , // # T16  # MC2-67  ## M2_SPI_MISO_B
	output wire			 o_B13_L17N      , // # U16  # MC2-69  ## M2_SPI_RX_CLK_B
	
	//}
		
	//// BANK B34 //{
	
	//input  wire  i_B34_0_       , // # T3     # NA
											    
	output wire  o_B34D_L1P       , // # T1    # MC1-59  ## DAC0_DAT_P2
	output wire  o_B34D_L1N       , // # U1    # MC1-61  ## DAC0_DAT_N2
	output wire  o_B34D_L2P       , // # U2    # MC1-49  ## DAC0_DAT_P4
	output wire  o_B34D_L2N       , // # V2    # MC1-51  ## DAC0_DAT_N4
	output wire  o_B34D_L3P       , // # R3    # MC1-41  ## DAC0_DAT_P6
	output wire  o_B34D_L3N       , // # R2    # MC1-43  ## DAC0_DAT_N6	
	output wire  o_B34D_L4P       , // # W2    # MC1-53  ## DAC0_DAT_P3
	output wire  o_B34D_L4N       , // # Y2    # MC1-57  ## DAC0_DAT_N3
	output wire  o_B34_L5P        , // # W1    # MC1-54  ## ADCx_TPT_B
	inout  wire io_B34_L5N        , // # Y1    # MC1-58  ## S_IO_0 --> MEM_SIO
	output wire  o_B34D_L6P       , // # U3    # MC1-50  ## ADCx_CNV_P
	output wire  o_B34D_L6N       , // # V3    # MC1-52  ## ADCx_CNV_N
	output wire  o_B34D_L7P       , // # AA1   # MC1-63  ## DAC0_DAT_P1
	output wire  o_B34D_L7N       , // # AB1   # MC1-65  ## DAC0_DAT_N1
	output wire  o_B34D_L8P       , // # AB3   # MC1-60  ## ADCx_CLK_P
	output wire  o_B34D_L8N       , // # AB2   # MC1-62  ## ADCx_CLK_N
	output wire  o_B34D_L9P       , // # Y3    # MC1-45  ## DAC0_DAT_P5
	output wire  o_B34D_L9N       , // # AA3   # MC1-47  ## DAC0_DAT_N5
	output wire  o_B34D_L10P      , // # AA5   # MC1-31  ## DAC0_DCI_P
	output wire  o_B34D_L10N      , // # AB5   # MC1-33  ## DAC0_DCI_N
	input  wire  i_B34D_L11P_SRCC , // # Y4    # MC1-38  ## ADC0_DCO_P
	input  wire  i_B34D_L11N_SRCC , // # AA4   # MC1-40  ## ADC0_DCO_N
	output wire  o_B34D_L12P_MRCC , // # V4    # MC1-77  ## DAC0_DAT_P0
	output wire  o_B34D_L12N_MRCC , // # W4    # MC1-79  ## DAC0_DAT_N0
	output wire  o_B34D_L13P_MRCC , // # R4    # MC1-32  ## DAC0_DAT_P11
	output wire  o_B34D_L13N_MRCC , // # T4    # MC1-34  ## DAC0_DAT_N11
	input  wire  c_B34D_L14P_SRCC , // # T5    # MC1-27  ## DAC0_DCO_P
	input  wire  c_B34D_L14N_SRCC , // # U5    # MC1-29  ## DAC0_DCO_N
	output wire  o_B34D_L15P      , // # W6    # MC1-28  ## DAC0_DAT_N15 // swap
	output wire  o_B34D_L15N      , // # W5    # MC1-30  ## DAC0_DAT_P15 // swap
	output wire  o_B34D_L16P      , // # U6    # MC1-23  ## DAC0_DAT_N10 // swap
	output wire  o_B34D_L16N      , // # V5    # MC1-25  ## DAC0_DAT_P10 // swap
	output wire  o_B34D_L17P      , // # R6    # MC1-19  ## DAC0_DAT_N9  // swap
	output wire  o_B34D_L17N      , // # T6    # MC1-21  ## DAC0_DAT_P9  // swap
	input  wire  i_B34D_L18P      , // # Y6    # MC1-42  ## ADC0_DA_P
	input  wire  i_B34D_L18N      , // # AA6   # MC1-44  ## ADC0_DA_N
	output wire  o_B34D_L19P      , // # V7    # MC1-20  ## DAC0_DAT_N13 // swap
	output wire  o_B34D_L19N      , // # W7    # MC1-22  ## DAC0_DAT_P13 // swap
	output wire  o_B34D_L20P      , // # AB7   # MC1-37  ## DAC0_DAT_P7
	output wire  o_B34D_L20N      , // # AB6   # MC1-39  ## DAC0_DAT_N7
	output wire  o_B34D_L21P      , // # V9    # MC1-16  ## DAC0_DAT_N12 // swap
	output wire  o_B34D_L21N      , // # V8    # MC1-18  ## DAC0_DAT_P12 // swap
	input  wire  i_B34D_L22P      , // # AA8   # MC1-46  ## ADC0_DB_P
	input  wire  i_B34D_L22N      , // # AB8   # MC1-48  ## ADC0_DB_N
	output wire  o_B34D_L23P      , // # Y8    # MC1-24  ## DAC0_DAT_N14 // swap
	output wire  o_B34D_L23N      , // # Y7    # MC1-26  ## DAC0_DAT_P14 // swap
	output wire  o_B34D_L24P      , // # W9    # MC1-15  ## DAC0_DAT_N8  // swap
	output wire  o_B34D_L24N      , // # Y9    # MC1-17  ## DAC0_DAT_P8  // swap
	
	//output wire  o_B34_25       , // # U7     # NA

	//}

	//// BANK B35 //{
	
	output wire  o_B35_0_         , // # F4    # MC2-10  ## CLKD_RST_B
	output wire  o_B35D_L1P       , // # B1    # MC2-59  ## DAC1_DAT_N13 // PN swap
	output wire  o_B35D_L1N       , // # A1    # MC2-61  ## DAC1_DAT_P13 // PN swap
	output wire  o_B35D_L2P       , // # C2    # MC2-60  ## DAC1_DAT_N12 // PN swap
	output wire  o_B35D_L2N       , // # B2    # MC2-62  ## DAC1_DAT_P12 // PN swap
	output wire  o_B35D_L3P       , // # E1    # MC2-54  ## DAC1_DAT_N11 // PN swap
	output wire  o_B35D_L3N       , // # D1    # MC2-58  ## DAC1_DAT_P11 // PN swap
	output wire  o_B35_L4P        , // # E2    # MC2-49  ## CLKD_SCLK
	output wire  o_B35_L4N        , // # D2    # MC2-51  ## CLKD_CS_B
	output wire  o_B35D_L5P       , // # G1    # MC2-50  ## DAC1_DAT_N10 // PN swap
	output wire  o_B35D_L5N       , // # F1    # MC2-52  ## DAC1_DAT_P10 // PN swap
	input  wire  i_B35_L6P        , // # F3    # MC2-53  ## CLKD_SDO 
	inout  wire io_B35_L6N        , // # E3    # MC2-57  ## CLKD_SDIO
	input  wire  i_B35D_L7P       , // # K1    # MC2-41  ## ADC1_DA_P
	input  wire  i_B35D_L7N       , // # J1    # MC2-43  ## ADC1_DA_N
	output wire  o_B35D_L8P       , // # H2    # MC2-46  ## DAC1_DAT_N9  // PN swap
	output wire  o_B35D_L8N       , // # G2    # MC2-48  ## DAC1_DAT_P9  // PN swap
	input  wire  i_B35D_L9P       , // # K2    # MC2-37  ## ADC1_DB_P
	input  wire  i_B35D_L9N       , // # J2    # MC2-39  ## ADC1_DB_N
	output wire  o_B35D_L10P      , // # J5    # MC2-42  ## DAC1_DAT_N8  // PN swap
	output wire  o_B35D_L10N      , // # H5    # MC2-44  ## DAC1_DAT_P8  // PN swap
	input  wire  i_B35D_L11P_SRCC , // # H3    # MC2-45  ## ADC1_DCO_P
	input  wire  i_B35D_L11N_SRCC , // # G3    # MC2-47  ## ADC1_DCO_N
	output wire  o_B35D_L12P_MRCC , // # H4    # MC2-67  ## DAC1_DAT_N15 // PN swap
	output wire  o_B35D_L12N_MRCC , // # G4    # MC2-69  ## DAC1_DAT_P15 // PN swap
	output wire  o_B35D_L13P_MRCC , // # K4    # MC2-63  ## DAC1_DAT_N14 // PN swap
	output wire  o_B35D_L13N_MRCC , // # J4    # MC2-65  ## DAC1_DAT_P14 // PN swap
	input  wire  c_B35D_L14P_SRCC , // # L3    # MC2-38  ## DAC1_DCO_N   // PN swap
	input  wire  c_B35D_L14N_SRCC , // # K3    # MC2-40  ## DAC1_DCO_P   // PN swap
	input  wire  i_B35_L15P       , // # M1    # MC2-31  ## CLKD_STAT
	input  wire  i_B35_L15N       , // # L1    # MC2-33  ## CLKD_REFM
	output wire  o_B35D_L16P      , // # M3    # MC2-28  ## DAC1_DAT_P4
	output wire  o_B35D_L16N      , // # M2    # MC2-30  ## DAC1_DAT_N4
	output wire  o_B35D_L17P      , // # K6    # MC2-32  ## DAC1_DCI_N   // PN swap
	output wire  o_B35D_L17N      , // # J6    # MC2-34  ## DAC1_DCI_P   // PN swap
	output wire  o_B35D_L18P      , // # L5    # MC2-23  ## DAC1_DAT_P1
	output wire  o_B35D_L18N      , // # L4    # MC2-25  ## DAC1_DAT_N1
	output wire  o_B35D_L19P      , // # N4    # MC2-19  ## DAC1_DAT_P2
	output wire  o_B35D_L19N      , // # N3    # MC2-21  ## DAC1_DAT_N2
	output wire  o_B35D_L20P      , // # R1    # MC2-24  ## DAC1_DAT_P5
	output wire  o_B35D_L20N      , // # P1    # MC2-26  ## DAC1_DAT_N5
	output wire  o_B35D_L21P      , // # P5    # MC2-15  ## DAC1_DAT_P3
	output wire  o_B35D_L21N      , // # P4    # MC2-17  ## DAC1_DAT_N3
	output wire  o_B35D_L22P      , // # P2    # MC2-20  ## DAC1_DAT_P6
	output wire  o_B35D_L22N      , // # N2    # MC2-22  ## DAC1_DAT_N6
	output wire  o_B35D_L23P      , // # M6    # MC2-27  ## DAC1_DAT_P0
	output wire  o_B35D_L23N      , // # M5    # MC2-29  ## DAC1_DAT_N0
	output wire  o_B35D_L24P      , // # P6    # MC2-16  ## DAC1_DAT_P7
	output wire  o_B35D_L24N      , // # N5    # MC2-18  ## DAC1_DAT_N7
	input  wire  i_B35_25         , // # L6    # MC2-12  ## CLKD_LD
	
	//}

	// MC1 - odd //{
										   // # MC1-1   # VDC_IN
										   // # MC1-3   # VDC_IN
										   // # MC1-5   # VDC_IN
										   // # MC1-7   # VDD_1.8V
										   // # MC1-9   # VDD_3.3V
										   // # MC1-11  # VDD_3.3V
										   // # MC1-13  # VDD_3.3V
										   // # MC1-35  # GND
										   // # MC1-55  # GND
	
	//}
	
	// MC1 - even //{
										   // # MC1-2   # GND
										   // # MC1-4   # VDD_1.0V
										   // # MC1-6   # VDD_1.0V
										   // # MC1-14  # GND
										   // # MC1-36  # MC1_VCCO
										   // # MC1-56  # MC1_VCCO
										   // # MC1-78  # GND
										   // # MC1-80  # GND

	//}
	
	// MC2 - odd //{
										   // # MC2-1   # GND
										   // # MC2-3   # +VCCBATT
										   // # MC2-5   # FPGA_TCK
										   // # MC2-7   # FPGA_TMS
										   // # MC2-9   # FPGA_TDI
										   // # MC2-13  # GND
										   // # MC2-35  # MC2_VCCO
										   // # MC2-55  # MC2_VCCO
	
	//}
	
	// MC2 - even //{
										   // # MC2-2   # VDD_3.3V
										   // # MC2-4   # VDD_3.3V
										   // # MC2-6   # VDD_3.3V
										   // # MC2-8   # FPGA_TDO
	                                       // # MC2-14  # GND
										   // # MC2-36  # GND
										   // # MC2-56  # GND				
										   // # MC2-78  # GND
	                                       // # MC2-80  # GND

	//}

	
	//// external clock ports on B13 //{
	input  wire  sys_clkp,  // # i_B13_L12P_MRCC  # W11 
	input  wire  sys_clkn,  // # i_B13_L12N_MRCC  # W12 
	//}

	//// XADC input on B0 //{
	input  wire  i_XADC_VP, // # L10   VP_0      CONFIG    // # MC1-12  # XADC_VP // external ADC ports 
	input  wire  i_XADC_VN  // # M9    VN_0      CONFIG    // # MC1-10  # XADC_VN // external ADC ports 
	//}

	);


/*parameter common */  //{
	
// TODO: FPGA_IMAGE_ID = h_A4_21_0728   //{
//parameter FPGA_IMAGE_ID = 32'h_BD_21_0310; // PGU-CPU-F5500 // dac pattern gen : dsp maacro test // with XEM7310
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0521; // S3100-PGU // pin map io buf convert from PGU-CPU-F5500 with TXEM7310
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0607; // S3100-PGU // update ENDPOINT map
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0611; // S3100-PGU // activate slave SPI endpoints
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0615; // S3100-PGU // revise LAN and EEPROM endpoints
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0619; // S3100-PGU // update SSPI endpoints
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0628; // S3100-PGU // update SSPI emulation mode : endpoint switch ... LAN, SSPI, SSPI_emulation(MSPI_by_LAN, others_by_SSPI)
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0702; // S3100-PGU // update MSPI endpoint map 
//parameter FPGA_IMAGE_ID = 32'h_A4_21_07A2; // S3100-PGU // debug M2_SPI_TX_EN_SLAVE 
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0723; // S3100-PGU // revise MSPI timing
//parameter FPGA_IMAGE_ID = 32'h_A4_21_0728; // S3100-PGU // revise slave SPI trig out level detect
parameter FPGA_IMAGE_ID = 32'h_A6_21_0813; // S3100-ADDA // initial setup

//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: IO BUF assignment */ //{


//// BANK B14 IOBUF //{

// NA

//}


//// BANK B15 IOBUF //{

//// TP on FPGA module
wire [7:0] TP_tri = 8'b1;  wire [7:0] TP_out = 8'b0;  wire [7:0] TP_in; // 
IOBUF iobuf__TP0__inst(.IO( io_B15_L1P_AD0P  ), .T(TP_tri[0]), .I(TP_out[0] ), .O(TP_in[0] ) ); //
IOBUF iobuf__TP1__inst(.IO( io_B15_L1N_AD0N  ), .T(TP_tri[1]), .I(TP_out[1] ), .O(TP_in[1] ) ); //
IOBUF iobuf__TP2__inst(.IO( io_B15_L2P_AD8P  ), .T(TP_tri[2]), .I(TP_out[2] ), .O(TP_in[2] ) ); //
IOBUF iobuf__TP3__inst(.IO( io_B15_L2N_AD8N  ), .T(TP_tri[3]), .I(TP_out[3] ), .O(TP_in[3] ) ); //
IOBUF iobuf__TP4__inst(.IO( io_B15_L3P_AD1P  ), .T(TP_tri[4]), .I(TP_out[4] ), .O(TP_in[4] ) ); //
IOBUF iobuf__TP5__inst(.IO( io_B15_L3N_AD1N  ), .T(TP_tri[5]), .I(TP_out[5] ), .O(TP_in[5] ) ); //
IOBUF iobuf__TP6__inst(.IO( io_B15_L5P_AD9P  ), .T(TP_tri[6]), .I(TP_out[6] ), .O(TP_in[6] ) ); //
IOBUF iobuf__TP7__inst(.IO( io_B15_L5N_AD9N  ), .T(TP_tri[7]), .I(TP_out[7] ), .O(TP_in[7] ) ); //


//// LAN pin on FPGA module
wire  LAN_PWDN     = 1'b0; // unused // fixed
wire  LAN_SSAUX_B  = 1'b1; // unused // fixed
wire  PT_FMOD_EP_LAN_MOSI ; 
wire  PT_FMOD_EP_LAN_SCLK ; 
wire  PT_FMOD_EP_LAN_CS_B ; 
wire  PT_FMOD_EP_LAN_INT_B;
wire  PT_FMOD_EP_LAN_RST_B; 
wire  PT_FMOD_EP_LAN_MISO ;
OBUF obuf__LAN_PWDN_____inst (.O( o_B15_L6P ), .I( LAN_PWDN             ) ); // 
OBUF obuf__LAN_SSAUX_B__inst (.O( o_B15_L6N ), .I( LAN_SSAUX_B          ) ); // 
OBUF obuf__EP_LAN_MOSI__inst (.O( o_B15_L7P ), .I( PT_FMOD_EP_LAN_MOSI  ) ); // 
OBUF obuf__EP_LAN_SCLK__inst (.O( o_B15_L7N ), .I( PT_FMOD_EP_LAN_SCLK  ) ); // 
OBUF obuf__EP_LAN_CS_B__inst (.O( o_B15_L8P ), .I( PT_FMOD_EP_LAN_CS_B  ) ); // 
IBUF ibuf__EP_LAN_INT_B_inst (.I( i_B15_L8N ), .O( PT_FMOD_EP_LAN_INT_B ) ); //
OBUF obuf__EP_LAN_RST_B_inst (.O( o_B15_L9P ), .I( PT_FMOD_EP_LAN_RST_B ) ); // 
IBUF ibuf__EP_LAN_MISO__inst (.I( i_B15_L9N ), .O( PT_FMOD_EP_LAN_MISO  ) ); //


//// ADC on module
//	input  wire  i_B15_L10P, // # H20    AUX_AD11P
//	input  wire  i_B15_L10N, // # G20    AUX_AD11N

//}


//// BANK B16 IOBUF //{

//// LED on FPGA module
wire [7:0] led;
wire [7:0] F_LED_tri = led;  wire [7:0] F_LED_out = 8'b0;  wire [7:0] F_LED_in; // 
IOBUF iobuf__F_LED4__inst(.IO( io_B16_L7P   ), .T(F_LED_tri[4]), .I(F_LED_out[4] ), .O(F_LED_in[4] ) ); //
IOBUF iobuf__F_LED6__inst(.IO( io_B16_L7N   ), .T(F_LED_tri[6]), .I(F_LED_out[6] ), .O(F_LED_in[6] ) ); //
IOBUF iobuf__F_LED1__inst(.IO( io_B16_L8N   ), .T(F_LED_tri[1]), .I(F_LED_out[1] ), .O(F_LED_in[1] ) ); //
IOBUF iobuf__F_LED3__inst(.IO( io_B16_L9P   ), .T(F_LED_tri[3]), .I(F_LED_out[3] ), .O(F_LED_in[3] ) ); //
IOBUF iobuf__F_LED5__inst(.IO( io_B16_L9N   ), .T(F_LED_tri[5]), .I(F_LED_out[5] ), .O(F_LED_in[5] ) ); //
IOBUF iobuf__F_LED0__inst(.IO( io_B16_L10P  ), .T(F_LED_tri[0]), .I(F_LED_out[0] ), .O(F_LED_in[0] ) ); //
IOBUF iobuf__F_LED2__inst(.IO( io_B16_L10N  ), .T(F_LED_tri[2]), .I(F_LED_out[2] ), .O(F_LED_in[2] ) ); //
IOBUF iobuf__F_LED7__inst(.IO( io_B16_L11P  ), .T(F_LED_tri[7]), .I(F_LED_out[7] ), .O(F_LED_in[7] ) ); //

//}


//// BANK B13 IOBUF //{

//// LAN pin on BASE board (PGU) // removed in S3100
//wire  PT_BASE_EP_LAN_MOSI ; 
//wire  PT_BASE_EP_LAN_SCLK ; 
//wire  PT_BASE_EP_LAN_CS_B ; 
//wire  PT_BASE_EP_LAN_INT_B;
//wire  PT_BASE_EP_LAN_RST_B; 
//wire  PT_BASE_EP_LAN_MISO ;
//OBUF obuf__LAN_MOSI__inst (.O( o_B13_L11N_SRCC  ), .I(PT_BASE_EP_LAN_MOSI ) ); // 
//OBUF obuf__LAN_SCLK__inst (.O( o_B13_L6N        ), .I(PT_BASE_EP_LAN_SCLK ) ); // 
//OBUF obuf__LAN_CS_B__inst (.O( o_B13_L6P        ), .I(PT_BASE_EP_LAN_CS_B ) ); // 
//IBUF ibuf__LAN_INT_B_inst (.I( i_B13_L11P_SRCC  ), .O(PT_BASE_EP_LAN_INT_B) ); //
//OBUF obuf__LAN_RST_B_inst (.O( o_B13_L17N       ), .I(PT_BASE_EP_LAN_RST_B) ); // 
//IBUF ibuf__LAN_MISO__inst (.I( i_B13_L17P       ), .O(PT_BASE_EP_LAN_MISO ) ); //

//// M2_SPI buffers
wire  M2_SPI_CS_BUF      ; // i
wire  M2_SPI_MOSI        ; // i
wire  M2_SPI_TX_CLK      ; // i
wire  M2_SPI_MISO        ;  wire  M2_SPI_MISO_B   = ~M2_SPI_MISO   ; // o
wire  M2_SPI_RX_CLK      ;  wire  M2_SPI_RX_CLK_B = ~M2_SPI_RX_CLK ; // o
wire  M2_SPI_RX_EN_SLAVE ; // o
wire  M2_SPI_TX_EN_SLAVE ; // o
IBUF ibuf__M2_SPI_CS_BUF_______inst (.I( i_B13_L6P       ), .O( M2_SPI_CS_BUF      ) ); //
IBUF ibuf__M2_SPI_MOSI_________inst (.I( i_B13_L11N_SRCC ), .O( M2_SPI_MOSI        ) ); //
IBUF ibuf__M2_SPI_TX_CLK_______inst (.I( i_B13_L6N       ), .O( M2_SPI_TX_CLK      ) ); //
OBUF ibuf__M2_SPI_MISO_B_______inst (.O( o_B13_L17P      ), .I( M2_SPI_MISO_B      ) ); //
OBUF ibuf__M2_SPI_RX_CLK_B_____inst (.O( o_B13_L17N      ), .I( M2_SPI_RX_CLK_B    ) ); //
OBUF obuf__M2_SPI_RX_EN_SLAVE__inst (.O( o_B13_L2P       ), .I( M2_SPI_RX_EN_SLAVE ) ); // 
OBUF obuf__M2_SPI_TX_EN_SLAVE__inst (.O( o_B13_L11P_SRCC ), .I( M2_SPI_TX_EN_SLAVE ) ); // 

//// CLKD
wire   CLKD_COUT; // i
wire c_CLKD_COUT;
IBUFDS ibufds_CLKD_COUT_inst (.I(c_B13D_L13P_MRCC), .IB(c_B13D_L13N_MRCC), .O(c_CLKD_COUT) );
BUFG     bufg_CLKD_COUT_inst (.I(c_CLKD_COUT), .O(CLKD_COUT) ); //$$ use BUFG

wire CLKD_SYNC = 1'b0; // o_B13_L7N // reserved
OBUF obuf_CLKD_SYNC_inst  (.O(o_B13_L7N         ), .I(CLKD_SYNC   ) ); // 


//// TRIG

wire   TRIG_IN;
IBUFDS ibufds_TRIG_IN_inst  (.I(i_B13D_L14P_SRCC), .IB(i_B13D_L14N_SRCC), .O(TRIG_IN) );

//wire   TRIG_OUT;
//OBUFDS obufds_TRIG_OUT_inst (.O(o_B13D_L15P), .OB(o_B13D_L15N), .I(TRIG_OUT)	); // LVDS_25 //$$ NG
wire TRIG_OUT_P; // o
wire TRIG_OUT_N; // o
OBUF obuf_TRIG_OUT_P_inst (.O(o_B13_L15P       ), .I( TRIG_OUT_P ) );  // LVCMOS25
OBUF obuf_TRIG_OUT_N_inst (.O(o_B13_L15N       ), .I( TRIG_OUT_N ) );  // LVCMOS25

//// SPIO
wire SPIO0_CS   ; // removed in S3100
wire SPIO1_CS   ; // o_B13_L1P
wire SPIOx_SCLK ; // o_B13_L2N
wire SPIOx_MOSI ; // o_B13_L4P
wire SPIOx_MISO ; // i_B13_L4N
OBUF obuf_SPIOx_SCLK_inst (.O(o_B13_L2N         ), .I(SPIOx_SCLK          ) ); 
OBUF obuf_SPIOx_MOSI_inst (.O(o_B13_L4P         ), .I(SPIOx_MOSI          ) ); 
IBUF ibuf_SPIOx_MISO_inst (.I(i_B13_L4N         ), .O(SPIOx_MISO          ) );
OBUF obuf_SPIO1_CS_inst   (.O(o_B13_L1P         ), .I(SPIO1_CS | SPIO0_CS ) ); // share

//// S_IO
wire S_IO_1_tri;  wire S_IO_1_out;  wire S_IO_1_in; // 
wire S_IO_2_tri;  wire S_IO_2_out;  wire S_IO_2_in; // 
IOBUF iobuf_S_IO_1_inst (.IO(io_B13_L16N ), .T(S_IO_1_tri), .I(S_IO_1_out), .O(S_IO_1_in) ); //
IOBUF iobuf_S_IO_2_inst (.IO(io_B13_L1N  ), .T(S_IO_2_tri), .I(S_IO_2_out), .O(S_IO_2_in) ); //
wire   S_IO_1     = S_IO_1_in;
wire w_S_IO_1_wr  = 1'b1; //$$ not activated
assign S_IO_1_tri = w_S_IO_1_wr;
assign S_IO_1_out = w_S_IO_1_wr;
wire   S_IO_2     = S_IO_2_in;
wire w_S_IO_2_wr  = 1'b1; //$$ not activated
assign S_IO_2_tri = w_S_IO_2_wr;
assign S_IO_2_out = w_S_IO_2_wr;

//// DACx
wire DACx_RST_B ; // o_B13_L7P 
wire DAC0_CS    ; // o_B13_L16P
wire DAC1_CS    ; // o_B13_L5P 
wire DACx_SCLK  ; // o_B13_L5N 
wire DACx_SDIO  ; // o_B13_L3P 
wire DACx_SDO   ; // i_B13_L3N 
OBUF obuf_DACx_RST_B_inst (.O(o_B13_L7P  ), .I(DACx_RST_B ) ); // 
OBUF obuf_DAC0_CS_inst    (.O(o_B13_L16P ), .I(DAC0_CS    ) ); // 
OBUF obuf_DAC1_CS_inst    (.O(o_B13_L5P  ), .I(DAC1_CS    ) ); // 
OBUF obuf_DACx_SCLK_inst  (.O(o_B13_L5N  ), .I(DACx_SCLK  ) ); // 
OBUF obuf_DACx_SDIO_inst  (.O(o_B13_L3P  ), .I(DACx_SDIO  ) ); // 
IBUF ibuf_DACx_SDO_inst   (.I(i_B13_L3N  ), .O(DACx_SDO   ) ); //


//}

//// BANK B34 IOBUF //{

//// DAC0
(* keep = "true" *) wire [15:0] DAC0_DAT; 

// IOB consideration
wire        w_DAC0_DAT__IOB_clk;
wire        w_DAC0_DAT__IOB_rst_n;
wire [15:0] w_DAC0_DAT__IOB_in ;
wire [15:0] w_DAC0_DAT__IOB_out;

sub_buf_16b  sub_buf_16b__DAC0__inst (
	.clk      (w_DAC0_DAT__IOB_clk  ),
	.reset_n  (w_DAC0_DAT__IOB_rst_n),
	//
	.i_buf    (w_DAC0_DAT__IOB_in ), // [15:0]
	.o_buf    (w_DAC0_DAT__IOB_out)  // [15:0]
	);

assign w_DAC0_DAT__IOB_in[15] = ~DAC0_DAT[15]; // PN swap
assign w_DAC0_DAT__IOB_in[14] = ~DAC0_DAT[14]; // PN swap
assign w_DAC0_DAT__IOB_in[13] = ~DAC0_DAT[13]; // PN swap
assign w_DAC0_DAT__IOB_in[12] = ~DAC0_DAT[12]; // PN swap
assign w_DAC0_DAT__IOB_in[11] =  DAC0_DAT[11]; 
assign w_DAC0_DAT__IOB_in[10] = ~DAC0_DAT[10]; // PN swap
assign w_DAC0_DAT__IOB_in[9 ] = ~DAC0_DAT[9 ]; // PN swap 
assign w_DAC0_DAT__IOB_in[8 ] = ~DAC0_DAT[8 ]; // PN swap 
assign w_DAC0_DAT__IOB_in[7 ] =  DAC0_DAT[7 ];
assign w_DAC0_DAT__IOB_in[6 ] =  DAC0_DAT[6 ];
assign w_DAC0_DAT__IOB_in[5 ] =  DAC0_DAT[5 ];
assign w_DAC0_DAT__IOB_in[4 ] =  DAC0_DAT[4 ];
assign w_DAC0_DAT__IOB_in[3 ] =  DAC0_DAT[3 ];
assign w_DAC0_DAT__IOB_in[2 ] =  DAC0_DAT[2 ];
assign w_DAC0_DAT__IOB_in[1 ] =  DAC0_DAT[1 ];
assign w_DAC0_DAT__IOB_in[0 ] =  DAC0_DAT[0 ];

OBUFDS obufds_DAC0_DAT15_inst 	(.O(o_B34D_L15P     ), .OB(o_B34D_L15N     ), .I(w_DAC0_DAT__IOB_out[15])	); // PN swap
OBUFDS obufds_DAC0_DAT14_inst 	(.O(o_B34D_L23P     ), .OB(o_B34D_L23N     ), .I(w_DAC0_DAT__IOB_out[14])	); // PN swap
OBUFDS obufds_DAC0_DAT13_inst 	(.O(o_B34D_L19P     ), .OB(o_B34D_L19N     ), .I(w_DAC0_DAT__IOB_out[13])	); // PN swap
OBUFDS obufds_DAC0_DAT12_inst 	(.O(o_B34D_L21P     ), .OB(o_B34D_L21N     ), .I(w_DAC0_DAT__IOB_out[12])	); // PN swap
OBUFDS obufds_DAC0_DAT11_inst 	(.O(o_B34D_L13P_MRCC), .OB(o_B34D_L13N_MRCC), .I(w_DAC0_DAT__IOB_out[11])	);
OBUFDS obufds_DAC0_DAT10_inst 	(.O(o_B34D_L16P     ), .OB(o_B34D_L16N     ), .I(w_DAC0_DAT__IOB_out[10])	); // PN swap
OBUFDS obufds_DAC0_DAT9__inst 	(.O(o_B34D_L17P     ), .OB(o_B34D_L17N     ), .I(w_DAC0_DAT__IOB_out[9 ])	); // PN swap 
OBUFDS obufds_DAC0_DAT8__inst 	(.O(o_B34D_L24P     ), .OB(o_B34D_L24N     ), .I(w_DAC0_DAT__IOB_out[8 ])	); // PN swap 
OBUFDS obufds_DAC0_DAT7__inst 	(.O(o_B34D_L20P     ), .OB(o_B34D_L20N     ), .I(w_DAC0_DAT__IOB_out[7 ])	);
OBUFDS obufds_DAC0_DAT6__inst 	(.O(o_B34D_L3P      ), .OB(o_B34D_L3N      ), .I(w_DAC0_DAT__IOB_out[6 ])	);
OBUFDS obufds_DAC0_DAT5__inst 	(.O(o_B34D_L9P      ), .OB(o_B34D_L9N      ), .I(w_DAC0_DAT__IOB_out[5 ])	);
OBUFDS obufds_DAC0_DAT4__inst 	(.O(o_B34D_L2P      ), .OB(o_B34D_L2N      ), .I(w_DAC0_DAT__IOB_out[4 ])	);
OBUFDS obufds_DAC0_DAT3__inst 	(.O(o_B34D_L4P      ), .OB(o_B34D_L4N      ), .I(w_DAC0_DAT__IOB_out[3 ])	);
OBUFDS obufds_DAC0_DAT2__inst 	(.O(o_B34D_L1P      ), .OB(o_B34D_L1N      ), .I(w_DAC0_DAT__IOB_out[2 ])	);
OBUFDS obufds_DAC0_DAT1__inst 	(.O(o_B34D_L7P      ), .OB(o_B34D_L7N      ), .I(w_DAC0_DAT__IOB_out[1 ])	);
OBUFDS obufds_DAC0_DAT0__inst 	(.O(o_B34D_L12P_MRCC), .OB(o_B34D_L12N_MRCC), .I(w_DAC0_DAT__IOB_out[0 ])	);
//
wire          DAC0_DCI;
OBUFDS obufds_DAC0_DCI_inst 	(.O(o_B34D_L10P),      .OB(o_B34D_L10N),      .I(DAC0_DCI)	); //
//
wire          DAC0_DCO; // not used
wire        c_DAC0_DCO;
IBUFDS ibufds_DAC0_DCO_inst 	(.I(c_B34D_L14P_SRCC), .IB(c_B34D_L14N_SRCC), .O(c_DAC0_DCO) );
BUFG     bufg_DAC0_DCO_inst 	(.I(c_DAC0_DCO), .O(DAC0_DCO) ); 

//// ADC
wire   ADC0_DCO;
wire c_ADC0_DCO;
IBUFDS ibufds_ADC0_DCO_inst (.I(i_B34D_L11P_SRCC), .IB(i_B34D_L11N_SRCC), .O(c_ADC0_DCO) );
BUFG     bufg_ADC0_DCO_inst (.I(c_ADC0_DCO), .O(ADC0_DCO) ); 
//
wire ADC0_DA;
wire ADC0_DB;
IBUFDS ibufds_ADC0_DA_inst  (.I(i_B34D_L18P), .IB(i_B34D_L18N), .O(ADC0_DA) );
IBUFDS ibufds_ADC0_DB_inst  (.I(i_B34D_L22P), .IB(i_B34D_L22N), .O(ADC0_DB) );
//
wire ADCx_CNV   = 1'b0; // not yet
wire ADCx_CLK   = 1'b0; // not yet
OBUFDS obufds_ADCx_CNV_inst (.O(o_B34D_L6P ), .OB(o_B34D_L6N), .I(ADCx_CNV)	); //
OBUFDS obufds_ADCx_CLK_inst (.O(o_B34D_L8P ), .OB(o_B34D_L8N), .I(ADCx_CLK)	); //
//
wire ADCx_TPT_B = 1'b0; // not yet
OBUF obuf_ADCx_TPT_B_inst   (.O(o_B34_L5P    ), .I(ADCx_TPT_B   ) ); // 

//// MEM_SIO
wire  MEM_SIO_out; wire  MEM_SIO_tri; wire  MEM_SIO_in; // io_B34_L5N // high-Z control style ports 
IOBUF iobuf_MEM_SIO_inst  (.IO(io_B34_L5N  ), .T(MEM_SIO_tri), .I(MEM_SIO_out ), .O(MEM_SIO_in ) ); //


//}

//// BANK B35 IOBUF //{

//// DAC1 
(* keep = "true" *) wire [15:0] DAC1_DAT;

// IOB consideration
wire        w_DAC1_DAT__IOB_clk;
wire        w_DAC1_DAT__IOB_rst_n;
wire [15:0] w_DAC1_DAT__IOB_in ;
wire [15:0] w_DAC1_DAT__IOB_out;

sub_buf_16b  sub_buf_16b__DAC1__inst (
	.clk      (w_DAC1_DAT__IOB_clk  ),
	.reset_n  (w_DAC1_DAT__IOB_rst_n),
	//
	.i_buf    (w_DAC1_DAT__IOB_in ), // [15:0]
	.o_buf    (w_DAC1_DAT__IOB_out)  // [15:0]
	);

assign w_DAC1_DAT__IOB_in[15] = ~DAC1_DAT[15]; // PN swap
assign w_DAC1_DAT__IOB_in[14] = ~DAC1_DAT[14]; // PN swap
assign w_DAC1_DAT__IOB_in[13] = ~DAC1_DAT[13]; // PN swap
assign w_DAC1_DAT__IOB_in[12] = ~DAC1_DAT[12]; // PN swap
assign w_DAC1_DAT__IOB_in[11] = ~DAC1_DAT[11]; // PN swap
assign w_DAC1_DAT__IOB_in[10] = ~DAC1_DAT[10]; // PN swap
assign w_DAC1_DAT__IOB_in[9 ] = ~DAC1_DAT[9 ]; // PN swap
assign w_DAC1_DAT__IOB_in[8 ] = ~DAC1_DAT[8 ]; // PN swap
assign w_DAC1_DAT__IOB_in[7 ] =  DAC1_DAT[7 ];
assign w_DAC1_DAT__IOB_in[6 ] =  DAC1_DAT[6 ];
assign w_DAC1_DAT__IOB_in[5 ] =  DAC1_DAT[5 ];
assign w_DAC1_DAT__IOB_in[4 ] =  DAC1_DAT[4 ];
assign w_DAC1_DAT__IOB_in[3 ] =  DAC1_DAT[3 ];
assign w_DAC1_DAT__IOB_in[2 ] =  DAC1_DAT[2 ];
assign w_DAC1_DAT__IOB_in[1 ] =  DAC1_DAT[1 ];
assign w_DAC1_DAT__IOB_in[0 ] =  DAC1_DAT[0 ];

//
OBUFDS obufds_DAC1_DAT15_inst 	(.O(o_B35D_L12P_MRCC), .OB(o_B35D_L12N_MRCC), .I(w_DAC1_DAT__IOB_out[15])	); // PN swap
OBUFDS obufds_DAC1_DAT14_inst 	(.O(o_B35D_L13P_MRCC), .OB(o_B35D_L13N_MRCC), .I(w_DAC1_DAT__IOB_out[14])	); // PN swap
OBUFDS obufds_DAC1_DAT13_inst 	(.O(o_B35D_L1P      ), .OB(o_B35D_L1N      ), .I(w_DAC1_DAT__IOB_out[13])	); // PN swap
OBUFDS obufds_DAC1_DAT12_inst 	(.O(o_B35D_L2P      ), .OB(o_B35D_L2N      ), .I(w_DAC1_DAT__IOB_out[12])	); // PN swap
OBUFDS obufds_DAC1_DAT11_inst 	(.O(o_B35D_L3P      ), .OB(o_B35D_L3N      ), .I(w_DAC1_DAT__IOB_out[11])	); // PN swap
OBUFDS obufds_DAC1_DAT10_inst 	(.O(o_B35D_L5P      ), .OB(o_B35D_L5N      ), .I(w_DAC1_DAT__IOB_out[10])	); // PN swap
OBUFDS obufds_DAC1_DAT9__inst 	(.O(o_B35D_L8P      ), .OB(o_B35D_L8N      ), .I(w_DAC1_DAT__IOB_out[9 ])	); // PN swap
OBUFDS obufds_DAC1_DAT8__inst 	(.O(o_B35D_L10P     ), .OB(o_B35D_L10N     ), .I(w_DAC1_DAT__IOB_out[8 ])	); // PN swap
OBUFDS obufds_DAC1_DAT7__inst 	(.O(o_B35D_L24P     ), .OB(o_B35D_L24N     ), .I(w_DAC1_DAT__IOB_out[7 ])	); 
OBUFDS obufds_DAC1_DAT6__inst 	(.O(o_B35D_L22P     ), .OB(o_B35D_L22N     ), .I(w_DAC1_DAT__IOB_out[6 ])	); 
OBUFDS obufds_DAC1_DAT5__inst 	(.O(o_B35D_L20P     ), .OB(o_B35D_L20N     ), .I(w_DAC1_DAT__IOB_out[5 ])	); 
OBUFDS obufds_DAC1_DAT4__inst 	(.O(o_B35D_L16P     ), .OB(o_B35D_L16N     ), .I(w_DAC1_DAT__IOB_out[4 ])	); 
OBUFDS obufds_DAC1_DAT3__inst 	(.O(o_B35D_L21P     ), .OB(o_B35D_L21N     ), .I(w_DAC1_DAT__IOB_out[3 ])	); 
OBUFDS obufds_DAC1_DAT2__inst 	(.O(o_B35D_L19P     ), .OB(o_B35D_L19N     ), .I(w_DAC1_DAT__IOB_out[2 ])	); 
OBUFDS obufds_DAC1_DAT1__inst 	(.O(o_B35D_L18P     ), .OB(o_B35D_L18N     ), .I(w_DAC1_DAT__IOB_out[1 ])	); 
OBUFDS obufds_DAC1_DAT0__inst 	(.O(o_B35D_L23P     ), .OB(o_B35D_L23N     ), .I(w_DAC1_DAT__IOB_out[0 ])	); 
//
wire          DAC1_DCI ;
OBUFDS obufds_DAC1_DCI_inst 	(.O(o_B35D_L17P     ), .OB(o_B35D_L17N     ), .I( DAC1_DCI  )	); // PN swap by PLL
//
wire          DAC1_DCO; // not used
wire        c_DAC1_DCO;
IBUFDS ibufds_DAC1_DCO_inst 	(.I(c_B35D_L14P_SRCC), .IB(c_B35D_L14N_SRCC), .O(c_DAC1_DCO) );
//BUFG   bufg_DAC1_DCO_inst 	(.I(~c_DAC1_DCO), .O(DAC1_DCO) ); // PN swap
BUFG     bufg_DAC1_DCO_inst 	(.I(c_DAC1_DCO), .O(DAC1_DCO) ); // PN swap by PLL 180 degree

//// ADC
wire   ADC1_DCO;
wire c_ADC1_DCO;
IBUFDS ibufds_ADC1_DCO_inst (.I(i_B35D_L11P_SRCC), .IB(i_B35D_L11N_SRCC), .O(c_ADC1_DCO) );
BUFG     bufg_ADC1_DCO_inst (.I(c_ADC1_DCO), .O(ADC1_DCO) ); 
//
wire ADC1_DA;
wire ADC1_DB;
IBUFDS ibufds_ADC1_DA_inst (.I(i_B35D_L7P ), .IB(i_B35D_L7N ), .O(ADC1_DA) );
IBUFDS ibufds_ADC1_DB_inst (.I(i_B35D_L9P ), .IB(i_B35D_L9N ), .O(ADC1_DB) );

//// CLKD
wire CLKD_RST_B;
wire CLKD_LD   ;
wire CLKD_STAT ;
wire CLKD_REFM ;
OBUF obuf_CLKD_RST_B_inst (.O(o_B35_0_     ), .I(CLKD_RST_B ) ); // 
IBUF ibuf_CLKD_LD_inst    (.I(i_B35_25     ), .O(CLKD_LD    ) ); //
IBUF ibuf_CLKD_STAT_inst  (.I(i_B35_L15P   ), .O(CLKD_STAT  ) ); //
IBUF ibuf_CLKD_REFM_inst  (.I(i_B35_L15N   ), .O(CLKD_REFM  ) ); //
//
wire CLKD_SCLK    ;
wire CLKD_CS_B    ;
wire CLKD_SDO     ; // read for 4-wire SPI
wire CLKD_SDIO    ; // 
wire CLKD_SDIO_wr = CLKD_SDIO; // open-drain write for AD9516-1
wire CLKD_SDIO_rd ; // test read
//
OBUF   obuf_CLKD_SCLK_inst ( .O( o_B35_L4P  ), .I(CLKD_SCLK ) ); // 
OBUF   obuf_CLKD_CS_B_inst ( .O( o_B35_L4N  ), .I(CLKD_CS_B ) ); // 
IBUF   ibuf_CLKD_SDO__inst ( .I( i_B35_L6P  ), .O(CLKD_SDO  ) ); //
IOBUF iobuf_CLKD_SDIO_inst (.IO(io_B35_L6N ), .T(CLKD_SDIO_wr ), .I(CLKD_SDIO_wr ), .O(CLKD_SDIO_rd ) ); //


//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: clock/pll and reset */ //{

// clock pll0 //{
wire clk_out1_200M ; // REFCLK 200MHz for IDELAYCTRL // for pll1
wire clk_out2_140M ; // for pll2 ... 140M
wire clk_out3_10M  ; // for slow logic / I2C //
wire clk_out4_10M ; // for XADC 
//
wire clk_locked_pre;
clk_wiz_0  clk_wiz_0_inst(
	// MMCM
	// VCO 700MHz
	// Clock out ports  
	.clk_out1_200M (clk_out1_200M ), // BUFG
	.clk_out2_140M (clk_out2_140M ), // BUFG
	// Status and control signals               
	.locked(clk_locked_pre),
	// Clock in ports
	.clk_in1_p(sys_clkp), // diff clock pin
	.clk_in1_n(sys_clkn)
);
////
clk_wiz_0_0_1  clk_wiz_0_0_1_inst(
	// Clock out ports  
	.clk_out1_10M (clk_out3_10M), // BUFGCE // due to soft-startup
	.clk_out2_10M (clk_out4_10M), // BUFGCE // due to soft-startup
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(), // not used
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll1 //{

wire clk1_locked = 1'b1; // unused // to remove

//}

// clock pll2 //{


wire clk2_locked = 1'b1; // unused // to remove



//}

// clock pll3 //{
wire clk3_out1_72M ; // MCS core; IO bridge
wire clk3_out2_144M; // LAN-SPI control 144MHz 
wire clk3_out3_12M ; // slow logic // not used yet
wire clk3_out4_72M ; // eeprom fifo
//
wire clk3_locked;
//
clk_wiz_0_3_1  clk_wiz_0_3_1_inst(
	// Clock out ports  
	.clk_out1_72M (clk3_out1_72M ), // BUFGCE // due to soft-startup 
	.clk_out2_144M(clk3_out2_144M), // BUFGCE // due to soft-startup
	.clk_out3_12M (clk3_out3_12M ), // BUFGCE // due to soft-startup
	.clk_out4_72M (clk3_out4_72M ), // BUFGCE // due to soft-startup 
	// Status and control signals     
	.resetn(clk_locked_pre),          
	.locked(clk3_locked),
	// Clock in ports
	.clk_in1_200M(clk_out1_200M) // no buf
);

//}

// clock pll4 //{

wire clk4_locked = 1'b1; // to remove

//}

// clock pll for DAC 400MHz  //{

// add more clocks for DAC0_DCI DAC1_DCI
//  DCI pin swap info:
//    DAC0_DCI_P/N - pin noraml
//    DAC1_DCI_P/N - pin swap

//$$ note ... 
//    clk_wiz_1 setting : eventually 1:1
//                        output 400MHz --> 200MHz 
//                        input             200MHz
//    input clock from CLKD 400MHz 
//    clk_wiz_1 --> clk_wiz_1_3 removed unused

wire clk_dac_out1_400M; // DAC update rate 
wire clk_dac_out2_400M_0;   // for DAC0_DCI //$$ alternative to DAC0_DCO
wire clk_dac_out3_400M_180; // for DAC1_DCI //$$ alternative to DAC1_DCO
//
wire clk_dac_locked;
wire clk_dac_clk_in; // from  CLKD_COUT or c_B13D_L13P_MRCC // for DAC/CLK 400MHz pll
wire clk_dac_clk_rst;
//

clk_wiz_1_2  clk_wiz_1_2_inst (
	// PLL
	// VCO 800MHz
	// Clock out ports  
	.clk_out1_200M      (clk_dac_out1_400M     ), // BUFGCE // same buf type for phase align 
	.clk_out2_200M_0    (clk_dac_out2_400M_0   ), // BUFGCE // same buf type for phase align
	.clk_out3_200M_180  (clk_dac_out3_400M_180 ), // BUFGCE // same buf type for phase align
	// clock en ports
	.clk_out1_200M_ce     (1'b1),
	.clk_out2_200M_0_ce   (1'b1),
	.clk_out3_200M_180_ce (1'b1),
	// Status and control signals     
	.resetn(clk_locked_pre & ~clk_dac_clk_rst),          
	.locked(clk_dac_locked),
	// Clock in ports
	.clk_in1_200M       (clk_dac_clk_in) // no buf
);


//   
wire dac0_dco_clk_out1_400M; // DAC0 update rate 
//wire dac0_dco_clk_out2_200M; // DAC0 DMA rate     //$$ unused
wire dac0_dco_clk_out5_400M; // DAC0 DCI
wire dac1_dco_clk_out1_400M; // DAC1 update rate 
//wire dac1_dco_clk_out2_200M; // DAC1 DMA rate     //$$ unused
wire dac1_dco_clk_out5_400M; // DAC1 DCI
//
wire dac0_dco_clk_locked;
wire dac0_dco_clk_in;
wire dac0_dco_clk_rst; 
wire dac1_dco_clk_locked;
wire dac1_dco_clk_in;
wire dac1_dco_clk_rst; 
//
wire dac0_clk_dis; // clock disable
wire dac1_clk_dis; // clock disable
//
assign dac0_dco_clk_in = clk_dac_out2_400M_0; // for common clock 
// TODO: must see polarity ... --------////
// note DAC1_DCI and DAC1_DCO are both PN swapped in board 
// note in PGU board... DCI and DAC codes are directly generated from FPGA... in this case, DCO is not necessary.
// in case of DCI coming from external pll, DCO must be used.
assign dac1_dco_clk_in = clk_dac_out3_400M_180; // for common clock //$$ emulation for PN swap of DAC1_DCO
//
//

//$$ for common 
//$$ wire dac0_dco_clk_locked = clk_dac_locked;
//$$ wire dac1_dco_clk_locked = clk_dac_locked;


clk_wiz_1_2  clk_wiz_1_2_0_inst ( // VCO 1200MHz
	// Clock out ports  
	.clk_out1_200M     (dac0_dco_clk_out1_400M), // BUFGCE // //$$ for dac0_clk
	.clk_out2_200M_0   (dac0_dco_clk_out5_400M), // BUFGCE // //$$ for DAC0_DCI
	.clk_out3_200M_180 (),
	// clock en ports
	.clk_out1_200M_ce     (1'b1 & (~dac0_clk_dis) ),
	.clk_out2_200M_0_ce   (1'b1 & (~dac0_clk_dis) ),
	.clk_out3_200M_180_ce (1'b0),
	// Status and control signals            
	.resetn(clk_locked_pre & ~dac0_dco_clk_rst),          
	.locked(dac0_dco_clk_locked),
	// Clock in ports
	.clk_in1_200M      (dac0_dco_clk_in) // no buf
);
//
clk_wiz_1_2  clk_wiz_1_2_1_inst (
	// Clock out ports  
	.clk_out1_200M     (dac1_dco_clk_out5_400M), // BUFGCE // 0 deg for dci same phase with clk in //$$ for DAC1_DCI 
	.clk_out2_200M_0   (),
	.clk_out3_200M_180 (dac1_dco_clk_out1_400M), // BUFGCE // 180 deg for clock in PN swap //$$ for dac1_clk
	// clock en ports
	.clk_out1_200M_ce     (1'b1 & (~dac1_clk_dis) ),
	.clk_out2_200M_0_ce   (1'b0),
	.clk_out3_200M_180_ce (1'b1 & (~dac1_clk_dis) ),
	// Status and control signals            
	.resetn(clk_locked_pre & ~dac1_dco_clk_rst),          
	.locked(dac1_dco_clk_locked),
	// Clock in ports
	.clk_in1_200M      (dac1_dco_clk_in) // no buf // 0 deg
);


//}

// test clock out //{
wire w_trig_p_oddr_out; // to TRIG_OUT_P
wire w_trig_n_oddr_out; // to TRIG_OUT_N
wire w_oddr_in = clk_dac_out1_400M; // OK ... xdc set_output_delay
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TRIG_P_inst (
	.Q(w_trig_p_oddr_out),   // 1-bit DDR output
	.C(w_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge) // normal
	.D2(1'b0), // 1-bit data input (negative edge) // normal
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_TRIG_N_inst (
	.Q(w_trig_n_oddr_out),   // 1-bit DDR output
	.C(w_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b0), // 1-bit data input (positive edge) // inverted
	.D2(1'b1), // 1-bit data input (negative edge) // inverted
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);

//}

// clock locked //{
wire clk_locked = clk1_locked & clk2_locked & clk3_locked & clk4_locked;
//}

// system clock //{
wire sys_clk	= clk_out3_10M;
//}

// system reset //{
wire reset_n	= clk_locked;
wire reset		= ~reset_n;
//}

// other alias clocks //{
wire mcs_clk             = clk3_out1_72M;
wire lan_clk             = clk3_out2_144M;
wire mcs_eeprom_fifo_clk = clk3_out4_72M;
wire xadc_clk            = clk_out4_10M;
//}

// DAC clocks //{
	
wire dac0_clk   = dac0_dco_clk_out1_400M; 
wire dac1_clk   = dac1_dco_clk_out1_400M; 

wire dac0_reset_n = dac0_dco_clk_locked;
wire dac1_reset_n = dac1_dco_clk_locked;

// for IOB registers
assign w_DAC0_DAT__IOB_clk   = dac0_clk;
assign w_DAC1_DAT__IOB_clk   = dac1_clk;
assign w_DAC0_DAT__IOB_rst_n = reset_n;
assign w_DAC1_DAT__IOB_rst_n = reset_n;



// dac dci oddr output //{
wire w_dac0_dci_oddr_out; // to DAC0_DCI
wire w_dac1_dci_oddr_out; // to DAC1_DCI
wire w_dac0_dci_oddr_in = dac0_dco_clk_out5_400M; 
wire w_dac1_dci_oddr_in = dac1_dco_clk_out5_400M; // PN swap in pll 180 degree
// use common clock 
//wire w_dac0_dci_oddr_in = clk_dac_out2_400M_0  ; 
//wire w_dac1_dci_oddr_in = clk_dac_out3_400M_180; // PN swap in pll 180 degree
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
)   ODDR_dac0_dci_inst (
	.Q(w_dac0_dci_oddr_out),   // 1-bit DDR output
	.C(w_dac0_dci_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge)
	.D2(1'b0), // 1-bit data input (negative edge)
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
ODDR #(
	.DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
	.INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
	.SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
)   ODDR_dac1_dci_inst (
	.Q(w_dac1_dci_oddr_out),   // 1-bit DDR output
	.C(w_dac1_dci_oddr_in),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D1(1'b1), // 1-bit data input (positive edge)
	.D2(1'b0), // 1-bit data input (negative edge)
	.R(1'b0),   // 1-bit reset
	.S(1'b0)    // 1-bit set
);
//
	
//}	
	
//}


// clock for MTH SPI //{

wire base_sspi_clk; // base clock for slave SPI // 104MHz
wire p_sspi_clk;    // p_clk for SSPI // 13MHz = base / 8

wire clk_2_locked = 1'b1;

// clk_wiz_2_2
wire clk_2_2_locked; //$$ unused
clk_wiz_2_2  clk_wiz_2_2_inst (
	// Clock out ports  
	.clk_out1_104M(base_sspi_clk),  
	.clk_out2_13M (p_sspi_clk   ),  
	// Status and control signals     
	.resetn(clk_2_locked),          
	.locked(clk_2_2_locked),
	// Clock in ports
	.clk_in1(clk_out1_200M)
);

//}


//}


///TODO: //-------------------------------------------------------//


/* TODO: end-point wires */ //{

// end-points : SSPI vs LAN 
//
// endpoint modules :
//
// (USB) ok_endpoint_wrapper : usb host interface <--> end-points //$$ removed
//    okHost okHI
//    ok...
//
// (LAN) lan_endpoint_wrapper : lan spi  interface <--> end-points
//    microblaze_mcs_1  soft_cpu_mcs_inst
//    mcs_io_bridge_ext  mcs_io_bridge_inst2
//    master_spi_wz850_ext  master_spi_wz850_inst
//    fifo_generator_3  LAN_fifo_wr_inst
//    fifo_generator_3  LAN_fifo_rd_inst
//
// (SSPI) slave_spi_mth_brd : MTH slave SPI <--> end-points
//   


//// TODO: USB --> SSPI end-point wires: //{

// Wire In 		0x00 - 0x1F //{
wire [31:0] ep00wire; //
wire [31:0] ep01wire; //
wire [31:0] ep02wire; //$$ [SSPI] SSPI_CON_WI         //$$ S3100 // to revise
wire [31:0] ep03wire; // 
wire [31:0] ep04wire; //
wire [31:0] ep05wire; //$$ [DACX] DACX_WI             // PGU
wire [31:0] ep06wire; //$$ [CLKD] CLKD_WI             // PGU
wire [31:0] ep07wire; //$$ [SPIO] SPIO_WI             // PGU
wire [31:0] ep08wire; //$$ [DACZ] DACZ_DAT_WI         // PGU
wire [31:0] ep09wire; //$$ [TRIG] TRIG_DAT_WI         // PGU reserved
wire [31:0] ep0Awire; //
wire [31:0] ep0Bwire; //
wire [31:0] ep0Cwire; //
wire [31:0] ep0Dwire; //
wire [31:0] ep0Ewire; //
wire [31:0] ep0Fwire; //
wire [31:0] ep10wire; //
wire [31:0] ep11wire; //
wire [31:0] ep12wire; //$$ [MEM] MEM_FDAT_WI
wire [31:0] ep13wire; //$$ [MEM] MEM_WI
wire [31:0] ep14wire; //
wire [31:0] ep15wire; //
wire [31:0] ep16wire; //
wire [31:0] ep17wire; //
wire [31:0] ep18wire; //
wire [31:0] ep19wire; //
wire [31:0] ep1Awire; //
wire [31:0] ep1Bwire; //
wire [31:0] ep1Cwire; //
wire [31:0] ep1Dwire; //
wire [31:0] ep1Ewire; //
wire [31:0] ep1Fwire; //
//}

// Wire Out 	0x20 - 0x3F //{
wire [31:0] ep20wire;         //$$ [TEST] F_IMAGE_ID_WO       // PGU
wire [31:0] ep21wire = 32'b0; //
wire [31:0] ep22wire;         //$$ [TEST] TIMESTAMP_WO        // PGU
wire [31:0] ep23wire;         //$$ {TEST] TEST_IO_MON         // PGU
wire [31:0] ep24wire = 32'b0; //
wire [31:0] ep25wire;         //$$ [DACX] DACX_WO             // PGU
wire [31:0] ep26wire;         //$$ [CLKD] CLKD_WO             // PGU
wire [31:0] ep27wire;         //$$ [SPIO] SPIO_WO             // PGU
wire [31:0] ep28wire;         //$$ [DACZ] DACZ_DAT_WO         // PGU
wire [31:0] ep29wire;         //$$ [TRIG] TRIG_DAT_WO         // PGU reserved
wire [31:0] ep2Awire = 32'b0; //
wire [31:0] ep2Bwire = 32'b0; //
wire [31:0] ep2Cwire = 32'b0; //
wire [31:0] ep2Dwire = 32'b0; //
wire [31:0] ep2Ewire = 32'b0; //
wire [31:0] ep2Fwire = 32'b0; //
wire [31:0] ep30wire = 32'b0; //
wire [31:0] ep31wire = 32'b0; //
wire [31:0] ep32wire;         //$$ [SSPI] SSPI_FLAG_WO    //$$ S3100 // to revise
wire [31:0] ep33wire = 32'b0; //
wire [31:0] ep34wire = 32'b0; //
wire [31:0] ep35wire = 32'b0; //
wire [31:0] ep36wire = 32'b0; //
wire [31:0] ep37wire = 32'b0; //
wire [31:0] ep38wire = 32'b0; //
wire [31:0] ep39wire = 32'b0; //
wire [31:0] ep3Awire;         //$$ [XADC] XADC_TEMP       // PGU
wire [31:0] ep3Bwire;         //$$ [XADC] XADC_VOLT       // PGU
wire [31:0] ep3Cwire = 32'b0; //
wire [31:0] ep3Dwire = 32'b0; //
wire [31:0] ep3Ewire = 32'b0; //
wire [31:0] ep3Fwire = 32'b0; //
//}

// Trigger In 	0x40 - 0x5F //{
wire ep40ck = 1'b0;             wire [31:0] ep40trig;
wire ep41ck = 1'b0;             wire [31:0] ep41trig;
wire ep42ck = 1'b0;             wire [31:0] ep42trig;
wire ep43ck = 1'b0;             wire [31:0] ep43trig;
wire ep44ck = 1'b0;             wire [31:0] ep44trig;
wire ep45ck = sys_clk;          wire [31:0] ep45trig; //$$ [DACX] DACX_TI             // PGU
wire ep46ck = sys_clk;          wire [31:0] ep46trig; //$$ [CLKD] CLKD_TI             // PGU
wire ep47ck = sys_clk;          wire [31:0] ep47trig; //$$ [SPIO] SPIO_TI             // PGU
wire ep48ck = sys_clk;          wire [31:0] ep48trig; //$$ [DACZ] DACZ_DAT_TI         // PGU
wire ep49ck = sys_clk;          wire [31:0] ep49trig; //$$ [TRIG] TRIG_DAT_TI         // PGU reserved
wire ep4Ack = 1'b0;             wire [31:0] ep4Atrig;
wire ep4Bck = 1'b0;             wire [31:0] ep4Btrig;
wire ep4Cck = 1'b0;             wire [31:0] ep4Ctrig;
wire ep4Dck = 1'b0;             wire [31:0] ep4Dtrig;
wire ep4Eck = 1'b0;             wire [31:0] ep4Etrig;
wire ep4Fck = 1'b0;             wire [31:0] ep4Ftrig;
wire ep50ck = 1'b0;             wire [31:0] ep50trig;
wire ep51ck = 1'b0;             wire [31:0] ep51trig;
wire ep52ck = 1'b0;             wire [31:0] ep52trig;
wire ep53ck = sys_clk;          wire [31:0] ep53trig; //$$ [MEM] MEM_TI
wire ep54ck = 1'b0;             wire [31:0] ep54trig;
wire ep55ck = 1'b0;             wire [31:0] ep55trig;
wire ep56ck = 1'b0;             wire [31:0] ep56trig;
wire ep57ck = 1'b0;             wire [31:0] ep57trig;
wire ep58ck = 1'b0;             wire [31:0] ep58trig;
wire ep59ck = 1'b0;             wire [31:0] ep59trig;
wire ep5Ack = 1'b0;             wire [31:0] ep5Atrig;
wire ep5Bck = 1'b0;             wire [31:0] ep5Btrig;
wire ep5Cck = 1'b0;             wire [31:0] ep5Ctrig;
wire ep5Dck = 1'b0;             wire [31:0] ep5Dtrig;
wire ep5Eck = 1'b0;             wire [31:0] ep5Etrig;
wire ep5Fck = 1'b0;             wire [31:0] ep5Ftrig;
//}

// Trigger Out 	0x60 - 0x7F //{
wire ep60ck = 1'b0;             wire [31:0] ep60trig = 32'b0;
wire ep61ck = 1'b0;             wire [31:0] ep61trig = 32'b0;
wire ep62ck = 1'b0;             wire [31:0] ep62trig = 32'b0;
wire ep63ck = 1'b0;             wire [31:0] ep63trig = 32'b0;
wire ep64ck = 1'b0;             wire [31:0] ep64trig = 32'b0;
wire ep65ck = 1'b0;             wire [31:0] ep65trig = 32'b0;
wire ep66ck = 1'b0;             wire [31:0] ep66trig = 32'b0;
wire ep67ck = 1'b0;             wire [31:0] ep67trig = 32'b0;
wire ep68ck = 1'b0;             wire [31:0] ep68trig = 32'b0;
wire ep69ck = 1'b0;             wire [31:0] ep69trig = 32'b0;
wire ep6Ack = 1'b0;             wire [31:0] ep6Atrig = 32'b0;
wire ep6Bck = 1'b0;             wire [31:0] ep6Btrig = 32'b0;
wire ep6Cck = 1'b0;             wire [31:0] ep6Ctrig = 32'b0;
wire ep6Dck = 1'b0;             wire [31:0] ep6Dtrig = 32'b0;
wire ep6Eck = 1'b0;             wire [31:0] ep6Etrig = 32'b0;
wire ep6Fck = 1'b0;             wire [31:0] ep6Ftrig = 32'b0;
wire ep70ck = 1'b0;             wire [31:0] ep70trig = 32'b0;
wire ep71ck = 1'b0;             wire [31:0] ep71trig = 32'b0;
wire ep72ck = 1'b0;             wire [31:0] ep72trig = 32'b0;
wire ep73ck = sys_clk;          wire [31:0] ep73trig; //$$ [MEM] MEM_TO
wire ep74ck = 1'b0;             wire [31:0] ep74trig = 32'b0;
wire ep75ck = 1'b0;             wire [31:0] ep75trig = 32'b0;
wire ep76ck = 1'b0;             wire [31:0] ep76trig = 32'b0;
wire ep77ck = 1'b0;             wire [31:0] ep77trig = 32'b0;
wire ep78ck = 1'b0;             wire [31:0] ep78trig = 32'b0;
wire ep79ck = 1'b0;             wire [31:0] ep79trig = 32'b0;
wire ep7Ack = 1'b0;             wire [31:0] ep7Atrig = 32'b0;
wire ep7Bck = 1'b0;             wire [31:0] ep7Btrig = 32'b0;
wire ep7Cck = 1'b0;             wire [31:0] ep7Ctrig = 32'b0;
wire ep7Dck = 1'b0;             wire [31:0] ep7Dtrig = 32'b0;
wire ep7Eck = 1'b0;             wire [31:0] ep7Etrig = 32'b0;
wire ep7Fck = 1'b0;             wire [31:0] ep7Ftrig = 32'b0; 
//}

// Pipe In 		0x80 - 0x9F // clock is assumed to use epClk //{
wire ep80wr; wire [31:0] ep80pipe;
wire ep81wr; wire [31:0] ep81pipe;
wire ep82wr; wire [31:0] ep82pipe;
wire ep83wr; wire [31:0] ep83pipe;
wire ep84wr; wire [31:0] ep84pipe;
wire ep85wr; wire [31:0] ep85pipe;
wire ep86wr; wire [31:0] ep86pipe; //$$ [DACZ] DAC0_DAT_INC_PI
wire ep87wr; wire [31:0] ep87pipe; //$$ [DACZ] DAC0_DUR_PI 
wire ep88wr; wire [31:0] ep88pipe; //$$ [DACZ] DAC1_DAT_INC_PI
wire ep89wr; wire [31:0] ep89pipe; //$$ [DACZ] DAC1_DUR_PI 
wire ep8Awr; wire [31:0] ep8Apipe; //$$ [TEST] TEST_PI
wire ep8Bwr; wire [31:0] ep8Bpipe;
wire ep8Cwr; wire [31:0] ep8Cpipe;
wire ep8Dwr; wire [31:0] ep8Dpipe;
wire ep8Ewr; wire [31:0] ep8Epipe;
wire ep8Fwr; wire [31:0] ep8Fpipe;
wire ep90wr; wire [31:0] ep90pipe;
wire ep91wr; wire [31:0] ep91pipe;
wire ep92wr; wire [31:0] ep92pipe;
wire ep93wr; wire [31:0] ep93pipe; //$$ [MEM] MEM_PI
wire ep94wr; wire [31:0] ep94pipe;
wire ep95wr; wire [31:0] ep95pipe;
wire ep96wr; wire [31:0] ep96pipe;
wire ep97wr; wire [31:0] ep97pipe; 
wire ep98wr; wire [31:0] ep98pipe; 
wire ep99wr; wire [31:0] ep99pipe; 
wire ep9Awr; wire [31:0] ep9Apipe; 
wire ep9Bwr; wire [31:0] ep9Bpipe;
wire ep9Cwr; wire [31:0] ep9Cpipe;
wire ep9Dwr; wire [31:0] ep9Dpipe;
wire ep9Ewr; wire [31:0] ep9Epipe;
wire ep9Fwr; wire [31:0] ep9Fpipe;
//}

// Pipe Out 	0xA0 - 0xBF //{
wire epA0rd; wire [31:0] epA0pipe = 32'b0;
wire epA1rd; wire [31:0] epA1pipe = 32'b0;
wire epA2rd; wire [31:0] epA2pipe = 32'b0;
wire epA3rd; wire [31:0] epA3pipe = 32'b0;
wire epA4rd; wire [31:0] epA4pipe = 32'b0;
wire epA5rd; wire [31:0] epA5pipe = 32'b0;
wire epA6rd; wire [31:0] epA6pipe = 32'b0;
wire epA7rd; wire [31:0] epA7pipe = 32'b0;
wire epA8rd; wire [31:0] epA8pipe = 32'b0;
wire epA9rd; wire [31:0] epA9pipe = 32'b0;
wire epAArd; wire [31:0] epAApipe; //$$ [TEST] TEST_PO
wire epABrd; wire [31:0] epABpipe = 32'b0;
wire epACrd; wire [31:0] epACpipe = 32'b0;
wire epADrd; wire [31:0] epADpipe = 32'b0;
wire epAErd; wire [31:0] epAEpipe = 32'b0;
wire epAFrd; wire [31:0] epAFpipe = 32'b0;
wire epB0rd; wire [31:0] epB0pipe = 32'b0;
wire epB1rd; wire [31:0] epB1pipe = 32'b0;
wire epB2rd; wire [31:0] epB2pipe = 32'b0;
wire epB3rd; wire [31:0] epB3pipe; //$$ [MEM] MEM_PO
wire epB4rd; wire [31:0] epB4pipe = 32'b0;
wire epB5rd; wire [31:0] epB5pipe = 32'b0;
wire epB6rd; wire [31:0] epB6pipe = 32'b0;
wire epB7rd; wire [31:0] epB7pipe = 32'b0;
wire epB8rd; wire [31:0] epB8pipe = 32'b0;
wire epB9rd; wire [31:0] epB9pipe = 32'b0;
wire epBArd; wire [31:0] epBApipe = 32'b0;
wire epBBrd; wire [31:0] epBBpipe = 32'b0;
wire epBCrd; wire [31:0] epBCpipe = 32'b0;
wire epBDrd; wire [31:0] epBDpipe = 32'b0;
wire epBErd; wire [31:0] epBEpipe = 32'b0;
wire epBFrd; wire [31:0] epBFpipe = 32'b0;
//}

// Target interface clk: //{
//
//wire okClk;
wire epClk = base_sspi_clk; // okClk --> epClk
//}

//}

//// TODO: LAN end-point wires: //{

// wire in //{
wire [31:0] w_port_wi_00_1;
wire [31:0] w_port_wi_01_1; //$$ TEST_CON_WI   
wire [31:0] w_port_wi_02_1;
wire [31:0] w_port_wi_03_1; //$$ BRD_CON_WI    
wire [31:0] w_port_wi_04_1;
wire [31:0] w_port_wi_05_1; // DACX_WI       
wire [31:0] w_port_wi_06_1; // CLKD_WI       
wire [31:0] w_port_wi_07_1; // SPIO_WI       
wire [31:0] w_port_wi_08_1; // DACZ_DAT_WI   
wire [31:0] w_port_wi_09_1; // TRIG_DAT_WI   
wire [31:0] w_port_wi_0A_1;
wire [31:0] w_port_wi_0B_1;
wire [31:0] w_port_wi_0C_1;
wire [31:0] w_port_wi_0D_1;
wire [31:0] w_port_wi_0E_1;
wire [31:0] w_port_wi_0F_1;
wire [31:0] w_port_wi_10_1;
wire [31:0] w_port_wi_11_1;
wire [31:0] w_port_wi_12_1; //$$ MEM_FDAT_WI   
wire [31:0] w_port_wi_13_1; //$$ MEM_WI        
wire [31:0] w_port_wi_14_1;
wire [31:0] w_port_wi_15_1;
wire [31:0] w_port_wi_16_1; //$$ MSPI_EN_CS_WI 
wire [31:0] w_port_wi_17_1; //$$ MSPI_CON_WI   
wire [31:0] w_port_wi_18_1;
wire [31:0] w_port_wi_19_1; //$$ MCS_SETUP_WI  
wire [31:0] w_port_wi_1A_1;
wire [31:0] w_port_wi_1B_1;
wire [31:0] w_port_wi_1C_1;
wire [31:0] w_port_wi_1D_1;
wire [31:0] w_port_wi_1E_1;
wire [31:0] w_port_wi_1F_1;
//}

// wire out //{
wire [31:0] w_port_wo_20_1; //$$ F_IMAGE_ID_WO 
wire [31:0] w_port_wo_21_1; //$$ TEST_OUT_WO   
wire [31:0] w_port_wo_22_1; //$$ TIMESTAMP_WO  
wire [31:0] w_port_wo_23_1; //$$ TEST_MON_WO   
wire [31:0] w_port_wo_24_1; //$$ MSPI_FLAG_WO  
wire [31:0] w_port_wo_25_1; // DACX_WO       
wire [31:0] w_port_wo_26_1; // CLKD_WO       
wire [31:0] w_port_wo_27_1; // SPIO_WO       
wire [31:0] w_port_wo_28_1; // DACZ_DAT_WO   
wire [31:0] w_port_wo_29_1; // TRIG_DAT_WO   
wire [31:0] w_port_wo_2A_1 = 32'b0; //
wire [31:0] w_port_wo_2B_1 = 32'b0; //
wire [31:0] w_port_wo_2C_1 = 32'b0; //
wire [31:0] w_port_wo_2D_1 = 32'b0; //
wire [31:0] w_port_wo_2E_1 = 32'b0; //
wire [31:0] w_port_wo_2F_1 = 32'b0; //
wire [31:0] w_port_wo_30_1 = 32'b0; //
wire [31:0] w_port_wo_31_1 = 32'b0; //
wire [31:0] w_port_wo_32_1 = 32'b0; //
wire [31:0] w_port_wo_33_1 = 32'b0; //
wire [31:0] w_port_wo_34_1 = 32'b0; //
wire [31:0] w_port_wo_35_1 = 32'b0; //
wire [31:0] w_port_wo_36_1 = 32'b0; //
wire [31:0] w_port_wo_37_1 = 32'b0; //
wire [31:0] w_port_wo_38_1 = 32'b0; //
wire [31:0] w_port_wo_39_1 = 32'b0; //
wire [31:0] w_port_wo_3A_1; //$$ XADC_TEMP_WO  
wire [31:0] w_port_wo_3B_1; //$$ XADC_VOLT_WO  
wire [31:0] w_port_wo_3C_1 = 32'b0; //
wire [31:0] w_port_wo_3D_1 = 32'b0; //
wire [31:0] w_port_wo_3E_1 = 32'b0; //
wire [31:0] w_port_wo_3F_1 = 32'b0; //
//}

// trig in //{
wire w_ck_40_1 = sys_clk       ; wire [31:0] w_port_ti_40_1; //$$ TEST_TI       
wire w_ck_42_1 = base_sspi_clk ; wire [31:0] w_port_ti_42_1; //$$ MSPI_TI       
wire w_ck_45_1 = sys_clk       ; wire [31:0] w_port_ti_45_1; // DACX_TI       
wire w_ck_46_1 = sys_clk       ; wire [31:0] w_port_ti_46_1; // CLKD_TI       
wire w_ck_47_1 = sys_clk       ; wire [31:0] w_port_ti_47_1; // SPIO_TI        
wire w_ck_48_1 = sys_clk       ; wire [31:0] w_port_ti_48_1; // DACZ_DAT_TI
wire w_ck_49_1 = sys_clk       ; wire [31:0] w_port_ti_49_1; // TRIG_DAT_TI   
wire w_ck_53_1 = sys_clk       ; wire [31:0] w_port_ti_53_1; //$$ MEM_TI        
//}

// trig out //{
wire w_ck_60_1 = sys_clk       ; wire [31:0] w_port_to_60_1; //$$ TEST_TO       
wire w_ck_62_1 = base_sspi_clk ; wire [31:0] w_port_to_62_1; //$$ MSPI_TO       
wire w_ck_73_1 = sys_clk       ; wire [31:0] w_port_to_73_1; //$$ MEM_TO        
//}

// pipe in //{
wire w_wr_86_1; wire [31:0] w_port_pi_86_1; // DAC0_DAT_PI   
wire w_wr_87_1; wire [31:0] w_port_pi_87_1; // DAC0_DUR_PI   
wire w_wr_88_1; wire [31:0] w_port_pi_88_1; // DAC1_DAT_PI   
wire w_wr_89_1; wire [31:0] w_port_pi_89_1; // DAC1_DUR_PI   
wire w_wr_8A_1; wire [31:0] w_port_pi_8A_1; //$$ TEST_PI       
wire w_wr_93_1; wire [31:0] w_port_pi_93_1; //$$ MEM_PI        
//}

// pipe out //{
wire w_rd_AA_1; wire [31:0] w_port_po_AA_1; //$$ TEST_PO        
wire w_rd_B3_1; wire [31:0] w_port_po_B3_1; //$$ MEM_PO        
//}

//$$ TODO: pipe clock //{
wire w_ck_pipe; //

//}

//}

//}


///TODO: //-------------------------------------------------------//


/* TODO: END-POINTS wrapper for EP_LAN */ //{

// offset definition for mcs_io_bridge.v //{

//#define MCS_IO_INST_OFFSET              0x00000000 // for LAN
//#define MCS_IO_INST_OFFSET_CMU          0x00010000 // for CMU
//#define MCS_IO_INST_OFFSET_PGU          0x00020000 // for PGU
//#define MCS_IO_INST_OFFSET_EXT          0x00030000 // for MHVSU_BASE (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_CMU      0x00040000 // for NEW CMU (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_PGU      0x00050000 // for NEW PGU (port end-points + lan end-points) //$$ to come

//}

// lan_endpoint_wrapper   //{

wire [47:0] w_adrs_offset_mac_48b; // BASE = {8'h00,8'h08,8'hDC,8'h00,8'hAB,8'hCD}; // 00:08:DC:00:xx:yy ??48 bits
wire [31:0] w_adrs_offset_ip_32b ; // BASE = {8'd192,8'd168,8'd168,8'd112}; // 192.168.168.112 or C0:A8:A8:70 ??32 bits
wire [15:0] w_offset_lan_timeout_rtr_16b; // assign later 
wire [15:0] w_offset_lan_timeout_rcr_16b; // assign later 

wire  EP_LAN_MOSI ; // rev 20210105
wire  EP_LAN_SCLK ; // rev 20210105
wire  EP_LAN_CS_B ; // rev 20210105
wire  EP_LAN_INT_B; // rev 20210105
wire  EP_LAN_RST_B; // rev 20210105
wire  EP_LAN_MISO ; // rev 20210105

lan_endpoint_wrapper #(
	//.MCS_IO_INST_OFFSET			(32'h_0004_0000), //$$ for CMU2020
	//.MCS_IO_INST_OFFSET			(32'h_0005_0000), //$$ for PGU2020 or S3000-PGU
	//.MCS_IO_INST_OFFSET			(32'h_0006_0000), //$$ for S3100-CPU-BASE
	.MCS_IO_INST_OFFSET			(32'h_0007_0000), //$$ for S3100-PGU
	.FPGA_IMAGE_ID              (FPGA_IMAGE_ID)  
) lan_endpoint_wrapper_inst (
	
	//// pins and config //{
	
	// EP_LAN pins 
	.EP_LAN_MOSI   (EP_LAN_MOSI ), // output wire     EP_LAN_MOSI  ,
	.EP_LAN_SCLK   (EP_LAN_SCLK ), // output wire     EP_LAN_SCLK  ,
	.EP_LAN_CS_B   (EP_LAN_CS_B ), // output wire     EP_LAN_CS_B  ,
	.EP_LAN_INT_B  (EP_LAN_INT_B), // input  wire     EP_LAN_INT_B ,
	.EP_LAN_RST_B  (EP_LAN_RST_B), // output wire     EP_LAN_RST_B ,
	.EP_LAN_MISO   (EP_LAN_MISO ), // input  wire     EP_LAN_MISO  ,
	
	// for common 
	.clk           (sys_clk), // 10MHz
	.reset_n       (reset_n),
	
	// soft CPU clock
	.mcs_clk       (mcs_clk), // 72MHz
	
	// dedicated LAN clock 
	.lan_clk       (lan_clk), // 144MHz
	
	// MAC/IP address offsets
	.i_adrs_offset_mac_48b  (w_adrs_offset_mac_48b), // input  wire [47:0]  
	.i_adrs_offset_ip_32b   (w_adrs_offset_ip_32b ), // input  wire [31:0]  
	// LAN timeout setup
	.i_offset_lan_timeout_rtr_16b  (w_offset_lan_timeout_rtr_16b), // input  wire [15:0]
	.i_offset_lan_timeout_rcr_16b  (w_offset_lan_timeout_rcr_16b), // input  wire [15:0]
	
	//}

	// Wire In 		0x00 - 0x1F  //{
	.ep00wire (w_port_wi_00_1), // output wire [31:0]
	.ep01wire (w_port_wi_01_1), // output wire [31:0]
	.ep02wire (w_port_wi_02_1), // output wire [31:0]
	.ep03wire (w_port_wi_03_1), // output wire [31:0]
	.ep04wire (w_port_wi_04_1), // output wire [31:0]
	.ep05wire (w_port_wi_05_1), // output wire [31:0]
	.ep06wire (w_port_wi_06_1), // output wire [31:0]
	.ep07wire (w_port_wi_07_1), // output wire [31:0]
	.ep08wire (w_port_wi_08_1), // output wire [31:0]
	.ep09wire (w_port_wi_09_1), // output wire [31:0]
	.ep0Awire (w_port_wi_0A_1), // output wire [31:0]
	.ep0Bwire (w_port_wi_0B_1), // output wire [31:0]
	.ep0Cwire (w_port_wi_0C_1), // output wire [31:0]
	.ep0Dwire (w_port_wi_0D_1), // output wire [31:0]
	.ep0Ewire (w_port_wi_0E_1), // output wire [31:0]
	.ep0Fwire (w_port_wi_0F_1), // output wire [31:0]
	.ep10wire (w_port_wi_10_1), // output wire [31:0]
	.ep11wire (w_port_wi_11_1), // output wire [31:0]
	.ep12wire (w_port_wi_12_1), // output wire [31:0]
	.ep13wire (w_port_wi_13_1), // output wire [31:0]
	.ep14wire (w_port_wi_14_1), // output wire [31:0]
	.ep15wire (w_port_wi_15_1), // output wire [31:0]
	.ep16wire (w_port_wi_16_1), // output wire [31:0]
	.ep17wire (w_port_wi_17_1), // output wire [31:0]
	.ep18wire (w_port_wi_18_1), // output wire [31:0]
	.ep19wire (w_port_wi_19_1), // output wire [31:0]
	.ep1Awire (w_port_wi_1A_1), // output wire [31:0]
	.ep1Bwire (w_port_wi_1B_1), // output wire [31:0]
	.ep1Cwire (w_port_wi_1C_1), // output wire [31:0]
	.ep1Dwire (w_port_wi_1D_1), // output wire [31:0]
	.ep1Ewire (w_port_wi_1E_1), // output wire [31:0]
	.ep1Fwire (w_port_wi_1F_1), // output wire [31:0]
	//}
	
	// Wire Out 	0x20 - 0x3F //{
	.ep20wire (w_port_wo_20_1), // input wire [31:0]
	.ep21wire (w_port_wo_21_1), // input wire [31:0]
	.ep22wire (w_port_wo_22_1), // input wire [31:0]
	.ep23wire (w_port_wo_23_1), // input wire [31:0]
	.ep24wire (w_port_wo_24_1), // input wire [31:0]
	.ep25wire (w_port_wo_25_1), // input wire [31:0]
	.ep26wire (w_port_wo_26_1), // input wire [31:0]
	.ep27wire (w_port_wo_27_1), // input wire [31:0]
	.ep28wire (w_port_wo_28_1), // input wire [31:0]
	.ep29wire (w_port_wo_29_1), // input wire [31:0]
	.ep2Awire (w_port_wo_2A_1), // input wire [31:0]
	.ep2Bwire (w_port_wo_2B_1), // input wire [31:0]
	.ep2Cwire (w_port_wo_2C_1), // input wire [31:0]
	.ep2Dwire (w_port_wo_2D_1), // input wire [31:0]
	.ep2Ewire (w_port_wo_2E_1), // input wire [31:0]
	.ep2Fwire (w_port_wo_2F_1), // input wire [31:0]
	.ep30wire (w_port_wo_30_1), // input wire [31:0]
	.ep31wire (w_port_wo_31_1), // input wire [31:0]
	.ep32wire (w_port_wo_32_1), // input wire [31:0]
	.ep33wire (w_port_wo_33_1), // input wire [31:0]
	.ep34wire (w_port_wo_34_1), // input wire [31:0]
	.ep35wire (w_port_wo_35_1), // input wire [31:0]
	.ep36wire (w_port_wo_36_1), // input wire [31:0]
	.ep37wire (w_port_wo_37_1), // input wire [31:0]
	.ep38wire (w_port_wo_38_1), // input wire [31:0]
	.ep39wire (w_port_wo_39_1), // input wire [31:0]
	.ep3Awire (w_port_wo_3A_1), // input wire [31:0]
	.ep3Bwire (w_port_wo_3B_1), // input wire [31:0]
	.ep3Cwire (w_port_wo_3C_1), // input wire [31:0]
	.ep3Dwire (w_port_wo_3D_1), // input wire [31:0]
	.ep3Ewire (w_port_wo_3E_1), // input wire [31:0]
	.ep3Fwire (w_port_wo_3F_1), // input wire [31:0]
	//}
	
	// Trigger In 	0x40 - 0x5F //{
	.ep40ck (w_ck_40_1), .ep40trig (w_port_ti_40_1), // input wire, output wire [31:0],
	.ep41ck (1'b0),      .ep41trig (), // input wire, output wire [31:0],
	.ep42ck (w_ck_42_1), .ep42trig (w_port_ti_42_1), // input wire, output wire [31:0],
	.ep43ck (1'b0),      .ep43trig (), // input wire, output wire [31:0],
	.ep44ck (1'b0),      .ep44trig (), // input wire, output wire [31:0],
	.ep45ck (w_ck_45_1), .ep45trig (w_port_ti_45_1), // input wire, output wire [31:0],
	.ep46ck (w_ck_46_1), .ep46trig (w_port_ti_46_1), // input wire, output wire [31:0],
	.ep47ck (w_ck_47_1), .ep47trig (w_port_ti_47_1), // input wire, output wire [31:0],
	.ep48ck (w_ck_48_1), .ep48trig (w_port_ti_48_1), // input wire, output wire [31:0],
	.ep49ck (w_ck_49_1), .ep49trig (w_port_ti_49_1), // input wire, output wire [31:0],
	.ep4Ack (1'b0),      .ep4Atrig (), // input wire, output wire [31:0],
	.ep4Bck (1'b0),      .ep4Btrig (), // input wire, output wire [31:0],
	.ep4Cck (1'b0),      .ep4Ctrig (), // input wire, output wire [31:0],
	.ep4Dck (1'b0),      .ep4Dtrig (), // input wire, output wire [31:0],
	.ep4Eck (1'b0),      .ep4Etrig (), // input wire, output wire [31:0],
	.ep4Fck (1'b0),      .ep4Ftrig (), // input wire, output wire [31:0],
	.ep50ck (1'b0),      .ep50trig (), // input wire, output wire [31:0],
	.ep51ck (1'b0),      .ep51trig (), // input wire, output wire [31:0],
	.ep52ck (1'b0),      .ep52trig (), // input wire, output wire [31:0],
	.ep53ck (w_ck_53_1), .ep53trig (w_port_ti_53_1), // input wire, output wire [31:0],
	.ep54ck (1'b0),      .ep54trig (), // input wire, output wire [31:0],
	.ep55ck (1'b0),      .ep55trig (), // input wire, output wire [31:0],
	.ep56ck (1'b0),      .ep56trig (), // input wire, output wire [31:0],
	.ep57ck (1'b0),      .ep57trig (), // input wire, output wire [31:0],
	.ep58ck (1'b0),      .ep58trig (), // input wire, output wire [31:0],
	.ep59ck (1'b0),      .ep59trig (), // input wire, output wire [31:0],
	.ep5Ack (1'b0),      .ep5Atrig (), // input wire, output wire [31:0],
	.ep5Bck (1'b0),      .ep5Btrig (), // input wire, output wire [31:0],
	.ep5Cck (1'b0),      .ep5Ctrig (), // input wire, output wire [31:0],
	.ep5Dck (1'b0),      .ep5Dtrig (), // input wire, output wire [31:0],
	.ep5Eck (1'b0),      .ep5Etrig (), // input wire, output wire [31:0],
	.ep5Fck (1'b0),      .ep5Ftrig (), // input wire, output wire [31:0],
	//}
	
	// Trigger Out 	0x60 - 0x7F //{
	.ep60ck (w_ck_60_1), .ep60trig (w_port_to_60_1), // input wire, input wire [31:0],
	.ep61ck (1'b0),      .ep61trig (32'b0), // input wire, input wire [31:0],
	.ep62ck (w_ck_62_1), .ep62trig (w_port_to_62_1), // input wire, input wire [31:0],
	.ep63ck (1'b0),      .ep63trig (32'b0), // input wire, input wire [31:0],
	.ep64ck (1'b0),      .ep64trig (32'b0), // input wire, input wire [31:0],
	.ep65ck (1'b0),      .ep65trig (32'b0), // input wire, input wire [31:0],
	.ep66ck (1'b0),      .ep66trig (32'b0), // input wire, input wire [31:0],
	.ep67ck (1'b0),      .ep67trig (32'b0), // input wire, input wire [31:0],
	.ep68ck (1'b0),      .ep68trig (32'b0), // input wire, input wire [31:0],
	.ep69ck (1'b0),      .ep69trig (32'b0), // input wire, input wire [31:0],
	.ep6Ack (1'b0),      .ep6Atrig (32'b0), // input wire, input wire [31:0],
	.ep6Bck (1'b0),      .ep6Btrig (32'b0), // input wire, input wire [31:0],
	.ep6Cck (1'b0),      .ep6Ctrig (32'b0), // input wire, input wire [31:0],
	.ep6Dck (1'b0),      .ep6Dtrig (32'b0), // input wire, input wire [31:0],
	.ep6Eck (1'b0),      .ep6Etrig (32'b0), // input wire, input wire [31:0],
	.ep6Fck (1'b0),      .ep6Ftrig (32'b0), // input wire, input wire [31:0],
	.ep70ck (1'b0),      .ep70trig (32'b0), // input wire, input wire [31:0],
	.ep71ck (1'b0),      .ep71trig (32'b0), // input wire, input wire [31:0],
	.ep72ck (1'b0),      .ep72trig (32'b0), // input wire, input wire [31:0],
	.ep73ck (w_ck_73_1), .ep73trig (w_port_to_73_1), // input wire, input wire [31:0],
	.ep74ck (1'b0),      .ep74trig (32'b0), // input wire, input wire [31:0],
	.ep75ck (1'b0),      .ep75trig (32'b0), // input wire, input wire [31:0],
	.ep76ck (1'b0),      .ep76trig (32'b0), // input wire, input wire [31:0],
	.ep77ck (1'b0),      .ep77trig (32'b0), // input wire, input wire [31:0],
	.ep78ck (1'b0),      .ep78trig (32'b0), // input wire, input wire [31:0],
	.ep79ck (1'b0),      .ep79trig (32'b0), // input wire, input wire [31:0],
	.ep7Ack (1'b0),      .ep7Atrig (32'b0), // input wire, input wire [31:0],
	.ep7Bck (1'b0),      .ep7Btrig (32'b0), // input wire, input wire [31:0],
	.ep7Cck (1'b0),      .ep7Ctrig (32'b0), // input wire, input wire [31:0],
	.ep7Dck (1'b0),      .ep7Dtrig (32'b0), // input wire, input wire [31:0],
	.ep7Eck (1'b0),      .ep7Etrig (32'b0), // input wire, input wire [31:0],
	.ep7Fck (1'b0),      .ep7Ftrig (32'b0), // input wire, input wire [31:0],
	//}
	
	// Pipe In 		0x80 - 0x9F //{
	.ep80wr (),          .ep80pipe (), // output wire, output wire [31:0],
	.ep81wr (),          .ep81pipe (), // output wire, output wire [31:0],
	.ep82wr (),          .ep82pipe (), // output wire, output wire [31:0],
	.ep83wr (),          .ep83pipe (), // output wire, output wire [31:0],
	.ep84wr (),          .ep84pipe (), // output wire, output wire [31:0],
	.ep85wr (),          .ep85pipe (), // output wire, output wire [31:0],
	.ep86wr (w_wr_86_1), .ep86pipe (w_port_pi_86_1), // output wire, output wire [31:0],
	.ep87wr (w_wr_87_1), .ep87pipe (w_port_pi_87_1), // output wire, output wire [31:0],
	.ep88wr (w_wr_88_1), .ep88pipe (w_port_pi_88_1), // output wire, output wire [31:0],
	.ep89wr (w_wr_89_1), .ep89pipe (w_port_pi_89_1), // output wire, output wire [31:0],
	.ep8Awr (w_wr_8A_1), .ep8Apipe (w_port_pi_8A_1), // output wire, output wire [31:0],
	.ep8Bwr (),          .ep8Bpipe (), // output wire, output wire [31:0],
	.ep8Cwr (),          .ep8Cpipe (), // output wire, output wire [31:0],
	.ep8Dwr (),          .ep8Dpipe (), // output wire, output wire [31:0],
	.ep8Ewr (),          .ep8Epipe (), // output wire, output wire [31:0],
	.ep8Fwr (),          .ep8Fpipe (), // output wire, output wire [31:0],
	.ep90wr (),          .ep90pipe (), // output wire, output wire [31:0],
	.ep91wr (),          .ep91pipe (), // output wire, output wire [31:0],
	.ep92wr (),          .ep92pipe (), // output wire, output wire [31:0],
	.ep93wr (w_wr_93_1), .ep93pipe (w_port_pi_93_1), // output wire, output wire [31:0],
	.ep94wr (),          .ep94pipe (), // output wire, output wire [31:0],
	.ep95wr (),          .ep95pipe (), // output wire, output wire [31:0],
	.ep96wr (),          .ep96pipe (), // output wire, output wire [31:0],
	.ep97wr (),          .ep97pipe (), // output wire, output wire [31:0],
	.ep98wr (),          .ep98pipe (), // output wire, output wire [31:0],
	.ep99wr (),          .ep99pipe (), // output wire, output wire [31:0],
	.ep9Awr (),          .ep9Apipe (), // output wire, output wire [31:0],
	.ep9Bwr (),          .ep9Bpipe (), // output wire, output wire [31:0],
	.ep9Cwr (),          .ep9Cpipe (), // output wire, output wire [31:0],
	.ep9Dwr (),          .ep9Dpipe (), // output wire, output wire [31:0],
	.ep9Ewr (),          .ep9Epipe (), // output wire, output wire [31:0],
	.ep9Fwr (),          .ep9Fpipe (), // output wire, output wire [31:0],
	//}
	
	// Pipe Out 	0xA0 - 0xBF //{
	.epA0rd (),          .epA0pipe (32'b0), // output wire, input wire [31:0],
	.epA1rd (),          .epA1pipe (32'b0), // output wire, input wire [31:0],
	.epA2rd (),          .epA2pipe (32'b0), // output wire, input wire [31:0],
	.epA3rd (),          .epA3pipe (32'b0), // output wire, input wire [31:0],
	.epA4rd (),          .epA4pipe (32'b0), // output wire, input wire [31:0],
	.epA5rd (),          .epA5pipe (32'b0), // output wire, input wire [31:0],
	.epA6rd (),          .epA6pipe (32'b0), // output wire, input wire [31:0],
	.epA7rd (),          .epA7pipe (32'b0), // output wire, input wire [31:0],
	.epA8rd (),          .epA8pipe (32'b0), // output wire, input wire [31:0],
	.epA9rd (),          .epA9pipe (32'b0), // output wire, input wire [31:0],
	.epAArd (w_rd_AA_1), .epAApipe (w_port_po_AA_1), // output wire, input wire [31:0],
	.epABrd (),          .epABpipe (32'b0), // output wire, input wire [31:0],
	.epACrd (),          .epACpipe (32'b0), // output wire, input wire [31:0],
	.epADrd (),          .epADpipe (32'b0), // output wire, input wire [31:0],
	.epAErd (),          .epAEpipe (32'b0), // output wire, input wire [31:0],
	.epAFrd (),          .epAFpipe (32'b0), // output wire, input wire [31:0],
	.epB0rd (),          .epB0pipe (32'b0), // output wire, input wire [31:0],
	.epB1rd (),          .epB1pipe (32'b0), // output wire, input wire [31:0],
	.epB2rd (),          .epB2pipe (32'b0), // output wire, input wire [31:0],
	.epB3rd (w_rd_B3_1), .epB3pipe (w_port_po_B3_1), // output wire, input wire [31:0],
	.epB4rd (),          .epB4pipe (32'b0), // output wire, input wire [31:0],
	.epB5rd (),          .epB5pipe (32'b0), // output wire, input wire [31:0],
	.epB6rd (),          .epB6pipe (32'b0), // output wire, input wire [31:0],
	.epB7rd (),          .epB7pipe (32'b0), // output wire, input wire [31:0],
	.epB8rd (),          .epB8pipe (32'b0), // output wire, input wire [31:0],
	.epB9rd (),          .epB9pipe (32'b0), // output wire, input wire [31:0],
	.epBArd (),          .epBApipe (32'b0), // output wire, input wire [31:0],
	.epBBrd (),          .epBBpipe (32'b0), // output wire, input wire [31:0],
	.epBCrd (),          .epBCpipe (32'b0), // output wire, input wire [31:0],
	.epBDrd (),          .epBDpipe (32'b0), // output wire, input wire [31:0],
	.epBErd (),          .epBEpipe (32'b0), // output wire, input wire [31:0],
	.epBFrd (),          .epBFpipe (32'b0), // output wire, input wire [31:0],
	//}
	
	// Pipe clock output //{
	.epPPck (w_ck_pipe) //output wire // sync with write/read of pipe // 72MHz
	//}
	);

//}

// assign //{

assign w_adrs_offset_mac_48b[47:16] = {8'h00,8'h00,8'h00,8'h00}; // assign high 32b
assign w_adrs_offset_ip_32b [31:16] = {8'h00,8'h00}            ; // assign high 16b
assign w_offset_lan_timeout_rtr_16b = 16'd0;
assign w_offset_lan_timeout_rcr_16b = 16'd0;

//}

////

//}



///TODO: //-------------------------------------------------------//


/* TODO: mapping endpoints to signals for S3100-PGU board */ //{

// most control in signals

//// BRD_CON //{
wire [31:0] w_BRD_CON = w_port_wi_03_1; //$$ board control from LAN
// reset wires 
// endpoint mux enable : LAN(MCS) over SSPI

// reset wires 
//wire w_HW_reset     = w_BRD_CON[0];
//wire w_rst_adc      = w_BRD_CON[1]; 
//wire w_rst_dwave    = w_BRD_CON[2]; 
//wire w_rst_bias     = w_BRD_CON[3]; 
//wire w_rst_spo      = w_BRD_CON[4]; 

// endpoint mux enable : LAN(MCS) vs SSPI
wire w_mcs_ep_po_en = w_BRD_CON[ 8]; 
wire w_mcs_ep_pi_en = w_BRD_CON[ 9]; 
wire w_mcs_ep_to_en = w_BRD_CON[10]; 
wire w_mcs_ep_ti_en = w_BRD_CON[11];  
wire w_mcs_ep_wo_en = w_BRD_CON[12]; 
wire w_mcs_ep_wi_en = w_BRD_CON[13]; 

//}

//// MCS_SETUP_WI //{

// MCS control 
wire [31:0] w_MCS_SETUP_WI = w_port_wi_19_1; //$$ dedicated to MCS. updated by MCS boot-up.
// bit[7:0]=slot_id, range of 00~99, set from EEPROM via MCS //$$ 4 --> 8 bits in S3100-PGU
// ...
// bit[ 8]=sel__H_LAN_for_EEPROM_fifo (or SSPI)
// bit[ 9]=sel__H_EEPROM_on_TP (or on Base)      //$$ to remove in S3100-PGU
// bit[10]=sel__H_LAN_on_BASE_BD (or on module)  //$$ to remove in S3100-PGU
// bit[15:11]=reserved
// ...
// bit[31:16]=board_id, range of 0000~9999, set from EEPROM via MCS

wire [3:0]  w_slot_id             = w_MCS_SETUP_WI[3:0];   //$$ 4 bits in S3100-PGU
wire [7:0]  w_slot_id_8b          = w_MCS_SETUP_WI[7:0];   //$$ 8 bits in S3100-PGU
//
//$$ note ... need to protect MCS_SETUP_WI[15:8] by SDK
//##wire w_sel__H_LAN_for_EEPROM_fifo = w_MCS_SETUP_WI[8];     //$$ removed in S3100-PGU 
//##wire w_sel__H_EEPROM_on_TP        = w_MCS_SETUP_WI[9];     //$$ removed in S3100-PGU 
//##wire w_sel__H_LAN_on_BASE_BD      = w_MCS_SETUP_WI[10];    //$$ removed in S3100-PGU 
//
wire [15:0] w_board_id            = w_MCS_SETUP_WI[31:16]; 

// for dedicated LAN setup from MCS
//$$assign w_adrs_offset_mac_48b[15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
//$$assign w_adrs_offset_ip_32b [15:0] = {8'h00, 4'h0, w_slot_id}; // assign low 16b
assign w_adrs_offset_mac_48b[15:0] = {8'h00, w_slot_id_8b}; // assign low 16b
assign w_adrs_offset_ip_32b [15:0] = {8'h00, w_slot_id_8b}; // assign low 16b

//}

//// TEST wires //{


// check IDs end-point //{
wire [31:0] w_F_IMAGE_ID_WO = FPGA_IMAGE_ID ;
//
assign         ep20wire = w_F_IMAGE_ID_WO; //$$ SSPI
assign w_port_wo_20_1   = w_F_IMAGE_ID_WO; //$$ LAN
//}

// timestamp //{
(* keep = "true" *) wire [31:0] w_TIMESTAMP_WO;
assign         ep22wire = w_TIMESTAMP_WO;
assign w_port_wo_22_1   = w_TIMESTAMP_WO;
//}

// TEST counter end-point //{
wire [31:0] w_TEST_CON_WI = w_port_wi_01_1; //$$ (w_mcs_ep_wi_en)? w_port_wi_01_1 : ep01wire;
//
wire [31:0] w_TEST_OUT_WO;
//assign ep21wire = (!w_mcs_ep_wo_en)? w_TEST_OUT_WO : 32'hACAC_ACAC; // TEST_OUT
assign w_port_wo_21_1 = w_TEST_OUT_WO; //$$ (w_mcs_ep_wo_en)? w_TEST_OUT_WO : 32'hACAC_ACAC;
//
wire [31:0] w_TEST_TI = w_port_ti_40_1; //$$ (w_mcs_ep_ti_en)? w_port_ti_40_1 : ep40trig;
//
wire [31:0] w_TEST_TO;
//assign ep60trig = w_TEST_TO; //$$
assign w_port_to_60_1 = w_TEST_TO; //$$ (w_mcs_ep_to_en)? w_TEST_TO : 32'h0000_0000; //$$
//}

// TEST_IO end-point //{

wire [31:0] w_TEST_MON_WO; //$$ S3000-PGU // w_TEST_IO_MON --> w_TEST_MON_WO
// check pll status
assign         ep23wire = w_TEST_MON_WO;
assign w_port_wo_23_1   = w_TEST_MON_WO;

// assign ep23wire       = (!w_mcs_ep_wo_en)? w_TEST_MON_WO : 32'hACAC_ACAC;
// assign w_port_wo_23_1 = ( w_mcs_ep_wo_en)? w_TEST_MON_WO : 32'hACAC_ACAC;
// //
// wire [31:0] w_TEST_IO_TI = (w_mcs_ep_ti_en)? w_port_ti_43_1 : ep43trig; ; //$$ removed in S3000-PGU
// //
assign w_TEST_MON_WO[31] = 1'b0;
assign w_TEST_MON_WO[30] = 1'b0;
assign w_TEST_MON_WO[29] = 1'b0;
assign w_TEST_MON_WO[28:27] =  2'b0;
assign w_TEST_MON_WO[26] = dac1_dco_clk_locked; //$$ DAC1 pll locked
assign w_TEST_MON_WO[25] = dac0_dco_clk_locked; //$$ DAC0 pll locked
assign w_TEST_MON_WO[24] = clk_dac_locked; //$$ DAC common pll locked
assign w_TEST_MON_WO[23:20] =  4'b0;
assign w_TEST_MON_WO[19] = clk4_locked; //$$ NA
assign w_TEST_MON_WO[18] = clk3_locked; //$$ mcs pll locked
assign w_TEST_MON_WO[17] = clk2_locked; //$$ NA
assign w_TEST_MON_WO[16] = clk1_locked; //$$ NA
assign w_TEST_MON_WO[15: 0] = 16'b0;

//}


//}


//// SSPI and MSPI wires //{

//$$ note : to revise SSPI control access from LAN or SSPI
wire [31:0] w_SSPI_CON_WI  = ep02wire; // controls ... 
			// w_SSPI_CON_WI[0] enables LAN control ... USB vs LAN vs SSPI 
			// w_SSPI_CON_WI[1] ...
wire [31:0] w_SSPI_FLAG_WO; 
assign ep32wire = w_SSPI_FLAG_WO; //$$ ep22wire --> ep23wire --> ep32wire

// HW reset signal : MEM, TEST_COUNTER, XADC, TIMESTAMP // SPIO, DAC, ADC, TRIG_IO,
//wire w_HW_reset__ext; // from SSPI
//wire w_HW_reset = w_SSPI_CON_WI[3] | w_HW_reset__ext | w_BRD_CON[0] ; //$$
wire w_HW_reset = w_SSPI_CON_WI[3] | w_BRD_CON[0] ; //$$

wire w_SSPI_TEST_mode_en; //$$ hw emulation for mother board master spi //$$ w_MTH_SPI_emulation__en ??


wire [31:0] w_MSPI_CON_WI   = w_port_wi_17_1; //$$ MSPI frame data
wire [31:0] w_MSPI_EN_CS_WI = w_port_wi_16_1; //$$ MSPI nCSX enable //$$ only for S3100-CPU-BASE

wire [31:0] w_MSPI_FLAG_WO; 
assign w_port_wo_24_1   = w_MSPI_FLAG_WO; 

//$$ w_SSPI_TEST_TI --> w_MSPI_TI 
wire [31:0] w_MSPI_TI   = w_port_ti_42_1; 

//$$ w_SSPI_TEST_TO --> w_MSPI_TO 
wire [31:0] w_MSPI_TO;
assign w_port_to_62_1 = w_MSPI_TO;


//
//wire [31:0] w_SSPI_CNT_CS_M0_WO         ;  // rev...
//wire [31:0] w_SSPI_CNT_CS_M1_WO         ;  // rev...
//wire [31:0] w_SSPI_CNT_ADC_FIFO_IN_WO   ;  // rev...
//wire [31:0] w_SSPI_CNT_ADC_TRIG_WO      ;  // rev...
//wire [31:0] w_SSPI_CNT_SPIO_FRM_TRIG_WO ;  // rev...
//wire [31:0] w_SSPI_CNT_DAC_TRIG_WO      ;  // rev...

// for w_MSPI_FLAG_WO or w_TEST_FLAG_WO
//assign w_TEST_FLAG_WO[23]    = w_SSPI_TEST_mode_en; //$$
//assign w_TEST_FLAG_WO[22:20] = 3'b0; //$$ not yet used
//assign w_TEST_FLAG_WO[31:24] = {r_EXT_TRIG[0], r_EXT_BUSY_B_OUT, w_spio_busy_cowork, w_dac_busy_cowork, 
//							    w_adc_busy_cowork, r_M_TRIG[0], r_M_PRE_TRIG[0], r_M_BUSY_B_OUT}; 
//assign w_SSPI_TEST_WO[15:0] = w_SSPI_frame_data_B[15:0];
//
//assign w_MSPI_FLAG_WO[31:24] = 8'b0; //$$ not yet used
//assign w_MSPI_FLAG_WO[23]    = w_SSPI_TEST_mode_en;
//assign w_MSPI_FLAG_WO[22:20] = 3'b0; //$$ not yet used
//assign w_MSPI_FLAG_WO[19:16] = 4'b0; //$$ not yet used
//assign w_MSPI_FLAG_WO[15:0 ] = w_SSPI_frame_data_B[15:0]; // to come below

//}


//// SPIO wires //{

// SPIO_WI @ ep07wire = {3'b0,i_CS_id,i_pin_adrs_A[2:0],i_R_W_bar,i_reg_adrs_A,i_wr_DA[7:0],i_wr_DB[7:0]}
// SPIO_WO @ ep27wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset,8'b0,o_rd_DA[7:0],o_rd_DB[7:0]}
// SPIO_TI @ ep47trig

wire [31:0] w_SPIO_WI   = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_07_1 : ep07wire; 
wire [31:0] w_SPIO_WO; 
assign         ep27wire = w_SPIO_WO; 
assign w_port_wo_27_1   = w_SPIO_WO;
wire [31:0] w_SPIO_TI   =                                           w_port_ti_47_1 | ep47trig;

//}

//// CLKD wires //{

// CLKD_WI @ ep06wire = {i_R_W_bar,2'b0,3'b0,i_reg_adrs_A[9:0],8'b0,i_wr_D[7:0]}
// CLKD_WO @ ep26wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset,8'b0,8'b0,o_rd_D[7:0]}
// CLKD_TI @ ep46trig

(* keep = "true" *) 
wire [31:0] w_CLKD_WI   = (w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_06_1 : ep06wire;
(* keep = "true" *) 
wire [31:0] w_CLKD_WO;
assign         ep26wire = w_CLKD_WO; 
assign w_port_wo_26_1   = w_CLKD_WO;
(* keep = "true" *) 
wire [31:0] w_CLKD_TI   =                                          w_port_ti_46_1 | ep46trig;

//}

//// TRIG wires //{

//// control for external trig in and out 
// TRIG_DAT_WI @ ep09wire   
// TRIG_DAT_WO @ ep29wire
// TRIG_DAT_TI @ ep49trig

wire [31:0] w_TRIG_DAT_WI = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_09_1 : ep09wire; 
wire [31:0] w_TRIG_DAT_WO;
assign         ep29wire   = w_TRIG_DAT_WO; 
assign w_port_wo_29_1     = w_TRIG_DAT_WO;
wire [31:0] w_TRIG_DAT_TI =                                           w_port_ti_49_1 | ep49trig;

//}

//// DACX and DACZ wires //{

//// control for AD9783
// DACX_WI @ ep05wire = {1'b0,clk_rst[2:0], 3'b0,i_CS_id, i_R_W_bar, i_byte_mode_N, i_reg_adrs_A, 8'b0, i_wr_D}
// DACX_WO @ ep25wire = {6'b0,o_done_SPI_frame,o_done_LNG_reset, 16'b0 , o_rd_D}
// DACX_TI @ ep45trig

wire [31:0] w_DACX_WI   = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_05_1 : ep05wire; 
//  bit[30]    = dac1_dco_clk_rst      
//  bit[29]    = dac0_dco_clk_rst      
//  bit[28]    = clk_dac_clk_rst       
//  bit[27]    = dac1_clk_dis          
//  bit[26]    = dac0_clk_dis          
//  bit[24]    = DACx_CS_id            
//  bit[23]    = DACx_R_W_bar          
//  bit[22:21] = DACx_byte_mode_N[1:0] 
//  bit[20:16] = DACx_reg_adrs_A [4:0] 
//  bit[7:0]   = DACx_wr_D[7:0]        

wire [31:0] w_DACX_WO; 
assign         ep25wire = w_DACX_WO; 
assign w_port_wo_25_1   = w_DACX_WO;
//  bit[25]  = done_DACx_SPI_frame
//  bit[24]  = done_DACx_LNG_reset
//  bit[7:0] = DACx_rd_D[7:0]     

wire [31:0] w_DACX_TI   =                                           w_port_ti_45_1 | ep45trig;
//  bit[0] = trig_DACx_LNG_reset 
//  bit[1] = trig_DACx_SPI_frame 


//// control for pattern generator
// DACZ_DAT_WI @ ep08wire   //$$ rev .... = {DAC1_DAT[15:0], DAC0_DAT[15:0]}
// DACZ_DAT_WO @ ep28wire
// DACZ_DAT_TI @ ep48trig

wire [31:0] w_DACZ_DAT_WI = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_08_1 : ep08wire; 
//
wire [31:0] w_DACZ_DAT_WO;
assign         ep28wire   = w_DACZ_DAT_WO; 
assign w_port_wo_28_1     = w_DACZ_DAT_WO;
//
wire [31:0] w_DACZ_DAT_TI =                                           w_port_ti_48_1 | ep48trig;


// 'DAC0_DAT_INC_PI'    : 0x86, ##$$ new for DACZ CID style // data b16 + inc b16
// 'DAC0_DUR_PI    '    : 0x87, ##$$ new for DACZ CID style // duration b32
// 'DAC1_DAT_INC_PI'    : 0x88, ##$$ new for DACZ CID style // data b16 + inc b16
// 'DAC1_DUR_PI    '    : 0x89, ##$$ new for DACZ CID style // duration b32

wire [31:0] w_DAC0_DAT_INC_PI    = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_86_1 : ep86pipe;
wire        w_DAC0_DAT_INC_PI_WR = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)?      w_wr_86_1 : ep86wr  ;
wire [31:0] w_DAC0_DUR_PI        = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_87_1 : ep87pipe;
wire        w_DAC0_DUR_PI_WR     = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)?      w_wr_87_1 : ep87wr  ;
wire [31:0] w_DAC1_DAT_INC_PI    = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_88_1 : ep88pipe;
wire        w_DAC1_DAT_INC_PI_WR = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)?      w_wr_88_1 : ep88wr  ;
wire [31:0] w_DAC1_DUR_PI        = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_89_1 : ep89pipe;
wire        w_DAC1_DUR_PI_WR     = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)?      w_wr_89_1 : ep89wr  ;


//}


//// EEPROM wires //{
//$$ remove w_sel__H_LAN_for_EEPROM_fifo
wire [31:0] w_MEM_WI      = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_13_1 : ep13wire;                                        
wire [31:0] w_MEM_FDAT_WI = ( w_mcs_ep_wi_en & ~w_SSPI_TEST_mode_en)? w_port_wi_12_1 : ep12wire;                                        
wire [31:0] w_MEM_TI      =                                           w_port_ti_53_1 | ep53trig; 
wire [31:0] w_MEM_TO; 
assign ep73trig           = (~w_mcs_ep_to_en |  w_SSPI_TEST_mode_en)? w_MEM_TO : 32'b0; 
assign w_port_to_73_1     = ( w_mcs_ep_to_en & ~w_SSPI_TEST_mode_en)? w_MEM_TO : 32'b0; 
wire [31:0] w_MEM_PI      = ( w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_93_1 : ep93pipe;
wire [31:0] w_MEM_PO; 
assign         epB3pipe   = w_MEM_PO; 
assign w_port_po_B3_1     = w_MEM_PO;
wire        w_MEM_PI_wr   =                                                w_wr_93_1 | ep93wr;
wire        w_MEM_PO_rd   =                                                w_rd_B3_1 | epB3rd;

//}

//// TEST-FIFO wires //{
// PI 0x8A, PO 0xAA
// review mode :
//  w_mcs_ep_pi_en  w_SSPI_TEST_mode_en   EP switch
//               0                    0   SSPI
//               0                    1   NA
//               1                    0   LAN
//               1                    1   SSPI

wire [31:0] w_TEST_PI    = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? w_port_pi_8A_1 : ep8Apipe;
wire        w_TEST_PI_wr =                                               w_wr_8A_1 | ep8Awr;                  
wire [31:0] w_TEST_PO; 
assign         epAApipe  = w_TEST_PO;
assign w_port_po_AA_1    = w_TEST_PO;
wire        w_TEST_PO_rd =                                               w_rd_AA_1 | epAArd; 
wire        c_TEST_FIFO  = (w_mcs_ep_po_en & ~w_SSPI_TEST_mode_en)?        mcs_clk : base_sspi_clk;

//}



//}



//-------------------------------------------------------//


/* timestamp */ //{
// global time index in debugger based on 10MHz 

//sub_timestamp //{
sub_timestamp sub_timestamp_inst(
	.clk         (sys_clk),
	.reset_n     (reset_n),
	.o_timestamp (w_TIMESTAMP_WO),
	.valid       ()
);
//}

//}


/* TEST COUNTER */ //{

// wires //{
wire [7:0] w_test;
wire [7:0]  count1;
wire        count1eq00;
wire        count1eq80;
wire        reset1;
wire        disable1;
wire [7:0]  count2;
wire        count2eqFF;
wire        reset2;
wire        up2;
wire        down2;
wire        autocount2;
//}

// assign //{

// Counter 1:
assign reset1     = w_TEST_CON_WI[0]; 
assign disable1   = w_TEST_CON_WI[1]; 
assign autocount2 = w_TEST_CON_WI[2]; 
//
assign w_TEST_OUT_WO[15:0] = {count2[7:0], count1[7:0]}; 
assign w_TEST_OUT_WO[31:16] = 16'b0; 
// Counter 2:
assign reset2     = w_TEST_TI[0];
assign up2        = w_TEST_TI[1];
assign down2      = w_TEST_TI[2];
//
assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};

// LED drive //{

//// note: fpga module in S3100-PGU uses high-Z output // 7..0 ... B17,B16,A16,B15,A15,A14,B13,A13
//// note: S3100-CPU-BASE           uses high-Z output // 7..0 ... V19,V18,Y19,Y18,W20,W19,V20,U20

// xem7310_led:
//   1 in --> 0 out // tri_0, out_0
//   0 in --> Z out // tri_1, out_X
function [7:0] xem7310_led;
input [7:0] a;
integer i;
begin
	for(i=0; i<8; i=i+1) begin: u
		//xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
		xem7310_led[i] = (a[i]==1'b1) ? (1'b0) : (1'b1); // inverter
	end
end
endfunction
// 
assign led = xem7310_led(w_test ^ count1);
//}

//}

// test_counter_wrapper //{
test_counter_wrapper  test_counter_wrapper_inst (
	.sys_clk (sys_clk),
	.reset_n (reset_n),
	//
	.o_test    (w_test),
	//
	.o_count1      (count1),
	//
	.o_count1eq00  (count1eq00),
	.o_count1eq80  (count1eq80),
	//
	.reset1        (reset1),
	.disable1      (disable1),
	//
	.o_count2      (count2),
	//
	.o_count2eqFF  (count2eqFF),
	//
	.reset2        (reset2    ),
	.up2           (up2       ),
	.down2         (down2     ),
	.autocount2    (autocount2)
	//             
);
//}

//}


/* XADC */ //{

// wires and end-points //{

wire [31:0] w_XADC_TEMP_WO; 
assign         ep3Awire = w_XADC_TEMP_WO;
assign w_port_wo_3A_1   = w_XADC_TEMP_WO;
//
wire [31:0] w_XADC_VOLT_WO; 
assign         ep3Bwire = w_XADC_VOLT_WO;
assign w_port_wo_3B_1   = w_XADC_VOLT_WO;

// XADC_DRP
wire [31:0] MEASURED_TEMP_MC;
wire [31:0] MEASURED_VCCINT_MV;
wire [31:0] MEASURED_VCCAUX_MV;
wire [31:0] MEASURED_VCCBRAM_MV;
//
wire [7:0] dbg_drp;
//}

// master_drp_ug480 //{
master_drp_ug480 master_drp_ug480_inst(
	.DCLK				(xadc_clk), // input DCLK, // Clock input for DRP
	.RESET				(~reset_n), // input RESET,
	.VP					(i_XADC_VP), // input VP, VN,// Dedicated and Hardwired Analog Input Pair
	.VN					(i_XADC_VN),
	.MEASURED_TEMP		(), // output reg [15:0] MEASURED_TEMP, MEASURED_VCCINT,
	.MEASURED_VCCINT	(),
	.MEASURED_VCCAUX	(), // output reg [15:0] MEASURED_VCCAUX, MEASURED_VCCBRAM,
	.MEASURED_VCCBRAM	(),
	// converted to decimal
	.MEASURED_TEMP_MC		(MEASURED_TEMP_MC), 
	.MEASURED_VCCINT_MV		(MEASURED_VCCINT_MV),
	.MEASURED_VCCAUX_MV		(MEASURED_VCCAUX_MV), 
	.MEASURED_VCCBRAM_MV	(MEASURED_VCCBRAM_MV),
	//
	.ALM_OUT	(), // output wire ALM_OUT,
	.CHANNEL	(), // output wire [4:0] CHANNEL,
	.OT			(), // output wire OT,
	.XADC_EOC	(), // output wire XADC_EOC,
	.XADC_EOS	(), // output wire XADC_EOS
	.debug_out	(dbg_drp)
);
//}

// assign //{
assign w_XADC_TEMP_WO = MEASURED_TEMP_MC;

assign w_XADC_VOLT_WO = MEASURED_VCCINT_MV;

//assign w_XADC_VOLT = 
//	(count2[7:6]==2'b00)? MEASURED_VCCINT_MV :
//	(count2[7:6]==2'b01)? MEASURED_VCCAUX_MV :
//	(count2[7:6]==2'b10)? MEASURED_VCCBRAM_MV :
//		32'b0;

//}

//}


/* TODO: SPIO : MCP23S17 */ //{


//end-points for SPIO //{
//
wire w_trig_SPIO_LNG_reset = w_SPIO_TI[0];//$$ | w_TEST_IO_TI[0]; // test 
wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];//$$ | w_TEST_IO_TI[1]; // test 
wire w_done_SPIO_LNG_reset ;
wire w_done_SPIO_SPI_frame ;
//
wire       w_SPIO_CS_id      = w_SPIO_WI[28]   ;
wire [2:0] w_SPIO_pin_adrs_A = w_SPIO_WI[27:25];
wire       w_SPIO_R_W_bar    = w_SPIO_WI[24]   ;
wire [7:0] w_SPIO_reg_adrs_A = w_SPIO_WI[23:16];
wire [7:0] w_SPIO_wr_DA      = w_SPIO_WI[15: 8];
wire [7:0] w_SPIO_wr_DB      = w_SPIO_WI[ 7: 0];
//
wire [7:0] w_SPIO_rd_DA      ;
wire [7:0] w_SPIO_rd_DB      ;
//
assign w_SPIO_WO[31:26] = 6'b0;
assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
assign w_SPIO_WO[24] = w_done_SPIO_LNG_reset;
assign w_SPIO_WO[23:16] = 8'b0;
assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
//}

// master_spi_mcp23s17 //{
master_spi_mcp23s17  master_spi_mcp23s17_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_SPIO_LNG_reset),
	.o_done_LNG_reset	(w_done_SPIO_LNG_reset), 
	.o_LNG_RSTn			(),
	.i_trig_SPI_frame	(w_trig_SPIO_SPI_frame), 
	.o_done_SPI_frame	(w_done_SPIO_SPI_frame), 
	//
	.o_SPIO0_CS   		(SPIO0_CS  ),
	.o_SPIO1_CS   		(SPIO1_CS  ),
	.o_SPIOx_SCLK 		(SPIOx_SCLK),
	.o_SPIOx_MOSI 		(SPIOx_MOSI),
	.i_SPIOx_MISO 		(SPIOx_MISO),
	//
	.i_CS_id            (w_SPIO_CS_id     ), //       
	.i_pin_adrs_A       (w_SPIO_pin_adrs_A), // [2:0] 
	.i_R_W_bar          (w_SPIO_R_W_bar   ), //       
	.i_reg_adrs_A       (w_SPIO_reg_adrs_A), // [7:0] 
	.i_wr_DA            (w_SPIO_wr_DA     ), // [7:0] 
	.i_wr_DB            (w_SPIO_wr_DB     ), // [7:0] 
	.o_rd_DA            (w_SPIO_rd_DA     ), // [7:0] 
	.o_rd_DB            (w_SPIO_rd_DB     ), // [7:0] 
	//
	.valid				()		
);

// LED test with USER_LED_ST0 net (SP1_GPB3)
//   IODIR frame 0x40_00_FF_F7 : w_SPIO_WI = 32'h10_00_FF_F7
//   GPIO  frame 0x40_12_00_08 : w_SPIO_WI = 32'h10_12_00_08
//   GPIO  frame 0x40_12_00_00 : w_SPIO_WI = 32'h10_12_00_00

//}

//}


/* TODO: CLKD : AD9516-1 */ //{

// CLKD ports //{

assign clk_dac_clk_in = CLKD_COUT; // for DAC/CLK 400MHz pll

//}

//end-points for CLKD //{
//
wire w_trig_CLKD_LNG_reset = w_CLKD_TI[0];//$$ | w_TEST_IO_TI[2]; // test 
wire w_trig_CLKD_SPI_frame = w_CLKD_TI[1];//$$ | w_TEST_IO_TI[3]; // test 
wire w_done_CLKD_LNG_reset ;
wire w_done_CLKD_SPI_frame ;
//
wire        w_CLKD_R_W_bar     = w_CLKD_WI[31];
wire  [1:0] w_CLKD_byte_mode_W = w_CLKD_WI[30:29];
wire  [9:0] w_CLKD_reg_adrs_A  = w_CLKD_WI[25:16];
wire  [7:0] w_CLKD_wr_D        = w_CLKD_WI[7:0];
//
wire  [7:0] w_CLKD_rd_D       ;
//
assign w_CLKD_WO[31]    = CLKD_LD   ;
assign w_CLKD_WO[30]    = CLKD_STAT ;
assign w_CLKD_WO[29]    = CLKD_REFM ;
//assign w_CLKD_WO[28]    = CLKD_SDO  ;
assign w_CLKD_WO[28]    = CLKD_SDIO_rd  ;
assign w_CLKD_WO[27:26] = 2'b0;
assign w_CLKD_WO[25]    = w_done_CLKD_SPI_frame;
assign w_CLKD_WO[24]    = w_done_CLKD_LNG_reset;
assign w_CLKD_WO[23:8]  = 16'b0;
assign w_CLKD_WO[7:0]   = w_CLKD_rd_D;
//}

// master_spi_ad9516 //{
master_spi_ad9516#(
	.TIME_RESET_WAIT_MS (5) // for 5ms reset 
)   master_spi_ad9516_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_CLKD_LNG_reset),
	.o_done_LNG_reset	(w_done_CLKD_LNG_reset), 
	.o_LNG_RSTn			(CLKD_RST_B),
	.i_trig_SPI_frame	(w_trig_CLKD_SPI_frame), 
	.o_done_SPI_frame	(w_done_CLKD_SPI_frame), 
	//
	.o_CLK_CS_B   		(CLKD_CS_B),
	.o_CLK_SCLK 		(CLKD_SCLK),
	.o_CLK_SDIO 		(CLKD_SDIO),
	//.i_CLK_SDO 			(CLKD_SDIO_rd),
	.i_CLK_SDO 			(CLKD_SDO),
	//
	.i_R_W_bar          (w_CLKD_R_W_bar    ), //     
	.i_byte_mode_W      (w_CLKD_byte_mode_W), // [1:0]
	.i_reg_adrs_A       (w_CLKD_reg_adrs_A ), // [9:0] 
	.i_wr_D             (w_CLKD_wr_D       ), // [7:0] 
	.o_rd_D             (w_CLKD_rd_D       ), // [7:0] 
	//
	.valid				()		
);
//}

//}


/* TODO: TRIG */ //{
// control external trig in and out 

// assign port //{
assign TRIG_OUT_P = w_trig_p_oddr_out;
assign TRIG_OUT_N = w_trig_n_oddr_out;
//}

// assign endpoint //{
wire [31:0] w_wire_in_trig_data = w_TRIG_DAT_WI;
wire [31:0] w_trig_in_trig_data = w_TRIG_DAT_TI;
wire [31:0] w_wireout_trig_data ;
assign w_TRIG_DAT_WO = w_wireout_trig_data;
//}

// call control module : sub_trig_data
sub_trig_data  sub_trig_data__inst  (
	.clk                 (sys_clk),
	.reset_n             (reset_n),
	//              
	// trig data interface 
	.i_wire_in_trig_data (w_wire_in_trig_data), // [31:0] // data-in
	.i_trig_in_trig_data (w_trig_in_trig_data), // [31:0] // control trig
	.o_wireout_trig_data (w_wireout_trig_data)  // [31:0] // data-out
);




//}


/* TODO: DAC : AD9783 */ //{

// ports //{
assign        DAC0_DCI = w_dac0_dci_oddr_out; // dac0_dco_clk_out1_400M; // 1'b0;
assign        DAC1_DCI = w_dac1_dci_oddr_out; // dac1_dco_clk_out1_400M; // 1'b0;

//assign dac0_dco_clk_in = DAC0_DCO; // for DAC1 400MHz pll
//assign dac1_dco_clk_in = DAC1_DCO; // for DAC1 400MHz pll

//}

// end-points for DACX //{
//
wire w_trig_DACx_LNG_reset = w_DACX_TI[0];
wire w_trig_DACx_SPI_frame = w_DACX_TI[1];
wire w_done_DACx_LNG_reset;
wire w_done_DACx_SPI_frame;
//
assign dac1_dco_clk_rst = w_DACX_WI[30];
assign dac0_dco_clk_rst = w_DACX_WI[29];
assign  clk_dac_clk_rst = w_DACX_WI[28];
//
assign dac1_clk_dis     = w_DACX_WI[27];
assign dac0_clk_dis     = w_DACX_WI[26];
//
wire       w_DACx_CS_id       = w_DACX_WI[24];
wire       w_DACx_R_W_bar     = w_DACX_WI[23];
wire [1:0] w_DACx_byte_mode_N = w_DACX_WI[22:21];
wire [4:0] w_DACx_reg_adrs_A  = w_DACX_WI[20:16];
wire [7:0] w_DACx_wr_D        = w_DACX_WI[7:0];
wire [7:0] w_DACx_rd_D      ;
//
//$$assign w_DACX_WO[31:26] = 6'b0; // assigned from pattern gen
assign w_DACX_WO[25]    = w_done_DACx_SPI_frame;
assign w_DACX_WO[24]    = w_done_DACx_LNG_reset;
assign w_DACX_WO[23:16] = 8'b0;
assign w_DACX_WO[15:8]  = 8'b0;
assign w_DACX_WO[ 7:0]  = w_DACx_rd_D;
//}

// master_spi_ad9783 //{
master_spi_ad9783  master_spi_ad9783_inst (
	.clk				(sys_clk), // 
	.reset_n			(reset_n),
	//
	.i_trig_LNG_reset	(w_trig_DACx_LNG_reset),
	.o_done_LNG_reset	(w_done_DACx_LNG_reset), 
	.o_LNG_RSTn			(DACx_RST_B),
	.i_trig_SPI_frame	(w_trig_DACx_SPI_frame), 
	.o_done_SPI_frame	(w_done_DACx_SPI_frame), 
	//
	.o_DAC0_CS   		(DAC0_CS  ),
	.o_DAC1_CS   		(DAC1_CS  ),
	.o_DACx_SCLK 		(DACx_SCLK),
	.o_DACx_SDIO 		(DACx_SDIO),
	.i_DACx_SDO  		(DACx_SDO),
	//
	.i_CS_id            (w_DACx_CS_id      ), //       
	.i_R_W_bar          (w_DACx_R_W_bar    ), //       
	.i_byte_mode_N      (w_DACx_byte_mode_N), // [1:0] 
	.i_reg_adrs_A       (w_DACx_reg_adrs_A ), // [4:0] 
	.i_wr_D             (w_DACx_wr_D       ), // [7:0] 
	.o_rd_D             (w_DACx_rd_D       ), // [7:0] 
	//
	.valid				()		
);
//}

//}


/* TODO: DAC pattern generator */ //{

// end-points for DACx_DAT_xx and DACX_WO //{

// end-points for FIFO control

// for DACZ
wire [31:0] w_trig_dacz_ctrl     = w_DACZ_DAT_TI;
wire [31:0] w_wire_in__dacz_data = w_DACZ_DAT_WI;
wire [31:0] w_wire_out_dacz_data;
assign w_DACZ_DAT_WO = w_wire_out_dacz_data;


// note clock mux
// BUFGMUX in https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf

wire c_fifo_wr;

// wire w_DAC0_DAT_PI_CK = c_fifo_wr; // remove
// wire w_DAC1_DAT_PI_CK = c_fifo_wr; // remove

wire w_DAC0_DAT_INC_PI_CK = c_fifo_wr;
wire w_DAC0_DUR_PI_CK     = c_fifo_wr;
wire w_DAC1_DAT_INC_PI_CK = c_fifo_wr;
wire w_DAC1_DUR_PI_CK     = c_fifo_wr;

//$$  BUFGMUX bufgmux_c_fifo_read_inst (
//$$  	.O(c_fifo_wr), 
//$$  	.I0(epClk), 
//$$  	.I1(mcs_clk), //$$ mcs_clk vs clk3_out1_72M
//$$  	.S(w_mcs_ep_pi_en) 
//$$  ); 

//assign c_fifo_wr = (w_mcs_ep_pi_en == 0)? epClk : mcs_clk ; //$$ remove BUFGMUX
assign c_fifo_wr = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? mcs_clk : epClk; //$$ remove BUFGMUX

// for DACZ
wire         w_dac0_fifo_datinc_wr_ck  = w_DAC0_DAT_INC_PI_CK; //    
wire         w_dac0_fifo_datinc_wr_en  = w_DAC0_DAT_INC_PI_WR; // 
wire [31:0]  w_dac0_fifo_datinc_din    = w_DAC0_DAT_INC_PI; // 
wire         w_dac0_fifo_dur____wr_ck  = w_DAC0_DUR_PI_CK    ; //    
wire         w_dac0_fifo_dur____wr_en  = w_DAC0_DUR_PI_WR    ; // 
wire [31:0]  w_dac0_fifo_dur____din    = w_DAC0_DUR_PI; // 
wire         w_dac1_fifo_datinc_wr_ck  = w_DAC1_DAT_INC_PI_CK; //    
wire         w_dac1_fifo_datinc_wr_en  = w_DAC1_DAT_INC_PI_WR; // 
wire [31:0]  w_dac1_fifo_datinc_din    = w_DAC1_DAT_INC_PI; // 
wire         w_dac1_fifo_dur____wr_ck  = w_DAC1_DUR_PI_CK    ; //    
wire         w_dac1_fifo_dur____wr_en  = w_DAC1_DUR_PI_WR    ; // 
wire [31:0]  w_dac1_fifo_dur____din    = w_DAC1_DUR_PI       ; // 



// not used
assign w_DACX_WO[31] = 1'b0; // w_fifo_dac1_empty; 
assign w_DACX_WO[30] = 1'b0; // w_fifo_dac0_empty; 
assign w_DACX_WO[29] = 1'b0; // w_fifo_dac1_full ;
assign w_DACX_WO[28] = 1'b0; // w_fifo_dac0_full ; 
assign w_DACX_WO[27] = 1'b0; // w_fifo_dac1_wrack; 
assign w_DACX_WO[26] = 1'b0; // w_fifo_dac0_wrack;

//}

// wires //{

//wire dacx_ref_clk     = clk_dac_out1_400M;
//wire dacx_ref_reset_n = clk_dac_locked;

//wire dac0_reset_n = dac0_dco_clk_locked;
//wire dac1_reset_n = dac1_dco_clk_locked;
//
wire [15:0] w_dac0_data_pin;
wire [15:0] w_dac1_data_pin;
assign DAC0_DAT = w_dac0_data_pin;
assign DAC1_DAT = w_dac1_data_pin;

//wire       w_dac0_active_dco;
//wire       w_dac1_active_dco;
//wire       w_dac0_active_clk;
//wire       w_dac1_active_clk;

//}

// dac_pattern_gen_wrapper --> dac_pattern_gen_wrapper__dsp //{

dac_pattern_gen_wrapper__dsp  dac_pattern_gen_wrapper__inst (

	// clock / reset
	.clk                (sys_clk), // 
	.reset_n            (reset_n),
	
	// DAC clock / reset
	.i_clk_dac0_dco     (dac0_clk    ), // clk_400M vs clk_200M
	.i_rstn_dac0_dco    (dac0_reset_n), //
	.i_clk_dac1_dco     (dac1_clk    ), // clk_400M vs clk_200M
	.i_rstn_dac1_dco    (dac1_reset_n), //
	
	// DACZ control port // new control 
	.i_trig_dacz_ctrl   (w_trig_dacz_ctrl    ), // [31:0]
	.i_wire_dacz_data   (w_wire_in__dacz_data), // [31:0]
	.o_wire_dacz_data   (w_wire_out_dacz_data), // [31:0]
	
	// DACZ fifo port // new control // from MCS or USB
	.i_dac0_fifo_datinc_wr_ck    (w_dac0_fifo_datinc_wr_ck ), //       
	.i_dac0_fifo_datinc_wr_en    (w_dac0_fifo_datinc_wr_en ), //       
	.i_dac0_fifo_datinc_din      (w_dac0_fifo_datinc_din   ), // [31:0]
	.i_dac0_fifo_dur____wr_ck    (w_dac0_fifo_dur____wr_ck ), //       
	.i_dac0_fifo_dur____wr_en    (w_dac0_fifo_dur____wr_en ), //       
	.i_dac0_fifo_dur____din      (w_dac0_fifo_dur____din   ), // [31:0]
	.i_dac1_fifo_datinc_wr_ck    (w_dac1_fifo_datinc_wr_ck ), //       
	.i_dac1_fifo_datinc_wr_en    (w_dac1_fifo_datinc_wr_en ), //       
	.i_dac1_fifo_datinc_din      (w_dac1_fifo_datinc_din   ), // [31:0]
	.i_dac1_fifo_dur____wr_ck    (w_dac1_fifo_dur____wr_ck ), //       
	.i_dac1_fifo_dur____wr_en    (w_dac1_fifo_dur____wr_en ), //       
	.i_dac1_fifo_dur____din      (w_dac1_fifo_dur____din   ), // [31:0]
	//
	.i_dac0_fifo_dd_rd_en_test   (1'b0), //
	.i_dac1_fifo_dd_rd_en_test   (1'b0), //
	
	// DAC data output port 
	.o_dac0_data_pin    (w_dac0_data_pin), // [15:0]
	.o_dac1_data_pin    (w_dac1_data_pin), // [15:0]

	// DAC activity flag
	.o_dac0_active_dco  (), // unused
	.o_dac1_active_dco  (), // unused
	.o_dac0_active_clk  (), // alternatively read from o_wire_dacx_data
	.o_dac1_active_clk  (), // alternatively read from o_wire_dacx_data
	
	//  // fifo data and control   // remove
	//  .i_dac0_fifo_wr_clk     (w_dac0_fifo_wr_clk), //
	//  .i_dac0_fifo_wr_en      (w_dac0_fifo_wr_en ), //
	//  .i_dac0_fifo_din        (w_dac0_fifo_din   ), // [31:0]
	//  .i_dac1_fifo_wr_clk     (w_dac1_fifo_wr_clk), //
	//  .i_dac1_fifo_wr_en      (w_dac1_fifo_wr_en ), //
	//  .i_dac1_fifo_din        (w_dac1_fifo_din   ), // [31:0]
	//  //
	//  .i_dac0_fifo_rd_en_test (1'b0), // test read out
	//  .i_dac1_fifo_rd_en_test (1'b0), // test read out
	//  
	//  // FIFO flag 
	//  .o_fifo_dac0_full   (w_fifo_dac0_full ),
	//  .o_fifo_dac0_wrack  (w_fifo_dac0_wrack),
	//  .o_fifo_dac0_empty  (w_fifo_dac0_empty),
	//  .o_fifo_dac0_valid  (w_fifo_dac0_valid),
	//  .o_fifo_dac1_full   (w_fifo_dac1_full ),
	//  .o_fifo_dac1_wrack  (w_fifo_dac1_wrack),
	//  .o_fifo_dac1_empty  (w_fifo_dac1_empty),
	//  .o_fifo_dac1_valid  (w_fifo_dac1_valid),
	
	// flag
	.valid              ()

);

//}


//}


/* S_IO */ //{

//// assign 
//assign w_TEST_MON_WO[31] = S_IO_2; //$$ removed in S3000-PGU
//assign w_TEST_MON_WO[30] = S_IO_1; //$$ removed in S3000-PGU
//assign w_TEST_MON_WO[29] = S_IO_0; //


//}


/* ADC */ //{

//$$ not activated

//}


///TODO: //-------------------------------------------------------//


/* TODO: EEPROM */ //{
// support 11AA160T-I/TT U59 // same in CMU
// io signal, open-drain
// note that 10K ohm pull up is located on board.
// net in sch: S_IO_0
// pin: io_B34_L5N


// fifo read clock //{
wire c_eeprom_fifo_clk; // clock mux between lan and usb/slave-spi end-points
//
//  BUFGMUX bufgmux_c_eeprom_fifo_clk_inst (
//  	.O(c_eeprom_fifo_clk), 
//  	//.I0(base_sspi_clk), // base_sspi_clk for slave_spi_mth_brd // 104MHz
//  	.I0(epClk        ), // USB  // 100.8MHz
//  	//.I1(w_ck_pipe    ), // LAN from lan_endpoint_wrapper_inst      // 72MHz
//  	.I1(mcs_eeprom_fifo_clk), 
//  	.S(w_sel__H_LAN_for_EEPROM_fifo) 
//  );

// note BUFG issue : solved with duplicated clock  mcs_eeprom_fifo_clk
//   without BUFGMUX : pre BUFG 35, post BUGF 26
//   with    BUFGMUX : pre BUFG 37, post BUGF 28 // duplicate clock

// try remove bufg at pll out
//assign c_eeprom_fifo_clk = w_ck_pipe; // LAN test 

//$$ note in S3100-GNDU
//assign c_eeprom_fifo_clk = (w_sel__H_LAN_for_EEPROM_fifo == 0)? okClk : mcs_eeprom_fifo_clk ; //$$ remove BUFGMUX

//$$ note in S3100-PGU
//assign c_eeprom_fifo_clk = (~w_mcs_ep_pi_en)? base_sspi_clk : mcs_eeprom_fifo_clk ; //$$ remove BUFGMUX
//assign c_eeprom_fifo_clk = (~w_mcs_ep_pi_en)? epClk : mcs_eeprom_fifo_clk ; //$$ remove BUFGMUX
assign c_eeprom_fifo_clk = (w_mcs_ep_pi_en & ~w_SSPI_TEST_mode_en)? mcs_eeprom_fifo_clk : epClk; //$$ remove BUFGMUX

//}


// module //{

wire w_MEM_rst;
wire w_MEM_fifo_rst;
wire w_MEM_valid;
//
wire w_trig_frame   ;
wire w_done_frame   ;
wire w_done_frame_TO;
//
wire [7:0] w_frame_data_CMD    ;
wire [7:0] w_frame_data_ADH    ;
wire [7:0] w_frame_data_ADL    ;
wire [7:0] w_frame_data_STA_in ;
wire [7:0] w_frame_data_STA_out;
//
wire [11:0] w_num_bytes_DAT    ;
wire        w_con_disable_SBP;
//
wire [7:0] w_frame_data_DAT_wr   ;
wire [7:0] w_frame_data_DAT_rd   ;
wire       w_frame_data_DAT_wr_en;
wire       w_frame_data_DAT_rd_en;
//
wire w_SCIO_DI;
wire w_SCIO_DO;
wire w_SCIO_OE;

//
control_eeprom__11AA160T  control_eeprom__11AA160T_inst (
	//
	.clk     (sys_clk                ), //	input  wire // 10MHz
	.reset_n (reset_n & (~w_MEM_rst) & (~w_HW_reset)), //	input  wire // TI
	
	// controls //{
	.i_trig_frame     (w_trig_frame   ), //	input  wire                    // TI
	.o_done_frame     (w_done_frame   ), //	output wire                    // TO
	.o_done_frame_TO  (w_done_frame_TO), //	output wire  // trig out @ clk // TO
	//	
	.i_en_SBP         (~w_con_disable_SBP  ), //	input  wire  // enable SBP (stand-by pulse) // WI
	//
	.i_frame_data_SHD (8'h55           ), //	input  wire [7:0]  // fixed
	.i_frame_data_DVA (8'hA0           ), //	input  wire [7:0]  // fixed
	.i_frame_data_CMD (w_frame_data_CMD    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADH (w_frame_data_ADH    ), //	input  wire [7:0]  // WI
	.i_frame_data_ADL (w_frame_data_ADL    ), //	input  wire [7:0]  // WI
	.i_frame_data_STA (w_frame_data_STA_in ), //	input  wire [7:0]  // WI
	.o_frame_data_STA (w_frame_data_STA_out), //	output wire [7:0]  // TO
	//	
	.i_num_bytes_DAT  (w_num_bytes_DAT     ), //	input  wire [11:0] // WI
	//}
	
	// FIFO/PIPE interface //{
	.i_reset_fifo             (w_MEM_fifo_rst), //	input  wire    // TI
	//
	.i_frame_data_DAT         (w_frame_data_DAT_wr   ), //	input  wire [7:0] // PI
	.o_frame_data_DAT         (w_frame_data_DAT_rd   ), //	output wire [7:0] // PO
	//
	.i_frame_data_DAT_wr_en   (w_frame_data_DAT_wr_en), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_wr_clk  (c_eeprom_fifo_clk     ), // input wire // control for i_frame_data_DAT
	.i_frame_data_DAT_rd_en   (w_frame_data_DAT_rd_en), // input wire // control for o_frame_data_DAT	
	.i_frame_data_DAT_rd_clk  (c_eeprom_fifo_clk     ), // input wire // control for o_frame_data_DAT	
	//}
	
	// IO ports //{
	.i_SCIO_DI        (w_SCIO_DI), // input  wire 
	.o_SCIO_DO        (w_SCIO_DO), // output wire 
	.o_SCIO_OE        (w_SCIO_OE), // output wire 
	//}

	.valid            (w_MEM_valid)//	output wire 
);


//}

// assignment //{

assign w_num_bytes_DAT               = w_MEM_WI[11:0]; // 12-bit 
assign w_con_disable_SBP             = w_MEM_WI[15]  ; // 1-bit

assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit

assign w_MEM_rst      = w_MEM_TI[0];
assign w_MEM_fifo_rst = w_MEM_TI[1];
assign w_trig_frame   = w_MEM_TI[2];

assign w_MEM_TO[0]     = w_MEM_valid    ;
assign w_MEM_TO[1]     = w_done_frame   ;
assign w_MEM_TO[2]     = w_done_frame_TO;
assign w_MEM_TO[ 7: 3] =  5'b0;
assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
assign w_MEM_TO[31:16] = 16'b0;

assign w_frame_data_DAT_wr    = w_MEM_PI[7:0]; // 8-bit
assign w_frame_data_DAT_wr_en = w_MEM_PI_wr;

assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
assign w_MEM_PO[31:8]         = {24{w_frame_data_DAT_rd[7]}}; // rev signed expansion for compatibility
assign w_frame_data_DAT_rd_en = w_MEM_PO_rd;


//// port mux
//  assign w_SCIO_DI   = ( w_sel__H_EEPROM_on_TP)?   TP_in[2] : MEM_SIO_in ; // switching
//  //                     
//  assign TP_out[2]   = ( w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // test TP 
//  assign TP_tri[2]   = ( w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // test TP 
//  //
//  assign TP_out[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b1 : 1'b0 ; // for test power (3.3V) on signal line
//  assign TP_out[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b0 ; // for test power (GND)  on signal line
//  assign TP_tri[0]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  assign TP_tri[1]   = ( w_sel__H_EEPROM_on_TP)? 1'b0 : 1'b1 ; // for test power on signal line
//  //                     
//  assign MEM_SIO_out = (~w_sel__H_EEPROM_on_TP)?  w_SCIO_DO : 1'b0 ; // dedicated port
//  assign MEM_SIO_tri = (~w_sel__H_EEPROM_on_TP)? ~w_SCIO_OE : 1'b1 ; // dedicated port


// no TP yet
assign w_SCIO_DI   = MEM_SIO_in ; 
assign MEM_SIO_out =  w_SCIO_DO ; // dedicated port
assign MEM_SIO_tri = ~w_SCIO_OE ; // dedicated port

//}


//}


/* TODO: TEST FIFO */ //{

// test fifo data 
//
// fifo_generator_4 : test
// 32 bits
// 4096 depth = 2^12
// 2^12 * 4 byte = 16KB

//$$ read mode : standard vs first_word_fall_through // back to standard
//$$ speed : 72 --> 104 MHz
		
//$$ clock switch : mcs_clk vs base_sspi_clk ... c_TEST_FIFO

fifo_generator_4 TEST_fifo_inst (
  //.rst       (~reset_n | ~w_LAN_RSTn | w_FIFO_reset), // input wire rst
  .rst       (~reset_n), // input wire rst
  .wr_clk    (c_TEST_FIFO   ), // input wire wr_clk
  .wr_en     (w_TEST_PI_wr  ), // input wire wr_en
  .din       (w_TEST_PI     ), // input wire [31 : 0] din
  .rd_clk    (c_TEST_FIFO   ), // input wire rd_clk
  .rd_en     (w_TEST_PO_rd  ), // input wire rd_en
  .dout      (w_TEST_PO     ), // output wire [31 : 0] dout
  .full      (),  // output wire full
  .wr_ack    (),  // output wire wr_ack
  .empty     (),  // output wire empty
  .valid     ()   // output wire valid
);

//}



/* TODO: TEMP SENSOR */
// to come

/* TODO: TP for TXEM7310 */
// to come

///TODO: //-------------------------------------------------------//

/* TODO: Master_SPI emulation for Slave_SPI  or  MSPI */ //{


// module //{

//// Master SPI endpoints
//
// MSPI_TI : ep42trig
//   bit[0] = reset_trig 
//   bit[1] = init_trig
//   bit[2] = frame_trig
//
// MSPI_TO : ep62trig
//   bit[0] = reset_done
//   bit[1] = init_done
//   bit[2] = frame_done
//
// MSPI_CON_WI : ep17wire
//  bit[31:26] = data_C // control[5:0]
//  bit[25:16] = data_A // address[9:0]
//  bit[15: 0] = data_D // MOSI data[15:0]
//
// MSPI_EN_CS_WI : ep16wire
//  bit[0 ] = enable SPI_nCS0  
//  bit[1 ] = enable SPI_nCS1  
//  bit[2 ] = enable SPI_nCS2  
//  bit[3 ] = enable SPI_nCS3  
//  bit[4 ] = enable SPI_nCS4  
//  bit[5 ] = enable SPI_nCS5  
//  bit[6 ] = enable SPI_nCS6  
//  bit[7 ] = enable SPI_nCS7  
//  bit[8 ] = enable SPI_nCS8  
//  bit[9 ] = enable SPI_nCS9  
//  bit[10] = enable SPI_nCS10 
//  bit[11] = enable SPI_nCS11 
//  bit[12] = enable SPI_nCS12 
//
// MSPI_FLAG_WO : ep24wire --> ep34wire --> ep24wire
//  bit[23]   = TEST_mode_en
//  bit[15:0] = data_B // MISO data[15:0]

wire w_SSPI_TEST_trig_reset = w_MSPI_TI[0];
assign w_MSPI_TO[0]    = w_SSPI_TEST_trig_reset;
//
wire  w_SSPI_TEST_trig_init = w_MSPI_TI[1];
wire  w_SSPI_TEST_done_init ;
//
assign w_SSPI_TEST_mode_en = w_SSPI_TEST_done_init;
assign w_MSPI_TO[1]        = w_SSPI_TEST_done_init;
//
wire  w_SSPI_TEST_trig_frame = w_MSPI_TI[2];
wire  w_SSPI_TEST_done_frame;
assign w_MSPI_TO[2]   = w_SSPI_TEST_done_frame;
//
assign w_MSPI_TO[31:3] = 29'b0;

//
wire  [ 5:0] w_SSPI_frame_data_C = w_MSPI_CON_WI[31:26]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [ 9:0] w_SSPI_frame_data_A = w_MSPI_CON_WI[25:16]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
wire  [15:0] w_SSPI_frame_data_D = w_MSPI_CON_WI[15: 0]; // w_SSPI_TEST_WI --> w_MSPI_CON_WI
//
wire  [15:0] w_SSPI_frame_data_B;
wire  [15:0] w_SSPI_frame_data_E;
//
assign w_MSPI_FLAG_WO[31:16] = w_SSPI_frame_data_E[15:0];
assign w_MSPI_FLAG_WO[15: 0] = w_SSPI_frame_data_B[15:0]; //$$ w_SSPI_TEST_WO --> w_MSPI_FLAG_WO

wire  w_SSPI_TEST_SS_B   ;
wire  w_SSPI_TEST_MCLK   ;
wire  w_SSPI_TEST_SCLK   ;
wire  w_SSPI_TEST_MOSI   ;
wire  w_SSPI_TEST_MISO   ;
wire  w_SSPI_TEST_MISO_EN;


//  //$$ S3100: mapping SSPI_TEST to M0_SPI
//  assign  FPGA_M0_SPI_TX_EN   = w_SSPI_TEST_mode_en ;
//  //
//  assign  FPGA_M0_SPI_nCS0_   = (w_MSPI_EN_CS_WI[0 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS1_   = (w_MSPI_EN_CS_WI[1 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS2_   = (w_MSPI_EN_CS_WI[2 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS3_   = (w_MSPI_EN_CS_WI[3 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS4_   = (w_MSPI_EN_CS_WI[4 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS5_   = (w_MSPI_EN_CS_WI[5 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS6_   = (w_MSPI_EN_CS_WI[6 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS7_   = (w_MSPI_EN_CS_WI[7 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS8_   = (w_MSPI_EN_CS_WI[8 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS9_   = (w_MSPI_EN_CS_WI[9 ])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS10   = (w_MSPI_EN_CS_WI[10])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS11   = (w_MSPI_EN_CS_WI[11])? w_SSPI_TEST_SS_B : 1'b1 ;
//  assign  FPGA_M0_SPI_nCS12   = (w_MSPI_EN_CS_WI[12])? w_SSPI_TEST_SS_B : 1'b1 ;
//  //
//  assign  M0_SPI_TX_CLK       = w_SSPI_TEST_MCLK    ;
//  assign  M0_SPI_MOSI         = w_SSPI_TEST_MOSI    ;
//  //
assign  w_SSPI_TEST_MISO_EN = w_SSPI_TEST_mode_en ; 
//  //$$assign  w_SSPI_TEST_SCLK    = M0_SPI_RX_CLK       ; //$$ must come from SSPI in test.
//  //$$assign  w_SSPI_TEST_MISO    = M0_SPI_MISO         ; //$$ must come from SSPI in test.


master_spi_mth_brd  master_spi_mth_brd__inst(
	.clk     (base_sspi_clk), // 104MHz
	.reset_n (reset_n & (~w_SSPI_TEST_trig_reset)),
	
	// control 
	.i_trig_init    (w_SSPI_TEST_trig_init ), // 
	.o_done_init    (w_SSPI_TEST_done_init ), // to be used for monitoring test mode 
	.i_trig_frame   (w_SSPI_TEST_trig_frame), // 
	.o_done_frame   (w_SSPI_TEST_done_frame), // 

	// frame data 
	.i_frame_data_C (w_SSPI_frame_data_C), // [ 5:0] // control  data on MOSI
	.i_frame_data_A (w_SSPI_frame_data_A), // [ 9:0] // address  data on MOSI
	.i_frame_data_D (w_SSPI_frame_data_D), // [15:0] // register data on MOSI
	//
	.o_frame_data_B (w_SSPI_frame_data_B), // [15:0] // readback data on MISO, low  16 bits
	.o_frame_data_E (w_SSPI_frame_data_E), // [15:0] // readback data on MISO, high 16 bits
	
	// IO 
	.o_SS_B    (w_SSPI_TEST_SS_B   ),
	.o_MCLK    (w_SSPI_TEST_MCLK   ), // sclk master out 
	.i_SCLK    (w_SSPI_TEST_SCLK   ), // sclk slave in
	.o_MOSI    (w_SSPI_TEST_MOSI   ),
	.i_MISO    (w_SSPI_TEST_MISO   ),
	.i_MISO_EN (w_SSPI_TEST_MISO_EN),
	
	.valid  ()
); 

//}

//}


///TODO: //-------------------------------------------------------//

/* TODO: Slave_SPI from Mother board  or  SSPI */ //{


// modules //{

// wire for slave spi module
(* keep = "true" *) wire w_SSPI_CS_B    ; // i
(* keep = "true" *) wire w_SSPI_CLK     ; // i
(* keep = "true" *) wire w_SSPI_MOSI    ; // i
(* keep = "true" *) wire w_SSPI_MISO    ; // o
(* keep = "true" *) wire w_SSPI_MISO_EN ; // o

wire [15:0] w_SSPI_cnt_sspi_cs; // o

//$$ pad assignment for S3100-PGU
//wire  M2_SPI_CS_BUF      ; // i // 0 for SPI frame active 
//wire  M2_SPI_MOSI        ; // i // data in from master
//wire  M2_SPI_TX_CLK      ; // i // clock in for MOSI
//wire  M2_SPI_MISO        ;  wire  M2_SPI_MISO_B   = ~M2_SPI_MISO   ; // o // data out  to master // inverted due to artwork
//wire  M2_SPI_RX_CLK      ;  wire  M2_SPI_RX_CLK_B = ~M2_SPI_RX_CLK ; // o // clock out for MISO  // inverted due to artwork
//wire  M2_SPI_RX_EN_SLAVE ; // o // 0 for TX_CLK/MOSI active
//wire  M2_SPI_TX_EN_SLAVE ; // o // 1 for RX_CLK/MISO active

//$$ mux for S3100-PGU test
assign  w_SSPI_CS_B        = (w_SSPI_TEST_mode_en)? w_SSPI_TEST_SS_B : M2_SPI_CS_BUF ;
assign  w_SSPI_CLK         = (w_SSPI_TEST_mode_en)? w_SSPI_TEST_MCLK : M2_SPI_TX_CLK ;
assign  w_SSPI_MOSI        = (w_SSPI_TEST_mode_en)? w_SSPI_TEST_MOSI : M2_SPI_MOSI   ;
//
assign  w_SSPI_TEST_SCLK   = (w_SSPI_TEST_mode_en)? w_SSPI_CLK    : 1'b0 ; //$$ must come from SSPI in test.
assign  w_SSPI_TEST_MISO   = (w_SSPI_TEST_mode_en)? w_SSPI_MISO   : 1'b0 ; //$$ must come from SSPI in test.
//
assign  M2_SPI_RX_CLK      = (w_SSPI_TEST_mode_en)? 1'b0 : w_SSPI_CLK  ; //$$ to revise RCLK
assign  M2_SPI_MISO        = (w_SSPI_TEST_mode_en)? 1'b0 : w_SSPI_MISO    ;
assign  M2_SPI_TX_EN_SLAVE = (w_SSPI_TEST_mode_en)? 1'b0 : (~M2_SPI_CS_BUF) ; // MISO active // note: 1 for tx enable 
assign  M2_SPI_RX_EN_SLAVE = 1'b0; // MOSI active // note: 0 for rx enable // must be 0 all the time.



//// wires for SSPI endpoints //{


//// slave spi address port:

// wi
wire [31:0] w_M2_port_wi_sadrs_h008; assign ep02wire = w_M2_port_wi_sadrs_h008;
wire [31:0] w_M2_port_wi_sadrs_h014; assign ep05wire = w_M2_port_wi_sadrs_h014;
wire [31:0] w_M2_port_wi_sadrs_h018; assign ep06wire = w_M2_port_wi_sadrs_h018;
wire [31:0] w_M2_port_wi_sadrs_h01C; assign ep07wire = w_M2_port_wi_sadrs_h01C;
wire [31:0] w_M2_port_wi_sadrs_h020; assign ep08wire = w_M2_port_wi_sadrs_h020;
wire [31:0] w_M2_port_wi_sadrs_h024; assign ep09wire = w_M2_port_wi_sadrs_h024;
wire [31:0] w_M2_port_wi_sadrs_h048; assign ep12wire = w_M2_port_wi_sadrs_h048;
wire [31:0] w_M2_port_wi_sadrs_h04C; assign ep13wire = w_M2_port_wi_sadrs_h04C;

// wo
wire [31:0] w_M2_port_wo_sadrs_h080 = ep20wire; // w_F_IMAGE_ID_WO; // F_IMAGE_ID_WO  	0x080	wo20
wire [31:0] w_M2_port_wo_sadrs_h088 = ep22wire; // w_TIMESTAMP_WO ; 
wire [31:0] w_M2_port_wo_sadrs_h08C = ep23wire; // w_TEST_MON_WO  ; 
wire [31:0] w_M2_port_wo_sadrs_h094 = ep25wire; // DACX_WO
wire [31:0] w_M2_port_wo_sadrs_h098 = ep26wire; // CLKD_WO
wire [31:0] w_M2_port_wo_sadrs_h09C = ep27wire; // SPIO_WO
wire [31:0] w_M2_port_wo_sadrs_h0A0 = ep28wire; // DACZ_DAT_WO
wire [31:0] w_M2_port_wo_sadrs_h0A4 = ep29wire; // TRIG_DAT_WO
wire [31:0] w_M2_port_wo_sadrs_h0C8 = ep32wire; // w_SSPI_FLAG_WO ;
wire [31:0] w_M2_port_wo_sadrs_h0E8 = ep3Awire; // w_XADC_TEMP_WO ; // XADC_TEMP_WO		0x0E8	wo3A
wire [31:0] w_M2_port_wo_sadrs_h0EC = ep3Bwire; // w_XADC_VOLT_WO ; 
wire [31:0] w_M2_port_wo_sadrs_h380 = 32'h33AA_CC55  ; // 0x380	NA  // known pattern

// ti 
wire w_M2_ck__sadrs_h114 = ep45ck;  wire [31:0] w_M2_port_ti_sadrs_h114; assign ep45trig = w_M2_port_ti_sadrs_h114; // DACX_TI
wire w_M2_ck__sadrs_h118 = ep46ck;  wire [31:0] w_M2_port_ti_sadrs_h118; assign ep46trig = w_M2_port_ti_sadrs_h118; // CLKD_TI
wire w_M2_ck__sadrs_h11C = ep47ck;  wire [31:0] w_M2_port_ti_sadrs_h11C; assign ep47trig = w_M2_port_ti_sadrs_h11C; // SPIO_TI
wire w_M2_ck__sadrs_h120 = ep48ck;  wire [31:0] w_M2_port_ti_sadrs_h120; assign ep48trig = w_M2_port_ti_sadrs_h120; // DACZ_DAT_TI   
wire w_M2_ck__sadrs_h124 = ep49ck;  wire [31:0] w_M2_port_ti_sadrs_h124; assign ep49trig = w_M2_port_ti_sadrs_h124; // TRIG_DAT_TI
wire w_M2_ck__sadrs_h14C = ep53ck;  wire [31:0] w_M2_port_ti_sadrs_h14C; assign ep53trig = w_M2_port_ti_sadrs_h14C; // MEM_TI

// to 
wire w_M2_ck__sadrs_h1CC = ep73ck;  wire [31:0] w_M2_port_to_sadrs_h1CC = ep73trig; // MEM_TO

// pi 
wire w_M2_wr__sadrs_h218; assign ep86wr = w_M2_wr__sadrs_h218;  wire [31:0] w_M2_port_pi_sadrs_h218; assign ep86pipe = w_M2_port_pi_sadrs_h218; // DAC0_DAT_PI // pipe_in_86
wire w_M2_wr__sadrs_h21C; assign ep87wr = w_M2_wr__sadrs_h21C;  wire [31:0] w_M2_port_pi_sadrs_h21C; assign ep87pipe = w_M2_port_pi_sadrs_h21C; // DAC0_DUR_PI // pipe_in_87
wire w_M2_wr__sadrs_h220; assign ep88wr = w_M2_wr__sadrs_h220;  wire [31:0] w_M2_port_pi_sadrs_h220; assign ep88pipe = w_M2_port_pi_sadrs_h220; // DAC1_DAT_PI // pipe_in_88
wire w_M2_wr__sadrs_h224; assign ep89wr = w_M2_wr__sadrs_h224;  wire [31:0] w_M2_port_pi_sadrs_h224; assign ep89pipe = w_M2_port_pi_sadrs_h224; // DAC1_DUR_PI // pipe_in_89
wire w_M2_wr__sadrs_h228; assign ep8Awr = w_M2_wr__sadrs_h228;  wire [31:0] w_M2_port_pi_sadrs_h228; assign ep8Apipe = w_M2_port_pi_sadrs_h228; // TEST_PI       | 0x228      | pipe_in_8A
wire w_M2_wr__sadrs_h24C; assign ep93wr = w_M2_wr__sadrs_h24C;  wire [31:0] w_M2_port_pi_sadrs_h24C; assign ep93pipe = w_M2_port_pi_sadrs_h24C; // MEM_PI      // pipe_in_93

// po
wire w_M2_rd__sadrs_h2A8; assign epAArd = w_M2_rd__sadrs_h2A8;  wire [31:0] w_M2_port_po_sadrs_h2A8 = epAApipe; // TEST_PO       | 0x2A8      | pipeout_AA 
wire w_M2_rd__sadrs_h2CC; assign epB3rd = w_M2_rd__sadrs_h2CC;  wire [31:0] w_M2_port_po_sadrs_h2CC = epB3pipe; // MEM_PO // pipeout_B3 


//}

//// other wires //{
wire       w_M2_loopback_en           = w_SSPI_CON_WI[24]   ; //$$ (~w_SSPI_CON_WI[0])? w_M2_port_wi_sadrs_h008[24]    : w_SSPI_CON_WI[24]    ;
wire       w_M2_MISO_one_bit_ahead_en = w_SSPI_CON_WI[25]   ; //$$ (~w_SSPI_CON_WI[0])? w_M2_port_wi_sadrs_h008[25]    : w_SSPI_CON_WI[25]    ;
wire [2:0] w_M2_slack_count_MISO      = w_SSPI_CON_WI[30:28]; //$$ (~w_SSPI_CON_WI[0])? w_M2_port_wi_sadrs_h008[30:28] : w_SSPI_CON_WI[30:28] ;
//
wire [7:0] w_board_status = 8'b0; // test

//}


slave_spi_mth_brd  slave_spi_mth_brd__M2_inst(
	.clk     (base_sspi_clk), // base clock 104MHz
	.reset_n (reset_n),
	
	//// slave SPI pins:
	.i_SPI_CS_B      (w_SSPI_CS_B   ),
	.i_SPI_CLK       (w_SSPI_CLK    ),
	.i_SPI_MOSI      (w_SSPI_MOSI   ),
	.o_SPI_MISO      (w_SSPI_MISO   ),
	.o_SPI_MISO_EN   (w_SSPI_MISO_EN), // MISO buffer control
	
	//// monitor
	.o_cnt_sspi_cs   (w_SSPI_cnt_sspi_cs), // [15:0] 
	
	//// endpoint port interface //{
	
	// wi
	.o_port_wi_sadrs_h008    (w_M2_port_wi_sadrs_h008), 
	.o_port_wi_sadrs_h014    (w_M2_port_wi_sadrs_h014),
	.o_port_wi_sadrs_h018    (w_M2_port_wi_sadrs_h018),
	.o_port_wi_sadrs_h01C    (w_M2_port_wi_sadrs_h01C),
	.o_port_wi_sadrs_h020    (w_M2_port_wi_sadrs_h020),
	.o_port_wi_sadrs_h024    (w_M2_port_wi_sadrs_h024),
	.o_port_wi_sadrs_h04C    (w_M2_port_wi_sadrs_h04C),
	.o_port_wi_sadrs_h048    (w_M2_port_wi_sadrs_h048),
	
	// wo
	.i_port_wo_sadrs_h080    (w_M2_port_wo_sadrs_h080),
	.i_port_wo_sadrs_h088    (w_M2_port_wo_sadrs_h088),
	.i_port_wo_sadrs_h08C    (w_M2_port_wo_sadrs_h08C),
	.i_port_wo_sadrs_h094    (w_M2_port_wo_sadrs_h094),
	.i_port_wo_sadrs_h098    (w_M2_port_wo_sadrs_h098),
	.i_port_wo_sadrs_h09C    (w_M2_port_wo_sadrs_h09C),
	.i_port_wo_sadrs_h0A0    (w_M2_port_wo_sadrs_h0A0),
	.i_port_wo_sadrs_h0A4    (w_M2_port_wo_sadrs_h0A4),
	.i_port_wo_sadrs_h0C8    (w_M2_port_wo_sadrs_h0C8),
	.i_port_wo_sadrs_h0E8    (w_M2_port_wo_sadrs_h0E8), 
	.i_port_wo_sadrs_h0EC    (w_M2_port_wo_sadrs_h0EC), 
	.i_port_wo_sadrs_h380    (w_M2_port_wo_sadrs_h380), 
	
	// ti
	.i_ck__sadrs_h114  (w_M2_ck__sadrs_h114),    .o_port_ti_sadrs_h114  (w_M2_port_ti_sadrs_h114), // [31:0] 
	.i_ck__sadrs_h118  (w_M2_ck__sadrs_h118),    .o_port_ti_sadrs_h118  (w_M2_port_ti_sadrs_h118), // [31:0] 
	.i_ck__sadrs_h11C  (w_M2_ck__sadrs_h11C),    .o_port_ti_sadrs_h11C  (w_M2_port_ti_sadrs_h11C), // [31:0] 
	.i_ck__sadrs_h120  (w_M2_ck__sadrs_h120),    .o_port_ti_sadrs_h120  (w_M2_port_ti_sadrs_h120), // [31:0] 
	.i_ck__sadrs_h124  (w_M2_ck__sadrs_h124),    .o_port_ti_sadrs_h124  (w_M2_port_ti_sadrs_h124), // [31:0] 
	.i_ck__sadrs_h14C  (w_M2_ck__sadrs_h14C),    .o_port_ti_sadrs_h14C  (w_M2_port_ti_sadrs_h14C), // [31:0] 

	// to
	.i_ck__sadrs_h1CC  (w_M2_ck__sadrs_h1CC),    .i_port_to_sadrs_h1CC  (w_M2_port_to_sadrs_h1CC), // [31:0] 

	// pi
	.o_wr__sadrs_h218  (w_M2_wr__sadrs_h218),    .o_port_pi_sadrs_h218  (w_M2_port_pi_sadrs_h218), // [31:0]  
	.o_wr__sadrs_h21C  (w_M2_wr__sadrs_h21C),    .o_port_pi_sadrs_h21C  (w_M2_port_pi_sadrs_h21C), // [31:0]  
	.o_wr__sadrs_h220  (w_M2_wr__sadrs_h220),    .o_port_pi_sadrs_h220  (w_M2_port_pi_sadrs_h220), // [31:0]  
	.o_wr__sadrs_h224  (w_M2_wr__sadrs_h224),    .o_port_pi_sadrs_h224  (w_M2_port_pi_sadrs_h224), // [31:0]  
	.o_wr__sadrs_h228  (w_M2_wr__sadrs_h228),    .o_port_pi_sadrs_h228  (w_M2_port_pi_sadrs_h228), // [31:0]  
	.o_wr__sadrs_h24C  (w_M2_wr__sadrs_h24C),    .o_port_pi_sadrs_h24C  (w_M2_port_pi_sadrs_h24C), // [31:0]  
	 
	// po
	.o_rd__sadrs_h2A8  (w_M2_rd__sadrs_h2A8),    .i_port_po_sadrs_h2A8  (w_M2_port_po_sadrs_h2A8), // [31:0]  
	.o_rd__sadrs_h2CC  (w_M2_rd__sadrs_h2CC),    .i_port_po_sadrs_h2CC  (w_M2_port_po_sadrs_h2CC), // [31:0]  
	
	//}
	
	//// loopback mode and timing control 
	.i_loopback_en           (w_M2_loopback_en          ), //       // '1' for loopback
	.i_slack_count_MISO      (w_M2_slack_count_MISO     ), // [2:0] // '0' for MISO on SCLK falling edge; 'n' for earlier location
	.i_MISO_one_bit_ahead_en (w_M2_MISO_one_bit_ahead_en), //       // '1' for MISO one bit ahead mode.  

	.i_board_id      (w_slot_id     ), // [3:0] // slot ID
	.i_board_status  (w_board_status), // [7:0] // board status

	.valid    () 
);


//}

// endpoints assignments //{

// miso control M2
//assign w_M2_loopback_en       = ; (~w_SSPI_CON_WI[0])? w_M2_port_wi_sadrs_h008[24]    : w_SSPI_CON_WI[24]    ;
//assign w_M2_slack_count_MISO  = ; (~w_SSPI_CON_WI[0])? w_M2_port_wi_sadrs_h008[30:28] : w_SSPI_CON_WI[30:28] ;

// HW reset control 
//assign w_HW_reset__ext        = w_M2_port_wi_sadrs_h008[3]; //$$


// flag assignment 
assign w_SSPI_FLAG_WO[31:24] = w_board_status[7:0];
assign w_SSPI_FLAG_WO[23:16] = w_slot_id_8b[7:0];
assign w_SSPI_FLAG_WO[15: 0] = w_SSPI_cnt_sspi_cs; // w_SSPI_cnt_sspi_cs
//assign w_SSPI_FLAG_WO[0]     = w_SSPI_CON_WI[0]; // enables SSPI control from MCS or USB 
//assign w_SSPI_FLAG_WO[1]     = 1'b0;  //$$ res_net_ctrl_ext_en; // enables res net control from SSPI
//assign w_SSPI_FLAG_WO[2]     = 1'b0; 
//assign w_SSPI_FLAG_WO[3]     = w_HW_reset; //$$ HW reset status
//assign w_SSPI_FLAG_WO[7:4]   =  4'b0; // w_slot_id[3:0]     ; // show board slot id 
//assign w_SSPI_FLAG_WO[15:8]  = w_board_status[7:0]; // show board status
//assign w_SSPI_FLAG_WO[23:16] = w_slot_id_8b;
//assign w_SSPI_FLAG_WO[27:24] = 4'b0; // {w_M2_slack_count_MISO[2:0], w_M2_loopback_en}; // miso control
//assign w_SSPI_FLAG_WO[31:28] = 4'b0; // {w_M1_slack_count_MISO[2:0], w_M1_loopback_en}; // miso control




//}


//}


///TODO: //-------------------------------------------------------//

/* TODO: okHost : ok_endpoint_wrapper */ //{
//$$ Endpoints
// Wire In 		0x00 - 0x1F
// Wire Out 	0x20 - 0x3F
// Trigger In 	0x40 - 0x5F
// Trigger Out 	0x60 - 0x7F
// Pipe In 		0x80 - 0x9F
// Pipe Out 	0xA0 - 0xBF

//  ok_endpoint_wrapper__dummy  ok_endpoint_wrapper_inst (
//  //ok_endpoint_wrapper  ok_endpoint_wrapper_inst (
//  	//$$  .okUH (okUH ), //input  wire [4:0]   okUH, // external pins
//  	//$$  .okHU (okHU ), //output wire [2:0]   okHU, // external pins
//  	//$$  .okUHU(okUHU), //inout  wire [31:0]  okUHU, // external pins
//  	//$$  .okAA (okAA ), //inout  wire         okAA, // external pin
//  	
//  	//$$ for dummy
//  	.clk    (sys_clk),
//  	.reset_n(reset_n),
//  	
//  	// Wire In 		0x00 - 0x1F
//  	.ep00wire(ep00wire), // output wire [31:0]
//  	.ep01wire(ep01wire), // output wire [31:0]
//  	.ep02wire(ep02wire), // output wire [31:0]
//  	.ep03wire(ep03wire), // output wire [31:0]
//  	.ep04wire(ep04wire), // output wire [31:0]
//  	.ep05wire(ep05wire), // output wire [31:0]
//  	.ep06wire(ep06wire), // output wire [31:0]
//  	.ep07wire(ep07wire), // output wire [31:0]
//  	.ep08wire(ep08wire), // output wire [31:0]
//  	.ep09wire(ep09wire), // output wire [31:0]
//  	.ep0Awire(ep0Awire), // output wire [31:0]
//  	.ep0Bwire(ep0Bwire), // output wire [31:0]
//  	.ep0Cwire(ep0Cwire), // output wire [31:0]
//  	.ep0Dwire(ep0Dwire), // output wire [31:0]
//  	.ep0Ewire(ep0Ewire), // output wire [31:0]
//  	.ep0Fwire(ep0Fwire), // output wire [31:0]
//  	.ep10wire(ep10wire), // output wire [31:0]
//  	.ep11wire(ep11wire), // output wire [31:0]
//  	.ep12wire(ep12wire), // output wire [31:0]
//  	.ep13wire(ep13wire), // output wire [31:0]
//  	.ep14wire(ep14wire), // output wire [31:0]
//  	.ep15wire(ep15wire), // output wire [31:0]
//  	.ep16wire(ep16wire), // output wire [31:0]
//  	.ep17wire(ep17wire), // output wire [31:0]
//  	.ep18wire(ep18wire), // output wire [31:0]
//  	.ep19wire(ep19wire), // output wire [31:0]
//  	.ep1Awire(ep1Awire), // output wire [31:0]
//  	.ep1Bwire(ep1Bwire), // output wire [31:0]
//  	.ep1Cwire(ep1Cwire), // output wire [31:0]
//  	.ep1Dwire(ep1Dwire), // output wire [31:0]
//  	.ep1Ewire(ep1Ewire), // output wire [31:0]
//  	.ep1Fwire(ep1Fwire), // output wire [31:0]
//  	// Wire Out 	0x20 - 0x3F
//  	.ep20wire(ep20wire), // input wire [31:0]
//  	.ep21wire(ep21wire), // input wire [31:0]
//  	.ep22wire(ep22wire), // input wire [31:0]
//  	.ep23wire(ep23wire), // input wire [31:0]
//  	.ep24wire(ep24wire), // input wire [31:0]
//  	.ep25wire(ep25wire), // input wire [31:0]
//  	.ep26wire(ep26wire), // input wire [31:0]
//  	.ep27wire(ep27wire), // input wire [31:0]
//  	.ep28wire(ep28wire), // input wire [31:0]
//  	.ep29wire(ep29wire), // input wire [31:0]
//  	.ep2Awire(ep2Awire), // input wire [31:0]
//  	.ep2Bwire(ep2Bwire), // input wire [31:0]
//  	.ep2Cwire(ep2Cwire), // input wire [31:0]
//  	.ep2Dwire(ep2Dwire), // input wire [31:0]
//  	.ep2Ewire(ep2Ewire), // input wire [31:0]
//  	.ep2Fwire(ep2Fwire), // input wire [31:0]
//  	.ep30wire(ep30wire), // input wire [31:0]
//  	.ep31wire(ep31wire), // input wire [31:0]
//  	.ep32wire(ep32wire), // input wire [31:0]
//  	.ep33wire(ep33wire), // input wire [31:0]
//  	.ep34wire(ep34wire), // input wire [31:0]
//  	.ep35wire(ep35wire), // input wire [31:0]
//  	.ep36wire(ep36wire), // input wire [31:0]
//  	.ep37wire(ep37wire), // input wire [31:0]
//  	.ep38wire(ep38wire), // input wire [31:0]
//  	.ep39wire(ep39wire), // input wire [31:0]
//  	.ep3Awire(ep3Awire), // input wire [31:0]
//  	.ep3Bwire(ep3Bwire), // input wire [31:0]
//  	.ep3Cwire(ep3Cwire), // input wire [31:0]
//  	.ep3Dwire(ep3Dwire), // input wire [31:0]
//  	.ep3Ewire(ep3Ewire), // input wire [31:0]
//  	.ep3Fwire(ep3Fwire), // input wire [31:0]
//  	// Trigger In 	0x40 - 0x5F
//  	.ep40ck(ep40ck), .ep40trig(ep40trig), // input wire, output wire [31:0],
//  	.ep41ck(ep41ck), .ep41trig(ep41trig), // input wire, output wire [31:0],
//  	.ep42ck(ep42ck), .ep42trig(ep42trig), // input wire, output wire [31:0],
//  	.ep43ck(ep43ck), .ep43trig(ep43trig), // input wire, output wire [31:0],
//  	.ep44ck(ep44ck), .ep44trig(ep44trig), // input wire, output wire [31:0],
//  	.ep45ck(ep45ck), .ep45trig(ep45trig), // input wire, output wire [31:0],
//  	.ep46ck(ep46ck), .ep46trig(ep46trig), // input wire, output wire [31:0],
//  	.ep47ck(ep47ck), .ep47trig(ep47trig), // input wire, output wire [31:0],
//  	.ep48ck(ep48ck), .ep48trig(ep48trig), // input wire, output wire [31:0],
//  	.ep49ck(ep49ck), .ep49trig(ep49trig), // input wire, output wire [31:0],
//  	.ep4Ack(ep4Ack), .ep4Atrig(ep4Atrig), // input wire, output wire [31:0],
//  	.ep4Bck(ep4Bck), .ep4Btrig(ep4Btrig), // input wire, output wire [31:0],
//  	.ep4Cck(ep4Cck), .ep4Ctrig(ep4Ctrig), // input wire, output wire [31:0],
//  	.ep4Dck(ep4Dck), .ep4Dtrig(ep4Dtrig), // input wire, output wire [31:0],
//  	.ep4Eck(ep4Eck), .ep4Etrig(ep4Etrig), // input wire, output wire [31:0],
//  	.ep4Fck(ep4Fck), .ep4Ftrig(ep4Ftrig), // input wire, output wire [31:0],
//  	.ep50ck(ep50ck), .ep50trig(ep50trig), // input wire, output wire [31:0],
//  	.ep51ck(ep51ck), .ep51trig(ep51trig), // input wire, output wire [31:0],
//  	.ep52ck(ep52ck), .ep52trig(ep52trig), // input wire, output wire [31:0],
//  	.ep53ck(ep53ck), .ep53trig(ep53trig), // input wire, output wire [31:0],
//  	.ep54ck(ep54ck), .ep54trig(ep54trig), // input wire, output wire [31:0],
//  	.ep55ck(ep55ck), .ep55trig(ep55trig), // input wire, output wire [31:0],
//  	.ep56ck(ep56ck), .ep56trig(ep56trig), // input wire, output wire [31:0],
//  	.ep57ck(ep57ck), .ep57trig(ep57trig), // input wire, output wire [31:0],
//  	.ep58ck(ep58ck), .ep58trig(ep58trig), // input wire, output wire [31:0],
//  	.ep59ck(ep59ck), .ep59trig(ep59trig), // input wire, output wire [31:0],
//  	.ep5Ack(ep5Ack), .ep5Atrig(ep5Atrig), // input wire, output wire [31:0],
//  	.ep5Bck(ep5Bck), .ep5Btrig(ep5Btrig), // input wire, output wire [31:0],
//  	.ep5Cck(ep5Cck), .ep5Ctrig(ep5Ctrig), // input wire, output wire [31:0],
//  	.ep5Dck(ep5Dck), .ep5Dtrig(ep5Dtrig), // input wire, output wire [31:0],
//  	.ep5Eck(ep5Eck), .ep5Etrig(ep5Etrig), // input wire, output wire [31:0],
//  	.ep5Fck(ep5Fck), .ep5Ftrig(ep5Ftrig), // input wire, output wire [31:0],
//  	// Trigger Out 	0x60 - 0x7F
//  	.ep60ck(ep60ck), .ep60trig(ep60trig), // input wire, input wire [31:0],
//  	.ep61ck(ep61ck), .ep61trig(ep61trig), // input wire, input wire [31:0],
//  	.ep62ck(ep62ck), .ep62trig(ep62trig), // input wire, input wire [31:0],
//  	.ep63ck(ep63ck), .ep63trig(ep63trig), // input wire, input wire [31:0],
//  	.ep64ck(ep64ck), .ep64trig(ep64trig), // input wire, input wire [31:0],
//  	.ep65ck(ep65ck), .ep65trig(ep65trig), // input wire, input wire [31:0],
//  	.ep66ck(ep66ck), .ep66trig(ep66trig), // input wire, input wire [31:0],
//  	.ep67ck(ep67ck), .ep67trig(ep67trig), // input wire, input wire [31:0],
//  	.ep68ck(ep68ck), .ep68trig(ep68trig), // input wire, input wire [31:0],
//  	.ep69ck(ep69ck), .ep69trig(ep69trig), // input wire, input wire [31:0],
//  	.ep6Ack(ep6Ack), .ep6Atrig(ep6Atrig), // input wire, input wire [31:0],
//  	.ep6Bck(ep6Bck), .ep6Btrig(ep6Btrig), // input wire, input wire [31:0],
//  	.ep6Cck(ep6Cck), .ep6Ctrig(ep6Ctrig), // input wire, input wire [31:0],
//  	.ep6Dck(ep6Dck), .ep6Dtrig(ep6Dtrig), // input wire, input wire [31:0],
//  	.ep6Eck(ep6Eck), .ep6Etrig(ep6Etrig), // input wire, input wire [31:0],
//  	.ep6Fck(ep6Fck), .ep6Ftrig(ep6Ftrig), // input wire, input wire [31:0],
//  	.ep70ck(ep70ck), .ep70trig(ep70trig), // input wire, input wire [31:0],
//  	.ep71ck(ep71ck), .ep71trig(ep71trig), // input wire, input wire [31:0],
//  	.ep72ck(ep72ck), .ep72trig(ep72trig), // input wire, input wire [31:0],
//  	.ep73ck(ep73ck), .ep73trig(ep73trig), // input wire, input wire [31:0],
//  	.ep74ck(ep74ck), .ep74trig(ep74trig), // input wire, input wire [31:0],
//  	.ep75ck(ep75ck), .ep75trig(ep75trig), // input wire, input wire [31:0],
//  	.ep76ck(ep76ck), .ep76trig(ep76trig), // input wire, input wire [31:0],
//  	.ep77ck(ep77ck), .ep77trig(ep77trig), // input wire, input wire [31:0],
//  	.ep78ck(ep78ck), .ep78trig(ep78trig), // input wire, input wire [31:0],
//  	.ep79ck(ep79ck), .ep79trig(ep79trig), // input wire, input wire [31:0],
//  	.ep7Ack(ep7Ack), .ep7Atrig(ep7Atrig), // input wire, input wire [31:0],
//  	.ep7Bck(ep7Bck), .ep7Btrig(ep7Btrig), // input wire, input wire [31:0],
//  	.ep7Cck(ep7Cck), .ep7Ctrig(ep7Ctrig), // input wire, input wire [31:0],
//  	.ep7Dck(ep7Dck), .ep7Dtrig(ep7Dtrig), // input wire, input wire [31:0],
//  	.ep7Eck(ep7Eck), .ep7Etrig(ep7Etrig), // input wire, input wire [31:0],
//  	.ep7Fck(ep7Fck), .ep7Ftrig(ep7Ftrig), // input wire, input wire [31:0],
//  	// Pipe In 		0x80 - 0x9F
//  	.ep80wr(ep80wr), .ep80pipe(ep80pipe), // output wire, output wire [31:0],
//  	.ep81wr(ep81wr), .ep81pipe(ep81pipe), // output wire, output wire [31:0],
//  	.ep82wr(ep82wr), .ep82pipe(ep82pipe), // output wire, output wire [31:0],
//  	.ep83wr(ep83wr), .ep83pipe(ep83pipe), // output wire, output wire [31:0],
//  	.ep84wr(ep84wr), .ep84pipe(ep84pipe), // output wire, output wire [31:0],
//  	.ep85wr(ep85wr), .ep85pipe(ep85pipe), // output wire, output wire [31:0],
//  	.ep86wr(ep86wr), .ep86pipe(ep86pipe), // output wire, output wire [31:0],
//  	.ep87wr(ep87wr), .ep87pipe(ep87pipe), // output wire, output wire [31:0],
//  	.ep88wr(ep88wr), .ep88pipe(ep88pipe), // output wire, output wire [31:0],
//  	.ep89wr(ep89wr), .ep89pipe(ep89pipe), // output wire, output wire [31:0],
//  	.ep8Awr(ep8Awr), .ep8Apipe(ep8Apipe), // output wire, output wire [31:0],
//  	.ep8Bwr(ep8Bwr), .ep8Bpipe(ep8Bpipe), // output wire, output wire [31:0],
//  	.ep8Cwr(ep8Cwr), .ep8Cpipe(ep8Cpipe), // output wire, output wire [31:0],
//  	.ep8Dwr(ep8Dwr), .ep8Dpipe(ep8Dpipe), // output wire, output wire [31:0],
//  	.ep8Ewr(ep8Ewr), .ep8Epipe(ep8Epipe), // output wire, output wire [31:0],
//  	.ep8Fwr(ep8Fwr), .ep8Fpipe(ep8Fpipe), // output wire, output wire [31:0],
//  	.ep90wr(ep90wr), .ep90pipe(ep90pipe), // output wire, output wire [31:0],
//  	.ep91wr(ep91wr), .ep91pipe(ep91pipe), // output wire, output wire [31:0],
//  	.ep92wr(ep92wr), .ep92pipe(ep92pipe), // output wire, output wire [31:0],
//  	.ep93wr(ep93wr), .ep93pipe(ep93pipe), // output wire, output wire [31:0],
//  	.ep94wr(ep94wr), .ep94pipe(ep94pipe), // output wire, output wire [31:0],
//  	.ep95wr(ep95wr), .ep95pipe(ep95pipe), // output wire, output wire [31:0],
//  	.ep96wr(ep96wr), .ep96pipe(ep96pipe), // output wire, output wire [31:0],
//  	.ep97wr(ep97wr), .ep97pipe(ep97pipe), // output wire, output wire [31:0],
//  	.ep98wr(ep98wr), .ep98pipe(ep98pipe), // output wire, output wire [31:0],
//  	.ep99wr(ep99wr), .ep99pipe(ep99pipe), // output wire, output wire [31:0],
//  	.ep9Awr(ep9Awr), .ep9Apipe(ep9Apipe), // output wire, output wire [31:0],
//  	.ep9Bwr(ep9Bwr), .ep9Bpipe(ep9Bpipe), // output wire, output wire [31:0],
//  	.ep9Cwr(ep9Cwr), .ep9Cpipe(ep9Cpipe), // output wire, output wire [31:0],
//  	.ep9Dwr(ep9Dwr), .ep9Dpipe(ep9Dpipe), // output wire, output wire [31:0],
//  	.ep9Ewr(ep9Ewr), .ep9Epipe(ep9Epipe), // output wire, output wire [31:0],
//  	.ep9Fwr(ep9Fwr), .ep9Fpipe(ep9Fpipe), // output wire, output wire [31:0],
//  	// Pipe Out 	0xA0 - 0xBF
//  	.epA0rd(epA0rd), .epA0pipe(epA0pipe), // output wire, input wire [31:0],
//  	.epA1rd(epA1rd), .epA1pipe(epA1pipe), // output wire, input wire [31:0],
//  	.epA2rd(epA2rd), .epA2pipe(epA2pipe), // output wire, input wire [31:0],
//  	.epA3rd(epA3rd), .epA3pipe(epA3pipe), // output wire, input wire [31:0],
//  	.epA4rd(epA4rd), .epA4pipe(epA4pipe), // output wire, input wire [31:0],
//  	.epA5rd(epA5rd), .epA5pipe(epA5pipe), // output wire, input wire [31:0],
//  	.epA6rd(epA6rd), .epA6pipe(epA6pipe), // output wire, input wire [31:0],
//  	.epA7rd(epA7rd), .epA7pipe(epA7pipe), // output wire, input wire [31:0],
//  	.epA8rd(epA8rd), .epA8pipe(epA8pipe), // output wire, input wire [31:0],
//  	.epA9rd(epA9rd), .epA9pipe(epA9pipe), // output wire, input wire [31:0],
//  	.epAArd(epAArd), .epAApipe(epAApipe), // output wire, input wire [31:0],
//  	.epABrd(epABrd), .epABpipe(epABpipe), // output wire, input wire [31:0],
//  	.epACrd(epACrd), .epACpipe(epACpipe), // output wire, input wire [31:0],
//  	.epADrd(epADrd), .epADpipe(epADpipe), // output wire, input wire [31:0],
//  	.epAErd(epAErd), .epAEpipe(epAEpipe), // output wire, input wire [31:0],
//  	.epAFrd(epAFrd), .epAFpipe(epAFpipe), // output wire, input wire [31:0],
//  	.epB0rd(epB0rd), .epB0pipe(epB0pipe), // output wire, input wire [31:0],
//  	.epB1rd(epB1rd), .epB1pipe(epB1pipe), // output wire, input wire [31:0],
//  	.epB2rd(epB2rd), .epB2pipe(epB2pipe), // output wire, input wire [31:0],
//  	.epB3rd(epB3rd), .epB3pipe(epB3pipe), // output wire, input wire [31:0],
//  	.epB4rd(epB4rd), .epB4pipe(epB4pipe), // output wire, input wire [31:0],
//  	.epB5rd(epB5rd), .epB5pipe(epB5pipe), // output wire, input wire [31:0],
//  	.epB6rd(epB6rd), .epB6pipe(epB6pipe), // output wire, input wire [31:0],
//  	.epB7rd(epB7rd), .epB7pipe(epB7pipe), // output wire, input wire [31:0],
//  	.epB8rd(epB8rd), .epB8pipe(epB8pipe), // output wire, input wire [31:0],
//  	.epB9rd(epB9rd), .epB9pipe(epB9pipe), // output wire, input wire [31:0],
//  	.epBArd(epBArd), .epBApipe(epBApipe), // output wire, input wire [31:0],
//  	.epBBrd(epBBrd), .epBBpipe(epBBpipe), // output wire, input wire [31:0],
//  	.epBCrd(epBCrd), .epBCpipe(epBCpipe), // output wire, input wire [31:0],
//  	.epBDrd(epBDrd), .epBDpipe(epBDpipe), // output wire, input wire [31:0],
//  	.epBErd(epBErd), .epBEpipe(epBEpipe), // output wire, input wire [31:0],
//  	.epBFrd(epBFrd), .epBFpipe(epBFpipe), // output wire, input wire [31:0],
//  	// 
//  	.okClk(okClk)//output wire okClk // sync with write/read of pipe
//  	);
	
//}


///TODO: //-------------------------------------------------------//


/* TODO: other BANK signals */ //{

//// LAN fixed in S3100-PGU //{
assign PT_FMOD_EP_LAN_MOSI  = EP_LAN_MOSI ;
assign PT_FMOD_EP_LAN_SCLK  = EP_LAN_SCLK ;
assign PT_FMOD_EP_LAN_CS_B  = EP_LAN_CS_B ;
assign PT_FMOD_EP_LAN_RST_B = EP_LAN_RST_B;
//
assign EP_LAN_INT_B = PT_FMOD_EP_LAN_INT_B;
assign EP_LAN_MISO  = PT_FMOD_EP_LAN_MISO ;
//}

// LAN signals to mux //{

// output mux
//assign PT_BASE_EP_LAN_MOSI  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
//assign PT_BASE_EP_LAN_SCLK  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
//assign PT_BASE_EP_LAN_CS_B  = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
//assign PT_BASE_EP_LAN_RST_B = ( w_sel__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

//assign PT_FMOD_EP_LAN_MOSI  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_MOSI  : 1'b0;
//assign PT_FMOD_EP_LAN_SCLK  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_SCLK  : 1'b0;
//assign PT_FMOD_EP_LAN_CS_B  = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_CS_B  : 1'b1;
//assign PT_FMOD_EP_LAN_RST_B = (~w_sel__H_LAN_on_BASE_BD)? EP_LAN_RST_B : 1'b1;

// input mux
//assign EP_LAN_INT_B = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_INT_B  : PT_BASE_EP_LAN_INT_B;
//assign EP_LAN_MISO  = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_MISO   : PT_BASE_EP_LAN_MISO;
//assign EP_LAN_INT_B = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_INT_B  : 1'b1;
//assign EP_LAN_MISO  = (~w_sel__H_LAN_on_BASE_BD)? PT_FMOD_EP_LAN_MISO   : 1'b0;


//}

//}

endmodule
