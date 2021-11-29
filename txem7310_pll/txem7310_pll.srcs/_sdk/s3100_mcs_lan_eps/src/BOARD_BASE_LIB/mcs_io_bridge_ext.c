//#include "xparameters.h"
//#include "xil_cache.h"

#include "microblaze_sleep.h"
#include "xil_printf.h" // print() for pure string; xil_printf() for formatted string

#include "ioLibrary/Ethernet/W5500/w5500.h" // for w5500 io functions

#include "mcs_io_bridge_ext.h" //$$ board dependent // also call __PGU_CPU_CONFIG_H_


// common subfunctions //{
u32 hexchr2data_u32(u8 hexchr) {
	// '0' -->  0
	// 'A' --> 10
	u32 val;
	s32 val_L;
	s32 val_H;
	//
	val_L = (s32)hexchr - (s32)'0';
	//if ((val_L>=0)&&(val_L<10)) {
	if (val_L<10) {
		val = (u32)val_L;
	}
	else {
		val_H = (s32)hexchr - (s32)'A';
		//if ((val_H>=0)&&(val_H<6)) {
		//	val = (u32)val_H+10;
		// }
		//else {
		//	val = (u32)(-1); // no hex code.
		// }
		val = (u32)val_H+10;
		//
		if (val>15) {
			val += (s32)'A' - (s32)'a';
		}
	}
	//
	return val; 
}

u32 hexstr2data_u32(u8* hexstr, u32 len) {
	u32 val;
	u32 loc;
	u32 ii;
	loc = 0;
	val = 0;
	for (ii=0;ii<len;ii++) {
		val = (val<<4) + hexchr2data_u32(hexstr[loc++]);
	}
	return val;
}

u32 decchr2data_u32(u8 decchr) {
	// '0' -->  0
	u32 val;
	s32 val_t;
	//
	val_t = (s32)decchr - (s32)'0';
	if (val_t<10) {
		val = (u32)val_t;
	}
	else {
		val = (u32)(-1); // no valid code.
	}
	//
	return val; 
}

u32 decstr2data_u32(u8* decstr, u32 len) {
	u32 val;
	u32 loc;
	u32 ii;
	loc = 0;
	val = 0;
	for (ii=0;ii<len;ii++) {
		val = (val*10) + decchr2data_u32(decstr[loc++]);
	}
	return val;
}

u32 is_dec_char(u8 chr) { // 0 for dec; -1 for not
	u32 ret;
	ret = decchr2data_u32(chr);
	if (ret != -1)  ret = 0;
	return ret;
}

void mcopy(void *dest, const void *src, size_t n) { //$$ rename memcpy --> mcopy
	u32 ii;
	for (ii=0;ii<n;ii++) {
		*((u8*)dest) = *((u8*)src);
		dest++;
		src++;
	}	
}

//}


// subfunctions for pipe //{

void dcopy_pipe8_to_buf8  (u32 adrs_p8, u8 *p_buf_u8, u32 len) {
	u32 ii;
	u8 val;
	//
	for (ii=0;ii<len;ii++) {
		val = (u8)XIomodule_In32 (adrs_p8);
		p_buf_u8[ii] = val;
	}
}
	
void dcopy_buf8_to_pipe8  (u8 *p_buf_u8, u32 adrs_p8, u32 len) {
	u32 ii;
	u32 val;
	//
	for (ii=0;ii<len;ii++) {
		val = p_buf_u8[ii]&0x000000FF;
		XIomodule_Out32 (adrs_p8, val);
	}
}

void dcopy_pipe32_to_buf32(u32 adrs_p32, u32 *p_buf_u32, u32 len_byte) { // (src,dst,len)
	u32 ii;
	u32 len;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		p_buf_u32[ii] = XIomodule_In32 (adrs_p32);
	}
}


void dcopy_buf32_to_pipe32(u32 *p_buf_u32, u32 adrs_p32, u32 len_byte) { // (src,dst,len)
	u32 ii;
	u32 val;
	u32 len;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		val = p_buf_u32[ii];
		XIomodule_Out32 (adrs_p32, val);
	}
}

void dcopy_buf8_to_pipe32(u8 *p_buf_u8, u32 adrs_p32, u32 len_byte) { // (src,dst,len_byte)
	u32 ii;
	u32 val;
	//u32 *p_val;
	u8  *p_val_u8;
	u32 len;
	//
	//p_val = (u32*)p_buf_u8; //$$ NG ...  MCS IO mem on buf8 -> buf32 location has some constraint.
	p_val_u8 = (u8*)&val;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		p_val_u8[0] = p_buf_u8[ii*4+0];
		p_val_u8[1] = p_buf_u8[ii*4+1];
		p_val_u8[2] = p_buf_u8[ii*4+2];
		p_val_u8[3] = p_buf_u8[ii*4+3];
		//
		//xil_printf("check: 0x%08X\r\n",(unsigned int)val); //$$ test
		//
		XIomodule_Out32 (adrs_p32, val);
	}
}

void dcopy_pipe32_to_pipe32(u32 src_adrs_p32, u32 dst_adrs_p32, u32 len_byte) { // (src,dst,len)
	u32 ii;
	u32 len;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		XIomodule_Out32 (dst_adrs_p32, XIomodule_In32 (src_adrs_p32));
	}
}

void dcopy_pipe8_to_pipe32 (u32 src_adrs_p8,  u32 dst_adrs_p32, u32 len_byte) { // (src,dst,len)
	// src_adrs_p8          dst_adrs_p32
	// {AA},{BB},{CC},{DD}  {DD,CC,BB,AA}   
	u32 ii;
	u32 len;
	u32 val;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		val = 0   +  ((XIomodule_In32 (src_adrs_p8))&0x000000FF)     ;
		val = val + (((XIomodule_In32 (src_adrs_p8))&0x000000FF)<< 8);
		val = val + (((XIomodule_In32 (src_adrs_p8))&0x000000FF)<<16);
		val = val + (((XIomodule_In32 (src_adrs_p8))&0x000000FF)<<24);
		XIomodule_Out32 (dst_adrs_p32, val);
	}
}

void dcopy_pipe32_to_pipe8 (u32 src_adrs_p32, u32 dst_adrs_p8,  u32 len_byte) { // (src,dst,len)
	// src_adrs_p32    dst_adrs_p8
	// {DD,CC,BB,AA}   {AA},{BB},{CC},{DD}
	u32 ii;
	u32 len;
	u32 val;
	//
	len = len_byte>>2;
	for (ii=0;ii<len;ii++) {
		val = XIomodule_In32 (src_adrs_p32);
		XIomodule_Out32 (dst_adrs_p8, (val&0x000000FF));
		val = val >> 8;
		XIomodule_Out32 (dst_adrs_p8, (val&0x000000FF));
		val = val >> 8;
		XIomodule_Out32 (dst_adrs_p8, (val&0x000000FF));
		val = val >> 8;
		XIomodule_Out32 (dst_adrs_p8, (val&0x000000FF));
	}
}

//}



// === MCS io access functions === //{

//// for low-level driver test
u32 _test_read_mcs (char* txt, u32 adrs) {
	u32 value;
	xil_printf(txt);
	value = XIomodule_In32 (adrs);
	xil_printf("mcs rd: 0x%08X @ 0x%08X \r\n", value, adrs);
	return value;
}

u32 _test_write_mcs(char* txt, u32 adrs, u32 value) {
	xil_printf(txt);
	XIomodule_Out32 (adrs, value);
	xil_printf("mcs wr: 0x%08X @ 0x%08X \r\n", value, adrs);
	return value;
}


u32 read_mcs_io (u32 adrs) {
	u32 value = XIomodule_In32 (adrs);
	return value;
}

u32 write_mcs_io(u32 adrs, u32 value) {
	XIomodule_Out32 (adrs, value);
	return value;
}


//}



// === dedicated LAN interface (wiznet 850io) functions === //{

// note : dedicated LAN port masks fixed to full mask in mcs_io_bridge_ext.v

u8 hw_reset__wz850() {
	//u32 adrs;
	u32 value;

	//// trig LAN RESET @  master_spi_wz850
	//xil_printf(">>> trig LAN RESET @  master_spi_wz850: \n\r");
	
	//_test_write_mcs(">>> ADRS_MASK_WO____MHVSU: \r\n", ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	//_test_write_mcs(">>> ADRS_MASK_WO____MHVSU: \r\n", ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	
	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);
	
	// read out trig ouu 
	read_mcs_io (ADRS_LAN_TO_60);		

	// {...,w_LAN_INTn,w_LAN_SSNn,w_LAN_RSTn,w_LAN_valid}
	//_test_read_mcs (">>> ADRS_LAN_WO_20_MHVSU : \r\n", ADRS_LAN_WO_20_MHVSU); 
	//_test_write_mcs(">>> ADRS_LAN_WI_00_MHVSU : \r\n", ADRS_LAN_WI_00_MHVSU, 0x00000001);
	//_test_read_mcs (">>> ADRS_LAN_WO_20_MHVSU : \r\n", ADRS_LAN_WO_20_MHVSU);
	//_test_write_mcs(">>> ADRS_LAN_WI_00_MHVSU : \r\n", ADRS_LAN_WI_00_MHVSU, 0x00000000);
	//_test_read_mcs (">>> ADRS_LAN_WO_20_MHVSU : \r\n", ADRS_LAN_WO_20_MHVSU);
	
	write_mcs_io(ADRS_LAN_WI_00, 0x00000001);
	write_mcs_io(ADRS_LAN_WI_00, 0x00000000);
	
	while (1) {
		//value = _test_read_mcs (">>> ADRS_LAN_WO_20_MHVSU : \r\n", ADRS_LAN_WO_20_MHVSU);
		value = read_mcs_io (ADRS_LAN_WO_20);
		if ((value & 0x03) == 0x03) break;
		usleep(100); // 1us*100 sleep
		}
	//
	return 0;
}

// for  uint8_t  WIZCHIP_READ(uint32_t AddrSel)
u8    read_data__wz850 (u32 AddrSel) {
	u8 ret;
	//u32 adrs;
	u32 value;

	// set up mode
	AddrSel |= (_W5500_SPI_READ_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU
	
	
	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);
	
	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);

	
	//  //
	//  adrs = ADRS_PORT_WI_02; // move to ADRS_LAN_WI_00_MHVSU [31:16]
	//  value = 1;
	//  XIomodule_Out32 (adrs, value);

	value = 1 << 16; // set length to 1 at high 16b

	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //

	//  value = value | 0x00000002; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	//  
	//  
	//  //  adrs = ADRS_PORT_WI_00;
	//  //  value = 0x0000; // ... , trig_frame, trig_reset
	//  //  XIomodule_Out32 (adrs, value);
	//  
	//  value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	
	// TODO: send frame // OK 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	
	
	//
	while (1) {
		//
		// adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		// value = XIomodule_In32 (adrs);
		
		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;
		
		//usleep(100); // 1us*100 sleep
		//
		}
	//

	//// read fifo data
	//   ADRS_LAN_PO_A0_MHVSU
	
	// adrs = ADRS_PORT_PO_A0;
	// value = XIomodule_In32 (adrs);
	// //
	// ret = value & (0x000000ff);
	
	value = read_mcs_io (ADRS_LAN_PO_A0);
	ret   = value & (0x000000FF);
	
	return ret;
}

// for  void WIZCHIP_WRITE(uint32_t AddrSel, uint8_t wb )
void write_data__wz850 (u32 AddrSel, u8 wb) {
	//u32 adrs;
	u32 value;

	// set up mode
	AddrSel |= (_W5500_SPI_WRITE_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);


	//// write fifo data
	//   ADRS_LAN_PI_80_MHVSU
	
	//  adrs = ADRS_PORT_PI_80;
	//  value = 0x000000FF & wb;
	//  XIomodule_Out32 (adrs, value);
	
	value = 0x000000FF & wb;
	write_mcs_io (ADRS_LAN_PI_80, value);

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU

	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);

	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);

	//  //
	//  adrs = ADRS_PORT_WI_02;
	//  value = 1;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0000; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  
	
	value = 1 << 16; // set length to 1 at high 16b
	//  value = value | 0x00000002; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	//  value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	
	// TODO: send frame 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	//
	while (1) {
		//
		//  adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		//  value = XIomodule_In32 (adrs);

		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;

		//usleep(100); // 1us*100 sleep
		//
		}
	//
}

// for  void WIZCHIP_READ_BUF (uint32_t AddrSel, uint8_t* pBuf, uint16_t len)
// read data from LAN-fifo to buffer  // recv
void  read_data_buf__wz850 (u32 AddrSel, u8* pBuf, u16 len) {
	//u32 adrs;
	u32 value;

	// set up mode
	AddrSel |= (_W5500_SPI_READ_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU
	
	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_02;
	//  value = len;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0000; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	
	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);
	
	value = len << 16; // set length to len at high 16b
	//  value = value | 0x00000002; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	//  value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);

	// TODO: send frame 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	//
	while (1) {
		//
		//adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		//value = XIomodule_In32 (adrs);
		//

		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;
		
		//usleep(100); // 1us*100 sleep
		//
		}
	//

	//// read fifo data : dcopy pipe_8b to buf_8b
	//  dcopy_pipe8_to_buf8  (ADRS_PORT_PO_A0, pBuf, len);
	dcopy_pipe8_to_buf8  (ADRS_LAN_PO_A0, pBuf, len);
	
	//
}

// for  void WIZCHIP_WRITE_BUF(uint32_t AddrSel, uint8_t* pBuf, uint16_t len)
// write data from buffer to LAN-fifo // send
void write_data_buf__wz850 (u32 AddrSel, u8* pBuf, u16 len) {
	//u32 adrs;
	u32 value;

	// set up mode
	AddrSel |= (_W5500_SPI_WRITE_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);

	// write buffer data to LAN-fifo : dcopy buf_8b to pipe_8b
	//dcopy_buf8_to_pipe8(pBuf, ADRS_PORT_PI_80, len);
	dcopy_buf8_to_pipe8(pBuf, ADRS_LAN_PI_80, len);

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU

	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_02;
	//  value = len;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0000; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//

	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);
	
	value = len << 16; // set length to len at high 16b
	//  value = value | 0x00000002; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	//  value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);

	// TODO: send frame 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	//
	while (1) {
		//
		//  adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		//  value = XIomodule_In32 (adrs);
		//
		
		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;
		
		//usleep(100); // 1us*100 sleep
		//
		}
	//
}

// FROM w5500.c : WIZCHIP_READ_BUF
// FROM w5500.c : void wiz_recv_data(uint8_t sn, uint8_t *wizdata, uint16_t len)
// FROM socket.c: int32_t recv(uint8_t sn, uint8_t * buf, uint16_t len)
// FROM socket.c: int32_t recvfrom(uint8_t sn, uint8_t * buf, uint16_t len, uint8_t * addr, uint16_t *port)
// ...
// TO    WIZCHIP_READ_PIPE // test
// TO    void wiz_recv_data_pipe(uint8_t sn, uint8_t *wizdata, uint32_t len_u32)
// TO    int32_t recv_pipe(uint8_t sn, uint8_t * buf, uint32_t len_u32)
// TO    int32_t recvfrom_pipe(uint8_t sn, uint8_t * buf, uint32_t len_u32, uint8_t * addr, uint16_t *port)
//
// read data from LAN-fifo to pipe // recv
//void  read_data_pipe__wz850 (u32 AddrSel, u32 ep_offset, u32 len_u32) { // test
void  read_data_pipe__wz850 (u32 AddrSel, u32 dst_adrs_p32, u32 len_u32) { // test
	//u32 adrs;
	u32 value;
	u32 ii;
	//
	u32 len_4byte;
	u32 data_u32;
	u8  *p_data_u8;

	// set up mode
	AddrSel |= (_W5500_SPI_READ_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);

 	// length based on 4 bytes
	len_4byte = len_u32>>2; // len_u32 must be muliple of 4.

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU
	
	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_02;
	//  value = len_u32; //$$
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0000; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	
	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);
	
	value = len_u32 << 16; // set length to len at high 16b //$$
	//  value = value | 0x00000002; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	//  value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	//  write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);

	// TODO: send frame 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	while (1) {
		//
		//adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		//value = XIomodule_In32 (adrs);
		//
		
		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;
		
		//usleep(100); // 1us*100 sleep
		//
		}
	//

	//// read fifo data from LAN to pipe
	//
	// address of pipe end-point //$$ ep_offset --> dst_adrs_p32 
	//adrs = ADRS_BASE_CMU + (ep_offset<<4); // MCS1 //$$
	//
	p_data_u8 = (u8*)&data_u32;
	for (ii=0;ii<len_4byte;ii++) {
		value = XIomodule_In32 (ADRS_LAN_PO_A0); // read data0 from LAN-fifo
		p_data_u8[0] = (u8) (value & 0x00FF);
		//
		value = XIomodule_In32 (ADRS_LAN_PO_A0); // read data1 from LAN-fifo
		p_data_u8[1] = (u8) (value & 0x00FF);
		//
		value = XIomodule_In32 (ADRS_LAN_PO_A0); // read data2 from LAN-fifo
		p_data_u8[2] = (u8) (value & 0x00FF);
		//
		value = XIomodule_In32 (ADRS_LAN_PO_A0); // read data3 from LAN-fifo
		p_data_u8[3] = (u8) (value & 0x00FF);
		//
		//XIomodule_Out32 (adrs, data_u32);// write a 32-bit value to pipe end-point
		XIomodule_Out32 (dst_adrs_p32, data_u32);// write a 32-bit value to pipe end-point
	}
	//
}

// FROM w5500.c : WIZCHIP_WRITE_BUF
// FROM w5500.c : void wiz_send_data(uint8_t sn, uint8_t *wizdata, uint16_t len)
// FROM socket.c: int32_t send(uint8_t sn, uint8_t * buf, uint16_t len)
// FROM socket.c: int32_t sendto(uint8_t sn, uint8_t * buf, uint16_t len, uint8_t * addr, uint16_t port)
// ...
// TO    WIZCHIP_WRITE_PIPE // test
// TO    void wiz_send_data_pipe(uint8_t sn, uint8_t *wizdata, uint32_t len_u32)
// TO    int32_t send_pipe(uint8_t sn, uint8_t * buf, uint32_t len_u32)
// TO    int32_t sendto_pipe(uint8_t sn, uint8_t * buf, uint32_t len_u32, uint8_t * addr, uint16_t port)
//
// write data from pipe to LAN-fifo // send
void write_data_pipe__wz850 (u32 AddrSel, u32 src_adrs_p32, u32 len_u32) {
	//u32 adrs;
	u32 value;
	u32 ii;
	//
	u32 len_4byte;
	u32 data_u32;
	u8  *p_data_u8;

	// set up LAN spi mode
	AddrSel |= (_W5500_SPI_WRITE_ | _W5500_SPI_VDM_OP_);

	// TODO: initialize mask
	// write_mcs_io (ADRS_MASK_WO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_WI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TI____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_TO____MHVSU, 0xFFFFFFFF);
	// write_mcs_io (ADRS_MASK_ALL___MHVSU, 0xFFFFFFFF);

	// address of pipe end-point //$$ ep_offset --> src_adrs_p32
	//adrs = ADRS_BASE_CMU + (ep_offset<<4); // MCS1

 	// length based on 4 bytes
	len_4byte = len_u32>>2; // len_u32 must be muliple of 4.

	// note that 32 bits from pipe-out and 8 bits into LAN-fifo
	// need to send 4 bytes byte-by-byte ...
	p_data_u8 = (u8*)&data_u32;
	for (ii=0;ii<len_4byte;ii++) {
		//// read from data pipe such as adc pipe
		data_u32 = XIomodule_In32 (src_adrs_p32); // read a 32-bit value from pipe end-point
		//...
		//// write the value to LAN pipe end-point
		// send data in the order of ... p_data_u8[0], p_data_u8[1], p_data_u8[2], p_data_u8[3]
		value = 0x000000FF & p_data_u8[0];
		XIomodule_Out32 (ADRS_LAN_PI_80, value); // write data0 to LAN-fifo
		//
		value = 0x000000FF & p_data_u8[1];
		XIomodule_Out32 (ADRS_LAN_PI_80, value); // write data1 to LAN-fifo
		//
		value = 0x000000FF & p_data_u8[2];
		XIomodule_Out32 (ADRS_LAN_PI_80, value); // write data2 to LAN-fifo
		//
		value = 0x000000FF & p_data_u8[3];
		XIomodule_Out32 (ADRS_LAN_PI_80, value); // write data3 to LAN-fifo

	}

	//// set up frame
	//   ADRS_LAN_WI_00_MHVSU
	//   ADRS_LAN_WI_01_MHVSU
	//   ADRS_LAN_WO_20_MHVSU

	//  adrs = ADRS_PORT_WI_01;
	//  value = AddrSel&0x00FFFFFF;
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_02;
	//  value = len_u32; //$$
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0002; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	//  adrs = ADRS_PORT_WI_00;
	//  value = 0x0000; // ... , trig_frame, trig_reset
	//  XIomodule_Out32 (adrs, value);
	//  //
	
	value = AddrSel&0x00FFFFFF;
	write_mcs_io (ADRS_LAN_WI_01, value);
	
	value = len_u32 << 16; // set length to len at high 16b //$$
	// value = value | 0x00000002; // ... , trig_frame, trig_reset
	// write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);
	// value = value & 0xFFFFFFFD; // ... , trig_frame, trig_reset
	// write_mcs_io (ADRS_LAN_WI_00_MHVSU, value);	

	// TODO: send frame 
	write_mcs_io (ADRS_LAN_WI_00, value); // set data count at high 16b
	write_mcs_io (ADRS_LAN_TI_40, 0x00000002); // trig frame
	
	while (1) {
		//  //
		//  adrs = ADRS_PORT_WO_20; // {...,w_done_SPI_frame,w_LAN_INTn,w_LAN_SCSn,w_LAN_RSTn,w_done_LAN_reset}
		//  value = XIomodule_In32 (adrs);
		//  //
		
		// TODO: frame done 
		// value = read_mcs_io (ADRS_LAN_WO_20);
		// if ((value & 0x10) == 0x10) break;
		value = read_mcs_io (ADRS_LAN_TO_60);		
		if ((value & 0x00000002) == 0x00000002) break;
		
		//usleep(100); // 1us*100 sleep
		//
		}
	//
}

//}



// === MCS-EP access functions === //{

// * EP common subfunctions : //{
// note that mask should be careful... MCS and LAN as well...

// note for EXT-CMU and EXT-PGU as well
//   BRD_CON
//   wi03 // ADRS_PORT_WI_03 --> ADRS__BRD_CON_WI
//
//   bit[0]=HW_reset
//   bit[1]=rst_adc  
//   bit[2]=rst_dwave
//   bit[3]=rst_bias 
//   bit[4]=rst_spo  
//   ...
//   bit[8]=mcs_ep_po_en
//   bit[9]=mcs_ep_pi_en
//   bit[10]=mcs_ep_to_en
//   bit[11]=mcs_ep_ti_en
//   bit[12]=mcs_ep_wo_en
//   bit[13]=mcs_ep_wi_en
//   ...
//   bit[16]=time_stamp_disp_en


void  enable_mcs_ep() {
	//adrs = ADRS_PORT_WI_10;
	//value = 0x0000003F;
	//XIomodule_Out32 (adrs, value);
	//XIomodule_Out32 (ADRS_MASK_WI,    0x0000003F); // write mask
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x0000003F); // write MCS0 
	//XIomodule_Out32 (ADRS_MASK_WI,      MASK_ALL); // reset mask
	
	XIomodule_Out32 (ADRS_MASK_WI___, (0x3F<<8) ); // write mask
	XIomodule_Out32 (ADRS__BRD_CON_WI, (0x3F<<8) ); // 
	XIomodule_Out32 (ADRS_MASK_WI___,   MASK_ALL); // reset mask
}

void disable_mcs_ep() {
	//adrs = ADRS_PORT_WI_10;
	//value = 0x00000000;
	//XIomodule_Out32 (adrs, value);
	//XIomodule_Out32 (ADRS_MASK_WI,    0x0000003F); // write mask
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x00000000); // write MCS0 // TODO: remove
	//XIomodule_Out32 (ADRS_MASK_WI,      MASK_ALL); // reset mask

	XIomodule_Out32 (ADRS_MASK_WI___, (0x3F<<8) ); // write mask
	XIomodule_Out32 (ADRS__BRD_CON_WI, 0x00000000); // 
	XIomodule_Out32 (ADRS_MASK_WI___,   MASK_ALL); // reset mask
}

void  reset_mcs_ep() { //$$ to revise name
	//XIomodule_Out32 (ADRS_MASK_WI,    0x00010000); // write mask
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x00010000); // write MCS0
	//usleep(100);
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x00000000); // write MCS0
	//XIomodule_Out32 (ADRS_MASK_WI,      MASK_ALL); // reset mask

	//  HW_reset
	XIomodule_Out32 (ADRS_MASK_WI___, (0x01<<0) ); // write mask
	XIomodule_Out32 (ADRS__BRD_CON_WI, (0x01<<0) ); // 
	usleep(100);
	XIomodule_Out32 (ADRS__BRD_CON_WI, 0x00000000); // 
	XIomodule_Out32 (ADRS_MASK_WI___,   MASK_ALL); // reset mask
}

void  reset_io_dev() {
	// adc / dwave / bias / spo
	//XIomodule_Out32 (ADRS_MASK_WI,    0x001E0000); // write mask
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x001E0000); // write MCS0
	//usleep(100);
	//XIomodule_Out32 (ADRS_PORT_WI_10, 0x00000000); // write MCS0
	//XIomodule_Out32 (ADRS_MASK_WI,      MASK_ALL); // reset mask

	//  rst_adc rst_dwave rst_bias rst_spo
	XIomodule_Out32 (ADRS_MASK_WI___, (0x0F<<1) ); // write mask
	XIomodule_Out32 (ADRS__BRD_CON_WI, (0x0F<<1) ); // 
	usleep(100);
	XIomodule_Out32 (ADRS__BRD_CON_WI, 0x00000000); // 
	XIomodule_Out32 (ADRS_MASK_WI___,   MASK_ALL); // reset mask
}


u32 is_enabled_mcs_ep() {
	u32 val;
	u32 ret;
	XIomodule_Out32 (ADRS_MASK_ALL__,   MASK_ALL); // reset mask
	val = XIomodule_In32 (ADRS__BRD_CON_WI); // assume MASK_ALL
	if ((val&(0x3F<<8))==(0x3F<<8)) {
		ret = 1;
	}
	else ret = 0;
	return ret;

}

//}

// * EP io-mask subfunctions : //{

u32  read_mcs_ep_wi_mask(u32 adrs_base) {
	//return XIomodule_In32 (ADRS_MASK_WI____CMU);
	return XIomodule_In32 (adrs_base + ADRS_MASK_WI____OFST);
}

u32 write_mcs_ep_wi_mask(u32 adrs_base, u32 mask) {
	//XIomodule_Out32 (ADRS_MASK_WI____CMU, mask); // mask 
	XIomodule_Out32 (adrs_base + ADRS_MASK_WI____OFST, mask); // mask 
	return mask;
}

u32  read_mcs_ep_wo_mask(u32 adrs_base) {
	//return XIomodule_In32 (ADRS_MASK_WO____CMU);
	return XIomodule_In32 (adrs_base + ADRS_MASK_WO____OFST);
}

u32 write_mcs_ep_wo_mask(u32 adrs_base, u32 mask) {
	//XIomodule_Out32 (ADRS_MASK_WO____CMU, mask); // mask 
	XIomodule_Out32 (adrs_base + ADRS_MASK_WO____OFST, mask); // mask 
	return mask;
}

u32  read_mcs_ep_ti_mask(u32 adrs_base) {
	//return XIomodule_In32 (ADRS_MASK_TI____CMU);
	return XIomodule_In32 (adrs_base + ADRS_MASK_TI____OFST);
}

u32 write_mcs_ep_ti_mask(u32 adrs_base, u32 mask) {
	//XIomodule_Out32 (ADRS_MASK_TI____CMU, mask); // mask 
	XIomodule_Out32 (adrs_base + ADRS_MASK_TI____OFST, mask); // mask 
	return mask;
}

u32  read_mcs_ep_to_mask(u32 adrs_base) {
	//return XIomodule_In32 (ADRS_MASK_TO____CMU);
	return XIomodule_In32 (adrs_base + ADRS_MASK_TO____OFST);
}

u32 write_mcs_ep_to_mask(u32 adrs_base, u32 mask) {
	//XIomodule_Out32 (ADRS_MASK_TO____CMU, mask); // mask 
	XIomodule_Out32 (adrs_base + ADRS_MASK_TO____OFST, mask); // mask 
	return mask;
}


u32  read_mcs_ep_xx_data(u32 adrs_base, u32 offset) {
	u32 adrs;
	u32 value;
	//adrs = ADRS_BASE_CMU + (offset<<4); // MCS1
	adrs = adrs_base + (offset<<4); // MCS1
	value = XIomodule_In32 (adrs);
	return value;	
}

u32 write_mcs_ep_xx_data(u32 adrs_base, u32 offset, u32 data) {
	u32 adrs;
	//adrs = ADRS_BASE_CMU + (offset<<4); // MCS1
	adrs = adrs_base + (offset<<4); // MCS1
	XIomodule_Out32 (adrs, data);
	return data;
}


u32  read_mcs_ep_wi_data(u32 adrs_base, u32 offset) {
	return read_mcs_ep_xx_data(adrs_base, offset);
}

u32 write_mcs_ep_wi_data(u32 adrs_base, u32 offset, u32 data) {
	return write_mcs_ep_xx_data(adrs_base, offset, data);
}

u32  read_mcs_ep_wo_data(u32 adrs_base, u32 offset) {
	return read_mcs_ep_xx_data(adrs_base, offset);
}

// u32 write_mcs_ep_wo_data(u32 offset, u32 data) // NA

u32  read_mcs_ep_ti_data(u32 adrs_base, u32 offset) {
	return read_mcs_ep_xx_data(adrs_base, offset);
}

u32 write_mcs_ep_ti_data(u32 adrs_base, u32 offset, u32 data) {
	return write_mcs_ep_xx_data(adrs_base, offset, data);
}

u32  read_mcs_ep_to_data(u32 adrs_base, u32 offset) {
	return read_mcs_ep_xx_data(adrs_base, offset);
}

// u32 write_mcs_ep_to_data(u32 offset, u32 data) // NA


//// PIPE-DATA direct

// u32  read_mcs_ep_pi_data() // NA

u32 write_mcs_ep_pi_data(u32 adrs_base, u32 offset, u32 data) { // OK
	return write_mcs_ep_xx_data(adrs_base, offset, data);
}

u32  read_mcs_ep_po_data(u32 adrs_base, u32 offset) { // OK
	return read_mcs_ep_xx_data(adrs_base, offset);
}

// u32 write_mcs_ep_po_data() // NA

//}

// * EP functions : //{

u32   read_mcs_ep_wi(u32 adrs_base, u32 offset) {
	return read_mcs_ep_wi_data(adrs_base, offset);
}

void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask) {
	write_mcs_ep_wi_mask(adrs_base, mask);
	write_mcs_ep_wi_data(adrs_base, offset, data);
}

u32   read_mcs_ep_wo(u32 adrs_base, u32 offset, u32 mask) {
	write_mcs_ep_wo_mask(adrs_base, mask);
	return read_mcs_ep_wo_data(adrs_base, offset);
}

u32   read_mcs_ep_ti(u32 adrs_base, u32 offset) {
	return read_mcs_ep_ti_data(adrs_base, offset);
}

void write_mcs_ep_ti(u32 adrs_base, u32 offset, u32 data, u32 mask) {
	write_mcs_ep_ti_mask(adrs_base, mask);
	write_mcs_ep_ti_data(adrs_base, offset, data);
}

void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc) { 
	u32 value;
	value = 0x00000001 << bit_loc;
	write_mcs_ep_ti(adrs_base, offset, value, value);
}

u32   read_mcs_ep_to(u32 adrs_base, u32 offset, u32 mask) {
	write_mcs_ep_to_mask(adrs_base, mask);
	return read_mcs_ep_to_data(adrs_base, offset);
}

u32 is_triggered_mcs_ep_to(u32 adrs_base, u32 offset, u32 mask) {
	u32 ret;
	u32 value;
	//
	value = read_mcs_ep_to(adrs_base, offset, mask);
	if (value==0) ret = 0;
	else ret = 1;
	return ret;
}


//// PIPE-DATA in buffer 

// write data from buffer to pipe-in 
u32 write_mcs_ep_pi_buf(u32 adrs_base, u32 offset, u32 len_byte, u8 *p_data) {
	u32 adrs;
	//
	//adrs = ADRS_BASE_CMU + (offset<<4); // MCS1
	adrs = adrs_base + (offset<<4); // MCS1
	dcopy_buf32_to_pipe32((u32*)p_data, adrs, len_byte);
	//
	return (len_byte&0xFFFFFFFC);
}

// read data from pipe-out to buffer 
u32  read_mcs_ep_po_buf(u32 adrs_base, u32 offset, u32 len_byte, u8 *p_data) { 
	u32 adrs;
	//
	//adrs = ADRS_BASE_CMU + (offset<<4); // MCS1
	adrs = adrs_base + (offset<<4); // MCS1
	dcopy_pipe32_to_buf32(adrs, (u32*)p_data, len_byte);
	//
	return (len_byte&0xFFFFFFFC);
}


//// PIPE-DATA in fifo 

// write data from fifo to pipe-in 
// u32 write_mcs_ep_pi_fifo(u32 offset, u32 len_byte, u8 *p_data) { // test
// 	return 0;
// }

// read data from pipe-out to fifo 
// u32  read_mcs_ep_po_fifo(u32 offset, u32 len_byte, u8 *p_data) { // test
// 	return 0;
// }

//}

//}


// NOTE: legacy compatible functions ... CPP class to come
//
//  GetWireOutValue
//  UpdateWireOuts 
//  SetWireInValue
//  UpdateWireIns // dummy
//  ActivateTriggerIn // ActivateTriggerIn(int epAddr, int bit)
//  UpdateTriggerOuts // not much // dummy
//  IsTriggered // not much // IsTriggered(int epAddr, UINT32 mask)
//  ReadFromPipeOut
//  WriteToPipeIn // not much
//  // https://library.opalkelly.com/library/FrontPanelAPI/classokCFrontPanel-members.html


// === TODO: common functions === //{

// pgu_read_fpga_image_id() --> read_fpga_image_id()
u32  read_fpga_image_id() {
	u32 fpga_image_id;
	fpga_image_id = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__FPGA_IMAGE_ID_WO, MASK_ALL);
	return fpga_image_id;	
}

// pgu_read_fpga_temperature() --> read_fpga_temperature()
u32  read_fpga_temperature() {
	u32 mon_fpga_temp_mC;
	mon_fpga_temp_mC =  read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__XADC_TEMP_WO, MASK_ALL);
	return mon_fpga_temp_mC;	
}


//}


// === TODO: EEPROM access functions === //{
	

u32  eeprom_send_frame_ep (u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32) {
//  def eeprom_send_frame_ep (MEM_WI, MEM_FDAT_WI):
//  	## //// end-point map :
//  	## // wire [31:0] w_MEM_WI      = ep13wire;
//  	## // wire [31:0] w_MEM_FDAT_WI = ep12wire;
//  	## // wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;
//  	## // wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;
//  	## // wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr; 
//  	## // wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; 	

#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_send_frame_ep  \r\n");
#endif
	u32 ret;
	u32 cnt_loop;
	
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__MEM_WI, MEM_WI_b32, 0xFFFFFFFF); // adrs_base, EP_offset_EP, data, mask
#ifdef _EEPROM_DEBUG_
	xil_printf("write_mcs_ep_wi: 0x%08X @ 0x%02X \r\n", MEM_WI_b32, EP_ADRS__MEM_WI);
#endif

	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__MEM_FDAT_WI, MEM_FDAT_WI_b32, 0xFFFFFFFF); // adrs_base, EP_offset_EP, data, mask
#ifdef _EEPROM_DEBUG_
	xil_printf("write_mcs_ep_wi: 0x%08X @ 0x%02X \r\n", MEM_FDAT_WI_b32, EP_ADRS__MEM_FDAT_WI);
#endif

	//  	# clear TO
	ret = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS__MEM_TO, 0xFFFFFFFF);
#ifdef _EEPROM_DEBUG_
	xil_printf("read_mcs_ep_to: 0x%08X @ 0x%02X \r\n", ret, EP_ADRS__MEM_TO);
#endif

	//  	# act TI
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__MEM_TI, 2);
#ifdef _EEPROM_DEBUG_
	xil_printf("activate_mcs_ep_ti: loc %d @ 0x%02X \r\n", 2, EP_ADRS__MEM_TI);
#endif

	cnt_loop = 0;
	while (1) {
		ret = is_triggered_mcs_ep_to(MCS_EP_BASE, EP_ADRS__MEM_TO, 0x04);
		if (ret==1) {
#ifdef _EEPROM_DEBUG_
			xil_printf("is_triggered_mcs_ep_to: 0x%08X @ 0x%02X \r\n", ret, EP_ADRS__MEM_TO);
#endif
			break;
		}
		cnt_loop += 1;
	}
#ifdef _EEPROM_DEBUG_
	xil_printf("cnt_loop = %d \r\n", cnt_loop);
#endif

	return 0;
}

// global variables for eeprom
static u8 g_EEPROM__LAN_access = 1;
static u8 g_EEPROM__on_TP      = 1;
static u8 g_EEPROM__buf_2KB[2048];

u32 eeprom_set_g_var (u8 EEPROM__LAN_access, u8 EEPROM__on_TP) {
//  def eeprom_set_g_var (EEPROM__LAN_access=1, EEPROM__on_TP=1):
//  	print('\n>>>>>> eeprom_set_g_var')
//  	global g_EEPROM__LAN_access
//  	global g_EEPROM__on_TP
//  	#
//  	g_EEPROM__LAN_access = EEPROM__LAN_access
//  	g_EEPROM__on_TP      = EEPROM__on_TP
//  	#
//  	return
	u32 ret;
	//
	g_EEPROM__LAN_access = EEPROM__LAN_access;
	g_EEPROM__on_TP      = EEPROM__on_TP     ;
	//
	
	// update wire wi11 //$$ MCS_SETUP_WI wi11 --> wi19  EP_ADRS__MCS_SETUP_WI
	// bit [9] = w_con_port__L_MEM_SIO__H_TP    // set from MCS
	// bit [8] = w_con_fifo_path__L_sspi_H_lan  // set from MCS
	ret = (g_EEPROM__LAN_access<<8) + (g_EEPROM__on_TP<<9);
	//write_mcs_ep_wi(MCS_EP_BASE, 0x11, ret, 0x00000300); // adrs_base, EP_offset, data, mask
	//write_mcs_ep_wi(MCS_EP_BASE, 0x19, ret, 0x00000300); // adrs_base, EP_offset, data, mask
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__MCS_SETUP_WI, ret, 0x00000300); // adrs_base, EP_offset, data, mask
	
	//
	return ret;
}

u32  eeprom_send_frame (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8) {
//  def eeprom_send_frame (CMD=0x05, STA_in=0, ADL=0, ADH=0, num_bytes_DAT=1, con_disable_SBP=0):
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_send_frame  \r\n");
#endif
	u32 ret;

//  	## 
//  	#num_bytes_DAT               = 1
//  	#con_disable_SBP             = 0
//  	
//  	con_fifo_path__L_sspi_H_lan = 1 # LAN access
//  	#con_fifo_path__L_sspi_H_lan = 0 # slave spi access
//	u32 con_fifo_path__L_sspi_H_lan = g_EEPROM__LAN_access; // moved to MCS_EP_BASE
//  
//  	con_port__L_MEM_SIO__H_TP   = 1 # test TP	
//  	#con_port__L_MEM_SIO__H_TP   = 0 # test MEM_SIO
//	u32 con_port__L_MEM_SIO__H_TP = g_EEPROM__on_TP; // moved to MCS_EP_BASE
//  	
//  	#
//  	set_data_WI = (con_port__L_MEM_SIO__H_TP<<17) + (con_fifo_path__L_sspi_H_lan<<16) + (con_disable_SBP<<15) + num_bytes_DAT
//	u32 set_data_WI = (con_port__L_MEM_SIO__H_TP<<17) + (con_fifo_path__L_sspi_H_lan<<16) + ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
	u32 set_data_WI = ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
//  	
//  	frame_data_CMD     = CMD    ## 0x05
//  	frame_data_STA_in  = STA_in ## 0x00
//  	frame_data_ADL     = ADL    ## 0x00
//  	frame_data_ADH     = ADH    ## 0x00
//  	#
//  	set_data_FDAT_WI = (frame_data_ADH<<24) + (frame_data_ADL<<16) + (frame_data_STA_in<<8) + frame_data_CMD
	u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
//  	
//  	ret = eeprom_send_frame_ep (MEM_WI=set_data_WI, MEM_FDAT_WI=set_data_FDAT_WI)
	ret = eeprom_send_frame_ep (set_data_WI, set_data_FDAT_WI);
//  	#
//  	return ret

	return ret;
}

void eeprom_write_enable() {
//  def eeprom_write_enable():
//  	print('\n>>>>>> eeprom_write_enable')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_enable  \r\n");
#endif
//  	#
//  	## // CMD_WREN__96 
//  	print('\n>>> CMD_WREN__96')
//  	eeprom_send_frame (CMD=0x96, con_disable_SBP=1)
	eeprom_send_frame (0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
}

void eeprom_write_disable() {
//  def eeprom_write_disable():
//  	print('\n>>>>>> eeprom_write_disable')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_disable  \r\n");
#endif
//  	#
//  	## // CMD_WRDI__91 
//  	print('\n>>> CMD_WRDI__91')
//  	eeprom_send_frame (CMD=0x91)
	eeprom_send_frame (0x91, 0, 0, 0, 1, 0); // (CMD=0x91)
}

u32 eeprom_read_status() {
//  def eeprom_read_status():
//  	print('\n>>>>>> eeprom_read_status')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_read_status  \r\n");
#endif
	u32 ret;
	
//  	## // CMD_RDSR__05 
//  	print('\n>>> CMD_RDSR__05')
//  	eeprom_send_frame (CMD=0x05) 
	eeprom_send_frame (0x05, 0, 0, 0, 1, 0); //
//  
//  	# clear TO 
//  	dev.UpdateTriggerOuts()
//  	ret=dev.GetTriggerOutVector(0x73)
	ret = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS__MEM_TO, 0xFFFFFFFF);
//  	print('{} = 0x{:08X}'.format('ret', ret))
//  
//  	# read again TO 
//  	dev.UpdateTriggerOuts()
//  	ret=dev.GetTriggerOutVector(0x73)
	ret = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS__MEM_TO, 0xFFFFFFFF);
//  	print('{} = 0x{:08X}'.format('ret', ret))
//  	
//  	MUST_ZEROS = (ret>>12)&0x0F
//  	
//  	BP1 = (ret>>11)&0x01
//  	BP0 = (ret>>10)&0x01
//  	WEL = (ret>> 9)&0x01
//  	WIP = (ret>> 8)&0x01
	ret = (ret>> 8)&0xFF;
//  	
//  	#
//  	return [BP1, BP0, WEL, WIP, MUST_ZEROS]
	return ret;
}

void eeprom_write_status (u8 BP1_b8, u8 BP0_b8) {
//  def eeprom_write_status(BP1, BP0):
//  	print('\n>>>>>> eeprom_write_status')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_status  \r\n");
#endif
//  	## // CMD_WREN__96 
//  	#print('\n>>> CMD_WREN__96')
//  	#eeprom_send_frame (CMD=0x96)
//  	eeprom_write_enable()
	eeprom_write_enable();
//  	
//  	##
//  	STA_in = (BP1<<3) + (BP0<<2)
	u8 STA_in_b8 = (BP1_b8<<3) + (BP0_b8<<2);
//  	
//  	## // CMD_WRSR__6E
//  	print('\n>>> CMD_WRSR__6E')
//  	eeprom_send_frame (CMD=0x6E, STA_in=STA_in)
	eeprom_send_frame (0x6E, STA_in_b8, 0, 0, 1, 0);
//  	
//  	#
//  	return None
}

u32 is_eeprom_available() {
//  def is_eeprom_available():
//  	print('\n>>>>>> is_eeprom_available')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> is_eeprom_available  \r\n");
#endif
	//  	ret = 1
	u32 ret = 1;
	u32 val;
//  	
//  	## initialize by sending stand-by pulse 
//  	eeprom_write_disable() # SBP
	eeprom_write_disable();
//  	#
//  	[BP1, BP0, WEL, WIP, _] = eeprom_read_status()
	val = eeprom_read_status();
//  	print('{}={}'.format('WEL',WEL))
//  	#
//  	if WEL==0:
//  		ret = ret*1
//  	else:
//  		ret = ret*0
	if ((val&0x02)==0x00) {
		ret = ret*1;
	}
	else {
		ret = ret*0;
	}
//  	
//  	## 
//  	eeprom_write_enable() ## No SBP
	eeprom_write_enable();
//  	#
//  	[BP1, BP0, WEL, WIP, _] = eeprom_read_status()
	val = eeprom_read_status();
//  	print('{}={}'.format('WEL',WEL))
//  	#
//  	if WEL==1:
//  		ret = ret*1
//  	else:
//  		ret = ret*0
	if ((val&0x02)==0x02) {
		ret = ret*1;
	}
	else {
		ret = ret*0;
	}
//  		
//  	##
//  	if (ret==1):
//  		return True
//  	else:
//  		return False
	return ret;
}

void eeprom_erase_all() {
//  def eeprom_erase_all():
//  	print('\n>>>>>> eeprom_erase_all')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_erase_all  \r\n");
#endif
//  	#
//  	
//  	eeprom_write_enable()
	eeprom_write_enable();
//  	
//  	## // CMD_ERAL__6D
//  	print('\n>>> CMD_ERAL__6D')
//  	eeprom_send_frame (CMD=0x6D)
	eeprom_send_frame (0x6D, 0, 0, 0, 1, 0);
//  
//  	pass
}

void eeprom_set_all() {
//  def eeprom_set_all():
//  	print('\n>>>>>> eeprom_set_all')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_set_all  \r\n");
#endif
///  	#
//  	
//  	eeprom_write_enable()
	eeprom_write_enable();
//  	
//  	## // CMD_SETAL_67
//  	print('\n>>> CMD_SETAL_67')
//  	eeprom_send_frame (CMD=0x67)
	eeprom_send_frame (0x67, 0, 0, 0, 1, 0);
//  
//  	pass
}


void eeprom_reset_fifo() {
//  def eeprom_reset_fifo():
//  	print('\n>>>>>> eeprom_reset_fifo')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_reset_fifo  \r\n");
#endif
//  	
//  	#  // w_MEM_TI
//  	#  assign w_MEM_rst      = w_MEM_TI[0];
//  	#  assign w_MEM_fifo_rst = w_MEM_TI[1];
//  	#  assign w_trig_frame   = w_MEM_TI[2];	
//  	
//  	# act TI 
//  	dev.ActivateTriggerIn(0x53, 1)	## (ep, loc)
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__MEM_TI, 1);
//  	
//  	pass
}

u16 eeprom_read_fifo (u16 num_bytes_DAT_b16, u8 *buf_dataout) {
//  def eeprom_read_fifo(num_data=1):
//  	print('\n>>>>>> eeprom_read_fifo')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_read_fifo  \r\n");
#endif
//  	#
//  	
//  	bytes_in_one_sample = 4 # for 32-bit end-point
//  	num_bytes_from_fifo = num_data * bytes_in_one_sample
//  	print('{} = {}'.format('num_bytes_from_fifo', num_bytes_from_fifo))
//  	
//  	## setup data buffer for fifo data
//  	dataout = bytearray([0] * num_bytes_from_fifo)
//  	
//  	## call api function to read pipeout data
//  	data_count = dev.ReadFromPipeOut(0xB3, dataout)

	// memory copy from 32-bit width pipe to 8-bit width buffer // ADRS_BASE_MHVSU or MCS_EP_BASE
	//dcopy_pipe8_to_buf8 (MCS_EP_BASE + (0xB3<<4), buf_dataout, num_bytes_DAT_b16); // (u32 adrs_p8, u8 *p_buf_u8, u32 len)
	dcopy_pipe8_to_buf8 (ADRS__MEM_PO, buf_dataout, num_bytes_DAT_b16); // (u32 adrs_p8, u8 *p_buf_u8, u32 len)

//  	print('{} : {}'.format('data_count [byte]',data_count))
//  	
//  	##  if data_count<0:
//  	##  	#return
//  	##  	# set test data 
//  	##  	num_data = 40
//  	##  	data_count = num_data * bytes_in_one_sample
//  	##  	data_int_list = [1,2,3, 2, 1, -1 ]
//  	##  	data_bytes_list = [x.to_bytes(bytes_in_one_sample,byteorder='little',signed=True) for x in data_int_list]
//  	##  	print('{} = {}'.format('data_bytes_list', data_bytes_list))
//  	##  	#dataout = b'\x01\x00\x00\x00\x02\x00\x00\x00'
//  	##  	dataout = b''.join(data_bytes_list)
//  	
//  	## convert bytearray to 32-bit data : high 24 bits to be ignored due to 8-bit fifo
//  	data_fifo_int_list = []
//  	for ii in range(0,num_data):
//  		temp_data = int.from_bytes(dataout[ii*bytes_in_one_sample:(ii+1)*bytes_in_one_sample], byteorder='little', signed=True)
//  		data_fifo_int_list += [temp_data&0x000000FF] # mask low 8-bit
//  	
//  	
//  	## print out 
//  	#if __debug__:print('{} = {}'.format('data_fifo_int_list', data_fifo_int_list))
//  	
//  	return data_fifo_int_list

	return num_bytes_DAT_b16;
}

u16 eeprom_write_fifo (u16 num_bytes_DAT_b16, u8 *buf_datain) {
//  def eeprom_write_fifo(datain__int_list=[0]):
//  	print('\n>>>>>> eeprom_write_fifo')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_fifo  \r\n");
#endif
//  	#
//  
//  	## convert 32-bit data to bytearray
//  	bytes_in_one_sample = 4 # for 32-bit end-point
//  	num_data = len(datain__int_list)
//  	num_bytes_to_fifo = num_data * bytes_in_one_sample
//  	datain = bytearray([0] * num_bytes_to_fifo)
//  	
//  	# convert bytes list : high 24 bits to be ignored due to 8-bit fifo
//  	datain__bytes_list = [x.to_bytes(bytes_in_one_sample,byteorder='little',signed=True) for x in datain__int_list]
//  	if __debug__:print('{} = {}'.format('datain__bytes_list', datain__bytes_list[:20]))
//  	
//  	# take out bytearray from list
//  	datain = b''.join(datain__bytes_list) 
//  	if __debug__:print('{} = {}'.format('datain', datain[:20]))
//  	
//  	## call api for pipein
//  	data_count = dev.WriteToPipeIn(0x93, datain)

	// memory copy from 8-bit width buffer to 32-bit width pipe // ADRS_BASE_MHVSU or MCS_EP_BASE
	//dcopy_buf8_to_pipe8  (buf_datain, MCS_EP_BASE + (0x93<<4), num_bytes_DAT_b16); //  (u8 *p_buf_u8, u32 adrs_p8, u32 len)
	dcopy_buf8_to_pipe8  (buf_datain, ADRS__MEM_PI, num_bytes_DAT_b16); //  (u8 *p_buf_u8, u32 adrs_p8, u32 len)
	
//  	
//  	return 
	return num_bytes_DAT_b16;
}

u16 eeprom_read_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout) {
//  def eeprom_read_data(ADRS_b16=0x0000, num_bytes_DAT=1):
//  	print('\n>>>>>> eeprom_read_data')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_read_data  \r\n");
#endif
	u16 ret;
//  	#
//  	
//  	## reset fifo test 
//  	eeprom_reset_fifo()
	eeprom_reset_fifo();
//  
//  	## convert address
//  	ADL = (ADRS_b16>>0)&0x00FF 
//  	ADH = (ADRS_b16>>8)&0x00FF
	u8 ADL = (ADRS_b16>>0)&0x00FF;
	u8 ADH = (ADRS_b16>>8)&0x00FF;
//  	print('{} = 0x{:08X}'.format('ADRS_b16', ADRS_b16))
//  	print('{} = 0x{:04X}'.format('ADH', ADH))
//  	print('{} = 0x{:04X}'.format('ADL', ADL))
//  	
//  	## // CMD_READ__03 
//  	print('\n>>> CMD_READ__03')
//  	eeprom_send_frame (CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT)
	eeprom_send_frame (0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);
//  
//  	## call fifo
//  	ret = eeprom_read_fifo(num_data=num_bytes_DAT)
	ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
//  
//  	#
//  	return ret
	return ret;
}

u16 eeprom_read_data_current (u16 num_bytes_DAT_b16, u8 *buf_dataout) {
//  def eeprom_read_data_current(num_bytes_DAT=1):
//  	print('\n>>>>>> eeprom_read_data_current')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_read_data_current  \r\n");
#endif
	u16 ret;
//  	#
//  	
//  	## reset fifo test 
//  	eeprom_reset_fifo()
	eeprom_reset_fifo();
//  
//  	## // CMD_CRRD__06 
//  	print('\n>>> CMD_CRRD__06')
//  	eeprom_send_frame (CMD=0x06, num_bytes_DAT=num_bytes_DAT)
	eeprom_send_frame (0x06, 0, 0, 0, num_bytes_DAT_b16, 0);
//  
//  	## call fifo
//  	ret = eeprom_read_fifo(num_data=num_bytes_DAT)
	ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
//  	#
//  	return ret
	return ret;
}

u16 eeprom_write_data_16B (u16 ADRS_b16, u16 num_bytes_DAT_b16) {
//  #def eeprom_write_data_16B(ADRS_b16=0x0000, num_bytes_DAT=16, data8b_in=[0]*16) :
//  def eeprom_write_data_16B(ADRS_b16=0x0000, num_bytes_DAT=16) :
//  	print('\n>>>>>> eeprom_write_data_16B')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_data_16B  \r\n");
#endif
//  	
//  	## call fifo 
//  	#eeprom_write_fifo(datain__int_list=data8b_in)
//  	
//  	## write enble
//  	eeprom_write_enable()
	eeprom_write_enable();
//  	
//  	## convert address
//  	ADL = (ADRS_b16>>0)&0x00FF 
//  	ADH = (ADRS_b16>>8)&0x00FF
	u8 ADL = (ADRS_b16>>0)&0x00FF;
	u8 ADH = (ADRS_b16>>8)&0x00FF;
//  	print('{} = 0x{:08X}'.format('ADRS_b16', ADRS_b16))
//  	print('{} = 0x{:04X}'.format('ADH', ADH))
//  	print('{} = 0x{:04X}'.format('ADL', ADL))
//  	
//  	## // CMD_WRITE_6C 
//  	print('\n>>> CMD_WRITE_6C')
//  	eeprom_send_frame (CMD=0x6C, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT, con_disable_SBP=1)
	eeprom_send_frame (0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
//  	pass
	return num_bytes_DAT_b16;
}

u16 eeprom_write_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain) {
//  def eeprom_write_data(ADRS_b16=0x0000, num_bytes_DAT=1, data8b_in=[0]):
//  	print('\n>>>>>> eeprom_write_data')
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_data  \r\n");
#endif
//  
//  	##  The 11XX features a 16-byte page buffer, meaning that
//  	##  up to 16 bytes can be written at one time. To utilize this
//  	##  feature, the master can transmit up to 16 data bytes to
//  	##  the 11XX, which are temporarily stored in the page buffer.
//  	##  After each data byte, the master sends a MAK, indicating
//  	##  whether or not another data byte is to follow. A
//  	##  NoMAK indicates that no more data is to follow, and as
//  	##  such will initiate the internal write cycle.
//  	
//  	## reset fifo test 
//  	eeprom_reset_fifo()
	eeprom_reset_fifo();
//  
//  	if num_bytes_DAT <= 16:
	if (num_bytes_DAT_b16 <= 16) {
//  		eeprom_write_fifo(datain__int_list=data8b_in)
		eeprom_write_fifo (num_bytes_DAT_b16, buf_datain); // (u16 num_bytes_DAT_b16, u8 *buf_datain)
//  		#eeprom_write_data_16B(ADRS_b16=ADRS_b16, num_bytes_DAT=num_bytes_DAT, data8b_in=data8b_in)
//  		eeprom_write_data_16B(ADRS_b16=ADRS_b16, num_bytes_DAT=num_bytes_DAT)
		eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16); // (u16 ADRS_b16, u16 num_bytes_DAT_b16)
		num_bytes_DAT_b16 = 0; // sent all
	}
	else {
//  	else:
//  		## call fifo : 8-bit width, depth 2048
//  		## note buf size 2048 
//  		## note 8-bit --> 32-bit conversion ... 4x loss
//  		## fifo size will be 2048/4=512
//  		#fifo_size = 512; # OK
//  		#fifo_size = 1024; # OK with 2048+56 buf fpga-side
//  		#fifo_size = 1024+512; # OK with 4096+512 buf fpga-side
//  		fifo_size = 2048; # OK with 4096*4+128 buf fpga-side
//  		#eeprom_write_fifo(datain__int_list=data8b_in)
//  		for ii in range(0,num_bytes_DAT,fifo_size):
//  			if __debug__: print('{} = {}'.format('ii', ii))
//  			eeprom_write_fifo(datain__int_list=data8b_in[(ii):(ii+fifo_size)])

		// eeprom fifo depth 2048 ready
		eeprom_write_fifo (num_bytes_DAT_b16, buf_datain); // (u16 num_bytes_DAT_b16, u8 *buf_datain)

//  			
//  		##  16-byte page buffer operation support
//  		for ii in range(0,num_bytes_DAT,16):
//  			#eeprom_write_data_16B(ADRS_b16=ADRS_b16+ii, data8b_in=data8b_in[(ii):(ii+16)])
//  			eeprom_write_data_16B(ADRS_b16=ADRS_b16+ii)
		// split address by 16
		while (1) {
			eeprom_write_data_16B (ADRS_b16, 16); // (u16 ADRS_b16, u16 num_bytes_DAT_b16)
			//
			ADRS_b16          += 16;
			num_bytes_DAT_b16 -= 16;
			//
			if (num_bytes_DAT_b16 <= 16) {
				eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16); // (u16 ADRS_b16, u16 num_bytes_DAT_b16)
				num_bytes_DAT_b16 = 0;
				break;
			}
		}

	}
//  	pass
	return num_bytes_DAT_b16;
}

u8* get_adrs__g_EEPROM__buf_2KB() {
	// xil_printf(">>>>>> get_adrs__g_EEPROM__buf_2KB  \r\n");
	// xil_printf("     g_EEPROM__buf_2KB   : 0x%08X \r\n", g_EEPROM__buf_2KB);
	// xil_printf("    &g_EEPROM__buf_2KB[0]: 0x%08X \r\n", &g_EEPROM__buf_2KB[0]);
	// xil_printf("(u8*)g_EEPROM__buf_2KB   : 0x%08X \r\n", (u8*)g_EEPROM__buf_2KB);
	return (u8*)g_EEPROM__buf_2KB;
}

u16 eeprom_read_all() { // copy eeprom to g_EEPROM__buf_2KB
//  def eeprom_read_all():
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_read_all  \r\n");
#endif
//  	global g_EEPROM__buf_2KB
//  	
//  	g_EEPROM__buf_2KB = eeprom_read_data(ADRS_b16=0x0000, num_bytes_DAT=2048)
	eeprom_read_data (0x0000, 2048, g_EEPROM__buf_2KB); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
//  	
//  	return g_EEPROM__buf_2KB
	return 2048;
}

u16 eeprom_write_all() { // copy eeprom to g_EEPROM__buf_2KB
#ifdef _EEPROM_DEBUG_
	xil_printf(">>>>>> eeprom_write_all  \r\n");
#endif
	eeprom_write_data (0x0000, 2048, g_EEPROM__buf_2KB); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	return 2048;
}


u8 ignore_nonprint_code(u8 ch) {
	if (ch< 0x20 || ch>0x7E)
		ch = '.';
	return ch;
}

void hex_txt_display (s16 len_b16, u8 *p_mem_data, u32 adrs_offset) {
//void hex_txt_display (u8 *p_mem_data, u32 adrs_offset, u8 *buf_txtout) {
//  def hex_txt_display(mem_data__list, offset=0x0000):
//  	# display : every 16 bytes
//  	#print(mem_data_2KB__list)
//  	# 014  0x00E0  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
//  	# 015  0x00F0  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
//  	# 016  0x0100  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
//  	# 017  0x0110  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
//  	# 018  0x0120  FF FF FF FE DC BA FF FF  FF FF FF FF FF FF FF FF  ................	
//  	
//  	mem_data_2KB__list = mem_data__list
//  	adrs_ofs = offset
//  	
//  	num_bytes_in_MEM = len(mem_data_2KB__list)
//  	num_bytes_in_a_display_line = 16
//  	
//  	output_display = ''
//  	for ii in range(0,int(num_bytes_in_MEM/num_bytes_in_a_display_line)):
//  		xx              = mem_data_2KB__list[(ii*16):(ii*16+16)]                                 # load line data
//  		output_display += '{:03d}  '  .format(ii)                                                # line number 
//  		output_display += '0x{:04X}  '.format(ii*16+adrs_ofs)                                             # start address each line
//  		output_display += ''.join([ '{:02X} '.format(jj) for jj in xx[0:8 ] ])                   # hex code 
//  		output_display += ' '
//  		output_display += ''.join([ '{:02X} '.format(jj) for jj in xx[8:16] ])                   # hex code 
//  		output_display += ' '
//  		output_display += ''.join([ chr(jj) if (jj>= 0x20 and jj<=0x7E) else '.' for jj in xx ]) # printable code
//  		output_display += '\n'                                                                   # line feed
//  	#
//  	return output_display
	u32 ii=0;
	while (1) {
		xil_printf("%03d  ",ii);
		xil_printf("0x%04X  ",adrs_offset);
		xil_printf("%02X %02X %02X %02X %02X %02X %02X %02X  ",
			p_mem_data[0],p_mem_data[1],p_mem_data[2],p_mem_data[3],
			p_mem_data[4],p_mem_data[5],p_mem_data[6],p_mem_data[7]);
		xil_printf("%02X %02X %02X %02X %02X %02X %02X %02X  ",
			p_mem_data[8+0],p_mem_data[8+1],p_mem_data[8+2],p_mem_data[8+3],
			p_mem_data[8+4],p_mem_data[8+5],p_mem_data[8+6],p_mem_data[8+7]);
		xil_printf("%c%c%c%c%c%c%c%c %c%c%c%c%c%c%c%c",
			ignore_nonprint_code(p_mem_data[0]  ),ignore_nonprint_code(p_mem_data[1]  ),ignore_nonprint_code(p_mem_data[2]  ),ignore_nonprint_code(p_mem_data[3]  ),
			ignore_nonprint_code(p_mem_data[4]  ),ignore_nonprint_code(p_mem_data[5]  ),ignore_nonprint_code(p_mem_data[6]  ),ignore_nonprint_code(p_mem_data[7]  ),
			ignore_nonprint_code(p_mem_data[8+0]),ignore_nonprint_code(p_mem_data[8+1]),ignore_nonprint_code(p_mem_data[8+2]),ignore_nonprint_code(p_mem_data[8+3]),
			ignore_nonprint_code(p_mem_data[8+4]),ignore_nonprint_code(p_mem_data[8+5]),ignore_nonprint_code(p_mem_data[8+6]),ignore_nonprint_code(p_mem_data[8+7]));
		xil_printf("\r\n");
		//
		ii += 1;
		adrs_offset += 16;
		p_mem_data  += 16;
		len_b16 -= 16;
		//
		if (len_b16<=0) break;
	}

}

u8 cal_checksum (u16 len_b16, u8 *p_data_b8) {
//  def cal_checksum (data_b8_list):
//  	ret = sum(data_b8_list) & 0xFF
//  	return ret
	u8 ret;
	//
	ret = 0;
	while (1) {
		ret     += (*p_data_b8);
		len_b16   -= 1;
		p_data_b8 += 1;
		if (len_b16==0) break;
	}
	//
	return ret;
}

u8 gen_checksum (u16 len_b16, u8 *p_data_b8) {
//  def gen_checksum (data_b8_list):
//  	ret = 0x100 - sum(data_b8_list) & 0xFF
//  	return ret
	u8 ret;
	ret = - cal_checksum (len_b16, p_data_b8);
	return ret; 
}

u8 chk_all_zeros (u16 len_b16, u8 *p_data_b8) {
	u8 ret;
	//
	ret = 1;
	while (1) {
		if ((*p_data_b8)==0x00) 
			ret = ret * 1;
		else 
			ret = ret * 0;
		len_b16   -= 1;
		p_data_b8 += 1;
		if (len_b16==0) break;
	}
	//
	return ret;	// 1 for all zero.
}

//}


// === TODO: S3100-PGU functions === //{
#ifdef _S3100_PGU_


// common //{
	
u32 pgu_test(u32 opt) {
	return opt;
}

u32  pgu_read_fpga_image_id() {
	return read_fpga_image_id();	
}

// pgu_read_fpga_temperature() --> read_fpga_temperature()
u32  pgu_read_fpga_temperature() {
	return read_fpga_temperature();	
}

//}


// SPIO //{

// for master_spi_mcp23s17.v

u32  pgu_spio_send_spi_frame(u32 frame_data) { // EP access
	//dev = lib_ctrl.dev
	//EP_ADRS = conf.OK_EP_ADRS_CONFIG
	//#
	//print('>> {}'.format('Send SPIO frame'))
	//#
	//wi = EP_ADRS['SPIO_WI']
	//wo = EP_ADRS['SPIO_WO']
	//ti = EP_ADRS['SPIO_TI']
	//#
	//#frame_data = (ctrl_b16<<16) + val_b16
	//print('{} = 0x{:08X}'.format('frame_data',frame_data))#
	//#
	//# write control 
	//dev.SetWireInValue(wi,frame_data,0xFFFFFFFF) # (ep,val,mask)
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__SPIO_WI, frame_data, MASK_ALL); // EP_ADRS_PGU__SPIO_WI 
	//dev.UpdateWireIns()
	//#
	//# trig spi frame
	//#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
	//ret = dev.ActivateTriggerIn(ti, 1) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__SPIO_TI, 1); // EP_ADRS_PGU__SPIO_TI
	//#
	//# check spi frame done
	//#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	//while True:
	while (1) {
		//dev.UpdateWireOuts()
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__SPIO_WO, MASK_ALL); // EP_ADRS_PGU__SPIO_WO
		
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//#print('{} = {:#010x}'.format('flag',flag))
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//#  
	//print('{} = {}'.format('cnt_done',cnt_done))#
	//print('{} = {}'.format('flag_done',flag_done))
	//#
	//# read received data 
	//#   assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
	//#   assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
	u32 val_recv = flag & 0x0000FFFF;
	//#
	//print('{} = 0x{:02X}'.format('val_recv',val_recv))#
	//#
	return val_recv;
}

u32  pgu_sp_1_reg_read_b16(u32 reg_adrs_b8) {
	//#
	u32 val_b16 =0;
	//
	u32 CS_id      = 1;
	u32 pin_adrs_A = 0; 
	u32 R_W_bar    = 1;
	u32 reg_adrs_A = reg_adrs_b8;
	//#
	u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
	//#
	return pgu_spio_send_spi_frame(framedata);
}

u32  pgu_sp_1_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
	//#
	u32 CS_id      = 1;
	u32 pin_adrs_A = 0;
	u32 R_W_bar    = 0;
	u32 reg_adrs_A = reg_adrs_b8;
	//#
	u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
	//#
	return pgu_spio_send_spi_frame(framedata);
}


//$$ power control
//   pwr_amp NOT used in PGU-S3000
//   pwr_p5v_dac used in PGU-S3100
//   pwr_n5v_dac used in PGU-S3100
void pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 pwr_p5v_dac, u32 pwr_n5v_dac) {
    // SP1 pin map: in S3100
    //  SP1_GPB7 = AUX_CS_B           // o
    //  SP1_GPB6 = AUX_SCLK           // o
    //  SP1_GPB5 = AUX_MOSI           // o
    //  SP1_GPB4 = AUX_MISO           // i
    //  SP1_GPB3 = USER_LED           // o
    //  SP1_GPB2 = PWR_ANAL_DAC_ON    // o
    //  SP1_GPB1 = PWR_ANAL_ON (ADC)  // o
    //  SP1_GPB0 = PWR_AMP_ON         // o  // reserved // with pwr_amp
    //
    //  SP1_GPA7 = SLOT_ID3_BUF       // i
    //  SP1_GPA6 = SLOT_ID2_BUF       // i
    //  SP1_GPA5 = SLOT_ID1_BUF       // i
    //  SP1_GPA4 = SLOT_ID0_BUF       // i
    //  SP1_GPA3 = NA                 // o
    //  SP1_GPA2 = PWR_AMP_DAC_ON     // o  // 5/-5V dac amp power enable // shared with pwr_amp
    //  SP1_GPA1 = SW_RL_K2           // o
    //  SP1_GPA0 = SW_RL_K1           // o

	//
	u32 dir_read;
	u32 lat_read;
	//
	//# read IO direction 
	//# check IO direction : 0xFFX0 where (SPA,SPB)
	dir_read = pgu_sp_1_reg_read_b16(0x00); // unused
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	
	//# set IO direction for SP1 PB[3:0] - all output
	//# set IO direction for SP1 PA[3:2] - all output // new in S3100-PGU
	//pgu_sp_1_reg_write_b16(0x00, dir_read & 0xFFF0);
	//$$pgu_sp_1_reg_write_b16(0x00, dir_read & 0xF3F0);
	pgu_sp_1_reg_write_b16(0x00, dir_read & 0xF010); //$$ S3100-ADDA
	//# set IO for SP1 PB[3:0]
	u32 val = (lat_read & 0xF3F0) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0) ) | ( (pwr_n5v_dac<<11) + (pwr_p5v_dac<<10));
	pgu_sp_1_reg_write_b16(0x12,val);
}

u32  pgu_spio_ext_pwr_led_readback() {
	//
	u32 lat_read;
	//
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//
	//return lat_read & 0x000F;
	return lat_read & 0xFFFF; // rev
}

//$$ output relay control : added in PGU-S3000
void pgu_spio_ext_relay(u32 sw_rl_k1, u32 sw_rl_k2) {
	//
	u32 dir_read;
	u32 lat_read;
	//
	//# read IO direction 
	//# check IO direction : 0xFFX0 where (SPA,SPB)
	dir_read = pgu_sp_1_reg_read_b16(0x00); // unused
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	
	//# set IO direction for SP1 PA[1:0] - all output
	pgu_sp_1_reg_write_b16(0x00, dir_read & 0xFCFF);
	//# set IO for SP1 PA[1:0]
	u32 val = (lat_read & 0xFCFF) | ( (sw_rl_k2<<9) + (sw_rl_k1<<8) );
	pgu_sp_1_reg_write_b16(0x12,val);
}

u32  pgu_spio_ext_relay_readback() {
	//
	u32 lat_read;
	//
	//# read output Latch // where (SPA,SPB)
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//
	return (lat_read & 0x0300)>>8; //$$ {SW_RL_K2,SW_RL_K1}
}


//// TODO: AUX IO controls on 6-pin connector //{
//
// initialize   : pgu_spio_ext__aux_init() 
// write outputs: pgu_spio_ext__aux_out ()
// read inputs  : pgu_spio_ext__aux_in  ()
//
// bit locations: 
//   AUX_CS_B = GPB[7]
//   AUX_SCLK = GPB[6]
//   AUX_MOSI = GPB[5]
//   AUX_MISO = GPB[4]
//   
//   self check possible 
//   GPIO port address : 0x12
// 

u32 pgu_spio_ext__aux_init() {
	u32 dir_read;
	u32 lat_read;
	
	//  //// set safe IO direction: all inputs
	//  // read previous value
	//  dir_read = pgu_sp_1_reg_read_b16(0x00);
	//  // set GPB[7:4] as inputs for safe
	//  dir_read = dir_read | 0x00F0;
	//  //
	//  pgu_sp_1_reg_write_b16(0x00,dir_read);
	//  //
	//  //dir_read = pgu_sp_1_reg_read_b16(0x00);

	//// set the safe output values:
	//   AUX_CS_B = 1          @ GPB[7]
	//   AUX_SCLK = 0          @ GPB[6]
	//   AUX_MOSI = 0          @ GPB[5]
	//   AUX_MISO = input (0)  @ GPB[4]
	//
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | 0x0080;
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);

	//// setup IO direction : 0xFF1F
	// read previous value
	dir_read = pgu_sp_1_reg_read_b16(0x00);
	// set GPB[7:5] as outputs //$$ set GPA[1:0] GPB[3:0] as outputs
	//dir_read = dir_read & 0xFF1F;
	dir_read = dir_read & 0xFC10;
	// set GPB[4] as input 
	dir_read = dir_read | 0x0010;
	//
	pgu_sp_1_reg_write_b16(0x00,dir_read);
	//
	dir_read = pgu_sp_1_reg_read_b16(0x00);
	
	return dir_read;
}

void pgu_spio_ext__aux_idle() {
	u32 lat_read;
	
	//// set the safe output values:
	//   AUX_CS_B = 1          @ GPB[7]
	//   AUX_SCLK = 0          @ GPB[6]
	//   AUX_MOSI = 0          @ GPB[5]
	//   AUX_MISO = input (0)  @ GPB[4]
	//
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | 0x0080;
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);

}

void pgu_spio_ext__aux_out (u32 val_b4) {
	u32 lat_read;
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | ( (val_b4&0x000F)<<4 );
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);
}

u32 pgu_spio_ext__aux_in () {
	u32 port_read;
	// read gpio
	port_read = pgu_sp_1_reg_read_b16(0x12);
	// find value
	return (port_read & 0x00F0 )>>4;
}


// spi control emulation
u32 pgu_spio_ext__aux_send_spi_frame (u32 R_W_bar, u32 reg_adrs_b8, u32 val_b16) {
	u32 val_recv = 0;
	u32 framedata = 0x00000000;
	u32 f_count;
	u32 val;
	
	// make a frame for MCP23S17T-E/ML
	
	// - SPI frame format: 16 bit long data
	//		<write> 
	//		  o_SPIOx_CS_B -________________________________________________________________---
	//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0___
	//        f_count_high  0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3
	//        f_count_low   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
	//                     
	//		<read>           
	//		  o_SPIOx_CS_B -________________________________________________________________---
	//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-___
	//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0___________________________________
	//		  o_SPIOx_MISO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0~~
	//        f_count_high  0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3
	//        f_count_low   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
	//
	//		control bits      : C[7:0]
	//			C7 0
	//			C6 1
	//			C5 0
	//			C4 0
	//			C3 HW_A2
	//			C2 HW_A1
	//			C1 HW_A0
	//			C0 R_W_bar
	//		address bits      : A[7:0]
	//		data bits for GPA : D[7:0]
	//		data bits for GPB : E[7:0]

	// C = 0x40 or 0x41
	// A = reg_adrs_b8
	// D = val_b16 // {GPA,GPB}
	
	if (R_W_bar==0) {
		framedata = (0x40<<24) | (reg_adrs_b8<<16) | val_b16;
	}
	else {
		framedata = (0x41<<24) | (reg_adrs_b8<<16) | val_b16;
	}
	//
	
	// generate a frame
	// ...
	//// frame start
	// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 1,0,0,0
	pgu_spio_ext__aux_out(0x8);
	
	for (f_count=0;f_count<33;f_count++) {
		u32 val_AUX_CS_B;
		u32 val_AUX_SCLK;
		
		if (f_count==32) val_AUX_CS_B = 0x8;
		else             val_AUX_CS_B = 0x0;
		
		if ((f_count==32)&&(R_W_bar==1)) val_AUX_SCLK = 0x0;
		else                             val_AUX_SCLK = 0x4;
		
		// read //{
		if (R_W_bar==1) {
			// shift val_recv
			val_recv  = val_recv<<1;
			
			// read MISO
			val = pgu_spio_ext__aux_in();
			val_recv = val_recv | (val & 0x0001);
		}
			
		//}
		
		
		// write //{
			
		// check framedata[31]
		if ( (framedata & 0x80000000) == 0) {
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,0,0,0 // clock low 
			pgu_spio_ext__aux_out(val_AUX_CS_B|0x0);
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,1,0,0 // clock high
			pgu_spio_ext__aux_out(val_AUX_CS_B|val_AUX_SCLK);	
		} else {
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,0,1,0 // clock low 
			pgu_spio_ext__aux_out(val_AUX_CS_B|0x2);
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,1,1,0 // clock high
			pgu_spio_ext__aux_out(val_AUX_CS_B|val_AUX_SCLK|0x2);	
		}
		
		// shift framedata
		framedata = framedata<<1;
		
		//}

		// // check if write frame...
		// if (R_W_bar==0) continue;
		// 
		// // no recv at last f_count
		// if (f_count==32) continue;
		// 
		// // shift val_recv
		// val_recv  = val_recv<<1;
		// 
		// // read MISO
		// val = pgu_spio_ext__aux_in();
		// val_recv = val_recv | (val & 0x0001);
		
		
	}
	
	//// frame stop
	// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 1,0,0,0
	pgu_spio_ext__aux_out(0x8);
	// 
	return val_recv & 0x0000FFFF;
}

void pgu_spio_ext__aux_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
	//pgu_spio_ext__aux_init(); //$$ to check 
	pgu_spio_ext__aux_send_spi_frame(0, reg_adrs_b8, val_b16);
	pgu_spio_ext__aux_idle();
}

u32  pgu_spio_ext__aux_reg_read_b16(u32 reg_adrs_b8) {
	u32 ret;
	//pgu_spio_ext__aux_init(); //$$ to check 
	ret = pgu_spio_ext__aux_send_spi_frame(1, reg_adrs_b8, 0x0000);
	pgu_spio_ext__aux_idle();
	return ret;
}

//
u32 pgu_spio_ext__aux_IO_init(u32 conf_iodir_AB, u32 conf_out_init_AB) {
	u32 ret;
	
	// init io 
	ret = pgu_spio_ext__aux_init(); // 0xFF10 expected for aux spio and led control
	
	//// set safe IO direction: all inputs
	pgu_spio_ext__aux_reg_write_b16(0x00, 0xFFFF);
	
	//// set the safe output valueas in latch // subboard v1
	//   GPA[7] ch2_gain_con = 0 
	//   GPA[6] ch1_gain_con = 0
	//   GPA[5] ch2_be_con   = 0
	//   GPA[4] ch2_fe_con   = 0
	//   GPA[3] ch1_be_con   = 0
	//   GPA[2] ch1_fe_con   = 0
	//   GPA[1] sleep_n_2    = 0
	//   GPA[0] sleep_n_1    = 0
	//
	//   GPB[7:0] = 0x00
	//
	// pgu_spio_ext__aux_IO_init(0x00FF, 0x0000)

	//pgu_spio_ext__aux_reg_write_b16(0x14, 0x0300); // safe for sleep
	//pgu_spio_ext__aux_reg_write_b16(0x14, 0x0000); // safe for sleep_n // subboard v1
	pgu_spio_ext__aux_reg_write_b16(0x14, conf_out_init_AB); 
	
	//// set IO direction
	//pgu_spio_ext__aux_reg_write_b16(0x00, 0x00FF); // subboard v1
	pgu_spio_ext__aux_reg_write_b16(0x00, conf_iodir_AB); 
	
	ret = pgu_spio_ext__aux_reg_read_b16(0x00);
	
	return ret;
}

void pgu_spio_ext__aux_IO_write_b16 (u32 val_b16) {
	// val_b16 = {GPA,GPB}
	pgu_spio_ext__aux_reg_write_b16(0x14, val_b16);
}

u32 pgu_spio_ext__aux_IO_read_b16() {
	//return pgu_spio_ext__aux_reg_read_b16(0x14); // read latch
	return pgu_spio_ext__aux_reg_read_b16(0x12); // read port
}

//$$ new command for subboard v2
//$$ IOCON (@reg 0x0A)   `':PGU:AUX:CON?'`     `':PGU:AUX:CON #H0000'`
//$$ OLAT  (@reg 0x14)   `':PGU:AUX:OLAT?'`    `':PGU:AUX:OLAT #H0000'`
//$$ IODIR (@reg 0x00)   `':PGU:AUX:DIR?'`     `':PGU:AUX:DIR #H0000'`
//$$ GPIO  (@reg 0x12)   `':PGU:AUX:GPIO?'`    `':PGU:AUX:GPIO #H0000'`
u32  pgu_spio_ext__read_aux_IO_CON  () {
	return pgu_spio_ext__aux_reg_read_b16(0x0A);
}
u32  pgu_spio_ext__read_aux_IO_OLAT () {
	return pgu_spio_ext__aux_reg_read_b16(0x14);
}
u32  pgu_spio_ext__read_aux_IO_DIR  () {
	return pgu_spio_ext__aux_reg_read_b16(0x00);
}
u32  pgu_spio_ext__read_aux_IO_GPIO () {
	return pgu_spio_ext__aux_reg_read_b16(0x12);
}
//
void pgu_spio_ext__send_aux_IO_CON  (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x0A, val_b16);
}
void pgu_spio_ext__send_aux_IO_OLAT (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x14, val_b16);
}
void pgu_spio_ext__send_aux_IO_DIR  (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x00, val_b16);
}
void pgu_spio_ext__send_aux_IO_GPIO (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x12, val_b16);
}

//}


//}


// CLKD //{

// reset signal to CLKD device
u32  pgu_clkd_init() { // EP access
	//
	//ret = dev.ActivateTriggerIn(ti, 0) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__CLKD_TI, 0);
	//
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 24   ;
	u32 flag            ;
	u32 flag_done       ;
	//
	while (1) {
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	return flag_done;
}

// clkd_send_spi_frame
u32  pgu_clkd_send_spi_frame(u32 frame_data) { // EP access
	//
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__CLKD_WI, frame_data, MASK_ALL);
	//
	// trig spi frame
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__CLKD_TI, 1);
	//
	// check spi frame done
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	// check if done is low // when sclk is slow < 1MHz
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==0)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	// check if done is high
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	// copy received data
	u32 val_recv = flag & 0x000000FF;
	//
	return val_recv;
}

// clkd_reg_write_b8
u32  pgu_clkd_reg_write_b8(u32 reg_adrs_b10, u32 val_b8) {
	//
	u32 R_W_bar     = 0           ;
	u32 byte_mode_W = 0x0         ;
	u32 reg_adrs    = reg_adrs_b10;
	u32 val         = val_b8      ;
	//
	u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
	//
	return pgu_clkd_send_spi_frame(framedata);
}

// clkd_reg_read_b8
u32  pgu_clkd_reg_read_b8(u32 reg_adrs_b10) {
	//
	u32 R_W_bar     = 1           ;
	u32 byte_mode_W = 0x0         ;
	u32 reg_adrs    = reg_adrs_b10;
	u32 val         = 0xFF        ;
	//
	u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
	//
	return pgu_clkd_send_spi_frame(framedata);
}

// write check 
u32  pgu_clkd_reg_write_b8_check (u32 reg_adrs_b10, u32 val_b8) {
	u32 tmp;
	u32 retry_count = 0;
	while(1) {
		// write 
		pgu_clkd_reg_write_b8(reg_adrs_b10, val_b8);
		// readback
		tmp = pgu_clkd_reg_read_b8(reg_adrs_b10); // readback 0x18
		if (tmp == val_b8) 
			break;
		retry_count++;
	}
	return retry_count;
}

// read check 
u32  pgu_clkd_reg_read_b8_check (u32 reg_adrs_b10, u32 val_b8) {
	u32 tmp;
	u32 retry_count = 0;
	while(1) {
		// read
		tmp = pgu_clkd_reg_read_b8(reg_adrs_b10); // readback 0x18
		if (tmp == val_b8) 
			break;
		retry_count++;
	}
	return retry_count;
}

// setup CLKD 
u32  pgu_clkd_setup(u32 freq_preset) {
	u32 ret = freq_preset;
	u32 tmp = 0;
	
	// write conf : SDO active 0x99
	tmp += pgu_clkd_reg_write_b8_check(0x000,0x99);

	// read conf 
	//tmp = pgu_clkd_reg_read_b8_check(0x000, 0x18); // readback 0x18
	tmp += pgu_clkd_reg_read_b8_check(0x000, 0x99); // readback 0x99
	
	// read ID
	tmp += pgu_clkd_reg_read_b8_check(0x003, 0x41); // read ID 0x41 
	
	
	// power down for output ports
	// ## LVPECL outputs:
	// ##   0x0F0 OUT0 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F1 OUT1 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F2 OUT2 ... 0x0A for power down; 0x08 for power up. // TO DAC 
	// ##   0x0F3 OUT3 ... 0x0A for power down; 0x08 for power up. // TO DAC 
	// ##   0x0F4 OUT4 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F5 OUT5 ... 0x0A for power down; 0x08 for power up.
	// ## LVDS outputs:
	// ##   0x140 OUT6 ... 0x43 for power down; 0x42 for power up. // TO REF OUT
	// ##   0x141 OUT7 ... 0x43 for power down; 0x42 for power up.
	// ##   0x142 OUT8 ... 0x43 for power down; 0x42 for power up. // TO FPGA
	// ##   0x143 OUT9 ... 0x43 for power down; 0x42 for power up.
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x0F0,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F1,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F2,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F3,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F4,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F5,0x0A);
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x140,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x141,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x142,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x143,0x43);

	// update registers // no readback
	pgu_clkd_reg_write_b8(0x232,0x01); 
	//
	
	//// clock distribution setting
	tmp += pgu_clkd_reg_write_b8_check(0x010,0x7D); //# PLL power-down
	
	if (freq_preset == 4000) { // 400MHz // OK
		//# 400MHz common = 400MHz/1
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x01); //# Bypass VCO divider # for 400MHz common clock 
		//
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 2000) { // 200MHz // OK
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 1000) { // 100MHz // OK
		//# 100MHz common = 400MHz/(2+2)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x02); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 800) { // 80MHz //OK
		//# 80MHz common = 400MHz/(2+3)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 500) { // 50MHz //OK
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
		tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
		tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	}
	else if (freq_preset == 200) { // 20MHz //OK
		//# 80MHz common = 400MHz/(2+3)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/4  
		tmp += pgu_clkd_reg_write_b8_check(0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
		tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
		tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	}
	//  else if (freq_preset == 100) { // 10MHz //NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0x33); //# DVD1 div 2+3+3=8 --> DACx: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x11); //# DVD3.2 div 2+1+1=4  --> REFo: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x11); //# DVD4.2 div 2+1+1=4  --> FPGA: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	//  else if (freq_preset == 50) { // 5MHz //NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/16 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0x77); //# DVD1 div 2+7+7=16 --> DACx: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x33); //# DVD3.2 div 2+3+3=8  --> REFo: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x33); //# DVD4.2 div 2+3+3=8  --> FPGA: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	//  else if (freq_preset == 25) { // 2.5MHz // NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0xFF); //# DVD1 div 2+15+15=32 --> DACx: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x11); //# DVD3.1 div 2+1+1=4 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x33); //# DVD3.2 div 2+3+3=8  --> REFo: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x11); //# DVD4.1 div 2+1+1=4 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x33); //# DVD4.2 div 2+3+3=8  --> FPGA: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	else {
		// return 0
		ret = 0;
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	
	// power up for clock outs
	tmp += pgu_clkd_reg_write_b8_check(0x0F0,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F1,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F2,0x08); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x0F3,0x08); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x0F4,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F5,0x0A);
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x140,0x42); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x141,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x142,0x42); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x143,0x43);
	
	//// readbacks
	//pgu_clkd_reg_read_b8(0x1E0);
	//pgu_clkd_reg_read_b8(0x1E1);
	//pgu_clkd_reg_read_b8(0x193);
	//pgu_clkd_reg_read_b8(0x194);
	//pgu_clkd_reg_read_b8(0x199);
	//pgu_clkd_reg_read_b8(0x19B);
	//pgu_clkd_reg_read_b8(0x19C);
	//pgu_clkd_reg_read_b8(0x19E);
	//pgu_clkd_reg_read_b8(0x1A0);
	//pgu_clkd_reg_read_b8(0x1A1);
	
	
	// update registers // no readback
	pgu_clkd_reg_write_b8(0x232,0x01); 
	
	// check if retry count > 0
	if (tmp>0) {
		ret = 0;
	}
	
	return ret;
}

//}


// DACX //{

// dacx_init
u32  pgu_dacx_init() { // EP access
	//
	//ret = dev.ActivateTriggerIn(ti, 0) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACX_TI, 0);
	//
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 24   ;
	u32 flag            ;
	u32 flag_done       ;
	//
	while (1) {
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACX_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	return flag_done;
}


//  wire [31:0] w_DACX_WI = (w_mcs_ep_wi_en)? w_port_wi_05_1 : ep05wire; 
//  //  bit[30]    = dac1_dco_clk_rst      
//  //  bit[29]    = dac0_dco_clk_rst      
//  //  bit[28]    = clk_dac_clk_rst       
//  //  bit[27]    = dac1_clk_dis          
//  //  bit[26]    = dac0_clk_dis          
//  //  bit[24]    = DACx_CS_id            
//  //  bit[23]    = DACx_R_W_bar          
//  //  bit[22:21] = DACx_byte_mode_N[1:0] 
//  //  bit[20:16] = DACx_reg_adrs_A [4:0] 
//  //  bit[7:0]   = DACx_wr_D[7:0]        

// dacx_fpga_pll_rst
u32  pgu_dacx_fpga_pll_rst(u32 clkd_out_rst, u32 dac0_dco_rst, u32 dac1_dco_rst) { // EP access
	u32 control_data;
	u32 status_pll;
	
	// control data
	control_data = (dac1_dco_rst<<30) + (dac0_dco_rst<<29) + (clkd_out_rst<<28);
	
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, control_data, 0x70000000);
	
	// read status
	//   assign w_TEST_IO_MON[31] = S_IO_2; //
	//   assign w_TEST_IO_MON[30] = S_IO_1; //
	//   assign w_TEST_IO_MON[29] = S_IO_0; //
	//   assign w_TEST_IO_MON[28:27] =  2'b0;
	//   assign w_TEST_IO_MON[26] = dac1_dco_clk_locked;
	//   assign w_TEST_IO_MON[25] = dac0_dco_clk_locked;
	//   assign w_TEST_IO_MON[24] = clk_dac_locked;
	//
	//   assign w_TEST_IO_MON[23:20] =  4'b0;
	//   assign w_TEST_IO_MON[19] = clk4_locked;
	//   assign w_TEST_IO_MON[18] = clk3_locked;
	//   assign w_TEST_IO_MON[17] = clk2_locked;
	//   assign w_TEST_IO_MON[16] = clk1_locked;
	//
	//   assign w_TEST_IO_MON[15: 0] = 16'b0;	
	
	status_pll = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__TEST_IO_MON, 0x07000000);
	//
	return status_pll;
}

u32  pgu_dacx_fpga_clk_dis(u32 dac0_clk_dis, u32 dac1_clk_dis) { // EP access
	u32 ret = 0;
	u32 control_data;
	
	// control data
	control_data = (dac1_clk_dis<<27) + (dac0_clk_dis<<26);

	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, control_data, (0x03 << 26));
	
	return ret;
}


// dacx_send_spi_frame
u32  pgu_dacx_send_spi_frame(u32 frame_data) { // EP access
	//
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, frame_data, MASK_ALL);
	//
	// trig spi frame
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACX_TI, 1);
	//
	// check spi frame done
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	//while True:
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACX_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	u32 val_recv = flag & 0x000000FF;
	//
	return val_recv;
}

// dac0_reg_write_b8
u32  pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
	//
	u32 CS_id       = 0          ;
	u32 R_W_bar     = 0          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = val_b8     ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac0_reg_read_b8
u32  pgu_dac0_reg_read_b8(u32 reg_adrs_b5) {
	//
	u32 CS_id       = 0          ;
	u32 R_W_bar     = 1          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = 0xFF       ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac1_reg_write_b8
u32  pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
	//
	u32 CS_id       = 1          ;
	u32 R_W_bar     = 0          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = val_b8     ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac1_reg_read_b8
u32  pgu_dac1_reg_read_b8(u32 reg_adrs_b5) {
	//
	u32 CS_id       = 1          ;
	u32 R_W_bar     = 1          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = 0xFF       ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

//$$ dac input delay tap calibration
//$$   set initial smp value for input delay tap : try 8
//     https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
//           
//     The nominal step size for SET and HLD is 80 ps. 
//     The nominal step size for SMP is 160 ps.
//
//     400MHz 2.5ns 2500ps  ... 1/3 position ... SMP 2500/160/3 ~ 7.8
//     400MHz 2.5ns 2500ps  ... 1/2 position ... SMP 2500/160/3 ~ 5
//     200MHz 5ns   5000ps  ... 1/3 position ... SMP 5000/160/3 ~ 10
//     200MHz 5ns   5000ps  ... 1/4 position ... SMP 5000/160/4 ~ 7.8
//
//     build timing data array
//       SMP n, SET 0, HLD 0, ... record SEEK
//       SMP n, SET 0, HLD increasing until SEEK toggle ... to find the hold time 
//       SMP n, HLD 0, SET increasing until SEEK toggle ... to find the setup time 
//
//
//    simple method 
//       SET 0, HLD 0, SMP increasing ... record SEEK bit
//       find the center of SMP of the first SEEK high range.
//   

u32  pgu_dacx_cal_input_dtap() {
	
	// SET  = BIT[7:4] @ 0x04
	// HLD  = BIT[3:0] @ 0x04
	// SMP  = BIT[4:0] @ 0x05
	// SEEK = BIT[0]   @ 0x06

	u32 val;
	u32 val_0_pre = 0;
	u32 val_1_pre = 0;
	u32 val_0 = 0;
	u32 val_1 = 0;
	u32 ii;
	u32 val_0_seek_low = -1; // loc of rise
	u32 val_0_seek_hi  = -1; // loc of fall
	u32 val_1_seek_low = -1; // loc of rise
	u32 val_1_seek_hi  = -1; // loc of fall
	u32 val_0_center   = 0; 
	u32 val_1_center   = 0; 
	
	//// new try: weighted sum approach
	u32 val_0_seek_low_found = 0;
	u32 val_0_seek_hi__found = 0;
	u32 val_0_seek_w_sum     = 0;
	u32 val_0_seek_w_sum_fin = 0;
	u32 val_0_cnt_seek_hi    = 0;
	u32 val_0_center_new     = 0;
	u32 val_1_seek_low_found = 0;
	u32 val_1_seek_hi__found = 0;
	u32 val_1_seek_w_sum     = 0;
	u32 val_1_seek_w_sum_fin = 0;
	u32 val_1_cnt_seek_hi    = 0;
	u32 val_1_center_new     = 0;
	
	xil_printf(">>>>>> pgu_dacx_cal_input_dtap: \r\n");
	//xil_printf("write_mcs_ep_wi: 0x%08X @ 0x%02X \r\n", MEM_WI_b32, 0x13);
	
	ii=0;
	
	// make timing table:
	//  SMP  DAC0_SEEK  DAC1_SEEK 
	xil_printf("+-----++-----------+-----------+\r\n");
	xil_printf("| SMP || DAC0_SEEK | DAC1_SEEK |\r\n");
	xil_printf("+-----++-----------+-----------+\r\n");
	while (1) {
		//
		pgu_dac0_reg_write_b8(0x05, ii); // test SMP
		pgu_dac1_reg_write_b8(0x05, ii); // test SMP
		//
		val       = pgu_dac0_reg_read_b8(0x06);
		val_0_pre = val_0;
		val_0     = val & 0x01;
		//xil_printf("read dac0 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
		val       = pgu_dac1_reg_read_b8(0x06);
		val_1_pre = val_1;
		val_1     = val & 0x01;
		//xil_printf("read dac1 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
		
		// report
		xil_printf("| %3d || %9d | %9d |\r\n", ii, val_0, val_1);
		
		// detection rise and fall
		if (val_0_seek_low == -1 && val_0_pre==0 && val_0==1)
			val_0_seek_low = ii;
		if (val_0_seek_hi  == -1 && val_0_pre==1 && val_0==0)
			val_0_seek_hi  = ii-1;
		if (val_1_seek_low == -1 && val_1_pre==0 && val_1==1)
			val_1_seek_low = ii;
		if (val_1_seek_hi  == -1 && val_1_pre==1 && val_1==0)
			val_1_seek_hi  = ii-1;
		
		//// new try 
		if (val_0_seek_low_found == 0 && val_0==0)
			val_0_seek_low_found = 1;
		if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 0 && val_0==1)
			val_0_seek_hi__found = 1;
		if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 1 && val_0==0)
			val_0_seek_w_sum_fin = 1;
		if (val_0_seek_hi__found == 1 && val_0_seek_w_sum_fin == 0) {
			val_0_seek_w_sum    += ii;
			val_0_cnt_seek_hi   += 1;
		}
		if (val_1_seek_low_found == 0 && val_1==0)
			val_1_seek_low_found = 1;
		if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 0 && val_1==1)
			val_1_seek_hi__found = 1;
		if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 1 && val_1==0)
			val_1_seek_w_sum_fin = 1;
		if (val_1_seek_hi__found == 1 && val_1_seek_w_sum_fin == 0) {
			val_1_seek_w_sum    += ii;
			val_1_cnt_seek_hi   += 1;
		}
		
		if (ii==31) 
			break;
		else 
			ii=ii+1;
	}
	xil_printf("+-----++-----------+-----------+\r\n");
	
	// check windows 
	if (val_0_seek_low == -1) val_0_seek_low = 31;
	if (val_0_seek_hi  == -1) val_0_seek_hi  = 31;
	if (val_1_seek_low == -1) val_1_seek_low = 31;
	if (val_1_seek_hi  == -1) val_1_seek_hi  = 31;
	//
	val_0_center = (val_0_seek_low + val_0_seek_hi)/2;
	val_1_center = (val_1_seek_low + val_1_seek_hi)/2;
	//
	xil_printf(" > val_0_seek_low : %02d \r\n", val_0_seek_low);
	xil_printf(" > val_0_seek_hi  : %02d \r\n", val_0_seek_hi );
	xil_printf(" > val_0_center   : %02d \r\n", val_0_center  );
	xil_printf(" > val_1_seek_low : %02d \r\n", val_1_seek_low);
	xil_printf(" > val_1_seek_hi  : %02d \r\n", val_1_seek_hi );
	xil_printf(" > val_1_center   : %02d \r\n", val_1_center  );
		
	//// new try 
	if (val_0_cnt_seek_hi>0) val_0_center_new = val_0_seek_w_sum / val_0_cnt_seek_hi;
	else                     val_0_center_new = val_0_seek_w_sum;
	if (val_1_cnt_seek_hi>0) val_1_center_new = val_1_seek_w_sum / val_1_cnt_seek_hi;
	else                     val_1_center_new = val_1_seek_w_sum;
	
	xil_printf(" >>>> weighted sum \r\n");
	xil_printf(" > val_0_seek_w_sum  : %02d \r\n", val_0_seek_w_sum  );
	xil_printf(" > val_0_cnt_seek_hi : %02d \r\n", val_0_cnt_seek_hi );
	xil_printf(" > val_0_center_new  : %02d \r\n", val_0_center_new  );
	xil_printf(" > val_1_seek_w_sum  : %02d \r\n", val_1_seek_w_sum  );
	xil_printf(" > val_1_cnt_seek_hi : %02d \r\n", val_1_cnt_seek_hi );
	xil_printf(" > val_1_center_new  : %02d \r\n", val_1_center_new  );
	
		
	//$$ set initial smp value for input delay tap : try 9
	//
	// test run with 200MHz : common seek high range 12~26  ... 19
	// test run with 400MHz : common seek high range  6~12  ...  9
	
	// pgu_dac0_reg_write_b8(0x05, 9);
	// pgu_dac1_reg_write_b8(0x05, 9);
	
	// set center
	//pgu_dac0_reg_write_b8(0x05, val_0_center);
	//pgu_dac1_reg_write_b8(0x05, val_1_center);
	pgu_dac0_reg_write_b8(0x05, val_0_center_new);
	pgu_dac1_reg_write_b8(0x05, val_1_center_new);
	
	xil_printf(">>> DAC input delay taps are chosen at each center\r\n");
	
	return 0;
}

// setup DACX 
u32  pgu_dacx_setup() {

	// # pulse path  : full scale 28.1mA  @ 0x02D0 <<<<<< 21.6V / 13.5ns = 1600 V/us // best with 14V supply
	// pgu.dac0_reg_write_b8(0x0F,0xD0)
	// pgu.dac0_reg_write_b8(0x10,0x02)
	// pgu.dac0_reg_write_b8(0x0B,0xD0)
	// pgu.dac0_reg_write_b8(0x0C,0x02)
	pgu_dac0_reg_write_b8(0x0F,0xD0);
	pgu_dac0_reg_write_b8(0x10,0x02);
	pgu_dac0_reg_write_b8(0x0B,0xD0);
	pgu_dac0_reg_write_b8(0x0C,0x02);
	// #
	// pgu.dac1_reg_write_b8(0x0F,0xD0)
	// pgu.dac1_reg_write_b8(0x10,0x02)
	// pgu.dac1_reg_write_b8(0x0B,0xD0)
	// pgu.dac1_reg_write_b8(0x0C,0x02)
	pgu_dac1_reg_write_b8(0x0F,0xD0);
	pgu_dac1_reg_write_b8(0x10,0x02);
	pgu_dac1_reg_write_b8(0x0B,0xD0);
	pgu_dac1_reg_write_b8(0x0C,0x02);
	// 
	// # offset DAC : 0x140 0.625mA, AUX2N active[7] (1) , sink current[6] (1) <<< offset 1.81mV
	// pgu.dac0_reg_write_b8(0x11,0x40)
	// pgu.dac0_reg_write_b8(0x12,0xC1)
	// pgu.dac0_reg_write_b8(0x0D,0x40)
	// pgu.dac0_reg_write_b8(0x0E,0xC1)
	pgu_dac0_reg_write_b8(0x11,0x40);
	pgu_dac0_reg_write_b8(0x12,0xC1);
	pgu_dac0_reg_write_b8(0x0D,0x40);
	pgu_dac0_reg_write_b8(0x0E,0xC1);
	// #
	// pgu.dac1_reg_write_b8(0x11,0x40)
	// pgu.dac1_reg_write_b8(0x12,0xC1)
	// pgu.dac1_reg_write_b8(0x0D,0x40)
	// pgu.dac1_reg_write_b8(0x0E,0xC1)
	pgu_dac1_reg_write_b8(0x11,0x40);
	pgu_dac1_reg_write_b8(0x12,0xC1);
	pgu_dac1_reg_write_b8(0x0D,0x40);
	pgu_dac1_reg_write_b8(0x0E,0xC1);

	
	
	
	return 0;
}

//}


// DACX_PG //{ // not used in S3100-PGU

//  // subfunctions: dacx_dat_write
//  void pgu_dacx_dat_write(u32 dacx_dat, u32 bit_loc_trig) { // EP access
//  	// write control 
//  	//dev.SetWireInValue(wi,dacx_dat,0xFFFFFFFF) # (ep,val,mask)
//  
//  	//write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_WI, dacx_dat, MASK_ALL);
//  	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, dacx_dat, MASK_ALL); //$$ DACZ
//  
//  	//
//  	// trig
//  	//activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_TI, bit_loc_trig);
//  	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
//  
//  }
//  
//  // subfunctions: dacx_dat_read
//  u32  pgu_dacx_dat_read(u32 bit_loc_trig) { // EP access
//  	// trig
//  	//activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_TI, bit_loc_trig);
//  	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
//  
//  	//
//  	//return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_WO, MASK_ALL);
//  	return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WO, MASK_ALL); //$$ DACZ
//  }
//  
//  
//  // dacx_dcs_write_adrs
//  void pgu_dacx_dcs_write_adrs(u32 adrs) {
//  	pgu_dacx_dat_write(adrs, 16);
//  }
//  
//  // dacx_dcs_read_adrs
//  u32  pgu_dacx_dcs_read_adrs() {
//  	return pgu_dacx_dat_read(17);
//  }
//  
//  // dacx_dcs_write_data_dac0
//  void pgu_dacx_dcs_write_data_dac0(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 18);
//  }
//  
//  // dacx_dcs_read_data_dac0
//  u32  pgu_dacx_dcs_read_data_dac0() {
//  	return pgu_dacx_dat_read(19);
//  }
//  
//  // dacx_dcs_write_data_dac1
//  void pgu_dacx_dcs_write_data_dac1(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 20);
//  }
//  
//  // dacx_dcs_read_data_dac1
//  u32  pgu_dacx_dcs_read_data_dac1() {
//  	return pgu_dacx_dat_read(21);
//  }
//  
//  
//  // dacx_dcs_run_test
//  void pgu_dacx_dcs_run_test() {
//  	pgu_dacx_dat_write(0, 22);
//  }
//  
//  
//  // dacx_dcs_stop_test
//  void pgu_dacx_dcs_stop_test() {
//  	pgu_dacx_dat_write(0, 23);
//  }
//  
//  
//  // dacx_dcs_write_repeat
//  void pgu_dacx_dcs_write_repeat(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 24);
//  }
//  
//  // dacx_dcs_read_repeat
//  u32  pgu_dacx_dcs_read_repeat() {
//  	return pgu_dacx_dat_read(25);
//  }
//  
//  // dac0_fifo_write_data
//  	// see // data_count =  dev.WriteToPipeIn(pi, bdata) # (ep, bdata)  in dac0_fifo_write_data()
//  	// see // write_mcs_ep_pi_data 
//  	// see // write_mcs_ep_pi_buf // for dac0_fifo_write_buf to be.
//  void pgu_dac0_fifo_write_data(u32 val_b32) { // unused in S3100-PGU
//  	// call pipe-in data 
//  	write_mcs_ep_pi_data(MCS_EP_BASE, EP_ADRS_PGU__DAC0_DAT_PI, val_b32);
//  }
//  // dac1_fifo_write_data
//  void pgu_dac1_fifo_write_data(u32 val_b32) { // unused in S3100-PGU
//  	// call pipe-in data 
//  	write_mcs_ep_pi_data(MCS_EP_BASE, EP_ADRS_PGU__DAC1_DAT_PI, val_b32);
//  }
//  
//  // dacx_fdcs_run_test
//  void pgu_dacx_fdcs_run_test() {
//  	pgu_dacx_dat_write(0, 28);
//  }
//  // dacx_fdcs_stop_test
//  void pgu_dacx_fdcs_stop_test() {
//  	pgu_dacx_dat_write(0, 29);
//  }
//  
//  // dacx_fdcs_write_repeat
//  void pgu_dacx_fdcs_write_repeat(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 30);
//  }
//  // dacx_fdcs_read_repeat
//  u32  pgu_dacx_fdcs_read_repeat() {
//  	return pgu_dacx_dat_read(31);
//  }
//  
//  // TODO: pgu_dacx__write_control
//  void pgu_dacx__write_control(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 4);
//  }
//  
//  // TODO: pgu_dacx__read_status
//  u32  pgu_dacx__read_status() {
//  	// in h_BC_20_0309
//  	// wire w_write_control = i_trig_dacx_ctrl[4]; //$$
//  	// wire w_read_status   = i_trig_dacx_ctrl[5]; //$$ <--
//  	return pgu_dacx_dat_read(5); //$$ 4-->5 // not work with h_BC_20_0309
//  	//$$return pgu_dacx_dat_read(4); //$$ only for AUX IO test image // OK with h_BC_20_0309
//  }
//  
//  // dacx_fdcs_write_repeat
//  void pgu_dacx__write_rep_period(u32 val_b32) {
//  	pgu_dacx_dat_write(val_b32, 6);
//  }
//  // dacx_fdcs_read_repeat
//  u32  pgu_dacx__read_rep_period() {
//  	return pgu_dacx_dat_read(7);
//  }
//  
//  
//  // setup DACX 
//  u32  pgu_dacx_pg_setup() { //$$ previous DCS setup... not used in S3100-PGU
//  	
//  	// ## setup DCS configuration and data 
//  	// pgu.dacx_dcs_write_adrs     (0x00000000)
//  	// pgu.dacx_dcs_write_data_dac0(0x3FFF0008)
//  	// pgu.dacx_dcs_write_data_dac1(0x3FFF0002)
//  	pgu_dacx_dcs_write_adrs(0);
//  	pgu_dacx_dcs_write_data_dac0(0x3FFF0008);
//  	pgu_dacx_dcs_write_data_dac1(0x3FFF0002);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000001)
//  	// pgu.dacx_dcs_write_data_dac0(0x7FFF0010)
//  	// pgu.dacx_dcs_write_data_dac1(0x7FFF0004)
//  	pgu_dacx_dcs_write_adrs(1);
//  	pgu_dacx_dcs_write_data_dac0(0x7FFF0010);
//  	pgu_dacx_dcs_write_data_dac1(0x7FFF0004);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000002)
//  	// pgu.dacx_dcs_write_data_dac0(0x3FFF0008)
//  	// pgu.dacx_dcs_write_data_dac1(0x3FFF0002)
//  	pgu_dacx_dcs_write_adrs(2);
//  	pgu_dacx_dcs_write_data_dac0(0x3FFF0008);
//  	pgu_dacx_dcs_write_data_dac1(0x3FFF0002);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000003)
//  	// pgu.dacx_dcs_write_data_dac0(0x00000004)
//  	// pgu.dacx_dcs_write_data_dac1(0x00000001)
//  	pgu_dacx_dcs_write_adrs(3);
//  	pgu_dacx_dcs_write_data_dac0(0x00000004);
//  	pgu_dacx_dcs_write_data_dac1(0x00000001);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000004)
//  	// pgu.dacx_dcs_write_data_dac0(0xC0000008)
//  	// pgu.dacx_dcs_write_data_dac1(0xC0000002)
//  	pgu_dacx_dcs_write_adrs(4);
//  	pgu_dacx_dcs_write_data_dac0(0xC0000008);
//  	pgu_dacx_dcs_write_data_dac1(0xC0000002);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000005)
//  	// pgu.dacx_dcs_write_data_dac0(0x80000010)
//  	// pgu.dacx_dcs_write_data_dac1(0x80000004)
//  	pgu_dacx_dcs_write_adrs(5);
//  	pgu_dacx_dcs_write_data_dac0(0x80000010);
//  	pgu_dacx_dcs_write_data_dac1(0x80000004);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000006)
//  	// pgu.dacx_dcs_write_data_dac0(0xC0000008)
//  	// pgu.dacx_dcs_write_data_dac1(0xC0000002)
//  	pgu_dacx_dcs_write_adrs(6);
//  	pgu_dacx_dcs_write_data_dac0(0xC0000008);
//  	pgu_dacx_dcs_write_data_dac1(0xC0000002);
//  	// #
//  	// pgu.dacx_dcs_write_adrs     (0x00000007)
//  	// pgu.dacx_dcs_write_data_dac0(0x00000004)
//  	// pgu.dacx_dcs_write_data_dac1(0x00000001)
//  	pgu_dacx_dcs_write_adrs(7);
//  	pgu_dacx_dcs_write_data_dac0(0x00000004);
//  	pgu_dacx_dcs_write_data_dac1(0x00000001);
//  	// #
//  	// 
//  	// ## DCS test repeat setup 
//  	// #pgu.dacx_dcs_write_repeat  (0x00000000)
//  	// pgu.dacx_dcs_write_repeat  (0x00040001)	
//  	pgu_dacx_dcs_write_repeat(0x00040001);
//  	
//  	return 0;
//  }
//  

//}


// DACZ //{

//$$ new subfunctions may come for S3100-PGU

// subfunctions: dacz_dat_write
void pgu_dacz_dat_write(u32 dacx_dat, u32 bit_loc_trig) { // EP access
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, dacx_dat, MASK_ALL); //$$ DACZ
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
}

// subfunctions: dacz_dat_read
u32  pgu_dacz_dat_read(u32 bit_loc_trig) { // EP access
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
	return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WO, MASK_ALL); //$$ DACZ
}

// TODO: pgu_dacz__read_status
u32  pgu_dacz__read_status() {
	// return status : 
	// wire w_read_status   = i_trig_dacz_ctrl[5]; //$$
	// wire [31:0] w_status_data = {r_control_pulse[31:2], r_dac1_active_clk, r_dac0_active_clk};
	return pgu_dacz_dat_read(5); 
}

	
//}

#endif
//}


// === TODO: PGU-CPU functions === //{
#ifdef _PGU_CPU_

// note : ADRS_BASE_PGU               --> MCS_EP_BASE
// note : EP_ADRS__FPGA_IMAGE_ID__PGU --> EP_ADRS_PGU__FPGA_IMAGE_ID
// note : EP_ADRS__XADC_TEMP__PGU     --> EP_ADRS_PGU__XADC_TEMP
// note : EP_ADRS__SPIO_WI__PGU       --> EP_ADRS_PGU__SPIO_WI
// note : EP_ADRS__SPIO_TI__PGU       --> EP_ADRS_PGU__SPIO_TI
// note : EP_ADRS__SPIO_WO__PGU       --> EP_ADRS_PGU__SPIO_WO
// note : EP_ADRS__CLKD_TI__PGU       --> EP_ADRS_PGU__CLKD_TI
// note : EP_ADRS__CLKD_WO__PGU       --> EP_ADRS_PGU__CLKD_WO
// note : EP_ADRS__CLKD_WI__PGU       --> EP_ADRS_PGU__CLKD_WI
// note : EP_ADRS__DACX_TI__PGU       --> EP_ADRS_PGU__DACX_TI
// note : EP_ADRS__DACX_WO__PGU       --> EP_ADRS_PGU__DACX_WO
// note : EP_ADRS__DACX_WI__PGU       --> EP_ADRS_PGU__DACX_WI
// note : EP_ADRS__TEST_IO_MON__PGU   --> EP_ADRS_PGU__TEST_IO_MON
// note : EP_ADRS__DACX_DAT_WI__PGU   --> EP_ADRS_PGU__DACX_DAT_WI
// note : EP_ADRS__DACX_DAT_TI__PGU   --> EP_ADRS_PGU__DACX_DAT_TI
// note : EP_ADRS__DACX_DAT_WO__PGU   --> EP_ADRS_PGU__DACX_DAT_WO
// note : EP_ADRS__DAC0_DAT_PI__PGU   --> EP_ADRS_PGU__DAC0_DAT_PI
// note : EP_ADRS__DAC1_DAT_PI__PGU   --> EP_ADRS_PGU__DAC1_DAT_PI

// common //{
	
u32 pgu_test(u32 opt) {
	return opt;
}

u32  pgu_read_fpga_image_id() {
	return read_fpga_image_id();	
}

// pgu_read_fpga_temperature() --> read_fpga_temperature()
u32  pgu_read_fpga_temperature() {
	return read_fpga_temperature();	
}

	
//}


// SPIO //{

// for master_spi_mcp23s17.v

u32  pgu_spio_send_spi_frame(u32 frame_data) {
	//dev = lib_ctrl.dev
	//EP_ADRS = conf.OK_EP_ADRS_CONFIG
	//#
	//print('>> {}'.format('Send SPIO frame'))
	//#
	//wi = EP_ADRS['SPIO_WI']
	//wo = EP_ADRS['SPIO_WO']
	//ti = EP_ADRS['SPIO_TI']
	//#
	//#frame_data = (ctrl_b16<<16) + val_b16
	//print('{} = 0x{:08X}'.format('frame_data',frame_data))#
	//#
	//# write control 
	//dev.SetWireInValue(wi,frame_data,0xFFFFFFFF) # (ep,val,mask)
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__SPIO_WI, frame_data, MASK_ALL);
	//dev.UpdateWireIns()
	//#
	//# trig spi frame
	//#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
	//ret = dev.ActivateTriggerIn(ti, 1) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__SPIO_TI, 1);
	//#
	//# check spi frame done
	//#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	//while True:
	while (1) {
		//dev.UpdateWireOuts()
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__SPIO_WO, MASK_ALL);
		
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//#print('{} = {:#010x}'.format('flag',flag))
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//#  
	//print('{} = {}'.format('cnt_done',cnt_done))#
	//print('{} = {}'.format('flag_done',flag_done))
	//#
	//# read received data 
	//#   assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
	//#   assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
	u32 val_recv = flag & 0x0000FFFF;
	//#
	//print('{} = 0x{:02X}'.format('val_recv',val_recv))#
	//#
	return val_recv;
}

u32  pgu_sp_1_reg_read_b16(u32 reg_adrs_b8) {
	//#
	u32 val_b16 =0;
	//
	u32 CS_id      = 1;
	u32 pin_adrs_A = 0; 
	u32 R_W_bar    = 1;
	u32 reg_adrs_A = reg_adrs_b8;
	//#
	u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
	//#
	return pgu_spio_send_spi_frame(framedata);
}

u32  pgu_sp_1_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
	//#
	u32 CS_id      = 1;
	u32 pin_adrs_A = 0;
	u32 R_W_bar    = 0;
	u32 reg_adrs_A = reg_adrs_b8;
	//#
	u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
	//#
	return pgu_spio_send_spi_frame(framedata);
}


//$$ power control : pwd_amp removed in PGU-S3000
void pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp) {
	//
	u32 dir_read;
	u32 lat_read;
	//
	//# read IO direction 
	//# check IO direction : 0xFFX0 where (SPA,SPB)
	dir_read = pgu_sp_1_reg_read_b16(0x00); // unused
	//print('>>>{} = {}'.format('dir_read',form_hex_32b(dir_read)))
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//print('>>>{} = {}'.format('lat_read',form_hex_32b(lat_read)))
	
	//# set IO direction for SP1 PB[3:0] - all output
	pgu_sp_1_reg_write_b16(0x00, dir_read & 0xFFF0);
	//# set IO for SP1 PB[3:0]
	u32 val = (lat_read & 0xFFF0) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));
	pgu_sp_1_reg_write_b16(0x12,val);
}

u32  pgu_spio_ext_pwr_led_readback() {
	//
	u32 lat_read;
	//
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//
	return lat_read & 0x000F;
}

//$$ output relay control : added in PGU-S3000
void pgu_spio_ext_relay(u32 sw_rl_k1, u32 sw_rl_k2) {
	//
	u32 dir_read;
	u32 lat_read;
	//
	//# read IO direction 
	//# check IO direction : 0xFFX0 where (SPA,SPB)
	dir_read = pgu_sp_1_reg_read_b16(0x00); // unused
	//print('>>>{} = {}'.format('dir_read',form_hex_32b(dir_read)))
	//# read output Latch
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//print('>>>{} = {}'.format('lat_read',form_hex_32b(lat_read)))
	
	//# set IO direction for SP1 PA[1:0] - all output
	pgu_sp_1_reg_write_b16(0x00, dir_read & 0xFCFF);
	//# set IO for SP1 PA[1:0]
	u32 val = (lat_read & 0xFCFF) | ( (sw_rl_k2<<9) + (sw_rl_k1<<8) );
	pgu_sp_1_reg_write_b16(0x12,val);
}

u32  pgu_spio_ext_relay_readback() {
	//
	u32 lat_read;
	//
	//# read output Latch // where (SPA,SPB)
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	//
	return (lat_read & 0x0300)>>8; //$$ {SW_RL_K2,SW_RL_K1}
}


//// TODO: AUX IO controls on 6-pin connector //{
//
// initialize   : pgu_spio_ext__aux_init() 
// write outputs: pgu_spio_ext__aux_out ()
// read inputs  : pgu_spio_ext__aux_in  ()
//
// bit locations: 
//   AUX_CS_B = GPB[7]
//   AUX_SCLK = GPB[6]
//   AUX_MOSI = GPB[5]
//   AUX_MISO = GPB[4]
//   
//   self check possible 
//   GPIO port address : 0x12
// 

u32 pgu_spio_ext__aux_init() {
	u32 dir_read;
	u32 lat_read;
	
	//  //// set safe IO direction: all inputs
	//  // read previous value
	//  dir_read = pgu_sp_1_reg_read_b16(0x00);
	//  // set GPB[7:4] as inputs for safe
	//  dir_read = dir_read | 0x00F0;
	//  //
	//  pgu_sp_1_reg_write_b16(0x00,dir_read);
	//  //
	//  //dir_read = pgu_sp_1_reg_read_b16(0x00);

	//// set the safe output values:
	//   AUX_CS_B = 1          @ GPB[7]
	//   AUX_SCLK = 0          @ GPB[6]
	//   AUX_MOSI = 0          @ GPB[5]
	//   AUX_MISO = input (0)  @ GPB[4]
	//
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | 0x0080;
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);

	//// setup IO direction : 0xFF1F
	// read previous value
	dir_read = pgu_sp_1_reg_read_b16(0x00);
	// set GPB[7:5] as outputs //$$ set GPA[1:0] GPB[3:0] as outputs
	//dir_read = dir_read & 0xFF1F;
	dir_read = dir_read & 0xFC10;
	// set GPB[4] as input 
	dir_read = dir_read | 0x0010;
	//
	pgu_sp_1_reg_write_b16(0x00,dir_read);
	//
	dir_read = pgu_sp_1_reg_read_b16(0x00);
	
	return dir_read;
}

void pgu_spio_ext__aux_idle() {
	u32 lat_read;
	
	//// set the safe output values:
	//   AUX_CS_B = 1          @ GPB[7]
	//   AUX_SCLK = 0          @ GPB[6]
	//   AUX_MOSI = 0          @ GPB[5]
	//   AUX_MISO = input (0)  @ GPB[4]
	//
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | 0x0080;
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);

}

void pgu_spio_ext__aux_out (u32 val_b4) {
	u32 lat_read;
	// read previous value
	lat_read = pgu_sp_1_reg_read_b16(0x14);
	// update new value
	lat_read = lat_read & 0xFF0F;
	lat_read = lat_read | ( (val_b4&0x000F)<<4 );
	// update latch
	pgu_sp_1_reg_write_b16(0x14,lat_read);
}

u32 pgu_spio_ext__aux_in () {
	u32 port_read;
	// read gpio
	port_read = pgu_sp_1_reg_read_b16(0x12);
	// find value
	return (port_read & 0x00F0 )>>4;
}


// spi control emulation
u32 pgu_spio_ext__aux_send_spi_frame (u32 R_W_bar, u32 reg_adrs_b8, u32 val_b16) {
	u32 val_recv = 0;
	u32 framedata = 0x00000000;
	u32 f_count;
	u32 val;
	
	// make a frame for MCP23S17T-E/ML
	
	// - SPI frame format: 16 bit long data
	//		<write> 
	//		  o_SPIOx_CS_B -________________________________________________________________---
	//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
	//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0___
	//        f_count_high  0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3
	//        f_count_low   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
	//                     
	//		<read>           
	//		  o_SPIOx_CS_B -________________________________________________________________---
	//		  o_SPIOx_SCLK __-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-___
	//		  o_SPIOx_MOSI _C7C6C5C4C3C2C1C0A7A6A5A4A3A2A1A0___________________________________
	//		  o_SPIOx_MISO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~D7D6D5D4D3D2D1D0E7E6E5E4E3E2E1E0~~
	//        f_count_high  0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 3 3 3
	//        f_count_low   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
	//
	//		control bits      : C[7:0]
	//			C7 0
	//			C6 1
	//			C5 0
	//			C4 0
	//			C3 HW_A2
	//			C2 HW_A1
	//			C1 HW_A0
	//			C0 R_W_bar
	//		address bits      : A[7:0]
	//		data bits for GPA : D[7:0]
	//		data bits for GPB : E[7:0]

	// C = 0x40 or 0x41
	// A = reg_adrs_b8
	// D = val_b16 // {GPA,GPB}
	
	if (R_W_bar==0) {
		framedata = (0x40<<24) | (reg_adrs_b8<<16) | val_b16;
	}
	else {
		framedata = (0x41<<24) | (reg_adrs_b8<<16) | val_b16;
	}
	//
	
	// generate a frame
	// ...
	//// frame start
	// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 1,0,0,0
	pgu_spio_ext__aux_out(0x8);
	
	for (f_count=0;f_count<33;f_count++) {
		u32 val_AUX_CS_B;
		u32 val_AUX_SCLK;
		
		if (f_count==32) val_AUX_CS_B = 0x8;
		else             val_AUX_CS_B = 0x0;
		
		if ((f_count==32)&&(R_W_bar==1)) val_AUX_SCLK = 0x0;
		else                             val_AUX_SCLK = 0x4;
		
		// read //{
		if (R_W_bar==1) {
			// shift val_recv
			val_recv  = val_recv<<1;
			
			// read MISO
			val = pgu_spio_ext__aux_in();
			val_recv = val_recv | (val & 0x0001);
		}
			
		//}
		
		
		// write //{
			
		// check framedata[31]
		if ( (framedata & 0x80000000) == 0) {
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,0,0,0 // clock low 
			pgu_spio_ext__aux_out(val_AUX_CS_B|0x0);
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,1,0,0 // clock high
			pgu_spio_ext__aux_out(val_AUX_CS_B|val_AUX_SCLK);	
		} else {
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,0,1,0 // clock low 
			pgu_spio_ext__aux_out(val_AUX_CS_B|0x2);
			// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 0,1,1,0 // clock high
			pgu_spio_ext__aux_out(val_AUX_CS_B|val_AUX_SCLK|0x2);	
		}
		
		// shift framedata
		framedata = framedata<<1;
		
		//}

		// // check if write frame...
		// if (R_W_bar==0) continue;
		// 
		// // no recv at last f_count
		// if (f_count==32) continue;
		// 
		// // shift val_recv
		// val_recv  = val_recv<<1;
		// 
		// // read MISO
		// val = pgu_spio_ext__aux_in();
		// val_recv = val_recv | (val & 0x0001);
		
		
	}
	
	//// frame stop
	// AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 1,0,0,0
	pgu_spio_ext__aux_out(0x8);
	// 
	return val_recv & 0x0000FFFF;
}

void pgu_spio_ext__aux_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
	//pgu_spio_ext__aux_init(); //$$ to check 
	pgu_spio_ext__aux_send_spi_frame(0, reg_adrs_b8, val_b16);
	pgu_spio_ext__aux_idle();
}

u32  pgu_spio_ext__aux_reg_read_b16(u32 reg_adrs_b8) {
	u32 ret;
	//pgu_spio_ext__aux_init(); //$$ to check 
	ret = pgu_spio_ext__aux_send_spi_frame(1, reg_adrs_b8, 0x0000);
	pgu_spio_ext__aux_idle();
	return ret;
}

//
u32 pgu_spio_ext__aux_IO_init(u32 conf_iodir_AB, u32 conf_out_init_AB) {
	u32 ret;
	
	// init io 
	ret = pgu_spio_ext__aux_init(); // 0xFF10 expected for aux spio and led control
	
	//// set safe IO direction: all inputs
	pgu_spio_ext__aux_reg_write_b16(0x00, 0xFFFF);
	
	//// set the safe output valueas in latch // subboard v1
	//   GPA[7] ch2_gain_con = 0 
	//   GPA[6] ch1_gain_con = 0
	//   GPA[5] ch2_be_con   = 0
	//   GPA[4] ch2_fe_con   = 0
	//   GPA[3] ch1_be_con   = 0
	//   GPA[2] ch1_fe_con   = 0
	//   GPA[1] sleep_n_2    = 0
	//   GPA[0] sleep_n_1    = 0
	//
	//   GPB[7:0] = 0x00
	//
	// pgu_spio_ext__aux_IO_init(0x00FF, 0x0000)

	//pgu_spio_ext__aux_reg_write_b16(0x14, 0x0300); // safe for sleep
	//pgu_spio_ext__aux_reg_write_b16(0x14, 0x0000); // safe for sleep_n // subboard v1
	pgu_spio_ext__aux_reg_write_b16(0x14, conf_out_init_AB); 
	
	//// set IO direction
	//pgu_spio_ext__aux_reg_write_b16(0x00, 0x00FF); // subboard v1
	pgu_spio_ext__aux_reg_write_b16(0x00, conf_iodir_AB); 
	
	ret = pgu_spio_ext__aux_reg_read_b16(0x00);
	
	return ret;
}

void pgu_spio_ext__aux_IO_write_b16 (u32 val_b16) {
	// val_b16 = {GPA,GPB}
	pgu_spio_ext__aux_reg_write_b16(0x14, val_b16);
}

u32 pgu_spio_ext__aux_IO_read_b16() {
	//return pgu_spio_ext__aux_reg_read_b16(0x14); // read latch
	return pgu_spio_ext__aux_reg_read_b16(0x12); // read port
}

//$$ new command for subboard v2
//$$ IOCON (@reg 0x0A)   `':PGU:AUX:CON?'`     `':PGU:AUX:CON #H0000'`
//$$ OLAT  (@reg 0x14)   `':PGU:AUX:OLAT?'`    `':PGU:AUX:OLAT #H0000'`
//$$ IODIR (@reg 0x00)   `':PGU:AUX:DIR?'`     `':PGU:AUX:DIR #H0000'`
//$$ GPIO  (@reg 0x12)   `':PGU:AUX:GPIO?'`    `':PGU:AUX:GPIO #H0000'`
u32  pgu_spio_ext__read_aux_IO_CON  () {
	return pgu_spio_ext__aux_reg_read_b16(0x0A);
}
u32  pgu_spio_ext__read_aux_IO_OLAT () {
	return pgu_spio_ext__aux_reg_read_b16(0x14);
}
u32  pgu_spio_ext__read_aux_IO_DIR  () {
	return pgu_spio_ext__aux_reg_read_b16(0x00);
}
u32  pgu_spio_ext__read_aux_IO_GPIO () {
	return pgu_spio_ext__aux_reg_read_b16(0x12);
}
//
void pgu_spio_ext__send_aux_IO_CON  (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x0A, val_b16);
}
void pgu_spio_ext__send_aux_IO_OLAT (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x14, val_b16);
}
void pgu_spio_ext__send_aux_IO_DIR  (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x00, val_b16);
}
void pgu_spio_ext__send_aux_IO_GPIO (u32 val_b16) {
	pgu_spio_ext__aux_reg_write_b16(0x12, val_b16);
}

//}


//}


// CLKD //{

// reset signal to CLKD device
u32  pgu_clkd_init() {
	//
	//ret = dev.ActivateTriggerIn(ti, 0) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__CLKD_TI, 0);
	//
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 24   ;
	u32 flag            ;
	u32 flag_done       ;
	//
	while (1) {
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	return flag_done;
}

// clkd_send_spi_frame
u32  pgu_clkd_send_spi_frame(u32 frame_data) {
	//
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__CLKD_WI, frame_data, MASK_ALL);
	//
	// trig spi frame
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__CLKD_TI, 1);
	//
	// check spi frame done
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	// check if done is low // when sclk is slow < 1MHz
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==0)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	// check if done is high
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__CLKD_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	// copy received data
	u32 val_recv = flag & 0x000000FF;
	//
	return val_recv;
}

// clkd_reg_write_b8
u32  pgu_clkd_reg_write_b8(u32 reg_adrs_b10, u32 val_b8) {
	//
	u32 R_W_bar     = 0           ;
	u32 byte_mode_W = 0x0         ;
	u32 reg_adrs    = reg_adrs_b10;
	u32 val         = val_b8      ;
	//
	u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
	//
	return pgu_clkd_send_spi_frame(framedata);
}

// clkd_reg_read_b8
u32  pgu_clkd_reg_read_b8(u32 reg_adrs_b10) {
	//
	u32 R_W_bar     = 1           ;
	u32 byte_mode_W = 0x0         ;
	u32 reg_adrs    = reg_adrs_b10;
	u32 val         = 0xFF        ;
	//
	u32 framedata = (R_W_bar<<31) + (byte_mode_W<<29) + (reg_adrs<<16) + val;
	//
	return pgu_clkd_send_spi_frame(framedata);
}

// write check 
u32  pgu_clkd_reg_write_b8_check (u32 reg_adrs_b10, u32 val_b8) {
	u32 tmp;
	u32 retry_count = 0;
	while(1) {
		// write 
		pgu_clkd_reg_write_b8(reg_adrs_b10, val_b8);
		// readback
		tmp = pgu_clkd_reg_read_b8(reg_adrs_b10); // readback 0x18
		if (tmp == val_b8) 
			break;
		retry_count++;
	}
	return retry_count;
}

// read check 
u32  pgu_clkd_reg_read_b8_check (u32 reg_adrs_b10, u32 val_b8) {
	u32 tmp;
	u32 retry_count = 0;
	while(1) {
		// read
		tmp = pgu_clkd_reg_read_b8(reg_adrs_b10); // readback 0x18
		if (tmp == val_b8) 
			break;
		retry_count++;
	}
	return retry_count;
}

// setup CLKD 
u32  pgu_clkd_setup(u32 freq_preset) {
	u32 ret = freq_preset;
	u32 tmp = 0;
	
	// write conf : SDO active 0x99
	tmp += pgu_clkd_reg_write_b8_check(0x000,0x99);

	// read conf 
	//tmp = pgu_clkd_reg_read_b8_check(0x000, 0x18); // readback 0x18
	tmp += pgu_clkd_reg_read_b8_check(0x000, 0x99); // readback 0x99
	
	// read ID
	tmp += pgu_clkd_reg_read_b8_check(0x003, 0x41); // read ID 0x41 
	
	
	// power down for output ports
	// ## LVPECL outputs:
	// ##   0x0F0 OUT0 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F1 OUT1 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F2 OUT2 ... 0x0A for power down; 0x08 for power up. // TO DAC 
	// ##   0x0F3 OUT3 ... 0x0A for power down; 0x08 for power up. // TO DAC 
	// ##   0x0F4 OUT4 ... 0x0A for power down; 0x08 for power up.
	// ##   0x0F5 OUT5 ... 0x0A for power down; 0x08 for power up.
	// ## LVDS outputs:
	// ##   0x140 OUT6 ... 0x43 for power down; 0x42 for power up. // TO REF OUT
	// ##   0x141 OUT7 ... 0x43 for power down; 0x42 for power up.
	// ##   0x142 OUT8 ... 0x43 for power down; 0x42 for power up. // TO FPGA
	// ##   0x143 OUT9 ... 0x43 for power down; 0x42 for power up.
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x0F0,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F1,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F2,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F3,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F4,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F5,0x0A);
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x140,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x141,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x142,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x143,0x43);

	// update registers // no readback
	pgu_clkd_reg_write_b8(0x232,0x01); 
	//
	
	//// clock distribution setting
	tmp += pgu_clkd_reg_write_b8_check(0x010,0x7D); //# PLL power-down
	
	if (freq_preset == 4000) { // 400MHz // OK
		//# 400MHz common = 400MHz/1
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x01); //# Bypass VCO divider # for 400MHz common clock 
		//
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 2000) { // 200MHz // OK
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 1000) { // 100MHz // OK
		//# 100MHz common = 400MHz/(2+2)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x02); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 800) { // 80MHz //OK
		//# 80MHz common = 400MHz/(2+3)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	else if (freq_preset == 500) { // 50MHz //OK
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
		tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
		tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	}
	else if (freq_preset == 200) { // 20MHz //OK
		//# 80MHz common = 400MHz/(2+3)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/4  
		tmp += pgu_clkd_reg_write_b8_check(0x193,0x11); //# DVD1 div 2+1+1=4 --> DACx: ()/4 
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
		tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x19B,0x00); //# DVD3.2 div 2+0+0=2  --> REFo: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
		tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
		tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x00); //# DVD4.2 div 2+0+0=2  --> FPGA: ()/4
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	}
	//  else if (freq_preset == 100) { // 10MHz //NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0x33); //# DVD1 div 2+3+3=8 --> DACx: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x11); //# DVD3.2 div 2+1+1=4  --> REFo: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x11); //# DVD4.2 div 2+1+1=4  --> FPGA: ()/8
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	//  else if (freq_preset == 50) { // 5MHz //NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/16 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0x77); //# DVD1 div 2+7+7=16 --> DACx: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x00); //# DVD3.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x33); //# DVD3.2 div 2+3+3=8  --> REFo: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x00); //# DVD4.1 div 2+0+0=2 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x33); //# DVD4.2 div 2+3+3=8  --> FPGA: ()/16
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	//  else if (freq_preset == 25) { // 2.5MHz // NG
	//  	//# 80MHz common = 400MHz/(2+3)
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x03); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
	//  	// ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x193,0xFF); //# DVD1 div 2+15+15=32 --> DACx: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x194,0x00); //# DVD1 bypass off 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x199,0x11); //# DVD3.1 div 2+1+1=4 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19B,0x33); //# DVD3.2 div 2+3+3=8  --> REFo: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19C,0x00); //# DVD3.1, DVD3.2 all bypass off
	//  	tmp += pgu_clkd_reg_write_b8_check(0x19E,0x11); //# DVD4.1 div 2+1+1=4 
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A0,0x33); //# DVD4.2 div 2+3+3=8  --> FPGA: ()/32
	//  	tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x00); //# DVD4.1, DVD4.2 all bypass off
	//  }
	else {
		// return 0
		ret = 0;
		//# 200MHz common = 400MHz/(2+0)
		tmp += pgu_clkd_reg_write_b8_check(0x1E0,0x00); //# Set VCO divider # [0,1,2,3,4] for [/2,/3,/4,/5,/6]
		tmp += pgu_clkd_reg_write_b8_check(0x1E1,0x00); //# Use VCO divider # for 400MHz/X common clock 
		// ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x194,0x80); //# DVD1 bypass --> DACx: ()/1 
		tmp += pgu_clkd_reg_write_b8_check(0x19C,0x30); //# DVD3.1, DVD3.2 all bypass --> REFo: ()/1
		tmp += pgu_clkd_reg_write_b8_check(0x1A1,0x30); //# DVD4.1, DVD4.2 all bypass --> FPGA: ()/1 = 400MHz
	}
	
	// power up for clock outs
	tmp += pgu_clkd_reg_write_b8_check(0x0F0,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F1,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F2,0x08); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x0F3,0x08); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x0F4,0x0A);
	tmp += pgu_clkd_reg_write_b8_check(0x0F5,0x0A);
	// ##
	tmp += pgu_clkd_reg_write_b8_check(0x140,0x42); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x141,0x43);
	tmp += pgu_clkd_reg_write_b8_check(0x142,0x42); //$$ power up
	tmp += pgu_clkd_reg_write_b8_check(0x143,0x43);
	
	//// readbacks
	//pgu_clkd_reg_read_b8(0x1E0);
	//pgu_clkd_reg_read_b8(0x1E1);
	//pgu_clkd_reg_read_b8(0x193);
	//pgu_clkd_reg_read_b8(0x194);
	//pgu_clkd_reg_read_b8(0x199);
	//pgu_clkd_reg_read_b8(0x19B);
	//pgu_clkd_reg_read_b8(0x19C);
	//pgu_clkd_reg_read_b8(0x19E);
	//pgu_clkd_reg_read_b8(0x1A0);
	//pgu_clkd_reg_read_b8(0x1A1);
	
	
	// update registers // no readback
	pgu_clkd_reg_write_b8(0x232,0x01); 
	
	// check if retry count > 0
	if (tmp>0) {
		ret = 0;
	}
	
	return ret;
}

//}


// DACX //{

// dacx_init
u32  pgu_dacx_init() {
	//
	//ret = dev.ActivateTriggerIn(ti, 0) # (ep,bit) 
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_TI, 0);
	//
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 24   ;
	u32 flag            ;
	u32 flag_done       ;
	//
	while (1) {
		//flag = dev.GetWireOutValue(wo)
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__DACX_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	return flag_done;
}


//  wire [31:0] w_DACX_WI = (w_mcs_ep_wi_en)? w_port_wi_05_1 : ep05wire; 
//  //  bit[30]    = dac1_dco_clk_rst      
//  //  bit[29]    = dac0_dco_clk_rst      
//  //  bit[28]    = clk_dac_clk_rst       
//  //  bit[27]    = dac1_clk_dis          
//  //  bit[26]    = dac0_clk_dis          
//  //  bit[24]    = DACx_CS_id            
//  //  bit[23]    = DACx_R_W_bar          
//  //  bit[22:21] = DACx_byte_mode_N[1:0] 
//  //  bit[20:16] = DACx_reg_adrs_A [4:0] 
//  //  bit[7:0]   = DACx_wr_D[7:0]        

// dacx_fpga_pll_rst
u32  pgu_dacx_fpga_pll_rst(u32 clkd_out_rst, u32 dac0_dco_rst, u32 dac1_dco_rst) {
	u32 control_data;
	u32 status_pll;
	
	// control data
	control_data = (dac1_dco_rst<<30) + (dac0_dco_rst<<29) + (clkd_out_rst<<28);
	
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACX_WI, control_data, 0x70000000);
	
	// read status
	//   assign w_TEST_IO_MON[31] = S_IO_2; //
	//   assign w_TEST_IO_MON[30] = S_IO_1; //
	//   assign w_TEST_IO_MON[29] = S_IO_0; //
	//   assign w_TEST_IO_MON[28:27] =  2'b0;
	//   assign w_TEST_IO_MON[26] = dac1_dco_clk_locked;
	//   assign w_TEST_IO_MON[25] = dac0_dco_clk_locked;
	//   assign w_TEST_IO_MON[24] = clk_dac_locked;
	//
	//   assign w_TEST_IO_MON[23:20] =  4'b0;
	//   assign w_TEST_IO_MON[19] = clk4_locked;
	//   assign w_TEST_IO_MON[18] = clk3_locked;
	//   assign w_TEST_IO_MON[17] = clk2_locked;
	//   assign w_TEST_IO_MON[16] = clk1_locked;
	//
	//   assign w_TEST_IO_MON[15: 0] = 16'b0;	
	
	status_pll = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_IO_MON, 0x07000000);
	//
	return status_pll;
}

u32  pgu_dacx_fpga_clk_dis(u32 dac0_clk_dis, u32 dac1_clk_dis) {
	u32 ret = 0;
	u32 control_data;
	
	// control data
	control_data = (dac1_clk_dis<<27) + (dac0_clk_dis<<26);

	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACX_WI, control_data, (0x03 << 26));
	
	return ret;
}


// dacx_send_spi_frame
u32  pgu_dacx_send_spi_frame(u32 frame_data) {
	//
	// write control 
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACX_WI, frame_data, MASK_ALL);
	//
	// trig spi frame
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_TI, 1);
	//
	// check spi frame done
	u32 cnt_done = 0    ;
	u32 MAX_CNT  = 20000;
	u32 bit_loc  = 25   ;
	u32 flag;
	u32 flag_done;
	//while True:
	while (1) {
		//
		flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__DACX_WO, MASK_ALL);
		flag_done = (flag&(1<<bit_loc))>>bit_loc;
		//
		if (flag_done==1)
			break;
		cnt_done += 1;
		if (cnt_done>=MAX_CNT)
			break;
	}
	//
	u32 val_recv = flag & 0x000000FF;
	//
	return val_recv;
}

// dac0_reg_write_b8
u32  pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
	//
	u32 CS_id       = 0          ;
	u32 R_W_bar     = 0          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = val_b8     ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac0_reg_read_b8
u32  pgu_dac0_reg_read_b8(u32 reg_adrs_b5) {
	//
	u32 CS_id       = 0          ;
	u32 R_W_bar     = 1          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = 0xFF       ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac1_reg_write_b8
u32  pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
	//
	u32 CS_id       = 1          ;
	u32 R_W_bar     = 0          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = val_b8     ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

// dac1_reg_read_b8
u32  pgu_dac1_reg_read_b8(u32 reg_adrs_b5) {
	//
	u32 CS_id       = 1          ;
	u32 R_W_bar     = 1          ;
	u32 byte_mode_N = 0x0        ;
	u32 reg_adrs    = reg_adrs_b5;
	u32 val         = 0xFF       ;
	//
	u32 framedata = (CS_id<<24) + (R_W_bar<<23) + (byte_mode_N<<21) + (reg_adrs<<16) + val;
	//
	return pgu_dacx_send_spi_frame(framedata);
}

//$$ dac input delay tap calibration
//$$   set initial smp value for input delay tap : try 8
//     https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
//           
//     The nominal step size for SET and HLD is 80 ps. 
//     The nominal step size for SMP is 160 ps.
//
//     400MHz 2.5ns 2500ps  ... 1/3 position ... SMP 2500/160/3 ~ 7.8
//     400MHz 2.5ns 2500ps  ... 1/2 position ... SMP 2500/160/3 ~ 5
//     200MHz 5ns   5000ps  ... 1/3 position ... SMP 5000/160/3 ~ 10
//     200MHz 5ns   5000ps  ... 1/4 position ... SMP 5000/160/4 ~ 7.8
//
//     build timing data array
//       SMP n, SET 0, HLD 0, ... record SEEK
//       SMP n, SET 0, HLD increasing until SEEK toggle ... to find the hold time 
//       SMP n, HLD 0, SET increasing until SEEK toggle ... to find the setup time 
//
//
//    simple method 
//       SET 0, HLD 0, SMP increasing ... record SEEK bit
//       find the center of SMP of the first SEEK high range.
//   

u32  pgu_dacx_cal_input_dtap() {
	
	// SET  = BIT[7:4] @ 0x04
	// HLD  = BIT[3:0] @ 0x04
	// SMP  = BIT[4:0] @ 0x05
	// SEEK = BIT[0]   @ 0x06

	u32 val;
	u32 val_0_pre = 0;
	u32 val_1_pre = 0;
	u32 val_0 = 0;
	u32 val_1 = 0;
	u32 ii;
	u32 val_0_seek_low = -1; // loc of rise
	u32 val_0_seek_hi  = -1; // loc of fall
	u32 val_1_seek_low = -1; // loc of rise
	u32 val_1_seek_hi  = -1; // loc of fall
	u32 val_0_center   = 0; 
	u32 val_1_center   = 0; 
	
	//// new try: weighted sum approach
	u32 val_0_seek_low_found = 0;
	u32 val_0_seek_hi__found = 0;
	u32 val_0_seek_w_sum     = 0;
	u32 val_0_seek_w_sum_fin = 0;
	u32 val_0_cnt_seek_hi    = 0;
	u32 val_0_center_new     = 0;
	u32 val_1_seek_low_found = 0;
	u32 val_1_seek_hi__found = 0;
	u32 val_1_seek_w_sum     = 0;
	u32 val_1_seek_w_sum_fin = 0;
	u32 val_1_cnt_seek_hi    = 0;
	u32 val_1_center_new     = 0;
	
	xil_printf(">>>>>> pgu_dacx_cal_input_dtap: \r\n");
	//xil_printf("write_mcs_ep_wi: 0x%08X @ 0x%02X \r\n", MEM_WI_b32, 0x13);
	
	ii=0;
	
	// make timing table:
	//  SMP  DAC0_SEEK  DAC1_SEEK 
	xil_printf("|------------------------------|\r\n");
	xil_printf("| SMP || DAC0_SEEK | DAC1_SEEK |\r\n");
	xil_printf("|-----||-----------|-----------|\r\n");
	while (1) {
		//
		pgu_dac0_reg_write_b8(0x05, ii); // test SMP
		pgu_dac1_reg_write_b8(0x05, ii); // test SMP
		//
		val       = pgu_dac0_reg_read_b8(0x06);
		val_0_pre = val_0;
		val_0     = val & 0x01;
		//xil_printf("read dac0 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
		val       = pgu_dac1_reg_read_b8(0x06);
		val_1_pre = val_1;
		val_1     = val & 0x01;
		//xil_printf("read dac1 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
		
		// report
		xil_printf("| %3d || %9d | %9d |\r\n", ii, val_0, val_1);
		
		// detection rise and fall
		if (val_0_seek_low == -1 && val_0_pre==0 && val_0==1)
			val_0_seek_low = ii;
		if (val_0_seek_hi  == -1 && val_0_pre==1 && val_0==0)
			val_0_seek_hi  = ii-1;
		if (val_1_seek_low == -1 && val_1_pre==0 && val_1==1)
			val_1_seek_low = ii;
		if (val_1_seek_hi  == -1 && val_1_pre==1 && val_1==0)
			val_1_seek_hi  = ii-1;
		
		//// new try 
		if (val_0_seek_low_found == 0 && val_0==0)
			val_0_seek_low_found = 1;
		if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 0 && val_0==1)
			val_0_seek_hi__found = 1;
		if (val_0_seek_low_found == 1 && val_0_seek_hi__found == 1 && val_0==0)
			val_0_seek_w_sum_fin = 1;
		if (val_0_seek_hi__found == 1 && val_0_seek_w_sum_fin == 0) {
			val_0_seek_w_sum    += ii;
			val_0_cnt_seek_hi   += 1;
		}
		if (val_1_seek_low_found == 0 && val_1==0)
			val_1_seek_low_found = 1;
		if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 0 && val_1==1)
			val_1_seek_hi__found = 1;
		if (val_1_seek_low_found == 1 && val_1_seek_hi__found == 1 && val_1==0)
			val_1_seek_w_sum_fin = 1;
		if (val_1_seek_hi__found == 1 && val_1_seek_w_sum_fin == 0) {
			val_1_seek_w_sum    += ii;
			val_1_cnt_seek_hi   += 1;
		}
		
		if (ii==31) 
			break;
		else 
			ii=ii+1;
	}
	xil_printf("|------------------------------|\r\n");
	
	// check windows 
	if (val_0_seek_low == -1) val_0_seek_low = 31;
	if (val_0_seek_hi  == -1) val_0_seek_hi  = 31;
	if (val_1_seek_low == -1) val_1_seek_low = 31;
	if (val_1_seek_hi  == -1) val_1_seek_hi  = 31;
	//
	val_0_center = (val_0_seek_low + val_0_seek_hi)/2;
	val_1_center = (val_1_seek_low + val_1_seek_hi)/2;
	//
	xil_printf(" > val_0_seek_low : %02d \r\n", val_0_seek_low);
	xil_printf(" > val_0_seek_hi  : %02d \r\n", val_0_seek_hi );
	xil_printf(" > val_0_center   : %02d \r\n", val_0_center  );
	xil_printf(" > val_1_seek_low : %02d \r\n", val_1_seek_low);
	xil_printf(" > val_1_seek_hi  : %02d \r\n", val_1_seek_hi );
	xil_printf(" > val_1_center   : %02d \r\n", val_1_center  );
		
	//// new try 
	if (val_0_cnt_seek_hi>0) val_0_center_new = val_0_seek_w_sum / val_0_cnt_seek_hi;
	else                     val_0_center_new = val_0_seek_w_sum;
	if (val_1_cnt_seek_hi>0) val_1_center_new = val_1_seek_w_sum / val_1_cnt_seek_hi;
	else                     val_1_center_new = val_1_seek_w_sum;
	
	xil_printf(" >>>> weighted sum \r\n");
	xil_printf(" > val_0_seek_w_sum  : %02d \r\n", val_0_seek_w_sum  );
	xil_printf(" > val_0_cnt_seek_hi : %02d \r\n", val_0_cnt_seek_hi );
	xil_printf(" > val_0_center_new  : %02d \r\n", val_0_center_new  );
	xil_printf(" > val_1_seek_w_sum  : %02d \r\n", val_1_seek_w_sum  );
	xil_printf(" > val_1_cnt_seek_hi : %02d \r\n", val_1_cnt_seek_hi );
	xil_printf(" > val_1_center_new  : %02d \r\n", val_1_center_new  );
	
		
	//$$ set initial smp value for input delay tap : try 9
	//
	// test run with 200MHz : common seek high range 12~26  ... 19
	// test run with 400MHz : common seek high range  6~12  ...  9
	
	// pgu_dac0_reg_write_b8(0x05, 9);
	// pgu_dac1_reg_write_b8(0x05, 9);
	
	// set center
	//pgu_dac0_reg_write_b8(0x05, val_0_center);
	//pgu_dac1_reg_write_b8(0x05, val_1_center);
	pgu_dac0_reg_write_b8(0x05, val_0_center_new);
	pgu_dac1_reg_write_b8(0x05, val_1_center_new);
	
	xil_printf(">>> DAC input delay taps are chosen at each center\r\n");
	
	return 0;
}

// setup DACX 
u32  pgu_dacx_setup() {

	// # pulse path  : full scale 28.1mA  @ 0x02D0 <<<<<< 21.6V / 13.5ns = 1600 V/us // best with 14V supply
	// pgu.dac0_reg_write_b8(0x0F,0xD0)
	// pgu.dac0_reg_write_b8(0x10,0x02)
	// pgu.dac0_reg_write_b8(0x0B,0xD0)
	// pgu.dac0_reg_write_b8(0x0C,0x02)
	pgu_dac0_reg_write_b8(0x0F,0xD0);
	pgu_dac0_reg_write_b8(0x10,0x02);
	pgu_dac0_reg_write_b8(0x0B,0xD0);
	pgu_dac0_reg_write_b8(0x0C,0x02);
	// #
	// pgu.dac1_reg_write_b8(0x0F,0xD0)
	// pgu.dac1_reg_write_b8(0x10,0x02)
	// pgu.dac1_reg_write_b8(0x0B,0xD0)
	// pgu.dac1_reg_write_b8(0x0C,0x02)
	pgu_dac1_reg_write_b8(0x0F,0xD0);
	pgu_dac1_reg_write_b8(0x10,0x02);
	pgu_dac1_reg_write_b8(0x0B,0xD0);
	pgu_dac1_reg_write_b8(0x0C,0x02);
	// 
	// # offset DAC : 0x140 0.625mA, AUX2N active[7] (1) , sink current[6] (1) <<< offset 1.81mV
	// pgu.dac0_reg_write_b8(0x11,0x40)
	// pgu.dac0_reg_write_b8(0x12,0xC1)
	// pgu.dac0_reg_write_b8(0x0D,0x40)
	// pgu.dac0_reg_write_b8(0x0E,0xC1)
	pgu_dac0_reg_write_b8(0x11,0x40);
	pgu_dac0_reg_write_b8(0x12,0xC1);
	pgu_dac0_reg_write_b8(0x0D,0x40);
	pgu_dac0_reg_write_b8(0x0E,0xC1);
	// #
	// pgu.dac1_reg_write_b8(0x11,0x40)
	// pgu.dac1_reg_write_b8(0x12,0xC1)
	// pgu.dac1_reg_write_b8(0x0D,0x40)
	// pgu.dac1_reg_write_b8(0x0E,0xC1)
	pgu_dac1_reg_write_b8(0x11,0x40);
	pgu_dac1_reg_write_b8(0x12,0xC1);
	pgu_dac1_reg_write_b8(0x0D,0x40);
	pgu_dac1_reg_write_b8(0x0E,0xC1);

	
	
	
	return 0;
}

//}


// DACX_PG //{

// subfunctions: dacx_dat_write
void pgu_dacx_dat_write(u32 dacx_dat, u32 bit_loc_trig) {
	// write control 
	//dev.SetWireInValue(wi,dacx_dat,0xFFFFFFFF) # (ep,val,mask)

	//write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_WI, dacx_dat, MASK_ALL);
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, dacx_dat, MASK_ALL); //$$ DACZ

	//
	// trig
	//activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_TI, bit_loc_trig);
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ

}

// subfunctions: dacx_dat_read
u32  pgu_dacx_dat_read(u32 bit_loc_trig) {
	// trig
	//activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_TI, bit_loc_trig);
	activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ

	//
	//return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__DACX_DAT_WO, MASK_ALL);
	return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WO, MASK_ALL); //$$ DACZ
}


// dacx_dcs_write_adrs
void pgu_dacx_dcs_write_adrs(u32 adrs) {
	pgu_dacx_dat_write(adrs, 16);
}

// dacx_dcs_read_adrs
u32  pgu_dacx_dcs_read_adrs() {
	return pgu_dacx_dat_read(17);
}

// dacx_dcs_write_data_dac0
void pgu_dacx_dcs_write_data_dac0(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 18);
}

// dacx_dcs_read_data_dac0
u32  pgu_dacx_dcs_read_data_dac0() {
	return pgu_dacx_dat_read(19);
}

// dacx_dcs_write_data_dac1
void pgu_dacx_dcs_write_data_dac1(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 20);
}

// dacx_dcs_read_data_dac1
u32  pgu_dacx_dcs_read_data_dac1() {
	return pgu_dacx_dat_read(21);
}


// dacx_dcs_run_test
void pgu_dacx_dcs_run_test() {
	pgu_dacx_dat_write(0, 22);
}


// dacx_dcs_stop_test
void pgu_dacx_dcs_stop_test() {
	pgu_dacx_dat_write(0, 23);
}


// dacx_dcs_write_repeat
void pgu_dacx_dcs_write_repeat(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 24);
}

// dacx_dcs_read_repeat
u32  pgu_dacx_dcs_read_repeat() {
	return pgu_dacx_dat_read(25);
}

// dac0_fifo_write_data
	// see // data_count =  dev.WriteToPipeIn(pi, bdata) # (ep, bdata)  in dac0_fifo_write_data()
	// see // write_mcs_ep_pi_data 
	// see // write_mcs_ep_pi_buf // for dac0_fifo_write_buf to be.
void pgu_dac0_fifo_write_data(u32 val_b32) {
	// call pipe-in data 
	write_mcs_ep_pi_data(MCS_EP_BASE, EP_ADRS_PGU__DAC0_DAT_PI, val_b32);
}
// dac1_fifo_write_data
void pgu_dac1_fifo_write_data(u32 val_b32) {
	// call pipe-in data 
	write_mcs_ep_pi_data(MCS_EP_BASE, EP_ADRS_PGU__DAC1_DAT_PI, val_b32);
}

// dacx_fdcs_run_test
void pgu_dacx_fdcs_run_test() {
	pgu_dacx_dat_write(0, 28);
}
// dacx_fdcs_stop_test
void pgu_dacx_fdcs_stop_test() {
	pgu_dacx_dat_write(0, 29);
}

// dacx_fdcs_write_repeat
void pgu_dacx_fdcs_write_repeat(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 30);
}
// dacx_fdcs_read_repeat
u32  pgu_dacx_fdcs_read_repeat() {
	return pgu_dacx_dat_read(31);
}

// TODO: pgu_dacx__write_control
void pgu_dacx__write_control(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 4);
}

// TODO: pgu_dacx__read_status
u32  pgu_dacx__read_status() {
	// in h_BC_20_0309
	// wire w_write_control = i_trig_dacx_ctrl[4]; //$$
	// wire w_read_status   = i_trig_dacx_ctrl[5]; //$$ <--
	return pgu_dacx_dat_read(5); //$$ 4-->5 // not work with h_BC_20_0309
	//$$return pgu_dacx_dat_read(4); //$$ only for AUX IO test image // OK with h_BC_20_0309
}

// dacx_fdcs_write_repeat
void pgu_dacx__write_rep_period(u32 val_b32) {
	pgu_dacx_dat_write(val_b32, 6);
}
// dacx_fdcs_read_repeat
u32  pgu_dacx__read_rep_period() {
	return pgu_dacx_dat_read(7);
}


// setup DACX 
u32  pgu_dacx_pg_setup() {
	
	// ## setup DCS configuration and data 
	// pgu.dacx_dcs_write_adrs     (0x00000000)
	// pgu.dacx_dcs_write_data_dac0(0x3FFF0008)
	// pgu.dacx_dcs_write_data_dac1(0x3FFF0002)
	pgu_dacx_dcs_write_adrs(0);
	pgu_dacx_dcs_write_data_dac0(0x3FFF0008);
	pgu_dacx_dcs_write_data_dac1(0x3FFF0002);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000001)
	// pgu.dacx_dcs_write_data_dac0(0x7FFF0010)
	// pgu.dacx_dcs_write_data_dac1(0x7FFF0004)
	pgu_dacx_dcs_write_adrs(1);
	pgu_dacx_dcs_write_data_dac0(0x7FFF0010);
	pgu_dacx_dcs_write_data_dac1(0x7FFF0004);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000002)
	// pgu.dacx_dcs_write_data_dac0(0x3FFF0008)
	// pgu.dacx_dcs_write_data_dac1(0x3FFF0002)
	pgu_dacx_dcs_write_adrs(2);
	pgu_dacx_dcs_write_data_dac0(0x3FFF0008);
	pgu_dacx_dcs_write_data_dac1(0x3FFF0002);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000003)
	// pgu.dacx_dcs_write_data_dac0(0x00000004)
	// pgu.dacx_dcs_write_data_dac1(0x00000001)
	pgu_dacx_dcs_write_adrs(3);
	pgu_dacx_dcs_write_data_dac0(0x00000004);
	pgu_dacx_dcs_write_data_dac1(0x00000001);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000004)
	// pgu.dacx_dcs_write_data_dac0(0xC0000008)
	// pgu.dacx_dcs_write_data_dac1(0xC0000002)
	pgu_dacx_dcs_write_adrs(4);
	pgu_dacx_dcs_write_data_dac0(0xC0000008);
	pgu_dacx_dcs_write_data_dac1(0xC0000002);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000005)
	// pgu.dacx_dcs_write_data_dac0(0x80000010)
	// pgu.dacx_dcs_write_data_dac1(0x80000004)
	pgu_dacx_dcs_write_adrs(5);
	pgu_dacx_dcs_write_data_dac0(0x80000010);
	pgu_dacx_dcs_write_data_dac1(0x80000004);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000006)
	// pgu.dacx_dcs_write_data_dac0(0xC0000008)
	// pgu.dacx_dcs_write_data_dac1(0xC0000002)
	pgu_dacx_dcs_write_adrs(6);
	pgu_dacx_dcs_write_data_dac0(0xC0000008);
	pgu_dacx_dcs_write_data_dac1(0xC0000002);
	// #
	// pgu.dacx_dcs_write_adrs     (0x00000007)
	// pgu.dacx_dcs_write_data_dac0(0x00000004)
	// pgu.dacx_dcs_write_data_dac1(0x00000001)
	pgu_dacx_dcs_write_adrs(7);
	pgu_dacx_dcs_write_data_dac0(0x00000004);
	pgu_dacx_dcs_write_data_dac1(0x00000001);
	// #
	// 
	// ## DCS test repeat setup 
	// #pgu.dacx_dcs_write_repeat  (0x00000000)
	// pgu.dacx_dcs_write_repeat  (0x00040001)	
	pgu_dacx_dcs_write_repeat(0x00040001);
	
	return 0;
}


//}


#endif
//}






































