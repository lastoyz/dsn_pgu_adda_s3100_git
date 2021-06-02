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

namespace TopInstrument
{
    public class TOP_PGU
    {
        
        //// TCPIP
        //public int TIMEOUT = 5000;                      // socket timeout
        public int SO_SNDBUF = 2048;
        public int SO_RCVBUF = 32768;
        public int INTVAL = 100;                       // Milli Second
        public int BUF_SIZE_NORMAL = 2048;
        public int BUF_SIZE_LARGE = 16384;

        //public string HOST = "192.168.100.119";
        public int PORT = 5025;

        public Socket ss = null;

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



        // LAN command string headers
        public string cmd_str__IDN = "*IDN?\n";
        public string cmd_str__RST = "*RST\n";

        public string cmd_str__FPGA_FID = ":FPGA:FID?\n";
        public string cmd_str__FPGA_TMP = ":FPGA:TMP?\n";

        public string cmd_str__EPS_EN = ":EPS:EN";

        public string cmd_str__PGU_PWR = ":PGU:PWR";
        public string cmd_str__PGU_OUTP = ":PGU:OUTP";

        public string cmd_str__PGU_STAT = ":PGU:STAT"; // output activity check

        public string cmd_str__PGU_AUX_OUTP = ":PGU:AUX:OUTP";  //Remove        
                                                    
        public string cmd_str__PGU_AUX_CON        = ":PGU:AUX:CON";  //new
        public string cmd_str__PGU_AUX_OLAT       = ":PGU:AUX:OLAT"; //new
        public string cmd_str__PGU_AUX_DIR        = ":PGU:AUX:DIR";  //new
        public string cmd_str__PGU_AUX_GPIO       = ":PGU:AUX:GPIO"; //new

        //public string cmd_str__PGU_DCS_TRIG = ":PGU:DCS:TRIG";
        //public string cmd_str__PGU_DCS_DAC0_PNT = ":PGU:DCS:DAC0:PNT";
        //public string cmd_str__PGU_DCS_DAC1_PNT = ":PGU:DCS:DAC1:PNT";
        //public string cmd_str__PGU_DCS_RPT = ":PGU:DCS:RPT";
        public string cmd_str__PGU_TRIG = ":PGU:TRIG";
        public string cmd_str__PGU_NFDT0 = ":PGU:NFDT0";
        public string cmd_str__PGU_NFDT1 = ":PGU:NFDT1";
        public string cmd_str__PGU_FDAC0 = ":PGU:FDAT0";
        public string cmd_str__PGU_FDAC1 = ":PGU:FDAT1";
        public string cmd_str__PGU_FRPT0 = ":PGU:FRPT0";
        public string cmd_str__PGU_FRPT1 = ":PGU:FRPT1";

        public string cmd_str__PGU_FDCS_TRIG = ":PGU:FDCS:TRIG";
        public string cmd_str__PGU_FDCS_DAC0 = ":PGU:FDCS:DAC0";
        public string cmd_str__PGU_FDCS_DAC1 = ":PGU:FDCS:DAC1";
        public string cmd_str__PGU_FDCS_RPT = ":PGU:FDCS:RPT";

        public string cmd_str__PGU_FREQ = ":PGU:FREQ";
        public string cmd_str__PGU_OFST_DAC0 = ":PGU:OFST:DAC0";
        public string cmd_str__PGU_OFST_DAC1 = ":PGU:OFST:DAC1";
        public string cmd_str__PGU_GAIN_DAC0 = ":PGU:GAIN:DAC0";
        public string cmd_str__PGU_GAIN_DAC1 = ":PGU:GAIN:DAC1";

        //$$ new for EEPROM
        public string cmd_str__PGU_MEMR      = ":PGU:MEMR"; // # new ':PGU:MEMR #H00000058 \n'
        public string cmd_str__PGU_MEMW      = ":PGU:MEMW"; // # new ':PGU:MEMW #H0000005C #H1234ABCD \n'

        //public string cmd_str__DC_BIAS = ":PGU:BIAS";
        
        //----//

        public string LogFilePath = Path.GetDirectoryName(Environment.CurrentDirectory) + "T-SPACE" + "\\Log"; //$$ for release
		//$$public string LogFilePat\\ = \\ath.GetDirectoryName(Environment.CurrentDirectory) + "/testcs/log/";
        //$$public string LogFilePath = Path.GetDirectoryName(Environment.CurrentDirectory) + "\\test_vscode\\log\\"; //$$ TODO: logfile location

        public bool IsInit = false;

        public string SysOpen(string HOST, int TIMEOUT)
        {
            my_open(HOST, TIMEOUT);

            string ret;

            if (IsInit == false)
            {            

                //### :PGEP:EN
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__EPS_EN + " ON\n"));

                //### scpi command: ":PGU:PWR"
                //### power on (DAC IC)
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " ON\n"));
                Delay(10); //$$ 10ms wait for electrical power stabilty

                ////### output on or off //$$ PGU-CPU-S3000 relay on or off 
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " ON\n"));

                Read_IDN();
                Load_CAL_from_EEPROM();
                Load_INFO_from_EEPROM();

                IsInit = true;     
            }

            //### scpi : *IDN?
            return scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__IDN));  
        }


        public void SysClose()
        {
            if (ss != null) scpi_close(ss);
        }

        public void SysClose__board_shutdown() 
        {
            //$$ shutdown board 
            IsInit = false; 

            scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " OFF\n"));
            Delay(10); //$$ 10ms wait for mechanical relay done 
            scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR  + " OFF\n"));
            scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__EPS_EN   + " OFF\n"));


            if (ss != null) scpi_close(ss);
        }
        
        public Socket my_open(string HOST, int TIMEOUT)
        {
            if (ss != null) scpi_close(ss);
            //
            ss = scpi_open(HOST, PORT, TIMEOUT, SO_SNDBUF, SO_RCVBUF);
            scpi_connect(ss, HOST, PORT);
                        
            return ss;

            //def my_open(host, port):
            //#
            //ss = scpi_open()
            //try:
            //    print('>> try to connect : {}:{}'.format(host, port))
            //    scpi_connect(ss, host, port)
            //except socket.timeout:
            //    ss = None
            //except:
            //    raise
            //return ss
        }

        private static Socket scpi_open(string HOST, int PORT, int TIMEOUT, int SO_SNDBUF, int SO_RCVBUF)
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
                Socket ss = null;
                throw new Exception(String.Format("Error in Open") + e.Message);
            }

            //def scpi_open (timeout=TIMEOUT):
            //    try:
            //        ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            //        ss.settimeout(timeout)
            //        ss.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SO_SNDBUF)
            //        ss.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, SO_RCVBUF) # 8192 16384 32768 65536
            //    except OSError as msg:
            //        ss = None
            //        print('error in socket: ', msg)
            //        raise
            //    return ss

        }

        private Socket scpi_connect(Socket ss, string HOST, int PORT)
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

            //try
            //{
            //    var ep = new IPEndPoint(IPAddress.Parse(HOST), PORT);
            //    ss.Connect(ep);

            //}

            //catch (Exception e)
            //{
            //    ss.Close();
            //    //// Console.WriteLine(String.Format("Error in Open") + e.Message);
            //}

            //return ss;

            //def scpi_connect (ss, HOST, PORT):
            //  try:
            //      ss.connect((HOST, PORT))
            //  except OSError as msg:
            //      ss.close()
            //      ss = None
            //      print('error in connect: ', msg)
            //      raise
        }

        private Socket scpi_close(Socket ss)
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

            //def scpi_close (ss):
            //    try:
            //        ss.close()
            //    except:
            //        if ss == None:
            //            print('error: ss==None')
            //        raise
        }


        private static DateTime Delay(int S) //$$ ms
        {
            DateTime ThisMoment = DateTime.Now;
            TimeSpan duration = new TimeSpan(0, 0, 0, 0, S);
            DateTime AfterWards = ThisMoment.Add(duration);

            while (AfterWards >= ThisMoment)
            {
                ThisMoment = DateTime.Now;
            }

            return DateTime.Now;
        }

        public string scpi_comm_resp_ss(Socket ss, byte[] cmd_str, int BUF_SIZE_NORMAL = 2048, int INTVAL = 100)
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
				//Console.WriteLine("(TEST)>>> " + Encoding.UTF8.GetString(cmd_str));
            }

            //try:
            //    print('Send:', repr(cmd_str))
            //    ss.sendall(cmd_str)
            //except:
            //    print('error in sendall')
            //    raise

            Delay(1);

            int nRecvSize;
            string data;
            try
            {
                nRecvSize = ss.Receive(receiverBuff);
                data = new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));

                while (true)
                {
                    if (receiverBuff[nRecvSize - 1] == '\n')
                    {
                        break;
                    }
                    nRecvSize = ss.Receive(receiverBuff);
                    data = data + new string(Encoding.Default.GetChars(receiverBuff, 0, nRecvSize));

                }
                //try:
                //data = ss.recv(buf_size) # try 1024 131072 524288
                //while (1):
                //    if (chr(data[-1])=='\n'): # check the sentinel '\n'
                //        break
                //    data = data + ss.recv(buf_size)
            }

            catch
            {
                //Console.WriteLine(String.Format("Error in Recive"));
                //$$data = "";
                data = "#H00000000\n";
                //raise
            }
            //except:
            //print('error in recv')
            //raise

            return data;

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



        //$$ EEPROM access

        public int pgu_eeprom__read__data_4byte(int adrs_b32) {
        //  def pgu_eeprom__read__data_4byte (adrs_b32):
        //  	print('\n>>>>>> pgu_eeprom__read__data_4byte')
        //  	#
        //  	cmd_str = cmd_str__PGU_MEMR + (' #H{:08X}\n'.format(adrs_b32)).encode()
        //  	rsp_str = scpi_comm_resp_ss(ss, cmd_str)
        //  	rsp = rsp_str.decode()
        //  	# assume hex decimal response: #HF3190306<NL>
        //  	rsp = '0x' + rsp[2:-1] # convert "#HF3190306<NL>" --> "0xF3190306"
        //  	rsp = int(rsp,16) # convert hex into int
        //  	return rsp

            string PGU_MEMR = Convert.ToString(cmd_str__PGU_MEMR) + string.Format(" #H{0,8:X8}\n", adrs_b32);
            byte[] PGU_MEMR_CMD = Encoding.UTF8.GetBytes(PGU_MEMR);

            string ret;
            
            try {
                ret = scpi_comm_resp_ss(ss, PGU_MEMR_CMD);
            }

            catch {
                ret = "#H00000000\n";
            }
            return (int)Convert.ToInt32(ret.Substring(2,8),16); // convert hex into int32
        }

        public int pgu_eeprom__write_data_4byte(int adrs_b32, uint val_b32) {
        //  def pgu_eeprom__write_data_4byte (adrs_b32, val_b32):
        //  	print('\n>>>>>> pgu_eeprom__write_data_4byte')
        //  	#
        //  	cmd_str = cmd_str__PGU_MEMW + (' #H{:08X} #H{:08X}\n'.format(adrs_b32, val_b32)).encode()
        //  	rsp_str = scpi_comm_resp_ss(ss, cmd_str)
        //  	print('string rcvd: ' + repr(rsp))
        //  	print('rsp: ' + rsp.decode())
        //  	return rsp.decode()[0:2] # OK or NG
        //  
            string PGU_MEMW = Convert.ToString(cmd_str__PGU_MEMW) 
                            + string.Format(" #H{0,8:X8}"  , adrs_b32)
                            + string.Format(" #H{0,8:X8}\n", val_b32 );
            byte[] PGU_MEMW_CMD = Encoding.UTF8.GetBytes(PGU_MEMW);

            string ret = scpi_comm_resp_ss(ss, PGU_MEMW_CMD);

            //Delay(1); //$$ 1ms wait for write done // NG  read right after write
            //Delay(2); //$$ 2ms wait for write done // some NG 
            Delay(10); //$$ 10ms wait for write done 

            var val = 0;
            if (ret.Substring(0,2)=="OK") {
                val = 0;
            }
            else {
                val = -1;
            }

            return val;
        }

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

        public int Load_CAL_from_EEPROM() {
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

            return ret;
        }

        public int Save_CAL_into_EEPROM(float ch1_offset = 0.0F, float ch2_offset = 0.0F, float ch1_gain = 1.0F, float ch2_gain = 1.0F) {

            this.__gui_out_ch1_offset = ch1_offset; 
            this.__gui_out_ch2_offset = ch2_offset; 
            this.__gui_out_ch1_gain   = ch1_gain  ; 
            this.__gui_out_ch2_gain   = ch2_gain  ;

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

        public int Read_IDN() 
        {
            var idn_str = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__IDN));
            this.__gui_pgu_idn_txt = idn_str.ToCharArray();
            return 0;
        }

        public int Load_INFO_from_EEPROM() 
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
            var pgu_check_sum = eeprom_data_at_2X__bytes[0xF];;// located at 0x2F
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

            // copy to members
            //...
            this.__gui_pgu_model_name              = new string(model_name  ).ToCharArray(); // (1)
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

            return pgu_check_sum_residual; //$$ 0 for valid INFO, non-zero for check sum error.
        }

        public int Save_INFO_into_EEPROM(
            char[] model_name   ,
            char[] pgu_ip_adrs  ,
            char[] pgu_sm_adrs  ,
            char[] pgu_ga_adrs  ,
            char[] pgu_dns_adrs ,
            char[] pgu_mac_adrs ,
            char[] pgu_slot_id  , 
            byte   pgu_user_id  , 
            char[] pgu_user_txt ) 
        {
            //// update members and save them into eeprom
            this.__gui_pgu_model_name   = model_name   ;
            this.__gui_pgu_ip_adrs  = pgu_ip_adrs  ;
            this.__gui_pgu_sm_adrs  = pgu_sm_adrs  ;
            this.__gui_pgu_ga_adrs  = pgu_ga_adrs  ;
            this.__gui_pgu_dns_adrs = pgu_dns_adrs ;
            this.__gui_pgu_mac_adrs = pgu_mac_adrs ;
            this.__gui_pgu_slot_id  = pgu_slot_id  ;
            this.__gui_pgu_user_id  = pgu_user_id  ;
            this.__gui_pgu_user_txt = pgu_user_txt ;

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
            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            try {
                using (StreamWriter ws = new StreamWriter(LogFileName, false))
                    ws.WriteLine("## Debuger Start"); //$$ add python comment header
            }
            catch {
                System.IO.Directory.CreateDirectory(LogFilePath);
                using (StreamWriter ws = new StreamWriter(LogFileName, false))
                    ws.WriteLine("## Debuger Start"); //$$ add python comment header
            }

            int val_b16 = 0x0808;

            pgu_spio_ext__send_aux_IO_CON(val_b16);
            string ret = pgu_spio_ext__read_aux_IO_CON();

            int OLAT = 0x0000;
            int IODIR = 0x000F;
            pgu_spio_ext__send_aux_IO_OLAT(OLAT);
            pgu_spio_ext__send_aux_IO_DIR(IODIR);
            
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

            int pgu_freq_in_100kHz = Convert.ToInt32(1 / (time_ns__dac_update * 1e-9) / 100000);
            string pgu_freq_in_100kHz_str = string.Format(" {0,4:D4} \n", pgu_freq_in_100kHz);

            //pgu_freq_in_100kHz_str = ' {:04d} \n'.format(pgu_freq_in_100kHz).encode()
            //print('pgu_freq_in_100kHz_str:', repr(pgu_freq_in_100kHz_str))

            byte[] PGU_FREQ_100kHz_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_FREQ + pgu_freq_in_100kHz_str);
            scpi_comm_resp_ss(ss, PGU_FREQ_100kHz_STR);


            double DAC_full_scale_current__mA = 25.5; // 20.1Vpp
            double I_FS__mA = DAC_full_scale_current__mA;
            double R_FS__ohm = 10e3;
            int DAC_gain = Convert.ToInt32((I_FS__mA / 1000 * R_FS__ohm - 86.6) / 0.220 + 0.5);

            string pgu_fsc_gain_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", DAC_gain, DAC_gain);
            //pgu_fsc_gain_str = ' #H{:04X}{:04X} \n'.format(DAC_gain,DAC_gain).encode()
            //#
            //print('pgu_fsc_gain_str:', repr(pgu_fsc_gain_str))
            //#
            //if DAC_gain>0x3FF or DAC_gain<0 :
            //    print('>>> please check the full scale current: {}'.format(DAC_full_scale_current__mA))
            //    raise

            float DAC_offset_current__mA = 0; // 0 min // # 0.625 mA
            //float DAC_offset_current__mA = 1; // 
            //float DAC_offset_current__mA = 2; // 2 max

            int N_pol_sel = 1; // 1

            int Sink_sel = 1; // 1

            //int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200 + 0.5);
            int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200);
            // 0x3FF, sets output current to 2.0 mA.
            // 0x200, sets output current to 1.0 mA.
            // 0x000, sets output current to 0.0 mA.

            //if DAC_offset_current__code > 0x3FF :
            //print('>>> please check the offset current: {}'.format(DAC_offset_current__mA))
            //raise
            if (DAC_offset_current__code > 0x3FF) {
                DAC_offset_current__code = 0x3FF; // max
            }

            // compose
            int DAC_offset = (N_pol_sel << 15) + (Sink_sel << 14) + DAC_offset_current__code;

            string pgu_offset_con_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", DAC_offset, DAC_offset);

            byte[] PGU_OFST_DAC0_OFFSET_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_OFST_DAC0 + pgu_offset_con_str);
            scpi_comm_resp_ss(ss, PGU_OFST_DAC0_OFFSET_STR);
            byte[] PGU_OFST_DAC1_OFFSET_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_OFST_DAC1 + pgu_offset_con_str);
            scpi_comm_resp_ss(ss, PGU_OFST_DAC1_OFFSET_STR);


            byte[] PGU_GAIN_DAC0_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_GAIN_DAC0 + pgu_fsc_gain_str);
            scpi_comm_resp_ss(ss, PGU_GAIN_DAC0_STR);
            byte[] PGU_GAIN_DAC1_STR = Encoding.UTF8.GetBytes(cmd_str__PGU_GAIN_DAC1 + pgu_fsc_gain_str);
            scpi_comm_resp_ss(ss, PGU_GAIN_DAC1_STR);

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

            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            //using (StreamWriter ws = new StreamWriter(LogFileName, false))
            //    ws.WriteLine("Debuger Start");

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
            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            //using (StreamWriter ws = new StreamWriter(LogFileName, false))
            //    ws.WriteLine("Debuger Start");

            long fifo_data = 0;

            for (int i = 0; i < len_fifo_data.Length; i++)
            {
                fifo_data = fifo_data + len_fifo_data[i];
            }

            string len_fifo_data_str = string.Format(" #H{0,8:X8}", fifo_data);

            if (Ch == 1)
            {
                string PGU_NFDT0 = Convert.ToString(cmd_str__PGU_NFDT0 + len_fifo_data_str + " \n");
                byte[] PGU_NFDT0_CMD = Encoding.UTF8.GetBytes(PGU_NFDT0);
                scpi_comm_resp_ss(ss, PGU_NFDT0_CMD);

                using (StreamWriter ws = new StreamWriter(LogFileName, true))
                    ws.WriteLine("## " + PGU_NFDT0);

                for (int i = 0; i < pulse_info_num_block_str.Length; i++)
                {
                    string PGU_FDAC0 = Convert.ToString(cmd_str__PGU_FDAC0 + pulse_info_num_block_str[i]);
                    byte[] PGU_FDAC0_CMD = Encoding.UTF8.GetBytes(PGU_FDAC0);
                    scpi_comm_resp_ss(ss, PGU_FDAC0_CMD);

                    using (StreamWriter ws = new StreamWriter(LogFileName, true))
                        ws.WriteLine("## " + PGU_FDAC0);
                }

                
            }
            else if(Ch == 2)
            {
                string PGU_NFDT1 = Convert.ToString(cmd_str__PGU_NFDT1 + len_fifo_data_str + " \n");
                byte[] PGU_NFDT1_CMD = Encoding.UTF8.GetBytes(PGU_NFDT1);
                scpi_comm_resp_ss(ss, PGU_NFDT1_CMD);

                using (StreamWriter ws = new StreamWriter(LogFileName, true))
                    ws.WriteLine("## " + PGU_NFDT1);

                for (int i = 0; i < pulse_info_num_block_str.Length; i++)
                {
                    string PGU_FDAC1 = Convert.ToString(cmd_str__PGU_FDAC1 + pulse_info_num_block_str[i]);
                    byte[] PGU_FDAC1_CMD = Encoding.UTF8.GetBytes(PGU_FDAC1);
                    scpi_comm_resp_ss(ss, PGU_FDAC1_CMD);

                    using (StreamWriter ws = new StreamWriter(LogFileName, true))
                        ws.WriteLine("## " + PGU_FDAC1);
                }
            }

        }

        public void trig_pgu_output_Cid_ON(int CycleCount)
        {

            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit

            string pgu_repeat_num_str = string.Format(" #H{0,8:X8} \n", CycleCount);

            string PGU_FRPT0 = Convert.ToString(cmd_str__PGU_FRPT0 + pgu_repeat_num_str);
            byte[] PGU_FRPT0_CMD = Encoding.UTF8.GetBytes(PGU_FRPT0);
            scpi_comm_resp_ss(ss, PGU_FRPT0_CMD);

            string PGU_FRPT1 = Convert.ToString(cmd_str__PGU_FRPT1 + pgu_repeat_num_str);
            byte[] PGU_FRPT1_CMD = Encoding.UTF8.GetBytes(PGU_FRPT1);
            scpi_comm_resp_ss(ss, PGU_FRPT1_CMD);

            //write_aux_io__direct(__gui_aux_io_control & 0xFFFF);  // #Only, Use to 10V PGU
            string ret;

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_FRPT0); //$$ add py comment heeder

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                ws.WriteLine("## " + PGU_FRPT1); //$$ add py comment heeder
            

            // 40V-amp control latch reset on
            pgu_spio_ext__send_aux_IO_OLAT(0x0030);
            // 40V-amp control latch reset off
            pgu_spio_ext__send_aux_IO_OLAT(0x0000);
            // # 40V-amp sleep_n power on
            pgu_spio_ext__send_aux_IO_OLAT(0x0300);

            Delay(3); // # Wait 5ms

            // # 40V-amp 40v relay output close 
            pgu_spio_ext__send_aux_IO_OLAT(0x3300);

            Delay(3);

            string PGU_TRIG_ON = Convert.ToString(cmd_str__PGU_TRIG + " #H00010001 \n");
            byte[] cmd_str__PGU_TRIG_CMD = Encoding.UTF8.GetBytes(PGU_TRIG_ON);
            scpi_comm_resp_ss(ss, cmd_str__PGU_TRIG_CMD);
                       
            ret = pgu_spio_ext__read_aux_IO_GPIO();

        }

        public void trig_pgu_output_Cid_OFF()
        {          
            string PGU_TRIG_OFF = Convert.ToString(cmd_str__PGU_TRIG + " #H00000000 \n");
            byte[] cmd_str__PGU_TRIG_OFF_CMD = Encoding.UTF8.GetBytes(PGU_TRIG_OFF);
            scpi_comm_resp_ss(ss, cmd_str__PGU_TRIG_OFF_CMD);

            // 40V-amp control latch reset off
            pgu_spio_ext__send_aux_IO_OLAT(0x0000);

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
            trig_pgu_output_Cid_ON(CycleCount);

            Delay(delay); //delay 3.5s

            trig_pgu_output_Cid_OFF();


            //write_aux_io__direct(__gui_aux_io_control & 0xFCFF);



			//$$ remove below for stable output
			//$$ //### power off 
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " OFF\n"));
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));

            string ret;
            ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            //## close socket
            scpi_close(ss);

            return ret;
        }

        public string ForcePGU_ON(int CycleCount)
        {
            trig_pgu_output_Cid_ON(CycleCount);
            string ret;

            ret = pgu_spio_ext__read_aux_IO_GPIO();
            //ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));
            //## close socket

            return ret;
        }

        public string Over_Detected()
        {
            string ret;

            ret = pgu_spio_ext__read_aux_IO_GPIO();

            return ret;
        }

        public string ForcePGU_OFF()
        {
            string ret;
            // # Board Temp Check CMD
            ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(":EPS:WMO#H3A #HFFFFFFFF\n"));

            trig_pgu_output_Cid_OFF();
            
            //$$ remove below for stable output
			//$$ //### power off 
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " OFF\n"));
            //$$ scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));

            //## close socket
            scpi_close(ss);

            return ret;
        }

        public string pgu_spio_ext__read_aux_IO_CON()
        {
            string ret_str;
            //int ret;
            ret_str = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_CON + "?\n"));

            //ret = Convert.ToInt32("0x" + ret_str.Substring(2, 5));

            return ret_str;
        }

        public string pgu_spio_ext__read_aux_IO_OLAT()
        {
            string ret_str;
            //int ret;
            ret_str = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_OLAT + "?\n"));

            //ret = Convert.ToInt32("0x" + ret_str.Substring(2, 8));

            return ret_str;

            //rsp = '0x' + rsp[2:-1] # convert "#HF3190306<NL>" --> "0xF3190306"
            //rsp = int(rsp,16) # convert hex into int
            //return rsp
        }

        public string pgu_spio_ext__read_aux_IO_DIR()
        {
            string ret_str;
            //int ret;
            ret_str = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_DIR + "?\n"));

            //ret = Convert.ToInt32("0x" + ret_str.Substring(2, 8));

            return ret_str;
        }

        public string pgu_spio_ext__read_aux_IO_GPIO()
        {
            string ret_str;
            //int ret;
            ret_str = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_GPIO + "?\n"));

            //ret = Convert.ToInt32("0x" + ret_str.Substring(2, 8));

            return ret_str;
        }

        public string pgu_spio_ext__send_aux_IO_CON(int val_b16)
        {
            string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret;

            string PGU_AUX_CON = Convert.ToString(cmd_str__PGU_AUX_CON + val_b16_str);
            byte[] PGU_AUX_CON_CMD = Encoding.UTF8.GetBytes(PGU_AUX_CON);
            ret = scpi_comm_resp_ss(ss, PGU_AUX_CON_CMD);

            return ret;
        }

        public string pgu_spio_ext__send_aux_IO_OLAT(int val_b16)
        {
            string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret;


            string PGU_AUX_OLAT = Convert.ToString(cmd_str__PGU_AUX_OLAT + val_b16_str);
            byte[] PGU_AUX_OLAT_CMD = Encoding.UTF8.GetBytes(PGU_AUX_OLAT);
            ret = scpi_comm_resp_ss(ss, PGU_AUX_OLAT_CMD);

            return ret;
        }

        public string pgu_spio_ext__send_aux_IO_DIR(int val_b16)
        {
            string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);

            string ret;

            string PGU_AUX_DIR = Convert.ToString(cmd_str__PGU_AUX_DIR + val_b16_str);
            byte[] PPGU_AUX_DIR_CMD = Encoding.UTF8.GetBytes(PGU_AUX_DIR);
            ret = scpi_comm_resp_ss(ss, PPGU_AUX_DIR_CMD);

            return ret;
        }

		//$$ test text
		public string pgu_spio_ext__send_aux_IO_GPIO__cmd_str(int val_b16)
		{
			string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
			string PGU_AUX_GPIO = Convert.ToString(cmd_str__PGU_AUX_GPIO + val_b16_str);

			return PGU_AUX_GPIO;
		}

        public string pgu_spio_ext__send_aux_IO_GPIO(int val_b16)
        {
            string val_b16_str = string.Format(" #H{0,4:X4} \n", val_b16);
            string ret;

            string PGU_AUX_GPIO = Convert.ToString(cmd_str__PGU_AUX_GPIO + val_b16_str);
            byte[] PGU_AUX_GPIO_CMD = Encoding.UTF8.GetBytes(PGU_AUX_GPIO);
            ret = scpi_comm_resp_ss(ss, PGU_AUX_GPIO_CMD);

            return ret;

            //return rsp.decode()[0:2] # OK or NG
        }

		/*
		public static int _test()
        {
            Console.WriteLine("Hello, TopInstrument!");

            Console.WriteLine(">>> Some test for command string:");
            // init class
            TOP_PGU dev = new TOP_PGU();

            //  // test mem function
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0x000F));
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0x00F0));
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0x0F00));
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0xF000));
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0xFFFF));
            //  Console.WriteLine(dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0x0000));

            // test bit converters
            Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x0000));
            Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x7FFF));
            Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x8000));
            Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x0001));
            Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0xFFFF));
            //
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+20.0));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+13.9));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+10.0));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+9.9));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+5.0));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(+0.1));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-0.1));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-5.0));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-9.9));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-10.0));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-13.9));
            Console.WriteLine(dev.conv_dec_to_bit_2s_comp_16bit(-20.0));


            //// sys_open
            //Console.WriteLine(dev.SysOpen("192.168.100.112", 20000));
            //Console.WriteLine(dev.SysOpen("192.168.100.115", 20000));
            Console.WriteLine(dev.SysOpen("192.168.100.127", 20000));


            //// test eeprom access 
            //   eeprom read header 16B * 4 = 64B
            var eeprom_data_at_00 = dev.pgu_eeprom__read__data_4byte(0x00);
            var eeprom_data_at_04 = dev.pgu_eeprom__read__data_4byte(0x04);
            var eeprom_data_at_08 = dev.pgu_eeprom__read__data_4byte(0x08);
            var eeprom_data_at_0C = dev.pgu_eeprom__read__data_4byte(0x0C);
            var eeprom_data_at_10 = dev.pgu_eeprom__read__data_4byte(0x10);
            var eeprom_data_at_14 = dev.pgu_eeprom__read__data_4byte(0x14);
            var eeprom_data_at_18 = dev.pgu_eeprom__read__data_4byte(0x18);
            var eeprom_data_at_1C = dev.pgu_eeprom__read__data_4byte(0x1C);
            var eeprom_data_at_20 = dev.pgu_eeprom__read__data_4byte(0x20);
            var eeprom_data_at_24 = dev.pgu_eeprom__read__data_4byte(0x24);
            var eeprom_data_at_28 = dev.pgu_eeprom__read__data_4byte(0x28);
            var eeprom_data_at_2C = dev.pgu_eeprom__read__data_4byte(0x2C);
            var eeprom_data_at_30 = dev.pgu_eeprom__read__data_4byte(0x30);
            var eeprom_data_at_34 = dev.pgu_eeprom__read__data_4byte(0x34);
            var eeprom_data_at_38 = dev.pgu_eeprom__read__data_4byte(0x38);
            var eeprom_data_at_3C = dev.pgu_eeprom__read__data_4byte(0x3C);

            var eeprom_data_at_00__bytes = BitConverter.GetBytes(eeprom_data_at_00);
            var eeprom_data_at_04__bytes = BitConverter.GetBytes(eeprom_data_at_04);
            var eeprom_data_at_08__bytes = BitConverter.GetBytes(eeprom_data_at_08);
            var eeprom_data_at_0C__bytes = BitConverter.GetBytes(eeprom_data_at_0C);
            var eeprom_data_at_10__bytes = BitConverter.GetBytes(eeprom_data_at_10);
            var eeprom_data_at_14__bytes = BitConverter.GetBytes(eeprom_data_at_14);
            var eeprom_data_at_18__bytes = BitConverter.GetBytes(eeprom_data_at_18);
            var eeprom_data_at_1C__bytes = BitConverter.GetBytes(eeprom_data_at_1C);
            var eeprom_data_at_20__bytes = BitConverter.GetBytes(eeprom_data_at_20);
            var eeprom_data_at_24__bytes = BitConverter.GetBytes(eeprom_data_at_24);
            var eeprom_data_at_28__bytes = BitConverter.GetBytes(eeprom_data_at_28);
            var eeprom_data_at_2C__bytes = BitConverter.GetBytes(eeprom_data_at_2C);
            var eeprom_data_at_30__bytes = BitConverter.GetBytes(eeprom_data_at_30);
            var eeprom_data_at_34__bytes = BitConverter.GetBytes(eeprom_data_at_34);
            var eeprom_data_at_38__bytes = BitConverter.GetBytes(eeprom_data_at_38);
            var eeprom_data_at_3C__bytes = BitConverter.GetBytes(eeprom_data_at_3C);

            var eeprom_data_at_00__str = Encoding.UTF8.GetString(eeprom_data_at_00__bytes);
            var eeprom_data_at_04__str = Encoding.UTF8.GetString(eeprom_data_at_04__bytes);
            var eeprom_data_at_08__str = Encoding.UTF8.GetString(eeprom_data_at_08__bytes);
            var eeprom_data_at_0C__str = Encoding.UTF8.GetString(eeprom_data_at_0C__bytes);
            var eeprom_data_at_10__str = Encoding.UTF8.GetString(eeprom_data_at_10__bytes);
            var eeprom_data_at_14__str = Encoding.UTF8.GetString(eeprom_data_at_14__bytes);
            var eeprom_data_at_18__str = Encoding.UTF8.GetString(eeprom_data_at_18__bytes);
            var eeprom_data_at_1C__str = Encoding.UTF8.GetString(eeprom_data_at_1C__bytes);
            var eeprom_data_at_20__str = Encoding.UTF8.GetString(eeprom_data_at_20__bytes);
            var eeprom_data_at_24__str = Encoding.UTF8.GetString(eeprom_data_at_24__bytes);
            var eeprom_data_at_28__str = Encoding.UTF8.GetString(eeprom_data_at_28__bytes);
            var eeprom_data_at_2C__str = Encoding.UTF8.GetString(eeprom_data_at_2C__bytes);
            var eeprom_data_at_30__str = Encoding.UTF8.GetString(eeprom_data_at_30__bytes);
            var eeprom_data_at_34__str = Encoding.UTF8.GetString(eeprom_data_at_34__bytes);
            var eeprom_data_at_38__str = Encoding.UTF8.GetString(eeprom_data_at_38__bytes);
            var eeprom_data_at_3C__str = Encoding.UTF8.GetString(eeprom_data_at_3C__bytes);

            var eeprom_data_at_00__hexstr = BitConverter.ToString(eeprom_data_at_00__bytes);
            var eeprom_data_at_04__hexstr = BitConverter.ToString(eeprom_data_at_04__bytes);
            var eeprom_data_at_08__hexstr = BitConverter.ToString(eeprom_data_at_08__bytes);
            var eeprom_data_at_0C__hexstr = BitConverter.ToString(eeprom_data_at_0C__bytes);
            var eeprom_data_at_10__hexstr = BitConverter.ToString(eeprom_data_at_10__bytes);
            var eeprom_data_at_14__hexstr = BitConverter.ToString(eeprom_data_at_14__bytes);
            var eeprom_data_at_18__hexstr = BitConverter.ToString(eeprom_data_at_18__bytes);
            var eeprom_data_at_1C__hexstr = BitConverter.ToString(eeprom_data_at_1C__bytes);
            var eeprom_data_at_20__hexstr = BitConverter.ToString(eeprom_data_at_20__bytes);
            var eeprom_data_at_24__hexstr = BitConverter.ToString(eeprom_data_at_24__bytes);
            var eeprom_data_at_28__hexstr = BitConverter.ToString(eeprom_data_at_28__bytes);
            var eeprom_data_at_2C__hexstr = BitConverter.ToString(eeprom_data_at_2C__bytes);
            var eeprom_data_at_30__hexstr = BitConverter.ToString(eeprom_data_at_30__bytes);
            var eeprom_data_at_34__hexstr = BitConverter.ToString(eeprom_data_at_34__bytes);
            var eeprom_data_at_38__hexstr = BitConverter.ToString(eeprom_data_at_38__bytes);
            var eeprom_data_at_3C__hexstr = BitConverter.ToString(eeprom_data_at_3C__bytes);

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
            Console.WriteLine(BitConverter.ToString(eeprom_data_at_0X__bytes));
            Console.WriteLine(BitConverter.ToString(eeprom_data_at_1X__bytes));
            Console.WriteLine(BitConverter.ToString(eeprom_data_at_2X__bytes));
            Console.WriteLine(BitConverter.ToString(eeprom_data_at_3X__bytes));
            Console.WriteLine(BitConverter.ToString(eeprom_LAN_data__bytes  ));

            // string merge
            var eeprom_data_at_0X__str = eeprom_data_at_00__str 
                                       + eeprom_data_at_04__str
                                       + eeprom_data_at_08__str
                                       + eeprom_data_at_0C__str;
            var eeprom_data_at_1X__str = eeprom_data_at_10__str 
                                       + eeprom_data_at_14__str
                                       + eeprom_data_at_18__str
                                       + eeprom_data_at_1C__str;
            var eeprom_data_at_2X__str = eeprom_data_at_20__str 
                                       + eeprom_data_at_24__str
                                       + eeprom_data_at_28__str
                                       + eeprom_data_at_2C__str;
            var eeprom_data_at_3X__str = eeprom_data_at_30__str 
                                       + eeprom_data_at_34__str
                                       + eeprom_data_at_38__str
                                       + eeprom_data_at_3C__str;
            Console.WriteLine(eeprom_data_at_0X__str);
            Console.WriteLine(eeprom_data_at_1X__str);
            Console.WriteLine(eeprom_data_at_2X__str);
            Console.WriteLine(eeprom_data_at_3X__str);

            // hex string merge
            var eeprom_data_at_0X__hexstr = eeprom_data_at_00__hexstr + "-"
                                          + eeprom_data_at_04__hexstr + "-"
                                          + eeprom_data_at_08__hexstr + "-"
                                          + eeprom_data_at_0C__hexstr;
            var eeprom_data_at_1X__hexstr = eeprom_data_at_10__hexstr + "-" 
                                          + eeprom_data_at_14__hexstr + "-"
                                          + eeprom_data_at_18__hexstr + "-"
                                          + eeprom_data_at_1C__hexstr;
            var eeprom_data_at_2X__hexstr = eeprom_data_at_20__hexstr + "-"
                                          + eeprom_data_at_24__hexstr + "-"
                                          + eeprom_data_at_28__hexstr + "-"
                                          + eeprom_data_at_2C__hexstr;
            var eeprom_data_at_3X__hexstr = eeprom_data_at_30__hexstr + "-"
                                          + eeprom_data_at_34__hexstr + "-"
                                          + eeprom_data_at_38__hexstr + "-"
                                          + eeprom_data_at_3C__hexstr;
            Console.WriteLine(eeprom_data_at_0X__hexstr);
            Console.WriteLine(eeprom_data_at_1X__hexstr);
            Console.WriteLine(eeprom_data_at_2X__hexstr);
            Console.WriteLine(eeprom_data_at_3X__hexstr);


            // test string converter
            Console.WriteLine(dev.conv_hexstr_to_decstr("A0-23-23-C0"));
            Console.WriteLine(dev.conv_decstr_to_hexstr("192.168.0.12"));
            Console.WriteLine(Convert.ToHexString(dev.conv_decstr_to_bytes ("192.168.0.12")));

            // test load INFO
            dev.Read_IDN();
            dev.Load_INFO_from_EEPROM();


            //// test change members
            var model_name = new string  ("PGU_CPU_S3000#00").ToCharArray(); // (1)
            //var model_name = new string("PGU_CPU_LAN#1234").ToCharArray(); // (1)

            var pgu_ip_adrs = new string  ("192.168.100.127").ToCharArray(); // (2)
            //var pgu_ip_adrs  = new string  ("192.168.100.112" ).ToCharArray(); // (2)

            var pgu_sm_adrs  = new string  ("255.255.255.0" ).ToCharArray(); // (3)
            var pgu_ga_adrs  = new string  ("0.0.0.0"       ).ToCharArray(); // (4)
            var pgu_dns_adrs = new string  ("0.0.0.0"       ).ToCharArray(); // (5)

            //var pgu_mac_adrs = new string  ("00485533CD0F" ).ToCharArray(); // (6)
            var pgu_mac_adrs = new string  ("0008DC00CD0F" ).ToCharArray(); // (6)

            var pgu_slot_id  = new string("56").ToCharArray(); // (7)
            //var pgu_slot_id  = new string("98").ToCharArray(); // (7)

            //var pgu_user_id = (byte) 32; //(8)
            var pgu_user_id = (byte) 23; //(8)

            //var pgu_user_txt = new string  ("0123456789ABCDEF").ToCharArray(); // (9)
            var pgu_user_txt = new string("ACACABAB12123434").ToCharArray(); // (9)
            

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
            dev.Load_INFO_from_EEPROM();
            

            ////
            Console.WriteLine(dev.pgu_eeprom__read__data_4byte(0x40));
            Console.WriteLine(dev.pgu_eeprom__read__data_4byte(0x44));
            Console.WriteLine(dev.pgu_eeprom__read__data_4byte(0x48));
            Console.WriteLine(dev.pgu_eeprom__read__data_4byte(0x4C));

            // eeprom write test
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x40, 0x03020100));
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x40, 0xFFFFFFFF));
            //Console.WriteLine(dev.pgu_eeprom__read__data_4byte(0x40));

            // data converter test
            Console.WriteLine(dev.conv__raw_int32__flt32((int)0x00000000));

            uint tmp_uint = 0xFFFFFFFF;
            Console.WriteLine(dev.conv__raw_uint32__flt32(tmp_uint));
            Console.WriteLine(dev.conv__raw_uint32__flt32(0x00000000));

            tmp_uint = dev.conv__flt32__raw_uint32((float)1.0101);
            Console.WriteLine(dev.conv__raw_uint32__flt32(tmp_uint));


            //   save cal_data to eeprom
            //dev.__gui_out_ch1_offset = -0.010;
            //dev.__gui_out_ch2_offset = -0.011;
            //dev.__gui_out_ch1_gain  =  1.013;
            //dev.__gui_out_ch2_gain  =  1.012;
            //dev.Save_CAL_into_EEPROM();

            //   load cal_data from eeprom
            dev.Load_CAL_from_EEPROM();
            Console.WriteLine(dev.__gui_out_ch1_offset);
            Console.WriteLine(dev.__gui_out_ch2_offset);
            Console.WriteLine(dev.__gui_out_ch1_gain );
            Console.WriteLine(dev.__gui_out_ch2_gain );

            // clear cal_data to all FF
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x40, 0xFFFFFFFF));
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x44, 0xFFFFFFFF));
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x48, 0xFFFFFFFF));
            //Console.WriteLine(dev.pgu_eeprom__write_data_4byte(0x4C, 0xFFFFFFFF));
            //dev.Load_CAL_from_EEPROM();

            // test float double
            float  tmp_float  = 1.1F;
            double tmp_double = 1.1D;
            Console.WriteLine(Convert.ToString((double)tmp_float )); 
            Console.WriteLine(Convert.ToString((float)tmp_double));
            tmp_float  = 1.0F;
            tmp_double = 1.0D;
            Console.WriteLine(Convert.ToString((double)tmp_float )); 
            Console.WriteLine(Convert.ToString((float)tmp_double));

            //// call pulse setup
            long[] StepTime;
            double[] StepLevel;
            int ret;

            //$$dev.InitializePGU(10, 10, 7.650 / 10, 50); //$$ OK, board output impedance is normally 50ohm // no caldate
            
            //$$ add cal_data access :

            //$$ case 0: init without using cal_data
            //dev.Set_CAL_Mode(0);
            //dev.InitializePGU(10, 10, 7.650 / 10, 50); // (double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm = 50)

            //$$ case 1: init with new cal_data and save it to EEPROM
            dev.Set_CAL_Mode(1);
            //dev.Save_CAL_into_EEPROM(0.01F, -0.01F, 0.9F, 1.1F); // (offset_ch1, offset_ch2, gain_ch1, gain_ch2)
            dev.Save_CAL_into_EEPROM(0.001F, -0.001F, 0.99F, 1.01F); // (offset_ch1, offset_ch2, gain_ch1, gain_ch2)
            dev.InitializePGU(10, 10, 7.650 / 10, 50); 

            //$$ case 2: init with cal_data from EEPROM
            //dev.Set_CAL_Mode(1);
            //dev.Load_CAL_from_EEPROM();
            //dev.InitializePGU  (10, 10, 7.650 / 10, 50);                            

            // check cal_data
            Console.WriteLine(dev.__gui_out_ch1_offset);
            Console.WriteLine(dev.__gui_out_ch2_offset);
            Console.WriteLine(dev.__gui_out_ch1_gain );
            Console.WriteLine(dev.__gui_out_ch2_gain );

            // case1 AA // 0
            StepTime = new long[] { 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 };
            StepLevel = new double[] { 0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 0.5, 0.5, 0.0, 0.0 };
            ret = dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

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

            Console.WriteLine("SetSetupPGU return Code = " + Convert.ToString(ret));

            //dev.SysClose(); // close but all controls alive
            dev.SysClose__board_shutdown(); // close with board shutdown and clear init bit

            return 0x3535ACAC;

        }
		*/




        /*
        public void Run()
        {
            SysOpen();
            long[] StepTime = { 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 };
            double[] StepLevel = { 0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 0.5, 0.5, 0.0, 0.0 };
            //int interpol = 4;   //#lyh_201221_rev

            long[] StepTime2 = { 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000 };
            double[] StepLevel2 = { 0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0 };
            //int interpol2 = 4;  //#lyh_201221_rev

            InitializePGU(2.5, 50, 7.650 / 10, 50);

            SetSetupPGU(1, 10, 1e6, StepTime, StepLevel);
            SetSetupPGU(2, 10, 1e6, StepTime2, StepLevel2);
            //#lyh_201221_rev
            //SetSetupPGU(1, 10, 1e6, StepTime, StepLevel, interpol);
            //SetSetupPGU(2, 10, 1e6, StepTime2, StepLevel2, interpol2);
            //#lyh_201221_rev

            ForcePGU(3, 3500);

        }
        */

    }

}


////---- cut off later ----////
/*

//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace __test__
{
    public class Program
    {
        public static void Main(string[] args)
        {
        	//Your code goes hereafter
        	Console.WriteLine("Hello, world!");

			//call something in TopInstrument
			TopInstrument.TOP_PGU._test();

			// // test more 
			// TopInstrument.TOP_PGU dev = new TopInstrument.TOP_PGU();
			// string ret;
			// 
			// ret = dev.pgu_spio_ext__send_aux_IO_GPIO__cmd_str(0x0000);
			// Console.WriteLine(ret);
			

        }
    }
}
*/