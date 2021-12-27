//******************************************************************************
// File Name: Cmd_PguTest.c
// Description: Commands for test 
//******************************************************************************
#include "Cmd_PguTest.h"
#include "App_PguTest.h"

static tst_console_cmd_t tst_PGU_cmd[] = {
	{"PGU_TEST", 		ProcessPGU_TEST},
	

	{NULL, 			NULL}
};

u8 Cmd_PguTest(u16 cmdc, void *pCmdv, u16 argc, void *pArgv)
{
    u8	result = 1;
    u8  res = 0;

    char **ppCmdv = (char **) pCmdv;

    tst_console_cmd_t *c_pgu_cmd = tst_PGU_cmd;
    
    char *cmd = NULL;
    char found = 0;
    int count = 0;
    int i;
    u32* tx_buf = NULL;

    
    if (cmdc > 0) cmd = ppCmdv[0];
    
    //-----------------------------------------------
    // execute the command list   

    do {
        if (CMD_Compare((u8 *)cmd, (char *)c_pgu_cmd->fn_name)) {
            found = 1;
            //TRACE(";%s\r\n", (u8*)c_pgu_cmd->fn_name);
            res = (c_pgu_cmd->fn)(argc, pArgv);
            if (res == 0) goto CMD_ERROR;

        }
    } while((++c_pgu_cmd)->fn_name != NULL);

    if (found == 0) {
CMD_ERROR:
        result = 0;
        //errFlag++;
    }

    return result;

}