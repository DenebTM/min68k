library ieee;
use ieee.std_logic_1164.all;

entity sn74299 is
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
end sn74299;

architecture behave of sn74299 is
  signal data : std_logic_vector(7 downto 0);
  signal out_en : std_logic_vector(1 downto 0);
  signal func_sel : std_logic_vector(1 downto 0);
begin

  out_en <= i_g1 & i_g2;
  func_sel <= i_s1 & i_s0;

  process(i_clear, i_clock)
  begin
    -- asynchronous clear
    if i_clear = '0' then
      data <= "00000000";

    elsif rising_edge(i_clock) then
      case func_sel is
        -- load
        when "11" =>
          data <= io_data;

        -- shift right
        when "01" =>
          data <= i_sr & data(data'high downto data'low + 1);

        -- shift right
        when "10" =>
          data <= data(data'high - 1 downto data'low) & i_sl;

        -- hold
        when others => null;
      end case;

    end if;
  end process;

  -- cascade outputs
  o_qA <= data(data'low);
  o_qH <= data(data'high);

  -- high impedance unless G1 and G2 are asserted
  io_data <= data when out_en = "00" else "ZZZZZZZZ";

end architecture behave;
