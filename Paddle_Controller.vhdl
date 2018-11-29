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
    paddle_length : INTEGER := 3; --total cycles
    paddle_y : INTEGER := 5; -- starting y coordinate
    paddle_min_x : INTEGER; --how far left you can go
    paddle_max_x : INTEGER -- farthest right open space
  );
  port(
    clock, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable
    buttons: in STD_LOGIC_VECTOR(1 downto 0); -- 1 = R, 0 = L
    paddle_leftedge_x : out STD_LOGIC_VECTOR(5 downto 0);
    update_detected : out STD_LOGIC
  );
end  entity Paddle_Controller;

-------------------------------Architecture
architecture rtl of Paddle_Controller is
  signal paddle_leftedge_reg : STD_LOGIC_VECTOR(5 downto 0) := (3=>'1', others=>'0');
  signal last_button_reg : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin

  paddle_leftedge_x <= paddle_leftedge_reg;

  -- sequential button press, reset logic
  seq : process (clock, enable)
  begin
    if rising_edge(clock) then
    if resetl = '0' then
      paddle_leftedge_reg <= std_logic_vector(to_unsigned(paddle_min_x, paddle_leftedge_reg'length));
      last_button_reg <= "00";
    end if; -- reset

      update_detected <= '0';
      if enable = '1' then
        if last_button_reg(0) = '1' and buttons(0) = '0' then
          --move right if you can
          if unsigned(paddle_leftedge_reg) > paddle_min_x then
            paddle_leftedge_reg <=  std_logic_vector(unsigned(paddle_leftedge_reg) - 1);
            update_detected <='1';
          end if;
        elsif last_button_reg(1) = '1' and buttons(1) = '0' then
          -- move left if you can
          if (unsigned(paddle_leftedge_reg) + paddle_length) < paddle_max_x then
            paddle_leftedge_reg <=  std_logic_vector(unsigned(paddle_leftedge_reg) + 1);
            update_detected <= '1';
          end if;
        end if; -- button edge

          --update last state
      last_button_reg <= buttons;
      end if; -- enable 


      --update last state
      last_button_reg <= buttons;
    end if; --risingedge clock
  end process seq;
  
end architecture rtl;