--------------------------------------------------------------
-- 
-- Data path
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;

ENTITY datapath IS
    PORT(
		alu_sel     : IN alu_sel_t;
		databus_out	: OUT std_logic_vector(31 DOWNTO 0);
		);
END datapath;

ARCHITECTURE behaviour OF datapath IS

BEGIN
    SIGNAL reg 					: reg_bank_t := 
         ("00000000000000000000000000000000",
          OTHERS => "00000000000000000000000000000000"
          );
    SIGNAL reg_LO, reg_HI     	: std_logic_vector(31 DOWNTO 0); 
	
BEGIN
	PROCESS(clk) 
		VARIABLE pc 		: std_logic_vector(31 DOWNTO 0); -- increment by ALU
		VARIABLE operand1 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE operand2 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_out 	: std_logic_vector(31 DOWNTO 0);
	BEGIN
		IF reset='1' THEN 
            pc              := 0;
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";


		ELSIF rising_edge(clk) THEN
		
			CASE alu_sel IS
				WHEN alu_add =>
					alu_out := operand1 + operand2; --fix
				WHEN alu_and =>
					alu_out := operand1 and operand2;
				WHEN alu_or =>
					alu_out := operand1 or operand2;
				WHEN alu_xor	
					alu_out := operand1 xor operand2;
			END CASE;
		
		END IF;
	END PROCESS;	
END ARCHITECTURE;
