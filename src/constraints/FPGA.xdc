set_property IOSTANDARD LVCMOS33 [get_ports *]
create_clock -period 10 [get_ports sys_clk]

# Buzzer
set_property PACKAGE_PIN T1 [get_ports pwm]
set_property PACKAGE_PIN M6 [get_ports sd]

# Buttons
set_property PACKAGE_PIN R15 [get_ports but_center]
set_property PACKAGE_PIN U4 [get_ports but_up]
set_property PACKAGE_PIN R17 [get_ports but_down]
set_property PACKAGE_PIN V1 [get_ports but_left]
set_property PACKAGE_PIN R11 [get_ports but_right]

set_property PACKAGE_PIN G17 [get_ports but_esc]
set_property PACKAGE_PIN B17 [get_ports {buts[0]}]
set_property PACKAGE_PIN A16 [get_ports {buts[1]}]
set_property PACKAGE_PIN A14 [get_ports {buts[2]}]
set_property PACKAGE_PIN A18 [get_ports {buts[3]}]
set_property PACKAGE_PIN F14 [get_ports {buts[4]}]
set_property PACKAGE_PIN B14 [get_ports {buts[5]}]
set_property PACKAGE_PIN C14 [get_ports {buts[6]}]
set_property PACKAGE_PIN A11 [get_ports {buts[7]}]

# VGA
set_property PACKAGE_PIN F5 [get_ports {color_red[0]}]
set_property PACKAGE_PIN C6 [get_ports {color_red[1]}]
set_property PACKAGE_PIN C5 [get_ports {color_red[2]}]
set_property PACKAGE_PIN B7 [get_ports {color_red[3]}]
set_property PACKAGE_PIN B6 [get_ports {color_green[0]}]
set_property PACKAGE_PIN A6 [get_ports {color_green[1]}]
set_property PACKAGE_PIN A5 [get_ports {color_green[2]}]
set_property PACKAGE_PIN D8 [get_ports {color_green[3]}]
set_property PACKAGE_PIN C7 [get_ports {color_blue[0]}]
set_property PACKAGE_PIN E6 [get_ports {color_blue[1]}]
set_property PACKAGE_PIN E5 [get_ports {color_blue[2]}]
set_property PACKAGE_PIN E7 [get_ports {color_blue[3]}]
set_property PACKAGE_PIN D7 [get_ports hsync]
set_property PACKAGE_PIN C4 [get_ports vsync]

# Top
set_property PACKAGE_PIN P17 [get_ports sys_clk]
set_property PACKAGE_PIN P15 [get_ports rst_n]

# Switches
set_property PACKAGE_PIN P5 [get_ports {switch[7]}]
set_property PACKAGE_PIN P4 [get_ports {switch[6]}]
set_property PACKAGE_PIN P3 [get_ports {switch[5]}]
set_property PACKAGE_PIN P2 [get_ports {switch[4]}]
set_property PACKAGE_PIN R2 [get_ports {switch[3]}]
set_property PACKAGE_PIN M4 [get_ports {switch[2]}]
set_property PACKAGE_PIN N4 [get_ports {switch[1]}]
set_property PACKAGE_PIN R1 [get_ports {switch[0]}]

# LEDs
set_property PACKAGE_PIN F6 [get_ports {LED[7]}]
set_property PACKAGE_PIN G4 [get_ports {LED[6]}]
set_property PACKAGE_PIN G3 [get_ports {LED[5]}]
set_property PACKAGE_PIN J4 [get_ports {LED[4]}]
set_property PACKAGE_PIN H4 [get_ports {LED[3]}]
set_property PACKAGE_PIN J3 [get_ports {LED[2]}]
set_property PACKAGE_PIN J2 [get_ports {LED[1]}]
set_property PACKAGE_PIN K2 [get_ports {LED[0]}]

# LEDs for debug
set_property PACKAGE_PIN K1 [get_ports {Debug_LED[7]}]
set_property PACKAGE_PIN H6 [get_ports {Debug_LED[6]}]
set_property PACKAGE_PIN H5 [get_ports {Debug_LED[5]}]
set_property PACKAGE_PIN J5 [get_ports {Debug_LED[4]}]
set_property PACKAGE_PIN K6 [get_ports {Debug_LED[3]}]
set_property PACKAGE_PIN H1 [get_ports {Debug_LED[2]}]
set_property PACKAGE_PIN M1 [get_ports {Debug_LED[1]}]
set_property PACKAGE_PIN K3 [get_ports {Debug_LED[0]}]