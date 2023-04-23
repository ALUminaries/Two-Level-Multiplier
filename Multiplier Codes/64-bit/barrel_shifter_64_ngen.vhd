library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity barrel_shifter_64 is
generic(
  g_n:      integer := 64;  -- Input (multiplier) length is n
  g_log2n:  integer := 6;  -- Base 2 Logarithm of input length n; i.e., output length
  g_m:      integer := 64;  -- Input (multiplicand) length is m
  g_q:      integer := 8;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 3;  -- Base 2 Logarithm of q
  g_k:      integer := 8;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 3  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_m - 1 downto 0); -- input to shift, i.e., multiplicand Md
  shamt: in std_logic_vector(g_log2n - 1 downto 0); -- shift amount, i.e., floor(log_2(Mr))
  output: out std_logic_vector(g_m + g_n - 1 downto 0) -- shifted output
);
end barrel_shifter_64;

architecture behavioral of barrel_shifter_64 is

signal shamt_upper: std_logic_vector(g_log2k - 1 downto 0); -- most significant log2(k) bits of shift amount
signal shamt_lower: std_logic_vector(g_log2q - 1 downto 0); -- least significant log2(q) bits of shift amount
signal coarse_result: std_logic_vector(g_m + g_n - 2 downto 0); -- result of coarse shifting
signal fine_result: std_logic_vector(g_m + g_q - 2 downto 0); -- result of fine shifting
-- we do the fine shift first to reduce the hardware complexity of intermediate signals
constant q_0s: std_logic_vector(g_q - 1 downto 0) := (others => '0'); -- shorthand for q zeroes

begin
shamt_upper <= shamt(g_log2n - 1 downto g_log2q); -- log2(k) most significant bits
shamt_lower <= shamt(g_log2q - 1 downto 0); -- log2(q) least significant bits

-- maximum fine shift: q - 1 bits
fine_result <=
       input & "0000000" when shamt_lower = 7 else
  "0" & input & "000000" when shamt_lower = 6 else
  "00" & input & "00000" when shamt_lower = 5 else
  "000" & input & "0000" when shamt_lower = 4 else
  "0000" & input & "000" when shamt_lower = 3 else
  "00000" & input & "00" when shamt_lower = 2 else
  "000000" & input & "0" when shamt_lower = 1 else
  "0000000" & input;

coarse_result <=
  fine_result & q_0s & q_0s & q_0s & q_0s & q_0s & q_0s & q_0s when shamt_upper = 7 else
  q_0s & fine_result & q_0s & q_0s & q_0s & q_0s & q_0s & q_0s when shamt_upper = 6 else
  q_0s & q_0s & fine_result & q_0s & q_0s & q_0s & q_0s & q_0s when shamt_upper = 5 else
  q_0s & q_0s & q_0s & fine_result & q_0s & q_0s & q_0s & q_0s when shamt_upper = 4 else
  q_0s & q_0s & q_0s & q_0s & fine_result & q_0s & q_0s & q_0s when shamt_upper = 3 else
  q_0s & q_0s & q_0s & q_0s & q_0s & fine_result & q_0s & q_0s when shamt_upper = 2 else
  q_0s & q_0s & q_0s & q_0s & q_0s & q_0s & fine_result & q_0s when shamt_upper = 1 else
  q_0s & q_0s & q_0s & q_0s & q_0s & q_0s & q_0s & fine_result;

output <= '0' & coarse_result;
end;