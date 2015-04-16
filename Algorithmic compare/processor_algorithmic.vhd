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
USE instruction_decode_defs.ALL;


ENTITY processor_alg IS
    PORT(
        address_bus     : OUT std_logic_vector(31 DOWNTO 0);
        databus_in      : IN  std_logic_vector(31 DOWNTO 0);
        databus_out     : OUT std_logic_vector(31 DOWNTO 0);
        write           : OUT std_logic;
        reset           : IN  std_logic;
        clk             : IN  std_logic
    );
END processor_alg;

ARCHITECTURE behaviour OF processor_alg IS
    TYPE fsm_state_t IS (fetch, decode, execute, mem_read,mem_write);
    SIGNAL state : fsm_state_t;  
      
    TYPE reg_bank_t IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0); 
    SIGNAL reg                      : reg_bank_t := 
         ("00000000000000000000000000000000",
          OTHERS => "00000000000000000000000000000000"
          );
    SIGNAL reg_LO, reg_HI     : std_logic_vector(31 DOWNTO 0);      --TODO: kunnen dit allemaal variabelen zijn? 
          


     Function sra_f(inp : unsigned) return unsigned is
	    Begin
		    return inp(inp'length-1) & inp(inp'length-1 downto 1);
	    End sra_f;

BEGIN
    PROCESS(clk,reset)
        VARIABLE pc                 : INTEGER := 0;
        VARIABLE instruction        : std_logic_vector(31 DOWNTO 0);
       
        VARIABLE opcode             : std_logic_vector(5 DOWNTO 0);

        VARIABLE src                : INTEGER RANGE 0 TO 31;
        VARIABLE src_tgt            : INTEGER RANGE 0 TO 31;
        VARIABLE dst                : INTEGER RANGE 0 TO 31;
        
        VARIABLE operand1           : std_logic_vector(31 DOWNTO 0);
        VARIABLE operand2           : std_logic_vector(31 DOWNTO 0);
        VARIABLE operand1a          : unsigned(31 DOWNTO 0);
        VARIABLE operand2a          : unsigned(31 DOWNTO 0);
        VARIABLE reg_HI_internal    : std_logic_vector(31 DOWNTO 0);
        VARIABLE reg_LO_internal    : std_logic_vector(31 DOWNTO 0);
        
        VARIABLE funct              : std_logic_vector(5 DOWNTO 0);

        VARIABLE imm                : std_logic_vector(15 DOWNTO 0);
        VARIABLE target             : std_logic_vector(25 DOWNTO 0);
        VARIABLE temp_pc            : std_logic_vector(31 DOWNTO 0); 

        VARIABLE partial_hi         : unsigned(32 DOWNTO 0);  -- help register for mult operation
        VARIABLE multiplicand       : unsigned(32 DOWNTO 0);
        VARIABLE carry_in           : unsigned( 0 DOWNTO 0);
        VARIABLE shift_cnt          : INTEGER RANGE 0 TO 31;

        VARIABLE quotient           : unsigned(31 DOWNTO 0); 
        VARIABLE divisor            : unsigned(31 DOWNTO 0); 
        VARIABLE remainder_HI       : unsigned(31 DOWNTO 0);
        VARIABLE remainder_LO       : unsigned(31 DOWNTO 0);
        VARIABLE adder_res          : unsigned(32 DOWNTO 0);

        VARIABLE address_temp       : std_logic_vector(31 DOWNTO 0);
        VARIABLE data_temp          : std_logic_vector(31 DOWNTO 0);  
    

    -- A read operation has 1 clock cycle delay
    PROCEDURE memory_read(pc : IN INTEGER) IS
        BEGIN
            write       <= '0';
            address_bus <= std_logic_vector(to_unsigned(pc,32));
    END memory_read;

    PROCEDURE memory_write(
                    address : IN std_logic_vector(31 DOWNTO 0); 
                    data    : IN std_logic_vector(31 DOWNTO 0)) IS    
        BEGIN
            write        <= '1';
            address_bus <= address;
            databus_out <= data;
    END memory_write;  
      

    BEGIN
        IF reset='1' THEN 
            state           <= fetch;
            pc              := 0;
            write           <= '0';
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
            address_bus     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";

            reg_LO          <= (OTHERS => '0');
            reg_HI          <= (OTHERS => '0');            
            partial_hi      := (OTHERS => '0'); -- zero partial hi
            shift_cnt       := 0;
            quotient        := (OTHERS => '0');
            remainder_HI    := (OTHERS => '0');
            remainder_LO    := (OTHERS => '0');
            divisor         := (OTHERS => '0');
            adder_res       := (OTHERS => '0'); -- could probably be combined with partial hi

            
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN fetch =>
                    --
                    -- Instruction fetch
                    -- 
                    memory_read(pc);

                    -- Increase program counter
                    pc := pc+4; 

                    state <= decode;

                WHEN decode =>
                    instruction := databus_in;
                    state       <= execute; 
                  
                    -- Common
                    opcode      := instruction(31 DOWNTO 26);

                    -- Common R and I
                    src         := to_integer(unsigned(instruction(25 DOWNTO 21)));
                    src_tgt     := to_integer(unsigned(instruction(20 DOWNTO 16)));
                    
                    -- Both registers (R-Type):
                    dst         := to_integer(unsigned(instruction(15 DOWNTO 11)));
                    funct       := instruction( 5 DOWNTO  0);
                    -----------------------------------------
                    -- One immediate (I-Type):
                    imm         := std_logic_vector(signed(instruction(15 DOWNTO 0)));
                    -----------------------------------------
                    -- Jump (J-Type):
                    target      := instruction(25 DOWNTO 0);
                    -----------------------------------------
                    operand1    := reg(src);
                    operand2    := reg(src_tgt);
                    operand1a   := unsigned(operand1);
                    operand2a   := unsigned(operand2);
                     
                WHEN execute =>  
                    state <= fetch;
                    -- Decoding and execution
                    CASE opcode IS                        
                     -- Arithmetic registers operation or nop
                     WHEN Rtype =>

                       
                        CASE funct IS
                            -- Arithmetic ADD
                            WHEN F_add =>
                                reg(dst) <= std_logic_vector( signed(operand1) + signed(operand2) ); 
                            -- Arithmetic MULT
                            WHEN F_mult =>                    
                                -- operand1a is multiplicand, operand2a is multiplier  
                                reg_HI_internal := reg_HI;
                                if shift_cnt = 0 then 
                                    reg_HI_internal := (OTHERS => '0');            
                                end if;
                                
                                carry_in := (OTHERS => '0');
                                if operand2a(0) = '1' then
                                    if shift_cnt = 31 then
                                        carry_in := (OTHERS => '1');
                                        operand1a := not operand1a; -- invert if last cycle
                                    end if;
                                    multiplicand := (operand1a(31) & operand1a); -- sign extension by one bits
                                else 
                                    multiplicand := (others => '0'); -- sign extension by two bits
                                end if;                                         
                                
                                partial_hi     := (reg_HI_internal(31) & unsigned(reg_HI_internal)) + multiplicand + carry_in; -- use alu adder ( 33 bits with carry in and out)
                                
                                reg_HI         <= std_logic_vector(partial_hi(32 downto 1));
                                reg_LO         <= partial_hi(0) & reg_LO(31 downto 1); -- shift new partial_hi product bit into reg_LO
                                --partial_hi     := sra_f(partial_hi); -- shift partial_hi to next position
                                operand2a      := sra_f(operand2a); -- shift to the next bit multiplier - sign extended                                            
                                
                                state <= execute;                                
                                if shift_cnt = 31 then  -- mult operation done
                                    state     <= fetch;
                                    shift_cnt := 0;
                                else
                                    shift_cnt := shift_cnt + 1;
                                end if;
                                
                                
                                
                            -- Arithmetic DIVU (restoring division algorithm)
                            WHEN F_divu => 
                                reg_LO_internal := reg_LO; -- dividend at start, quotient at end
                                reg_HI_internal := reg_HI; -- 0 at start, remainder at end
                                state <= execute;
                                if shift_cnt = 0 then   -- set parameters in first cycle
                                    reg_LO_internal:= operand1;
                                    divisor     := unsigned(operand2a);
                                    --quotient    := (OTHERS => '0');
                                    reg_HI_internal:= (OTHERS => '0');           
                                end if;
                                
                                reg_HI_internal := reg_HI_internal(30 downto 0) & reg_LO_internal(31);
                                --remainder_HI    := remainder_HI(30 downto 0) & remainder_LO(31);
                               -- reg_LO_internal := reg_LO(30 downto 0) & 'U';
                                --remainder_LO    := remainder_LO(30 downto 0) & 'U';
                                
                                adder_res       := ('0' & unsigned(reg_HI_internal)) + ( '1' & (not divisor)) + 1; -- use alu adder
                                
                                if adder_res(32)='0' then
                                    reg_HI_internal := std_logic_vector(adder_res(31 downto 0));
                                   -- quotient := quotient(30 downto 0) & '1';
                                    reg_LO          <= reg_LO_internal(30 DOWNTO 0) & '1';
                                else
                                    reg_LO          <= reg_LO_internal(30 DOWNTO 0) & '0';
                                   -- quotient := quotient(30 downto 0) & '0';                                
                                end if; 
                                
                                reg_HI <= reg_HI_internal;
                                
                                if shift_cnt = 31 then
                                    --reg_HI      <= std_logic_vector(remainder_HI(31 downto 0));
                                    --reg_LO      <= sd_logic_vector(quotient);
                                   -- quotient    := (OTHERS => '0');  
                                    shift_cnt   := 0;   
                                    state       <= fetch;   
                                else
                                    shift_cnt := shift_cnt + 1;                     
                                end if;
                                
                            -- Arithmetic SUB
                            WHEN F_sub =>
                            -- temp_pc := signed(not operand2)+1; 
                                 reg(dst) <= std_logic_vector( signed(operand1) + signed(not operand2) + 1 );
                                                                  
                            -- Logic AND
                            WHEN F_and =>      
                                 reg(dst) <= operand1 AND operand2;                                      
                            -- Logic OR
                            WHEN F_or =>
                                 reg(dst) <= operand1 OR operand2;                                 
                            -- Logic XOR
                            WHEN F_xor =>
                                 reg(dst) <= (operand1 AND (not operand2)) OR ((not operand1) AND operand2) ;                                 
                            -- NOP "operation"
                            WHEN F_nop =>
                            -- MFHI move from $HI to dst register
                            WHEN F_mfhi =>
                                  reg(dst) <= reg_HI;
                            -- MFLO move from $LO to dst register
                            WHEN F_mflo => 
                                  reg(dst) <= reg_LO;
                            WHEN OTHERS =>     
                        END CASE; -- end case func

                     -- ADD immediate operation
                     WHEN Iadd =>
                        reg(src_tgt) <= std_logic_vector(signed(operand1) + signed(imm));
                     -- AND immediate operation
                     WHEN Iand =>
                        reg(src_tgt) <= operand1 AND std_logic_vector(resize(unsigned(imm),32));
                     -- OR immediate operation
                     WHEN Ior =>   
                        reg(src_tgt) <= operand1 OR std_logic_vector(resize(unsigned(imm),32));
                     -- JUMP immediate operation
                     WHEN Jjump =>
                        temp_pc  := std_logic_vector(to_unsigned(pc,32));
                        pc       := to_integer(unsigned(std_logic_vector'(temp_pc(31 DOWNTO 28) & target & "00")));
                     -- BEQ immediate operation
                     WHEN Ibeq =>   
                        IF operand1 = operand2 THEN
                          pc := pc + to_integer(signed(imm) sll 2);
                        END IF;  
                     -- BGTZ immediate operation
                     WHEN Ibgtz =>
                        IF signed(operand1) > 0 THEN
                          pc := pc + to_integer(signed(imm) sll 2);
                        END IF;  
                     -- LUI immediate operation 
                     WHEN Ilui => 
                        reg(src_tgt) <= std_logic_vector(unsigned(imm) ) & "0000000000000000";
                     -- Load word  LW memory immediate operation
                     WHEN Ilw =>
                        memory_read(to_integer(signed(operand1) + signed(imm)));
                        state <= mem_read;
                     -- Store word SW memory immediate operation
                     WHEN Isw => 
                        address_temp := std_logic_vector(signed(operand1) + signed(imm));
                        data_temp    := operand2;
						state 		<= mem_write;
                        memory_write(address_temp,data_temp);
                     WHEN OTHERS =>   
                    END CASE ; -- end case opcode
                WHEN mem_read =>
                    reg(src_tgt)  <= databus_in;
                    
                    -- Fetch
                    memory_read(pc);
                    -- Increase program counter
                    pc := pc+4;
                    
                    state     <= decode;
				WHEN mem_write =>
					state 	<= fetch;
            END CASE;
            reg(0) <= (OTHERS => '0');
        END IF;
    END PROCESS;

END ARCHITECTURE;
