---Andy MacGregor

--the magic words
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

----- VGA_Coutner
entity BREAKOUT is 

  port (
    --these pins match fpga pin names
  MAX10_CLK1_50: in STD_LOGIC;
  SW : in STD_LOGIC_VECTOR(9 downto 0);    -- connected to reset L, push high to run
  LEDR : out STD_LOGIC_VECTOR(9 downto 0); -- just diagnostics to keep me sane
  VGA_HS, VGA_VS: out STD_LOGIC;
  VGA_R, VGA_B, VGA_G: out STD_LOGIC_VECTOR(3 downto 0) -- vga digital color sigs
);
end entity BREAKOUT;

architecture rtl of BREAKOUT is
  signal v_enable : STD_LOGIC;
  signal v_addr : STD_LOGIC_VECTOR(9 downto 0);
  signal h_addr : STD_LOGIC_VECTOR(9 downto 0);
  signal color_code : STD_LOGIC_VECTOR(1 downto 0);
  signal addr : STD_LOGIC_VECTOR(10 downto 0);
  signal reset_L : STD_LOGIC;
  signal clk : STD_LOGIC; --26.5MHz clock
begin 

  --clock divider PLL
  cd : ENTITY WORK.clockPLL
  PORT map 
  (
    areset   => '0',  --Active high async reset
    inclk0   => MAX10_CLK1_50,
    c0    => clk,
    locked  => open
  );

  --map sw0 to reset
  reset_L <= SW(0);
  LEDR(0) <= not SW(0); --led on == no resetski
  LEDR(7) <= not SW(0); -- just to make sure its me programming it

  --hsync counter
  sh : entity WORK.sync_counter
  generic map( 
    total_length => 800,
    data_length => 640,
    sync_start => 656, --640 + 16
    sync_end => 752 --640 + 16 + 96
  )
  port map(
    clock => clk,
    reset => reset_L,
    enable => '1',
    sync => VGA_HS,
    enable_out => v_enable,
    addr => h_addr
  );

  --vsync counter
  sv : entity WORK.sync_counter
  generic map(
    total_length => 525,
    data_length => 480,
    sync_start => 490, --480 + 10
    sync_end => 492 --480 + 10 + 2
  )
  port map(
    clock => clk,
    reset => reset_L,
    enable => v_enable,
    sync => VGA_VS,
    enable_out => open, --TODO route this to the controller enable
    addr => v_addr
  );

  -- form the output address to memory
  -- drop the 4 LSB because we don't need that kind of resolution
  addr <= v_addr(8 downto 4) & h_addr(9 downto 4);


  -- bring in RAM
  -- a side is vga driver
  ram : entity WORK.IP_BreakoutRam
  port map (
    address_a  => addr,
    address_b  => "00000000000", --r/write TODO
    clock  => clk,
    data_a   => "00", --no write 
    data_b   => "00", --todo
    wren_a   => '0',
    wren_b   => '0', --todo this should be non-zero
    q_a  => color_code,
    q_b  => open -- todo
  );

  -- decode the ram
  decoder : entity WORK.COLOR_DECODER
  port map (
    code_input => color_code,
    r_out => VGA_R,
    b_out => VGA_B,
    g_out => VGA_G
    );
end architecture  rtl;