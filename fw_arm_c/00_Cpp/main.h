#ifndef _MAIN_H
#define	_MAIN_H

#include 	"top_core_info.h"

#define IP_ADDR0   192
#define IP_ADDR1   168
#define IP_ADDR2   27
#define IP_ADDR3   210
   
/*NETMASK*/
#define NETMASK_ADDR0   255
#define NETMASK_ADDR1   255
#define NETMASK_ADDR2   255
#define NETMASK_ADDR3   0

/*Gateway Address*/
#define GW_ADDR0   192
#define GW_ADDR1   168
#define GW_ADDR2   27
#define GW_ADDR3   1

extern	u8 systemReset;
extern  u32 SYS_HCLK_FREQ;

#ifdef __cplusplus
extern "C" {
#endif
//void main();
#ifdef __cplusplus
}
#endif


#endif // !_MAIN_H
