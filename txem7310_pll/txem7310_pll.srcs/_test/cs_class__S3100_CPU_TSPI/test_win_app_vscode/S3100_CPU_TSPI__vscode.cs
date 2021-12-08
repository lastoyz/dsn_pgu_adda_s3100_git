//$$ test with vs code

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;



// note ... class SCPI_base                         //     support SCPI commands
// note ... class EPS_Dev                           //     support EPS commands
// note ... class SPI_EMUL                          //     support EPS-SPI emulation commands
// note ... class PGU_control_by_lan                //     support PGU-LAN commands
// note ... class PGU_control_by_eps                //     support PGU-EPS commands // review mcs_io_bridge_ext.c in xsdk firmware

//(case1)
// >>> SCPI_base          - _class__SCPI_base_ 
// >>> EPS_Dev            - _class__SCPI_base_:_class__EPS_Dev_ 
// >>> PGU_control_by_lan - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_lan_ 
// >>> PGU_control_by_eps - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_eps_ 
// >>> TOP_PGU (alias)    - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_lan_:_class__TOP_PGU__LAN_ // support PGU-LAN command 
//
// case1 using example:
//using mybaseclass_PGU_control = TopInstrument.PGU_control_by_lan; //##(case1) for S3000-PGU and S3100-PGU-TLAN // support PGU-LAN command
//using mybaseclass_EPS_control = TopInstrument.EPS_Dev;  //##(case2 or NA) for S3100-PGU-TLAN // support EPS by LAN commands

//(case2)
// >>> SCPI_base          - _class__SCPI_base_ 
// >>> EPS_Dev            - _class__SCPI_base_:_class__EPS_Dev_ 
// >>> PGU_control_by_lan - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_lan_ 
// >>> PGU_control_by_eps - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_eps_ 
// >>> TOP_PGU (alias)    - _class__SCPI_base_:_class__EPS_Dev_:_class__PGU_control_by_eps_:_class__TOP_PGU__EPS_LAN_ // support PGU-EPS commands
//
// case2 using example:
//using mybaseclass_PGU_control = TopInstrument.PGU_control_by_eps; //##(case2 or case3) support PGU-EPS command
//using mybaseclass_EPS_control = TopInstrument.EPS_Dev;  //##(case2 or NA) for S3100-PGU-TLAN // support EPS by LAN commands

//(case3)
// simple emualation using class SPI_EMUL !!
// >>> SCPI_base          - _class__SCPI_base_ 
// >>> EPS_Dev            - _class__SCPI_base_:_class__EPS_Dev_ 
// >>> SPI_EMUL           - _class__SCPI_base_:_class__EPS_Dev_:_class__SPI_EMUL_ 
// >>> PGU_control_by_eps - _class__SCPI_base_:_class__EPS_Dev_:_class__SPI_EMUL_:_class__PGU_control_by_eps_ 
// >>> TOP_PGU (alias)    - _class__SCPI_base_:_class__EPS_Dev_:_class__SPI_EMUL_:_class__PGU_control_by_eps_:_class__TOP_PGU__EPS_SPI_ // support PGU-SPI emulation commands
//
// case3 using example:
//using mybaseclass_PGU_control = TopInstrument.PGU_control_by_eps; //##(case2 or case3) support PGU-EPS command
//using mybaseclass_EPS_control = TopInstrument.SPI_EMUL; //##(case3) for S3100-PGU-TSPI // support EPS-SPI emulation commands

//// select top class alias
//using TOP_PGU = TopInstrument.TOP_PGU__LAN;     // case1 // not supported in this file
//using TOP_PGU = TopInstrument.TOP_PGU__EPS_LAN; // case2 // not supported in this file
//using TOP_PGU = TopInstrument.TOP_PGU__EPS_SPI;   // case3 

//using TOP_GNDU = TopInstrument.TOP_GNDU__EPS_SPI; // EPS emulated on SPI bus

//// S3100-ADDA test : class ADDA_control_by_eps
//   may support S3100-PGU-ADDA and S3100-CMU-ADDA boards with the same EPS information.

//// S3100-CMU-SUB test
// using TOP_GNDU = TopInstrument.TOP_CMU__EPS_SPI; // EPS emulated on SPI bus
// class CMU_control_by_eps

//// S3100-HVPGU test
using TOP_HVPGU = TopInstrument.TOP_HVPGU__EPS_SPI; // EPS emulated on SPI bus

namespace TopInstrument
{

    // for my base classes

    //using mybaseclass_PGU_control = TopInstrument.PGU_control_by_lan; //##(case1) for S3000-PGU and S3100-PGU-TLAN // support PGU-LAN command
    //using mybaseclass_PGU_control = TopInstrument.PGU_control_by_eps; //##(case2 or case3) support PGU-EPS command

    //using mybaseclass_EPS_control     = TopInstrument.EPS_Dev;  //##(case2 or NA) for S3100-PGU-TLAN // support EPS by LAN commands
    //using mybaseclass_EPS_control     = TopInstrument.SPI_EMUL; //##(case3) for S3100-PGU-TSPI // support EPS-SPI emulation commands


    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware


    public class SCPI_base
    {
        //## TCP socket access for SCPI commands

        //// TCPIP socket parameters
        //private int TIMEOUT = 20000;                      // socket timeout
        private int SO_SNDBUF = 32768; // 2048 --> 16384 --> 32768
        private int SO_RCVBUF = 32768;
        //private int INTVAL = 100;                       // Milli Second
        //private int BUF_SIZE_NORMAL = 2048;
        //private int BUF_SIZE_LARGE = 16384;
        //private string HOST = "192.168.100.119";
        private int PORT = 5025;
        private Socket ss = null;

        // SPCI basic commands
        private string cmd_str__IDN = "*IDN?\n"; // note EPS
        public string cmd_str__RST = "*RST\n"; // note EPS
        public string cmd_str__FPGA_FID = ":FPGA:FID?\n"; // note EPS
        public string cmd_str__FPGA_TMP = ":FPGA:TMP?\n"; // note EPS

        private int cnt_call_scpi_comm_resp = 0;
        private void increase_count_call_scpi() {
            cnt_call_scpi_comm_resp++;
        }

        public int show_count_call_scpi() {
            return cnt_call_scpi_comm_resp;
        }

        //// common subfunctions
        public DateTime Delay(int ms) //$$ ms
        {
            DateTime ThisMoment = DateTime.Now;
            TimeSpan duration = new TimeSpan(0, 0, 0, 0, ms); // days, hours, minutes, seconds, and milliseconds
            DateTime AfterWards = ThisMoment.Add(duration);

            while (AfterWards >= ThisMoment)
            {
                ThisMoment = DateTime.Now;
            }

            return DateTime.Now;
        }


        //// lan subfunctions ......
        public bool scpi_is_available(){
            bool ret = false;
            if (ss != null) ret = true;
            return ret;
        }

        public Socket scpi_open(int TIMEOUT, int SO_SNDBUF, int SO_RCVBUF)
        {
            try
            {
                Socket ss = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                ss.SendTimeout = TIMEOUT;
                ss.ReceiveTimeout = TIMEOUT;
                ss.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.SendBuffer, SO_SNDBUF);
                ss.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReceiveBuffer, SO_RCVBUF);
                return ss;

            }

            catch (Exception e)
            {
                //$$ Socket ss = null;
                throw new Exception(String.Format("Error in Open") + e.Message);
            }

        }

        public Socket scpi_connect(string HOST, int PORT)
        {
            var result = ss.BeginConnect(HOST, PORT, null, null);
            bool success = result.AsyncWaitHandle.WaitOne(2000, true);
            if (success)
            {
                ss.EndConnect(result);
            }
            else
            {
                ss.Close();
                ss = null;
                throw new SocketException(10060); // Connection timed out.                 
            }
            return ss;
        }

        public Socket scpi_close()
        {
            try
            {
                ss.Close();
            }


            catch (Exception e)
            {
                ss = null;
                throw new Exception(String.Format("Error in Close") + e.Message);
            }

            return ss;
        }

        public Socket my_open(string HOST, int TIMEOUT = 20000)
        {
            if ( scpi_is_available() ) scpi_close();
            //
            ss = scpi_open(TIMEOUT, SO_SNDBUF, SO_RCVBUF); // save socket
            scpi_connect(HOST, PORT);
                        
            return ss;
        }

        public string scpi_comm_resp_ss(byte[] cmd_str, int BUF_SIZE_NORMAL = 2048, int INTVAL = 0)
        {
            increase_count_call_scpi(); // monitoring count up

            byte[] receiverBuff = new byte[BUF_SIZE_NORMAL];

            try
            {
                //Console.WriteLine(String.Format("Send:", cmd_str));
                int Sent = ss.Send(cmd_str);
            }

            catch (Exception e)
            {
                throw new Exception(String.Format("Error in sendall") + e.Message); //$$ for release
                //$$ TODO:  print out command string for test
                //$$Console.WriteLine("(TEST)>>> " + Encoding.UTF8.GetString(cmd_str));
            }
            //
            Delay(INTVAL);
            //
            int nRecvSize;
            string data;
            try
            {
                nRecvSize = ss.Receive(receiverBuff);
                data = new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                //
                while (true)
                {
                    if (receiverBuff[nRecvSize - 1] == '\n')
                    {
                        break;
                    }
                    nRecvSize = ss.Receive(receiverBuff);
                    data = data + new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                }
            }

            catch
            {
                //Console.WriteLine(String.Format("Error in Recive"));
                //$$data = "";
                data = "#H00000000\n";
                //raise
            }
            return data;
        }



        //  # scpi command for numeric block response -- return bytearray
        //## read pipeout
        //# cmd: ":EPS:PO#HAA 001024\n"
        //# rsp: "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"		

        public byte[] scpi_comm_resp_numb_ss__bytearray(byte[] cmd_str, int BUF_SIZE_LARGE = 16384, int INTVAL = 1, int timeout_large=20000) {
            increase_count_call_scpi(); // monitoring count up

            byte[] receiverBuff = new byte[BUF_SIZE_LARGE];
            try
            {
                //Console.WriteLine(String.Format("Send:", cmd_str));
                int Sent = ss.Send(cmd_str);
            }

            catch (Exception e)
            {
                throw new Exception(String.Format("Error in sendall") + e.Message); //$$ for release
                //$$ TODO:  print out command string for test
                //Console.WriteLine("(TEST)>>> " + Encoding.UTF8.GetString(cmd_str));
            }
            //
            Delay(INTVAL);
            //
            int nRecvSize;
            //string data;
            byte[] data_bytearry = new byte[BUF_SIZE_LARGE];
            int count_to_recv;

            //# read timeout
            int rx_timeout_prev = ss.ReceiveTimeout;
            ss.ReceiveTimeout = timeout_large;

            int byte_count;
            try
            {
                nRecvSize = ss.Receive(receiverBuff);
                //data = new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                data_bytearry = receiverBuff.Take(nRecvSize).ToArray();
                // find the numeric head : must 10 in data 
                while (true)
                {
                    if (data_bytearry.Length >= 10) 
                    {
                        break;
                    }
                    nRecvSize = ss.Receive(receiverBuff);
                    //data      = data + new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                    data_bytearry = data_bytearry.Concat(receiverBuff.Take(nRecvSize)).ToArray();

                }
                // find byte count in header
                //byte_count = (int)Convert.ToInt32(data.Substring(3,6));
                byte[] byte_count__array = data_bytearry.Skip(3).Take(6).ToArray();
                string byte_count__str   = Encoding.UTF8.GetString(byte_count__array);
                byte_count = (int)Convert.ToInt32(byte_count__str);

                // collect all data by byte count
                count_to_recv = byte_count + 10 + 1; //# add header count #add /n
                while (true)
                {
                    if (data_bytearry.Length>=count_to_recv)
                        break;
                    nRecvSize = ss.Receive(receiverBuff);
                    //data      = data + new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                    data_bytearry = data_bytearry.Concat(receiverBuff.Take(nRecvSize)).ToArray();
                }
                // check the sentinel
                while (true)
                {
                    if (receiverBuff[nRecvSize - 1] == '\n')
                    {
                        break;
                    }
                    nRecvSize = ss.Receive(receiverBuff);
                    //data      = data + new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));
                    data_bytearry = data_bytearry.Concat(receiverBuff.Take(nRecvSize)).ToArray();
                }
            }
            catch
            {
                //Console.WriteLine(String.Format("Error in Recive"));
                //data = "#H00000000\n";
                //data = "NG\n";
                data_bytearry = Encoding.UTF8.GetBytes("NG\n");
            }

            //# timeout back to prev
            ss.ReceiveTimeout = rx_timeout_prev;
            //return data;
            return data_bytearry;
        }


        //$$ scpi commands

        public string get_IDN(){
            return scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__IDN));  
        }

        public string get_FPGA_TMP(){
            //$$ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            return scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__FPGA_TMP));  
        }

        public int get_FPGA_TMP_mC(){
            //$$ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__FPGA_TMP));  
            return (int)Convert.ToInt32(rsp_str.Substring(2,8),16);
        }

        //$$ test

        // test var
        private int __test_int = 0;
        
        // test function
        public static string _test() {
            string ret = "_class__SCPI_base_";
            return ret;
        }

        public static int __test_scpi_base() {
            Console.WriteLine(">>>>>> test: __test_scpi_base");

            // test member
            SCPI_base dev = new SCPI_base();
            dev.__test_int = dev.__test_int - 1;        

            return dev.__test_int;
        }

    } //// EOC

    public class EPS_Dev : SCPI_base
    {
        //## eps command access

        //// EPS LAN commands
        private string cmd_str__EPS_EN = ":EPS:EN"; // note EPS
        //
        private string cmd_str__EPS_WMI  = ":EPS:WMI";
        private string cmd_str__EPS_WMO  = ":EPS:WMO";
        private string cmd_str__EPS_TAC  = ":EPS:TAC";
        private string cmd_str__EPS_TMO  = ":EPS:TMO";
        private string cmd_str__EPS_TWO  = ":EPS:TWO";
        private string cmd_str__EPS_PI   = ":EPS:PI";
        private string cmd_str__EPS_PO   = ":EPS:PO";

        //// EPS common parameters
        //private uint MASK_ALL    = 0xFFFFFFFF;


        //$$ EPS commands

        public string eps_enable() {
            string ret;
            //### :EPS:EN //$$ endpoint enable
            ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__EPS_EN + " ON\n"));
            return ret;
        }

        public string eps_disable() {
            string ret;
            //### :EPS:EN //$$ endpoint disable
            ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__EPS_EN + " OFF\n"));
            return ret;
        }

        // endpoint functions
        public uint __GetWireOutValue__(uint adrs, uint mask = 0xFFFFFFFF) {
            //# cmd: ":EPS:WMO#Hnn #Hmmmmmmmm\n"
            //# rsp: "#H000O3245\n" 
            string cmd_str = cmd_str__EPS_WMO + string.Format("#H{0,2:X2} #H{1,8:X8}\n", adrs, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
            return (uint)Convert.ToUInt32(rsp_str.Substring(2,8),16); // convert hex into uint32;
        }

        public uint GetWireOutValue(uint adrs, uint mask = 0xFFFFFFFF) {
            return __GetWireOutValue__(adrs, mask); // convert hex into uint32;
        }

        public void UpdateWireOuts() {
            // NOP
        }

	    public void __SetWireInValue__(uint adrs, uint data, uint mask = 0xFFFFFFFF) {
            //# cmd: ":EPS:WMI#Hnn #Hnnnnnnnn #Hmmmmmmmm\n"
            //# rsp: "OK\n" or "NG\n"
            string cmd_str = cmd_str__EPS_WMI + string.Format("#H{0,2:X2} #H{1,8:X8} #H{2,8:X8}\n", adrs, data, mask);
		    string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
        }

	    public void SetWireInValue(uint adrs, uint data, uint mask = 0xFFFFFFFF) {
            __SetWireInValue__(adrs, data, mask);
        }

        public void UpdateWireIns() {
            // NOP
        }

        public void __ActivateTriggerIn__(uint adrs, int loc_bit) {
            //# cmd: ":EPS:TAC#Hnn  #Hnn\n"
            //# rsp: "OK\n" or "NG\n"
            string cmd_str = cmd_str__EPS_TAC + string.Format("#H{0,2:X2} #H{1,2:X2}\n",adrs,loc_bit);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
        }


        public void ActivateTriggerIn(uint adrs, int loc_bit) {
            __ActivateTriggerIn__(adrs, loc_bit);
        }

        public void UpdateTriggerOuts() {
            // NOP
        }

        public bool __IsTriggered__(uint adrs, uint mask) {
            //# cmd: ":EPS:TMO#H60 #H0000FFFF\n"
            //# rsp: "ON\n" or "OFF\n"
            string cmd_str = cmd_str__EPS_TMO + string.Format("#H{0,2:X2} #H{1,8:X8}\n", adrs, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
            bool ret;
            if (rsp_str.Substring(0,3)=="OFF") {
                ret = false;
            }
            else if (rsp_str.Substring(0,2)=="ON") {
                ret = true;
            } else {
                ret = false; // error in response string
            }
            return ret;
        }
        public bool IsTriggered(uint adrs, uint mask) {
            return __IsTriggered__(adrs, mask);
        }

        public uint __GetTriggerOutVector__(uint adrs, uint mask = 0xFFFFFFFF) {
            //# cmd: ":EPS:TWO#H60 #H0000FFFF\n"
            //# rsp: "#H000O3245\n"
            string cmd_str = cmd_str__EPS_TWO + string.Format("#H{0,2:X2} #H{1,8:X8}\n", adrs, mask);
            string rsp_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str));
            return (uint)Convert.ToUInt32(rsp_str.Substring(2,8),16); // convert hex into uint32;
        }

        public uint GetTriggerOutVector(uint adrs, uint mask = 0xFFFFFFFF) {
            return __GetTriggerOutVector__(adrs, mask);
        }


        public long __ReadFromPipeOut__(uint adrs, ref byte[] data_bytearray) {
            //## read pipeout
            //# cmd: ":EPS:PO#HAA 001024\n"
            //# rsp: "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"		
            int byte_count = data_bytearray.Length;
            string cmd_str = cmd_str__EPS_PO + string.Format("#H{0,2:X2} {1,6:d6}\n", adrs, byte_count);

            //// return string 
            //string rsp_str = scpi_comm_resp_numb_ss(Encoding.UTF8.GetBytes(cmd_str)); 
            //# remove header
            //string data_str = rsp_str.Substring(10, (int)byte_count); 
            //# copy data
            //data_bytearray =  Encoding.UTF8.GetBytes(data_str); //$$ must check NOT UTF8 

            //// return binary array
            byte[] rsp_bytearray = scpi_comm_resp_numb_ss__bytearray(Encoding.UTF8.GetBytes(cmd_str)); 
            //# remove header such as "#4_001024_" and tail such as '\n'
            rsp_bytearray = rsp_bytearray.Skip(10).SkipLast(1).ToArray();
            
            //# copy data
            rsp_bytearray.CopyTo(data_bytearray, 0);

            //$$ scpi_comm_resp_numb_ss may return binary data ... 
            //return (long)byte_count;
            return (long)data_bytearray.Length;
        }

        public long ReadFromPipeOut(uint adrs, ref byte[] data_bytearray) {
            return __ReadFromPipeOut__(adrs, ref data_bytearray);
        }

        public long __WriteToPipeIn__(uint adrs, ref byte[] data_bytearray) {
            //## write pipein
            //# cmd: ":EPS:PI#H8A #4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
            //# rsp: "OK\n"		
            int byte_count = data_bytearray.Length;
            //cmd_str = cmd_str__EPS_PI + ('#H{:02X} #4_{:06d}_'.format(adrs,byte_count)).encode() + data_bytearray + b'\n'
            //string cmd_str = cmd_str__EPS_PI + string.Format("#H{0,2:X2} #4_{1,6:d6}_{2}\n", adrs, byte_count, Encoding.UTF8.GetString(data_bytearray).ToCharArray());
            //string cmd_str = cmd_str__EPS_PI + string.Format("#H{0,2:X2} #4_{1,6:d6}_{2}\n", adrs, byte_count, 
            //    Encoding.UTF8.GetString(data_bytearray)); // NG //$$ must check NOT UTF8
            
            byte[] cmd_bytearray =                      Encoding.UTF8.GetBytes(cmd_str__EPS_PI);
            cmd_bytearray        = cmd_bytearray.Concat(Encoding.UTF8.GetBytes(string.Format("#H{0,2:X2} #4_{1,6:d6}_", adrs, byte_count))).ToArray();
            cmd_bytearray        = cmd_bytearray.Concat(data_bytearray).ToArray(); // binary data
            cmd_bytearray        = cmd_bytearray.Concat(Encoding.UTF8.GetBytes("\n")).ToArray();

            //$$ note that #4 format uses binary format. thus, UTF8 encoding may lose bits. instead, use byte array directly.
            string rsp_str = scpi_comm_resp_ss(cmd_bytearray);
            return (long)byte_count;
        }

        public long WriteToPipeIn(uint adrs, ref byte[] data_bytearray) {
            return __WriteToPipeIn__(adrs, ref data_bytearray);
        }


        // master SPI emulation functions
        public uint _test__reset_spi_emul(uint adrs_MSPI_TI = 0x42, uint adrs_MSPI_TO = 0x62,
            int loc_bit_MSPI_reset_trig = 0, uint mask_MSPI_reset_done = 0x00000001) {
            //## trigger reset 
            //uint adrs_MSPI_TI = 0x42;
            //uint loc_bit_MSPI_reset_trig = 0;
            //uint adrs_MSPI_TO = 0x62;
            //uint mask_MSPI_reset_done = 0x00000001;
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_reset_trig);
            uint cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_reset_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
                    break;
                }
            }
            return cnt_loop;
        }
        
        public uint _test__init__spi_emul(uint adrs_MSPI_TI = 0x42, uint adrs_MSPI_TO = 0x62,
            int loc_bit_MSPI_init_trig = 1, uint mask_MSPI_init_done = 0x00000002) {
            //## trigger init 
            //uint adrs_MSPI_TI = 0x42;
            //uint loc_bit_MSPI_init_trig = 1;
            //uint adrs_MSPI_TO = 0x62;
            //uint mask_MSPI_init_done = 0x00000002;
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_init_trig);
            uint cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_init_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //Console.WriteLine(string.Format("> done !! @ cnt_loop=", cnt_loop)); // test
                    break;
                }
            }
            return cnt_loop;
        }

        public uint _test__send_spi_frame(uint data_C, uint  data_A, uint  data_D, 
            uint enable_CS_bits_16b = 0x00001FFF, uint enable_CS_group_16b = 0x0007,
            uint adrs_MSPI_CON_WI = 0x17, uint adrs_MSPI_FLAG_WO = 0x24, uint adrs_MSPI_TI = 0x42, uint adrs_MSPI_TO = 0x62, 
            uint adrs_MSPI_EN_CS_WI = 0x16, int loc_bit_MSPI_frame_trig = 2, uint mask_MSPI_frame_done = 0x00000004) {
            //## set spi frame data (example)
            //#data_C = 0x10   ##// for read 
            //#data_A = 0x380  ##// for address of known pattern  0x_33AA_CC55
            //#data_D = 0x0000 ##// for reading (XXXX)
            uint data_MSPI_CON_WI = (data_C<<26) + (data_A<<16) + data_D;
            //uint adrs_MSPI_CON_WI = 0x17;
            __SetWireInValue__(adrs_MSPI_CON_WI, data_MSPI_CON_WI);

            //## set spi enable signals : {enable_CS_group_16b, enable_CS_bits_16b}
            uint data_MSPI_EN_CS_WI = ((enable_CS_group_16b & 0x0007) <<16 ) + (enable_CS_bits_16b & 0x1FFF);
            __SetWireInValue__(adrs_MSPI_EN_CS_WI, data_MSPI_EN_CS_WI);

            //## trigger frame 
            __ActivateTriggerIn__(adrs_MSPI_TI, loc_bit_MSPI_frame_trig);
            uint cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs_MSPI_TO, mask_MSPI_frame_done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //$$Console.WriteLine(string.Format("> frame done !! @ cnt_loop={0}", cnt_loop)); // test
                    break;
                }
            }

            //## read miso data
            uint data_B;
            data_B = __GetWireOutValue__(adrs_MSPI_FLAG_WO);
            data_B = data_B & 0xFFFF; // mask on low 16 bits
            return data_B;
        }

        private void __act_trig_w_check(
            int  loc_bit__trig = 2,
            uint    mask__done = (0x1<<2),
            uint adrs__TI = 0x42,
            uint adrs__TO = 0x62
        ) {
            __ActivateTriggerIn__(adrs__TI, loc_bit__trig);
            uint cnt_loop = 0;
            bool done_trig = false;
            while (true) {
                done_trig = __IsTriggered__(adrs__TO, mask__done);
                cnt_loop++;
                if (done_trig) {
                    // print
                    //$$Console.WriteLine(string.Format("> frame done !! @ cnt_loop={0}", cnt_loop)); // test
                    break;
                }
            }
        }

        public uint _test__send_spi_frame_fifo(
            ref s32[] mosi_in_buf_s32,
            ref s32[] miso_out_buf_s32,
            s32  MAX_DEPTH_FIFO_32B = 256,
            uint enable_CS_bits_16b = 0x00001FFF,
            uint enable_CS_group_16b = 0x0007,
            uint adrs_MSPI_CON_WI = 0x17,
            uint adrs_MSPI_FLAG_WO = 0x24,
            uint adrs_MSPI_TI = 0x42,
            uint adrs_MSPI_TO = 0x62,
            uint adrs_MSPI_PI = 0x92,
            uint adrs_MSPI_PO = 0xB2,
            uint adrs_MSPI_EN_CS_WI = 0x16,
            int  loc_bit_MSPI_reset_fifo_trig = 3,
            uint    mask_MSPI_reset_fifo_done = (0x1<<3),
            int  loc_bit_MSPI_frame_fifo_trig = 4,
            uint    mask_MSPI_frame_fifo_done = (0x1<<4)
        ) {
            
            // convert s32[] to byte[]
            byte[] mosi_in_buf_byte  = new byte[mosi_in_buf_s32.Length*sizeof(s32)];
            byte[] miso_out_buf_byte = new byte[mosi_in_buf_s32.Length*sizeof(s32)];
            Buffer.BlockCopy(mosi_in_buf_s32, 0, mosi_in_buf_byte, 0, mosi_in_buf_byte.Length); // length of bytes

            _test__send_spi_frame_fifo(
                ref mosi_in_buf_byte,
                ref miso_out_buf_byte,
                MAX_DEPTH_FIFO_32B,
                enable_CS_bits_16b,
                enable_CS_group_16b,
                adrs_MSPI_CON_WI,
                adrs_MSPI_FLAG_WO,
                adrs_MSPI_TI,
                adrs_MSPI_TO,
                adrs_MSPI_PI,
                adrs_MSPI_PO,
                adrs_MSPI_EN_CS_WI,
                loc_bit_MSPI_reset_fifo_trig,
                mask_MSPI_reset_fifo_done,
                loc_bit_MSPI_frame_fifo_trig,
                mask_MSPI_frame_fifo_done
            );

            // convert byte[] to s32[]
            Buffer.BlockCopy(miso_out_buf_byte, 0, miso_out_buf_s32, 0, miso_out_buf_byte.Length); // length of bytes

            return (uint)miso_out_buf_byte.Length;
        }

        public uint _test__send_spi_frame_fifo(
            ref byte[] mosi_in_buf_byte,
            ref byte[] miso_out_buf_byte,
            s32  MAX_DEPTH_FIFO_32B = 256,
            uint enable_CS_bits_16b = 0x00001FFF,
            uint enable_CS_group_16b = 0x0007,
            uint adrs_MSPI_CON_WI = 0x17,
            uint adrs_MSPI_FLAG_WO = 0x24,
            uint adrs_MSPI_TI = 0x42,
            uint adrs_MSPI_TO = 0x62,
            uint adrs_MSPI_PI = 0x92,
            uint adrs_MSPI_PO = 0xB2,
            uint adrs_MSPI_EN_CS_WI = 0x16,
            int  loc_bit_MSPI_reset_fifo_trig = 3,
            uint    mask_MSPI_reset_fifo_done = (0x1<<3),
            int  loc_bit_MSPI_frame_fifo_trig = 4,
            uint    mask_MSPI_frame_fifo_done = (0x1<<4)
        ) {

            //// test buffer
            //s32[] datain_buf_s32  = {0, 1, -1, 100, -100};
            //s32[] datain_buf_s32    = {0x43820000, 0x43800000, 0x43820000, 0x43800000}; // mosi test data
            //s32[] dataout_buf_s32   = new s32[datain_buf_s32.Length];
            //byte[] datain_buf_byte  = new byte[datain_buf_s32.Length*sizeof(s32)];
            //byte[] dataout_buf_byte = new byte[datain_buf_s32.Length*sizeof(s32)];
            //Buffer.BlockCopy(datain_buf_s32, 0, datain_buf_byte, 0, datain_buf_byte.Length); // length of bytes
            //Buffer.BlockCopy(datain_buf_byte, 0, dataout_buf_byte, 0, datain_buf_byte.Length); // length of bytes
            //Buffer.BlockCopy(dataout_buf_byte, 0, dataout_buf_s32, 0, datain_buf_byte.Length); // length of bytes
            // compared if dataout_buf_s32 == datain_buf_s32

            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_EN_CS_WI | TBD        | wire_in_16 | Control MSPI CS enable.    | bit[12: 0]=MSPI_EN_CS[12: 0]   |
            // |       |               |            |            |                            | bit[16]   =M0 group enable     |
            // |       |               |            |            |                            | bit[17]   =M1 group enable     |
            // |       |               |            |            |                            | bit[18]   =M2 group enable     |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_CON_WI   | TBD        | wire_in_17 | Control MSPI MOSI frame.   | bit[31:26]=frame_data_C[ 5:0]  |
            // |       |               |            |            |                            | bit[25:16]=frame_data_A[ 9:0]  |
            // |       |               |            |            |                            | bit[15: 0]=frame_data_D[15:0]  |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_FLAG_WO  | TBD        | wireout_24 | Return MSPI MISO frame.    | bit[31:16]=frame_data_E[15:0]  |
            // |       |               |            |            |                            | bit[15: 0]=frame_data_B[15:0]  |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_TI       | TBD        | trig_in_42 | Trigger functions.         | bit[0]=trigger_reset           |
            // |       |               |            |            |                            | bit[1]=trigger_init            |
            // |       |               |            |            |                            | bit[2]=trigger_frame           |
            // |       |               |            |            |                            | bit[3]=trigger_reset_fifo      |
            // |       |               |            |            |                            | bit[4]=trigger_frame_fifo      |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_TO       | TBD        | trigout_62 | Check if trigger is done.  | bit[0]=done_reset              |
            // |       |               |            |            |                            | bit[1]=done_init               |
            // |       |               |            |            |                            | bit[2]=done_frame              |
            // |       |               |            |            |                            | bit[3]=done_reset_fifo         |
            // |       |               |            |            |                            | bit[4]=done_frame_fifo         |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_PI       | TBD__      | pipe_in_92 | Send mosi data into pipe.  | bit[31:0]=frame_mosi[31:0]     |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | MSPI  | MSPI_PO       | TBD__      | pipeout_B2 | Read miso data from pipe.  | bit[31:0]=frame_miso[31:0]     |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+

            //// test -- send frames with fifo -- case of (max fifo size >= mosi data size)
            // 0. select slot and spi channel
            // 1. trigger reset fifo
            // 2. send MOSI data into fifo 
            // 3. trigger frame fifo
            // 4. read MISO data from fifo

            //// test -- send frames with fifo -- case of (max fifo size < mosi data size)
            // 0. select slot and spi channel
            // 1. check data size --> goto 2. or 3.
            // 2. single trigger case
            // 2-1. trigger reset fifo
            // 2-2. send MOSI data into fifo 
            // 2-3. trigger frame fifo
            // 2-4. read MISO data from fifo
            // 2-5. done
            // 3. multiple trigger case
            // 3-1. trigger reset fifo
            // 3-2. divide MOSI subblocks
            // 3-3. send MOSI subblock into fifo
            // 3-4. trigger frame fifo
            // 3-5. read MISO subblock from fifo
            // 3-6. merge MISO subblocks 
            // 3-7. repeat with residual subblocks to 3-2.
            // 3-8. done

            // 0. select slot and spi channel
            //## set spi enable signals : {enable_CS_group_16b, enable_CS_bits_16b}
            uint data_MSPI_EN_CS_WI = ((enable_CS_group_16b & 0x0007) <<16 ) + (enable_CS_bits_16b & 0x1FFF);
            __SetWireInValue__(adrs_MSPI_EN_CS_WI, data_MSPI_EN_CS_WI);

            // 1. check data size --> goto 2. or 3.
            //    check if the number of mosi data is larger than max fifo depth
            //s32 MAX_DEPTH_FIFO_32B = 500; // actually 512 max
            s32 len__mosi_data; // length of mosi data with (16 bit control) + (16 bit data)
            len__mosi_data = mosi_in_buf_byte.Length/4; // assume mosi_in_buf_byte.Length is multiple of 4.
            if (len__mosi_data <= MAX_DEPTH_FIFO_32B) {
                //// single fifo trigger
                // 2. single trigger case

                // 2-1. trigger reset fifo
                __act_trig_w_check(loc_bit_MSPI_reset_fifo_trig, mask_MSPI_reset_fifo_done, adrs_MSPI_TI, adrs_MSPI_TO);

                // 2-2. send MOSI data into fifo -- must consider max fifo depth on pipe-in
                __WriteToPipeIn__(adrs_MSPI_PI, ref mosi_in_buf_byte); 

                // 2-3. trigger frame fifo
                __act_trig_w_check(loc_bit_MSPI_frame_fifo_trig, mask_MSPI_frame_fifo_done, adrs_MSPI_TI, adrs_MSPI_TO);

                // 2-4. read MISO data from fifo -- must consider max fifo depth on pipe-out
                __ReadFromPipeOut__(adrs_MSPI_PO, ref miso_out_buf_byte); 

                // 2-5. done

            }
            else {
                //// divide and trigger subblocks
                // 3. multiple trigger case

                // 3-1. trigger reset fifo
                __act_trig_w_check(loc_bit_MSPI_reset_fifo_trig, mask_MSPI_reset_fifo_done, adrs_MSPI_TI, adrs_MSPI_TO);

                byte[] sub_mosi_in_buf_byte;
                byte[] sub_miso_out_buf_byte;
                s32 residual_len__mosi_data;
                s32 len__buf_byte;
                s32 idx__mosi_in_buf_byte;

                idx__mosi_in_buf_byte = 0;
                while(true) {

                    // 3-2. divide MOSI subblocks
                    // use MAX_DEPTH_FIFO_32B and len__mosi_data
                    if (len__mosi_data==0) break; // all sent
                    if (len__mosi_data <= MAX_DEPTH_FIFO_32B) { // last one
                        residual_len__mosi_data = len__mosi_data;
                    }
                    else {
                        residual_len__mosi_data = MAX_DEPTH_FIFO_32B;
                    }
                    len__mosi_data = len__mosi_data - residual_len__mosi_data; // update len
                    len__buf_byte = residual_len__mosi_data*sizeof(s32);
                    sub_mosi_in_buf_byte  = new byte[len__buf_byte];
                    Buffer.BlockCopy(mosi_in_buf_byte, idx__mosi_in_buf_byte, sub_mosi_in_buf_byte, 0, len__buf_byte); // length of bytes

                    // 3-3. send MOSI subblock into fifo
                    __WriteToPipeIn__(adrs_MSPI_PI, ref sub_mosi_in_buf_byte); 

                    // 3-4. trigger frame fifo
                    __act_trig_w_check(loc_bit_MSPI_frame_fifo_trig, mask_MSPI_frame_fifo_done, adrs_MSPI_TI, adrs_MSPI_TO);

                    // 3-5. read MISO subblock from fifo
                    sub_miso_out_buf_byte = new byte[len__buf_byte];
                    __ReadFromPipeOut__(adrs_MSPI_PO, ref sub_miso_out_buf_byte); 

                    // 3-6. merge MISO subblocks 
                    Buffer.BlockCopy(sub_miso_out_buf_byte, 0, miso_out_buf_byte, idx__mosi_in_buf_byte, len__buf_byte); // length of bytes
                    idx__mosi_in_buf_byte += len__buf_byte; // update to next mosi and misolocation
                    

                    // 3-7. repeat with residual subblocks to 3-2.
                }

                // 3-8. done
            }

            // done


            return (uint)miso_out_buf_byte.Length;
        }

        //// slot information on spi channal

        //sel_loc_groups = 0x0001; // M0 group
        //sel_loc_groups = 0x0002; // M1 group
        //sel_loc_groups = 0x0004; // M2 group
        private uint [] options_sel_loc_groups = {0x0001, 0x0002, 0x0004}; //

        // slot index 0 ~ 12
        private bool [,] slot_is_occupied = {{false, false, false, false, false, false, false, false, false, false,  false, false, false},
                                             {false, false, false, false, false, false, false, false, false, false,  false, false, false},
                                             {false, false, false, false, false, false, false, false, false, false,  false, false, false}};
        // FPGA image id
        private uint [,] val_FID_arr  = {{0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0},
                                         {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0},
                                         {0, 0, 0, 0, 0,  0, 0, 0, 0, 0,  0, 0, 0}};

        public void _test__scan_slots__spi_emul() {
            uint data_C = 0x10  ; // for read // 6 bits
            uint data_A = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
            uint data_D = 0x0000; // for reading (XXXX) // 16bits
            uint data_B;
            uint sel_loc_slots;
            uint sel_loc_groups;

            //// send frames to all slots on all spi groups ...
            //sel_loc_slots  = 0x01FF;
            //sel_loc_groups = 0x0007;
            //data_A = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
            //data_B = dev_eps._test__send_spi_frame(data_C, data_A, data_D, sel_loc_slots, sel_loc_groups);
            //Console.WriteLine(string.Format(">>>------"));
            //Console.WriteLine(string.Format(">>> {0} = 0x{1,3:X3}", "data_A" , data_A));
            //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_B" , data_B));
            //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_slots " , sel_loc_slots));
            //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_groups" , sel_loc_groups));


            //// send frames to slot CSn
            //sel_loc_groups = 0x0001; // M0 group
            //sel_loc_groups = 0x0002; // M1 group
            //sel_loc_groups = 0x0004; // M2 group

            for(int jj=0;jj<3;jj++) {
                sel_loc_groups = options_sel_loc_groups[jj];
                //
                for (int ii=0;ii<13;ii++) {
                    sel_loc_slots = (uint)(0x0000_0001 << ii);
                    data_A = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
                    data_B = _test__send_spi_frame(data_C, data_A, data_D, sel_loc_slots, sel_loc_groups);
                    //Console.WriteLine(string.Format(">>>------"));
                    //Console.WriteLine(string.Format(">>> {0} = 0x{1,3:X3}", "data_A" , data_A));
                    //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_B" , data_B));
                    //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_slots " , sel_loc_slots));
                    //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_groups" , sel_loc_groups));
                    //
                    if (data_B==0xCC55) {
                        //Console.WriteLine(string.Format(">>>------"));
                        //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_slots " , sel_loc_slots));
                        //Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_groups" , sel_loc_groups));
                        //Console.WriteLine(string.Format(">>> A board is found in slot."));
                        slot_is_occupied[jj,ii] = true;
                        // read FID
                        uint FID_lo = _test__send_spi_frame(data_C, 0x080, 0x0000, sel_loc_slots, sel_loc_groups);
                        uint FID_hi = _test__send_spi_frame(data_C, 0x082, 0x0000, sel_loc_slots, sel_loc_groups);
                        uint FID = (FID_hi<<16) | FID_lo;
                        val_FID_arr[jj,ii] = FID;
                    }
                    //
                }
            }
            return;
        }

        public string _test__report_slots__spi_emul() {
            uint sel_loc_slots;
            uint sel_loc_groups;
            string ret = "";
            string tmp;

            // print out slot info 


            tmp = string.Format("+----------------+------------+---------------+------------+");
            ret += tmp + "\n";
            //Console.WriteLine(tmp);

            tmp = string.Format("| sel_loc_groups | slot index | sel_loc_slots | FID        |");
            ret += tmp + "\n";
            //Console.WriteLine(tmp);

            tmp = string.Format("+================+============+===============+============+");
            ret += tmp + "\n";
            //Console.WriteLine(tmp);

            for(int jj=0;jj<3;jj++) {
                sel_loc_groups = options_sel_loc_groups[jj];
                //
                for (int ii=0;ii<13;ii++) {
                    if (slot_is_occupied[jj,ii]==false)
                        continue;
                    sel_loc_slots = (uint)(0x0000_0001 << ii);
                    //
                    tmp = string.Format("|         0x{0:X4} |         {1:d2} |        0x{2:X4} | 0x{3:X8} |", 
                        sel_loc_groups, ii, sel_loc_slots, val_FID_arr[jj,ii]);
                    ret += tmp + "\n";
                    //Console.WriteLine(tmp);
                    //
                }
            }

            tmp = string.Format("+----------------+------------+---------------+------------+");
            ret += tmp + "\n";
            //Console.WriteLine(tmp);

            return ret;
        }


        // test var
        private int __test_int = 0;

        // test function
        public new static string _test() {
            string ret = SCPI_base._test() + ":_class__EPS_Dev_";
            return ret;
        }
        public static int __test_eps_dev() {
            Console.WriteLine(">>>>>> test: __test_eps_dev");

            // test member
            EPS_Dev dev_eps = new EPS_Dev();
            dev_eps.__test_int = dev_eps.__test_int - 1;

            // test EPS
            dev_eps.my_open(__test__.Program.test_host_ip); 
            Console.WriteLine(dev_eps.get_IDN());
            Console.WriteLine(dev_eps.eps_enable());

            // test start
            //
            Console.WriteLine((float)dev_eps.get_FPGA_TMP_mC()/1000);
            //
            // endpoint access test : WI, WO, TI, TO
            Console.WriteLine((float)dev_eps.GetWireOutValue(0x3A)/1000); // see temperature in fpga
            dev_eps.SetWireInValue(0x16, 0xFA1275DA);
            Console.WriteLine(dev_eps.GetWireOutValue(0x16).ToString("X8")); 
            //
            // ActivateTriggerIn(self, adrs, loc_bit)
            // UpdateTriggerOuts()
            // IsTriggered (self, adrs, mask)
            // GetTriggerOutVector()
            //
            // more endpoint access test : PI, PO
            // scpi_comm_resp_numb_ss
            //dev_eps.scpi_comm_resp_numb_ss(cmd_str);

            //// test fifo : pipein at 0x8A; pipeout at 0xAA.
            // byte[] datain_bytearray;
            // datain_bytearray = new byte[] { 
            //     (byte)0x33, (byte)0x34, (byte)0x35, (byte)0x36,
            //     (byte)0x03, (byte)0x04, (byte)0x05, (byte)0x06,
            //     (byte)0xFF, (byte)0x80, (byte)0xCA, (byte)0x92,
            //     (byte)0x00, (byte)0x01, (byte)0x02, (byte)0x03
            //     };
            // Console.WriteLine(dev_eps.WriteToPipeIn(0x8A, ref datain_bytearray));
            ////
            // byte[] dataout_bytearray = new byte[16];
            // Console.WriteLine(dev_eps.ReadFromPipeOut(0xAA, ref dataout_bytearray));
            // // compare
            // Console.WriteLine(BitConverter.ToString(datain_bytearray));
            // Console.WriteLine(BitConverter.ToString(dataout_bytearray));
            // bool comp = datain_bytearray.SequenceEqual(dataout_bytearray);
            // if (comp ==  false) {
            //     Console.WriteLine(comp);
            // }
            

            // MSPI test : 
            //  _test__reset_spi_emul
            //  _test__init__spi_emul
            //  _test__send_spi_frame
            //
            // reset spi emulation
            dev_eps._test__reset_spi_emul();
            // init  spi emulation
            dev_eps._test__init__spi_emul();

            //// test send frame //{

            // frame data
            uint data_C = 0x10  ; // for read // 6 bits
            uint data_A = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
            uint data_D = 0x0000; // for reading (XXXX) // 16bits
            uint data_B;
            uint sel_loc_slots;
            uint sel_loc_groups;
            Console.WriteLine(string.Format(">>> {0} = 0x{1,2:X2}", "data_C" , data_C));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_D" , data_D));

            // send frames to no slots
            sel_loc_slots  = 0x0000;
            sel_loc_groups = 0x0000;
            data_A        = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
            data_B        = dev_eps._test__send_spi_frame(data_C, data_A, data_D, sel_loc_slots, sel_loc_groups);
            Console.WriteLine(string.Format(">>>------"));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,3:X3}", "data_A" , data_A));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_B" , data_B));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_slots " , sel_loc_slots));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "sel_loc_groups" , sel_loc_groups));

            //}

            //// test send frame with fifo //{

            s32[] mosi_in_buf_s32  = {0x43820000, 0x43800000, 0x43820000, 0x43800000}; // mosi test data
            s32[] miso_out_buf_s32 = new s32[mosi_in_buf_s32.Length];
            dev_eps._test__send_spi_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32, 256, sel_loc_slots, sel_loc_groups);
            // check if miso_out_buf_s32 == {...33AA, ...CC55, ...33AA, ...CC55}
            Console.WriteLine("mosi into fifo = " + string.Join(", ", Array.ConvertAll(mosi_in_buf_s32,  x => x.ToString("X8")) )); 
            Console.WriteLine("miso from fifo = " + string.Join(", ", Array.ConvertAll(miso_out_buf_s32, x => x.ToString("X8")) ));
            
            // byte array direct
            byte[] mosi_in_buf_byte  = new byte[mosi_in_buf_s32.Length*sizeof(s32)];
            byte[] miso_out_buf_byte = new byte[mosi_in_buf_byte.Length];
            Buffer.BlockCopy(mosi_in_buf_s32, 0, mosi_in_buf_byte, 0, mosi_in_buf_byte.Length); // length of bytes
            dev_eps._test__send_spi_frame_fifo(ref mosi_in_buf_byte, ref miso_out_buf_byte, 256, sel_loc_slots, sel_loc_groups);
            // check if miso_out_buf_s32 == {...33AA, ...CC55, ...33AA, ...CC55}
            Console.WriteLine("mosi into fifo in bytes = " + string.Join(", ", Array.ConvertAll(mosi_in_buf_byte,  x => x.ToString("X2")) )); 
            Console.WriteLine("miso from fifo in bytes = " + string.Join(", ", Array.ConvertAll(miso_out_buf_byte, x => x.ToString("X2")) ));

            //}


            //// scan slots on spi bus and update info
            dev_eps._test__scan_slots__spi_emul();
            Console.WriteLine(dev_eps._test__report_slots__spi_emul());

            // reset spi emulation
            dev_eps._test__reset_spi_emul();

            // test finish
            Console.WriteLine(dev_eps.eps_disable());
            dev_eps.scpi_close();

            return dev_eps.__test_int;
        }
        
    }

    public class SPI_EMUL : EPS_Dev
    {
        //## renew eps command access by spi emulation

        private bool IsInit = false;

        public uint SPI_EMUL__reset() {
            IsInit = false;
            return _test__reset_spi_emul();
        }

        public uint SPI_EMUL__init() {
            IsInit = true;
            return _test__init__spi_emul();
        }

        public bool SPI_EMUL__IsInit() {
            return IsInit;
        }

        // renew eps_enable
        public new string eps_enable() {
            string ret;
            ret = base.eps_enable();
            //
            SPI_EMUL__init();
            //
            return ret;
        }

        public new string eps_disable() {
            string ret;
            //
            SPI_EMUL__reset();
            //
            ret = base.eps_disable();
            return ret;
        }

        private bool m_use_loc_slot = false;
        private uint m_sel_loc_slots = 0x1FFF;
        private uint m_sel_loc_groups = 0x0007;

        public bool SPI_EMUL__get__use_loc_slot() {
            return m_use_loc_slot;
        }
        public uint SPI_EMUL__get__loc_group() {
            return m_sel_loc_groups;
        }
        public uint SPI_EMUL__get__loc_slot() {
            return m_sel_loc_slots;
        }

        public bool SPI_EMUL__set__use_loc_slot(bool val) {
            m_use_loc_slot = val;
            return m_use_loc_slot;
        }
        public uint SPI_EMUL__set__loc_group(uint val) {
            m_sel_loc_groups = val;
            return SPI_EMUL__get__loc_group();
        }
        public uint SPI_EMUL__set__loc_slot(uint val) {
            m_sel_loc_slots = val;
            return SPI_EMUL__get__loc_slot();
        }

        private uint SPI_EMUL__send_frame(uint data_C, uint data_A, uint data_D, uint sel_loc_slots = 0x1FFF, uint sel_loc_groups = 0x0007) {
            u32 ret;
            if (m_use_loc_slot) 
                ret = _test__send_spi_frame(data_C, data_A, data_D, m_sel_loc_slots, m_sel_loc_groups);
            else 
                ret = _test__send_spi_frame(data_C, data_A, data_D, sel_loc_slots, sel_loc_groups);
            return ret;
        }

        //// use _test__send_spi_frame_fifo
        //       ref s32[] mosi_in_buf_s32, ref s32[] miso_out_buf_s32
        private uint SPI_EMUL__send_frame_fifo(ref s32[] mosi_in_buf_s32, ref s32[] miso_out_buf_s32, s32 MAX_DEPTH_FIFO_32B = 256, uint sel_loc_slots = 0x1FFF, uint sel_loc_groups = 0x0007) {
            u32 ret;
            if (m_use_loc_slot) 
                ret = _test__send_spi_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32, MAX_DEPTH_FIFO_32B, m_sel_loc_slots, m_sel_loc_groups);
            else 
                ret = _test__send_spi_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32, MAX_DEPTH_FIFO_32B, sel_loc_slots, sel_loc_groups);
            return ret;
        }

        private uint SPI_EMUL__send_frame_fifo(ref byte[] mosi_in_buf_byte, ref byte[] miso_out_buf_byte, s32 MAX_DEPTH_FIFO_32B = 256, uint sel_loc_slots = 0x1FFF, uint sel_loc_groups = 0x0007) {
            u32 ret;
            if (m_use_loc_slot) 
                ret = _test__send_spi_frame_fifo(ref mosi_in_buf_byte, ref miso_out_buf_byte, MAX_DEPTH_FIFO_32B, m_sel_loc_slots, m_sel_loc_groups);
            else 
                ret = _test__send_spi_frame_fifo(ref mosi_in_buf_byte, ref miso_out_buf_byte, MAX_DEPTH_FIFO_32B, sel_loc_slots, sel_loc_groups);
            return ret;
        }

        private uint _read_spi_frame_32b_mask_check_(uint adrs, uint mask = 0xFFFFFFFF) {
            u32 data_C = 0x10; // read
            u32 data_A = adrs<<2;
            u32 data_D = 0x0000;

            // // hi first 
            // u32 data_B_hi = 0;
            // if ((mask & 0xFFFF0000) != 0) {
            //     data_B_hi = SPI_EMUL__send_frame(data_C, data_A+2, data_D);
            // }

            // lo first
            u32 data_B_lo = 0;
            if ((mask & 0x0000FFFF) != 0) {
                data_B_lo = SPI_EMUL__send_frame(data_C, data_A  , data_D);
            }

            u32 data_B_hi = 0;
            if ((mask & 0xFFFF0000) != 0) {
                data_B_hi = SPI_EMUL__send_frame(data_C, data_A+2, data_D);
            }
            
            u32 data_B = ( (data_B_hi << 16) + data_B_lo ) & mask; // mask off
            return data_B;
        }

        public new  uint GetWireOutValue(uint adrs, uint mask = 0xFFFFFFFF) {
            return _read_spi_frame_32b_mask_check_(adrs, mask);
        }

        private uint _send_spi_frame_32b_mask_check_(uint adrs, uint data, uint mask = 0xFFFFFFFF) {
            u32 data_C_rd = 0x10; // read
            u32 data_C_wr = 0x00; // write
            u32 data_A_lo =  adrs<<2;
            u32 data_A_hi = (adrs<<2) + 2;
            u32 data_D_lo = 0x0000;
            u32 data_D_hi = 0x0000;
            u32 data_B_lo = 0;
            u32 data_B_hi = 0;

            // addres low side 
            if ((mask & 0x0000FFFF) != 0) {
                if ((mask & 0x0000FFFF) != 0xFFFF) { // need to read data first to mask off
                    data_B_lo = SPI_EMUL__send_frame(data_C_rd, data_A_lo  , data_D_lo);
                    // mask off: 
                    //  data mask  new
                    //  0    0     0
                    //  0    1     0
                    //  1    0     1
                    //  1    1     0
                    data_B_lo = data_B_lo & ~(mask & 0x0000FFFF) ; // previoud data with mask off
                }
                data_D_lo = (data & mask) & 0x0000FFFF; // new data with mask off
                data_D_lo = data_D_lo | data_B_lo;      // merge data
                data_B_lo = SPI_EMUL__send_frame(data_C_wr, data_A_lo  , data_D_lo);
            }

            // addres high side 
            if ((mask & 0xFFFF0000) != 0) {
                if ((mask & 0xFFFF0000) != 0xFFFF0000) { // need to read data first to mask off
                    data_B_hi = SPI_EMUL__send_frame(data_C_rd, data_A_hi  , data_D_hi);
                    // mask off: 
                    //  data mask  new
                    //  0    0     0
                    //  0    1     0
                    //  1    0     1
                    //  1    1     0
                    data_B_hi = data_B_hi & ~( (mask>>16) & 0x0000FFFF) ; // previoud data with mask off
                }
                data_D_hi = ((data & mask)>>16) & 0x0000FFFF; // new data with mask off
                data_D_hi = data_D_hi | data_B_hi;      // merge data
                data_B_hi = SPI_EMUL__send_frame(data_C_wr, data_A_hi  , data_D_hi);
            }

            uint data_B = (data_B_hi << 16) | data_B_lo; // merge
            return data_B;
        }



        public new void SetWireInValue(uint adrs, uint data, uint mask = 0xFFFFFFFF) {
            _send_spi_frame_32b_mask_check_(adrs, data, mask);
        }

        public new  void ActivateTriggerIn(uint adrs, int loc_bit) {
            u32 mask = (u32)(0x00000001 << loc_bit);
            u32 data = mask;
            _send_spi_frame_32b_mask_check_(adrs, data, mask);
        }

        public new  bool IsTriggered(uint adrs, uint mask) {
            bool ret = false;
            u32 data_trig_done = _read_spi_frame_32b_mask_check_(adrs, mask);
            if (data_trig_done != 0)
                ret = true;
            return ret;
        }

        public new  uint GetTriggerOutVector(uint adrs, uint mask = 0xFFFFFFFF) {
            return _read_spi_frame_32b_mask_check_(adrs, mask);
        }

        //$$ note SSPI EP pipe operation is based on 16-bit access.
        //$$ trigger signals for next data are synchrinized with 4n+0 addresses.
        //$$ write seq : 4n+2 adrs --> 4n+0 adrs.
        //$$ read  seq : 4n+2 adrs --> 4n+0 adrs.

        // may use SPI_EMUL__send_frame_fifo
        //    s32[] mosi_in_buf_s32  = {0x43820000, 0x43800000, 0x43820000, 0x43800000}; // mosi test data
        //    s32[] miso_out_buf_s32 = new s32[mosi_in_buf_s32.Length];
        //    dev_eps._test__send_spi_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32);

        private long __ReadFromPipeOut__(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0) {
            u32 data_C_rd = 0x10; // read
            //u32 data_C_wr = 0x00; // write
            u32 data_A_lo =  adrs<<2;
            u32 data_A_hi = (adrs<<2) + 2;
            u32 data_D_lo = 0x0000;
            u32 data_D_hi = 0x0000;
            u32 data_B_lo = 0;
            u32 data_B_hi = 0;
            u32 data_B    = 0;
            byte[] data_B__bytearray;
            //
            s32 len_bytes = data_bytearray.Length;
            //
            if (dummy_leading_read_pulse !=0 ) {
                SPI_EMUL__send_frame(data_C_rd, data_A_lo, data_D_lo); // dummy reading pulse
            }
            //
            for (s32 idx = 0; idx < len_bytes; idx = idx + 4) {
                data_B_hi = SPI_EMUL__send_frame(data_C_rd, data_A_hi, data_D_hi); // hi first
                data_B_lo = SPI_EMUL__send_frame(data_C_rd, data_A_lo, data_D_lo); // low and reading pulse
                //
                data_B = (data_B_hi<<16) | data_B_lo;
                //
                data_B__bytearray = BitConverter.GetBytes(data_B);
                //
                data_bytearray[idx+0] = data_B__bytearray[0];
                data_bytearray[idx+1] = data_B__bytearray[1];
                data_bytearray[idx+2] = data_B__bytearray[2];
                data_bytearray[idx+3] = data_B__bytearray[3];
            }
            return (long)len_bytes;
        }

        public long ReadFromPipeOut(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0, int use_fifo = 1, s32 MAX_DEPTH_FIFO_32B = 256) {
            long ret;
            if (use_fifo == 0) {
                ret = __ReadFromPipeOut__(adrs, ref data_bytearray, dummy_leading_read_pulse); // send frame without fifo
            } 
            else {
                // setup buffer -- 16 bit data into 32 bit mosi
                s32 len__mosi_data; // length of mosi data with (16 bit control) + (16 bit data)
                len__mosi_data = data_bytearray.Length/2; // assume data_bytearray.Length is multiple of 4.
                s32[] mosi_in_buf_s32  = new s32[len__mosi_data];
                s32[] miso_out_buf_s32 = new s32[len__mosi_data];
                    
                // fill mosi with address -- alternatiing hi and low adrs
                u32 data_C_rd = 0x10; // read
                //u32 data_C_wr = 0x00; // write
                u32 data_A_lo =  adrs<<2;
                u32 data_A_hi = (adrs<<2) + 2;
                for (int ii = 0; ii+1 < mosi_in_buf_s32.Length; ii=ii+2)
                {
                    // note high 16 bit send first // due to fifo reading based on 32 bit low adrs
                    mosi_in_buf_s32[ii]   = ((s32)data_C_rd<<26) | ((s32)data_A_hi<<16); // high adrs + dummy data
                    mosi_in_buf_s32[ii+1] = ((s32)data_C_rd<<26) | ((s32)data_A_lo<<16); // low  adrs + dummy data
                }

                // do something for dummy_leading_read_pulse
                if (dummy_leading_read_pulse !=0 ) {
                    SPI_EMUL__send_frame(data_C_rd, data_A_lo, 0); // dummy reading pulse
                }

                // send mosi and read miso 
                ret = (long)SPI_EMUL__send_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32, MAX_DEPTH_FIFO_32B);

                // convert s32 array into byte array -- must parse 16 bit data from 32 bit miso
                s16[] miso_data_buf_s16 = new s16[miso_out_buf_s32.Length*2];
                for (int ii = 0; ii+1 < miso_out_buf_s32.Length; ii=ii+2)
                {
                    // must swap high  and low address
                    miso_data_buf_s16[ii+1] = (s16)(miso_out_buf_s32[ii  ] & 0xFFFF); // high adrs
                    miso_data_buf_s16[ii  ] = (s16)(miso_out_buf_s32[ii+1] & 0xFFFF); // low  adrs
                }
                Buffer.BlockCopy(miso_data_buf_s16, 0, data_bytearray, 0, data_bytearray.Length); // length of bytes
                //
            }
            return ret;
        }

        private new long __WriteToPipeIn__(uint adrs, ref byte[] data_bytearray) {
            //u32 data_C_rd = 0x10; // read
            u32 data_C_wr = 0x00; // write
            u32 data_A_lo =  adrs<<2;
            u32 data_A_hi = (adrs<<2) + 2;
            u32 data_D_lo = 0x0000;
            u32 data_D_hi = 0x0000;
            u32 data_B_lo = 0;
            u32 data_B_hi = 0;
            //
            s32 len_bytes = data_bytearray.Length;
            //
            for (s32 idx = 0; idx < len_bytes; idx = idx + 4) {
                data_D_hi = (u32)BitConverter.ToUInt16(data_bytearray, idx+2);
                data_D_lo = (u32)BitConverter.ToUInt16(data_bytearray, idx  );
                //
                data_B_hi = SPI_EMUL__send_frame(data_C_wr, data_A_hi, data_D_hi); // hi first
                data_B_lo = SPI_EMUL__send_frame(data_C_wr, data_A_lo, data_D_lo);
            }
            return (long)len_bytes;
        }

        public long WriteToPipeIn(uint adrs, ref byte[] data_bytearray, int use_fifo = 1, s32 MAX_DEPTH_FIFO_32B = 256) {
            long ret;
            if (use_fifo == 0) {
                ret = __WriteToPipeIn__(adrs, ref data_bytearray); // send frame without fifo
            }
            else {
                // setup buffer -- 16 bit data into 32 bit mosi
                s32 len__mosi_data; // length of mosi data with (16 bit control) + (16 bit data)
                len__mosi_data = data_bytearray.Length/2; // assume data_bytearray.Length is multiple of 4.
                s32[] mosi_in_buf_s32  = new s32[len__mosi_data];
                s32[] miso_out_buf_s32 = new s32[len__mosi_data];

                // collect mosi data
                u16[] mosi_data_buf_u16 = new u16[len__mosi_data];
                Buffer.BlockCopy(data_bytearray, 0, mosi_data_buf_u16, 0, data_bytearray.Length); // length of bytes
                    
                // fill mosi with address -- alternatiing hi and low adrs
                //u32 data_C_rd = 0x10; // read
                u32 data_C_wr = 0x00; // write
                u32 data_A_lo =  adrs<<2;
                u32 data_A_hi = (adrs<<2) + 2;
                u32 data_D_lo = 0x0000;
                u32 data_D_hi = 0x0000;
                for (int ii = 0; ii+1 < mosi_in_buf_s32.Length; ii=ii+2)
                {
                    // mosi data : data_bytearray[2*ii],data_bytearray[2*ii+1],data_bytearray[2*ii+2],data_bytearray[2*ii+3]
                    //          or mosi_data_buf_s16[ii], mosi_data_buf_s16[ii+1]
                    data_D_hi = (u32)mosi_data_buf_u16[ii+1];
                    data_D_lo = (u32)mosi_data_buf_u16[ii  ];
                    // note high 16 bit send first // due to fifo reading based on 32 bit low adrs
                    mosi_in_buf_s32[ii]   = ((s32)data_C_wr<<26) | ((s32)data_A_hi<<16) | (s32)data_D_hi; // high adrs + dummy data
                    mosi_in_buf_s32[ii+1] = ((s32)data_C_wr<<26) | ((s32)data_A_lo<<16) | (s32)data_D_lo; // low  adrs + dummy data
                }

                // send mosi and read miso 
                ret = (long)SPI_EMUL__send_frame_fifo(ref mosi_in_buf_s32, ref miso_out_buf_s32, MAX_DEPTH_FIFO_32B);

                // ignore miso 
            }
            return ret;
        }


        // test var
        private int __test_int = 0;

        // test function
        public new static string _test() {
            string ret = EPS_Dev._test() + ":_class__SPI_EMUL_";
            return ret;
        }
        public static int __test_spi_emul() {
            Console.WriteLine(">>>>>> test: __test_spi_emul");

            // test member
            SPI_EMUL dev_spi_emul = new SPI_EMUL();
            dev_spi_emul.__test_int = dev_spi_emul.__test_int - 1;

            
            // open S3100-CPU-BASE with IP address
            dev_spi_emul.my_open(__test__.Program.test_host_ip); // IP address of S3100-CPU-BASE board

            // get IDN string from S3100-CPU-BASE // may check board info // by LAN command
            Console.WriteLine(dev_spi_emul.get_IDN());

            // enable EPS and initialize EPS-SPI ... by LAN command
            Console.WriteLine(dev_spi_emul.eps_enable()); // renew eps_enable ... merged with SPI_EMUL__init

            // may check FPGA die temperature from S3100-CPU-BASE
            Console.WriteLine((float)dev_spi_emul.get_FPGA_TMP_mC()/1000); // by LAN command
            
            // set slot location for EPS-SPI emulation : S3100-XXX board on slot over EPS-SPI emulation
            dev_spi_emul.SPI_EMUL__set__use_loc_slot(true); // use fixed slot location
            dev_spi_emul.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel index
            dev_spi_emul.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot); // for slot index 
            


            //// test start
            
            // MSPI test : 

            // send frame
            uint data_C = 0x10  ; // for read // 6 bits
            uint data_A = 0x380 ; // for address of known pattern  0x_33AA_CC55 // 10 bits
            uint data_D = 0x0000; // for reading (XXXX) // 16bits
            //uint data_B = dev_spi_emul._test__send_spi_frame(data_C, data_A, data_D);
            uint data_B = dev_spi_emul.SPI_EMUL__send_frame(data_C, data_A, data_D);
            Console.WriteLine(string.Format(">>> {0} = 0x{1,2:X2}", "data_C" , data_C));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,3:X3}", "data_A" , data_A));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_D" , data_D));
            Console.WriteLine(string.Format(">>> {0} = 0x{1,4:X4}", "data_B" , data_B));

            // endpoint access test : WI, WO, TI, TO
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x20).ToString("X8")); // see FID
            Console.WriteLine((float)dev_spi_emul.GetWireOutValue(0x3A)/1000); // see temperature in fpga
            
            dev_spi_emul.SetWireInValue(0x16, 0xFA1275DA);
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x16).ToString("X8")); 

            dev_spi_emul.SetWireInValue(0x16, 0xFFFFFFFF, 0x0000FFF0);
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x16).ToString("X8")); 

            dev_spi_emul.SetWireInValue(0x16, 0xFFFFFFFF, 0x0000FFFF);
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x16).ToString("X8")); 

            dev_spi_emul.SetWireInValue(0x16, 0xFFFFFFFF, 0xFFF00000);
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x16).ToString("X8")); 

            dev_spi_emul.SetWireInValue(0x16, 0xFFFFFFFF, 0xFFFF0000);
            Console.WriteLine(dev_spi_emul.GetWireOutValue(0x16).ToString("X8")); 
            
            // more endpoint access test : TI, TO

            dev_spi_emul.ActivateTriggerIn(0x53, 2); // test MEM frame trig
            //dev_spi_emul.Delay(1); // ms // wait for a while
            Console.WriteLine(dev_spi_emul.IsTriggered(0x73, 0x00000004));  // true or not

            dev_spi_emul.ActivateTriggerIn(0x53, 2); // test MEM frame trig
            //dev_spi_emul.Delay(1); // ms // wait for a while
            Console.WriteLine(dev_spi_emul.GetTriggerOutVector(0x73).ToString("X8"));  // true or not

            // more endpoint access test : PI, PO

            //// test fifo : pipein at 0x8A; pipeout at 0xAA. // fifo standard reading mode
            byte[] datain_bytearray;
            datain_bytearray = new byte[] { 
                (byte)0x33, (byte)0x34, (byte)0x35, (byte)0x36,
                (byte)0x03, (byte)0x04, (byte)0x05, (byte)0x06,
                (byte)0xFF, (byte)0x80, (byte)0xCA, (byte)0x92,
                (byte)0x00, (byte)0x01, (byte)0x02, (byte)0x03
                };
            Console.WriteLine(dev_spi_emul.WriteToPipeIn(0x8A, ref datain_bytearray, 1));
            //
            byte[] dataout_bytearray = new byte[16];
            // dummy_leading_read_pulse = 1 for fifo standardi reading mode
            Console.WriteLine(dev_spi_emul.ReadFromPipeOut(0xAA, ref dataout_bytearray, 1, 1)); // with fifo
            //Console.WriteLine(dev_spi_emul.ReadFromPipeOut(0xAA, ref dataout_bytearray, 1, 0)); // no fifo
            // compare
            Console.WriteLine(BitConverter.ToString(datain_bytearray));
            Console.WriteLine(BitConverter.ToString(dataout_bytearray));
            bool comp = datain_bytearray.SequenceEqual(dataout_bytearray);
            if (comp ==  false) {
                Console.WriteLine(comp);
                Console.WriteLine("> Unmated bytearray!");
            } else {
                Console.WriteLine(comp);
                Console.WriteLine("> Matched bytearray!");
            }
            
            // read again
            Console.WriteLine(dev_spi_emul.ReadFromPipeOut(0xAA, ref dataout_bytearray, 1));
            Console.WriteLine(BitConverter.ToString(dataout_bytearray));

            // reset spi emulation
            //dev_spi_emul._test__reset_spi_emul();
            //dev_spi_emul.SPI_EMUL__reset();

            //// test finish
            Console.WriteLine(dev_spi_emul.eps_disable()); // renew eps_disable ... mergerd with SPI_EMUL__reset
            dev_spi_emul.scpi_close();

            return dev_spi_emul.__test_int;
        }
    }


    //// S3100-HVPGU class using SPI_EMUL
    //     * controls IO for S3100-HVPGU and S3100-ADDA 
    public class HVPGU_control_by_eps : SPI_EMUL
    {

        //// EPS address map info ......
        
        // for S3100 common       : TEST, MEM
        // for S3100-ADDA only    : DACX, DACZ, DACn, CLKD, SPIO, ADCH
        // for S3100-CMU-ANL only : RRIV, DET, AMP, STAT, DACQ.
        // for S3100-CMU-SIG only : DACP, EXT, FILT.
        // for S3100-HVPGU only   : HVPGU

        private string EP_ADRS__GROUP_STR         = "_S3100_HVPGU_";

        //private u32   EP_ADRS__SSPI_TEST_WO     = 0xE0;
        private u32   EP_ADRS__SSPI_CON_WI      = 0x02; //$$ new for TEST LAN control
        //private u32   EP_ADRS__SSPI_FLAG_WO     = 0x00;

        private u32   EP_ADRS__FPGA_IMAGE_ID_WO = 0x20;
        private u32   EP_ADRS__XADC_TEMP_WO     = 0x3A;
        //private u32   EP_ADRS__XADC_VOLT_WO     = 0x3B;
        //private u32   EP_ADRS__TIMESTAMP_WO     = 0x22;
        private u32   EP_ADRS__TEST_MON_WO      = 0x23;
        //private u32   EP_ADRS__TEST_CON_WI      = 0x01; // LAN only
        //private u32   EP_ADRS__TEST_LED_WI      = 0x01; // GNDU
        //private u32   EP_ADRS__TEST_LED_TI      = 0x41; // GNDU
        //private u32   EP_ADRS__TEST_OUT_WO      = 0x21; // LAN only
        //private u32   EP_ADRS__TEST_TI          = 0x40; // LAN only
        //private u32   EP_ADRS__TEST_TO          = 0x60; // LAN only
        //private u32   EP_ADRS__TEST_PI          = 0x8A;
        //private u32   EP_ADRS__TEST_PO          = 0xAA;

        //private u32   EP_ADRS__BRD_CON_WI       = 0x03; // LAN only
        //private u32   EP_ADRS__MCS_SETUP_WI     = 0x19; // LAN only
        //private u32   EP_ADRS__MSPI_EN_CS_WI    = 0x16; // LAN only
        //private u32   EP_ADRS__MSPI_CON_WI      = 0x17; // LAN only
        //private u32   EP_ADRS__MSPI_FLAG_WO     = 0x24; // LAN only
        //private u32   EP_ADRS__MSPI_TI          = 0x42; // LAN only
        //private u32   EP_ADRS__MSPI_TO          = 0x62; // LAN only

        // MEM
        private u32   EP_ADRS__MEM_FDAT_WI        = 0x12;
        private u32   EP_ADRS__MEM_WI             = 0x13;
        private u32   EP_ADRS__MEM_TI             = 0x53;
        private u32   EP_ADRS__MEM_TO             = 0x73;
        private u32   EP_ADRS__MEM_PI             = 0x93;
        private u32   EP_ADRS__MEM_PO             = 0xB3;

        // S3100-ADDA
        private u32   EP_ADRS__DACX_WI            = 0x05;
        private u32   EP_ADRS__DACX_WO            = 0x25;
        private u32   EP_ADRS__DACX_TI            = 0x45;
        private u32   EP_ADRS__DACZ_DAT_WI        = 0x08;
        private u32   EP_ADRS__DACZ_DAT_WO        = 0x28;
        private u32   EP_ADRS__DACZ_DAT_TI        = 0x48;
        private u32   EP_ADRS__DAC0_DAT_INC_PI    = 0x86;
        private u32   EP_ADRS__DAC0_DUR_PI        = 0x87;
        private u32   EP_ADRS__DAC1_DAT_INC_PI    = 0x88;
        private u32   EP_ADRS__DAC1_DUR_PI        = 0x89;
        private u32   EP_ADRS__CLKD_WI            = 0x06;
        private u32   EP_ADRS__CLKD_WO            = 0x26;
        private u32   EP_ADRS__CLKD_TI            = 0x46;
        private u32   EP_ADRS__SPIO_WI            = 0x07;
        private u32   EP_ADRS__SPIO_WO            = 0x27;
        private u32   EP_ADRS__SPIO_TI            = 0x47;

        //private u32   EP_ADRS__TRIG_DAT_WI        = 0x09;
        //private u32   EP_ADRS__TRIG_DAT_WO        = 0x29;
        //private u32   EP_ADRS__TRIG_DAT_TI        = 0x49;

        private u32   EP_ADRS__ADCH_WI            = 0x18;
        //private u32   EP_ADRS__ADCH_FREQ_WI       = 0x1C;
        private u32   EP_ADRS__ADCH_UPD_SM_WI     = 0x1D;
        private u32   EP_ADRS__ADCH_SMP_PR_WI     = 0x1E;
        private u32   EP_ADRS__ADCH_DLY_TP_WI     = 0x1F;
        private u32   EP_ADRS__ADCH_WO            = 0x38;
        private u32   EP_ADRS__ADCH_B_FRQ_WO      = 0x39;
        //private u32   EP_ADRS__ADCH_DOUT0_WO      = 0x3C;
        //private u32   EP_ADRS__ADCH_DOUT1_WO      = 0x3D;
        //private u32   EP_ADRS__ADCH_DOUT2_WO      = 0x3E;
        //private u32   EP_ADRS__ADCH_DOUT3_WO      = 0x3F;
        private u32   EP_ADRS__ADCH_TI            = 0x58;
        private u32   EP_ADRS__ADCH_TO            = 0x78;
        private u32   EP_ADRS__ADCH_DOUT0_PO      = 0xBC;
        private u32   EP_ADRS__ADCH_DOUT1_PO      = 0xBD;
        //private u32   EP_ADRS__DFT_TI             = 0x5C; // reserved
        //private u32   EP_ADRS__DFT_COEF_RE_PI     = 0x9C; // reserved
        //private u32   EP_ADRS__DFT_COEF_IM_PI     = 0x9D; // reserved

        // S3100-GNDU // shared with ADDA
        //private u32   EP_ADRS__HRADC_CON_WI       = 0x08; // 0x020
        //private u32   EP_ADRS__HRADC_FLAG_WO      = 0x28; // 0x0A0
        //private u32   EP_ADRS__HRADC_TRIG_TI      = 0x48; // 0x120
        //private u32   EP_ADRS__HRADC_TRIG_TO      = 0x68; // 0x1A0
        //private u32   EP_ADRS__HRADC_DAT_WO       = 0x29; // 0x0A4
        //private u32   EP_ADRS__DIAG_RELAY_WI      = 0x04; // 0x010
        //private u32   EP_ADRS__DIAG_RELAY_TI      = 0x44; // 0x110
        //private u32   EP_ADRS__OUTP_RELAY_WI      = 0x05; // 0x014
        //private u32   EP_ADRS__OUTP_RELAY_TI      = 0x45; // 0x114
        //private u32   EP_ADRS__VM_RANGE_WI        = 0x06; // 0x018
        //private u32   EP_ADRS__VM_RANGE_TI        = 0x46; // 0x118
        //private u32   EP_ADRS__ADC_IN_SEL_WI      = 0x07; // 0x01C
        //private u32   EP_ADRS__ADC_IN_SEL_TI      = 0x47; // 0x11C
        //private u32   EP_ADRS__VDAC_VAL_WI        = 0x09; // 0x024
        //private u32   EP_ADRS__VDAC_CON_TI        = 0x49; // 0x124

        // S3100-CMU
        private u32   EP_ADRS__CMU_WI         = 0x14;
        private u32   EP_ADRS__CMU_WO         = 0x34;

        // S3100-CMU-ANL
        private u32   EP_ADRS__RRIV_WI        = 0x15;
        private u32   EP_ADRS__DET_WI         = 0x16;
        private u32   EP_ADRS__AMP_WI         = 0x17;
        private u32   EP_ADRS__STAT_WO        = 0x37;
        private u32   EP_ADRS__DACQ_WI        = 0x0A;
        private u32   EP_ADRS__DACQ_WO        = 0x2A;
        private u32   EP_ADRS__DACQ_TI        = 0x4A;
        private u32   EP_ADRS__DACQ_TO        = 0x6A;
        private u32   EP_ADRS__DACQ_DIN21_WI  = 0x0B;
        private u32   EP_ADRS__DACQ_DIN43_WI  = 0x0C;
        private u32   EP_ADRS__DACQ_RDB21_WO  = 0x2B;
        private u32   EP_ADRS__DACQ_RDB43_WO  = 0x2C;
        
        // S3100-CMU-SIG
        private u32   EP_ADRS__DACP_WI        = 0x19;
        private u32   EP_ADRS__EXT_WI         = 0x1A;
        private u32   EP_ADRS__FILT_WI        = 0x1B;

        // S3100-HVPGU
        private u32   EP_ADRS__HVPGU_WI       = 0x11;
        private u32   EP_ADRS__HVPGU_WO       = 0x31;


        //// log file info
        private string LOG_DIR_NAME  =  "test_win_app_vscode"; //$$ test_HVPGU__vscode --> test_win_app_vscode

        //// firmware control const
        //private u32   MAX_CNT = 2000000; // max counter when checking done trig_out.
        private u32   MAX_CNT = 20000; // max counter when checking done trig_out.

        //// functions 

        // spio functions

        public void dev_set_tlan_disabled() {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | SSPI  | SSPI_CON_WI   | 0x008      | wire_in_02 | Control slave SPI bus.     | bit[30:28]=reserved            | 
            // |       |               |            |            |                            | bit[25]=miso_one_bit_ahead_en  |
            // |       |               |            |            |                            | bit[24]=loopback_en            |
            // |       |               |            |            |                            | bit[20:16]=miso_timing_control | 
            // |       |               |            |            |                            | bit[ 3]=HW_reset               |
            // |       |               |            |            |                            | bit[ 1]=LAN_EPS_disable        |
            // |       |               |            |            |                            | bit[ 0]=reserved               |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            //           
            SetWireInValue(EP_ADRS__SSPI_CON_WI, 0x0000_0002);
        }

        public void dev_set_tlan_allowed() {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | SSPI  | SSPI_CON_WI   | 0x008      | wire_in_02 | Control slave SPI bus.     | bit[30:28]=reserved            | 
            // |       |               |            |            |                            | bit[25]=miso_one_bit_ahead_en  |
            // |       |               |            |            |                            | bit[24]=loopback_en            |
            // |       |               |            |            |                            | bit[20:16]=miso_timing_control | 
            // |       |               |            |            |                            | bit[ 3]=HW_reset               |
            // |       |               |            |            |                            | bit[ 1]=LAN_EPS_disable        |
            // |       |               |            |            |                            | bit[ 0]=reserved               |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            //           
            SetWireInValue(EP_ADRS__SSPI_CON_WI, 0x0000_0000);
        }

        private u32 spio_send_spi_frame(u32 frame_data) {
            //# write control 
            SetWireInValue(EP_ADRS__SPIO_WI, frame_data);  //# (ep,val,mask)

            //# trig spi frame
            //#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
            ActivateTriggerIn(EP_ADRS__SPIO_TI, 1); //# (ep,bit) 
            
            //# check spi frame done
            //#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            while (true) {
            	flag = GetWireOutValue(EP_ADRS__SPIO_WO);
            	flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }

            //# read received data 
            //#   assign w_SPIO_WO[15:8] = w_SPIO_rd_DA;
            //#   assign w_SPIO_WO[ 7:0] = w_SPIO_rd_DB;
            u32 val_recv = flag & 0x0000FFFF;
            return val_recv;
        }        
        private u32 sp1_reg_read_b16(u32 reg_adrs_b8) {
            u32 val_b16    = 0;
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 1; // read
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return spio_send_spi_frame(framedata);
        }
        private u32 sp1_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 0; // write
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return spio_send_spi_frame(framedata);
        }
        public u32 sp1_ext_init(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0) {
            //...
            u32 dir_read;
            u32 lat_read;
            u32 inp_read;

            // SP1 pin map:
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
            //  SP1_GPA3 = NA                 // i
            //  SP1_GPA2 = PWR_AMP_DAC_ON     // i  // 5/-5V dac amp power enable // shared with pwr_amp
            //  SP1_GPA1 = SW_RL_K2           // o    
            //  SP1_GPA0 = SW_RL_K1           // o    

            //
            //# read IO direction 
            //# check IO direction : (SPA,SPB)
            dir_read = sp1_reg_read_b16(0x00); // 0 for out, 1 for in.

            //# read output Latch
            lat_read = sp1_reg_read_b16(0x14);
            
            //# set IO direction for SP1 PA[2:0] - output // PA[1:0] --> PA[2:0]
            //# set IO direction for SP1 PB[7:5] - output
            //# set IO direction for SP1 PB[3:0] - output
            //sp1_reg_write_b16(0x00, dir_read & 0xFC10);
            sp1_reg_write_b16(0x00, dir_read & 0xF810);
            
            //# set IO for SP1 PB[3:0]
            //u32 val = (lat_read & 0xFFF0) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));
            //u32 val = (lat_read & 0xFCF0) | ( (sw_relay_k2<<9) + (sw_relay_k1<<8) ) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));
            u32 val = (lat_read & 0xFCF0) | ( (pwr_amp<<10) + (sw_relay_k2<<9) + (sw_relay_k1<<8) ) | 
                                            ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0));

            sp1_reg_write_b16(0x12,val);

            // power stability delay 
            Delay(10); // 10ms

            // read IO 
            inp_read = sp1_reg_read_b16(0x12);
            return inp_read & 0xFFFF;
        }
        

        // adc fuctions
        private u32 adc_pwr(u32 val) {

            // read IO 
            u32 inp_read = sp1_reg_read_b16(0x12);

            // read power control status
            u32 val_s0 = (inp_read>>0) & 0x0001;
            u32 val_s1 = (inp_read>>1) & 0x0001;
            u32 val_s2 = (inp_read>>2) & 0x0001;
            u32 val_s3 = (inp_read>>3) & 0x0001;
            u32 val_s8 = (inp_read>>8) & 0x0001;
            u32 val_s9 = (inp_read>>9) & 0x0001;

            // ADC power on 
            if      (val==1) val_s1 = 1;
            else if (val==0) val_s1 = 0;
            //sp1_ext_init(val_s3, val_s2, val_s1, val_s0); // (led, pwr_dac, pwr_adc, pwr_amp)
            inp_read = sp1_ext_init(val_s3, val_s2, val_s1, val_s0, val_s8, val_s9); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

            // power stability delay 1ms or more.
            Delay(10);

            return inp_read;
        }
        public u32 adc_enable(u32 sel_freq_mode_MHz = 210) {
            if (sel_freq_mode_MHz == 210) 
                SetWireInValue(EP_ADRS__ADCH_WI, 0x0000_0001); // enable with 210MHz base freq
            else if (sel_freq_mode_MHz == 189) 
                SetWireInValue(EP_ADRS__ADCH_WI, 0x0000_0101); // enable with 189MHz base freq
            else // default 210MHz
                SetWireInValue(EP_ADRS__ADCH_WI, 0x0000_0001); // enable with 210MHz base freq
            //
            u32 ret = GetWireOutValue(EP_ADRS__ADCH_WO);
            return ret;
        }
        public u32 adc_disable() {
            SetWireInValue(EP_ADRS__ADCH_WI, 0x0000_0000);
            u32 ret = GetWireOutValue(EP_ADRS__ADCH_WO);
            return ret;
        }
        private u32 adc_trig_check(s32 bit_loc) {
            ActivateTriggerIn(EP_ADRS__ADCH_TI, bit_loc); // (u32 adrs, s32 loc_bit)

            //# check done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000; 
            bool flag_done;
            while (true) {
            	flag_done = IsTriggered(EP_ADRS__ADCH_TO, (u32)(0x1<<bit_loc));
            	if (flag_done==true)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }

            u32 ret = GetWireOutValue(EP_ADRS__ADCH_WO);
            return ret;
        }
        private u32 adc_trig_check__wo_trig(s32 bit_loc) {
            //$$ActivateTriggerIn(EP_ADRS__ADCH_TI, bit_loc); // (u32 adrs, s32 loc_bit)

            //# check done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            bool flag_done;
            while (true) {
            	flag_done = IsTriggered(EP_ADRS__ADCH_TO, (u32)(0x1<<bit_loc));
            	if (flag_done==true)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }

            u32 ret = GetWireOutValue(EP_ADRS__ADCH_WO);
            return ret;
        }
        private u32 adc_reset() {
            return adc_trig_check(0);
        }
        public u32 adc_init(s32 len_adc_data = 4, u32 cnt_sampling_period = 21,
            u32 val_tst_fix_pat_en_b1 = 0, u32 val_tst_inc_pat_en_b1 = 0,
            u32 val_tap0a_b5 = 0x0, u32 val_tap0b_b5 = 0x0, u32 val_tap1a_b5 = 0x0, u32 val_tap1b_b5 = 0x0
        ) {
            // ADC parameter setup
            adc_set_update_sample_num(len_adc_data); // set the number of ADC samples
            adc_set_sampling_period(cnt_sampling_period); // 210MHz/21   =  10 Msps
            adc_set_tap_control(val_tap0a_b5,val_tap0b_b5,val_tap1a_b5,val_tap1b_b5,val_tst_fix_pat_en_b1,val_tst_inc_pat_en_b1); // (u32 val_tap0a_b5, u32 val_tap0b_b5, u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 

            // print out base freq and sampling rate
            u32 val = adc_get_base_freq(); // adc base freq check 
            Console.WriteLine(string.Format("{0} = {1} [MHz]", "adc_base_freq    ", (float)val/1000000.0));
            Console.WriteLine(string.Format("{0} = {1,0:0.####} [MHz]", "adc_sampling_freq", (float)val/1000000.0/cnt_sampling_period));

            // trigger init
            return adc_trig_check(1);
        }
        private u32 adc_update() {
            return adc_trig_check(2);
        }
        public u32 adc_update_check() {
            return adc_trig_check__wo_trig(2);
        }
        private u32 adc_test() {
            return adc_trig_check(3);
        }
        public u32 adc_reset_fifo() {
            return adc_trig_check(4);
        }
        private u32 adc_get_base_freq() {
            return GetWireOutValue(EP_ADRS__ADCH_B_FRQ_WO);
        }
        private u32 adc_set_sampling_period(u32 val) {
            // 210MHz/val = x  Msps
            // 210MHz/14  = 15 Msps
            SetWireInValue(EP_ADRS__ADCH_SMP_PR_WI, val);
            return val;
        }
        private s32 adc_set_update_sample_num(s32 val) {
            SetWireInValue(EP_ADRS__ADCH_UPD_SM_WI, (u32)val);
            return val;
        }
        private u32 adc_set_tap_control(u32 val_tap0a_b5, u32 val_tap0b_b5, u32 val_tap1a_b5, u32 val_tap1b_b5,
            u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) {
            
            // note: val_tst_fix_pat_en_b1 for adc fixed test pattern 18-bit 0x330FC
            u32 val = 
                (val_tap1b_b5<<27) | (val_tap1a_b5<<22) | 
                (val_tap0b_b5<<17) | (val_tap0a_b5<<12) | 
                (val_tst_inc_pat_en_b1<<2) | (val_tst_fix_pat_en_b1);
            
            SetWireInValue(EP_ADRS__ADCH_DLY_TP_WI, val);

            return val;
        }
        public u32 adc_get_fifo(u32 ch, s32 num_data, s32[] buf_s32) {
            u32 ret;
            u32 adrs;
            u8[] buf_pipe = new u8[num_data*4]; // *4 for 32-bit pipe 
            
            if (ch==0) {
                adrs = EP_ADRS__ADCH_DOUT0_PO;
            } else if (ch==1) {
                adrs = EP_ADRS__ADCH_DOUT1_PO;
            } else {
                return 0;
            }

            // buf_pipe ... u8 buffer
            ret = (u32)ReadFromPipeOut(adrs, ref buf_pipe); //(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0, int use_fifo = 1)
            //ret = (u32)ReadFromPipeOut(adrs, ref buf_pipe, 0, 0); //(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0, int use_fifo = 1)
            //ret = (u32)ReadFromPipeOut(adrs, ref buf_pipe, 0, 1); //(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0, int use_fifo = 1)

            // collect and copy data : buf => buf_dataout
            s32 ii;
            s32 tmp;
            for (ii=0;ii<num_data;ii++) {
                tmp = BitConverter.ToInt32(buf_pipe, ii*4); // read one pipe data every 4 bytes
                //buf_s32[ii] = (u8) (tmp & 0x000000FF); // 8 bit limit
                buf_s32[ii] = tmp; // adc uses 32 bits ... msb side 18 bits are valid.
            }

            return ret/4; // number of bytes --> number of int
        }
        public void adc_log(char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32, 
                                string buf_time_str="", string buf_dac0_str="", string buf_dac1_str="") {

            // open or create a file
            string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), LOG_DIR_NAME, "log"); //$$ TODO: logfile location in vs code
            string LogFileName = Path.Combine(LogFilePath, new string(log_filename));
            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }

            // write header
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) {
                ws.WriteLine("\"\"\" data log file : import data as CONSTANT \"\"\"");
                ws.WriteLine("# pylint: disable=C0301");
                ws.WriteLine("# pylint: disable=line-too-long");
                ws.WriteLine("# pylint: disable=C0326 ## disable-exactly-one-space");
                ws.WriteLine("## log start"); //$$ add python comment header
            }

            // note adc full scale : +/-4.096V with 2^31-1 ~ -2^31
            float adc_scale = (float)4.096 / ((float)Math.Pow(2,31)-(float)1.0);

            string buf0_s32_str = "";
            string buf1_s32_str = "";
            string buf0_s32_hex_str = "";
            string buf1_s32_hex_str = "";
            string buf0_flt_str = "";
            string buf1_flt_str = "";

            for (s32 i = 0; i < len_data; i++) {
                //
                buf0_s32_str     = buf0_s32_str + string.Format("{0,11:D}, ",buf0_s32[i]);
                buf1_s32_str     = buf1_s32_str + string.Format("{0,11:D}, ",buf1_s32[i]);
                buf0_s32_hex_str = buf0_s32_hex_str + string.Format(" '{0,8:X8}', ",buf0_s32[i]);
                buf1_s32_hex_str = buf1_s32_hex_str + string.Format(" '{0,8:X8}', ",buf1_s32[i]);
                buf0_flt_str     = buf0_flt_str + string.Format("{0,11:F8}, ",(float)buf0_s32[i]*adc_scale);
                buf1_flt_str     = buf1_flt_str + string.Format("{0,11:F8}, ",(float)buf1_s32[i]*adc_scale);
            }

            // write data string on the file
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                ws.WriteLine("TEST_DATA = [0, 1, 2, 3]"); // test
                // command info
                ws.WriteLine("BUF_TIME     = [" + buf_time_str + "]"); // command info
                ws.WriteLine("BUF_DAC0     = [" + buf_dac0_str + "]"); // command info
                ws.WriteLine("BUF_DAC1     = [" + buf_dac1_str + "]"); // command info
                ws.WriteLine(""); // newline
                ws.WriteLine("ADC_BUF0     = [" + buf0_s32_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1     = [" + buf1_s32_str + "]"); // from buf1_s32
                ws.WriteLine("ADC_BUF0_HEX = [" + buf0_s32_hex_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1_HEX = [" + buf1_s32_hex_str + "]"); // from buf1_s32
                ws.WriteLine("ADC_BUF0_FLT = [" + buf0_flt_str + "]"); // from buf0_s32
                ws.WriteLine("ADC_BUF1_FLT = [" + buf1_flt_str + "]"); // from buf1_s32
            }



        }

        // dac functions
        private u32 dac_pwr(u32 val) {

            // read IO 
            u32 inp_read = sp1_reg_read_b16(0x12);

            // read power control status
            u32 val_s0 = (inp_read>>0) & 0x0001;
            u32 val_s1 = (inp_read>>1) & 0x0001;
            u32 val_s2 = (inp_read>>2) & 0x0001;
            u32 val_s3 = (inp_read>>3) & 0x0001;
            u32 val_s8 = (inp_read>>8) & 0x0001;
            u32 val_s9 = (inp_read>>9) & 0x0001;

            // DAC power on 
            if      (val==1) val_s2 = 1;
            else if (val==0) val_s2 = 0;
            //sp1_ext_init(val_s3, val_s2, val_s1, val_s0); // (led, pwr_dac, pwr_adc, pwr_amp)
            inp_read = sp1_ext_init(val_s3, val_s2, val_s1, val_s0, val_s8, val_s9); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

            // power stability delay 1ms or more.
            Delay(10);

            return inp_read;
        }
        public void dac_init(double time_ns__dac_update = 5,
            double DAC_full_scale_current__mA_1 = 25.5,
            double DAC_full_scale_current__mA_2 = 25.5,
            float  DAC_offset_current__mA_1     = (float)0.0,
            float  DAC_offset_current__mA_2     = (float)0.0,
            int    N_pol_sel_1                  = 0,
            int    N_pol_sel_2                  = 0,
            int    Sink_sel_1                   = 0,
            int    Sink_sel_2                   = 0
        ) {
            // setup pgu-clock device
            //$$ note ... hardware support freq: 20MHz, 50MHz, 80MHz, 100MHz, 200MHz(default), 400MHz.
            //pgu__setup_freq(time_ns__dac_update);

            //// calculate parameters
            int pgu_freq_in_100kHz = Convert.ToInt32(1 / (time_ns__dac_update * 1e-9) / 100000);
            u32 val = (u32)pgu_freq_in_100kHz;

            // DACX fpga pll reset
            pgu_dacx_fpga_pll_rst(1, 1, 1);

            // CLKD init
            pgu_clkd_init();

            // CLKD freq setup 
            pgu_clkd_setup(val);

            // DACX init 
            pgu_dacx_init();

            // DACX fpga pll run
            pgu_dacx_fpga_pll_rst(0, 0, 0);
            pgu_dacx_fpga_clk_dis(0, 0);

            // wait for pll stable
            Delay(1); // 1ms

            //$$ DAC device input delay tap calibration 
            if (time_ns__dac_update <= 5) // conduct dac input delay tap check only when update rate >= 200MHz.
                dac__dev_cal_dtap();
            else
                dac__dev_set_dtap((u32)0, (u32)0); // set 0 taps


            //$$ DAC device full-scale current, offset setup
            pgu__setup_gain_offset(1, 
                DAC_full_scale_current__mA_1, DAC_offset_current__mA_1, 
                N_pol_sel_1, Sink_sel_1);
            pgu__setup_gain_offset(2, 
                DAC_full_scale_current__mA_2, DAC_offset_current__mA_2, 
                N_pol_sel_2, Sink_sel_2);


        }

        // clkd ... external clock IC control // to rename
        private u32  pgu_clkd_init() {
            //
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__CLKD_TI, 0);
            ActivateTriggerIn(EP_ADRS__CLKD_TI, 0);
            //
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 24   ;
            u32 flag            ;
            u32 flag_done       ;
            //
            while (true) {
            	flag = GetWireOutValue(EP_ADRS__CLKD_WO);
            	//flag_done = (flag&(1<<bit_loc))>>bit_loc;
                flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }
            //
            return flag_done;
        }
        private u32  pgu_clkd_send_spi_frame(u32 frame_data) {
            //
            // write control 
            SetWireInValue(EP_ADRS__CLKD_WI, frame_data);
            //
            // trig spi frame
            ActivateTriggerIn(EP_ADRS__CLKD_TI, 1);
            //
            // check spi frame done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            
            //$$ note clkd frame done is poorly implemented by checking two levels.
            //$$ must revise this ... to check triggered output...

            // check if done is low // when sclk is slow < 1MHz
            //$$ while (true) {
            //$$ 	//
            //$$ 	flag = GetWireOutValue(EP_ADRS__CLKD_WO);
            //$$ 	flag_done = (flag>>bit_loc) & 0x00000001;
            //$$ 	//
            //$$ 	if (flag_done==0)
            //$$ 		break;
            //$$ 	cnt_done += 1;
            //$$ 	if (cnt_done>=MAX_CNT)
            //$$ 		break;
            //$$ }
            // check if done is high
            while (true) {
            	//
            	flag = GetWireOutValue(EP_ADRS__CLKD_WO);
            	flag_done = (flag>>bit_loc) & 0x00000001;
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
        private u32  pgu_clkd_reg_write_b8(u32 reg_adrs_b10, u32 val_b8) {
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
        private u32  pgu_clkd_reg_read_b8(u32 reg_adrs_b10) {
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
        private u32  pgu_clkd_reg_write_b8_check (u32 reg_adrs_b10, u32 val_b8) {
            u32 tmp;
            u32 retry_count = 0;
            while(true) {
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
        private u32  pgu_clkd_reg_read_b8_check (u32 reg_adrs_b10, u32 val_b8) {
            u32 tmp;
            u32 retry_count = 0;
            while(true) {
            	// read
            	tmp = pgu_clkd_reg_read_b8(reg_adrs_b10); // readback 0x18
            	if (tmp == val_b8) 
            		break;
            	retry_count++;
            }
            return retry_count;
        }
        private u32  pgu_clkd_setup(u32 freq_preset) {
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
        // dacx ... DAC IC control // to rename
        private u32  pgu_dacx_init() { // EP access
            //
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACX_TI, 0);
            ActivateTriggerIn(EP_ADRS__DACX_TI, 0);
            //
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 24   ;
            u32 flag            ;
            u32 flag_done       ;
            //
            while (true) {
            	//flag = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACX_WO, MASK_ALL);
                flag = GetWireOutValue(EP_ADRS__DACX_WO);
            	//flag_done = (flag&(1<<bit_loc))>>bit_loc;
                //flag_done = (flag&(1<<bit_loc))>>bit_loc;
                flag_done = (flag>>bit_loc) & 0x00000001;
            	if (flag_done==1)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }
            //
            return flag_done;
        }
        private u32  pgu_dacx_fpga_pll_rst(u32 clkd_out_rst, u32 dac0_dco_rst, u32 dac1_dco_rst) {
            u32 control_data;
            u32 status_pll;

            // control data
            control_data = (dac1_dco_rst<<30) + (dac0_dco_rst<<29) + (clkd_out_rst<<28);

            // write control 
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, control_data, 0x70000000);
            SetWireInValue(EP_ADRS__DACX_WI, control_data, 0x70000000);

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

            //status_pll = read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__TEST_IO_MON, 0x07000000);
            status_pll = GetWireOutValue(EP_ADRS__TEST_MON_WO, 0x07000000);
            //
            return status_pll;
        }
        private u32  pgu_dacx_fpga_clk_dis(u32 dac0_clk_dis, u32 dac1_clk_dis) {
            u32 ret = 0;
            u32 control_data;

            // control data
            control_data = (dac1_clk_dis<<27) + (dac0_clk_dis<<26);

            // write control 
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACX_WI, control_data, (0x03 << 26));
            SetWireInValue(EP_ADRS__DACX_WI, control_data, (0x03 << 26));

            return ret;
        }
        private u32  pgu_dacx_send_spi_frame(u32 frame_data) { // EP access
            //
            // write control 
            SetWireInValue(EP_ADRS__DACX_WI, frame_data);
            //
            // trig spi frame
            ActivateTriggerIn(EP_ADRS__DACX_TI, 1);
            //
            // check spi frame done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000;
            s32 bit_loc  = 25   ;
            u32 flag;
            u32 flag_done;
            //while True:
            while (true) {
            	//
            	flag = GetWireOutValue(EP_ADRS__DACX_WO);
            	//flag_done = (flag&(1<<bit_loc))>>bit_loc;
                flag_done = (flag>>bit_loc) & 0x00000001;
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
        private u32  pgu_dac0_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
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
        private u32  pgu_dac0_reg_read_b8(u32 reg_adrs_b5) {
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
        private u32  pgu_dac1_reg_write_b8(u32 reg_adrs_b5, u32 val_b8) {
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
        private u32  pgu_dac1_reg_read_b8(u32 reg_adrs_b5) {
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

        // test printf emulation
        private void xil_printf(string fmt) { // for test print
            // remove "\r\n" 
            if (fmt.Substring(fmt.Length-2)=="\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-2);
                fmt = tmp; //
            }
            Console.WriteLine(fmt);
        }
        private void xil_printf(string fmt, s32 val) { // for test print
            // check "%02d \r\n"
            if (fmt.Substring(fmt.Length-7)=="%02d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-7);
                fmt = tmp + string.Format("{0,2:d2} ", val); //
            }
            // check "%d \r\n"
            else if (fmt.Substring(fmt.Length-5)=="%d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-5);
                fmt = tmp + string.Format("{0} ", val); //
            }
            Console.WriteLine(fmt);
        }
        private void xil_printf(string fmt, s32 val1 , s32 val2 , s32 val3) { // for test print
            // remove "| %3d || %9d | %9d |\r\n" 
            if (fmt.Substring(fmt.Length-22)=="| %3d || %9d | %9d |\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-22);
                fmt = tmp + string.Format("| {0,3:d} || {1,9:d} | {2,9:d} |", val1, val2, val3); //
            }
            Console.WriteLine(fmt);
        }

        private void dac__dev_set_dtap(u32 val_dac0_dtap, u32 val_dac1_dtap) {
            // input delay tap 0 ~ 31
            pgu_dac0_reg_write_b8(0x05, (u32)val_dac0_dtap);
            pgu_dac1_reg_write_b8(0x05, (u32)val_dac1_dtap);
        }

        private u32  dac__dev_cal_dtap() { 
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
            //    simple method 
            //       SET 0, HLD 0, SMP increasing ... record SEEK bit
            //       find the center of SMP of the first SEEK high range.

            // SET  = BIT[7:4] @ 0x04
            // HLD  = BIT[3:0] @ 0x04
            // SMP  = BIT[4:0] @ 0x05
            // SEEK = BIT[0]   @ 0x06
            s32 val;
            s32 val_0_pre = 0;
            s32 val_1_pre = 0;
            s32 val_0 = 0;
            s32 val_1 = 0;
            s32 ii;
            s32 val_0_seek_low = -1; // loc of rise
            s32 val_0_seek_hi  = -1; // loc of fall
            s32 val_1_seek_low = -1; // loc of rise
            s32 val_1_seek_hi  = -1; // loc of fall
            s32 val_0_center   = 0; 
            s32 val_1_center   = 0; 

            //// new try: weighted sum approach
            u32 val_0_seek_low_found = 0;
            u32 val_0_seek_hi__found = 0;
            s32 val_0_seek_w_sum     = 0;
            s32 val_0_seek_w_sum_fin = 0;
            s32 val_0_cnt_seek_hi    = 0;
            s32 val_0_center_new     = 0;
            u32 val_1_seek_low_found = 0;
            u32 val_1_seek_hi__found = 0;
            s32 val_1_seek_w_sum     = 0;
            s32 val_1_seek_w_sum_fin = 0;
            s32 val_1_cnt_seek_hi    = 0;
            s32 val_1_center_new     = 0;

            xil_printf(">>>>>> pgu_dacx_cal_input_dtap: \r\n");

            //xil_printf("write_mcs_ep_wi: 0x%08X @ 0x%02X \r\n", MEM_WI_b32, 0x13);

            ii=0;

            // make timing table:
            //  SMP  DAC0_SEEK  DAC1_SEEK 
            xil_printf("+-----++-----------+-----------+\r\n");
            xil_printf("| SMP || DAC0_SEEK | DAC1_SEEK |\r\n");
            xil_printf("+-----++-----------+-----------+\r\n");

            while (true) {
            	//
            	pgu_dac0_reg_write_b8(0x05, (u32)ii); // test SMP
            	pgu_dac1_reg_write_b8(0x05, (u32)ii); // test SMP
            	//
            	val       = (s32)pgu_dac0_reg_read_b8(0x06);
            	val_0_pre = val_0;
            	val_0     = val & 0x01;
            	//xil_printf("read dac0 reg: 0x%02X @ 0x%02X with SMP %02d \r\n", val, 0x06, ii);
            	val       = (s32)pgu_dac1_reg_read_b8(0x06);
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
            else                     val_0_center_new = 0; //15; // no seek_hi
            if (val_1_cnt_seek_hi>0) val_1_center_new = val_1_seek_w_sum / val_1_cnt_seek_hi;
            else                     val_1_center_new = 0; //15; // no seek_hi

            //// add more for too few seek_hi
            if (val_0_cnt_seek_hi>0 && val_0_cnt_seek_hi<8) val_0_center_new = 0; // few seek_hi
            if (val_1_cnt_seek_hi>0 && val_1_cnt_seek_hi<8) val_1_center_new = 0; // few seek_hi

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
            //pgu_dac0_reg_write_b8(0x05, (u32)val_0_center_new);
            //pgu_dac1_reg_write_b8(0x05, (u32)val_1_center_new);

            dac__dev_set_dtap((u32)val_0_center_new, (u32)val_1_center_new);

            xil_printf(">>> DAC input delay taps are chosen at each center\r\n");

            return 0;
        }

        // dacz ... Pattern generator control // to rename
        private void pgu_dacz_dat_write(u32 dacx_dat, s32 bit_loc_trig) { // EP access
            //$$write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, dacx_dat, MASK_ALL); //$$ DACZ
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
            SetWireInValue   (EP_ADRS__DACZ_DAT_WI, dacx_dat    );
            ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI, bit_loc_trig); // trig location
        }
        private u32  pgu_dacz_dat_read(s32 bit_loc_trig) { // EP access
	        //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, bit_loc_trig); //$$ DACZ
            //$$return read_mcs_ep_wo(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WO, MASK_ALL); //$$ DACZ
            ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI, bit_loc_trig); // trig location
            return (u32)GetWireOutValue(EP_ADRS__DACZ_DAT_WO);
        }
        private u32  pgu_dacz__read_status() {
            // return status : 
            // wire w_read_status   = i_trig_dacz_ctrl[5]; //$$
            // wire [31:0] w_status_data = {r_control_pulse[31:2], r_dac1_active_clk, r_dac0_active_clk};
            return pgu_dacz_dat_read(5); 
        }

        // temp for dac setup // to name
        public string pgu_gain__send(int Ch, double DAC_full_scale_current__mA = 25.5) {
            string ret = "OK\n";

            //// calculate parameters // from https://www.analog.com/media/en/technical-documentation/data-sheets/AD9780_9781_9783.pdf
            double I_FS__mA = DAC_full_scale_current__mA; //$$ 8.66 ~ 31.66mA
            double R_FS__ohm = 10e3; // from schematic
            int DAC_gain = Convert.ToInt32((I_FS__mA / 1000 * R_FS__ohm - 86.6) / 0.220 + 0.5);
            // ((25.5 / 1000 * 10e3 - 86.6) / 0.220 + 0.5) = 765.954545455 ~ 0x2FD

            //// for firmware
            u32 val       = (u32)DAC_gain;
            u32 val1_high;
            u32 val1_low;
            u32 val0_high;
            u32 val0_low;
            // resolve data
            val1_high = (val>>24) & 0x000000FF;
            val1_low  = (val>>16) & 0x000000FF;
            val0_high = (val>> 8) & 0x000000FF;
            val0_low  = (val>> 0) & 0x000000FF;

            // set data
            if (Ch == 1) { // Ch == 1 or DAC0
                pgu_dac0_reg_write_b8(0x0C, val1_high);
                pgu_dac0_reg_write_b8(0x0B, val1_low );
                pgu_dac0_reg_write_b8(0x10, val0_high);
                pgu_dac0_reg_write_b8(0x0F, val0_low );
            } else {
                pgu_dac1_reg_write_b8(0x0C, val1_high);
                pgu_dac1_reg_write_b8(0x0B, val1_low );
                pgu_dac1_reg_write_b8(0x10, val0_high);
                pgu_dac1_reg_write_b8(0x0F, val0_low );
            }

            return ret;
        }
        public string pgu_ofst__send(int Ch, float DAC_offset_current__mA = 0, int N_pol_sel = 1, int Sink_sel = 1) {
            string ret = "OK\n";

            //// calculate parameters
            //int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200 + 0.5);
            int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200);
            // 0x3FF, sets output current to 2.0 mA.
            // 0x200, sets output current to 1.0 mA.
            // 0x000, sets output current to 0.0 mA.
            //
            //if DAC_offset_current__code > 0x3FF :
            //print('>>> please check the offset current: {}'.format(DAC_offset_current__mA))
            //raise
            if (DAC_offset_current__code > 0x3FF) {
                DAC_offset_current__code = 0x3FF; // max
            }
            // compose
            int DAC_offset = (N_pol_sel << 15) + (Sink_sel << 14) + DAC_offset_current__code;

            //// for firmware
            u32 val       = (u32)DAC_offset;
            u32 val1_high;
            u32 val1_low;
            u32 val0_high;
            u32 val0_low;
            // resolve data
            val1_high = (val>>24) & 0x000000FF;
            val1_low  = (val>>16) & 0x000000FF;
            val0_high = (val>> 8) & 0x000000FF;
            val0_low  = (val>> 0) & 0x000000FF;

            // set data
            if (Ch == 1) { // Ch == 1 or DAC0
                pgu_dac0_reg_write_b8(0x0E, val1_high); // AUXDAC1 MSB
                pgu_dac0_reg_write_b8(0x0D, val1_low ); // AUXDAC1
                pgu_dac0_reg_write_b8(0x12, val0_high); // AUXDAC2 MSB
                pgu_dac0_reg_write_b8(0x11, val0_low ); // AUXDAC2
            } else {
                pgu_dac1_reg_write_b8(0x0E, val1_high);
                pgu_dac1_reg_write_b8(0x0D, val1_low );
                pgu_dac1_reg_write_b8(0x12, val0_high);
                pgu_dac1_reg_write_b8(0x11, val0_low );
            }

            return ret;
        }

        // data converters
        private long conv_dec_to_bit_2s_comp_16bit(double dec, double full_scale = 20) //$$ int to double
        {
			//$$ // Console.WriteLine(">>> ... in conv_dec_to_bit_2s_comp_16bit() "); //$$
			//$$ // Console.WriteLine(">>> (full_scale / 2.0 - full_scale / Math.Pow(2, 16)) = " + Convert.ToString( (full_scale / 2.0 - full_scale / Math.Pow(2, 16)) ) ); //$$
			//$$ // Console.WriteLine(">>> (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)) = " + Convert.ToString( (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)) ) ); //$$
			
            if (dec > (full_scale / 2.0 - full_scale / Math.Pow(2, 16)))
            {
                dec = full_scale / 2.0 - full_scale / Math.Pow(2, 16);
            }

            if (dec < (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)))
            {
                dec = -full_scale / 2.0;
            }

            //bit_2s_comp = int( 0x10000 * ( dec + full_scale/2)    / full_scale ) + 0x8000
            //$$int bit_2s_comp = Convert.ToInt32(0x10000 * (dec + full_scale / 2.0) / full_scale) + 0x8000;
			long bit_2s_comp = Convert.ToInt64(0x10000 * (dec + full_scale / 2.0) / full_scale) + 0x8000;

            if (bit_2s_comp > (0xFFFF))
            {
                bit_2s_comp -= 0x10000;
            }

            return bit_2s_comp;
        }
        public double conv_bit_2s_comp_16bit_to_dec(int bit_2s_comp, double full_scale = 20) //$$ int to double
        {
            if (bit_2s_comp >= 0x8000) //$$ negative
            {
                //bit_2s_comp = 0x8000;
                //$$double dec = full_scale * Convert.ToDouble(bit_2s_comp) / (double)0x10000 - full_scale / 2.0; 
				double dec = full_scale * (bit_2s_comp) / (double)0x10000 - full_scale; //$$ rev
				// 20 * 0x8000 / 0x10000 - 20 = -10
				//$$// Console.WriteLine("bit_2s_comp = " + Convert.ToString(bit_2s_comp) );
				//$$// Console.WriteLine("dec = " + Convert.ToString(dec) );
				
                return dec;
            }

            else
            {
                //$$double dec = Convert.ToInt32(full_scale * (bit_2s_comp) / 0x10000); //$$ NG
				double dec = full_scale * (bit_2s_comp) / 0x10000;

                //$$if (dec == full_scale / 2.0 - full_scale / Convert.ToInt32(Math.Pow(2, 16)))
				if (dec == full_scale / 2.0 - full_scale / Math.Pow(2, 16))
                    dec = full_scale / 2.0;
                return dec;

            }

        }
        private u32 decchr2data_u32(char decchr) { // u8 --> char
            // '0' -->  0
            u32 val;
            s32 val_t;
            //
            val_t = (s32)decchr - (s32)'0';
            if (val_t<10) {
                val = (u32)val_t;
            }
            else {
                //$$val = (u32)(-1); // no valid code.
                val = (u32)(0xFFFFFFFF); // no valid code.
            }
            //
            return val; 
        }
        private u32 decstr2data_u32(char[] decstr, u32 len) { // u8* hexstr --> char[] hexstr
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
        private u32 hexchr2data_u32(char hexchr) { // u8 --> char
            // '0' -->  0
            // 'A' --> 10
            u32 val;
            s32 val_L;
            s32 val_H;
            //
            val_L = (s32)hexchr - (s32)'0';
            //
            if (val_L < 10) {
            	val = (u32)val_L;
            }
            else {
            	val_H = (s32)hexchr - (s32)'A' + 10;
            	//
            	if (val_H > 15) {
                    val_H = (s32)hexchr - (s32)'a' + 10;
            	}
                val = (u32)val_H;
            }
            //
            return val; 
        }
        private u32 hexstr2data_u32(char[] hexstr, u32 len) { // u8* hexstr --> char[] hexstr
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

        public void dac_set_trig(bool trig_ch1 =false, bool trig_ch2 = false, bool trig_adc_linked = false) {
            u32 val;
            if (trig_ch1 && trig_ch2)
                val = 0x00000030;
            else if ( (trig_ch1 == true) && (trig_ch2 == false) )
                val = 0x00000010;
            else if ( (trig_ch1 == false) && (trig_ch2 == true) )
                val = 0x00000020;
            else
                val = 0x00000000;
            //

            if (trig_adc_linked)
                val = val + 0x100;

            //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, val);
            //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI, 12); // trig location
            //wire w_enable_dac0_bias           = r_cid_reg_ctrl[0];
            //wire w_enable_dac1_bias           = r_cid_reg_ctrl[1];
            //wire w_enable_dac0_pulse_out_seq  = r_cid_reg_ctrl[2]; 
            //wire w_enable_dac1_pulse_out_seq  = r_cid_reg_ctrl[3]; 
            //wire w_enable_dac0_pulse_out_fifo = r_cid_reg_ctrl[4];
            //wire w_enable_dac1_pulse_out_fifo = r_cid_reg_ctrl[5];
            //wire w_rst_dac0_fifo              = r_cid_reg_ctrl[6]; //$$ false path try
            //wire w_rst_dac1_fifo              = r_cid_reg_ctrl[7]; //$$ false path try
            //wire w_force_trig_out             = r_cid_reg_ctrl[8];// new control for trig out  

            pgu_dacz_dat_write(val, 12); // trig control
        }
        public void dac_reset_trig() {
            dac_set_trig();
        }

        private Tuple<long[], double[], double[]> dac_gen_wave_cmd(
            double test_freq_kHz        = 500,
            int len_dac_command_points  = 200,
            double amplitude            = 1.0,
            double phase_diff           = Math.PI/2
        ) {
            //// case for sine wave

            long   test_period_ns   = (long)(1.0/test_freq_kHz*1000000);
            long   sample_period_ns = test_period_ns/len_dac_command_points; // DAC command point space
            double sample_rate_kSPS = (double)1.0/sample_period_ns*1000000;
            //double phase_diff = Math.PI/2; // pi/2 = 90 degree
            
            long[]   buf_time = new long  [len_dac_command_points+1];
            double[] buf_dac0 = new double[len_dac_command_points+1];
            double[] buf_dac1 = new double[len_dac_command_points+1];

            for (int n = 0; n < buf_time.Length; n++)
            {
                buf_time[n] = sample_period_ns*n;
                buf_dac0[n] = (amplitude * Math.Sin((2 * Math.PI * n * test_freq_kHz) / sample_rate_kSPS + 0         ));
                buf_dac1[n] = (amplitude * Math.Sin((2 * Math.PI * n * test_freq_kHz) / sample_rate_kSPS + phase_diff));
            }

            return Tuple.Create(buf_time, buf_dac0, buf_dac1);

        }

        public Tuple<long[], double[], double[]> dac_gen_pulse_cmd(long[] StepTime, double[] StepLevel) {
            // generate dac command dual list from single time-voltage list
            int len_dac_command_points = StepTime.Length;
            long[]   buf_time = new long  [len_dac_command_points];
            double[] buf_dac0 = new double[len_dac_command_points];
            double[] buf_dac1 = new double[len_dac_command_points];

            Array.Copy(StepTime,  buf_time, len_dac_command_points);

            // same data on dac0 and dac1
            Array.Copy(StepLevel, buf_dac0, len_dac_command_points);
            Array.Copy(StepLevel, buf_dac1, len_dac_command_points);

            return Tuple.Create(buf_time, buf_dac0, buf_dac1);
        }

        public Tuple<s32[], u32[]> dac_gen_fifo_dat(long[] time_ns_list, double[] level_volt_list, 
            int    time_ns__code_duration, 
            double load_impedance_ohm, double output_impedance_ohm,
            double scale_voltage_10V_mode, int output_range, double gain_voltage_10V_to_40V_mode, 
            double out_scale, double out_offset)
        {
            // copy to new lists
            int len_data = time_ns_list.Length;
            long[]   time_ns_list__ref    = new long  [len_data];
            double[] level_volt_list__ref = new double[len_data];

            Array.Copy(time_ns_list,    time_ns_list__ref,    len_data);
            Array.Copy(level_volt_list, level_volt_list__ref, len_data);

            // generate pulse waveform
            var pulse_info = pgu__gen_pulse_info(
                output_range, 
                time_ns_list__ref, level_volt_list__ref, 
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm, 
                scale_voltage_10V_mode, gain_voltage_10V_to_40V_mode,
                out_scale, out_offset);

            // download waveform into FPGA
            //load_pgu_waveform_Cid(ch, pulse_info.Item1, pulse_info.Item2); 
            //long[] len_fifo_data = pulse_info.Item1;
            //string[] pulse_info_num_block_str = pulse_info.Item2; //$$ must remove
            List<s32>[]  code_value__list    = pulse_info.Item1;
            List<long>[] code_duration__list = pulse_info.Item2;            

            // set the number of fifo data length
            u32 len_fifo_data = 0;
            for (int i = 0; i < code_value__list.Length; i++)
            {
                len_fifo_data = len_fifo_data + (u32)code_value__list[i].Count;
            }

            s32[]  code_value__s32_buf    ;
            s32[]  code_inc_value__s32_buf;
            long[] code_duration__long_buf; 
            u32[]  code_duration__u32_buf ; 

            s32[]  merge_code_inc_value__s32_buf = new s32[len_fifo_data];
            u32[]  merge_code_duration__u32_buf  = new u32[len_fifo_data]; 
            


            // send DAC data into FPGA FIFO
            //for (int i = 0; i < pulse_info_num_block_str.Length; i++)
            int idx_merge = 0;
            for (int i = 0; i < code_value__list.Length; i++)
            {
                //pgu_fdac__send(ch, pulse_info_num_block_str[i]); //$$ replaced

                //// collect DAC data into arrays
                //code_value__list[i]   
                code_value__s32_buf = code_value__list[i].ToArray();
                // shift 16 bits due to 0 incremental code
                code_inc_value__s32_buf = code_value__s32_buf.Select(x => (x<<16)).ToArray();
                //code_duration__list[i]
                code_duration__long_buf = code_duration__list[i].ToArray();
                code_duration__u32_buf  = Array.ConvertAll(code_duration__long_buf, x => (u32)x);

                //// accumulate arrays 
                int len_code_buf = code_inc_value__s32_buf.Length;
                Array.Copy(code_inc_value__s32_buf, 0, merge_code_inc_value__s32_buf, idx_merge, len_code_buf);
                Array.Copy(code_duration__u32_buf,  0, merge_code_duration__u32_buf,  idx_merge, len_code_buf);
                idx_merge += len_code_buf;

                //// send arrays to FIFOs 
                // byte[] dat_bytearray = code_inc_value__s32_buf.SelectMany(BitConverter.GetBytes).ToArray();
                // byte[] dur_bytearray = code_duration__u32_buf.SelectMany(BitConverter.GetBytes).ToArray(); //$$ long to u32
// 
                // if (ch == 1) { // Ch == 1 or DAC0
                //     WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray);
                //     WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray);
                // }
                // else { // Ch == 2 or DAC1
                //     WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray);
                //     WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray);
                // }

            }

            ////

            //s32[]  code_inc_value__s32_buf = new s32[] {0};
            //long[] code_duration__long_buf = new long[] {0}; //$$ long --> u32 ?? to check later.
            
            return Tuple.Create(merge_code_inc_value__s32_buf, merge_code_duration__u32_buf);
        }

        private Tuple<List<s32>, List<long>> gen_pulse_info_segment__inc_step(int code_start, double volt_diff, int code_diff, int code_step, long num_steps, long code_duration, 
				long time_start_ns = 0, long max_duration_a_code__in_flat_segment = 16, long max_num_codes__in_slope_segment = 16,
                int time_ns__code_duration = 10)
        {
            long num_codes = num_steps;

            //string pulse_info_num_block_str = ""; // = String.Format(" #N8_{0,6:D6}", num_codes * 16); //$$ must revise

			long time_ns = (long)time_start_ns;
			long duration_ns = 0; //$$
            int code_value = code_start;

            //string test_str;

			
			//string code_value_str = ""; //$$
			//string code_value_float_str = ""; //$$
			//string code_duration_str = ""; //$$
			//string time_ns_str = ""; //$$
			//string duration_ns_str = ""; //$$
			
			long total_duration_segment = num_steps*(code_duration + 1); //$$
			
			int    num_merge_steps = 1;
			double code_start_float = conv_bit_2s_comp_16bit_to_dec(code_start);
			
			//$$ note if code_step == 0, flat segment
			//   re-calculate code_duration
			if ((volt_diff == 0) && (total_duration_segment > max_duration_a_code__in_flat_segment )) 
			{
				// use max_duration_a_code__in_flat_segment
				code_duration = (int)max_duration_a_code__in_flat_segment - 1;
			}
			else if ((volt_diff == 0) && (total_duration_segment <= max_duration_a_code__in_flat_segment )) 
			{
				// use one step for total_duration_segment 
				//num_codes     = 1; // not used
				code_duration = (int)total_duration_segment - 1; //$$ 
			}
			else if (num_steps > max_num_codes__in_slope_segment)
			{
				//$$ slope segment ...
				// use max_num_codes__in_slope_segment
				double ratio_num_steps_max_num_codes__in_slope_segment = (double)num_steps/max_num_codes__in_slope_segment;
				// Console.WriteLine("ratio_num_steps_max_num_codes__in_slope_segment = " + Convert.ToString(ratio_num_steps_max_num_codes__in_slope_segment) );
				num_merge_steps = (int)Math.Ceiling(ratio_num_steps_max_num_codes__in_slope_segment);
				// Console.WriteLine("num_merge_steps                                 = " + Convert.ToString(num_merge_steps) );
				
				code_duration = (int)((code_duration+1)*num_merge_steps - 1); //$$ 
			}
			else 
			{
				// as it is ...
			}
			
			//$$ code list and duration list
            List<s32>  code_value_list    = new List<s32>();
            List<long> code_duration_list = new List<long>();
			
            long duration_send = total_duration_segment;
			double code_value_float = code_start_float;
			long count_codes = 0; // count number of codes in a segment
			while (true)
            {
				//$$ calculate dac code 
				code_value = (int)conv_dec_to_bit_2s_comp_16bit(code_value_float);
				
                ////test_value = (code_value << 16) + code_duration;
                //test_str = string.Format("_{0,4:X4}", code_value);
                //pulse_info_num_block_str = pulse_info_num_block_str + test_str;
                //test_str = string.Format("{0,4:X4}", 0); //$$ incremental code 0
                //pulse_info_num_block_str = pulse_info_num_block_str + test_str;
                //test_str = string.Format("{0,8:X8}", code_duration);
                //pulse_info_num_block_str = pulse_info_num_block_str + test_str;

				
				count_codes++; //$$ increase count

				duration_ns = (code_duration + 1) * (long)time_ns__code_duration;

				//$$ report as string
				//code_value_str       += string.Format("{0,6:X4}, ", code_value  ); //$$ must convert to s32 array or list
				//code_value_float_str += string.Format("{0,6:f3}, ", conv_bit_2s_comp_16bit_to_dec(code_value)  );
				//code_duration_str    += string.Format("{0,6:d}, ", code_duration); //$$ must convert to long array or list
				//time_ns_str          += string.Format("{0,6:d}, ", time_ns      );
				//duration_ns_str      += string.Format("{0,6:d}, ", duration_ns);

                // report data as list
                code_value_list   .Add(code_value);
                code_duration_list.Add(code_duration);

				// update code in float 
				code_value_float += (volt_diff * (code_duration+1) / total_duration_segment); //$$ get more accuracy

				// update time_ns 
				time_ns += duration_ns;
				
				//$$ update loop 
				duration_send -= (code_duration+1);
				
				if (duration_send < (code_duration+1) ) 
				{
					code_duration = (int)duration_send-1;
				}

				if (duration_send == 0) break;
				
            }

            //pulse_info_num_block_str += " \n";
			
			//$$ header generation
			//string pulse_info_num_block_header_str = String.Format(" #N8_{0,6:D6}", count_codes * 16); //$$ must revise
			
			// merge string 
			//pulse_info_num_block_str = pulse_info_num_block_header_str + pulse_info_num_block_str;
			
            //return Tuple.Create(pulse_info_num_block_str,code_value_float_str,time_ns_str,duration_ns_str);
            //return Tuple.Create(pulse_info_num_block_str,code_value_float_str,time_ns_str);
            //return Tuple.Create(pulse_info_num_block_str,code_value_float_str,time_ns_str,code_value_list,code_duration_list);
            return Tuple.Create(code_value_list, code_duration_list);
        }
        private void pgu__setup_gain_offset(int Ch, 
            double DAC_full_scale_current__mA = 25.5, float DAC_offset_current__mA = 0, 
            int N_pol_sel = 1, int Sink_sel = 1) {

            //$$ double DAC_full_scale_current__mA = 25.5; // 20.1Vpp
            pgu_gain__send(Ch, DAC_full_scale_current__mA);

            //$$ float DAC_offset_current__mA = 0; // 0 min // # 0.625 mA
            //float DAC_offset_current__mA = 1; // 
            //float DAC_offset_current__mA = 2; // 2 max
            //$$ int N_pol_sel = 1; // 1
            //$$ int Sink_sel = 1; // 1
            pgu_ofst__send(Ch, DAC_offset_current__mA, N_pol_sel, Sink_sel);

        }

        public void dac_set_fifo_dat(
            int ch, int num_repeat_pulses,
            s32[] code_inc_value__s32_buf,
            u32[] code_duration__u32_buf) {

            u32 val;
            //$$ note pgu_dacz_dat_write --> dac__pat*...

            // set pulse repeat number
            //pgu_frpt__send(ch, num_repeat_pulses); //$$ replaced
            val = (u32)num_repeat_pulses;
            if (ch == 1) { // Ch == 1 or DAC0
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000020); // cid_adrs for r_cid_reg_dac0_num_repeat
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,          8); // w_trig_cid_adrs_wr
                pgu_dacz_dat_write(0x00000020,  8); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI,        val); // data for cid_data
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         10); // w_trig_cid_data_wr 
                pgu_dacz_dat_write(val, 10); // trig control
            } else { // Ch == 2 or DAC1
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000030); // cid_adrs for r_cid_reg_dac1_num_repeat
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,          8); // w_trig_cid_adrs_wr
                pgu_dacz_dat_write(0x00000030,  8); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI,        val); // data for cid_data
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         10); // w_trig_cid_data_wr 
                pgu_dacz_dat_write(val, 10); // trig control
            }


            //// download waveform into FPGA

            // set the number of fifo data length
            u32 len_fifo_data = (u32)code_inc_value__s32_buf.Length;
            val = (u32)len_fifo_data;
            if (ch == 1) { // Ch == 1 or DAC0
                //// dac0 fifo reset 
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000040); // w_rst_dac0_fifo   
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000040, 12); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000000); // clear bit
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000000, 12); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000000); // clear bit again
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000000, 12); // trig control
                // on dac0 fifo length set
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00001000); // cid_adrs for r_cid_reg_dac0_num_ffdat
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,          8); // w_trig_cid_adrs_wr
                pgu_dacz_dat_write(0x00001000,  8); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI,        val); // data for cid_data
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         10); // w_trig_cid_data_wr
                pgu_dacz_dat_write(val, 10); // trig control
            }
            else { // Ch == 2 or DAC1
                //// dac1 fifo reset 
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000080); // w_rst_dac1_fifo
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000080, 12); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000000); // clear bit
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000000, 12); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00000000); // clear bit again
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         12); // w_trig_cid_ctrl_wr
                pgu_dacz_dat_write(0x00000000, 12); // trig control
                // on dac1 fifo length set
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, 0x00001010); // cid_adrs for r_cid_reg_dac1_num_ffdat
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,          8); // w_trig_cid_adrs_wr
                pgu_dacz_dat_write(0x00001010,  8); // trig control
                //SetWireInValue   (EP_ADRS__DACZ_DAT_WI,        val); // data for cid_data
                //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI,         10); // w_trig_cid_data_wr 
                pgu_dacz_dat_write(val, 10); // trig control
            }            

            //// send merged DAC data into FPGA FIFO
            byte[] dat_bytearray = code_inc_value__s32_buf.SelectMany(BitConverter.GetBytes).ToArray();
            byte[] dur_bytearray = code_duration__u32_buf.SelectMany(BitConverter.GetBytes).ToArray();
            //s32 use_fifo = 0;
            //s32 use_fifo = 1;
            //s32 MAX_DEPTH_FIFO_32B = 256; // OK with 396 due to previous scpi pi processing capa
            if (ch == 1) { // Ch == 1 or DAC0
                //WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray, use_fifo, MAX_DEPTH_FIFO_32B);
                //WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray, use_fifo, MAX_DEPTH_FIFO_32B);
                WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray);
            }
            else { // Ch == 2 or DAC1
                //WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray, use_fifo, MAX_DEPTH_FIFO_32B);
                //WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray, use_fifo, MAX_DEPTH_FIFO_32B);
                WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray);
            }

        }

        private Tuple<List<s32>[], List<long>[]> pgu__gen_pulse_info(int output_range, long[] time_ns_list, double[] level_volt_list,
            int    time_ns__code_duration, 
            double load_impedance_ohm, double output_impedance_ohm,
            double scale_voltage_10V_mode, double gain_voltage_10V_to_40V_mode, 
            double out_scale, double out_offset) 
        {
            double Devide_V = 1;
            if (output_range == 40)
            {
                Devide_V = gain_voltage_10V_to_40V_mode;
            }

            // apply load_impedance_ohm
            scale_voltage_10V_mode = scale_voltage_10V_mode * ((output_impedance_ohm + load_impedance_ohm) / load_impedance_ohm);

            // apply calibration to voltages
            for (int i = 0; i < level_volt_list.Length; i++) 
            {
                level_volt_list[i]     = (level_volt_list[i]* out_scale + out_offset) * scale_voltage_10V_mode / Devide_V; 
            }

            long[] num_steps_list = new long[time_ns_list.Length - 1]; //$$ <<<
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				num_steps_list[i - 1] = Convert.ToInt64(((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__code_duration));  //$$ number of DAC points in eash segment
            }

            double[] level_diff_volt_list = new double[level_volt_list.Length - 1]; //$$ <<<
            for (int i = 1; i < level_volt_list.Length; i++)
            {
                level_diff_volt_list[i - 1] = level_volt_list[i] - level_volt_list[i - 1]; //$$ dac incremental value in each segment
            }

            int[] level_code_list = new int[level_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_volt_list.Length; i++)
            {
                level_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(level_volt_list[i]); //$$ dac starting code in ease segment
            }

            int[] level_step_code_list = new int[level_diff_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                //$$ num_steps_list[i] == 0 means data duplicate.
                if (num_steps_list[i] > 0) {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) / num_steps_list[i]); //$$ dac incremental code in each segment
                }
                else {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(0); //$$ 
                }
            }
			
			int[] level_diff_code_list = new int[level_diff_volt_list.Length]; //$$ <<<
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                level_diff_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) ); //$$ dac full difference in each segment
            }

            int[]    time_step_code_list        = new int   [time_ns_list.Length - 1]; //$$ <<<
			double[] time_step_code_double_list = new double[time_ns_list.Length - 1];
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				time_step_code_list[i - 1] = 0; //$$ basic step 1
            }

            string[] num_block_str__sample_code__list = new string[level_step_code_list.Length]; //$$ <<<

            List<s32>[]  code_value__list    = new List<s32> [level_step_code_list.Length];
            List<long>[] code_duration__list = new List<long>[level_step_code_list.Length];

            int code_start;
			double volt_diff;
			int code_diff;
            int code_step;
            long num_steps;
			long time_step_code; //$$
			long time_start_ns; //$$
			
			long max_duration_a_code__in_flat_segment = Convert.ToInt64(Math.Pow(2, 31)-1); // 2^32-1
			//long max_duration_a_code__in_flat_segment = Convert.ToInt64(Math.Pow(2, 16)-1); // 2^16-1
			//long max_duration_a_code__in_flat_segment = 16; // 16
			
            int Point_NUM = Convert.ToInt32(1000 / (num_steps_list.Length));    //$$ FIFO Count limit 
			//long max_num_codes__in_slope_segment = (long)16; //Point_NUM;
			long max_num_codes__in_slope_segment = Point_NUM;

            for (int i = 0; i < level_step_code_list.Length; i++)
            {
                code_start     = level_code_list[i];      //$$ dac starting code in each segment
				volt_diff      = level_diff_volt_list[i]; //$$ dac voltage difference in in each segment for max step +/- 20V or more.
				code_diff      = level_diff_code_list[i]; //$$ dac code diff in each segment for better slope shape //$$ NG  with large slope step more than +/-10V
                code_step      = level_step_code_list[i]; //$$ dac incremental code in each segment 
                num_steps      = num_steps_list[i];       //$$ number of DAC points in eash segment
                time_step_code = time_step_code_list[i];  //$$ duration count 32 bit in each segment // share it with all points
				time_start_ns  = time_ns_list[i];         //$$ start time each segment in ns
				
				var ret = gen_pulse_info_segment__inc_step(code_start, volt_diff, code_diff, code_step, num_steps, time_step_code, 
							time_start_ns, max_duration_a_code__in_flat_segment, max_num_codes__in_slope_segment, time_ns__code_duration); //$$ (pulse_info_num_block_str, code_value_float_str, time_ns_str) 


				//num_block_str__sample_code__list[i] = ret.Item1; //$$ in string // removed

                //$$ segment info by list not string
                code_value__list[i]    = ret.Item1;
                code_duration__list[i] = ret.Item2;
				
				//$$ update new number of codes //$$ must or not
				// string time_ns_str = ret.Item3;
				// double[] time_ns_str_double = Array.ConvertAll(time_ns_str.Remove(time_ns_str.Length-2,1).Split(','), Double.Parse);
				// num_steps_list[i] = (long)(time_ns_str_double.Length); //$$
				
            }
			
			//return Tuple.Create(num_steps_list, num_block_str__sample_code__list, FIFO_Count);
            //return Tuple.Create(num_steps_list, num_block_str__sample_code__list, code_value__list, code_duration__list);
            return Tuple.Create(code_value__list, code_duration__list);
        }

        // DFT functions:

        private Tuple<double[], double[]> dft_gen_coef(
            double test_freq_kHz             = 500      , // kHz
            uint   adc_base_freq_MHz         = 189      , // MHz
            uint   adc_sampling_period_count = 379      ,
            int    mode_undersampling        = 1        , // 0 for normal sampling, 1 for undersampling
            int    len_dft_coef              = 378      , //$$ must check integer // if failed to try multiple cycle // samples_per_cycle ratio
            double amplitude                 = 1.0      ,
            double phase_diff                = Math.PI/2  //$$ IQ pairs : sin(x) and sin(x+phase_diff) // phase_diff must be pi/2.
        ) {
            // compute DFT coefficients: In-phase, Quadrature-phase

            // ex: 500kHz undersampling
            //     189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave
            //     thus, sampling freq = 189MHz/379  =  0.498680739 Msps
            //           test freq     = 0.5MHz
            //           image freq    = 0.5MHz - 189MHz/379 = 1.31926121kHz (= 189MHz*(1/378 - 1/379) = 189MHz/378/379 = 189MHz/143262)
            //           number of samples in a cycle = (sampling freq)/( (test freq)- (sampling freq) ) 
            //                                        = 189MHz/379/(0.5MHz - 189MHz/379) = 1/(0.5MHz/189MHz*379-1) = 378
            //     note 189MHz/378 = 0.5MHz

            //double sample_rate_kSPS     = 189*1e6 / 379 / 1000; // kHz
            double sample_rate_kSPS       = adc_base_freq_MHz*1e6 / adc_sampling_period_count / 1000; // kHz
            //
            Console.WriteLine(string.Format("{0} = {1,0:0.####} [kHz]", "sample_rate_kSPS", sample_rate_kSPS));

            double imag_freq_kHz        = test_freq_kHz - sample_rate_kSPS;
            //
            Console.WriteLine(string.Format("{0} = {1,0:0.####} [kHz]", "imag_freq_kHz", imag_freq_kHz));

            double target_freq_kHz;
            if (mode_undersampling==1)
                target_freq_kHz = imag_freq_kHz;
            else 
                target_freq_kHz = test_freq_kHz;
            //
            Console.WriteLine(string.Format("{0} = {1,0:0.####} [kHz]", "target_freq_kHz", target_freq_kHz));


            double[] dft_coef_i_buf = new double[len_dft_coef];
            double[] dft_coef_q_buf = new double[len_dft_coef];

            for (int n = 0; n < len_dft_coef; n++)
            {
                dft_coef_i_buf[n] = (amplitude * Math.Sin((2 * Math.PI * n * target_freq_kHz) / sample_rate_kSPS + 0         ));
                dft_coef_q_buf[n] = (amplitude * Math.Sin((2 * Math.PI * n * target_freq_kHz) / sample_rate_kSPS + phase_diff));
            }

            return Tuple.Create(dft_coef_i_buf, dft_coef_q_buf);
        }
        private double[] dft_calc_iq(
            int len_dft_buf = 0, double[] dft_coef_buf0_double = null, double[] dft_coef_buf1_double = null,
            int num_repeat_block_coef =   1,
            int idx_offset_adc_data   =   0,
            int len_adc_buf = 0,    int[] adc_data_buf0_s32    = null,    int[] adc_data_buf1_s32    = null,
            double adc_scale_s32_volt =   1 // 4.096 / (Math.Pow(2,31)-1.0)
        ) {
            // do sum_product
            double[] sum_prod = new double[4]; // IQ sum_prod list for ADC0 and ADC1 = {sp_ADC0_I, sp_ADC0_Q, sp_ADC1_I, sp_ADC1_Q}
            sum_prod[0] = 0.0;
            sum_prod[1] = 0.0;
            sum_prod[2] = 0.0;
            sum_prod[3] = 0.0;

            // find min length to compute
            int len_sum = len_dft_buf*num_repeat_block_coef;
            if (len_sum>(len_adc_buf-idx_offset_adc_data))
                len_sum = len_adc_buf-idx_offset_adc_data;

            for (int i = 0; i < len_sum; i++)
            {
                sum_prod[0] += dft_coef_buf0_double[i % len_dft_buf]*(double)adc_data_buf0_s32[i+idx_offset_adc_data];
                sum_prod[1] += dft_coef_buf1_double[i % len_dft_buf]*(double)adc_data_buf0_s32[i+idx_offset_adc_data];
                sum_prod[2] += dft_coef_buf0_double[i % len_dft_buf]*(double)adc_data_buf1_s32[i+idx_offset_adc_data];
                sum_prod[3] += dft_coef_buf1_double[i % len_dft_buf]*(double)adc_data_buf1_s32[i+idx_offset_adc_data];
            }

            // calculate IQ values
            double adc0_i = sum_prod[0]/len_sum * adc_scale_s32_volt;
            double adc0_q = sum_prod[1]/len_sum * adc_scale_s32_volt;
            double adc1_i = sum_prod[2]/len_sum * adc_scale_s32_volt;
            double adc1_q = sum_prod[3]/len_sum * adc_scale_s32_volt;

            return new double[] {adc0_i, adc0_q, adc1_i, adc1_q};
        }

        private double[] dft_calc_impedance_ratio(
            double adc0_i, double adc0_q, double adc1_i, double adc1_q
        ) {
            // calculate impedance ratio : assume adc0 as voltage, and  adc1 as negative current.

            //## referece:
            //  def test_dft_calc(acc_flt32__list):
            //  	#SS = [-1755152000.0,  1363413504.0,  265692464.0,  350571840.0] # test 
            //  	SS = acc_flt32__list
            //  	
            //  	print('// ----------------------------------------- //')
            //  	print('// Vx : {} + {}j '.format(SS[0],SS[1]) )
            //  	print('// Vr : {} + {}j '.format(SS[2],SS[3]) )
            //  	print('// conj(Vr) : {} - {}j '.format(SS[2],SS[3]) )
            //  	print('// (abs(Vr))^2 : {} '.format( (SS[2]*SS[2]+SS[3]*SS[3]) ) )
            //  	print('// Vx * conj(-Vr) : {} + {}j '.format( -SS[0]*SS[2]-SS[1]*SS[3] , SS[0]*SS[3]-SS[1]*SS[2] ) )
            //  	#
            //  	try : 
            //  		RR = (-SS[0]*SS[2]-SS[1]*SS[3])/(SS[2]*SS[2]+SS[3]*SS[3]) + 1j*( SS[0]*SS[3]-SS[1]*SS[2])/(SS[2]*SS[2]+SS[3]*SS[3])
            //  		print('// R : {} + {}j '.format( (-SS[0]*SS[2]-SS[1]*SS[3])/(SS[2]*SS[2]+SS[3]*SS[3]) ,
            //  										( SS[0]*SS[3]-SS[1]*SS[2])/(SS[2]*SS[2]+SS[3]*SS[3]) ) )
            //  	except:
            //  		RR = 0
            //  	print('// abs(R)   : {} '.format( np.abs(RR) ) )
            //  	print('// angle(R) : {} '.format( np.angle(RR, deg=True) ) )
            //  	print('// ----------------------------------------- //')
            //  
            //  	return RR

            // print out 
            Console.WriteLine("> iq related calculataion : "); // test ptint
            Console.WriteLine(string.Format(" {0} = {1} + {2}j ", "Vx",              adc0_i,  adc0_q )); 
            Console.WriteLine(string.Format(" {0} = {1} + {2}j ", "Vr",              adc1_i,  adc1_q )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "abs(Vx)",         Math.Sqrt(adc0_i*adc0_i + adc0_q*adc0_q) )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "abs(Vr)",         Math.Sqrt(adc1_i*adc1_i + adc1_q*adc1_q) )); 
            Console.WriteLine(string.Format(" {0} = {1} + {2}j ", "conj(-Vr)",      -adc1_i,  adc1_q )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "abs(Vr))^2",      adc1_i*adc1_i + adc1_q*adc1_q )); 

            // complex ratio = Vx * conj(-Vr) / abs(Vr))^2
            //   Vx * conj(-Vr) = (adc0_i,  adc0_q) * (-adc1_i,  adc1_q)
            //                  = (-adc0_i*adc1_i-adc0_q*adc1_q,  adc0_i*adc1_q-adc0_q*adc1_i)
            double imp_ratio_i = (-adc0_i*adc1_i-adc0_q*adc1_q) / (adc1_i*adc1_i + adc1_q*adc1_q) ; 
            double imp_ratio_q = ( adc0_i*adc1_q-adc0_q*adc1_i) / (adc1_i*adc1_i + adc1_q*adc1_q) ;
            double imp_ratio_abs   = Math.Sqrt(imp_ratio_i*imp_ratio_i+imp_ratio_q*imp_ratio_q) ;
            double imp_ratio_phase = Math.Atan2( imp_ratio_q, imp_ratio_i );
            double imp_ratio_angle = Math.Atan2( imp_ratio_q, imp_ratio_i )*180/Math.PI;

            Console.WriteLine(string.Format(" {0} = {1} + {2}j ", "Vx * conj(-Vr)",  -adc0_i*adc1_i-adc0_q*adc1_q,  adc0_i*adc1_q-adc0_q*adc1_i )); 
            Console.WriteLine(string.Format(" {0} = {1} + {2}j ", "Z = Vx / (-Vr)",                   imp_ratio_i,  imp_ratio_q )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "abs  (Z)      ",    imp_ratio_abs    )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "phase(Z)      ",    imp_ratio_phase  )); 
            Console.WriteLine(string.Format(" {0} = {1}        ", "angle(Z)      ",    imp_ratio_angle  )); 

            return new double [5] {imp_ratio_i, imp_ratio_q, imp_ratio_abs, imp_ratio_phase, imp_ratio_angle};
        }

        private Tuple<double[], double[], double[], double[]> dft_compute(
            double test_freq_kHz             = 500      , // kHz
            uint   adc_base_freq_MHz         = 189      , // MHz
            uint   adc_sampling_period_count = 379      ,
            int    mode_undersampling        = 1        , // 0 for normal sampling, 1 for undersampling
            int    len_dft_coef              = 378      , //$$ must check integer // if failed to try multiple cycle // samples_per_cycle ratio
            int    num_repeat_block_coef     = 2        , // adc data inputs
            int    idx_offset_adc_data       = 0        ,
            int    len_adc_data              = 0        , 
            s32[]  adc0_s32_buf              = null     , //
            s32[]  adc1_s32_buf              = null       //
        ) {

            //// compute DFT coefficients: In-phase, Quadrature-phase
            
            var ret__dft_coef = dft_gen_coef(
                test_freq_kHz             ,
                adc_base_freq_MHz         ,
                adc_sampling_period_count ,
                mode_undersampling        ,
                len_dft_coef              
            );

            double[] dft_coef_i_buf;
            double[] dft_coef_q_buf;

            dft_coef_i_buf = ret__dft_coef.Item1;
            dft_coef_q_buf = ret__dft_coef.Item2;

            //string dft_coef_i_buf_str = String.Join(", ", dft_coef_i_buf); // test ptint
            //string dft_coef_q_buf_str = String.Join(", ", dft_coef_q_buf); // test ptint
            //Console.WriteLine("> dft_coef_i_buf =" + dft_coef_i_buf_str); // test ptint
            //Console.WriteLine("> dft_coef_q_buf =" + dft_coef_q_buf_str); // test ptint


            //// calculate IQ values
            //int    num_repeat_block_coef =   1;
            //int    idx_offset_adc_data   = 100;
            double adc_scale_s32_volt    =  4.096 / (Math.Pow(2,31)-1.0);

            double[] iq_info = dft_calc_iq(
                len_dft_coef, dft_coef_i_buf, dft_coef_q_buf,
                num_repeat_block_coef,
                idx_offset_adc_data,
                len_adc_data, adc0_s32_buf  , adc1_s32_buf   ,
                adc_scale_s32_volt
            );

            string iq_info_str = String.Join(", ", iq_info); // test ptint
            Console.WriteLine("> iq_info =" + iq_info_str); // test ptint


            //// calculate complex ratio
            double[] imp_ratio_info = dft_calc_impedance_ratio(iq_info[0], iq_info[1], iq_info[2], iq_info[3]);


            return Tuple.Create(dft_coef_i_buf, dft_coef_q_buf, iq_info, imp_ratio_info);
        }

        private void dft_log(char[] log_filename, 
            double test_freq_kHz            , // dft parameters
            uint    adc_base_freq_MHz        , //
            uint    adc_sampling_period_count, //
            int    mode_undersampling       , //
            int    len_dft_buf = 0, double[] dft_coef_buf0_double = null, double[] dft_coef_buf1_double = null, // dft coef
            int    num_repeat_block_coef = 1, // 
            int    idx_offset_adc_data   = 0, //
            int     len_adc_buf = 0,    int[] adc_data_buf0_s32    = null,    int[] adc_data_buf1_s32    = null, // adc data
            double[] iq_info = null, double[] imp_ratio_info = null // IQ result
            ) {
            // open or create a file
            string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), LOG_DIR_NAME, "log"); //$$ TODO: logfile location in vs code
            string LogFileName = Path.Combine(LogFilePath, new string(log_filename));
            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ;
                }
            }

            // write header
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) {
                ws.WriteLine("\"\"\" data log file : import data as CONSTANT \"\"\"");
                ws.WriteLine("# pylint: disable=C0301");
                ws.WriteLine("# pylint: disable=line-too-long");
                ws.WriteLine("# pylint: disable=C0326 ## disable-exactly-one-space");
                ws.WriteLine("## log start"); //$$ add python comment header
            }

            // print out -- dft coef
            string dft_coef_buf0_double_str = "";
            string dft_coef_buf1_double_str = "";
            for (s32 i = 0; i < len_dft_buf; i++) {
                //
                dft_coef_buf0_double_str = dft_coef_buf0_double_str + string.Format("{0,24:G}, ",dft_coef_buf0_double[i]);
                dft_coef_buf1_double_str = dft_coef_buf1_double_str + string.Format("{0,24:G}, ",dft_coef_buf1_double[i]);
            }

            // print out -- adc data in use
            int len_sum = len_dft_buf*num_repeat_block_coef;
            if (len_sum>(len_adc_buf-idx_offset_adc_data))
                len_sum = len_adc_buf-idx_offset_adc_data;

            string adc_data_buf0_s32_str = "";
            string adc_data_buf1_s32_str = "";
            for (s32 i = 0; i < len_sum; i++) {
                //
                adc_data_buf0_s32_str = adc_data_buf0_s32_str + string.Format("{0,11:D}, ",adc_data_buf0_s32[i+idx_offset_adc_data]);
                adc_data_buf1_s32_str = adc_data_buf1_s32_str + string.Format("{0,11:D}, ",adc_data_buf1_s32[i+idx_offset_adc_data]);
            }


            // write data string on the file
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                ws.WriteLine(""); // newline
                //
                ws.WriteLine("TEST_FREQ_KHZ             = " + string.Format("{0}", test_freq_kHz)  ); 
                ws.WriteLine("ADC_BASE_FREQ_MHZ         = " + string.Format("{0}", adc_base_freq_MHz)  ); 
                ws.WriteLine("ADC_SAMPLING_PERIOD_COUNT = " + string.Format("{0}", adc_sampling_period_count)  ); 
                ws.WriteLine("MODE_UNDERSAMPLING        = " + string.Format("{0}", mode_undersampling)  ); 
                ws.WriteLine("LEN_DFT_BUF               = " + string.Format("{0}", len_dft_buf)  ); 
                ws.WriteLine("NUM_REPEAT_BLOCK_COEF     = " + string.Format("{0}", num_repeat_block_coef)  ); 
                ws.WriteLine("IDX_OFFSET_ADC_DATA       = " + string.Format("{0}", idx_offset_adc_data)  ); 
                ws.WriteLine("LEN_SUM                   = " + string.Format("{0}", len_sum)  ); 
                ws.WriteLine("IQ_INFO                   = [" + string.Join(", ", iq_info) + "] ## ADC0_I,ADC0_Q,ADC1_I,ADC1_Q" ); 
                ws.WriteLine("IMP_RATIO_INFO            = [" + string.Join(", ", imp_ratio_info) + "] ## Z_I,Z_Q,mag,phase,angle" ); 
                //
                ws.WriteLine(""); // newline
                //
                ws.WriteLine("DFT_COEF_I_BUF = [" + dft_coef_buf0_double_str + "]"); 
                ws.WriteLine("DFT_COEF_Q_BUF = [" + dft_coef_buf1_double_str + "]"); 
                //
                ws.WriteLine(""); // newline
                //
                ws.WriteLine("ADC_DATA_0_BUF = [" + adc_data_buf0_s32_str + "]"); 
                ws.WriteLine("ADC_DATA_1_BUF = [" + adc_data_buf1_s32_str + "]"); 
                //
                ws.WriteLine(""); // newline
                //
                //
                ws.WriteLine(""); // newline
                ws.WriteLine("## log done"); 
            }



        }


        // CMU functions:

        //// unit functions:
        // cmu__dev_*
        // cmu__dacq_*

        //// macro functions:
        // cmu_init_sig(...)
        // cmu_set_sig_dacp(...)
        // cmu_set_sig_extc(...)
        // cmu_set_sig_filt(...)
        // cmu_init_anl(...)
        // cmu_set_anl_rr_iv(...)
        // cmu_set_anl_det_mod(...)
        // cmu_set_anl_amp_gain(...)
        // cmu_get_anl_stat()
        // cmu_set_anl_dacq(...)
        // cmu_get_anl_dacq(...)

        private void cmu__dev_set_cntl(u32 val) {
            // | CMU   | CMU_WI        | 0x050      | wire_in_14 | Control for CMU-SUB.       | bit[0]=force_io_path_ANL       |
            // |       |               |            |            |                            | bit[1]=force_io_path_SIG       |
            // |       |               |            |            |                            | bit[2]=auto_sel_io_path        |
            SetWireInValue(EP_ADRS__CMU_WI, val);
        }

        public u32 cmu__dev_get_stat() {
            // | CMU   | CMU_WO        | 0x0D0      | wireout_34 | Return CMU-SUB status.     | bit[0]=selection_io_path_ANL   |
            // |       |               |            |            |                            | bit[1]=selection_io_path_SIG   |
            // |       |               |            |            |                            | bit[7:2]=NA                    |
            // |       |               |            |            |                            | bit[11:8]=board class ID[3:0]  |
            // |       |               |            |            |                            | bit[19:16]=MTH SLOT ID[3:0]    |
            return GetWireOutValue(EP_ADRS__CMU_WO);
        }

        public u32 cmu__dev_get_fid() {
            return GetWireOutValue(EP_ADRS__FPGA_IMAGE_ID_WO);
        }

        public float cmu__dev_get_temp_C() {
            return (float)GetWireOutValue(EP_ADRS__XADC_TEMP_WO)/1000;
        }

        private u32 cmu_init_sig() {
            u32 ret;
            // set IO path 
            cmu__dev_set_cntl(0x4); // for auto selection
            // get status
            ret = cmu__dev_get_stat();
            return ret;
        }

        private void cmu_set_sig_dacp(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0) {
            // | DACP  | DACP_WI       | 0x064      | wire_in_19 | Control parallel DACP.     | bit[ 0]=o_DAC_D0               |
            // |       |               |            |            |                            | bit[ 1]=o_DAC_D1               |
            // |       |               |            |            |                            | bit[ 2]=o_DAC_D2               |
            // |       |               |            |            |                            | bit[ 3]=o_DAC_D3               |
            // |       |               |            |            |                            | bit[ 4]=o_DAC_D4               |
            // |       |               |            |            |                            | bit[ 5]=o_DAC_D5               |
            // |       |               |            |            |                            | bit[ 6]=o_DAC_D6               |
            // |       |               |            |            |                            | bit[ 7]=o_DAC_D7               |
            // |       |               |            |            |                            | bit[ 8]=o_DAC_D8               |
            // |       |               |            |            |                            | bit[ 9]=o_DAC_D9               |
            // |       |               |            |            |                            | bit[10]=o_DAC_D10              |
            // |       |               |            |            |                            | bit[11]=o_DAC_D11              |
            // |       |               |            |            |                            | bit[12]=o_DAC_MODE1            |
            // |       |               |            |            |                            | bit[13]=o_DAC_MODE2            |
            // |       |               |            |            |                            | bit[14]=o_DAC_POL              |
            // |       |               |            |            |                            | bit[15]=o_DAC_SPDUP            |

            u32 val = (spdup<<15) | (pol<<14) | (mode2<<13) | (mode1<<12) | (val_DACP_b12);
            SetWireInValue(EP_ADRS__DACP_WI, val);
        }
        private void cmu_set_sig_extc(u32 val = 0) {
            // | EXT   | EXT_WI        | 0x068      | wire_in_1A | Control external IO.       | bit[ 0]=o_EXT_BIAS_ON          |
            SetWireInValue(EP_ADRS__EXT_WI, val);
        }
        private void cmu_set_sig_filt(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF) {
            // | FILT  | FILT_WI       | 0x06C      | wire_in_1B | Control Filter.            | bit[ 0]=o_T_0_1                |
            // |       |               |            |            |                            | bit[ 1]=o_T_0_2                |
            // |       |               |            |            |                            | bit[ 2]=o_T_0_4                |
            // |       |               |            |            |                            | bit[ 3]=o_T_0_8                |
            // |       |               |            |            |                            | bit[ 4]=o_T_0_16               |
            // |       |               |            |            |                            | bit[ 5]=o_T_0_32               |
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_T_90_1               |
            // |       |               |            |            |                            | bit[ 9]=o_T_90_2               |
            // |       |               |            |            |                            | bit[10]=o_T_90_4               |
            // |       |               |            |            |                            | bit[11]=o_T_90_8               |
            // |       |               |            |            |                            | bit[12]=o_T_90_16              |
            // |       |               |            |            |                            | bit[13]=o_T_90_32              |
            // |       |               |            |            |                            | bit[14]=NA                     |
            // |       |               |            |            |                            | bit[15]=NA                     |
            // |       |               |            |            |                            | bit[16]=o_6K_B                 |
            // |       |               |            |            |                            | bit[17]=o_60K_B                |
            // |       |               |            |            |                            | bit[18]=o_600K_B               |
            // |       |               |            |            |                            | bit[19]=o_LPF_B                |
            // |       |               |            |            |                            | bit[31:20]=NA                  |
            u32 val = (val_FILT_b4<<16) | (val_T_90_b6<<8) | (val_T_0_b6);
            SetWireInValue(EP_ADRS__FILT_WI, val);
        }

        private u32 cmu__dacq_trig_check(s32 bit_loc) {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TI       | 0x128      | trig_in_4A | Trigger DACQ.              | bit[ 0]=trig_reset             | 
            // |       |               |            |            |                            | bit[ 1]=trig_init              |  
            // |       |               |            |            |                            | bit[ 2]=trig_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TO       | 0x1A8      | trigout_6A | Check DACQ done.           | bit[ 0]=done_reset             | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WO       | 0x0A8      | wireout_2A | Return DACQ status.        | bit[ 0]=ready                  | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            ActivateTriggerIn(EP_ADRS__DACQ_TI, bit_loc); // (u32 adrs, s32 loc_bit)

            //# check done
            u32 cnt_done = 0    ;
            //u32 MAX_CNT  = 20000; 
            bool flag_done;
            while (true) {
            	flag_done = IsTriggered(EP_ADRS__DACQ_TO, (u32)(0x1<<bit_loc));
            	if (flag_done==true)
            		break;
            	cnt_done += 1;
            	if (cnt_done>=MAX_CNT)
            		break;
            }

            u32 ret = GetWireOutValue(EP_ADRS__DACQ_WO);
            return ret;
        }

        private u32 cmu__dacq_init() {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WI       | 0x028      | wire_in_0A | Control DACQ.              | bit[ 0]=enable                 | 
            // |       |               |            |            |                            | bit[31:16]=confuration         |
            // |       |               |            |            |                            | conf=0xFF0B for +/-10V scale   |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_WO       | 0x0A8      | wireout_2A | Return DACQ status.        | bit[ 0]=ready                  | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TI       | 0x128      | trig_in_4A | Trigger DACQ.              | bit[ 0]=trig_reset             | 
            // |       |               |            |            |                            | bit[ 1]=trig_init              |  
            // |       |               |            |            |                            | bit[ 2]=trig_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_TO       | 0x1A8      | trigout_6A | Check DACQ done.           | bit[ 0]=done_reset             | 
            // |       |               |            |            |                            | bit[ 1]=done_init              |  
            // |       |               |            |            |                            | bit[ 2]=done_update            |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            SetWireInValue(EP_ADRS__DACQ_WI,0xFF0B0001);
            return cmu__dacq_trig_check(1);
        }

        private u32 cmu__dacq_update() {
            return cmu__dacq_trig_check(2);
        }

        private u32 cmu_init_anl() {
            u32 ret;
            //// set IO path 
            cmu__dev_set_cntl(0x4); // for auto selection
            // get status
            ret = cmu__dev_get_stat();

            //// initialize DACQ
            cmu__dacq_init();

            return ret;
        }

        private void cmu_set_anl_rr_iv(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) {
            // | RRIV  | RRIV_WI       | 0x054      | wire_in_15 | Control RR and IV.         | bit[ 0]=o_F_R_1                |
            // |       |               |            |            |                            | bit[ 1]=o_F_R_2                |
            // |       |               |            |            |                            | bit[ 2]=o_A1_R_1               |          
            // |       |               |            |            |                            | bit[ 3]=o_A1_R_2               |
            // |       |               |            |            |                            | bit[ 4]=o_F_D_1                |
            // |       |               |            |            |                            | bit[ 5]=o_F_D_2                | 
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_R100                 |
            // |       |               |            |            |                            | bit[ 9]=o_R1K                  |
            // |       |               |            |            |                            | bit[10]=o_R10K                 |
            // |       |               |            |            |                            | bit[11]=o_R100K                |
            // |       |               |            |            |                            | bit[12]=o_R_0                  |
            // |       |               |            |            |                            | bit[13]=o_R_1                  |
            // |       |               |            |            |                            | bit[14]=o_R_2                  |
            // |       |               |            |            |                            | bit[15]=o_R_3                  |
            u32 val = (val_R_N_b4<<12) | (val_R_M_b4<<8) | (val_F_D_b2<<4) | (val_A1_R_b2<<2) | (val_F_R_b2);
            SetWireInValue(EP_ADRS__RRIV_WI, val);
        }

        private void cmu_set_anl_det_mod(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0) {
            // | DET   | DET_WI        | 0x058      | wire_in_16 | Control PH det and MOD.    | bit[ 0]=o_A3_D1                |
            // |       |               |            |            |                            | bit[ 1]=o_A3_D2                |
            // |       |               |            |            |                            | bit[ 2]=o_A3_R1                |
            // |       |               |            |            |                            | bit[ 3]=o_A3_R2                |
            // |       |               |            |            |                            | bit[ 4]=o_PS_0_0_RLY           |
            // |       |               |            |            |                            | bit[ 5]=o_PS90_0_RLY           |
            u32 val = (val_PS_RLY_b2<<4) | (val_A3_R_b2<<2) | (val_A3_D_b2);
            SetWireInValue(EP_ADRS__DET_WI, val);
        }

        private void cmu_set_anl_amp_gain(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0) {
            // | AMP   | AMP_WI        | 0x05C      | wire_in_17 | Control AMP gain.          | bit[ 0]=o_AF1_D                |
            // |       |               |            |            |                            | bit[ 1]=o_AF2_D                |  
            // |       |               |            |            |                            | bit[ 2]=o_AF4_D                |
            // |       |               |            |            |                            | bit[ 3]=o_AM__1_D              |
            // |       |               |            |            |                            | bit[ 4]=o_AM100_D              |
            // |       |               |            |            |                            | bit[ 5]=NA                     |
            // |       |               |            |            |                            | bit[ 6]=NA                     |
            // |       |               |            |            |                            | bit[ 7]=NA                     |
            // |       |               |            |            |                            | bit[ 8]=o_AF1_R                |
            // |       |               |            |            |                            | bit[ 9]=o_AF2_R                |
            // |       |               |            |            |                            | bit[10]=o_AF4_R                |
            // |       |               |            |            |                            | bit[11]=o_AM__1_R              |
            // |       |               |            |            |                            | bit[12]=o_AM100_R              |

            u32 val = (val_AM_R_b2<<11) | (val_AF_R_b3<<8) | (val_AM_D_b2<<3) | (val_AF_D_b3);
            SetWireInValue(EP_ADRS__AMP_WI, val);
        }

        private u32 cmu_get_anl_stat() {
            // | STAT  | STAT_WO       | 0x0DC      | wireout_37 | Return status.             | bit[ 0]=i_UNBAL                |
            // |       |               |            |            |                            | bit[7:2]=NA                    |
            // |       |               |            |            |                            | bit[ 8]=i_A_D                  |
            // |       |               |            |            |                            | bit[ 9]=i_B_D                  |
            // |       |               |            |            |                            | bit[10]=i_C_D                  |
            // |       |               |            |            |                            | bit[11]=i_D_D                  |
            // |       |               |            |            |                            | bit[12]=i_A_R                  |
            // |       |               |            |            |                            | bit[13]=i_B_R                  |
            // |       |               |            |            |                            | bit[14]=i_C_R                  |
            // |       |               |            |            |                            | bit[15]=i_D_R                  |
            return GetWireOutValue(EP_ADRS__STAT_WO);
        }

        private u32 cmu_get_anl_stat__unbal() {
            return (cmu_get_anl_stat() & 0x0001);
        }

        private u32 cmu_get_anl_stat__dcba_d() {
            return (cmu_get_anl_stat()>>8) & 0x000F;
        }

        private u32 cmu_get_anl_stat__dcba_r() {
            return (cmu_get_anl_stat()>>12) & 0x000F;
        }

        private s32 cmu__daq_conv_flt_s32(float val_flt) {
            //// convert float to int (16-bits)
            // note: range -10V ~ +10V in float 
            s32 val_s32;
            float val_flt_MAX = 10;
            float val_flt_MIN = -10;

            // limit
            if (val_flt > val_flt_MAX) val_flt = val_flt_MAX;
            if (val_flt < val_flt_MIN) val_flt = val_flt_MIN;

            // pos scale = 10V / (2^15-1)
            // neg scale = -10V / 2^15
            float scale;
            if (val_flt > 0) scale = (float)( (Math.Pow(2,15)-1)/10.0 );
            else             scale = (float)(  Math.Pow(2,15)   /10.0 );

            val_s32 = (s32)(val_flt * scale);
            return val_s32;
        }

        private float cmu__daq_conv_s32_flt(s32 val_s32) {
            //// convert int (16-bits) to float
            // note: range -10V ~ +10V in float 
            float val_flt;

            // limit
            s32 val_s32_MAX = (s32)(Math.Pow(2,15)-1);
            s32 val_s32_MIN = (s32)(-Math.Pow(2,15));
            if (val_s32 > val_s32_MAX) val_flt = val_s32_MAX;
            if (val_s32 < val_s32_MIN) val_flt = val_s32_MIN;

            // pos scale = 10V / (2^15-1)
            // neg scale = -10V / 2^15
            float scale;
            if (val_s32 > 0) scale = (float)(10.0 / (Math.Pow(2,15)-1) );
            else             scale = (float)(10.0 /  Math.Pow(2,15)    );

            val_flt = (float)(val_s32 * scale);
            return val_flt;
        }


        private void cmu_set_anl_dacq(float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0) {
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_DIN21_WI | 0x02C      | wire_in_0B | Set DACQ_21 data.          | bit[31:16]=DAC2[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC1[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_DIN43_WI | 0x030      | wire_in_0C | Set DACQ_43 data.          | bit[31:16]=DAC4[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC3[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            
            //// convert float to int (16-bits)
            // note: range -10V ~ +10V in float // scale = 10V / (2^15-1)
            s32 val_dac1_s32 = cmu__daq_conv_flt_s32(val_dac1_flt);
            s32 val_dac2_s32 = cmu__daq_conv_flt_s32(val_dac2_flt);
            s32 val_dac3_s32 = cmu__daq_conv_flt_s32(val_dac3_flt);
            s32 val_dac4_s32 = cmu__daq_conv_flt_s32(val_dac4_flt);
            // set dac integer values
            u32 val_dac21 =  (u32)( ((val_dac2_s32&0xFFFF)<<16) | (val_dac1_s32&0xFFFF) );
            u32 val_dac43 =  (u32)( ((val_dac4_s32&0xFFFF)<<16) | (val_dac3_s32&0xFFFF) );
            SetWireInValue(EP_ADRS__DACQ_DIN21_WI, val_dac21);
            SetWireInValue(EP_ADRS__DACQ_DIN43_WI, val_dac43);

            // trigger dac update
            cmu__dacq_update();
        }

        private float cmu_get_anl_dacq(u32 ch_sel = 1) {
            // ch_sel : 1, 2, 3, 4

            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_RDB21_WO | 0x0AC      | wireout_2B | Get DACQ_21 readback.      | bit[31:16]=DAC2[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC1[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+
            // | DACQ  | DACQ_RDB43_WO | 0x0B0      | wireout_2C | Get DACQ_43 readback.      | bit[31:16]=DAC4[15:0]          |
            // |       |               |            |            |                            | bit[15: 0]=DAC3[15:0]          |
            // +-------+---------------+------------+------------+----------------------------+--------------------------------+

            float val_flt;
            u32 ret_val_21 = GetWireOutValue(EP_ADRS__DACQ_RDB21_WO);
            u32 ret_val_43 = GetWireOutValue(EP_ADRS__DACQ_RDB43_WO);
            s16 ret_val_s16;
            s32 ret_val_s32;
            if      (ch_sel == 1) ret_val_s16 = (s16)((ret_val_21>> 0)&0xFFFF);
            else if (ch_sel == 2) ret_val_s16 = (s16)((ret_val_21>>16)&0xFFFF);
            else if (ch_sel == 3) ret_val_s16 = (s16)((ret_val_43>> 0)&0xFFFF);
            else if (ch_sel == 4) ret_val_s16 = (s16)((ret_val_43>>16)&0xFFFF);
            else                  ret_val_s16 = 0;
            //
            ret_val_s32 = (s32)ret_val_s16;
            val_flt = cmu__daq_conv_s32_flt(ret_val_s32);
            return val_flt;
        }


        ////////////////////////////////////////////////////////////

        private u32 hvpgu_LED_CHK    = 0;
        private u32 hvpgu_LATCH_RST2 = 0;
        private u32 hvpgu_LATCH_RST1 = 0;
        private u32 hvpgu_OUT10V_CLS2= 0;
        private u32 hvpgu_OUT10V_CLS1= 0;
        private u32 hvpgu_OUT40V_CLS2= 0;
        private u32 hvpgu_OUT40V_CLS1= 0;
        private u32 hvpgu_CH2_40V    = 0;
        private u32 hvpgu_CH1_40V    = 0; 
        private u32 hvpgu_SLEEP2     = 0;
        private u32 hvpgu_SLEEP1     = 0;

        private u32 hvpgu_OH_DET2     = 0;
        private u32 hvpgu_OH_DET1     = 0;
        private u32 hvpgu_OC_DET2     = 0;
        private u32 hvpgu_OC_DET1     = 0;
       
        public void hvpgu_set_outp() {
            // | HVPGU | HVPGU_WI      | 0x044      | wire_in_11 | Control for HVPGU.         | bit[ 0]=LED_CHK (0 for ON)     |
            // |       |               |            |            |                            | bit[ 1]=NA                     |
            // |       |               |            |            |                            | bit[ 2]=LATCH_RST2             |
            // |       |               |            |            |                            | bit[ 3]=LATCH_RST1             |
            // |       |               |            |            |                            | bit[ 4]=OUT10V_CLS2            |
            // |       |               |            |            |                            | bit[ 5]=OUT10V_CLS1            |
            // |       |               |            |            |                            | bit[ 6]=OUT40V_CLS2            |
            // |       |               |            |            |                            | bit[ 7]=OUT40V_CLS1            |
            // |       |               |            |            |                            | bit[ 8]=CH2_40V                |
            // |       |               |            |            |                            | bit[ 9]=CH1_40V                |
            // |       |               |            |            |                            | bit[10]=SLEEP2                 |
            // |       |               |            |            |                            | bit[11]=SLEEP1                 |
            u32 val =   (hvpgu_LED_CHK     << 0) |
                        (hvpgu_LATCH_RST2  << 2) |
                        (hvpgu_LATCH_RST1  << 3) |
                        (hvpgu_OUT10V_CLS2 << 4) |
                        (hvpgu_OUT10V_CLS1 << 5) |
                        (hvpgu_OUT40V_CLS2 << 6) |
                        (hvpgu_OUT40V_CLS1 << 7) |
                        (hvpgu_CH2_40V     << 8) |
                        (hvpgu_CH1_40V     << 9) |
                        (hvpgu_SLEEP2      <<10) |
                        (hvpgu_SLEEP1      <<11) ;
            SetWireInValue(EP_ADRS__HVPGU_WI, val);
        }

        public void hvpgu_set_outp__LED_CHK    (u32 val) { hvpgu_LED_CHK     = val; }
        public void hvpgu_set_outp__LATCH_RST2 (u32 val) { hvpgu_LATCH_RST2  = val; }
        public void hvpgu_set_outp__LATCH_RST1 (u32 val) { hvpgu_LATCH_RST1  = val; }
        public void hvpgu_set_outp__OUT10V_CLS2(u32 val) { hvpgu_OUT10V_CLS2 = val; }
        public void hvpgu_set_outp__OUT10V_CLS1(u32 val) { hvpgu_OUT10V_CLS1 = val; }
        public void hvpgu_set_outp__OUT40V_CLS2(u32 val) { hvpgu_OUT40V_CLS2 = val; }
        public void hvpgu_set_outp__OUT40V_CLS1(u32 val) { hvpgu_OUT40V_CLS1 = val; }
        public void hvpgu_set_outp__CH2_40V    (u32 val) { hvpgu_CH2_40V     = val; }
        public void hvpgu_set_outp__CH1_40V    (u32 val) { hvpgu_CH1_40V     = val; }
        public void hvpgu_set_outp__SLEEP2     (u32 val) { hvpgu_SLEEP2      = val; }
        public void hvpgu_set_outp__SLEEP1     (u32 val) { hvpgu_SLEEP1      = val; }
        private u32  hvpgu_get_outp__LED_CHK    () { return hvpgu_LED_CHK    ; }
        private u32  hvpgu_get_outp__LATCH_RST2 () { return hvpgu_LATCH_RST2 ; }
        private u32  hvpgu_get_outp__LATCH_RST1 () { return hvpgu_LATCH_RST1 ; }
        private u32  hvpgu_get_outp__OUT10V_CLS2() { return hvpgu_OUT10V_CLS2; }
        private u32  hvpgu_get_outp__OUT10V_CLS1() { return hvpgu_OUT10V_CLS1; }
        private u32  hvpgu_get_outp__OUT40V_CLS2() { return hvpgu_OUT40V_CLS2; }
        private u32  hvpgu_get_outp__OUT40V_CLS1() { return hvpgu_OUT40V_CLS1; }
        private u32  hvpgu_get_outp__CH2_40V    () { return hvpgu_CH2_40V    ; }
        private u32  hvpgu_get_outp__CH1_40V    () { return hvpgu_CH1_40V    ; }
        private u32  hvpgu_get_outp__SLEEP2     () { return hvpgu_SLEEP2     ; }
        private u32  hvpgu_get_outp__SLEEP1     () { return hvpgu_SLEEP1     ; }

        public u32  hvpgu_get_inp__OH_DET2     () { return hvpgu_OH_DET2     ; }
        public u32  hvpgu_get_inp__OH_DET1     () { return hvpgu_OH_DET1     ; }
        public u32  hvpgu_get_inp__OC_DET2     () { return hvpgu_OC_DET2     ; }
        public u32  hvpgu_get_inp__OC_DET1     () { return hvpgu_OC_DET1     ; }


        public u32 hvpgu_get_inp() {
            // | HVPGU | HVPGU_WO      | 0x0C4      | wireout_31 | Return HVPGU status.       | bit[0]=OH_DET2                 |
            // |       |               |            |            |                            | bit[1]=OH_DET1                 |
            // |       |               |            |            |                            | bit[2]=OC_DET2                 |
            // |       |               |            |            |                            | bit[3]=OC_DET1                 |
            // |       |               |            |            |                            | bit[19:16]=w_MTH_SLOT_ID       |
            u32 ret = GetWireOutValue(EP_ADRS__HVPGU_WO);

            // update field
            hvpgu_OH_DET2 = (ret>>0) & 0x01;
            hvpgu_OH_DET1 = (ret>>1) & 0x01;
            hvpgu_OC_DET2 = (ret>>2) & 0x01;
            hvpgu_OC_DET1 = (ret>>3) & 0x01;

            return ret;
        }

        private u32 hvpgu_get_inp__detect() {
            return hvpgu_get_inp()&0x0F;
        }

        private u32 hvpgu_get_inp__slot_id() {
            return (hvpgu_get_inp()>>16)&0x0F;
        }

        ////////////////////////////////////////////////////////////


        ////

        // test var
        private int __test_int = 0;
        
        // test function
        public new static string _test() {
            string ret = SPI_EMUL._test() + ":_class__HVPGU_control_by_eps_";
            return ret;
        }

        public static int __test_HVPGU_control_by_eps() {
            Console.WriteLine(">>>>>> test: __test_HVPGU_control_by_eps");

            // test member
            HVPGU_control_by_eps dev_eps = new HVPGU_control_by_eps();
            dev_eps.__test_int = dev_eps.__test_int - 1;
            Console.WriteLine(">>> EP_ADRS__GROUP_STR = " + dev_eps.EP_ADRS__GROUP_STR);

            // test LAN
            dev_eps.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev_eps.get_IDN());
            Console.WriteLine(dev_eps.eps_enable()); 
            
            //// scan CMU sub boards ... ADDA, SIG(brd_id=0x8), ANL(brd_id=0x9)
            // locate slot and check FID and temperature

            // MSPI setup for SPI emulation : fixed slot location info
            dev_eps.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev_eps.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits
            //dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot);      // for slot location bits

            // check SIG
            //Console.WriteLine(">>> check SIG");
            //dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__SIG);      // for slot location bits
            //Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev_eps.cmu__dev_get_fid()    ));
            //Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   ));
            //Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev_eps.cmu__dev_get_temp_C() ));

            // check ANL
            //Console.WriteLine(">>> check ANL");
            //dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ANL);      // for slot location bits
            //Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev_eps.cmu__dev_get_fid()    ));
            //Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   ));
            //Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev_eps.cmu__dev_get_temp_C() ));

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev_eps.cmu__dev_get_fid()    )); // shared with HVPGU
            //Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   ));
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev_eps.cmu__dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev_eps.cmu__dev_get_fid()    )); // shared with ADDA
            //Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   )); // NA with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev_eps.cmu__dev_get_temp_C() )); // shared with ADDA
            

            // ... test subfunctions ////////////////////////////////////////////////////

            ////
            Console.WriteLine("> S3100-HVPGU board test");
            // may select the slot ...
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits

            ////
            Console.WriteLine(">>> test HVPGU WI ");

            dev_eps.hvpgu_set_outp__LED_CHK    (1);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (0);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(0);
            dev_eps.hvpgu_set_outp__CH2_40V    (1);
            dev_eps.hvpgu_set_outp__CH1_40V    (1);
            dev_eps.hvpgu_set_outp__SLEEP2     (1);
            dev_eps.hvpgu_set_outp__SLEEP1     (1);
            dev_eps.hvpgu_set_outp(); // final update

            dev_eps.hvpgu_set_outp__LED_CHK    (0);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (1);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (1);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(1);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(1);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(1);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(1);
            dev_eps.hvpgu_set_outp__CH2_40V    (0);
            dev_eps.hvpgu_set_outp__CH1_40V    (0);
            dev_eps.hvpgu_set_outp__SLEEP2     (0);
            dev_eps.hvpgu_set_outp__SLEEP1     (0);
            dev_eps.hvpgu_set_outp(); // final update

            dev_eps.hvpgu_set_outp__LED_CHK    (1);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (1);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(1);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(1);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(0);
            dev_eps.hvpgu_set_outp__CH2_40V    (0);
            dev_eps.hvpgu_set_outp__CH1_40V    (1);
            dev_eps.hvpgu_set_outp__SLEEP2     (0);
            dev_eps.hvpgu_set_outp__SLEEP1     (1);
            dev_eps.hvpgu_set_outp(); // final update

            dev_eps.hvpgu_set_outp__LED_CHK    (0);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (0);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(1);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(1);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(0);
            dev_eps.hvpgu_set_outp__CH2_40V    (1);
            dev_eps.hvpgu_set_outp__CH1_40V    (1);
            dev_eps.hvpgu_set_outp__SLEEP2     (0);
            dev_eps.hvpgu_set_outp__SLEEP1     (0);
            dev_eps.hvpgu_set_outp(); // final update

            dev_eps.hvpgu_set_outp__LED_CHK    (1);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (0);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(0);
            dev_eps.hvpgu_set_outp__CH2_40V    (0);
            dev_eps.hvpgu_set_outp__CH1_40V    (0);
            dev_eps.hvpgu_set_outp__SLEEP2     (0);
            dev_eps.hvpgu_set_outp__SLEEP1     (0);
            dev_eps.hvpgu_set_outp(); // final update

            dev_eps.hvpgu_set_outp__LED_CHK    (0);
            dev_eps.hvpgu_set_outp__LATCH_RST2 (0);
            dev_eps.hvpgu_set_outp__LATCH_RST1 (0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT10V_CLS1(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS2(0);
            dev_eps.hvpgu_set_outp__OUT40V_CLS1(0);
            dev_eps.hvpgu_set_outp__CH2_40V    (0);
            dev_eps.hvpgu_set_outp__CH1_40V    (0);
            dev_eps.hvpgu_set_outp__SLEEP2     (0);
            dev_eps.hvpgu_set_outp__SLEEP1     (0);
            dev_eps.hvpgu_set_outp(); // final update

            ////
            Console.WriteLine(">>> test HVPGU WO ");
            Console.WriteLine(string.Format("[OC_DET1,OC_DET2,OH_DET1,OH_DET2] = 0x{0,1:X1} ",dev_eps.hvpgu_get_inp__detect()    )); 
            Console.WriteLine(string.Format("SLOT ID                           = 0x{0,1:X1} ",dev_eps.hvpgu_get_inp__slot_id()   ));


            /////////////////////////////////////////////////////////////

            /* 

            ////
            Console.WriteLine("> S3100-CMU-SUB board test");

            ////
            Console.WriteLine(">>> CMU-SIG setup");
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__SIG);      // for slot location bits

            // CMU-SIG init
            dev_eps.cmu_init_sig(); 
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   ));

            // test DACP_WI
            dev_eps.cmu_set_sig_dacp(0xF35,1,1,1,1); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_eps.cmu_set_sig_dacp(0x3CA,1,0,1,0); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_eps.cmu_set_sig_dacp(0xC35,0,1,0,1); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)
            dev_eps.cmu_set_sig_dacp(); //(u32 val_DACP_b12 = 0, u32 mode1 = 0, u32 mode2 = 0, u32 pol = 0, u32 spdup = 0)

            // test EXT_WI
            dev_eps.cmu_set_sig_extc(1); //(u32 val = 0)
            dev_eps.cmu_set_sig_extc(0); //(u32 val = 0)

            // test FILT_WI
            dev_eps.cmu_set_sig_filt(0x00,0x00,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x01,0x01,0xE); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x02,0x02,0xD); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x04,0x04,0xB); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x08,0x08,0x7); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x10,0x10,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(0x20,0x20,0xF); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)
            dev_eps.cmu_set_sig_filt(); //(u32 val_T_0_b6 = 0, u32 val_T_90_b6 = 0, u32 val_FILT_b4 = 0xF)


            ////
            Console.WriteLine(">>> CMU-ANL setup");
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ANL);      // for slot location bits

            // CMU-ANL init
            dev_eps.cmu_init_anl(); 
            Console.WriteLine(string.Format("CMU_BRD INFO  = 0x{0,8:X8} ",dev_eps.cmu__dev_get_stat()   ));

            // test RRIV_WI
            dev_eps.cmu_set_anl_rr_iv(0x0,0x0,0x0,0x0,0x0) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_eps.cmu_set_anl_rr_iv(0x1,0x0,0x0,0x1,0x8) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_eps.cmu_set_anl_rr_iv(0x2,0x0,0x1,0x2,0x4) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_eps.cmu_set_anl_rr_iv(0x0,0x1,0x2,0x4,0x2) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_eps.cmu_set_anl_rr_iv(0x0,0x2,0x0,0x8,0x1) ; //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 
            dev_eps.cmu_set_anl_rr_iv(); //(u32 val_F_R_b2 = 0, u32  val_A1_R_b2 = 0, u32 val_F_D_b2 = 0, u32 val_R_M_b4 = 0, u32 val_R_N_b4 = 0) 

            // test DET_WI
            dev_eps.cmu_set_anl_det_mod(0x0,0x0,0x0); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_eps.cmu_set_anl_det_mod(0x1,0x0,0x1); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_eps.cmu_set_anl_det_mod(0x1,0x1,0x2); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_eps.cmu_set_anl_det_mod(0x2,0x2,0x1); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_eps.cmu_set_anl_det_mod(0x2,0x0,0x2); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)
            dev_eps.cmu_set_anl_det_mod(); //(u32 val_PS_RLY_b2 = 0, u32 val_A3_R_b2 = 0, u32 val_A3_D_b2 = 0)

            // test AMP_WI
            dev_eps.cmu_set_anl_amp_gain(0x0,0x0,0x0,0x0); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x0,0x1,0x1,0x1); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x1,0x1,0x1,0x2); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x1,0x2,0x0,0x4); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x2,0x2,0x0,0x1); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x2,0x4,0x2,0x2); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain(0x0,0x4,0x2,0x4); //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)
            dev_eps.cmu_set_anl_amp_gain() ; //(u32 val_AM_R_b2 = 0, u32 val_AF_R_b3 = 0, u32 val_AM_D_b2 = 0, u32 val_AF_D_b3 = 0)

            // test STAT_WO
            Console.WriteLine(string.Format("CMU_ANL UNBAL   = 0x{0,8:X8} ",dev_eps.cmu_get_anl_stat__unbal()   ));
            Console.WriteLine(string.Format("CMU_ANL DCBA_D  = 0x{0,8:X8} ",dev_eps.cmu_get_anl_stat__dcba_d()  ));
            Console.WriteLine(string.Format("CMU_ANL DCBA_R  = 0x{0,8:X8} ",dev_eps.cmu_get_anl_stat__dcba_r()  ));

            // test DACQ
            dev_eps.cmu_set_anl_dacq(); //(float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0)

            dev_eps.cmu_set_anl_dacq(0,1,-1,0);
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_eps.cmu_get_anl_dacq(1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_eps.cmu_get_anl_dacq(2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_eps.cmu_get_anl_dacq(3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_eps.cmu_get_anl_dacq(4) ));

            dev_eps.cmu_set_anl_dacq(5,10,-10,-5);
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_eps.cmu_get_anl_dacq(1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_eps.cmu_get_anl_dacq(2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_eps.cmu_get_anl_dacq(3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_eps.cmu_get_anl_dacq(4) ));

            dev_eps.cmu_set_anl_dacq(); //(float val_dac1_flt = 0, float val_dac2_flt = 0, float val_dac3_flt = 0, float val_dac4_flt = 0)
            Console.WriteLine(string.Format("CMU_ANL DACQ_1  = {0} ", dev_eps.cmu_get_anl_dacq(1) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_2  = {0} ", dev_eps.cmu_get_anl_dacq(2) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_3  = {0} ", dev_eps.cmu_get_anl_dacq(3) ));
            Console.WriteLine(string.Format("CMU_ANL DACQ_4  = {0} ", dev_eps.cmu_get_anl_dacq(4) ));

            */

            ////////////////////////////////////////////////////////////////////////

            ////
            Console.WriteLine("> S3100-ADDA board test");
            // may select the slot ...
            dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits

            ////
            Console.WriteLine(">>> ADC setup");

            // spio init for power control
            u32 val;
            //val = dev_eps.sp1_ext_init(1,0,0,0); //(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp);
            //val = dev_eps.sp1_ext_init(1,1,1,1); //(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp);
            val = dev_eps.sp1_ext_init(1,1,1,1,1,1); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));


            // adc power on 
            dev_eps.adc_pwr(1);
            
            // adc enable : 210MHz vs 189MHz
            uint    adc_base_freq_MHz         = 210      ; // MHz
            //uint    adc_base_freq_MHz         = 189      ; // MHz
            //val = dev_eps.adc_enable(); // adc_enable(u32 sel_freq_mode_MHz = 210) // 210MHz
            //val = dev_eps.adc_enable(189); // 189MHz
            val = dev_eps.adc_enable(adc_base_freq_MHz); 
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_enable", val));
            
            // adc reset
            val = dev_eps.adc_reset();
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_reset", val));

            //// adc init 
            // 40 samples for test
            // 210MHz/21   =  10 Msps  or  189MHz/18   =  10.5 Msps
            // adc fixed pattern setup 
            val = dev_eps.adc_init(40, 18, 1);
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_init", val));
            
            // adc fifo reset 
            val = dev_eps.adc_reset_fifo();
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_reset_fifo", val));
            
            // adc update 
            val = dev_eps.adc_update();
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_update", val));
            
            // check fifo in data in logic debugger

            //// DAC DC test
            Console.WriteLine(">>> ADC test run");

            // no setup for DAC

            // adc normal setup and data collection
            //s32 len_adc_data = 10000; // 100s during SPI emulation
            s32 len_adc_data = 100; // 1s during SPI emulation
            u32 adc_sampling_period_count = 21; // 210MHz/21   =  10 Msps
            dev_eps.adc_init(len_adc_data, adc_sampling_period_count, 0); // init with setup parameters
            dev_eps.adc_reset_fifo(); // clear fifo for new data
            dev_eps.adc_update();

            // fifo data read 
            s32[] adc0_s32_buf = new s32[len_adc_data];
            s32[] adc1_s32_buf = new s32[len_adc_data];
            dev_eps.adc_get_fifo(0, len_adc_data, adc0_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            dev_eps.adc_get_fifo(1, len_adc_data, adc1_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);

            // log fifo data into a file
            dev_eps.adc_log("log__adc_buf.py".ToCharArray(), len_adc_data, adc0_s32_buf, adc1_s32_buf); // (char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32)


            //// DAC wave test

            // DAC setup

            ////
            Console.WriteLine(">>> DAC setup");

            // dac init
            Console.WriteLine(">>>>>> DAC power on");
            dev_eps.dac_pwr(1);

            
            Console.WriteLine(">>>>>> DAC init");
            
            //// DAC update period
            double time_ns__dac_update = 5; // 200MHz dac update
            //double time_ns__dac_update = 10; // 100MHz dac update

            //// DAC IC gain and offset // not must
            double DAC_full_scale_current__mA_1 = 25.50;       // for BD2
            double DAC_full_scale_current__mA_2 = 25.45;       // for BD2
            float DAC_offset_current__mA_1      = (float)0.44; // for BD2
            float DAC_offset_current__mA_2      = (float)0.79; // for BD2
            int N_pol_sel_1                     = 0;           // for BD2
            int N_pol_sel_2                     = 0;           // for BD2
            int Sink_sel_1                      = 0;           // for BD2
            int Sink_sel_2                      = 0;           // for BD2
            //
            //double DAC_full_scale_current__mA_1 = 25.50;       // for BD3 //$$ 8.66 ~ 31.66mA
            //double DAC_full_scale_current__mA_2 = 25.62;       // for BD3 //$$ 8.66 ~ 31.66mA
            //float DAC_offset_current__mA_1      = (float)0.58; // for BD3
            //float DAC_offset_current__mA_2      = (float)0.29; // for BD3
            //int N_pol_sel_1                     = 0;           // for BD3
            //int N_pol_sel_2                     = 0;           // for BD3
            //int Sink_sel_1                      = 0;           // for BD3
            //int Sink_sel_2                      = 0;           // for BD3
            //
            
            dev_eps.dac_init(time_ns__dac_update,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2
            ); 


            ////
            Console.WriteLine(">>> DAC pulse setup");

            //// case for sine wave

            // double test_freq_kHz       =  1; 
            // int len_dac_command_points = 500; //80;
            // double amplitude  = 8.0; // no distortion

            // double test_freq_kHz       = 10; 
            // int len_dac_command_points = 500; //80;
            // double amplitude  = 8.0; // no distortion

            // double test_freq_kHz       = 20; 
            // int len_dac_command_points = 500; //80;
            // double amplitude  = 8.0; // no distortion

            // double test_freq_kHz       = 50; 
            // int len_dac_command_points = 500; //80;
            // double amplitude  = 8.0; // no distortion

            //double test_freq_kHz       = 100; 
            //int len_dac_command_points = 500; //40;
            //double amplitude  = 8.0; // no distortion

            // double test_freq_kHz       = 200; 
            // int len_dac_command_points = 500; //40;
            // double amplitude  = 8.0; // no distortion

            double test_freq_kHz       = 500; 
            int len_dac_command_points = 200; //40;
            //double amplitude  = 8.0; // no distortion in diract sample // little distortion in undersample
            //double amplitude  = 4.0; // no distortion
            double amplitude  = 1.0; // test 1V amp


            // double test_freq_kHz       = 1000; 
            // int len_dac_command_points = 100; // 20; // 4
            // //double amplitude  = 8.0; // some distortion
            // double amplitude  = 2.0; // best waveform
            // //double amplitude  = 1.0;

            // double test_freq_kHz       = 2000; 
            // int len_dac_command_points = 50; // 20; // 4
            // //double amplitude  = 8.0; // some distortion
            // double amplitude  = 2.0; // best waveform
            // //double amplitude  = 1.0;

            // double test_freq_kHz       = 5000; 
            // int len_dac_command_points = 20; // 4
            // //double amplitude  = 8.0; // waveform distortion
            // //double amplitude  = 3.0;
            // double amplitude  = 2.0; // best waveform
            // //double amplitude  = 1.0; 



            //// rough wave test

            // 5MHz wave test - rough // note code dutation 10ns may not work.
            //StepTime_1  = new long[]   {   0,    25,   50,     75,  100,    125,  150,    175,   200 }; // ns
            //StepLevel_1 = new double[] { 0.0, 5.657,  8.0,  5.657,  0.0, -5.657, -8.0, -5.657,   0.0 }; // V
            //StepTime_2  = new long[]   {   0,    25,   50,     75,  100,    125,  150,    175,   200 }; // ns
            //StepLevel_2 = new double[] { 8.0, 5.657,  0.0, -5.657, -8.0, -5.657,  0.0,  5.657,   8.0 }; // V
            //
            //StepTime_1  = new long[]   {   0,          50,          100,          150,           200 }; // ns
            //StepLevel_1 = new double[] { 0.0,         8.0,          0.0,         -8.0,           0.0 }; // V
            //StepTime_2  = new long[]   {   0,          50,          100,          150,           200 }; // ns
            //StepLevel_2 = new double[] { 8.0,         0.0,         -8.0,          0.0,           8.0 }; // V

            // 1MHz wave test // note code dutation 10ns may not work.
            //StepTime_1  = new long[]   {   0,   125,  250,    375,  500,    625,  750,    875,  1000 }; // ns
            //StepLevel_1 = new double[] { 0.0, 5.657,  8.0,  5.657,  0.0, -5.657, -8.0, -5.657,   0.0 }; // V
            //StepTime_2  = new long[]   {   0,   125,  250,    375,  500,    625,  750,    875,  1000 }; // ns
            //StepLevel_2 = new double[] { 8.0, 5.657,  0.0, -5.657, -8.0, -5.657,  0.0,  5.657,   8.0 }; // V
            //
            //StepTime_1  = new long[]   {   0,           250,          500,          750,          1000 }; // ns
            //StepLevel_1 = new double[] { 0.0,           8.0,          0.0,         -8.0,           0.0 }; // V
            //StepTime_2  = new long[]   {   0,           250,          500,          750,          1000 }; // ns
            //StepLevel_2 = new double[] { 8.0,           0.0,         -8.0,          0.0,           8.0 }; // V

            // 100kHz wave test
            //StepTime_1  = new long[]   {   0,  1250, 2500,   3750, 5000,   6250, 7500,   8750, 10000 }; // ns
            //StepLevel_1 = new double[] { 0.0, 5.657,  8.0,  5.657,  0.0, -5.657, -8.0, -5.657,   0.0 }; // V
            //StepTime_2  = new long[]   {   0,  1250, 2500,   3750, 5000,   6250, 7500,   8750, 10000 }; // ns
            //StepLevel_2 = new double[] { 8.0, 5.657,  0.0, -5.657, -8.0, -5.657,  0.0,  5.657,   8.0 }; // V

            
            ////
            long[]   StepTime;
            double[] StepLevel;

            //// case base for 10V mode with neg
            StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
            StepLevel = new double[] { 0.0,  0.0,  4.0,  4.0,  8.0,  8.0, -8.0, -8.0,   0.0 }; // V

            //// case base for 10V mode
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,  4.0,  4.0,  8.0,  8.0,  2.3,  2.3,  0.0,  0.0 }; // V

            //// case base
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 10.0, 10.0, 20.0, 20.0,  5.5,  5.5,  0.0,  0.0 }; // V

            //// case 0
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 20.0, 20.0, 40.0, 40.0,   11,   11,  0.0,  0.0 }; // V
            //// case 1
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 10.0, 10.0, 20.0, 20.0,  5.5,  5.5,  0.0,  0.0 }; // V
            //// case 2
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000,  6000,  7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,  5.0,  5.0, 10.0, 10.0,  2.75,  2.75,  0.0,  0.0 }; // V
            //// case 3
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000,   6000,   7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,  2.5,  2.5,  5.0,  5.0,  1.375,  1.375,  0.0,  0.0 }; // V
            //// case 4
            //StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000,   6000,   7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 1.25, 1.25,  2.5,  2.5, 0.6875, 0.6875,  0.0,  0.0 }; // V
            //// case 5
            //StepTime  = new long[]   {   0, 1000,  2000,  3000, 4000, 5000,    6000,    7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 0.625, 0.625, 1.25, 1.25, 0.34375, 0.34375,  0.0,  0.0 }; // V
            //// case 6
            //StepTime  = new long[]   {   0, 1000,   2000,   3000,  4000,  5000,     6000,     7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, 0.3125, 0.3125, 0.625, 0.625, 0.171875, 0.171875,  0.0,  0.0 }; // V

            //// case 7
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0, -0.3125, -0.3125, -0.625, -0.625, -0.171875, -0.171875,  0.0,  0.0 }; // V
            //// case 8
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,  -0.625,  -0.625,  -1.25,  -1.25,  -0.34375,  -0.34375,  0.0,  0.0 }; // V
            //// case 9
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,   -1.25,   -1.25,   -2.5,   -2.5,   -0.6875,   -0.6875,  0.0,  0.0 }; // V
            //// case 10
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,    -2.5,    -2.5,   -5.0,   -5.0,    -1.375,    -1.375,  0.0,  0.0 }; // V
            //// case 11
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,    -5.0,    -5.0,  -10.0,  -10.0,     -2.75,     -2.75,  0.0,  0.0 }; // V
            //// case 12
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,   -10.0,   -10.0,  -20.0,  -20.0,      -5.5,      -5.5,  0.0,  0.0 }; // V
            //// case 13
            //StepTime  = new long[]   {   0, 1000,    2000,    3000,   4000,   5000,      6000,      7000, 8000, 9000 }; // ns
            //StepLevel = new double[] { 0.0,  0.0,   -20.0,   -20.0,  -40.0,  -40.0,     -11.0,     -11.0,  0.0,  0.0 }; // V


            ////
            Console.WriteLine(">>> DAC waveform command generation");
            
            int test_case__wave = 0; // 0 for pulse, 1 for sine

            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1

            if (test_case__wave==1) {
                //double phase_diff = Math.PI/2;  //$$ inductor load in IV balanced circuit (adc0 = voltage, adc1 = -currrent)
                //double phase_diff = Math.PI;    //$$ resistor load in IV balanced circuit
                double phase_diff = -Math.PI/2;   //$$ capacitor   load in IV balanced circuit
                //double phase_diff = 0;          //$$ neg resistor  load in IV balanced circuit
                time_volt_dual_list = dev_eps.dac_gen_wave_cmd(
                    test_freq_kHz, len_dac_command_points, 
                    amplitude, phase_diff);
            } else {
                time_volt_dual_list = dev_eps.dac_gen_pulse_cmd(StepTime, StepLevel);
            }

            // print out and log data
            string buf_time_str = String.Join(", ", time_volt_dual_list.Item1);
            string buf_dac0_str = String.Join(", ", time_volt_dual_list.Item2);
            string buf_dac1_str = String.Join(", ", time_volt_dual_list.Item3);
            // Console.WriteLine("> buf_time_str =" + buf_time_str);
            // Console.WriteLine("> buf_dac0_str =" + buf_dac0_str);
            // Console.WriteLine("> buf_dac1_str =" + buf_dac1_str);


            // dac output ... setup 
            int    output_range                     = 10;   
            //int    time_ns__code_duration          = 10; // 10ns = 100MHz
            int    time_ns__code_duration          = 5; // 5ns = 200MHz
            double load_impedance_ohm              = 1e6;                       
            double output_impedance_ohm            = 50;                        
            double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0;
            double out_offset                      = 0.0;

            int num_repeat_pulses = 4;
            //int num_repeat_pulses = 100; // 100/(500kHz)=0.2ms
            //int num_repeat_pulses = 500; // 500/(500kHz)=1.0ms
            //int num_repeat_pulses = 1000;
            //int num_repeat_pulses = 2000; // 2000/(500kHz)=4ms

            ////
            Console.WriteLine(">>> DAC FIFO data generation");

            Console.WriteLine(">>>>>> DAC0 FIFO data generation");
            var ret__dac0_fifo_dat = dev_eps.dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item2,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            );  

            Console.WriteLine(">>>>>> DAC1 FIFO data generation");
            var ret__dac1_fifo_dat = dev_eps.dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item3,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            ); 

            // print out
            // string buf_code_str = String.Join(", ", ret__dac0_fifo_dat.Item1); // s32[]
            // string buf_dur_str  = String.Join(", ", ret__dac0_fifo_dat.Item2); // u32[]
            // Console.WriteLine("> buf_code_str =" + buf_code_str);
            // Console.WriteLine("> buf_dur_str  =" + buf_dur_str);

            s32[] dac0_code_inc_value__s32_buf = ret__dac0_fifo_dat.Item1;
            u32[] dac0_code_duration__u32_buf  = ret__dac0_fifo_dat.Item2;
            s32[] dac1_code_inc_value__s32_buf = ret__dac1_fifo_dat.Item1;
            u32[] dac1_code_duration__u32_buf  = ret__dac1_fifo_dat.Item2;


            ////
            Console.WriteLine(">>> DAC pulse download");
            
            Console.WriteLine(">>>>>> DAC0 download");
            dev_eps.dac_set_fifo_dat(
                1, num_repeat_pulses,
                dac0_code_inc_value__s32_buf, dac0_code_duration__u32_buf);

            Console.WriteLine(">>>>>> DAC1 download");
            dev_eps.dac_set_fifo_dat(
                2, num_repeat_pulses,
                dac1_code_inc_value__s32_buf, dac1_code_duration__u32_buf);


            ////
            Console.WriteLine(">>> ADC setup");

            // adc normal setup 
            //len_adc_data = 2000; // 0.19047619 @ 10.5MHz
            //len_adc_data = 1200;
            //len_adc_data = 1000; // 0.0952380952 ms @ 10.5MHz
            //len_adc_data = 800; // 0.0761904762 ms @ 10.5MHz
            len_adc_data = 600;
            //len_adc_data = 500; // 0.0476190476 ms @ 10.5MHz
            //len_adc_data = 250; // fit for mosi fifo depth 500

            //adc_sampling_period_count = 14   ; // 210MHz/14   =  15 Msps
            //adc_sampling_period_count = 15   ; // 210MHz/15   =  14 Msps
            adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
            //adc_sampling_period_count = 43   ; // 210MHz/43   =  4.883721 Msps //$$ 116.27907kHz image with 5MHz wave
            //adc_sampling_period_count = 106  ; // 210MHz/106  =  1.98113208 Msps //$$ 18.8679245kHz image with 2MHz wave
            //adc_sampling_period_count = 210  ; // 210MHz/210  =  1 Msps
            //adc_sampling_period_count = 211  ; // 210MHz/211  =  0.995261 Msps //$$ 4.739336kHz image with 1MHz wave
            //adc_sampling_period_count = 2100 ; // 210MHz/210  =  0.1 Msps

            //adc_sampling_period_count =  15  ; // 189MHz/14   =  13.5 Msps
            //adc_sampling_period_count =  18  ; // 189MHz/18   =  10.5 Msps
            //adc_sampling_period_count =  38  ; // 189MHz/38   =  4.973684 Msps //$$ 26.315789kHz image with 5MHz wave
            //adc_sampling_period_count =  95  ; // 189MHz/95  =  1.98947368 Msps //$$  10.5263158kHz image with 2MHz wave
            //adc_sampling_period_count = 190  ; // 189MHz/190  =  0.994737 Msps //$$  5.263158kHz image with 1MHz wave
            //adc_sampling_period_count = 379  ; // 189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave
            
            dev_eps.adc_init(len_adc_data, adc_sampling_period_count); // init with setup parameters
            dev_eps.adc_reset_fifo(); // clear fifo for new data
            

            ////
            Console.WriteLine(">>> DAC pulse trigger linked with ADC trigger");

            //// trigger linked DAC wave and adc update -- method 2
            dev_eps.dac_set_trig(true, true, true); // (bool Ch1, bool Ch2, bool force_adc_trig = false) 

            dev_eps.adc_update_check(); // check done without triggering // vs. adc_update() with triggering
            Console.WriteLine(">>>>>> ADC update done");


            ////
            Console.WriteLine(">>> DAC closed");

            // clear DAC wave
            dev_eps.dac_reset_trig();

            // dac finish
            dev_eps.dac_pwr(0);


            ////
            Console.WriteLine(">>> ADC FIFO read");

            // clear local buffers
            adc0_s32_buf = null;
            adc1_s32_buf = null;
            GC.Collect(); // Collect all generations of memory.

            // fifo data read 
            adc0_s32_buf = new s32[len_adc_data];
            adc1_s32_buf = new s32[len_adc_data];
            Console.WriteLine(">>>>>> ADC0 FIFO read");
            dev_eps.adc_get_fifo(0, len_adc_data, adc0_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            Console.WriteLine(">>>>>> ADC1 FIFO read");
            dev_eps.adc_get_fifo(1, len_adc_data, adc1_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);

            // log fifo data into a file
            Console.WriteLine(">>>>>> write ADC log file");
            dev_eps.adc_log("log__adc_buf__dac.py".ToCharArray(), len_adc_data, adc0_s32_buf, adc1_s32_buf,
                                buf_time_str, buf_dac0_str, buf_dac1_str); // (char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32)


            ////
            Console.WriteLine(">>> ADC closed");

            // adc disable 
            val = dev_eps.adc_disable();
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_disable", val));

            // adc power off
            dev_eps.adc_pwr(0);
            //dev_eps.sp1_ext_init(0,0,0,0); //(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp);
            dev_eps.sp1_ext_init(0,0,0,0,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)


            ////
            Console.WriteLine(">>> DFT calculation");

            if (test_case__wave==1) {

            Console.WriteLine(">>>>>> DFT compute");
            // DFT compute
            //double test_freq_kHz             = 500      ; // kHz
            //int    adc_base_freq_MHz         = 189      ; // MHz
            //int    adc_sampling_period_count = 379      ;
            int    mode_undersampling        = 1        ; // 0 for normal sampling, 1 for undersampling
            //int    mode_undersampling        = 0        ; // 0 for normal sampling, 1 for undersampling
            int    len_dft_coef              = 378    ; // 378*3    ; //$$ must check integer // if failed to try multiple cycle // samples_per_cycle ratio
            int    num_repeat_block_coef     =   2    ;
            int    idx_offset_adc_data       = 100;
            //
            var ret__dft_compute = dev_eps.dft_compute(
                test_freq_kHz            , // dft parameters
                adc_base_freq_MHz        , //
                adc_sampling_period_count, //
                mode_undersampling       , //
                len_dft_coef             , //
                num_repeat_block_coef    , // adc data inputs
                idx_offset_adc_data      , //
                len_adc_data             , //
                adc0_s32_buf             , //
                adc1_s32_buf               //
            );
            
            double[] dft_coef_i_buf = ret__dft_compute.Item1;
            double[] dft_coef_q_buf = ret__dft_compute.Item2;
            len_dft_coef   = ret__dft_compute.Item1.Length; // renew length just in case
            double[] iq_info        = ret__dft_compute.Item3; // {adc0_i, adc0_q, adc1_i, adc1_q}
            double[] cmp_ratio_info = ret__dft_compute.Item4; // {cmp_ratio_i, cmp_ratio_q, cmp_ratio_abs, cmp_ratio_phase, cmp_ratio_angle}


            Console.WriteLine(">>>>>> DFT log generate");
            // report: DFT coeff, ADC data, IQ, complex ratio
            dev_eps.dft_log("log__dft_compute.py".ToCharArray(), 

                test_freq_kHz            , // dft parameters
                adc_base_freq_MHz        , //
                adc_sampling_period_count, //
                mode_undersampling       , //
                
                len_dft_coef, dft_coef_i_buf, dft_coef_q_buf, // dft coef 

                num_repeat_block_coef    , // adc data inputs
                idx_offset_adc_data      , //
                len_adc_data, adc0_s32_buf,   adc1_s32_buf,

                iq_info, cmp_ratio_info    // IQ result
                );
            
            } else {
                //// DFT calculation bypass under pulse test
            }


            //// test finish
            Console.WriteLine(dev_eps.eps_disable());
            dev_eps.scpi_close();

            return dev_eps.__test_int;
        }

    }
    
    //// top class case3 for HVPGU
    //     * macro functions for test or GUI
    public class TOP_HVPGU__EPS_SPI : HVPGU_control_by_eps {
        // 

        //////

        public u32 dev_get_fid() {
            return cmu__dev_get_fid();
        }
        public u32 dev_get_stat() {
            return cmu__dev_get_stat();
        }
        public float dev_get_temp_C() {
            return cmu__dev_get_temp_C();
        }


        public void hvpgu_init() {
            hvpgu_standby();
            hvpgu_reset_latch();
        }

        public void hvpgu_standby() {
            hvpgu_set_outp__LED_CHK    (0);
            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp__OUT10V_CLS2(0);
            hvpgu_set_outp__OUT10V_CLS1(0);
            hvpgu_set_outp__OUT40V_CLS2(0);
            hvpgu_set_outp__OUT40V_CLS1(0);
            hvpgu_set_outp__CH2_40V    (0);
            hvpgu_set_outp__CH1_40V    (0);
            hvpgu_set_outp__SLEEP2     (0);
            hvpgu_set_outp__SLEEP1     (0);
            hvpgu_set_outp(); // final update
        }

        public void hvpgu_reset_latch() {
            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp(); // final update
            
            hvpgu_set_outp__LATCH_RST2 (1);
            hvpgu_set_outp__LATCH_RST1 (1);
            hvpgu_set_outp(); // final update

            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp(); // final update

        }

        public void hvpgu_ready__40V() {

            // 40V-amp control latch reset on
            hvpgu_set_outp__LED_CHK    (1);
            hvpgu_set_outp__LATCH_RST2 (1);
            hvpgu_set_outp__LATCH_RST1 (1);
            hvpgu_set_outp__OUT10V_CLS2(0);
            hvpgu_set_outp__OUT10V_CLS1(0);
            hvpgu_set_outp__OUT40V_CLS2(0);
            hvpgu_set_outp__OUT40V_CLS1(0);
            hvpgu_set_outp__CH2_40V    (0);
            hvpgu_set_outp__CH1_40V    (0);
            hvpgu_set_outp__SLEEP2     (0);
            hvpgu_set_outp__SLEEP1     (0);
            hvpgu_set_outp(); // final update

            // 40V-amp control latch reset off
            hvpgu_set_outp__LED_CHK    (1);
            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp__OUT10V_CLS2(0);
            hvpgu_set_outp__OUT10V_CLS1(0);
            hvpgu_set_outp__OUT40V_CLS2(0);
            hvpgu_set_outp__OUT40V_CLS1(0);
            hvpgu_set_outp__CH2_40V    (0);
            hvpgu_set_outp__CH1_40V    (0);
            hvpgu_set_outp__SLEEP2     (0);
            hvpgu_set_outp__SLEEP1     (0);
            hvpgu_set_outp(); // final update

            // # 40V-amp sleep_n power on
            hvpgu_set_outp__LED_CHK    (1);
            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp__OUT10V_CLS2(0);
            hvpgu_set_outp__OUT10V_CLS1(0);
            hvpgu_set_outp__OUT40V_CLS2(0);
            hvpgu_set_outp__OUT40V_CLS1(0);
            hvpgu_set_outp__CH2_40V    (0);
            hvpgu_set_outp__CH1_40V    (0);
            hvpgu_set_outp__SLEEP2     (1);
            hvpgu_set_outp__SLEEP1     (1);
            hvpgu_set_outp(); // final update

            Delay(3); // # Wait 3ms

            // # 40V-amp 40v relay output close 
            hvpgu_set_outp__LED_CHK    (1);
            hvpgu_set_outp__LATCH_RST2 (0);
            hvpgu_set_outp__LATCH_RST1 (0);
            hvpgu_set_outp__OUT10V_CLS2(0);
            hvpgu_set_outp__OUT10V_CLS1(0);
            hvpgu_set_outp__OUT40V_CLS2(1);
            hvpgu_set_outp__OUT40V_CLS1(1);
            hvpgu_set_outp__CH2_40V    (0);
            hvpgu_set_outp__CH1_40V    (0);
            hvpgu_set_outp__SLEEP2     (1);
            hvpgu_set_outp__SLEEP1     (1);
            hvpgu_set_outp(); // final update

            Delay(3); // # Wait 3ms

        }

        public void hvpgu_read_inp__printout() {
            hvpgu_get_inp(); // update

            Console.WriteLine(string.Format(" OH_DET2 = {0} ", hvpgu_get_inp__OH_DET2() ));
            Console.WriteLine(string.Format(" OH_DET1 = {0} ", hvpgu_get_inp__OH_DET1() ));
            Console.WriteLine(string.Format(" OC_DET2 = {0} ", hvpgu_get_inp__OC_DET2() ));
            Console.WriteLine(string.Format(" OC_DET1 = {0} ", hvpgu_get_inp__OC_DET1() ));
        
        }


        public void adda_pwr_on() {
            
            // spio init for power control : adc power on, dac power on, output relay on

            u32 val;

            // powers on
            val = sp1_ext_init(1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay(1); // 1ms

            // output relay on
            val = sp1_ext_init(1,1,1,1,1,1); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)
            Console.WriteLine(string.Format("{0} = 0x{1,4:X4} ", "sp1_ext_init", val));

            // delay 
            Delay(5); // 5ms

        }

        public void adda_pwr_off() {

            // relay off
            sp1_ext_init(1,1,1,1,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

            // delay 
            Delay(5); // 5ms

            // powers off
            sp1_ext_init(0,0,0,0,0,0); // (u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0)

        }

        public void adda_init(
            s32 len_adc_data = 600, u32 adc_sampling_period_count = 21,
            double time_ns__dac_update = 5,
            double DAC_full_scale_current__mA_1 = 25.47      , 
            double DAC_full_scale_current__mA_2 = 25.47      , 
            float DAC_offset_current__mA_1      = (float)0.61, 
            float DAC_offset_current__mA_2      = (float)0.61, 
            int N_pol_sel_1                     = 0          , 
            int N_pol_sel_2                     = 0          , 
            int Sink_sel_1                      = 0          , 
            int Sink_sel_2                      = 0          
        ) {
            // adc setup
            //s32 len_adc_data = 600; // adc samples
            //u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
            adc_enable(); // 210MHz base freq
            adc_init(len_adc_data, adc_sampling_period_count); // init with setup parameters
            adc_reset_fifo(); // clear fifo for new data

            // dac setup
            //double time_ns__dac_update = 5; // 200MHz dac update
            ////double time_ns__dac_update = 10; // 100MHz dac update
            //double DAC_full_scale_current__mA_1 = 25.50;       // for BD2
            //double DAC_full_scale_current__mA_2 = 25.45;       // for BD2
            //float DAC_offset_current__mA_1      = (float)0.44; // for BD2
            //float DAC_offset_current__mA_2      = (float)0.79; // for BD2
            //int N_pol_sel_1                     = 0;           // for BD2
            //int N_pol_sel_2                     = 0;           // for BD2
            //int Sink_sel_1                      = 0;           // for BD2
            //int Sink_sel_2                      = 0;           // for BD2
            //
            dac_init(time_ns__dac_update,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2
            ); 

        }

        public Tuple<long[], double[], double[]>  adda_setup_pgu_waveform(
            long[] StepTime_ns, double[] StepLevel_V, 
            int    output_range                    = 10,
            int    time_ns__code_duration          = 5,
            double load_impedance_ohm              = 1e6,                       
            double output_impedance_ohm            = 50,                        
            double scale_voltage_10V_mode          = 8.5/10, // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 3.64, // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0,
            double out_offset                      = 0.0,
            int num_repeat_pulses                  = 4   // repeat pulse
        ) {
            //// setup dac output
            //int    output_range                     = 10;   
            ////int    time_ns__code_duration          = 10; // 10ns = 100MHz
            //int    time_ns__code_duration          = 5; // 5ns = 200MHz
            //double load_impedance_ohm              = 1e6;                       
            //double output_impedance_ohm            = 50;                        
            //double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
            //double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64
            //double out_scale                       = 1.0;
            //double out_offset                      = 0.0;
            //// setup repeat
            //int num_repeat_pulses = 4;

            // DAC waveform command generation : time, dac0, dac1
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1
            time_volt_dual_list = dac_gen_pulse_cmd(StepTime_ns, StepLevel_V);


            // DAC0 FIFO data generation
            var ret__dac0_fifo_dat = dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item2,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            );  

            // DAC1 FIFO data generation
            var ret__dac1_fifo_dat = dac_gen_fifo_dat(
                time_volt_dual_list.Item1, time_volt_dual_list.Item3,
                time_ns__code_duration, 
                load_impedance_ohm, output_impedance_ohm,
                scale_voltage_10V_mode, output_range, gain_voltage_10V_to_40V_mode, 
                out_scale, out_offset
            ); 

            s32[] dac0_code_inc_value__s32_buf = ret__dac0_fifo_dat.Item1;
            u32[] dac0_code_duration__u32_buf  = ret__dac0_fifo_dat.Item2;
            s32[] dac1_code_inc_value__s32_buf = ret__dac1_fifo_dat.Item1;
            u32[] dac1_code_duration__u32_buf  = ret__dac1_fifo_dat.Item2;


            ////
            // DAC pulse download
            Console.WriteLine(">>>>>> DAC0 download");
            dac_set_fifo_dat(
                1, num_repeat_pulses,
                dac0_code_inc_value__s32_buf, dac0_code_duration__u32_buf);
            Console.WriteLine(">>>>>> DAC1 download");
            dac_set_fifo_dat(
                2, num_repeat_pulses,
                dac1_code_inc_value__s32_buf, dac1_code_duration__u32_buf);
            Console.WriteLine(">>>>>> download done!");

            return time_volt_dual_list; // for log data
        }

        public void adda_trigger_pgu_output() {
            //// trigger linked DAC wave and adc update 
            dac_set_trig(true, true, true); // (bool Ch1, bool Ch2, bool force_adc_trig = false) 

        }

        public void adda_wait_for_adc_done() {
            adc_update_check(); // check done without triggering // vs. adc_update() with triggering
            Console.WriteLine(">>>>>> ADC update done");
        }
        public void adda_trigger_pgu_off() {
            // clear DAC wave
            dac_reset_trig();
            Console.WriteLine(">>>>>> PGU trigger off");
        }

        public void adda_read_adc_buf(s32 len_adc_data = 600, string buf_time_str = "", string buf_dac0_str = "", string buf_dac1_str ="") {
            
            // fifo data read 
            s32[] adc0_s32_buf = new s32[len_adc_data];
            s32[] adc1_s32_buf = new s32[len_adc_data];
            Console.WriteLine(">>>>>> ADC0 FIFO read");
            adc_get_fifo(0, len_adc_data, adc0_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);
            Console.WriteLine(">>>>>> ADC1 FIFO read");
            adc_get_fifo(1, len_adc_data, adc1_s32_buf); // (u32 ch, s32 num_data, s32[] buf_s32);

            // log fifo data into a file
            Console.WriteLine(">>>>>> write ADC log file");
            adc_log("log__adc_buf__dac.py".ToCharArray(), 
                len_adc_data, adc0_s32_buf, adc1_s32_buf,
                buf_time_str, buf_dac0_str, buf_dac1_str); 

        }

        ////
        public new static string _test() {
            string ret = HVPGU_control_by_eps._test() + ":_class__TOP_HVPGU__EPS_SPI_";
            return ret;
        }
        public static int __test_TOP_HVPGU__EPS_SPI() {
            Console.WriteLine(">>>>>> test: __test_TOP_HVPGU__EPS_SPI");

            // test member
            TOP_HVPGU__EPS_SPI dev = new TOP_HVPGU__EPS_SPI();

            // test LAN
            dev.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable()); 
            
            //// scan sub boards ... ADDA, SIG(brd_id=0x8), ANL(brd_id=0x9)
            // locate slot and check FID and temperature

            // MSPI setup for SPI emulation : fixed slot location info
            dev.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits
            //dev_eps.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot);      // for slot location bits

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with HVPGU
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with ADDA
            
            //$$ force to access ADDA device from SSPI
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_disabled(); 

            // ... test subfunctions ////////////////////////////////////////////////////

            //// HVPGU sequence test
            // seq 0 : initialize HVPGU IO 
            // seq 1 : initialize ADDA
            // seq 2 : setup PGU waveform
            // seq 3 : set HVPGU IO for trigger; read HVPGU status
            // seq 4 : trigger PGU output
            // seq 5 : wait for ADC done
            // seq 6 : reset HVPGU IO; read HVPGU status
            // seq 7 : collect ADC data and finish

            ////
            // seq 0 : initialize HVPGU IO 
            Console.WriteLine(">>> seq 0 : initialize HVPGU IO");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_init();
            dev.hvpgu_read_inp__printout();

            ////
            // seq 1 : initialize ADDA
            Console.WriteLine(">>> seq 1 : initialize ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_pwr_on();
            // adc setup
            s32 len_adc_data              = 600  ; // adc samples
            //s32 len_adc_data              = 250  ; // adc samples ... fit for max spi fifo
            //s32 len_adc_data              = 50   ; // adc samples
            u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
            // dac setup
            //double time_ns__dac_update = 5; // 200MHz dac update
            double time_ns__dac_update = 10; // 100MHz dac update
            double DAC_full_scale_current__mA_1  = 25.50;       // for BD2
            double DAC_full_scale_current__mA_2  = 25.45;       // for BD2
            float  DAC_offset_current__mA_1      = (float)0.44; // for BD2
            float  DAC_offset_current__mA_2      = (float)0.79; // for BD2
            int    N_pol_sel_1                   = 0;           // for BD2
            int    N_pol_sel_2                   = 0;           // for BD2
            int    Sink_sel_1                    = 0;           // for BD2
            int    Sink_sel_2                    = 0;           // for BD2
            //
            dev.adda_init(len_adc_data, adc_sampling_period_count,
                time_ns__dac_update         ,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2                  
                );

            ////
            // seq 2 : setup PGU waveform
            Console.WriteLine(">>> seq 2 : setup PGU waveform");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            //
            long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
            double[] StepLevel_V = new double[] { 0.0,  0.0,  4.0,  4.0,  8.0,  8.0, -8.0, -8.0,   0.0 }; // V
            //
            // setup dac output
            int    output_range                    = 10;   
            int    time_ns__code_duration          = 10; // 10ns = 100MHz
            //int    time_ns__code_duration          = 5; // 5ns = 200MHz
            double load_impedance_ohm              = 1e6;                       
            double output_impedance_ohm            = 50;                        
            double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0;
            double out_offset                      = 0.0;
            // setup repeat
            int num_repeat_pulses = 4;
            //
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1
            //
            time_volt_dual_list= dev.adda_setup_pgu_waveform(
                StepTime_ns, StepLevel_V,
                // setup dac output
                output_range                ,
                time_ns__code_duration      ,
                load_impedance_ohm          ,
                output_impedance_ohm        ,
                scale_voltage_10V_mode      ,
                gain_voltage_10V_to_40V_mode,
                out_scale                   ,
                out_offset                  ,
                // setup repeat
                num_repeat_pulses
            );
            string buf_dac_time_str = String.Join(", ", time_volt_dual_list.Item1);;
            string buf_dac0_str     = String.Join(", ", time_volt_dual_list.Item2);;
            string buf_dac1_str     = String.Join(", ", time_volt_dual_list.Item3);;

            ////
            // seq 3 : set HVPGU IO for trigger; read HVPGU status
            Console.WriteLine(">>> seq 3 : set HVPGU IO for trigger; read HVPGU status");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_ready__40V();
            dev.hvpgu_read_inp__printout();

            ////
            // seq 4 : trigger PGU output
            Console.WriteLine(">>> seq 4 : trigger PGU output");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_trigger_pgu_output();

            ////
            // seq 5 : wait for ADC done
            Console.WriteLine(">>> seq 5 : wait for ADC done");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_wait_for_adc_done();
            dev.adda_trigger_pgu_off();

            dev.Delay(500); // test for LED

            ////
            // seq 6 : reset HVPGU IO; read HVPGU status
            Console.WriteLine(">>> seq 6 : reset HVPGU IO; read HVPGU status");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_standby();
            dev.hvpgu_read_inp__printout();

            ////
            // seq 7 : collect ADC data and finish
            Console.WriteLine(">>> seq 7 : collect ADC data and finish");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_read_adc_buf(len_adc_data, buf_dac_time_str, buf_dac0_str, buf_dac1_str);
            dev.adda_pwr_off();


            //// test finish

            //$$ allow to access ADDA device from test LAN
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_allowed(); 

            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

            return 0;
        }

        public static int __test_TOP_HVPGU_ADDA__ready() {
            Console.WriteLine(">>>>>> test: __test_TOP_HVPGU_ADDA__ready");
            // test member
            TOP_HVPGU__EPS_SPI dev = new TOP_HVPGU__EPS_SPI();

            // open LAN
            dev.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable()); 

            // MSPI setup for SPI emulation : fixed slot location info
            dev.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with HVPGU
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with ADDA

            //$$ force to access ADDA device from SSPI
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_disabled(); 

            //// test seq for HVPGU_ADDA__ready() :
            //// HVPGU-ADDA get-ready sequence
            // seq 0 : initialize HVPGU IO 
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_init();
            dev.hvpgu_read_inp__printout();
            // seq 1 : initialize ADDA
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_pwr_on();
            
            // adc setup
            s32 len_adc_data              = 600  ; // adc samples
            //s32 len_adc_data              = 250  ; // adc samples ... fit for max spi fifo
            //s32 len_adc_data              = 50   ; // adc samples
            //$$ u32 adc_sampling_period_count = 21   ; // 210MHz/21   =  10 Msps
            u32 adc_sampling_period_count = 210000   ; // 210MHz/210000   =  1 ksps

            // dac setup
            //double time_ns__dac_update = 5; // 200MHz dac update
            double time_ns__dac_update = 10; // 100MHz dac update
            double DAC_full_scale_current__mA_1  = 25.50;       // for BD2
            double DAC_full_scale_current__mA_2  = 25.45;       // for BD2
            float  DAC_offset_current__mA_1      = (float)0.44; // for BD2
            float  DAC_offset_current__mA_2      = (float)0.79; // for BD2
            int    N_pol_sel_1                   = 0;           // for BD2
            int    N_pol_sel_2                   = 0;           // for BD2
            int    Sink_sel_1                    = 0;           // for BD2
            int    Sink_sel_2                    = 0;           // for BD2
            //
            dev.adda_init(len_adc_data, adc_sampling_period_count,
                time_ns__dac_update         ,
                DAC_full_scale_current__mA_1,
                DAC_full_scale_current__mA_2,
                DAC_offset_current__mA_1    ,
                DAC_offset_current__mA_2    ,
                N_pol_sel_1                 ,
                N_pol_sel_2                 ,
                Sink_sel_1                  ,
                Sink_sel_2                  
                );
            // seq 2 : ...
            // seq 3 : set HVPGU IO for trigger; read HVPGU status
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_ready__40V();
            dev.hvpgu_read_inp__printout();
            // seq 4 : ...
            // seq 5 : ...
            // seq 6 : ...
            // seq 7 : ...
            

            //// test finish

            //$$ allow to access ADDA device from test LAN
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_allowed(); 

            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

            return 0;
        }
        public static int __test_TOP_HVPGU_ADDA__trigger() {
            Console.WriteLine(">>>>>> test: __test_TOP_HVPGU_ADDA__trigger");
            // test member
            TOP_HVPGU__EPS_SPI dev = new TOP_HVPGU__EPS_SPI();

            // open LAN
            dev.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable()); 

            // MSPI setup for SPI emulation : fixed slot location info
            dev.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with HVPGU
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with ADDA

            //$$ force to access ADDA device from SSPI
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_disabled(); 
            
            //// test seq for HVPGU_ADDA__trigger() :
            //// DAC waveform generation sequence (easy to replace)
            // seq 0 : ...
            // seq 1 : ...
            // seq 2 : setup PGU waveform
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            //

            //// case AA : pr 10000ns, tr 1000ns
            //long[]   StepTime_ns = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 7000, 8000, 10000 }; // ns
            //double[] StepLevel_V = new double[] { 0.0,  0.0,  4.0,  4.0,  8.0,  8.0, -8.0, -8.0,   0.0 }; // V

            //// case BB : pr 1000ns, tr 100ns
            long[]   StepTime_ns  = new long[]   {      0,     50,    150,    450,    550,   1000 }; // ns
            double[] StepLevel_V  = new double[] {  0.000,  0.000,  8.000,  8.000,  0.000,  0.000 }; // V

            //// case CC : 10s long
            // Tdata_usr = [     0, 1000000000, 1100000000, 6000000000, 6100000000, 10000000000, ]
            // Vdata_usr = [ 0.000,  0.000, 20.000, 20.000,  0.000,  0.000, ] 
            //StepTime  = new long[]   {      0, 1000000000, 1100000000, 6000000000, 6100000000, 10000000000 }; // ns
            //StepLevel = new double[] {  0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; // V

            //
            // setup dac output
            int    output_range                    = 10;   
            int    time_ns__code_duration          = 10; // 10ns = 100MHz
            //int    time_ns__code_duration          = 5; // 5ns = 200MHz
            double load_impedance_ohm              = 1e6;                       
            double output_impedance_ohm            = 50;                        
            double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0;
            double out_offset                      = 0.0;
            // setup repeat
            int num_repeat_pulses = 10; // 3, 4, 10
            //
            Tuple<long[], double[], double[]> time_volt_dual_list; // time, dac0, dac1
            //
            time_volt_dual_list= dev.adda_setup_pgu_waveform(
                StepTime_ns, StepLevel_V,
                // setup dac output
                output_range                ,
                time_ns__code_duration      ,
                load_impedance_ohm          ,
                output_impedance_ohm        ,
                scale_voltage_10V_mode      ,
                gain_voltage_10V_to_40V_mode,
                out_scale                   ,
                out_offset                  ,
                // setup repeat
                num_repeat_pulses
            );
            string buf_dac_time_str = String.Join(", ", time_volt_dual_list.Item1);;
            string buf_dac0_str     = String.Join(", ", time_volt_dual_list.Item2);;
            string buf_dac1_str     = String.Join(", ", time_volt_dual_list.Item3);;
            // seq 3 : ...
            // seq 4 : trigger PGU output
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_trigger_pgu_output();
            // seq 5 : ...
            // seq 6 : ...
            // seq 7 : ...


            //// test finish

            //$$ allow to access ADDA device from test LAN
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_allowed(); 

            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

            return 0;
        }
        public static int __test_TOP_HVPGU_ADDA__read_adc_buf() {
            Console.WriteLine(">>>>>> test: __test_TOP_HVPGU_ADDA__read_adc_buf");
            // test member
            TOP_HVPGU__EPS_SPI dev = new TOP_HVPGU__EPS_SPI();

            // open LAN
            dev.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable()); 

            // MSPI setup for SPI emulation : fixed slot location info
            dev.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with HVPGU
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with ADDA

            //$$ force to access ADDA device from SSPI
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_disabled(); 

            //// test seq  HVPGU_ADDA__read_adc_buf() :
            //// ADC data collection sequence 
            // seq 0 : ...
            // seq 1 : ...
            // seq 2 : ...
            // seq 3 : ...
            // seq 4 : ...
            // seq 5 : wait for ADC done
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.adda_wait_for_adc_done();
            dev.adda_trigger_pgu_off();
            // seq 6 : ...
            // seq 7 : collect ADC data and finish
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            s32 len_adc_data              = 600  ; // adc samples
            dev.adda_read_adc_buf(len_adc_data); //(len_adc_data, buf_dac_time_str, buf_dac0_str, buf_dac1_str);
            //dev.adda_pwr_off(); // not needed


            //// test finish

            //$$ allow to access ADDA device from test LAN
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_allowed(); 

            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

            return 0;
        }
        public static int __test_TOP_HVPGU_ADDA__standby() {
            Console.WriteLine(">>>>>> test: __test_TOP_HVPGU_ADDA__standby");
            // test member
            TOP_HVPGU__EPS_SPI dev = new TOP_HVPGU__EPS_SPI();

            // open LAN
            dev.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev.get_IDN());
            Console.WriteLine(dev.eps_enable()); 

            // MSPI setup for SPI emulation : fixed slot location info
            dev.SPI_EMUL__set__use_loc_slot(true);                             // use slot location control
            dev.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel location bits

            // check HVPGU
            Console.WriteLine(">>> check HVPGU");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with HVPGU
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with HVPGU

            // check ADDA ... controlled via class CMU_control_by_eps
            Console.WriteLine(">>> check ADDA");
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            Console.WriteLine(string.Format("FID           = 0x{0,8:X8} ",dev.dev_get_fid()    )); // shared with ADDA
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3}   ",dev.dev_get_temp_C() )); // shared with ADDA

            //$$ force to access ADDA device from SSPI
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_disabled(); 
            
            //// test seq for HVPGU_ADDA__standby() :
            //// HVPGU get-standby sequence 
            // seq 0 : ...
            // seq 1 : ...
            // seq 2 : ...
            // seq 3 : ...
            // seq 4 : ...
            // seq 5 : ...
            // seq 6 : reset HVPGU IO; read HVPGU status
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__HVPGU);      // for slot location bits
            dev.hvpgu_standby();
            dev.hvpgu_read_inp__printout();
            // seq 7 : ...


            //// test finish

            //$$ allow to access ADDA device from test LAN
            dev.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot__ADDA);      // for slot location bits
            dev.dev_set_tlan_allowed(); 

            Console.WriteLine(dev.eps_disable());
            dev.scpi_close();

            return 0;
        }


    }


}

    

