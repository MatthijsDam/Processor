LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE types IS
	TYPE fsm_state_t IS (fetch, decode, execute, mem_pc, write_back);
	TYPE alu_sel_t 	 IS (alu_add, alu_sub,alu_and,alu_or,alu_xor);
	TYPE pc_src_t    IS (pc_jump, pc_alu);
	TYPE reg_bank_t  IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0);
	TYPE fsm_mult_t  IS (mult_s, mult_n, mult_e);
	TYPE fsm_divu_t  IS (divu_s, divu_n, divu_e);
	TYPE alu_ina_t 	 IS (m_pc,m_reg,m_regHI,m_regLO);
	TYPE alu_inb_t	 IS (m_pc4,m_reg,m_reg_invert,m_imma, m_immasl2, m_imml,m_imm_upper);
	TYPE hi_select_t   IS (hi_0, hi_shift_left, hi_shift_right );
	TYPE lo_select_t   IS (lo_operandA, lo_shift_left, lo_shift_right, lo_0 );
	TYPE operation_t IS (divu,mult,branch,other);
END types;
