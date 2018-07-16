function [r, zx, zy] = mofi_cart2beam_coord (x, y, z)
%
% [r, zx, zy] = mofi_cart2beam_coord (x, y, z)
%
%
% By MFR, Init version 2014-05-15
%


% Do the calculation
r  = sqrt(x.^2 + y.^2 + z.^2);
zx = atan2(x, z);
zy = atan2(y, z);

