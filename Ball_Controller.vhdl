--  VHDL module to *update* the ball's position
-- keeps counters running that move the ball
-- takes inputs to tell when the ball bounces
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

------------------------------sync_counter
entity BALL_CONTROLLER is
  generic(
    ball_r_x : INTEGER; -- reset coordinates (are in pixels) --TODO these don't do anything rn
    ball_r_y : INTEGER; -- reset coordinates
    ball_v_x_init : INTEGER := 20; --x inverse speed (updates / pixel moved)
    ball_v_y_init : INTEGER := 15--x inverse speed (updates / pixel moved)
  );
  port(
    --this should run for one clock cycle every
    clock, a_resetl, resetl, enable: in STD_LOGIC; -- async/sync active low reset, active high enable
    ball_update : out STD_LOGIC := '0';
    ball_pos_x : out STD_LOGIC_VECTOR(5 downto 0);
    ball_pos_y : out STD_LOGIC_VECTOR(4 downto 0);
    ball_dir_x : in STD_LOGIC; 
    ball_dir_y : in  STD_LOGIC
  );
end  entity BALL_CONTROLLER;

-------------------------------Architecture
architecture rtl of BALL_CONTROLLER is
  --signal ball_pos_x_tmp, ball_pos_y_tmp : STD_LOGIC_VECTOR(9 downto 0);
  signal ball_pos_x_reg : STD_LOGIC_VECTOR(5 downto 0) := ( 2 =>'1', 0=>'1', others=>'0'); --janky way to say 5
  signal ball_pos_y_reg : STD_LOGIC_VECTOR(4 downto 0) := ( 2 =>'1', 0=>'1', others=>'0');
  signal ball_v_x_cnt, ball_v_y_cnt : INTEGER := 0; -- counts up to calculate velocity
  signal ball_v_x: INTEGER := ball_v_x_init;
  signal ball_v_y : INTEGER := ball_v_y_init; -- velocity top counter

  --signal trig_ball_update : STD_LOGIC; --_TODO
begin

  --continuous output assignment
  ball_pos_x <= ball_pos_x_reg;
  ball_pos_y <= ball_pos_y_reg;

  update_pos : process (clock, a_resetl, enable)
  begin
    if a_resetl = '0' then
      
      --async won't work because vhdl won't synthesize a register for these vairables then
      --TODO

      --ball_pos_x_reg <= std_logic_vector(to_unsigned(ball_r_x, ball_pos_x_reg'length)); -- this is more obnoxious than C typecasts
      --ball_pos_y_reg <= std_logic_vector(to_unsigned(ball_r_y, ball_pos_y_reg'length));
      --ball_x_dir_reg <= '1';
      --ball_y_dir_reg <= '1';
      --ball_v_x <= ball_v_x_init;
      --ball_v_y <= ball_v_y_init;
      --ball_v_x_cnt <= 0;
      --ball_v_y_cnt <= 0;
    end if;

    if rising_edge(clock) and enable = '1' then
      ball_update <= '0';
      if resetl = '0' then
        ball_pos_x_reg <= std_logic_vector(to_unsigned(ball_r_x, ball_pos_x_reg'length)); -- this is more obnoxious than C typecasts
        ball_pos_y_reg <= std_logic_vector(to_unsigned(ball_r_y, ball_pos_y_reg'length));
        ball_v_x <= ball_v_x_init;
        ball_v_y <= ball_v_y_init;
        ball_v_x_cnt <= 0;
        ball_v_y_cnt <= 0;
      end if;
      ball_v_x_cnt <= ball_v_x_cnt + 1;
      ball_v_y_cnt <= ball_v_y_cnt + 1;

      --move ball position
      if ball_v_x_cnt >= ball_v_x - 1 then
         ball_update <= '1';
        ball_v_x_cnt <= 0;
        if ball_dir_x = '1' then
          ball_pos_x_reg <= std_logic_vector(unsigned(ball_pos_x_reg) + 1);
        else
          ball_pos_x_reg <= std_logic_vector(unsigned(ball_pos_x_reg) - 1); -- should be -1
        end if;
      end if;
      
      if ball_v_y_cnt >= ball_v_y - 1 then
      ball_update <= '1';
        ball_v_y_cnt <= 0;
        if ball_dir_y = '1' then
          ball_pos_y_reg <= std_logic_vector(unsigned(ball_pos_y_reg) + 1);
        else
          ball_pos_y_reg <= std_logic_vector(unsigned(ball_pos_y_reg) - 1);
        end if;
      end if;
    end if;
  end process update_pos;

end architecture rtl;