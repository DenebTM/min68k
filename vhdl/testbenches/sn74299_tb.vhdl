library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn74299_tb is
end sn74299_tb;

architecture behave of sn74299_tb is

  -- constant c_CLOCK_PERIOD : time := 125 ns;
  constant c_CLOCK_PERIOD : time := 125 us;
  constant c_NO_DATA : std_Logic_vector(7 downto 0) := "ZZZZZZZZ";
  constant c_INIT_DATA : std_logic_vector(7 downto 0) := "10101010";

  signal r_CYCLE : natural := 0;
  signal r_CLOCK : std_logic := '0';

  signal r_FUNCSEL  : std_logic_vector(1 downto 0) := "00";
  signal r_OUT_EN   : std_logic := '1';
  signal r_CLEAR    : std_logic := '1';
  signal r_SL       : std_logic := '1';
  signal r_SR       : std_logic := '1';
  signal r_DATA     : std_logic_vector(7 downto 0) := c_NO_DATA;

  signal r_qAp      : std_logic;
  signal r_qHp      : std_logic;

  component sn74299 is
    port (
      i_clock : in    std_logic;
      i_s0    : in    std_logic;
      i_s1    : in    std_logic;
      i_g1    : in    std_logic;
      i_g2    : in    std_logic;
      i_clear : in    std_logic;
      i_sl    : in    std_logic;
      i_sr    : in    std_logic;
      o_qA    : out   std_logic;
      o_qH    : out   std_logic;
      io_data : inout std_logic_vector(7 downto 0)
    );
  end component sn74299;

begin

  UUT : sn74299
    port map (
      i_clock => r_CLOCK,
      i_s0 => r_FUNCSEL(1),
      i_s1 => r_FUNCSEL(0),
      i_g1 => r_OUT_EN,
      i_g2 => r_OUT_EN,
      i_clear => r_CLEAR,
      i_sl => r_SL,
      i_sr => r_SR,
      o_qA => r_qAp,
      o_qH => r_qHp,
      io_data => r_DATA
    );

    -- clock generator
    p_CLK_GEN : process is
    begin
      wait for c_CLOCK_PERIOD/2;
      r_CLOCK <= not r_CLOCK;
    end process p_CLK_GEN;

    -- test process
    process
    begin
      wait for 5 ms;

      -- clear
      r_FUNCSEL <= "00";
      r_CLEAR <= '0';
      wait for 1 ms;
      r_CLEAR <= '1';
      wait for 4 ms;

      -- load data
      r_FUNCSEL <= "11";
      r_DATA <= c_INIT_DATA;
      wait for 1 ms;
      r_DATA <= c_NO_DATA;

      -- shift ones in from right
      r_FUNCSEL <= "01";
      r_SL <= '1';
      wait for 10 ms;

      -- output data
      r_FUNCSEL <= "00";
      r_DATA <= c_NO_DATA;
      r_OUT_EN <= '0';
      wait for 10 ms;
      r_OUT_EN <= '1';

      -- load data
      r_FUNCSEL <= "11";
      r_DATA <= c_INIT_DATA;
      wait for 1 ms;
      r_DATA <= c_NO_DATA;

      -- shift zeroes in from right
      r_FUNCSEL <= "01";
      r_SL <= '0';
      wait for 10 ms;

      -- output data
      r_FUNCSEL <= "11";
      r_DATA <= c_NO_DATA;
      r_OUT_EN <= '0';
      wait for 20 ms;
      r_OUT_EN <= '1';


      -- load data
      r_FUNCSEL <= "11";
      r_DATA <= c_INIT_DATA;
      wait for 1 ms;
      r_DATA <= c_NO_DATA;

      -- shift ones in from left
      r_FUNCSEL <= "10";
      r_SR <= '1';
      wait for 10 ms;

      -- output data
      r_FUNCSEL <= "00";
      r_OUT_EN <= '0';
      wait for 10 ms;
      r_OUT_EN <= '1';

      -- load data
      r_FUNCSEL <= "11";
      r_DATA <= c_INIT_DATA;
      wait for 1 ms;
      r_DATA <= c_NO_DATA;

      -- shift zeroes in from left
      r_FUNCSEL <= "10";
      r_SR <= '0';
      wait for 10 ms;

      -- output data
      r_FUNCSEL <= "11";
      r_OUT_EN <= '0';
      wait for 10 ms;
      r_OUT_EN <= '1';

    end process;

end behave;
