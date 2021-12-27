#include	"Cmd_File.h"

uint32_t App_FWSize = 0;
uint8_t* App_FWAddr = (u8p)SDRAM_FPGA_READ_ADRS;

u8 Cmd_File(trxData_t *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8 result = 1;
	u16 argc = *pArgc;

	CMD_SerialTxOneTimeEnable();

	if(CMD_Compare(pArgv[1], "check"))
	{
		CMD_Printf(";CHECK");

		if(argc != 3)	goto CMD_FILE_ERROR;

		if(CMD_Compare(pArgv[2], "nand"))
		{
			if(sysError.nandFlash == 1)		CMD_Printf(";NAND_ERROR");
			else							CMD_Printf(";NAND_OK");
		}
		else			goto CMD_FILE_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "save"))
	{
		u8	rtn;
		u32	rxSrc;
		u32	indexNo, fileSize, rcvSize;
		u8	*pFileName;
		u8	*pFileType;
		u8	*pFileData;
		u16	hPixel, vLine;
		u16	waitTime;
		
		// 2.fileType 3.size 4.indexNo 5.fileName

		CMD_Printf(";SAVE");

		rxSrc = pTrxData->txSource;

		if((rxSrc != CMD_TYPE_ETHERNET))		goto CMD_FILE_ERROR;
		if((argc != 6) && (argc != 9))									goto CMD_FILE_ERROR;

		pFileType	= pArgv[2];
		fileSize	= CMD_StrToUL(pArgv[3]);
		indexNo		= CMD_StrToUL(pArgv[4]);
		pFileName	= pArgv[5];

		if(indexNo == 0)	goto CMD_FILE_ERROR;

		indexNo -= 1;

		waitTime = fileSize / 5000;

		if(CMD_Compare(pFileType, "key"))
		{
			if(argc != 6)			goto CMD_FILE_ERROR;
			
			if(rxSrc == CMD_TYPE_ETHERNET)
			{
				rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
			}
			else
			{
				goto CMD_FILE_ERROR;
			}

			if(rtn == 0)			goto CMD_FILE_ERROR;
			
			if(rcvSize != fileSize)	goto CMD_FILE_ERROR;

			CMD_TransmitWaitTime(waitTime);

		}
		else if(CMD_Compare(pFileType, "binary"))
		{

			if(rxSrc == CMD_TYPE_ETHERNET)
			{
				rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
			}
			else
			{
				goto CMD_FILE_ERROR;
			}

			if(rtn == 0)									goto CMD_FILE_ERROR;

			if(rcvSize != fileSize)							goto CMD_FILE_ERROR;

			CMD_TransmitWaitTime(waitTime);

		}
		else			goto CMD_FILE_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "save.other"))
	{
//			0: file
//			1: save.other
//			2: fileSize
//			3: fileName

		u8	rtn;
		u8p	pFileName, pFileAdrs;
		u32	rxSrc, fileSize = 0, rcvSize = 0;
		u16	waitTime;

		CMD_Printf(";SAVE.OTHER");

		if(argc != 5)				goto CMD_FILE_ERROR;

		rxSrc = pTrxData->txSource;

		fileSize = CMD_StrToUL(pArgv[3]);
		pFileName = pArgv[4];

		waitTime = fileSize / 5000;

		if(rxSrc == CMD_TYPE_ETHERNET)
		{
			rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
		}
		else						goto CMD_FILE_ERROR;

		if(rtn == 0)				goto CMD_FILE_ERROR;

		if(fileSize != rcvSize)		goto CMD_FILE_ERROR;

		CMD_TransmitWaitTime(waitTime);
	}
	else if(CMD_Compare(pArgv[1], "save.path"))
	{
		u8	rtn;
		u8p	pFileAdrs;
		u32	rxSrc, fileSize = 0, rcvSize = 0;
		u16	waitTime;

		CMD_Printf(";SAVE.PATH");

		if(argc != 5)				goto CMD_FILE_ERROR;

//		memset(fileName, NULL, sizeof(fileName));

		fileSize = CMD_StrToUL(pArgv[2]);
//		strcpy((char*)fileName, (char*)pArgv[4]);

		waitTime = fileSize / 5000;

		rxSrc = pTrxData->txSource;

		if(rxSrc == CMD_TYPE_ETHERNET)
		{
			rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
		}
		else						goto CMD_FILE_ERROR;

		if(rtn == 0)				goto CMD_FILE_ERROR;

		if(fileSize != rcvSize)		goto CMD_FILE_ERROR;

		CMD_TransmitWaitTime(waitTime);
	}
	else if(CMD_Compare(pArgv[1], "save.fw"))
	{
		u8	rtn;
		u8p	pFileAdrs;
		u32	rxSrc, fileSize = 0; 
		u32 rcvSize = 0;
		u16	waitTime;

		CMD_Printf(";SAVE.FW");

		if(argc != 5)				goto CMD_FILE_ERROR;

//		memset(fileName, NULL, sizeof(fileName));

		fileSize = CMD_StrToUL(pArgv[2]);
//////////////////		strcpy((char*)fileName, (char*)pArgv[4]);

		waitTime = fileSize / 5000;

		rxSrc = pTrxData->txSource;

		if(rxSrc == CMD_TYPE_ETHERNET)
		{
			rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
		}
		else if(rxSrc == CMD_TYPE_SERIAL)
		{
			// disable 
//			UART_WaitOnFlagUntilTimeout(&h_Board_Serial, USART_ISR_IDLE, SET, 0, 0);
			App_FWSize = 0;
			UART_WaitOnFlagUntilTimeout(&h_Board_Serial, UART_FLAG_RXNE, RESET, HAL_GetTick(), 0);

			TRACE("zmodem : start \r\n");

			rcvSize = rz("test.txt", SDRAM_FPGA_READ_ADRS);	// 32Mb
			// enable
			HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
			if (rcvSize > 0) 
			{
				App_FWSize = rcvSize;
				rtn = 1;
			}

			TRACE("zmodem : size : %d \r\n", rcvSize);
		}
		else						goto CMD_FILE_ERROR;

		if(rtn == 0)				goto CMD_FILE_ERROR;

		if(fileSize != rcvSize)		goto CMD_FILE_ERROR;

		CMD_TransmitWaitTime(waitTime);

	}
	else
	{
		CMD_FILE_ERROR:
		result = 0;
	}

	if(result)		CMD_Printf(";OK");
	else			CMD_Printf(";ERROR");

	return result;
}

