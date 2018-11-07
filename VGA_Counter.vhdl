--  VHDL module to drive the VGA address generator
--    Combine vsync and hsync in the breakout project
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

----- VGA_Coutner
entity VGA_COUNTER is 

  port (
  clock, reset: in STD_LOGIC;
  hsync, vsync: out STD_LOGIC
);
end entity VGA_COUNTER;

architecture rtl of VGA_Counter is
  signal temp : STD_LOGIC;
  signal v_addr : STD_LOGIC_VECTOR(7 downto 0);
  signal h_addr : STD_LOGIC_VECTOR(7 downto 0);
begin 
  --hsync counter
  sh : entity WORK.sync_counter
  generic map( 
    length => 800,
    sync_start => 96,
    sync_end => 100
  )
  port map(
    clock => clock,
    reset => reset,
    enable => '1',
    sync => hsync,
    enable_out => temp,
    addr => h_addr
  );

  --vsync counter
  sv : entity WORK.sync_counter
  generic map(
    length => 525,
    sync_start => 16,
    sync_end => 18
  )
  port map(
    clock => clock,
    reset => reset,
    enable => temp,
    sync => vsync,
    enable_out => open,
    addr => v_addr
  );
end architecture  rtl;