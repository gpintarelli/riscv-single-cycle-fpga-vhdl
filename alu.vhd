----------------------------------------------------------------------
-- ARITHMETIC LOGIC UNIT (ALU)
--
-- Arquitetura:
--   - Unidade combinacional de 32 bits
--   - Executa operações aritméticas e lógicas
--   - Controlada por sinal ALUControl (3 bits)
--
-- Ports:
--     a, b        -> Operandos de entrada (32 bits)
--     ALUControl  -> Código de controle da operação
--     ALUResult   -> Resultado da operação (32 bits)
--     Zero        -> Flag de resultado zero
--
-- Operações implementadas:
--
--   ALUControl = "000" -> ADD  (a + b)
--   ALUControl = "001" -> SUB  (a - b)
--   ALUControl = "010" -> AND  (a and b)
--   ALUControl = "011" -> OR   (a or b)
--   ALUControl = "101" -> SLT  (Set Less Than, baseado no bit de sinal)
--
-- Implementação:
--   - Soma/subtração compartilhando o mesmo somador
--   - Subtração via complemento de dois:
--         b invertido + 1 (quando ALUControl(0) = '1')
--   - Operações lógicas realizadas diretamente por portas AND/OR
--   - SLT utiliza bit de sinal do resultado da subtração
--
-- Observações importantes:
--   - Unidade totalmente combinacional (sem clock)
--   - Zero = '1' quando ALUResult = 0
--   - Uso de NUMERIC_STD recomendado (evitar bibliotecas não padrão)
--
-- Hardware inferido pelo sintetizador:
--   - Somador de 32 bits
--   - Portas lógicas AND/OR
--   - Multiplexador selecionando a operação
--
----------------------------------------------------------------------
--            ┌───────────────┐
--    a ─────►│               │
--    b ─────►│      ALU      │── ALUResult
-- ALUControl►│               │── Zero
--            └───────────────┘
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port(a, b:       in     STD_LOGIC_VECTOR(31 downto 0);
       ALUControl: in     STD_LOGIC_VECTOR(2  downto 0);
       ALUResult:  buffer STD_LOGIC_VECTOR(31 downto 0);
       Zero:       out    STD_LOGIC);
end;

architecture behave of alu is
  signal condinvb, sum: STD_LOGIC_VECTOR(31 downto 0);
  signal v, isAddSub: STD_LOGIC; -- v é o bit de overflow
  
begin
  ----------------------------------------------------------------------
  -- Se ALUControl(0) = '0' → condinvb = B  (ADD)
  -- Se ALUControl(0) = '1' → condinvb = not B (SUB)
  -- PS: Implementa parte do complemento de dois: A - B = A + (~B) + 1
  -- carry_in é o próprio ALUControl(0), que é usado para SUB
  ----------------------------------------------------------------------
  condinvb <= not b when Alucontrol(0)='1' else b;
  sum <= a + condinvb + Alucontrol(0);
  
  -- Flag para lógica do Overflow, que só faz sentido em ADD ou SUB:
  isAddSub <= (not ALUControl(2) and not ALUControl(1)) or (not ALUControl(1) and     ALUControl(0));  
  ----------------------------------------------------------------------
  -- Bloco combinacional principal da ALU
  ----------------------------------------------------------------------
  process(a,b,ALUControl,sum) begin
    case Alucontrol is
      when "000" =>  ALUResult <= sum; 		-- ADD (A + B)
      when "001" =>  ALUResult <= sum; 		-- SUB (A - B)
      when "010" =>  ALUResult <= a and b; 	-- AND bit-a-bit
      when "011" =>  ALUResult <= a or b; 	-- OR bit-a-bit
		
      ------------------------------------------------------------------
      -- "101" → SLT (Set Less Than)
      -- Após calcular A - B: sum(31) contém o bit de sinal do resultado.
      -- Se A < B → sum(31) = 1 → resultado = 000...0001
      -- Caso contrário → resultado = 000...0000
      -- Para o Resultado: Apenas o bit 0 recebe o sinal do SUB.
		-- "(0 => sum(31), others => '0')" é a agragação vetor
      ------------------------------------------------------------------
      when "101" =>  ALUResult <= (0 => (sum(31) xor v), others => '0');
		
      when others => ALUResult <= (others => 'X'); -- X é valor indefinido
    end case;
  end process;
  
  Zero <= '1' when ALUResult = X"00000000" else '0';
  
  -- Lógica de overflow: a e b têm mesmo sinal, mas resultado tem sinal diferente
  v <= not(ALUControl(0) xor a(31) xor b(31)) and (a(31) xor sum(31)) and isAddSub;
end;


----------------------------------------------------------------------
-- Comparação com Patterson & Hennessy (PH):
--
--   Nesta implementação:
--     - ALUControl possui 3 bits
--     - O controle é fornecido diretamente pela unidade de controle
--     - Modelo simplificado (estilo Harris & Harris)
--
--   No modelo do Patterson & Hennessy (MIPS):
--     - ALUControl geralmente possui 4 bits
--     - Existe uma unidade intermediária chamada "ALU Control"
--     - ALUOp (2 bits) + campo funct (6 bits da instrução)
--       são decodificados para gerar ALUControl
--     - Modelo mais fiel ao hardware real do MIPS
--
--   Estrutura conceitual:
--
--   Modelo simplificado (Harris):
--
--       Control ─────► ALUControl (3 bits) ─────► ALU
--
--   Modelo PH:
--
--       Instruction
--            │
--            ▼
--       Main Control ──► ALUOp
--                            │
--       Funct field ─────────┘
--                            ▼
--                       ALU Control
--                            │
--                            ▼
--                           ALU (4 bits)
--
-- Observação:
--   A diferença está na organização do controle,
--   não na capacidade funcional da ALU.
--   Ambas podem implementar as mesmas operações,
--   variando apenas o nível de abstração do projeto.
--
-- Esta ALU segue o modelo simplificado para facilitar
-- integração com datapaths didáticos e projetos iniciais.
----------------------------------------------------------------------