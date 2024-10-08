----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:19:17 10/12/2023 
-- Design Name: 
-- Module Name:    cache - Behavioral 
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

entity cache is
    Port ( ADDR_from_cpu : in  STD_LOGIC_VECTOR (15 downto 0);
           WR_RD_from_cpu : in  STD_LOGIC;
           CS_from_cpu : in  STD_LOGIC;
           ADDR_out_to_main : out  STD_LOGIC_VECTOR (15 downto 0);
           WR_RD_out_to_main : out  STD_LOGIC;
           MSTRB : out  STD_LOGIC;
           demux_out_0 : out  STD_LOGIC_VECTOR (7 downto 0);
           demux_out_1 : out  STD_LOGIC_VECTOR (7 downto 0);
           mux_in_0 : in  STD_LOGIC_VECTOR (7 downto 0);
           mux_in_1 : in  STD_LOGIC_VECTOR (7 downto 0);
			RDY	:	out	STD_LOGIC; --goes to CPU from cache
			clk	:	in STD_LOGIC; -- from cpu
			debug_state : OUT std_logic_vector(2 downto 0); --current state of cache controller goes to SDRAM
			debug_table_match :	out STD_logic; --goes to sdram
			debug_hit	: out std_logic;-- goes to sdram
			debug_addr_to_sram : out std_logic_vector(7 downto 0) --goes to sram 
			);
end cache;

architecture Behavioral of cache is

--signal declaration
--general signals - for multiplexers(will be assigned in cacheController)
signal demux_out_sel : STD_LOGIC;
signal mux_in_sel	: STD_LOGIC;
signal WEN	: STD_LOGIC_VECTOR(0 DOWNTO 0);
-- address being sent to cache memory(SRAM)
signal SRAM_in_addr	: STD_LOGIC_VECTOR (7 DOWNTO 0);

--cache memory(SRAM) signals
signal SRAM_Din : STD_LOGIC_VECTOR(7 downto 0);
signal SRAM_Dout : STD_LOGIC_VECTOR(7 downto 0);





--component declaration
--general declaration
COMPONENT mux2to1
	PORT(
		d0 : IN std_logic_vector(7 downto 0);
		d1 : IN std_logic_vector(7 downto 0);
		sel : IN std_logic;          
		d_out : OUT std_logic_vector(7 downto 0)
		);
END COMPONENT;

COMPONENT demux2to1
	PORT(
		d_in : IN std_logic_vector(7 downto 0);
		sel : IN std_logic;          
		d0 : OUT std_logic_vector(7 downto 0);
		d1 : OUT std_logic_vector(7 downto 0)
		);
END COMPONENT;

--cache memory
	COMPONENT Cache_SRAM
	PORT(
		ADDR : IN std_logic_vector(7 downto 0);
		WEN : IN std_logic_vector (0 downto 0);
		Din : IN std_logic_vector(7 downto 0);
		clk : IN std_logic;          
		Dout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

--cache controller
COMPONENT cacheController
	PORT(
		ADDR_in : IN std_logic_vector(15 downto 0);
		WR_RD_in : IN std_logic;
		CS : IN std_logic;     
		clk : IN std_logic;
		ADDR_out : OUT std_logic_vector(15 downto 0);
		RDY : OUT std_logic;
		WR_RD_out : OUT std_logic;
		MSTRB : OUT std_logic;
		Dout_sel : OUT std_logic;
		Din_sel : OUT std_logic;
		WEN : OUT std_logic_vector(0 downto 0);
		C_addr : OUT std_logic_vector(7 downto 0);
		debug_state : out std_logic_vector(2 downto 0);
		debug_hit : out std_logic;
		debug_table_match : out std_logic
		);
END COMPONENT;

--COMPONENT bram
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--  );
--END COMPONENT;

begin

debug_addr_to_sram <= C_addr;
--cache memory
 
	Inst_Cache_SRAM: Cache_SRAM PORT MAP(
		ADDR => C_addr,
		WEN => WEN,
		Din => SRAM_Din,
		Dout => SRAM_Dout,
		clk => clk
	);
 --!!!!!when cache controller is change CHANGE THIS!!!!!!!!!!!!!!!!!!!
controller : cacheController PORT MAP(
	ADDR_from_cpu => ADDR_from_cpu,
	WR_RD_from_cpu => WR_RD_from_cpu,
	CS_from_cpu => CS_from_cpu,
		clk => clk, 
		ADDR_out_to_main => ADDR_out_to_main,
		WR_RD_out_to_main => WR_RD_out_to_main,
		MSTRB => MSTRB,
		--the select signals come from cache controller
		demux_out_sel => demux_out_sel, --select signal for demux
		mux_in_sel => mux_in_sel, -- select signal for mux
		SRAM_WEN => WEN,
		SRAM_in_addr => SRAM_in_addr,
		RDY_TO_CPU => RDY,
		-- debug_state => debug_state, 
		-- debug_hit => debug_hit,
		-- debug_table_match => debug_table_match
	);
--for port mapping left side is always the same as component declaration
--and right side is from this current component i.e. cache 	
multiplexer: mux2to1 PORT MAP(
	d0 => mux_in_0,
	d1 => mux_in_1,
	sel => mux_in_sel,
	d_out => SRAM_Din
	);
	
demux: demux2to1 PORT MAP(
		d0 => demux_out_0,
		d1 => demux_out_1,
		d_in => SRAM_Dout,
		sel => demux_out_sel
	);
	
end Behavioral;