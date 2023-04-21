-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA16384 is
    port(
        A, B: in std_logic_vector(16383 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(16383 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA16384;
architecture Structure of CLA16384 is  
    component CLA4096 is
        port(
            A, B: in std_logic_vector(4095 downto 0);
            Ci: in std_logic;
            S: out std_logic_vector(4095 downto 0);
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
        LCLA0: CLA4096 port map (A(4095 downto 0), B(4095 downto 0), Ci, S(4095 downto 0), open, P(0), G(0));
        LCLA1: CLA4096 port map (A(8191 downto 4096), B(8191 downto 4096), C(1), S(8191 downto 4096), open, P(1), G(1));
        LCLA2: CLA4096 port map (A(12287 downto 8192), B(12287 downto 8192), C(2), S(12287 downto 8192), open, P(2), G(2));
        LCLA3: CLA4096 port map (A(16383 downto 12288), B(16383 downto 12288), C(3), S(16383 downto 12288), open, P(3), G(3));
end Structure;