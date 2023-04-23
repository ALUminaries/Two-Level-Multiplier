-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA128 is
    port(
        A, B: in std_logic_vector(127 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(127 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA128;
architecture Structure of CLA128 is  
    component CLA64 is
        port(
            A, B: in std_logic_vector(63 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(63 downto 0);
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
    --instantiate four copies of the child adder
        CarryLogic: CLALogic port map (G, P, Ci, C, Co, PG, GG);
        LCLA0: CLA64 port map (A(63 downto 0), B(63 downto 0), Ci, S(63 downto 0), open, P(0), G(0));
        LCLA1: CLA64 port map (A(127 downto 64), B(127 downto 64), C(1), S(127 downto 64), open, P(1), G(1));
        -- LCLA2: CLA64 port map (A(191 downto 128), B(191 downto 128), C(2), S(191 downto 128), open, P(2), G(2));
        -- LCLA3: CLA64 port map (A(255 downto 192), B(255 downto 192), C(3), S(255 downto 192), open, P(3), G(3));
end Structure;