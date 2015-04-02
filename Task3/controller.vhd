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
				state 	<= fetch;
				write 	<= '0';
				iord 	<= '0';
				irWrite <= '0';
			ELSIF rising_edge(clk) THEN
				CASE state IS
					WHEN fetch =>
						iord 	<= '0';
						irWrite <= '0';
					
					WHEN decode =>
						irWrite <= '1';
						
					WHEN execute =>
						CASE opcode_c IS
							WHEN Rtype =>
								CASE funct_c IS
									
								END CASE;
						END CASE;
					
				END CASE;
			END IF;
		END PROCESS;

END ARCHITECTURE;
