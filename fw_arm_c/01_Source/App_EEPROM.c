#include	"App_EEPROM.h"

/*
	USE		: Microchip 24LC16B
	Adrs	: SoftAdrs = 0xa0
			  HardAdrs Not USE
*/

I2C_HandleTypeDef *hEEPI2C;

void EEP_Init()
{
	hEEPI2C = &hI2C1;
	BSP_I2C1_Init();
}

void EEP_Deinit()
{
	BSP_I2C1_Deinit();
}

void EEP_WriteDelay()
{
	// EEPROM Write Delay 10ms
	HAL_Delay(10);
}

u8 EEP_AdrsScan()
{
	u8 adrs = 0, devAdrs;
	u8 rtn;

	do{
		devAdrs = (adrs << 1) & 0xfe;
		
		rtn = HAL_I2C_IsDeviceReady(hEEPI2C, devAdrs, 2, 100);

		if(rtn == HAL_OK)	break;
		
		adrs++;
	}while(adrs != 0x80);
	
	return devAdrs;
}

void EEP_Write(u16 adrs, u8 *pData, u16 length)
{
	u16	remainCnt = length, cnt = 0;
	eepDev_t	devAdrs;

	do 
	{
		devAdrs.dev	= 0x0a;
		devAdrs.blk = (u8)(adrs >> 8);

		if(remainCnt > 16)
		{
			HAL_I2C_Mem_Write(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, &pData[cnt], 16, 1000);

			cnt += 16;
			adrs += 16;

			remainCnt -= 16;

			EEP_WriteDelay();
		}
		else
		{
			HAL_I2C_Mem_Write(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, &pData[cnt], remainCnt, 1000);

			cnt += remainCnt;
			adrs += remainCnt;

			remainCnt -= remainCnt;
		}
	}while(remainCnt > 0);
}

void EEP_Read(u16 adrs, u8 *pData, u16 length)
{
	eepDev_t	devAdrs;

	devAdrs.dev	= 0x0a;
	devAdrs.blk = (u8)(adrs >> 8);

	HAL_I2C_Mem_Read(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, pData, length, 1000);
}

void EEP_Clear()
{
	u8	buff[32];
	u16 cnt, remainCnt;
	
	memset(buff, NULL, sizeof(buff));

	cnt = 0;

	remainCnt = 2048;

	do{
		if(remainCnt > 16)
		{
			EEP_Write(cnt, buff, 16);

			cnt += 16;
			remainCnt -= 16;
		}
		else
		{
			EEP_Write(cnt, buff, remainCnt);

			cnt += remainCnt;

			remainCnt -= remainCnt;
		}
	}while(remainCnt > 0);
}

void EDID_Write(u8 *pData, u16 length)
{
	u16	adrs = 0, remainCnt = length, cnt = 0;
	eepDev_t	devAdrs;
	
	do{
		devAdrs.dev	= 0x0a;
		devAdrs.blk = 0;

		if(remainCnt > 16)
		{
			HAL_I2C_Mem_Write(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, &pData[cnt], 16, 1000);

			cnt += 16;
			adrs += 16;

			remainCnt -= 16;

			EEP_WriteDelay();
		}
		else
		{
			HAL_I2C_Mem_Write(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, &pData[cnt], remainCnt, 1000);

			cnt += remainCnt;
			adrs += remainCnt;

			remainCnt -= remainCnt;
		}
	}while(remainCnt > 0);

	EEP_WriteDelay();
}

void EDID_Read(u8 *pData, u16 length)
{
	u16	adrs = 0;
	eepDev_t	devAdrs;

	devAdrs.dev	= 0x0a;
	devAdrs.blk = 0;

	HAL_I2C_Mem_Read(hEEPI2C, (u8)devAdrs.data, (u8)adrs, I2C_MEMADD_SIZE_8BIT, pData, length, 1000);
}

void AA_Write(u8 devAdrs, u8 regAdrs, u8 *pData, u16 length)
{
	HAL_I2C_Mem_Write(hEEPI2C, devAdrs, regAdrs, I2C_MEMADD_SIZE_8BIT, pData, length, 1000);
}

void AA_Read(u8 devAdrs, u8 regAdrs, u8 *pData, u16 length)
{
	HAL_I2C_Mem_Read(hEEPI2C, devAdrs, regAdrs, I2C_MEMADD_SIZE_8BIT, pData, length, 1000);
}







void eeprom_reset_fifo(u32 slot, u32 spi_sel)
{
	//ActivateTriggerIn(SLOT_CS0, SPI_SEL_M0, EP_ADRS__MEM_TI, 1);
	ActivateTriggerIn(slot, spi_sel, EP_ADRS__MEM_TI, 1);
}

u16 eeprom_write_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_datain)
{
	u16 num_bytes_DAT_b16_extend = num_bytes_DAT_b16 * 4;
	u8 *buf_datain_32b = (u8 *)calloc(num_bytes_DAT_b16_extend, sizeof(u8));
	u16 idx;

	if(buf_datain_32b == NULL)
	{
		free(buf_datain_32b);
		buf_datain_32b = NULL;
		return 0xFFFF;
	}

	for(idx = 0; idx < num_bytes_DAT_b16; idx++)
	{
		memcpy(&buf_datain_32b[idx * 4], &buf_datain[idx], 1);
	}
 
	WriteToPipeIn(slot, spi_sel, EP_ADRS__MEM_PI, num_bytes_DAT_b16_extend, buf_datain_32b);

	free(buf_datain_32b);
	buf_datain_32b = NULL;

	return 0;
}

void eeprom_write_enable(u32 slot, u32 spi_sel)
{
	//  	## // CMD_WREN__96 
	//  	print('\n>>> CMD_WREN__96')
	//  	eeprom_send_frame (CMD=0x96, con_disable_SBP=1)
	eeprom_send_frame (slot, spi_sel, 0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
}

u16 eeprom_write_data_16B(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16)
{
	eeprom_write_enable(slot, spi_sel);
	u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
	u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);
	//  	
	//  	## // CMD_WRITE_6C 
	//  	eeprom_send_frame (CMD=0x6C, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT, con_disable_SBP=1)
	eeprom_send_frame (slot, spi_sel, 0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
	return num_bytes_DAT_b16;
}

u32 eeprom_send_frame (u32 slot, u32 spi_sel, u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8)
{
	u32 ret;
	u32 set_data_WI = ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
	u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
	ret = eeprom_send_frame_ep (slot, spi_sel, set_data_WI, set_data_FDAT_WI);
	return ret; //$$
}

u32 eeprom_send_frame_ep (u32 slot, u32 spi_sel, u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32)
{
	//  def eeprom_send_frame_ep (MEM_WI, MEM_FDAT_WI):
	//  	## //// end-point map :
	//  	## // wire [31:0] w_MEM_WI      = ep13wire;
	//  	## // wire [31:0] w_MEM_FDAT_WI = ep12wire;
	//  	## // wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;
	//  	## // wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;
	//  	## // wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr; 
	//  	## // wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; 	

	bool ret_bool;
	s32 cnt_loop;

	SetWireInValue(slot, spi_sel, EP_ADRS__MEM_WI, MEM_WI_b32, 0xFFFFFFFF); 
	SetWireInValue(slot, spi_sel, EP_ADRS__MEM_FDAT_WI, MEM_FDAT_WI_b32, 0xFFFFFFFF); 
	//  	# clear TO
	GetTriggerOutVector(slot, spi_sel, EP_ADRS__MEM_TO, 0xFFFFFFFF);
	//  	# act TI
	ActivateTriggerIn(slot, spi_sel, EP_ADRS__MEM_TI, 2);
	cnt_loop = 0;
	while (true) {
		ret_bool = IsTriggered(slot, spi_sel, EP_ADRS__MEM_TO, 0x04);
		if (ret_bool==true) {
			break;
		}
		
		if(cnt_loop > SPI_TRIG_MAX_CNT)
		{
			// TRACE("slot %d, eeprom_send_frame_ep Trigger Time Out\r\n", slot);
			break;
		}
		
		cnt_loop += 1;

		Delay_ms(1);
	}
	//$$if (cnt_loop>0) xil_printf("cnt_loop = %d \r\n", cnt_loop);
	return 0;
}

void eeprom_write_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
{
	u16 ret = num_bytes_DAT_b16;
	
	eeprom_reset_fifo(slot, spi_sel);

	if (num_bytes_DAT_b16 <= 16)
	{
		eeprom_write_fifo (slot, spi_sel, num_bytes_DAT_b16, buf_datain);
		eeprom_write_data_16B (slot, spi_sel, ADRS_b16, num_bytes_DAT_b16);
		ret = 0; // sent all
	}
	else
	{
		eeprom_write_fifo (slot, spi_sel, num_bytes_DAT_b16, buf_datain);

		while (true)
		{
			eeprom_write_data_16B (slot, spi_sel, ADRS_b16, 16);
			//
			ADRS_b16          += 16;
			ret               -= 16;
			//
			if (ret <= 16)
			{
				eeprom_write_data_16B (slot, spi_sel, ADRS_b16, num_bytes_DAT_b16);
				ret            = 0;
				break;
			}
		}

	}

	Delay_ms(5);
}

void eeprom_write_data_u8(u32 slot, u32 spi_sel, u16 adrs, u8 data)
{
	write_data_1byte(slot, spi_sel, adrs, data);
}

void write_data_1byte(u32 slot, u32 spi_sel, u16 adrs, u8 data)
{
//    //// for firmware
// 	u32 val  = (u32)val_b8;
// 	u16 adrs = (u16)adrs_b32; 

// 	//byte[] buf_bytearray = BitConverter.GetBytes(val);
// 	//u8[] buf = Array.ConvertAll(buf_bytearray, x => (u8)x );
// 	u8[] buf = {val_b8};

	// eeprom_write_data(adrs, 1, buf); //$$ write eeprom 

	// Delay(interval_ms); //$$ ms wait for write done

	eeprom_write_data(slot, spi_sel, adrs, 1, &data); //$$ write eeprom 
	Delay_ms(1);
}

void eeprom_write_data_u32(u32 slot, u32 spi_sel, u16 adrs, u32 data)
{
	write_data_4byte(slot, spi_sel, adrs, data);
}

void eeprom_write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data)
{
	write_data_float(slot, spi_sel, adrs, data);
}

void write_data_4byte(u32 slot, u32 spi_sel, u16 adrs, u32 data)
{
	u16 num_byte_DAT_b16 = 4;		// byte
	u8 data_32b[4];

	SYS_WordToHex(data, &data_32b[0]);

	eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, &data_32b[0]); //$$ write eeprom 
}

void write_data_float(u32 slot, u32 spi_sel, u16 adrs, float data)
{
	u16 num_byte_DAT_b16 = 4;		// byte
	u8 data_32b[4];

	SYS_FloatToHex(data, &data_32b[0]);

	eeprom_write_data(slot, spi_sel, adrs, num_byte_DAT_b16, &data_32b[0]); //$$ write eeprom 
}

u32 eeprom__read__data_u32(u32 slot, u32 spi_sel, u16 adrs)
{
	u32 ret = read__data_4byte(slot, spi_sel, adrs); 
	return ret;
}

float eeprom__read__data_float(u32 slot, u32 spi_sel, u16 adrs)
{
	float ret = read__data_float(slot, spi_sel, adrs);
	return ret;
}

//$$ eeprom__read__data_4byte --> read__data_4byte
u32 read__data_4byte(u32 slot, u32 spi_sel, u16 adrs)
{
	u8 buf[16]; //$$ 50 --> 16
	u32 ret_u32 = 0;
	u16 idx;
	eeprom_read_data(slot, spi_sel, adrs, 4, &buf[0]);

	for(idx = 0; idx < 4; idx++)
	{
		ret_u32 |= (buf[idx*4] << (idx*8));
	}
	
	return ret_u32;

	// return 0;

}

float read__data_float(u32 slot, u32 spi_sel, u16 adrs)
{
	u8 buf[16]; //$$ 50 --> 16
	float ret_float = 0; //$$ ret_u32 --> ret_float
	u16 idx;
	u8 *p;
	eeprom_read_data(slot, spi_sel, adrs, 4, &buf[0]);

	p = (u8 *)(&ret_float);
	
	for(idx = 0; idx < 4; idx++)
	{
		*(p+idx) = buf[idx*4];
	}
	
	return ret_float;




	




	// char *p;
	// float receive;
    // short second_addr=first_addr+1;
    // short third_addr=first_addr+2;
    // short fourth_addr=first_addr+3;
    // char data_byte1,data_byte2,data_byte3,data_byte4;
    // data_byte1=spi_read_byte(first_addr);
	// data_byte2=spi_read_byte(second_addr);
    // data_byte3=spi_read_byte(third_addr);
	// data_byte4=spi_read_byte(fourth_addr);
    // p=(char *)(&receive);
	// *p=data_byte1;
	// *(p+1)=data_byte2;
	// *(p+2)=data_byte3;
	// *(p+3)=data_byte4;










	// return 0;

}

u16 eeprom_read_data(u32 slot, u32 spi_sel, u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout)
{
	//buf_dataout[0] = (char)0x01; // test
	//buf_dataout[1] = (char)0x02; // test
	//buf_dataout[2] = (char)0x03; // test
	//buf_dataout[3] = (char)0x04; // test

	//byte[] buf_bytearray = BitConverter.GetBytes(0xFEDCBA98); // test
	//buf_bytearray.CopyTo(buf_dataout, 0); //test

	u16 ret;

	eeprom_reset_fifo(slot, spi_sel);

	u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
	u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);

	//  	## // CMD_READ__03 
	//  	eeprom_send_frame (CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT)
	eeprom_send_frame (slot, spi_sel, 0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);

	ret = eeprom_read_fifo(slot, spi_sel, num_bytes_DAT_b16, buf_dataout);
	
	return ret;

}

u16 eeprom_read_fifo(u32 slot, u32 spi_sel, u16 num_bytes_DAT_b16, u8 *buf_dataout)
{
	u16 ret;
	u32 adrs = EP_ADRS__MEM_PO;
	u16 num_bytes_DAT_b16_extend = num_bytes_DAT_b16 * 4;

	ret = ReadFromPipeOut(slot, spi_sel, adrs, num_bytes_DAT_b16_extend, buf_dataout, 0);

	return ret;
}


u32 eeprom_read_status(u32 slot, u32 spi_sel)
{
	u32 ret;
	//  	## // CMD_RDSR__05 
	//  	print('\n>>> CMD_RDSR__05')
	//  	eeprom_send_frame (CMD=0x05) 
	eeprom_send_frame (slot, spi_sel, 0x05, 0, 0, 0, 1, 0); //

	//  	# clear TO
	ret = GetTriggerOutVector(slot, spi_sel, EP_ADRS__MEM_TO, 0xFFFFFFFF);
	//  	# read again TO for reading latched status
	ret = GetTriggerOutVector(slot, spi_sel, EP_ADRS__MEM_TO, 0xFFFFFFFF);

	//  	MUST_ZEROS = (ret>>12)&0x0F
	//  	BP1 = (ret>>11)&0x01
	//  	BP0 = (ret>>10)&0x01
	//     	WEL = (ret>> 9)&0x01
	//  	WIP = (ret>> 8)&0x01
	ret = (ret>> 8)&0xFF;
	return ret;
}
