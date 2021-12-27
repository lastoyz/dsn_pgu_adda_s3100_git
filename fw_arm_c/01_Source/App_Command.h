#ifndef	_APP_COMMAND_H
#define	_APP_COMMAND_H

#include "top_core_info.h"

#define	CMD_TRX_PACKET_SIZE			2048
#define	CMD_TRX_PACKET_SEND_SIZE	1200

#define	CMD_MAX_COUNT		300
#define	CMD_DELIMITER_1		" .\t\r\n"
#define	CMD_DELIMITER_2		" \t\r\n"
#define	CMD_DELIMITER_3		"\r"
#define	CMD_DELIMITER_4		" \t\"\r\n"
#define	CMD_DELIMITER_5		"\""

typedef	struct{
	u32	enable;
	u32	sTime;
	u32	rTime;
	u32	setTime;
}cmdWaitTime_t;

typedef	struct{
	u8	enable;
	u8	oneTime;
}cmdSerialTx_t;

enum{
	CMD_TYPE_NONE= 0,
	CMD_TYPE_SERIAL,
	CMD_TYPE_ETHERNET,
	CMD_TYPE_GPIB,
};

extern	u16 cmdCnt;
extern	u8 *cmdData[CMD_MAX_COUNT];

extern	trxData_t	trxData;

#ifdef __cplusplus
extern "C" {
#endif

void CMD_RcvCheck();
void CMD_SerialTxOneTimeEnable();
void CMD_Init();
u8 CMD_Compare(u8 *s1Data, const char *s2Data);
u8 CMD_CompareByte(char *s1Data, const char *s2Data);

void CMD_Strlwr(u8 *pData);
u8 CMD_ColorConverter(u8 *pData, u32 *pColor);
void CMD_SerialTxEnable();
void CMD_SerialTxDisable();
void CMD_TransmitWaitTime(u16 data);
u32 CMD_StrToUL(u8 *pData);
double CMD_AToF(u8 *pData);
void CMD_Printf(const char *pData, ...);
void CMD_TxData(u8 *pData, u32 length);
u8 CMD_Process(trxData_t *pTrxData);

u8 CMD_WaitTimeDelay();
void CMD_TransmitAck(trxData_t *pTrxData);
void CMD_BinTransmitAck(trxData_t *pTrxData);
#ifdef __cplusplus
}
#endif
#endif	// _APP_COMMAND_H
