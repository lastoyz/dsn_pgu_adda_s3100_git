#include	"App_Initialize.h"

u8	sysConfig_Init;

void Init_MCU()
{
	MCU_Init();

	System_ErrorInit();

	memset(sysConfig.u8Data, NULL, sizeof(sysConfig));
}

void Init_GPIO()
{
	FPGA_GpioInit();		// 

	GPIO_LedInit();		// smkim ok

	GPIO_NandWpInit();	// sbcho
	GPIO_NandWpCtrl(NAND_WP_LOW);
	

	GPIO_EXTI_Init();	// EXTI Interrupt for W5300
}

void Init_Memory()
{
	// EEPROM Init
	EEP_Init();

	// SDRAM, NAND, FPGA Init
	BSP_FMC_Init();

//	hMicroSD1.Instance = SDMMC1;
//	hMicroSD2.Instance = SDMMC2;

//	FatFS_DriverInit();
//	FatFS_DriveMount(0x01);	// 0x01 : nand, 0x02 : sd

	/* External NAND Flash initialize driver */
	Init_Driver();
}

void Init_SystemConfig()
{
	u8	chkr;
	u8	retryCnt = 0;

	memset(&sysLock, NULL, sizeof(sysLock));

	sysError.sysConfig = 0;

	HAL_Delay(10);

	do{
		System_SysConfigRead(&sysConfig);

		chkr = System_SysConfigCheck(&sysConfig);

		if(chkr)	break;

		retryCnt++;

//		EEP_Deinit();

//		HAL_Delay(200);

//		EEP_Init();
	}while(retryCnt < 3);

	if(chkr == 0)
	{
		System_ConfigDefaultSet(&sysConfig);

		sysError.sysConfig = 1;
	}

//	EEP_Deinit();

//	HAL_Delay(100);

//	EEP_Init();
}

void SPI_Init_FPGA()
{
	FPGA_SpiInit();
}

void Init_FPGA()
{
	FPGA_Reset();

	FPGA_Init();

	HAL_Delay(100);

	//FPGA_SpiInit();
}

void Init_SystemLog()
{
//	LOG_Init();

//	DBG_FileCheck();
//	LOG_FileCheck();
}

void Init_SystemLoad()
{
	// todo

}

void Init_SystemCheck()
{
	// 1 FPGA CHECK
	FPGA_Check();
}

void Init_Communication()
{
	
	CMD_Init();
	
//	Serial_ExtInit(115200 * 8);		// NE4 crash

	Serial_Init();

	Network_Init();	
}

void Init_System()
{
	Init_MCU();
	
	Init_GPIO();

	HAL_Delay(100); 
    //HAL_Delay(1000);            // FPGA configuration delay

//		Init_FPGA();
	SPI_Init_FPGA();

	HAL_Delay(100); 

	DWT_Delay_Init();			// us Delay Init(Using CoreSight Debugging Unit)
	DWT_Delay_us(1);

	Init_Memory();

	HAL_Delay(300); 
    HAL_Delay(1000);            // FMC memory init delay

	Init_FPGA();

	HAL_Delay(1500);

	Init_SystemConfig();
	
	Init_SystemLog();

	Init_SystemLoad();

	Init_Communication();

	Init_SystemCheck();
    
    HAL_Delay(1000);            // FPGA configuration delay

	FPGA_SpiLogicReset();

	Serial_Printf(">>System Boot.\r\n");
	Ext_Serial_Printf(">>System Boot.\r\n");

	GPIO_LedClear();
}

