--Entity Name: 
-- 	GCD_PE
--
--Description: 
-- 	This is a Processing Element (PE) that implements the GCD processor that uses Euclidean Division Algorithm.
--	The PE's operation can be described as below
--  while(n != 0) {
--		r = m % n;
--		m = n;
--		n = r;
--  }
--  It receives two inputs (OpA_In, OpB_In) and does the division using a parallel restoring divider (Parallel 
--  divider handles the dividend and divisor of NUM_BITS size. The parallel divider's total size is O(NUM_BITS^2))
--  If the current OpB is not zero, the PE updates the OpA to OpB, and OpB to the remainder.
--  If the current OpB is zero, the PE doesn't change OpA and OpB and transfer the current OpA and OpB to the 
--  next PE.
-- 
--Entity Generics/Ports Information
--	Generic
--		NUM_BITS  : Size of inputs
--	Inputs
--		OpA_In	  : First input from the previous PE  (NUM_BITS bits)
--		OpB_In	  : Second input from the previous PE (NUM_BITS bits)
--	Outputs
--		OpA_Out	  : First output to the next PE  (NUM_BITS bits)
--      OpB_Out   : Second output to the next PE (NUM_BITS bits)
--
--Revision History
--	03/05/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GCD_PE is
generic( NUM_BITS: natural := 16); 
port(
    Clk     : in std_logic;
    OpA_In  : in std_logic_vector(NUM_BITS-1 downto 0);
    OpB_In  : in std_logic_vector(NUM_BITS-1 downto 0);
    OpA_Out : out std_logic_vector(NUM_BITS-1 downto 0);
    OpB_Out : out std_logic_vector(NUM_BITS-1 downto 0)
    );
end GCD_PE;

architecture Behavioral of GCD_PE is


-- GCD processing element uses a parallel restoring divider to calculate the remainder
component ResDivider is
generic (NUM_BITS : natural := 16);
port(
    Dividend : in std_logic_vector(NUM_BITS-1 downto 0);
    Divisor  : in std_logic_vector(NUM_BITS-1 downto 0);
    Quotient : out std_logic_vector(NUM_BITS-1 downto 0);
    Remainder: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end component;

-- Remainder from the parallel divider
signal Remainder : std_logic_vector(NUM_BITS-1 downto 0);
-- A signal that indicates that the second input is equal to zero
signal OpBIsZero : std_logic;

begin
	
	-- If the second input(OpB) is equal to zero, set this flag. Otherwise reset it
    OpBIsZero <= '1' when OpB_In = (OpB_In'range => '0') else
                 '0';

	-- Instantiate the NUM_BITS size parallel divider to calculate the remainder
    ResDiv: ResDivider
            generic map(NUM_BITS => NUM_BITS)
            port map(
                Dividend => OpA_In,
                Divisor => OpB_In,
                Remainder => Remainder);
     
	-- If the second input(OpB) is not zero, update OpA to current OpB and OpB to the remainder
	-- If the second input(OpB) is zero, transfer OpA and OpB to the next PE without making any change on inputs
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(OpBIsZero = '0') then -- If the second input is not zero
                OpA_Out <= OpB_In;
                OpB_Out <= Remainder;
            else				     -- If the second input is zero
                OpA_Out <= OpA_In;
                OpB_Out <= OpB_In;
            end if;
       end if;
    end process;
    
end Behavioral;
