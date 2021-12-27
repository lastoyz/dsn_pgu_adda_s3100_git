#ifndef	_APP_EXTI_H
#define	_APP_EXTI_H

#include 	"top_core_info.h"

void EXTI_InterruptEnable(u8 position);
void EXTI_InterruptDisable(u8 position);
void EXTI_InterruptInit();

#endif	// _APP_EXTI_H
