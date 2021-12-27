#include "nand_hw_if.h"

static FMC_NAND_PCC_TimingTypeDef	nandTiming;

#ifdef ASYNC_MODE


/**
	Initialize HW NAND Controller.
	This function is called during driver initialization.
*/
void PLATFORM_Init()
{
	BSP_NAND_Init();
	BSP_NAND_Check();
}

/**
 	Open NAND device.
 	This function is called every time an I/O is performed.
*/
// void PLATFORM_Open(void)
// {
// 	/* Process Locked */
// 	__HAL_LOCK(&nandHandle); 
// }

HAL_StatusTypeDef PLATFORM_Open(void)
{
	/* Process Locked */
	__HAL_LOCK(&nandHandle);
	return HAL_OK;
}


/**
	NAND Command input.
	This function is used to send a command to NAND.
*/
void PLATFORM_SendCmd(bus_t ubCommand)
{
    *(__IO uint8_t *)((uint32_t)(NAND_DEVICE | CMD_AREA))  = ubCommand;
    __DSB();
}

/**
	NAND Address input.
	This function is used to send an address to NAND.
*/
void PLATFORM_SendAddr(bus_t ubAddress)
{
    *(__IO uint8_t *)((uint32_t)(NAND_DEVICE | ADDR_AREA)) = ubAddress;
    __DSB();
}

/**
	NAND Data input.
	This function is used to send data to NAND.
*/
void PLATFORM_SendData(bus_t data)
{
    *(__IO uint8_t *)NAND_DEVICE = data;
      __DSB();
}

/**
	NAND Data output.
	This function is used to read data from NAND.
*/
bus_t PLATFORM_ReadData(void)
{
    return *(uint8_t *)NAND_DEVICE;
}

/**
	NAND Write protect (set WP = L).
	This function is used to set Write Protect (WP) pin to LOW
*/
void PLATFORM_SetWriteProtect(void)
{
    
}

/**
	NAND Write protect (set WP = H).
	This function is used to set Write Protect (WP) pin to HIGH
*/
void PLATFORM_UnsetWriteProtect(void)
{
    
}

/**
	Wait for microseconds.
	This function should call a platform or OS wait() function.
*/
void PLATFORM_Wait(int microseconds)
{
    Delay_us(microseconds);
}

/**
	Close HW NAND Controller.
	This function is used to close the NAND HW controller in the right way.
*/
void PLATFORM_Close(void)
{
    /* Process unlocked */
	__HAL_UNLOCK(&nandHandle); 
}

#endif