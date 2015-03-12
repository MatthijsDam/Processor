## Demo add.asm
     .text
     .globl  main
main:
     #registers used for arithmetic operations
     ori $2,$0, 200  # set eight registers for test purpose, do not use $0 and $1
     ori $3,$0, 50
     ori $4,$0, 1023 # stores add result (2000 + 50)
     ori $5,$0, 1023 # stores addi result(2000 + 2000 ie)
     ori $6,$0, 1023 # stores divu result(2000 / 50)
     ori $7,$0, 1023 # stores mult result(2000 * 50)
     ori $8,$0, 1023 # stores sub result(2000 - 50)
     
     # registers used for logic operations
     ori $9,$0, 118   # ( 0b01110110 ) 
     ori $10,$0, 176  # ( 0b10101010 )
     ori $11,$0, 1023 # stores and result (118 & 176)
     ori $12,$0, 1023 # stores andi result(118 & 225 ie)
     ori $13,$0, 1023 # stores or result()
     
     ori $13,$0, 1023 # stores arithmetic branch condition
     ori $13,$0, 1023 # stores logic branch condition
     
    
     addi $20, $0, 0x2100  # .data offset voor simulator
 #    addi $20, $0, 256    # .data offset voor "hardware"
     
     sw   $2, -24($20) # store all the registers to the memory, offset and register flipped in order to switch easy between simulator and hardware
     sw   $3, -20($20)
     sw   $4, -16($20)
     sw   $5, -12($20)
     sw   $6, -8($20)
     sw   $7, -4($20)
     sw   $8, 0($20)

begin:
     lw   $2, -24($20) # load all the register from the memory
     lw   $3, -20($20)
     lw   $4, -16($20)
     lw   $5, -12($20)
     lw   $6, -8($20)
     lw   $7, -4($20)
     lw   $8, 0($20) 

     add    $4, $2, $3  
     addi   $6, $5, 50

     and    $8, $6, $7
     andi   $3, $2, 0xAAAA

     beq    $3, $4, branch1 ## 
     beq    $3, $4, branch1 ## 
branch1:
     bgtz   $6, branch2
     bgtz   $6, branch2     ## duplicat both to verify right behaviour
branch2:

     divu   $8, $7
     mfhi   $7
     mflo   $8
        
     
     mult   $2, $3
     mfhi   $2
     mflo   $3

     nop	   	
     nop	
     
     sw   $2, -24($20)
     sw   $3, -20($20)
     sw   $4, -16($20)
     sw   $5, -12($20)
     sw   $6, -8($20)
     sw   $7, -4($20)
     sw   $8, 0($20) # load some registers


   

     j begin ## jump to start
## End of file
