----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/26 15:40:42
-- Design Name: 
-- Module Name: top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- for internal counter etc.

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_tb is
end top_tb;

architecture behavioral of top_tb is
	component control
		PORT(
            enable : OUT std_logic;
            reqx : OUT std_logic;
            reqy : OUT std_logic;
            write: OUT std_logic;
            x_write : OUT std_logic;
            y_write : OUT std_logic;
            available : IN std_logic;
            clk : IN std_logic;
            data_in : IN std_logic_vector(7 DOWNTO 0);
            gntx : IN std_logic;
            gnty : IN std_logic;
            reset : IN std_logic;
            header_LSB : IN std_logic
        );
		
	end component;
	--INPUT
	signal clk: std_logic;
	signal r_n: std_logic;
	signal stim_xdata: std_logic_vector(7 downto 0);
	signal stim_ydata: std_logic_vector(7 downto 0);
	signal stim_xavail: std_logic :='0';
	signal stim_yavail: std_logic :='0';
	signal gntx: std_logic :='0';
	signal gnty: std_logic :='0';
	--OUTPUT
	signal stim_xenable: std_logic :='0';
	signal stim_yenable: std_logic :='0';
	signal writex: std_logic :='0';
    signal writey: std_logic :='0';
	signal x_writex: std_logic :='0';
	signal x_writey: std_logic :='0';
	signal y_writex: std_logic :='0';
    signal y_writey: std_logic :='0';
	signal x_reqx: std_logic :='0';
	signal x_reqy: std_logic :='0';
	signal y_reqx: std_logic :='0';
    signal y_reqy: std_logic :='0';
    signal header_LSB: std_logic :='0';
--    signal data_out: std_logic_vector(7 downto 0);
	
	signal xdata_out: std_logic_vector(7 downto 0);
	signal ydata_out: std_logic_vector(7 downto 0);
	--VARIABLE
	----stim_xbar.vhd
	signal internalclock : std_logic; -- internal clock
	signal dummy : std_logic; -- dummy signal
	----output.vhd
	type states is (poll_x, poll_y, grant_x, grant_y);
	-- Present state.
	signal present_state_x : states;
	signal present_state_y : states;
	
	
begin

	controlx:control port map(  
        --Input
		clk=>clk,
		reset=>r_n,
		data_in=>stim_xdata,
		available=>stim_xavail,
		gntx=>gntx,
		gnty=>gnty,
		--Output
		enable=>stim_xenable,
		write=>writex,
		x_write=>x_writey,
		reqx=>x_reqx,
		reqy=>x_reqy,
		header_LSB=>header_LSB
        ); 
	controly:control port map(  
        --Input
		clk=>clk,
		reset=>r_n,
		data_in=>stim_ydata,
		available=>stim_yavail,
		gntx=>gntx,
		gnty=>gnty,
		--Output
		enable=>stim_yenable,
		write=>writey,
		y_write=>y_writex,
		reqx=>y_reqx,
		reqy=>y_reqy,
		header_LSB=>header_LSB
        );
	
	resetgen : process
	begin -- process resetgen
		r_n <= '0';
		wait for 2450 ns;
		r_n <= '1';
	-- Add more entries if required at this point !

		wait until dummy'event;
	end process resetgen;

	-- purpose: Generates the internal clock source. This is a 50% duty
	-- cycle clock source, period 1000ns, with the first half of
	-- the cycle being logic '0'.
	--
	-- outputs: internalclock
	clockgen : process
	begin -- process clockgen
		internalclock <= '0';
		wait for 500 ns;
		internalclock <= '1';
		wait for 500 ns;
	end process clockgen;
	-- purpose: Generates the stimuli for the data, using a counter based
	-- approach which is much cleaner than explicit timings
	--
	-- outputs: stim_inst
	-- stim_a
	-- stim_b

-- x -> x
	datagen1 : process
	-- Since we're going to output a number of different test
	-- data we need an internal counter to keep track of things.

	variable count : unsigned (5 downto 0) := "000000";
	begin -- process datagen1
		wait until internalclock'event and internalclock = '1';
		count := count + 1;
		if count = 4 then -- simple data transfer x -> x
			stim_xavail <= '1'; -- data flag raised
			wait until internalclock'event and internalclock = '1'
			and stim_xenable = '1';

			stim_xdata <= "10000010"; -- header word pushed when system
			stim_xavail <= '0'; -- requests transfer, and flag back down

			wait until internalclock'event and internalclock = '1'
			and stim_xenable = '1';

            stim_xdata <= "10000010";
            
			wait until internalclock'event and internalclock = '1'
			and stim_xenable = '1';

			stim_xdata <= "11100111"; -- data word pushed

			wait until internalclock'event and internalclock = '1'
			and stim_xenable = '1';

			stim_xdata <= "11111111"; -- end word pushed
		elsif count = 5 then    -- NO OPERATION
			stim_xavail <= '0';
			stim_xdata <= "00000000";
		else  -- NO OPERATION
			stim_xavail <= '0';
			stim_xdata <= "00000000";
		end if;
end process datagen1;
	
-- x -> y
	datagen2 : process
        -- Since we're going to output a number of different test
        -- data we need an internal counter to keep track of things.
    
        variable count : unsigned (5 downto 0) := "000000";
        begin -- process datagen1
            wait until internalclock'event and internalclock = '1';
            count := count + 1;
            if count = 4 then -- simple data transfer x -> y
                stim_xavail <= '1'; -- data flag raised
                wait until internalclock'event and internalclock = '1'
                and stim_xenable = '1';
    
                stim_xdata <= "00000001"; -- header word pushed when system
                stim_xavail <= '0'; -- requests transfer, and flag back down
    
                wait until internalclock'event and internalclock = '1'
                and stim_xenable = '1';
                stim_xdata <= "00000001";
    
                wait until internalclock'event and internalclock = '1'
                and stim_xenable = '1';
                stim_xdata <= "10101011"; -- data word pushed
    
                wait until internalclock'event and internalclock = '1'
                and stim_xenable = '1';
    
                stim_xdata <= "11111111"; -- end word pushed
            elsif count = 5 then    -- NO OPERATION
                stim_xavail <= '0';
                stim_xdata <= "00000000";
            else  -- NO OPERATION
                stim_xavail <= '0';
                stim_xdata <= "00000000";
            end if;
        end process datagen2;

-- y -> x
datagen3 : process
        -- Since we're going to output a number of different test
        -- data we need an internal counter to keep track of things.
    
        variable count : unsigned (5 downto 0) := "000000";
        begin -- process datagen1
            wait until internalclock'event and internalclock = '1';
            count := count + 1;
            if count = 4 then -- simple data transfer y -> x
                stim_yavail <= '1'; -- data flag raised
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "10000010"; -- header word pushed when system
                stim_yavail <= '0'; -- requests transfer, and flag back down
    
    
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
                                  
                stim_ydata <= "10000010"; -- header word pushed when system
                
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "10111010"; -- data word pushed
    
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "11111111"; -- end word pushed
            elsif count = 5 then    -- NO OPERATION
                stim_yavail <= '0';
                stim_ydata <= "00000000";
            else  -- NO OPERATION
                stim_yavail <= '0';
                stim_ydata <= "00000000";
            end if;
        end process datagen3;



-- y -> y
datagen4 : process
        -- Since we're going to output a number of different test
        -- data we need an internal counter to keep track of things.
    
        variable count : unsigned (5 downto 0) := "000000";
        begin -- process datagen1
            wait until internalclock'event and internalclock = '1';
            count := count + 1;
            if count = 4 then -- simple data transfer y -> y
                stim_yavail <= '1'; -- data flag raised
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "00000001"; -- header word pushed when system
                stim_yavail <= '0'; -- requests transfer, and flag back down
                
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
                stim_ydata <= stim_ydata; -- header word pushed again
                
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "10101010"; -- data word pushed
    
                wait until internalclock'event and internalclock = '1'
                and stim_yenable = '1';
    
                stim_ydata <= "11111111"; -- end word pushed
                    
             
            elsif count = 5 then    -- NO OPERATION
                stim_yavail <= '0';
                stim_ydata <= "00000000";
            else  -- NO OPERATION
                stim_yavail <= '0';
                stim_ydata <= "00000000";
            end if;
        end process datagen4;




	-- *************************************


	-- now drive the output clock, this is simply the internal clock
	-- nb: could also invert the clock if desired to allow for signals
	-- to be generated pseudo-asynchronously

	clk <= internalclock;
 
	--output.vhd
	--  x-output
	x_output: process (clk, r_n)
	begin
	-- Activities triggered by asynchronous reset (active low).
		if (r_n = '0') then
		-- Set the default state and outputs.
			present_state_x <= poll_x;
			gntx <= '0';
			xdata_out <= "00000000";
		elsif (clk'event and clk = '1') then
		-- Set the default state and outputs.
			present_state_x <= poll_x;
			gntx <= '0';
			xdata_out <= "00000000";
			case present_state_x is                                                                                                                                                                                                                                                                                                                                      

				when poll_x =>
					if (x_reqx = '1' or y_reqx = '1') then
						present_state_x <= grant_x;
					else
						present_state_x <= poll_x;
					end if;
	
				when grant_x =>
					if (y_writex = '1') then
					    xdata_out <= stim_ydata;
					elsif (writex = '1') then
					    xdata_out <= stim_xdata;
					end if;
					if (x_reqx = '1' or y_reqx='1') then
					    present_state_x <= grant_x;
					else
						present_state_x <= poll_x;
					end if;
					gntx <= '1';
		
				when others =>
					-- Set the default state and outputs.
					present_state_x <= poll_x;
					gntx <= '0';
					xdata_out <= "00000000";
			end case;
		end if;
	end process;
	--  y-output
	y_output: process (clk, r_n)
        begin
        -- Activities triggered by asynchronous reset (active low).
            if (r_n = '0') then
            -- Set the default state and outputs.
                present_state_y <= poll_x;
                gnty <= '0';
                ydata_out <= "00000000";
            elsif (clk'event and clk = '1') then
            -- Set the default state and outputs.
                present_state_y <= poll_y;
                gnty <= '0';
                ydata_out <= "00000000";
                case present_state_y is                                                                                                                                                                                                                                                                                                                                      
                    
                    
                    when poll_y =>
                        if (x_reqy = '1' or y_reqy = '1') then
                            present_state_y <= grant_y;
                        else
                            present_state_y <= poll_y;
                        end if;
                    
    
                    
                    when grant_y =>
                        if (x_writey = '1') then
                            ydata_out <= stim_xdata;
                        elsif (writey = '1') then
                            ydata_out <= stim_ydata;
                        end if;
                        if (x_reqy = '1' or y_reqy = '1') then
                            present_state_y <= grant_y;
                        else
                            present_state_y <= poll_y;
                        end if;
                        gnty <= '1';
    
                        
                    
                    when others =>
                        -- Set the default state and outputs.
                        present_state_y <= poll_y;
                        gnty <= '0';
                        ydata_out <= "00000000";
                end case;
            end if;
        end process;
	
	
	
	
	
	
	
	
	
	
end behavioral;