--  VHDL module for a generic sync counter
--  Used as hsync and vsync timers in the Breakout Project
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; -- allows increment/decrement to STD_LOGIC_VECTOR

------------------------------sync_counter
entity SYNC_COUNTER is
  generic(
    total_length : INTEGER; --total cycles
    data_length : INTEGER; -- how long to output data
    sync_start : INTEGER;
    sync_end : INTEGER
  );
  port(clock, reset, enable: in STD_LOGIC;
    sync, enable_out: out STD_LOGIC;
    addr: out STD_LOGIC_VECTOR(9 downto 0) --todo this needs to drop down lower
  );
end  entity SYNC_COUNTER;

-------------------------------Architecture
architecture rtl of SYNC_COUNTER is
  signal count : STD_LOGIC_VECTOR(9 downto 0);
begin

  process (clock, reset, enable) 
  begin
  if reset = '0' then 
    count <= "0000000000";
    enable_out <= '0';
    addr <= "0000000000";
    sync <= '1';
  elsif rising_edge(clock) then
    if enable = '1' then

      count <= count + 1;

      -- wraparound & enable next stage
      if count = total_length - 1 then
        count <= "0000000000";
        enable_out <= '1';
      else 
        enable_out <= '0';
      end if;

      -- output a data address only when video data is expected 
      if count < data_length then
        addr <= count;
      else
        addr <= "0000000000"; --garbage data written off screen
      end if;

      --sync pulse
      if (count >= sync_start) and (count <  sync_end) then
        sync <= '0';
      else
        sync <= '1';
      end if;

    end if;
  end if; 
  end process;
end architecture rtl;