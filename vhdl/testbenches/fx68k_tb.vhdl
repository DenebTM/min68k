library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fx68k_tb is
end fx68k_tb;

architecture behave of fx68k_tb is

  constant c_CLOCK_PERIOD : time := 125 ns;
  constant c_NO_DATA : std_Logic_vector(3 downto 0) := "ZZZZ";
  constant c_INIT_DATA : std_logic_vector(3 downto 0) := "1000";

  signal i_CLOCK  : std_logic := '0';

  -- 68k signals
  signal i_RESET  : std_logic := '1';
  signal o_RESET  : std_logic;
  signal o_HALTED : std_logic;

  signal o_FC     : std_logic_vector(2 downto 0);

  signal o_RW     : std_logic;
  signal o_AS     : std_logic;
  signal o_LDS    : std_logic;
  signal o_UDS    : std_logic;
  signal o_VMA    : std_logic;
  signal i_VPA    : std_logic := '1';
  signal i_DTACK  : std_logic := '0';

  signal i_BR     : std_logic := '1';
  signal o_BG     : std_logic;
  signal i_BGACK  : std_logic := '1';
  signal i_BERR   : std_logic := '1';

  signal b_DATA   : unsigned(15 downto 0) := (others => '0');
  signal o_ADDR   : unsigned(23 downto 0);

  component fx68k is
    port (
      clk       : in    std_logic;
      HALTn     : in    std_logic;

      extReset  : in    std_logic;
      pwrUp     : in    std_logic;
      enPhi1    : in    std_logic;
      enPhi2    : in    std_logic;

      eRWn      : out   std_logic;
      ASn       : out   std_logic;
      LDSn      : out   std_logic;
      UDSn      : out   std_logic;
      E         : out   std_logic;
      VMAn      : out   std_logic;

      FC0       : out   std_logic;
      FC1       : out   std_logic;
      FC2       : out   std_logic;
      BGn       : out   std_logic;
      oRESETn   : out   std_logic;
      oHALTEDn  : out   std_logic;
      DTACKn    : in    std_logic;
      VPAn      : in    std_logic;
      BERRn     : in    std_logic;
      BRn       : in    std_logic;
      BGACKn    : in    std_logic;
      IPL0n     : in    std_logic;
      IPL1n     : in    std_logic;
      IPL2n     : in    std_logic;

      iEdb      : in    unsigned(15 downto 0);
      oEdb      : out   unsigned(15 downto 0);
      eab       : out   unsigned(23 downto 1)
    );
  end component fx68k;

begin

  m68k : fx68k
    port map (
      clk       => i_CLOCK,
      HALTn     => '1',

      extReset  => i_RESET,
      pwrUp     => i_RESET,
      enPhi1    => '1',
      enPhi2    => '1',

      eRWn      => o_RW,
      ASn       => o_AS,
      LDSn      => o_LDS,
      UDSn      => o_UDS,
      E         => open,
      VMAn      => o_VMA,

      FC0       => o_FC(0),
      FC1       => o_FC(1),
      FC2       => o_FC(2),
      BGn       => o_BG,
      oRESETn   => o_RESET,
      oHALTEDn  => o_HALTED,
      DTACKn    => i_DTACK,
      VPAn      => i_VPA,
      BERRn     => i_BERR,
      BRn       => i_BR,
      BGACKn    => i_BGACK,
      IPL0n     => '1',
      IPL1n     => '1',
      IPL2n     => '1',

      iEdb      => b_DATA,
      oEdb      => b_DATA,
      eab       => o_ADDR(23 downto 1)
    );

    -- clock generator
    p_CLK_GEN : process is
    begin
      wait for c_CLOCK_PERIOD/2;
      i_CLOCK <= not i_CLOCK;

    end process p_CLK_GEN;

    -- test process
    process
    begin
      i_RESET <= '0';
      wait for 10 ms;

      i_RESET <= '1';
      wait for 90 ms;

    end process;

end behave;
