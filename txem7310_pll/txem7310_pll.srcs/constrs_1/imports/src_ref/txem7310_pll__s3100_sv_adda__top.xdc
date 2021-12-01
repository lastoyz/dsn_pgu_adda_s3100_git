############################################################################
# XEM7310 - Xilinx constraints file
#   XC7A200T-1FBG484
#   https://www.xilinx.com/support/packagefiles/a7packages/xc7a200tfbg484pkg.txt
# Pin mappings for the XEM7310.
#
# this           : txem7310_pll__s3100_sv_adda__top.xdc
# top verilog    : txem7310_pll__s3100_sv_adda__top.v
#
# FPGA board     : NA
# FPGA board_sch : NA
#
# base board     : S3100-ADDA or S3100-CMU-ADDA
# base board sch : S3100_CMU_ADDA__r210827__remap.pdf
#
# note: artix-7 top design for S3100-ADDA slave spi side
#
############################################################################


#### TODO: chip config 
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

#### TODO: XDC command for SPIx4 config mode  
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

############################################################################
## TODO: bank usage
############################################################################
# B13 : CLK, SPIO1, S_IO, DACx_SPI, M2_SPI, CLK_COUT, TRIG  // 3.3V // (in MC1/MC2) 
# B14 : CONF                                                // 1.8V
# B15 : TP, LAN_SPI(, SCIO)                                 // 3.3V
# B16 : LED                                                 // 3.3V
# B34 : XADC, DAC0, ADC0, ADCx                              // 3.3V // (in MC1)
# B35 : DAC1, ADC1, CLK_SPI                                 // 3.3V // (in MC2)
# B216: not used


############################################################################
## TODO: PACKAGE_PIN assignment
############################################################################

# set_property PACKAGE_PIN xx [get_ports xx]

## Pin   Pin Name                      Memory Byte Group  Bank  I/O Type  
## N9    DXN_0                         NA                 0     CONFIG    
## K10   VCCADC_0                      NA                 0     CONFIG    
## K9    GNDADC_0                      NA                 0     CONFIG    
## N10   DXP_0                         NA                 0     CONFIG    
## L9    VREFN_0                       NA                 0     CONFIG    
## M10   VREFP_0                       NA                 0     CONFIG    
set_property PACKAGE_PIN L10 [get_ports i_XADC_VP] ; ## L10   VP_0                          NA                 0     CONFIG    
set_property PACKAGE_PIN M9  [get_ports i_XADC_VN] ; ## M9    VN_0                          NA                 0     CONFIG    
## E12   VCCBATT_0                     NA                 0     CONFIG    
## L12   CCLK_0                        NA                 0     CONFIG    
## V12   TCK_0                         NA                 0     CONFIG    
## T13   TMS_0                         NA                 0     CONFIG    
## U13   TDO_0                         NA                 0     CONFIG    
## R13   TDI_0                         NA                 0     CONFIG    
## U12   INIT_B_0                      NA                 0     CONFIG    
## N12   PROGRAM_B_0                   NA                 0     CONFIG    
## U8    CFGBVS_0                      NA                 0     CONFIG    
## G11   DONE_0                        NA                 0     CONFIG    
## U9    M2_0                          NA                 0     CONFIG    
## U11   M0_0                          NA                 0     CONFIG    
## U10   M1_0                          NA                 0     CONFIG    


set_property PACKAGE_PIN  Y17   [get_ports io_B13_0_] ; # IO_0_13                       NA                 13    HR        
## set_property PACKAGE_PIN  Y16   [get_ports  o_B13_L1P ] ; # IO_L1P_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AA16  [get_ports  i_B13_L1N ] ; # IO_L1N_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AB16  [get_ports  i_B13_L2P ] ; # IO_L2P_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AB17  [get_ports  o_B13_L2N ] ; # IO_L2N_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AA13  [get_ports  o_B13_L3P ] ; # IO_L3P_T0_DQS_13              0                  13    HR        
set_property PACKAGE_PIN  AB13  [get_ports io_B13_L3N ] ; # IO_L3N_T0_DQS_13              0                  13    HR        
set_property PACKAGE_PIN  AA15  [get_ports  o_B13_L4P ] ; # IO_L4P_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AB15  [get_ports  i_B13_L4N ] ; # IO_L4N_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  Y13   [get_ports  i_B13_L5P ] ; # IO_L5P_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  AA14  [get_ports  o_B13_L5N ] ; # IO_L5N_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  W14   [get_ports  o_B13_L6P ] ; # IO_L6P_T0_13                  0                  13    HR        
set_property PACKAGE_PIN  Y14   [get_ports  o_B13_L6N ] ; # IO_L6N_T0_VREF_13             0                  13    HR        
set_property PACKAGE_PIN  AB11  [get_ports  o_B13_L7P ] ; # IO_L7P_T1_13                  1                  13    HR        
set_property PACKAGE_PIN  AB12  [get_ports  o_B13_L7N ] ; # IO_L7N_T1_13                  1                  13    HR        
set_property PACKAGE_PIN  AA9   [get_ports  o_B13_L8P ] ; # IO_L8P_T1_13                  1                  13    HR        
set_property PACKAGE_PIN  AB10  [get_ports  i_B13_L8N ] ; # IO_L8N_T1_13                  1                  13    HR        
set_property PACKAGE_PIN  AA10  [get_ports  o_B13_L9P ] ; # IO_L9P_T1_DQS_13              1                  13    HR        
set_property PACKAGE_PIN  AA11  [get_ports  o_B13_L9N ] ; # IO_L9N_T1_DQS_13              1                  13    HR        
## set_property PACKAGE_PIN  V10   [get_ports xx] ; # IO_L10P_T1_13                 1                  13    HR        
## set_property PACKAGE_PIN  W10   [get_ports xx] ; # IO_L10N_T1_13                 1                  13    HR        
## set_property PACKAGE_PIN  Y11   [get_ports o_B13_L11P_SRCC ] ; # IO_L11P_T1_SRCC_13            1                  13    HR        
## set_property PACKAGE_PIN  Y12   [get_ports i_B13_L11N_SRCC ] ; # IO_L11N_T1_SRCC_13            1                  13    HR        
## set_property PACKAGE_PIN  W11   [get_ports xx] ; # IO_L12P_T1_MRCC_13            1                  13    HR        
## set_property PACKAGE_PIN  W12   [get_ports xx] ; # IO_L12N_T1_MRCC_13            1                  13    HR        
set_property PACKAGE_PIN  V13   [get_ports  c_B13D_L13P_MRCC ] ; # IO_L13P_T2_MRCC_13            2                  13    HR        
set_property PACKAGE_PIN  V14   [get_ports  c_B13D_L13N_MRCC ] ; # IO_L13N_T2_MRCC_13            2                  13    HR        
set_property PACKAGE_PIN  U15   [get_ports  i_B13D_L14P_SRCC ] ; # IO_L14P_T2_SRCC_13            2                  13    HR        
set_property PACKAGE_PIN  V15   [get_ports  i_B13D_L14N_SRCC ] ; # IO_L14N_T2_SRCC_13            2                  13    HR        
## set_property PACKAGE_PIN  T14   [get_ports  o_B13_L15P       ] ; # IO_L15P_T2_DQS_13             2                  13    HR        
## set_property PACKAGE_PIN  T15   [get_ports  o_B13_L15N       ] ; # IO_L15N_T2_DQS_13             2                  13    HR        
## set_property PACKAGE_PIN  W15   [get_ports  o_B13_L16P       ] ; # IO_L16P_T2_13                 2                  13    HR        
## set_property PACKAGE_PIN  W16   [get_ports io_B13_L16N       ] ; # IO_L16N_T2_13                 2                  13    HR        
## set_property PACKAGE_PIN  T16   [get_ports  o_B13_L17P       ] ; # IO_L17P_T2_13                 2                  13    HR        
## set_property PACKAGE_PIN  U16   [get_ports  o_B13_L17N       ] ; # IO_L17N_T2_13                 2                  13    HR        


## set_property PACKAGE_PIN  P20  [get_ports xx] ; # IO_0_14                       NA                 14    HR        
## set_property PACKAGE_PIN  P22  [get_ports xx] ; # IO_L1P_T0_D00_MOSI_14         0                  14    HR        
## set_property PACKAGE_PIN  R22  [get_ports xx] ; # IO_L1N_T0_D01_DIN_14          0                  14    HR        
## set_property PACKAGE_PIN  P21  [get_ports xx] ; # IO_L2P_T0_D02_14              0                  14    HR        
## set_property PACKAGE_PIN  R21  [get_ports xx] ; # IO_L2N_T0_D03_14              0                  14    HR        
## set_property PACKAGE_PIN  U22  [get_ports xx] ; # IO_L3P_T0_DQS_PUDC_B_14       0                  14    HR        
## set_property PACKAGE_PIN  V22  [get_ports xx] ; # IO_L3N_T0_DQS_EMCCLK_14       0                  14    HR        
## set_property PACKAGE_PIN  T21  [get_ports o_B14_L4P] ; # IO_L4P_T0_D04_14              0                  14    HR        
## set_property PACKAGE_PIN  U21  [get_ports o_B14_L4N] ; # IO_L4N_T0_D05_14              0                  14    HR        
## set_property PACKAGE_PIN  P19  [get_ports o_B14_L5P] ; # IO_L5P_T0_D06_14              0                  14    HR        
## set_property PACKAGE_PIN  R19  [get_ports o_B14_L5N] ; # IO_L5N_T0_D07_14              0                  14    HR        
## set_property PACKAGE_PIN  T19  [get_ports xx] ; # IO_L6P_T0_FCS_B_14            0                  14    HR        
## set_property PACKAGE_PIN  T20  [get_ports o_B14_L6N] ; # IO_L6N_T0_D08_VREF_14         0                  14    HR        
## set_property PACKAGE_PIN  W21  [get_ports o_B14_L7P] ; # IO_L7P_T1_D09_14              1                  14    HR        
## set_property PACKAGE_PIN  W22  [get_ports o_B14_L7N] ; # IO_L7N_T1_D10_14              1                  14    HR        
## set_property PACKAGE_PIN  AA20 [get_ports o_B14_L8P] ; # IO_L8P_T1_D11_14              1                  14    HR        
## set_property PACKAGE_PIN  AA21 [get_ports o_B14_L8N ] ; # IO_L8N_T1_D12_14              1                  14    HR        
## set_property PACKAGE_PIN  Y21  [get_ports o_B14_L9P ] ; # IO_L9P_T1_DQS_14              1                  14    HR        
## set_property PACKAGE_PIN  Y22  [get_ports o_B14_L9N ] ; # IO_L9N_T1_DQS_D13_14          1                  14    HR        
## set_property PACKAGE_PIN  AB21 [get_ports o_B14_L10P] ; # IO_L10P_T1_D14_14             1                  14    HR        
## set_property PACKAGE_PIN  AB22 [get_ports xx] ; # IO_L10N_T1_D15_14             1                  14    HR        
## set_property PACKAGE_PIN  U20  [get_ports io_B14_L11P_SRCC] ; # IO_L11P_T1_SRCC_14            1                  14    HR        
## set_property PACKAGE_PIN  V20  [get_ports io_B14_L11N_SRCC] ; # IO_L11N_T1_SRCC_14            1                  14    HR        
## set_property PACKAGE_PIN  W19  [get_ports io_B14_L12P_MRCC] ; # IO_L12P_T1_MRCC_14            1                  14    HR        
## set_property PACKAGE_PIN  W20  [get_ports io_B14_L12N_MRCC] ; # IO_L12N_T1_MRCC_14            1                  14    HR        
## set_property PACKAGE_PIN  Y18  [get_ports io_B14_L13P_MRCC] ; # IO_L13P_T2_MRCC_14            2                  14    HR        
## set_property PACKAGE_PIN  Y19  [get_ports io_B14_L13N_MRCC] ; # IO_L13N_T2_MRCC_14            2                  14    HR        
## set_property PACKAGE_PIN  V18  [get_ports io_B14_L14P_SRCC] ; # IO_L14P_T2_SRCC_14            2                  14    HR        
## set_property PACKAGE_PIN  V19  [get_ports io_B14_L14N_SRCC] ; # IO_L14N_T2_SRCC_14            2                  14    HR        
## set_property PACKAGE_PIN  AA19 [get_ports xx] ; # IO_L15P_T2_DQS_RDWR_B_14      2                  14    HR        
## set_property PACKAGE_PIN  AB20 [get_ports xx] ; # IO_L15N_T2_DQS_DOUT_CSO_B_14  2                  14    HR        
## set_property PACKAGE_PIN  V17  [get_ports xx] ; # IO_L16P_T2_CSI_B_14           2                  14    HR        
## set_property PACKAGE_PIN  W17  [get_ports o_B14_L16N] ; # IO_L16N_T2_A15_D31_14         2                  14    HR        
## set_property PACKAGE_PIN  AA18 [get_ports o_B14_L17P] ; # IO_L17P_T2_A14_D30_14         2                  14    HR        
## set_property PACKAGE_PIN  AB18 [get_ports o_B14_L17N] ; # IO_L17N_T2_A13_D29_14         2                  14    HR        
## set_property PACKAGE_PIN  U17  [get_ports o_B14_L18P] ; # IO_L18P_T2_A12_D28_14         2                  14    HR        
## set_property PACKAGE_PIN  U18  [get_ports o_B14_L18N] ; # IO_L18N_T2_A11_D27_14         2                  14    HR        
## set_property PACKAGE_PIN  P14  [get_ports o_B14_L19P] ; # IO_L19P_T3_A10_D26_14         3                  14    HR        
## set_property PACKAGE_PIN  R14  [get_ports o_B14_L19N] ; # IO_L19N_T3_A09_D25_VREF_14    3                  14    HR        
## set_property PACKAGE_PIN  R18  [get_ports o_B14_L20P] ; # IO_L20P_T3_A08_D24_14         3                  14    HR        
## set_property PACKAGE_PIN  T18  [get_ports o_B14_L20N] ; # IO_L20N_T3_A07_D23_14         3                  14    HR        
## set_property PACKAGE_PIN  N17  [get_ports o_B14_L21P] ; # IO_L21P_T3_DQS_14             3                  14    HR        
## set_property PACKAGE_PIN  P17  [get_ports o_B14_L21N] ; # IO_L21N_T3_DQS_A06_D22_14     3                  14    HR        
## set_property PACKAGE_PIN  P15  [get_ports o_B14_L22P] ; # IO_L22P_T3_A05_D21_14         3                  14    HR        
## set_property PACKAGE_PIN  R16  [get_ports o_B14_L22N] ; # IO_L22N_T3_A04_D20_14         3                  14    HR        
## set_property PACKAGE_PIN  N13  [get_ports i_B14_L23P] ; # IO_L23P_T3_A03_D19_14         3                  14    HR        
## set_property PACKAGE_PIN  N14  [get_ports i_B14_L23N] ; # IO_L23N_T3_A02_D18_14         3                  14    HR        
## set_property PACKAGE_PIN  P16  [get_ports i_B14_L24P] ; # IO_L24P_T3_A01_D17_14         3                  14    HR        
## set_property PACKAGE_PIN  R17  [get_ports i_B14_L24N] ; # IO_L24N_T3_A00_D16_14         3                  14    HR        
## set_property PACKAGE_PIN  N15  [get_ports xx] ; # IO_25_14                      NA                 14    HR      
  

## set_property PACKAGE_PIN  J16  [get_ports  o_B15_0_] ; # IO_0_15                       NA                 15    HR        
set_property PACKAGE_PIN  H13  [get_ports io_B15_L1P_AD0P] ; # IO_L1P_T0_AD0P_15             0                  15    HR        
set_property PACKAGE_PIN  G13  [get_ports io_B15_L1N_AD0N] ; # IO_L1N_T0_AD0N_15             0                  15    HR        
set_property PACKAGE_PIN  G15  [get_ports io_B15_L2P_AD8P] ; # IO_L2P_T0_AD8P_15             0                  15    HR        
set_property PACKAGE_PIN  G16  [get_ports io_B15_L2N_AD8N] ; # IO_L2N_T0_AD8N_15             0                  15    HR        
set_property PACKAGE_PIN  J14  [get_ports io_B15_L3P_AD1P] ; # IO_L3P_T0_DQS_AD1P_15         0                  15    HR        
set_property PACKAGE_PIN  H14  [get_ports io_B15_L3N_AD1N] ; # IO_L3N_T0_DQS_AD1N_15         0                  15    HR        
## set_property PACKAGE_PIN  G17  [get_ports _B15_L4P] ; # IO_L4P_T0_15                  0                  15    HR        
## set_property PACKAGE_PIN  G18  [get_ports _B15_L4N] ; # IO_L4N_T0_15                  0                  15    HR        
set_property PACKAGE_PIN  J15  [get_ports io_B15_L5P_AD9P    ] ; # IO_L5P_T0_AD9P_15             0                  15    HR        
set_property PACKAGE_PIN  H15  [get_ports io_B15_L5N_AD9N    ] ; # IO_L5N_T0_AD9N_15             0                  15    HR        
## set_property PACKAGE_PIN  H17  [get_ports o_B15_L6P         ] ; # IO_L6P_T0_15                  0                  15    HR        
## set_property PACKAGE_PIN  H18  [get_ports o_B15_L6N         ] ; # IO_L6N_T0_VREF_15             0                  15    HR        
set_property PACKAGE_PIN  J22  [get_ports i_B15D_L7P         ] ; # IO_L7P_T1_AD2P_15             1                  15    HR        
set_property PACKAGE_PIN  H22  [get_ports i_B15D_L7N         ] ; # IO_L7N_T1_AD2N_15             1                  15    HR        
set_property PACKAGE_PIN  H20  [get_ports i_B15D_L8P         ] ; # IO_L8P_T1_AD10P_15            1                  15    HR        
set_property PACKAGE_PIN  G20  [get_ports i_B15D_L8N         ] ; # IO_L8N_T1_AD10N_15            1                  15    HR        
set_property PACKAGE_PIN  K21  [get_ports o_B15D_L9P         ] ; # IO_L9P_T1_DQS_AD3P_15         1                  15    HR        
set_property PACKAGE_PIN  K22  [get_ports o_B15D_L9N         ] ; # IO_L9N_T1_DQS_AD3N_15         1                  15    HR        
## set_property PACKAGE_PIN  M21  [get_ports _B15_L10P_AD11P] ; # IO_L10P_T1_AD11P_15           1                  15    HR        
## set_property PACKAGE_PIN  L21  [get_ports _B15_L10N_AD11N] ; # IO_L10N_T1_AD11N_15           1                  15    HR        
## set_property PACKAGE_PIN  J20  [get_ports _B15_L11P_SRCC ] ; # IO_L11P_T1_SRCC_15            1                  15    HR        
## set_property PACKAGE_PIN  J21  [get_ports _B15_L11N_SRCC ] ; # IO_L11N_T1_SRCC_15            1                  15    HR        
set_property PACKAGE_PIN  J19  [get_ports c_B15D_L12P_MRCC ] ; # IO_L12P_T1_MRCC_15            1                  15    HR        
set_property PACKAGE_PIN  H19  [get_ports c_B15D_L12N_MRCC ] ; # IO_L12N_T1_MRCC_15            1                  15    HR        
set_property PACKAGE_PIN  K18  [get_ports c_B15D_L13P_MRCC ] ; # IO_L13P_T2_MRCC_15            2                  15    HR        
set_property PACKAGE_PIN  K19  [get_ports c_B15D_L13N_MRCC ] ; # IO_L13N_T2_MRCC_15            2                  15    HR        
## set_property PACKAGE_PIN  L19  [get_ports _B15_L14P_SRCC ] ; # IO_L14P_T2_SRCC_15            2                  15    HR        
## set_property PACKAGE_PIN  L20  [get_ports _B15_L14N_SRCC ] ; # IO_L14N_T2_SRCC_15            2                  15    HR        
set_property PACKAGE_PIN  N22  [get_ports o_B15D_L15P      ] ; # IO_L15P_T2_DQS_15             2                  15    HR        
set_property PACKAGE_PIN  M22  [get_ports o_B15D_L15N      ] ; # IO_L15N_T2_DQS_ADV_B_15       2                  15    HR        
## set_property PACKAGE_PIN  M18  [get_ports _B15_L16P      ] ; # IO_L16P_T2_A28_15             2                  15    HR        
## set_property PACKAGE_PIN  L18  [get_ports _B15_L16N      ] ; # IO_L16N_T2_A27_15             2                  15    HR        
set_property PACKAGE_PIN  N18  [get_ports i_B15D_L17P      ] ; # IO_L17P_T2_A26_15             2                  15    HR        
set_property PACKAGE_PIN  N19  [get_ports i_B15D_L17N      ] ; # IO_L17N_T2_A25_15             2                  15    HR        
set_property PACKAGE_PIN  N20  [get_ports i_B15D_L18P      ] ; # IO_L18P_T2_A24_15             2                  15    HR        
set_property PACKAGE_PIN  M20  [get_ports i_B15D_L18N      ] ; # IO_L18N_T2_A23_15             2                  15    HR        
## set_property PACKAGE_PIN  K13  [get_ports _B15_L19P      ] ; # IO_L19P_T3_A22_15             3                  15    HR        
## set_property PACKAGE_PIN  K14  [get_ports _B15_L19N      ] ; # IO_L19N_T3_A21_VREF_15        3                  15    HR        
set_property PACKAGE_PIN  M13  [get_ports io_B15_L20P      ] ; # IO_L20P_T3_A20_15             3                  15    HR        
set_property PACKAGE_PIN  L13  [get_ports io_B15_L20N      ] ; # IO_L20N_T3_A19_15             3                  15    HR        
set_property PACKAGE_PIN  K17  [get_ports o_B15_L21P      ] ; # IO_L21P_T3_DQS_15             3                  15    HR        
set_property PACKAGE_PIN  J17  [get_ports i_B15_L21N      ] ; # IO_L21N_T3_DQS_A18_15         3                  15    HR        
set_property PACKAGE_PIN  L14  [get_ports i_B15_L22P      ] ; # IO_L22P_T3_A17_15             3                  15    HR        
set_property PACKAGE_PIN  L15  [get_ports o_B15_L22N      ] ; # IO_L22N_T3_A16_15             3                  15    HR        
set_property PACKAGE_PIN  L16  [get_ports o_B15_L23P      ] ; # IO_L23P_T3_FOE_B_15           3                  15    HR        
set_property PACKAGE_PIN  K16  [get_ports o_B15_L23N      ] ; # IO_L23N_T3_FWE_B_15           3                  15    HR        
set_property PACKAGE_PIN  M15  [get_ports o_B15_L24P      ] ; # IO_L24P_T3_RS1_15             3                  15    HR        
set_property PACKAGE_PIN  M16  [get_ports o_B15_L24N      ] ; # IO_L24N_T3_RS0_15             3                  15    HR        
set_property PACKAGE_PIN  M17  [get_ports o_B15_25        ] ; # IO_25_15                      NA                 15    HR        


## set_property PACKAGE_PIN  F15  [get_ports _B16_0_  ] ; # IO_0_16                       NA                 16    HR        
set_property PACKAGE_PIN  F13  [get_ports i_B16_L1P ] ; # IO_L1P_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  F14  [get_ports i_B16_L1N ] ; # IO_L1N_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  F16  [get_ports i_B16_L2P ] ; # IO_L2P_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  E17  [get_ports i_B16_L2N ] ; # IO_L2N_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  C14  [get_ports i_B16_L3P ] ; # IO_L3P_T0_DQS_16              0                  16    HR        
set_property PACKAGE_PIN  C15  [get_ports i_B16_L3N ] ; # IO_L3N_T0_DQS_16              0                  16    HR        
set_property PACKAGE_PIN  E13  [get_ports i_B16_L4P ] ; # IO_L4P_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  E14  [get_ports i_B16_L4N ] ; # IO_L4N_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  E16  [get_ports i_B16_L5P ] ; # IO_L5P_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  D16  [get_ports i_B16_L5N ] ; # IO_L5N_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  D14  [get_ports i_B16_L6P ] ; # IO_L6P_T0_16                  0                  16    HR        
set_property PACKAGE_PIN  D15  [get_ports i_B16_L6N ] ; # IO_L6N_T0_VREF_16             0                  16    HR        
set_property PACKAGE_PIN  B15  [get_ports  io_B16_L7P ] ; # IO_L7P_T1_16                  1                  16    HR        
set_property PACKAGE_PIN  B16  [get_ports  io_B16_L7N ] ; # IO_L7N_T1_16                  1                  16    HR        
## set_property PACKAGE_PIN  C13  [get_ports _B16_L8P ] ; # IO_L8P_T1_16                  1                  16    HR        
set_property PACKAGE_PIN  B13  [get_ports  io_B16_L8N ] ; # IO_L8N_T1_16                  1                  16    HR        
set_property PACKAGE_PIN  A15  [get_ports  io_B16_L9P ] ; # IO_L9P_T1_DQS_16              1                  16    HR        
set_property PACKAGE_PIN  A16  [get_ports  io_B16_L9N ] ; # IO_L9N_T1_DQS_16              1                  16    HR        
set_property PACKAGE_PIN  A13  [get_ports  io_B16_L10P] ; # IO_L10P_T1_16                 1                  16    HR        
set_property PACKAGE_PIN  A14  [get_ports  io_B16_L10N] ; # IO_L10N_T1_16                 1                  16    HR        
set_property PACKAGE_PIN  B17  [get_ports  io_B16_L11P] ; # IO_L11P_T1_SRCC_16            1                  16    HR        
## set_property PACKAGE_PIN  B18  [get_ports _B16_L11N] ; # IO_L11N_T1_SRCC_16            1                  16    HR        
set_property PACKAGE_PIN  D17  [get_ports io_B16_L12P] ; # IO_L12P_T1_MRCC_16            1                  16    HR        
## set_property PACKAGE_PIN  C17  [get_ports _B16_L12N] ; # IO_L12N_T1_MRCC_16            1                  16    HR        
set_property PACKAGE_PIN  C18  [get_ports io_B16_L13P] ; # IO_L13P_T2_MRCC_16            2                  16    HR        
## set_property PACKAGE_PIN  C19  [get_ports _B16_L13N] ; # IO_L13N_T2_MRCC_16            2                  16    HR        
set_property PACKAGE_PIN  E19  [get_ports io_B16_L14P] ; # IO_L14P_T2_SRCC_16            2                  16    HR        
## set_property PACKAGE_PIN  D19  [get_ports _B16_L14N] ; # IO_L14N_T2_SRCC_16            2                  16    HR        
set_property PACKAGE_PIN  F18  [get_ports io_B16_L15P] ; # IO_L15P_T2_DQS_16             2                  16    HR        
## set_property PACKAGE_PIN  E18  [get_ports _B16_L15N] ; # IO_L15N_T2_DQS_16             2                  16    HR        
set_property PACKAGE_PIN  B20  [get_ports  i_B16_L16P] ; # IO_L16P_T2_16                 2                  16    HR        
set_property PACKAGE_PIN  A20  [get_ports  i_B16_L16N] ; # IO_L16N_T2_16                 2                  16    HR        
set_property PACKAGE_PIN  A18  [get_ports  o_B16_L17P] ; # IO_L17P_T2_16                 2                  16    HR        
set_property PACKAGE_PIN  A19  [get_ports  o_B16_L17N] ; # IO_L17N_T2_16                 2                  16    HR        
set_property PACKAGE_PIN  F19  [get_ports io_B16_L18P] ; # IO_L18P_T2_16                 2                  16    HR        
## set_property PACKAGE_PIN  F20  [get_ports _B16_L18N] ; # IO_L18N_T2_16                 2                  16    HR        
## set_property PACKAGE_PIN  D20  [get_ports _B16_L19P] ; # IO_L19P_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  C20  [get_ports o_B16_L19N] ; # IO_L19N_T3_VREF_16            3                  16    HR        
set_property PACKAGE_PIN  C22  [get_ports o_B16_L20P] ; # IO_L20P_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  B22  [get_ports o_B16_L20N] ; # IO_L20N_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  B21  [get_ports i_B16_L21P] ; # IO_L21P_T3_DQS_16             3                  16    HR        
set_property PACKAGE_PIN  A21  [get_ports o_B16_L21N] ; # IO_L21N_T3_DQS_16             3                  16    HR        
set_property PACKAGE_PIN  E22  [get_ports i_B16_L22P] ; # IO_L22P_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  D22  [get_ports o_B16_L22N] ; # IO_L22N_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  E21  [get_ports i_B16_L23P] ; # IO_L23P_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  D21  [get_ports i_B16_L23N] ; # IO_L23N_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  G21  [get_ports i_B16_L24P] ; # IO_L24P_T3_16                 3                  16    HR        
set_property PACKAGE_PIN  G22  [get_ports i_B16_L24N] ; # IO_L24N_T3_16                 3                  16    HR        
## set_property PACKAGE_PIN  F21  [get_ports _B16_25  ] ; # IO_25_16                      NA                 16    HR        


## set_property PACKAGE_PIN  T3   [get_ports _B34_0_         ] ; # IO_0_34                       NA                 34    HR        
set_property PACKAGE_PIN  T1   [get_ports   o_B34D_L1P       ] ; # IO_L1P_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  U1   [get_ports   o_B34D_L1N       ] ; # IO_L1N_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  U2   [get_ports   o_B34D_L2P       ] ; # IO_L2P_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  V2   [get_ports   o_B34D_L2N       ] ; # IO_L2N_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  R3   [get_ports   o_B34D_L3P       ] ; # IO_L3P_T0_DQS_34              0                  34    HR        
set_property PACKAGE_PIN  R2   [get_ports   o_B34D_L3N       ] ; # IO_L3N_T0_DQS_34              0                  34    HR        
set_property PACKAGE_PIN  W2   [get_ports   o_B34D_L4P       ] ; # IO_L4P_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  Y2   [get_ports   o_B34D_L4N       ] ; # IO_L4N_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  W1   [get_ports   o_B34D_L5P        ] ; # IO_L5P_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  Y1   [get_ports   o_B34D_L5N        ] ; # IO_L5N_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  U3   [get_ports   o_B34D_L6P       ] ; # IO_L6P_T0_34                  0                  34    HR        
set_property PACKAGE_PIN  V3   [get_ports   o_B34D_L6N       ] ; # IO_L6N_T0_VREF_34             0                  34    HR        
set_property PACKAGE_PIN  AA1  [get_ports   o_B34D_L7P       ] ; # IO_L7P_T1_34                  1                  34    HR        
set_property PACKAGE_PIN  AB1  [get_ports   o_B34D_L7N       ] ; # IO_L7N_T1_34                  1                  34    HR        
set_property PACKAGE_PIN  AB3  [get_ports   o_B34D_L8P       ] ; # IO_L8P_T1_34                  1                  34    HR        
set_property PACKAGE_PIN  AB2  [get_ports   o_B34D_L8N       ] ; # IO_L8N_T1_34                  1                  34    HR        
set_property PACKAGE_PIN  Y3   [get_ports   o_B34D_L9P       ] ; # IO_L9P_T1_DQS_34              1                  34    HR        
set_property PACKAGE_PIN  AA3  [get_ports   o_B34D_L9N       ] ; # IO_L9N_T1_DQS_34              1                  34    HR        
set_property PACKAGE_PIN  AA5  [get_ports   o_B34D_L10P      ] ; # IO_L10P_T1_34                 1                  34    HR        
set_property PACKAGE_PIN  AB5  [get_ports   o_B34D_L10N      ] ; # IO_L10N_T1_34                 1                  34    HR        
## set_property PACKAGE_PIN  Y4   [get_ports   c_B34D_L11P_SRCC ] ; # IO_L11P_T1_SRCC_34            1                  34    HR        
## set_property PACKAGE_PIN  AA4  [get_ports   c_B34D_L11N_SRCC ] ; # IO_L11N_T1_SRCC_34            1                  34    HR        
set_property PACKAGE_PIN  V4   [get_ports   c_B34D_L12P_MRCC ] ; # IO_L12P_T1_MRCC_34            1                  34    HR        
set_property PACKAGE_PIN  W4   [get_ports   c_B34D_L12N_MRCC ] ; # IO_L12N_T1_MRCC_34            1                  34    HR        
set_property PACKAGE_PIN  R4   [get_ports   o_B34D_L13P_MRCC ] ; # IO_L13P_T2_MRCC_34            2                  34    HR        
set_property PACKAGE_PIN  T4   [get_ports   o_B34D_L13N_MRCC ] ; # IO_L13N_T2_MRCC_34            2                  34    HR        
## set_property PACKAGE_PIN  T5   [get_ports   c_B34D_L14P_SRCC ] ; # IO_L14P_T2_SRCC_34            2                  34    HR        
## set_property PACKAGE_PIN  U5   [get_ports   c_B34D_L14N_SRCC ] ; # IO_L14N_T2_SRCC_34            2                  34    HR        
set_property PACKAGE_PIN  W6   [get_ports   o_B34D_L15P      ] ; # IO_L15P_T2_DQS_34             2                  34    HR        
set_property PACKAGE_PIN  W5   [get_ports   o_B34D_L15N      ] ; # IO_L15N_T2_DQS_34             2                  34    HR        
## set_property PACKAGE_PIN  U6   [get_ports   o_B34D_L16P      ] ; # IO_L16P_T2_34                 2                  34    HR        
## set_property PACKAGE_PIN  V5   [get_ports   o_B34D_L16N      ] ; # IO_L16N_T2_34                 2                  34    HR        
## set_property PACKAGE_PIN  R6   [get_ports   o_B34D_L17P      ] ; # IO_L17P_T2_34                 2                  34    HR        
## set_property PACKAGE_PIN  T6   [get_ports   o_B34D_L17N      ] ; # IO_L17N_T2_34                 2                  34    HR        
set_property PACKAGE_PIN  Y6   [get_ports   o_B34D_L18P      ] ; # IO_L18P_T2_34                 2                  34    HR        
set_property PACKAGE_PIN  AA6  [get_ports   o_B34D_L18N      ] ; # IO_L18N_T2_34                 2                  34    HR        
## set_property PACKAGE_PIN  V7   [get_ports   o_B34D_L19P      ] ; # IO_L19P_T3_34                 3                  34    HR        
## set_property PACKAGE_PIN  W7   [get_ports   o_B34D_L19N      ] ; # IO_L19N_T3_VREF_34            3                  34    HR        
set_property PACKAGE_PIN  AB7  [get_ports   o_B34D_L20P      ] ; # IO_L20P_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  AB6  [get_ports   o_B34D_L20N      ] ; # IO_L20N_T3_34                 3                  34    HR        
## set_property PACKAGE_PIN  V9   [get_ports   o_B34D_L21P      ] ; # IO_L21P_T3_DQS_34             3                  34    HR        
## set_property PACKAGE_PIN  V8   [get_ports   o_B34D_L21N      ] ; # IO_L21N_T3_DQS_34             3                  34    HR        
set_property PACKAGE_PIN  AA8  [get_ports   o_B34D_L22P      ] ; # IO_L22P_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  AB8  [get_ports   o_B34D_L22N      ] ; # IO_L22N_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  Y8   [get_ports   o_B34D_L23P      ] ; # IO_L23P_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  Y7   [get_ports   o_B34D_L23N      ] ; # IO_L23N_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  W9   [get_ports   o_B34D_L24P      ] ; # IO_L24P_T3_34                 3                  34    HR        
set_property PACKAGE_PIN  Y9   [get_ports   o_B34D_L24N      ] ; # IO_L24N_T3_34                 3                  34    HR        
## set_property PACKAGE_PIN  U7   [get_ports _B34_25         ] ; # IO_25_34                      NA                 34    HR        


## set_property PACKAGE_PIN  F4   [get_ports  o_B35_0_         ] ; # IO_0_35                       NA                 35    HR        
set_property PACKAGE_PIN  B1   [get_ports  o_B35D_L1P       ] ; # IO_L1P_T0_AD4P_35             0                  35    HR        
set_property PACKAGE_PIN  A1   [get_ports  o_B35D_L1N       ] ; # IO_L1N_T0_AD4N_35             0                  35    HR        
set_property PACKAGE_PIN  C2   [get_ports  o_B35D_L2P       ] ; # IO_L2P_T0_AD12P_35            0                  35    HR        
set_property PACKAGE_PIN  B2   [get_ports  o_B35D_L2N       ] ; # IO_L2N_T0_AD12N_35            0                  35    HR        
set_property PACKAGE_PIN  E1   [get_ports  o_B35D_L3P       ] ; # IO_L3P_T0_DQS_AD5P_35         0                  35    HR        
set_property PACKAGE_PIN  D1   [get_ports  o_B35D_L3N       ] ; # IO_L3N_T0_DQS_AD5N_35         0                  35    HR        
set_property PACKAGE_PIN  E2   [get_ports  o_B35D_L4P       ] ; # IO_L4P_T0_35                  0                  35    HR        
set_property PACKAGE_PIN  D2   [get_ports  o_B35D_L4N       ] ; # IO_L4N_T0_35                  0                  35    HR        
set_property PACKAGE_PIN  G1   [get_ports  o_B35D_L5P       ] ; # IO_L5P_T0_AD13P_35            0                  35    HR        
set_property PACKAGE_PIN  F1   [get_ports  o_B35D_L5N       ] ; # IO_L5N_T0_AD13N_35            0                  35    HR        
## set_property PACKAGE_PIN  F3   [get_ports  i_B35_L6P        ] ; # IO_L6P_T0_35                  0                  35    HR        
## set_property PACKAGE_PIN  E3   [get_ports io_B35_L6N        ] ; # IO_L6N_T0_VREF_35             0                  35    HR        
set_property PACKAGE_PIN  K1   [get_ports  o_B35D_L7P       ] ; # IO_L7P_T1_AD6P_35             1                  35    HR        
set_property PACKAGE_PIN  J1   [get_ports  o_B35D_L7N       ] ; # IO_L7N_T1_AD6N_35             1                  35    HR        
set_property PACKAGE_PIN  H2   [get_ports  o_B35D_L8P       ] ; # IO_L8P_T1_AD14P_35            1                  35    HR        
set_property PACKAGE_PIN  G2   [get_ports  o_B35D_L8N       ] ; # IO_L8N_T1_AD14N_35            1                  35    HR        
set_property PACKAGE_PIN  K2   [get_ports  o_B35D_L9P       ] ; # IO_L9P_T1_DQS_AD7P_35         1                  35    HR        
set_property PACKAGE_PIN  J2   [get_ports  o_B35D_L9N       ] ; # IO_L9N_T1_DQS_AD7N_35         1                  35    HR        
## set_property PACKAGE_PIN  J5   [get_ports  o_B35D_L10P      ] ; # IO_L10P_T1_AD15P_35           1                  35    HR        
## set_property PACKAGE_PIN  H5   [get_ports  o_B35D_L10N      ] ; # IO_L10N_T1_AD15N_35           1                  35    HR        
set_property PACKAGE_PIN  H3   [get_ports  o_B35D_L11P_SRCC ] ; # IO_L11P_T1_SRCC_35            1                  35    HR        
set_property PACKAGE_PIN  G3   [get_ports  o_B35D_L11N_SRCC ] ; # IO_L11N_T1_SRCC_35            1                  35    HR        
set_property PACKAGE_PIN  H4   [get_ports  c_B35D_L12P_MRCC ] ; # IO_L12P_T1_MRCC_35            1                  35    HR        
set_property PACKAGE_PIN  G4   [get_ports  c_B35D_L12N_MRCC ] ; # IO_L12N_T1_MRCC_35            1                  35    HR        
set_property PACKAGE_PIN  K4   [get_ports  o_B35D_L13P_MRCC ] ; # IO_L13P_T2_MRCC_35            2                  35    HR        
set_property PACKAGE_PIN  J4   [get_ports  o_B35D_L13N_MRCC ] ; # IO_L13N_T2_MRCC_35            2                  35    HR        
set_property PACKAGE_PIN  L3   [get_ports  o_B35D_L14P_SRCC ] ; # IO_L14P_T2_SRCC_35            2                  35    HR        
set_property PACKAGE_PIN  K3   [get_ports  o_B35D_L14N_SRCC ] ; # IO_L14N_T2_SRCC_35            2                  35    HR        
set_property PACKAGE_PIN  M1   [get_ports  o_B35D_L15P      ] ; # IO_L15P_T2_DQS_35             2                  35    HR        
set_property PACKAGE_PIN  L1   [get_ports  o_B35D_L15N      ] ; # IO_L15N_T2_DQS_35             2                  35    HR        
set_property PACKAGE_PIN  M3   [get_ports  o_B35D_L16P      ] ; # IO_L16P_T2_35                 2                  35    HR        
set_property PACKAGE_PIN  M2   [get_ports  o_B35D_L16N      ] ; # IO_L16N_T2_35                 2                  35    HR        
## set_property PACKAGE_PIN  K6   [get_ports  o_B35D_L17P      ] ; # IO_L17P_T2_35                 2                  35    HR        
## set_property PACKAGE_PIN  J6   [get_ports  o_B35D_L17N      ] ; # IO_L17N_T2_35                 2                  35    HR        
set_property PACKAGE_PIN  L5   [get_ports  o_B35D_L18P      ] ; # IO_L18P_T2_35                 2                  35    HR        
set_property PACKAGE_PIN  L4   [get_ports  o_B35D_L18N      ] ; # IO_L18N_T2_35                 2                  35    HR        
set_property PACKAGE_PIN  N4   [get_ports  o_B35D_L19P      ] ; # IO_L19P_T3_35                 3                  35    HR        
set_property PACKAGE_PIN  N3   [get_ports  o_B35D_L19N      ] ; # IO_L19N_T3_VREF_35            3                  35    HR        
set_property PACKAGE_PIN  R1   [get_ports  o_B35D_L20P      ] ; # IO_L20P_T3_35                 3                  35    HR        
set_property PACKAGE_PIN  P1   [get_ports  o_B35D_L20N      ] ; # IO_L20N_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  P5   [get_ports  o_B35D_L21P      ] ; # IO_L21P_T3_DQS_35             3                  35    HR        
## set_property PACKAGE_PIN  P4   [get_ports  o_B35D_L21N      ] ; # IO_L21N_T3_DQS_35             3                  35    HR        
set_property PACKAGE_PIN  P2   [get_ports  o_B35D_L22P      ] ; # IO_L22P_T3_35                 3                  35    HR        
set_property PACKAGE_PIN  N2   [get_ports  o_B35D_L22N      ] ; # IO_L22N_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  M6   [get_ports  o_B35D_L23P      ] ; # IO_L23P_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  M5   [get_ports  o_B35D_L23N      ] ; # IO_L23N_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  P6   [get_ports  o_B35D_L24P      ] ; # IO_L24P_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  N5   [get_ports  o_B35D_L24N      ] ; # IO_L24N_T3_35                 3                  35    HR        
## set_property PACKAGE_PIN  L6   [get_ports  i_B35_25         ] ; # IO_25_35                      NA                 35    HR        


## Pin   Pin Name                      Memory Byte Group  Bank  I/O Type  
## D7    MGTPTXP3_216                  NA                 216   GTP       
## D9    MGTPRXP3_216                  NA                 216   GTP       
## C7    MGTPTXN3_216                  NA                 216   GTP       
## C9    MGTPRXN3_216                  NA                 216   GTP       
## B6    MGTPTXP2_216                  NA                 216   GTP       
## B10   MGTPRXP2_216                  NA                 216   GTP       
## A6    MGTPTXN2_216                  NA                 216   GTP       
## A10   MGTPRXN2_216                  NA                 216   GTP       
## E6    MGTREFCLK0N_216               NA                 216   GTP       
## F6    MGTREFCLK0P_216               NA                 216   GTP       
## F8    MGTRREF_216                   NA                 216   GTP       
## F10   MGTREFCLK1P_216               NA                 216   GTP       
## E10   MGTREFCLK1N_216               NA                 216   GTP       
## D5    MGTPTXP1_216                  NA                 216   GTP       
## D11   MGTPRXP1_216                  NA                 216   GTP       
## C5    MGTPTXN1_216                  NA                 216   GTP       
## C11   MGTPRXN1_216                  NA                 216   GTP       
## B4    MGTPTXP0_216                  NA                 216   GTP       
## B8    MGTPRXP0_216                  NA                 216   GTP       
## A4    MGTPTXN0_216                  NA                 216   GTP       
## A8    MGTPRXN0_216                  NA                 216   GTP       

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


############################################################################
## TODO: System Clock
############################################################################
##$$ bank 13
set_property PACKAGE_PIN W11 [get_ports sys_clkp]
set_property PACKAGE_PIN W12 [get_ports sys_clkn]
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

## TODO: define clock - mcs_eeprom_fifo_clk
create_generated_clock  -name mcs_eeprom_fifo_clk      [get_pins  clk_wiz_0_3_1_inst/inst/plle2_adv_inst/CLKOUT3]

## TODO: define clock - base_sspi_clk
create_generated_clock  -name base_sspi_clk   [get_pins  clk_wiz_2_2_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - base_adc_clk 
create_generated_clock  -name base_adc_clk    [get_pins  clk_wiz_0_2_3_inst/inst/mmcm_adv_inst/CLKOUT0]

## TODO: define clock - base_adc_alt_clk 
create_generated_clock  -name base_adc_alt_clk  [get_pins  clk_wiz_0_2_3_inst/inst/mmcm_adv_inst/CLKOUT1]

## TODO: define clock - adc_fifo_clk 
create_generated_clock  -name adc_fifo_clk    [get_pins  clk_wiz_0_2_3_inst/inst/mmcm_adv_inst/CLKOUT2]

## TODO: define clock - ref_200M_clk 
create_generated_clock  -name ref_200M_clk    [get_pins  clk_wiz_0_inst/inst/mmcm_adv_inst/CLKOUT0]


## async for MCS
# mcs_clk
# lan_clk
## for base_sspi_clk
## for adc
set_clock_groups -asynchronous          \
-group [get_clocks mcs_clk            ] \
-group [get_clocks lan_clk            ] \
-group [get_clocks sys_clk            ] \
-group [get_clocks xadc_clk           ] \
-group [get_clocks mcs_eeprom_fifo_clk] \
-group [get_clocks base_sspi_clk      ] \
-group [get_clocks base_adc_clk       ] \
-group [get_clocks base_adc_alt_clk   ] \
-group [get_clocks adc_fifo_clk       ] \
-group [get_clocks ref_200M_clk       ]



############################################################################
## TODO: DAC clock 
############################################################################


##$$ 400MHz 2.5ns for dac_clk        // CLK_COUT_P ## used for dac clocks
##$$ 400MHz 2.5ns for dac0_dco_clk   // DAC0_DCO_P # unused
##$$ 400MHz 2.5ns for dac1_dco_clk   // DAC1_DCO_P # unused

#create_clock -period 2.500 -name dac_clk      [get_ports i_B13D_L13P_MRCC]
#create_clock -period 2.500 -name dac0_dco_clk [get_ports i_B34D_L14P_SRCC]
#create_clock -period 2.500 -name dac1_dco_clk [get_ports i_B35D_L14N_SRCC]


## TODO: downclocking 400MHz 2.5ns ----////
# --> 200MHz 5ns --> 175.01MHz 5.714ns --> 174.06MHz 5.745ns --> 169.49MHz 5.9ns  --> 166.67MHz 6.0ns 
# --> 161.29MHz 6.2ns --> 158.73MHz 6.3ns --> 156.25MHz 6.4ns --> 152.91MHz 6.54ns
create_clock -period 5.000 -name dac_clk      [get_ports c_B13D_L13P_MRCC]
create_clock -period 5.000 -name dac0_dco_clk [get_ports c_B34D_L14P_SRCC]
create_clock -period 5.000 -name dac1_dco_clk [get_ports c_B35D_L14N_SRCC]


## setup diff termination for clock in ## LVDS_25 with LVCMOS25
set_property DIFF_TERM TRUE [get_ports {c_B13D_L13P_MRCC}]
set_property DIFF_TERM TRUE [get_ports {c_B13D_L13N_MRCC}]



## TODO: dac clock group 
#clk_wiz_1_3_inst
#clk_wiz_1_3_0_inst
#clk_wiz_1_3_1_inst

## TODO: define clock - dac_test_clk // replace clk_out1_200M_clk_wiz_1_2
create_generated_clock  -name dac_test_clk    [get_pins  clk_wiz_1_2_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - dac0_clk // replace clk_out1_400M_clk_wiz_1_0
create_generated_clock  -name dac0_clk        [get_pins  clk_wiz_1_2_0_inst/inst/plle2_adv_inst/CLKOUT0]

## TODO: define clock - dac0_dci_clk // replace clk_out5_400M_clk_wiz_1_0
create_generated_clock  -name dac0_dci_clk    [get_pins  clk_wiz_1_2_0_inst/inst/plle2_adv_inst/CLKOUT1]

## TODO: define clock - dac1_clk // replace clk_out1_400M_clk_wiz_1_1
create_generated_clock  -name dac1_clk        [get_pins  clk_wiz_1_2_1_inst/inst/plle2_adv_inst/CLKOUT2]

## TODO: define clock - dac1_dci_clk // replace clk_out5_400M_clk_wiz_1_1
create_generated_clock  -name dac1_dci_clk    [get_pins  clk_wiz_1_2_1_inst/inst/plle2_adv_inst/CLKOUT0]

## async for DAC
set_clock_groups -asynchronous          \
-group [get_clocks mcs_clk            ] \
-group [get_clocks lan_clk            ] \
-group [get_clocks sys_clk            ] \
-group [get_clocks xadc_clk           ] \
-group [get_clocks mcs_eeprom_fifo_clk] \
-group [get_clocks base_sspi_clk      ] \
-group [get_clocks base_adc_clk       ] \
-group [get_clocks base_adc_alt_clk   ] \
-group [get_clocks adc_fifo_clk       ] \
-group [get_clocks ref_200M_clk       ] \
-group [get_clocks dac_test_clk       ] \
-group [get_clocks dac0_clk           ] \
-group [get_clocks dac0_dci_clk       ] \
-group [get_clocks dac1_clk           ] \
-group [get_clocks dac1_dci_clk       ] 
#


############################################################################
## TODO: ADC clock 
############################################################################

## for serdes ##
#// 9.5ns for serdesCLK_0 @ 210MHz/2
create_clock -period 9.5 -name serdesCLK_0 [get_ports c_B34D_L11P_SRCC]
create_clock -period 9.5 -name serdesCLK_1 [get_ports c_B35D_L11P_SRCC]
#
create_generated_clock -name serdesCLK_0_div [get_pins {adc_wrapper__inst/control_hsadc_dual__inst/serdes[0].serdes_ddr_2lane_in_20bit_out_inst/clkout_buf_inst/O}]
create_generated_clock -name serdesCLK_1_div [get_pins {adc_wrapper__inst/control_hsadc_dual__inst/serdes[1].serdes_ddr_2lane_in_20bit_out_inst/clkout_buf_inst/O}]

## async for ADC
set_clock_groups -asynchronous          \
-group [get_clocks mcs_clk            ] \
-group [get_clocks lan_clk            ] \
-group [get_clocks sys_clk            ] \
-group [get_clocks xadc_clk           ] \
-group [get_clocks mcs_eeprom_fifo_clk] \
-group [get_clocks base_sspi_clk      ] \
-group [get_clocks base_adc_clk       ] \
-group [get_clocks base_adc_alt_clk   ] \
-group [get_clocks adc_fifo_clk       ] \
-group [get_clocks ref_200M_clk       ] \
-group [get_clocks dac_test_clk       ] \
-group [get_clocks dac0_clk           ] \
-group [get_clocks dac0_dci_clk       ] \
-group [get_clocks dac1_clk           ] \
-group [get_clocks dac1_dci_clk       ] \
-group [get_clocks serdesCLK_0        ] \
-group [get_clocks serdesCLK_1        ] \
-group [get_clocks serdesCLK_0_div    ] \
-group [get_clocks serdesCLK_1_div    ] 


## ADC input :  2.4ns or 4.8ns delay for serdesCLK_0 @ 210MHz/2 ...9.5ns

## io delay 
#input  wire  i_B34D_L18P     ## ADC0_DA_P
#input  wire  i_B34D_L22P     ## ADC0_DB_P
#input  wire  i_B35D_L7P      ## ADC1_DA_P
#input  wire  i_B35D_L9P      ## ADC1_DB_P
#
set_input_delay  -clock [get_clocks serdesCLK_0] -max -add_delay  0.500 [get_ports i_B34D_L18P]
set_input_delay  -clock [get_clocks serdesCLK_0] -min -add_delay  0.000 [get_ports i_B34D_L18P]
set_input_delay  -clock [get_clocks serdesCLK_0] -max -add_delay  0.500 [get_ports i_B34D_L18P] -clock_fall
set_input_delay  -clock [get_clocks serdesCLK_0] -min -add_delay  0.000 [get_ports i_B34D_L18P] -clock_fall
#
set_input_delay  -clock [get_clocks serdesCLK_0] -max -add_delay  0.500 [get_ports i_B34D_L22P]
set_input_delay  -clock [get_clocks serdesCLK_0] -min -add_delay  0.000 [get_ports i_B34D_L22P]
set_input_delay  -clock [get_clocks serdesCLK_0] -max -add_delay  0.500 [get_ports i_B34D_L22P] -clock_fall
set_input_delay  -clock [get_clocks serdesCLK_0] -min -add_delay  0.000 [get_ports i_B34D_L22P] -clock_fall
#
set_input_delay  -clock [get_clocks serdesCLK_1] -max -add_delay  0.500 [get_ports i_B35D_L7P]
set_input_delay  -clock [get_clocks serdesCLK_1] -min -add_delay  0.000 [get_ports i_B35D_L7P]
set_input_delay  -clock [get_clocks serdesCLK_1] -max -add_delay  0.500 [get_ports i_B35D_L7P] -clock_fall
set_input_delay  -clock [get_clocks serdesCLK_1] -min -add_delay  0.000 [get_ports i_B35D_L7P] -clock_fall
#
set_input_delay  -clock [get_clocks serdesCLK_1] -max -add_delay  0.500 [get_ports i_B35D_L9P]
set_input_delay  -clock [get_clocks serdesCLK_1] -min -add_delay  0.000 [get_ports i_B35D_L9P]
set_input_delay  -clock [get_clocks serdesCLK_1] -max -add_delay  0.500 [get_ports i_B35D_L9P] -clock_fall
set_input_delay  -clock [get_clocks serdesCLK_1] -min -add_delay  0.000 [get_ports i_B35D_L9P] -clock_fall
#


#output wire  o_B34_L5P       ## ADCx_TPT_B
set_max_delay -to [get_ports o_B34_L5P] 12.0
set_output_delay -clock [get_clocks base_adc_clk] 0.000 [get_ports o_B34_L5P]

#output wire  o_B34D_L6P      ## ADCx_CNV_P
#output wire  o_B34D_L6N      ## ADCx_CNV_N
#output wire  o_B34D_L8P      ## ADCx_CLK_P
#output wire  o_B34D_L8N      ## ADCx_CLK_N
set_max_delay   -to [get_ports o_B34D_L6P] 12.0 ;# <-- 11.1 <-- 10.6 <--9.9
set_max_delay   -to [get_ports o_B34D_L6N] 12.0 ;# <-- 11.1 <-- 10.6 <--9.9
set_max_delay   -to [get_ports o_B34D_L8P] 12.0 ;# <-- 10.1 <--  9.6 <- 9.7  
set_max_delay   -to [get_ports o_B34D_L8N] 12.0 ;# <-- 10.1 <--  9.6 <- 9.7  


###########################################################################
###########################################################################



############################################################################
## TODO: IO property 
############################################################################

## IOSTANDARD ##
# B13
set_property IOSTANDARD LVCMOS25        [get_ports *_B13_*]  ; # due to diff clock LVDS_25
set_property IOSTANDARD LVDS_25         [get_ports *_B13D*]
# B14                             
## set_property IOSTANDARD LVCMOS18     [get_ports *_B14_*]
# B15
set_property IOSTANDARD LVCMOS33        [get_ports *_B15_*]
# B16
set_property IOSTANDARD LVCMOS33        [get_ports *_B16_*]
# B34
set_property IOSTANDARD LVCMOS18        [get_ports *_B34_*]  ; # due to diff signal DIFF_HSTL_I_18
set_property IOSTANDARD DIFF_HSTL_I_18  [get_ports *_B34D*]
# B35
set_property IOSTANDARD LVCMOS18        [get_ports *_B35_*]  ; # due to diff signal DIFF_HSTL_I_18
set_property IOSTANDARD DIFF_HSTL_I_18  [get_ports *_B35D*]


## PULLUP ##
set_property PULLUP true [get_ports io_B13_*]
## set_property PULLUP true [get_ports io_B14_*]
set_property PULLUP true [get_ports io_B15_*]
set_property PULLUP true [get_ports io_B16_*]
set_property PULLUP true [get_ports io_B34_*]
set_property PULLUP true [get_ports io_B35_*]


## INTERNAL_VREF for diff port ##
#set_property INTERNAL_VREF 0.9 [get_iobanks 13]
#set_property INTERNAL_VREF 0.75 [get_iobanks 15]
set_property INTERNAL_VREF 0.75 [get_iobanks 16]
set_property INTERNAL_VREF 0.9 [get_iobanks 34]
set_property INTERNAL_VREF 0.9 [get_iobanks 35]




############################################################################
## TODO: IO delays 
############################################################################

## B13 common
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B13*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B13*]
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B13*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B13*]
#
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports  o_B13*]
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports io_B13*]

## B14 common
#set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports i_B14*]
#set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports i_B14*]
#
#set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports o_B14*]

## B15 common
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B15*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B15*]
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B15*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B15*]
#
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports  o_B15*]
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports io_B15*]

## B16 common
#set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B16*]
#set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B16*]
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B16*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B16*]
#
#set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports  o_B16*]
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports io_B16*]

## B34 common
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B34*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B34*]
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B34*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B34*]
#
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports  o_B34*]
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports io_B34*]

## B35 common
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports  i_B35*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports  i_B35*]
set_input_delay  -clock [get_clocks sys_clk] -max -add_delay 1.500 [get_ports io_B35*]
set_input_delay  -clock [get_clocks sys_clk] -min -add_delay 1.000 [get_ports io_B35*]
#
set_output_delay -clock [get_clocks sys_clk]                 0.000 [get_ports  o_B35*]





############################################################################
## TODO: DAC control 
############################################################################


## DAC0 data out : 400MHz case
# 
set ports_dac0 [list o_B34D_L15P      \
                     o_B34D_L23P      \
                     o_B34D_L19P      \
                     o_B34D_L21P      \
                     o_B34D_L13P_MRCC \
                     o_B34D_L17P      \
                     o_B34D_L24P      \
                     o_B34D_L16P      \
                     o_B34D_L20P      \
                     o_B34D_L3P       \
                     o_B34D_L9P       \
                     o_B34D_L2P       \
                     o_B34D_L4P       \
                     o_B34D_L1P       \
                     o_B34D_L7P       \
                     o_B34D_L12P_MRCC ]
#
set_property IOB TRUE [get_ports $ports_dac0 ]

## try
# 10ns period, setup 1ns, hold 0.5ns
# 2.5ns period, setup 0.25ns, hold 0.125ns
# add -0.550ns // 0.250-0.550=-0.300,  -0.125-0.550=-0.675

##
#set t_dac0_su_r           0.250 ;   # 0.250ns
#set t_dac0_hd_r           0.125 ;   # 0.125ns
#set t_dac0_su_f           0.250 ;   # 0.250ns
#set t_dac0_hd_f           0.125 ;   # 0.125ns
#set t_dac0_trc_dly_max   [expr -0.550 -2.500  +1.250 ] ; # -3.050 ;   # -0.550ns -2.5ns # +1.25ns
#set t_dac0_trc_dly_min   [expr -0.600 -2.500  +1.250 ] ; # -3.100 ;   # -0.600ns -2.5ns # +1.25ns
#
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay [expr $t_dac0_trc_dly_max + $t_dac0_su_r ] [get_ports $ports_dac0 ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay [expr $t_dac0_trc_dly_min - $t_dac0_hd_r ] [get_ports $ports_dac0 ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay [expr $t_dac0_trc_dly_max + $t_dac0_su_f ] [get_ports $ports_dac0 ] -clock_fall
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay [expr $t_dac0_trc_dly_min - $t_dac0_hd_f ] [get_ports $ports_dac0 ] -clock_fall

##
#set t_dac0_delay_max [expr 1.250 + 0.800 ] ; # 1.250 + 0.800 ns
#
#set_max_delay -datapath_only -from [get_pins {r_DAC0_DAT_reg[*]/C}] -to [get_ports $ports_dac0 ] $t_dac0_delay_max

## 14.960 --> 15.460 --> 16.060 --> 17.000
#
set_max_delay    -to [get_ports $ports_dac0 ] 17.000



## DAC1 data out : 400MHz case
#
set ports_dac1 [list o_B35D_L12P_MRCC \
                     o_B35D_L13P_MRCC \
                     o_B35D_L1P       \
                     o_B35D_L2P       \
                     o_B35D_L3P       \
                     o_B35D_L5P       \
                     o_B35D_L8P       \
                     o_B35D_L10P      \
                     o_B35D_L24P      \
                     o_B35D_L22P      \
                     o_B35D_L20P      \
                     o_B35D_L16P      \
                     o_B35D_L21P      \
                     o_B35D_L19P      \
                     o_B35D_L18P      \
                     o_B35D_L23P  ]   
#
set_property IOB TRUE [get_ports  $ports_dac1 ]

##
#set t_dac1_su_r           0.250 ;   # 0.250ns
#set t_dac1_hd_r           0.125 ;   # 0.125ns
#set t_dac1_su_f           0.250 ;   # 0.250ns
#set t_dac1_hd_f           0.125 ;   # 0.125ns
#set t_dac1_trc_dly_max   [expr -0.550 -2.500  +1.250 ] ; # -3.050 ;   # -0.550ns -2.5ns # +1.25ns
#set t_dac1_trc_dly_min   [expr -0.600 -2.500  +1.250 ] ; # -3.100 ;   # -0.600ns -2.5ns # +1.25ns
#
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay [expr $t_dac1_trc_dly_max + $t_dac1_su_r ] [get_ports $ports_dac1 ]
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay [expr $t_dac1_trc_dly_min - $t_dac1_hd_r ] [get_ports $ports_dac1 ]
#set_output_delay -clock [get_clocks dac0_clk] -max -add_delay [expr $t_dac1_trc_dly_max + $t_dac1_su_f ] [get_ports $ports_dac1 ] -clock_fall
#set_output_delay -clock [get_clocks dac0_clk] -min -add_delay [expr $t_dac1_trc_dly_min - $t_dac1_hd_f ] [get_ports $ports_dac1 ] -clock_fall

##
#set t_dac1_delay_max [expr 1.250 + 0.800 ] ; # 1.250 + 0.800 ns
#
#set_max_delay -datapath_only -from [get_pins {r_DAC1_DAT_reg[*]/C}] -to [get_ports $ports_dac1 ] $t_dac1_delay_max

## 14.380 --> 14.910 --> 15.910 --> 16.650 --> 17.010
#
set_max_delay   -to [get_ports $ports_dac1 ] 17.010


## DCI out: 400MHz case
#set t_su_r           0.250 ;   # 0.250ns
#set t_hd_r           0.125 ;   # 0.125ns
#set t_su_f           0.250 ;   # 0.250ns
#set t_hd_f           0.125 ;   # 0.125ns
#set t_trc_dly_max   [expr -0.550 -2.500  +1.250 ] ; # -3.050 ;   # -0.550ns -2.5ns # +1.25ns -1.25ns
#set t_trc_dly_min   [expr -0.600 -2.500  +1.250 ] ; # -3.100 ;   # -0.600ns -2.5ns # +1.25ns
#
#[expr $t_trc_dly_max + $t_su_r ] # -0.550 -2.500  +1.250 + 0.250 -1.250 = -2.800 # -2.400 +(-0.400) = -3.000 +(+0.200)
#[expr $t_trc_dly_min - $t_hd_r ] # -0.600 -2.500  +1.250 -0.125 = -1.975         # -2.400 -(-0.425) = -2.075 -(+0.100) # -1.975 -0.100
#[expr $t_trc_dly_max + $t_su_f ] #
#[expr $t_trc_dly_min - $t_hd_f ] #

set t_dci_delay_max [expr 1.250 + 0.800 ] ; # 1.250 + 0.800 ns

## dac0 dci
#
#set_output_delay -clock [get_clocks dac0_dci_clk] -max -add_delay [expr $t_trc_dly_max + $t_su_r ] [get_ports {o_B34D_L10P}]
#set_output_delay -clock [get_clocks dac0_dci_clk] -min -add_delay [expr $t_trc_dly_min - $t_hd_r ] [get_ports {o_B34D_L10P}]
#set_output_delay -clock [get_clocks dac0_dci_clk] -max -add_delay [expr $t_trc_dly_max + $t_su_f ] [get_ports {o_B34D_L10P}] -clock_fall
#set_output_delay -clock [get_clocks dac0_dci_clk] -min -add_delay [expr $t_trc_dly_min - $t_hd_f ] [get_ports {o_B34D_L10P}] -clock_fall
#
set_max_delay -datapath_only -from [get_pins ODDR_dac0_dci_inst/C] -to [get_ports o_B34D_L10P] $t_dci_delay_max


## dac1 dci
#
# add fall -2.5ns
#set_output_delay -clock [get_clocks dac1_dci_clk] -max -add_delay [expr $t_trc_dly_max + $t_su_r] [get_ports {o_B35D_L17P}]
#set_output_delay -clock [get_clocks dac1_dci_clk] -min -add_delay [expr $t_trc_dly_min - $t_hd_r] [get_ports {o_B35D_L17P}]
#set_output_delay -clock [get_clocks dac1_dci_clk] -max -add_delay [expr $t_trc_dly_max + $t_su_f] [get_ports {o_B35D_L17P}] -clock_fall
#set_output_delay -clock [get_clocks dac1_dci_clk] -min -add_delay [expr $t_trc_dly_min - $t_hd_f] [get_ports {o_B35D_L17P}] -clock_fall
#
set_max_delay -datapath_only -from [get_pins ODDR_dac1_dci_inst/C] -to [get_ports o_B35D_L17P ] $t_dci_delay_max

# dac0 dci
## 8.000 --> 14.960
#set_max_delay   -to [get_ports o_B34D_L10P ] 14.960
#
# dac1 dci
## 8.000 --> 14.910
#set_max_delay   -to [get_ports o_B35D_L17P ] 14.910
#


## false path for fifo reset
set_false_path -from [get_pins {dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/r_cid_reg_ctrl_reg[6]/C}] 
set_false_path -from [get_pins {dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/r_cid_reg_ctrl_reg[7]/C}] 

## false path from flag_fcid_pulse_active_dac*
#set_false_path -from [get_pins dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac0_reg/C] 
#set_false_path -from [get_pins dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac1_reg/C] 

## release path from flag_fcid_pulse_active_dac*
#set_max_delay -datapath_only -from [get_pins dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac0_reg/C] 5.000
#set_max_delay -datapath_only -from [get_pins dac_pattern_gen_wrapper__inst/dac_pattern_gen_inst/flag_fcid_pulse_active_dac1_reg/C] 5.000



############################################################################
## TODO: TRIG control 
############################################################################

# TRIG_OUT
# 400MHz clock out case
##set_max_delay   -to [get_ports o_B13_L15P ] 9.200
##set_max_delay   -to [get_ports o_B13_L15N ] 9.200
set_max_delay   -to [get_ports o_B13_L15P ] 14.200
set_max_delay   -to [get_ports o_B13_L15N ] 14.200
#


############################################################################
## TODO: SPIO control 
############################################################################

set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L2N ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L4P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L1P ]
#
# ignore wire in from ep07wire
#set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi07/ep_dataout_reg[*]/C}] 


############################################################################
## TODO: CLKD control 
############################################################################

# CLKD_SCLK     
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_L4P ]
# CLKD_CS_B
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_L4N ]
# CLKD_SDIO
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports io_B35_L6N ]
set_input_delay  -clock [get_clocks sys_clk] 0.000 [get_ports io_B35_L6N ]

# CLKD_RST_B
#set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B35_0_ ]
set_false_path   -from [get_pins master_spi_ad9516_inst/r_LNG_RSTn_reg/C]
set_max_delay    -to [get_ports o_B35_0_] 20.0
#

# ignore wire in from ep06wire
#set_false_path -from [get_pins {ok_endpoint_wrapper_inst/wi06/ep_dataout_reg[*]/C}] 

## pull up for SDIO SDO in bidir mode
# CLKD_SDIO
set_property PULLUP true [get_ports io_B35_L6N]
# CLKD_SDO
set_property PULLUP true [get_ports  i_B35_L6P]



############################################################################
## TODO: DACX control 
############################################################################

set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L16P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L3P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L5N ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L5P ]
set_output_delay -clock [get_clocks sys_clk] 0.000 [get_ports o_B13_L7P ]
#



############################################################################
## TODO: LAN control 
############################################################################

# LAN_MISO
set_input_delay -clock [get_clocks lan_clk] -max -add_delay 3.500 [get_ports i_B15_L9N] 
set_input_delay -clock [get_clocks lan_clk] -min -add_delay 1.000 [get_ports i_B15_L9N] 

# LAN_INT_B
set_max_delay  18.000  -from [get_ports i_B15_L8N] 
set_min_delay   0.000  -from [get_ports i_B15_L8N] 

# LAN_RST_B  LAN_PWDN
set_max_delay  18.000    -to [get_ports {{o_B15_L9P} {o_B15_L6P}}]  

# LAN_SCLK   LAN_SSN_B LAN_SSAUX_B
##set_max_delay   6.900    -to [get_ports {{o_B15_L7P} {o_B15_L7N} {o_B15_L8P} {o_B15_L6N}}]  
set_max_delay   12.900    -to [get_ports {{o_B15_L7P} {o_B15_L7N} {o_B15_L8P} {o_B15_L6N}}]  

## relax wires
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_00/r_port_wi_00_reg[*]/C}] 
set_false_path -from [get_pins {lan_endpoint_wrapper_inst/mcs_io_bridge_inst2/o_wi_core__inst__lan_wi_01/r_port_wi_00_reg[*]/C}] 


############################################################################
## test 
############################################################################

## IOB output register try for DAC outputs and all others
#set_property IOB TRUE [all_outputs]







