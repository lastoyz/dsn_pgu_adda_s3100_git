//******************************************************************************
// File Name: shell.c
// Description: 명령어 처리 스레드
//******************************************************************************

#ifndef	_APP_MLCCTEST_H
#define	_APP_MLCCTEST_H

#include "top_core_info.h"


#ifdef __cplusplus
extern "C" {
#endif 
// mlcc
#define DOWNLOAD_RX_RAM_ADDR			SDRAM_FPGA_READ_ADRS
#define DOWNLOAD_TX_RAM_ADDR			(SDRAM_FPGA_READ_ADRS + 0x01000000)
//////////////////////////////////////////////////////////////

u8 tst_init(int argc, void* data);
u8 tst_enable(int argc, void* data);
u8 tst_disable(int argc, void* data);
//////////////////////////////////////////////////////////////
u8 tst_spi_send(int argc, void* data);
u8 tst_spi_recv(int argc, void* data);

u8 tst_mem_io_rd(int argc, void* data);
u8 tst_mem_io_wr(int argc, void* data);

u8 tst_adc_fifo(int argc, void* data);
u8 tst_adc_rd(int argc, void* data);
u8 tst_mhvsu_config(int argc, void* data);
u8 tst_pg_run(int argc, void* data);
u8 tst_fg_run(int argc, void* data);
u8 tst_hp_run(int argc, void* data);
//==============================================================================
//

typedef struct _buffer_t 
{
	int size ;
	unsigned char* buf;
} buffer_t;
extern buffer_t tx_buffer;
extern buffer_t rx_buffer;

#ifdef __cplusplus
}
#endif 

#endif
