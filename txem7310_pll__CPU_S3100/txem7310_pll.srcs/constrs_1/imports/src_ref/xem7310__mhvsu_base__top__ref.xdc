############################################################################
# XEM7310 - Xilinx constraints file
#   XC7A200T-1FBG484
#   https://www.xilinx.com/support/packagefiles/a7packages/xc7a200tfbg484pkg.txt
# Pin mappings for the XEM7310.
#
# this           : xem7310__mhvsu_base__top.xdc
# top verilog    : xem7310__mhvsu_base__top.v
# FPGA board     : TXEM7310-FPGA-CORE
# FPGA board sch : FPGA_MODULE_V11_20200812-4M.pdf
# base on socket : MHVSU-BASE-REV2 (BN: MHVSU BASE BOARD, PN: 1B003-B0301, RN: 0.2)
# base sch       : MHVSU_BASE_BRD_REV02__R0807.pdf
#
############################################################################

#### config #################################################################
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

## XDC command for SPIx4 config mode  
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

############################################################################


############################################################################
## TODO: System Clock
############################################################################
##$$ bank 13
set_property PACKAGE_PIN W12 [get_ports sys_clkn]
set_property PACKAGE_PIN W11 [get_ports sys_clkp]
set_property IOSTANDARD LVDS_25 [get_ports sys_clkp]
set_property IOSTANDARD LVDS_25 [get_ports sys_clkn]

##$$ 200MHz 5ns // without pll
##$$create_clock -period 5.000 -name sys_clk [get_ports sys_clkp]
##

## define clock - sys_clk // from pll
create_generated_clock  -name sys_clk         [get_pins  clk_wiz_2_0_inst/inst/plle2_adv_inst/CLKOUT0]

##  ## define clock - okHI_clk
##  create_generated_clock  -name okHI_clk        [get_pins  ok_endpoint_wrapper_inst/okHI/mmcm0/CLKOUT0]

## define clock - mcs_clk
create_generated_clock  -name mcs_clk         [get_pins  clk_wiz_2_1_inst/inst/plle2_adv_inst/CLKOUT0]

## define clock - lan_clk
create_generated_clock  -name lan_clk         [get_pins  clk_wiz_2_1_inst/inst/plle2_adv_inst/CLKOUT1]

## define clock - base_sspi_clk
create_generated_clock  -name base_sspi_clk   [get_pins  clk_wiz_2_2_inst/inst/plle2_adv_inst/CLKOUT0]

## define clock - base_adc_clk
create_generated_clock  -name base_adc_clk    [get_pins  clk_wiz_2_3_inst/inst/plle2_adv_inst/CLKOUT0]

## define clock - p_adc_clk      # adc parallel data clock # fifo write clk
create_generated_clock  -name p_adc_clk       [get_pins  clk_wiz_2_3_inst/inst/plle2_adv_inst/CLKOUT1]

## define clock - m_fifo_rd_clk  # fifo read clk muxed with USB and sspi
# create_generated_clock  -name m_fifo_rd_clk   [get_pins  bufgmux_c_f_clk_inst/O] # not allowed

# clock interactions
set_clock_groups -asynchronous -group [get_clocks  sys_clk]       -group [get_clocks  {base_sspi_clk}]
set_clock_groups -asynchronous -group [get_clocks  sys_clk]       -group [get_clocks  {base_adc_clk}]
set_clock_groups -asynchronous -group [get_clocks  sys_clk]       -group [get_clocks  {mcs_clk}]
set_clock_groups -asynchronous -group [get_clocks  sys_clk]       -group [get_clocks  {lan_clk}]

set_clock_groups -asynchronous -group [get_clocks  mcs_clk]       -group [get_clocks  {base_sspi_clk}]
set_clock_groups -asynchronous -group [get_clocks  mcs_clk]       -group [get_clocks  {base_adc_clk}]

set_clock_groups -asynchronous -group [get_clocks  lan_clk]       -group [get_clocks  {base_sspi_clk}]
set_clock_groups -asynchronous -group [get_clocks  lan_clk]       -group [get_clocks  {base_adc_clk}]

set_clock_groups -asynchronous -group [get_clocks  base_sspi_clk] -group [get_clocks  {base_adc_clk} ]

set_clock_groups -asynchronous -group [get_clocks  p_adc_clk]     -group [get_clocks  {sys_clk} ]
set_clock_groups -asynchronous -group [get_clocks  p_adc_clk]     -group [get_clocks  {base_sspi_clk} ]

############################################################################



#### TXEM7310 interface includes LAN / TP / ADC_AUX.

###########################################################################
## TODO: LAN 
###########################################################################

## LAN for END-POINTS : on FPGA module ##
# H17  o_B15_L6P  EP_LAN_PWDN 
# J22  o_B15_L7P  EP_LAN_MOSI
# H22  o_B15_L7N  EP_LAN_SCLK
# H20  o_B15_L8P  EP_LAN_CS_B
# G20  i_B15_L8N  EP_LAN_INT_B
# K21  o_B15_L9P  EP_LAN_RST_B
# K22  i_B15_L9N  EP_LAN_MISO
set_property PACKAGE_PIN  H17  [get_ports  o_B15_L6P ] 
set_property PACKAGE_PIN  J22  [get_ports  o_B15_L7P ] 
set_property PACKAGE_PIN  H22  [get_ports  o_B15_L7N ] 
set_property PACKAGE_PIN  H20  [get_ports  o_B15_L8P ] 
set_property PACKAGE_PIN  G20  [get_ports  i_B15_L8N ] 
set_property PACKAGE_PIN  K21  [get_ports  o_B15_L9P ] 
set_property PACKAGE_PIN  K22  [get_ports  i_B15_L9N ] 

## rev mcs_clk-->lan_clk
set_input_delay -clock [get_clocks lan_clk] -max -add_delay 3.500 [get_ports i_B15_L9N] 
set_input_delay -clock [get_clocks lan_clk] -min -add_delay 1.000 [get_ports i_B15_L9N] 
set_max_delay  18.000  -from [get_ports i_B15_L8N] 
set_min_delay   0.000  -from [get_ports i_B15_L8N] 
set_max_delay  18.000    -to [get_ports {{o_B15_L9P} {o_B15_L6P}}]  
set_max_delay   6.900    -to [get_ports {{o_B15_L7P} {o_B15_L7N} {o_B15_L8P}}]  


## LAN alternative : on BASE ##
# o_B13_L11N_SRCC   PT_BASE_EP_LAN_MOSI 
# o_B13_L6N         PT_BASE_EP_LAN_SCLK 
# o_B13_L6P         PT_BASE_EP_LAN_CS_B 
# i_B13_L13P_MRCC   PT_BASE_EP_LAN_INT_B
# o_B13_L15P        PT_BASE_EP_LAN_RST_B
# i_B13_L15N        PT_BASE_EP_LAN_MISO 

## rev
#set_input_delay -clock [get_clocks lan_clk] -max -add_delay 3.500 [get_ports i_B13_L15N] # NG lan miso data
set_input_delay -clock [get_clocks lan_clk] -max -add_delay 2.500 [get_ports i_B13_L15N] 
set_input_delay -clock [get_clocks lan_clk] -min -add_delay 1.000 [get_ports i_B13_L15N] 
set_max_delay  18.000  -from [get_ports i_B13_L13P_MRCC] 
set_min_delay   0.000  -from [get_ports i_B13_L13P_MRCC] 
set_max_delay  18.000    -to [get_ports o_B13_L15P]  
set_max_delay  13.100    -to [get_ports {{o_B13_L11N_SRCC} {o_B13_L6N} {o_B13_L6P}}]  

## relax  w_MCS_SETUP_WI[10]
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__port_wi_11/r_port_wi_00_reg[*]*/C}] 
## relax wires
# wire [15:0] w_offset_lan_timeout_rtr_16b = ep00wire[31:16]; // assign later 
# wire [15:0] w_offset_lan_timeout_rcr_16b = ep00wire[15: 0]; // assign later 
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_00/r_port_wi_00_reg[*]/C}] 
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_01/r_port_wi_00_reg[*]/C}] 

###########################################################################


###########################################################################
## TODO: TP 
###########################################################################
# H13  io_B15_L1P  TP0
# G13  io_B15_L1N  TP1
# G15  io_B15_L2P  TP2
# G16  io_B15_L2N  TP3
# J14  io_B15_L3P  TP4
# H14  io_B15_L3N  TP5
# J15  io_B15_L5P  TP6
# H15  io_B15_L5N  TP7
set_property PACKAGE_PIN  H13  [get_ports  io_B15_L1P ]
set_property PACKAGE_PIN  G13  [get_ports  io_B15_L1N ]
set_property PACKAGE_PIN  G15  [get_ports  io_B15_L2P ]
set_property PACKAGE_PIN  G16  [get_ports  io_B15_L2N ]
set_property PACKAGE_PIN  J14  [get_ports  io_B15_L3P ]
set_property PACKAGE_PIN  H14  [get_ports  io_B15_L3N ]
set_property PACKAGE_PIN  J15  [get_ports  io_B15_L5P ]
set_property PACKAGE_PIN  H15  [get_ports  io_B15_L5N ]

set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L1P] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L1N] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L2P] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L2N] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L3P] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L3N] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L5P] 
set_input_delay  -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L5N] 

set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L1P]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L1N]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L2P]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L2N]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L3P]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L3N]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L5P]
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports io_B15_L5N]

## #set_property PULLUP true [get_ports io_B15_L2P]

###########################################################################


###########################################################################
## TODO: ADC_AUX 
###########################################################################

# M21  i_B15_L10P  AUX_AD11P
# L21  i_B15_L10N  AUX_AD11N
set_property PACKAGE_PIN  M21  [get_ports  i_B15_L10P ]
set_property PACKAGE_PIN  L21  [get_ports  i_B15_L10N ]

###########################################################################


############################################################################
## TODO: Slave SPI delays
############################################################################

#IBUF ibuf__M0_SPI_CS_B_BUF_inst (.I(i_B34_L2P       ), .O(M0_SPI_CS_B_BUF  ) ); //
#IBUF ibuf__M0_SPI_CLK______inst (.I(i_B34_L2N       ), .O(M0_SPI_CLK       ) ); //
#OBUF obuf__M0_SPI_SCLK_____inst (.O(o_B34_L1P       ), .I(M0_SPI_SCLK      ) ); //$$ REV2
#IBUF ibuf__M0_SPI_MOSI_____inst (.I(i_B34_L4P       ), .O(M0_SPI_MOSI      ) ); //
#OBUF obuf__M0_SPI_MISO_____inst (.O(o_B34_L4N       ), .I(M0_SPI_MISO      ) ); // 
#OBUF obuf__M0_SPI_MISO_EN__inst (.O(o_B34_L24P      ), .I(M0_SPI_MISO_EN   ) ); //$$ o_B34_L1P --> o_B34_L24P //$$ REV2
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L2P]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L2P]
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L2N]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L2N]
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L4P]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L4P]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L4N] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L4N]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L1P] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L1P]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L24P] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L24P]
##
#IBUF ibuf__M1_SPI_CS_B_BUF_inst (.I(i_B34_L1N       ), .O(M1_SPI_CS_B_BUF  ) ); //
#IBUF ibuf__M1_SPI_CLK______inst (.I(i_B34_L7P       ), .O(M1_SPI_CLK       ) ); //
#OBUF obuf__M1_SPI_SCLK_____inst (.O(o_B34_L12N_MRCC ), .I(M1_SPI_SCLK      ) ); //$$ REV2
#IBUF ibuf__M1_SPI_MOSI_____inst (.I(i_B34_L7N       ), .O(M1_SPI_MOSI      ) ); //
#OBUF obuf__M1_SPI_MISO_____inst (.O(o_B34_L12P_MRCC ), .I(M1_SPI_MISO      ) ); // 
#OBUF obuf__M1_SPI_MISO_EN__inst (.O(o_B34_L24N      ), .I(M1_SPI_MISO_EN   ) ); //$$ o_B34_L12N_MRCC --> o_B34_L24N //$$ REV2
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L1N]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L1N]
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L7P]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L7P]
set_input_delay  -clock [get_clocks base_sspi_clk] -max -add_delay 1.500 [get_ports i_B34_L7N]
set_input_delay  -clock [get_clocks base_sspi_clk] -min -add_delay 1.000 [get_ports i_B34_L7N]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L12P_MRCC] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L12P_MRCC]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L12N_MRCC] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L12N_MRCC]
set_output_delay -clock [get_clocks base_sspi_clk] -max -add_delay 0.200 [get_ports o_B34_L24N] 
set_output_delay -clock [get_clocks base_sspi_clk] -min -add_delay 0.000 [get_ports o_B34_L24N]
# some relax
##  set_false_path -from [get_pins {slave_spi_mth_brd__M0_inst/r_port_wi_sadrs_*/C}] 
##  set_false_path -from [get_pins {slave_spi_mth_brd__M1_inst/r_port_wi_sadrs_*/C}] 

############################################################################


############################################################################
## TODO: ADC delays 
############################################################################

#OBUFDS obufds__ADCx_CNV_inst (.O(o_B34D_L17P), .OB(o_B34D_L17N), .I(ADCx_CNV)	);
#set_output_delay -clock [get_clocks base_adc_clk] -max -add_delay -5.150 [get_ports o_B34D_L17P] 
#set_output_delay -clock [get_clocks base_adc_clk] -min -add_delay -7.150 [get_ports o_B34D_L17P]
#set_multicycle_path -setup 2 -from [get_clocks base_adc_clk]         -to [get_ports o_B34D_L17P]
#set_output_delay -clock [get_clocks base_adc_clk] 0.000                  [get_ports o_B34D_L17P] # 3.9 total measured
#set_max_delay                                                         -to [get_ports o_B34D_L17P] 8.850
set_max_delay                                                         -to [get_ports o_B34D_L17P] 9.250
#OBUFDS obufds__ADCx_SCK_inst (.O(o_B34D_L16P), .OB(o_B34D_L16N), .I(ADCx_SCK)	);
#set_output_delay -clock [get_clocks base_adc_clk] -max -add_delay -5.150 [get_ports o_B34D_L16P] 
#set_output_delay -clock [get_clocks base_adc_clk] -min -add_delay -7.150 [get_ports o_B34D_L16P]
#set_multicycle_path -setup 2 -from [get_clocks base_adc_clk]         -to [get_ports o_B34D_L16P]
#set_output_delay -clock [get_clocks base_adc_clk] 0.000                  [get_ports o_B34D_L16P]
set_max_delay                                                         -to [get_ports o_B34D_L16P] 8.750
#IBUFDS ibufds__ADC0_SDOD_inst (.I(i_B34D_L21P     ), .IB(i_B34D_L21N     ), .O(ADC0_SDOD_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L21P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L21P]
#IBUFDS ibufds__ADC0_SDOC_inst (.I(i_B34D_L19P     ), .IB(i_B34D_L19N     ), .O(ADC0_SDOC_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L19P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L19P]
#IBUFDS ibufds__ADC0_SDOB_inst (.I(i_B34D_L23P     ), .IB(i_B34D_L23N     ), .O(ADC0_SDOB_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L23P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L23P]
#IBUFDS ibufds__ADC0_SDOA_inst (.I(i_B34D_L15P     ), .IB(i_B34D_L15N     ), .O(ADC0_SDOA_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L15P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L15P]
#IBUFDS ibufds__ADC0_DCO__inst (.I(c_B34D_L13P_MRCC), .IB(c_B34D_L13N_MRCC), .O(ADC0_DCO__B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.600 [get_ports c_B34D_L13P_MRCC]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.100 [get_ports c_B34D_L13P_MRCC]
#IBUFDS ibufds__ADC1_DCO__inst (.I(c_B34D_L14P_SRCC), .IB(c_B34D_L14N_SRCC), .O(ADC1_DCO_) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.600 [get_ports c_B34D_L14P_SRCC]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.100 [get_ports c_B34D_L14P_SRCC]
#IBUFDS ibufds__ADC1_SDOA_inst (.I(i_B34D_L10P     ), .IB(i_B34D_L10N     ), .O(ADC1_SDOA) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L10P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L10P]
#IBUFDS ibufds__ADC1_SDOB_inst (.I(i_B34D_L20P     ), .IB(i_B34D_L20N     ), .O(ADC1_SDOB) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L20P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L20P]
#IBUFDS ibufds__ADC1_SDOC_inst (.I(i_B34D_L3P      ), .IB(i_B34D_L3N      ), .O(ADC1_SDOC) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L3P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L3P]
#IBUFDS ibufds__ADC1_SDOD_inst (.I(i_B34D_L9P      ), .IB(i_B34D_L9N      ), .O(ADC1_SDOD) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B34D_L9P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B34D_L9P]
#IBUFDS ibufds__ADC2_SDOD_inst (.I(i_B35D_L22P     ), .IB(i_B35D_L22N     ), .O(ADC2_SDOD_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L22P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L22P]
#IBUFDS ibufds__ADC2_SDOC_inst (.I(i_B35D_L20P     ), .IB(i_B35D_L20N     ), .O(ADC2_SDOC_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L20P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L20P]
#IBUFDS ibufds__ADC2_SDOB_inst (.I(i_B35D_L16P     ), .IB(i_B35D_L16N     ), .O(ADC2_SDOB_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L16P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L16P]
#IBUFDS ibufds__ADC2_SDOA_inst (.I(i_B35D_L17P     ), .IB(i_B35D_L17N     ), .O(ADC2_SDOA_B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L17P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L17P]
#IBUFDS ibufds__ADC2_DCO__inst (.I(c_B35D_L14P_SRCC), .IB(c_B35D_L14N_SRCC), .O(ADC2_DCO__B) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.600 [get_ports c_B35D_L14P_SRCC]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.100 [get_ports c_B35D_L14P_SRCC]
#IBUFDS ibufds__ADC3_SDOA_inst (.I(i_B35D_L23P     ), .IB(i_B35D_L23N     ), .O(ADC3_SDOA) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L23P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L23P]
#IBUFDS ibufds__ADC3_SDOB_inst (.I(i_B35D_L15P     ), .IB(i_B35D_L15N     ), .O(ADC3_SDOB) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L15P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L15P]
#IBUFDS ibufds__ADC3_SDOC_inst (.I(i_B35D_L9P      ), .IB(i_B35D_L9N      ), .O(ADC3_SDOC) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L9P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L9P]
#IBUFDS ibufds__ADC3_SDOD_inst (.I(i_B35D_L7P      ), .IB(i_B35D_L7N      ), .O(ADC3_SDOD) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.400 [get_ports i_B35D_L7P]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.000 [get_ports i_B35D_L7P]
#IBUFDS ibufds__ADC3_DCO__inst (.I(c_B35D_L11P_SRCC), .IB(c_B35D_L11N_SRCC), .O(ADC3_DCO_) );
set_input_delay  -clock [get_clocks base_adc_clk] -max -add_delay 1.600 [get_ports c_B35D_L11P_SRCC]
set_input_delay  -clock [get_clocks base_adc_clk] -min -add_delay 1.100 [get_ports c_B35D_L11P_SRCC]

## relax : w_ADC_CON_WI
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__port_wi_07/r_port_wi_00_reg[*]/C}] 

############################################################################


############################################################################
## TODO: LEDs 
############################################################################
##$$ bank 16
# LED0 A13   IO_L10P_T1_16
set_property PACKAGE_PIN A13 [get_ports {led[0]}]
# LED1 B13   IO_L8N_T1_16
set_property PACKAGE_PIN B13 [get_ports {led[1]}]
# LED2 A14   IO_L10N_T1_16
set_property PACKAGE_PIN A14 [get_ports {led[2]}]
# LED3 A15   IO_L9P_T1_DQS_16
set_property PACKAGE_PIN A15 [get_ports {led[3]}]
# LED4 B15   IO_L7P_T1_16
set_property PACKAGE_PIN B15 [get_ports {led[4]}]
# LED5 A16   IO_L9N_T1_DQS_16
set_property PACKAGE_PIN A16 [get_ports {led[5]}]
# LED6 B16   IO_L7N_T1_16
set_property PACKAGE_PIN B16 [get_ports {led[6]}]
# LED7 B17   IO_L11P_T1_SRCC_16
set_property PACKAGE_PIN B17 [get_ports {led[7]}]

## LVCMOS15 --> LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# for led
set_output_delay -clock [get_clocks  sys_clk] 0.0 [get_ports {led[*]}]

############################################################################


############################################################################
## TODO: IO delays common 
############################################################################

## B13 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B13*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B13*]
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B13*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B13*]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports  o_B13_* ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports io_B13_* ]

## B35 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B35*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B35*]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports c_B35*]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports c_B35*]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B35*]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B35*]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_* ]

## B34 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B34*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B34*]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports c_B34*]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports c_B34*]
#set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B34*]
#set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B34*]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B34_* ]

############################################################################


############################################################################
## TODO: BANKS IN CONNECTORS 
############################################################################

##
# MC1-15  # RES_NET_2 --> M0_SPI_MISO_EN # REV2
set_property PACKAGE_PIN W9   [get_ports o_B34_L24P       ]  
# MC1-17  # RES_NET_3 --> M1_SPI_MISO_EN # REV2
set_property PACKAGE_PIN Y9   [get_ports o_B34_L24N       ]  
# MC1-19  # ADCx_CNV_P       
set_property PACKAGE_PIN R6   [get_ports o_B34D_L17P      ]  
# MC1-21  # ADCx_CNV_N       
set_property PACKAGE_PIN T6   [get_ports o_B34D_L17N      ]  
# MC1-23  # ADCx_SCK_P       
set_property PACKAGE_PIN U6   [get_ports o_B34D_L16P      ]  
# MC1-25  # ADCx_SCK_N       
set_property PACKAGE_PIN V5   [get_ports o_B34D_L16N      ]  
# MC1-27  # ADC1_DCO_P       
set_property PACKAGE_PIN T5   [get_ports c_B34D_L14P_SRCC ]  
# MC1-29  # ADC1_DCO_N       
set_property PACKAGE_PIN U5   [get_ports c_B34D_L14N_SRCC ]  
# MC1-31  # ADC1_SDOA_P      
set_property PACKAGE_PIN AA5  [get_ports i_B34D_L10P      ]  
# MC1-33  # ADC1_SDOA_N      
set_property PACKAGE_PIN AB5  [get_ports i_B34D_L10N      ]  
# MC1-35  # DGND             GND                                                           
# MC1-37  # ADC1_SDOB_P      
set_property PACKAGE_PIN AB7  [get_ports i_B34D_L20P      ]  
# MC1-39  # ADC1_SDOB_N      
set_property PACKAGE_PIN AB6  [get_ports i_B34D_L20N      ]  
# MC1-41  # ADC1_SDOC_P      
set_property PACKAGE_PIN R3   [get_ports i_B34D_L3P       ]  
# MC1-43  # ADC1_SDOC_N      
set_property PACKAGE_PIN R2   [get_ports i_B34D_L3N       ]  
# MC1-45  # ADC1_SDOD_P      
set_property PACKAGE_PIN Y3   [get_ports i_B34D_L9P       ]  
# MC1-47  # ADC1_SDOD_N      
set_property PACKAGE_PIN AA3  [get_ports i_B34D_L9N       ]  
# MC1-49  # M0_SPI_CS_B_BUF  
set_property PACKAGE_PIN U2   [get_ports i_B34_L2P        ]  
# MC1-51  # M0_SPI_CLK       
set_property PACKAGE_PIN V2   [get_ports i_B34_L2N        ]  
# MC1-53  # M0_SPI_MOSI      
set_property PACKAGE_PIN W2   [get_ports i_B34_L4P        ]  
# MC1-55  # DGND             GND                                                           
# MC1-57  # M0_SPI_MISO      
set_property PACKAGE_PIN Y2   [get_ports o_B34_L4N        ]  
# MC1-59  # M0_SPI_MISO_EN   
set_property PACKAGE_PIN T1   [get_ports o_B34_L1P        ]  
# MC1-61  # M1_SPI_CS_B_BUF  
set_property PACKAGE_PIN U1   [get_ports i_B34_L1N        ]  
# MC1-63  # M1_SPI_CLK       
set_property PACKAGE_PIN AA1  [get_ports i_B34_L7P        ]  
# MC1-65  # M1_SPI_MOSI      
set_property PACKAGE_PIN AB1  [get_ports i_B34_L7N        ]  
# MC1-67  # EXT_SPx_MOSI     
set_property PACKAGE_PIN AB16 [get_ports o_B13_L2P        ]  
# MC1-69  # EXT_SPx_SCLK     
set_property PACKAGE_PIN AB17 [get_ports o_B13_L2N        ]  
# MC1-71  # EXT_SPx_MISO     
set_property PACKAGE_PIN AA15 [get_ports i_B13_L4P        ]  
# MC1-73  # EXT_SP0_CS_B     
set_property PACKAGE_PIN AB15 [get_ports o_B13_L4N        ]  
# MC1-75  # EXT_SP1_CS_B     
set_property PACKAGE_PIN Y16  [get_ports o_B13_L1P        ]  
# MC1-77  # M1_SPI_MISO      
set_property PACKAGE_PIN V4   [get_ports o_B34_L12P_MRCC  ]  
# MC1-79  # M1_SPI_MISO_EN   
set_property PACKAGE_PIN W4   [get_ports o_B34_L12N_MRCC  ]  


####
# MC1-8   # RES_NET_0     
set_property PACKAGE_PIN AB11 [get_ports o_B13_SYS_CLK_MC1   ]
# MC1-10  #               
set_property PACKAGE_PIN M9   [get_ports i_XADC_VN           ]
# MC1-12  #               
set_property PACKAGE_PIN L10  [get_ports i_XADC_VP           ]
# MC1-14  GND                                                                          
# MC1-16  # ADC0_SDOD_N   
set_property PACKAGE_PIN V9   [get_ports i_B34D_L21P         ]  
# MC1-18  # ADC0_SDOD_P   
set_property PACKAGE_PIN V8   [get_ports i_B34D_L21N         ]  
# MC1-20  # ADC0_SDOC_N   
set_property PACKAGE_PIN V7   [get_ports i_B34D_L19P         ]  
# MC1-22  # ADC0_SDOC_P   
set_property PACKAGE_PIN W7   [get_ports i_B34D_L19N         ]  
# MC1-24  # ADC0_SDOB_N   
set_property PACKAGE_PIN Y8   [get_ports i_B34D_L23P         ]  
# MC1-26  # ADC0_SDOB_P   
set_property PACKAGE_PIN Y7   [get_ports i_B34D_L23N         ]  
# MC1-28  # ADC0_SDOA_N   
set_property PACKAGE_PIN W6   [get_ports i_B34D_L15P         ]  
# MC1-30  # ADC0_SDOA_P   
set_property PACKAGE_PIN W5   [get_ports i_B34D_L15N         ]  
# MC1-32  # ADC0_DCO_N    
set_property PACKAGE_PIN R4   [get_ports c_B34D_L13P_MRCC    ]  
# MC1-34  # ADC0_DCO_P    
set_property PACKAGE_PIN T4   [get_ports c_B34D_L13N_MRCC    ]  
# MC1-36  # MC1_VCCO      VCCO                                                             
# MC1-38  # DAC1_SCK      
set_property PACKAGE_PIN Y4   [get_ports o_B34_L11P_SRCC     ]  
# MC1-40  # DAC1_MOSI     
set_property PACKAGE_PIN AA4  [get_ports o_B34_L11N_SRCC     ]  
# MC1-42  # DAC1_MISO     
set_property PACKAGE_PIN Y6   [get_ports i_B34_L18P          ]  
# MC1-44  # DAC1_SYNC_B   
set_property PACKAGE_PIN AA6  [get_ports o_B34_L18N          ]  
# MC1-46  # DAC0_SCK      
set_property PACKAGE_PIN AA8  [get_ports o_B34_L22P          ]  
# MC1-48  # DAC0_MOSI     
set_property PACKAGE_PIN AB8  [get_ports o_B34_L22N          ]  
# MC1-50  # DAC0_MISO     
set_property PACKAGE_PIN U3   [get_ports i_B34_L6P           ]  
# MC1-52  # DAC0_SYNC_B   
set_property PACKAGE_PIN V3   [get_ports o_B34_L6N           ]  
# MC1-54  # RES_NET_1     
set_property PACKAGE_PIN W1   [get_ports o_B34_L5P           ]  
# MC1-56  # MC1_VCCO      VCCO                                                             
# MC1-58  # INT_SP_MOSI   
set_property PACKAGE_PIN Y1   [get_ports io_B34_L5N          ]  
# MC1-60  # INT_SP_SCLK   
set_property PACKAGE_PIN AB3  [get_ports io_B34_L8P          ]  
# MC1-62  # INT_SP_MISO   
set_property PACKAGE_PIN AB2  [get_ports io_B34_L8N          ]  
# MC1-64  # INT_SP_CS_B   
set_property PACKAGE_PIN Y13  [get_ports io_B13_L5P          ]  
# MC1-66  # EXT_SP2_CS_B  
set_property PACKAGE_PIN AA14 [get_ports o_B13_L5N           ]  
# MC1-68  # EXT_SP3_CS_B  
set_property PACKAGE_PIN AA13 [get_ports o_B13_L3P           ]  
# MC1-70  # EXT_SP4_CS_B  
set_property PACKAGE_PIN AB13 [get_ports o_B13_L3N           ]  
# MC1-72  # EXT_SP5_CS_B  
set_property PACKAGE_PIN W15  [get_ports o_B13_L16P          ]  
# MC1-74  # EXT_SP6_CS_B  
set_property PACKAGE_PIN W16  [get_ports o_B13_L16N          ]  
# MC1-76  # EXT_SP7_CS_B  
set_property PACKAGE_PIN AA16 [get_ports o_B13_L1N           ]  
# MC1-78  GND
# MC1-80  GND
          

####        
# MC2-11  # DACx_LOAC_B      
set_property PACKAGE_PIN AB12 [get_ports o_B13_SYS_CLK_MC2]
# MC2-13  # DGND            GND                                                         
# MC2-15  # DAC2_SCK         
set_property PACKAGE_PIN P5   [get_ports o_B35_L21P       ]
# MC2-17  # DAC2_MOSI        
set_property PACKAGE_PIN P4   [get_ports o_B35_L21N       ]
# MC2-19  # DAC2_MISO        
set_property PACKAGE_PIN N4   [get_ports i_B35_L19P       ]
# MC2-21  # DAC2_SYNC_B      
set_property PACKAGE_PIN N3   [get_ports o_B35_L19N       ]
# MC2-23  # M_TRIG           
set_property PACKAGE_PIN L5   [get_ports i_B35_L18P       ]
# MC2-25  # M_PRE_TRIG       
set_property PACKAGE_PIN L4   [get_ports i_B35_L18N       ]
# MC2-27  # ADC3_SDOA_P      
set_property PACKAGE_PIN M6   [get_ports i_B35D_L23P      ]
# MC2-29  # ADC3_SDOA_N      
set_property PACKAGE_PIN M5   [get_ports i_B35D_L23N      ]
# MC2-31  # ADC3_SDOB_P      
set_property PACKAGE_PIN M1   [get_ports i_B35D_L15P      ]
# MC2-33  # ADC3_SDOB_N      
set_property PACKAGE_PIN L1   [get_ports i_B35D_L15N      ]
# MC2-35  # MC2_VCCO        VCCO                                                       
# MC2-37  # ADC3_SDOC_P      
set_property PACKAGE_PIN K2   [get_ports i_B35D_L9P       ]
# MC2-39  # ADC3_SDOC_N      
set_property PACKAGE_PIN J2   [get_ports i_B35D_L9N       ]
# MC2-41  # ADC3_SDOD_P      
set_property PACKAGE_PIN K1   [get_ports i_B35D_L7P       ]
# MC2-43  # ADC3_SDOD_N      
set_property PACKAGE_PIN J1   [get_ports i_B35D_L7N       ]
# MC2-45  # ADC3_DCO_P       
set_property PACKAGE_PIN H3   [get_ports c_B35D_L11P_SRCC ]
# MC2-47  # ADC3_DCO_N       
set_property PACKAGE_PIN G3   [get_ports c_B35D_L11N_SRCC ]
# MC2-49  # EXT_SP16_CS_B    
set_property PACKAGE_PIN E2   [get_ports o_B35_L4P        ]
# MC2-51  # EXT_SP17_CS_B    
set_property PACKAGE_PIN D2   [get_ports o_B35_L4N        ]
# MC2-53  # EXT_SP18_CS_B    
set_property PACKAGE_PIN F3   [get_ports o_B35_L6P        ]
# MC2-55  # MC2_VCCO        VCCO                                                        
# MC2-57  # EXT_SP19_CS_B    
set_property PACKAGE_PIN E3   [get_ports o_B35_L6N        ]
# MC2-59  # EXT_SP20_CS_B    
set_property PACKAGE_PIN B1   [get_ports o_B35_L1P        ]
# MC2-61  # EXT_SP21_CS_B    
set_property PACKAGE_PIN A1   [get_ports o_B35_L1N        ]
# MC2-63  # EXT_SP22_CS_B    
set_property PACKAGE_PIN K4   [get_ports o_B35_L13P_MRCC  ]
# MC2-65  # EXT_SP23_CS_B    
set_property PACKAGE_PIN J4   [get_ports o_B35_L13N_MRCC  ]
# MC2-67  # EXT_BUSY_B_OUT   
set_property PACKAGE_PIN T16  [get_ports o_B13_L17P       ]
# MC2-69  # MEM_SIO          
set_property PACKAGE_PIN U16  [get_ports io_B13_L17N      ]
# MC2-71  # LAN_INT_B        
set_property PACKAGE_PIN V13  [get_ports i_B13_L13P_MRCC  ]
# MC2-73  # TMP_SDO          
set_property PACKAGE_PIN V14  [get_ports i_B13_L13N_MRCC  ]
# MC2-75  # M_BUSY_B_OUT     
set_property PACKAGE_PIN Y11  [get_ports o_B13_L11P_SRCC  ]
# MC2-77  # EXT_SP14_CS_B    
set_property PACKAGE_PIN H4   [get_ports o_B35_L12P_MRCC  ]
# MC2-79  # EXT_SP15_CS_B    
set_property PACKAGE_PIN G4   [get_ports o_B35_L12N_MRCC  ]


####        
# MC2-10  # DAC3_SYNC_B      
set_property PACKAGE_PIN F4   [get_ports o_B35_IO0        ]
# MC2-12  # DAC3_SCK         
set_property PACKAGE_PIN L6   [get_ports o_B35_IO25       ]
# MC2-14  # DGND            GND                                                          
# MC2-16  # DAC3_MOSI        
set_property PACKAGE_PIN P6   [get_ports o_B35_L24P       ]
# MC2-18  # DAC3_MISO        
set_property PACKAGE_PIN N5   [get_ports i_B35_L24N       ]
# MC2-20  # ADC2_SDOD_N      
set_property PACKAGE_PIN P2   [get_ports i_B35D_L22P      ]
# MC2-22  # ADC2_SDOD_P      
set_property PACKAGE_PIN N2   [get_ports i_B35D_L22N      ]
# MC2-24  # ADC2_SDOC_N      
set_property PACKAGE_PIN R1   [get_ports i_B35D_L20P      ]
# MC2-26  # ADC2_SDOC_P      
set_property PACKAGE_PIN P1   [get_ports i_B35D_L20N      ]
# MC2-28  # ADC2_SDOB_N      
set_property PACKAGE_PIN M3   [get_ports i_B35D_L16P      ]
# MC2-30  # ADC2_SDOB_P      
set_property PACKAGE_PIN M2   [get_ports i_B35D_L16N      ]
# MC2-32  # ADC2_SDOA_N      
set_property PACKAGE_PIN K6   [get_ports i_B35D_L17P      ]
# MC2-34  # ADC2_SDOA_P      
set_property PACKAGE_PIN J6   [get_ports i_B35D_L17N      ]
# MC2-36  # DGND            GND                                                         
# MC2-38  # ADC2_DCO_N       
set_property PACKAGE_PIN L3   [get_ports c_B35D_L14P_SRCC ]
# MC2-40  # ADC2_DCO_P       
set_property PACKAGE_PIN K3   [get_ports c_B35D_L14N_SRCC ]
# MC2-42  # EXT_SP8_CS_B     
set_property PACKAGE_PIN J5   [get_ports o_B35_L10P       ]
# MC2-44  # EXT_SP9_CS_B     
set_property PACKAGE_PIN H5   [get_ports o_B35_L10N       ]
# MC2-46  # EXT_SP10_CS_B    
set_property PACKAGE_PIN H2   [get_ports o_B35_L8P        ]
# MC2-48  # EXT_SP11_CS_B    
set_property PACKAGE_PIN G2   [get_ports o_B35_L8N        ]
# MC2-50  # EXT_SP12_CS_B    
set_property PACKAGE_PIN G1   [get_ports o_B35_L5P        ]
# MC2-52  # EXT_SP13_CS_B    
set_property PACKAGE_PIN F1   [get_ports o_B35_L5N        ]
# MC2-54  # S_ID3_BUF        
set_property PACKAGE_PIN E1   [get_ports i_B35_L3P        ]
# MC2-56  # DGND            GND                                                          
# MC2-58  # S_ID2_BUF        
set_property PACKAGE_PIN D1   [get_ports i_B35_L3N        ]
# MC2-60  # S_ID1_BUF        
set_property PACKAGE_PIN C2   [get_ports i_B35_L2P        ]
# MC2-62  # S_ID0_BUF        
set_property PACKAGE_PIN B2   [get_ports i_B35_L2N        ]
# MC2-64  # EXT_TRIG_P       
set_property PACKAGE_PIN U15  [get_ports i_B13D_L14P_SRCC ]
# MC2-66  # EXT_TRIG_N       
set_property PACKAGE_PIN V15  [get_ports i_B13D_L14N_SRCC ]
# MC2-68  # LAN_RST_B        
set_property PACKAGE_PIN T14  [get_ports o_B13_L15P       ]
# MC2-70  # LAN_MISO         
set_property PACKAGE_PIN T15  [get_ports i_B13_L15N       ]
# MC2-72  # LAN_CS_B         
set_property PACKAGE_PIN W14  [get_ports o_B13_L6P        ]
# MC2-74  # LAN_SCLK         
set_property PACKAGE_PIN Y14  [get_ports o_B13_L6N        ]
# MC2-76  # LAN_MOSI         
set_property PACKAGE_PIN Y12  [get_ports o_B13_L11N_SRCC  ]
# MC2-78 GND
# MC2-80 GND

############################################################################


############################################################################
## TODO: IO property : B13 B34 B35 + B15
############################################################################
#
set_property INTERNAL_VREF 0.9 [get_iobanks 34]
set_property INTERNAL_VREF 0.9 [get_iobanks 35]
#

##$$ IO property

## B13 ##
# due to clock input ... use LVDS_25 and LVCMOS25
set_property IOSTANDARD LVCMOS25          [get_ports  *_B13_*]
set_property IOSTANDARD LVDS_25           [get_ports *_B13D_*]

## B34 ##
set_property IOSTANDARD LVCMOS18        [get_ports  *_B34_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *_B34D_*]

## B35 ##
set_property IOSTANDARD LVCMOS18        [get_ports  *_B35_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *_B35D_*]

## B15 ## 
set_property IOSTANDARD LVCMOS33          [get_ports  *_B15_*]









