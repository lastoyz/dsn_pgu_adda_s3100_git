#ifndef	_APP_SYSTEM_H
#define	_APP_SYSTEM_H

#include 	"top_core_info.h"

typedef struct{
	u16	t_usb;
	u16	t_tcp;
	u8	f_usb;
	u8	f_tcp;
}sysTick_t;

typedef	union{
	u8	u8Data[256];
	__packed struct{
		u8	stx[2];			// "TE"
		u16	writeCnt;		// EEPROM Write Count
		u8	modelType[10];	// modelType ex: E7502-X000
		u8	serialNo[8];	// serialNo
		u8	buildDate[6];	// buildDate ex: 161216
		u32	secretCode;		// (Calculate CRC16 SerialNo) ^ (Calculate CRC16 buildDate)
		u8	hwType;
		u8	macAdrs[6];		// MAC
		u8	ipAdrs[4];		// IP
		u8	nmAdrs[4];		// Network Mask
		u8	gwAdrs[4];		// Gateway
		u8	ethEN;			// Ethernet Enable
		u8	userLogEnable;	// System Log Enable
		u8	dsiMode;		// MIPI DSI Mode(0=NONE, 1=SSD2829)
		u8	odPClk;
		u8	odBClk;
		u16	networkPort;
		u8	debugLogEnable;
		u8	mDrive;		// Main Driver No.
		u8	networkMode;	// Ethernet Mode(TCP/UDP)

		u8	unUse[194];

		u16	crc16;
	};
}sysConfig_t;

typedef	struct{
	u8	index;
	u8	sysConfig;
	u8	pwrBd;
	u8	ictBd;
#if 0
	u8	microSD;
#endif
	u8	nandFlash;
	u8	fpga;
}sysError_t;

typedef	struct{
	u32	enable;
	u32	sTime;
	u32	rTime;
}sysLock_t;

#define SYSTEM_CONFIG_ADRS		0x400

extern	sysTick_t	systemTick;
extern	sysConfig_t	sysConfig;
extern	sysError_t	sysError;
extern	sysLock_t	sysLock;

void System_ErrorInit();
void System_TickProcess();
void System_TickClear(u8 status);
void System_FlagClear(u8 status);
u16 System_CalculateCRC16(u8 *pData, u32 length);
void System_ConfigDefaultSet(sysConfig_t *pConfig);
u8 System_SysConfigRead(sysConfig_t *pConfig);
u8 System_SysConfigWrite(sysConfig_t *pConfig);
u8 System_SysConfigCheck(sysConfig_t *pConfig);
u8 System_ConfigRoutine();
void System_Lock();
void System_Release();
u32	System_LockCheck();

#endif	// _APP_SYSTEM_H
