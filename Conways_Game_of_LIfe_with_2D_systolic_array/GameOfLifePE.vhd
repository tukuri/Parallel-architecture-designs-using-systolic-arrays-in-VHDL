--Entity Name: 
-- 	GameOfLifePE
--
--Description: 
-- 	This is the processing element(cell) for Conway's Game of Life.
--  The cell can continue living if there are exactly two or three live neighbors.
--  If the cell is currently dead, it can be reborn if there are exactly three live neighbors.
--  Otherwise, the cell dies.
--  The processing element(cell) counts the number of alive neighbors by using 4-bit adders.
--  When NextTimeTick is active, the processing element changes its state based on the rule on clock rising edge.
--  When Shift is active, it shifts data by changing its state into the shifted-in data from the neighbor on 
--  west(except for the first column cells) Note that the cells on the first columns receive the shifted data 
--  from the tail of the previous row instead and the top-left cell gets data shifted in from DataIn top-level
--  port. Details are explained in the top level entity file.
--  Finally, note that NextTimeTick has priority over Shift. Therefore, if both NextTimeTick and Shift are 
--  active, the processing element updates its state based on the game's rule instead of shifting.
--
--	Inputs
--    State_N	: State of the neighbor on the north (1 bit)
--    State_NE	: State of the neighbor on the northeast (1 bit)
--    State_E	: State of the neighbor on the east (1 bit)
--    State_SE	: State of the neighbor on the southeast (1 bit)
--    State_S	: State of the neighbor on the south (1 bit)
--    State_SW	: State of the neighbor on the southwest (1 bit)
--    State_W	: State of the neighbor on the west (1 bit)
--    State_NW	: State of the neighbor on the northwest (1 bit)
--    Clk		: System clock (1 bit)
--    NextTimeTick: When active, cells change the state based on the rule on the clock rising edge (1 bit)
--    Shift		: When active, cells shift data on the clock rising edge (1 bit)
--	Outputs
--	  StateOut  : Current state of the cell (1 bit)
--
--Revision History
--	03/10/2019	Sung Hoon Choi	Created
--  03/11/2019  Sung Hoon Choi  Initial simulation
--  03/13/2019  Sung Hoon Choi  Added comments


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity GameOfLifePE is
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
end GameOfLifePE;

architecture Behavioral of GameOfLifePE is

-- Current state of the cell
signal CurState : std_logic;
-- Next state of the cell determined by the game rule
signal NextState: std_logic;
-- Total number of alive neighbors (0 ~ 8)
signal AliveNeighbors: unsigned(3 downto 0);

-- State of the north neighbor in std_logic_vector
signal State_N_ext: std_logic_vector(3 downto 0);
-- State of the northeast neighbor in std_logic_vector
signal State_NE_ext: std_logic_vector(3 downto 0);
-- State of the east neighbor in std_logic_vector
signal State_E_ext: std_logic_vector(3 downto 0);
-- State of the southwest neighbor in std_logic_vector
signal State_SE_ext: std_logic_vector(3 downto 0);
-- State of the south neighbor in std_logic_vector
signal State_S_ext: std_logic_vector(3 downto 0);
-- State of the southwest neighbor in std_logic_vector
signal State_SW_ext: std_logic_vector(3 downto 0);
-- State of the west neighbor in std_logic_vector
signal State_W_ext: std_logic_vector(3 downto 0);
-- State of the northwest neighbor in std_logic_vector
signal State_NW_ext: std_logic_vector(3 downto 0);

-- State of the north neighbor in unsigned
signal State_N_uns: unsigned(3 downto 0);
-- State of the northeast neighbor in unsigned
signal State_NE_uns: unsigned(3 downto 0);
-- State of the east neighbor in unsigned
signal State_E_uns: unsigned(3 downto 0);
-- State of the southwest neighbor in unsigned
signal State_SE_uns: unsigned(3 downto 0);
-- State of the south neighbor in unsigned
signal State_S_uns: unsigned(3 downto 0);
-- State of the southwest neighbor in unsigned
signal State_SW_uns: unsigned(3 downto 0);
-- State of the west neighbor in unsigned
signal State_W_uns: unsigned(3 downto 0);
-- State of the northwest neighbor in unsigned
signal State_NW_uns: unsigned(3 downto 0);


begin

	-- Extend the states to 4-bits for addition --
    State_N_ext  <= "000" & State_N; 	-- Extend the north neighbor
    State_NE_ext <= "000" & State_NE;	-- Extend the northeast neighbor
    State_E_ext  <= "000" & State_E;	-- Extend the east neighbor
    State_SE_ext <= "000" & State_SE;	-- Extend the southeast neighbor
    State_S_ext  <= "000" & State_S;	-- Extend the south cell
    State_SW_ext <= "000" & State_SW;	-- Extend the southwest cell
    State_W_ext  <= "000" & State_W;   	-- Extend the west cell                     
    State_NW_ext <= "000" & State_NW;  	-- Extend the northwest cell
    
	-- Convert the states into unsigned for addition --
    State_N_uns  <= unsigned(State_N_ext);	-- Convert the north cell
    State_NE_uns <= unsigned(State_NE_ext);	-- Convert the northeast cell
    State_E_uns  <= unsigned(State_E_ext);	-- Convert the east cell
    State_SE_uns <= unsigned(State_SE_ext);	-- Convert the southeast cell  
    State_S_uns  <= unsigned(State_S_ext);	-- Convert the south cell
    State_SW_uns <= unsigned(State_SW_ext);	-- Convert the southwest cell
    State_W_uns  <= unsigned(State_W_ext);	-- Convert the west cell
    State_NW_uns <= unsigned(State_NW_ext);	-- Convert the northwest cell 
    
    -- Use 4-bit adders to count the total number of alive neighbors
    AliveNeighbors <= State_N_uns + State_NE_uns + State_E_uns + State_SE_uns 
					+ State_S_uns + State_SW_uns + State_W_uns + State_NW_uns;


	-- Determine the next state based on the game rule
				  -- If there are three neighbors alive: Regardless of the current state, the next state is alive
				  -- (Because if current state is dead, it gets reborn. If current state is alive, it stays alive)
    NextState <= '1'              when AliveNeighbors = 3 else
				  -- If there are two neighbors alive: The next state depends on the current state
				  -- (If current state is alive, stay alive. If current state is dead, stay dead)
                 '1' AND CurState when AliveNeighbors = 2 else
				  -- Otherwise, the next state is dead
                 '0';                                           
    
    -- The cell changes its state based on the game rule if NextTimeTick is active
	-- The cell shifts the data if Shift is active. When shifting, the cell receives the data from
	-- the negibor on the west. However, the top level program re-routes the shift data for the cells on the first column.
	-- See the top-level entity file for re-routing details for the first column cells.
	-- Since NextTimeTick has priority over Shift, the cell would follow the game rule when both signals are active
    process(Clk)
    begin
        if(rising_edge(Clk)) then
			-- When NextTimeTick is active, follow the game rule
            if(NextTimeTick = '1') then
                CurState <= NextState;
			-- When Shift is active, shift the data 
            elsif(Shift = '1') then
                CurState <= State_W;
             end if;
        end if;
    end process;
    
	-- Output the current state of the cell
    StateOut <= CurState;
    
end Behavioral;
