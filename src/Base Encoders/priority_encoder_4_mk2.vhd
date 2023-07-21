-------------------------------------------------------------------------------------
-- priority_encoder_4_mk2.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips, Hayden Drennen, Nathan Hagerdorn
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Base single-level priority encoder.
-- Precision:   4 bits
-------------------------------------------------------------------------------------
--
-- Returns the floor of the base 2 logarithm of the input,
-- or alternatively, the position of the most significant high bit (MSHB).
-- This is a single-level priority encoder designed to be used as the "base case"
-- of a larger two-level priority encoder (either the "coarse" or "fine" component).
-- This encoder is optimized down to the gate level.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [input]: Self explanatory.
--
-- [output]: Base 2 logarithm or position of MSHB in [input].
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_unsigned.all;

entity priority_encoder_4 is
  port ( 
    input  : in    std_logic_vector(3 downto 0);
    output : out   std_logic_vector(1 downto 0)
  );
end priority_encoder_4;

architecture behavioral of priority_encoder_4 is
begin    

  output(1) <= input(3) or input(2);
  output(0) <= input(3) or (input(1) and not input(2));

end;