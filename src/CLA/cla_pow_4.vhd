-------------------------------------------------------------------------------------
-- cla_pow_4.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Recursive general component for carry-look-ahead adder.
-- Precision:   Generic, any natural power of 4.
-------------------------------------------------------------------------------------
--
-- This file cannot be used alone; it must be wrapped by a cla_top module.
--
-- Recursively constructs a CLA by instantiating itself until it reaches the
-- base case of 4 bits, at which point it instead generates 4 partial full adders.
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

entity cla_pow_4 is
  generic (
    G_size : integer := 64
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
end cla_pow_4;

architecture behavioral of cla_pow_4 is

  constant G_new_size : integer := G_size / 4;

  -- recursive instantiation requires redeclaring primary entity as a component
  component cla_pow_4 is
    -- seems like scope of generic in component declaration extends to ports
    -- but this is not the case for instantiation
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
  end component;

  component partial_full_adder is
    port (
      a : in    std_logic;
      b : in    std_logic;
      c : in    std_logic;

      g : out   std_logic;
      p : out   std_logic;
      s : out   std_logic
    );
  end component;

  -- Leave sizes below this point hardcoded
  component cla_group_logic is
    port (
      gen_i  : in    std_logic_vector(3 downto 0);
      prop_i : in    std_logic_vector(3 downto 0);
      c_in   : in    std_logic;
      c_i    : out   std_logic_vector(3 downto 1);
      c_out  : out   std_logic;
      prop_g : out   std_logic;
      gen_g  : out   std_logic
    );
  end component;

  signal gen_i, prop_i : std_logic_vector(3 downto 0); -- carry internal signals
  signal carry_i       : std_logic_vector(3 downto 0);

begin

  cla_gl_block : cla_group_logic
    port map (
      gen_i  => gen_i,
      prop_i => prop_i,
      c_in   => c_in,
      c_i    => carry_i(3 downto 1),
      c_out  => c_out,
      prop_g => prop_g,
      gen_g  => gen_g
    );

  carry_i(0) <= c_in;

  gen_cla_recursive : 
  if (G_size > 4) generate
    gen_child_clas :
    for i in 0 to 3 generate
      adder : cla_pow_4
        generic map (
          G_size => G_new_size
        )
        port map ( -- using G_size here would use the current G_size, not the new G_size
          a      => a(((G_new_size * i) + (G_new_size - 1)) downto (G_new_size * i)),
          b      => b(((G_new_size * i) + (G_new_size - 1)) downto (G_new_size * i)),
          c_in   => carry_i(i),
          sum    => sum(((G_new_size * i) + (G_new_size - 1)) downto (G_new_size * i)),
          c_out  => open,
          prop_g => prop_i(i),
          gen_g  => gen_i(i)
        );
    end generate gen_child_clas;
  else generate
    gen_pfas : 
    for i in 0 to 3 generate
      pfa : partial_full_adder
        port map (
          a => a(i),
          b => b(i),
          c => carry_i(i),

          g => gen_i(i),
          p => prop_i(i),
          s => sum(i)
        );
    end generate gen_pfas;  
  end generate gen_cla_recursive;
end architecture behavioral;
 