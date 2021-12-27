//#include "stdafx.h"
//#include <stdio.h>
//#include <stdlib.h>

//#include "systype.h"
//#include "OsTimer.h"

//#include "seeprom.h"
//#include "spidrv.h"
//include "App_teginfo.h"
#include "App_teginfo.h"

//#include "top_core_info.h"
//#include "UserDefine.h"




TModuleInfo module_info[MAX_MODULE];
TModuleInfo ebox_module_info[MAX_MODULE_EBOX];
//
//char *slot_name[] = {"CPU", "IO1", "IO2", "VSM", "SMU1", "SMU2", "SMU3", "SMU4", "EXT"}; 
//char *ebox_slot_name[] = {"HPU1", "HPU2", "HPU3", "HPU4"}; 


/*
// calibration parameter값들을 읽어서 calibration factor 계산
void load_calib(void)
{
    int ch;
    
    read_adc_calib();
    read_vsm_calib();

    for (ch=0; ch<4; ch++) read_smu_calib(ch);
    for (ch=0; ch<4; ch++) ebox_read_smu_calib(ch);

    calculate_calib();
}
*/

BOOL write_smu_calib_para(int ch)
{
    u32 slotCS = _SPI_SEL_SLOT(ch + 1);
    long magic;
    int i;
    u16 adrs = 0;

    eeprom_write_data_u32(slotCS, SPI_SEL_M0, adrs, MODULE_MAGIC_CODE); adrs += 4;

    for (i=0; i<NO_OF_VRANGE; i++) 
	{		
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_vsrc_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_vsrc_offset_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_vmsr_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_vmsr_offset_calib[ch][i]); adrs += 4;
	}

    for (i=0; i<NO_OF_IRANGE; i++) 
	{	
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_ipsrc_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_ipsrc_offset_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_ipmsr_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_ipmsr_offset_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_insrc_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_insrc_offset_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_inmsr_gain_calib[ch][i]); adrs += 4;
        eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_inmsr_offset_calib[ch][i]); adrs += 4;
	}

    adrs = 0;
    magic = eeprom__read__data_u32(slotCS, SPI_SEL_M0, adrs); adrs += 4;

    if (magic != MODULE_MAGIC_CODE) 
	{
		TRACE("Magic code is: 0x%x\r\n", magic);
		goto compare_err;
	}

    for (i=0; i<NO_OF_VRANGE; i++) 
	{
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_vsrc_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_vsrc_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_vmsr_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_vmsr_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
    }
    
    for (i=0; i<NO_OF_IRANGE; i++) 
	{
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_ipsrc_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_ipsrc_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_ipmsr_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_ipmsr_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_insrc_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_insrc_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_inmsr_gain_calib[ch][i]) goto compare_err;
        adrs += 4;
        if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_inmsr_offset_calib[ch][i]) goto compare_err;
        adrs += 4;
    }    

    TRACE("# Compare Ok. Calibration Parameter Write Completed: SMU%d.\r\n", ch+1);
    return TRUE;

    compare_err:

    TRACE("# Compare Error. Calibration Parameter Write Error: SMU%d.\r\n",ch+1);
    return FALSE;
}


//------------------------------------------------------------------------------
BOOL write_smu_zero_calib_para(int ch)
{
    u32 slotCS = _SPI_SEL_SLOT(ch + 1);
    long magic;
    u16 adrs;

    adrs = SMU_ZERO_CALIB_OFFSET;

    eeprom_write_data_u32(slotCS, SPI_SEL_M0, adrs, MODULE_MAGIC_CODE); adrs += 4;

    eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_ipmsr_offset[ch][SMU_1nA_RANGE]); adrs += 4;
    eeprom_write_data_float(slotCS, SPI_SEL_M0, adrs, smu_inmsr_offset[ch][SMU_1nA_RANGE]); adrs += 4;

    adrs = SMU_ZERO_CALIB_OFFSET;

    magic = eeprom__read__data_u32(slotCS, SPI_SEL_M0, adrs); adrs += 4;

    if (magic != MODULE_MAGIC_CODE) 
	{
		TRACE("Magic code is: 0x%x\r\n", magic);
		goto compare_err;
	}

    if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_ipmsr_offset[ch][SMU_1nA_RANGE]) goto compare_err;
    if (eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs) != smu_inmsr_offset[ch][SMU_1nA_RANGE]) goto compare_err;

    TRACE("# Compare Ok. Calibration Parameter Write Completed: SMU%d.\r\n", ch+1);
    return TRUE;

    compare_err:
    
	TRACE("# Compare Error. Calibration Parameter Write Error: SMU%d.\r\n",ch+1);
    return FALSE;
}

// for debug
/*
BOOL write_smu_zero_calib_para(int ch)
{
    long magic;

    int i;
    short addr;

	long read_val;
    
	addr = SMU_CALIB_OFFSET;
    smu_seeprom_on(ch);
	spi_write_long(addr, 0xDEB); addr += 4;
    
   	spi_write_long(addr, 0xAAAAAAAA); addr += 4;
	spi_write_long(addr, 0xFFFFFFFF); addr += 4;
	spi_write_long(addr, 0x55555555); addr += 4;

	seeprom_off();
   
	addr = SMU_CALIB_OFFSET;
	smu_seeprom_on(ch);
    magic = spi_read_long(addr); addr += 4;
	
    if (magic != 0xDEB) 
	{
		printf("Magic Code Error. Magic code is: 0x%x\n", magic);
	//	goto compare_err;
	}

//	printf("Magic code is: 0x%x\n", magic);

	read_val = spi_read_long(addr); addr += 4;
	printf("SMU%d read value: 0x%x\n", ch+1, read_val);
	read_val = spi_read_long(addr); addr += 4;
	printf("SMU%d read value: 0x%x\n", ch+1, read_val);
	read_val = spi_read_long(addr); addr += 4;
	printf("SMU%d read value: 0x%x\n\n", ch+1, read_val);
	
    seeprom_off();
//    PrintF("# Compare Ok.\r\n");
//    PrintF("# \r\n");

//	printf("# Compare Ok: SMU%d.\n", ch+1);
    return TRUE;
}
*/

// sbcho@20211220
BOOL write_gndu_calib_para(void)
{
    long magic;
    int i;

    u16 adrs;

    adrs = GNDU_CALIB_OFFSET;

    eeprom_write_data_u32(SLOT_CS0, SPI_SEL_M0, adrs, MODULE_MAGIC_CODE); adrs += 4;

    eeprom_write_data_float(SLOT_CS0, SPI_SEL_M0, adrs, gndu_vsrc_gain_calib); adrs += 4;
    eeprom_write_data_float(SLOT_CS0, SPI_SEL_M0, adrs, gndu_vsrc_offset_calib); adrs += 4;

    for (i=0; i<NO_OF_VRANGE; i++) 
	{		
        eeprom_write_data_float(SLOT_CS0, SPI_SEL_M0, adrs, gndu_vmsr_gain_calib[i]); adrs += 4;
        eeprom_write_data_float(SLOT_CS0, SPI_SEL_M0, adrs, gndu_vmsr_offset_calib[i]); adrs += 4;
    }

    adrs = GNDU_CALIB_OFFSET;

    magic = eeprom__read__data_u32(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;

    if(magic != MODULE_MAGIC_CODE) 
	{
        TRACE("# Magic code is: 0x%x\n", magic);
        goto compare_err;
	}

    if(eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs) != gndu_vsrc_gain_calib) goto compare_err;
    adrs += 4;
    if(eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs) != gndu_vsrc_offset_calib) goto compare_err;
    adrs += 4;

    for (i=0; i<NO_OF_VRANGE; i++) 
	{
        if(eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs) != gndu_vmsr_gain_calib[i]) goto compare_err;
        adrs += 4;
        if(eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs) != gndu_vmsr_offset_calib[i]) goto compare_err;
        adrs += 4;
    }

	TRACE("# Compare Ok. Calibration Parameter Write Completed: GNDU.\r\n");
    return TRUE;

    compare_err:
    TRACE("# Compare Error. Calibration Parameter Write Error: GNDU.\r\n");
    return FALSE;
}

/*
// for debug
void write_smu_calib_para(int ch)
{
    long magic;

    int i;
    short addr;
    
	addr = SMU_CALIB_OFFSET;
    smu_seeprom_on(ch);
	spi_write_long(addr, MODULE_MAGIC_CODE); addr += 4;
        
    spi_write_float(addr, 1.2345); addr += 4;
    spi_write_float(addr, 2.3456); addr += 4;      
    spi_write_float(addr, 3.4567); addr += 4;
    spi_write_float(addr, 4.5678); addr += 4;
	spi_write_float(addr, 5.6789); addr += 4;
    spi_write_float(addr, 6.7890); addr += 4;      
    spi_write_float(addr, 7.8901); addr += 4;
    spi_write_float(addr, 8.9012); addr += 4;
      	
	seeprom_off();
   
	addr = SMU_CALIB_OFFSET;
	smu_seeprom_on(ch);
    magic = spi_read_long(addr); addr += 4;
	
    
	printf("Magic code is: 0x%x\n", magic);
	printf("1st code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("2nd code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("3rd code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("4th code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("5th code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("6th code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("7th code is: %f\n", spi_read_float(addr)); addr += 4;
	printf("8th code is: %f\n", spi_read_float(addr)); addr += 4;
	

	
    seeprom_off();
//    PrintF("# Compare Ok.\r\n");
//    PrintF("# \r\n");


}
*/



void read_smu_calib_para(int ch)
{
    u32 slotCS = _SPI_SEL_SLOT(ch + 1);
    long magic;
    int i;

    u16 adrs = 0;

    magic = eeprom__read__data_u32(slotCS, SPI_SEL_M0, adrs); adrs += 4;

    if(magic != MODULE_MAGIC_CODE) 
	{
		smu_clear_calib_para(ch);
		TRACE("# <Read Calibration Parameter Error> or <Not Calibrated> : SMU%d\r\n", ch+1);
        return;
    }
    else //2015.12.22
	{
		TRACE("# <Read Calibration Parameter Success> : SMU%d\r\n", ch+1);
	}


    
    for (i=0; i<NO_OF_VRANGE; i++) 
	{
        smu_vsrc_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_vsrc_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_vmsr_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_vmsr_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
    }
        
    for (i=0; i<NO_OF_IRANGE; i++) 
	{
        smu_ipsrc_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_ipsrc_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_ipmsr_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_ipmsr_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_insrc_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_insrc_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_inmsr_gain_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
        smu_inmsr_offset_calib[ch][i] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
    }
}

//====================================================================================================
// SMU보드의 serial EEPROM에서 calibration parameter값들을 읽는다
void read_smu_zero_calib_para(int ch, long *magic)
{
    u32 slotCS = _SPI_SEL_SLOT(ch + 1);
    u16 adrs;

    adrs = SMU_ZERO_CALIB_OFFSET;

    *magic = eeprom__read__data_u32(slotCS, SPI_SEL_M0, adrs); adrs += 4;
    TRACE("# magic : 0x%X\n", magic);

    if (*magic != MODULE_MAGIC_CODE) 
	{
		smu_clear_calib_para(ch);

		TRACE("# <Read Calibration Parameter Error> or <Not Calibrated> : SMU%d\r\n", ch+1);
		return;
    }
    else //2015.12.22
	{
		TRACE("# <Read Calibration Parameter Success> : SMU%d\r\n", ch+1);
	}

    smu_ipmsr_offset[ch][SMU_1nA_RANGE] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;
    smu_inmsr_offset[ch][SMU_1nA_RANGE] = eeprom__read__data_float(slotCS, SPI_SEL_M0, adrs); adrs += 4;

    TRACE("# smu_ipmsr_offset : %e, %e\n", smu_ipmsr_offset[ch][SMU_1nA_RANGE],  smu_inmsr_offset[ch][SMU_1nA_RANGE]);
}


void read_gndu_calib_para(void)
{
	long magic;
    int i;

    u16 adrs;

    adrs = GNDU_CALIB_OFFSET;

    magic = eeprom__read__data_u32(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;

    if(magic != MODULE_MAGIC_CODE) 
	{
        TRACE("# Magic code is: 0x%x\n", magic);
        goto compare_err;
	}

    gndu_vsrc_gain_calib = eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;
    gndu_vsrc_offset_calib = eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;

    for (i=0; i<NO_OF_VRANGE; i++) 
	{
        gndu_vmsr_gain_calib[i] = eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;
        gndu_vmsr_offset_calib[i] = eeprom__read__data_float(SLOT_CS0, SPI_SEL_M0, adrs); adrs += 4;
    }

	TRACE("# <Read Calibration Parameter Success> : GNDU\r\n");
    return;

    compare_err:
    TRACE("# <Read Calibration Parameter Error> or <Not Calibrated> : GNDU\r\n");
    return;
}

// not used
void print_calib_para(int ch)
{
    int k;

    for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vsrc_gain_calib[ch][k]);
    for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vsrc_offset_calib[ch][k]);
    for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vmsr_gain_calib[ch][k]);
    for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vmsr_offset_calib[ch][k]);
    //    uart1_flush();
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipsrc_gain_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipsrc_offset_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_insrc_gain_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_insrc_offset_calib[ch][k]);
    //    uart1_flush();
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipmsr_gain_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipmsr_offset_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_inmsr_gain_calib[ch][k]);
    for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_inmsr_offset_calib[ch][k]);
    //    uart1_flush();
    
   
  //  uart1_flush();
}


/*
// print calibration parameter 
void print_calib_para_all(void)
{
    int ch, k;

    for (ch=0; ch<NO_OF_SMU; ch++) 
	{
        for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vsrc_gain_calib[ch][k]);
        for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vsrc_offset_calib[ch][k]);
        for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vmsr_gain_calib[ch][k]);
        for (k=0; k<NO_OF_VRANGE; k++) printf("%E\r\n", smu_vmsr_offset_calib[ch][k]);
    //    uart1_flush();
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipsrc_gain_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipsrc_offset_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_insrc_gain_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_insrc_offset_calib[ch][k]);
    //    uart1_flush();
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipmsr_gain_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_ipmsr_offset_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_inmsr_gain_calib[ch][k]);
        for (k=NO_OF_IRANGE-1; k>=0; k--) printf("%E\r\n", smu_inmsr_offset_calib[ch][k]);
    //    uart1_flush();
    }
   
  //  uart1_flush();
}
*/

// not used
// StaClient 사용하기 위해 수정
void print_calib_para_all(void)
{
    int ch, k;

  for (ch=0; ch<4; ch++) 
	{
        for (k=0; k<4; k++) printf("%E\r\n", smu_vsrc_gain_calib[ch][k]);
        for (k=0; k<4; k++) printf("%E\r\n", smu_vsrc_offset_calib[ch][k]);
        for (k=0; k<4; k++) printf("%E\r\n", smu_vmsr_gain_calib[ch][k]);
        for (k=0; k<4; k++) printf("%E\r\n", smu_vmsr_offset_calib[ch][k]);
    //    uart1_flush();
        for (k=11; k>=0; k--) printf("%E\r\n", smu_ipsrc_gain_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_ipsrc_offset_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_insrc_gain_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_insrc_offset_calib[ch][k]);
    //    uart1_flush();
        for (k=11; k>=0; k--) printf("%E\r\n", smu_ipmsr_gain_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_ipmsr_offset_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_inmsr_gain_calib[ch][k]);
        for (k=11; k>=0; k--) printf("%E\r\n", smu_inmsr_offset_calib[ch][k]);
    //    uart1_flush();
    }
   
	for (ch=0; ch<2; ch++) 
	{
        for (k=0; k<2; k++) printf("%E\r\n", 0);
        for (k=0; k<2; k++) printf("%E\r\n", 0);
    }
    for (ch=0; ch<2; ch++) 
	{
        for (k=0; k<2; k++) printf("%E\r\n", 0);
        for (k=0; k<2; k++) printf("%E\r\n", 0);
    }
  //  uart1_flush();
}



/*
void write_calib_para_all(void)
{
    int ch;
      
    for (ch=0; ch<NO_OF_SMU; ch++) write_smu_calib_para(ch);
}
*/

// not used
// StaClient 사용하기 위해 수정
void write_calib_para_all(void)
{
    int ch;
      
    for (ch=0; ch<NO_OF_SMU; ch++) write_smu_calib_para(ch);
}


/*
void read_calib_para_all(void)
{
    int ch;
      
    for (ch=0; ch<NO_OF_SMU; ch++) read_smu_calib_para(ch);
}
*/

// not used
// StaClient 사용하기 위해 수정
void read_calib_para_all(void)
{
    int ch;
      
    for (ch=0; ch<NO_OF_SMU; ch++) read_smu_calib_para(ch);
}





/*
// module infomation 
void extract_version_int(long ver, int *major, int *midle, int *minor)
{
    // 03.01.12
    // major.midle.minor
    *major = ver / 10000;
    *midle = (ver - *major*10000) / 100;
    *minor = ver - *major*10000 - *midle*100;
}



void extract_date_int(long date, int *year, int *month, int *day)
{
    // 2002.07.23
    // year.month.day
    *year = date / 10000;
    *month = (date - *year*10000) / 100;
    *day = date - *year*10000 - *month*100;
}




// 장착된 보드들의 정보를 읽어들인다
// CPU보드의 정보는 FLASH에서
// VSM, SMU 보드의 정보는 serial EEPROM에서 읽어들인다
void load_module_info(void)
{
    init_module_info();
    ebox_init_module_info();

    read_module_info_all();
    ebox_read_module_info_all();
}




void init_module_info(void)
{
    int i;

    for (i=0; i<MAX_MODULE; i++) module_info[i].installed = FALSE;
}




// FLASH로 부터 STA정보(전원 주파수, 모델명)를 읽어서
// 전원 주파수에 따라 measurement timer 설정을 달리하고
// 모델명에 따라 전압 및 전류의 최대, 최소 레인지를 설정해 준다
void load_sta_info(void)
{
    read_sta_info();
    set_meas_timer(ac_power_freq);
    configure_system_info();
}




// print sta infomation 
void print_sta_info(void)
{
    int major, midle, minor;
    
    extract_version_int(sta_version, &major, &midle, &minor);
    PrintF("#----- STA INFOMATIOM -----\r\n");
    PrintF("# MODEL NAME: %s\r\n", model_name);
    PrintF("# MODEL ID  : %d\r\n", id_code);
    PrintF("# MODEL VER : %d.%d.%d\r\n", major, midle, minor);
    PrintF("# POWER FREQ: %dHz\r\n", ac_power_freq);
    PrintF("# \r\n");
}
 


   
// print module infomation 
void print_module_info(int module)
{
    int major, midle, minor;
    int year, month, day;
    TModuleInfo *info;

    PrintF("#----- MODULE INFOMATIOM -----\r\n");
    info = &module_info[module];

    if (info->installed) {
        PrintF("# SLOT: %s\r\n", slot_name[module]);
        PrintF("# NAME: %s\r\n", info->name);
        PrintF("# ID  : %d\r\n", info->id);
        extract_version_int(info->version, &major, &midle, &minor);
        PrintF("# VER : %d.%d.%d\r\n", major, midle, minor);
        PrintF("# SN  : %s\r\n", info->serial);
        extract_date_int(info->birthday, &year, &month, &day);
        PrintF("# Manufacture Date: %d-%d-%d\r\n", year, month, day);
        extract_date_int(info->calibday, &year, &month, &day);
        PrintF("# Calibration Date: %d-%d-%d\r\n", year, month, day);
        PrintF("# \r\n");
    }
    else {
        PrintF("# %s SLOT is not installed.\r\n", slot_name[module]);
        PrintF("# \r\n");
    }     
}


void print_module_info_all(void)
{
    int i;
    int major, midle, minor;
    int year, month, day;
    TModuleInfo *info;

    PrintF("#====== MODULE INFOMATIOM ======\r\n");
    for (i=0; i<MAX_MODULE; i++) {
        info = &module_info[i];
        if (info->installed) {
            PrintF("# ------ %s SLOT ------\r\n", slot_name[i]);
            PrintF("# NAME: %s\r\n", info->name);
            PrintF("# ID  : %d\r\n", info->id);
            extract_version_int(info->version, &major, &midle, &minor);
            PrintF("# VER : %d.%d.%d\r\n", major, midle, minor);
            PrintF("# SN  : %s\r\n", info->serial);
            extract_date_int(info->birthday, &year, &month, &day);
            PrintF("# Manufacture Date: %d-%d-%d\r\n", year, month, day);
            extract_date_int(info->calibday, &year, &month, &day);
            PrintF("# Calibration Date: %d-%d-%d\r\n", year, month, day);
            PrintF("# \r\n");
        }
        else {
            PrintF("# %s SLOT is not installed.\r\n", slot_name[i]);
            PrintF("# \r\n");
        }
    }     
}



// read configuration section from flash buffer
void read_sta_info(void)
{
    fread_flash();
    fread_sta_section((void *)(FLASH_BUFFER_BASE+FLASH_STA_OFFSET));
}



/////////////////////////////////////////////////////////////////////////////////
// read module infomation from flash or seeprom. 
//  
//  - CPU 보드의 정보는 FLASH 로 부터 읽어오고
//  - VSM, SMU 보드의 정보는 각 보드에 있는 serial EEPROM 으로부터 읽어 온다
// - 저장돼 있는 magic code를 읽어들여 제대로된 값이 들어 있으면 installed가 TRUE
//    ID, version, birthday, calibday, name, serial정보 읽어들임
/////////////////////////////////////////////////////////////////////////////////  
void read_module_info(int module)
{
    long i, magic;
    short addr;
    TModuleInfo *info;
    
    info = &module_info[module];
   
    if (module == MODULE_CPU) {
        fread_flash();
        fread_cpu_section((void *)(FLASH_BUFFER_BASE+FLASH_CPU_OFFSET));
        return;
    }
    
    if (module == MODULE_VSM) {
        vsm_seeprom_on();
    }
    else if ((module >= MODULE_SMU1) && (module <= MODULE_SMU4)) {
        smu_seeprom_on(module-MODULE_SMU1);
    }
    else {
        return;
    }
    
    magic = spi_read_long(0x00);
    info->id = spi_read_long(0x04);
    info->version = spi_read_long(0x08);
    info->birthday = spi_read_long(0x0C);
    info->calibday = spi_read_long(0x10);
    addr = 0x14;
    for (i=0; i<MAX_MODULE_NAME; i++) info->name[i] = spi_read_byte(addr++);
    info->name[MAX_MODULE_NAME] = '\0';
    addr++;
    for (i=0; i<MAX_MODULE_SERIAL; i++) info->serial[i] = spi_read_byte(addr++);
    info->serial[MAX_MODULE_SERIAL] = '\0';
    addr++;
    if (magic == MODULE_MAGIC_CODE) info->installed = TRUE;
    else info->installed = FALSE;
    
    seeprom_off();
}




void read_module_info_all(void)
{
    int i;
    
    for (i=0; i<MAX_MODULE; i++) {
        read_module_info(i);
    }
}



// read configuration section from flash buffer. 
void write_sta_info(void)
{
    PrintF("# Programming... STA Configuration.\r\n");
    fread_flash();
    fwrite_sta_section((void *)(FLASH_BUFFER_BASE+FLASH_STA_OFFSET));
    fwrite_flash();
    fcompare_flash();
    PrintF("# Programming End.\r\n");
    PrintF("# \r\n");
}





void write_module_info(int module)
{
    long i;
    short addr;
    TModuleInfo *info;
    
    info = &module_info[module];
   
    if (module == MODULE_CPU) {
        PrintF("# Programming... CPU Configuration.\r\n");
        fread_flash();
        fwrite_cpu_section((void *)(FLASH_BUFFER_BASE+FLASH_CPU_OFFSET));
        fwrite_flash();
        fcompare_flash();
        PrintF("# Programming End.\r\n");
        PrintF("# \r\n");
        return;
    }
    
    if (module == MODULE_VSM) {
        vsm_seeprom_on();
        PrintF("# Programming... VSM Configuration.\r\n");
    }
    else if ((module >= MODULE_SMU1) && (module <= MODULE_SMU4)) {
        smu_seeprom_on(module-MODULE_SMU1);
        PrintF("# Programming... SMU%d Configuration.\r\n", module-MODULE_SMU1+1);
    }
    else {
        return;
    }
    
    spi_write_long(0x00, MODULE_MAGIC_CODE);
    spi_write_long(0x04, info->id);
    spi_write_long(0x08, info->version);
    spi_write_long(0x0C, info->birthday);
    spi_write_long(0x10, info->calibday);
    addr = 0x14;
    for (i=0; i<MAX_MODULE_NAME; i++) spi_write_byte(addr++, info->name[i]);
    spi_write_byte(addr++, '\0');
    for (i=0; i<MAX_MODULE_SERIAL; i++) spi_write_byte(addr++, info->serial[i]);
    spi_write_byte(addr++, '\0');
    
    seeprom_off();
    PrintF("# Programming End.\r\n");
    PrintF("# \r\n");
}
*/







