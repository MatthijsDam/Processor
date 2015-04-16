
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY topEntity_compare IS
	PORT(
		reset 	: IN std_logic;
		clk		: IN std_logic
	);
END topEntity_compare;

ARCHITECTURE behaviour OF topEntity_compare IS
	
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
	
	component memory
		PORT(
			address_bus	: IN  std_logic_vector(31 DOWNTO 0);
			databus_in	: IN  std_logic_vector(31 DOWNTO 0);
			databus_out : OUT std_logic_vector(31 DOWNTO 0);
			write 		: IN  std_logic;	
			clk			: IN  std_logic
			);
	END component;

	component compare
		PORT(
			address_bus_mem : OUT std_logic_vector(31 DOWNTO 0);
			address_bus_bhv : IN  std_logic_vector(31 DOWNTO 0);
			address_bus_alu : IN  std_logic_vector(31 DOWNTO 0);
			data_bus_bhv 	: IN  std_logic_vector(31 DOWNTO 0);
			data_bus_alu 	: IN  std_logic_vector(31 DOWNTO 0);
			write_mem       : OUT std_logic;
			write_bhv		: IN  std_logic;
			write_alu		: IN  std_logic;
			enable_bhv		: OUT std_logic;
			reset           : IN  std_logic
			);
	END component;
	
	SIGNAL address_mem		: std_logic_vector(31 DOWNTO 0);
	SIGNAL address_bus_bhv	: std_logic_vector(31 DOWNTO 0);
	SIGNAL address_bus_alu	: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL data_bus_bhv	: std_logic_vector(31 DOWNTO 0);
	SIGNAL data_bus_alu	: std_logic_vector(31 DOWNTO 0);
	SIGNAL databus		: std_logic_vector(31 DOWNTO 0);
	
	SIGNAL write_mem	: std_logic;
	SIGNAL write_bhv	: std_logic;
	SIGNAL write_alu	: std_logic;
	
	SIGNAL enable_bhv	: std_logic;

	BEGIN	
		-- PSL default clock is rising_edge(clk);
		-- PSL psl_address_bus:assert forall i in {0 to 255} :  
		--   always (to_integer(unsigned(address_bus_bhv)) = 4*i) -> next_e[0 to 36](to_integer(unsigned(address_bus_alu)) = 4*i); 
		comp : compare
		PORT MAP(
				address_bus_mem	=> address_mem,
				address_bus_bhv	=> address_bus_bhv,
				address_bus_alu	=> address_bus_alu,
				data_bus_bhv 	=> data_bus_bhv,
				data_bus_alu	=> data_bus_alu,
				write_mem		=> write_mem,
				write_bhv		=> write_bhv,
				write_alu 		=> write_alu,
				enable_bhv 		=> enable_bhv,
				reset           => reset
				);
				
		proc : processor
		PORT MAP(
				address_bus => address_bus_alu,
				databus_in	=> databus,
				databus_out => data_bus_alu,
				write		=> write_alu,
				reset		=> reset,
				clk			=> clk
				);
				
		proc_bhv : processor_bhv
		PORT MAP(
				address_bus => address_bus_bhv,
				databus_in	=> databus,
				databus_out => data_bus_bhv,
				write		=> write_bhv,
				reset		=> reset,
				enable		=> enable_bhv,
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
