connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent JTAG-HS2 210249A3114B"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent JTAG-HS2 210249A3114B"} -index 0
dow /media/sf_temp/dsn_s3100_sv_pgu_git/txem7310_pll/txem7310_pll.srcs/_sdk/s3100_mcs_lan_eps/Debug/s3100_mcs_lan_eps.elf
bpadd -addr &main
