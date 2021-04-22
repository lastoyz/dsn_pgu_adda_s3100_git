create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz_2_2_inst/inst/clk_out1_104M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 10 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_A[0]} {master_spi_mth_brd__inst/i_frame_data_A[1]} {master_spi_mth_brd__inst/i_frame_data_A[2]} {master_spi_mth_brd__inst/i_frame_data_A[3]} {master_spi_mth_brd__inst/i_frame_data_A[4]} {master_spi_mth_brd__inst/i_frame_data_A[5]} {master_spi_mth_brd__inst/i_frame_data_A[6]} {master_spi_mth_brd__inst/i_frame_data_A[7]} {master_spi_mth_brd__inst/i_frame_data_A[8]} {master_spi_mth_brd__inst/i_frame_data_A[9]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list clk_wiz_0_0_1_inst/inst/clk_out1_10M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 32 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {sub_timestamp_inst/r_global_time_idx[0]} {sub_timestamp_inst/r_global_time_idx[1]} {sub_timestamp_inst/r_global_time_idx[2]} {sub_timestamp_inst/r_global_time_idx[3]} {sub_timestamp_inst/r_global_time_idx[4]} {sub_timestamp_inst/r_global_time_idx[5]} {sub_timestamp_inst/r_global_time_idx[6]} {sub_timestamp_inst/r_global_time_idx[7]} {sub_timestamp_inst/r_global_time_idx[8]} {sub_timestamp_inst/r_global_time_idx[9]} {sub_timestamp_inst/r_global_time_idx[10]} {sub_timestamp_inst/r_global_time_idx[11]} {sub_timestamp_inst/r_global_time_idx[12]} {sub_timestamp_inst/r_global_time_idx[13]} {sub_timestamp_inst/r_global_time_idx[14]} {sub_timestamp_inst/r_global_time_idx[15]} {sub_timestamp_inst/r_global_time_idx[16]} {sub_timestamp_inst/r_global_time_idx[17]} {sub_timestamp_inst/r_global_time_idx[18]} {sub_timestamp_inst/r_global_time_idx[19]} {sub_timestamp_inst/r_global_time_idx[20]} {sub_timestamp_inst/r_global_time_idx[21]} {sub_timestamp_inst/r_global_time_idx[22]} {sub_timestamp_inst/r_global_time_idx[23]} {sub_timestamp_inst/r_global_time_idx[24]} {sub_timestamp_inst/r_global_time_idx[25]} {sub_timestamp_inst/r_global_time_idx[26]} {sub_timestamp_inst/r_global_time_idx[27]} {sub_timestamp_inst/r_global_time_idx[28]} {sub_timestamp_inst/r_global_time_idx[29]} {sub_timestamp_inst/r_global_time_idx[30]} {sub_timestamp_inst/r_global_time_idx[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 6 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_C[0]} {master_spi_mth_brd__inst/i_frame_data_C[1]} {master_spi_mth_brd__inst/i_frame_data_C[2]} {master_spi_mth_brd__inst/i_frame_data_C[3]} {master_spi_mth_brd__inst/i_frame_data_C[4]} {master_spi_mth_brd__inst/i_frame_data_C[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_D[0]} {master_spi_mth_brd__inst/i_frame_data_D[1]} {master_spi_mth_brd__inst/i_frame_data_D[2]} {master_spi_mth_brd__inst/i_frame_data_D[3]} {master_spi_mth_brd__inst/i_frame_data_D[4]} {master_spi_mth_brd__inst/i_frame_data_D[5]} {master_spi_mth_brd__inst/i_frame_data_D[6]} {master_spi_mth_brd__inst/i_frame_data_D[7]} {master_spi_mth_brd__inst/i_frame_data_D[8]} {master_spi_mth_brd__inst/i_frame_data_D[9]} {master_spi_mth_brd__inst/i_frame_data_D[10]} {master_spi_mth_brd__inst/i_frame_data_D[11]} {master_spi_mth_brd__inst/i_frame_data_D[12]} {master_spi_mth_brd__inst/i_frame_data_D[13]} {master_spi_mth_brd__inst/i_frame_data_D[14]} {master_spi_mth_brd__inst/i_frame_data_D[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {master_spi_mth_brd__inst/o_frame_data_B[0]} {master_spi_mth_brd__inst/o_frame_data_B[1]} {master_spi_mth_brd__inst/o_frame_data_B[2]} {master_spi_mth_brd__inst/o_frame_data_B[3]} {master_spi_mth_brd__inst/o_frame_data_B[4]} {master_spi_mth_brd__inst/o_frame_data_B[5]} {master_spi_mth_brd__inst/o_frame_data_B[6]} {master_spi_mth_brd__inst/o_frame_data_B[7]} {master_spi_mth_brd__inst/o_frame_data_B[8]} {master_spi_mth_brd__inst/o_frame_data_B[9]} {master_spi_mth_brd__inst/o_frame_data_B[10]} {master_spi_mth_brd__inst/o_frame_data_B[11]} {master_spi_mth_brd__inst/o_frame_data_B[12]} {master_spi_mth_brd__inst/o_frame_data_B[13]} {master_spi_mth_brd__inst/o_frame_data_B[14]} {master_spi_mth_brd__inst/o_frame_data_B[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {master_spi_mth_brd__inst/o_frame_data_E[0]} {master_spi_mth_brd__inst/o_frame_data_E[1]} {master_spi_mth_brd__inst/o_frame_data_E[2]} {master_spi_mth_brd__inst/o_frame_data_E[3]} {master_spi_mth_brd__inst/o_frame_data_E[4]} {master_spi_mth_brd__inst/o_frame_data_E[5]} {master_spi_mth_brd__inst/o_frame_data_E[6]} {master_spi_mth_brd__inst/o_frame_data_E[7]} {master_spi_mth_brd__inst/o_frame_data_E[8]} {master_spi_mth_brd__inst/o_frame_data_E[9]} {master_spi_mth_brd__inst/o_frame_data_E[10]} {master_spi_mth_brd__inst/o_frame_data_E[11]} {master_spi_mth_brd__inst/o_frame_data_E[12]} {master_spi_mth_brd__inst/o_frame_data_E[13]} {master_spi_mth_brd__inst/o_frame_data_E[14]} {master_spi_mth_brd__inst/o_frame_data_E[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list FPGA_M0_SPI_nCS0_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list FPGA_M0_SPI_nCS1_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list FPGA_M0_SPI_nCS2_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list FPGA_M0_SPI_nCS3_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list FPGA_M0_SPI_nCS4_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list FPGA_M0_SPI_nCS5_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list FPGA_M0_SPI_nCS6_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list FPGA_M0_SPI_nCS7_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list FPGA_M0_SPI_nCS8_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list FPGA_M0_SPI_nCS9_]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list FPGA_M0_SPI_nCS10]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list FPGA_M0_SPI_nCS11]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list FPGA_M0_SPI_nCS12]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list FPGA_M0_SPI_TX_EN]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list w_M0_SPI_MISO]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list w_SSPI_TEST_done_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list w_SSPI_TEST_MCLK]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list w_SSPI_TEST_MISO]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list w_SSPI_TEST_MISO_EN]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list w_SSPI_TEST_MOSI]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list w_SSPI_TEST_SCLK]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list w_SSPI_TEST_SS_B]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list w_SSPI_TEST_trig_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list w_SSPI_TEST_trig_init]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_out3_10M]
