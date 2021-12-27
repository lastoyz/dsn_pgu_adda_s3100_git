#ifndef	_APP_INITIALIZE_H
#define	_APP_INITIALIZE_H

#include 	"top_core_info.h"


#ifdef __cplusplus
extern "C" {
#endif


extern	u8	sysConfig_Init;

void INIT_Gpio();
void INIT_SystemConfig();
void INIT_Communication();
void INIT_SystemLog();

void Init_System();

#ifdef __cplusplus
}
#endif



#endif	// _APP_INITIALIZE_H
