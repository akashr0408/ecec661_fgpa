library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

entity pe is
   generic (NUMBER_WIDTH:natural := 4;
            NUMBER_COUNT: natural:= 5);
   port(li, ri                               : in std_logic_vector(NUMBER_WIDTH-1 downto 0);
        lo, ro                               : out std_logic_vector(NUMBER_WIDTH-1 downto 0);
        scan_en, run_en, pe_type, reset, ck  : in std_logic);
end pe;

architecture behav of pe is
   signal temp           : std_logic_vector(NUMBER_WIDTH-1 downto 0);
   signal pe_flag        : std_logic := '0';
   type state_type is (sort_left, sort_right);
   signal cs             : state_type;
   
begin
   process(ck, run_en, reset)
   begin
      if ck='1' and ck'event then
         if reset = '1' then
            if (pe_type = '0') and (pe_flag = '0') then
               cs <= sort_right;
            elsif(pe_type = '0') and (pe_flag = '1') then
               cs <= sort_left;
            elsif (pe_type = '1') and (pe_flag = '0') then
               cs <= sort_left;
            elsif(pe_type = '1') and (pe_flag = '1') then
               cs <= sort_right;
            end if;
            temp      <= (others => '0');  
         elsif run_en = '1' then
             case cs is
                when sort_right =>
                   if ri < temp then
                      temp <= ri;
                   end if;
                   cs <= sort_left;
                when sort_left =>
                   if temp < li then
                      temp <= li;
                   end if;
                   cs <= sort_right;
             end case;
         elsif scan_en = '1' then
            temp <= li;
         end if;
      end if;
   end process;

   lo <= temp;
   ro <= temp;
end behav;