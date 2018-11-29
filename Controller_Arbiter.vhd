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
--use IEEE.std_logic_unsigned.all; -- including this library breaks assigning input std_logic_vectors to signals. I don't know why

------------------------------sync_counter
entity Controller_arbiter is
  generic(
    PADDLE_Y : INTEGER := 5; --TODO this is also ahrdcoded
    PADDLE_LEN : INTEGER := 3 --must be 3 because I hardcoded it :(
    );
  port(
    clock, aresetl, resetl, enable: in STD_LOGIC; -- async active low reset, active high enable

    paddle_update : in STD_LOGIC;
    paddle_leftedge_x : in STD_LOGIC_VECTOR(5 downto 0);

    ball_pos_x : in STD_LOGIC_VECTOR(5 downto 0);
    ball_pos_y : in STD_LOGIC_VECTOR(4 downto 0);
    ball_dir_x : out STD_LOGIC;
    ball_dir_y : out  STD_LOGIC;
    ball_update : in STD_LOGIC;

    --memory iface
    mem_address : out STD_LOGIC_VECTOR(10 downto 0);
    mem_data_in  : out STD_LOGIC_VECTOR(1 downto 0);
    mem_wren    : out STD_LOGIC  := '0';
    mem_data_out   : in STD_LOGIC_VECTOR (1 DOWNTO 0)
  );
end  entity Controller_arbiter;

-------------------------------Architecture
architecture rtl of Controller_arbiter is
  type state_action is (init_wait, draw_paddle, draw_ball, wait_for_changes, check_for_ball_bounce);
  signal present_state : state_action := init_wait;
  signal next_state : state_action := init_wait;

  --are these good practice? maybe
  signal state_counter : INTEGER := 0;

  signal old_ball_pos_x_reg : STD_LOGIC_VECTOR(5 downto 0) := "000000";
  signal old_ball_pos_y_reg : STD_LOGIC_VECTOR(4 downto 0) := "00000";

  signal old_paddle_left_x_reg : STD_LOGIC_VECTOR(5 downto 0) := "000000";

  signal ball_bounce_results : STD_LOGIC_VECTOR(2 downto 0) := "000"; --0 => brick present to x+, 1=> brick present to y+, 2, brick present to x+,y+
  signal ball_dir_x_reg : STD_LOGIC := '1';
  signal ball_dir_y_reg : STD_LOGIC := '1';
  --how long it takes to work in each state
  constant INIT_WAIT_LEN : INTEGER := 5;
  constant DRAW_BALL_LEN : INTEGER := 5;
  constant DRAW_PADDLE_LEN : INTEGER := 13;
  constant CHECK_BOUNCE_LEN : INTEGER := 20;
  constant WAIT_FOR_CHANGES_LEN : INTEGER := 3;
begin --TODO draw paddle update before ball
  
  ball_dir_x <= ball_dir_x_reg;
  ball_dir_y <= ball_dir_y_reg;

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
    variable PADDLE_Y_SL : STD_LOGIC_VECTOR(4 downto 0) := "00101"; --cheating
  begin
    if rising_edge(clock) and enable = '1' then
      state_counter <= state_counter + 1;
      case present_state is

        when init_wait => -----------------------------------------------------------------
          --next_state <= init_wait;
          -- I'm milling to let the ball controller do its thing? I don't know if it needs this time, but I'm giving it plenty just in case because I don't want to debug it later

          if state_counter >= INIT_WAIT_LEN then
            state_counter <= 0;
            next_state <= draw_ball;
          end if;

        when draw_paddle => -----------------------------------------------------------------
          --next_state <= draw_ball;

          case state_counter is
            when 1 => -- draw black space
              if unsigned(old_paddle_left_x_reg) < unsigned(paddle_leftedge_x) then
                mem_wren <='1';
                mem_data_in <= "00"; -- background pixel
                mem_address <= PADDLE_Y_SL & old_paddle_left_x_reg;
              elsif unsigned(old_paddle_left_x_reg) > unsigned(paddle_leftedge_x) then
                mem_wren <='1';
                mem_data_in <= "00"; -- background pixel
                mem_address <= PADDLE_Y_SL & std_logic_vector(unsigned(old_paddle_left_x_reg) + PADDLE_LEN + 1);
              else
                --no update?
                mem_wren <= '0';
              end if;
            when 4 => -- draw paddle 1
              mem_address <= PADDLE_Y_SL & std_logic_vector(unsigned(paddle_leftedge_x) + 1);
              mem_data_in <= "11"; -- strong
              mem_wren <= '1';
            when 7 => --draw paddle 2
              mem_address <= PADDLE_Y_SL & std_logic_vector(unsigned(paddle_leftedge_x) + 2);
              mem_data_in <= "11"; -- strong
              mem_wren <= '1';
            when 11 => --draw paddle 3
              mem_address <= PADDLE_Y_SL & std_logic_vector(unsigned(paddle_leftedge_x) + 3);
              mem_data_in <= "11"; -- strong
              mem_wren <= '1';
            when 13 => --register updated ball position
              old_paddle_left_x_reg <= paddle_leftedge_x;
              mem_wren <= '0';
            when others => --disable memory write
              mem_address <= "00000000000";
              mem_wren <= '0';
          end case;

          if state_counter >= DRAW_PADDLE_LEN then
            state_counter <= 0;
            next_state <= init_wait;
          end if;

        when draw_ball => -----------------------------------------------------------------
          --next_state <= draw_ball;

          case state_counter is
            when 3 => -- draw new ball
              mem_address <= ball_pos_y & ball_pos_x;
              mem_data_in <= "10"; -- ball pixel
              mem_wren <= '1';
            when 1 => -- draw erased old ball 
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
            next_state <= check_for_ball_bounce;
          end if;

        when check_for_ball_bounce => -----------------------------------------------------------------
        --load next x pos, next y pos, next xy pos
          case state_counter is

            when 1=> --check results(0) , x +1
              ball_bounce_results <= "000";

              if ball_dir_x_reg = '1' then
                mem_address <= ball_pos_y & std_logic_vector(unsigned(ball_pos_x) + 1);
              else 
                mem_address <= ball_pos_y & std_logic_vector(unsigned(ball_pos_x) - 1);
              end if;
              mem_wren <= '0';

            -- it takes 3 cycles to do a memory access/update
            when 4=> --update results(0), erase brick if its there
              mem_data_in <= "00";
              if mem_data_out /= "00" then
                ball_bounce_results(0) <= '1';
                if mem_data_out = "01" then --if there's a brick, DESTROY
                  mem_wren <= '1';
                end if;
              end if;

            when 7=> -- check results(1) , y + 1
              mem_wren <= '0';
              if ball_dir_y_reg = '1' then
                mem_address <= std_logic_vector(unsigned(ball_pos_y) + 1) & ball_pos_x;
              else 
                mem_address <= std_logic_vector(unsigned(ball_pos_y) - 1) & ball_pos_x;
              end if;

            when 10=> -- update result(0)
              mem_data_in <= "00";
              if mem_data_out /= "00" then
                ball_bounce_results(1) <= '1';
                if mem_data_out = "01" then --if there's a brick, DESTROY
                  mem_wren <= '1';
                end if;
              end if;

            when 13=> -- check reuslts (2), x+ 1, y + 1
              mem_wren <= '0';
              if ball_dir_x_reg = '1' and ball_dir_y_reg = '1' then
                mem_address <= std_logic_vector(unsigned(ball_pos_y) + 1) & std_logic_vector(unsigned(ball_pos_x) + 1);
              elsif ball_dir_x_reg = '1' and ball_dir_y_reg = '0' then
                mem_address <= std_logic_vector(unsigned(ball_pos_y) - 1) & std_logic_vector(unsigned(ball_pos_x) + 1);
              elsif ball_dir_x_reg = '0' and ball_dir_y_reg = '1' then
                mem_address <= std_logic_vector(unsigned(ball_pos_y) + 1) & std_logic_vector(unsigned(ball_pos_x) - 1);
              elsif ball_dir_x_reg = '0' and ball_dir_y_reg = '0' then
                mem_address <= std_logic_vector(unsigned(ball_pos_y) - 1) & std_logic_vector(unsigned(ball_pos_x) - 1);
              end if;

            when 16=> --update results (2)
              mem_data_in <= "00";
              if mem_data_out /= "00" then
                ball_bounce_results(2) <= '1';
                if mem_data_out = "01" then --if there's a brick, DESTROY
                  mem_wren <= '1';
                end if;
              end if;

            when 19=> -- decide how it bounced
              case ball_bounce_results is
                when "100" =>
                  ball_dir_x_reg <= not ball_dir_x_reg;
                  ball_dir_y_reg <= not ball_dir_y_reg;
                when "111" =>
                  ball_dir_x_reg <= not ball_dir_x_reg;
                  ball_dir_y_reg <= not ball_dir_y_reg;
                when "011" =>
                  ball_dir_x_reg <= not ball_dir_x_reg;
                  ball_dir_y_reg <= not ball_dir_y_reg;
                when "110" =>
                  ball_dir_y_reg <= not ball_dir_y_reg;
                when "010" =>
                  ball_dir_y_reg <= not ball_dir_y_reg;
                when "101" =>
                  ball_dir_x_reg <= not ball_dir_x_reg;
                when "001" =>
                  ball_dir_x_reg <= not ball_dir_x_reg;
                when others =>
                  -- no dir change
              end case;

            when others =>
          end case;
          
          if state_counter >= CHECK_BOUNCE_LEN then
            state_counter <= 0;
            next_state <= wait_for_changes;
          end if;

        when wait_for_changes =>  -----------------------------------------------------------------
          ---next_state <= wait_for_changes;

          --just check for next state every time?
          state_counter <= 0;
          next_state <= draw_paddle;
          --check for paddle update fi
          --if paddle_update = '1' then
          --  state_counter <= 0;
          --  next_state <= draw_paddle;
          --elsif ball_update ='1' then
          --  --have to reset bounce outputs
          --  --ball_gonna_bounce_x_reg <= '0';
          --  --ball_gonna_bounce_y_reg <= '0';
          --  state_counter <= 0;
          --  next_state <= init_wait;
          --end if;
      end case;
    end if;
  end process ns_output;

end architecture rtl;