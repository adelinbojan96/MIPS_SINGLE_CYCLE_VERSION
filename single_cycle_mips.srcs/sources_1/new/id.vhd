library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity INST_FETCH is
    Port (
          clk : in STD_LOGIC;
          reset : in STD_LOGIC;
          enable : in STD_LOGIC;
          branchAddress : in STD_LOGIC_VECTOR(31 downto 0);
          jumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
          jump : in STD_LOGIC;
          PCsrc : in STD_LOGIC;
          instruction : out STD_LOGIC_VECTOR(31 downto 0);
          PC4 : out STD_LOGIC_VECTOR(31 downto 0)
          );
end INST_FETCH;

architecture INST_FETCH of INST_FETCH is

-- ROM memory
type tROM is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
signal ROM : tROM := (
--- Testing program
    "00000000001000000001000000100000", -- add $2 $1 $0, HEX: 201020
    "00000000001000000001100000100010", -- sub $3 $1 $0, HEX: 201822
    "00000000011000100010000000100100", -- and $4 $3 $2, HEX: 622024
    "00000000011000100010100000100101", -- or $5 $3 $2, HEX: 622825
    "00000000000001000010000001000000", -- sll $4 $4 1, HEX: 42040
    "00000000000001010010100001000010", -- srl $5 $5 1, HEX: 52842
    "00100000100001000000000000000001", -- addi $4 $4 1, HEX: 20840001
    "00110100101001010000000000000001", -- ori $5 $5 1, HEX: 34A50001
    "00010000001001000000000000001011", -- beq $1, $4, 11; HEX: 1024000B
    "10001100001001010000000000000000", -- lw $5 0($1), HEX: 8C250000
    "10101100100001010000000000000000", -- sw $5 0($4), HEX: AC850000
    "00001000000000000000000000000000", -- j 0, HEX: 8000000
--- Program for summing the doubles of the elements from an array.
    --"00000000000000000000100000100000", -- saves counter of the loop add $1, $0, $0; HEX: 820
    --"00100000000001000000000000001010", -- saves max num of iterations addi $4, $0, 10; HEX: 2004000A
    --"00000000000000000001000000100000", -- add $2, $0, $0; HEX: 1020
    --"00000000000000000010100000100000", -- add $5, $0, $0; HEX: 2820
    --"00010000001001000000000000000111", -- beq $1, $4, 7; HEX: 10240007
    --"10001100010000110000000000000000", -- lw $3, 0($2); HEX: 8C430000
    --"00000000011000110001100000100000", -- doubles the number add $3 $3 $3; HEX: 631820
    --"10101100010000110000000000000000", -- sw $3, 0($2); HEX: AC430000
    --"00000000101000110010100000100000", -- add $5, $5, $3; HEX: A32820  
    --"00100000010000100000000000000100", -- addi $2, $2, 4; HEX: 20420004
    --"00100000001000010000000000000001", -- addi $1, $1, 1; HEX: 20210001
    --"00001000000000000000000000000100", -- j 4 ; HEX: 8000004
    --"10101100000001010000000000100000", -- sw $5, 32($0); HEX: AC050020
    others => X"00000000");                    


signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal outMuxLast, outMuxFirst : STD_LOGIC_VECTOR(31 downto 0);

begin

    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                pc <= outMuxLast;
            end if;
        end if;
    end process;

    instruction <= ROM(conv_integer(PC(6 downto 2)));
    pc4 <= pc + 4;
    outMuxFirst <= branchAddress when PCSrc = '1' else (pc + 4);  
    outMuxLast <= jumpAddress when jump = '1' else outMuxFirst;
    
end INST_FETCH;