#If required use the below command and launch symbol server from an external shell.
#symbol_server -S -s tcp::1534
connect -path [list tcp::1534 tcp:192.168.100.110:3121]
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent JTAG-HS3 210299A1F7A1"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent JTAG-HS3 210299A1F7A1"} -index 0
dow /media/sf_temp/dsn_adda_s3100_git/txem7310_pll/txem7310_pll.srcs/_sdk/s3100_mcs_lan_eps/Debug/s3100_mcs_lan_eps.elf
bpadd -addr &main
