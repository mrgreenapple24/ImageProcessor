-- fixed_image_processor.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fixed_image_processor is
    generic (
        IMG_WIDTH   : integer := 4;    -- Small for testing
        IMG_HEIGHT  : integer := 4;
        PIXEL_BITS  : integer := 8
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        pixel_in    : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        pixel_valid : in  std_logic;
        pixel_out   : out std_logic_vector(PIXEL_BITS-1 downto 0);
        pixel_ready : out std_logic;
        mode        : in  std_logic_vector(2 downto 0);
        process_en  : in  std_logic;
        busy        : out std_logic;
        done        : out std_logic
    );
end fixed_image_processor;

architecture behavioral of fixed_image_processor is
    type line_buffer_t is array (0 to IMG_WIDTH-1) of integer range 0 to 255;
    signal line0, line1, line2 : line_buffer_t := (others => 0);
    signal wr_ptr : integer range 0 to IMG_WIDTH-1 := 0;
    signal line_cnt : integer range 0 to 3 := 0;
    signal pixels_processed : integer range 0 to IMG_WIDTH*IMG_HEIGHT := 0;
    
    signal processing : std_logic := '0';
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset all signals
            wr_ptr <= 0;
            line_cnt <= 0;
            pixels_processed <= 0;
            processing <= '0';
            busy <= '0';
            done <= '0';
            pixel_ready <= '0';
            pixel_out <= (others => '0');
            
            -- Clear line buffers
            for i in 0 to IMG_WIDTH-1 loop
                line0(i) <= 0;
                line1(i) <= 0;
                line2(i) <= 0;
            end loop;
            
        elsif rising_edge(clk) then
            -- Default values
            pixel_ready <= '0';
            done <= '0';
            
            -- Process enable signal
            if process_en = '1' and processing = '0' then
                processing <= '1';
                busy <= '1';
                report "Processing started" severity note;
            end if;
            
            -- Input pixel handling
            if pixel_valid = '1' and processing = '1' then
                -- Store pixel in appropriate line buffer
                if line_cnt = 0 then
                    line0(wr_ptr) <= to_integer(unsigned(pixel_in));
                    report "Writing to line0, pixel: " & integer'image(to_integer(unsigned(pixel_in))) severity note;
                elsif line_cnt = 1 then
                    line1(wr_ptr) <= to_integer(unsigned(pixel_in));
                    report "Writing to line1, pixel: " & integer'image(to_integer(unsigned(pixel_in))) severity note;
                elsif line_cnt = 2 then
                    line2(wr_ptr) <= to_integer(unsigned(pixel_in));
                    report "Writing to line2, pixel: " & integer'image(to_integer(unsigned(pixel_in))) severity note;
                end if;
                
                -- Update write pointer
                if wr_ptr = IMG_WIDTH-1 then
                    wr_ptr <= 0;
                    if line_cnt < 2 then
                        line_cnt <= line_cnt + 1;
                    end if;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
                
                -- Simple processing: add 50 to the pixel (guaranteed non-zero)
                pixel_out <= std_logic_vector(to_unsigned(
                    (to_integer(unsigned(pixel_in)) + 50) mod 256, 
                    PIXEL_BITS
                ));
                pixel_ready <= '1';
                
                -- Update pixel counter
                if pixels_processed = IMG_WIDTH*IMG_HEIGHT - 1 then
                    -- Done with all pixels
                    processing <= '0';
                    busy <= '0';
                    done <= '1';
                    line_cnt <= 0;
                    wr_ptr <= 0;
                    pixels_processed <= 0;
                    report "Processing complete!" severity note;
                else
                    pixels_processed <= pixels_processed + 1;
                end if;
            end if;
        end if;
    end process;
end behavioral;