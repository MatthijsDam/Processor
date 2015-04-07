LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE types IS
	TYPE fsm_state_t IS (fetch, decode, execute, write_back,mem_read);
	TYPE alu_sel_t 	 IS (alu_add,alu_and,alu_or,alu_xor);
	TYPE reg_bank_t  IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0);
	
	TYPE alu_ina_t 	 IS (m_pc,m_reg);
	TYPE alu_inb_t	 IS (m_pc4,m_reg,m_imm,m_immb);
END types;