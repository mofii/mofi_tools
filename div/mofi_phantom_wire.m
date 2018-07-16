function [pos amp] = mofi_phantom_wire(radius, x_center, x_length, y_center, z_center, num_points, threshhold)
% CFU_PHANTOM_WIRE - Create a more realistic wire phantom.
%   
% mofi_phantom_wire(radius, x_center, x_length, y_center, z_center, num_points [,threshold=0.01])
%
% By Morten F. Rasmussen, 2014-10-28.
%

if nargin < 7, threshhold = 0.01; end
    
% Normalized positions
angle  = mofi_rand([num_points 1], 0, 2*pi);
x_nosc = mofi_rand([num_points 1], -1, 1);
y_nosc = cos(angle);
z_nosc = sin(angle);

% Amplitude from normalized positions
amp_x = sin(((x_nosc+1)/2)*pi);
amp_y = sin(((y_nosc+1)/2)*pi);
amp_z = ones(num_points, 1);
amp = amp_x .* amp_y .* amp_z;
%p.pht_amp = p.pht_amp.^2; 

% Scale positions
x = x_nosc*x_length/2 + x_center;
y = y_nosc*radius     + y_center;
z = z_nosc*radius     + z_center;
pos = [x y z];

% Remove scatterer with too low a reflection coeff.
idx = find(amp < threshhold);
pos(idx, :) = [];
amp(idx)    = [];

