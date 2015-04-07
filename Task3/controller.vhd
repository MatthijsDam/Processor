--------------------------------------------------------------
-- 
-- Controller
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;
USE instruction_decode_defs.ALL;

ENTITY controller IS
    PORT(
		clk 			: IN  std_logic;
		reset 			: IN  std_logic;
		databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
		write	        : OUT std_logic;
		iord			: OUT std_logic;
		pcwrite			: OUT std_logic;
		regDst			: OUT std_logic;
		alu_srca 		: OUT alu_ina_t;
		alu_srcb 		: OUT alu_inb_t;
		alu_sel 		: OUT alu_sel_t;
		irWrite 		: OUT std_logic;
		regWrite		: OUT std_logic;
		memToReg		: OUT std_logic
		);
END controller;

ARCHITECTURE behaviour OF controller IS
	SIGNAL state 	: fsm_state_t;

BEGIN
		PROCESS(clk,reset)
		BEGIN
			IF reset='1' THEN 
				state 		<= fetch;
				write 		<= '0';
				iord 		<= '0';
				irWrite 	<= '0';
				regWrite 	<= '0';
				pcwrite		<= '0';
				regDst		<= '0';
				memToReg	<= '0';
			ELSIF rising_edge(clk) THEN
				CASE state IS
					WHEN fetch =>
						iord 		<= '0';
						irWrite 	<= '0';
						regWrite 	<= '0';
						pcwrite		<= '0';
						
						state 		<= decode;
					WHEN decode =>
						iord 		<= '0';
						irWrite 	<= '1';
						regWrite 	<= '0';
						pcwrite		<= '0';
						
						state 		<= execute;
					WHEN execute =>
						state 		<= write_back;
						iord 		<= '-';
						irWrite 	<= '0';
						regWrite 	<= '0';
						pcwrite		<= '0';
						
						CASE databus_in(31 DOWNTO 26) IS
							WHEN Rtype =>
								regDst 		<= '0';
								alu_srca	<= m_reg;
								alu_srcb	<= m_reg;
								CASE databus_in(5 DOWNTO 0) IS
									WHEN F_add =>
										alu_sel 	<= alu_add;
									WHEN F_and =>
										alu_sel 	<= alu_and;
									WHEN F_or =>	
										alu_sel 	<= alu_or;
									WHEN F_xor =>	
										alu_sel 	<= alu_xor;
									WHEN OTHERS =>
								END CASE;
							
							WHEN Iadd =>
								regDst		<= '1';
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_add;
								
							WHEN Iand =>
								regDst		<= '1';						
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_and;
							
							WHEN Ior =>
								regDst		<= '1';					
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_or;
	

							WHEN Ilw =>
								regDst		<= '1';
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_add;
								iord 		<= '1';
								
								state 		<= mem_read;
							WHEN OTHERS =>

						END CASE;
						
						
					WHEN write_back =>
						regWrite 	<= '1';
						memToReg 	<= '0';
						
						-- increase program counter
						alu_srca	<= m_pc;
						alu_srcb	<= m_pc4;
						pcwrite		<= '1';
						alu_sel 	<= alu_add;
						iord		<= '0';
						
						state 		<= fetch;
						
					WHEN mem_read =>	
						irWrite 	<= '1';
						memToReg 	<= '1';
						
						-- increase program counter
						alu_srca	<= m_pc;
						alu_srcb	<= m_pc4;
						pcwrite		<= '1';
						alu_sel 	<= alu_add;
						iord		<= '0';
						
						state 		<= fetch;
				END CASE;
			END IF;
		END PROCESS;

END ARCHITECTURE;
