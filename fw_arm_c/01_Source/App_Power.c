#include	"App_Power.h"

#if 0		// not used : smkim
static uc8	target = BOARDTYPE_POWER;
#endif		// not used : smkim
static u8 txData[256], txLen, rxData[256], rxLen;

static void PWR_BufferInit()
{
	txLen = 0;
	rxLen = 0;
	memset(txData, NULL, sizeof(txData));
	memset(rxData, NULL, sizeof(rxData));
}

u8 PWR_Test()
{
	u8	result = 0;
	u16	cmd;
	u8	chkr = 0;

	PWR_BufferInit();

	cmd = SB_PWR_CMD_TEST;

#if 0		// not used : smkim
	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
#endif		// not used : smkim
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, txLen) != 0)	result = 0;

	return result;
}

u8 PWR_Version(u8 *pData)
{
	u8	result = 0;
	u16	cmd;
	u8	chkr = 0; 

	PWR_BufferInit();

#if 0		// not used : smkim
	cmd = SB_PWR_CMD_VERSION;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)
	{
		result = 1;

		memcpy(pData, rxData, rxLen);
	}
#endif		// not used : smkim

	return result;
}

