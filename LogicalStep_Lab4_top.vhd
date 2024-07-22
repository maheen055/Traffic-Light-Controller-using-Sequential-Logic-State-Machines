LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	
	--sm_clken_temp : out std_logic;
	--blink_sig_temp: out std_logic;
	--EW_a, EW_d, EW_g, NS_a, NS_d, NS_g    :out std_logic;
	
	
	-------------------------------------------------------------
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
             clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
	end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
            clkin      		    : in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
	);
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
	);
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				    : out	std_logic;							 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
	);
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
	);
   end component; 

	component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
	);	
	end component;			
	
	component State_Machine port (
			clk_input, reset, sm_clken, blink_sig, NS_req, EW_req			: IN std_logic; -- Input bits for clock, reset, enable, blink signal, and pedestrian requests
			green, yellow, red, green_EW, yellow_EW, red_EW						: OUT std_logic; -- Output bits for the red, amber and green traffic lights (0 when not-active, 1 when light is active), for both NS and EW directions
			NS_CROSSINGS, EW_CROSSINGS	: OUT std_logic; -- Output bits to symbolize crossing periods
			state_out : OUT std_logic_vector(3 downto 0); -- Output logic vector to represent state (unsigned decimal) as a binary number
			NS_REGISTER_CLEAR, EW_REGISTER_CLEAR : OUT std_logic -- Output bits to clear pedestrian requests
 	);
	end component;		
	
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode								: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads	
	-- set to TRUE for SIMULATIONS	
	
	SIGNAL rst 										: std_logic;
	SIGNAL rst_n_filtered 						: std_logic;
	SIGNAL sync_rst			  					: std_logic;
	SIGNAL sm_clken								: std_logic; 
	SIGNAL blink_sig								: std_logic; 
	
	SIGNAL pb_n_filtered							: std_logic_vector(3 downto 0); 
	SIGNAL pb										: std_logic_vector(3 downto 0); 
	SIGNAL pb_filt									: std_logic_vector (3 downto 0);

	SIGNAL EW_out									: std_logic; -- For holding the traffic light outputs
	SIGNAL NS_out									: std_logic; -- For holding the traffic light outputs
	
	SIGNAL EW_REGISTER_CLEAR					: std_logic;-- For holding the pedestrian request clear signals
	SIGNAL NS_REGISTER_CLEAR					: std_logic;-- For holding the pedestrian request clear signals
	
	signal NS_request 							: std_logic;
	signal EW_request 							: std_logic;
	
	signal light_EW								: std_logic_vector (6 downto 0);-- For holding the overall concatenated traffic digit value
	signal light_NS								: std_logic_vector (6 downto 0);-- For holding the overall concatenated traffic digit value
	
	SIGNAL NS_CROSSING				 			: std_logic;-- For holding the active crossing values
	SIGNAL EW_CROSSING 							: std_logic;-- For holding the active crossing values
	
	signal g_solid_NS								: std_logic;
	signal a_solid_NS								: std_logic;
	signal r_solid_NS								: std_logic;
	
	signal g_solid_EW								: std_logic;
	signal a_solid_EW								: std_logic;
	signal r_solid_EW								: std_logic;	
	
	
BEGIN
----------------------------------------------------------------------------------------------------

	-- Assignments of outputs to LEDs
	leds(0)<= NS_CROSSING; 
	leds(1)<= NS_out;
	leds(2)<= EW_CROSSING; 
	leds(3)<= EW_out;

	-- The following are temporary ports for simulation
	--sm_clken_temp 	<= sm_clken;
	--blink_sig_temp <= blink_sig;
	--EW_a <= r_solid_EW;
	--EW_d <= g_solid_EW;
	--EW_g <= a_solid_EW;
	
	--NS_a <= r_solid_NS;
	--NS_d <= g_solid_NS;
	--NS_g <= a_solid_NS;
	

	-- Concatenation of state machine outputs for 7seg mux
	light_NS <= a_solid_NS & "00" & g_solid_NS & "00" & r_solid_NS;
	light_EW <= a_solid_EW & "00" & g_solid_EW & "00" & r_solid_EW; 

INST0: pb_filters 			port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters			port map (rst_n_filtered, rst, pb_n_filtered, pb);

INST2: clock_generator 		port map (sim_mode, sync_rst, clkin_50, sm_clken, blink_sig); -- blink_sig);

INST3: synchronizer			port map( clkin_50, sync_rst, rst, sync_rst);-- Used for the synchronizer which generates the synchronous reset signal
INST4: synchronizer		 	port map (clkin_50, sync_rst, pb(1), EW_request);
INST5: synchronizer 			port map (clkin_50, sync_rst, pb(0), NS_request);

INST6: holding_register 	port map (clkin_50, sync_rst, EW_REGISTER_CLEAR, EW_request, EW_out);
INST7: holding_register 	port map (clkin_50, sync_rst, NS_REGISTER_CLEAR, NS_request, NS_out);

-- Generates an instance of the state machine which transitions between states and controls most of the traffic light
INST8: State_Machine 		port map(clkin_50, sync_rst, sm_clken, blink_sig, NS_out, EW_out, g_solid_NS, a_solid_NS, r_solid_NS, g_solid_EW, a_solid_EW, r_solid_EW, NS_CROSSING, EW_CROSSING, leds(7 downto 4), NS_REGISTER_CLEAR, EW_REGISTER_CLEAR);	

-- Uses the segment7_mux to display the traffic light digit values on the FPGA (or waveform if in SIM_MODE)
INST9: segment7_mux 			port map(clkin_50, light_NS, light_EW, seg7_data, seg7_char2, seg7_char1); 

END SimpleCircuit;