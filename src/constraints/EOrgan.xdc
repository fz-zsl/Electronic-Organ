set_property IOSTANDARD LVCMOS33 [get_ports *]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PS2_clk_IBUF]
create_clock -period 10 [get_ports sys_clk]

set_property PACKAGE_PIN P17 [get_ports sys_clk]
set_property PACKAGE_PIN P15 [get_ports rst_n]
set_property PACKAGE_PIN K5 [get_ports PS2_clk]
set_property PACKAGE_PIN L4 [get_ports PS2_data]

set_property PACKAGE_PIN F6 [get_ports {note[0]}]
set_property PACKAGE_PIN G4 [get_ports {note[1]}]
set_property PACKAGE_PIN G3 [get_ports {note[2]}]
set_property PACKAGE_PIN J4 [get_ports {note[3]}]
set_property PACKAGE_PIN H4 [get_ports {note[4]}]
set_property PACKAGE_PIN J3 [get_ports {note[5]}]
set_property PACKAGE_PIN J2 [get_ports {note[6]}]
set_property PACKAGE_PIN K2 [get_ports {note[7]}]

#set_property PACKAGE_PIN U2 [get_ports {shift[0]}]
#set_property PACKAGE_PIN U3 [get_ports {shift[1]}]

set_property PACKAGE_PIN T1 [get_ports pwm]
set_property PACKAGE_PIN M6 [get_ports sd]