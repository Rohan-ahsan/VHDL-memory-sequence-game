library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_game is
port(

    clk     : in std_logic;

    -- SW0 RESET (ACTIVE LOW)
    reset   : in std_logic;

    -- KEY0..KEY3
    btn1    : in std_logic;
    btn2    : in std_logic;
    btn3    : in std_logic;
    btn4    : in std_logic;

    -- GREEN LEDS
    led1    : out std_logic;
    led2    : out std_logic;
    led3    : out std_logic;
    led4    : out std_logic;

    -- RESULT LEDS
    correct_led : out std_logic;
    wrong_led   : out std_logic

);
end memory_game;

architecture behavior of memory_game is

------------------------------------------------
-- FSM STATES
------------------------------------------------

type state_type is (

    IDLE,

    GENERATE_SEQUENCE,

    SHOW_SEQUENCE,

    SHOW_PAUSE,

    HIDE_SEQUENCE,

    WAIT_INPUT,

    CORRECT,

    WRONG,

    WIN

);

------------------------------------------------
-- SEQUENCE STORAGE
------------------------------------------------

type sequence_array is array (0 to 9) of integer range 0 to 3;    --sequence lenth and Leds

------------------------------------------------
-- SIGNALS
------------------------------------------------

signal state : state_type := IDLE;
signal sequence : sequence_array := (others =>0);       --initially stores zero

signal round_length : integer range 1 to 10 := 1;       -- sequence length

signal show_index : integer range 0 to 9 := 0;

signal input_index : integer range 0 to 9 := 0;

signal counter : integer := 0;                          --delay
signal btn_lock : std_logic := '0';                     --prevents multiple setections from one press

signal last_btn : integer range 0 to 3 := 0;            

------------------------------------------------
-- 4-BIT MAXIMAL LFSR
------------------------------------------------

signal lfsr : std_logic_vector(3 downto 0) := "0001";

------------------------------------------------
-- CURRENT LED DISPLAY
------------------------------------------------

signal display_leds : std_logic_vector(3 downto 0) := "0000";

begin

------------------------------------------------
-- MAIN PROCESS
------------------------------------------------

------------------------------------------------
-- LFSR PROCESS (SEPARATED FOR FSM EXTRACTION)
------------------------------------------------

process(clk, reset)
begin

    if reset = '0' then

        lfsr <= "0001";

    elsif rising_edge(clk) then

        lfsr <= lfsr(2 downto 0) &
                (lfsr(3) xor lfsr(2));

        if lfsr = "0000" then
            lfsr <= "0001";
        end if;

    end if;

end process;
process(clk, reset)

begin

------------------------------------------------
-- RESET
------------------------------------------------

if reset = '0' then

    state <= IDLE;

    round_length <= 1;

    show_index <= 0;

    input_index <= 0;

    counter <= 0;

    sequence <= (others =>0);


    display_leds <= "0000";
 	 btn_lock <= '0';
    last_btn <= 0;

    led1 <= '0';
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';

    correct_led <= '0';
    wrong_led <= '0';

------------------------------------------------
-- CLOCK
------------------------------------------------

elsif rising_edge(clk) then

 
    ------------------------------------------------
    -- FSM
    ------------------------------------------------

    case state is
	 ------------------------------------------------
-- IDLE
------------------------------------------------

when IDLE =>

    led1 <= '0';
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';

    correct_led <= '0';
    wrong_led <= '0';

    counter <= counter + 1;

    if counter = 50000000 then

        counter <= 0;

        state <= GENERATE_SEQUENCE;

    end if;

------------------------------------------------
-- GENERATE NEXT SEQUENCE ELEMENT
------------------------------------------------

when GENERATE_SEQUENCE =>

    sequence(round_length-1)
        <= to_integer(unsigned(lfsr(1 downto 0)));

    show_index <= 0;

    display_leds <= "0000";

    state <= SHOW_SEQUENCE;

------------------------------------------------
-- SHOW SEQUENCE (CUMULATIVE)
------------------------------------------------

------------------------------------------------
-- SHOW CURRENT STEP
------------------------------------------------

when SHOW_SEQUENCE =>

    led1 <= '0';
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';

    case sequence(show_index) is

        when 0 =>
            led1 <= '1';

        when 1 =>
            led2 <= '1';

        when 2 =>
            led3 <= '1';

        when others =>
            led4 <= '1';

    end case;

    counter <= counter + 1;

    if counter = 50000000 then

        counter <= 0;

        state <= SHOW_PAUSE;

    end if;

------------------------------------------------
-- 0.5 SECOND PAUSE
------------------------------------------------

------------------------------------------------
-- GAP BETWEEN STEPS
------------------------------------------------

when SHOW_PAUSE =>

    led1 <= '0';
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';

    counter <= counter + 1;

    if counter = 25000000 then

        counter <= 0;

        if show_index = round_length - 1 then                --if LED should was the last LED in sequence

            state <= HIDE_SEQUENCE;

        else

            show_index <= show_index + 1;                     

            state <= SHOW_SEQUENCE;

        end if;

    end if;
	 ------------------------------------------------
-- HIDE SEQUENCE
------------------------------------------------

when HIDE_SEQUENCE =>

    led1 <= '0';
    led2 <= '0';
    led3 <= '0';
    led4 <= '0';

    display_leds <= "0000";

    input_index <= 0;
	 btn_lock <= '0';
    counter <= 0;

    state <= WAIT_INPUT;
	 
	 ------------------------------------------------
-- WAIT FOR USER INPUT
------------------------------------------------

when WAIT_INPUT =>

------------------------------------------------
-- WAIT FOR BUTTON RELEASE
------------------------------------------------

if btn_lock = '1' then

    if btn1='1' and
       btn2='1' and
       btn3='1' and
       btn4='1' then

        btn_lock <= '0';

    end if;

------------------------------------------------
-- DETECT NEW BUTTON PRESS
------------------------------------------------

else

    if btn1='0' then

        btn_lock <= '1';

        if sequence(input_index)=0 then                  --was Button1 expected?

            if input_index = round_length-1 then         --checking for last button

                counter <= 0;
                state <= CORRECT;

            else

                input_index <= input_index + 1;         -- if not last button,continue

            end if;

        else

            counter <= 0;
            state <= WRONG;

        end if;

    elsif btn2='0' then                                          

        btn_lock <= '1';                        

        if sequence(input_index)=1 then                             --was Button2 expected?

            if input_index = round_length-1 then                    --checking for last button

                counter <= 0;
                state <= CORRECT;

            else

                input_index <= input_index + 1;                      -- if not last button,continue

            end if;

        else

            counter <= 0;
            state <= WRONG;

        end if;

    elsif btn3='0' then                                             

        btn_lock <= '1';

        if sequence(input_index)=2 then                              --was Button3 expected?

            if input_index = round_length-1 then                     --checking for last button

                counter <= 0;
                state <= CORRECT;

            else

                input_index <= input_index + 1;                      -- if not last button,continue

            end if;

        else

            counter <= 0;
            state <= WRONG;

        end if;

    elsif btn4='0' then                                          

        btn_lock <= '1';

        if sequence(input_index)=3 then                            --was Button4 expected?

            if input_index = round_length-1 then                   --checking for last button

                counter <= 0;
                state <= CORRECT;

            else

                input_index <= input_index + 1;                     -- if not last button,continue

            end if;

        else

            counter <= 0;
            state <= WRONG;

        end if;

    end if;

end if;
------------------------------------------------
-- CORRECT
------------------------------------------------

when CORRECT =>

    correct_led <= '1';
    wrong_led <= '0';

    counter <= counter + 1;

    if counter = 50000000 then

        counter <= 0;

        correct_led <= '0';

        if round_length = 10 then

            state <= WIN;

        else

            round_length <= round_length + 1;

            state <= GENERATE_SEQUENCE;

        end if;

    end if;

------------------------------------------------
-- WRONG
------------------------------------------------

when WRONG =>

    correct_led <= '0';
    wrong_led <= '1';

    counter <= counter + 1;

    if counter = 50000000 then

        counter <= 0;

        wrong_led <= '0';

        round_length <= 1;

        state <= GENERATE_SEQUENCE;

    end if;

------------------------------------------------
-- WIN
------------------------------------------------

when WIN =>

    led1 <= '1';
    led2 <= '1';
    led3 <= '1';
    led4 <= '1';

    correct_led <= '1';
    wrong_led <= '0';

    counter <= counter + 1;

    if counter = 100000000 then

        counter <= 0;

        led1 <= '0';
        led2 <= '0';
        led3 <= '0';
        led4 <= '0';

        correct_led <= '0';

        round_length <= 1;

        state <= GENERATE_SEQUENCE;

    end if;

end case;

end if;

end process;

end behavior;