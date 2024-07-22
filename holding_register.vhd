-- Maheen Shoaib & Jessica Persaud 
-- ECE 124
-- Section 201

library ieee;
use ieee.std_logic_1164.all;

-- Entity declaration for holding_register
entity holding_register is 
    port (
        clk             : in std_logic;  -- Clock signal
        reset           : in std_logic;  -- Reset signal
        register_clr    : in std_logic;  -- Register clear signal
        din             : in std_logic;  -- Data input
        dout            : out std_logic  -- Data output
    );
end holding_register;

-- Architecture definition for holding_register
architecture circuit of holding_register is
    signal sreg : std_logic;  -- Internal signal to hold the register value
begin
    -- Process triggered on the rising edge of the clock
    process(clk)
    begin
        -- Check for rising edge of the clock
        if rising_edge(clk) then
            -- If reset is active, clear the register
            if reset = '1' then
                sreg <= '0';
            else
                -- Update the register value based on din and control signals (based on the given diagram)
                sreg <= ((sreg or din) and not (register_clr or reset));
            end if;
        end if;
    end process;

    -- Assign the internal register value to the output
    dout <= sreg;
end circuit;
