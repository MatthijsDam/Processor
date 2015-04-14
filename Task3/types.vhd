LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE types IS
	TYPE fsm_state_t IS (fetch, decode, execute, mem_pc, write_back);
	TYPE alu_sel_t 	 IS (alu_add, alu_sub,alu_and,alu_or,alu_xor);
	TYPE reg_bank_t  IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0);
	
	TYPE alu_ina_t 	 IS (m_pc,m_reg);
	TYPE alu_inb_t	 IS (m_pc4,m_reg,m_reg_invert,m_imm,m_imm_upper);
END types;
