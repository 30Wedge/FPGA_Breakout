--  VHDL module for a generic sync counter
--  Used as hsync and vsync timers in the Breakout Project
---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

------------------------------sync_counter
entity sync_counter is
  generic(
    length : INTEGER;               -- 525 800
    sync_start : INTEGER;
    sync_end : INTEGER
  );
  port(clock, reset, enable: in STD_LOGIC;
    sync, enable_out: out STD_LOGIC ;
    addr: out STD_LOGIC_VECTOR --TODO help what length
  );
end  entity sync_counter;

-------------------------------Architecture
architecture rtl of sync_counter is
  signal count : STD_LOGIC_VECTOR(9 downto 0); -- should always be big enough?
begin

  process (clock, reset) 
  begin
  if reset = '0' then 
    count <= "0";
    enable_out <= '0';
    addr <= "0";
    sync <= '1';
  elsif rising_edge(clock) then
    if enable = '1' then
      count <= count + 1;

      if count = length - 1 then
        count <= "0";
      end if;

      if count = sync_start then
        sync <= '0';
      elsif count = sync_end then
        sync <= '1';
      end if;

      if count <= sync_start then
        addr <= count;
      else
        addr <= "0";
      end if; --TODO am i synthesizing a latch or am I assigning a vector correctly??

    end if;
  end if; 
  end process;
end architecture rtl;