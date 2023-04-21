library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_256 is
generic(
  g_n:      integer := 256;  -- Input (multiplier) length is n
  g_log2n:  integer := 8;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 16;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 4;  -- Base 2 Logarithm of q
  g_k:      integer := 16;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 4  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_256;

architecture behavioral of priority_encoder_256 is

component priority_encoder_16
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(15) <= input(255) or input(254) or input(253) or input(252) or input(251) or input(250) or input(249) or input(248) or 
                input(247) or input(246) or input(245) or input(244) or input(243) or input(242) or input(241) or input(240);

slice_or(14) <= input(239) or input(238) or input(237) or input(236) or input(235) or input(234) or input(233) or input(232) or 
                input(231) or input(230) or input(229) or input(228) or input(227) or input(226) or input(225) or input(224);

slice_or(13) <= input(223) or input(222) or input(221) or input(220) or input(219) or input(218) or input(217) or input(216) or 
                input(215) or input(214) or input(213) or input(212) or input(211) or input(210) or input(209) or input(208);

slice_or(12) <= input(207) or input(206) or input(205) or input(204) or input(203) or input(202) or input(201) or input(200) or 
                input(199) or input(198) or input(197) or input(196) or input(195) or input(194) or input(193) or input(192);

slice_or(11) <= input(191) or input(190) or input(189) or input(188) or input(187) or input(186) or input(185) or input(184) or 
                input(183) or input(182) or input(181) or input(180) or input(179) or input(178) or input(177) or input(176);

slice_or(10) <= input(175) or input(174) or input(173) or input(172) or input(171) or input(170) or input(169) or input(168) or 
                input(167) or input(166) or input(165) or input(164) or input(163) or input(162) or input(161) or input(160);

slice_or(9)  <= input(159) or input(158) or input(157) or input(156) or input(155) or input(154) or input(153) or input(152) or 
                input(151) or input(150) or input(149) or input(148) or input(147) or input(146) or input(145) or input(144);

slice_or(8)  <= input(143) or input(142) or input(141) or input(140) or input(139) or input(138) or input(137) or input(136) or 
                input(135) or input(134) or input(133) or input(132) or input(131) or input(130) or input(129) or input(128);

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

coarse_encoder: priority_encoder_16 port map(slice_or, c_output);

f_input <= 
  input(255 downto 240) when c_output = "1111" else
  input(239 downto 224) when c_output = "1110" else
  input(223 downto 208) when c_output = "1101" else
  input(207 downto 192) when c_output = "1100" else
  input(191 downto 176) when c_output = "1011" else
  input(175 downto 160) when c_output = "1010" else
  input(159 downto 144) when c_output = "1001" else
  input(143 downto 128) when c_output = "1000" else
  input(127 downto 112) when c_output = "111"  else
  input(111 downto 96)  when c_output = "110"  else
  input(95 downto 80)   when c_output = "101"  else
  input(79 downto 64)   when c_output = "100"  else
  input(63 downto 48)   when c_output = "11"   else
  input(47 downto 32)   when c_output = "10"   else
  input(31 downto 16)   when c_output = "1"    else
  input(15 downto 0);

fine_encoder: priority_encoder_16 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;