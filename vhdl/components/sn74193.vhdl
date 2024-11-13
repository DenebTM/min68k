library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn74193 is
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
end sn74193;

architecture behave of sn74193 is
  signal r_value  : unsigned(3 downto 0);
  signal r_carry  : std_logic := '1';
  signal r_borrow : std_logic := '1';
begin

  process(i_clear, i_load, i_up, i_down)
  begin
    -- if rising_edge(i_clear) then -- synchronous clear
    if i_clear = '1' then -- asynchronous clear
      r_value <= "0000";

    -- elsif falling_edge(i_load) then -- synchronous load
    elsif i_load = '0' then -- asynchronous load
      r_value <= unsigned(i_value);

    else
      -- counting up
      if (rising_edge(i_up) and i_down = '1') then
        r_value <= r_value + 1;
        r_carry <= '1';
      -- assert carry for half-cycle on overflow
      elsif falling_edge(i_up) then
        if r_value = 15 then
          r_carry <= '0';
        else
          r_carry <= '1';
        end if;
      end if;

      -- counting down
      if (rising_edge(i_down) and i_up = '1') then
        r_value <= r_value - 1;
        r_borrow <= '1';
      -- assert borrow for half-cycle on underflow
      elsif falling_edge(i_down) then
        if r_value = 0 then
          r_borrow <= '0';
        else
          r_borrow <= '1';
        end if;
      end if;
    end if;
  end process;

  o_value <= std_logic_vector(r_value(3 downto 0));
  o_carry <= r_carry;
  o_borrow <= r_borrow;

end architecture behave;
