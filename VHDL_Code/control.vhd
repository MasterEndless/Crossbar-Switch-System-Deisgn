library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
port(       
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
end control;


architecture behavior of control is

-- Behaviour follows the 'classic' state machine method
    -- Possible states.

    type states is (poll_fifo, raise_enable, check_data, setup_x, setup_y, setup_xy, data_xfer, data_yfer, data_xyfer);

    -- Present state.

    signal present_state : states;

begin

    -- Main process.

    process (clk, reset)

    begin

        -- Activities triggered by asynchronous reset (active low).

        if (reset = '0') then

            -- Set the default state and outputs.

            present_state <= poll_fifo;
            enable <= '0';
            reqx <= '0';
            reqy <= '0';
            write <= '0';
            x_write <= '0';
            y_write <= '0';
            

        elsif (clk'event and clk = '1') then

            -- Set the default state and outputs.

            present_state <= poll_fifo;
            enable <= '0';
            reqx <= '0';
            reqy <= '0';
            write <= '0';
            x_write <= '0';
            y_write <= '0';

            case present_state is

                when poll_fifo =>
                    if(available='1')then
                        present_state <= raise_enable;
                    else
                        present_state <= poll_fifo;
                    end if;

			

                when raise_enable =>
                    enable <= '1';
                    present_state <= check_data;

			
 
                when check_data =>
                    enable <= '0';
                    if data_in(7)='1' then
                        present_state <= setup_xy;
                    elsif(data_in(0)='0') then
                        present_state <= setup_x;
                    elsif(data_in(0) = '1') then
                        present_state <= setup_y;
                    end if;
                

                when setup_x =>
			         reqx<='1';
			         if(gntx='1')then
			             present_state<=data_xfer;
			         else
			             present_state<=setup_x;
			         end if;
			         
			

                when setup_y =>
                    reqy<='1';
			        if(gnty='1')then
                        present_state<=data_yfer;
                    else
                        present_state<=setup_y ;
                    end if;

                when setup_xy =>
                    reqy<='1';
                    reqx<='1';
			        if(gnty='1' and gntx='1')then
                        present_state<=data_xyfer;
                    else
                        present_state<=setup_xy ;
                    end if;			

                when data_xfer =>
                    reqx<='1';
                    write <= '1';
                    y_write<='1';
                    enable<='1';
                    if(data_in = "11111111")then
                        enable<='0';
                        present_state <= poll_fifo;
                    else
                        present_state <= data_xfer;
                    end if;
                   

                when data_yfer =>
                    reqy<='1';
                    write <= '1';
                    x_write<='1';
                    enable <= '1';
                    if(data_in="11111111")then
                        enable<='0';
                        present_state<=poll_fifo;
                    else
                        enable<='1';
                        present_state<=data_yfer;
                    end if;
		
                when data_xyfer =>
                        reqy<='1';
                        reqx<='1';
                        write <= '1';
                        x_write<='1';
                        y_write<='1';
                        enable <= '1';
                        if(data_in="11111111")then
                            enable<='0';
                            present_state<=poll_fifo;
                        else
                            enable<='1';
                            present_state<=data_xyfer;
                        end if;
                        
                        
                when others =>
                    present_state <= poll_fifo;
                    enable <= '0';
                    reqx <= '0';
                    reqy <= '0';
                    x_write <= '0';
                    y_write <= '0';

            		
			
            end case;

        end if;

    end process;

end behavior;
