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
		ADDR_from_cpu : in  STD_LOGIC_VECTOR (15 downto 0);
		WR_RD_from_cpu : in  STD_LOGIC_VECTOR (0 downto 0);
		CS_from_cpu : in  STD_LOGIC_VECTOR (0 downto 0);
           clk : in  STD_LOGIC_VECTOR (0 downto 0);
		--Ouputs to SDRAM
			ADDR_out_to_main : out  STD_LOGIC_VECTOR (15 downto 0);
			WR_RD_out_to_main : out  STD_LOGIC_VECTOR (0 downto 0);
           MSTRB : out  STD_LOGIC_VECTOR (0 downto 0);
		
		--Outputs to SRAM
           demux_out_sel : out  STD_LOGIC_VECTOR (0 downto 0);
		   mux_in_sel : out  STD_LOGIC_VECTOR (0 downto 0);
           SRAM_WEN : out  STD_LOGIC_VECTOR (0 downto 0);
           SRAM_in_addr : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  RDY_TO_CPU : out  STD_LOGIC_VECTOR (0 downto 0)
			  
			  );
			  
end cacheController;

architecture Behavioral of cacheController is

--SIGNAL DECLARATIONS
	--CPU Signals
	signal DOUT_CPU, DIN_CPU	: STD_LOGIC_VECTOR(7 downto 0); -- data from CPU and data to CPU
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

	--controller table signals
	signal table_data_out	: std_logic_vector(9 downto 0);
	signal old_tag_from_table: std_logic_vector(7 downto 0);
	signal valid_bit_from_table: std_logic;
	signal dirty_bit_from_table: std_logic;
	signal tag_match: std_logic;


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
	
	
	--State Signals
	--Hit/Miss			        --0000 : state0
	--Load from Main Memory 	--0001 : state1
	--Write back to Main Memory	--0010 : state2
	--IDLE 						--0011 : state3
	--READY 					--0100 : state4
	
--FSM signals:
TYPE STATETYPE IS (state_0, state_1, state_2, state_3, state_4, state_5);
SIGNAL present_state: STATETYPE := state_0;
signal state_value : std_logic_vector(3 downto 0);
SIGNAL counter : integer := 0;

	--signals for controller table register
		--3 bit index = index from address
		--10 bit data in = 8 bit tag, 1 bit Vbit, 1 bit Dbit
		--10 bit data out = 8 bit tag, 1 bit Vbit, 1 bit Dbit
		--we want output for tag comparision and checking Vbit and Dbit

	-- Define a register array to store cache entries (8 entries, each 10 bits wide - 8bit tag, Vbit and Dbit)
    type tableArray is array(0 to 7) of std_logic_vector(9 downto 0);  
    signal controller_table_register : tableArray := (others => (others => ('0')));   -- Initialize the registers to zero

	





begin

--PORT MAPPING


--PROCESS
process(clk)

--BEGIN
begin
	--extract tag, idex and offset from input address
	TAG <= ADDR_from_cpu(15 downto 8);
	INDEX <= ADDR_from_cpu(7 downto 5);
	OFFSET <= ADDR_from_cpu(4 downto 0);

	--now we read from controller table register to see if the tag matches

	--get data from controller table register
	-- On the rising edge of the clock read the data from the controller table register
	if rising_edge(clk) then
		table_data_out <= controller_table_register(to_integer(unsigned(INDEX)));  -- Convert address to integer for indexing
    end if;
	
	old_tag_from_table <= table_data_out(9 downto 2);
	valid_bit_from_table <= table_data_out(1);
	dirty_bit_from_table <= table_data_out(0);

		-- tag comaparision logic
		if (old_tag_from_table = TAG) then --if tag from table matches new tag
			tag_match <= '1'; -- tags match, possible cache hit

				--check if Vbit is set
			if (valid_bit_from_table = '1') then
				--Vbit is set, cache hit
				hit <= '1';
			else
				--Vbit is not set, cache miss
				hit <= '0';
			end if;

		else
			tag_match <= '0'; --tags dont match, definate miss
			hit <= '0';
		end if;

		
--STATE CODE


--end process






end Behavioral;




