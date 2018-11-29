--  VHDL module to control the paddle
-- keeps track of the paddle's position,
-- outputs the paddle's position
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

------------------------------sync_counter
entity Paddle_Controller is
  generic(
    paddle_length : UNSIGNED; --total cycles
    paddle_y : UNSIGNED; -- starting y coordinate
    paddle_min_x : UNSIGNED; --how far left you can go
    paddle_max_x : UNSIGNED -- farthest right open space
  );
  port(
    clock, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable
    buttons: in STD_LOGIC_VECTOR(1 downto 0); -- 1 = R, 0 = L
    ball_pos_x_next, ball_pos_y_next : in  STD_LOGIC_VECTOR(9 downto 0); --todo remove
    paddle_leftedge_x : out STD_LOGIC_VECTOR(9 downto 0);
    ball_bounce : out STD_LOGIC --TODO remove
  );
end  entity Paddle_Controller;

-------------------------------Architecture
architecture rtl of Paddle_Controller is
  signal paddle_leftedge_reg : STD_LOGIC_VECTOR(9 downto 0);
  signal last_button_reg : STD_LOGIC_VECTOR(1 downto 0);
begin

  -- sequential button press, reset logic
  seq : process (clock, resetl, enable)
    variable temp_paddle_update : STD_LOGIC := '0';
  begin
    if resetl = '0' then
      paddle_leftedge_reg <= std_logic_vector(paddle_min_x);
      last_button_reg <= "00";
    end if; -- reset

    if rising_edge(clock) then
      temp_paddle_update := '0';
      if enable = '1' then
        if last_button_reg(0) = '1' and buttons(0) = '0' then
          --move right if you can
          if unsigned(paddle_leftedge_reg) > paddle_min_x then
            paddle_leftedge_reg <=  std_logic_vector(unsigned(paddle_leftedge_reg) - 1);
            temp_paddle_update :='1';
          end if;
        elsif last_button_reg(1) = '1' and buttons(1) = '0' then
          -- move left if you can
          if (unsigned(paddle_leftedge_reg) + paddle_length) < paddle_max_x then
            paddle_leftedge_reg <=  std_logic_vector(unsigned(paddle_leftedge_reg) + 1);
            temp_paddle_update := '1';
          end if;
        end if; -- button edge

          --update last state
      last_button_reg <= buttons;
      end if; -- enable 


      --update last state
      last_button_reg <= buttons;
    end if; --risingedge clock
  end process seq;

 -- combinational bounce detection
  bounces : process (ball_pos_x_next, ball_pos_y_next)
    variable temp_out : STD_LOGIC := '0';
  begin
    temp_out := '0';
    if unsigned(ball_pos_y_next) = paddle_y then
      if unsigned(ball_pos_x_next) > unsigned(paddle_leftedge_reg) and unsigned(ball_pos_x_next) < (unsigned(paddle_leftedge_reg) + paddle_length) then
        temp_out := '1';
      end if;
    end if;
    ball_bounce <= temp_out;
  end process bounces;
  
end architecture rtl;