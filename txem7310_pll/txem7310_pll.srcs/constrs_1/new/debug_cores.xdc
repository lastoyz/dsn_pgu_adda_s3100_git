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
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz_1_2_0_inst/inst/clk_out1_200M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {w_dac0_data_pin[0]} {w_dac0_data_pin[1]} {w_dac0_data_pin[2]} {w_dac0_data_pin[3]} {w_dac0_data_pin[4]} {w_dac0_data_pin[5]} {w_dac0_data_pin[6]} {w_dac0_data_pin[7]} {w_dac0_data_pin[8]} {w_dac0_data_pin[9]} {w_dac0_data_pin[10]} {w_dac0_data_pin[11]} {w_dac0_data_pin[12]} {w_dac0_data_pin[13]} {w_dac0_data_pin[14]} {w_dac0_data_pin[15]}]]
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
connect_debug_port u_ila_1/clk [get_nets [list clk_wiz_1_2_1_inst/inst/clk_out3_200M_180]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 16 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {w_dac1_data_pin[0]} {w_dac1_data_pin[1]} {w_dac1_data_pin[2]} {w_dac1_data_pin[3]} {w_dac1_data_pin[4]} {w_dac1_data_pin[5]} {w_dac1_data_pin[6]} {w_dac1_data_pin[7]} {w_dac1_data_pin[8]} {w_dac1_data_pin[9]} {w_dac1_data_pin[10]} {w_dac1_data_pin[11]} {w_dac1_data_pin[12]} {w_dac1_data_pin[13]} {w_dac1_data_pin[14]} {w_dac1_data_pin[15]}]]
create_debug_core u_ila_2 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_2]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_2]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_2]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_2]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_2]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_2]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_2]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_2]
set_property port_width 1 [get_debug_ports u_ila_2/clk]
connect_debug_port u_ila_2/clk [get_nets [list clk_wiz_0_2_3_inst/inst/clk_out1_210M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe0]
set_property port_width 2 [get_debug_ports u_ila_2/probe0]
connect_debug_port u_ila_2/probe0 [get_nets [list {adc_wrapper__inst/control_hsadc_dual__inst/serdes[0].serdes_ddr_2lane_in_20bit_out_inst/i_data_s[0]} {adc_wrapper__inst/control_hsadc_dual__inst/serdes[0].serdes_ddr_2lane_in_20bit_out_inst/i_data_s[1]}]]
create_debug_core u_ila_3 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_3]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_3]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_3]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_3]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_3]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_3]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_3]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_3]
set_property port_width 1 [get_debug_ports u_ila_3/clk]
connect_debug_port u_ila_3/clk [get_nets [list clk_wiz_2_2_inst/inst/clk_out1_104M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe0]
set_property port_width 18 [get_debug_ports u_ila_3/probe0]
connect_debug_port u_ila_3/probe0 [get_nets [list {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[0]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[1]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[2]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[3]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[4]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[5]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[6]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[7]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[8]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[9]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[10]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[11]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[12]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[13]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[14]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[15]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[16]} {adc_wrapper__inst/o_hsadc_fifo_adc0_dout[17]}]]
create_debug_core u_ila_4 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_4]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_4]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_4]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_4]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_4]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_4]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_4]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_4]
set_property port_width 1 [get_debug_ports u_ila_4/clk]
connect_debug_port u_ila_4/clk [get_nets [list clk_wiz_0_2_3_inst/inst/clk_out3_60M]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_4/probe0]
set_property port_width 18 [get_debug_ports u_ila_4/probe0]
connect_debug_port u_ila_4/probe0 [get_nets [list {adc_wrapper__inst/o_hsadc_fifo_adc0_din[0]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[1]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[2]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[3]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[4]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[5]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[6]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[7]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[8]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[9]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[10]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[11]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[12]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[13]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[14]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[15]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[16]} {adc_wrapper__inst/o_hsadc_fifo_adc0_din[17]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {DAC0_DAT[0]} {DAC0_DAT[1]} {DAC0_DAT[2]} {DAC0_DAT[3]} {DAC0_DAT[4]} {DAC0_DAT[5]} {DAC0_DAT[6]} {DAC0_DAT[7]} {DAC0_DAT[8]} {DAC0_DAT[9]} {DAC0_DAT[10]} {DAC0_DAT[11]} {DAC0_DAT[12]} {DAC0_DAT[13]} {DAC0_DAT[14]} {DAC0_DAT[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac0]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 16 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {DAC1_DAT[0]} {DAC1_DAT[1]} {DAC1_DAT[2]} {DAC1_DAT[3]} {DAC1_DAT[4]} {DAC1_DAT[5]} {DAC1_DAT[6]} {DAC1_DAT[7]} {DAC1_DAT[8]} {DAC1_DAT[9]} {DAC1_DAT[10]} {DAC1_DAT[11]} {DAC1_DAT[12]} {DAC1_DAT[13]} {DAC1_DAT[14]} {DAC1_DAT[15]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 1 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac1]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe1]
set_property port_width 2 [get_debug_ports u_ila_2/probe1]
connect_debug_port u_ila_2/probe1 [get_nets [list {adc_wrapper__inst/control_hsadc_dual__inst/serdes[1].serdes_ddr_2lane_in_20bit_out_inst/i_data_s[0]} {adc_wrapper__inst/control_hsadc_dual__inst/serdes[1].serdes_ddr_2lane_in_20bit_out_inst/i_data_s[1]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe2]
set_property port_width 1 [get_debug_ports u_ila_2/probe2]
connect_debug_port u_ila_2/probe2 [get_nets [list adc_wrapper__inst/i_hsadc_dco__adc_0]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe3]
set_property port_width 1 [get_debug_ports u_ila_2/probe3]
connect_debug_port u_ila_2/probe3 [get_nets [list adc_wrapper__inst/i_hsadc_dco__adc_1]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe4]
set_property port_width 1 [get_debug_ports u_ila_2/probe4]
connect_debug_port u_ila_2/probe4 [get_nets [list adc_wrapper__inst/o_hsadc_pin_conv]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe5]
set_property port_width 1 [get_debug_ports u_ila_2/probe5]
connect_debug_port u_ila_2/probe5 [get_nets [list adc_wrapper__inst/o_hsadc_pin_sclk]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe1]
set_property port_width 10 [get_debug_ports u_ila_3/probe1]
connect_debug_port u_ila_3/probe1 [get_nets [list {adc_wrapper__inst/i_HSADC_DLY_TAP1[0]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[1]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[2]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[3]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[4]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[5]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[6]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[7]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[8]} {adc_wrapper__inst/i_HSADC_DLY_TAP1[9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe2]
set_property port_width 10 [get_debug_ports u_ila_3/probe2]
connect_debug_port u_ila_3/probe2 [get_nets [list {adc_wrapper__inst/i_HSADC_DLY_TAP0[0]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[1]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[2]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[3]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[4]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[5]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[6]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[7]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[8]} {adc_wrapper__inst/i_HSADC_DLY_TAP0[9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe3]
set_property port_width 32 [get_debug_ports u_ila_3/probe3]
connect_debug_port u_ila_3/probe3 [get_nets [list {adc_wrapper__inst/i_HSADC_SMP_PRD[0]} {adc_wrapper__inst/i_HSADC_SMP_PRD[1]} {adc_wrapper__inst/i_HSADC_SMP_PRD[2]} {adc_wrapper__inst/i_HSADC_SMP_PRD[3]} {adc_wrapper__inst/i_HSADC_SMP_PRD[4]} {adc_wrapper__inst/i_HSADC_SMP_PRD[5]} {adc_wrapper__inst/i_HSADC_SMP_PRD[6]} {adc_wrapper__inst/i_HSADC_SMP_PRD[7]} {adc_wrapper__inst/i_HSADC_SMP_PRD[8]} {adc_wrapper__inst/i_HSADC_SMP_PRD[9]} {adc_wrapper__inst/i_HSADC_SMP_PRD[10]} {adc_wrapper__inst/i_HSADC_SMP_PRD[11]} {adc_wrapper__inst/i_HSADC_SMP_PRD[12]} {adc_wrapper__inst/i_HSADC_SMP_PRD[13]} {adc_wrapper__inst/i_HSADC_SMP_PRD[14]} {adc_wrapper__inst/i_HSADC_SMP_PRD[15]} {adc_wrapper__inst/i_HSADC_SMP_PRD[16]} {adc_wrapper__inst/i_HSADC_SMP_PRD[17]} {adc_wrapper__inst/i_HSADC_SMP_PRD[18]} {adc_wrapper__inst/i_HSADC_SMP_PRD[19]} {adc_wrapper__inst/i_HSADC_SMP_PRD[20]} {adc_wrapper__inst/i_HSADC_SMP_PRD[21]} {adc_wrapper__inst/i_HSADC_SMP_PRD[22]} {adc_wrapper__inst/i_HSADC_SMP_PRD[23]} {adc_wrapper__inst/i_HSADC_SMP_PRD[24]} {adc_wrapper__inst/i_HSADC_SMP_PRD[25]} {adc_wrapper__inst/i_HSADC_SMP_PRD[26]} {adc_wrapper__inst/i_HSADC_SMP_PRD[27]} {adc_wrapper__inst/i_HSADC_SMP_PRD[28]} {adc_wrapper__inst/i_HSADC_SMP_PRD[29]} {adc_wrapper__inst/i_HSADC_SMP_PRD[30]} {adc_wrapper__inst/i_HSADC_SMP_PRD[31]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe4]
set_property port_width 32 [get_debug_ports u_ila_3/probe4]
connect_debug_port u_ila_3/probe4 [get_nets [list {adc_wrapper__inst/i_HSADC_UPD_SMP[0]} {adc_wrapper__inst/i_HSADC_UPD_SMP[1]} {adc_wrapper__inst/i_HSADC_UPD_SMP[2]} {adc_wrapper__inst/i_HSADC_UPD_SMP[3]} {adc_wrapper__inst/i_HSADC_UPD_SMP[4]} {adc_wrapper__inst/i_HSADC_UPD_SMP[5]} {adc_wrapper__inst/i_HSADC_UPD_SMP[6]} {adc_wrapper__inst/i_HSADC_UPD_SMP[7]} {adc_wrapper__inst/i_HSADC_UPD_SMP[8]} {adc_wrapper__inst/i_HSADC_UPD_SMP[9]} {adc_wrapper__inst/i_HSADC_UPD_SMP[10]} {adc_wrapper__inst/i_HSADC_UPD_SMP[11]} {adc_wrapper__inst/i_HSADC_UPD_SMP[12]} {adc_wrapper__inst/i_HSADC_UPD_SMP[13]} {adc_wrapper__inst/i_HSADC_UPD_SMP[14]} {adc_wrapper__inst/i_HSADC_UPD_SMP[15]} {adc_wrapper__inst/i_HSADC_UPD_SMP[16]} {adc_wrapper__inst/i_HSADC_UPD_SMP[17]} {adc_wrapper__inst/i_HSADC_UPD_SMP[18]} {adc_wrapper__inst/i_HSADC_UPD_SMP[19]} {adc_wrapper__inst/i_HSADC_UPD_SMP[20]} {adc_wrapper__inst/i_HSADC_UPD_SMP[21]} {adc_wrapper__inst/i_HSADC_UPD_SMP[22]} {adc_wrapper__inst/i_HSADC_UPD_SMP[23]} {adc_wrapper__inst/i_HSADC_UPD_SMP[24]} {adc_wrapper__inst/i_HSADC_UPD_SMP[25]} {adc_wrapper__inst/i_HSADC_UPD_SMP[26]} {adc_wrapper__inst/i_HSADC_UPD_SMP[27]} {adc_wrapper__inst/i_HSADC_UPD_SMP[28]} {adc_wrapper__inst/i_HSADC_UPD_SMP[29]} {adc_wrapper__inst/i_HSADC_UPD_SMP[30]} {adc_wrapper__inst/i_HSADC_UPD_SMP[31]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe5]
set_property port_width 18 [get_debug_ports u_ila_3/probe5]
connect_debug_port u_ila_3/probe5 [get_nets [list {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[0]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[1]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[2]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[3]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[4]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[5]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[6]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[7]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[8]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[9]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[10]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[11]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[12]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[13]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[14]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[15]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[16]} {adc_wrapper__inst/o_hsadc_fifo_adc1_dout[17]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe6]
set_property port_width 10 [get_debug_ports u_ila_3/probe6]
connect_debug_port u_ila_3/probe6 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_A[0]} {master_spi_mth_brd__inst/i_frame_data_A[1]} {master_spi_mth_brd__inst/i_frame_data_A[2]} {master_spi_mth_brd__inst/i_frame_data_A[3]} {master_spi_mth_brd__inst/i_frame_data_A[4]} {master_spi_mth_brd__inst/i_frame_data_A[5]} {master_spi_mth_brd__inst/i_frame_data_A[6]} {master_spi_mth_brd__inst/i_frame_data_A[7]} {master_spi_mth_brd__inst/i_frame_data_A[8]} {master_spi_mth_brd__inst/i_frame_data_A[9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe7]
set_property port_width 16 [get_debug_ports u_ila_3/probe7]
connect_debug_port u_ila_3/probe7 [get_nets [list {master_spi_mth_brd__inst/o_frame_data_E[0]} {master_spi_mth_brd__inst/o_frame_data_E[1]} {master_spi_mth_brd__inst/o_frame_data_E[2]} {master_spi_mth_brd__inst/o_frame_data_E[3]} {master_spi_mth_brd__inst/o_frame_data_E[4]} {master_spi_mth_brd__inst/o_frame_data_E[5]} {master_spi_mth_brd__inst/o_frame_data_E[6]} {master_spi_mth_brd__inst/o_frame_data_E[7]} {master_spi_mth_brd__inst/o_frame_data_E[8]} {master_spi_mth_brd__inst/o_frame_data_E[9]} {master_spi_mth_brd__inst/o_frame_data_E[10]} {master_spi_mth_brd__inst/o_frame_data_E[11]} {master_spi_mth_brd__inst/o_frame_data_E[12]} {master_spi_mth_brd__inst/o_frame_data_E[13]} {master_spi_mth_brd__inst/o_frame_data_E[14]} {master_spi_mth_brd__inst/o_frame_data_E[15]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe8]
set_property port_width 16 [get_debug_ports u_ila_3/probe8]
connect_debug_port u_ila_3/probe8 [get_nets [list {master_spi_mth_brd__inst/o_frame_data_B[0]} {master_spi_mth_brd__inst/o_frame_data_B[1]} {master_spi_mth_brd__inst/o_frame_data_B[2]} {master_spi_mth_brd__inst/o_frame_data_B[3]} {master_spi_mth_brd__inst/o_frame_data_B[4]} {master_spi_mth_brd__inst/o_frame_data_B[5]} {master_spi_mth_brd__inst/o_frame_data_B[6]} {master_spi_mth_brd__inst/o_frame_data_B[7]} {master_spi_mth_brd__inst/o_frame_data_B[8]} {master_spi_mth_brd__inst/o_frame_data_B[9]} {master_spi_mth_brd__inst/o_frame_data_B[10]} {master_spi_mth_brd__inst/o_frame_data_B[11]} {master_spi_mth_brd__inst/o_frame_data_B[12]} {master_spi_mth_brd__inst/o_frame_data_B[13]} {master_spi_mth_brd__inst/o_frame_data_B[14]} {master_spi_mth_brd__inst/o_frame_data_B[15]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe9]
set_property port_width 16 [get_debug_ports u_ila_3/probe9]
connect_debug_port u_ila_3/probe9 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_D[0]} {master_spi_mth_brd__inst/i_frame_data_D[1]} {master_spi_mth_brd__inst/i_frame_data_D[2]} {master_spi_mth_brd__inst/i_frame_data_D[3]} {master_spi_mth_brd__inst/i_frame_data_D[4]} {master_spi_mth_brd__inst/i_frame_data_D[5]} {master_spi_mth_brd__inst/i_frame_data_D[6]} {master_spi_mth_brd__inst/i_frame_data_D[7]} {master_spi_mth_brd__inst/i_frame_data_D[8]} {master_spi_mth_brd__inst/i_frame_data_D[9]} {master_spi_mth_brd__inst/i_frame_data_D[10]} {master_spi_mth_brd__inst/i_frame_data_D[11]} {master_spi_mth_brd__inst/i_frame_data_D[12]} {master_spi_mth_brd__inst/i_frame_data_D[13]} {master_spi_mth_brd__inst/i_frame_data_D[14]} {master_spi_mth_brd__inst/i_frame_data_D[15]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe10]
set_property port_width 6 [get_debug_ports u_ila_3/probe10]
connect_debug_port u_ila_3/probe10 [get_nets [list {master_spi_mth_brd__inst/i_frame_data_C[0]} {master_spi_mth_brd__inst/i_frame_data_C[1]} {master_spi_mth_brd__inst/i_frame_data_C[2]} {master_spi_mth_brd__inst/i_frame_data_C[3]} {master_spi_mth_brd__inst/i_frame_data_C[4]} {master_spi_mth_brd__inst/i_frame_data_C[5]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe11]
set_property port_width 10 [get_debug_ports u_ila_3/probe11]
connect_debug_port u_ila_3/probe11 [get_nets [list {slave_spi_mth_brd__M2_inst/r_frame_adrs[0]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[1]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[2]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[3]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[4]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[5]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[6]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[7]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[8]} {slave_spi_mth_brd__M2_inst/r_frame_adrs[9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe12]
set_property port_width 16 [get_debug_ports u_ila_3/probe12]
connect_debug_port u_ila_3/probe12 [get_nets [list {slave_spi_mth_brd__M2_inst/r_frame_mosi[0]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[1]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[2]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[3]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[4]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[5]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[6]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[7]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[8]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[9]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[10]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[11]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[12]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[13]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[14]} {slave_spi_mth_brd__M2_inst/r_frame_mosi[15]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe13]
set_property port_width 6 [get_debug_ports u_ila_3/probe13]
connect_debug_port u_ila_3/probe13 [get_nets [list {slave_spi_mth_brd__M2_inst/r_frame_ctrl[0]} {slave_spi_mth_brd__M2_inst/r_frame_ctrl[1]} {slave_spi_mth_brd__M2_inst/r_frame_ctrl[2]} {slave_spi_mth_brd__M2_inst/r_frame_ctrl[3]} {slave_spi_mth_brd__M2_inst/r_frame_ctrl[4]} {slave_spi_mth_brd__M2_inst/r_frame_ctrl[5]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe14]
set_property port_width 16 [get_debug_ports u_ila_3/probe14]
connect_debug_port u_ila_3/probe14 [get_nets [list {slave_spi_mth_brd__M2_inst/r_frame_miso[0]} {slave_spi_mth_brd__M2_inst/r_frame_miso[1]} {slave_spi_mth_brd__M2_inst/r_frame_miso[2]} {slave_spi_mth_brd__M2_inst/r_frame_miso[3]} {slave_spi_mth_brd__M2_inst/r_frame_miso[4]} {slave_spi_mth_brd__M2_inst/r_frame_miso[5]} {slave_spi_mth_brd__M2_inst/r_frame_miso[6]} {slave_spi_mth_brd__M2_inst/r_frame_miso[7]} {slave_spi_mth_brd__M2_inst/r_frame_miso[8]} {slave_spi_mth_brd__M2_inst/r_frame_miso[9]} {slave_spi_mth_brd__M2_inst/r_frame_miso[10]} {slave_spi_mth_brd__M2_inst/r_frame_miso[11]} {slave_spi_mth_brd__M2_inst/r_frame_miso[12]} {slave_spi_mth_brd__M2_inst/r_frame_miso[13]} {slave_spi_mth_brd__M2_inst/r_frame_miso[14]} {slave_spi_mth_brd__M2_inst/r_frame_miso[15]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe15]
set_property port_width 1 [get_debug_ports u_ila_3/probe15]
connect_debug_port u_ila_3/probe15 [get_nets [list adc_wrapper__inst/i_hsadc_en]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe16]
set_property port_width 1 [get_debug_ports u_ila_3/probe16]
connect_debug_port u_ila_3/probe16 [get_nets [list adc_wrapper__inst/i_hsadc_fifo_adc0_rd_en]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe17]
set_property port_width 1 [get_debug_ports u_ila_3/probe17]
connect_debug_port u_ila_3/probe17 [get_nets [list adc_wrapper__inst/i_hsadc_fifo_adc1_rd_en]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe18]
set_property port_width 1 [get_debug_ports u_ila_3/probe18]
connect_debug_port u_ila_3/probe18 [get_nets [list adc_wrapper__inst/i_hsadc_fifo_rst]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe19]
set_property port_width 1 [get_debug_ports u_ila_3/probe19]
connect_debug_port u_ila_3/probe19 [get_nets [list adc_wrapper__inst/i_hsadc_init]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe20]
set_property port_width 1 [get_debug_ports u_ila_3/probe20]
connect_debug_port u_ila_3/probe20 [get_nets [list adc_wrapper__inst/i_hsadc_reset]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe21]
set_property port_width 1 [get_debug_ports u_ila_3/probe21]
connect_debug_port u_ila_3/probe21 [get_nets [list adc_wrapper__inst/i_hsadc_test]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe22]
set_property port_width 1 [get_debug_ports u_ila_3/probe22]
connect_debug_port u_ila_3/probe22 [get_nets [list adc_wrapper__inst/i_hsadc_update]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe23]
set_property port_width 1 [get_debug_ports u_ila_3/probe23]
connect_debug_port u_ila_3/probe23 [get_nets [list slave_spi_mth_brd__M2_inst/i_SPI_CLK]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe24]
set_property port_width 1 [get_debug_ports u_ila_3/probe24]
connect_debug_port u_ila_3/probe24 [get_nets [list slave_spi_mth_brd__M2_inst/i_SPI_CS_B]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe25]
set_property port_width 1 [get_debug_ports u_ila_3/probe25]
connect_debug_port u_ila_3/probe25 [get_nets [list slave_spi_mth_brd__M2_inst/i_SPI_MOSI]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe26]
set_property port_width 1 [get_debug_ports u_ila_3/probe26]
connect_debug_port u_ila_3/probe26 [get_nets [list master_spi_mth_brd__inst/i_trig_frame]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe27]
set_property port_width 1 [get_debug_ports u_ila_3/probe27]
connect_debug_port u_ila_3/probe27 [get_nets [list master_spi_mth_brd__inst/i_trig_init]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe28]
set_property port_width 1 [get_debug_ports u_ila_3/probe28]
connect_debug_port u_ila_3/probe28 [get_nets [list master_spi_mth_brd__inst/o_done_frame]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe29]
set_property port_width 1 [get_debug_ports u_ila_3/probe29]
connect_debug_port u_ila_3/probe29 [get_nets [list master_spi_mth_brd__inst/o_done_init]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe30]
set_property port_width 1 [get_debug_ports u_ila_3/probe30]
connect_debug_port u_ila_3/probe30 [get_nets [list adc_wrapper__inst/o_hsadc_init_done]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe31]
set_property port_width 1 [get_debug_ports u_ila_3/probe31]
connect_debug_port u_ila_3/probe31 [get_nets [list adc_wrapper__inst/o_hsadc_init_done_to]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe32]
set_property port_width 1 [get_debug_ports u_ila_3/probe32]
connect_debug_port u_ila_3/probe32 [get_nets [list adc_wrapper__inst/o_hsadc_pin_test]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe33]
set_property port_width 1 [get_debug_ports u_ila_3/probe33]
connect_debug_port u_ila_3/probe33 [get_nets [list adc_wrapper__inst/o_hsadc_test_done]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe34]
set_property port_width 1 [get_debug_ports u_ila_3/probe34]
connect_debug_port u_ila_3/probe34 [get_nets [list adc_wrapper__inst/o_hsadc_test_done_to]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe35]
set_property port_width 1 [get_debug_ports u_ila_3/probe35]
connect_debug_port u_ila_3/probe35 [get_nets [list adc_wrapper__inst/o_hsadc_update_done]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe36]
set_property port_width 1 [get_debug_ports u_ila_3/probe36]
connect_debug_port u_ila_3/probe36 [get_nets [list adc_wrapper__inst/o_hsadc_update_done_to]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe37]
set_property port_width 1 [get_debug_ports u_ila_3/probe37]
connect_debug_port u_ila_3/probe37 [get_nets [list slave_spi_mth_brd__M2_inst/o_SPI_MISO]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe38]
set_property port_width 1 [get_debug_ports u_ila_3/probe38]
connect_debug_port u_ila_3/probe38 [get_nets [list slave_spi_mth_brd__M2_inst/o_SPI_MISO_EN]]
create_debug_port u_ila_4 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_4/probe1]
set_property port_width 18 [get_debug_ports u_ila_4/probe1]
connect_debug_port u_ila_4/probe1 [get_nets [list {adc_wrapper__inst/o_hsadc_fifo_adc1_din[0]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[1]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[2]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[3]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[4]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[5]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[6]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[7]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[8]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[9]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[10]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[11]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[12]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[13]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[14]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[15]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[16]} {adc_wrapper__inst/o_hsadc_fifo_adc1_din[17]}]]
create_debug_port u_ila_4 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_4/probe2]
set_property port_width 1 [get_debug_ports u_ila_4/probe2]
connect_debug_port u_ila_4/probe2 [get_nets [list adc_wrapper__inst/o_hsadc_fifo_adc0_wr_ack]]
create_debug_port u_ila_4 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_4/probe3]
set_property port_width 1 [get_debug_ports u_ila_4/probe3]
connect_debug_port u_ila_4/probe3 [get_nets [list adc_wrapper__inst/o_hsadc_fifo_adc1_wr_ack]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets adc_fifo_clk]
