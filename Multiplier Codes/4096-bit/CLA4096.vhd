-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA4096 is
    port(
        A, B: in std_logic_vector(4095 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(4095 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA4096;
architecture Structure of CLA4096 is  
    component CLA1024 is
        port(
            A, B: in std_logic_vector(1023 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(1023 downto 0);
            Co, PG, GG: out std_logic
            );
    end component;

    component CLALogic is
        port(
            G, P: in std_logic_vector(3 downto 0);    -- Inputs
            Ci: in std_logic;
            C: out std_logic_vector(3 downto 1);      -- Outputs
            Co, PG, GG: out std_logic);
    end component;


    signal G, P: std_logic_vector(3 downto 0); -- carry internal signals
    signal C: std_logic_vector(3 downto 1);

    begin
    --instantiate four copies of the GPFullAdder
        CarryLogic: CLALogic port map (G, P, Ci, C, Co, PG, GG);
        LCLA0: CLA1024 port map (A(1023 downto 0), B(1023 downto 0), Ci, S(1023 downto 0), open, P(0), G(0));
        LCLA1: CLA1024 port map (A(2047 downto 1024), B(2047 downto 1024), C(1), S(2047 downto 1024), open, P(1), G(1));
        LCLA2: CLA1024 port map (A(3071 downto 2048), B(3071 downto 2048), C(2), S(3071 downto 2048), open, P(2), G(2));
        LCLA3: CLA1024 port map (A(4095 downto 3072), B(4095 downto 3072), C(3), S(4095 downto 3072), open, P(3), G(3));
end Structure;