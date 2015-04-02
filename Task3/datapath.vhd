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
		address_bus : OUT std_logic_vector(31 DOWNTO 0);
		databus_out	: OUT std_logic_vector(31 DOWNTO 0);
		pcwrite 	: IN  std_logic;
		alu_srca 	: IN  std_logic;
		alu_srcb 	: IN  std_logic;
		alu_sel     : IN  alu_sel_t;
		);
END datapath;

ARCHITECTURE behaviour OF datapath IS

BEGIN
    SIGNAL reg 				: reg_bank_t := 
		("00000000000000000000000000000000",
		OTHERS => "00000000000000000000000000000000"
		);
    SIGNAL reg_LO, reg_HI	: std_logic_vector(31 DOWNTO 0); 
	
BEGIN
	PROCESS(clk) 
		VARIABLE pc 		: std_logic_vector(31 DOWNTO 0); -- increment by ALU
		VARIABLE alu_inp1 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_inp2 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_out 	: std_logic_vector(31 DOWNTO 0);
	BEGIN
		IF reset='1' THEN 
            pc              := 0;
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";

		ELSIF rising_edge(clk) THEN
		
			CASE alu_srca IS
				WHEN '0' =>
					alu_inp1 <= pc;
				WHEN '1' =>
					alu_inp1 <=
			END CASE;
			
			CASE alu_srcb IS
			
			END CASE;
			
			CASE alu_sel IS
				WHEN alu_add =>
					alu_out := alu_inp1 + alu_inp2; --fix
				WHEN alu_and =>
					alu_out := alu_inp1 AND alu_inp2;
				WHEN alu_or =>
					alu_out := alu_inp1 OR alu_inp2;
				WHEN alu_xor	
					alu_out := alu_inp1 XOR alu_inp2;
			END CASE;

			CASE pcwrite IS
				WHEN '0' =>
					address_bus <= pc;
				WHEN '1' =>
					address_bus <= alu_out;
			END CASE;
			
			
			
		END IF;
	END PROCESS;	
END ARCHITECTURE;
