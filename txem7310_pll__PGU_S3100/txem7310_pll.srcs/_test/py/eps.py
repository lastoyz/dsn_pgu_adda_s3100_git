## eps.py : support end-point system from LAN



###########################################################################
## TODO: LAN setup
###########################################################################

# common
from time import sleep

#



##  ###########################################################################
##  ## common converter
##  
##  def conv_dec_to_bit_2s_comp_16bit(dec, full_scale=20):
##  	if dec > full_scale/2-full_scale/2**16 :
##  		dec = full_scale/2-full_scale/2**16
##  	if dec < -full_scale/2-full_scale/2**16 :
##  		dec = -full_scale/2-full_scale/2**16
##  	#bit_2s_comp = int( 0x10000 * ( dec + full_scale/2)    / full_scale ) + 0x8000
##  	bit_2s_comp = int( 0x10000 * ( dec + full_scale/2)    / full_scale +0.5) + 0x8000
##  	if bit_2s_comp > 0xFFFF :
##  		bit_2s_comp -= 0x10000
##  	return bit_2s_comp
##  
##  #test_codes = [ conv_dec_to_bit_2s_comp_16bit(x) for x in [-10,-5,0,5,10] ]
##  #print(test_codes)
##  	
##  def conv_bit_2s_comp_16bit_to_dec(bit_2s_comp, full_scale=20):
##  	if bit_2s_comp >= 0x8000:
##  		bit_2s_comp -= 0x8000
##  		#dec = full_scale * (bit_2s_comp) / 0x10000 -10
##  		dec = full_scale * (bit_2s_comp) / 0x10000 - full_scale/2
##  	else :
##  		dec = full_scale * (bit_2s_comp) / 0x10000
##  		if dec == full_scale/2-full_scale/2**16 :
##  			dec = full_scale/2
##  	return dec
##  
##  #test_codes2 = [ conv_bit_2s_comp_16bit_to_dec(x) for x in test_codes ]
##  #print(test_codes2)

	


###########################################################################
## LAN socket  ####################################################

import socket

## socket control parameters 

HOST = '192.168.168.143'  # The server's hostname or IP address
PORT = 5025               # The port used by the server
#
#TIMEOUT = 5.3 # socket timeout
TIMEOUT = 500 # socket timeout // for debug 
#TIMEOUT = 1000 # socket timeout // for debug 1000s
#
SO_SNDBUF = 2048
SO_RCVBUF = 32768
INTVAL = 0.1 # sec for waiting before recv()
BUF_SIZE_NORMAL = 2048
BUF_SIZE_LARGE = 16384
TIMEOUT_LARGE = TIMEOUT*10

ss = None # socket


## command strings ##############################################################
cmd_str__IDN      = b'*IDN?\n'
cmd_str__RST      = b'*RST\n'
cmd_str__EPS_EN   = b':EPS:EN'
cmd_str__EPS_WMI  = b':EPS:WMI'
cmd_str__EPS_WMO  = b':EPS:WMO'
cmd_str__EPS_TAC  = b':EPS:TAC'
cmd_str__EPS_TMO  = b':EPS:TMO' 
cmd_str__EPS_TWO  = b':EPS:TWO' ## new
cmd_str__EPS_PI   = b':EPS:PI'
cmd_str__EPS_PO   = b':EPS:PO'

##  cmd_str__EPS_MKWI = b':EPS:MKWI'
##  cmd_str__EPS_MKWO = b':EPS:MKWO'
##  cmd_str__EPS_MKTI = b':EPS:MKTI'
##  cmd_str__EPS_MKTO = b':EPS:MKTO'
##  cmd_str__EPS_WI   = b':EPS:WI'
##  cmd_str__EPS_WO   = b':EPS:WO'
##  cmd_str__EPS_TI   = b':EPS:TI'
##  cmd_str__EPS_TO   = b':EPS:TO'
#

## scpi functions ####################################################################

def scpi_open (timeout=TIMEOUT):
	try:
		ss = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		ss.settimeout(timeout)
		ss.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, SO_SNDBUF)
		ss.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, SO_RCVBUF) # 8192 16384 32768 65536
	except OSError as msg:
		ss = None
		print('error in socket: ', msg)
		raise
	return ss

def scpi_connect (ss, HOST, PORT):
	try:
		ss.connect((HOST, PORT))
	except OSError as msg:
		ss.close()
		ss = None
		print('error in connect: ', msg)
		raise


def scpi_close (ss):
	try:
		ss.close()
	except:
		if ss == None:
			print('error: ss==None')
		raise

def scpi_comm_resp_ss (ss, cmd_str, buf_size=BUF_SIZE_NORMAL, intval=INTVAL) :
	try:
		if __debug__:print('Send:', repr(cmd_str[:40]))
		ss.sendall(cmd_str)
	except:
		if __debug__:print('error in sendall')
		raise
	##
	sleep(intval)
	#
	# recv data until finding the sentinel '\n'
	try:
		data = ss.recv(buf_size) # try 1024 131072 524288
		# try   
		while (1):
			if (chr(data[-1])=='\n'): # check the sentinel '\n' 
				break
			data = data + ss.recv(buf_size)
	except:
		if __debug__:print('error in recv')
		raise
	#
	## check response 
	if (len(data)>20):
		if __debug__:print('Received:', repr(data[0:20]),  ' (first 20 bytes)')
	else:
		if __debug__:print('Received:', repr(data))
	#
	# NG response check 
	if data[0:2]==b'NG':
		if __debug__:print('Received: NG as response')
		#input('Press Enter key!')
		#sleep(3)
	#
	return data


# scpi command for numeric block response
def scpi_comm_resp_numb_ss (ss, cmd_str, buf_size=BUF_SIZE_LARGE, intval=INTVAL, timeout_large=TIMEOUT_LARGE) :
	try:
		if __debug__:print('Send:', repr(cmd_str))
		ss.sendall(cmd_str)
	except:
		if __debug__:print('error in sendall')
		raise
	##
	sleep(intval)
	#
	# cmd: ":PGEP:PO#HBC 524288\n"
	# rsp: "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
	#
	# recv data until finding the sentinel '\n' 
	# but check the sentinel after the data byte count is met.
	#
	# read timeout
	to = ss.gettimeout()
	#print(to)
	# increase timeout
	ss.settimeout(timeout_large)
	#
	try:
		# find the numeric head : must 10 in data 
		data = ss.recv(buf_size)
		while True:
			if len(data)>=10:
				break
			data = data + ss.recv(buf_size)
		#
		#print('header: ', repr(data[0:10])) # header
		#
		# find byte count 
		byte_count = int(data[3:9])
		#print('byte_count=', repr(byte_count)) 
		#
		# collect all data by byte count
		count_to_recv = byte_count + 10 + 1# add header count #add /n
		while True:
			if len(data)>=count_to_recv:
				break
			data = data + ss.recv(buf_size)
		#
		# check the sentinel 
		while True:
			if (chr(data[-1])=='\n'): # check the sentinel '\n' 
				break
			data = data + ss.recv(buf_size)
		#
	except:
		if __debug__:print('error in recv')
		raise
	#
	if (len(data)>20):
		if __debug__:print('Received:', repr(data[0:20]),  ' (first 20 bytes)')
	else:
		if __debug__:print('Received:', repr(data))
	#
	# timeout back to prev
	ss.settimeout(to)
	#
	data = data[10:(10+byte_count)]
	if __debug__:print('data:', data[0:20].hex(),  ' (first 20 bytes)')
	#
	return [byte_count, data]
	



###########################################################################
## TODO: EPS_Dev  class  

class EPS_Dev:
	dev_count = 0
	idn = []
	ss = None # socket
	#
	f_scpi_open = scpi_open
	f_scpi_connect = scpi_connect
	f_scpi_close = scpi_close
	f_scpi_cmd = scpi_comm_resp_ss
	f_scpi_cmd_numb = scpi_comm_resp_numb_ss
	#
	def _test(self):
		return '_class__EPS_Dev_'
	#
	def GetDeviceCount(self):
		# must update from ping ip ... or else 
		self.dev_count = 1
		return self.dev_count 
	#
	def Init(self):
		# NOP
		return
	def Reset(self):
		# 
		rsp = scpi_comm_resp_ss(self.ss, cmd_str__RST)
		return rsp
	def Open(self, hh=HOST, pp=PORT):
		##  # open scpi
		##  self.ss = LAN_CMU_Dev.f_scpi_open()		
		##  # connect scpi
		##  LAN_CMU_Dev.f_scpi_connect(self.ss,hh,pp)
		##  # board reset 
		##  ret = LAN_CMU_Dev.f_scpi_cmd(self.ss, cmd_str__RST).decode()
		##  # LAN end-point control enable
		##  ret = LAN_CMU_Dev.f_scpi_cmd(self.ss, cmd_str__CMEP_EN+b' ON\n').decode()
		##  return ret
		
		# open socket
		self.ss = EPS_Dev.f_scpi_open()
		try:
			print('>> try to connect : {}:{}'.format(hh,pp))
			EPS_Dev.f_scpi_connect(self.ss,hh,pp)
		except socket.timeout:
			self.ss = None
		except ConnectionRefusedError:
			self.ss = None
		except:
			raise
		
		# enable end-points control
		scpi_comm_resp_ss(self.ss, cmd_str__EPS_EN +b' ON\n')
		
		return self.ss
	#
	def IsOpen(self):
		if self.ss == None:
			ret = False
		else:
			ret = True
		return ret	
	#
	def GetSerialNumber(self):
		ret = EPS_Dev.f_scpi_cmd(self.ss, cmd_str__IDN).decode() # will revise
		return ret # must come from board later 
	def ConfigureFPGA(self, opt=[]):
		# not support
		pass
		return 0
	def GetErrorString(self, opt):
		# not support
		pass
		return []
	def Close(self):
		# disable end-points control
		scpi_comm_resp_ss(self.ss, cmd_str__EPS_EN +b' OFF\n')
		
		#
		ret = None
		# close scpi
		EPS_Dev.f_scpi_close(self.ss)
		self.ss = None
		return ret
	#
	def GetWireOutValue(self, adrs, mask=0xFFFFFFFF):
		# :EPS:WMO#Hnn  #Hmmmmmmmm<NL>
		cmd_str = cmd_str__EPS_WMO + ('#H{:02X} #H{:08X}\n'.format(adrs,mask)).encode()
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		#
		rsp = rsp_str.decode()
		# assume hex decimal response: #HF3190306<NL>
		rsp = '0x' + rsp[2:-1] # convert "#HF3190306<NL>" --> "0xF3190306"
		rsp = int(rsp,16) # convert hex into int
		return rsp
	def UpdateWireOuts(self):
		# no global update : nothing to do.
		pass
	def SetWireInValue(self, adrs, data, mask=0xFFFFFFFF):
		# :EPS:WMI#Hnn  #Hnnnnnnnn #Hmmmmmmmm<NL>
		cmd_str = cmd_str__EPS_WMI + ('#H{:02X} #H{:08X} #H{:08X}\n'.format(adrs,data,mask)).encode()
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		#
		rsp = rsp_str.decode()
		return rsp
	def UpdateWireIns(self):
		# no global update : nothing to do.
		pass
	#
	def ActivateTriggerIn(self, adrs, loc_bit):
		## activate trig 
		# :EPS:TAC#Hnn  #Hnn<NL>
		#
		cmd_str = cmd_str__EPS_TAC + ('#H{:02X} #H{:02X}\n'.format(adrs,loc_bit)).encode()
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		rsp = rsp_str.decode()
		return rsp
	#
	def UpdateTriggerOuts(self) :
		# no global update : nothing to do.
		pass
	#
	def IsTriggered (self, adrs, mask):
		# cmd: ":EPS:TMO#H60 #H0000FFFF\n"
		# rsp: "ON\n" or "OFF\n"
		cmd_str = cmd_str__EPS_TMO + ('#H{:02X} #H{:08X}\n'.format(adrs,mask)).encode()
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		#
		rsp = rsp_str.decode()
		#
		if rsp[0:3]=='OFF':
			ret =  False
		elif rsp[0:2]=='ON':
			ret =  True
		else:
			ret =  None
		#
		return ret
	#
	def GetTriggerOutVector(self, adrs, mask=0xFFFFFFFF):
		# cmd: ":EPS:TWO#H60 #H0000FFFF\n"
		# rsp: "#H000O3245\n" 
		cmd_str = cmd_str__EPS_TWO + ('#H{:02X} #H{:08X}\n'.format(adrs,mask)).encode()
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		#
		rsp = rsp_str.decode()
		# assume hex decimal response: #HF3190306<NL>
		rsp = '0x' + rsp[2:-1] # convert "#HF3190306<NL>" --> "0xF3190306"
		rsp = int(rsp,16) # convert hex into int
		return rsp
	#
	def ReadFromPipeOut(self, adrs, data_bytearray):
		## read pipeout
		# cmd: ":EPS:PO#HAA 001024\n"
		# rsp: "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"		
		#
		byte_count = len(data_bytearray)
		#
		cmd_str = cmd_str__EPS_PO + ('#H{:02X} {:06d}\n'.format(adrs,byte_count)).encode()
		if __debug__:print(cmd_str)
		#
		[rsp_cnt, rsp_str] = EPS_Dev.f_scpi_cmd_numb(self.ss, cmd_str)
		#
		# assume numeric block : "#4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
		# assume rsp_str is data part.
		# copy data 
		for ii in range(0,rsp_cnt): 
			data_bytearray[ii] = rsp_str[ii]
		#
		return rsp_cnt

	def WriteToPipeIn(self, adrs, data_bytearray):
		## write pipein
		# cmd: ":EPS:PI#H8A #4_001024_rrrrrrrrrr...rrrrrrrrrr\n"
		# rsp: "OK\n"		
		
		# check later : byte_count is multiple of 4 
		
		#
		byte_count = len(data_bytearray)
		#
		#cmd_str = cmd_str__EPS_PI + ('#H{:02X} #4_{:06d}_{}\n'.format(adrs,byte_count,data_bytearray)).encode() # NG
		cmd_str = cmd_str__EPS_PI + ('#H{:02X} #4_{:06d}_'.format(adrs,byte_count)).encode() + data_bytearray + b'\n'
		if __debug__:print(cmd_str[:30])
		
		rsp_str = EPS_Dev.f_scpi_cmd(self.ss, cmd_str)
		
		rsp = rsp_str.decode() # OK or NG
		
		#
		return rsp

	## composite function for spi test
	def _test__send_spi_frame(self, data_C, data_A, data_D, enable_CS_bits = 0x00001FFF):
		## set spi frame data
		#data_C = 0x10   ##// for read 
		#data_A = 0x380  ##// for address of known pattern  0x_33AA_CC55
		#data_D = 0x0000 ##// for reading (XXXX)
		MSPI_CON_WI = (data_C<<26) + (data_A<<16) + data_D
		EPS_Dev.SetWireInValue(self,0x17, MSPI_CON_WI)

		## set spi enable signals
		MSPI_EN_CS_WI = enable_CS_bits
		EPS_Dev.SetWireInValue(self,0x16, MSPI_EN_CS_WI)

		## frame 
		EPS_Dev.ActivateTriggerIn(self,0x42, 2) # frame_trig
		cnt_loop = 0
		while True:
			ret=EPS_Dev.IsTriggered(self,0x62,0x00000004) # frame_done ## rev 0x00000002 --> 0x00000004
			cnt_loop += 1
			if ret:
				print('frame done !! @ ' + repr(cnt_loop))
				break
			
		#GetWireOutValue
		ret=EPS_Dev.GetWireOutValue(self,0x24)
		data_B = ret & 0xFFFF
		print('0x{:08X}'.format(data_B))

		return data_B		

###########################################################################
###########################################################################


###########################################################################
## load shell parameters for IP 

# example command in shell: 
#    python test__MHVSU_BASE__lan.py  192.168.168.143  5025
#    slot id -- default ip address 
#    0x0     -- 192.168.168.128
#    0x1     -- 192.168.168.129
#    0x2     -- 192.168.168.130
#    0x3     -- 192.168.168.131
#    0x4     -- 192.168.168.132
#    0x5     -- 192.168.168.133
#    0x6     -- 192.168.168.134
#    0x7     -- 192.168.168.135
#    0x8     -- 192.168.168.136
#    0x9     -- 192.168.168.137
#    0xA     -- 192.168.168.138
#    0xB     -- 192.168.168.139
#    0xC     -- 192.168.168.140
#    0xE     -- 192.168.168.141
#    0xD     -- 192.168.168.142
#    0xF     -- 192.168.168.143 (slot id is not detected)
_host_ips__MHVSU = [	
	'192.168.168.128',
	'192.168.168.129',
	'192.168.168.130',
	'192.168.168.131',
	'192.168.168.132',
	'192.168.168.133',
	'192.168.168.134',
	'192.168.168.135',
	'192.168.168.136',
	'192.168.168.137',
	'192.168.168.138',
	'192.168.168.139',
	'192.168.168.140',
	'192.168.168.141',
	'192.168.168.142',
	'192.168.168.143']

# CMU ips :
# 0x0 -- 192.168.168.80
# 0x1 -- 192.168.168.81
# 0x2 -- 192.168.168.82
# 0x3 -- 192.168.168.83
# 0x4 -- 192.168.168.84
# 0x5 -- 192.168.168.85
# 0x6 -- 192.168.168.86
# 0x7 -- 192.168.168.87
# 0x8 -- 192.168.168.88
# 0x9 -- 192.168.168.89
# 0xA -- 192.168.168.90
# 0xB -- 192.168.168.91
# 0xC -- 192.168.168.92
# 0xE -- 192.168.168.93
# 0xD -- 192.168.168.94
# 0xF -- 192.168.168.95
# missing info - '192.168.168.143'
_host_ips__CMU = [	
	'192.168.100.80',
	'192.168.100.81',
	'192.168.100.82',
	'192.168.100.83',
	'192.168.100.84',
	'192.168.100.85',
	'192.168.100.86',
	'192.168.100.87',
	'192.168.100.88',
	'192.168.100.89',
	'192.168.100.90',
	'192.168.100.91',
	'192.168.100.92',
	'192.168.100.93',
	'192.168.100.94',
	'192.168.100.95',
	'192.168.168.80',
	'192.168.168.81',
	'192.168.168.82',
	'192.168.168.83',
	'192.168.168.84',
	'192.168.168.85',
	'192.168.168.86',
	'192.168.168.87',
	'192.168.168.88',
	'192.168.168.89',
	'192.168.168.90',
	'192.168.168.91',
	'192.168.168.92',
	'192.168.168.93',
	'192.168.168.94',
	'192.168.168.95',
	'192.168.168.143']
# PGU ips
# 0x0 -- 192.168.168.112
# 0x1 -- 192.168.168.113
# 0x2 -- 192.168.168.114
# 0x3 -- 192.168.168.115
# 0x4 -- 192.168.168.116
# 0x5 -- 192.168.168.117
# 0x6 -- 192.168.168.118
# 0x7 -- 192.168.168.119 // test ip
# 0x8 -- 192.168.168.120
# 0x9 -- 192.168.168.121
# 0xA -- 192.168.168.122 // dev1
# 0xB -- 192.168.168.123 // dev1
# 0xC -- 192.168.168.124 // dev1
# 0xE -- 192.168.168.125
# 0xD -- 192.168.168.126
# 0xF -- 192.168.168.127
# missing info - '192.168.168.143'
_host_ips__PGU = [	
	'192.168.168.112',
	'192.168.168.113',
	'192.168.168.114',
	'192.168.168.115',
	'192.168.168.116',
	'192.168.168.117',
	'192.168.168.118',
	'192.168.168.119',
	'192.168.168.120',
	'192.168.168.121',
	'192.168.168.122',
	'192.168.168.123',
	'192.168.168.124',
	'192.168.168.125',
	'192.168.168.126',
	'192.168.168.127',
	'192.168.168.143']

#_host_ips_ = _host_ips__MHVSU
_host_ips_ = _host_ips__CMU
#_host_ips_ = _host_ips__PGU

###########################################################################
### ping ###

import sys
import platform    # For getting the operating system name
import subprocess  # For executing a shell command


def ping(host):
	"""
	Returns True if host (str) responds to a ping request.
	Remember that a host may not respond to a ping (ICMP) request even if the host name is valid.
	"""
	
	# Option for the number of packets as a function of
	param1 = '-n' if platform.system().lower()=='windows' else '-c'
	param2 = '-w' if platform.system().lower()=='windows' else '-i'
	value2 = '50' if platform.system().lower()=='windows' else '0.05'
	
	# Building the command. Ex: "ping -c 1 google.com"
	command = ['ping', param1, '1', param2, value2, host]
	
	return subprocess.call(command) == 0


def set_host_ip_by_ping():
	if __debug__: print(sys.argv[0])
	
	argc=len(sys.argv)
	
	if __debug__: print(argc)
	
	_host_ = None
	_port_ = None
	
	#
	if argc>1:
		_host_                    = sys.argv[1]         # ex: 192.168.168.143
	else:
		#_host_                    = '192.168.168.143'
		for xx in _host_ips_:
			if ping(xx):
				_host_ = xx
				if __debug__: print('{} is available.'.format(xx))
				break 
			else:
				if __debug__: print('{} is NOT available.'.format(xx))
	#
	if argc>2:
		_port_                    = int  (sys.argv[2])  # ex: 5025
	else:
		_port_                    = 5025
	#
	
	#
	return _host_,_port_


###########################################################################
# TODO: test function



def eps_test():
	print('#################################################')

	## class init
	dev = EPS_Dev()
	
	## class test
	print(dev._test())	
	
	## TODO: test ip 
	#_host_,_port_ = set_host_ip_by_ping()
	
	#_host_ = '192.168.100.127' # PGU test
	#_host_ = '192.168.168.143' # test
	_host_ = '192.168.100.77'  # S3100-CPU-BASE BD1

	#
	_port_ = 5025

	#
	print(_host_)
	print(_port_)
	
	## open socket and connect ##
	ss = dev.Open(_host_,_port_) 


	## flag check max retry count
	#MAX_count = 50
	##MAX_count = 500 # 20000 # 280 for 192000 samples
	#MAX_count = 5000 # 1500 for 25600 samples @ 12500 count period	
	
	## check open 
	if dev.IsOpen():
		print('>>> device opened.')
	else:
		print('>>> device is not open.')
		## raise
		input('')
		#MAX_count = 3	
	
	
	### scpi : *IDN?
	print('\n>>> {} : {}'.format('Test',cmd_str__IDN))
	rsp = scpi_comm_resp_ss(ss, cmd_str__IDN)
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))
	
	# alternative 
	ret = dev.GetSerialNumber()
	print(ret)
	
	### scpi : *RST
	print('\n>>> {} : {}'.format('Test',cmd_str__RST))
	rsp = scpi_comm_resp_ss(ss, cmd_str__RST)
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))
	
	# alternative 
	dev.Reset()
	
	### scpi : ":EPS:EN?\n"
	print('\n>>> {} : {}'.format('Test',cmd_str__EPS_EN))
	rsp = scpi_comm_resp_ss(ss, cmd_str__EPS_EN +b'?\n')
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))
	

	##---- EPS ON test ----##
	
	### scpi : ":EPS:EN ON\n"
	print('\n>>> {} : {}'.format('Test',cmd_str__EPS_EN))
	rsp = scpi_comm_resp_ss(ss, cmd_str__EPS_EN +b' ON\n')
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))
		
	### scpi : ":EPS:WMO#H20 #HFFFFFFFF\n"
	# read fpga ID through PORT EP
	#   ADRS_PORT_WO_20 : ":EPS:WMO#H20 #HFFFFFFFF\n"
	print('\n>>> {} : {}'.format('Test',cmd_str__EPS_WMO))
	rsp = scpi_comm_resp_ss(ss, cmd_str__EPS_WMO +b'#H20 #HFFFFFFFF\n')
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))

	# alternative 
	dev.UpdateWireOuts()
	ret=dev.GetWireOutValue(0x20)
	print('0x{:08X}'.format(ret))
	
	##---- EPS  trigger test ----##
	print('\n>>> {} : {}'.format('Test','EPS triggers'))

	##// MSPI_TI : ep42trig
	##//   bit[0] = reset_trig 
	##//   bit[1] = init_trig
	##//   bit[2] = frame_trig
	##//
	##// MSPI_TO : ep62trig
	##//   bit[0] = reset_done
	##//   bit[1] = init_done
	##//   bit[2] = frame_done
	##//
	##// MSPI_EN_CS_WI : ep16wire
	##//  bit[0 ] = enable SPI_nCS0  
	##//  bit[1 ] = enable SPI_nCS1  
	##//  bit[2 ] = enable SPI_nCS2  
	##//  bit[3 ] = enable SPI_nCS3  
	##//  bit[4 ] = enable SPI_nCS4  
	##//  bit[5 ] = enable SPI_nCS5  
	##//  bit[6 ] = enable SPI_nCS6  
	##//  bit[7 ] = enable SPI_nCS7  
	##//  bit[8 ] = enable SPI_nCS8  
	##//  bit[9 ] = enable SPI_nCS9  
	##//  bit[10] = enable SPI_nCS10 
	##//  bit[11] = enable SPI_nCS11 
	##//  bit[12] = enable SPI_nCS12 
	##//
	##// MSPI_CON_WI : ep17wire
	##//  bit[31:26] = data_C // control[5:0]
	##//  bit[25:16] = data_A // address[9:0]
	##//  bit[15: 0] = data_D // MOSI data[15:0]
	##//
	##// MSPI_FLAG_WO : ep24wire
	##//  bit[23]   = TEST_mode_en
	##//  bit[15:0] = data_B // MISO data[15:0]	
	

	## reset 
	dev.ActivateTriggerIn(0x42, 0) # reset_trig
	cnt_loop = 0
	while True:
		ret=dev.IsTriggered(0x62,0x00000001) # reset_done
		cnt_loop += 1
		if ret:
			print('reset done !! @ ' + repr(cnt_loop))
			break
	
	## init 
	dev.ActivateTriggerIn(0x42, 1) # init_trig
	cnt_loop = 0
	while True:
		ret=dev.IsTriggered(0x62,0x00000002) # init_done
		cnt_loop += 1
		if ret:
			print('init done !! @ ' + repr(cnt_loop))
			break

	
	## set CS enable bits 
	enable_CS_bits = 0x000013CA
	
	## set spi frame data @ address 0x380
	data_C = 0x10   ##// control data 6bit for read 
	data_A = 0x380  ##// address data 10bit for address of known pattern  0x_33AA_CC55
	data_D = 0x0000 ##// MOSI data 16bit for reading (XXXX)

	data_B = dev._test__send_spi_frame(data_C, data_A, data_D, enable_CS_bits) ##// return MISO data

	print('{} = 0x{:02X}'.format('data_C', data_C))
	print('{} = 0x{:03X}'.format('data_A', data_A))
	print('{} = 0x{:04X}'.format('data_D', data_D))
	print('{} = 0x{:04X}'.format('data_B', data_B))


	## set spi frame data @ address 0x382
	data_C = 0x10   ##// control data 6bit for read 
	data_A = 0x382  ##// address data 10bit for address of known pattern  0x_33AA_CC55
	data_D = 0x0000 ##// MOSI data 16bit for reading (XXXX)

	data_B = dev._test__send_spi_frame(data_C, data_A, data_D, enable_CS_bits) ##// return MISO data

	print('{} = 0x{:02X}'.format('data_C', data_C))
	print('{} = 0x{:03X}'.format('data_A', data_A))
	print('{} = 0x{:04X}'.format('data_D', data_D))
	print('{} = 0x{:04X}'.format('data_B', data_B))


	##---- EPS OFF test ----##
	
	### scpi : ":EPS:EN OFF\n"
	print('\n>>> {} : {}'.format('Test',cmd_str__EPS_EN))
	rsp = scpi_comm_resp_ss(ss, cmd_str__EPS_EN +b' OFF\n')
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))
		
	### scpi : ":EPS:WMO#H20 #HFFFFFFFF\n"
	# read fpga ID through PORT EP
	#   ADRS_PORT_WO_20 : ":EPS:WMO#H20 #HFFFFFFFF\n"
	print('\n>>> {} : {}'.format('Test',cmd_str__EPS_WMO))
	rsp = scpi_comm_resp_ss(ss, cmd_str__EPS_WMO +b'#H20 #HFFFFFFFF\n')
	#print('hex code rcvd: ' + rsp.hex())
	print('string rcvd: ' + repr(rsp))

	# alternative 
	dev.UpdateWireOuts()
	ret=dev.GetWireOutValue(0x20)
	print('0x{:08X}'.format(ret))
	
	## close socket ##
	dev.Close()
	print('>>> device closed.')
	print('#################################################')

	#
	return


###########################################################################
# test lib

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	eps_test()
	