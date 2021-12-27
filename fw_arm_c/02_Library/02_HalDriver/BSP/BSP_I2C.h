#ifndef	_BSP_I2C_H
#define	_BSP_I2C_H

#include	"stm32f7xx_hal.h"

extern	I2C_HandleTypeDef	hI2C1, hI2C2, hI2C4;

void BSP_I2C1_Init();
void BSP_I2C1_Deinit();
void BSP_I2C2_Init();
void BSP_I2C2_Deinit();
void BSP_I2C4_Init();
void BSP_I2C4_Deinit();
void I2C_Init(I2C_HandleTypeDef *pHandle);
void I2C_Deinit(I2C_HandleTypeDef *pHandle);

#endif	// _BSP_I2C_H