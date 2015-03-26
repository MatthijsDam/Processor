vcom definitions.vhd
vcom processor_behavioural.vhd
#vcom processor_algorithmic.vhd
vcom program.vhd
vcom memory.vhd
vcom compare.vhd
vcom topEntity_bhv.vhd
vsim work.topentity_bhv

add wave *

add wave -position end  sim:/topentity_bhv/proc/state
add wave -position end  sim:/topentity_bhv/proc/reg
add wave -position end  sim:/topentity_bhv/proc/reg_LO
add wave -position end  sim:/topentity_bhv/proc/reg_HI
add wave -position end  sim:/topentity_bhv/mem/mem

radix signal sim:/topentity_bhv/address_bus hexadecimal

radix signal sim:/topentity_bhv/databus1 hexadecimal
radix signal sim:/topentity_bhv/databus2 hexadecimal

force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
