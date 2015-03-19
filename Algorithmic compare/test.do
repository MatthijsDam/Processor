vcom definitions.vhd
vcom processor_behavioural.vhd
vcom processor_algorithmic.vhd
vcom memory.vhd
vcom compare.vhd
vcom topEntity.vhd
vsim work.topentity

add wave *

add wave -position end  sim:/topentity/proc1/state
add wave -position end  sim:/topentity/proc1/reg
add wave -position end  sim:/topentity/proc1/reg_LO
add wave -position end  sim:/topentity/proc1/reg_HI
add wave -position end  sim:/topentity/mem/mem

radix signal sim:/topentity/address_mem hexadecimal
radix signal sim:/topentity/address_bus_bhv hexadecimal
radix signal sim:/topentity/address_bus_alg hexadecimal

radix signal sim:/topentity/data_bus_bhv hexadecimal
radix signal sim:/topentity/data_bus_alg hexadecimal
radix signal sim:/topentity/databus hexadecimal


force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns