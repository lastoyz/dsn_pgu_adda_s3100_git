#include "APP_SEEPROM.h"


//#include "stdafx.h"
//	#include <stdio.h>
//	
//	#include "systype.h"
//	#include "OsTimer.h"
//	#include "smu.h"
//	#include "measure.h"
//	#include "spidrv.h"
//	
//	#include "seeprom.h"


static int board;


void smu_seeprom_on(int ch)
{
	#if 0

	io_eeprom_sequence(ch);
	ConfigSSP_GPIO();
    board = ch;

	#endif

	board = ch;
}


// 20070713
void gndu_seeprom_on(void)
{
	#if 0
	ConfigSSP_GPIO();
	board = NO_OF_SMU;
	#endif

	board = NO_OF_SMU;
}


void seeprom_cs_on(void)
{
  if (board < NO_OF_SMU) 
 {
	smu_seeprom_cs_on(board);
 }
  else
  {
	  gndu_seeprom_cs_on();
  }
//  spi_cs_on();
}



void seeprom_cs_off(void)
{
//  spi_cs_off();
	smu_seeprom_cs_off();
    gndu_seeprom_cs_off();
}



void seeprom_off(void)
{
//   spi_cs_off();
	smu_seeprom_cs_off();
    gndu_seeprom_cs_off();
	
//	    spi_disable();
}

void spi_write_byte(short addr, char data)
{
    uint8_t high_addr = (uint8_t)(addr >> 8);
	uint8_t low_addr  = (uint8_t)addr;

    
//		spi_init();
//		spi_enable();

    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    seeprom_cs_on();
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&WREN, 1, 100);
	//spi_send_byte(WREN);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
	seeprom_cs_off();

	//Delay_ms(2);
	Delay_us(100);
	
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    seeprom_cs_on();
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&WRITE, 1, 100);
	Delay_us(100);
	//spi_send_byte(WRITE);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&high_addr, 1, 100);
	Delay_us(100);
	//spi_send_byte(high_addr);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&low_addr, 1, 100);
	Delay_us(100);
	//spi_send_byte(low_addr);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
   	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&data, 1, 100);
	Delay_us(100);
    //spi_send_byte(data);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
    seeprom_cs_off();
  
    Delay_ms(10); // Delay 없으면 다음 번 write가 제대로 안된다
    
}



uint8_t spi_read_byte(short addr)
{
    volatile uint8_t receive;
    uint8_t high_addr=(uint8_t)(addr>>8);
	uint8_t low_addr=(uint8_t)addr;

    //printf("+spi_read_byte() \n");
    //ConfigSSP_GPIO();

//		spi_init();
//		spi_enable();

    //spi_flush();

    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
	seeprom_cs_on();
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&READ, 1, 100);
    //spi_send_byte(READ);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
	HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&high_addr, 1, 100);
	//spi_send_byte(high_addr);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
    HAL_SPI_Transmit(fpgaSPI, (uint8_t *)&low_addr, 1, 100);
    //spi_send_byte(low_addr);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("SSDR_1 is 0x%x\n", *SSDR_1);
	HAL_SPI_Receive(fpgaSPI, (uint8_t *)&receive, 1, 100);
	//receive=spi_receive_byte();
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("+++SSDR_1 is  0x%x\n", *SSDR_1);
    //printf("SSSR_1 is 0x%x\n", *SSSR_1);
    //printf("+++SSDR_1 is  0x%x\n", *SSDR_1);
    seeprom_cs_off();
	
    //Delay_ms(2);

    return receive;
}





 //	// not used
//	void spi_write_short(short first_addr, short data)
//	{
//		short second_addr=first_addr+1;
//		short a=data;
//		char *p=(char *)(&a);
//		char data_byte1=*p++;
//		char data_byte2=*p++;
//		spi_write_byte(first_addr,data_byte1);
//		spi_write_byte(second_addr,data_byte2);
//	    
//	}
//	
void spi_write_long(short first_addr, long data)
{
	short second_addr = first_addr+1;
    short third_addr  = first_addr+2;
    short fourth_addr = first_addr+3;
	long a = data;
	char *p = (char *)(&a);
	char data_byte1 = *p;
    char data_byte2 = *(p+1);
    char data_byte3 = *(p+2);
	char data_byte4 = *(p+3);
	
    spi_write_byte(first_addr, data_byte1);
    spi_write_byte(second_addr, data_byte2);
    spi_write_byte(third_addr, data_byte3);
    spi_write_byte(fourth_addr, data_byte4);
}
	
//
void spi_write_float(short first_addr, float data)
{
    //printf("# data : %f\n" , data);
    short second_addr=first_addr+1;
    short third_addr=first_addr+2;
    short fourth_addr=first_addr+3;
	float a=data;
    char *p=(char *)(&a);
	    
	char data_byte1=*p;
    char data_byte2=*(p+1);
    char data_byte3=*(p+2);
    char data_byte4=*(p+3);
	
    spi_write_byte(first_addr,data_byte1);
    spi_write_byte(second_addr,data_byte2);
    spi_write_byte(third_addr,data_byte3);
    spi_write_byte(fourth_addr,data_byte4);
}
//	
//	// not used
//	short spi_read_short(short first_addr)
//	{
//		char *p;
//		short receive;
//		short second_addr=first_addr+1;
//		char data_byte1, data_byte2;
//		
//		data_byte1=spi_read_byte(first_addr);
//		data_byte2=spi_read_byte(second_addr);
//		
//		p = (char *)(&receive);
//		*p=data_byte1;
//		*(p+1)=data_byte2;
//	
//	    return receive;
//	}
//	
long spi_read_long(short first_addr)
{
    //printf("# spi_read_long\n");
	char *p;
	long  receive;
    short second_addr=first_addr+1;
    short third_addr=first_addr+2;
    short fourth_addr=first_addr+3;
    char data_byte1,data_byte2,data_byte3,data_byte4;
	
    data_byte1=spi_read_byte(first_addr);
    //printf("# first_addr : 0x%p, 0x%X\n",  &first_addr, first_addr);
	data_byte2=spi_read_byte(second_addr);
    //printf("# second_addr : 0x%p, 0x%X\n",  &second_addr, second_addr);
    data_byte3=spi_read_byte(third_addr);
    //printf("# third_addr : 0x%p, 0x%X\n",  &third_addr, third_addr);
	data_byte4=spi_read_byte(fourth_addr);
    //printf("# fourth_addr : 0x%p, 0x%X\n",  &fourth_addr, fourth_addr);
	p=(char *)(&receive);
	*p=data_byte1;
	*(p+1)=data_byte2;                              
    *(p+2)=data_byte3;
    *(p+3)=data_byte4;
	
    //printf("# receive : 0x%X\n" , receive);
	return receive;
}
	
float spi_read_float(short first_addr)
{
	char *p;
	float receive;
    short second_addr=first_addr+1;
    short third_addr=first_addr+2;
    short fourth_addr=first_addr+3;
    char data_byte1,data_byte2,data_byte3,data_byte4;
    data_byte1=spi_read_byte(first_addr);
	data_byte2=spi_read_byte(second_addr);
    data_byte3=spi_read_byte(third_addr);
	data_byte4=spi_read_byte(fourth_addr);
    p=(char *)(&receive);
	*p=data_byte1;
	*(p+1)=data_byte2;
	*(p+2)=data_byte3;
	*(p+3)=data_byte4;
	
	return receive;
}
//	
//	// not used
//	void spi_write_buffer(short first_addr, char *buffer, int count)
//	{
//		int i;
//		for(i=0;i<count;i++)
//		{
//			spi_write_byte(first_addr++,*buffer++);
//		}
//	}
//	
//	// not used
//	void spi_read_buffer(short first_addr, char *buffer,int count)
//	{
//		int i;
//		for(i=0;i<count;i++)
//		{
//			buffer[i]=spi_read_byte(first_addr++);
//		}
//	}
//	
//	// not used
//	void spi_write_string(short first_addr, char *string)
//	{
//		do{
//			spi_write_byte(first_addr++,*string);
//		}while(*string++!='\0');
//	}
//	
//	// not used
//	void spi_read_string(short first_addr, char *string)
//	{
//		int i=0;
//		do{
//			string[i]=spi_read_byte(first_addr++);
//		}while(string[i++]!='\0');
//	}
//	
//	////////////////////////////////////////
//	// 2015.12.10 추가
//	void CSpiRom::seeprom_write_byte(int dev, short addr, char data)
//	{
//		  char high_addr = (char)(addr >> 8);
//		  char low_addr  = (char) addr;
//	
//		  spi_init();
//		  spi_enable();
//	
//	       seeprom_cs_on(dev);
//		  seeprom_send_byte(dev, WREN);
//		  seeprom_cs_off(dev);	  
//	
//		  OstDelay_us(10000);
//		  //Delay_mSec(2);
//		
//		   seeprom_cs_on(dev);
//		  seeprom_send_byte(dev, WRITE);
//	    seeprom_send_byte(dev, high_addr);
//	    seeprom_send_byte(dev, low_addr);
//	    seeprom_send_byte(dev, data);
//	    seeprom_cs_off(dev);
//	    
//		  OstDelay_us(10000);
//	    //Delay_mSec(10);
//		  spi_disable();
//		  //printf("seeprom_write_byte\n");
//	}
//	
//	char CSpiRom::seeprom_read_byte(int dev, short addr)
//	{
//		  char receive;
//	    char high_addr = (char)(addr>>8);
//		  char low_addr  = (char) addr;
//	
//		  spi_init();
//		  spi_enable();
//	
//		 seeprom_cs_on(dev);
//	    seeprom_send_byte(dev, READ);
//	    seeprom_send_byte(dev, high_addr);
//	    seeprom_send_byte(dev, low_addr);
//		  receive = seeprom_receive_byte(dev);
//	    seeprom_cs_off(dev);
//		
//		  //printf("seeprom_read_byte. rec = %s\n", receive);
//		  spi_disable();
//	    return receive;	
//	}
//	
//	// not used
//	void CSpiRom::seeprom_write_short(int dev, short first_addr, short data)
//	{
//		  short second_addr = first_addr+1;
//		  short a = data;
//		  char *p = (char *)(&a);
//		  char data_byte1 = *p++;
//		  char data_byte2 = *p++;
//		
//	    seeprom_write_byte(dev, first_addr,  data_byte1);
//		  seeprom_write_byte(dev, second_addr, data_byte2);
//	}
//	
//	// not used
//	void CSpiRom::seeprom_write_long(int dev, short first_addr, long data)
//	{
//		  short second_addr = first_addr+1;
//	    short third_addr  = first_addr+2;
//	    short fourth_addr = first_addr+3;
//		  long  a = data;
//		  char *p = (char *)(&a);
//		  char data_byte1 = *p;
//	    char data_byte2 = *(p+1);
//	    char data_byte3 = *(p+2);
//		  char data_byte4 = *(p+3);
//	
//	    seeprom_write_byte(dev, first_addr,  data_byte1);
//	    seeprom_write_byte(dev, second_addr, data_byte2);
//	    seeprom_write_byte(dev, third_addr,  data_byte3);
//	    seeprom_write_byte(dev, fourth_addr, data_byte4);
//	}
//	
//	// not used
//	void CSpiRom::seeprom_write_float(int dev, short first_addr, float data)
//	{
//	    short second_addr = first_addr+1;
//	    short third_addr  = first_addr+2;
//	    short fourth_addr = first_addr+3;
//		  float a = data;
//	    char *p = (char *)(&a);
//		    
//		  char data_byte1 = *p;
//	    char data_byte2 = *(p+1);
//	    char data_byte3 = *(p+2);
//	    char data_byte4 = *(p+3);
//	
//	    seeprom_write_byte(dev, first_addr,  data_byte1);
//	    seeprom_write_byte(dev, second_addr, data_byte2);
//	    seeprom_write_byte(dev, third_addr,  data_byte3);
//	    seeprom_write_byte(dev, fourth_addr, data_byte4);
//	}
//	
//	// not used
//	short CSpiRom::seeprom_read_short(int dev, short first_addr)
//	{
//		  char *p;
//		  short receive;
//		  short second_addr = first_addr+1;
//		  char data_byte1, data_byte2;
//	  	
//		  data_byte1 = seeprom_read_byte(dev, first_addr);
//		  data_byte2 = seeprom_read_byte(dev, second_addr);
//	  	
//		  p = (char *)(&receive);
//		  *p = data_byte1;
//		  *(p+1) = data_byte2;
//	
//	    return receive;
//	}
//	
//	// not used
//	long CSpiRom::seeprom_read_long(int dev, short first_addr)
//	{
//		  char *p;
//		  long  receive;
//	    short second_addr = first_addr+1;
//	    short third_addr  = first_addr+2;
//	    short fourth_addr = first_addr+3;
//	    char data_byte1, data_byte2, data_byte3, data_byte4;
//	    
//	    data_byte1 = seeprom_read_byte(dev, first_addr);
//		  data_byte2 = seeprom_read_byte(dev, second_addr);
//	    data_byte3 = seeprom_read_byte(dev, third_addr);
//		  data_byte4 = seeprom_read_byte(dev, fourth_addr);
//		
//	    p = (char *)(&receive);
//		  *p = data_byte1;
//		  *(p+1) = data_byte2;
//	    *(p+2) = data_byte3;
//	    *(p+3) = data_byte4;
//		
//	    return receive;
//	}
//	
//	// not used
//	float CSpiRom::seeprom_read_float(int dev, short first_addr)
//	{
//		  char *p;
//		  float receive;
//	    short second_addr = first_addr+1;
//	    short third_addr  = first_addr+2;
//	    short fourth_addr = first_addr+3;
//	    char data_byte1, data_byte2, data_byte3, data_byte4;
//	
//	    data_byte1 = seeprom_read_byte(dev, first_addr);
//		  data_byte2 = seeprom_read_byte(dev, second_addr);
//	    data_byte3 = seeprom_read_byte(dev, third_addr);
//	  	data_byte4 = seeprom_read_byte(dev, fourth_addr);
//	    
//	    p = (char *)(&receive);
//		  *p = data_byte1;
//		  *(p+1) = data_byte2;
//		  *(p+2) = data_byte3;
//		  *(p+3) = data_byte4;
//		
//		  //printf("seeprom_read_float, receive = %f \n", receive);
//		  return receive;
//	}
//	
//	// not used
//	void CSpiRom::seeprom_write_buffer(int dev, short first_addr, char *buffer, int count)
//	{
//		  int i;
//		
//	    for(i=0; i<count; i++)
//		  {
//			  seeprom_write_byte(dev, first_addr++, *buffer++);
//		  }
//	}
//	
//	// not used
//	void CSpiRom::seeprom_read_buffer(int dev, short first_addr, char *buffer,int count)
//	{
//		  int i;
//		
//	    for(i=0; i<count; i++)
//		  {
//			  buffer[i] = seeprom_read_byte(dev, first_addr++);
//		  }
//	}
//	
//	// not used
//	void CSpiRom::seeprom_write_string(int dev, short first_addr, char *string, int max)
//	{
//		  int i;
//	    
//	    for (i=0; i<max; i++)
//	    {
//	      seeprom_write_byte(dev, first_addr++, string[i]);
//	      if (string[i] == 0) break;
//	    }
//	}
//	
//	// not used
//	void CSpiRom::seeprom_read_string(int dev, short first_addr, char *string, int max)
//	{
//		  int i;
//		
//	    for (i=0; i<max; i++)
//	    {
//	      string[i] = seeprom_read_byte(dev, first_addr++);
//	      if (string[i] == 0) break;
//	    }
//	    string[i] = 0;
//	}



