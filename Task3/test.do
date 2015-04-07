vcom types.vhd
vcom definitions.vhd
vcom processor.vhd
vcom controller.vhd
vcom datapath.vhd
vcom program.vhd
vcom memory.vhd
vcom topEntity.vhd
vsim work.topEntity_processor

add wave -label "Reset" sim:/topentity_processor/reset
add wave -label "Clock" sim:/topentity_processor/clk
add wave -label "Addressbus" sim:/topentity_processor/address_bus
add wave -label "Proc_data_in" sim:/topentity_processor/proc_data_in
add wave -label "Mem_data_in" sim:/topentity_processor/mem_data_in
add wave -label "Mem write" sim:/topentity_processor/write

add wave -label "alu_sel" sim:/topentity_processor/proc/alu_sel
add wave -label "alu_reg" sim:/topentity_processor/proc/dtpath/alu_reg

add wave -label "state" sim:/topentity_processor/proc/contr/state 
add wave -label "reg" sim:/topentity_processor/proc/dtpath/reg

add wave -label "memory" sim:/topentity_processor/mem/mem



force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
