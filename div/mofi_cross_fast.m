function c = cross_fast(a,b)
% c = cross_fast(a,b)
%
% It makes no input checks and assumes the matrices ''a'' and ''b'' are N times 3-element vectors.
% a: 3xN element matrix
% b: 3xN element matrix
% c: 1xN cross products
%½
% By Mofi, 2014-03-10
%

c = [a(2,:).*b(3,:) - a(3,:).*b(2,:);
     a(3,:).*b(1,:) - a(1,:).*b(3,:);
     a(1,:).*b(2,:) - a(2,:).*b(1,:)];
