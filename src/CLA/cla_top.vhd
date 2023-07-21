-------------------------------------------------------------------------------------
-- cla_top.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Top-level wrapper for carry-look-ahead adder component.
-- Precision:   Generic, any natural power of 2 greater than 8.
-------------------------------------------------------------------------------------
--
-- Customize size by adjusting the [G_size] generic.
--
-- This wrapper is NECESSARY otherwise Vivado will flag illegal recursive instantiation.
--
-- Note: For many use cases, [prop_g] and [gen_g] can be left `open`.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_size]: Size of operands.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [a], [b]: Individual input operands, i.e., the addends.
--
-- [c_in]: Input carry.
--
-- [sum]: Self explanatory.
--
-- [c_out]: Carry-out.
--
-- [prop_g]: Group propagate signal for top-level group logic block.
--
-- [gen_g]: Group generate signal for top-level group logic block.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;

library work;
  use work.all;

entity cla_top is
  generic (
    G_size : integer
  );
  port (
    a      : in    std_logic_vector(G_size - 1 downto 0);
    b      : in    std_logic_vector(G_size - 1 downto 0);
    c_in   : in    std_logic; -- carry in
    sum    : out   std_logic_vector(G_size - 1 downto 0);
    c_out  : out   std_logic; -- carry out
    prop_g : out   std_logic; -- group propagate
    gen_g  : out   std_logic  -- group generate
  );
end cla_top;

architecture behavioral of cla_top is

  -- if size is a power of 4, these two values are equal.
  -- if size is a power of 2, these values are not equal.
  -- the multiplication by 2 is to allow rounding and integer comparison instead of floating-point comparison to avoid the need for relative comparisons and a threshold.
  constant log_4_n_x2       : integer := integer(round(log(x => real(G_size), base => 4.0) * 2.0));
  constant floor_log_4_n_x2 : integer := integer(round(floor(real(log_4_n_x2) / 2.0) * 2.0)); -- have to round and convert oddly otherwise floor will floor down more than it should

begin

  gen_inst :
  if (log_4_n_x2 /= floor_log_4_n_x2) generate
    inst : entity work.cla_pow_2(behavioral)
      generic map (
        G_size => G_size
      )
      port map (
        a      => a,
        b      => b,
        c_in   => c_in,
        sum    => sum,
        c_out  => c_out,
        prop_g => prop_g,
        gen_g  => gen_g
      );
  else generate
    inst : entity work.cla_pow_4(behavioral)
      generic map (
        G_size => G_size
      )
      port map (
        a      => a,
        b      => b,
        c_in   => c_in,
        sum    => sum,
        c_out  => c_out,
        prop_g => prop_g,
        gen_g  => gen_g
      );
  end generate gen_inst;
end architecture behavioral;
