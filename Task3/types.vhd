LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE types IS
	TYPE fsm_state_t IS (fetch, decode, execute, write_back);
	TYPE alu_sel_t 	 IS (alu_add,alu_and,alu_or,alu_xor);
	TYPE reg_bank_t  IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0);
END types;