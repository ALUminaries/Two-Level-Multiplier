-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA16 is
    port(
        A, B: in std_logic_vector(15 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(15 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA16;
architecture Structure of CLA16 is  
    component CLA4 is
        port(
            A, B: in std_logic_vector(3 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(3 downto 0);
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
        LCLA0: CLA4 port map (A(3 downto 0), B(3 downto 0), Ci, S(3 downto 0), open, P(0), G(0));
        LCLA1: CLA4 port map (A(7 downto 4), B(7 downto 4), C(1), S(7 downto 4), open, P(1), G(1));
        LCLA2: CLA4 port map (A(11 downto 8), B(11 downto 8), C(2), S(11 downto 8), open, P(2), G(2));
        LCLA3: CLA4 port map (A(15 downto 12), B(15 downto 12), C(3), S(15 downto 12), open, P(3), G(3));
end Structure;