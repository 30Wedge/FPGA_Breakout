--  controller arbiter ball update test bench
-- why wont it erase the old ball position?
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

----(test_bench right now)
entity Arbiter_TB is 
end entity Arbiter_TB;

architecture behavior of Arbiter_TB is

--inputs
  signal tb_clock : STD_LOGIC := '0';
  signal tb_reset : STD_LOGIC := '0';

  signal tb_paddle_update : STD_LOGIC := '0';
  signal tb_paddle_leftedge_x: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');

  signal tb_ball_pos_x : STD_LOGIC_VECTOR(5 downto 0) := "000100";
  signal tb_ball_pos_y : STD_LOGIC_VECTOR(4 downto 0) := "00100";
  signal tb_ball_dir_x : STD_LOGIC;
  signal tb_ball_dir_y : STD_LOGIC;
  signal tb_ball_update : STD_LOGIC;

--outputs  
  signal tb_mem_address  : STD_LOGIC_VECTOR(10 downto 0);
  signal tb_mem_data_in  : STD_LOGIC_VECTOR(1 downto 0);
  signal tb_mem_wren     : STD_LOGIC  := '0';
  signal tb_mem_data_out : STD_LOGIC_VECTOR (1 DOWNTO 0);
--clock period
  constant tb_clock_period : time := 40 ns; --25MHz input clock
begin


  -- Instantiate the Unit Under Test (UUT)
    --coordinate the two controllers
  arbiter : entity WORK.Controller_arbiter
  port map(
    clock => tb_clock,
    aresetl => tb_reset,
    resetl => '1', --TODO need to switch to synch reset
    enable => '1' , --TODO is there a better way to conditionally enable this?
    paddle_update => tb_paddle_update,
    paddle_leftedge_x => tb_paddle_leftedge_x,
    ball_pos_x => tb_ball_pos_x,
    ball_pos_y => tb_ball_pos_y,
    ball_dir_x => tb_ball_dir_x,
    ball_dir_y => tb_ball_dir_y,
    ball_update => tb_ball_update,
    mem_address => tb_mem_address,
    mem_data_in => tb_mem_data_in,
    mem_wren => tb_mem_wren,
    mem_data_out => tb_mem_data_out
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
    tb_ball_dir_x <= '1';
    tb_ball_dir_y <= '1';
    -- hold reset state for 100us.
    tb_reset <= '0';
    wait for tb_clock_period*10;
    tb_reset <= '1';
    wait for tb_clock_period*30; --udate pos
    tb_mem_data_out <= "01"; --say there's a brick coming up

    tb_ball_pos_x <= "000101";
    tb_ball_pos_y <= "00101";
    tb_ball_update <= '1';
    wait for tb_clock_period;
    tb_ball_update <= '0';
    wait for tb_clock_period*30; --again again
    tb_ball_pos_x <= "000110";
    tb_ball_pos_y <= "00110";
    tb_ball_update <= '1';
    wait for tb_clock_period;
    tb_ball_update <= '0';
    wait for tb_clock_period*100;
  end process;
end architecture behavior;