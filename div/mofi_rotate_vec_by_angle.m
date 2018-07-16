function v_rot = mofi_rotate_vec_by_angle(v,phi,rot_axis)
% CFU_ROTATE_VEC_BY_ANGLE - Rotates a column vector by phi radians around the rot_axis (a column vector). 
%   
% v_rot = mofi_rotate_vec_by_angle(v,phi,rot_axis)
%
% By Mofi

% normalise the vector
L0 = rot_axis/norm(rot_axis);

% Rodrigues' rotation formula, from http://en.wikipedia.org/wiki/Axis-angle:
v_rot = v*cos(phi) + ...
        (v'*L0)*(1-cos(phi))*L0 + ...
        cross(L0,v)*sin(phi);

