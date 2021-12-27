#include	"mcuClock.h"
//#include	"dwt_stm32_delay.h"

static void Error_Handler(void)
{
	while(1)
	{
	}
}

void MPU_Config()
{
	MPU_Region_InitTypeDef mpu;

	HAL_MPU_Disable();
/*
	// SRAM1, SRAM2
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0x20020000;
	mpu.Size						= MPU_REGION_SIZE_512KB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER0;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);
*/

	// SRAM2(Only Ethernet Buffer)
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0x2007C000;
	mpu.Size						= MPU_REGION_SIZE_16KB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER1;
	mpu.TypeExtField				= MPU_TEX_LEVEL1;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);

	// SRAM2(Only Ethernet Buffer, Discriptors)
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0x2007C000;
	mpu.Size						= MPU_REGION_SIZE_256B;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER2;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);

	// FMC BANK_1_2
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0x60000000;
	mpu.Size						= MPU_REGION_SIZE_512MB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_NOT_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER3;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);

	// FMC BANK_3_4
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0x80000000;
	mpu.Size						= MPU_REGION_SIZE_512MB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_NOT_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER4;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);

	// FMC BANK_5
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0xC0000000;
	mpu.Size						= MPU_REGION_SIZE_256MB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_NOT_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER5;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);

	// FMC BANK_6
	mpu.Enable						= MPU_REGION_ENABLE;
	mpu.BaseAddress					= 0xD0000000;
	mpu.Size						= MPU_REGION_SIZE_256MB;
	mpu.AccessPermission			= MPU_REGION_FULL_ACCESS;
	mpu.IsBufferable				= MPU_ACCESS_NOT_BUFFERABLE;
	mpu.IsCacheable					= MPU_ACCESS_NOT_CACHEABLE;
	mpu.IsShareable					= MPU_ACCESS_NOT_SHAREABLE;
	mpu.Number						= MPU_REGION_NUMBER6;
	mpu.TypeExtField				= MPU_TEX_LEVEL0;
	mpu.SubRegionDisable			= 0x00;
	mpu.DisableExec					= MPU_INSTRUCTION_ACCESS_ENABLE;

	HAL_MPU_ConfigRegion(&mpu);
	
	HAL_MPU_Enable(MPU_PRIVILEGED_DEFAULT);
}

void SystemClock_Config(void)
{
	RCC_OscInitTypeDef RCC_OscInitStruct;
	RCC_ClkInitTypeDef RCC_ClkInitStruct;
	RCC_PeriphCLKInitTypeDef PeriphClkInitStruct;

	__HAL_RCC_PWR_CLK_ENABLE();

	__HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

	RCC_OscInitStruct.OscillatorType		=	RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState				=	RCC_HSE_ON;
	RCC_OscInitStruct.LSEState				=	RCC_LSE_OFF;
	RCC_OscInitStruct.HSIState				=	RCC_HSI_OFF;
	RCC_OscInitStruct.HSICalibrationValue	=	RCC_HSICALIBRATION_DEFAULT;
	RCC_OscInitStruct.LSIState				=	RCC_LSI_OFF;
	RCC_OscInitStruct.PLL.PLLState			=	RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource			=	RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PLLM				=	25;
	RCC_OscInitStruct.PLL.PLLN				=	432;
	RCC_OscInitStruct.PLL.PLLP				=	RCC_PLLP_DIV2;
	RCC_OscInitStruct.PLL.PLLQ				=	9;
	
	// 25mhz / 25(M) * 432(N) / 2(DIV) = sysclk
	// 25mhz / 25(M) * 432(N) / 9(Q) = 48mhz


	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
	{
		Error_Handler();
	}

	if (HAL_PWREx_EnableOverDrive() != HAL_OK)
	{
		Error_Handler();
	}

	RCC_ClkInitStruct.ClockType			=	RCC_CLOCKTYPE_HCLK |
											RCC_CLOCKTYPE_SYSCLK |
											RCC_CLOCKTYPE_PCLK1 |
											RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource		=	RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider		=	RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider	=	RCC_HCLK_DIV4;
	RCC_ClkInitStruct.APB2CLKDivider	=	RCC_HCLK_DIV2;
	
	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_7) != HAL_OK)
	{
		Error_Handler();
	}

	PeriphClkInitStruct.PLLSAI.PLLSAIN			=	384;
	PeriphClkInitStruct.PLLSAI.PLLSAIQ			=	2;
	PeriphClkInitStruct.PLLSAI.PLLSAIR			=	2;
	PeriphClkInitStruct.PLLSAI.PLLSAIP			=	RCC_PLLSAIP_DIV8;
	PeriphClkInitStruct.PeriphClockSelection	=	RCC_PERIPHCLK_USART1 |
													RCC_PERIPHCLK_USART2 |
													RCC_PERIPHCLK_USART3 |
													RCC_PERIPHCLK_UART4 |
													RCC_PERIPHCLK_UART5 |
													RCC_PERIPHCLK_USART6 |
													RCC_PERIPHCLK_UART7 |
													RCC_PERIPHCLK_UART8 |
													RCC_PERIPHCLK_I2C1 |
													RCC_PERIPHCLK_I2C2 |
													RCC_PERIPHCLK_I2C3 |
													RCC_PERIPHCLK_I2C4 |
													RCC_PERIPHCLK_SDMMC1 |
													RCC_PERIPHCLK_SDMMC2 |
													RCC_PERIPHCLK_CLK48;
	PeriphClkInitStruct.Usart1ClockSelection	=	RCC_USART1CLKSOURCE_PCLK2;
	PeriphClkInitStruct.Usart2ClockSelection	=	RCC_USART2CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Usart3ClockSelection	=	RCC_USART3CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Uart4ClockSelection		=	RCC_UART4CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Uart5ClockSelection		=	RCC_UART5CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Usart6ClockSelection	=	RCC_USART6CLKSOURCE_PCLK2;
	PeriphClkInitStruct.Uart7ClockSelection		=	RCC_UART7CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Uart8ClockSelection		=	RCC_UART8CLKSOURCE_PCLK1;
	PeriphClkInitStruct.I2c1ClockSelection		=	RCC_I2C1CLKSOURCE_PCLK1;
	PeriphClkInitStruct.I2c2ClockSelection		=	RCC_I2C2CLKSOURCE_PCLK1;
	PeriphClkInitStruct.I2c3ClockSelection		=	RCC_I2C3CLKSOURCE_PCLK1;
	PeriphClkInitStruct.I2c4ClockSelection		=	RCC_I2C4CLKSOURCE_PCLK1;
	PeriphClkInitStruct.Clk48ClockSelection		=	RCC_CLK48SOURCE_PLLSAIP;
	PeriphClkInitStruct.Sdmmc1ClockSelection	=	RCC_SDMMC1CLKSOURCE_CLK48;
	PeriphClkInitStruct.Sdmmc2ClockSelection	=	RCC_SDMMC2CLKSOURCE_CLK48;
	
	if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
	{
		Error_Handler();
	}
}

void CPU_CacheEnable()
{
	SCB_EnableICache();

	SCB_EnableDCache();
}

void CPU_CacheDisable()
{
	SCB_DisableICache();

	SCB_DisableDCache();
}

void CPU_CacheClean()
{
	SCB_CleanDCache();
}

void MCU_Init()
{
	//CPU_CacheEnable();

	//CPU_CacheDisable();

	MPU_Config();

	SCB_InvalidateICache();	

	/* Enable branch prediction */
	SCB->CCR |= (1 <<18); 
	__DSB();

	SCB_InvalidateICache();
	SCB_EnableICache();

	SCB_InvalidateDCache();
	SCB_EnableDCache();

	
	SystemClock_Config();

	HAL_Init();

//		if(DWT_Delay_Init())
//	 	{
//		 	Error_Handler(); /* Call Error Handler */
//		}

	__HAL_RCC_GPIOA_CLK_ENABLE();
	__HAL_RCC_GPIOB_CLK_ENABLE();
	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_GPIOD_CLK_ENABLE();
	__HAL_RCC_GPIOE_CLK_ENABLE();
	__HAL_RCC_GPIOF_CLK_ENABLE();
	__HAL_RCC_GPIOG_CLK_ENABLE();
	__HAL_RCC_GPIOH_CLK_ENABLE();
	__HAL_RCC_GPIOI_CLK_ENABLE();
	__HAL_RCC_GPIOJ_CLK_ENABLE();
	__HAL_RCC_GPIOK_CLK_ENABLE();

	SYS_HCLK_FREQ = HAL_RCC_GetHCLKFreq() / 1000000;			// 216(MHz)

}
