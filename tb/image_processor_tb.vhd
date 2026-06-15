-- working_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.all;

entity working_tb is
end working_tb;

architecture behavioral of working_tb is
    constant IMG_WIDTH  : integer := 4;
    constant IMG_HEIGHT : integer := 4;
    constant PIXEL_BITS : integer := 8;
    constant clk_period : time := 10 ns;
    
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal pixel_in    : std_logic_vector(PIXEL_BITS-1 downto 0) := (others => '0');
    signal pixel_valid : std_logic := '0';
    signal pixel_out   : std_logic_vector(PIXEL_BITS-1 downto 0);
    signal pixel_ready : std_logic;
    signal mode        : std_logic_vector(2 downto 0) := "001";
    signal process_en  : std_logic := '0';
    signal busy        : std_logic;
    signal done        : std_logic;
    
    -- Test pattern
    type test_pattern_t is array (0 to IMG_WIDTH*IMG_HEIGHT-1) of integer;
    constant test_pattern : test_pattern_t := (
        10, 20, 30, 40,
        50, 60, 70, 80,
        90, 100, 110, 120,
        130, 140, 150, 160
    );
    
begin
    -- Instantiate the processor
    uut: entity work.fixed_image_processor
        generic map (
            IMG_WIDTH  => IMG_WIDTH,
            IMG_HEIGHT => IMG_HEIGHT,
            PIXEL_BITS => PIXEL_BITS
        )
        port map (
            clk         => clk,
            reset       => reset,
            pixel_in    => pixel_in,
            pixel_valid => pixel_valid,
            pixel_out   => pixel_out,
            pixel_ready => pixel_ready,
            mode        => mode,
            process_en  => process_en,
            busy        => busy,
            done        => done
        );
    
    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Main test process
    test_process: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 20 ns;
        
        -- Start processing
        process_en <= '1';
        wait for clk_period;
        process_en <= '0';
        
        -- Feed test pattern
        report "Starting to feed test pattern..." severity note;
        
        for i in 0 to IMG_WIDTH*IMG_HEIGHT-1 loop
            pixel_in <= std_logic_vector(to_unsigned(test_pattern(i), PIXEL_BITS));
            pixel_valid <= '1';
            wait for clk_period;
            
            -- Report what we're sending
            report "Sent pixel " & integer'image(i) & ": " & integer'image(test_pattern(i)) severity note;
        end loop;
        
        pixel_valid <= '0';
        report "Finished sending all pixels" severity note;
        
        -- Wait for processing to complete
        while done /= '1' loop
            wait until rising_edge(clk);
        end loop;
        wait for 100 ns;
        
        -- End simulation
        report "SIMULATION COMPLETED SUCCESSFULLY" severity note;
        finish;
    end process;
    
    -- Monitor output
    monitor_process: process
    begin
        wait until rising_edge(clk);
        if pixel_ready = '1' then
            report "Output pixel: " & integer'image(to_integer(unsigned(pixel_out))) severity note;
        end if;
    end process;
    
end behavioral;