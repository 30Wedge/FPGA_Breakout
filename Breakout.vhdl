--  The very top level design
--
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

---- Breakout
entity Breakout is 
-- todo what?
end entity Breakout;

-- Declare sync_coutner architecture. TODO import this from a library
architecture rtl of Breakout is
  signal clk : STD_LOGIC;
  signal reset : STD_LOGIC;
  signal vsync: STD_LOGIC;
  signal hsync : STD_LOGIC;
begin 