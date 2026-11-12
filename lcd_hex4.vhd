----------------------------------------------------------------------
-- LCD HEX DISPLAY CONTROLLER (lcd_hex4)
--
-- Descrição:
--   Controlador para display LCD 16x2 (HD44780 compatível)
--   Implementado para a placa DE2 (clock de 50 MHz).
--
--   O módulo exibe 4 valores de 32 bits em formato hexadecimal:
--
--       Linha 1: AAAAAAAABBBBBBBB
--       Linha 2: CCCCCCCCDDDDDDDD
--
--   Cada valor ocupa 8 caracteres HEX (32 bits = 8 dígitos).
--   Total por linha: 16 caracteres (preenche completamente o LCD).
--
----------------------------------------------------------------------
-- Funcionamento:
--
--   - O módulo implementa uma Máquina de Estados Finita (FSM)
--   - Inicializa o LCD após power-up
--   - Posiciona cursor na linha correta
--   - Envia caracteres ASCII correspondentes aos valores HEX
--   - Atualiza o display periodicamente (~100 ms)
--
--   Conversão:
--     Cada nibble (4 bits) é convertido para ASCII:
--       0x0–0x9 → '0'–'9'
--       0xA–0xF → 'A'–'F'
--
----------------------------------------------------------------------
-- Interface:
--
--   Entradas:
--     clk      -> Clock de 50 MHz da DE2
--     reset    -> Reset síncrono
--     valA     -> Primeiro valor (linha 1, esquerda)
--     valB     -> Segundo valor (linha 1, direita)
--     valC     -> Terceiro valor (linha 2, esquerda)
--     valD     -> Quarto valor (linha 2, direita)
--
--   Saídas:
--     LCD_D    -> Barramento de dados (8 bits)
--     LCD_RS   -> Register Select (0=comando, 1=dado)
--     LCD_RW   -> Read/Write (fixo em 0 = write)
--     LCD_EN   -> Enable (pulso de escrita)
--     LCD_ON   -> Liga display
--     LCD_BLON -> Liga backlight
--
----------------------------------------------------------------------
-- Temporização (para 50 MHz):
--
--   - Delay inicial ~40 ms após reset
--   - Delay após comando de linha ~100 µs
--   - Delay entre caracteres ~50 µs
--   - Atualização completa a cada ~100 ms
--
----------------------------------------------------------------------
-- Observações Importantes:
--
--   - Não utiliza leitura do Busy Flag (RW fixo em '0')
--   - Controle totalmente por temporização
--   - FSM separa claramente:
--         comando de linha
--         envio de caractere
--         delays de segurança
--   - Projeto didático para visualização de registradores
--     de um processador RISC-V em FPGA.
--
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_hex4 is
    port(
        clk      : in  std_logic; -- 50 MHz
        reset    : in  std_logic;

        valA     : in  std_logic_vector(31 downto 0);
        valB     : in  std_logic_vector(31 downto 0);
        valC     : in  std_logic_vector(31 downto 0);
        valD     : in  std_logic_vector(31 downto 0);

        LCD_D    : out std_logic_vector(7 downto 0);
        LCD_RS   : out std_logic;
        LCD_RW   : out std_logic;
        LCD_EN   : out std_logic;
        LCD_ON   : out std_logic;
        LCD_BLON : out std_logic
    );
end;

architecture rtl of lcd_hex4 is

    ------------------------------------------------------------------
    -- FSM
    ------------------------------------------------------------------
    type state_type is (
        INIT_DELAY,
        SET_LINE,
        WAIT_LINE,
        SEND_CHAR,
        EN_HIGH,
        EN_LOW,
        WAIT_CHAR,
        NEXT_POS,
        NEXT_LINE,
        REFRESH_DELAY
    );

    signal state : state_type := INIT_DELAY;

    ------------------------------------------------------------------
    -- Controles
    ------------------------------------------------------------------
    signal line      : integer range 0 to 1 := 0;
    signal pos       : integer range 0 to 15 := 0;
    signal delay_cnt : integer := 0;
    signal hold_cnt  : integer := 0;

    signal rs_reg    : std_logic := '0';
    signal data_reg  : std_logic_vector(7 downto 0);

    ------------------------------------------------------------------
    -- Temporizações (50 MHz)
    ------------------------------------------------------------------
    constant T_INIT    : integer := 2_000_000; -- 40 ms
    constant T_LINE    : integer := 5_000;     -- 100 us (seguro)
    constant T_CHAR    : integer := 2_500;     -- 50 us
    constant T_REFRESH : integer := 5_000_000; -- 100 ms
    constant EN_HOLD_T : integer := 20;        -- ~400 ns

    ------------------------------------------------------------------
    -- Função HEX → ASCII
    ------------------------------------------------------------------
    function hex_to_ascii(h : std_logic_vector(3 downto 0))
        return std_logic_vector is
    begin
        if unsigned(h) < 10 then
            return std_logic_vector(to_unsigned(48,8) + unsigned(h));
        else
            return std_logic_vector(to_unsigned(55,8) + unsigned(h));
        end if;
    end;

begin

    ------------------------------------------------------------------
    -- Saídas fixas
    ------------------------------------------------------------------
    LCD_ON   <= '1';
    LCD_BLON <= '1';
    LCD_RW   <= '0';

    LCD_RS <= rs_reg;
    LCD_D  <= data_reg;

    ------------------------------------------------------------------
    -- FSM principal
    ------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state <= INIT_DELAY;
            delay_cnt <= 0;
            line <= 0;
            pos  <= 0;
            LCD_EN <= '0';

        elsif rising_edge(clk) then

            case state is

                --------------------------------------------------
                -- Delay inicial após power-up
                --------------------------------------------------
                when INIT_DELAY =>
                    if delay_cnt < T_INIT then
                        delay_cnt <= delay_cnt + 1;
                    else
                        delay_cnt <= 0;
                        state <= SET_LINE;
                    end if;

                --------------------------------------------------
                -- Envia endereço da linha
                --------------------------------------------------
                when SET_LINE =>
                    rs_reg <= '0';

                    if line = 0 then
                        data_reg <= x"80"; -- linha 1
                    else
                        data_reg <= x"C0"; -- linha 2
                    end if;

                    state <= EN_HIGH;

                --------------------------------------------------
                -- Espera maior após comando de linha
                --------------------------------------------------
                when WAIT_LINE =>
                    if delay_cnt < T_LINE then
                        delay_cnt <= delay_cnt + 1;
                    else
                        delay_cnt <= 0;
                        state <= SEND_CHAR;
                    end if;

                --------------------------------------------------
                -- Envia caractere
                --------------------------------------------------
                when SEND_CHAR =>
                    rs_reg <= '1';

                    if line = 0 then
                        if pos < 8 then
                            data_reg <= hex_to_ascii(
                                valA(31-4*pos downto 28-4*pos));
                        else
                            data_reg <= hex_to_ascii(
                                valB(31-4*(pos-8) downto 28-4*(pos-8)));
                        end if;
                    else
                        if pos < 8 then
                            data_reg <= hex_to_ascii(
                                valC(31-4*pos downto 28-4*pos));
                        else
                            data_reg <= hex_to_ascii(
                                valD(31-4*(pos-8) downto 28-4*(pos-8)));
                        end if;
                    end if;

                    state <= EN_HIGH;

                --------------------------------------------------
                -- Pulso EN
                --------------------------------------------------
                when EN_HIGH =>
                    LCD_EN <= '1';
                    hold_cnt <= 0;
                    state <= EN_LOW;

                when EN_LOW =>
                    if hold_cnt < EN_HOLD_T then
                        hold_cnt <= hold_cnt + 1;
                    else
                        LCD_EN <= '0';
                        delay_cnt <= 0;

                        if rs_reg = '0' then
                            state <= WAIT_LINE;
                        else
                            state <= WAIT_CHAR;
                        end if;
                    end if;

                --------------------------------------------------
                -- Delay entre caracteres
                --------------------------------------------------
                when WAIT_CHAR =>
                    if delay_cnt < T_CHAR then
                        delay_cnt <= delay_cnt + 1;
                    else
                        state <= NEXT_POS;
                    end if;

                --------------------------------------------------
                -- Próxima posição
                --------------------------------------------------
                when NEXT_POS =>
                    if pos < 15 then
                        pos <= pos + 1;
                        state <= SEND_CHAR;
                    else
                        pos <= 0;
                        state <= NEXT_LINE;
                    end if;

                --------------------------------------------------
                -- Próxima linha
                --------------------------------------------------
                when NEXT_LINE =>
                    if line = 0 then
                        line <= 1;
                        state <= SET_LINE;
                    else
                        line <= 0;
                        delay_cnt <= 0;
                        state <= REFRESH_DELAY;
                    end if;

                --------------------------------------------------
                -- Atualização periódica
                --------------------------------------------------
                when REFRESH_DELAY =>
                    if delay_cnt < T_REFRESH then
                        delay_cnt <= delay_cnt + 1;
                    else
                        delay_cnt <= 0;
                        state <= SET_LINE;
                    end if;

            end case;
        end if;
    end process;

end rtl;