// InterfaceApp.cpp: implementation of the CInterfaceApp class.
//
//////////////////////////////////////////////////////////////////////
#include "InterfaceApp.h"

#include "string.h"

///////////////////////////////////////////////////////////////////////////////////////////
static char * __fw_ver__ = "1.3";

extern trxData_t		trxData;
extern trxData_t		trxBinData;
extern hal_lock_t  		eth_lock;

//
// Sleep(x) 
//		x msec delay.
#define Sleep(x)	OstDelay_us(x * 1000)	
#define _LOOPBACK_DEBUG_

static const UINT16 UDP_STX = 0xe1ec;
static const UINT16 TCP_STX = 0xe1ec;

//2015.12.22
static int prev_old_cmd = OLD_NO_CMD;

//#define NCS3_BASE_ADDR		0x0C000000		// 0xAB500000	
//#define	VSVM_BASE_ADDR		(NCS3_BASE_ADDR + 0x00C00000) // VSVM


//	u8 w5300_tx_mem_conf[8]	= {8,8,8,8,8,8,8,8};				// for setting TMSR regsiter
//	u8 w5300_rx_mem_conf[8]	= {8,8,8,8,8,8,8,8};				// for setting RMSR regsiter
//	u8 w_5300_ip[4]			= {192,168,111,200};				// for setting SIP register
//	u8 w_5300_gw[4]			= {192,168,111,1};					// for setting GAR register
//	u8 w_5300_sn[4]			= {255,255,255,0};					// for setting SUBR register
//	u8 w_5300_mac[6]			= {0x00,0x08,0xDC,0x00,111,200};	// for setting SHAR register
//	u8 w5300_serverip[4]		= {192,168,111,78};					// "TCP SERVER" IP address for loopback_tcpc()
//	u8 m_pBuf[4096];
u32 w5300_rx_count		= 0;


//2017.08.28
extern SysInfo sta_info;

#define DUMP_TARGET_ADDR  	0xa7000000
#define DUMP_RESP_ADDR  	0xa7080000
static volatile u8 *dump_addr = 0;
static const unsigned char START_BYTE = 0xE1;

static int NullOutByte(char ch)
{
	return ch;
}

#ifdef TM_CORE_USE_GPIB

void REM_Interrupt_Handler(void)
{
	TNT_Out(R_auxmr, F_clrREMC);
	Set_4882_Status(STB, 0x02);
}
#endif // !TM_CORE_USE_GPIB

#if 0   // deprecated.. : move to MlccTest.h
typedef struct _buffer {
	int size ;
	unsigned char* buf;
} buffer_t;

#endif

extern buffer_t tx_buffer;
extern buffer_t rx_buffer;

int tsr_binprint(const char *data, int size, int seqnum);
extern UINT8 ser_tx_buffer[1024*32];

// typedef u8 (*tst_console_fn_t)(int, void*);

// typedef struct _tst_console_cmd {
// 	const char *fn_name;
// 	tst_console_fn_t fn;
// } tst_console_cmd_t;

// static tst_console_cmd_t tst_SMU_cmd[] = {
// 	// {"SMU_OUT_FORCE_RLY", 		ProcessSMU_OUT_FORCE_RLY},
// 	// {"SMU_OUT_SENSE_RLY", 		ProcessSMU_OUT_SENSE_RLY},
// 	{"smu_force_rly",			ProcessSMU_FORCE_RLY},

// 	{NULL, 			NULL}
// };

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CInterfaceApp::CInterfaceApp()
{
	// do nothing
	m_IsRemote = false;
	m_nPacketSeq = 0;

	m_RxCount = 0;
	m_RecvMsg[m_RxCount] = 0;
	//m_SerialRxDone = false;
	m_GpibTerm = 0;
	m_Rs232Installed = true;
	m_GpibInstalled = false;
	m_LanInstalled = true;
	m_UdpSocket = 7;
	m_UdpPort = UDP_PORT_TEG;
	m_UdpDestPort = 0;

	m_Socket = 0;
	m_Port = TCP_PORT_TEG;
	m_DestPort = 0;


	// TODO : caution
	tx_buffer.buf = (unsigned char*)(DOWNLOAD_TX_RAM_ADDR);
	rx_buffer.buf = (unsigned char*)(DOWNLOAD_RX_RAM_ADDR);
	m_mode = 'c';

}

CInterfaceApp::~CInterfaceApp()
{
	// do nothing
} 

BOOL CInterfaceApp::Create(u8 ipset)
{
	int i;

	GPIO_LedCtrl(0, LED_ON);
	GPIO_LedCtrl(1, LED_ON);

	TRACE("CInterfaceApp::Create() \r\n");

	m_IsSerial = FALSE;
	m_TegPort = UDP_PORT_TEG;
	m_DownSize = 0;

	return TRUE;
}

void CInterfaceApp::GotoRemote(TCommunicationSource comm)
{
#if 0	// deprecated.. 
	switch(comm)
	{
		case CMD_TYPE_GPIB:
			m_CommSource = CMD_TYPE_GPIB;
			break;

		case CMD_TYPE_SERIAL:
			m_CommSource = CMD_TYPE_SERIAL;
			break;

		case CMD_TYPE_ETHERNET:
			m_CommSource = CMD_TYPE_ETHERNET;
			break;
		default:
			m_CommSource = CMD_TYPE_SERIAL;
			break;
	}
	m_RxCount = 0;
	m_IsRemote = true;
#endif
}

void CInterfaceApp::GotoLocal(void)
{
}

bool CInterfaceApp::MessageAvailable(void)
{
	int size; 

#if 0		// deprecated.. : oldstyle

#ifdef TM_CORE_USE_GPIB
	if((m_CommSource == CMD_TYPE_NONE) && m_GpibInstalled)
	{
		// GPIB
		if(Message_Available())
		{
			//TRACE("# GPIB Mode\r\n");
			GotoRemote(CMD_TYPE_GPIB);
		}
	}
#endif

	if((m_CommSource == CMD_TYPE_NONE) && m_LanInstalled)
	{
		if (m_LanProtocol ) {
			if (TcpServer()  > 0) {
				GotoRemote(CMD_TYPE_ETHERNET);
			}
		} else {
			switch(getSn_SSR(m_UdpSocket))
			{
				case SOCK_UDP:
					if(getSn_RX_RSR(m_UdpSocket) > 0)
					{
						//TRACE("# LAN Mode\r\n");
						GotoRemote(CMD_TYPE_ETHERNET);
					}
					break;
	
				case SOCK_CLOSED:
					TRACE("# LAN Socket Close.\r\n");
					close(m_UdpSocket);
					socket(m_UdpSocket, Sn_MR_UDP, m_UdpPort, 0);
					break;
			}
		}
	}

#if 0	// deprecated.. 
	if((m_CommSource == CMD_TYPE_NONE) && m_hSerialCom.IsReadyChar())
#else
	if((m_CommSource == CMD_TYPE_NONE) && m_hSerialCom.IsReadyChar())
#endif
	{
		TRACE("# Serial Mode\r\n");
		GotoRemote(CMD_TYPE_SERIAL);
	}


	////////

	if(m_CommSource == CMD_TYPE_SERIAL)
	{
		return m_hSerialCom.IsReadyChar();
	}

	if(m_CommSource == CMD_TYPE_ETHERNET)
	{
		if (m_LanProtocol ) {
			TcpServer();
			switch(getSn_SR(m_Socket))
			{
				case SOCK_ESTABLISHED :
					if((size = getSn_RX_RSR(m_Socket)) > 0)
						return true;
					break;
			}
		} else {
			// udp
			switch(getSn_SSR(m_UdpSocket))
			{
				case SOCK_UDP:
					if(getSn_RX_RSR(m_UdpSocket) > 0)
					{
						return true;
					}
					break;
	
				case SOCK_CLOSED:
					close(m_UdpSocket);
					socket(m_UdpSocket, Sn_MR_UDP, m_UdpPort, 0);
					break;
			}
		}
	}

#ifdef TM_CORE_USE_GPIB
	if(m_CommSource == CMD_TYPE_GPIB)
	{
		// If no data in the output queue then Clear MAV bit
		if( !(QUEUE_STATUS & OMWA) && (Read_4882_Status(STB) & 0x10)) Clear_4882_Status(STB, 0x10); 

		// If EABO report it
		if (INTERFACE_STATUS & ERR) 
		{             
			TRACE("GPIB error has occured (INTERFACE_ERROR = %d)\n", INTERFACE_ERROR);
			TRACE("INTERFACE_STATUS = 0x%X\n", INTERFACE_STATUS);
			INTERFACE_STATUS &= ~ERR;
		}
		return Message_Available();	 
	}
#endif
#else

	CMD_RcvCheck();

#endif	//	!deprecated.. : oldstyle

	if (trxData.received > 0)
		return true;
	return false;
}

bool CInterfaceApp::ReadCommand(void)
{
	if (trxData.received > 0) {
		trxData.received = 0x00;

//		hal_lock(&eth_lock);
		if (hal_lock(&eth_lock) != HAL_OK) {
			TRACE("ETHERNET : lock error..\r\n");
			return false;
		}

		switch (trxData.rxSource)
		{
			case CMD_TYPE_SERIAL:
				m_RxCount = trxData.rxLength;
				m_CommSource = trxData.rxSource;
				trxData.txSource = m_CommSource ;
				memcpy(m_RecvMsg, serialRxData, m_RxCount);
				break;
			case CMD_TYPE_ETHERNET:
				m_RxCount = trxData.rxLength;
				m_CommSource = trxData.rxSource;
				trxData.txSource = m_CommSource ;
				memcpy(m_RecvMsg, networkRxData, m_RxCount);
				break;
			default :
				m_RxCount = 0;
				m_CommSource = CMD_TYPE_NONE;
				trxData.txSource = 0;
				break;
		}

		Network_RxRecover(0x03);
		hal_unlock(&eth_lock);

		//memset(trxData.txData, 0, (trxData.txLength + 16));
		trxData.txLength = 0;
		trxData.rxSource = 0;

		return true;
	}
	return false;
}

bool CInterfaceApp::WriteCommand(char *str)
{
#if 0		// deprecated.. : oldstyle
	if(m_CommSource == CMD_TYPE_ETHERNET)		return WriteCommandLan(str);
	if(m_CommSource == CMD_TYPE_GPIB)		return WriteCommandGpib(str);
	if(m_CommSource == CMD_TYPE_SERIAL)	return WriteCommandSerial(str);
#endif
	return false;
}

int CInterfaceApp::UdpServer()
{
	Network_DataProcess();
	return 0;
}


int CInterfaceApp::TcpServer()
{
#if 0		// deprecated.. : oldstyle

	int32_t ret;
	uint16_t size = 0;
	u8 wiz_rx_buf[1024*8];	// wiz rx buff
	int32_t port = m_Port;
	int sn = SOCK_TCPS;
	int i;

#ifdef _LOOPBACK_DEBUG_
	u8 m_DEstIP[4];
	uint16_t m_DEstPort;
#endif

	switch(getSn_SR(m_Socket))
	{
		case SOCK_ESTABLISHED :
			if(getSn_IR(m_Socket) & Sn_IR_CON)
			{
#ifdef _LOOPBACK_DEBUG_
				getSn_DIPR(m_Socket, m_DEstIP);
				m_DEstPort = getSn_DPORT(m_Socket);

				TRACE("%d:Connected - %d.%d.%d.%d : %d\r\n",m_Socket, m_DEstIP[0], m_DEstIP[1], m_DEstIP[2], m_DEstIP[3], m_DEstPort);
#endif
				setSn_IR(m_Socket,Sn_IR_CON);
			}
#if 0
			if((size = getSn_RX_RSR(m_Socket)) > 0)
			{
				if(size > DEF_RX_DATA_BUF_SIZE) size = DEF_RX_DATA_BUF_SIZE;

				ret = recv(m_Socket, m_pBuf, size);
				TRACE("tcp-recv : %d\n", ret);
				w5300_rx_count  = ret;
			}
#else
			return true;
#endif
			break;
		case SOCK_CLOSE_WAIT :
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:CloseWait\r\n", m_Socket);
#endif
			if((ret=disconnect(m_Socket)) != SOCK_OK) return ret;
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:Socket closed\r\n",m_Socket);
#endif
			break;
		case SOCK_INIT :
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:Listen, TCP server loopback, port [%d]\r\n",m_Socket, port);
#endif
			{
				unsigned int val = SIK_ALL;
				int res = 0;
				res = ctlsocket(m_Socket, CS_SET_INTMASK, &val);
				TRACE("==> init... 0x%08x , %d \n", val, res);
			}
			
			if( (ret = listen(m_Socket)) != SOCK_OK) return ret;
			break;
		case SOCK_CLOSED:
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:TCP server loopback start\r\n",m_Socket);
#endif
			if((ret=socket(m_Socket, Sn_MR_TCP, port, 0x00)) != m_Socket)
			if((ret=socket(m_Socket, Sn_MR_TCP, port, Sn_MR_ND)) != m_Socket)
			return ret;
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:Socket opened\r\n",m_Socket);
#endif
			break;
		default:
			break;
	}
#else
	Network_DataProcess();
#endif
	return 0;
}

#if 0		// deprecated.. : oldstyle
bool CInterfaceApp::ReadCommandLan(void)
{
	u32 len;
	u16 stx, length;

	m_DownSize = 0;
	if(getSn_SSR(m_UdpSocket) == SOCK_UDP)
	{
		len = getSn_RX_RSR(m_UdpSocket);

		if(len > 0)
		{
			len = recvfrom(m_UdpSocket, &m_pBuf[w5300_rx_count], len, m_UdpDestIP, &m_UdpDestPort);
			w5300_rx_count += len;
            m_pBuf[len] = 0;
		}

		memset(m_RecvMsg, NULL, sizeof(m_RecvMsg));

		memcpy(m_RecvMsg, m_pBuf, len);
		m_RxCount = len;

		memset(m_pBuf, NULL, sizeof(m_pBuf));
		w5300_rx_count = 0;

		return true;
	} else {
		if((len = getSn_RX_RSR(m_Socket)) > 0)
		{
			if(len > DEF_RX_DATA_BUF_SIZE) len = DEF_RX_DATA_BUF_SIZE;

			len = recv(m_Socket, m_pBuf, len);
			TRACE("tcp-recv : %d\n", len);

			//**  debuggging.
			if (len < 10) {
				int i;
				for (i = 0; i < len; i++ ) {
					TRACE("tcp-recv : %2d : %02x\n", i, m_pBuf[i]);
				}

			}
			//**
		}
		m_DownSize = len;

		if (m_DownSize > 0)
			return true;

	}

	return false;
}

#ifdef TM_CORE_USE_GPIB
bool CInterfaceApp::ReadCommandGpib(void)
{
	m_RxCount = 0;
	m_GpibTerm = 0;
	if(Message_Available())
	{
		Read_Input_Queue(m_RecvMsg, Message_Length(), &m_GpibTerm);

		if(m_GpibTerm & DCAS)
		{
		}
		if(m_GpibTerm & DTAS)
		{
		}

		if(QUEUE_COUNT > 0)
		{
			m_RxCount = QUEUE_COUNT;
			m_RecvMsg[m_RxCount] = 0;
			//
			return true;
		}
		else
		{
			return false;
		}
	}
	return false;
}
#endif // !TM_CORE_USE_GPIB

bool CInterfaceApp::ReadCommandSerial(void)
{
	bool result;

	//result = m_hSerialCom.ReadPacket(m_RecvMsg);
	result = m_hSerialCom.ReadMsgBuff(m_RecvMsg); //2015.12.22

	m_RxCount = strlen(m_RecvMsg);

	return result;
}

bool CInterfaceApp::WriteCommandLan(char *str)
{
#if defined(CONFIG_TST_MLCC)
	char *buf = (char*) ser_tx_buffer;

	unsigned short length;

	length = tsr_binprint(str, strlen(str), 0);
    
	TRACE("DBG[LAN] : send : %d, %s seq:%d\r\n", length, str, m_nPacketSeq);

	if (m_LanProtocol) {
		switch(getSn_SR(m_Socket))
		{
			case SOCK_ESTABLISHED :
				length = send(m_Socket, (u8*)buf, length);
				break;
		}
		if (length > 0)
			return true;
		else
			return false;
	} else {
		if(length == sendto(m_UdpSocket, (u8*)buf, length, m_UdpDestIP, m_UdpDestPort))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
#else
	char buf[ETHERNET_MAX_LENGTH];
	unsigned short length;

	length = strlen(str);

	memcpy(&buf[0], &UDP_STX, 2);
	memcpy(&buf[2], &length, 2);
	memcpy(&buf[4], str, length);

	if(length == sendto(m_UdpSocket, (u8*)buf, length+4, m_UdpDestIP, m_UdpDestPort))
	{
		return true;
	}
	else
	{
		return false;
	}
#endif
}

bool CInterfaceApp::WriteCommandGpib(char *str)
{
    TRACE("DBG[Gpi] : send : %d, %s seq:%d\r\n", strlen(str), str, m_nPacketSeq);

	Set_4882_Status(STB, 0x10);
	Write_Output_Queue(str, strlen(str), EOI);

	return true;
}

bool CInterfaceApp::WriteCommandSerial(char *str)
{
    TRACE("DBG[Ser] : send : %d, %s seq:%d\r\n", strlen(str), str, m_nPacketSeq);

	m_hSerialCom.WritePacket(str); 

	return true;
}

BOOL CInterfaceApp::DoSerial()
{
	m_IsSerial = TRUE;

	TRACE("# OK : Start Serial Server. \r\n");
	if (Do()) 
	{
		TRACE("# OK : Serial Server Close...\n");
		return TRUE;
	}

	return FALSE;
}

BOOL CInterfaceApp::DoLan()
{
	m_IsSerial = FALSE;


	TRACE("\r\n# OK : Start Network Server. \r\n");	
	if (m_LanProtocol)
	{
		DoTCP();
	} else {
		DoUDP();
	}

	return FALSE;
}

BOOL CInterfaceApp::DoUDP()
{
	m_IsSerial = FALSE;

	TRACE("\r\n# OK : Start UDP Server. \r\n");	
	if (Do()) 
	{
		TRACE("# OK : UDP Server Close...\n");
		return TRUE;
	}

	return FALSE;
}

BOOL CInterfaceApp::DoTCP()
{
	m_IsSerial = FALSE;

	TRACE("\r\n# OK : Start TCP Server. \r\n");	
	if (Do()) 
	{
		TRACE("# OK : TCP Server Close...\n");
		return TRUE;
	}

	return FALSE;
}
#endif 	//	!deprecated.. : oldstyle

BOOL CInterfaceApp::Do()
{
	int i, ch;

	read_plf_info();
	SmuInit();

	// sbcho@20211220 for test
	
	dac_val_reg.smu_vdac_out_val[1] = 2.0;
	dac_val_reg.smu_idac_out_val[1] = 1.5;

	start_smu_dac(1);










	// test end










	GPIO_LedCtrl(0, LED_OFF); 		//	m_CPU.BusyLed(false);
//	m_CPU.OkLed(true);

	if( !CmdService() )
	{
		TRACE("Server Close...\n");
		TRACE("exit 1400 system program 1.0.s (%s)\n", __DATE__);  
		return FALSE;
	}	

	return TRUE;
}

BOOL CInterfaceApp::CmdService(void)
{
	int len;
	int size;
	int freesize;
	int length;
	bool bIsReadMsg;
//	bool bIsReadDone;

	TRACE("# Into CmdService\r\n");

	while(1)
	{  
		//reomve limit current
		//m_DcTpi.RemoveLimitCurrentAll(); 

		//------------------------------
		//Perpin 보드는 어드레스가 틀린거 같음. 
		//keyProcess();
		//------------------------------
//		bIsReadDone = false;

		// check ethernet status.
		TcpServer();
		//UdpServer();
                
		bIsReadMsg = MessageAvailable();
		if(bIsReadMsg)
		{
			bIsReadMsg = ReadCommand();

#if 0		// deprecated.. : network only..
			// gathering..
			if (m_DownSize > 0) {
				TRACE("# tcp : down size : %d, %d / %d\r\n", m_DownSize, m_RxCount, DEF_RX_DATA_BUF_SIZE);

				if ((m_RxCount + m_DownSize) > DEF_RX_DATA_BUF_SIZE)  {
					TRACE("# tcp overflow rxbuffer : %d \r\n", m_RxCount + m_DownSize);
					m_DownSize = DEF_RX_DATA_BUF_SIZE - m_RxCount;
				}
				memcpy(&m_RecvMsg[m_RxCount], m_pBuf, m_DownSize);
				m_RxCount += m_DownSize;

				// check pre process
				if (m_mode == 'b') {
					// bin mode
					if (m_RxCount > 3) {
						if ((m_RecvMsg[0] == TS_STX) && (m_RecvMsg[1] == 0xff)){
							if ((m_RecvMsg[2] == 0xff) && (m_RecvMsg[3] == 0xff)) {
								m_mode = 'c';
								m_RxCount = 0;
								TRACE("mode change-- : %c \r\n", m_mode);
								continue;
							}
						}
						if (m_RecvMsg[0] == TS_STX)  {
							if ((m_RecvMsg[1] == 0xd0) || (m_RecvMsg[1] == 0xd1) || (m_RecvMsg[1] == 0xe0) || (m_RecvMsg[1] == 0xe1))
							{
								size = 0;
								size += m_RecvMsg[3] << 8;
								size += m_RecvMsg[2];
								TRACE("# tcp size :  %x:%x:%x:%x : %d  / %d \r\n", \
										m_RecvMsg[0], m_RecvMsg[1], m_RecvMsg[2], m_RecvMsg[3], m_RxCount , size);
							} else{
								TRACE("# tcp size :  %x:%x:%x:%x : %d  / %d : wrong packet... \r\n", \
										m_RecvMsg[0], m_RecvMsg[1], m_RecvMsg[2], m_RecvMsg[3], m_RxCount , size);
								m_RxCount = 0;
								continue;
							}
						}
					}
				} else {
					if(bIsReadMsg)
					{
						if((stricmp(m_RecvMsg, "shell") == 0) || (stricmp(m_RecvMsg, "mon") == 0))
						{
							MsgOut("E00\r");
							TRACE("# Into Shell Program\r\n");
							shell_program();
							continue;
						}
					}
				}
			}

			continue;
		} else {
			if (m_RxCount > 0)  {
				bIsReadDone =  true;
			}
#endif 	// !deprecated.. : network only..
		}

//		if (m_RxCount > 0)  {
//			bIsReadDone =  true;
//		}

//		if (bIsReadDone)
		if (m_RxCount > 0)
		{
			GPIO_LedCtrl(0, LED_ON); 		//	m_CPU.BusyLed(true);
//			m_CPU.OkLed(false);
//			m_CPU.ErrorLed(false);			// 새로운 Command를 받으면 Error LED꺼짐
			errFlag = 0;


			

			// byte mode
			if(CMD_CompareByte(&m_RecvMsg[0], "QMVS")) 						ProcessQMFV(&m_RecvMsg[0]);
			else if(CMD_CompareByte(&m_RecvMsg[0], "QMIM")) 				ProcessQMMI(&m_RecvMsg[0]);		
			else
			{
				// char mode
				m_CmdToken.Clear();  
				if(m_CommSource == CMD_TYPE_SERIAL)
				{
					m_CmdToken.SetDelimit(" ", " ");
				}
#ifdef TM_CORE_USE_GPIB
				else if(m_CommSource == CMD_TYPE_GPIB)
				{
					//m_CmdToken.SetDelimit(" ", " "); GPIB HP4145 
				}
#endif // !TM_CORE_USE_GPIB

				else if(m_CommSource == CMD_TYPE_ETHERNET)	
				{
					m_CmdToken.SetDelimit(":", ",");
				}
	
				m_RecvMsg[m_RxCount] = 0;
				// TRACE("-> %s\r\n", m_RecvMsg);
				m_CmdToken.Token(m_RecvMsg);
				GPIO_LedCtrl(1, LED_OFF); 	//				m_CPU.ListenLed(false);
	
				if (m_CmdToken.m_CmdCount < 1) continue;
	
				if (m_CmdToken.m_CmdCount > 0)
				{
	
					u16	argc = m_CmdToken.m_ParaCount;
					void * pArgv = m_CmdToken.m_Para;

					u16 cmdc = m_CmdToken.m_CmdCount;
					void *pCmdv = m_CmdToken.m_Cmd;
					
					//User Command (LCD TEG Tester)     
					m_nPacketSeq++;	// debugging

	
					u8 rtn = 0;
					
 					// if(Cmd_info(m_CmdToken)) rtn = 1;
					// else if(Cmd_SmuTest(cmdc, pCmdv, argc, pArgv)) rtn = 1;
					if(Cmd_SmuTest(cmdc, pCmdv, argc, pArgv)) rtn = 1;
					else if(Cmd_CmuTest(cmdc, pCmdv, argc, pArgv)) rtn = 1;
					else if(Cmd_PguTest(cmdc, pCmdv, argc, pArgv)) rtn = 1;


					if(rtn == 0)
					{     
						TRACE("# <Unkown message.>\r8\n");
						MsgOut("E99\r");    
						errFlag++;
					}

					CMD_WaitTimeDelay();
				
					CMD_TransmitAck(&trxData);
					CMD_BinTransmitAck(&trxBinData);
				
					if(systemReset)
					{
						HAL_Delay(1000);
						NVIC_SystemReset();
					}
	
					GPIO_LedCtrl(0, LED_OFF); 		//	m_CPU.BusyLed(false);
					if(errFlag > 0)
					{
//						m_CPU.ErrorLed(true);
//						m_CPU.OkLed(false);
					}
					else
					{
//						m_CPU.OkLed(true);
					}
				}
		
			} //	!if (m_mode == 'b') {
		

			m_RxCount = 0;

		} 	//		!  if (m_RxCount > 0) 
	} 	// 	!while(1)

	return TRUE;
}

void CInterfaceApp::DisplayConnectMsg(void)
{
	TRACE("1400 system program 1.0 (2006.09.24) \r\n");
}


#if 0		// deprecated.. : oldstyle
int CInterfaceApp::ReadPacketUDP(char *msg)
{
	char buf[ETHERNET_MAX_LENGTH];
	UINT16 stx, pack_len;
	int len, fromlen;

	fromlen = sizeof(m_TegFrom);
	//len = recvfrom(m_TegSocket, buf, sizeof(buf), 0, &m_TegFrom, &fromlen);

	//2015.12.22
	len = getSn_RX_RSR(m_UdpSocket);
	if(len > 0)
		len = recvfrom(m_UdpSocket, &m_pBuf[w5300_rx_count], len, m_UdpDestIP, &m_UdpDestPort);

	if (len < 0)
	{
		TRACE("UDP: receive error[%d], ret = %d\n", -1, len);
		return -1;
	}
	else if (len > 0)
	{
		if (len < 4) 
		{
			TRACE("UDP: receive error[%d], len = %d\n", -2, len);
			return -2;
		}

		memcpy(&stx, &buf[0], 2);
		if (stx != UDP_STX) 
		{
			TRACE("UDP: receive error[%d], stx = 0x%04x\n", -3, stx);
			return -3;
		}

		memcpy(&pack_len, &buf[2], 2);
		if (len != pack_len+4) 
		{
			TRACE("UDP: receive error[%d], len = %d, pack_len = %d\n", -4, len, pack_len);
			return -4;
		}
		if (pack_len > 512) 
		{
			TRACE("UDP: receive error[%d], pack_len = %d\n", -5, pack_len);
			return -5;
		}

		memcpy(msg, &buf[4], pack_len);
		msg[pack_len] = 0;

		//2015.12.22
		memset(m_pBuf, NULL, sizeof(m_pBuf));
		w5300_rx_count = 0;

		return pack_len;
	}

	return 0; // if len = 0
}

int CInterfaceApp::WritePacketUDP(const char *msg, int size)
{
	char buf[ETHERNET_MAX_LENGTH];
	UINT16 pack_len;
	int len;

	memcpy(&buf[0], &UDP_STX, 2);
	pack_len = size;
	memcpy(&buf[2], &pack_len, 2);
	memcpy(&buf[4], msg, pack_len);

	//len = sendto(m_TegSocket, buf, pack_len+4, 0, &m_TegFrom, sizeof(struct sockaddr_in));

	if (len < 0)
	{
		TRACE("UDP: failed to sendto socket, ret = %d\n", len);
		//closesocket(udp_sock);
		return -1;
	}
	else if (len < 4)
	{
		TRACE("UDP: failed to sendto socket, len = %d\n", len);
		//closesocket(udp_sock);
		return -2;
	}

	return pack_len;
}
#endif

BOOL CInterfaceApp::MsgOut(const char *format, ...)
{
	u32	length;

	va_list	ap;

	trxData_t *pTrxData = &trxData;

	u8 *pStartData = &(pTrxData->txData[pTrxData->txLength]);

	va_start(ap, format);

	length = vsprintf((char*)pStartData, format, ap);

	pTrxData->txLength += length;		//strlen((char*)pStartData);

	va_end(ap);

	return true;
}

BOOL CInterfaceApp::MsgOut_byte(char *data, uint32 length)
{
	
//		GPIO_LedCtrl(1, LED_ON);
//		
//		if(!WriteCommand_byte(data, length))
//		{
//			GPIO_LedCtrl(1, LED_OFF);
//			return false;
//		}
//		
//		GPIO_LedCtrl(1, LED_OFF);
//		return TRUE;

	trxData_t *pTrxData = &trxData;

	//u8 *pStartData = &(pTrxData->txData[pTrxData->txLength]);
	
	//pTrxData->txData = &data;

	//memcpy(&(pTrxData->txData[pTrxData->txLength]), &data[0], length);
	pTrxData->txData = (u8 *)data;
	
	pTrxData->txLength += length;

	return true;


}


//******************************************************************************
//                                     COMMAND 
//******************************************************************************
u8 CInterfaceApp::Cmd_info(CCmdToken &Cmd)
{
	if		(Cmd.IsEQCmd(0, (char *)"SYS"))						ProcessSys(Cmd);
	else if	(Cmd.IsEQCmd(0, (char *)"VER"))						ProcessVer(Cmd);
	else if	(Cmd.IsEQCmd(0, (char *)"MLCC"))					ProcessMlccCommand(Cmd);
	else if	(Cmd.IsEQCmd(0, (char *)"MODE"))					ProcessMode(Cmd);
	else if	(Cmd.IsEQCmd(0, (char *)"DATA"))					DataTransmission(Cmd);
	else return 0;

	return 1;
}

void CInterfaceApp::ProcessSys(CCmdToken &Cmd)
{
	TRACE(" ProcessSys\r\n");

	if (Cmd.m_ParaCount >  0) {
		if(m_CmdToken.IsEQPara(0, "MODEL")) {
			MsgOut("NAME:MLCC IR TESTER\r");
		} else if(m_CmdToken.IsEQPara(0, "VENDOR")) { 
			MsgOut("VENDOR:TOP Engineering\r"); 
		} else if(m_CmdToken.IsEQPara(0, "date")) { 
			MsgOut("DATE:2020.04.01\r"); 
		} else if(m_CmdToken.IsEQPara(0, "reset")) { 
			MsgOut("RESET\r");
			HAL_Delay(1000);
			NVIC_SystemReset();
		} 
	} else if(Cmd.m_CmdCount > 0){
		if(m_CmdToken.IsEQCmd(1, "ALIVE")) { 
			TRACE(" ALIVE : OK\r\n");
		}
	} else {
		MsgOut( "E01\r" );	
		return;
	}
	
	MsgOut( "E00\r" );
	return;
}

void CInterfaceApp::ProcessVer(CCmdToken &Cmd)
{
	TRACE(" ProcessVer %d %d\r\n", Cmd.m_CmdCount, Cmd.m_ParaCount);

#define HW_MAGIC_CODE	0x5a5a
#define HW_MAGIC_CODE_8	0x5a

	if (Cmd.m_ParaCount >  0) {
		if(m_CmdToken.IsEQPara(0, "FW")) { 
			MsgOut("FWVER:V%s\r", __fw_ver__); 
		} else if(m_CmdToken.IsEQPara(0, "HW")) { 
			//unsigned short hw_val = 0;
			u32 hw_val = 0;

			//hw_val = 0xFFFF&(*(volatile unsigned short*)(0x08100000));		// 0x5a5a or 0x5a(old)
			FPGA_Read(0x00100000, &hw_val, 1);
			
			TRACE("HW MAGIC : 0x%04x\r\n", hw_val);            

			if ((hw_val == HW_MAGIC_CODE) || ((hw_val&0xFF) == HW_MAGIC_CODE_8)) {
				//hw_val = 0xFFFF&(*(volatile unsigned short*)(0x08100004));	// fpga version
				FPGA_Read(0x00100004, &hw_val, 1);
			} else {
				hw_val = 0;
			}
			MsgOut("HWVER:V%04d\r", hw_val);
		}
	} else if(Cmd.m_CmdCount > 0){
		if(m_CmdToken.IsEQCmd(1, "HW")) { 
            u32 hw_val = 0;
          
			FPGA_Read(0x00100000, &hw_val, 1);
			TRACE("HW MAGIC : 0x%x\r\n", hw_val); 
		}
	} else {
		MsgOut( "E01\r" );	
		return;
	}
    
    

	MsgOut( "E00\r" );

	return;
}

void CInterfaceApp::ProcessMlccCommand(CCmdToken &Cmd)
{
	TRACE(" ProcessMlccCommand%d %d\r\n", Cmd.m_CmdCount, Cmd.m_ParaCount);
	int res = 0;
	int count = 0;
	int i;
	unsigned int *rx_buf = (unsigned int*)rx_buffer.buf;

	res = Cmd_MlccTest(&trxData, (u16*)&Cmd.m_ParaCount, (u8**)Cmd.m_Para);

	if (res > 0) {
		if (rx_buffer.size > 0) {
			count = rx_buffer.size / sizeof(int);
			if (count > 0) {
				for (i = 0 ; i < count; i++) {
					MsgOut("RX:0x%08x\r", rx_buf[i]);
				}
			} else {
				MsgOut("RX:0x%08x\r", rx_buf[0]);
			}
		}
		MsgOut( "E00\r" );
	} else {
		MsgOut( "E99\r" );
	}

}

void CInterfaceApp::ProcessMode(CCmdToken &Cmd)
{
	TRACE(" ProcessMode %d %d\r\n", Cmd.m_CmdCount, Cmd.m_ParaCount);

    if (Cmd.m_ParaCount > 0) {
        m_mode = *Cmd.m_Para[0];
		TRACE("mode: %d\n", m_mode);
    } else {
		m_mode = 'c';
	}
	MsgOut( "E00\r" );
	return;
}


void CInterfaceApp::DataTransmission(CCmdToken &Cmd)
{
	u32	fileSize, rcvSize, rtn;

	TRACE("DataTransmission %d %d\r\n", Cmd.m_CmdCount, Cmd.m_ParaCount);

	if (Cmd.m_ParaCount >  0) {
		if(m_CmdToken.IsEQPara(0, "Upload")) { 
			fileSize = CMD_StrToUL((u8*)Cmd.m_Para[1]);
			TRACE("Upload.. size:%d\r\n", fileSize);

			rtn = Network_FileDownload(SDRAM_FPGA_READ_ADRS, &rcvSize);
			if(rtn == 0)									goto CMD_FILE_ERROR;
			if(rcvSize != fileSize)							goto CMD_FILE_ERROR;

			CMD_TransmitWaitTime(fileSize / 5000);

			MsgOut("SIZE:%d\r", rcvSize);
		} else if(m_CmdToken.IsEQPara(0, "Download")) { 
			fileSize = CMD_StrToUL((u8*)Cmd.m_Para[1]);
			TRACE("Download.. size: %d\r\n", fileSize);

			trxBinData.txSource = trxData.txSource;
			trxBinData.txData = (u8*)DOWNLOAD_TX_RAM_ADDR;
			trxBinData.txLength = fileSize * 4;

			MsgOut("SIZE:%d\r", rcvSize);
		}
	}

	MsgOut( "E00\r" );
	return;

CMD_FILE_ERROR:
	MsgOut( "E99\r" );
	return;
}

