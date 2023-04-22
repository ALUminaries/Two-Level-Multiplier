----------------------------------------------------------------------------
--	rx_module.vhd 
----------------------------------------------------------------------------
-- Author:  Maxwell Phillips
----------------------------------------------------------------------------
-- This is a single-byte receiver module for UART transmission.
-- It listens to the [input] port (serial in) and samples `sampling_factor`
-- times faster than the baud rate (default 9600).
-- It assumes a UART frame of 8 data bits and 1 stop bit, with no parity.
--         				
-- Ports:
-- [clk] Input clock signal; should match `clk_freq` generic.
-- 
-- [reset] Asynchronous reset signal.
--
-- [input] Route this to the serial input of the high-level controller.
-- 
-- [data] The parallel data received. Is valid once [done] goes high.
-- 
-- [done] High when [data] is valid and a byte has been received.
--   
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

entity rx_controller is
  generic(
    bits: integer := 8;  -- UART RS-232 uses 8 bits or 1 byte of data
    clk_freq: integer := 100000000; -- FPGA clock frequency
    sampling_factor: integer := 4; -- for oversampling
    baud_rate: integer := 9600
  );
  port( 
    clk: in std_logic;
    reset: in std_logic;
    input: in std_logic; -- serial input. UART starts transmission on low input
    data: out std_logic_vector(bits - 1 downto 0);
    idle: out std_logic;
    receiving: out std_logic;
    done: out std_logic
  );
end rx_controller;

architecture behavioral of rx_controller is
  type state_type is (
    RX_IDLE, -- Base idle state (loopable)
    RX_WAIT_BEFORE, -- Waiting state before sampling (loopable)
    RX_SAMPLE, -- State of actively sampling (instantaneous)
    RX_WAIT_AFTER, -- Waiting state after sampling to avoid unintentional multisampling/shifting (loopable)
    RXD_BYTE -- Reset bit counter and go back to idle state after synchronizing (loopable)
  );

  signal state, next_state: state_type;

  -- shift register to hold serial IO data, excluding start and stop bits.
  signal data_reg: std_logic_vector(bits - 1 downto 0);
  signal shift: std_logic; -- whether to shift the data register or load the output 

  -- maximum value of the bit counter. 1 start, (bits) data, 1 stop.
  constant PACKET_BITS: integer := bits + 2; 
  constant LOG_PACKET_BITS: integer := integer(round(ceil(log2(real(PACKET_BITS)))));

  -- clears and increments here are active high
  -- count up to n + 2 for UART receieving
  -- i.e., once we get a low input, the next n + 1 bits will be data,
  -- then a stop bit at the end. so, we need a counter for that
  -- 0 is for no bits recieved or transmitted yet
  signal bit_counter: std_logic_vector(LOG_PACKET_BITS downto 0);
  signal en_bit_counter, clr_bit_counter: std_logic;

  -- counter for oversampling for receiver
  -- ex. if sampling_factor = 4, we are oversampling 4x
  constant LOG_SAMPLE: integer := integer(round(ceil(log2(real(sampling_factor)))));
  constant sample_counter_max: integer := sampling_factor - 1;
  constant mid_sample: integer := sampling_factor / 2;
  signal sample_counter: std_logic_vector(LOG_SAMPLE - 1 downto 0);
  signal en_sample_counter,  clr_sample_counter: std_logic;

  -- receiver clock division logic:
  -- we divide the system clock frequency by `div_factor_rx` to get
  -- a frequency `sampling_factor` times higher than the baud rate.
  -- the resultant frequency is implemented using `rx_clk_counter`.
  -- this allows us to sample the middle of the wave, which is stable.
  -- ex. if sampling_factor = 4, we are oversampling 4x, and slow clk runs 4x faster than the baud rate.
  constant div_factor_rx: integer := clk_freq / (baud_rate * sampling_factor);
  constant bits_rx_counter: integer := integer(ceil(log2(real(div_factor_rx)))); -- don't round this
  signal rx_clk_counter: std_logic_vector(bits_rx_counter - 1 downto 0); -- clocked `sampling_factor` times faster than baud rate
  signal en_rx_clk_counter, clr_rx_clk_counter: std_logic;

  -- shorthand for n zeroes
  constant n_0s: std_logic_vector(bits - 1 downto 0) := (others => '0'); 

  signal initialReset: std_logic := '0';

begin
  process (clk, reset) begin
    if (reset = '1' or initialReset = '0') then
      -- reset all counters and go to idle state
      state <= RX_IDLE;
      bit_counter <= (others => '0');
      sample_counter <= (others => '0');
      rx_clk_counter <= (others => '0');
      data_reg <= (others => '0');
      data <= (others => '0');
      initialReset <= '1';
    elsif (clk'event and clk = '1') then
      -- state takes next state on fast clock, allows ultimate control over processing
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
      elsif (rx_clk_counter >= div_factor_rx) then
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

  -- States
  -- RX_IDLE, RX_WAIT_BEFORE, RX_SAMPLE, RX_WAIT_AFTER, RX_INC_BYTE, RXD_BYTE, RX_DONE
  
  idle <= '1' when (state = RX_IDLE) else '0';
  done <= '1' when (state = RXD_BYTE) else '0';

  process (state) begin
    case state is
      when RX_IDLE =>
        if (input = '0') then
          next_state <= RX_WAIT_BEFORE;
        else -- input = '1'
          next_state <= RX_IDLE;
        end if;

        -- Outputs
        shift <= '0';

        -- rx counter disabled and reset
        clr_rx_clk_counter <= '1';
        en_rx_clk_counter <= '0';

        -- sample counter disabled and reset
        clr_sample_counter <= '1';
        en_sample_counter <= '0';

        -- bit counter disabled and reset
        clr_bit_counter <= '1';
        en_bit_counter <= '0';

        receiving <= '0';
     
      when RX_WAIT_BEFORE =>
        if (sample_counter = mid_sample) then
          next_state <= RX_SAMPLE;
        else
          next_state <= RX_WAIT_BEFORE;
        end if;

        -- Outputs
        shift <= '0';

        -- rx counter enabled [!]
        clr_rx_clk_counter <= '0';
        en_rx_clk_counter <= '1';

        -- sample counter enabled [!]
        clr_sample_counter <= '0';
        en_sample_counter <= '1';

        -- bit counter disabled
        clr_bit_counter <= '0';
        en_bit_counter <= '0';

        -- don't set `receiving` here

      when RX_SAMPLE =>
        -- test if we have an erroneous start or stop bit
        -- at this point, bit counter has not been incremented
        -- so when we're sampling the nth bit , bit_counter = n - 1.
        if ((bit_counter = 0 and input = '1') or (bit_counter = PACKET_BITS - 1 and input = '0')) then
          next_state <= RX_IDLE;
        else -- otherwise proceed to RX_WAIT_AFTER
          next_state <= RX_WAIT_AFTER;
        end if;

        -- Outputs
        if (bit_counter > 0 and bit_counter < PACKET_BITS - 1) then
          shift <= '1'; -- [!]
        else
          shift <= '0';
        end if;

        -- rx counter enabled
        clr_rx_clk_counter <= '0';
        en_rx_clk_counter <= '1';
        
        -- sample counter enabled
        clr_sample_counter <= '0';
        en_sample_counter <= '1';

        -- bit counter enabled [!]
        clr_bit_counter <= '0';
        en_bit_counter <= '1';

        -- don't set `receiving` here

      when RX_WAIT_AFTER =>
        if (sample_counter = 0) then
          -- only sample once, then loop until sample counter resets to keep synchronization
          if (bit_counter = PACKET_BITS) then
            next_state <= RXD_BYTE;
          else
            next_state <= RX_WAIT_BEFORE;
          end if;
        else
          next_state <= RX_WAIT_AFTER;
        end if; 

        -- Outputs
        shift <= '0'; -- [!]

        -- rx counter enabled
        clr_rx_clk_counter <= '0';
        en_rx_clk_counter <= '1';

        -- sample counter enabled
        clr_sample_counter <= '0';
        en_sample_counter <= '1';

        -- bit counter disabled [!]
        clr_bit_counter <= '0';
        en_bit_counter <= '0';

        receiving <= '1';
        
      when RXD_BYTE =>
        next_state <= RX_IDLE;

        -- Outputs
        shift <= '0';

        -- rx counter enabled
        clr_rx_clk_counter <= '0';
        en_rx_clk_counter <= '1';

        -- sample counter enabled
        clr_sample_counter <= '0';
        en_sample_counter <= '1';

        -- bit counter disabled and reset
        clr_bit_counter <= '1';
        en_bit_counter <= '0';

        receiving <= '0';
        
      when others => -- should never happen
        next_state <= RX_IDLE;
    end case;
  end process;
end architecture behavioral;