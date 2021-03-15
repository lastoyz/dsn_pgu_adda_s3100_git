#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "xil_printf.h" // print() for pure string; xil_printf() for formatted string
//#include "microblaze_sleep.h" // for usleep

#include "../../Ethernet/socket.h"
#include "loopback.h"


//#include "../../../mhvsu_base_config.h" //$$ board dependent
//#include "../../../mcs_io_bridge_ext.h" //$$ board dependent
//#include "../../../xil_sprintf.h" // to come // https://gist.github.com/raczben/a8b5410440b601ce6e7d64fd96b2d79d

// TCP Loopback Test
int32_t loopback_tcps(uint8_t sn, uint8_t* buf, uint16_t port)
{
   int32_t ret;
   uint16_t size = 0;
   uint16_t sentsize=0;
#ifdef _LOOPBACK_DEBUG_
   uint8_t destip[4];
   uint16_t destport;
#endif
   uint8_t sr; //$$
#ifdef _LOOPBACK_DEBUG_WCMSG_
   uint8_t* msg_welcome = (uint8_t*)"> Loopback TCP server is established: \r\r\n";
#endif

   switch(sr=getSn_SR(sn))
   {
      case SOCK_ESTABLISHED :
    	 //$$ case of new establish
         if(getSn_IR(sn) & Sn_IR_CON)
         {
#ifdef _LOOPBACK_DEBUG_
        	 getSn_DIPR(sn, destip);
        	 destport = getSn_DPORT(sn);
        	 //
        	 xil_printf("%d:Connected - %d.%d.%d.%d : %d \r\n",sn, destip[0], destip[1], destip[2], destip[3], destport);
#endif
             setSn_IR(sn,Sn_IR_CON); //$$ clear establish intr.
#ifdef _LOOPBACK_DEBUG_WCMSG_			 
             //$$ send welcome message
             size = strlen((char*)msg_welcome);
             ret = send(sn,msg_welcome,size); //$$ send welcome msg
             if(ret < 0)
             {
                close(sn);
                return ret;
             }
             //$$
#endif			 
         }
         //$$ loopback data
         if((size = getSn_RX_RSR(sn)) > 0) //$$ check received data size
         {
            if(size > DATA_BUF_SIZE) size = DATA_BUF_SIZE;
            ret = recv(sn, buf, size); //$$ read socket data
            if(ret <= 0) return ret;
            sentsize = 0;
            while(size != sentsize)
            {
               ret = send(sn,buf+sentsize,size-sentsize); //$$ send loopback
               if(ret < 0)
               {
                  close(sn);
                  return ret;
               }
               sentsize += ret; // Don't care SOCKERR_BUSY, because it is zero.
            }
         }
         //$$
         break;
      case SOCK_CLOSE_WAIT :
#ifdef _LOOPBACK_DEBUG_
         //xil_printf("%d:CloseWait \r\n",sn);
#endif
         if((ret=disconnect(sn)) != SOCK_OK) return ret;
#ifdef _LOOPBACK_DEBUG_
         xil_printf("%d:Socket closed \r\n",sn);
#endif
         break;
      case SOCK_INIT :
#ifdef _LOOPBACK_DEBUG_
    	 xil_printf("%d:Listen, TCP server loopback, port [%d] \r\n",sn, port);
#endif
         if( (ret = listen(sn)) != SOCK_OK) return ret;
         break;
      case SOCK_CLOSED:
#ifdef _LOOPBACK_DEBUG_
         //xil_printf("%d:TCP server loopback start \r\n",sn);
#endif
         if((ret=socket(sn, Sn_MR_TCP, port, 0x00)) != sn)
         //if((ret=socket(sn, Sn_MR_TCP, port, Sn_MR_ND)) != sn)
            return ret;
#ifdef _LOOPBACK_DEBUG_
         xil_printf("%d:Socket opened \r\n",sn);
         //xil_printf("%d:Opened, TCP server loopback, port [%d] \r\n",sn, port);
#endif
         break;
      case SOCK_LISTEN:
    	 //$$ nothing to do...
    	 break;
      default:
         break;
   }
   return 1;
}


// UDP Loopback Test
int32_t loopback_udps(uint8_t sn, uint8_t* buf, uint16_t port)
{
   int32_t  ret;
   uint16_t size, sentsize;
   uint8_t  destip[4];
   uint16_t destport;
   //uint8_t  packinfo = 0;
   uint8_t sr; //$$

   switch(sr=getSn_SR(sn))
   {
      case SOCK_UDP :
         if((size = getSn_RX_RSR(sn)) > 0)
         {
            if(size > DATA_BUF_SIZE) size = DATA_BUF_SIZE;
            ret = recvfrom(sn,buf,size,destip,(uint16_t*)&destport);
            if(ret <= 0)
            {
#ifdef _LOOPBACK_DEBUG_
               xil_printf("%d: recvfrom error. %ld \r\n",sn,ret);
#endif
               return ret;
            }
            size = (uint16_t) ret;
            sentsize = 0;
            while(sentsize != size)
            {
               ret = sendto(sn,buf+sentsize,size-sentsize,destip,destport);
               if(ret < 0)
               {
#ifdef _LOOPBACK_DEBUG_
                  xil_printf("%d: sendto error. %ld \r\n",sn,ret);
#endif
                  return ret;
               }
               sentsize += ret; // Don't care SOCKERR_BUSY, because it is zero.
            }
         }
         break;
      case SOCK_CLOSED:
#ifdef _LOOPBACK_DEBUG_
         //xil_printf("%d:UDP loopback start \r\n",sn);
#endif
         if((ret=socket(sn,Sn_MR_UDP,port,0x00)) != sn)
            return ret;
#ifdef _LOOPBACK_DEBUG_
         xil_printf("%d:Opened, UDP loopback, port [%d] \r\n",sn, port);
#endif
         break;
      default :
         break;
   }
   return 1;
}
