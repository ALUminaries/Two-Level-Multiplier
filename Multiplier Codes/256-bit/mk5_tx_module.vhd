----------------------------------------------------------------------------
--	tx_module.vhd -- UART data Transfer Component
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- This component may be used to transfer data over a UART device. It will
-- serialize a byte of data and transmit it over a TXD line. The serialized
-- data has the following characteristics:
--    * 9600 Baud Rate
--    * 8 data bits, LSB first
--    * 1 stop bit
--    * no parity
--         				
-- Port Descriptions:
-- 
-- [send]
-- Used to trigger a send operation. The upper layer logic should 
-- set this signal high for a single clock cycle to trigger a 
-- send. When this signal is set high data must be valid. 
-- Should not be asserted unless ready is high.
-- 
-- [data]
-- The parallel data to be sent. Must be valid during 
-- the clock cycle that send has gone high.
-- 
-- [clk] A 100 MHz clock is expected.
--
-- [ready]
-- This signal goes low once a send operation has begun and
-- remains low until it has completed and the module is ready to
-- send another byte.
-- 
-- [serial_out]
-- This signal should be routed to the appropriate TX pin 
-- of the external UART device.
--   
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011 (SamB): Created using Xilinx Tools 13.2
--  04/10/2023 (MaxP): Borrowed from Basys 3 examples; cleaned up code.
----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tx_controller is
  generic(
    bits: integer := 8
  );
  port( 
    clk: in std_logic;
    send: in std_logic;
    data: in std_logic_vector (bits - 1 downto 0);
    ready: out std_logic;
    serial_out: out std_logic
  );
end tx_controller;

architecture behavioral of tx_controller is
  type state_type is (TX_READY, LOAD_BIT, SEND_BIT);

  signal state: state_type := TX_READY;

  constant BIT_TMR_MAX: std_logic_vector(13 downto 0) := "10100010110000"; -- (10416) = (round(100MHz / 9600)) - 1
  constant PACKET_BITS: natural := bits + 2; -- (10): 1 start, 8 data, 1 stop.

  -- Counter that keeps track of the number of clock cycles the current bit 
  -- has been held stable over the UART TX line. 
  -- It is used to signal when the next bit should be transmitted.
  signal bitTmr: std_logic_vector(13 downto 0) := (others => '0');

  -- Combinational logic that goes high when bitTmr has counted to the proper value to ensure 9600 baud rate
  signal bitDone: std_logic;

  -- Contains the index of the next bit in txData that needs to be transferred 
  signal bitIndex: natural;

  -- A register that holds the current data being sent over the UART TX line
  signal txBit: std_logic := '1';

  -- A register that contains the whole data packet to be sent, including start and stop bits. 
  signal txData: std_logic_vector(PACKET_BITS - 1 downto 0);

begin

  --Next state logic
  next_txState_process: process (clk) begin
    if (rising_edge(clk)) then
      case state is 
        when TX_READY =>
          if (send = '1') then
            state <= LOAD_BIT;
          end if;
        when LOAD_BIT =>
          state <= SEND_BIT;
        when SEND_BIT =>
          if (bitDone = '1') then
            if (bitIndex = PACKET_BITS) then
              state <= TX_READY;
            else
              state <= LOAD_BIT;
            end if;
          end if;
        when others => -- should never be reached
          state <= TX_READY;
      end case;
    end if;
  end process;

  bit_timing_process: process (clk) begin
    if (rising_edge(clk)) then
      if (state = TX_READY) then
        bitTmr <= (others => '0');
      else
        if (bitDone = '1') then
          bitTmr <= (others => '0');
        else
          bitTmr <= bitTmr + 1;
        end if;
      end if;
    end if;
  end process;

  bitDone <= '1' when (bitTmr = BIT_TMR_MAX) else '0';

  bit_counting_process: process (clk) begin
    if (rising_edge(clk)) then
      if (state = TX_READY) then
        bitIndex <= 0;
      elsif (state = LOAD_BIT) then
        bitIndex <= bitIndex + 1;
      end if;
    end if;
  end process;

  tx_data_latch_process: process (clk) begin
    if (rising_edge(clk)) then
      if (send = '1') then
        txData <= '1' & data & '0';
      end if;
    end if;
  end process;

  tx_bit_process: process (clk) begin
    if (rising_edge(clk)) then
      if (state = TX_READY) then
        txBit <= '1';
      elsif (state = LOAD_BIT) then
        txBit <= txData(bitIndex);
      end if;
    end if;
  end process;

  serial_out <= txBit;
  ready <= '1' when (state = TX_READY) else '0';

end architecture behavioral;