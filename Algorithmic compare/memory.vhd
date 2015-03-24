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
		write		: IN  std_logic;
		clk			: IN  std_logic
	);
END memory;

ARCHITECTURE behaviour OF memory IS
	CONSTANT low_address	: INTEGER := 0; 
	CONSTANT high_address	: INTEGER := 255;

	TYPE mem_array IS ARRAY (low_address TO high_address) OF std_logic_vector(31 DOWNTO 0);
	
	SIGNAL mem 		: mem_array := 
					 ("00111100000000011000000000000000",
"00110100001000010000000000000000",
"00000000000000010001000000100101",
"00111100000000010111111111111111",
"00110100001000011111111111111111",
"00000000000000010001100000100101",
"00000000010000100000000000011000",
"00000000000000000010000000010000",
"00000000000000000010100000010010",
"00000000011000110000000000011000",
"00000000000000000011000000010000",
"00000000000000000011100000010010",
"00000000010000110000000000011000",
"00000000000000000100000000010000",
"00000000000000000100100000010010",
"00000000011000100000000000011000",
"00000000000000000101000000010000",
"00000000000000000101100000010010",
						OTHERS => "00000000000000000000000000000000"
						);

	
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


