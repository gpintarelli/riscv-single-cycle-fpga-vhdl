----------------------------------------------------------------------
-- INSTRUCTION MEMORY (IMEM)
--
-- Arquitetura:
--   - Memória somente leitura (ROM)
--   - 64 palavras de 32 bits
--   - Acesso por palavra (word-aligned)
--   - Leitura puramente combinacional
--
-- Ports:
--     a   -> Endereço (32 bits, vindo do PC)
--     rd  -> Instrução lida (32 bits)
--
-- Organização interna:
--   - A memória é inicializada a partir do package "program_pkg"
--   - Cada posição armazena uma instrução RISC-V (32 bits)
--   - Endereço efetivo usa bits a(31 downto 2)
--     (descarta os 2 LSB → alinhamento por palavra)
--
-- Funcionamento:
--   - O PC fornece um endereço byte-addressed
--   - Como instruções têm 4 bytes:
--         endereço / 4 → índice da memória
--   - Portanto:
--         mem[a(31 downto 2)]
--
-- Observações importantes:
--   - Não possui clock (ROM combinacional)
--   - Não possui escrita
--   - Pode ser inferida como ROM em BRAM
--   - Ideal para arquitetura Harvard
--
-- Hardware inferido pelo sintetizador:
--   - Memória ROM (Block RAM ou LUTs)
--   - Multiplexação interna para seleção da palavra
--
----------------------------------------------------------------------
--             ┌────────────────────┐
--      a ────►│                    │
--             │        IMEM        │── rd
--             │   (Instruction)    │
--             └────────────────────┘
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Importa o programa definido em arquivo separado
use work.program_pkg.all;

entity imem is
  port(
    a  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Endereço (PC)
    rd : out STD_LOGIC_VECTOR(31 downto 0)   -- Instrução
  );
end;

architecture rtl of imem is
  -- Memória interna inicializada com o programa
  signal mem : ramtype := PROGRAM;

begin
  ------------------------------------------------------------------
  -- Leitura combinacional (word-aligned)
  --
  -- a(31 downto 2):
  --   descarta os dois bits menos significativos
  --   (porque cada instrução ocupa 4 bytes)
  --
  -- Exemplo:
  --   PC = 0x00000000 → mem(0)
  --   PC = 0x00000004 → mem(1)
  --   PC = 0x00000008 → mem(2)
  ------------------------------------------------------------------
  rd <= mem(
          to_integer(
            unsigned(a(31 downto 2))
          )
        );

end rtl;