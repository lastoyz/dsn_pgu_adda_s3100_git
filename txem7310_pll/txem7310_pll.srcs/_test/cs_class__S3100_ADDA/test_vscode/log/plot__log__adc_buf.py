## plot__log__adc_buf.py
# plot data from log__adc_buf.py

## import info
# test_data_list
# adc_buf0_list_s32
# adc_buf1_list_s32
# adc_buf0_list_hex_str
# adc_buf1_list_hex_str
#

#import log__adc_buf as adc_log
import log__adc_buf__dac as adc_log

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

	###

	# calculate 18-bit adc list
	adc_buf0_list_s32_18b = [ x>>14 for x in adc_buf0_list_s32]
	adc_buf1_list_s32_18b = [ x>>14 for x in adc_buf1_list_s32]

	###

##	# plot 1 - ADC 32-bit
##	FIG_NUM = 1
##	plt.figure(FIG_NUM, figsize=(8, 6))
##	
##	title_str = 'adc0(red) and adc1(blue)'
##	t_list = range(len(adc_buf0_list_s32))
##
##	plt.plot(t_list, adc_buf0_list_s32, 'ro-', markersize=10)
##	plt.plot(t_list, adc_buf1_list_s32, 'bs-', markersize=10, alpha=0.5)
##
##	plt.title(title_str)
##	plt.ylabel('adc_32bit_scale')
##	plt.xlabel('data index')
##	plt.grid(True)


	# plot 2 - voltages : float 
	FIG_NUM = 2
	plt.figure(FIG_NUM, figsize=(8, 6))
	
	title_str = 'adc0(red) and adc1(blue)'
	t_list = range(len(adc_buf0_list_s32))

	plt.plot(t_list, adc_buf0_list_flt, 'ro-', markersize=10, alpha=0.5)
	plt.plot(t_list, adc_buf1_list_flt, 'bs-', markersize=10, alpha=0.5)

	plt.title(title_str)
	plt.ylabel('adc_voltage')
	plt.xlabel('data index')
	plt.grid(True)


##	# plot 3 - ADC 18-bit
##	FIG_NUM = 3
##	plt.figure(FIG_NUM, figsize=(8, 6))
##	
##	title_str = 'adc0(red) and adc1(blue)'
##	t_list = range(len(adc_buf0_list_s32_18b))
##
##	plt.plot(t_list, adc_buf0_list_s32_18b, 'ro-', markersize=10)
##	plt.plot(t_list, adc_buf1_list_s32_18b, 'bs-', markersize=10, alpha=0.5)
##
##	plt.title(title_str)
##	plt.ylabel('adc_18bit_scale')
##	plt.xlabel('data index')
##	plt.grid(True)


	##
	plt.show()

	return


if __name__ == '__main__':
  if __debug__:
    print('>>>>>> In debug mode ... ')
    plot_test()

