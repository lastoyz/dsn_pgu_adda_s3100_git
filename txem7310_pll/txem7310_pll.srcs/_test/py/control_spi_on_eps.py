import eps

#eps.eps_test()

eps.EPS_Dev

class control_spi (eps.EPS_Dev):
    def _test(self):
        ret_str = super()._test() + ':_class__control_spi_'
        return ret_str
    pass


###########################################################################
# TODO: test function

def control_spi__test():
    print('#################################################')

    ## class init
    ctl = control_spi()

    ## class test
    print(ctl._test())	#inherited function




###########################################################################
# test lib

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	control_spi__test()