-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA512 is
    port(
        A, B: in std_logic_vector(511 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(511 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA512;
architecture Structure of CLA512 is  
    component CLA256 is
        port(
            A, B: in std_logic_vector(255 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(255 downto 0);
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
        LCLA0: CLA256 port map (A(255 downto 0), B(255 downto 0), Ci, S(255 downto 0), open, P(0), G(0));
        LCLA1: CLA256 port map (A(511 downto 256), B(511 downto 256), C(1), S(511 downto 256), open, P(1), G(1));
        -- LCLA2: CLA256 port map (A(767 downto 512), B(767 downto 512), C(2), S(767 downto 512), open, P(2), G(2));
        -- LCLA3: CLA256 port map (A(1023 downto 768), B(1023 downto 768), C(3), S(1023 downto 768), open, P(3), G(3));
end Structure;