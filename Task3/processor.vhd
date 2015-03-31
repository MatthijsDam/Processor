--------------------------------------------------------------
-- 
-- Processor
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;

ENTITY processor IS
    PORT(
        address_bus     : OUT std_logic_vector(31 DOWNTO 0);
        databus_in      : IN  std_logic_vector(31 DOWNTO 0);
        databus_out     : OUT std_logic_vector(31 DOWNTO 0);
        write           : OUT std_logic;
        reset           : IN  std_logic;
        clk             : IN  std_logic
    );
END processor;

ARCHITECTURE behaviour OF processor IS

	component datapath
		PORT(
		alu_sel     	: IN  alu_sel_t;
		databus_out		: OUT std_logic_vector(31 DOWNTO 0);
		reset 			: IN  std_logic;
		clk 			: IN  std_logic;
		);
	END component;	
	
	component controller
		PORT(
		address_bus     : OUT std_logic_vector(31 DOWNTO 0);
		write           : OUT std_logic;
		alu_sel 		: OUT alu_sel_t;
		reset 			: IN  std_logic;
		clk 			: IN  std_logic;
		);
	END component;	
	
	SIGNAL address_bus 	: std_logic_vector(31 DOWNTO 0);
	SIGNAL write 		: std_logic;
	SIGNAL alu_sel		: alu_sel_t;
	SIGNAL clk 			: std_logic;
	
BEGIN
		
	
	
END ARCHITECTURE;