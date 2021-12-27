#ifndef _TOP_CORE_INFO_H
#define	_TOP_CORE_INFO_H

#include	"UserDefine.h"
//#include	"dwt_stm32_delay.h"

#define _SHIFT_ADDR(a)  (a << 1)
#define _SHIFT_R_ADDR(a)  (a >> 1)

#define _SPI_SEL_SLOT(a)     	(1 << (a + 1))  // in S3100 slot 1~12
#define _SPI_SEL_SLOT_GNDU()  	SLOT_CS0  		// in S3100-GNDU slot 0
#define _SPI_SEL_SLOT_SMU(a)	(1 << (a + 1))	// in S3100 slot 1~12
#define _SPI_SEL_SLOT_CMU(a)	(1 << (a + 1))  // in S3100 slot 1~12
#define _SPI_SEL_SLOT_PGU(a)	(1 << (a + 1))  // in S3100 slot 1~12



/*
SYSTEM_VERSION RULE
MAJOR.MINOR.RELEASE.TYPE

TYPE
{
	A : Alpha,
	B : Beta,
	R : Release,
}
*/

enum{
	BOARDTYPE_NONE = 0,
	BOARDTYPE_CORE,
	BOARDTYPE_POWER,
	BOARDTYPE_ICT,
	BOARDTYPE_EXT
};

enum{
	S3000_PGU = 0xBD,
	S3000_CMU = 0xED,
	S3100_GNDU = 0xA2,
	S3100_PGU_ADDA = 0xA4, // res
	S3100_CMU_ADDA = 0xA6,
	E8000_HLSMU = 0xA7,
	S3100_HVSMU = 0xA8,
	S3100_CMU_SUB = 0xAB,
	//S3100_CMU_ANAL = 0xAA,
	//S3100_CMU_SIG = 0xAC
	S3100_PGU_SUB    = 0xAE   // alias S3100_HVPGU
};




#define SMU_DBG_POINT 		0


#define BOARD_TYPE			BOARDTYPE_CORE

#define	SYSTEM_MODEL		"TOP-CORE"

#define	SYSTEM_MODEL_CODE	(u32)0x75020100

#define SYSTEM_VERSION		"1.1.9.R"
#define	SYSTEM_BUILDDATE	"2020.12.14"

#define	SOURCE_MAX_COUNT	3		// ETHERNET, SERIAL, GPIB

#define	USE_ETHERNET_IP 	0
#define	USE_FREERTOS		0

typedef	struct{
	u32	received;
	u32	txSource;
	u32 rxSource;
	u32	txLength;
	u32	rxLength;
	u32 txCount;
	u8	*txData;
	u8	*rxData[SOURCE_MAX_COUNT];
}trxData_t;

typedef struct {
	u8 Lock;
} hal_lock_t;


/* debug message definition */

#define DBG_NO_MESSAGE  0
#define DBG_LEVEL_0		1		// normal print

#define DEBUG  DBG_LEVEL_0

#if defined(DEBUG) && (DEBUG == 1)
	#define DEBUG_PRINT(fmt, args...) Ext_Serial_Printf("DEBUG: " fmt, ##args)
#else
	#define DEBUG_PRINT(fmt, args...) 
#endif

//#define TRACE(fmt, args...) Ext_Serial_Printf("TRACE: " fmt, ##args)
#define TRACE(fmt, args...) Serial_Printf("TRACE: " fmt, ##args)


/*
typedef	union{
	u8	u8Data[128];
	struct{
		u32	header;
		u32	serialNo;
	};
}systemData_t;
*/

#include	"stm32f7xx_hal.h"
//#include	"dwt_stm32_delay.h"

typedef	struct{
	GPIO_TypeDef	*port;
	u16				pin;
	u8				direction;
	u8				value;
}ioStatus_t;

/** NAND address */
typedef struct nand_address_t {

	/* LUN */
	MT_uint32 lun;

	/* block address */
	MT_uint32 block;

	/* page address */
	MT_uint32 page;

	/* column address */
	MT_uint32 column;

} nand_addr_t;



/** Parameter Page Data Structure */
typedef struct parameter_page_t {
	/** Parameter page signature (ONFI) */
	char signature[5];

	/** Revision number */
	MT_uint16 rev_num;

	/** Features supported */
	MT_uint16 feature;

	/** Optional commands supported */
	MT_uint16 command;

	/** Device manufacturer */
	char manufacturer[13];

	/** Device part number */
	char model[21];

	/** Manufacturer ID (Micron = 2Ch) */
	MT_uint8 jedec_id;

	/** Date code */
	MT_uint16 date_code;

	/** Number of data bytes per page */
	MT_uint32 data_bytes_per_page;

	/** Number of spare bytes per page */
	MT_uint16 spare_bytes_per_page;

	/** Number of data bytes per partial page */
	MT_uint32 data_bytes_per_partial_page;

	/** Number of spare bytes per partial page */
	MT_uint16 spare_bytes_per_partial_page;

	/** Number of pages per block */
	MT_uint32 pages_per_block;

	/** Number of blocks per unit */
	MT_uint32 blocks_per_lun;

	/** Number of logical units (LUN) per chip enable */
	MT_uint8 luns_per_ce;

	/** Number of address cycles */
	MT_uint8 num_addr_cycles;

	/** Number of bits per cell (1 = SLC; >1= MLC) */
	MT_uint8 bit_per_cell;

	/** Bad blocks maximum per unit */
	MT_uint16 max_bad_blocks_per_lun;

	/** Block endurance */
	MT_uint16 block_endurance;

	/** Guaranteed valid blocks at beginning of target */
	MT_uint8 guarenteed_valid_blocks;

	/** Block endurance for guaranteed valid blocks */
	MT_uint16 block_endurance_guarenteed_valid;

	/** Number of programs per page */
	MT_uint8 num_programs_per_page;

	/** Partial programming attributes */
	MT_uint8 partial_prog_attr;

	/** Number of bits ECC bits */
	MT_uint8 num_ECC_bits_correctable;

	/** Number of interleaved address bits */
	MT_uint8 num_interleaved_addr_bits;

	/** Interleaved operation attributes */
	MT_uint8 interleaved_op_attr;

} param_page_t;

enum{
	IO_INPUT = 0,
	IO_OUTPUT,
	IO_INT_RISING,
	IO_INT_FALLING,
	IO_INT_RISING_FALLING
};

#if	USE_FREERTOS

#include	"FreeRTOS.h"
#include	"task.h"
#include	"queue.h"
#include	"semphr.h"
#include	"timers.h"

#endif	// USE_RTOS

#if USE_ETHERNET_IP

#include	"opt.h"
#include	"init.h"
#include	"netif.h"
#include	"etharp.h"
#include	"lwip_timers.h"
#include	"ethernetif.h"
#include	"app_ethernet.h"
#include	"tcp_server.h"
#include	"udp_server.h"

#else

#include	"dwt_stm32_delay.h"

#include 	"wizchip_conf.h"
#include 	"App_moncfg.h"
#include 	"socket.h"

#endif 	// !USE_ETHERNET_IP


#include	"System_Converter.h"

//#include	"FatFS_GenDrv.h"
//#include	"MicroSD_DiskIO.h"
//#include	"NANDFlash_DiskIO.h"

#include	"nand_hw_if.h"
#include	"nand_MT29F_lld.h"

#include	"BSP_Base.h"
#include	"BSP_FMC.h"
#include	"BSP_I2C.h"
//#include	"BSP_MircoSD.h"
#include	"BSP_SPI.h"


#include	"App_BoardTest.h"
#include	"App_flash.h"
#include	"App_Command.h"
#include	"App_CoreReg.h"
#include	"App_EEPROM.h"
#include	"App_EXTI.h"
//#include	"App_ExtIO.h"
//#include	"App_File.h"
//#include	"App_FileManager.h"
#include	"App_FPGA.h"
#include	"App_GPIO.h"
#include	"App_ICT.h"
#include	"App_Initialize.h"
//#include	"App_Log.h"
#include	"App_Network.h"
#include	"App_Power.h"
//#include	"App_Script.h"
#include	"App_Serial.h"
#include	"App_System.h"
#include	"App_Timer.h"
#include	"App_MlccTest.h"
#include 	"mcuClock.h"
#include	"App_SMU.h"
#include	"App_measure.h"
#include	"App_SEEPROM.h"
#include	"App_teginfo.h"
#include	"App_SmuTest.h"
#include	"App_CmuTest.h"
#include	"App_PguTest.h"

#include	"Cmd_BoardTest.h"
//#include	"Cmd_ExtIO.h"
#include	"Cmd_File.h"
#include	"Cmd_FPGA.h"
#include	"Cmd_Gpio.h"
#include	"Cmd_ICT.h"
//#include	"Cmd_Log.h"
#include	"Cmd_Power.h"
#include	"Cmd_System.h"
#include	"Cmd_MlccTest.h"
#include	"Cmd_SmuTest.h"
#include	"Cmd_CmuTest.h"
#include	"Cmd_PguTest.h"

//-------------------------------------------------------------------//
#include 	"StaClientsApp.h"
#include 	"zmodem.h"
//#include 	"protocol_parser.h"
#include	"InterfaceApp.h"
#include 	"shell.h"

#include	"main.h"

#define	SDRAM_RGB_DUMP_ADRS				(u32)0xC0000000			// 32MB		0xC0000000 ~ 0xC1FFFFFF
#define	SDRAM_BMP_DUMP_ADRS				(u32)0xC2000000			// 32MB		0xC2000000 ~ 0xC3FFFFFF
#define	SDRAM_FPGA_READ_ADRS			(u32)0xC4000000			// 32MB		0xC4000000 ~ 0xC5FFFFFF
#define	SDRAM_DUMMY_1_ADRS				(u32)0xC6000000			// 16MB		0xC6000000 ~ 0xC6FFFFFF
#define	SDRAM_DUMMY_2_ADRS				(u32)0xC7000000			// 4MB		0xC7000000 ~ 0xC73FFFFF
#define	SDRAM_DUMMY_3_ADRS				(u32)0xC7400000			// 4MB		0xC7400000 ~ 0xC77FFFFF
#define	SDRAM_SERIAL_RX_EXT				(u32)0xC7800000			// 2MB		0xC7800000 ~ 0xC79FFFFF
#define	SDRAM_CMD_BUFFER_ADRS			(u32)0xC7A00000			// 256KB	0xC7A00000 ~ 0xC7A3FFFF
#define	SDRAM_RX_BUFFER_ADRS			(u32)0xC7A40000			// 256KB	0xC7A40000 ~ 0xC7A7FFFF
#define	SDRAM_SERIAL_RX_BUFFER_ADRS		(u32)0xC7A80000			// 128KB	0xC7A80000 ~ 0xC7A9FFFF
#define	SDRAM_USB_RX_BUFFER_ADRS		(u32)0xC7AA0000			// 128KB	0xC7AA0000 ~ 0xC7ABFFFF
#define	SDRAM_ETHERNET_RX_BUFFER_ADRS	(u32)0xC7AC0000			// 128KB	0xC7AC0000 ~ 0xC7ADFFFF
#define	SDRAM_CMD_RX_BUFFER_ADRS		(u32)0xC7AE0000			// 128KB	0xC7AE0000 ~ 0xC7AFFFFF
#define	SDRAM_CMD_TX_BUFFER_ADRS		(u32)0xC7B00000			// 1MB		0xC7B00000 ~ 0xC7BFFFFF
#define	SDRAM_SCRIPT_FILE_0_ADRS		(u32)0xC7C00000			// 128KB	0xC7C00000 ~ 0xC7C1FFFF
#define	SDRAM_SCRIPT_FILE_1_ADRS		(u32)0xC7C20000			// 128KB	0xC7C20000 ~ 0xC7C3FFFF
#define	SDRAM_SCRIPT_FILE_2_ADRS		(u32)0xC7C40000			// 128KB	0xC7C40000 ~ 0xC7C5FFFF
#define	SDRAM_SCRIPT_FILE_3_ADRS		(u32)0xC7C60000			// 128KB	0xC7C60000 ~ 0xC7C7FFFF
#define	SDRAM_SCRIPT_FILE_4_ADRS		(u32)0xC7C80000			// 128KB	0xC7C80000 ~ 0xC7C9FFFF
#define	SDRAM_SCRIPT_FILE_5_ADRS		(u32)0xC7CA0000			// 128KB	0xC7CA0000 ~ 0xC7CBFFFF
#define	SDRAM_SCRIPT_FILE_6_ADRS		(u32)0xC7CC0000			// 128KB	0xC7CC0000 ~ 0xC7CDFFFF
#define	SDRAM_SCRIPT_FILE_7_ADRS		(u32)0xC7CE0000			// 128KB	0xC7CE0000 ~ 0xC7CFFFFF
#define	SDRAM_NAND_FLASH_BACKUP_ADRS	(u32)0xC7D00000			// 512KB	0xC7D00000 ~ 0xC77FFFFF
#define	SDRAM_FLASH_MEMORY_BACKUP_ADRS	(u32)0xC7D80000			// 384KB	0xC7D80000 ~ 0xC7DDFFFF
#define	SDRAM_IMAGE_LIST_ADRS			(u32)0xC7DE0000			// 128KB	0xC7DE0000 ~ 0xC7DFFFFF
#define	SDRAM_USER_LOG_ADRS				(u32)0xC7E00000			// 1MB		0xC7E00000 ~ 0xC7EFFFFF
#define	SDRAM_DEBUG_LOG_ADRS			(u32)0xC7F00000			// 1MB		0xC7F00000 ~ 0xC7FFFFFF
#define	SDRAM_JPG_DUMP_ADRS				SDRAM_RGB_DUMP_ADRS
#define	SDRAM_TOUCH_BIN_ADRS			SDRAM_DUMMY_4_ADRS

#define SDRAM_CODE_SECTION0				SDRAM_DUMMY_1_ADRS + 0x00000000		// 1MB		0xC6000000 ~ 0xC60FFFFF
#define SDRAM_CODE_SECTION1				SDRAM_DUMMY_1_ADRS + 0x00100000		// 1MB		0xC6100000 ~ 0xC61FFFFF
#define SDRAM_CODE_SECTION2				SDRAM_DUMMY_1_ADRS + 0x00200000		// 1MB		0xC6200000 ~ 0xC62FFFFF
#define SDRAM_CODE_SECTION3				SDRAM_DUMMY_1_ADRS + 0x00300000		// 1MB		0xC6300000 ~ 0xC63FFFFF
#define SDRAM_CODE_SECTION4				SDRAM_DUMMY_1_ADRS + 0x00400000		// 1MB		0xC6400000 ~ 0xC64FFFFF
#define SDRAM_CODE_SECTION5				SDRAM_DUMMY_1_ADRS + 0x00500000		// 1MB		0xC6500000 ~ 0xC65FFFFF
#define SDRAM_CODE_SECTION6				SDRAM_DUMMY_1_ADRS + 0x00600000		// 1MB		0xC6600000 ~ 0xC66FFFFF
#define SDRAM_CODE_SECTION7				SDRAM_DUMMY_1_ADRS + 0x00700000		// 1MB		0xC6700000 ~ 0xC67FFFFF
#define SDRAM_CODE_SECTION8				SDRAM_DUMMY_1_ADRS + 0x00800000		// 1MB		0xC6800000 ~ 0xC68FFFFF
#define SDRAM_CODE_SECTION9				SDRAM_DUMMY_1_ADRS + 0x00900000		// 1MB		0xC6900000 ~ 0xC69FFFFF
#define SDRAM_CODE_SECTION10			SDRAM_DUMMY_1_ADRS + 0x00A00000		// 1MB		0xC6A00000 ~ 0xC6AFFFFF
#define SDRAM_CODE_SECTION11			SDRAM_DUMMY_1_ADRS + 0x00B00000		// 1MB		0xC6B00000 ~ 0xC6BFFFFF
#define SDRAM_CODE_SECTION12			SDRAM_DUMMY_1_ADRS + 0x00C00000		// 1MB		0xC6C00000 ~ 0xC6CFFFFF
#define SDRAM_CODE_SECTION13			SDRAM_DUMMY_1_ADRS + 0x00D00000		// 1MB		0xC6D00000 ~ 0xC6DFFFFF
#define SDRAM_CODE_SECTION14			SDRAM_DUMMY_1_ADRS + 0x00E00000		// 1MB		0xC6E00000 ~ 0xC6EFFFFF
#define SDRAM_CODE_SECTION15			SDRAM_DUMMY_1_ADRS + 0x00F00000		// 1MB		0xC6F00000 ~ 0xC6FFFFFF


// GNDU Calibration Section : 0xC7000000 ~ 0xC7000FFF
#define	SDRAM_GNDU_CAL_SECTION				SDRAM_DUMMY_2_ADRS + 0x00000000		// 4KB		0xC7000000 ~ 0xC7000FFF

// SMU Calibration Section : 0xC7010000 ~ 0xC73FFFFF
// SMU Channel Offset : 0x00010000
#define SDRAM_SMU_CAL_SECTION_OFFSET		(u32)0x00001000						// 4KB		0xC7001000 ~ 0xC7096FFF(SMU 150ch capacity)
#define	SDRAM_SMU_CAL_SECTION				SDRAM_DUMMY_2_ADRS + 0x00001000		


#define SDRAM_SMU_ZERO_CAL_SECTION_OFFSET	(u32)0x00001000						// 4KB		0xC7001000 ~ 0xC712CFFF(SMU 150ch capacity)
#define	SDRAM_SMU_ZERO_CAL_SECTION			SDRAM_DUMMY_2_ADRS + 0x00097000		






// lock
u8 Ext_Serial_Printf(const char *pData, ...);

u8 Serial_Printf(const char *pData, ...);



inline HAL_StatusTypeDef hal_lock(hal_lock_t *lock)
{
	__HAL_LOCK(lock);
//	TRACE("lock...  \r\n");
	return HAL_OK;
}

inline HAL_StatusTypeDef hal_unlock(hal_lock_t *lock)
{
	__HAL_UNLOCK(lock);
//	TRACE("unlock...  \r\n");
	return HAL_OK;
}

#endif	// !_TOP_CORE_INFO_H_
