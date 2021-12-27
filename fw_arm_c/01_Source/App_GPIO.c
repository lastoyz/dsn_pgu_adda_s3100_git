#include	"App_GPIO.h"

#define GPIO_MODE             ((uint32_t)0x00000003U)
#define EXTI_MODE             ((uint32_t)0x10000000U)
#define GPIO_MODE_IT          ((uint32_t)0x00010000U)
#define GPIO_MODE_EVT         ((uint32_t)0x00020000U)
#define RISING_EDGE           ((uint32_t)0x00100000U)
#define FALLING_EDGE          ((uint32_t)0x00200000U)
#define GPIO_OUTPUT_TYPE      ((uint32_t)0x00000010U)

#define GPIO_NUMBER           ((uint32_t)16U)

gpioLED_t		gpioLED;
gpioSwitch_t	gpioSwitch;
bitCtrl8_t		switchFlag;
// ioStatus_t		gpioTestSW;
ioStatus_t		gpioNandWp;


u8	swData;

u8	ledDisable = 0;

static void GPIO_SetIO(ioStatus_t *pData)
{
	GPIO_InitTypeDef	gpio;

	pData->value &= 0x01;

	if(pData->direction == IO_INPUT)
	{
		gpio.Pin		= pData->pin;
		gpio.Mode		= GPIO_MODE_INPUT;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;

		HAL_GPIO_Init(pData->port, &gpio);

		pData->value = HAL_GPIO_ReadPin(pData->port, pData->pin);
	}
	else if(pData->direction == IO_OUTPUT)
	{
		gpio.Pin		= pData->pin;
		gpio.Mode		= GPIO_MODE_OUTPUT_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;

		HAL_GPIO_Init(pData->port, &gpio);

		HAL_GPIO_WritePin(pData->port, pData->pin, (GPIO_PinState)pData->value);
	}
}

void GPIO_LedInit()
{
	u8 cnt = 0;

	/*
	IO Map

	MCU_LED_0		PB1		// OK
	MCU_LED_1		PB2		// BUSY
	*/

	cnt = 0;
	// LED_OK
	gpioLED.io[cnt].port		= GPIOB;
	gpioLED.io[cnt].pin		= GPIO_PIN_1;
	gpioLED.io[cnt].direction	= IO_OUTPUT;
	gpioLED.io[cnt].value		= LED_ON;
	cnt ++;

	// LED_BUSY
	gpioLED.io[cnt].port		= GPIOB;
	gpioLED.io[cnt].pin		= GPIO_PIN_2;
	gpioLED.io[cnt].direction	= IO_OUTPUT;
	gpioLED.io[cnt].value		= LED_ON;

	for(cnt = 0; cnt < GPIO_LED_CNT; cnt++)
	{
		GPIO_SetIO(&gpioLED.io[cnt]);
	}
}

void GPIO_LedCtrl(u8 position, u8 status)
{
	status &= 0x01;

	if(position >= GPIO_LED_CNT)	return;

	if(ledDisable)	status = 1;

	gpioLED.io[position].value = status;

	HAL_GPIO_WritePin(gpioLED.io[position].port, gpioLED.io[position].pin, (GPIO_PinState)gpioLED.io[position].value);
}

void GPIO_LedToggle(u8 position)
{
	if(position >= GPIO_LED_CNT)	return;

	if(gpioLED.io[position].value == 0)
	{
		gpioLED.io[position].value = 1;
	}
	else
	{
		gpioLED.io[position].value = 0;
	}

	if(ledDisable)	gpioLED.io[position].value = 1;

	HAL_GPIO_WritePin(gpioLED.io[position].port, gpioLED.io[position].pin, (GPIO_PinState)gpioLED.io[position].value);
}

void GPIO_LedRun()
{
	static u16 cnt;

	cnt++;

	if(cnt >= 500)
	{
		cnt -= 500;

		GPIO_LedToggle(0);
	}
}

void GPIO_LedClear()
{
	GPIO_LedCtrl(0, LED_OFF);
	GPIO_LedCtrl(1, LED_OFF);
}

// EXTI Interrupt for W5300
void GPIO_EXTI_Init()
{
	/// PIN
	//
	GPIO_InitTypeDef	gpio;

	gpio.Mode		=	GPIO_MODE_IT_FALLING;
	gpio.Pull		=	GPIO_PULLUP;
	gpio.Speed		=	GPIO_SPEED_HIGH;
	gpio.Alternate          =	0;

	gpio.Pin		=	GPIO_PIN_7;		//  PH7	 	ETH_nIRQ for W5300	// NVIC_EnableIRQ

	HAL_GPIO_Init(GPIOH, &gpio);

	EXTI_InterruptInit();
	EXTI_InterruptEnable(7);

}

void GPIO_NandWpInit()
{
	gpioNandWp.port = GPIOI;
	gpioNandWp.pin = GPIO_PIN_11;
	gpioNandWp.direction = IO_OUTPUT;
	gpioNandWp.value = 0;				// LOW is Protection

	GPIO_SetIO(&gpioNandWp);
}

void GPIO_NandWpCtrl(u8 status)
{
	status &= 0x01;
	gpioNandWp.value = status;
	
	HAL_GPIO_WritePin(gpioNandWp.port, gpioNandWp.pin, (GPIO_PinState)gpioNandWp.value);
}

