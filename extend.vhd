----------------------------------------------------------------------
-- IMMEDIATE EXTENSION UNIT (EXTEND)
--
-- Este módulo corresponde ao bloco de geração de imediato
-- No RISC-V Os bits do imediato ficam espalhados pela instrução
-- Cada formato organiza esses bits diferente
--
-- Arquitetura:
--   - Unidade combinacional
--   - Gera imediato de 32 bits a partir da instrução RISC-V
--   - Implementa extensão de sinal (sign-extension)
--
-- Função:
--   - Extrai os campos de imediato conforme o formato da instrução
--   - Reconstrói os bits espalhados na instrução
--   - Estende o bit de sinal até 32 bits
--
-- Ports:
--     instr   -> Bits relevantes da instrução (31 downto 7)
--     immsrc  -> Seleciona o tipo de imediato:
--                 "00" = I-type
--                 "01" = S-type
--                 "10" = B-type
--                 "11" = J-type
--     immext  -> Imediato expandido para 32 bits
--
-- Tipos suportados:
--   I-type (ADDI, LW, etc.)
--     imm[11:0] = instr[31:20]
--
--   S-type (SW)
--     imm[11:5] = instr[31:25]
--     imm[4:0]  = instr[11:7]
--
--   B-type (BEQ, BNE)
--     imm[12]   = instr[31]
--     imm[10:5] = instr[30:25]
--     imm[4:1]  = instr[11:8]
--     imm[11]   = instr[7]
--     imm[0]    = 0 (alinhamento)
--
--   J-type (JAL)
--     imm[20]   = instr[31]
--     imm[10:1] = instr[30:21]
--     imm[11]   = instr[20]
--     imm[19:12]= instr[19:12]
--     imm[0]    = 0 (alinhamento)
--
--   Obs: Existe instrução R-type, mas ela NÃO usa imediato,
--        porque o módulo extend só é usado quando: ALUSrc = 1
--
-- Observações importantes:
--   - Implementa extensão de sinal usando: (31 downto N => instr(31))
--   - Branches e Jumps possuem LSB fixo em '0'
--     pois os offsets são múltiplos de 2 bytes (halfword aligned)
--   - PH define o ImmGen recebendo a instrução toda instr[31:0],
--     mas isso nao muda o conceito da operação do extend ou ImmGen
--
-- Bit Swirl (RISC-V Encoding Strategy):
--     Nos formatos B e J, os bits do imediato não aparecem
--     na instrução em ordem crescente.
--     Essa reorganização (bit swirl) foi projetada para:
--   - Manter o bit de sinal sempre em instr(31)
--   - Reduzir multiplexadores no datapath
--   - Simplificar o hardware do Immediate Generator
--   - Diminuir o caminho crítico do processador
--   Ou seja, o encoding da instrução foi pensado
--   para facilitar a implementação física do hardware.
--
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity extend is -- extend unit
  port(instr:  in  STD_LOGIC_VECTOR(31 downto 7);
    immsrc: in  STD_LOGIC_VECTOR(1  downto 0);
    immext: out STD_LOGIC_VECTOR(31 downto 0));
end;
    
architecture behave of extend is
begin
  process(instr, immsrc) begin
    case immsrc is
      -- I-type
      when "00" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 20);
      -- S-types (stores)
      when "01" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7);
      -- B-type (branches)
      when "10" =>
        immext <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
      -- J-type (jal)
      when "11" =>
        immext <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
      when others =>
        immext <= (31 downto 0 => '-'); -- condição dont care, uma vez que o immext é irrelevante
    end case;
  end process;
end;
