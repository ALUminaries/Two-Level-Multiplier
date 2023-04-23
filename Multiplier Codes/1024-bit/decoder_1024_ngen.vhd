library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity decoder_1024 is
generic(
  g_n:      integer := 1024;  -- Input (multiplier) length is n
  g_log2n:  integer := 10;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 32;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 5;  -- Base 2 Logarithm of q
  g_k:      integer := 32;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 5  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_log2n - 1 downto 0); -- value to decode, i.e., shift amount for multiplication)
  output: out std_logic_vector(g_n - 1 downto 0) -- decoded result (C_i)
);
end decoder_1024;

architecture behavioral of decoder_1024 is

signal col: std_logic_vector(g_k - 1 downto 0); -- column/coarse decoder, handles log2k most significant bits of input
signal row: std_logic_vector(g_q - 1 downto 0); -- row/fine decoder, handles log2q least significant bits of input
signal result: std_logic_vector(g_n - 1 downto 0); -- result of decoding, i.e., 2^{input}

begin
-- Decoding corresponds to binary representation of given portions of shift

col(31) <= input(9) and input(8) and input(7) and input(6) and input(5);
col(30) <= input(9) and input(8) and input(7) and input(6) and not input(5);
col(29) <= input(9) and input(8) and input(7) and not input(6) and input(5);
col(28) <= input(9) and input(8) and input(7) and not input(6) and not input(5);
col(27) <= input(9) and input(8) and not input(7) and input(6) and input(5);
col(26) <= input(9) and input(8) and not input(7) and input(6) and not input(5);
col(25) <= input(9) and input(8) and not input(7) and not input(6) and input(5);
col(24) <= input(9) and input(8) and not input(7) and not input(6) and not input(5);
col(23) <= input(9) and not input(8) and input(7) and input(6) and input(5);
col(22) <= input(9) and not input(8) and input(7) and input(6) and not input(5);
col(21) <= input(9) and not input(8) and input(7) and not input(6) and input(5);
col(20) <= input(9) and not input(8) and input(7) and not input(6) and not input(5);
col(19) <= input(9) and not input(8) and not input(7) and input(6) and input(5);
col(18) <= input(9) and not input(8) and not input(7) and input(6) and not input(5);
col(17) <= input(9) and not input(8) and not input(7) and not input(6) and input(5);
col(16) <= input(9) and not input(8) and not input(7) and not input(6) and not input(5);
col(15) <= not input(9) and input(8) and input(7) and input(6) and input(5);
col(14) <= not input(9) and input(8) and input(7) and input(6) and not input(5);
col(13) <= not input(9) and input(8) and input(7) and not input(6) and input(5);
col(12) <= not input(9) and input(8) and input(7) and not input(6) and not input(5);
col(11) <= not input(9) and input(8) and not input(7) and input(6) and input(5);
col(10) <= not input(9) and input(8) and not input(7) and input(6) and not input(5);
col(9)  <= not input(9) and input(8) and not input(7) and not input(6) and input(5);
col(8)  <= not input(9) and input(8) and not input(7) and not input(6) and not input(5);
col(7)  <= not input(9) and not input(8) and input(7) and input(6) and input(5);
col(6)  <= not input(9) and not input(8) and input(7) and input(6) and not input(5);
col(5)  <= not input(9) and not input(8) and input(7) and not input(6) and input(5);
col(4)  <= not input(9) and not input(8) and input(7) and not input(6) and not input(5);
col(3)  <= not input(9) and not input(8) and not input(7) and input(6) and input(5);
col(2)  <= not input(9) and not input(8) and not input(7) and input(6) and not input(5);
col(1)  <= not input(9) and not input(8) and not input(7) and not input(6) and input(5);
col(0)  <= not input(9) and not input(8) and not input(7) and not input(6) and not input(5);

row(31) <= input(4) and input(3) and input(2) and input(1) and input(0);
row(30) <= input(4) and input(3) and input(2) and input(1) and not input(0);
row(29) <= input(4) and input(3) and input(2) and not input(1) and input(0);
row(28) <= input(4) and input(3) and input(2) and not input(1) and not input(0);
row(27) <= input(4) and input(3) and not input(2) and input(1) and input(0);
row(26) <= input(4) and input(3) and not input(2) and input(1) and not input(0);
row(25) <= input(4) and input(3) and not input(2) and not input(1) and input(0);
row(24) <= input(4) and input(3) and not input(2) and not input(1) and not input(0);
row(23) <= input(4) and not input(3) and input(2) and input(1) and input(0);
row(22) <= input(4) and not input(3) and input(2) and input(1) and not input(0);
row(21) <= input(4) and not input(3) and input(2) and not input(1) and input(0);
row(20) <= input(4) and not input(3) and input(2) and not input(1) and not input(0);
row(19) <= input(4) and not input(3) and not input(2) and input(1) and input(0);
row(18) <= input(4) and not input(3) and not input(2) and input(1) and not input(0);
row(17) <= input(4) and not input(3) and not input(2) and not input(1) and input(0);
row(16) <= input(4) and not input(3) and not input(2) and not input(1) and not input(0);
row(15) <= not input(4) and input(3) and input(2) and input(1) and input(0);
row(14) <= not input(4) and input(3) and input(2) and input(1) and not input(0);
row(13) <= not input(4) and input(3) and input(2) and not input(1) and input(0);
row(12) <= not input(4) and input(3) and input(2) and not input(1) and not input(0);
row(11) <= not input(4) and input(3) and not input(2) and input(1) and input(0);
row(10) <= not input(4) and input(3) and not input(2) and input(1) and not input(0);
row(9)  <= not input(4) and input(3) and not input(2) and not input(1) and input(0);
row(8)  <= not input(4) and input(3) and not input(2) and not input(1) and not input(0);
row(7)  <= not input(4) and not input(3) and input(2) and input(1) and input(0);
row(6)  <= not input(4) and not input(3) and input(2) and input(1) and not input(0);
row(5)  <= not input(4) and not input(3) and input(2) and not input(1) and input(0);
row(4)  <= not input(4) and not input(3) and input(2) and not input(1) and not input(0);
row(3)  <= not input(4) and not input(3) and not input(2) and input(1) and input(0);
row(2)  <= not input(4) and not input(3) and not input(2) and input(1) and not input(0);
row(1)  <= not input(4) and not input(3) and not input(2) and not input(1) and input(0);
row(0)  <= not input(4) and not input(3) and not input(2) and not input(1) and not input(0);


-- generates each bit of the decoder result
-- see two-level decoder block diagram
coarse: for i in g_k - 1 downto 0 generate -- generate columns
  fine: for j in g_q - 1 downto 0 generate -- generate rows
    result((g_q * i) + j) <= col(i) and row(j);
  end generate fine;
end generate coarse;

output <= result;
end;