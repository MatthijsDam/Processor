LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE instruction_decode_defs IS

  -- opcodes
  CONSTANT Rtype : std_logic_vector(5 DOWNTO 0) := "000000";
    -- functions
    CONSTANT F_add : std_logic_vector(5 DOWNTO 0) := "100000";
    CONSTANT F_and : std_logic_vector(5 DOWNTO 0) := "100100";
    CONSTANT F_divu : std_logic_vector(5 DOWNTO 0) := "011011";
    CONSTANT F_mult : std_logic_vector(5 DOWNTO 0) := "011000";
    CONSTANT F_mfhi : std_logic_vector(5 DOWNTO 0) := "010000";
    CONSTANT F_mflo : std_logic_vector(5 DOWNTO 0) := "010010";
    CONSTANT F_or : std_logic_vector(5 DOWNTO 0) := "100101";
    CONSTANT F_sub : std_logic_vector(5 DOWNTO 0) := "100010";
    CONSTANT F_xor : std_logic_vector(5 DOWNTO 0) := "100110";
    CONSTANT F_nop : std_logic_vector(5 DOWNTO 0) := "000000";
  
  CONSTANT Iadd : std_logic_vector(5 DOWNTO 0) := "001000";
  CONSTANT Iand : std_logic_vector(5 DOWNTO 0) := "001100";
  CONSTANT Ilui : std_logic_vector(5 DOWNTO 0) := "001111";
  CONSTANT Ior : std_logic_vector(5 DOWNTO 0) := "001101";
  CONSTANT Ibeq : std_logic_vector(5 DOWNTO 0) := "000100";
  CONSTANT Ibgtz : std_logic_vector(5 DOWNTO 0) := "000111";
  CONSTANT Ilw : std_logic_vector(5 DOWNTO 0) := "100011";
  CONSTANT Isw : std_logic_vector(5 DOWNTO 0) := "101011";  

  CONSTANT Jjump : std_logic_vector(5 DOWNTO 0) := "000010";

END instruction_decode_defs;
