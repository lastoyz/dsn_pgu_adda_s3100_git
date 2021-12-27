#include	"Cmd_Gpio.h"

u8 Cmd_Gpio(void *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8	result = 1;
	u16	argc = *pArgc;

	if(CMD_Compare(pArgv[1], "init"))
	{
		CMD_Printf(";INIT");

//		if(argc != 2)		goto CMD_GPIO_ERROR;

//		LCM_GpioInit();
	}
#if 0			// not used : smkim
	else if(CMD_Compare(pArgv[1], "dir"))
	{
		bitCtrl8_t bitData;
		
		CMD_Printf(";DIR");

		if(argc != 3)		goto CMD_GPIO_ERROR;
		
		bitData.u8Data = CMD_StrToUL(pArgv[2]);

		if(bitData.b0)	LCM_GpioDir(0, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(0, LCM_GPIO_MODE_INPUT);

		if(bitData.b1)	LCM_GpioDir(1, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(1, LCM_GPIO_MODE_INPUT);

		if(bitData.b2)	LCM_GpioDir(2, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(2, LCM_GPIO_MODE_INPUT);

		if(bitData.b3)	LCM_GpioDir(3, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(3, LCM_GPIO_MODE_INPUT);

		if(bitData.b4)	LCM_GpioDir(4, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(4, LCM_GPIO_MODE_INPUT);

		if(bitData.b5)	LCM_GpioDir(5, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(5, LCM_GPIO_MODE_INPUT);

		if(bitData.b6)	LCM_GpioDir(6, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(6, LCM_GPIO_MODE_INPUT);

		if(bitData.b7)	LCM_GpioDir(7, LCM_GPIO_MODE_OUTPUT);
		else			LCM_GpioDir(7, LCM_GPIO_MODE_INPUT);
	}
	else if(CMD_Compare(pArgv[1], "write"))
	{
		bitCtrl8_t bitData;
		
		CMD_Printf(";WRITE");

		if(argc != 3)		goto CMD_GPIO_ERROR;

		bitData.u8Data = CMD_StrToUL(pArgv[2]);

		LCM_GpioOut(0, bitData.b0);
		LCM_GpioOut(1, bitData.b1);
		LCM_GpioOut(2, bitData.b2);
		LCM_GpioOut(3, bitData.b3);
		LCM_GpioOut(4, bitData.b4);
		LCM_GpioOut(5, bitData.b5);
		LCM_GpioOut(6, bitData.b6);
		LCM_GpioOut(7, bitData.b7);
	}
	else if(CMD_Compare(pArgv[1], "read"))
	{
		bitCtrl8_t bitData;
		u8 rData;

		bitData.u8Data = 0;
			
		CMD_Printf(";READ");

		if(argc != 2)		goto CMD_GPIO_ERROR;

		rData = LCM_GpioIn(0);
		if(rData != 0xff)	bitData.b0 = rData;

		rData = LCM_GpioIn(1);
		if(rData != 0xff)	bitData.b1 = rData;

		rData = LCM_GpioIn(2);
		if(rData != 0xff)	bitData.b2 = rData;

		rData = LCM_GpioIn(3);
		if(rData != 0xff)	bitData.b3 = rData;

		rData = LCM_GpioIn(4);
		if(rData != 0xff)	bitData.b4 = rData;

		rData = LCM_GpioIn(5);
		if(rData != 0xff)	bitData.b5 = rData;

		rData = LCM_GpioIn(6);
		if(rData != 0xff)	bitData.b6 = rData;

		rData = LCM_GpioIn(7);
		if(rData != 0xff)	bitData.b7 = rData;

		CMD_Printf(";0x%02x", bitData.u8Data);

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "set"))
	{
		bitCtrl8_t bitData;
		
		CMD_Printf(";SET");

		if(argc != 3)	goto CMD_GPIO_ERROR;

		bitData.u8Data = CMD_StrToUL(pArgv[2]);

		if(bitData.b0)	LCM_GpioOut(0, HIGH);
		if(bitData.b1)	LCM_GpioOut(1, HIGH);
		if(bitData.b2)	LCM_GpioOut(2, HIGH);
		if(bitData.b3)	LCM_GpioOut(3, HIGH);
		if(bitData.b4)	LCM_GpioOut(4, HIGH);
		if(bitData.b5)	LCM_GpioOut(5, HIGH);
		if(bitData.b6)	LCM_GpioOut(6, HIGH);
		if(bitData.b7)	LCM_GpioOut(7, HIGH);
	}
	else if(CMD_Compare(pArgv[1], "clear") || CMD_Compare(pArgv[1], "clr"))
	{
		bitCtrl8_t bitData;
		
		CMD_Printf(";CLEAR");

		if(argc != 3)	goto CMD_GPIO_ERROR;

		bitData.u8Data = CMD_StrToUL(pArgv[2]);

		if(bitData.b0)	LCM_GpioOut(0, LOW);
		if(bitData.b1)	LCM_GpioOut(1, LOW);
		if(bitData.b2)	LCM_GpioOut(2, LOW);
		if(bitData.b3)	LCM_GpioOut(3, LOW);
		if(bitData.b4)	LCM_GpioOut(4, LOW);
		if(bitData.b5)	LCM_GpioOut(5, LOW);
		if(bitData.b6)	LCM_GpioOut(6, LOW);
		if(bitData.b7)	LCM_GpioOut(7, LOW);
	}
	else if(CMD_Compare(pArgv[1], "script.enable"))
	{
		CMD_Printf(";SCRIPT.ENABLE");

		if(argc != 2)	goto CMD_GPIO_ERROR;

		LCM_GpioMode(6, LCM_GPIO_MODE_SCRIPT);
		LCM_GpioMode(7, LCM_GPIO_MODE_SCRIPT);
	}
	else if(CMD_Compare(pArgv[1], "script.disable"))
	{
		CMD_Printf(";SCRIPT.DISABLE");

		if(argc != 2)	goto CMD_GPIO_ERROR;

		if(lcmGpioDir[6] == IO_INPUT)	LCM_GpioMode(6, LCM_GPIO_MODE_INPUT);
		else							LCM_GpioMode(6, LCM_GPIO_MODE_OUTPUT);

		if(lcmGpioDir[7] == IO_INPUT)	LCM_GpioMode(7, LCM_GPIO_MODE_INPUT);
		else							LCM_GpioMode(7, LCM_GPIO_MODE_OUTPUT);
	}
	else if(CMD_Compare(pArgv[1], "int.enable"))
	{
		u8 pos, edge, key;

		CMD_Printf(";INT.ENABLE");

		// gpio.int.enable [gpioN] [edge] [keyNO]

		if(argc != 5)	goto CMD_GPIO_ERROR;

		// GPIONO
		if(CMD_Compare(pArgv[2], "gpio0"))			pos = 0;
		else if(CMD_Compare(pArgv[2], "gpio1"))		pos = 1;
		else if(CMD_Compare(pArgv[2], "gpio2"))		pos = 2;
		else if(CMD_Compare(pArgv[2], "gpio3"))		pos = 3;
		else if(CMD_Compare(pArgv[2], "gpio4"))		pos = 4;
		else if(CMD_Compare(pArgv[2], "gpio5"))		pos = 5;
		else if(CMD_Compare(pArgv[2], "gpio6"))		pos = 6;
		else if(CMD_Compare(pArgv[2], "gpio7"))		pos = 7;
		else			goto CMD_GPIO_ERROR;

		if(pos < 4)		goto CMD_GPIO_ERROR;

		// EDGE
		if(CMD_Compare(pArgv[3], "rising"))			edge = LCM_GPIO_MODE_INT_RISING;
		else if(CMD_Compare(pArgv[3], "falling"))	edge = LCM_GPIO_MODE_INT_FALLING;
		else			goto CMD_GPIO_ERROR;

		if(CMD_Compare(pArgv[4], "key1"))			key = 0;
		else if(CMD_Compare(pArgv[4], "key2"))		key = 1;
		else if(CMD_Compare(pArgv[4], "key3"))		key = 2;
		else if(CMD_Compare(pArgv[4], "key4"))		key = 3;
		else if(CMD_Compare(pArgv[4], "key5"))		key = 4;
		else if(CMD_Compare(pArgv[4], "key6"))		key = 5;
		else if(CMD_Compare(pArgv[4], "key7"))		key = 6;
		else if(CMD_Compare(pArgv[4], "key8"))		key = 7;
		else			goto CMD_GPIO_ERROR;

		LCM_GpioMode(pos, edge);
		LCM_GpioKeyMap(pos, key);
	}
	else if(CMD_Compare(pArgv[1], "int.disable"))
	{
		u8 pos;

		CMD_Printf(";INT.DISABLE");

		// gpio.int.disable [gpioN]

		if(argc != 3)	goto CMD_GPIO_ERROR;

		// GPIONO
		if(CMD_Compare(pArgv[2], "gpio0"))			pos = 0;
		else if(CMD_Compare(pArgv[2], "gpio1"))		pos = 1;
		else if(CMD_Compare(pArgv[2], "gpio2"))		pos = 2;
		else if(CMD_Compare(pArgv[2], "gpio3"))		pos = 3;
		else if(CMD_Compare(pArgv[2], "gpio4"))		pos = 4;
		else if(CMD_Compare(pArgv[2], "gpio5"))		pos = 5;
		else if(CMD_Compare(pArgv[2], "gpio6"))		pos = 6;
		else if(CMD_Compare(pArgv[2], "gpio7"))		pos = 7;
		else			goto CMD_GPIO_ERROR;

		if(pos < 4)		goto CMD_GPIO_ERROR;

		if(lcmGpioDir[pos] == IO_INPUT)		LCM_GpioMode(pos, LCM_GPIO_MODE_INPUT);
		else								LCM_GpioMode(pos, LCM_GPIO_MODE_OUTPUT);

		LCM_GpioKeyMap(pos, 0xff);
	}
	else if(CMD_Compare(pArgv[1], "1wire.pulse"))
	{
		u8	rtn;
		u8	pos, pulseCnt;

		CMD_Printf("1WIRE.PULSE");

		if(argc != 4)		goto CMD_GPIO_ERROR;

		pos			= CMD_StrToUL(pArgv[2]);
		pulseCnt	= CMD_StrToUL(pArgv[3]);

		rtn = LCM_Gpio1WirePulseCtrl(pos, pulseCnt);

		if(rtn == 0)		goto CMD_GPIO_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "1wire.timing"))
	{
		u8	rtn;
		u32	lowDelay, highDelay, storeDelay;

		CMD_Printf("1WIRE.TIMING");

		if(argc != 5)		goto CMD_GPIO_ERROR;

		lowDelay	= CMD_StrToUL(pArgv[2]);
		highDelay	= CMD_StrToUL(pArgv[3]);
		storeDelay	= CMD_StrToUL(pArgv[4]);

		rtn = LCM_1WirePulseTiming(lowDelay, highDelay, storeDelay);

		if(rtn == 0)		goto CMD_GPIO_ERROR;
	}
	else
	{
		CMD_GPIO_ERROR:
		result = 0;
	}
#endif			// not used : smkim

	if(result)	CMD_Printf(";OK");
	else		CMD_Printf(";ERROR");

	return result;
}
