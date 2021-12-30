//// EPS.cs

//// from System_Converter.h
// u16	SYS_HexToHWord(u8 *pData);
// u32	SYS_HexToWord(u8 *pData);
// float SYS_HexToFloat(u8 *pData);
// double SYS_HexToDouble(u8 *pData);
// void SYS_HWordToHex(u16 hWord, u8 *pData);
// void SYS_WordToHex(u32 word, u8 *pData);
// void SYS_FloatToHex(float fData, u8 *pData);
// void SYS_DoubleToHex(double dData, u8 *pData);

//// from top_core_info.h
// enum{
// 	S3000_PGU        = 0xBD,
// 	S3000_CMU        = 0xED,
// 	S3100_GNDU       = 0xA2,
// 	S3100_PGU        = 0xA4,  // alias S3100_PGU_ADDA
// 	S3100_ADDA       = 0xA6,  // alias S3100_CMU_ADDA
// 	E8000_HLSMU      = 0xA7,
// 	S3100_HVSMU      = 0xA8,
// 	S3100_CMU_SUB    = 0xAB
// 	//S3100_CMU_ANAL = 0xAA,  // removed
// 	//S3100_CMU_SIG  = 0xAC   // removed
// };

//// from App_measure.h
// void Delay_ms(UINT32 milisecond);
// void Delay_us(vu32 microsecond);

//// from UserDefine.h
// typedef struct
// {
//     int slotCS;
//     int offset;
// } THlsmuChInfo;

//// from UserDefine.h
// typedef	union{
// 	u8	u8Data[4];
// 	s8	s8Data[4];
// 	u16	u16Data[2];
// 	s16	s16Data[2];
// 	u32	u32Data;
// 	s32	s32Data;
// 	struct{
// 		u8	b0	:1;
// 		u8	b1	:1;
// 		u8	b2	:1;
// 		u8	b3	:1;
// 		u8	b4	:1;
// 		u8	b5	:1;
// 		u8	b6	:1;
// 		u8	b7	:1;
// 		u8	b8	:1;
// 		u8	b9	:1;
// 		u8	b10	:1;
// 		u8	b11	:1;
// 		u8	b12	:1;
// 		u8	b13	:1;
// 		u8	b14	:1;
// 		u8	b15	:1;
// 		u8	b16	:1;
// 		u8	b17	:1;
// 		u8	b18	:1;
// 		u8	b19	:1;
// 		u8	b20	:1;
// 		u8	b21	:1;
// 		u8	b22	:1;
// 		u8	b23	:1;
// 		u8	b24	:1;
// 		u8	b25	:1;
// 		u8	b26	:1;
// 		u8	b27	:1;
// 		u8	b28	:1;
// 		u8	b29	:1;
// 		u8	b30	:1;
// 		u8	b31	:1;
// 	};
// }bitCtrl32_t;


using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;


namespace TopInstrument
{

    using u32 = System.UInt32; // for converting firmware
    using s32 = System.Int32;  // for converting firmware
    using u16 = System.UInt16; // for converting firmware
    using s16 = System.Int16;  // for converting firmware
    using u8  = System.Byte;   // for converting firmware
    using s8  = System.SByte;  // for converting firmware

    using UINT32 = System.UInt32; // for converting firmware
    using vu32   = System.UInt32; // for converting firmware



    //// some common interface

    interface I_System_Converter 
    {
        // for System_Converter.h
        u16	SYS_HexToHWord(u8[] pData); // u8* --> u8[]
        u32	SYS_HexToWord(u8[] pData); // u8* --> u8[]
        float SYS_HexToFloat(u8[] pData); // u8* --> u8[]
        double SYS_HexToDouble(u8[] pData); // u8* --> u8[]
        void SYS_HWordToHex(u16 hWord, u8[] pData); // u8* --> u8[]
        void SYS_WordToHex(u32 word, u8[] pData); // u8* --> u8[]
        void SYS_FloatToHex(float fData, u8[] pData); // u8* --> u8[]
        void SYS_DoubleToHex(double dData, u8[] pData); // u8* --> u8[]
    }

    interface I_Delay 
    {
        void Delay_ms(UINT32 milisecond);
        void Delay_us(vu32 microsecond);    

    }



    //// some common class or enum or struct
    
    public partial class __S3100_SPI_EMUL : I_System_Converter 
    {

        //THlsmuChInfo dev_ch; // test

        //// for I_System_Converter
        public u16	SYS_HexToHWord(u8[] pData) // u8* --> u8[]
        {
            return 0;
        }
        public u32	SYS_HexToWord(u8[] pData) // u8* --> u8[]
        {
            // bitCtrl32_t data;
            // data.u8Data[0] = pData[0];
            // data.u8Data[1] = pData[1];
            // data.u8Data[2] = pData[2];
            // data.u8Data[3] = pData[3];
            // return data.u32Data;

            //$$ C# implement // C# safe style
            return BitConverter.ToUInt32(pData);
        }
        public float SYS_HexToFloat(u8[] pData) // u8* --> u8[]
        {
            return 0;
        }
        public double SYS_HexToDouble(u8[] pData) // u8* --> u8[]
        {
            return 0;
        }
        public void SYS_HWordToHex(u16 hWord, u8[] pData) // u8* --> u8[]
        {
            //
        }
        public void SYS_WordToHex(u32 word, u8[] pData) // u8* --> u8[]
        {
            // bitCtrl32_t data;
            // data.u32Data = word;
            // pData[0] = data.u8Data[0];
            // pData[1] = data.u8Data[1];
            // pData[2] = data.u8Data[2];
            // pData[3] = data.u8Data[3];

            //$$ C# implement // C# safe style
            var buf_byte = BitConverter.GetBytes(word);
            pData[0] = buf_byte[0];
            pData[1] = buf_byte[1];
            pData[2] = buf_byte[2];
            pData[3] = buf_byte[3];
        }
        public void SYS_FloatToHex(float fData, u8[] pData) // u8* --> u8[]
        {
            // floatCtrl_t data;
            // data.fData[0] = fData;
            // pData[0] = data.u8Data[0];
            // pData[1] = data.u8Data[1];
            // pData[2] = data.u8Data[2];
            // pData[3] = data.u8Data[3];

            //$$ C# implement // C# safe style
            var buf_byte = BitConverter.GetBytes(fData);
            pData[0] = buf_byte[0];
            pData[1] = buf_byte[1];
            pData[2] = buf_byte[2];
            pData[3] = buf_byte[3];
        }
        public void SYS_DoubleToHex(double dData, u8[] pData) // u8* --> u8[]
        {
            //
        }
        
        }

    public partial class __S3100_SPI_EMUL : I_Delay 
    {
        //// for I_Delay
        public void Delay_ms(UINT32 milisecond)
        {
            //$$ C# implement
            DateTime ThisMoment = DateTime.Now;
            TimeSpan duration = new TimeSpan(0, 0, 0, 0, (int)milisecond); // days, hours, minutes, seconds, and milliseconds
            DateTime AfterWards = ThisMoment.Add(duration);
            while (AfterWards >= ThisMoment)
            {
                ThisMoment = DateTime.Now;
            }
            // exit
        }
        public void Delay_ms(s32 milisecond)
        {
            Delay_ms((u32)milisecond);
        }

        public void Delay_us(vu32 microsecond)
        {
            //$$ C# implement
            var stopwatch = new Stopwatch();
            stopwatch.Start();
            long nanosecPerTick = (1000L*1000L*1000L) / Stopwatch.Frequency;
            long usDelayTick = ( microsecond * 1000L ) / nanosecPerTick;
            while (stopwatch.ElapsedTicks < usDelayTick);
            // exit
        }
        public void Delay_us(s32 microsecond)
        {
            Delay_us((u32)microsecond);
        }

    }


    // SCPI base
    public partial class __S3100_SPI_EMUL
    {
        private int SO_SNDBUF = 32768; // 2048 --> 16384 --> 32768
        private int SO_RCVBUF = 32768;
        private int PORT = 5025;
        private Socket ss = null;

        // SPCI basic commands string
        private string cmd_str__IDN = "*IDN?\n"; // note EPS
        public string cmd_str__RST = "*RST\n"; // note EPS
        public string cmd_str__FPGA_FID = ":FPGA:FID?\n"; // note EPS
        public string cmd_str__FPGA_TMP = ":FPGA:TMP?\n"; // note EPS

        private string cmd_str__EPS_EN = ":EPS:EN"; // note EPS
        //
        private string cmd_str__EPS_WMI  = ":EPS:WMI";
        private string cmd_str__EPS_WMO  = ":EPS:WMO";
        private string cmd_str__EPS_TAC  = ":EPS:TAC";
        private string cmd_str__EPS_TMO  = ":EPS:TMO";
        //private string cmd_str__EPS_TWO  = ":EPS:TWO"; // reserved
        private string cmd_str__EPS_PI   = ":EPS:PI";
        private string cmd_str__EPS_PO   = ":EPS:PO";


        // lan subfunctions ...
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
                //$$throw new SocketException(10060); // Connection timed out.                 
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
            Delay_ms(INTVAL);
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
            Delay_ms(INTVAL);
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



        // eps functions ...
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

    }

    // common
    public partial class EPS 
    {
        // some common modules
        public void TRACE(string fmt)
        {
            // remove "\r\n" 
            if (fmt.Substring(fmt.Length-2)=="\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-2);
                fmt = tmp; //
            }
            Console.WriteLine(fmt);
        }

        public void TRACE(string fmt, s32 val) { // for test print
            // check "...%02d \r\n"
            if (fmt.Substring(fmt.Length-7)=="%02d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-7);
                fmt = tmp + string.Format("{0,2:d2} ", val); //
            }
            // check "...%d \r\n"
            else if (fmt.Substring(fmt.Length-5)=="%d \r\n") {
                string tmp = fmt.Substring(0, fmt.Length-5);
                fmt = tmp + string.Format("{0} ", val); //
            }
            // check "...%d>\r\n"
            else if (fmt.Substring(fmt.Length-5)=="%d>\r\n") {
                string tmp = fmt.Substring(0, fmt.Length-5);
                fmt = tmp + string.Format("{0}>", val); //
            }
            Console.WriteLine(fmt);
        }
        public void TRACE(string fmt, s32 val_0, u32 val_1) { // for test print
            int loc_dd = -1;
            // check "...%d...%X>\r\n"
            if (fmt.Substring(fmt.Length-5)=="%X>\r\n") {
                // find %X
                string tmp = fmt.Substring(0, fmt.Length-5);
                fmt = tmp + string.Format("{0:X}>", val_1); //
                // find %d
                loc_dd = fmt.IndexOf("%d");
                tmp = fmt.Substring(0, loc_dd) + string.Format("{0:d}", val_0);
                fmt = tmp + fmt.Substring(loc_dd+2, fmt.Length-loc_dd-2);
            }
            Console.WriteLine(fmt);
        }

        public const bool FALSE = false;        
        public const bool TRUE  = true;        
    }

}