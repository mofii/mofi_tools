function b = norm_fast(a)
% b = norm_fast(a)
%
% It make no input checks and assumes the matrix ''a'' is a N times 3-element vectors.
% a: 3xN element matrix
% b: 1xN norms
%
% By Mofi, 2014-03-10
%

b = sqrt(a(1,:).^2 + a(2,:).^2 + a(3,:).^2 );
