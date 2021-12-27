#include	"App_Command.h"

//#define TRACE		Ext_Serial_Printf	// incompatible redefinition
//
extern u8 systemReset;

void eraseFlash()
{
	//  Disable prefetch memory
	__HAL_FLASH_PREFETCH_BUFFER_DISABLE();

	//  Flash 5 wait state.
	//  Check the Number of wait states according to CPU clock
	//  In my case, HCLK = 168MHz, Need FLASH_LATENCY_5
	if (FLASH_LATENCY_5 == __HAL_FLASH_GET_LATENCY())
		__HAL_FLASH_SET_LATENCY( FLASH_LATENCY_5 );

	//  Lock the memory to make sure to write the FLASH_OPT_KEYn in OPTKEYR
	HAL_FLASH_Lock();

	//  Clean all flags except FLASH_FLAG_BSY
	__HAL_FLASH_CLEAR_FLAG( FLASH_FLAG_EOP | FLASH_FLAG_OPERR | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR  );

	//  Write the FLASH_OPT_KEYn in OPTKEYR to access the memory
	HAL_FLASH_Unlock();

	//    Timeout of 500ms for the operation. Check if the FLASH_FLAG_BSY.
	FLASH_WaitForLastOperation( 500 );

	//    Write the Sector.
	//    STM32F40/41 have 11 sectors. 5 sectors of 16K, 1 x 64K, 7 x 128K
	//    Each STM32 has a different memory organisation
	//    The voltage range will selection the type to erase the memory
	//    FLASH_VOLTAGE_RANGE_3 erases by WORD
	FLASH_Erase_Sector(  FLASH_SECTOR_1,  FLASH_VOLTAGE_RANGE_3);

	FLASH_WaitForLastOperation( 500 );

	HAL_FLASH_Lock();
	//  The memory is erased from that point
}

extern UART_HandleTypeDef	h_Board_Serial;

int uart_state_index(int n) 
{ 
	switch(n)
	{
		case 0x00: return 0; 
		case 0x20: return 1;
		case 0x24: return 2;
		case 0x21: return 3;
		case 0x22: return 4;
		case 0x23: return 5;
		case 0xA0: return 6;
		case 0xE0: return 7;
		default  :;
	}
	return 7;
}


u16 cmdCnt;
u8 *cmdData[CMD_MAX_COUNT];

trxData_t		trxData;
trxData_t		trxBinData;
u8				*cmdRxData = (u8*)SDRAM_CMD_RX_BUFFER_ADRS;

cmdWaitTime_t	cmdWaitTime;

u8				cmdSerialTxEnable;

cmdSerialTx_t	cmdSerialTx;


void CMD_RcvCheck()
{
	Network_PacketProcess();

	Serial_CommandProcess();

	if (h_Board_Serial.RxState == 0xE0) {
		HAL_UART_DeInit(&h_Board_Serial);
	}

	if(serialRxFlag)
	{
		trxData.received = 1;
		trxData.rxSource = CMD_TYPE_SERIAL;
		trxData.rxLength = serialRxCnt;
	}
	else if(networkRxFlag)
	{
		trxData.received = 1;
		trxData.rxSource = CMD_TYPE_ETHERNET;
		trxData.rxLength = networkRxCnt;
	}
}

void CMD_SerialTxInit()
{
	//	cmdSerialTx.enable = GPIO_TestSwitchRead();

	cmdSerialTx.enable = 1;

	cmdSerialTx.oneTime = 0;
}

void CMD_SerialTxOneTimeEnable()
{
	cmdSerialTx.oneTime = 1;
}

void CMD_Init()
{
	u32	size 							= 128 * 1024;
	systemReset							= 0;

	trxData.received					= 0;
	trxData.txSource					= 0;
	trxData.rxSource					= 0;
	trxData.txLength					= 0;
	trxData.rxLength					= 0;
	trxData.txCount						= 0;
	trxData.txData						= (u8*)SDRAM_CMD_TX_BUFFER_ADRS;
	trxData.rxData[CMD_TYPE_ETHERNET]	= networkRxData;
	trxData.rxData[CMD_TYPE_SERIAL]		= serialRxData;

	//	memset(usbRxData,		NULL,	size);
	memset(networkRxData,	NULL,	size);
	memset(serialRxData,	NULL,	size);

	cmdWaitTime.enable = 0;

	CMD_SerialTxInit();
}

u8 CMD_Parsing(u8 *rcvData, u16 *pArgc, u8 **pArgv)
{
	u8	result = 0;
	u8	*token, *pData;
	u32	length;

	*pArgc = NULL;

	token = (u8*)strtok((char*)rcvData, CMD_DELIMITER_1);

	do{
		if(token == NULL)	break;

		length = strlen((char*)token);

		length++;

		pArgv[*pArgc] = token;
		(*pArgc)++;

		if(token[length] == ' ')
		{
			token[length] = 0;
			length++;
		}

		pData = &token[length];

		if(token[length] == '"')
		{
			token = (u8*)strtok((char*)pData, CMD_DELIMITER_5);
		}
		else
		{
			token = (u8*)strtok((char*)pData, CMD_DELIMITER_2);
		}

		if(*pArgc > CMD_MAX_COUNT)	break;
	}while(token != NULL);

	if(*pArgc > NULL)	result = 1;

	return result;
}

void CMD_Strlwr(u8 *pData)
{
	u32 cnt = 0;

	do{
		if(pData[cnt] == 0)		break;

		if(pData[cnt] < 'A')
		{
			cnt++;
			continue;
		}
		if(pData[cnt] > 'Z')
		{
			cnt++;
			continue;
		}

		pData[cnt] += 0x20;

		cnt++;
	}while(1);
}

u8 CMD_Compare(u8 *s1Data, const char *s2Data)
{
	u8	result = 0;

	//CMD_Strlwr(s1Data);			// A -> a

	if(strcmp((char*)s1Data, s2Data) == NULL)
	{
		result = 1;
	}

	return result;
}

u8 CMD_CompareByte(char *s1Data, const char *s2Data)
{
	u8 result = 0;

	if(memcmp(s1Data, s2Data, strlen(s2Data)) == NULL)
	{
		result = 1;
	}
	
	return result;
}

u32 CMD_StrToUL(u8 *pData)
{
	return strtoul((char*)pData, NULL, NULL);
}

double CMD_AToF(u8 *pData)
{
	return atof((char*)pData);
}

void CMD_SerialTxEnable()
{
	cmdSerialTxEnable = 1;
}

void CMD_SerialTxDisable()
{
	cmdSerialTxEnable = 0;
}

u8 CMD_Analysis(trxData_t *pTrxData)
{
	u8 result = 0;
	u32	commentCheck;
	u32	size;

	switch(pTrxData->rxSource)
	{
		case CMD_TYPE_ETHERNET:
			pTrxData->rxData[CMD_TYPE_ETHERNET][pTrxData->rxLength] = 0;

			commentCheck = (u32)strstr((char*)pTrxData->rxData[CMD_TYPE_ETHERNET], "#");

			if(commentCheck != NULL)
			{
				size = commentCheck - (u32)(pTrxData->rxData[CMD_TYPE_ETHERNET]);
				memcpy(cmdRxData, pTrxData->rxData[CMD_TYPE_ETHERNET], size);

				memset(&cmdRxData[size], NULL, 32);
			}
			else
			{
				memcpy(cmdRxData, pTrxData->rxData[CMD_TYPE_ETHERNET], pTrxData->rxLength);

				memset(&cmdRxData[pTrxData->rxLength], NULL, 32);
			}

			result = CMD_Parsing(cmdRxData, &cmdCnt, cmdData);

			// Rcv Start

			Network_RxRecover(0x03);
			break;

		case CMD_TYPE_SERIAL:
			pTrxData->rxData[CMD_TYPE_SERIAL][pTrxData->rxLength] = 0;

			commentCheck = (u32)strstr((char*)pTrxData->rxData[CMD_TYPE_SERIAL], "#");

			if(commentCheck != NULL)
			{
				size = commentCheck - (u32)(pTrxData->rxData[CMD_TYPE_SERIAL]);
				memcpy(cmdRxData, pTrxData->rxData[CMD_TYPE_SERIAL], size);

				memset(&cmdRxData[size], NULL, 32);
			}
			else
			{
				memcpy(cmdRxData, pTrxData->rxData[CMD_TYPE_SERIAL], pTrxData->rxLength);

				memset(&cmdRxData[pTrxData->rxLength], NULL, 32);
			}

			result = CMD_Parsing(cmdRxData, &cmdCnt, cmdData);

			// Rcv Start

			Serial_RxRecover();

			CMD_SerialTxInit();
			break;
	}

	pTrxData->txSource = pTrxData->rxSource;

	pTrxData->rxSource = 0;

	memset(pTrxData->txData, NULL, (pTrxData->txLength + 16));

	pTrxData->txLength = 0;

	pTrxData->txCount = 0;

	return result;
}

void CMD_TransmitWaitTime(u16 data)
{
	cmdWaitTime.sTime	= HAL_GetTick();
	cmdWaitTime.setTime	= 0;
	cmdWaitTime.enable	= 0;

	if(trxData.txSource == CMD_TYPE_ETHERNET)
	{
		Network_WaitTimeSend(data);

		cmdWaitTime.enable = 1;

		cmdWaitTime.sTime = HAL_GetTick();

		cmdWaitTime.setTime = data;
	}
}

u8 CMD_WaitTimeDelay()
{
	u8	result = 0, rtn;
	u8	state = 0;

	if(trxData.txSource == CMD_TYPE_ETHERNET)
	{
		if(cmdWaitTime.enable)
		{
			do{
				cmdWaitTime.rTime = HAL_GetTick();

				if((cmdWaitTime.rTime - cmdWaitTime.sTime) > cmdWaitTime.setTime)
				{
					break;
				}
			}while(1);

			rtn = Network_ReceiveAck(&state);

			if(rtn)
			{
				result = 1;
			}
		}
		else
		{
			result = 1;
		}
	}
	else
	{
		result = 1;
	}

	cmdWaitTime.enable = 0;

	return result;
}

void CMD_TransmitAck(trxData_t *pTrxData)
{
switch(pTrxData->txSource)
	{
		case CMD_TYPE_ETHERNET:
			Network_TransmitPacket(pTrxData->txData, pTrxData->txLength);
			break;

		case CMD_TYPE_SERIAL:
			if((cmdSerialTx.enable) || (cmdSerialTx.oneTime))
			{
				Serial_TxData(pTrxData->txData, pTrxData->txLength);
			}
			break;
	}

}

void CMD_BinTransmitAck(trxData_t *pTrxData)
{
	switch(pTrxData->txSource)
	{
		case CMD_TYPE_ETHERNET:
			Network_TransmitPacket(pTrxData->txData, pTrxData->txLength);
			break;

		case CMD_TYPE_SERIAL:
			if((cmdSerialTx.enable) || (cmdSerialTx.oneTime))
			{
				Serial_TxData(pTrxData->txData, pTrxData->txLength);
			}
			break;
	}

}

void CMD_Printf(const char *pData, ...)
{
	u32	length;

	va_list	ap;

	trxData_t *pTrxData = &trxData;

	u8 *pStartData = &(pTrxData->txData[pTrxData->txLength]);

	va_start(ap, pData);

	length = vsprintf((char*)pStartData, pData, ap);

	pTrxData->txLength += length;		//strlen((char*)pStartData);

	va_end(ap);
}

void CMD_TxData(u8 *pData, u32 length)
{
	trxData_t *pTrxData = &trxData;

	u8 *pStartData = &(pTrxData->txData[pTrxData->txLength]);

	memcpy(pStartData, pData, length);

	pTrxData->txLength += length;
}

u8 CMD_Process(trxData_t *pTrxData)
{
	u8 result = 0;
	u8 cmdCheck;
	u16 *pArgc	= &cmdCnt;
	u8 **pArgv	= cmdData;


	// transfer binary
	trxBinData.txLength = 0;
	// 1. Data Check
	if((pTrxData->received == 0x00) || (pTrxData->rxLength == 0))
	{
		return result;
	}

	// 2. Data Analysis

	cmdCheck = CMD_Analysis(pTrxData);

	pTrxData->received = 0x00;

	if(cmdCheck == 0)
	{
		return result;
	}

	GPIO_LedCtrl(0, LED_ON);
	GPIO_LedCtrl(1, LED_ON);

	// 3. Data Compare & Execute
	if(CMD_Compare(pArgv[0], "system"))
	{
		CMD_Printf(">>SYSTEM");

		result = Cmd_System(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "file"))
	{
		CMD_Printf(">>FILE");

		result = Cmd_File(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "mlcc"))
	{
		CMD_Printf(">>MLCC");

		result = Cmd_MlccTest(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "gpio"))
	{
		CMD_Printf(">>GPIO");

		result = Cmd_Gpio(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "fpga"))
	{
		CMD_Printf(">>FPGA");

		result = Cmd_FPGA(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "power"))
	{
		CMD_Printf(">>POWER");

		result = Cmd_Power(pTrxData, pArgc, pArgv);
	}
#if 0
	else if(CMD_Compare(pArgv[0], "log"))
	{
		CMD_Printf(">>LOG");

		result = Cmd_Log(pTrxData, pArgc, pArgv);
	}
#endif
	else if(CMD_Compare(pArgv[0], "ict"))
	{
		CMD_Printf(">>ICT");

		result = Cmd_ICT(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "test"))
	{
		CMD_Printf(">>TEST");

		result = Cmd_BoardTest(pTrxData, pArgc, pArgv);
	}
	else if(CMD_Compare(pArgv[0], "delay"))
	{
		u32 cnt;

		CMD_Printf(">>DELAY");

		if(*pArgc != 2)		goto CMD_ERROR;

		cnt = CMD_StrToUL(pArgv[1]);

		HAL_Delay(cnt);

		result = 1;

		CMD_Printf(";OK");
	}
	else if(CMD_Compare(pArgv[0], "flashe"))
	{
		CMD_Printf(">>FLASH.ERASE");

		if(*pArgc != 1)		goto CMD_ERROR;

		EraseFlash();

		CMD_Printf(";OK");
	}
	else if(CMD_Compare(pArgv[0], "flashw"))
	{
		u32 data;

		CMD_Printf(">>FLASH.WRITE");

		if(*pArgc != 2)		goto CMD_ERROR;

		data = CMD_StrToUL(pArgv[1]);
		CMD_Printf(";0x%08x",data);

		if (data > 0) 
			WriteFlash(data);
		else
			WriteFlashFW();


		CMD_Printf(";OK");
	}
	else if(CMD_Compare(pArgv[0], "getbin"))
	{
		u32 cnt;
		CMD_Printf(">>GETBIN");

		if(*pArgc != 2)		goto CMD_ERROR;

		cnt = CMD_StrToUL(pArgv[1]);
		CMD_Printf(";SIZE:%d",cnt * 4);

		trxBinData.txSource = pTrxData->txSource;
		trxBinData.txData = (u8*)DOWNLOAD_TX_RAM_ADDR;
		trxBinData.txLength = cnt * 4;

		CMD_Printf(";OK");
	}
	else if(CMD_Compare(pArgv[0], "netinit"))
	{
		CMD_Printf(">>NET.INIT");

		if(*pArgc != 1)		goto CMD_ERROR;

		Network_Init();
		
		CMD_Printf(";OK");
	}
	else if(CMD_Compare(pArgv[0], "netswap"))
	{
		u32 param;
		u16 val;
		CMD_Printf(">>NETSWAP");

		if(*pArgc != 2)		goto CMD_ERROR;

		param = CMD_StrToUL(pArgv[1]);
		if (param == 0) {
			setMR(getMR()|MR_FS); // If Little-endian, set MR_FS.
			val = getMR();
			TRACE("endian : 0x%08x \r\n", val);
			if (val & MR_FS) TRACE(" Endian : (no-swamp)  \r\n");
			else 		TRACE(" Endian : swap \r\n");
		} else if (param == 1) {
		} else {
			setMR(getMR() & ~MR_FS); // If Little-endian, set MR_FS.
			val = getMR();
			TRACE("endican : 0x%08x \r\n", val);
			if (val & MR_FS) TRACE(" Endian : (no-swamp)  \r\n");
			else 		TRACE(" Endian : swap \r\n");
		}

		
		CMD_Printf(";OK");
	}
	else
	{
CMD_ERROR:
		CMD_Printf(">>ERROR");
	}


	CMD_Printf("\r\n");

	CMD_WaitTimeDelay();

	CMD_TransmitAck(pTrxData);
	CMD_BinTransmitAck(&trxBinData);

	if(systemReset)
	{
		HAL_Delay(1000);
		NVIC_SystemReset();
	}

	GPIO_LedCtrl(1, LED_OFF);
	if(result == 0)
	{
		// smkim : to be defined...
		GPIO_LedCtrl(0, LED_OFF);
		GPIO_LedCtrl(1, LED_ON);
	}

	return result;
}

