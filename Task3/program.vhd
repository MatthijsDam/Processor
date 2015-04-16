-- assembled from divu_test.asm on 2015-04-15 16:01:49.38686 CEST

--  Address    Code        Basic                     Source
-- 
-- 0x00000000  0x3c01ffff  lui $1,0xffffffff     7         ori $2, $0, 0xFFFFFFFF
-- 0x00000004  0x3421ffff  ori $1,$1,0x0000ffff       
-- 0x00000008  0x00011025  or $2,$0,$1                
-- 0x0000000c  0x3c01ffff  lui $1,0xffffffff     8         ori $3, $0, 0xFFFFFFFF
-- 0x00000010  0x3421ffff  ori $1,$1,0x0000ffff       
-- 0x00000014  0x00011825  or $3,$0,$1                
-- 0x00000018  0x204604cf  addi $6,$2,0x000004cf 9         addi $6, $2,1231
-- 0x0000001c  0x0043001b  divu $2,$3            11        divu $2, $3
-- 0x00000020  0x00002010  mfhi $4               12        mfhi $4
-- 0x00000024  0x00002812  mflo $5               13        mflo $5
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00111100000000011111111111111111",
"00110100001000011111111111111111",
"00000000000000010001000000100101",
"00111100000000011111111111111111",
"00110100001000011111111111111111",
"00000000000000010001100000100101",
"00100000010001100000010011001111",
"00000000010000110000000000011011",
"00000000000000000010000000010000",
"00000000000000000010100000010010",

OTHERS => "00000000000000000000000000000000");

END;
