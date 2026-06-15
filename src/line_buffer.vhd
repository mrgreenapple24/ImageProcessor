-- line_buffer.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity line_buffer is
    generic (
        IMG_WIDTH   : integer := 640;
        PIXEL_BITS  : integer := 8
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        pixel_in    : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        pixel_valid : in  std_logic;
        line_out_0  : out std_logic_vector(PIXEL_BITS-1 downto 0);
        line_out_1  : out std_logic_vector(PIXEL_BITS-1 downto 0);
        line_out_2  : out std_logic_vector(PIXEL_BITS-1 downto 0);
        buffer_ready: out std_logic
    );
end line_buffer;

architecture behavioral of line_buffer is
    type line_memory is array (0 to IMG_WIDTH-1) of std_logic_vector(PIXEL_BITS-1 downto 0);
    signal line_buffer_0, line_buffer_1, line_buffer_2 : line_memory;
    
    signal wr_ptr : integer range 0 to IMG_WIDTH-1 := 0;
    signal rd_ptr : integer range 0 to IMG_WIDTH-1 := 0;
    signal valid_counter : integer range 0 to IMG_WIDTH*3 := 0;
    signal buffer_filled : std_logic := '0';
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            valid_counter <= 0;
            buffer_filled <= '0';
            line_out_0 <= (others => '0');
            line_out_1 <= (others => '0');
            line_out_2 <= (others => '0');
            buffer_ready <= '0';
            
        elsif rising_edge(clk) then
            if pixel_valid = '1' then
                -- Write incoming pixel to line buffers
                if valid_counter < IMG_WIDTH then
                    line_buffer_0(wr_ptr) <= pixel_in;
                elsif valid_counter < IMG_WIDTH*2 then
                    line_buffer_1(wr_ptr) <= pixel_in;
                else
                    line_buffer_2(wr_ptr) <= pixel_in;
                end if;
                
                -- Update pointers
                if wr_ptr = IMG_WIDTH-1 then
                    wr_ptr <= 0;
                    if valid_counter < IMG_WIDTH*3 - 1 then
                        valid_counter <= valid_counter + 1;
                    else
                        buffer_filled <= '1';
                    end if;
                else
                    wr_ptr <= wr_ptr + 1;
                    valid_counter <= valid_counter + 1;
                end if;
                
                -- Output current window
                line_out_0 <= line_buffer_0(rd_ptr);
                line_out_1 <= line_buffer_1(rd_ptr);
                line_out_2 <= line_buffer_2(rd_ptr);
                
                if rd_ptr = IMG_WIDTH-1 then
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
                end if;
            end if;
            
            buffer_ready <= buffer_filled;
        end if;
    end process;
end behavioral;