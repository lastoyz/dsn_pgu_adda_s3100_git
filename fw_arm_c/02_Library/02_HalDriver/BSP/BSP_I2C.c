#include	"BSP_I2C.h"

I2C_HandleTypeDef	hI2C1, hI2C2, hI2C4;

void HAL_I2C_MspInit(I2C_HandleTypeDef *hi2c)
{
	GPIO_InitTypeDef	gpio;

/*
	IO Map

	EEPROM_I2C_SCL			: PB6
	EEPROM_I2C_SDA			: PB7
	LCD_I2C0_SCL			: PB8
	LCD_I2C0_SDA			: PB9
	LCD_I2C1_SCL			: PH4
	LCD_I2C1_SDA			: PB11

	LCD_I2C0_ATTN			: PB0
	LCD_I2C1_ATTN			: PB2
*/

	gpio.Mode		=	GPIO_MODE_AF_OD;
	gpio.Pull		=	GPIO_NOPULL;
	gpio.Speed		=	GPIO_SPEED_HIGH;

	if(hi2c->Instance == I2C1)
	{
		gpio.Alternate	=	GPIO_AF4_I2C1;

		gpio.Pin		=	GPIO_PIN_6;		// EEPROM_I2C_SCL		: PB6
		gpio.Pin		|=	GPIO_PIN_7;		// EEPROM_I2C_SDA		: PB7

		HAL_GPIO_Init(GPIOB, &gpio);
	}
	else if(hi2c->Instance == I2C2)
	{
		gpio.Alternate	=	GPIO_AF4_I2C2;

		gpio.Pin		=	GPIO_PIN_4;		// LCD_I2C1_SCL		: PH4

		HAL_GPIO_Init(GPIOH, &gpio);

		gpio.Pin		=	GPIO_PIN_11;	// LCD_I2C1_SDA		: PB11

		HAL_GPIO_Init(GPIOB, &gpio);
	}
	else if(hi2c->Instance == I2C4)
	{
		gpio.Alternate	=	GPIO_AF1_I2C4;

		gpio.Pin		=	GPIO_PIN_8;		// LCD_I2C0_SCL		: PB8
		gpio.Pin		|=	GPIO_PIN_9;		// LCD_I2C0_SDA		: PB9

		HAL_GPIO_Init(GPIOB, &gpio);
	}

	if(hi2c->Instance == I2C2)
	{
		gpio.Mode		=	GPIO_MODE_INPUT;
		gpio.Pull		=	GPIO_PULLUP;
		gpio.Speed		=	GPIO_SPEED_HIGH;

		gpio.Alternate	=	0;

		gpio.Pin		=	GPIO_PIN_2;		// LCD_I2C1_ATTN		: PB2

		HAL_GPIO_Init(GPIOB, &gpio);
	}
	else if(hi2c->Instance == I2C4)
	{
		gpio.Mode		=	GPIO_MODE_INPUT;
		gpio.Pull		=	GPIO_PULLUP;
		gpio.Speed		=	GPIO_SPEED_HIGH;

		gpio.Alternate	=	0;

		gpio.Pin		=	GPIO_PIN_0;		// LCD_I2C0_ATTN		: PB0

		HAL_GPIO_Init(GPIOB, &gpio);
	}
}

void HAL_I2C_MspDeInit(I2C_HandleTypeDef *hi2c)
{
	GPIO_InitTypeDef	gpio;

/*
	IO Map

	EEPROM_I2C_SCL			: PB6
	EEPROM_I2C_SDA			: PB7
	LCD_I2C0_SCL			: PB8
	LCD_I2C0_SDA			: PB9
	LCD_I2C1_SCL			: PH4
	LCD_I2C1_SDA			: PB11

	LCD_I2C0_ATTN			: PB0
	LCD_I2C1_ATTN			: PB2
*/

	gpio.Mode		=	GPIO_MODE_OUTPUT_OD;
	gpio.Pull		=	GPIO_NOPULL;
	gpio.Speed		=	GPIO_SPEED_HIGH; 

	if(hi2c->Instance == I2C1)
	{ 
		gpio.Pin		=	GPIO_PIN_6;		// EEPROM_I2C_SCL		: PB6
		gpio.Pin		|=	GPIO_PIN_7;		// EEPROM_I2C_SDA		: PB7

		HAL_GPIO_Init(GPIOB, &gpio);

		HAL_GPIO_WritePin(GPIOB, gpio.Pin, GPIO_PIN_RESET);
	}
	else if(hi2c->Instance == I2C2)
	{ 
		gpio.Pin		=	GPIO_PIN_4;		// LCD_I2C1_SCL		: PH4

		HAL_GPIO_Init(GPIOH, &gpio);

		HAL_GPIO_WritePin(GPIOH, gpio.Pin, GPIO_PIN_RESET);

		gpio.Pin		=	GPIO_PIN_11;	// LCD_I2C1_SDA		: PB11

		HAL_GPIO_Init(GPIOB, &gpio);

		HAL_GPIO_WritePin(GPIOB, gpio.Pin, GPIO_PIN_RESET);
	}
	else if(hi2c->Instance == I2C4)
	{ 
		gpio.Pin		=	GPIO_PIN_8;		// LCD_I2C0_SCL		: PB8
		gpio.Pin		|=	GPIO_PIN_9;		// LCD_I2C0_SDA		: PB9

		HAL_GPIO_Init(GPIOB, &gpio);

		HAL_GPIO_WritePin(GPIOB, gpio.Pin, GPIO_PIN_RESET);
	}

	if(hi2c->Instance == I2C2)
	{
		gpio.Mode		=	GPIO_MODE_INPUT;
		gpio.Pull		=	GPIO_PULLUP;
		gpio.Speed		=	GPIO_SPEED_HIGH;

		gpio.Alternate	=	0;

		gpio.Pin		=	GPIO_PIN_2;		// LCD_I2C1_ATTN		: PB2

		HAL_GPIO_Init(GPIOB, &gpio);
	}
	else if(hi2c->Instance == I2C4)
	{
		gpio.Mode		=	GPIO_MODE_INPUT;
		gpio.Pull		=	GPIO_PULLUP;
		gpio.Speed		=	GPIO_SPEED_HIGH;

		gpio.Alternate	=	0;

		gpio.Pin		=	GPIO_PIN_0;		// LCD_I2C0_ATTN		: PB0

		HAL_GPIO_Init(GPIOB, &gpio);
	}
}

void BSP_I2C1_Init()
{
	__HAL_RCC_I2C1_CLK_ENABLE();

/*
	BAUDRATE : 100KHz
*/

	hI2C1.Instance					= I2C1;
	hI2C1.Init.Timing				= 0x20404768;
	hI2C1.Init.OwnAddress1			= 0x00;
	hI2C1.Init.AddressingMode		= I2C_ADDRESSINGMODE_7BIT;
	hI2C1.Init.DualAddressMode		= I2C_DUALADDRESS_DISABLE;
	hI2C1.Init.OwnAddress2			= 0x00;
	hI2C1.Init.OwnAddress2Masks		= I2C_OA2_NOMASK;
	hI2C1.Init.GeneralCallMode		= I2C_GENERALCALL_DISABLE;
	hI2C1.Init.NoStretchMode		= I2C_NOSTRETCH_ENABLE;

	HAL_I2C_Init(&hI2C1);

	HAL_I2CEx_ConfigAnalogFilter(&hI2C1, I2C_ANALOGFILTER_ENABLE);
}

void BSP_I2C1_Deinit()
{
	hI2C1.Instance					= I2C1;

	HAL_I2C_DeInit(&hI2C1);

	__HAL_RCC_I2C1_CLK_DISABLE();
}

void BSP_I2C2_Init()
{
	__HAL_RCC_I2C2_CLK_ENABLE();

/*
	BAUDRATE : 100KHz
*/

	hI2C2.Instance					= I2C2;
	hI2C2.Init.Timing				= 0x20404768;
	hI2C2.Init.OwnAddress1			= 0x00;
	hI2C2.Init.AddressingMode		= I2C_ADDRESSINGMODE_7BIT;
	hI2C2.Init.DualAddressMode		= I2C_DUALADDRESS_DISABLE;
	hI2C2.Init.OwnAddress2			= 0x00;
	hI2C2.Init.OwnAddress2Masks		= I2C_OA2_NOMASK;
	hI2C2.Init.GeneralCallMode		= I2C_GENERALCALL_DISABLE;
	hI2C2.Init.NoStretchMode		= I2C_NOSTRETCH_ENABLE;

	HAL_I2C_Init(&hI2C2);

	HAL_I2CEx_ConfigAnalogFilter(&hI2C2, I2C_ANALOGFILTER_ENABLE);
}

void BSP_I2C2_Deinit()
{
	hI2C2.Instance					= I2C2;

	HAL_I2C_DeInit(&hI2C2);

	__HAL_RCC_I2C2_CLK_DISABLE();
}

void BSP_I2C4_Init()
{
	__HAL_RCC_I2C4_CLK_ENABLE();

/*
	BAUDRATE : 100KHz
*/

	hI2C4.Instance					= I2C4;
	hI2C4.Init.Timing				= 0x20404768;
	hI2C4.Init.OwnAddress1			= 0x00;
	hI2C4.Init.AddressingMode		= I2C_ADDRESSINGMODE_7BIT;
	hI2C4.Init.DualAddressMode		= I2C_DUALADDRESS_DISABLE;
	hI2C4.Init.OwnAddress2			= 0x00;
	hI2C4.Init.OwnAddress2Masks		= I2C_OA2_NOMASK;
	hI2C4.Init.GeneralCallMode		= I2C_GENERALCALL_DISABLE;
	hI2C4.Init.NoStretchMode		= I2C_NOSTRETCH_ENABLE;

	HAL_I2C_Init(&hI2C4);

	HAL_I2CEx_ConfigAnalogFilter(&hI2C4, I2C_ANALOGFILTER_ENABLE);
}

void BSP_I2C4_Deinit()
{
	hI2C4.Instance					= I2C4;

	HAL_I2C_DeInit(&hI2C4);

	__HAL_RCC_I2C4_CLK_DISABLE();
}

void I2C_Init(I2C_HandleTypeDef *pHandle)
{
	if(pHandle == &hI2C1)
	{
		BSP_I2C1_Init();
	}
	else if(pHandle == &hI2C2)
	{
		BSP_I2C2_Init();
	}
	else if(pHandle == &hI2C4)
	{
		BSP_I2C4_Init();
	}
}

void I2C_Deinit(I2C_HandleTypeDef *pHandle)
{
	if(pHandle == &hI2C1)
	{
		BSP_I2C1_Deinit();
	}
	else if(pHandle == &hI2C2)
	{
		BSP_I2C2_Deinit();
	}
	else if(pHandle == &hI2C4)
	{
		BSP_I2C4_Deinit();
	}
}
