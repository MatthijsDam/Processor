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
		clk 		: IN  std_logic;
		reset		: IN  std_logic;
		address_bus : OUT std_logic_vector(31 DOWNTO 0);
		databus_out	: OUT std_logic_vector(31 DOWNTO 0);
		databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
		pcwrite 	: IN  std_logic;
		alu_srca 	: IN  std_logic;
		alu_srcb 	: IN  std_logic;
		alu_sel     : IN  alu_sel_t;
		iord		: IN  std_logic;
		irWrite 	: IN  std_logic;
		regWrite 	: IN  std_logic;	
		opcode_c	: OUT std_logic_vector(5 DOWNTO 0);
		funct_c		: OUT std_logic_vector(5 DOWNTO 0)
		);
END datapath;

ARCHITECTURE behaviour OF datapath IS

BEGIN
    SIGNAL reg 				: reg_bank_t := 
		("00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000010",
		"00000000000000000000000000000011",
		OTHERS => "00000000000000000000000000000000"
		);
    SIGNAL reg_LO, reg_HI	: std_logic_vector(31 DOWNTO 0); 
	SIGNAL pc		 		: std_logic_vector(31 DOWNTO 0); -- increment by ALU
	
	-- Instruction register
	SIGNAL opcode           : std_logic_vector(5 DOWNTO 0);
	SIGNAL funct			: std_logic_vector(5 DOWNTO 0);
	SIGNAL src				: std_logic_vector(4 DOWNTO 0);
	SIGNAL src_tgt			: std_logic_vector(4 DOWNTO 0);
	SIGNAL dst				: std_logic_vector(4 DOWNTO 0);
	SIGNAL alu_reg			: std_logic_vector(31 DOWNTO 0);
	
BEGIN
	PROCESS(clk) 
		VARIABLE alu_inp0 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_inp1 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_out 	: std_logic_vector(31 DOWNTO 0);
	BEGIN
		IF reset='1' THEN 
            pc              <= 0;
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";

		ELSIF rising_edge(clk) THEN
			CASE iord IS
				WHEN '0' =>
					address_bus <= pc;
				WHEN '1' =>
					address_bus <= alu_out;
			END CASE;
			
			IF irWrite ='1' THEN
				opcode      <= databus_in(31 DOWNTO 26);
				src 		<= databus_in(25 DOWNTO 21);
				src_tgt		<= databus_in(20 DOWNTO 16);
				dst 		<= databus_in(15 DOWNTO 11);
				funct		<= databus_in(5 DOWNTO 0);
			END IF;
			
			-- Controller values
			opcode_c 	<= opcode;
			funct_c		<= funct;		
				
			IF regWrite ='1' THEN
				reg(dst) <= alu_reg; -- add multiplexer
			END IF;
			
			CASE alu_srca IS
				WHEN '0' =>
					alu_inp0 := pc;
				WHEN '1' =>
					alu_inp0 := reg(src);
			END CASE;

			CASE alu_srcb IS
				WHEN '0' =>
					alu_inp1 := 4;
				WHEN '1' =>
					alu_inp1 := reg(src_tgt);
			END CASE;	


			CASE alu_sel IS
				WHEN alu_add =>
					alu_out := alu_inp0 + alu_inp1;
				WHEN alu_and =>
					alu_out := alu_inp0 AND alu_inp1;
				WHEN alu_or =>
					alu_out := alu_inp0 OR alu_inp1;
				WHEN alu_xor	
					alu_out := alu_inp0 XOR alu_inp1;
			END CASE;	

			-- Store ALU output in a register
			alu_reg 	<= alu_out;			
			
			IF pcwrite ='1' THEN
				pc <= alu_out;
			END IF;
			
		END IF;
	END PROCESS;	
END ARCHITECTURE;
