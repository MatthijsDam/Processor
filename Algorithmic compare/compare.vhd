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
		data_bus_bhv 	: IN  std_logic_vector(31 DOWNTO 0);
		data_bus_alg 	: IN  std_logic_vector(31 DOWNTO 0);
        write_mem       : OUT std_logic;
		write_bhv		: IN  std_logic;
		write_alg		: IN  std_logic;
		enable_bhv		: OUT std_logic;
        clk             : IN  std_logic
    );
END compare;

ARCHITECTURE behaviour OF compare IS

BEGIN
	PROCESS(address_bus_bhv,address_bus_alg)
	BEGIN
		IF address_bus_bhv = address_bus_alg THEN
			address_bus_mem <= address_bus_bhv;
			write_mem 		<= write_bhv;
			enable_bhv 		<= '1';
		ELSE
			enable_bhv 		<= '0';
		END IF;

	END PROCESS;

END ARCHITECTURE;