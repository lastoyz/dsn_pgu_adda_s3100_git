## cmu_cpu__lib.py : LAN function library for PGU-CPU-TEST-F5500 

# convert cmu_cpu__lib.py --> pgu_cpu__lib.py

####
## library call
##$$import ok ## remove
##import eps

#
from sys import exit
#
import time
#
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
#
import tkinter as tk
from tkinter import filedialog
import os
#
import datetime
#
import csv
#
####

####
## import configuration 
#  
#  load EP_ADRS_CONFIG
import pgu_cpu__lib_conf as conf
#  
####

####
## TODO: (0) test or common
#
def sleep(val):
	return time.sleep(val)
#



####
## TODO: (6) test counter
#
#assign reset1     = w_TEST_CON[0];
#assign disable1   = w_TEST_CON[1];
#assign autocount2 = w_TEST_CON[2];
#assign reset2     = w_TEST_TI[0];
#assign up2        = w_TEST_TI[1];
#assign down2      = w_TEST_TI[2];
#assign w_TEST_OUT = {16'b0, count2[7:0], count1[7:0]}; // TEST_OUT
#assign w_TEST_TO   = {15'b0, count2eqFF, 14'b0, count1eq80, count1eq00};
#
#  https://www.opalkelly.com/examples/counting
#
def test_counter(dev, EP_ADRS, opt='OFF'): ##$$
	#
	if not opt:
		opt = 'OFF'
	#
	print('\n>> {}'.format('Test counter'))
	#
	# clear reset1
	dev.SetWireInValue(EP_ADRS['TEST_CON'],0x00,0x01) # (ep,val,mask)
	# clear disable1
	dev.SetWireInValue(EP_ADRS['TEST_CON'],0x00,0x02) # (ep,val,mask)
	#
	if opt.upper()=='ON':
		# set autocount2
		dev.SetWireInValue(EP_ADRS['TEST_CON'],0x04,0x04) # (ep,val,mask)
	elif opt.upper()=='OFF':
		# clear autocount2
		dev.SetWireInValue(EP_ADRS['TEST_CON'],0x00,0x04) # (ep,val,mask)
	else:
		pass
	#
	dev.UpdateWireIns()
	#
	#
	if opt.upper()=='RESET':
		# set reset2 // reset counter #2
		dev.ActivateTriggerIn(EP_ADRS['TEST_TI'], 0) # (ep,bit)
	else:
		pass
	#
	# read counters 
	dev.UpdateWireOuts()
	test_out = dev.GetWireOutValue(EP_ADRS['TEST_OUT'])
	count1 = test_out & 0xFF
	count2 = (test_out>>8) & 0xFF
	#
	return [count1, count2]
#
####




####
## TODO: (11) EEPROM
#  
#  // w_MEM_WI   
#  assign w_num_bytes_DAT               = w_MEM_WI[11:0]; // 12-bit 
#  assign w_con_disable_SBP             = w_MEM_WI[15]; // 1-bit
#  assign w_con_fifo_path__L_sspi_H_lan = w_MEM_WI[16]; // 1-bit
#  assign w_con_port__L_MEM_SIO__H_TP   = w_MEM_WI[17]; // 1-bit
#  
#  // w_MEM_FDAT_WI
#  assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
#  assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
#  assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
#  assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit
#  
#  // w_MEM_TI
#  assign w_MEM_rst      = w_MEM_TI[0];
#  assign w_MEM_fifo_rst = w_MEM_TI[1];
#  assign w_trig_frame   = w_MEM_TI[2];
#  
#  // w_MEM_TO
#  assign w_MEM_TO[0]     = w_MEM_valid    ;
#  assign w_MEM_TO[1]     = w_done_frame   ;
#  assign w_MEM_TO[2]     = w_done_frame_TO; //$$ rev
#  assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
#  
#  // w_MEM_PI
#  assign w_frame_data_DAT_wr    = w_MEM_PI[7:0]; // 8-bit
#  assign w_frame_data_DAT_wr_en = w_MEM_PI_wr;
#  
#  // w_MEM_PO
#  assign w_MEM_PO[7:0]          = w_frame_data_DAT_rd; // 8-bit
#  assign w_MEM_PO[31:8]         = 24'b0; // unused
#  assign w_frame_data_DAT_rd_en = w_MEM_PO_rd;
#  
#

##  // global variables for eeprom
##  static u8 g_EEPROM__LAN_access = 1;
g_EEPROM__LAN_access = 1 # 0 or 1
##  static u8 g_EEPROM__on_TP      = 1;
g_EEPROM__on_TP      = 1 # 0 or 1

##  static u8 g_EEPROM__buf_2KB[2048];
g_EEPROM__buf_2KB = [0x00]*2048 # list

def eeprom_send_frame_ep (dev, EP_ADRS,  MEM_WI, MEM_FDAT_WI, MAX_CNT = 50):
	## //// end-point map :
	## // wire [31:0] w_MEM_WI      = ep13wire;
	## // wire [31:0] w_MEM_FDAT_WI = ep12wire;
	## // wire [31:0] w_MEM_TI = ep53trig; assign ep53ck = sys_clk;
	## // wire [31:0] w_MEM_TO; assign ep73trig = w_MEM_TO; assign ep73ck = sys_clk;
	## // wire [31:0] w_MEM_PI = ep93pipe; wire w_MEM_PI_wr = ep93wr; 
	## // wire [31:0] w_MEM_PO; assign epB3pipe = w_MEM_PO; wire w_MEM_PO_rd = epB3rd; 	

	## // assign w_num_bytes_DAT               = w_MEM_WI[11:0]; // 12-bit 
	## // assign w_con_disable_SBP             = w_MEM_WI[15]  ; // 1-bit
	## // 
	## // assign w_frame_data_CMD              = w_MEM_FDAT_WI[ 7: 0]; // 8-bit
	## // assign w_frame_data_STA_in           = w_MEM_FDAT_WI[15: 8]; // 8-bit
	## // assign w_frame_data_ADL              = w_MEM_FDAT_WI[23:16]; // 8-bit
	## // assign w_frame_data_ADH              = w_MEM_FDAT_WI[31:24]; // 8-bit
	## // 
	## // assign w_MEM_rst      = w_MEM_TI[0];
	## // assign w_MEM_fifo_rst = w_MEM_TI[1];
	## // assign w_trig_frame   = w_MEM_TI[2];
	## // 
	## // assign w_MEM_TO[0]     = w_MEM_valid    ;
	## // assign w_MEM_TO[1]     = w_done_frame   ;
	## // assign w_MEM_TO[2]     = w_done_frame_TO;
	## // assign w_MEM_TO[ 7: 3] =  5'b0;
	## // assign w_MEM_TO[15: 8] = w_frame_data_STA_out; 
	## // assign w_MEM_TO[31:16] = 16'b0;
	
	# EP address
	wi      = EP_ADRS['MEM_WI']
	wi_fdat = EP_ADRS['MEM_FDAT_WI']
	ti      = EP_ADRS['MEM_TI']
	to      = EP_ADRS['MEM_TO']
	#pi      = EP_ADRS['MEM_PI']
	#po      = EP_ADRS['MEM_PO']


	##$$ print('{} = 0x{:08X}'.format('MEM_WI', MEM_WI))
	dev.SetWireInValue(wi,MEM_WI,0xFFFFFFFF) # (ep,val,mask)
	#dev.UpdateWireIns()	
	
	##$$ print('{} = 0x{:08X}'.format('MEM_FDAT_WI', MEM_FDAT_WI))
	dev.SetWireInValue(wi_fdat,MEM_FDAT_WI,0xFFFFFFFF) # (ep,val,mask)
	dev.UpdateWireIns()	
	
	# clear TO 
	dev.UpdateTriggerOuts()
	ret=dev.GetTriggerOutVector(to)
	##$$ print('{} = 0x{:08X}'.format('ret', ret))


	# act TI 
	dev.ActivateTriggerIn(ti, 2)	## (ep, loc)
	
	# check frame done
	cnt_loop = 0;
	while 1:
		# First, query all XEM Trigger Outs.
		dev.UpdateTriggerOuts()
		# check trigger out //$$  0x01 w_MEM_TO[0]  or  0x04 w_MEM_TO[2] 
		if dev.IsTriggered(to, 0x04) == True: # // (ep, mask)
			break
		cnt_loop += 1;
		##$$ print('{} = {}'.format('cnt_loop', cnt_loop))
		if (cnt_loop>MAX_CNT):
			break
	##$$ print('{} = {}'.format('cnt_loop', cnt_loop))

	# # read again TO 
	# dev.UpdateTriggerOuts()
	# ret=dev.GetTriggerOutVector(to)
	# print('{} = 0x{:08X}'.format('ret', ret))

	#
	#return ret
	return None

##  u32  eeprom_set_g_var (u8 EEPROM__LAN_access, u8 EEPROM__on_TP);
def eeprom_set_g_var (dev, EP_ADRS, EEPROM__LAN_access_b8,  EEPROM__on_TP_b8):
	global g_EEPROM__LAN_access
	global g_EEPROM__on_TP
	#
	g_EEPROM__LAN_access = EEPROM__LAN_access_b8
	g_EEPROM__on_TP      = EEPROM__on_TP_b8

	## // update wire wi11 //$$ MCS_SETUP_WI wi11 --> wi19 in cmu
	## // bit [9] = w_con_port__L_MEM_SIO__H_TP    // set from MCS
	## // bit [8] = w_con_fifo_path__L_sspi_H_lan  // set from MCS
	
	## // wire [3:0]  w_slot_id             = w_MCS_SETUP_WI[3:0];
	## // wire w_sel__H_LAN_for_EEPROM_fifo = w_MCS_SETUP_WI[8];
	## // wire w_sel__H_EEPROM_on_TP        = w_MCS_SETUP_WI[9];
	## // wire w_sel__H_LAN_on_BASE_BD      = w_MCS_SETUP_WI[10];
	## // wire [15:0] w_board_id            = w_MCS_SETUP_WI[31:16];
	
	
	## ret = (g_EEPROM__LAN_access<<8) + (g_EEPROM__on_TP<<9);
	ret = (g_EEPROM__LAN_access<<8) + (g_EEPROM__on_TP<<9);
	
	## //write_mcs_ep_wi(MCS_EP_BASE, 0x11, ret, 0x00000300); // adrs_base, EP_offset, data, mask
	## write_mcs_ep_wi(MCS_EP_BASE, 0x19, ret, 0x00000300); // adrs_base, EP_offset, data, mask
	dev.SetWireInValue(EP_ADRS['MCS_SETUP_WI'], ret, 0x00000300) # (ep,val,mask)
	
	#
	return ret

##  u32  eeprom_send_frame (u8 CMD_b8, u8 STA_in_b8, u8 ADL_b8, u8 ADH_b8, u16 num_bytes_DAT_b16, u8 con_disable_SBP_b8);
def eeprom_send_frame(dev, EP_ADRS,  CMD_b8, STA_in_b8, ADL_b8, ADH_b8, num_bytes_DAT_b16, con_disable_SBP_b8):
	#xil_printf(">>>>>> eeprom_send_frame  \r\n");
	#u32 ret;
	#
	#u32 con_fifo_path__L_sspi_H_lan = g_EEPROM__LAN_access; // moved
	#u32 con_port__L_MEM_SIO__H_TP = g_EEPROM__on_TP; // moved
	#u32 set_data_WI = (con_port__L_MEM_SIO__H_TP<<17) + (con_fifo_path__L_sspi_H_lan<<16) + ((u32)con_disable_SBP_b8<<15) + ((u32)num_bytes_DAT_b16);
	set_data_WI = (con_disable_SBP_b8<<15) + (num_bytes_DAT_b16)
	#u32 set_data_FDAT_WI = ((u32)ADH_b8<<24) + ((u32)ADL_b8<<16) + ((u32)STA_in_b8<<8) + (u32)CMD_b8;
	set_data_FDAT_WI = (ADH_b8<<24) + (ADL_b8<<16) + (STA_in_b8<<8) + CMD_b8
	#ret = eeprom_send_frame_ep (set_data_WI, set_data_FDAT_WI);
	ret = eeprom_send_frame_ep (dev, EP_ADRS, set_data_WI, set_data_FDAT_WI)
	#return ret;	
	return ret

##  void eeprom_write_enable();
def eeprom_write_enable(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_write_enable  \r\n");
	#eeprom_send_frame (0x96, 0, 0, 0, 1, 1); // (CMD=0x96, con_disable_SBP=1)
	eeprom_send_frame (dev, EP_ADRS, 0x96, 0, 0, 0, 1, 1) ## // (CMD=0x96, con_disable_SBP=1)
	return

##  void eeprom_write_disable();
def eeprom_write_disable(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_write_disable  \r\n");
	#eeprom_send_frame (0x91, 0, 0, 0, 1, 0); // (CMD=0x91)
	eeprom_send_frame (dev, EP_ADRS, 0x91, 0, 0, 0, 1, 0) ## // (CMD=0x91)
	return

##  u32 eeprom_read_status();
def eeprom_read_status(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_read_status  \r\n");
	#u32 ret;
	#eeprom_send_frame (0x05, 0, 0, 0, 1, 0); 
	eeprom_send_frame (dev, EP_ADRS, 0x05, 0, 0, 0, 1, 0) 
	#ret = read_mcs_ep_to(MCS_EP_BASE, 0x73, 0xFFFFFFFF);
	#ret = read_mcs_ep_to(MCS_EP_BASE, 0x73, 0xFFFFFFFF);
	
	# read twice
	dev.UpdateTriggerOuts()
	ret=dev.GetTriggerOutVector(EP_ADRS['MEM_TO'])
	dev.UpdateTriggerOuts()
	ret=dev.GetTriggerOutVector(EP_ADRS['MEM_TO'])

	## //  	MUST_ZEROS = (ret>>12)&0x0F
	## //  	BP1 = (ret>>11)&0x01
	## //  	BP0 = (ret>>10)&0x01
	## //  	WEL = (ret>> 9)&0x01
	## //  	WIP = (ret>> 8)&0x01
	
	#ret = (ret>> 8)&0xFF;
	status     = (ret>> 8)&0xFF
	must_zeros = (ret>>12)&0x0F
	print('>>>>>> {} = {}'.format('status',status))
	print('>>>>>> {} = {}'.format('must_zeros',must_zeros))
	
	#return ret;
	return status

##  void eeprom_write_status (u8 BP1_b8, u8 BP0_b8);
def eeprom_write_status (dev, EP_ADRS,  BP1_b8, BP0_b8):
	#xil_printf(">>>>>> eeprom_write_status  \r\n");
	#eeprom_write_enable();
	eeprom_write_enable(dev, EP_ADRS)
	
	#u8 STA_in_b8 = (BP1_b8<<3) + (BP0_b8<<2);
	STA_in_b8 = (BP1_b8<<3) + (BP0_b8<<2)
	
	#eeprom_send_frame (0x6E, STA_in_b8, 0, 0, 1, 0);
	eeprom_send_frame (dev, EP_ADRS,  0x6E, STA_in_b8, 0, 0, 1, 0)
	
	return

##  u32 is_eeprom_available();
def is_eeprom_available(dev, EP_ADRS):
	#xil_printf(">>>>>> is_eeprom_available  \r\n");
	#u32 ret = 1;
	ret = 1
	
	#####
	#u32 val;
	#eeprom_write_disable();
	eeprom_write_disable(dev, EP_ADRS)
	
	#val = eeprom_read_status();
	val = eeprom_read_status(dev, EP_ADRS)
	print('>>>>>> {} = {}'.format('val',val))
	
	#if ((val&0x02)==0x00) {
	#	ret = ret*1;
	#}
	#else {
	#	ret = ret*0;
	#}
	if ((val&0x02)==0x00):
		ret = ret*1
	else:
		ret = ret*0
	
	####
	#eeprom_write_enable();
	eeprom_write_enable(dev, EP_ADRS)
	
	#val = eeprom_read_status();
	val = eeprom_read_status(dev, EP_ADRS)
	print('>>>>>> {} = {}'.format('val',val))
	
	#if ((val&0x02)==0x02) {
	#	ret = ret*1;
	#}
	#else {
	#	ret = ret*0;
	#}
	if ((val&0x02)==0x02):
		ret = ret*1
	else:
		ret = ret*0
	
	##  ###
	##  #eeprom_write_status (dev, EP_ADRS,  BP1_b8, BP0_b8)
	##  BP1_ref = (val>>3)&0x01 
	##  BP0_ref = (val>>2)&0x01 
	##  BP1_test = 1 - BP1_ref
	##  BP0_test = 1 - BP0_ref
	##  eeprom_write_status (dev, EP_ADRS,  BP1_b8=BP1_test, BP0_b8=BP0_test)
	##  val = eeprom_read_status(dev, EP_ADRS)
	##  print('>>>>>> {} = {}'.format('val',val))
	##  #
	##  eeprom_write_status (dev, EP_ADRS,  BP1_b8=BP1_ref, BP0_b8=BP0_ref)
	
	
	######
	#return ret;
	if ret==1:
		ret=True
	else:
		ret=False
	return ret

##  void eeprom_erase_all();
def eeprom_erase_all(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_erase_all  \r\n");
	#eeprom_write_enable();
	eeprom_write_enable(dev, EP_ADRS)
	#eeprom_send_frame (0x6D, 0, 0, 0, 1, 0);
	eeprom_send_frame (dev, EP_ADRS,  0x6D, 0, 0, 0, 1, 0)
	return

##  void eeprom_set_all();
def eeprom_set_all(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_set_all  \r\n");
	#eeprom_write_enable();
	eeprom_write_enable(dev, EP_ADRS)
	#eeprom_send_frame (0x67, 0, 0, 0, 1, 0);
	eeprom_send_frame (dev, EP_ADRS,  0x67, 0, 0, 0, 1, 0)
	return

##  void eeprom_reset_fifo();
def eeprom_reset_fifo(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_reset_fifo  \r\n");
	#activate_mcs_ep_ti(MCS_EP_BASE, 0x53, 1);
	
	dev.ActivateTriggerIn(EP_ADRS['MEM_TI'], 1)	## (ep, loc)
	return


##  u16 eeprom_read_fifo (u16 num_bytes_DAT_b16, u8 *buf_dataout);
def eeprom_read_fifo (dev, EP_ADRS,  num_bytes_DAT_b16):
	buf_dataout_b8_list = []
	#

	#//  def eeprom_read_fifo(num_data=1):
	print('\n>>>>>> eeprom_read_fifo')
		#xil_printf(">>>>>> eeprom_read_fifo  \r\n");
	#//  	#
	#//  	
	bytes_in_one_sample = 4 # for 32-bit end-point
	num_bytes_from_fifo = num_bytes_DAT_b16 * bytes_in_one_sample
	print('{} = {}'.format('num_bytes_from_fifo', num_bytes_from_fifo))
	#//  	
	## setup data buffer for fifo data
	dataout = bytearray([0] * num_bytes_from_fifo)
	#//  	
	## call api function to read pipeout data
	data_count = dev.ReadFromPipeOut(EP_ADRS['MEM_PO'], dataout)
	#
		#// memory copy from 32-bit width pipe to 8-bit width buffer // ADRS_BASE_MHVSU or MCS_EP_BASE
		#dcopy_pipe8_to_buf8 (MCS_EP_BASE + (0xB3<<4), buf_dataout, num_bytes_DAT_b16); // (u32 adrs_p8, u8 *p_buf_u8, u32 len)
	#
	print('{} : {}'.format('data_count [byte]',data_count))
	#//  	
	#//  	##  if data_count<0:
	#//  	##  	#return
	#//  	##  	# set test data 
	#//  	##  	num_data = 40
	#//  	##  	data_count = num_data * bytes_in_one_sample
	#//  	##  	data_int_list = [1,2,3, 2, 1, -1 ]
	#//  	##  	data_bytes_list = [x.to_bytes(bytes_in_one_sample,byteorder='little',signed=True) for x in data_int_list]
	#//  	##  	print('{} = {}'.format('data_bytes_list', data_bytes_list))
	#//  	##  	#dataout = b'\x01\x00\x00\x00\x02\x00\x00\x00'
	#//  	##  	dataout = b''.join(data_bytes_list)
	#//  	
	## convert bytearray to 32-bit data : high 24 bits to be ignored due to 8-bit fifo
	#//  	data_fifo_int_list = []
	for ii in range(0,num_bytes_DAT_b16):
		temp_data = int.from_bytes(dataout[ii*bytes_in_one_sample:(ii+1)*bytes_in_one_sample], byteorder='little', signed=True)
		buf_dataout_b8_list += [temp_data&0x000000FF] # mask low 8-bit
	#//  	
	#//  	
	#//  	## print out 
	#//  	#if __debug__:print('{} = {}'.format('data_fifo_int_list', data_fifo_int_list))
	#//  	
	#//  	return data_fifo_int_list
	#
		#return num_bytes_DAT_b16;
	
	#
	return buf_dataout_b8_list

##  u16 eeprom_write_fifo (u16 num_bytes_DAT_b16, u8 *buf_datain);
def eeprom_write_fifo (dev, EP_ADRS,  num_bytes_DAT_b16, buf_datain_b8_list):

	#//  def eeprom_write_fifo(datain__int_list=[0]):
	print('\n>>>>>> eeprom_write_fifo')
	#	xil_printf(">>>>>> eeprom_write_fifo  \r\n");
	#//  	#
	#//  
	## convert 32-bit data to bytearray
	bytes_in_one_sample = 4 # for 32-bit end-point
	#//  	num_data = len(datain__int_list)
	num_bytes_to_fifo = num_bytes_DAT_b16 * bytes_in_one_sample
	datain = bytearray([0] * num_bytes_to_fifo)
	#//  	
	# convert bytes list : high 24 bits to be ignored due to 8-bit fifo
	datain__bytes_list = [x.to_bytes(bytes_in_one_sample,byteorder='little',signed=True) for x in buf_datain_b8_list]
	if __debug__:print('{} = {}'.format('datain__bytes_list', datain__bytes_list[:20]))
	#//  	
	# take out bytearray from list
	datain = b''.join(datain__bytes_list) 
	if __debug__:print('{} = {}'.format('datain', datain[:20]))
	#//  	
	## call api for pipein
	data_count = dev.WriteToPipeIn(EP_ADRS['MEM_PI'], datain)
	#
	#	// memory copy from 8-bit width buffer to 32-bit width pipe // ADRS_BASE_MHVSU or MCS_EP_BASE
	#	dcopy_buf8_to_pipe8  (buf_datain, MCS_EP_BASE + (0x93<<4), num_bytes_DAT_b16); //  (u8 *p_buf_u8, u32 adrs_p8, u32 len)
	#	
	#//  	
	#//  	return 
	#	return num_bytes_DAT_b16;

	return num_bytes_DAT_b16

##  u16 eeprom_read_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_dataout);
def eeprom_read_data (dev, EP_ADRS,  ADRS_b16, num_bytes_DAT_b16):
	buf_dataout_b8_list = []
	#

	#//  def eeprom_read_data(ADRS_b16=0x0000, num_bytes_DAT=1):
	print('\n>>>>>> eeprom_read_data')
	#	xil_printf(">>>>>> eeprom_read_data  \r\n");
	#	u16 ret;
	#//  	#
	#//  	
	## reset fifo test 
	eeprom_reset_fifo(dev, EP_ADRS)
	#	eeprom_reset_fifo();
	#//  
	## convert address
	ADL = (ADRS_b16>>0)&0x00FF 
	ADH = (ADRS_b16>>8)&0x00FF
	#	u8 ADL = (ADRS_b16>>0)&0x00FF;
	#	u8 ADH = (ADRS_b16>>8)&0x00FF;
	#//  	print('{} = 0x{:08X}'.format('ADRS_b16', ADRS_b16))
	#//  	print('{} = 0x{:04X}'.format('ADH', ADH))
	#//  	print('{} = 0x{:04X}'.format('ADL', ADL))
	#//  	
	## // CMD_READ__03 
	print('\n>>> CMD_READ__03')
	eeprom_send_frame (dev, EP_ADRS,  CMD_b8=0x03, STA_in_b8=0, ADL_b8=ADL, ADH_b8=ADH, num_bytes_DAT_b16=num_bytes_DAT_b16, con_disable_SBP_b8=0)
	#eeprom_send_frame (dev, EP_ADRS,  CMD=0x03, ADL=ADL, ADH=ADH, num_bytes_DAT=num_bytes_DAT_b16)
	#	eeprom_send_frame (0x03, 0, ADL, ADH, num_bytes_DAT_b16, 0);
	#//  
	## call fifo
	buf_dataout_b8_list = eeprom_read_fifo (dev, EP_ADRS,  num_bytes_DAT_b16=num_bytes_DAT_b16)
	#//  	ret = eeprom_read_fifo(num_data=num_bytes_DAT)
	#	ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
	#//  
	#//  	#
	#//  	return ret
	#	return ret;
	
	#
	return buf_dataout_b8_list

##  u16 eeprom_read_data_current (u16 num_bytes_DAT_b16, u8 *buf_dataout);
def eeprom_read_data_current (dev, EP_ADRS,  num_bytes_DAT_b16):
	buf_dataout_b8_list = []
	#
	
	#//  def eeprom_read_data_current(num_bytes_DAT=1):
	print('\n>>>>>> eeprom_read_data_current')
	#	xil_printf(">>>>>> eeprom_read_data_current  \r\n");
	#	u16 ret;
	#//  	#
	#//  	
	## reset fifo test 
	eeprom_reset_fifo(dev, EP_ADRS)
	#	eeprom_reset_fifo();
	#//  
	## // CMD_CRRD__06 
	print('\n>>> CMD_CRRD__06')
	eeprom_send_frame (dev, EP_ADRS,  CMD_b8=0x06, STA_in_b8=0, ADL_b8=0, ADH_b8=0, num_bytes_DAT_b16=num_bytes_DAT_b16, con_disable_SBP_b8=0)
	#eeprom_send_frame (CMD=0x06, num_bytes_DAT=num_bytes_DAT)
	#	eeprom_send_frame (0x06, 0, 0, 0, num_bytes_DAT_b16, 0);
	#//  
	## call fifo
	buf_dataout_b8_list = eeprom_read_fifo (dev, EP_ADRS,  num_bytes_DAT_b16=num_bytes_DAT_b16)
	#//  	ret = eeprom_read_fifo(num_data=num_bytes_DAT)
	#	ret = eeprom_read_fifo (num_bytes_DAT_b16, buf_dataout);
	#//  	#
	#//  	return ret
	#	return ret;
	
	#
	return buf_dataout_b8_list

##  u16 eeprom_write_data_16B (u16 ADRS_b16, u16 num_bytes_DAT_b16);
def eeprom_write_data_16B (dev, EP_ADRS,  ADRS_b16, num_bytes_DAT_b16=16):
	#xil_printf(">>>>>> eeprom_write_data_16B  \r\n");
	#eeprom_write_enable();
	eeprom_write_enable(dev, EP_ADRS)
	#u8 ADL = (ADRS_b16>>0)&0x00FF;
	#u8 ADH = (ADRS_b16>>8)&0x00FF;
	ADL = (ADRS_b16>>0)&0x00FF
	ADH = (ADRS_b16>>8)&0x00FF
	#eeprom_send_frame (0x6C, 0, ADL, ADH, num_bytes_DAT_b16, 1);
	eeprom_send_frame (dev, EP_ADRS,  CMD_b8=0x6C, STA_in_b8=0, ADL_b8=ADL, ADH_b8=ADH, num_bytes_DAT_b16=num_bytes_DAT_b16, con_disable_SBP_b8=1)
	#return num_bytes_DAT_b16;
	return num_bytes_DAT_b16

##  u16 eeprom_write_data (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain);
def eeprom_write_data (dev, EP_ADRS,  ADRS_b16, num_bytes_DAT_b16, buf_datain_b8_list):
	#//  def eeprom_write_data(ADRS_b16=0x0000, num_bytes_DAT=1, data8b_in=[0]):
	print('\n>>>>>> eeprom_write_data')
	#	xil_printf(">>>>>> eeprom_write_data  \r\n");
	#//  
	#//  	##  The 11XX features a 16-byte page buffer, meaning that
	#//  	##  up to 16 bytes can be written at one time. To utilize this
	#//  	##  feature, the master can transmit up to 16 data bytes to
	#//  	##  the 11XX, which are temporarily stored in the page buffer.
	#//  	##  After each data byte, the master sends a MAK, indicating
	#//  	##  whether or not another data byte is to follow. A
	#//  	##  NoMAK indicates that no more data is to follow, and as
	#//  	##  such will initiate the internal write cycle.
	#//  	
	## reset fifo test 
	eeprom_reset_fifo(dev, EP_ADRS)
	#	eeprom_reset_fifo();
	#//  
	if num_bytes_DAT_b16 <= 16:
		eeprom_write_fifo(dev, EP_ADRS,  num_bytes_DAT_b16=num_bytes_DAT_b16, buf_datain_b8_list=buf_datain_b8_list)
		eeprom_write_data_16B(dev, EP_ADRS,  ADRS_b16=ADRS_b16, num_bytes_DAT_b16=num_bytes_DAT_b16)
		num_bytes_DAT_b16 = 0 # 0 meaning all sent
		
	else:
		## call fifo : 8-bit width, depth 2048
	    ## note buf size 2048 
		fifo_size = 2048; # OK with 4096*4+128 buf fpga-side
		num_data_to_send = num_bytes_DAT_b16
		loc_data_to_send = 0
		while (num_data_to_send>0):
			if num_data_to_send <= 2048:
				eeprom_write_fifo(dev, EP_ADRS,  num_bytes_DAT_b16=num_data_to_send, buf_datain_b8_list=buf_datain_b8_list[(loc_data_to_send):])
				num_data_to_send = 0
			#
			eeprom_write_fifo(dev, EP_ADRS,  num_bytes_DAT_b16=fifo_size, buf_datain_b8_list=buf_datain_b8_list[(loc_data_to_send):(loc_data_to_send+fifo_size)])
			num_data_to_send -= fifo_size
			loc_data_to_send += fifo_size
			#
			pass
			
		## 16-byte page buffer operation support
		num_data_to_send = num_bytes_DAT_b16 # reload
		while 1:
			if num_data_to_send <= 16:
				eeprom_write_data_16B(dev, EP_ADRS,  ADRS_b16=ADRS_b16, num_bytes_DAT_b16=num_data_to_send)
				num_bytes_DAT_b16 = 0
				break
			eeprom_write_data_16B(dev, EP_ADRS,  ADRS_b16=ADRS_b16, num_bytes_DAT_b16=16)
			ADRS_b16          += 16;
			num_data_to_send  -= 16;
			#
			pass
		
	return num_bytes_DAT_b16

##  u8* get_adrs__g_EEPROM__buf_2KB();
def get_adrs__g_EEPROM__buf_2KB():
	global g_EEPROM__buf_2KB
	EEPROM__buf_2KB = g_EEPROM__buf_2KB;
	return EEPROM__buf_2KB

##  u16 eeprom_read_all();
def eeprom_read_all(dev, EP_ADRS):
	#//  def eeprom_read_all():
	#	xil_printf(">>>>>> eeprom_read_all  \r\n");
	global g_EEPROM__buf_2KB
	#//  	
	g_EEPROM__buf_2KB = eeprom_read_data(dev, EP_ADRS,  ADRS_b16=0x0000, num_bytes_DAT_b16=2048)
	#	eeprom_read_data (0x0000, 2048, g_EEPROM__buf_2KB); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	#//  	
	return g_EEPROM__buf_2KB
	#	return 2048;

##  u16 eeprom_write_all();
def eeprom_write_all(dev, EP_ADRS):
	#xil_printf(">>>>>> eeprom_write_all  \r\n");
	global g_EEPROM__buf_2KB
	eeprom_write_data (dev, EP_ADRS,  ADRS_b16=0, num_bytes_DAT_b16=2048, buf_datain_b8_list=g_EEPROM__buf_2KB)
	#eeprom_write_data (0x0000, 2048, g_EEPROM__buf_2KB); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)	
	return g_EEPROM__buf_2KB
	#return 2048;



#u8 ignore_nonprint_code(u8 ch) {
#	if (ch< 0x20 || ch>0x7E)
#		ch = '.';
#	return ch;
#}

def hex_txt_display(mem_data__list, offset=0x0000):
	# display : every 16 bytes
	#print(mem_data_2KB__list)
	# 014  0x00E0  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
	# 015  0x00F0  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
	# 016  0x0100  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
	# 017  0x0110  FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
	# 018  0x0120  FF FF FF FE DC BA FF FF  FF FF FF FF FF FF FF FF  ................	
	
	mem_data_2KB__list = mem_data__list
	adrs_ofs = offset
	
	num_bytes_in_MEM = len(mem_data_2KB__list)
	num_bytes_in_a_display_line = 16
	
	output_display = ''
	for ii in range(0,int(num_bytes_in_MEM/num_bytes_in_a_display_line)):
		xx              = mem_data_2KB__list[(ii*16):(ii*16+16)]                                 # load line data
		output_display += '{:03d}  '  .format(ii)                                                # line number 
		output_display += '0x{:04X}  '.format(ii*16+adrs_ofs)                                             # start address each line
		output_display += ''.join([ '{:02X} '.format(jj) for jj in xx[0:8 ] ])                   # hex code 
		output_display += ' '
		output_display += ''.join([ '{:02X} '.format(jj) for jj in xx[8:16] ])                   # hex code 
		output_display += ' '
		output_display += ''.join([ chr(jj) if (jj>= 0x20 and jj<=0x7E) else '.' for jj in xx ]) # printable code
		output_display += '\n'                                                                   # line feed
	#
	return output_display


def cal_checksum (data_b8_list):
	ret = sum(data_b8_list) & 0xFF
	return ret
	
def gen_checksum (data_b8_list):
	ret = 0x100 - sum(data_b8_list) & 0xFF
	return ret

##  u8 chk_all_zeros (u16 len_b16, u8 *p_data_b8);
def chk_all_zeros (len_b16, p_data_b8_list):
	#u8 ret;
	#//
	#ret = 1;
	#while (1) {
	#	if ((*p_data_b8)==0x00) 
	#		ret = ret * 1;
	#	else 
	#		ret = ret * 0;
	#	len_b16   -= 1;
	#	p_data_b8 += 1;
	#	if (len_b16==0) break;
	#}
	#//
	#return ret;	// 1 for all zero.
	return all(vv==0 for vv in p_data_b8_list[0:len_b16])


def eeprom_read_header_formatted(dev, EP_ADRS):
	mem_data__list = eeprom_read_data(dev, EP_ADRS, ADRS_b16=0x0000, num_bytes_DAT_b16=16*4)
	output_display = hex_txt_display(mem_data__list)
	return output_display, mem_data__list

def _test_eeprom():
	print('>>> _test_eeprom')

	import eps
	import pgu_cpu__lib as pgu
	import pgu_cpu__lib_conf as conf
	
	EP_ADRS   = conf.EP_ADRS_CONFIG
	
	dev = eps.EPS_Dev()

	#_host_ = '192.168.100.87' # t1
	#_host_ = '192.168.100.84' # t2
	#_host_ = '192.168.100.95' # tt
	#_host_ = '192.168.168.95' # tt
	_host_ = '192.168.100.127' # PGU test
	_port_ = 5025
	dev.Open(_host_,_port_) 

	## check g var
	print('{} = {}'.format('g_EEPROM__LAN_access',g_EEPROM__LAN_access))
	print('{} = {}'.format('g_EEPROM__on_TP',g_EEPROM__on_TP))
	
	eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=0,  EEPROM__on_TP_b8=1)
	print('{} = {}'.format('g_EEPROM__LAN_access',g_EEPROM__LAN_access))
	print('{} = {}'.format('g_EEPROM__on_TP',g_EEPROM__on_TP))
	
	eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=1,  EEPROM__on_TP_b8=1)
	print('{} = {}'.format('g_EEPROM__LAN_access',g_EEPROM__LAN_access))
	print('{} = {}'.format('g_EEPROM__on_TP',g_EEPROM__on_TP))
	
	
	## test 
	eeprom_write_enable(dev, EP_ADRS)
	
	ret = eeprom_read_status(dev, EP_ADRS)
	print(ret)

	eeprom_write_disable(dev, EP_ADRS)
	
	ret = eeprom_read_status(dev, EP_ADRS)
	print(ret)
	
	ret = is_eeprom_available(dev, EP_ADRS)
	print(ret)
	if ret==False:
		input('Note: eeprom is not available!')

	## update eeprom ex 
	#
	#// 000  0x0000  43 4D 55 5F 43 50 55 5F  4C 41 4E 23 30 31 30 31  CMU_CPU_ LAN#0101 // info_txt[0:10]+'#'+BoardID_txt[0:3]
	#// 001  0x0010  C0 A8 A8 8F FF FF FF 00  C0 A8 A8 01 00 00 00 00  ........ ........ // SIP[0:3]+SUB[0:3]+GAR[0:3]+DNS[0:3]
	#// 002  0x0020  30 30 30 38 44 43 30 30  41 43 33 32 31 35 24 31  0008DC00 AC3215$1 // MAC_txt[0:11]+SlotID_txt[0:1]+UserID[0]+CKS[0]
	#// 003  0x0030  2D 5F 2D 5F 2D 2D 5F 5F  2D 5F 2D 5F 2D 2D 5F 5F  -_-_--__ -_-_--__	 // test_txt[0:15]
	#
	#// input para :
	#
	#//u32 BoardID = 101; // EEPROM on TP
	#//u32 SlotID  =  15; // EEPROM on TP
	#
	#u32 BoardID = 110+4; // CMU-CPU-F5500 #4
	#u32 SlotID  =     4; // CMU-CPU-F5500 #4
	#
	#//u32 BoardID = 110+7; // CMU-CPU-F5500 #7
	#//u32 SlotID  =     7; // CMU-CPU-F5500 #7
	#
	#//   info_txt[0:10]  
	#u8* info_txt = (u8*)"CMU_CPU_LAN"; // + sentinel
	#//   BoardID_txt[0:3]
	#//...
	#
	#//   SIP[0:3]
	#// note CMU base ip : 192.168.100.16, 192.168.100.80,  192.168.168.80
	#u8 eeprom_SIP[4] = {192,168,100,80}; // will add SlotID to eeprom_SIP[3]
	#//   SUB[0:3]
	#u8 eeprom_SUB[4] = {255,255,255,  0};
	#//   GAR[0:3]       
	#u8 eeprom_GAR[4] = {  0,  0,  0,  0};
	#//   DNS[0:3]       
	#u8 eeprom_DNS[4] = {  0,  0,  0,  0};
	#//
	#eeprom_SIP[3] += SlotID;
	#
	#//   MAC_txt[0:11]
	#//u8* MAC_txt = (u8*)"0008DC00ABCD"; // + sentinel // will add BoardID
	#u8 MAC_txt[12];// will add BoardID
	#xil_sprintf((char*)MAC_txt, "%s%08X", (char *)"0008", (unsigned int)0XDC00ABCD+BoardID);
	#//   SlotID_txt[0:1]
	#//...
	#//   UserID[0]
	#u8 UserID = '$';
	#//   CKS[0]
	#u8 CKS = 0;
	#
	#
	#
	#//   test_txt[0:15]
	#u8* test_txt = (u8*)"-_-_--__-_-_--__"; // + sentinel
	#
	#// write header
	#//...
	#//eeprom_write_data (0x0000, 16, (u8*)"CMU_CPU_LAN#0100"); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)
	#
	#// line 0
	#xil_sprintf((char*)tmp_buf, "%.11s%c%04d", (char*)info_txt, (char)'#', (unsigned int)BoardID);
	#eeprom_write_data (0x0000, 16, (u8*)tmp_buf); // (u16 ADRS_b16, u16 num_bytes_DAT_b16, u8 *buf_datain)

	## read mem header test 
	#mem_data__list = eeprom_read_data(dev, EP_ADRS, ADRS_b16=0x0000, num_bytes_DAT_b16=16*4)
	#output_display = hex_txt_display(mem_data__list)
	#print(output_display)
	
	output_display = eeprom_read_header_formatted(dev, EP_ADRS)
	print(output_display)
	
	input('')

	## write data 16B 
	#txt_test =  '0123456789abcdef'
	txt_test =  '0123456789ABCDEF'
	mem_data__list = []*16
	mem_data__list[0x00:0x10] = [ ord(xx) for xx in txt_test] # text --> ascii	
	eeprom_write_data(dev, EP_ADRS,  ADRS_b16=0x0030, num_bytes_DAT_b16=16, buf_datain_b8_list=mem_data__list)
	
	mem_data_2KB__list = eeprom_read_all(dev, EP_ADRS)
	output_display = hex_txt_display(mem_data_2KB__list)
	print(output_display)

	## write data 16B * 2EA
	#txt_test =  '0123456789abcdef'
	txt_test =  '0123456789abcdef' + '0123456789ABCDEF'
	mem_data__list = []*16*2
	mem_data__list[0x00:0x20] = [ ord(xx) for xx in txt_test] # text --> ascii	
	mem_data__list[0x10:0x20] = [0xFF]*16 # set 1
	eeprom_write_data(dev, EP_ADRS,  ADRS_b16=0x0030, num_bytes_DAT_b16=16*2, buf_datain_b8_list=mem_data__list)
	
	mem_data_2KB__list = eeprom_read_all(dev, EP_ADRS)
	output_display = hex_txt_display(mem_data_2KB__list)
	print(output_display)


	## write mem header test 
	HEADER_WRITE_TEST_EN = 0
	if HEADER_WRITE_TEST_EN: 
	
		# info 
		#board_id = 11 # board-REV2 #11
		#board_id = 12 # board-REV2 #12
		#board_id = 13 # board-REV2 #13
		board_id = 14 # for EEPROM from TP test
		#board_id = 15 # for EEPROM from TP
		#SIP = [192,168,168,143] # 128 + 15
		SIP = [192,168,168,128+board_id] # 128 + board_id
		SUB = [255,255,255,  0]
		GAR = [192,168,168,  1]
		DNS = [  0,  0,  0,  0]
		#MAC = '0008dc00abcd'
		MAC = '0008dc00ab' '{:02x}'.format(0xcd + board_id) # cd + board_id
		BID = '{:02d}'.format(board_id) # board id 
		slot_id = board_id
		SID = '{:02d}'.format(slot_id) # slot_id # 0 for loading from mother board later
		UID = '$'
		CKS = '#'
	
		mem_header = [0]*(16*4)
		#mem_header[0x00:0x10] = [ ord(xx) for xx in 'MHVSU_BASE_#0000'] # info text on TP
		mem_header[0x00:0x10] = [ ord(xx) for xx in 'MHVSU_BASE_#00'+BID ] # info text // on Board ID 
		mem_header[0x10:0x20] = [ xx      for xx in SIP+SUB+GAR+DNS ] # info IP
		mem_header[0x20:0x30] = [ ord(xx) for xx in MAC+SID+UID+CKS ] # info text : MAC(12 hex char) + Slot ID(2 bytes) + USER ID(1 bytes) + IP checksum (1 byte)
		mem_header[0x30:0x40] = [ ord(xx) for xx in '-_-_-_-_-_-_-_-_'] # info text
		
		print(mem_header[0x10:0x30])
		print(cal_checksum(mem_header[0x10:0x30]))
		mem_header[0x2F] = gen_checksum(mem_header[0x10:0x2F]) # update zero checksum CKS
		print(mem_header[0x2F])
		print(cal_checksum(mem_header[0x10:0x30]))
		
		eeprom_write_data(ADRS_b16=0x0000, num_bytes_DAT=len(mem_header), data8b_in=mem_header)


	pass


#  
####  


####
## TODO: (12) SPIO
#  
#  // SPIO_WI
#  wire [31:0] w_SPIO_CON_WI  = (w_mcs_ep_wi_en)? w_port_wi_1B_1 : ep1Bwire;
#  // bit[0]=SPIO_enable
#  // bit[4]=pin_swap_CSB_MOSI
#  // bit[8]=mode_forced_pin_enable //$$ for PGU interface
#  // bit[9]=forced_sig_MOSI
#  // bit[10]=forced_sig_SCLK
#  // bit[11]=forced_sig_CS
#  // bit[18:16]=CS_en[2:0]      //$$ frame data control
#  // bit[31:24]=socket_en[7:0]  //$$ frame data control
#  
#  // SPIO_FDAT_WI
#  wire [31:0] w_SPIO_FDAT_WI = (w_mcs_ep_wi_en)? w_port_wi_1A_1 : ep1Awire;
#  // bit[27:25]=pin_address[2:0]
#  // bit[24]=read/write_bar
#  // bit[23:16]=reg_address[7:0]
#  // bit[15: 8]=GPA[7:0]
#  // bit[ 7: 0]=GPB[7:0]
#  
#  // SPIO_WO
#  wire [31:0] w_SPIO_FLAG_WO; //$$ share with w_XADC_VOLT
#  // bit[26]  =frame_busy
#  // bit[25]  =frame_done
#  // bit[15:8]=readback_DA
#  // bit[7:0] =readback_DB
#  
#  // SPIO_TI
#  wire [31:0] w_SPIO_TRIG_TI = (w_mcs_ep_ti_en)? w_port_ti_5B_1 : ep5Btrig;
#  // bit[0]=reset_trig
#  // bit[1]=spi_frame_trig
#  
#  // SPIO_TO
#  wire [31:0] w_SPIO_TRIG_TO;
#  // bit[1]=spi_frame_done
#  assign ep7Btrig       = (~w_mcs_ep_to_en)? w_SPIO_TRIG_TO : 32'h0;
#  assign w_port_to_7B_1 = ( w_mcs_ep_to_en)? w_SPIO_TRIG_TO : 32'h0; //$$
#  
#  // SPIO controls
#  wire w_SPIO_en = w_SPIO_CON_WI[0] & (~w_SPIO_TRIG_TI[0]); //$$
#  wire w_pin_swap_CSB_MOSI = w_SPIO_CON_WI[4];

def spio_en(dev, EP_ADRS, pin_swap_CSB_MOSI=0):

	if pin_swap_CSB_MOSI==1 :
		SPIO_WI      = 0x00000011
		SPIO_WI_mask = 0x00000011
	else :
		SPIO_WI      = 0x00000001
		SPIO_WI_mask = 0x00000011
	
	dev.SetWireInValue(EP_ADRS['SPIO_WI'], SPIO_WI, SPIO_WI_mask) # (ep,val,mask)
	dev.UpdateWireIns()	
	return	

def spio_dis(dev, EP_ADRS):
	dev.SetWireInValue(EP_ADRS['SPIO_WI'], 0x00000000, 0x00000011) # (ep,val,mask)
	dev.UpdateWireIns()	
	return

def spio_reset(dev, EP_ADRS):
	dev.ActivateTriggerIn(EP_ADRS['SPIO_TI'], 0)	## (ep, loc)
	return

def spio_send_frame_ep(dev, EP_ADRS, SPIO_WI, SPIO_FDAT_WI, MAX_CNT = 50):
	#def spio_send_frame_ep (dev, EP_ADRS, socket_en, cs_en, rd__wr_bar, reg_adrs, data_out):
	
	data_readback = 0x0000
	#
	
	## send SPIO send frame
	
	# # set socket/cs 
	# # SPIO_CON_WI
	# # ep05 = 0xFF070001 // w_SPIO_CON_WI // socket/cs enable 
	# #cs_en_data = 0x02 # for CS1
	# #wire_data = 0
	# wire_data = (socket_en<<24) + (cs_en<<16) + 1
	# dev.SetWireInValue(0x05,wire_data,0xFFFFFFFF) # (ep,val,mask)
	# dev.UpdateWireIns()
	
	dev.SetWireInValue(EP_ADRS['SPIO_WI'],SPIO_WI,0xFFFF0000) # (ep,val,mask)
	dev.UpdateWireIns()
	
	#  # make frame data
	#  #reg_adrs = 0x0012
	#  frame_data = 0
	#  frame_data = (rd__wr_bar<<24)+ (reg_adrs<<16) + data_out
	#  # SPIO_FDAT_WI
	#  # ep04 = 0x00120080 // {GPA,GPB}
	#  dev.SetWireInValue(0x04,frame_data,0xFFFFFFFF) # (ep,val,mask)
	#  dev.UpdateWireIns()
	
	dev.SetWireInValue(EP_ADRS['SPIO_FDAT_WI'],SPIO_FDAT_WI,0xFFFFFFFF) # (ep,val,mask)
	dev.UpdateWireIns()
	
	## clear trig out
	dev.UpdateTriggerOuts()
	ret=dev.GetTriggerOutVector(EP_ADRS['SPIO_TO'])

	# send trig 
	#dev.ActivateTriggerIn(0x45, 1)
	dev.ActivateTriggerIn(EP_ADRS['SPIO_TI'], 1)	## (ep, loc)
	
	# ep65[1] // w_SPIO_TRIG_TO; // init done
	cnt_loop = 0;
	while 1:
		# First, query all XEM Trigger Outs.
		dev.UpdateTriggerOuts()
		# check trigger out
		if dev.IsTriggered(EP_ADRS['SPIO_TO'], (0x01<<1)) == True: # // (ep, mask)
			break
		cnt_loop += 1;
		print('{} = {}'.format('cnt_loop', cnt_loop))
		if (cnt_loop>MAX_CNT):
			break
	print('{} = {}'.format('cnt_loop', cnt_loop))	
	
	## readback 
	dev.UpdateWireOuts()
	readback = dev.GetWireOutValue(EP_ADRS['SPIO_WO'])
	data_readback = (readback & 0x0000FFFF)
	print('{} = 0x{:04X}'.format('data_readback', data_readback))
	
	#
	return data_readback


## force mode operation for spio_send_frame


def spio_send_frame(dev, EP_ADRS, 
	socket_en_8b, cs_en_3b, 
	pin_adrs_3b, rd__wr_bar, reg_adrs_8b, data_gpa_8b=0, data_gpb_8b=0, MAX_CNT = 50):
	
	SPIO_WI  = (socket_en_8b<<24) + (cs_en_3b<<16) + 1
	
	SPIO_FDAT_WI = (pin_adrs_3b<<25) + (rd__wr_bar<<24)+ (reg_adrs_8b<<16) + (data_gpa_8b<<8) + data_gpb_8b
	
	return spio_send_frame_ep (dev, EP_ADRS, SPIO_WI, SPIO_FDAT_WI, MAX_CNT)

##



def spio_send_reg(dev, EP_ADRS, hwa, rd__wr_bar, reg_adrs, dat_a=0, dat_b=0):
	reg_adrs_dict = {}
	reg_adrs_dict['iocon'] = 0x0A
	reg_adrs_dict['olat']  = 0x14
	reg_adrs_dict['iodir'] = 0x00
	reg_adrs_dict['gpio']  = 0x12
	#
	try:
		reg_adrs_8b = reg_adrs_dict[reg_adrs]
	except:
		reg_adrs_8b = reg_adrs
	#
	ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hwa, rd__wr_bar=rd__wr_bar, reg_adrs_8b=reg_adrs_8b, 
		data_gpa_8b=dat_a, data_gpb_8b=dat_b)
	return ret

##  

def spio_hw_adrs_en(dev, EP_ADRS, hwa=0x0):
	# write IOCON : enable hardware pin address // @ 0x0A
	
	#ret = spio_send_frame(dev, EP_ADRS, 
	#socket_en_8b=0x01, cs_en_3b=0x1, 
	#pin_adrs_3b=0x0, rd__wr_bar=0, reg_adrs_8b=0x0A, 
	#data_gpa_8b=0x08, data_gpb_8b=0x08)
	
	spio_send_reg(dev=dev, EP_ADRS=EP_ADRS, 
		hwa=hwa, rd__wr_bar=0, reg_adrs='iocon', dat_a=0x08, dat_b=0x08)
	
	return

def spio_hw_adrs_scan(dev, EP_ADRS, hwa_range=range(0,8)):	
	IOCON = []
	OLAT  = []
	IODIR = []
	GPIO  = []
	#
	for hh in hwa_range:
		# read  IOCON with hardware address 0x0~0x7
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=1, reg_adrs_8b=0x0A, 
		data_gpa_8b=0x00, data_gpb_8b=0x00)
		IOCON += [ret]
		
		# read  OLAT with hardware address 0x0~0x7
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=1, reg_adrs_8b=0x14, 
		data_gpa_8b=0x00, data_gpb_8b=0x00)
		OLAT += [ret]
		
		# read  IODIR with hardware address 0x0~0x7
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=1, reg_adrs_8b=0x00, 
		data_gpa_8b=0x00, data_gpb_8b=0x00)
		IODIR += [ret]
		
		# read  GPIO with hardware address 0x0~0x7
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=1, reg_adrs_8b=0x12, 
		data_gpa_8b=0x00, data_gpb_8b=0x00)
		GPIO += [ret]
	
	return IOCON, OLAT, IODIR, GPIO

def spio_hw_adrs_write_spio(dev, EP_ADRS, hwa_range=range(0,8), GPIO=0x00):	
	# write GPIO with the same values
	for hh in hwa_range:
		# write  GPIO with hardware address 0x0~0x7
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=0, reg_adrs_8b=0x12, 
		data_gpa_8b=(GPIO>>8)&0x00FF, data_gpb_8b=GPIO&0x00FF)

	return

# iocon check 
def spio_hw_adrs_check(dev, EP_ADRS, hwa_list=[0, 1, 2, 3, 4, 5, 6, 7]):
	rd__wr_bar=1
	reg_adrs='iocon'
	##
	iocon_list = {}
	for ii,hwa in enumerate(hwa_list):
		iocon_list[hwa] = spio_send_reg(dev=dev, EP_ADRS=EP_ADRS, 
			hwa=hwa, rd__wr_bar=rd__wr_bar, reg_adrs=reg_adrs)
	#
	# iocon_list[0], ... iocon_list[7]
	return iocon_list

##

def spio_conf (dev, EP_ADRS, SPIO_CONF, hwa_list=range(0,8)):
	
	# set reg : OLAT, IODIR
	# read reg: GPIO
	for hh in hwa_list:
		
		# OLAT : set OLAT reg // @ 0x14
		reg_adrs       ='olat'
		dat_a=SPIO_CONF['OLAT_A'][hh]
		dat_b=SPIO_CONF['OLAT_B'][hh]
		ret = spio_send_reg(dev=dev, EP_ADRS=EP_ADRS, 
			hwa=hh, rd__wr_bar=0, reg_adrs=reg_adrs, dat_a=dat_a, dat_b=dat_b)
		
		# IODIR : set io directions for all devices // @ 0x00
		reg_adrs       ='iodir'
		dat_a=SPIO_CONF['IODIR_A'][hh]
		dat_b=SPIO_CONF['IODIR_B'][hh]
		ret = spio_send_reg(dev=dev, EP_ADRS=EP_ADRS, 
			hwa=hh, rd__wr_bar=0, reg_adrs=reg_adrs, dat_a=dat_a, dat_b=dat_b)
		
		pass
	#
	return

def spio_init(dev, EP_ADRS, SPIO_CONF):

	# hw adrs enable
	spio_hw_adrs_en(dev, EP_ADRS)
	
	# scan all hw adrs
	#IOCON, OLAT, IODIR, GPIO = spio_hw_adrs_scan(dev, EP_ADRS)
	#print(IOCON)
	#print(OLAT)
	#print(IODIR)
	#print(GPIO)
	
	# set reg : OLAT, IODIR
	# read reg: GPIO
	GPIO_readback = []
	for hh in range(0,8):
		# OLAT : set OLAT reg // @ 0x14
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=0, reg_adrs_8b=0x14, 
		data_gpa_8b=SPIO_CONF['OLAT_A'][hh], data_gpb_8b=SPIO_CONF['OLAT_B'][hh])
		GPIO_readback += [ret]
			
		# IODIR : set io directions for all devices // @ 0x00
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=0, reg_adrs_8b=0x00, 
		data_gpa_8b=SPIO_CONF['IODIR_A'][hh], data_gpb_8b=SPIO_CONF['IODIR_B'][hh])
		GPIO_readback += [ret]		
	
		# GPIO : read IO ports // @ 0x12
		ret = spio_send_frame(dev, EP_ADRS, 
		socket_en_8b=0x01, cs_en_3b=0x1, 
		pin_adrs_3b=hh, rd__wr_bar=1, reg_adrs_8b=0x12, 
		data_gpa_8b=0x00, data_gpb_8b=0x00)
		GPIO_readback += [ret]
	#
	print(GPIO_readback)


	return


# spio sub-spi 
def dac_spi_frame_gen(i_frame_data_wr_24b):
	# frame subcount_L  01234567890123456789012345678901234567890123456789
	# frame subcount_H  00000000001111111111222222222233333333334444444444
	#           o_SCSB  -________________________________________________-
	#           o_SCLK  --_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
	#           o_MOSI  _DDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDddDDdd_
	#                    3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 
	#                    2 2 2 2 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 
	o_SCSB = [0]*50
	o_SCLK = [0]*50
	o_MOSI = [0]*50
	#
	o_SCSB[ 0] = 1
	o_SCSB[49] = 1
	#
	o_SCLK[ 0] = 1
	for ii in range(1,50,2):
		o_SCLK[ii] = 1
	#
	for ii in range(1,48,2):
		if i_frame_data_wr_24b&0x800000 == 0:
			data_bit_at_b23 = 0
		else:
			data_bit_at_b23 = 1
		o_MOSI[ii  ] = data_bit_at_b23
		o_MOSI[ii+1] = data_bit_at_b23
		i_frame_data_wr_24b = i_frame_data_wr_24b<<1
	#
	return o_SCSB, o_SCLK, o_MOSI



def _test_spio():
	print('>>> _test_spio')

	# test input parameter 
	pin_adrs_3b = 0x6
	rd__wr_bar  = 0x1
	reg_adrs_8b = 0x0A
	data_gpa_8b = 0x00
	data_gpb_8b = 0x00
	#
	SPIO_FDAT_WI = (pin_adrs_3b<<25) + (rd__wr_bar<<24)+ (reg_adrs_8b<<16) + (data_gpa_8b<<8) + data_gpb_8b
	#
	print('{} = 0x{:08X}'.format('SPIO_FDAT_WI',SPIO_FDAT_WI))
	
	#
	#o_SCSB, o_SCLK, o_MOSI = dac_spi_frame_gen(i_frame_data_wr_24b=0x000000)
	o_SCSB, o_SCLK, o_MOSI = dac_spi_frame_gen(i_frame_data_wr_24b=0x35ACA5)
	print('{} = {}'.format('o_SCSB',o_SCSB))
	print('{} = {}'.format('o_SCLK',o_SCLK))
	print('{} = {}'.format('o_MOSI',o_MOSI))
	
	

#  
####  


####
## TODO: (13) DACZ - pattern gen - CID test
#  
#  // 'DACZ_DAT_WI'        : 0x08, ##$$ new pattern gen
#  // 'DACZ_DAT_WO'        : 0x28, ##$$ new pattern gen
#  // 'DACZ_DAT_TI'        : 0x48, ##$$ new pattern gen




#  
####  





####
## TODO: (99) any functions
#  
#  test batch
#  
####  

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
		
	#_test_spio()

	_test_eeprom()
	
	
	
	