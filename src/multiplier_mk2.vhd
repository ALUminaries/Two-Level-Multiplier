-------------------------------------------------------------------------------------
-- multiplier_mk2.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips, Nathan Hagerdorn
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: High-level component for two-level multiplier.
-- Precision:   Generic
-------------------------------------------------------------------------------------
--
-- Performs integer multiplication on inputs of high bit precision.
-- Takes inputs and returns outputs in sign and magnitude representation.
-- An implementation of the algorithm described in the paper: "Leveraging a
-- Novel Two-Level Priority Encoder for High-Precision Integer Multiplication"
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_n]: The size `n` of the multiplier `Mr`.
--
-- [G_log_2_n]: Base 2 Logarithm of multiplier length `n`.
--
-- [G_m]: The size `m` of the multiplicand `Md`.
--
-- [G_q]: The least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
--
-- [G_log_2_q]: Base 2 logarithm of `q` (# of bits required to represent q)
--
-- [G_k]: Defined as n/q. If n is a perfect square, then k = sqrt(n) = q.
--
-- [G_log_2_k]: Base 2 logarithm of `k`, and output size of the coarse encoder.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [clk]: Hardware clock signal.
--
-- [reset]: Asynchronous reset signal.
--
-- [start]: Start control signal, should remain high for duration of processing.
--
-- [s_mr]: Sign bit of the multiplier
--
-- [mr]: Magnitude of the multiplier.
--
-- [s_md]: Sign bit of the multiplicand.
--
-- [mr]: Magnitude of the multiplicand.
--
-- [s_prod]: Sign bit of the product.
--
-- [prod]: Magnitude of the product.
--
-- [done]: High once the hardware has finished processing.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;

entity two_level_multiplier is
  generic (
    G_n       : integer := 256; -- Input (multiplier) length is n
    G_m       : integer := 256  -- Input (multiplicand) length is m
  );
  port (
    clk    : in    std_logic;
    reset  : in    std_logic;
    start  : in    std_logic;
    s_mr   : in    std_logic;
    mr     : in    std_logic_vector(G_n - 1 downto 0);
    s_md   : in    std_logic;
    md     : in    std_logic_vector(G_m - 1 downto 0);
    s_prod : out   std_logic;
    prod   : out   std_logic_vector(G_n + G_m - 1 downto 0);
    done   : out   std_logic
  );
end two_level_multiplier;

architecture structural of two_level_multiplier is

  constant G_log_2_n : integer := integer(round(log2(real(G_n))));                  -- Base 2 Logarithm of input length n
  constant G_q       : integer := integer(round(2 ** ceil(log2(sqrt(real(G_n)))))); -- q is the least power of 2 greater than sqrt(n).
  constant G_log_2_q : integer := integer(round(log2(real(G_q))));                  -- Base 2 Logarithm of q
  constant G_k       : integer := G_n / G_q;                                        -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  constant G_log_2_k : integer := integer(round(log2(real(G_k))));                  -- Base 2 Logarithm of k

  component priority_encoder_generic is
    generic (
      G_n       : integer;
      G_log_2_n : integer;
      G_q       : integer;
      G_log_2_q : integer;
      G_k       : integer;
      G_log_2_k : integer
    );
    port (
      input  : in    std_logic_vector(G_n - 1 downto 0);
      output : out   std_logic_vector(G_log_2_n - 1 downto 0)
    );
  end component priority_encoder_generic;

  component barrel_shifter_generic is
    generic (
      G_n       : integer;
      G_log_2_n : integer;
      G_m       : integer;
      G_q       : integer;
      G_log_2_q : integer;
      G_k       : integer;
      G_log_2_k : integer
    );
    port (
      input  : in    std_logic_vector(G_m - 1 downto 0);
      shamt  : in    std_logic_vector(G_log_2_n - 1 downto 0);
      output : out   std_logic_vector(G_m + G_n - 1 downto 0)
    );
  end component barrel_shifter_generic;

  component decoder_generic is
    generic (
      G_input_size  : integer;
      G_coarse_size : integer;
      G_fine_size   : integer
    );
    port (
      input  : in    std_logic_vector(G_input_size - 1 downto 0);
      output : out   std_logic_vector((2 ** G_input_size) - 1 downto 0)
    );
  end component decoder_generic;

  component cla_top is
    generic (
      G_size : integer
    );
    port (
      a      : in    std_logic_vector(G_size - 1 downto 0);
      b      : in    std_logic_vector(G_size - 1 downto 0);
      c_in   : in    std_logic;
      sum    : out   std_logic_vector(G_size - 1 downto 0);
      c_out  : out   std_logic;
      prop_g : out   std_logic;
      gen_g  : out   std_logic
    );
  end component;

  -- Registers
  signal mr_reg   : std_logic_vector(G_n - 1 downto 0);
  signal prod_reg : std_logic_vector(G_n + G_m - 1 downto 0);

  -- Intermediate Signals
  signal encoder_output : std_logic_vector(G_log_2_n - 1 downto 0);
  signal decoder_output : std_logic_vector(G_n - 1 downto 0);
  signal shifter_output : std_logic_vector(G_n + G_m - 1 downto 0);
  signal xor_output     : std_logic_vector(G_n - 1 downto 0);
  signal adder_output   : std_logic_vector(G_n + G_m - 1 downto 0);
  signal hw_done        : std_logic;
  signal active         : std_logic;

  attribute dont_touch : string;
  attribute dont_touch of shifter_output : signal is "true";
  attribute dont_touch of active         : signal is "true";

begin

  -- Instantiate Components
  encoder : priority_encoder_generic
    generic map (
      G_n       => G_n,
      G_log_2_n => G_log_2_n,
      G_q       => G_q,
      G_log_2_q => G_log_2_q,
      G_k       => G_k,
      G_log_2_k => G_log_2_k
    )
    port map (
      input  => mr_reg,
      output => encoder_output
    );

  decoder : decoder_generic
    generic map (
      G_input_size  => G_log_2_n,
      G_coarse_size => G_log_2_k,
      G_fine_size   => G_log_2_q
    )
    port map (
      input  => encoder_output,
      output => decoder_output
    );

  shifter : barrel_shifter_generic
    generic map (
      G_n       => G_n,
      G_log_2_n => G_log_2_n,
      G_m       => G_m,
      G_q       => G_q,
      G_log_2_q => G_log_2_q,
      G_k       => G_k,
      G_log_2_k => G_log_2_k
    )
    port map (
      input  => md,
      shamt  => encoder_output,
      output => shifter_output
    );

  cla : cla_top
    generic map (
      G_size => prod_reg'length
    )
    port map (
      a      => prod_reg,
      b      => shifter_output,
      c_in   => '0',
      sum    => adder_output,
      c_out  => open,
      prop_g => open,
      gen_g  => open
    );

  xor_output <= mr_reg xor decoder_output; -- delete MSHB
  prod       <= prod_reg;
  s_prod     <= s_mr xor s_md;             -- determine sign bit
  hw_done    <= nor mr_reg;                -- generate done flag

  process (clk, reset) begin
    if (reset = '1') then
      mr_reg   <= (others => '1');   -- set all 1s initially to avoid premature done
      prod_reg <= (others => '0');
      done     <= '0';
      active   <= '0';
    elsif (clk'event and clk = '1') then
      done <= hw_done;
      if (start = '1' and active = '0') then
        mr_reg   <= mr;              -- take initial value of multiplier
        prod_reg <= (others => '0'); -- reset product register
        active   <= '1';
      elsif (active = '1' and hw_done = '0') then
        mr_reg   <= xor_output;
        prod_reg <= adder_output;
      end if;
    end if;
  end process;
end architecture structural;
