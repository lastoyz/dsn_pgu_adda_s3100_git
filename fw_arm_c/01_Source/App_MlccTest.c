//******************************************************************************
// File Name: App_MlccTest.c
// Description: 명령어 처리 스레드
//******************************************************************************
#include "App_MlccTest.h"
#include "Cmd_MlccTest.h"

buffer_t tx_buffer;		// transmit buffer	: periph -> PC
buffer_t rx_buffer;		// receive buffer	: PC -> periph

static unsigned int download_rx_addr = DOWNLOAD_RX_RAM_ADDR;
static unsigned int download_tx_addr = DOWNLOAD_TX_RAM_ADDR;

static unsigned int downloaded_size = 0;
static int spi_select = 1;	//  0: cpu, 1 : FPGA

///////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////
static void fpga_spi_write(char ch, unsigned long n_data) 
{
	char n_cnt = 10;

	DEBUG_PRINT("SPI_WR : send: 0x%08x \r\n", n_data);
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

	DEBUG_PRINT("SPI_RD : send: 0x%08x \r\n", n_data);
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
		HAL_Delay(10);
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
	DEBUG_PRINT("SPI_RD : recv : 0x%08x, %d\r\n", recv, n_cnt);

	return recv;
}

static u8 tst_spi_write(char typ, char cs, unsigned long n_data)
{
	fpga_spi_write(cs, n_data);
}

static unsigned int tst_spi_read(char typ, char cs, unsigned long n_data, char rep)
{
	unsigned int recv = 0;

	recv = fpga_spi_read(cs, n_data, rep);

	return recv;
}
///////////////////////////////////////////////////////////////////////

int Soft_Reset(int argc, char **argv)
{
	DEBUG_PRINT("System Soft Reset.......\r\n");
//	OWER  = OWER_WME;
//	OSSR  = OSSR_M3;
//	OSMR3 = OSCR + 36864;	/* ... in 10 ms */
	return 0;
}
#if 0
static uint8_t Serial_InChar()
{
	uint8_t data;
	int8_t res = 0;

	HAL_UART_Receive(&h_Board_Serial, &data, 1, 100);
	return data;
}
#endif

static void Serial_OutChar(uint8_t ch)
{
	HAL_UART_Transmit(&h_Board_Serial, &ch, 1, 100);
}

//==============================================================================
static const char *delim = " \f\n\r\t\v";
static int parse_args(char *cmdline, char **argv)
{
	char *tok;
	int argc = 0;

	argv[argc] = NULL;

	for (tok = strtok(cmdline, delim); tok; tok = strtok(NULL, delim)) {
		argv[argc++] = tok;
	}

	return argc;
}

//==============================================================================
//#if defined(CONFIG_TST_MLCC)

int ClsMem(int argc, char **argv)
{
	unsigned char *ram_addr   = (unsigned char*)download_rx_addr;
	unsigned int size       = downloaded_size;

	DEBUG_PRINT("clear memroy ..\r\n");

	if (argc > 0) ram_addr = (unsigned char *) strtoul(argv[1], NULL, 0);
	if (argc > 1) size = (unsigned int) strtoul(argv[2], NULL, 0);
	DEBUG_PRINT("  ADDRESS :  0x%08x , SIZE : %d\r\n", (unsigned int)ram_addr, size);

	while (size--) {
		*(ram_addr ++) = 0;
	}
	DEBUG_PRINT("clear memory.. done\r\n");

	return 1;
}

u8 tst_init(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char ch = 0;

	if (argc > 0) cmd = (char *) argv[0];
	if (argc > 1) ch = (int)strtoul(argv[1], NULL, 0);
	DEBUG_PRINT("cmd: %s %d\r\n", cmd, ch);

	// set buffer
	rx_buffer.buf = (unsigned char*)download_rx_addr;
	tx_buffer.buf = (unsigned char*)download_tx_addr;
	// set slot 
	
	// set timing cfg in client 
	tst_spi_write(0, 0, 0x000a1000);

	return result;
}

u8 tst_enable(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char ch = 0;

	if (argc > 0) cmd = (char *) argv[0];
	if (argc > 1) ch = (char) strtoul(argv[1], NULL, 0);
	DEBUG_PRINT("cmd: %s %d\r\n", cmd, ch);

	// sip enable
//	if (ch == 0)	
//		spi_enable();
//	else
//		spi2_enable();
	return result;
}

u8 tst_disable(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char ch = 0;

	if (argc > 0) cmd = (char *) argv[0];
	if (argc > 1) ch = (char) strtoul(argv[1], NULL, 0);
	DEBUG_PRINT("cmd: %s %d\r\n", cmd, ch);

	// sip enable
//	if (ch == 0)	
//		spi_disable();
//	else
//		spi2_disable();
	return result;
}

u8 tst_spi_set_speed(int argc, void* data)
{
	DEBUG_PRINT("console: not supported. \r\n");
}

u8 tst_spi_send(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char dbg_mode = 0;
	char cs = 0;
	unsigned int n_data = 0;

	if (argc > 0) cmd = (char *) argv[0];
	if (argc > 1) cs = (char)strtoul(argv[1], NULL, 0);
	if (argc > 2) n_data = strtoul(argv[2], NULL, 0);
	if (argc > 3) dbg_mode = (char) strtoul(argv[3], NULL, 0);
	DEBUG_PRINT("cmd: %s %d\r\n", cmd, cs);

	tst_spi_write(0, cs, n_data);

	if (dbg_mode > 0) {
		DEBUG_PRINT(" send %d: 0x%08x\r\n", cs, n_data);
	}

	return result;
}

u8 tst_spi_recv(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char dbg_mode = 0;
	char cs = 0;
	unsigned int n_data = 0;
	unsigned int recv_data = 0;


	if (argc > 0) cmd = (char *) argv[0];
	if (argc > 1) cs = (char)strtoul(argv[12], NULL, 0);
	if (argc > 2) n_data = strtoul(argv[2], NULL, 0);
	if (argc > 3) dbg_mode = (char) strtoul(argv[3], NULL, 0);
	DEBUG_PRINT("cmd: %s %d\r\n", cmd, cs);

	recv_data = tst_spi_read(0, cs, n_data, 0);

	tx_buffer.size = sizeof(int);
	memcpy(tx_buffer.buf, &recv_data, sizeof(int));

	if (dbg_mode > 0) {
		DEBUG_PRINT(" recv : 0x%08x\r\n", recv_data);
	}

	return result;
}

u8 tst_mem_io_rd(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char dbg_mode = 0;
	unsigned long io_addr = 0;
	unsigned int value = 0;

	if (argc > 0) cmd = (char *) argv[0];
	DEBUG_PRINT("cmd: %s\r\n", cmd);
	if (argc > 1) io_addr = (unsigned long) strtoul(argv[1], NULL, 0);
	if (argc > 2) dbg_mode = (char) strtoul(argv[2], NULL, 0);

	if (dbg_mode > 0) 
		DEBUG_PRINT(" rd addr : %08x %d\r\n", io_addr, sizeof(int));
	value = MIO_RD(io_addr);

	tx_buffer.size = sizeof(int);
	memcpy(tx_buffer.buf, &value, sizeof(int));

	return result ;
}

u8 tst_mem_io_wr(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	char dbg_mode = 0;
	unsigned long io_addr = 0;
	unsigned int value = 0;

	if (argc > 0) cmd = (char *) argv[1];
	io_addr = strtoul(argv[1], NULL, 0);
	value = strtoul(argv[2], NULL, 0);
	if (argc > 4) dbg_mode = (char) strtoul(argv[3], NULL, 0);
	DEBUG_PRINT("cmd: %s\r\n", cmd);

	MIO_WR(io_addr, value);
	if (dbg_mode > 0) 
		DEBUG_PRINT(" io_addr wr: 0x%08x : 0x%08x\r\n", io_addr, value);

	return result;
}

u8 tst_adc_fifo(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	unsigned int *resp_buf = (unsigned int*)tx_buffer.buf;
	char *cmd = NULL;
	uint8_t socket = 0;
	uint8_t ch = 0;
	unsigned int sp_cnt = 0;
	char spi_cs = 0;
	int sp_delay = 0;
	int i;

	unsigned int addr = 0;
	unsigned int pack_data = 0;
	unsigned int recv_data = 0;
	unsigned int acc_data = 0;


	if (argc > 0) cmd = (char *) argv[1];
	DEBUG_PRINT("cmd: %s\r\n", cmd);
	if (argc < 6) return;

	socket = (unsigned char) strtoul(argv[2], NULL, 0);
	ch = (unsigned char) strtoul(argv[3], NULL, 0);
	sp_cnt = (unsigned int) strtoul(argv[4], NULL, 0);
	sp_delay = (unsigned char) strtoul(argv[5], NULL, 0);

	if (sp_cnt > 32768) {
		sp_cnt = 32768;
	}
	if (sp_cnt < 1) {
		sp_cnt = 1;
	}
	// socket : bit : socket 
	// #1 = 0b00000001
	// #2 = 0b00000010
	// #3 = 0b00000100
	// ...
	// #8 = 0b10000000
	// #0 = all or none
	if (socket < 1) {
		socket = 1;
	}
	if (ch < 1) {
		addr = 0x0280;
	} else {
		addr = 0x02a0;
	}

	// gen packet
	pack_data = 0;
	pack_data += (0x1 << 30); // read
	pack_data += ((addr + 4 * (socket - 1)) << 16); // read

#if 0
	DEBUG_PRINT("cmd: %s, %d, %d, %d, %d %c\r\n", cmd, socket, ch, sp_cnt, sp_delay, ((spi_select>0)?'f':'c'));
	recv_data = tst_spi_read(spi_select, ch, pack_data, 0);

	for (i = 0; i < sp_cnt; i++) {
		recv_data = tst_spi_read(spi_select, ch, pack_data, 0);

		acc_data += 0x0000FFFF & recv_data;
		HAL_Delay(sp_delay);
		resp_buf[i] = recv_data;
	}
#else
	DEBUG_PRINT("cmd: %s, %d, %d, %d, %d %c\r\n", cmd, socket, ch, sp_cnt, sp_delay, ((spi_select>0)?'f':'c'));
//	recv_data = tst_spi_read(spi_select, spi_cs, pack_data, 0);

	for (i = 0; i < sp_cnt; i++) {
		recv_data = tst_spi_read(spi_select, spi_cs, pack_data, 0);

		acc_data += 0x0000FFFF & recv_data;
		HAL_Delay(sp_delay);
		resp_buf[i] = recv_data;
	}
#endif

	return result;
}

u8 tst_adc_rd(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	uint8_t socket = 0;
	uint8_t ch = 0;
	int sp_cnt = 0;
	int sp_delay = 0;
	int auto_trigger = 0;
	int i;

	unsigned int pack_data = 0;
	unsigned int recv_data = 0;
	unsigned int acc_data = 0;
	unsigned int trigger_data = 0;


	if (argc > 0) cmd = (char *) argv[1];
	DEBUG_PRINT("cmd: %s\r\n", cmd);
	if (argc < 6) return;

	socket = (unsigned char) strtoul(argv[2], NULL, 0);
	ch = (unsigned char) strtoul(argv[3], NULL, 0);
	sp_cnt = (unsigned char) strtoul(argv[4], NULL, 0);
	sp_delay = (unsigned char) strtoul(argv[5], NULL, 0);

	if (argc > 7) {
		auto_trigger = (unsigned char) strtoul(argv[6], NULL, 0);
		trigger_data = (unsigned int) strtoul(argv[7], NULL, 0);
	}

	if (sp_cnt > 64) {
		sp_cnt = 64;
	}
	if (sp_cnt < 1) {
		sp_cnt = 1;
	}
	if (socket < 1) {
		socket = 1;
	}
	if (ch < 1) {
		ch = 1;
	}

	// gen packet
	pack_data = 0;
	pack_data += (0x1 << 30); // read
	pack_data += ((0x0c0 + 4 * (socket - 1) + 2 * (ch - 1)) << 16); // read

	DEBUG_PRINT("cmd: %s, %d, %d, %d, %d : 0x%08x\r\n", cmd, socket, ch, sp_cnt, sp_delay, pack_data);

	for (i = 0; i < sp_cnt; i++) {
		if (auto_trigger != 0 ) {
			tst_spi_write(spi_select, ch, trigger_data);
			HAL_Delay(1);
			tst_spi_read(spi_select, ch, trigger_data + 0x00800000, 0);
			HAL_Delay(1);
		}

		recv_data = tst_spi_read(spi_select, ch, pack_data, 0);

		acc_data += 0x0000FFFF & recv_data;
		HAL_Delay(sp_delay);
	}

	tx_buffer.size = sizeof(int);
	memcpy(tx_buffer.buf, &acc_data, sizeof(int));

	return result;
}

#define gen_pack(addr, data)	((addr << 16 ) & 0xFFFF0000 | (data & 0x0000FFFF))

u8 tst_mhvsu_config(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	char *cmd = NULL;
	unsigned int socket =  1;
	char cs = 0;
	char spi_sel = 0;
	unsigned int data_cs = 0;
	unsigned int res = 0;

	if (argc > 0) cmd = (char *) argv[1];
	if (argc < 4) return;

	socket = (unsigned char) strtoul(argv[2], NULL, 0);
	cs = (unsigned char) strtoul(argv[3], NULL, 0);
	data_cs = (unsigned int ) strtoul(argv[4], NULL, 0);
	spi_sel = (unsigned char) strtoul(argv[5], NULL, 0);

	DEBUG_PRINT("cmd: %s, %d, %d : 0x%08x, %d\r\n", cmd, socket, cs, data_cs,spi_sel);

	return result;
}

//#define _DATA_FMT(_sl,_so,_c,_d)		((_sl << 28) | (_so << 24) | (_c << 20) | (0xFFFF&(_d) << 0))
static unsigned int _DATA_FMT(int _sl,int _so,int _c,int _d)
{
//	DEBUG_PRINT(" DAT_FMT: %x, %x, %x, %x\r\n", _sl, _so, _c, ((_sl << 28) | (_so << 24) | (_c << 20) | (0xFFFF&(_d) << 0)));
	return (((_sl) << 28) | ((_so) << 24) | ((_c) << 20) | (0xFFFF&(_d) << 0));
}

// time-oridented
//
u8 tst_pg_run(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	unsigned int *cmd_buf = (unsigned int*)rx_buffer.buf;
	unsigned int *resp_buf = (unsigned int*)tx_buffer.buf;

	char *cmd = NULL;
	int n_count = 0;
	int n_delay = 0;
	char runmode = 0;
	char adc_trig = 0;
	int adc_delay = 0;
	char dbg_mode = 0;
	int test_mode = 0;
	int test_mode_cnt = 0;
	uint32_t m_socket = 0;
	uint8_t m_socket_ch1 = 0;
	uint8_t m_socket_ch2 = 0;
	int s_n, c_n;
	int i, j;
	int done = 0;
	char spi_cs = 0;
	char toggle_flag = 0;
	unsigned long ts_cur;
	unsigned long ts_cur_s;

	unsigned int tmp_data = 0;
	unsigned int rp_type = 0;
	unsigned int rp_data = 0;
	unsigned int rp_count = 0;

	if (argc > 1) cmd = (char *) argv[1];
	if (argc > 2) m_socket = (unsigned int) strtoul(argv[2], NULL, 0);
	if (argc > 3) runmode = (char) strtoul(argv[3], NULL, 0);
	if (argc > 4) adc_trig = (char) strtoul(argv[4], NULL, 0);
	if (argc > 5) adc_delay = (int) strtoul(argv[5], NULL, 0);
	if (argc > 6) n_count = (int) strtoul(argv[6], NULL, 0);
	if (argc > 7) test_mode = (int) strtoul(argv[7], NULL, 0);

	// m_socket : bit : ch2 : m_socket_h, ch1 : m_socket_l
	// #1 = 0b00000001
	// #2 = 0b00000010
	// #3 = 0b00000100
	// ...
	// #8 = 0b10000000
	// #0 = all or none
	
	m_socket_ch1 = (uint8_t)((m_socket >> 0) & 0xFF);
	m_socket_ch2 = (uint8_t)((m_socket >> 8) & 0xFF);

	if (m_socket_ch1 < 1) {
		m_socket_ch1 = 0;
	}
	if (m_socket_ch2 < 1) {
		m_socket_ch2 = 0;
	}

	// debug_mode
	// 		0 : normal
	// 		1 : debug mode
	dbg_mode = (runmode & 0xF0) >> 4;

	// runmode 
	// 		0 : normal
	// 		1 : testmode
	// 		2 : reserved
	runmode = runmode & 0x03;

	if (test_mode > 1) {
		test_mode_cnt = test_mode - 1;
	} else{
		test_mode_cnt = 1;
	}
	if (n_count < 1) {
		n_count = 1;
	}

	DEBUG_PRINT("cmd: %s, mode: %d, 0x%02x 0x%02x %d %d, [%d, %d]\r\n", cmd, runmode, m_socket_ch1, m_socket_ch2, adc_trig, adc_delay, spi_select,spi_cs);
	if (argc < 6) return;

	tmp_data = cmd_buf[0];

#define RP_IDLE		0x00
#define RP_DELAY 	0x01
#define RP_IMSET	0x02
#define RP_MEAS		0x03
#define RP_VOSET	0x04
#define RP_MEAS_IM	0x05

#define MODE_DELAY	100
#define MEAS_DELAY	1000

	rp_type = (tmp_data >> 24) & 0xFF;
	rp_data = (tmp_data >> 0)  & 0x00FFFFFF;
	if (rp_type == RP_IDLE)
		rp_count = rp_data;
	else
		return;

	int im_set = 0;
	int vout_set = 0;
	int meas_set = 0;
	int vout_data = 0;
	int im_data = 0;
	int meas_data = 0;
	int meas_im_data = 0;
	int meas_mode = 0;		// 1 : single , 0 : acc
	int meas_cnt = 0;		// 1 : single , 0 : acc
	unsigned int res = 0;
	int cnt = 0;

	// adc trigger!
	if (adc_trig > 0) {
		tst_spi_write(spi_select, spi_cs, gen_pack(0x011c, 0x0004)); 
	}

	if (adc_delay > 0) {
		HAL_Delay(adc_delay);
	}

	// count of result.
	resp_buf[0] = 0;
	meas_cnt = 1;
        
	ts_cur_s = HAL_GetTick();
	for (j = 0; j < n_count ;j++) {
		for (i = 1; i < (rp_count + 1); i++) {
			tmp_data = cmd_buf[i];
	
			rp_type = (tmp_data >> 24) & 0xFF;
			rp_data = (tmp_data >> 0)  & 0x00FFFFFF;
	
			if (dbg_mode > 0)
				DEBUG_PRINT("STEP %3d : 0x%08x : 0x%04x  0x%08x \r\n", i, tmp_data, rp_type, rp_data);
			// parser
			switch(rp_type) {
				case RP_DELAY:
					n_delay = rp_data * 10;		// 10 usec
                                        n_delay = n_delay / 1000;
					if ((int)(n_delay) < 1)  n_delay = 1;

					if (dbg_mode > 0)
						DEBUG_PRINT(" step %3d : delay : %d usec\r\n", i, n_delay);
					break;
				case RP_IMSET:
					im_data = rp_data & 0xffff;
					if (dbg_mode > 0)
						DEBUG_PRINT(" step %3d : im mode: ch1:0x%02x, ch2:0x%02x, %04x\r\n", i, m_socket_ch1, m_socket_ch2, im_data);
					im_set = 1;
					break;
				case RP_MEAS:
					meas_data = (0x00FFFF & rp_data) * 10;  // 10 usec
					meas_mode = (0xFF0000 & rp_data) >> 16;		// acc or single
	
					if (dbg_mode > 0)
						DEBUG_PRINT(" step %3d : meas: ch1:0x%02x, ch2:0x%02x, %04x\r\n", i, m_socket_ch1, m_socket_ch2, n_delay);
	
					if ((0x00FFFF & rp_data) > 0) {
						if (meas_data > MEAS_DELAY)
							n_delay = meas_data;
						else
							n_delay = MEAS_DELAY;

						// millisecond.
						n_delay = n_delay / 1000;
						if ((int)(n_delay) < 1)  n_delay = 1;

						meas_set = 1;
					} else {
						n_delay = 0;
						meas_set = 0;
					}
					break;
				case RP_VOSET:
					vout_data = rp_data & 0xffff;
					if (dbg_mode > 0)
						DEBUG_PRINT(" step %3d : vo set: ch1:0x%02x, ch2:0x%02x, %04x\r\n", i, m_socket_ch1, m_socket_ch2, vout_data);
					vout_set = 1;
					break;
				default:
					done = 1;
					break;
			}
			if (done > 0)
				break;
	
			// deley
			if (n_delay > 0) {
				if (im_set > 0) {
					// range mode 
					tst_spi_write(spi_select, spi_cs, gen_pack(0x0012, 0x0012)); // reg addr 
					tst_spi_write(spi_select, spi_cs, gen_pack(0x0010, 0x0000FFFF & im_data)); // data
	
					ts_cur = HAL_GetTick();
					if ((dbg_mode & 0x02) == 0) {
						// trigger
						tst_spi_write(spi_select, spi_cs, gen_pack(0x0114, 0x0002)); // trigger
						// wait until busy done
						cnt = 10;
						toggle_flag = 0;
		
						while((cnt--) > 0) {
							res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4194, 0), 0);		// read
							if ((res & 0x0F) > 0) {
								toggle_flag = 1;
							}
							if (toggle_flag > 0) {
								if ((res & 0x0F) == 0) {
									break;
								}
							}
						}
					} else {
						HAL_Delay(10);
					}
		
					if (dbg_mode > 0)
						DEBUG_PRINT("   MODE, 0x%08x,%d, %08x, %d\r\n", im_data, HAL_GetTick() - ts_cur, res, cnt);
	
					im_set = 0;
				}
	
				if (vout_set > 0) {
					// vout set
					for (s_n = 0; s_n < 8; s_n++) {
						c_n = 0;
						if ((m_socket_ch1 & (0x01 << s_n)) > 0) {
							tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4 + 2 * c_n, vout_data));
							if (dbg_mode > 0)
								DEBUG_PRINT("   VOUT %d-%d : %08x  \r\n", s_n+1, c_n+1,vout_data, res);
						}
						c_n = 1;
						if ((m_socket_ch2 & (0x01 << s_n)) > 0) {
							tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4 + 2 * c_n, vout_data));
							if (dbg_mode > 0)
								DEBUG_PRINT("   VOUT %d-%d : %08x  \r\n", s_n+1, c_n+1,vout_data, res);
						}
					}
					tst_spi_write(spi_select, spi_cs, gen_pack(0x0118, 0x01 << 3));
					HAL_Delay(10);
					res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4198, 0x0000), 0); // confirm
					if (dbg_mode > 0)
						DEBUG_PRINT("   VOUT-STAT %08x  0x%04x \r\n", vout_data, res);
	
					vout_set = 0;
					vout_data = 0;
				}
	
				if ((test_mode > 1) && (meas_set > 0)){
					test_mode_cnt = test_mode;
				} else{
					test_mode_cnt = 1;
				}
	
				if (dbg_mode > 0)
					DEBUG_PRINT("   MEAS_CNT : %d \r\n", test_mode_cnt);
	
				while (test_mode_cnt-- > 0) {
					DEBUG_PRINT("   ACTION :  %d  %d \r\n", test_mode_cnt, n_delay);
					if (n_delay > 0) {
						HAL_Delay(n_delay );
					}
		
					// applay delay.. 
					if ((meas_set > 0) && (adc_trig == 0)) {
						// measure..
						if (meas_mode == 0) {
							if (runmode == 0) {
								tst_spi_write(spi_select, spi_cs, gen_pack(0x011c, 0x0002));
								cnt = 1000;
								toggle_flag = 0;
								ts_cur = HAL_GetTick();
			
								if ((dbg_mode & 0x02) > 0) {
									HAL_Delay(10);
								} else {
									while((cnt--) > 0) {
										res = tst_spi_read(spi_select, spi_cs, gen_pack(0x419c, 0), 0);		// read
										if ((res & 0x0F) > 0) {
											toggle_flag = 1;
										}
										if (toggle_flag > 0) {
											if ((res & 0x0F) == 0) {
												break;
											}
										}
										HAL_Delay(10);
									}
								}
								if (dbg_mode > 0)
									DEBUG_PRINT("   ADC-s : etime ,%d, %08x, %d \r\n", HAL_GetTick() - ts_cur,res, cnt);
							}
			
						/////
							for (s_n = 0; s_n < 8; s_n++) {
								if (runmode == 0) {
									// runmode : normal
									c_n = 0;
									if ((m_socket_ch1 & (0x01 << s_n)) > 0) {
										res = tst_spi_read(spi_select, spi_cs, gen_pack(0x40c0 + 4 * s_n + 2 * c_n, 0), 0);

										if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

										resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
			
										if (dbg_mode > 0)
											DEBUG_PRINT("   ADC-s %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
									}
									c_n = 1;
									if ((m_socket_ch2 & (0x01 << s_n)) > 0) {
										res = tst_spi_read(spi_select, spi_cs, gen_pack(0x40c0 + 4 * s_n + 2 * c_n, 0), 0);

										if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

										resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
			
										if (dbg_mode > 0)
											DEBUG_PRINT("   ADC-s %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
									}
								} else {
									// runmode : test mode
									c_n = 0;
									if ((m_socket_ch1 & (0x01 << s_n)) > 0) {
										res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4280 + 4 * s_n, 0), 0);

										if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

										resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
			
										if (dbg_mode > 0)
											DEBUG_PRINT("   ADC-t %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
									}
									c_n = 1;
									if ((m_socket_ch2 & (0x01 << s_n)) > 0) {
										res = tst_spi_read(spi_select, spi_cs, gen_pack(0x42A0 + 4 * s_n, 0), 0);

										if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

										resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
			
										if (dbg_mode > 0)
											DEBUG_PRINT("   ADC-t %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
									}
								}
							}
						} else {
							tst_spi_write(spi_select, spi_cs, gen_pack(0x011c, 0x0004));
							cnt = 10000;
							toggle_flag = 0;
							ts_cur = HAL_GetTick();
		
							if ((dbg_mode & 0x02) == 0) {
								while((cnt--) > 0) {
									res = tst_spi_read(spi_select, spi_cs, gen_pack(0x419c, 0), 0);		// read
									if ((res & 0x0F) > 0) {
										toggle_flag = 1;
									}
									if (toggle_flag > 0) {
										if ((res & 0x0F) == 0) {
											break;
										}
									}
									HAL_Delay(10);
								}
							} else {
								HAL_Delay(10);
							}
		
							if (dbg_mode > 0)
								DEBUG_PRINT("   ADC-a : etime ,%d, %08x, %d \r\n", HAL_GetTick() - ts_cur,res, cnt);
							for (s_n = 0; s_n < 8; s_n++) {
								c_n = 0;
								if ((m_socket_ch1 & (0x01 << s_n)) > 0) {
									res = tst_spi_read(spi_select, spi_cs, gen_pack(0x40a0 + 4 * s_n + 2 * c_n, 0), 0);

									if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

									resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
		
									if (dbg_mode > 0)
										DEBUG_PRINT("   ADC-a %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
								}
								c_n = 1;
								if ((m_socket_ch2 & (0x01 << s_n)) > 0) {
									res = tst_spi_read(spi_select, spi_cs, gen_pack(0x40a0 + 4 * s_n + 2 * c_n, 0), 0);

									if ((dbg_mode & 0x02) > 0) res = 0x8000 + meas_cnt;	// dbg

									resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), s_n+1, c_n+1, res & 0xFFFF);
		
									if (dbg_mode > 0)
										DEBUG_PRINT("   ADC-a %d-%d %08x %08x \r\n", s_n+1, c_n+1, res, resp_buf[meas_cnt -1]);
								}
							}
						}
						meas_data = 0;
						if (dbg_mode > 0)
								DEBUG_PRINT("   ADC-done (%5d): etime ,%d \r\n", meas_cnt - 1, HAL_GetTick() - ts_cur);
					}
				} 
				meas_set = 0;
				meas_data = 0;
				n_delay = 0;
				// end
			}
			res = 0;
		}	// for (i..)
	}	// for (j..)

	if (test_mode > 0) {
		resp_buf[0] = meas_cnt - 1;	// count
		tx_buffer.size = 1 * sizeof(int);
		DEBUG_PRINT("   pg_run done : etime ,%d, %d \r\n", HAL_GetTick() - ts_cur_s, meas_cnt - 1);
	} else {
	   	tx_buffer.size = (meas_cnt - 1) * sizeof(int);
		DEBUG_PRINT("   pg_run done : etime ,%d \r\n", HAL_GetTick() - ts_cur_s);
	}

	return result;
}	//! tst_pg_run(int argc, void* data)

u8 tst_fg_run(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;

	char *cmd = NULL;
	int n_count = 0;
	int n_delay = 0;
	char adc_trig = 0;
	int trig_delay = 0;

	char dbg_mode = 0;
	int test_mode_cnt = 0;
	uint32_t m_socket = 0;
	uint8_t m_socket_ch1 = 0;
	uint8_t m_socket_ch2 = 0;
	uint8_t m_slot = 0;
	unsigned int value_prev = 0;
	unsigned int value = 0;

	int s_n, c_n;
	int i, j;
	int done = 0;
	char spi_cs = 0;
	char toggle_flag = 0;
	unsigned long ts_cur;
	unsigned long ts_cur_s;

	int vout_data = 0;
	int vout_init = 0;
	unsigned int res = 0;
	int cnt = 0;

	if (argc > 1) cmd = (char *) argv[1];
	if (argc > 2) m_socket = (unsigned int) strtoul(argv[2], NULL, 0);
	if (argc > 3) adc_trig = (char) strtoul(argv[3], NULL, 0);
	if (argc > 4) trig_delay = (int) strtoul(argv[4], NULL, 0);
	if (argc > 5) vout_data = (unsigned int ) strtoul(argv[5], NULL, 0);
	if (argc > 6) vout_init = (unsigned int ) strtoul(argv[6], NULL, 0);
	if (argc > 7) n_delay = (unsigned int) strtoul(argv[7], NULL, 0);
	if (argc < 7) return;

	// m_socket : bit : ch2 : m_socket_h, ch1 : m_socket_l
	// #1 = 0b00000001
	// #2 = 0b00000010
	// #3 = 0b00000100
	// ...
	// #8 = 0b10000000
	// #0 = all or none
	
	m_socket_ch1 = (uint8_t)((m_socket >> 0) & 0xFF);
	m_socket_ch2 = (uint8_t)((m_socket >> 8) & 0xFF);
	m_slot = (uint8_t)((m_socket >> 16) & 0xFF);

	if (m_socket_ch1 < 1) {
		m_socket_ch1 = 0;
	}

	if (m_socket_ch2 < 1) {
		m_socket_ch2 = 0;
	}

	vout_init = vout_init & 0xFFFF;
	vout_data = vout_data & 0xFFFF;
	DEBUG_PRINT("cmd: %s, 0x%02x 0x%02x %d 0x%04x, 0x%04x\r\n", cmd, m_socket_ch1, m_socket_ch2, trig_delay, vout_init, vout_data);

	// channel
	for (s_n = 0; s_n < 8; s_n++) {
		c_n = 0;
		if ((m_socket_ch1 & (0x01 << s_n)) > 0) {
			break;
		}
		c_n = 1;
		if ((m_socket_ch2 & (0x01 << s_n)) > 0) {
			break;
		}
	}
	DEBUG_PRINT("   channel : %d, %d-%d, 0x%08x \r\n", m_slot, s_n+1, c_n+1, vout_data );

	value_prev = MIO_RD(0x00600000);
	if (adc_trig > 0) {
		tst_spi_write(spi_select, spi_cs, gen_pack(0x011c, 0x0004)); 
		DEBUG_PRINT("   channel : trigger : 0x%08x \r\n", value_prev);
	}

	//msg = "CMD: ccmd,mio_wr,0x0c000000,%s"%(hex(slot_cs))
	value = 0xFFFF ^ (0x0001 << m_slot);
	MIO_WR(0x00600000, value);	// slot
	DEBUG_PRINT("   channel : 0x%08x 0x%08x \r\n", value_prev, value);

	if (trig_delay > 0) {
		HAL_Delay(trig_delay);
		DEBUG_PRINT("   channel : delay : %d \r\n", trig_delay);
	}

	/////////////////////////////////////////////////////////////
	// set voltage
	// 		: apply one channel
	if (c_n == 0 ) {
		tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4, vout_data));
		tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4 + 2, 0));
	} else {
		tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4, 0));
		tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4 + 2, vout_data));
	}
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0118, 0x01 << 3));

	// wait until busy done
	cnt = 10;
	toggle_flag = 0;

	while((cnt--) > 0) {
		res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4198, 0), 0);		// read
		if ((res & 0x0F) > 0) {
			toggle_flag = 1;
		}
		if (toggle_flag > 0) {
			if ((res & 0x0F) == 0) {
				break;
			}
		}
	}
	DEBUG_PRINT("   channel : vout done : 0x%08x \r\n", vout_data);
	
	/////////////////////////////////////////////////////////////
	// delay
	HAL_Delay(n_delay * 10);
	DEBUG_PRINT("   channel : delay : %d \r\n", n_delay * 10);

	
	/////////////////////////////////////////////////////////////
	// reset voltage (set zero)
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0060 + (s_n) * 4 + 2 * c_n, vout_init));
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0118, 0x01 << 3));

	// wait until busy done
	cnt = 10;
	toggle_flag = 0;

	while((cnt--) > 0) {
		res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4198, 0), 0);		// read
		if ((res & 0x0F) > 0) {
			toggle_flag = 1;
		}
		if (toggle_flag > 0) {
			if ((res & 0x0F) == 0) {
				break;
			}
		}
	}
	DEBUG_PRINT("   channel : vout  : 0x%08x \r\n", vout_init);

	MIO_WR(0x00600000, value_prev);	
	DEBUG_PRINT("   channel : done: 0x%08x \r\n", value_prev);

	return result;
}	//! tst_fg_run(int argc, void* data)
	
//////////////////////////////////////////////////////////////////////////////////////////
u8 tst_hp_run(int argc, void* data)
{
	u8 result = 1;

	char **argv = (char**)data;
	unsigned int *cmd_buf = (unsigned int*)rx_buffer.buf;
	unsigned int *resp_buf = (unsigned int*)tx_buffer.buf;

	char *cmd = NULL;
	char dbg_mode = 0;
	int test_mode = 0;
	unsigned int tmp_data = 0;

	char toggle_flag = 0;
	unsigned long ts_cur;
	unsigned long ts_cur_s;
	int i, d, k;
	char spi_cs = 0;

	uint32_t m_socket = 0;
	// mu (meas_unit) range : 0 ~ 255)
	unsigned int mu_st = 0;
	unsigned int mu_step = 0;
	unsigned int mu_end = 0;
	unsigned int ch_mask = 0xFF;

	unsigned int ms_front_us = 0;
	unsigned ms_post_us = 0;
	unsigned adc_exp_time = 0;

	if (argc > 1) cmd = (char *) argv[1];
	if (argc > 2) dbg_mode = (char) strtoul(argv[2], NULL, 0);
	if (argc > 3) mu_st = (unsigned int) strtoul(argv[3], NULL, 0);
	if (argc > 4) mu_step = (unsigned int) strtoul(argv[4], NULL, 0);
	if (argc > 5) mu_end = (unsigned int) strtoul(argv[5], NULL, 0);
	if (argc > 6) ms_front_us = (int) strtoul(argv[6], NULL, 0);
	if (argc > 7) ms_post_us = (int) strtoul(argv[7], NULL, 0);
	if (argc > 8) adc_exp_time = (int) strtoul(argv[8], NULL, 0);
	if (argc > 9) ch_mask = (int) strtoul(argv[9], NULL, 0);
	if (argc > 10) test_mode = (int) strtoul(argv[10], NULL, 0);
	if (argc < 10) return;

	DEBUG_PRINT("cmd: %s, mode: %d, mu : %d, %d, %d, %d, %d\r\n", cmd, dbg_mode, mu_st, mu_step, mu_end, adc_exp_time, test_mode);

	// mu (meas_unit) range : 0 ~ 255)
	if ((mu_st < 0) || (mu_st > 255)) {
		return ;	// error
	}
	if (mu_st < 1) 		mu_st = 0;
	if (mu_st > 255) 	mu_st = 255;

	if (mu_end < 1) 	mu_end = 0;
	if (mu_end > 255) 	mu_end = 256;

	// swapping
//	ch_mask = ((ch_mask & 0x0F) << 4) | ((ch_mask & 0xF0) >> 4);
//	ch_mask = ((ch_mask & 0x0F) << 4) | ((ch_mask & 0xF0) >> 4);

	if (m_socket < 1) {
		m_socket = 0;
	}

	if (ms_post_us < 0)
		ms_post_us = 0;
	if (ms_front_us < 0)
		ms_front_us = 0;

	tmp_data = cmd_buf[0];

	/////////////////
	int im_set = 0;
	int vout_set = 0;
	int vout_data = 0;
	int im_data = 0;
	int meas_im_data = 0;
	int meas_mode = 0;		// 1 : single , 0 : acc
	int meas_cnt = 0;		// 1 : single , 0 : acc
	unsigned int res = 0;
	int cnt = 0;
	int s_n = 0;
	int c_n=0;
	int prev_ch = -1;

	// adc trigger!
	ts_cur_s = HAL_GetTick();

	// init mux-switching 
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0014, 0x00001)); 					// 0x014 : enable
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0016, ((0x01 << 8) | (0x0002)))); 	// socket:1 cs:2

	// count of result.
	resp_buf[0] = 0;
	meas_cnt = 1;

	for (i = mu_st; i < (mu_end); i+=mu_step) {
		// mask
		if (i > 0 ) {
			if (ch_mask < 0xFF)  {
	//			if (((i + 1) & ch_mask) != (i+1)) {
				if (((i) & ch_mask) != (i)) {
					continue;
				}
			}
		}
		if (dbg_mode > 0)
			DEBUG_PRINT("-->   MASK : 0x%08x  , %d, %d, %d \r\n", ch_mask, i, ch_mask & (i+1), prev_ch);

		if (1) {
			// mux- switching
			{
				// 0. Chagne MU

				ts_cur = HAL_GetTick();
// config cs & socket info

				d  =  0x1010;		// enable mux
				
//				k = i << mu_st;
				k = i;
				d  += (k & 0x0F)<<8;
				d  += (k >> 4) & 0x000F;

				tst_spi_write(spi_select, spi_cs, gen_pack(0x0010, d)); 				// 0x014 : enable
				if (dbg_mode > 0)
					DEBUG_PRINT("   MUX : data 0x%08x 0x%08x \r\n", i, d);

				// 4. spio trigger
				tst_spi_write(spi_select, spi_cs, gen_pack(0x0114, 0x0002));
				cnt = 1000;
				res = 0;

				// 5. wait done
				if (ms_post_us > 0) {
					HAL_Delay(ms_post_us);
				} else {
					toggle_flag = 0;
					while((cnt--) > 0) {
						res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4194, 0), 0);		// read
						if ((res & 0x0F) > 0) {
							toggle_flag = 1;
						}
						if (toggle_flag > 0) {
							if ((res & 0x0F) == 0) {
								break;
							}
						}
					}
				}
	
				if (dbg_mode > 0)
					DEBUG_PRINT("   MUX : etime ,%d, %08x, %d \r\n", HAL_GetTick() - ts_cur,res, cnt);
			}
			// measure..
			{
				// 1. trigger ADC
				ts_cur = HAL_GetTick();
				tst_spi_write(spi_select, spi_cs, gen_pack(0x011c, 0x0004));

				// 2. wait ADC
				HAL_Delay(adc_exp_time);
#if 0
				cnt = 1000;
				toggle_flag = 0;
				while((cnt--) > 0) {
					res = tst_spi_read(spi_select, spi_cs, gen_pack(0x419c, 0), 0);		// read
					if ((res & 0x0F) > 0) {
						toggle_flag = 1;
					}
					if (toggle_flag > 0) {
						if ((res & 0x0F) == 0) {
							break;
						}
					}
				}
				if (dbg_mode > 0)
					DEBUG_PRINT("   ADC-a : etime ,%d, %08x, %d\n", HAL_GetTick() - ts_cur,res, cnt);

#else
				cnt = 1000;
				toggle_flag = 0;
				while((cnt--) > 0) {
					res = tst_spi_read(spi_select, spi_cs, gen_pack(0x419c, 0), 0);		// read
					if ((res & (0x01 << 18)) == 0) {
						break;
					}
				}
				if (dbg_mode > 0)
					DEBUG_PRINT("   ADC-a : etime ,%d, %08x, %d \r\n", HAL_GetTick() - ts_cur,res, cnt);

#endif
				HAL_Delay(ms_front_us);
			}

			// store data
			{
				s_n = 0;
				c_n = 0;
				if (test_mode == 1) {
					res = tst_spi_read(spi_select, spi_cs, gen_pack(0x40a0 + 4 * s_n + 2 * c_n, 0), 0);
					resp_buf[meas_cnt++] = _DATA_FMT(0xF&(res>> 26), 0xF & (k>>4), 0xF & k, res & 0xFFFF);
				}
			}

			// end
		}	// if (1) 
		res = 0;
	}

	// close mux-switching
	ts_cur = HAL_GetTick();

	d  =  0;		// disable mux
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0010, d)); 				// 0x014 : 
	if (dbg_mode > 0)
		DEBUG_PRINT("   MUX : data 0x%08x 0x%08x \r\n", i, d);

	// 4. spio trigger
	tst_spi_write(spi_select, spi_cs, gen_pack(0x0114, 0x0002));
	cnt = 1000;

	// 5. wait done
	toggle_flag = 0;
	while((cnt--) > 0) {
		res = tst_spi_read(spi_select, spi_cs, gen_pack(0x4194, 0), 0);		// read
		if ((res & 0x0F) > 0) {
			toggle_flag = 1;
		}
		if (toggle_flag > 0) {
			if ((res & 0x0F) == 0) {
				break;
			}
		}
	}
	if (dbg_mode > 0)
		DEBUG_PRINT("   MUX : etime ,%d, %08x, %d \r\n", HAL_GetTick() - ts_cur,res, cnt);
	else
		HAL_Delay(10);

	//////////////////////////////
	DEBUG_PRINT("   hg_run done : etime ,%d, %d \r\n", HAL_GetTick() - ts_cur_s, meas_cnt);
	resp_buf[0] = meas_cnt;	// count
	tx_buffer.size = 1 * sizeof(int);

	HAL_Delay(10);

	return result;

}

void MemoryHexDump(void *address, int size )
{
	int lp1,lp2,lp3;
	unsigned char *ptrData;


	ptrData = (unsigned char *)address;

	for( lp1 = 0; lp1 < size*4; lp1 += 16 )
	{
		// 주소 표시 
		DEBUG_PRINT( "%04X-%04X :",  (((unsigned int)ptrData)>>16)&0xFFFF,
				((unsigned int)ptrData)     &0xFFFF  );

		// 총 4번 표시 
		for( lp2 = 0; lp2 < 4; lp2++ )
		{
			for( lp3 = 0; lp3 < 4; lp3++ )
			{
				DEBUG_PRINT( "%02X", ptrData[ lp2 * 4 + lp3 ] & 0xFF );
			} 
			DEBUG_PRINT( " " );
		}

		DEBUG_PRINT( "  " );
		for( lp3 = 0; lp3 < 16; lp3++ )
		{
			if      ( ptrData[lp3] < ' ' ) DEBUG_PRINT( "." );
			else if ( ptrData[lp3] > '~' ) DEBUG_PRINT( "." ); 
			else    DEBUG_PRINT("%c", ptrData[lp3]  );
		} 

		DEBUG_PRINT( "\n" );
		ptrData += 16;
	}
}

//==============================================================================
