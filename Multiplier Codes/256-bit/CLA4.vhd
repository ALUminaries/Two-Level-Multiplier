-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import this file and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity CLA4 is
    port(
        A, B: in std_logic_vector(3 downto 0);
        Ci: in std_logic;
        S: out std_logic_vector(3 downto 0);
        Co, PG, GG: out std_logic
        );
end CLA4;
architecture Structure of CLA4 is  
    component GPFullAdder
        port(
            X, Y, Cin: in std_logic;  -- Inputs
            G, P, Sum: out std_logic  -- Outputs
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
        FA0: GPFullAdder port map (A(0), B(0), Ci, G(0), P(0), S(0));
        FA1: GPFullAdder port map (A(1), B(1), C(1), G(1), P(1), S(1));
        FA2: GPFullAdder port map (A(2), B(2), C(2), G(2), P(2), S(2));
        FA3: GPFullAdder port map (A(3), B(3), C(3), G(3), P(3), S(3));
end Structure;