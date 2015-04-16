--------------------------------------------------------------
-- 
-- Processor
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;
USE instruction_decode_defs.ALL;


ENTITY processor_bhv IS
    PORT(
        address_bus     : OUT std_logic_vector(31 DOWNTO 0);
        databus_in      : IN  std_logic_vector(31 DOWNTO 0);
        databus_out     : OUT std_logic_vector(31 DOWNTO 0);
        write           : OUT std_logic;
        reset           : IN  std_logic;
		enable 			: IN  std_logic;
        clk             : IN  std_logic
    );
END processor_bhv;

ARCHITECTURE behaviour OF processor_bhv IS
    TYPE fsm_state_t IS (fetch, execute, mem_read);
    SIGNAL state : fsm_state_t;  
      
    TYPE reg_bank_t IS ARRAY (0 TO 31) OF std_logic_vector(31 DOWNTO 0); 
    SIGNAL reg                      : reg_bank_t := 
         ("00000000000000000000000000000000",
          OTHERS => "00000000000000000000000000000000"
          );
          
    SIGNAL reg_LO, reg_HI : std_logic_vector(31 DOWNTO 0);

    
BEGIN


    PROCESS(clk,reset)
        VARIABLE pc                 : INTEGER := -4;

        VARIABLE instruction        : std_logic_vector(31 DOWNTO 0);
       
        VARIABLE opcode             : std_logic_vector(5 DOWNTO 0);

        VARIABLE src                : INTEGER RANGE 0 TO 31;
        VARIABLE src_tgt            : INTEGER RANGE 0 TO 31;
        VARIABLE dst                : INTEGER RANGE 0 TO 31;
        
        VARIABLE operand1           : std_logic_vector(31 DOWNTO 0);
        VARIABLE operand2           : std_logic_vector(31 DOWNTO 0);
        
        VARIABLE funct              : std_logic_vector(5 DOWNTO 0);

        VARIABLE imm16              : std_logic_vector(15 DOWNTO 0);
        VARIABLE imm                : std_logic_vector(31 DOWNTO 0);
        VARIABLE target             : std_logic_vector(25 DOWNTO 0);
        VARIABLE temp64             : std_logic_vector(63 DOWNTO 0);
        VARIABLE temp_pc            : std_logic_vector(31 DOWNTO 0);  
        
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

        ELSIF rising_edge(clk)  AND enable = '1'  THEN
            CASE state IS
                WHEN fetch =>
                    --
                    -- Instruction fetch
                    -- 
                    
                    memory_read(pc);
                                   -- Increase program counter
                    pc := pc+4;

                    state <= execute;

                WHEN execute =>
                    instruction := databus_in;
                    state       <= fetch; 
                  
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
                    imm16       := instruction(15 DOWNTO 0);
                    imm         := std_logic_vector(resize(signed(imm16),32));
                    -----------------------------------------
                    -- Jump (J-Type):
                    target      := instruction(25 DOWNTO 0);
                    -----------------------------------------
                    operand1    := reg(src);
                    operand2    := reg(src_tgt);
                    
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
                                reg_HI <= std_logic_vector( signed(operand1) mod signed(operand2) );
                                reg_LO <= std_logic_vector( signed(operand1) / signed(operand2) );
                            -- Arithmetic MULT
                            WHEN F_mult =>
                                 temp64 := std_logic_vector( signed(operand1) * signed(operand2) ); 
                                 reg_HI <= temp64(63 DOWNTO 32); 
                                 reg_LO <= temp64(31 DOWNTO 0);
                            -- Arithmetic SUB
                            WHEN F_sub =>
                                 reg(dst) <= std_logic_vector( signed(operand1) - signed(operand2) );                                 
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
                        reg(src_tgt) <= operand1 AND std_logic_vector(resize(unsigned(imm16),32));
                     -- OR immediate operation
                     WHEN Ior =>   
                        reg(src_tgt) <= operand1 OR std_logic_vector(resize(unsigned(imm16),32));
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
                        reg(src_tgt) <= std_logic_vector(unsigned(imm) sll 16);
                     -- Load word  LW memory immediate operation
                     WHEN Ilw =>
                        memory_read(to_integer(signed(operand1) + signed(imm)));
                        state <= mem_read;
                     -- Store word SW memory immediate operation
                     WHEN Isw => 
                        address_temp := std_logic_vector(signed(operand1) + signed(imm));
                        data_temp    := operand2;						
                        memory_write(address_temp,data_temp);
                     WHEN OTHERS =>     
                    END CASE;
                WHEN mem_read =>
                    reg(src_tgt)  <= databus_in;
                                   
                    memory_read(pc);
                                   -- Increase program counter
                    pc := pc+4;

                    state <= execute;
            END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE;


