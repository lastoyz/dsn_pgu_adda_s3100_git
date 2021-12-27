#include	"App_Serial.h"

u8	serialMode;

u8	serialRs485Mode;
UART_HandleTypeDef	h_Board_Serial;
UART_HandleTypeDef	hSerial_BT;

u32	serialRxCnt;
u8	*serialRxData = (u8*)SDRAM_SERIAL_RX_BUFFER_ADRS;
u8	serialRxTemp, serialRxFlag;
serialRCV_t	serialRCV;

///////////////////
// Debug
UART_HandleTypeDef	hExtSerial;
u32	boardRxCnt;
u8	boardRxData[SERIAL_TRX_PACKET_SIZE];
u8	boardRxTemp, boardRxFlag;

u32	ExtSerialRxCnt;
u8	*ExtserialRxData = (u8*)SDRAM_SERIAL_RX_EXT;
u8	ExtSerialRxTemp, ExtSerialRxFlag;
serialRCV_t	ExtSerialRCV;

void HAL_UART_MspInit(UART_HandleTypeDef *huart)
{
	GPIO_InitTypeDef	gpio;
	
	if(huart->Instance == USART1)
	{		
		// UASRT1 
		gpio.Pin		= SBP_UART_GPIO_TX_PIN | SBP_UART_GPIO_RX_PIN;
		gpio.Mode		= GPIO_MODE_AF_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;
		gpio.Alternate	= GPIO_AF7_USART1;

		HAL_GPIO_Init(SBP_UART_GPIO, &gpio);
	}
	else if(huart->Instance == USART2)
	{		
		// UASRT2  : RS-232C
		gpio.Pin		= SBP_UART_GPIO_TX_PIN | SBP_UART_GPIO_RX_PIN;
		gpio.Mode		= GPIO_MODE_AF_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;
		gpio.Alternate	= GPIO_AF7_USART2;

		HAL_GPIO_Init(SBP_UART_GPIO, &gpio);
	}
	else if(huart->Instance == USART6)
	{
		// UART 
		gpio.Pin		= SERIAL_GPIO_TX_PIN | SERIAL_GPIO_RX_PIN;
		gpio.Mode		= GPIO_MODE_AF_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;
		gpio.Alternate	= GPIO_AF8_USART6;

		HAL_GPIO_Init(SERIAL_GPIO, &gpio);

		// RS485 DE
		gpio.Pin		= GPIO_PIN_12;
		gpio.Mode		= GPIO_MODE_OUTPUT_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;
		gpio.Alternate	= 0;

		HAL_GPIO_Init(GPIOG, &gpio);

		HAL_GPIO_WritePin(GPIOG, GPIO_PIN_12, GPIO_PIN_RESET);
	}
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	if(huart->Instance == USART1)
	{
		HAL_UART_Receive_IT(&hSerial_BT, &serialRxTemp, 1);
		serialRCV.pData[(serialRCV.rcvPos)++] = serialRxTemp;

		__DSB();

		serialRCV.time = 0;
	}
	else if(huart->Instance == USART2)
	{
		HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
		serialRCV.pData[(serialRCV.rcvPos)++] = serialRxTemp;

		__DSB();

		serialRCV.time = 0;
	}
	else if(huart->Instance == USART6)
	{
		// Debug
		HAL_UART_Receive_IT(&hExtSerial, &boardRxTemp, 1);
		ExtSerialRCV.pData[(ExtSerialRCV.rcvPos)++] = ExtSerialRxTemp;

		__DSB();

		ExtSerialRCV.time = 0;
	}
}

void Serial_Init()
{
	__HAL_RCC_USART2_CLK_ENABLE();

	serialRs485Mode = 0;
	
	h_Board_Serial.Instance					= USART2;
	h_Board_Serial.Init.BaudRate			= 115200;
	h_Board_Serial.Init.WordLength			= UART_WORDLENGTH_8B;
	h_Board_Serial.Init.StopBits			= UART_STOPBITS_1;
	h_Board_Serial.Init.Parity				= UART_PARITY_NONE;
	h_Board_Serial.Init.Mode				= UART_MODE_TX_RX;
	h_Board_Serial.Init.HwFlowCtl			= UART_HWCONTROL_NONE;
	h_Board_Serial.Init.OverSampling		= UART_OVERSAMPLING_16;
	h_Board_Serial.Init.OneBitSampling		= UART_ONE_BIT_SAMPLE_ENABLE;

	serialMode = SERIAL_CMD_MODE;

	HAL_UART_Init(&h_Board_Serial);

	HAL_NVIC_SetPriority(USART2_IRQn, 3, 0);
	HAL_NVIC_EnableIRQ(USART2_IRQn);
	
	memset(&serialRCV, NULL, sizeof(serialRCV));
	serialRCV.pData = (u8*)SDRAM_RX_BUFFER_ADRS;
	memset(serialRCV.pData, NULL, (256 * 1024));	// Init 256KB

	Serial_RxRecover();

	HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
}

void Serial_ExtInit(u32 baudrate)
{
	__HAL_RCC_USART6_CLK_ENABLE();

	serialRs485Mode = 0;
	
	hExtSerial.Instance					= USART6;
	hExtSerial.Init.BaudRate			= baudrate;
	hExtSerial.Init.WordLength			= UART_WORDLENGTH_8B;
	hExtSerial.Init.StopBits			= UART_STOPBITS_1;
	hExtSerial.Init.Parity				= UART_PARITY_NONE;
	hExtSerial.Init.Mode				= UART_MODE_TX_RX;
	hExtSerial.Init.HwFlowCtl			= UART_HWCONTROL_NONE;
	hExtSerial.Init.OverSampling		= UART_OVERSAMPLING_16;
	hExtSerial.Init.OneBitSampling		= UART_ONE_BIT_SAMPLE_ENABLE;

	serialMode = SERIAL_EXT_MODE;

	HAL_UART_Init(&hExtSerial);

	HAL_NVIC_SetPriority(USART6_IRQn, 3, 0);
	HAL_NVIC_EnableIRQ(USART6_IRQn);

	Ext_Serial_RxRecover();
}

void Serial_RS485DEnRECtrl(u8 state)
{
	state &= 0x01;

	HAL_GPIO_WritePin(GPIOG, GPIO_PIN_12, (GPIO_PinState)state);
}

u8 Serial_Printf(const char *pData, ...)
{
	va_list	ap;
	char	string[SERIAL_TRX_PACKET_SIZE];
	u16		length;
	
	memset(string, NULL, SERIAL_TRX_PACKET_SIZE);

	va_start(ap, pData);

	length = vsprintf(string, pData, ap);

//	length = strlen(string);

	va_end(ap);

	if(serialRs485Mode)
	{
		Serial_RS485DEnRECtrl(HIGH);

		HAL_Delay(1);
	}

	HAL_UART_Transmit(&h_Board_Serial, (uint8_t*)string, length, 1000);

	if(serialRs485Mode)
	{
		HAL_Delay(1);

		Serial_RS485DEnRECtrl(LOW);
	}

	return 1;
}

u8 Ext_Serial_Printf(const char *pData, ...)
{
	va_list	ap;
	char	string[SERIAL_TRX_PACKET_SIZE];
	u16		length;

	memset(string, NULL, SERIAL_TRX_PACKET_SIZE);

	va_start(ap, pData);

	length = vsprintf(string, pData, ap);

//	length = strlen(string);

	va_end(ap);

	HAL_UART_Transmit(&hExtSerial, (uint8_t*)string, length, 1000);

	return 1;
}

u8 Serial_TxData(u8 *pData, u16 length)
{
	if(serialRs485Mode)
	{
		Serial_RS485DEnRECtrl(HIGH);

		HAL_Delay(1);
	}

	HAL_UART_Transmit(&h_Board_Serial, (uint8_t*)pData, length, 1000);

	if(serialRs485Mode)
	{
		HAL_Delay(1);

		Serial_RS485DEnRECtrl(LOW);
	}

	return 1;
}

u8 Ext_Serial_TxData(u8 *pData, u16 length)
{
	HAL_UART_Transmit(&hExtSerial, (uint8_t*)pData, length, 1000);

	return 1;
}

void Serial_RxRecover()
{
//	memset(serialRxData, NULL, SERIAL_TRX_PACKET_SIZE);
	serialRxCnt = 0;
	serialRxFlag = 0;

	HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
}

void Ext_Serial_RxRecover()
{
//	memset(ExtserialRxData, NULL, SERIAL_TRX_PACKET_SIZE);
	ExtSerialRxCnt = 0;
	ExtSerialRxFlag = 0;
	
//	HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
}

void Serial_CmdMode()
{
	serialMode = SERIAL_CMD_MODE;

	Serial_RxRecover();
}

void Serial_ExtMode()
{
	serialMode = SERIAL_EXT_MODE;

	Ext_Serial_RxRecover();
}

u16 Serial_ExtDataCheck()
{
	u16	size;

	TRACE("Serial_ExtDataCheck: not implemented. \r\n");

	return size;
}

u16 Serial_ExtDataOut(u8 *pData)
{
	u16 rxCnt = 0;

	TRACE("Serial_ExtDataOut : not implemented. \r\n");

	return rxCnt;
}

u8 Serial_CommandProcess()
{
	u8	result = 0;
	u8	*pData, *findPos;
	u32	size;

	if(serialMode == SERIAL_EXT_MODE)	return result;

	if(serialRCV.time < 2)				return result;

	if(serialRCV.startPos < serialRCV.rcvPos)
	{
		pData = (u8*)&serialRCV.pData[serialRCV.startPos];

		findPos = (u8*)strstr((char*)pData, "\r");

		if(findPos != NULL)
		{
			size = (u32)findPos - (u32)pData;
	
			if(size < 2048)
			{
				memcpy(serialRxData, pData, size);
				serialRxCnt = (u32)size;
			}
			else
			{
				memcpy(serialRxData, pData, 2048);
				serialRxCnt = 2048;
			}
	
			memset(pData, NULL, (size + 1));
	
			serialRxFlag = 1;
	
			serialRCV.startPos = 0;
			serialRCV.rcvPos = 0;
			result = 1;
		}
		else 
		{
			result = 0;
		}
	}
	else		// serialRCV.startPos == serialRCV.rcvPos
	{
		if(serialRCV.startPos == serialRCV.rcvPos)	
		{
			if((serialRCV.startPos != 0) && (serialRCV.rcvPos != 0))
			{
				serialRCV.startPos = 0;
				serialRCV.rcvPos = 0;
			}
		}
	}

	HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
	return result;
}

u8 Serial_FileDownload(u32 dstAdrs, u32 *pRcvSize)
{
	u8	result = 0;
	u8	*pData, *findPos;
	u32	size;

	if(serialMode == SERIAL_EXT_MODE)	return result;

	if(serialRCV.time < 2)				return result;

	if(serialRCV.startPos < serialRCV.rcvPos)
	{
		pData = (u8*)&serialRCV.pData[serialRCV.startPos];

		findPos = (u8*)strstr((char*)pData, "\r");

		if(findPos == NULL)
		{
			HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
			return result;
		}

		size = (u32)findPos - (u32)pData;

		if(size < 2048)
		{
			memcpy(serialRxData, pData, size);
			serialRxCnt = (u32)size;
		}
		else
		{
			memcpy(serialRxData, pData, 2048);
			serialRxCnt = 2048;
		}

		memset(pData, NULL, (size + 1));

		serialRxFlag = 1;

		serialRCV.startPos += (size + 1);

		do{
			if(serialRCV.pData[serialRCV.startPos] == '\r')
			{
				serialRCV.pData[serialRCV.startPos] = NULL;
				(serialRCV.startPos) += 1;
			}
			else if(serialRCV.pData[serialRCV.startPos] == '\n')
			{
				serialRCV.pData[serialRCV.startPos] = NULL;
				(serialRCV.startPos) += 1;
			}
			else
			{
				break;
			}
		}while(1);
/*
		if(serialRCV.startPos == serialRCV.rcvPos)
		{
			serialRCV.startPos = 0;
			serialRCV.rcvPos = 0;
		}
*/
		HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);

		result = 1;
	}
	else		// serialRCV.startPos == serialRCV.rcvPos
	{
		if(serialRCV.startPos != serialRCV.rcvPos)	
		{
			HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
			return result;
		}

		if((serialRCV.startPos != 0) && (serialRCV.rcvPos != 0))
		{
			serialRCV.startPos = 0;
			serialRCV.rcvPos = 0;
		}
		
		HAL_UART_Receive_IT(&h_Board_Serial, &serialRxTemp, 1);
	}

	return result;
}
