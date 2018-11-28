--  VHDL module to control the ball
-- keeps counters running that move the ball
-- takes inputs to tell when the ball bounces
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; -- allows increment/decrement to STD_LOGIC_VECTOR

------------------------------sync_counter
entity BALL_CONTROLLER is
  generic(
    ball_r_x : INTEGER; -- reset coordinates
    ball_r_y : INTEGER; -- reset coordinates
    ball_v_x : INTEGER; --x inverse speed (updates / pixel)
    ball_v_y : INTEGER -- y inverse speed
  );
  port(
    clock, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable
    ball_will_bounce_x, ball_will_bounce_y : in STD_LOGIC;
    ball_pos_x, ball_pos_y : out STD_LOGIC_VECTOR(9 downto 0);
    ball_pos_x_next, ball_pos_y_next : out  STD_LOGIC_VECTOR(9 downto 0)
  );
end  entity BALL_CONTROLLER;

-------------------------------Architecture
architecture rtl of Paddle_Controller is
  --signal ball_pos_x_tmp, ball_pos_y_tmp : STD_LOGIC_VECTOR(9 downto 0);
  signal ball_x_dir, ball_y_dir : STD_LOGIC; --1 if moving forward, 0 if neg
  signal ball_v_x_cnt, ball_v_y_cnt : STD_LOGIC_VECTOR(9 downto 0); -- counts up to calculate velocity
begin

  update_pos : process (clock, resetl, enable)
  begin
    if resetl = '0' then
      ball_pos_x <= ball_r_x;
      ball_pos_y <= ball_r_y;
      ball_x_dir <= '0';
      ball_y_dir <= '0';
      ball_v_x_cnt <= "0000000000";
      ball_v_y_cnt <= "0000000000";
    end if;

    if rising_edge(clock) and enable = '1' then
      ball_v_x_cnt = ball_v_x_cnt + 1;
      ball_v_y_cnt = ball_v_y_cnt + 1;

      -- handle bounces
      if ball_will_bounce_x = '1' then
        ball_x_dir = not ball_x_dir;
      end if;

      if ball_will_bounce_y = '1' then
        ball_y_dir = not ball_y_dir;
      end if;

      --move ball position
      if ball_v_x_cnt = ball_v_x - 1 then
        ball_v_x_cnt <= "0000000000";
        if ball_x_dir = '1' then
          ball_pos_x <= ball_pos_x + 1;
        else
          ball_pos_x <= ball_pos_x - 1; 
        end if;
      end if;
      
      if ball_v_y_cnt = ball_v_y - 1 then
        ball_v_y_cnt <= "0000000000";
        if ball_y_dir = '1' then
          ball_pos_y <= ball_pos_y + 1;
        else
          ball_pos_y <= ball_pos_y - 1;
        end if;
      end if;
    end if;
  end process update_pos;

  next_pos : process(ball_pos_x, ball_pos_x, ball_x_dir, ball_y_dir)
  begin
    if ball_x_dir = '1' then
      ball_pos_x_next = ball_pos_x + 1;
    else
      ball_pos_x_next = ball_pos_x - 1;
    end if;

    if ball_y_dir = '1' then
      ball_pos_y_next = ball_pos_y + 1;
    else
      ball_pos_y_next = ball_pos_y - 1;
    end if;

  end process next_pos;

end architecture rtl;