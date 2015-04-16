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
		div_by_zero     : IN std_logic;
		hi_select       : OUT hi_select_t;
		lo_select       : OUT lo_select_t;
		hi_lo_write     : OUT std_logic;
		irWrite 		: OUT std_logic;
		regWrite		: OUT std_logic;
		memToReg		: OUT std_logic
		);
END controller;

ARCHITECTURE behaviour OF controller IS
	SIGNAL state 	: fsm_state_t;
    
BEGIN
		PROCESS(clk,reset)
		    VARIABLE flag_reg_write     : std_logic;
		    VARIABLE flag_mem_to_reg    : std_logic;
		    VARIABLE mem_write_flag     : std_logic;
		    VARIABLE mem_read_flag      : std_logic;
		    VARIABLE pc_jump_flag       : std_logic;
		    VARIABLE pc_branch_flag     : std_logic;
		    VARIABLE cycle_cnt          : integer RANGE 0 to 34;
		
		BEGIN
			IF reset='1' THEN 
				state 		    <= fetch;
				write 		    <= '0';
				iord 		    <= '0';
				irWrite 	    <= '0';
				regWrite 	    <= '0';
				flag_reg_write  := '0';	
				flag_mem_to_reg := '0';			
				mem_write_flag  := '0';
				mem_read_flag   := '0';
				pc_jump_flag    := '0';
				pcwrite	        <= '0';
				regDst		    <= '0';
				memToReg	    <= '0';
				alu_carry_in    <= '0';	
				cycle_cnt       := 0;
				
			ELSIF rising_edge(clk) THEN
				hi_lo_write     <= '0';
				alu_carry_in    <= '0';
				CASE state IS
					WHEN fetch =>
						write 		    <= '0';
						iord 		    <= '0';
						irWrite 	    <= '0';
						regWrite 	    <= '0';
						pcwrite		    <= '0';
						memToReg        <= '0';						
						state 		    <= decode;
					WHEN decode =>
						irWrite 	    <= '1';																	
						state 		    <= execute;
					WHEN execute =>
						state 		    <= mem_pc;
						iord 		    <= '-';
						irWrite 	    <= '0';
						regWrite 	    <= '0';
						pcwrite		    <= '0';
						alu_carry_in    <= '0';
						flag_reg_write  := '1';
						mem_write_flag  := '0';
						mem_read_flag   := '0';
						pc_jump_flag    := '0';
						pc_branch_flag  := '0';
						pc_src          <= pc_alu;
						
						
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
									    hi_lo_write <= '1';
									    hi_select   <= hi_shift_right;
									    lo_select   <= lo_shift_right;
									    alu_srca    <= m_regHI;
									    flag_reg_write := '0';
									    
								        IF cycle_cnt = 0 THEN
								            alu_srca    <= m_reg; 
								            hi_select   <= hi_0;
								            lo_select   <= lo_operandA;
									        state       <= execute;
									        cycle_cnt := cycle_cnt + 1;
									    ELSIF cycle_cnt = 32 THEN
									        alu_srcb    <= m_reg_invert;
									        cycle_cnt   := 0;
									        alu_carry_in<= '1'; -- minus in last cycle
									    ELSE
									        cycle_cnt   := cycle_cnt + 1;
									        state   <= execute;
									    END IF;
									WHEN F_divu =>  
									    alu_sel         <= alu_add;
									    hi_lo_write     <= '1';
									    flag_reg_write  := '0';
									    hi_select       <= hi_shift_left;
									    lo_select       <= lo_shift_left;
									    alu_srca        <= m_regHI;
									    alu_srcb        <= m_reg_invert;
									    alu_carry_in    <= '1';
									    
									    IF cycle_cnt = 0 THEN -- INIT
									        alu_srca  <= m_reg; 
									        alu_srcb  <= m_reg; 
								            hi_select <= hi_0;
								            lo_select <= lo_operandA;									        
									        cycle_cnt := cycle_cnt + 1;
									        state <= execute;
									    ELSIF cycle_cnt = 1 OR cycle_cnt = 2 THEN -- check div by zero
									        -- alu out = hi(=0) + srcb(=divisor) 
									        alu_srca  <= m_regHI; 
									        alu_srcb  <= m_reg; 
									        alu_carry_in    <= '0';

									        cycle_cnt := cycle_cnt + 1;
									        hi_lo_write <= '0';
									        state <= execute;
--									    ELSIF cycle_cnt = 2 THEN
--    									    cycle_cnt := cycle_cnt + 1;
--									        hi_lo_write <= '0';
--									        state <= execute;
   									    ELSIF cycle_cnt = 3 THEN
   									    
           									IF     (div_by_zero = '1') THEN -- there was a div by zero, abort div
									                cycle_cnt := 0;  
								                    hi_select <= hi_0;
								                    lo_select <= lo_0;									        
									                state <= mem_pc;
									            ASSERT false REPORT "div cycle2, WEL div0" SEVERITY warning;
									        ELSE
									            ASSERT false REPORT "div cycle2, not div0" SEVERITY warning;
    									        cycle_cnt := cycle_cnt + 1;  
    									        state <= execute;
									        END IF;
									    ELSIF cycle_cnt = 34 THEN
									        cycle_cnt := 0;
									    ELSE
									        cycle_cnt := cycle_cnt + 1;  
									        state <= execute;
									    END IF;

									 WHEN F_mfhi =>
									    alu_sel 	<= alu_add;
									    alu_srca    <= m_regHI;
									WHEN F_mflo => 
									    alu_sel 	<= alu_add;  
									    alu_srca    <= m_regLO;
									WHEN OTHERS =>
								END CASE;
							
							WHEN Iadd =>
								regDst		<= '1';
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imma;
								alu_sel		<= alu_add;
							WHEN Iand =>
								regDst		<= '1';						
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imml;
								alu_sel		<= alu_and;
							
							WHEN Ior =>
								regDst		<= '1';					
								alu_srca	<= m_reg;
								alu_srcb 	<= m_imml;
								alu_sel		<= alu_or;
	                        WHEN Ilui =>
	                            regDst      <= '1';
	                            alu_srca    <= m_reg;
	                            alu_srcb    <= m_imm_upper;
	                            alu_sel     <= alu_or;

							WHEN Ilw =>
							    write 		    <= '0';
								regDst		    <= '1'; -- src_tgt
								alu_srca	    <= m_reg;
								alu_srcb 	    <= m_imma;
								alu_sel		    <= alu_add;
								iord 		    <= '1';
								mem_read_flag   := '1';
								
								memToReg 	<= '1'; --
							WHEN Isw => 
							    alu_srca	    <= m_reg;
								alu_srcb 	    <= m_imma;
								alu_sel		    <= alu_add;
							    iord 		    <= '1';
							    flag_reg_write  := '0';
								mem_write_flag  := '1';								
							WHEN Ibgtz  =>
							    alu_srca	    <= m_reg;
								alu_srcb	    <= m_reg; -- becomes register $0
								alu_sel         <= alu_xor;
								flag_reg_write  := '0';
								
							    
							WHEN Ibeq   =>	
							    alu_srca	    <= m_reg;
								alu_srcb	    <= m_reg;
								alu_sel         <= alu_xor;
								flag_reg_write  := '0';
								
							WHEN Jjump =>
							    pc_jump_flag    := '1';
							    flag_reg_write  := '0';
							    pc_src          <= pc_jump;
							WHEN OTHERS =>
						END CASE;
										
					WHEN mem_pc=>	
					    
						
					    IF mem_read_flag = '1' THEN
					        regWrite 	<= '1';
							irWrite 	<= '0';
					        memToReg 	<= '1';
							state 		<= fetch;
						ELSE 
							state       <= write_back;						
					    END IF;
						
						IF mem_write_flag = '1' THEN
							write 		<= '1';
						END	IF;
					    
					    IF pc_jump_flag = '1' THEN
					        pc_src      <= pc_jump;
		                ELSE
		                    pc_src      <= pc_alu;
		                    alu_srca	<= m_pc;
						    alu_srcb	<= m_pc4;
		                END IF;
					    pcwrite		<= '1';
       				    alu_sel 	<= alu_add;
						
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
