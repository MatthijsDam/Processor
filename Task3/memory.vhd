--------------------------------------------------------------
-- 
-- Clock driven Memory (results in 1 clockcycle delay) 
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;
USE work.program.ALL;

ENTITY memory IS
	PORT(
		address_bus	: IN  std_logic_vector(31 DOWNTO 0);
		databus_in	: IN  std_logic_vector(31 DOWNTO 0);
		databus_out : OUT std_logic_vector(31 DOWNTO 0);
		write		: IN  std_logic;
		clk			: IN  std_logic
	);
END memory;

ARCHITECTURE behaviour OF memory IS	
	SIGNAL mem 		: mem_array := work.program.program;
	
	BEGIN
		PROCESS(clk,address_bus)
			VARIABLE address 	: INTEGER;
	
		BEGIN
			IF to_integer(unsigned(address_bus(31 DOWNTO 2))) <= high_address THEN
				address 	:=  to_integer(unsigned(address_bus(31 DOWNTO 2)));
			END	IF;
			
		    databus_out <= mem(address);
			IF rising_edge(clk) THEN
				IF write = '1' THEN
					mem(address) <= databus_in;		
				END IF;
			END IF;
		END PROCESS;

END ARCHITECTURE;


