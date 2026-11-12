----------------------------------------------------------------------
-- 2:1 MULTIPLEXER (MUX2)
--
-- Arquitetura:
--   - Multiplexador combinacional de 2 entradas
--   - Largura configurável via generic (parametrizável)
--     width -> Define o número de bits do barramento (default = 8)
--
-- Ports:
--     d0  -> Entrada 0  (width bits)
--     d1  -> Entrada 1  (width bits)
--     s   -> Sinal de seleção (1 bit)
--     y   -> Saída selecionada (width bits)
--
-- Funcionamento:
--     Se s = '0' → y = d0
--     Se s = '1' → y = d1
--
-- Implementação:
--   - Lógica puramente combinacional
--   - Sintetiza como width X multiplexadores 2:1 em paralelo
--   - Cada bit da saída é:
--         y(i) = (¬s AND d0(i)) OR (s AND d1(i))
--
-- Observações:
--   - Não possui clock (sem elementos sequenciais)
--   - Utilizado em datapaths para seleção de operandos,
--     resultados intermediários ou controle de fluxo
--
-- Hardware inferido pelo sintetizador:
--   - width MUX 2:1 implementados em LUTs
--
----------------------------------------------------------------------
--            ┌───────────────┐
--     d0 ───►│               │
--     d1 ───►│     MUX 2:1   │── y
--      s ───►│               │
--            └───────────────┘
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux2 is -- two-input multiplexer
  generic(width: integer :=8);
  port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
       s:      in  STD_LOGIC;
       y:      out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of mux2 is
begin
  y <= d1 when s='1' else d0;
end;

