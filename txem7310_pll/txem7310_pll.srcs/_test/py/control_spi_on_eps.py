## import EPS endpoint system
import eps
#eps.eps_test()

## may import specific endpoint address map
# ...

## define class for spi control based on EPS 
#  test for S3100-PGU-TSPI
class control_spi (eps.EPS_Dev):
    #
    def _test(self):
        ret_str = super()._test() + ':_class__control_spi_'
        return ret_str
    #
    ## direct inherit:
    #    Init
    #    Reset
    #    Open
    #    IsOpen
    #    GetSerialNumber
    #    Close
    #    _test__send_spi_frame  ## temporal use
    #
    ## composition:
    #
    def MSPI_reset(self):
        self.ActivateTriggerIn(0x42, 0) # reset_trig
        cnt_loop = 0
        while True:
            ret = self.IsTriggered(0x62,0x00000001) # reset_done
            cnt_loop += 1
            if ret:
                print('reset done !! @ ' + repr(cnt_loop))
                break
        pass
    #
    def MSPI_init(self):
        self.ActivateTriggerIn(0x42, 1) # init_trig
        cnt_loop = 0
        while True:
            ret = self.IsTriggered(0x62,0x00000002) # init_done
            cnt_loop += 1
            if ret:
                print('init done !! @ ' + repr(cnt_loop))
                break        
        pass
    #
    def MSPI_send_frame(self, data_C, data_A, data_D):
        ret = self._test__send_spi_frame(data_C, data_A, data_D)
        return ret # return data_B
    #  
    #
    def S3100_PGU_TSPI__send_ep_data(self, ep_adrs, ep_data):
        # 32 bit operation: send two 16-bit data frames
        data_C = 0x00 & 0x3F  ##// control data 6bit for write
        data_A_lo = ep_adrs       & 0x3FF
        data_D_lo = ep_data       & 0xFFFF # low 16 bit
        data_A_hi = (ep_adrs+2)   & 0x3FF
        data_D_hi = (ep_data>>16) & 0xFFFF # high 16 bit
        self.MSPI_send_frame(data_C, data_A_lo, data_D_lo)
        self.MSPI_send_frame(data_C, data_A_hi, data_D_hi)
        pass
    #
    def S3100_PGU_TSPI__read_ep_data(self, ep_adrs):
        # 32 bit operation: send two 16-bit data frames
        data_C = 0x10 & 0x3F  ##// control data 6bit for read 
        data_A_lo = ep_adrs       & 0x3FF
        data_D_lo = 0x0000        & 0xFFFF # low 16 bit
        data_A_hi = (ep_adrs+2)   & 0x3FF
        data_D_hi = 0x0000        & 0xFFFF # high 16 bit
        ret_lo = self.MSPI_send_frame(data_C, data_A_lo, data_D_lo)
        ret_hi = self.MSPI_send_frame(data_C, data_A_hi, data_D_hi)
        #
        ep_data = (ret_lo & 0xFFFF) + ((ret_hi & 0xFFFF)<<16)
        #
        return ep_data # 32 bits
    #
    #
    def pgu_get_fpga_id(self):
        ret = self.S3100_PGU_TSPI__read_ep_data(0x080)
        return ret
    #
    def pgu_get_fpga_temp(self):
        ret = self.S3100_PGU_TSPI__read_ep_data(0x0E8)
        return ret # mC
    #
    #  
    pass



###########################################################################
# TODO: test function

def control_spi__test():
    print('#################################################')

    ## class init
    ctl = control_spi()

    ## class test
    print(ctl._test())	#inherited function

    ## open socket for scpi
    _host_ = '192.168.100.62' # test S3100-PGU-TSPI
    _port_ = 5025
    ctl.Open(_host_,_port_) 

    ## get IDN from scpi
    ret = ctl.GetSerialNumber()
    print(ret)

    ## reset MSPI
    ctl.MSPI_reset()

    ## init MSPI
    ctl.MSPI_init()

    ## send test MSPI frame
    data_C = 0x10   ##// control data 6bit for read 
    data_A = 0x380  ##// address data 10bit for address of known pattern  0x_33AA_CC55
    data_D = 0x0000 ##// MOSI data 16bit for reading (XXXX)
    data_B = ctl.MSPI_send_frame(data_C, data_A, data_D)
    print('>>> {} = 0x{:02X}'.format('data_C', data_C))
    print('>>> {} = 0x{:03X}'.format('data_A', data_A))
    print('>>> {} = 0x{:04X}'.format('data_D', data_D))
    print('>>> {} = 0x{:04X}'.format('data_B', data_B))
    
    ## call test ep_data functions - 32 bits
    ep_adrs = 0x380
    ep_data = ctl.S3100_PGU_TSPI__read_ep_data(ep_adrs)
    print('>>> {} = 0x{:03X}'.format('ep_adrs', ep_adrs))
    print('>>> {} = 0x{:08X}'.format('ep_data', ep_data))

    ## pgu functions
    fpga_id = ctl.pgu_get_fpga_id()
    print('>>> {} = 0x{:08X}'.format('fpga_id', fpga_id))

    fpga_temp = ctl.pgu_get_fpga_temp()
    print('>>> {} = {}[C]'.format('fpga_temp', fpga_temp/1000))


    ## reset MSPI and control off MSPI
    ctl.MSPI_reset()

    ## close socket
    ctl.Close()
    print('>>> device closed.')
    print('#################################################')

    pass



###########################################################################
# test lib

if __name__ == '__main__':
	if __debug__:
		print('>>>>>> In debug mode ... ')
	control_spi__test()