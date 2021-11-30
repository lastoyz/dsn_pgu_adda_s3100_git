using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

//$$ https://micropilot.tistory.com/category/C%23/Button%20added

using TOP_HVPGU = TopInstrument.TOP_HVPGU__EPS_SPI; // EPS emulated on SPI bus

//$$namespace test_win_app_vscode
namespace __test__
{
    
    public partial class Form1 : Form
    {

        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e) 
        { 
            Console.WriteLine(string.Format(">>> button1 : all processes"));

            TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards

            TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

        }

        private void button2_Click(object sender, EventArgs e) 
        { 
            Console.WriteLine(string.Format(">>> button2 : process ready (40V output enabled)"));

            //TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards

            TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

        }

        private void button3_Click(object sender, EventArgs e) 
        { 
            Console.WriteLine(string.Format(">>> button3 : process trigger (test waveform)"));

            //TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards

            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

        }

        private void button4_Click(object sender, EventArgs e) 
        { 
            Console.WriteLine(string.Format(">>> button4 : process read_adc_buf (read adc buffer)"));

            //TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards

            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

        }

        private void button5_Click(object sender, EventArgs e) 
        { 
            Console.WriteLine(string.Format(">>> button5 : process standby (finish)"));

            //TopInstrument.EPS_Dev.__test_eps_dev(); // test EPS // scan slot and report FIDs of boards

            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__ready();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__trigger();
            //TOP_HVPGU.__test_TOP_HVPGU_ADDA__read_adc_buf();
            TOP_HVPGU.__test_TOP_HVPGU_ADDA__standby();

        }


    }
}
