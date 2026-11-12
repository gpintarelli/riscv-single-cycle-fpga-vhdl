-- Programa Teste
--
--#  RISC-V Assembly        Descrição (didática)				                    Addr (DEC)  Addr (HEX)  Machine Code
--main:	 addi x1, x0, 5		  # Carrega 5 em x1                               0           0x00        0x00500093
--    	 addi x2, x1, 2		  # Soma 2 a x1 → x2 = 7                          4           0x04        0x00208113
--    	 addi x3, x1, -2		# Subtrai 2 de x1 → x3 = 3                      8           0x08        0xffe08193
--    	 sub  x4, x1, x3		# x4 = 5 - 3 = 2                                12          0x0C        0x40308233
--    	 or   x4, x1, x3		# Operação OR bit a bit: 5 OR 3 = 7             16          0x10        0x0030e233
--    	 and  x4, x1, x3		# Operação AND bit a bit: 5 AND 3 = 1           20          0x14        0x0030f233
--
--    	 beq  x1, x2, end	  # Se x1 == x2 salta para end (não acontece)     24          0x18        0x04208663
--    	 slt  x4, x2, x1		# x4 = 1 se 7 < 5 (falso → x4 = 0)              28          0x1C        0x00112233
--    	 beq  x4, x0, salto # Se x4 == 0 salta para 'salto' (acontece)      32          0x20        0x00020463
--    	 addi x4, x0, 255	  # Não executa (foi desviado)                    36          0x24        0x0ff00213
--
--salto: slt  x4, x3, x1		# x4 = 1 se 3 < 5 (verdadeiro → x4 = 1)         40          0x28        0x0011a233
--    	 addi x4, x0, 12		# x4 recebe 12 (usado como base de endereço)    44          0x2C        0x00c00213
--    	 sw   x1, 48(x4)		# Armazena x1 em memória: 12 + 48 = 60          48          0x30        0x02122823
--    	 lw   x4, 60(x0)		# Carrega mem[60] em x4                         52          0x34        0x03c02203
--
--     	 addi x1, x0, 0		  # Zera x1 (será usado como contador)            56          0x38        0x00000093
--     	 add  x3, x2, x3		# x3 = 7 + 3 = 10 (contador do loop)            60          0x3C        0x003101b3
--
--    	 jal  x2, loop		  # Salta para 'loop' e salva PC+4 em x2 (0x44)   64          0x40        0x0080016f
--    	 addi x4, x0, 255	  # Não executa (foi desviado pelo jal)           68          0x44        0x00ff0213
--
--loop:	 addi x1, x1, 1		  # Incrementa x1                                 72         0x48         0x00108093
--    	 addi x3, x3, -1		# Decrementa o contador x3                      76         0x4C         0xfff18193
--    	 beq  x3, x0, save	# Se contador chegou a zero → salva resultado   80         0x50         0x00018463
--    	 beq  x0, x0, loop	# Salto incondicional (repete o loop)           84         0x54         0xfe000ae3
--
--save:	 addi x4, x0, 10		# x4 = 10 (endereço base)                       88         0x58         0x00a00213
--       sw   x1, 0(x4)	  	# mem[10] = valor final de x1                   92         0x5C         0x00122023
--       lw   x1, 0(x4)		  # Lê novamente mem[10] para x1                  96         0x60         0x00022083
--
--end:	 beq  x0, x0, end	  # Loop infinito (fim do programa)               100        0x64         0x00000063


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package program_pkg is

  constant IMEM_WORDS : integer := 64;

  type ramtype is array (0 to IMEM_WORDS-1)
                    of STD_LOGIC_VECTOR(31 downto 0);

  constant PROGRAM : ramtype := (
    -- Programa RISC-V (valores em HEX)
    0  => X"00500093", -- addi x1, x0, 5
    1  => X"00208113", -- addi x2, x1, 2
    2  => X"FFE08193", -- addi x3, x1, -2
    3  => X"40308233", -- sub  x4, x1, x3
    4  => X"0030E233", -- or   x4, x1, x3
    5  => X"0030F233", -- and  x4, x1, x3
    6  => X"04208663", -- beq  x1, x2, end
    7  => X"00112233", -- slt  x4, x2, x1
    8  => X"00020463", -- beq  x4, x0, salto
    9  => X"0FF00213", -- addi x4, x0, 255
    10 => X"0011A233", -- slt  x4, x3, x1
    11 => X"00C00213", -- addi x4, x0, 12
    12 => X"02122823", -- sw   x1, 48(x4)
    13 => X"03C02203", -- lw   x4, 60(x0)
    14 => X"00000093", -- addi x1, x0, 0
    15 => X"003101B3", -- add  x3, x2, x3
    16 => X"0080016F", -- jal  x2, loop
    17 => X"00FF0213", -- addi x4, x0, 255
    18 => X"00108093", -- addi x1, x1, 1
    19 => X"FFF18193", -- addi x3, x3, -1
    20 => X"00018463", -- beq  x3, x0, save
    21 => X"FE000AE3", -- beq  x0, x0, loop
    22 => X"00A00213", -- addi x4, x0, 10
    23 => X"00122023", -- sw   x1, 0(x4)
    24 => X"00022083", -- lw   x1, 0(x4)
    25 => X"00000063", -- beq  x0, x0, end
    -- resto da memória zerado
    others => (others => '0')
  );

end package;