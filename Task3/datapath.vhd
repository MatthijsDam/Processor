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
USE instruction_decode_defs.ALL;

ENTITY datapath IS
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
END datapath;

ARCHITECTURE behaviour OF datapath IS
    SIGNAL reg 				: reg_bank_t := 
		("00000000000000000000000000000000",
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
	
	-- Alu signals
	SIGNAL alu_reg			: std_logic_vector(31 DOWNTO 0);
	SIGNAL imma 			: std_logic_vector(31 DOWNTO 0);
	SIGNAL imml 		    : std_logic_vector(31 DOWNTO 0);
	SIGNAL jump_address     : std_logic_vector(25 DOWNTO 0);
	SIGNAL alu_zero         : std_logic;
	SIGNAL alu_gtz          : std_logic;
	
BEGIN
    div_by_zero <= alu_zero;
	PROCESS(clk,reset) 
		VARIABLE alu_inp0 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_inp1 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE alu_inp0_32: std_logic;
		VARIABLE alu_inp1_32: std_logic;
		VARIABLE carry_in_loc:std_logic_vector(0 DOWNTO 0);
		VARIABLE carry_out  : std_logic;
		VARIABLE alu_out 	: std_logic_vector(31 DOWNTO 0);
		VARIABLE temp_alu   : std_logic_vector(32 DOWNTO 0);
		
		VARIABLE reg_dst	: Integer;
		VARIABLE reg_inp	: std_logic_vector(31 DOWNTO 0);
		
	BEGIN
	   
		

		IF reset='1' THEN 
            pc              <= (OTHERS => '0');
			databus_out		<= (OTHERS => '0');
			address_bus		<= (OTHERS => '0');
			alu_reg			<= (OTHERS => '0');
			alu_inp0		:= (OTHERS => '0');
			alu_inp1		:= (OTHERS => '0');
			alu_inp0_32		:= '0';
			alu_inp1_32		:= '0';
			
			opcode		 	<= (OTHERS => '0');
			funct			<= (OTHERS => '0');
			src				<= (OTHERS => '0');
			src_tgt			<= (OTHERS => '0');
			dst				<= (OTHERS => '0');
			
			imma 			<= (OTHERS => '0');
			imml 		    <= (OTHERS => '0');
			jump_address    <= (OTHERS => '0');
			alu_zero        <= '0';
			alu_gtz         <= '0';
			
            reg_HI      	<= (OTHERS => '0');
			reg_LO      	<= (OTHERS => '0');
			reg				<= ("00000000000000000000000000000000",
								OTHERS => "00000000000000000000000000000000"
								);
							
			carry_in_loc	:= "0";
			carry_out  		:= '0';
			alu_out 		:= (OTHERS => '0');
			temp_alu 		:= (OTHERS => '0');
		
			reg_dst			:= 0;
			reg_inp			:= (OTHERS => '0');					
			
		ELSIF rising_edge(clk) THEN		
            databus_out <= reg(to_integer(unsigned(src_tgt)));
            carry_in_loc(0) := alu_carry_in;
            alu_inp0_32 := '0'; -- only used in mult and divu 
            alu_inp1_32 := '0';

			IF irWrite ='1' THEN
				opcode      <= databus_in(31 DOWNTO 26);
				src 		<= databus_in(25 DOWNTO 21);
				src_tgt		<= databus_in(20 DOWNTO 16);
				dst 		<= databus_in(15 DOWNTO 11);
				funct		<= databus_in(5 DOWNTO 0);
				jump_address<= databus_in(25 DOWNTO 0);
				imma 		<= std_logic_vector(resize(signed(databus_in(15 DOWNTO 0)),32));
				imml 		<= std_logic_vector(resize(unsigned(databus_in(15 DOWNTO 0)),32));
				
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
   
			    WHEN m_regHI =>
			        alu_inp0 := reg_HI;
        		    IF opcode = Rtype AND funct = F_divu AND carry_in_loc = "1" THEN
			            alu_inp0 := reg_HI(30 DOWNTO 0) & reg_LO(31);
			         END IF;
			    WHEN m_regLO => -- alleen voor mflo
			        alu_inp0 := reg_LO;    
				WHEN OTHERS =>
			END CASE;

                       

			CASE alu_srcb IS
				WHEN m_pc4 =>
                    IF (alu_zero = '1' AND opcode= Ibeq ) OR (alu_gtz = '1' AND opcode = Ibgtz) THEN
                        alu_inp1 := std_logic_vector(unsigned(imma(29 DOWNTO 0))+1) & "00"; -- shift left 2 and add 4
                    ELSE  
					    alu_inp1 := std_logic_vector(to_unsigned(4,32));
					END IF;
					--alu_inp1 := "00000000000000000000000000000100"; 
				WHEN m_reg =>
				    alu_inp1 := reg(to_integer(unsigned(src_tgt)));
			        IF opcode = Rtype AND funct = F_mult AND reg_LO(0) = '0' THEN
			            alu_inp1 := (OTHERS => '0');
			        END IF;		
				WHEN m_reg_invert =>
                    
				    alu_inp1 := not reg(to_integer(unsigned(src_tgt)));
				    IF opcode = Rtype AND funct = F_mult AND reg_LO(0) = '0' THEN
			            alu_inp1 := (OTHERS => '0');
			            carry_in_loc(0) := '0';
			        END IF;	
				WHEN m_imma =>
					alu_inp1 := imma;
			    --WHEN m_immasl2 =>
			     --   IF alu_zero = '1' AND (opcode= Ibeq OR opcode = Ibgtz) THEN
			      --      alu_inp1 := std_logic_vector(signed(imma) sll 2); 
			       -- ELSE
			        --    alu_inp1 := (OTHERS => '0');
			        --END IF;
                WHEN m_imml =>
                    alu_inp1 := imml;                
                WHEN m_imm_upper=>
                    alu_inp1 := std_logic_vector(unsigned(imml) sll 16);
				WHEN OTHERS =>
			END CASE;
			
				
			
			CASE alu_sel IS
				WHEN alu_add =>
				    IF opcode = Rtype AND funct = F_mult THEN
				        alu_inp0_32 := alu_inp0(31);
				        alu_inp1_32 := alu_inp1(31);
				    ELSIF opcode = Rtype AND funct = F_divu THEN
				        alu_inp0_32 := '0';
				        alu_inp1_32 := '1';
				    END IF;
                    temp_alu := std_logic_vector(unsigned(alu_inp0_32& alu_inp0) + unsigned(alu_inp1_32&alu_inp1) + unsigned(carry_in_loc)    );
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
			
			alu_zero <= '0';
			alu_gtz <= '0';
			IF alu_out = "00000000000000000000000000000000" THEN
			    alu_zero <= '1';
			ELSIF alu_out(31) = '0' AND unsigned(alu_out)>0 THEN
			    alu_gtz <= '1';
			END IF;

			IF hi_lo_write = '1' THEN
			    CASE hi_select IS
			        WHEN hi_0    => -- voor de initiatie
			            reg_HI  <= (OTHERS => '0');
			        WHEN hi_shift_left => -- voor de divu
			            
			             IF carry_out = '0' THEN
    			             ASSERT false REPORT "not restoring" SEVERITY warning;
			                reg_HI  <= alu_out; -- not restoring
			            ELSE
    			             ASSERT false REPORT "wel restoring" SEVERITY warning;
			                reg_HI  <= alu_inp0;-- restoring, because overflow
			            END IF;
			        WHEN hi_shift_right =>   -- voor de mult
			           reg_HI  <= carry_out & alu_out(31 downto 1);
			    END CASE;
			
			    CASE lo_select IS
			        WHEN lo_operandA    => -- init
			            reg_LO <= alu_inp0;
			        WHEN lo_shift_left =>    -- divu
                        reg_LO <= reg_LO(30 DOWNTO 0) & not carry_out;  
			        WHEN lo_shift_right => -- mult
			            reg_LO <= alu_out(0) & reg_LO(31 downto 1);
			        WHEN lo_0 => -- used when div by zero
			            reg_LO <= (OTHERS => '0');
			    END CASE;
			END IF;
			
			IF pcwrite ='1' THEN
		        CASE pc_src IS
		            WHEN pc_jump =>
		                pc <= pc(31 DOWNTO 28) & jump_address & "00";
		            WHEN pc_alu  =>
		                pc <= alu_out;
	            END CASE;
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
