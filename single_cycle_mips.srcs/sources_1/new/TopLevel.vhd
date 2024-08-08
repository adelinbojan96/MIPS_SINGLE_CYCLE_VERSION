library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
entity MIPS is
port
(
     clk : in std_logic;
     btn : in std_logic_vector(4 downto 0);
     sw : in std_logic_vector(15 downto 0);
     led : out std_logic_vector(15 downto 0);
     an : out std_logic_vector(7 downto 0);
     cat : out std_logic_vector(6 downto 0)
);
end MIPS;

architecture MIPS of MIPS is
component mpg is 
port
(
     clk : in std_logic;
     btn: in std_logic;
     enable: out std_logic
);
end component;
component inst_fetch is
port(
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
end component;
component op_fetch is
port
(
    clk: in std_logic;
    enable: in std_logic;
    regWrite: in std_logic;
    instr: in std_logic_vector(25 downto 0);
    regDst: in std_logic;
    extOp: in std_logic;
    wd: in std_logic_vector(31 downto 0);
    ext_Imm: out std_logic_vector(31 downto 0);
    funct: out std_logic_vector(5 downto 0);
    sa: out std_logic_vector(4 downto 0);
    rd1: out std_logic_vector(31 downto 0);
    rd2: out std_logic_vector(31 downto 0)
);
end component;
component execution_unit is
port
(
    pc_4: in std_logic_vector(31 downto 0);
    rd_1: in std_Logic_vector(31 downto 0);
    ALU_src: in std_logic;
    rd_2: in std_Logic_vector(31 downto 0);
    ext_imm: in std_Logic_vector(31 downto 0);
    sa: in std_logic_vector(4 downto 0);
    func: in std_Logic_vector(5 downto 0);
    alu_op: in std_Logic_vector(2 downto 0);
    zero: out std_Logic;
    ALU_res: out std_logic_vector(31 downto 0);
    Branch_Address: out std_Logic_vector(31 downto 0)
);
end component;

component DataMemory is
port
(
    clk: in std_logic;
    enable: in std_logic;
    mem_write: in std_logic;
    alu_res: in std_logic_vector(31 downto 0);
    rd2: in std_logic_vector(31 downto 0);
    mem_data: out std_logic_vector(31 downto 0);
    alu_res_out: out std_logic_vector(31 downto 0)
);
end component;
component MainControlUnit is
port
(
    instruction: in std_logic_vector(0 to 5);
    reg_dst: out std_logic;
    ext_op: out std_logic;
    alu_src: out std_logic;
    branch: out std_logic;
    jump: out std_logic;
    alu_op: out std_Logic_vector(2 downto 0);
    mem_write: out std_logic;
    mem_to_reg: out std_logic;
    reg_write: out std_logic
);
end component;
component ssd is 
port
(
    clk : in std_logic;
    digit0: in std_logic_vector(3 downto 0);
    digit1: in std_logic_vector(3 downto 0);
    digit2: in std_logic_vector(3 downto 0);
    digit3: in std_logic_vector(3 downto 0);
    digit4: in std_logic_vector(3 downto 0);
    digit5: in std_logic_vector(3 downto 0);
    digit6: in std_logic_vector(3 downto 0);
    digit7: in std_logic_vector(3 downto 0);
    cat: out std_logic_vector(6 downto 0);
    an: out std_logic_vector(7 downto 0)
);
end component;
signal read_data, jump_address, branch_address, instruction, wd, rd1, rd2, rd_1, rd_2, pc_4, ext_imm, ALU_res, alu_res_out, result: std_logic_vector(31 downto 0) := x"00000000";  
signal instr: std_logic_vector(25 downto 0);
signal jump, pcsrc, regWrite, regDst, extOp, ALU_src, zero : std_logic; 
signal funct, func: std_logic_vector(5 downto 0);
signal sa: std_logic_vector(4 downto 0);
signal alu_op: std_logic_vector(2 downto 0);
signal mem_to_reg, mem_write: std_logic;
signal outMuxDataMemory: std_logic_vector(31 downto 0);
signal branch, enable, reset: std_logic := '0';

signal switch: std_logic_vector(2 downto 0);
begin
    --jump_address <= pc_4 (31 downto 28) & instr(25 downto 0) & "00";
    instr <= instruction(25 downto 0);
    outMuxDataMemory <= read_data when mem_to_reg = '1' else alu_res_out;
    wd <= outMuxDataMemory;
    rd_1 <= rd1;
    rd_2 <= rd2;
    pcsrc <= branch and zero;
    func <= funct;
    MPG_component: mpg port map
    (
        clk => clk,
        btn => btn(0),
        enable => enable
    );
    MPG_component2: mpg port map --not necessary
    (   
        clk=>clk,
        btn => btn(1),
        enable => reset
    );
    INS_FETCH: inst_fetch port map
    (
        clk => clk,
        reset => btn(1),
        enable => enable,
        BranchAddress => branch_address,
        jumpAddress => jump_address,
        jump => jump,
        pcsrc => pcsrc,
        instruction => instruction,
        pc4 => pc_4
    );
    OP_FETCHING: op_fetch port map
    (
        clk => clk,
        enable => enable,
        regWrite => regWrite,
        instr => instr,
        regDst => regDst, --input here
        extOp => extOp,
        wd => wd,
        ext_Imm => ext_Imm, 
        funct => funct,
        sa => sa, 
        rd1 => rd1,
        rd2 => rd2
    ); 
    EX_UNIT: execution_unit port map
    (
        pc_4 => pc_4,
        rd_1 => rd_1,
        ALU_src => ALU_src,
        rd_2 => rd_2,
        ext_imm => ext_imm,
        sa => sa, 
        func => func, --input
        alu_op => alu_op,
        zero => zero, 
        ALU_res => ALU_res,
        Branch_Address => Branch_Address
    );
    DATA_MEM: DataMemory port map
    (
        clk => clk,
        enable => enable,
        mem_write => mem_write, 
        alu_res => alu_res, 
        rd2 => rd2, 
        mem_data => read_data,
        alu_res_out => alu_res_out
    );
    MAIN_UNIT: MainControlUnit port map
    (
        instruction => instruction(31 downto 26),
        reg_dst => regDst,
        ext_op => extOp,
        alu_src => ALU_src,
        branch => branch, 
        jump => jump,
        alu_op => alu_op, 
        mem_write => mem_write,
        mem_to_reg => mem_to_reg,
        reg_write => regWrite
    );
    switch <= sw(15 downto 13);
    process(switch)
        begin
            case switch is 
                when "000" => result <= instruction;
                when "001" => result <= pc_4;
                when "010" => result <= rd1; --check
                when "011" => result <= rd2; --check
                when "100" => result <= ext_imm;
                when "101" => result <= alu_res;
                when "110" => result <= read_data; --mem_data
                when "111" => result <= wd;
                when others => result <= x"00000000";
            end case;
    end process;
    SSD_MAPPING: ssd port map
    (
        clk => clk,
        digit0 => result(3 downto 0),
        digit1 => result(7 downto 4),
        digit2 => result(11 downto 8),
        digit3 => result(15 downto 12),
        digit4 => result(19 downto 16),
        digit5 => result(23 downto 20),
        digit6 => result(27 downto 24),
        digit7 => result(31 downto 28),
        cat => cat,
        an => an    
    );
    led <= result(15 downto 0);
end MIPS;
