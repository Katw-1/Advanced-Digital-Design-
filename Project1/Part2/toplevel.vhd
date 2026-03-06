library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
	generic (
		ro_length:	positive := 13;
		ro_count:	positive := 16
	);
	port (
		clock:	in	std_logic;
		reset:	in	std_logic;
		done:	out	std_logic 
	);
end entity toplevel;

architecture top of toplevel is
	-- TODO: any signal declarations you may need
	type state_type is (
		RESET,
		SET_CHALLENGE,
		RELEASE_RESET,
		ENABLE,
		WAIT,
		DISABLE,
		STORE,
		NEXT,
		DONE, 
	);
	signal state        : state_type := RESET;
	signal challenge    : unsigned(ro_count-1 downto 0) := (others => '0');
	signal puf_reset    : std_logic := '1';
	signal put_enable   : std_logic := '0';
	signal puf_response : std_logic;
begin

	-- TODO: make instance of ro_puf
	puf: ro_puf
		generic map (
			-- add generic information
			-- should come from toplevel's generic list
			ro_length => ro_length,
			ro_count => ro_count
		)
		
		port map (
			-- add port information
			-- should use some signals internal to this architecture
			-- should use the `reset' input from toplevel
			clock     => clock,
			reset     => puf_reset, 
			enable    => puf_enable,
			challenge => std_logic_vector(challenge),
			response  => puf_response
		);

	-- TODO: control unit
	-- use control unit entity from blackboard, make entity here
	-- uses the `clock' input and the `reset' input from toplevel
	process(clock, reset)
	begin
		entity control_unit is
			generic map(
				clock_freq   : positive := 50000000
				probe_delay  : positive := 10
				ro_length    : positive := 13
				ro_count	 : positive := 16 
			);
			port (
				clock: in std_logic;
				reset: in std_logic;
				enable: in std_logic
				
				counter_enable: out std_logic;
				counter_reset:  out std_logic;
				challenge:   out std_logic_vector;
				store_response: out std_logic;
				done:  out std_logic;

			)
		if reset = '0' then 
			state        <= RESET;
			challenge    <= (others => '0');
			wait_counter <= 0;
			puf_reset    <= '1';
			puf_enable   <= '0';
			ram_wren     <= '0';
			done         <= '0';
		elsif rising_edge(clock) then 
			case state is 
				when RESET => 
					puf_reset <= '1';
					puf_enable <= '0';
					state <= SET_CHALLENGE;
				when SET_CHALLENGE =>
					state <= RELEASE_RESET;
				when RELEASE_RESET
					puf_reset <= '0';
					state <= ENABLE;
				when ENABLE =>
					puf_enable <= '1';
					wait_counter <= 0;
					state <= WAIT;
				when WAIT =>
					if wait_counter < WAIT_CYCLES then 
						wait_counter <= wait_counter + 1;
					else
						state <= DISABLE;
					end if;
				when DISABLE =>
					puf_enable <= '0';
					state <= STORE;
				when STORE => 
					ram_wren <= '0';
					if challenge = MAX_CHALLENGES -1 then 
						STATE <= DONE;
					else 
						challenge <= challenge + 1;
						state <= RESET;
					end if;
				when DONE => 
					done <= '1';
					state <= DONE; 
			end case;
		end if;
	end process; 

	-- TODO: BRAM
	-- create a BRAM using the IP Catalog, instance it here
	-- make sure you enable the In-System Memory Viewer!
	ram_inst : entity work.bram_ip
		port map(
			clock  => clock,
			address => std_logic_vector(challenge),
			data => puf_response,
			wren => ram_wren, 
			q => open
		);

end architecture top;
