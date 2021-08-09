##== LED and TP ==##
set_property MARK_DEBUG true [get_nets {led[*]}]
set_property MARK_DEBUG true [get_nets {test_point[*]}]

##== TIME STAMP ==##
#set_property MARK_DEBUG true [get_nets {w_TIMESTAMP_WO[*]}]
set_property MARK_DEBUG true [get_nets {sub_timestamp_inst/r_global_time_idx[*]}]


##== MTH SPI ==##
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_frame]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_done_frame]
#set_property MARK_DEBUG true [get_nets w_SSPI_TEST_trig_init]

set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SS_B]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MOSI]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MCLK]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO_EN]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_MISO]
set_property MARK_DEBUG true [get_nets w_SSPI_TEST_SCLK]

set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_trig_init  ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_done_init  ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_trig_frame ]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_done_frame ]

set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_C[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_A[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/i_frame_data_D[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_B[*]]
set_property MARK_DEBUG true [get_nets master_spi_mth_brd__inst/o_frame_data_E[*]]

set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS0_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS1_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS2_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS3_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS4_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS5_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS6_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS7_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS8_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS9_ ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS10 ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS11 ]
set_property MARK_DEBUG true [get_nets FPGA_M0_SPI_nCS12 ]

set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS0_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS1_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS2_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS3_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS4_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS5_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS6_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS7_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS8_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS9_ ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS10 ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS11 ]
set_property MARK_DEBUG true [get_nets FPGA_M1_SPI_nCS12 ]

set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS0_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS1_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS2_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS3_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS4_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS5_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS6_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS7_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS8_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS9_ ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS10 ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS11 ]
set_property MARK_DEBUG true [get_nets FPGA_M2_SPI_nCS12 ]

##== LAN ==##

             

##== core endpoint wapper ==##

# core_endpoint_wrapper__inst

set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_NCE        ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_ADD[*]     ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_NOE        ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/o_FMC_DRD[*]     ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_NWE        ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_DWR[*]     ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/i_FMC_DWR[*]     ]
set_property MARK_DEBUG true [get_nets core_endpoint_wrapper__inst/o_FMC_DRD_TRI[*] ]

##== BUF data  ==##
set_property MARK_DEBUG true [get_nets BUF_DATA_DIR ]
set_property MARK_DEBUG true [get_nets nBUF_DATA_OE ]


##== ETH ==##
set_property MARK_DEBUG true [get_nets ETH_nCS ]



##== GPIB ==##
set_property MARK_DEBUG true [get_nets GPIB_nCS      ]
set_property MARK_DEBUG true [get_nets GPIB_DATA_DIR ]
set_property MARK_DEBUG true [get_nets GPIB_DATA_nOE ]
#
set_property MARK_DEBUG true [get_nets GPIB_SW_nOE   ]

set_property MARK_DEBUG true [get_nets GPIB_REM      ]
set_property MARK_DEBUG true [get_nets GPIB_TADCS    ]
set_property MARK_DEBUG true [get_nets GPIB_LADCS    ]
set_property MARK_DEBUG true [get_nets GPIB_DCAS     ]
set_property MARK_DEBUG true [get_nets GPIB_TRIG     ]

##== IOs ==##
set_property MARK_DEBUG true [get_nets INTER_RELAY_O   ]
set_property MARK_DEBUG true [get_nets INTER_LED_O     ]
set_property MARK_DEBUG true [get_nets INTER_LOCK_ON   ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_0 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_1 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_2 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_3 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_4 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_5 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_6 ]
set_property MARK_DEBUG true [get_nets FPGA_FAN_SENS_7 ]
set_property MARK_DEBUG true [get_nets TRIG            ] 
set_property MARK_DEBUG true [get_nets SOT             ] 
set_property MARK_DEBUG true [get_nets PRE_TRIG        ] 
set_property MARK_DEBUG true [get_nets FPGA_H_IN1      ] 
set_property MARK_DEBUG true [get_nets FPGA_H_IN2      ] 
set_property MARK_DEBUG true [get_nets FPGA_H_IN3      ] 
set_property MARK_DEBUG true [get_nets FPGA_H_IN4      ] 
set_property MARK_DEBUG true [get_nets FPGA_H_OUT1     ] 
set_property MARK_DEBUG true [get_nets FPGA_H_OUT2     ] 
set_property MARK_DEBUG true [get_nets FPGA_H_OUT3     ] 
set_property MARK_DEBUG true [get_nets FPGA_H_OUT4     ] 
set_property MARK_DEBUG true [get_nets BUF_MASTER0     ] 
set_property MARK_DEBUG true [get_nets BUF_MASTER1     ] 


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


