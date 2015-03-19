--------------------------------------------------------------
-- 
-- Compare unit
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY compare IS
    PORT(
        address_bus_mem : OUT std_logic_vector(31 DOWNTO 0);
		address_bus_bhv : IN  std_logic_vector(31 DOWNTO 0);
		address_bus_alg : IN  std_logic_vector(31 DOWNTO 0);
		data_bus_mem 	: OUT std_logic_vector(31 DOWNTO 0);
		data_bus_bhv 	: IN  std_logic_vector(31 DOWNTO 0);
		data_bus_alg 	: IN  std_logic_vector(31 DOWNTO 0);
        write_mem      : OUT std_logic;
		write_bhv		: IN  std_logic;
		write_alg		: IN  std_logic;
		enable_bhv		: OUT std_logic;
        clk             : IN  std_logic
    );
END compare;

ARCHITECTURE behaviour OF compare IS

BEGIN
	PROCESS(clk,address_bus_bhv,address_bus_alg)
	BEGIN
	
	END PROCESS;

END ARCHITECTURE;