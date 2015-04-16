vcom definitions.vhd
#vcom processor_behavioural.vhd
vcom processor_algorithmic.vhd
vcom program.vhd
vcom memory.vhd
vcom compare.vhd
vcom topEntity_alg.vhd
vsim work.topentity_alg

add wave *

add wave -label "state"  sim:/topentity_alg/proc/state
add wave -label "reg"  sim:/topentity_alg/proc/reg
add wave -label "reg_LO"  sim:/topentity_alg/proc/reg_LO
add wave -label "reg_HI"  sim:/topentity_alg/proc/reg_HI
add wave -label "mem"  sim:/topentity_alg/mem/mem

radix signal sim:/topentity_alg/address_bus hexadecimal
radix signal sim:/topentity_alg/databus1 hexadecimal
radix signal sim:/topentity_alg/databus2 hexadecimal
radix signal sim:/topentity_alg/proc/reg hexadecimal
radix signal sim:/topentity_alg/mem/mem hexadecimal

add wave -label "adder_res" sim:/topentity_alg/proc/line__45/adder_res
radix signal sim:/topentity_alg/proc/line__45/adder_res hexadecimal

force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
