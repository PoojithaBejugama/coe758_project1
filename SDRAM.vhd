----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:58:16 10/01/2024 
-- Design Name: 
-- Module Name:    SDRAM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SDRAM is
    Port ( 	clk: in STD_LOGIC;
		  SDRAM_ADDR : in  STD_LOGIC_VECTOR (15 downto 0);
        SDRAM_WR_RD : in  STD_LOGIC_VECTOR (0 downto 0);
		  MSTRB : in  STD_LOGIC_VECTOR (0 downto 0); --this is MEMSTRB
		  SDRAM_Din : in  STD_LOGIC_VECTOR (7 downto 0);
		  SDRAM_Dout : out  STD_LOGIC_VECTOR (7 downto 0));
end SDRAM;

architecture Behavioral of SDRAM is
	type memoryArray is array(7 downto 0, 31 downto 0) of std_logic_vector(7 downto 0);
	signal memory: memoryArray;
	signal counter: integer := 0;
begin

process(clk)
	begin
		if clk'event and clk = '1' then
			if counter = 0 then 
				for row in 0 to 7 loop--number of block
					for col in 0 to 31 loop --words in each block 
						memory(row,col) <= "00000000";
					end loop;
				end loop;
				counter <= 1;
			end if;
		
			if MSTRB = '1' then
				if(SDRAM_WR_RD = '1') then
					-- data in (Din) from cache will be stored to main memory
					memory(to_integer(unsigned(SDRAM_ADDR(7 downto 5))), to_integer(unsigned(SDRAM_ADDR(4 downto 0)))) <= SDRAM_Din; --index is 3 bits and offset si 5 bits
				else
				--data from memeory is stpred in Dout and then sent back to cache
					SDRAM_Dout <= memory(to_integer(unsigned(SDRAM_ADDR(7 downto 5))), to_integer(unsigned(SDRAM_ADDR(4 downto 0))));
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;

		
	
			

