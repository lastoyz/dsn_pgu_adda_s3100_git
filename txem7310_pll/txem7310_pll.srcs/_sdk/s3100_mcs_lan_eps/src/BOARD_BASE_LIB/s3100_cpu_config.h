#ifndef __S3100_CPU_CONFIG_H_		/* prevent circular inclusions */
#define __S3100_CPU_CONFIG_H_		/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif


#include "xiomodule_l.h" // low-level driver
// for XPAR_IOMODULE_0_IO_BASEADDR
// for XIomodule_In32() and XIomodule_Out32()

#include "xil_printf.h"

// macro for CMU-CPU board support
//#define _CMU_CPU_

// macro for PGU-CPU board support
//#define _PGU_CPU_

// macro for S3100-CPU-BASE board support
#define _S3100_CPU_



// offset definition for mcs_io_bridge.v //{
//#define MCS_IO_INST_OFFSET              0x00000000 // for LAN
//#define MCS_IO_INST_OFFSET_CMU          0x00010000 // for CMU
//#define MCS_IO_INST_OFFSET_PGU          0x00020000 // for PGU
//#define MCS_IO_INST_OFFSET_EXT          0x00030000 // for MHVSU_BASE (port end-points + lan end-points)
//#define MCS_IO_INST_OFFSET_EXT_CMU      0x00040000 // for NEW CMU (port end-points + lan end-points)
#define MCS_IO_INST_OFFSET_EXT_PGU      0x00050000 // for S3000-PGU       (port end-points + lan end-points)
#define MCS_IO_INST_OFFSET_EXT_S3100    0x00060000 // for S3100-CPU-BASE  (port end-points + lan end-points)
//}

// BASE //{
//#define ADRS_BASE           XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET     // not used
//#define ADRS_BASE_CMU       XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_CMU // not used
//#define ADRS_BASE_PGU       XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_PGU // not used
//#define ADRS_BASE_MHVSU     XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_EXT // not used
//#define ADRS_BASE_EXT_CMU   XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_EXT_CMU
#define ADRS_BASE_EXT_PGU     XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_EXT_PGU
#define ADRS_BASE_EXT_S3100   XPAR_IOMODULE_0_IO_BASEADDR + MCS_IO_INST_OFFSET_EXT_S3100

#define MCS_EP_BASE           ADRS_BASE_EXT_PGU // test S3100-PGU or S3000-PGU
//#define MCS_EP_BASE         ADRS_BASE_EXT_S3100 // for S3100-CPU-BASE


//}


// TODO: common offset for end point address //{

// ADRS_PORT_WI_xx_OFST ... //{ 
#define ADRS_PORT_WI_00_OFST     0x00000000 // output wire [31:0] 
#define ADRS_PORT_WI_01_OFST     0x00000010 // output wire [31:0] 
#define ADRS_PORT_WI_02_OFST     0x00000020 // output wire [31:0]
#define ADRS_PORT_WI_03_OFST     0x00000030 // output wire [31:0] 
#define ADRS_PORT_WI_04_OFST     0x00000040 // output wire [31:0] 
#define ADRS_PORT_WI_05_OFST     0x00000050 // output wire [31:0] 
#define ADRS_PORT_WI_06_OFST     0x00000060 // output wire [31:0] 
#define ADRS_PORT_WI_07_OFST     0x00000070 // output wire [31:0] 
#define ADRS_PORT_WI_08_OFST     0x00000080 // output wire [31:0]
#define ADRS_PORT_WI_09_OFST     0x00000090 // output wire [31:0]
#define ADRS_PORT_WI_0A_OFST     0x000000A0 // output wire [31:0]
#define ADRS_PORT_WI_0B_OFST     0x000000B0 // output wire [31:0]
#define ADRS_PORT_WI_0C_OFST     0x000000C0 // output wire [31:0]
#define ADRS_PORT_WI_0D_OFST     0x000000D0 // output wire [31:0]
#define ADRS_PORT_WI_0E_OFST     0x000000E0 // output wire [31:0]
#define ADRS_PORT_WI_0F_OFST     0x000000F0 // output wire [31:0]
#define ADRS_PORT_WI_10_OFST     0x00000100 // output wire [31:0]
#define ADRS_PORT_WI_11_OFST     0x00000110 // output wire [31:0]
#define ADRS_PORT_WI_12_OFST     0x00000120 // output wire [31:0]
#define ADRS_PORT_WI_13_OFST     0x00000130 // output wire [31:0]
#define ADRS_PORT_WI_14_OFST     0x00000140 // output wire [31:0]
#define ADRS_PORT_WI_15_OFST     0x00000150 // output wire [31:0]
#define ADRS_PORT_WI_16_OFST     0x00000160 // output wire [31:0]
#define ADRS_PORT_WI_17_OFST     0x00000170 // output wire [31:0]
#define ADRS_PORT_WI_18_OFST     0x00000180 // output wire [31:0]
#define ADRS_PORT_WI_19_OFST     0x00000190 // output wire [31:0]
#define ADRS_PORT_WI_1A_OFST     0x000001A0 // output wire [31:0]
#define ADRS_PORT_WI_1B_OFST     0x000001B0 // output wire [31:0]
#define ADRS_PORT_WI_1C_OFST     0x000001C0 // output wire [31:0]
#define ADRS_PORT_WI_1D_OFST     0x000001D0 // output wire [31:0]
#define ADRS_PORT_WI_1E_OFST     0x000001E0 // output wire [31:0]
#define ADRS_PORT_WI_1F_OFST     0x000001F0 // output wire [31:0]
//}

// ADRS_PORT_WO_xx_OFST ... //{
#define ADRS_PORT_WO_20_OFST     0x00000200 // input wire [31:0]
#define ADRS_PORT_WO_21_OFST     0x00000210 // input wire [31:0]
#define ADRS_PORT_WO_22_OFST     0x00000220 // input wire [31:0]
#define ADRS_PORT_WO_23_OFST     0x00000230 // input wire [31:0]
#define ADRS_PORT_WO_24_OFST     0x00000240 // input wire [31:0]
#define ADRS_PORT_WO_25_OFST     0x00000250 // input wire [31:0]
#define ADRS_PORT_WO_26_OFST     0x00000260 // input wire [31:0]
#define ADRS_PORT_WO_27_OFST     0x00000270 // input wire [31:0]
#define ADRS_PORT_WO_28_OFST     0x00000280 // input wire [31:0]
#define ADRS_PORT_WO_29_OFST     0x00000290 // input wire [31:0]
#define ADRS_PORT_WO_2A_OFST     0x000002A0 // input wire [31:0]
#define ADRS_PORT_WO_2B_OFST     0x000002B0 // input wire [31:0]
#define ADRS_PORT_WO_2C_OFST     0x000002C0 // input wire [31:0]
#define ADRS_PORT_WO_2D_OFST     0x000002D0 // input wire [31:0]
#define ADRS_PORT_WO_2E_OFST     0x000002E0 // input wire [31:0]
#define ADRS_PORT_WO_2F_OFST     0x000002F0 // input wire [31:0]
#define ADRS_PORT_WO_30_OFST     0x00000300 // input wire [31:0]
#define ADRS_PORT_WO_31_OFST     0x00000310 // input wire [31:0]
#define ADRS_PORT_WO_32_OFST     0x00000320 // input wire [31:0]
#define ADRS_PORT_WO_33_OFST     0x00000330 // input wire [31:0]
#define ADRS_PORT_WO_34_OFST     0x00000340 // input wire [31:0]
#define ADRS_PORT_WO_35_OFST     0x00000350 // input wire [31:0]
#define ADRS_PORT_WO_36_OFST     0x00000360 // input wire [31:0]
#define ADRS_PORT_WO_37_OFST     0x00000370 // input wire [31:0]
#define ADRS_PORT_WO_38_OFST     0x00000380 // input wire [31:0]
#define ADRS_PORT_WO_39_OFST     0x00000390 // input wire [31:0]
#define ADRS_PORT_WO_3A_OFST     0x000003A0 // input wire [31:0]
#define ADRS_PORT_WO_3B_OFST     0x000003B0 // input wire [31:0]
#define ADRS_PORT_WO_3C_OFST     0x000003C0 // input wire [31:0]
#define ADRS_PORT_WO_3D_OFST     0x000003D0 // input wire [31:0]
#define ADRS_PORT_WO_3E_OFST     0x000003E0 // input wire [31:0]
#define ADRS_PORT_WO_3F_OFST     0x000003F0 // input wire [31:0]
//}

// ADRS_PORT_TI_xx_OFST ... //{
#define ADRS_PORT_TI_40_OFST     0x00000400 // input wire, output wire [31:0]
#define ADRS_PORT_TI_41_OFST     0x00000410 // input wire, output wire [31:0]
#define ADRS_PORT_TI_42_OFST     0x00000420 // input wire, output wire [31:0]
#define ADRS_PORT_TI_43_OFST     0x00000430 // input wire, output wire [31:0]
#define ADRS_PORT_TI_44_OFST     0x00000440 // input wire, output wire [31:0]
#define ADRS_PORT_TI_45_OFST     0x00000450 // input wire, output wire [31:0]
#define ADRS_PORT_TI_46_OFST     0x00000460 // input wire, output wire [31:0]
#define ADRS_PORT_TI_47_OFST     0x00000470 // input wire, output wire [31:0]
#define ADRS_PORT_TI_48_OFST     0x00000480 // input wire, output wire [31:0]
#define ADRS_PORT_TI_49_OFST     0x00000490 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4A_OFST     0x000004A0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4B_OFST     0x000004B0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4C_OFST     0x000004C0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4D_OFST     0x000004D0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4E_OFST     0x000004E0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_4F_OFST     0x000004F0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_50_OFST     0x00000500 // input wire, output wire [31:0]
#define ADRS_PORT_TI_51_OFST     0x00000510 // input wire, output wire [31:0]
#define ADRS_PORT_TI_52_OFST     0x00000520 // input wire, output wire [31:0]
#define ADRS_PORT_TI_53_OFST     0x00000530 // input wire, output wire [31:0]
#define ADRS_PORT_TI_54_OFST     0x00000540 // input wire, output wire [31:0]
#define ADRS_PORT_TI_55_OFST     0x00000550 // input wire, output wire [31:0]
#define ADRS_PORT_TI_56_OFST     0x00000560 // input wire, output wire [31:0]
#define ADRS_PORT_TI_57_OFST     0x00000570 // input wire, output wire [31:0]
#define ADRS_PORT_TI_58_OFST     0x00000580 // input wire, output wire [31:0]
#define ADRS_PORT_TI_59_OFST     0x00000590 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5A_OFST     0x000005A0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5B_OFST     0x000005B0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5C_OFST     0x000005C0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5D_OFST     0x000005D0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5E_OFST     0x000005E0 // input wire, output wire [31:0]
#define ADRS_PORT_TI_5F_OFST     0x000005F0 // input wire, output wire [31:0]
//}

// ADRS_PORT_TO_xx_OFST ... //{
#define ADRS_PORT_TO_60_OFST     0x00000600 // input wire, input wire [31:0]
#define ADRS_PORT_TO_61_OFST     0x00000610 // input wire, input wire [31:0]
#define ADRS_PORT_TO_62_OFST     0x00000620 // input wire, input wire [31:0]
#define ADRS_PORT_TO_63_OFST     0x00000630 // input wire, input wire [31:0]
#define ADRS_PORT_TO_64_OFST     0x00000640 // input wire, input wire [31:0]
#define ADRS_PORT_TO_65_OFST     0x00000650 // input wire, input wire [31:0]
#define ADRS_PORT_TO_66_OFST     0x00000660 // input wire, input wire [31:0]
#define ADRS_PORT_TO_67_OFST     0x00000670 // input wire, input wire [31:0]
#define ADRS_PORT_TO_68_OFST     0x00000680 // input wire, input wire [31:0]
#define ADRS_PORT_TO_69_OFST     0x00000690 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6A_OFST     0x000006A0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6B_OFST     0x000006B0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6C_OFST     0x000006C0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6D_OFST     0x000006D0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6E_OFST     0x000006E0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_6F_OFST     0x000006F0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_70_OFST     0x00000700 // input wire, input wire [31:0]
#define ADRS_PORT_TO_71_OFST     0x00000710 // input wire, input wire [31:0]
#define ADRS_PORT_TO_72_OFST     0x00000720 // input wire, input wire [31:0]
#define ADRS_PORT_TO_73_OFST     0x00000730 // input wire, input wire [31:0]
#define ADRS_PORT_TO_74_OFST     0x00000740 // input wire, input wire [31:0]
#define ADRS_PORT_TO_75_OFST     0x00000750 // input wire, input wire [31:0]
#define ADRS_PORT_TO_76_OFST     0x00000760 // input wire, input wire [31:0]
#define ADRS_PORT_TO_77_OFST     0x00000770 // input wire, input wire [31:0]
#define ADRS_PORT_TO_78_OFST     0x00000780 // input wire, input wire [31:0]
#define ADRS_PORT_TO_79_OFST     0x00000790 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7A_OFST     0x000007A0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7B_OFST     0x000007B0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7C_OFST     0x000007C0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7D_OFST     0x000007D0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7E_OFST     0x000007E0 // input wire, input wire [31:0]
#define ADRS_PORT_TO_7F_OFST     0x000007F0 // input wire, input wire [31:0]
//}

// ADRS_PORT_PI_xx_OFST ... //{
#define ADRS_PORT_PI_80_OFST     0x00000800 // output wire, output wire [31:0]
#define ADRS_PORT_PI_81_OFST     0x00000810 // output wire, output wire [31:0]
#define ADRS_PORT_PI_82_OFST     0x00000820 // output wire, output wire [31:0]
#define ADRS_PORT_PI_83_OFST     0x00000830 // output wire, output wire [31:0]
#define ADRS_PORT_PI_84_OFST     0x00000840 // output wire, output wire [31:0]
#define ADRS_PORT_PI_85_OFST     0x00000850 // output wire, output wire [31:0]
#define ADRS_PORT_PI_86_OFST     0x00000860 // output wire, output wire [31:0]
#define ADRS_PORT_PI_87_OFST     0x00000870 // output wire, output wire [31:0]
#define ADRS_PORT_PI_88_OFST     0x00000880 // output wire, output wire [31:0]
#define ADRS_PORT_PI_89_OFST     0x00000890 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8A_OFST     0x000008A0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8B_OFST     0x000008B0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8C_OFST     0x000008C0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8D_OFST     0x000008D0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8E_OFST     0x000008E0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_8F_OFST     0x000008F0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_90_OFST     0x00000900 // output wire, output wire [31:0]
#define ADRS_PORT_PI_91_OFST     0x00000910 // output wire, output wire [31:0]
#define ADRS_PORT_PI_92_OFST     0x00000920 // output wire, output wire [31:0]
#define ADRS_PORT_PI_93_OFST     0x00000930 // output wire, output wire [31:0]
#define ADRS_PORT_PI_94_OFST     0x00000940 // output wire, output wire [31:0]
#define ADRS_PORT_PI_95_OFST     0x00000950 // output wire, output wire [31:0]
#define ADRS_PORT_PI_96_OFST     0x00000960 // output wire, output wire [31:0]
#define ADRS_PORT_PI_97_OFST     0x00000970 // output wire, output wire [31:0]
#define ADRS_PORT_PI_98_OFST     0x00000980 // output wire, output wire [31:0]
#define ADRS_PORT_PI_99_OFST     0x00000990 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9A_OFST     0x000009A0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9B_OFST     0x000009B0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9C_OFST     0x000009C0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9D_OFST     0x000009D0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9E_OFST     0x000009E0 // output wire, output wire [31:0]
#define ADRS_PORT_PI_9F_OFST     0x000009F0 // output wire, output wire [31:0]
//}

// ADRS_PORT_PO_xx_OFST ... //{
#define ADRS_PORT_PO_A0_OFST     0x00000A00 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A1_OFST     0x00000A10 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A2_OFST     0x00000A20 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A3_OFST     0x00000A30 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A4_OFST     0x00000A40 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A5_OFST     0x00000A50 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A6_OFST     0x00000A60 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A7_OFST     0x00000A70 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A8_OFST     0x00000A80 // output wire, input wire [31:0]
#define ADRS_PORT_PO_A9_OFST     0x00000A90 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AA_OFST     0x00000AA0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AB_OFST     0x00000AB0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AC_OFST     0x00000AC0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AD_OFST     0x00000AD0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AE_OFST     0x00000AE0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_AF_OFST     0x00000AF0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B0_OFST     0x00000B00 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B1_OFST     0x00000B10 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B2_OFST     0x00000B20 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B3_OFST     0x00000B30 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B4_OFST     0x00000B40 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B5_OFST     0x00000B50 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B6_OFST     0x00000B60 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B7_OFST     0x00000B70 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B8_OFST     0x00000B80 // output wire, input wire [31:0]
#define ADRS_PORT_PO_B9_OFST     0x00000B90 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BA_OFST     0x00000BA0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BB_OFST     0x00000BB0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BC_OFST     0x00000BC0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BD_OFST     0x00000BD0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BE_OFST     0x00000BE0 // output wire, input wire [31:0]
#define ADRS_PORT_PO_BF_OFST     0x00000BF0 // output wire, input wire [31:0]
//}

//// dedicated lan interface //{
	
// 'b_0000_XXHH_hhxx_xx00
//
//         1100 (C)
//         1101 (D)
//         1110 (E)
//         
// 'b_0000_1100_00xx_xx00 -- LAN_WI_00
// 'b_0000_1100_01xx_xx00 -- LAN_WI_10
// 'b_0000_1100_10xx_xx00 -- LAN_WO_20
// 'b_0000_1100_11xx_xx00 -- LAN_WO_30
// 'b_0000_1101_00xx_xx00 -- LAN_TI_40
// 'b_0000_1101_01xx_xx00 -- LAN_TI_50
// 'b_0000_1101_10xx_xx00 -- LAN_TO_60
// 'b_0000_1101_11xx_xx00 -- LAN_TO_70
// 'b_0000_1110_00xx_xx00 -- LAN_PI_80
// 'b_0000_1110_01xx_xx00 -- LAN_PI_90
// 'b_0000_1110_10xx_xx00 -- LAN_PO_A0
// 'b_0000_1110_11xx_xx00 -- LAN_PO_B0

#define ADRS_LAN_WI_00_OFST      0x00000C00 // output wire [31:0]
#define ADRS_LAN_WI_01_OFST      0x00000C04 // output wire [31:0]
#define ADRS_LAN_WO_20_OFST      0x00000C80 // input wire [31:0]
#define ADRS_LAN_WO_21_OFST      0x00000C84 // input wire [31:0]
#define ADRS_LAN_TI_40_OFST      0x00000D00 // input wire, output wire [31:0],
#define ADRS_LAN_TI_41_OFST      0x00000D04 // input wire, output wire [31:0],
#define ADRS_LAN_TO_60_OFST      0x00000D80 // input wire, input wire [31:0],
#define ADRS_LAN_TO_61_OFST      0x00000D84 // input wire, input wire [31:0],
#define ADRS_LAN_PI_80_OFST      0x00000E00 // output wire, output wire [31:0],
#define ADRS_LAN_PI_81_OFST      0x00000E04 // output wire, output wire [31:0],
#define ADRS_LAN_PO_A0_OFST      0x00000E80 // output wire, input wire [31:0],
#define ADRS_LAN_PO_A1_OFST      0x00000E84 // output wire, input wire [31:0],
//
#define ADRS_FPGA_IMAGE_OFST     0x00000F00 // image id
#define ADRS_TEST_REG___OFST     0x00000F04 // test reg 
#define ADRS_MASK_ALL___OFST     0x00000F08 // mask all //$$
#define ADRS_MASK_WI____OFST     0x00000F10 // mask
#define ADRS_MASK_WO____OFST     0x00000F14 // mask
#define ADRS_MASK_TI____OFST     0x00000F18 // mask
#define ADRS_MASK_TO____OFST     0x00000F1C // mask	
//
#define ADRS_LAN_CONF_00_OFST    0x00000FC0 //input  wire [31:0]   i_lan_conf_00  // (BASE_ADRS_IP_32B  + i_adrs_offset_ip_32b )
#define ADRS_LAN_CONF_01_OFST    0x00000FC4 //input  wire [31:0]   i_lan_conf_01  // (BASE_ADRS_MAC_48B[31: 0] + i_adrs_offset_mac_48b[31: 0] )
#define ADRS_LAN_CONF_02_OFST    0x00000FC8 //input  wire [31:0]   i_lan_conf_02  // ( {16'b0,BASE_ADRS_MAC_48B[47:32]} + {16'b0,i_adrs_offset_mac_48b[47:32]} )
#define ADRS_LAN_CONF_03_OFST    0x00000FCC //input  wire [31:0]   i_lan_conf_03  // ( i_lan_timeout_rtr_16b , i_lan_timeout_rcr_16b )
//

//}

//}


// TODO: ADRS_PORT_xx and ADRS_LAN_xx with MCS_EP_BASE //{
	
// ADRS_PORT_WI_xx ... //{
#define ADRS_PORT_WI_00     MCS_EP_BASE + ADRS_PORT_WI_00_OFST // output wire [31:0]
#define ADRS_PORT_WI_01     MCS_EP_BASE + ADRS_PORT_WI_01_OFST // output wire [31:0]
#define ADRS_PORT_WI_02     MCS_EP_BASE + ADRS_PORT_WI_02_OFST // output wire [31:0]
#define ADRS_PORT_WI_03     MCS_EP_BASE + ADRS_PORT_WI_03_OFST // output wire [31:0]
#define ADRS_PORT_WI_04     MCS_EP_BASE + ADRS_PORT_WI_04_OFST // output wire [31:0]
#define ADRS_PORT_WI_05     MCS_EP_BASE + ADRS_PORT_WI_05_OFST // output wire [31:0]
#define ADRS_PORT_WI_06     MCS_EP_BASE + ADRS_PORT_WI_06_OFST // output wire [31:0]
#define ADRS_PORT_WI_07     MCS_EP_BASE + ADRS_PORT_WI_07_OFST // output wire [31:0]
#define ADRS_PORT_WI_08     MCS_EP_BASE + ADRS_PORT_WI_08_OFST // output wire [31:0]
#define ADRS_PORT_WI_09     MCS_EP_BASE + ADRS_PORT_WI_09_OFST // output wire [31:0]
#define ADRS_PORT_WI_0A     MCS_EP_BASE + ADRS_PORT_WI_0A_OFST // output wire [31:0]
#define ADRS_PORT_WI_0B     MCS_EP_BASE + ADRS_PORT_WI_0B_OFST // output wire [31:0]
#define ADRS_PORT_WI_0C     MCS_EP_BASE + ADRS_PORT_WI_0C_OFST // output wire [31:0]
#define ADRS_PORT_WI_0D     MCS_EP_BASE + ADRS_PORT_WI_0D_OFST // output wire [31:0]
#define ADRS_PORT_WI_0E     MCS_EP_BASE + ADRS_PORT_WI_0E_OFST // output wire [31:0]
#define ADRS_PORT_WI_0F     MCS_EP_BASE + ADRS_PORT_WI_0F_OFST // output wire [31:0]
#define ADRS_PORT_WI_10     MCS_EP_BASE + ADRS_PORT_WI_10_OFST // output wire [31:0]
#define ADRS_PORT_WI_11     MCS_EP_BASE + ADRS_PORT_WI_11_OFST // output wire [31:0]
#define ADRS_PORT_WI_12     MCS_EP_BASE + ADRS_PORT_WI_12_OFST // output wire [31:0]
#define ADRS_PORT_WI_13     MCS_EP_BASE + ADRS_PORT_WI_13_OFST // output wire [31:0]
#define ADRS_PORT_WI_14     MCS_EP_BASE + ADRS_PORT_WI_14_OFST // output wire [31:0]
#define ADRS_PORT_WI_15     MCS_EP_BASE + ADRS_PORT_WI_15_OFST // output wire [31:0]
#define ADRS_PORT_WI_16     MCS_EP_BASE + ADRS_PORT_WI_16_OFST // output wire [31:0]
#define ADRS_PORT_WI_17     MCS_EP_BASE + ADRS_PORT_WI_17_OFST // output wire [31:0]
#define ADRS_PORT_WI_18     MCS_EP_BASE + ADRS_PORT_WI_18_OFST // output wire [31:0]
#define ADRS_PORT_WI_19     MCS_EP_BASE + ADRS_PORT_WI_19_OFST // output wire [31:0]
#define ADRS_PORT_WI_1A     MCS_EP_BASE + ADRS_PORT_WI_1A_OFST // output wire [31:0]
#define ADRS_PORT_WI_1B     MCS_EP_BASE + ADRS_PORT_WI_1B_OFST // output wire [31:0]
#define ADRS_PORT_WI_1C     MCS_EP_BASE + ADRS_PORT_WI_1C_OFST // output wire [31:0]
#define ADRS_PORT_WI_1D     MCS_EP_BASE + ADRS_PORT_WI_1D_OFST // output wire [31:0]
#define ADRS_PORT_WI_1E     MCS_EP_BASE + ADRS_PORT_WI_1E_OFST // output wire [31:0]
#define ADRS_PORT_WI_1F     MCS_EP_BASE + ADRS_PORT_WI_1F_OFST // output wire [31:0]
//}

// ADRS_PORT_WO_xx ... //{
#define ADRS_PORT_WO_20     MCS_EP_BASE + ADRS_PORT_WO_20_OFST // input wire [31:0]
#define ADRS_PORT_WO_21     MCS_EP_BASE + ADRS_PORT_WO_21_OFST // input wire [31:0]
#define ADRS_PORT_WO_22     MCS_EP_BASE + ADRS_PORT_WO_22_OFST // input wire [31:0]
#define ADRS_PORT_WO_23     MCS_EP_BASE + ADRS_PORT_WO_23_OFST // input wire [31:0]
#define ADRS_PORT_WO_24     MCS_EP_BASE + ADRS_PORT_WO_24_OFST // input wire [31:0]
#define ADRS_PORT_WO_25     MCS_EP_BASE + ADRS_PORT_WO_25_OFST // input wire [31:0]
#define ADRS_PORT_WO_26     MCS_EP_BASE + ADRS_PORT_WO_26_OFST // input wire [31:0]
#define ADRS_PORT_WO_27     MCS_EP_BASE + ADRS_PORT_WO_27_OFST // input wire [31:0]
#define ADRS_PORT_WO_28     MCS_EP_BASE + ADRS_PORT_WO_28_OFST // input wire [31:0]
#define ADRS_PORT_WO_29     MCS_EP_BASE + ADRS_PORT_WO_29_OFST // input wire [31:0]
#define ADRS_PORT_WO_2A     MCS_EP_BASE + ADRS_PORT_WO_2A_OFST // input wire [31:0]
#define ADRS_PORT_WO_2B     MCS_EP_BASE + ADRS_PORT_WO_2B_OFST // input wire [31:0]
#define ADRS_PORT_WO_2C     MCS_EP_BASE + ADRS_PORT_WO_2C_OFST // input wire [31:0]
#define ADRS_PORT_WO_2D     MCS_EP_BASE + ADRS_PORT_WO_2D_OFST // input wire [31:0]
#define ADRS_PORT_WO_2E     MCS_EP_BASE + ADRS_PORT_WO_2E_OFST // input wire [31:0]
#define ADRS_PORT_WO_2F     MCS_EP_BASE + ADRS_PORT_WO_2F_OFST // input wire [31:0]
#define ADRS_PORT_WO_30     MCS_EP_BASE + ADRS_PORT_WO_30_OFST // input wire [31:0]
#define ADRS_PORT_WO_31     MCS_EP_BASE + ADRS_PORT_WO_31_OFST // input wire [31:0]
#define ADRS_PORT_WO_32     MCS_EP_BASE + ADRS_PORT_WO_32_OFST // input wire [31:0]
#define ADRS_PORT_WO_33     MCS_EP_BASE + ADRS_PORT_WO_33_OFST // input wire [31:0]
#define ADRS_PORT_WO_34     MCS_EP_BASE + ADRS_PORT_WO_34_OFST // input wire [31:0]
#define ADRS_PORT_WO_35     MCS_EP_BASE + ADRS_PORT_WO_35_OFST // input wire [31:0]
#define ADRS_PORT_WO_36     MCS_EP_BASE + ADRS_PORT_WO_36_OFST // input wire [31:0]
#define ADRS_PORT_WO_37     MCS_EP_BASE + ADRS_PORT_WO_37_OFST // input wire [31:0]
#define ADRS_PORT_WO_38     MCS_EP_BASE + ADRS_PORT_WO_38_OFST // input wire [31:0]
#define ADRS_PORT_WO_39     MCS_EP_BASE + ADRS_PORT_WO_39_OFST // input wire [31:0]
#define ADRS_PORT_WO_3A     MCS_EP_BASE + ADRS_PORT_WO_3A_OFST // input wire [31:0]
#define ADRS_PORT_WO_3B     MCS_EP_BASE + ADRS_PORT_WO_3B_OFST // input wire [31:0]
#define ADRS_PORT_WO_3C     MCS_EP_BASE + ADRS_PORT_WO_3C_OFST // input wire [31:0]
#define ADRS_PORT_WO_3D     MCS_EP_BASE + ADRS_PORT_WO_3D_OFST // input wire [31:0]
#define ADRS_PORT_WO_3E     MCS_EP_BASE + ADRS_PORT_WO_3E_OFST // input wire [31:0]
#define ADRS_PORT_WO_3F     MCS_EP_BASE + ADRS_PORT_WO_3F_OFST // input wire [31:0]
//}

// ADRS_PORT_TI_xx ... //{
#define ADRS_PORT_TI_40     MCS_EP_BASE + ADRS_PORT_TI_40_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_41     MCS_EP_BASE + ADRS_PORT_TI_41_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_42     MCS_EP_BASE + ADRS_PORT_TI_42_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_43     MCS_EP_BASE + ADRS_PORT_TI_43_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_44     MCS_EP_BASE + ADRS_PORT_TI_44_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_45     MCS_EP_BASE + ADRS_PORT_TI_45_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_46     MCS_EP_BASE + ADRS_PORT_TI_46_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_47     MCS_EP_BASE + ADRS_PORT_TI_47_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_48     MCS_EP_BASE + ADRS_PORT_TI_48_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_49     MCS_EP_BASE + ADRS_PORT_TI_49_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4A     MCS_EP_BASE + ADRS_PORT_TI_4A_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4B     MCS_EP_BASE + ADRS_PORT_TI_4B_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4C     MCS_EP_BASE + ADRS_PORT_TI_4C_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4D     MCS_EP_BASE + ADRS_PORT_TI_4D_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4E     MCS_EP_BASE + ADRS_PORT_TI_4E_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_4F     MCS_EP_BASE + ADRS_PORT_TI_4F_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_50     MCS_EP_BASE + ADRS_PORT_TI_50_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_51     MCS_EP_BASE + ADRS_PORT_TI_51_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_52     MCS_EP_BASE + ADRS_PORT_TI_52_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_53     MCS_EP_BASE + ADRS_PORT_TI_53_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_54     MCS_EP_BASE + ADRS_PORT_TI_54_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_55     MCS_EP_BASE + ADRS_PORT_TI_55_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_56     MCS_EP_BASE + ADRS_PORT_TI_56_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_57     MCS_EP_BASE + ADRS_PORT_TI_57_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_58     MCS_EP_BASE + ADRS_PORT_TI_58_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_59     MCS_EP_BASE + ADRS_PORT_TI_59_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5A     MCS_EP_BASE + ADRS_PORT_TI_5A_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5B     MCS_EP_BASE + ADRS_PORT_TI_5B_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5C     MCS_EP_BASE + ADRS_PORT_TI_5C_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5D     MCS_EP_BASE + ADRS_PORT_TI_5D_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5E     MCS_EP_BASE + ADRS_PORT_TI_5E_OFST // input wire, output wire [31:0],
#define ADRS_PORT_TI_5F     MCS_EP_BASE + ADRS_PORT_TI_5F_OFST // input wire, output wire [31:0],
//}

// ADRS_PORT_TO_xx ... //{
#define ADRS_PORT_TO_60     MCS_EP_BASE + ADRS_PORT_TO_60_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_61     MCS_EP_BASE + ADRS_PORT_TO_61_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_62     MCS_EP_BASE + ADRS_PORT_TO_62_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_63     MCS_EP_BASE + ADRS_PORT_TO_63_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_64     MCS_EP_BASE + ADRS_PORT_TO_64_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_65     MCS_EP_BASE + ADRS_PORT_TO_65_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_66     MCS_EP_BASE + ADRS_PORT_TO_66_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_67     MCS_EP_BASE + ADRS_PORT_TO_67_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_68     MCS_EP_BASE + ADRS_PORT_TO_68_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_69     MCS_EP_BASE + ADRS_PORT_TO_69_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6A     MCS_EP_BASE + ADRS_PORT_TO_6A_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6B     MCS_EP_BASE + ADRS_PORT_TO_6B_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6C     MCS_EP_BASE + ADRS_PORT_TO_6C_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6D     MCS_EP_BASE + ADRS_PORT_TO_6D_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6E     MCS_EP_BASE + ADRS_PORT_TO_6E_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_6F     MCS_EP_BASE + ADRS_PORT_TO_6F_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_70     MCS_EP_BASE + ADRS_PORT_TO_70_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_71     MCS_EP_BASE + ADRS_PORT_TO_71_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_72     MCS_EP_BASE + ADRS_PORT_TO_72_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_73     MCS_EP_BASE + ADRS_PORT_TO_73_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_74     MCS_EP_BASE + ADRS_PORT_TO_74_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_75     MCS_EP_BASE + ADRS_PORT_TO_75_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_76     MCS_EP_BASE + ADRS_PORT_TO_76_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_77     MCS_EP_BASE + ADRS_PORT_TO_77_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_78     MCS_EP_BASE + ADRS_PORT_TO_78_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_79     MCS_EP_BASE + ADRS_PORT_TO_79_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7A     MCS_EP_BASE + ADRS_PORT_TO_7A_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7B     MCS_EP_BASE + ADRS_PORT_TO_7B_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7C     MCS_EP_BASE + ADRS_PORT_TO_7C_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7D     MCS_EP_BASE + ADRS_PORT_TO_7D_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7E     MCS_EP_BASE + ADRS_PORT_TO_7E_OFST // input wire, input wire [31:0],
#define ADRS_PORT_TO_7F     MCS_EP_BASE + ADRS_PORT_TO_7F_OFST // input wire, input wire [31:0],
//}

// ADRS_PORT_PI_xx ... //{
#define ADRS_PORT_PI_80     MCS_EP_BASE + ADRS_PORT_PI_80_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_81     MCS_EP_BASE + ADRS_PORT_PI_81_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_82     MCS_EP_BASE + ADRS_PORT_PI_82_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_83     MCS_EP_BASE + ADRS_PORT_PI_83_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_84     MCS_EP_BASE + ADRS_PORT_PI_84_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_85     MCS_EP_BASE + ADRS_PORT_PI_85_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_86     MCS_EP_BASE + ADRS_PORT_PI_86_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_87     MCS_EP_BASE + ADRS_PORT_PI_87_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_88     MCS_EP_BASE + ADRS_PORT_PI_88_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_89     MCS_EP_BASE + ADRS_PORT_PI_89_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8A     MCS_EP_BASE + ADRS_PORT_PI_8A_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8B     MCS_EP_BASE + ADRS_PORT_PI_8B_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8C     MCS_EP_BASE + ADRS_PORT_PI_8C_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8D     MCS_EP_BASE + ADRS_PORT_PI_8D_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8E     MCS_EP_BASE + ADRS_PORT_PI_8E_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_8F     MCS_EP_BASE + ADRS_PORT_PI_8F_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_90     MCS_EP_BASE + ADRS_PORT_PI_90_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_91     MCS_EP_BASE + ADRS_PORT_PI_91_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_92     MCS_EP_BASE + ADRS_PORT_PI_92_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_93     MCS_EP_BASE + ADRS_PORT_PI_93_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_94     MCS_EP_BASE + ADRS_PORT_PI_94_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_95     MCS_EP_BASE + ADRS_PORT_PI_95_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_96     MCS_EP_BASE + ADRS_PORT_PI_96_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_97     MCS_EP_BASE + ADRS_PORT_PI_97_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_98     MCS_EP_BASE + ADRS_PORT_PI_98_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_99     MCS_EP_BASE + ADRS_PORT_PI_99_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9A     MCS_EP_BASE + ADRS_PORT_PI_9A_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9B     MCS_EP_BASE + ADRS_PORT_PI_9B_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9C     MCS_EP_BASE + ADRS_PORT_PI_9C_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9D     MCS_EP_BASE + ADRS_PORT_PI_9D_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9E     MCS_EP_BASE + ADRS_PORT_PI_9E_OFST // output wire, output wire [31:0],
#define ADRS_PORT_PI_9F     MCS_EP_BASE + ADRS_PORT_PI_9F_OFST // output wire, output wire [31:0],
//}

// ADRS_PORT_PO_xx ... //{
#define ADRS_PORT_PO_A0     MCS_EP_BASE + ADRS_PORT_PO_A0_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A1     MCS_EP_BASE + ADRS_PORT_PO_A1_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A2     MCS_EP_BASE + ADRS_PORT_PO_A2_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A3     MCS_EP_BASE + ADRS_PORT_PO_A3_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A4     MCS_EP_BASE + ADRS_PORT_PO_A4_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A5     MCS_EP_BASE + ADRS_PORT_PO_A5_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A6     MCS_EP_BASE + ADRS_PORT_PO_A6_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A7     MCS_EP_BASE + ADRS_PORT_PO_A7_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A8     MCS_EP_BASE + ADRS_PORT_PO_A8_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_A9     MCS_EP_BASE + ADRS_PORT_PO_A9_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AA     MCS_EP_BASE + ADRS_PORT_PO_AA_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AB     MCS_EP_BASE + ADRS_PORT_PO_AB_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AC     MCS_EP_BASE + ADRS_PORT_PO_AC_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AD     MCS_EP_BASE + ADRS_PORT_PO_AD_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AE     MCS_EP_BASE + ADRS_PORT_PO_AE_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_AF     MCS_EP_BASE + ADRS_PORT_PO_AF_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B0     MCS_EP_BASE + ADRS_PORT_PO_B0_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B1     MCS_EP_BASE + ADRS_PORT_PO_B1_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B2     MCS_EP_BASE + ADRS_PORT_PO_B2_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B3     MCS_EP_BASE + ADRS_PORT_PO_B3_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B4     MCS_EP_BASE + ADRS_PORT_PO_B4_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B5     MCS_EP_BASE + ADRS_PORT_PO_B5_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B6     MCS_EP_BASE + ADRS_PORT_PO_B6_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B7     MCS_EP_BASE + ADRS_PORT_PO_B7_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B8     MCS_EP_BASE + ADRS_PORT_PO_B8_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_B9     MCS_EP_BASE + ADRS_PORT_PO_B9_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BA     MCS_EP_BASE + ADRS_PORT_PO_BA_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BB     MCS_EP_BASE + ADRS_PORT_PO_BB_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BC     MCS_EP_BASE + ADRS_PORT_PO_BC_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BD     MCS_EP_BASE + ADRS_PORT_PO_BD_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BE     MCS_EP_BASE + ADRS_PORT_PO_BE_OFST // output wire, input wire [31:0],
#define ADRS_PORT_PO_BF     MCS_EP_BASE + ADRS_PORT_PO_BF_OFST // output wire, input wire [31:0],
//}


//// dedicated lan interface: //{

// 'b_0000_XXHH_hhxx_xx00
//
//         1100 (C)
//         1101 (D)
//         1110 (E)
//         
// 'b_0000_1100_00xx_xx00 -- LAN_WI_00
// 'b_0000_1100_01xx_xx00 -- LAN_WI_10
// 'b_0000_1100_10xx_xx00 -- LAN_WO_20
// 'b_0000_1100_11xx_xx00 -- LAN_WO_30
// 'b_0000_1101_00xx_xx00 -- LAN_TI_40
// 'b_0000_1101_01xx_xx00 -- LAN_TI_50
// 'b_0000_1101_10xx_xx00 -- LAN_TO_60
// 'b_0000_1101_11xx_xx00 -- LAN_TO_70
// 'b_0000_1110_00xx_xx00 -- LAN_PI_80
// 'b_0000_1110_01xx_xx00 -- LAN_PI_90
// 'b_0000_1110_10xx_xx00 -- LAN_PO_A0
// 'b_0000_1110_11xx_xx00 -- LAN_PO_B0
//
#define ADRS_LAN_WI_00      MCS_EP_BASE + ADRS_LAN_WI_00_OFST // output wire [31:0]
#define ADRS_LAN_WI_01      MCS_EP_BASE + ADRS_LAN_WI_01_OFST // output wire [31:0]
#define ADRS_LAN_WO_20      MCS_EP_BASE + ADRS_LAN_WO_20_OFST // input wire [31:0]
#define ADRS_LAN_WO_21      MCS_EP_BASE + ADRS_LAN_WO_21_OFST // input wire [31:0]
#define ADRS_LAN_TI_40      MCS_EP_BASE + ADRS_LAN_TI_40_OFST // input wire, output wire [31:0],
#define ADRS_LAN_TI_41      MCS_EP_BASE + ADRS_LAN_TI_41_OFST // input wire, output wire [31:0],
#define ADRS_LAN_TO_60      MCS_EP_BASE + ADRS_LAN_TO_60_OFST // input wire, input wire [31:0],
#define ADRS_LAN_TO_61      MCS_EP_BASE + ADRS_LAN_TO_61_OFST // input wire, input wire [31:0],
#define ADRS_LAN_PI_80      MCS_EP_BASE + ADRS_LAN_PI_80_OFST // output wire, output wire [31:0],
#define ADRS_LAN_PI_81      MCS_EP_BASE + ADRS_LAN_PI_81_OFST // output wire, output wire [31:0],
#define ADRS_LAN_PO_A0      MCS_EP_BASE + ADRS_LAN_PO_A0_OFST // output wire, input wire [31:0],
#define ADRS_LAN_PO_A1      MCS_EP_BASE + ADRS_LAN_PO_A1_OFST // output wire, input wire [31:0],
//
#define ADRS_FPGA_IMAGE     MCS_EP_BASE + ADRS_FPGA_IMAGE_OFST // image id
#define ADRS_TEST_REG__     MCS_EP_BASE + ADRS_TEST_REG___OFST // test reg 
#define ADRS_MASK_ALL__     MCS_EP_BASE + ADRS_MASK_ALL___OFST // mask all //$$
#define ADRS_MASK_WI___     MCS_EP_BASE + ADRS_MASK_WI____OFST // mask for port IO
#define ADRS_MASK_WO___     MCS_EP_BASE + ADRS_MASK_WO____OFST // mask for port IO
#define ADRS_MASK_TI___     MCS_EP_BASE + ADRS_MASK_TI____OFST // mask for port IO
#define ADRS_MASK_TO___     MCS_EP_BASE + ADRS_MASK_TO____OFST // mask for port IO
//
#define ADRS_LAN_CONF_00    MCS_EP_BASE + ADRS_LAN_CONF_00_OFST //input  wire [31:0]   i_lan_conf_00  // (BASE_ADRS_IP_32B  + i_adrs_offset_ip_32b )
#define ADRS_LAN_CONF_01    MCS_EP_BASE + ADRS_LAN_CONF_01_OFST //input  wire [31:0]   i_lan_conf_01  // (BASE_ADRS_MAC_48B[31: 0] + i_adrs_offset_mac_48b[31: 0] )
#define ADRS_LAN_CONF_02    MCS_EP_BASE + ADRS_LAN_CONF_02_OFST //input  wire [31:0]   i_lan_conf_02  // ( {16'b0,BASE_ADRS_MAC_48B[47:32]} + {16'b0,i_adrs_offset_mac_48b[47:32]} )
#define ADRS_LAN_CONF_03    MCS_EP_BASE + ADRS_LAN_CONF_03_OFST //input  wire [31:0]   i_lan_conf_03  // ( i_lan_timeout_rtr_16b , i_lan_timeout_rcr_16b )
//

//}
	
//}


// parameters common //{
#define MASK_ALL                      0xFFFFFFFF
//}

// TODO: S3100 endpoints adrs //{
#ifdef _S3100_CPU_

// EP address
#define EP_ADRS__SW_BUILD_ID_WI     0x00  //$$ [TEST] SW_BUILD_ID_WI   //$$ S3100
#define EP_ADRS__TEST_CON_WI        0x01  //$$ [TEST] TEST_CON_WI      //$$ S3100
#define EP_ADRS__SSPI_CON_WI        0x02  //$$ [SSPI] SSPI_CON_WI      //$$ S3100
#define EP_ADRS__BRD_CON_WI         0x03  //$$ [TEST] BRD_CON_WI       //$$ S3100
#define EP_ADRS__MEM_FDAT_WI        0x12  //$$ [MEM]  MEM_FDAT_WI      //$$ S3100
#define EP_ADRS__MEM_WI             0x13  //$$ [MEM]  MEM_WI           //$$ S3100
#define EP_ADRS__MSPI_EN_CS_WI      0x16  //$$ [MSPI] MSPI_EN_CS_WI    //$$ S3100 
#define EP_ADRS__MSPI_CON_WI        0x17  //$$ [MSPI] MSPI_CON_WI      //$$ S3100 // SSPI_TEST_WI // for MTH spi master test 
#define EP_ADRS__MCS_SETUP_WI       0x19  //$$ [MCS]  MCS_SETUP_WI     //$$ S3100
#define EP_ADRS__FPGA_IMAGE_ID_WO   0x20  //$$ [TEST] FPGA_IMAGE_ID_WO //$$ S3100
#define EP_ADRS__TEST_OUT_WO        0x21  //$$ [TEST] TEST_OUT_WO      //$$ S3100
#define EP_ADRS__TIMESTAMP_WO       0x22  //$$ [TEST] TIMESTAMP_WO     //$$ S3100
#define EP_ADRS__SSPI_FLAG_WO       0x23  //$$ [SSPI] SSPI_FLAG_WO     //$$ S3100
#define EP_ADRS__MSPI_FLAG_WO       0x24  //$$ [MSPI] MSPI_FLAG_WO     //$$ S3100 // SSPI_TEST_WO //$$
#define EP_ADRS__XADC_TEMP_WO       0x3A  //$$ [XADC] XADC_TEMP_WO     //$$ S3100
#define EP_ADRS__XADC_VOLT_WO       0x3B  //$$ [XADC] XADC_VOLT_WO     //$$ S3100
#define EP_ADRS__TEST_TI            0x40  //$$ [TEST] TEST_TI          //$$ S3100
#define EP_ADRS__MSPI_TI            0x42  //$$ [MSPI] MSPI_TI          //$$ S3100
#define EP_ADRS__MEM_TI             0x53  //$$ [MEM]  MEM_TI           //$$ S3100
#define EP_ADRS__TEST_TO            0x60  //$$ [TEST] TEST_TO          //$$ S3100
#define EP_ADRS__MSPI_TO            0x62  //$$ [MSPI] MSPI_TO          //$$ S3100
#define EP_ADRS__MEM_TO             0x73  //$$ [MEM]  MEM_TO           //$$ S3100
#define EP_ADRS__MEM_PI             0x93  //$$ [MEM]  MEM_PI           //$$ S3100
#define EP_ADRS__MEM_PO             0xB3  //$$ [MEM]  MEM_PO           //$$ S3100

// add  MCS_EP_BASE
#define ADRS_PGU__SW_BUILD_ID         ( MCS_EP_BASE + (EP_ADRS_PGU__SW_BUILD_ID      <<4)  )

#define ADRS__SW_BUILD_ID_WI        ( MCS_EP_BASE + (EP_ADRS__SW_BUILD_ID_WI    <<4) )
#define ADRS__TEST_CON_WI           ( MCS_EP_BASE + (EP_ADRS__TEST_CON_WI       <<4) )
#define ADRS__SSPI_CON_WI           ( MCS_EP_BASE + (EP_ADRS__SSPI_CON_WI       <<4) )
#define ADRS__BRD_CON_WI            ( MCS_EP_BASE + (EP_ADRS__BRD_CON_WI        <<4) )
#define ADRS__MEM_FDAT_WI           ( MCS_EP_BASE + (EP_ADRS__MEM_FDAT_WI       <<4) )
#define ADRS__MEM_WI                ( MCS_EP_BASE + (EP_ADRS__MEM_WI            <<4) )
#define ADRS__MSPI_EN_CS_WI         ( MCS_EP_BASE + (EP_ADRS__MSPI_EN_CS_WI     <<4) )
#define ADRS__MSPI_CON_WI           ( MCS_EP_BASE + (EP_ADRS__MSPI_CON_WI       <<4) )
#define ADRS__MCS_SETUP_WI          ( MCS_EP_BASE + (EP_ADRS__MCS_SETUP_WI      <<4) )
#define ADRS__FPGA_IMAGE_ID_WO      ( MCS_EP_BASE + (EP_ADRS__FPGA_IMAGE_ID_WO  <<4) )
#define ADRS__TEST_OUT_WO           ( MCS_EP_BASE + (EP_ADRS__TEST_OUT_WO       <<4) )
#define ADRS__TIMESTAMP_WO          ( MCS_EP_BASE + (EP_ADRS__TIMESTAMP_WO      <<4) )
#define ADRS__SSPI_FLAG_WO          ( MCS_EP_BASE + (EP_ADRS__SSPI_FLAG_WO      <<4) )
#define ADRS__MSPI_FLAG_WO          ( MCS_EP_BASE + (EP_ADRS__MSPI_FLAG_WO      <<4) )
#define ADRS__XADC_TEMP_WO          ( MCS_EP_BASE + (EP_ADRS__XADC_TEMP_WO      <<4) )
#define ADRS__XADC_VOLT_WO          ( MCS_EP_BASE + (EP_ADRS__XADC_VOLT_WO      <<4) )
#define ADRS__TEST_TI               ( MCS_EP_BASE + (EP_ADRS__TEST_TI           <<4) )
#define ADRS__MSPI_TI               ( MCS_EP_BASE + (EP_ADRS__MSPI_TI           <<4) )
#define ADRS__MEM_TI                ( MCS_EP_BASE + (EP_ADRS__MEM_TI            <<4) )
#define ADRS__TEST_TO               ( MCS_EP_BASE + (EP_ADRS__TEST_TO           <<4) )
#define ADRS__MSPI_TO               ( MCS_EP_BASE + (EP_ADRS__MSPI_TO           <<4) )
#define ADRS__MEM_TO                ( MCS_EP_BASE + (EP_ADRS__MEM_TO            <<4) )
#define ADRS__MEM_PI                ( MCS_EP_BASE + (EP_ADRS__MEM_PI            <<4) )
#define ADRS__MEM_PO                ( MCS_EP_BASE + (EP_ADRS__MEM_PO            <<4) )


#endif
//}
 
// TODO: PGU endpoints adrs //{
#ifdef _PGU_CPU_

// copy from pgu_cpu__lib_conf.py
#define EP_ADRS_PGU__SW_BUILD_ID      0x00
#define EP_ADRS_PGU__TEST_CON         0x01
#define EP_ADRS_PGU__BRD_CON          0x03
#define EP_ADRS_PGU__DACX_DAT_WI      0x04 // remove
#define EP_ADRS_PGU__DACX_WI          0x05 
#define EP_ADRS_PGU__CLKD_WI          0x06
#define EP_ADRS_PGU__SPIO_WI          0x07
#define EP_ADRS_PGU__DACZ_DAT_WI      0x08 // new pattern gen
#define EP_ADRS_PGU__MEM_FDAT_WI      0x12
#define EP_ADRS_PGU__MEM_WI           0x13
#define EP_ADRS_PGU__MCS_SETUP_WI     0x19
#define EP_ADRS_PGU__FPGA_IMAGE_ID    0x20
#define EP_ADRS_PGU__TEST_OUT         0x21
#define EP_ADRS_PGU__TIMESTAMP_WO     0x22
#define EP_ADRS_PGU__TEST_IO_MON      0x23
#define EP_ADRS_PGU__DACX_DAT_WO      0x24 // remove
#define EP_ADRS_PGU__DACX_WO          0x25
#define EP_ADRS_PGU__CLKD_WO          0x26
#define EP_ADRS_PGU__SPIO_WO          0x27
#define EP_ADRS_PGU__DACZ_DAT_WO      0x28 // new pattern gen
#define EP_ADRS_PGU__XADC_TEMP        0x3A
#define EP_ADRS_PGU__XADC_VOLT        0x3B
#define EP_ADRS_PGU__TEST_TI          0x40
#define EP_ADRS_PGU__TEST_IO_TI       0x43
#define EP_ADRS_PGU__DACX_DAT_TI      0x44 // remove
#define EP_ADRS_PGU__DACX_TI          0x45
#define EP_ADRS_PGU__CLKD_TI          0x46
#define EP_ADRS_PGU__SPIO_TI          0x47
#define EP_ADRS_PGU__DACZ_DAT_TI      0x48 // new pattern gen
#define EP_ADRS_PGU__MEM_TI           0x53
#define EP_ADRS_PGU__TEST_TO          0x60
#define EP_ADRS_PGU__MEM_TO           0x73
#define EP_ADRS_PGU__DAC0_DAT_PI      0x84
#define EP_ADRS_PGU__DAC1_DAT_PI      0x85
#define EP_ADRS_PGU__DAC0_DAT_INC_PI  0x86 // new // data b16 + inc b16
#define EP_ADRS_PGU__DAC0_DUR_PI      0x87 // new // duration b32
#define EP_ADRS_PGU__DAC1_DAT_INC_PI  0x88 // new // data b16 + inc b16
#define EP_ADRS_PGU__DAC1_DUR_PI      0x89 // new // duration b32
#define EP_ADRS_PGU__MEM_PI           0x93
#define EP_ADRS_PGU__MEM_PO           0xB3


// add  MCS_EP_BASE
#define ADRS_PGU__SW_BUILD_ID         ( MCS_EP_BASE + (EP_ADRS_PGU__SW_BUILD_ID      <<4)  )
#define ADRS_PGU__TEST_CON            ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_CON         <<4)  )
#define ADRS_PGU__BRD_CON             ( MCS_EP_BASE + (EP_ADRS_PGU__BRD_CON          <<4)  )
#define ADRS_PGU__DACX_DAT_WI         ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_DAT_WI      <<4)  )
#define ADRS_PGU__DACX_WI             ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_WI          <<4)  )
#define ADRS_PGU__CLKD_WI             ( MCS_EP_BASE + (EP_ADRS_PGU__CLKD_WI          <<4)  )
#define ADRS_PGU__SPIO_WI             ( MCS_EP_BASE + (EP_ADRS_PGU__SPIO_WI          <<4)  )
#define ADRS_PGU__DACZ_DAT_WI         ( MCS_EP_BASE + (EP_ADRS_PGU__DACZ_DAT_WI      <<4)  ) // new
#define ADRS_PGU__MEM_FDAT_WI         ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_FDAT_WI      <<4)  )
#define ADRS_PGU__MEM_WI              ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_WI           <<4)  )
#define ADRS_PGU__MCS_SETUP_WI        ( MCS_EP_BASE + (EP_ADRS_PGU__MCS_SETUP_WI     <<4)  )
#define ADRS_PGU__FPGA_IMAGE_ID       ( MCS_EP_BASE + (EP_ADRS_PGU__FPGA_IMAGE_ID    <<4)  )
#define ADRS_PGU__TEST_OUT            ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_OUT         <<4)  )
#define ADRS_PGU__TIMESTAMP_WO        ( MCS_EP_BASE + (EP_ADRS_PGU__TIMESTAMP_WO     <<4)  )
#define ADRS_PGU__TEST_IO_MON         ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_IO_MON      <<4)  )
#define ADRS_PGU__DACX_DAT_WO         ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_DAT_WO      <<4)  )
#define ADRS_PGU__DACX_WO             ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_WO          <<4)  )
#define ADRS_PGU__CLKD_WO             ( MCS_EP_BASE + (EP_ADRS_PGU__CLKD_WO          <<4)  )
#define ADRS_PGU__SPIO_WO             ( MCS_EP_BASE + (EP_ADRS_PGU__SPIO_WO          <<4)  )
#define ADRS_PGU__DACZ_DAT_WO         ( MCS_EP_BASE + (EP_ADRS_PGU__DACZ_DAT_WO      <<4)  ) // new
#define ADRS_PGU__XADC_TEMP           ( MCS_EP_BASE + (EP_ADRS_PGU__XADC_TEMP        <<4)  )
#define ADRS_PGU__XADC_VOLT           ( MCS_EP_BASE + (EP_ADRS_PGU__XADC_VOLT        <<4)  )
#define ADRS_PGU__TEST_TI             ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_TI          <<4)  )
#define ADRS_PGU__TEST_IO_TI          ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_IO_TI       <<4)  )
#define ADRS_PGU__DACX_DAT_TI         ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_DAT_TI      <<4)  )
#define ADRS_PGU__DACX_TI             ( MCS_EP_BASE + (EP_ADRS_PGU__DACX_TI          <<4)  )
#define ADRS_PGU__CLKD_TI             ( MCS_EP_BASE + (EP_ADRS_PGU__CLKD_TI          <<4)  )
#define ADRS_PGU__SPIO_TI             ( MCS_EP_BASE + (EP_ADRS_PGU__SPIO_TI          <<4)  )
#define ADRS_PGU__DACZ_DAT_TI         ( MCS_EP_BASE + (EP_ADRS_PGU__DACZ_DAT_TI      <<4)  ) // new
#define ADRS_PGU__MEM_TI              ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_TI           <<4)  )
#define ADRS_PGU__TEST_TO             ( MCS_EP_BASE + (EP_ADRS_PGU__TEST_TO          <<4)  )
#define ADRS_PGU__MEM_TO              ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_TO           <<4)  )
#define ADRS_PGU__DAC0_DAT_PI         ( MCS_EP_BASE + (EP_ADRS_PGU__DAC0_DAT_PI      <<4)  )
#define ADRS_PGU__DAC1_DAT_PI         ( MCS_EP_BASE + (EP_ADRS_PGU__DAC1_DAT_PI      <<4)  )
#define ADRS_PGU__DAC0_DAT_INC_PI     ( MCS_EP_BASE + (EP_ADRS_PGU__DAC0_DAT_INC_PI  <<4)  ) // new
#define ADRS_PGU__DAC0_DUR_PI         ( MCS_EP_BASE + (EP_ADRS_PGU__DAC0_DUR_PI      <<4)  ) // new
#define ADRS_PGU__DAC1_DAT_INC_PI     ( MCS_EP_BASE + (EP_ADRS_PGU__DAC1_DAT_INC_PI  <<4)  ) // new
#define ADRS_PGU__DAC1_DUR_PI         ( MCS_EP_BASE + (EP_ADRS_PGU__DAC1_DUR_PI      <<4)  ) // new
#define ADRS_PGU__MEM_PI              ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_PI           <<4)  )
#define ADRS_PGU__MEM_PO              ( MCS_EP_BASE + (EP_ADRS_PGU__MEM_PO           <<4)  )

#endif
//}

#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */
