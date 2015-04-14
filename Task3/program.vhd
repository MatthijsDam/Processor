-- assembled from /mnt/Data/Bibliotheken/Dropbox/DDS processor assignment (1)/Test_prog/Assembly/sw.asm on 2015-04-14 14:42:59.994256 CEST

--  Address    Code        Basic                     Source
-- 
-- 0x00000000  0x34020064  ori $2,$0,0x00000064  5         ori $2, $0, 100
-- 0x00000004  0x200300c8  addi $3,$0,0x000000c8 6         addi $3, $0, 200
-- 0x00000008  0xac020050  sw $2,0x00000050($0)  8         sw $2, 80($0)
-- 0x0000000c  0xac030054  sw $3,0x00000054($0)  9         sw $3, 84($0)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00110100000000100000000001100100",
"00100000000000110000000011001000",
"10101100000000100000000001010000",
"10101100000000110000000001010100",

OTHERS => "00000000000000000000000000000000");

END;
