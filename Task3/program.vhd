-- assembled from Rtype_add_and_or_xor.asm
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE program IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	CONSTANT program : mem_array := (
"00000000010000110010000000100000",
"00000000010000110010100000100100",
"00000000010000110011000000100101",
"00000000010000110011000000100110",

OTHERS => "00000000000000000000000000000000");

END;