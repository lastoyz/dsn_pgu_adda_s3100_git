//------------------------------------------------------------------------------
// 파 일 명 : moncfg.h
// 프로젝트 : ezboot
// 설    명 : ezboot에서 사용하는 환경 설정에 관련된 내용
// 작성자 : 유영창 (주)제이닷디엔티 frog@falinux.com
//          오재경 (주)제이닷디엔티 freefrug@falinux.com  -- 푸지
// 작성일 : 2002년 1월 19일
// 수  정 : 2003-06-07	
// 저작권 : (주)제이닷디엔티 
// 주  의 : 
//------------------------------------------------------------------------------

#ifndef _MONCFG_HEADER_
#define _MONCFG_HEADER_

#include "top_core_info.h"

#ifdef __cplusplus
extern "C" {
#endif

#define CONFIG_MAGIC				0x89880012
#define CONFIG_CMD_MAGIC			0x20030702
#define DEFAULT_BOOT_WAIT			3
#define DEFAULT_ENTRY_KEY			' '
#define DEFAULT_SERIAL				0  

#define DEFAULT_LOCAL_MAC			{0x00, 0xA2, 0x55, 0xF2, 0x26, 0x25}
#define DEFAULT_LOCAL_IP			(192<<0)|(168<<8)|(2<<16)|(181<<24)

#define DEFAULT_TFTP_DIR			""
#define DEFAULT_KERNEL_FILENAME		"teg"
#define DEFAULT_RAMDISK_FILENAME	"ramdisk"
#define DEFAULT_EZBOOT_FILENAME		"bmon"

#define DEFAULT_KERNEL_COMMAND		"keepinitrd root=/dev/ramdisk console=ttyS02,115200"
#if 0

#define LINUX_MACH_TYPE             303

#define DEFAULT_FLASH_BOOT          0x00000000 // 플래쉬에서 부트 시작 어드레스 
#define DEFAULT_BOOT_SIZE           (256*1024) // 부트영역의 크기
#define DEFAULT_BOOT_PARAM         	(DEFAULT_FLASH_BOOT+DEFAULT_BOOT_SIZE) // 플래쉬에서 부트 파라메터 영역
#define	DEFAULT_BOOT_PARAM_SIZE		(256*1024)
#define DEFAULT_RAM_WORK_START      0xA7000000 

typedef unsigned char  uint8_t;
typedef unsigned short Word16;
typedef unsigned long  uint32_t;
#endif

typedef struct 
{
	uint32_t	CMD_MagicNumber;        // 커널 커맨드 매직번호 
	char    CMD_Tag       [8]; 	// 커널 명령 라인 디폴트 ""
	char    Kernel_CmdLine[512]; 	// 커널 명령 라인 디폴트 ""
} __attribute__ ((packed)) TKernelCommandLine;

#if defined(CONFIG_TST_MLCC)
#define NV_DEF_SIGNATURE	0xAABB400E

#define TSRNV_HEADER_SIZE	(4*3)	/* signature, length, crc32 */
#define TSR_SMU_CH_CNT		64

#define TSR_SENSOR_ID_SIZE	32
#define TSR_SERIAL_SIZE 	32

typedef union __TDataUnion {
	void* 	pVOID;
	uint8_t*	pU8;
	uint16_t*	pU16;
	uint32_t*	pU32;
	uint32_t*	pIp;
	uint8_t*	pMac;
	char*	pStr;
	uint8_t*	pBin;
} TDataUnion;

#define TDATA_INVALID	0
#define TDATA_U8		1
#define TDATA_U16		2
#define TDATA_U32		3
#define TDATA_IP		4
#define TDATA_MAC		5
#define TDATA_STR		6
#define TDATA_BIN		7

typedef struct __TDataItem {
	const unsigned char *	name;
	uint8_t			type;
	TDataUnion		d;
	uint8_t			len;	// string only
} TDataItem;

typedef struct __TSRNVData {
	/* =========================================== */
	/* basic header */
	uint32_t		signature;
	uint32_t		length;
	uint32_t		crc32;
	/* =========================================== */
	/* data field */
	uint8_t		model[TSR_SENSOR_ID_SIZE+2];	// string
	uint8_t		serial[TSR_SERIAL_SIZE];			// bin
	uint8_t		board_id;

	/* startup time */
	uint32_t		app_startup_ms;
	uint32_t		r_initwait_seq;

	/* communication config*/
	uint8_t 		r_comm_mode;
	uint8_t 		r_dbg_comm_port;

	/* spi configure */
	uint32_t		r_spi_baudrate;	// related r_spi_div_cnt
	uint32_t		r_spi_div_cnt;	// baudrate : 13MHz / (cnt + 1)

	/* multi channel status */
	uint8_t 		used_channel[TSR_SMU_CH_CNT];;

	/* debug */
	uint32_t		io_map_base_address;		// io mapped address for FPGA

	/* =========================================== */
} __attribute__ ((packed)) TSRNVData;

#endif

typedef struct SConfig
{
	uint32_t	MagicNumber;           	// 환경 데이타가 있음의 검증에 대한 매직 번호 0x8988000x

	uint32_t	AutoBootWaitTime;      	// 자동 부트 대기 시간 ( 초 단위 )

	char    BootMenuKey;    	// 부트 로더 진입 키 기본 ' '
	char	UseRamdisk;		// 램디스크 사용유무
	char    Rev1[2];               	// 예약 영역     

	uint8_t    Local_MacAddress[8];   	// 보드   MAC Address  [xx:xx:xx:xx:xx:xx] 
	uint8_t    Host_MacAddress[8];    	// 호스트 MAC Address  [xx:xx:xx:xx:xx:xx] 
	// 6 바이트만 사용한다.
	uint32_t  Local_IP;              	// 보드   IP  = 0
	uint32_t  Host_IP;               	// 호스트 IP  = 0

	char    TFTP_Directory      [128]; // TFTP 디렉토리 명         디폴트 ""
	char    TFTP_zImageFileName [128]; // 커널 이미지      화일 명 디폴트 "zImage" 
	char    TFTP_RamDiskFileName[128]; // 램 디스크 이미지 화일 명 디폴트 "ramdisk.gz" 
	char    TFTP_LoaderFileName [128]; // 부트로더         화일 명 디폴트 "ezboot_x5" 

	uint32_t	SeriaNumber; 		// 사용할 시리얼 포트 번호  
	uint32_t  Kernel_ArchNumber;	// 커널에 전달될 커널 아키텍쳐 번호  디폴트 303

	TKernelCommandLine KCmd; 	// 커널 커맨드 

#if defined(CONFIG_TST_MLCC)
	TSRNVData	TopConfigure;
#endif

} __attribute__ ((packed))TMonConfig;


	BOOL LoadMonConfig( void );

	int Cfg_parse_args(char *cmdline, char **argv);
	uint8_t StrTouint8_t( char *ptr, int hex );

#ifdef __cplusplus
}
#endif

extern TMonConfig Cfg;
extern BOOL    LoadMonConfig( void );
extern void    SaveMonConfig( void );
//extern BOOL    LoadConfig( void );
//extern void    SaveConfig( void );
//extern int     ModifyCfg(int argc, char **argv);

#endif // _MONCFG_HEADER_







