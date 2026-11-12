----------------------------------------------------------------------
-- REGISTER FILE (3-PORT)
--
-- Arquitetura:
--   - 32 registradores x 32 bits (RISC-V)
--   - 2 portas de leitura (combinacionais)
--   - 1 porta de escrita (sequencial, clock)
--
--	Ports:
--     ReadReg1   -> a1   => Read Register 1 Addr (5 bits)
--     ReadReg2   -> a2   => Read Register 2 Addr (5 bits)
--     WriteReg   -> a3   => Write Register Addr (5 bits)
--     WriteData  -> wd3  => Data Write (32 bits)
--     RegWrite   -> we3  => Write Enable Control
--     Clock      -> clk
--
-- Implementação inferida pelo sintetizador:
--   - Escrita: decoder + enable + D flip-flops
--   - Leitura: 2X MUX 32:1 (32 bits)
--   - Forca sintetizador a ter esses componentes de HW, pois é um RegFile
--
-- Observação importante:
--   - Leitura é combinacional
--   - Escrita ocorre apenas na borda de subida do clock
--   - Se um registrador for lido e escrito no mesmo ciclo, a leitura retorna o valor antigo
--
-- Registrador x0:
--   - Endereço 0 é hardwired para 0x00000000
--   - Internamente pode ser escrito, mas nunca é lido
----------------------------------------------------------------------
--          ┌───────────────┐
--a1 ──────►│               │── rd1
--a2 ──────►│  REGISTER     │── rd2
--          │    FILE       │
--a3 ──────►│               │
--wd3 ─────►│               │
--we3 ─────►│               │
--clk ─────►│               │── x1, x2, x3, x4 (Usado para debug apenas)
--          └───────────────┘

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity regfile is
  port(clk:        in  STD_LOGIC; -- clock
       we3:        in  STD_LOGIC; -- enable para gravar registrador
       a1, a2, a3: in  STD_LOGIC_VECTOR(4  downto 0); -- endereços dos registradores
       wd3:        in  STD_LOGIC_VECTOR(31 downto 0); -- dado a ser gravado
       rd1, rd2:   out STD_LOGIC_VECTOR(31 downto 0); -- leituras
       x1debug, x2debug, x3debug, x4debug: out STD_LOGIC_VECTOR(31 downto 0) -- Usado para debug apenas
       );
end;

architecture behave of regfile is
  type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0); -- VHDL enumeration type (também usado para FSM)
  signal mem: ramtype; -- Cria array 32x32bits
  
begin
  -- Porta de escrita do register file
  -- Implementa escrita síncrona com enable (RegWrite)
  process(clk) begin
    if rising_edge(clk) then
      if we3='1' then mem(to_integer(unsigned(a3))) <= wd3; -- Data in
      end if;
    end if;
  end process;
  
  process(a1, a2) begin
    -- Porta de leitura 1 (combinacional)
    if (to_integer(unsigned(a1))=0) then rd1 <= X"00000000"; -- X"00000000 é HEX
    else rd1 <= mem(to_integer(unsigned(a1)));
    end if;
	 
    -- Porta de leitura 2 (combinacional)
    if (to_integer(unsigned(a2))=0) then rd2 <= X"00000000";
    else rd2 <= mem(to_integer(unsigned(a2)));
    end if;    
  end process;
      
  x1debug <= mem(1); -- Usado para debug apenas
  x2debug <= mem(2);
  x3debug <= mem(3);
  x4debug <= mem(4);
end;