---- this file is part of the ADS library

library ads;
use ads.ads_fixed.all;

package ads_complex_pkg is
	-- complex number in rectangular form
	type ads_complex is
	record
		re: ads_sfixed;
		im: ads_sfixed;
	end record ads_complex;

	---- functions

	-- make a complex number
	function ads_cmplx (
			re, im: in ads_sfixed
		) return ads_complex;

	-- returns l + r
	function "+" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l - r
	function "-" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l * r
	function "*" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns the complex conjugate of arg
	function conj (
			arg: in ads_complex
		) return ads_complex;

	-- returns || arg || ** 2
	function abs2 (
			arg: in ads_complex
		) return ads_sfixed;

	-- constants
	constant complex_zero: ads_complex :=
					ads_cmplx(to_ads_sfixed(0), to_ads_sfixed(0));

end package ads_complex_pkg;

package body ads_complex_pkg is

		-- addition
		function "+" (
				l, r: in ads_complex
			) return ads_complex
		is
			variable ret: ads_complex;
		begin
			ret.re := l.re + r.re;
			ret.im := l.im + r.im;
			return ret;
		end function "+";


	------------------------------------------------
	-- create complex number
	------------------------------------------------
		function ads_cmplx (
				re, im: in ads_sfixed
			) return ads_complex
		is
			variable ret: ads_complex;
		begin
			ret.re := re;
			ret.im := im;
			return ret;
		end function ads_cmplx;


	------------------------------------------------
	-- subtraction
	------------------------------------------------
		function "-" (
				l, r: in ads_complex
			) return ads_complex
		is
			variable ret: ads_complex;
		begin
			ret.re := l.re - r.re;
			ret.im := l.im - r.im;
			return ret;
		end function "-";


	------------------------------------------------
	-- multiplication
	-- (a+bi)(c+di) = (ac - bd) + (ad + bc)i
	------------------------------------------------
		function "*" (
				l, r: in ads_complex
			) return ads_complex
		is
			variable ret: ads_complex;
			variable ac, bd, ad, bc: ads_sfixed;
		begin
			ac := l.re * r.re;
			bd := l.im * r.im;
			ad := l.re * r.im;
			bc := l.im * r.re;

			ret.re := ac - bd;
			ret.im := ad + bc;

			return ret;
		end function "*";


	------------------------------------------------
	-- complex conjugate
	------------------------------------------------
		function conj (
				arg: in ads_complex
			) return ads_complex
		is
			variable ret: ads_complex;
		begin
			ret.re := arg.re;
			ret.im := -arg.im;
			return ret;
		end function conj;


	------------------------------------------------
	-- magnitude squared
	-- |z|² = a² + b²
	------------------------------------------------
		function abs2 (
				arg: in ads_complex
			) return ads_sfixed
		is
		begin
			return (arg.re * arg.re) + (arg.im * arg.im);
		end function abs2;
		
end package body ads_complex_pkg;
