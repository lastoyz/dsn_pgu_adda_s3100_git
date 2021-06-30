##== TIME STAMP ==##
#set_property MARK_DEBUG true [get_nets {w_TIMESTAMP_WO[*]}]
set_property MARK_DEBUG true [get_nets {sub_timestamp_inst/r_global_time_idx[*]}]


##== MTH SPI ==##

## ports for master_spi_mth_brd__inst

#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_frame]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_done_frame]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_init]

set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_trig_init  ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_done_init  ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_trig_frame ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_done_frame ]

set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_C[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_A[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_D[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_B[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_E[*]]

#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SS_B]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MOSI]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MCLK]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO_EN]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SCLK]


##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS0_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS1_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS2_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS3_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS4_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS5_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS6_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS7_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS8_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS9_ ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS10 ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS11 ]
##set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS12 ]


## ports for slave_spi_mth_brd__M2_inst 

#set_property MARK_DEBUG true [get_nets w_SSPI_CS_B   ]
#set_property MARK_DEBUG true [get_nets w_SSPI_CLK    ]
#set_property MARK_DEBUG true [get_nets w_SSPI_MOSI   ]
#set_property MARK_DEBUG true [get_nets w_SSPI_MISO   ]
#set_property MARK_DEBUG true [get_nets w_SSPI_MISO_EN]

set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/i_SPI_CS_B    ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/i_SPI_CLK     ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/i_SPI_MOSI    ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/o_SPI_MISO    ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/o_SPI_MISO_EN ]

set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/o_port_pi_sadrs_h228[*] ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/i_port_po_sadrs_h2A8[*] ]

set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/o_cnt_sspi_cs[*] ]

set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/r_frame_ctrl[*] ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/r_frame_adrs[*] ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/r_frame_mosi[*] ]
set_property MARK_DEBUG true [get_nets slave_spi_mth_brd__M2_inst/r_frame_miso[*] ]


##== LAN ==##



##== DAC Pattern Gen ==##

set_property MARK_DEBUG true [get_nets {DAC0_DAT[*]}]
set_property MARK_DEBUG true [get_nets {DAC1_DAT[*]}]

set_property MARK_DEBUG true [get_nets dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac0]
set_property MARK_DEBUG true [get_nets dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac1]


##------------------------------------------------------------------------##

#### LOC for mmcm pll ####

## set_property LOC MMCME2_ADV_X0Y1 [get_cells -quiet [list clk_wiz_0_inst/inst/mmcm_adv_inst]]

set_property LOC PLLE2_ADV_X0Y1 [get_cells clk_wiz_1_2_inst/inst/plle2_adv_inst]
set_property LOC PLLE2_ADV_X0Y0 [get_cells clk_wiz_0_3_1_inst/inst/plle2_adv_inst]
set_property LOC PLLE2_ADV_X1Y3 [get_cells clk_wiz_1_2_1_inst/inst/plle2_adv_inst]
set_property LOC PLLE2_ADV_X1Y2 [get_cells clk_wiz_1_2_0_inst/inst/plle2_adv_inst]


#### pblock ####

create_pblock pblock_lan_endpnt_wrpr_inst
add_cells_to_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] [get_cells -quiet [list lan_endpoint_wrapper_inst]]
##resize_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] -add {CLOCKREGION_X0Y0:CLOCKREGION_X1Y1}
##resize_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y4 CLOCKREGION_X1Y4:CLOCKREGION_X1Y4}
resize_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] -add {CLOCKREGION_X0Y2:CLOCKREGION_X0Y4}


create_pblock pblock_mth
add_cells_to_pblock [get_pblocks pblock_mth] [get_cells -quiet [list  master_spi_mth_brd__inst slave_spi_mth_brd__M2_inst]]
resize_pblock [get_pblocks pblock_mth] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y1}


create_pblock pblock_dac
add_cells_to_pblock [get_pblocks pblock_dac] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_*]]
resize_pblock [get_pblocks pblock_dac] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y3}


create_pblock pblock_dac0_fifo_datinc
add_cells_to_pblock [get_pblocks pblock_dac0_fifo_datinc] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac0_fifo_datinc__inst ]]
resize_pblock [get_pblocks pblock_dac0_fifo_datinc] -add {RAMB36_X6Y22:RAMB36_X6Y23}
#set_property PARENT pblock_dac0 [get_pblocks pblock_dac0_fifo_datinc]
set_property PARENT pblock_dac [get_pblocks pblock_dac0_fifo_datinc]

create_pblock pblock_dac0_fifo_dur
add_cells_to_pblock [get_pblocks pblock_dac0_fifo_dur] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac0_fifo_dur_____inst]]
resize_pblock [get_pblocks pblock_dac0_fifo_dur] -add {RAMB36_X6Y20:RAMB36_X6Y21}
#set_property PARENT pblock_dac0 [get_pblocks pblock_dac0_fifo_dur]
set_property PARENT pblock_dac [get_pblocks pblock_dac0_fifo_dur]

#GRID_RANGES	RAMB36_X6Y20:RAMB36_X6Y24, RAMB18_X6Y40:RAMB18_X6Y49, DSP48_X5Y40:DSP48_X6Y49, SLICE_X92Y100:SLICE_X117Y124  for dac0
create_pblock pblock_dac0
#add_cells_to_pblock [get_pblocks pblock_dac0] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_idx_dac0__inst dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_rpt_dac0__inst]]
add_cells_to_pblock [get_pblocks pblock_dac0] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_idx_dac0__inst]]
resize_pblock [get_pblocks pblock_dac0] -add {SLICE_X92Y100:SLICE_X117Y124}
set_property PARENT pblock_dac [get_pblocks pblock_dac0]

#create_pblock pblock_dac0_cnt_dur
#add_cells_to_pblock [get_pblocks pblock_dac0_cnt_dur] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_dur_dac0__inst]]
#resize_pblock [get_pblocks pblock_dac0_cnt_dur] -add {SLICE_X102Y100:SLICE_X108Y119}
#set_property PARENT pblock_dac0 [get_pblocks pblock_dac0_cnt_dur]

#create_pblock pblock_dac0_dat_out
#add_cells_to_pblock [get_pblocks pblock_dac0_dat_out] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_dat_out_dac0__inst]]
#resize_pblock [get_pblocks pblock_dac0_dat_out] -add {SLICE_X104Y100:SLICE_X107Y119}
#set_property PARENT pblock_dac0 [get_pblocks pblock_dac0_dat_out]


create_pblock pblock_dac1_fifo_datinc
add_cells_to_pblock [get_pblocks pblock_dac1_fifo_datinc] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac1_fifo_datinc__inst ]]
resize_pblock [get_pblocks pblock_dac1_fifo_datinc] -add {RAMB36_X6Y27:RAMB36_X6Y28}
#set_property PARENT pblock_dac1 [get_pblocks pblock_dac1_fifo_datinc]
set_property PARENT pblock_dac [get_pblocks pblock_dac1_fifo_datinc]

create_pblock pblock_dac1_fifo_dur
add_cells_to_pblock [get_pblocks pblock_dac1_fifo_dur] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac1_fifo_dur_____inst]]
resize_pblock [get_pblocks pblock_dac1_fifo_dur] -add {RAMB36_X6Y25:RAMB36_X6Y26}
#set_property PARENT pblock_dac1 [get_pblocks pblock_dac1_fifo_dur]
set_property PARENT pblock_dac [get_pblocks pblock_dac1_fifo_dur]

#GRID_RANGES	RAMB36_X6Y25:RAMB36_X6Y29, RAMB18_X6Y50:RAMB18_X6Y59, DSP48_X5Y50:DSP48_X6Y59, SLICE_X92Y125:SLICE_X117Y149  for dac1
create_pblock pblock_dac1
#add_cells_to_pblock [get_pblocks pblock_dac1] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_idx_dac1__inst dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_rpt_dac1__inst]]
add_cells_to_pblock [get_pblocks pblock_dac1] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_idx_dac1__inst]]
resize_pblock [get_pblocks pblock_dac1] -add {SLICE_X92Y125:SLICE_X117Y149}
set_property PARENT pblock_dac [get_pblocks pblock_dac1]

#create_pblock pblock_dac1_cnt_dur
#add_cells_to_pblock [get_pblocks pblock_dac1_cnt_dur] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_cnt_dur_dac1__inst]]
#resize_pblock [get_pblocks pblock_dac1_cnt_dur] -add {SLICE_X102Y150:SLICE_X108Y169}
#set_property PARENT pblock_dac1 [get_pblocks pblock_dac1_cnt_dur]

#create_pblock pblock_dac1_dat_out
#add_cells_to_pblock [get_pblocks pblock_dac1_dat_out] [get_cells -quiet [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/dsp48__AP_C__r_fcid_dat_out_dac1__inst]]
#resize_pblock [get_pblocks pblock_dac1_dat_out] -add {SLICE_X104Y150:SLICE_X107Y169}
#set_property PARENT pblock_dac1 [get_pblocks pblock_dac1_dat_out]



