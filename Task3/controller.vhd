--------------------------------------------------------------
-- 
-- Controller
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;

ENTITY controller IS
    PORT(
		address_bus     : OUT std_logic_vector(31 DOWNTO 0);
		write           : OUT std_logic;
		alu_sel 		: OUT alu_sel_t;
		reset 			: IN  std_logic;
		clk 			: IN  std_logic;
		);
END controller;

ARCHITECTURE behaviour OF controller IS

END ARCHITECTURE;