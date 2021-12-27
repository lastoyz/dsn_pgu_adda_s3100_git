#include	"Cmd_BoardTest.h"

#define TIMEOUT (-2)
#define ERROR (-1)

//#define READLINE_PF(timeout)	SerialInChar()  // [newlib]
static uint8_t READLINE_PF(uint32_t timeout) 
{
	uint8_t data;
	int8_t res = 0;

	switch(HAL_UART_Receive(&h_Board_Serial, &data, 1, timeout)) 
	{
		case HAL_TIMEOUT:
          return TIMEOUT;
		case HAL_ERROR:
			return ERROR;
	}
	return data;
}

u8 Cmd_BoardTest(trxData_t *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8 result = 1;
	vu16 argc = *pArgc;

	if(CMD_Compare(pArgv[1], "enable"))
	{
		CMD_Printf(";ENABLE");

		if(argc != 2)			goto CMD_BOARDTEST_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "sdram"))
	{
		u8	rtn;
		u32	sTime, rTime;

		CMD_Printf(";SDRAM");

		if(argc != 2)			goto CMD_BOARDTEST_ERROR;

		sTime = HAL_GetTick();
		
		rtn = BTest_SDRAM();

		rTime = HAL_GetTick();

		CMD_Printf(";RUNTIME:%dms", (rTime - sTime));

		if(rtn == 0)			goto CMD_BOARDTEST_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "serial"))
	{
		u8	rtn;
		u32	dTime;
		u32	dCnt;
		int8_t  dChar;

		bTest32BitIO_t	errData;

		CMD_Printf(";SERIAL");

		if(argc != 4)			goto CMD_BOARDTEST_ERROR;

		memset(&errData, NULL, sizeof(errData));

		dTime = CMD_StrToUL(pArgv[2]);
		dCnt =  CMD_StrToUL(pArgv[3]);
		TRACE("==> argc : %d, cnt : %d\r\n", argc, dTime, dCnt);

		TRACE("WaitingFlagUntil Timeout..\r\n");
		UART_WaitOnFlagUntilTimeout(&h_Board_Serial, UART_FLAG_RXNE, RESET, HAL_GetTick(), 0);
		TRACE("WaitingFlagUntil done...\r\n");
		while (dCnt > 0) {
			TRACE("%3d  th..\r\n", dCnt);
			dChar = READLINE_PF(dTime) ;
			TRACE("ch : %d %c\r\n", dChar, dChar);
			if (dChar < 0) {
				break;
			}
			dCnt--;
		}

		HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);

	}
	else
	{
		CMD_BOARDTEST_ERROR:
		result = 0;
	}

	if(result)		CMD_Printf(";OK");
	else			CMD_Printf(";ERROR");

	return result;
}

