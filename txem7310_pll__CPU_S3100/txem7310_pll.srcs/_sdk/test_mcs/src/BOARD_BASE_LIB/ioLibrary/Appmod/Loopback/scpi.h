#ifndef  _SCPI_H_
#define  _SCPI_H_

#include "../../../mcs_io_bridge_ext.h" //$$ board dependent

//// scpi debug

//#define _SCPI_DEBUG_MIN_ //$$ SCPI server debug connection info
//#define _SCPI_DEBUG_ //$$ SCPI server debug

////#define _SCPI_DEBUG_WCMSG_ // welcome message enabled


//// SCPI command set control

#define _SCPI_CMD_PGU_

// MCS EP control
//#define  MCS_EP_BASE  ADRS_BASE_PGU
//#define  MCS_EP_BASE  ADRS_BASE_MHVSU

//#define _IDN_BOARD_NAME_  "PGU-CPU-F5500"
//#define _IDN_BOARD_NAME_  "MHVSU-BASE-R7000"
//#define _IDN_BOARD_NAME_  "CMU-CPU-F5500-LAN"
//#define _IDN_BOARD_NAME_  "PGU-CPU-F5500-LAN"
#define _IDN_BOARD_NAME_    "S3100-CPU-BASE-LAN"

//// buffer sizes //{

//// incoming buffer
//#define DATA_BUF_SIZE_SCPI   2048 //$$ init
//#define DATA_BUF_SIZE_SCPI   256 //$$ test
//#define DATA_BUF_SIZE_SCPI   2048+56 //$$ final
//#define DATA_BUF_SIZE_SCPI   2048*4 //$$ try
//#define DATA_BUF_SIZE_SCPI   4096 //$$ try
//#define DATA_BUF_SIZE_SCPI   4096+512 //$$ try
//#define DATA_BUF_SIZE_SCPI   4096*2+128 //$$ OK with EEPROM 2KB or FIFO 8KB
#define DATA_BUF_SIZE_SCPI   4096*4+128 //$$ OK with EEPROM 2KB or FIFO 8KB
//#define DATA_BUF_SIZE_SCPI   8192 //$$ try

//#define DATA_BUF_SIZE_SCPI_SUB   256 //$$ try

//// response buffer
#define RSP_BUF_SIZE_SCPI   128 //$$ init
//#define RSP_BUF_SIZE_SCPI   2048*4 //$$ test
//#define RSP_BUF_SIZE_SCPI   8192 //$$ try

//}

//// watch-dog counter

//#define MAX_CNT_STAY_SOCK_ESTABLISHED 0x08800000 // about 57 min stay at system clock 10MHz // 24us per count... // with two sockets opened
#define MAX_CNT_STAY_SOCK_ESTABLISHED 0x01800000 // about 10 min stay at system clock 10MHz // 24us per count... // with two sockets opened
//#define MAX_CNT_STAY_SOCK_ESTABLISHED 0x00800000 // about 3.3 min stay at system clock 10MHz // 24us per count... // with two sockets opened
//#define MAX_CNT_STAY_SOCK_ESTABLISHED 0x00300000 // about 75 sec stay at system clock 10MHz // 24us per count... // with two sockets opened
//#define MAX_CNT_STAY_SOCK_ESTABLISHED 0x00100000 // about 26 sec stay at system clock 10MHz
//#define MAX_CNT_STAY_SOCK_ESTABLISHED 0 // for no time limit to stay established


//  int32_t scpi_tcps(uint8_t sn, uint8_t* buf, uint16_t port); //$$ scpi server - normal

int32_t scpi_tcps_ep(uint8_t sn, uint8_t* buf, uint16_t port); //$$ scpi server - only low-level end-point

int32_t scpi_tcps_ep_state(uint8_t sn, uint8_t* buf, uint16_t port); //$$ scpi server - state-machine operation


#endif   // _SCPI_H_
