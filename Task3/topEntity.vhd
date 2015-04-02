
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY topEntity_processor IS
	PORT(
		reset 	: IN std_logic;
		clk		: IN std_logic
	);
END topEntity_processor;

ARCHITECTURE behaviour OF topEntity_processor IS
	
	component processor
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
		proc : processor
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
