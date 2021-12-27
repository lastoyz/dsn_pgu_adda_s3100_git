#ifndef	_APP_FPGA_H
#define	_APP_FPGA_H

#include 	"top_core_info.h"

#define FPGA_GPIO_CNT		4
#define	FPGA_IFSEL_CNT		2

#define SPI_TRIG_MAX_CNT	99

#define	FPGA_DDR_IMAGE_MAX_ADRS		((u32)0x6cffffff)

typedef	struct{
	ioStatus_t	io[FPGA_GPIO_CNT];
}fpgaIO_t;

typedef	struct{
	u8			ifsel;
	ioStatus_t	io[FPGA_IFSEL_CNT];
}fpgaIfSel_t;

enum{
	DNC_CMD = 0,
	DNC_DATA
};

enum{
	FPGA_CLOCK_PIXEL_CLK = 0,
	FPGA_CLOCK_BYTE_CLK
};

enum{
	FPGA_MODE_NONE				= 0x00,
	FPGA_MODE_SSD2829			= 0x01
};

// enum{
// 	FPGA_CHECK								= 0x00100000,
// 	FPGA_VERSION							= 0x00100004,
// 	FPGA_ERR_LED							= 0x00100008,
// 	FPGA_IO									= 0x0010000C,

// 	FPGA_FAN_CNT1							= 0x00100010,
// 	FPGA_FAN_CNT2							= 0x00100014,
	
// 	FPGA_INTER_LOCK							= 0x00100018,
// 	FPGA_INTER_LOCK_LED						= 0x0010001C,
// 	FPGA_INTER_LOCK_RELAY					= 0x00100020,

// 	FPGA_IP									= 0x00100024,

// 	FPGA_SW_RESET							= 0x00100028,

// 	FPGA_380_CTRL							= 0x0010002C,
// 	FPGA_200_CTRL							= 0x00100030,
// };

enum{
	FPGA_MAGIC_CODE_L						= 0x00100000,
	FPGA_MAGIC_CODE_H						= 0x00100004,
	FPGA_ERR_LED							= 0x00100008,

	FPGA_LED								= 0x00100010,

	FPGA_MASTER_MODE_LAN_IP_ADRS			= 0x00100018,

	FPGA_IMAGE_ID_L							= 0x00100020,
	FPGA_IMAGE_ID_H							= 0x00100024,

	FPGA_SW_RESET							= 0x00100028,

	FPGA_H_IF_OUT							= 0x00100030,
	FPGA_H_IF_IN							= 0x00100038,

	FPGA_FAN_SPEED_0						= 0x00100040,
	FPGA_FAN_SPEED_1						= 0x00100044,
	FPGA_FAN_SPEED_2						= 0x00100048,
	FPGA_FAN_SPEED_3						= 0x0010004C,
	FPGA_FAN_SPEED_4						= 0x00100050,
	FPGA_FAN_SPEED_5						= 0x00100054,
	FPGA_FAN_SPEED_6						= 0x00100058,
	FPGA_FAN_SPEED_7						= 0x0010005C,

	FPGA_INTER_LOCK							= 0x60100060,
	FPGA_INTER_LED							= 0x60100068,
	FPGA_INTER_RELAY						= 0x6010006C

};

// S3100 define
// S3100 FPGA SPI CONTROL ADDRESS
enum{
	FPGA_SPI_CS_ADRS						= 0x00600000,
	FPGA_SPI_SLOT_CS_MASK_ADRS				= 0x00000000,
	FPGA_SPI_CH_SELECT_ADRS					= 0x00000004,

	FPGA_SPI_MOSI_ADRS						= 0x00700000,
	FPGA_SPI_MOSI_L_ADRS					= 0x00000000,
	FPGA_SPI_MOSI_H_ADRS					= 0x00000004,

	FPGA_SPI_MISO_ADRS						= 0x00700008,
	FPGA_SPI_MISO_L_ADRS					= 0x00000008,
	FPGA_SPI_MISO_H_ADRS					= 0x0000000C,

	FPGA_SPI_TRIG_ADRS						= 0x00700010,
	FPGA_SPI_DONE_ADRS						= 0x00700018
};

// S3100 FPGA SPI CONTROL BIT
enum{
	SPI_MODE_WRITE							= 0x00000000,
	SPI_MODE_READ							= 0x00000010,

	SPI_SEL_M0								= 0x00000001,			//GNDU & SMU
	// SPI_SEL_M1								= 0x00000002,		// E8000 not used
	SPI_SEL_M2								= 0x00000004,			//CMU & PGU
	SPI_SEL_EMUL 							= 0x00000000,			//emulation ... self test


	SPI_TRIG_OPT_RESET_LOC					= 0,
	SPI_TRIG_OPT_INIT_LOC					= 1,
	SPI_TRIG_OPT_FRAME_LOC	 			    = 2,

	SPI_TRIG_OPT_RESET_MSK					= 0x1<<SPI_TRIG_OPT_RESET_LOC,
	SPI_TRIG_OPT_INIT_MSK					= 0x1<<SPI_TRIG_OPT_INIT_LOC,
	SPI_TRIG_OPT_FRAME_MSK	 			    = 0x1<<SPI_TRIG_OPT_FRAME_LOC

};

//Reserved
enum{
	FPGA_TRIG_ADRS							= 0x0A000000,
	FPGA_PRE_TRIG_ADRS						= 0x0A000004,
	FPGA_SOT_ADRS							= 0x0A000008
};

enum{
	SLOT_CS_EMUL                            = 0x00000000,
	SLOT_CS0								= 0x00000001 << 0,
	SLOT_CS1								= 0x00000001 << 1,
	SLOT_CS2								= 0x00000001 << 2,
	SLOT_CS3								= 0x00000001 << 3,
	SLOT_CS4								= 0x00000001 << 4,
	SLOT_CS5								= 0x00000001 << 5,
	SLOT_CS6								= 0x00000001 << 6,
	SLOT_CS7								= 0x00000001 << 7,
	SLOT_CS8								= 0x00000001 << 8,
	SLOT_CS9								= 0x00000001 << 9,
	SLOT_CS10								= 0x00000001 << 10,
	SLOT_CS11								= 0x00000001 << 11,
	SLOT_CS12								= 0x00000001 << 12
};




extern u8 fpgaPclkOD, fpgaBclkOD;

extern SPI_HandleTypeDef	*fpgaSPI;
extern ioStatus_t	fpgaSpiCs;
extern u32 fpgaVersion;

void FPGA_GpioInit();
void FPGA_IoInit(u8 data);
void FPGA_SpiCsCtrl(u8 data);
void FPGA_SpiInit();
void FPGA_SpiLogicReset();
void FPGA_Init();
u8 FPGA_Check();

void FPGA_Read(u32 addr, u32 *pData, u32 length);
void FPGA_Write(u32 addr, u32 *pData, u32 length);
u32 FPGA_ReadSingle(u32 addr);
void FPGA_WriteSingle(u32 addr, u32 data);
void FPGA_Reset();


u32 __GetWireOutValue__(u32 adrs, u32 mask);
void __SetWireInValue__(u32 adrs, u32 data, u32 mask);

void __SetWireInValue__(u32 adrs, u32 data, u32 mask);
void __ActivateTriggerIn__(u32 adrs, s32 loc_bit);
bool __IsTriggered__(u32 adrs, u32 mask);
u32 _test__reset_spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_reset_trig, u32 mask_MSPI_reset_done);
u32 _test__init__spi_emul(u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, u32 loc_bit_MSPI_init_trig, u32 mask_MSPI_init_done);
u32 _test__send_spi_frame(u32 data_C, u32 data_A, u32 data_D, u32 enable_CS_bits_16b , u32 enable_CS_group_16b,
            u32 adrs_MSPI_CON_WI, u32 adrs_MSPI_FLAG_WO, u32 adrs_MSPI_TI, u32 adrs_MSPI_TO, 
            u32 adrs_MSPI_EN_CS_WI , s32 loc_bit_MSPI_frame_trig, u32 mask_MSPI_frame_done);



u32 _read_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
u32 GetWireOutValue(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
u32 _send_spi_frame_32b_mask_check_(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);
void SetWireInValue(u32 slot, u32 spi_sel, u32 adrs, u32 data, u32 mask);
void ActivateTriggerIn(u32 slot, u32 spi_sel, u32 adrs, s32 loc_bit);
bool IsTriggered(u32 slot, u32 spi_sel, u32 adrs, u32 mask);
u32 GetTriggerOutVector(u32 slot, u32 spi_sel, u32 adrs, u32 mask);

u32 SPI_EMUL__send_frame(u32 dumy_a, u32 dumy_b, u32 dumy_c);		// dumy function

u32 WriteToPipeIn(u32 slot, u32 spi_sel, u32 adrs, u16 num_bytes_DAT_b16, u8* data_bytearray);
u32 ReadFromPipeOut(u32 slot, u32 spi_sel, u16 adrs, u16 num_bytes_DAT_b16, u8 *data_bytearray, u8 dummy_leading_read_pulse);

#endif	// _APP_FPGA_H
