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
		address_bus_alu : IN  std_logic_vector(31 DOWNTO 0);
		data_bus_bhv 	: IN  std_logic_vector(31 DOWNTO 0);
		data_bus_alu 	: IN  std_logic_vector(31 DOWNTO 0);
        write_mem       : OUT std_logic;
		write_bhv		: IN  std_logic;
		write_alu		: IN  std_logic;
		enable_bhv		: OUT std_logic;
        reset           : IN  std_logic
    );
END compare;

ARCHITECTURE behaviour OF compare IS

BEGIN
	PROCESS(reset,address_bus_bhv,address_bus_alu)
		VARIABLE previous_data_on_bus          : std_logic_vector(31 DOWNTO 0);
		VARIABLE previous_address_on_bus	: std_logic_vector(31 DOWNTO 0);
	BEGIN
	    IF(reset = '0') THEN
		    IF address_bus_bhv = address_bus_alu AND write_bhv = '0' AND write_alu = '0' THEN -- beide lezen van hetzelde address
			    address_bus_mem 	<= address_bus_bhv;
			    write_mem 		<= write_bhv;
			    enable_bhv 		<= '1';
			    previous_address_on_bus 	:= address_bus_alu;
			    previous_data_on_bus		:= data_bus_alu;
		    ELSIF address_bus_bhv = address_bus_alu AND write_bhv = '1' AND write_alu = '1' AND data_bus_alu = data_bus_bhv THEN -- beide schrijven dezelfde value naar hetzelfde address
			    address_bus_mem 	<= address_bus_bhv;
			    write_mem 		<= write_bhv;
			    enable_bhv 		<= '1';
			    previous_address_on_bus 	:= address_bus_alu;
			    previous_data_on_bus		:= data_bus_alu;

		    ELSIF address_bus_alu = previous_address_on_bus AND write_bhv = '0' THEN -- bhv lees, alu nog niet zo ver
			    ASSERT false REPORT "Behavioral read pause" SEVERITY warning ;
			    enable_bhv 		<= '0';
		    ELSIF write_bhv = '1' AND write_alu = '0' THEN -- bhv schrijft, alu nog niet zo ver
			    ASSERT false REPORT "Behavioral write pause" SEVERITY warning ;
			    enable_bhv 		<= '0';
			

		    ELSE
			    ASSERT false REPORT "Compare error!" SEVERITY failure ;
			    enable_bhv 		<= '0';
		    END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;
