--------------------------------------------------------------
-- 
-- Processor
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY processor IS
	PORT(
		address_bus	: OUT std_logic_vector(31 DOWNTO 0);
		databus_in	: IN  std_logic_vector(31 DOWNTO 0);
		databus_out : OUT std_logic_vector(31 DOWNTO 0);
		read		: OUT std_logic;
		write 		: OUT std_logic;
		reset		: IN  std_logic;
		clk			: IN  std_logic
	);
END processor;

ARCHITECTURE behaviour OF processor IS

BEGIN
	PROCESS(clk,reset)
		VARIABLE pc 			: INTEGER := 0;
		VARIABLE instruction 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE opcode			: std_logic_vector(5 DOWNTO 0);
		VARIABLE funct			: std_logic_vector(5 DOWNTO 0);

	-- A read operation has 1 clock cycle delay
	PROCEDURE memory_read(
				pc 	 : IN INTEGER; 
				data : OUT std_logic_vector(31 DOWNTO 0)) IS
		
		VARIABLE address 	: std_logic_vector(31 DOWNTO 0);

		BEGIN
			read 		<= '1';
			address 	:= std_logic_vector(to_unsigned(pc,30)) & "00";
			address_bus <= address;
			data 		:= databus_in;
	END memory_read;

	PROCEDURE memory_write(
					address : IN std_logic_vector(31 DOWNTO 0); 
					data 	: IN std_logic_vector(31 DOWNTO 0)) IS
		
		BEGIN
			write 		<= '1';
			databus_out <= data;
	END memory_write;		

	BEGIN
		IF reset='1' THEN 
			pc 			:= 0;
			read 		<= '0';
			write 		<= '0';
			databus_out <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
			address_bus <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
		ELSIF rising_edge(clk) THEN
			
			--
			-- Instruction fetch
			--
			memory_read(pc,instruction);

			-- Increase program counter
			pc := pc+1;

			--
			-- Decode and execute
			--
			opcode 		:= instruction(31 DOWNTO 26);
			funct 	 	:= instruction(5 DOWNTO 0);

			--CASE opcode IS

		END IF;
	END PROCESS;

END ARCHITECTURE;