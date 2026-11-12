----------------------------------------------------------------------
-- 3:1 MULTIPLEXER (MUX3)
--
-- Arquitetura:
--   - Multiplexador combinacional de 3 entradas
--   - Largura configurável via generic (parametrizável)
--     width -> Define o número de bits do barramento (default = 8)
--
-- Ports:
--     d0  -> Entrada 0  (width bits)
--     d1  -> Entrada 1  (width bits)
--     d2  -> Entrada 2  (width bits)
--     s   -> Sinal de seleção (2 bits)
--     y   -> Saída selecionada (width bits)
--
-- Funcionamento:
--     s = "00" → y = d0
--     s = "01" → y = d1
--     s = "10" → y = d2
--     s = "11" → indefinido (não utilizado)
--
-- Implementação:
--   - Lógica puramente combinacional
--   - Sintetiza como width X multiplexadores 3:1 em paralelo
--
-- Observações:
--   - Não possui clock (sem elementos sequenciais)
--   - Pode ser descrito com atribuição concorrente (when/else)
--     ou com process (if/case), produzindo o mesmo hardware
--
-- Hardware inferido pelo sintetizador:
--   - width MUX 3:1 implementados em LUTs
--
----------------------------------------------------------------------
--            ┌───────────────┐
--     d0 ───►│               │
--     d1 ───►│     MUX 3:1   │── y
--     d2 ───►│               │
--      s ───►│               │
--            └───────────────┘
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux3 is -- three-input multiplexer
  generic(width: integer :=8);
  port(d0, d1, d2: in  STD_LOGIC_VECTOR(width-1 downto 0);
       s:          in  STD_LOGIC_VECTOR(1 downto 0);
       y:          out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of mux3 is
begin
-- Alternativa equivalente sem processo:
  y <= d0 when s="00" else
       d1 when s="01" else
       d2 when s="10" else
       (others => '0');

-- Alternativa equivalente usando processo:
--  process(d0, d1, d2, s)
--  begin
--     if    (s = "00") then y <= d0;
--     elsif (s = "01") then y <= d1;
--     elsif (s = "10") then y <= d2;
--     else                 y <= (others => '0'); -- Zero caso seleção seja '11'
--     end if;
--   end process;
end;
