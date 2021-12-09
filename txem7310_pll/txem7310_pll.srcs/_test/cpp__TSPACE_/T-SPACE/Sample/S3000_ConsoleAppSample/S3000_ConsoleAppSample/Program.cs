using System;
using System.Text;
using System.Threading;

//
using Top.Instrument.S3000;

namespace S3000_ConsoleAppSample
{
    class Program
    {
        public static S3000 Inst;
        public const int SMU_MAX = 2;

        static void Main(string[] args)
        {           
            
            Inst = new S3000();
            Inst.NetworkIP = "192.168.100.201";
            Inst.Timeout = 3000;

            int result;

            result = Inst.OpenSystem(); //Open System
            
            if (result != S3000.NOERR)
            {
                Console.WriteLine("Error! Can not connect to S3000.");
                return;
            }           
            
            string RecvData = "";
            Inst.SendCommand("GET:VER?", ref RecvData);
            Console.WriteLine("S3000 F/W Version : " + RecvData);
            
            //init example
            InitSmuChannels();
            
            //meas example
            Pin2_meas();
            
            Console.ReadLine();


            Inst.CloseSystem(); //Close System

        }

        static void InitSmuChannels()
        {
            int i;
            for (i = 1; i < SMU_MAX; i++)
            {              
                Inst.ForceV(i, 0.0, 20, 0.0001, 0.0001);
            }

            Thread.Sleep(100);

            for (i = 1; i < SMU_MAX; i++)
            {
                Inst.SmuOutputRly(i, 0);
            }

            Inst.GnduOutputRly(0);

            Thread.Sleep(100);
        }

        static void Pin2_meas()
        {
            //define
            int IntegMode;
            int Ua, Uc;
            double Va_start, Va_stop, Va_step;
            double Vc_offset, Vc_ratio;
            double Compl;
            double Va_rng, Vc_rng;
            double TimeHold, TimeDelay;
           
            int LoopCount;

            double[] Va, Vc, Ia, Ic;

            //setting
            IntegMode = 1; //1:short, 2:Medium(1PLC) , 3:Long(16PLC)

            Ua = 1; //SMU1
            Uc = 2; //SMU2

            Va_start = 0;
            Va_stop = 4;
            Va_step = 0.05;

            Vc_offset = -0.5;
            Vc_ratio = 1;

            Compl = 0.01; //0.01A (10mA)

            TimeHold = 0.1; //100ms
            TimeDelay = 0.01; //10ms
            
            LoopCount = (int)((Va_stop - Va_start) / Va_step + 1);

            Va_rng = Math.Max(Math.Abs(Va_start), Math.Abs(Va_stop));
            Vc_rng = Math.Max(Math.Abs(Va_start*Vc_ratio+Vc_offset), Math.Abs(Va_stop*Vc_ratio+Vc_offset)); 

            
            //Init
            Inst.ForceV(Ua, 0, Va_rng, Compl, Compl);
            Inst.ForceV(Uc, 0, Vc_rng, Compl, Compl);

            Inst.SmuOutputRly(Ua, 1);
            Inst.SmuOutputRly(Uc, 1);

            
            //Sweep
            int i;
            int[] Um;
            double[] Im;

            Um = new int[2] { Ua, Uc };
            Im = new double[2];

            Va = new double[LoopCount];
            Vc = new double[LoopCount];
            Ia = new double[LoopCount];
            Ic = new double[LoopCount];

            //
            Console.WriteLine("     Va, Vc, Ia, Ic");

            Inst.SetAdc(0, IntegMode);
            //Inst.SetAdc(0, 3, 5);       //Long, 5PLC : Long모드에서는 PLC 갯수 임의 설정가능

            for (i = 0; i < LoopCount; i++)
            {
                Va[i] = Va_start + Va_step * i;
                Vc[i] = Va[i] * Vc_ratio + Vc_offset;

                Inst.ForceV(Ua, Va[i], Va_rng, Compl);
                Inst.ForceV(Uc, Vc[i], Vc_rng, Compl);

                if (i == 0) Inst.WaitDelay(TimeHold); //wait hold_time.

                Inst.WaitDelay(TimeDelay); //wait delay_time

                Inst.MeasureIM(2, Um, ref Im, 1e-9, 1);

                Ia[i] = Im[0];
                Ic[i] = Im[1];

                //
                Console.WriteLine(i + "," + Va[i] + "," + Vc[i] + "," + Ia[i] + "," + Ic[i]);

            }

            //Init
            Inst.ForceV(Ua, 0, Va_rng, Compl);
            Inst.ForceV(Uc, 0, Vc_rng, Compl);

            Inst.SmuOutputRly(Ua, 0);
            Inst.SmuOutputRly(Uc, 0);           
       
        }

    }
}
