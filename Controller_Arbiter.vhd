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
use IEEE.std_logic_unsigned.all; -- allows increment/decrement to STD_LOGIC_VECTOR

------------------------------sync_counter
entity Controller_arbiter is
  generic(
    paddle_length : INTEGER; --total cycles
    screen_width : INTEGER; -- how wide the paddle can go
    paddle_y : INTEGER; -- starting y coordinate
    paddle_min_x : STD_LOGIC_VECTOR(9 downto 0); --how far left you can go
    paddle_max_x : STD_LOGIC_VECTOR(9 downto 0) -- farthest right open space
  );
  port(
    clock, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable
    ball_pos_x, ball_pos_y : in STD_LOGIC_VECTOR(9 downto 0);
    ball_pos_x_next, ball_pos_y_next : in  STD_LOGIC_VECTOR(9 downto 0);
    paddle_leftedge_x : in STD_LOGIC_VECTOR(9 downto 0);
    paddle_ball_bounce : in STD_LOGIC

    mem_address : out STD_LOGIC(10 downto 0);
    mem_data  : out STD_LOGIC(1 downto 0);
    mem_wren    : out STD_LOGIC  := '0';
    mem_data_out   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
  );
end  entity Controller_arbiter;

-------------------------------Architecture
architecture rtl of Controller_arbiter is
  type state_action is (draw_paddle, draw_ball, read_next_ball, remove_brick, reset_game);
  signal present_state, next_state : state_action;
  --are these good practice? maybe
  signal state_counter : INTEGER := 0;
  signal state_len : INTEGER := 1;

  signal apocalyptic_game_ending_event_detected : STD_LOGIC := 0; --1 if we need to reset
  signal last_paddle_leftedge : STD_LOGIC_VECTOR (9 downto 0);  
begin
  
  seq : process(clock, resetl) is
  begin
    if resetl = '0' then
      present_state <= draw_paddle;
      next_state <= draw_paddle;

    end if;
    present_state <= next_state;
  end process seq; 

  ns_logic : process(present_state, state_counter, apocalyptic_game_ending_event_detected) --todo state_len??
  begin
    --only increment state if the current state has run its course
    if state_counter >= state_len then
      --normally no inputs,
      case present_state is
        when draw_paddle =>
           next_state <= draw_ball;
        when draw_ball =>
          next_state <= read_next_ball;
        when read_next_ball =>
          next_state <= remove_brick;
        when remove_brick =>
          next_state <+ draw_paddle;
        when reset_game =>
          next_state <= draw_paddle;
      end case;
    else
      next_state <= present_state;
    end if;

    if apocalyptic_game_ending_event_detected = '1' then
      next_state <= reset_game;
      apocalyptic_game_ending_event_detected <= '0'
    end if;
  end process ns_logic;

  op : process(clock, present_state, enable)
  begin
    if rising_edge(clock) and enable = '1':
        case present_state is
      when draw_paddle =>    --draw the paddle
        --TODO
      when draw_ball =>
        --TODO
      when read_next_ball =>
        --TODO
      when remove_brick =>
        --TODO
      when reset_game =>
        --TODO
    end case;

    --draw the ball

    -- 
    --read next_ball pos from memory
      -- determine if bounce from memory
      -- if you can, remove the brick
    end if;
  end process op;
  
-- comb or calculated bounce with paddle_controller
  
end architecture rtl;