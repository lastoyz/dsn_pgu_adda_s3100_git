# xsct script for MB processor check... may see Hello in MDM jtagterminal
#
#  xsct% cd {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.srcs\_tcl}
#  xsct% source xsct_script__test_hello.tcl 
#
#  $ xsct xsct_script__test_hello.tcl [args]
#
#  Xilinx Software Command-Line Tool (XSCT)
#  https://www.xilinx.com/html_docs/xilinx2018_2/SDK_Doc/xsct/intro/xsct_introduction.html
#



# Set SDK workspace
setws {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.sdk}
# assume bsp was created
# assume app was created
# Build hello project 
puts >>build:
projects -build -type app -name hello
# connect 
#connect -host localhost
connect
# list targets 
targets 

# select target for downloading bit
targets -set -filter {name =~ "xc7*"}
# Download bit
puts >>bit:
fpga -f {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.sdk\xem7310__cmu_cpu__top_hw_platform_0\xem7310__cmu_cpu__top.bit}

# select target for jtagterminal
targets -set -filter {name =~ "MicroBlaze*Debug*"}
# start jtagterminal
jtagterminal

# select target for downloading elf 
targets -set -filter {name =~ "MicroBlaze*#0"}
# System Reset
#rst -system
# Download the elf
puts >>elf:
dow {D:\proj_fpga\xem7310_pll__CMU-CPU__work\xem7310_pll.sdk\hello\Debug\hello.elf}
# Insert a breakpoint @ main
puts >>break:
bpadd -addr &main
# Continue execution until the target is suspended
con -block -timeout 5
# con
puts >>con:
con

# rst
#puts >>rst:
#rst

# state
#puts >>state:
#state 

# register 
#puts >>reg:
#rrd

#Remove Breakpoints/Watchpoints.
bpremove -all

# Disable Breakpoints/Watchpoints.
#bpdisable -all

# disconnect
#disconnect