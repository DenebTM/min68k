library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn74193_tb is
end sn74193_tb;

architecture behave of sn74193_tb is

  -- constant c_CLOCK_PERIOD : time := 125 ns;
  constant c_CLOCK_PERIOD : time := 125 us;
  constant c_NO_DATA : std_Logic_vector(3 downto 0) := "ZZZZ";
  constant c_INIT_DATA : std_logic_vector(3 downto 0) := "1000";

  signal r_CLOCK  : std_logic := '0';

  -- 74193 inputs
  signal r_CLEAR  : std_logic := '0'; -- active-high
  signal r_LOAD   : std_logic := '1'; -- active-low
  signal r_VALIN  : std_logic_vector(3 downto 0) := c_NO_DATA;

  -- 74193 clocked inputs
  signal r_CNTU   : std_logic := '0';
  signal r_CNTD   : std_logic := '0';
  signal r_CNTU_S : std_logic := '0';
  signal r_CNTD_S : std_logic := '0';

  -- 74193 clocked input conditions
  signal r_DOCNTU : std_logic := '0';
  signal r_DOCNTD : std_logic := '0';

  -- 74193 outputs
  signal r_CARRY  : std_logic;
  signal r_BORROW : std_logic;
  signal r_VALOUT : std_logic_vector(3 downto 0);

  component sn74193 is
    port (
      i_up      : in  std_logic;
      i_down    : in  std_logic;
      i_clear   : in  std_logic;
      i_load    : in  std_logic;
      o_carry   : out std_logic;
      o_borrow  : out std_logic;
      i_value   : in  std_logic_vector(3 downto 0);
      o_value   : out std_logic_vector(3 downto 0)
    );
  end component sn74193;

begin

  UUT : sn74193
    port map (
      i_up      => r_CNTU,
      i_down    => r_CNTD,
      i_clear   => r_CLEAR,
      i_load    => r_LOAD,
      o_carry   => r_CARRY,
      o_borrow  => r_BORROW,
      i_value   => r_VALIN,
      o_value   => r_VALOUT
    );

    -- clock generator
    p_CLK_GEN : process is
    begin
      wait for c_CLOCK_PERIOD/2;
      r_CLOCK <= not r_CLOCK;
    end process p_CLK_GEN;

    -- attach clock to CNTU, CNTD, both, or neither
    r_CNTU <= r_CLOCK when r_DOCNTU = '1' else r_CNTU_S;
    r_CNTD <= r_CLOCK when r_DOCNTD = '1' else r_CNTD_S;

    -- test process
    process
    begin
      wait for 5 ms;

      -- clear
      r_CLEAR <= '1';
      wait for 1 ms;
      r_CLEAR <= '0';
      wait for 4 ms;

      -- load data
      r_LOAD <= '0';
      r_VALIN <= c_INIT_DATA;
      wait for 1 ms;
      r_LOAD <= '1';
      r_VALIN <= c_NO_DATA;
      wait for 10 ms;

      -- count up
      r_CNTD_S <= '1';
      r_DOCNTU <= '1';
      wait for 10 ms;

      -- hold
      r_CNTD_S <= '0';
      wait for 10 ms;

      -- remove clock
      r_DOCNTU <= '0';
      wait for 10 ms;

      -- count down
      r_CNTU_S <= '1';
      r_DOCNTD <= '1';
      wait for 10 ms;

      -- hold
      r_CNTU_S <= '0';
      wait for 10 ms;

      -- remove clock
      r_DOCNTD <= '0';
      wait for 10 ms;

    end process;

end behave;
