#ifndef	_APP_SERIAL_H
#define	_APP_SERIAL_H

#include 	"top_core_info.h"

#define	SERIAL_GPIO				GPIOC

#define	SERIAL_GPIO_TX_PIN		GPIO_PIN_6
#define	SERIAL_GPIO_RX_PIN		GPIO_PIN_7

/// USART 2
#define	SBP_UART_GPIO			GPIOA

#define	SBP_UART_GPIO_TX_PIN	GPIO_PIN_2
#define	SBP_UART_GPIO_RX_PIN	GPIO_PIN_3

#define	SERIAL_TRX_PACKET_SIZE	2048

enum{
	SERIAL_CMD_MODE = 0,
	SERIAL_EXT_MODE
};

typedef	struct{
	u8	*pData;
	u16	startPos;
	u16	rcvPos;
	u32	time;
}serialRCV_t;

extern	u8	serialMode;

extern	u8 serialRs485Mode;
extern	UART_HandleTypeDef	h_Board_Serial;
extern	UART_HandleTypeDef	hSerial_BT;
extern	u32	serialRxCnt;
extern	u8	*serialRxData;
extern	u8	serialRxTemp, serialRxFlag;

extern	UART_HandleTypeDef	hExtSerial;
extern	u32	boardRxCnt;
extern	u8	boardRxData[SERIAL_TRX_PACKET_SIZE];
extern	u8	boardRxTemp, boardRxFlag;

extern	serialRCV_t	serialRCV;
extern	serialRCV_t	ExtSerialRCV;

void Serial_Init();					/// USART2 	(RS-232C)
void Serial_ExtInit(u32 baudrate);	// USART6	(Debug)

void Serial_RS485DEnRECtrl(u8 state);

u8 Serial_Printf(const char *pData, ...);
u8 Ext_Serial_Printf(const char *pData, ...);

u8 Serial_TxData(u8 *pData, u16 length);
u8 Ext_Serial_TxData(u8 *pData, u16 length);

void Serial_RxRecover();
void Ext_Serial_RxRecover();

void Serial_CmdMode();
void Serial_ExtMode();

u16 Serial_ExtDataCheck();
u16 Serial_ExtDataOut(u8 *pData);
u8 Serial_CommandProcess();

#endif	// _APP_SERIAL_H
