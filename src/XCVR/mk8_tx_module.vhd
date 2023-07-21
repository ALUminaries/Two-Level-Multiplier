-------------------------------------------------------------------------------------
-- tx_module.vhd, version 8
-------------------------------------------------------------------------------------
-- Author:  Maxwell Phillips
-- Based on Basys 3 serial transmitter module by Sam Bobrowicz @ Digilent.
-- Source: https://digilent.com/reference/programmable-logic/basys-3/demos/gpio
-------------------------------------------------------------------------------------
--
-- This UART transmitter module is capable of serializing one byte
-- of data and transmitting it over a serial connection.
-- It assumes a UART frame of 8 data bits and 1 stop bit, with no parity.
--
-------------------------------------------------------------------------------------
-- Generics
-------------------------------------------------------------------------------------
--
-- [G_byte_bits] Should be 8. Do not change.
--
-- [G_clk_freq] Should match the clock frequency of the FPGA board.
--
-- [G_baud_rate] Standard baud rate to use. Default 9600.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [clk] Input clock signal; should match [G_clk_freq] generic.
--
-- [reset] Asynchronous reset signal.
--         It is assumed that the module is reset before use.
--
-- [send] The high-level controller should pulse this signal for one
--        clock cycle to begin transmission of a byte.
--        When asserting, [data] must be valid and [ready] should be high.
--
-- [data] The parallel input data to be transmitted.
--
-- [ready] High only when a byte is ready to be sent.
--         Low during transmission.
--
-- [output] Route this to the serial output of the high-level controller.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_unsigned.all;
  use IEEE.math_real.all;

entity tx_module is
  generic (
    G_byte_bits : integer := 8;         -- UART RS-232 uses 8 bits or 1 byte of data
    G_clk_freq  : integer := 100000000; -- FPGA clock frequency
    G_baud_rate : integer := 9600
  );
  port (
    clk    : in    std_logic;
    reset  : in    std_logic;
    send   : in    std_logic;
    data   : in    std_logic_vector(G_byte_bits - 1 downto 0);
    ready  : out   std_logic;
    output : out   std_logic
  );
end entity tx_module;

architecture behavioral of tx_module is

  -------------------
  -- State Machine --
  -------------------

  type state_type is (
    TX_READY,    -- Base waiting state (loopable)
    TX_SEND_BIT, -- Loads bit from `packet_reg` into `bit_buffer` (instantaneous)
    TX_WAIT_SYNC -- Waits until `tx_clk_counter` reaches maximum, then either prepares to send another bit or returns to the ready state (loopable)
  );

  signal state, next_state : state_type;

  --------------------------------------
  -- Transmitter Clock Division Logic --
  --------------------------------------

  -- we divide the system clock frequency by `tx_clk_max`
  -- to get a frequency equal to the baud rate.
  -- the resultant frequency is implemented using `tx_clk_counter`.
  -- this allows us to remain synchronized appropriately.
  constant tx_clk_max      : integer := G_clk_freq / G_baud_rate;
  constant bits_tx_counter : integer := integer(ceil(log2(real(tx_clk_max)))); -- don't round this

  signal tx_clk_counter : std_logic_vector(bits_tx_counter - 1 downto 0); -- clocked at baud rate

  signal en_tx_clk_counter  : std_logic;
  signal clr_tx_clk_counter : std_logic;
  signal tx_clk_tick        : std_logic; -- high when tx_clk_counter reaches maximum

  -------------------------------
  -- General Transmitter Logic --
  -------------------------------

  -- number of bits in a packet. 1 start, 8 data, 1 stop.
  constant packet_bits : integer := G_byte_bits + 2;

  -- data register containing the entire data packet to be sent, including start and stop bits.
  signal packet_reg : std_logic_vector(packet_bits - 1 downto 0);

  -- index of the next bit in `packet_reg` to be transmitted
  signal packet_index : natural range 0 to packet_bits;

  -- register holding the current data being sent to [output]
  signal bit_buffer : std_logic; -- initially reset to high since RS-232 idle is high

begin

  -------------------------
  -- Combinational Logic --
  -------------------------

  output      <= bit_buffer; -- serial output always takes the value of the buffer
  ready       <= '1' when (state = TX_READY) else '0';
  tx_clk_tick <= '1' when (tx_clk_counter = tx_clk_max) else '0';

  -------------------
  -- Clock Process --
  -------------------
  process (clk) begin
    if (reset = '1') then
      -- reset all counters and go to idle state
      state          <= TX_READY;
      tx_clk_counter <= (others => '0');
      packet_reg     <= (others => '0');
      packet_index   <= 0;
      bit_buffer     <= '1';
    elsif (clk'event and clk = '1') then
      state <= next_state;

      -- load `packet_reg`` when [send] is received
      if (send = '1') then
        packet_reg <= '1' & data & '0';
      end if;

      -- load `bit_buffer` to send bit to [output]
      -- handle bit index / counting
      if (state = TX_READY) then
        bit_buffer   <= '1';
        packet_index <= 0;
      elsif (state = TX_SEND_BIT) then
        bit_buffer   <= packet_reg(packet_index);
        packet_index <= packet_index + 1;
      end if;

      -- handle transmitter clock and sample counter
      if (clr_tx_clk_counter = '1') then
        tx_clk_counter <= (others => '0');
      elsif (en_tx_clk_counter = '1') then
        tx_clk_counter <= tx_clk_counter + 1;
      end if;
    end if;
  end process;

  -------------------
  -- State Machine --
  -------------------
  clr_tx_clk_counter <= '1' when (state = TX_READY or tx_clk_tick = '1') else '0';
  en_tx_clk_counter  <= '0' when (state = TX_READY) else '1';

  process (state) begin
    case state is
      when TX_READY =>
        if (send = '1') then
          next_state <= TX_SEND_BIT;
        else
          next_state <= TX_READY;
        end if;

      when TX_SEND_BIT =>
        next_state <= TX_WAIT_SYNC;

      when TX_WAIT_SYNC =>
        if (tx_clk_tick = '1') then
          if (packet_index = packet_bits) then
            next_state <= TX_READY;
          else
            next_state <= TX_SEND_BIT;
          end if;
        else
          next_state <= TX_WAIT_SYNC;
        end if;

      when others => -- should never be reached
        next_state <= TX_READY;
    end case;
  end process;
end architecture behavioral;
