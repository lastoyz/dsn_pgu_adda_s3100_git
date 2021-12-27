#ifndef	_APP_BOARDTEST_H
#define	_APP_BOARDTEST_H

#include 	"top_core_info.h"

typedef	struct{
	u8	errCnt;
	u8	errHistory[32];
}bTest32BitIO_t;

void BTest_Enable();
void BTest_Disable();
u8 BTest_Check();
u8 BTest_SDRAM();

#endif	// _APP_BOARDTEST_H
