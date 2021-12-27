//******************************************************************************
// File Name: Cmd_MlccTest.c
// Description: Commands for test 
//******************************************************************************
#include "Cmd_MlccTest.h"
#include "App_MlccTest.h"

#define TRACE_RAW Ext_Serial_Printf

static char cmd_buffer[128];

// a -> A
char* CMD_Strhwr(const u8 *pData)
{
	u32 cnt = 0;

	do{
		if(pData[cnt] == 0)		break;

		if(pData[cnt] < 'a')
		{
                        cmd_buffer[cnt] = pData[cnt];
			cnt++;                                                
			continue;
		}
		if(pData[cnt] > 'z')
		{
                        cmd_buffer[cnt] = pData[cnt];
			cnt++;                        
			continue;
		}

		cmd_buffer[cnt] = pData[cnt] - 0x20;

		cnt++;
	}while(1);
	cmd_buffer[cnt] = 0;

	return cmd_buffer;
}

// typedef u8 (*tst_console_fn_t)(int, void*);

// typedef struct _tst_console_cmd {
// 	const char *fn_name;
// 	tst_console_fn_t fn;
// } tst_console_cmd_t;

static tst_console_cmd_t tst_console_cmd[] = {
	{"init", 		tst_init},
	{"enable", 		tst_enable},
	{"disable",		tst_disable},
	{"spi_wr", 		tst_spi_send},
	{"spi_rd", 		tst_spi_recv},
	{"mio_rd", 		tst_mem_io_rd},
	{"mio_wr", 		tst_mem_io_wr},
	{"adc_rd", 		tst_adc_rd},
	{"adc_fifo",	tst_adc_fifo},
	{"mv_cfg", 		tst_mhvsu_config},
	{"pg_run", 		tst_pg_run},
	{"fg_run", 		tst_fg_run},
	{"hp_run", 		tst_hp_run},
	{NULL, 			NULL}
};

u8 Cmd_MlccTest(void *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8	result = 1;
	u8  res = 0;
	u16	argc = *pArgc;

	tst_console_cmd_t *c_cmd = tst_console_cmd;
	char *cmd = NULL;
	char found = 0;
	int count = 0;
	int i;
	u32* tx_buf = NULL;

	if (argc > 0) cmd = (char *) pArgv[0];
	if (cmd == NULL)
		return -1;

	if(CMD_Compare(pArgv[0], "enable"))
	{
		TRACE_RAW(";ENABLE");

		if(argc != 2)		goto CMD_MLCC_ERROR;

	}
	else if(CMD_Compare(pArgv[0], "disable"))
	{
		TRACE_RAW(";DISABLE");

		if(argc != 2)		goto CMD_MLCC_ERROR;

	}
	else 
	{
		//-----------------------------------------------
		// execute the command list
		TRACE("TST CONSOLE.. %s, %d\r\n", cmd, argc);
		tx_buffer.size = 0;
	
		do {
	
			if (CMD_Compare((u8 *)cmd, (char *)c_cmd->fn_name)) {
				found = 1;
				TRACE_RAW(";%s", CMD_Strhwr( (u8*)c_cmd->fn_name));
				res = (c_cmd->fn)(argc, pArgv);
				if (res == 0) goto CMD_MLCC_ERROR;

			}
	
		} while((++c_cmd)->fn_name != NULL);
	
		if (found == 0) {
CMD_MLCC_ERROR:
			result = 0;
		}
	}

	if ((result > 0 ) && (found > 0) ) { 
		// application command.
		if (tx_buffer.size > 0) {
			tx_buf = (u32*)tx_buffer.buf;
			count = tx_buffer.size /sizeof(int);
			if (count > 0) {
				for (i = 0; i < count ; i++ ) {
					TRACE_RAW(";0x%08x", tx_buf[i]);
				}
			}
		}
	}

	if(result)		TRACE_RAW(";OK");
	else			TRACE_RAW(";ERROR");

	return result;
}

//==============================================================================
