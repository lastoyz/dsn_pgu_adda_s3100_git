//******************************************************************************
//
// 헤더 정의
//
//******************************************************************************
#include <stdio.h>
#include <string.h>

#include "App_moncfg.h"

//******************************************************************************
// 광역 변수 정의
//******************************************************************************

TMonConfig Cfg;
#if 0
#if defined(CONFIG_TSR_MLCC)
/* ================================================================================================== */

static uint8_t		g_nvdata_dirty = 0;
static int8_t		g_nv_state = TSRNV_ERR_NONE;

/* ================================================================================================== */
const TDataItem nv_items[] = {
	{	(unsigned char *)"model"		,	TDATA_STR	,	{g_nv_data.model}				, TSR_SENSOR_ID_SIZE },
	{	(unsigned char *)"serial"		,	TDATA_BIN	,	{g_nv_data.serial}				, TSR_SERIAL_SIZE },
	{	(unsigned char *)"board_id"		,	TDATA_U8	,	{&g_nv_data.board_id}			, 0 },

	{	(unsigned char *)"startup"		,	TDATA_U32	,	{&g_nv_data.app_startup_ms}		, 0	},
	{	(unsigned char *)"r_initwait"	,	TDATA_U32	,	{&g_nv_data.r_initwait_seq}		, 0	},

	{	(unsigned char *)"baudrate"		,	TDATA_U32	,	{&g_nv_data.r_spi_baudrate}		, 0	},
	{	(unsigned char *)"spi_div"		,	TDATA_U32	,	{&g_nv_data.r_spi_div_cnt}		, 0	},

	{	(unsigned char *)"used_channel",	TDATA_STR	,	{g_nv_data.server_name}		, 64},
	{	(unsigned char *)"io_addr"		,	TDATA_U32	,	{&g_nv_data.r_spi_div_cnt}		, 0	},

	/* terminator */	
	{	NULL, TDATA_INVALID, {NULL}, 0 }
};


#endif

TMonConfig Default_Cfg =
{
	MagicNumber         : CONFIG_MAGIC,              	// 환경 데이타가 있음의 검증에 대한 매직 번호 0x89880003

	AutoBootWaitTime    : DEFAULT_BOOT_WAIT,         	// 자동 부트 대기 시간 ( 초 단위 )
	BootMenuKey         : DEFAULT_ENTRY_KEY,         	// 부트 로더 진입 키 기본 ' '
	UseRamdisk	    : 'Y',								// 램디스 복사유무
	Rev1                : { 0x0,0x0 },           		// 예약 영역     
	
	Local_MacAddress    : DEFAULT_LOCAL_MAC,       		// 보드 MAC Address  [xx:xx:xx:xx:xx:xx]    
	Local_IP            : DEFAULT_LOCAL_IP,				// local IP   xxx.xxx.xxx.xxx
	Host_MacAddress     : {0,0,0,0,0,0},       			// 호스트 MAC Address  [xx:xx:xx:xx:xx:xx]
	Host_IP             : 0,                         	// 호스트 IP  = 0
	
	TFTP_Directory      : DEFAULT_TFTP_DIR,             // TFTP 디렉토리 명   
	TFTP_zImageFileName : DEFAULT_KERNEL_FILENAME,      // 커널 이미지      화일 명 디폴트
	TFTP_RamDiskFileName: DEFAULT_RAMDISK_FILENAME,     // 램 디스크 이미지 화일 명 디폴트
	TFTP_LoaderFileName : DEFAULT_EZBOOT_FILENAME,      // 부트로더         화일 명 디폴트
	
	SeriaNumber         : DEFAULT_SERIAL,               // 사용할 시리얼 번호  
	Kernel_ArchNumber   : 0,							// 커널에 전달될 커널 아키텍쳐 번호
	
	KCmd : {
		CMD_MagicNumber : CONFIG_CMD_MAGIC,       // 커널 커맨드 매직번호 
		CMD_Tag         : "CMD=",                 // 커널 명령 라인 디폴트 ""
		Kernel_CmdLine  : DEFAULT_KERNEL_COMMAND  // 커널 명령 라인 디폴트 ""   
	},
	TopConfigure : {
		signature 	: NV_DEF_SIGNATURE,
		length 		: sizeof(TSRNVData) - TSRNV_HEADER_SIZE,
		crc32 		: 0,
		model 		: "MHVSU FW",	
		serial 		: { 0xFF,0xFE,0xFD,0xFC,0xFB,0xFA,0xF9,0xF8,0xF7,0xF6,0xF5,0xF4,0xF3,0xF2,0xF1,0xF0 }, 
		board_id 	: 0,
		app_startup_ms : 03000,
		r_initwait_seq : 0400,
		r_comm_mode		:0,
		r_dbg_comm_port	:0,
		r_spi_baudrate : 01000000,				// spi baudrate : 1MHz (default)
		r_spi_div_cnt : 012,
		used_channel :  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, 			// multi channel status (64 channels)
		io_map_base_address : 0x60000000 		// for fpga 
	},
};

//------------------------------------------------------------------------------
// 설명 : 환경을 불러온다.
// 주의 : 
//------------------------------------------------------------------------------
BOOL LoadMonConfig( void )
{
	if ( CONFIG_MAGIC == *(uint32_t*)(DEFAULT_BOOT_PARAM) )
	{
		memcpy( &Cfg, (unsigned char *)(DEFAULT_BOOT_PARAM), sizeof(TMonConfig) );
		return TRUE;
	}
	else
	{
		memcpy( &Cfg, &Default_Cfg, sizeof(TMonConfig) );
		return FALSE;
	}
}

//------------------------------------------------------------------------------
// 설명 : 문자열을 분리한다.
// 주의 : 
//------------------------------------------------------------------------------
char *delim_ = " .:\n";   //\f\n\r\t\v
int Cfg_parse_args(char *cmdline, char **argv)
{
	char *tok;
	int argc = 0;

	argv[argc] = NULL;

	for (tok = strtok(cmdline, delim_); tok; tok = strtok(NULL, delim_)) 
	{
		argv[argc++] = tok;
	}

	return argc;
}

//------------------------------------------------------------------------------
// 설명 : 문자열을 정수형으로 변경한다.
// 매계 : 문자열, 핵사유무
// 반환 :
// 주의 : 
//------------------------------------------------------------------------------
uint8_t StrToByte( char *ptr, int hex )
{
	uint8_t    rtn = 0;

	while (1)
	{
		if (*ptr == '\0') break;

		if (hex) rtn *= 16;
		else     rtn *= 10; 
		switch (*ptr)
		{
			case '0' ... '9' : rtn += (uint8_t)(*ptr)&0x0f;       break;
			case 'A' ... 'F' : 
			case 'a' ... 'f' : rtn += ((uint8_t)(*ptr)&0x0f) + 9; break;
		}
		ptr++;
	}
	return rtn;
}

#endif




