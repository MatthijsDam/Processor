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
     ori $2,$0, 10  # register 2 and 3 are used as input registers for the arithmetic operations
     ori $3,$0, -10
     mult $2, $3
     mfhi $4
     mflo $5
	 mult $3, $2
	 mfhi $6
     mflo $7
## End of file
