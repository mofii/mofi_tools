function c = mofi_dot_fast (a,b)
% c = mofi_dot_fast (a,b)
%
% It makes no input checks and assumes the matrices ''a'' and ''b'' are N times 3-element vectors.
% a: 3xN element matrix
% b: 3xN element matrix
% c: 1xN dot products
%
% By Mofi, 2014-03-10
%

c = a(1,:).* b(1,:) + a(2,:).* b(2,:) + a(3,:).* b(3,:);
