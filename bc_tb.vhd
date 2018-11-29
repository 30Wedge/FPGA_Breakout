--  controller arbiter ball update test bench
-- why wont it erase the old ball position?
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

----(test_bench right now)
entity bc_TB is 
end entity bc_TB;

architecture behavior of bc_TB is

    signal tb_clock : STD_LOGIC;
    signal tb_a_resetl : STD_LOGIC;
    signal tb_resetl : STD_LOGIC;
    signal tb_enable : STD_LOGIC;
    signal tb_ball_update : STD_LOGIC;
    signal tb_ball_pos_x : STD_LOGIC_VECTOR(5 downto 0);
    signal tb_ball_pos_y : STD_LOGIC_VECTOR(4 downto 0);
    signal tb_ball_dir_x : STD_LOGIC;
    signal tb_ball_dir_y : STD_LOGIC;
--clock period
  constant tb_clock_period : time := 16 ns; --60MHz input clock (act like its 60Hz)
begin


  -- Instantiate the Unit Under Test (UUT)
    --coordinate the two controllers
  ball : entity WORK.BALL_CONTROLLER
  generic map(
    ball_r_x => 10,
    ball_r_y => 10
  )
  port map(
    --this should run for one clock cycle every
    clock => tb_clock, 
    a_resetl => tb_a_resetl, 
    resetl => tb_resetl, 
    enable => '1',
    ball_update => tb_ball_update,
    ball_pos_x => tb_ball_pos_x,
    ball_pos_y => tb_ball_pos_y,
    ball_dir_x => tb_ball_dir_x,
    ball_dir_y  => tb_ball_dir_y
  );

  -- start clock process
  counter_tb_process : process
  begin
     tb_clock <= '0';
     wait for (tb_clock_period / 2);
     tb_clock <= '1';
     wait for (tb_clock_period / 2);
  end process counter_tb_process;

   -- Stimulus process
  stim_proc : process
  begin
    -- hold reset state for 100us.
    tb_resetl <= '1';
    tb_ball_dir_x <= '1';
    tb_ball_dir_y <= '1';

    wait for tb_clock_period*60; --udate pos
    tb_ball_dir_x <= '0';
    wait for tb_clock_period*90;
    tb_ball_dir_y <= '0';
    wait for tb_clock_period * 60;
    tb_ball_dir_x <= '0';
    wait for tb_clock_period * 60;
  end process;
end architecture behavior;