#include "App_SmuTest.h"


/* Channel Division
	     | board Ch | SMU Offset Ch |
	ch10 |	 101    |       0       |	(bin)
	ch11 |	 101    |       1       |	(bin)
	ch12 |	 110    |       0       |	(bin)
	  .
	  .
*/


BOOL tst_MsgOut(const char *format, ...)
{
	u32	length;

	va_list	ap;

	trxData_t *pTrxData = &trxData;

	u8 *pStartData = &(pTrxData->txData[pTrxData->txLength]);

	va_start(ap, format);

	length = vsprintf((char*)pStartData, format, ap);

	pTrxData->txLength += length;		//strlen((char*)pStartData);

	va_end(ap);

	return TRUE;
}

BOOL MsgOut_DI(char *data, uint32 length)
{
	trxData_t *pTrxData = &trxData;
	
	pTrxData->txData = (u8 *)data;	
	pTrxData->txLength += length;
	
	return TRUE;
	
	
}


/////////////////////////////////////////////////////////////////////
// CDCTpiDrv::
/////////////////////////////////////////////////////////////////////
BOOL SetADCI(int type, int mode, float value, int autozero, float b_range, int mode_h, float value_h)
{
    int nplc;

    nplc = (int)(value+0.5);
    if( mode == 3 )
    {
        average_cnt_reg.average_long[SMU_10pA_RANGE] =  SAMPLES_PER_1PLC * nplc;
        average_cnt_reg.average_long[SMU_100pA_RANGE]=  SAMPLES_PER_1PLC * nplc;
        average_cnt_reg.average_long[SMU_1nA_RANGE]  =  SAMPLES_PER_1PLC * nplc;

        if( type == 1 )
        {
            average_cnt_reg.average_long[SMU_10nA_RANGE]  =  SAMPLES_PER_1PLC * nplc;
        }
    }
    
    return TRUE;
}

BOOL CalSmuOffset_channel(int ch)
{
  start_calib_leak_one( ch-1 );
  return TRUE;
}

BOOL ZeroCalSetOffset(int ch, int rng, float val)
{
    TRACE("smu ch=%d, rng=%d, val=%e \n",ch, rng, val ); 
    if( rng == 1 )  //1nA
    { 
      TRACE("#in rng : ipmsr_offset=%e, val=%e, ipmsr_real_gain=%e \n",smu_ipmsr_offset[ch-1][SMU_1nA_RANGE], val, smu_ipmsr_real_gain[ch-1][SMU_1nA_RANGE] );
      smu_ipmsr_offset[ch-1][SMU_1nA_RANGE] = smu_ipmsr_offset[ch-1][SMU_1nA_RANGE] + val * smu_ipmsr_real_gain[ch-1][SMU_1nA_RANGE];
      smu_inmsr_offset[ch-1][SMU_1nA_RANGE] = smu_inmsr_offset[ch-1][SMU_1nA_RANGE] + val * smu_inmsr_real_gain[ch-1][SMU_1nA_RANGE];
      TRACE("#1nA : smu ch=%d, rng=%d, pval=%e, nval=%e \n",ch, rng, smu_ipmsr_offset[ch-1][SMU_1nA_RANGE], smu_inmsr_offset[ch-1][SMU_1nA_RANGE]);
    }
    else if( rng == 2 )  //10nA
    {
      smu_ipmsr_offset[ch-1][SMU_10nA_RANGE] = smu_ipmsr_offset[ch-1][SMU_10nA_RANGE] + val * smu_ipmsr_real_gain[ch-1][SMU_10nA_RANGE];
      smu_inmsr_offset[ch-1][SMU_10nA_RANGE] = smu_inmsr_offset[ch-1][SMU_10nA_RANGE] + val * smu_inmsr_real_gain[ch-1][SMU_10nA_RANGE];

      TRACE("#10nA : smu ch=%d, rng=%d, pval=%e, nval=%e \n",ch, rng, smu_ipmsr_offset[ch-1][SMU_10nA_RANGE], smu_inmsr_offset[ch-1][SMU_10nA_RANGE]); 
    }
    return TRUE;
}

BOOL ZeroCalGetOffset( int ch, int rng, float *offset, float *_offset)
{
    if( rng == 1 )  //1nA
    { 
        *offset = smu_ipmsr_offset[ch-1][SMU_1nA_RANGE];
        *_offset = smu_inmsr_offset[ch-1][SMU_1nA_RANGE];
    }
    else if( rng == 2 ) //10nA
    {
        *offset = smu_ipmsr_offset[ch-1][SMU_10nA_RANGE];
        *_offset = smu_inmsr_offset[ch-1][SMU_10nA_RANGE];
    }

    return TRUE;
}


//----------------------------------------------------------
// DC Calibration
//----------------------------------------------------------
// 1.Sourcing
//   Vdut: dut voltage
//   Vsrc: sourcing voltage before calibration 
//   Vdac: dac value
//   Ge: gain error, Oe: offset error
//   Gi: ideal dac to output gain
//
//   Vdut = Ge*Vsrc + Oe, Vsrc = Gi*Vdac
//   Vdut = Ge*Gi*Vdac + Oe
//   Vdac = (Vdut - Oe) / (Ge*Gi)
//   Vdac = (Vdut - Offset) / Gain, (Gain = Ge*Gi, Offset = Oe)
//
// 2.Measurement
//   Vdut: dut voltage
//   Vmsr: measurment voltage before calibration
//   Vadc: adc value
//   Ge: gain error, Oe: offset error
//   Gi: ideal output to adc gain
//
//   Vmsr = Ge*Vdut + Oe, Vmsr = Vadc/Gi
//   Vadc = Gi*(Ge*Vdut + Oe)   = Gi*Ge*Vdut + Gi*Oe
//   Vdut = (Vadc/Gi - Oe) / Ge = (Vadc - Gi*Oe) / (Gi*Ge)
//   Vdut = (Vadc - Offset) / Gain, (Gain = Gi*Ge, Offset = Gi*Oe)
//----------------------------------------------------------
BOOL CalDacAdjust(int step)
{
    if (step == 0) // GNDU ouput 0V
    {
        gndu_source_start();
        
        return TRUE;
    }
    else if (step == 1) // DAC gain adjust
    {
        // +9.999695 출력
        // SMU  TP3(VDAC):    adjust VR2
        // SMU  TP4(IDAC):    adjust VR4
        // GNDU TP3(GND_DAC): adjust VR2
        smu_dac_gain_adjust();
        gndu_dac_gain_adjust();

        return TRUE;
    }
    else if (step == 2) // DAC offset adjust
    {
        // -10V 출력
        // SMU  TP3(VDAC):    adjust VR3
        // SMU  TP4(IDAC):    adjust VR5
        // GNDU TP3(GND_DAC): adjust VR3
        smu_dac_offset_adjust();
        gndu_dac_offset_adjust();

        return TRUE;
    }
    
    return FALSE;
}


BOOL CalSetSmuFV(int ch, int vrange, float gain, float offset)
{
    ch = ch - 1;
    smu_vsrc_gain_calib[ch][vrange]   = gain;
    smu_vsrc_offset_calib[ch][vrange] = offset;

    smu_vsrc_real_gain[ch][vrange] = smu_vsrc_ideal_gain[ch][vrange] * smu_vsrc_gain_calib[ch][vrange];
    smu_vsrc_offset[ch][vrange]    = smu_vsrc_offset_calib[ch][vrange];
			
    return TRUE;
}

BOOL CalGetSmuFV(int ch, int vrange, float *gain, float *offset)
{
    ch = ch - 1;
    *gain   = smu_vsrc_gain_calib[ch][vrange];
    *offset = smu_vsrc_offset_calib[ch][vrange];

    return TRUE;
}

BOOL CalSetSmuMV(int ch, int vrange, float gain, float offset)
{
    ch = ch - 1;
    smu_vmsr_gain_calib[ch][vrange]   = gain;
    smu_vmsr_offset_calib[ch][vrange] = offset;

    smu_vmsr_real_gain[ch][vrange] = smu_vmsr_ideal_gain[ch] [vrange] * smu_vmsr_gain_calib[ch][vrange];
	  smu_vmsr_offset[ch][vrange]    = smu_vmsr_ideal_gain[ch] [vrange] * smu_vmsr_offset_calib[ch][vrange];

    return TRUE;
}

BOOL CalGetSmuMV(int ch, int vrange, float *gain, float *offset)
{
    ch = ch - 1;
    *gain   = smu_vmsr_gain_calib[ch][vrange];
    *offset = smu_vmsr_offset_calib[ch][vrange];

    return TRUE;
}

BOOL CalSetSmuFI(int ch, int irange, float gain, float offset, float _gain, float _offset)
{
    ch = ch - 1;
    smu_ipsrc_gain_calib[ch][irange]   =  gain;
    smu_ipsrc_offset_calib[ch][irange] =  offset;
    smu_insrc_gain_calib[ch][irange]   = _gain;
    smu_insrc_offset_calib[ch][irange] = _offset;
    
    smu_ipsrc_real_gain[ch][irange] = smu_isrc_ideal_gain[ch][irange] * smu_ipsrc_gain_calib[ch][irange];
    smu_ipsrc_offset[ch][irange]    = smu_ipsrc_offset_calib[ch][irange];
    smu_insrc_real_gain[ch][irange] = smu_isrc_ideal_gain[ch][irange] * smu_insrc_gain_calib[ch][irange];
    smu_insrc_offset[ch][irange]    = smu_insrc_offset_calib[ch][irange];
                    
    return TRUE;
}

BOOL CalGetSmuFI(int ch, int irange, float *gain, float *offset, float *_gain, float *_offset)
{
    ch = ch - 1;
    *gain    = smu_ipsrc_gain_calib[ch][irange];
    *offset  = smu_ipsrc_offset_calib[ch][irange];
    *_gain   = smu_insrc_gain_calib[ch][irange];
    *_offset = smu_insrc_offset_calib[ch][irange];

    return TRUE;
}

BOOL CalSetSmuMI(int ch, int irange, float gain, float offset, float _gain, float _offset)
{
    ch = ch - 1;
    smu_ipmsr_gain_calib[ch][irange]   =  gain;
    smu_ipmsr_offset_calib[ch][irange] =  offset;
    smu_inmsr_gain_calib[ch][irange]   = _gain;
    smu_inmsr_offset_calib[ch][irange] = _offset;
    
    smu_ipmsr_real_gain[ch][irange] = smu_imsr_ideal_gain[ch][irange] * smu_ipmsr_gain_calib[ch][irange];
    smu_ipmsr_offset[ch][irange]    = smu_imsr_ideal_gain[ch][irange] * smu_ipmsr_offset_calib[ch][irange];
    smu_inmsr_real_gain[ch][irange] = smu_imsr_ideal_gain[ch][irange] * smu_inmsr_gain_calib[ch][irange];
    smu_inmsr_offset[ch][irange]    = smu_imsr_ideal_gain[ch][irange] * smu_inmsr_offset_calib[ch][irange];
                    
    return TRUE;
}

BOOL CalGetSmuMI(int ch, int irange, float *gain, float *offset, float *_gain, float *_offset)
{
    ch = ch - 1;
    *gain    = smu_ipmsr_gain_calib[ch][irange];
    *offset  = smu_ipmsr_offset_calib[ch][irange];
    *_gain   = smu_inmsr_gain_calib[ch][irange];
    *_offset = smu_inmsr_offset_calib[ch][irange];

    return TRUE;
}




BOOL CalSetGnduFV(float gain, float offset)
{
  gndu_vsrc_gain_calib   = gain;
  gndu_vsrc_offset_calib = offset;
    
  gndu_vsrc_real_gain = gndu_vsrc_ideal_gain * gndu_vsrc_gain_calib;
	gndu_vsrc_offset    = gndu_vsrc_offset_calib;
	
  printf("# VSRC_OFFSET_CALIB = %f, VSRC_GAIN_CALIB = %f\n",gndu_vsrc_offset_calib, gndu_vsrc_gain_calib); 
	
  gndu_source_start();

  return TRUE;
}

BOOL CalGetGnduFV(float *gain, float *offset)
{
    *gain   = gndu_vsrc_gain_calib;
    *offset = gndu_vsrc_offset_calib;
    
    return TRUE;
}

BOOL CalSmuFVEN(BOOL en)
{
    if (en) without_smu_vsrc = FALSE;
    else without_smu_vsrc = TRUE;

    return TRUE;
}

BOOL CalSmuMVEN(BOOL en)
{
    if (en) without_smu_vmsr = FALSE;
    else without_smu_vmsr = TRUE;

    return TRUE;
}

BOOL CalSmuFIEN(BOOL en)
{
    if (en) without_smu_isrc = FALSE;
    else without_smu_isrc = TRUE;

    return TRUE;
}

BOOL CalSmuMIEN(BOOL en)
{
    if (en) without_smu_imsr = FALSE;
    else without_smu_imsr = TRUE;

    return TRUE;
}

BOOL CalGnduFVEN(BOOL en)
{ 
    if (en) without_gndu_vsrc = FALSE;
    else without_gndu_vsrc = TRUE;

    gndu_source_start();

    return TRUE;
}

BOOL CalLoadSmu(int ch)
{
    read_smu_calib_para(ch-1);
    calculate_calib();

    return TRUE;
}

BOOL CalSaveSmu(int ch)
{
    return write_smu_calib_para(ch-1);
}

/////
BOOL ZeroCalLoadSmu(int ch, long *magic)
{
    read_smu_zero_calib_para(ch-1, magic);
    return TRUE;
}

BOOL ZeroCalSaveSmu(int ch)
{
    return write_smu_zero_calib_para(ch-1);
}
/////

BOOL CalLoadGndu(void)
{
    read_gndu_calib_para();
    calculate_calib();
    gndu_source_start();

    return TRUE;
}

BOOL CalSaveGndu(void)
{
    write_gndu_calib_para();

    return TRUE;
}


u8 ProcessTest(void* pCmd, int argc, void* pData)
{
	tst_MsgOut( "E00\r" );
	
	return TRUE;
}

u8 ProcessSys(void* pCmd, int argc, void* pData)
{
	tst_MsgOut( "E00\r" );
	
	return TRUE;
}

u8 ProcessSet(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;

	// SET
	int   type, mode, autozero, mode_h;
	float value, b_range, value_h;

	if(CMD_Compare((u8 *)ppCmdv[1], "ADC") && CMD_Compare((u8 *)ppCmdv[2], "I")) 
	{
		if(argc > 0) type = strtoul(ppArgv[0], NULL, 0);
		if(argc > 1) mode = strtoul(ppArgv[1], NULL, 0);
		if(argc > 2) value = strtof(ppArgv[2], NULL);
		if(argc > 3) autozero = strtoul(ppArgv[3], NULL, 0);
		if(argc > 4) b_range = strtof(ppArgv[4], NULL);
		if(argc > 5) mode_h = strtoul(ppArgv[5], NULL, 0);
		if(argc > 6) value_h = strtof(ppArgv[6], NULL);

		if(SetADCI(type, mode, value, autozero, b_range, mode_h, value_h ))
		{
			tst_MsgOut( "E00\r" );
			return TRUE;
		}
		else
		{
			tst_MsgOut( "E01\r");
			// errFlag++;
			return FALSE;
		}
	}

	tst_MsgOut( "E02\r" );
	// errFlag++;
	
	return FALSE;
}
u8 ProcessCal(void* pCmd, int argc, void* pData)
{
    float gain, offset, _gain, _offset;
    int channel, calMode, signal, range;
    long magic;

	char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;

    if(CMD_Compare((u8 *)ppCmdv[1], "OFFSET"))
    {
        if(CMD_Compare((u8 *)ppCmdv[2], "SMU"))
        {
            if(CalSmuOffset_channel(strtoul(ppArgv[0], NULL, 0)))
            {
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
            else
            {
                tst_MsgOut( "E01\r");
                // errFlag++;
				return FALSE;
            }
            // return;
        }

        if(CMD_Compare((u8 *)ppCmdv[2], "SET"))
        {
            if(ZeroCalSetOffset(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0), strtoul(ppArgv[2], NULL, 0)))
			{
				tst_MsgOut( "E00\r" );
				return TRUE;
			}
            else
            {
                tst_MsgOut( "E01\r");
                // errFlag++;
				return FALSE;
            }
            // return;
        }
        // CAL:OFFSET:SET? ch rng
        if(CMD_Compare((u8 *)ppCmdv[2], "SET?"))
        {
            if(ZeroCalGetOffset(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0), &offset, &_offset) )
            {
			    tst_MsgOut( "E00 %e,%e", offset, _offset ); 
				return TRUE;
            }
            else
            {
                tst_MsgOut( "E01\r");
                // errFlag++;
				return FALSE;
            }
            // return;
        }





        //--------------------------------------------------------
        // CAL:OFFSET:LOAD ch
        if(CMD_Compare((u8 *)ppCmdv[2], "LOAD"))
        {
	        if(ZeroCalLoadSmu(strtoul(ppArgv[0], NULL, 0), &magic))
			{
				tst_MsgOut( "E00 0x%X", magic);
				return TRUE;
			}
		        
	        else
		    {
			    tst_MsgOut( "E01\r");
			    // errFlag++;
				return FALSE;
		    }
	        // return;
        }
        // CAL:OFFSET:SAVE ch
        if(CMD_Compare((u8 *)ppCmdv[2], "SAVE"))
        {
	        if(ZeroCalSaveSmu(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
		        
	        else
		    {
			    tst_MsgOut( "E01\r");
			    // errFlag++;
				return FALSE;
		    }
	        // return;
        }
        //--------------------------------------------------------
    }

//////////////////////////////////////////////////////////////////////////////
	// CAL:DAC step
	if(CMD_Compare((u8 *)ppCmdv[1], "DAC"))
	{
		if(CalDacAdjust(strtoul(ppArgv[0], NULL, 0)))
		{
			tst_MsgOut("E00\r");
			return TRUE;
		}
		else
		{
			tst_MsgOut("E01\r");
			// errFlag++;
			return FALSE;
		}
		// return;
	}

// //////////////////////////////////////////////////////////////////////////////

  	if(CMD_Compare((u8 *)ppCmdv[1], "SMU"))
	{
      	// CAL:SMU:FV ch, range, gain, offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "FV"))
	    {
		    if(CalSetSmuFV(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
                strtof(ppArgv[2], NULL), strtof(ppArgv[3], NULL)))
			{
				tst_MsgOut( "E00\r" );
				return TRUE;
			}
		    else
			{
			    tst_MsgOut( "E01\r");
			    // errFlag++;
				return FALSE;
			}
		    // return;
	    }
      	// CAL:SMU:FV? ch, range -> E00 gain, offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "FV?"))
	    {
		    if(CalGetSmuFV(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
	          &gain, &offset))
		  	{
				tst_MsgOut("E00 %e,%e\r", gain, offset);
				return TRUE;
		  	}
			    
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }

      	// CAL:SMU:MV ch, range, gain, offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "MV"))
	    {
		    if(CalSetSmuMV(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
                strtof(ppArgv[2], NULL), strtof(ppArgv[3], NULL)))
			{
				tst_MsgOut( "E00\r" ); 
				return TRUE;
			}
			    
		    else
			  {
				  tst_MsgOut( "E01\r");
				//   errFlag++;
				return FALSE;
			  }
		    // return;
	    }
      	// CAL:SMU:MV? ch, range -> E00 gain, offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "MV?"))
	    {
			if(CalGetSmuMV(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
          		&gain, &offset))
		  	{
				tst_MsgOut( "E00 %e,%e\r", gain, offset );
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }

      	// CAL:SMU:FI ch, range, +gain, +offset, -gain, -offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "FI"))
	    {
		    if(CalSetSmuFI(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
          		strtof(ppArgv[2], NULL), strtof(ppArgv[3], NULL), strtof(ppArgv[4], NULL), strtof(ppArgv[5], NULL)))
			{
				tst_MsgOut( "E00\r" );
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
      	// CAL:SMU:FI? ch, range -> E00 +gain, +offset, -gain, -offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "FI?"))
	    {
		    if(CalGetSmuFI(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
          		&gain, &offset, &_gain, &_offset))
			{
				tst_MsgOut( "E00 %e,%e,%e,%e\r", gain, offset, _gain, _offset ); 
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }

      	// Cal Toll에서 측정한 값
      	// CAL:SMU:MI ch, range, +gain, +offset, -gain, -offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "MI"))
	    {
		    if(CalSetSmuMI(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
          		strtof(ppArgv[2], NULL), strtof(ppArgv[3], NULL), strtof(ppArgv[4], NULL), strtof(ppArgv[5], NULL)))
        	{
			    tst_MsgOut( "E00\r" );
				return TRUE;
        	}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }

      	// CAL:Load 후 실행 하면 보드에 저장된 값을 불러온다.
      	// CAL:SMU:MI? ch, range -> E00 +gain, +offset, -gain, -offset
      	if(CMD_Compare((u8 *)ppCmdv[2], "MI?"))
	    {
		    if(CalGetSmuMI(strtoul(ppArgv[0], NULL, 0), strtoul(ppArgv[1], NULL, 0),
          		&gain, &offset, &_gain, &_offset ))
			{
				tst_MsgOut( "E00 %e,%e,%e,%e\r", gain, offset, _gain, _offset );
				return TRUE; 
			}
			else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
			// return;
	    }

      	// CAL:SMU:FVEN 0/1
		  
      	if(CMD_Compare((u8 *)ppCmdv[2], "FVEN"))
	    {
		    if(CalSmuFVEN(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
			else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
      	// CAL:SMU:MVEN 0/1
      	if(CMD_Compare((u8 *)ppCmdv[2], "MVEN"))
	    {
		    if(CalSmuMVEN(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
      	// CAL:SMU:FIEN 0/1
      	if(CMD_Compare((u8 *)ppCmdv[2], "FIEN"))
	    {
		    if(CalSmuFIEN(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
      	// CAL:SMU:MIEN 0/1
		  
      	if(CMD_Compare((u8 *)ppCmdv[2], "MIEN"))
	    {
		    if(CalSmuMIEN(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
			    
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }

      	// CAL:SMU:LOAD ch
      	if(CMD_Compare((u8 *)ppCmdv[2], "LOAD"))
	    {
		    if(CalLoadSmu(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
     	// CAL:SMU:SAVE ch
		 
      	if(CMD_Compare((u8 *)ppCmdv[2], "SAVE"))
	    {
		    if(CalSaveSmu(strtoul(ppArgv[0], NULL, 0)))
			{
				tst_MsgOut( "E00\r"); 
				return TRUE;
			}
		    else
			{
				tst_MsgOut( "E01\r");
				// errFlag++;
				return FALSE;
			}
		    // return;
	    }
    }
    
// //////////////////////////////////////////////////////////////////////////////
//   	if( Cmd.IsEQCmd(1,"GNDU") )
// 	{
//       	// CAL:GNDU:FV gain, offset
//       	if( Cmd.IsEQCmd(2,"FV") )
// 	    {
// 		    if( m_DcTpi.CalSetGnduFV( atof(Cmd.m_Para[0]), atof(Cmd.m_Para[1]) ) )
// 			    MsgOut( "E00\r" ); 
// 		    else
// 			  {
// 				  MsgOut( "E01\r");
// 				  errFlag++;
// 			  }
// 		    return;
// 	    }
//       	// CAL:GNDU:FV? -> E00 gain, offset
//       	if( Cmd.IsEQCmd(2,"FV?") )
// 	    {
// 		    if( m_DcTpi.CalGetGnduFV( &gain, &offset ) )
// 			    MsgOut( "E00 %e,%e\r", gain, offset ); 
// 		    else
// 			  {
// 				  MsgOut( "E01\r");
// 				  errFlag++;
// 			  }
// 		    return;
// 	    }

//       	// CAL:GNDU:FVEN 0/1
//       	if( Cmd.IsEQCmd(2,"FVEN") )
// 	    {
// 		    if( m_DcTpi.CalGnduFVEN( atoi(Cmd.m_Para[0]) ) )
// 			    MsgOut( "E00\r"); 
// 		    else
// 			  {
// 				  MsgOut( "E01\r");
// 				  errFlag++;
// 			  }
// 		    return;
// 	    }

//       	// CAL:GNDU:LOAD
//       	if( Cmd.IsEQCmd(2,"LOAD") )
// 	    {
// 		    if( m_DcTpi.CalLoadGndu() )
// 			    MsgOut( "E00\r"); 
// 		    else
// 			  {
// 				  MsgOut( "E01\r");
// 				  errFlag++;
// 			  }
// 		    return;
// 	    }

//       // CAL:GNDU:SAVE
//       	if( Cmd.IsEQCmd(2,"SAVE") )
// 	    {
// 		    if( m_DcTpi.CalSaveGndu() )
// 			    MsgOut( "E00\r"); 
// 		    else
// 			  {
// 				  MsgOut( "E01\r");
// 				  errFlag++;
// 			  }
// 		    return;
// 	    }
//     }
	
// 	MsgOut( "E02\r" );
// 	errFlag++;
	
// 	return;

	return TRUE;
}



	// char **ppArgv = (char**)pData;
	// char **ppCmdv = (char**)pCmd;

	// // SET
	// int   type, mode, autozero, mode_h;
	// float value, b_range, value_h;

	// if(CMD_Compare((u8 *)ppCmdv[1], "ADC") && CMD_Compare((u8 *)ppCmdv[2], "I")) 
	// {
	// 	if(argc > 0) type = strtoul(ppArgv[0], NULL, 0);
	// 	if(argc > 1) mode = strtoul(ppArgv[1], NULL, 0);
	// 	if(argc > 2) value = strtof(ppArgv[2], NULL);
	// 	if(argc > 3) autozero = strtoul(ppArgv[3], NULL, 0);
	// 	if(argc > 4) b_range = strtof(ppArgv[4], NULL);
	// 	if(argc > 5) mode_h = strtoul(ppArgv[5], NULL, 0);
	// 	if(argc > 6) value_h = strtof(ppArgv[6], NULL);



u8 ProcessRDPLF(void* pCmd, int argc, void* pData)
{
	// char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;
	

    if(CMD_Compare((u8 *)ppCmdv[0], "RDPLF"))
	{
		smu_pwr_line_freq = 0;
        read_plf_info();
        tst_MsgOut("E00 (Read) POWER LINE FREQUENCY: %dHz\r",smu_pwr_line_freq);
		return TRUE;
    }
    else
    {
		tst_MsgOut( "E01\r");
		// errFlag++;
        return FALSE;
	}
}

u8 ProcessWRPLF(void* pCmd, int argc, void* pData)
{
	char **ppCmdv = (char**)pCmd;

    if(CMD_Compare((u8 *)ppCmdv[0], "WRPLF"))
	{
        
        if(write_plf_info())
        {
            read_plf_info();
            tst_MsgOut("E00 (Read) POWER LINE FREQUENCY: %dHz\r",smu_pwr_line_freq);
			return TRUE;
        }
        else
        {
            // tst_MsgOut("E01 (Error!!!) Writing flash at %x (size: %d)",STRATA_STA_ADDRESS, sizeof(smu_pwr_line_freq));
			tst_MsgOut("E01 (Error!!!) Writing flash\r");
			return FALSE;
        }
	    
	    
        //MsgOut("E00\r");
    }
    else
    {
		tst_MsgOut( "E01\r");
		// errFlag++;
        return FALSE;
	}
}

u8 ProcessLDPLF(void* pCmd, int argc, void* pData)
{
    int freq;

	char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;

	freq = strtoul(ppArgv[0], NULL, 0);

    if (argc > 1)
	{
		tst_MsgOut("E01\r");
		// errFlag++;
		return FALSE;
	}
    else
    {
        load_plf_info(freq);
        //configure_sta_info();
        tst_MsgOut("E00 (Write) POWER LINE FREQUENCY: %d\r", freq);
		return TRUE;
    }


}

u8 ProcessDBG(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;

	if(CMD_Compare((u8 *)ppCmdv[1], "VDAC"))
	{	
		int ch;
		float vdac_out_val;
		s32 vdac_in_val;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		vdac_out_val = strtof(ppArgv[1], NULL);

		// if(vdac_out_val < 0)
		// {
		// 	vdac_in_val = (INT32)((vdac_out_val * 0x00800001 / 3.75)); //0x00800000 : Analog Output(v) -> -3.75V [Negative Full-Scale]
		// }
		// else
		// {
		// 	vdac_in_val= (INT32)((vdac_out_val * 0x007FFFFF / 3.75));
		// }
		
		// write_smu_vdac(ch, vdac_in_val);

		write_smu_vdac(ch, calculate_dac_in_val(vdac_out_val));


		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "IDAC"))
	{
		int ch;
		float idac_out_val;
		s32 idac_in_val;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		idac_out_val = strtof(ppArgv[1], NULL);


		// if(idac_out_val < 0)
		// {
		// 	idac_in_val = (INT32)((idac_out_val * 0x00800001 / 3.75)); //0x00800000 : Analog Output(v) -> -3.75V [Negative Full-Scale]
		// }
		// else
		// {
		// 	idac_in_val= (INT32)((idac_out_val * 0x007FFFFF / 3.75));
		// }

		// write_smu_idac(ch, idac_in_val);

		write_smu_idac(ch, calculate_dac_in_val(idac_out_val));
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "VMRANGE"))
	{
		int ch;
		int range;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		range = strtoul(ppArgv[1], NULL, 0);

		smu_ctrl_reg[ch].vmsr_rng = range;

		write_smu_vrange(ch, smu_ctrl_reg[ch].vmsr_rng);
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "COMP"))
	{
		int ch;
		u8 comp_ctrl;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		comp_ctrl = (u8)(strtoul(ppArgv[1], NULL, 0) & 0x000000FF);

		write_smu_comp_ctrl(ch, comp_ctrl); //뒤에해야 튀는게 없어진다. 
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "IRANGE"))
	{
		int ch;
		u32 ictrl;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		ictrl = strtoul(ppArgv[1], NULL, 0);

		write_smu_ictrl(ch, ictrl);
		
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "IRANGE_AUTO"))
	{
		int ch;
		u32 irng_idx;

		TSmuCtrl smu_ictrl;


		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		irng_idx = strtoul(ppArgv[1], NULL, 0);

		// smu_ictrl = to_smu_imsr_ctrl(ch, irng_idx);
		// write_smu_ictrl_init(ch, smu_ictrl.ictrl);
		// write_smu_comp_ctrl(ch, smu_ictrl.comp_ctrl);//뒤에해야 튀는게 없어진다.


		smu_ctrl_reg[ch].src_rng = irng_idx;
		change_smu_isrc_range(ch, smu_ctrl_reg[ch].src_rng);

		tst_MsgOut( "E00\r"); 
		return TRUE;
	}

	else if(CMD_Compare((u8 *)ppCmdv[1], "ADC_SEL"))
	{
		int ch;
		int mux_sel;
	
		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		mux_sel = strtoul(ppArgv[1], NULL, 0);
		
		switch(mux_sel)
		{
			case 1:		// V sel
				smu_adc_mux_v_sel(ch);		
				break;

			case 2:		// I sel
				smu_adc_mux_i_sel(ch);		
				break;

			default:
				smu_adc_mux_no_sel(ch);
			break;

		}

		tst_MsgOut("E00\r");
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "ADC"))
	{
		int ch;
	
		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		

		char msr_val[100];
		unsigned long *pTmpVal;
		
		// smu_adc_conv_start(ch);
		// smu_adc_voltage(ch);
		smu_adc_acquire_voltage(ch, 3);

		// sprintf(msr_val, "HLSMU,%d,%f\r", ch+1, adcval_to_float(adc_mean.smu_vadc[ch]));

		tst_MsgOut("E00 %s\r", msr_val);
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "ORELAY"))
	{
		int ch;
		int rly_ctrl;

		if(argc < 2)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		rly_ctrl = strtoul(ppArgv[1], NULL, 0);

		smu_force_rly_ctrl(ch, rly_ctrl);
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "FVEN"))
	{
		BOOL en;

		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		en = strtoul(ppArgv[0], NULL, 0);

		if(CalSmuFVEN(en))
		{
			tst_MsgOut( "E00\r"); 
			return TRUE;
		}
		else
		{
			tst_MsgOut( "E01\r");
			// errFlag++;
			return FALSE;
		}
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "MVEN"))
	{
		BOOL en;

		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		en = strtoul(ppArgv[0], NULL, 0);

		if(CalSmuMVEN(en))
		{
			tst_MsgOut( "E00\r"); 
			return TRUE;
		}
		else
		{
			tst_MsgOut( "E01\r");
			// errFlag++;
			return FALSE;
		}
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "FIEN"))
	{
		BOOL en;

		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		en = strtoul(ppArgv[0], NULL, 0);

		if(CalSmuFIEN(en))
		{
			tst_MsgOut( "E00\r"); 
			return TRUE;
		}
		else
		{
			tst_MsgOut( "E01\r");
			// errFlag++;
			return FALSE;
		}
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "MIEN"))
	{
		BOOL en;

		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		en = strtoul(ppArgv[0], NULL, 0);

		if(CalSmuMIEN(en))
		{
			tst_MsgOut( "E00\r"); 
			return TRUE;
		}
		else
		{
			tst_MsgOut( "E01\r");
			// errFlag++;
			return FALSE;
		}
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "SMVS"))
	{
		ProcessSMFV(pCmd, argc, pData);
		
		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "SMIS"))
	{
		ProcessSMFI(pCmd, argc, pData);

		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "SMVM"))
	{
		ProcessSMMV(pCmd, argc, pData);

		tst_MsgOut( "E00\r"); 
		return TRUE;		
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "SMIM"))
	{
		ProcessSMMI(pCmd, argc, pData);

		tst_MsgOut( "E00\r"); 
		return TRUE;		
	}
	else if(CMD_Compare((u8 *)ppCmdv[1], "EEPROM_RESET"))
	{
		int ch;
		u16 adrs;
		u32 slotCS;

		if(argc < 1)
		{
			tst_MsgOut( "E01\r"); 
			return TRUE;
		}

		ch = strtoul(ppArgv[0], NULL, 0) - 1;
		slotCS = _SPI_SEL_SLOT(ch + 1);

		     

		for(adrs = 0; adrs < 110; adrs++)	// Magic Code(1) + Vrange(3) * 4 + Irange(12) * 8 = 109
		{
			eeprom_write_data_u32(slotCS, SPI_SEL_M0, adrs, 0x00000000); adrs += 4;
		}

		tst_MsgOut( "E00\r"); 
		return TRUE;
	}
	else
	{
		tst_MsgOut( "E01\r"); 
		return FALSE;
	}
}


u8 ProcessSMUTEST(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;
	char **ppCmdv = (char**)pCmd;

	int i;
	int ch;
	float volt;

	ch = strtoul(ppArgv[0], NULL, 0) - 1;
	volt = strtof(ppArgv[1], NULL);

	if(ch < 0) return FALSE;


	// // 2V rng = 0, 10V rng = 1, 40V rng = 2
	// write_smu_vctrl(ch, to_smu_vctrl(0));


	// // SMU_100mA_RANGE
	// smu_ctrl_reg[ch].comp_ctrl = SMU_IX10_COMP;
	// smu_ctrl_reg[ch].ictrl = SMU_100mA_CTRL; 
	// // bit[0] = 1x10_comp, bit[1] = 5M_comp, bit[2] = LOOP_CUT
	// write_smu_comp_ctrl(ch,smu_ctrl_reg[ch].comp_ctrl);
	// write_smu_ictrl(ch, smu_ctrl_reg[ch].ictrl);




	// for(i = 0; i < 2; i++)
	// {
	// 	write_smu_vdac(ch + i, 0x007FFFFF);
	// 	write_smu_vdac(ch + i, 0x00800000);

	// 	write_smu_vdac(ch + i, 0xFFF08912);
	// 	write_smu_vdac(ch + i, 0xFF7FFFFF);



	// 	write_smu_idac(ch + i, 0x007FFFFF);

	// 	smu_adc_conv_start(ch + i);
	// 	smu_adc_voltage(ch + i);

	// 	TRACE("HRADC Read V 0x%X\r\n", smu_vadc_values[ch]);
	// 	TRACE("HRADC Voltage %f\r\n", adcval_to_float(smu_vadc_values[ch]));
	// }


	write_smu_vdac(ch, 0x007FFFFF);
	write_smu_vdac(ch, 0x003FFFFF);
	write_smu_vdac(ch, 0x00800000);
	write_smu_vdac(ch, 0x00C00000);


	smu_adc_conv_start(ch);
	smu_adc_voltage(ch);

	TRACE("HRADC Read V 0x%X\r\n", smu_vadc_values[ch]);
	TRACE("HRADC Voltage %f\r\n", adcval_to_float(smu_vadc_values[ch]));

	















	// //####################################################################################################################
	// // DAC TEST
	// // VDAC Reset
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_CON_CH1_WI | (chInfo.offset << 4), (u32)0, 0xFFFFFFFF);
	// Delay_ms(100);
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_CON_CH1_WI | (chInfo.offset << 4), (u32)1, 0xFFFFFFFF);
	// Delay_ms(100);

	// // VDAC Init
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_OPCODE_CH1_WI | (chInfo.offset << 4), HLSMU_OPCODE_DAC_INIT, 0xFFFFFFFF);
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_VAL_CH1_WI | (chInfo.offset << 4), 0x00000001, 0xFFFFFFFF);
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_CON_CH1_TI | (chInfo.offset << 4), 1); // EP for VDAC_TI // write pulse

	// // // DAC Init Read
	// // SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_OPCODE_CH1_WI | (chInfo.offset << 4), HLSMU_OPCODE_DAC_READ, 0xFFFFFFFF);
	// // ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_CON_CH1_TI | (chInfo.offset << 4), 1); // EP for VDAC_TI // write pulse
	// // TRACE("INIT Read V_DAC_CH1 = %X\r\n", GetWireOutValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_VAL_CH1_WO , 0xFFFFFFFF));



	// // // VDAC set
	// // SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_OPCODE_CH1_WI | (chInfo.offset << 4), HLSMU_OPCODE_DAC_SET, 0xFFFFFFFF);
	// // SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_VAL_CH1_WI | (chInfo.offset << 4), 0x007FFFFF, 0xFFFFFFFF);
	// // ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_V_DAC_CON_CH1_TI | (chInfo.offset << 4), 1); // EP for VDAC_TI // write pulse

	// // VDAC Set
	// for(i = 0; i < 50; i++)
	// {
	// 	if(i & 0x1) write_smu_vdac(ch, 0x00000000);
	// 	else write_smu_vdac(ch, 0x007FFFFF);			// SET V_DAC +2.5V AMP OUT +3.75V
	// 	Delay_us(100);
	// }
	

	// // IDAC Reset
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_CON_CH1_WI | (chInfo.offset << 4), (u32)0, 0xFFFFFFFF);
	// Delay_ms(100);
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_CON_CH1_WI | (chInfo.offset << 4), (u32)1, 0xFFFFFFFF);
	// Delay_ms(100);

	// // IDAC Init
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_OPCODE_CH1_WI | (chInfo.offset << 4), HLSMU_OPCODE_DAC_INIT, 0xFFFFFFFF);
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_VAL_CH1_WI | (chInfo.offset << 4), 0x00000001, 0xFFFFFFFF);
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_CON_CH1_TI | (chInfo.offset << 4), 1); // EP for VDAC_TI // write pulse

	// // // DAC Init Read
	// // SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_OPCODE_CH1_WI | (chInfo.offset << 4), HLSMU_OPCODE_DAC_READ, 0xFFFFFFFF);
	// // ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_CON_CH1_TI | (chInfo.offset << 4), 1); // EP for VDAC_TI // write pulse
	// // TRACE("INIT Read I_DAC_CH1 = %X\r\n", GetWireOutValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_I_DAC_VAL_CH1_WO , 0xFFFFFFFF));

	// // IDAC Set

	// for(i = 0; i < 50; i++)
	// {
	// 	if(i & 0x1) write_smu_idac(ch, 0x00000000);
	// 	else write_smu_idac(ch, 0x007FFFFF);			// SET I_DAC +2.5V AMP OUT +3.75V
	// 	Delay_us(100);
	// }


	// //####################################################################################################################
	// // ADC Test


	// // ADC sel reset
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_ADCIN_SEL_CH1_TI | (chInfo.offset << 4), 0); // clear pulse


	// // A_SEL
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_ADCIN_SEL_CH1_WI | (chInfo.offset << 4), ~(0x00000001), 0xFFFFFFFF);
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_ADCIN_SEL_CH1_TI | (chInfo.offset << 4), 1); // write pulse

	// // SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_ADCIN_SEL_CH1_WI | (chInfo.offset << 4), ~(0x00000000), 0xFFFFFFFF);		// All Off
	// // ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_ADCIN_SEL_CH1_TI | (chInfo.offset << 4), 1); // write pulse



	// // HRADC enable
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_HRADC_CH1_CON_WI | (chInfo.offset << 4), 0x00000001, 0xFFFFFFFF);
	// // HRADC measure dummy
	// smu_adc_conv_start(ch);
	// smu_adc_voltage(ch);
	// // adcval_to_float(smu_vadc_values[ch]);

	// // VM_RANGE
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_VMRANGE_CH1_WI | (chInfo.offset << 4), ~(0x00000000), 0xFFFFFFFF);		// 0 == On(Low active)
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_VMRANGE_CH1_TI | (chInfo.offset << 4), 1); // write pulse

	// // VS_RANGE
	// SetWireInValue(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_VSRANGE_CH1_WI | (chInfo.offset << 4), ~(0x00000000), 0xFFFFFFFF);		// 0 == On(Low active)
	// ActivateTriggerIn(chInfo.slotCS, SPI_SEL_M0, EP_ADRS__HLSMU_VSRANGE_CH1_TI | (chInfo.offset << 4), 1); // write pulse

	
	// write_smu_vdac(ch, 0x007FFFFF);
	// Delay_ms(100);
	// // HRADC get data
	// smu_adc_conv_start(ch);
	// smu_adc_voltage(ch);

	// TRACE("HRADC Read V 0x%X\r\n", smu_vadc_values[ch]);
	// TRACE("HRADC Voltage %f\r\n", adcval_to_float(smu_vadc_values[ch]));
	// Delay_ms(100);	

	tst_MsgOut( "E00\r"); 

	return TRUE;
}


void ProcessQMFV(char *recvMsg)
{
	float cmdConvPara[10];
	
	int smu_ch;
	float v_source;
	int v_source_range;
	float i_limit;
	int i_measure_range;
	
	cmdConvPara[0] = SYS_HexToFloat((u8 *)&recvMsg[4]);		// SMU ch
	cmdConvPara[1] = SYS_HexToFloat((u8 *)&recvMsg[4*2]);		// Voltage
	cmdConvPara[2] = SYS_HexToFloat((u8 *)&recvMsg[4*3]);		// Voltage Range
    cmdConvPara[3] = SYS_HexToFloat((u8 *)&recvMsg[4*4]);		// Compliance
	cmdConvPara[4] = SYS_HexToFloat((u8 *)&recvMsg[4*5]);		// Current Range


	smu_ch = ((int)cmdConvPara[0]) - 1;
	v_source = cmdConvPara[1];
	v_source_range = (int)cmdConvPara[2];
	i_limit = cmdConvPara[3];
	i_measure_range = (int)cmdConvPara[4];

	smu_force_voltage(smu_ch, v_source, v_source_range, i_limit, i_measure_range);	
	
	//MsgOut( "E00\r" );
	memcpy(&msr_val_union.cVal[0], "E00\r", 4);
	MsgOut_DI(msr_val_union.cVal, sizeof(char) * 4);

	CMD_WaitTimeDelay();

	CMD_TransmitAck(&trxData);
	//CMD_BinTransmitAck(&trxBinData);

	if(systemReset)
	{
		HAL_Delay(1000);
		NVIC_SystemReset();
	}

	GPIO_LedCtrl(0, LED_OFF); 		//	m_CPU.BusyLed(false);
	
	
}

void ProcessQMMI(char *recvMsg)
{
	float cmdConvPara[10];
	
	int ch;
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	
	cmdConvPara[0] = SYS_HexToFloat((u8 *)&recvMsg[4]);		// SMU ch
	cmdConvPara[1] = SYS_HexToFloat((u8 *)&recvMsg[4*2]); 	// Average Count
	cmdConvPara[2] = SYS_HexToFloat((u8 *)&recvMsg[4*3]); 	// Current Range
	cmdConvPara[3] = SYS_HexToFloat((u8 *)&recvMsg[4*4]); 	// Range Control


	ch = ((int)cmdConvPara[0]) - 1;
	average_cnt = cmdConvPara[1];

	if(((int)cmdConvPara[2] == -1) && ((int)cmdConvPara[3] == -1))
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_irange(ch);
	}
	else
	{
		rng_ctrl = (int)cmdConvPara[2];
		msr_rng = (int)cmdConvPara[3];
	}
	

	smu_measure_current_DI(&msr_val_union.fVal[0], ch, average_cnt, rng_ctrl, msr_rng);


	MsgOut_DI(msr_val_union.cVal, sizeof(float) * 6);

	CMD_WaitTimeDelay();

	CMD_TransmitAck(&trxData);
	//CMD_BinTransmitAck(&trxBinData);

	if(systemReset)
	{
		HAL_Delay(1000);
		NVIC_SystemReset();
	}

	GPIO_LedCtrl(0, LED_OFF); 		//	m_CPU.BusyLed(false);
	
	
}


u8 ProcessSMFV(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

    int ch;
	float v_source;
	int v_source_range;
	float i_limit;
	int i_measure_range;

	// char * strPara;
	// u8 result = 1;
    
	if(argc < 5) return false;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) v_source = strtof(ppArgv[1], NULL);
	if(argc > 2) v_source_range = strtoul(ppArgv[2], NULL, 0);
	if(argc > 3) i_limit = strtof(ppArgv[3], NULL);
	if(argc > 4) i_measure_range = strtoul(ppArgv[4], NULL, 0);
	
	// if (Cmd.m_ParaCount < 5) 
	// {
	// 	//printf("error : %s \n", Cmd.m_Cmd[0]);
	// 	MsgOut("E11\r");
	// 	return;
	// }
	
	/*smu_ch = 1 - 1; 
	v_source = rv * 0.5;
	v_source_range = 2;
	i_limit = 0.001;
	i_measure_range = 8;
	if( rv < 1 ) 
		rv = 1.0;
	else
		rv = 0.0;*/
	
    //TRACE( "ch: %d, v_src : %e, v_src_rng : %d, limit %e, comp %d \n", smu_ch, v_source, v_source_range, i_limit, i_measure_range );
	//smu_output_rly_on(smu_ch);
    //Delay_ms(50);

    // SMVS 12,5,2,0.1,0.1
	smu_force_voltage(ch, v_source, v_source_range, i_limit, i_measure_range);

	tst_MsgOut("E00\r");

	return true;
}

u8 ProcessSMFI(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

    int ch;
	float i_source;
	int i_source_range;
	float v_limit;
	int v_measure_range;

	// char * strPara;
	// u8 result = 1;
    
	if(argc < 5) return false;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) i_source = strtof(ppArgv[1], NULL);
	if(argc > 2) i_source_range = strtoul(ppArgv[2], NULL, 0);
	if(argc > 3) v_limit = strtof(ppArgv[3], NULL);
	if(argc > 4) v_measure_range = strtoul(ppArgv[4], NULL, 0);

	smu_force_current(ch, i_source, i_source_range, v_limit, v_measure_range);

	tst_MsgOut("E00\r");
	
	return true;
}

u8 ProcessSMMV(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	char msr_val[1024];
    int ch;
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	// char * strPara;
	// u8 result = 1;
    
	if(argc > 4) return false;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) average_cnt = strtoul(ppArgv[1], NULL, 0);


	if(argc == 2)
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_vrange(ch);
	}
	if(argc == 4)
	{
		rng_ctrl = *ppArgv[2];
		msr_rng = strtoul(ppArgv[3], NULL, 0);
	}


	// if (Cmd.m_ParaCount == 4)
	// {
	// 	rng_ctrl = Cmd.m_Para[2][0];
	// 	msr_rng = atol(Cmd.m_Para[3]);
	// }
	// else
	// {
	// 	rng_ctrl = RANGE_AUTO;
	// 	msr_rng = read_smu_vrange(ch);
	// }

	smu_measure_voltage(msr_val, ch, average_cnt, rng_ctrl, msr_rng);
	tst_MsgOut("E00 %s\r", msr_val);

	return true;
	
}


u8 ProcessSMMI(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	char msr_val[1024];
    int ch;
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	// char * strPara;
	// u8 result = 1;
    
	if(!((argc == 2) || (argc == 4))) return false;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) average_cnt = strtoul(ppArgv[1], NULL, 0);
	if(argc == 2)
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_vrange(ch);
	}
	if(argc == 4)
	{
		rng_ctrl = *ppArgv[2];
		msr_rng = strtoul(ppArgv[3], NULL, 0);
	}
	if(argc > 4)
	{
		return false;
	}

	// ch = atol(Cmd.m_Para[0]) - 1;
	// average_cnt = atol(Cmd.m_Para[1]);
	
	// if (Cmd.m_ParaCount == 4)
	// {
	// 	rng_ctrl = Cmd.m_Para[2][0];
	// 	msr_rng = atol(Cmd.m_Para[3]);
	// }
	// else
	// {
	// 	rng_ctrl = RANGE_AUTO;
	// 	msr_rng = read_smu_irange(ch);
	// }

	smu_measure_current(msr_val, ch, average_cnt, rng_ctrl, msr_rng);
	tst_MsgOut("E00 %s\r", msr_val);

	return true;
	
}

u8 ProcessSMFVM(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	int cnt;
	int smuCount;
	int smuChannel[NO_OF_SMU];
	float v_source[NO_OF_SMU];
	int v_source_range[NO_OF_SMU];
	float i_limit[NO_OF_SMU];
	int i_measure_range[NO_OF_SMU];

	int v_source_range_cpy;
	float i_limit_cpy;
	int i_measure_range_cpy;

	smuCount = strtoul(ppArgv[0], NULL, 0);

	if((smuCount > NO_OF_SMU) || (argc != (smuCount * 2) + 4))
	{
		// error
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	for(cnt = 0; cnt < smuCount; cnt++)
	{
		smuChannel[cnt] = strtoul(ppArgv[cnt*2+1], NULL, 0) - 1;
		v_source[cnt] = strtof(ppArgv[cnt*2+2], NULL);
	}
	
	v_source_range_cpy = strtoul(ppArgv[(smuCount*2)+1], NULL, 0);
	i_limit_cpy = strtof(ppArgv[(smuCount*2)+2], NULL);
	i_measure_range_cpy = strtoul(ppArgv[(smuCount*2)+3], NULL, 0);

	for(cnt = 0; cnt < smuCount; cnt++)
	{
		v_source_range[cnt] = v_source_range_cpy;
		i_limit[cnt] = i_limit_cpy;
		i_measure_range[cnt] = i_measure_range_cpy;
	}

	smu_force_voltage_multi(smuCount, smuChannel, v_source, v_source_range, i_limit, i_measure_range);

    tst_MsgOut("E00\r");

	return true;

}









u8 ProcessSMFIM(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	int cnt;
	int smuCount;
	int smuChannel[NO_OF_SMU];
	float i_source[NO_OF_SMU];
	int i_source_range[NO_OF_SMU];
	float v_limit[NO_OF_SMU];
	int v_measure_range[NO_OF_SMU];

	int i_source_range_cpy;
	float v_limit_cpy;
	int v_measure_range_cpy;

	smuCount = strtoul(ppArgv[0], NULL, 0);

	if((smuCount > NO_OF_SMU) || (argc != (smuCount * 2) + 4))
	{
		// error
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	for(cnt = 0; cnt < smuCount; cnt++)
	{
		smuChannel[cnt] = strtoul(ppArgv[cnt*2+1], NULL, 0) - 1;
		i_source[cnt] = strtof(ppArgv[cnt*2+2], NULL);
	}
	
	i_source_range_cpy = strtoul(ppArgv[(smuCount*2)+1], NULL, 0);
	v_limit_cpy = strtof(ppArgv[(smuCount*2)+2], NULL);
	v_measure_range_cpy = strtoul(ppArgv[(smuCount*2)+3], NULL, 0);

	for(cnt = 0; cnt < smuCount; cnt++)
	{
		i_source_range[cnt] = i_source_range_cpy;
		v_limit[cnt] = v_limit_cpy;
		v_measure_range[cnt] = v_measure_range_cpy;
	}

	smu_force_current_multi(smuCount, smuChannel, i_source, i_source_range, v_limit, v_measure_range);
	
	tst_MsgOut("E00\r");

	return true;
	
}




u8 ProcessSMMVM(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	int cnt;
	char msr_val[1024];
	int selectCnt;
	int a_ch[NO_OF_SMU];
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	/* 입력 순서
	선택채널갯수, 채널0, ... 채널n, 측정횟수, 레인지컨트롤, 측정레인지
	*/

	selectCnt = strtoul(ppArgv[0], NULL, 0);
	if(selectCnt > NO_OF_SMU)
	{
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		a_ch[cnt] = strtoul(ppArgv[cnt+1], NULL, 0) - 1;
	}

	average_cnt = strtoul(ppArgv[selectCnt+1], NULL, 0);

	if(argc == selectCnt+4)
	{
		// rng_ctrl = Cmd.m_Para[selectCnt+2][0];
		// msr_rng = atoi(Cmd.m_Para[selectCnt+3]);
		
		rng_ctrl = *ppArgv[selectCnt+2];
		msr_rng = strtoul(ppArgv[selectCnt+3], NULL, 0);
	}
	else if(argc == selectCnt+2)
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_vrange(a_ch[0]);
	}
	else
	{
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	//memset(msr_val, NULL, sizeof(msr_val));

	msr_val[0] = 0;

    //SMU_MMV
	smu_measure_voltage_multi(msr_val, selectCnt, a_ch, average_cnt, rng_ctrl, msr_rng);

	tst_MsgOut("E00 %s\r", msr_val);

	return true;
}



u8 ProcessSMMIM(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;
	
	int cnt;
	char msr_val[1024];
	int selectCnt;
	int a_ch[NO_OF_SMU];
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	/* 입력 순서
	선택채널갯수, 채널0, ... 채널n, 측정횟수, 레인지컨트롤, 측정레인지
	*/

	selectCnt = strtoul(ppArgv[0], NULL, 0);
	if(selectCnt > NO_OF_SMU)
	{
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	for(cnt = 0; cnt < selectCnt; cnt++)
	{
		a_ch[cnt] = strtoul(ppArgv[cnt+1], NULL, 0) - 1;
	}

	average_cnt = strtoul(ppArgv[selectCnt+1], NULL, 0);

	if(argc == selectCnt+4)
	{
		rng_ctrl = *ppArgv[selectCnt+2];
		msr_rng = strtoul(ppArgv[selectCnt+3], NULL, 0);
	}
	else if(argc == selectCnt+2)
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_vrange(a_ch[0]);
	}
	else
	{
		tst_MsgOut("E01\r");
		// errFlag++;
		return false;
	}

	//memset(msr_val, NULL, sizeof(msr_val));

	msr_val[0] = 0;

    //SMU_MMI
	smu_measure_current_multi(msr_val, selectCnt, a_ch, average_cnt, rng_ctrl, msr_rng);

	tst_MsgOut("E00 %s\r", msr_val);

	return true;
}
































u8 ProcessSMU_FORCE_RLY(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

    int ch;
	char * strPara;
	u8 result = 1;
    
	if (argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if (argc > 1) strPara = ppArgv[1];

    if(strcmp(strPara, "ON") == 0)
	{
        smu_force_rly_ctrl(ch, smu_ctrl_reg[ch].force_relay_ctrl | SMU_FOCE_REL);
	}
	else if(strcmp(strPara, "OFF") == 0)
	{
	    smu_force_rly_ctrl(ch, smu_ctrl_reg[ch].force_relay_ctrl & ~SMU_FOCE_REL);
	}
	else
	{
		result = 0;
	}

	tst_MsgOut("E00\r");

	return result;
}

// u8 ProcessSMU_OUT_SENSE_RLY(void* pCmd, int argc, void* pData)
// {
// 	char **ppArgv = (char**)pData;

//     int ch;
// 	char * strPara;
// 	u8 result = 1;
    
// 	if (argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
// 	if (argc > 1) strPara = ppArgv[1];

//     if(strcmp(strPara, "ON") == 0)
// 	{
//         smu_output_rly_ctrl(ch, smu_ctrl_reg[ch].output_relay_ctrl | SMU_OUT_SENS_REL);
// 	}
// 	else if(strcmp(strPara, "OFF") == 0)
// 	{
// 	    smu_output_rly_ctrl(ch, smu_ctrl_reg[ch].output_relay_ctrl & ~SMU_OUT_SENS_REL);
// 	}
// 	else
// 	{
// 		result = 0;
// 	}

// 	tst_MsgOut("E00\r");

// 	return result;
// }

u8 ProcessGNDU_FORCE_RLY(void* pCmd, int argc, void* pData)
{
	char **ppArgv = (char**)pData;

	char * strPara;
	u8 result = 1;
    
	if(argc > 1) return false;

	if(argc > 0) strPara = ppArgv[0];

    if(strcmp(strPara, "ON") == 0)
	{
		write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl | (GNDU_F_RELAY | GNDU_S_RELAY));
	}
	else if(strcmp(strPara, "OFF") == 0)
	{
		write_gndu_out_relay_ctrl(gndu_ctrl_reg.output_relay_ctrl & ~(GNDU_F_RELAY | GNDU_S_RELAY));
	}
	else
	{	
	   result = 0;
	}

	tst_MsgOut("E00\r");

	return result;

}










//S3100 Functon  //////////////////////////////////////////////////////////

// SMU

// GNDU




u8 ProcessGNDU_FORCE_V_TEST(void* pCmd, int argc, void* pData)
{
	// force_v format
	char **ppArgv = (char**)pData;

    int ch;
	float v_source;
	int v_source_range;
	float i_limit;
	int i_measure_range;

	char * strPara;
	u8 result = 1;
    
	if(argc < 5) return false;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) v_source = strtof(ppArgv[1], NULL);
	if(argc > 2) v_source_range = strtoul(ppArgv[2], NULL, 0);
	if(argc > 3) i_limit = strtof(ppArgv[3], NULL);
	if(argc > 4) i_measure_range = strtoul(ppArgv[4], NULL, 0);

	int i;

	TestFunction1(v_source);
	
	// for(i = 0; i < (36/2); i ++)
	// {
	// 	//TestFunction1(v_source);
	// 	TestFunction3(v_source);
	// 	TestFunction3(0.0);
	// }
	// TestFunction3(0.0);

	tst_MsgOut("E00\r");
	
	return true;

}


u8 ProcessGNDU_MEAS_I_TEST(void* pCmd, int argc, void* pData)
{
	// measure_i format
	char **ppArgv = (char**)pData;

	char msr_val[1024];
    int ch;
	int average_cnt;
	char rng_ctrl;
	int msr_rng;

	char * strPara;
	u8 result = 1;

	float meas_val;

	if(argc > 0) ch = strtoul(ppArgv[0], NULL, 0) - 1;
	if(argc > 1) average_cnt = strtoul(ppArgv[1], NULL, 0);
	if(argc == 2)
	{
		rng_ctrl = RANGE_AUTO;
		msr_rng = read_smu_vrange(ch);
	}
	if(argc == 4)
	{
		rng_ctrl = *ppArgv[2];
		msr_rng = strtoul(ppArgv[3], NULL, 0);
	}
	if(argc > 4)
	{
		return false;
	}

	meas_val = TestFunction2();	
    //TRACE("meas val %f\r\n", meas_val);

	tst_MsgOut("E00\r");

	return true;
}

u8 ProcessRETURN_OK(void* pCmd, int argc, void* pData)
{
	tst_MsgOut("E00\r");
	return true;
}



// public string gndu_FID_read() {
// 	string ret = "";
// 	ret = GetWireOutValue(EP_ADRS__FPGA_IMAGE_ID_WO).ToString("X8");
// 	return ret;
// }       

float gndu_temp_read() {
	float ret;
	ret = (float)GetWireOutValue(SLOT_CS2, SPI_SEL_M0, EP_ADRS__XADC_TEMP_WO, 0xFFFFFFFF)/1000;
	return ret;
}

u32 gndu_D_RLY_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__DIAG_RELAY_TI, 0);           // EP for DIAG_RELAY_TI // clear pulse
	return 0;
}

u32 gndu_D_RLY_send(u32 dat) {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__DIAG_RELAY_WI, dat, 0xFFFFFFFF); // EP for DIAG_RELAY_WI // set ...
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__DIAG_RELAY_TI, 1);           // EP for DIAG_RELAY_TI // latch pulse
	return 0;
}

u32 gndu_VDAC_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__VDAC_CON_TI, 0); // EP for VDAC_CON_TI // reset pulse
	return 0;
}

u32 gndu_VDAC_send(float dat_float) {
	s32 dat;
	if (dat_float>0) {
		dat = (s32)(16384*((dat_float)/5.0)); // 0x0000_4000 = 16384
		if (dat>32767) // 0x0000_7FFF = 32767
			dat = 32767;
	}
	else {
		dat = (s32)(-16384*((dat_float)/-5.0)); // 0xFFFF_C000 = -0x4000 = -16384
		if (dat<-32768) // 0xFFFF_8000 = -32768
			dat = -32768;
	}
	//Console.WriteLine(">>> DAC test : " + string.Format(" {0} ... 0x{1,8:X8}", dat_float, (u32)dat));
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__VDAC_VAL_WI, (u32)dat, 0xFFFFFFFF); // EP for VDAC_VAL_WI 
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__VDAC_CON_TI, 1); // EP for VDAC_CON_TI // write pulse
	return 0;
}


u32 gndu_O_RLY_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__OUTP_RELAY_TI, 0); // clear pulse
	return 0;
}

u32 gndu_O_RLY_send(u32 dat) {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__OUTP_RELAY_WI, dat, 0xFFFFFFFF); // set ...
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__OUTP_RELAY_TI, 1); // latch pulse
	return 0;
}

u32 gndu_V_RNG_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__VM_RANGE_TI, 0); // clear pulse
	return 0;
}

u32 gndu_V_RNG_send_act_high(u32 dat) {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__VM_RANGE_WI, ~dat, 0xFFFFFFFF); // set ... // inversion
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__VM_RANGE_TI, 1); // latch pulse
	return 0;
}

u32 gndu_A_SEL_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__ADC_IN_SEL_TI, 0); // clear pulse
	return 0;
}

u32 gndu_A_SEL_send_act_high(u32 dat) {
	//assign A_SEL___0V__G_REF_SEL = r_ADC_IN_SEL_Val[3];
	//assign A_SEL___5V__G_REF_SEL = r_ADC_IN_SEL_Val[2];
	//assign A_SEL__GND__ADCIN_SEL = r_ADC_IN_SEL_Val[1];
	//assign A_SEL__DIAG_ADCIN_SEL = r_ADC_IN_SEL_Val[0];            
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__ADC_IN_SEL_WI, ~dat, 0xFFFFFFFF); // set ... // inversion
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__ADC_IN_SEL_TI, 1); // latch pulse
	return 0;
}

u32 PAR__A_SEL__DIAG     = 0x00000001;
u32 PAR__A_SEL__GND      = 0x00000002;
u32 PAR__A_SEL__5V_G_REF = 0x00000004;
u32 PAR__A_SEL__0V_G_REF = 0x00000008;

u32 gndu_A_SEL__diag() {
	return gndu_A_SEL_send_act_high(PAR__A_SEL__DIAG);
}
u32 gndu_A_SEL__gnd() {
	return gndu_A_SEL_send_act_high(PAR__A_SEL__GND);
}
u32 gndu_A_SEL__5V_gref() {
	return gndu_A_SEL_send_act_high(PAR__A_SEL__5V_G_REF);
}
u32 gndu_A_SEL__0V_gref() {
	return gndu_A_SEL_send_act_high(PAR__A_SEL__0V_G_REF);
}

u32 gndu_LED_reset() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__TEST_LED_TI, 0);    // trigger_led_count_reset
	return 0;
}

u32 gndu_LED_load_test_data(u32 dat_b4) {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__TEST_LED_WI, dat_b4&0x0000000F, 0xFFFFFFFF); // set ... 
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__TEST_LED_TI, 1);    // trigger_led_count_load
	return 0;
}

u32 gndu_LED_inc_test_data() {
	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__TEST_LED_TI, 2);    // trigger_led_count_up
	return 0;
}

u32 gndu_HRADC_enable() {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_CON_WI, 0x00000001, 0xFFFFFFFF); // enable
	// clear IO reg in ADC after power-on
	gndu_HRADC_measure(); // send dummy converion and sck signals.
	return 0;
}

u32 gndu_HRADC_disable() {
	SetWireInValue   (SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_CON_WI, 0x00000000, 0xFFFFFFFF); // disable
	return 0;
}

float gndu_HRADC_measure() {
	// single trigger

	// assumed: gndu_HRADC_enable()

	ActivateTriggerIn(SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_TRIG_TI, 0); // trigger conversion

	// check trigger done
	s32 cnt_loop = 0;
	bool ret_bool;
	while (true) {
		ret_bool = IsTriggered(SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_TRIG_TO, 0x01); // adc conversion done 
		if (ret_bool==true) {
			break;
		}
		cnt_loop += 1;
	}

	// read adc value
	u32 val = GetWireOutValue(SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_DAT_WO, 0xFFFFFFFF);

	// LTC2380 24bit, ref 5V ... -5V ~ +5V ... extented 32bit -2^31(-2147483648) ~ 2^31-1(2147483647)
	s32 val_int = (int)val;
	float LSB = (float)10.0 / (float)4294967296 ; // 10V/2^32
	float val_float = LSB*(float)val_int;

	return val_float;
}

u32 gndu_HRADC_read_status() {
	u32 val = GetWireOutValue(SLOT_CS2, SPI_SEL_M0, EP_ADRS__HRADC_FLAG_WO, 0xFFFFFFFF);
	return val;
}






// //// EEPROM control ...
// u32  eeprom_send_frame_ep (u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32) {
// 	//  def eeprom_send_frame_ep (MEM_WI, MEM_FDAT_WI):
// 	//  	## //// end-point map :
// 	//  	## // wire [31:0] w_MEM_WI      = ep13wire;
// 	//  	## // wire [31:0] w_MEM_FDAT_WI = ep12wire;
// 	//  	## // wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;
// 	//  	## // wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;
// 	//  	## // wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr; 
// 	//  	## // wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; 	

// 	bool ret_bool;
// 	s32 cnt_loop;

// 	SetWireInValue(EP_ADRS__MEM_WI,      MEM_WI_b32); 
// 	SetWireInValue(EP_ADRS__MEM_FDAT_WI, MEM_FDAT_WI_b32); 
// 	//  	# clear TO
// 	GetTriggerOutVector(EP_ADRS__MEM_TO);
// 	//  	# act TI
// 	ActivateTriggerIn(EP_ADRS__MEM_TI, 2);
// 	cnt_loop = 0;
// 	while (true) {
// 		ret_bool = IsTriggered(EP_ADRS__MEM_TO, 0x04);
// 		if (ret_bool==true) {
// 			break;
// 		}
// 		cnt_loop += 1;
// 	}
// 	//$$if (cnt_loop>0) xil_printf("cnt_loop = %d \r\n", cnt_loop);
// 	return 0;
// }

// u32  eeprom_send_frame (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8) {
// 	u32 ret;
// 	u32 set_data_WI = ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
// 	u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
// 	ret = eeprom_send_frame_ep (set_data_WI, set_data_FDAT_WI);
// 	return ret;
// }

// void eeprom_reset_fifo() {
// 	ActivateTriggerIn(EP_ADRS__MEM_TI, 1);
// }

// u16 eeprom_read_fifo (u16 num_bytes_DAT_b16, u8[] buf_dataout) {
// 	u16 ret;
// 	//dcopy_pipe8_to_buf8 (ADRS__MEM_PO, buf_dataout, num_bytes_DAT_b16); // (u32 adrs_p8, u8 *p_buf_u8, u32 len)
// 	// read 32-bit width pipe and collect 8-bit width data
	
// 	u32 adrs = EP_ADRS__MEM_PO;
// 	u8[] buf_pipe = new u8[num_bytes_DAT_b16*4]; // *4 for 32-bit pipe 
	
// 	ret = (u16)ReadFromPipeOut(adrs, ref buf_pipe);

// 	// collect and copy data : buf => buf_dataout
// 	s32 ii;
// 	s32 tmp;
// 	for (ii=0;ii<num_bytes_DAT_b16;ii++) {
// 		tmp = BitConverter.ToInt32(buf_pipe, ii*4); // read one pipe data every 4 bytes
// 		buf_dataout[ii] = (u8) (tmp & 0x000000FF); 
// 	}

// 	return ret;
// }

// u16 eeprom_write_fifo (u16 num_bytes_DAT_b16, u8[] buf_datain) {
// 	u16 ret;
// 	// memory copy from 8-bit width buffer to 32-bit width pipe // ADRS_BASE_MHVSU or MCS_EP_BASE
// 	//dcopy_buf8_to_pipe8  (buf_datain, ADRS__MEM_PI, num_bytes_DAT_b16); //  (u8 *p_buf_u8, u32 adrs_p8, u32 len)

// 	u32 adrs = EP_ADRS__MEM_PI;
	
// 	//u32[] buf_pipe_data = new u32[buf_datain.Length];
// 	u32[] buf_pipe_data = Array.ConvertAll(buf_datain, x => (u32)x );

// 	u8[] buf_pipe = buf_pipe_data.SelectMany(BitConverter.GetBytes).ToArray();

// 	ret = (u16)WriteToPipeIn(adrs, ref buf_pipe);

// 	return ret;
// }


// u16 eeprom_read_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_dataout) {
	
// 	//buf_dataout[0] = (char)0x01; // test
// 	//buf_dataout[1] = (char)0x02; // test
// 	//buf_dataout[2] = (char)0x03; // test
// 	//buf_dataout[3] = (char)0x04; // test

// 	//byte[] buf_bytearray = BitConverter.GetBytes(0xFEDCBA98); // test
// 	//buf_bytearray.CopyTo(buf_dataout, 0); //test

// 	u16 ret;

// 	eeprom_reset_fifo();

// 	u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
// 	u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);

// 	//  	## // CMD_READ__03 
// 	//  	eeprom_send_frame (CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT)
// 	eeprom_send_frame (0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);

// 	ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
	
// 	return ret;
// }

// void eeprom_write_enable() {
// 	//  	## // CMD_WREN__96 
// 	//  	print('\n>>> CMD_WREN__96')
// 	//  	eeprom_send_frame (CMD=0x96, con_disable_SBP=1)
// 	eeprom_send_frame (0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
// }

// void eeprom_write_disable() {
// 	eeprom_send_frame (0x91, 0, 0, 0, 1, 0); 
// }

// u32 eeprom_read_status() {
// 	u32 ret;
// 	//  	## // CMD_RDSR__05 
// 	//  	print('\n>>> CMD_RDSR__05')
// 	//  	eeprom_send_frame (CMD=0x05) 
// 	eeprom_send_frame (0x05, 0, 0, 0, 1, 0); //

// 	//  	# clear TO
// 	ret = GetTriggerOutVector(EP_ADRS__MEM_TO);
// 	//  	# read again TO for reading latched status
// 	ret = GetTriggerOutVector(EP_ADRS__MEM_TO);

// 	//  	MUST_ZEROS = (ret>>12)&0x0F
// 	//  	BP1 = (ret>>11)&0x01
// 	//  	BP0 = (ret>>10)&0x01
// 	//     	WEL = (ret>> 9)&0x01
// 	//  	WIP = (ret>> 8)&0x01
// 	ret = (ret>> 8)&0xFF;
// 	return ret;
// }

// u32 is_eeprom_available() {
// 	u32 ret = 1;
// 	u32 val;
	
// 	eeprom_write_disable();
// 	val = eeprom_read_status();
// 	if ((val&0x02)==0x00) // check WEL
// 		ret = ret*1;
// 	else
// 		ret = ret*0;
	
// 	eeprom_write_enable();
// 	val = eeprom_read_status();
// 	if ((val&0x02)==0x02) // check WEL
// 		ret = ret*1;
// 	else
// 		ret = ret*0;

// 	return ret; // 1 for available; 0 for NA.
// }

// u16 eeprom_write_data_16B (u16 ADRS_b16, u16 num_bytes_DAT_b16) {
// 	eeprom_write_enable();
// 	u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
// 	u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);
// 	//  	
// 	//  	## // CMD_WRITE_6C 
// 	//  	eeprom_send_frame (CMD=0x6C, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT, con_disable_SBP=1)
// 	eeprom_send_frame (0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
// 	return num_bytes_DAT_b16;
// }

// u16 eeprom_write_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_datain) {
// 	u16 ret = num_bytes_DAT_b16;

// 	eeprom_reset_fifo();

// 	if (num_bytes_DAT_b16 <= 16) {
// 		eeprom_write_fifo (num_bytes_DAT_b16, buf_datain);
// 		eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16);
// 		ret = 0; // sent all
// 	}
// 	else {
// 		eeprom_write_fifo (num_bytes_DAT_b16, buf_datain);

// 		while (true) {
// 			eeprom_write_data_16B (ADRS_b16, 16);
// 			//
// 			ADRS_b16          += 16;
// 			ret               -= 16;
// 			//
// 			if (num_bytes_DAT_b16 <= 16) {
// 				eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16);
// 				ret            = 0;
// 				break;
// 			}
// 		}

// 	}
// 	return ret;
// }

// int eeprom__read__data_4byte(int adrs_b32) {
// 	int ret_int;

// 	//// for firmware
// 	u16 adrs = (u16)adrs_b32; 
// 	u8[] buf = new u8[4]; // sizeof(int) : 4
	
// 	//eeprom_read_data((u16)adrs, 4, (u8*)&val); //$$ read eeprom
// 	eeprom_read_data(adrs, 4, buf); // num of bytes : 4 for int
	
// 	// reconstruct int from char[]
// 	byte[] buf_bytearray = Array.ConvertAll(buf, x => (byte)x );
// 	ret_int = BitConverter.ToInt32(buf_bytearray,0);  

// 	//
// 	return ret_int;
// }

// u32 eeprom__read__data_u32(int adrs_b32) {
// 	return (u32)eeprom__read__data_4byte(adrs_b32);
// }

// void eeprom__read__buf_u8(int adrs_b32, u32 size_buf_u32, u8 [] buf_u8) {
// 	eeprom_read_data((u16)adrs_b32, (u16)size_buf_u32, buf_u8);
// }

// float eeprom__read__data_float(int adrs_b32) {
// 	s32 val = eeprom__read__data_4byte(adrs_b32);

// 	var bytes  = BitConverter.GetBytes(val);
// 	var result = BitConverter.ToSingle(bytes, 0);

// 	return result;
// }

// s32 eeprom__read__data_s32(int adrs_b32) {
// 	return eeprom__read__data_4byte(adrs_b32);
// }


// // read eeprom: data_u8, data_u32, data_float, buf_u8.
// // convert hex form for 16 bytes:
// //   hex_txt_display()
// //   # 014  0x00E0  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................

// u8 ignore_nonprint_code(u8 ch) {
// 	if (ch< 0x20 || ch>0x7E)
// 	ch = (byte)'.';
// 	return ch;
// }

// string hex_txt_display (s16 len_b16, u8 [] mem_buf_u8, u32 adrs_offset_u32) {
// 	//string tmp_str = "# 018  0x0120  FF FF FF FE DC BA FF FF  FF FF FF FF FF FF FF FF  ................ \n";
// 	string tmp_str = "";

// 	const s32 num_bytes_in_a_display_line = 16;
// 	u8 [] tmp_buf_u8 = new u8[num_bytes_in_a_display_line];

// 	for (s32 ii=0; ii<len_b16; ii=ii+num_bytes_in_a_display_line) {
// 		//
// 		tmp_str += String.Format("# {0:000}  0x{1:X4}  ", ii/num_bytes_in_a_display_line, adrs_offset_u32+ii);
// 		//
// 		Array.Copy(mem_buf_u8,ii, tmp_buf_u8,0x0, num_bytes_in_a_display_line);
// 		for (s32 jj=0; jj<num_bytes_in_a_display_line/2; jj++) {
// 			tmp_str += String.Format("{0:X2} ",tmp_buf_u8[jj]);
// 		}
// 		//
// 		tmp_str += String.Format(" ");
// 		//
// 		for (s32 jj=num_bytes_in_a_display_line/2; jj<num_bytes_in_a_display_line; jj++) {
// 			tmp_str += String.Format("{0:X2} ",tmp_buf_u8[jj]);
// 		}
// 		//
// 		tmp_str += String.Format(" ");
// 		//
// 		Array.Copy(mem_buf_u8,ii, tmp_buf_u8,0x0, num_bytes_in_a_display_line);
// 		for (s32 jj=0; jj<num_bytes_in_a_display_line; jj++) {
// 			tmp_str += String.Format("{0}",(char)ignore_nonprint_code(tmp_buf_u8[jj]));
// 		}
// 		//
// 		tmp_str += String.Format("\n");
// 	}

// 	return tmp_str;
// }

// int eeprom__write_data_4byte(int adrs_b32, uint val_b32, int interval_ms = 0) {
// 	int ret_int = 0;

// 	//// for firmware
// 	u32 val  = (u32)val_b32;
// 	u16 adrs = (u16)adrs_b32; 

// 	byte[] buf_bytearray = BitConverter.GetBytes(val);
// 	u8[] buf = Array.ConvertAll(buf_bytearray, x => (u8)x );

// 	eeprom_write_data(adrs, 4, buf); //$$ write eeprom 

// 	if (interval_ms == 0) {
// 		u32 cnt = 0;
// 		while (true) {
// 			u32 flag = eeprom_read_status();
// 			cnt++;
// 			if ( (flag&0x01) == 0x00) // check WIP
// 				break;
// 		}
// 	} 
// 	else {
// 		Delay(interval_ms); //$$ ms wait for write done 
// 	}
	

// 	return ret_int;
// }

// int eeprom__write_data_u32(int adrs_b32, uint val_b32, int interval_ms = 0) {
// 	return eeprom__write_data_4byte(adrs_b32, val_b32, interval_ms);
// 	}

// int eeprom__write_data_float(int adrs_b32, float val_float, int interval_ms = 0) {
// 	//return eeprom__write_data_4byte(adrs_b32, val_b32, interval_ms);
// 	var bytes  = BitConverter.GetBytes(val_float);
// 	var val_u32 = BitConverter.ToUInt32(bytes, 0);

// 	return eeprom__write_data_4byte(adrs_b32, val_u32, interval_ms);
// 	}

// int eeprom__write_data_s32(int adrs_b32, s32 val_s32, int interval_ms = 0) {
// 	return eeprom__write_data_4byte(adrs_b32, (u32)val_s32, interval_ms);
// }

// int eeprom__write_data_1byte(int adrs_b32, u8 val_b8, int interval_ms = 0) {
// 	int ret_int = 0;

// 	//// for firmware
// 	u32 val  = (u32)val_b8;
// 	u16 adrs = (u16)adrs_b32; 

// 	//byte[] buf_bytearray = BitConverter.GetBytes(val);
// 	//u8[] buf = Array.ConvertAll(buf_bytearray, x => (u8)x );
// 	u8[] buf = {val_b8};

// 	eeprom_write_data(adrs, 1, buf); //$$ write eeprom 

// 	Delay(interval_ms); //$$ ms wait for write done 

// 	return ret_int;
// }

// int eeprom__write_data_u8(int adrs_b32, u8 val_b8, int interval_ms = 0) {
// 	return eeprom__write_data_1byte(adrs_b32, val_b8, interval_ms);
// }

// int eeprom__write_buf_u8(int adrs_b32, u32 size_buf_u32, u8[] buf_b8, int interval_ms = 0) {
// 	//return eeprom__write_data_1byte(adrs_b32, buf_b8, interval_ms);
// 	// check every 16 bytes
// 	return 0;
// }





// }