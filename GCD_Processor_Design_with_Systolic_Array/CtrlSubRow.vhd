--Entity Name: 
-- 	CtrlSubRow
--
--Description: 
-- 	This is a row of controlled subtractors. The row is comprised of NUM_BITS bit-wise controlled subtractors.
--  It keeps subtracting the divisor from partial remainders or transferring the previous remaining remainder to 
--  next row depending on the value of Sub control signal. Sub control signals and quotient bits are determined by 
--  the carryout of each row. (Sub, Q = NOT carryout) Each row outputs one quotient bit. This row entity is called
--  by the restoring divider entity to generate an array of controlled subtractors.
--
--Entity Generics/Ports Information
--	Generic
--		NUM_BITS  : Size of dividends and divisors
--	Inputs
--		divisor_in_row  : Unsigned divisor (NUM_BITS bits)
--      partial_rem_row : Unsigned partial remainder (NUM_BITS bits)
--	Outputs
--      quotient_bit  : quotient bit from the current row (1 bit)
--      s_out_row     : The result of subtraction. It is equivalent to the partial remainder for next row
--                      (NUM_BITS bits)
--Revision History
--	03/05/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CtrlSubRow is
generic (NUM_BITS : natural := 16);
port(
    divisor_in_row: in std_logic_vector(NUM_BITS-1 downto 0);
    partial_rem_row: in std_logic_vector(NUM_BITS-1 downto 0);
    quotient_bit: out std_logic;
    s_out_row: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end CtrlSubRow;

architecture Behavioral of CtrlSubRow is

-- Call the bitwise controlled subtractor as a component to build the row
component CtrlSub is
port(
    divisor_in : in std_logic;
    partial_rem: in std_logic;
    c_in       : in std_logic;
    sub_in     : in std_logic;
    s_out      : out std_logic;
    c_out      : out std_logic
    );
end component;

-- Carries in the current row
signal carry: std_logic_vector(NUM_BITS downto 0);
-- Control signal that determines whether the current row should do subtraction, or just transfer the previous 
-- partial remainder to the next row
signal sub: std_logic;

begin
    
	-- sub control signal is equivalent to the negation of the leftmost carryout in the row
    sub <= not carry(NUM_BITS);
	-- quotient bit of the current row is equivalent to the negation of the leftmost carryout in the row
    quotient_bit <= not carry(NUM_BITS);
    
	-- Generate the entries in the row, except the rightmost entry
	-- Each entries perform the controlled subtraction and transfer the carries and results to adjacent entries
    Gen_Entries: for i in NUM_BITS-1 downto 1 generate
             Row: CtrlSub port map ( 
                                     divisor_in => divisor_in_row(i), 
                                     partial_rem => partial_rem_row(i),
                                     c_in => carry(i),
                                     sub_in => sub,
                                     s_out => s_out_row(i),
                                     c_out => carry(i+1)
                                     );
    end generate;
                   
	-- Generate the rightmost entry in the row
	-- The rightmost entry needs to be generated separately, since its carry input must be zero
     Gen_RightmostEntry: CtrlSub port map(
                                     divisor_in => divisor_in_row(0), 
                                     partial_rem => partial_rem_row(0),
                                     c_in => '0',
                                     sub_in => sub,
                                     s_out => s_out_row(0),
                                     c_out => carry(1)
                                     );
                                     
end Behavioral;
