--  Breakout test Bench
--
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

----(test_bench right now)
entity BREAKOUT_TB is 
end entity BREAKOUT_TB;

-- Declare sync_coutner architecture. TODO import this from a library
architecture behavior of BREAKOUT_TB is
-- component of UUT
  component BREAKOUT is 
    port (
      clock, reset: in STD_LOGIC;
      hsync, vsync: out STD_LOGIC;
      addr: out STD_LOGIC_VECTOR(10 downto 0) -- 11b memory address width
    );
  end component;

--inputs
  signal tb_clock : STD_LOGIC := '0';
  signal tb_reset : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
--outputs  
  signal tb_led : STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
  signal tb_vsync: STD_LOGIC;
  signal tb_hsync : STD_LOGIC;
  signal tb_r: STD_LOGIC_VECTOR(3 downto 0); -- 4b color
  signal tb_b: STD_LOGIC_VECTOR(3 downto 0); -- 4b color
  signal tb_g: STD_LOGIC_VECTOR(3 downto 0); -- 4b color
  signal tb_keys : STD_LOGIC_VECTOR(1 downto 0);
--clock period
  constant tb_clock_period : time := 20 ns; --50MHz input clock
begin


  -- Instantiate the Unit Under Test (UUT)
  uut : entity WORK.BREAKOUT 
  port map (
    MAX10_CLK1_50 => tb_clock,
    SW => tb_reset,
    LEDR => tb_led,
    KEY => tb_keys,
    VGA_VS => tb_vsync,
    VGA_HS => tb_hsync,
    VGA_R => tb_r,
    VGA_G => tb_g,
    VGA_B => tb_b
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
    tb_reset <= "0000000000";
    wait for tb_clock_period*10;
    tb_reset <= "1111111111";
    wait for tb_clock_period*10000; --let it fly
    wait;
  end process;
end architecture behavior;