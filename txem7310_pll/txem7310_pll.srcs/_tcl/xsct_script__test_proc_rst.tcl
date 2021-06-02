# xsct script for MB processor check... may see Hello in MDM jtagterminal
#
#  xsct% cd {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.srcs\_tcl}
#  xsct% source xsct_script__test_proc_rst.tcl 
#
#  $ xsct xsct_script__test_proc_rst.tcl [args]




# connect 
connect
# list targets 
targets 

# select target for downloading bit
targets -set -filter {name =~ "xc7*"}
# Download bit
puts >>bit:
fpga -f {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.sdk\xem7310__cmu_cpu__top_hw_platform_0\download__F5_19_0115.bit}

# select target for jtagterminal
targets -set -filter {name =~ "MicroBlaze*Debug*"}
# start jtagterminal
jtagterminal
# select target for downloading elf 
targets -set -filter {name =~ "MicroBlaze*#0"}

# System Reset
rst -system

# con
puts >>con:
con

# disconnect
#disconnect