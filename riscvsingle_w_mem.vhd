library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity riscvsingle_w_mem is -- Top-level design (CPU com memóricas imem e dmem)
  port(clk, reset:         in     STD_LOGIC;
       WriteData, DataAdr: buffer STD_LOGIC_VECTOR(31 downto 0);
       MemWrite:           buffer STD_LOGIC;
       iCLK_50:            in     STD_LOGIC; -- Clock da DE2-70 (usado para temporizacão da FSM do LCD1602)
       
       -- Outputs colocados para mostrar a Instrução (usa 8x HEX)
       oHEX0_D:            out STD_LOGIC_VECTOR (6 downto 0);
       oHEX1_D:            out STD_LOGIC_VECTOR (6 downto 0);      
       oHEX2_D:            out STD_LOGIC_VECTOR (6 downto 0);
       oHEX3_D:            out STD_LOGIC_VECTOR (6 downto 0);      
       oHEX4_D:            out STD_LOGIC_VECTOR (6 downto 0);
       oHEX5_D:            out STD_LOGIC_VECTOR (6 downto 0);      
       oHEX6_D:            out STD_LOGIC_VECTOR (6 downto 0);
       oHEX7_D:            out STD_LOGIC_VECTOR (6 downto 0);
       oLEDG:              out STD_LOGIC_VECTOR (8 downto 0);
       
       -- Outputs colocados para mostrar o valor de quadro registradoes no LCD1602
       LCD_D:              out std_logic_vector(7 downto 0);
       oLCD_RW:            out std_logic;
       oLCD_EN:            out std_logic;
       oLCD_RS:            out std_logic;
       oLCD_ON:            out std_logic;
       oLCD_BLON:          out std_logic);
end;

architecture archi of riscvsingle_w_mem is
  component riscvsingle
    port(clk, reset:           in  STD_LOGIC;
         PC:                   out STD_LOGIC_VECTOR(31 downto 0);
         Instr:                in  STD_LOGIC_VECTOR(31 downto 0);
         MemWrite:             out STD_LOGIC;
         ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
         ReadData:             in  STD_LOGIC_VECTOR(31 downto 0);
         x1debug, x2debug, x3debug, x4debug: out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  
  component imem
    port(a:  in  STD_LOGIC_VECTOR(31 downto 0);
         rd: out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  
  component dmem
    port(clk, we: in  STD_LOGIC;
         a, wd:   in  STD_LOGIC_VECTOR(31 downto 0);
         rd:      out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  
  -- Mostrar no display 7 seg
  component dec7Disp8
  port (valueToHex:   in STD_LOGIC_VECTOR(31 downto 0);
        Display7Seg0: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg1: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg2: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg3: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg4: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg5: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg6: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg7: out STD_LOGIC_VECTOR (6 downto 0));
  end component;
  
  -- Mostrar registrados no displayLCD
  component lcd_hex4
  port(
        clk      : in  std_logic; -- 50 MHz
        reset    : in  std_logic;
        valA     : in  std_logic_vector(31 downto 0);
        valB     : in  std_logic_vector(31 downto 0);
        valC     : in  std_logic_vector(31 downto 0);
        valD     : in  std_logic_vector(31 downto 0);
        LCD_D    : out std_logic_vector(7 downto 0);
        LCD_RS   : out std_logic;
        LCD_RW   : out std_logic;
        LCD_EN   : out std_logic;
        LCD_ON   : out std_logic;
        LCD_BLON : out std_logic);
  end component;

    
  signal PC, Instr, ReadData: STD_LOGIC_VECTOR(31 downto 0);
  signal valA, valB, valC, valD: STD_LOGIC_VECTOR(31 downto 0);
  
  begin
  -- Instancias processador e memórias
  rvsingle: riscvsingle port map(clk, not(reset), PC, Instr, MemWrite, DataAdr, WriteData, ReadData, valA, valB, valC, valD); -- Reset está negado por causa do lógica inversa da Key
  imem1: imem port map(PC, Instr);
  dmem1: dmem port map(clk, MemWrite, DataAdr, WriteData, ReadData);
  
  -- Mostra a Instrução nos displays HEX. Obs.: RISC-V é little endian. O byte menos significativo vai no menor endereço.
  dec7Disp8_1: dec7Disp8 port map(Instr, oHEX7_D, oHEX6_D, oHEX5_D, oHEX4_D, oHEX3_D, oHEX2_D, oHEX1_D, oHEX0_D);
  
  -- Mostra o PC nos LEDGs
  oLEDG <= PC(8 downto 0);
  
  -- Mostra x1-x4
  lcd_inst : lcd_hex4 port map(iCLK_50, '0', valA, valB, valC, valD, LCD_D, oLCD_RS, oLCD_RW, oLCD_EN, oLCD_ON, oLCD_BLON);
end;