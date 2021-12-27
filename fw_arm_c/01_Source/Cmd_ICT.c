#include	"Cmd_ICT.h"

u8 Cmd_ICT(trxData_t *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8	result = 1;
	u8	chkr;
	u16 argc = *pArgc;

	CMD_SerialTxOneTimeEnable();

	if(CMD_Compare(pArgv[1], "test"))
	{
	}
	else if(CMD_Compare(pArgv[1], "init"))
	{
		CMD_Printf(";INIT");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_Init();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "enable"))
	{
		CMD_Printf(";ENABLE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_Enable();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "disable"))
	{
		CMD_Printf(";DISABLE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_Disable();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "osmode"))
	{
		CMD_Printf(";OSMODE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_OpenShortMode();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "leakmode"))
	{
		CMD_Printf(";LEAKMODE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_LeakageMode();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "relaymode"))
	{
		u8 data;
		
		CMD_Printf(";RELAYMODE");

		if(argc != 3)		goto CMD_ICT_ERROR;

		data = CMD_StrToUL(pArgv[2]);

		chkr = ICT_RelayMode(data);

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "osselect"))
	{
		u8 data;
		
		CMD_Printf(";OSSELECT");

		if(argc != 3)		goto CMD_ICT_ERROR;

		data = CMD_StrToUL(pArgv[2]);

		chkr = ICT_OpenShortSelect(data);

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "leakselect"))
	{
		u8 data;
		
		CMD_Printf(";LEAKSELECT");

		if(argc != 3)		goto CMD_ICT_ERROR;

		data = CMD_StrToUL(pArgv[2]);

		chkr = ICT_LeakageSelect(data);

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "osvoltage"))
	{
		float voltage;
		
		CMD_Printf(";OSSELECT");

		if(argc != 3)		goto CMD_ICT_ERROR;

		voltage = CMD_AToF(pArgv[2]);

		chkr = ICT_OpenShortFVoltage(voltage);

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "leakvoltage"))
	{
		float voltage;
		
		CMD_Printf(";LEAKSELECT");

		if(argc != 3)		goto CMD_ICT_ERROR;

		voltage = CMD_AToF(pArgv[2]);

		chkr = ICT_LeakageFVoltage(voltage);

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "mode.enable"))
	{
		CMD_Printf(";MODE.ENABLE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_ModeEnable();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "mode.disable"))
	{
		CMD_Printf(";MODE.DISABLE");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_ModeDisable();

		if(chkr == 0)		goto CMD_ICT_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "read"))
	{
		float data[40];
		
		CMD_Printf(";READ");

		if(argc != 2)		goto CMD_ICT_ERROR;

		chkr = ICT_Read(data);

		if(chkr == 0)		goto CMD_ICT_ERROR;

		CMD_Printf(";");

		for(u8 cnt = 0; cnt < 40; cnt++)
		{
			CMD_Printf("ch%d=%1.2fV ", cnt, data[cnt]);
		}
	}
	else
	{
		CMD_ICT_ERROR:
		result = 0;
	}

	if(result)		CMD_Printf(";OK");
	else			CMD_Printf(";ERROR");
	
	return result;
}
