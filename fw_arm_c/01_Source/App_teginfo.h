/*
 * <STAINFO.H>
 * sta infomation read and write
 *
 *   Programmed by Baek Wangki
 * 	 2001.12.20
 */

#ifndef _TEGINFO_H
#define _TEGINFO_H
//
#include    "top_core_info.h"

#define MODULE_MAGIC_CODE	0xE1EC5L

#define MODULE_CPU			0
#define MODULE_IO1			1
#define MODULE_IO2			2
#define MODULE_VSM			3
#define MODULE_SMU1			4
#define MODULE_SMU2			5
#define MODULE_SMU3			6
#define MODULE_SMU4			7
#define MODULE_EXT			8
#define MAX_MODULE			9

#define MAX_MODULE_NAME     11
#define MAX_MODULE_SERIAL   23

// sbcho@20211220 HVSMU
// #define ADC_CALIB_OFFSET        0x400
// #define VSM_CALIB_OFFSET        0x500
// #define SMU_CALIB_OFFSET        0x400
// #define HPU_CALIB_OFFSET        0x400
// #define SMU_ZERO_CALIB_OFFSET   0x600

// #define GNDU_CALIB_OFFSET    0x400

#define SMU_CALIB_OFFSET        0x000
#define SMU_ZERO_CALIB_OFFSET   0x200

#define GNDU_CALIB_OFFSET    0x000

#define MODULE_EBOX_HPU1    0
#define MODULE_EBOX_HPU2    1
#define MODULE_EBOX_HPU3    2
#define MODULE_EBOX_HPU4    3
#define MAX_MODULE_EBOX     4

#define DOWNLOAD_RAM_ADDR	0xA7000000 

typedef struct {
    BOOL installed;
    long id;
    long version;
    long birthday;
    long calibday;
    char name[MAX_MODULE_NAME+1];
    char serial[MAX_MODULE_SERIAL+1];
} TModuleInfo;

extern TModuleInfo module_info[MAX_MODULE];
extern TModuleInfo ebox_module_info[MAX_MODULE_EBOX];

#ifdef __cplusplus
    extern "C" {
#endif

//
BOOL write_smu_zero_calib_para(int ch);
//
BOOL write_smu_calib_para(int ch);
BOOL write_gndu_calib_para(void);
//
void read_smu_zero_calib_para(int ch, long *magic);
//
void read_smu_calib_para(int ch);
void read_gndu_calib_para(void);
void print_calib_para(int ch);
void print_calib_para_all(void);
void write_calib_para_all(void);
void read_calib_para_all(void);




#ifdef __cplusplus
    }
#endif

#endif



