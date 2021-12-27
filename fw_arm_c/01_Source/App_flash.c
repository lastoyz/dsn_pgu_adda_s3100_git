#include "App_flash.h"

extern uint32_t App_FWSize;
extern uint8_t* App_FWAddr;

/* USER CODE BEGIN 4 */
HAL_StatusTypeDef EraseFlash()
{
	uint32_t SectorError = 0;

	/* Unlock to control */
	HAL_FLASH_Unlock();

	/* Calculate sector index */
	uint32_t UserSector = GetSector(FLASH_USER_START_ADDR);
	uint32_t NbOfSectors = GetSector(FLASH_USER_END_ADDR) - UserSector + 1;

	/* Erase sectors */
	FLASH_EraseInitTypeDef EraseInitStruct;
	EraseInitStruct.TypeErase = FLASH_TYPEERASE_SECTORS;
	EraseInitStruct.VoltageRange = FLASH_VOLTAGE_RANGE_3;
	EraseInitStruct.Sector = UserSector;
	EraseInitStruct.NbSectors = NbOfSectors;

	if(HAL_FLASHEx_Erase(&EraseInitStruct, &SectorError) != HAL_OK)
	{ 
		uint32_t errorcode = HAL_FLASH_GetError();            
		return HAL_ERROR;
	}
#if 0
	/* Clear cache for flash */
	__HAL_FLASH_DATA_CACHE_DISABLE();
	__HAL_FLASH_INSTRUCTION_CACHE_DISABLE();

	__HAL_FLASH_DATA_CACHE_RESET();
	__HAL_FLASH_INSTRUCTION_CACHE_RESET();

	__HAL_FLASH_INSTRUCTION_CACHE_ENABLE();
	__HAL_FLASH_DATA_CACHE_ENABLE();

#endif
	/* Lock flash control register */
	HAL_FLASH_Lock();

	return HAL_OK;  
}

HAL_StatusTypeDef WriteFlash(uint32_t size)
{
	/* Unlock to control */
	HAL_FLASH_Unlock();

	uint32_t *sAddress =  (uint32_t*)SDRAM_FPGA_READ_ADRS;
	uint32_t Address = FLASH_USER_START_ADDR;
	uint32_t data = 0;

	while(Address < FLASH_USER_END_ADDR)
	{
		if (size > 0) {
			data = *sAddress;
			sAddress++;
			size = size - 4;
		} else {
			data = 0xFF;
		}
		/* Writing data to flash memory */
		if(HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, Address, data) == HAL_OK)
		{
			Address = Address + 4;
		}
		else
		{
			uint32_t errorcode = HAL_FLASH_GetError();
			return HAL_ERROR;
		}
	}

	/* Lock flash control register */
	HAL_FLASH_Lock();  

	return HAL_OK;
}

HAL_StatusTypeDef WriteFlashFW()
{
	/* Unlock to control */
	HAL_FLASH_Unlock();

	uint32_t Address = FLASH_USER_START_ADDR;
	uint32_t* pAppAddress = (uint32_t*)App_FWAddr;
	int size = App_FWSize;
	uint32_t data = 0;

	if (size < 1) {
		return  HAL_ERROR;
	}

	while(Address < FLASH_USER_END_ADDR)
	{
		if (size > 0) {
			data = *pAppAddress;
			pAppAddress++;
			size = size - 4;
		} else {
			data = 0;
		}
		/* Writing data to flash memory */
		if(HAL_FLASH_Program(FLASH_TYPEPROGRAM_WORD, Address, data) == HAL_OK)
		{
			Address = Address + 4;
		}
		else
		{
			uint32_t errorcode = HAL_FLASH_GetError();
			return HAL_ERROR;
		}
	}

	/* Lock flash control register */
	HAL_FLASH_Lock();  

	return HAL_OK;
}

HAL_StatusTypeDef ReadFlash()
{
	__IO uint32_t data32 = 0 , MemoryProgramStatus = 0;
	uint32_t Address = FLASH_USER_START_ADDR;

	while(Address < FLASH_USER_END_ADDR)
	{
		data32 = *(__IO uint32_t*)Address;

		if(data32 != DATA_32)
			MemoryProgramStatus++;

		Address = Address + 4;
	}

	if(MemoryProgramStatus > 0)
		return HAL_ERROR;

	return HAL_OK;
}

HAL_StatusTypeDef ReadFlash_buf(uint32_t *buff, uint32_t size)
{
	__IO uint32_t data32 = 0;
	uint32_t Address = FLASH_USER_START_ADDR;
	uint32_t rdSize = FLASH_USER_START_ADDR + size;
	uint32_t buff_idx = 0;

	while(Address < rdSize)
	{
		buff[buff_idx++] = *(__IO uint32_t*)Address;	
		Address = Address + 4;
	}

	return HAL_OK;
}

uint32_t GetWriteProtect()
{
	FLASH_OBProgramInitTypeDef OBInit; 

	HAL_FLASHEx_OBGetConfig(&OBInit);
	uint32_t SectorsWRPStatus = OBInit.WRPSector & FLASH_WRP_SECTORS;

	return SectorsWRPStatus;
}

HAL_StatusTypeDef EnableWriteProtect()
{
	FLASH_OBProgramInitTypeDef OBInit; 

	HAL_FLASH_OB_Unlock();
	HAL_FLASH_Unlock();

	OBInit.OptionType = OPTIONBYTE_WRP;
	OBInit.WRPState   = OB_WRPSTATE_ENABLE;
//	OBInit.Banks      = FLASH_BANK_1;
	OBInit.WRPSector  = FLASH_WRP_SECTORS;
	HAL_FLASHEx_OBProgram(&OBInit);   

	if (HAL_FLASH_OB_Launch() != HAL_OK)
	{
		return HAL_ERROR;
	}

	HAL_FLASH_OB_Lock();  
	HAL_FLASH_Lock();  

	return HAL_OK;
}

HAL_StatusTypeDef DisableWriteProtect()
{
	FLASH_OBProgramInitTypeDef OBInit; 

	HAL_FLASH_OB_Unlock();
	HAL_FLASH_Unlock();

	OBInit.OptionType = OPTIONBYTE_WRP;
	OBInit.WRPState   = OB_WRPSTATE_DISABLE;
//	OBInit.Banks      = FLASH_BANK_1;
	OBInit.WRPSector  = FLASH_WRP_SECTORS;
	HAL_FLASHEx_OBProgram(&OBInit); 

	if (HAL_FLASH_OB_Launch() != HAL_OK)
	{
		return HAL_ERROR;
	}

	HAL_FLASH_OB_Lock();  
	HAL_FLASH_Lock();

	return HAL_OK;
}

uint32_t GetSector(uint32_t Address)
{
	uint32_t sector = 0;

	if((Address < ADDR_FLASH_SECTOR_1) && (Address >= ADDR_FLASH_SECTOR_0))
	{
		sector = FLASH_SECTOR_0;  
	}
	else if((Address < ADDR_FLASH_SECTOR_2) && (Address >= ADDR_FLASH_SECTOR_1))
	{
		sector = FLASH_SECTOR_1;  
	}
	else if((Address < ADDR_FLASH_SECTOR_3) && (Address >= ADDR_FLASH_SECTOR_2))
	{
		sector = FLASH_SECTOR_2;  
	}
	else if((Address < ADDR_FLASH_SECTOR_4) && (Address >= ADDR_FLASH_SECTOR_3))
	{
		sector = FLASH_SECTOR_3;  
	}
	else if((Address < ADDR_FLASH_SECTOR_5) && (Address >= ADDR_FLASH_SECTOR_4))
	{
		sector = FLASH_SECTOR_4;  
	}
	else if((Address < ADDR_FLASH_SECTOR_6) && (Address >= ADDR_FLASH_SECTOR_5))
	{
		sector = FLASH_SECTOR_5;  
	}
	else if((Address < ADDR_FLASH_SECTOR_7) && (Address >= ADDR_FLASH_SECTOR_6))
	{
		sector = FLASH_SECTOR_6;  
	}
	else if((Address < ADDR_FLASH_SECTOR_8) && (Address >= ADDR_FLASH_SECTOR_7))
	{
		sector = FLASH_SECTOR_7;  
	}
	else if((Address < ADDR_FLASH_SECTOR_9) && (Address >= ADDR_FLASH_SECTOR_8))
	{
		sector = FLASH_SECTOR_8;  
	}
	else if((Address < ADDR_FLASH_SECTOR_10) && (Address >= ADDR_FLASH_SECTOR_9))
	{
		sector = FLASH_SECTOR_9;  
	}
	else if((Address < ADDR_FLASH_SECTOR_11) && (Address >= ADDR_FLASH_SECTOR_10))
	{
		sector = FLASH_SECTOR_10;  
	}
	else /* (Address < FLASH_END_ADDR) && (Address >= ADDR_FLASH_SECTOR_11) */
	{
		sector = FLASH_SECTOR_11;
	}

	return sector;
}

uint32_t GetSectorSize(uint32_t Sector)
{
	uint32_t sectorsize = 0x00;

	if((Sector == FLASH_SECTOR_0) || (Sector == FLASH_SECTOR_1) || (Sector == FLASH_SECTOR_2) || (Sector == FLASH_SECTOR_3))
	{
		sectorsize = 16 * 1024;
	}
	else if(Sector == FLASH_SECTOR_4)
	{
		sectorsize = 64 * 1024;
	}
	else
	{
		sectorsize = 128 * 1024;
	}  
	return sectorsize;
}
