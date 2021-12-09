"""
plot__log__adc_buf.py
plot data from log__adc_buf.py or log__adc_buf__dac.py
"""

## import info
# test_data_list
# adc_buf0_list_s32
# adc_buf1_list_s32
# adc_buf0_list_hex_str
# adc_buf1_list_hex_str
#

# pylint: disable=C0301
# pylint: disable=line-too-long

## Constants should be defined with UPPER_CASE letters only and should be defined at the module level
## Class names should be defined with CamelCase letters
## Variables should be defined at lower_case and should be defined inside function, classes etc.

# pylint: disable=C0326 ## disable-exactly-one-space


import matplotlib.pyplot as plt

#import log__adc_buf as adc_log
import log__adc_buf__dac as adc_log


#plt.ion() # matplotlib interactive mode


def plot_test():
    '''
    plot test
    '''
    ## data from outside
    test_data_list        = adc_log.TEST_DATA     # test

    buf_time              = adc_log.BUF_TIME      # dac cmd data
    buf_dac0              = adc_log.BUF_DAC0      # dac cmd data
    buf_dac1              = adc_log.BUF_DAC1      # dac cmd data

    adc_buf0_list_s32     = adc_log.ADC_BUF0      # adc buf0
    adc_buf1_list_s32     = adc_log.ADC_BUF1      # adc buf1
    adc_buf0_list_hex_str = adc_log.ADC_BUF0_HEX  # adc buf0 hex
    adc_buf1_list_hex_str = adc_log.ADC_BUF1_HEX  # adc buf1 hex
    adc_buf0_list_flt     = adc_log.ADC_BUF0_FLT  # adc buf0 float
    adc_buf1_list_flt     = adc_log.ADC_BUF1_FLT  # adc buf1 float

    ###

    print(">> length of test_data = {} ".format(len(test_data_list        )))

    print(">> length of buf_time  = {} ".format(len(buf_time              )))
    print(">> length of buf_dac0  = {} ".format(len(buf_dac0              )))
    print(">> length of buf_dac1  = {} ".format(len(buf_dac1              )))

    print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_s32     )))
    print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_s32     )))
    print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_hex_str )))
    print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_hex_str )))
    print(">> length of adc_buf0  = {} ".format(len(adc_buf0_list_flt     )))
    print(">> length of adc_buf1  = {} ".format(len(adc_buf1_list_flt     )))

    ###

    # calculate 18-bit adc list
    ##  adc_buf0_list_s32_18b = [ x>>14 for x in ADC_BUF0_LIST_S32]
    ##  adc_buf1_list_s32_18b = [ x>>14 for x in ADC_BUF1_LIST_S32]

    ###

    if buf_time: # non-empty list

        # plot 0 - dac command points - voltages : float
        fig_num = 0
        plt.figure(fig_num, figsize=(8, 6))

        title_str = 'dac0(red) and dac1(blue)'
        t_list = buf_time

        plt.plot(t_list, buf_dac0, 'ro-', markersize=10, alpha=0.5)
        plt.plot(t_list, buf_dac1, 'bs-', markersize=10, alpha=0.5)

        plt.title(title_str)
        plt.ylabel('dac_voltage [V]')
        plt.xlabel('time [ns]')
        plt.grid(True)

##	# plot 1 - ADC 32-bit
##	fig_num = 1
##	plt.figure(fig_num, figsize=(8, 6))
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
    fig_num = 2
    plt.figure(fig_num, figsize=(8, 6))

    title_str = 'adc0(red) and adc1(blue)'
    t_list = range(len(adc_buf0_list_s32))

    plt.plot(t_list, adc_buf0_list_flt, 'ro-', markersize=10, alpha=0.3)
    plt.plot(t_list, adc_buf1_list_flt, 'bs-', markersize=10, alpha=0.3)

    plt.title(title_str)
    plt.ylabel('adc_voltage')
    plt.xlabel('data index')
    plt.grid(True)


##	# plot 3 - ADC 18-bit
##	fig_num = 3
##	plt.figure(fig_num, figsize=(8, 6))
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

    return None


if __name__ == '__main__':
    if __debug__:
        print('>>>>>> In debug mode ... ')
        plot_test()
