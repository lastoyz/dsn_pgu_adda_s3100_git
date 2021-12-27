//******************************************************************************
// File Name: Cmd_SmuTest.c
// Description: Commands for test 
//******************************************************************************
#include "Cmd_SmuTest.h"
#include "App_SmuTest.h"



static tst_smu_console_cmd_t tst_SMU_cmd[] = {

    {"STN", 		                ProcessRETURN_OK},  // for TREX SERVER compatible
    {"SYS", 		                ProcessSys},
    {"SET", 		                ProcessSet},
    {"CAL", 		                ProcessCal},

	{"DV", 		                    ProcessSMFV},      // Force V
    {"DI", 		                    ProcessSMFI},      // Force I
    {"TV", 		                    ProcessSMMV},      // Measure V
    {"TI", 		                    ProcessSMMI},      // Measure I

	{"SMVS", 		                ProcessSMFV},      // Force V
    {"SMIS", 		                ProcessSMFI},      // Force I
    {"SMVM", 		                ProcessSMMV},      // Measure V    
    {"SMIM", 		                ProcessSMMI},      // Measure I

    {"SMU_MFV", 		            ProcessSMFVM},      // Multi Force V
    {"SMU_MFI", 		            ProcessSMFIM},      // Multi Force I
    {"SMU_MMV", 		            ProcessSMMVM},      // Multi Measure V    
    {"SMU_MMI", 		            ProcessSMMIM},      // Multi Measure I

    // {"SMU_MFV2", 		            ProcessSMFVM2},      // Multi2 Force V
    // {"SMU_MFI2", 		            ProcessSMFIM2},      // Multi2 Force I
    // {"SMU_MMV2", 		            ProcessSMMVM2},      // Multi2 Measure V    
    // {"SMU_MMI2", 		            ProcessSMMIM2},      // Multi2 Measure I    


    {"SMU_OUT_FORCE_RLY", 		    ProcessRETURN_OK},
	{"SMU_OUT_SENSE_RLY", 		    ProcessRETURN_OK},
	{"SMU_FORCE_RLY",			    ProcessSMU_FORCE_RLY},

    // {"GNDU_OUT_FORCE_RLY",		    ProcessGNDU_FORCE_RLY},
    {"GNDU_FORCE_RLY",		        ProcessGNDU_FORCE_RLY},
	// {"GNDU_FORCE_V",		ProcessGNDU_FORCE_RLY},

    {"RDPLF",			            ProcessRDPLF},
    {"WRPLF",			            ProcessWRPLF},
    {"LDPLF",			            ProcessLDPLF},

    {"DBG",			                ProcessDBG},

    {"SMUTEST",			            ProcessSMUTEST},



	{NULL, 			NULL}
};


u8 Cmd_SmuTest(u16 cmdc, void *pCmdv, u16 argc, void *pArgv)
{
    u8	result = 1;
    u8  res = 0;

    char **ppCmdv = (char **) pCmdv;

    tst_smu_console_cmd_t *c_smu_cmd = tst_SMU_cmd;
    
    char *cmd = NULL;
    char found = 0;

    
    if (cmdc > 0) cmd = ppCmdv[0];
    
    //-----------------------------------------------
    // execute the command list   

    do {
        if (CMD_Compare((u8 *)cmd, (char *)c_smu_cmd->fn_name)) {
            found = 1;
            //TRACE(";%s\r\n", (u8*)c_smu_cmd->fn_name);
            res = (c_smu_cmd->fn)(pCmdv, argc, pArgv);
            if (res == 0) goto CMD_ERROR;

        }
    } while((++c_smu_cmd)->fn_name != NULL);

    if (found == 0) {
CMD_ERROR:
        result = 0;
        //errFlag++;
    }

    return result;
}

