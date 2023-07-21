-------------------------------------------------------------------------------------
-- mux_generic.vhd
-------------------------------------------------------------------------------------
-- Source:      https://stackoverflow.com/a/23718796/15080675
--              Modified by Maxwell Phillips @ Ohio Northern University, 2023.
-- Description: Generic multiplexer.
-- Precision:   Generic
-------------------------------------------------------------------------------------
--
-- Returns the floor of the base 2 logarithm of the input,
-- or alternatively, the position of the most significant high bit (MSHB).
-- Composed of a 'coarse' and 'fine' level.
-- The coarse encoder determines which `q` bit slice the MSHB is in.
-- The fine encoder determines where in that slice the MSHB is.
-- Combined, their outputs are equal to the expected primary output.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_entries]: The number of potential selections for the multiplexer.
--
-- [G_entry_width]: The width of each entry (potential selection), in bits.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [input]: The concatenation of all entries in order of selection.
--
-- [sel]: Select signal. Determines which entry to select.
--        Highest value corresponds to most significant entry.
--
-- [output]: Selected entry of size [G_entry_width].
--
-------------------------------------------------------------------------------------
-- Example
-------------------------------------------------------------------------------------
--
-- G_entries     := 4
-- G_entry_width := 4
-- 
-- output <= input(15 downto 12) when sel = "11" else
--           input(11 downto 8)  when sel = "10" else
--           input(7 downto 4)   when sel = "01" else
--           input(3 downto 0);
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;

entity mux_generic is
  generic (
    G_entries     : natural;
    G_entry_width : natural
  );
  port (
    signal input  : in    std_logic_vector(G_entries * G_entry_width - 1 downto 0);
    signal sel    : in    std_logic_vector(natural(round(ceil(log2(real(G_entries))))) - 1 downto 0);
    signal output : out   std_logic_vector(G_entry_width - 1 downto 0)
  );
end mux_generic;

architecture behavioral of mux_generic is

  constant input_width : natural := G_entries * G_entry_width;

  type mux_array is array (natural range 0 to G_entries - 1) of std_logic_vector(output'range);

  signal array_val : mux_array;

begin

  gen : 
  for i in array_val'range generate
    array_val(i) <= input(((input_width - 1) - (G_entry_width * i)) downto (input_width - (G_entry_width * (i + 1))));
  end generate gen;

  -- "normal" order (sel = "11..11" => least significant `G_entry_width` bits of `input`)
  -- output <= array_val(natural(to_integer(unsigned(sel))));

  -- inverted order (sel = "11..11" => most significant `G_entry_width` bits of `input`)
  output <= array_val((G_entries - 1) - natural(to_integer(unsigned(sel))));


end architecture behavioral;
