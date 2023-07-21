-------------------------------------------------------------------------------------
-- priority_encoder_generic.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Semi-generalized two-level priority encoder.
-- Precision:   32 to 4096 bits.
-------------------------------------------------------------------------------------
--
-- Returns the floor of the base 2 logarithm of the input,
-- or alternatively, the position of the most significant high bit (MSHB).
-- Composed of a 'coarse' and 'fine' level.
-- The coarse encoder determines which `q` bit slice the MSHB is in.
-- The fine encoder determines where in that slice the MSHB is.
-- Combined, their outputs are equal to the expected primary output.
--
-------------------------------------------------------------------------------------
-- Dependencies
-------------------------------------------------------------------------------------
--
-- This entity imports base priority encoders from 4 to 64 bits,
-- but only *instantiates* those of input width G_q (and G_k, if different).
-- Therefore, it *should* not be required to add the component files
-- that are not instantiated to your project. You can of course do so anyways.
--
-------------------------------------------------------------------------------------
-- Modification for Higher Bit Precisions
-------------------------------------------------------------------------------------
--
-- In order to utilize this component for precisions larger than 4096 bits, you will
-- need to create your own base-level encoders of 128+ bits.
-- This is not recommended due to growing complexity of encoders past 32 bits.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_n]: Input length `n`. For instance, the size of the multiplier in 2LMR.
--
-- [G_log_2_n]: Base 2 Logarithm of input length `n`; i.e., output length
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
-- [input]: Self explanatory. Has size [G_n].
--
-- [output]: Base 2 logarithm or position of MSHB in [input].
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity priority_encoder_generic is
  generic (
    G_n       : integer; --:= 256; -- Input length is n
    G_log_2_n : integer; --:= 8;   -- Base 2 Logarithm of input length n; i.e., output length
    G_q       : integer; --:= 16;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
    G_log_2_q : integer; --:= 4;   -- Base 2 Logarithm of q // Ignore any warnings claiming this isn't used. It is.
    G_k       : integer; --:= 16;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
    G_log_2_k : integer  --:= 4    -- Base 2 Logarithm of k
  );
  port (
    input  : in    std_logic_vector(G_n - 1 downto 0);
    output : out   std_logic_vector(G_log_2_n - 1 downto 0)
  );
end priority_encoder_generic;

architecture behavioral of priority_encoder_generic is

  component priority_encoder_4 is
    port ( 
      input  : in    std_logic_vector(3 downto 0);
      output : out   std_logic_vector(1 downto 0)
    );
  end component;

  component priority_encoder_8 is
    port ( 
      input  : in    std_logic_vector(7 downto 0);
      output : out   std_logic_vector(2 downto 0)
    );
  end component;

  component priority_encoder_16 is
    port (
      input  : in    std_logic_vector(15 downto 0);
      output : out   std_logic_vector(3 downto 0)
    );
  end component;

  component priority_encoder_32 is
    port ( 
      input  : in    std_logic_vector(31 downto 0);
      output : out   std_logic_vector(4 downto 0)
    );
  end component;

  component priority_encoder_64 is
    port ( 
      input  : in    std_logic_vector(63 downto 0);
      output : out   std_logic_vector(5 downto 0)
    );
  end component;

  component mux_generic is
    generic (
      G_entries     : natural;
      G_entry_width : natural
    );
    port (
      signal input  : in    std_logic_vector(G_n - 1 downto 0);
      signal sel    : in    std_logic_vector(natural(G_log_2_k) - 1 downto 0);
      signal output : out   std_logic_vector(G_entry_width - 1 downto 0)
    );
  end component;

  signal slice_or : std_logic_vector(G_k - 1 downto 0);       -- there should be `k` or gates with q inputs each. last is effectively unused
  signal c_output : std_logic_vector(G_log_2_k - 1 downto 0); -- coarse encoder output, select input signal for mux
  signal f_input  : std_logic_vector(G_q - 1 downto 0);       -- fine encoder input
  signal f_output : std_logic_vector(G_log_2_q - 1 downto 0); -- fine encoder output

begin

  gen_slice_or : 
  for i in 0 to (G_k - 2) generate
    slice_or((G_k - 1) - i) <= or input(((G_n - 1) - (G_q * i)) downto (G_n - (G_q * (i + 1))));
  end generate gen_slice_or;

  slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway

  gen_coarse_encoder : 
  if (G_k = 4) generate
    coarse_encoder : priority_encoder_4
      port map (
        input  => slice_or,
        output => c_output
      );
  elsif (G_k = 8) generate
    coarse_encoder : priority_encoder_8
      port map (
        input  => slice_or,
        output => c_output
      );
  elsif (G_k = 16) generate
    coarse_encoder : priority_encoder_16
      port map (
        input  => slice_or,
        output => c_output
      );
  elsif (G_k = 32) generate
    coarse_encoder : priority_encoder_32
      port map (
        input  => slice_or,
        output => c_output
      );
  elsif (G_k = 64) generate
    coarse_encoder : priority_encoder_64
      port map (
        input  => slice_or,
        output => c_output
      );
  end generate gen_coarse_encoder;

  mux : mux_generic
    generic map (
      G_entries     => G_k,
      G_entry_width => G_q
    )
    port map (
      input  => input,
      sel    => c_output,
      output => f_input
    );
  
  gen_fine_encoder : 
  if (G_q = 4) generate
    fine_encoder : priority_encoder_4
      port map (
        input  => f_input,
        output => f_output
      );
  elsif (G_q = 8) generate
    fine_encoder : priority_encoder_8
      port map (
        input  => f_input,
        output => f_output
      );
  elsif (G_q = 16) generate
    fine_encoder : priority_encoder_16
      port map (
        input  => f_input,
        output => f_output
      );
  elsif (G_q = 32) generate
    fine_encoder : priority_encoder_32
      port map (
        input  => f_input,
        output => f_output
      );
  elsif (G_q = 64) generate
    fine_encoder : priority_encoder_64
      port map (
        input  => f_input,
        output => f_output
      );
  end generate gen_fine_encoder;

  output(G_log_2_n - 1 downto G_log_2_q) <= c_output;
  output(G_log_2_q - 1 downto 0) <= f_output;
  
end architecture behavioral;
