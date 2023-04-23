library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_32 is
generic(
  g_n:      integer := 32;  -- Input (multiplier) length is n
  g_log2n:  integer := 5;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 8;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 3;  -- Base 2 Logarithm of q
  g_k:      integer := 4;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 2  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_32;

architecture behavioral of priority_encoder_32 is

component priority_encoder_4
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

component priority_encoder_8
port(
  input: in std_logic_vector(g_q - 1 downto 0);
  output: out std_logic_vector(g_log2q - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(3)  <= input(31) or input(30) or input(29) or input(28) or input(27) or input(26) or input(25) or input(24);

slice_or(2)  <= input(23) or input(22) or input(21) or input(20) or input(19) or input(18) or input(17) or input(16);

slice_or(1)  <= input(15) or input(14) or input(13) or input(12) or input(11) or input(10) or input(9) or input(8);

slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway

coarse_encoder: priority_encoder_4 port map(slice_or, c_output);

f_input <= 
  input(31 downto 24) when c_output = "11" else
  input(23 downto 16) when c_output = "10" else
  input(15 downto 8)  when c_output = "1"  else
  input(7 downto 0);

fine_encoder: priority_encoder_8 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;