--------------------------------------------------------------
-- 
-- Top Entity
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY topEntity IS
	PORT(
		reset 	: IN std_logic;
		clk		: IN std_logic
	);
END topEntity;

ARCHITECTURE behaviour OF topEntity IS
	
	component compare
		PORT(
			address_bus_mem : OUT std_logic_vector(31 DOWNTO 0);
			address_bus_bhv : IN  std_logic_vector(31 DOWNTO 0);
			address_bus_alg : IN  std_logic_vector(31 DOWNTO 0);
			data_bus_bhv 	: IN  std_logic_vector(31 DOWNTO 0);
			data_bus_alg 	: IN  std_logic_vector(31 DOWNTO 0);
			write_mem       : OUT std_logic;
			write_bhv		: IN  std_logic;
			write_alg		: IN  std_logic;
			enable_bhv		: OUT std_logic;
			clk             : IN  std_logic
		);
	END component;	
	
	component processor_bhv
		PORT(
			address_bus	: OUT std_logic_vector(31 DOWNTO 0);
			databus_in	: IN  std_logic_vector(31 DOWNTO 0);
			databus_out : OUT std_logic_vector(31 DOWNTO 0);
			write 		: OUT std_logic;
			reset		: IN  std_logic;
			enable 		: IN  std_logic;
			clk			: IN  std_logic
		);
	END component;
	
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


	SIGNAL address_mem		: std_logic_vector(31 DOWNTO 0);
	SIGNAL address_bus_bhv	: std_logic_vector(31 DOWNTO 0);
	SIGNAL address_bus_alg	: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL data_bus_bhv	: std_logic_vector(31 DOWNTO 0);
	SIGNAL data_bus_alg	: std_logic_vector(31 DOWNTO 0);
	SIGNAL databus		: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL write_mem	: std_logic;
	SIGNAL write_bhv	: std_logic;
	SIGNAL write_alg	: std_logic;
	
	SIGNAL enable_bhv	: std_logic;


	BEGIN
		comp : compare
		PORT MAP(
				address_bus_mem	=> address_mem,
				address_bus_bhv	=> address_bus_bhv,
				address_bus_alg	=> address_bus_alg,
				data_bus_bhv 	=> data_bus_bhv,
				data_bus_alg	=> data_bus_alg,
				write_mem		=> write_mem,
				write_bhv		=> write_bhv,
				write_alg 		=> write_alg,
				enable_bhv 		=> enable_bhv,
				clk             => clk
				);
		
		proc1 : processor_bhv
		PORT MAP(
				address_bus => address_bus_bhv,
				databus_in	=> databus,
				databus_out => data_bus_bhv,
				write		=> write_bhv,
				reset		=> reset,
				enable		=> enable_bhv,
				clk			=> clk
				);
				
		proc2 : processor_alg
		PORT MAP(
				address_bus => address_bus_alg,
				databus_in	=> databus,
				databus_out => data_bus_alg,
				write		=> write_alg,
				reset		=> reset,
				clk			=> clk
				);		

		mem : memory
		PORT MAP(
				address_bus => address_mem,
				databus_in	=> data_bus_bhv,
				databus_out => databus,
				write		=> write_mem,
				clk			=> clk
				);

END ARCHITECTURE;