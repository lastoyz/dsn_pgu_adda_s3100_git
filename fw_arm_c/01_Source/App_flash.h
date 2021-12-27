#ifndef	_APP_FLASH_H
#define	_APP_FLASH_H

#include	"top_core_info.h"

/* USER CODE BEGIN PV */
/* Private variables ---------------------------------------------------------*/
#define ADDR_FLASH_SECTOR_0     ((uint32_t)0x08000000) /* Base address of Sector 0, 32 Kbytes */
#define ADDR_FLASH_SECTOR_1     ((uint32_t)0x08008000) /* Base address of Sector 1, 32 Kbytes */
#define ADDR_FLASH_SECTOR_2     ((uint32_t)0x08010000) /* Base address of Sector 2, 32 Kbytes */
#define ADDR_FLASH_SECTOR_3     ((uint32_t)0x08018000) /* Base address of Sector 3, 32 Kbytes */
#define ADDR_FLASH_SECTOR_4     ((uint32_t)0x08020000) /* Base address of Sector 4, 128 Kbytes */
#define ADDR_FLASH_SECTOR_5     ((uint32_t)0x08040000) /* Base address of Sector 5, 256 Kbytes */
#define ADDR_FLASH_SECTOR_6     ((uint32_t)0x08080000) /* Base address of Sector 6, 256 Kbytes */
#define ADDR_FLASH_SECTOR_7     ((uint32_t)0x080C0000) /* Base address of Sector 7, 256 Kbytes */
#define ADDR_FLASH_SECTOR_8     ((uint32_t)0x08100000) /* Base address of Sector 8, 256 Kbytes */
#define ADDR_FLASH_SECTOR_9     ((uint32_t)0x08140000) /* Base address of Sector 9, 256 Kbytes */
#define ADDR_FLASH_SECTOR_10    ((uint32_t)0x08180000) /* Base address of Sector 10, 256 Kbytes */
#define ADDR_FLASH_SECTOR_11    ((uint32_t)0x081C0000) /* Base address of Sector 11, 256 Kbytes */

#define FLASH_WRP_SECTORS   (OB_WRP_SECTOR_10)

#define FLASH_USER_START_ADDR   ADDR_FLASH_SECTOR_10   /* Start @ of user Flash area */
#define FLASH_USER_END_ADDR     (ADDR_FLASH_SECTOR_11 - 1)

#define DATA_32                 ((uint32_t)0x12345678)

extern uint32_t App_FWSize;
extern uint8_t* App_FWAddr;

/* USER CODE END PV */

#ifdef __cplusplus
extern "C" {
#endif

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void Error_Handler(void);
static void MX_GPIO_Init(void);

HAL_StatusTypeDef EraseFlash(void);
HAL_StatusTypeDef WriteFlash(uint32_t data);
HAL_StatusTypeDef WriteFlashFW();
HAL_StatusTypeDef ReadFlash(void);
HAL_StatusTypeDef ReadFlash_buf(uint32_t *buff, uint32_t size);
uint32_t GetWriteProtect(void);
HAL_StatusTypeDef EnableWriteProtect(void);
HAL_StatusTypeDef DisableWriteProtect(void);
uint32_t GetSector(uint32_t Address);
uint32_t GetSectorSize(uint32_t Sector);

#ifdef __cplusplus
}
#endif

#endif	// _CMD_ICT_H
