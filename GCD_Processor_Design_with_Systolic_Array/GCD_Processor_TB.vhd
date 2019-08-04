--Testbench Name: 
-- 	GCD_Processor_TB
--
--Description: 
-- 	This is a testbench that verifies the GCD processor implemented with processing elements.
--	Given the size of inputs(NUM_BITS), the testbench generates random testvectors of inputs and their expected
--  GCDs. The expected GCDs are generated on testbench, using the Euclidean Division Algorithm. 
--  The testbench generates the NUM_TESTVECTOR testvectors comprised of:
-------------------------
-- Test Case 1 
-- input1: random integers in range [1, MAX_OPERAND]
-- input2: random integers in range [1, MAX_OPERAND]
-- * Either input can be the larger one. Expected GCD is calculated by the testbench
-------------------------
-- Test Case 2
-- input1: random integers in range [1, MAX_OPERAND]
-- input2: 0
-- * Expected GCD = 0
-------------------------
-- Test Case 3
-- input1: 0
-- input2: random in range [1, MAX_OPERAND]
-- * Expected GCD = 0
-------------------------
-- Test Case 4
-- input1: 0
-- input2: 0
-- * Expected GCD = 0
-------------------------
--  Note that MAX_OPERAND is the maximum possible value of an input given NUM_BITS (MAX_OPERAND = 2^NUM_BITS - 1)
--  The testbench waits MAX_ITERATIONS clocks for the GCD processor to start outputting the results every clock
--  Once the GCD processor outputs the first result, the testbench checks the outputs every clock since the GCD
--  processor can compute the GCD every clock.
--
--Revision History
--	03/07/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.all; -- Library for generating random numbers

entity GCD_Processor_TB is
end GCD_Processor_TB;

architecture Behavioral of GCD_Processor_TB is

component GCD_Processor is
generic(NUM_BITS: natural := 16; MAX_ITERATIONS: natural := 22);
port(
    Clk:in std_logic;
    OpA: in std_logic_vector(NUM_BITS-1 downto 0);
    OpB: in std_logic_vector(NUM_BITS-1 downto 0);
    GCD: out std_logic_vector(NUM_BITS-1 downto 0)
);
end component;

------------------- Configurable parameters -------------------------
-- The size of the input numbers
-- Change this value to test the inputs of different sizes
constant NUM_BITS: natural := 16;
-- Maximum number of iterations required for the worst case of Euclidean Division Algorithm
-- It can be calculated as 5*log(2^NUM_BITS-1) with log base 10, while n is the number of bits in each input
-- The worst case occurs when the inputs are two consecutive Fibonacci numbers
-- Change this value to test the inputs of different sizes
constant MAX_ITERATIONS: natural := 22;
---------------------------------------------------------------------

-- The maximum value of inputs given the number of bits. 2^NUM_BITS - 1
constant MAX_OPERAND: natural := 2**NUM_BITS-1;
-- Number of testvectors to be generated
constant NUM_TESTVECTOR: natural := 500;

-- System clock
signal Clk: std_logic := '1';
-- First input
signal OpA: std_logic_vector(NUM_BITS-1 downto 0);
-- Second input
signal OpB: std_logic_vector(NUM_BITS-1 downto 0);
-- GCD of the inputs
signal GCD: std_logic_vector(NUM_BITS-1 downto 0);
-- Indicates the end of simulation
signal END_SIM: std_logic := '0';

-- Type definition for the testvectors
type GCDProc_testvector is array(0 to NUM_TESTVECTOR-1) of std_logic_vector(NUM_BITS-1 downto 0);
-- Testvectors for the first input
signal A_testvector: GCDProc_testvector;
-- Testvectors for the second input
signal B_testvector: GCDProc_testvector;
-- Testvecotrs for the GCD's of the inputs
signal GCD_testvector: GCDProc_testvector;

begin
    
	-- Instantiate the GCD processor to test it
    UUT: GCD_Processor
        generic map(NUM_BITS => NUM_BITS, MAX_ITERATIONS => MAX_ITERATIONS)
        port map(
                Clk => Clk,
                OpA => OpA,
                OpB => OpB,
                GCD => GCD
                );
                
    -- Generate system clock to run the GCD processor            
    Clk <= not Clk after 50 ns;

	-- Generate the random testvectors
    Gen_Testvectors: process
		-- random input1 in integer
        variable A: integer;
		-- random input1 in real number
        variable A_real: real;
		-- random input1 in std_logic_vectot
        variable A_std: std_logic_vector(NUM_BITS-1 downto 0);
		-- random input2 in integer
        variable B: integer;
		-- random input2 in real number
        variable B_real: real;
		-- random input2 in std_logic_vector
        variable B_std: std_logic_vector(NUM_BITS-1 downto 0);
		-- remainder of A/B. Used for calculating the expected GCD's
        variable r: integer;
		-- expected GCD
        variable GCD_Expected: integer;
		-- expected GCD in std_logic_vector
        variable GCD_Expected_std: std_logic_vector(NUM_BITS-1 downto 0);
		-- first seed value for generating random inputs
        variable seed1: positive := 10;
		-- second seed value for generating random inputs
        variable seed2: positive := 1000;
    begin
        for i in 0 to NUM_TESTVECTOR-1 loop
			-- Test Case 1
			-- input1: random in range [1, MAX_OPERAND]
			-- input2: random in range [1, MAX_OPERAND]
            if(i < NUM_TESTVECTOR-20) then
				-- generate a random real value in [0,1] using seeds for input1
                uniform(seed1, seed2, A_real);
				-- generate a random real value in [0,1] using seeds for input2
                uniform(seed1, seed2, B_real); 
				-- scale the range and convert the type into integer ([0,1] -> [1,MAX_OPERAND])
				-- input1 = a random integer in [1, MAX_OPERAND]
                A := integer(A_real*(MAX_OPERAND-1) + 1.0);
				-- input2 = a random integer in [1, MAX_OPERAND}
                B := integer(B_real*(MAX_OPERAND-1) + 1.0);
				-- convert input1 into std_logic_vector
                A_std := std_logic_vector(to_unsigned(A, A_std'length));
				-- convert input2 into std_logic_vector
                B_std := std_logic_vector(to_unsigned(B, B_std'length));
                -- calculate the GCD of the generated inputs using the Euclidean Algorithm
                while( B /= 0) loop
                    r := A mod B;
                    A := B;
                    B := r;
                end loop;
				-- the expected GCD is equivalent to the last value of input1
                GCD_Expected := A;  
				
			-- Test Case 2
			-- input1: random in range [1, MAX_OPERAND]
			-- input2: 0
            elsif(i < NUM_TESTVECTOR-10) then
				-- generate a random real value in [0,1] using seeds for input1
                uniform(seed1, seed2, A_real); 
				-- input1 = a random integer in [1, MAX_OPERAND]
                A := integer(A_real*(MAX_OPERAND-1) +1.0);
				-- input2 = 0
                B := 0;
				-- convert input1 into std_logic_vector
                A_std := std_logic_vector(to_unsigned(A, A_std'length));
				-- convert input2 into std_logic_vector
                B_std := std_logic_vector(to_unsigned(B, B_std'length));
				-- expected GCD = 0
                GCD_Expected := 0;  
				
			-- Test Case 3
			-- input1: 0
			-- input2: random in range [1, MAX_OPERAND]
            elsif(i < NUM_TESTVECTOR-1) then
				-- input1 = 0
                A := 0;
				-- generate a random real value in [0,1] using seeds for input2
                uniform(seed1, seed2, B_real); 
				-- input2 = a random integer in [1, MAX_OPERAND]
                B := integer(B_real*(MAX_OPERAND-1)+1.0); -- Scaled random B. B = [1, MAX_OPERAND]
				-- convert input1 into std_logic_vector
                A_std := std_logic_vector(to_unsigned(A, A_std'length));
				-- convert input2 into std_logic_vector
                B_std := std_logic_vector(to_unsigned(B, B_std'length));
				-- expected GCD = 0
                GCD_Expected := 0;  
				
			-- Test Case 4
			-- input1: 0
			-- input2: 0
            else
				-- input1 = 0
                A := 0;
				-- input2 = 0
                B := 0;
				-- convert input1 into std_logic_vector
                A_std := std_logic_vector(to_unsigned(A, A_std'length));
				-- convert input2 into std_logic_vector
                B_std := std_logic_vector(to_unsigned(B, B_std'length));
				-- expected GCD = 0
                GCD_Expected := 0;  
            end if;
			-- convert the expected GCD into std_logic_vector
            GCD_Expected_std := std_logic_vector(to_unsigned(GCD_Expected,GCD_Expected_std'length));
			-- store the generated input1 into the testvector array
            A_testvector(i) <= A_std;
			-- store the generated input2 into the testvector array
            B_testvector(i) <= B_std;
			-- store the expected GCD into the testvector array
            GCD_testvector(i) <= GCD_Expected_std;      
        end loop;        
        wait;
    end process;

    
	-- Provide the inputs to GCD processor from the generated testvectors
	Stimulate_input: process
    begin
        wait for 10 ns;
		-- provide inputs every clock
        for i in 0 to NUM_TESTVECTOR-1 loop
            OpA <= A_testvector(i);
            OpB <= B_testvector(i);
            wait for 100 ns;
       end loop;
       wait;
    end process;

	-- Verify the results using the assert statements with the expected GCD's
    process
    begin
        wait for 10 ns;
		-- Need to wait MAX_ITERATIONS clocks for the GCD processor to start outputting the results every clock
        for i in 0 to MAX_ITERATIONS-1 loop
            wait for 100 ns;
        end loop;
		-- Verify the correctness of GCD every clock
        for i in 0 to NUM_TESTVECTOR-1 loop
            assert(std_match(GCD, GCD_testvector(i)))
            report "Error: GCD: " & integer'image(to_integer(unsigned(GCD))) 
                    & " Expected: " & integer'image(to_Integer(unsigned(GCD_testvector(i))))
            severity ERROR;
			-- wait for one cycle to check next GCD
            wait for 100 ns;       
        end loop;       
		-- Simulation is done
        END_SIM <= '1';
        wait;
    end process;

end Behavioral;
