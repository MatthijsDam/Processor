#vcom topEntity.vho
vcom types.vhd
vcom definitions.vhd
vcom processor_behavioural.vhd
vcom controller.vhd
vcom datapath_convert.vhd
vcom processor_post.vhd
vcom compare.vhd
vcom program.vhd
vcom memory.vhd
vcom topEntity_compare_post.vhd
vsim work.topEntity_compare_post

#add wave -label "Address_bus compare" psl_address_bus
add wave -label "Reset" sim:/topentity_compare_post/reset
add wave -label "Clock" sim:/topentity_compare_post/clk
add wave -label "address bus memory" sim:/topentity_compare_post/address_mem
add wave -label "address bus bhv" sim:/topentity_compare_post/address_bus_bhv
add wave -label "address bus alu" sim:/topentity_compare_post/address_bus_alu

add wave -label "data bus" sim:/topentity_compare_post/databus
add wave -label "data bus bhv" sim:/topentity_compare_post/data_bus_bhv
add wave -label "data bus alu" sim:/topentity_compare_post/data_bus_alu

add wave -label "write mem" sim:/topentity_compare_post/write_mem
add wave -label "write bhv" sim:/topentity_compare_post/write_bhv
add wave -label "write alu" sim:/topentity_compare_post/write_alu

add wave -label "enable bhv" sim:/topentity_compare_post/enable_bhv


add wave -label "state bhv" sim:/topentity_compare_post/proc_bhv/state
#add wave -label "state alu" sim:/topentity_compare_post/proc/contr/state 

add wave -label "memory" sim:/topentity_compare_post/mem/mem

#add wave -label "reg alu" sim:/topentity_compare_post/proc/dtpath/reg
#add wave -label "reg bhv low" sim:/topentity_compare_post/proc/dtpath/reg_LO
#add wave -label "reg bhv high" sim:/topentity_compare_post/proc/dtpath/reg_HI
add wave -label "reg bhv" sim:/topentity_compare_post/proc_bhv/reg
add wave -label "reg bhv low" sim:/topentity_compare_post/proc_bhv/reg_LO
add wave -label "reg bhv high" sim:/topentity_compare_post/proc_bhv/reg_HI

#add wave -label "operation"  sim:/topentity_compare_post/proc/operation

radix signal sim:/topentity_compare_post/address_mem hexadecimal
radix signal sim:/topentity_compare_post/address_bus_bhv hexadecimal
radix signal sim:/topentity_compare_post/address_bus_alu hexadecimal

force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
