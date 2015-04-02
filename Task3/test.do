vcom definitions.vhd
vcom processor.vhd
vcom controller.vhd
vcom datapath.vhd
vcom program.vhd
vcom memory.vhd
vcom topEntity.vhd
vsim work.topEntity_processor

add wave *



force clk 0,1 10ns -repeat 20ns
force reset 1
run 50ns
force reset 0
run 3000ns
