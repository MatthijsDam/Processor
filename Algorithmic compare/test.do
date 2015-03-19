vcom definitions.vhd
vcom processor.vhd
vcom memory.vhd
vcom compare.vhd
vcom topEntity.vhd
vsim work.topentity

add wave *

add wave -position end  sim:/topentity/proc/state
add wave -position end  sim:/topentity/proc/reg
add wave -position end  sim:/topentity/proc/reg_LO
add wave -position end  sim:/topentity/proc/reg_HI
add wave -position end  sim:/topentity/mem/mem

radix signal sim:/topentity/address_bus hexadecimal
radix signal sim:/topentity/databus1 hexadecimal
radix signal sim:/topentity/databus2 hexadecimal


force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns