function rand_out = mofi_rand (N,min, max)
%
% rand_out = mofi_rand (N, min, max)
%
%    N: Number of random numbers to draw.
%  min: Minimum value of the drawn numbers.
%  max: Maximum value of the drawn numbers.
%
% This function is just a wrapper around the built-in ''rand'' function.
%
% 2012-01-12, Version 1.0, MFR
% 2012-12-18, Version 1.1, added variable ''N''. MFR
% 2014-10-28, Version 1.2, Renamed to from mfr_rand to mofi_rand.

rand_out = rand(N)*(max-min) + min;


