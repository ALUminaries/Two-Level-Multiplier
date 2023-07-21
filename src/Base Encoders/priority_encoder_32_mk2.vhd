-------------------------------------------------------------------------------------
-- priority_encoder_32_mk2.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips, Hayden Drennen, Nathan Hagerdorn
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Base single-level priority encoder.
-- Precision:   32 bits
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

entity priority_encoder_32 is
  port ( 
    input  : in    std_logic_vector(31 downto 0);
    output : out   std_logic_vector(4 downto 0)
  );
end priority_encoder_32;

architecture behavioral of priority_encoder_32 is
begin
                  
  output(4) <= 
    input(31) or input(30) or input(29) or input(28) or input(27) or input(26) or input(25) or input(24) or
    input(23) or input(22) or input(21) or input(20) or input(19) or input(18) or input(17) or input(16);

  output(3) <= 
    input(31) or input(30) or input(29) or input(28) or input(27) or input(26) or input(25) or input(24) or 
    (
      not (input(23) or input(22) or input(21) or input(20) or input(19) or input(18) or input(17) or input(16)) 
      and (input(15) or input(14) or input(13) or input(12) or input(11) or input(10) or input(9) or input(8))
    );

  output(2) <=
    input(31) or input(30) or input(29) or input(28) or 
    (
      not (input(27) or input(26) or input(25) or input(24)) 
      and (
        input(23) or input(22) or input(21) or input(20) or 
        (
          not (input(19) or input(18) or input(17) or input(16)) 
          and (input(15) or input(14) or input(13) or input(12) or 
            (
              not (input(11) or input(10) or input(9) or input(8))
              and (input(7) or input(6) or input(5) or input(4))
            )
          )
        )
      )
    );

  output(1) <= 
    input(31) or input(30) or 
    (
      not (input(29) or input(28)) 
      and (input(27) or input(26) or 
        (
          not (input(25) or input(24)) 
          and (input(23) or input(22) or 
            (
              not (input(21) or input(20)) 
              and (input(19) or input(18) or 
                (
                  not (input(17) or input(16)) 
                  and (input(15) or input(14) or 
                    (
                      not (input(13) or input(12)) 
                      and (input(11) or input(10) or 
                        (
                          not (input(9) or input(8)) 
                          and (input(7) or input(6) or 
                            (
                              not (input(5) or input(4)) 
                              and (input(3) or input(2))
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    ); 

  output(0) <=
    input(31) or (
      not input(30) and (
        input(29) or (
          not input(28) and (
            input(27) or (
              not input(26) and (
                input(25) or (
                  not input(24) and (
                    input(23) or (
                      not input(22) and (
                        input(21) or (
                          not input(20) and (
                            input(19) or (
                              not input(18) and (
                                input(17) or (
                                  not input(16) and (
                                    input(15) or (
                                      not input(14) and (
                                        input(13) or (
                                          not input(12) and (
                                            input(11) or (
                                              not input(10) and (
                                                input(9) or (
                                                  not input(8) and (
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
                                                  )
                                                )
                                              )
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    );

end architecture behavioral;