--Entity Name: 
-- 	GameOfLife
--
--Description: 
-- 	This is the top level entity for Conway's Game of Life. It generates MESH_SIZE^2 PE's to implement the system.
--  The game rule is as following:
--  	Any live cell with fewer than two live neighbors dies of loneliness.
--  	Any live cell with more than three live neighbors dies of overpopulation.
--  	Any live cell with exactly two or three live neighbors continues living.
--  	And dead cell with exactly three live neighbors is (re)born as a live cell.
--  Note that the top level generates 'ghost states' outside the edges and corners of the grid to make the cells 
--  on boundaries to run correctly and make implementation easier. 
--  For example, if MESH_SIZE = 5, then it generates a 7 x 7 states array that looks like:
--  0 0 0 0 0 0 0
--  0 ? ? ? ? ? 0
--  0 ? ? ? ? ? 0
--  0 ? ? ? ? ? 0
--  0 ? ? ? ? ? 0
--  0 ? ? ? ? ? 0
--  0 0 0 0 0 0 0
--  Note that the outer ghost states (zeros) are just "states" and not actual PE's. In case of MESH_SIZE = 5, 
--  only 5^2=25 PE's are actually generated. Thus, the total resources of the system do not increase significantly.
--  The new data input is shifted in to the top-left cell on the grid, and the data output is shifted out from
--  the bottom-right cell on the grid. 
--  When NextTimeTick is active, the cells change their states based on the rule (on clock rising edges)
--  When Shift is active, the cells shift data to right. The cells on first column receive the shifted data from
--  the tail of the previous row above. Of course, the very top-left cell gets its data from DataIn port instead.
--  Note that NextTimeTick has priority over Shift for our PE's. Therefore, if both signals are active, the PE's
--  will change their states based on the game rule instead of shifting the data.
--
-- Generics
--	  MESH_SIZE : The size of the mesh. The total number of cells are MESH_SIZE^2
--	Inputs
--    Clk	: System clock (1 bit)
--    NextTimeTick	: When active, cells change the state based on the rule on the clock rising edge (1 bit)
--    Shift	: When active, cells shift data on the clock rising edge (1 bit)
--    DataIn	: Data to be shifted in to the array (1 bit)
--	Outputs
--    DataOut	: Data to be shifted out from the array (1 bit)
--
--Revision History
--	03/10/2019	Sung Hoon Choi	Created
--  03/11/2019  Sung Hoon Choi  Initial simulation
--  03/13/2019  Sung Hoon Choi  Added comments


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GameOfLife is
generic(MESH_SIZE: natural := 5);
port(
    Clk: in std_logic;
    NextTimeTick: in std_logic;
    Shift: in std_logic;
    DataIn: in std_logic;
    DataOut: out std_logic
    );
end GameOfLife;

architecture Behavioral of GameOfLife is

-- Array that contains the states of the cells. It also includes the ghost states outside the grid edges. 
-- Thus, its total size is [MESH_SIZE+2 x MESH_SIZE+2]
type StateArrayType is array(0 to MESH_SIZE+1) of std_logic_vector(0 to MESH_SIZE+1);
-- Generate the state array using the type defined above
signal StateArray: StateArrayType;
-- Input Mux for the first column cells. The selection of inputs for them depend on Shift and NextTimeTick.
signal FirstColMux: std_logic_vector(0 to MESH_SIZE);
-- Input Mux for the top-left cell. If the Shift is '1', the top-left cell is wired to DataIn. Otherwise, it is
-- wired to the ghost cell
signal TopLeftCellMux: std_logic;

-- The processing element to be generated for implementing Conway's Game of Life.
component GameOfLifePE is
port(
    State_N: in std_logic;
    State_NE: in std_logic;
    State_E: in std_logic;
    State_SE: in std_logic;
    State_S: in std_logic;
    State_SW: in std_logic;
    State_W: in std_logic;
    State_NW: in std_logic;
    Clk: in std_logic;
    NextTimeTick: in std_logic;
    Shift: in std_logic;
    StateOut: out std_logic
    );
end component;


begin

    -- Generate the ghost columns(column number 0, column number MESH_SIZE+1) outside the boundaries of the grid
	-- The ghost columns' states are '0' (DEAD)
	-- Ghost states are needed to make the cells on edges and corners to work correctly
    Ghost_column: for column in 0 to MESH_SIZE+1 generate
                  StateArray(0)(column) <= '0';
                  StateArray(MESH_SIZE+1)(column) <= '0';
                  end generate;
    -- Generate the ghost rows(row number 0, row number MESH_SIZE+1) outside the boundaries of the grid
	-- The ghost rows' states are '0' (DEAD)
	-- Ghost states are needed to make the cells on edges and corners to work correctly
	Ghost_row: for row in 1 to MESH_SIZE generate
             StateArray(row)(0) <= '0';
             StateArray(row)(MESH_SIZE+1) <= '0';
             end generate;
             
    -- The signal to be mapped to State_W port of the top-left cell. 
	-- When Shift = '1', State_W port of the top-left cell must be DataIn
	-- When Shift = '0', State_W port of the top-left cell must be '0'
    TopLeftCellMux <= DataIn and Shift;
	-- The output data is to be shifted out from the bottom-right cell
    DataOut <= StateArray(MESH_SIZE)(MESH_SIZE);
    
	-- The signal to be mapped to State_W ports of first column (except the top-left cell that receives DataIn)
	-- When Shift = '1', State_W ports of first column cells must be connected to the tail of the row above
	-- When Shift = '0', State_W ports must be '0'
    gen_FirstColumnCellMux: for row in 1 to MESH_SIZE generate
                        FirstColMux(row) <= StateArray(row-1)(MESH_SIZE) when Shift = '1' else
                                           '0';              
                  end generate;   

	-- Generate the PE of the top-left cell and connect it to neighbors
	-- Note that the top left cell's State_W is DataIn when Shift = '1'
    gen_TopLeftCellMux: GameOfLifePE port map(
                State_N => StateArray(1-1)(1),
                State_NE => StateArray(1-1)(2),
                State_E => StateArray(1)(2),
                State_SE => StateArray(1+1)(2),
                State_S => StateArray(1+1)(1),
                State_SW => StateArray(1+1)(0),
                State_W => TopLeftCellMux,
                State_NW => StateArray(1-1)(0),
                Clk => Clk,
                NextTimeTick=> NextTimeTick,
                Shift=> Shift,
                StateOut => StateArray(1)(1)
                );

	-- Generate the PE's of the cells on the first column (except the top-left cell)
	-- Note that the first column cells' State_W are equivalent to the tail of the previous row when Shift = '1'
    gen_FirstColumn: for row in 2 to MESH_SIZE generate
                            gen_PE: GameOfLifePE port map(
                            State_N => StateArray(row-1)(1),
                            State_NE => StateArray(row-1)(2),
                            State_E => StateArray(row)(2),
                            State_SE => StateArray(row+1)(2),
                            State_S => StateArray(row+1)(1),
                            State_SW => StateArray(row+1)(0),
                            State_W => FirstColMux(row),
                            State_NW => StateArray(row-1)(0),
                            Clk => Clk,
                            NextTimeTick=> NextTimeTick,
                            Shift=> Shift,
                            StateOut => StateArray(row)(1)
                            );
                      end generate;
    
    -- Generate the rest of the PE's
	-- These general PE's are simply connected to their neighbors without any input muxes.
    gen_row: for row in  1 to MESH_SIZE generate
        gen_col: for column in 2 to MESH_SIZE generate
                    gen_PE: GameOfLifePE port map(
                            State_N => StateArray(row-1)(column),
                            State_NE => StateArray(row-1)(column+1),
                            State_E => StateArray(row)(column+1),
                            State_SE => StateArray(row+1)(column+1),
                            State_S => StateArray(row+1)(column),
                            State_SW => StateArray(row+1)(column-1),
                            State_W => StateArray(row)(column-1),
                            State_NW => StateArray(row-1)(column-1),
                            Clk => Clk,
                            NextTimeTick=> NextTimeTick,
                            Shift=> Shift,
                            StateOut => StateArray(row)(column)
                            );
         end generate;
    end generate;

end Behavioral;
