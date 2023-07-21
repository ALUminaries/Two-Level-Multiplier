-------------------------------------------------------------------------------------
-- barrel_shifter_generic.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Generalized barrel shifter.
-- Precision:   Arbitrary power of 2.
-------------------------------------------------------------------------------------
--
-- Produces an [output] equal to [input] left shifted by [shamt] bits.
-- Composed of a 'coarse' and 'fine' level.
-- The fine shifter shifts the input between 0 and q - 1 bits.
-- The coarse shifter shifts the input by a number of bits equal to 
-- a multiple of q between 0 and (k - 1)q (ex. 0, q, 2q, ... (k - 1)q).
-- Thus, the minimum shift is zero bits, and the maximum shift is (k * q - 1) bits,
-- which corresponds with the maximum value of [shamt].
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_n]: Unused, but is related to [G_log_2_n].
--
-- [G_log_2_n]: Base 2 Logarithm of input length `n`; i.e., output length
--
-- [G_m]: Input length `m`. For instance, the size of the multiplicand in 2LMR.
--
-- [G_q]: The least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
--
-- [G_log_2_q]: Base 2 logarithm of `q`.
--
-- [G_k]: Defined as n/q. If n is a perfect square, then k = sqrt(n) = q.
--
-- [G_log_2_k]: Base 2 logarithm of `k`.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [input]: Self explanatory. Has size [G_m].
--
-- [output]: Equal to [input] left shifted by [shamt] bits.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity barrel_shifter_generic is
  generic (
    G_n       : integer := 256; -- Unused
    G_log_2_n : integer := 8;   -- Base 2 Logarithm of input length n; i.e., output length
    G_m       : integer := 256; -- Input (multiplicand) length is m
    G_q       : integer := 16;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
    G_log_2_q : integer := 4;   -- Base 2 Logarithm of q
    G_k       : integer := 16;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
    G_log_2_k : integer := 4    -- Base 2 Logarithm of k
  );
  port (
    input  : in    std_logic_vector(G_m - 1 downto 0);       -- input to shift, i.e., multiplicand Md
    shamt  : in    std_logic_vector(G_log_2_n - 1 downto 0); -- shift amount, i.e., floor(log_2(Mr))
    output : out   std_logic_vector(G_m + G_n - 1 downto 0)  -- shifted output
  );
end barrel_shifter_generic;

architecture behavioral of barrel_shifter_generic is

  signal shamt_upper   : std_logic_vector(G_log_2_k - 1 downto 0); -- most significant log2(k) bits of shift amount
  signal shamt_lower   : std_logic_vector(G_log_2_q - 1 downto 0); -- least significant log2(q) bits of shift amount
  signal coarse_result : std_logic_vector(G_m + G_n - 2 downto 0); -- result of coarse shifting
  signal fine_result   : std_logic_vector(G_m + G_q - 2 downto 0); -- result of fine shifting
  -- we do the fine shift first to reduce the hardware complexity of intermediate signals

  type fine_array is array (natural range 0 to G_q - 1) of std_logic_vector(fine_result'range);
  type coarse_array is array (natural range 0 to G_k - 1) of std_logic_vector(coarse_result'range); 

  signal fine_arr   : fine_array;
  signal coarse_arr : coarse_array;

begin

  shamt_upper <= shamt(G_log_2_n - 1 downto G_log_2_q); -- log2(k) most significant bits
  shamt_lower <= shamt(G_log_2_q - 1 downto 0);         -- log2(q) least significant bits

  -- maximum fine shift: q - 1 bits
  gen_fine_result :
  for i in (G_q - 1) downto 0 generate
    -- most significant `(G_q - i)` bits := 0
    -- least significant `i` bits := 0
    fine_arr(i) <= ((fine_result'left - (G_q - i - 1)) downto i => input, others => '0');
  end generate gen_fine_result;

  fine_result <= fine_arr(natural(to_integer(unsigned(shamt_lower))));

  -- coarse shift
  gen_coarse_result :
  for j in (G_k - 1) downto 0 generate
    coarse_arr(j) <= (coarse_result'left - ((G_k - 1 - j) * G_q) downto (coarse_result'left - ((G_k - 1 - j) * G_q) - (fine_result'length - 1)) => fine_result, others => '0');
  end generate gen_coarse_result;
  
  coarse_result <= coarse_arr(natural(to_integer(unsigned(shamt_upper))));

  output <= "0" & coarse_result;

end architecture behavioral;