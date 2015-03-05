add wave *
force clk 0,1 10ns -repeat 20ns
force reset 1
run 20ns
force reset 0
run 200ns