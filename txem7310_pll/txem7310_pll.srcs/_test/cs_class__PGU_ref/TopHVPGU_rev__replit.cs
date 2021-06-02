//$$ test with  https://replit.com/@SungEunEun/testcs#TopHVPGU_rev.cs

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

        //public int TIMEOUT = 5000;                      // socket timeout
        public int SO_SNDBUF = 2048;
        public int SO_RCVBUF = 32768;
        public int INTVAL = 100;                       // Milli Second
        public int BUF_SIZE_NORMAL = 2048;
        public int BUF_SIZE_LARGE = 16384;

        //public string HOST = "192.168.100.119";
        public int PORT = 5025;

        public Socket ss = null;


        public double time_ns__dac_update = 2.5;
        public int time_ns__code_duration = 10;    //$$ consider int --> double
        public double scale_voltage_10V_mode = 7.650 / 10;
        public double scale_voltage_40V_mode = 6.950 / 10;
        public double output_impedance_ohm = 50;

        public int __gui_ch_info;
        public int __gui_aux_io_control;
        public double __gui_load_impedance_ohm;
        public int __gui_cycle_count;
        public int __gui_min_num_interpol;
        //public int __gui_num_points;

        public string cmd_str__IDN = "*IDN?\n";
        public string cmd_str__RST = "*RST\n";

        public string cmd_str__FPGA_FID = ":FPGA:FID?\n";
        public string cmd_str__FPGA_TMP = ":FPGA:TMP?\n";

        //public string cmd_str__PGEP_EN = ":PGEP:EN";
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

        //$$public string LogFilePath = Path.GetDirectoryName(Environment.CurrentDirectory) + "T-SPACE" + "\\Log";
		public string LogFilePath = Path.GetDirectoryName(Environment.CurrentDirectory) + "/testcs/log/"; //$$ TODO: logfile location

        //public string cmd_str__DC_BIAS = ":PGU:BIAS";
        public bool IsInit = false;

        public void SysOpen(string HOST, int TIMEOUT)
        {
            my_open(HOST, TIMEOUT);

            string ret;

            if (IsInit == false)
            {            
                //### scpi : *IDN?
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__IDN));

                //### :PGEP:EN
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__EPS_EN + " ON\n"));
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__EPS_EN + "?\n"));

                //### scpi command: ":PGU:PWR"
                //### power on 
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " ON\n"));
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n'"));

                ////### output on or off //$$ PGU-CPU-S3000 relay on or off 
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + "?\n"));
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " ON\n"));
                ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + "?\n"));

            IsInit = true;        

            }

			//$$ remove below for stable output
			//$$ 
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n"));
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + " ON\n"));
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_PWR + "?\n'"));
			//$$ 
            //$$ ////### output on or off
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + "?\n"));
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + " ON\n"));
            //$$ ret = scpi_comm_resp_ss(ss, Encoding.UTF8.GetBytes(cmd_str__PGU_OUTP + "?\n"));

        }


        public void SysClose()
        {
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
                Console.WriteLine(String.Format("Error in Open") + e.Message);
                return ss;
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
            //    //Console.WriteLine(String.Format("Error in Open") + e.Message);
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
                Console.WriteLine(String.Format("Error in Open") + e.Message);
                return ss;
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


        private static DateTime Delay(int S)
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

            catch
            {
                //Console.WriteLine(String.Format("error in sendall"));
                //raise
				
				//$$ TODO:  print out command string for test
				Console.WriteLine("(TEST)>>> " + Encoding.UTF8.GetString(cmd_str));
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
                data = "";
                //raise
            }
            //except:
            //print('error in recv')
            //raise

            return data;

        }

        public long conv_dec_to_bit_2s_comp_16bit(double dec, double full_scale = 20) //$$ int to double
        {
			//$$ Console.WriteLine(">>> ... in conv_dec_to_bit_2s_comp_16bit() "); //$$
			//$$ Console.WriteLine(">>> (full_scale / 2.0 - full_scale / Math.Pow(2, 16)) = " + Convert.ToString( (full_scale / 2.0 - full_scale / Math.Pow(2, 16)) ) ); //$$
			//$$ Console.WriteLine(">>> (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)) = " + Convert.ToString( (-full_scale / 2.0 + full_scale / Math.Pow(2, 16)) ) ); //$$
			
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
				//$$Console.WriteLine("bit_2s_comp = " + Convert.ToString(bit_2s_comp) );
				//$$Console.WriteLine("dec = " + Convert.ToString(dec) );
				
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
			Console.WriteLine(">>> ... in gen_pulse_info_num_block__inc_step()");
			
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
			Console.WriteLine("total_duration_segment = " + Convert.ToString(total_duration_segment) );
			Console.WriteLine("code_start             = " + Convert.ToString(code_start   ) );
			Console.WriteLine("volt_diff              = " + Convert.ToString(volt_diff    ) ); //$$ new para
			Console.WriteLine("code_diff              = " + Convert.ToString(code_diff    ) ); //$$ new para
			Console.WriteLine("code_step              = " + Convert.ToString(code_step    ) );
			Console.WriteLine("num_steps              = " + Convert.ToString(num_steps    ) );
			Console.WriteLine("code_duration          = " + Convert.ToString(code_duration) );
			
			//long max_duration_a_code__in_flat_segment = Math.Pow(2, 31)-1; // 2^32-1
			//long max_duration_a_code__in_flat_segment = Math.Pow(2, 16)-1; // 2^16-1
			//long max_duration_a_code__in_flat_segment = 16; // 16
			
			int    num_merge_steps = 1;
			double code_start_float = conv_bit_2s_comp_16bit_to_dec(code_start);
			Console.WriteLine("code_start         = " + Convert.ToString(code_start) );
			Console.WriteLine("code_start_float   = " + Convert.ToString(code_start_float) );
			//$$ double code_diff_float = conv_bit_2s_comp_16bit_to_dec(code_diff);   //$$  not used
			//$$ Console.WriteLine("code_diff_float    = " + Convert.ToString(code_diff_float) ); 
			
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
				Console.WriteLine("ratio_num_steps_max_num_codes__in_slope_segment = " + Convert.ToString(ratio_num_steps_max_num_codes__in_slope_segment) );
				num_merge_steps = (int)Math.Ceiling(ratio_num_steps_max_num_codes__in_slope_segment);
				Console.WriteLine("num_merge_steps                                 = " + Convert.ToString(num_merge_steps) );
				
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
			Console.WriteLine("code_value (hex) = [" + code_value_str       + "]");
			Console.WriteLine("code_value_float = [" + code_value_float_str + "]");
			Console.WriteLine("code_duration    = [" + code_duration_str    + "]");
			Console.WriteLine("time_ns          = [" + time_ns_str          + "]");
			

            //return Tuple.Create(pulse_info_num_block_str, sample_code); //$$ string 
            //return pulse_info_num_block_str;
			//return (pulse_info_num_block_str, code_value_float_str, time_ns_str, duration_ns_str);
            return Tuple.Create(pulse_info_num_block_str,code_value_float_str,time_ns_str,duration_ns_str);
        }



      

        public string initialize_aux_io()
        {
            //Console.WriteLine(String.Format("\n>>>>>"));

            byte[] PGU_AUX_OUTP_Init = Encoding.UTF8.GetBytes(cmd_str__PGU_AUX_OUTP + ":INIT\n");

            string rsp = Convert.ToString(scpi_comm_resp_ss(ss, PGU_AUX_OUTP_Init));

            //    def initialize_aux_io():
            //print('\n>>>>>>')
            //rsp = scpi_comm_resp_ss(ss, cmd_str__PGU_AUX_OUTP+ b':INIT\n')
            return rsp;

        }

        public void write_aux_io__direct(int para_ctrl)
        {
            //Console.WriteLine(String.Format("\n>>>>>> write_aux_io__direct"));



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

        public void InitializePGU(double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm = 50 )
        {
            //if (time_ns__dac_update >= 50) time_ns__dac_update = 50;  // # 20MHz # 50ns*1000*2^16= 3 276.8 milliseconds (3.2768 microseconds/1Point)
            //else if (time_ns__dac_update >= 20) time_ns__dac_update = 20;  // # 50MH
            //else if (time_ns__dac_update >= 10) time_ns__dac_update = 10;  // # 100MHz # 10ns*1000*2^16= 655.36 milliseconds (0.65536 microseconds/1Point)
            //else if (time_ns__dac_update >= 5) time_ns__dac_update = 5;   // # 200MHz
            //else time_ns__dac_update = 2.5; // # 400MHz # 2.5ns*1000*2^16=163.84 ms
            string LogFileName;
            LogFileName = LogFilePath +  "Debugger" + ".py"; //$$ for replit
			
            using (StreamWriter ws = new StreamWriter(LogFileName, false))
				ws.WriteLine("## Debuger Start"); //$$ add python comment header

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

            int DAC_offset_current__mA = 0; // 0 # 0.625 mA
            int N_pol_sel = 1; // 1

            int Sink_sel = 1; // 1

            int DAC_offset_current__code = Convert.ToInt32(DAC_offset_current__mA * 0x200 + 0.5);

            //if DAC_offset_current__code > 0x3FF :
            //print('>>> please check the offset current: {}'.format(DAC_offset_current__mA))
            //raise
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
        
        {          

			//time_ns__dac_update = this.time_ns__dac_update; //$$
			
            double gui_out_ch1_scale = 0.95;
            double gui_out_ch2_scale = 1.0;
            double gui_out_ch1_offset = -0.01;
            double gui_out_ch2_offset = 0.10;

            double gui_out_scale = 0.0;
            double gui_out_offset = 0.0;

            string Timedata;
            string Timedata_str = "";

            string Vdata;
            string Vdata_str = "";

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
			Console.WriteLine("Tdata_usr = [" + Timedata_str + "]");

            using (StreamWriter ws = new StreamWriter(LogFileName, true))
                 ws.WriteLine("Vdata_usr = [" + Vdata_str + "] \n");
			Console.WriteLine("Vdata_usr = [" + Vdata_str + "] \n");

            if (Ch == 1)
            {
                gui_out_scale = gui_out_ch1_scale;
                gui_out_offset = gui_out_ch1_offset;
            }
            else
            {
                gui_out_scale = gui_out_ch2_scale;
                gui_out_offset = gui_out_ch2_offset;
            }

            double Devide_V = 1; //$$ int --> double

            if (OutputRange == 40)
            {
                Devide_V = 4;
                scale_voltage_10V_mode = (6.95 / 10);
            }

            scale_voltage_10V_mode = scale_voltage_10V_mode * ((output_impedance_ohm + __gui_load_impedance_ohm) / __gui_load_impedance_ohm);
            Console.WriteLine("output_impedance_ohm     = " + Convert.ToString(output_impedance_ohm    ));
            Console.WriteLine("__gui_load_impedance_ohm = " + Convert.ToString(__gui_load_impedance_ohm));
            Console.WriteLine("scale_voltage_10V_mode   = " + Convert.ToString(scale_voltage_10V_mode  ));

			string level_volt_list_str = ""; //$$
            for (int i = 0; i < level_volt_list.Length; i++) //$$ for (int i = 1; i < level_volt_list.Length; i++) //$$ from i = 0
            {
				// # HVPGU B/D 사용 시 Gain 4배 증폭, Base전압을 1/4로 감소해야 함.
                level_volt_list[i] = level_volt_list[i] * scale_voltage_10V_mode / Devide_V;  
                //level_volt_list[i] = level_volt_list[i] * scale_voltage_10V_mode * gui_out_scale + gui_out_offset;
				
				// update string 
				level_volt_list_str += string.Format("{0,6:f3}, ",level_volt_list[i]);
            }
			Console.WriteLine("level_volt_list = [" + level_volt_list_str + "]");

			//$$ scale data check 
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                 ws.WriteLine("Tdata_cmd = [" + Timedata_str        + "]"); // time point
                 ws.WriteLine("Vdata_cmd = [" + level_volt_list_str + "] \n"); // voltage value
			}                            
			Console.WriteLine("Tdata_cmd = [" + Timedata_str        + "]"); // time point
			Console.WriteLine("Vdata_cmd = [" + level_volt_list_str + "] \n"); // voltage value
			

            long[] num_steps_list = new long[time_ns_list.Length - 1];
            //long[] num_steps_list = new long[time_ns_list.Length - 1];

            //#lyh_201221_rev
            //this.__gui_min_num_interpol = interpol;
            //int min_num_interpol = 20;

            int Point_NUM = Convert.ToInt32(1000 / (num_steps_list.Length));    //$$ FIFO Count limit 
			Console.WriteLine("Point_NUM = " + Convert.ToString(Point_NUM));

			string num_steps_list_str = ""; //$$
            for (int i = 1; i < time_ns_list.Length; i++)
            {
				num_steps_list[i - 1] = Convert.ToInt64(((time_ns_list[i] - time_ns_list[i - 1]) / time_ns__code_duration));  //$$ number of DAC points in eash segment

				//
				num_steps_list_str += string.Format("{0,6:d}, ",num_steps_list[i - 1]);
            }
			Console.WriteLine("num_steps_list       = [" + num_steps_list_str + "]");
            //#lyh_201221_rev

			string level_diff_volt_list_str = ""; //$$
            double[] level_diff_volt_list = new double[level_volt_list.Length - 1];
			num_steps_list_str = ""; //$$ clear
            for (int i = 1; i < level_volt_list.Length; i++)
            {
                level_diff_volt_list[i - 1] = level_volt_list[i] - level_volt_list[i - 1]; //$$ dac incremental value in each segment
				level_diff_volt_list_str += string.Format("{0,6:f3}, ", level_diff_volt_list[i - 1]);
				
            }
			//  Console.WriteLine("num_steps_list       = [" + num_steps_list_str + "]");
			Console.WriteLine("level_diff_volt_list = [" + level_diff_volt_list_str + "]");

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
                Console.WriteLine("level_step_code_list[" + Convert.ToString(i) + "] = " + Convert.ToString(level_step_code_list[i]) );
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
			Console.WriteLine("time_step_code_list = [" + time_step_code_list_str + "]");

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
			Console.WriteLine("max_duration_a_code__in_flat_segment = " + Convert.ToString(max_duration_a_code__in_flat_segment));
			
			
			//long max_num_codes__in_slope_segment = (long)16; //Point_NUM;
			long max_num_codes__in_slope_segment = Point_NUM;
			Console.WriteLine("max_num_codes__in_slope_segment = " + Convert.ToString(max_num_codes__in_slope_segment));
			

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
				Console.WriteLine("time_ns_str_double        = " + Convert.ToString(time_ns_str_double));
				Console.WriteLine("time_ns_str_double.Length = " + Convert.ToString(time_ns_str_double.Length));
				num_steps_list[i] = (long)(time_ns_str_double.Length);
				
            }

			
			//$$ print out DAC points in FIFO
            using (StreamWriter ws = new StreamWriter(LogFileName, true)) { //$$ true for append
                 ws.WriteLine("Tdata_seg = [" + merge_time_ns_str          + "]"); // time point
                 ws.WriteLine("Ddata_seg = [" + merge_duration_ns_str      + "]"); // duration time
                 ws.WriteLine("Vdata_seg = [" + merge_code_value_float_str + "] \n"); // voltage value
			}                            
			Console.WriteLine("Tdata_seg = [" + merge_time_ns_str          + "]"); // time point
			Console.WriteLine("Ddata_seg = [" + merge_duration_ns_str      + "]"); // duration time
			Console.WriteLine("Vdata_seg = [" + merge_code_value_float_str + "] \n"); // voltage value

			//$$ FIFO count = size of (Tdata_seg)
			double[] Tdata_seg_double = Array.ConvertAll(merge_time_ns_str.Remove(merge_time_ns_str.Length-2,1).Split(','), Double.Parse);
			Console.WriteLine("Tdata_seg_double = " + Convert.ToString(Tdata_seg_double));
			Console.WriteLine("Tdata_seg_double.Length = " + Convert.ToString(Tdata_seg_double.Length));
			
			//$$ datacount in FIFO
			long FIFO_Count = Tdata_seg_double.Length;
			Console.WriteLine("FIFO_Count = " + Convert.ToString(FIFO_Count));
			
			return Tuple.Create(num_steps_list, num_block_str__sample_code__list, FIFO_Count);
            //$$return Tuple.Create(num_steps_list, num_block_str__sample_code__list);
            //return num_block_str__sample_code__list;

        }

        public void load_pgu_waveform(int Ch, int[] num_block_str__sample_code__list)
        {
            ////Console.WriteLine(String.Format("\n>>>>>> load_pgu_waveform()"));
            ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC0);
            
            if (Ch == 1)
            {
                for (int k = 0; k < (num_block_str__sample_code__list.Length); k++)
                {
                    string PGU_FDCS_DAC0 = Convert.ToString(cmd_str__PGU_FDCS_DAC0 + num_block_str__sample_code__list[k]);
                    byte[] PGU_FDCS_DAC0_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_DAC0);
                    scpi_comm_resp_ss(ss, PGU_FDCS_DAC0_CMD);
                }
                ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC1);
            }
            else
            {
                for (int k = 0; k < (num_block_str__sample_code__list.Length); k++)
                {
                    string PGU_FDCS_DAC1 = Convert.ToString(cmd_str__PGU_FDCS_DAC1 + num_block_str__sample_code__list[k]);
                    byte[] PGU_FDCS_DAC1_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_DAC1);
                    scpi_comm_resp_ss(ss, PGU_FDCS_DAC1_CMD, BUF_SIZE_NORMAL, INTVAL); //$$ ??
                }
                ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_RPT);
            }


        }

        public void trig_pgu_output(int pgu_repeat_num, int delay)
        {
            __gui_cycle_count = pgu_repeat_num;
            int pulse_repeat_number_dac0 = __gui_cycle_count;
            int pulse_repeat_number_dac1 = __gui_cycle_count;

            string pgu_repeat_num_str = string.Format(" #H{0,4:X4}{1,4:X4} \n", pulse_repeat_number_dac1, pulse_repeat_number_dac0);


            byte[] PGU_FDCS_RPT_Init = Encoding.UTF8.GetBytes(cmd_str__PGU_FDCS_RPT + pgu_repeat_num_str);

            scpi_comm_resp_ss(ss, PGU_FDCS_RPT_Init);

            ////Console.WriteLine(String.Format("\n>>>>>> trig_pgu_output()"));

            string PGU_FDCS_TRIG_ON = Convert.ToString(cmd_str__PGU_FDCS_TRIG) + " ON\n";
            byte[] PGU_FDCS_TRIG_ON_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_TRIG_ON);

            ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", PGU_FDCS_TRIG_ON_CMD);

            scpi_comm_resp_ss(ss, PGU_FDCS_TRIG_ON_CMD);

            Delay(delay); //delay 3.5s

            string PGU_FDCS_TRIG_OFF = Convert.ToString(cmd_str__PGU_FDCS_TRIG) + " OFF\n";
            byte[] PGU_FDCS_TRIG_OFF_CMD = Encoding.UTF8.GetBytes(PGU_FDCS_TRIG_OFF);

            ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", PGU_FDCS_TRIG_OFF_CMD);

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
            ////Console.WriteLine(String.Format("\n>>>>>> load_pgu_waveform()"));
            ////Console.WriteLine(String.Format("'\n>>> {} : {}'"), "Test", cmd_str__PGU_FDCS_DAC0);
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

            //$$ check fifo data count
            long __FIFO_DATA_COUNT_MAX__ = 1000;
            if (range.Item3 > __FIFO_DATA_COUNT_MAX__) {
                return -2; // FIFO data count overflow
            }

            load_pgu_waveform_Cid(PG_Ch, range.Item1, range.Item2); //$$ (int Ch, long[] len_fifo_data, string[] pulse_info_num_block_str)

            return ret;
        }

        public string ForcePGU(int CycleCount, int delay)
        {
            //## initialize PGU 

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
			
			Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x0000));
			Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x7FFF));
			Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x8000));
			Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0x0001));
			Console.WriteLine(dev.conv_bit_2s_comp_16bit_to_dec(0xFFFF));
			
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
			
			
			// call pulse setup
            long[]   StepTime ;
            double[] StepLevel;
            int ret;
			
			// public void InitializePGU(double time_ns__dac_update, int time_ns__code_duration, double scale_voltage_10V_mode, double output_impedance_ohm)
            dev.InitializePGU(10, 10, 7.650 / 10, 50); //$$ OK, board output impedance is normally 50ohm
			
			// case1 AA // 0
			StepTime  = new long[]   {   0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000 };
			StepLevel = new double[] { 0.0,  0.0,  1.0,  1.0,  2.0,  2.0,  0.5,  0.5,  0.0,  0.0 };
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case2 BB // 1
			StepTime  = new long[]   {   0,  500, 2000, 3000, 4000, 5000, 6000, 7000, 8500, 9000 };
			StepLevel = new double[] { 0.0,  0.0,  1.0,  1.0,  2.0,  2.0,  0.5,  0.5,  0.0,  0.0 };
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case3 CC // - 20ns slope
			StepTime  = new long[]   {0, 20, 40, 70, 90, 100};
			StepLevel = new double[] {0,  0, 20, 20,  0,   0};
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case4 DD // - 30ns slope
			StepTime  = new long[]   {0, 10, 40, 60, 90, 100};
			StepLevel = new double[] {0,  0, 20, 20,  0,   0}; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case5 EE // - 10ns slope1
			StepTime  = new long[]   {0, 40, 50, 120, 130, 1000};
			StepLevel = new double[] {0,  0, 20,  20,   0,    0}; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case6 FF // - 10ns slope2
			StepTime  = new long[]   {0, 40, 50, 100, 110, 1000};
			StepLevel = new double[] {0,  0, 20,  20,   0,    0}; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			
			// case7 GG // _7_  //duration of one count duration causes error in repeat pattern
			StepTime  = new long[]   {    0,     10,      20,      60,     70,    200};
			StepLevel = new double[] {0.000,  0.000, -20.000, -20.000,  0.000,  0.000}; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			 
			// case8 HH // _8_  // +/- changing slope 
			StepTime  = new long[]   {     0,     10,     40,      60,      90,    100 };
			StepLevel = new double[] { 0.000, 20.000, 20.000, -20.000, -20.000,  0.000 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			
			// case9 II // _9_ // pulse info 1 :  (0V, 15000ns) + (slope, 200ns) + (-Vgp, 4130000ns) + (slope, 200ns)  ...  4.145400 ms = 4145400 ns
			StepTime  = new long[]   {     0, 15000,  15200, 4145200, 4145400 };
			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			
			// case10 JJ // _10_ // pulse info 2 : (0V, 15000ns) + (slope, 1000ns) + (-Vgp, 4130000ns) + (slope, 1000ns)  ... = 4147000 ns
			StepTime  = new long[]   {     0, 15000,   16000, 4146000, 4147000 };
			StepLevel = new double[] {     0,     0,   -4.43,   -4.43,       0 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

			// case11 KK // _11_ // pulse info 3 : (0V, 15000ns) + (slope, 100000ns) + (-Vgp, 4130000ns) + (slope, 100000ns)  ... = 4345000 ns
			StepTime  = new long[]   {     0, 15000, 115000, 4245000, 4345000 };
			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

			// case12 LL // 10s pulse // 10s = 10000000000 ns
			StepTime  = new long[]   {     0,  1000,  2000,  8000002000,  8000003000, 10000000000 };
			StepLevel = new double[] {     0,     0,     5,           5,           0,           0 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

			// case13 MM // 1s pulse // 10s = 10000000000 ns
			StepTime  = new long[]   {     0, 1000000000, 1400000000, 6000000000, 6400000000, 10000000000 };
			StepLevel = new double[] { 0.000,      0.000,     20.000,     20.000,      0.000,       0.000 }; 
			dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			
			// case14 NN // 50 ohm output check
			StepTime  = new long[]   {     0, 15000, 115000, 4245000, 4345000 };
			StepLevel = new double[] {     0,     0,  -4.43,   -4.43,       0 }; 
			dev.SetSetupPGU(1, 40, 50, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)

			// case15 OO // 0 delay pulse causing duplicate
			StepTime  = new long[]   {     0,       00,      200,    15000,     15200,    4145000 };
			StepLevel = new double[] { 0.000,    0.000,    -4.43,    -4.43,     0.000,      0.000 }; 
			ret = dev.SetSetupPGU(1, 40, 1e6, StepTime, StepLevel); // (int PG_Ch, int OutputRange, double Impedance, long[] StepTime, double[] StepLevel)
			
			//Console.WriteLine("SetSetupPGU return Code = " + Convert.ToString(ret) );

			return 0x3535ACAC;
		}
		

              
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

//Rextester.Program.Main is the entry point for your code. Don't change it.
//Microsoft (R) Visual C# Compiler version 2.9.0.63208 (958f2354)

//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text.RegularExpressions;

namespace Rextester
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
