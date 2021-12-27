#include	"main.h"
//#include 	"socket.h" 

//static u8 systemReset = 1;
u8 systemReset = 0;
CInterfaceApp Interface;

u32 SYS_HCLK_FREQ;

#if 0
// SMU & OST Initialize
extern "C" void sys_init(void);

typedef void (*pfunc) (void);
extern pfunc __CTOR_LIST__[];
extern pfunc __CTOR_END__[];

void invoke_constructors(void)
{
	int k = 0;
	pfunc *p;

	TRACE("Invoke C++ constructors ...\n");
	for (p = &__CTOR_END__[-1]; p >= __CTOR_LIST__; p--) {
		k++;
		(*p) ();
	}
}
 
#endif

void main()
{
	Init_System();

	GPIO_LedCtrl(0, LED_ON);
	GPIO_LedCtrl(1, LED_OFF);

//	invoke_constructors();
	
	TRACE("\r\n");
	TRACE("#############################################\r\n");
	TRACE("# [TOP ENGINEERING] S3100 STA\r\n");
	TRACE("#  F/W   : S3100 STA Firmware v1.3\r\n");
	TRACE("#  FID 	: S3100 STA FID 0x%X\r\n", fpgaVersion);
	TRACE("#  Build : %s %s\r\n", __DATE__, __TIME__);
	TRACE("#############################################\r\n");

	Interface.Create(0);

	Interface.Do();
}
