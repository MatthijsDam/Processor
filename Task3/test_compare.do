vcom types.vhd
vcom definitions.vhd
vcom processor_behavioural.vhd
vcom controller.vhd
vcom datapath.vhd
vcom processor.vhd
vcom compare.vhd
vcom program.vhd
vcom memory.vhd
vcom topEntity_compare.vhd
vsim work.topEntity_compare

add wave -label "Address_bus compare" psl_address_bus
add wave -label "Reset" sim:/topentity_compare/reset
add wave -label "Clock" sim:/topentity_compare/clk
add wave -label "address bus memory" sim:/topentity_compare/address_mem
add wave -label "address bus bhv" sim:/topentity_compare/address_bus_bhv
add wave -label "address bus alu" sim:/topentity_compare/address_bus_alu

add wave -label "data bus" sim:/topentity_compare/databus
add wave -label "data bus bhv" sim:/topentity_compare/data_bus_bhv
add wave -label "data bus alu" sim:/topentity_compare/data_bus_alu

add wave -label "write mem" sim:/topentity_compare/write_mem
add wave -label "write bhv" sim:/topentity_compare/write_bhv
add wave -label "write alu" sim:/topentity_compare/write_alu

add wave -label "enable bhv" sim:/topentity_compare/enable_bhv


add wave -label "state bhv" sim:/topentity_compare/proc_bhv/state
add wave -label "state alu" sim:/topentity_compare/proc/contr/state 

add wave -label "memory" sim:/topentity_compare/mem/mem

add wave -label "reg alu" sim:/topentity_compare/proc/dtpath/reg
add wave -label "reg bhv low" sim:/topentity_compare/proc/dtpath/reg_LO
add wave -label "reg bhv high" sim:/topentity_compare/proc/dtpath/reg_HI
add wave -label "reg bhv" sim:/topentity_compare/proc_bhv/reg
add wave -label "reg bhv low" sim:/topentity_compare/proc_bhv/reg_LO
add wave -label "reg bhv high" sim:/topentity_compare/proc_bhv/reg_HI

add wave -label "funct"  sim:/topentity_compare/proc/dtpath/funct
add wave -label "opcode" sim:/topentity_compare/proc/dtpath/opcode
add wave -label "div0"  sim:/topentity_compare/proc/contr/div_by_zero
add wave -label "cycle_cnt"  sim:/topentity_compare/proc/contr/line__43/cycle_cnt

radix signal sim:/topentity_compare/address_mem hexadecimal
radix signal sim:/topentity_compare/address_bus_bhv hexadecimal
radix signal sim:/topentity_compare/address_bus_alu hexadecimal

force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
