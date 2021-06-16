## pgu_cpu__26_eeprom_writer.py 
# eeprom writer for setup ID and IPs

# ref:
#   https://tkdocs.com/tutorial/text.html
#   https://stackoverflow.com/questions/14824163/how-to-get-the-input-from-the-tkinter-text-widget
#   https://tkdocs.com/tutorial/morewidgets.html#text
#   https://www.python-course.eu/tkinter_text_widget.php

###########################################################################
# check debug mode
if __debug__:
	print('>>> In debug mode ... ')


###########################################################################
###########################################################################

####
## common
#  
def _form_dict_idx_(var,idx):
	return '{:20} --> {}'.format(idx, var[idx])
def _form_dict_idx_hex_16b_(var,idx):
	return '{:20} --> {:#04x}'.format(idx, var[idx])
def _form_hex_32b_(val):
	return '0x{:08X}'.format(val)
#


####
## TODO : library call
import eps
import pgu_cpu__lib as pgu
import pgu_cpu__lib_conf as conf

#eps.eps_test()

# read configuration : EP_ADRS_CONFIG
EP_ADRS   = conf.EP_ADRS_CONFIG

#  display some configuration info
print(_form_dict_idx_(EP_ADRS,'board_name'))
print(_form_dict_idx_(EP_ADRS,'ver'))
print(_form_dict_idx_(EP_ADRS,'bit_filename'))
#
print(_form_dict_idx_hex_16b_(EP_ADRS,'FPGA_IMAGE_ID'))
print(_form_dict_idx_hex_16b_(EP_ADRS,'XADC_TEMP'))
print(_form_dict_idx_hex_16b_(EP_ADRS,'TEST_CON'))
print(_form_dict_idx_hex_16b_(EP_ADRS,'BRD_CON'))

####
## TODO: init for end-point system : dev 
dev = eps.EPS_Dev()


#### GUI: Checkbutton and Button
from tkinter import *
from functools import partial


## window obj
master   = Tk()


## global var for eeprom
g_eeprom_not_found = 1
g_eeprom_loc = ''


## gui variables for board status
def set_up_global_master():
	
	global master

	global  ee_FPGA_IMAGE_ID_
	global  ee_TEST_FLAG_____
	global  ee_MON_XADC______
	global  ee_temp_fpga_____
	
	global  tt_IP_ADRS
	global  tt_RSP_IDN
	
	global  g_eeprom_loc
	
	global 	tt_EEPROM_LOC
	global  tt_EEPROM_HEADER
	global  tt_EEPROM_INFO_txt   
	global  tt_EEPROM_BoardID_txt
	global  tt_EEPROM_SIP_txt    
	global  tt_EEPROM_SUB_txt    
	global  tt_EEPROM_GAR_txt    
	global  tt_EEPROM_DNS_txt    
	global  tt_EEPROM_MAC_txt    
	global  tt_EEPROM_SlotID_txt 
	global  tt_EEPROM_UserID_txt 
	global  tt_EEPROM_CKS_txt    
	global  tt_EEPROM_USER_txt   
	
	
	## board
	ee_FPGA_IMAGE_ID_ = Entry(master, justify='right', width=12)
	ee_TEST_FLAG_____ = Entry(master, justify='right', width=12)
	ee_MON_XADC______ = Entry(master, justify='right', width=12)
	#
	ee_temp_fpga_____ = Entry(master, justify='right', width=8)
	#
	#
	ee_FPGA_IMAGE_ID_.insert(0,"0x00000000")
	ee_TEST_FLAG_____.insert(0,"0x00000000")
	ee_MON_XADC______.insert(0,"0x00000000")
	#
	ee_temp_fpga_____.insert(0,"0.0")
	
	## LAN
	tt_IP_ADRS = Text(master, width=40, height=1)
	tt_RSP_IDN = Text(master, width=60, height=1)
	#
	tt_IP_ADRS.insert(1.0,'test ip')
	tt_RSP_IDN.insert(1.0,'test IDN')
	
	## EEPROM
	
	tt_EEPROM_LOC    = Text(master, width=5, height=1)
	tt_EEPROM_LOC    .insert(1.0,g_eeprom_loc)
	
	tt_EEPROM_HEADER = Text(master, width=80, height=4)
	tt_EEPROM_HEADER.insert(1.0,'0x00 ... \n')
	tt_EEPROM_HEADER.insert(2.0,'0x10 ... \n')
	tt_EEPROM_HEADER.insert(3.0,'0x20 ... \n')
	tt_EEPROM_HEADER.insert(4.0,'0x30 ... ')

	# INFO_txt[0:11] // 12 char
	tt_EEPROM_INFO_txt    = Text(master, width=12, height=1)
	tt_EEPROM_INFO_txt   .insert(1.0,'____________')
	#tt_EEPROM_INFO_txt    .insert(1.0,'PGU_CPU_LAN#')
	# BoardID_txt[0:3]    0 ~ 9999
	tt_EEPROM_BoardID_txt = Text(master, width=4, height=1)
	tt_EEPROM_BoardID_txt .insert(1.0,'9999')
	# SIP[0:3] 
	tt_EEPROM_SIP_txt     = Text(master, width=15, height=1)
	tt_EEPROM_SIP_txt     .insert(1.0,'192.168.000.000')
	# SUB[0:3]            
	tt_EEPROM_SUB_txt     = Text(master, width=15, height=1)
	tt_EEPROM_SUB_txt     .insert(1.0,'255.255.255.000')
	# GAR[0:3]            
	tt_EEPROM_GAR_txt     = Text(master, width=15, height=1)
	tt_EEPROM_GAR_txt     .insert(1.0,'000.000.000.000')
	# DNS[0:3]            
	tt_EEPROM_DNS_txt     = Text(master, width=15, height=1)
	tt_EEPROM_DNS_txt     .insert(1.0,'000.000.000.000')
	# MAC_txt[0:11]       
	#tt_EEPROM_MAC_txt     = Text(master, width=17, height=1)
	#tt_EEPROM_MAC_txt     .insert(1.0,'XX:XX:XX:XX:XX:XX')
	tt_EEPROM_MAC_txt     = Text(master, width=12, height=1)
	#tt_EEPROM_MAC_txt    .insert(1.0,'XXXXXXXXXXXX')
	tt_EEPROM_MAC_txt     .insert(1.0,'0123456789AB')
	# SlotID_txt[0:1]     0 ~ 99
	tt_EEPROM_SlotID_txt  = Text(master, width=2, height=1)
	tt_EEPROM_SlotID_txt  .insert(1.0,'99')
	# UserID[0]           0 ~ 255
	tt_EEPROM_UserID_txt  = Text(master, width=3, height=1)
	tt_EEPROM_UserID_txt  .insert(1.0,'123')
	# CKS[0]              0 ~ 255
	tt_EEPROM_CKS_txt     = Text(master, width=3, height=1)
	tt_EEPROM_CKS_txt     .insert(1.0,'023')
	# USER_txt[0:15]      
	tt_EEPROM_USER_txt    = Text(master, width=16, height=1)
	#tt_EEPROM_USER_txt   .insert(1.0,'________________')
	tt_EEPROM_USER_txt    .insert(1.0,'0123456789ABCDEF')

	
	#
	return
#
set_up_global_master()




### GUI functions ###

def master_bb_update_board_status_wo():
	print('>>> master_bb_update_board_status_wo')
	#
	## read endpoint
	dev.UpdateWireOuts()
	#
	wo20_data = dev.GetWireOutValue(0x20) # FPGA_IMAGE_ID
	wo21_data = dev.GetWireOutValue(0x21) # TEST_FLAG____
	wo3A_data = dev.GetWireOutValue(0x3A) # MON_XADC_____
	#
	print('{} = 0x{:08X}'.format('wo20_data', wo20_data))
	print('{} = 0x{:08X}'.format('wo21_data', wo21_data))
	print('{} = 0x{:08X}'.format('wo3A_data', wo3A_data))
	#
	ee_FPGA_IMAGE_ID_.delete(0,END)
	ee_TEST_FLAG_____.delete(0,END)
	ee_MON_XADC______.delete(0,END)
	#
	ee_temp_fpga_____.delete(0,END)
	#
	ee_FPGA_IMAGE_ID_.insert(0,'0x{:08X}'.format(wo20_data))
	ee_TEST_FLAG_____.insert(0,'0x{:08X}'.format(wo21_data))
	ee_MON_XADC______.insert(0,'0x{:08X}'.format(wo3A_data))
	#
	temp_fpga_____   = wo3A_data/1000
	ee_temp_fpga_____.insert(0,'{}'.format(temp_fpga_____))
	#
	
	return

def master_bb_update_lan_status():
	print('>>> master_bb_update_lan_status')
	
	dev_idn_str = dev.GetSerialNumber()
	
	tt_IP_ADRS.delete(1.0,END)
	tt_RSP_IDN.delete(1.0,END)

	tt_IP_ADRS.insert(1.0,'{}:{:d}'.format(_host_,_port_))
	tt_RSP_IDN.insert(1.0,'{}'.format(dev_idn_str))
	
	pass

## TODO: master_bb_read_eeprom()
def master_bb_read_eeprom():
	print('>>> master_bb_read_eeprom')
	
	global g_eeprom_not_found
	global g_eeprom_loc
	
	if g_eeprom_not_found==1:
		tt_EEPROM_HEADER.delete(1.0,END)
		tt_EEPROM_HEADER.delete(2.0,END)
		tt_EEPROM_HEADER.delete(3.0,END)
		tt_EEPROM_HEADER.delete(4.0,END)
		tt_EEPROM_HEADER.insert(1.0,'EEPROM is missing!!!')
		return
		
	## eeprom loca info
	tt_EEPROM_LOC.delete(1.0,END)
	tt_EEPROM_LOC.insert(1.0,g_eeprom_loc)

	## read eeprom header
	eeprom_header_str_4_16, eeprom_header_list = pgu.eeprom_read_header_formatted(dev, EP_ADRS)
	
	tt_EEPROM_HEADER.delete(1.0,END)
	tt_EEPROM_HEADER.delete(2.0,END)
	tt_EEPROM_HEADER.delete(3.0,END)
	tt_EEPROM_HEADER.delete(4.0,END)
	
	tt_EEPROM_HEADER.insert(1.0,eeprom_header_str_4_16)

	## parse eeprom header

	#// 000  0x0000  43 4D 55 5F 43 50 55 5F  4C 41 4E 23 30 31 30 31  CMU_CPU_ LAN#0101 // info_txt[0:10]+'#'+BoardID_txt[0:3]
	#// 001  0x0010  C0 A8 A8 8F FF FF FF 00  C0 A8 A8 01 00 00 00 00  ........ ........ // SIP[0:3]+SUB[0:3]+GAR[0:3]+DNS[0:3]
	#// 002  0x0020  30 30 30 38 44 43 30 30  41 43 33 32 31 35 24 31  0008DC00 AC3215$1 // MAC_txt[0:11]+SlotID_txt[0:1]+UserID[0]+CKS[0]
	#// 003  0x0030  2D 5F 2D 5F 2D 2D 5F 5F  2D 5F 2D 5F 2D 2D 5F 5F  -_-_--__ -_-_--__ // test_txt[0:15]
	
	# INFO_txt[0:11] // revise  info_txt[0:11]+BoardID_txt[0:3]
	# BoardID_txt[0:3]
	# SIP[0:3] 
	# SUB[0:3]
	# GAR[0:3]
	# DNS[0:3]
	# MAC_txt[0:11]
	# SlotID_txt[0:1]
	# UserID[0]
	# CKS[0]
	# USER_txt[0:15]
	
	print(eeprom_header_list)
	
	# convert list to txt
	INFO_txt    = ''.join([ chr(vv)  for vv in eeprom_header_list[ 0x00    :(0x00+12  )] ])
	#BoardID_txt = ''.join([ chr(vv)  for vv in eeprom_header_list[(0x00+12):(0x00+12+4)] ])
	try:
		BoardID_txt = '{:04d}'.format(int(''.join([ chr(vv)  for vv in eeprom_header_list[(0x00+12):(0x00+12+4)] ])))
	except:
		BoardID_txt = '{:04d}'.format(int('9999'))
	SIP_txt     = '{:3d}.{:3d}.{:3d}.{:3d}'.format( eeprom_header_list[0x10+0],
														eeprom_header_list[0x10+1],
														eeprom_header_list[0x10+2],
														eeprom_header_list[0x10+3])
	SUB_txt     = '{:3d}.{:3d}.{:3d}.{:3d}'.format( eeprom_header_list[0x14+0],
														eeprom_header_list[0x14+1],
														eeprom_header_list[0x14+2],
														eeprom_header_list[0x14+3])
	GAR_txt     = '{:3d}.{:3d}.{:3d}.{:3d}'.format( eeprom_header_list[0x18+0],
														eeprom_header_list[0x18+1],
														eeprom_header_list[0x18+2],
														eeprom_header_list[0x18+3])
	DNS_txt     = '{:3d}.{:3d}.{:3d}.{:3d}'.format( eeprom_header_list[0x1C+0],
														eeprom_header_list[0x1C+1],
														eeprom_header_list[0x1C+2],
														eeprom_header_list[0x1C+3])
	MAC_txt     = ''.join([ chr(vv)  for vv in eeprom_header_list[ 0x20    :(0x20+12  )] ])
	#SlotID_txt  = ''.join([ chr(vv)  for vv in eeprom_header_list[(0x20+12):(0x20+12+2)] ])
	try:
		SlotID_txt  = '{:02d}'.format(int(''.join([ chr(vv)  for vv in eeprom_header_list[(0x20+12):(0x20+12+2)] ])))
	except:
		SlotID_txt  = '{:02d}'.format(int('99'))
	UserID_txt  = '{:03d}'.format(eeprom_header_list[(0x20+12+2)])
	CKS_txt     = '{:03d}'.format(eeprom_header_list[(0x20+12+3)])
	USER_txt    = ''.join([ chr(vv)  for vv in eeprom_header_list[ 0x30    :(0x30+16  )] ])

	tt_EEPROM_INFO_txt    .delete(1.0,END)
	tt_EEPROM_BoardID_txt .delete(1.0,END)
	tt_EEPROM_SIP_txt     .delete(1.0,END)
	tt_EEPROM_SUB_txt     .delete(1.0,END)
	tt_EEPROM_GAR_txt     .delete(1.0,END)
	tt_EEPROM_DNS_txt     .delete(1.0,END)
	tt_EEPROM_MAC_txt     .delete(1.0,END)
	tt_EEPROM_SlotID_txt  .delete(1.0,END)
	tt_EEPROM_UserID_txt  .delete(1.0,END)
	tt_EEPROM_CKS_txt     .delete(1.0,END)
	tt_EEPROM_USER_txt    .delete(1.0,END)
	
	tt_EEPROM_INFO_txt    .insert(1.0,INFO_txt   )
	tt_EEPROM_BoardID_txt .insert(1.0,BoardID_txt)
	tt_EEPROM_SIP_txt     .insert(1.0,SIP_txt    )
	tt_EEPROM_SUB_txt     .insert(1.0,SUB_txt    )
	tt_EEPROM_GAR_txt     .insert(1.0,GAR_txt    )
	tt_EEPROM_DNS_txt     .insert(1.0,DNS_txt    )
	tt_EEPROM_MAC_txt     .insert(1.0,MAC_txt    )
	tt_EEPROM_SlotID_txt  .insert(1.0,SlotID_txt )
	tt_EEPROM_UserID_txt  .insert(1.0,UserID_txt )
	tt_EEPROM_CKS_txt     .insert(1.0,CKS_txt    )
	tt_EEPROM_USER_txt    .insert(1.0,USER_txt   )
	

	pass


def conv_txt_to_mem_list(txt,num_chr):
	if len(txt) >= num_chr:
		mem_list = [ ord(txt[ii])  for ii in range(num_chr) ]
	else:
		mem_list = [ord(' ')]*num_chr
		for ii in range(len(txt)):
			mem_list[ii] = ord(txt[ii])
	return mem_list

## TODO: master_bb_fuse_eeprom()
def master_bb_fuse_eeprom():
	print('>>> master_bb_fuse_eeprom')
	
	# read GUI
	
	EEPROM_INFO_txt      = tt_EEPROM_INFO_txt     .get(1.0,END)
	EEPROM_BoardID_txt   = tt_EEPROM_BoardID_txt  .get(1.0,END)
	EEPROM_SIP_txt       = tt_EEPROM_SIP_txt      .get(1.0,END)
	EEPROM_SUB_txt       = tt_EEPROM_SUB_txt      .get(1.0,END)
	EEPROM_GAR_txt       = tt_EEPROM_GAR_txt      .get(1.0,END)
	EEPROM_DNS_txt       = tt_EEPROM_DNS_txt      .get(1.0,END)
	EEPROM_MAC_txt       = tt_EEPROM_MAC_txt      .get(1.0,END)
	EEPROM_SlotID_txt    = tt_EEPROM_SlotID_txt   .get(1.0,END)
	EEPROM_UserID_txt    = tt_EEPROM_UserID_txt   .get(1.0,END)	
	EEPROM_CKS_txt       = tt_EEPROM_CKS_txt      .get(1.0,END)	
	EEPROM_USER_txt      = tt_EEPROM_USER_txt     .get(1.0,END)
	
	# remove the last \n
	EEPROM_INFO_txt    = EEPROM_INFO_txt   [:-1]
	EEPROM_BoardID_txt = EEPROM_BoardID_txt[:-1]
	EEPROM_SIP_txt     = EEPROM_SIP_txt    [:-1]
	EEPROM_SUB_txt     = EEPROM_SUB_txt    [:-1]
	EEPROM_GAR_txt     = EEPROM_GAR_txt    [:-1]
	EEPROM_DNS_txt     = EEPROM_DNS_txt    [:-1]
	EEPROM_MAC_txt     = EEPROM_MAC_txt    [:-1]
	EEPROM_SlotID_txt  = EEPROM_SlotID_txt [:-1]
	EEPROM_UserID_txt  = EEPROM_UserID_txt [:-1]
	EEPROM_CKS_txt     = EEPROM_CKS_txt    [:-1]
	EEPROM_USER_txt    = EEPROM_USER_txt   [:-1]
	
	# add leading zeros
	try:
		EEPROM_BoardID_txt = '{:04d}'.format(int(EEPROM_BoardID_txt))
	except:
		EEPROM_BoardID_txt = '{:04d}'.format(int('9999'))
	try:
		EEPROM_SlotID_txt  = '{:02d}'.format(int(EEPROM_SlotID_txt))
	except:
		EEPROM_SlotID_txt  = '{:02d}'.format(int('99'))
	
	try:
		print(EEPROM_INFO_txt   )
		print(EEPROM_BoardID_txt)
		print(EEPROM_SIP_txt    )
		print(EEPROM_SUB_txt    )
		print(EEPROM_GAR_txt    )
		print(EEPROM_DNS_txt    )
		print(EEPROM_MAC_txt    )
		print(EEPROM_SlotID_txt )
		print(EEPROM_UserID_txt )
		print(EEPROM_CKS_txt    )
		print(EEPROM_USER_txt   )
	except:
		pass

	#print(len(EEPROM_INFO_txt   ))
	#print(len(EEPROM_BoardID_txt))
	#print(len(EEPROM_SIP_txt    ))
	#print(len(EEPROM_SUB_txt    ))
	#print(len(EEPROM_GAR_txt    ))
	#print(len(EEPROM_DNS_txt    ))
	#print(len(EEPROM_MAC_txt    ))
	#print(len(EEPROM_SlotID_txt ))
	#print(len(EEPROM_UserID_txt ))
	#print(len(EEPROM_CKS_txt    ))
	#print(len(EEPROM_USER_txt   ))
	
	# convert eeprom data
	mem_data_4_16B_list = [0]*16*4
	
	#mem_data_4_16B_list[0:16] = conv_txt_to_mem_list('0123456789abcdef')
	mem_data_4_16B_list[0x00+ 0:0x00+12] = conv_txt_to_mem_list(EEPROM_INFO_txt,12)
	mem_data_4_16B_list[0x00+12:0x00+16] = conv_txt_to_mem_list(EEPROM_BoardID_txt,4)
	
	mem_data_4_16B_list[0x10+ 0:0x10+ 4] = [int(vv) for vv in EEPROM_SIP_txt.split('.')]
	mem_data_4_16B_list[0x10+ 4:0x10+ 8] = [int(vv) for vv in EEPROM_SUB_txt.split('.')]
	mem_data_4_16B_list[0x10+ 8:0x10+12] = [int(vv) for vv in EEPROM_GAR_txt.split('.')]
	mem_data_4_16B_list[0x10+12:0x10+16] = [int(vv) for vv in EEPROM_DNS_txt.split('.')]
	
	mem_data_4_16B_list[0x20+ 0:0x20+12] = conv_txt_to_mem_list(EEPROM_MAC_txt,12)
	mem_data_4_16B_list[0x20+12:0x20+14] = conv_txt_to_mem_list(EEPROM_SlotID_txt,2)
	mem_data_4_16B_list[0x20+14]         = int(EEPROM_UserID_txt)
	mem_data_4_16B_list[0x20+15]         = int(EEPROM_CKS_txt)
	
	# rewrite SIP and MAC 
	#// note CMU base ip  : 192.168.100.16, 192.168.100.80,  192.168.168.80
	#// note CMU base MAC : "0008DC00AB00"
	#
	#// note PGU base ip  : 192.168.100.48, 192.168.100.112, 192.168.168.112
	#// note PGU base MAC : "0008DC00CD00"
	#
	#EEPROM_SlotID_txt
	#EEPROM_SIP_txt
	#EEPROM_MAC_txt
	EEPROM_SIP_base_txt = '192.168.100.112'
	EEPROM_MAC_base_txt = '0008DC00CD00'
	
	SlotID = int(EEPROM_SlotID_txt)
	print('{} = {}'.format('SlotID',SlotID))
	
	if SlotID!=99:
		print('>>> rewrite SPI and MAC!!')
		# update SIP
		mem_data_4_16B_list[0x10+ 0:0x10+ 4] = [int(vv) for vv in EEPROM_SIP_base_txt.split('.')]
		mem_data_4_16B_list[0x10+ 3] += SlotID
		mem_data_4_16B_list[0x10+ 3] = mem_data_4_16B_list[0x10+ 3]&0xFF
		# update MAC
		last_MAC_txt = EEPROM_MAC_base_txt[10:12] 
		print(last_MAC_txt)
		last_MAC = int(last_MAC_txt,16) + SlotID
		last_MAC = last_MAC&0xFF
		EEPROM_MAC_base_txt = EEPROM_MAC_base_txt[0:10] + '{:02X}'.format(last_MAC)
		mem_data_4_16B_list[0x20+ 0:0x20+12] = conv_txt_to_mem_list(EEPROM_MAC_base_txt,12)
		pass
	
	# re-calculate checksum
	mem_data_4_16B_list[0x2F] = pgu.gen_checksum(mem_data_4_16B_list[0x10:0x2F]) # update zero checksum CKS
	print(mem_data_4_16B_list[0x2F])
	print(pgu.cal_checksum(mem_data_4_16B_list[0x10:0x30]))
	
	mem_data_4_16B_list[0x30   :0x30+16] = conv_txt_to_mem_list(EEPROM_USER_txt,16)
	
	#print(EEPROM_USER_txt)
	#print(type(tmp_mem_list))
	#print(tmp_mem_list)
	#print(mem_data_4_16B_list[0x30   :0x30+16])
	#print(mem_data_4_16B_list)
		
	output_display = pgu.hex_txt_display(mem_data_4_16B_list)
	print(output_display)
	
	
	global g_eeprom_not_found
	
	if g_eeprom_not_found==1:
		# no fuse 
		return
	
	# fuse eeprom
	pgu.eeprom_write_data(dev, EP_ADRS,  
		ADRS_b16=0x0000, num_bytes_DAT_b16=16*4, buf_datain_b8_list=mem_data_4_16B_list)
	
	# reload 
	master_bb_read_eeprom()
	
	pass


def master_bb_fuse_eeprom_zeros():
	pgu.eeprom_erase_all(dev, EP_ADRS)
	pass
	
def master_bb_fuse_eeprom_ones ():
	pgu.eeprom_set_all(dev, EP_ADRS)
	pass



#### TODO: tk_win_setup()
def tk_win_setup():

	global master
	
	#### master ####
	
	## title lines
	row_title = 0
	Label(master, text="== PGU-CPU controls : == ").grid(row=row_title, column= 0, sticky=W, columnspan = 4)
	
	
	## ee for wireout registers 
	Label(master, text=" FPGA_IMG# =").grid(row=row_title+1+1, column=0, sticky=E) 
	Label(master, text=" TEST_FLAG =").grid(row=row_title+1+2, column=0, sticky=E) 
	Label(master, text=" MON_XADC  =").grid(row=row_title+1+3, column=0, sticky=E) 
	ee_FPGA_IMAGE_ID_                 .grid(row=row_title+1+1, column=1)
	ee_TEST_FLAG_____                 .grid(row=row_title+1+2, column=1)
	ee_MON_XADC______                 .grid(row=row_title+1+3, column=1)
	#
	Label(master, text=" temp[C]   =").grid(row=row_title+1+3, column=2, sticky=E)
	ee_temp_fpga_____                 .grid(row=row_title+1+3, column=3)
		
	## update button for wireout registers
	Button(master, text='update board status', command=master_bb_update_board_status_wo) \
	                                  .grid(row=row_title+1+4, column=0, sticky=W+E, pady=4, columnspan = 4)
	
	
	## tt for LAN stuffs
	Label(master, text=" IP_ADRS =").grid(row=row_title+1+5, column=0, sticky=E) 
	Label(master, text=" RSP_IDN =").grid(row=row_title+1+6, column=0, sticky=E) 
	tt_IP_ADRS                      .grid(row=row_title+1+5, column=1, columnspan = 3)
	tt_RSP_IDN                      .grid(row=row_title+1+6, column=1, columnspan = 3)

	Button(master, text='update LAN status', command=master_bb_update_lan_status) \
	                                .grid(row=row_title+1+7, column=0, sticky=W+E, pady=4, columnspan = 4)

	
	## tt for EEPROM 
	Label(master, text=" EEPROM HDR =").grid(row=row_title+1+ 0, column=6, sticky=E) 
	Label(master, text=" EEPROM LOC =").grid(row=row_title+1+ 1, column=6, sticky=E) 
	Label(master, text=" === decode and values to fuse ===").grid(row=row_title+1+ 2, column=6, sticky=W+E, columnspan = 2) 
	Label(master, text=" INFO      =")   .grid(row=row_title+1+ 3, column=6, sticky=E) 
	Label(master, text=" BoardID   =")   .grid(row=row_title+1+ 4, column=6, sticky=E) 
	Label(master, text=" SIP(*)    =")   .grid(row=row_title+1+ 5, column=6, sticky=E) 
	Label(master, text=" SUB       =")   .grid(row=row_title+1+ 6, column=6, sticky=E) 
	Label(master, text=" GAR       =")   .grid(row=row_title+1+ 7, column=6, sticky=E) 
	Label(master, text=" DNS       =")   .grid(row=row_title+1+ 8, column=6, sticky=E) 
	Label(master, text=" MAC(*)    =")   .grid(row=row_title+1+ 9, column=6, sticky=E) 
	Label(master, text=" SlotID(*) =")   .grid(row=row_title+1+10, column=6, sticky=E) 
	Label(master, text=" UserID    =")   .grid(row=row_title+1+11, column=6, sticky=E) 
	Label(master, text=" CKS(**)   =")   .grid(row=row_title+1+12, column=6, sticky=E) 
	Label(master, text=" USER_TXT  =")   .grid(row=row_title+1+13, column=6, sticky=E) 
	Label(master, text="Note (*) : SIP and MAC are selected automatically by SlotID, as long as SlotID is not 99.").grid(row=row_title+1+14, column=6, sticky=W, columnspan = 2) 
	Label(master, text="Note (**): checksum byte is re-determined during fusing.").grid(row=row_title+1+15, column=6, sticky=W, columnspan = 2) 
	
	tt_EEPROM_HEADER                   .grid(row=row_title+1+ 0, column=7, sticky=W)
	tt_EEPROM_LOC                      .grid(row=row_title+1+ 1, column=7, sticky=W)
	#
	tt_EEPROM_INFO_txt                 .grid(row=row_title+1+ 3, column=7, sticky=W) 
	tt_EEPROM_BoardID_txt              .grid(row=row_title+1+ 4, column=7, sticky=W) 
	tt_EEPROM_SIP_txt                  .grid(row=row_title+1+ 5, column=7, sticky=W) 
	tt_EEPROM_SUB_txt                  .grid(row=row_title+1+ 6, column=7, sticky=W) 
	tt_EEPROM_GAR_txt                  .grid(row=row_title+1+ 7, column=7, sticky=W) 
	tt_EEPROM_DNS_txt                  .grid(row=row_title+1+ 8, column=7, sticky=W) 
	tt_EEPROM_MAC_txt                  .grid(row=row_title+1+ 9, column=7, sticky=W) 
	tt_EEPROM_SlotID_txt               .grid(row=row_title+1+10, column=7, sticky=W) 
	tt_EEPROM_UserID_txt               .grid(row=row_title+1+11, column=7, sticky=W) 
	tt_EEPROM_CKS_txt                  .grid(row=row_title+1+12, column=7, sticky=W) 
	tt_EEPROM_USER_txt                 .grid(row=row_title+1+13, column=7, sticky=W) 
	
	Button(master, text='read EEPROM', command=master_bb_read_eeprom) .grid(row=50, column=6, sticky=W+E, pady=4, columnspan = 2)
	Button(master, text='fuse EEPROM with User Data', command=master_bb_fuse_eeprom)   .grid(row=51, column=6, sticky=W+E, pady=4, columnspan = 2)
	Button(master, text='fuse EEPROM with zeros', command=master_bb_fuse_eeprom_zeros) .grid(row=52, column=6, sticky=W+E, pady=4, columnspan = 2)
	Button(master, text='fuse EEPROM with ones',  command=master_bb_fuse_eeprom_ones ) .grid(row=53, column=6, sticky=W+E, pady=4, columnspan = 2)
	
	## buttons common 
	# quit
	bb_quit = Button(master, text='Quit', command=master.quit) .grid(row=100,  sticky=W+E, pady=4, columnspan = 8)


	##################
	
	
	
	
	return



##############################################



if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	
	#txt = 'test'
	#mem_list = conv_txt_to_mem_list(txt)
	#print(mem_list)
	
	#master_bb_fuse_eeprom()
	
	#input('')
	
	#
	print('>>> eeprom writer')

	####
	## TODO: test ip setup
	#_host_,_port_ = eps.set_host_ip_by_ping()
	
	##_host_ = '192.168.168.143' # dd
	
	# 0xD -- 192.168.100.61 // S3100-PGU_BD01 
	# 0xE -- 192.168.100.62 // S3100-PGU_BD02 
	# 0xF -- 192.168.100.62 // S3100-PGU_BD02 
	##_host_ = '192.168.100.61' # bd 1
	_host_ = '192.168.100.62' # bd 2
	##_host_ = '192.168.100.63' # bd 3
	

	# 0x3 -- 192.168.100.115 //s3dv1
	# 0x4 -- 192.168.100.116 //s3dv2 --> 119
	# 0x5 -- 192.168.100.117 //s3dv3 --> 120
	
	#_host_ = '192.168.100.115'
	#_host_ = '192.168.100.117'
	
	#_host_ = '192.168.168.84'
	#_host_ = '192.168.100.90' # t3ss 
	#_host_ = '192.168.100.95'	
	#_host_ = '192.168.100.84' ## yy
	
	##_host_ = '192.168.100.116' ## s3dv2
	
	#_host_ = '192.168.100.120' ## lab test 
	#_host_ = '192.168.100.87' ##jj
	
	##_host_ = '192.168.100.127' # PGU test

	_port_ = 5025
	print(_host_)
	print(_port_)
	
	####
	## open socket and connect
	ss = dev.Open(_host_,_port_) 
	
	##  ####
	##  ## flag check max retry count
	##  MAX_CNT = 50
	##  ##MAX_CNT = 500 # 20000 # 280 for 192000 samples
	##  #MAX_CNT = 5000 # 1500 for 25600 samples @ 12500 count period	
	##  
	##  ## check open 
	##  if dev.IsOpen():
	##  	print('>>> device opened.')
	##  else:
	##  	print('>>> device is not open.')
	##  	## raise
	##  	input('')
	##  	MAX_CNT = 3	
	
	
	## get serial from board 
	ret = dev.GetSerialNumber()
	print(ret)
	
	
	
	####
	## read fpga_image_id
	dev.UpdateWireOuts()
	fpga_image_id = dev.GetWireOutValue(EP_ADRS['FPGA_IMAGE_ID'])
	#
	print(_form_hex_32b_(fpga_image_id))
	
	####
	## read FPGA internal temp and volt
	dev.UpdateWireOuts()
	ret = dev.GetWireOutValue(EP_ADRS['XADC_TEMP'])  
	print(ret)


	########
	# TEST on
	
	####
	## test counter on 
	ret = pgu.test_counter(dev, EP_ADRS, 'ON')
	print(ret)
	
	
	
	##############################################
	# TODO: test board control
	
	##  # BRD_CON[0]  = hw reset
	##  # BRD_CON[16] = timestamp disp en
	##  print('\n>> {}'.format('test hw reset'))
	##  dev.SetWireInValue(EP_ADRS['BRD_CON'],0x00000001,0x00010001) # (ep,val,mask)
	##  dev.UpdateWireIns()
	##  
	##  ###
	##  #input('ENTER key')
	##  
	##  print('\n>> {}'.format('test timestamp disp en'))
	##  dev.SetWireInValue(EP_ADRS['BRD_CON'],0x00010000,0x00010001) # (ep,val,mask)
	##  dev.UpdateWireIns()
	##  #
	##  time_stamp = []
	##  #
	##  dev.UpdateWireOuts()
	##  time_stamp += [dev.GetWireOutValue(EP_ADRS['TIME_STAMP'])]
	##  print('{} = {}'.format('time_stamp',time_stamp))
	##  #
	##  dev.UpdateWireOuts()
	##  time_stamp += [dev.GetWireOutValue(EP_ADRS['TIME_STAMP'])]
	##  print('{} = {}'.format('time_stamp',time_stamp))
	##  #
	##  dev.UpdateWireOuts()
	##  time_stamp += [dev.GetWireOutValue(EP_ADRS['TIME_STAMP'])]
	##  print('{} = {}'.format('time_stamp',time_stamp))
	##  #
	##  time_stamp_diff = [zz[0]-zz[1] for zz in zip(time_stamp[1:], time_stamp[0:-1])]
	##  print('{} = {}'.format('time_stamp_diff',time_stamp_diff))
	##  
	##  # convert time based on 10MHz or 100ns or 0.1us
	##  print('{} = {}'.format('time_stamp_diff_us',[xx*0.1 for xx in time_stamp_diff]))
	##  print('{} = {}'.format('time_stamp_diff_ms',[xx*0.1*0.001 for xx in time_stamp_diff]))
	##  
	##  ###
	##  #input('ENTER key')
	##  
	##  print('\n>> {}'.format('test clear all'))
	##  dev.SetWireInValue(EP_ADRS['BRD_CON'],0x00000000,0x00010001) # (ep,val,mask)
	##  dev.UpdateWireIns()
	##  
	##  ###
	##  #input('ENTER key')
	
	

	
	#############################################


	
	
	########
	# TODO: EEPROM 
		
	## find EEPROM on board or TP
	
	# set BASE board access
	pgu.eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=1,  EEPROM__on_TP_b8=0)
	chk_eeprom_base = pgu.is_eeprom_available(dev, EP_ADRS)
	print('>>>>>> {} = {}'.format('chk_eeprom_base',chk_eeprom_base))
	
	# set TP access
	pgu.eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=1,  EEPROM__on_TP_b8=1)
	chk_eeprom_tp   = pgu.is_eeprom_available(dev, EP_ADRS)
	print('>>>>>> {} = {}'.format('chk_eeprom_tp',chk_eeprom_tp))
	
	
	if   chk_eeprom_base:
		pgu.eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=1,  EEPROM__on_TP_b8=0)
		g_eeprom_loc = 'BASE'
		g_eeprom_not_found = 0
	elif chk_eeprom_tp:
		pgu.eeprom_set_g_var (dev, EP_ADRS,  EEPROM__LAN_access_b8=1,  EEPROM__on_TP_b8=1)
		g_eeprom_loc = 'TP'
		g_eeprom_not_found = 0
	else :
		print('>>>>>>>> Note: eeprom is not available!')
		g_eeprom_loc = ''
		g_eeprom_not_found = 1
	
	#input('')
	
	#############################################


	#######
	# TODO: GUI setup 
	
	print('>>> tk GUI control')
		
	# titles 
	master  .wm_title('PGU-CPU board')


	#### window locations and sizes ####
	master  .geometry('1310x690+0+0')
	
	
	#### call windows setup ####
	tk_win_setup()
	
	## update status 
	master_bb_update_board_status_wo()
	master_bb_update_lan_status()
	master_bb_read_eeprom()

	
	#### main loop for gui : until quit() ####
	mainloop() 
	
	#############################################
	
	
	
	
	########
	
	####
	#input('> press Enter ...')
	####
	
	
	####
	# work above!
	####
	
	
	
	###############################
	## finish test
	###############################
	
	
	

	
	
	########
	# TEST off
	
	####
	## test counter off
	ret = pgu.test_counter(dev, EP_ADRS,'OFF')
	print(ret)
	####
	
	####
	## test counter reset
	ret = pgu.test_counter(dev, EP_ADRS,'RESET')
	print(ret)
	####
	
	
	########
	## close socket
	dev.Close()
	print('>>> device closed.')
	
	#############################################

	pass

