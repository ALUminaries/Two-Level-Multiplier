-- Authors: Maxwell Phillips, Hayden Drennen, Nathan Hagerdorn
-- Copyright: Ohio Northern University, 2023.
-- License: GPL v3
-- Usage: Component of larger two-level priority encoder. Import this file alongside a TLPE that requires it (look for priority_encoder_<k> in multiplier_<n>_ngen.vhd)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder_8 is
port( 
  input: in std_logic_vector(7 downto 0);
  output: out std_logic_vector(2 downto 0)
);
end priority_encoder_8;

architecture behavioral of priority_encoder_8 is
begin    

output(2)
  <= input(7)
  or input(6)
  or input(5)
  or input(4);

output(1)
  <= input(7)
  or input(6)
  or (
    not (input(5)
      or input(4)
    )
    and (input(3)
      or input(2)
    )
  )
;

output(0) <=
  input(7) or (
    not input(6) and (
      input(5) or (
        not input(4) and (
          input(3) or (
            not input(2) 
            and input(1)
          )
        )
      )
    )
  )
;

end;