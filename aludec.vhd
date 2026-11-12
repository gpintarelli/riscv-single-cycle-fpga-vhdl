----------------------------------------------------------------------
-- ALU CONTROL ECODER (aludec)
--
-- Descrição:
--   Decodificador da operação da ALU.
--   Recebe ALUOp do Main Decoder e utiliza os campos
--   funct3 e funct7 para determinar a operação exata.
--
-- Entradas:
--   • ALUOp   → operação de alto nível (00, 01, 10)
--   • funct3  → campo da instrução
--   • funct7b5→ bit 5 de funct7 (diferencia ADD/SUB)
--   • opb5    → bit 5 do opcode (auxilia distinções)
--
-- Funcionamento:
--
--   ALUOp = "00" → Operações de memória (ADD)
--   ALUOp = "01" → Branch (SUB para comparação)
--   ALUOp = "10" → Instruções aritméticas (R/I-type)
--
--   Para R-type:
--       ADD  vs SUB depende de funct7b5
--
--   Para I-type:
--       Determinado apenas por funct3
--
-- RtypeSub:
--   Detecta instrução SUB:
--       RtypeSub = funct7b5 AND opb5
--
-- Papel arquitetural:
--   Implementa o segundo nível da lógica de controle
--   descrita no PH, reduzindo complexidade do
--   decodificador principal.
--
-- Tipo:
--   Lógica combinacional.
--
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity aludec is
  port(opb5:       in  STD_LOGIC;
       funct3:     in  STD_LOGIC_VECTOR(2 downto 0);
       funct7b5:   in  STD_LOGIC;
       ALUOp:      in  STD_LOGIC_VECTOR(1 downto 0);
       ALUControl: out STD_LOGIC_VECTOR(2 downto 0));
end;

architecture behave of aludec is
  signal RtypeSub: STD_LOGIC;
begin
  RtypeSub <= funct7b5 and opb5; -- TRUE for R-type subtract
  
  process(opb5, funct3, funct7b5, ALUOp, RtypeSub) begin
    case ALUOp is
      when "00" =>                     ALUControl <= "000"; -- addition
      when "01" =>                     ALUControl <= "001"; -- subtraction
      when others => case funct3 is           -- R-type or I-type ALU
                       when "000" => if RtypeSub = '1' then
                                       ALUControl <= "001"; -- sub
                                     else
                                       ALUControl <= "000"; -- add, addi
                                     end if;
                       when "010" =>   ALUControl <= "101"; -- slt, slti
                       when "110" =>   ALUControl <= "011"; -- or, ori
                       when "111" =>   ALUControl <= "010"; -- and, andi
                       when others =>  ALUControl <= "---"; -- unknown
                     end case;
    end case;
  end process;
end;