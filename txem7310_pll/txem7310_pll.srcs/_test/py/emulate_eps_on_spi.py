## import control spi
import control_spi_on_eps

## define class for EPS emulation based on MTH-SPI control over LAN-EPS 
#  test for S3100-CPU-TSPI

class emulate_eps (control_spi_on_eps.control_spi):
    #
    def _test(self):
        ret_str = super()._test() + ':_class__emulate_eps_'
        return ret_str




###########################################################################
# TODO: test function

def emulate_eps__test():
    print('#################################################')

    ## class init
    emul = emulate_eps()

    ## class test
    print(emul._test())	#inherited function

    pass



###########################################################################
# test lib

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	emulate_eps__test()