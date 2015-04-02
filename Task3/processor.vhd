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
			clk 		: IN  std_logic;
			reset		: IN  std_logic;
			address_bus : OUT std_logic_vector(31 DOWNTO 0);
			databus_out	: OUT std_logic_vector(31 DOWNTO 0);
			databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
			pcwrite 	: IN  std_logic;
			alu_srca 	: IN  std_logic;
			alu_srcb 	: IN  std_logic;
			alu_sel     : IN  alu_sel_t;
			memRead		: IN  std_logic;
			irWrite 	: IN  std_logic;
			regWrite 	: IN  std_logic;
			opcode_c	: OUT std_logic_vector(5 DOWNTO 0);
			funct_c		: OUT std_logic_vector(5 DOWNTO 0)
		);
	END component;	
	
	component controller
		PORT(
			clk 			: IN  std_logic;
			reset 			: IN  std_logic;
			memWrite        : OUT std_logic;
			memRead			: OUT std_logic;
			pcwrite			: OUT std_logic;
			alu_srca 		: OUT std_logic;
			alu_srcb 		: OUT std_logic;
			alu_sel 		: OUT alu_sel_t;
			irWrite 		: OUT std_logic;
			regWrite		: OUT std_logic;
			opcode_c 		: IN  std_logic_vector(5 DOWNTO 0);
			funct_c			: IN  std_logic_vector(5 DOWNTO 0)
		);
	END component;	
	
	SIGNAL address_bus 	: std_logic_vector(31 DOWNTO 0);
	SIGNAL write 		: std_logic;
	SIGNAL alu_sel		: alu_sel_t;
	SIGNAL clk 			: std_logic;
	
BEGIN
		
	
	
END ARCHITECTURE;