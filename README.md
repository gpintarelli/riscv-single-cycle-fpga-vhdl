# Processador RISC-V Monociclo — Projeto Didático em VHDL

Implementação didática de um processador RISC-V monociclo em VHDL, baseada na organização clássica de caminho de dados (datapath) e unidade de controle. O projeto utiliza uma FPGA para demonstrar a execução de instruções, com visualização da instrução atual nos displays HEX, do contador de programa (PC) nos LEDs e dos valores dos registradores x1–x4 no LCD.

O objetivo é facilitar o ensino de organização e arquitetura de computadores, permitindo acompanhar visualmente o funcionamento interno de um processador durante a execução de um programa.

## Recursos

- Banco de 32 registradores de 32 bits, com duas portas de leitura e uma de escrita.
- ULA com operações ADD, SUB, AND, OR e SLT.
- Instruções implementadas: ADD, SUB, AND, OR, SLT, ADDI, ANDI, ORI, SLTI, LW, SW, BEQ e JAL.
- Memória de instruções (ROM) e memória de dados com 64 palavras de 32 bits.
- Oito displays HEX mostram a instrução atual de 32 bits.
- LEDs verdes mostram os 9 bits menos significativos do PC.
- LCD 16×2 mostra os conteúdos dos registradores x1–x4 em hexadecimal.

## FPGA

O projeto está configurado para a FPGA Altera Cyclone II, com pinagem correspondente à placa DE2-70.

## Referências

- Harris, David e Sarah. *Digital Design and Computer Architecture*, seção 7.6 — referência da implementação-base, conforme atribuição em `riscvsingle.vhd`.
- Patterson & Hennessy — referência para a organização da unidade de controle, conforme os comentários do código.
