-------------------------------------------------------------------------------------
-- Transceiver Hardware Component Container
-------------------------------------------------------------------------------------
-- Author:      Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Container for hardware to be wrapped by serial transceiver.
-------------------------------------------------------------------------------------
--
-- This file is the hardware component container wrapped by the top level
-- serial transceiver. You should modify this file to wrap your hardware
-- in order to utilize it with the transceiver. See the transceiver file
-- for more details on its functionality.
--
-- [!] For the multiplier container: the only thing that needs changed between
--     bit precisions is the component name (in declaration and instantiation).
--     clk_div_bits may also technically need adjusted depending on the difference.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_byte_bits]: Should be 8. Mapped from transceiver.
--
-- [G_total_bits]: The capacity, in bits, of the transceiver.
--                 Mapped directly from the transceiver.
--                 Should be used to help structure hardware components.
--
-- [G_clk_freq]: Should match the clock frequency of the FPGA board.
--               Again, mapped by top-level transceiver.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [clk]: Input clock signal; should match [G_clk_freq] generic.
--
-- [reset]: Asynchronous reset signal. The module should be initially
--          reset automatically by the transceiver, and will remain reset
--          until all bytes are received and the processing stage begins.
--          To preserve state, the hardware is NOT reset after the processing
--          stage and during the transmission stage. This allows you to display
--          output on the LEDs from the hardware container freely.
--
-- [load]: Signal which is received for one clock cycle ([G_clk_freq]) at the
--         beginning of the processing stage, to allow for any hardware setup.
--
-- [start]: Signal which is asserted for as long as the processing stage is active.
--          Will remain high until [done] is asserted.
--
-- [btn_X]: These four signals are mapped to their corresponding buttons
--          on the FPGA development board. By default, left and right are
--          used by the transceiver to display the delay counter on the LEDS.
--          In order to utilize the LEDs for your hardware, you must assert
--          [override_leds] when a button is pressed and set [leds] as desired.
--
-- [switches]: The 16 dip switches on the FPGA development board.
--             For this multiplier, leftmost switch is the Mr sign,
--             and the second leftmost switch is the Md sign.
--
-- [input]: Parallel input of size [G_total_bits] from the transceiver.
--
-- [output]: Parallel output of size [G_total_bits] back to the transceiver.
--
-- [done]: Done signal for the transceiver to terminate the processing stage
--         and begin to transmit the result (from [output]) back over UART.
--
-- [override_leds]: Signal for the transceiver to use [leds] from the hardware
--                  instead of its own display.
--
-- [leds]: Output LEDs. Controlled by the transceiver based on [override_leds].
--         For this multiplier, the rightmost LED is the sign of the product.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_unsigned.all;
  use IEEE.math_real.all;

entity hw_container is
  generic (
    G_byte_bits  : integer;
    G_total_bits : integer;
    G_clk_freq   : integer
  );
  port (
    clk           : in    std_logic; -- board clk
    reset         : in    std_logic; -- async reset which is high when xcvr is not in processing stage
    load          : in    std_logic; -- pseudo-async pulse received from xcvr at the start of processing stage
    start         : in    std_logic; -- consistent signal received from xcvr as long as processing stage is active
    btn_up        : in    std_logic;
    btn_left      : in    std_logic; -- left is by default used for displaying left half of delay counter from xcvr
    btn_right     : in    std_logic; -- right is by default used for displaying right half of delay counter from xcvr
    btn_down      : in    std_logic;
    switches      : in    std_logic_vector(15 downto 0);
    input         : in    std_logic_vector(G_total_bits - 1 downto 0);
    output        : out   std_logic_vector(G_total_bits - 1 downto 0);
    done          : out   std_logic; -- tells xcvr to finish processing stage and transmit back result ([output])
    override_leds : out   std_logic; -- tells xcvr to use [leds] instead of displaying bytes received or delay
    leds          : out   std_logic_vector(15 downto 0)
  );
end hw_container;

architecture behavioral of hw_container is

  -- clock divider
  constant div_clk_bits : integer := 4;

  signal   div_clk         : std_logic;
  signal   div_clk_counter : std_logic_vector(div_clk_bits - 1 downto 0);
  constant div_clk_max     : std_logic_vector(div_clk_bits - 1 downto 0) := (others => '1');

  -- multiplier
  constant g_n : integer := G_total_bits / 2;
  constant g_m : integer := G_total_bits / 2;

  component multiplier_2048 is
    port (
      clk    : in    std_logic;
      start  : in    std_logic;
      reset  : in    std_logic;
      mr     : in    std_logic_vector(g_n - 1 downto 0);
      s_mr   : in    std_logic;
      md     : in    std_logic_vector(g_m - 1 downto 0);
      s_md   : in    std_logic;
      prod   : out   std_logic_vector(g_n + g_m - 1 downto 0);
      s_prod : out   std_logic;
      done   : out   std_logic
    );
  end component;

  -- multiplier data signals
  signal s_mr   : std_logic;
  signal s_md   : std_logic;
  signal s_prod : std_logic;
  signal mag_mr : std_logic_vector(g_n - 1 downto 0);
  signal mag_md : std_logic_vector(g_m - 1 downto 0);
  signal prod   : std_logic_vector(g_n + g_m - 1 downto 0);

  -- multiplier logistics signals
  signal mr_hw_start : std_logic;
  signal mr_hw_reset : std_logic;
  signal mr_hw_done  : std_logic;

begin

  s_mr   <= switches(15);
  mag_mr <= input(input'left downto g_m);
  s_md   <= switches(14);
  mag_md <= input(g_m - 1 downto 0);

  mr_hw_start <= start;
  mr_hw_reset <= reset;
  done        <= mr_hw_done;
  output      <= prod;

  -- clock divider
  div_clk <= '1' when (div_clk_counter(div_clk_counter'left) = '1') else '0';

  process (clk, reset) begin
    if (reset = '1') then
      override_leds   <= '0'; -- IMPORTANT!
      leds            <= (others => '0');
      div_clk_counter <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- clock division logic
      if (div_clk_counter = div_clk_max) then
        div_clk_counter <= (others => '0');
      else
        div_clk_counter <= div_clk_counter + 1;
      end if;

      -- LED multiplexing
      if (btn_down = '1') then
        override_leds     <= '1';
        leds(15)          <= s_mr;
        leds(14)          <= s_md;
        leds(13 downto 1) <= (others => '0');
        leds(0)           <= s_prod;
      else
        override_leds <= '0';
      end if;
    end if;
  end process;

  multiplier : multiplier_2048
    port map (
      clk    => div_clk,
      start  => mr_hw_start,
      reset  => mr_hw_reset,
      mr     => mag_mr,
      s_mr   => s_mr,
      md     => mag_md,
      s_md   => s_md,
      prod   => prod,
      s_prod => s_prod,
      done   => mr_hw_done
    );

end architecture behavioral;
