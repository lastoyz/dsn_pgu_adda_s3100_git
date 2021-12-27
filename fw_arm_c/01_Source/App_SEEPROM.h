/*
 * <SEEPROM.H>
 * stub routine for serial eeprom
 *
 *   Programmed by Baek Wangki
 * 	 2002.4.18
 */

#ifndef SEEPROM_H
#define SEEPROM_H

#include 	"top_core_info.h"


// 2015.12.10 hong
//	#include "systype.h"
//	#include "OsTimer.h"
//	#include "smu.h"
//	#include "measure.h"
//	#include "spidrv.h"
//////

/* instruction set for sesial EEPROM AT25XXX */
//	#define WREN    0x06      
//	#define WRDI    0x04                                                 
//	#define RDSR    0x05                                             
//	#define WRSR    0x01       
//	#define READ    0x03      
//	#define WRITE   0x02     
const uint8_t WREN = 0x06;
const uint8_t WRDI = 0x04;                                                 
const uint8_t RDSR = 0x05;                                             
const uint8_t WRSR = 0x01;       
const uint8_t READ = 0x03;      
const uint8_t WRITE = 0x02;     


#ifdef __cplusplus
    extern "C" {
#endif

/* spi routines for serial eeprom */
void smu_seeprom_on(int ch);
void gndu_seeprom_on(void);
void seeprom_cs_on(void);
void seeprom_cs_off(void);
void seeprom_off(void);

////E5000 Ãß°¡ (2020.02.18_À±»óÈÆ)
//void io_output_cs_init();
//void io_output1_cs_on();
//void io_output2_cs_on();
//void io_output3_cs_on();
//void io_sequence(int ch);
//void io_output1_cs_off();
//void io_output2_cs_off();
//void io_output3_cs_off();


void spi_write_byte(short int addr, char data);
uint8_t spi_read_byte(short int addr);
//	void spi_write_short(short first_addr, short data);
void spi_write_long(short first_addr, long data);
void spi_write_float(short first_addr, float data);
//	short spi_read_short(short first_addr);
long spi_read_long(short first_addr);
float spi_read_float(short first_addr);
//	void spi_write_buffer(short first_addr, char *buffer, int count);
//	void spi_read_buffer(short first_addr, char *buffer,int count);
//	void spi_write_string(short first_addr, char *string);
//	void spi_read_string(short first_addr, char *string);

//	// 2015.12.10 hong
//	class ISpiRomDev
//	{
//	public:
//	    virtual ~ISpiRomDev() {}
//	
//	    virtual void PROM_CSOn(int dev) = 0;
//	    virtual void PROM_CSOff(int dev) = 0;
//	    virtual void PROM_SendByte(int dev, char data) = 0;
//	    virtual char PROM_ReceiveByte(int dev) = 0;
//	};
//	
//	class CSpiRom
//	{
//	public:
//	    ISpiRomDev *m_pRomDev;
//	
//	    CSpiRom() { m_pRomDev = 0; }
//	    void Create(ISpiRomDev *pRom) { m_pRomDev = pRom; }
//	    
//	    void seeprom_cs_on(int dev) { m_pRomDev->PROM_CSOn(dev); }
//	    void seeprom_cs_off(int dev) { m_pRomDev->PROM_CSOff(dev); }
//		void seeprom_send_byte(int dev, char data) { spi_send_byte(data); } //m_pRomDev->PROM_SendByte(dev, data); }
//	    char seeprom_receive_byte(int dev) { return spi_receive_byte(); } //return m_pRomDev->PROM_ReceiveByte(dev); }
//	
//	    void  seeprom_write_byte  (int dev, short addr, char data);
//	    char  seeprom_read_byte   (int dev, short addr);
//	    void  seeprom_write_short (int dev, short first_addr, short data);
//	    void  seeprom_write_long  (int dev, short first_addr, long data);
//	    void  seeprom_write_float (int dev, short first_addr, float data);
//	    short seeprom_read_short  (int dev, short first_addr);
//	    long  seeprom_read_long   (int dev, short first_addr);
//	    float seeprom_read_float  (int dev, short first_addr);
//	    void  seeprom_write_buffer(int dev, short first_addr, char *buffer, int count);
//	    void  seeprom_read_buffer (int dev, short first_addr, char *buffer, int count);
//	    void  seeprom_write_string(int dev, short first_addr, char *string, int max);
//	    void  seeprom_read_string (int dev, short first_addr, char *string, int max);
//	};
/////////

//	
//	void seeprom_cs_on(int dev);
//	void seeprom_cs_off(int dev);
//	void seeprom_send_byte(int dev, char data);
//	char seeprom_receive_byte(int dev);
//	
//	void  seeprom_write_byte  (int dev, short addr, char data);
//	char  seeprom_read_byte   (int dev, short addr);
//	void  seeprom_write_short (int dev, short first_addr, short data);
//	void  seeprom_write_long  (int dev, short first_addr, long data);
//	void  seeprom_write_float (int dev, short first_addr, float data);
//	short seeprom_read_short  (int dev, short first_addr);
//	long  seeprom_read_long   (int dev, short first_addr);
//	float seeprom_read_float  (int dev, short first_addr);
//	void  seeprom_write_buffer(int dev, short first_addr, char *buffer, int count);
//	void  seeprom_read_buffer (int dev, short first_addr, char *buffer, int count);
//	void  seeprom_write_string(int dev, short first_addr, char *string, int max);
//	void  seeprom_read_string (int dev, short first_addr, char *string, int max);






#ifdef __cplusplus
    }
#endif

#endif /* #ifndef SEEPROM_H */

