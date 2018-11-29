-- Controller arbiter
-- links the paddle_controller and ball_controller and coordinates their memory
--    access strategy

-- I fudged this,
 -- TODO - remove ball_bounce, and ball_next_pos from paddle_controller
    --    store last state of ball and paddle in these registers
    --    only draw/update if first-state != last state
    -- brick break logic - Don't worry about taking into acoutn diagonal.
        -- just get the ball to move first
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_unsigned.all; -- including this library makes it break. I don't know why

------------------------------sync_counter
entity Controller_arbiter is
  port(
    clock, aresetl, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable
    ball_pos_x : in STD_LOGIC_VECTOR(5 downto 0);
    ball_pos_y : in STD_LOGIC_VECTOR(4 downto 0);
    ball_dir_x : in STD_LOGIC;
    ball_dir_y : in  STD_LOGIC;
    ball_gonna_bounce_x : out STD_LOGIC;
    ball_gonna_bounce_y : out STD_LOGIC;
    ball_update : in STD_LOGIC;

    mem_address : out STD_LOGIC_VECTOR(10 downto 0);
    mem_data_in  : out STD_LOGIC_VECTOR(1 downto 0);
    mem_wren    : out STD_LOGIC  := '0';
    mem_data_out   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
  );
end  entity Controller_arbiter;

-------------------------------Architecture
architecture rtl of Controller_arbiter is
  type state_action is (init_wait, draw_ball, wait_for_changes, check_for_ball_bounce);
  signal present_state : state_action := init_wait;
  signal next_state : state_action := init_wait;

  --are these good practice? maybe
  signal state_counter : INTEGER := 0;

  signal old_ball_pos_x_reg : STD_LOGIC_VECTOR(5 downto 0) := "000000";
  signal old_ball_pos_y_reg : STD_LOGIC_VECTOR(4 downto 0) := "00000";

  --how long it takes to work in each state
  constant INIT_WAIT_LEN : INTEGER := 5;
  constant DRAW_BALL_LEN : INTEGER := 5;
  constant WAIT_FOR_CHANGES_LEN : INTEGER := 3;
begin
  
  --change those states
  seq : process(clock) is
  begin
    if rising_edge(clock) then
      if resetl = '0' then
        present_state <= init_wait;
      else
        present_state <= next_state;
      end if;
    end if;
  end process seq; 

  --do work in each state
  ns_output : process(clock)
  begin
    if rising_edge(clock) and enable = '1' then
      state_counter <= state_counter + 1;
      case present_state is

        when init_wait =>
          next_state <= init_wait;
          -- I'm milling to let the ball controller do its thing? I don't know if it needs this time, but I'm giving it plenty just in case because I don't want to debug it later

          if state_counter >= INIT_WAIT_LEN then
            state_counter <= 0;
            next_state <= draw_ball;
          end if;

        when draw_ball =>
          next_state <= draw_ball;

          case state_counter is
            when 3 => -- draw new ball
              mem_address <= ball_pos_y & ball_pos_x;
              mem_data_in <= "10"; -- bleh pixel
              mem_wren <= '1';
            when 1 => -- draw erased old ball --TODO does 4 give it enough cycles to write?
              mem_address <= old_ball_pos_y_reg & old_ball_pos_x_reg;
              mem_data_in <= "00"; -- background pixel
              mem_wren <= '1';
              old_ball_pos_x_reg <= ball_pos_x;
              old_ball_pos_y_reg <= ball_pos_y;
            when 4 => --register updated ball position
             -- old_ball_pos_x_reg <= ball_pos_x;
              --old_ball_pos_y_reg <= ball_pos_y;
              mem_wren <= '0';
            when others => --disable memory write
              mem_address <= "00000000000";
              mem_wren <= '0';
          end case;

          if state_counter >= DRAW_BALL_LEN then
            state_counter <= 0;
            next_state <= wait_for_changes;
          end if;
        when check_for_ball_bounce =>

        when wait_for_changes =>--TODO there's probably a better way to do this with a separate process sensitive to the ball_pos variables
          next_state <= wait_for_changes;

          --wait for ball update
          if ball_update ='1' then
            state_counter <= 0;
            next_state <= init_wait;
          end if;
      end case;
    end if;
  end process ns_output;

end architecture rtl;