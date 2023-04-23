library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_512 is
generic(
  g_n:      integer := 512;  -- Input (multiplier) length is n
  g_log2n:  integer := 9;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 32;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 5;  -- Base 2 Logarithm of q
  g_k:      integer := 16;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 4  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_512;

architecture behavioral of priority_encoder_512 is

component priority_encoder_16
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

component priority_encoder_32
port(
  input: in std_logic_vector(g_q - 1 downto 0);
  output: out std_logic_vector(g_log2q - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(15) <= input(511) or input(510) or input(509) or input(508) or input(507) or input(506) or input(505) or input(504) or 
                input(503) or input(502) or input(501) or input(500) or input(499) or input(498) or input(497) or input(496) or 
                input(495) or input(494) or input(493) or input(492) or input(491) or input(490) or input(489) or input(488) or 
                input(487) or input(486) or input(485) or input(484) or input(483) or input(482) or input(481) or input(480);

slice_or(14) <= input(479) or input(478) or input(477) or input(476) or input(475) or input(474) or input(473) or input(472) or 
                input(471) or input(470) or input(469) or input(468) or input(467) or input(466) or input(465) or input(464) or 
                input(463) or input(462) or input(461) or input(460) or input(459) or input(458) or input(457) or input(456) or 
                input(455) or input(454) or input(453) or input(452) or input(451) or input(450) or input(449) or input(448);

slice_or(13) <= input(447) or input(446) or input(445) or input(444) or input(443) or input(442) or input(441) or input(440) or 
                input(439) or input(438) or input(437) or input(436) or input(435) or input(434) or input(433) or input(432) or 
                input(431) or input(430) or input(429) or input(428) or input(427) or input(426) or input(425) or input(424) or 
                input(423) or input(422) or input(421) or input(420) or input(419) or input(418) or input(417) or input(416);

slice_or(12) <= input(415) or input(414) or input(413) or input(412) or input(411) or input(410) or input(409) or input(408) or 
                input(407) or input(406) or input(405) or input(404) or input(403) or input(402) or input(401) or input(400) or 
                input(399) or input(398) or input(397) or input(396) or input(395) or input(394) or input(393) or input(392) or 
                input(391) or input(390) or input(389) or input(388) or input(387) or input(386) or input(385) or input(384);

slice_or(11) <= input(383) or input(382) or input(381) or input(380) or input(379) or input(378) or input(377) or input(376) or 
                input(375) or input(374) or input(373) or input(372) or input(371) or input(370) or input(369) or input(368) or 
                input(367) or input(366) or input(365) or input(364) or input(363) or input(362) or input(361) or input(360) or 
                input(359) or input(358) or input(357) or input(356) or input(355) or input(354) or input(353) or input(352);

slice_or(10) <= input(351) or input(350) or input(349) or input(348) or input(347) or input(346) or input(345) or input(344) or 
                input(343) or input(342) or input(341) or input(340) or input(339) or input(338) or input(337) or input(336) or 
                input(335) or input(334) or input(333) or input(332) or input(331) or input(330) or input(329) or input(328) or 
                input(327) or input(326) or input(325) or input(324) or input(323) or input(322) or input(321) or input(320);

slice_or(9)  <= input(319) or input(318) or input(317) or input(316) or input(315) or input(314) or input(313) or input(312) or 
                input(311) or input(310) or input(309) or input(308) or input(307) or input(306) or input(305) or input(304) or 
                input(303) or input(302) or input(301) or input(300) or input(299) or input(298) or input(297) or input(296) or 
                input(295) or input(294) or input(293) or input(292) or input(291) or input(290) or input(289) or input(288);

slice_or(8)  <= input(287) or input(286) or input(285) or input(284) or input(283) or input(282) or input(281) or input(280) or 
                input(279) or input(278) or input(277) or input(276) or input(275) or input(274) or input(273) or input(272) or 
                input(271) or input(270) or input(269) or input(268) or input(267) or input(266) or input(265) or input(264) or 
                input(263) or input(262) or input(261) or input(260) or input(259) or input(258) or input(257) or input(256);

slice_or(7)  <= input(255) or input(254) or input(253) or input(252) or input(251) or input(250) or input(249) or input(248) or 
                input(247) or input(246) or input(245) or input(244) or input(243) or input(242) or input(241) or input(240) or 
                input(239) or input(238) or input(237) or input(236) or input(235) or input(234) or input(233) or input(232) or 
                input(231) or input(230) or input(229) or input(228) or input(227) or input(226) or input(225) or input(224);

slice_or(6)  <= input(223) or input(222) or input(221) or input(220) or input(219) or input(218) or input(217) or input(216) or 
                input(215) or input(214) or input(213) or input(212) or input(211) or input(210) or input(209) or input(208) or 
                input(207) or input(206) or input(205) or input(204) or input(203) or input(202) or input(201) or input(200) or 
                input(199) or input(198) or input(197) or input(196) or input(195) or input(194) or input(193) or input(192);

slice_or(5)  <= input(191) or input(190) or input(189) or input(188) or input(187) or input(186) or input(185) or input(184) or 
                input(183) or input(182) or input(181) or input(180) or input(179) or input(178) or input(177) or input(176) or 
                input(175) or input(174) or input(173) or input(172) or input(171) or input(170) or input(169) or input(168) or 
                input(167) or input(166) or input(165) or input(164) or input(163) or input(162) or input(161) or input(160);

slice_or(4)  <= input(159) or input(158) or input(157) or input(156) or input(155) or input(154) or input(153) or input(152) or 
                input(151) or input(150) or input(149) or input(148) or input(147) or input(146) or input(145) or input(144) or 
                input(143) or input(142) or input(141) or input(140) or input(139) or input(138) or input(137) or input(136) or 
                input(135) or input(134) or input(133) or input(132) or input(131) or input(130) or input(129) or input(128);

slice_or(3)  <= input(127) or input(126) or input(125) or input(124) or input(123) or input(122) or input(121) or input(120) or 
                input(119) or input(118) or input(117) or input(116) or input(115) or input(114) or input(113) or input(112) or 
                input(111) or input(110) or input(109) or input(108) or input(107) or input(106) or input(105) or input(104) or 
                input(103) or input(102) or input(101) or input(100) or input(99) or input(98) or input(97) or input(96);

slice_or(2)  <= input(95) or input(94) or input(93) or input(92) or input(91) or input(90) or input(89) or input(88) or 
                input(87) or input(86) or input(85) or input(84) or input(83) or input(82) or input(81) or input(80) or 
                input(79) or input(78) or input(77) or input(76) or input(75) or input(74) or input(73) or input(72) or 
                input(71) or input(70) or input(69) or input(68) or input(67) or input(66) or input(65) or input(64);

slice_or(1)  <= input(63) or input(62) or input(61) or input(60) or input(59) or input(58) or input(57) or input(56) or 
                input(55) or input(54) or input(53) or input(52) or input(51) or input(50) or input(49) or input(48) or 
                input(47) or input(46) or input(45) or input(44) or input(43) or input(42) or input(41) or input(40) or 
                input(39) or input(38) or input(37) or input(36) or input(35) or input(34) or input(33) or input(32);

slice_or(0) <= '1'; -- shouldn't matter if it's 0 or 1, it isn't looked at anyway

coarse_encoder: priority_encoder_16 port map(slice_or, c_output);

f_input <= 
  input(511 downto 480) when c_output = "1111" else
  input(479 downto 448) when c_output = "1110" else
  input(447 downto 416) when c_output = "1101" else
  input(415 downto 384) when c_output = "1100" else
  input(383 downto 352) when c_output = "1011" else
  input(351 downto 320) when c_output = "1010" else
  input(319 downto 288) when c_output = "1001" else
  input(287 downto 256) when c_output = "1000" else
  input(255 downto 224) when c_output = "111"  else
  input(223 downto 192) when c_output = "110"  else
  input(191 downto 160) when c_output = "101"  else
  input(159 downto 128) when c_output = "100"  else
  input(127 downto 96)  when c_output = "11"   else
  input(95 downto 64)   when c_output = "10"   else
  input(63 downto 32)   when c_output = "1"    else
  input(31 downto 0);

fine_encoder: priority_encoder_32 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;