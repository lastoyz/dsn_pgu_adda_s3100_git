//$$ s3100_mcs_lan_eps.c
//$$   main top for S3100-CPU-BASE to run MCS (microblaze controller system) with LAN end-point system

#include "microblaze_sleep.h" // for usleep()

#include "xil_printf.h" // print() for pure string; xil_printf() for formatted string
#include "BOARD_BASE_LIB/xil_sprintf.h" // modified from // https://gist.github.com/raczben/a8b5410440b601ce6e7d64fd96b2d79d

#include "BOARD_BASE_LIB/platform.h"

#include "BOARD_BASE_LIB/mcs_io_bridge_ext.h" //$$ board dependent // LAN and EPS control

#include "BOARD_BASE_LIB/ioLibrary/Ethernet/W5500/w5500.h" // for w5500 io functions
#include "BOARD_BASE_LIB/ioLibrary/Ethernet/socket.h"	// Just include one header for WIZCHIP // for close(SOCK_TCPS) and disconnect(SOCK_TCPS)

//$$ SCPI vs loopback socket
//#define _TEST_LOOPBACK_
#define _TEST_SCPI_

#ifdef _TEST_LOOPBACK_
#include "BOARD_BASE_LIB/ioLibrary/Appmod/Loopback/loopback.h"
#endif

#ifdef _TEST_SCPI_
#include "BOARD_BASE_LIB/ioLibrary/Appmod/Loopback/scpi.h" // for scpi server
#endif


/////////////////////////////////////////
// SOCKET NUMBER DEFINION for Examples //
/////////////////////////////////////////
#define SOCK_TCPS        0

////////////////////////////////////////////////
// Shared Buffer Definition                   //
////////////////////////////////////////////////
#ifdef _TEST_LOOPBACK_
uint8_t gDATABUF[DATA_BUF_SIZE]; // DATA_BUF_SIZE from loopback.h // -->bss
#endif
#ifdef _TEST_SCPI_
uint8_t gDATABUF[DATA_BUF_SIZE_SCPI]; // DATA_BUF_SIZE_SCPI from scpi.h // -->bss
#endif


///////////////////////////////////
// Default Network Configuration //
///////////////////////////////////
// to be updated by HW info
wiz_NetInfo gWIZNETINFO = { .mac = {0x00, 0x08, 0xdc,0x00, 0xab, 0xcd},
							.ip = {192, 168, 168, 143},
							.sn = {255,255,255,0},
							.gw  = {0,0,0,0},
							.dns = {0,0,0,0},
							.dhcp = NETINFO_STATIC };
wiz_NetInfo gWIZNETINFO_rb; // read back

// set LAN timeout parameters
u16 gWIZNET_RTR = 4000; // 2000; // setRTR(2000); // retry time based on 100us unit time.
u16 gWIZNET_RCR = 46  ; // 23  ; // setRCR(23);   // retry count

// network IC buf size : W5500 ... TX 16KB and RX 16KB
uint8_t gMEMSIZE[2][8] = {{16,0,0,0,0,0,0,0},{16,0,0,0,0,0,0,0}}; // KB

// dummy variable
uint8_t g_tmp_u8;
int32_t g_tmp_s32;

//////////////////////////////////
// For example of ioLibrary_BSD //
//////////////////////////////////
uint8_t network_init(void);								// Initialize Network information and display it
//////////////////////////////////

//// EEPROM test mem 
uint8_t gEEPROM[2048];

int main(void)
{	
	//// for low-level driver test
	//u32 adrs;
	u32 value;
	//u32 mask;
	//u32 ii;
	u8 *p_tmp_u8;
	u8 tmp_buf[0x80];


	///////////////////////////////////////////
	// Host dependent peripheral initialized //
	///////////////////////////////////////////
	init_platform();

	//// test setup for print on jtag-terminal // stdio with mdm //{
	//xil_printf("> Go MHVSU BASE!! \r\n");
	//xil_printf("> Go CMU-CPU-F5500 with LAN support!! \r\n");
	//xil_printf("> Go PGU-CPU-F5500 with LAN support!! \r\n");
	xil_printf("> Go S3100-CPU-BASE with LAN support!! \r\n");

	xil_printf(">>> build_info: ["__TIME__"],[" __DATE__ "]\r\n");
#ifdef  _SCPI_DEBUG_
	xil_printf(">> _SCPI_DEBUG_ mode enabled \r\n");
#endif
	//}



	//// TODO: board basic controls --------////

	//// test  mcs_io_bridge.v called in lan_endpoint_wrapper.v //{
	xil_printf(">> test mcs_io_bridge.v \r\n");

	// reset all MASK : ADRS_MASK_ALL__
	_test_write_mcs(">>> set MASK for WI: \r\n",     ADRS_MASK_ALL__, 0xFFFFFFFF);

	// test read ADRS_FPGA_IMAGE
	_test_read_mcs(">>> FPGA_IMAGE_ID: \r\n", ADRS_FPGA_IMAGE);
	
	// MCS access enable  // BRD_CON // ADRS_PORT_WI_03 --> ADRS_PGU__BRD_CON
	_test_write_mcs(">>> enable MCS control : \r\n", ADRS_PGU__BRD_CON, 0x00003F00);
	
	// test read FPGA_IMAGE_ID from mcs endpoint WO_20 // FPGA_IMAGE_ID // ADRS_PORT_WO_20
	_test_read_mcs(">>> FPGA_IMAGE_ID from ADRS_PGU__FPGA_IMAGE_ID : \r\n", ADRS_PGU__FPGA_IMAGE_ID);
	
	// clear test : TEST_CON // ADRS_PORT_WI_01 --> ADRS_PGU__TEST_CON
	_test_write_mcs(">>>clear test control: \r\n",   ADRS_PGU__TEST_CON, 0x00000000);
		
	//}

	//// test reg on lan logic //{
	xil_printf(">> test ADRS_TEST_REG__ \r\n");
	value = read_mcs_io (ADRS_TEST_REG__);
	if (value==0xACACCDCD) // reset pattern : 0xACACCDCD
		value = 0;
	else 
		value += 1; // count up every process start
	value = write_mcs_io(ADRS_TEST_REG__, value);
	value = read_mcs_io (ADRS_TEST_REG__);
	xil_printf("mcs rd: 0x%08X \r\n", value );
	
	//}
	
	//// test read  MON_XADC_WO or temperature // ADRS_PORT_WO_3A --> ADRS_PGU__XADC_TEMP //{
	_test_read_mcs(">>> read ADRS_PGU__XADC_TEMP : \r\n", ADRS_PGU__XADC_TEMP);
	value = read_mcs_io (ADRS_PGU__XADC_TEMP);
	xil_printf("mcs rd: %d \r\n", value );
	//}
	
	//// test counters //{
	
	xil_printf(">>> test count2 \r\n");
	
	// read_mcs_ep_to @ 0x61 --> 0x60 //$$ TEST_TO --> EP_ADRS_PGU__TEST_TO
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	// read  : test counts at WO21  // TEST_OUT --> EP_ADRS_PGU__TEST_OUT
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );

	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	// TEST_TI // ti40 --> EP_ADRS_PGU__TEST_TI
	activate_mcs_ep_ti(MCS_EP_BASE,EP_ADRS_PGU__TEST_TI,0); // reset : test count2 TI40[0] 
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );
	
	//
	activate_mcs_ep_ti(MCS_EP_BASE,EP_ADRS_PGU__TEST_TI,1); // up    : test count2 TI40[1] 
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );
	//
	activate_mcs_ep_ti(MCS_EP_BASE,EP_ADRS_PGU__TEST_TI,2); // down  : test count2 TI40[2] 
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );
	
	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	//
	activate_mcs_ep_ti(MCS_EP_BASE,EP_ADRS_PGU__TEST_TI,2); // down  : test count2 TI40[2] 
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );

	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	//
	activate_mcs_ep_ti(MCS_EP_BASE,EP_ADRS_PGU__TEST_TI,1); // up    : test count2 TI40[1] 
	value = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS_PGU__TEST_OUT, 0x0000FFFF); // TEST_OUT
	xil_printf("WO21 rd: 0x%08X \r\n", value );

	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	// read_mcs_ep_to @ 0x61 --> 0x60 
	//   assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
	value = read_mcs_ep_to(MCS_EP_BASE, EP_ADRS_PGU__TEST_TO, 0xFFFFFFFF); //$$ TEST_TO
	xil_printf("TO60 rd: 0x%08X \r\n", value );

	// test count :  set autocount2 // TEST_CON // ADRS_PORT_WI_01 --> MCS_EP_BASE + EP_ADRS_PGU__TEST_CON
	xil_printf(">>> test count :  set autocount2 \r\n");
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000000, 0x00000004); // adrs_base, EP_offset_EP, data, mask
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000004, 0x00000004); // adrs_base, EP_offset_EP, data, mask
	
	//}

	//// TODO: test eeprom : 11AA160T-I/TT //{
		
	xil_printf(">>> test eeprom  \r\n");
	
	// test call eeprom functions in mcs_io_bridge_ext.h //{
	
	// test ep // clear wires
	eeprom_send_frame_ep(0,0); // (u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32)
	
	// select EEPROM on BASE
	value = eeprom_set_g_var(1,0); // (u8 EEPROM__LAN_access, u8 EEPROM__on_TP)
	xil_printf("> eeprom_set_g_var: 0x%08X \r\n", value );
	
	// select EEPROM on TP
	value = eeprom_set_g_var(1,1); // (u8 EEPROM__LAN_access, u8 EEPROM__on_TP)
	xil_printf("> eeprom_set_g_var: 0x%08X \r\n", value );

	// eeprom_read_status
	eeprom_send_frame(0x05, 0, 0, 0, 1, 0); // (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);

	// read status
	value = eeprom_read_status();
	xil_printf("> eeprom_read_status: 0x%08X \r\n", value );
	
	//}
	
	// check and switch connection //{
	eeprom_set_g_var(1, 0); // # EEPROM on MEM_SIO (MHVSU_BASE) or FPGA_IO_A (EXT-CMU)
	if (is_eeprom_available()) {
		xil_printf(">> EEPROM on BASE is available. \r\n");
	}
	else {
		eeprom_set_g_var(1, 1); // # EEPROM on TP
		if (is_eeprom_available()) {
			xil_printf(">> EEPROM on TP is available. \r\n");
		}
		else {
			xil_printf(">> EEPROM is NOT available. \r\n");
		}
	}
	
	//}
	
	//// test eeprom_erase_all()
//#define _TEST__EEPROM_ERASE_ALL_
#ifdef _TEST__EEPROM_ERASE_ALL_
	eeprom_erase_all();
#endif 	

	//// test eeprom_set_all()
//#define _TEST__EEPROM_SET_ALL_
#ifdef _TEST__EEPROM_SET_ALL_
	eeprom_set_all();
#endif 	
	
	// test functions about check sum //{
	value = cal_checksum (32, (u8*)"1234567812345678test try good~!!");
	xil_printf("cal_checksum: 0x%02X \r\n", value );
	value = gen_checksum (32, (u8*)"1234567812345678test try good~!!");
	xil_printf("gen_checksum: 0x%02X \r\n", value );
	// test hex display
	hex_txt_display (32, (u8*)"1234567812345678test try good~!!", 0x0020); // (s16 len_b16, u8 *p_mem_data, u32 adrs_offset)	
	//}

	//// eeprom header renewal 
	
//#define _TEST__EEPROM_HEADER_RENEWAL_
#ifdef _TEST__EEPROM_HEADER_RENEWAL_

	// 000  0x0000  43 4D 55 5F 43 50 55 5F  4C 41 4E 23 30 31 30 31  PGU_CPU_ LAN#0101 // info_txt[0:10]+'#'+BoardID_txt[0:3]
	// 001  0x0010  C0 A8 A8 8F FF FF FF 00  C0 A8 A8 01 00 00 00 00  ........ ........ // SIP[0:3]+SUB[0:3]+GAR[0:3]+DNS[0:3]
	// 002  0x0020  30 30 30 38 44 43 30 30  41 43 33 32 31 35 24 31  0008DC00 AC3215$1 // MAC_txt[0:11]+SlotID_txt[0:1]+UserID[0]+CKS[0]
	// 003  0x0030  2D 5F 2D 5F 2D 2D 5F 5F  2D 5F 2D 5F 2D 2D 5F 5F  -_-_--__ -_-_--__	 // test_txt[0:15]
	
	// input para :
	
	//u32 BoardID = 101; // EEPROM on TP
	//u32 SlotID  =  15; // EEPROM on TP

	//u32 BoardID = 110+4; // CMU-CPU-F5500 #4
	//u32 SlotID  =     4; // CMU-CPU-F5500 #4
	
	//u32 BoardID = 110+7; // CMU-CPU-F5500 #7
	//u32 SlotID  =     7; // CMU-CPU-F5500 #7
	
	//u32 BoardID = 110+15; // CMU-CPU-F5500 #15
	//u32 SlotID  =     15; // CMU-CPU-F5500 #15

	u32 BoardID = 210+15; // PGU-CPU-F5500 #15
	u32 SlotID  =     15; // PGU-CPU-F5500 #15

	//   info_txt[0:10]  
	u8* info_txt = (u8*)"PGU_CPU_LAN"; // + sentinel
	
	//   BoardID_txt[0:3]
	//... see line 0
	
	
	// note CMU base ip  : 192.168.100.16, 192.168.100.80,  192.168.168.80
	// note CMU base MAC : "0008DC00AB00"
	
	// note PGU base ip  : 192.168.100.48, 192.168.100.112, 192.168.168.112
	// note PGU base MAC : "0008DC00CD00"
	
	//   SIP[0:3]
	u8 eeprom_SIP[4] = {192,168,100,112}; // will add SlotID to eeprom_SIP[3]
	//   SUB[0:3]
	u8 eeprom_SUB[4] = {255,255,255,  0};
	//   GAR[0:3]       
	u8 eeprom_GAR[4] = {  0,  0,  0,  0};
	//   DNS[0:3]       
	u8 eeprom_DNS[4] = {  0,  0,  0,  0};
	//
	eeprom_SIP[3] += SlotID;
	
	//   MAC_txt[0:11]
	//u8* MAC_txt = (u8*)"0008DC00ABCD"; // + sentinel // will add BoardID
	u8 MAC_txt[12];// will add BoardID
	xil_sprintf((char*)MAC_txt, "%s%08X", (char *)"0008", (unsigned int)0XDC00ABCD+BoardID);
	//   SlotID_txt[0:1]
	//...
	//   UserID[0]
	u8 UserID = '$';
	//   CKS[0]
	u8 CKS = 0;

	
	
	//   test_txt[0:15]
	u8* test_txt = (u8*)"-_-_--__-_-_--__"; // + sentinel

	// write header
	//...
	//eeprom_write_data (0x0000, 16, (u8*)"CMU_CPU_LAN#0100"); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	
	// line 0
	xil_sprintf((char*)tmp_buf, "%.11s%c%04d", (char*)info_txt, (char)'#', (unsigned int)BoardID);
	eeprom_write_data (0x0000, 16, (u8*)tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)

	// line 1
	//mcopy(void *dest, const void *src, size_t n);
	mcopy(&tmp_buf[ 0], eeprom_SIP, 4);
	mcopy(&tmp_buf[ 4], eeprom_SUB, 4);
	mcopy(&tmp_buf[ 8], eeprom_GAR, 4);
	mcopy(&tmp_buf[12], eeprom_DNS, 4);
	eeprom_write_data (0x0010, 16, (u8*)tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	
	// line 2
	xil_sprintf((char*)tmp_buf, "%.12s%02d%c%c", (char*)MAC_txt, (unsigned int)SlotID, (char)UserID , (char)CKS);
	eeprom_write_data (0x0020, 16, (u8*)tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	// re-calculate check sum
	eeprom_read_data (0x0010, 16*2, tmp_buf);
	value = cal_checksum (32, tmp_buf); // 
	xil_printf("cal_checksum of EEPROM[0x10:0x2F] = 0x%02X \r\n", value );
	tmp_buf[0x1F]-=value;
	value = cal_checksum (32, tmp_buf); // 
	xil_printf("re-cal_checksum of EEPROM[0x10:0x2F] = 0x%02X \r\n", value );
	eeprom_write_data (0x0010, 32, (u8*)tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)

	// line 3
	eeprom_write_data (0x0030, 16, (u8*)test_txt); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)

	

	// read header
	eeprom_read_data (0x0000, 16*4, tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout)
	hex_txt_display (16*4, tmp_buf, 0x0000);
	
#endif 	
	

//#define _TEST__EEPROM_WRITE_
#ifdef _TEST__EEPROM_WRITE_
	// test read all from EEPROM to g_EEPROM__buf_2KB
	eeprom_read_all();
	p_tmp_u8 = get_adrs__g_EEPROM__buf_2KB();
	hex_txt_display (16*4, p_tmp_u8, 0x0000);
	
	// test eeprom write 
	eeprom_write_data (0x0030, 2, (u8*)"?!"); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	eeprom_read_data (0x0000, 16*4, tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout)
	hex_txt_display (16*4, tmp_buf, 0x0000);
#endif 	
	

	// read eeprom //{

	eeprom_read_all();
	p_tmp_u8 = get_adrs__g_EEPROM__buf_2KB();
	eeprom_read_data (0x0000, 16*4, tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout)
	hex_txt_display (2048, p_tmp_u8, 0x0000);
	

	//}


#define _NET_INIT_FROM_EEPROM_ 
#ifdef _NET_INIT_FROM_EEPROM_

	// EEPROM header check 
	eeprom_read_all();
	p_tmp_u8 = get_adrs__g_EEPROM__buf_2KB();
	value = cal_checksum (32, &p_tmp_u8[0x10]); // 
	xil_printf("cal_checksum in g_EEPROM[0x10:0x2F] : 0x%02X \r\n", value );

	if (value==0) {
		
		value = chk_all_zeros (32, &p_tmp_u8[0x10]); // 
		xil_printf("chk_all_zeros in g_EEPROM[0x10:0x2F] : 0x%02X \r\n", value );
		
		if (value == 0) { // not all zero
		
			//// update IP/MAC ...
			//   SIP = [192,168,168,143]
			//   SUB = [255,255,255,  0]
			//   GAR = [192,168,168,  1]
			//   DNS = [  0,  0,  0,  0]
			//   MAC = '0008dc00abcd'
			//   SID = '06'
			//   UID = '$'
			//   CKS = '#'

			gWIZNETINFO.ip[0]  = p_tmp_u8[0x10];
			gWIZNETINFO.ip[1]  = p_tmp_u8[0x11];
			gWIZNETINFO.ip[2]  = p_tmp_u8[0x12];
			gWIZNETINFO.ip[3]  = p_tmp_u8[0x13];
			//
			gWIZNETINFO.sn[0]  = p_tmp_u8[0x14];
			gWIZNETINFO.sn[1]  = p_tmp_u8[0x15];
			gWIZNETINFO.sn[2]  = p_tmp_u8[0x16];
			gWIZNETINFO.sn[3]  = p_tmp_u8[0x17];
			//
			gWIZNETINFO.gw[0]  = p_tmp_u8[0x18];
			gWIZNETINFO.gw[1]  = p_tmp_u8[0x19];
			gWIZNETINFO.gw[2]  = p_tmp_u8[0x1A];
			gWIZNETINFO.gw[3]  = p_tmp_u8[0x1B];
			//
			gWIZNETINFO.dns[0] = p_tmp_u8[0x1C];
			gWIZNETINFO.dns[1] = p_tmp_u8[0x1D];
			gWIZNETINFO.dns[2] = p_tmp_u8[0x1E];
			gWIZNETINFO.dns[3] = p_tmp_u8[0x1F];
			//
			gWIZNETINFO.mac[0] = hexstr2data_u32(&p_tmp_u8[0x20],2);
			gWIZNETINFO.mac[1] = hexstr2data_u32(&p_tmp_u8[0x22],2);
			gWIZNETINFO.mac[2] = hexstr2data_u32(&p_tmp_u8[0x24],2);
			gWIZNETINFO.mac[3] = hexstr2data_u32(&p_tmp_u8[0x26],2);
			gWIZNETINFO.mac[4] = hexstr2data_u32(&p_tmp_u8[0x28],2);
			gWIZNETINFO.mac[5] = hexstr2data_u32(&p_tmp_u8[0x2A],2);
		
			xil_printf(">> MAC and IP are set by EEPROM info. \r\n");
			
			//// update SID and BID into MCS_SETUP_WI @ WI11 --> wi19
			// WI11 :
			//   bit [31:16] = board ID // 0000~9999, set from EEPROM via MCS
			//   bit [10]    = select__L_LAN_on_FPGA_MD__H_LAN_on_BASE_BD // set from MCS
			//   bit [9]     = w_con_port__L_MEM_SIO__H_TP                // set from MCS
			//   bit [8]     = w_con_fifo_path__L_sspi_H_lan              // set from MCS
			//   bit [3:0]   = slot ID  // 00~99, set from EEPROM via MCS
			//_test_write_mcs(">>> set BID and SID: \r\n", ADRS_PORT_WI_11_MHVSU, 
			_test_write_mcs(">>> set BID and SID: \r\n", ADRS_PORT_WI_19, 
				//(p_tmp_u8[0x0E]<<24) + (p_tmp_u8[0x0F]<<16) +  // BID
				(decstr2data_u32(&p_tmp_u8[0x0C],4)<<16) + // BID
				 decstr2data_u32(&p_tmp_u8[0x2C],2)        // SID
				);
			//_test_read_mcs (">>> get BID and SID: \r\n", ADRS_PORT_WI_11_MHVSU);
			_test_read_mcs (">>> get BID and SID: \r\n", ADRS_PORT_WI_19);
			
			xil_printf(">> BID and SID are set by EEPROM info. \r\n");
			
		}
		else {
		xil_printf(">>> all-zero header is ignored. \r\n");
		}
	}
	else {
		xil_printf(">>> check sum error! eeprom header ignored. \r\n");
	}


#endif 	
	

	//// TODO: eeprom control back to USB control or not //{

	//eeprom_set_g_var(0, 0); // (u8 EEPROM__LAN_access, u8 EEPROM__on_TP)

	// force LAN control and EEPROM on BOARD
	eeprom_set_g_var(1, 0); // (u8 EEPROM__LAN_access, u8 EEPROM__on_TP)

	//}
	
	//}



	//// TODO: PGU start up --------////
	
	//// note : PGU initialization comes with the command of ":PGU:PWR ON\n"
	
	//// PGU led control //{
	// test on
	// pgu.spio_ext__pwr_led(led=1,pwr_dac=1,pwr_adc=0,pwr_amp=1)
	pgu_spio_ext_pwr_led(1,0,0,0);
	value = pgu_spio_ext_pwr_led_readback();
	xil_printf(">> Check LED readback: 0x%08X \r\n", value);
	// sleep
	//usleep(9000);
	usleep(300000); // 0.3s = 300ms =300000us
	// test off
	pgu_spio_ext_pwr_led(0,0,0,0);
	value = pgu_spio_ext_pwr_led_readback();
	xil_printf(">> Check LED readback: 0x%08X \r\n", value);
	//}
	
	//// PGU AUX IO //{
	// PGU AUX IO initialization
	
	// setup io direction and idle state
	pgu_spio_ext__aux_init(); //
	pgu_spio_ext__aux_idle(); //
	//}
	

	
	//// TODO: LAN start up --------////

	//// TODO: end-point control back to USB //{
	
	// dedicated LAN is always available to MCS.
	// MCS_SETUP_WI (wi19) is also always available to MCS.
	// TEST_CON (wi01) is controlled by MCS_SETUP_WI.
	
	// reset all MASK : ADRS_MASK_ALL__
	_test_write_mcs(">>> set MASK for WI: \r\n",     ADRS_MASK_ALL__, 0xFFFFFFFF);

	// MCS access enable // BRD_CON // ADRS_PORT_WI_03 --> ADRS_PGU__BRD_CON
	//_test_write_mcs(">>> enable  MCS control : \r\n", ADRS_PGU__BRD_CON, 0x00003F00);
	_test_write_mcs  (">>> disable MCS control : \r\n", ADRS_PGU__BRD_CON, 0x00000000);

	// read back : return 0xACACACAC due to lost control // ADRS_PORT_WO_3A --> ADRS_PGU__XADC_TEMP
	_test_read_mcs(">>> read ADRS_PGU__XADC_TEMP : \r\n", ADRS_PGU__XADC_TEMP);
	
	value = read_mcs_io (ADRS_PGU__BRD_CON);
	xil_printf("mcs rd: %d \r\n", value );
	
	//}

	//// select LAN-on-BASE first //{
	
	//$$ MCS_SETUP_WI // wi19 --> EP_ADRS_PGU__MCS_SETUP_WI
	xil_printf(">>>LAN-on-BASE selected: \r\n");
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__MCS_SETUP_WI, 0x00000400, 0x00000400); // MCS_SETUP_WI // wi19
	
	//}

	//// hw reset wz850 //{
	xil_printf(">>> hw reset wz850 \r\n");
	hw_reset__wz850();
	//}
	
	//// socket setup //{

	//// check ID 
	//
	// VERSIONR (W5500 Chip Version Register) [R] [0x0039] [0x04]
	// #define VERSIONR           (_W5500_IO_BASE_ + (0x0039 << 8) + (WIZCHIP_CREG_BLOCK << 3))
	// #define getVERSIONR()      WIZCHIP_READ(VERSIONR)
	//
	// VERSIONR (W5200 Chip Version Register)[R][0x001F][0x03]
	// note that W5200 has different SPI frame format. Not supported.
	// 

	u8 tmp_ver_u8;
	u8 tmp_buf_init_u8;
	u8 tmp_net_init_u8;

	tmp_ver_u8 = getVERSIONR(); // no device: 0xFF, W5200: 0x00, W5500: 0x04
	tmp_buf_init_u8 = ctlwizchip(CW_INIT_WIZCHIP,(void*)gMEMSIZE); /* WIZCHIP SOCKET Buffer initialize */
	tmp_net_init_u8 = network_init(); /* Network initialization */
	ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8); /* PHY link status check */

	xil_printf("VERSIONR: %d (0x%02X) \r\n", tmp_ver_u8, tmp_ver_u8);
	
	if (tmp_ver_u8 != 0x04) {
		// stay here : no LAN setup due to no W5500 chip found.
		// USB end-points are available.
		////xil_printf("VERSIONR: %d (0x%02X) \r\n", g_tmp_u8, g_tmp_u8);
	    xil_printf("> no W5500 chip is found. \r\n");
		//while (1);
	}
	
	if(tmp_buf_init_u8 == (u8)(-1)) {
	    xil_printf("> WIZCHIP BUF Initialization failed. \r\n");
	   //while(1);
	}

	if(tmp_net_init_u8 == (u8)(-1)) {
	    xil_printf("> WIZCHIP Network Initialization failed. \r\n");
	   //while(1);
	}

	if(g_tmp_u8 == (u8)(-1))
	    xil_printf("Unknown PHY Link status. \n");


	if ((tmp_ver_u8 != 0x04)||(tmp_buf_init_u8 == -1)||(tmp_net_init_u8 == -1)) {
		xil_printf(">> LAN is not PRESENT, or MAC is not allowed. \r\n");
		//while(1) ; // stop here
		
		//// try LAN-on-FPGA
		xil_printf(">>>LAN-on-FPGA selected: \r\n");
		write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__MCS_SETUP_WI, 0x00000000, 0x00000400); // MCS_SETUP_WI // wi19
		
		hw_reset__wz850();

		tmp_ver_u8 = getVERSIONR(); // no device: 0xFF, W5200: 0x00, W5500: 0x04
		tmp_buf_init_u8 = ctlwizchip(CW_INIT_WIZCHIP,(void*)gMEMSIZE); /* WIZCHIP SOCKET Buffer initialize */
		tmp_net_init_u8 = network_init(); /* Network initialization */
		ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8); /* PHY link status check */

		xil_printf("VERSIONR: %d (0x%02X) \r\n", tmp_ver_u8, tmp_ver_u8);

		if (tmp_ver_u8 != 0x04) {
			// stay here : no LAN setup due to no W5500 chip found.
			// USB end-points are available.
			////xil_printf("VERSIONR: %d (0x%02X) \r\n", g_tmp_u8, g_tmp_u8);
		    xil_printf("> no W5500 chip is found. \r\n");
			//while (1);
		}

		if(tmp_buf_init_u8 == (u8)(-1)) {
		    xil_printf("> WIZCHIP BUF Initialization failed. \r\n");
		   //while(1);
		}

		if(tmp_net_init_u8 == (u8)(-1)) {
		    xil_printf("> WIZCHIP Network Initialization failed. \r\n");
		   //while(1);
		}

		if(g_tmp_u8 == (u8)(-1))
		    xil_printf("Unknown PHY Link status. \n");

		if ((tmp_ver_u8 != 0x04)||(tmp_buf_init_u8 == -1)||(tmp_net_init_u8 == -1)) {
			while(1); // stay here due to no lan on ports
		}
	}
	
	//// network initialized
	// turn on running LED // only if MCS is enabled
	write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000004, 0x00000004); // TEST_CON // wi01


	/* PHY link check */
	ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
	if (g_tmp_u8 == PHY_LINK_OFF) {
		xil_printf(">>> PHY_LINK_OFF \r\n");
		// close socket
		close(SOCK_TCPS);
		//disconnect(SOCK_TCPS); // hanging; must remove.
		
		// turn off running LED 
		write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000000, 0x00000004); // TEST_CON // wi01
	
		// wait for PHY_LINK_ON
		do
		{
			ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
		}while(g_tmp_u8 == PHY_LINK_OFF);
	
		// turn on running LED 
		write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000004, 0x00000004); // TEST_CON // wi01


		// re-init network
		network_init(); 
		
	}

	//}
	

	/*****************************************/
	/* WIZnet W5500 inside                   */
	/*****************************************/


#ifdef _TEST_LOOPBACK_
	/* TODO: Main loop for TCP Loopback test */
	while(1)
	{
		/* Loopback Test */
		// TCP server loopback test
		if( (g_tmp_s32 = loopback_tcps(SOCK_TCPS, gDATABUF, 5025)) < 0) {
			xil_printf("SOCKET ERROR : %ld \n", g_tmp_s32);
		}

		// UDP server loopback test
		// if( (g_tmp_s32 = loopback_udps(SOCK_UDPS, gDATABUF, 3000)) < 0) {
		// 	xil_printf("SOCKET ERROR : %ld \n", g_tmp_s32);
		// }

		/* PHY link check */
		ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
		if (g_tmp_u8 == PHY_LINK_OFF) {
			xil_printf(">>> PHY_LINK_OFF \r\n");
			// close socket
			close(SOCK_TCPS);
			//disconnect(SOCK_TCPS); // hanging; must remove.
			
			// turn off running LED 
			write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000000, 0x00000004); // TEST_CON // wi01
		
			// wait for PHY_LINK_ON
			do
			{
				ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
			}while(g_tmp_u8 == PHY_LINK_OFF);
		
			// turn on running LED 
			write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000004, 0x00000004); // TEST_CON // wi01
	
			// re-init network
			network_init(); 
		}

	} // end of Main loop
#endif


#ifdef _TEST_SCPI_
	/* TODO: Main loop for TCP socket based SCPI server test */
	while(1)
	{
		//  /* SCPI server Test */
		// if( (g_tmp_s32 = scpi_tcps_ep_state(SOCK_TCPS, gDATABUF, 5025)) < 0) {
		// 	xil_printf("SOCKET ERROR : %ld \n", g_tmp_s32);
		// }
	
		//  /* SCPI server Test : eps */
		if( (g_tmp_s32 = scpi_tcps_ep(SOCK_TCPS, gDATABUF, 5025)) < 0) {
			xil_printf("SOCKET ERROR : %ld \n", g_tmp_s32);
		}
	
		/* PHY link check */
		ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
		if (g_tmp_u8 == PHY_LINK_OFF) {
			xil_printf(">>> PHY_LINK_OFF \r\n"); 
			// close socket
			close(SOCK_TCPS);
			//disconnect(SOCK_TCPS); // hanging; must remove.
			
			// turn off running LED 
			write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000000, 0x00000004); // TEST_CON // wi01
		
			// wait for PHY_LINK_ON
			do
			{
				ctlwizchip(CW_GET_PHYLINK, (void*)&g_tmp_u8);
			}while(g_tmp_u8 == PHY_LINK_OFF);
		
			// turn on running LED 
			write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__TEST_CON, 0x00000004, 0x00000004); // TEST_CON // wi01
	
			// re-init network
			network_init(); 
		}
	
	} // end of Main loop
#endif

    /////
    cleanup_platform();

    // TODO: stay
    //while(1);

} // end of main()

/////////////////////////////////////////////////////////////
// Initialize the network information to be used in WIZCHIP //
/////////////////////////////////////////////////////////////
uint8_t network_init(void)
{
	uint8_t tmpstr[6];
	uint8_t ret;
	
	// set
	ctlnetwork(CN_SET_NETINFO, (void*)&gWIZNETINFO);
	// get
	ctlnetwork(CN_GET_NETINFO, (void*)&gWIZNETINFO_rb);

	// set timeout para
	//setRTR(2000);
	setRTR(gWIZNET_RTR);
	//setRCR(23);
	setRCR(gWIZNET_RCR);

	// Display Network Information
	ctlwizchip(CW_GET_ID,(void*)tmpstr);
	//
	xil_printf("\r\n=== %s NET CONF === \r\n",(char*)tmpstr);
	xil_printf("MAC: %02X:%02X:%02X:%02X:%02X:%02X \r\n",
		gWIZNETINFO_rb.mac[0],gWIZNETINFO_rb.mac[1],gWIZNETINFO_rb.mac[2],
		gWIZNETINFO_rb.mac[3],gWIZNETINFO_rb.mac[4],gWIZNETINFO_rb.mac[5]);
	xil_printf("SIP: %d.%d.%d.%d \r\n", gWIZNETINFO_rb.ip[0],gWIZNETINFO_rb.ip[1],gWIZNETINFO_rb.ip[2],gWIZNETINFO_rb.ip[3]);
	xil_printf("SUB: %d.%d.%d.%d \r\n", gWIZNETINFO_rb.sn[0],gWIZNETINFO_rb.sn[1],gWIZNETINFO_rb.sn[2],gWIZNETINFO_rb.sn[3]);
	xil_printf("GAR: %d.%d.%d.%d \r\n", gWIZNETINFO_rb.gw[0],gWIZNETINFO_rb.gw[1],gWIZNETINFO_rb.gw[2],gWIZNETINFO_rb.gw[3]);
	xil_printf("DNS: %d.%d.%d.%d \r\n", gWIZNETINFO_rb.dns[0],gWIZNETINFO_rb.dns[1],gWIZNETINFO_rb.dns[2],gWIZNETINFO_rb.dns[3]);
	xil_printf("====================== \r\n");
	xil_printf("RTR: %d (0x%04X) \r\n", getRTR(), getRTR());
	xil_printf("RCR: %d (0x%04X) \r\n", getRCR(), getRCR());
	xil_printf("====================== \r\n");
	
	ret = 0;
	if ( (gWIZNETINFO_rb.mac[0]==0xFF) &&
		 (gWIZNETINFO_rb.mac[1]==0xFF) &&
		 (gWIZNETINFO_rb.mac[2]==0xFF) &&
		 (gWIZNETINFO_rb.mac[3]==0xFF) &&
		 (gWIZNETINFO_rb.mac[4]==0xFF) &&
		 (gWIZNETINFO_rb.mac[5]==0xFF) )
		ret = -1; // failed
	return ret;
	


}
/////////////////////////////////////////////////////////////


