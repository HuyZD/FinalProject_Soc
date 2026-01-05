# Artix 7 AC701 Pin Assignments

############################

# On-board Slide Switches  #

############################

#set_property -dict { PACKAGE_PIN P6   IOSTANDARD LVCMOS33 } [get_ports { swt[0] }];

#set_property -dict { PACKAGE_PIN T5   IOSTANDARD LVCMOS33 } [get_ports { swt[1] }];

#set_property -dict { PACKAGE_PIN R5   IOSTANDARD LVCMOS33 } [get_ports { swt[2] }];

#set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports { swt[3] }];



set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports { RESET }]; #CPU_Reset

set_property -dict { PACKAGE_PIN M21   IOSTANDARD LVCMOS33 } [get_ports { CLK }]; #SYSCLK_P

create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]

############################

# On-board led             #

############################
set_property -dict { PACKAGE_PIN P26   IOSTANDARD LVCMOS33 } [get_ports { RsRx }]; #PMOD_0
set_property -dict { PACKAGE_PIN T22   IOSTANDARD LVCMOS33 } [get_ports { RsTx }]; #PMOD_1
set_property -dict { PACKAGE_PIN L25   IOSTANDARD LVCMOS33 } [get_ports { LCD[0] }]; #DB4

set_property -dict { PACKAGE_PIN M24   IOSTANDARD LVCMOS33 } [get_ports { LCD[1] }]; #DB5

set_property -dict { PACKAGE_PIN M25   IOSTANDARD LVCMOS33 } [get_ports { LCD[2] }]; #DB6

set_property -dict { PACKAGE_PIN L22   IOSTANDARD LVCMOS33 } [get_ports { LCD[3] }]; #DB7

set_property -dict { PACKAGE_PIN L24   IOSTANDARD LVCMOS33 } [get_ports { LCD[4] }]; #RW

set_property -dict { PACKAGE_PIN L23   IOSTANDARD LVCMOS33 } [get_ports { LCD[5] }]; #RS

set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { LCD[6] }]; #Enable