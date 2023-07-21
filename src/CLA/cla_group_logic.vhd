-------------------------------------------------------------------------------------
-- cla_group_logic.vhd
-------------------------------------------------------------------------------------
-- Authors:     Hayden Drennen, Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Group logic block handling 4 PFAs or lower-level CLAs.
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [gen_i]: Input generate signals from PFAs or lower-level CLAs.
--
-- [prop_i]: Input propagate signals from PFAs or lower-level CLAs.
--
-- [c_in]: Input carry.
--
-- [c_i]: Individual carry-in signals for input to each PFA or lower-level CLA,
--        except the first (note the size range of 3 downto 1).
--
-- [c_out]: Group carry out signal.
--
-- [prop_g]: Determines whether this group is capable of propagating a carry.
--
-- [gen_g]: Determines whether this group is capable of generating a carry.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity cla_group_logic is
  port (
    gen_i  : in    std_logic_vector(3 downto 0);
    prop_i : in    std_logic_vector(3 downto 0);
    c_in   : in    std_logic;
    c_i    : out   std_logic_vector(3 downto 1);
    c_out  : out   std_logic;
    prop_g : out   std_logic;
    gen_g  : out   std_logic
  );
end cla_group_logic;

architecture behavioral of cla_group_logic is

  signal generate_group, propagate_group : std_logic;

  -- carries for each individual adder connected to this block
  signal carries : std_logic_vector(3 downto 1);

begin

  carries(1) <= gen_i(0) or
                (prop_i(0) and c_in);

  carries(2) <= gen_i(1) or
                (prop_i(1) and gen_i(0)) or
                (prop_i(1) and prop_i(0) and c_in);

  carries(3) <= gen_i(2) or
                (prop_i(2) and gen_i(1)) or
                (prop_i(2) and prop_i(1) and gen_i(0)) or
                (prop_i(2) and prop_i(1) and prop_i(0) and c_in);

  propagate_group <= prop_i(3) and prop_i(2) and prop_i(1) and prop_i(0);

  generate_group <= gen_i(3) or
                    (prop_i(3) and gen_i(2)) or
                    (prop_i(3) and prop_i(2) and gen_i(1)) or
                    (prop_i(3) and prop_i(2) and prop_i(1) and gen_i(0));

  c_out <= generate_group or (propagate_group and c_in);

  c_i    <= carries;
  prop_g <= propagate_group;
  gen_g  <= generate_group;

end architecture behavioral;
