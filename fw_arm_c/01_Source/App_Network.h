#ifndef	_APP_NETWORK_H
#define	_APP_NETWORK_H

#include 	"top_core_info.h"

#define DEF_RX_BUF_SIZE 		(2048)
#define DEF_RX_DATA_BUF_SIZE 	(4 * 1024) 


#define	NETWORK_TRX_PACKET_SIZE			2048

#define	NETWORK_FILE_DOWNLOAD_TIMEOUT	4000
#define	NETWORK_RECEIVE_ACK_TIMEOUT		10000

enum{
	NETWORK_CONNECT_TCP = 0,
	NETWORK_CONNECT_UDP,
};

enum{
	NETWORK_PKT_MODE_CMD = 0,
	NETWORK_PKT_MODE_FILE,
};

enum{
	NETWORK_PKT_RCV_ERROR = 0,
	NETWORK_PKT_RCV_ING,
	NETWORK_PKT_RCV_COMPLETE,
};

#if	_WIZCHIP_ == W5100S || _WIZCHIP_ == W5200 || _WIZCHIP_ == W5500 || _WIZCHIP_ == W5300
extern	wiz_NetInfo g_NetInfo;
#else
extern	struct	netif	gnetif;
#endif

extern	u8	networkIntFlag;

extern	u8	networkMode;
extern	u16	networkPort;

extern	u8	networkRxFlag, *networkRxData;
extern	u32	networkRxCnt;

extern	u8	networkPktTxData[1280];

extern	u8	networkPktRxFlag, *pNetworkPktRxData;
extern	u16	networkPktRxCnt;

extern	u8	*pNetworkRxFile;
extern	u32	networkRxFileSize;

extern	u8	networkPktMode;

#ifdef __cplusplus
extern "C" {
#endif 

void Network_Init();
void Network_FrameCheck();
void Network_DataProcess();
void Network_TransmitData(u8 *pData, u16 length);
void Network_RxRecover(u8	clear);
void Network_RxData(u8 *pData, u16 length);
u8 Network_PacketChecker(u8 *pData, u16 size);
u8 Network_PacketSender(u8 nextData, u16 waitTime, u8 *pData, u16 length);
u8 Network_TransmitAck(u8 nextData, u8 state);
u8 Network_WaitTimeSend(u16 waitTime);
u8 Network_PacketReceiver();
u8 Network_PacketProcess();
u8 Network_FileDownload(u32 dstAdrs, u32 *pRcvSize);
u8 Network_ReceiveAck(u8 *pState);
u8 Network_TransmitPacket(u8 *pData, u32 length);

void w5300_irq_handler();

extern hal_lock_t  eth_lock;

#ifdef __cplusplus
}
#endif

#endif	// !_APP_NETWORK_H
