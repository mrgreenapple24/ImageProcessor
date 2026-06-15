-- sobel_edge.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sobel_edge is
    generic (
        PIXEL_BITS : integer := 8
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        p00, p01, p02 : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        p10, p11, p12 : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        p20, p21, p22 : in  std_logic_vector(PIXEL_BITS-1 downto 0);
        magnitude   : out std_logic_vector(PIXEL_BITS-1 downto 0);
        valid       : out std_logic
    );
end sobel_edge;

architecture behavioral of sobel_edge is
    signal gx, gy : signed(PIXEL_BITS+2 downto 0);
    signal abs_gx, abs_gy : unsigned(PIXEL_BITS+2 downto 0);
    signal sum : unsigned(PIXEL_BITS+3 downto 0);
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            gx <= (others => '0');
            gy <= (others => '0');
            magnitude <= (others => '0');
            valid <= '0';
            
        elsif rising_edge(clk) then
            -- Sobel X direction: (-1 0 1, -2 0 2, -1 0 1)
            gx <= resize(signed('0' & p02), PIXEL_BITS+3) -
                  resize(signed('0' & p00), PIXEL_BITS+3) +
                  (resize(signed('0' & p12), PIXEL_BITS+3) - 
                   resize(signed('0' & p10), PIXEL_BITS+3)) * 2 +
                  resize(signed('0' & p22), PIXEL_BITS+3) -
                  resize(signed('0' & p20), PIXEL_BITS+3);
            
            -- Sobel Y direction: (-1 -2 -1, 0 0 0, 1 2 1)
            gy <= resize(signed('0' & p20), PIXEL_BITS+3) -
                  resize(signed('0' & p00), PIXEL_BITS+3) +
                  (resize(signed('0' & p21), PIXEL_BITS+3) - 
                   resize(signed('0' & p01), PIXEL_BITS+3)) * 2 +
                  resize(signed('0' & p22), PIXEL_BITS+3) -
                  resize(signed('0' & p02), PIXEL_BITS+3);
            
            -- Approximate magnitude: |Gx| + |Gy|
            abs_gx <= unsigned(abs(gx));
            abs_gy <= unsigned(abs(gy));
            sum <= ('0' & abs_gx) + ('0' & abs_gy);
            
            -- Clamp to pixel range
            if sum > (2**PIXEL_BITS - 1) then
                magnitude <= (others => '1');
            else
                magnitude <= std_logic_vector(sum(PIXEL_BITS-1 downto 0));
            end if;
            
            valid <= '1';
        end if;
    end process;
end behavioral;