-------------------------------------------------------------------------------------
-- rx_module.vhd, version 7
-------------------------------------------------------------------------------------
-- Author:  Maxwell Phillips
-------------------------------------------------------------------------------------
--
-- This is a single-byte receiver module for UART transmission.
-- It listens to the [input] port (serial in) and samples `G_sampling_factor`
-- times faster than the baud rate (default 9600).
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
-- [G_sampling_factor] Factor to oversample by. Recommended 4-16.
--
-- [G_baud_rate] Standard baud rate to use. Default 9600.
--
-------------------------------------------------------------------------------------
-- Ports
-------------------------------------------------------------------------------------
--
-- [clk] Input clock signal; should match `G_clk_freq` generic.
--
-- [reset] Asynchronous reset signal.
--         It is assumed that the module is reset before use.
--
-- [input] Route this to the serial input of the high-level controller.
--
-- [data] The parallelized data. Is valid once [done] goes high.
--
-- [done] High when [data] is valid and a byte has been received.
--
-------------------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_unsigned.all;
  use IEEE.math_real.all;

entity rx_module is
  generic (
    G_byte_bits       : integer := 8;         -- UART RS-232 uses 8 bits or 1 byte of data
    G_clk_freq        : integer := 100000000; -- FPGA clock frequency
    G_sampling_factor : integer := 4;         -- for oversampling
    G_baud_rate       : integer := 9600
  );
  port (
    clk       : in    std_logic;
    reset     : in    std_logic;
    input     : in    std_logic; -- serial input. UART starts transmission on low input
    data      : out   std_logic_vector(G_byte_bits - 1 downto 0);
    idle      : out   std_logic;
    receiving : out   std_logic;
    done      : out   std_logic
  );
end entity rx_module;

architecture behavioral of rx_module is

  -------------------
  -- State Machine --
  -------------------
  type state_type is (
    RX_IDLE,        -- Base idle state (loopable)
    RX_WAIT_BEFORE, -- Waiting state before sampling (loopable)
    RX_SAMPLE,      -- State of actively sampling (instantaneous)
    RX_WAIT_AFTER,  -- Waiting state after sampling to avoid unintentional multisampling/shifting (loopable)
    RXD_BYTE        -- Reset bit counter and go back to idle state after synchronizing (loopable)
  );

  signal state,               next_state : state_type := RX_IDLE;
  signal idle_int                        : std_logic; -- high when state is RX_IDLE, used as a buffer for [idle]

  -----------------
  -- Bit Counter --
  -----------------

  -- maximum value of the bit counter. 1 start, (G_byte_bits) data, 1 stop.
  constant packet_bits     : integer := G_byte_bits + 2;
  constant log_packet_bits : integer := integer(round(ceil(log2(real(packet_bits)))));

  -- clears and increments here are active high
  -- count up to n + 2 for UART receieving
  -- i.e., once we get a low input, the next n + 1 bits will be data,
  -- then a stop bit at the end. so, we need a counter for that
  -- 0 is for no bits recieved or transmitted yet
  signal bit_counter                          : std_logic_vector(log_packet_bits downto 0) := (others => '0');
  signal en_bit_counter,      clr_bit_counter : std_logic;

  --------------------
  -- Sample Counter --
  --------------------

  -- counter for oversampling for receiver
  -- ex. if G_sampling_factor = 4, we are oversampling 4x
  constant log_sample                            : integer                                   := integer(round(ceil(log2(real(G_sampling_factor)))));
  constant sample_counter_max                    : integer                                   := G_sampling_factor - 1;
  constant mid_sample                            : integer                                   := G_sampling_factor / 2;
  signal   sample_counter                        : std_logic_vector(log_sample - 1 downto 0) := (others => '0');
  signal   en_sample_counter, clr_sample_counter : std_logic;

  -----------------------------------
  -- Receiver Clock Division Logic --
  -----------------------------------

  -- we divide the system clock frequency by `RX_CLK_MAX` to get
  -- a frequency `G_sampling_factor` times higher than the baud rate.
  -- the resultant frequency is implemented using `rx_clk_counter`.
  -- this allows us to sample the middle of the wave, which is stable.
  -- ex. if G_sampling_factor = 4, we are oversampling 4x, and slow clk runs 4x faster than the baud rate.
  constant rx_clk_max      : integer := G_clk_freq / (G_baud_rate * G_sampling_factor);
  constant bits_rx_counter : integer := integer(ceil(log2(real(rx_clk_max)))); -- don't round this

  -- clocked `G_sampling_factor` times faster than baud rate
  signal rx_clk_counter     : std_logic_vector(bits_rx_counter - 1 downto 0) := (others => '0');
  signal en_rx_clk_counter  : std_logic;
  signal clr_rx_clk_counter : std_logic;

  -------------------
  -- Data Register --
  -------------------

  -- shift register to hold serial IO data, excluding start and stop bits.
  signal data_reg : std_logic_vector(G_byte_bits - 1 downto 0) := (others => '0');
  signal shift    : std_logic; -- whether to shift the data register or load the output

begin

  process (clk, reset) begin
    if (reset = '1') then
      -- reset all counters and go to idle state
      state          <= RX_IDLE;
      bit_counter    <= (others => '0');
      sample_counter <= (others => '0');
      rx_clk_counter <= (others => '0');
      data_reg       <= (others => '0');
      data           <= (others => '0');
    elsif (clk'event and clk = '1') then
      state <= next_state;

      -- shift in
      if (shift = '1') then
        data_reg <= input & data_reg(data_reg'left downto 1);
      end if;

      if (state = RXD_BYTE) then
        data <= data_reg;
      end if;

      -- bit counter
      if (clr_bit_counter = '1') then
        bit_counter <= (others => '0');
      elsif (en_bit_counter = '1') then
        bit_counter <= bit_counter + 1;
      end if;

      -- handle receiver clock and sample counter
      if (clr_rx_clk_counter = '1') then
        rx_clk_counter <= (others => '0');
      elsif (rx_clk_counter >= rx_clk_max) then
        rx_clk_counter <= (others => '0');
        if (clr_sample_counter = '1' or sample_counter >= sample_counter_max) then
          sample_counter <= (others => '0');
        elsif (en_sample_counter = '1') then
          sample_counter <= sample_counter + 1;
        end if;
      elsif (en_rx_clk_counter = '1') then
        rx_clk_counter <= rx_clk_counter + 1;
      end if;
    end if;
  end process;

  -- | Port      | IDLE | WAIT_BEFORE | SAMPLE | WAIT_AFTER | RXD_BYTE |
  -- | --------- | ---- | ----------- | ------ | ---------- | -------- |
  -- | data      | prev | prev        | prev   | prev       | data_reg |
  -- | idle      | 1    | 0           | 0      | 0          | 0        |
  -- | receiving | 0    | prev        | prev   | 1          | 0        |
  -- | done      | 0    | 0           | 0      | 0          | 1        |

  idle <= idle_int;
  done <= '1' when (state = RXD_BYTE) else '0';

  -- | Signal             | IDLE | WAIT_BEFORE | SAMPLE | WAIT_AFTER | RXD_BYTE |
  -- | ------------------ | ---- | ----------- | ------ | ---------- | -------- |
  -- | idle_int           | 1    | 0           | 0      | 0          | 0        |
  -- | clr_rx_clk_counter | 1    | 0           | 0      | 0          | 0        |
  -- | en_rx_clk_counter  | 0    | 1           | 1      | 1          | 1        |
  -- | clr_sample_counter | 1    | 0           | 0      | 0          | 0        |
  -- | en_sample_counter  | 0    | 1           | 1      | 1          | 1        |
  -- | clr_bit_counter    | 1    | 0           | 0      | 0          | 1        |
  -- | en_bit_counter     | 0    | 0           | 1      | 0          | 0        |
  -- | shift              | 0    | 0           | 1/0    | 0          | 0        |

  idle_int           <= '1' when (state = RX_IDLE) else '0';
  clr_rx_clk_counter <= idle_int;
  en_rx_clk_counter  <= not idle_int;
  clr_sample_counter <= idle_int;
  en_sample_counter  <= not idle_int;
  clr_bit_counter    <= '1' when (state = RX_IDLE or state = RXD_BYTE) else '0';
  en_bit_counter     <= '1' when (state = RX_SAMPLE) else '0';

  process (state) begin
    case state is
      when RX_IDLE =>
        if (input = '0') then
          next_state <= RX_WAIT_BEFORE;
        else -- input = '1'
          next_state <= RX_IDLE;
        end if;

        -- [Outputs]
        -- rx counter disabled and reset
        -- sample counter disabled and reset
        -- bit counter disabled and reset
        receiving <= '0';
        shift     <= '0';

      when RX_WAIT_BEFORE =>
        if (sample_counter = mid_sample) then
          next_state <= RX_SAMPLE;
        else
          next_state <= RX_WAIT_BEFORE;
        end if;

        -- [Outputs]
        -- rx counter enabled [!]
        -- sample counter enabled [!]
        -- bit counter disabled
        -- don't set `receiving` here
        shift <= '0';

      when RX_SAMPLE =>
        -- test if we have an erroneous start or stop bit
        -- at this point, bit counter has not been incremented
        -- so when we're sampling the nth bit , bit_counter = n - 1.
        if ((bit_counter = 0 and input = '1') or (bit_counter = packet_bits - 1 and input = '0')) then
          next_state <= RX_IDLE;
        else -- otherwise proceed to RX_WAIT_AFTER
          next_state <= RX_WAIT_AFTER;
        end if;

        -- [Outputs]
        -- rx counter enabled
        -- sample counter enabled
        -- bit counter enabled [!]
        -- don't set `receiving` here
        if (bit_counter > 0 and bit_counter < packet_bits - 1) then
          shift <= '1'; -- [!]
        else
          shift <= '0';
        end if;

      when RX_WAIT_AFTER =>
        if (sample_counter = 0) then
          -- only sample once, then loop until sample counter resets to keep synchronization
          if (bit_counter = packet_bits) then
            next_state <= RXD_BYTE;
          else
            next_state <= RX_WAIT_BEFORE;
          end if;
        else
          next_state <= RX_WAIT_AFTER;
        end if;

        -- [Outputs]
        -- rx counter enabled
        -- sample counter enabled
        -- bit counter disabled [!]
        receiving <= '1';
        shift     <= '0'; -- [!]

      when RXD_BYTE =>
        next_state <= RX_IDLE;

        -- [Outputs]
        -- rx counter enabled
        -- sample counter enabled
        -- bit counter disabled and reset
        receiving <= '0';
        shift     <= '0';

      when others => -- should never happen
        next_state <= RX_IDLE;
    end case;
  end process;
end architecture behavioral;
