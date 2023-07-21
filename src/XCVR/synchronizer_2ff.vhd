-------------------------------------------------------------------------------------
-- synchronizer-2ff.vhd
-------------------------------------------------------------------------------------
-- Authors:     Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Simple two-flip-flop CDC synchronizer.
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;

entity synchronizer_2ff is
  port (
    input    : in    std_logic;
    dest_clk : in    std_logic;
    reset    : in    std_logic;
    output   : out   std_logic
  );
end synchronizer_2ff;

architecture behavioral of synchronizer_2ff is

  component d_flip_flop is
    port (
      input  : in    std_logic;
      clk    : in    std_logic;
      reset  : in    std_logic;
      output : out   std_logic
    );
  end component;

  signal q1_to_d2 : std_logic;

begin

  sync_ff_1 : d_flip_flop
    port map (
      input  => input,
      clk    => dest_clk,
      reset  => reset,
      output => q1_to_d2
    );

  sync_ff_2 : d_flip_flop
    port map (
      input  => q1_to_d2,
      clk    => dest_clk,
      reset  => reset,
      output => output
    );

end architecture behavioral;
