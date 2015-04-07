
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
	SIGNAL proc_data_in	: std_logic_vector(31 DOWNTO 0);
	SIGNAL mem_data_in 	: std_logic_vector(31 DOWNTO 0);
	SIGNAL write 		: std_logic;

	BEGIN
		proc : processor
		PORT MAP(
				address_bus => address_bus,
				databus_in	=> proc_data_in,
				databus_out => mem_data_in,
				write		=> write,
				reset		=> reset,
				clk			=> clk
				);

		mem : memory
		PORT MAP(
				address_bus => address_bus,
				databus_in	=> mem_data_in,
				databus_out => proc_data_in,
				write		=> write,
				clk			=> clk
				);

END ARCHITECTURE;
