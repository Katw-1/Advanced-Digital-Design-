library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package complex_pkg is 
    constant width : integer := 32; 

    type ads_complex is record 
        re : signed(width-1 downto 0);
        im : signed(width-1 downto 0);
    end record;

    subtype ads_complex_mag is signed(width-1 downto 0);
    function complex_add(a, b : ads_complex) return ads_complex; 
    function complex_mult(a, b : ads_complex) return ads_complex;
    function complex_mag2(a : ads_complex) return ads_complex_mag; 

end package; 

package body complex_pkg is 
    function complex_add(a, b: ads_complex) return ads_complex is 
        variable r : ads_complex;
    begin 
        r.re := a.re + b.re;
        r.im := a.im + b.im; 
        return r;
    end; 

    function complex_mult(a,b : ads_complex) return ads_complex is 
        variable r : ads_complex; 
        variable ac, bd, ad, bc : signed(width-1 downto 0);
    begin 
        ac := resize(a.re * b.re, width);
        bd := resize(a.im * b.im, width);
        ad := resize(a.re * b.im, width);
        bd := resize(a.im * b.re, width);

        r.re := ac - bd;
        r.im := ad + bc; 

        return r;
    end; 
    
    function complex_mag2(a : ads_complex) return ads_complex_mag is
    begin 
        return resize(a.re * a.re + a.im * a.im, width);
    end;
    end package body; 