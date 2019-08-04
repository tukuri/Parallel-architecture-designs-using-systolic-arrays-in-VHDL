--Entity Name: 
-- 	ResDivider
--
--Description: 
-- 	This is an unsigned parallel divider that divides the dividends of NUM_BITS size by the divisors of NUM_BITS 
--  size, by using a restoring division algorithm. The restoring divider is implemented by an array of controlled 
--  substractors. It is comprised of NUM_BITS controlled subtractors rows, while each row is comprised of NUM_BITS 
--  bit-wise controlled subtractors. Overall, restoring divider is implemented by NUM_BITS^2 bit-wise controlled 
--  Subtractors. The restoring dividing algorithm repeats subtracting the divisor from dividend or transferring the 
--  previous partial remainder to the next row depending on the SUB signal, while shifting the dividend by one-bit 
--  per row. Each bit of quotient is determined by the CarryOut bit of each row (Q(n)= NOT CarryOut(n)). 
--  The entity instantiates multiple controlled subtractor rows to easily implement the divisor through hierarchical
--  implmentation. The parallel divider is purely combinatorial and thus outputs the result after a certain 
--  combinatorial delay.
--
--Entity Generics/Ports Information
--	Generic
--		NUM_BITS  : Size of dividends and divisors
--	Inputs
--		Dividend  : Unsigned dividend (NUM_BITS bits)
--      Divisor   : Unsigned divisor (NUM_BITS bits)
--	Outputs
--      Quotient  : quotient (NUM_BITS bits)
--      Remainder : remainder (NUM_BITS bits)
--
--Revision History
--	03/05/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ResDivider is
generic (NUM_BITS : natural := 16);
port(
    Dividend: in std_logic_vector(NUM_BITS-1 downto 0);
    Divisor: in std_logic_vector(NUM_BITS-1 downto 0);
    Quotient: out std_logic_vector(NUM_BITS-1 downto 0);
    Remainder: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end ResDivider;

architecture Behavioral of ResDivider is

-- Use the controlled subtractor rows to build an array of controlled subtractors
-- Each row is comprised of NUM_BITS bitwise controlled subtractors
component CtrlSubRow is
generic (NUM_BITS : natural := 16);
port(
    divisor_in_row: in std_logic_vector(NUM_BITS-1 downto 0);
    partial_rem_row: in std_logic_vector(NUM_BITS-1 downto 0);
    quotient_bit: out std_logic;
    s_out_row: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end component;

-- Extended dividend padded with zeros for division
signal padded_dividend: std_logic_vector(NUM_BITS*2-2 downto 0);

-- Type definition for an array that stores the partial remainders inside a restoring divisor
type partial_rem_array_type is array (NUM_BITS-1 downto 0) of std_logic_vector(NUM_BITS-1 downto 0);
-- An array that stores the partial remainders
signal sig_partial_rem_array: partial_rem_array_type;
-- An array that stores the shifted partial remainders
signal sig_shifted_partial_rem_array: partial_rem_array_type;

begin
	-- Store the dividend in the padded dividend input
    padded_dividend(NUM_BITS-1 downto 0) <= Dividend;
	-- Clear the high bits into zero to initiate division
    padded_dividend(NUM_BITS*2-2 downto NUM_BITS) <= (others => '0');

	-- Generate the top row of controlled subtractors
	-- Top row needs to be instantiated separately, since it receives the input of padded_dividend
     GenTopRow : CtrlSubRow 
                generic map(NUM_BITS => NUM_BITS)
                port map(
                        divisor_in_row => Divisor,
                        partial_rem_row => padded_dividend(NUM_BITS*2-2 downto NUM_BITS-1),
                        quotient_bit => Quotient(NUM_BITS-1),
                        s_out_row => sig_partial_rem_array(NUM_BITS-1)
                        );
						
	-- Generate the rest of the rows
	-- Divisor is shared by all controlled subtractors
	-- Each row outputs one quotient
    GenRows: for i in NUM_BITS-2 downto 0 generate
                     -- shift the partial remainder and append a bit from the dividend
                     sig_shifted_partial_rem_array(i) <= sig_partial_rem_array(i+1)(NUM_BITS-2 downto 0) & 
                                                         padded_dividend(i);
                     EachRow: CtrlSubRow 
                     generic map(NUM_BITS => NUM_BITS) 
                     port map(
                            divisor_in_row => Divisor,
                            partial_rem_row => sig_shifted_partial_rem_array(i),
                            quotient_bit => Quotient(i),
                            s_out_row => sig_partial_rem_array(i)
                            );
             end generate;
     
	-- Remainder is the equivalent to the partial remainder output of the last row (bottom in the divisor array)
   Remainder <= sig_partial_rem_array(0);

end Behavioral;
