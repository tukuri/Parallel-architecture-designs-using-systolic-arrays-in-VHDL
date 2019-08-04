--Entity Name: 
-- 	CtrlSub
--
--Description: 
-- 	This is a bitwise controlled subtractor.
--  Depending on the sub control signal, it subtracts partial_rem from divisor_in, or just outputs the received
--  partial_rem itself. It also outputs a carry bit, which depends on the values of partial_rem, divisor_in, and 
--  c_in.
--
--Entity Generics/Ports Information
--	Inputs
--		divisor_in      : Unsigned divisor (1 bit)
--		partial_rem     : Partial remainder (1 bit)
--      c_in			: Carry in (1 bit)
--      sub_in          : Control signal that determines the operation of the subtractor (1 bit)
--  Outputs
--		s_out			: The calculation result (1 bit)
--					    : If sub_in is '1', s_out is the subtraction result
--                      : If sub_in is '0', s_out is equivalent to the partial_rem (partial remainder)
--      c_out           : Carry out (1 bit)
--Revision History
--	03/05/2019	Sung Hoon Choi	Created
--  03/08/2019  Sung Hoon Choi  Initial simulation
--  03/09/2019  Sung Hoon Choi  Added comments

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CtrlSub is
port(
    divisor_in     : in std_logic;
    partial_rem: in std_logic;
    c_in       : in std_logic;
    sub_in     : in std_logic;
    s_out      : out std_logic;
    c_out      : out std_logic
    );
end CtrlSub;

architecture Behavioral of CtrlSub is

begin
	-- calculate the carryout
    c_out <= (not partial_rem and divisor_in) or (not partial_rem and c_in) or (divisor_in and c_in);
	-- calculate the result
	-- If sub_in is '1', s_out is the subtraction result. If sub_in is '0', sub_in is equivalent to partial_rem
    s_out <= ((partial_rem  xor divisor_in xor c_in) and sub_in) or (partial_rem and not sub_in);

end Behavioral;
