#ifndef	_APP_TIMER_H
#define	_APP_TIMER_H

#include 	"top_core_info.h"

extern	TIM_HandleTypeDef	hTimer3;

void Timer3_Init();
void Timer3_Deinit();
void Timer3_Start();
void Timer3_Stop();
void Timer3_TickClear();
void Timer3_TickCount();
u32 Timer3_GetTick();
void Timer3_Delay(u32 cnt);

#endif	// _APP_TIMER_H
