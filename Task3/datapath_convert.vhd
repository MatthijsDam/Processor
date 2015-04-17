--------------------------------------------------------------
-- 
-- convert the post-simulation datapath in to an entity with the same interface as datapath
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;

ENTITY datapath_convert IS
    PORT(
		clk 		: IN  std_logic;
		reset		: IN  std_logic;
		address_bus : OUT std_logic_vector(31 DOWNTO 0);
		databus_out	: OUT std_logic_vector(31 DOWNTO 0);
		databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
		pc_src      : IN  pc_src_t;
		pcwrite 	: IN  std_logic;
		regDst		: IN  std_logic;
		alu_srca 	: IN  alu_ina_t;
		alu_srcb 	: IN  alu_inb_t;
		alu_sel     : IN  alu_sel_t;
		alu_carry_in: IN  std_logic;
		div_by_zero : OUT std_logic;
    	hi_select   : IN  hi_select_t;
		lo_select   : IN  lo_select_t;
		hi_lo_write : IN  std_logic;
		iord		: IN  std_logic;
		irWrite 	: IN  std_logic;
		regWrite 	: IN  std_logic;
		memToReg 	: IN  std_logic
		);
END datapath_convert;

ARCHITECTURE converter OF datapath_convert IS

	component datapath_post
    PORT (
	clk : IN std_logic;
	reset : IN std_logic;
	address_bus : OUT std_logic_vector(31 DOWNTO 0);
	databus_out : OUT std_logic_vector(31 DOWNTO 0);
	databus_in : IN std_logic_vector(31 DOWNTO 0);
	pc_src : IN std_logic;
	pcwrite : IN std_logic;
	regDst : IN std_logic;
	\alu_srca.m_pc\ : IN std_logic;
	\alu_srca.m_reg\ : IN std_logic;
	\alu_srca.m_regHI\ : IN std_logic;
	\alu_srca.m_regLO\ : IN std_logic;
	\alu_srcb.m_pc4\ : IN std_logic;
	\alu_srcb.m_reg\ : IN std_logic;
	\alu_srcb.m_reg_invert\ : IN std_logic;
	\alu_srcb.m_imma\ : IN std_logic;
	\alu_srcb.m_imml\ : IN std_logic;
	\alu_srcb.m_imm_upper\ : IN std_logic;
	\alu_sel.alu_add\ : IN std_logic;
	\alu_sel.alu_sub\ : IN std_logic;
	\alu_sel.alu_and\ : IN std_logic;
	\alu_sel.alu_or\ : IN std_logic;
	\alu_sel.alu_xor\ : IN std_logic;
	alu_carry_in : IN std_logic;
	div_by_zero : OUT std_logic;
	\hi_select.hi_0\ : IN std_logic;
	\hi_select.hi_shift_left\ : IN std_logic;
	\hi_select.hi_shift_right\ : IN std_logic;
	\lo_select.lo_operandA\ : IN std_logic;
	\lo_select.lo_shift_left\ : IN std_logic;
	\lo_select.lo_shift_right\ : IN std_logic;
	\lo_select.lo_0\ : IN std_logic;
	hi_lo_write : IN std_logic;
	iord : IN std_logic;
	irWrite : IN std_logic;
	regWrite : IN std_logic;
	memToReg : IN std_logic
	);
	END component;	
	
	
SIGNAL pc_src_new : std_logic;

SIGNAL \alu_srca.m_pc\ : std_logic;
SIGNAL \alu_srca.m_reg\ : std_logic;
SIGNAL \alu_srca.m_regHI\ : std_logic;
SIGNAL \alu_srca.m_regLO\ : std_logic;
SIGNAL \alu_srcb.m_pc4\ : std_logic;
SIGNAL \alu_srcb.m_reg\ : std_logic;
SIGNAL \alu_srcb.m_reg_invert\ : std_logic;
SIGNAL \alu_srcb.m_imma\ : std_logic;
SIGNAL \alu_srcb.m_immasl2\ : std_logic;
SIGNAL \alu_srcb.m_imml\ : std_logic;
SIGNAL \alu_srcb.m_imm_upper\ : std_logic;
SIGNAL \alu_sel.alu_add\ : std_logic;
SIGNAL \alu_sel.alu_sub\ : std_logic;
SIGNAL \alu_sel.alu_and\ : std_logic;
SIGNAL \alu_sel.alu_or\ : std_logic;
SIGNAL \alu_sel.alu_xor\ : std_logic;
SIGNAL \hi_select.hi_0\ : std_logic;
SIGNAL \hi_select.hi_shift_left\ : std_logic;
SIGNAL \hi_select.hi_shift_right\ : std_logic;
SIGNAL \lo_select.lo_operandA\ : std_logic;
SIGNAL \lo_select.lo_shift_left\ : std_logic;
SIGNAL \lo_select.lo_shift_right\ : std_logic;
SIGNAL \lo_select.lo_0\ : std_logic;
	
BEGIN

	
	dtpath : datapath_post
	PORT MAP(
		clk			=> clk,
		reset 		=> reset,
		iord 		=> iord,
		pcwrite 	=> pcwrite,
		pc_src      => pc_src_new,
		regDst		=> regDst,
		alu_carry_in=> alu_carry_in,
		div_by_zero => div_by_zero,
		hi_lo_write => hi_lo_write,
		irWrite 	=> irWrite,
		regWrite 	=> regWrite,
		address_bus => address_bus,
		databus_out => databus_out,
		databus_in	=> databus_in,
		memToReg 	=> memToReg,

\alu_srca.m_pc\ => \alu_srca.m_pc\,
\alu_srca.m_reg\ => \alu_srca.m_reg\,
\alu_srca.m_regHI\ => \alu_srca.m_regHI\,
\alu_srca.m_regLO\ => \alu_srca.m_regLO\,
\alu_srcb.m_pc4\ => \alu_srcb.m_pc4\,
\alu_srcb.m_reg\ => \alu_srcb.m_reg\,
\alu_srcb.m_reg_invert\ => \alu_srcb.m_reg_invert\,
\alu_srcb.m_imma\ => \alu_srcb.m_imma\,
\alu_srcb.m_imml\ => \alu_srcb.m_imml\,
\alu_srcb.m_imm_upper\ => \alu_srcb.m_imm_upper\,
\alu_sel.alu_add\ => \alu_sel.alu_add\,
\alu_sel.alu_sub\ => \alu_sel.alu_sub\,
\alu_sel.alu_and\ => \alu_sel.alu_and\,
\alu_sel.alu_or\ => \alu_sel.alu_or\,
\alu_sel.alu_xor\ => \alu_sel.alu_xor\,
\hi_select.hi_0\ => \hi_select.hi_0\,
\hi_select.hi_shift_left\ => \hi_select.hi_shift_left\,
\hi_select.hi_shift_right\ => \hi_select.hi_shift_right\,
\lo_select.lo_operandA\ => \lo_select.lo_operandA\,
\lo_select.lo_shift_left\ => \lo_select.lo_shift_left\,
\lo_select.lo_shift_right\ => \lo_select.lo_shift_right\,
\lo_select.lo_0\ => \lo_select.lo_0\

	);	

PROCESS (alu_srca)
BEGIN
\alu_srca.m_pc\ <= '0';
\alu_srca.m_reg\ <= '0';
\alu_srca.m_regHI\ <= '0';
\alu_srca.m_regLO\ <= '0';
CASE alu_srca IS
	WHEN m_pc =>
		\alu_srca.m_pc\ <= '1';
	WHEN m_reg =>
		\alu_srca.m_reg\ <= '1';
	WHEN m_regHI =>
		\alu_srca.m_regHI\ <= '1';
	WHEN m_regLO =>
		\alu_srca.m_regLO\ <= '1';
END CASE;
END PROCESS;

PROCESS (alu_srcb)
BEGIN
\alu_srcb.m_pc4\ <= '0';
\alu_srcb.m_reg\ <= '0';
\alu_srcb.m_reg_invert\ <= '0';
\alu_srcb.m_imma\ <= '0';
\alu_srcb.m_immasl2\ <= '0';
\alu_srcb.m_imml\ <= '0';
\alu_srcb.m_imm_upper\ <= '0';
CASE alu_srcb IS
	WHEN m_pc4 =>
		\alu_srcb.m_pc4\ <= '1';
	WHEN m_reg =>
		\alu_srcb.m_reg\ <= '1';
	WHEN m_reg_invert =>
		\alu_srcb.m_reg_invert\ <= '1';
	WHEN m_imma =>
		\alu_srcb.m_imma\ <= '1';
	WHEN m_imml =>
		\alu_srcb.m_imml\ <= '1';
	WHEN m_imm_upper =>
		\alu_srcb.m_imm_upper\ <= '1';

END CASE;
END PROCESS;

PROCESS (alu_sel)
BEGIN
\alu_sel.alu_add\ <= '0';
\alu_sel.alu_sub\ <= '0';
\alu_sel.alu_and\ <= '0';
\alu_sel.alu_or\ <= '0';
\alu_sel.alu_xor\ <= '0';
CASE alu_sel IS
	WHEN alu_add =>
		\alu_sel.alu_add\ <= '1';
	WHEN alu_sub =>
		\alu_sel.alu_sub\ <= '1';
	WHEN alu_and =>
		\alu_sel.alu_and\ <= '1';
	WHEN alu_or =>
		\alu_sel.alu_or\ <= '1';
	WHEN alu_xor =>
		\alu_sel.alu_xor\ <= '1';
END CASE;
END PROCESS;

PROCESS (hi_select)
BEGIN
\hi_select.hi_0\ <= '0';
\hi_select.hi_shift_left\ <= '0';
\hi_select.hi_shift_right\ <= '0';
CASE hi_select IS
	WHEN hi_0 =>
		\hi_select.hi_0\ <= '1';
	WHEN hi_shift_left =>
		\hi_select.hi_shift_left\ <= '1';
	WHEN hi_shift_right =>
		\hi_select.hi_shift_right\ <= '1';
END CASE;
END PROCESS;

PROCESS (lo_select)
BEGIN
\lo_select.lo_operandA\ <= '0';
\lo_select.lo_shift_left\ <= '0';
\lo_select.lo_shift_right\ <= '0';
\lo_select.lo_0\ <= '0';
CASE lo_select IS
	WHEN lo_operandA =>
		\lo_select.lo_operandA\ <= '1';
	WHEN lo_shift_left =>
		\lo_select.lo_shift_left\ <= '1';
	WHEN lo_shift_right =>
		\lo_select.lo_shift_right\ <= '1';
	WHEN lo_0 =>
		\lo_select.lo_0\ <= '1';
END CASE;
END PROCESS;


PROCESS (pc_src)
BEGIN
	IF pc_src = pc_jump THEN
		pc_src_new <= '0'; -- TODO weet deze mapping niet zeker
	ELSE
		pc_src_new <= '1';
	END IF;
END PROCESS;

END ARCHITECTURE;
