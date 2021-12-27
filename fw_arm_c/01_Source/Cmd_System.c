#include	"Cmd_System.h"

u8 Cmd_System(void *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8 result = 1;
	u16 argc = *pArgc;

	CMD_SerialTxOneTimeEnable();

	if(CMD_Compare(pArgv[1], "model"))
	{
		CMD_Printf(";MODEL");

		if(argc != 2)		goto CMD_SYSTEM_ERROR;

		CMD_Printf(";%s", SYSTEM_MODEL);
	}
	else if(CMD_Compare(pArgv[1], "version"))
	{
		u8	rtn;
		u8p	pData;
		u32	version;
		u16	msb, lsb;
		
		CMD_Printf(";VERSION");

		if(argc != 2)		goto CMD_SYSTEM_ERROR;

		CMD_Printf(";MAIN_%s", SYSTEM_VERSION);
		
		version = (FPGA_ReadSingle(FPGA_IMAGE_ID_H) << 16);
		version |= (FPGA_ReadSingle(FPGA_IMAGE_ID_L) << 16);

		msb = lsb = (u8)version;

		msb >>= 4;
		lsb &= 0x0f;

		CMD_Printf(";FPGA_%01x.%01x", msb, lsb);

		pData = (u8*)SDRAM_CMD_BUFFER_ADRS;

		memset(pData, NULL, 32);
		
		rtn = PWR_Version(pData);

		if(rtn == 0)		goto CMD_SYSTEM_ERROR;
		
		CMD_Printf(";POWER_%s", pData);
	}
	else if(CMD_Compare(pArgv[1], "build"))
	{
		u8	rtn;
		u8p	pData;
		u16	year, month, day;
		u32	version;
		
		CMD_Printf(";BUILD");

		if(argc != 2)		goto CMD_SYSTEM_ERROR;

		CMD_Printf(";MAIN_%s", SYSTEM_BUILDDATE);

		version = (FPGA_ReadSingle(FPGA_IMAGE_ID_H) << 16);
		version |= FPGA_ReadSingle(FPGA_IMAGE_ID_L);

		year	= (u16)(version >> 24);
		month	= (u16)(version >> 16);
		day		= (u16)(version >> 8);

		year	&= 0x00ff;
		month	&= 0x00ff;
		day		&= 0x00ff;

		year |= 0x2000;

		CMD_Printf(";FPGA_%04x.%02x.%02x", year, month, day);

		pData = (u8*)SDRAM_CMD_BUFFER_ADRS;
		
		rtn = 0;         //PWR_BuildDate(pData);

		if(rtn == 0)		goto CMD_SYSTEM_ERROR;

		CMD_Printf(";POWER_%s", pData);
	}
	else if(CMD_Compare(pArgv[1], "delay"))
	{
		u32	delayCnt;
		
		CMD_Printf(";DELAY");

		if(argc != 3)		goto CMD_SYSTEM_ERROR;

		delayCnt = CMD_StrToUL(pArgv[2]);

		HAL_Delay(delayCnt);
	}
	else if(CMD_Compare(pArgv[1], "reset"))
	{
		CMD_Printf(";RESET");

		if(argc != 2)		goto CMD_SYSTEM_ERROR;

		systemReset = 1;
	}
	else if(CMD_Compare(pArgv[1], "config"))
	{
		CMD_Printf(";CONFIG");

		if(CMD_Compare(pArgv[2], "password"))
		{
			CMD_Printf(";PASSWORD");

			if(argc != 4)	goto CMD_SYSTEM_ERROR;

			if(CMD_Compare(pArgv[3], "topenge7502"))
			{
				System_Release();

				CMD_Printf(";SYSTEM_RELEASE");
			}
			else
			{
				System_Lock();

				CMD_Printf(";SYSTEM_LOCK");
			}
		}
		else if(CMD_Compare(pArgv[2], "read"))
		{
			u8 dummy[20];
			
			CMD_Printf(";READ");

			if(argc != 4)
			{
				goto CMD_SYSTEM_ERROR;
			}

			memset(dummy, NULL, sizeof(dummy));

			if(CMD_Compare(pArgv[3], "modeltype"))
			{
				CMD_Printf(";MODELTYPE");
				
				memcpy(dummy, sysConfig.modelType, 10);
				
				CMD_Printf(";%s", dummy);
			}
			else if(CMD_Compare(pArgv[3], "serial"))
			{
				CMD_Printf(";SERIAL_NO");
				
				memcpy(dummy, sysConfig.serialNo, 8);

				CMD_Printf(";%s", dummy);
			}
			else if(CMD_Compare(pArgv[3], "builddate"))
			{
				CMD_Printf(";SERIAL_NO");
				
				memcpy(dummy, sysConfig.buildDate, 6);

				CMD_Printf(";%s", dummy);
			}
			else if(CMD_Compare(pArgv[3], "hwtype"))
			{
				CMD_Printf(";HWTYPE");

				CMD_Printf(";0x%02x", sysConfig.hwType);
			}
			else if(CMD_Compare(pArgv[3], "log"))
			{
				CMD_Printf(";LOG");
				
				if(sysConfig.userLogEnable)
				{
					strcpy((char*)dummy, ";ENABLE");
				}
				else
				{
					strcpy((char*)dummy, ";DISABLE");
				}

				CMD_Printf(";%s", dummy);
			}
			else if(CMD_Compare(pArgv[3], "debug"))
			{
				CMD_Printf(";DEBUG");
				
				if(sysConfig.debugLogEnable)
				{
					strcpy((char*)dummy, ";ENABLE");
				}
				else
				{
					strcpy((char*)dummy, ";DISABLE");
				}

				CMD_Printf(";%s", dummy);
			}
			else if(CMD_Compare(pArgv[3], "secretcode"))
			{
				CMD_Printf(";SECRETCODE");
				
				CMD_Printf(";0x%08x", sysConfig.secretCode);
			}
#if 0		// not used : smkim
			else if(CMD_Compare(pArgv[3], "dsimode"))
			{
				CMD_Printf(";DSIMODE");
				
				switch(sysConfig.dsiMode)
				{
					case MIPI_DSI_TYPE_NONE:
						CMD_Printf(";NO_SELECT");
						break;

					case MIPI_DSI_TYPE_SSD2829:
						CMD_Printf(";SSD2829");
						break;

					case MIPI_DSI_TYPE_FPGA:
						CMD_Printf(";DSI1.2_FPGA");
						break;

					case MIPI_DSI_TYPE_CORE:
						CMD_Printf(";DSI1.2_CORE");
						break;

//					case MIPI_DSI_TYPE_PNC:
//						CMD_Printf(";PNC_MDM_X");
//						break;
				}
			}
			else if(CMD_Compare(pArgv[3], "pclkod"))
			{
				CMD_Printf(";PCLKOD");
				CMD_Printf(";%d", sysConfig.odPClk);
			}
			else if(CMD_Compare(pArgv[3], "bclkod"))
			{
				CMD_Printf(";BCLKOD");
				CMD_Printf(";%d", sysConfig.odBClk);
			}
			else if(CMD_Compare(pArgv[3], "writecnt"))
			{
				CMD_Printf(";WRITECNT");
				
				CMD_Printf(";%d", sysConfig.writeCnt);
			}
			else if(CMD_Compare(pArgv[3], "drivemode"))
			{
				CMD_Printf(";DRIVEMODE");

				if(sysConfig.mDrive == 0)
				{
					CMD_Printf(";NAND_FLASH");
				}
				else if(sysConfig.mDrive == 1)
				{
					CMD_Printf(";MICRO_SD");
				}
			}
#endif 		// not used
			else
			{
				goto CMD_SYSTEM_ERROR;
			}
		}
		else if(CMD_Compare(pArgv[2], "write"))
		{
			u16 length;
			u8 dummy[20];
			
			CMD_Printf(";WRITE");

			if(argc != 5)
			{
				goto CMD_SYSTEM_ERROR;
			}

			memset(dummy, NULL, sizeof(dummy));

			length = strlen((char*)pArgv[4]);

			if(length > sizeof(dummy))
			{
				memcpy(dummy, pArgv[4], sizeof(dummy));
			}
			else
			{
				memcpy(dummy, pArgv[4], length);
			}
			
			if(CMD_Compare(pArgv[3], "modeltype"))
			{
				CMD_Printf(";MODELTYPE");

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;
				
				memcpy(sysConfig.modelType, dummy, 10);
			}
			else if(CMD_Compare(pArgv[3], "serial"))
			{
				CMD_Printf(";SERIAL_NO");

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;
				
				memcpy(sysConfig.serialNo, dummy, 8);
			}
			else if(CMD_Compare(pArgv[3], "builddate"))
			{
				CMD_Printf(";SERIAL_NO");

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;
				
				memcpy(sysConfig.buildDate, dummy, 6);
			}
			else if(CMD_Compare(pArgv[3], "hwtype"))
			{
				CMD_Printf(";HWTYPE");

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;
				
				sysConfig.hwType = (u8)(CMD_StrToUL(pArgv[4]) & 0x00ff);
			}
			else if(CMD_Compare(pArgv[3], "log"))
			{
				CMD_Printf(";LOG");
				
				if(CMD_Compare(pArgv[4], "enable"))
				{
					sysConfig.userLogEnable = 1;
				}
				else if(CMD_Compare(pArgv[4], "disable"))
				{
					sysConfig.userLogEnable = 0;
				}
				else
				{
					goto CMD_SYSTEM_ERROR;
				}
			}
			else if(CMD_Compare(pArgv[3], "debug"))
			{
				CMD_Printf(";DEBUG");

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;
				
				if(CMD_Compare(pArgv[4], "enable"))
				{
					sysConfig.debugLogEnable = 1;
				}
				else if(CMD_Compare(pArgv[4], "disable"))
				{
					sysConfig.debugLogEnable = 0;
				}
				else
				{
					goto CMD_SYSTEM_ERROR;
				}
			}
#if 0			// not used :  smkim
			else if(CMD_Compare(pArgv[3], "dsimode"))
			{
				CMD_Printf(";DSIMODE");

				if(CMD_Compare(pArgv[4], "none"))
				{
					sysConfig.dsiMode = MIPI_DSI_TYPE_NONE;
				}
				else if(CMD_Compare(pArgv[4], "ssd2829"))
				{
					sysConfig.dsiMode = MIPI_DSI_TYPE_SSD2829;
				}
				else if(CMD_Compare(pArgv[4], "dsi1.2"))
				{
					sysConfig.dsiMode = MIPI_DSI_TYPE_FPGA;
				}
				else if(CMD_Compare(pArgv[4], "core"))
				{
					sysConfig.dsiMode = MIPI_DSI_TYPE_CORE;
				}
				else if(CMD_Compare(pArgv[4], "pnc"))
				{
//					sysConfig.dsiMode = MIPI_DSI_TYPE_PNC;
				}
				else
				{
					goto CMD_SYSTEM_ERROR;
				}

			}
			else if(CMD_Compare(pArgv[3], "pclkod"))
			{
				u8 od;
				
				CMD_Printf(";PCLKOD");

				od = CMD_StrToUL(pArgv[4]);

				if(od > 7)		goto CMD_SYSTEM_ERROR;

				fpgaPclkOD = sysConfig.odPClk = od;
			}
			else if(CMD_Compare(pArgv[3], "bclkod"))
			{
				u8 od;
				
				CMD_Printf(";BCLKOD");

				od = CMD_StrToUL(pArgv[4]);

				if(od > 7)		goto CMD_SYSTEM_ERROR;

				fpgaBclkOD = sysConfig.odBClk = od;
			}
			else if(CMD_Compare(pArgv[3], "drivemode"))
			{
				u8	drive;

				if(System_LockCheck() == 0)	goto CMD_SYSTEM_ERROR;

				if(CMD_Compare(pArgv[4], "nand"))
				{
					drive = 0;
				}
				else if(CMD_Compare(pArgv[4], "microsd"))
				{
					drive = 1;
				}
				else			goto CMD_SYSTEM_ERROR;

				fmDrive = sysConfig.mDrive	= drive;
			}
#endif 		// not used
			else
			{
				goto CMD_SYSTEM_ERROR;
			}
		}
		else if(CMD_Compare(pArgv[2], "save"))
		{
			sysConfig_t cpy;
			
			u8 ret;
			
			CMD_Printf(";SAVE");

			if(argc != 3)
			{
				goto CMD_SYSTEM_ERROR;
			}

			memcpy(cpy.u8Data, sysConfig.u8Data, sizeof(sysConfig_t));

			System_SysConfigWrite(&cpy);
			System_SysConfigRead(&cpy);
			ret = System_SysConfigCheck(&cpy);

			if(ret)
			{
				// Success

				memcpy(sysConfig.u8Data, cpy.u8Data, sizeof(sysConfig_t));
			}
			else
			{
				// Fail
				goto CMD_SYSTEM_ERROR;
			}
		}
		else
		{
			goto CMD_SYSTEM_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "netconfig"))
	{
		CMD_Printf(";NETCONFIG");
		
		if(CMD_Compare(pArgv[2], "read"))
		{
			CMD_Printf(";READ");
			
			if(argc != 4)
			{
				goto CMD_SYSTEM_ERROR;
			}

			if(CMD_Compare(pArgv[3], "status"))
			{
				CMD_Printf(";STATUS");
				
				if(sysConfig.ethEN)
				{
					CMD_Printf(";ETHERNET_ENABLE");
				}
				else
				{
					CMD_Printf(";ETHERNET_DISABLE");
				}
			}
			else if(CMD_Compare(pArgv[3], "mode"))
			{
				CMD_Printf(";MODE");

				if(sysConfig.networkMode == 0)			// TCP
				{
					CMD_Printf(";TCP");
				}
				else if(sysConfig.networkMode == 1)	// UDP
				{
					CMD_Printf(";UDP");
				}
			}
			else if(CMD_Compare(pArgv[3], "mac"))
			{
				CMD_Printf(";MAC_ADDRESS");

				CMD_Printf(";%02X.",	sysConfig.macAdrs[0]);
				CMD_Printf("%02X.",		sysConfig.macAdrs[1]);
				CMD_Printf("%02X.",		sysConfig.macAdrs[2]);
				CMD_Printf("%02X.",		sysConfig.macAdrs[3]);
				CMD_Printf("%02X.",		sysConfig.macAdrs[4]);
				CMD_Printf("%02X",		sysConfig.macAdrs[5]);
			}
			else if(CMD_Compare(pArgv[3], "ip"))
			{
				CMD_Printf(";IP_ADDRESS");

				CMD_Printf(";%d.",	sysConfig.ipAdrs[0]);
				CMD_Printf("%d.",	sysConfig.ipAdrs[1]);
				CMD_Printf("%d.",	sysConfig.ipAdrs[2]);
				CMD_Printf("%d",	sysConfig.ipAdrs[3]);
			}
			else if(CMD_Compare(pArgv[3], "gateway"))
			{
				CMD_Printf(";GW_ADDRESS");

				CMD_Printf(";%d.",	sysConfig.gwAdrs[0]);
				CMD_Printf("%d.",	sysConfig.gwAdrs[1]);
				CMD_Printf("%d.",	sysConfig.gwAdrs[2]);
				CMD_Printf("%d",	sysConfig.gwAdrs[3]);
			}
			else if(CMD_Compare(pArgv[3], "netmask"))
			{
				CMD_Printf(";NM_ADDRESS");

				CMD_Printf(";%d.",	sysConfig.nmAdrs[0]);
				CMD_Printf("%d.",	sysConfig.nmAdrs[1]);
				CMD_Printf("%d.",	sysConfig.nmAdrs[2]);
				CMD_Printf("%d",	sysConfig.nmAdrs[3]);
			}
			else if(CMD_Compare(pArgv[3], "tcpport"))
			{
				CMD_Printf(";TCPPORT");
				
				CMD_Printf(";%d",	sysConfig.networkPort);
			}
			else
			{
				goto CMD_SYSTEM_ERROR;
			}
		}
		else if(CMD_Compare(pArgv[2], "write"))
		{
			CMD_Printf(";WRITE");

			if(CMD_Compare(pArgv[3], "status"))
			{
				CMD_Printf(";STATUS");
				
				if(argc != 5)
				{
					goto CMD_SYSTEM_ERROR;
				}

				if(CMD_Compare(pArgv[4], "enable"))
				{
					sysConfig.ethEN = 1;
				}
				else if(CMD_Compare(pArgv[4], "disable"))
				{
					sysConfig.ethEN = 0;
				}
				else
				{
					goto CMD_SYSTEM_ERROR;
				}
			}
			else if(CMD_Compare(pArgv[3], "mode"))
			{
				CMD_Printf(";MODE");

				if(argc != 5)	goto CMD_SYSTEM_ERROR;

				if(CMD_Compare(pArgv[4], "tcp"))
				{
					sysConfig.networkMode	= 0;
				}
				else if(CMD_Compare(pArgv[4], "udp"))
				{
					sysConfig.networkMode	= 1;
				}
				else			goto CMD_SYSTEM_ERROR;
			}
			else if(CMD_Compare(pArgv[3], "mac"))
			{
				CMD_Printf(";MAC_ADDRESS");
				
				if(argc != 10)
				{
					goto CMD_SYSTEM_ERROR;
				}

				sysConfig.macAdrs[0] = CMD_StrToUL(pArgv[4]);
				sysConfig.macAdrs[1] = CMD_StrToUL(pArgv[5]);
				sysConfig.macAdrs[2] = CMD_StrToUL(pArgv[6]);
				sysConfig.macAdrs[3] = CMD_StrToUL(pArgv[7]);
				sysConfig.macAdrs[4] = CMD_StrToUL(pArgv[8]);
				sysConfig.macAdrs[5] = CMD_StrToUL(pArgv[9]);
			}
			else if(CMD_Compare(pArgv[3], "ip"))
			{
				CMD_Printf(";IP_ADDRESS");

				if(argc != 8)
				{
					goto CMD_SYSTEM_ERROR;
				}

				sysConfig.ipAdrs[0] = CMD_StrToUL(pArgv[4]);
				sysConfig.ipAdrs[1] = CMD_StrToUL(pArgv[5]);
				sysConfig.ipAdrs[2] = CMD_StrToUL(pArgv[6]);
				sysConfig.ipAdrs[3] = CMD_StrToUL(pArgv[7]);
			}
			else if(CMD_Compare(pArgv[3], "gateway"))
			{
				CMD_Printf(";GW_ADDRESS");

				if(argc != 8)
				{
					goto CMD_SYSTEM_ERROR;
				}

				sysConfig.gwAdrs[0] = CMD_StrToUL(pArgv[4]);
				sysConfig.gwAdrs[1] = CMD_StrToUL(pArgv[5]);
				sysConfig.gwAdrs[2] = CMD_StrToUL(pArgv[6]);
				sysConfig.gwAdrs[3] = CMD_StrToUL(pArgv[7]);
			}
			else if(CMD_Compare(pArgv[3], "netmask"))
			{
				CMD_Printf(";NM_ADDRESS");

				if(argc != 8)
				{
					goto CMD_SYSTEM_ERROR;
				}

				sysConfig.nmAdrs[0] = CMD_StrToUL(pArgv[4]);
				sysConfig.nmAdrs[1] = CMD_StrToUL(pArgv[5]);
				sysConfig.nmAdrs[2] = CMD_StrToUL(pArgv[6]);
				sysConfig.nmAdrs[3] = CMD_StrToUL(pArgv[7]);
			}
			else if(CMD_Compare(pArgv[3], "tcpport"))
			{
				u32 port;
				
				CMD_Printf(";TCPPORT");

				if(argc != 5)			goto CMD_SYSTEM_ERROR;

				port = CMD_StrToUL(pArgv[4]);

				if(port > 0x0000ffff)	goto CMD_SYSTEM_ERROR;

				networkPort = sysConfig.networkPort = (u16)(port & 0x0000ffff);
			}
			else
			{
				goto CMD_SYSTEM_ERROR;
			}
		}
		else if(CMD_Compare(pArgv[2], "save"))
		{
			sysConfig_t cpy;
			
			u8 ret;
			
			CMD_Printf(";SAVE");

			if(argc != 3)				goto CMD_SYSTEM_ERROR;

			memcpy(cpy.u8Data, sysConfig.u8Data, sizeof(sysConfig_t));

			System_SysConfigWrite(&cpy);
			System_SysConfigRead(&cpy);
			ret = System_SysConfigCheck(&cpy);

			if(ret)
			{
				// Success

				memcpy(sysConfig.u8Data, cpy.u8Data, sizeof(sysConfig_t));

				systemReset = 1;
			}
			else
			{
				// Fail
				goto CMD_SYSTEM_ERROR;
			}
		}
		else
		{
			goto CMD_SYSTEM_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "i2c.write"))
	{
		u8	devAdrs, regAdrs;
		u16 dataCnt;
		u8	*pBuff;

		CMD_Printf(";I2C.WRITE");

		if(argc < 5)	goto CMD_SYSTEM_ERROR;

		devAdrs = CMD_StrToUL(pArgv[2]);
		regAdrs = CMD_StrToUL(pArgv[3]);

		dataCnt = argc - 4;

		pBuff = (u8*)SDRAM_CMD_BUFFER_ADRS;

		memset(pBuff, NULL, dataCnt);

		for(u16 cnt = 0; cnt < dataCnt; cnt++)
		{
			pBuff[cnt] = CMD_StrToUL(pArgv[cnt + 4]);
		}

		AA_Write(devAdrs, regAdrs, pBuff, dataCnt);
	}
	else if(CMD_Compare(pArgv[1], "i2c.read"))
	{
		u8	devAdrs, regAdrs;
		u16 dataCnt;
		u8	*pBuff;

		CMD_Printf(";I2C.READ");

		if(argc != 5)		goto CMD_SYSTEM_ERROR;

		devAdrs = CMD_StrToUL(pArgv[2]);
		regAdrs = CMD_StrToUL(pArgv[3]);
		dataCnt = CMD_StrToUL(pArgv[4]);

		if(dataCnt > 256)	goto CMD_SYSTEM_ERROR;

		pBuff = (u8*)SDRAM_CMD_BUFFER_ADRS;

		memset(pBuff, NULL, dataCnt);

		AA_Read(devAdrs, regAdrs, pBuff, dataCnt);

		CMD_Printf(";");

		for(u16 cnt = 0; cnt < dataCnt; cnt++)
		{
			CMD_Printf("0x%02X ", pBuff[cnt]);
		}
	}
	else if(CMD_Compare(pArgv[1], "eep.scan"))
	{
		u8 data;
		
		CMD_Printf(";EEP.SCAN");

		if(argc < 2)	goto CMD_SYSTEM_ERROR;

		data = EEP_AdrsScan();

		CMD_Printf(";0x%X", data);
	}
	else if(CMD_Compare(pArgv[1], "serial.mode"))
	{
		CMD_Printf(";SERIAL.MODE");

//		if(pTrxData->txSource == CMD_TYPE_SERIAL)	goto CMD_SYSTEM_ERROR;

		if(argc != 3)	goto CMD_SYSTEM_ERROR;

		if(CMD_Compare(pArgv[2], "cmd"))
		{
			Serial_Init();
			
			Serial_CmdMode();
		}
		else if(CMD_Compare(pArgv[2], "ext"))
		{
			Serial_ExtMode();
		}
		else 			goto CMD_SYSTEM_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "serial.init"))
	{
		u32	baudrate;
		
		CMD_Printf(";SERIAL.INIT");

//		if(pTrxData->txSource == CMD_TYPE_SERIAL)	goto CMD_SYSTEM_ERROR;

		if(serialMode == SERIAL_CMD_MODE)			goto CMD_SYSTEM_ERROR;

		if(argc != 3)	goto CMD_SYSTEM_ERROR;

		baudrate = CMD_StrToUL(pArgv[2]);

		//Serial_ExtInit(baudrate);
		TRACE("Can not use Ext_serial in F5500 System\r\n");
	}
	else if(CMD_Compare(pArgv[1], "serial.tx"))
	{
		CMD_Printf(";SERIAL.TX");

		if(serialMode == SERIAL_CMD_MODE)			goto CMD_SYSTEM_ERROR;

		if(argc != 3)								goto CMD_SYSTEM_ERROR;

		Serial_Printf("%s\r", pArgv[2]);
	}
	else if(CMD_Compare(pArgv[1], "serial.rxcheck"))
	{
		u32 dataCnt;
		
		CMD_Printf(";SERIAL.RXCHECK");

		if(serialMode == SERIAL_CMD_MODE)			goto CMD_SYSTEM_ERROR;

		if(argc != 2)								goto CMD_SYSTEM_ERROR;

		dataCnt = Serial_ExtDataCheck();

		if(dataCnt == 0)
		{
			CMD_Printf(";NO_DATA");
		}
		else
		{
			CMD_Printf(";Rx %d Data", dataCnt);
		}
	}
	else if(CMD_Compare(pArgv[1], "serial.rx"))
	{
		u8	*pData;
		u16	dataCnt;

		CMD_Printf(";SERIAL.RX");

		if(serialMode == SERIAL_CMD_MODE)			goto CMD_SYSTEM_ERROR;

		if(argc != 2)								goto CMD_SYSTEM_ERROR;

		dataCnt = Serial_ExtDataCheck();

		if(dataCnt == 0)
		{
			CMD_Printf(";NO_DATA");
		}
		else
		{
			dataCnt = Serial_ExtDataCheck();
			pData = (u8*)SDRAM_CMD_BUFFER_ADRS;

			memset(pData, NULL, (64 * 1024));

			dataCnt = Serial_ExtDataOut(pData);

			CMD_Printf(";%s", pData);
		}
	}
	else if(CMD_Compare(pArgv[1], "led.enable"))
	{
		CMD_Printf(";LED.ENABLE");

		if(argc != 2)								goto CMD_SYSTEM_ERROR;

		ledDisable = 0;

//		FPGA_DebugLedCtrl(1);
	}
	else if(CMD_Compare(pArgv[1], "led.disable"))
	{
		CMD_Printf(";LED.DISABLE");

		if(argc != 2)								goto CMD_SYSTEM_ERROR;

		ledDisable = 1;

//		FPGA_DebugLedCtrl(0);
	}
	else
	{
		CMD_SYSTEM_ERROR:
		result = 0;
	}

	if(result)		CMD_Printf(";OK");
	else			CMD_Printf(";ERROR");

	return result;
}
