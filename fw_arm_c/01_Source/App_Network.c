#include	"App_Network.h"

#define _LOOPBACK_DEBUG_ 	1
//#define TS_STX		0xe1
//#define TS_ETX		0xec

#if	_WIZCHIP_ == W5100S || _WIZCHIP_ == W5200 || _WIZCHIP_ == W5500 || _WIZCHIP_ == W5300
wiz_NetInfo g_NetInfo;
#else
struct	netif	gnetif;
#endif

u8	networkEnable = 0;
u8	networkIntFlag;

u8	networkMode;
u16	networkPort;

u8	networkRxFlag, *networkRxData = (u8*)SDRAM_ETHERNET_RX_BUFFER_ADRS;
u32	networkRxCnt;

u8	networkPktTxData[1280];

u8	networkPktRxFlag, *pNetworkPktRxData;
u16	networkPktRxCnt;

u8	*pNetworkRxFile;
u32	networkRxFileSize;

u8	networkPktMode;

hal_lock_t  		eth_lock;

static const UINT8 TS_STX = 0xe1;
static const UINT8 TS_CHAR = 0x0a;
static const UINT8 TS_ETX  = 0xec;

static int init_hw(void);
static int Netif_Config(void);

uint8_t m_Socket = 0;
uint8_t m_UdpPort = 0;
uint8_t m_UdpDestIP[4];
uint8_t m_UdpDestPort = 0;

int32_t m_Port = 7000;
uint32_t m_DownSize = 0;
uint8_t m_pBuf[DEF_RX_DATA_BUF_SIZE];

#define SOCK_OK               1        ///< Result is OK about socket process.
#define SOCK_BUSY             0        ///< Socket is busy on processing the operation. Valid only Non-block IO Mode.
#define SOCK_FATAL            -1000    ///< Result is fatal error about socket process.

#define SOCK_ERROR            0        
#define SOCKERR_SOCKNUM       (SOCK_ERROR - 1)     ///< Invalid socket number
#define SOCKERR_SOCKOPT       (SOCK_ERROR - 2)     ///< Invalid socket option
#define SOCKERR_SOCKINIT      (SOCK_ERROR - 3)     ///< Socket is not initialized or SIPR is Zero IP address when Sn_MR_TCP
#define SOCKERR_SOCKCLOSED    (SOCK_ERROR - 4)     ///< Socket unexpectedly closed.
#define SOCKERR_SOCKMODE      (SOCK_ERROR - 5)     ///< Invalid socket mode for socket operation.
#define SOCKERR_SOCKFLAG      (SOCK_ERROR - 6)     ///< Invalid socket flag
#define SOCKERR_SOCKSTATUS    (SOCK_ERROR - 7)     ///< Invalid socket status for socket operation.
#define SOCKERR_ARG           (SOCK_ERROR - 10)    ///< Invalid argument.
#define SOCKERR_PORTZERO      (SOCK_ERROR - 11)    ///< Port number is zero
#define SOCKERR_IPINVALID     (SOCK_ERROR - 12)    ///< Invalid IP address
#define SOCKERR_TIMEOUT       (SOCK_ERROR - 13)    ///< Timeout occurred
#define SOCKERR_DATALEN       (SOCK_ERROR - 14)    ///< Data length is zero or greater than buffer max size.
#define SOCKERR_BUFFER        (SOCK_ERROR - 15)    ///< Socket buffer is not enough for data communication.

#define SOCKFATAL_PACKLEN     (SOCK_FATAL - 1)     ///< Invalid packet length. Fatal Error.

#if 0
typedef enum
{
   SIK_CONNECTED     = (1 << 0),    ///< connected
   SIK_DISCONNECTED  = (1 << 1),    ///< disconnected
   SIK_RECEIVED      = (1 << 2),    ///< data received
   SIK_TIMEOUT       = (1 << 3),    ///< timeout occurred
   SIK_SENT          = (1 << 4),    ///< send ok
   //M20150410 : Remove the comma of last member
   //SIK_ALL           = 0x1F,        ///< all interrupt
   SIK_ALL           = 0x1F         ///< all interrupt
}sockint_kind;

typedef enum
{
   CS_SET_IOMODE,          ///< set socket IO mode with @ref SOCK_IO_BLOCK or @ref SOCK_IO_NONBLOCK
   CS_GET_IOMODE,          ///< get socket IO mode
   CS_GET_MAXTXBUF,        ///< get the size of socket buffer allocated in TX memory
   CS_GET_MAXRXBUF,        ///< get the size of socket buffer allocated in RX memory
   CS_CLR_INTERRUPT,       ///< clear the interrupt of socket with @ref sockint_kind
   CS_GET_INTERRUPT,       ///< get the socket interrupt. refer to @ref sockint_kind
//#if _WIZCHIP_ > 5100
   CS_SET_INTMASK,         ///< set the interrupt mask of socket with @ref sockint_kind, Not supported in W5100
   CS_GET_INTMASK          ///< get the masked interrupt of socket. refer to @ref sockint_kind, Not supported in W5100
//#endif
}ctlsock_typei;
#endif

void init_eth(int ipset)
{
    int i;
    int res = 0;
    uint16_t val = 0;

//	m_CPU.BusyLed(true);


	TRACE(">> Ehternet initCreate() \r\n");

	// Serial, RS232

	// LAN(Wiznet W5300)
//    if(m_LanInstalled)
	{
//		*(VUINT32*)0x48000010 = 0x788c7ff4; // CS5(LAN, 16bit, VRIO) - CS4(32bit, VRIO)
//		LoadMonConfig();
//
//		for (i=0; i<4; i++) g_NetInfo.ip[i] = (Cfg.Local_IP >> (i*8)) & 0xFF;
//		for (i=0; i<4; i++) g_NetInfo.gw[i] = (Cfg.Local_IP >> (i*8)) & 0xFF;
//		g_NetInfo.gw[3] = 1;
////		for (i=0; i<4; i++) w5300_serverip[i] = (Cfg.Host_IP >> (i*8)) & 0xFF;
//		for (i=0; i<6; i++) g_NetInfo.mac[i] = Cfg.Local_MacAddress[i];
//		for (i=0; i<4; i++) g_NetInfo.dns[i] = 0;

		g_NetInfo.dhcp = NETINFO_STATIC;

		if(ipset == 0) 
		{
			g_NetInfo.gw[0] = 192;
			g_NetInfo.gw[1] = 168;
			g_NetInfo.gw[2] = 37;
			g_NetInfo.gw[3] = 254;

			g_NetInfo.ip[0] = 192;
			g_NetInfo.ip[1] = 168;
			g_NetInfo.ip[2] = 37;
			g_NetInfo.ip[3] = 174;	// test machine for linux

			g_NetInfo.sn[0] = 255;
			g_NetInfo.sn[1] = 255;
			g_NetInfo.sn[2] = 255;
			g_NetInfo.sn[3] = 0;
		} else if(ipset == 15)  {
			g_NetInfo.gw[0] = 192;
			g_NetInfo.gw[1] = 168;
			g_NetInfo.gw[2] = 37;
			g_NetInfo.gw[3] = 254;

			g_NetInfo.ip[0] = 192;
			g_NetInfo.ip[1] = 168;
			g_NetInfo.ip[2] = 37;
			g_NetInfo.ip[3] = 78;	// test machine for linux

			g_NetInfo.sn[0] = 255;
			g_NetInfo.sn[1] = 255;
			g_NetInfo.sn[2] = 255;
			g_NetInfo.sn[3] = 0;

		} else {
//			g_NetInfo.gw[0] = 192;
//			g_NetInfo.gw[1] = 168;
//			g_NetInfo.gw[2] = 37;
//			g_NetInfo.gw[3] = 254;
//
//			g_NetInfo.ip[0] = 192;
//			g_NetInfo.ip[1] = 168;
//			g_NetInfo.ip[2] = 37;
//			g_NetInfo.ip[3] = 190 + ipset;

			g_NetInfo.gw[0] = 192;
			g_NetInfo.gw[1] = 168;
			g_NetInfo.gw[2] = 100;
			g_NetInfo.gw[3] = 1;

			g_NetInfo.ip[0] = 192;
			g_NetInfo.ip[1] = 168;
			g_NetInfo.ip[2] = 100;
			g_NetInfo.ip[3] = 200 + ipset;
		}
		g_NetInfo.mac[5] = 0xe0 + ipset;

		setMR(getMR() | MR_FS); // If Little-endian, set MR_FS.
		val = getMR();

		if (val & MR_FS) TRACE(" Endian : swap, Little-Endian  \r\n");
		else 		TRACE(" Endian : (no-swap), Big-Endian \r\n");

		// configure network information
		ctlnetwork(CN_SET_NETINFO, (void*)&g_NetInfo);

		/* verify network information */
		ctlnetwork(CN_GET_NETINFO, (void*)&g_NetInfo);

		TRACE("Network information ...\r\n");
		TRACE("SHAR : %02x:%02x:%02x:%02x:%02x:%02x\r\n",
				g_NetInfo.mac[0], g_NetInfo.mac[1], g_NetInfo.mac[2], g_NetInfo.mac[3], g_NetInfo.mac[4], g_NetInfo.mac[5]);
		TRACE("GWR  : %d.%d.%d.%d\r\n", g_NetInfo.gw[0], g_NetInfo.gw[1], g_NetInfo.gw[2], g_NetInfo.gw[3]);
		TRACE("SUBR : %d.%d.%d.%d\r\n", g_NetInfo.sn[0], g_NetInfo.sn[1], g_NetInfo.sn[2], g_NetInfo.sn[3]);
		TRACE("SIPR : %d.%d.%d.%d\r\n", g_NetInfo.ip[0], g_NetInfo.ip[1], g_NetInfo.ip[2], g_NetInfo.ip[3]);
//		m_LanProtocol = 1;	// 0 : UDP, 1 : TCP
	}

//	{
//		uint16_t endian = getMR() & MR_FS;
//		if (endian) TRACE(" Endian : swap, Little-Endian  \r\n");
//		else 		TRACE(" Endian : (no-swap), Big-Endian \r\n");
//	}
	eth_lock.Lock = 0;
}

static int init_hw()
{
	unsigned int w5300_intr_mask = IK_ALL | IK_SOCK_ALL;
	unsigned int w5300_tmp = 0;
	unsigned int tmp = 0;
	int res = 0;

	int retry = 10;
	// w5300
	while (retry--) {
		if(ctlwizchip(CW_RESET_WIZCHIP, NULL) ==  0)   break;
		TRACE(">> wizchip reset : retry : %d \r\n", retry);
		HAL_Delay(100);
	}
	if (retry < 0) {
		return -1;
	}

	res = ctlwizchip(CW_INIT_WIZCHIP, NULL);		// reset & init
        
	// set IMR
	ctlwizchip(CW_SET_INTRMASK,  &w5300_intr_mask);
	ctlwizchip(CW_CLR_INTERRUPT,  0);

	// socket 
	w5300_intr_mask = 0;
	w5300_tmp = 0;
	ctlwizchip(CW_GET_INTRMASK,  &w5300_intr_mask);
	ctlwizchip(CW_GET_INTERRUPT,  &w5300_tmp);

	TRACE("## Init hw ## IMR:0x%08x IR : 0x%08x\r\n", w5300_intr_mask, w5300_tmp);
	return 0;
}

static int Netif_Config(void)
{
#if 0
	ip_addr_t ipaddr;
	ip_addr_t netmask;
	ip_addr_t gw;

	/* IP address default setting */
	IP4_ADDR(&ipaddr,	sysConfig.ipAdrs[0], sysConfig.ipAdrs[1], sysConfig.ipAdrs[2], sysConfig.ipAdrs[3]);
	IP4_ADDR(&netmask,	sysConfig.nmAdrs[0], sysConfig.nmAdrs[1], sysConfig.nmAdrs[2], sysConfig.nmAdrs[3]);
	IP4_ADDR(&gw,		sysConfig.gwAdrs[0], sysConfig.gwAdrs[1], sysConfig.gwAdrs[2], sysConfig.gwAdrs[3]);

	/* Add the network interface */    
	netif_add(&gnetif, &ipaddr, &netmask, &gw, NULL, &ethernetif_init, &ethernet_input);

	/* Registers the default network interface */
	netif_set_default(&gnetif);

	if (netif_is_link_up(&gnetif))
	{
		/* When the netif is fully configured this function must be called */
		netif_set_up(&gnetif);
	}
	else
	{
		/* When the netif link is down this function must be called */
		netif_set_down(&gnetif);
	}

	/* Set the link callback function, this function is called on change of link status*/
	netif_set_link_callback(&gnetif, ethernetif_update_config);
#else
	uint32_t lan_ip = 0;
	
#define	TOP_FPGA_CHECK_ID	(0x00100000)
#define	TOP_FPGA_VER		(0x00100004)
#define	TOP_FPGA_ERR_LED	(0x00100008)
#define	TOP_FPGA_LED		(0x0010000C)

#define	TOP_FPGA_LAN_IP		(0x00100018)
/////
#define TOP_FPGA_BASE     		(0x00000000)	// NE1	
#define TOP_W5300_BASE     		(0x01000000)	// NE2

	//lan_ip = 0x000F & FPGA_ReadSingle(TOP_FPGA_LAN_IP);
	lan_ip = FPGA_ReadSingle(TOP_FPGA_LAN_IP);
	TRACE(">>LAN IP : %04x\r\n", lan_ip);

	if (lan_ip == 0xFFFF) {
		return -1;
	}

	HAL_Delay(100); 

	if (init_hw() < 0) {
		return -1;
	}
	init_eth(lan_ip);

	return 0;
#endif
}

static uint8_t tcp_server_init()
{
	int32_t port = m_Port;
	int32_t ret = 0;

	if (networkEnable > 0)
		return 1;

	TRACE(">>Network: tcp_server_init (TCP) \r\n");

	if((ret = socket(m_Socket, Sn_MR_TCP, port, 0x00)) != m_Socket) {
		TRACE(">>Network: open fail. %d, %d\r\n", port, m_Socket);
		networkEnable = 1;
		return 1;
	}
	if((ret = socket(m_Socket, Sn_MR_TCP, port, Sn_MR_ND)) != m_Socket) {
		TRACE(">>Network: open fail. %d, %d\r\n", port, m_Socket);
		networkEnable = 1;
		return 1;
	}

	return 0;
}

void tcp_server_send_data(u8* pData, u32 length)
{
	int len = 0;

	if (getSn_SR(m_Socket) == SOCK_ESTABLISHED )
	{
		len = send(m_Socket, (u8*)pData, length);
	}

//		TRACE(">>Network: tcp_server_send_data . len=%d/%d \r\n", len, length);
}

void udp_server_send_data(u8* pData, u32 length)
{
	int len = 0;

	len = sendto(m_Socket, (u8*)pData, length, m_UdpDestIP, m_UdpDestPort);
	TRACE(">>Network: udp_server_send_data . len=%d/%d \r\n", len, length);
}

static uint8_t udp_server_do()
{
	switch(getSn_SR(m_Socket))
	{
		case SOCK_UDP:
			if(getSn_RX_RSR(m_Socket) > 0)
			{
				//printf("# LAN Mode\r\n");
				//GotoRemote(csLan);
				return TRUE;
			}
			break;

		case SOCK_CLOSED:
			printf("# LAN Socket Close.\r\n");
			close(m_Socket);
			socket(m_Socket, Sn_MR_UDP, m_UdpPort, 0);
			break;
	}

	return FALSE;
}



static uint8_t tcp_server_do()
{
	int32_t ret;
	uint16_t size = 0;
	uint8_t wiz_rx_buf[1024*8];	// wiz rx buff
	int32_t port = m_Port;
	int sn = 0;
	int i;

#ifdef _LOOPBACK_DEBUG_
	uint8_t m_DEstIP[4];
	uint16_t m_DEstPort;
#endif

	if (networkEnable > 0)
		return 1;

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
			return 1;

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
				TRACE("==> init... 0x%08x , %d \r\n", val, res);
			}
			
			if( (ret = listen(m_Socket)) != SOCK_OK) return ret;
			break;
		case SOCK_CLOSED:
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:TCP server loopback start\r\n",m_Socket);
#endif
//			if((ret=socket(m_Socket, Sn_MR_TCP, port, 0x00)) != m_Socket)
//			if((ret=socket(m_Socket, Sn_MR_TCP, port, Sn_MR_ND)) != m_Socket)
		
			if((ret=socket(m_Socket, Sn_MR_TCP, port, 0x00)) != m_Socket) {
				TRACE(">>Network Init : open fail. %d, %d\r\n", port, m_Socket);
				return 1;
			}
			if((ret=socket(m_Socket, Sn_MR_TCP, port, Sn_MR_ND)) != m_Socket) {
				TRACE(">>Network Init : open fail. %d, %d\r\n", port, m_Socket);
				return 1;
			}
			return ret;
#ifdef _LOOPBACK_DEBUG_
			TRACE("%d:Socket opened\r\n",m_Socket);
#endif
			break;
		default:
			break;
	}
	return 0;
}


void udp_server_connect()
{
}

void udp_server_disconnect()
{
}

void Network_Init()
{
#if 0
	if(sysConfig.ethEN == 0)	return;

	networkPort	= sysConfig.networkPort;
	networkMode	= sysConfig.networkMode;

	lwip_init();

	Netif_Config();

	if(networkMode == NETWORK_CONNECT_TCP)
	{
		tcp_server_init();
	}
	else if(networkMode == NETWORK_CONNECT_UDP)
	{
		udp_server_init();
	}

	User_notification(&gnetif);
#else
	networkEnable = 0;
	networkPort	= 7000;	 				//sysConfig.networkPort;
	networkMode	= NETWORK_CONNECT_TCP;	//sysConfig.networkMode;
	networkPktMode = NETWORK_PKT_MODE_CMD;

	if (Netif_Config() < 0){
		TRACE("network config fail.. \r\n");
		networkEnable = 0;
	}

	tcp_server_init();
#endif
}

void Network_FrameCheck()
{
#if 0
	//if(netif_is_up(&gnetif))
	if(netif_is_link_up(&gnetif))
	{
		ethernetif_input(&gnetif);

		sys_check_timeouts();
	}
#endif
}

uint8_t nrx_Buf[4 * 1024];

void w5300_irq_handler()
{
	int sn_ir = 0;
	int ir = 0;
	int sir = 0;
	unsigned int w5300_intr_mask = IK_ALL | IK_SOCK_ALL;

	// read var
	int len = 0;

	if (hal_lock(&eth_lock) == HAL_OK) {
		// get socket
		ctlwizchip(CW_GET_INTERRUPT,  &ir);
		sir = (ir >> 8) & 0xFF;
		ir = (ir & 0xFF);
	
		if (sir < 1) {
			return ;
		}
	
		// read Sx_IR
		ctlsocket((sir - 1), CS_GET_INTERRUPT, &sn_ir);
		// write Sx_IR
		ctlsocket((sir - 1), CS_CLR_INTERRUPT, &sn_ir);
	
		//	SEND
		if (sn_ir & Sn_IR_SENDOK) {
			tx_busy(sir - 1, 0);
		}
	
		//	RECV
		if (sn_ir & Sn_IR_RECV) {
			int rx_len = 0;
			int try_cnt = 10;
	
			// disable interrupt
			ctlwizchip(CW_SET_INTRMASK,  0);
			// get rx_buff
			len = getSn_RX_RSR(sir - 1);
	
			do {
				rx_len = recv(sir - 1, nrx_Buf, len);
				Network_RxData(nrx_Buf, len);
	
				len -= rx_len;
				if (try_cnt-- < 1)
					break;
	
			} while (len > 3);
	
			//enable interrupt
			ctlwizchip(CW_SET_INTRMASK,  &w5300_intr_mask);
		}
	
		// clear ir
		ctlwizchip(CW_CLR_INTERRUPT,  0);
		hal_unlock(&eth_lock);
	} else {
		TRACE("ETHERNET(i) : lock error..\r\n");
	}

}

void Network_DataProcess()
{
	int ret = 0;
//	if(sysConfig.ethEN == 0)	return;

	if(networkIntFlag)
	{
//		ret = wizchip_getinterrupt();
		networkIntFlag = 0;                
	} else {
		// TODO : behavior is polling... may be insert the interrupt routine
		tcp_server_do();
		//udp_server_do();
	}

	Network_FrameCheck();
}

void Network_ServerConnect()
{
	switch(networkMode)
	{
		case NETWORK_CONNECT_UDP:
			udp_server_connect();
			break;
	}
}

void Network_ServerDisconnect()
{
	switch(networkMode)
	{
		case NETWORK_CONNECT_UDP:
			udp_server_disconnect();
			break;
	}
}

void Network_TransmitData(u8 *pData, u16 length)
{
	switch(networkMode)
	{
		case NETWORK_CONNECT_TCP:
			tcp_server_send_data(pData, length);
			break;

		case NETWORK_CONNECT_UDP:
			udp_server_send_data(pData, length);
			break;
	}
}

void Network_RxRecover(u8	clear)
{
	memset(networkRxData, NULL, networkRxCnt);

	networkRxCnt = 0;

	networkRxFlag = 0;
}

void Network_RxData(u8 *pData, u16 length)
{
	if(length != 0)
	{

		networkPktRxCnt = length;

		pNetworkPktRxData = pData;

		networkPktRxFlag = 1;
	}
}

static void Network_DataCpy(u8 *pDst, u8 *pSrc, u32 size)
{
	u8	mode = 1;
	u32	*pDst4, *pSrc4;

	if((u32)pDst % 4)		mode = 0;
	if((u32)pSrc % 4)		mode = 0;
	if(size % 4)			mode = 0;

	if(mode == 0)		// 1 Byte Copy
	{
		for(u32 cnt = 0; cnt < size; cnt++)
		{
			pDst[cnt] = pSrc[cnt];
		}
	}
	else				// 4 Byte Copy
	{
		pDst4	= (u32*)pDst;
		pSrc4	= (u32*)pSrc;

		size	/= 4;

		for(u32 cnt = 0; cnt < size; cnt++)
		{
			pDst4[cnt] = pSrc4[cnt];
		}
	}
}

u8 Network_PacketChecker(u8 *pData, u16 size)
{
	u8	result = 0;
	u8	stx, etx, nextData;
	u16	length, waitTime;

	// find sot
	length = size;
	do {
		if (TS_STX == pData[0])
			break;
		pData = pData++;
	} while(length--);

        
	if (length < 4)
		return result;

	// type 
	stx = pData[1];
	if(stx == 0xFF)			
		return -1;      // 0xff

	if (stx != TS_CHAR) 
		return 0;

	// Check Length
	length = SYS_HexToHWord(&pData[2]);
	if(length > 1024)		return result;
	if(size < (length + 4))	return result;

	// Check ETX
	etx = pData[length + 4];
	if(etx != TS_ETX)			return result;

	result = 1;

	return result;
}

u8 Network_PacketSender(u8 nextData, u16 waitTime, u8 *pData, u16 length)
{
	u8	result = 0;
	u16	totalLength;
	
	nextData &= 0x01;
	if(waitTime > 65000)		waitTime = 65000;
	if(length > 1024)			return result;
	
	networkPktTxData[0] = TS_STX;										// STX
	SYS_HWordToHex(length, &networkPktTxData[2]);					// LENGTH
	Network_DataCpy((u8*)&networkPktTxData[4], pData, length);		// DATA
	networkPktTxData[length + 4] = TS_ETX;								// ETX
	
	totalLength = length + 4 + 1;
	
	// Transmit Data
	Network_TransmitData(networkPktTxData, totalLength);
	
	result = 1;
	
	return result;
}


//	u8 Network_PacketSender(u8 nextData, u16 waitTime, u8 *pData, u16 length)
//	{
//		u8	result = 0;
//		u16	totalLength;
//		//u8 reversTemp;
//		u16 reversTemp;
//		u16 reversLoopCnt;
//		u16 i;
//		
//		
//		nextData &= 0x01;
//		if(waitTime > 65000)		waitTime = 65000;
//		if(length > 1024)			return result;
//		
//		
//		SYS_HWordToHex(TS_STX, &networkPktTxData[0]);					// STX
//		memcpy(&networkPktTxData[2], &length, 2);						// Length
//		Network_DataCpy((u8*)&networkPktTxData[4], pData, length);		// DATA
//		
//		if(length % 2) reversLoopCnt = (length -1 ) / 2;		// if odd
//		else reversLoopCnt = length /2;
//			
//		
//		for(i = 0; i < reversLoopCnt; i++)
//		{
//	//			reversTemp = networkPktTxData[i*2+4];
//	//			networkPktTxData[i*2+4] = networkPktTxData[i*2+4+1];
//	//			networkPktTxData[i*2+4+1] = reversTemp;
//			memcpy(&reversTemp, &networkPktTxData[i*2+4], 2);
//			reversTemp = (((u16)reversTemp & 0x00FF) << 8) | ((u16)reversTemp & 0x00FF);
//			SYS_HWordToHex(reversTemp, &networkPktTxData[i*2+4]);
//		
//	//				Network_DataCpy((u8*)&reversTemp,&networkPktTxData[i*2+4], 2);
//	//				SYS_HWordToHex(reversTemp, &networkPktTxData[i*2+4]);
//		}		
//	
//	
//	//					if(mr & MR_FS)
//	//					recvsize = (((uint16_t)head[0]) << 8) | ((uint16_t)head[1]);
//	//				else
//	//					recvsize = (((uint16_t)head[1]) << 8) | ((uint16_t)head[0]);
//		
//		
//		networkPktTxData[length + 4] = TS_ETX;								// ETX
//		
//		
//		totalLength = length + 4 + 1;	
//		
//		// Transmit Data
//		Network_TransmitData(networkPktTxData, totalLength);
//		
//		result = 1;
//		
//		return result;
//	}






u8 Network_TransmitAck(u8 nextData, u8 state)
{
	u8	result = 0, rtn;
	u8	data[4];

	data[0] = state;

	rtn = Network_PacketSender(nextData, 0, data, 1);

	if(rtn != 0)	result = 1;

	return result;
}

u8 Network_WaitTimeSend(u16 waitTime)
{
	u8	result = 0, rtn;

	if(waitTime == 0)	waitTime = 1;

	rtn = Network_PacketSender(1, waitTime, 0, 0);

	if(rtn != 0)	result = 1;

	return result;
}

u8 Network_PacketReceiver()
{
	u8	result = NETWORK_PKT_RCV_ERROR, rtn = 0;
	u8p	pData_tmp;
	u8p	pData;
	u8	nextData;
	u16	length;
	
	rtn = Network_PacketChecker(pNetworkPktRxData, networkPktRxCnt);

	// test code.
	if (rtn == 0xFF) {
		// reboot
		systemReset = 1;
	}

	networkPktRxFlag = 0;

	if(rtn)
	{
		// find sot
		pData_tmp = pNetworkPktRxData;
		length = networkPktRxCnt;
		do {
			if (TS_STX == pData_tmp[0])
				break;
			pData_tmp = pData_tmp++;
		} while(length--);

		pData		= &pData_tmp[4];
		length		= SYS_HexToHWord(&pData_tmp[2]);
		nextData	= (pData_tmp[1] == 0xD2)? 1: 0;

		if(networkPktMode == NETWORK_PKT_MODE_CMD)
		{
			Network_DataCpy((u8*)&networkRxData[networkRxCnt], pData, length);

			networkRxCnt += length;
			
			if(nextData == 0)	networkRxFlag = 1;
		}
		else if(networkPktMode == NETWORK_PKT_MODE_FILE)
		{
			Network_DataCpy((u8*)&pNetworkRxFile[networkRxFileSize], pData, length);

			networkRxFileSize += length;
		}
#if 0
		if(nextData)
		{
			Network_TransmitAck(nextData, 1);

			result = NETWORK_PKT_RCV_ING;
		}
		else
		{
			Network_TransmitAck(0, 1);
			result = NETWORK_PKT_RCV_COMPLETE;
		}
#endif                
	}
	else
	{
		Network_TransmitAck(0, 0);
	}
#if 0
	uint32_t len;
	uint16_t  stx;  //, length;

	m_DownSize = 0;

//	if(getSn_SSR(m_UdpSocket) == SOCK_UDP)
//	{
//		len = getSn_RX_RSR(m_UdpSocket);
//
//		if(len > 0)
//		{
//			len = recvfrom(m_UdpSocket, &m_pBuf[w5300_rx_count], len, m_UdpDestIP, &m_UdpDestPort);
//			w5300_rx_count += len;
//            m_pBuf[len] = 0;
//		}
//
//		memset(m_RecvMsg, NULL, sizeof(m_RecvMsg));
//
//		memcpy(m_RecvMsg, m_pBuf, len);
//		m_RxCount = len;
//
//		memset(m_pBuf, NULL, sizeof(m_pBuf));
//		w5300_rx_count = 0;
//
//		return true;
//	} else 
	{
		len = getSn_RX_RSR(m_Socket);

		if(len) 
		{
			if(len > DEF_RX_DATA_BUF_SIZE) len = DEF_RX_DATA_BUF_SIZE;

			len = recv(m_Socket, m_pBuf, len);

			//**  debuggging.
			if (len < 10) {
				int i;
				for (i = 0; i < len; i++ ) {
					printf("tcp-receiver : %2d : %02x\n", i, m_pBuf[i]);
				}

			}
			//**
		}
		m_DownSize = len;

		if (m_DownSize > 0)
			result = NETWORK_PKT_RCV_COMPLETE;
	}
#endif

	return result;
}

u8 Network_PacketProcess()
{
	u8	result = 0, rtn;

	 if(networkPktRxFlag == 0)	return result;

	rtn = Network_PacketReceiver();

	if(rtn)	result = 1;

	return result;
}

u8 Network_FileDownload(u32 dstAdrs, u32 *pRcvSize)
{
	u8	result = NETWORK_PKT_RCV_ERROR, rtn;
	u32	sTime, rTime;

	pNetworkRxFile		= (u8*)dstAdrs;
	networkRxFileSize	= 0;
 
	Network_PacketSender(0, 0, (u8p)"Ready\r\n", 7);

	networkPktMode = NETWORK_PKT_MODE_FILE;

	sTime = HAL_GetTick();
	
	do{
		Network_FrameCheck();
		
		if(networkPktRxFlag)
		{
			rtn = Network_PacketReceiver();

			if(rtn == NETWORK_PKT_RCV_ING)
			{
				sTime = HAL_GetTick();
			}

			if(rtn == NETWORK_PKT_RCV_COMPLETE)
			{
				result = 1;
				break;
			}
		}

		rTime = HAL_GetTick();

		if((rTime - sTime) > NETWORK_FILE_DOWNLOAD_TIMEOUT)
		{
			break;
		}
	}while(1);

	networkPktMode = NETWORK_PKT_MODE_CMD;

	*pRcvSize = networkRxFileSize;

	return result;
}

u8 Network_ReceiveAck(u8 *pState)
{
	u8	result = 0, rtn;
	u32	sTime, rTime;
	u8p	pData;
	u16	length;

	sTime = HAL_GetTick();
	
	do{
		Network_FrameCheck();

		if(networkPktRxFlag)
		{
			rtn = Network_PacketChecker(pNetworkPktRxData, networkPktRxCnt);

			networkPktRxFlag = 0;

			if(rtn)
			{
				pData		= &pNetworkPktRxData[6];
				length		= SYS_HexToHWord(&pNetworkPktRxData[1]);

				if(length == 1)
				{
					*pState = pData[0];
					result = 1;
					break;
				}
				else
				{
					Network_TransmitAck(0, 0);
				}
			}
			else
			{
				Network_TransmitAck(0, 0);
			}
		}

		rTime = HAL_GetTick();

		if((rTime - sTime) > NETWORK_RECEIVE_ACK_TIMEOUT)
		{
			break;
		}
	}while(1);

	return result;
}

u8 Network_TransmitPacket(u8 *pData, u32 length)
{
	u8	result = 0, rtn;
	u8	state = 0;
	u8p	pPacket;
	u32	size;

	pPacket = pData;

	size = length;

	Network_ServerConnect();

	do{
		// TRANSMIT DATA
		if(size > 1024)
		{
			Network_PacketSender(1, 0, pPacket, 1024);

			rtn = Network_ReceiveAck(&state);

			if(rtn == 0)	break;

			pPacket = &pPacket[1024];

			size -= 1024;
		}
		else
		{
			Network_PacketSender(0, 0, pPacket, size);
			
			size -= size;

			result = 1;
		}
	}while(size > 0);

	Network_ServerDisconnect();

	return result;
}

