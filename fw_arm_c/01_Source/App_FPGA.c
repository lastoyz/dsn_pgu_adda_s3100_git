#include	"App_FPGA.h"

u8	fpgaPclkOD, fpgaBclkOD;

u32	fpgaMutex;
u32	fpgaVersion;

SPI_HandleTypeDef	*fpgaSPI;

fpgaIO_t	fpgaIO;
fpgaIfSel_t	fpgaIfSel;
ioStatus_t	fpgaDNC, fpgaRST, fpgaNorSel, fpgaPwr;
ioStatus_t	fpgaSpiCs;

//static vu32 *pFpgaCmd	= (vu32*)FPGA_CMD_ADDR;
//static vu32 *pFPGA_BaseAddress	= (vu32*)FPGA_DATA_ADDR;
//static vu32 *pFPGA_BaseAddress	= (vu32*)FPGA_DEVICE_ADDR		// 0x6000_0000
//
#define FPGA_BASE_ADDR		FPGA_DEVICE_ADDR		// 0x6000_0000

#define FPGA_PERP_ADDR_0	(FPGA_BASE_ADDR 	+ 0x00000000)		// NE1
#define FPGA_PERP_ADDR_1	(FPGA_BASE_ADDR 	+ 0x04000000)		// NE2
#define FPGA_PERP_ADDR_2	(FPGA_BASE_ADDR 	+ 0x08000000)		// NE3
#define FPGA_PERP_ADDR_3	(FPGA_BASE_ADDR 	+ 0x0C000000)

static void FPGA_GpioSet(ioStatus_t *pData)
{
	GPIO_InitTypeDef	gpio;

	pData->value &= 0x01;

	if(pData->direction == IO_INPUT)
	{
		gpio.Pin		= pData->pin;
		gpio.Mode		= GPIO_MODE_INPUT;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;

		HAL_GPIO_Init(pData->port, &gpio);

		pData->value = HAL_GPIO_ReadPin(pData->port, pData->pin);
	}
	else if(pData->direction == IO_OUTPUT)
	{
		gpio.Pin		= pData->pin;
		gpio.Mode		= GPIO_MODE_OUTPUT_PP;
		gpio.Pull		= GPIO_PULLUP;
		gpio.Speed		= GPIO_SPEED_HIGH;

		HAL_GPIO_Init(pData->port, &gpio);

		HAL_GPIO_WritePin(pData->port, pData->pin, (GPIO_PinState)pData->value);
	}
}

void FPGA_GpioInit()
{
#if 0  
	u8 cnt;
	/*
	IO Map

	FPGA_GPIO_0			PF6
	FPGA_GPIO_1			PF7
	FPGA_GPIO_2			PF8
	FPGA_GPIO_3			PF9

	FPGA_DnC			PI12
	FPGA_nRST			PI13
	FPGA_NORSEL			PI14
	FPGA_PWR			PI15

	IFSEL_0				PK6
	IFSEL_1				PK7

	FPGA_SPI_CS			PA4
	*/

	fpgaIO.io[0].port			= GPIOF;
	fpgaIO.io[0].pin			= GPIO_PIN_6;
	fpgaIO.io[0].direction		= IO_INPUT;
	fpgaIO.io[0].value			= LOW;
	fpgaIO.io[1].port			= GPIOF;
	fpgaIO.io[1].pin			= GPIO_PIN_7;
	fpgaIO.io[1].direction		= IO_INPUT;
	fpgaIO.io[1].value			= LOW;
	fpgaIO.io[2].port			= GPIOF;
	fpgaIO.io[2].pin			= GPIO_PIN_8;
	fpgaIO.io[2].direction		= IO_OUTPUT;
	fpgaIO.io[2].value			= LOW;
	fpgaIO.io[3].port			= GPIOF;
	fpgaIO.io[3].pin			= GPIO_PIN_9;
	fpgaIO.io[3].direction		= IO_OUTPUT;
	fpgaIO.io[3].value			= LOW;

	fpgaDNC.port				= GPIOI;
	fpgaDNC.pin					= GPIO_PIN_12;
	fpgaDNC.direction			= IO_OUTPUT;
	fpgaDNC.value				= DNC_CMD;

	fpgaRST.port				= GPIOI;
	fpgaRST.pin					= GPIO_PIN_13;
	fpgaRST.direction			= IO_OUTPUT;
	fpgaRST.value				= LOW;

	fpgaNorSel.port				= GPIOI;
	fpgaNorSel.pin				= GPIO_PIN_14;
	fpgaNorSel.direction		= IO_OUTPUT;
	fpgaNorSel.value			= LOW;

	fpgaPwr.port				= GPIOI;
	fpgaPwr.pin					= GPIO_PIN_15;
	fpgaPwr.direction			= IO_OUTPUT;
	fpgaPwr.value				= LOW;

	fpgaIfSel.io[0].port		= GPIOK;
	fpgaIfSel.io[0].pin			= GPIO_PIN_6;
	fpgaIfSel.io[0].direction	= IO_OUTPUT;
	fpgaIfSel.io[0].value		= LOW;
	
	fpgaIfSel.io[1].port		= GPIOK;
	fpgaIfSel.io[1].pin			= GPIO_PIN_7;
	fpgaIfSel.io[1].direction	= IO_OUTPUT;
	fpgaIfSel.io[1].value		= LOW;

	fpgaSpiCs.port				= GPIOA;
	fpgaSpiCs.pin				= GPIO_PIN_4;
	fpgaSpiCs.direction			= IO_OUTPUT;
	fpgaSpiCs.value				= HIGH;

	for(cnt = 0; cnt < FPGA_GPIO_CNT; cnt++)
	{
		FPGA_GpioSet(&fpgaIO.io[cnt]);
	}

	FPGA_GpioSet(&fpgaDNC);
	FPGA_GpioSet(&fpgaRST);
	FPGA_GpioSet(&fpgaPwr);
	FPGA_GpioSet(&fpgaNorSel);
	FPGA_GpioSet(&fpgaIfSel.io[0]);
	FPGA_GpioSet(&fpgaIfSel.io[1]);
	FPGA_GpioSet(&fpgaSpiCs);
#endif


}

void FPGA_IoInit(u8 data)
{
	if(data > 3)	return;
	
	FPGA_GpioSet(&fpgaIO.io[data]);
}

void FPGA_SpiCsCtrl(u8 data)
{
	data &= 0x01;

	fpgaSpiCs.value	= data;

	HAL_GPIO_WritePin(fpgaSpiCs.port, fpgaSpiCs.pin, (GPIO_PinState)fpgaSpiCs.value);
}

void FPGA_SpiInit()
{
	fpgaSPI = &hSPI1;

	SPI1_Init();

	FPGA_SpiCsCtrl(HIGH);
}
void FPGA_SpiLogicReset()
{
	// SPI M0, M1, M2 Reset
	_test__reset_spi_emul(FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, SPI_TRIG_OPT_RESET_LOC, SPI_TRIG_OPT_RESET_MSK);
    TRACE("_test__reset_spi_emul done\r\n");
    
    HAL_Delay(1);            // FPGA configuration delay
    
	_test__init__spi_emul(FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, SPI_TRIG_OPT_INIT_LOC, SPI_TRIG_OPT_INIT_MSK);
    TRACE("_test__init__spi_emul done\r\n");

    HAL_Delay(1);            // FPGA configuration delay
    		    
}

void FPGA_Init()
{
	fpgaMutex = 0;
}

u8 FPGA_Check()
{
	u8	result = 0;

	fpgaVersion = (FPGA_ReadSingle(FPGA_IMAGE_ID_H) << 16);
	fpgaVersion |= FPGA_ReadSingle(FPGA_IMAGE_ID_L);

	if(fpgaVersion == NULL)
	{
		TRACE(">>CPU BASE FID read fail.\r\n");
		sysError.fpga = 1;
		return result;
	}
	result = 1;

	return result;
}

void FPGA_Read(u32 addr, u32 *pData, u32 length)
{
	u32 cnt;
	// buswidth : 16bit 
	vu16 *paddr = (vu16*)(FPGA_PERP_ADDR_0 +  _SHIFT_ADDR(addr));

	for(cnt = 0; cnt < length; cnt++)
	{
		pData[cnt] = 0x0000FFFF & *paddr;
	}
}

void FPGA_Write(u32 addr, u32 *pData, u32 length)
{
	u32 cnt;
	// buswidth : 16bit 
	vu16 *paddr = (vu16*)(FPGA_PERP_ADDR_0 +  _SHIFT_ADDR(addr));

	for(cnt = 0; cnt < length; cnt++)
	{
		*(paddr + 2*cnt) = 0x0000FFFF & pData[cnt] ;
	}
}

u32 FPGA_ReadSingle(u32 addr)
{
	u32 data;

	FPGA_Read(addr, &data, 1);

	return data;
}

void FPGA_WriteSingle(u32 addr, u32 data)
{
	FPGA_Write(addr, &data, 1);
}

void FPGA_Reset()
{
	FPGA_WriteSingle(FPGA_SW_RESET, 0);

	HAL_Delay(10);

	FPGA_WriteSingle(FPGA_SW_RESET, 1);

	HAL_Delay(10);
}


//////////////////////////////////////////////////////////////////////////////////////////////

static u32 address_step_b16 = 4;  // 4 or 2

u32 __GetWireOutValue__(u32 adrs, u32 mask) {

	u32 ret = 0;
	ret = FPGA_ReadSingle(adrs + address_step_b16);
	ret = (ret<<16) | FPGA_ReadSingle(adrs) ;
	ret = ret & mask;

	//TRACE("GetWireOutValue adrs: 0x%08X, data: 0x%08X\r\n", adrs, ret);

	return ret;
}

void UpdateWireOuts() {
            // NOP
}

void __SetWireInValue__(u32 adrs, u32 data, u32 mask) {

	u32 maskedData = data & mask;

	FPGA_WriteSingle(adrs + address_step_b16, (maskedData>>16) & 0x0000FFFF); // write hi 16b
	FPGA_WriteSingle(adrs + 0               , (maskedData>>0 ) & 0x0000FFFF); // write low 16b

	//TRACE("SetWireInValue adrs: 0x%08X, data: 0x%08X\r\n", adrs, maskedData);
	
}

void __ActivateTriggerIn__(u32 adrs, s32 loc_bit) {

	s32 sh_loc_bit = 0x00000001 << loc_bit;
    // CPU BASE Host Interface
	FPGA_WriteSingle(adrs, sh_loc_bit);

	//TRACE("ActivateTriggerIn adrs: 0x%08X, data: 0x%08X\r\n", adrs, loc_bit);
}

bool __IsTriggered__(u32 adrs, u32 mask) {

	u32 ret = FPGA_ReadSingle(adrs);

	//TRACE("IsTriggered adrs: 0x%08X, data: 0x%08X\r\n", adrs, ret);

	if(ret & mask) return 1;
	else return 0;

    
}

u32 _test__reset_spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_reset_trig, u32 mask_MSPI_reset_done) {

    //## trigger reset 
    __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_reset_trig);
    u32 cnt_loop = 0;
    bool done_trig = false;
    while (true) {
        done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_reset_done);
        cnt_loop++;
        if (done_trig) {
            // print
            //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
            break;
        }
    }
    return cnt_loop;
}


u32 _test__init__spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_init_trig, u32 mask_MSPI_init_done) {
    
	//## trigger init 
    __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_init_trig);
    u32 cnt_loop = 0;
    bool done_trig = false;
    while (true) {
        done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_init_done);
        cnt_loop++;
        if (done_trig) {
            // print
            //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
            break;
        }
    }
    return cnt_loop;
}

u32 _test__send_spi_frame(u32 data_C, u32 data_A, u32 data_D, u32 enable_CS_bits_16b , u32 enable_CS_group_16b,
            u32 adrs_MSPI_CON_WI, u32 adrs_MSPI_FLAG_WO, u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, 
            u32 adrs_MSPI_EN_CS_WI , s32 loc_bit_MSPI_frame_trig, u32 mask_MSPI_frame_done) {

    //## set spi frame data (example)
    u32 data_MSPI_CON_WI = (data_C<<26) + (data_A<<16) + data_D;
    //uint adrs_MSPI_CON_WI = 0x17;
    __SetWireInValue__(adrs_MSPI_CON_WI, data_MSPI_CON_WI, 0xFFFFFFFF);

    //## set spi enable signals : {enable_CS_group_16b, enable_CS_bits_16b}
    u32 data_MSPI_EN_CS_WI = ((enable_CS_group_16b & 0x0007) <<16 ) + (enable_CS_bits_16b & 0x1FFF);
    __SetWireInValue__(adrs_MSPI_EN_CS_WI, data_MSPI_EN_CS_WI, 0xFFFFFFFF);		// SLOT CS MASK 16bit

    //## trigger frame 
    __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_frame_trig);

	//HAL_Delay(1);
    u32 cnt_loop = 0;
    bool done_trig = false;
    while (true) {
        done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_frame_done);
        cnt_loop++;
        if (done_trig) {
            // print
            //$$Console.WriteLine(string.Format("> frame done !! @ cnt_loop={0}", cnt_loop)); // test
            break;
        }
    }
	
    //## read miso data
    u32 data_B;
    data_B = __GetWireOutValue__(adrs_MSPI_FLAG_WO, 0xFFFFFFFF);
    return data_B;
}

u32 _read_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 mask) {
	u32 data_C = SPI_MODE_READ;		// read
	u32 data_A = (adrs << 2);
	u32 data_D = 0x0000;

	// lo first
	u32 data_B_lo = 0;
	if ((mask & 0x0000FFFF) != 0) {
		data_B_lo = _test__send_spi_frame(data_C, data_A, data_D, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}

	u32 data_B_hi = 0;
	if ((mask & 0xFFFF0000) != 0) {
		data_B_hi = _test__send_spi_frame(data_C, data_A+2, data_D, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}
	
	u32 data_B = ( (data_B_hi << 16) + (data_B_lo & 0x0000FFFF)) & mask; // mask off
	return data_B;
}

u32 GetWireOutValue(u32 slot, u32 spi_sel, u32 adrs, u32 mask) {
	return _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
}

u32 _send_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask) {
	u32 data_C_rd = SPI_MODE_READ;		// read
	u32 data_C_wr = SPI_MODE_WRITE;		// write
	u32 data_A_lo = (adrs << 2);
	u32 data_A_hi = (adrs << 2) + 2;
	u32 data_D_lo = 0x0000;
	u32 data_D_hi = 0x0000;
	u32 data_B_lo = 0;
	u32 data_B_hi = 0;




	// addres low side 
	if ((mask & 0x0000FFFF) != 0) {
		if ((mask & 0x0000FFFF) != 0xFFFF) { // need to read data first to mask off
			data_B_lo = _test__send_spi_frame(data_C_rd, data_A_lo, data_D_lo, slot, spi_sel, 
							FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
							FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);

			// mask off: 
			//  data mask  new
			//  0    0     0
			//  0    1     0
			//  1    0     1
			//  1    1     0
			data_B_lo = data_B_lo & ~(mask & 0x0000FFFF) ; // previous data with mask off
		}
		data_D_lo = (data & mask) & 0x0000FFFF; // new data with mask off
		data_D_lo = data_D_lo | data_B_lo;      // merge data
		data_B_lo = _test__send_spi_frame(data_C_wr, data_A_lo, data_D_lo, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}

	// addres high side 
	if ((mask & 0xFFFF0000) != 0) {
		if ((mask & 0xFFFF0000) != 0xFFFF0000) { // need to read data first to mask off
			data_B_hi = _test__send_spi_frame(data_C_rd, data_A_hi, data_D_hi, slot, spi_sel, 
							FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
							FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);			
			// mask off: 
			//  data mask  new
			//  0    0     0
			//  0    1     0
			//  1    0     1
			//  1    1     0
			data_B_hi = data_B_hi & ~( (mask>>16) & 0x0000FFFF) ; // previous data with mask off
		}
		data_D_hi = ((data & mask)>>16) & 0x0000FFFF; // new data with mask off
		data_D_hi = data_D_hi | data_B_hi;      // merge data
		data_B_hi = _test__send_spi_frame(data_C_wr, data_A_hi, data_D_hi, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}

	u32 data_B = (data_B_hi << 16) | (data_B_lo & 0x0000FFFF); // merge
	return data_B;
}

void SetWireInValue(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask) {
	_send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data, mask);
}


//$$ for ActivateTriggerIn()
u32 _send_spi_frame_32b_mask_check__no_readback_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask) {
//	u32 data_C_rd = SPI_MODE_READ;		// read
	u32 data_C_wr = SPI_MODE_WRITE;		// write
	u32 data_A_lo = (adrs << 2);
	u32 data_A_hi = (adrs << 2) + 2;
	u32 data_D_lo = 0x0000;
	u32 data_D_hi = 0x0000;
	u32 data_B_lo = 0;
	u32 data_B_hi = 0;


	// addres low side 
	if ((mask & 0x0000FFFF) != 0) {
		data_D_lo = (data & mask) & 0x0000FFFF; // new data with mask off
		data_B_lo = _test__send_spi_frame(data_C_wr, data_A_lo, data_D_lo, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}

	// addres high side 
	if ((mask & 0xFFFF0000) != 0) {
		data_D_hi = ((data & mask)>>16) & 0x0000FFFF; // new data with mask off
		data_B_hi = _test__send_spi_frame(data_C_wr, data_A_hi, data_D_hi, slot, spi_sel, 
						FPGA_SPI_MOSI_ADRS, FPGA_SPI_MISO_ADRS , FPGA_SPI_TRIG_ADRS, FPGA_SPI_DONE_ADRS, 
						FPGA_SPI_CS_ADRS, SPI_TRIG_OPT_FRAME_LOC, SPI_TRIG_OPT_FRAME_MSK);
	}

	u32 data_B = (data_B_hi << 16) | (data_B_lo & 0x0000FFFF); // merge
	return data_B;
}

void ActivateTriggerIn(u32 slot, u32 spi_sel, u32 adrs, s32 loc_bit) {
	u32 mask = (u32)(0x00000001 << loc_bit);
	u32 data = mask;
	//$$ _send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data, mask);
	_send_spi_frame_32b_mask_check__no_readback_(slot, spi_sel, adrs, data, mask); //$$ rev 20210826
}

bool IsTriggered(u32 slot, u32 spi_sel, u32 adrs, u32 mask) {
	bool ret = false;
	u32 data_trig_done = _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
	if (data_trig_done != 0)
		ret = true;
	return ret;
}

u32 GetTriggerOutVector(u32 slot, u32 spi_sel, u32 adrs, u32 mask) {
	return _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, mask);
}

u32 SPI_EMUL__send_frame(u32 dumy_a, u32 dumy_b, u32 dumy_c)		// dummy function
{
	return dumy_a+dumy_b+dumy_c;

}

u32 WriteToPipeIn(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8* data_bytearray)
{
	u32 data_B = 0;
	u16 idx;

	for (idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
	{		
		data_B = SYS_HexToWord(&data_bytearray[idx]);		// MSB 16bit + LSB 16bit
		_send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);		// FIFO in
	}

	// return (long)len_bytes;
	return 0;
}

u32 ReadFromPipeOut(u32 slot, u32 spi_sel, u16 adrs, u16 num_bytes_DAT_b16, u8 *data_bytearray, u8 dummy_leading_read_pulse)
{
	u32 data_B    = 0;

	if (dummy_leading_read_pulse !=0 )
	{
		_send_spi_frame_32b_mask_check_(slot, spi_sel, adrs, data_B, 0xFFFFFFFF);
	}
	
	for (s32 idx = 0; idx < num_bytes_DAT_b16; idx = idx + 4)
	{		
		data_B = _read_spi_frame_32b_mask_check_(slot, spi_sel, adrs, 0xFFFFFFFF);

		SYS_WordToHex(data_B, &data_bytearray[idx]);
	}
	// return (long)len_bytes;
	return 0;
}


