-- assembled from /mnt/Data/Bibliotheken/Dropbox/DDS processor assignment (1)/Test_prog/Assembly/sw.asm on 2015-04-14 22:58:47.203865 CEST

--  Address    Code        Basic                     Source
-- 
-- 0x00000000  0x3402000a  ori $2,$0,0x0000000a  5         ori $2, $0, 10
-- 0x00000004  0x00420018  mult $2,$2            6         mult $2, $2
-- 0x00000008  0x0042001b  divu $2,$2            7         divu $2, $2
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00110100000000100000000000001010",
"00000000010000100000000000011000",
"00000000010000100000000000011011",

OTHERS => "00000000000000000000000000000000");

END;
