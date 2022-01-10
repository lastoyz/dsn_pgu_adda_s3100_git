"""
plot__log__dft_compute.py
plot data from log__dft_compute.py
"""

## import info
# DFT_COEF_I_BUF
# DFT_COEF_Q_BUF
# ADC_DATA_0_BUF
# ADC_DATA_1_BUF


# pylint: disable=C0301
# pylint: disable=line-too-long

## Constants should be defined with UPPER_CASE letters only and should be defined at the module level
## Class names should be defined with CamelCase letters
## Variables should be defined at lower_case and should be defined inside function, classes etc.

# pylint: disable=C0326 ## disable-exactly-one-space


import matplotlib.pyplot as plt

#import log__adc_buf as adc_log
#import log__adc_buf__dac as adc_log
import log__dft_compute as dft_log

#plt.ion() # matplotlib interactive mode


def plot_test():
    '''
    plot test
    '''
    ## data from outside
    dft_coef_i_buf_list_flt     = dft_log.DFT_COEF_I_BUF  # dft coef i buf
    dft_coef_q_buf_list_flt     = dft_log.DFT_COEF_Q_BUF  # dft coef q buf
    adc_data_0_buf_list_s32     = dft_log.ADC_DATA_0_BUF  # adc data 0 buf
    adc_data_1_buf_list_s32     = dft_log.ADC_DATA_1_BUF  # adc data 1 buf


    ###

    print(">> length of dft_coef_i_buf_list_flt  = {} ".format(len(dft_coef_i_buf_list_flt     )))
    print(">> length of dft_coef_q_buf_list_flt  = {} ".format(len(dft_coef_q_buf_list_flt     )))
    print(">> length of adc_data_0_buf_list_s32  = {} ".format(len(adc_data_0_buf_list_s32     )))
    print(">> length of adc_data_1_buf_list_s32  = {} ".format(len(adc_data_1_buf_list_s32     )))

    ###


##    # plot 0 - dac command points - voltages : float
##    fig_num = 0
##    plt.figure(fig_num, figsize=(8, 6))
##
##    title_str = 'dac0(red) and dac1(blue)'
##    t_list = buf_time
##
##    plt.plot(t_list, buf_dac0, 'ro-', markersize=10, alpha=0.5)
##    plt.plot(t_list, buf_dac1, 'bs-', markersize=10, alpha=0.5)
##
##    plt.title(title_str)
##    plt.ylabel('dac_voltage [V]')
##    plt.xlabel('time [ns]')
##    plt.grid(True)

    # plot 1 - ADC 32-bit --> voltage
    fig_num = 1
    plt.figure(fig_num, figsize=(8, 6))
    title_str = 'adc0(red) and adc1(blue)'
    t_list = range(len(adc_data_0_buf_list_s32))
    adc_scale = 4.096 / (2**31-1)
    y1_list = [ x*adc_scale for x in adc_data_0_buf_list_s32]
    y2_list = [ x*adc_scale for x in adc_data_1_buf_list_s32]
    plt.plot(t_list, y1_list, 'ro-', markersize=10)
    plt.plot(t_list, y2_list, 'bs-', markersize=10, alpha=0.5)
    plt.title(title_str)
    plt.ylabel('ADC voltage') #plt.ylabel('adc_32bit_scale')
    plt.xlabel('data index')
    plt.grid(True)


    # plot 2 - DFT coefficients : float
    fig_num = 2
    plt.figure(fig_num, figsize=(8, 6))

    title_str = 'dft_coef_i(magenta) and dft_coef_q(cyan)'
    t_list = range(len(dft_coef_i_buf_list_flt))

    ## https://matplotlib.org/stable/gallery/color/named_colors.html
    plt.plot(t_list, dft_coef_i_buf_list_flt, 'mo-', markersize=10, alpha=0.5)
    plt.plot(t_list, dft_coef_q_buf_list_flt, 'cs-', markersize=10, alpha=0.5)

    plt.title(title_str)
    plt.ylabel('DFT coef')
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
