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
          


     Function sra_f(inp : signed) return signed is
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
        VARIABLE operand1a          : signed(31 DOWNTO 0);
        VARIABLE operand2a          : signed(31 DOWNTO 0);

        
        VARIABLE funct              : std_logic_vector(5 DOWNTO 0);

        VARIABLE imm                : std_logic_vector(15 DOWNTO 0);
        VARIABLE target             : std_logic_vector(25 DOWNTO 0);
        VARIABLE temp_pc            : std_logic_vector(31 DOWNTO 0); 

        VARIABLE partial_hi         : signed(32 DOWNTO 0);  -- help register for mult operation
        VARIABLE shift_cnt          : INTEGER RANGE 0 TO 31;

        VARIABLE quotient           : signed(31 DOWNTO 0); 
        VARIABLE divisor            : signed(31 DOWNTO 0); 
        VARIABLE remainder          : signed(32 DOWNTO 0);

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
            partial_hi      := (OTHERS => '0'); -- zero partial hi
            shift_cnt       := 0;
            quotient        := (OTHERS => '0');
            remainder       := (OTHERS => '0');
            divisor         := (OTHERS => '0');

            
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
                    operand1a   := signed(operand1);
                    operand2a   := signed(operand2);
                     
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
                            -- Arithmetic DIVU
                            WHEN F_divu =>
                                state <= execute;
                                if shift_cnt = 0 then
                                    remainder(31 downto 0)   := signed(reg(src));
                                    divisor     := signed(reg(src_tgt));
                                    quotient    := (OTHERS => '0');                               
                                end if;
                                remainder := remainder(31 downto 0) & '0';
                                if remainder < divisor then
                                    quotient := quotient(30 downto 0) & '1';
                                    remainder := remainder - divisor;
                                else
                                    quotient := quotient(30 downto 0) & '0';
                                end if;
                                
                                
                               -- reg_HI <= std_logic_vector( signed(operand1) mod signed(operand2) ); -- old behavioral code
                               --reg_LO <= std_logic_vector( signed(operand1) / signed(operand2) ); -- old behavioral code
                                shift_cnt   := shift_cnt + 1;
                                if shift_cnt = 31 then
                                    reg_HI      <= std_logic_vector(remainder(31 downto 0));
                                    reg_LO      <= std_logic_vector(quotient);
                                    quotient    := (OTHERS => '0');  
                                    shift_cnt   := 0;   
                                    state       <= fetch;                       
                                end if;
                            -- Arithmetic MULT
                            WHEN F_mult =>                    
                                -- operand1a is multiplicand, operand2a is multiplier                                                                                                                                                      
                                if operand2a(0) = '1' then
                                    if shift_cnt = 31 then
                                        partial_hi := partial_hi + (not operand1a(31) & not operand1a) + 1; -- last cycle, carry in becomes one               
                                    else 
                                        partial_hi := partial_hi + (operand1a(31) & operand1a);
                                    end if;
                                end if;


                                reg_LO         <= partial_hi(0) & reg_LO(31 downto 1); -- shift new partial_hi product bit into reg lo
                                partial_hi     := sra_f(partial_hi); -- shift partial_hi to next position
                                operand2a      := sra_f(operand2a); -- shift to the next bit multiplier - sign extended                                            
                                
                                state <= execute;
                                if shift_cnt = 31 then  -- mult operation done
                                    state          <= fetch;
                                    reg_HI         <= std_logic_vector(partial_hi(31 downto 0));
                                    partial_hi     := (OTHERS => '0');
                                    shift_cnt := 0;
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
                                 reg(dst) <= operand1 XOR operand2;                                 
                            -- NOP "operation"
                            WHEN F_nop =>
                            -- MFHI move from $HI to dst register
                            WHEN F_mfhi =>
                                  reg(dst) <= reg_HI;
                            -- MFLO move from $LO to dst register
                            WHEN F_mflo => 
                                  reg(dst) <= reg_LO;
                            WHEN OTHERS =>     
                        END CASE;

                     -- ADD immediate operation
                     WHEN Iadd =>
                        reg(src_tgt) <= std_logic_vector(signed(operand1) + signed(imm));
                     -- AND immediate operation
                     WHEN Iand =>
                        reg(src_tgt) <= operand1 AND imm;
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
                    END CASE;
                WHEN mem_read =>
                    reg(src_tgt)  <= databus_in;
                    
                    -- Fetch
                    memory_read(pc);
                    -- Increase program counter
                    pc := pc+4;
                    
                    state     <= execute;
				WHEN mem_write =>
					state 	<= fetch;
            END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE;


