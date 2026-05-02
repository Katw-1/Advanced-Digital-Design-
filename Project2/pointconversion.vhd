library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_complex_pkg.all;
use ads.ads_fixed.all;

package pointconversion is
function map_coordinate_to_complex (
		point:	in	coordinate;
		vga_res:	in	vga_timing;
		mode:	in	std_logic
	) return ads_complex;
end package pointconversion;

package body pointconversion is

function map_coordinate_to_complex (
		point:	in	coordinate;
		vga_res:	in	vga_timing;
		mode:	in	std_logic
	) return ads_complex
is
	---- these are constants so computing them generates no hardware!
	-- mandelbrot window, ranges are arbitrarily chosen
	constant x_min_mandelbrot:	real := -2.2;	-- ranges keep 4:3 aspect ratio
	constant x_max_mandelbrot:	real :=  1.0;	-- the .0 is important!
	constant y_min_mandelbrot:	real := -1.2;
	constant y_max_mandelbrot:	real :=  1.2;
	
	-- julia window, ranges are arbitrarily chosen
	constant x_min_julia:	real := -2.0;	-- ranges keep 4:3 aspect ratio
	constant x_max_julia:	real :=  2.0;
	constant y_min_julia:	real := -1.5;
	constant y_max_julia:	real :=  1.5;
	
	---- deltas, conversion from integer to real is important!
	-- mandelbrot deltas
	constant delta_x_mandelbrot: ads_sfixed := to_ads_sfixed(
				(x_max_mandelbrot - x_min_mandelbrot) / real(vga_res.horizontal.active)
			);
	constant delta_y_mandelbrot: ads_sfixed := to_ads_sfixed(
				(y_min_mandelbrot - y_max_mandelbrot) / real(vga_res.vertical.active)
			);
	-- TODO: similar for julia!
    constant delta_x_julia: ads_sfixed := to_ads_sfixed(
				(x_max_julia - x_min_julia) / real(vga_res.horizontal.active)
			);
	constant delta_y_julia: ads_sfixed := to_ads_sfixed(
				(y_min_julia - y_max_julia) / real(vga_res.vertical.active)
			);
	
	---- variables
	variable x_delta, y_delta, x_min, y_max: ads_sfixed;
	variable ret: ads_complex;
begin
	-- this infers multiplexers
	if mode = '1' then
		x_delta := delta_x_mandelbrot;
		y_delta := delta_y_mandelbrot;
		x_min := to_ads_sfixed(x_min_mandelbrot); -- folds constant
		y_max := to_ads_sfixed(y_max_mandelbrot);
	else
		-- TODO: similar for julias
        x_delta := delta_x_julia;
		y_delta := delta_y_julia;
		x_min := to_ads_sfixed(x_min_julia); -- folds constant
		y_max := to_ads_sfixed(y_max_julia);
	end if;
	
	-- two multipliers and two adders
	ret.re := x_delta * to_ads_sfixed(point.x) + x_min;
	ret.im := y_delta * to_ads_sfixed(point.y) + y_max;
	
	return ret;
end function map_coordinate_to_complex;

end package body pointconversion;
