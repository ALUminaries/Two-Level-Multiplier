-- Authors: Riley Jackson, Maxwell Phillips
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: For an n-bit CLA, import CLA<n> and component CLA files (multiples of 4 less than `n`), along with CLALogic.vhd and GPFullAdder.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
entity GPFullAdder is
    port(
        X, Y, Cin: in std_logic;  -- Inputs
        G, P, Sum: out std_logic  -- Outputs
        );
end GPFullAdder;
architecture Equations of GPFullAdder is
    signal P_int: std_logic;
    begin
    -- concurrent assignment statements
        G <= X and Y;
        P <= P_int;
        P_int <= X xor Y;
        Sum <= P_int xor Cin;
end Equations;