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
  LEDR : out STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); -- just diagnostics to keep me sane
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
  signal areset_L : STD_LOGIC;
  signal clk : STD_LOGIC; --26.5MHz clock

  signal update_enable : STD_LOGIC;
  --ball specific
  signal temp_ball_pos_x : STD_LOGIC_VECTOR(5 downto 0);
  signal temp_ball_pos_y : STD_LOGIC_VECTOR(4 downto 0);
  signal temp_ball_dir_x : STD_LOGIC;
  signal temp_ball_dir_y : STD_LOGIC;
  signal temp_ball_gonna_bounce_x : STD_LOGIC;
  signal temp_ball_gonna_bounce_y : STD_LOGIC;
  --controller signals
  signal controller_addr : STD_LOGIC_VECTOR(10 downto 0);
  signal controller_w_data : STD_LOGIC_VECTOR(1 downto 0);
  signal controller_wren : STD_LOGIC;
  signal controller_r_data :STD_LOGIC_VECTOR(1 downto 0);
  signal memory_out : STD_LOGIC_VECTOR(1 downto 0);
  signal ball_update : STD_LOGIC;
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
  areset_L <= SW(0);
  LEDR(0) <= not SW(0); --led on == no resetski
  LEDR(7) <= not SW(0); -- just to make sure its me programming it

-- its a 40 wide x 30 tall screen in memory
--  new row every 64 address spaces
--
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
    reset => areset_L,
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
    reset => areset_L,
    enable => v_enable,
    sync => VGA_VS,
    enable_out => update_enable,
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
    address_b  => controller_addr,
    clock  => clk,
    data_a   => "00", --no write 
    data_b   => controller_w_data,
    wren_a   => '0',
    wren_b   => controller_wren,
    q_a  => color_code,
    q_b  => controller_r_data
  );

  -- decode the ram for VGA color output
  decoder : entity WORK.COLOR_DECODER
  port map (
    code_input => color_code,
    r_out => VGA_R,
    b_out => VGA_B,
    g_out => VGA_G
    );

  --move the ball
  ball_updater : entity WORK.BALL_CONTROLLER
  generic map (
    ball_r_x => 10, -- reset coordinates
    ball_r_y => 10, -- reset coordinates
    ball_v_x_init => 30, --x inverse speed (updates / pixel)
    ball_v_y_init => 30 --x inverse speed (updates / pixel)
  )
  port map(
    clock => update_enable, --not clock.Surprise. The enable signal was going for too long TODO will this cause problems?
    a_resetl => areset_L,
    resetl => '1',  -- TODO, will I ever sync reset? probably not
    enable => '1',
    ball_will_bounce_x => temp_ball_gonna_bounce_x,
    ball_will_bounce_y => temp_ball_gonna_bounce_y,
    --outputs
    ball_update => ball_update,
    ball_pos_x => temp_ball_pos_x,
    ball_pos_y => temp_ball_pos_y,
    ball_dir_x => temp_ball_dir_x,
    ball_dir_y => temp_ball_dir_y
  );

  --coordinate the two controllers
  arbiter : entity WORK.Controller_arbiter
  port map(
    clock => clk,
    aresetl => areset_L,
    resetl => '1', --TODO need to switch to synch reset
    enable => '1' , --TODO is there a better way to conditionally enable this?
    ball_pos_x => temp_ball_pos_x,
    ball_pos_y => temp_ball_pos_y,
    ball_dir_x => temp_ball_dir_x,
    ball_dir_y => temp_ball_dir_y,
    ball_update => ball_update,

    --outputs
    ball_gonna_bounce_x => temp_ball_gonna_bounce_x,
    ball_gonna_bounce_y => temp_ball_gonna_bounce_y,
    mem_address => controller_addr,
    mem_data_in => controller_w_data,
    mem_wren => controller_wren,
    mem_data_out => controller_r_data
  );

end architecture  rtl;