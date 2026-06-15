-- median_filter.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity median_filter is
    generic (
        PIXEL_BITS : integer := 8
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        pixels   : in  std_logic_vector(8*PIXEL_BITS-1 downto 0);
        median   : out std_logic_vector(PIXEL_BITS-1 downto 0);
        valid    : out std_logic
    );
end median_filter;

architecture behavioral of median_filter is
    type pixel_array is array (0 to 8) of unsigned(PIXEL_BITS-1 downto 0);
    signal sorted : pixel_array;
    
begin
    process(clk, reset)
        variable temp : unsigned(PIXEL_BITS-1 downto 0);
        variable v_sorted : pixel_array;
    begin
        if reset = '1' then
            median <= (others => '0');
            valid <= '0';
            
        elsif rising_edge(clk) then
            -- Unpack pixels
            for i in 0 to 8 loop
                v_sorted(i) := unsigned(pixels((i+1)*PIXEL_BITS-1 downto i*PIXEL_BITS));
            end loop;
            
            -- Bubble sort to find median
            for i in 0 to 7 loop
                for j in 0 to 7-i loop
                    if v_sorted(j) > v_sorted(j+1) then
                        temp := v_sorted(j);
                        v_sorted(j) := v_sorted(j+1);
                        v_sorted(j+1) := temp;
                    end if;
                end loop;
            end loop;
            
            sorted <= v_sorted;
            
            -- Output median (4th element in 3x3 window)
            median <= std_logic_vector(v_sorted(4));
            valid <= '1';
        end if;
    end process;
end behavioral;