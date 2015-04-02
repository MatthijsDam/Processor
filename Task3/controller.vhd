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
		write	        : OUT std_logic;
		iord			: OUT std_logic;
		pcwrite			: OUT std_logic;
		alu_srca 		: OUT std_logic;
		alu_srcb 		: OUT std_logic;
		alu_sel 		: OUT alu_sel_t;
		irWrite 		: OUT std_logic;
		regWrite		: OUT std_logic;
		opcode_c 		: IN  std_logic_vector(5 DOWNTO 0);
		funct_c			: IN  std_logic_vector(5 DOWNTO 0)
		);
END controller;

ARCHITECTURE behaviour OF controller IS
	SIGNAL state 	: fsm_state_t;

BEGIN
		PROCESS(clk)
		BEGIN
			IF reset='1' THEN 
				state 		<= fetch;
				write 		<= '0';
				iord 		<= '0';
				irWrite 	<= '0';
				regWrite 	<= '0';
				pcwrite		<= '0';
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
						iord 		<= '-';
						irWrite 	<= '0';
						regWrite 	<= '0';
						pcwrite		<= '0';
						
						CASE opcode_c IS
							WHEN Rtype =>
								alu_srca	<= '1';
								alu_srcb	<= '1';
								CASE funct_c IS
									WHEN F_add =>
										alu_sel 	<= alu_add;
									WHEN F_and =>
										alu_sel 	<= alu_and;
									WHEN F_or =>	
										alu_sel 	<= alu_or;
									WHEN F_xor =>	
										alu_sel 	<= alu_xor;
									WHEN others =>
								END CASE;
							WHEN others =>

						END CASE;
						
						state 		<= write_back;
					WHEN write_back =>
						regWrite 	<= '1';
						
						-- increase program counter
						alu_srca	<= '0';
						alu_srcb	<= '0';
						pcwrite		<= '1';
						
						state 		<= fetch;
				END CASE;
			END IF;
		END PROCESS;

END ARCHITECTURE;
