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
			regDst		: IN std_logic;
			alu_srca 	: IN  alu_ina_t;
			alu_srcb 	: IN  alu_inb_t;
			alu_sel     : IN  alu_sel_t;
			iord		: IN  std_logic;
			irWrite 	: IN  std_logic;
			regWrite 	: IN  std_logic;
			memToReg	: IN  std_logic
		);
	END component;	
	
	component controller
		PORT(
			clk 			: IN  std_logic;
			reset 			: IN  std_logic;
			databus_in 		: IN  std_logic_vector(31 DOWNTO 0);
			write	        : OUT std_logic;
			iord			: OUT std_logic;
			pcwrite			: OUT std_logic;
			regDst			: OUT std_logic;			
			alu_srca 		: OUT alu_ina_t;
			alu_srcb 		: OUT alu_inb_t;
			alu_sel 		: OUT alu_sel_t;
			irWrite 		: OUT std_logic;
			regWrite		: OUT std_logic;
			memToReg		: OUT std_logic
		);
	END component;	
	
	SIGNAL alu_sel		: alu_sel_t;
	SIGNAL iord			: std_logic;
	SIGNAL pcwrite		: std_logic;
	SIGNAL alu_srca 	: alu_ina_t;
	SIGNAL alu_srcb		: alu_inb_t;
	SIGNAL alsu_sel		: std_logic;
	SIGNAL irWrite 		: std_logic;
	SIGNAL regWrite		: std_logic;
	SIGNAL regDst		: std_logic;
	SIGNAL memToReg		: std_logic;

	
BEGIN

	contr : controller
	PORT MAP(
		clk 		=> clk,
		reset 		=> reset,
		databus_in 	=> databus_in,
		write		=> write,
		iord 		=> iord,
		pcwrite 	=> pcwrite,
		regDst 		=> regDst,
		alu_srca 	=> alu_srca,
		alu_srcb	=> alu_srcb,
		alu_sel 	=> alu_sel,
		irWrite 	=> irWrite,
		regWrite 	=> regWrite,
		memToReg 	=> memToReg
	);
	
	dtpath : datapath
	PORT MAP(
		clk			=> clk,
		reset 		=> reset,
		iord 		=> iord,
		pcwrite 	=> pcwrite,
		regDst		=> regDst,
		alu_srca 	=> alu_srca,
		alu_srcb 	=> alu_srcb,
		alu_sel 	=> alu_sel,
		irWrite 	=> irWrite,
		regWrite 	=> regWrite,
		address_bus => address_bus,
		databus_out => databus_out,
		databus_in	=> databus_in,
		memToReg 	=> memToReg
	);	
END ARCHITECTURE;