#ifndef __EPS_Dev_H__
#define __EPS_Dev_H__

#include <stdio.h>
#include <WinSock2.h>
#pragma comment(lib, "ws2_32") //$$ to revise

//#include <stddef.h> //$$ for NULL
#undef NULL
#define NULL 0

//#define PORT 4578
//#define PACKET_SIZE 1024

#define PORT 5025
#define PACKET_SIZE 16384	//2048
//#define SERVER_IP "192.168.100.84"
//$$#define SERVER_IP "192.168.100.88" // CMU // DUT
#define SERVER_IP "192.168.100.77" // S3100-CPU-BASE // DUT

//#define SERVER_IP "192.168.100.87"

#define cmd_str_IDN			"*IDN?\n"
#define cmd_str_rst			"*RST\n"
#define cmd_str_EPS_EN		":EPS:EN"
#define cmd_str_EPS_WMI		":EPS:WMI"
#define cmd_str_EPS_WMO		":EPS:WMO"
#define cmd_str_EPS_TAC		":EPS:TAC"
#define cmd_str_EPS_TMO		":EPS:TMO"
#define cmd_str_EPS_TWO		":EPS:TWO"
#define cmd_str_EPS_PI		":EPS:PI"
#define cmd_str_EPS_PO		":EPS:PO"

//$$#define SO_SNDBUF			2048  //$$ to revise
//$$#define SO_RCVBUF			32768 //$$ to revise

#define BUF_SIZE_COMMAND	32
#define BUF_SIZE_RESP_CHK	64	

#define BUF_SIZE_NORMAL		2048
#define BUF_SIZE_LARGE		131072

#define TIMEOUT				500
#define TIMEOUT_LARGE		TIMEOUT*10
#define INTVAL				0.1




#include <iostream>
#include <string>
//using namespace std;

class EPS_Dev
{
public:
		EPS_Dev();
		~EPS_Dev();
		char *c_p_scpi_comm_resp;
		char *c_p_cmd_str;
		unsigned char *adc_raw_dataout0, *adc_raw_dataout1;
		char *adc_raw_data_buf0, *adc_raw_data_buf1;
		
		char *adc_raw_data_rcv_buf;
		unsigned int *adc_raw_data_rcv_int_buf;
		int *adc_raw_dataout_i0, *adc_raw_dataout_i1;
		int *adc_raw_dataout_i0_adc_init, *adc_raw_dataout_i1_adc_init;

		char *c_p_cmd_str_flt32_to_fpga;

		char *test_resp;





public:

	int dev_count;
	SOCKADDR_IN tAddr;
	SOCKET hSocket;
	

	//unsigned char adc_raw_dataout0[524288], adc_raw_dataout1[524288];
	int* adc_raw_data0;
	int* adc_raw_data1;
	double adc_double_raw_data0[131072], adc_double_raw_data1[131072];
	double adc_voltage_raw_data0[131072], adc_voltage_raw_data1[131072];

	


	int fifo_adc0_empty, fifo_adc1_empty;





	

	//int scpi_comm_resp(char cmd_str[], char *ret, int intval = 0.1, int buf_size = BUF_SIZE_NORMAL);
	//char *scpi_comm_resp_numb(char cmd_str[], int length = BUF_SIZE_LARGE, int intval = 0.1, int timeout_large=TIMEOUT_LARGE);
	//char *scpi_comm_resp_numb(char cmd_str[], int length);//, int intval = 0.1, int timeout_large);
	//char *scpi_comm_resp_old(char cmd_str[], int intval = 0.1, int buf_size = BUF_SIZE_NORMAL);

	bool scpi_open();
	
	int GetWireOutValue(int adrs, int mask = 0xFFFFFFFF);
	int scpi_comm_resp(char cmd_str[], char *ret, int buf_size);
	int scpi_comm_resp_for_pipe_in(char cmd_str[], char *ret, int buf_size);

	int scpi_comm_resp_numb(char cmd_str[], int *data, int length);

	int SetWireInValue(int adrs, unsigned int data, int mask=0xFFFFFFFF);
	void Close();

	void SetWireInValue_test(char cmd_str[], int adrs, unsigned int data, int mask);
	
	void GetDeviceCount();
	int ActivateTriggerIn(int adrs, int loc_bit);
	//int IsTriggered(int adrs, int mask);
	bool IsTriggered(int adrs, int mask);
	int GetTriggerOutVector(int adrs, int mask = 0xFFFFFFFF);
	//int ReadFromPipeOut(int adrs, int length, unsigned char data_bytearray[]);
	int ReadFromPipeOut(int adrs, int length, int *data);
	void WriteToPipeIn(int adrs, int length, int *data);

	void UpdateWireIns();
	void UpdateWireOuts();

	void GetSerialNumber(char *serial_number);

	void cmu_adc_enable();
	void cmu_adc_reset();
	void cmu_adc_set_para();
	void cmu_adc_init();
	void cmu_adc_is_fifo_empty();
	void cmu_check_adc_test_pattern();
	void cmu_adc_update();

	int ReadFromPipeOut2(int adrs, int length, unsigned char data_bytearray[]);



	void cmu_adc_load_from_fifo(int adc_num_samples);
	
	

	void cmu_spo_enable();
	void cmu_spo_init();
	void cmu_spo_update();
	void cmu_spo_bit_amp_pwr();
	void cmu_spo_set_buffer(int adrs, int val, unsigned int mask);

	int cmu_dwave_enable();
	int cmu_dwave_disable();
	int cmu_dwave_init();
	int cmu_dwave_update();

	void set_cmu_dwave(unsigned int frequency);
	void cmu_dwave_read_cnt_period();
	void cmu_dwave_write_cnt_diff(int val);
	void cmu_dwave_write_trig(int bit_loc, int val);
	void cmu_dwave_read_trig(int bit_loc);
	void cmu_dwave_set_para();
	void cmu_dwave_write_cnt_period(int val);
	void cmu_dwave_read_cnt_diff();
	
	void cmu_dwave_pulse_on();
	void cmu_dwave_pulse_off();

	void cmu_write_raw_data(int adc_num_samples);

	int Test(int &test_array);
	

	void sleep(unsigned long time);

	void UpdateTriggerOuts();

	int _test();

};

#endif