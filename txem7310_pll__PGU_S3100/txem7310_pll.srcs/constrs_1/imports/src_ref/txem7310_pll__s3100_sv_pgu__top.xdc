############################################################################
# XEM7310 - Xilinx constraints file
#   XC7A200T-1FBG484
#   https://www.xilinx.com/support/packagefiles/a7packages/xc7a200tfbg484pkg.txt
# Pin mappings for the XEM7310.
#
# this           : txem7310_pll__s3100_sv_pgu__top.xdc
# top verilog    : txem7310_pll__s3100_sv_pgu__top.v
#
# FPGA board     : XEM7310-A200 # (not yet) TXEM7310-FPGA-CORE 
# FPGA board sch : NA           # (not yet) PGU_CPU_F5500__R190929__4M.pdf
#
# base board     : S3100-PGU
# base board sch : PGU-CPU-S3100__R20210521.pdf
#
############################################################################


#### TODO: chip config 
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

#### TODO: XDC command for SPIx4 config mode  
## set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
## set_property CONFIG_MODE SPIx4 [current_design]

############################################################################


############################################################################
## TODO: FrontPanel Host Interface
############################################################################
##$$ bank 14
#  set_property PACKAGE_PIN Y19 [get_ports {okHU[0]}]
#  set_property PACKAGE_PIN R18 [get_ports {okHU[1]}]
#  set_property PACKAGE_PIN R16 [get_ports {okHU[2]}]
#  set_property SLEW FAST [get_ports {okHU[*]}]
#  set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]
#  
#  set_property PACKAGE_PIN W19 [get_ports {okUH[0]}]
#  set_property PACKAGE_PIN V18 [get_ports {okUH[1]}]
#  set_property PACKAGE_PIN U17 [get_ports {okUH[2]}]
#  set_property PACKAGE_PIN W17 [get_ports {okUH[3]}]
#  set_property PACKAGE_PIN T19 [get_ports {okUH[4]}]
#  set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]
#  
#  set_property PACKAGE_PIN AB22 [get_ports {okUHU[0]}]
#  set_property PACKAGE_PIN AB21 [get_ports {okUHU[1]}]
#  set_property PACKAGE_PIN Y22 [get_ports {okUHU[2]}]
#  set_property PACKAGE_PIN AA21 [get_ports {okUHU[3]}]
#  set_property PACKAGE_PIN AA20 [get_ports {okUHU[4]}]
#  set_property PACKAGE_PIN W22 [get_ports {okUHU[5]}]
#  set_property PACKAGE_PIN W21 [get_ports {okUHU[6]}]
#  set_property PACKAGE_PIN T20 [get_ports {okUHU[7]}]
#  set_property PACKAGE_PIN R19 [get_ports {okUHU[8]}]
#  set_property PACKAGE_PIN P19 [get_ports {okUHU[9]}]
#  set_property PACKAGE_PIN U21 [get_ports {okUHU[10]}]
#  set_property PACKAGE_PIN T21 [get_ports {okUHU[11]}]
#  set_property PACKAGE_PIN R21 [get_ports {okUHU[12]}]
#  set_property PACKAGE_PIN P21 [get_ports {okUHU[13]}]
#  set_property PACKAGE_PIN R22 [get_ports {okUHU[14]}]
#  set_property PACKAGE_PIN P22 [get_ports {okUHU[15]}]
#  set_property PACKAGE_PIN R14 [get_ports {okUHU[16]}]
#  set_property PACKAGE_PIN W20 [get_ports {okUHU[17]}]
#  set_property PACKAGE_PIN Y21 [get_ports {okUHU[18]}]
#  set_property PACKAGE_PIN P17 [get_ports {okUHU[19]}]
#  set_property PACKAGE_PIN U20 [get_ports {okUHU[20]}]
#  set_property PACKAGE_PIN N17 [get_ports {okUHU[21]}]
#  set_property PACKAGE_PIN N14 [get_ports {okUHU[22]}]
#  set_property PACKAGE_PIN V20 [get_ports {okUHU[23]}]
#  set_property PACKAGE_PIN P16 [get_ports {okUHU[24]}]
#  set_property PACKAGE_PIN T18 [get_ports {okUHU[25]}]
#  set_property PACKAGE_PIN V19 [get_ports {okUHU[26]}]
#  set_property PACKAGE_PIN AB20 [get_ports {okUHU[27]}]
#  set_property PACKAGE_PIN P15 [get_ports {okUHU[28]}]
#  set_property PACKAGE_PIN V22 [get_ports {okUHU[29]}]
#  set_property PACKAGE_PIN U18 [get_ports {okUHU[30]}]
#  set_property PACKAGE_PIN AB18 [get_ports {okUHU[31]}]
#  set_property SLEW FAST [get_ports {okUHU[*]}]
#  set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]
#  
#  set_property PACKAGE_PIN N13 [get_ports okAA]
#  set_property IOSTANDARD LVCMOS18 [get_ports okAA]

## TODO: okUH0
#  create_clock -period 9.920 -name okUH0 [get_ports {okUH[0]}]
#  
#  set_input_delay -clock [get_clocks okUH0] -max -add_delay 8.000 [get_ports {{okUH[1]} {okUH[2]} {okUH[3]} {okUH[4]}}]
#  set_input_delay -clock [get_clocks okUH0] -min -add_delay 10.000 [get_ports {{okUH[1]} {okUH[2]} {okUH[3]} {okUH[4]}}]
#  set_multicycle_path -setup -from [get_ports {{okUH[1]} {okUH[2]} {okUH[3]} {okUH[4]}}] 2
#  
#  set_input_delay -clock [get_clocks okUH0] -max -add_delay 8.000 [get_ports {okUHU[*]}]
#  set_input_delay -clock [get_clocks okUH0] -min -add_delay 2.000 [get_ports {okUHU[*]}]
#  set_multicycle_path -setup -from [get_ports {okUHU[*]}] 2
#  
#  set_output_delay -clock [get_clocks okUH0] -max -add_delay 2.000 [get_ports {okHU[*]}]
#  set_output_delay -clock [get_clocks okUH0] -min -add_delay -0.500 [get_ports {okHU[*]}]
#  
#  set_output_delay -clock [get_clocks okUH0] -max -add_delay 2.000 [get_ports {okUHU[*]}]
#  set_output_delay -clock [get_clocks okUH0] -min -add_delay -0.500 [get_ports {okUHU[*]}]
#  
#  # for okAA
#  set_input_delay -clock [get_clocks okUH0] -max -add_delay 7.000 [get_ports okAA]
#  set_input_delay -clock [get_clocks okUH0] -min -add_delay 2.000 [get_ports okAA]
#  set_multicycle_path -setup -from [get_ports okAA] 2
#  set_output_delay -clock [get_clocks okUH0] -max -add_delay 2.000 [get_ports okAA]
#  set_output_delay -clock [get_clocks okUH0] -min -add_delay -0.500 [get_ports okAA]
#  
#  ## TODO: define clock - okDnaClk   for ok_endpoint_wrapper_inst/okHI/core0/core0/a0
#  create_generated_clock -name okDnaClk -source [get_pins ok_endpoint_wrapper_inst/okHI/mmcm0/CLKOUT0] -divide_by 32 [get_pins {ok_endpoint_wrapper_inst/okHI/core0/core0/a0/d0/lc4da648cb12eeeb24e4d199c1195ed93_reg[4]/Q}]
#  set_false_path -to [get_pins {ok_endpoint_wrapper_inst/okHI/core0/core0/a0/pm0/ram_1k_generate.v6.kcpsm6_rom/DIBDI[*]}]
#  set_false_path -to [get_pins {ok_endpoint_wrapper_inst/okHI/core0/core0/a0/pm0/ram_1k_generate.v6.kcpsm6_rom/DIPBDIP[*]}]
#  
#  ## TODO: define clock - okHI_clk // replace mmcm0_clk0
#  create_generated_clock  -name okHI_clk        [get_pins  ok_endpoint_wrapper_inst/okHI/mmcm0/CLKOUT0]
#  
#  # asynchronous
#  set_clock_groups -asynchronous -group [get_clocks {okHI_clk okUH0}] -group [get_clocks okDnaClk]

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


## TODO: define clock - sys_clk // from pll // clk_out3_10M_clk_wiz_0
create_generated_clock  -name sys_clk         [get_pins  clk_wiz_0_0_1_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - xadc_clk // replace clk_out1_10M_clk_wiz_0_4
create_generated_clock  -name xadc_clk        [get_pins  clk_wiz_0_0_1_inst/inst/plle2_adv_inst/CLKOUT1]


## TODO: define clock - mcs_clk // replace clk_out1_72M_clk_wiz_0_3
create_generated_clock  -name mcs_clk         [get_pins  clk_wiz_0_3_1_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - lan_clk // replace clk_out2_144M_clk_wiz_0_3
create_generated_clock  -name lan_clk         [get_pins  clk_wiz_0_3_1_inst/inst/plle2_adv_inst/CLKOUT1]

## TODO: define clock - lan_io_clk // replace clk_out3_12M_clk_wiz_0_3
#create_generated_clock  -name lan_io_clk      [get_pins  clk_wiz_0_3_1_inst/inst/plle2_adv_inst/CLKOUT2]

## TODO: define clock - mcs_eeprom_fifo_clk
create_generated_clock  -name mcs_eeprom_fifo_clk      [get_pins  clk_wiz_0_3_1_inst/inst/plle2_adv_inst/CLKOUT3]

## TODO: define clock - ref_clk // replace clk_out1_200M_clk_wiz_0
create_generated_clock  -name ref_clk        [get_pins  clk_wiz_0_inst/inst/plle2_adv_inst/CLKOUT0]

####
set_clock_groups -asynchronous -group [get_clocks mcs_eeprom_fifo_clk] -group [get_clocks sys_clk]
set_clock_groups -asynchronous -group [get_clocks ref_clk] -group [get_clocks sys_clk]
#  set_clock_groups -asynchronous -group [get_clocks ref_clk] -group [get_clocks {okHI_clk okUH0}]
#  set_clock_groups -asynchronous -group [get_clocks mcs_eeprom_fifo_clk] -group [get_clocks okHI_clk]
#  set_clock_groups -asynchronous -group [get_clocks {okHI_clk okUH0}] -group [get_clocks sys_clk]


## for MCS
# mcs_clk
# lan_clk
# lan_io_clk # not yet
set_clock_groups -asynchronous -group [get_clocks mcs_clk] -group [get_clocks lan_clk]
set_clock_groups -asynchronous -group [get_clocks mcs_clk] -group [get_clocks sys_clk]
set_clock_groups -asynchronous -group [get_clocks lan_clk] -group [get_clocks sys_clk]
set_clock_groups -asynchronous -group [get_clocks xadc_clk] -group [get_clocks mcs_clk]
#  set_clock_groups -asynchronous -group [get_clocks mcs_clk] -group [get_clocks {okHI_clk okUH0}]
#  set_clock_groups -asynchronous -group [get_clocks lan_clk] -group [get_clocks {okHI_clk okUH0}]
#  set_clock_groups -asynchronous -group [get_clocks xadc_clk] -group [get_clocks {okHI_clk okUH0}]
#set_clock_groups -asynchronous -group [get_clocks mcs_clk] -group [get_clocks lan_io_clk]
#set_clock_groups -asynchronous -group [get_clocks lan_io_clk] -group [get_clocks lan_clk]



## IO delays ##############################################################
## B35 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B35*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B35*]
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B35*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B35*]

## B34 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B34*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B34*]
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B34*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B34*]
#
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports io_B34* ]

## B13 common
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B13*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B13*]
set_input_delay -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B13*]
set_input_delay -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B13*]


## LAN control
#set_output_delay -clock [get_clocks lan_io_clk] 0.000 [get_ports o_B35*]
#set_max_delay   -to [get_ports o_B35_L21N] 20.0
#set_max_delay   -to [get_ports o_B35_IO0 ] 10.7
#set_max_delay   -to [get_ports o_B35_IO25] 10.7
#set_max_delay   -to [get_ports o_B35_L24P] 10.7
#set_max_delay   -to [get_ports o_B35_L24N] 10.7
#set_output_delay -clock [get_clocks lan_clk] 0.0 [get_ports o_B35_L21N]
#set_output_delay -clock [get_clocks lan_clk] 0.0 [get_ports o_B35_IO0 ]
#set_output_delay -clock [get_clocks lan_clk] 0.0 [get_ports o_B35_IO25]
#set_output_delay -clock [get_clocks lan_clk] 0.0 [get_ports o_B35_L24P]
#set_output_delay -clock [get_clocks lan_clk] 0.0 [get_ports o_B35_L24N]
#
#set_input_delay  -clock [get_clocks lan_clk] 3.5 [get_ports i_B35_L21P]            


## TEMP sensor 
#set_input_delay  -clock [get_clocks lan_io_clk] 0.0 [get_ports i_B35_L6P]            


# LEDs #####################################################################
##$$ bank 16
set_property PACKAGE_PIN A13 [get_ports {led[0]}]
set_property PACKAGE_PIN B13 [get_ports {led[1]}]
set_property PACKAGE_PIN A14 [get_ports {led[2]}]
set_property PACKAGE_PIN A15 [get_ports {led[3]}]
set_property PACKAGE_PIN B15 [get_ports {led[4]}]
set_property PACKAGE_PIN A16 [get_ports {led[5]}]
set_property PACKAGE_PIN B16 [get_ports {led[6]}]
set_property PACKAGE_PIN B17 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[*]}]

# for led
set_output_delay -clock [get_clocks sys_clk] 0.0 [get_ports {led[*]}]

## XADC pins for sure
## _AD0P_ to _AD15P_
## _AD0N_ to _AD15N_
#H13   IO_L1P_T0_AD0P_15
#G13   IO_L1N_T0_AD0N_15
#J14   IO_L3P_T0_DQS_AD1P_15
#H14   IO_L3N_T0_DQS_AD1N_15
#J22   IO_L7P_T1_AD2P_15
#H22   IO_L7N_T1_AD2N_15
#K21   IO_L9P_T1_DQS_AD3P_15
#K22   IO_L9N_T1_DQS_AD3N_15
#B1    IO_L1P_T0_AD4P_35
#A1    IO_L1N_T0_AD4N_35
#E1    IO_L3P_T0_DQS_AD5P_35
#D1    IO_L3N_T0_DQS_AD5N_35
#K1    IO_L7P_T1_AD6P_35
#J1    IO_L7N_T1_AD6N_35
#K2    IO_L9P_T1_DQS_AD7P_35
#J2    IO_L9N_T1_DQS_AD7N_35
#G15   IO_L2P_T0_AD8P_15
#G16   IO_L2N_T0_AD8N_15
#J15   IO_L5P_T0_AD9P_15
#H15   IO_L5N_T0_AD9N_15
#H20   IO_L8P_T1_AD10P_15
#G20   IO_L8N_T1_AD10N_15
#M21   IO_L10P_T1_AD11P_15
#L21   IO_L10N_T1_AD11N_15
#C2    IO_L2P_T0_AD12P_35
#B2    IO_L2N_T0_AD12N_35
#G1    IO_L5P_T0_AD13P_35
#F1    IO_L5N_T0_AD13N_35
#H2    IO_L8P_T1_AD14P_35
#G2    IO_L8N_T1_AD14N_35
#J5    IO_L10P_T1_AD15P_35
#H5    IO_L10N_T1_AD15N_35

##$$ note B34 B35 clock pin locations
#
#Y4    IO_L11P_T1_SRCC_34
#AA4   IO_L11N_T1_SRCC_34
#V4    IO_L12P_T1_MRCC_34
#W4    IO_L12N_T1_MRCC_34
#R4    IO_L13P_T2_MRCC_34
#T4    IO_L13N_T2_MRCC_34
#T5    IO_L14P_T2_SRCC_34
#U5    IO_L14N_T2_SRCC_34
#
#H3    IO_L11P_T1_SRCC_35
#G3    IO_L11N_T1_SRCC_35
#H4    IO_L12P_T1_MRCC_35
#G4    IO_L12N_T1_MRCC_35
#K4    IO_L13P_T2_MRCC_35
#J4    IO_L13N_T2_MRCC_35
#L3    IO_L14P_T2_SRCC_35
#K3    IO_L14N_T2_SRCC_35
#
#Y11   IO_L11P_T1_SRCC_13
#Y12   IO_L11N_T1_SRCC_13
#W11   IO_L12P_T1_MRCC_13
#W12   IO_L12N_T1_MRCC_13
#V13   IO_L13P_T2_MRCC_13
#V14   IO_L13N_T2_MRCC_13
#U15   IO_L14P_T2_SRCC_13
#V15   IO_L14N_T2_SRCC_13


##$$ BANKS IN CONNECTORS ###################################################
##
# MC1-10
set_property PACKAGE_PIN M9 [get_ports i_XADC_VN]
# MC1-12
set_property PACKAGE_PIN L10 [get_ports i_XADC_VP]
##
# MC1-15
set_property PACKAGE_PIN W9 [get_ports o_B34D_L24P]
# MC1-17
set_property PACKAGE_PIN Y9 [get_ports o_B34D_L24N]
# MC1-19
set_property PACKAGE_PIN R6 [get_ports o_B34D_L17P]
# MC1-21
set_property PACKAGE_PIN T6 [get_ports o_B34D_L17N]
# MC1-23
set_property PACKAGE_PIN U6 [get_ports o_B34D_L16P]
# MC1-25
set_property PACKAGE_PIN V5 [get_ports o_B34D_L16N]
# MC1-27
set_property PACKAGE_PIN T5 [get_ports c_B34D_L14P_SRCC]
# MC1-29
set_property PACKAGE_PIN U5 [get_ports c_B34D_L14N_SRCC]
# MC1-31
set_property PACKAGE_PIN AA5 [get_ports o_B34D_L10P]
# MC1-33
set_property PACKAGE_PIN AB5 [get_ports o_B34D_L10N]
# MC1-37
set_property PACKAGE_PIN AB7 [get_ports o_B34D_L20P]
# MC1-39
set_property PACKAGE_PIN AB6 [get_ports o_B34D_L20N]
# MC1-41
set_property PACKAGE_PIN R3 [get_ports o_B34D_L3P]
# MC1-43
set_property PACKAGE_PIN R2 [get_ports o_B34D_L3N]
# MC1-45
set_property PACKAGE_PIN Y3 [get_ports o_B34D_L9P]
# MC1-47
set_property PACKAGE_PIN AA3 [get_ports o_B34D_L9N]
# MC1-49
set_property PACKAGE_PIN U2 [get_ports o_B34D_L2P]
# MC1-51
set_property PACKAGE_PIN V2 [get_ports o_B34D_L2N]
# MC1-53
set_property PACKAGE_PIN W2 [get_ports o_B34D_L4P]
# MC1-57
set_property PACKAGE_PIN Y2 [get_ports o_B34D_L4N]
# MC1-59
set_property PACKAGE_PIN T1 [get_ports o_B34D_L1P]
# MC1-61
set_property PACKAGE_PIN U1 [get_ports o_B34D_L1N]
# MC1-63
set_property PACKAGE_PIN AA1 [get_ports o_B34D_L7P]
# MC1-65
set_property PACKAGE_PIN AB1 [get_ports o_B34D_L7N]
##
# MC1-67
set_property PACKAGE_PIN AB16 [get_ports o_B13_L2P]
# MC1-69
set_property PACKAGE_PIN AB17 [get_ports o_B13_L2N]
# MC1-71
set_property PACKAGE_PIN AA15 [get_ports o_B13_L4P]
# MC1-73
set_property PACKAGE_PIN AB15 [get_ports i_B13_L4N]
# MC1-75
set_property PACKAGE_PIN Y16 [get_ports o_B13_L1P]
##
# MC1-77
set_property PACKAGE_PIN V4 [get_ports o_B34D_L12P_MRCC]
# MC1-79
set_property PACKAGE_PIN W4 [get_ports o_B34D_L12N_MRCC]
##
# MC1-8
set_property PACKAGE_PIN AB11 [get_ports o_B13_SYS_CLK_MC1]
# MC1-16
set_property PACKAGE_PIN V9 [get_ports o_B34D_L21P]
# MC1-18
set_property PACKAGE_PIN V8 [get_ports o_B34D_L21N]
# MC1-20
set_property PACKAGE_PIN V7 [get_ports o_B34D_L19P]
# MC1-22
set_property PACKAGE_PIN W7 [get_ports o_B34D_L19N]
# MC1-24
set_property PACKAGE_PIN Y8 [get_ports o_B34D_L23P]
# MC1-26
set_property PACKAGE_PIN Y7 [get_ports o_B34D_L23N]
# MC1-28
set_property PACKAGE_PIN W6 [get_ports o_B34D_L15P]
# MC1-30
set_property PACKAGE_PIN W5 [get_ports o_B34D_L15N]
# MC1-32
set_property PACKAGE_PIN R4 [get_ports o_B34D_L13P_MRCC]
# MC1-34
set_property PACKAGE_PIN T4 [get_ports o_B34D_L13N_MRCC]
# MC1-38
set_property PACKAGE_PIN Y4 [get_ports c_B34D_L11P_SRCC]
# MC1-40
set_property PACKAGE_PIN AA4 [get_ports c_B34D_L11N_SRCC]
# MC1-42
set_property PACKAGE_PIN Y6 [get_ports i_B34D_L18P]
# MC1-44
set_property PACKAGE_PIN AA6 [get_ports i_B34D_L18N]
# MC1-46
set_property PACKAGE_PIN AA8 [get_ports i_B34D_L22P]
# MC1-48
set_property PACKAGE_PIN AB8 [get_ports i_B34D_L22N]
# MC1-50
set_property PACKAGE_PIN U3 [get_ports o_B34D_L6P]
# MC1-52
set_property PACKAGE_PIN V3 [get_ports o_B34D_L6N]
# MC1-54
set_property PACKAGE_PIN W1 [get_ports o_B34_L5P]
# MC1-58
set_property PACKAGE_PIN Y1 [get_ports io_B34_L5N]
# MC1-60
set_property PACKAGE_PIN AB3 [get_ports o_B34D_L8P]
# MC1-62
set_property PACKAGE_PIN AB2 [get_ports o_B34D_L8N]

# MC1-64
set_property PACKAGE_PIN Y13 [get_ports o_B13_L5P]
# MC1-66
set_property PACKAGE_PIN AA14 [get_ports o_B13_L5N]
# MC1-68
set_property PACKAGE_PIN AA13 [get_ports o_B13_L3P]
# MC1-70
set_property PACKAGE_PIN AB13 [get_ports i_B13_L3N]
# MC1-72
set_property PACKAGE_PIN W15 [get_ports o_B13_L16P]
# MC1-74
set_property PACKAGE_PIN W16 [get_ports io_B13_L16N]
# MC1-76
set_property PACKAGE_PIN AA16 [get_ports io_B13_L1N]
##
# MC2-11
set_property PACKAGE_PIN AB12 [get_ports o_B13_SYS_CLK_MC2]
##
# MC2-15
set_property PACKAGE_PIN P5 [get_ports o_B35D_L21P]
# MC2-17
set_property PACKAGE_PIN P4 [get_ports o_B35D_L21N]
# MC2-19
set_property PACKAGE_PIN N4 [get_ports o_B35D_L19P]
# MC2-21
set_property PACKAGE_PIN N3 [get_ports o_B35D_L19N]
# MC2-23
set_property PACKAGE_PIN L5 [get_ports o_B35D_L18P]
# MC2-25
set_property PACKAGE_PIN L4 [get_ports o_B35D_L18N]
# MC2-27
set_property PACKAGE_PIN M6 [get_ports o_B35D_L23P]
# MC2-29
set_property PACKAGE_PIN M5 [get_ports o_B35D_L23N]
# MC2-31
set_property PACKAGE_PIN M1 [get_ports i_B35_L15P]
# MC2-33
set_property PACKAGE_PIN L1 [get_ports i_B35_L15N]
# MC2-37
set_property PACKAGE_PIN K2 [get_ports i_B35D_L9P]
# MC2-39
set_property PACKAGE_PIN J2 [get_ports i_B35D_L9N]
# MC2-41
set_property PACKAGE_PIN K1 [get_ports i_B35D_L7P]
# MC2-43
set_property PACKAGE_PIN J1 [get_ports i_B35D_L7N]
# MC2-45
set_property PACKAGE_PIN H3 [get_ports c_B35D_L11P_SRCC]
# MC2-47
set_property PACKAGE_PIN G3 [get_ports c_B35D_L11N_SRCC]
# MC2-49
set_property PACKAGE_PIN E2 [get_ports o_B35_L4P]
# MC2-51
set_property PACKAGE_PIN D2 [get_ports o_B35_L4N]
# MC2-53
set_property PACKAGE_PIN F3 [get_ports i_B35_L6P]
# MC2-57
set_property PACKAGE_PIN E3 [get_ports io_B35_L6N]
# MC2-59
set_property PACKAGE_PIN B1 [get_ports o_B35D_L1P]
# MC2-61
set_property PACKAGE_PIN A1 [get_ports o_B35D_L1N]
# MC2-63
set_property PACKAGE_PIN K4 [get_ports o_B35D_L13P_MRCC]
# MC2-65
set_property PACKAGE_PIN J4 [get_ports o_B35D_L13N_MRCC]
##
# MC2-67
set_property PACKAGE_PIN T16 [get_ports i_B13_L17P]
# MC2-69
set_property PACKAGE_PIN U16 [get_ports o_B13_L17N]
# MC2-71
set_property PACKAGE_PIN V13 [get_ports c_B13D_L13P_MRCC]
# MC2-73
set_property PACKAGE_PIN V14 [get_ports c_B13D_L13N_MRCC]
# MC2-75
set_property PACKAGE_PIN Y11 [get_ports i_B13_L11P_SRCC]
##
# MC2-77
set_property PACKAGE_PIN H4 [get_ports o_B35D_L12P_MRCC]
# MC2-79
set_property PACKAGE_PIN G4 [get_ports o_B35D_L12N_MRCC]
##
# MC2-10
set_property PACKAGE_PIN F4 [get_ports o_B35_IO0]
# MC2-12
set_property PACKAGE_PIN L6 [get_ports i_B35_IO25]
# MC2-16
set_property PACKAGE_PIN P6 [get_ports o_B35D_L24P]
# MC2-18
set_property PACKAGE_PIN N5 [get_ports o_B35D_L24N]
# MC2-20
set_property PACKAGE_PIN P2 [get_ports o_B35D_L22P]
# MC2-22
set_property PACKAGE_PIN N2 [get_ports o_B35D_L22N]
# MC2-24
set_property PACKAGE_PIN R1 [get_ports o_B35D_L20P]
# MC2-26
set_property PACKAGE_PIN P1 [get_ports o_B35D_L20N]
# MC2-28
set_property PACKAGE_PIN M3 [get_ports o_B35D_L16P]
# MC2-30
set_property PACKAGE_PIN M2 [get_ports o_B35D_L16N]
# MC2-32
set_property PACKAGE_PIN K6 [get_ports o_B35D_L17P]
# MC2-34
set_property PACKAGE_PIN J6 [get_ports o_B35D_L17N]
# MC2-38
set_property PACKAGE_PIN L3 [get_ports c_B35D_L14P_SRCC]
# MC2-40
set_property PACKAGE_PIN K3 [get_ports c_B35D_L14N_SRCC]
# MC2-42
set_property PACKAGE_PIN J5 [get_ports o_B35D_L10P]
# MC2-44
set_property PACKAGE_PIN H5 [get_ports o_B35D_L10N]
# MC2-46
set_property PACKAGE_PIN H2 [get_ports o_B35D_L8P]
# MC2-48
set_property PACKAGE_PIN G2 [get_ports o_B35D_L8N]
# MC2-50
set_property PACKAGE_PIN G1 [get_ports o_B35D_L5P]
# MC2-52
set_property PACKAGE_PIN F1 [get_ports o_B35D_L5N]
# MC2-54
set_property PACKAGE_PIN E1 [get_ports o_B35D_L3P]
# MC2-58
set_property PACKAGE_PIN D1 [get_ports o_B35D_L3N]
# MC2-60
set_property PACKAGE_PIN C2 [get_ports o_B35D_L2P]
# MC2-62
set_property PACKAGE_PIN B2 [get_ports o_B35D_L2N]
##
# MC2-64
set_property PACKAGE_PIN U15 [get_ports i_B13D_L14P_SRCC]
# MC2-66
set_property PACKAGE_PIN V15 [get_ports i_B13D_L14N_SRCC]
# MC2-68
set_property PACKAGE_PIN T14 [get_ports o_B13_L15P]
# MC2-70
set_property PACKAGE_PIN T15 [get_ports o_B13_L15N]
# MC2-72
set_property PACKAGE_PIN W14 [get_ports o_B13_L6P]
# MC2-74
set_property PACKAGE_PIN Y14 [get_ports o_B13_L6N]
# MC2-76
set_property PACKAGE_PIN Y12 [get_ports o_B13_L11N_SRCC]
#

##$$ IO property
#
##set_property SLEW FAST [get_ports io_B0_*]
##set_property IOSTANDARD LVCMOS15 [get_ports io_B0_*]
#
## B13 ##
# clock input
#LVCMOS25
#set_property IOSTANDARD LVCMOS33  [get_ports  *_B13_*]
#set_property IOSTANDARD LVDS_25   [get_ports *c_B13D_*]
#set_property IOSTANDARD LVDS_25   [get_ports *i_B13D_*]
#set_property IOSTANDARD TMDS_33   [get_ports *o_B13D_*]
#
#set_property IOSTANDARD LVCMOS18          [get_ports  *_B13_*]
set_property IOSTANDARD LVCMOS25          [get_ports  *_B13_*]
set_property IOSTANDARD LVDS_25           [get_ports *c_B13D_*]
set_property IOSTANDARD LVDS_25           [get_ports *i_B13D_*]
#set_property IOSTANDARD LVDS_25           [get_ports *o_B13D_*]
#set_property IOSTANDARD LVDS_25    [get_ports *o_B13D_*]
#
#set_property DRIVE 12   [get_ports io_B13_*]
#set_property SLEW  FAST [get_ports io_B13_*]
#set_property DRIVE 12   [get_ports o_B13_*]
#set_property SLEW  FAST [get_ports o_B13_*]
##set_property SLEW  FAST [get_ports o_B13D_*]
#
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports *c_B13D_*]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports *i_B13D_*]
#
## B34 ##
#set_property SLEW FAST [get_ports io_B34_*]
#set_property IOSTANDARD LVCMOS33 [get_ports *_B34_*]
#set_property IOSTANDARD TMDS_33 [get_ports *o_B34D_*]
#
set_property IOSTANDARD LVCMOS18        [get_ports  *_B34_*]
#set_property IOSTANDARD LVCMOS25        [get_ports  *_B34_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *c_B34D_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *i_B34D_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *o_B34D_*]
#set_property IOSTANDARD LVDS_25  [get_ports *o_B34D_*]
#
#set_property DRIVE 12   [get_ports io_B34_*]
#set_property SLEW  FAST [get_ports io_B34_*]
#set_property DRIVE 12   [get_ports o_B34_*]
#set_property SLEW  FAST [get_ports o_B34_*]
##set_property SLEW  FAST [get_ports o_B34D_*]
#
#set_property OFFCHIP_TERM NONE [get_ports *o_B34D_*]
#set_property OFFCHIP_TERM NONE [get_ports o_B34D_L19P]
#set_property OFFCHIP_TERM NONE [get_ports o_B34D_L21P]
#
# reduce drive low 8 and slow for better SSN
#set_property DRIVE 12 [get_ports *o_B34_*]
#
## B35 ##
#set_property SLEW FAST [get_ports io_B35_*]
#set_property IOSTANDARD LVCMOS33 [get_ports *_B35_*]
#
set_property IOSTANDARD LVCMOS18        [get_ports  *_B35_*]
#set_property IOSTANDARD LVCMOS25        [get_ports  *_B35_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *c_B35D_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *i_B35D_*]
set_property IOSTANDARD DIFF_HSTL_I_18   [get_ports *o_B35D_*]
#set_property IOSTANDARD LVDS_25  [get_ports *o_B35D_*]
#
#set_property DRIVE 12   [get_ports io_B35_*]
#set_property SLEW  FAST [get_ports io_B35_*]
#set_property DRIVE 12   [get_ports o_B35_*]
#set_property SLEW  FAST [get_ports o_B35_*]
##set_property SLEW  FAST [get_ports o_B35D_*]
#
#set_property DRIVE 12 [get_ports *o_B35_*]
#
#set_property PULLUP true [get_ports io_B35_L17N]
#set_property PULLUP true [get_ports io_B35_L17P]
#
##
#set_property INTERNAL_VREF 0.9 [get_iobanks 13]
set_property INTERNAL_VREF 0.9 [get_iobanks 34]
set_property INTERNAL_VREF 0.9 [get_iobanks 35]
##


## TODO: DAC clock 

##$$ 400MHz 2.5ns for dac_clk        // CLK_COUT_P ## used for dac clocks
##$$ 400MHz 2.5ns for dac0_dco_clk   // DAC0_DCO_P # unused
##$$ 400MHz 2.5ns for dac1_dco_clk   // DAC1_DCO_P # unused

#create_clock -period 2.500 -name dac_clk      [get_ports c_B13D_L13P_MRCC]
#create_clock -period 2.500 -name dac0_dco_clk [get_ports c_B34D_L14P_SRCC]
#create_clock -period 2.500 -name dac1_dco_clk [get_ports c_B35D_L14N_SRCC]


## TODO: downclocking 400MHz 2.5ns ----////
# --> 200MHz 5ns --> 175.01MHz 5.714ns --> 174.06MHz 5.745ns --> 169.49MHz 5.9ns  --> 166.67MHz 6.0ns 
# --> 161.29MHz 6.2ns --> 158.73MHz 6.3ns --> 156.25MHz 6.4ns --> 152.91MHz 6.54ns
create_clock -period 5.000 -name dac_clk      [get_ports c_B13D_L13P_MRCC]
create_clock -period 5.000 -name dac0_dco_clk [get_ports c_B34D_L14P_SRCC]
create_clock -period 5.000 -name dac1_dco_clk [get_ports c_B35D_L14N_SRCC]


## setup diff termination for clock in ## LVDS_25 with LVCMOS25
set_property DIFF_TERM TRUE [get_ports {c_B13D_L13P_MRCC}]
set_property DIFF_TERM TRUE [get_ports {c_B13D_L13N_MRCC}]

#set_property DIFF_TERM TRUE [get_ports {c_B34D_L14P_SRCC}]
#set_property DIFF_TERM TRUE [get_ports {c_B34D_L14N_SRCC}]
#set_property DIFF_TERM TRUE [get_ports {c_B35D_L14N_SRCC}]
#set_property DIFF_TERM TRUE [get_ports {c_B35D_L14P_SRCC}]
## in-chip term with DIFF_SSTL18_I DIFF_SSTL18_II DIFF_HSTL_I_18 DIFF_HSTL_II_18 # UNTUNED_SPLIT_60 UNTUNED_SPLIT_50 UNTUNED_SPLIT_40
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B13D_L13P_MRCC}]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B13D_L13N_MRCC}]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B34D_L14P_SRCC}]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B34D_L14N_SRCC}]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B35D_L14N_SRCC}]
#set_property IN_TERM UNTUNED_SPLIT_50 [get_ports {c_B35D_L14P_SRCC}]
## pull/keeper option for clock inputs with DIFF_HSTL_I_18
#set_property PULLUP   true [get_ports c_B13D_L13P_MRCC]
#set_property PULLDOWN true [get_ports c_B13D_L13N_MRCC]
#set_property PULLUP   true [get_ports c_B34D_L14P_SRCC]
#set_property PULLDOWN true [get_ports c_B34D_L14N_SRCC]
#set_property PULLUP   true [get_ports c_B35D_L14N_SRCC]
#set_property PULLDOWN true [get_ports c_B35D_L14P_SRCC]


## TODO: dac clock group 
#clk_wiz_1_3_inst
#clk_wiz_1_3_0_inst
#clk_wiz_1_3_1_inst

## TODO: define clock - dac0_clk // replace clk_out1_400M_clk_wiz_1_0
create_generated_clock  -name dac0_clk        [get_pins  clk_wiz_1_2_0_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - dac0_clk_180 // replace clk_out5_400M_clk_wiz_1_0
create_generated_clock  -name dac0_clk_180    [get_pins  clk_wiz_1_2_0_inst/inst/plle2_adv_inst/CLKOUT1]

## TODO: define clock - dac1_clk // replace clk_out1_400M_clk_wiz_1_1
create_generated_clock  -name dac1_clk        [get_pins  clk_wiz_1_2_1_inst/inst/plle2_adv_inst/CLKOUT2]

## TODO: define clock - dac1_clk_180 // replace clk_out5_400M_clk_wiz_1_1
create_generated_clock  -name dac1_clk_180    [get_pins  clk_wiz_1_2_1_inst/inst/plle2_adv_inst/CLKOUT0]


#  set_clock_groups -asynchronous -group [get_clocks {dac0_clk dac0_clk_180}] -group [get_clocks {okHI_clk okUH0 mcs_clk}]
set_clock_groups -asynchronous -group [get_clocks  dac0_clk] -group [get_clocks {dac0_clk_180}]
set_clock_groups -asynchronous -group [get_clocks  dac0_clk] -group [get_clocks {sys_clk}]
#
#  set_clock_groups -asynchronous -group [get_clocks {dac1_clk dac1_clk_180}] -group [get_clocks {okHI_clk okUH0 mcs_clk}]
set_clock_groups -asynchronous -group [get_clocks  dac1_clk] -group [get_clocks {dac1_clk_180}]
set_clock_groups -asynchronous -group [get_clocks  dac1_clk] -group [get_clocks {sys_clk}]
#
set_clock_groups -asynchronous -group [get_clocks  dac0_clk] -group [get_clocks dac1_clk]
#

## DAC0 data out : 400MHz case
#
#o_B34D_L15P      // DAC0_DAT15
#o_B34D_L23P      // DAC0_DAT14
#o_B34D_L19P      // DAC0_DAT13
#o_B34D_L21P      // DAC0_DAT12
#o_B34D_L13P_MRCC // DAC0_DAT11
#o_B34D_L17P      // DAC0_DAT10
#o_B34D_L24P      // DAC0_DAT9_
#o_B34D_L16P      // DAC0_DAT8_
#o_B34D_L20P      // DAC0_DAT7_
#o_B34D_L3P       // DAC0_DAT6_
#o_B34D_L9P       // DAC0_DAT5_
#o_B34D_L2P       // DAC0_DAT4_
#o_B34D_L4P       // DAC0_DAT3_
#o_B34D_L1P       // DAC0_DAT2_
#o_B34D_L7P       // DAC0_DAT1_
#o_B34D_L12P_MRCC // DAC0_DAT0_
#
##set_multicycle_path -setup -to [get_ports o_B34D_L15P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L23P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L19P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L21P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L13P_MRCC ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L17P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L24P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L16P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L20P      ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L3P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L9P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L2P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L4P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L1P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L7P       ] 2
##set_multicycle_path -setup -to [get_ports o_B34D_L12P_MRCC ] 2
#
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L15P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L23P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L19P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L21P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L13P_MRCC ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.900 [get_ports o_B34D_L17P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L24P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L16P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L20P      ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L3P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L9P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L2P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L4P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L1P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L7P       ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay -2.500 [get_ports o_B34D_L12P_MRCC ]
##
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L15P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L23P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L19P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L21P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L13P_MRCC ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L17P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L24P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L16P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L20P      ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L3P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L9P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L2P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L4P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L1P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L7P       ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay  0.700 [get_ports o_B34D_L12P_MRCC ]
#
set_max_delay   -to [get_ports o_B34D_L15P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L23P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L19P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L21P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L13P_MRCC ] 14.960
set_max_delay   -to [get_ports o_B34D_L17P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L24P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L16P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L20P      ] 14.960
set_max_delay   -to [get_ports o_B34D_L3P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L9P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L2P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L4P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L1P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L7P       ] 14.960
set_max_delay   -to [get_ports o_B34D_L12P_MRCC ] 14.960
#

## DAC1 data out : 400MHz case
#
#o_B35D_L12P_MRCC // DAC1_DAT15
#o_B35D_L13P_MRCC // DAC1_DAT14
#o_B35D_L1P       // DAC1_DAT13
#o_B35D_L2P       // DAC1_DAT12
#o_B35D_L3P       // DAC1_DAT11
#o_B35D_L5P       // DAC1_DAT10
#o_B35D_L8P       // DAC1_DAT9_
#o_B35D_L10P      // DAC1_DAT8_
#o_B35D_L24P      // DAC1_DAT7_
#o_B35D_L22P      // DAC1_DAT6_
#o_B35D_L20P      // DAC1_DAT5_
#o_B35D_L16P      // DAC1_DAT4_
#o_B35D_L21P      // DAC1_DAT3_
#o_B35D_L19P      // DAC1_DAT2_
#o_B35D_L18P      // DAC1_DAT1_
#o_B35D_L23P      // DAC1_DAT0_
#
##set_multicycle_path -setup -to [get_ports o_B35D_L12P_MRCC ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L13P_MRCC ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L1P       ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L2P       ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L3P       ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L5P       ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L8P       ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L10P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L24P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L22P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L20P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L16P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L21P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L19P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L18P      ] 2
##set_multicycle_path -setup -to [get_ports o_B35D_L23P      ] 2
#
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L12P_MRCC ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L13P_MRCC ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L1P       ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L2P       ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L3P       ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.900 [get_ports o_B35D_L5P       ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L8P       ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L10P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L24P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L22P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L20P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L16P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L21P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L19P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L18P      ]
#set_output_delay -clock [get_clocks dac1_clk] -max -add_delay -2.500 [get_ports o_B35D_L23P      ]
##
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L12P_MRCC ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L13P_MRCC ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L1P       ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L2P       ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L3P       ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L5P       ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L8P       ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L10P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L24P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L22P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L20P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L16P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L21P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L19P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L18P      ]
#set_output_delay -clock [get_clocks dac1_clk] -min -add_delay  0.700 [get_ports o_B35D_L23P      ]
#
## 14.380 --> 14.910
set_max_delay   -to [get_ports o_B35D_L12P_MRCC ] 14.910
set_max_delay   -to [get_ports o_B35D_L13P_MRCC ] 14.910
set_max_delay   -to [get_ports o_B35D_L1P       ] 14.910
set_max_delay   -to [get_ports o_B35D_L2P       ] 14.910
set_max_delay   -to [get_ports o_B35D_L3P       ] 14.910
set_max_delay   -to [get_ports o_B35D_L5P       ] 14.910
set_max_delay   -to [get_ports o_B35D_L8P       ] 14.910
set_max_delay   -to [get_ports o_B35D_L10P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L24P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L22P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L20P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L16P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L21P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L19P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L18P      ] 14.910
set_max_delay   -to [get_ports o_B35D_L23P      ] 14.910
#


## DCI out: 400MHz case
# dac0 dci
## set_multicycle_path -setup -to [get_ports o_B34D_L10P ] 2
## #set_multicycle_path -hold  -to [get_ports o_B34D_L10P ] 1
## set_output_delay -clock [get_clocks dac0_clk_180] -max -add_delay -1.250 [get_ports {o_B34D_L10P}]
## set_output_delay -clock [get_clocks dac0_clk_180] -max -add_delay -1.500 [get_ports {o_B34D_L10P}] -clock_fall
## set_output_delay -clock [get_clocks dac0_clk_180] -min -add_delay  0.950 [get_ports {o_B34D_L10P}]
## set_output_delay -clock [get_clocks dac0_clk_180] -min -add_delay  0.940 [get_ports {o_B34D_L10P}] -clock_fall
#
## 8.000 --> 14.960
set_max_delay   -to [get_ports o_B34D_L10P ] 14.960
#
# dac1 dci
## set_multicycle_path -setup -to [get_ports o_B35D_L17P ] 2
## #set_multicycle_path -hold  -to [get_ports o_B35D_L17P ] 1
## set_output_delay -clock [get_clocks dac1_clk_180] -max -add_delay -1.350 [get_ports {o_B35D_L17P}]
## set_output_delay -clock [get_clocks dac1_clk_180] -max -add_delay -1.450 [get_ports {o_B35D_L17P}] -clock_fall
## set_output_delay -clock [get_clocks dac1_clk_180] -min -add_delay  0.960 [get_ports {o_B35D_L17P}]
## set_output_delay -clock [get_clocks dac1_clk_180] -min -add_delay  0.950 [get_ports {o_B35D_L17P}] -clock_fall
#
## 8.000 --> 14.910
set_max_delay   -to [get_ports o_B35D_L17P ] 14.910
#

## false path for fifo reset
# wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6]; //$$ false path try
# wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7]; //$$ false path try
set_false_path -from [get_pins {dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/r_cid_reg_ctrl_reg[6]/C}] 
set_false_path -from [get_pins {dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/r_cid_reg_ctrl_reg[7]/C}] 


## TRIG
# TRIG_OUT
# 200MHz clock out case
#set_output_delay -clock [get_clocks clk_out2_200M_clk_wiz_1] -max -add_delay -2.500 [get_ports {o_B13D_L15P}]
#set_output_delay -clock [get_clocks clk_out2_200M_clk_wiz_1] -min -add_delay -1.500 [get_ports {o_B13D_L15P}]
#
# 400MHz clock out case
#set_multicycle_path -setup -to [get_ports o_B13D_L15P ] 2
#
#set_output_delay -clock [get_clocks clk_out1_400M_clk_wiz_1]  -max -add_delay -1.200 [get_ports {o_B13D_L15P}]
#set_output_delay -clock [get_clocks clk_out1_400M_clk_wiz_1]  -max -add_delay -1.250 [get_ports {o_B13D_L15P}] -clock_fall
#set_output_delay -clock [get_clocks clk_out1_400M_clk_wiz_1]  -min -add_delay  1.000 [get_ports {o_B13D_L15P}]
#set_output_delay -clock [get_clocks clk_out1_400M_clk_wiz_1]  -min -add_delay  0.950 [get_ports {o_B13D_L15P}] -clock_fall
#
#set_max_delay   -to [get_ports o_B13D_L15P ] 8.200
set_max_delay   -to [get_ports o_B13_L15P ] 9.200
set_max_delay   -to [get_ports o_B13_L15N ] 9.200
#


## SPIO
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L2P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L2N ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L4P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L1P ]
#
# ignore wire in from ep07wire
set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi07/ep_dataout_reg[*]/C}] 


## CLKD
# CLKD_SCLK     
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_L4P ]
# CLKD_CS_B
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_L4N ]
# CLKD_SDIO
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports io_B35_L6N ]
set_input_delay  -clock [get_clocks sys_clk] 0.000 [get_ports io_B35_L6N ]

# CLKD_RST_B
#set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_IO0 ]
set_false_path   -from [get_pins master_spi_ad9516_inst/r_LNG_RSTn_reg/C]
set_max_delay    -to [get_ports o_B35_IO0] 20.0

#


# ignore wire in from ep06wire
set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi06/ep_dataout_reg[*]/C}] 



## pull up for SDIO SDO in bidir mode
# CLKD_SDIO
set_property PULLUP true [get_ports io_B35_L6N]
# CLKD_SDO
set_property PULLUP true [get_ports  i_B35_L6P]


## DACX
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L16P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L3P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L5N ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L5P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_SYS_CLK_MC1 ]
#
# ignore wire in from ep05wire
set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi05/ep_dataout_reg[*]/C}] 
# ignore wire in from ep04wire --> ep08wire
#set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi04/ep_dataout_reg[*]/C}] 
set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi08/ep_dataout_reg[*]/C}] 
#

## TODO: LAN control 

## on BASE
# IBUF ibuf_LAN_MISO_inst (.I(i_B13_L17P      ), .O(LAN_MISO ) ); //
# IBUF ibuf_LAN_INTn_inst (.I(i_B13_L11P_SRCC ), .O(LAN_INTn ) ); //
# OBUF obuf_LAN_RSTn_inst (.O(o_B13_L17N      ), .I(LAN_RSTn ) ); // 
# OBUF obuf_LAN_SSNn_inst (.O(o_B13_L6P       ), .I(LAN_SSNn ) ); // 
# OBUF obuf_LAN_SCLK_inst (.O(o_B13_L6N       ), .I(LAN_SCLK ) ); // 
# OBUF obuf_LAN_MOSI_inst (.O(o_B13_L11N_SRCC ), .I(LAN_MOSI ) ); // 
#
# for LAN_RSTn
#set_false_path -from [get_pins master_spi_wz850_inst/r_LAN_RSTn_reg/C]
#set_max_delay    -to [get_ports o_B13_L17N] 20.0
set_max_delay    -to [get_ports o_B13_L17N] 18.0

# for w_FIFO_reset
#set_false_path -from [get_pins {mcs_io_bridge_inst0/r_port_wi_00_reg[0]*/C}] 
# 
# for LAN_MISO
#set_input_delay  -clock [get_clocks lan_clk] 3.5 [get_ports i_B13_L17P] 
set_input_delay -clock [get_clocks lan_clk] -max -add_delay 3.400 [get_ports i_B13_L17P] 
set_input_delay -clock [get_clocks lan_clk] -min -add_delay 1.000 [get_ports i_B13_L17P] 

# for LAN_SSNn LAN_SCLK LAN_MOSI
#set_max_delay   -to [get_ports o_B13_L6P      ] 10.7
#set_max_delay   -to [get_ports o_B13_L6N      ] 10.7
#set_max_delay   -to [get_ports o_B13_L11N_SRCC] 10.7
set_max_delay   -to [get_ports o_B13_L6P      ] 7.1
set_max_delay   -to [get_ports o_B13_L6N      ] 7.1
set_max_delay   -to [get_ports o_B13_L11N_SRCC] 7.1

# for LAN_INTn
set_max_delay  18.000  -from [get_ports i_B13_L11P_SRCC] 
set_min_delay   0.000  -from [get_ports i_B13_L11P_SRCC] 


## on FPGA module : alternative

set_property PACKAGE_PIN  H17  [get_ports  o_B15_L6P ] 
set_property PACKAGE_PIN  J22  [get_ports  o_B15_L7P ] 
set_property PACKAGE_PIN  H22  [get_ports  o_B15_L7N ] 
set_property PACKAGE_PIN  H20  [get_ports  o_B15_L8P ] 
set_property PACKAGE_PIN  G20  [get_ports  i_B15_L8N ] 
set_property PACKAGE_PIN  K21  [get_ports  o_B15_L9P ] 
set_property PACKAGE_PIN  K22  [get_ports  i_B15_L9N ] 

set_input_delay -clock [get_clocks lan_clk] -max -add_delay 3.500 [get_ports i_B15_L9N] 
set_input_delay -clock [get_clocks lan_clk] -min -add_delay 1.000 [get_ports i_B15_L9N] 
set_max_delay  18.000  -from [get_ports i_B15_L8N] 
set_min_delay   0.000  -from [get_ports i_B15_L8N] 
set_max_delay  18.000    -to [get_ports {{o_B15_L9P} {o_B15_L6P}}]  
set_max_delay   6.900    -to [get_ports {{o_B15_L7P} {o_B15_L7N} {o_B15_L8P}}]  

## relax wires
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_00/r_port_wi_00_reg[*]/C}] 
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_01/r_port_wi_00_reg[*]/C}] 


##$$ bank 15 / 16 ###################################################################

# B15 only for TXEM7310 compatible
set_property IOSTANDARD LVCMOS33          [get_ports  *_B15_*]

##
#set_property INTERNAL_VREF 0.75 [get_iobanks 15]
set_property INTERNAL_VREF 0.75 [get_iobanks 16]
##








