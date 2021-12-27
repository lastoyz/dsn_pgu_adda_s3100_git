#ifndef	_APP_ICT_H
#define	_APP_ICT_H

#include	"top_core_info.h"

enum{
	SB_ICT_CMD_ERROR					= 0x0000,
	SB_ICT_CMD_TEST						= 0x0001,
	SB_ICT_CMD_VERSION					= 0x0002,
	SB_ICT_CMD_INIT						= 0x0003,

	SB_ICT_CMD_ICT_ENABLE				= 0x0010,
	SB_ICT_CMD_ICT_DISABLE				= 0x0011,
	SB_ICT_CMD_OPENSHORT_MODE			= 0x0012,
	SB_ICT_CMD_LEAKAGE_MODE				= 0x0013,
	SB_ICT_CMD_RELAY_MODE				= 0x0014,
	SB_ICT_CMD_OPENSHORT_IO_SELECT		= 0x0015,
	SB_ICT_CMD_LEAKAGE_IO_SELECT		= 0x0016,
	SB_ICT_CMD_OPENSHORT_FVOLTAGE		= 0x0017,
	SB_ICT_CMD_LEAKAGE_FVOLTAGE			= 0x0018,

	SB_ICT_CMD_ENABLE					= 0x0020,
	SB_ICT_CMD_DISABLE					= 0x0021,
	SB_ICT_CMD_READ						= 0x0022
};

u8 ICT_Init();
u8 ICT_Enable();
u8 ICT_Disable();
u8 ICT_OpenShortMode();
u8 ICT_LeakageMode();
u8 ICT_RelayMode(u8 data);
u8 ICT_OpenShortSelect(u8 data);
u8 ICT_LeakageSelect(u8 data);
u8 ICT_OpenShortFVoltage(float voltage);
u8 ICT_LeakageFVoltage(float voltage);
u8 ICT_ModeEnable();
u8 ICT_ModeDisable();
u8 ICT_Read(float *pData);

#endif	// _APP_ICT_H