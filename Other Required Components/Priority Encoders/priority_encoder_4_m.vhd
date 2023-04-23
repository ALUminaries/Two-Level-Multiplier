-- Authors: Maxwell Phillips, Hayden Drennen, Nathan Hagerdorn
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: Component of larger two-level priority encoder. Import this file alongside a TLPE that requires it (look for priority_encoder_<k> in multiplier_<n>_ngen.vhd)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_4 is
port( 
  input: in std_logic_vector(3 downto 0);
  output: out std_logic_vector(1 downto 0)
);
end priority_encoder_4;

architecture behavioral of priority_encoder_4 is
begin    

output(1) <= input(3) or input(2);
output(0) <= input(3) or (input(1) and not input(2));

end;