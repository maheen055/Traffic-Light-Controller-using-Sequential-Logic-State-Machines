-- Maheen Shoaib & Jessica Persaud 
-- ECE 124
-- Section 201
 
library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset		: in std_logic;
			din			: in std_logic;
			dout		: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	-- Signal (2-bit vector) to keep track of synchronizer register contents
	signal sreg : std_logic_vector(1 downto 0);

begin
  -- Process construct that advances based on changes in the clock input
  synced_process : process(clk)
  begin
    -- If the clock is on its rising edge, continue logic evaluation
    if rising_edge(clk) then
      -- Reset the register contents to "00" if reset is active
      if reset = '1' then
        sreg <= "00";
      -- Shift the register contents (D flip-flop) to the right if reset is not active
      else
        sreg(1) <= sreg(0); -- Shifts the content of the first register to the second
        sreg(0) <= din;     -- Assigns the data input to the first register
      end if;
    end if;
  end process synced_process;
  
  dout <= sreg(1); -- Assigns the second register contents to the circuit data output
end;