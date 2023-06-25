----------------------------------------------------------------------------
-- Primary Transceiver Module, version 7
----------------------------------------------------------------------------
-- Author:      Maxwell Phillips
-- Copyright:   Ohio Northern University, 2023.
-- License:     GPL v3
-- Description: Serial transceiver for use with any hardware.
-- Precision:   512 bits, 64 bytes.
----------------------------------------------------------------------------
--
-- This file is the top-level component for a serial UART RS-232 transceiver.
-- It contains a receiver and transmitter module alongside a hardware 
-- component container/wrapper. The latter is what you should modify to
-- utilize your hardware with this component. Several inputs are passed
-- through to the container. By default, this transceiver also tracks the
-- number of bytes received on the LEDs, and pressing either the left or
-- right button displays either the most significant or least significant
-- half of a 32-bit counter which tracks the number of clock cycles taken
-- by the processing stage. This is used to determine the delay of the
-- hardware inside the container.
--
----------------------------------------------------------------------------
-- Generics
----------------------------------------------------------------------------
--
-- [G_byte_bits]: Should be 8. Do not change.
--
-- [G_bytes]: This determines the capacity of the transciever.
--           It will start the processing stage when it receives this
--           number of bytes, and transmit out this number of bytes
--           after the processing stage is completed.
--
-- [G_total_bits]: Essentially [G_bytes] * [G_byte_bits]. The capacity, in bits, 
--                of the transceiver. Not directly used, but passed through 
--                to the hardware container via a generic map.
--
-- [G_clk_freq]: Should match the clock frequency of the FPGA board.
--
-- [G_sampling_factor]: Factor to oversample by when receiving. Recommended 4-16.
--
-- [G_baud_rate]: Standard baud rate to use. Default 9600.
--
----------------------------------------------------------------------------
-- Ports
----------------------------------------------------------------------------
--
-- [clk]: Input clock signal; should match [G_clk_freq] generic.
--
-- [reset]: Asynchronous reset signal. This component also has an 
--         initial reset signal built-in. This is mapped to the 
--         center button on the FPGA development board.
--
-- [btn_X]: These four signals are mapped to their corresponding buttons
--         on the FPGA development board. By default, left and right 
--         display corresponding halves of the delay counter on the LEDS. 
--         Up and down are passed directly to the hardware container and 
--         can be used for additional LED multiplexing or other purposes.
--
-- [switches]: The 16 dip switches on the FPGA development board. 
--            Passed through to hardware container.
--
-- [input]: Serial UART input pin. Constrain appropriately. Passed to RX.
-- 
-- [output]: Serial UART output pin. Constrain appropriately. Passed to TX.
--
-- [leds]: Output LEDs. Controlled directly by the transceiver depending on
--        how it and the hardware container are configured.
--
----------------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.std_logic_unsigned.all;
  use IEEE.math_real.all;

entity transceiver is
  generic (
    G_byte_bits       : integer := 8;         -- # of bits in a byte. do not change.
    G_bytes           : integer := 64;       -- how many bytes to process/expect
    G_total_bits      : integer := 512;      -- input length
    G_clk_freq        : integer := 100000000; -- board clk
    G_sampling_factor : integer := 4;         -- rx oversampling factor
    G_baud_rate       : integer := 9600
  );
  port (
    clk       : in    std_logic;
    reset     : in    std_logic;
    btn_up    : in    std_logic;
    btn_left  : in    std_logic;
    btn_right : in    std_logic;
    btn_down  : in    std_logic;
    switches  : in    std_logic_vector(15 downto 0);
    input     : in    std_logic;
    output    : out   std_logic;
    leds      : out   std_logic_vector(15 downto 0)
  );
end entity transceiver;

architecture behavioral of transceiver is

  -- initial reset
  -- avoid use of signal initializations elsewhere
  signal init_reset : std_logic := '1';

  -- state machine variables
  type state_type is (
    IDLE,        -- Base idle state (loopable)
    RX_WAIT,     -- Triggered once receiver is active, wait until it has received a byte (loopable)
    RX_INC_BYTE, -- Increment byte counter, load data from `rx_output` into `data_reg` (instantaneous)
    RXD_BYTE,    -- Prepare for next byte (instantaneous)
    RX_DONE,     -- Received all bytes (instantaneous)
    PROC_START,  -- Starts the processing stage (instantaneous)
    PROC_WAIT,   -- Wait for processing to complete (loopable)
    PROC_DONE,   -- Transition to transmission stage (instantaneous)
    TX_LOAD,     -- Load transmitter in parallel (instantaneous)
    TX_SEND,     -- Assert send signal to tx module (instantaneous)
    TX_WAIT,     -- Wait for transmitter to transmit byte (loopable)
    TX_INC_BYTE, -- Increment byte counter, load data from `data_reg` into `tx_input` (instantaneous)
    TXD_BYTE,    -- Prepare for next byte (instantaneous)
    TX_DONE      -- Transmitted all bytes (instantaneous)
  );

  signal state      : state_type;
  signal next_state : state_type;

  -- components
  component rx_module is
    generic (
      G_byte_bits       : integer;
      G_clk_freq        : integer;
      G_sampling_factor : integer;
      G_baud_rate       : integer
    );
    port (
      clk       : in    std_logic;
      reset     : in    std_logic;
      input     : in    std_logic;
      data      : out   std_logic_vector(G_byte_bits - 1 downto 0);
      idle      : out   std_logic;
      receiving : out   std_logic;
      done      : out   std_logic
    );
  end component;

  component tx_module is
    generic (
      G_byte_bits       : integer;
      G_clk_freq        : integer;
      G_baud_rate       : integer
    );
    port (
      clk    : in    std_logic;
      reset  : in    std_logic;
      send   : in    std_logic;
      data   : in    std_logic_vector(G_byte_bits - 1 downto 0);
      ready  : out   std_logic;
      output : out   std_logic
    );
  end component;

  component hw_container is
    generic (
      G_byte_bits       : integer;
      G_clk_freq        : integer;
      G_total_bits      : integer
    );
    port (
      clk           : in    std_logic;
      reset         : in    std_logic;
      load          : in    std_logic;
      start         : in    std_logic;
      btn_up        : in    std_logic;
      btn_left      : in    std_logic;
      btn_right     : in    std_logic;
      btn_down      : in    std_logic;
      switches      : in    std_logic_vector(15 downto 0);
      input         : in    std_logic_vector(G_total_bits - 1 downto 0);
      output        : out   std_logic_vector(G_total_bits - 1 downto 0);
      done          : out   std_logic;
      override_leds : out   std_logic;
      leds          : out   std_logic_vector(15 downto 0)
    );
  end component;

  -- rx controller handling
  signal rx_reset    : std_logic;
  signal rx_idle     : std_logic;
  signal rx_active   : std_logic;
  signal rx_done_sig : std_logic;
  signal rx_output   : std_logic_vector(G_byte_bits - 1 downto 0); -- rx output

  -- tx controller handling
  signal tx_reset    : std_logic;
  signal tx_send_sig : std_logic;
  signal tx_ready    : std_logic;
  signal load_tx_reg : std_logic;
  signal tx_input    : std_logic_vector(G_byte_bits - 1 downto 0); -- tx input

  -- shift register to hold serial IO data, excluding start and stop bits.
  constant data_reg_bits    : integer := G_bytes * G_byte_bits;
  signal   data_reg         : std_logic_vector(data_reg_bits - 1 downto 0);
  signal   shift_data_reg   : std_logic;
  signal   load_data_reg    : std_logic;
  signal   start_processing : std_logic;
  signal   done_processing  : std_logic;

  -- counter to record number of bytes received or transmitted
  -- needs to have (G_bytes + 1) values, so no (-1) on upper bound
  -- 0 is for no bytes received or transmitted yet
  constant log_bytes        : integer := integer(round(ceil(log2(real(G_bytes)))));
  signal   byte_counter     : std_logic_vector(log_bytes downto 0);
  signal   en_byte_counter  : std_logic;
  signal   clr_byte_counter : std_logic;

  -- signals for hardware container
  signal hw_reset         : std_logic;
  signal hw_load          : std_logic;
  signal hw_override_leds : std_logic; -- tells the transceiver to use hw_leds instead
  signal hw_leds          : std_logic_vector(15 downto 0);
  signal hw_output        : std_logic_vector(G_total_bits - 1 downto 0);

  -- hardware delay counter
  signal delay_counter : std_logic_vector(31 downto 0); -- same size as leds

begin

  rx : rx_module
    generic map (
      G_byte_bits       => G_byte_bits,
      G_clk_freq        => G_clk_freq,
      G_sampling_factor => G_sampling_factor,
      G_baud_rate       => G_baud_rate
    )
    port map (
      clk       => clk,
      reset     => rx_reset,
      input     => input,
      data      => rx_output,
      idle      => rx_idle,
      receiving => rx_active,
      done      => rx_done_sig
    );

  tx : tx_module
    generic map (
      G_byte_bits => G_byte_bits,
      G_clk_freq  => G_clk_freq,
      G_baud_rate => G_baud_rate
    )
    port map (
      clk    => clk,
      reset  => tx_reset,
      data   => tx_input,
      output => output,
      ready  => tx_ready,
      send   => tx_send_sig
    );

  hw : hw_container
    generic map (
      G_byte_bits  => G_byte_bits,
      G_total_bits => G_total_bits,
      G_clk_freq   => G_clk_freq
    )
    port map (
      clk           => clk,
      reset         => hw_reset,
      load          => hw_load,
      start         => start_processing,
      btn_up        => btn_up,
      btn_left      => btn_left,
      btn_right     => btn_right,
      btn_down      => btn_down,
      switches      => switches,
      input         => data_reg,
      output        => hw_output,
      done          => done_processing,
      override_leds => hw_override_leds,
      leds          => hw_leds
    );

  process (clk, reset) begin
    if (reset = '1' or init_reset = '1') then
      state         <= IDLE;
      byte_counter  <= (others => '0');
      data_reg      <= (others => '0');
      leds          <= (others => '0');
      tx_input      <= (others => '0');
      delay_counter <= (others => '0');
      init_reset    <= '0';
    elsif (clk'event and clk = '1') then
      state <= next_state;

      if (hw_override_leds = '1') then
        -- use leds from hardware
        leds <= hw_leds;
      elsif (btn_left = '1') then
        -- show delay on leds
        leds <= delay_counter(31 downto 16);
      elsif (btn_right = '1') then
        leds <= delay_counter(15 downto 0);
      else
        -- show byte counter on leds
        leds(byte_counter'left downto 0)      <= byte_counter;
        leds(15 downto byte_counter'left + 1) <= (others => '0');
      end if;

      if (load_tx_reg = '1') then
        tx_input <= data_reg(data_reg'left downto data_reg'left - G_byte_bits + 1);
      end if;

      if (load_data_reg = '1') then
        data_reg <= hw_output;
      elsif (shift_data_reg = '1') then
        data_reg <= data_reg(data_reg'left - G_byte_bits downto 0) & rx_output;
      end if;

      -- handle byte counter
      if (clr_byte_counter = '1') then
        byte_counter <= (others => '0');
      elsif (en_byte_counter = '1') then
        byte_counter <= byte_counter + 1;
      end if;

      -- increment delay counter while processing
      if (start_processing = '1') then
        delay_counter <= delay_counter + 1;
      end if;
    end if;
  end process;

  -- State Machine
  -- Inputs: state, rx_idle, rx_active, rx_done_sig, tx_ready
  -- Outputs: next_state, rx_reset, tx_send_sig, load_tx_reg,
  --          shift_data_reg, load_data_reg, clr_byte_counter, en_byte_counter
  -- Outputs are selected via muxes to make state machine cleaner and more compact.

  -- reset receiver when reset is high or if transmitting
  rx_reset <= '1' when (reset = '1' or init_reset = '1' or
                        state = TX_LOAD or state = TX_SEND or
                        state = TX_WAIT or state = TX_INC_BYTE or
                        state = TXD_BYTE or state = TX_DONE) else '0';

  tx_reset <= '1' when (reset = '1' or init_reset = '1' or rx_reset = '0') else '0';

  load_tx_reg <= '1' when (state = TX_LOAD) else '0';
  tx_send_sig <= '1' when (state = TX_SEND) else '0';

  load_data_reg  <= '1' when (state = PROC_DONE) else '0';
  shift_data_reg <= '1' when (state = RX_INC_BYTE or state = TX_INC_BYTE) else '0';

  clr_byte_counter <= '1' when (state = PROC_START or state = PROC_WAIT or state = PROC_DONE) else '0';
  en_byte_counter  <= '1' when (state = RX_INC_BYTE or state = TX_INC_BYTE) else '0';

  start_processing <= '1' when (state = PROC_START or state = PROC_WAIT) else '0';

  -- this reset is active high. reset hw clock if not processing or transmitting (the latter is to preserve state)
  -- this is also responsive to global async reset, since that sets state directly to idle (might take a cycle though)
  hw_reset <= '1' when (reset = '1' or init_reset = '1' or state = IDLE or state = RX_WAIT or 
                        state = RX_INC_BYTE or state = RXD_BYTE or state = RX_DONE);

  -- load signal during PROC_START state
  hw_load <= '1' when (state = PROC_START) else '0';

  process (state) begin
    case state is
      when IDLE =>
        if (rx_active = '1') then
          next_state <= RX_WAIT;
        else -- input = '1'
          next_state <= IDLE;
        end if;
      -- byte counter disabled but NOT reset
      when RX_WAIT =>
        if (rx_done_sig = '1') then
          next_state <= RX_INC_BYTE;
        else
          next_state <= RX_WAIT;
        end if;
      when RX_INC_BYTE =>
        next_state <= RXD_BYTE;
      -- shift data reg and enable byte counter
      when RXD_BYTE =>
        if (byte_counter = G_bytes) then
          next_state <= RX_DONE;
        else
          next_state <= IDLE;
        end if;
      -- stop shifting and disable byte counter
      when RX_DONE =>
        -- wait for synchronization at the end
        if (rx_idle = '1') then
          next_state <= PROC_START;
        else
          next_state <= RX_DONE;
        end if;
      when PROC_START =>
        next_state <= PROC_WAIT;
      when PROC_WAIT =>
        if (done_processing = '1') then
          next_state <= PROC_DONE;
        else
          next_state <= PROC_WAIT;
        end if;
      when PROC_DONE =>
        next_state <= TX_LOAD;
      when TX_LOAD =>
        next_state <= TX_SEND;
      when TX_SEND =>
        next_state <= TX_WAIT;
      when TX_WAIT =>
        if (tx_ready = '1') then
          next_state <= TX_INC_BYTE;
        else
          next_state <= TX_WAIT;
        end if;
      when TX_INC_BYTE =>
        next_state <= TXD_BYTE;
      when TXD_BYTE =>
        if (byte_counter = G_bytes) then
          next_state <= TX_DONE;
        else
          next_state <= TX_LOAD;
        end if;
      when TX_DONE =>
        if (reset = '1') then
          next_state <= IDLE;
        else
          next_state <= TX_DONE;
        end if;
    end case;
  end process;
end architecture behavioral;