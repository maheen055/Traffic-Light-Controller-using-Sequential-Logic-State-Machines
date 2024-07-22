library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


Entity State_Machine IS Port
(
 clk_input, reset, sm_clken, blink_sig, NS_req, EW_req			: IN std_logic; -- Input bits for clock, reset, enable, blink signal, and pedestrian requests
 green, yellow, red, green_EW, yellow_EW, red_EW						: OUT std_logic; -- Output bits for the red, amber and green traffic lights (0 when not-active, 1 when light is active), for both NS and EW directions
 NS_CROSSINGS, EW_CROSSINGS	: OUT std_logic; -- Output bits to symbolize crossing periods
 state_out : OUT std_logic_vector(3 downto 0); -- Output logic vector to represent state (unsigned decimal) as a binary number
 NS_REGISTER_CLEAR, EW_REGISTER_CLEAR : OUT std_logic -- Output bits to clear pedestrian requests
 );
END ENTITY;
 
-- Define the logic of the traffic light Moore State Machine
Architecture SM of State_Machine is
 
 
TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);   -- list all the 16 STATE_NAMES values

 
SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


BEGIN

-- Register process, updates with respect to changes in the clock
Register_Section: PROCESS (clk_input)  
BEGIN
	-- Reacts on the rising edge of the clock
	IF(rising_edge(clk_input)) THEN
		-- If reset is active, reset state back to first state (S0)
		IF (reset = '1') THEN
			current_state <= S0;
		-- If reset is not active and state machine is enabled, current state transitions to next state
		ELSIF (reset = '0' and sm_clken = '1') THEN
			current_state <= next_State;
		END IF;
	END IF;
END PROCESS;	



-- Transition process, updates with respect to the changes in current_state
Transition_Section: PROCESS (current_state) 

BEGIN
  -- Case block to define the transition between states depending on order and variable values
  CASE current_state IS
        -- Either advances chronologically or skips to S6 (EW amber state) if EW request is activated by pedestrian and NS request is not active
  		WHEN S0 =>
			if (EW_req = '1' AND NS_req = '0') then
				next_state <= S6;
			else
				next_state <= S1;
			end if;
        -- Either advances chronologically or skips to S6 (EW amber state) if EW request is activated by pedestrian and NS request is not active
		WHEN S1 =>		
			if (EW_req = '1' AND NS_req = '0') then
				next_state <= S6;
			else
				next_state <= S2;
			end if;
        -- Assigns the next states chronologically
		WHEN S2 =>		
			next_state <= S3;
		WHEN S3 =>		
			next_state <= S4;
		WHEN S4 =>		
			next_state <= S5;
		WHEN S5 =>		
			next_state <= S6;
		WHEN S6 =>		
			next_state <= S7;
		WHEN S7 =>		
			next_state <= S8;
		-- Either advances chronologically or skips to S14 (NS amber state) if NS request is activated by pedestrian and EW request is not active
		WHEN S8 =>		
			if (EW_req = '0' AND NS_req = '1') then
				next_state <= S14;
			else
				next_state <= S9;
			end if;
		-- Either advances chronologically or skips to S14 (NS amber state) if NS request is activated by pedestrian and EW request is not active
		WHEN S9 =>		
			if (EW_req = '0' AND NS_req = '1') then
				next_state <= S14;
			else
				next_state <= S10;
			end if;
		-- Assigns the next states chronologically
		WHEN S10 =>		
			next_state <= S11;
		WHEN S11 =>		
			next_state <= S12;
		WHEN S12 =>		
			next_state <= S13;
		WHEN S13 =>		
			next_state <= S14;
		WHEN S14 =>		
			next_state <= S15;
		-- When reaches S15, next state is defined back to the start (S0)
		WHEN S15 =>		
			next_state <= S0;
	  END CASE;
 END PROCESS;
 

-- Decoder process, updates with respect to the changes in current_state
Decoder_Section: PROCESS (current_state) 

BEGIN
	-- Case block to assign outputs based on the state
     CASE current_state IS
		-- Assigns blinking green signal for NS and red signal for EW
         WHEN S0 | S1 =>
			NS_REGISTER_CLEAR <= '0';		
			green <= blink_sig;
			yellow <= '0';
			red <= '0';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
			green_EW <= '0';
			yellow_EW <= '0';
			red_EW <= '1';
			EW_CROSSINGS <= '0';
		-- Assigns solid green signal for NS with activated crossing signal and red signal for EW
        WHEN S2 | S3 | S4 | S5 =>		
		 	NS_REGISTER_CLEAR <= '0';
			green <= '1';
			yellow <= '0';
			red <= '0';
			NS_CROSSINGS <= '1';
			
			EW_REGISTER_CLEAR <= '0';
			green_EW <= '0';
			yellow_EW <= '0';
			red_EW <= '1';
			EW_CROSSINGS <= '0';
		-- Assigns amber signal for NS and red signal for EW, and activates NS request clear
        WHEN S6 =>	
			NS_REGISTER_CLEAR <= '1';
			green <= '0';
			yellow <= '1';
			red <= '0';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
			green_EW <= '0';
			yellow_EW <= '0';
			red_EW <= '1';
			EW_CROSSINGS <= '0';
		-- Assigns amber signal for NS and red signal for EW
		WHEN S7 =>		
			NS_REGISTER_CLEAR <= '0';
			green <= '0';
			yellow <= '1';
			red <= '0';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
			green_EW <= '0';
			yellow_EW <= '0';
			red_EW <= '1';
			EW_CROSSINGS <= '0';
			
		-- Assigns red signal for NS and blinking green signal for EW
        WHEN S8 | S9 =>
			NS_REGISTER_CLEAR <= '0';
 			green <= '0';
			yellow <= '0';
			red <= '1';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
 			green_EW <= blink_sig;
			yellow_EW <= '0';
			red_EW <= '0';
			EW_CROSSINGS <= '0';
		
		-- Assigns red signal for NS and green signal for EW with crossing signal activated
		WHEN S10 | S11 | S12 | S13 =>		
 			NS_REGISTER_CLEAR <= '0';
			green <= '0';
			yellow <= '0';
			red <= '1';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
 			green_EW <= '1';
			yellow_EW <= '0';
			red_EW <= '0';
			EW_CROSSINGS <= '1';
		-- Assigns red signal for NS and amber signal for EW and activates EW request clear
		WHEN S14 =>		
 			NS_REGISTER_CLEAR <= '0';
			green <= '0';
			yellow <= '0';
			red <= '1';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '1';
 			green_EW <= '0';
			yellow_EW <= '1';
			red_EW <= '0';
			EW_CROSSINGS <= '0';
		-- Assigns red signal for NS and amber signal for EW
		WHEN S15 =>		
 			NS_REGISTER_CLEAR <= '0';
			green <= '0';
			yellow <= '0';
			red <= '1';
			NS_CROSSINGS <= '0';
			
			EW_REGISTER_CLEAR <= '0';
 			green_EW <= '0';
			yellow_EW <= '1';
			red_EW <= '0';
			EW_CROSSINGS <= '0';
			
	  END CASE;
	  
	  -- Case block which assigns a state's respective binary value to the state_out output
	  CASE current_state IS
		WHEN S0 =>
			state_out <= "0000";
		WHEN S1 =>
			state_out <= "0001";
		WHEN S2 =>
			state_out <= "0010";
		WHEN S3 =>
			state_out <= "0011";
		WHEN S4 =>
			state_out <= "0100";
		WHEN S5 =>
			state_out <= "0101";
		WHEN S6 =>
			state_out <= "0110";
		WHEN S7 =>
			state_out <= "0111";
		WHEN S8 =>
			state_out <= "1000";
		WHEN S9 =>
			state_out <= "1001";
		WHEN S10 =>
			state_out <= "1010";
		WHEN S11 =>
			state_out <= "1011";
		WHEN S12 =>
			state_out <= "1100";
		WHEN S13 =>
			state_out <= "1101";
		WHEN S14 =>
			state_out <= "1110";
		WHEN S15 =>
			state_out <= "1111";
		END CASE;
 END PROCESS;

 END ARCHITECTURE SM;