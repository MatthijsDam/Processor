add wave *
radix signal sim:/topentity/address_bus hexadecimal
radix signal sim:/topentity/databus1 hexadecimal
radix signal sim:/topentity/databus2 hexadecimal
force clk 0,1 10ns -repeat 20ns
force reset 1
run 20ns
force reset 0
run 200ns
