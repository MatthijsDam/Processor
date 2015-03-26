--------------------------------------------------------------
-- 
-- Behavioral description
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY topEntity_alg IS
	PORT(
		reset 	: IN std_logic;
		clk		: IN std_logic
	);
END topEntity_alg;

ARCHITECTURE behaviour OF topEntity_alg IS
	
	component processor_alg
		PORT(
			address_bus	: OUT std_logic_vector(31 DOWNTO 0);
			databus_in	: IN  std_logic_vector(31 DOWNTO 0);
			databus_out : OUT std_logic_vector(31 DOWNTO 0);
			write 		: OUT std_logic;
			reset		: IN  std_logic;
			clk			: IN  std_logic
		);
	END component;

	component memory
		PORT(
			address_bus	: IN  std_logic_vector(31 DOWNTO 0);
			databus_in	: IN  std_logic_vector(31 DOWNTO 0);
			databus_out : OUT std_logic_vector(31 DOWNTO 0);
			write 		: IN  std_logic;	
			clk			: IN  std_logic
			);
	END component;

	SIGNAL address_bus	: std_logic_vector(31 DOWNTO 0);
	SIGNAL databus1		: std_logic_vector(31 DOWNTO 0);
	SIGNAL databus2 	: std_logic_vector(31 DOWNTO 0);
	SIGNAL write 		: std_logic;

	BEGIN
		proc : processor_alg
		PORT MAP(
				address_bus => address_bus,
				databus_in	=> databus1,
				databus_out => databus2,
				write		=> write,
				reset		=> reset,
				clk			=> clk
				);

		mem : memory
		PORT MAP(
				address_bus => address_bus,
				databus_in	=> databus2,
				databus_out => databus1,
				write		=> write,
				clk			=> clk
				);

END ARCHITECTURE;
