-- 7seg display decoder
-- Group of 8X 7seg display decoder

library ieee;
use ieee.std_logic_1164.all;

entity dec7Disp8 is
  port (valueToHex:   in STD_LOGIC_VECTOR(31 downto 0);   -- 32 bits (8HEX)
        Display7Seg0: out STD_LOGIC_VECTOR (6 downto 0); -- 7 bits cada (numero HEX)
        Display7Seg1: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg2: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg3: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg4: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg5: out STD_LOGIC_VECTOR (6 downto 0);      
        Display7Seg6: out STD_LOGIC_VECTOR (6 downto 0);
        Display7Seg7: out STD_LOGIC_VECTOR (6 downto 0));
end dec7Disp8;

architecture struct of dec7Disp8 is
  component dec7seg
    port (valueToHex:  in std_logic_vector (3 downto 0);
          Display7Seg: out std_logic_vector (6 downto 0));
  end component;

begin		
  dec7seg0: dec7seg port map(valueToHex(31 downto 28), Display7Seg0);
  dec7seg1: dec7seg port map(valueToHex(27 downto 24), Display7Seg1);
  dec7seg2: dec7seg port map(valueToHex(23 downto 20), Display7Seg2);
  dec7seg3: dec7seg port map(valueToHex(19 downto 16), Display7Seg3);
  dec7seg4: dec7seg port map(valueToHex(15 downto 12), Display7Seg4);
  dec7seg5: dec7seg port map(valueToHex(11 downto 8),  Display7Seg5);
  dec7seg6: dec7seg port map(valueToHex(7 downto 4),   Display7Seg6);
  dec7seg7: dec7seg port map(valueToHex(3 downto 0),   Display7Seg7);
end struct;