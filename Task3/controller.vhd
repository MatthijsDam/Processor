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
USE instruction_decode_defs.ALL;

ENTITY controller IS
    PORT(
		clk 			: IN  std_logic;
		reset 			: IN  std_logic;
		databus_in 	: IN  std_logic_vector(31 DOWNTO 0);
		write	        : OUT std_logic;
		iord			: OUT std_logic;
		pc_src          : OUT pc_src_t;
		pcwrite			: OUT std_logic;
		regDst			: OUT std_logic;
		alu_srca 		: OUT alu_ina_t;
		alu_srcb 		: OUT alu_inb_t;
		alu_sel 		: OUT alu_sel_t;
		alu_carry_in    : OUT std_logic;
		irWrite 		: OUT std_logic;
		regWrite		: OUT std_logic;
		memToReg		: OUT std_logic
		);
END controller;

ARCHITECTURE behaviour OF controller IS
	SIGNAL state 	: fsm_state_t;
    
BEGIN
		PROCESS(clk,reset)
		    VARIABLE flag_reg_write : std_logic;
		    VARIABLE flag_mem_to_reg : std_logic;
		    VARIABLE mem_write_flag : std_logic;
		    VARIABLE mem_read_flag : std_logic;
		    VARIABLE pc_jump_flag : std_logic;
		    VARIABLE pc_branch_flag : std_logic;
		    VARIABLE cycle_cnt  : integer RANGE 0 to 31;
		
		BEGIN
			IF reset='1' THEN 
				state 		<= fetch;
				write 		<= '0';
				iord 		<= '0';
				irWrite 	<= '0';
				regWrite 	<= '0';
				flag_reg_write  := '0';	
				flag_mem_to_reg := '0';			
				mem_write_flag  := '0';
				mem_read_flag   := '0';
				pc_jump_flag    := '0';
				pcwrite	    <= '0';
				regDst		<= '0';
				memToReg	<= '0';
				alu_carry_in<= '0';	
			ELSIF rising_edge(clk) THEN
				CASE state IS
					WHEN fetch =>
						write 		<= '0';
						iord 		<= '0';
						irWrite 	<= '0';
						regWrite 	<= '0';
						pcwrite		<= '0';
						memToReg    <= '0';
						
						state 		<= decode;
					WHEN decode =>
						irWrite 	<= '1';
																	
						state 		<= execute;
					WHEN execute =>
						state 		<= mem_pc;
						iord 		<= '-';
						irWrite 	<= '0';
						regWrite 	<= '0';
						pcwrite		<= '0';
						alu_carry_in<= '0';
						flag_reg_write := '1';
						mem_write_flag := '0';
						mem_read_flag := '0';
						pc_jump_flag   := '0';
						pc_branch_flag:= '0';
						pc_src  <= pc_alu;
						
						CASE databus_in(31 DOWNTO 26) IS
							WHEN Rtype =>
								regDst 		<= '0';
								alu_srca	<= m_reg;
								alu_srcb	<= m_reg;
								CASE databus_in(5 DOWNTO 0) IS
									WHEN F_add =>
										alu_sel 	<= alu_add;
									WHEN F_sub =>
								        alu_sel 	<= alu_add;
								        alu_carry_in<= '1';
									WHEN F_and =>
										alu_sel 	<= alu_and;
									WHEN F_or =>	
										alu_sel 	<= alu_or;
									WHEN F_xor =>	
										alu_sel 	<= alu_xor;
									WHEN F_nop =>
									    alu_sel     <= alu_or;
									WHEN F_mult =>
									    alu_sel     <= alu_add; 
									        
								        
									    IF cycle_cnt = 31 THEN
									        cycle_cnt := 0;
									        alu_carry_in<='1'; -- minus in last round
									    ELSE
									        cycle_cnt := cycle_cnt + 1;
									        state <= execute;
									    END IF;
									WHEN F_divu =>  
									    alu_sel <= alu_add; 
									    alu_carry_in<= '1';
									        
									    IF cycle_cnt = 31 THEN
									        cycle_cnt := 0;
									        alu_carry_in<='1'; -- minus in last round
									    ELSE
									        cycle_cnt := cycle_cnt + 1;
									        state <= execute;
									    END IF;
									WHEN OTHERS =>
								END CASE;
							
							WHEN Iadd =>
								regDst		<= '1';
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_add;
								
							WHEN Iand =>
								regDst		<= '1';						
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_and;
							
							WHEN Ior =>
								regDst		<= '1';					
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_or;
	                        WHEN Ilui =>
	                            regDst      <= '1';
	                            alu_srca    <= m_reg;
	                            alu_srcb    <= m_imm_upper;
	                            alu_sel     <= alu_or;

							WHEN Ilw =>
							    write 		<= '0';
								regDst		<= '1';
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_add;
								iord 		<= '1';
								mem_read_flag := '1';
								--flag_mem_to_reg := '1';
								
							WHEN Isw => 
							    alu_srca	<= m_reg;
								alu_srcb 	<= m_imm;
								alu_sel		<= alu_add;
							    iord 		<= '1';
							    flag_reg_write := '0';
								mem_write_flag := '1';
								
							WHEN Ibgtz  =>
							    alu_srca	<= m_reg;
								alu_srcb	<= m_reg; -- becomes register $0
								alu_sel     <= alu_xor;
								flag_reg_write := '0';
								
							    
							WHEN Ibeq   =>	
							    alu_srca	<= m_reg;
								alu_srcb	<= m_reg;
								alu_sel     <= alu_xor;
								flag_reg_write := '0';
								
							WHEN Jjump =>
							    pc_jump_flag := '1';
							    flag_reg_write := '0';
							    pc_src    <= pc_jump;
							    
							
							WHEN OTHERS =>

						END CASE;
										
					WHEN mem_pc=>	
					
					    IF mem_read_flag = '1' THEN
					        irWrite 	<= '0';
					        memToReg 	<= '1';
					    ELSIF mem_write_flag = '1' THEN
					        write 		<= '1';
					    END IF;
					    
					    IF pc_jump_flag = '1' THEN
					        pc_src    <= pc_jump;
		                ELSE
		                    pc_src    <= pc_alu;
		                    alu_srca	<= m_pc;
						    alu_srcb	<= m_pc4;
		                END IF;
					    pcwrite		<= '1';
       				    alu_sel 	<= alu_add;
						state       <= write_back;
					WHEN write_back =>
                        pcwrite     <= '0';
                        write 		<= '0';
						IF flag_reg_write = '1' THEN -- bij instructies die naar reg schrijven ( _ (sw, jump, b))
						    regWrite 	<= '1';
						END IF;
							
						iord		<= '0';	
						state 		<= fetch;
				END CASE;
			END IF;
		END PROCESS;

END ARCHITECTURE;
