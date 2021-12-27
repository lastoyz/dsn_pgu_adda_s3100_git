#include	"Cmd_FPGA.h"

#if 1 // spi test
//#define MIO_WR(addr,data)	*(volatile unsigned long*)(addr) = (unsigned int)(data)
//#define MIO_RD(addr)	*(volatile unsigned long*)(addr) 
#define MIO_WR			FPGA_WriteSingle
#define MIO_RD			FPGA_ReadSingle

#define FPGA_SPI_0_BASE		0x00700000
#define FPGA_SPI_1_BASE		0x00800000

#define FPGA_SPI_0_WL		FPGA_SPI_0_BASE	+ 0x00
#define FPGA_SPI_0_WH		FPGA_SPI_0_BASE	+ 0x04
#define FPGA_SPI_0_TRG		FPGA_SPI_0_BASE	+ 0x08
#define FPGA_SPI_0_RL		FPGA_SPI_0_BASE	+ 0x0C
#define FPGA_SPI_0_RH		FPGA_SPI_0_BASE	+ 0x10
#define FPGA_SPI_0_STATUS	FPGA_SPI_0_BASE	+ 0x14

#define FPGA_SPI_1_WL		FPGA_SPI_1_BASE	+ 0x00
#define FPGA_SPI_1_WH		FPGA_SPI_1_BASE	+ 0x04
#define FPGA_SPI_1_TRG		FPGA_SPI_1_BASE	+ 0x08
#define FPGA_SPI_1_RL		FPGA_SPI_1_BASE	+ 0x0C
#define FPGA_SPI_1_RH		FPGA_SPI_1_BASE	+ 0x10
#define FPGA_SPI_1_STATUS	FPGA_SPI_1_BASE	+ 0x14


static void fpga_spi_write(char ch, unsigned long n_data) 
{
	char n_cnt = 10;

	TRACE(">>fpga spi_wr : %d ,0x%08x \r\n", ch, n_data);
	if (ch == 0) {
		MIO_WR(FPGA_SPI_0_WL, (n_data >> 0) & 0xFFFF);		// LSB
		MIO_WR(FPGA_SPI_0_WH, (n_data >> 16) & 0xFFFF);		// MSB
		MIO_WR(FPGA_SPI_0_TRG, 1);							// Trigger
	} else {
		MIO_WR(FPGA_SPI_1_WL, (n_data >> 0) & 0xFFFF);		// LSB
		MIO_WR(FPGA_SPI_1_WH, (n_data >> 16) & 0xFFFF);		// MSB
		MIO_WR(FPGA_SPI_1_TRG, 1);							// Trigger
	}

	while(n_cnt-- > 0) {
		if (ch == 0) 
			if (MIO_RD(FPGA_SPI_0_STATUS) & 0x01 > 0)  break;
		else 
			if (MIO_RD(FPGA_SPI_1_STATUS) & 0x01 > 0)  break;
	}

}

static unsigned int fpga_spi_read(char ch, unsigned long n_data, char repeat) 
{
	unsigned int recv = 0;
	char n_cnt = 10;

	TRACE(">>fpga spi_rd : %d ,0x%08x \r\n", ch, n_data);
	if (repeat < 1) {
		if (ch == 0) {
			MIO_WR(FPGA_SPI_0_WL, (n_data >> 0) & 0xFFFF);		// LSB
			MIO_WR(FPGA_SPI_0_WH, (n_data >> 16) & 0xFFFF);		// MSB
			MIO_WR(FPGA_SPI_0_TRG, 1);							// Trigger
		} else {
			MIO_WR(FPGA_SPI_1_WL, (n_data >> 0) & 0xFFFF);		// LSB
			MIO_WR(FPGA_SPI_1_WH, (n_data >> 16) & 0xFFFF);		// MSB
			MIO_WR(FPGA_SPI_1_TRG, 1);							// Trigger
		}
	} else {
		if (ch == 0)
			MIO_WR(FPGA_SPI_0_TRG, 1);							// Trigger
		else
			MIO_WR(FPGA_SPI_1_TRG, 1);							// Trigger
	}

	while(n_cnt-- > 0) {
		if (ch == 0) 
			if (MIO_RD(FPGA_SPI_0_STATUS) & 0x01 > 0)  break;
		else 
			if (MIO_RD(FPGA_SPI_1_STATUS) & 0x01 > 0)  break;
	}

	if (ch == 0) {
		recv = (MIO_RD(FPGA_SPI_0_RH) & 0x0000FFFF )  << 16;
		recv |= (MIO_RD(FPGA_SPI_0_RL) & 0x0000FFFF )  << 0;
	} else {
		recv = (MIO_RD(FPGA_SPI_1_RH) & 0x0000FFFF )  << 16;
		recv |= (MIO_RD(FPGA_SPI_1_RL) & 0x0000FFFF )  << 0;
	}

	return recv;
}

#endif

//u8 Cmd_FPGA(trxData_t *pTrxData, u16 *pArgc, u8 **pArgv)
u8 Cmd_FPGA(void *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8 result = 1;
	u16 argc = *pArgc;

	if(CMD_Compare(pArgv[1], "read"))
	{
		u32 cmd, data;

		CMD_Printf(";READ");
		
		if(argc != 3)	goto CMD_FPGA_ERROR;

		cmd = CMD_StrToUL(pArgv[2]);

		data = FPGA_ReadSingle(cmd);

		CMD_Printf(";CMD=0x%08x,DATA=0x%08x", cmd, data);

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "write"))
	{
		u32 cmd, data;

		CMD_Printf(";WRITE");
		
		if(argc != 4)	goto CMD_FPGA_ERROR;

		cmd		= CMD_StrToUL(pArgv[2]);
		data	= CMD_StrToUL(pArgv[3]);

		FPGA_WriteSingle(cmd, data);

		CMD_Printf(";CMD=0x%08x,DATA=0x%08x", cmd, data);
	}
	else if(CMD_Compare(pArgv[1], "spi.write"))
	{
		u16 nCmd;
		u16 nData;

		CMD_Printf(";SPI.WRITE");

		if(argc != 4)		goto CMD_FPGA_ERROR;

		nCmd = CMD_StrToUL(pArgv[2]);
		nData = CMD_StrToUL(pArgv[3]);

		fpga_spi_write(0, ((nCmd << 16) | (nData)));

	}
	else if(CMD_Compare(pArgv[1], "spi.read"))
	{
		u16 nCmd;
		u16 nData;
		u32 recv = 0;

		CMD_Printf(";SPI.READ");

		if(argc != 3)		goto CMD_FPGA_ERROR;

//		pinStat.u8Data = CMD_StrToUL(pArgv[2]);

		nCmd = CMD_StrToUL(pArgv[2]);
		nData = 0;

		recv = fpga_spi_read(0, ((nCmd << 16) | (nData)), 0);

		CMD_Printf(";0x%08x",recv);

//		pinStat.u8Data &= 0x03;

	}
	else
	{
		CMD_FPGA_ERROR:
		result = 0;
	}

	if(result)	CMD_Printf(";OK");
	else		CMD_Printf(";ERROR");

	return result;
}
