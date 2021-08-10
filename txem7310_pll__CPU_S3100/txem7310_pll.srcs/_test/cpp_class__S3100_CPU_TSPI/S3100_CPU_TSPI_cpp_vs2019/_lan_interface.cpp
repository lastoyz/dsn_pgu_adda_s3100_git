#include <stdio.h>
#include <stdlib.h>
#include <time.h>

//#include <WinSock2.h>
//#pragma comment(lib, "ws2_32")

#include <iostream>
#include <string>

#include "_lan_interface.h"
#include "EP_CONF_ADRS_LIB.h"

using namespace std;

//#define PORT 5025
//#define PACKET_SIZE 2048
//#define SERVER_IP "192.168.100.090"


//$$#pragma warning(disable: 4996) //#define _CRT_SECURE_NO_WARNINGS //$$




EPS_Dev::EPS_Dev()
{

	test_resp = new char [50000];

	c_p_cmd_str_flt32_to_fpga = new char [131072];

	c_p_scpi_comm_resp = new char [64];
	c_p_cmd_str = new char [64];

	adc_raw_dataout0 = new unsigned char [524288];
	adc_raw_dataout1 = new unsigned char [524288];

	adc_raw_data_buf0 = new char [524288];
	adc_raw_data_buf1 = new char [524288];

	adc_raw_data_rcv_buf = new char [524288+1+10];
	adc_raw_data_rcv_int_buf = new unsigned int [131072];

	adc_raw_dataout_i0 = new int [131072];
	adc_raw_dataout_i1 = new int [131072];

	adc_raw_dataout_i0_adc_init = new int [131072];
	adc_raw_dataout_i1_adc_init = new int [131072];

	




}
EPS_Dev::~EPS_Dev()
{
	delete []adc_raw_dataout0;
	delete []adc_raw_dataout1;

	delete []adc_raw_data_buf0;
	delete []adc_raw_data_buf1;

	delete []adc_raw_data_rcv_buf;
	delete []adc_raw_data_rcv_int_buf;

	delete []adc_raw_dataout_i0;
	delete []adc_raw_dataout_i1;

	delete []adc_raw_dataout_i0_adc_init;
	delete []adc_raw_dataout_i1_adc_init;

	delete []c_p_scpi_comm_resp;

	delete []c_p_cmd_str;

	delete []c_p_cmd_str_flt32_to_fpga;

	delete []test_resp;


}



bool EPS_Dev::scpi_open()
{
	WSADATA wsaData;
	WSAStartup(MAKEWORD(2, 2), &wsaData);

	hSocket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

	//tAddr = {};
	tAddr.sin_family = AF_INET;
	tAddr.sin_port = htons(PORT);
	tAddr.sin_addr.s_addr = inet_addr(SERVER_IP);
	// RecvAddr.sin_addr.s_addr = inet_addr("192.168.1.1");
	// InetPton(AF_INET, _T("192.168.1.1"), &RecvAddr.sin_addr.s_addr);
	
	string str_tmp = "";

	str_tmp = SERVER_IP;



	connect(hSocket, (SOCKADDR*)&tAddr, sizeof(tAddr));


	sprintf(c_p_cmd_str, "%s ON\n",cmd_str_EPS_EN);

	int data_cnt;


	data_cnt = scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK);

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("response : %s\n", c_p_scpi_comm_resp);

	return true;





}

int EPS_Dev::GetWireOutValue(int adrs, int mask)
{



	sprintf(c_p_cmd_str, "%s#H%02X #H%08X\n", cmd_str_EPS_WMO, adrs, mask);

	printf("getwire command : %s\n", c_p_cmd_str);

	int data_cnt;	

	data_cnt = (scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK));

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("getwire resp : %s\n", c_p_scpi_comm_resp);




	char *wire_out_ret;

	wire_out_ret = new char [64];


	int i, j;

	j = 0;


	int max_idx;

	for (i = 0; i < 64; i++)
	{
		if((*(c_p_scpi_comm_resp + j) == '#') | (*(c_p_scpi_comm_resp + j) == 'H'))
		{
			j++;
			i--;
			continue;
		}
		else if(*(c_p_scpi_comm_resp + j) == NULL)
		{
			max_idx = i-2;
			break;
		}
		else
		{
			*(wire_out_ret + i) = *(c_p_scpi_comm_resp + j);
			j++;
		}

	}




	char c_ret[1];
	int ret_int;



	ret_int = strtol(wire_out_ret,NULL, 16);

	delete []wire_out_ret;

	return ret_int;

}



//int EPS_Dev::GetWireOutValue(int adrs, int mask)
//{
//	string cmd_str = "";
//
//
//
//	char cMsg[2048];
//
//
//
//	cmd_str = ":EPS:EN ON\n";
//
//	
//
//	//const char tmp[2048];
//
//	//strcpy(tmp, 
//
//	strcpy(cMsg, cmd_str.c_str());
//	
//	send(hSocket, cMsg, strlen(cMsg), 0);
//
//	string rcv_str;
//
//	
//
//	char cBuffer[PACKET_SIZE] = {};
//
//	recv(hSocket, cBuffer, PACKET_SIZE, 0);
//
//	int i;
//
//	for(i = 0; i<PACKET_SIZE; i++)
//	{
//		if(cBuffer[i] == NULL)
//		{		
//			break;
//		}
//		rcv_str = rcv_str + cBuffer[i];
//
//	}
//
//	int rcv_tmp;
//	rcv_tmp = atoi(rcv_str.c_str());
//
//
//
//
//	cmd_str = ":EPS:WMO#H20 #HFFFFFFFF\n";
//
//	
//
//	//const char tmp[2048];
//
//	//strcpy(tmp, 
//
//	strcpy(cMsg, cmd_str.c_str());
//	
//	send(hSocket, cMsg, strlen(cMsg), 0);
//
//	//string rcv_str;
//
//	//char cBuffer[PACKET_SIZE] = {};
//
//	recv(hSocket, cBuffer, PACKET_SIZE, 0);
//
//	//int i;
//
//	for(i = 0; i<PACKET_SIZE; i++)
//	{
//		if(cBuffer[i] == NULL)
//		{		
//			break;
//		}
//		rcv_str = rcv_str + cBuffer[i];
//
//	}
//
//	//int rcv_tmp;
//	rcv_tmp = atoi(rcv_str.c_str());
//
//	int t;
//
//	t = 0;
//
//	
//
//
//	return 0;
//
//
//}

//int scpi_comm_resp(char cmd_str[], char *ret, int intval = 0.1, int buf_size = BUF_SIZE_NORMAL)
//{
//	char *c_cmd_str;
//
//	int cmd_char_count;
//
//	cmd_char_count = 64;
//
//	c_cmd_str = new char [cmd_char_count];
//	memset(c_cmd_str, 0, cmd_char_count);
//
//
//
//	int cmd_char_cnt_idx;
//
//	for (cmd_char_cnt_idx = 0; cmd_char_cnt_idx < cmd_char_count; cmd_char_cnt_idx++)
//	{
//		if (cmd_str[cmd_char_cnt_idx] == NULL)
//		{
//			break;
//		}
//		*(c_cmd_str + cmd_char_cnt_idx) = cmd_str[cmd_char_cnt_idx];
//	}
//	
//
//	int tmp;
//
//	tmp = strlen(c_cmd_str);
//
//	send(hSocket, c_cmd_str, strlen(c_cmd_str), 0);
//
//	//sleep(500);//////////////////////////////////////
//
//
//	delete c_cmd_str;
//
//	char *ret_resp = (char *) malloc(64);
//
//	//char ret_resp[64];
//	int i;
//
//	memset(ret_resp, 0, (sizeof(char) *64));
//
//
//
//
//	//recv(hSocket, cBuffer, PACKET_SIZE, 0);
//	recv(hSocket, ret_resp, 64, 0);
//
//	int ret_char_cnt_idx;
//
//	return ret_resp;
//
//	//return ret_resp;
//
//}

int EPS_Dev::scpi_comm_resp_for_pipe_in(char cmd_str[], char *ret, int buf_size)
{

	int chk_val;

	chk_val = strlen(cmd_str);

	
	//send(hSocket, cmd_str, strlen(cmd_str), 0);

	if (buf_size >= 2560)
	{
		send(hSocket, cmd_str, 10263, 0);		// 22 + 2560*4 + 1 //NULL (header + data + NULL)
	}
	else
	{
		send(hSocket, cmd_str, 22+buf_size*4+1, 0);

	}


	int data_cnt;

	//while(1)
	//{
	//	data_cnt = recv(hSocket, ret, buf_size, 0);

	//	//sleep(10);

	//	if(data_cnt >= 0)
	//	{
	//		break;
	//	}
	//	else
	//	{
	//		data_cnt = recv(hSocket, ret, buf_size, 0);
	//	}

	//}

	//sleep(10);

	//sleep(200);

	while(1)
	{
		data_cnt = recv(hSocket, ret, buf_size, 0);
		if(data_cnt >= 3)
		{
			if((ret[0] == 'O') && (ret[1] == 'K'))
			{
				break;
			}
		}
		else if(data_cnt == 2)
		{
			if((ret[0] == 'O') && (ret[1] == 'K'))
			{
				while(1)
				{
					data_cnt = recv(hSocket, ret, buf_size, 0);
					if(data_cnt >= 1)
					{
						break;
					}



				}
			}
			else
			{
				//exit function
			}
		
		}
		else if(data_cnt == 1)
		{
			if(ret[0] == 'O')
			{
				while(1)
				{
					data_cnt = recv(hSocket, ret, buf_size, 0);
					if(data_cnt >= 1)
					{
						if(ret[0] == 'K')
						{
							break;
						}
						else
						{
							//exit function
						}
					}

				}
			}
			else
			{
				//exit function
			}

		}

	}



	//data_cnt = recv(hSocket, ret, buf_size, 0);

	//if(data_cnt == (-1))
	//{
	//	data_cnt = recv(hSocket, ret, buf_size, 0);
	//}

	ret[data_cnt] = 0;



	return data_cnt;

}





int EPS_Dev::scpi_comm_resp(char cmd_str[], char *ret, int buf_size)
{

	int chk_val;

	chk_val = strlen(cmd_str);

	
	send(hSocket, cmd_str, strlen(cmd_str), 0);



	int data_cnt;

	//while(1)
	//{
	//	data_cnt = recv(hSocket, ret, buf_size, 0);

	//	//sleep(10);

	//	if(data_cnt >= 0)
	//	{
	//		break;
	//	}
	//	else
	//	{
	//		data_cnt = recv(hSocket, ret, buf_size, 0);
	//	}

	//}

	//sleep(10);

	//sleep(200);

	
	data_cnt = recv(hSocket, ret, buf_size, 0);


	//double conv_val;

	//conv_val = strtol(ret, &(ret+4), 16);



	//data_cnt = recv(hSocket, ret, buf_size, 0);

	//if(data_cnt == (-1))
	//{
	//	data_cnt = recv(hSocket, ret, buf_size, 0);
	//}

	ret[data_cnt] = 0;



	return data_cnt;

}

int EPS_Dev::SetWireInValue(int adrs, unsigned int data, int mask)
{


	sprintf(c_p_cmd_str, "%s#H%02X #H%08X  #H%08X\n", cmd_str_EPS_WMI, adrs, data, mask);


	printf("command : %s\n", c_p_cmd_str);


	int data_cnt;




	data_cnt = scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK);

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("response : %s\n", c_p_scpi_comm_resp);


	return data_cnt;




}








void EPS_Dev::Close()
{
	printf("Close..\n");

	sprintf(c_p_cmd_str, "%s OFF\n",cmd_str_EPS_EN);

	printf("command : %s\n", c_p_cmd_str);

	int data_cnt;

	data_cnt = scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK);

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("response : %s\n", c_p_scpi_comm_resp);



	closesocket(hSocket);
	WSACleanup();

	
	

	
}



void EPS_Dev::GetDeviceCount()
{



}


int EPS_Dev::ActivateTriggerIn(int adrs, int loc_bit)
{


	sprintf(c_p_cmd_str, "%s#H%02X #H%02X\n", cmd_str_EPS_TAC, adrs, loc_bit);

	printf("Activate triggerin command : %s\n", c_p_cmd_str);


	int data_cnt;

	data_cnt = (scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK));

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("Activate triggerin response : %s\n", c_p_scpi_comm_resp);

	return data_cnt;

}

bool EPS_Dev::IsTriggered(int adrs, int mask)
{

	bool ret;
	char ret_char[4];

	sprintf(c_p_cmd_str, "%s#H%02x #H%08x\n", cmd_str_EPS_TMO, adrs, mask);

	printf("command : %x\n", c_p_cmd_str);

	int data_cnt;

	data_cnt = (scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK));

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("response : %s\n", c_p_scpi_comm_resp);

	string resp_str;

	int i;

	for(i = 0; i < 4; i++)
	{
		if(*(c_p_scpi_comm_resp + i) == 0)
		{
			break;
		}
		ret_char[i] = *(c_p_scpi_comm_resp + i);
	}


	if(ret_char == "OFF")
	{
		ret = false;
	}
	else if(ret_char == "ON")
	{
		ret = true;
	}


	return ret;

	

}

int EPS_Dev::GetTriggerOutVector(int adrs, int mask)
{

	const char *c_p_resp;

	//c_p_resp = new char[64];

	sprintf(c_p_cmd_str, "%s#H%02X #H%08X\n", cmd_str_EPS_TWO, adrs, mask);

	int data_cnt;

	data_cnt = (scpi_comm_resp(c_p_cmd_str, c_p_scpi_comm_resp, BUF_SIZE_RESP_CHK));

	c_p_scpi_comm_resp[data_cnt] = 0;

	printf("response : %s\n", c_p_scpi_comm_resp);

	string str_resp = "0x";

	int i;

	//*(c_p_resp + 0) = "0";
	//*(c_p_resp + 1) = "x";

	for(i = 2; i < 64; i++)
	{
		if (*(c_p_scpi_comm_resp + i) == 0)
		{
			break;
		}
		else
		{
			str_resp = str_resp + *(c_p_scpi_comm_resp + i);
		}
	}

	c_p_resp = str_resp.c_str();


	
	int ret;

	ret = strtol(c_p_resp, NULL, 16);

	//delete []c_p_resp;

	return ret;

}

int EPS_Dev::ReadFromPipeOut(int adrs, int length, int *data)
{
	int adrs_tmp;
	int length_tmp;
	int *data_arry_tmp;



	sprintf(c_p_cmd_str, "%s#H%02X  %06d\n", cmd_str_EPS_PO, adrs, length);

	printf("readfrompipeout command : %s\n", c_p_cmd_str);

	
	int data_cnt;

	data_cnt = scpi_comm_resp_numb(c_p_cmd_str, data, length);

	//printf("readfrompipeout response : %s\n", resp);



	return 0;


}


int EPS_Dev::scpi_comm_resp_numb(char cmd_str[], int *data,  int length)
{


	int length_tmp;

	length_tmp = length + 11;		// data length + header


	send(hSocket, c_p_cmd_str, strlen(c_p_cmd_str), 0);




	int cnt;
	int ret_recv_val;

	
	int recv_cnt, data_cnt, buf_idx;



	

	int i;

	int data_idx;

	int total_cnt, head_cnt;

	int tmp_val;
	unsigned char* p_tmp_val;
	p_tmp_val = (unsigned char *) &tmp_val;

	data_idx = 0;
	total_cnt = 0;
	head_cnt = 0;
	data_cnt = 0;



	/*char ret_head_buf[10];

	head_cnt = recv(hSocket, ret_head_buf, 10, 0);*/


	int err_cnt;
	err_cnt = 0;

	int test_cnt;

	while(1)
	{
		data_cnt = recv(hSocket, adc_raw_data_rcv_buf + total_cnt, 524288 + 1 + 10, 0);

		sleep(10);

		if(data_cnt >= 0)
		{
			total_cnt = total_cnt + data_cnt;
		}
		else
		{
			err_cnt = err_cnt + data_cnt;
		}

		if(total_cnt - 1 == length + 10)
		{
			break;
		}
		/*else if((*(adc_raw_data_rcv_buf) + total_cnt) == NULL)			//binary data�� NULL�� �߰��� ����.
		{
			break;
		}*/
		//if (data_cnt == (-1)
		//{
			//set_cmu_adc_with_update();



		//}
		//if (data_cnt == -1)
		//{
		//	break;
		//}
	}

	int brk;

	if(err_cnt != 0)
	{
		brk = 0;

	}




	for (i = 10; i < length + 10; i = i + 4)
	{
	
		*(p_tmp_val+3) = (0xFF&adc_raw_data_rcv_buf[i+3]);
		*(p_tmp_val+2) = (0xFF&adc_raw_data_rcv_buf[i+2]);
		*(p_tmp_val+1) = (0xFF&adc_raw_data_rcv_buf[i+1]);
		*(p_tmp_val+0) = (0xFF&adc_raw_data_rcv_buf[i]);

		tmp_val = tmp_val >> 14;

		data[((i-10)/4)] = tmp_val;

		
	}

//	memset(adc_raw_data_rcv_buf, 0, total_cnt);


	//int *tmp_data;

	//tmp_data = new int [total_cnt];

	//tmp_data = data;

	int j;

	for (j = 0; j < 4; j++)
	{
		printf("rcv_int_data = 0x%08x\n", data[j] & 0x3FFFF);
	}



	return 0;

}



void EPS_Dev::WriteToPipeIn(int adrs, int length, int *data)
{

	int adrs_tmp;
	int length_tmp;
	int *data_arry_tmp;

	//unsigned char *data_str;

	//data_str = new unsigned char [3000];

	char nline[] = "\n";

	sprintf(c_p_cmd_str_flt32_to_fpga, "%s#H%02X #4_%06d_\0", cmd_str_EPS_PI, adrs, length*4);

	int chk_val;

	chk_val = strlen(c_p_cmd_str_flt32_to_fpga);

	memcpy(c_p_cmd_str_flt32_to_fpga + 22, data, length*4);

	memcpy(c_p_cmd_str_flt32_to_fpga + 22 + length*4, nline, 1);

	int i;

	/*for (i = 0; i < length; i++)
	{
		sprintf(c_p_cmd_str_flt32_to_fpga, "%s%08x", c_p_cmd_str_flt32_to_fpga, *(data + i));
		if(i == (length -1))
		{
			sprintf(c_p_cmd_str_flt32_to_fpga, "%s\n", c_p_cmd_str_flt32_to_fpga);
		}
	}*/

	//printf("readfrompipeout command : %s\n", c_p_cmd_str);

	
	int data_cnt;

	//data_cnt = scpi_comm_resp(c_p_cmd_str_flt32_to_fpga, c_p_scpi_comm_resp, length);

	data_cnt = scpi_comm_resp_for_pipe_in(c_p_cmd_str_flt32_to_fpga, c_p_scpi_comm_resp, length);

	//printf("readfrompipeout response : %s\n", resp);



	//return 0;



	//return 0;
}


void EPS_Dev::UpdateWireIns()
{

}


void EPS_Dev::UpdateWireOuts()
{

}

void EPS_Dev::GetSerialNumber(char *serial_number)
{		


	sprintf(c_p_cmd_str, "%s\n", cmd_str_IDN);

	int data_cnt;

	data_cnt = (scpi_comm_resp(c_p_cmd_str, serial_number, BUF_SIZE_RESP_CHK));

	serial_number[data_cnt] = 0;


}







/////////////////////////////

void EPS_Dev::cmu_spo_enable()
{


	unsigned long input_val;

	int ep07_addrstart_tmp;
	int ep07_numbyte_tmp;
	int ep07wire_addr_num;

	/*ep07_addrstart_tmp = ep07_addrstart;
	ep07_numbyte_tmp   = ep07_numbyte;*/

	ep07_addrstart_tmp = 0;
	ep07_numbyte_tmp   = 7;

	ep07wire_addr_num = ((ep07_numbyte_tmp << 8) | (ep07_addrstart_tmp << 4));

	input_val = ep07wire_addr_num | 0x00000001;

	printf("cmu_spo_enable..\n");

	//SetWireInValue_test(c_p_cmd_str, 0x07, 0x00000000, 0x00000001);
	//SetWireInValue(0x07, 0x00000000, 0x00000001);
	SetWireInValue(0x07, 0x00000000, 0x00000001);
	UpdateWireIns();

	SetWireInValue(0x07, input_val, 0x00000001);
	UpdateWireIns();


	UpdateWireOuts();
	int flag;
	flag = GetWireOutValue(0x27);


}
void EPS_Dev::cmu_spo_init()
{


	unsigned long input_val;

	int init_done, cnt_done, flag;
	int MAX_CNT;

	MAX_CNT = __MAX_CNT;

	int ep07_addrstart_tmp;
	int ep07_numbyte_tmp;
	int ep07wire_addr_num;

	/*ep07_addrstart_tmp = ep07_addrstart;
	ep07_numbyte_tmp   = ep07_numbyte;*/

	ep07_addrstart_tmp = 0;
	ep07_numbyte_tmp   = 7;

	ep07wire_addr_num = ((ep07_numbyte_tmp << 8) | (ep07_addrstart_tmp << 4));

	printf("cmu_spo_init..\n");

	input_val = ep07wire_addr_num | 0x00000002;

	SetWireInValue(SPO_CON, input_val, 0x00000002);

	GetWireOutValue(0x27);

	input_val = ep07wire_addr_num | 0x00000000;


	SetWireInValue(SPO_CON, input_val, 0x00000002);



	cnt_done = 0;//$$
	while(1)
	{

		flag = GetWireOutValue(0x27);
		init_done = (flag & 0x00000002)>>1;

		if (init_done == 1)
		{
			break;
		}

		cnt_done += 1;

		if (cnt_done>=MAX_CNT)
		{
			break;
		}


	}


}

void EPS_Dev::cmu_spo_update()
{



	int flag, update_done;



	unsigned long mon_wo22_val_comp;

	unsigned long input_val;

	int ep07_addrstart_tmp;
	int ep07_numbyte_tmp;
	int ep07wire_addr_num;

	/*ep07_addrstart_tmp = ep07_addrstart;
	ep07_numbyte_tmp   = ep07_numbyte;*/

	ep07_addrstart_tmp = 0;
	ep07_numbyte_tmp   = 7;

	ep07wire_addr_num = ((ep07_numbyte_tmp << 8) | (ep07_addrstart_tmp << 4));


	printf("cmu_spo_update..\n");


	// set bit
	SetWireInValue(SPO_CON, 0x00000004, 0x00000004);		// (ep, val, mask)

	// reset bit
	SetWireInValue(SPO_CON, 0x00000000, 0x00000004);		// (ep, val, mask)


	// check update_done flag

	int cnt_done, MAX_CNT;

	cnt_done = 0;
	MAX_CNT = __MAX_CNT;


	while(1)
	{

		flag = GetWireOutValue(SPO_FLAG);

		update_done = (flag&0x00000004)>>2;

		if (update_done == 1)
		{
			break;
		}

		cnt_done += 1;

		if (cnt_done>=MAX_CNT)
		{
			break;
		}
	}

	input_val;

	input_val = ep07wire_addr_num | 0x00000001;

	//dev->UpdateWireIns();
	SetWireInValue(0x07, input_val);

	int resp;

	resp = GetWireOutValue(0x27);







}


void EPS_Dev::cmu_spo_bit_amp_pwr()
{

	printf("cmu_spo_bit_amp_pwr..\n");

	
	int opt, opt_tmp;

	// opt = 0x01 // AMP power
	// opt = 0x02 // ADC power
	// opt = 0x03 // both power

	opt = 1;

	if (opt == 1)
	{
		opt_tmp = 3;
	}
	else
	{
		opt_tmp = 0;
	}

	

	unsigned long mask;

	mask = 0x0003;

	cmu_spo_set_buffer(SPO_DIN_B3_L, opt_tmp, mask);
	cmu_spo_update();


}

void EPS_Dev::cmu_spo_set_buffer(int adrs, int val, unsigned int mask)
{


	SetWireInValue(adrs, val, mask);

}



void EPS_Dev::cmu_adc_enable()
{

	int wi, wo;

	wi = 0x18;
	wo = 0x38;

	printf("cmu_adc_enable..\n");

	SetWireInValue(wi, 0x00000001, 0x00000001);

	int ret;

	printf("cmu_adc_enable..getwire..\n");

	ret = GetWireOutValue(wo);




}

void EPS_Dev::cmu_adc_reset()
{

	int ti, wo;

	ti = 0x58;
	wo = 0x38;

	printf("cmu_adc_reset..\n");

	ActivateTriggerIn(ti, 0);

	int ret;

	ret = GetWireOutValue(wo);





}


void EPS_Dev::cmu_adc_init()
{

	int wi, ti, wo;
	int cnt_done, MAX_CNT;
	int flag;
	int init_done;

	wi = ADC_HS_WI;
	ti = ADC_HS_TI;
	wo = ADC_HS_WO;

	printf("cmu_adc_init..\n");

	ActivateTriggerIn(ti, 1);		// ep, bit

	//sleep(1000);


	cnt_done = 0;
	MAX_CNT = __MAX_CNT;

	while(1)
	{
		flag = GetWireOutValue(wo);
		init_done = (flag&0x00000002)>>1;

		if (init_done == 1)
		{
			break;
		}
		cnt_done += 1;

		if (cnt_done>=MAX_CNT)
		{
			break;
		}

	}




}


void EPS_Dev::cmu_adc_set_para()
{


	printf("adc_set_para..\n");


	double adc_base_freq_tmp, fs_target_tmp;
	int adc_num_samples_tmp, adc_input_delay_tap_tmp, pin_test_frc_high_tmp, pin_dlln_frc_low_tmp, pttn_cnt_up_en_tmp;
	double adc_cnt_sample_period_float;
	int adc_cnt_sample_period;
	unsigned int adc_input_delay_tap_code, adc_control_code;

	/*adc_base_freq_tmp = 210000000;
	fs_target_tmp = 15000000;
	adc_num_samples_tmp = 131072;
	adc_input_delay_tap_tmp = 15;
	pin_test_frc_high_tmp = 0;
	pin_dlln_frc_low_tmp = 0;
	pttn_cnt_up_en_tmp = 0;*/

	adc_base_freq_tmp = 210000000;
	fs_target_tmp = 210000000.0/211.0;
	adc_num_samples_tmp = 31710;
	adc_input_delay_tap_tmp = 10;		// 0~31 variance, 
	pin_test_frc_high_tmp = 0;
	pin_dlln_frc_low_tmp = 0;
	pttn_cnt_up_en_tmp = 0;

	




	adc_cnt_sample_period_float = (adc_base_freq_tmp) / (fs_target_tmp);
	adc_cnt_sample_period = (int) (adc_cnt_sample_period_float + 0.5);


	double Fs;

	Fs = (adc_base_freq_tmp) / ((double) adc_cnt_sample_period);

	double Fs_tmp;

	Fs_tmp = Fs;

	SetWireInValue(ADC_HS_SMP_PRD, adc_cnt_sample_period, 0xFFFFFFFF);

	SetWireInValue(ADC_HS_UPD_SMP, adc_num_samples_tmp, 0xFFFFFFFF);



	//adc_input_delay_tap_code = (adc_input_delay_tap_1_a << 27) | (adc_input_delay_tap_1_b << 22) | (adc_input_delay_tap_2_a << 17) | (adc_input_delay_tap_2_b << 12); //20201217
	adc_input_delay_tap_code = (adc_input_delay_tap_tmp << 27) | (adc_input_delay_tap_tmp << 22);
	//adc_input_delay_tap_code = (adc_input_delay_tap_tmp << 27) | (adc_input_delay_tap_tmp << 22) | (adc_input_delay_tap_tmp << 17) | (adc_input_delay_tap_tmp << 12); //20201211

	//ADC_INPUT_DELAY_TAP_code = (ADC_INPUT_DELAY_TAP<<27)|(ADC_INPUT_DELAY_TAP<<22)|(ADC_INPUT_DELAY_TAP<<17)|(ADC_INPUT_DELAY_TAP<<12)


	//SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_input_delay_tap_code, 0xFFC00000);		// ep val mask

	SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_input_delay_tap_code, 0xFFFFF000);		// ep val mask		//20201211



	adc_control_code = (pttn_cnt_up_en_tmp << 2) | (pin_dlln_frc_low_tmp << 1) | pin_test_frc_high_tmp;

	SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_control_code, 0x00000007);		// ep val mask






}

//void EPS_Dev::cmu_adc_set_para_tune(int tap_1a, int tap_1b, int tap_2a, int tap_2b)
//{
//
//
//	printf("adc_set_para..\n");
//
//
//	double adc_base_freq_tmp, fs_target_tmp;
//	int adc_num_samples_tmp, adc_input_delay_tap_tmp, pin_test_frc_high_tmp, pin_dlln_frc_low_tmp, pttn_cnt_up_en_tmp;
//	double adc_cnt_sample_period_float;
//	int adc_cnt_sample_period;
//	unsigned int adc_input_delay_tap_code, adc_control_code;
//
//	/*adc_base_freq_tmp = 210000000;
//	fs_target_tmp = 15000000;
//	adc_num_samples_tmp = 131072;
//	adc_input_delay_tap_tmp = 15;
//	pin_test_frc_high_tmp = 0;
//	pin_dlln_frc_low_tmp = 0;
//	pttn_cnt_up_en_tmp = 0;*/
//
//	adc_base_freq_tmp = 210000000;
//	fs_target_tmp = 210000000.0/211.0;
//	adc_num_samples_tmp = 31710;
//	//adc_input_delay_tap_tmp = 10;		// 0~31 variance, 
//	pin_test_frc_high_tmp = 0;
//	pin_dlln_frc_low_tmp = 0;
//	pttn_cnt_up_en_tmp = 0;
//
//	//adc_input_delay_tap_1_a
//	//adc_input_delay_tap_1_b
//	//adc_input_delay_tap_2_a
//	//adc_input_delay_tap_2_b
//
//
//
//
//
//
//	adc_cnt_sample_period_float = (adc_base_freq_tmp) / (fs_target_tmp);
//	adc_cnt_sample_period = (int) (adc_cnt_sample_period_float + 0.5);
//
//
//	double Fs;
//
//	Fs = (adc_base_freq_tmp) / ((double) adc_cnt_sample_period);
//
//	double Fs_tmp;
//
//	Fs_tmp = Fs;
//
//	SetWireInValue(ADC_HS_SMP_PRD, adc_cnt_sample_period, 0xFFFFFFFF);
//
//	SetWireInValue(ADC_HS_UPD_SMP, adc_num_samples_tmp, 0xFFFFFFFF);
//
//
//
//	//adc_input_delay_tap_code = (adc_input_delay_tap_1_a << 27) | (adc_input_delay_tap_1_b << 22) | (adc_input_delay_tap_2_a << 17) | (adc_input_delay_tap_2_b << 12); //20201217
//	adc_input_delay_tap_code = (adc_input_delay_tap_tmp << 27) | (adc_input_delay_tap_tmp << 22);
//	//adc_input_delay_tap_code = (adc_input_delay_tap_tmp << 27) | (adc_input_delay_tap_tmp << 22) | (adc_input_delay_tap_tmp << 17) | (adc_input_delay_tap_tmp << 12); //20201211
//
//	//ADC_INPUT_DELAY_TAP_code = (ADC_INPUT_DELAY_TAP<<27)|(ADC_INPUT_DELAY_TAP<<22)|(ADC_INPUT_DELAY_TAP<<17)|(ADC_INPUT_DELAY_TAP<<12)
//
//
//	//SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_input_delay_tap_code, 0xFFC00000);		// ep val mask
//
//	SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_input_delay_tap_code, 0xFFFFF000);		// ep val mask		//20201211
//
//
//
//	adc_control_code = (pttn_cnt_up_en_tmp << 2) | (pin_dlln_frc_low_tmp << 1) | pin_test_frc_high_tmp;
//
//	SetWireInValue(ADC_HS_DLY_TAP_OPT, adc_control_code, 0x00000007);		// ep val mask
//
//
//
//
//
//
//}

//void EPS_Dev::cmu_adc_update()
//{
//	
//	int wi, ti, wo, to;
//	int cnt_done, MAX_CNT;
//	int update_done;
//	int flag;
//
//	wi = ADC_HS_WI;
//	ti = ADC_HS_TI;
//	wo = ADC_HS_WO;
//	to = ADC_HS_TO;
//
//	while(1)
//	{
//		flag = GetWireOutValue(wo);
//		update_done = (flag&0x00000004)>>2;
//
//		if (update_done==1)
//		{
//			break;
//		}
//
//		cnt_done += 1;
//
//
//	}
//
//
//
//
//	ActivateTriggerIn(ti, 2);		// ep, bit
//
//	cnt_done = 0;
//	MAX_CNT = __MAX_CNT;
//
//	while(1)
//	{
//		flag = GetWireOutValue(wo);
//		update_done = (flag&0x00000004)>>2;
//
//		if (update_done==1)
//		{
//			break;
//		}
//
//		cnt_done += 1;
//
//		if (cnt_done>=MAX_CNT)
//		{
//
//		break;
//		}
//
//	}
//}


void EPS_Dev::cmu_adc_is_fifo_empty()
{

	int wi, ti, wo, to, po_d0, po_d1;
	int data_count0, data_count1;
	int flag;
	//int fifo_adc0_empty, fifo_adc1_empty;

	wi = ADC_HS_WI;
	ti = ADC_HS_TI;
	wo = ADC_HS_WO;
	to = ADC_HS_TO;


	printf("cmu_adc_fifo_empty..\n");


	flag = GetWireOutValue(wo);

	fifo_adc0_empty = (flag&(0x00000001<<9 ))>>9;
	fifo_adc1_empty = (flag&(0x00000001<<15))>>15;

	int i;

	i = 0;

	printf("fifo is empty?\n");
	printf("fifo_adc_0 empty = %d\n", fifo_adc0_empty);
	printf("fifo_adc_1 empty = %d\n", fifo_adc1_empty);

}


int EPS_Dev::cmu_dwave_enable()
{


	printf("cmu_dwave_enable..\n");

	int flag;

	SetWireInValue(DWAVE_CON, 0x00000001, 0x00000001);		//(ep, val, mask)

	flag = GetWireOutValue(DWAVE_FLAG);



	return flag;


}

int EPS_Dev::cmu_dwave_disable()
{

	printf("cmu_dwave_disable..\n");

	int flag;

	SetWireInValue(DWAVE_CON, 0x00000000, 0x00000001);

	flag = GetWireOutValue(DWAVE_FLAG);



	return flag;

}

int EPS_Dev::cmu_dwave_init()
{


	printf("cmu_dwave_init..\n");

	int flag;

	SetWireInValue(DWAVE_CON, 0x00000002, 0x00000002);		//(ep, val, mask)

	SetWireInValue(DWAVE_CON, 0x00000000, 0x00000002);		//(ep, val, mask)


	flag = GetWireOutValue(DWAVE_FLAG);



	return flag;


}

int EPS_Dev::cmu_dwave_update()
{

	printf("cmu_dwave_update..\n");

	int flag;

	SetWireInValue(DWAVE_CON, 0x00000004, 0x00000004);		//(ep, val, mask)

	SetWireInValue(DWAVE_CON, 0x00000000, 0x00000004);		//(ep, val, mask)

	flag = GetWireOutValue(DWAVE_FLAG);

	return flag;


}


void EPS_Dev::set_cmu_dwave(unsigned int frequency)
{



	unsigned long input_val;


	unsigned int test_signal_period, test_signal_freq, test_signal_diff_period;

	float test_signal_diff_period_tmp;

	test_signal_freq = frequency;

	//current_freq = test_signal_freq;

	test_signal_period = 160000000 / test_signal_freq;



	test_signal_diff_period_tmp =  0.75 * float(test_signal_period);


	float tmp_val;






	if ((test_signal_diff_period_tmp - (int)test_signal_diff_period_tmp) >= 0.5)
	{
		test_signal_diff_period = (int)test_signal_diff_period_tmp + 1;
	}
	else
	{
		test_signal_diff_period = test_signal_diff_period_tmp;
	}

	tmp_val = test_signal_diff_period;

	cmu_dwave_pulse_off();

	sleep(50);


	cmu_dwave_write_cnt_period(test_signal_period);

	int tmpval;

	cmu_dwave_read_cnt_period();

	cmu_dwave_write_cnt_diff(test_signal_diff_period);

	cmu_dwave_read_cnt_diff();

	cmu_dwave_set_para();



}

void EPS_Dev::cmu_dwave_read_cnt_period()
{
	int tmp;

	cmu_dwave_read_trig(24);



}

void EPS_Dev::cmu_dwave_write_cnt_diff(int val)
{
	cmu_dwave_write_trig(17, val);

}

void EPS_Dev::cmu_dwave_set_para()
{
	cmu_dwave_write_trig(3, 0);
}

void EPS_Dev::cmu_dwave_write_trig(int bit_loc, int val)
{

	int ret;	//debugging
	int tmp;  
	int bit_loc_tmp;

	int val_tmp;

	val_tmp = val;

	bit_loc_tmp = bit_loc;

	SetWireInValue(DWAVE_DIN_BY_TRIG, val_tmp, 0xFFFFFFFF);		// (ep, val, mask)

	//trig

	ActivateTriggerIn(DWAVE_TI, bit_loc_tmp);		// (ep, bit)


}
void EPS_Dev::cmu_dwave_read_trig(int bit_loc)
{
	int ret;	//debugging
	int tmp;

	int bit_loc_tmp;

	bit_loc_tmp = bit_loc;

	//trig
	ActivateTriggerIn(DWAVE_TI, bit_loc_tmp);		// (ep, bit)


	ret = GetWireOutValue(DWAVE_DOUT_BY_TRIG);



}

void EPS_Dev::cmu_dwave_write_cnt_period(int val)
{
	int val_tmp;

	val_tmp = val;

	cmu_dwave_write_trig(16, val_tmp);

}

void EPS_Dev::cmu_dwave_pulse_on()
{
	cmu_dwave_write_trig( 1, 0);
}

void EPS_Dev::cmu_dwave_pulse_off()
{
	cmu_dwave_write_trig( 0, 0);
}

void EPS_Dev::cmu_dwave_read_cnt_diff()
{
	int tmp;

	cmu_dwave_read_trig(25);


}


void EPS_Dev::cmu_adc_load_from_fifo(int adc_num_samples)
{



	int wi, ti, wo, po_d0, po_d1;
	int data_count0, data_count1;

	wi = ADC_HS_WI;
	ti = ADC_HS_TI;
	wo = ADC_HS_WO;

	po_d0 = ADC_HS_DOUT0_PO;
	po_d1 = ADC_HS_DOUT1_PO;


	data_count0 = ReadFromPipeOut(po_d0, adc_num_samples*4, adc_raw_dataout_i0);
	data_count1 = ReadFromPipeOut(po_d1, adc_num_samples*4, adc_raw_dataout_i1);
	
	

	//sleep(100);

	


	//data_count0 = ReadFromPipeOut2(po_d0, adc_num_samples*4, adc_raw_dataout0);
	//data_count1 = ReadFromPipeOut2(po_d1, adc_num_samples*4, adc_raw_dataout1);





	//adc_raw_data0 = (int *) adc_raw_dataout0;
	//adc_raw_data1 = (int *) adc_raw_dataout1;




	int i;

	for(i = 0; i < 4; i++)
	{
		printf("adc_raw_data_out_ui0 = %d\t adc_raw_data_out_ui1 = %d\n", adc_raw_dataout_i0[i], adc_raw_dataout_i1[i]);
	}

	
	int m;

	m = 0;


	//
}

void EPS_Dev::sleep(unsigned long time_ms)
{
	//$$ _sleep(time); //$$ for windows ms time

	//$$ review _sleep
	int CLOCKS_PER_MS = CLOCKS_PER_SEC/1000;
	clock_t start_clk = clock();
	clock_t final_clk = start_clk + time_ms*CLOCKS_PER_MS;
	
	while (true) {
		//if ((clock() - start_clk)/CLOCKS_PER_MS > time_ms) break;
		if (clock() >= final_clk) break;
	}
	
	
}


void EPS_Dev::cmu_adc_update()
{

	int wi, ti, wo, to;
	int cnt_done, MAX_CNT;
	int update_done;
	int flag;

	wi = ADC_HS_WI;
	ti = ADC_HS_TI;
	wo = ADC_HS_WO;
	to = ADC_HS_TO;

	//while(1)
	//{
	//	
	//	flag = GetWireOutValue(wo);
	//	update_done = (flag&0x00000004)>>2;

	//	if (update_done==1)
	//	{
	//		break;
	//	}

	//	cnt_done += 1;


	//}




	ActivateTriggerIn(ti, 2);		// ep, bit

	cnt_done = 0;
	MAX_CNT = __MAX_CNT;

	while(1)
	{
		flag = GetWireOutValue(wo);
		update_done = (flag&0x00000004)>>2;

		if (update_done==1)
		{
			break;
		}

		cnt_done += 1;

		/*if (cnt_done>=MAX_CNT)
		{

		break;
		}*/

	}

}

void EPS_Dev::cmu_check_adc_test_pattern()
{


	int wi, ti, wo, to, po_d0, po_d1;
	int data_count0, data_count1;
	int cnt_done, MAX_CNT;
	int update_done;
	int flag;

	wi = ADC_HS_WI;
	ti = ADC_HS_TI;
	wo = ADC_HS_WO;


	po_d0 = ADC_HS_DOUT0_PO;
	po_d1 = ADC_HS_DOUT1_PO;



	int adc_num_samples;

	adc_num_samples = 4;

	printf("cmu_check_adc_test_pattern..\n");



	data_count0 = ReadFromPipeOut(po_d0, adc_num_samples*4, adc_raw_dataout_i0);
	sleep(100);
	data_count1 = ReadFromPipeOut(po_d1, adc_num_samples*4, adc_raw_dataout_i1);

	//adc_raw_data0 = (int *) adc_raw_dataout0;
	//adc_raw_data1 = (int *) adc_raw_dataout1;


	int i;

	for(i = 0; i < 4; i++)
	{
		printf("adc_raw_data_out_ui0 = 0x%08x\t adc_raw_data_out_ui1 = 0x%08x\n", adc_raw_dataout_i0[i], adc_raw_dataout_i1[i]);
	}

	for(i = 0; i < 4; i++)
	{
		printf("adc_raw_data_out_ui0 = %d\t adc_raw_data_out_ui1 = %d\n", adc_raw_dataout_i0[i], adc_raw_dataout_i1[i]);
	}

	i = 0;




}


void EPS_Dev::cmu_write_raw_data(int adc_num_samples)
{

	// time.h ���ǳ���
	//struct tm {
	//			int tm_sec;   /* Seconds */
	//			int tm_min;   /* Minutes */
	//			int tm_hour;  /* Hour (0--23) */
	//			int tm_mday;  /* Day of month (1--31) */
	//			int tm_mon;   /* Month (0--11) */
	//			int tm_year;  /* Year (calendar year minus 1900) */
	//			int tm_wday;  /* Weekday (0--6; Sunday = 0) */
	//			int tm_yday;  /* Day of year (0--365) */
	//			int tm_isdst; /* 0 if daylight savings time is not in effect) */
	//};
	//UINT16 i;


	//char *log_path;
	char *filename;
	char *strtmp;
	char *databuf;
	char *test;

	const char *log_folder_tmp;
	const char *filename_tmp;
	//	const char *save_file;

	string str_save_file_tmp;
	int i, j, k;

	int dc_bias_inc_log_var;
	int bias_inc_cnt_log;

	float test_val;

	/*typedef union
	{
	char ch_dc_bias_tmp[4];
	float f_dc_bias_tmp;
	} file_name_maker;

	file_name_maker fnm;*/


	//log_path = new char[64];
	filename = new char[128];






	//log_path = str_tmp;

	//strcpy(log_path, log_folder_tmp);


	time_t timer;
	struct tm *t;

	timer = time(NULL);

	t = localtime(&timer);

	char str_tmp1[32];
	char str_tmp2[32];
	char str_tmp3[32];
	string string_time, string_hour, string_min, string_sec;

	itoa((t->tm_hour),str_tmp1,10);
	itoa((t->tm_min),str_tmp2,10);
	itoa((t->tm_sec),str_tmp3,10);

	for (i = 0; i<32; i++)
	{
		if (str_tmp1[i] == NULL)
		{
			break;
		}

		string_hour = string_hour + str_tmp1[i];
	}

	for (i = 0; i<32; i++)
	{
		if (str_tmp2[i] == NULL)
		{
			if (atoi(str_tmp2) < 10)
			{
				string_min = "0" + string_min;
			}
			break;
		}

		string_min = string_min + str_tmp2[i];
	}


	for (i = 0; i<32; i++)
	{
		if (str_tmp3[i] == NULL)
		{
			if (atoi(str_tmp3) < 10)
			{
				string_sec = "0" + string_sec;

			}
			break;

		}

		string_sec = string_sec + str_tmp3[i];
	}



	string_time = string_hour + string_min + string_sec;

	int fs_idx, dc_idx;

	string str_dc_bias_for_log;




	char str_tmp_repeat_cnt[32];
	string str_repeat_cnt;
	str_repeat_cnt = "";










	str_save_file_tmp = "D:\\Analog_cmu_log\\test" +  string_time + ".csv";

	filename_tmp = str_save_file_tmp.c_str();

	strcpy(filename, filename_tmp);

	//FILE*fp2 = fopen(filename, "w");
	FILE*fp = fopen(filename, "w");

	fprintf(fp, "//frequency,Vx_RAW,VR_RAW\r");
	fprintf(fp, "//10416666,131072\r");
	fprintf(fp, "//frequency,Vx_RAW,VR_RAW\r");

	//fprintf(fp, "frequency,Vx_RAW,VR_RAW\r");

	int analog_adc_num_samples;
	analog_adc_num_samples = adc_num_samples;

	for (i = 0; i < analog_adc_num_samples; i++)
	{
		fprintf(fp, "%d,%d\r", adc_raw_dataout_i0[i], adc_raw_dataout_i1[i]);
	}


	fclose(fp);

	delete []filename;


}

void EPS_Dev::UpdateTriggerOuts()
{

}


int EPS_Dev::Test(int &test_array)
{

	///*int *a;

	//a = new int [10];

	//int i;

	//for(i = 0; i<10; i++)
	//{
	//	*(a + i) = i;
	//}*/

	//int a[10];

	//int i;

	//for(i = 0; i<10; i++)
	//{
	//	a[i] = i;
	//}

	//&test_array = &a[0];

	//return test_array;

	return 0;

}

int EPS_Dev::_test()
{
	printf(">>> test class EPS_Dev \n");

	
	printf("> test sleep(1000) \n");
	sleep(1000); //ms
	printf("> test sleep(1000) \n");
	sleep(1000); //ms

	return 0;
}