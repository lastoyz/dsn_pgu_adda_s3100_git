#ifndef	_APP_EEPROM_H
#define	_APP_EEPROM_H

#include 	"top_core_info.h"

typedef	union{
	u8	data;
	__packed struct{
		u8	rw		:1;
		u8	blk		:3;
		u8	dev		:4;
	};
}eepDev_t;

void EEP_Init();
void EEP_Deinit();
u8 EEP_AdrsScan();
void EEP_Write(u16 adrs, u8 *pData, u16 length);
void EEP_Read(u16 adrs, u8 *pData, u16 length);
void EDID_Write(u8 *pData, u16 length);
void EDID_Read(u8 *pData, u16 length);

void AA_Write(u8 devAdrs, u8 regAdrs, u8 *pData, u16 length);
void AA_Read(u8 devAdrs, u8 regAdrs, u8 *pData, u16 length);


void eeprom_reset_fifo(u32 slot, u32 spi_sel);
u16 eeprom_write_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_datain);
void eeprom_write_enable(u32 slot, u32 spi_sel);
u16 eeprom_write_data_16B(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16);
u32 eeprom_send_frame (u32 slot, u32 spi_sel, u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);
u32 eeprom_send_frame_ep (u32 slot, u32 spi_sel, u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32);
void eeprom_write_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
void eeprom_write_data_u8(u32 slot, u32 spi_sel, u16 adrs, u8 data);
void write_data_1byte(u32 slot, u32 spi_sel, u16 adrs, u8 data);
void eeprom_write_data_u32(u32 slot, u32 spi_sel, u16 adrs, u32 data);
void eeprom_write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data);
void write_data_4byte(u32 slot, u32 spi_sel, u16 adrs, u32 data);
void write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data);

u32 eeprom__read__data_u32(u32 slot, u32 spi_sel, u16 adrs);
float eeprom__read__data_float(u32 slot, u32 spi_sel, u16 adrs);
u32 read__data_4byte(u32 slot, u32 spi_sel, u16 adrs);
float read__data_float(u32 slot, u32 spi_sel, u16 adrs);
u16 eeprom_read_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
u16 eeprom_read_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_dataout);
u32 eeprom_read_status(u32 slot, u32 spi_sel);














#endif	// _APP_EEPROM_H
