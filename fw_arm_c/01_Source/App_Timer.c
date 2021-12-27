#include	"App_Timer.h"

TIM_HandleTypeDef	hTimer3;

static u32	tim3Tick;

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef * htim)
{
	if(htim->Instance == TIM3)
	{
		tim3Tick++;
	}
}

void Timer3_Init()					// 5uS/interrupt
{
	hTimer3.Instance				= TIM3;

	hTimer3.Init.Prescaler			= ((SystemCoreClock / 2) / 1000000) - 1;
	hTimer3.Init.CounterMode		= TIM_COUNTERMODE_UP;
	hTimer3.Init.Period				= 5 - 1;
	hTimer3.Init.ClockDivision		= TIM_CLOCKDIVISION_DIV1;
	hTimer3.Init.RepetitionCounter	= 0;
	hTimer3.Init.AutoReloadPreload	= TIM_AUTORELOAD_PRELOAD_DISABLE;

	__HAL_RCC_TIM3_CLK_ENABLE();

	HAL_TIM_Base_Init(&hTimer3);

	HAL_NVIC_SetPriority(TIM3_IRQn, 5, 0);
	HAL_NVIC_EnableIRQ(TIM3_IRQn);
}

void Timer3_Deinit()
{
	hTimer3.Instance	= TIM3;

	HAL_TIM_Base_DeInit(&hTimer3);

	HAL_NVIC_DisableIRQ(TIM3_IRQn);

	__HAL_RCC_TIM3_CLK_DISABLE();
}

void Timer3_Start()
{
	HAL_TIM_Base_Start_IT(&hTimer3);
}

void Timer3_Stop()
{
	HAL_TIM_Base_Start_IT(&hTimer3);
}

void Timer3_TickClear()
{
	tim3Tick = 0;
}

void Timer3_TickCount()
{
	tim3Tick++;
}

u32 Timer3_GetTick()
{
	return tim3Tick;
}

void Timer3_Delay(u32 cnt)
{
	u32	sTick, rTick;

	sTick = Timer3_GetTick();

	do{
		rTick = Timer3_GetTick();
	}while((rTick - sTick) < cnt);
}

