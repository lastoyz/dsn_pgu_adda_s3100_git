#include	"Cmd_Power.h"

u8 Cmd_Power(void *pTrxData, u16 *pArgc, u8 **pArgv)
{
	u8 chkr, result = 1;
	u16 argc = *pArgc;

	if(CMD_Compare(pArgv[1], "revision"))
	{
		u8	revData[16];

		CMD_Printf(";REVISION");

		if(argc != 2)	goto CMD_POWER_ERROR;

		memset(revData, NULL, sizeof(revData));

//		chkr = PWR_Revision(revData);

		if(chkr == 0)	goto CMD_POWER_ERROR;

		CMD_Printf(";%s", revData);
	}
#if 0
	else if(CMD_Compare(pArgv[1], "init"))
	{
		CMD_Printf(";INIT");

		if(argc != 3)	goto CMD_POWER_ERROR;
		if(CMD_Compare(pArgv[2], "all"))
		{
			chkr = PWR_Init(PWR_ALL);
		}
		else if(CMD_Compare(pArgv[2], "vm"))
		{
			chkr = PWR_Init(PWR_VM_0);
		}
		else if(CMD_Compare(pArgv[2], "vspn"))
		{
			chkr = PWR_Init(PWR_VSPN);
		}
		else if(CMD_Compare(pArgv[2], "blu"))
		{
			chkr = PWR_Init(PWR_BLU_0);
		}
		else if(CMD_Compare(pArgv[2], "vio") || CMD_Compare(pArgv[2], "gpio"))
		{
			chkr = PWR_Init(PWR_VIO);
		}
		else			goto CMD_POWER_ERROR;

		if(chkr == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "dac.delay"))
	{
		u8	save = 0;
		u32	delay;

		if(argc == 3)
		{
			delay = CMD_StrToUL(pArgv[2]);

			if(delay < 100)					goto CMD_POWER_ERROR;
			if(delay > 100000)				goto CMD_POWER_ERROR;

			chkr = PWR_DacDelay(save, delay);
		}
		else if(argc == 4)
		{
			save	= CMD_StrToUL(pArgv[2]);
			delay	= CMD_StrToUL(pArgv[3]);

			if((save != 0) && (save != 1))	goto CMD_POWER_ERROR;

			if(delay < 100)					goto CMD_POWER_ERROR;
			if(delay > 100000)				goto CMD_POWER_ERROR;


			chkr = PWR_DacDelay(save, delay);
		}
		else		goto CMD_POWER_ERROR;
		
		if(chkr == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "config.clear"))
	{
		CMD_Printf(";CONFIG.CLEAR");

		if(argc != 2)	goto CMD_POWER_ERROR;

		chkr = PWR_SysConfigClear();

		if(chkr == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.clear"))
	{
		CMD_Printf(";CAL.CLEAR");

		if(argc != 2)	goto CMD_POWER_ERROR;

		chkr = PWR_CalDataClear();

		if(chkr == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "on"))
	{
		u8 listCnt;
		u8 list[16];
		
		CMD_Printf(";ON");

		if(argc < 3)		goto CMD_POWER_ERROR;
		
		listCnt = argc - 2;

		if(listCnt > 9)		goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			if(CMD_Compare(pArgv[cnt + 2], "vdd") || CMD_Compare(pArgv[cnt + 2], "vlcd"))		list[cnt] = PWR_VM_0;
			else if(CMD_Compare(pArgv[cnt + 2], "vio") || CMD_Compare(pArgv[cnt + 2], "vbat"))	list[cnt] = PWR_VM_1;
			else if(CMD_Compare(pArgv[cnt + 2], "led") || CMD_Compare(pArgv[cnt + 2], "vext"))	list[cnt] = PWR_VM_2;
			else if(CMD_Compare(pArgv[cnt + 2], "vcc"))											list[cnt] = PWR_VM_3;
			else if(CMD_Compare(pArgv[cnt + 2], "vbl"))											list[cnt] = PWR_VM_4;
			else if(CMD_Compare(pArgv[cnt + 2], "vout"))										list[cnt] = PWR_VM_5;			
			else if(CMD_Compare(pArgv[cnt + 2], "vspn"))										list[cnt] = PWR_VSPN;
			else if(CMD_Compare(pArgv[cnt + 2], "blu0"))										list[cnt] = PWR_BLU_0;
			else if(CMD_Compare(pArgv[cnt + 2], "blu1"))										list[cnt] = PWR_BLU_1;
			else 																				goto CMD_POWER_ERROR;
		}

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			chkr = PWR_Enable(list[cnt]);

			if(chkr == 0)	goto CMD_POWER_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "off"))
	{
		u8 listCnt;
		u8 list[16];
		
		CMD_Printf(";OFF");

		if(argc < 3)		goto CMD_POWER_ERROR;

		if((argc == 3) && CMD_Compare(pArgv[2], "all"))
		{
			listCnt = 9;

			list[0] = PWR_VM_0;
			list[1] = PWR_VM_1;
			list[2] = PWR_VM_2;
			list[3] = PWR_VM_3;
			list[4] = PWR_VM_4;
			list[5] = PWR_VM_5;
			list[6] = PWR_VSPN;
			list[7] = PWR_BLU_0;
			list[8] = PWR_BLU_1;
		}
		else
		{
			listCnt = argc - 2;

			if(listCnt > 9)		goto CMD_POWER_ERROR;

			for(u8 cnt = 0; cnt < listCnt; cnt++)
			{
				if(	CMD_Compare(pArgv[cnt + 2], "vdd") || CMD_Compare(pArgv[cnt + 2], "vlcd"))			list[cnt] = PWR_VM_0;
				else if(CMD_Compare(pArgv[cnt + 2], "vio") || CMD_Compare(pArgv[cnt + 2], "vbat"))		list[cnt] = PWR_VM_1;
				else if(CMD_Compare(pArgv[cnt + 2], "led") || CMD_Compare(pArgv[cnt + 2], "vext"))		list[cnt] = PWR_VM_2;
				else if(CMD_Compare(pArgv[cnt + 2], "vcc"))												list[cnt] = PWR_VM_3;
				else if(CMD_Compare(pArgv[cnt + 2], "vbl"))												list[cnt] = PWR_VM_4;
				else if(CMD_Compare(pArgv[cnt + 2], "vout"))											list[cnt] = PWR_VM_5;			
				else if(CMD_Compare(pArgv[cnt + 2], "vspn"))											list[cnt] = PWR_VSPN;
				else if(CMD_Compare(pArgv[cnt + 2], "blu0"))											list[cnt] = PWR_BLU_0;
				else if(CMD_Compare(pArgv[cnt + 2], "blu1"))											list[cnt] = PWR_BLU_1;
				else 																					goto CMD_POWER_ERROR;
			}
		}
		
		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			chkr = PWR_Disable(list[cnt]);

			if(chkr == 0)	goto CMD_POWER_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "voltage"))
	{
		u8 chkr;
		float vol0, vol1;
		
		CMD_Printf(";VOLTAGE");

		if(argc == 3)
		{
			vol0 = CMD_AToF(pArgv[2]);
		}
		else if(argc == 4)
		{
			vol0 = CMD_AToF(pArgv[2]);
			vol1 = CMD_AToF(pArgv[3]);
		}
		else				goto CMD_POWER_ERROR;

		chkr = PWR_OutputVoltage(PWR_VM_0, vol0);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		if(argc == 4)
		{
			chkr = PWR_OutputVoltage(PWR_VM_1, vol1);

			if(chkr == 0)	goto CMD_POWER_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "voltage.channel"))
	{
		u8 position;
		float voltage;
		
		CMD_Printf(";VOLTAGE.CHANNEL");

		if(argc != 4)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vdd") || CMD_Compare(pArgv[2], "vlcd"))		position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vio") || CMD_Compare(pArgv[2], "vbat"))	position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "led") || CMD_Compare(pArgv[2], "vext"))	position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vcc"))									position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vbl"))									position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vout"))									position = PWR_VM_5;			
		else if(CMD_Compare(pArgv[2], "vspn"))									position = PWR_VSPN;
		else if(CMD_Compare(pArgv[2], "blu0"))									position = PWR_BLU_0;
		else if(CMD_Compare(pArgv[2], "blu1"))									position = PWR_BLU_1;
		else 																	goto CMD_POWER_ERROR;

		voltage = CMD_AToF(pArgv[3]);

		chkr = PWR_OutputVoltage(position, voltage);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "current"))
	{
		u8	rtn;
		u8	target;
		float voltage, current;
		
		CMD_Printf(";CURRENT");

		if(argc != 3)	goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vio"))
		{
			target = PWR_VM_0;
		}
		else if(CMD_Compare(pArgv[2], "vdd"))
		{
			target = PWR_VM_1;
		}
		else			goto CMD_POWER_ERROR;

		rtn = PWR_MeasureVI(target, &voltage, &current);

		if(rtn == 0)	goto CMD_POWER_ERROR;

		CMD_Printf(";%fmA", current);

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "gpio.enable"))
	{
		u8	rtn;
		
		CMD_Printf(";GPIO.ENABLE");

		if(argc != 2)	goto CMD_POWER_ERROR;

		rtn = PWR_Enable(PWR_VIO);

		if(rtn == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "gpio.diable"))
	{
		u8	rtn;
		
		CMD_Printf(";GPIO.DISABLE");

		if(argc != 2)	goto CMD_POWER_ERROR;

		rtn = PWR_Disable(PWR_VIO);

		if(rtn == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "gpio.voltage"))
	{
		u8	rtn;
		float voltage;

		CMD_Printf(";GPIO.VOLTAGE");

		if(argc != 3)	goto CMD_POWER_ERROR;

		voltage = CMD_AToF(pArgv[2]);

		rtn = PWR_OutputVoltage(PWR_VIO, voltage);

		if(rtn == 0)	goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "led"))
	{
		float data;
		u8	position, duty;
		
		CMD_Printf(";LED");

		if(argc != 3)		goto CMD_POWER_ERROR;

		position = 0;
		data = CMD_AToF(pArgv[2]);

		if(data > 20)		goto CMD_POWER_ERROR;

		duty = (u8)(data * 5);
		
		chkr = PWR_BluDuty(position, duty);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "led.duty"))
	{
		u8	position, duty;
		
		CMD_Printf(";LED.DUTY");

		if(argc != 4)		goto CMD_POWER_ERROR;

		position = CMD_StrToUL(pArgv[2]);
		duty = CMD_StrToUL(pArgv[3]);

		if(position > 1)	goto CMD_POWER_ERROR;
		if(duty > 100)		goto CMD_POWER_ERROR;
		
		chkr = PWR_BluDuty(position, duty);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "enable"))
	{
		u8 listCnt;
		u8 list[16];
		
		CMD_Printf(";ENABLE");

		if(argc < 3)		goto CMD_POWER_ERROR;
		
		listCnt = argc - 2;

		if(listCnt > 10)	goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			if(CMD_Compare(pArgv[cnt + 2], "vm0"))			list[cnt] = PWR_VM_0;
			else if(CMD_Compare(pArgv[cnt + 2], "vm1"))		list[cnt] = PWR_VM_1;
			else if(CMD_Compare(pArgv[cnt + 2], "vm2"))		list[cnt] = PWR_VM_2;
			else if(CMD_Compare(pArgv[cnt + 2], "vm3"))		list[cnt] = PWR_VM_3;
			else if(CMD_Compare(pArgv[cnt + 2], "vm4"))		list[cnt] = PWR_VM_4;
			else if(CMD_Compare(pArgv[cnt + 2], "vm5"))		list[cnt] = PWR_VM_5;
			else if(CMD_Compare(pArgv[cnt + 2], "vspn"))	list[cnt] = PWR_VSPN;
			else if(CMD_Compare(pArgv[cnt + 2], "blu0"))	list[cnt] = PWR_BLU_0;
			else if(CMD_Compare(pArgv[cnt + 2], "blu1"))	list[cnt] = PWR_BLU_1;
			else if(CMD_Compare(pArgv[cnt + 2], "vio"))		list[cnt] = PWR_VIO;
			else if(CMD_Compare(pArgv[cnt + 2], "gpio"))	list[cnt] = PWR_VIO;
			else 											goto CMD_POWER_ERROR;
		}

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			chkr = PWR_Enable(list[cnt]);

			if(chkr == 0)	goto CMD_POWER_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "disable"))
	{
		u8 listCnt;
		u8 list[16];
		
		CMD_Printf(";DISABLE");

		if(argc < 3)		goto CMD_POWER_ERROR;
		
		listCnt = argc - 2;

		if(listCnt > 10)	goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			if(CMD_Compare(pArgv[cnt + 2], "vm0"))			list[cnt] = PWR_VM_0;
			else if(CMD_Compare(pArgv[cnt + 2], "vm1"))		list[cnt] = PWR_VM_1;
			else if(CMD_Compare(pArgv[cnt + 2], "vm2"))		list[cnt] = PWR_VM_2;
			else if(CMD_Compare(pArgv[cnt + 2], "vm3"))		list[cnt] = PWR_VM_3;
			else if(CMD_Compare(pArgv[cnt + 2], "vm4"))		list[cnt] = PWR_VM_4;
			else if(CMD_Compare(pArgv[cnt + 2], "vm5"))		list[cnt] = PWR_VM_5;
			else if(CMD_Compare(pArgv[cnt + 2], "vspn"))	list[cnt] = PWR_VSPN;
			else if(CMD_Compare(pArgv[cnt + 2], "blu0"))	list[cnt] = PWR_BLU_0;
			else if(CMD_Compare(pArgv[cnt + 2], "blu1"))	list[cnt] = PWR_BLU_1;
			else if(CMD_Compare(pArgv[cnt + 2], "vio"))		list[cnt] = PWR_VIO;
			else if(CMD_Compare(pArgv[cnt + 2], "gpio"))	list[cnt] = PWR_VIO;
			else 											goto CMD_POWER_ERROR;
		}

		for(u8 cnt = 0; cnt < listCnt; cnt++)
		{
			chkr = PWR_Disable(list[cnt]);

			if(chkr == 0)	goto CMD_POWER_ERROR;
		}
	}
	else if(CMD_Compare(pArgv[1], "set.voltage"))
	{
		u8	position;
		float voltage;
		
		CMD_Printf(";SET.VOLTAGE");

		if(argc != 4)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vio"))		position = PWR_VIO;
		else if(CMD_Compare(pArgv[2], "gpio"))		position = PWR_VIO;
		else 										goto CMD_POWER_ERROR;

		voltage = CMD_AToF(pArgv[3]);
		
		chkr = PWR_OutputVoltage(position, voltage);

		if(chkr == 0)								goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "set.current"))
	{
		u8	position;
		float current;
		
		CMD_Printf(";SET.CURRENT");

		if(argc != 4)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = PWR_VM_5;
		else 										goto CMD_POWER_ERROR;

		current = CMD_AToF(pArgv[3]);

		chkr = PWR_OutputCurrent(position, current);

		if(chkr == 0)								goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "range"))
	{
		u8	position, range;
		
		CMD_Printf(";RANGE");

		if(argc != 4)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vspn"))		position = PWR_VSPN;
		else if(CMD_Compare(pArgv[2], "blu0"))		position = PWR_BLU_0;
		else if(CMD_Compare(pArgv[2], "blu1"))		position = PWR_BLU_1;
		else 										goto CMD_POWER_ERROR;

		range = CMD_StrToUL(pArgv[3]);

		chkr = PWR_RangeSelect(position, range);

		if(chkr == 0)								goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "read"))
	{
		u8	position;
		float voltage[4], current[4];
		
		CMD_Printf(";READ");

		if(argc != 3)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vspn"))		position = PWR_VSPN;
		else if(CMD_Compare(pArgv[2], "blu0"))		position = PWR_BLU_0;
		else if(CMD_Compare(pArgv[2], "blu1"))		position = PWR_BLU_1;
		else 										goto CMD_POWER_ERROR;
		
		chkr = PWR_MeasureVI(position, voltage, current);

		if(chkr == 0)								goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < 4; cnt++)
		{
			if(current[cnt] < 0)
			{
				current[cnt] *= -1;
				current[cnt] /= 5;
			}
		}

		if(	(position == PWR_VM_0) || (position == PWR_VM_1) ||
			(position == PWR_VM_2) || (position == PWR_VM_3) ||
			(position == PWR_VM_4) || (position == PWR_VM_5))
		{
			CMD_Printf(";VM%d %fV %fmA", (position - PWR_VM_0), voltage[0], current[0]);
		}
		else if(position == PWR_VSPN)
		{
			CMD_Printf(";VSP %fV %fmA;VSN %fV %fmA", voltage[0], current[0], voltage[1], current[1]);
		}
		else if((position == PWR_BLU_0) || (position == PWR_BLU_1))
		{
			CMD_Printf(";BLU%d %fV %fmA %fmA %fmA %fmA", (position - PWR_BLU_0), voltage[0], current[0], current[1], current[2], current[3]);
		}

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "blu.freq"))
	{
		u32	freq;
		
		CMD_Printf(";BLU.FREQ");

		if(argc != 3)		goto CMD_POWER_ERROR;
		
		freq = CMD_StrToUL(pArgv[2]);

		if(freq > 10000)	goto CMD_POWER_ERROR;
		
		chkr = PWR_BluFreq(freq);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "blu.duty"))
	{
		u8	position, duty;
		
		CMD_Printf(";BLU.DUTY");

		if(argc != 4)		goto CMD_POWER_ERROR;

		position = CMD_StrToUL(pArgv[2]);
		duty = CMD_StrToUL(pArgv[3]);

		if(position > 1)	goto CMD_POWER_ERROR;
		if(duty > 100)		goto CMD_POWER_ERROR;
		
		chkr = PWR_BluDuty(position, duty);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.enable"))
	{
		CMD_Printf(";CAL.ENABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_CalFactorEnable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.disable"))
	{
		CMD_Printf(";CAL.DISABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_CalFactorDisable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.save"))
	{
		CMD_Printf(";CAL.SAVE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_CalFactorSave();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.vout"))
	{
		pwrCalData_t posData;
		float ideal[2], real[2];

		CMD_Printf(";CAL.VOUT");

		if(argc != 7)		goto CMD_POWER_ERROR;

		memset(&posData, NULL, sizeof(posData));

		if(CMD_Compare(pArgv[2], "vm0"))			posData.position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		posData.position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		posData.position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		posData.position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		posData.position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		posData.position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vio"))		posData.position = PWR_VIO;
		else if(CMD_Compare(pArgv[2], "gpio"))		posData.position = PWR_VIO;
		else 										goto CMD_POWER_ERROR;

		ideal[0]	= CMD_AToF(pArgv[3]);
		real[0]		= CMD_AToF(pArgv[4]);
		ideal[1]	= CMD_AToF(pArgv[5]);
		real[1]		= CMD_AToF(pArgv[6]);

		chkr = PWR_CalOutputVoltage(&posData, ideal, real);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.vin"))
	{
		pwrCalData_t posData;
		float ideal[2], real[2];
		
		CMD_Printf(";CAL.VIN");

		if(argc != 7)		goto CMD_POWER_ERROR;

		memset(&posData, NULL, sizeof(posData));

		if(CMD_Compare(pArgv[2], "vm0"))			posData.position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		posData.position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		posData.position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		posData.position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		posData.position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		posData.position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vsp"))
		{
			posData.position = PWR_VSPN;
			posData.mode = 0;
		}
		else if(CMD_Compare(pArgv[2], "vsn"))
		{
			posData.position = PWR_VSPN;
			posData.mode = 1;
		}
		else if(CMD_Compare(pArgv[2], "blu0"))		posData.position = PWR_BLU_0;
		else if(CMD_Compare(pArgv[2], "blu1"))		posData.position = PWR_BLU_1;
		else 										goto CMD_POWER_ERROR;

		ideal[0]	= CMD_AToF(pArgv[3]);
		real[0]		= CMD_AToF(pArgv[4]);
		ideal[1]	= CMD_AToF(pArgv[5]);
		real[1]		= CMD_AToF(pArgv[6]);

		chkr = PWR_CalMeasureVoltage(&posData, ideal, real);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.cin"))
	{
		pwrCalData_t posData;
		float ideal[2], real[2];
		
		CMD_Printf(";CAL.CIN");

		if(argc != 8)		goto CMD_POWER_ERROR;

		memset(&posData, NULL, sizeof(posData));

		if(CMD_Compare(pArgv[2], "vm0"))			posData.position = PWR_VM_0;
		else if(CMD_Compare(pArgv[2], "vm1"))		posData.position = PWR_VM_1;
		else if(CMD_Compare(pArgv[2], "vm2"))		posData.position = PWR_VM_2;
		else if(CMD_Compare(pArgv[2], "vm3"))		posData.position = PWR_VM_3;
		else if(CMD_Compare(pArgv[2], "vm4"))		posData.position = PWR_VM_4;
		else if(CMD_Compare(pArgv[2], "vm5"))		posData.position = PWR_VM_5;
		else if(CMD_Compare(pArgv[2], "vsp"))
		{
			posData.position	= PWR_VSPN;
			posData.mode		= 0;
		}
		else if(CMD_Compare(pArgv[2], "vsn"))
		{
			posData.position	= PWR_VSPN;
			posData.mode		= 1;
		}
		else if(CMD_Compare(pArgv[2], "blu0_0"))
		{
			posData.position	= PWR_BLU_0;
			posData.channel		= 0;
		}
		else if(CMD_Compare(pArgv[2], "blu0_1"))
		{
			posData.position	= PWR_BLU_0;
			posData.channel		= 1;
		}
		else if(CMD_Compare(pArgv[2], "blu0_2"))
		{
			posData.position	= PWR_BLU_0;
			posData.channel		= 2;
		}
		else if(CMD_Compare(pArgv[2], "blu0_3"))
		{
			posData.position	= PWR_BLU_0;
			posData.channel		= 3;
		}
		else if(CMD_Compare(pArgv[2], "blu1_0"))
		{
			posData.position	= PWR_BLU_1;
			posData.channel		= 0;
		}
		else if(CMD_Compare(pArgv[2], "blu1_1"))
		{
			posData.position	= PWR_BLU_1;
			posData.channel		= 1;
		}
		else if(CMD_Compare(pArgv[2], "blu1_2"))
		{
			posData.position	= PWR_BLU_1;
			posData.channel		= 2;
		}
		else if(CMD_Compare(pArgv[2], "blu1_3"))
		{
			posData.position	= PWR_BLU_1;
			posData.channel		= 3;
		}
		else 										goto CMD_POWER_ERROR;

		posData.range = CMD_StrToUL(pArgv[3]);

		ideal[0]	= CMD_AToF(pArgv[4]);
		real[0]		= CMD_AToF(pArgv[5]);
		ideal[1]	= CMD_AToF(pArgv[6]);
		real[1]		= CMD_AToF(pArgv[7]);

		chkr = PWR_CalMeasureCurrent(&posData, ideal, real);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "cal.get"))
	{
		pwrCalData_t posData;
		float gain, offset;

		CMD_Printf(";CAL.GET");

		memset(&posData, NULL, sizeof(posData));

		if(CMD_Compare(pArgv[2], "vout"))		// Output Voltage
		{
			posData.mode = 0;

			if(argc != 4)								goto CMD_POWER_ERROR;

			if(CMD_Compare(pArgv[3], "vm0"))			posData.position = PWR_VM_0;
			else if(CMD_Compare(pArgv[3], "vm1"))		posData.position = PWR_VM_1;
			else if(CMD_Compare(pArgv[3], "vm2"))		posData.position = PWR_VM_2;
			else if(CMD_Compare(pArgv[3], "vm3"))		posData.position = PWR_VM_3;
			else if(CMD_Compare(pArgv[3], "vm4"))		posData.position = PWR_VM_4;
			else if(CMD_Compare(pArgv[3], "vm5"))		posData.position = PWR_VM_5;
			else if(CMD_Compare(pArgv[3], "vio"))		posData.position = PWR_VIO;
			else if(CMD_Compare(pArgv[3], "gpio"))		posData.position = PWR_VIO;
			else										goto CMD_POWER_ERROR;
		}
		else if(CMD_Compare(pArgv[2], "vin"))	// Input Voltage
		{
			posData.mode = 1;

			if(argc != 4)								goto CMD_POWER_ERROR;

			if(CMD_Compare(pArgv[3], "vm0"))			posData.position = PWR_VM_0;
			else if(CMD_Compare(pArgv[3], "vm1"))		posData.position = PWR_VM_1;
			else if(CMD_Compare(pArgv[3], "vm2"))		posData.position = PWR_VM_2;
			else if(CMD_Compare(pArgv[3], "vm3"))		posData.position = PWR_VM_3;
			else if(CMD_Compare(pArgv[3], "vm4"))		posData.position = PWR_VM_4;
			else if(CMD_Compare(pArgv[3], "vm5"))		posData.position = PWR_VM_5;
			else if(CMD_Compare(pArgv[3], "vsp"))
			{
				posData.position	= PWR_VSPN;
				posData.channel		= 0;
			}
			else if(CMD_Compare(pArgv[3], "vsn"))
			{
				posData.position	= PWR_VSPN;
				posData.channel		= 1;
			}
			else if(CMD_Compare(pArgv[3], "blu0"))		posData.position = PWR_BLU_0;
			else if(CMD_Compare(pArgv[3], "blu1"))		posData.position = PWR_BLU_1;
			else										goto CMD_POWER_ERROR;
		}
		else if(CMD_Compare(pArgv[2], "cin"))	// Input Current
		{
			posData.mode = 2;

			if(argc != 5)								goto CMD_POWER_ERROR;

			if(CMD_Compare(pArgv[3], "vm0"))			posData.position = PWR_VM_0;
			else if(CMD_Compare(pArgv[3], "vm1"))		posData.position = PWR_VM_1;
			else if(CMD_Compare(pArgv[3], "vm2"))		posData.position = PWR_VM_2;
			else if(CMD_Compare(pArgv[3], "vm3"))		posData.position = PWR_VM_3;
			else if(CMD_Compare(pArgv[3], "vm4"))		posData.position = PWR_VM_4;
			else if(CMD_Compare(pArgv[3], "vm5"))		posData.position = PWR_VM_5;
			else if(CMD_Compare(pArgv[3], "vsp"))
			{
				posData.position	= PWR_VSPN;
				posData.channel		= 0;
			}
			else if(CMD_Compare(pArgv[3], "vsn"))
			{
				posData.position	= PWR_VSPN;
				posData.channel		= 1;
			}
			else if(CMD_Compare(pArgv[3], "blu0_0"))
			{
				posData.position	= PWR_BLU_0;
				posData.channel		= 0;
			}
			else if(CMD_Compare(pArgv[3], "blu0_1"))
			{
				posData.position	= PWR_BLU_0;
				posData.channel		= 1;
			}
			else if(CMD_Compare(pArgv[3], "blu0_2"))
			{
				posData.position	= PWR_BLU_0;
				posData.channel		= 2;
			}
			else if(CMD_Compare(pArgv[3], "blu0_3"))
			{
				posData.position	= PWR_BLU_0;
				posData.channel		= 3;
			}
			else if(CMD_Compare(pArgv[3], "blu1_0"))
			{
				posData.position	= PWR_BLU_1;
				posData.channel		= 0;
			}
			else if(CMD_Compare(pArgv[3], "blu1_1"))
			{
				posData.position	= PWR_BLU_1;
				posData.channel		= 1;
			}
			else if(CMD_Compare(pArgv[3], "blu1_2"))
			{
				posData.position	= PWR_BLU_1;
				posData.channel		= 2;
			}
			else if(CMD_Compare(pArgv[3], "blu1_3"))
			{
				posData.position	= PWR_BLU_1;
				posData.channel		= 3;
			}
			else										goto CMD_POWER_ERROR;

			posData.range = CMD_StrToUL(pArgv[4]);
		}
		else											goto CMD_POWER_ERROR;

		chkr = PWR_GetCalGainOffeset(&posData, &gain, &offset);

		if(chkr == 0)									goto CMD_POWER_ERROR;

		CMD_Printf(";GAIN=%f, OFFSET=%f", gain, offset);

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "vspn.voltclr"))
	{
		CMD_Printf(";VSPN.VOLTCLR");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_VspnVoltageClear();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "vspn.voltctrl"))
	{
		u8 pulseCnt, rtn;
		double voltage;
		
		CMD_Printf(";VSPN.VOLTCLR");

		if(argc != 3)		goto CMD_POWER_ERROR;

		voltage = CMD_AToF(pArgv[2]);

		rtn = PWR_VspnVoltageConverter(voltage, &pulseCnt);

		if(rtn == 0)		goto CMD_POWER_ERROR;

		chkr = PWR_VspnVoltageControl(pulseCnt);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "over.enable"))
	{
		CMD_Printf(";OVER.ENABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

//		chkr = PWR_OverPowerEnable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "over.disable"))
	{
		CMD_Printf(";OVER.DISABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_OverPowerDisable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "vmtype"))
	{
		u8	channel, type;

		CMD_Printf(";VMTYPE");

		if(argc != 4)		goto CMD_POWER_ERROR;

		channel = CMD_StrToUL(pArgv[2]);

		if(channel < 3)		goto CMD_POWER_ERROR;
		if(channel > 5)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[3], "normal") || CMD_Compare(pArgv[3], "12v1a5"))
		{
			type = VM_TYPE_NORMAL;
		}
		else if(CMD_Compare(pArgv[3], "12v3a"))
		{
			type = VM_TYPE_12V_3A;
		}
		else if(CMD_Compare(pArgv[3], "-10v3a"))
		{
			type = VM_TYPE_N10V_3A;
		}
		else if(CMD_Compare(pArgv[3], "10v5a"))
		{
			type = VM_TYPE_10V_5A;
		}
		else				goto CMD_POWER_ERROR;

		chkr = PWR_VoutModuleType(channel, type);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "vmcheck"))
	{
		u8	channel, type;

		CMD_Printf(";VMCHECK");

		if(argc != 3)		goto CMD_POWER_ERROR;

		channel = CMD_StrToUL(pArgv[2]);

		if(channel < 3)		goto CMD_POWER_ERROR;
		if(channel > 5)		goto CMD_POWER_ERROR;

		chkr = PWR_VoutModuleCheck(channel, &type);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		CMD_SerialTxOneTimeEnable();

		switch(type)
		{
			case VM_TYPE_NORMAL:
				CMD_Printf(";TYPE_12V1A5");
				break;

			case VM_TYPE_12V_3A:
				CMD_Printf(";TYPE_12V3A");
				break;

			case VM_TYPE_N10V_3A:
				CMD_Printf(";TYPE_-10V3A");
				break;

			case VM_TYPE_10V_5A:
				CMD_Printf(";TYPE_10V5A");
				break;

			default:
				goto CMD_POWER_ERROR;
				break;
		}
	}
	else if(CMD_Compare(pArgv[1], "vmres.set"))
	{
		u8	data;

		CMD_Printf(";VMRES.SET");

		if(argc != 3)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "normal"))
		{
			data = 0;
		}
		else if(CMD_Compare(pArgv[2], "fixed"))
		{
			data = 1;
		}
		else				goto CMD_POWER_ERROR;

		chkr = PWR_VoutModuleResType(data);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "vmres.check"))
	{
		u8	data;

		CMD_Printf(";VMRES.CHECK");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_VoutModuleResCheck(&data);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		if(data == 0)		CMD_Printf(";NORMAL");
		else if(data == 1)	CMD_Printf(";FIXED");
		else				CMD_Printf(";NOTHING");

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "blu.type"))
	{
		u8	position, data;

		CMD_Printf(";BLU.TYPE");

		if(argc != 4)		goto CMD_POWER_ERROR;

		position = CMD_StrToUL(pArgv[2]);
		if(position > 1)	goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[3], "normal"))			data = 0;
		else if(CMD_Compare(pArgv[3], "custom1"))	data = 1;
		else				goto CMD_POWER_ERROR;

		chkr = PWR_BluModuleType(position, data);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "blu.check"))
	{
		u8	position, data;

		CMD_Printf(";BLU.CHECK");

		if(argc != 3)		goto CMD_POWER_ERROR;

		position = CMD_StrToUL(pArgv[2]);
		if(position > 1)	goto CMD_POWER_ERROR;

		chkr = PWR_BluModuleCheck(position, &data);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		if(data == 0)		CMD_Printf(";NORMAL");
		else if(data == 1)	CMD_Printf(";CUSTOM1");
		else				CMD_Printf(";NOTHING");

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "over.check"))
	{
		u16	voltageCnt[6], currentCnt[6];

		CMD_Printf(";OVER.CHECK");

		if(argc != 2)		goto CMD_POWER_ERROR;

//		chkr = PWR_OverPowerCheck(voltageCnt, currentCnt);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < 6; cnt++)
		{
			CMD_Printf(";VM%d V=%d I=%d", cnt, voltageCnt[cnt], currentCnt[cnt]);
		}

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "over.status"))
	{
		u8	vmStatus[6], sum = 0;

		CMD_Printf(";OVER.STATUS");

		if(argc != 2)		goto CMD_POWER_ERROR;

//		chkr = PWR_OverPowerRead(vmStatus);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		for(u8 cnt = 0; cnt < 6; cnt++)
		{
			if(vmStatus[cnt] == VM_OP_VOLTAGE)			CMD_Printf(";VM%d_OVER_VOLTAGE", cnt);
			else if(vmStatus[cnt] == VM_OP_CURRENT)		CMD_Printf(";VM%d_OVER_CURRENT", cnt);

			sum |= vmStatus[cnt];
		}

		if(sum == 0)									CMD_Printf(";VM_OVER_VOLTAGE_CURRENT_NONE");

		CMD_SerialTxOneTimeEnable();
	}
	else if(CMD_Compare(pArgv[1], "led.enable"))
	{
		CMD_Printf(";LED.ENABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_LedEnable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "led.disable"))
	{
		CMD_Printf(";LED.DISABLE");

		if(argc != 2)		goto CMD_POWER_ERROR;

		chkr = PWR_LedDisable();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "factor.set"))
	{
		u8	position, type;
		float	fData;

		CMD_Printf(";FACTOR.SET");

		if(argc != 5)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = 0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = 1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = 2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = 3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = 4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = 5;
		else				goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[3], "vfb"))			type = 0;
		else if(CMD_Compare(pArgv[3], "ovr1"))		type = 1;
		else if(CMD_Compare(pArgv[3], "ovr2"))		type = 2;
		else if(CMD_Compare(pArgv[3], "ovr3"))		type = 3;
		else if(CMD_Compare(pArgv[3], "mvr1"))		type = 4;
		else if(CMD_Compare(pArgv[3], "mvr2"))		type = 5;
		else if(CMD_Compare(pArgv[3], "mir1"))		type = 6;
		else if(CMD_Compare(pArgv[3], "mir2"))		type = 7;
		else if(CMD_Compare(pArgv[3], "rds"))		type = 8;
		else if(CMD_Compare(pArgv[3], "shunt1"))	type = 9;
		else if(CMD_Compare(pArgv[3], "shunt2"))	type = 10;
		else if(CMD_Compare(pArgv[3], "shunt3"))	type = 11;

		fData		= CMD_AToF(pArgv[4]);

		chkr = PWR_FConfigSetData(position, type, fData);

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "factor.get"))
	{
		u8	position, type;
		float	fData;

		CMD_Printf(";FACTOR.GET");

		if(argc != 4)		goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[2], "vm0"))			position = 0;
		else if(CMD_Compare(pArgv[2], "vm1"))		position = 1;
		else if(CMD_Compare(pArgv[2], "vm2"))		position = 2;
		else if(CMD_Compare(pArgv[2], "vm3"))		position = 3;
		else if(CMD_Compare(pArgv[2], "vm4"))		position = 4;
		else if(CMD_Compare(pArgv[2], "vm5"))		position = 5;
		else				goto CMD_POWER_ERROR;

		if(CMD_Compare(pArgv[3], "vfb"))			type = 0;
		else if(CMD_Compare(pArgv[3], "ovr1"))		type = 1;
		else if(CMD_Compare(pArgv[3], "ovr2"))		type = 2;
		else if(CMD_Compare(pArgv[3], "ovr3"))		type = 3;
		else if(CMD_Compare(pArgv[3], "mvr1"))		type = 4;
		else if(CMD_Compare(pArgv[3], "mvr2"))		type = 5;
		else if(CMD_Compare(pArgv[3], "mir1"))		type = 6;
		else if(CMD_Compare(pArgv[3], "mir2"))		type = 7;
		else if(CMD_Compare(pArgv[3], "rds"))		type = 8;
		else if(CMD_Compare(pArgv[3], "shunt1"))	type = 9;
		else if(CMD_Compare(pArgv[3], "shunt2"))	type = 10;
		else if(CMD_Compare(pArgv[3], "shunt3"))	type = 11;
		else				goto CMD_POWER_ERROR;

		chkr = PWR_FConfigGetData(position, type, &fData);

		if(chkr == 0)		goto CMD_POWER_ERROR;

		CMD_Printf(";%f", fData);
	}
	else if(CMD_Compare(pArgv[1], "factor.save"))
	{
		CMD_Printf(";FACTOR.SAVE");

		chkr = PWR_FConfigSaveData();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "factor.clear"))
	{
		CMD_Printf(";FACTOR.CLEAR");

		chkr = PWR_FConfigClearData();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
	else if(CMD_Compare(pArgv[1], "factor.load"))
	{
		CMD_Printf(";FACTOR.LOAD");

		chkr = PWR_FConfigLoadData();

		if(chkr == 0)		goto CMD_POWER_ERROR;
	}
#endif
	else
	{
		CMD_POWER_ERROR:
		result = 0;
	}

	if(result)	CMD_Printf(";OK");
	else		CMD_Printf(";ERROR");

	return result;
}

