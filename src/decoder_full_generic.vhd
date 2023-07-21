-------------------------------------------------------------------------------------
-- decoder_full_generic.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Two-level decoder.
-- Precision:   Generic.
-------------------------------------------------------------------------------------
--
-- For an input n, returns 2^n. Alternatively, returns a bit vector with all zeroes
-- except for a single 1 at the nth index. This is a two-level decoder.
--
-- This version is entirely self-contained with no external dependencies.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_input_size]: Input width / bit precision. In 2LMR, should be equal to log_2(n).
--
-- [G_coarse_size]: Size of coarse (column) decoder. In 2LMR, should be log_2(k).
--
-- [G_fine_size]: Size of fine (row) decoder. In 2LMR, should be log_2(q).
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [input]: The input value to decode. For instance, the shift amount in 2LMR.
--
-- [output]: 2^[input]. The decoded output value. For instance, C_i in 2LMR.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity decoder_generic is
  generic (
    G_input_size  : integer := 8;
    G_coarse_size : integer := 4;
    G_fine_size   : integer := 4
  );
  port (
    input  : in    std_logic_vector(G_input_size - 1 downto 0);
    output : out   std_logic_vector((2**G_input_size) - 1 downto 0)
  );
end decoder_generic;

architecture behavioral of decoder_generic is

  signal col    : std_logic_vector((2**G_coarse_size) - 1 downto 0); -- column/coarse decoder, handles log_2(k) most significant bits of input
  signal row    : std_logic_vector((2**G_fine_size) - 1 downto 0);   -- row/fine decoder, handles log_2(q) least significant bits of input
  signal result : std_logic_vector(output'range);                    -- result of decoding, i.e., 2^[input]

  signal coarse_input : std_logic_vector(G_coarse_size - 1 downto 0);
  signal fine_input   : std_logic_vector(G_fine_size - 1 downto 0);

  type coarse_result_array is array (natural range 0 to (2**G_coarse_size) - 1) of std_logic_vector(col'range); 
  type fine_result_array is array (natural range 0 to (2**G_fine_size) - 1) of std_logic_vector(row'range); 
  
  signal coarse_result : coarse_result_array;
  signal fine_result   : fine_result_array;

begin

  -- Coarse Decoder (Columns)
  coarse_input <= input(G_input_size - 1 downto G_fine_size);

  gen_coarse_result :
  for i in ((2**G_coarse_size) - 1) downto 0 generate
    coarse_result(i) <= (i => '1', others => '0');
  end generate gen_coarse_result;

  col <= coarse_result(natural(to_integer(unsigned(coarse_input))));

  -- Fine Decoder (Rows)
  fine_input <= input(G_fine_size - 1 downto 0);

  gen_fine_result :
  for j in ((2**G_fine_size) - 1) downto 0 generate
    fine_result(j) <= (j => '1', others => '0');
  end generate gen_fine_result;  

  row <= fine_result(natural(to_integer(unsigned(fine_input))));

  -- AND Gate array
  -- generates each bit of the decoder result
  -- see two-level decoder block diagram
  coarse : for i in (2**G_coarse_size - 1) downto 0 generate -- generate columns
    fine : for j in (2**G_fine_size - 1) downto 0 generate -- generate rows
      result(((2**G_fine_size) * i) + j) <= col(i) and row(j);
    end generate fine;
  end generate coarse;

  output <= result;
end architecture behavioral;
