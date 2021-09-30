## plot__log__adc_buf.py
# plot data from log__adc_buf.py

## import info
# test_data_list
# adc_buf0_list_s32
# adc_buf1_list_s32
# adc_buf0_list_hex_str
# adc_buf1_list_hex_str
#

import log__adc_buf as adc_log
#import log__adc_buf__dac as adc_log

test_data_list        = adc_log.test_data # test
adc_buf0_list_s32     = adc_log.adc_buf0  # adc buf0
adc_buf1_list_s32     = adc_log.adc_buf1  # adc buf1
adc_buf0_list_hex_str = adc_log.adc_buf0_hex  # adc buf0 hex
adc_buf1_list_hex_str = adc_log.adc_buf1_hex  # adc buf1 hex
adc_buf0_list_flt     = adc_log.adc_buf0_flt  # adc buf0 float
adc_buf1_list_flt     = adc_log.adc_buf1_flt  # adc buf1 float


import matplotlib.pyplot as plt
##plt.ion() # matplotlib interactive mode

def plot_test():
	## data from outside
	# in global
	global test_data_list       
	global adc_buf0_list_s32    
	global adc_buf1_list_s32    
	global adc_buf0_list_hex_str
	global adc_buf1_list_hex_str	
	global adc_buf0_list_flt    
	global adc_buf1_list_flt    

	###

	print(">> length of test_data = {} ".format(len(test_data_list)))
	print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_s32 )))
	print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_s32 )))
	print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_hex_str )))
	print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_hex_str )))
	print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_flt )))
	print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_flt )))

	# plot 1 - overview
	FIG_NUM = 1
	plt.figure(FIG_NUM, figsize=(8, 6))
	
	title_str = 'adc0(red) and adc1(blue)'
	t_list = range(len(adc_buf0_list_s32))

	plt.plot(t_list, adc_buf0_list_s32, 'ro-', markersize=10)
	plt.plot(t_list, adc_buf1_list_s32, 'bs-', markersize=10, alpha=0.5)

	plt.title(title_str)
	plt.ylabel('adc_32bit_scale')
	plt.xlabel('data index')
	plt.grid(True)


	# plot 2 - voltages
	FIG_NUM = 2
	plt.figure(FIG_NUM, figsize=(8, 6))
	
	title_str = 'adc0(red) and adc1(blue)'
	t_list = range(len(adc_buf0_list_s32))

	plt.plot(t_list, adc_buf0_list_flt, 'ro-', markersize=10)
	plt.plot(t_list, adc_buf1_list_flt, 'bs-', markersize=10, alpha=0.5)

	plt.title(title_str)
	plt.ylabel('adc_voltage')
	plt.xlabel('data index')
	plt.grid(True)

	##
	plt.show()

#	# data
#	#t_list = [0,  1, 2 ] ## time
#	#y_list = [0, 40, 0 ] ## voltage
#	#c_list = [0,  0, 0 ] ## voltage incremental
#	
#	t_list = Tdata_usr
#	y_list = Vdata_usr
#	
#	# plot 1 - overview
#	FIG_NUM = 1
#	plt.figure(FIG_NUM, figsize=(8, 6))
#	
#	title_str = 'command waveform (red)'
#	title_str += ' vs DAT points (green, blue)'
#	
#	##title_str += '\n DAC update {}ns, Step duration {}ns'.format(time_ns__dac_update,time_ns__code_duration)
#	#title_str += '\n DAC update {}ns, {}'.format(time_ns__dac_update,'incremental coded')
#	#title_str += ', Full scale current {}mA'.format(DAC_full_scale_current__mA)
#	
#	
#	plt.plot(t_list,    y_list,     'ro-', markersize=10)
#	plt.plot(Tdata_cmd, Vdata_cmd,  'gs-',  markersize=5,  alpha=0.7)
#	plt.plot(Tdata_seg, Vdata_seg,  'bd',  markersize=10, alpha=0.5)
#	
#	# last point + duration 
#	plt.plot(Tdata_seg[-1]+Ddata_seg[-1], Vdata_seg[-1],  'k^',  markersize=12, alpha=0.7)
#	
#	plt.title(title_str)
#	plt.ylabel('Voltage')
#	plt.xlabel('Time(ns)')
#	plt.grid(True)
#	
#	# plot 2 - previous DUT
#	FIG_NUM = 2
#	plt.figure(FIG_NUM, figsize=(8, 6))
#	
#	title_str = 'command waveform (red)'
#	title_str += ' vs DAT points (previous command)'
#	
#	plt.plot(t_list,    y_list,    'ro-', markersize=10)
#	plt.plot(Tdata_cmd, Vdata_cmd, 'gs-',  markersize=5,  alpha=0.7)
#	
#	plt.title(title_str)
#	plt.ylabel('Voltage')
#	plt.xlabel('Time(ns)')
#	plt.grid(True)
#	
#	# plot 3 - new segment
#	FIG_NUM = 3
#	plt.figure(FIG_NUM, figsize=(8, 6))
#	
#	title_str = 'command waveform (red)'
#	title_str += ' vs DAT points (new segment style)'
#	
#	plt.plot(t_list,    y_list,     'ro-', markersize=10)
#	plt.plot(Tdata_seg, Vdata_seg,  'bd',  markersize=10, alpha=0.5)
#	
#	plt.title(title_str)
#	plt.ylabel('Voltage')
#	plt.xlabel('Time(ns)')
#	plt.grid(True)
#	
#	# plot 4 - repeat pattern 
#	
#	# repeat 2
#	Tdata_seg__rpt = Tdata_seg + [  xx+Tdata_seg[-1]+Ddata_seg[-1]  for xx in Tdata_seg ]
#	Vdata_seg__rpt = Vdata_seg + Vdata_seg
#	
#	t_list__rpt = t_list + [xx+t_list[-1] for xx in t_list]
#	y_list__rpt = y_list + y_list
#	
#	#print(">> Tdata_seg__rpt = {} ", Tdata_seg__rpt )
#	#print(">> Vdata_seg__rpt = {} ", Vdata_seg__rpt )
#	
#	FIG_NUM = 4
#	plt.figure(FIG_NUM, figsize=(8, 6))
#	
#	title_str = 'command waveform (red)'
#	title_str += ' vs DAT points (repeat pattern)'
#	
#	plt.plot(t_list__rpt,    y_list__rpt,     'ro-', markersize=10)
#	plt.plot(Tdata_seg__rpt, Vdata_seg__rpt,  'bd-',  markersize=5, alpha=0.5)
#	
#	plt.title(title_str)
#	plt.ylabel('Voltage')
#	plt.xlabel('Time(ns)')
#	plt.grid(True)
#	
#	##
#	plt.show()
	return


if __name__ == '__main__':
  if __debug__:
    print('>>>>>> In debug mode ... ')
    plot_test()

