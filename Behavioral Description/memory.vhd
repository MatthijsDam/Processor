--------------------------------------------------------------
-- 
-- Clock driven Memory (results in 1 clockcycle delay) 
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY memory IS
	PORT(
		address_bus	: IN  std_logic_vector(31 DOWNTO 0);
		databus_in	: IN  std_logic_vector(31 DOWNTO 0);
		databus_out : OUT std_logic_vector(31 DOWNTO 0);
		read		: IN  std_logic;
		write 		: IN  std_logic;	
		clk			: IN  std_logic
	);
END memory;

ARCHITECTURE behaviour OF memory IS

BEGIN
	PROCESS(clk)
		CONSTANT low_address	: INTEGER := 0; 
		CONSTANT high_address	: INTEGER := 256;

		TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);

		VARIABLE address 	: INTEGER;
		VARIABLE mem 		: mem_array := 
				("00000000000000000000000000000000",
				"00110100000010000000000010101011",
				"00111100000000010000000000000010",
				"00110100001000010101010101010101",
				"00000000000000010100100000100101",
				"00000001000010010101000000100000",
				OTHERS => "00000000000000000000000000000000"
				);

	BEGIN
		IF rising_edge(clk) THEN
			address :=  to_integer(unsigned(address_bus(31 DOWNTO 2)));

			IF write = '1' THEN
				mem(address) := databus_in;
			ELSE 
				-- Read instruction
				databus_out  <= mem(address);
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;
