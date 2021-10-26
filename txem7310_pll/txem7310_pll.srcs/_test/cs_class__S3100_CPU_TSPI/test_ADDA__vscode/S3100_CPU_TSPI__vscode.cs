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
using TOP_PGU = TopInstrument.TOP_PGU__EPS_SPI;   // case3 


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
        private int SO_SNDBUF = 2048;
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

        public uint SPI_EMUL__send_frame(uint data_C, uint data_A, uint data_D, uint sel_loc_slots = 0x1FFF, uint sel_loc_groups = 0x0007) {
            u32 ret;
            if (m_use_loc_slot) 
                ret = _test__send_spi_frame(data_C, data_A, data_D, m_sel_loc_slots, m_sel_loc_groups);
            else 
                ret = _test__send_spi_frame(data_C, data_A, data_D, sel_loc_slots, sel_loc_groups);
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
        public long ReadFromPipeOut(uint adrs, ref byte[] data_bytearray, uint dummy_leading_read_pulse = 0) {
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

        public new  long WriteToPipeIn(uint adrs, ref byte[] data_bytearray) {
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

            // set slot location for SPI emulation
            dev_spi_emul.SPI_EMUL__set__use_loc_slot(true); // use fixed slot location
            dev_spi_emul.SPI_EMUL__set__loc_group(__test__.Program.test_loc_spi_group); // for spi channel index
            dev_spi_emul.SPI_EMUL__set__loc_slot (__test__.Program.test_loc_slot); // for slot index 
            
            // open S3100-CPU-BASE with IP address
            dev_spi_emul.my_open(__test__.Program.test_host_ip); // IP address of S3100-CPU-BASE board

            // get IDN string from S3100-CPU-BASE // may check board info // by LAN command
            Console.WriteLine(dev_spi_emul.get_IDN());

            // enable EPS and initialize EPS-SPI ... by LAN command
            Console.WriteLine(dev_spi_emul.eps_enable()); // renew eps_enable ... merged with SPI_EMUL__init

            // may check FPGA die temperature from S3100-CPU-BASE
            Console.WriteLine((float)dev_spi_emul.get_FPGA_TMP_mC()/1000); // by LAN
            

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
            Console.WriteLine(dev_spi_emul.WriteToPipeIn(0x8A, ref datain_bytearray));
            //
            byte[] dataout_bytearray = new byte[16];
            // dummy_leading_read_pulse = 1 for fifo standardi reading mode
            Console.WriteLine(dev_spi_emul.ReadFromPipeOut(0xAA, ref dataout_bytearray, 1)); 
            // compare
            Console.WriteLine(BitConverter.ToString(datain_bytearray));
            Console.WriteLine(BitConverter.ToString(dataout_bytearray));
            bool comp = datain_bytearray.SequenceEqual(dataout_bytearray);
            if (comp ==  false) {
                Console.WriteLine(comp);
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

    public class PGU_control_by_eps : SPI_EMUL
    {
        //## lan command access
        //   not use PGU LAN command string
        //   use EPS command

        //// PGU LAN command string headers //$$ for de bug
        
        private int cnt_call_unintended = 0;

        public string scpi_comm_resp_ss(byte[] cmd_str) {
            // NOP // to replace by EPS
            cnt_call_unintended++;
            Console.WriteLine(">>> NO ONE MUST NOT CALL THIS!" + string.Format("_{0}_", cnt_call_unintended));
            return base.scpi_comm_resp_ss(cmd_str);
        }

        private string cmd_str__PGU_TRIG       = ":PGU:TRIG";
        private string cmd_str__PGU_NFDT0      = ":PGU:NFDT0";
        private string cmd_str__PGU_NFDT1      = ":PGU:NFDT1";
        private string cmd_str__PGU_FDAC0      = ":PGU:FDAT0";
        private string cmd_str__PGU_FDAC1      = ":PGU:FDAT1";
        private string cmd_str__PGU_FRPT0      = ":PGU:FRPT0";
        private string cmd_str__PGU_FRPT1      = ":PGU:FRPT1";
        //private string cmd_str__PGU_MEMR      = ":PGU:MEMR"; // # new ':PGU:MEMR #H00000058 \n'
        //private string cmd_str__PGU_MEMW      = ":PGU:MEMW"; // # new ':PGU:MEMW #H0000005C #H1234ABCD \n'
        

        //// PGU EPS address map info ......
        private string EP_ADRS__GROUP_STR         = "_S3100_PGU_";
        //private u32   EP_ADRS__FPGA_IMAGE_ID_WO   = 0x20;
        //private u32   EP_ADRS__XADC_TEMP_WO       = 0x3A;
        //private u32   EP_ADRS__XADC_VOLT          = 0x3B;
        //private u32   EP_ADRS__TIMESTAMP_WO       = 0x22;
        private u32   EP_ADRS__TEST_IO_MON        = 0x23;
        //private u32   EP_ADRS__TEST_CON_WI        = 0x01;
        //private u32   EP_ADRS__TEST_OUT_WO        = 0x21;
        //private u32   EP_ADRS__TEST_TI            = 0x40;
        //private u32   EP_ADRS__TEST_TO            = 0x60;
        //private u32   EP_ADRS__BRD_CON_WI         = 0x03;
        //private u32   EP_ADRS__MCS_SETUP_WI       = 0x19;
        //private u32   EP_ADRS__MSPI_EN_CS_WI      = 0x16;
        //private u32   EP_ADRS__MSPI_CON_WI        = 0x17;
        //private u32   EP_ADRS__MSPI_FLAG_WO       = 0x24;
        //private u32   EP_ADRS__MSPI_TI            = 0x42;
        //private u32   EP_ADRS__MSPI_TO            = 0x62;
        private u32   EP_ADRS__MEM_FDAT_WI        = 0x12;
        private u32   EP_ADRS__MEM_WI             = 0x13;
        private u32   EP_ADRS__MEM_TI             = 0x53;
        private u32   EP_ADRS__MEM_TO             = 0x73;
        private u32   EP_ADRS__MEM_PI             = 0x93;
        private u32   EP_ADRS__MEM_PO             = 0xB3;
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

        //// common functions
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


        //// PGU subfunctions with EPS commands
        private void enable_mcs_ep() {
            //...
            eps_enable();
        }

        private void disable_mcs_ep() {
            //...
            eps_disable();
        }

        // SPIO ......
        
        private u32 pgu_spio_send_spi_frame(u32 frame_data) {
            //# write control 
            SetWireInValue(EP_ADRS__SPIO_WI, frame_data);  //# (ep,val,mask)

            //# trig spi frame
            //#   wire w_trig_SPIO_SPI_frame = w_SPIO_TI[1];
            ActivateTriggerIn(EP_ADRS__SPIO_TI, 1); //# (ep,bit) 
            
            //# check spi frame done
            //#   assign w_SPIO_WO[25] = w_done_SPIO_SPI_frame;
            u32 cnt_done = 0    ;
            u32 MAX_CNT  = 20000;
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
        private u32 pgu_sp_1_reg_read_b16(u32 reg_adrs_b8) {
            u32 val_b16    = 0;
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 1; // read
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return pgu_spio_send_spi_frame(framedata);
        }
        private u32 pgu_sp_1_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
            //
            u32 CS_id      = 1;
            u32 pin_adrs_A = 0; 
            u32 R_W_bar    = 0; // write
            u32 reg_adrs_A = reg_adrs_b8;
            //#
            u32 framedata = (CS_id<<28) + (pin_adrs_A<<25) + (R_W_bar<<24) + (reg_adrs_A<<16) + val_b16;
            //#
            return pgu_spio_send_spi_frame(framedata);
        }

        private void pgu_spio_ext_pwr_led(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 pwr_p5v_dac = 0, u32 pwr_n5v_dac= 0) {
            //...
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
            pgu_sp_1_reg_write_b16(0x00, dir_read & 0xF3F0);
            
            //# set IO for SP1 PA[3:2] and SP1 PB[3:0]
            u32 val = (lat_read & 0xF3F0) | ( (led<<3) + (pwr_dac<<2) + (pwr_adc<<1) + (pwr_amp<<0) ) | ( (pwr_n5v_dac<<11) + (pwr_p5v_dac<<10));
            pgu_sp_1_reg_write_b16(0x12,val);
        }

        private u32 pgu_spio_ext_pwr_led_readback() {
            //...
            u32 lat_read;
            //# read output Latch
            lat_read = pgu_sp_1_reg_read_b16(0x14);
            //return lat_read & 0x000F;
            return lat_read & 0xFFFF; // 16 bit all
        }

        private void pgu_spio_ext_relay (u32 sw_rl_k1, u32 sw_rl_k2) {
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

        private u32  pgu_spio_ext_relay_readback() {
            //
            u32 lat_read;
            //
            //# read output Latch // where (SPA,SPB)
            lat_read = pgu_sp_1_reg_read_b16(0x14);
            //
            return (lat_read & 0x0300)>>8; //$$ {SW_RL_K2,SW_RL_K1}
        }

        // AUX on SPIO ...

        private bool IsBypassed__AUX_IO = false; 
        // bypass control for those functions: 
        //  pgu_spio_ext__aux_init()
        //  pgu_spio_ext__aux_idle()
        //  pgu_spio_ext__aux_send_spi_frame()

        public void pgu_aux_io_bypass_on() {
            IsBypassed__AUX_IO = true;
        } 

        public void pgu_aux_io_bypass_off() {
            IsBypassed__AUX_IO = false;
        } 

        public bool pgu_aux_io_is_bypassed() {
            return IsBypassed__AUX_IO;
        } 

        private u32 pgu_spio_ext__aux_init() {
        	u32 dir_read;
        	u32 lat_read;

            if (IsBypassed__AUX_IO==true) return 0; // bypass

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

        private void pgu_spio_ext__aux_idle() {
        	u32 lat_read;

            if (IsBypassed__AUX_IO==true) return; // bypass

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

            return;
        }

        private void pgu_spio_ext__aux_out (u32 val_b4) {
        	u32 lat_read;
        	// read previous value
        	lat_read = pgu_sp_1_reg_read_b16(0x14);
        	// update new value
        	lat_read = lat_read & 0xFF0F;
        	lat_read = lat_read | ( (val_b4&0x000F)<<4 );
        	// update latch
        	pgu_sp_1_reg_write_b16(0x14,lat_read);
        }

        private u32 pgu_spio_ext__aux_in () {
        	u32 port_read;
        	// read gpio
        	port_read = pgu_sp_1_reg_read_b16(0x12);
        	// find value
        	return (port_read & 0x00F0 )>>4;
        }


        private u32 pgu_spio_ext__aux_send_spi_frame (u32 R_W_bar, u32 reg_adrs_b8, u32 val_b16) {
            u32 val_recv = 0;
            u32 framedata = 0x00000000;
            u32 f_count;
            u32 val;

            if (IsBypassed__AUX_IO==true) return 0; // bypass

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

            }

            //// frame stop
            // AUX_CS_B, AUX_SCLK, AUX_MOSI,0 = 1,0,0,0
            pgu_spio_ext__aux_out(0x8);
            // 
            return val_recv & 0x0000FFFF;
        }

        private void pgu_spio_ext__aux_reg_write_b16(u32 reg_adrs_b8, u32 val_b16) {
            //pgu_spio_ext__aux_init(); //$$ to check 
            pgu_spio_ext__aux_send_spi_frame(0, reg_adrs_b8, val_b16);
            pgu_spio_ext__aux_idle();
        }

        private u32  pgu_spio_ext__aux_reg_read_b16(u32 reg_adrs_b8) {
            u32 ret;
            //pgu_spio_ext__aux_init(); //$$ to check 
            ret = pgu_spio_ext__aux_send_spi_frame(1, reg_adrs_b8, 0x0000);
            pgu_spio_ext__aux_idle();
            return ret;
        }

        private u32  pgu_spio_ext__read_aux_IO_CON  () {
	        return pgu_spio_ext__aux_reg_read_b16(0x0A);
        }

        private u32  pgu_spio_ext__read_aux_IO_OLAT () {
        	return pgu_spio_ext__aux_reg_read_b16(0x14);
        }
        private u32  pgu_spio_ext__read_aux_IO_DIR  () {
        	return pgu_spio_ext__aux_reg_read_b16(0x00);
        }
        private u32  pgu_spio_ext__read_aux_IO_GPIO () {
        	return pgu_spio_ext__aux_reg_read_b16(0x12);
        }
        //
        private void pgu_spio_ext__send_aux_IO_CON  (u32 val_b16) {
        	pgu_spio_ext__aux_reg_write_b16(0x0A, val_b16);
        }
        private void pgu_spio_ext__send_aux_IO_OLAT (u32 val_b16) {
        	pgu_spio_ext__aux_reg_write_b16(0x14, val_b16);
        }
        private void pgu_spio_ext__send_aux_IO_DIR  (u32 val_b16) {
        	pgu_spio_ext__aux_reg_write_b16(0x00, val_b16);
        }
        private void pgu_spio_ext__send_aux_IO_GPIO (u32 val_b16) {
        	pgu_spio_ext__aux_reg_write_b16(0x12, val_b16);
        }


        // CLKD control ...
        private u32  pgu_clkd_init() {
            //
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__CLKD_TI, 0);
            ActivateTriggerIn(EP_ADRS__CLKD_TI, 0);
            //
            u32 cnt_done = 0    ;
            u32 MAX_CNT  = 20000;
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
            u32 MAX_CNT  = 20000;
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


        // DACX DAC IC control ...

        // dacx_init
        private u32  pgu_dacx_init() { // EP access
            //
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACX_TI, 0);
            ActivateTriggerIn(EP_ADRS__DACX_TI, 0);
            //
            u32 cnt_done = 0    ;
            u32 MAX_CNT  = 20000;
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
            status_pll = GetWireOutValue(EP_ADRS__TEST_IO_MON, 0x07000000);
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
            u32 MAX_CNT  = 20000;
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

        private u32  pgu_dacx_cal_input_dtap() {
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
            pgu_dac0_reg_write_b8(0x05, (u32)val_0_center_new);
            pgu_dac1_reg_write_b8(0x05, (u32)val_1_center_new);

            xil_printf(">>> DAC input delay taps are chosen at each center\r\n");

            return 0;
        }

        // DACZ pattern gen control ...
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

        //// EEPROM control ...

        private u32  eeprom_send_frame_ep (u32 MEM_WI_b32, u32 MEM_FDAT_WI_b32) {
            //  def eeprom_send_frame_ep (MEM_WI, MEM_FDAT_WI):
            //  	## //// end-point map :
            //  	## // wire [31:0] w_MEM_WI      = ep13wire;
            //  	## // wire [31:0] w_MEM_FDAT_WI = ep12wire;
            //  	## // wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;
            //  	## // wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;
            //  	## // wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr; 
            //  	## // wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; 	

            bool ret_bool;
            s32 cnt_loop;

            SetWireInValue(EP_ADRS__MEM_WI,      MEM_WI_b32); 
            SetWireInValue(EP_ADRS__MEM_FDAT_WI, MEM_FDAT_WI_b32); 
            //  	# clear TO
            GetTriggerOutVector(EP_ADRS__MEM_TO);
            //  	# act TI
            ActivateTriggerIn(EP_ADRS__MEM_TI, 2);
            cnt_loop = 0;
            while (true) {
                ret_bool = IsTriggered(EP_ADRS__MEM_TO, 0x04);
                if (ret_bool==true) {
                    break;
                }
                cnt_loop += 1;
            }
            if (cnt_loop>0) xil_printf("cnt_loop = %d \r\n", cnt_loop);
            return 0;
        }

        private u32  eeprom_send_frame (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8) {
            u32 ret;
            u32 set_data_WI = ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
            u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
            ret = eeprom_send_frame_ep (set_data_WI, set_data_FDAT_WI);
            return ret;
        }

        private void eeprom_reset_fifo() {
            ActivateTriggerIn(EP_ADRS__MEM_TI, 1);
        }

        private u16 eeprom_read_fifo (u16 num_bytes_DAT_b16, u8[] buf_dataout) {
            u16 ret;
           	//dcopy_pipe8_to_buf8 (ADRS__MEM_PO, buf_dataout, num_bytes_DAT_b16); // (u32 adrs_p8, u8 *p_buf_u8, u32 len)
            // read 32-bit width pipe and collect 8-bit width data
            
            u32 adrs = EP_ADRS__MEM_PO;
            u8[] buf_pipe = new u8[num_bytes_DAT_b16*4]; // *4 for 32-bit pipe 
            
            ret = (u16)ReadFromPipeOut(adrs, ref buf_pipe);

            // collect and copy data : buf => buf_dataout
            s32 ii;
            s32 tmp;
            for (ii=0;ii<num_bytes_DAT_b16;ii++) {
                tmp = BitConverter.ToInt32(buf_pipe, ii*4); // read one pipe data every 4 bytes
                buf_dataout[ii] = (u8) (tmp & 0x000000FF); 
            }

            return ret;
        }

        private u16 eeprom_write_fifo (u16 num_bytes_DAT_b16, u8[] buf_datain) {
            u16 ret;
            // memory copy from 8-bit width buffer to 32-bit width pipe // ADRS_BASE_MHVSU or MCS_EP_BASE
            //dcopy_buf8_to_pipe8  (buf_datain, ADRS__MEM_PI, num_bytes_DAT_b16); //  (u8 *p_buf_u8, u32 adrs_p8, u32 len)

            u32 adrs = EP_ADRS__MEM_PI;
            
            //u32[] buf_pipe_data = new u32[buf_datain.Length];
            u32[] buf_pipe_data = Array.ConvertAll(buf_datain, x => (u32)x );

            u8[] buf_pipe = buf_pipe_data.SelectMany(BitConverter.GetBytes).ToArray();

            ret = (u16)WriteToPipeIn(adrs, ref buf_pipe);

            return ret;
        }


        private u16 eeprom_read_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_dataout) {
            
            //buf_dataout[0] = (char)0x01; // test
            //buf_dataout[1] = (char)0x02; // test
            //buf_dataout[2] = (char)0x03; // test
            //buf_dataout[3] = (char)0x04; // test

            //byte[] buf_bytearray = BitConverter.GetBytes(0xFEDCBA98); // test
            //buf_bytearray.CopyTo(buf_dataout, 0); //test

            u16 ret;

            eeprom_reset_fifo();

            u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
            u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);

            //  	## // CMD_READ__03 
            //  	eeprom_send_frame (CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT)
            eeprom_send_frame (0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);

            ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
            
            return ret;
        }

        private void eeprom_write_enable() {
            //  	## // CMD_WREN__96 
            //  	print('\n>>> CMD_WREN__96')
            //  	eeprom_send_frame (CMD=0x96, con_disable_SBP=1)
        	eeprom_send_frame (0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
        }

        private u16 eeprom_write_data_16B (u16 ADRS_b16, u16 num_bytes_DAT_b16) {
            eeprom_write_enable();
            u8 ADL = (u8) ((ADRS_b16>>0) & 0x00FF);
            u8 ADH = (u8) ((ADRS_b16>>8) & 0x00FF);
            //  	
            //  	## // CMD_WRITE_6C 
            //  	eeprom_send_frame (CMD=0x6C, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT, con_disable_SBP=1)
        	eeprom_send_frame (0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
        	return num_bytes_DAT_b16;
        }

        private u16 eeprom_write_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8[] buf_datain) {
            u16 ret = num_bytes_DAT_b16;

            eeprom_reset_fifo();

            if (num_bytes_DAT_b16 <= 16) {
                eeprom_write_fifo (num_bytes_DAT_b16, buf_datain);
                eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16);
                ret = 0; // sent all
            }
            else {
                eeprom_write_fifo (num_bytes_DAT_b16, buf_datain);

                while (true) {
                    eeprom_write_data_16B (ADRS_b16, 16);
                    //
                    ADRS_b16          += 16;
                    ret               -= 16;
                    //
                    if (num_bytes_DAT_b16 <= 16) {
                        eeprom_write_data_16B (ADRS_b16, num_bytes_DAT_b16);
                        ret            = 0;
                        break;
                    }
                }

            }
            return ret;
        }
        

        //$$ PWR access

        public string pgu_pwr__on() {
            //## string ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " ON\n")); // equivalent PGU LAN command
            
            string ret = "OK\n"; // or "NG\n"
            u32 val;
            u32 val_s0;
            u32 val_s1;

            // force to enable LAN endpoint
            enable_mcs_ep(); // just in case // not necessary in S3100-PGu

            // read power control status
            val = pgu_spio_ext_pwr_led_readback();
            val_s0 = (val>>0) & 0x0001;
            val_s1 = (val>>1) & 0x0001;

            // DAC power on // without changing pwr_adc and pwr_amp
            pgu_spio_ext_pwr_led(1, 1, val_s1, val_s0, 1, 1); // (led, pwr_dac, pwr_adc, pwr_amp, pwr_p5v_dac, pwr_n5v_dac)

            // power stability delay 1ms or more.
            Delay(1);

            // DACX fpga pll reset
            pgu_dacx_fpga_pll_rst(1, 1, 1);

            // CLKD init
            pgu_clkd_init();

            // CLKD setup
            pgu_clkd_setup(2000); // preset 200MHz

            // DACX init 
            pgu_dacx_init();

            // DACX fpga pll run
            pgu_dacx_fpga_pll_rst(0, 0, 0);
            pgu_dacx_fpga_clk_dis(0, 0);

            // update input delay tap inside DAC IC
            pgu_dacx_cal_input_dtap();

            return ret;
        }

        public string pgu_pwr__off() {
            //return scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " OFF\n")); // equivalent PGU LAN command

            string ret = "OK\n"; // or "NG\n"
            // DAC power off
            pgu_spio_ext_pwr_led(0, 0, 0, 0, 0, 0);

            // TODO: consider pll off by reset  vs  clock disable
            //pgu_dacx_fpga_pll_rst(1, 1, 1); // DAC pll off by reset
            pgu_dacx_fpga_clk_dis(1, 1); // DAC clock output disable

            return ret;
        }

        //$$ OUTPUT access

        public string pgu_output__on() {
            //return scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " ON\n")); // equivalent PGU LAN command

            string ret = "OK\n"; // or "NG\n"
            // local var
            u32 val;
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
            pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 1, val_s10, val_s11); // pwr_amp on

            //$$ relay control for PGU-CPU-S3000 or PGU-S3100
            pgu_spio_ext_relay(1,1); //(u32 sw_rl_k1, u32 sw_rl_k2) // relay on

            return ret;
        }

        public string pgu_output__off() {
            //return scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " OFF\n")); // equivalent PGU LAN command

            string ret = "OK\n"; // or "NG\n"
            // local var
            u32 val;
            u32 val_s1;
            u32 val_s2;
            u32 val_s3;
            u32 val_s10;
            u32 val_s11;
            // read power status 
            val = pgu_spio_ext_pwr_led_readback();
            val_s1  = (val>> 1) & 0x0001;
            val_s2  = (val>> 2) & 0x0001;
            val_s3  = (val>> 3) & 0x0001;
            val_s10 = (val>>10) & 0x0001;
            val_s11 = (val>>11) & 0x0001;
            // output power on
            pgu_spio_ext_pwr_led(val_s3, val_s2, val_s1, 0, val_s10, val_s11); // pwr_amp off

            //$$ relay control for PGU-CPU-S3000 or PGU-S3100
            pgu_spio_ext_relay(0,0); //(u32 sw_rl_k1, u32 sw_rl_k2) // relay off

            return ret;
        }

        //$$ AUX IO access

        public string pgu_aux_con__read()
        {
            //string ret_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_CON + "?\n")); // equivalent PGU LAN command

            string ret_str;
            u32 val = pgu_spio_ext__read_aux_IO_CON();
            //$$xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
            ret_str = string.Format("#H{0,4:X4}\n", val);
            
            return ret_str;
        }


        public string pgu_aux_olat__read()
        {
            //string ret_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_OLAT + "?\n")); // equivalent PGU LAN command

            string ret_str;
            u32 val = pgu_spio_ext__read_aux_IO_OLAT();
            //$$xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
            ret_str = string.Format("#H{0,4:X4}\n", val);

            return ret_str;
        }

        public string pgu_aux_dir__read()
        {
            //string ret_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_DIR + "?\n")); // equivalent PGU LAN command

            string ret_str;
            u32 val = pgu_spio_ext__read_aux_IO_DIR();
            //$$xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
            ret_str = string.Format("#H{0,4:X4}\n", val);

            return ret_str;
        }

        public string pgu_aux_gpio__read()
        {
            //string ret_str = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_GPIO + "?\n")); // equivalent PGU LAN command

            string ret_str;
            u32 val = pgu_spio_ext__read_aux_IO_GPIO();
            //$$xil_sprintf((char*)rsp_str,"#H%04X\n",(unsigned int)val); // '\0' added. ex "H00000002\n"
            ret_str = string.Format("#H{0,4:X4}\n", val);

            return ret_str;
        }

        public string pgu_aux_con__send(uint val_b16)
        {
            //string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret = "OK\n";

            //string PGU_AUX_CON = Convert.ToString(cmd_str__PGU_AUX_CON + val_b16_str);
            //byte[] PGU_AUX_CON_CMD = Encoding.UTF8.GetBytes(PGU_AUX_CON);
            //ret = scpi_comm_resp_ss(PGU_AUX_CON_CMD);

            pgu_spio_ext__send_aux_IO_CON(val_b16);

            return ret;
        }

        public string pgu_aux_olat__send(uint val_b16)
        {
            //string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret = "OK\n";

            //string PGU_AUX_OLAT = Convert.ToString(cmd_str__PGU_AUX_OLAT + val_b16_str);
            //byte[] PGU_AUX_OLAT_CMD = Encoding.UTF8.GetBytes(PGU_AUX_OLAT);
            //ret = scpi_comm_resp_ss(PGU_AUX_OLAT_CMD);

            pgu_spio_ext__send_aux_IO_OLAT(val_b16);

            return ret;
        }

        public string pgu_aux_dir__send(uint val_b16)
        {
            //string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret = "OK\n";

            //string PGU_AUX_DIR = Convert.ToString(cmd_str__PGU_AUX_DIR + val_b16_str);
            //byte[] PPGU_AUX_DIR_CMD = Encoding.UTF8.GetBytes(PGU_AUX_DIR);
            //ret = scpi_comm_resp_ss(PPGU_AUX_DIR_CMD);

            pgu_spio_ext__send_aux_IO_DIR(val_b16);

            return ret;
        }


        public string pgu_aux_gpio__send(uint val_b16)
        {
            //string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret = "OK\n";

            //string PGU_AUX_GPIO = Convert.ToString(cmd_str__PGU_AUX_GPIO + val_b16_str);
            //byte[] PGU_AUX_GPIO_CMD = Encoding.UTF8.GetBytes(PGU_AUX_GPIO);
            //ret = scpi_comm_resp_ss(PGU_AUX_GPIO_CMD);

            pgu_spio_ext__send_aux_IO_GPIO(val_b16);

            return ret;
        }

        //$$ PGU control access

        public string pgu_trig__on_log(bool Ch1, bool Ch2, string LogFileName) {
            string ret = "OK\n";

            //$$ if      (val == 0x00000001) val = 0x000000010;
            //$$ else if (val == 0x00010000) val = 0x00000020;
            //$$ else if (val == 0x00010001) val = 0x00000030;
            //$$ else                        val = 0x00000000;
            //$$ write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
            //$$ activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);

            u32 val;
            if (Ch1 && Ch2)
                val = 0x00000030;
            else if ( (Ch1 == true) && (Ch2 == false) )
                val = 0x000000010;
            else
                val = 0x00000020;
            //
            //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, val);
            //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI, 12); // trig location
            pgu_dacz_dat_write(val, 12); // trig control

            // for log data
            string PGU_TRIG_ON;
            if (Ch1 && Ch2)
                PGU_TRIG_ON = Convert.ToString(cmd_str__PGU_TRIG + " #H00010001 \n");
            else if ( (Ch1 == true) && (Ch2 == false) )
                PGU_TRIG_ON = Convert.ToString(cmd_str__PGU_TRIG + " #H00000001 \n");
            else
                PGU_TRIG_ON = Convert.ToString(cmd_str__PGU_TRIG + " #H00010000 \n");
            //
            //$$byte[] PGU_TRIG_ON_CMD = Encoding.UTF8.GetBytes(PGU_TRIG_ON);
            //$$ret = scpi_comm_resp_ss(PGU_TRIG_ON_CMD);
            //
            // log
            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_TRIG_ON); 

            return ret;
        }
        
        public string pgu_trig__off()
        {
            string ret = "OK\n";
            u32 val = 0x00000000;
            //SetWireInValue   (EP_ADRS__DACZ_DAT_WI, val);
            //ActivateTriggerIn(EP_ADRS__DACZ_DAT_TI, 12); // trig location
            pgu_dacz_dat_write(val, 12); // trig control
            return ret;
            //$$string PGU_TRIG_OFF = Convert.ToString(cmd_str__PGU_TRIG + " #H00000000 \n");
            //$$byte[] cmd_str__PGU_TRIG_OFF_CMD = Encoding.UTF8.GetBytes(PGU_TRIG_OFF);
            //$$return scpi_comm_resp_ss(cmd_str__PGU_TRIG_OFF_CMD);
        }

        public string pgu_nfdt__send_log(int Ch, long fifo_data, string LogFileName) {
            // send the number of fifo_data
            string ret = "OK\n";

            u32 val = (u32)fifo_data;

            //$$//// dac0 fifo reset 
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000040, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // w_rst_dac0_fifo
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // clear bit
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // clear bit again
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$// on dac0 fifo length set
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00001000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // cid_adrs for r_cid_reg_dac0_num_ffdat
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);                            // w_trig_cid_adrs_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);        // data for cid_data
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_data_wr

            //$$//// dac1 fifo reset 
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000080, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // w_rst_dac1_fifo
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // clear bit
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000000, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // clear bit again
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 12); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_ctrl_wr
            //$$// on dac1 fifo length set
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00001010, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask); // cid_adrs for r_cid_reg_dac1_num_ffdat
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);                            // w_trig_cid_adrs_wr
            //$$write_mcs_ep_wi   (MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);        // data for cid_data
            //$$activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);                           // w_trig_cid_data_wr 

            if (Ch == 1) { // Ch == 1 or DAC0
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

            // for log data
            string len_fifo_data_str = string.Format(" #H{0,8:X8}", fifo_data);
            string PGU_NFDT__;
            //
            if (Ch == 1) {
                PGU_NFDT__ = Convert.ToString(cmd_str__PGU_NFDT0 + len_fifo_data_str + " \n");
            }
            else {
                PGU_NFDT__ = Convert.ToString(cmd_str__PGU_NFDT1 + len_fifo_data_str + " \n");
            }
            //
            //$$byte[] PGU_NFDT__CMD = Encoding.UTF8.GetBytes(PGU_NFDT__);
            //$$ret = scpi_comm_resp_ss(PGU_NFDT__CMD);
            // log
            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_NFDT__);

            return ret;
        }

        public string pgu_fdac__send_log(int Ch, string pulse_info_num_block_str, string LogFileName) {
            string ret = "OK\n";

            //## generate EP commands for numeric block string
            // #  `:PGU:FDAT0` + `#N8_dddddd_hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn_... ..._hhhhmmmmnnnnnnnn_hhhhmmmmnnnnnnnn` + `'\n'` , 
            // #      `hhhh` for DAC value; `mmmm` for incremental step; `nnnnnnnn` for duration count for each DAC value.
            // 
            // send data - first part
            //write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DACx_DAT_INC_PI,val); //(u32 adrs_base, u32 offset, u32 data);
            // send data - second part
            //write_mcs_ep_pi_data(MCS_EP_BASE,EP_ADRS__DACx_DUR_PI,val); //(u32 adrs_base, u32 offset, u32 data);
            // // skip '_' and repeat 

            //// collect data from numberic block string
            char[] buf = pulse_info_num_block_str.ToCharArray();
            s32 loc;
            u32 flag_found__hdr_N8 = 0;
            u32 len_byte;
            u32 val_dat;
            u32 val_dur;
            u32[] buf_val_dat;
            u32[] buf_val_dur;
            u32 idx_buf;
            char[] buf_tmp_dat;
            char[] buf_tmp_dur;
            

            // skip space in buf
            loc = 0;
            while (true) {
                if      (buf[loc]==' ' ) loc++;
                else if (buf[loc]=='\t') loc++;
                else break;
            }            

            // find header in buf : "#N8_"
            if (buf.Skip(loc).Take(4).SequenceEqual("#N8_")) {
                //...
                loc += 4; // skip for header
                // find len_byte in 6-bytes
                //$$len_byte = decstr2data_u32((u8*)(buf+loc),6);
                len_byte = decstr2data_u32(buf.Skip(loc).Take(6).ToArray(), 6);
                loc += 7; // skip for 6 bytes + '_'
                // set flag
                flag_found__hdr_N8 = 1;
            } else {
                // ...
                ret = "NG\n";
                return ret;
            }

            // collect data and repeat
            if (flag_found__hdr_N8 == 1) {
                //...
                // define buffers to collect
                buf_val_dat = new u32[len_byte/16]; // len_byte/2/8
                buf_val_dur = new u32[len_byte/16];
                // loop
                idx_buf = 0;
                while (len_byte > 0) {
                    // collect data in 16 bytes
                    len_byte -= 16;
                    // first part - collect 8 bytes for val_DAT
                    buf_tmp_dat = buf.Skip(loc).Take(8).ToArray();
                    val_dat = hexstr2data_u32(buf.Skip(loc).Take(8).ToArray(), 8);
                    loc += 8;
                    // second part - collect 8 bytes for val_DUR
                    buf_tmp_dur = buf.Skip(loc).Take(8).ToArray();
                    val_dur = hexstr2data_u32(buf.Skip(loc).Take(8).ToArray(), 8);
                    loc += 8;
                    // save in buffers
                    buf_val_dat[idx_buf] = val_dat;
                    buf_val_dur[idx_buf] = val_dur;
                    idx_buf++;
                    // skip '_'
                    while (true) {
                        if (buf[loc]=='_' ) loc++;
                        else break;
                    }            
                }
            } else {
                // ...
                ret = "NG\n";
                return ret;
            }

            //// send at once.
            byte[] dat_bytearray = buf_val_dat.SelectMany(BitConverter.GetBytes).ToArray();
            byte[] dur_bytearray = buf_val_dur.SelectMany(BitConverter.GetBytes).ToArray();
            //
            if (Ch == 1) { // Ch == 1 or DAC0
                WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray);
            }
            else { // Ch == 2 or DAC1
                WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray);
            }

            // for log data
            string PGU_FDAC__;
            //
            if (Ch == 1) {
                PGU_FDAC__ = Convert.ToString(cmd_str__PGU_FDAC0 + pulse_info_num_block_str);
            }
            else {
                PGU_FDAC__ = Convert.ToString(cmd_str__PGU_FDAC1 + pulse_info_num_block_str);
            }
            //
            //$$byte[] PGU_FDAC__CMD = Encoding.UTF8.GetBytes(PGU_FDAC__);
            //$$ret = scpi_comm_resp_ss(PGU_FDAC__CMD);
            // log
            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_FDAC__);
            
            return ret;
        }

        public string pgu_frpt__send_log(int Ch, int CycleCount, string LogFileName) {
            string ret = "OK\n";

            u32 val = (u32)CycleCount;

            //// on dac0 repeat number set
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000020, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);
            //// on dac1 repeat number set
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, 0x00000030, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 8); //(u32 adrs_base, u32 offset, u32 bit_loc);
            //write_mcs_ep_wi(MCS_EP_BASE, EP_ADRS__DACZ_DAT_WI, val, 0xFFFFFFFF);//(u32 adrs_base, u32 offset, u32 data, u32 mask);
            //activate_mcs_ep_ti(MCS_EP_BASE, EP_ADRS__DACZ_DAT_TI, 10); //(u32 adrs_base, u32 offset, u32 bit_loc);


            if (Ch == 1) { // Ch == 1 or DAC0
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

             // for log data
            string PGU_FRPT__;
            //
            string pgu_repeat_num_str = string.Format(" #H{0,8:X8} \n", CycleCount);
            //
            if (Ch == 1) {
                PGU_FRPT__ = Convert.ToString(cmd_str__PGU_FRPT0 + pgu_repeat_num_str);
            } 
            else {
                PGU_FRPT__ = Convert.ToString(cmd_str__PGU_FRPT1 + pgu_repeat_num_str);
            }
            //
            //$$byte[] PGU_FRPT__CMD = Encoding.UTF8.GetBytes(PGU_FRPT__);
            //$$ret = scpi_comm_resp_ss(PGU_FRPT__CMD);
            // log
            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_FRPT__); //$$ add py comment heeder

            return ret;
        }

        public string pgu_freq__send(double time_ns__dac_update) {
            //$$ note ... hardware support freq: 20MHz, 50MHz, 80MHz, 100MHz, 200MHz(default), 400MHz.
            string ret = "OK\n";

            //// calculate parameters
            int pgu_freq_in_100kHz = Convert.ToInt32(1 / (time_ns__dac_update * 1e-9) / 100000);

            u32 val = (u32)pgu_freq_in_100kHz;

            //// DACX fpga pll reset
            pgu_dacx_fpga_pll_rst(1, 1, 1);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms
            //// set freq parameter
            pgu_clkd_setup(val);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms
            //
            //// DACX fpga pll run : all clock work again.
            pgu_dacx_fpga_pll_rst(0, 0, 0);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms

            //$$ DAC input delay tap calibration
            pgu_dacx_cal_input_dtap();


            //// previous LAN command for freq setting
            // string pgu_freq_in_100kHz_str = string.Format(" {0,4:D4} \n", pgu_freq_in_100kHz);
            // byte[] PGU_FREQ_100kHz_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_FREQ + pgu_freq_in_100kHz_str);
            // ret = scpi_comm_resp_ss(PGU_FREQ_100kHz_STR);

            return ret;
        }

        public string pgu_gain__send(int Ch, double DAC_full_scale_current__mA = 25.5) {
            string ret = "OK\n";

            //// calculate parameters
            double I_FS__mA = DAC_full_scale_current__mA;
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

            //// previous LAN command for DAC IC gain setting
            // # ":PGU:GAIN:DAC0? \n" 
            // # ":PGU:GAIN:DAC0 #H02D002D0 \n" 
            //
            // data = {DAC_ch1_fsc, DAC_ch2_fsc}
            // DAC_ch#_fsc = {000000, 10 bit data}
            //
            // string pgu_fsc_gain_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", DAC_gain, DAC_gain);
            // byte[] PGU_GAIN_DAC__STR;
            // if (Ch == 1)
            //     PGU_GAIN_DAC__STR = Encoding.UTF8.GetBytes(cmd_str__PGU_GAIN_DAC0 + pgu_fsc_gain_str);
            // else
            //     PGU_GAIN_DAC__STR = Encoding.UTF8.GetBytes(cmd_str__PGU_GAIN_DAC1 + pgu_fsc_gain_str);
            // ret = scpi_comm_resp_ss(PGU_GAIN_DAC__STR);
            
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
                pgu_dac0_reg_write_b8(0x0E, val1_high);
                pgu_dac0_reg_write_b8(0x0D, val1_low );
                pgu_dac0_reg_write_b8(0x12, val0_high);
                pgu_dac0_reg_write_b8(0x11, val0_low );
            } else {
                pgu_dac1_reg_write_b8(0x0E, val1_high);
                pgu_dac1_reg_write_b8(0x0D, val1_low );
                pgu_dac1_reg_write_b8(0x12, val0_high);
                pgu_dac1_reg_write_b8(0x11, val0_low );
            }

            //// previous LAN command for DAC IC offset setting
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
            // string pgu_offset_con_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", DAC_offset, DAC_offset); // set subchannel as well
            // byte[] PGU_OFST_DAC__OFFSET_STR;
            // if (Ch == 1)
            //     PGU_OFST_DAC__OFFSET_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_OFST_DAC0 + pgu_offset_con_str);
            // else
            //     PGU_OFST_DAC__OFFSET_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_OFST_DAC1 + pgu_offset_con_str);
            // ret = scpi_comm_resp_ss(PGU_OFST_DAC__OFFSET_STR);
            
            return ret;
        }

            

        //$$ EEPROM access

        public int pgu_eeprom__read__data_4byte(int adrs_b32) {
            int ret_int;

            //// for firmware
            u16 adrs = (u16)adrs_b32; 
            u8[] buf = new u8[4]; // sizeof(int) : 4
            
            //eeprom_read_data((u16)adrs, 4, (u8*)&val); //$$ read eeprom
            eeprom_read_data(adrs, 4, buf); // num of bytes : 4 for int
            
            // reconstruct int from char[]
            byte[] buf_bytearray = Array.ConvertAll(buf, x => (byte)x );
            ret_int = BitConverter.ToInt32(buf_bytearray,0);  

            //// previous LAN commmand for eeprom read
            // # ':PGU:MEMR' # new ':PGU:MEMR #H00000058 \n'
            //
            // string PGU_MEMR = Convert.ToString(cmd_str__PGU_MEMR) + string.Format(" #H{0,8:X8}\n", adrs_b32);
            // byte[] PGU_MEMR_CMD = Encoding.UTF8.GetBytes(PGU_MEMR);
            // string ret;
            // try {
            //     ret = scpi_comm_resp_ss(PGU_MEMR_CMD);
            // }
            // catch {
            //     ret = "#H00000000\n";
            // }
            // ret_int = (int)Convert.ToInt32(ret.Substring(2,8),16); // convert hex into int32

            return ret_int;
        }

        public int pgu_eeprom__write_data_4byte(int adrs_b32, uint val_b32, int interval_ms = 10) {
            int ret_int = 0;

            //// for firmware
            u32 val  = (u32)val_b32;
            u16 adrs = (u16)adrs_b32; 

            byte[] buf_bytearray = BitConverter.GetBytes(val);
            u8[] buf = Array.ConvertAll(buf_bytearray, x => (u8)x );

            eeprom_write_data(adrs, 4, buf); //$$ write eeprom 

            Delay(interval_ms); //$$ ms wait for write done 
            

            //// previous LAN commmand for eeprom write
            // # ':PGU:MEMW' # new ':PGU:MEMW #H0000005C #H1234ABCD \n'
            //
            // string PGU_MEMW = Convert.ToString(cmd_str__PGU_MEMW) 
            //                 + string.Format(" #H{0,8:X8}"  , adrs_b32)
            //                 + string.Format(" #H{0,8:X8}\n", val_b32 );
            // byte[] PGU_MEMW_CMD = Encoding.UTF8.GetBytes(PGU_MEMW);
            // string ret = scpi_comm_resp_ss(PGU_MEMW_CMD);
            // 
            // //Delay(1); //$$ 1ms wait for write done // NG  read right after write
            // //Delay(2); //$$ 2ms wait for write done // some NG 
            // //Delay(10); //$$ 10ms wait for write done 
            // Delay(interval_ms); //$$ ms wait for write done 
            // //
            // int ret_int = 0;
            // if (ret.Substring(0,2)=="OK") {
            //     ret_int = 0;
            // }
            // else {
            //     ret_int = -1;
            // }

            return ret_int;
        }


        // test var
        private int __test_int = 0;
        
        // test function
        public new static string _test() {
            string ret = SPI_EMUL._test() + ":_class__PGU_control_by_eps_";
            return ret;
        }
        public static int __test_PGU_control_by_eps() {
            Console.WriteLine(">>>>>> test: __test_PGU_control_by_eps");

            // test member
            PGU_control_by_eps dev_eps = new PGU_control_by_eps();
            dev_eps.__test_int = dev_eps.__test_int - 1;
            Console.WriteLine(">>> EP_ADRS__GROUP_STR = " + dev_eps.EP_ADRS__GROUP_STR);

            // test LAN
            dev_eps.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev_eps.get_IDN());
            Console.WriteLine(dev_eps.eps_enable());

            // test start
            Console.WriteLine(dev_eps.pgu_pwr__on());
            Console.WriteLine(dev_eps.pgu_output__on());
            dev_eps.Delay(1000); // ms


            Console.WriteLine(dev_eps.pgu_output__off());
            Console.WriteLine(dev_eps.pgu_pwr__off());
            dev_eps.Delay(1000); // ms

            // test finish
            Console.WriteLine(dev_eps.eps_disable());
            dev_eps.scpi_close();

            return dev_eps.__test_int;
        }
    }


    //// S3100-ADDA class using SPI_EMUL
    public class ADDA_control_by_eps : SPI_EMUL
    {

        //// EPS address map info ......
        private string EP_ADRS__GROUP_STR         = "_S3100_ADDA_";

        //private u32   EP_ADRS__SSPI_TEST_WO     = 0xE0;
        //private u32   EP_ADRS__SSPI_CON_WI      = 0x02;
        //private u32   EP_ADRS__SSPI_FLAG_WO     = 0x00;

        private u32   EP_ADRS__FPGA_IMAGE_ID_WO = 0x20;
        private u32   EP_ADRS__XADC_TEMP_WO     = 0x3A;
        //private u32   EP_ADRS__XADC_VOLT_WO     = 0x3B;
        //private u32   EP_ADRS__TIMESTAMP_WO     = 0x22;
        private u32   EP_ADRS__TEST_MON_WO      = 0x23;
        //private u32   EP_ADRS__TEST_CON_WI      = 0x01; // LAN only
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

        private u32   EP_ADRS__MEM_FDAT_WI        = 0x12;
        private u32   EP_ADRS__MEM_WI             = 0x13;
        private u32   EP_ADRS__MEM_TI             = 0x53;
        private u32   EP_ADRS__MEM_TO             = 0x73;
        private u32   EP_ADRS__MEM_PI             = 0x93;
        private u32   EP_ADRS__MEM_PO             = 0xB3;
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
        private u32   EP_ADRS__ADCH_FREQ_WI       = 0x1C;
        private u32   EP_ADRS__ADCH_UPD_SM_WI     = 0x1D;
        private u32   EP_ADRS__ADCH_SMP_PR_WI     = 0x1E;
        private u32   EP_ADRS__ADCH_DLY_TP_WI     = 0x1F;
        private u32   EP_ADRS__ADCH_WO            = 0x38;
        private u32   EP_ADRS__ADCH_B_FRQ_WO      = 0x39;
        private u32   EP_ADRS__ADCH_DOUT0_WO      = 0x3C;
        private u32   EP_ADRS__ADCH_DOUT1_WO      = 0x3D;
        private u32   EP_ADRS__ADCH_DOUT2_WO      = 0x3E;
        private u32   EP_ADRS__ADCH_DOUT3_WO      = 0x3F;
        private u32   EP_ADRS__ADCH_TI            = 0x58;
        private u32   EP_ADRS__ADCH_TO            = 0x78;
        private u32   EP_ADRS__ADCH_DOUT0_PO      = 0xBC;
        private u32   EP_ADRS__ADCH_DOUT1_PO      = 0xBD;

        //private u32   EP_ADRS__DFT_TI             = 0x5C; // reserved
        //private u32   EP_ADRS__DFT_COEF_RE_PI     = 0x9C; // reserved
        //private u32   EP_ADRS__DFT_COEF_IM_PI     = 0x9D; // reserved

        //// firmware control const
        private u32   MAX_CNT = 2000000; // max counter when checking done trig_out.

        //// functions 

        // spio functions

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
        private u32 sp1_ext_init(u32 led, u32 pwr_dac, u32 pwr_adc, u32 pwr_amp, u32 sw_relay_k1=0, u32 sw_relay_k2=0) {
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
        private u32 adc_enable(u32 sel_freq_mode_MHz = 210) {
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
        private u32 adc_disable() {
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
        private u32 adc_init() {
            return adc_trig_check(1);
        }
        private u32 adc_update() {
            return adc_trig_check(2);
        }
        private u32 adc_update_check() {
            return adc_trig_check__wo_trig(2);
        }
        private u32 adc_test() {
            return adc_trig_check(3);
        }
        private u32 adc_reset_fifo() {
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
        private u32 adc_get_fifo(u32 ch, s32 num_data, s32[] buf_s32) {
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

            ret = (u32)ReadFromPipeOut(adrs, ref buf_pipe); // buf_pipe ... u8 buffer

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
        private void adc_log_buf(char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32, 
                                string buf_time_str="", string buf_dac0_str="", string buf_dac1_str="") {
            //
		    string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), "test_ADDA__vscode", "log"); //$$ TODO: logfile location in vs code
            string LogFileName = Path.Combine(LogFilePath, new string(log_filename));

            // open or create a file
            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ws.WriteLine("\"\"\" data log file : import data as CONSTANT \"\"\"");
                    ws.WriteLine("# pylint: disable=C0301");
                    ws.WriteLine("# pylint: disable=line-too-long");
                    ws.WriteLine("# pylint: disable=C0326 ## disable-exactly-one-space");
                    ws.WriteLine("## log start"); //$$ add python comment header
                }
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false)) {
                    ws.WriteLine("\"\"\" data log file : import data as CONSTANT \"\"\"");
                    ws.WriteLine("# pylint: disable=C0301");
                    ws.WriteLine("# pylint: disable=line-too-long");
                    ws.WriteLine("# pylint: disable=C0326 ## disable-exactly-one-space");
                    ws.WriteLine("## log start"); //$$ add python comment header
                }
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
        private void dac_init(double time_ns__dac_update = 5,
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
                pgu_dacx_cal_input_dtap();
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

        private u32  pgu_dacx_cal_input_dtap() {
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

        // temp for dac test // to replace
        public string pgu_freq__send(double time_ns__dac_update) {
            //$$ note ... hardware support freq: 20MHz, 50MHz, 80MHz, 100MHz, 200MHz(default), 400MHz.
            string ret = "OK\n";

            //// calculate parameters
            int pgu_freq_in_100kHz = Convert.ToInt32(1 / (time_ns__dac_update * 1e-9) / 100000);

            u32 val = (u32)pgu_freq_in_100kHz;

            //// DACX fpga pll reset
            pgu_dacx_fpga_pll_rst(1, 1, 1);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms
            //// set freq parameter
            pgu_clkd_setup(val);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms
            //
            //// DACX fpga pll run : all clock work again.
            pgu_dacx_fpga_pll_rst(0, 0, 0);
            //
            //usleep(500); // 500us
            Delay(1); // 1ms

            //$$ DAC input delay tap calibration // option
            //pgu_dacx_cal_input_dtap();

            return ret;
        }        
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

        private string pgu_nfdt__send(int Ch, long fifo_data) {
            // send the number of fifo_data
            string ret = "OK\n";

            u32 val = (u32)fifo_data;

            if (Ch == 1) { // Ch == 1 or DAC0
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

            return ret;
        }
        private string pgu_fdac__send(int Ch, string pulse_info_num_block_str) {
            string ret = "OK\n";

            //// collect data from numberic block string
            char[] buf = pulse_info_num_block_str.ToCharArray();
            s32 loc;
            u32 flag_found__hdr_N8 = 0;
            u32 len_byte;
            u32 val_dat;
            u32 val_dur;
            u32[] buf_val_dat;
            u32[] buf_val_dur;
            u32 idx_buf;
            char[] buf_tmp_dat;
            char[] buf_tmp_dur;
            

            // skip space in buf
            loc = 0;
            while (true) {
                if      (buf[loc]==' ' ) loc++;
                else if (buf[loc]=='\t') loc++;
                else break;
            }            

            // find header in buf : "#N8_"
            if (buf.Skip(loc).Take(4).SequenceEqual("#N8_")) {
                //...
                loc += 4; // skip for header
                // find len_byte in 6-bytes
                //$$len_byte = decstr2data_u32((u8*)(buf+loc),6);
                len_byte = decstr2data_u32(buf.Skip(loc).Take(6).ToArray(), 6);
                loc += 7; // skip for 6 bytes + '_'
                // set flag
                flag_found__hdr_N8 = 1;
            } else {
                // ...
                ret = "NG\n";
                return ret;
            }

            // collect data and repeat
            if (flag_found__hdr_N8 == 1) {
                //...
                // define buffers to collect
                buf_val_dat = new u32[len_byte/16]; // len_byte/2/8
                buf_val_dur = new u32[len_byte/16];
                // loop
                idx_buf = 0;
                while (len_byte > 0) {
                    // collect data in 16 bytes
                    len_byte -= 16;
                    // first part - collect 8 bytes for val_DAT
                    buf_tmp_dat = buf.Skip(loc).Take(8).ToArray();
                    val_dat = hexstr2data_u32(buf.Skip(loc).Take(8).ToArray(), 8);
                    loc += 8;
                    // second part - collect 8 bytes for val_DUR
                    buf_tmp_dur = buf.Skip(loc).Take(8).ToArray();
                    val_dur = hexstr2data_u32(buf.Skip(loc).Take(8).ToArray(), 8);
                    loc += 8;
                    // save in buffers
                    buf_val_dat[idx_buf] = val_dat;
                    buf_val_dur[idx_buf] = val_dur;
                    idx_buf++;
                    // skip '_'
                    while (true) {
                        if (buf[loc]=='_' ) loc++;
                        else break;
                    }            
                }
            } else {
                // ...
                ret = "NG\n";
                return ret;
            }

            //// send at once.
            byte[] dat_bytearray = buf_val_dat.SelectMany(BitConverter.GetBytes).ToArray();
            byte[] dur_bytearray = buf_val_dur.SelectMany(BitConverter.GetBytes).ToArray();
            //
            if (Ch == 1) { // Ch == 1 or DAC0
                WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray);
            }
            else { // Ch == 2 or DAC1
                WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray);
                WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray);
            }

            return ret;
        }
        private string pgu_frpt__send(int Ch, int CycleCount) {
            string ret = "OK\n";

            u32 val = (u32)CycleCount;

            if (Ch == 1) { // Ch == 1 or DAC0
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

            return ret;
        }
        
        private void dac_set_trig(bool trig_ch1 =false, bool trig_ch2 = false, bool trig_adc_linked = false) {
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
        private void dac_reset_trig() {
            dac_set_trig();
        }

        private void dac_gen_wave_cmd(){

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
        private void pgu__setup_freq(double time_ns__dac_update) {

            //$$ note ... hardware support freq: 20MHz, 50MHz, 80MHz, 100MHz, 200MHz(default), 400MHz.
            pgu_freq__send(time_ns__dac_update);

            //$$ DAC input delay tap calibration // option
            if (time_ns__dac_update <= 5) // conduct dac input delay tap check only when update rate >= 200MHz.
                pgu_dacx_cal_input_dtap();
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

        private void dac_set_fifo(
            int    ch, int num_repeat_pulses,
            long[] time_ns_list, double[] level_volt_list,
            int    time_ns__code_duration, 
            double out_scale, double out_offset,
            double load_impedance_ohm, double output_impedance_ohm,
            double scale_voltage_10V_mode, 
            int output_range, double gain_voltage_10V_to_40V_mode) {

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

            // generate pulse waveform
            var pulse_info = pgu__gen_pulse_info(
                output_range, 
                time_ns_list, level_volt_list, 
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

            s32[]  code_value__s32_buf;
            s32[]  code_inc_value__s32_buf;
            long[] code_duration__long_buf;

            // set the number of fifo data length
            long fifo_data = 0;
            for (int i = 0; i < code_value__list.Length; i++)
            {
                fifo_data = fifo_data + code_value__list[i].Count;
            }
            //pgu_nfdt__send(ch, fifo_data); //$$ replaced
            val = (u32)fifo_data;
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

            // send DAC data into FPGA FIFO
            //for (int i = 0; i < pulse_info_num_block_str.Length; i++)
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

                //// send arrays to FIFOs 
                byte[] dat_bytearray = code_inc_value__s32_buf.SelectMany(BitConverter.GetBytes).ToArray();
                byte[] dur_bytearray = code_duration__long_buf.SelectMany(BitConverter.GetBytes).ToArray();

                if (ch == 1) { // Ch == 1 or DAC0
                    WriteToPipeIn(EP_ADRS__DAC0_DAT_INC_PI, ref dat_bytearray);
                    WriteToPipeIn(EP_ADRS__DAC0_DUR_PI    , ref dur_bytearray);
                }
                else { // Ch == 2 or DAC1
                    WriteToPipeIn(EP_ADRS__DAC1_DAT_INC_PI, ref dat_bytearray);
                    WriteToPipeIn(EP_ADRS__DAC1_DUR_PI    , ref dur_bytearray);
                }

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
        private Tuple<long[], double[]> pgu__gen_time_voltage_list__remove_dup(long[] StepTime, double[] StepLevel) {
            // copy buffer and remove duplicate data
            List<long>   StepTime_List  = new List<long>();
            List<double> StepLevel_List = new List<double>();
            
            // add the first elements into list
            StepTime_List.Add(StepTime[0]);
            StepLevel_List.Add(StepLevel[0]);

            for (int i = 1; i < StepTime.Length; i++)
            {
                if (StepTime[i]  == StepTime[i-1]) {
                    if (StepLevel[i] == StepLevel[i-1] ) {
                        continue; // leave for removing dup data with same voltage
                    } 
                    else {
                        break; // not able to remove dup data due to difference voltage
                    }
                }
                StepTime_List.Add(StepTime[i]);
                StepLevel_List.Add(StepLevel[i]);
            }

            // You can convert it back to an array if you would like to
            long[] StepTime__no_dup  = StepTime_List.ToArray();
            double[] StepLevel__no_dup = StepLevel_List.ToArray();

            return Tuple.Create(StepTime__no_dup, StepLevel__no_dup);
        }

        // test var
        private int __test_int = 0;
        
        // test function
        public new static string _test() {
            string ret = SPI_EMUL._test() + ":_class__ADDA_control_by_eps_";
            return ret;
        }

        public static int __test_ADDA_control_by_eps() {
            Console.WriteLine(">>>>>> test: __test_ADDA_control_by_eps");

            // test member
            ADDA_control_by_eps dev_eps = new ADDA_control_by_eps();
            dev_eps.__test_int = dev_eps.__test_int - 1;
            Console.WriteLine(">>> EP_ADRS__GROUP_STR = " + dev_eps.EP_ADRS__GROUP_STR);

            // test LAN
            dev_eps.my_open(__test__.Program.test_host_ip);
            Console.WriteLine(dev_eps.get_IDN());
            Console.WriteLine(dev_eps.eps_enable());

            // ... test eps addresses
            Console.WriteLine(string.Format("FID = 0x{0,8:X8} ",dev_eps.GetWireOutValue(dev_eps.EP_ADRS__FPGA_IMAGE_ID_WO)));
            Console.WriteLine(string.Format("FPGA temp [C] = {0,6:f3} ",(float)dev_eps.GetWireOutValue(dev_eps.EP_ADRS__XADC_TEMP_WO)/1000));

            // ... test subfunctions

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
            //val = dev_eps.adc_enable(); // adc_enable(u32 sel_freq_mode_MHz = 210) // 210MHz
            val = dev_eps.adc_enable(189); // 189MHz
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_enable", val));
            
            // adc base freq check 
            val = dev_eps.adc_get_base_freq();
            Console.WriteLine(string.Format("{0} = {1} [MHz]", "adc_base_freq", val/1000000));

            // adc reset
            val = dev_eps.adc_reset();
            Console.WriteLine(string.Format("{0} = 0x{1,8:X8} ", "adc_reset", val));

            // adc fixed pattern setup 
            dev_eps.adc_set_tap_control(0x0,0x0,0x0,0x0,1,0); // (u32 val_tap0a_b5, u32 val_tap0b_b5, u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
            
            // adc sampling period
            //dev_eps.adc_set_sampling_period( 14); // 210MHz/14   =  15 Msps
            dev_eps.adc_set_sampling_period( 21); // 210MHz/21   =  10 Msps
            //dev_eps.adc_set_sampling_period( 42); // 210MHz/42   =   5 Msps
            //dev_eps.adc_set_sampling_period(105); // 210MHz/105  =   2 Msps
            //dev_eps.adc_set_sampling_period(210); // 210MHz/210  =   1 Msps
            //dev_eps.adc_set_sampling_period( 42); // 210MHz/420  = 0.5 Msps
            //dev_eps.adc_set_sampling_period(105); // 210MHz/1050 = 0.2 Msps
            //dev_eps.adc_set_sampling_period(210); // 210MHz/2100 = 0.1 Msps

            // adc update sample numbers
            dev_eps.adc_set_update_sample_num(40); // 40 samples for test

            // adc init 
            val = dev_eps.adc_init();
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
            dev_eps.adc_set_tap_control(0x0,0x0,0x0,0x0,0,0); // (u32 val_tap0a_b5, u32 val_tap0b_b5,             u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
            //dev_eps.adc_set_tap_control(0xF,0xF,0xF,0xF,0,0); // (u32 val_tap0a_b5, u32 val_tap0b_b5,             u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
            dev_eps.adc_set_sampling_period( 21); // 210MHz/21   =  10 Msps
            dev_eps.adc_set_update_sample_num(len_adc_data); // any number of samples
            dev_eps.adc_init(); // init with setup parameters
            dev_eps.adc_reset_fifo(); // clear fifo for new data
            dev_eps.adc_update();

            // fifo data read 
            s32[] buf0_s32 = new s32[len_adc_data];
            s32[] buf1_s32 = new s32[len_adc_data];
            dev_eps.adc_get_fifo(0, len_adc_data, buf0_s32); // (u32 ch, s32 num_data, s32[] buf_s32);
            dev_eps.adc_get_fifo(1, len_adc_data, buf1_s32); // (u32 ch, s32 num_data, s32[] buf_s32);

            // log fifo data into a file
            dev_eps.adc_log_buf("log__adc_buf.py".ToCharArray(), len_adc_data, buf0_s32, buf1_s32); // (char[] log_filename, s32 len_data, s32[] buf0_s32, s32[] buf1_s32)


            //// DAC wave test

            // DAC setup

            //$$ note: DAC/CLKD IC, FPGA PLL setup and Pattern generator setup
            // dac__dev_*
            // dac__clk_*
            // dac__pll_*
            // dac__pat_*
            // dac__out_* : dac output direct control (reserved)
            //
            // dac_pwr(...)
            // dac_init()
            // dac_setup(...)
            // dac_waveform(...)
            // dac_trig_on(...)
            // dac_trig_off()


            ////
            Console.WriteLine(">>> DAC setup");

            // dac init
            Console.WriteLine(">>>>>> DAC power on");
            dev_eps.dac_pwr(1);

            
            Console.WriteLine(">>>>>> DAC init");
            
            //// DAC update period
            //double time_ns__dac_update = 5; // 200MHz dac update
            double time_ns__dac_update = 10; // 100MHz dac update

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

            //$$ pulse setup
            long[]   StepTime_1;
            double[] StepLevel_1;
            long[]   StepTime_2;
            double[] StepLevel_2;

            //// case for sine wave

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
            double amplitude  = 1.0; // test


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

            //
            long   test_period_ns   = (long)(1.0/test_freq_kHz*1000000);
            long   sample_period_ns = test_period_ns/len_dac_command_points; // DAC command point space
            double sample_rate_kSPS = (double)1.0/sample_period_ns*1000000;
            double phase_diff = Math.PI/2; // pi/2 = 90 degree
            
            long[]   buf_time = new long  [len_dac_command_points+1];
            double[] buf_dac0 = new double[len_dac_command_points+1];
            double[] buf_dac1 = new double[len_dac_command_points+1];

            for (int n = 0; n < buf_time.Length; n++)
            {
                buf_time[n] = sample_period_ns*n;
                buf_dac0[n] = (amplitude * Math.Sin((2 * Math.PI * n * test_freq_kHz) / sample_rate_kSPS + 0         ));
                buf_dac1[n] = (amplitude * Math.Sin((2 * Math.PI * n * test_freq_kHz) / sample_rate_kSPS + phase_diff));
            }

            // print out
            string buf_time_str = String.Join(", ", buf_time);
            string buf_dac0_str = String.Join(", ", buf_dac0);
            string buf_dac1_str = String.Join(", ", buf_dac1);
            Console.WriteLine(buf_time_str);
            Console.WriteLine(buf_dac0_str);
            Console.WriteLine(buf_dac1_str);

            StepTime_1  = buf_time;
            StepLevel_1 = buf_dac0;
            StepTime_2  = buf_time;
            StepLevel_2 = buf_dac1;


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

            //$$ generate waveform and download
            //StepTime_1  = StepTime;
            //StepLevel_1 = StepLevel;
            //StepTime_2  = StepTime;
            //StepLevel_2 = StepLevel;

            var time_volt_list1 = dev_eps.pgu__gen_time_voltage_list__remove_dup(StepTime_1, StepLevel_1);
            var time_volt_list2 = dev_eps.pgu__gen_time_voltage_list__remove_dup(StepTime_2, StepLevel_2);

            ////
            Console.WriteLine(">>> DAC waveform command generation");
            dev_eps.dac_gen_wave_cmd();
            //dev_eps.dac_gen_test_cmd(int case_idx);

            ////
            Console.WriteLine(">>> DAC FIFO data gerenation");
            //dev_eps.dac_gen_fifo_dat();

            ////
            Console.WriteLine(">>> DAC pulse download");

            // call setup 
            int    output_range                     = 10;   
            int    time_ns__code_duration          = 10; // 10ns = 100MHz
            //int    time_ns__code_duration          = 5; // 5ns = 200MHz
            double load_impedance_ohm              = 1e6;                       
            double output_impedance_ohm            = 50;                        
            double scale_voltage_10V_mode          = 8.5/10; // 7.650/10        
            double gain_voltage_10V_to_40V_mode    = 3.64; // 4/7.650*6.95~=3.64
            double out_scale                       = 1.0;
            double out_offset                      = 0.0;
            //int num_repeat_pulses = 100; // 100/(500kHz)=0.2ms
            int num_repeat_pulses = 500; // 500/(500kHz)=1.0ms
            //int num_repeat_pulses = 2000; // 2000/(500kHz)=4ms

            // dac_set_fifo(...) : download dac data to fifo after reading data from time-voltage list
            Console.WriteLine(">>>>>> DAC0 download");
            dev_eps.dac_set_fifo(
                1, num_repeat_pulses,
                time_volt_list1.Item1, time_volt_list1.Item2, 
                time_ns__code_duration, 
                out_scale, out_offset,
                load_impedance_ohm, output_impedance_ohm, 
                scale_voltage_10V_mode, 
                output_range, gain_voltage_10V_to_40V_mode);
            Console.WriteLine(">>>>>> DAC1 download");
            dev_eps.dac_set_fifo(
                2, num_repeat_pulses,
                time_volt_list2.Item1, time_volt_list2.Item2, 
                time_ns__code_duration, 
                out_scale, out_offset,
                load_impedance_ohm, output_impedance_ohm, 
                scale_voltage_10V_mode, 
                output_range, gain_voltage_10V_to_40V_mode);


            // previoud subfunctions:
            // pgu_pwr__on
            // pgu_pwr__off
            // pgu_nfdt__send_log
            // pgu_fdac__send_log
            // pgu_frpt__send_log
            // pgu_trig__on_log
            // pgu_trig__off

            ////
            Console.WriteLine(">>> ADC setup");

            // adc normal setup 
            //len_adc_data = 2000; // 0.19047619 @ 10.5MHz
            //len_adc_data = 1000; // 0.0952380952 ms @ 10.5MHz
            //len_adc_data = 800; // 0.0761904762 ms @ 10.5MHz
            len_adc_data = 600;
            //len_adc_data = 500; // 0.0476190476 ms @ 10.5MHz
            dev_eps.adc_set_tap_control(0x0,0x0,0x0,0x0,0,0); // (u32 val_tap0a_b5, u32 val_tap0b_b5,             u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
            //dev_eps.adc_set_tap_control(0xF,0xF,0xF,0xF,0,0); // (u32 val_tap0a_b5, u32 val_tap0b_b5,             u32 val_tap1a_b5, u32 val_tap1b_b5, u32 val_tst_fix_pat_en_b1, u32 val_tst_inc_pat_en_b1) 
            //
            //dev_eps.adc_set_sampling_period( 14); // 210MHz/14   =  15 Msps
            //dev_eps.adc_set_sampling_period( 15); // 210MHz/15   =  14 Msps
            //dev_eps.adc_set_sampling_period( 21); // 210MHz/21   =  10 Msps
            //dev_eps.adc_set_sampling_period( 43); // 210MHz/43   =  4.883721 Msps //$$ 116.27907kHz image with 5MHz wave
            //dev_eps.adc_set_sampling_period( 106); // 210MHz/106   =  1.98113208 Msps //$$ 18.8679245kHz image with 2MHz wave
            //dev_eps.adc_set_sampling_period( 210); // 210MHz/210   =  1 Msps
            //dev_eps.adc_set_sampling_period( 211); // 210MHz/211   =  0.995261 Msps //$$ 4.739336kHz image with 1MHz wave
            //dev_eps.adc_set_sampling_period( 2100); // 210MHz/210   =  0.1 Msps
            //
            //dev_eps.adc_set_sampling_period( 15); // 189MHz/14   =  13.5 Msps
            dev_eps.adc_set_sampling_period( 18); // 189MHz/18   =  10.5 Msps
            //dev_eps.adc_set_sampling_period( 38); // 189MHz/38   =  4.973684 Msps //$$ 26.315789kHz image with 5MHz wave
            //dev_eps.adc_set_sampling_period( 95); // 189MHz/95  =  1.98947368 Msps //$$  10.5263158kHz image with 2MHz wave
            //dev_eps.adc_set_sampling_period(190); // 189MHz/190  =  0.994737 Msps //$$  5.263158kHz image with 1MHz wave
            //dev_eps.adc_set_sampling_period(379); // 189MHz/379  =  0.498680739 Msps //$$  1.31926121kHz image with 0.5MHz wave
            //
            dev_eps.adc_set_update_sample_num(len_adc_data); // any number of samples
            dev_eps.adc_init(); // init with setup parameters
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
            buf0_s32 = null;
            buf1_s32 = null;
            GC.Collect(); // Collect all generations of memory.

            // fifo data read 
            buf0_s32 = new s32[len_adc_data];
            buf1_s32 = new s32[len_adc_data];
            Console.WriteLine(">>>>>> ADC0 FIFO read");
            dev_eps.adc_get_fifo(0, len_adc_data, buf0_s32); // (u32 ch, s32 num_data, s32[] buf_s32);
            Console.WriteLine(">>>>>> ADC1 FIFO read");
            dev_eps.adc_get_fifo(1, len_adc_data, buf1_s32); // (u32 ch, s32 num_data, s32[] buf_s32);

            // log fifo data into a file
            Console.WriteLine(">>>>>> write ADC log file");
            dev_eps.adc_log_buf("log__adc_buf__dac.py".ToCharArray(), len_adc_data, buf0_s32, buf1_s32,
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

            // test finish
            Console.WriteLine(dev_eps.eps_disable());
            dev_eps.scpi_close();

            return dev_eps.__test_int;
        }

    }
    

    //// top class case3
    public class TOP_PGU__EPS_SPI : PGU_control_by_eps
    {
        

        //// default setting for PGU
        public double time_ns__dac_update = 10; // 2.5, 5, 10
        public int time_ns__code_duration = 10;    //$$ consider int --> double
        public double scale_voltage_10V_mode = 7.650 / 10;
        public double scale_voltage_40V_mode = 6.950 / 10;
        public double output_impedance_ohm = 50;

        public int __gui_ch_info;
        public int __gui_aux_io_control;
        public double __gui_load_impedance_ohm;
        public int __gui_cycle_count;
        //public int __gui_min_num_interpol;
        //public int __gui_num_points;

        //// cal_data from EEPROM
        public int __gui_use_caldata = 1; // 1 to use calibration data.
        public float __gui_out_ch1_offset = 0.0F; //$$ EEPROM float32 location @ 0x040
        public float __gui_out_ch2_offset = 0.0F; //$$ EEPROM float32 location @ 0x044
        public float __gui_out_ch1_gain  = 1.0F; //$$ EEPROM float32 location @ 0x048
        public float __gui_out_ch2_gain  = 1.0F; //$$ EEPROM float32 location @ 0x04C


        // board INFO from EEPROM 
        public char[] __gui_pgu_idn_txt = new char[60]; //$$ not inside EEPROM

        public char[] __gui_pgu_model_name  = new char[16]; //$$ location @ 0x00-0x0F
        public char[] __gui_pgu_ip_adrs = new char[16]; //$$ location @ 0x10-0x13
        public char[] __gui_pgu_sm_adrs = new char[16]; //$$ location @ 0x14-0x17
        public char[] __gui_pgu_ga_adrs = new char[16]; //$$ location @ 0x18-0x1B
        public char[] __gui_pgu_dns_adrs= new char[16]; //$$ location @ 0x1C-0x1F
        public char[] __gui_pgu_mac_adrs= new char[12]; //$$ location @ 0x20-0x2B
        public char[] __gui_pgu_slot_id = new char[2];  //$$ location @ 0x2C-0x2D
        public byte __gui_pgu_user_id           ;       //$$ location @ 0x2E
        public byte __gui_pgu_check_sum         ;       //$$ location @ 0x2F
        public byte __gui_pgu_check_sum_residual;       //$$ not inside EEPROM
        public char[] __gui_pgu_user_txt = new char[16];//$$ location @ 0x30-0x3F

        //----//

        //public string LogFilePath = Path.GetDirectoryName(Environment.CurrentDirectory) + "T-SPACE" + "\\Log";
        //$$public static string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), "T-SPACE", "Log"); //$$ for release
		public static string LogFilePath = Path.Combine(Path.GetDirectoryName(Environment.CurrentDirectory), "test_PGU__vscode", "log"); //$$ TODO: logfile location in vs code
        public string LogFileName = Path.Combine(LogFilePath, "Debugger.py");
        
        public bool IsInit = false;

        //$$ new sysopen with slot location and spi group info
        //   SysOpen_loc_slot_spi(string HOST, int TIMEOUT = 20000, uint loc_slot = 0x01FF, uint loc_spi_group = 0x0003)
        public string SysOpen_loc_slot_spi(string HOST, int TIMEOUT = 20000, uint loc_slot = 0x01FF, uint loc_spi_group = 0x0003) {
            // select slot locations
            SPI_EMUL__set__use_loc_slot(true);       // use fixed slot location
            SPI_EMUL__set__loc_slot (loc_slot);      // for slot location bits
            SPI_EMUL__set__loc_group(loc_spi_group); // for spi channel location bits
            return SysOpen(HOST, TIMEOUT);
        }

        public string SysOpen(string HOST, int TIMEOUT = 20000)
        {
            my_open(HOST, TIMEOUT);

            string ret;

            if (IsInit == false)
            {            

                //### :EPS:EN //$$ endpoint enable
                ret = eps_enable();

                //### scpi command: ":PGU:PWR"
                //### power on (DAC IC)
                ret = pgu_pwr__on();
                Delay(10); //$$ 10ms wait for electrical power stabilty

                ////### output on or off //$$ PGU-CPU-S3000 relay on or off 
                ret = pgu_output__on();

                Read_IDN();
                Load_CAL_from_EEPROM();
                Load_INFO_from_EEPROM();

                IsInit = true;     
            }

            //### scpi : *IDN?
            return get_IDN();  
        }

        public void SysClose()
        {
            if ( scpi_is_available() ) scpi_close();
        }

        public void SysClose__board_shutdown() 
        {
            //$$ shutdown board 
            IsInit = false; 

            pgu_output__off(); // relay off
            Delay(10); //$$ 10ms wait for mechanical relay done 
            pgu_pwr__off(); // dac ic off
            eps_disable(); // endpoint access off 

            if ( scpi_is_available() ) scpi_close();
        }
        




        public long conv_dec_to_bit_2s_comp_16bit(double dec, double full_scale = 20) //$$ int to double
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

		//$$ TODO: gen_pulse_info_num_block__inc_step
        //public Tuple<string, int[]> gen_pulse_info_num_block__inc_step(int code_start, int code_step, int num_steps, int code_duration)
        //$$public string gen_pulse_info_num_block__inc_step(int code_start, int code_step, long num_steps, int code_duration)
		
		// new tuple for starting C# v7.0
		//public (string pulse_info_num_block_str, string code_value_float_str, string time_ns_str, string duration_ns_str)
		//gen_pulse_info_num_block__inc_step (int code_start, int code_diff, int code_step, long num_steps, int code_duration, 
		//		long time_start_ns = 0, long max_duration_a_code__in_flat_segment = 16, long max_num_codes__in_slope_segment = 16 )
		
        public Tuple<string, string, string, string> gen_pulse_info_num_block__inc_step(int code_start, double volt_diff, int code_diff, int code_step, long num_steps, long code_duration, 
				long time_start_ns = 0, long max_duration_a_code__in_flat_segment = 16, long max_num_codes__in_slope_segment = 16)
        {
			// Console.WriteLine(">>> ... in gen_pulse_info_num_block__inc_step()");
			
            long num_codes = num_steps;
			
			int time_ns__code_duration = this.time_ns__code_duration; //$$ consider float??

            string pulse_info_num_block_str = ""; // = String.Format(" #N8_{0,6:D6}", num_codes * 16); //$$ must revise

            //$$int[] code_list = new int[num_codes];     //$$ unused
            //$$int[] duration_list = new int[num_codes]; //$$ unused
            //$$int[] sample_list = new int[num_codes];   //$$ unused
            //$$int[] sample_code = new int[num_codes];   //$$ unused

            //$$int sample_value = 0;
			long time_ns = (long)time_start_ns;
			long duration_ns = 0; //$$
            int code_value = code_start;
            //int test_value;
            string test_str;
            //int code_value_prev;
			
			string code_value_str = ""; //$$
			string code_value_float_str = ""; //$$
			string code_duration_str = ""; //$$
			string time_ns_str = ""; //$$
			string duration_ns_str = ""; //$$
			
			long total_duration_segment = num_steps*(code_duration + 1); //$$
			// Console.WriteLine("total_duration_segment = " + Convert.ToString(total_duration_segment) );
			// Console.WriteLine("code_start             = " + Convert.ToString(code_start   ) );
			// Console.WriteLine("volt_diff              = " + Convert.ToString(volt_diff    ) ); //$$ new para
			// Console.WriteLine("code_diff              = " + Convert.ToString(code_diff    ) ); //$$ new para
			// Console.WriteLine("code_step              = " + Convert.ToString(code_step    ) );
			// Console.WriteLine("num_steps              = " + Convert.ToString(num_steps    ) );
			// Console.WriteLine("code_duration          = " + Convert.ToString(code_duration) );
			
			//long max_duration_a_code__in_flat_segment = Math.Pow(2, 31)-1; // 2^32-1
			//long max_duration_a_code__in_flat_segment = Math.Pow(2, 16)-1; // 2^16-1
			//long max_duration_a_code__in_flat_segment = 16; // 16
			
			int    num_merge_steps = 1;
			double code_start_float = conv_bit_2s_comp_16bit_to_dec(code_start);
			// Console.WriteLine("code_start         = " + Convert.ToString(code_start) );
			// Console.WriteLine("code_start_float   = " + Convert.ToString(code_start_float) );
			//$$ double code_diff_float = conv_bit_2s_comp_16bit_to_dec(code_diff);   //$$  not used
			//$$ // Console.WriteLine("code_diff_float    = " + Convert.ToString(code_diff_float) ); 
			
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
				//$$code_step     = code_step*num_merge_steps; //$$ test // NG must use code_diff
				
				// code_step = conv_dec_to_bit_2s_comp_16bit(code_diff_float * (code_duration+1) / total_duration_segment)
				
			}
			else 
			{
				// as it is ...
			}
			
			
			
            //$$for (int i = 0; i < num_codes; i++)
			long duration_send = total_duration_segment;
			double code_value_float = code_start_float;
			long count_codes = 0; // count number of codes in a segment
			while (true)
            {
				//$$ calculate dac code 
				code_value = (int)conv_dec_to_bit_2s_comp_16bit(code_value_float);
				
                //test_value = (code_value << 16) + code_duration;
                test_str = string.Format("_{0,4:X4}", code_value);
                pulse_info_num_block_str = pulse_info_num_block_str + test_str;
                test_str = string.Format("{0,4:X4}", 0);
                pulse_info_num_block_str = pulse_info_num_block_str + test_str;
                test_str = string.Format("{0,8:X8}", code_duration);
                pulse_info_num_block_str = pulse_info_num_block_str + test_str;
				
				count_codes++; //$$ increase count

                //$$code_list[i] = code_value;
                //$$duration_list[i] = code_duration + 1;
                //$$sample_list[i] = sample_value;

				duration_ns = (code_duration + 1) * (long)time_ns__code_duration;

				//$$ report string
				code_value_str       += string.Format("{0,6:X4}, ", code_value   );
				code_value_float_str += string.Format("{0,6:f3}, ", conv_bit_2s_comp_16bit_to_dec(code_value)  );
				code_duration_str    += string.Format("{0,6:d}, ", code_duration);
				time_ns_str          += string.Format("{0,6:d}, ", time_ns      );
				duration_ns_str      += string.Format("{0,6:d}, ", duration_ns);

				// update code // in float 
				//$$code_value_float += (code_diff_float * (code_duration+1) / total_duration_segment); //$$
				code_value_float += (volt_diff * (code_duration+1) / total_duration_segment); //$$ get more accuracy

                //$$sample_value += code_duration + 1;
                //int code_value_prev = code_value;
                //$$code_value += code_step; //$$ increase DAC code 
				
                //$$ if (code_value > 0xFFFF)
                //$$     code_value -= 0x10000;
				//$$ 
                //$$ if (code_value_prev >= 0x8000 && code_value_prev < 0xC000)
                //$$ {
                //$$     if (code_value <= 0x7FFF && code_value > 0x3FFF)
                //$$         code_value = 0x8000;
                //$$ }
                //$$ else if (code_value_prev <= 0x7FFF && code_value_prev > 0x3FFF)
                //$$ {
                //$$     if (code_value >= 0x8000 && code_value < 0xC000)
                //$$         code_value = 0x7FFF;
                //$$ }
				
				
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

            pulse_info_num_block_str += " \n";
            //sample_code = {code_list, duration_list, sample_list};
			
			//$$ header generation
			string pulse_info_num_block_header_str = String.Format(" #N8_{0,6:D6}", count_codes * 16); //$$ must revise
			
			// merge string 
			pulse_info_num_block_str = pulse_info_num_block_header_str + pulse_info_num_block_str;
			
			//$$ print out
			// Console.WriteLine("code_value (hex) = [" + code_value_str       + "]");
			// Console.WriteLine("code_value_float = [" + code_value_float_str + "]");
			// Console.WriteLine("code_duration    = [" + code_duration_str    + "]");
			// Console.WriteLine("time_ns          = [" + time_ns_str          + "]");
			

            //return Tuple.Create(pulse_info_num_block_str, sample_code); //$$ string 
            //return pulse_info_num_block_str;
			//return (pulse_info_num_block_str, code_value_float_str, time_ns_str, duration_ns_str);
            return Tuple.Create(pulse_info_num_block_str,code_value_float_str,time_ns_str,duration_ns_str);
        }



      

        /*
        public string initialize_aux_io()
        {
            //// Console.WriteLine(String.Format("\n>>>>>"));

            byte[] PGU_AUX_OUTP_Init = Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_OUTP + ":INIT\n");

            string rsp = Convert.ToString(scpi_comm_resp_ss(ss, PGU_AUX_OUTP_Init));

            //    def initialize_aux_io():
            //print('\n>>>>>>')
            //rsp = scpi_comm_resp_ss(ss, cmd_str__PGU_AUX_OUTP+ b':INIT\n')
            return rsp;

        }
        */

        /*
        public void write_aux_io__direct(int para_ctrl)
        {
            //// Console.WriteLine(String.Format("\n>>>>>> write_aux_io__direct"));



            string PGU_AUX_OUTP = Convert.ToString(cmd_str__PGU_AUX_OUTP) + string.Format(" #H{0,4:X4}\n", para_ctrl);
            byte[] PGU_AUX_OUTP_CMD = Encoding.UTF8.GetBytes(PGU_AUX_OUTP);

            scpi_comm_resp_ss(ss, PGU_AUX_OUTP_CMD);

            //def write_aux_io__direct(para_ctrl):
            //print('\n>>>>>> write_aux_io__direct')
            //#
            //para_ctrl_str = '#H{:04X}'.format(para_ctrl).encode()
            //print('{} = {}'.format('para_ctrl_str', para_ctrl_str))
            //#
            //# send command 
            //scpi_comm_resp_ss(ss, cmd_str__PGU_AUX_OUTP+ b' ' +para_ctrl_str + b'\n')
            //-> :PGU:AUX:OUTP 0x000'\n
        }
        */


        public int conv__flt32__raw_int32(float flt32) {
        //  def conv__flt32__raw_int32(flt32):
        //  	bb4 = struct.pack('>f', flt32) # bytearray with 4 bytes or 32 bits
        //  	int32 = struct.unpack('>L', bb4)[0]
        //  	return int32

        //float f = 1234.5678F;
        //var bytes = BitConverter.GetBytes(f);
        //var result = string.Format("0x{0:x}{1:x}{2:x}{3:x}", bytes[0], bytes[1], bytes[2], bytes[3]);

            var bytes  = BitConverter.GetBytes(flt32);
            var result = BitConverter.ToInt32(bytes, 0);

            return (int)result;
        }

        public uint conv__flt32__raw_uint32(float flt32) {
            var bytes  = BitConverter.GetBytes(flt32);
            var result = BitConverter.ToUInt32(bytes, 0);
            return (uint)result;
        }

        public float conv__raw_int32__flt32(int int32) {
        //  def conv__raw_int32__flt32(int32):
        //  	bb4 = struct.pack('>L', int32) # bytearray with 4 bytes or 32 bits
        //  	flt32 = struct.unpack('>f', bb4)[0]
        //  	return flt32
            
            var bytes  = BitConverter.GetBytes(int32);
            var result = BitConverter.ToSingle(bytes, 0);
            return (float)result;
        }

        public float conv__raw_uint32__flt32(uint uint32) {
            var bytes  = BitConverter.GetBytes(uint32);
            var result = BitConverter.ToSingle(bytes, 0);
            return (float)result;
        }

        public string Load_CAL_from_EEPROM() {
            int ret = 0;
            
            // cal_data are all float.
            var dat_at_h40_int = pgu_eeprom__read__data_4byte(0x40);
            var dat_at_h44_int = pgu_eeprom__read__data_4byte(0x44);
            var dat_at_h48_int = pgu_eeprom__read__data_4byte(0x48);
            var dat_at_h4C_int = pgu_eeprom__read__data_4byte(0x4C);

            var dat_at_h40_float = (float)conv__raw_int32__flt32(dat_at_h40_int); // hexa string --> float
            var dat_at_h44_float = (float)conv__raw_int32__flt32(dat_at_h44_int);
            var dat_at_h48_float = (float)conv__raw_int32__flt32(dat_at_h48_int);
            var dat_at_h4C_float = (float)conv__raw_int32__flt32(dat_at_h4C_int);
             
            // check data integrity : not allowed all FF ... NaN
            if               (!Double.IsNaN(dat_at_h40_float)) {
                this.__gui_out_ch1_offset = dat_at_h40_float;
            } else {
                this.__gui_out_ch1_offset = 0.0F; // load safe values for offset
                ret--;
            }
            if               (!Double.IsNaN(dat_at_h44_float)) {
                this.__gui_out_ch2_offset = dat_at_h44_float;
            } else {
                this.__gui_out_ch2_offset = 0.0F; // load safe values for offset
                ret--;
            }
            if               (!Double.IsNaN(dat_at_h48_float)) {
                this.__gui_out_ch1_gain  = dat_at_h48_float;
            } else {
                this.__gui_out_ch1_gain  = 1.0F; // load safe values for scale
                ret--;
            }
            if               (!Double.IsNaN(dat_at_h4C_float)) {
                this.__gui_out_ch2_gain  = dat_at_h4C_float;
            } else {
                this.__gui_out_ch2_gain  = 1.0F; // load safe values for scale
                ret--;
            }

            // print out test
            // Console.WriteLine(this.__gui_out_ch1_offset);
            // Console.WriteLine(this.__gui_out_ch2_offset);
            // Console.WriteLine(this.__gui_out_ch1_gain );
            // Console.WriteLine(this.__gui_out_ch2_gain );
            string ret_str  = "";
            ret_str += "# (1) cal_ch1_offset : " + this.__gui_out_ch1_offset.ToString()  + "\n";
            ret_str += "# (2) cal_ch2_offset : " + this.__gui_out_ch2_offset.ToString()  + "\n";
            ret_str += "# (3) cal_ch1_gain   : " + this.__gui_out_ch1_gain  .ToString()  + "\n";
            ret_str += "# (4) cal_ch2_gain   : " + this.__gui_out_ch2_gain  .ToString()  + "\n";

            return ret_str;
        }

        public int Save_CAL_into_EEPROM(float ch1_offset, float ch2_offset, float ch1_gain = 1.0F, float ch2_gain = 1.0F) {

            this.__gui_out_ch1_offset = ch1_offset; 
            this.__gui_out_ch2_offset = ch2_offset; 
            this.__gui_out_ch1_gain   = ch1_gain  ; 
            this.__gui_out_ch2_gain   = ch2_gain  ;

            return Save_CAL_into_EEPROM();
        }

        public int Save_CAL_into_EEPROM() {

            var dat_at_h40_double = this.__gui_out_ch1_offset;
            var dat_at_h44_double = this.__gui_out_ch2_offset;
            var dat_at_h48_double = this.__gui_out_ch1_gain  ;
            var dat_at_h4C_double = this.__gui_out_ch2_gain  ;

            var dat_at_h40_uint    = conv__flt32__raw_uint32((float)dat_at_h40_double);
            var dat_at_h44_uint    = conv__flt32__raw_uint32((float)dat_at_h44_double);
            var dat_at_h48_uint    = conv__flt32__raw_uint32((float)dat_at_h48_double);
            var dat_at_h4C_uint    = conv__flt32__raw_uint32((float)dat_at_h4C_double);

            pgu_eeprom__write_data_4byte(0x40,dat_at_h40_uint);
            pgu_eeprom__write_data_4byte(0x44,dat_at_h44_uint);
            pgu_eeprom__write_data_4byte(0x48,dat_at_h48_uint);
            pgu_eeprom__write_data_4byte(0x4C,dat_at_h4C_uint);

            return 0;
        }

        public int Set_CAL_Mode (int use_caldata = 1) 
        {
            this.__gui_use_caldata = use_caldata;
            return 0;
        }


        public byte calc_check_sum(byte[] eeprom_LAN_data__bytes) 
        {
            uint pgu_check_sum_residual__uint = 0;
            foreach (var item in eeprom_LAN_data__bytes)
            {
                pgu_check_sum_residual__uint += (uint)item;
            }
            pgu_check_sum_residual__uint %= 256;
            var pgu_check_sum_residual = Convert.ToByte(pgu_check_sum_residual__uint);
            return pgu_check_sum_residual;
        }

        public string conv_hexstr_to_decstr( string hexstr) 
        {
            // C0-A8-64-7F  --> 192.168.100.127
            // Console.WriteLine(hexstr);
            string[] hexstr_split = hexstr.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries);
            // Console.WriteLine(hexstr_split);
            string decstr = "";
            foreach (var item in hexstr_split)
            {
                int value = Convert.ToInt32(item, 16);
                // Console.WriteLine(string.Format("> {0} = {1}", item, Convert.ToDecimal(value)));
                decstr += Convert.ToString(Convert.ToDecimal(value)) + ".";
            }
            decstr = decstr.Remove(decstr.Length-1);
            // Console.WriteLine(decstr);
            return decstr;
        }

        public string conv_decstr_to_hexstr( string decstr) 
        {
            //   192.168.100.127 --> C0-A8-64-7F
            // Console.WriteLine(decstr);
            string[] decstr_split = decstr.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
            //// Console.WriteLine(decstr_split);
            string hexstr = "";
            foreach (var item in decstr_split)
            {
                // Console.WriteLine(string.Format("> {0} = {1}", item, int.Parse(item).ToString("X2") ));
                hexstr += int.Parse(item).ToString("X2") + "-";
            }
            hexstr = hexstr.Remove(hexstr.Length-1);
            // Console.WriteLine(hexstr);
            return hexstr;
        }


        public byte[] conv_decstr_to_bytes ( string decstr) 
        {
            //   192.168.100.127 --> C0-A8-64-7F
            // Console.WriteLine(decstr);
            string[] decstr_split = decstr.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
            //// Console.WriteLine(decstr_split);

            var ret = new byte[decstr_split.Length];
            var ii = 0;
            foreach (var item in decstr_split)
            {
                // Console.WriteLine(string.Format("> {0} = {1}", item, int.Parse(item).ToString("X2") ));
                ret[ii] = (byte)int.Parse(item);
                ii++;
            }
            //// Console.WriteLine(Convert.ToHexString(ret));
            return ret;
        }

        public string Read_IDN() 
        {
            var idn_str = get_IDN();
            this.__gui_pgu_idn_txt = idn_str.ToCharArray();
            return idn_str;
        }

        public string Load_INFO_from_EEPROM() 
        {
            //// read eeprom and copy info to members

            // read eeprom read header 16B * 4 = 64B
            var eeprom_data_at_00__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x00) );
            var eeprom_data_at_04__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x04) );
            var eeprom_data_at_08__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x08) );
            var eeprom_data_at_0C__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x0C) );
            var eeprom_data_at_10__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x10) );
            var eeprom_data_at_14__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x14) );
            var eeprom_data_at_18__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x18) );
            var eeprom_data_at_1C__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x1C) );
            var eeprom_data_at_20__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x20) );
            var eeprom_data_at_24__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x24) );
            var eeprom_data_at_28__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x28) );
            var eeprom_data_at_2C__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x2C) );
            var eeprom_data_at_30__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x30) );
            var eeprom_data_at_34__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x34) );
            var eeprom_data_at_38__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x38) );
            var eeprom_data_at_3C__bytes = BitConverter.GetBytes( pgu_eeprom__read__data_4byte(0x3C) );

            // bytes merge 
            var eeprom_data_at_0X__bytes = new byte[16];
            var eeprom_data_at_1X__bytes = new byte[16];
            var eeprom_data_at_2X__bytes = new byte[16];
            var eeprom_data_at_3X__bytes = new byte[16];
            //
            var eeprom_LAN_data__bytes   = new byte[32];
            //
            Array.Copy(eeprom_data_at_00__bytes,0,eeprom_data_at_0X__bytes,0x0, 4);
            Array.Copy(eeprom_data_at_04__bytes,0,eeprom_data_at_0X__bytes,0x4, 4);
            Array.Copy(eeprom_data_at_08__bytes,0,eeprom_data_at_0X__bytes,0x8, 4);
            Array.Copy(eeprom_data_at_0C__bytes,0,eeprom_data_at_0X__bytes,0xC, 4);
            //
            Array.Copy(eeprom_data_at_10__bytes,0,eeprom_data_at_1X__bytes,0x0, 4);
            Array.Copy(eeprom_data_at_14__bytes,0,eeprom_data_at_1X__bytes,0x4, 4);
            Array.Copy(eeprom_data_at_18__bytes,0,eeprom_data_at_1X__bytes,0x8, 4);
            Array.Copy(eeprom_data_at_1C__bytes,0,eeprom_data_at_1X__bytes,0xC, 4);
            //
            Array.Copy(eeprom_data_at_20__bytes,0,eeprom_data_at_2X__bytes,0x0, 4);
            Array.Copy(eeprom_data_at_24__bytes,0,eeprom_data_at_2X__bytes,0x4, 4);
            Array.Copy(eeprom_data_at_28__bytes,0,eeprom_data_at_2X__bytes,0x8, 4);
            Array.Copy(eeprom_data_at_2C__bytes,0,eeprom_data_at_2X__bytes,0xC, 4);
            //
            Array.Copy(eeprom_data_at_30__bytes,0,eeprom_data_at_3X__bytes,0x0, 4);
            Array.Copy(eeprom_data_at_34__bytes,0,eeprom_data_at_3X__bytes,0x4, 4);
            Array.Copy(eeprom_data_at_38__bytes,0,eeprom_data_at_3X__bytes,0x8, 4);
            Array.Copy(eeprom_data_at_3C__bytes,0,eeprom_data_at_3X__bytes,0xC, 4);
            //
            Array.Copy(eeprom_data_at_1X__bytes,0,eeprom_LAN_data__bytes,0x00, 16);
            Array.Copy(eeprom_data_at_2X__bytes,0,eeprom_LAN_data__bytes,0x10, 16);
            //
            // Console.WriteLine(BitConverter.ToString(eeprom_data_at_0X__bytes));
            // Console.WriteLine(BitConverter.ToString(eeprom_data_at_1X__bytes));
            // Console.WriteLine(BitConverter.ToString(eeprom_data_at_2X__bytes));
            // Console.WriteLine(BitConverter.ToString(eeprom_data_at_3X__bytes));
            // Console.WriteLine(BitConverter.ToString(eeprom_LAN_data__bytes  ));


            // collect data from eeprom:
            //  bytes   ... eeprom_data_at_0X__bytes
            //  str     ... eeprom_data_at_0X__str
            //  hex_str ... eeprom_data_at_0X__hexstr
            //
            //(1)  
            var model_name = new char[16];
            Array.Copy(eeprom_data_at_0X__bytes,0,model_name,0, 16);
            //(2)
            var pgu_ip_adrs        = new char[16];
            var pgu_ip_adrs__bytes = new byte[4];
            Array.Copy(eeprom_data_at_1X__bytes,0x0,pgu_ip_adrs__bytes,0, 4);
            string pgu_ip_adrs__decstr = conv_hexstr_to_decstr(BitConverter.ToString(pgu_ip_adrs__bytes));
            pgu_ip_adrs = pgu_ip_adrs__decstr.ToCharArray();
            //(3)
            var pgu_sm_adrs = new char[16];
            var pgu_sm_adrs__bytes = new byte[4];
            Array.Copy(eeprom_data_at_1X__bytes,0x4,pgu_sm_adrs__bytes,0, 4);
            string pgu_sm_adrs__decstr = conv_hexstr_to_decstr(BitConverter.ToString(pgu_sm_adrs__bytes));
            pgu_sm_adrs = pgu_sm_adrs__decstr.ToCharArray();
            //(4)
            var pgu_ga_adrs = new char[16];
            var pgu_ga_adrs__bytes = new byte[4];
            Array.Copy(eeprom_data_at_1X__bytes,0x8,pgu_ga_adrs__bytes,0, 4);
            string pgu_ga_adrs__decstr = conv_hexstr_to_decstr(BitConverter.ToString(pgu_ga_adrs__bytes));
            pgu_ga_adrs = pgu_ga_adrs__decstr.ToCharArray();
            //(5)
            var pgu_dns_adrs = new char[16];
            var pgu_dns_adrs__bytes = new byte[4];
            Array.Copy(eeprom_data_at_1X__bytes,0xC,pgu_dns_adrs__bytes,0, 4);
            string pgu_dns_adrs__decstr = conv_hexstr_to_decstr(BitConverter.ToString(pgu_dns_adrs__bytes));
            pgu_dns_adrs = pgu_dns_adrs__decstr.ToCharArray();
            //(6)
            var pgu_mac_adrs = new char[12];
            Array.Copy(eeprom_data_at_2X__bytes,0,pgu_mac_adrs,0, 12);
            //(7)
            var pgu_slot_id   = new char[2]; // located at 0x2C-0x2D // char[2] --> char[1]
            Array.Copy(eeprom_data_at_2X__bytes,0xC,pgu_slot_id,0, 2);
            //(8)
            var pgu_user_id   = eeprom_data_at_2X__bytes[0xE]; // located at 0x2E 
            var pgu_check_sum = eeprom_data_at_2X__bytes[0xF]; // located at 0x2F
            byte pgu_check_sum_residual = calc_check_sum(eeprom_LAN_data__bytes); // byte sum at 0x10 - 0x2F // for network setup integrity
            //(9)
            var pgu_user_txt = new char[16];
            Array.Copy(eeprom_data_at_3X__bytes,0,pgu_user_txt,0, 16);

            // print out
            // Console.WriteLine(">  Load_INFO_from_EEPROM() ...     ");
            // Console.WriteLine(">>> (1) model_name             : " + new string(model_name    )          );
            // Console.WriteLine(">>> (2) pgu_ip_adrs            : " + new string(pgu_ip_adrs   )          );
            // Console.WriteLine(">>> (3) pgu_sm_adrs            : " + new string(pgu_sm_adrs   )          );
            // Console.WriteLine(">>> (4) pgu_ga_adrs            : " + new string(pgu_ga_adrs   )          );
            // Console.WriteLine(">>> (5) pgu_dns_adrs           : " + new string(pgu_dns_adrs  )          );
            // Console.WriteLine(">>> (6) pgu_mac_adrs           : " + new string(pgu_mac_adrs  )          );
            // Console.WriteLine(">>> (7) pgu_slot_id            : " + new string(pgu_slot_id   )          );
            // Console.WriteLine(">>> (8) pgu_user_id            : " + pgu_user_id.ToString()              );
            // Console.WriteLine(">>> (*) pgu_check_sum          : " + pgu_check_sum.ToString()            );
            // Console.WriteLine(">>> (*) pgu_check_sum_residual : " + pgu_check_sum_residual.ToString()   );
            // Console.WriteLine(">>> (9) pgu_user_txt           : " + new string(pgu_user_txt  )          );
            string ret_str = "";
            // Console.WriteLine(">  Load_INFO_from_EEPROM() ...     ");
            ret_str += "# (1) model_name         char[16] : " + new string(model_name    )        + "\n";
            ret_str += "# (2) ip_adrs            char[16] : " + new string(pgu_ip_adrs   )        + "\n";
            ret_str += "# (3) sm_adrs            char[16] : " + new string(pgu_sm_adrs   )        + "\n";
            ret_str += "# (4) ga_adrs            char[16] : " + new string(pgu_ga_adrs   )        + "\n";
            ret_str += "# (5) dns_adrs           char[16] : " + new string(pgu_dns_adrs  )        + "\n";
            ret_str += "# (6) mac_adrs           char[12] : " + new string(pgu_mac_adrs  )        + "\n";
            ret_str += "# (7) slot_id            char[2]  : " + new string(pgu_slot_id   )        + "\n";
            ret_str += "# (8) user_id            byte     : " + pgu_user_id.ToString()            + "\n";
            ret_str += "# (*) check_sum          byte     : " + pgu_check_sum.ToString()          + "\n";
            ret_str += "# (*) check_sum_residual byte     : " + pgu_check_sum_residual.ToString() + "\n";
            ret_str += "# (9) user_txt           char[16] : " + new string(pgu_user_txt  )        + "\n";

            // copy to members
            //...
            this.__gui_pgu_model_name          = new string(model_name  ).ToCharArray(); // (1)
            this.__gui_pgu_ip_adrs             = new string(pgu_ip_adrs ).ToCharArray(); // (2)
            this.__gui_pgu_sm_adrs             = new string(pgu_sm_adrs ).ToCharArray(); // (3)
            this.__gui_pgu_ga_adrs             = new string(pgu_ga_adrs ).ToCharArray(); // (4)
            this.__gui_pgu_dns_adrs            = new string(pgu_dns_adrs).ToCharArray(); // (5)
            this.__gui_pgu_mac_adrs            = new string(pgu_mac_adrs).ToCharArray(); // (6)
            this.__gui_pgu_slot_id             = new string(pgu_slot_id ).ToCharArray(); // (7)
            this.__gui_pgu_user_id             = pgu_user_id                           ; // (8)
            this.__gui_pgu_check_sum           = pgu_check_sum                         ; // (*)
            this.__gui_pgu_check_sum_residual  = pgu_check_sum_residual                ; // (*)
            this.__gui_pgu_user_txt            = new string(pgu_user_txt).ToCharArray(); // (9)

            //return pgu_check_sum_residual; //$$ 0 for valid INFO, non-zero for check sum error.
            return ret_str;
        }

        public int Save_INFO_into_EEPROM(
            char[] model_name   ,
            char[] ip_adrs  ,
            char[] sm_adrs  ,
            char[] ga_adrs  ,
            char[] dns_adrs ,
            char[] mac_adrs ,
            char[] slot_id  , 
            byte   user_id  , 
            char[] user_txt ) 
        {
            //// update members and save them into eeprom
            if (model_name.Length > 0) this.__gui_pgu_model_name   = model_name; // (1) 
            if (ip_adrs   .Length > 0) this.__gui_pgu_ip_adrs      = ip_adrs   ; // (2)
            if (sm_adrs   .Length > 0) this.__gui_pgu_sm_adrs      = sm_adrs   ; // (3)
            if (ga_adrs   .Length > 0) this.__gui_pgu_ga_adrs      = ga_adrs   ; // (4)
            if (dns_adrs  .Length > 0) this.__gui_pgu_dns_adrs     = dns_adrs  ; // (5)
            if (mac_adrs  .Length > 0) this.__gui_pgu_mac_adrs     = mac_adrs  ; // (6)
            if (slot_id   .Length > 0) this.__gui_pgu_slot_id      = slot_id   ; // (7)
            this.__gui_pgu_user_id                                 = user_id   ; // (8)
            if (user_txt  .Length > 0) this.__gui_pgu_user_txt     = user_txt  ; // (9)

            // convert members to bytes
            var eeprom_data_at_0X__bytes = new byte[16];
            var eeprom_data_at_1X__bytes = new byte[16];
            var eeprom_data_at_2X__bytes = new byte[16];
            var eeprom_data_at_3X__bytes = new byte[16];

            // 0X, 3X
            Array.Copy(Encoding.UTF8.GetBytes(this.__gui_pgu_model_name  ),0, eeprom_data_at_0X__bytes,0x0, 16); // (1) model_name   // simple text // write without checksum
            Array.Copy(Encoding.UTF8.GetBytes(this.__gui_pgu_user_txt),0, eeprom_data_at_3X__bytes,0x0, 16); // (9) pgu_user_txt // simple text // write without checksum
            // 1X : ip addresses
            Array.Copy( conv_decstr_to_bytes( new string(this.__gui_pgu_ip_adrs ) ),0, eeprom_data_at_1X__bytes,0x0, 4); // (2)
            Array.Copy( conv_decstr_to_bytes( new string(this.__gui_pgu_sm_adrs ) ),0, eeprom_data_at_1X__bytes,0x4, 4); // (3)
            Array.Copy( conv_decstr_to_bytes( new string(this.__gui_pgu_ga_adrs ) ),0, eeprom_data_at_1X__bytes,0x8, 4); // (4)
            Array.Copy( conv_decstr_to_bytes( new string(this.__gui_pgu_dns_adrs) ),0, eeprom_data_at_1X__bytes,0xC, 4); // (5)
            // 2X
            Array.Copy(Encoding.UTF8.GetBytes(this.__gui_pgu_mac_adrs),0, eeprom_data_at_2X__bytes,0x0, 12); // (6)
            Array.Copy(Encoding.UTF8.GetBytes(this.__gui_pgu_slot_id ),0, eeprom_data_at_2X__bytes,0xC, 2 ); // (7)
            eeprom_data_at_2X__bytes[0xE] = this.__gui_pgu_user_id   ; //(8)
            eeprom_data_at_2X__bytes[0xF] = this.__gui_pgu_check_sum ; //(*)

            // calculate check sum 
            var eeprom_LAN_data__bytes__checksum   = new byte[31];
            Array.Copy(eeprom_data_at_1X__bytes,0,eeprom_LAN_data__bytes__checksum,0x00, 16);
            Array.Copy(eeprom_data_at_2X__bytes,0,eeprom_LAN_data__bytes__checksum,0x10, 15); // 15

            var cc =  -((int)calc_check_sum( eeprom_LAN_data__bytes__checksum ));
            var new_check_sum = (byte)cc;
            eeprom_data_at_2X__bytes[0xF] = new_check_sum;
            this.__gui_pgu_check_sum      = new_check_sum; //(*)

            var eeprom_LAN_data__bytes   = new byte[32];
            Array.Copy(eeprom_data_at_1X__bytes,0,eeprom_LAN_data__bytes,0x00, 16);
            Array.Copy(eeprom_data_at_2X__bytes,0,eeprom_LAN_data__bytes,0x10, 16);
            byte pgu_check_sum_residual = calc_check_sum(eeprom_LAN_data__bytes); // byte sum at 0x10 - 0x2F // for network setup integrity


            // print out
            // Console.WriteLine(">  Save_INFO_into_EEPROM() ...     ");
            // Console.WriteLine(">>> (1) model_name             : " + new string(this.__gui_pgu_model_name    )          );
            // Console.WriteLine(">>> (2) pgu_ip_adrs            : " + new string(this.__gui_pgu_ip_adrs   )          ); // protected by check sum
            // Console.WriteLine(">>> (3) pgu_sm_adrs            : " + new string(this.__gui_pgu_sm_adrs   )          ); // protected by check sum
            // Console.WriteLine(">>> (4) pgu_ga_adrs            : " + new string(this.__gui_pgu_ga_adrs   )          ); // protected by check sum
            // Console.WriteLine(">>> (5) pgu_dns_adrs           : " + new string(this.__gui_pgu_dns_adrs  )          ); // protected by check sum
            // Console.WriteLine(">>> (6) pgu_mac_adrs           : " + new string(this.__gui_pgu_mac_adrs  )          ); // protected by check sum
            // Console.WriteLine(">>> (7) pgu_slot_id            : " + new string(this.__gui_pgu_slot_id   )          ); // protected by check sum
            // Console.WriteLine(">>> (8) pgu_user_id            : " + this.__gui_pgu_user_id.ToString()              ); // protected by check sum
            // Console.WriteLine(">>> (*) pgu_check_sum          : " + this.__gui_pgu_check_sum.ToString()            ); // protected by check sum
            // Console.WriteLine(">>> (*) pgu_check_sum_residual : " + this.__gui_pgu_check_sum_residual.ToString()   ); // protected by check sum
            // Console.WriteLine(">>> (9) pgu_user_txt           : " + new string(this.__gui_pgu_user_txt  )          );


            //// save them into eeprom

            // 0X
            pgu_eeprom__write_data_4byte(0x00, BitConverter.ToUInt32(eeprom_data_at_0X__bytes, 0x0)); // (1) model_name
            pgu_eeprom__write_data_4byte(0x04, BitConverter.ToUInt32(eeprom_data_at_0X__bytes, 0x4)); // (1) model_name
            pgu_eeprom__write_data_4byte(0x08, BitConverter.ToUInt32(eeprom_data_at_0X__bytes, 0x8)); // (1) model_name
            pgu_eeprom__write_data_4byte(0x0C, BitConverter.ToUInt32(eeprom_data_at_0X__bytes, 0xC)); // (1) model_name

            // 3X
            pgu_eeprom__write_data_4byte(0x30, BitConverter.ToUInt32(eeprom_data_at_3X__bytes, 0x0)); // (9) pgu_user_txt
            pgu_eeprom__write_data_4byte(0x34, BitConverter.ToUInt32(eeprom_data_at_3X__bytes, 0x4)); // (9) pgu_user_txt
            pgu_eeprom__write_data_4byte(0x38, BitConverter.ToUInt32(eeprom_data_at_3X__bytes, 0x8)); // (9) pgu_user_txt
            pgu_eeprom__write_data_4byte(0x3C, BitConverter.ToUInt32(eeprom_data_at_3X__bytes, 0xC)); // (9) pgu_user_txt

            // 1X, 2X ... after checksum
            if (pgu_check_sum_residual != 0) {
                return -1; // check sum error
            }
            pgu_eeprom__write_data_4byte(0x10, BitConverter.ToUInt32(eeprom_data_at_1X__bytes, 0x0)); // 
            pgu_eeprom__write_data_4byte(0x14, BitConverter.ToUInt32(eeprom_data_at_1X__bytes, 0x4)); // 
            pgu_eeprom__write_data_4byte(0x18, BitConverter.ToUInt32(eeprom_data_at_1X__bytes, 0x8)); // 
            pgu_eeprom__write_data_4byte(0x1C, BitConverter.ToUInt32(eeprom_data_at_1X__bytes, 0xC)); // 

            pgu_eeprom__write_data_4byte(0x20, BitConverter.ToUInt32(eeprom_data_at_2X__bytes, 0x0)); // 
            pgu_eeprom__write_data_4byte(0x24, BitConverter.ToUInt32(eeprom_data_at_2X__bytes, 0x4)); // 
            pgu_eeprom__write_data_4byte(0x28, BitConverter.ToUInt32(eeprom_data_at_2X__bytes, 0x8)); // 
            pgu_eeprom__write_data_4byte(0x2C, BitConverter.ToUInt32(eeprom_data_at_2X__bytes, 0xC)); // 



            return 0;
        }



        //$$public void InitializePGU(double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm = 50 , int use_caldata = 0 )
        public void InitializePGU(double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm = 50 ,
            int set_new_caldate = 0, float offset_ch1 = 0.0F, float offset_ch2 = 0.0F, float gain_ch1 = 1.0F, float gain_ch2 = 1.0F )
        {
            //string LogFileName;
            //$$LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit
            //LogFileName = Path.Combine(LogFilePath, "Debugger.py");

            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false))
                    ws.WriteLine("## Debuger Start"); //$$ add python comment header
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false))
                    ws.WriteLine("## Debuger Start"); //$$ add python comment header
            }

            uint val_b16 = 0x0808;

            pgu_aux_con__send(val_b16);
            string ret = pgu_aux_con__read();

            uint OLAT = 0x0000;
            uint IODIR = 0x000F;
            pgu_aux_olat__send(OLAT);
            pgu_aux_dir__send(IODIR);
            
            //
            this.time_ns__dac_update = time_ns__dac_update;
            this.time_ns__code_duration = time_ns__code_duration;
            this.scale_voltage_10V_mode = scale_voltage_10V_mode;
            this.output_impedance_ohm = output_impedance_ohm; //$$ output_impedance_ohm is for board output at norminal value of 50ohm

            //load caldata 
            var use_caldata = this.__gui_use_caldata;
            if (use_caldata == 1) { // case of using cal data
                if(set_new_caldate == 1) {
                    // save cal_data into eeprom
                    Save_CAL_into_EEPROM(offset_ch1, offset_ch2, gain_ch1, gain_ch2);
                }
                else {
                    // load cal_data from eeprom 
                    //Load_CAL_from_EEPROM(); // or we can use them without loading.
                }
            }
            else { // case without cal data
                // reset cal_data
                //this.__gui_out_ch1_offset = 0.0F; 
                //this.__gui_out_ch2_offset = 0.0F; 
                //this.__gui_out_ch1_gain   = 1.0F;
                //this.__gui_out_ch2_gain   = 1.0F;
            }

            //$$ note ... hardware support freq: 20MHz, 50MHz, 80MHz, 100MHz, 200MHz(default), 400MHz.
            pgu_freq__send(time_ns__dac_update);


            double DAC_full_scale_current__mA = 25.5; // 20.1Vpp
            pgu_gain__send(1, DAC_full_scale_current__mA);
            pgu_gain__send(2, DAC_full_scale_current__mA);


            float DAC_offset_current__mA = 0; // 0 min // # 0.625 mA
            //float DAC_offset_current__mA = 1; // 
            //float DAC_offset_current__mA = 2; // 2 max
            int N_pol_sel = 1; // 1
            int Sink_sel = 1; // 1
            pgu_ofst__send(1, DAC_offset_current__mA, N_pol_sel, Sink_sel);
            pgu_ofst__send(2, DAC_offset_current__mA, N_pol_sel, Sink_sel);


            //write_aux_io__direct(0x3F00 & 0xFCFF);
        }

		//$$ TODO: set_setup_pgu
        //public Tuple<int[], string[]> set_setup_pgu(int Ch, int[] time_ns_list, double[] level_volt_list)
        //public Tuple<long[], string[]> set_setup_pgu(int Ch, int OutputRange, long[] time_ns_list, double[] level_volt_list)
        public Tuple<long[], string[], long> set_setup_pgu(int Ch, int OutputRange, long[] time_ns_list, double[] level_volt_list)
        //$$public Tuple<long[], string[], long> set_setup_pgu(int Ch, int OutputRange, long[] time_ns_list, double[] level_volt_list,
        //$$    double offset_ch1 = 0.0, double offset_ch2 = 0.0, double scale__ch1 = 1.0, double scale__ch2 = 1.0 )
        {          

			//time_ns__dac_update = this.time_ns__dac_update; //$$
			
            double gui_out_ch1_gain   = this.__gui_out_ch1_gain ; // = 0.95;
            double gui_out_ch2_gain   = this.__gui_out_ch2_gain ; // = 1.0;
            double gui_out_ch1_offset = this.__gui_out_ch1_offset; // = -0.01;
            double gui_out_ch2_offset = this.__gui_out_ch2_offset; // = 0.10;

            double gui_out_scale  = 1.0;
            double gui_out_offset = 0.0;

            string Timedata;
            string Timedata_str = "";

            string Vdata;
            string Vdata_str = "";


            // time_ns_list
            for (int i = 0; i < time_ns_list.Length; i++)
            {
                //Timedata = Convert.ToString(time_ns_list[i]) + ", ";
				//$$Timedata = string.Format("{0,6:f3}, ",time_ns_list[i]);
				Timedata = string.Format("{0,6:d}, ",time_ns_list[i]);
                Timedata_str = Timedata_str + Timedata;
            }

            for (int i = 0; i < level_volt_list.Length; i++)
            {
                //Vdata = Convert.ToString(level_volt_list[i]) + ", ";
				Vdata = string.Format("{0,6:f3}, ",level_volt_list[i]);
                Vdata_str = Vdata_str + Vdata;
            }

            //string LogFileName;
            //LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                 ws.WriteLine("####$$$$------------------------------------------->>>>>>");
                 ws.WriteLine("Tdata_usr = [" + Timedata_str + "]");
			}
			// Console.WriteLine("Tdata_usr = [" + Timedata_str + "]");

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                 ws.WriteLine("Vdata_usr = [" + Vdata_str + "] \n");
			// Console.WriteLine("Vdata_usr = [" + Vdata_str + "] \n");

            var use_caldata = this.__gui_use_caldata;
            if (use_caldata == 1) {
                if (Ch == 1)
                {
                    gui_out_scale  = gui_out_ch1_gain;
                    gui_out_offset = gui_out_ch1_offset;
                }
                else //$$ ch == 2
                {
                    gui_out_scale  = gui_out_ch2_gain;
                    gui_out_offset = gui_out_ch2_offset;
                }
            } else {
                gui_out_scale  = 1.0;
                gui_out_offset = 0.0;
            }

            double Devide_V = 1; //$$ int --> double

            if (OutputRange == 40)
            {
                Devide_V = 4;
                scale_voltage_10V_mode = (6.95 / 10);
            }

            scale_voltage_10V_mode = scale_voltage_10V_mode * ((output_impedance_ohm + __gui_load_impedance_ohm) / __gui_load_impedance_ohm);
            // Console.WriteLine("output_impedance_ohm     = " + Convert.ToString(output_impedance_ohm    ));
            // Console.WriteLine("__gui_load_impedance_ohm = " + Convert.ToString(__gui_load_impedance_ohm));
            // Console.WriteLine("scale_voltage_10V_mode   = " + Convert.ToString(scale_voltage_10V_mode  ));

			string level_volt_list_str = ""; //$$
            for (int i = 0; i < level_volt_list.Length; i++) //$$ for (int i = 1; i < level_volt_list.Length; i++) //$$ from i = 0
            {
				// # HVPGU B/D 사용 시 Gain 4배 증폭, Base전압을 1/4로 감소해야 함.
                //$$level_volt_list[i] = level_volt_list[i] * scale_voltage_10V_mode / Devide_V;  
                //$$level_volt_list[i]     = level_volt_list[i] * scale_voltage_10V_mode / Devide_V * gui_out_scale + gui_out_offset; //$$ NG due to 10V scaling
                level_volt_list[i]     = (level_volt_list[i]* gui_out_scale + gui_out_offset) * scale_voltage_10V_mode / Devide_V; 

				
				// update string 
				level_volt_list_str += string.Format("{0,6:f3}, ",level_volt_list[i]);
            }
			// Console.WriteLine("level_volt_list = [" + level_volt_list_str + "]");

			//$$ scale data check 
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                 ws.WriteLine("Tdata_cmd = [" + Timedata_str        + "]"); // time point
                 ws.WriteLine("Vdata_cmd = [" + level_volt_list_str + "] \n"); // voltage value
			}                            
			// Console.WriteLine("Tdata_cmd = [" + Timedata_str        + "]"); // time point
			// Console.WriteLine("Vdata_cmd = [" + level_volt_list_str + "] \n"); // voltage value
			

            long[] num_steps_list = new long[time_ns_list.Length - 1];
            //long[] num_steps_list = new long[time_ns_list.Length - 1];

            //#lyh_201221_rev
            //this.__gui_min_num_interpol = interpol;
            //int min_num_interpol = 20;

            int Point_NUM = Convert.ToInt32(1000 / (num_steps_list.Length));    //$$ FIFO Count limit 
			// Console.WriteLine("Point_NUM = " + Convert.ToString(Point_NUM));

			string num_steps_list_str = ""; //$$
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				num_steps_list[i - 1] = Convert.ToInt64(((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__code_duration));  //$$ number of DAC points in eash segment

				//
				num_steps_list_str += string.Format("{0,6:d}, ",num_steps_list[i - 1]);
            }
			// Console.WriteLine("num_steps_list       = [" + num_steps_list_str + "]");
            //#lyh_201221_rev

			string level_diff_volt_list_str = ""; //$$
            double[] level_diff_volt_list = new double[level_volt_list.Length - 1];
			num_steps_list_str = ""; //$$ clear
            for (int i = 1; i < level_volt_list.Length; i++)
            {
                level_diff_volt_list[i - 1] = level_volt_list[i] - level_volt_list[i - 1]; //$$ dac incremental value in each segment
				level_diff_volt_list_str += string.Format("{0,6:f3}, ", level_diff_volt_list[i - 1]);
				
            }
			//  // Console.WriteLine("num_steps_list       = [" + num_steps_list_str + "]");
			// Console.WriteLine("level_diff_volt_list = [" + level_diff_volt_list_str + "]");

            int[] level_code_list = new int[level_volt_list.Length];
            for (int i = 0; i < level_volt_list.Length; i++)
            {
                level_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(level_volt_list[i]); //$$ dac starting code in ease segment
            }

            int[] level_step_code_list = new int[level_diff_volt_list.Length];
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                //$$ num_steps_list[i] == 0 means data duplicate.
                if (num_steps_list[i] > 0) {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) / num_steps_list[i]); //$$ dac incremental code in each segment
                }
                else {
                    level_step_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit(0); //$$ 
                }
                // Console.WriteLine("level_step_code_list[" + Convert.ToString(i) + "] = " + Convert.ToString(level_step_code_list[i]) );
            }
			
			int[] level_diff_code_list = new int[level_diff_volt_list.Length];
            for (int i = 0; i < level_diff_volt_list.Length; i++)
            {
                level_diff_code_list[i] = (int)conv_dec_to_bit_2s_comp_16bit((level_diff_volt_list[i]) ); //$$ dac full difference in each segment
            }

			string   time_step_code_list_str = ""; //$$
            int[]    time_step_code_list        = new int   [time_ns_list.Length - 1];
			double[] time_step_code_double_list = new double[time_ns_list.Length - 1];
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				time_step_code_list[i - 1] = 0; //$$ basic step 1
				
				time_step_code_list_str += string.Format("{0,6:d}, ",time_step_code_list[i - 1]);
            }
			// Console.WriteLine("time_step_code_list = [" + time_step_code_list_str + "]");

            string[] num_block_str__sample_code__list = new string[level_step_code_list.Length];
            int code_start;
			double volt_diff;
			int code_diff;
            int code_step;
            long num_steps;
            //$$int time_step_code; //#201222 lyh_rev
			long time_step_code; //$$
			long time_start_ns; //$$
			
			string merge_code_value_float_str = ""; //$$
			string merge_duration_ns_str      = ""; //$$
			string merge_time_ns_str          = ""; //$$

			long max_duration_a_code__in_flat_segment = Convert.ToInt64(Math.Pow(2, 31)-1); // 2^32-1
			//$$long max_duration_a_code__in_flat_segment = Convert.ToInt64(Math.Pow(2, 16)-1); // 2^16-1
			
			//long max_duration_a_code__in_flat_segment = 16; // 16
			// Console.WriteLine("max_duration_a_code__in_flat_segment = " + Convert.ToString(max_duration_a_code__in_flat_segment));
			
			
			//long max_num_codes__in_slope_segment = (long)16; //Point_NUM;
			long max_num_codes__in_slope_segment = Point_NUM;
			// Console.WriteLine("max_num_codes__in_slope_segment = " + Convert.ToString(max_num_codes__in_slope_segment));
			

            for (int i = 0; i < level_step_code_list.Length; i++)
            {
                code_start     = level_code_list[i];      //$$ dac starting code in each segment
				volt_diff      = level_diff_volt_list[i]; //$$ dac voltage difference in in each segment for max step +/- 20V or more.
				code_diff      = level_diff_code_list[i]; //$$ dac code diff in each segment for better slope shape //$$ NG  with large slope step more than +/-10V
                code_step      = level_step_code_list[i]; //$$ dac incremental code in each segment 
                num_steps      = num_steps_list[i];       //$$ number of DAC points in eash segment
                time_step_code = time_step_code_list[i];  //$$ duration count 32 bit in each segment // share it with all points
				time_start_ns  = time_ns_list[i];         //$$ start time each segment in ns
				
				var ret = gen_pulse_info_num_block__inc_step(code_start, volt_diff, code_diff, code_step, num_steps, time_step_code, 
							time_start_ns, max_duration_a_code__in_flat_segment, max_num_codes__in_slope_segment); //$$ (pulse_info_num_block_str, code_value_float_str, time_ns_str) 

				//num_block_str__sample_code__list[i] = ret.pulse_info_num_block_str;				
				//merge_code_value_float_str += ret.code_value_float_str;
				//merge_time_ns_str          += ret.time_ns_str;
				//merge_duration_ns_str      += ret.duration_ns_str;

				num_block_str__sample_code__list[i] = ret.Item1;				
				merge_code_value_float_str         += ret.Item2;
                merge_time_ns_str                  += ret.Item3;
				merge_duration_ns_str              += ret.Item4;
				
				//$$ update new number of codes 
				string time_ns_str = ret.Item3;
				double[] time_ns_str_double = Array.ConvertAll(time_ns_str.Remove(time_ns_str.Length-2,1).Split(','), Double.Parse);
				// Console.WriteLine("time_ns_str_double        = " + Convert.ToString(time_ns_str_double));
				// Console.WriteLine("time_ns_str_double.Length = " + Convert.ToString(time_ns_str_double.Length));
				num_steps_list[i] = (long)(time_ns_str_double.Length);
				
            }

			
			//$$ print out DAC points in FIFO
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                 ws.WriteLine("Tdata_seg = [" + merge_time_ns_str          + "]"); // time point
                 ws.WriteLine("Ddata_seg = [" + merge_duration_ns_str      + "]"); // duration time
                 ws.WriteLine("Vdata_seg = [" + merge_code_value_float_str + "] \n"); // voltage value
			}                            
			// Console.WriteLine("Tdata_seg = [" + merge_time_ns_str          + "]"); // time point
			// Console.WriteLine("Ddata_seg = [" + merge_duration_ns_str      + "]"); // duration time
			// Console.WriteLine("Vdata_seg = [" + merge_code_value_float_str + "] \n"); // voltage value

			//$$ FIFO count = size of (Tdata_seg)
			double[] Tdata_seg_double = Array.ConvertAll(merge_time_ns_str.Remove(merge_time_ns_str.Length-2,1).Split(','), Double.Parse);
			// Console.WriteLine("Tdata_seg_double = " + Convert.ToString(Tdata_seg_double));
			// Console.WriteLine("Tdata_seg_double.Length = " + Convert.ToString(Tdata_seg_double.Length));
			
			//$$ datacount in FIFO
			long FIFO_Count = Tdata_seg_double.Length;
			// Console.WriteLine("FIFO_Count = " + Convert.ToString(FIFO_Count));
			
			return Tuple.Create(num_steps_list, num_block_str__sample_code__list, FIFO_Count);
            //$$return Tuple.Create(num_steps_list, num_block_str__sample_code__list);
            //return num_block_str__sample_code__list;

        }

        /*
        public void load_pgu_waveform(int Ch, int[] num_block_str__sample_code__list)
        {
            ////// Console.WriteLine(String.Format("\n>>>>>> load_pgu_waveform()"));
            ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC0);
            
            if (Ch == 1)
            {
                for (int k = 0; k < (num_block_str__sample_code__list.Length); k++)
                {
                    string PGU_FDCS_DAC0 = Convert.ToString(cmd_str__PGU_FDCS_DAC0 + num_block_str__sample_code__list[k]);
                    byte[] PGU_FDCS_DAC0_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_DAC0);
                    scpi_comm_resp_ss(ss, PGU_FDCS_DAC0_CMD);
                }
                ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC1);
            }
            else
            {
                for (int k = 0; k < (num_block_str__sample_code__list.Length); k++)
                {
                    string PGU_FDCS_DAC1 = Convert.ToString(cmd_str__PGU_FDCS_DAC1 + num_block_str__sample_code__list[k]);
                    byte[] PGU_FDCS_DAC1_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_DAC1);
                    scpi_comm_resp_ss(ss, PGU_FDCS_DAC1_CMD, BUF_SIZE_NORMAL, INTVAL); //$$ ??
                }
                ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_RPT);
            }


        }
        */

        /*
        public void trig_pgu_output(int pgu_repeat_num, int delay) //$$ unused
        {
            __gui_cycle_count = pgu_repeat_num;
            int pulse_repeat_number_dac0 = __gui_cycle_count;
            int pulse_repeat_number_dac1 = __gui_cycle_count;

            string pgu_repeat_num_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", pulse_repeat_number_dac1, pulse_repeat_number_dac0);


            byte[] PGU_FDCS_RPT_Init = Encoding.UTF8.GetBytes(cmd_str__PGU_FDCS_RPT + pgu_repeat_num_str);

            scpi_comm_resp_ss(ss, PGU_FDCS_RPT_Init);

            ////// Console.WriteLine(String.Format("\n>>>>>> trig_pgu_output()"));

            string PGU_FDCS_TRIG_ON = Convert.ToString(cmd_str__PGU_FDCS_TRIG) + " ON\n";
            byte[] PGU_FDCS_TRIG_ON_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_TRIG_ON);

            ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", PGU_FDCS_TRIG_ON_CMD);

            scpi_comm_resp_ss(ss, PGU_FDCS_TRIG_ON_CMD);

            Delay(delay); //delay 3.5s

            string PGU_FDCS_TRIG_OFF = Convert.ToString(cmd_str__PGU_FDCS_TRIG) + " OFF\n";
            byte[] PGU_FDCS_TRIG_OFF_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_TRIG_OFF);

            ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", PGU_FDCS_TRIG_OFF_CMD);

            scpi_comm_resp_ss(ss, PGU_FDCS_TRIG_OFF_CMD);

        }
        */

        /*
		public Tuple<string, string> set_setup_pgu_Cid(int Ch, int[] time_ns_list, double[] level_volt_list)
        {
            string Timedata;
            string Timedata_str = "";

            string Vdata;
            string Vdata_str = "";

            for (int i = 1; i < time_ns_list.Length; i++)
            {
                Timedata = Convert.ToString(time_ns_list[i] + ",");
                Timedata_str = Timedata_str + Timedata;
            }

            for (int i = 1; i < level_volt_list.Length; i++)
            {
                Vdata = Convert.ToString(level_volt_list[i] + ",");
                Vdata_str = Vdata_str + Vdata;
            }

            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            using (StreamWriter ws = new StreamWriter(LogFileName, false))
                ws.WriteLine("## Debuger Start"); //$$ add python comment header

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("Timedata = [" + Timedata_str + "]");

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("Vdata = [" + Vdata_str + "]");

            scale_voltage_10V_mode = scale_voltage_10V_mode * ((output_impedance_ohm + __gui_load_impedance_ohm) / __gui_load_impedance_ohm);

            double[] level_incr_list = new double[level_volt_list.Length];

            level_incr_list[0] = 0;

            for (int i = 1; i < level_volt_list.Length; i++)
            {
                if ((level_volt_list[i] - level_volt_list[i - 1]) == 0)
                {
                    level_incr_list[i - 1] = 0;
                }
                else
                {
                    level_incr_list[i - 1] = (level_volt_list[i] - level_volt_list[i - 1]) / ((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__dac_update);
                }
            }

            for (int i = 0; i < level_volt_list.Length; i++)
            {
                level_volt_list[i] = level_volt_list[i] * scale_voltage_10V_mode;
            }

            for (int i = 0; i < level_incr_list.Length; i++)
            {
                level_incr_list[i] = level_incr_list[i] * scale_voltage_10V_mode;
            }

            UInt64[] level_code_list = new UInt64[level_volt_list.Length];
            for (int i = 0; i < level_volt_list.Length; i++)
            {
                level_code_list[i] = Convert.ToUInt64(conv_dec_to_bit_2s_comp_16bit(level_volt_list[i]) & 0x000000000000FFFF);
            }

            UInt64[] level_code_inc_list = new UInt64[level_incr_list.Length];
            for (int i = 0; i < level_incr_list.Length; i++)
            {
                level_code_inc_list[i] = Convert.ToUInt64(conv_dec_to_bit_2s_comp_16bit(level_incr_list[i]) & 0x000000000000FFFF);
            }

            int[] duration_code_list = new int[time_ns_list.Length + 1];
            for (int i = 1; i < time_ns_list.Length + 1; i++)
            {
                if (i == time_ns_list.Length)
                {
                    duration_code_list[i - 1] = 0;
                }
                else
                    duration_code_list[i - 1] = Convert.ToInt32(((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__dac_update) - 1);
            }

            Int64 num_codes = level_code_list.Length;
            string pulse_info_num_block_str;
            string len_fifo_data_str;

            len_fifo_data_str = string.Format(" #H{0,8:X8}", num_codes);
            pulse_info_num_block_str = string.Format(" #N8_{0,6:D6}", num_codes * 16);

            UInt64 test_value;
            string test_str;

            UInt64 level_code_Value;
            UInt64 level_code_inc_Value;
            UInt64 duration_code_Value;

            for (int i = 0; i < num_codes; i++)
            {
                level_code_Value = Convert.ToUInt64((level_code_list[i] << 48) & 0xFFFF000000000000);
                level_code_inc_Value = Convert.ToUInt64((level_code_inc_list[i] << 32) & 0x0000FFFF00000000);
                duration_code_Value = Convert.ToUInt64((duration_code_list[i] & 0x00000000FFFFFFFF));

                test_value = level_code_Value + level_code_inc_Value + duration_code_Value;
                test_str = string.Format("_{0,16:X16}", test_value);
                pulse_info_num_block_str = pulse_info_num_block_str + test_str;
            }

            pulse_info_num_block_str += " \n";

            return Tuple.Create(len_fifo_data_str, pulse_info_num_block_str);

        }
		
		*/

        public void load_pgu_waveform_Cid(int Ch, long[] len_fifo_data, string[] pulse_info_num_block_str)
        {
            ////// Console.WriteLine(String.Format("\n>>>>>> load_pgu_waveform()"));
            ////// Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC0);
            //string LogFileName;
            //LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            //using (StreamWriter ws = new StreamWriter(LogFileName, false))
            //    ws.WriteLine("Debuger Start");

            long fifo_data = 0;

            for (int i = 0; i < len_fifo_data.Length; i++)
            {
                fifo_data = fifo_data + len_fifo_data[i];
            }

            //$$string len_fifo_data_str = string.Format(" #H{0,8:X8}", fifo_data);

            pgu_nfdt__send_log(Ch, fifo_data, LogFileName);
                
            for (int i = 0; i < pulse_info_num_block_str.Length; i++)
            {
                pgu_fdac__send_log(Ch, pulse_info_num_block_str[i], LogFileName);
            }
        }

        public void trig_pgu_output_Cid_ON(int CycleCount, bool Ch1, bool Ch2)
        {

            //string LogFileName;
            //LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            //write_aux_io__direct(__gui_aux_io_control & 0xFFFF);  // #Only, Use to 10V PGU
            string ret;

            // send repeat numbers
            if (Ch1)
                pgu_frpt__send_log(1, CycleCount, LogFileName);
            if (Ch2)
                pgu_frpt__send_log(2, CycleCount, LogFileName);

            // 40V-amp control latch reset on
            pgu_aux_olat__send(0x0030);
            // 40V-amp control latch reset off
            pgu_aux_olat__send(0x0000);
            // # 40V-amp sleep_n power on
            pgu_aux_olat__send(0x0300);

            Delay(3); // # Wait 5ms

            // # 40V-amp 40v relay output close 
            pgu_aux_olat__send(0x3300);

            Delay(3);

            // trig and log
            pgu_trig__on_log(Ch1, Ch2, LogFileName);

            ret = pgu_aux_gpio__read();

        }

        public void trig_pgu_output_Cid_OFF()
        {          
            // trig off 
            pgu_trig__off();

            // 40V-amp control latch reset off
            pgu_aux_olat__send(0x0000);

            //write_aux_io__direct(__gui_aux_io_control & 0xFCFF); // #Only, Use to 10V PGU
        }

        //$$public int SetSetupPGU(int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel, 
        //$$    double offset_ch1 = 0.0, double offset_ch2 = 0.0, double scale__ch1 = 1.0, double scale__ch2 = 1.0 )
        public int SetSetupPGU(int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
        //$$public void SetSetupPGU(int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
        //public void SetSetupPGU(int PG_Ch, int OutputRange, double Impedance, int[] StepTime, double[] StepLevel, int interpol)
        {
            int ret = 0;
            //$$ return code | note  
            //$$ ------------+---------------------------------------------
            //$$       0     | OK    
            //$$      -1     | NG due to duplicate date in time-volt pairs (different voltages in the same time)
            //$$      -2     | NG due to FIFO data count overflow
            //$$      -3     | NG due to too few data point 

            int __DATA_COUNT_MIN__ = 2;
            if (StepTime.Length < __DATA_COUNT_MIN__) {
                return -3;
            }

            this.__gui_ch_info = PG_Ch;
            //tjs
            if (OutputRange == 10)
                this.__gui_aux_io_control = 0x3F00; // 10V Range
            else
                this.__gui_aux_io_control = 0x0000; // 40V Range
            //            
            this.__gui_load_impedance_ohm = Impedance; // # ex:   1e6 # 1e6 or 50.0      

            //$$ check duplicate data    
            List<long>   StepTime_List  = new List<long>();
            List<double> StepLevel_List = new List<double>();
            
            // add the first elements into list
            StepTime_List.Add(StepTime[0]);
            StepLevel_List.Add(StepLevel[0]);

            for (int i = 1; i < StepTime.Length; i++)
            {
                if (StepTime[i]  == StepTime[i-1]) {
                    if (StepLevel[i] == StepLevel[i-1] ) {
                        continue; // leave for removing dup data with same voltage
                    } 
                    else {
                        return -1; // not able to remove dup data due to difference voltage
                    }
                    
                }

                StepTime_List.Add(StepTime[i]);
                StepLevel_List.Add(StepLevel[i]);
                
            }


            // You can convert it back to an array if you would like to
            long[] StepTime__no_dup  = StepTime_List.ToArray();
            double[] StepLevel__no_dup = StepLevel_List.ToArray();
            
            //var range = set_setup_pgu(PG_Ch, StepTime, StepLevel);
            //$$var range = set_setup_pgu(PG_Ch, OutputRange, StepTime, StepLevel); //$$ return Tuple<long[], string[]>
            var range = set_setup_pgu(PG_Ch, OutputRange, StepTime__no_dup, StepLevel__no_dup); //$$ return Tuple<long[], string[], int>
            //$$var range = set_setup_pgu(PG_Ch, OutputRange, StepTime__no_dup, StepLevel__no_dup, 
            //$$    offset_ch1, offset_ch2, scale__ch1, scale__ch2 ); //$$ return Tuple<long[], string[], int>


            //$$ check fifo data count
            long __FIFO_DATA_COUNT_MAX__ = 1000;
            if (range.Item3 > __FIFO_DATA_COUNT_MAX__) {
                return -2; // FIFO data count overflow
            }

            // download waveform into FPGA FIFO
            load_pgu_waveform_Cid(PG_Ch, range.Item1, range.Item2); //$$ (int Ch, long[] len_fifo_data, string[] pulse_info_num_block_str)

            return ret;
        }

        public string ForcePGU(int CycleCount, int delay)
        {
            //$$ update repeat info in member
            this.__gui_cycle_count = CycleCount;
            
            //## initialize PGU //$$

            //write_aux_io__direct(__gui_aux_io_control & 0xFFFF);
            trig_pgu_output_Cid_ON(CycleCount, true, true);

            Delay(delay); //delay 3.5s

            trig_pgu_output_Cid_OFF();


            //write_aux_io__direct(__gui_aux_io_control & 0xFCFF);



			//$$ remove below for stable output
			//$$ //### power off 
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " OFF\n"));
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));

            string ret;
            //ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            ret = get_FPGA_TMP();

            //## close socket
            scpi_close();

            return ret;
        }

        public string ForcePGU_ON(int CycleCount, bool Ch1, bool Ch2)
        {
            trig_pgu_output_Cid_ON(CycleCount, Ch1, Ch2);
            string ret;

            ret = pgu_aux_gpio__read();
            //ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            //## close socket

            return ret;
        }

        public string ForcePGU_ON__delayed_OFF(int CycleCount, bool Ch1, bool Ch2, int delay_ms = 3500)
        {
            trig_pgu_output_Cid_ON(CycleCount, Ch1, Ch2);

            Delay(delay_ms); //delay 3.5s

            trig_pgu_output_Cid_OFF();

            string ret;
            ret = pgu_aux_gpio__read();
            //ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            //## close socket

            return ret;
        }
        public string Over_Detected()
        {
            string ret;

            ret = pgu_aux_gpio__read();

            return ret;
        }

        public string ForcePGU_OFF()
        {
            string ret;
            // # Board Temp Check CMD
            //ret = scpi_comm_resp_ss(Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            ret = get_FPGA_TMP();

            trig_pgu_output_Cid_OFF();
            
            //$$ remove below for stable output
			//$$ //### power off 
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " OFF\n"));
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));

            //## close socket
            scpi_close();

            return ret;
        }


		//// test functions 
        public new static string _test() {
            string ret = PGU_control_by_eps._test() + ":_class__TOP_PGU__EPS_SPI_";
            return ret;
        }

		public static int __test_top_pgu()
        {
            Console.WriteLine("Hello, TopInstrument!");

            Console.WriteLine(">>> Some test for command string:");
            // init class
            TOP_PGU__EPS_SPI dev = new TOP_PGU__EPS_SPI();


            //// TODO: locate PGU board on slots // before sys_open
            //dev.SPI_EMUL__set__use_loc_slot(true); // use fixed slot location
            //dev.SPI_EMUL__set__loc_slot (0x0400); // for slot index 10
            //dev.SPI_EMUL__set__loc_group(0x0004); // for M2 spi channel

            //// sys_open
            //Console.WriteLine(">>> sys_open");
            //Console.WriteLine(dev.SysOpen("192.168.100.112"));
            //Console.WriteLine(dev.SysOpen("192.168.100.115"));
            //Console.WriteLine(dev.SysOpen("192.168.100.127"));
            //
            //Console.WriteLine(dev.SysOpen("192.168.168.143")); // test 
            //
            //Console.WriteLine(dev.SysOpen("192.168.100.119")); // test S3000-PGU
            //Console.WriteLine(dev.SysOpen("192.168.100.120")); // test S3000-PGU
            //Console.WriteLine(dev.SysOpen("192.168.100.123"));
            //Console.WriteLine(dev.SysOpen("192.168.100.122"));
            //
            //Console.WriteLine(dev.SysOpen("192.168.100.61", 20000)); //$$ S3100-PGU-TLAN test // BD#1
            //Console.WriteLine(dev.SysOpen("192.168.100.62", 20000)); //$$ S3100-PGU-TLAN test // BD#2
            //Console.WriteLine(dev.SysOpen("192.168.100.63", 20000)); //$$ S3100-PGU-TLAN test // BD#3

            //Console.WriteLine(dev.SysOpen(__test__.Program.test_host_ip)); //$$

            Console.WriteLine(">>> sys_open with slot location info");
            int timeout        = 20000;
            // loc_slot bit 0  = slot location 0
            // loc_slot bit 1  = slot location 1
            // ...
            // loc_slot bit 12 = slot location 12
            //uint loc_slot      = 0x0100; // slot location 8
            //uint loc_slot      = 0x0400; // slot location 10
            //uint loc_slot      = 0x1000; // slot location 12
            // loc_spi_group bit 0 = mother board spi M0
            // loc_spi_group bit 1 = mother board spi M1
            // loc_spi_group bit 2 = mother board spi M2
            //uint loc_spi_group = 0x0004; // spi M2
            //
            Console.WriteLine(dev.SysOpen_loc_slot_spi(__test__.Program.test_host_ip, timeout, 
                __test__.Program.test_loc_slot, __test__.Program.test_loc_spi_group)); //$$

            //// may collect slots information
            // ...


            // test load INFO
            Console.WriteLine(dev.Read_IDN());
            Console.WriteLine(dev.Load_INFO_from_EEPROM());

            //   load cal_data from eeprom
            Console.WriteLine(dev.Load_CAL_from_EEPROM());


            //// test change members
            //var model_name = new string("PGU_CPU_S3000#00").ToCharArray(); // (1)
            //var model_name = new string("PGU_CPU_LAN#1234").ToCharArray(); // (1)
            //var model_name = new string("CMU_CPU_S3000#88").ToCharArray(); // (1)
            //var model_name = new string  ("S3100_PGU_2#9802").ToCharArray(); // (1)
            var model_name = new string("").ToCharArray(); // (1)

            //var pgu_ip_adrs = new string  ("192.168.100.127").ToCharArray(); // (2)
            //var pgu_ip_adrs  = new string  ("192.168.100.112" ).ToCharArray(); // (2)
            //var pgu_ip_adrs = new string  ("192.168.100.88").ToCharArray(); // (2)
            var pgu_ip_adrs = new string  ("").ToCharArray(); // (2)
            

            //var pgu_sm_adrs  = new string  ("255.255.255.0" ).ToCharArray(); // (3)
            var pgu_sm_adrs  = new string  ("" ).ToCharArray(); // (3)
            //var pgu_ga_adrs  = new string  ("0.0.0.0"       ).ToCharArray(); // (4)
            var pgu_ga_adrs  = new string  ("").ToCharArray(); // (4)
            //var pgu_dns_adrs = new string  ("0.0.0.0"       ).ToCharArray(); // (5)
            var pgu_dns_adrs = new string  ("").ToCharArray(); // (5)

            //var pgu_mac_adrs = new string  ("00485533CD0F" ).ToCharArray(); // (6)
            //var pgu_mac_adrs = new string  ("0008DC00CD0F" ).ToCharArray(); // (6)
            //var pgu_mac_adrs = new string  ("0008DC111488" ).ToCharArray(); // (6)
            var pgu_mac_adrs = new string  ("" ).ToCharArray(); // (6)

            //var pgu_slot_id  = new string("56").ToCharArray(); // (7)
            //var pgu_slot_id  = new string("98").ToCharArray(); // (7)
            var pgu_slot_id  = new string("AA").ToCharArray(); // (7)

            //var pgu_user_id = (byte) 32; //(8)
            var pgu_user_id = (byte) 23; //(8)

            //var pgu_user_txt = new string("0123456789ABCDEF").ToCharArray(); // (9)
            //var pgu_user_txt = new string("ACACABAB12123434").ToCharArray(); // (9)
            //var pgu_user_txt = new string  ("LAN_EEPROM_TEST_").ToCharArray(); // (9)
            var pgu_user_txt = new string  ("").ToCharArray(); // (9)
            

            // test save INFO
            dev.Save_INFO_into_EEPROM(
                model_name   ,  // (1)
                pgu_ip_adrs  ,  // (2)
                pgu_sm_adrs  ,  // (3)
                pgu_ga_adrs  ,  // (4)
                pgu_dns_adrs ,  // (5)
                pgu_mac_adrs ,  // (6)
                pgu_slot_id  ,  // (7) 
                pgu_user_id  ,  // (8) 
                pgu_user_txt ); // (9) 
        

            //// test load INFO again
            Console.WriteLine(dev.Load_INFO_from_EEPROM());


            // save cal_data to eeprom
            dev.__gui_out_ch1_offset = (float)(-0.010);
            dev.__gui_out_ch2_offset = (float)(-0.011);
            dev.__gui_out_ch1_gain  =  (float)(1.013);
            dev.__gui_out_ch2_gain  =  (float)(1.012);
            dev.Save_CAL_into_EEPROM();

            //   load cal_data from eeprom
            Console.WriteLine(dev.Load_CAL_from_EEPROM());


            //// bypass AUX control : 
            try
            {
                Console.WriteLine(dev.pgu_aux_io_is_bypassed()); // read status
                dev.pgu_aux_io_bypass_on(); // disable unused aux io control // faster x3
                //dev.pgu_aux_io_bypass_off();  // activate aux io for 40V AMP board
                Console.WriteLine(dev.pgu_aux_io_is_bypassed()); // read status
            }
            catch (Exception e)
            {
                Console.WriteLine("{0} Exception caught.", e);
            }                
            
            //// call pulse setup
            long[] StepTime;
            double[] StepLevel;
            int ret;


            //$$ case 0: init without using cal_data
            dev.Set_CAL_Mode(0);
            dev.InitializePGU(10, 10, 7.650 / 10, 50); // (double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm = 50)

            //$$ case 1: init with new cal_data and save it to EEPROM
            //dev.Set_CAL_Mode(1);
            ////dev.Save_CAL_into_EEPROM(0.01F, -0.01F, 0.9F, 1.1F); // (offset_ch1, offset_ch2, gain_ch1, gain_ch2)
            //dev.Save_CAL_into_EEPROM(0.001F, -0.001F, 0.99F, 1.01F); // (offset_ch1, offset_ch2, gain_ch1, gain_ch2)
            //dev.InitializePGU(10, 10, 7.650 / 10, 50); 

            //$$ case 2: init with cal_data from EEPROM
            //dev.Set_CAL_Mode(1);
            //dev.Load_CAL_from_EEPROM();
            //dev.InitializePGU  (10, 10, 7.650 / 10, 50);                            

            // check cal_data
            Console.WriteLine(dev.__gui_out_ch1_offset);
            Console.WriteLine(dev.__gui_out_ch2_offset);
            Console.WriteLine(dev.__gui_out_ch1_gain );
            Console.WriteLine(dev.__gui_out_ch2_gain );

            // case0 __ // _
            StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 }; // ns
            StepLevel = new double[] { 0.0,  0.0, 10.0, 10.0, 20.0, 20.0,  5.5,  5.5,  0.0,  0.0 }; // V
            ret = dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            ret = dev.SetSetupPGU(2, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

            //          // case1 AA // 0
            //          StepTime = new long[] { 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 };
            //          StepLevel = new double[] { 0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 0.5, 0.5, 0.0, 0.0 };
            //          ret = dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //          
            //			// case2 BB // 1
            //			StepTime  = new long[]   {   0,  500, 2000, 3000, 4000, 5000, 6000, 7000, 8500, 9000 };
            //			StepLevel = new double[] { 0.0,  0.0,  1.0,  1.0,  2.0,  2.0,  0.5,  0.5,  0.0,  0.0 };
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			 
            //			// case3 CC // - 20ns slope
            //			StepTime  = new long[]   {0, 20, 40, 70, 90, 100};
            //			StepLevel = new double[] {0,  0, 20, 20,  0,   0};
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			 
            //			// case4 DD // - 30ns slope
            //			StepTime  = new long[]   {0, 10, 40, 60, 90, 100};
            //			StepLevel = new double[] {0,  0, 20, 20,  0,   0}; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			 
            //			// case5 EE // - 10ns slope1
            //			StepTime  = new long[]   {0, 40, 50, 120, 130, 1000};
            //			StepLevel = new double[] {0,  0, 20,  20,   0,    0}; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			 
            //			// case6 FF // - 10ns slope2
            //			StepTime  = new long[]   {0, 40, 50, 100, 110, 1000};
            //			StepLevel = new double[] {0,  0, 20,  20,   0,    0}; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			
            //			// case7 GG // _7_  //duration of one count duration causes error in repeat pattern
            //			StepTime  = new long[]   {    0,     10,      20,      60,     70,    200};
            //			StepLevel = new double[] {0.000,  0.000, -20.000, -20.000,  0.000,  0.000}; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			 
            //			// case8 HH // _8_  // +/- changing slope 
            //			StepTime  = new long[]   {     0,     10,     40,      60,      90,    100 };
            //			StepLevel = new double[] { 0.000, 20.000, 20.000, -20.000, -20.000,  0.000 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			
            //			// case9 II // _9_ // pulse info 1 :  (0V, 15000ns) + (slope, 200ns) + (-Vgp, 4130000ns) + (slope, 200ns)  ...  4.145400 ms = 4145400 ns
            //			StepTime  = new long[]   {     0, 15000,  15200, 4145200, 4145400 };
            //			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			
            //			// case10 JJ // _10_ // pulse info 2 : (0V, 15000ns) + (slope, 1000ns) + (-Vgp, 4130000ns) + (slope, 1000ns)  ... = 4147000 ns
            //			StepTime  = new long[]   {     0, 15000,   16000, 4146000, 4147000 };
            //			StepLevel = new double[] {     0,     0,   -4.43,   -4.43,       0 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //
            //			// case11 KK // _11_ // pulse info 3 : (0V, 15000ns) + (slope, 100000ns) + (-Vgp, 4130000ns) + (slope, 100000ns)  ... = 4345000 ns
            //			StepTime  = new long[]   {     0, 15000, 115000, 4245000, 4345000 };
            //			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //
            //			// case12 LL // 10s pulse // 10s = 10000000000 ns
            //			StepTime  = new long[]   {     0,  1000,  2000,  8000002000,  8000003000, 10000000000 };
            //			StepLevel = new double[] {     0,     0,     5,           5,           0,           0 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //
            //			// case13 MM // 1s pulse // 10s = 10000000000 ns
            //			StepTime  = new long[]   {     0, 1000000000, 1400000000, 6000000000, 6400000000, 10000000000 };
            //			StepLevel = new double[] { 0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; 
            //			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //			
            //			// case14 NN // 50 ohm output check
            //			StepTime  = new long[]   {     0, 15000, 115000, 4245000, 4345000 };
            //			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
            //			dev.SetSetupPGU(1, 40, 50, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            //
            //			// case15 OO // 0 delay pulse causing duplicate
            //			StepTime  = new long[]   {     0,       00,      200,    15000,     15200,    4145000 };
            //			StepLevel = new double[] { 0.000,    0.000,    -4.43,    -4.43,     0.000,      0.000 }; 
            //			ret = dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)


            // test force 
            dev.ForcePGU_ON__delayed_OFF(4,  true,  false, 3500); // (int CycleCount, bool Ch1, bool Ch2)
            //dev.ForcePGU_ON(5,  true, true); // (int CycleCount, bool Ch1, bool Ch2)
            //dev.ForcePGU_ON(3, true,  false); // (int CycleCount, bool Ch1, bool Ch2)

            Console.WriteLine(">>>>> count_call_scpi = " + Convert.ToString(dev.show_count_call_scpi()));

            // test force again
            dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            dev.SetSetupPGU(2, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
            dev.ForcePGU_ON__delayed_OFF(2,  true,  true, 3500); // (int CycleCount, bool Ch1, bool Ch2)
            //dev.ForcePGU_ON__delayed_OFF(2,  true,  true, 5500); // (int CycleCount, bool Ch1, bool Ch2)
            //dev.ForcePGU_ON(3, true,  true); // (int CycleCount, bool Ch1, bool Ch2)

            Console.WriteLine(">>>>> count_call_scpi = " + Convert.ToString(dev.show_count_call_scpi()));

            //Console.WriteLine("SetSetupPGU return Code = " + Convert.ToString(ret));

            //dev.SysClose(); // close but all controls alive
            dev.SysClose__board_shutdown(); // close with board shutdown and clear init bit

            return 0x3535ACAC;

        }

    }

}


////---- cut off later ----////


//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace __test__
{
    public class Program
    {
        //$$ note: IP ... setup for own LAN port test //{
        
        //public static string test_host_ip = "192.168.168.143"; // test dummy ip 
        public static uint test_loc_slot = 0x0000; // slot dummy // for self LAN port test
        public static uint test_loc_spi_group = 0x0000; // spi dummy outside  // for self LAN port test

        //}

        //public static string test_host_ip = "192.168.100.77"; // S3100-CPU_BD1
        //public static string test_host_ip = "192.168.100.78"; // S3100-CPU_BD2
        //public static string test_host_ip = "192.168.100.79"; // S3100-CPU_BD3

        //public static string test_host_ip = "192.168.100.61"; // S3100-PGU_BD1
        public static string test_host_ip = "192.168.100.62"; // S3100-PGU_BD2
        //public static string test_host_ip = "192.168.100.63"; // S3100-PGU_BD3

        //public static string test_host_ip = "192.168.168.143"; // test dummy ip

        //// S3100 frame slot selection:
        // loc_slot bit 0  = slot location 0`
        // loc_slot bit 1  = slot location 1
        // ...
        // loc_slot bit 12 = slot location 12

        //public static uint test_loc_slot = 0x0004; // slot location 2
        //public static uint test_loc_slot = 0x0010; // slot location 4
        //public static uint test_loc_slot = 0x0040; // slot location 6
        //public static uint test_loc_slot = 0x0100; // slot location 8
        //public static uint test_loc_slot = 0x0200; // slot location 9
        //public static uint test_loc_slot = 0x0400; // slot location 10
        //public static uint test_loc_slot = 0x1000; // slot location 12
        
        //// frame spi channel selection:
        // loc_spi_group bit 0 = mother board spi M0
        // loc_spi_group bit 1 = mother board spi M1
        // loc_spi_group bit 2 = mother board spi M2
        //public static uint test_loc_spi_group = 0x0001; // spi M0 // for GNDU
        //public static uint test_loc_spi_group = 0x0002; // spi M1 // for SMU
        //public static uint test_loc_spi_group = 0x0004; // spi M2 // for PGU CMU
        
        public static void Main(string[] args)
        {
            //Your code goes hereafter
            Console.WriteLine("Hello, world!");

            //call something in TopInstrument
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SCPI_base          ", TopInstrument.SCPI_base._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "EPS_Dev            ", TopInstrument.EPS_Dev._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "SPI_EMUL           ", TopInstrument.SPI_EMUL._test()));
            //Console.WriteLine(string.Format(">>> {0} - {1} ", "PGU_control_by_lan ", TopInstrument.PGU_control_by_lan._test()));
            Console.WriteLine(string.Format(">>> {0} - {1} ", "PGU_control_by_eps ", TopInstrument.PGU_control_by_eps._test()));
            //
            Console.WriteLine(string.Format(">>> {0} - {1} ", "TOP_PGU (alias)    ", TOP_PGU._test())); // using alias
            //
            Console.WriteLine(string.Format(">>> {0} - {1} ", "ADDA_control_by_eps", TopInstrument.ADDA_control_by_eps._test()));

            int ret = 0;
            ret = TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards
            //ret = TopInstrument.SPI_EMUL.__test_spi_emul(); // test SPI EMUL // must locate PGU board on slot // sel_loc_groups=0x0004, sel_loc_slots=0x0400 
            
            // new adc test : adc power on // adc enable // adc init // adc fifo reset // adc update // fifo data read 
            ret = TopInstrument.ADDA_control_by_eps.__test_ADDA_control_by_eps(); 

            //ret = TOP_PGU.__test_top_pgu(); // test PGU control // must locate PGU board on slot // sel_loc_groups=0x0004, sel_loc_slots=0x0400  

            Console.WriteLine(string.Format(">>> ret = 0x{0,8:X8}",ret));

        }
    }
}
