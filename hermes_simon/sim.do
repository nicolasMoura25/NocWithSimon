if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work -93 -explicit SIMON/simon_key_scheduler.vhd
vcom -work work -93 -explicit SIMON/simon_core.vhd
vcom -work work -93 -explicit NOC/Hermes_package.vhd
vcom -work work -93 -explicit NOC/Hermes_buffer.vhd
vcom -work work -93 -explicit NOC/Hermes_switchcontrol.vhd
vcom -work work -93 -explicit NOC/Hermes_crossbar.vhd
vcom -work work -93 -explicit NOC/simon_wrapper.vhd
vcom -work work -93 -explicit NOC/RouterCC.vhd
vcom -work work -93 -explicit NOC/RouterCC_S.vhd
vcom -work work -93 -explicit NOC/NOC.vhd
vcom -work work -93 -explicit tb.vhd

vsim -voptargs=+acc=lprn -t ps work.tb

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

do wave.do 

run 1000 ns

