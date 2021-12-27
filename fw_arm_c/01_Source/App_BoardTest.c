#include	"App_BoardTest.h"

static	u8	boardTestEnable = 0;

void BTest_Enable()
{
	boardTestEnable = 1;
}

void BTest_Disable()
{
	boardTestEnable = 0;
}

u8 BTest_Check()
{
	return boardTestEnable;
}

u8 BTest_SDRAM()
{
	u8	result = 0;
	u32	bitCnt, cnt, testSize;
	u32	writeData, readData;
	u32	errorCnt;
	u32 *pTestAdrs;

	pTestAdrs	= (u32*)SDRAM_RGB_DUMP_ADRS;

	testSize = 64 * 1024 * 1024;		// 64MB
	testSize /= 4;

	errorCnt = 0;

	for(cnt = 0; cnt < testSize; cnt++)
	{
		for(bitCnt = 0; bitCnt < 2; bitCnt++)
		{
			if(bitCnt)	writeData = 0x55555555;
			else		writeData = 0xaaaaaaaa;

			pTestAdrs[cnt] = writeData;

			readData = pTestAdrs[cnt];

			if(writeData != readData)	errorCnt++;
		}
	}

	if(errorCnt == 0)	result = 1;

	return result;
}

u8 BTest_NAND()
{
	u8	result = 0;

	return result;
}

