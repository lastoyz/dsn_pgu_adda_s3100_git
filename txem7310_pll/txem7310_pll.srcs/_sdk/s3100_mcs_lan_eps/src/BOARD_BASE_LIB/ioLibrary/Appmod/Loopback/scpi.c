//#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "microblaze_sleep.h" // for usleep
#include "xil_printf.h" // print() for pure string; xil_printf() for formatted string
#include "../../../xil_sprintf.h" // modified from // https://gist.github.com/raczben/a8b5410440b601ce6e7d64fd96b2d79d

#include "../../Ethernet/socket.h"
#include "scpi.h"


#include "../../../mcs_io_bridge_ext.h" //$$ board dependent



//// scpi parameters / data //{
	
// common command
//uint8_t* cmd_str__XXX = (uint8_t*)"XXX";
uint8_t* cmd_str__IDN       = (uint8_t*)"*IDN?"; // rev for both \r\n and \n
uint8_t* cmd_str__RST       = (uint8_t*)"*RST";  // rev for both \r\n and \n
//
uint8_t* cmd_str__FPGA_FID  = (uint8_t*)":FPGA:FID?\n";
uint8_t* cmd_str__FPGA_TMP  = (uint8_t*)":FPGA:TMP?\n";

// TODO: EPS: low-level end-point access command string
uint8_t* cmd_str__EPS_EN   = (uint8_t*)":EPS:EN"; 
//
uint8_t* cmd_str__EPS_WMI  = (uint8_t*)":EPS:WMI";
uint8_t* cmd_str__EPS_WMO  = (uint8_t*)":EPS:WMO";
uint8_t* cmd_str__EPS_TAC  = (uint8_t*)":EPS:TAC";
uint8_t* cmd_str__EPS_TMO  = (uint8_t*)":EPS:TMO"; // return ON or OFF
uint8_t* cmd_str__EPS_TWO  = (uint8_t*)":EPS:TWO";  // return 32-bit word
uint8_t* cmd_str__EPS_PI   = (uint8_t*)":EPS:PI";
uint8_t* cmd_str__EPS_PO   = (uint8_t*)":EPS:PO";

uint8_t* cmd_str__MEM_MEMR           = (uint8_t*)":MEM:MEMR"; // ':MEM:MEMR #H00000058 \n'
uint8_t* cmd_str__MEM_MEMW           = (uint8_t*)":MEM:MEMW"; // ':MEM:MEMW #H0000005C #H1234ABCD \n'
//

#ifdef _SCPI_CMD_S3100_PGU_// _SCPI_CMD_PGU_ --> _SCPI_CMD_S3100_PGU_

// TODO: PGU command string 
uint8_t* cmd_str__PGU_PWR            = (uint8_t*)":PGU:PWR";
uint8_t* cmd_str__PGU_OUTP           = (uint8_t*)":PGU:OUTP";
uint8_t* cmd_str__PGU_STAT           = (uint8_t*)":PGU:STAT"; //$$
//
uint8_t* cmd_str__PGU_AUX_OUTP       = (uint8_t*)":PGU:AUX:OUTP"; //$$ previous command 
uint8_t* cmd_str__PGU_AUX_CON        = (uint8_t*)":PGU:AUX:CON" ; //$$ IOCON (@reg 0x0A)   `':PGU:AUX:CON?'`     `':PGU:AUX:CON #H0000'`
uint8_t* cmd_str__PGU_AUX_OLAT       = (uint8_t*)":PGU:AUX:OLAT"; //$$ OLAT  (@reg 0x14)   `':PGU:AUX:OLAT?'`    `':PGU:AUX:OLAT #H0000'`
uint8_t* cmd_str__PGU_AUX_DIR        = (uint8_t*)":PGU:AUX:DIR" ; //$$ IODIR (@reg 0x00)   `':PGU:AUX:DIR?'`     `':PGU:AUX:DIR #H0000'`
uint8_t* cmd_str__PGU_AUX_GPIO       = (uint8_t*)":PGU:AUX:GPIO"; //$$ GPIO  (@reg 0x12)   `':PGU:AUX:GPIO?'`    `':PGU:AUX:GPIO #H0000'`
//
uint8_t* cmd_str__PGU_MEMR           = (uint8_t*)":PGU:MEMR"; // ':PGU:MEMR #H00000058 \n'
uint8_t* cmd_str__PGU_MEMW           = (uint8_t*)":PGU:MEMW"; // ':PGU:MEMW #H0000005C #H1234ABCD \n'

//// unused
//uint8_t* cmd_str__PGU_DCS_TRIG       = (uint8_t*)":PGU:DCS:TRIG";
//uint8_t* cmd_str__PGU_DCS_DAC0_PNT   = (uint8_t*)":PGU:DCS:DAC0:PNT";
//uint8_t* cmd_str__PGU_DCS_DAC1_PNT   = (uint8_t*)":PGU:DCS:DAC1:PNT";
//uint8_t* cmd_str__PGU_DCS_RPT        = (uint8_t*)":PGU:DCS:RPT";
//uint8_t* cmd_str__PGU_FDCS_TRIG      = (uint8_t*)":PGU:FDCS:TRIG";
//uint8_t* cmd_str__PGU_FDCS_DAC0      = (uint8_t*)":PGU:FDCS:DAC0";
//uint8_t* cmd_str__PGU_FDCS_DAC1      = (uint8_t*)":PGU:FDCS:DAC1";
//uint8_t* cmd_str__PGU_FDCS_RPT       = (uint8_t*)":PGU:FDCS:RPT";
//uint8_t* cmd_str__PGU_PRD            = (uint8_t*)":PGU:PRD"; //$$

//
uint8_t* cmd_str__PGU_TRIG           = (uint8_t*)":PGU:TRIG" ;  //$$ new pattern gen
uint8_t* cmd_str__PGU_FDAT0          = (uint8_t*)":PGU:FDAT0";  //$$ new pattern gen
uint8_t* cmd_str__PGU_FDAT1          = (uint8_t*)":PGU:FDAT1";  //$$ new pattern gen
uint8_t* cmd_str__PGU_NFDT0          = (uint8_t*)":PGU:NFDT0";  //$$ new pattern gen
uint8_t* cmd_str__PGU_NFDT1          = (uint8_t*)":PGU:NFDT1";  //$$ new pattern gen
uint8_t* cmd_str__PGU_FRPT0          = (uint8_t*)":PGU:FRPT0";  //$$ new pattern gen
uint8_t* cmd_str__PGU_FRPT1          = (uint8_t*)":PGU:FRPT1";  //$$ new pattern gen
//
uint8_t* cmd_str__PGU_FREQ           = (uint8_t*)":PGU:FREQ";
uint8_t* cmd_str__PGU_OFST_DAC0      = (uint8_t*)":PGU:OFST:DAC0";
uint8_t* cmd_str__PGU_OFST_DAC1      = (uint8_t*)":PGU:OFST:DAC1";
uint8_t* cmd_str__PGU_GAIN_DAC0      = (uint8_t*)":PGU:GAIN:DAC0";
uint8_t* cmd_str__PGU_GAIN_DAC1      = (uint8_t*)":PGU:GAIN:DAC1";
//
#endif


//// command string length 

//#define LEN_CMD_STR__XXX   3
#define LEN_CMD_STR__IDN                (strlen((const char *)cmd_str__IDN)) 
#define LEN_CMD_STR__RST                (strlen((const char *)cmd_str__RST)) 
//
#define LEN_CMD_STR__FPGA_FID           (strlen((const char *)cmd_str__FPGA_FID)) 
#define LEN_CMD_STR__FPGA_TMP           (strlen((const char *)cmd_str__FPGA_TMP)) 

// low-level end-point access command : EPS
#define LEN_CMD_STR__EPS_EN             (strlen((const char *)cmd_str__EPS_EN  ))
#define LEN_CMD_STR__EPS_WMI            (strlen((const char *)cmd_str__EPS_WMI ))
#define LEN_CMD_STR__EPS_WMO            (strlen((const char *)cmd_str__EPS_WMO ))
#define LEN_CMD_STR__EPS_TAC            (strlen((const char *)cmd_str__EPS_TAC ))
#define LEN_CMD_STR__EPS_TMO            (strlen((const char *)cmd_str__EPS_TMO ))
#define LEN_CMD_STR__EPS_TWO            (strlen((const char *)cmd_str__EPS_TWO ))
#define LEN_CMD_STR__EPS_PI             (strlen((const char *)cmd_str__EPS_PI  ))
#define LEN_CMD_STR__EPS_PO             (strlen((const char *)cmd_str__EPS_PO  ))

#define LEN_CMD_STR__MEM_MEMR            (strlen((const char *) cmd_str__MEM_MEMR         ))
#define LEN_CMD_STR__MEM_MEMW            (strlen((const char *) cmd_str__MEM_MEMW         ))
//


#ifdef _SCPI_CMD_S3100_PGU_// _SCPI_CMD_PGU_ --> _SCPI_CMD_S3100_PGU_

//
#define LEN_CMD_STR__PGU_PWR             (strlen((const char *) cmd_str__PGU_PWR          ))
#define LEN_CMD_STR__PGU_OUTP            (strlen((const char *) cmd_str__PGU_OUTP         ))
#define LEN_CMD_STR__PGU_STAT            (strlen((const char *) cmd_str__PGU_STAT         ))
// 
#define LEN_CMD_STR__PGU_AUX_OUTP        (strlen((const char *) cmd_str__PGU_AUX_OUTP     ))
#define LEN_CMD_STR__PGU_AUX_CON         (strlen((const char *) cmd_str__PGU_AUX_CON      ))
#define LEN_CMD_STR__PGU_AUX_OLAT        (strlen((const char *) cmd_str__PGU_AUX_OLAT     ))
#define LEN_CMD_STR__PGU_AUX_DIR         (strlen((const char *) cmd_str__PGU_AUX_DIR      ))
#define LEN_CMD_STR__PGU_AUX_GPIO        (strlen((const char *) cmd_str__PGU_AUX_GPIO     ))
// 
#define LEN_CMD_STR__PGU_MEMR            (strlen((const char *) cmd_str__PGU_MEMR         ))
#define LEN_CMD_STR__PGU_MEMW            (strlen((const char *) cmd_str__PGU_MEMW         ))

//// unused
//#define LEN_CMD_STR__PGU_DCS_TRIG        (strlen((const char *) cmd_str__PGU_DCS_TRIG     ))
//#define LEN_CMD_STR__PGU_DCS_DAC0_PNT    (strlen((const char *) cmd_str__PGU_DCS_DAC0_PNT ))
//#define LEN_CMD_STR__PGU_DCS_DAC1_PNT    (strlen((const char *) cmd_str__PGU_DCS_DAC1_PNT ))
//#define LEN_CMD_STR__PGU_DCS_RPT         (strlen((const char *) cmd_str__PGU_DCS_RPT      ))
//#define LEN_CMD_STR__PGU_FDCS_TRIG       (strlen((const char *) cmd_str__PGU_FDCS_TRIG    ))
//#define LEN_CMD_STR__PGU_FDCS_DAC0       (strlen((const char *) cmd_str__PGU_FDCS_DAC0    ))
//#define LEN_CMD_STR__PGU_FDCS_DAC1       (strlen((const char *) cmd_str__PGU_FDCS_DAC1    ))
//#define LEN_CMD_STR__PGU_FDCS_RPT        (strlen((const char *) cmd_str__PGU_FDCS_RPT     ))
//#define LEN_CMD_STR__PGU_PRD             (strlen((const char *) cmd_str__PGU_PRD          ))

//
#define LEN_CMD_STR__PGU_TRIG            (strlen((const char *) cmd_str__PGU_TRIG         ))
#define LEN_CMD_STR__PGU_FDAT0           (strlen((const char *) cmd_str__PGU_FDAT0        ))
#define LEN_CMD_STR__PGU_FDAT1           (strlen((const char *) cmd_str__PGU_FDAT1        ))
#define LEN_CMD_STR__PGU_NFDT0           (strlen((const char *) cmd_str__PGU_NFDT0        ))
#define LEN_CMD_STR__PGU_NFDT1           (strlen((const char *) cmd_str__PGU_NFDT1        ))
#define LEN_CMD_STR__PGU_FRPT0           (strlen((const char *) cmd_str__PGU_FRPT0        ))
#define LEN_CMD_STR__PGU_FRPT1           (strlen((const char *) cmd_str__PGU_FRPT1        ))
//
#define LEN_CMD_STR__PGU_FREQ            (strlen((const char *) cmd_str__PGU_FREQ         ))
#define LEN_CMD_STR__PGU_OFST_DAC0       (strlen((const char *) cmd_str__PGU_OFST_DAC0    ))
#define LEN_CMD_STR__PGU_OFST_DAC1       (strlen((const char *) cmd_str__PGU_OFST_DAC1    ))
#define LEN_CMD_STR__PGU_GAIN_DAC0       (strlen((const char *) cmd_str__PGU_GAIN_DAC0    ))
#define LEN_CMD_STR__PGU_GAIN_DAC1       (strlen((const char *) cmd_str__PGU_GAIN_DAC1    ))
//
#endif


// https://mcuoneclipse.com/2013/04/14/text-data-and-bss-code-and-data-size-explained/

// IDN string 
uint8_t* rsp_str__IDN = (uint8_t*) _IDN_BOARD_NAME_ "; SBT " __TIME__ ", " __DATE__;

// common para
uint8_t* rsp_str__NULL = (uint8_t*)"\0";
uint8_t* rsp_str__OK   = (uint8_t*)"OK\n";
uint8_t* rsp_str__NG   = (uint8_t*)"NG\n";
uint8_t* rsp_str__OFF  = (uint8_t*)"OFF\n";
uint8_t* rsp_str__ON   = (uint8_t*)"ON\n";
uint8_t* rsp_str__NL   = (uint8_t*)"\n"; // sentinel for numberic block

// comparison string
uint8_t* cmp_str__N4_HD_3  = (uint8_t*)"#4_";


//}


//// scpi subfunctions: //{

// send response all //{
int32_t send_response_all(uint8_t sn, uint8_t *p_rsp_str, int32_t size) {
	int32_t sentsize;
	int32_t ret;
	//
	if (size==0)
		return 0;
	//
	sentsize = 0;
	while(size != sentsize) {
		ret = send(sn, p_rsp_str+sentsize, size-sentsize); //$$ send
		if(ret < 0) {
			return ret;
		}
#ifdef _SCPI_DEBUG_
		xil_printf("send size:%d , string size:%d, contents:%s \r\n",(int)ret,(int)(size-sentsize),(p_rsp_str+sentsize));
#endif
		sentsize += ret; // Don't care SOCKERR_BUSY, because it is zero.
	}
	return ret;
}
//}

// send_response_all_from_pipe32() //{
//   send data from pipe32 
//   new send_from_pipe32() in socket.c
//   new wiz_send_data_from_pipe32() in w5500.c
//   new WIZCHIP_WRITE_PIPE() in w5500.c
//   new write_data_pipe__wz850() in cmu_cpu.c
int32_t send_response_all_from_pipe32(uint8_t sn, uint32_t src_adrs_p32, int32_t size) {
	int32_t sentsize;
	int32_t ret;
	//
	if (size==0)
		return 0;
	//
	sentsize = 0;
	while(size != sentsize) {
		//$$ret = send(sn, p_rsp_str+sentsize, size-sentsize); //$$ send
		ret = send_from_pipe32(sn, src_adrs_p32, size-sentsize); //$$ send
		if(ret < 0) {
			return ret;
		}
#ifdef _SCPI_DEBUG_
		xil_printf("sent size :%d , size to send:%d, prev sent size:%d \r\n",(int)ret,(int)(size-sentsize),(int)sentsize);
#endif
		sentsize += ret; // Don't care SOCKERR_BUSY, because it is zero.
	}
	return ret;
}
//}

//}


//// static var //{	
static int8_t flag_SOCK_ESTABLISHED = 0;
static int8_t flag_get_rx = 0;
static int32_t cnt_stay_SOCK_ESTABLISHED = MAX_CNT_STAY_SOCK_ESTABLISHED;
//}

//// SCPI servers : scpi_tcps_ep  //{

// TODO: scpi_tcps_ep() ================ //{
int32_t scpi_tcps_ep(uint8_t sn, uint8_t* buf, uint16_t port) //$$
{
	// vars //{
	int32_t ret, ret2;
	uint16_t size = 0;
	int32_t ii;
	int32_t flag__found_newline;
	//
#ifdef _SCPI_DEBUG_MIN_
	uint8_t destip[4];
	uint16_t destport;
#endif
	uint8_t sr; //$$
#ifdef _SCPI_DEBUG_WCMSG_
	uint8_t* msg_welcome = (uint8_t*)"> SCPI TCP server is established: \r\n";
#endif
	uint8_t rsp_str[RSP_BUF_SIZE_SCPI];
	uint8_t* p_rsp_str;
	//}

	switch(sr=getSn_SR(sn))
	{
		case SOCK_ESTABLISHED : //{
			
			// case of new establish //{
			if(getSn_IR(sn) & Sn_IR_CON)
			{
#ifdef _SCPI_DEBUG_MIN_
			getSn_DIPR(sn, destip);
			destport = getSn_DPORT(sn);
			//
			xil_printf("%d:Connected - %d.%d.%d.%d : %d \r\n",sn, destip[0], destip[1], destip[2], destip[3], destport);
#endif
			setSn_IR(sn,Sn_IR_CON); //$$ clear establish intr.
			//
			flag_SOCK_ESTABLISHED = 1;
			flag_get_rx = 0;
			cnt_stay_SOCK_ESTABLISHED = MAX_CNT_STAY_SOCK_ESTABLISHED;
			//
#ifdef _SCPI_DEBUG_WCMSG_
			//$$ send welcome message
			size = strlen((char*)msg_welcome);
			ret = send(sn,msg_welcome,size); //$$ send welcome msg
			if(ret < 0)
			{
				close(sn);
				return ret;
			}
			//
#endif 
			}
			//}
			
			// check input buffer and process SCPI commands... //{
				
			if((size = getSn_RX_RSR(sn)) > 0) { //$$ check received data size //{
			
			// for reset counter //{
			flag_get_rx = 1;
			// cnt_stay_SOCK_ESTABLISHED = MAX_CNT_STAY_SOCK_ESTABLISHED;
			//}
			
			// see if size is too small... wait a moment ... check getSn_RX_RSR() again... //{
			if (size<5) {
#ifdef _SCPI_DEBUG_
				xil_printf("get rx size again. size:%d \r\n",(int)size);
#endif
				////usleep(100); // wait for 100us
				//usleep(10); // wait for 10us
				size = getSn_RX_RSR(sn);
			}
			//}
			
			// move data to buf //{
			if(size > DATA_BUF_SIZE_SCPI-1) size = DATA_BUF_SIZE_SCPI-1; //$$ a space for sentinel
			ret = recv(sn, buf, size); //$$ read socket data, and save them into buf 
			if(ret <= 0) 
				return ret;
			buf[ret] = '\0'; // add sentinel
			//}
			
			//$$ must revise that newline is not available...
			//$$ must consider to rewrite buf as a circular style.
			
			//// check newline and get more input //{
			// see if buf has <NL> or end of command ... repeat recv() for a while... 
			// 16KB buffer ... 100Mbps ... 16KB/(100Mbps) = 1.28 milliseconds
			// wait for 320us ... 4KB size 

			flag__found_newline = 0;
			ret2 = ret;
			while (1) {
				// find <NL> from rear-side
				for (ii=0;ii<ret2;ii++) {
					if (buf[ret-1-ii] == '\n') {
						flag__found_newline = 1;
#ifdef _SCPI_DEBUG_
						xil_printf("flag__found_newline:%d, @ii=%d \r\n",(int)flag__found_newline,(int)ii);
#endif
						if ((ret-2-ii>=0)&&(buf[ret-2-ii]=='\r')) {
							buf[ret-2-ii]='\n'; // convert '\r' --> '\n'
						}
						break;
					}
				}
				if (flag__found_newline) break;
				//
#ifdef _SCPI_DEBUG_
				xil_printf("get more socket data. flag__found_newline:%d \r\n",(int)flag__found_newline);
#endif
				////usleep(320); // wait for 320us
				//usleep(100); // wait for 100us

				//$$ for large numerical packet
				// 16KB buffer ... 100Mbps ... 16KB/(100Mbps) = 1.28 milliseconds
				usleep(1000); // wait for 1000us

				size = getSn_RX_RSR(sn);
				//
				if (size==0) {
					//break; // no more data; leave!
					continue; //$$ retry
				}
				//
				ret2 = recv(sn, buf+ret, size); //$$ read socket data, and save them into buf 
				if(ret2 <= 0)
					return ret2; //$$
#ifdef _SCPI_DEBUG_
				xil_printf("size=%d, ret=%d, ret2=%d \r\n",(int)size,(int)ret,(int)ret2);
#endif
				ret = ret+ret2;
				buf[ret] = '\0'; // add sentinel
				//
				// if too many try.... close socket and leave.... 
			}

			// note new line check may fail if command has numberic block...
			// need some method ... what if buf starting with '#4_' must be numberic block...?!
			// waiting for whole numberic block...

			//}
			
			//// find scpi command and respond //{
			//   - case: buf has the completed command 
			//   - case: buf has no valid command 
			
#ifdef _SCPI_DEBUG_
			size = strlen((char*)buf); // assume buf has ascii... not binary...
			xil_printf("recv size:%d , string size:%d, contents:%s \r\n",(int)ret,(int)size,buf);
#endif
			
			//// TODO: basic scpi commands --------//// 
			
			// TODO: case of ECHO //{
			if (buf[0]=='\n') { // echo '\n'
				// make scpi response string
				p_rsp_str = rsp_str__NL;
			}
			//}
			
			// TODO: case of  cmd_str__IDN //{
			else if (0==strncmp((char*)cmd_str__IDN,(char*)buf,LEN_CMD_STR__IDN)) { // 0 means eq
				u32 val;
				// make scpi response string
				//   - case: *IDN?<NL> --> "CMU-CPU-F5500, "__DATE__" \r\n"
				//            add FPGA image ID 
				//val = XIomodule_In32 (ADRS_FPGA_IMAGE_MHVSU); //$$
				val = XIomodule_In32 (ADRS_FPGA_IMAGE); //$$
				xil_sprintf((char*)rsp_str,"%s; FID#H%08X\n", rsp_str__IDN, (unsigned int)val);
				p_rsp_str = rsp_str;
			}
			//}
			
			// TODO: case of  cmd_str__RST //{
			else if (0==strncmp((char*)cmd_str__RST,(char*)buf,LEN_CMD_STR__RST)) { // 0 means eq
				
				// reserved
				// Reset process ... LAN reset (meaningless) vs CMU reset (SPO/DAVE/ADC init...)
				// reset_mcs_ep();
				// reset_io_dev();
				// make scpi response string
				p_rsp_str = rsp_str__OK;
			}
			//}

			// TODO: case of  cmd_str__FPGA_FID //{
			else if (0==strncmp((char*)cmd_str__FPGA_FID,(char*)buf,LEN_CMD_STR__FPGA_FID)) { // 0 means eq
				u32 val;
				//
				val = read_fpga_image_id();
				xil_sprintf((char*)rsp_str,"#H%08X\n", (unsigned int)val);
				p_rsp_str = rsp_str;
			}
			//}
			
			// TODO: case of  cmd_str__FPGA_TMP //{
			else if (0==strncmp((char*)cmd_str__FPGA_TMP,(char*)buf,LEN_CMD_STR__FPGA_TMP)) { // 0 means eq
				u32 val;
				//
				val = read_fpga_temperature();
				xil_sprintf((char*)rsp_str,"#H%08X\n", (unsigned int)val);
				p_rsp_str = rsp_str;
			}
			//}
			
			
  			//// TODO: EPS (End-Point System) --------////
			
			// TODO: case of  cmd_str__EPS_EN //{
			else if (0==strncmp((char*)cmd_str__EPS_EN,(char*)buf,LEN_CMD_STR__EPS_EN)) { // 0 means eq
				// subfunctions:
				//        enable_mcs_ep()
				//       disable_mcs_ep()
				//    is_enabled_mcs_ep()
				//
				u32 loc = LEN_CMD_STR__EPS_EN;
				u32 val;
				//
				// skip spaces ' ' and tap
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\r\n",(char*)buf+loc);
#endif
				//
				// make scpi response string
				if (buf[loc]=='?') {
					// always enabled
					//p_rsp_str = rsp_str__ON;
					
					val = is_enabled_mcs_ep();
					if (val == 0) p_rsp_str = rsp_str__OFF;
					else          p_rsp_str = rsp_str__ON;
				}
				else if (0==strncmp("ON", (char*)&buf[loc], 2)) {
					// enable
					enable_mcs_ep();
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// OFF is not allowed
					//p_rsp_str = rsp_str__NG;
					
					disable_mcs_ep();
					p_rsp_str = rsp_str__OK;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__EPS_WMI //{
			else if (0==strncmp((char*)cmd_str__EPS_WMI,(char*)buf,LEN_CMD_STR__EPS_WMI)) { // 0 means eq
				// subfunctions:
				//     write_mcs_ep_wi_mask(msk);
				//     write_mcs_ep_wi_data(ofs,val);
				//
				// # ":EPS:WMI#H00 #HABCD1234 #HFF00FF00\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_WMI; //$$
				u32 val;
				u32 ofs; 
				u32 msk;
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("ofs: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					
					// find value
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8; //	
#ifdef _SCPI_DEBUG_
						xil_printf("val: 0x%08X\r\n",(unsigned int)val); 
#endif
						// skip spaces ' ' and tap
						while (1) {
							if      (buf[loc]==' ') loc++;
							else if (buf[loc]=='\t') loc++;
							else break;
						}
						
						// find mask 
						if (0==strncmp("#H", (char*)&buf[loc], 2)) {
							loc = loc + 2; // locate the numeric parameter head
							msk = hexstr2data_u32((u8*)(buf+loc),8);
							//loc = loc + 8; //	
#ifdef _SCPI_DEBUG_
							xil_printf("msk: 0x%08X\r\n",(unsigned int)msk); 
#endif
							write_mcs_ep_wi_mask(MCS_EP_BASE,msk);
							write_mcs_ep_wi_data(MCS_EP_BASE,ofs,val); //$$
							p_rsp_str = rsp_str__OK;
						}
						else {
							// return NG 
							p_rsp_str = rsp_str__NG;
						}
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
  			
			// TODO: case of  cmd_str__EPS_WMO //{
			else if (0==strncmp((char*)cmd_str__EPS_WMO,(char*)buf,LEN_CMD_STR__EPS_WMO)) { // 0 means eq
				// subfunctions:
				//    write_mcs_ep_wo_mask(msk);
				//     read_mcs_ep_wo_data(ofs);
				//
				// # ":EPS:WMO#H20 #HFFFF0000\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_WMO; //$$
				u32 val;
				u32 ofs; 
				u32 msk;
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("ofs: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					
					// find mask 
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						msk = hexstr2data_u32((u8*)(buf+loc),8);
						//loc = loc + 8; //	
#ifdef _SCPI_DEBUG_
						xil_printf("msk: 0x%08X\r\n",(unsigned int)msk); 
#endif
						write_mcs_ep_wo_mask(MCS_EP_BASE,msk); // write mask 
						val = read_mcs_ep_wo_data(MCS_EP_BASE,ofs); // read wireout
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n"
						p_rsp_str = rsp_str;
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__EPS_TAC//{
			else if (0==strncmp((char*)cmd_str__EPS_TAC,(char*)buf,LEN_CMD_STR__EPS_TAC)) { // 0 means eq
				// subfunctions:
				//    u32  read_mcs_ep_wi_mask();
				//    u32 write_mcs_ep_wi_mask(u32 mask);
				//    u32  read_mcs_ep_ti_data(u32 offset);
				//    u32 write_mcs_ep_ti_data(u32 offset, u32 data);
				//    void activate_mcs_ep_ti(u32 offset, u32 bit_loc);
				//
				// # ":EPS:TAC#H40 #H01\n"
				// ==
				// # ":EPS:MKTI#H40 #H00000002\n"
				// # ":EPS:TI#H40   #H00000002\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_TAC; //$$
				u32 val;
				u32 ofs; 
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// write command
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),2); //$$ read 2-byte para
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%08X\r\n",(unsigned int)val); 
#endif
						activate_mcs_ep_ti(MCS_EP_BASE,ofs,val);
						// convert bit_loc --> mask 
						//val = (0x00000001<<val);
						//write_mcs_ep_wi_mask(val); //$$
						//write_mcs_ep_ti_data(ofs,val); //$$
						p_rsp_str = rsp_str__OK;
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__EPS_TMO //{
			else if (0==strncmp((char*)cmd_str__EPS_TMO,(char*)buf,LEN_CMD_STR__EPS_TMO)) { // 0 means eq
				// subfunctions:
				//    u32  read_mcs_ep_to_mask(); //$$
				//    u32 write_mcs_ep_to_mask(u32 mask); //$$
				//    u32  read_mcs_ep_to_data(u32 offset);
				//    u32 is_triggered_mcs_ep_to(u32 offset, u32 mask);
				//
				// # cmd: ":EPS:TMO#H60 #H0000FFFF\n"
				// # rsp: "ON\n" or "OFF\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_TMO; //$$
				u32 val;
				u32 ofs; 
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// command
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8); //$$ read 8-byte para
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%08X\r\n",(unsigned int)val); 
#endif
						val = is_triggered_mcs_ep_to(MCS_EP_BASE,ofs,val);
						if (val==0) 
							p_rsp_str = rsp_str__OFF;
						else        
							p_rsp_str = rsp_str__ON;
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			// TODO: case of  cmd_str__EPS_TWO //{
			else if (0==strncmp((char*)cmd_str__EPS_TWO,(char*)buf,LEN_CMD_STR__EPS_TWO)) { // 0 means eq
				// subfunctions:
				//    u32  read_mcs_ep_to_mask(); //$$
				//    u32 write_mcs_ep_to_mask(u32 mask); //$$
				//    u32  read_mcs_ep_to_data(u32 offset);
				//
				//    u32  read_mcs_ep_to(u32 adrs_base, u32 offset, u32 mask);
				//
				// # cmd: ":EPS:TWO#H60 #H0000FFFF\n"
				// # rsp: "#H00003242\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_TWO; //$$
				u32 val;
				u32 ofs; 
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// command
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8); //$$ read 8-byte para
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%08X\r\n",(unsigned int)val); 
#endif
						val = read_mcs_ep_to(MCS_EP_BASE,ofs,val); //$$
						//
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n"
						p_rsp_str = rsp_str;
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__EPS_PI //{
			else if (0==strncmp((char*)cmd_str__EPS_PI,(char*)buf,LEN_CMD_STR__EPS_PI)) { // 0 means eq
				// subfunctions:
				//    void dcopy_buf8_to_pipe32(u8 *p_buf_u8, u32 adrs_p32, u32 len_byte); // (src,dst,len_byte)
				//
				// # cmd: ":EPS:PI#H8A #4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
				// 
				u32 loc = LEN_CMD_STR__EPS_PI; //$$
				//u32 val;
				u32 ofs; 
				u32 len_byte;
				u32 adrs_p32;
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// write command
					if (0==strncmp("#4_", (char*)&buf[loc], 3)) { //$$ #4 ... numeric block of 4-byte unit of binary byte(8 bit)
						loc = loc + 3; // locate the numeric parameter head
						len_byte = decstr2data_u32((u8*)(buf+loc),6); //$$ 6 bytes for data byte length
						loc = loc + 7; // skip a char '_'
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%06d\r\n",(unsigned int)len_byte); 
#endif
						// copy buf to pipe 
						//adrs_p32 = ADRS_BASE_CMU + (ofs<<4); 
						adrs_p32 = MCS_EP_BASE + (ofs<<4); 
						//dcopy_buf32_to_pipe32((u32*)(buf+loc), adrs_p32, len_byte);
						dcopy_buf8_to_pipe32((u8*)(buf+loc), adrs_p32, len_byte); 
						//
						p_rsp_str = rsp_str__OK;
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__EPS_PO //{
			else if (0==strncmp((char*)cmd_str__EPS_PO,(char*)buf,LEN_CMD_STR__EPS_PO)) { // 0 means eq
				// subfunctions:
				//    void dcopy_pipe32_to_pipe8 (u32 src_adrs_p32, u32 dst_adrs_p8,  u32 len_byte);
				//
				// # cmd: ":EPS:PO#HAA 000040\n"
				// # cmd: ":EPS:PO#HAA 001024\n"
				// # cmd: ":EPS:PO#HBC 131072\n"
				// # rsp: "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
				//
				u32 loc = LEN_CMD_STR__EPS_PO; //$$
				//u32 val;
				u32 ofs; 
				u32 len_byte;
				u32 adrs_p32;
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),2);
					loc = loc + 2; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%02X\r\n",(unsigned int)ofs); 
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// read command
					if (isdigit(buf[loc])) { //$$ isdigit() numeric parameter check
						len_byte = decstr2data_u32((u8*)(buf+loc),6); //$$ 6 bytes for data byte length
						loc = loc + 6; 
#ifdef _SCPI_DEBUG_
						xil_printf("check: %06d\r\n",(unsigned int)len_byte); 
#endif
						// send numberic block head : #4_nnnnnn_
						xil_sprintf((char*)rsp_str,"#4_%06d_",(int)len_byte); // '\0' added
						size = strlen((char*)rsp_str);
						ret = send_response_all(sn, rsp_str, size); //$$ first message
						if (ret < 0) {
							close(sn);
							return ret;
						}
						
						// send numeric block 
						// ... dcopy_pipe32_to_pipe8
						// send_response_all_from_pipe32() ... 
						//adrs_p32 = ADRS_BASE_CMU + (ofs<<4); 
						adrs_p32 = MCS_EP_BASE + (ofs<<4); 
						ret = send_response_all_from_pipe32(sn, adrs_p32, len_byte); //$$ first message block
						if (ret < 0) {
							close(sn);
							return ret;
						}
						
						// return NL
						p_rsp_str = rsp_str__NL; // Newline sentinel. this will be last message block
						//
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			

			// TODO: case of  cmd_str__MEM_MEMR //{
			else if (0==strncmp((char*)cmd_str__MEM_MEMR,(char*)buf,LEN_CMD_STR__MEM_MEMR)) { // 0 means eq
				// subfunctions:
				//    eeprom_read_data   (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
				//    eeprom_write_data  (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
				//
				// # ':MEM:MEMR' # new ':MEM:MEMR #H00000058 \n'
				// # ':MEM:MEMW' # new ':MEM:MEMW #H0000005C #H1234ABCD \n'

				u32 loc = LEN_CMD_STR__MEM_MEMR; //$$
				u32 val;
				u32 adrs;

				// skip spaces ' ' and tap
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}

				// find adrs
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read adrs 8 bytes
					loc = loc + 2; // locate the numeric parameter head
					adrs = hexstr2data_u32((u8*)(buf+loc),8);
					loc = loc + 8; //
#ifdef _SCPI_DEBUG_
					xil_printf("adrs: 0x%08X\r\n",(unsigned int)adrs);
#endif
					eeprom_read_data((u16)adrs, 4, (u8*)&val); //$$ read eeprom
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n"
					p_rsp_str = rsp_str;
				}
				else {
					// return NG
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			


			// TODO: case of  cmd_str__MEM_MEMW //$$ //{
			else if (0==strncmp((char*)cmd_str__MEM_MEMW,(char*)buf,LEN_CMD_STR__MEM_MEMW)) { // 0 means eq
				// subfunctions:
				//    eeprom_read_data   (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
				//    eeprom_write_data  (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
				//
				// # ':MEM:MEMR' # new ':MEM:MEMR #H00000058 \n'
				// # ':MEM:MEMW' # new ':MEM:MEMW #H0000005C #H1234ABCD \n'
			
				u32 loc = LEN_CMD_STR__MEM_MEMW; //$$
				u32 val;
				u32 adrs;

				// skip spaces ' ' and tap
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}

				// find adrs
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read adrs 8 bytes
					loc = loc + 2; // locate the numeric parameter head
					adrs = hexstr2data_u32((u8*)(buf+loc),8);
					loc = loc + 8; //
#ifdef _SCPI_DEBUG_
					xil_printf("adrs: 0x%08X\r\n",(unsigned int)adrs);
#endif

					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}

					// find value
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						// read adrs 8 bytes
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8; //
#ifdef _SCPI_DEBUG_
						xil_printf("val: 0x%08X\r\n",(unsigned int)val);
#endif

						// process
						eeprom_write_data((u16)adrs, 4, (u8*)&val); //$$ read eeprom
						p_rsp_str = rsp_str__OK;

					}
					else {
						// return NG
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG
					p_rsp_str = rsp_str__NG;
				}
			}
			//}


			//// TODO: S3100-PGU command --------////
#ifdef _SCPI_CMD_S3100_PGU_// _SCPI_CMD_PGU_ --> _SCPI_CMD_S3100_PGU_

			// TODO: case of  cmd_str__PGU_PWR //{
			else if (0==strncmp((char*)cmd_str__PGU_PWR,(char*)buf,LEN_CMD_STR__PGU_PWR)) { // 0 means eq
				// subfunctions:
				//    pgu_spio_ext_pwr_led_readback()
				//    pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp)
				//
				u32 loc = LEN_CMD_STR__PGU_PWR;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// check LAN end point enable
				//val = is_enabled_mcs_ep();

				// force to enable LAN endpoint
				enable_mcs_ep();

				// make scpi response string
				//  if (val == 0) { // not ready for LAN access
				//  	p_rsp_str = rsp_str__NG;
				//  }
				//else
				if (buf[loc]=='?') {
					val = pgu_spio_ext_pwr_led_readback();
					val = val & 0x0004; // 
					if (val == 0) p_rsp_str = rsp_str__OFF;
					else          p_rsp_str = rsp_str__ON;
				}
				else if (0==strncmp("ON", (char*)&buf[loc], 2)) {
					// local var
					//$$u32 val_s0;
					//$$u32 val_s1;

					// read power status 
					//$$val = pgu_spio_ext_pwr_led_readback();
					//$$val_s0 = (val>>0) & 0x0001;
					//$$val_s1 = (val>>1) & 0x0001;
					// DAC power on
					//$$pgu_spio_ext_pwr_led(1, 1, val_s1, val_s0, 1, 1); // (led, pwr_dac, pwr_adc, pwr_amp,  pwr_p5v_dac, pwr_n5v_dac)
					// powers on in S3100-ADDA
					pgu_spio_ext_pwr_led(1, 1, 1, 1, 1, 1); // (led, pwr_dac, pwr_adc, pwr_amp,  pwr_p5v_dac, pwr_n5v_dac)
					// DAC power on
					//pgu_spio_ext_pwr_led(1, 1, 0, 0); // test for no amp power
					//
					//
					usleep(500); // 500us
					//
					// DACX fpga pll reset
					pgu_dacx_fpga_pll_rst(1, 1, 1);
					//
					// CLKD init
					pgu_clkd_init();
					//
					// CLKD setup
					pgu_clkd_setup(2000); // preset 200MHz
					//
					// DACX init 
					pgu_dacx_init();
					//
					// DACX fpga pll run
					pgu_dacx_fpga_pll_rst(0, 0, 0);
					pgu_dacx_fpga_clk_dis(0, 0);
					//
					
					//$$ inside update input delay tap
					pgu_dacx_cal_input_dtap();
					
					// DACX setup 
					pgu_dacx_setup(); //$$ DAC IC scale,offset preset ... not necessary 
					//
					// DACX_PG setup
					//pgu_dacx_pg_setup(); //$$ previous DCS setup... not used in S3100-PGU
					
					// DACZ new pattern gen setup may come!!
					
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// DAC power off
					pgu_spio_ext_pwr_led(0, 0, 0, 0, 0, 0);
					p_rsp_str = rsp_str__OK;
					
					// TODO: consider pll off by reset  vs  clock dis
					//pgu_dacx_fpga_pll_rst(1, 1, 1);
					pgu_dacx_fpga_clk_dis(1, 1);
					
					// note :PGU:SLP sleep command to consider for disabling dac clocks and zeroing dac output.
				}
				else if (0==strncmp("TST3", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_pwr_led(1, 0, 0, 0, 0, 0);
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("TST2", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_pwr_led(0, 1, 0, 0, 0, 0);
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("TST1", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_pwr_led(0, 0, 1, 0, 0, 0);
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("TST0", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_pwr_led(0, 0, 0, 1, 0, 0);
					p_rsp_str = rsp_str__OK;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_OUTP //{
			else if (0==strncmp((char*)cmd_str__PGU_OUTP,(char*)buf,LEN_CMD_STR__PGU_OUTP)) { // 0 means eq
				// subfunctions:
				//    pgu_spio_ext_pwr_led_readback()
				//    pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp)
				//    pgu_spio_ext_relay_readback()
				//    void pgu_spio_ext_relay(u32 sw_rl_k1, u32 sw_rl_k2)
				//
				u32 loc = LEN_CMD_STR__PGU_OUTP;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					val = pgu_spio_ext_pwr_led_readback();
					val = val & 0x0001; // for pwr_amp
					if (val == 0) p_rsp_str = rsp_str__OFF;
					else          p_rsp_str = rsp_str__ON;
				}
				else if (0==strncmp("ON", (char*)&buf[loc], 2)) {
					// local var
					u32 val_s1;
					u32 val_s2;
					u32 val_s3;
					u32 val_s10;
					u32 val_s11;
										// read power status
					val = pgu_spio_ext_pwr_led_readback();
					val_s1 = (val>>1) & 0x0001;
					val_s2 = (val>>2) & 0x0001;
					val_s3 = (val>>3) & 0x0001;
					val_s10 = (val>>10) & 0x0001;
					val_s11 = (val>>11) & 0x0001;
										// output power on
					pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 1, val_s10, val_s11);
					
					//$$ relay control for PGU-CPU-S3000 or S3100-PGU
					pgu_spio_ext_relay(1,1); //(u32 sw_rl_k1, u32 sw_rl_k2)
					
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// local var
					u32 val_s1;
					u32 val_s2;
					u32 val_s3;
					u32 val_s10;
					u32 val_s11;
					// read power status 
					val = pgu_spio_ext_pwr_led_readback();
					val_s1 = (val>>1) & 0x0001;
					val_s2 = (val>>2) & 0x0001;
					val_s3 = (val>>3) & 0x0001;
					val_s10 = (val>>10) & 0x0001;
					val_s11 = (val>>11) & 0x0001;
					// output power off
					pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 0, val_s10, val_s11);

					//$$ relay control for PGU-CPU-S3000 or S3100-PGU
					pgu_spio_ext_relay(0,0); //(u32 sw_rl_k1, u32 sw_rl_k2)

					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("TST1", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_relay(0,1); //(u32 sw_rl_k1, u32 sw_rl_k2)
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("TST0", (char*)&buf[loc], 4)) {
					// power test
					pgu_spio_ext_relay(1,0); //(u32 sw_rl_k1, u32 sw_rl_k2)
					p_rsp_str = rsp_str__OK;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_STAT //{
			else if (0==strncmp((char*)cmd_str__PGU_STAT,(char*)buf,LEN_CMD_STR__PGU_STAT)) { // 0 means eq
				// subfunctions:
				//    u32  pgu_dacz__read_status() //$$
				//
				u32 loc = LEN_CMD_STR__PGU_STAT;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					// wire [31:0] w_status_data = {30'b0, r_dac1_active_clk, r_dac0_active_clk};
					val = pgu_dacz__read_status();
					val = val & 0x0003; // to check dac1/0 activity
					if (val == 0) p_rsp_str = rsp_str__OFF;
					else          p_rsp_str = rsp_str__ON;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			
			// TODO: case of  cmd_str__PGU_AUX_OUTP //{ 
			else if (0==strncmp((char*)cmd_str__PGU_AUX_OUTP,(char*)buf,LEN_CMD_STR__PGU_AUX_OUTP)) { // 0 means eq
				// subfunctions:
				//    pgu_spio_ext__aux_IO_read_b16()
				//    pgu_spio_ext__aux_IO_write_b16 (u32 val_b16)
				//
				u32 loc = LEN_CMD_STR__PGU_AUX_OUTP;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}				
				
				// make scpi response string
				if (buf[loc]=='?') {
					// readback
					val = pgu_spio_ext__aux_IO_read_b16();
					xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),4); //
					// set repeat data
					pgu_spio_ext__aux_IO_write_b16(val);
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else if (0==strncmp(":INIT", (char*)&buf[loc], 5)) {
					// initialize
					//pgu_spio_ext__aux_IO_init();
					val = pgu_spio_ext__aux_IO_init(0x00FF, 0x0000); // for subboard v1
				 	//
					if (val == 0x00FF)
						p_rsp_str = rsp_str__OK;
					else 
						p_rsp_str = rsp_str__NG;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}				
			}
			//}
			
			// TODO: case of  cmd_str__PGU_AUX_CON //{ 
			else if (0==strncmp((char*)cmd_str__PGU_AUX_CON,(char*)buf,LEN_CMD_STR__PGU_AUX_CON)) { // 0 means eq
				// subfunctions:
				//    u32  pgu_spio_ext__read_aux_IO_CON ()
				//    void pgu_spio_ext__send_aux_IO_CON (u32 val_b16)
				//
				u32 loc = LEN_CMD_STR__PGU_AUX_CON;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}				
				
				// make scpi response string
				if (buf[loc]=='?') {
					// readback
					val = pgu_spio_ext__read_aux_IO_CON();
					xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),4); //
					// set repeat data
					//$$pgu_spio_ext__send_aux_IO_CON(val); //$$ pending in S3100-ADDA
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}				
			}
			//}
			
			// TODO: case of  cmd_str__PGU_AUX_OLAT //{ 
			else if (0==strncmp((char*)cmd_str__PGU_AUX_OLAT,(char*)buf,LEN_CMD_STR__PGU_AUX_OLAT)) { // 0 means eq
				// subfunctions:
				//    u32  pgu_spio_ext__read_aux_IO_OLAT ()
				//    void pgu_spio_ext__send_aux_IO_OLAT (u32 val_b16)
				//
				u32 loc = LEN_CMD_STR__PGU_AUX_OLAT;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}				
				
				// make scpi response string
				if (buf[loc]=='?') {
					// readback
					val = pgu_spio_ext__read_aux_IO_OLAT();
					xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),4); //
					// set repeat data
					//$$pgu_spio_ext__send_aux_IO_OLAT(val); //$$ pending in S3100-ADDA
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}				
			}
			//}
			
			// TODO: case of  cmd_str__PGU_AUX_DIR //{ 
			else if (0==strncmp((char*)cmd_str__PGU_AUX_DIR,(char*)buf,LEN_CMD_STR__PGU_AUX_DIR)) { // 0 means eq
				// subfunctions:
				//    u32  pgu_spio_ext__read_aux_IO_DIR ()
				//    void pgu_spio_ext__send_aux_IO_DIR (u32 val_b16)
				//
				u32 loc = LEN_CMD_STR__PGU_AUX_DIR;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}				
				
				// make scpi response string
				if (buf[loc]=='?') {
					// readback
					val = pgu_spio_ext__read_aux_IO_DIR();
					xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),4); //
					// set repeat data
					//$$pgu_spio_ext__send_aux_IO_DIR(val); //$$ pending in S3100-ADDA
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}				
			}			
			//}
			
			// TODO: case of  cmd_str__PGU_AUX_GPIO //{ 
			else if (0==strncmp((char*)cmd_str__PGU_AUX_GPIO,(char*)buf,LEN_CMD_STR__PGU_AUX_GPIO)) { // 0 means eq
				// subfunctions:
				//    u32  pgu_spio_ext__read_aux_IO_GPIO ()
				//    void pgu_spio_ext__send_aux_IO_GPIO (u32 val_b16)
				//
				u32 loc = LEN_CMD_STR__PGU_AUX_GPIO;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}				
				
				// make scpi response string
				if (buf[loc]=='?') {
					// readback
					val = pgu_spio_ext__read_aux_IO_GPIO();
					xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),4); //
					// set repeat data
					//$$pgu_spio_ext__send_aux_IO_GPIO(val); //$$ pending in S3100-ADDA
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}				
			}			
			//}
			
			
			// TODO: case of  cmd_str__PGU_MEMR //{
			else if (0==strncmp((char*)cmd_str__PGU_MEMR,(char*)buf,LEN_CMD_STR__PGU_MEMR)) { // 0 means eq
				// subfunctions:
				//    eeprom_read_data   (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
				//    eeprom_write_data  (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
				//
				// # ':PGU:MEMR' # new ':PGU:MEMR #H00000058 \n'
				// # ':PGU:MEMW' # new ':PGU:MEMW #H0000005C #H1234ABCD \n'
			
				u32 loc = LEN_CMD_STR__PGU_MEMR; //$$
				u32 val;
				u32 adrs; 
				
				// skip spaces ' ' and tap
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				
				// find adrs 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read adrs 8 bytes
					loc = loc + 2; // locate the numeric parameter head
					adrs = hexstr2data_u32((u8*)(buf+loc),8);
					loc = loc + 8; //
#ifdef _SCPI_DEBUG_
					xil_printf("adrs: 0x%08X\r\n",(unsigned int)adrs); 
#endif
					eeprom_read_data((u16)adrs, 4, (u8*)&val); //$$ read eeprom 
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n"
					p_rsp_str = rsp_str;
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			
			// TODO: case of  cmd_str__PGU_MEMW //{
			else if (0==strncmp((char*)cmd_str__PGU_MEMW,(char*)buf,LEN_CMD_STR__PGU_MEMW)) { // 0 means eq
				// subfunctions:
				//    eeprom_read_data   (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
				//    eeprom_write_data  (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
				//
				// # ':PGU:MEMR' # new ':PGU:MEMR #H00000058 \n'
				// # ':PGU:MEMW' # new ':PGU:MEMW #H0000005C #H1234ABCD \n'
			
				u32 loc = LEN_CMD_STR__PGU_MEMW; //$$
				u32 val;
				u32 adrs; 
				
				// skip spaces ' ' and tap
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				
				// find adrs 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read adrs 8 bytes
					loc = loc + 2; // locate the numeric parameter head
					adrs = hexstr2data_u32((u8*)(buf+loc),8);
					loc = loc + 8; //
#ifdef _SCPI_DEBUG_
					xil_printf("adrs: 0x%08X\r\n",(unsigned int)adrs); 
#endif

					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}

					// find value
					if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						// read adrs 8 bytes
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8; //
#ifdef _SCPI_DEBUG_
						xil_printf("val: 0x%08X\r\n",(unsigned int)val); 
#endif
					
						// process
						eeprom_write_data((u16)adrs, 4, (u8*)&val); //$$ write eeprom 
						p_rsp_str = rsp_str__OK;
					
					}
					else {
						// return NG 
						p_rsp_str = rsp_str__NG;
					}
				}
				else {
					// return NG 
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			

			// TODO: case of  cmd_str__PGU_TRIG  //{
			else if (0==strncmp((char*)cmd_str__PGU_TRIG,(char*)buf,LEN_CMD_STR__PGU_TRIG)) { // 0 means eq
				// subfunctions:
				//    void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask)
				//    void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
				//
				//    DACn repeat count = {16-bit DAC1 repeat count, 16-bit DAC0 repeat count}
				//
				// #  `:PGU:TRIG` + `#Hmmmmnnnn` + `'\n'`
				// #  ex) trigger dac0 only : `:PGU:TRIG #H00000001 + \n`
				// #  ex) trigger dac1 only : `:PGU:TRIG #H00010000 + \n`
				// #  ex) trigger both      : `:PGU:TRIG #H00010001 + \n`
				//
				u32 loc = LEN_CMD_STR__PGU_TRIG;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					//  // readback
					//  val = pgu_dacx_fdcs_read_repeat();
					//  xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//  //
					//  p_rsp_str = rsp_str;
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					
					//// set trig data
					//  task CID_FIFO_TEST_RUN;
					//  	begin
					//  		CID_CTRL_WR(32'h0000_0030);
					//  	end
					//  endtask
					//
					//  task CID_CTRL_WR;
					//  	input  [31:0] data;
					//  	begin
					//  		@(posedge clk_10M);
					//  		r_wire_dacx_data    = data;  // @EP_ADRS__DACZ_DAT_WI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[12] = 1'b1; // @EP_ADRS__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[12] = 1'b0;
					//  	end
					//  endtask
					
					//// remap parameter for S3000/S3100-PGU
					// val == 0x00000001 --> val = 0x00000010
					// val == 0x00010000 --> val = 0x00000020
					// val == 0x00010001 --> val = 0x00000030
					//if      (val == 0x00000001) val = 0x00000010;
					//else if (val == 0x00010000) val = 0x00000020;
					//else if (val == 0x00010001) val = 0x00000030;
					//else                        val = 0x00000000;

					//// remap parameter for S3100-ADDA adc-linked trigger
					//wire w_enable_dac0_bias           = r_cid_reg_ctrl[0];
					//wire w_enable_dac1_bias           = r_cid_reg_ctrl[1];
					//wire w_enable_dac0_pulse_out_seq  = r_cid_reg_ctrl[2];
					//wire w_enable_dac1_pulse_out_seq  = r_cid_reg_ctrl[3];
					//
					//wire w_enable_dac0_pulse_out_fifo = r_cid_reg_ctrl[4];
					//wire w_enable_dac1_pulse_out_fifo = r_cid_reg_ctrl[5];
					//wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6]; //$$ false path try
					//wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7]; //$$ false path try
					//
					//wire w_force_trig_out             = r_cid_reg_ctrl[8];// new control for trig out

					if      (val == 0x00000001) val = 0x00000110;
					else if (val == 0x00010000) val = 0x00000120;
					else if (val == 0x00010001) val = 0x00000130;
					else                        val = 0x00000000;

					//xil_printf("val = 0x%08X\r\n", val); // test
					
					//$$ reset adc fifo for S3100-ADDA // try without done check
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__ADCH_TI, 4); //(u32 adrs_base, u32 offset, u32 bit_loc);

					// delay
					usleep(1000); // 1000us

					// send trigger info
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_NFDT0 //{
			else if (0==strncmp((char*)cmd_str__PGU_NFDT0,(char*)buf,LEN_CMD_STR__PGU_NFDT0)) { // 0 means eq
				// subfunctions:
				//    void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask)
				//    void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
				//
				// #  `:PGU:NFDT0` + `#H0000nnnn` + `'\n'`
				// #  set number of fifo data
				//
				u32 loc = LEN_CMD_STR__PGU_NFDT0;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					//  // readback
					//  val = pgu_dacx_fdcs_read_repeat();
					//  xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//  //
					//  p_rsp_str = rsp_str;
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					
					//$$ fifo reset 
					//  task CID_FIFO_RESET;
					// 	 begin
					// 	 	CID_CTRL_WR(32'h0000_00C0);
					// 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// 	 end
					//  endtask
					//// dac0 fifo reset 
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000040, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);

					//// set trig data //{
					//  task CID_DAC0_NUM_FFDAT_WR; // (data)
					//  	input  [31:0] data;
					//  	begin
					//  		CID_ADRS_WR(32'h_0000_1000);
					//  		CID_DATA_WR(data);
					//  	end
					//  endtask
					//
					//  task CID_ADRS_WR;
					//  	input  [31:0] adrs;
					//  	begin
					//  		@(posedge clk_10M);
					//  		r_wire_dacx_data    = adrs;
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[8] = 1'b1;
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[8] = 1'b0;
					//  	end
					//  endtask
					//
					//  task CID_DATA_WR;
					//  	input  [31:0] data;
					//  	begin
					//  		@(posedge clk_10M);
					//  		r_wire_dacx_data    = data;  // @EP_ADRS__DACZ_DAT_WI
					//  		@(posedge clk_10M);          
					//  		r_trig_dacx_ctrl[10] = 1'b1; // @EP_ADRS__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[10] = 1'b0;
					//  	end
					//  endtask
					//}
					
					// on dac0
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00001000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_NFDT1 //{
			else if (0==strncmp((char*)cmd_str__PGU_NFDT1,(char*)buf,LEN_CMD_STR__PGU_NFDT1)) { // 0 means eq
				// subfunctions:
				//    void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask)
				//    void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
				//
				// #  `:PGU:NFDT1` + `#H0000nnnn` + `'\n'`
				// #  set number of fifo data
				//
				u32 loc = LEN_CMD_STR__PGU_NFDT1;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					//  // readback
					//  val = pgu_dacx_fdcs_read_repeat();
					//  xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//  //
					//  p_rsp_str = rsp_str;
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					
					//$$ fifo reset 
					//  task CID_FIFO_RESET;
					// 	 begin
					// 	 	CID_CTRL_WR(32'h0000_00C0);
					// 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// 	 end
					//  endtask
					//// dac1 fifo reset 
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000080, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);

					//// set trig data //{
					//  task CID_DAC1_NUM_FFDAT_WR; // (data)
					//  	input  [31:0] data;
					//  	begin
					//  		CID_ADRS_WR(32'h_0000_1010);
					//  		CID_DATA_WR(data);
					//  	end
					//  endtask
					//
					//  task CID_ADRS_WR;
					//  	input  [31:0] adrs;
					//  	begin
					//  		@(posedge clk_10M);
					//  		r_wire_dacx_data    = adrs;
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[8] = 1'b1;
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[8] = 1'b0;
					//  	end
					//  endtask
					//
					//  task CID_DATA_WR;
					//  	input  [31:0] data;
					//  	begin
					//  		@(posedge clk_10M);
					//  		r_wire_dacx_data    = data;  // @EP_ADRS__DACZ_DAT_WI
					//  		@(posedge clk_10M);          
					//  		r_trig_dacx_ctrl[10] = 1'b1; // @EP_ADRS__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[10] = 1'b0;
					//  	end
					//  endtask
					//}
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					// on dac1
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00001010, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			
			// TODO: case of  cmd_str__PGU_FDAT0 //{
			else if (0==strncmp((char*)cmd_str__PGU_FDAT0,(char*)buf,LEN_CMD_STR__PGU_FDAT0)) { // 0 means eq
				// subfunctions:
				//    u32 write_mcs_ep_pi_data(u32 adrs_base, u32 offset, u32 data); // write data from a 32b-value to pipe-in(32b)
				//
				//    EP_ADRS__DAC0_DAT_INC_PI  0x86
				//    EP_ADRS__DAC0_DUR_PI      0x87
				//    EP_ADRS__DAC1_DAT_INC_PI  0x88
				//    EP_ADRS__DAC1_DUR_PI      0x89
				//
				// #  `:PGU:FDAT0` + `#N8_dddddd_hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn_... ..._hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn` + `'\n'` , 
				// #      `hhhh` for DAC value; `mmmm` for incremental step; `nnnnnnnn` for duration count for each DAC value.
				//
				u32 loc = LEN_CMD_STR__PGU_FDAT0; //$$
				u32 val;
				u32 len_byte;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (0==strncmp("#N8_", (char*)&buf[loc], 4)) { // check the numeric block header of hexadecimal bytes
					// read len_byte 
					loc = loc + 4; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
										
					//$$ read "16 byte long data" repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 16;
						// read first data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DAC0_DAT_INC_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// read second data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send  data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DAC0_DUR_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
					}
				 	//
				 	p_rsp_str = rsp_str__OK;					
				}
				else if (0==strncmp("#N_", (char*)&buf[loc], 3)) { // check the numeric block header of hexadecimal bytes
					p_rsp_str = rsp_str__NG;
				}
				else if (0==strncmp("#4_", (char*)&buf[loc], 3)) { // check the numeric block header of binary bytes
					p_rsp_str = rsp_str__NG;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_FDAT1 //{
			else if (0==strncmp((char*)cmd_str__PGU_FDAT1,(char*)buf,LEN_CMD_STR__PGU_FDAT1)) { // 0 means eq
				// subfunctions:
				//    u32 write_mcs_ep_pi_data(u32 adrs_base, u32 offset, u32 data); // write data from a 32b-value to pipe-in(32b)
				//
				//    EP_ADRS__DAC0_DAT_INC_PI  0x86
				//    EP_ADRS__DAC0_DUR_PI      0x87
				//    EP_ADRS__DAC1_DAT_INC_PI  0x88
				//    EP_ADRS__DAC1_DUR_PI      0x89
				//
				// #  `:PGU:FDAT0` + `#N8_dddddd_hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn_... ..._hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn` + `'\n'` , 
				// #      `hhhh` for DAC value; `mmmm` for incremental step; `nnnnnnnn` for duration count for each DAC value.
				//
				u32 loc = LEN_CMD_STR__PGU_FDAT1; //$$
				u32 val;
				u32 len_byte;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (0==strncmp("#N8_", (char*)&buf[loc], 4)) { // check the numeric block header of hexadecimal bytes
					// read len_byte 
					loc = loc + 4; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
					
					//  //$$ fifo reset --> move
					//  //  task CID_FIFO_RESET;
					//  // 	 begin
					//  // 	 	CID_CTRL_WR(32'h0000_00C0);
					//  // 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					//  // 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					//  // 	 end
					//  //  endtask
					//  //// dac1 fifo reset 
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000080, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
					//$$ read "16 byte long data" repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 16;
						// read first data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DAC1_DAT_INC_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// read second data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send  data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DAC1_DUR_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
					}
				 	//
				 	p_rsp_str = rsp_str__OK;					
				}
				else if (0==strncmp("#N_", (char*)&buf[loc], 3)) { // check the numeric block header of hexadecimal bytes
					p_rsp_str = rsp_str__NG;
				}
				else if (0==strncmp("#4_", (char*)&buf[loc], 3)) { // check the numeric block header of binary bytes
					p_rsp_str = rsp_str__NG;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			
			// TODO: case of  cmd_str__PGU_FRPT0 //{
			else if (0==strncmp((char*)cmd_str__PGU_FRPT0,(char*)buf,LEN_CMD_STR__PGU_FRPT0)) { // 0 means eq
				// subfunctions:
				//    void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask)
				//    void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
				//
				// #  `:PGU:FRPT0` + `#H0000nnnn` + `'\n'`
				// #  set number of repeat 
				//
				u32 loc = LEN_CMD_STR__PGU_FRPT0;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					//  // readback
					//  val = pgu_dacx_fdcs_read_repeat();
					//  xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//  //
					//  p_rsp_str = rsp_str;
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					
					//  task CID_DAC0_REPEAT_WR; // (data)
					//  	input  [31:0] data;
					//  	begin
					//  		CID_ADRS_WR(32'h_0000_0020);
					//  		CID_DATA_WR(data);
					//  	end
					//  endtask
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					// on dac0
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000020, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_FRPT1 //{
			else if (0==strncmp((char*)cmd_str__PGU_FRPT1,(char*)buf,LEN_CMD_STR__PGU_FRPT1)) { // 0 means eq
				// subfunctions:
				//    void write_mcs_ep_wi(u32 adrs_base, u32 offset, u32 data, u32 mask)
				//    void activate_mcs_ep_ti(u32 adrs_base, u32 offset, u32 bit_loc);
				//
				// #  `:PGU:FRPT1` + `#H0000nnnn` + `'\n'`
				// #  set number of repeat 
				//
				u32 loc = LEN_CMD_STR__PGU_FRPT1;
				u32 val;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					//  // readback
					//  val = pgu_dacx_fdcs_read_repeat();
					//  xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//  //
					//  p_rsp_str = rsp_str;
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					
					//  task CID_DAC1_REPEAT_WR;
					//  	input  [31:0] data;
					//  	begin
					//  		CID_ADRS_WR(32'h_0000_0030);
					//  		CID_DATA_WR(data);
					//  	end
					//  endtask
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					// on dac1
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000030, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}


			// TODO: case of  cmd_str__PGU_FREQ //{
			else if (0==strncmp((char*)cmd_str__PGU_FREQ,(char*)buf,LEN_CMD_STR__PGU_FREQ)) { // 0 means eq
				// subfunctions:
				//    pgu_clkd_setup(u32 freq_preset)
				//
				// # ":PGU:FREQ 2000 \n" // for 200.0MHz 
				// # ":PGU:FREQ 0200 \n" // for  20.0MHz
				//
				u32 loc = LEN_CMD_STR__PGU_FREQ;
				u32 val;
				u32 val_ret;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (0==is_dec_char(buf[loc])) { // check if the first char is decimal
					// read value
					val = decstr2data_u32((u8*)(buf+loc),4); //$$ read 4-char decimal
					// DACX fpga pll reset
					pgu_dacx_fpga_pll_rst(1, 1, 1);
					//
					usleep(500); // 500us
					// set freq parameter
					val_ret = pgu_clkd_setup(val);
					//
					usleep(500); // 500us
					//
					// DACX fpga pll run : all clock work again.
					pgu_dacx_fpga_pll_rst(0, 0, 0);
					//
					usleep(500); // 500us
				 	
					//$$ DAC input delay tap calibration
					pgu_dacx_cal_input_dtap();
					
					//
					if (val_ret == val)
						p_rsp_str = rsp_str__OK;
					else 
						p_rsp_str = rsp_str__NG;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			// TODO: case of  cmd_str__PGU_OFST_DAC0 //{
			else if (0==strncmp((char*)cmd_str__PGU_OFST_DAC0,(char*)buf,LEN_CMD_STR__PGU_OFST_DAC0)) { // 0 means eq
				// subfunctions:
				//    pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8)
				//    pgu_dac0_reg_read_b8(u32 reg_adrs_b5)
				//
				// reg_adrs_b5 = 0x12, 0x11 (for DAC_ch2_aux); 0x0E, 0x0D (for DAC_ch1_aux)
				//
				// # ":PGU:OFST:DAC0? \n" 
				// # ":PGU:OFST:DAC0 #HC140C140 \n" 
				//
				// data = {DAC_ch1_aux, DAC_ch2_aux}
				// DAC_ch#_aux = {PN_Pol_sel, Source_Sink_sel, 0000, 10 bit data}
				//                PN_Pol_sel      = 0/1 for P/N
				//                Source_Sink_sel = 0/1 for Source/Sink
				//
				// # offset DAC : 0x140 0.625mA, AUX2N active[7] (1) , sink current[6] (1)
				//
				u32 loc = LEN_CMD_STR__PGU_OFST_DAC0;
				u32 val;
				u32 val0_high;
				u32 val0_low;
				u32 val1_high;
				u32 val1_low;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					// read value from device
					val1_high = pgu_dac0_reg_read_b8(0x0E);
					val1_low  = pgu_dac0_reg_read_b8(0x0D);
					val0_high = pgu_dac0_reg_read_b8(0x12);
					val0_low  = pgu_dac0_reg_read_b8(0x11);
					// compose value
					val = (val1_high<<24) + (val1_low<<16) + (val0_high<<8) + val0_low;
					// set response string
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added
					// set response string
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// resolve data
					val1_high = (val>>24) & 0x000000FF;
					val1_low  = (val>>16) & 0x000000FF;
					val0_high = (val>> 8) & 0x000000FF;
					val0_low  = (val>> 0) & 0x000000FF;
					// set data
					pgu_dac0_reg_write_b8(0x0E, val1_high);
					pgu_dac0_reg_write_b8(0x0D, val1_low );
					pgu_dac0_reg_write_b8(0x12, val0_high);
					pgu_dac0_reg_write_b8(0x11, val0_low );
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
				
			// TODO: case of  cmd_str__PGU_OFST_DAC1 //{
			else if (0==strncmp((char*)cmd_str__PGU_OFST_DAC1,(char*)buf,LEN_CMD_STR__PGU_OFST_DAC1)) { // 0 means eq
				// subfunctions:
				//    pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8)
				//    pgu_dac1_reg_read_b8(u32 reg_adrs_b5)
				//
				// reg_adrs_b5 = 0x12, 0x11 (for DAC_ch2_aux); 0x0E, 0x0D (for DAC_ch1_aux)
				//
				// # ":PGU:OFST:DAC1? \n" 
				// # ":PGU:OFST:DAC1 #HC140C140 \n" 
				//
				// data = {DAC_ch1_aux, DAC_ch2_aux}
				// DAC_ch#_aux = {PN_Pol_sel, Source_Sink_sel, 0000, 10 bit data}
				//                PN_Pol_sel      = 0/1 for P/N
				//                Source_Sink_sel = 0/1 for Source/Sink
				//
				// # offset DAC : 0x140 0.625mA, AUX2N active[7] (1) , sink current[6] (1)
				//
				u32 loc = LEN_CMD_STR__PGU_OFST_DAC1;
				u32 val;
				u32 val0_high;
				u32 val0_low;
				u32 val1_high;
				u32 val1_low;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					// read value from device
					val1_high = pgu_dac1_reg_read_b8(0x0E);
					val1_low  = pgu_dac1_reg_read_b8(0x0D);
					val0_high = pgu_dac1_reg_read_b8(0x12);
					val0_low  = pgu_dac1_reg_read_b8(0x11);
					// compose value
					val = (val1_high<<24) + (val1_low<<16) + (val0_high<<8) + val0_low;
					// set response string
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added
					// set response string
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// resolve data
					val1_high = (val>>24) & 0x000000FF;
					val1_low  = (val>>16) & 0x000000FF;
					val0_high = (val>> 8) & 0x000000FF;
					val0_low  = (val>> 0) & 0x000000FF;
					// set data
					pgu_dac1_reg_write_b8(0x0E, val1_high);
					pgu_dac1_reg_write_b8(0x0D, val1_low );
					pgu_dac1_reg_write_b8(0x12, val0_high);
					pgu_dac1_reg_write_b8(0x11, val0_low );
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			// TODO: case of  cmd_str__PGU_GAIN_DAC0 //{
			else if (0==strncmp((char*)cmd_str__PGU_GAIN_DAC0,(char*)buf,LEN_CMD_STR__PGU_GAIN_DAC0)) { // 0 means eq
				// subfunctions:
				//    pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8)
				//    pgu_dac0_reg_read_b8(u32 reg_adrs_b5)
				//
				// reg_adrs_b5 = 0x10, 0x0F (for DAC_ch2_fsc); 0x0C, 0x0B (for DAC_ch1_fsc)
				//
				// # ":PGU:GAIN:DAC0? \n" 
				// # ":PGU:GAIN:DAC0 #H02D002D0 \n" 
				//
				// data = {DAC_ch1_fsc, DAC_ch2_fsc}
				// DAC_ch#_fsc = {000000, 10 bit data}
				//
				// # full scale DAC : 28.1mA  @ 0x02D0
				//
				u32 loc = LEN_CMD_STR__PGU_GAIN_DAC0;
				u32 val;
				u32 val0_high;
				u32 val0_low;
				u32 val1_high;
				u32 val1_low;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					// read value from device
					val1_high = pgu_dac0_reg_read_b8(0x0C);
					val1_low  = pgu_dac0_reg_read_b8(0x0B);
					val0_high = pgu_dac0_reg_read_b8(0x10);
					val0_low  = pgu_dac0_reg_read_b8(0x0F);
					// compose value
					val = (val1_high<<24) + (val1_low<<16) + (val0_high<<8) + val0_low;
					// set response string
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added
					// set response string
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// resolve data
					val1_high = (val>>24) & 0x000000FF;
					val1_low  = (val>>16) & 0x000000FF;
					val0_high = (val>> 8) & 0x000000FF;
					val0_low  = (val>> 0) & 0x000000FF;
					// set data
					pgu_dac0_reg_write_b8(0x0C, val1_high);
					pgu_dac0_reg_write_b8(0x0B, val1_low );
					pgu_dac0_reg_write_b8(0x10, val0_high);
					pgu_dac0_reg_write_b8(0x0F, val0_low );
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}		
			}
			//}

			// TODO: case of  cmd_str__PGU_GAIN_DAC1 //{
			else if (0==strncmp((char*)cmd_str__PGU_GAIN_DAC1,(char*)buf,LEN_CMD_STR__PGU_GAIN_DAC1)) { // 0 means eq
				// subfunctions:
				//    pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8)
				//    pgu_dac1_reg_read_b8(u32 reg_adrs_b5)
				//
				// reg_adrs_b5 = 0x10, 0x0F (for DAC_ch2_fsc); 0x0C, 0x0B (for DAC_ch1_fsc)
				//
				// # ":PGU:GAIN:DAC1? \n" 
				// # ":PGU:GAIN:DAC1 #H02D002D0 \n" 
				//
				// data = {DAC_ch1_fsc, DAC_ch2_fsc}
				// DAC_ch#_fsc = {000000, 10 bit data}
				//
				// # full scale DAC : 28.1mA  @ 0x02D0
				//
				u32 loc = LEN_CMD_STR__PGU_GAIN_DAC1;
				u32 val;
				u32 val0_high;
				u32 val0_low;
				u32 val1_high;
				u32 val1_low;
				//
				// skip spaces ' ' and tap //{
				while (1) {
					if      (buf[loc]==' ') loc++;
					else if (buf[loc]=='\t') loc++;
					else break;
				}
				//
#ifdef _SCPI_DEBUG_
				xil_printf("para:%s\n",(char*)buf+loc);
#endif
				//}
				
				// make scpi response string
				if (buf[loc]=='?') {
					// read value from device
					val1_high = pgu_dac1_reg_read_b8(0x0C);
					val1_low  = pgu_dac1_reg_read_b8(0x0B);
					val0_high = pgu_dac1_reg_read_b8(0x10);
					val0_low  = pgu_dac1_reg_read_b8(0x0F);
					// compose value
					val = (val1_high<<24) + (val1_low<<16) + (val0_high<<8) + val0_low;
					// set response string
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added
					// set response string
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// resolve data
					val1_high = (val>>24) & 0x000000FF;
					val1_low  = (val>>16) & 0x000000FF;
					val0_high = (val>> 8) & 0x000000FF;
					val0_low  = (val>> 0) & 0x000000FF;
					// set data
					pgu_dac1_reg_write_b8(0x0C, val1_high);
					pgu_dac1_reg_write_b8(0x0B, val1_low );
					pgu_dac1_reg_write_b8(0x10, val0_high);
					pgu_dac1_reg_write_b8(0x0F, val0_low );
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}		
			}
			//}
			
#endif


			//// TODO: unknown command --------////
			
			// TODO: case of  unknown //{
			else { // unknown commands 
				//p_rsp_str = rsp_str__NULL;
				p_rsp_str = rsp_str__NG;
			}
			//}
			
			//}
			
			// send response //{
			//
			size = strlen((char*)p_rsp_str);
			ret = send_response_all(sn, p_rsp_str, size); //$$
			if (ret < 0) {
				close(sn);
				return ret;
			}
			//}
			
			} //}
			
			else { // recv size 0 //{
				if (flag_get_rx==0) {
					cnt_stay_SOCK_ESTABLISHED = cnt_stay_SOCK_ESTABLISHED - 1;
				}
				else {
					flag_get_rx = 0;
					cnt_stay_SOCK_ESTABLISHED = MAX_CNT_STAY_SOCK_ESTABLISHED;
				}
#ifdef _SCPI_DEBUG_
				xil_printf("connected socket has no recv data: cnt_stay_SOCK_ESTABLISHED:%d \r",(int)cnt_stay_SOCK_ESTABLISHED);
#endif
				if (MAX_CNT_STAY_SOCK_ESTABLISHED!=0 && cnt_stay_SOCK_ESTABLISHED==0) { 
#ifdef _SCPI_DEBUG_
					xil_printf("connected socket has no activity; force to close: cnt_stay_SOCK_ESTABLISHED:%d \r\n",(int)cnt_stay_SOCK_ESTABLISHED);
#endif
					// close socket
					close(sn);
				}
			} //}
			
			//}
			
			break;
		//}
		case SOCK_CLOSE_WAIT : //{
#ifdef _SCPI_DEBUG_
			//xil_printf("%d:CloseWait \r\n",sn);
#endif
			if((ret=disconnect(sn)) != SOCK_OK) return ret;
#ifdef _SCPI_DEBUG_MIN_
			xil_printf("%d:Socket closed \r\n",sn);
#endif
			break;
		//}
		case SOCK_INIT : //{
#ifdef _SCPI_DEBUG_MIN_
			xil_printf("%d:Listen, TCP server, port [%d] \r\n",sn, port);
#endif
			if( (ret = listen(sn)) != SOCK_OK) return ret;
			break;
		//}
		case SOCK_CLOSED: //{
#ifdef _SCPI_DEBUG_MIN_
			//xil_printf("%d:TCP server start \r\n",sn);
#endif
			flag_SOCK_ESTABLISHED = 0;
			if((ret=socket(sn, Sn_MR_TCP, port, 0x00)) != sn)
			//if((ret=socket(sn, Sn_MR_TCP, port, SF_TCP_NODELAY)) != sn) //$$ fast ack //$$ some NG
			//if((ret=socket(sn, Sn_MR_TCP, port, Sn_MR_ND)) != sn)
			return ret;
#ifdef _SCPI_DEBUG_MIN_
			xil_printf("%d:Socket opened \r\n",sn);
			//xil_printf("%d:Opened, TCP server, port [%d] \r\n",sn, port);
#endif
			break;
		//}
		case SOCK_LISTEN: //{
			//$$ nothing to do...
			break;
		//}
		default: //{
			break;
		//}
	}
	return 1;

}	
//}


//}
















