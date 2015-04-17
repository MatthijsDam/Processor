-- assembled from mult_test.asm on 2015-04-16 16:43:29.103699 CEST

--  Address    Code        Basic                     Source
-- 
-- 0x00000000  0x201403fc  addi $20,$0,0x000003fc40        addi $20, $0, 1020    # .data offset voor "hardware"
-- 0x00000004  0x3c018000  lui $1,0xffff8000     45        ori $2,$0, 0x80000000  # register 2 and 3 are used as input registers for the arithmetic operations
-- 0x00000008  0x34210000  ori $1,$1,0x00000000       
-- 0x0000000c  0x00011025  or $2,$0,$1                
-- 0x00000010  0x3c017fff  lui $1,0x00007fff     46        ori $3,$0, 0x7FFFFFFF
-- 0x00000014  0x3421ffff  ori $1,$1,0x0000ffff       
-- 0x00000018  0x00011825  or $3,$0,$1                
-- 0x0000001c  0xae82ffe0  sw $2,0xffffffe0($20) 48        sw   $2, -32($20)
-- 0x00000020  0xae83ffdc  sw $3,0xffffffdc($20) 49        sw   $3, -36($20)
-- 0x00000024  0x00420018  mult $2,$2            52        mult $2, $2
-- 0x00000028  0x00002010  mfhi $4               53        mfhi $4
-- 0x0000002c  0x00002812  mflo $5               54        mflo $5
-- 0x00000030  0xae840000  sw $4,0x00000000($20) 55        sw   $4, 0($20)
-- 0x00000034  0xae85fffc  sw $5,0xfffffffc($20) 56        sw   $5, -4($20)
-- 0x00000038  0x00630018  mult $3,$3            58        mult $3, $3
-- 0x0000003c  0x00003010  mfhi $6               59        mfhi $6
-- 0x00000040  0x00003812  mflo $7               60        mflo $7
-- 0x00000044  0xae86fff8  sw $6,0xfffffff8($20) 61        sw   $6, -8($20)
-- 0x00000048  0xae87fff4  sw $7,0xfffffff4($20) 62        sw   $7, -12($20)
-- 0x0000004c  0x00430018  mult $2,$3            64        mult $2, $3
-- 0x00000050  0x00004010  mfhi $8               65        mfhi $8
-- 0x00000054  0x00004812  mflo $9               66        mflo $9
-- 0x00000058  0xae88fff0  sw $8,0xfffffff0($20) 67        sw   $8, -16($20)
-- 0x0000005c  0xae89ffec  sw $9,0xffffffec($20) 68        sw   $9, -20($20)
-- 0x00000060  0x00620018  mult $3,$2            70        mult $3, $2
-- 0x00000064  0x00005010  mfhi $10              71        mfhi $10
-- 0x00000068  0x00005812  mflo $11              72        mflo $11
-- 0x0000006c  0xae8affe8  sw $10,0xffffffe8($20)73        sw   $10, -24($20)
-- 0x00000070  0xae8bffe4  sw $11,0xffffffe4($20)74        sw   $11, -28($20)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00100000000101000000001111111100",
"00111100000000011000000000000000",
"00110100001000010000000000000000",
"00000000000000010001000000100101",
"00111100000000010111111111111111",
"00110100001000011111111111111111",
"00000000000000010001100000100101",
"10101110100000101111111111100000",
"10101110100000111111111111011100",
"00000000010000100000000000011000",
"00000000000000000010000000010000",
"00000000000000000010100000010010",
"10101110100001000000000000000000",
"10101110100001011111111111111100",
"00000000011000110000000000011000",
"00000000000000000011000000010000",
"00000000000000000011100000010010",
"10101110100001101111111111111000",
"10101110100001111111111111110100",
"00000000010000110000000000011000",
"00000000000000000100000000010000",
"00000000000000000100100000010010",
"10101110100010001111111111110000",
"10101110100010011111111111101100",
"00000000011000100000000000011000",
"00000000000000000101000000010000",
"00000000000000000101100000010010",
"10101110100010101111111111101000",
"10101110100010111111111111100100",

OTHERS => "00000000000000000000000000000000");

END;
