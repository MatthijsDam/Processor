-- assembled from test_prog_new.asm on 2015-04-17 14:35:32.339759 CEST

--  Address    Code        Basic                     Source
-- 
-- 0x00000000  0x340207d0  ori $2,$0,0x000007d0  40        ori $2,$0, 2000  # register 2 and 3 are used as input registers for the arithmetic operations
-- 0x00000004  0x34030032  ori $3,$0,0x00000032  41        ori $3,$0, 50
-- 0x00000008  0x34090076  ori $9,$0,0x00000076  49        ori $9,$0, 118   # ( 0b01110110 ) # register 9 and 10 are used as input registers for the logical operations
-- 0x0000000c  0x340a00b0  ori $10,$0,0x000000b0 50        ori $10,$0, 176  # ( 0b10101010 )
-- 0x00000010  0x340e0000  ori $14,$0,0x00000000 56        ori $14,$0, 0 # stores arithmetic branch condition
-- 0x00000014  0x340f0000  ori $15,$0,0x00000000 57        ori $15,$0, 0 # stores logic branch condition
-- 0x00000018  0x34100001  ori $16,$0,0x00000001 58        ori $16,$0, 1 # stores a one to do xor ops
-- 0x0000001c  0x341a0000  ori $26,$0,0x00000000 60        ori $26,$0, 0 # arithmetic loop counter
-- 0x00000020  0x341b0000  ori $27,$0,0x00000000 61        ori $27,$0, 0 # logic loop counter   
-- 0x00000024  0x201403fc  addi $20,$0,0x000003fc64       addi $20, $0, 1020    # .data offset voor "hardware"
-- 0x00000028  0xae820000  sw $2,0x00000000($20) 66        sw   $2, 0($20)          # store all the registers to the memory, offset and register flipped in order to switch easily between simulator and hardware
-- 0x0000002c  0xae83fffc  sw $3,0xfffffffc($20) 67        sw   $3, -4($20)
-- 0x00000030  0xae89ffe4  sw $9,0xffffffe4($20) 68        sw   $9, -28($20)
-- 0x00000034  0xae8affe0  sw $10,0xffffffe0($20)69        sw   $10,-32($20)
-- 0x00000038  0x8e820000  lw $2,0x00000000($20) 76        lw     $2, 0($20)          # load the input registers from the memory
-- 0x0000003c  0x8e83fffc  lw $3,0xfffffffc($20) 77        lw     $3, -4($20)
-- 0x00000040  0x00432020  add $4,$2,$3          79        add    $4, $2, $3          # some arithmetic operations
-- 0x00000044  0x204507d0  addi $5,$2,0x000007d0 80        addi   $5, $2, 2000
-- 0x00000048  0x0062001b  divu $3,$2            81        divu   $3, $2              
-- 0x0000004c  0x00003010  mfhi $6               82        mfhi   $6 
-- 0x00000050  0x00430018  mult $2,$3            83        mult   $2, $3
-- 0x00000054  0x00003812  mflo $7               84        mflo   $7
-- 0x00000058  0x00434022  sub $8,$2,$3          85        sub    $8, $2, $3
-- 0x0000005c  0x235a0001  addi $26,$26,0x000000087        addi   $26,$26, 1          # add 1 to arithmetic loop counter
-- 0x00000060  0x01d07026  xor $14,$14,$16       88        xor    $14, $14, $16       # flip the arithmetic brang deciding bit
-- 0x00000064  0xae84fff8  sw $4,0xfffffff8($20) 90        sw   $4, -8($20)
-- 0x00000068  0xae85fff4  sw $5,0xfffffff4($20) 91        sw   $5, -12($20)
-- 0x0000006c  0xae86fff0  sw $6,0xfffffff0($20) 92        sw   $6, -16($20)
-- 0x00000070  0xae87ffec  sw $7,0xffffffec($20) 93        sw   $7, -20($20)
-- 0x00000074  0xae88ffe8  sw $8,0xffffffe8($20) 94        sw   $8, -24($20)
-- 0x00000078  0xae9affd0  sw $26,0xffffffd0($20)95        sw   $26, -48($20)
-- 0x0000007c  0x11c0ffee  beq $14,$0,0xffffffee 97        beq   $14, $0, arithmetic
-- 0x00000080  0x8e89ffe4  lw $9,0xffffffe4($20) 102       lw   $9, -28($20)          # load the input registers from the memory
-- 0x00000084  0x8e8affe0  lw $10,0xffffffe0($20)103       lw   $10, -32($20)
-- 0x00000088  0x012a5824  and $11,$9,$10        105       and    $11, $9, $10        # some logic operations
-- 0x0000008c  0x312c00b7  andi $12,$9,0x000000b7106       andi   $12, $9, 0xB7
-- 0x00000090  0x012a6825  or $13,$9,$10         107       or     $13, $9, $10
-- 0x00000094  0x237b0001  addi $27,$27,0x0000000109       addi  $27,$27, 1           # add 1 to logic loop counter
-- 0x00000098  0x01f07826  xor $15,$15,$16       110       xor   $15, $15, $16       # flip the logic branch deciding bit
-- 0x0000009c  0xae8bffdc  sw $11,0xffffffdc($20)112       sw   $11, -36($20)         # store the calculated results in memory
-- 0x000000a0  0xae8cffd8  sw $12,0xffffffd8($20)113       sw   $12, -40($20)
-- 0x000000a4  0xae8dffd4  sw $13,0xffffffd4($20)114       sw   $13, -44($20)
-- 0x000000a8  0xae9bffcc  sw $27,0xffffffcc($20)115       sw   $27, -52($20)
-- 0x000000ac  0x1de0fff4  bgtz $15,0xfffffff4   117       bgtz   $15, logic     ## duplicate both to verify right behaviour  
-- 0x000000b0  0x0800000e  j 0x00000038          122       j arithmetic ## jump to start
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00110100000000100000011111010000",
"00110100000000110000000000110010",
"00110100000010010000000001110110",
"00110100000010100000000010110000",
"00110100000011100000000000000000",
"00110100000011110000000000000000",
"00110100000100000000000000000001",
"00110100000110100000000000000000",
"00110100000110110000000000000000",
"00100000000101000000001111111100",
"10101110100000100000000000000000",
"10101110100000111111111111111100",
"10101110100010011111111111100100",
"10101110100010101111111111100000",
"10001110100000100000000000000000",
"10001110100000111111111111111100",
"00000000010000110010000000100000",
"00100000010001010000011111010000",
"00000000011000100000000000011011",
"00000000000000000011000000010000",
"00000000010000110000000000011000",
"00000000000000000011100000010010",
"00000000010000110100000000100010",
"00100011010110100000000000000001",
"00000001110100000111000000100110",
"10101110100001001111111111111000",
"10101110100001011111111111110100",
"10101110100001101111111111110000",
"10101110100001111111111111101100",
"10101110100010001111111111101000",
"10101110100110101111111111010000",
"00010001110000001111111111101110",
"10001110100010011111111111100100",
"10001110100010101111111111100000",
"00000001001010100101100000100100",
"00110001001011000000000010110111",
"00000001001010100110100000100101",
"00100011011110110000000000000001",
"00000001111100000111100000100110",
"10101110100010111111111111011100",
"10101110100011001111111111011000",
"10101110100011011111111111010100",
"10101110100110111111111111001100",
"00011101111000001111111111110100",
"00001000000000000000000000001110",

OTHERS => "00000000000000000000000000000000");

END;
