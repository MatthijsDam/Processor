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
			iord		: IN  std_logic;
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
			write	        : OUT std_logic;
			iord			: OUT std_logic;
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
	
	SIGNAL alu_sel		: alu_sel_t;
	SIGNAL iord			: std_logic;
	SIGNAL pcwrite		: std_logic;
	SIGNAL alu_srca 	: std_logic;
	SIGNAL alu_srcb		: std_logic;
	SIGNAL alsu_sel		: std_logic;
	SIGNAL irWrite 		: OUT std_logic;
	SIGNAL regWrite		: OUT std_logic;
	SIGNAL opcode_c 	: IN  std_logic_vector(5 DOWNTO 0);
	SIGNAL funct_c		: IN  std_logic_vector(5 DOWNTO 0);
	
BEGIN

	contr : controller
	PORT MAP(
		clk => clk,
		reset => reset,
		write => write,
		iord => iord,
		pcwrite => pcwrite,
		alu_srca => alu_srca,
		alu_srcb => alu_srcb,
		alu_sel => alu_sel,
		irWrite => irWrite,
		regWrite => regWrite,
		opcode_c => opcode_c,
		funct_c => funct_c	
	);
	
	dtpath : datapath
	PORT MAP(
		clk => clk,
		reset => reset,
		iord => iord,
		pcwrite => pcwrite,
		alu_srca => alu_srca,
		alu_srcb => alu_srcb,
		alu_sel => alu_sel,
		irWrite => irWrite,
		regWrite => regWrite,
		opcode_c => opcode_c,
		funct_c => funct_c,
		address_bus => address_bus,
		databus_out => databus_out,
		databus_in => databus_in
	);	
END ARCHITECTURE;