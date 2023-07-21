-------------------------------------------------------------------------------------
-- partial_full_adder.vhd
-------------------------------------------------------------------------------------
-- Authors:     Hayden Drennen
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Standard partial full adder for use in a carry-look-ahead adder.
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [a], [b]: Individual input bits, i.e., the addends.
--
-- [c]: Input carry.
--
-- [g]: Determines whether this bit slice is capable of generating a carry.
--
-- [p]: Determines whether this bit slice is capable of propagating a carry.
--
-- [s]: Sum or result bit.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;

entity partial_full_adder is
  port (
    a : in    std_logic;
    b : in    std_logic;
    c : in    std_logic;

    g : out   std_logic;
    p : out   std_logic;
    s : out   std_logic
  );
end partial_full_adder;

architecture structure of partial_full_adder is

begin

  g <= a and b;
  p <= a xor b;
  s <= a xor b xor c;

end architecture structure;
