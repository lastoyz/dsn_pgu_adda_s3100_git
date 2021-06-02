//#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "xil_printf.h" // print() for pure string; xil_printf() for formatted string
#include "microblaze_sleep.h" // for usleep

#include "../../Ethernet/socket.h"
#include "scpi.h"


//$$ #include "../../../mhvsu_base_config.h" //$$ board dependent

#include "../../../mcs_io_bridge_ext.h" //$$ board dependent
#include "../../../xil_sprintf.h" // modified from // https://gist.github.com/raczben/a8b5410440b601ce6e7d64fd96b2d79d



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
uint8_t* cmd_str__EPS_WMI  = (uint8_t*)":EPS:WMI";
uint8_t* cmd_str__EPS_WMO  = (uint8_t*)":EPS:WMO";
uint8_t* cmd_str__EPS_TAC  = (uint8_t*)":EPS:TAC";
uint8_t* cmd_str__EPS_TMO  = (uint8_t*)":EPS:TMO"; // return ON or OFF
uint8_t* cmd_str__EPS_TWO  = (uint8_t*)":EPS:TWO";  // return 32-bit word
uint8_t* cmd_str__EPS_PI   = (uint8_t*)":EPS:PI";
uint8_t* cmd_str__EPS_PO   = (uint8_t*)":EPS:PO";
// uint8_t* cmd_str__EPS_MKWI = (uint8_t*)":EPS:MKWI";  // not used
// uint8_t* cmd_str__EPS_MKWO = (uint8_t*)":EPS:MKWO";  // not used
// uint8_t* cmd_str__EPS_MKTI = (uint8_t*)":EPS:MKTI";  // not used
// uint8_t* cmd_str__EPS_MKTO = (uint8_t*)":EPS:MKTO";  // not used
// uint8_t* cmd_str__EPS_WI   = (uint8_t*)":EPS:WI";    // not used
// uint8_t* cmd_str__EPS_WO   = (uint8_t*)":EPS:WO";    // not used
// uint8_t* cmd_str__EPS_TI   = (uint8_t*)":EPS:TI";    // not used
// uint8_t* cmd_str__EPS_TO   = (uint8_t*)":EPS:TO";    // not used


#ifdef _SCPI_CMD_PGU_

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
//
uint8_t* cmd_str__PGU_DCS_TRIG       = (uint8_t*)":PGU:DCS:TRIG";
uint8_t* cmd_str__PGU_DCS_DAC0_PNT   = (uint8_t*)":PGU:DCS:DAC0:PNT";
uint8_t* cmd_str__PGU_DCS_DAC1_PNT   = (uint8_t*)":PGU:DCS:DAC1:PNT";
uint8_t* cmd_str__PGU_DCS_RPT        = (uint8_t*)":PGU:DCS:RPT";
uint8_t* cmd_str__PGU_FDCS_TRIG      = (uint8_t*)":PGU:FDCS:TRIG";
uint8_t* cmd_str__PGU_FDCS_DAC0      = (uint8_t*)":PGU:FDCS:DAC0";
uint8_t* cmd_str__PGU_FDCS_DAC1      = (uint8_t*)":PGU:FDCS:DAC1";
uint8_t* cmd_str__PGU_FDCS_RPT       = (uint8_t*)":PGU:FDCS:RPT";
uint8_t* cmd_str__PGU_PRD            = (uint8_t*)":PGU:PRD"; //$$
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
// #define LEN_CMD_STR__EPS_MKWI           (strlen((const char *)cmd_str__EPS_MKWI))
// #define LEN_CMD_STR__EPS_MKWO           (strlen((const char *)cmd_str__EPS_MKWO))
// #define LEN_CMD_STR__EPS_MKTI           (strlen((const char *)cmd_str__EPS_MKTI))
// #define LEN_CMD_STR__EPS_MKTO           (strlen((const char *)cmd_str__EPS_MKTO))
// #define LEN_CMD_STR__EPS_WI             (strlen((const char *)cmd_str__EPS_WI  ))
// #define LEN_CMD_STR__EPS_WO             (strlen((const char *)cmd_str__EPS_WO  ))
// #define LEN_CMD_STR__EPS_TI             (strlen((const char *)cmd_str__EPS_TI  ))
// #define LEN_CMD_STR__EPS_TO             (strlen((const char *)cmd_str__EPS_TO  ))



#ifdef _SCPI_CMD_PGU_
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
// 
#define LEN_CMD_STR__PGU_DCS_TRIG        (strlen((const char *) cmd_str__PGU_DCS_TRIG     ))
#define LEN_CMD_STR__PGU_DCS_DAC0_PNT    (strlen((const char *) cmd_str__PGU_DCS_DAC0_PNT ))
#define LEN_CMD_STR__PGU_DCS_DAC1_PNT    (strlen((const char *) cmd_str__PGU_DCS_DAC1_PNT ))
#define LEN_CMD_STR__PGU_DCS_RPT         (strlen((const char *) cmd_str__PGU_DCS_RPT      ))
#define LEN_CMD_STR__PGU_FDCS_TRIG       (strlen((const char *) cmd_str__PGU_FDCS_TRIG    ))
#define LEN_CMD_STR__PGU_FDCS_DAC0       (strlen((const char *) cmd_str__PGU_FDCS_DAC0    ))
#define LEN_CMD_STR__PGU_FDCS_DAC1       (strlen((const char *) cmd_str__PGU_FDCS_DAC1    ))
#define LEN_CMD_STR__PGU_FDCS_RPT        (strlen((const char *) cmd_str__PGU_FDCS_RPT     ))
#define LEN_CMD_STR__PGU_PRD             (strlen((const char *) cmd_str__PGU_PRD          ))
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

//// SCPI servers : scpi_tcps_ep / scpi_tcps_ep_state //{

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
				val = pgu_read_fpga_image_id();
				xil_sprintf((char*)rsp_str,"#H%08X\n", (unsigned int)val);
				p_rsp_str = rsp_str;
			}
			//}
			
			// TODO: case of  cmd_str__FPGA_TMP //{
			else if (0==strncmp((char*)cmd_str__FPGA_TMP,(char*)buf,LEN_CMD_STR__FPGA_TMP)) { // 0 means eq
				u32 val;
				//
				val = pgu_read_fpga_temperature();
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
					//p_rsp_str = rsp_str__OK;
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
			

			//// TODO: PGU command --------////

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
					u32 val_s0;
					u32 val_s1;

					// read power status 
					val = pgu_spio_ext_pwr_led_readback();
					val_s0 = (val>>0) & 0x0001;
					val_s1 = (val>>1) & 0x0001;
					// DAC power on
					pgu_spio_ext_pwr_led(1, 1, val_s1, val_s0); // (led, pwr_dac, pwr_adc, pwr_amp)
					// DAC power on
					//pgu_spio_ext_pwr_led(1, 1, 0, 0); // test for no amp power
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
					pgu_dacx_setup(); 
					//
					// DACX_PG setup
					pgu_dacx_pg_setup();
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// DAC power off
					pgu_spio_ext_pwr_led(0, 0, 0, 0);
					p_rsp_str = rsp_str__OK;
					
					// TODO: consider pll off by reset  vs  clock dis
					//pgu_dacx_fpga_pll_rst(1, 1, 1);
					pgu_dacx_fpga_clk_dis(1, 1);
					
					// note :PGU:SLP sleep command to consider for disabling dac clocks and zeroing dac output.
					
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
					// read power status 
					val = pgu_spio_ext_pwr_led_readback();
					val_s1 = (val>>1) & 0x0001;
					val_s2 = (val>>2) & 0x0001;
					val_s3 = (val>>3) & 0x0001;
					// output power on
					pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 1);
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// local var
					u32 val_s1;
					u32 val_s2;
					u32 val_s3;
					// read power status 
					val = pgu_spio_ext_pwr_led_readback();
					val_s1 = (val>>1) & 0x0001;
					val_s2 = (val>>2) & 0x0001;
					val_s3 = (val>>3) & 0x0001;
					// output power off
					pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 0);
					//
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
				//    u32  pgu_dacx__read_status() //$$
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
					val = pgu_dacx__read_status();
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
					pgu_spio_ext__send_aux_IO_CON(val);
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
					pgu_spio_ext__send_aux_IO_OLAT(val);
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
					pgu_spio_ext__send_aux_IO_DIR(val);
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
					pgu_spio_ext__send_aux_IO_GPIO(val);
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
			
			
			// TODO: case of  cmd_str__PGU_DCS_TRIG //{
			else if (0==strncmp((char*)cmd_str__PGU_DCS_TRIG,(char*)buf,LEN_CMD_STR__PGU_DCS_TRIG)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_dcs_run_test()
				//    pgu_dacx_dcs_stop_test()
				//
				u32 loc = LEN_CMD_STR__PGU_DCS_TRIG;
				//u32 val;
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
					// 
					p_rsp_str = rsp_str__NG;
				}
				else if (0==strncmp("ON", (char*)&buf[loc], 2)) {
					// trig on
					pgu_dacx_dcs_run_test();
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// trig off
					pgu_dacx_dcs_stop_test();
					//
					p_rsp_str = rsp_str__OK;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}

			// TODO: case of  cmd_str__PGU_DCS_DAC0_PNT //{
			else if (0==strncmp((char*)cmd_str__PGU_DCS_DAC0_PNT,(char*)buf,LEN_CMD_STR__PGU_DCS_DAC0_PNT)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_dcs_write_adrs()
				//    pgu_dacx_dcs_read_data_dac0()
				//    pgu_dacx_dcs_write_data_dac0(u32 val_b32)
				//
				// # ":PGU:DCS:DAC0:PNT#H0001? \n"
				// # ":PGU:DCS:DAC0:PNT#H0001 #H00040001 \n"
				//
				u32 loc = LEN_CMD_STR__PGU_DCS_DAC0_PNT; //$$
				u32 val;
				u32 ofs; 
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),4); //$$ length 4 char
					loc = loc + 4; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%04X\n",(unsigned int)ofs); //$$ length 4 char
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// read command 
					if (buf[loc]=='?') { 
						//
						pgu_dacx_dcs_write_adrs(ofs);        //$$
						val = pgu_dacx_dcs_read_data_dac0(); //$$
						//
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n\0"
						p_rsp_str = rsp_str;
					}
					// write command
					else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%08X\n",(unsigned int)val); 
#endif
						//
						pgu_dacx_dcs_write_adrs(ofs);        //$$
						pgu_dacx_dcs_write_data_dac0(val); //$$
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
			
			// TODO: case of  cmd_str__PGU_DCS_DAC1_PNT //{
			else if (0==strncmp((char*)cmd_str__PGU_DCS_DAC1_PNT,(char*)buf,LEN_CMD_STR__PGU_DCS_DAC1_PNT)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_dcs_write_adrs()
				//    pgu_dacx_dcs_read_data_dac1()
				//    pgu_dacx_dcs_write_data_dac1(u32 val_b32)
				//
				// # ":PGU:DCS:DAC1:PNT#H0001? \n"
				// # ":PGU:DCS:DAC1:PNT#H0001 #H00040001 \n"
				//
				u32 loc = LEN_CMD_STR__PGU_DCS_DAC1_PNT; //$$
				u32 val;
				u32 ofs; 
				//
				// find offset 
				if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read offset
					loc = loc + 2; // locate the numeric parameter head
					ofs = hexstr2data_u32((u8*)(buf+loc),4); //$$ length 4 char
					loc = loc + 4; //		
#ifdef _SCPI_DEBUG_
					xil_printf("check: 0x%04X\n",(unsigned int)ofs); //$$ length 4 char
#endif
					// skip spaces ' ' and tap
					while (1) {
						if      (buf[loc]==' ') loc++;
						else if (buf[loc]=='\t') loc++;
						else break;
					}
					// read command 
					if (buf[loc]=='?') { 
						//
						pgu_dacx_dcs_write_adrs(ofs);        //$$
						val = pgu_dacx_dcs_read_data_dac1(); //$$
						//
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "#H00000002\n\0"
						p_rsp_str = rsp_str;
					}
					// write command
					else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
						loc = loc + 2; // locate the numeric parameter head
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("check: 0x%08X\n",(unsigned int)val); 
#endif
						//
						pgu_dacx_dcs_write_adrs(ofs);        //$$
						pgu_dacx_dcs_write_data_dac1(val); //$$
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
			}			//}
			
			// TODO: case of  cmd_str__PGU_DCS_RPT //{
			else if (0==strncmp((char*)cmd_str__PGU_DCS_RPT,(char*)buf,LEN_CMD_STR__PGU_DCS_RPT)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_dcs_read_repeat()
				//    pgu_dacx_dcs_write_repeat(u32 val_b32)
				//
				//    DACn repeat count = {16-bit DAC1 repeat count, 16-bit DAC0 repeat count}
				//
				// # ":PGU:DCS:RPT? \n"
				// # ":PGU:DCS:RPT #H00040001 \n"
				//
				u32 loc = LEN_CMD_STR__PGU_DCS_RPT;
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
					val = pgu_dacx_dcs_read_repeat();
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// set repeat data
					pgu_dacx_dcs_write_repeat(val);
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}


			// TODO: case of  cmd_str__PGU_FDCS_TRIG //{
			else if (0==strncmp((char*)cmd_str__PGU_FDCS_TRIG,(char*)buf,LEN_CMD_STR__PGU_FDCS_TRIG)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_fdcs_run_test()
				//    pgu_dacx_fdcs_stop_test()
				//
				// # ":PGU:FDCS:TRIG ON \n"
				// # ":PGU:FDCS:TRIG OFF \n"
				//
				u32 loc = LEN_CMD_STR__PGU_FDCS_TRIG;
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
					// 
					p_rsp_str = rsp_str__NG;
				}
				else if (0==strncmp("ON", (char*)&buf[loc], 2)) {
					// trig on
					pgu_dacx_fdcs_run_test();
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("OFF", (char*)&buf[loc], 3)) {
					// trig off
					pgu_dacx_fdcs_stop_test();
					//
					p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("AUTO", (char*)&buf[loc], 2)) {
					
					// sleep control: amp on
					u32 OLAT;
					OLAT = pgu_spio_ext__read_aux_IO_OLAT ();
					pgu_spio_ext__send_aux_IO_OLAT  (OLAT | 0x0300); // 16 bit // loc sleeps
					
					// trig on
					pgu_dacx_fdcs_run_test();
					
					//$$ status check 
					// wire [31:0] w_status_data = {30'b0, r_dac1_active_clk, r_dac0_active_clk};
					val = pgu_dacx__read_status();
					xil_printf("dacx_status:0x%08X\r\n",(int)val);
					
					// find val!=0
					u32 cnt_wait_one = 100;
					while (1) {
						if (val!=0) break;
						cnt_wait_one--;
						if (cnt_wait_one==0) break;
						val = pgu_dacx__read_status();
						xil_printf("dacx_status:0x%08X\r\n",(int)val);
					}
										
					// find val==0
					u32 cnt_one = 0;
					while (1) {
						if (val==0) break;
						val = pgu_dacx__read_status();
						xil_printf("dacx_status:0x%08X\r\n",(int)val);
						cnt_one++;
					}
					xil_printf("count pulse status high:%d\r\n",(int)cnt_one);

					// trig off
					pgu_dacx_fdcs_stop_test();

					// sleep control: amp off
					pgu_spio_ext__send_aux_IO_OLAT  (OLAT & 0xFCFF); // 16 bit // loc sleeps
					
					
					//
					p_rsp_str = rsp_str__OK;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_FDCS_DAC0 //{
			else if (0==strncmp((char*)cmd_str__PGU_FDCS_DAC0,(char*)buf,LEN_CMD_STR__PGU_FDCS_DAC0)) { // 0 means eq
				// subfunctions:
				//    pgu_dac0_fifo_write_data(u32 val_b32)
				//
				// # :PGU:FDCS:DAC0 #H_nnnnnn_hhhhhhhh_hhhhhhhh_..._hhhhhhhh <NL>
				// # :PGU:FDCS:DAC0 #4_nnnnnn_rrrrrrrr...rrrr <NL>
				// 
				// # :PGU:FDCS:DAC0 #H_000064_3FFF0002_7FFF0004_3FFF0002_00000001_C0000002_80000004_C0000002_00000001 <NL>
				// # :PGU:FDCS:DAC0 #4_000032_rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr <NL>
				//
				// hexadecimal vs binary format (reserved)
				//
				u32 loc = LEN_CMD_STR__PGU_FDCS_DAC0; //$$
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
				if (0==strncmp("#N_", (char*)&buf[loc], 3)) { // check the numeric block header of hexadecimal bytes
					// read len_byte 
					loc = loc + 3; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
					// read 8 bytes long data repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 8;
						// read data
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8;
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
						// set data
						pgu_dac0_fifo_write_data(val);
					}
				 	//
				 	p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#4_", (char*)&buf[loc], 3)) { // check the numeric block header of binary bytes
					p_rsp_str = rsp_str__NG;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_FDCS_DAC1 //{
			else if (0==strncmp((char*)cmd_str__PGU_FDCS_DAC1,(char*)buf,LEN_CMD_STR__PGU_FDCS_DAC1)) { // 0 means eq
				// subfunctions:
				//    pgu_dac1_fifo_write_data(u32 val_b32)
				//
				// # :PGU:FDCS:DAC1 #H_nnnnnn_hhhhhhhh_hhhhhhhh_..._hhhhhhhh <NL>
				// # :PGU:FDCS:DAC1 #4_nnnnnn_rrrrrrrr...rrrr <NL>
				// 
				// # :PGU:FDCS:DAC1 #N_000064_3FFF0008_7FFF0010_3FFF0008_00000004_C0000008_80000010_C0000008_00000004 <NL>
				// # :PGU:FDCS:DAC1 #4_000032_rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr <NL>
				//
				// hexadecimal vs binary format (reserved)
				//
				u32 loc = LEN_CMD_STR__PGU_FDCS_DAC1; //$$
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
				if (0==strncmp("#N_", (char*)&buf[loc], 3)) { // check the numeric block header of hexadecimal bytes
					// read len_byte 
					loc = loc + 3; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
					// read 8 bytes long data repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 8;
						// read data
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8;
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
						// set data
						pgu_dac1_fifo_write_data(val);
					}
				 	//
				 	p_rsp_str = rsp_str__OK;
				}
				else if (0==strncmp("#4_", (char*)&buf[loc], 3)) { // check the numeric block header of binary bytes
					p_rsp_str = rsp_str__NG;
				}
				else {
					p_rsp_str = rsp_str__NG;
				}
			}
			//}
			
			// TODO: case of  cmd_str__PGU_FDCS_RPT //{
			else if (0==strncmp((char*)cmd_str__PGU_FDCS_RPT,(char*)buf,LEN_CMD_STR__PGU_FDCS_RPT)) { // 0 means eq
				// subfunctions:
				//    pgu_dacx_fdcs_read_repeat()
				//    pgu_dacx_fdcs_write_repeat(u32 val_b32)
				//
				//    DACn repeat count = {16-bit DAC1 repeat count, 16-bit DAC0 repeat count}
				//
				// # ":PGU:FDCS:RPT? \n"
				// # ":PGU:FDCS:RPT #H00040001 \n"
				//
				u32 loc = LEN_CMD_STR__PGU_FDCS_RPT;
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
					val = pgu_dacx_fdcs_read_repeat();
					xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
					//
					p_rsp_str = rsp_str;
				}
				else if (0==strncmp("#H", (char*)&buf[loc], 2)) {
					// read value 
					loc = loc + 2; // locate the numeric parameter head
					val = hexstr2data_u32((u8*)(buf+loc),8);
					// set repeat data
					pgu_dacx_fdcs_write_repeat(val);
				 	//
				 	p_rsp_str = rsp_str__OK;
				 }
				else {
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
					//  		r_wire_dacx_data    = data;  // @EP_ADRS_PGU__DACZ_DAT_WI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[12] = 1'b1; // @EP_ADRS_PGU__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[12] = 1'b0;
					//  	end
					//  endtask
					
					// val == 0x00000001 --> val = 0x00000010
					// val == 0x00010000 --> val = 0x00000020
					// val == 0x00010001 --> val = 0x00000030

					if      (val == 0x00000001) val = 0x00000010;
					else if (val == 0x00010000) val = 0x00000020;
					else if (val == 0x00010001) val = 0x00000030;
					else                        val = 0x00000000;
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000040, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);

					//// set trig data
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
					//  		r_wire_dacx_data    = data;  // @EP_ADRS_PGU__DACZ_DAT_WI
					//  		@(posedge clk_10M);          
					//  		r_trig_dacx_ctrl[10] = 1'b1; // @EP_ADRS_PGU__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[10] = 1'b0;
					//  	end
					//  endtask
					//
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					// on dac0
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00001000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000080, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);

					//// set trig data
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
					//  		r_wire_dacx_data    = data;  // @EP_ADRS_PGU__DACZ_DAT_WI
					//  		@(posedge clk_10M);          
					//  		r_trig_dacx_ctrl[10] = 1'b1; // @EP_ADRS_PGU__DACZ_DAT_TI
					//  		@(posedge clk_10M);
					//  		r_trig_dacx_ctrl[10] = 1'b0;
					//  	end
					//  endtask
					//
					
					//xil_printf("val = 0x%08X\r\n", val); // test
					
					// on dac1
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00001010, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
				//    EP_ADRS_PGU__DAC0_DAT_INC_PI  0x86
				//    EP_ADRS_PGU__DAC0_DUR_PI      0x87
				//    EP_ADRS_PGU__DAC1_DAT_INC_PI  0x88
				//    EP_ADRS_PGU__DAC1_DUR_PI      0x89
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
					
					// //$$ fifo reset --> move
					// //  task CID_FIFO_RESET;
					// // 	 begin
					// // 	 	CID_CTRL_WR(32'h0000_00C0);
					// // 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// // 	 	CID_CTRL_WR(32'h0000_0000); // wair for reset done
					// // 	 end
					// //  endtask
					// //// dac0 fifo reset 
					// write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000040, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					// activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					// write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					// activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					// write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					// activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS_PGU__DAC0_DAT_INC_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// read second data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send  data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS_PGU__DAC0_DUR_PI,val); //(u32 adrs_base, u32 offset, u32 data);
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
					// read len_byte 
					loc = loc + 3; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
					// read 8 bytes long data repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 8;
						// read data
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8;
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
						// send every data
						pgu_dac0_fifo_write_data(val);
					}
				 	//
				 	p_rsp_str = rsp_str__OK;
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
				//    EP_ADRS_PGU__DAC0_DAT_INC_PI  0x86
				//    EP_ADRS_PGU__DAC0_DUR_PI      0x87
				//    EP_ADRS_PGU__DAC1_DAT_INC_PI  0x88
				//    EP_ADRS_PGU__DAC1_DUR_PI      0x89
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
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000080, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					//  write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					//  activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS_PGU__DAC1_DAT_INC_PI,val); //(u32 adrs_base, u32 offset, u32 data);
						// read second data
						val = hexstr2data_u32((u8*)(buf+loc),8);
#ifdef _SCPI_DEBUG_
						xil_printf("val = 0x%08X\r\n", val); // test
#endif
						loc = loc + 8;
						// send  data
						write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS_PGU__DAC1_DUR_PI,val); //(u32 adrs_base, u32 offset, u32 data);
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
					// read len_byte 
					loc = loc + 3; // locate the numeric parameter head //$$
					len_byte = decstr2data_u32((u8*)(buf+loc),6);
					// locate the first byte of data
					loc = loc + 7; // locate the numeric parameter head //$$
					// read 8 bytes long data repeatly
					while (len_byte > 0) {
						len_byte = len_byte - 8;
						// read data
						val = hexstr2data_u32((u8*)(buf+loc),8);
						loc = loc + 8;
						// skip '_'
						while (1) {
							if      (buf[loc]=='_') loc++;
							else break;
						}
						// send every data
						pgu_dac1_fifo_write_data(val);
					}
				 	//
				 	p_rsp_str = rsp_str__OK;
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
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000020, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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
					
					// on dac0
					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, 0x00000030, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);

					write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
					activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS_PGU__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
					
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


// TODO: scpi_tcps_ep_state() ================ //{
	
enum _state_scpi_cmd {
	scpi_cmd__ready=0, // find leading one char
	scpi_cmd__start, // find cmd string
	scpi_cmd__done,  // finish cmd
	scpi_cmd__done__EPS_PO, // finish for pipe out
	//
	scpi_cmd__RST=10,     // *RST\n   5
	scpi_cmd__IDN,     // *IDN?\n  6
	//
	scpi_cmd__EPS_EN=20, // :EPS:EN  7
	scpi_cmd__EPS_WMI, // :EPS:WMI 8
	scpi_cmd__EPS_WMO, // :EPS:WMO 8
	scpi_cmd__EPS_TAC, // :EPS:TAC 8
	scpi_cmd__EPS_TMO, // :EPS:TMO 8
	scpi_cmd__EPS_TWO, // :EPS:TWO 8
	scpi_cmd__EPS_PI , // :EPS:PI  7
	scpi_cmd__EPS_PO , // :EPS:PO  7
	//
	scpi_cmd__ECHO=30   // echo each byte with no chance of command...
} state_scpi_cmd = scpi_cmd__ready;


static uint8_t* p_cmd_buf_wr;
static uint8_t* p_cmd_buf_rd;
static u32 cnt_cmd_buf;


enum _state_scpi_para {
	scpi_para__ready=0, 
	scpi_para__test,  // test echo parameter string
	scpi_para__done ,
	//
	scpi_para__SW=10, //  ON/OFF
	scpi_para__B1_W1_W2,
	scpi_para__B1_W1,
	scpi_para__B1_B2,
	scpi_para__B1_D1,
	scpi_para__B1_N1,
	//scpi_para__B1, //  8-bit para1
	//scpi_para__B2, //  8-bit para2
	//scpi_para__W1, // 32-bit para1
	//scpi_para__W2, // 32-bit para2
	//
	//scpi_para__N,   // numeric block
	scpi_para__NG=30
} state_scpi_para = scpi_para__ready;


typedef enum {
	OFF,
	ON
} scpi_para__SW_t;

typedef enum {
	NG,
	OK
} scpi_para__OK_t;

//static u8  para_Q;  // 1 for ?, 0 for no 
//static u8  para_SW; // 

static scpi_para__OK_t  status_scpi_para =OK;
static scpi_para__SW_t  EPS_EN_SW =OFF;
//
static scpi_para__SW_t  para_SW =OFF;
static u32 para_b1, para_b2;
static u32 para_w1, para_w2; 
static u32 para_d1; 
static u32 para_n1; 

//static u32 para_len_N;
static u32 cnt_N1;
static u32 len_pipe;


static uint8_t rsp_str[RSP_BUF_SIZE_SCPI];
static uint8_t* p_rsp_str = 0;

int32_t scpi_tcps_ep_state (uint8_t sn, uint8_t* buf, uint16_t port) //$$
{
	// vars //{
	int32_t ret; //, ret2; //$$ remove
	uint16_t size = 0;
	//int32_t ii; //$$ remove
	//int32_t flag__found_newline; //$$ remove
	//
#ifdef _SCPI_DEBUG_MIN_
	uint8_t destip[4];
	uint16_t destport;
#endif
	uint8_t sr; //$$
#ifdef _SCPI_DEBUG_WCMSG_
	uint8_t* msg_welcome = (uint8_t*)"> SCPI TCP server is established: \r\n";
#endif
	//uint8_t rsp_str[RSP_BUF_SIZE_SCPI]; //$$ go to static
	//uint8_t* p_rsp_str; //$$ go to static
	//}

	switch(sr=getSn_SR(sn))
	{
		
		case SOCK_ESTABLISHED : //{
			
			//// case of new establish //{
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
			state_scpi_cmd = scpi_cmd__ready;
			p_cmd_buf_wr = buf;
			p_cmd_buf_rd = buf;
			cnt_cmd_buf  = 0;
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
			
			//// check rx activity //{
			if((size = getSn_RX_RSR(sn)) > 0) { 
				// set rx activity flag
				flag_get_rx = 1;
				//
				//f_cmd_buf_in(sn,buf,size);
				//
			}
			else { // recv size 0 // rx activity check  //{
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
			
			//// TODO: update state_scpi_cmd and do process //{
			if      (state_scpi_cmd==scpi_cmd__ready) {
				size = getSn_RX_RSR(sn);
				if (size > 0) {
					// buffer reset
					p_cmd_buf_wr = buf;
					p_cmd_buf_rd = buf;
					cnt_cmd_buf  = 0;
					//
					p_rsp_str = rsp_str__NULL;
					//
					ret = recv(sn, p_cmd_buf_wr, 1); // read one char
					//
					if (p_cmd_buf_wr[0]=='*' || p_cmd_buf_wr[0]==':') {
						state_scpi_cmd = scpi_cmd__start;
						//
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
					} 
					else if (p_cmd_buf_wr[0]=='\n' || p_cmd_buf_wr[0]=='\r') {
						state_scpi_cmd = scpi_cmd__done;
					} 
					else if (p_cmd_buf_wr[0]==' ' || p_cmd_buf_wr[0]=='\t') {
						state_scpi_cmd = scpi_cmd__done;
					} 
					else {
						state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n'
						//
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
					}
					//
				}
				//
			} 
			else if (state_scpi_cmd==scpi_cmd__start) {
				//// try to match cmd string

				// TODO: check buffer data length to find command header
				size = getSn_RX_RSR(sn);
				//
				if      (cnt_cmd_buf<5) { // scpi_cmd__RST
					if (size+cnt_cmd_buf>=5) {
						// update buffer 
						ret = recv(sn, p_cmd_buf_wr, 5-cnt_cmd_buf); // fill 5 chars in buffer
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
						
						// TODO: case of  cmd_str__RST 
						if (0==strncmp((char*)cmd_str__RST,(char*)p_cmd_buf_rd,LEN_CMD_STR__RST)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__RST;
							cnt_cmd_buf  -= LEN_CMD_STR__RST;
							//
							if (*p_cmd_buf_rd == '\n' || *p_cmd_buf_rd == '\r') {
								state_scpi_cmd = scpi_cmd__RST;
							} 
							else {
								// leave for longer command cases 
								p_cmd_buf_rd -= LEN_CMD_STR__RST;
								cnt_cmd_buf  += LEN_CMD_STR__RST;
							}
							//
						}
						else { // NOP
							// continue with more cnt_cmd_buf
						}
					}
					else { // check last letter 
						if (*(p_cmd_buf_wr-1)=='\n') {
							state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n';
						}
					}
				}
				else if (cnt_cmd_buf<6) { // scpi_cmd__IDN
					if (size+cnt_cmd_buf>=6) {
						// update buffer 
						ret = recv(sn, p_cmd_buf_wr, 6-cnt_cmd_buf); // fill 6 chars in buffer
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
						
						// TODO: case of  cmd_str__IDN
						if (0==strncmp((char*)cmd_str__IDN,(char*)p_cmd_buf_rd,LEN_CMD_STR__IDN)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__IDN;
							cnt_cmd_buf  -= LEN_CMD_STR__IDN;
							//
							if (*p_cmd_buf_rd == '\n' || *p_cmd_buf_rd == '\r') {
								state_scpi_cmd = scpi_cmd__IDN;
							} 
							else {
								// leave for longer command cases 
								p_cmd_buf_rd -= LEN_CMD_STR__IDN;
								cnt_cmd_buf  += LEN_CMD_STR__IDN;
							}
							//
						}
						else { // NOP
							// continue with more cnt_cmd_buf
						}
					}
					else { // check last letter 
						if (*(p_cmd_buf_wr-1)=='\n') {
							state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n';
						}
					}
				}
				else if (cnt_cmd_buf<7) { // scpi_cmd__EPS_EN  scpi_cmd__EPS_PI  scpi_cmd__EPS_PO
					if (size+cnt_cmd_buf>=7) {
						// update buffer 
						ret = recv(sn, p_cmd_buf_wr, 7-cnt_cmd_buf); // fill 7 chars in buffer
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
						
						// TODO: case of  cmd_str__EPS_EN
						if (0==strncmp((char*)cmd_str__EPS_EN,(char*)buf,LEN_CMD_STR__EPS_EN)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_EN;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_EN;
							//
							state_scpi_cmd = scpi_cmd__EPS_EN;
						}
						// TODO: case of  cmd_str__EPS_PO
						else if (0==strncmp((char*)cmd_str__EPS_PO,(char*)buf,LEN_CMD_STR__EPS_PO)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_PO;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_PO;
							//
							state_scpi_cmd = scpi_cmd__EPS_PO;
						}
						// TODO: case of  cmd_str__EPS_PI
						else if (0==strncmp((char*)cmd_str__EPS_PI,(char*)buf,LEN_CMD_STR__EPS_PI)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_PI;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_PI;
							//
							state_scpi_cmd = scpi_cmd__EPS_PI;
						}
						else { // NOP
							// continue with more cnt_cmd_buf
						}
					}
					else { // check last letter 
						
						if (*(p_cmd_buf_wr-1)=='\n') {
							state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n';
						}
					}
				}
				else if (cnt_cmd_buf<8) { // scpi_cmd__EPS_WMI scpi_cmd__EPS_WMO scpi_cmd__EPS_TAC scpi_cmd__EPS_TMO scpi_cmd__EPS_TWO
					if (size+cnt_cmd_buf>=8) {
						// update buffer 
						ret = recv(sn, p_cmd_buf_wr, 8-cnt_cmd_buf); // fill 8 chars in buffer
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
						
						// TODO: case of  cmd_str__EPS_WMI
						if (0==strncmp((char*)cmd_str__EPS_WMI,(char*)buf,LEN_CMD_STR__EPS_WMI)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_WMI;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_WMI;
							//
							state_scpi_cmd = scpi_cmd__EPS_WMI;
						}
						// TODO: case of  cmd_str__EPS_WMO
						else if (0==strncmp((char*)cmd_str__EPS_WMO,(char*)buf,LEN_CMD_STR__EPS_WMO)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_WMO;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_WMO;
							//
							state_scpi_cmd = scpi_cmd__EPS_WMO;
						}
						// TODO: case of  cmd_str__EPS_TAC
						else if (0==strncmp((char*)cmd_str__EPS_TAC,(char*)buf,LEN_CMD_STR__EPS_TAC)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_TAC;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_TAC;
							//
							state_scpi_cmd = scpi_cmd__EPS_TAC;
						}
						// TODO: case of  cmd_str__EPS_TMO
						else if (0==strncmp((char*)cmd_str__EPS_TMO,(char*)buf,LEN_CMD_STR__EPS_TMO)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_TMO;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_TMO;
							//
							state_scpi_cmd = scpi_cmd__EPS_TMO;
						}
						// TODO: case of  cmd_str__EPS_TWO
						else if (0==strncmp((char*)cmd_str__EPS_TWO,(char*)buf,LEN_CMD_STR__EPS_TWO)) { // 0 means eq
							//
							p_cmd_buf_rd += LEN_CMD_STR__EPS_TWO;
							cnt_cmd_buf  -= LEN_CMD_STR__EPS_TWO;
							//
							state_scpi_cmd = scpi_cmd__EPS_TWO;
						}
						//
						else { // NOP
							// continue with more cnt_cmd_buf
						}
					}
					else { // check last letter 
						if (*(p_cmd_buf_wr-1)=='\n') {
							state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n';
						}
					}
				}
				else                    { // scpi_cmd__ECHO
					// no more 
					state_scpi_cmd = scpi_cmd__ECHO; // echo until '\n'
				}
				// 
			}

			// TODO: EPS commands
			if      (state_scpi_cmd==scpi_cmd__RST) {
				//
				reset_mcs_ep();
				//
				p_rsp_str = rsp_str__OK;
				//
#ifdef _SCPI_DEBUG_MIN_
				xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
				//
				state_scpi_cmd = scpi_cmd__done;
			}
			else if (state_scpi_cmd==scpi_cmd__IDN) {
				u32 val;
				// make scpi response string
				//   - case: *IDN?<NL> --> "CMU-CPU-F5500, "__DATE__" \r\n"
				//            add FPGA image ID 
				val = XIomodule_In32 (ADRS_FPGA_IMAGE);
				xil_sprintf((char*)rsp_str,"%s; FID#H%08X\n", rsp_str__IDN, (unsigned int)val);
				p_rsp_str = rsp_str;
				//
#ifdef _SCPI_DEBUG_MIN_
				xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
				//
				state_scpi_cmd = scpi_cmd__done;
			}
			//
			else if (state_scpi_cmd==scpi_cmd__EPS_EN ) { // :EPS:EN  7 // ? SW 
				// # cmd: ":EPS:EN?\n"
				// # cmd: ":EPS:EN ON\n"
				// # cmd: ":EPS:EN OFF\n"
			
				//
				if      (state_scpi_para==scpi_para__ready) {
					// wait for one more char to check query command
					while (1) {
						size = getSn_RX_RSR(sn);
						if (size>0) break;
					}
					// read one char
					ret = recv(sn, p_cmd_buf_wr, 1); 
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					//
					if (p_cmd_buf_rd[0]=='?') { // ? command 
						if (EPS_EN_SW==ON)
							p_rsp_str = rsp_str__ON;
						else 
							p_rsp_str = rsp_str__OFF;
						//
	#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
						//
						state_scpi_cmd = scpi_cmd__done;
					}
					//
					else if (p_cmd_buf_rd[0]==' ') { // parameter expecting after ' '
						//
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						// start parameter check
						state_scpi_para=scpi_para__SW;
					}
					//
					else { // parameter NG
						p_rsp_str = rsp_str__NG;
						//
	#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
						//
						state_scpi_cmd = scpi_cmd__done;
					}
				} 
				else if (state_scpi_para==scpi_para__SW) { // find ON/OFF set parameter
					// wait for done
					// NOP
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						if (para_SW==ON) {
							EPS_EN_SW = ON;
							enable_mcs_ep();
						}
						else { 
							EPS_EN_SW = OFF;
							disable_mcs_ep();
						}
						//
						p_rsp_str = rsp_str__OK;							
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_WMI) { // :EPS:WMI 8 // B1 W1 W2
				// # cmd: ":EPS:WMI#H00 #HABCD1234 #HFF00FF00\n"
				// # rsp: "OK\n" or "NG\n"
				
				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_W1_W2;
				}
				else if (state_scpi_para==scpi_para__B1_W1_W2) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_W1_W2
						// para_b1, para_w1, para_w2
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_w1=0x%08X\r\n",sn,para_w1);
						xil_printf("%d:para_w2=0x%08X\r\n",sn,para_w2);
#endif
						write_mcs_ep_wi_mask(MCS_EP_BASE,para_w2);
						write_mcs_ep_wi_data(MCS_EP_BASE,para_b1,para_w1);
						//
						p_rsp_str = rsp_str__OK;							
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_WMO) { // :EPS:WMO 8 // B1 W1
				// # cmd: ":EPS:WMO#H20 #HFFFF0000\n"
				// # rsp: "#H00003242\n"
			
				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_W1;
				}
				else if (state_scpi_para==scpi_para__B1_W1) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_W1
						// para_b1, para_w1
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_w1=0x%08X\r\n",sn,para_w1);
#endif
						write_mcs_ep_wo_mask(MCS_EP_BASE,para_w1);
						ret = read_mcs_ep_wo_data(MCS_EP_BASE,para_b1);
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)ret);
						//
						p_rsp_str = rsp_str;							
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_TAC) { // :EPS:TAC 8 // B1 B2
				// # cmd: ":EPS:TAC#H40 #H01\n"
				// # rsp: "OK\n" or "NG\n"
			
				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_B2;
				}
				else if (state_scpi_para==scpi_para__B1_B2) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_B2
						// para_b1, para_b2
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_b2=0x%02X\r\n",sn,para_b2);
#endif
						activate_mcs_ep_ti(MCS_EP_BASE,para_b1,para_b2);
						//
						p_rsp_str = rsp_str__OK;							
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_TMO) { // :EPS:TMO 8 // B1 W1
				// # cmd: ":EPS:TMO#H60 #H0000FFFF\n"
				// # rsp: "ON\n" or "OFF\n"

				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_W1;
				}
				else if (state_scpi_para==scpi_para__B1_W1) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_W1
						// para_b1, para_w1
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_w1=0x%08X\r\n",sn,para_w1);
#endif
						//
						ret = is_triggered_mcs_ep_to(MCS_EP_BASE,para_b1,para_w1);
						//
						if (ret==0) 
							p_rsp_str = rsp_str__OFF;
						else        
							p_rsp_str = rsp_str__ON;
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_TWO) { // :EPS:TWO 8 // B1 W1 
				// # cmd: ":EPS:TWO#H60 #H0000FFFF\n"
				// # rsp: "#H00003242\n"

				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_W1;
				}
				else if (state_scpi_para==scpi_para__B1_W1) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_W1
						// para_b1, para_w1
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_w1=0x%08X\r\n",sn,para_w1);
#endif
						//
						ret = read_mcs_ep_to(MCS_EP_BASE,para_b1,para_w1);
						xil_sprintf((char*)rsp_str,"#H%08X\n",(unsigned int)ret);
						//
						p_rsp_str = rsp_str;							
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_PI ) { // :EPS:PI  7 // B1 N1
				// # cmd: ":EPS:PI#H8A #4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
				// # rsp: "OK\n" or "NG\n"
				
				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_N1;
				}
				else if (state_scpi_para==scpi_para__B1_N1) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_N1
						// para_b1, para_n1
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_n1=%06d\r\n",sn,para_n1);
#endif
						//
						p_rsp_str = rsp_str__OK;
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			else if (state_scpi_cmd==scpi_cmd__EPS_PO ) { // :EPS:PO  7 // B1 D1
				// # cmd: ":EPS:PO#HAA 001024\n"
				// # rsp: "#4_001024_rrrr...rrrrrrrrrr\n"

				//
				if      (state_scpi_para==scpi_para__ready) {
					state_scpi_para=scpi_para__B1_D1;
				}
				else if (state_scpi_para==scpi_para__B1_D1) {
				}
				else if (state_scpi_para==scpi_para__done) {
					//
					if (status_scpi_para==OK) {
						// for scpi_para__B1_D1
						// para_b1, para_d1
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:para_b1=0x%02X\r\n",sn,para_b1);
						xil_printf("%d:para_d1=%06d\r\n",sn,para_d1);
#endif
						// numeric block head : #4_nnnnnn_
						xil_sprintf((char*)rsp_str,"#4_%06d_",(int)para_d1);
						//
						p_rsp_str = rsp_str;
					}
					else { // NG
						p_rsp_str = rsp_str__NG;
					}
					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
					//
					state_scpi_cmd = scpi_cmd__done__EPS_PO;
				}
				else { // parameter NG
					p_rsp_str = rsp_str__NG;
					//
	#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
	#endif
					//
					state_scpi_cmd = scpi_cmd__done;
				}
			}
			//
			else if (state_scpi_cmd==scpi_cmd__ECHO) {
				// no command found, thus echo.
				size = getSn_RX_RSR(sn);
				if (size > 0) {
					ret = recv(sn, p_cmd_buf_wr, 1); // read one char
					//
					if (p_cmd_buf_wr[0]=='\n') {
						p_cmd_buf_wr += 1;
						cnt_cmd_buf  += 1;
						*p_cmd_buf_wr = '\0'; // for compatibility
						//
						p_rsp_str = p_cmd_buf_rd;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_cmd=%d\r\n",sn,state_scpi_cmd);
#endif
						//
						state_scpi_cmd = scpi_cmd__done;
					} else {
						// stay scpi_cmd__ECHO
						p_cmd_buf_wr += 1;
						cnt_cmd_buf  += 1;
					}
					//
				}
				else {
					// check last letter 
					if (cnt_cmd_buf>0) {
						if (*(p_cmd_buf_wr-1)=='\n') {
							state_scpi_cmd = scpi_cmd__done;
							*p_cmd_buf_wr = '\0'; // for compatibility
							//
							p_rsp_str = p_cmd_buf_rd;
						}
					}
				}
			} 
			else if (state_scpi_cmd==scpi_cmd__done) {
				// send simple rsp 
				if (p_rsp_str!=0) {
					ret = send_response_all(sn, p_rsp_str, strlen((char*)p_rsp_str));
				}
				// update state
				state_scpi_cmd=scpi_cmd__ready;
			} 
			//
			else if (state_scpi_cmd==scpi_cmd__done__EPS_PO) {
				// send header or NG
				if (p_rsp_str!=0) {
					ret = send_response_all(sn, p_rsp_str, strlen((char*)p_rsp_str));
				}
				//
				if (status_scpi_para==OK) {
					// send numeric data // from scpi_cmd__EPS_PO
					ret = send_response_all_from_pipe32(sn, MCS_EP_BASE + (para_b1<<4), para_d1);
					// send NL
					ret = send_response_all(sn, rsp_str__NL, strlen((char*)rsp_str__NL));
				}
				// update state
				state_scpi_cmd=scpi_cmd__ready;
			} 
			else { // unknown state
			}
			
			//}
			
			
			//// TODO: update state_scpi_para and collect parameters //{
			if (state_scpi_para==scpi_para__ready) {
				// NOP
			}
			else if (state_scpi_para==scpi_para__test) { // test
				// update buffer 
				size = getSn_RX_RSR(sn);
				ret = recv(sn, p_cmd_buf_wr, size);
				p_cmd_buf_wr += ret;
				cnt_cmd_buf  += ret;
				*p_cmd_buf_wr = '\0'; // for compatibility
				//
#ifdef _SCPI_DEBUG_MIN_
				xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
				//
				state_scpi_para=scpi_para__done;
			}
			//
			else if (state_scpi_para==scpi_para__SW) {
				// update buffer for "ON" or "OFF"
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>2) { // quick read 3 char
					ret = recv(sn, p_cmd_buf_wr, 3-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					if (p_cmd_buf_rd[0]==' ') { // space check 
						// leave for next char
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
					}
					else { // find "ON" or "OFF"
						//
						if (p_cmd_buf_rd[0]=='O' && p_cmd_buf_rd[1]=='N') { // "ON"
							//
							status_scpi_para = OK;
							para_SW = ON;
						}
						else if (p_cmd_buf_rd[0]=='O' && p_cmd_buf_rd[1]=='F' && p_cmd_buf_rd[2]=='F') { // "OFF"
							//
							status_scpi_para = OK;
							para_SW = OFF;
						}
						else { // NG 
							//
							status_scpi_para = NG;
						}
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
				}
			}
			else if (state_scpi_para==scpi_para__B1_W1_W2) {
				// # cmd: ":EPS:WMI#H00 #HABCD1234 #HFF00FF00\n"
				
				// update buffer
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>26) { // quick read 27 char
					// update 27 char
					ret = recv(sn, p_cmd_buf_wr, 27-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					// update buffer until '\n'
					while (1) {
						if (ret>0 && *(p_cmd_buf_wr-1)=='\n') break;
						//
						ret = recv(sn, p_cmd_buf_wr, 1);
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
					}
					
					//// find para : para_b1 para_w1 para_w2

					if (p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b1
						//
						status_scpi_para = OK;
						//
						para_b1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_w1
						//
						status_scpi_para = OK;
						//
						para_w1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),8);
						//
						p_cmd_buf_rd += 10;
						cnt_cmd_buf  -= 10;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_w2
						//
						status_scpi_para = OK;
						//
						para_w2 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),8);
						//
						p_cmd_buf_rd += 10;
						cnt_cmd_buf  -= 10;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
					//
					state_scpi_para=scpi_para__done;
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					// check NG by early '\n'
					if (ret>0 && *(p_cmd_buf_wr-1)=='\n') {
						//
						status_scpi_para = NG;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
				}
			}
			else if (state_scpi_para==scpi_para__B1_W1) {
				// # cmd: ":EPS:WMO#H20 #HFFFF0000\n"
				
				// update buffer
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>15) { // quick read 16 char
					// update 16 char
					ret = recv(sn, p_cmd_buf_wr, 16-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					// update buffer until '\n'
					while (1) {
						if (ret>0 && *(p_cmd_buf_wr-1)=='\n') break;
						//
						ret = recv(sn, p_cmd_buf_wr, 1);
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
					}
					
					//// find para : para_b1 para_w1

					if (p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b1
						//
						status_scpi_para = OK;
						//
						para_b1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_w1
						//
						status_scpi_para = OK;
						//
						para_w1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),8);
						//
						p_cmd_buf_rd += 10;
						cnt_cmd_buf  -= 10;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
					//
					state_scpi_para=scpi_para__done;
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					// check NG by early '\n'
					if (ret>0 && *(p_cmd_buf_wr-1)=='\n') {
						//
						status_scpi_para = NG;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
				}
			}
			else if (state_scpi_para==scpi_para__B1_B2) {
				// # cmd: ":EPS:TAC#H40 #H01\n"
				
				// update buffer
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>9) { // quick read 10 char
					// update 10 char
					ret = recv(sn, p_cmd_buf_wr, 10-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					// update buffer until '\n'
					while (1) {
						if (ret>0 && *(p_cmd_buf_wr-1)=='\n') break;
						//
						ret = recv(sn, p_cmd_buf_wr, 1);
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
					}
					
					//// find para : para_b1 para_b2

					if (p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b1
						//
						status_scpi_para = OK;
						//
						para_b1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b2
						//
						status_scpi_para = OK;
						//
						para_b2 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
					//
					state_scpi_para=scpi_para__done;
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					// check NG by early '\n'
					if (ret>0 && *(p_cmd_buf_wr-1)=='\n') {
						//
						status_scpi_para = NG;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
				}	
			}
			else if (state_scpi_para==scpi_para__B1_D1) {
				// # cmd: ":EPS:PO#HAA 001024\n"
				
				// update buffer
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>11) { // quick read 12 char
					// update 12 char
					ret = recv(sn, p_cmd_buf_wr, 12-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					// update buffer until '\n'
					while (1) {
						if (ret>0 && *(p_cmd_buf_wr-1)=='\n') break;
						//
						ret = recv(sn, p_cmd_buf_wr, 1);
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
					}
					
					//// find para : para_b1 para_d1

					if (p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b1
						//
						status_scpi_para = OK;
						//
						para_b1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && isdigit(p_cmd_buf_rd[0])) { // read para_d1
						//
						status_scpi_para = OK;
						//
						para_d1 = decstr2data_u32((u8*)(p_cmd_buf_rd),6);
						//
						p_cmd_buf_rd += 8;
						cnt_cmd_buf  -= 8;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
					//
					state_scpi_para=scpi_para__done;
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					// check NG by early '\n'
					if (ret>0 && *(p_cmd_buf_wr-1)=='\n') {
						//
						status_scpi_para = NG;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
				}	
			}
			else if (state_scpi_para==scpi_para__B1_N1) {
				// # cmd: ":EPS:PI#H8A #4_001024_rrrr...rrrrrrrrrr\n"
				
				// update buffer
				size = getSn_RX_RSR(sn);
				//
				if (cnt_cmd_buf+size==0) { // leave and waiting for data 
					// NOP
				} 
				else if (cnt_cmd_buf+size>14) { // quick read 15 char
					// update 15 char
					ret = recv(sn, p_cmd_buf_wr, 15-cnt_cmd_buf);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					
					// update buffer until '_' //$$
					while (1) {
						if (ret>0 && *(p_cmd_buf_wr-1)=='_') break;
						//
						ret = recv(sn, p_cmd_buf_wr, 1);
						p_cmd_buf_wr += ret;
						cnt_cmd_buf  += ret;
						*p_cmd_buf_wr = '\0'; // for compatibility
					}
					
					//// find para : para_b1 para_n1

					if (p_cmd_buf_rd[0]=='#' && p_cmd_buf_rd[1]=='H') { // read para_b1
						//
						status_scpi_para = OK;
						//
						para_b1 = hexstr2data_u32((u8*)(p_cmd_buf_rd+2),2);
						//
						p_cmd_buf_rd += 4;
						cnt_cmd_buf  -= 4;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if (status_scpi_para==OK && p_cmd_buf_rd[0]==' ') { // remove space
						p_cmd_buf_rd += 1;
						cnt_cmd_buf  -= 1;
						//
						while (1) {
							if (p_cmd_buf_rd[0]==' ') {
								p_cmd_buf_rd += 1;
								cnt_cmd_buf  -= 1;
							}
							else break;
						}
						//
					}
					else { // NG
						//
						status_scpi_para = NG;
					}
					
					if ((status_scpi_para==OK) && 
						(0==strncmp((char*)cmp_str__N4_HD_3,(char*)(p_cmd_buf_rd),3)) && 
						(isdigit(p_cmd_buf_rd[3])) ) { // read para_n1
						//
						status_scpi_para = OK;
						//
						para_n1 = decstr2data_u32((u8*)(p_cmd_buf_rd+3),6);
						//
						p_cmd_buf_rd += 10;
						cnt_cmd_buf  -= 10;
						
					} 
					else { // NG
						//
						status_scpi_para = NG;
					}

					// read and copy data from "rrrr...rrrrrrrrrr\n"
					if (status_scpi_para==OK) { // read numeric block
						// cnt_cmd_buf+size ... multiple of 4 
						// 
						cnt_N1 = para_n1;
						while (1) { 
							if (cnt_N1==0) break;
							size = getSn_RX_RSR(sn);
							// update buffer
							if (cnt_cmd_buf+size > cnt_N1) {
								ret = recv(sn, p_cmd_buf_wr, cnt_N1-cnt_cmd_buf);
								p_cmd_buf_wr += ret;
								cnt_cmd_buf  += ret;
								*p_cmd_buf_wr = '\0'; // for compatibility
							}
							else if (size > 0) {
								ret = recv(sn, p_cmd_buf_wr, size);
								p_cmd_buf_wr += ret;
								cnt_cmd_buf  += ret;
								*p_cmd_buf_wr = '\0'; // for compatibility
							}
							// send pipe/fifo
							//...
							len_pipe = cnt_cmd_buf&0xFFFFFFFC; // multiple of 4
							if ( len_pipe > 0 ) { 
								// update count
								cnt_N1 -= len_pipe; 
								// push pipe 
								dcopy_buf8_to_pipe32((u8*)(p_cmd_buf_rd), MCS_EP_BASE + (para_b1<<4), len_pipe); 
								// update p_cmd_buf_rd
								p_cmd_buf_rd += len_pipe;
								cnt_cmd_buf  -= len_pipe;
								// buffer reset when empty
								if (cnt_cmd_buf==0) {
									p_cmd_buf_wr = buf;
									p_cmd_buf_rd = buf;
								}
							}
						}
						//
					}
						
					// update buffer until '\n'
					if (status_scpi_para==OK) {
						while (1) {
							//
							ret = recv(sn, p_cmd_buf_wr, 1);
							p_cmd_buf_wr += ret;
							cnt_cmd_buf  += ret;
							*p_cmd_buf_wr = '\0'; // for compatibility
							//
							if (ret>0 && *(p_cmd_buf_wr-1)=='\r') continue; // '\r' allowed
							else if (ret>0 && *(p_cmd_buf_wr-1)=='\n') break; // '\n' found
							else if (ret>0) { // NG
								status_scpi_para=NG;
							}
						}
					}

					//
#ifdef _SCPI_DEBUG_MIN_
					xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
					//
					state_scpi_para=scpi_para__done;
					
				}
				else { // update buffer
					ret = recv(sn, p_cmd_buf_wr, size);
					p_cmd_buf_wr += ret;
					cnt_cmd_buf  += ret;
					*p_cmd_buf_wr = '\0'; // for compatibility
					//
					// check NG by early '\n'
					if (ret>0 && *(p_cmd_buf_wr-1)=='\n') {
						//
						status_scpi_para = NG;
						//
#ifdef _SCPI_DEBUG_MIN_
						xil_printf("%d:state_scpi_para=%d\r\n",sn,state_scpi_para);
#endif
						//
						state_scpi_para=scpi_para__done;
					}
				}	
			}
			//
			else if (state_scpi_para==scpi_para__done) {
				state_scpi_para=scpi_para__ready;
			}
			else { // unknown
				//
				state_scpi_para=scpi_para__ready;				
			}
			
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
			state_scpi_cmd = scpi_cmd__done;
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
















