#include	"App_ICT.h"

static uc8	target = BOARDTYPE_ICT;
static u8 txData[256], txLen, rxData[256], rxLen;

void ICT_BufferInit()
{
	txLen = 0;
	rxLen = 0;
	memset(txData, NULL, sizeof(txData));
	memset(rxData, NULL, sizeof(rxData));
}
u8 SB_SubBoardXfer(u8 target, u16 cmd, u8 *txData, u32 txLen, u8 *rxData, u8 *rxLen)
{
	// todo ..
	return 0;
}

u8 ICT_Init()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_INIT;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_Enable()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_ICT_ENABLE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_Disable()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_ICT_DISABLE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_OpenShortMode()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_OPENSHORT_MODE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_LeakageMode()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_LEAKAGE_MODE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_RelayMode(u8 data)
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	data &= 0x01;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_RELAY_MODE;

	txLen = 1;
	txData[0] = data;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_OpenShortSelect(u8 data)
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	data &= 0x0f;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_OPENSHORT_IO_SELECT;

	txLen = 1;
	txData[0] = data;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_LeakageSelect(u8 data)
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	data &= 0x0f;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_LEAKAGE_IO_SELECT;

	txLen = 1;
	txData[0] = data;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_OpenShortFVoltage(float voltage)
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_OPENSHORT_FVOLTAGE;

	txLen = 4;
	SYS_FloatToHex(voltage, &txData[0]);

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_LeakageFVoltage(float voltage)
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_LEAKAGE_FVOLTAGE;

	txLen = 4;
	SYS_FloatToHex(voltage, &txData[0]);

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_ModeEnable()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_ENABLE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_ModeDisable()
{
	u8 result = 0;
	u16	cmd;
	u8	chkr;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_DISABLE;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;
		
	if(rxLen != txLen)						result = 0;

	if(memcmp(rxData, txData, rxLen) != 0)	result = 0;

	return result;
}

u8 ICT_Read(float *pData)
{
	u8	result = 0;
	u16	cmd;
	u8	chkr;
	u8	readSize;

	ICT_BufferInit();

	cmd = SB_ICT_CMD_READ;

	chkr = SB_SubBoardXfer(target, cmd, txData, txLen, rxData, &rxLen);

	if(chkr)								result = 1;

	readSize = 40 * sizeof(float);
		
	if(rxLen != readSize)					result = 0;

	for(u8 cnt = 0; cnt < 40; cnt++)
	{
		pData[cnt] = SYS_HexToFloat(&rxData[cnt * sizeof(float)]);
	}

	return result;
}

