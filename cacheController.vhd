----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:18:37 10/06/2024 
-- Design Name: 
-- Module Name:    cacheController - Behavioral 
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

entity cacheController is
    Port ( 
		--inputs from cpu
	 ADDR : in  STD_LOGIC_VECTOR (15 downto 0);
           WR_RD : in  STD_LOGIC_VECTOR (0 downto 0);
           CS : in  STD_LOGIC_VECTOR (0 downto 0);
           clk : in  STD_LOGIC_VECTOR (0 downto 0);
		--Ouputs to SDRAM
           ADDR_SDRAM : out  STD_LOGIC_VECTOR (15 downto 0);
           WR_RD_MEM : out  STD_LOGIC_VECTOR (0 downto 0);
           
           MSTRB : out  STD_LOGIC_VECTOR (0 downto 0);
		
		--Outputs to SDRAM
           DIN_SEL : out  STD_LOGIC_VECTOR (0 downto 0);
           DOUT_SEL : out  STD_LOGIC_VECTOR (0 downto 0);
           SR_WEN : out  STD_LOGIC_VECTOR (0 downto 0);
           SR_ADDR : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  RDY_TO_CPU : out  STD_LOGIC_VECTOR (0 downto 0)
			  
			  );
			  
end cacheController;

architecture Behavioral of cacheController is

--SIGNAL DECLARATIONS
	--CPU Signals
	signal DOUT_CPU, DIN_CPU	: STD_LOGIC_VECTOR(7 downto 0);
	signal ADDR_OUT_CPU 			: STD_LOGIC_VECTOR (15 downto 0);
	signal WR_RD_CPU, CS_CPU 	: STD_LOGIC;
	signal RDY_IN_CPU				: STD_LOGIC;
	signal TAG				      : STD_LOGIC_VECTOR(7 downto 0);
	signal INDEX				   : STD_LOGIC_VECTOR(2 downto 0);
	signal OFFSET		         : STD_LOGIC_VECTOR(4 downto 0);
	--signal Tag_index					: STD_LOGIC_VECTOR(10 downto 0);
	
--SRAM(cache memory) Signals
	signal Dbit				: STD_LOGIC_VECTOR(7 downto 0):= "00000000";
	signal Vbit				: STD_LOGIC_VECTOR(7 downto 0):= "00000000";
	signal SR_ADDR, SR_DIN, SR_DOUT 		: STD_LOGIC_VECTOR(7 downto 0);
	signal SR_WEN				: STD_LOGIC_VECTOR(0 DOWNTO 0);
	
	--HIT = 1, MISS = HIT = 0
	signal HIT				: STD_LOGIC := '0';
	
--SDRAM Signals
	signal SDRAM_DIN, SDRAM_DOUT	: STD_LOGIC_VECTOR(7 downto 0);
	signal SDRAM_ADDR					: STD_LOGIC_VECTOR(15 downto 0);
	signal SDRAM_MSTRB,SDRAM_WR_RD	: STD_LOGIC;
	signal counter						: integer := 0;
	
	--When writing or reading to main memory, this can be used to loop through words in main memory
	signal NEW_OFFSET					: integer := 0;
	
	
	--ICON & VIO  & ILA Signals
	signal control0 : STD_LOGIC_VECTOR(35 downto 0);
	signal ila_data : std_logic_vector(99 downto 0);
	signal trig0 	: std_logic_vector(0 TO 0);
	
	
	--state signals
	

--COMPONENT DECLARATIONS
component CPU_gen
    Port ( clk : in  STD_LOGIC_VECTOR (0 downto 0);
           rst : in  STD_LOGIC_VECTOR (0 downto 0);
           trig : in  STD_LOGIC_VECTOR (0 downto 0);
           Address : out  STD_LOGIC_VECTOR (15 downto 0);
           wr_rd : out  STD_LOGIC_VECTOR (0 downto 0);
           cs : out  STD_LOGIC_VECTOR (0 downto 0);
           Dout : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

component sram
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;

component SDRAM
    Port ( 	clk: in STD_LOGIC;
		  SDRAM_ADDR : in  STD_LOGIC_VECTOR (15 downto 0);
        SDRAM_WR_RD : in  STD_LOGIC_VECTOR (0 downto 0);
		  MSTRB : in  STD_LOGIC_VECTOR (0 downto 0); --this is MEMSTRB
		  SDRAM_Din : in  STD_LOGIC_VECTOR (7 downto 0);
		  SDRAM_Dout : out  STD_LOGIC_VECTOR (7 downto 0));
end component;


begin

--PORT MAPPING


--PROCESS

--BEGIN

--STATE CODE


--end process






end Behavioral;




