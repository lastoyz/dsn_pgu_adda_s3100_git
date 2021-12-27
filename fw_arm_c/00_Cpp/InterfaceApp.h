
// InterfaceApp.h: interface for the CInterfaceApp class.
//
//////////////////////////////////////////////////////////////////////
#ifndef _ELE_INTERFACEAPP_H_
#define _ELE_INTERFACEAPP_H_

#include "top_core_info.h"
#include "CmdToken.h"

#define SOCKET                uint8_t  ///< SOCKET type define for legacy driver
#define DEF_RX_BUF_SIZE 		(2048)
#define DEF_RX_DATA_BUF_SIZE 	(4 * 1024) 

#if 0

#include "systype.h"
#include "net/types.h"

#include "protocol_parser.h"

//#include "net/network.h"
//#include "net/socket.h"

#include "eleSerial.h"
#include "CmdToken.h"
#include "SwmTpiDrv.h"
#include "DCTpiDrv.h"
#include "CfgMtxTpiDrv.h"
#include "smu.h"
#include "measure.h"
#endif

#define ERR_PROTOCOL  "E02\r"
#define ERR_FUNCTION  "E01\r"
#define ERR_NO        "E00\r"

#define ETHERNET_DEST_LENGTH     6           // Destination address
#define ETHERNET_SRC_LENGTH      6           // Source address
#define ETHERNET_TYPE_LENGTH     2           // The protocol type
#define ETHERNET_MIN_PDU_LENGTH  46          // Minimum payload
#define ETHERNET_MAX_PDU_LENGTH  1500        // Maximum payload
#define ETHERNET_MIN_LENGTH      60          // Minimum packet length
#define ETHERNET_MAX_LENGTH      1514        // Maximum packet length

#define DRV_HLEN 14
#define DRV_DST_MAC 0
#define DRV_SRC_MAC 6
#define DRV_ETHER_TYPE 12
#define MAC_LEN 6
#define CRC_LEN 4


//#ifndef _E1400_LED_CTRL_
//#define _E1400_LED_CTRL_
//
//// for LED. 
////#define MEM_ADDR_CS2		(0x08000000)		//	nCS2 : for ERR_LED, SDC_FLICKER_LED
//#define MEM_MAP_ADDR_REG	(0x40000000)	//	Memory-mapped registers
//#define MEM_ADDR_GPIO		(MEM_MAP_ADDR_REG + 0x00E00000)	//	GPIO
////#define MEM_ADDR_GPSR1		(MEM_ADDR_GPIO + 0x0000001C)
////#define MEM_ADDR_GPCR1		(MEM_ADDR_GPIO + 0x00000028)
////
//#define MEM_ERR_LED		(MEM_ADDR_CS2 | 0x00100000)		//	ERR_LED
//#define MEM_SDC_LED		(MEM_ADDR_CS2 | 0x00300004)		//	SDC_LED
//
////#define LED_ON		1
////#define LED_OFF		0
//
//// GPIO_52
//#define SetLED2(nSW)	if(nSW == LED_ON)		*((volatile UINT32 *)MEM_ADDR_GPCR1) |= 0x00100000;	\
//						else					*((volatile UINT32 *)MEM_ADDR_GPSR1) |= 0x00100000;
//#define SetLED3(nSW)	if(nSW == LED_ON)		*((volatile UINT32 *)MEM_ADDR_GPCR1) |= 0x00200000; \
//						else					*((volatile UINT32 *)MEM_ADDR_GPSR1) |= 0x00200000;
//
//#define SetLED4(nSW)	if(nSW == LED_ON)		*((volatile UINT32 *)MEM_ERR_LED) = 0; \
//								else					*((volatile UINT32 *)MEM_ERR_LED) = 1;
//
//#define SetLED6(nSW)	*((volatile UINT32 *)MEM_SDC_LED) = nSW;
//
//#endif

typedef enum {csNone, csSerial, csGpib, csLan} TCommunicationSource;

#define RET_ERR    -1
#define RET_OK		0
#define RET_CLOSE	1
#define RET_EXIT    2

#define UDP_PORT_TEG	7000
#define TCP_PORT_TEG	5000
#define SOCK_TCPS		0

struct in_addr {
	UINT32 s_addr;
};

struct sockaddr_in {
	UINT16 sin_family;
	UINT16 sin_port;
	struct in_addr sin_addr;
	UINT8 sin_zero[8];
};

class CInterfaceApp  
{
	public:
		CInterfaceApp();
		~CInterfaceApp();

	private:
		BOOL m_IsSerial;


		CCmdToken   m_CmdToken;

		unsigned int m_nPacketSeq;


	public:
//		CC270B3Board m_CPU;

		int			errFlag;

		bool		m_IsRemote;
		char        m_RecvMsg[DEF_RX_DATA_BUF_SIZE];
		int			m_RxCount;

		u8 			m_pBuf[DEF_RX_BUF_SIZE];
		unsigned int m_DownSize;

		bool		m_Rs232Installed;
		bool		m_GpibInstalled;
		bool		m_LanInstalled;

		int			m_GpibTerm;

		int 		m_CommSource;

		// Ethernet (w5300)
//		wiz_NetInfo m_NetInfo;

		// udp tcp info
		SOCKET m_UdpSocket;
		uint16 m_UdpPort;
		u8 m_UdpDestIP[4];
		uint16 m_UdpDestPort;

		// tcp info
		SOCKET m_Socket;
		uint16 m_Port;
		u8 m_DestIP[4];
		uint16 m_DestPort;

		u8 m_LanProtocol;
		char m_mode;		// 'c' : string , 'b' : bin
//		CDCTpiDrv   m_DcTpi;

//		CEleSerial	m_hSerialCom;

		void GotoRemote(TCommunicationSource comm);
		void GotoLocal(void);
		bool MessageAvailable(void);
		bool ReadCommand(void);
		bool WriteCommand(char *str);

#if 0		// deprecated.. : oldstyle
		bool ReadCommandLan(void);
		bool ReadCommandGpib(void);
		bool ReadCommandSerial(void);
		bool WriteCommandLan(char *str);
		bool WriteCommandGpib(char *str);
		bool WriteCommandSerial(char *str);
#endif

		INT32 m_TegPort;
		INT32 m_TegSocket;
		struct sockaddr_in m_TegFrom;

		BOOL Create(u8 ipset);
#if 0		// deprecated.. : oldstyle
		BOOL DoSerial();
		BOOL DoLan();
		BOOL DoUDP();
		BOOL DoTCP();
#endif

		int TcpServer();
		int UdpServer();

#if 0		// deprecated.. : oldstyle
		int ReadPacketUDP(char *msg);
		int WritePacketUDP(const char *msg, int size);
#endif

		BOOL CmdService(void);
		void DisplayConnectMsg(void);

		BOOL MsgOut(const char *format, ...);
		BOOL MsgOut_byte(char *data, uint32 length);
		BOOL Do();

		//******************************************************************************
		//	COMMAND 
		u8 Cmd_info(CCmdToken &Cmd);
		void ProcessSys(CCmdToken &Cmd);
		void ProcessVer(CCmdToken &Cmd);
		void ProcessMlccCommand(CCmdToken &Cmd);
		void ProcessMode(CCmdToken &Cmd);
		void DataTransmission(CCmdToken &Cmd);
        
        void ProcessTEST(void);

};

extern CInterfaceApp* pInterface;

#endif // _ELE_INTERFACEAPP_H_
