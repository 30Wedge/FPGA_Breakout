-- Define the (very specific) RAM used by the breakout controller.
-- Can be read by the VGA timer, and also read/written by the controller.
-- output to screen too

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BREAKOUT_RAM is 
  port (
      clk: in STD_LOGIC;
      vga_address: in STD_LOGIC_VECTOR(10 downto 0);
      vga_out: out STD_LOGIC_VECTOR(1 downto 0)
      -- TODO, controller address, 
      -- controller out, 
      -- controller-in-data, 
      -- controller-write-enable
    );
end entity BREAKOUT_RAM;

architecture behav of BREAKOUT_RAM is
  type MEMORY is array (2047 downto 0) of STD_LOGIC_VECTOR(1 downto 0);
  signal vga_content: MEMORY;
begin
  vga_read : process(clk)
  begin
    if (rising_edge(clk)) then
      vga_out <= vga_content(to_integer(unsigned(vga_address)));
    end if;
  end process vga_read;

  -- todo controller process
  --
  -- 

end architecture behav;