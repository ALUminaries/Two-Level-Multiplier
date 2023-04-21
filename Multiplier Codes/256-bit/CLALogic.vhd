library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
entity CLALogic is
    port(
        G, P: in std_logic_vector(3 downto 0);    -- Inputs
        Ci: in std_logic;
        C: out std_logic_vector(3 downto 1);      -- Outputs
        Co, PG, GG: out std_logic
        );
end CLALogic;

architecture Equations of CLALogic is
    signal GG_int, PG_int: std_logic;
    begin
        -- concurrent assignment statements
        C(1) <= G(0) or (P(0) and Ci);
        C(2) <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and Ci);
        C(3) <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or (P(2) and P(1) and P(0) and Ci);
        PG_int <= P(3) and P(2) and P(1) and P(0);
        GG_int <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0));
        Co <= GG_int or (PG_int and Ci);
        PG <= PG_int;
        GG <= GG_int;
end Equations;