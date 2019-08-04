--Entity Name: 
-- 	GameOfLifeTB_6x6
--
--Description: 
-- 	This is a testbench for Conway's Game of Life for 6x6 grid. (MESH_SIZE = 6)
--  The patterns and testvectors for this testbench are generated by using Python.
--  It verifies the cellular automata with different initial patterns. For each pattern, it checks the change of
--  states over NUM_EPOCHS epochs. At every epoch, the testbench verifies if the transition of states on the grid
--  are all correct.
--  The patterns tested in this testbench are
--
--  Initial Pattern 0: Beacon
--  Initial Pattern 1: Loaf
--  Initial Pattern 2: Glider
--  Initial Pattern 3: Vertical
--  
--  The initial pattern vector is shifted in to the array in the reverse order, and the output data is verified 
--  with the testvectors in the same order as well.
--
--  Note that all possible cases of different situations (neighbors = 0, 1, ..7, 8) are fully covered throughout 
--  the testbench for 5x5 grid, the testbench for 6x6 grid, and the testbench for 12x12 grid.
--
--Revision History
--	03/10/2019	Sung Hoon Choi	Created
--  03/11/2019  Sung Hoon Choi  Initial simulation
--  03/12/2019  Sung Hoon Choi  Added more initial patterns and testvectors to cover different cases
--  03/14/2019  Sung Hoon Choi  Updated comments


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity GameOfLifeTB is
end GameOfLifeTB;

architecture Behavioral of GameOfLifeTB is

-- Top-level entity to be verified
component GameOfLife is
generic(MESH_SIZE: natural := 5);
port(
    Clk: in std_logic;
    NextTimeTick: in std_logic;
    Shift: in std_logic;
    DataIn: in std_logic;
    DataOut: out std_logic
    );
end component;

-- The size of the mesh to be tested
constant TEST_MESH_SIZE : natural := 6;
-- The total number of cells
constant GRID_SIZE: natural := TEST_MESH_SIZE**2;

-- System clock
signal Clk: std_logic := '1';
-- When active, cells change the state based on the rule on the clock rising edge
signal NextTimeTick: std_logic := '0';
-- When active, cells shift data on the clock rising edge
signal Shift: std_logic := '0';
-- Data to be shifted in to the array
signal DataIn:std_logic;
-- Data to be shifted out from the array
signal DataOut:std_logic;
-- Notifies the end of simulation
signal END_SIM:std_logic := '0';

-- Number of epochs to verify the change of patterns over time
constant NUM_EPOCHS : natural := 6;
-- Number of initial patterns to be tested
constant NUM_PATTERNS : natural := 4;
-- Type definition for the testvectors that verify the change of patterns over different epochs
type GameOfLifeTestVecType is array(0 to NUM_EPOCHS-1) of std_logic_vector(0 to GRID_SIZE-1);

-- Beacon (Oscillates, period: 2)
signal Beacon: std_logic_vector(0 to GRID_SIZE-1) := "000000011000010000000010000110000000";
-- Beacon testvectors
signal BeaconTestvector: GameOfLifeTestVecType := ( "000000011000011000000110000110000000", -- epoch 1
                                                    "000000011000010000000010000110000000", -- epoch 2
                                                    "000000011000011000000110000110000000", -- epoch 3
                                                    "000000011000010000000010000110000000", -- epoch 4
                                                    "000000011000011000000110000110000000", -- epoch 5
                                                    "000000011000010000000010000110000000");-- epoch 6
                                                      
-- Loaf (Stays still)                                                 
signal Loaf: std_logic_vector(0 to GRID_SIZE-1) := "000000001100010010001010000100000000";
-- Loaf testvectors
signal LoafTestvector: GameOfLifeTestVecType := ( "000000001100010010001010000100000000", -- epoch 1
                                                  "000000001100010010001010000100000000", -- epoch 2
                                                  "000000001100010010001010000100000000", -- epoch 3
                                                  "000000001100010010001010000100000000", -- epoch 4
                                                  "000000001100010010001010000100000000", -- epoch 5
                                                  "000000001100010010001010000100000000");-- epoch 6
                                                  
-- Glider that keeps moving to right with transformation
signal Glider: std_logic_vector(0 to GRID_SIZE-1) := "010000001000111000000000000000000000";
-- Glider testvectors
signal GliderTestvector: GameOfLifeTestVecType := (  "000000101000011000010000000000000000", -- epoch 1
                                                     "000000001000101000011000000000000000", -- epoch 2
                                                     "000000010000001100011000000000000000", -- epoch 3
                                                     "000000001000000100011100000000000000", -- epoch 4
                                                     "000000000000010100001100001000000000", -- epoch 5
                                                     "000000000000000100010100001100000000");-- epoch 6
                                                     
-- Vertical. Converges to BeeHive                                             
signal Vertical: std_logic_vector(0 to GRID_SIZE-1) := "000000001000001000001000001000000000";
-- Vertical testvectors
signal VerticalTestvector: GameOfLifeTestVecType := (  "000000000000011100011100000000000000", -- epoch 1
                                                       "000000001000010100010100001000000000", -- epoch 2
                                                       "000000001000010100010100001000000000", -- epoch 3
                                                       "000000001000010100010100001000000000", -- epoch 4
                                                       "000000001000010100010100001000000000", -- epoch 5
                                                       "000000001000010100010100001000000000");-- epoch 6
                                                       
                                                     
begin
	-- Instantiate the entity to verify
    UUT: GameOfLife 
        generic map(MESH_SIZE => TEST_MESH_SIZE)
        port map(
            Clk => Clk,
            NextTimeTick => NextTimeTick,
            Shift => Shift,
            DataIn => DataIn,
            DataOut => DataOut
            );

-- Generate the system clock
Clk <= not Clk after 50 ns;

-- Go through testing different initial patterns. 
-- Check the correctness at every epoch. (Epoch1: states after 1 tick / Epoch2: states after 2 ticks / ..)
-- Between every epoch it resets the grid to test new epochs.
-- It shifts in the data into array by using the pattern vectors in the reverse order. 
-- For every test routine, it shifts out the data from the array and compare the data with the testvectors in the
-- reverse order.
-- After going thorugh all NUM_PATTERNS test cases (and NUM_EPOCHS test epochs for each pattern), it sets the
-- END_SIM signal to notify that the simulation is done.
process
begin
    DataIn <= '0';
	-- Wait before starting the simulation
    wait for 80 ns;
	-- Start testing NUM_PATTERNS initial patterns
    for pattern in 0 to NUM_PATTERNS-1 loop
		-- Outer loop to test the cellular automata at every epoch
        for epoch in 0 to NUM_EPOCHS-1 loop
			-- Shift in the initial pattern
            Shift <= '1';
            for i in 0 to GRID_SIZE-1 loop
                if(pattern = 0) then
                    DataIn <= Beacon(GRID_SIZE-1-i); -- Shift in initial pattern 0
                elsif(pattern = 1) then
                    DataIn <= Loaf(GRID_SIZE-1-i); -- Shift in initial pattern 1       
                elsif(pattern = 2) then
                    DataIn <= Glider(GRID_SIZE-1-i); -- Shift in initial pattern 2
                elsif(Pattern = 3) then
                    DataIn <= Vertical(GRID_SIZE-1-i); -- Shift in initial pattern 3
                end if;
                wait for 100 ns;
            end loop;
			-- Since we are done with shifting in the initial pattern, let's run the cellular automata
            Shift <= '0';
			-- Activate the NextTimeTick based on the epoch
			-- For example, if epoch=1, activate NextTimeTick for one cycle
			--              if epoch=2, activate NextTimeTick for two cycles
             for tick in 0 to epoch loop
                 NextTimeTick <= '1';
                 wait for 100 ns;
             end loop;
			-- Since we are done with running the cellular automata, let's shift out the data to check if the 
			-- result is correct
            NextTimeTick <= '0';
            Shift <= '1';
            for i in 0 to GRID_SIZE-1 loop
				-- Compare the result with the testvector (pattern 0)
                if(pattern = 0) then
                    assert(std_match(DataOut, BeaconTestVector(epoch)(GRID_SIZE-1-i)))
                    report "Error: DataOut does not match the expected value at pattern number " 
							& integer'image(pattern)
                        severity ERROR;
				-- Compare the result with the testvector (pattern 1)						
               elsif(pattern = 1) then
                    assert(std_match(DataOut, LoafTestVector(epoch)(GRID_SIZE-1-i)))
                    report "Error: DataOut does not match the expected value at pattern number " 
							& integer'image(pattern)
                        severity ERROR;      
				-- Compare the result with the testvector (pattern 2)
               elsif(pattern = 2) then
                    assert(std_match(DataOut, GliderTestVector(epoch)(GRID_SIZE-1-i)))
                    report "Error: DataOut does not match the expected value at pattern number " 
							& integer'image(pattern)
                        severity ERROR;    
				-- Compare the result with the testvector (pattern 3)
               elsif(pattern = 3) then
                    assert(std_match(DataOut, VerticalTestVector(epoch)(GRID_SIZE-1-i)))
                    report "Error: DataOut does not match the expected value at pattern number " 
							& integer'image(pattern)
                        severity ERROR;       
               end if;     
                wait for 100 ns;
            end loop;  
        end loop;   
    end loop;   
	-- Simulation complete	
	END_SIM <= '1';
    wait;
end process;

end Behavioral;