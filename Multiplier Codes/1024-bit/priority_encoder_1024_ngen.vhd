library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_1024 is
generic(
  g_n:      integer := 1024;  -- Input (multiplier) length is n
  g_log2n:  integer := 10;  -- Base 2 Logarithm of input length n; i.e., output length
  g_q:      integer := 32;  -- q is the least power of 2 greater than sqrt(n); i.e., 2^(ceil(log_2(sqrt(n)))
  g_log2q:  integer := 5;  -- Base 2 Logarithm of q
  g_k:      integer := 32;  -- k is defined as n/q, if n is a perfect square, then k = sqrt(n) = q
  g_log2k:  integer := 5  -- Base 2 Logarithm of k
);
port(
  input: in std_logic_vector(g_n-1 downto 0);
  output: out std_logic_vector(g_log2n-1 downto 0)
);
end priority_encoder_1024;

architecture behavioral of priority_encoder_1024 is

component priority_encoder_32
port(
  input: in std_logic_vector(g_k - 1 downto 0);
  output: out std_logic_vector(g_log2k - 1 downto 0)
);
end component;

signal c_output: std_logic_vector(g_log2k - 1 downto 0); -- coarse encoder output, select input signal for mux
signal f_input: std_logic_vector(g_q - 1 downto 0); -- fine encoder input
signal slice_or: std_logic_vector(g_k - 1 downto 0); -- there should be `k` or gates with q inputs each. last is effectively unused

begin
slice_or(31) <= input(1023) or input(1022) or input(1021) or input(1020) or input(1019) or input(1018) or input(1017) or input(1016) or 
                input(1015) or input(1014) or input(1013) or input(1012) or input(1011) or input(1010) or input(1009) or input(1008) or 
                input(1007) or input(1006) or input(1005) or input(1004) or input(1003) or input(1002) or input(1001) or input(1000) or 
                input(999) or input(998) or input(997) or input(996) or input(995) or input(994) or input(993) or input(992);

slice_or(30) <= input(991) or input(990) or input(989) or input(988) or input(987) or input(986) or input(985) or input(984) or 
                input(983) or input(982) or input(981) or input(980) or input(979) or input(978) or input(977) or input(976) or 
                input(975) or input(974) or input(973) or input(972) or input(971) or input(970) or input(969) or input(968) or 
                input(967) or input(966) or input(965) or input(964) or input(963) or input(962) or input(961) or input(960);

slice_or(29) <= input(959) or input(958) or input(957) or input(956) or input(955) or input(954) or input(953) or input(952) or 
                input(951) or input(950) or input(949) or input(948) or input(947) or input(946) or input(945) or input(944) or 
                input(943) or input(942) or input(941) or input(940) or input(939) or input(938) or input(937) or input(936) or 
                input(935) or input(934) or input(933) or input(932) or input(931) or input(930) or input(929) or input(928);

slice_or(28) <= input(927) or input(926) or input(925) or input(924) or input(923) or input(922) or input(921) or input(920) or 
                input(919) or input(918) or input(917) or input(916) or input(915) or input(914) or input(913) or input(912) or 
                input(911) or input(910) or input(909) or input(908) or input(907) or input(906) or input(905) or input(904) or 
                input(903) or input(902) or input(901) or input(900) or input(899) or input(898) or input(897) or input(896);

slice_or(27) <= input(895) or input(894) or input(893) or input(892) or input(891) or input(890) or input(889) or input(888) or 
                input(887) or input(886) or input(885) or input(884) or input(883) or input(882) or input(881) or input(880) or 
                input(879) or input(878) or input(877) or input(876) or input(875) or input(874) or input(873) or input(872) or 
                input(871) or input(870) or input(869) or input(868) or input(867) or input(866) or input(865) or input(864);

slice_or(26) <= input(863) or input(862) or input(861) or input(860) or input(859) or input(858) or input(857) or input(856) or 
                input(855) or input(854) or input(853) or input(852) or input(851) or input(850) or input(849) or input(848) or 
                input(847) or input(846) or input(845) or input(844) or input(843) or input(842) or input(841) or input(840) or 
                input(839) or input(838) or input(837) or input(836) or input(835) or input(834) or input(833) or input(832);

slice_or(25) <= input(831) or input(830) or input(829) or input(828) or input(827) or input(826) or input(825) or input(824) or 
                input(823) or input(822) or input(821) or input(820) or input(819) or input(818) or input(817) or input(816) or 
                input(815) or input(814) or input(813) or input(812) or input(811) or input(810) or input(809) or input(808) or 
                input(807) or input(806) or input(805) or input(804) or input(803) or input(802) or input(801) or input(800);

slice_or(24) <= input(799) or input(798) or input(797) or input(796) or input(795) or input(794) or input(793) or input(792) or 
                input(791) or input(790) or input(789) or input(788) or input(787) or input(786) or input(785) or input(784) or 
                input(783) or input(782) or input(781) or input(780) or input(779) or input(778) or input(777) or input(776) or 
                input(775) or input(774) or input(773) or input(772) or input(771) or input(770) or input(769) or input(768);

slice_or(23) <= input(767) or input(766) or input(765) or input(764) or input(763) or input(762) or input(761) or input(760) or 
                input(759) or input(758) or input(757) or input(756) or input(755) or input(754) or input(753) or input(752) or 
                input(751) or input(750) or input(749) or input(748) or input(747) or input(746) or input(745) or input(744) or 
                input(743) or input(742) or input(741) or input(740) or input(739) or input(738) or input(737) or input(736);

slice_or(22) <= input(735) or input(734) or input(733) or input(732) or input(731) or input(730) or input(729) or input(728) or 
                input(727) or input(726) or input(725) or input(724) or input(723) or input(722) or input(721) or input(720) or 
                input(719) or input(718) or input(717) or input(716) or input(715) or input(714) or input(713) or input(712) or 
                input(711) or input(710) or input(709) or input(708) or input(707) or input(706) or input(705) or input(704);

slice_or(21) <= input(703) or input(702) or input(701) or input(700) or input(699) or input(698) or input(697) or input(696) or 
                input(695) or input(694) or input(693) or input(692) or input(691) or input(690) or input(689) or input(688) or 
                input(687) or input(686) or input(685) or input(684) or input(683) or input(682) or input(681) or input(680) or 
                input(679) or input(678) or input(677) or input(676) or input(675) or input(674) or input(673) or input(672);

slice_or(20) <= input(671) or input(670) or input(669) or input(668) or input(667) or input(666) or input(665) or input(664) or 
                input(663) or input(662) or input(661) or input(660) or input(659) or input(658) or input(657) or input(656) or 
                input(655) or input(654) or input(653) or input(652) or input(651) or input(650) or input(649) or input(648) or 
                input(647) or input(646) or input(645) or input(644) or input(643) or input(642) or input(641) or input(640);

slice_or(19) <= input(639) or input(638) or input(637) or input(636) or input(635) or input(634) or input(633) or input(632) or 
                input(631) or input(630) or input(629) or input(628) or input(627) or input(626) or input(625) or input(624) or 
                input(623) or input(622) or input(621) or input(620) or input(619) or input(618) or input(617) or input(616) or 
                input(615) or input(614) or input(613) or input(612) or input(611) or input(610) or input(609) or input(608);

slice_or(18) <= input(607) or input(606) or input(605) or input(604) or input(603) or input(602) or input(601) or input(600) or 
                input(599) or input(598) or input(597) or input(596) or input(595) or input(594) or input(593) or input(592) or 
                input(591) or input(590) or input(589) or input(588) or input(587) or input(586) or input(585) or input(584) or 
                input(583) or input(582) or input(581) or input(580) or input(579) or input(578) or input(577) or input(576);

slice_or(17) <= input(575) or input(574) or input(573) or input(572) or input(571) or input(570) or input(569) or input(568) or 
                input(567) or input(566) or input(565) or input(564) or input(563) or input(562) or input(561) or input(560) or 
                input(559) or input(558) or input(557) or input(556) or input(555) or input(554) or input(553) or input(552) or 
                input(551) or input(550) or input(549) or input(548) or input(547) or input(546) or input(545) or input(544);

slice_or(16) <= input(543) or input(542) or input(541) or input(540) or input(539) or input(538) or input(537) or input(536) or 
                input(535) or input(534) or input(533) or input(532) or input(531) or input(530) or input(529) or input(528) or 
                input(527) or input(526) or input(525) or input(524) or input(523) or input(522) or input(521) or input(520) or 
                input(519) or input(518) or input(517) or input(516) or input(515) or input(514) or input(513) or input(512);

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

coarse_encoder: priority_encoder_32 port map(slice_or, c_output);

f_input <= 
  input(1023 downto 992)  when c_output = "11111" else
  input(991 downto 960)   when c_output = "11110" else
  input(959 downto 928)   when c_output = "11101" else
  input(927 downto 896)   when c_output = "11100" else
  input(895 downto 864)   when c_output = "11011" else
  input(863 downto 832)   when c_output = "11010" else
  input(831 downto 800)   when c_output = "11001" else
  input(799 downto 768)   when c_output = "11000" else
  input(767 downto 736)   when c_output = "10111" else
  input(735 downto 704)   when c_output = "10110" else
  input(703 downto 672)   when c_output = "10101" else
  input(671 downto 640)   when c_output = "10100" else
  input(639 downto 608)   when c_output = "10011" else
  input(607 downto 576)   when c_output = "10010" else
  input(575 downto 544)   when c_output = "10001" else
  input(543 downto 512)   when c_output = "10000" else
  input(511 downto 480)   when c_output = "1111"  else
  input(479 downto 448)   when c_output = "1110"  else
  input(447 downto 416)   when c_output = "1101"  else
  input(415 downto 384)   when c_output = "1100"  else
  input(383 downto 352)   when c_output = "1011"  else
  input(351 downto 320)   when c_output = "1010"  else
  input(319 downto 288)   when c_output = "1001"  else
  input(287 downto 256)   when c_output = "1000"  else
  input(255 downto 224)   when c_output = "111"   else
  input(223 downto 192)   when c_output = "110"   else
  input(191 downto 160)   when c_output = "101"   else
  input(159 downto 128)   when c_output = "100"   else
  input(127 downto 96)    when c_output = "11"    else
  input(95 downto 64)     when c_output = "10"    else
  input(63 downto 32)     when c_output = "1"     else
  input(31 downto 0);

fine_encoder: priority_encoder_32 port map(f_input, output(g_log2q - 1 downto 0));

output(g_log2n - 1 downto g_log2q) <= c_output(g_log2k - 1 downto 0);
end;