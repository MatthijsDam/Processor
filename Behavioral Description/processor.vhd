--------------------------------------------------------------
-- 
-- Processor
--
--------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY processor IS
    PORT(
        address_bus     : OUT std_logic_vector(31 DOWNTO 0);
        databus_in      : IN  std_logic_vector(31 DOWNTO 0);
        databus_out     : OUT std_logic_vector(31 DOWNTO 0);
        read            : OUT std_logic;
        write           : OUT std_logic;
        reset           : IN  std_logic;
        clk             : IN  std_logic
    );
END processor;

ARCHITECTURE behaviour OF processor IS
    TYPE reg_t IS std_logic_vector(31 downto 0); -- one register is of 32 bit logic vector type
    SIGNAL reg                      : reg_t ( 31 downto 0 ); -- reg is the register file 32 registers wide.
    SIGNAL reg_LO, reg_HI           : reg_t;
    
BEGIN
    reg(0)          <= ( OTHERS => '0' ); -- register 0 is always zero


    PROCESS(clk,reset)
        VARIABLE pc                 : INTEGER := 0;
        VARIABLE instruction        : std_logic_vector(31 DOWNTO 0);
       
        VARIABLE opcode             : std_logic_vector(5 DOWNTO 0);

        VARIABLE src                : std_logic_vector(4 DOWNTO 0);
        VARIABLE src_tgt            : std_logic_vector(4 DOWNTO 0);

        VARIABLE dst                : std_logic_vector(4 DOWNTO 0);
        VARIABLE shamt              : std_logic_vector(4 DOWNTO 0);
        VARIABLE funct              : std_logic_vector(5 DOWNTO 0);

        VARIABLE imm                : std_logic_vector(15 DOWNTO 0);
        VARIABLE target             : std_logic_vector(25 DOWNTO 0);

        

    -- A read operation has 1 clock cycle delay
    PROCEDURE memory_read(
                pc      : IN INTEGER; 
                data    : OUT std_logic_vector(31 DOWNTO 0)) IS
        
        VARIABLE address     : std_logic_vector(31 DOWNTO 0);

        BEGIN
            read        <= '1';
            address     := std_logic_vector(to_unsigned(pc,30)) & "00";
            address_bus <= address;
            data        := databus_in;
    END memory_read;

    PROCEDURE memory_write(
                    address : IN std_logic_vector(31 DOWNTO 0); 
                    data    : IN std_logic_vector(31 DOWNTO 0)) IS    
        BEGIN
            write         <= '1';
            databus_out <= data;
    END memory_write;        

    BEGIN
        IF reset='1' THEN 
            pc              := 0;
            read            <= '0';
            write           <= '0';
            databus_out     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";
            address_bus     <= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU";


            
        ELSIF rising_edge(clk) THEN
       
            --
            -- Instruction fetch
            --
            memory_read(pc,instruction);

            -- Increase program counter
            pc := pc+1;

            --
            -- Decode and execute
            --

            -- Common
            opcode      := instruction(31 DOWNTO 26);

            -- Common R and I
            src         := instruction(25 DOWNTO 21);
            src_tgt     := instruction(20 DOWNTO 16);
            
            -- Both registers (R-Type):
            dst         := instruction(15 DOWNTO 11);
            shamt       := instruction(10 DOWNTO  6);    
            funct       := instruction( 5 DOWNTO  0);
            -----------------------------------------
            -- One immediate (I-Type):
            imm         := instruction(15 DOWNTO 0);
            -----------------------------------------
            -- Jump (J-Type):
            target      := instruction(25 DOWNTO 0);
            -----------------------------------------
            
            -- Decoding and execution
            CASE opcode IS
             -- Arithmetic registers operation or nop
             WHEN "000000" =>
                CASE funct IS
                    -- Arithmetic ADD
                    WHEN "100000" =>
                        --reg(dst) = std_logic_vector( to_signed(reg(src), 32) + to_signed(reg(src_tgt), 32) ); -- int to logic vector logic needs to be added
                    -- Arithmetic DIVU
                    WHEN "011011" =>
                        --reg(dst) = std_logic_vector( to_unsigned(reg(src), 32) / to_unsigned(reg(src_tgt), 32) ); -- int to logic vector logic needs to be addeda
                    -- Arithmetic MULT
                    WHEN "011000" =>
                    -- Arithmetic SUB
                    WHEN "100010" =>

                    -- Logic AND
                    WHEN "100100" =>           
                    -- Logic OR
                    WHEN "100101" =>
                    -- Logic XOR
                    WHEN "100110" =>

                    -- NOP "operation"
                    WHEN "000000" =>
                       --something with reg(0)
                    -- MFHI move from $HI to dst register
                    WHEN "010000" =>
                    -- MFLO move from $LO to dst register
                    WHEN "010010" =>      
                END CASE;

             -- ADD immediate operation
             WHEN "001000" =>
                --reg(src_tgt) = std_logic_vector(reg(src) + imm; -- int to logic vector logic needs to be added
             -- AND immediate operation
             WHEN "001100" =>
             -- OR immediate operation
             WHEN "001101" =>   

             -- JUMP immediate operation
             WHEN "000010" =>
             -- BEQ immediate operation
             WHEN "000100" =>   
             -- BGEZ immediate operation
             WHEN "000001" =>
             

             -- LUI immediate operation 
             WHEN "001111" => 
             -- Load word  LW memory immediate operation
             WHEN "100011" =>
             -- Store word SW memory immediate operation
             WHEN "101011" => 
            END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE;
