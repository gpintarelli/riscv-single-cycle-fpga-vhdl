----------------------------------------------------------------------
-- ADDER (Somador Combinacional)
--
-- Descrição:
--   Unidade combinacional que realiza a soma de dois operandos.
--
-- Características:
--   - Lógica puramente combinacional
--
-- Uso no processador RISC-V:
--   • Cálculo do próximo PC sequencial:
--         PC + 4
--   • Cálculo de endereço de branch/jump:
--         PC + imediato (immext)
--
-- Papel arquitetural:
--   Ele é responsável pela atualização do Program Counter.
--
-- Observação:
--   A separação do adder da ALU permite reduzir o caminho crítico,
--   pois o cálculo de PC+4 ocorre em paralelo à execução da ALU.
--
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity adder is -- adder
  port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
       y:    out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of adder is
begin
  y <= a + b;
end;