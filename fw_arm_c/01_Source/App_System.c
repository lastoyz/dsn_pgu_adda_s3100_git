#include	"App_System.h"

sysTick_t	systemTick;
sysConfig_t	sysConfig;
sysError_t	sysError;
sysLock_t	sysLock;

void System_ErrorInit()
{
	memset(&sysError, NULL, sizeof(sysError));
}

void System_TickProcess()
{
	if(systemTick.t_usb < 1000)		systemTick.t_usb++;
	else							systemTick.f_usb = 1;

	if(systemTick.t_tcp < 1000)		systemTick.t_tcp++;
	else							systemTick.f_tcp = 1;

	if(sysLock.enable)
	{
		sysLock.rTime = HAL_GetTick();

		if((sysLock.rTime - sysLock.sTime) > 60000)
		{
			sysLock.enable = 0;
		}
	}

	serialRCV.time++;
}

void System_TickClear(u8 status)
{
	switch(status)
	{
		case 0:
			systemTick.t_usb = 0;
			break;

		case 1:
			systemTick.t_tcp = 0;
			break;

		default:
			break;
	}
}

void System_FlagClear(u8 status)
{
	switch(status)
	{
		case 0:
			systemTick.t_usb = 0;
			systemTick.f_usb = 0;
			break;

		case 1:
			systemTick.t_tcp = 0;
			systemTick.f_tcp = 0;
			break;

		default:
			break;
	}
}


u16 System_CalculateCRC16(u8 *pData, u32 length)
{
	u8	bitCnt, cData;
	u16 result = 0xffff;
	u32 byteCnt;

	if(length > 0)
	{
		for(byteCnt = 0; byteCnt < length; byteCnt++)
		{
			cData = pData[byteCnt];

			for(bitCnt = 0; bitCnt < 8; bitCnt++)
			{
				if(((result & 0x0001) ^ ((0x0001 * cData) & 0x0001)) > 0)
				{
					result = ((result >> 1) & 0x7fff) ^ 0x8408;
				}
				else
				{
					result = (result >> 1) & 0x7fff;
				}
				cData = (cData >> 1) & 0x7f;
			}
		}
	}

	return result;
}

void System_SysConfigAddCRC16(sysConfig_t *pConfig)
{
	pConfig->crc16 = System_CalculateCRC16(pConfig->u8Data, sizeof(sysConfig_t)-2);
}

u16 System_SysConfigCheckCRC16(sysConfig_t *pConfig)
{
	return System_CalculateCRC16(pConfig->u8Data, sizeof(sysConfig_t)-2);
}

void System_ConfigDefaultSet(sysConfig_t *pConfig)
{
	u16 cnt;
	u16	secretCode[2];

	for(cnt = 0; cnt < sizeof(sysConfig_t); cnt++)
	{
		pConfig->u8Data[cnt] = 0;
	}

	pConfig->stx[0]			= 'T';
	pConfig->stx[1]			= 'E';

	pConfig->writeCnt		= 0;

	pConfig->modelType[0]	= 'E';
	pConfig->modelType[1]	= '7';
	pConfig->modelType[2]	= '5';
	pConfig->modelType[3]	= '0';
	pConfig->modelType[4]	= '2';
	pConfig->modelType[5]	= '-';
	pConfig->modelType[6]	= 'X';
	pConfig->modelType[7]	= '0';
	pConfig->modelType[8]	= '0';
	pConfig->modelType[9]	= '0';

	pConfig->serialNo[0]	= 'N';
	pConfig->serialNo[1]	= 'O';
	pConfig->serialNo[2]	= 'S';
	pConfig->serialNo[3]	= 'E';
	pConfig->serialNo[4]	= 'R';
	pConfig->serialNo[5]	= 'I';
	pConfig->serialNo[6]	= 'A';
	pConfig->serialNo[7]	= 'L';

	secretCode[0]			= System_CalculateCRC16(pConfig->serialNo, 8);

	pConfig->buildDate[0]	= 'N';
	pConfig->buildDate[1]	= 'O';
	pConfig->buildDate[2]	= 'D';
	pConfig->buildDate[3]	= 'A';
	pConfig->buildDate[4]	= 'T';
	pConfig->buildDate[5]	= 'E';

	secretCode[1]			= System_CalculateCRC16(pConfig->buildDate, 6);

	pConfig->secretCode		= secretCode[0];

	pConfig->secretCode		<<= 16;

	pConfig->secretCode 	|= secretCode[1];

	pConfig->hwType			= 0x01;			// bit0 : pwrBd, bit1 : ictBd
/*
	pConfig->macAdrs[0]		= 0x12;
	pConfig->macAdrs[1]		= 0x34;
	pConfig->macAdrs[2]		= 0x56;
	pConfig->macAdrs[3]		= 0x78;
	pConfig->macAdrs[4]		= 0x9a;
	pConfig->macAdrs[5]		= 0xbc;
*/
	pConfig->ipAdrs[0]		= 192;
	pConfig->ipAdrs[1]		= 168;
	pConfig->ipAdrs[2]		= 100;
	pConfig->ipAdrs[3]		= 51;

	pConfig->nmAdrs[0]		= 255;
	pConfig->nmAdrs[1]		= 255;
	pConfig->nmAdrs[2]		= 255;
	pConfig->nmAdrs[3]		= 0;

	pConfig->gwAdrs[0]		= 192;
	pConfig->gwAdrs[1]		= 168;
	pConfig->gwAdrs[2]		= 100;
	pConfig->gwAdrs[3]		= 255;

	pConfig->userLogEnable	= 0;

	pConfig->dsiMode		= 0;

	pConfig->odPClk			= 6;
	pConfig->odBClk			= 6;

	pConfig->networkPort		= 8999;

	pConfig->debugLogEnable	= 0;

	pConfig->mDrive			= 0;		// Default NAND Flash

	pConfig->networkMode	= 0;		// Ethernet Mode : TCP(default)

	System_SysConfigAddCRC16(pConfig);
}

u8 System_SysConfigRead(sysConfig_t *pConfig)
{
	EEP_Read(SYSTEM_CONFIG_ADRS, pConfig->u8Data, sizeof(sysConfig_t));

	return 1;
}

u8 System_SysConfigWrite(sysConfig_t *pConfig)
{
	u8	macAdrs[6];
	u16 secretCode[2];

	memset(macAdrs, NULL, sizeof(macAdrs));

	secretCode[0] = System_CalculateCRC16(pConfig->serialNo, 8);
	secretCode[1] = System_CalculateCRC16(pConfig->buildDate, 6);

	macAdrs[0] = 0xe7;
	macAdrs[1] = 0x50;
	macAdrs[2] = 0x20;
	macAdrs[3] = ((pConfig->serialNo[2] & 0x0f) << 4) | (pConfig->serialNo[3] & 0x0f);
	macAdrs[4] = ((pConfig->serialNo[4] & 0x0f) << 4) | (pConfig->serialNo[5] & 0x0f);
	macAdrs[5] = ((pConfig->serialNo[6] & 0x0f) << 4) | (pConfig->serialNo[7] & 0x0f);

	memcpy(pConfig->macAdrs, macAdrs, 6);
	
	pConfig->secretCode = secretCode[0];

	pConfig->secretCode <<= 16;

	pConfig->secretCode |= secretCode[1];

	pConfig->writeCnt += 1;

	pConfig->crc16 = System_CalculateCRC16(pConfig->u8Data, sizeof(sysConfig_t)-2);

	EEP_Write(SYSTEM_CONFIG_ADRS, pConfig->u8Data, sizeof(sysConfig_t));

	return 1;
}

u8 System_SysConfigCheck(sysConfig_t *pConfig)
{
	u8 result = 0;

	if(((pConfig->stx[0] == 'T') && (pConfig->stx[1] == 'E')) &&
		(pConfig->crc16 == System_SysConfigCheckCRC16(pConfig)))
	{
		result = 1;
	}

	return result;
}

u8 System_ConfigRoutine()
{
	u8 result = 0;

	System_ConfigDefaultSet(&sysConfig);

	result = System_SysConfigCheck(&sysConfig);

	return result;
}

void System_Lock()
{
	sysLock.enable = 0;
}

void System_Release()
{
	sysLock.sTime = HAL_GetTick();

	sysLock.enable = 1;
}

u32	System_LockCheck()
{
	return sysLock.enable;
}

