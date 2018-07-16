function b = squeeze_fast(a)
% squeeze_fast
% A faster version of squeeze
% It makes no input checks.
% b = squeeze_fast(a)
%
% By mofi, 2014-03-10
%

siz         = size(a);
siz(siz==0) = [];  % remove singleton dimensions.
b           =  reshape(a, siz);

