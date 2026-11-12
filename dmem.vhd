----------------------------------------------------------------------
-- DATA MEMORY (DMEM)
--
-- Arquitetura:
--   - Memória de dados com 64 palavras de 32 bits
--   - Acesso por palavra (word-aligned)
--   - Escrita síncrona (clocked)
--   - Leitura combinacional
--
-- Ports:
--     clk  -> Clock do sistema
--     we   -> Write Enable (habilita escrita)
--     a    -> Endereço (32 bits)
--     wd   -> Write Data (32 bits)
--     rd   -> Read Data (32 bits)
--
-- Organização interna:
--   - 64 posições de memória
--   - Cada posição contém 32 bits
--   - Endereço efetivo usa bits a(7 downto 2)
--     (descarta os 2 LSB → alinhamento por palavra)
--
-- Funcionamento:
--   - Se we = '1' na borda de subida do clock:
--         mem[a(7 downto 2)] := wd
--				Exemplos:
--				0x00000000	mem(0)
--				0x00000004	mem(1)
--				0x00000008	mem(2)
--
--   - Leitura:
--         rd <= mem[a(7 downto 2)]
--     (atualiza sempre que 'a' muda)
--
-- Observações importantes:
--   - Memória modelada com variável interna
--   - Escrita ocorre apenas no clock
--   - Leitura é assíncrona
--   - Implementação típica de memória didática
--
----------------------------------------------------------------------
--             ┌────────────────────┐
--      a ────►│                    │
--     wd ────►│        DMEM        │── rd
--      we ───►│                    │
--     clk ───►│                    │
--             └────────────────────┘
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity dmem is -- data memory
  port(clk, we: in  STD_LOGIC;
       a, wd:   in  STD_LOGIC_VECTOR(31 downto 0);
       rd:      out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of dmem is
begin
  process(clk, a)
    -- Tipo da memória: 64 palavras de 32 bits
    type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
    -- Memória modelada como variável interna
    variable mem  : ramtype;
    -- Endereço convertido (word aligned)
    variable addr : integer range 0 to 63;
	 
  begin
    -- Converte endereço (descarta 2 LSB)
    addr := to_integer(unsigned(a(7 downto 2)));
	 
    -- Escrita síncrona
    if rising_edge(clk) then
      if we = '1' then
        mem(addr) := wd;
      end if;
    end if;
	 
    -- Leitura
    rd <= mem(addr);

  end process;
end;