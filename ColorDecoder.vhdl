-- Convert number from RAM to a VGA output


--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


----- VGA_Coutner
entity COLOR_DECODER is 

  port (
  code_input: in STD_LOGIC_VECTOR(1 downto 0);
  r_out, b_out, g_out: out STD_LOGIC_VECTOR(3 downto 0)
);
end entity COLOR_DECODER;

architecture behav of COLOR_DECODER is
begin

  decode : process(code_input)
    constant SIG_OFF : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant SIG_ON  : STD_LOGIC_VECTOR(3 downto 0) := "1111";
  begin
    r_out <= SIG_OFF;
    b_out <= SIG_OFF;
    g_out <= SIG_OFF;

    if code_input = "00" then
      -- nothing, all signals off
      r_out <= "0010";
      b_out <= "0010";
      g_out <= "0010";
    elsif code_input = "01" then
      r_out <= SIG_ON;
    elsif code_input = "10" then
      b_out <= SIG_ON;
    else -- code_input = "11"
      r_out <= SIG_ON;
      b_out <= SIG_ON;
      g_out <= SIG_ON;
    end if;
  end process decode;

end architecture behav;