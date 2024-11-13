library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sn74163 is
  port (
    i_clock   : in  std_logic;

    i_en      : in  std_logic;
    i_en_rco  : in  std_logic;

    i_clear   : in  std_logic;
    i_load    : in  std_logic;

    o_carry   : out std_logic;

    i_value   : in  std_logic_vector(3 downto 0);
    o_value   : out std_logic_vector(3 downto 0)
  );
end sn74163;

architecture behave of sn74163 is
  signal r_value  : unsigned(3 downto 0);
begin

  process(i_clock)
  begin
    if rising_edge(i_clock) then
     -- synchronous clear
      if i_clear = '0' then
        r_value <= "0000";

      -- synchronous load
      elsif i_load = '0' then
        r_value <= unsigned(i_value);

      elsif i_en = '1' and i_en_rco = '1' then
        r_value <= r_value + 1;

      end if;
    end if;
  end process;

  o_value <= std_logic_vector(r_value(3 downto 0));
  o_carry <= '1' when (i_en = '1' and i_en_rco = '1' and r_value = 15) else '0';

end architecture behave;
