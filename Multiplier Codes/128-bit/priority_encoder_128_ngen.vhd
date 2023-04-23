library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_128 is
generic(
  g_n:      integer := 128;  -- Input (multiplier) length is n
  g_log2n:  integer := 7;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 16;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 4;  -- Base 2 Logarithm of q
  g_k:      integer := 8;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 3  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_128;

architecture behavioral of priority_encoder_128 is

component priority_encoder_8
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

component priority_encoder_16
port(
  input: in std_logic_vector(g_q - 1 downto 0);
  output: out std_logic_vector(g_log2q - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(7)  <= input(127) or input(126) or input(125) or input(124) or input(123) or input(122) or input(121) or input(120) or 
                input(119) or input(118) or input(117) or input(116) or input(115) or input(114) or input(113) or input(112);

slice_or(6)  <= input(111) or input(110) or input(109) or input(108) or input(107) or input(106) or input(105) or input(104) or 
                input(103) or input(102) or input(101) or input(100) or input(99) or input(98) or input(97) or input(96);

slice_or(5)  <= input(95) or input(94) or input(93) or input(92) or input(91) or input(90) or input(89) or input(88) or 
                input(87) or input(86) or input(85) or input(84) or input(83) or input(82) or input(81) or input(80);

slice_or(4)  <= input(79) or input(78) or input(77) or input(76) or input(75) or input(74) or input(73) or input(72) or 
                input(71) or input(70) or input(69) or input(68) or input(67) or input(66) or input(65) or input(64);

slice_or(3)  <= input(63) or input(62) or input(61) or input(60) or input(59) or input(58) or input(57) or input(56) or 
                input(55) or input(54) or input(53) or input(52) or input(51) or input(50) or input(49) or input(48);

slice_or(2)  <= input(47) or input(46) or input(45) or input(44) or input(43) or input(42) or input(41) or input(40) or 
                input(39) or input(38) or input(37) or input(36) or input(35) or input(34) or input(33) or input(32);

slice_or(1)  <= input(31) or input(30) or input(29) or input(28) or input(27) or input(26) or input(25) or input(24) or 
                input(23) or input(22) or input(21) or input(20) or input(19) or input(18) or input(17) or input(16);

slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway

coarse_encoder: priority_encoder_8 port map(slice_or, c_output);

f_input <= 
  input(127 downto 112) when c_output = "111" else
  input(111 downto 96)  when c_output = "110" else
  input(95 downto 80)   when c_output = "101" else
  input(79 downto 64)   when c_output = "100" else
  input(63 downto 48)   when c_output = "11"  else
  input(47 downto 32)   when c_output = "10"  else
  input(31 downto 16)   when c_output = "1"   else
  input(15 downto 0);

fine_encoder: priority_encoder_16 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;