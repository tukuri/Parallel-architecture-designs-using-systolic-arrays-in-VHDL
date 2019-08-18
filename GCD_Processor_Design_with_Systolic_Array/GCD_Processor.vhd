--Entity Name: 
-- 	GCD_Processor
--
--Description: 
--  This is a GCD processor that calculates the GCD of two unsigned numbers(NUM_BITS bits), by using a linear 
--  array of processing elements (PE's). It uses the parallel dividers and Euclidean Division Algorithm to 
--  calculate the GCD. 
--  The pseudocode for Euclidean Division Algorithm is as follows.
--  while(n != 0) {
--		r = m % n;
--		m = n;
--		n = r;
--  }
-- GCD processor instantiates MAX_ITERATIONS PE's to calculate the GCD. MAX_ITERATIONS is the number of
-- divisions required for the worst case scenario of Euclidean Division Algorithm. The maximum number of iterations
-- required for n bit inputs is 5*log(2^n-1) with the log base 10. 
-- The worst case occurs when the two inputs are consecutive Fibonacci numbers. For example, for 16 bits numbers, 
-- the maximum number of iteration is 22. 
-- Since this hardware iterates in space, it instantiates MAX_ITERATIONS PE's regardless of the actual input values.
-- If the GCD is found in the middle of PE array, it just does NOP (don't make any change to numbers) for the 
-- rest of the PE's.
-- The processor outputs the first GCD MAX_ITERATIONS clocks after the time when the first pair of inputs were
-- provided. After the first GCD, it outputs the computed GCD every clock. This is possible due to the processor's
-- pipelined PE's.
-- There is one preprocessing stage before pushing the inputs into PE arrays. The preprocessing step checks if 
-- one or both input numbers are zero. If there is a zero, it resets both inputs to zero. By doing this step, the 
-- processor can make sure that it just outputs zero as GCD. If both inputs are reset to zero at the preprocessing 
-- stage, the PE arrays will not change any inputs and eventually output zero as GCD.
-- In summary, the GCD processor can handle one or both numbers being zero. If this is the case, the GCD processor
-- will output zero as GCD (GCD(0,X) = 0 , GCD(X,0) = 0 , GCD(0,0) = 0) The processor can also calculate the GCD
-- correctly regardless of either number being the larger one. Since each PE's size is O(n^2) due to the parallel 
-- dividers and we have O(n) PE's, the total processor size is O(n^3).
--
--Entity Generics/Ports Information
--	Generic
--		NUM_BITS       : Size of inputs
--      MAX_ITERATIONS : Number of iterations for the worst case (consecutive Fibonacci numbers)
--	Inputs
-- 	    Clk    : System clock  (1 bit)
--	    OpA	   : First input   (NUM_BITS bits)
--	    OpB    : Second input  (NUM_BITS bits)
--	Outputs
--	    GCD	   : GCD of two numbers (NUM_BITS bits)
--
--Revision History
--  03/05/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GCD_Processor is
generic(NUM_BITS: natural := 16; MAX_ITERATIONS: natural := 22);
port(
    Clk: in std_logic;
    OpA: in std_logic_vector(NUM_BITS-1 downto 0);
    OpB: in std_logic_vector(NUM_BITS-1 downto 0);
    GCD: out std_logic_vector(NUM_BITS-1 downto 0)
);
end GCD_Processor;

architecture Behavioral of GCD_Processor is

-- First input (OpA) after the preprocessing
signal OpA_Preprocessed : std_logic_vector(NUM_BITS-1 downto 0);
-- Second input (OpB) after the preprocessing
signal OpB_Preprocessed : std_logic_vector(NUM_BITS-1 downto 0);

-- Processing Elements(PE) to be instantiated for the GCD processor
component GCD_PE is
generic( NUM_BITS: natural := 16); 
port(
    Clk     : in std_logic;
    OpA_In  : in std_logic_vector(NUM_BITS-1 downto 0);
    OpB_In  : in std_logic_vector(NUM_BITS-1 downto 0);
    OpA_Out : out std_logic_vector(NUM_BITS-1 downto 0);
    OpB_Out : out std_logic_vector(NUM_BITS-1 downto 0)
    );
end component;

-- Signals between the processing elements
type InternalOperand is array (0 to MAX_ITERATIONS-1) of std_logic_vector(NUM_BITS-1 downto 0);

-- Operand A signal between the processing elements. Used to glue the PE's together
signal OpA_Internal: InternalOperand;
-- Operand B signal between the processing elements. Used to glue the PE's together
signal OpB_Internal: InternalOperand;

begin

	-- Preprocessing stage
	-- This process preprocesses the inputs.
	-- If one or both inputs are zero, it resets both inputs to zero.
	-- In this way, we can obtain the GCD value of zero without error. If both inputs are reset to zero, the PE's
	-- will not change the inputs and just output zero as the result GCD
    process(OpA, OpB)
    begin
        OpA_Preprocessed <= OpA; -- If neither of the inputs are zero, the inputs will skip the preprocessing step
        OpB_Preprocessed <= OpB;
        if(unsigned(OpA) = 0 or unsigned(OpB) = 0) then -- If one or both inputs are zero, reset both to zero to
														-- obtain GCD = 0
            OpA_Preprocessed <= (others => '0');
            OpB_Preprocessed <= (others => '0');
        end if;
    end process;
    
	
	-- Instantiate first PE
	-- The first PE needs to be instantiated separately, since it has to receive the preprocessed input numbers
    Gen_FirstPE: GCD_PE 
        generic map(NUM_BITS => NUM_BITS) 
        port map(
                Clk => Clk,
                OpA_In => OpA_Preprocessed,
                OpB_In => OpB_Preprocessed,
                OpA_Out => OpA_Internal(0),
                OpB_Out => OpB_Internal(0)
                );

	-- Instantiate the rest of the PE's
	-- The GCD processor implements MAX_ITERATIONS PE's (including the first PE) to calculate GCD successfully 
	-- even in the worst case when the numbers are consecutive Fibonacci numbers
    Gen_PEs: for i in 0 to MAX_ITERATIONS-2 generate
        PE: GCD_PE 
            generic map(NUM_BITS => NUM_BITS)
            port map(
                    Clk => Clk,
                    OpA_In => OpA_Internal(i),
                    OpB_In => OpB_Internal(i),
                    OpA_Out => OpA_Internal(i+1),
                    OpB_Out => OpB_Internal(i+1)
                    );
     end generate;
     
	 -- The computed GCD is equivalent to the OpA output of the last PE
     GCD <= OpA_Internal(MAX_ITERATIONS-1);
                    
                    

end Behavioral;
