----------------------------------------------------------------------
-- CONTROLLER (Single-Cycle Control Unit)
--
-- Descrição:
--   Unidade de controle do processador RISC-V single-cycle.
--   Responsável por gerar todos os sinais de controle do datapath
--   a partir dos campos da instrução.
--
-- Estrutura:
--   - Main Decoder (maindec)
--       • Decodifica o opcode (op)
--       • Gera sinais principais do datapath
--       • Produz ALUOp
--
--   - ALU Decoder (aludec)
--       • Usa ALUOp + funct3 + funct7b5
--       • Define operação específica da ALU
--
-- Funcionamento:
--   1) O opcode determina:
--        • Escrita em registrador
--        • Escrita em memória
--        • Tipo de imediato (ImmSrc)
--        • Seleção do resultado (ResultSrc)
--        • Se é branch ou jump
--
--   2) A ALU é controlada por:
--        • ALUOp (nível alto)
--        • funct3 / funct7 (nível baixo)
--
--   3) O PCSrc é calculado por:
--        PCSrc = (Branch AND Zero) OR Jump
--
-- Papel arquitetural:
--   Implementa a lógica de controle apresentada no
--   livro Computer Organization and Design (PH),
--   separando controle principal e controle da ALU.
--
-- Tipo:
--   Lógica puramente combinacional.
--
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity controller is -- single-cycle controller
  port(op:             in     STD_LOGIC_VECTOR(6 downto 0);
       funct3:         in     STD_LOGIC_VECTOR(2 downto 0);
       funct7b5, Zero: in     STD_LOGIC;
       ResultSrc:      out    STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:       out    STD_LOGIC;
       PCSrc, ALUSrc:  out    STD_LOGIC;
       RegWrite:       out    STD_LOGIC;
       Jump:           buffer STD_LOGIC;
       ImmSrc:         out    STD_LOGIC_VECTOR(1 downto 0);
       ALUControl:     out    STD_LOGIC_VECTOR(2 downto 0));
end;

architecture struct of controller is
  component maindec
    port(op:             in  STD_LOGIC_VECTOR(6 downto 0);
         ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
         MemWrite:       out STD_LOGIC;
         Branch, ALUSrc: out STD_LOGIC;
         RegWrite, Jump: out STD_LOGIC;
         ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
         ALUOp:          out STD_LOGIC_VECTOR(1 downto 0));
  end component;
  component aludec
    port(opb5:       in  STD_LOGIC;
         funct3:     in  STD_LOGIC_VECTOR(2 downto 0);
         funct7b5:   in  STD_LOGIC;
         ALUOp:      in  STD_LOGIC_VECTOR(1 downto 0);
         ALUControl: out STD_LOGIC_VECTOR(2 downto 0));
  end component;
  
  signal ALUOp:  STD_LOGIC_VECTOR(1 downto 0);
  signal Branch: STD_LOGIC;
begin
  md: maindec port map(op, ResultSrc, MemWrite, Branch,
                       ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  ad: aludec port map(op(5), funct3, funct7b5, ALUOp, ALUControl);
  
  PCSrc <= (Branch and Zero) or Jump;
end;
