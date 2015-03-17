## Demo add.asm
     .text
     .globl  main
main:
    # layout:
    # 0:                Permanently 0
    # 1:                Used for 16 bit shifts
    # 2:                Input 1 arith
    # 3:                Input 2 arith
    # 4:                Output add
    # 5:                Output addi
    # 6:                Output divu
    # 7:                Output mult
    # 8:                Output sub
    # 9:                Input 1 logic
    # 10:               Input 2 logic
    # 11:               Output and
    # 12:               Output andi
    # 13:               Output or
    # 14:               Branch selection bit arith
    # 15:               Branch selection bit logic
    # 16:               Branch xor bit high 1
    # 17:               NOT USED
    # 18:               NOT USED
    # 19:               NOT USED
    # 20:               Simulator, compiler base register
    # 21:               NOT USED
    # 22:               NOT USED
    # 23:               NOT USED
    # 24:               NOT USED
    # 25:               NOT USED
    # 26:               Arithmetic branch loop count
    # 27:               Logic branch loop count
    # 28:               NOT USED
    # 29:               NOT USED
    # 30:               NOT USED
    # 31:               NOT USED

     #1registers used for arithmetic operations
     ori $2,$0, 2000  # register 2 and 3 are used as input registers for the arithmetic operations
     ori $3,$0, 50
   #  ori $4,$0, 1023 # stores add result (2000 + 50)
   #  ori $5,$0, 1023 # stores addi result(2000 + 2000 ie)
   #  ori $6,$0, 1023 # stores divu result(2000 / 50)
   #  ori $7,$0, 1023 # stores mult result(2000 * 50)
   #  ori $8,$0, 1023 # stores sub result(2000 - 50)
     
     # registers used for logic operations
     ori $9,$0, 118   # ( 0b01110110 ) # register 9 and 10 are used as input registers for the logical operations
     ori $10,$0, 176  # ( 0b10101010 )
   #  ori $11,$0, 1023 # stores and result (118 & 176)
   #  ori $12,$0, 1023 # stores andi result(118 & 225 ie)
   #  ori $13,$0, 1023 # stores or result()
     
     
     ori $14,$0, 0 # stores arithmetic branch condition
     ori $15,$0, 0 # stores logic branch condition
     ori $16,$0, 1 # stores a one to do xor ops

     ori $26,$0, 0 # arithmetic loop counter
     ori $27,$0, 0 # logic loop counter   
    
     addi $20, $0, 0x2100  # .data offset voor simulator
 #   addi $20, $0, 256    # .data offset voor "hardware"
     
     sw   $2, 0($20)          # store all the registers to the memory, offset and register flipped in order to switch easily between simulator and hardware
     sw   $3, -4($20)
     sw   $9, -28($20)
     sw   $10,-32($20)
     
     #sw   $6, -8($20)
     #sw   $7, -4($20)
     #sw   $8, 0($20)

arithmetic:
     lw     $2, 0($20)          # load the input registers from the memory
     lw     $3, -4($20)

     add    $4, $2, $3          # some arithmetic operations
     addi   $5, $2, 2000
     divu   $3, $2              
     mfhi   $6 
     mult   $2, $3
     mflo   $7
     sub    $8, $2, $3
     
     addi   $26,$26, 1          # add 1 to arithmetic loop counter
     xor    $14, $14, $16       # flip the arithmetic brang deciding bit
  
     sw   $4, -8($20)
     sw   $5, -12($20)
     sw   $6, -16($20)
     sw   $7, -20($20)
     sw   $8, -24($20)
     sw   $26, -48($20)
     
     beq   $16, $0, arithmetic  
     


logic:
     lw   $9, -28($20)          # load the input registers from the memory
     lw   $10, -32($20)
        
     and    $11, $9, $10        # some logic operations
     andi   $12, $9, 0xB7
     or     $13, $9, $10
    
     addi  $27,$27, 1           # add 1 to logic loop counter
     xor   $15, $15, $16       # flip the logic branch deciding bit

     sw   $11, -36($20)         # store the calculated results in memory
     sw   $12, -40($20)
     sw   $13, -44($20)
     sw   $27, -52($20)

     bgtz   $15, logic     ## duplicate both to verify right behaviour  
     
     
     

     j arithmetic ## jump to start
## End of file
