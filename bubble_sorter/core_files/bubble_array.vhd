library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity bubble_array is
   generic(NUMBER_WIDTH:natural := 3;
           NUMBER_COUNT:natural := 4);
   port   (d_in                        : in std_logic_vector(NUMBER_WIDTH-1 downto 0);
           d_out                       : out std_logic_vector(NUMBER_WIDTH-1 downto 0);
           done                        : out std_logic;
           scan_en, run_en, reset, ck  : in std_logic);
end bubble_array;

architecture struct of bubble_array is
   component pe
      generic (NUMBER_WIDTH:natural := 4;
               NUMBER_COUNT: natural:= 5);
      port(li, ri                               : in std_logic_vector(NUMBER_WIDTH-1 downto 0);
           lo, ro                               : out std_logic_vector(NUMBER_WIDTH-1 downto 0);
           scan_en, run_en, pe_type, reset, ck  : in std_logic);
   end component;

   type vector_array is array(natural range<>) of std_logic_vector(NUMBER_WIDTH-1 downto 0);
   signal w_l                             :  vector_array(0 to NUMBER_COUNT);
   signal w_r                             :  vector_array(0 to NUMBER_COUNT-1);
   signal odd, even                       :  std_logic;
   signal minus_infinity, infinity, w_in  :  std_logic_vector(NUMBER_WIDTH-1 downto 0);
begin

   minus_infinity <= (others => '0');
   infinity       <= (others => '1');
   odd            <= '1';
   even           <= '0';

   process(scan_en, d_in)
   begin
      if scan_en = '1' then
         w_in <= d_in;
      else
         w_in <= minus_infinity;
      end if;
   end process;
   w_l(0)   <= w_in;
   w_r(NUMBER_COUNT-1) <= infinity;
   d_out    <= w_l(NUMBER_COUNT);


   --process to set done signal
   process (ck)
      variable count : integer := 0;
   begin
      if rising_edge(ck) then
         if reset = '1' or scan_en='1' then
            count := 0;
         elsif run_en='1' then
            count := count + 1;
         end if;
         if count >= NUMBER_COUNT then
            done <= '1';
         else
            done <='0';
         end if; 
      end if;
   end process;

   --generate statement
   gen_bubble_sorter: for I in 0 to NUMBER_COUNT-1 generate
      left_most: if i =0 generate
         u0: pe generic map(
         NUMBER_WIDTH => NUMBER_WIDTH,
         NUMBER_COUNT => NUMBER_COUNT
      )
         port map(
         scan_en  => scan_en,
         reset    => reset,
         run_en   => run_en,
         ck       => ck,
         pe_type  => even,
         li       => w_l(i),
         lo       => open,
         ri       => w_r(i),
         ro       => w_l(i+1)
      );
      end generate left_most;
 
      even_pe: if i mod 2 = 0 and i /= 0 generate
         u1:pe generic map(
         NUMBER_WIDTH => NUMBER_WIDTH,
         NUMBER_COUNT => NUMBER_COUNT
      )
         port map(
         scan_en  => scan_en,
         reset    => reset,
         run_en   => run_en,
         ck       => ck,
         pe_type  => even,
         li       => w_l(i),
         lo       => w_r(i-1),
         ri       => w_r(i),
         ro       => w_l(i+1)
      );
      end generate even_pe;

      odd_pe: if i mod 2 = 1 generate
         u2: pe generic map( 
         NUMBER_WIDTH => NUMBER_WIDTH,
         NUMBER_COUNT => NUMBER_COUNT
      )
         port map(
         scan_en  => scan_en,
         reset    => reset,
         run_en   => run_en,
         ck       => ck,
         pe_type  => odd,
         li       => w_l(i),
         lo       => w_r(i-1),
         ri       => w_r(i),
         ro       => w_l(i+1)
      );
      end generate odd_pe;
   end generate gen_bubble_sorter;


end struct;