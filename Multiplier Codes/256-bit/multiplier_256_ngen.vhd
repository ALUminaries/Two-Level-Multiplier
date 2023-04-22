library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;

entity multiplier_256 is
generic(
  g_n:      integer := 256;  -- Input (multiplier) length is n
  g_log2n:  integer := 8;  -- Base 2 Logarithm of input length n; i.e., output length
  g_m:      integer := 256;  -- Input (multiplicand) length is m
  g_q:      integer := 16;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 4;  -- Base 2 Logarithm of q
  g_k:      integer := 16;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 4  -- Base 2 Logarithm of k
);
port(
  clk: in std_logic;
  start: in std_logic;
  reset: in std_logic;
  mr: in std_logic_vector(g_n - 1 downto 0);
  s_mr: in std_logic;
  md: in std_logic_vector(g_m - 1 downto 0);
  s_md: in std_logic;
  prod: out std_logic_vector(g_n + g_m - 1 downto 0);
  s_prod: out std_logic;
  done: out std_logic
);
end multiplier_256;

architecture structural of multiplier_256 is

  component priority_encoder_256
  port(
    input: in std_logic_vector(g_n-1 downto 0);
    output: out std_logic_vector(g_log2n-1 downto 0)
  );
  end component;

  component barrel_shifter_256
  port(
    input: in std_logic_vector(g_m - 1 downto 0); -- input to shift, i.e., multiplicand Md
    shamt: in std_logic_vector(g_log2n - 1 downto 0); -- shift amount, i.e., floor(log_2(Mr))
    output: out std_logic_vector(g_m + g_n - 1 downto 0) -- shifted output
  );
  end component;

  component decoder_256
  port(
    input: in std_logic_vector(g_log2n - 1 downto 0); -- value to decode, i.e., shift amount for multiplication)
    output: out std_logic_vector(g_n - 1 downto 0) -- decoded result (C_i)
  );
  end component;

  component CLA512
  port(
    A, B: in std_logic_vector(g_n + g_m - 1 downto 0);
    Ci: in std_logic;
    S: out std_logic_vector(g_n + g_m - 1 downto 0);
    Co, PG, GG: out std_logic
  );
  end component;

  -- Registers
  signal mr_reg: std_logic_vector(g_n - 1 downto 0) := (others => '1');
  signal prod_reg: std_logic_vector(g_n + g_m - 1 downto 0);

  -- Intermediate Signals
  signal encoder_output: std_logic_vector(g_log2n - 1 downto 0);
  signal decoder_output: std_logic_vector(g_n - 1 downto 0);
  signal shifter_output: std_logic_vector(g_n + g_m - 1 downto 0);
  signal xor_output: std_logic_vector(g_n - 1 downto 0);
  signal adder_output: std_logic_vector(g_n + g_m - 1 downto 0);
  signal adder_cout: std_logic;
  signal hw_done: std_logic := '0';
  signal active: std_logic := '0';
  attribute dont_touch: string;
  attribute dont_touch of shifter_output: signal is "true";
  attribute dont_touch of active: signal is "true";

begin
  -- Instantiate Components
  encoder: priority_encoder_256 port map(mr_reg, encoder_output);
  decoder: decoder_256 port map(encoder_output, decoder_output);
  shifter: barrel_shifter_256 port map(md, encoder_output, shifter_output);
  adder: CLA512 port map(
    A => prod_reg,
    B => shifter_output,
    Ci => '0',
    S => adder_output,
    Co => adder_cout,
    PG => open,
    GG => open
  );

  xor_output <= mr_reg xor decoder_output;
  prod <= prod_reg;
  s_prod <= s_mr xor s_md;
  hw_done <= not or_reduce(mr_reg);

  process (clk, reset) begin
    if (reset = '1') then
      mr_reg <= (others => '1'); -- set all 1s initially to avoid premature done
      prod_reg <= (others => '0');
      done <= '0';
    elsif (clk'event and clk = '1') then
      done <= hw_done;
      if (start = '1' and active = '0') then
        mr_reg <= mr; -- take initial value of multiplier
        prod_reg <= (others => '0'); -- reset product register
        active <= '1';
      elsif (active = '1' and hw_done = '0') then
        mr_reg <= xor_output;
        prod_reg <= adder_output;
      end if;
    end if;
  end process;
end;