##== TIME STAMP ==##
#set_property MARK_DEBUG true [get_nets {w_TIMESTAMP_WO[*]}]
set_property MARK_DEBUG true [get_nets {sub_timestamp_inst/r_global_time_idx[*]}]


##== MTH SPI ==##
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_frame]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_done_frame]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_init]

set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SS_B]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MOSI]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MCLK]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO_EN]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SCLK]

set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_C[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_A[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_D[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_B[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_E[*]]


##== LAN ==##


##------------------------------------------------------------------------##

#### LOC for mmcm pll ####

##set_property LOC MMCME2_ADV_X0Y2 [get_cells -quiet [list ok_endpoint_wrapper_inst/okHI/mmcm0]]
set_property LOC MMCME2_ADV_X0Y1 [get_cells -quiet [list clk_wiz_0_inst/inst/mmcm_adv_inst]]

##set_property LOC PLLE2_ADV_X0Y1 [get_cells clk_wiz_1_2_inst/inst/plle2_adv_inst]
set_property LOC PLLE2_ADV_X0Y0 [get_cells clk_wiz_0_3_1_inst/inst/plle2_adv_inst]
##set_property LOC PLLE2_ADV_X1Y3 [get_cells clk_wiz_1_2_1_inst/inst/plle2_adv_inst]
##set_property LOC PLLE2_ADV_X1Y2 [get_cells clk_wiz_1_2_0_inst/inst/plle2_adv_inst]


#### pblock ####

create_pblock pblock_lan_endpnt_wrpr_inst
add_cells_to_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] [get_cells -quiet [list lan_endpoint_wrapper_inst]]
resize_pblock [get_pblocks pblock_lan_endpnt_wrpr_inst] -add {CLOCKREGION_X0Y0:CLOCKREGION_X1Y1}


