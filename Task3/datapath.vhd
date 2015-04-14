--------------------------------------------------------------
-- 
-- Data path
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_signed.all;
USE work.ALL;
USE types.ALL;

ENTITY datapath IS
    PORT(
		clk 		: IN  std_logic;
		reset		: IN  std_logic;
		address_bus : OUT std_logic_vector(31 DOWNTO 0);
		databus_out	: OUT std_logic_vector(31 DOWNTO 0);
		databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
		pcwrite 	: IN  std_logic;
		regDst		: IN  std_logic;
		alu_srca 	: IN  alu_ina_t;
		alu_srcb 	: IN  alu_inb_t;
		alu_sel     : IN  alu_sel_t;
		alu_carry_in: IN  std_logic;
		iord		: IN  std_logic;
		irWrite 	: IN  std_logic;
		regWrite 	: IN  std_logic;
		memToReg 	: IN  std_logic
		);
END datapath;

ARCHITECTURE behaviour OF datapath IS
    SIGNAL reg 				: reg_bank_t := 
		("00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000010",
		"00000000000000000000000000000011",
		OTHERS => "00000000000000000000000000000000"
		);
    SIGNAL reg_LO, reg_HI	: std_logic_vector(31 DOWNTO 0); 
	SIGNAL pc		 		: std_logic_vector(31 DOWNTO 0); -- increment by ALU
	
	-- Instruction register
	SIGNAL opcode           : std_logic_vector(5 DOWNTO 0);
	SIGNAL funct			: std_logic_vector(5 DOWNTO 0);
	SIGNAL src				: std_logic_vector(4 DOWNTO 0);
	SIGNAL src_tgt			: std_logic_vector(4 DOWNTO 0);
	SIGNAL dst				: std_logic_vector(4 DOWNTO 0);
	SIGNAL alu_reg			: std_logic_vector(31 DOWNTO 0);
	SIGNAL imm 				: std_logic_vector(31 DOWNTO 0);
	
BEGIN
	PROCESS(clk,reset) 
		VARIABLE alu_inp0 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_inp1 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE carry_out  : std_logic;
		VARIABLE alu_out 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE temp_alu   : std_logic_vector(32 DOWNTO 0);
		
		VARIABLE reg_dst	: Integer;
		VARIABLE reg_inp	: std_logic_vector(31 DOWNTO 0);
	BEGIN
	   
	    
		IF reset='1' THEN 
            pc              <= (OTHERS => '0');
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
    
		ELSIF rising_edge(clk) THEN		
            databus_out <= reg(to_integer(unsigned(src_tgt)));

			IF irWrite ='1' THEN
				opcode      <= databus_in(31 DOWNTO 26);
				src 		<= databus_in(25 DOWNTO 21);
				src_tgt		<= databus_in(20 DOWNTO 16);
				dst 		<= databus_in(15 DOWNTO 11);
				funct		<= databus_in(5 DOWNTO 0);
				imm 		<= std_logic_vector(resize(signed(databus_in(15 DOWNTO 0)),32));
			END IF;
			
			CASE regDst IS
				WHEN '0' =>
						reg_dst := to_integer(unsigned(dst)); 
				WHEN '1' =>
						reg_dst := to_integer(unsigned(src_tgt));
				WHEN OTHERS =>
			END CASE;
			
			IF regWrite ='1' AND reg_dst /= 0 THEN
				CASE memToReg IS
					WHEN '0' =>
						reg(reg_dst) <= alu_reg;
					WHEN '1' =>
						reg(reg_dst) <= databus_in;
					WHEN OTHERS =>
				END CASE;	
			END IF;
			
			CASE alu_srca IS
				WHEN m_pc =>
					alu_inp0 := pc;
				WHEN m_reg =>
					alu_inp0 := reg(to_integer(unsigned(src)));
				WHEN OTHERS =>
			END CASE;

			CASE alu_srcb IS
				WHEN m_pc4 =>
					alu_inp1 := std_logic_vector(to_unsigned(4,32));
				WHEN m_reg =>
					alu_inp1 := reg(to_integer(unsigned(src_tgt)));
				WHEN m_reg_invert =>
				    alu_inp1 := not reg(to_integer(unsigned(src_tgt)));
				WHEN m_imm =>
					alu_inp1 := imm;
                WHEN m_imm_upper=>
                    alu_inp1 := std_logic_vector(unsigned(imm) sll 16);
				WHEN OTHERS =>
			END CASE;
			
				
			
			CASE alu_sel IS
				WHEN alu_add =>
					temp_alu := std_logic_vector((alu_inp0(31)&alu_inp0) + (alu_inp1(31)&alu_inp1) + alu_carry_in);
					carry_out:= temp_alu(32);
					alu_out  := temp_alu(31 DOWNTO 0);
				WHEN alu_and =>
					alu_out := alu_inp0 AND alu_inp1;
				WHEN alu_or =>
					alu_out := alu_inp0 OR alu_inp1;
				WHEN alu_xor =>
					alu_out := alu_inp0 XOR alu_inp1;
				WHEN OTHERS =>
			END CASE;	

			-- Store ALU output in a register
			
			
			
			
			IF pcwrite ='1' THEN
				pc <= alu_out;
		    ELSE
		        alu_reg 	<= alu_out;
			END IF;
			
			CASE iord IS
				WHEN '0' =>
					address_bus <= pc;
				WHEN '1' =>
					address_bus <= alu_out;
				WHEN OTHERS =>
			END CASE;
			
		END IF;
	END PROCESS;	
END ARCHITECTURE;
