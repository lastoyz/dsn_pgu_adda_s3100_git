#include	"App_EXTI.h"

static	u8	extiEnable[16];
static	u8	extiChkr[7];

void EXTI_InterruptConfig()
{
	// External Interrupt 0 (GPIO_PIN_0)
	if((extiChkr[0] == 0) && (extiEnable[0] != 0))
	{
		HAL_NVIC_SetPriority(EXTI0_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI0_IRQn);

		extiChkr[0] = 0x01;
	}
	else if((extiChkr[0] != 0) && (extiEnable[0] == 0))
	{
		HAL_NVIC_DisableIRQ(EXTI0_IRQn);

		extiChkr[0] = 0x00;
	}

	// External Interrupt 1 (GPIO_PIN_1)
	if((extiChkr[1] == 0) && (extiEnable[1] != 0))
	{
		HAL_NVIC_SetPriority(EXTI1_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI1_IRQn);

		extiChkr[1] = 0x01;
	}
	else if((extiChkr[1] != 0) && (extiEnable[1] == 0))
	{
		HAL_NVIC_DisableIRQ(EXTI1_IRQn);

		extiChkr[1] = 0x00;
	}

	// External Interrupt 2 (GPIO_PIN_2)
	if((extiChkr[2] == 0) && (extiEnable[2] != 0))
	{
		HAL_NVIC_SetPriority(EXTI2_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI2_IRQn);

		extiChkr[2] = 0x01;
	}
	else if((extiChkr[2] != 0) && (extiEnable[2] == 0))
	{
		HAL_NVIC_DisableIRQ(EXTI2_IRQn);

		extiChkr[2] = 0x00;
	}

	// External Interrupt 3 (GPIO_PIN_3)
	if((extiChkr[3] == 0) && (extiEnable[3] != 0))
	{
		HAL_NVIC_SetPriority(EXTI3_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI3_IRQn);

		extiChkr[3] = 0x01;
	}
	else if((extiChkr[3] != 0) && (extiEnable[3] == 0))
	{
		HAL_NVIC_DisableIRQ(EXTI3_IRQn);

		extiChkr[3] = 0x00;
	}

	// External Interrupt 4 (GPIO_PIN_4)
	if((extiChkr[4] == 0) && (extiEnable[4] != 0))
	{
		HAL_NVIC_SetPriority(EXTI4_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI4_IRQn);

		extiChkr[4] = 0x01;
	}
	else if((extiChkr[4] != 0) && (extiEnable[4] == 0))
	{
		HAL_NVIC_DisableIRQ(EXTI4_IRQn);

		extiChkr[4] = 0x00;
	}

	// External Interrupt 5 - 9 (GPIO_PIN_5, GPIO_PIN_6, GPIO_PIN_7, GPIO_PIN_8, GPIO_PIN_9)
	if((extiChkr[5] == 0) && ((extiEnable[5] != 0) ||
								(extiEnable[6] != 0) ||
								(extiEnable[7] != 0) ||
								(extiEnable[8] != 0) ||
								(extiEnable[9] != 0)))
	{
		HAL_NVIC_SetPriority(EXTI9_5_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI9_5_IRQn);

		extiChkr[5] = 0x01;
	}
	else if((extiChkr[5] != 0) && ((extiEnable[5] == 0) &&
									(extiEnable[6] == 0) &&
									(extiEnable[7] == 0) &&
									(extiEnable[8] == 0) &&
									(extiEnable[9] == 0)))
	{
		HAL_NVIC_DisableIRQ(EXTI9_5_IRQn);

		extiChkr[5] = 0x00;
	}

	// External Interrupt 10 - 15 (GPIO_PIN_10, GPIO_PIN_11, GPIO_PIN_12, GPIO_PIN_13, GPIO_PIN_14, GPIO_PIN_15)
	if((extiChkr[6] == 0) && ((extiEnable[10] != 0) ||
								(extiEnable[11] != 0) ||
								(extiEnable[12] != 0) ||
								(extiEnable[13] != 0) ||
								(extiEnable[14] != 0) ||
								(extiEnable[15] != 0)))
	{
		HAL_NVIC_SetPriority(EXTI15_10_IRQn, 5, 0);
		HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);

		extiChkr[6] = 0x01;
	}
	else if((extiChkr[6] != 0) && ((extiEnable[10] == 0) &&
									(extiEnable[11] == 0) &&
									(extiEnable[12] == 0) &&
									(extiEnable[13] == 0) &&
									(extiEnable[14] == 0) &&
									(extiEnable[15] == 0)))
	{
		HAL_NVIC_DisableIRQ(EXTI15_10_IRQn);

		extiChkr[6] = 0x00;
	}
}

void EXTI_InterruptEnable(u8 position)
{
	if(position >= 16)	return;

	extiEnable[position] = 0x01;

	EXTI_InterruptConfig();
}

void EXTI_InterruptDisable(u8 position)
{
	if(position >= 16)	return;

	extiEnable[position] = 0x00;

	EXTI_InterruptConfig();
}

void EXTI_InterruptInit()
{
	for(u8 cnt = 0; cnt < 16; cnt++)
	{
		EXTI_InterruptDisable(cnt);
	}
}

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	switch(GPIO_Pin)
	{
	case GPIO_PIN_0:
		break;

	case GPIO_PIN_1:
		break;

	case GPIO_PIN_2:
		break;

	case GPIO_PIN_3:
		break;

	case GPIO_PIN_4:
		break;

	case GPIO_PIN_5:
		break;

	case GPIO_PIN_6:
		break;

	case GPIO_PIN_7:
		w5300_irq_handler();

		networkIntFlag = 1;
		break;

	default:
		break;
	}
}

