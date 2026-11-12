--7seg display decoder

library ieee;
use ieee.std_logic_1164.all;

entity dec7seg is
port (valueToHex:  in std_logic_vector (3 downto 0); -- 4 bits (1HEX)
      Display7Seg: out std_logic_vector (6 downto 0)); -- 7 bits (numero HEX)
end dec7seg;

architecture dec7seg_str of dec7seg is
begin		
		-- DE2 has pull up in the leds (common anode)
  Display7Seg <= "1000000" when valueToHex="0000" else -- 0
                 "1111001" when valueToHex="0001" else -- 1
                 "0100100" when valueToHex="0010" else -- 2
                 "0110000" when valueToHex="0011" else -- 3
                 "0011001" when valueToHex="0100" else -- 4
                 "0010010" when valueToHex="0101" else -- 5
                 "0000010" when valueToHex="0110" else -- 6
                 "1111000" when valueToHex="0111" else -- 7
                 "0000000" when valueToHex="1000" else -- 8
                 "0011000" when valueToHex="1001" else -- 9
                 "0001000" when valueToHex="1010" else -- 10-A
                 "0000011" when valueToHex="1011" else -- 11-b
                 "1000110" when valueToHex="1100" else -- 12-C
                 "0100001" when valueToHex="1101" else -- 13-d
                 "0000110" when valueToHex="1110" else -- 14-E
                 "0001110" when valueToHex="1111" else -- 15-F
                 "0000000";
end dec7seg_str;